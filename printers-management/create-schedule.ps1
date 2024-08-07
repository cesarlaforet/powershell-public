## // /////////////////////////////////
## // by: Cesar Laforet Coelho
## // at: 2024-08-06
## // 
## // version: 1.1
## // 
## // this script creates a task schedule
## // that run the script ($scriptName) every 60 minutes
## // and it must be located in the same folder
## // /////////////////////////////////

$taskName = "queue-cleanup"
$taskPath = "\"
$scriptName = "queue-cleanup.ps1"
$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if the task schedule already exists
$existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue

if ($null -eq $existingTask) {
    # Create a new task schedule
    $action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$currentPath\$scriptName`""
    $trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 60) -At (Get-Date).AddMinutes(1)

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Action $action -Trigger $trigger -User $currentUser
    Write-Host "Task schedule created successfully."
} else {
    Write-Host "Task schedule already exists."
}

# End of script
