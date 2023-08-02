<#===========================================================================================================================
 Script Name: ServerPatchReport.ps1
 Description: Reports uptime and the last date a patch was installed on servers.
      Inputs: List of server names fed from text file, one server name per line.
     Outputs: Server name, uptime, date and time the patch was installed, and how many days ago the server was patched.
       Notes: Added the option to have a .CSV file attached to the email.
     Example: .\ServerPatchReport.ps1
      Author: Richard Wright
Date Created: 11/3/2017
     Credits: https://damn.technology/get-latest-installed-update-powershell
              Scot Johnson (Spicehead: ScoJo) for bug reporting.
   ChangeLog: MM/DD/YYYY  Who  Description of changes
              ----------  ---  ----------------------------------------------------------------------------------------------
              11/04/2017  RMW  Added BG colors to highlight good, warning, critical days.
              11/06/2017  RMW  Added email notification.
              12/06/2017  RMW  Changed the querying processes
              12/20/2017  RWM  Aesthetics
              10/09/2018  RMW  Aesthetics
              11/06/2019  RMW  Added .CSV file option
              12/06/2019  RMW  Modified error checking routine
              07/06/2020  RMW  Added Uptime
              02/07/2022  RMW  Edited subject, minor changes for clarity

=============================================================================================================================
Variable List - in the section following this, edit these variables with your preferences:
   VARIABLE NAME     DESCRIPTION
   ----------------  --------------------------------------------------------------------------------------------------------
   $DateStamp        Format of dates shown in the report.
   $DateStampCSV     Format of dates shown in the CSV report - commas removed.
   $ServerList       File with the list of servernames for which to provide patch statistics; one per line.
   $ReportFileName   The outputted HTML filename and location
   $ReportFileCSV    The outputted CSV filename and location
   $IncludeCSV       If "True" the $ReportFileCSV will be emailed as an attachment
   $ReportTitle      Name of the report that is shown in the generated HTML file and in email subject.
   $EmailTo          Who should receive the report via email
   $EmailCc          Who should receive the report via email Cc:
   $EmailFrom        Sender email address
   $EmailSubject     Subject for the email
   $SMTPServer       SMTP server name
   $BGColorTbl       Background color for tables.
   $BGColorGood      Background color for "Good" results. #4CBB17 is a shade of green.
   $BGColorWarn      Background color for "Warning" results. #FFFC33 is a shade of yellow.
   $BGColorCrit      Background color for "Critical" results. #FF0000 is red.
   $Warning          # of days since last update to indicate Warning (Yellow) in report. Must be less than $Critical amount.
   $Critical         # of days since last update to indicate Critical (RED) in report. Must be more than $Warning amount.    
=============================================================================================================================#>
$ComputerName = $($env:COMPUTERNAME)
$ScriptPath = "D:\cron\PatchAdams"

<#==============================
Edit these with your preferences
==============================#>
$DateStamp = (Get-Date -Format D)
$DateStampCSV = (Get-Date -Format "MMM-dd-yyyy")
$FileDateStamp = Get-Date -Format yyyyMMdd
$ServerList = Get-Content "$ScriptPath\Servers.txt"
$ReportFileName = "$ScriptPath\ServerPatchReport-$FileDateStamp.html"
$ReportFileCSV = "$ScriptPath\ServerPatchReport.csv"
$IncludeCSV = "True"
$ReportTitle = "SCHOOLS Server Patch Report"
$EmailTo = "bob@acme.com"
$EmailFrom = "patchbot@acme.com
$EmailSubject = "From $ComputerName - SCHOOLS Servers Patch Report for $DateStamp"
$SMTPServer = "127.0.0.1"
$BGColorTbl = "#EAECEE"
$BGColorGood = "#4CBB17"
$BGColorWarn = "#FFFC33"
$BGColorCrit = "#FF0000"
$Warning = 30
$Critical = 60


<#==================================================
Do not edit below this section
==================================================#>
Clear

<#==================================================
Begin MAIN
==================================================#>
# Create output file and nullify display output
New-Item -ItemType file $ReportFileName -Force > $null
New-Item -ItemType file $ReportFileCSV -Force > $null

