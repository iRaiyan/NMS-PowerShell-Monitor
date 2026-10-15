# NMS-PowerShell-Monitor
Network Monitoring System using PowerShell
# NMS PowerShell Monitoring System

## Project Overview
This project monitors network devices using Windows PowerShell. It checks device connectivity and sends email notifications when a device goes down or comes back online.

## Project Files
- `Monitor-Devices.ps1` — PowerShell monitoring script.
- `devices.csv` — Device configuration file.

## Features
- Monitors multiple network devices.
- Checks connectivity using ping.
- Detects device downtime and recovery.
- Sends email notifications for device down and up events.
- Logs monitoring events to a CSV log file.
- Uses India Standard Time (IST) for internal timestamps.

## Requirements
- Windows computer.
- Windows PowerShell 5.1 or later.
- Network connectivity to the monitored devices.
- SMTP email configuration.

## Configuration
The `devices.csv` file should contain these columns:

`DeviceNumber,DeviceName,IPAddress,AlertEmail`

Example using placeholder information:

```csv
DeviceNumber,DeviceName,IPAddress,AlertEmail
1	pc3	192.168.1.12	sunasararaiyan20@gmail.com,bhavesh@skillsync.co.in
2	pc2	192.168.1.16	sunasararaiyan20@gmail.com,bhavesh@skillsync.co.in
3	pc8	192.168.1.15	sunasararaiyan20@gmail.com,bhavesh@skillsync.co.in
4	pc7	192.168.1.10	sunasararaiyan20@gmail.com,bhavesh@skillsync.co.in
<img width="865" height="146" alt="image" src="https://github.com/user-attachments/assets/71daf253-9d72-4a62-b6fe-e17a123c30a8" />
```

Replace the example values with your own authorized device information.

## Security
- Never upload Gmail App Passwords or other secrets.
- Do not upload credential files containing passwords.
- Use placeholders for private IP addresses and email addresses in public examples.
- Store credentials securely outside the repository.

## Usage
1. Configure `devices.csv`.
2. Configure SMTP credentials securely.
3. Run `Monitor-Devices.ps1` using Windows PowerShell.
4. Check the generated log file for monitoring events.

## Disclaimer
This project is intended for authorized network monitoring and educational use.
