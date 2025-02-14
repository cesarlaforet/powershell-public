# set current version from version.txt file
$version = "1.0.5"

# write the the console making it very visibel the current version of the script
Write-Host "***************************"
Write-Host "connect-ssh-rdp.ps1 v$version"
Write-Host "___________________________"

# Check the GitHub repository for the latest version
$latestVersion = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/cesarlaforet/powershell-public/main/rdp-thru-ssh/version.txt"
if ($null -ne $latestVersion) {
    $latestVersion = $latestVersion.Trim()
    if ($latestVersion -ne $Version) {
        Write-Host "A newer version is available: $latestVersion"
        Write-Host "Downloading the latest executable..."

        # Define the URL of the latest executable
        $latestExeUrl = "https://raw.githubusercontent.com/cesarlaforet/powershell-public/main/rdp-thru-ssh/connect-ssh-rdp.exe"

        # Define the path to save the latest executable
        $tempExePath = Join-Path -Path $env:TEMP -ChildPath "connect-ssh-rdp-latest.exe"

        # Download the latest executable
        Invoke-WebRequest -Uri $latestExeUrl -OutFile $tempExePath

        Write-Host "Downloaded the latest executable to $tempExePath"

        # Create a batch file to replace the old executable with the new one and restart it
        $batchFilePath = Join-Path -Path $env:TEMP -ChildPath "update-and-restart.bat"
        $currentExePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName

        $batchFileContent = @"
@echo off
timeout /t 3 /nobreak > nul
copy /y "$tempExePath" "$currentExePath"
start "" "$currentExePath"
del "%~f0"
"@

        $batchFileContent | Out-File -FilePath $batchFilePath -Encoding ASCII

        Write-Host "Executing the update batch file..."
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $batchFilePath"

        # Exit the current script
        exit
    }
}


# Define the path to the configuration file
$configFilePath = "connect-ssh-rdp.cfg"

# Default configuration content
$defaultConfigContent = @"
`$sshServer = "<server_address>"
`$sshPort = "<22XX>"
`$sshUser = "<ssh_user>"
`$rdpUser = "<rdp_user>"
`$localPort = 3399
`$fullscreen = 1
`$desktopwidth = 1920
`$desktopheight = 1080
"@

# Function to create the default configuration file
function CreateDefaultConfig {
    $defaultConfigContent | Out-File -FilePath $configFilePath -Encoding ASCII
    Write-Host "Configuration file created at $configFilePath. Please update it with your settings."
    Read-Host "Press Enter to exit"
    exit
}

# Check if the configuration file exists
if (-Not (Test-Path -Path $configFilePath)) {
    CreateDefaultConfig
}

# Load the configuration file
$configContent = Get-Content -Path $configFilePath -Raw
Invoke-Expression $configContent

# Validate the configuration file
if ($sshServer -eq "<server_address>" -or
    $sshPort -eq "<22XX>" -or
    $sshUser -eq "<ssh_user>" -or
    $rdpUser -eq "<rdp_user>") {
    Write-Host "Configuration file contains default values. Please update $configFilePath with your settings."
    Read-Host "Press Enter to exit"
    exit
}

# Function to check if SSH tunnel is already running
function Test-SSHTunnel {
    $isTunnelActive = netstat -an | Select-String ":$localPort.*LISTEN"
    if ($isTunnelActive) {
        return $true
    }
    return $false
}

# Function to start SSH tunnel
function Start-SSHTunnel {
    if (Test-SSHTunnel) {
        Write-Host "Skipping SSH tunnel setup as it is already active."
        return $true
    }
    Write-Host "Starting SSH tunnel..."

    $sshCommand = "ssh -o StrictHostKeyChecking=no -L $localPort`:localhost`:3389 -p $sshPort $sshUser@$sshServer"
    Write-Host "Executing SSH Command: $sshCommand"

    # Start the SSH process without redirection
    $sshProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $sshCommand"  -NoNewWindow -PassThru

    # Wait for the user to enter the password and the SSH tunnel to establish
    while (-not (Test-SSHTunnel)) {
        Start-Sleep -Seconds 5
    }

    if (Test-SSHTunnel) {
        Write-Host "SSH tunnel established successfully on port $localPort."
        return $sshProcess
    } else {
        Write-Host "Failed to establish SSH tunnel on port $localPort."
        return $null
    }
}

