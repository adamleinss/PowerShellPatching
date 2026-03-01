# Import the PSWindowsUpdate module from your specific location
Import-Module -Name "C:\cron\PSWindowsUpdate" -Force

# Get the last 10 updates from Get-WUHistory
$updates = Get-WUHistory -Last 10 | Sort-Object Date  # Sort ascending so latest is last

# Create HTML body for the email with a table
$htmlBody = @"
<html>
<head>
<style>
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid black; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
</style>
</head>
<body>
<h2>Recent Updates Report - $(Get-Date)</h2>
<table>
<tr>
    <th>KB Number</th>
    <th>Description</th>
    <th>Date</th>
    <th>Operation</th>
</tr>
"@

# Process each update
foreach ($update in $updates) {
    $kbNumber = if ($update.KB) { $update.KB } else { "N/A" }
    $description = if ($update.Title) { $update.Title } else { "No description available" }
    $date = if ($update.Date) { $update.Date } else { "N/A" }
    $operation = if ($update.Operation) { $update.Operation } else { "N/A" }
    
    $htmlBody += @"
<tr>
    <td>$kbNumber</td>
    <td>$description</td>
    <td>$date</td>
    <td>$operation</td>
</tr>
"@
}

# Close HTML
$htmlBody += @"
</table>
</body>
</html>
"@

# Email parameters
$emailParams = @{
    SmtpServer = '127.0.0.1'
    From       = 'vm-dw-dev@acme.com'  # Replace with appropriate sender address
    To         = 'bob@acme.com'
    Subject    = "Recent Updates Report - VM-DW-DEV"
    Body       = $htmlBody
    BodyAsHtml = $true
}

# Send the email
try {
    Send-MailMessage @emailParams
    Write-Host "Email sent successfully!"
}
catch {
    Write-Host "Failed to send email: $_"
}