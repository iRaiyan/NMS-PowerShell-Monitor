# 🌐 NMS PowerShell Monitoring System
# 🌐 NMS PowerShell Monitoring System

<p align="center">
  <img src="nms-dashboard.png" alt="NMS PowerShell Monitoring Dashboard" width="900">
</p>

<p align="center">
  🚀 Monitor • Detect • Notify • Keep Your Network Online
</p>

<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white" alt="PowerShell 5.1+">
  <img src="https://img.shields.io/badge/Platform-Windows-blue?logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/Monitoring-Network-green" alt="Network Monitoring">
  <img src="https://img.shields.io/badge/Status-Active-success" alt="Project Status">
</p>

<p align="center">
  <b>🚀 Monitor • Detect • Notify • Keep Your Network Online</b>
</p>

---

## 📌 Project Overview

The **NMS PowerShell Monitoring System** is a network monitoring project developed using Windows PowerShell.

It monitors network devices by checking their connectivity through ping. When a device goes down or comes back online, the system can send email notifications and record monitoring events in a CSV log file.

🎯 **Main Goal:** To simplify network monitoring and quickly identify device connectivity problems.

---

## 📁 Project Files

| 📄 File Name | 📝 Description |
|---|---|
| `Monitor-Devices.ps1` | PowerShell script for monitoring network devices |
| `devices.csv` | Configuration file containing device details |
| `NMS-Log.csv` | Log file for monitoring events, if configured by the script |
| `README.md` | Project documentation |

---

## ✨ Key Features

- 🖥️ **Multiple Device Monitoring** — Monitor multiple network devices.
- 📡 **Ping Monitoring** — Check device connectivity using ping.
- 🔴 **Device Down Detection** — Identify devices that become unreachable.
- 🟢 **Device Recovery Detection** — Detect when a device becomes reachable again.
- 📧 **Email Notifications** — Send alerts for device down and recovery events.
- 📊 **CSV Logging** — Record monitoring events in a CSV file.
- 🕒 **IST Timestamps** — Use India Standard Time for internal timestamps.
- ⚙️ **Configurable Devices** — Manage device information through a CSV file.

---

## 🛠️ Requirements

Make sure you have the following:

- 💻 Windows computer.
- ⚡ Windows PowerShell 5.1 or later.
- 🌐 Network connectivity to the monitored devices.
- 📧 Valid SMTP email configuration.
- 📂 A correctly configured `devices.csv` file.

---

## ⚙️ Configuration

The `devices.csv` file should contain these four columns:

```csv
DeviceNumber,DeviceName,IPAddress,AlertEmail
```

### 📋 Example CSV Configuration

The following example uses placeholder device and email information:

```csv
DeviceNumber,DeviceName,IPAddress,AlertEmail
1,pc1,192.168.1.101,alerts@example.com
2,pc2,192.168.1.102,alerts@example.com
```

📝 **Important:** Replace the example values with the correct device details and authorized alert email addresses for your environment.

---

## 🔐 Security Guidelines

Protect your project and email credentials.

- 🔒 Never upload Gmail App Passwords or SMTP passwords.
- 🛡️ Do not commit credential files containing saved passwords.
- 📧 Use placeholder email addresses in public examples.
- 🌐 Avoid exposing sensitive network information in public repositories.
- 🔑 Store credentials securely outside the repository.
- ⚠️ If a password has already been uploaded, revoke it and check the repository's Git history.

**Best Practice:** A private GitHub repository does not replace secure credential storage.

---

## 🚀 How to Run the Project

### Step 1️⃣ — Configure Devices

Update the `devices.csv` file with your authorized device information.

### Step 2️⃣ — Configure SMTP

Configure SMTP settings and credentials securely. Never put your Gmail App Password directly in a public script.

### Step 3️⃣ — Run PowerShell

Open Windows PowerShell and run the monitoring script using the appropriate file path.

Example:

```powershell
cd D:\NMS
.\Monitor-Devices.ps1
```

### Step 4️⃣ — Check Monitoring Logs

Review `NMS-Log.csv` if your script is configured to create this log file.

### Step 5️⃣ — Verify Email Alerts

Test the email configuration and confirm that device down and recovery notifications work as expected.

---

## 📈 Expected Monitoring Workflow

```text
       🖥️ Network Devices
               |
               v
       📡 Ping Connectivity
               |
               v
      🔍 Check Device Status
               |
        +------+------+
        |             |
        v             v
   🔴 Device Down  🟢 Device Up
        |             |
        v             v
   📧 Down Alert   📧 Up Alert
        |             |
        +------+------+
               |
               v
        📊 CSV Logging
```

*Note: The actual workflow depends on the monitoring logic implemented in the PowerShell script.*

---

## 🎓 Learning Objectives

This project helps develop practical knowledge of:

- 💻 Windows PowerShell scripting.
- 🌐 Basic network monitoring.
- 📡 IP addresses and ping connectivity.
- 📧 SMTP email configuration.
- 📊 CSV file handling.
- 🔐 Secure credential management.
- 🛠️ Troubleshooting network connectivity.

---

## ⚠️ Disclaimer

This project is intended for **educational purposes and authorized network monitoring only**.

Use it only on devices and networks you own or have permission to monitor.

---

<p align="center">
  <b>💡 Learn • Build • Monitor • Improve</b>
</p>

<p align="center">
  ⭐ NMS PowerShell Monitoring System ⭐
</p>
