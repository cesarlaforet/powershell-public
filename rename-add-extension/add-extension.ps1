$ListOfFiles = Get-ChildItem -Path $Path -Recurse -File -Filter '*.'

foreach ($File in $ListOfFiles) {
    Write-Host "file: $File"
    $NewFile = $File.ToString() + '.jpg'
    Write-Host "New File: $NewFile"
    Rename-Item $File $NewFile
}


