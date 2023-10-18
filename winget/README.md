# Windows App Backup & Restore

This repository contains scripts to backup installed Windows apps using `winget` and restore them.

## Backup

The `run_backup_installed.ps1` script creates a backup of installed apps in the form of a JSON file. The file naming convention used is:

\`\`\`
${date}.${formattedCounter}_${machineName}_InstalledApps.json
\`\`\`

Where:
- `${date}` is the current date in the format `yyyy-MM-dd`.
- `${formattedCounter}` is a two-digit number starting from `00` and incrementing if a file with the same name already exists.
- `${machineName}` is the name of the machine on which the script is executed.

To create a backup:

1. Run the `run_backup_installed.ps1` script in PowerShell.
2. The script will generate a JSON file with the aforementioned nomenclature.

## Restore

To restore apps from the created backup:

1. Drag and drop your backup JSON file onto the `wingetImport.bat` file. 
2. The batch file will invoke the `wingetImport.ps1` PowerShell script, which will then run the `winget import` command using the path of the dropped file.

Ensure that you have `winget` installed and properly configured on your machine for the scripts to work.

## Managing Packages with `ManagePackages`

The `ManagePackages.ps1` script provides a GUI to manage the packages listed in a `${date}.${formattedCounter}_${machineName}_InstalledApps.json` file. When executed, it displays all the packages from the given JSON file and allows you to select or deselect packages based on your preference. 

### Usage:

1. Drag and drop your `${date}.${formattedCounter}_${machineName}_InstalledApps.json` file onto the `ManagePackages.bat` file.
2. A GUI window will appear listing all the packages with their source (e.g., `msstore` or `winget`) in a second column.
3. Select or deselect packages as needed.
4. Click on the "Select All" or "Deselect All" buttons to quickly select or deselect all packages respectively.
5. Once you've made your selections, click the "Update" button.
6. The script will then generate a new JSON file with the `_SelectedOnly` suffix, containing only the packages you've selected.

Please note that the original file will remain unchanged. The new file serves as a filtered version based on your selections.

Ensure that both `ManagePackages.ps1` and `ManagePackages.bat` are in the same directory for this functionality to work properly.
