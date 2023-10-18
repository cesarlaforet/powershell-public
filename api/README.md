# PowerShell HTTP Listener

This PowerShell script creates a basic HTTP listener on port 8000. It listens for incoming requests, processes them based on their paths, and returns relevant responses.

## How it Works

1. **Starting the Listener**: The script begins by creating an HTTP listener on port 8000.

2. **Listening for Requests**: The listener waits for incoming HTTP requests. When a request is received, it processes the request based on the specified path.

3. **Routes**:
   - `/end`: A GET request to this endpoint will terminate the listener.
   - `/wmi`: This route expects two additional segments in the URL representing a WMI class name and a computer/server name. For instance, a request to `http://localhost:8000/wmi/Win32_ComputerSystem/localhost` will query the `Win32_ComputerSystem` WMI class on the `localhost` server. The result is then returned in JSON format.
   
   If no matching route is found, a 404 message "This is not the page you're looking for." is returned.

4. **Terminating the Listener**: The listener continues to run and process requests until a request is sent to the `/end` route. After this, the listener is stopped.

## Usage

1. Run the script in PowerShell.
2. Send HTTP requests to `http://localhost:8000/` followed by the desired route (e.g., `/wmi/Win32_ComputerSystem/localhost`).
3. To stop the listener, send a GET request to `http://localhost:8000/end`.

## Requirements

- PowerShell
- Required permissions to run an HTTP listener on port 8000.
- Permissions to query WMI objects if using the `/wmi` route.

## Note

This script is a simple demonstration of an HTTP listener in PowerShell. It's recommended to use it in controlled environments and not expose it to untrusted networks.
