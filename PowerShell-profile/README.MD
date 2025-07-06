# PowerShell Profile (`Microsoft.PowerShell_profile.ps1`)

This repository contains a custom PowerShell profile script named `Microsoft.PowerShell_profile.ps1`.

## What is a PowerShell Profile?

A PowerShell profile is a script that runs every time you start a new PowerShell session. It allows you to customize your environment by adding functions, aliases, variables, and importing modules automatically.

## How to Use This Profile

1. **Locate Your PowerShell Profile Path**

   To find your profile path, run this command in PowerShell:
   ```powershell
   $PROFILE
   ```

2. **Copy the Profile Script**

   Copy the `Microsoft.PowerShell_profile.ps1` file from this repository to the path shown by `$PROFILE`. If the file or directory does not exist, create them.

3. **Restart PowerShell**

   Close and reopen your PowerShell terminal to load the new profile.

## What does this profile do?

The profile script includes the following features:

- **Sets PowerShell to UTF-8 encoding** for better Unicode support.
- **Defines useful command aliases and custom functions** for navigation, file management, system info, networking, and more (see `List-MyFunctions` for a categorized list).
- **Configures the prompt appearance** using [Oh-My-Posh](https://ohmyposh.dev/) with a custom theme.
- **Performs one-time setup tasks** such as:
    - Installing the Hack Nerd Font for improved terminal appearance.
    - Setting up Windows Terminal font and acrylic settings for PowerShell.
    - Installing Oh-My-Posh, Chocolatey, and nano if not already present.
    - Downloading the custom Oh-My-Posh prompt configuration.
- **Checks for PowerShell updates** and prompts for upgrade if a newer version is available.
- **Provides quick access functions** for editing the profile, viewing system/environment info, and more.

You can view all available functions and their categories by running:

```powershell
List-MyFunctions
```

## Customization

Feel free to edit `Microsoft.PowerShell_profile.ps1` to suit your workflow and preferences.

## Troubleshooting

If you encounter errors when starting PowerShell, check the profile script for syntax issues or comment out recent changes.

---

