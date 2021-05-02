$FormatEnumerationLimit=-1

Stop-Transcript | out-null
Start-Transcript -path D:\cron\patchadams\patchreport.txt

$Credential = Import-CliXml -Path D:\cron\PatchAdams\bsod.cred

$servers = get-content D:\cron\patchadams\servers.txt

$rslt = get-content D:\cron\patchadams\patches.txt

$patchz = @()

$kbpattern = 'KB\d\d\d\d\d\d\d'

$found2012r2 = "FALSE"
$found2012 = "FALSE"
$found2016 = "FALSE"
$found2019 = "FALSE"

For ($i=0; $i -lt $rslt.Length; $i++) {
#write-output $rslt[$i]
    if (($rslt[$i] | select-string -pattern 'Windows Server 2012 R2') -and $found2012r2 -eq "FALSE" ) {
     if ($rslt[$i+1] | select-string -pattern 'Rollup') {
       $2012R2 = $rslt[$i+1] | select-string -pattern $kbpattern
       $KB2012R2 = $2012R2.Matches
       $patchz += $KB2012R2
       $found2012r2 = "TRUE"
       #write-host $KB2012R2
    
      } #end if
    } #end if

if (($rslt[$i] | select-string -pattern 'Windows Server 2012') -and $found2012 -eq "FALSE" ) {

     if ($rslt[$i+1] | select-string -pattern 'Rollup') {

       $2012 = $rslt[$i+1] | select-string -pattern $kbpattern
       $KB2012 = $2012.Matches
	   
	   if ($KB2012 -ne $KB2012R2) {
	   
			$patchz += $KB2012
			$found2012 = "TRUE"
			#write-host $KB2012
	   } #end dup if
	          
      } #end if
    } #end if


if (($rslt[$i] | select-string -pattern 'Windows Server 2016') -and $found2016 -eq "FALSE" ) {

       $2016 = $rslt[$i+1] | select-string -pattern $kbpattern
       $KB2016 = $2016.Matches
       $patchz += $KB2016
       $found2016 = "TRUE"
       #write-host $KB2016
    
    } #end if

if (($rslt[$i] | select-string -pattern 'Windows Server 2019') -and $found2019 -eq "FALSE" ) {

       $2019 = $rslt[$i+1] | select-string -pattern $kbpattern
       $KB2019 = $2019.Matches
       $patchz += $KB2019
       $found2019 = "TRUE"
       #write-host $KB2019
    
    } #end if

} #end for

$patchlist = "$($Patchz[0])","$($Patchz[1])", "$($Patchz[2])", "$($Patchz[3])"
write-host $patchlist

Invoke-Command -ComputerName $servers {
    Get-HotFix -Id $using:patchlist | Sort-Object Source | Format-Table -Autosize
} -Credential ($Credential) -ErrorAction SilentlyContinue -ErrorVariable Problem
 
foreach ($p in $Problem) {
    if ($p.origininfo.pscomputername) {
        Write-Warning -Message "Patch not found on $($p.origininfo.pscomputername)" 
    }
    elseif ($p.targetobject) {
      #  Write-Warning -Message "Unable to connect to $($p.targetobject)"
    }
}

Stop-Transcript

$patchreport = get-content D:\CRON\PatchAdams\patchreport.txt -Raw

Send-MailMessage -From 'patchreport@acme.com' -To 'daboss@acme.com' -Subject 'Patch Compliance Report' -Body "
$patchreport" -SmtpServer '127.0.0.1'

