set execution-policy bypass
$ErrorActionPreference = 'SilentlyContinue'

. "$PSScriptRoot\Get-PendingRebootStatus.ps1"
$servers = gc D:\cron\patchadams\servers.txt

foreach ($server in $servers) {

$result = Get-PendingRebootStatus -ComputerName $server

if ($result.pendingreboot -match "True")

  { write-output "Restarting" $server
    Restart-Computer -ComputerName $server -force
  } #end if

} #end for
