Write-Output "Starting Python installation..."
Set-ExecutionPolicy Bypass -Scope Process -Force

# Use Invoke-WebRequest with better error handling
$chocoInstallScript = "https://community.chocolatey.org/install.ps1"
Invoke-WebRequest -Uri $chocoInstallScript -UseBasicParsing -OutFile install.ps1

if (Test-Path "install.ps1") {
    Write-Output "Chocolatey script downloaded successfully"
    Invoke-Expression -Command (Get-Content install.ps1 -Raw)  # Run script inline
} else {
    Write-Output "Failed to download Chocolatey script"
    exit 1
}

# Add Chocolatey to the PATH
$env:Path += ";C:\ProgramData\chocolatey\bin"

# Ensure Chocolatey is installed before proceeding
if (!(Test-Path "C:\ProgramData\chocolatey\bin\choco.exe")) {
    Write-Output "Chocolatey installation failed."
    exit 1
}

# Install Python
choco install -y python310 --no-progress --limit-output

if ($?) {
    Write-Output "Python installed successfully"
} else {
    Write-Output "Python installation failed"
    exit 1
}

Write-Output "Finished"
