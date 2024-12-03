$UNIX_PLATFORM = 'Unix'
$os_name = [environment]::OSVersion.Platform

if ($os_name -eq $UNIX_PLATFORM) {
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class SignalHandler {
    // Import the signal function from libc
    [DllImport("libc.so.6", SetLastError = true)]
    public static extern int signal(int signum, SignalHandler.HandlerRoutine handler);

    // Define the delegate for handling signals
    public delegate void HandlerRoutine(int signum);

    // Signal constants (SIGTERM, SIGINT)
    public const int SIGTERM = 15;
    public const int SIGINT = 2;

    // The handler method that will be called when a signal is received
    public static void Handler(int signum) {
        if (signum == SIGTERM || signum == SIGINT) {
            Console.WriteLine("SIGTERM or SIGINT received. Cleaning up...");
            Environment.SetEnvironmentVariable("PS_SCRIPT_EXIT", "1");
        }
    }

    // Register the signal handler
    public static void Register() {
        signal(SIGTERM, new HandlerRoutine(Handler));
        signal(SIGINT, new HandlerRoutine(Handler));
    }
}
"@
} else {
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
            return true;
        }
        return true;
    }

    public static void Register() {
        SetConsoleCtrlHandler(new HandlerRoutine(Handler), true);
    }
}
"@
}

# Register the handler
[SignalHandler]::Register()

if($env:PS_SCRIPT_EXIT -eq "1") {
    Write-Host "Signal received. Exiting script gracefully."
    exit
}

Write-Host "Hello from test script"
Write-Host "Pwsh Process ID: $PID"
# python scripts/test-python.py


$RESULT_PATH = "results"
$LOGGING_NAME = "test-one"
$SUITE_NAME = "test-one"
New-Item -Force $RESULT_PATH/$LOGGING_NAME.txt | Out-Null

python -m pytest test/${SUITE_NAME} -rpP -v `
--log-file "${RESULT_PATH}/${LOGGING_NAME}.log" `
--junitxml "${RESULT_PATH}/${LOGGING_NAME}.xml" `
-o junit_suite_name=${SUITE_NAME} `
-o junit_family=xunit1 `
--capture=tee-sys > "${RESULT_PATH}/${LOGGING_NAME}.txt"

# $RESULT_PATH = "results"
# $LOGGING_NAME = "test-one"
# $SUITE_NAME = "test-one"
# New-Item -Force $RESULT_PATH/$LOGGING_NAME.txt | Out-Null

# python -m pytest -rpP -v `
# --log-file "${RESULT_PATH}/${LOGGING_NAME}.log" `
# --junitxml "${RESULT_PATH}/${LOGGING_NAME}.xml" `
# -o junit_suite_name=${SUITE_NAME} `
# -o junit_family=xunit1 `
# --capture=tee-sys > "${RESULT_PATH}/${LOGGING_NAME}.txt"