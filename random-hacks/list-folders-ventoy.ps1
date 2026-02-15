$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } elseif ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { (Get-Location).Path }
$driveRoot = [System.IO.Path]::GetPathRoot($scriptDir)
$driveRootLetter = $driveRoot.TrimEnd('\')
$root = Join-Path $driveRoot 'ISOS'

if (-not (Test-Path $root)) {
  Write-Error "ISOS folder not found at $root"
  exit 1
}

Get-ChildItem -Path $root -Recurse -File |
  Select-Object @{n="Path";e={$_.FullName.Replace($driveRootLetter,"")}},
                @{n="SizeMB";e={[math]::Round($_.Length/1MB,1)}},
                LastWriteTime |
  Sort-Object Path |
  Out-File (Join-Path $driveRoot 'iso_list.txt') -Encoding UTF8

