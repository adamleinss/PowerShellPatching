# Get all computers from Active Directory that are running a server OS
$servers = Get-ADComputer -Filter 'OperatingSystem -like "*Server*"' -Properties OperatingSystem

# Create an array to store the results
$results = @()

foreach ($server in $servers) {
    try {
        # Test if the server is online
        if (Test-Connection -ComputerName $server.Name -Count 1 -Quiet) {
            # Get the last boot time
            $lastBoot = (Get-CimInstance -ComputerName $server.Name -ClassName Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime
            
            # Calculate uptime
            $uptime = (Get-Date) - $lastBoot
            
            # Create custom object with server details
            $results += [PSCustomObject]@{
                ServerName     = $server.Name
                OperatingSystem = $server.OperatingSystem
                LastBootTime   = $lastBoot
                UptimeDays     = [math]::Round($uptime.TotalDays, 2)
                Status         = "Online"
            }
        } else {
            $results += [PSCustomObject]@{
                ServerName     = $server.Name
                OperatingSystem = $server.OperatingSystem
                LastBootTime   = "N/A"
                UptimeDays     = "N/A"
                Status         = "Offline"
            }
        }
    }
    catch {
        $results += [PSCustomObject]@{
            ServerName     = $server.Name
            OperatingSystem = $server.OperatingSystem
            LastBootTime   = "N/A"
            UptimeDays     = "N/A"
            Status         = "Error: $_"
        }
    }
}

# Display the results in a formatted table
$results | Format-Table -AutoSize

#Optional: Export to CSV file
$results | Export-Csv -Path "C:\temp\Server_Uptime_Report.csv" -NoTypeInformation