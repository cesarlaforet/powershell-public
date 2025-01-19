# RDP Through SSH

This script allows you to establish an RDP connection through an SSH tunnel. It automates the process of creating an SSH tunnel and starting an RDP session.

## Configuration

1. Create a configuration file named `connect-ssh-rdp.cfg` with the following content:
    ```powershell
    $sshServer = "<server_address>"
    $sshPort = "<22XX>"
    $sshUser = "<ssh_user>"
    $rdpUser = "<rdp_user>"
    $localPort = 3399
    ```

2. Update the configuration file with your actual server address, SSH port, SSH user, and RDP user.

## Usage

1. Run the script:
    ```powershell
    .\connect-ssh-rdp.ps1
    ```

2. The script will check if the configuration file exists and create it if it does not. It will then load the configuration and validate it.

3. The script will check if an SSH tunnel is already running on the specified local port. If not, it will start the SSH tunnel.

4. Once the SSH tunnel is established, the script will start an RDP connection using the specified RDP user.

5. After the RDP session ends, the script will close the SSH tunnel.

## Notes

- Ensure that you have the necessary permissions to run PowerShell scripts and establish SSH and RDP connections.
- The script assumes that `ssh` and `mstsc` (Remote Desktop Connection) are available on your system.
