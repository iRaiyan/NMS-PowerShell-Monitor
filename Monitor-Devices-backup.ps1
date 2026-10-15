
param(
    [switch]$TestEmail
)

# NMS Network Monitoring System
# Compatible with Windows PowerShell 5.1

$ErrorActionPreference = "Stop"

# Configuration
$BasePath = "D:\NMS"
$DeviceCsv = Join-Path $BasePath "Devices.csv"
$LogFile = Join-Path $BasePath "NMS-Log.csv"
$CredentialFile = Join-Path $BasePath "smtp-credential.xml"

# Gmail SMTP
$SmtpServer = "smtp.gmail.com"
$SmtpPort = 587
$SmtpUser = "sunasararaiyan20@gmail.com"

# Monitoring settings
$IntervalSeconds = 10
$FailureThreshold = 4
$PingTimeoutMs = 2000

# Indian Standard Time
$IstZone = [TimeZoneInfo]::FindSystemTimeZoneById(
    "India Standard Time"
)

function Get-IstTime {
    return [TimeZoneInfo]::ConvertTime(
        [DateTimeOffset]::Now,
        $IstZone
    )
}

function Write-NmsLog {
    param(
        [string]$DeviceNumber,
        [string]$DeviceName,
        [string]$IPAddress,
        [string]$Event,
        [string]$Details
    )

    $entry = [PSCustomObject]@{
        TimestampIST = (Get-IstTime).ToString(
            "yyyy-MM-dd HH:mm:ss zzz"
        )
        DeviceNumber = $DeviceNumber
        DeviceName = $DeviceName
        IPAddress = $IPAddress
        Event = $Event
        Details = $Details
    }

    if (Test-Path -LiteralPath $LogFile) {
        $entry | Export-Csv -LiteralPath $LogFile `
            -NoTypeInformation -Append -Encoding UTF8
    }
    else {
        $entry | Export-Csv -LiteralPath $LogFile `
            -NoTypeInformation -Encoding UTF8
    }
}

function Send-NmsEmail {
    param(
        [string]$Recipient,
        [string]$Subject,
        [string]$Body
    )

    if (-not (Test-Path -LiteralPath $CredentialFile)) {
        throw "SMTP credential file not found: $CredentialFile"
    }

    $credential = Import-Clixml -LiteralPath $CredentialFile
    $message = New-Object System.Net.Mail.MailMessage
    $smtp = $null

    try {
        $message.From = New-Object System.Net.Mail.MailAddress(
            $SmtpUser
        )
        $message.To.Add($Recipient)
        $message.Subject = $Subject
        $message.Body = $Body
        $message.IsBodyHtml = $false

        $smtp = New-Object System.Net.Mail.SmtpClient(
            $SmtpServer, $SmtpPort
        )
        $smtp.EnableSsl = $true