<#==================================================
Write the HTML Header to the report files
==================================================#>
Add-Content $ReportFileName "<html>"
Add-Content $ReportFileName "<head>"
Add-Content $ReportFileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $ReportFileName "<title>$ReportTitle</title>"
Add-Content $ReportFileName '<STYLE TYPE="text/css">'
Add-Content $ReportFileName "td {"
Add-Content $ReportFileName "font-family: Cambria;"
Add-Content $ReportFileName "font-size: 11px;"
Add-Content $ReportFileName "border-top: 1px solid #999999;"
Add-Content $ReportFileName "border-right: 1px solid #999999;"
Add-Content $ReportFileName "border-bottom: 1px solid #999999;"
Add-Content $ReportFileName "border-left: 1px solid #999999;"
Add-Content $ReportFileName "padding-top: 0px;"
Add-Content $ReportFileName "padding-right: 0px;"
Add-Content $ReportFileName "padding-bottom: 0px;"
Add-Content $ReportFileName "padding-left: 0px;"
Add-Content $ReportFileName "}"
Add-Content $ReportFileName "body {"
Add-Content $ReportFileName "margin-left: 5px;"
Add-Content $ReportFileName "margin-top: 5px;"
Add-Content $ReportFileName "margin-right: 5px;"
Add-Content $ReportFileName "margin-bottom: 10px;"
Add-Content $ReportFileName "table {"
Add-Content $ReportFileName "border: thin solid #000000;"
Add-Content $ReportFileName "}"
Add-Content $ReportFileName "</style>"
Add-Content $ReportFileName "</head>"
Add-Content $ReportFileName "<body>"
Add-Content $ReportFileName "<table width='75%' align=`"center`">"
Add-Content $ReportFileName "<tr bgcolor=$BGColorTbl>"
Add-Content $ReportFileName "<td colspan='4' height='25' align='center'>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='4'><strong>$ReportTitle<br></strong></font>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='2'>$DateStamp</font><br><br>"

#Add to CSV file
Add-Content $ReportFileCSV "$ReportTitle"
Add-Content $ReportFileCSV "$DateStampCSV`n"

# Add color descriptions
$Warn=$Warning+1
Add-content $ReportFileName "<table width='75%' align=`"center`">"  
Add-Content $ReportFileName "<tr>"  
Add-Content $ReportFileName "<td width='30%' bgcolor=$BGColorGood align='center'><strong>Patched <= $Warning Days</strong></td>"  
Add-Content $ReportFileName "<td width='30%' bgcolor=$BGColorWarn align='center'><strong>Patched $Warn - $Critical Days</strong></td>"  
Add-Content $ReportFileName "<td width='30%' bgcolor=$BGColorCrit align='center'><strong>Patched > $Critical Days</strong></td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "</table>"

# Add Column Headers
Add-Content $ReportFileName "</td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "<tr bgcolor=$BGColorTbl>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Server Name</strong></td>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Uptime</strong></td>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Last Patch Date & Time</strong></td>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Days Since Last Patch</strong></td>"
Add-Content $ReportFileName "</tr>"

#Add column headers to CSV file
Add-Content $ReportFileCSV "Server Name, Uptime, Last Patch Date & Time, Days Since Last Patch"

<#==================================================
Function to write the HTML footer
==================================================#>
Function writeHtmlFooter
{
	param($FileName)
	Add-Content $FileName "</table>"
	Add-content $FileName "<table width='75%' align=`"center`">"  
	Add-Content $FileName "<tr bgcolor=$BGColorTbl>"  
	Add-Content $FileName "<td width='75%' align='center'><strong>Total Servers: $ServerCount</strong></td>"
	Add-Content $FileName "</tr>"
	Add-Content $FileName "</table>"
	Add-Content $FileName "</body>"
	Add-Content $FileName "</html>"
	Add-Content $ReportFileCSV "`nEnd of Report"
}

