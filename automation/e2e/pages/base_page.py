from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

class BasePage:
    def __init__(self, driver, timeout=15):
        self.driver = driver
        self.timeout = timeout

    def by_id(self, acc_id: str):
        return (AppiumBy.ACCESSIBILITY_ID, acc_id)

    def wait_visible(self, locator):
        return WebDriverWait(self.driver, self.timeout).until(
            EC.visibility_of_element_located(locator)
        )

    def tap(self, locator):
        self.wait_visible(locator).click()

    def is_visible(self, locator) -> bool:
        try:
            self.wait_visible(locator)
            return True
        except TimeoutException:
            return False