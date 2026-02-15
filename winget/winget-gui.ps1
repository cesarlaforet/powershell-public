Add-Type -AssemblyName System.Windows.Forms, System.Drawing

function Get-UpgradablePackages {
    try {
        $tempOut = [System.IO.Path]::GetTempFileName()
        $tempErr = [System.IO.Path]::GetTempFileName()
        $exe = 'winget.exe'
        # detect whether winget supports --output before using JSON mode
        $helpText = ''
        try { $helpText = & $exe --help 2>$null | Out-String } catch { $helpText = '' }
        if ($helpText -and ($helpText -match '--output')) {
            $argsJson = @('upgrade','--accept-source-agreements','--accept-package-agreements','--output','json')
        } else {
            $argsJson = @('upgrade','--accept-source-agreements','--accept-package-agreements')
        }

        try {
            Start-Process -FilePath $exe -ArgumentList $argsJson -NoNewWindow -RedirectStandardOutput $tempOut -RedirectStandardError $tempErr -Wait -ErrorAction Stop
            $stderr = ''
            try { $stderr = Get-Content -Raw -ErrorAction Stop -Path $tempErr } catch { $stderr = '' }
            $raw = ''
            try { $raw = Get-Content -Raw -ErrorAction Stop -Path $tempOut } catch { $raw = '' }

            if ($stderr -and $stderr -match "Argument name was not recognized") {
                # Fall through to text parsing fallback below
                $raw = $null
            }
        } catch {
            # If JSON mode failed, fall back to text mode
            $raw = $null
        }

        if (-not $raw) {
            # Text-mode fallback: call winget directly to mirror terminal behaviour
            try {
                $rawLines = & winget upgrade --accept-source-agreements --accept-package-agreements 2>&1
                if ($rawLines) { $raw = ($rawLines -join "`n") } else { $raw = '' }
            } catch {
                $raw = ''
            }

            # If no upgradable versions shown, try include-unknown which some winget versions use
            if (-not $raw -or ($raw -match 'Multiple installed packages found')) {
                try {
                    $rawLines2 = & winget upgrade --accept-source-agreements --accept-package-agreements --include-unknown 2>&1
                    if ($rawLines2) { $raw2 = ($rawLines2 -join "`n") } else { $raw2 = '' }
                    if ($raw2 -and ($raw2.Length -gt $raw.Length)) { $raw = $raw2 }
                } catch {
                    # ignore
                }
            }
        }

        if (-not $raw) { return @() }

        # Try parse JSON first
        $data = $null
        try { $data = $raw | ConvertFrom-Json -ErrorAction Stop } catch { $data = $null }

        $items = @()
        if ($data) {
            if ($data -is [System.Array]) { $items = $data }
            elseif ($data -is [System.Management.Automation.PSCustomObject]) {
                if ($data.upgrades) { $items = $data.upgrades }
                elseif ($data.Upgrades) { $items = $data.Upgrades }
                elseif ($data.value) { $items = $data.value }
                elseif ($data.Value) { $items = $data.Value }
                elseif ($data.packages) { $items = $data.packages }
                elseif ($data.Packages) { $items = $data.Packages }
                elseif ($data.results) { $items = $data.results }
                else { $items = @($data) }
            }
        } else {
            # parse plain-text table from winget: split columns on two+ spaces
            $lines = $raw -split "`r?`n"
            $dataRows = @()
            foreach ($ln in $lines) {
                $s = $ln.Trim()
                if (-not $s) { continue }
                if ($s -match '\d+\s+upgrades available') { break }
                if ($s -match '^[-\s]+$') { continue }
                if ($s -match '\bName\b' -and $s -match '\bId\b') { continue }
                $cols = ($ln -split '\s{2,}') | ForEach-Object { $_.Trim() }
                if ($cols.Count -ge 4) {
                    $dataRows += [PSCustomObject]@{
                        packageName = $cols[0]
                        packageIdentifier = $cols[1]
                        installedVersion = $cols[2]
                        availableVersion = $cols[3]
                        source = if ($cols.Count -gt 4) { $cols[4] } else { '' }
                    }
                }
            }
            $items = $dataRows
        }

        $list = @()
        foreach ($pkg in $items) {
            $obj = [PSCustomObject]@{
                Id = ($pkg.packageIdentifier -or $pkg.PackageIdentifier -or $pkg.Id -or $pkg.PackageId -or $pkg.PackageIdentifierValue -or '')
                Name = ($pkg.packageName -or $pkg.PackageName -or $pkg.Name -or $pkg.packageDisplayName -or '')
                InstalledVersion = ($pkg.installedVersion -or $pkg.InstalledVersion -or $pkg.Version -or '')
                AvailableVersion = ($pkg.availableVersion -or $pkg.AvailableVersion -or $pkg.Available -or '')
                Source = ($pkg.source -or $pkg.Source -or '')
            }
            $list += $obj
        }

        # Keep only rows that actually show an available version different from installed
        $filtered = $list | Where-Object { $_.AvailableVersion -and ($_.AvailableVersion -ne '') -and ($_.AvailableVersion -ne $_.InstalledVersion) }
        return $filtered
    } catch {
        return @()
    } finally {
        if (Test-Path $tempOut) { Remove-Item -ErrorAction SilentlyContinue $tempOut }
        if (Test-Path $tempErr) { Remove-Item -ErrorAction SilentlyContinue $tempErr }
    }
}

