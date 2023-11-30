# PowerShell Script to Rename Files with Missing Extensions

This PowerShell script is designed to search for files in a specified directory that are missing file extensions and appends `.jpg` to their names.

## Features

1. **Recursive Search**: The script searches recursively within the specified directory, ensuring it checks all sub-directories for files with missing extensions.
   
2. **Filtering Files**: The script specifically looks for files with missing extensions by using the filter `'*.'`.

3. **Renaming Files**: Each file found with a missing extension is renamed to have a `.jpg` extension.

## How it Works

1. **Fetching List of Files**: Using `Get-ChildItem`, the script fetches a list of all files in the specified `$Path` that are missing extensions.

2. **Iterating Over Each File**: For each file in the list:
   - The script prints the original file name.
   - Constructs a new file name with a `.jpg` extension.
   - Renames the original file to the new name.

## Usage

1. Before running the script, ensure you set the `$Path` variable to the directory you want to search. For example, `$Path = "C:\path\to\directory"`.
2. Run the script in PowerShell.
3. The script will display the original and new names of each file it renames.

## Note

Ensure you have the necessary permissions to rename files in the specified directory. Always test the script on a subset or backup of your data to prevent unintentional renaming or data loss.
