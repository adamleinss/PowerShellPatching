# Set execution policy globally to bypass
Set-ExecutionPolicy Bypass -Force

# Define paths
$sourceModulePath = "\\vm-acme-01\netlogon\PSWindowsUpdate"
$localModulePath = "C:\Program Files\WindowsPowerShell\Modules\PSWindowsUpdate"
$computername = $env:computername + ".log"

# Create PSDrive for logging
try {
    New-PSDrive -Name dest -Root \\vm-bob-01\logs -PSProvider FileSystem -ErrorAction Stop
}
catch {
    Write-Error "Failed to create PSDrive: $_"
    exit 1
}

# Check if PSWindowsUpdate module exists locally, if not copy it
try {
    if (-not (Test-Path $localModulePath)) {
        Write-Host "Copying PSWindowsUpdate module to local computer..."
        # Create the modules directory if it doesn't exist
        $parentDir = Split-Path $localModulePath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        # Copy the module
        Copy-Item -Path $sourceModulePath -Destination $localModulePath -Recurse -Force -ErrorAction Stop
        Write-Host "Module copied successfully"
    }
    else {
        Write-Host "PSWindowsUpdate module already exists locally"
    }
}
catch {
    Write-Error "Failed to copy PSWindowsUpdate module: $_"
    exit 1
}

# Import the module from local path
try {
    Write-Host "Importing PSWindowsUpdate module..."
    Import-Module -Name PSWindowsUpdate -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to import PSWindowsUpdate module: $_"
    exit 1
}

# Run Windows Updates
try {
    Write-Host "Starting Windows Update process..."
    Install-WindowsUpdate -MicrosoftUpdate -Category 'Security Updates', 'Critical Updates' -NotKBArticleID KB890830 -AcceptAll -AutoReboot -Verbose | 
        Out-File "dest:\$computername" -Force -Append -ErrorAction Stop
    Write-Host "Windows Update process completed"
}
catch {
    Write-Error "Windows Update process failed: $_"
    exit 1
}
finally {
    # Clean up PSDrive
    if (Get-PSDrive -Name dest -ErrorAction SilentlyContinue) {
        Remove-PSDrive -Name dest -Force
    }
}