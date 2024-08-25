## // /////////////////////////////////
## // by: Cesar Laforet Coelho
## // at: 2024-08-06
## //
## // version: 1.1
## // 
## // this script cancels/deletes all pending jobs
## // of the specified printer ($printerName)
## // /////////////////////////////////

function Remove-PrintJobs {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PrinterName
    )

    $queue = Get-WmiObject -Query "SELECT * FROM Win32_PrintJob WHERE Name LIKE '%$PrinterName%'" -ComputerName localhost

    foreach ($job in $queue) {
        $job = [Wmi]$job.__PATH
        $job.Delete()
    }
}

Remove-PrintJobs -PrinterName "DUMMY-PRINTER"
