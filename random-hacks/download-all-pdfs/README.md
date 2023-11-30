# PowerShell PDF Downloader

This PowerShell script is designed to download PDF files from a web page. It extracts PDF links from the specified URL, combines them with the base URL, and saves the PDFs to a local directory.

## Usage

1. **Clone or Download**: Clone or download this script to your local machine.

2. **Open PowerShell**: Open a PowerShell terminal.

3. **Navigate to the Script**: Use the `cd` command to navigate to the directory containing the script.

4. **Configure the Script**: Open the script in a text editor and configure the following variables:

   - `$url`: The URL of the web page containing the PDF links.
   - `$savePath`: The local directory where you want to save the downloaded PDFs. If the directory doesn't exist, the script will create it.

5. **Run the Script**: In the PowerShell terminal, execute the script by entering:

   ```powershell
   .\download-pdfs.ps1

6. **Download PDFs (Continued)**: The script will start downloading all the PDF files from the specified web page and save them to the local directory you provided.

7. **Customization**: You can easily customize the script to suit your needs. For example, you can modify the URL to target a different web page or adjust the save path for downloaded PDFs. Make sure to review and modify the script variables as necessary.

8. **Dependencies**: This script uses the HTML Agility Pack library for parsing HTML content. You should download the library and place it in the same directory as the script. You can find the HTML Agility Pack library on NuGet.

**Notes**
The script specifically looks for links with a ".pdf" extension to download.

It decodes URL-encoded filenames to ensure the correct filenames for the downloaded PDFs.

Please ensure that you respect the terms of use of the website you are downloading from and follow all applicable laws and regulations.

This script is intended for personal, educational, or legitimate use cases and should not be used for any malicious purposes.

**License**
This script is provided under the MIT License.

Feel free to contribute or report issues on GitHub.