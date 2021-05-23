Function Get-PendingRebootStatus {
<#
.Synopsis
    This will check to see if a server or computer has a reboot pending.
    For updated help and examples refer to -Online version.
 
.NOTES
    Name: Get-PendingRebootStatus
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2018-Jun-6
 
.LINK
    https://thesysadminchannel.com/remotely-check-pending-reboot-status-powershell -
 
 
.PARAMETER ComputerName
    By default it will check the local computer.
 
.EXAMPLE
    Get-PendingRebootStatus -ComputerName PAC-DC01, PAC-WIN1001
 
    Description:
    Check the computers PAC-DC01 and PAC-WIN1001 if there are any pending reboots.
#>
 
    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0
        )]
 
    [string[]]  $ComputerName = $env:COMPUTERNAME
    )
 
 
    BEGIN {}
 
    PROCESS {
        Foreach ($Computer in $ComputerName) {
            Try {
                $PendingReboot = $false
 
                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"
 
                if ($WMI_Reg) {
                    if (($WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")).sNames -contains 'RebootPending') {$PendingReboot = $true}
                    if (($WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")).sNames -contains 'RebootRequired') {$PendingReboot = $true}
 
                    #Checking for SCCM namespace
                    $SCCM_Namespace = Get-WmiObject -Namespace ROOT\CCM\ClientSDK -List -ComputerName $Computer -ErrorAction Ignore
                    if ($SCCM_Namespace) {
                        if (([WmiClass]"\\$Computer\ROOT\CCM\ClientSDK:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending -eq $true) {$PendingReboot = $true}
                    }
 
                    if ($PendingReboot -eq $true) {
                        [PSCustomObject]@{
                            ComputerName   = $Computer.ToUpper()
                            PendingReboot  = $true
                        }
                      } else {
                        [PSCustomObject]@{
                            ComputerName   = $Computer.ToUpper()
                            PendingReboot  = $false
                        }
                    }
                }
            } catch {
                Write-Error $_.Exception.Message
 
            } finally {
                #Clearing Variables
                $WMI_Reg        = $null
                $SCCM_Namespace = $null
            }
        }
    }
 
    END {}
}
