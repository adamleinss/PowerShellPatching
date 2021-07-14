# totally ripped off and butchered (ahem, I mean carefully incised) from
# Jana Sattainathan [Twitter: @SQLJana] [Blog: sqljana.wordpress.com]
# https://sqljana.wordpress.com/2017/08/31/powershell-get-security-updates-list-from-microsoft-by-monthproductkbcve-with-api/
# all credit goes to Jana for saving me about a million hours

# special thanks to Tim Curwick [Twitter: @MadWPowershell] [Blog: https://www.madwithpowershell.com/2014/10/calculating-patch-tuesday-with.html]
# for date calculation business, which never fails to totally confuse me

# version 0.2

# Will need to install MSrcSecurityUpdates module from
# https://github.com/microsoft/MSRC-Microsoft-Security-Updates-API
# Will also need to create an APIkey. Create one at the Developer area at 
# https://portal.msrc.microsoft.com/en-us/security-guidance. Sign in with an outlook.com account 
# (create one if necessary), then plug the API key into the script.

#region initialise

$DebugPreference = "Continue"

# environment variables
$currentuser = $env:USERNAME
$homepath = "D:\cron\patchadams"
$filename = "$homepath\MS_Monthly_CVE.csv"
$filename_raw = "$homepath\patches.txt"

# API generated on my outlook.com email address
$APIKey = 'your_api_key_here'

# import modules. Must be already saved in C:\Users\$env:USERNAME\Documents\Windows PowerShell\Modules
import-module MSrcSecurityUpdates

# send API key to enable functionality
Set-MSRCApiKey -ApiKey $APIKey

# unhide cursor to show activity
#[Console]::CursorSize = 25

# if function getMonthOfInterest appears to fail, use this variable. Update YYYY-MMM as necessary
# monthOfInterest = "2019-Aug"

#endregion initialise


#region process

# generates the correct date format for Get-MsrcCvrfDocument to pull the current patch
function getMonthOfInterest {
    $basedate = (get-date -day 12).Date
    $patchtues = $basedate.AddDays(2 - [int]$basedate.DayOfWeek)
    $patchtues = $patchtues.AddHours(20)

    if ( ((get-date).Date) -lt $patchtues) {
        $patchmonth = (get-date -format "yyyy-MMM")
        return $patchmonth
    }
    else {
        $patchmonth = $basedate.ToString("yyyy-MMM")
        return $patchmonth
    }
}

$monthOfInterest = getMonthOfInterest

write-host "`n{*} Downloading $monthOfInterest rollup patch information from Microsoft. Please wait..." -ForegroundColor Green

$reportdata = Get-MsrcCvrfDocument -ID  $MonthOfInterest | Get-MsrcCvrfAffectedSoftware

# Facts about raw data in $reportData
#
# 1) A single product can have multiple KB's associated with it
# 2) A single KB could be associated with multiple CVE's
# 3) A single raw row could have single or multiple KB's
# 4) A CVE could be associated with multiple products/KB's
# 5) For a single KB and product combination, "Severity, Impact, Restart required" could all be different. Eg: 3191828
# 6) Each raw row has
#       FullProductName - SingleValue
#       KBArticle       - Hashtable (EMPTY! in some cases)
#       CVE             - SingleValue
#       Severity        - SingleValue
#       Impact          - SingleValue
#       RestartRequired - Array (count matches Superdedence) but all values will be the same
#       Supercedence    - Array (count matches RestartRequired) but each array value is distinct
#       CvssScoreSet    - HashTable
# given the above,
# depending on the what you want to look at the data by,
# "Severity, Impact, RestartRequired" may be approximations (first or last occurance)


# these hashtables will hold specific associations as key and value as csv
# mostly kept for reference
[hashtable]$cveByProductHash = @{}
[hashtable]$kbByProductHash = @{}
[hashtable]$productByKBHash = @{}
[hashtable]$cveByKBHash = @{}
[hashtable]$kbByCVEHash = @{}
[hashtable]$productByCVEHash = @{}
 
# these hashtables will hold all data values as objects by the keys
# mostly kept for reference
[hashtable]$cveByProductHashData = @{}
[hashtable]$kbByProductHashData = @{}
[hashtable]$productByKBHashData = @{}
[hashtable]$cveByKBHashData = @{}
[hashtable]$kbByCVEHashData = @{}
[hashtable]$productByCVEHashData = @{}

foreach($row in $reportData) {
            
# there is only one CVE per raw row
    $cveByProductHash[$row.FullProductName] += ($row.CVE + ';')
 
# there are multiple KB's per raw row
    foreach($kb in $row.KBArticle) {
 
        # ----- By CVE --------
        $kbByCVEHashData[$row.CVE] = [pscustomobject]@{
            'CVE' = $row.CVE
            'Severity'= $row.severity
            'Impact'= $row.impact
            'CVSS_base' = $row.CvssScoreSet.base
            'CVSS_temporal' = $row.CvssScoreSet.temporal
            'CVSS_vector' = $row.CvssScoreSet.vector
        }
    }
}

<# This is a hangover from the old script, kept purely for reference if different results are required.

switch ($resultType)
        {
            'RAW'           {$reportData}
            'CVEByProduct'  {$cveByProductHashData.Values}
            'KBByProduct'   {$kbByProductHashData.Values}
            'ProductByKB'   {$productByKBHashData.Values}
            'CVEByKB'       {$cveByKBHashData.Values}
            'KBByCVE'       {$kbByCVEHashData.Values}
            'ProductByCVE'  {$productByCVEHashData.Values}
        }
#>

# unfiltered output file for data integrity checking
write-host "`n{*} Producing raw csv...(for sanity checking)" -ForegroundColor Green
$reportData | Export-Csv $filename_raw

# filtered on CVE
Write-Host "`n{*} Producing consolidated csv..." -ForegroundColor Green
$kbByCVEHashData.Values | Export-Csv $filename

#endregion process


#region finalise

# tidy up CSV file
(Get-Content $filename | Select-Object -Skip 1) | Set-Content $filename
(Get-Content $filename_raw | Select-Object -Skip 1) | Set-Content $filename_raw

# open files
.$filename
.$filename_raw

#endregion finalise
