Stop-Transcript | out-null
Start-Transcript -path D:\cron\patchadams\patchuptimereport.txt

$servers = get-content D:\cron\patchadams\servers.txt

foreach ($server in $servers) {

if (test-path \\$server\c$ -ErrorAction SilentlyContinue) { 
Write-Output $server
(Get-Date) - (Get-CimInstance Win32_OperatingSystem -ComputerName $server -ErrorAction SilentlyContinue).LastBootupTime
}
}

$patchuptimereport = get-content D:\CRON\PatchAdams\patchuptimereport.txt -Raw

Send-MailMessage -From 'uptimereport@acme.com' -To 'bob@acme.com' -Subject 'ACME Servers Patching this Weekend Uptime Report' -Body "
$patchuptimereport" -SmtpServer '127.0.0.1'