function New-Gui {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Winget Updater'
    $form.Size = [System.Drawing.Size]::New(900,600)
    $form.StartPosition = 'CenterScreen'

    $dgv = New-Object System.Windows.Forms.DataGridView
    $dgv.Size = [System.Drawing.Size]::New(880,350)
    $dgv.Location = [System.Drawing.Point]::New(8,8)
    $dgv.AllowUserToAddRows = $false
    $dgv.ReadOnly = $false
    $dgv.SelectionMode = 'FullRowSelect'
    $dgv.MultiSelect = $false

    $colCheck = New-Object System.Windows.Forms.DataGridViewCheckBoxColumn
    $colCheck.HeaderText = ''
    $colCheck.Width = 30
    $dgv.Columns.Add($colCheck) | Out-Null

    $dgv.Columns.Add('Name','Name') | Out-Null
    $dgv.Columns.Add('Id','Id') | Out-Null
    $dgv.Columns.Add('InstalledVersion','Installed') | Out-Null
    $dgv.Columns.Add('AvailableVersion','Available') | Out-Null
    $dgv.Columns.Add('Source','Source') | Out-Null

    $btnRefresh = New-Object System.Windows.Forms.Button
    $btnRefresh.Text = 'Refresh'
    $btnRefresh.Size = [System.Drawing.Size]::New(100,30)
    $btnRefresh.Location = [System.Drawing.Point]::New(8,370)

    $btnUpgradeSelected = New-Object System.Windows.Forms.Button
    $btnUpgradeSelected.Text = 'Upgrade Selected'
    $btnUpgradeSelected.Size = [System.Drawing.Size]::New(140,30)
    $btnUpgradeSelected.Location = [System.Drawing.Point]::New(120,370)

    $btnUpgradeAll = New-Object System.Windows.Forms.Button
    $btnUpgradeAll.Text = 'Upgrade All'
    $btnUpgradeAll.Size = [System.Drawing.Size]::New(100,30)
    $btnUpgradeAll.Location = [System.Drawing.Point]::New(272,370)

    $txtLog = New-Object System.Windows.Forms.TextBox
    $txtLog.Multiline = $true
    $txtLog.ScrollBars = 'Vertical'
    $txtLog.ReadOnly = $true
    $txtLog.Size = [System.Drawing.Size]::New(880,150)
    $txtLog.Location = [System.Drawing.Point]::New(8,410)

    $form.Controls.AddRange(@($dgv,$btnRefresh,$btnUpgradeSelected,$btnUpgradeAll,$txtLog))

    $global:packages = @()

    function Populate-Grid {
        $dgv.Rows.Clear()
        $global:packages = Get-UpgradablePackages
        foreach ($p in $global:packages) {
            $idx = $dgv.Rows.Add()
            $row = $dgv.Rows[$idx]
            $row.Cells[0].Value = $false
            $row.Cells[1].Value = $p.Name
            $row.Cells[2].Value = $p.Id
            $row.Cells[3].Value = $p.InstalledVersion
            $row.Cells[4].Value = $p.AvailableVersion
            $row.Cells[5].Value = $p.Source
        }
    }

    $btnRefresh.Add_Click({
        $txtLog.AppendText("Refreshing list...`r`n")
        Populate-Grid
        $txtLog.AppendText("Found $($global:packages.Count) upgradable packages.`r`n")
    })

    function Run-Upgrade([string[]]$ids) {
        if (-not $ids -or $ids.Count -eq 0) { return }
        $btnRefresh.Enabled = $false; $btnUpgradeSelected.Enabled = $false; $btnUpgradeAll.Enabled = $false
        foreach ($id in $ids) {
            $txtLog.AppendText("=== Upgrading: $id ===`r`n")
            try {
                $args = @('upgrade','--id',$id,'--accept-source-agreements','--accept-package-agreements')
                $proc = Start-Process -FilePath winget -ArgumentList $args -NoNewWindow -RedirectStandardOutput -RedirectStandardError -PassThru
                $out = $proc.StandardOutput.ReadToEnd()
                $err = $proc.StandardError.ReadToEnd()
                $proc.WaitForExit()
                if ($out) { $txtLog.AppendText($out + "`r`n") }
                if ($err) { $txtLog.AppendText("ERROR: " + $err + "`r`n") }
            } catch {
                $txtLog.AppendText(("Failed to run winget for {0}: {1}`r`n" -f $id, $_.ToString()))
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
        $txtLog.AppendText("Upgrades complete.`r`n")
        $btnRefresh.Enabled = $true; $btnUpgradeSelected.Enabled = $true; $btnUpgradeAll.Enabled = $true
        Populate-Grid
    }

    $btnUpgradeSelected.Add_Click({
        $sel = @()
        for ($i=0; $i -lt $dgv.Rows.Count; $i++) {
            if ($dgv.Rows[$i].Cells[0].Value -eq $true) {
                $id = $dgv.Rows[$i].Cells[2].Value
                if ($id) { $sel += $id }
            }
        }
        if ($sel.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show('No packages selected','Info',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information); return }
        Run-Upgrade -ids $sel
    })

    $btnUpgradeAll.Add_Click({
        $all = @()
        foreach ($p in $global:packages) { if ($p.Id) { $all += $p.Id } }
        if ($all.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show('No upgradable packages found','Info') ; return }
        $ok = [System.Windows.Forms.MessageBox]::Show("Upgrade all $($all.Count) packages?","Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($ok -eq [System.Windows.Forms.DialogResult]::Yes) { Run-Upgrade -ids $all }
    })

    # initial population
    Populate-Grid
    $txtLog.AppendText("Ready. Found $($global:packages.Count) upgradable packages.`r`n")

    [void]$form.ShowDialog()
}

New-Gui
