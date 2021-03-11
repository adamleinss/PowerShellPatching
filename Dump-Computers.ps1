# Used to dump out patch collections to text files

# Import CM PS modules

import-module (Join-Path $(Split-Path $ENV:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

# Set site code

set-location ABC:
CD ABC:

$serverpilot = Get-CMCollectionMember -CollectionName "_Server Pilot - Auto-patch & Auto-restart" | Select Name | Sort-Object -Property Name | Export-Csv -NoTypeInformation E:\cron\sccm\serverpilot.txt

(Get-Content -Path E:\cron\sccm\serverpilot.txt).Replace('"','') | Set-Content -Path E:\cron\sccm\serverpilot.txt

(Get-Content -Path E:\cron\sccm\serverpilot.txt).Replace('Name','') | Set-Content -Path E:\cron\sccm\serverpilot.txt

(Get-Content -Path E:\cron\sccm\serverpilot.txt) | Select-Object -Skip 1 | Set-Content -Path E:\cron\sccm\serverpilot.txt

$serverplus4 = Get-CMCollectionMember -CollectionName "_All Test/Dev & VM-XXX/DP-XXX Odds/DC Odds - Auto-patch & Auto-restart" | Select Name | Sort-Object -Property Name | Export-Csv -NoTypeInformation E:\cron\sccm\serverplus4.txt

(Get-Content -Path E:\cron\sccm\serverplus4.txt).Replace('"','') | Set-Content -Path E:\cron\sccm\serverplus4.txt

(Get-Content -Path E:\cron\sccm\serverplus4.txt).Replace('Name','') | Set-Content -Path E:\cron\sccm\serverplus4.txt

(Get-Content -Path E:\cron\sccm\serverplus4.txt) | Select-Object -Skip 1 | Set-Content -Path E:\cron\sccm\serverplus4.txt

$serverplus11 = Get-CMCollectionMember -CollectionName "_DC/CM (All) & VM-XXX/DP-XXX Evens - Auto-patch and Auto-restart" | Select Name | Sort-Object -Property Name | Export-Csv -NoTypeInformation E:\cron\sccm\serverplus11.txt

(Get-Content -Path E:\cron\sccm\serverplus11.txt).Replace('"','') | Set-Content -Path E:\cron\sccm\serverplus11.txt

(Get-Content -Path E:\cron\sccm\serverplus11.txt).Replace('Name','') | Set-Content -Path E:\cron\sccm\serverplus11.txt

(Get-Content -Path E:\cron\sccm\serverplus11.txt) | Select-Object -Skip 1 | Set-Content -Path E:\cron\sccm\serverplus11.txt

$serverplus18 = Get-CMCollectionMember -CollectionName "_Production Servers – Auto-Patch & Auto-Restart" | Select Name | Sort-Object -Property Name | Export-Csv -NoTypeInformation E:\cron\sccm\serverplus18.txt

(Get-Content -Path E:\cron\sccm\serverplus18.txt).Replace('"','') | Set-Content -Path E:\cron\sccm\serverplus18.txt

(Get-Content -Path E:\cron\sccm\serverplus18.txt).Replace('Name','') | Set-Content -Path E:\cron\sccm\serverplus18.txt

(Get-Content -Path E:\cron\sccm\serverplus18.txt) | Select-Object -Skip 1 | Set-Content -Path E:\cron\sccm\serverplus18.txt

#$manualserver = Get-CMCollectionMember -CollectionName "_Production Servers – Manual Patching" | Select Name | Sort-Object -Property Name | Export-Csv -NoTypeInformation E:\cron\sccm\manualserver.txt

#(Get-Content -Path E:\cron\sccm\manualserver.txt).Replace('"','') | Set-Content -Path E:\cron\sccm\manualserver.txt

#(Get-Content -Path E:\cron\sccm\manualserver.txt).Replace('Name','') | Set-Content -Path E:\cron\sccm\manualserver.txt

#(Get-Content -Path E:\cron\sccm\manualserver.txt) | Select-Object -Skip 1 | Set-Content -Path E:\cron\sccm\manualserver.txt

Copy-Item -Force -Path "Microsoft.PowerShell.Core\FileSystem::E:\cron\sccm\server*.*" -Destination "Microsoft.PowerShell.Core\FileSystem::\\127.0.0.1\d$\patching"
Copy-Item -Force -Path "Microsoft.PowerShell.Core\FileSystem::E:\cron\sccm\server*.*" -Destination "Microsoft.PowerShell.Core\FileSystem::\\vm-acme-01\d$\CRON\PatchAdams"
Copy-Item -Force -Path "Microsoft.PowerShell.Core\FileSystem::E:\cron\sccm\server*.*" -Destination "Microsoft.PowerShell.Core\FileSystem::\\vm-acme-02\c$\CRON\PatchAdams"
