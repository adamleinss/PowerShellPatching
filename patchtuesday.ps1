# Used to catch servers not patched by SCCM and to automate what server list is patching


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

# Patching Server Pilot – Auto Patch & Auto-Restart / Nightly maintenance window [10PM to 5AM]

$patchStart = (Get-Date $date).AddDays($patchTuesday).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)

# Figure out what time it is

$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-1).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)


if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$Patching = "True"}else{$Patching = "False"}

if ($Patching -eq "True") {

if (Test-Path D:\CRON\PatchAdams\servers.txt) 
  {remove-item -force D:\CRON\PatchAdams\servers.txt}
copy-item -force -path D:\CRON\PatchAdams\serverpilot.txt -destination D:\CRON\PatchAdams\servers.txt

if (Test-Path D:\CRON\PatchAdams\count18.txt) 
  {remove-item -force D:\CRON\PatchAdams\count18.txt}

$Patching = "False"
}



# Patching All Test/Dev & VM-XXX/DP-XXX Odds/DC Odds – Auto-Patch & Auto-Restart / +4 days after Patch Tuesday which will be the 2nd or 3rd weekend of the month [Saturday 10PM to Sunday 5AM] – Auto-patch and Auto-restart

$patchStart = (Get-Date $date).AddDays($patchTuesday + 4).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)

$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-1).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$Patching= "True"}else{$Patching = "False"}

if ($Patching -eq "True"){

if (Test-Path D:\CRON\PatchAdams\servers.txt) 
  {remove-item -force D:\CRON\PatchAdams\servers.txt}
copy-item -force -path D:\CRON\PatchAdams\serverplus4.txt -destination D:\CRON\PatchAdams\servers.txt 
$Patching = "False"
}


 # _DC/CM (All) & VM-XXX/DP-XXX Evens - Auto-patch and Auto-restart

$patchStart = (Get-Date $date).AddDays($patchTuesday + 11).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)


$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-1).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$Patching = "True"}else{$Patching = "False"}

if ($Patching -eq "True") {

if (Test-Path D:\CRON\PatchAdams\servers.txt) 
  {remove-item -force D:\CRON\PatchAdams\servers.txt}
copy-item -force -path D:\CRON\PatchAdams\serverplus11.txt -destination D:\CRON\PatchAdams\servers.txt 
$Patching = "False"
}

 
 # _Production Servers – Auto-Patch & Auto-Restart

$patchStart = (Get-Date $date).AddDays($patchTuesday + 18).AddHours(22)
$patchEnd = (Get-Date $patchStart).AddHours(7)

$currentDate = Get-Date
$startDT = $PatchStart.ToString("s")
$endDT = $PatchEnd.ToString("s")
$SendNotificationStartTime=$PatchStart.AddDays(-2).AddHours(-14)
$SendNotificationEndTime=$SendNotificationStartTime.AddMinutes(45)

if(([DateTime]($currentDate) -ge $SendNotificationStartTime) -and ([DateTime]($currentDate) -le $SendNotificationEndTime )){$Patching = "True"}else{$Patching = "False"}

if ($Patching -eq "True"){

if (Test-Path D:\CRON\PatchAdams\servers.txt) 
  {remove-item -force D:\CRON\PatchAdams\servers.txt}
copy-item -force -path D:\CRON\PatchAdams\serverplus18.txt -destination D:\CRON\PatchAdams\servers.txt 
$Patching = "False"
}

