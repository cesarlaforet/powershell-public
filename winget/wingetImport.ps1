# wingetImport.ps1
param (
    [string]$filePath
)

# Check if the provided file exists
if (Test-Path $filePath) {
    # Execute the winget import command with the provided file
    winget import -i $filePath
} else {
    Write-Output "File not found: $filePath"
}

Read-Host -Prompt "Press Enter to exit"
