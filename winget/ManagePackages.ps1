Add-Type -AssemblyName System.Windows.Forms

# Function to load JSON content
function Load-JsonContent($filePath) {
    $jsonContent = Get-Content -Path $filePath -Raw | ConvertFrom-Json
    return $jsonContent
}

# Function to display the GUI
function Show-PackagesGUI($jsonContent, $filePath) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Packages"
    $form.Size = New-Object System.Drawing.Size(500, 450)

    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Size = New-Object System.Drawing.Size(460, 300)
    $listBox.Location = New-Object System.Drawing.Point(10, 10)

    foreach ($source in $jsonContent.Sources) {
        $sourceName = $source.SourceDetails.Name
        foreach ($package in $source.Packages) {
            $listBox.Items.Add("$($package.PackageIdentifier) - $sourceName", $true)
        }
    }

    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.Location = New-Object System.Drawing.Point(10, 320)
    $selectAllButton.Size = New-Object System.Drawing.Size(120, 25)

    $selectAllButton.Add_Click({
        0..($listBox.Items.Count - 1) | ForEach-Object { $listBox.SetItemChecked($_, $true) }
    })

    $deselectAllButton = New-Object System.Windows.Forms.Button
    $deselectAllButton.Text = "Deselect All"
    $deselectAllButton.Location = New-Object System.Drawing.Point(140, 320)
    $deselectAllButton.Size = New-Object System.Drawing.Size(120, 25)

    $deselectAllButton.Add_Click({
        0..($listBox.Items.Count - 1) | ForEach-Object { $listBox.SetItemChecked($_, $false) }
    })

    $updateButton = New-Object System.Windows.Forms.Button
    $updateButton.Text = "Update"
    $updateButton.Location = New-Object System.Drawing.Point(10, 360)
    $updateButton.Size = New-Object System.Drawing.Size(460, 25)

    $updateButton.Add_Click({
        $selectedPackages = $listBox.CheckedItems | ForEach-Object { $_.Split(" - ")[0] }
        Save-SelectedPackages -JsonContent $jsonContent -SelectedItems $selectedPackages -OriginalFilePath $filePath
        $form.Close()
    })

    $form.Controls.Add($listBox)
    $form.Controls.Add($selectAllButton)
    $form.Controls.Add($deselectAllButton)
    $form.Controls.Add($updateButton)

    $form.ShowDialog()
}

# Function to update JSON content
function Update-JsonContent($jsonContent, $selectedItems, $filePath) {
    foreach ($source in $jsonContent.Sources) {
        $newPackages = @()
        foreach ($package in $source.Packages) {
            if ($selectedItems -contains $package.PackageIdentifier) {
                $newPackages += $package
            }
        }
        $source.Packages = $newPackages
    }

    $updatedJson = $jsonContent | ConvertTo-Json -Depth 10
    Set-Content -Path $filePath -Value $updatedJson
}

# Function to save selected packages to a new JSON file
function Save-SelectedPackages($jsonContent, $selectedItems, $originalFilePath) {
    $newSources = @()

    foreach ($source in $jsonContent.Sources) {
        $newPackages = @()
        foreach ($package in $source.Packages) {
            if ($selectedItems -contains $package.PackageIdentifier) {
                $newPackages += $package
            }
        }
        
        # Only add sources which have selected packages
        if ($newPackages.Count -gt 0) {
            $source.Packages = $newPackages
            $newSources += $source
        }
    }
    
    $jsonContent.Sources = $newSources

    $newFileName = $originalFilePath -replace "_InstalledApps\.json$", "_InstalledApps_SelectedOnly.json"
    $updatedJson = $jsonContent | ConvertTo-Json -Depth 10 -Compress

    Set-Content -Path $newFileName -Value $updatedJson
}

# Main Execution
$filePath = $args[0] # The path of the dropped file will be the first argument

if ($filePath -match "\d{4}-\d{2}-\d{2}\.\d{2}_.+_InstalledApps.json") {
    $jsonContent = Load-JsonContent -FilePath $filePath
    Show-PackagesGUI -JsonContent $jsonContent -FilePath $filePath
} else {
    Write-Output "Invalid file format!"
}
