from .base_page import BasePage
from .home_page import HomePage
from ..locators import ids

class IntroPage(BasePage):
    def wait_loaded_intro_page(self):
        assert self.is_visible(self.by_id(ids.INTRO_NEXT_BUTTON)), "Intro page not loaded (NEXT button not found)"
        return self

    # def wait_loaded(self, step: int):
    #     if step == 1:
    #         assert self.is_visible(self.by_id(ids.INTRO_STEP1_TITLE))
    #     elif step == 2:
    #         assert self.is_visible(self.by_id(ids.INTRO_PET_TYPE_DROPDOWN))
    #     elif step == 3:
    #         assert self.is_visible(self.by_id(ids.INTRO_DONE_BUTTON))
    #     return self

    def wait_loaded_select_type_and_breed_page(self):
        assert self.is_visible(self.by_id(ids.INTRO_PET_TYPE_DROPDOWN)), "Select type and breed not loaded (Type dropdown menu not found)"
        return self

    def select_pet_type_rabbit(self):
        self.tap(self.by_id(ids.INTRO_PET_TYPE_DROPDOWN))
        self.tap(self.by_id(ids.intro_type_item('rabbit')))
        return self

    def select_pet_breed_dutch(self):
        self.tap(self.by_id(ids.INTRO_PET_BREED_DROPDOWN))
        self.tap(self.by_id(ids.intro_breed_item('dutch')))
        return self

    def tap_next(self):
        self.tap(self.by_id(ids.INTRO_NEXT_BUTTON))
        return self

    def tap_finish(self):
        self.tap(self.by_id(ids.INTRO_DONE_BUTTON))
        return HomePage(self.driver)
