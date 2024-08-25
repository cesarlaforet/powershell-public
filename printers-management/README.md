# Project Documentation

## Scripts Overview

This project contains three main PowerShell scripts:

1. **check-printer.ps1**
2. **queue-cleanup.ps1**
3. **create-schedule.ps1**


### check-printer.ps1

**Description:**
this script checks if -PrinterName exists if it's missing creates it.
is you wish to set the printer to paused apon creation uncomment lines 51 and 52.

**Example:**
```powershell
.\check-printer.ps1 -PrinterName "Printer1"
```

**Parameters:**
-PrinterName (mandatory): Specify the name of the printer to check.

### queue-cleanup.ps1

**Description:**
this script cancels/deletes all pending jobs of the specified printer -PrinterName.

**Example:**
```powershell
.\queue-cleanup.ps1 -PrinterName "Printer1"
```

**Parameters:**
-PrinterName (mandatory): Specify the name of the printer to clean queue.

### create-schedule.ps1

**Description:**
this script creates a task schedule that run the script (-scriptName) every 60 minutes and it must be located in the same folder.

**Example:**
```powershell
.\create-schedule.ps1 -taskName "queue-cleanup" -scriptName "queue-cleanup.ps1"
```

**Parameters:**
-taskName (optional): Specify the name of the task that will be created.
-scriptName (optional): Specify the name of the task to run, that must be in the same folder as this script.



Additional Information
For more details on each script, please refer to the inline comments within the scripts or contact the project maintainer.

