$servers = Get-ADComputer -Filter { OperatingSystem -like "*Windows Server*"} | Select -ExpandProperty Name
Write-Host " Total No of Server Objects found in AD - $($servers.Count) " -ForegroundColor Cyan


$Results = @()

foreach($server in $servers)
{
If (Test-Connection $server -Count 1 -ErrorAction SilentlyContinue)
{
$location = gwmi -class CacheConfig -Namespace root\ccm\SoftMgmtAgent -ComputerName $server | Select -ExpandProperty Location
$drive = $location.Substring(0,1) + ":"
$ccmloc = "\\" + $server + "\" + $location.Substring(0,1) + "$\" + $location.Substring(3) + "\"
write-host "$server    $location"
$detailsbefore = Get-WmiObject Win32_LogicalDisk -ComputerName $server -ErrorAction SilentlyContinue | Where-Object { $_.DeviceID -eq $drive }
Get-ChildItem $ccmloc -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

$detailsafter = Get-WmiObject Win32_LogicalDisk -ComputerName $server -ErrorAction SilentlyContinue | Where-Object { $_.DeviceID -eq $drive }
Write-Host "ccmcache removed from $server" -ForegroundColor Green

$Properties = @{
ServerName = $server
Size = [math]::Round(($detailsafter.Size)/1GB)
'FreeSpace Before' = [math]::Round(($detailsbefore.FreeSpace)/1GB,2)
Location = $location
Drive = $drive
'FreeSpace After' = [math]::Round(($detailsafter.FreeSpace)/1GB,2)
'Cleared Space' = ([math]::Round(($detailsafter.FreeSpace)/1GB,2)-[math]::Round(($detailsbefore.FreeSpace)/1GB,2))
'FreeSpace Percentage' = [math]::Round((($detailsafter.FreeSpace)/($detailsafter.Size))*100,2)
}
$Results += New-Object psobject -Property $Properties

}
Else
{
Write-Host "$server Server Doen't exist/not reachable" -ForegroundColor Red
}
}
$Results | Select ServerName,Location,Drive,Size,'FreeSpace Before','FreeSpace After','Cleared Space','FreeSpace Percentage'| Export-Csv D:\cron\patchadams\ccm_clean.csv -NoTypeInformation