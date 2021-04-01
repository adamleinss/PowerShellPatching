$ServersPatching = Get-Content D:\cron\PatchAdams\servers.txt

$CurrentDate = Get-Date
$CurrentMonth = ($CurrentDate).ToUniversalTime().Month
$CurrentMonthName = $CurrentMonth | %{(Get-Culture).DateTimeFormat.GetMonthName($_)}

$ServersTxtModDate = (Get-item D:\cron\PatchAdams\servers.txt).lastwritetime
$ServersTxtMonth = ($ServersTxtModDate).ToUniversalTime().Month
$ServersTxtMonthName = $ServersTxtMonth | %{(Get-Culture).DateTimeFormat.GetMonthName($_)}

$servers = @('VM-ACME-01')

if ($CurrentMonthName -eq $ServersTxtMonthName) {

    For ($i=0; $i -lt $servers.Length; $i++) {
        if ($ServersPatching | Select-String -Pattern $servers[$i])
          { Write-Host Restarting $servers[$i]
            Restart-Computer $servers[$i] -Force
        } # end if
     } #end for

 } #end outer if
