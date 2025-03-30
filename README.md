# Apache_SSL
A Bash script designed for automating the process of installing Apache2 and setting up a self-signed certificate & keys for SSL connection via HTTPS.

The script performs the following operations:
* Checks if Apache2 is already installed. If it is not - the script autoinstalls it.
* Configures Apache2 to launch at startup.
* Enables SSL support.
* Collects user info for the server's certificate.
* Generates SSL keys (private & public).
* Generates a .conf file to be used in the server's certificate.
* Conducts a final test to make sure Apaches's SSL configuration is active.

<b>Full Script Run:</b>

![1](https://github.com/user-attachments/assets/3968476b-ce0a-49bc-93e8-b034467b94d2)

<b>Connection to Apache2 via HTTPS:</b>

![2](https://github.com/user-attachments/assets/4ca44092-2d76-438a-9d54-82c563e19b4f)

<b>Certificate Display:</b>

![3](https://github.com/user-attachments/assets/5c024959-ca87-4292-b5ea-67b2bf728259)
