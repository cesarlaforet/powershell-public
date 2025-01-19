# Define the path to the configuration file
$configFilePath = "connect-ssh-rdp.cfg"

# Default configuration content
$defaultConfigContent = @"
`$sshServer = "<server_address>"
`$sshPort = "<22XX>"
`$sshUser = "<ssh_user>"
`$rdpUser = "<rdp_user>"
`$localPort = 3399
"@

# Function to create the default configuration file
function CreateDefaultConfig {
    $defaultConfigContent | Out-File -FilePath $configFilePath -Encoding ASCII
    Write-Host "Configuration file created at $configFilePath. Please update it with your settings."
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
    exit
}

# Function to check if SSH tunnel is already running
function Test-SSHTunnel {
    $isTunnelActive = netstat -an | Select-String ":$localPort.*LISTEN"
    if ($isTunnelActive) {
        Write-Host "An SSH tunnel is already active on port $localPort."
        return $true
    }
    return $false
}

# Function to start SSH tunnel
function Start-SSHTunnel {
    if (Test-SSHTunnel) {
        Write-Host "Skipping SSH tunnel setup as it is already active."
        return
    }
    Write-Host "Starting SSH tunnel..."

    $sshCommand = "ssh -o StrictHostKeyChecking=no -L $localPort`:localhost`:3389 -p $sshPort $sshUser@$sshServer"
    Write-Host "Executing SSH Command: $sshCommand"

    # Start the SSH process
    $sshProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c $sshCommand" -NoNewWindow -PassThru

    Start-Sleep -Seconds 5 # Give the tunnel time to establish

    if (Test-SSHTunnel) {
        Write-Host "SSH tunnel established successfully on port $localPort."
        return $sshProcess
    } else {
        Write-Host "Failed to establish SSH tunnel on port $localPort."
        return $null
    }
}

# Function to start RDP connection
# Function to start RDP connection
function Start-RDPConnection {
    $rdpFilePath = [System.IO.Path]::GetTempFileName() + ".rdp"
    $rdpFileContent = @"
screen mode id:i:2
use multimon:i:0
desktopwidth:i:1920
desktopheight:i:1080
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
"@

    $rdpFileContent | Out-File -FilePath $rdpFilePath -Encoding ASCII

    $rdpProcess = Start-Process -FilePath "mstsc.exe" -ArgumentList $rdpFilePath -PassThru
    return $rdpProcess
}

# Main Execution
$sshProcess = Start-SSHTunnel

# Start the RDP connection if the SSH tunnel was established
if ($sshProcess) {
    $rdpProcess = Start-RDPConnection
    if ($rdpProcess) {
        # Wait for the RDP process to exit
        Wait-Process -Id $rdpProcess.Id
        # Close the SSH tunnel process
        Stop-Process -Id $sshProcess.Id
        Write-Host "SSH tunnel closed."
        exit
    }
}

# Close the terminal
exit