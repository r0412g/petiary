import pytest

from automation.e2e.pages.intro_page import IntroPage
# from automation.e2e.pages.home_page import HomePage

@pytest.mark.smoke
class TestIntroPageFlow:

    # def test_00_app_can_launch(self, driver):
    #     assert driver.session_id is not None

    def test_01_first_launch_goes_to_intro(self, driver, fresh_install):
        IntroPage(driver).wait_loaded_intro_page()

    def test_02_intro_next_goes_forward(self, driver, fresh_install):
        IntroPage(driver)\
            .wait_loaded_intro_page()\
            .tap_next()\
            .wait_loaded_select_type_and_breed_page()

    def test_03_select_pet_type_rabbit(self, driver, fresh_install):
        intro = (IntroPage(driver)
                 .wait_loaded_intro_page()
                 .tap_next()
                 .select_pet_type_rabbit())

    def test_04_select_pet_breed_dutch(self, driver, fresh_install):
        intro = (IntroPage(driver)
                 .wait_loaded_intro_page()
                 .tap_next()
                 .select_pet_type_rabbit()
                 .select_pet_breed_dutch())

    def test_05_finish_goes_to_home(self, driver, fresh_install):
        home = (IntroPage(driver)
                .wait_loaded_intro_page()
                .tap_next()
                .tap_next()
                .tap_finish())
        home.wait_loaded_home_page()

    # def test_06_reopen_stays_on_home(self, driver, fresh_install, relaunch):
    #     home = (IntroPage(driver)
    #             .wait_loaded_intro_page()
    #             .tap_next()
    #             .tap_next()
    #             .tap_finish())
    #     home.wait_loaded_home_page()
    #
    #     # reopen app (didn't clean cache and data storage)
    #     relaunch
    #     HomePage.wait_loaded_home_page()