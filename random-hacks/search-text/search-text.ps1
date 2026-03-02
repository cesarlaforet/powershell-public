# Script to search for a string in XML filenames and contents recursively
# Usage: .\search-text.ps1 -Path "C:\folder" -SearchString "99864244" -MinDate "2024-01-01"

param(
	[Parameter(Mandatory=$true)]
	[string]$Path,
	[Parameter(Mandatory=$true)]
	[string]$SearchString,
	[Parameter(Mandatory=$false)]
	[datetime]$MinDate
)


# Get all XML files recursively, optionally filter by MinDate
if ($MinDate) {
	$xmlFiles = Get-ChildItem -Path $Path -Filter *.xml -Recurse -File | Where-Object { $_.LastWriteTime -ge $MinDate }
} else {
	$xmlFiles = Get-ChildItem -Path $Path -Filter *.xml -Recurse -File
}
$totalFiles = $xmlFiles.Count
$processed = 0

foreach ($file in $xmlFiles) {
	$processed++
	Write-Host ("Processing [$processed/$totalFiles]: " + $file.FullName) -ForegroundColor DarkGray

	$foundInName = $false
	$foundInContent = $false

	# Check if the filename contains the search string
	if ($file.Name -like "*${SearchString}*") {
		$foundInName = $true
	}

	# Check if the file content contains the search string
	$content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
	if ($content -and $content -match [regex]::Escape($SearchString)) {
		$foundInContent = $true
	}

	if ($foundInName -or $foundInContent) {
		Write-Host "Match found in: $($file.FullName)" -ForegroundColor Green
		if ($foundInName) { Write-Host "  -> In filename" -ForegroundColor Yellow }
		if ($foundInContent) { Write-Host "  -> In file content" -ForegroundColor Cyan }
	}
}
