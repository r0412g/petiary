from .base_page import BasePage
from ..locators import ids

class HomePage(BasePage):
    def wait_loaded_home_page(self):
        assert self.is_visible(self.by_id(ids.HOME_PET_DATA_TEXT)), "Home page not loaded (Pet data text not found)"
        return self