<#==================================================
Function to write server update information to the
HTML report file
==================================================#>
Function writeUpdateData
{
	param($FileName,$Server,$Uptime,$InstalledOn)
	Add-Content $FileName "<tr>"
	Add-Content $FileName "<td align='center'>$Server</td>"
	Add-Content $FileName "<td align='center'>$Uptime</td>"
	Add-Content $FileName "<td align='center'>$InstalledOn</td>"
# Color BG depending on $Warning and $Critical days set in script
    If ($InstalledOn -eq "Error collecting data") 
    { 
        $DaySpanDays = "Error"
        $Uptime = "Error"
    }
    Else
    {
        $System = (Get-Date -Format "MM/dd/yyyy hh:mm:ss")
        $DaySpan = New-TimeSpan -Start $InstalledOn -End $System
        $DaySpanDays = $DaySpan.Days
    }
	If ($InstalledOn -eq "Error collecting data" -or $DaySpan.Days -gt $Critical)
	{
    	# Red for Critical or Error retrieving data
		Add-Content $FileName "<td bgcolor=$BGColorCrit align='center'>$DaySpanDays</td>"
		Add-Content $ReportFileCSV "$Server,$Uptime,$InstalledOn,$DaySpanDays"
	}
	ElseIf ($DaySpan.Days -le $Warning)
	{
	    # Green for Good
		Add-Content $FileName "<td bgcolor=$BGColorGood align=center>$DaySpanDays</td>"
		Add-Content $ReportFileCSV "$Server,$Uptime,$InstalledOn,$DaySpanDays"
	}
	Else
	{
	    # Yellow for Warning
		Add-Content $FileName "<td bgcolor=$BGColorWarn align=center>$DaySpanDays</td>"
		Add-Content $ReportFileCSV "$Server,$Uptime,$InstalledOn,$DaySpanDays"
	}

	 Add-Content $FileName "</tr>"
}

<#==================================================
Query servers for their update history
Try registry first, if error Get-Hotfix
==================================================#>
Write-Host "Querying servers for installed updates...`n" -foreground "Yellow"
$ServerCount = 0
ForEach ($Server in $ServerList)
{
        $InstalledOn = ""

    if (Test-Connection "$server.schools.mpsds.edu" -Count 1 -ErrorAction SilentlyContinue) {
	$BootTime = (Get-WmiObject win32_operatingSystem -computer $Server -ErrorAction SilentlyContinue).lastbootuptime
	$BootTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($BootTime)
	$Now = Get-Date
	$Uptime = ""
	$span = New-TimeSpan $BootTime $Now 
		$Days = $span.days
		$Hours = $span.hours
		$Minutes = $span.minutes 

<#===============================
Remove plurals if the value = 1
=================================#>
	If ($Days -eq 1)
		{$Day = "1 day "}
	else
		{$Day = "$Days days "}

	If ($Hours -eq 1)
		{$Hr = "1 hr "}
	else
		{$Hr = "$Hours hrs "}

	If ($Minutes -eq 1)
		{$Min = "1 min"}
	else
		{$Min = "$Minutes mins"}

	$Uptime = $Day + $Hr + $Min

    Try
    {
    Write-host "Checking $Server..."
	$ServerCount++
    $ServerLastUpdate = (Get-HotFix -ComputerName $Server | Sort-Object -Descending -Property InstalledOn -ErrorAction SilentlyContinue | Select-Object -First 1)
	$InstalledOn = $ServerLastUpdate.InstalledOn

    }

    Catch 
    {
      #
    }

   If ($InstalledOn -eq "")
   {
	$InstalledOn = "Error collecting data"
	$Uptime = "Error collecting data"
   }

    writeUpdateData $ReportFileName $Server $Uptime $InstalledOn
}

}

Write-Host "Finishing report..." -ForegroundColor "Yellow"
writeHtmlFooter $ReportFileName

<#==================================================
Send email
==================================================#>
$BodyReport = Get-Content "$ReportFileName" -Raw

$SMTPsettings = @{
	To =  $EmailTo
	From = $EmailFrom
	Subject = $EmailSubject
	Body = $BodyReport
	SmtpServer = $SMTPServer
	}

$SMTPsettingsCSV = @{
	To =  $EmailTo
	From = $EmailFrom
	Subject = $EmailSubject
	Attachments = $ReportFileCSV
	Body = $BodyReport
	SmtpServer = $SMTPServer
	}

IF ($IncludeCSV -eq "True") {
	Send-MailMessage @SMTPsettingsCSV -BodyAsHtml
}ELSE {
	Send-MailMessage @SMTPsettings -BodyAsHtml
}

Start-Sleep 5
Remove-Item $ReportFileName -Force
Remove-Item $ReportFileCSV -Force