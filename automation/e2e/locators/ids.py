### INTRO PAGE

# DROPDOWN MENU
INTRO_PET_TYPE_DROPDOWN = "intro_dropdown_type"
INTRO_PET_BREED_DROPDOWN = "intro_dropdown_breed"

INTRO_PET_TYPE_ITEM_PREFIX = "intro_type_"
INTRO_PET_BREED_ITEM_PREFIX = "intro_breed_"

def intro_type_item(value: str) -> str:
    return f"{INTRO_PET_TYPE_ITEM_PREFIX}{value}"

def intro_breed_item(value: str) -> str:
    return f"{INTRO_PET_BREED_ITEM_PREFIX}{value}"

# TEXT
INTRO_PET_NAME_TEXT = "intro_textField_name"
INTRO_PET_AGE_TEXT = "intro_textField_age"

# SWITCH
INTRO_PET_GENDER_SWITCH = "intro_sw_gender"
INTRO_PET_AGE_OR_BDAY_SWITCH = "intro_sw_age_bday"
INTRO_PET_FIXED_SWITCH = "intro_sw_fixed"

# BUTTON
INTRO_PET_IMAGE_BUTTON = "intro_btn_image"
INTRO_SKIP_BUTTON = "intro_btn_skip"
INTRO_NEXT_BUTTON = "intro_btn_next"
INTRO_DONE_BUTTON = "intro_btn_done"
INTRO_PET_BDAY_BUTTON = "intro_btn_bday"


### HOME PAGE
HOME_PET_DATA_TEXT = "home_text_pet_data"