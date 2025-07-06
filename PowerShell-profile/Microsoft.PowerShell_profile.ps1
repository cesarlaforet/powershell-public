# . $env:USERPROFILE\.config\powershell\user_profile.ps1

# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# ------ Set Main Variables ------
$setupDir = "$env:USERPROFILE\OneDrive\Documentos\PowerShell\"
$deployedFile = Join-Path $setupDir "ProfileSetup.deployed"
$failedFile = Join-Path $setupDir "ProfileSetup.failed"
$promptConfigName = "jblab_2021.omp.json" # Get more themes at https://ohmyposh.dev/docs/themes
$promptConfigPath = Join-Path $setupDir $promptConfigName
# ------ End of Set Main Variables ------

# ------ FUNCTION DEFINITIONS ------

  # Utility Functions
  function Test-CommandExists {#Utility:Test if a command exists
    param($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
  }
  function touch($file) {#Utility:Create or update a file's timestamp
    "" | Out-File $file -Encoding ASCII 
  }
  function ff($name) {#Utility:Find files by name
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.directory)\$($_)"
    }
  }

  # Network Utilities
  function Get-PublicIP {#Network:Get public IP address
    (Invoke-WebRequest http://ifconfig.me/ip).Content 
  }
  function flushdns {#Network:Flush DNS cache
    Clear-DnsClientCache 
  }

  # System Utilities
  function uptime {#System:Get system uptime
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
  }

  # Enhanced Listing
  function la {#Listing:List all files and directories (including hidden ones)
    Get-ChildItem -Path . -Force | Format-Table -AutoSize 
  }
  function ll {#Listing:List only hidden files and directories
    Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize 
  }

  # Quick Access to System Information
  function sysinfo {#QuickAccess:Shows system information
    Get-ComputerInfo }
  # Quick Access to Environment Variables
  function env {#QuickAccess:Shows environment variables
    Get-ChildItem Env: | Format-Table -AutoSize }
  # Quick Access to System Processes
  function ps {#QuickAccess:Shows running processes
    Get-Process | Format-Table -AutoSize }
  # Quick Access to System Services
  function services {#QuickAccess:Shows system services
    Get-Service | Format-Table -AutoSize }
  # Quick Access to System Event Logs
  function events {#QuickAccess:Shows recent event logs
    Get-EventLog -LogName Application -Newest 10 | Format-Table -AutoSize }
  # Quick Access to System Users
  function users {#QuickAccess:Shows local users
    Get-LocalUser | Format-Table -AutoSize }

# ------ END OF FUNCTION DEFINITIONS ------



# One-time setup section
if (!(Test-Path $deployedFile) -and !(Test-Path $failedFile)) {
    try {
        # --- BEGIN ONE-TIME SETUP SECTION ---
        Write-Host "--- BEGIN ONE-TIME SETUP SECTION ---" -ForegroundColor Red

        # Check if the Hack font is already installed
        $hackFontInstalled = Get-ChildItem -Path "$env:windir\Fonts" -Filter "Hack*.ttf" -ErrorAction SilentlyContinue
        if ($hackFontInstalled) {
            Write-Host "Hack font is already installed." -ForegroundColor Green
        } else {
            Write-Host "Hack font is not installed. Proceeding with installation..." -ForegroundColor Yellow
            $release = Invoke-RestMethod https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest
            $asset = $release.assets | Where-Object { $_.name -eq "Hack.zip" }
            $hackUrl = $asset.browser_download_url
            if ($hackUrl) {
                $dest = Join-Path $setupDir "Hack.zip"
                Invoke-WebRequest -Uri $hackUrl -OutFile $dest
            } else {
                throw "Hack.zip not found in latest Nerd Fonts release."
            }

            # Unzip the downloaded Hack.zip
            $unzipPath = Join-Path $setupDir "Hack"
            if (-not (Test-Path $unzipPath)) {
                New-Item -ItemType Directory -Path $unzipPath | Out-Null
            }
            Expand-Archive -Path $dest -DestinationPath $unzipPath -Force
            Write-Host "Hack font downloaded and extracted to $unzipPath" -ForegroundColor Green
            
            # Install the Hack font
            $fontFiles = Get-ChildItem -Path $unzipPath -Filter "*.ttf" -Recurse
            foreach ($fontFile in $fontFiles) {
                $fontPath = $fontFile.FullName
                $destination = Join-Path $env:windir "Fonts\$($fontFile.Name)"
                Copy-Item -Path $fontPath -Destination $destination -Force
                Write-Host "Installed font: $($fontFile.Name)" -ForegroundColor Green
            }
          }

        # Set the default font and acrylic settings in Windows Terminal for PowerShell
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        if (Test-Path $settingsPath) {
            $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
            foreach ($profiles in $settings.profiles.list) {
                if ($profiles.name -eq "PowerShell") {
                    # Ensure the 'font' property exists
                    if ($null -eq $profiles.PSObject.Properties['font']) {
                        $profiles | Add-Member -MemberType NoteProperty -Name font -Value (@{})
                    }
                    $profiles.font.face = "Hack Nerd Font Mono"
                    $profiles.opacity = 20
                    $profiles.useAcrylic = $true
                    Write-Host "Set font and acrylic settings for profile: $($profiles.name)" -ForegroundColor Green
                }
            }
            $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
        } else {
            Write-Host "Settings file not found: $settingsPath" -ForegroundColor Yellow
        }

        # Install Oh-My-Posh
        if (-not (Test-CommandExists oh-my-posh)) {
            Write-Host "Installing Oh-My-Posh..." -ForegroundColor Yellow
            Install-Module -Name oh-my-posh -Scope CurrentUser -Force -SkipPublisherCheck
            Write-Host "Oh-My-Posh installed successfully." -ForegroundColor Green
        } else {
            Write-Host "Oh-My-Posh is already installed." -ForegroundColor Green
        }

        # Set up the Oh-My-Posh prompt configuration
        if (-not (Test-Path $promptConfigPath)) {
            Write-Host "Downloading Oh-My-Posh configuration..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/$promptConfigName" -OutFile $promptConfigPath
            Write-Host "Oh-My-Posh configuration downloaded to $promptConfigPath" -ForegroundColor Green
        } else {
            Write-Host "Oh-My-Posh configuration already exists at $promptConfigPath" -ForegroundColor Green
        }

        # Install Chocolatey if not already installed
        if (-not (Test-CommandExists choco)) {
            Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-Host "Chocolatey installed successfully." -ForegroundColor Green
        } else {
            Write-Host "Chocolatey is already installed." -ForegroundColor Green
        }
        
        # Install nano if not already installed
        if (-not (Test-CommandExists nano)) {
            Write-Host "Installing nano..." -ForegroundColor Yellow
            if (Test-CommandExists choco) {
                choco install nano -y
                Write-Host "nano installed successfully." -ForegroundColor Green
            } else {
                Write-Host "Chocolatey is not installed. Please install Chocolatey first." -ForegroundColor Red
            }
        } else {
            Write-Host "nano is already installed." -ForegroundColor Green
        }

        # --- END ONE-TIME SETUP SECTION ---

        # If everything succeeded, create the deployed marker
        Write-Host "--- ONE-TIME SETUP SECTION DONE ---" -ForegroundColor Green
        New-Item -ItemType File -Path $deployedFile -Force | Out-Null
    } catch {
        # On error, write all errors to the failed marker file
        Write-Host "--- ONE-TIME SETUP SECTION FAIL ---" -ForegroundColor Red
        $_ | Out-File $failedFile -Encoding UTF8
    }
}
# End of one-time setup section

function Update-PowerShell {
  # Initial GitHub.com connectivity check with 1 second timeout
  $canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

  if (-not $canConnectToGitHub) {
      Write-Host "Skipping PowerShell update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow

      try {
          Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
          $updateNeeded = $false
          $currentVersion = $PSVersionTable.PSVersion.ToString()
          $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
          $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
          $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
          if ($currentVersion -lt $latestVersion) {
              $updateNeeded = $true
          }

          if ($updateNeeded) {
              Write-Host "Updating PowerShell..." -ForegroundColor Yellow
              winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
              Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
          } else {
              Write-Host "Your PowerShell is up to date." -ForegroundColor Green
          }
      } catch {
          Write-Error "Failed to update PowerShell. Error: $_"
      }
  }
}

# Run the update function only once per session
if (-not $global:PowerShellUpdateChecked) {
    $global:PowerShellUpdateChecked = $true
    Update-PowerShell
}




# List all functions defined in the PowerShell profile
function List-MyFunctions {
    param(
        [string]$Category = ""
    )

    $profilePath = $PROFILE.CurrentUserCurrentHost
    if (-not (Test-Path $profilePath)) {
        Write-Warning "Profile file '$profilePath' does not exist."
        return
    }

    $pattern = '^\s*function\s+([\w-]+)\s*\{\s*#(\w+):(.+)'

    $functions = Select-String -Path $profilePath -Pattern $pattern | ForEach-Object {
        if ($_.Line -match $pattern) {
            [PSCustomObject]@{
                Name        = $matches[1]
                Category    = $matches[2]
                Description = $matches[3].Trim()
            }
        }
    }

    if (-not $functions) {
        Write-Verbose "No functions with category tags found." -Verbose
        return
    }

    if ($Category) {
        $functions | Where-Object { $_.Category -eq $Category } | Select-Object Name, Description
    } else {
        $functions | Format-Table -AutoSize
    }
}




# Edit the PowerShell profile using nano
function Edit-Profile {#QuickAccess:Edit the PowerShell profile using nano
  nano $PROFILE
}

# Initialize Oh-My-Posh with the custom configuration
oh-my-posh --init --shell pwsh --config $promptConfigPath | Invoke-Expression
Write-Host "Oh-My-Posh initialized with '$promptConfigName'." -ForegroundColor Green
Write-Host "Use 'List-MyFunctions' to see all defined functions with categories." -ForegroundColor Cyan
