import signal
import time
import os

def handle_signal(signum, frame):
    """
    Handle termination signals like SIGTERM and SIGINT.
    """
    print(f"Received termination signal: {signum}")
    # Perform cleanup or other necessary actions here
    print("Cleaning up resources...")
    # Exit gracefully
    exit(0)

# # Catch all signals
# for sig in [signal.SIGTERM, signal.SIGINT]:
#     signal.signal(sig, handle_signal)

# # Set up signal handlers
#print("Valid signals: ", signal.valid_signals())
signal.signal(signal.SIGTERM, handle_signal)
signal.signal(signal.SIGINT, handle_signal)
#signal.signal(signal.SIGBREAK, handle_signal)
print("Hello from Python script!")
print(f"Python Process ID: {os.getpid()}")

while True:
    time.sleep(1)