# Determine the screen mode based on the fullscreen setting
if ($fullscreen -eq 1) {
    $screenmode = 2
    $mstscScreenMode = "/f"
} else {
    $screenmode = 0
    $mstscScreenMode = ""
}

# Check if $desktopwidth and $desktopheight are set if not use default values 1920x1080
if (-not $desktopwidth -or $desktopwidth -eq 0 -or -not $desktopheight -or $desktopheight -eq 0) {
    $desktopwidth = 1920
    $mstscWidth = "/w:1920"
    $desktopheight = 1080
    $mstscHeight = "/h:1080"
} else {
    $mstscWidth = "/w:$desktopwidth"
    $mstscHeight = "/h:$desktopheight"
}


# Function to start RDP connection
function Start-RDPConnection {
    # set the path to the RDP file
    $rdpFilePath = "connect.rdp"

    $rdpFileContent = @"
screen mode id:i:$screenmode
use multimon:i:0
desktopwidth:i:$desktopwidth
desktopheight:i:$desktopheight
session bpp:i:32
winposstr:s:0,1,0,0,800,600
compression:i:1
keyboardhook:i:2
audiocapturemode:i:0
videoplaybackmode:i:1
connection type:i:2
networkautodetect:i:1
bandwidthautodetect:i:1
displayconnectionbar:i:1
enableworkspacereconnect:i:0
disable wallpaper:i:0
allow font smoothing:i:0
allow desktop composition:i:0
disable full window drag:i:1
disable menu anims:i:1
disable themes:i:0
disable cursor setting:i:0
bitmapcachepersistenable:i:1
full address:s:localhost:$localPort
username:s:$rdpUser
remoteappmousemoveinject:i:1
audiomode:i:0
redirectprinters:i:1
redirectlocation:i:0
redirectcomports:i:0
redirectsmartcards:i:1
redirectwebauthn:i:1
redirectclipboard:i:1
redirectposdevices:i:0
drivestoredirect:s:
autoreconnection enabled:i:1
authentication level:i:2
prompt for credentials:i:0
negotiate security layer:i:1
remoteapplicationmode:i:0
alternate shell:s:
shell working directory:s:
gatewayhostname:s:
gatewayusagemethod:i:4
gatewaycredentialssource:i:4
gatewayprofileusagemethod:i:0
promptcredentialonce:i:0
gatewaybrokeringtype:i:0
use redirection server name:i:0
rdgiskdcproxy:i:0
kdcproxyname:s:
enablerdsaadauth:i:0
"@

    $rdpFileContent | Out-File -FilePath $rdpFilePath -Encoding ASCII
    
    # Wait the file to be created
    while (-not (Test-Path -Path $rdpFilePath)) {
        Start-Sleep -Seconds 5
    }
    
    # Verify if the file was created
    if (Test-Path -Path $rdpFilePath) {
        Write-Host "RDP file created successfully at $rdpFilePath"
    } else {
        Write-Host "Failed to create RDP file at $rdpFilePath"
        return
    }

    # Debugging: Print the arguments to verify their values
    $arguments = @($rdpFilePath, "/v:localhost:$localPort", $mstscWidth, $mstscHeight, $mstscScreenMode)

    # Start the RDP connection
    $rdpProcess = Start-Process -FilePath "mstsc.exe" -ArgumentList "$arguments" -Wait -PassThru

    # Remove the temporary RDP file
    Remove-Item -Path $rdpFilePath -Force


    return $rdpProcess
}

# Main Execution
$sshProcess = Start-SSHTunnel

# Start the RDP connection if the SSH tunnel was established
if ($sshProcess) {
    $rdpProcess = Start-RDPConnection
    if ($rdpProcess) {
        # check the status of the RDP process
        $rdpProcess.WaitForExit()
        Write-Host "RDP connection closed."

        # Close the SSH tunnel process
        Stop-Process -Id (netstat -ano | findstr :$sshPort | ForEach-Object { ($_ -split '\s+')[5] })
        
        Write-Host "SSH tunnel closed."
    } else {
        Write-Host "Failed to start RDP connection."
    }
}

# Close the terminal
exit