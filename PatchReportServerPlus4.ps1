$serverplus4 = get-content D:\serverplus4.txt

Invoke-Command -ComputerName $serverplus4 {
    $Patches =  'KB4537821', 'KB4537764', 'KB4532691'
    Get-HotFix -Id $Patches
} -Credential (Get-Credential) -ErrorAction SilentlyContinue -ErrorVariable Problem
 
foreach ($p in $Problem) {
    if ($p.origininfo.pscomputername) {
        Write-Warning -Message "Patch not found on $($p.origininfo.pscomputername)" 
    }
    elseif ($p.targetobject) {
        #Write-Warning -Message "Unable to connect to $($p.targetobject)"
    }
}