function Get-SecurityUpdate
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                Position=0,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="Enter Year-Month.  Example 2017-May")]
        [ValidateNotNullOrEmpty()]
        [string]
        $MonthOfInterest,
 
        [Parameter(Mandatory=$true,
                Position=1,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="Enter your APIKey. Eg: 16ce02bef3d9475699b9cc3f0bed1234")]
        [ValidateNotNullOrEmpty()]
        [string]
        $APIKey,
 
        [Parameter(Mandatory=$false,
                Position=2,
                ValueFromPipelineByPropertyName=$true,
                HelpMessage="Enter the result grouping nature. Eg: CVEByKB")]
        [ValidateSet('RAW', 'CVEByProduct', 'KBByProduct', 'ProductByKB', 'CVEByKB', 'KBByCVE')]
        [string]
        $ResultType = 'CVEByKB'
 
    )
 
    [string] $fn = $MyInvocation.MyCommand
    [string] $stepName = "Begin [$fn]"
 
    try
    {    
 
        $stepName = "[$fn]: Check if MSRCSecurityUpdates exists and install if not"
        #---------------------------------------------------------------
        Write-Verbose $stepName
 
        if(-not {Get-Module MsrcSecurityUpdates})
        {
            Install-Module MSRCSecurityUpdates -Force
        }
 
        #Not necessary to import..just referencing a cmdlet in the module should automatically import the module
        #Import-Module MSRCSecurityUpdates -Force
 
        $stepName = "[$fn]: Set APIKey and download updates for month of interest"
        #---------------------------------------------------------------
        Write-Verbose $stepName
 
        Set-MSRCApiKey -ApiKey $APIKey -Verbose        
 
        $reportData = Get-MsrcCvrfDocument -ID  $MonthOfInterest | Get-MsrcCvrfAffectedSoftware
 
        $stepName = "[$fn]: Loop through raw data to make lists - CVE's by product, KB's by product, Products by KB's etc"
        #---------------------------------------------------------------
        Write-Verbose $stepName
 
        #Facts about raw data in $reportData
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
 
        #Given the above,
        #  depending on the what you want to look at the data by,
        #  "Severity, Impact, RestartRequired" may be approximations (first or last occurance)
 
        #These hashtables will hold specific associations as key and value as csv
        [hashtable]$cveByProductHash = @{}
        [hashtable]$kbByProductHash = @{}
        [hashtable]$productByKBHash = @{}
        [hashtable]$cveByKBHash = @{}
        [hashtable]$kbByCVEHash = @{}
        [hashtable]$productByCVEHash = @{}
 
        #These hashtables will hold all data values as objects by the keys
        [hashtable]$cveByProductHashData = @{}
        [hashtable]$kbByProductHashData = @{}
        [hashtable]$productByKBHashData = @{}
        [hashtable]$cveByKBHashData = @{}
        [hashtable]$kbByCVEHashData = @{}
        [hashtable]$productByCVEHashData = @{}
 
        foreach($row in $reportData)
        {
            Write-verbose ('Processing row: ' + $row)
 
            #There is only one CVE per raw row
            $cveByProductHash[$row.FullProductName] += ($row.CVE + ';')
 
            #There are multiple KB's per raw row
            foreach($kb in $row.KBArticle)
            {
                $kbByProductHash[$row.FullProductName] += ($kb.ID + ';')
                $productByKBHash[$kb.ID] += ($row.FullProductName + ';')
                $cveByKBHash[$kb.ID] += ($row.CVE + ';')
                $kbByCVEHash[$row.CVE] += ($kb.ID + ';')
                $productByCVEHash[$row.CVE] += ($row.FullProductName + ';')
 
                #These are the ways in which data can be looked at!
                # (split, select unique and join back to eliminate duplicates)
                #
 
                #----- By Product --------
                $cveByProductHashData[$row.FullProductName] = [pscustomobject]@{
                                                'ProductName'= $row.FullProductName
                                                'KB' = ((($kbByProductHash[$row.FullProductName]).Split(';') | Select-Object -Unique) -Join ';')
                                                'CVE' = ((($cveByProductHash[$row.FullProductName]).Split(';') | Select-Object -Unique) -Join ';')
                                                'Severity'= $row.severity
                                                'Impact'= $row.impact
                                                }
 
                $kbByProductHashData[$row.FullProductName] = `
                                                $cveByProductHashData[$row.FullProductName]
 
                #----- By KB --------
                $productByKBHashData[$kb.ID] = [pscustomobject]@{
                                                'KB'= $kb.ID
                                                'ProductName' = ((($productByKBHash[$kb.ID]).Split(';') | Select-Object -Unique) -Join ';')
                                                'CVE' = ((($cveByKBHash[$kb.ID]).Split(';') | Select-Object -Unique) -Join ';')
                                                'Severity'= $row.severity
                                                'Impact'= $row.impact
                                                }
 
                $cveByKBHashData[$kb.ID] = `
                                                $productByKBHashData[$kb.ID]
 
                #----- By CVE --------
                $kbByCVEHashData[$row.CVE] = [pscustomobject]@{
                                                'CVE' = $row.CVE
                                                'KB' = ((($kbByCVEHash[$row.CVE]).Split(';') | Select-Object -Unique) -Join ';')
                                                'ProductName' = ((($productByCVEHash[$row.CVE]).Split(';') | Select-Object -Unique) -Join ';')
                                                'Severity'= $row.severity
                                                'Impact'= $row.impact
                                                }
 
                $productByCVEHashData[$row.CVE] =
                                                $kbByCVEHashData[$row.CVE]
 
            }
        }
 
        #Serve it up the way the caller wants!
        #
        switch ($ResultType)
        {
            'RAW'           {$reportData}
            'CVEByProduct'  {$cveByProductHashData.Values}
            'KBByProduct'   {$kbByProductHashData.Values}
            'ProductByKB'   {$productByKBHashData.Values}
            'CVEByKB'       {$cveByKBHashData.Values}
            'KBByCVE'       {$kbByCVEHashData.Values}
            'ProductByCVE'  {$productByCVEHashData.Values}
        }                
 
    }
    catch
    {
        [Exception]$ex = $_.Exception
        Throw "Unable to get security update data. Error in step: `"{0}]`" `n{1}" -f `
                        $stepName, $ex.Message
    }
    finally
    {
        #Return value if any
    }
}

$date = Get-Date -Format "yyyy-MMM"
$datestr = $date.ToString()

$rslt = Get-SecurityUpdate -MonthOfInterest $datestr -APIKey '16ce02bef3d9475699b9cc3f0bed1234' -ResultType 'RAW'
$rslt | out-file -Width 300 D:\cron\patchadams\patches.txt