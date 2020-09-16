#if defined _hudmenu_included
	#endinput
#endif

#define _hudmenu_included

#include <amxmisc>

// DON'T TOUCH
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

#define hud_menu_register(%0,%1) register_menu(%0, KEYSMENU, %1, 1)

// GET MENU INDEX
native hud_menu_get_menu_index(const iClient);

// CREATE MENU TITLE
native hud_menu_create_title(const szText[], const iRed, const iGreen, const iBlue, const Float:fPosX = 0.0, const Float:fPosY = 0.4);

// DESTROY MENU
native hud_menu_destroy(const iClient, const iStatic);

// GET MENU PAGE
native hud_menu_get_page(const iClient);

// BACK PAGE
native hud_menu_back_page(const iClient);

// NEXT PAGE
native hud_menu_next_page(const iClient);

// GET ITEM INDEX
native hud_menu_get_selected_option(const iClient, iKey);

// GET MAX MENU ITEMS
native hud_menu_get_max_items(const iMenu);

// GET MAX MENU ITEMS PER PAGE
native hud_menu_get_page_max_items()

// GET ITEM NAME
native hud_menu_get_item_name(const iMenu, const iItem, szItem[], const iItemLenght);

// ADD ITEM TO THE MENU
native hud_menu_additem(const iMenu, const szText[], const szPos[], const iRed = 255, const iGreen = 255, const iBlue = 255);

// DISPLAY MENU
native hud_menu_display(const iClient, const iMenu, iPage);