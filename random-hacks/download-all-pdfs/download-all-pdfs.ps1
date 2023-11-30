# URL of the web page containing PDF links
$url = "https://<domain>/<html page>.html"

# Extract the base URL from the provided URL
$uri = [System.Uri]$url
$baseUrl = $uri.GetLeftPart([System.UriPartial]::Authority)

# Path where you want to save the downloaded PDFs
$savePath = "C:\temp\"

# Create the directory if it doesn't exist
if (!(Test-Path -Path $savePath)) {
    New-Item -ItemType Directory -Path $savePath
}

# Download the web page content
$response = Invoke-WebRequest -Uri $url
$html = $response.Content

# Load the HTML content using HTML Agility Pack
$scriptDirectory = $PSScriptRoot
Add-Type -Path "$scriptDirectory\HtmlAgilityPack.dll"  # Load HTML Agility Pack library (download from NuGet)

# Create an HTML Agility Pack document
$doc = New-Object HtmlAgilityPack.HtmlDocument
$doc.LoadHtml($html)

# Extract PDF links from anchor tags
$links = $doc.DocumentNode.SelectNodes("//a[@href]")
foreach ($link in $links) {
    $relativeUrl = [System.Web.HttpUtility]::HtmlDecode($link.GetAttributeValue("href", ""))
    
    # Check if the link ends with ".pdf" to filter out PDF links
    if ($relativeUrl -like "*.pdf") {
        # Combine the base URL with the relative URL to get the absolute URL
        $baseUrlRewrite = [System.Uri]::new($baseUrl)
        $pdfUrl = [System.Uri]::new($baseUrlRewrite, $relativeUrl)
        
        # Decode the URL-encoded filename to get the correct filename
        $pdfFileName = [System.Net.WebUtility]::UrlDecode([System.IO.Path]::GetFileName($pdfUrl.AbsoluteUri))
        $pdfFilePath = Join-Path -Path $savePath -ChildPath $pdfFileName

        Write-Host "Downloading $pdfFileName..."
        Invoke-WebRequest -Uri $pdfUrl.AbsoluteUri -OutFile $pdfFilePath
        Write-Host "$pdfFileName downloaded to $pdfFilePath"
    }
}
