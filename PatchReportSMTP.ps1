Stop-Transcript | out-null
Start-Transcript -path D:\cron\patchadams\patchreport.txt

$Credential = Import-CliXml -Path D:\cron\PatchAdams\bsod.cred

Get-credential ($Credential)

$servers = get-content D:\cron\patchadams\servers.txt

$rslt = get-content D:\cron\patchadams\patches.txt

# Specify the target FullProductNames
$targetProductNames = "Windows Server 2012", "Windows Server 2012 R2", "Windows Server 2016", "Windows Server 2019", "Windows Server 2022"

# HashSet to store the unique KB numbers
$kbNumbers = [System.Collections.Generic.HashSet[string]]::new()

# Flag to indicate if the current line contains a FullProductName
$foundProductName = $false

# Iterate through each line in the file
foreach ($line in $rslt) {
    # Check if the line contains FullProductName
    if ($line -like "FullProductName*") {
        $productName = ($line -split ":")[1].Trim()

        # Check if the FullProductName matches the target names
        if ($targetProductNames -contains $productName) {
            $foundProductName = $true
        } else {
            $foundProductName = $false
        }
    }

    # Check if the line contains KBArticle
    if ($line -like "KBArticle*") {
        if ($foundProductName) {
            # Extract the KB numbers from the KBArticle field
            $kbMatches = [regex]::Matches($line, "ID=(\d{7})")

            # Iterate through each match and append "KB" to the front of it
            foreach ($match in $kbMatches) {
                $kbNumber = "KB" + $match.Groups[1].Value
                [void]$kbNumbers.Add($kbNumber)
            }
        }
    }
}

# Output the array of unique KB numbers
$kbNumbers


Invoke-Command -ComputerName $servers {
	$FormatEnumerationLimit=-1
    Get-HotFix -Id $using:kbNumbers | Format-Table -Wrap | Out-String -Width 300
} -Credential ($Credential) -ErrorAction SilentlyContinue -ErrorVariable Problem
 
foreach ($p in $Problem) {
    if ($p.origininfo.pscomputername) {
        Write-Warning -Message "Patch not found on $($p.origininfo.pscomputername)" 
    }
    elseif ($p.targetobject) {
       # Write-Warning -Message "Unable to connect to $($p.targetobject)"
    }
}

Stop-Transcript

$patchreport = get-content D:\CRON\PatchAdams\patchreport.txt -Raw

Send-MailMessage -From 'patchreport@acme.com' -To 'bob@acme.com' -Subject 'Patch Compliance Report' -Body "
$patchreport" -SmtpServer '127.0.0.1'


