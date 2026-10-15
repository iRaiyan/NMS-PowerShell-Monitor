
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
        $smtp.Credentials = $credential.GetNetworkCredential()
        $smtp.Timeout = 15000

        $smtp.Send($message)
    }
    finally {
        $message.Dispose()

        if ($null -ne $smtp) {
            $smtp.Dispose()
        }
    }
}

# Check configuration files
if (-not (Test-Path -LiteralPath $BasePath)) {
    throw "Folder not found: $BasePath"
}

if (-not (Test-Path -LiteralPath $DeviceCsv)) {
    throw "Device CSV not found: $DeviceCsv"
}

if (-not (Test-Path -LiteralPath $CredentialFile)) {
    throw "SMTP credential file not found: $CredentialFile"
}

# Load devices
$devices = @(Import-Csv -LiteralPath $DeviceCsv)

if ($devices.Count -eq 0) {
    throw "No devices found in the CSV file."
}

$requiredColumns = @(
    "DeviceNumber",
    "DeviceName",
    "IPAddress",
    "AlertEmail"
)

foreach ($column in $requiredColumns) {
    if ($devices[0].PSObject.Properties.Name -notcontains $column) {
        throw "Required CSV column is missing: $column"
    }
}

foreach ($device in $devices) {
    foreach ($column in $requiredColumns) {
        if ([string]::IsNullOrWhiteSpace($device.$column)) {
            throw "Missing $column in a device CSV row."
        }
    }
}

# Test email mode
if ($TestEmail) {
    $firstDevice = $devices[0]

    $testBody = @"
Hello Team,

This is a test email from the NMS monitoring system.

Device Name: $($firstDevice.DeviceName)
Device IP: $($firstDevice.IPAddress)
Test Time: $((Get-IstTime).ToString("HH:mm:ss"))

If you received this email, SMTP testing succeeded.
"@

    Send-NmsEmail `
        -Recipient $firstDevice.AlertEmail `
        -Subject "NMS Test Email - $($firstDevice.DeviceName)" `
        -Body $testBody

    Write-Host "Test email sent successfully."
    exit 0
}

# Keep state for each monitored device
$state = @{}

foreach ($device in $devices) {
    $state[$device.DeviceNumber] = @{
        Failures = 0
        IsDown = $false
        FirstFailure = $null
        DownSince = $null
    }
}

Write-Host "NMS monitoring started."
Write-Host "Device count: $($devices.Count)"
Write-Host "Ping interval: $IntervalSeconds seconds"
Write-Host "Failure threshold: $FailureThreshold"
Write-Host "Log file: $LogFile"
Write-Host "Press Ctrl+C to stop."

while ($true) {
    $cycleWatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        $devices = @(Import-Csv -LiteralPath $DeviceCsv)
    }
    catch {
        Write-Warning "CSV read failed: $($_.Exception.Message)"
        Start-Sleep -Seconds $IntervalSeconds
        continue
    }

    foreach ($device in $devices) {
        $id = $device.DeviceNumber

        if ([string]::IsNullOrWhiteSpace($id) -or
            [string]::IsNullOrWhiteSpace($device.IPAddress) -or
            [string]::IsNullOrWhiteSpace($device.AlertEmail)) {
            Write-Warning "Skipping a row with missing values."
            continue
        }

        if (-not $state.ContainsKey($id)) {
            $state[$id] = @{
                Failures = 0
                IsDown = $false
                FirstFailure = $null
                DownSince = $null
            }
        }

        $s = $state[$id]
        $ping = $false

        # One ping check
        try {
            $pingOutput = & "$env:SystemRoot\System32\ping.exe" `
                -n 1 -w $PingTimeoutMs $device.IPAddress 2>$null

            $ping = ($LASTEXITCODE -eq 0)
        }
        catch {
            $ping = $false
        }

        if ($ping) {
            Write-Host "[$((Get-IstTime).ToString('HH:mm:ss'))] UP $($device.DeviceName) $($device.IPAddress)"

            if ($s.IsDown) {
                $recoveryTime = Get-IstTime
                $duration = $recoveryTime - $s.DownSince

                $durationText = "{0}d {1:00}:{2:00}:{3:00}" -f `
                    $duration.Days, $duration.Hours, `
                    $duration.Minutes, $duration.Seconds

                $upBody = @"
Hello Team,

The following device has re-established its connection.

Device Name: $($device.DeviceName)
Device IP: $($device.IPAddress)
Device Recovery Time: $($recoveryTime.ToString("HH:mm:ss"))
Total Downtime: $durationText
"@

                try {
                    Send-NmsEmail `
                        -Recipient $device.AlertEmail `
                        -Subject "Device Up - $($device.DeviceName)" `
                        -Body $upBody

                    Write-NmsLog $id $device.DeviceName `
                        $device.IPAddress "UP" `
                        "Recovered; downtime: $durationText"

                    Write-Host "Recovery email sent."
                }
                catch {
                    Write-Warning "Recovery email failed: $($_.Exception.Message)"

                    Write-NmsLog $id $device.DeviceName `
                        $device.IPAddress "EMAIL_ERROR" `
                        $_.Exception.Message
                }

                $s.IsDown = $false
                $s.DownSince = $null
                $s.FirstFailure = $null
                $s.Failures = 0
            }
            else {
                $s.Failures = 0
                $s.FirstFailure = $null
            }
        }
        else {
            Write-Host "[$((Get-IstTime).ToString('HH:mm:ss'))] DOWN? $($device.DeviceName) $($device.IPAddress)"

            if ($null -eq $s.FirstFailure) {
                $s.FirstFailure = Get-IstTime
            }

            $s.Failures++

            if (($s.Failures -ge $FailureThreshold) -and
                (-not $s.IsDown)) {

                $s.IsDown = $true
                $s.DownSince = $s.FirstFailure

                $downBody = @"
Hello Team,

The following device has lost its connection.

Device Name: $($device.DeviceName)
Device IP: $($device.IPAddress)
Device Shutdown Time: $($s.DownSince.ToString("HH:mm:ss"))

"@

                try {
                    Send-NmsEmail `
                        -Recipient $device.AlertEmail `
                        -Subject "Device Down - $($device.DeviceName)" `
                        -Body $downBody

                    Write-NmsLog $id $device.DeviceName `
                        $device.IPAddress "DOWN" `
                        "Down detected after $($s.Failures) consecutive failures"

                    Write-Host "Down alert email sent."
                }
                catch {
                    Write-Warning "Down email failed: $($_.Exception.Message)"

                    Write-NmsLog $id $device.DeviceName `
                        $device.IPAddress "EMAIL_ERROR" `
                        $_.Exception.Message
                }
            }
        }
    }

    $cycleWatch.Stop()
    $remaining = $IntervalSeconds - $cycleWatch.Elapsed.TotalSeconds

    if ($remaining -gt 0) {
        Start-Sleep -Milliseconds ([int]($remaining * 1000))
    }
}
