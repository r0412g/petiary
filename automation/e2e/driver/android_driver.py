from appium import webdriver
from appium.options.android import UiAutomator2Options
import os

def create_android_driver():
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.automation_name = "UiAutomator2"

    udid = os.getenv("ANDROID_UDID")
    if udid:
        options.udid = udid

    options.app_package = os.getenv("APP_PACKAGE", "com.yu.pet_diary")
    options.app_activity = os.getenv("APP_ACTIVITY", ".MainActivity")

    options.new_command_timeout = 300

    driver = webdriver.Remote(
        command_executor="http://localhost:4723",
        options=options
    )
    return driver
