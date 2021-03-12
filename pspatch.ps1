set-executionpolicy bypass

$env:PSModulePath = $env:PSModulePath + ";\\vm-acme-01\netlogon"
$computername = $env:computername + ".log"

#Start-Transcript -path \\vm-somesrv-01\logs\$computername -append

New-PSDrive -Name dest -Root \\vm-somsrv-01\logs -PSProvider FileSystem

Import-Module PSWindowsUpdate
Install-WindowsUpdate -MicrosoftUpdate -Category 'Security Updates', 'Critical Updates' -NotKBArticleID KB890830 -AcceptAll -AutoReboot -Verbose | Out-file dest:\$computername -Force -Append

#Stop-Transcript