Write-Output "Starting Python installation..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Use Invoke-WebRequest for better error handling
$chocoInstallScript = "https://community.chocolatey.org/install.ps1"
Invoke-WebRequest -Uri $chocoInstallScript -UseBasicParsing -OutFile install.ps1
if ($?) {
    Write-Output "Chocolatey script downloaded successfully"
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File install.ps1" -Wait -NoNewWindow
} else {
    Write-Output "Failed to download Chocolatey script"
    exit 1
}

# Install Python
choco install -y python310
if ($?) {
    Write-Output "Python installed successfully"
} else {
    Write-Output "Python installation failed"
    exit 1
}

Write-Output "Finished"
