# winget export --output 2023-10-18_InstalledApps_R923.json --accept-source-agreements

# Get current date in 'yyyy-MM-dd' format
$date = Get-Date -Format "yyyy-MM-dd"

# Get machine name
$machineName = $env:COMPUTERNAME

# Initialize a counter for XX
$counter = 0

# Loop to check if the filename exists and if so, increment the counter
do {
    # Format counter to always have two digits, e.g., "00", "01", "02", ...
    $formattedCounter = "{0:D2}" -f $counter

    # Construct the filename
    $filename = "${date}.${formattedCounter}_${machineName}_InstalledApps.json"

    # Increment counter for the next iteration (if needed)
    $counter++
} while (Test-Path $filename)

# Display the filename
Write-Output "This will be the filename: $filename"

# Export the current list of installed apps via winget
winget export --output $filename --accept-source-agreements