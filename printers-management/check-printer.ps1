## // /////////////////////////////////
## // by: Cesar Laforet Coelho
## // at: 2024-08-06
## //
## // version: 1.2
## //
## // this script checks if DUMMY-PRINTER exists
## // is it's missing creates it.
## // is you wish to set the printer to paused
## // apon creation uncomment lines 51 and 52 
## // /////////////////////////////////

function Request-Printer {
    param (
        [Parameter(Mandatory=$false)]
        [string]$PrinterName = "DUMMY-PRINTER"
    )

    $printer_name = $PrinterName
    $default_printer = (Get-WmiObject -Class Win32_Printer | Where-Object {$_.Default -eq $true}).Name
    Write-Host "$default_printer is the current default printer"

    # Check if the printer exists
    $printer_exists = $false
    foreach ($printer in (Get-WmiObject -Class Win32_Printer)) {
        if ($printer.Name -eq $printer_name) {
            $printer_exists = $true
            Write-Host "$printer_name already exists"
            break
        }
    }

    if ($printer_exists) {
        # Check if the printer is the default printer
        if ($default_printer -ne $printer_name) {
            # Set the printer as the default printer
            $WshNetwork = New-Object -ComObject WScript.Network
            $WshNetwork.SetDefaultPrinter($printer_name)
            Write-Host "$($printer.Name) set as the default printer"

        }
        else {
            Write-Host "$printer_name is already the default printer."
        }
    }
    else {
        # Add the printer
        $desiredDriver = "Microsoft PCL6 Class Driver"
        $fallbackDriver = "Microsoft Print to PDF"
        $availableDrivers = Get-PrinterDriver | Select-Object -ExpandProperty Name
        $driverToUse = $null
        if ($availableDrivers -contains $desiredDriver) {
            $driverToUse = $desiredDriver
        } elseif ($availableDrivers -contains $fallbackDriver) {
            Write-Host "Warning: '$desiredDriver' not found. Using '$fallbackDriver' instead."
            $driverToUse = $fallbackDriver
        } else {
            Write-Host "Error: Neither '$desiredDriver' nor '$fallbackDriver' printer drivers are available. Please install a suitable printer driver."
            return
        }

        $portName = "nul:"
        # Check if the port exists, if not, create it
        $portExists = Get-PrinterPort | Where-Object { $_.Name -eq $portName }
        if (-not $portExists) {
            try {
                Add-PrinterPort -Name $portName
                Write-Host "Created printer port: $portName"
            } catch {
                Write-Host "Failed to create printer port: $portName. Error: $_"
                return
            }
        }

        $printer_info = @{
            "Name" = $printer_name
            "PortName" = $portName
            "DriverName" = $driverToUse
        }

        Add-Printer -Name $printer_info.Name -DriverName $printer_info.DriverName -PortName $printer_info.PortName

        # $query = "Select * From Win32_Printer Where Name = '$($printer_info.Name)'"
        # Invoke-CimMethod -Query $query -Namespace Root/CIMV2 -MethodName Pause

        $WshNetwork = New-Object -ComObject WScript.Network
        $WshNetwork.SetDefaultPrinter($printer_info.Name)
        Write-Host "$($printer_info.Name) set as the default printer"
    }
}

Request-Printer