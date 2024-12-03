import os
import signal

import pytest


def pytest_runtest_makereport(item, call):
    report = pytest.TestReport.from_item_and_call(item, call)
    if report.when == "call" and report.failed and os.environ.get('TEST_TIMEOUT') == "True":
        # Customize the failure message
        custom_message = f"Custom Failure: {str(os.environ.get('XML_TAG_ROOT_CAUSE'))}"
        report.longrepr = custom_message  # Override the long failure message
    return report

# def pytest_runtest_logreport(report):
#     if report.when == "call" and report.failed:
#         # Add a custom XML attribute for failures
#         report.custom_failure_message = "Customized failure message."

# def pytest_record_xml_attribute(report, key, value):
#     # Customize or override attributes for the XML
#     if report.when == "call" and report.failed and key == "message":
#         return report.custom_failure_message  # Inject the custom message


def handle_signal(signum, frame):
    """
    Handle termination signals like SIGTERM and SIGINT.
    """
    print(f"Received termination signal: {signum}")
    # Perform cleanup or other necessary actions here
    print("Cleaning up resources...")
    os.environ["XML_TAG_ROOT_CAUSE"] = "Test ran for abnormally long time"
    os.environ["TEST_TIMEOUT"] = "True"
    # Exit gracefully
    exit(0)

@pytest.fixture(scope='function', autouse=True)
def term_handler(record_xml_attribute):
    print("Setting up signal handler")
    orig = signal.signal(signal.SIGINT, signal.getsignal(signal.SIGINT))
    signal.signal(signal.SIGINT, handle_signal)
    yield
    print("Restoring signal handler")
    signal.signal(signal.SIGTERM, orig)
    for env_var in os.environ:
        if env_var.startswith("XML_TAG_"):
            record_xml_attribute(env_var, os.environ.get(env_var, "-"))