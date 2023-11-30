# PowerShell SSL/TLS Configuration for API Request

This PowerShell script is designed to make a secure API request to a specified endpoint. It handles SSL/TLS configurations and bypasses certificate validation checks, which can be especially useful in testing or development environments with self-signed certificates.

## Features

1. **Bypassing Certificate Validation**: The script includes a custom certificate policy (`TrustAllCertsPolicy`) that trusts all certificates regardless of their validation status. This can be handy when working with endpoints that have self-signed or expired certificates.

2. **Setting SSL/TLS Protocols**: The script specifies a range of SSL/TLS protocols to be used for the request. This ensures compatibility with various server configurations.

3. **API Request**: The script sends a GET request to `https://api.example.com` with a specified API token in the headers.

## How it Works

1. **TrustAllCertsPolicy Class**: A custom .NET class that implements the `ICertificatePolicy` interface. This class always returns `true` for certificate validation checks, effectively bypassing them.

2. **Setting the Certificate Policy**: The script sets the global certificate validation policy to an instance of `TrustAllCertsPolicy`, ensuring all subsequent web requests in the session bypass certificate validation.

3. **Configuring SSL/TLS Protocols**: The script sets the security protocol to a combination of `Ssl3`, `Tls`, `Tls11`, and `Tls12`. This ensures that the request can negotiate a secure connection with servers configured to use any of these protocols.

4. **Making the API Request**: The script sends a GET request to the specified API endpoint with a header containing an API token. The response is stored in the `$Request` variable.

## Usage

1. Run the script in PowerShell.
2. Upon successful execution, the `$Request` variable will contain the response from the API.

## Warning

By bypassing certificate validation checks, you're trusting all certificates, including potentially untrustworthy ones. This script is intended for testing or development purposes and should not be used in production environments without understanding the security implications.
