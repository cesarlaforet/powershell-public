# get the program version from the version.txt file
$version = Get-Content -Path "version.txt"

# Description: Generate executable file from powershell script
Invoke-ps2exe .\connect-ssh-rdp.ps1 -outputFile .\connect-ssh-rdp.exe -iconFile .\icon.ico -product "Connect SSH RDP" -version "$version" -copyright "© 2024 Imperador Corp."
