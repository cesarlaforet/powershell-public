# Generate Encrypted RDP Password

This command `("MySuperSecretPassword" | ConvertTo-SecureString -AsPlainText -Force) | ConvertFrom-SecureString` allows you to generate an encrypted version of a password in PowerShell.

To add the encrypted password to an .rdp file and save the userpass, follow these steps:

1. Open the .rdp file in a text editor.
2. Locate the line that starts with `password 51:b` or add it.
3. Replace the existing encrypted password after `password 51:b` with the generated encrypted password.
4. Example: `password 51:b:MyEncryptedPassword`
5. Save the .rdp file.

Now, when you open the .rdp file, it will automatically use the encrypted password for authentication.
