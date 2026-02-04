import os
import pytest
import subprocess
from e2e.driver.android_driver import create_android_driver

def _adb_clear_app_data(udid: str, package: str):
    cmd = ["adb"]
    if udid:
        cmd += ["-s", udid]
    cmd += ["shell", "pm", "clear", package]
    subprocess.run(cmd, check=True)

def _adb_force_stop(udid: str, package: str):
    cmd = ["adb"]
    if udid:
        cmd += ["-s", udid]
    cmd += ["shell", "am", "force-stop", package]
    subprocess.run(cmd, check=True)

@pytest.fixture(scope="session")
def driver():
    driver = create_android_driver()
    yield driver
    driver.quit()

@pytest.fixture
def fresh_install(driver):
    udid = os.getenv("ANDROID_UDID", "")
    package = driver.current_package
    _adb_force_stop(udid, package)
    _adb_clear_app_data(udid, package)

    driver.activate_app(package)
    yield

def _app_id(driver) -> str:
    caps = getattr(driver, "capabilities", {}) or {}
    app_pkg = caps.get("appPackage") or caps.get("appium:appPackage")
    if app_pkg:
        return app_pkg

    return driver.current_package

# @pytest.fixture
# def relaunch(driver):
#     app_id = _app_id(driver)
#
#     try:
#         driver.terminate_app(app_id)
#     except Exception:
#         pass
#
#     try:
#         driver.activate_app(app_id)
#     except Exception:
#         try:
#             driver.execute_script("mobile: activateApp", {"appId": app_id})
#         except Exception:
#             driver.launch_app()
#
#     yield

@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):

    # If a tests fails, take a screenshot automatically
    outcome = yield
    report = outcome.get_result()

    if report.when == "call" and report.failed:
        get_driver = item.funcargs.get("driver")
        if get_driver is None:
            return
        os.makedirs("artifacts/screenshots", exist_ok=True)
        filename = f"artifacts/screenshots/{item.name}.png"
        try:
            get_driver.save_screenshot(filename)
        except Exception:
            # If screenshot fails, don't fail the tests report hook
            pass
