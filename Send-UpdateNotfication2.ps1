# Used to send out e-mail notifications about servers that are patching

# Find Patch Tuesday (2nd Tuesday of the month)

[DateTime]$date = Get-Date -Format "MM-01-yyyy"
switch ($date.DayOfWeek){            
    "Sunday"    {$patchTuesday = 9}             
    "Monday"    {$patchTuesday = 8}             
    "Tuesday"   {$patchTuesday = 7}             
    "Wednesday" {$patchTuesday = 13}             
    "Thursday"  {$patchTuesday = 12}             
    "Friday"    {$patchTuesday = 11}             
    "Saturday"  {$patchTuesday = 10}             
}

# Import CM PS modules

import-module (Join-Path $(Split-Path $ENV:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)

# Set site code

set-location ABC:
CD ABC:

# Patching Server Pilot – Auto Patch & Auto-Restart / Nightly maintenance window [10PM to 5AM]

# Set the maint window (should match maint window in SCCM)

$patchStart = (Get-Date $date).AddDays($patchTuesday).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)

# Figure out what time it is

$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-1).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

# If it's 24 hours before patching time, set $Sendmail to True, otherwise set to False

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$SendEmail = "True"}else{$SendEmail = "False"}

if ($SendEmail -eq "True") {

# Dump collection members from SCCM collection into text (CSV) format

$serverpilot = Get-CMCollectionMember -CollectionName "_Server Pilot - Auto-patch & Auto-restart" | Select Name | Sort-Object -Property Name | ConvertTo-Csv -NoTypeInformation

# Add break returns <br> for each computer name

ForEach ($_ in $serverpilot) {

$serverpilotbr += "$_ <br>"

}

# Send out e-mail.

Write-host "Sending out e-mail..."

 Send-MailMessage -From 'vm-acme-01@acme.com' -To 'patches@acme.com' -Subject 'Server Pilot Patching' -Body "The following servers will be
 patched and restarted between $PatchStart and $PatchEnd .  Please ignore NAGIOS/PRTG alerts during the maintenance window for these servers.  <br> $serverpilotbr" -SmtpServer '127.0.0.1' -BodyAsHtml
 $SendEmail = "False"
}

# Patching All Test/Dev & VM-XXX/DP-XXX Odds/DC Odds – Auto-Patch & Auto-Restart / +4 days after Patch Tuesday which will be the 2nd or 3rd weekend of the month [Saturday 5PM to Sunday 5PM] – Auto-patch and Auto-restart

$patchStart = (Get-Date $date).AddDays($patchTuesday + 4).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)

$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-1).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$SendEmail = "True"}else{$SendEmail = "False"}

if ($SendEmail -eq "True"){

$serverplus4 = Get-CMCollectionMember -CollectionName "_All Test/Dev & VM-XXX/DP-XXX Odds/DC Odds - Auto-patch & Auto-restart" | Select Name | Sort-Object -Property Name | ConvertTo-Csv -NoTypeInformation

ForEach ($_ in $serverplus4) {

$serverplus4br += "$_ <br>"

}


 Send-MailMessage -From 'vm-acme-01@acme.com' -To 'patches@acme.com' -Subject 'Server Weekend Patching +4 days after Patch Tuesday' -Body "The following servers will be
 patched and restarted between $PatchStart and $PatchEnd . Please ignore NAGIOS/PRTG alerts during the maintenance window for these servers. <br> $serverplus4br" -SmtpServer '127.0.0.1' -BodyAsHtml
 $SendEmail = "False"

 }

 # _DC/CM (All) & VM-XXX/DP-XXX Evens - Auto-patch and Auto-restart

$patchStart = (Get-Date $date).AddDays($patchTuesday + 11).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)


$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-1).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$SendEmail = "True"}else{$SendEmail = "False"}

if ($SendEmail -eq "True") {

$serverplus11 = Get-CMCollectionMember -CollectionName "_DC/CM (All) & VM-XXX/DP-XXX Evens - Auto-patch and Auto-restart" | Select Name | Sort-Object -Property Name | ConvertTo-Csv -NoTypeInformation

ForEach ($_ in $serverplus11) {

$serverplus11br += "$_ <br>"

}


 Send-MailMessage -From 'vm-acme-01@acme.com' -To 'patches@acme.com' -Subject 'Server Weekend Patching +11 days after Patch Tuesday' -Body "The following servers will be
 patched and restarted between $PatchStart and $PatchEnd . Please ignore NAGIOS/PRTG alerts during the maintenance window for these servers. <br> $serverplus11br" -SmtpServer '127.0.0.1' -BodyAsHtml
 $SendEmail = "False"
 }
 
 # _Production Servers – Auto-Patch & Auto-Restart

$patchStart = (Get-Date $date).AddDays($patchTuesday + 18).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)

$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-2).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$SendEmail = "True"}else{$SendEmail = "False"}

if ($SendEmail -eq "True"){

$serverplus18 = Get-CMCollectionMember -CollectionName "_Production Servers – Auto-Patch & Auto-Restart" | Select Name | Sort-Object -Property Name | ConvertTo-Csv -NoTypeInformation

ForEach ($_ in $serverplus18) {

$serverplus18br += "$_ <br>"

}

Send-MailMessage -From 'vm-acme-01@acme.com' -To 'patches@acme.com' -Subject 'Server Weekend Patching +18 days after Patch Tuesday' -Body "The following servers will be
patched and restarted between $PatchStart and $PatchEnd . Please ignore NAGIOS/PRTG alerts during the maintenance window for these servers. <br> $serverplus18br" -SmtpServer '127.0.0.1' -BodyAsHtml
$SendEmail = "False"
}









