$ServersPatching = Get-Content D:\cron\PatchAdams\servers.txt

$servers = @('SOMESRVER')

For ($i=0; $i -lt $servers.Length; $i++) {
  if ($ServersPatching | Select-String -Pattern $servers[$i])
      { Write-Host Restarting $servers[$i]
        Restart-Computer $servers[$i] -Force
        } # end if
 } #end for
