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
            return true;
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