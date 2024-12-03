# Add .NET class to handle signals
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class SignalHandler {
    [DllImport("Kernel32.dll", SetLastError = true)]
    public static extern bool SetConsoleCtrlHandler(HandlerRoutine handler, bool add);

    public delegate bool HandlerRoutine(int dwCtrlType);

    public static bool Handler(int dwCtrlType) {
        if (dwCtrlType == 2 || dwCtrlType == 0) { // SIGTERM or Ctrl+C
            Console.WriteLine("SIGTERM or Ctrl+C received. Cleaning up...");
            Environment.SetEnvironmentVariable("PS_SCRIPT_EXIT", "1");
            return false;
        }
        return true;
    }

    public static void Register() {
        SetConsoleCtrlHandler(new HandlerRoutine(Handler), true);
    }
}
"@

# Register the handler
[SignalHandler]::Register()

# Simulate a long-running process
Write-Host "Proces started with id: $pid"
Write-Host "Running... Send SIGTERM to test."
while ($true) {
    Start-Sleep -Seconds 1
    if ($env:PS_SCRIPT_EXIT -eq "1") {
        Write-Host "Signal received. Exiting script gracefully."
        exit
    }
    Write-Host "Still running..."
}
