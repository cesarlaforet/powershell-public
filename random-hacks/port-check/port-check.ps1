# Check if any Java process is listening on ports 33510-33515

$ports = 33510..33515
$found = $false

foreach ($port in $ports) {
    $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($proc -and $proc.ProcessName -like "java*") {
                Write-Output "Java process (PID $($proc.Id)) is listening on port $port"
                $found = $true
            }
        }
    }
}

if (-not $found) {
    Write-Output "No Java process is listening on ports 33510-33515."
}