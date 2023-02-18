set-executionpolicy bypass

$env:PSModulePath = $env:PSModulePath + ";\\vm-acme-01\netlogon"

Import-Module PSWindowsUpdate

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


$2ndTuesday = [DateTime]$date.AddDays($patchTuesday)

# Figure out what time it is

[DateTime]$currentDate = Get-Date -Format "MM-dd-yyyy"
$4dayoffset =  $2ndTuesday.AddDays(4)
$11dayoffset = $2ndTuesday.AddDays(11)
$18dayoffset = $2ndTuesday.AddDays(18)

write-output $currentDate
Write-Output $2ndTuesday
write-output $4dayoffset
write-output $11dayoffset
write-output $18dayoffset

if ($currentdate -eq $4dayoffset) {
Write-Output "It's +4 days after Patch Tuesday, time to start patching"
stop-service "Avigilon Control Center"
stop-service "AvigilonControlCenterAnalyticsService"
stop-service "AvigilonControlCenterWebEndpointService"
Install-WindowsUpdate -MicrosoftUpdate -Category 'Security Updates', 'Critical Updates' -NotKBArticleID KB890830 -AcceptAll -AutoReboot -Verbose -SendReport –PSWUSettings @{SmtpServer="127.0.0.1";From="vms_patching@acme.com";To="bob@acme.com";Subject = 'Patch report - VMS Patching'; Port=25}

}

else {

Write-Output "It's not +4days after Patch Tuesday, do nothing"

}