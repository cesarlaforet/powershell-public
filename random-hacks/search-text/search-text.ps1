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


# Store matches to print after processing
$matches = @()

foreach ($file in $xmlFiles) {
	$processed++
	# Overwrite the previous line with the current processing file
	Write-Host ("`rProcessing [$processed/$totalFiles]: $($file.FullName)        ") -NoNewline -ForegroundColor DarkGray

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
		$matchInfo = "Match found in: $($file.FullName)"
		if ($foundInName) { $matchInfo += "`n  -> In filename" }
		if ($foundInContent) { $matchInfo += "`n  -> In file content" }
		$matches += $matchInfo
	}
}

# Clear the processing line
Write-Host "`r`n" -NoNewline

# Print all matches
if ($matches.Count -eq 0) {
	Write-Host "No matches found." -ForegroundColor Yellow
} else {
	foreach ($m in $matches) {
		Write-Host $m -ForegroundColor Green
	}
}
