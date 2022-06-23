Import-Module MSRCSecurityUpdates -Force

$date = Get-Date -Format "yyyy-MMM"
$datestr = $date.ToString()

$rslt = Get-MsrcCvrfDocument -ID $datestr | Get-MsrcCvrfAffectedSoftware

$rslt | out-file -Width 300 D:\cron\patchadams\patches.txt