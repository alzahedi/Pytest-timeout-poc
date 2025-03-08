$logPath = "C:\Scripts\script_output.log"
Start-Transcript -Path $logPath -Append
Write-Host "Starting script execution"
Write-Host "Hello world!"
Write-Host "Script execution completed"
Stop-Transcript
