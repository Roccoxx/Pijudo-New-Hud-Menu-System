#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <engine>

#pragma semicolon 1

new const szName[] = "Hud Menu";
new const szVersion[] = "1.0";
new const szAuthor[] = "Roccoxx";

/* DON'T MODIFY */
#define MAX_LENGHT_TITLE 100
#define MAX_LENGHT_ITEM 60
/* END */

#define MAX_ITEMS_PER_PAGE 4 // MAX 6
#define MAX_MENU_COUNT 100 // 1 MENU PER PLAYER = 33 + Statics MENUES
#define MAX_ITEMS_COUNT 50

new const Float:fItemPositionYDiff[] = {
    0.05, 0.08, 0.11, 0.14
};

const MENU_NONE = -1;

enum _:MENU_TITLE_DATA
{
    MENU_TITLE_TEXT[MAX_LENGHT_TITLE],
    MENU_HANDLER[100],
    MENU_TITLE_RED,
    MENU_TITLE_GREEN,
    MENU_TITLE_BLUE,
    Float:MENU_POS_X,
    Float:MENU_POS_Y
}

enum _:MENU_ITEM_DATA
{
    MENU_ITEM_TEXT[MAX_LENGHT_ITEM],
    MENU_ITEM_POS[4],
    MENU_ITEM_RED,
    MENU_ITEM_GREEN,
    MENU_ITEM_BLUE
}

new Array:g_MenuTitle, Array:g_MenuItems[MAX_MENU_COUNT];

new g_iMenuCount, g_iItemCount[MAX_MENU_COUNT];

new g_iMenuDisplay[33] = {-1, ...}, g_iMenuPage[33];

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

public plugin_init(){
	register_plugin(szName, szVersion, szAuthor);

	g_MenuTitle = ArrayCreate(MENU_TITLE_DATA);

	new iEnt = create_entity("info_target");
	if(is_valid_ent(iEnt)){
		RegisterHamFromEntity(Ham_Think, iEnt, "HudMenuEntity");
		entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 5.0);
	}
}

public plugin_end(){
	ArrayDestroy(g_MenuTitle);
	for(new i; i < MAX_MENU_COUNT; i++) ArrayDestroy(g_MenuItems[i]);
}

public plugin_natives(){
	register_native("hud_menu_get_menu_index", "hud_menu_get_menu_index", 1);
	register_native("hud_menu_destroy", "hud_menu_destroy", 1);
	register_native("hud_menu_get_page", "hud_menu_get_page", 1);
	register_native("hud_menu_back_page", "hud_menu_back_page", 1);
	register_native("hud_menu_next_page", "hud_menu_next_page", 1);
	register_native("hud_menu_get_selected_option", "hud_menu_get_selected_option", 1);
	register_native("hud_menu_get_max_items", "hud_menu_get_max_items", 1);
	register_native("hud_menu_get_item_name", "hud_menu_get_item_name", 1);
	register_native("hud_menu_create_title", "hud_menu_create_title", 1);
	register_native("hud_menu_additem", "hud_menu_additem", 1);
	register_native("hud_menu_display", "hud_menu_display", 1);
	register_native("hud_menu_get_page_max_items", "hud_menu_get_page_max_items", 1);
}

public client_putinserver(id){
	g_iMenuDisplay[id] = MENU_NONE; g_iMenuPage[id] = 0;
}

public hud_menu_get_page_max_items() return MAX_ITEMS_PER_PAGE;
public hud_menu_get_page(const iClient) return g_iMenuPage[iClient];

public hud_menu_back_page(const iClient){
	if(g_iMenuPage[iClient] > 0) hud_menu_display(iClient, g_iMenuDisplay[iClient], (g_iMenuPage[iClient]-1));
	else hud_menu_display(iClient, g_iMenuDisplay[iClient], g_iMenuPage[iClient]);
}

public hud_menu_next_page(const iClient){
	new iPagesCount = (g_iItemCount[g_iMenuDisplay[iClient]] / MAX_ITEMS_PER_PAGE);
	if(g_iMenuPage[iClient] < iPagesCount) hud_menu_display(iClient, g_iMenuDisplay[iClient], (g_iMenuPage[iClient]+1));
	else hud_menu_display(iClient, g_iMenuDisplay[iClient], g_iMenuPage[iClient]);
}

public hud_menu_get_selected_option(const iClient, iKey){
	if(g_iMenuPage[iClient] > 0) iKey = (iKey + (g_iMenuPage[iClient] * MAX_ITEMS_PER_PAGE));

	return iKey;
}

public hud_menu_destroy(const iClient, const iStatic){
	if(!iStatic){
		new iMenu = g_iMenuDisplay[iClient];

		ArrayDeleteItem(g_MenuTitle, iMenu);

		new iLastMenu = iMenu;

		for(new iMenuIndex; iMenuIndex < MAX_MENU_COUNT; iMenuIndex++){
			// EMPTY MENU
			if(g_iItemCount[iMenuIndex] == 0) continue;

			if(iMenuIndex > iMenu){
				iLastMenu = iMenuIndex;

				g_iItemCount[iMenuIndex-1] = g_iItemCount[iMenuIndex];
				g_MenuItems[iMenuIndex-1] = ArrayClone(g_MenuItems[iMenuIndex]);
			}
		}

		ArrayDestroy(g_MenuItems[iLastMenu]);
		g_iItemCount[iLastMenu] = 0;

		for(new iPlayers = 1; iPlayers <= MAX_PLAYERS; iPlayers++){
			if(!is_user_connected(iPlayers) || iClient == iPlayers) continue;

			if(g_iMenuDisplay[iPlayers] > g_iMenuDisplay[iClient]) g_iMenuDisplay[iPlayers]--;
		}

		g_iMenuCount--;
	}

	g_iMenuDisplay[iClient] = MENU_NONE; g_iMenuPage[iClient] = 0;
}

public hud_menu_get_menu_index(const iClient) return g_iMenuDisplay[iClient];

public hud_menu_get_max_items(const iMenu) return g_iItemCount[iMenu];

public hud_menu_get_item_name(const iMenu, const iItem, szItem[], const iItemLenght){
	new iDataItem[MENU_ITEM_DATA]; ArrayGetArray(g_MenuItems[iMenu], iItem, iDataItem);

	param_convert(3); copy(szItem, iItemLenght, iDataItem[MENU_ITEM_TEXT]);
}

public hud_menu_create_title(const szText[], const iRed, const iGreen, const iBlue, const Float:fPosX, const Float:fPosY){
	if(g_iMenuCount >= MAX_MENU_COUNT){
		log_amx("You can create only %d menues!", MAX_MENU_COUNT);
		return PLUGIN_HANDLED;
	}

	param_convert(1);

	if(strlen(szText) > MAX_LENGHT_TITLE){
		log_amx("Maximum %d Chracters!", MAX_LENGHT_TITLE);
		return PLUGIN_HANDLED;
	}

	new iData[MENU_TITLE_DATA];
	copy(iData[MENU_TITLE_TEXT], charsmax(iData), szText);
	iData[MENU_TITLE_RED] = iRed; iData[MENU_TITLE_GREEN] = iGreen; iData[MENU_TITLE_BLUE] = iBlue;
	iData[MENU_POS_X] = fPosX;
	iData[MENU_POS_Y] = fPosY;

	g_MenuItems[g_iMenuCount] = ArrayCreate(MENU_ITEM_DATA);

	g_iMenuCount++;
	
	return ArrayPushArray(g_MenuTitle, iData);
}

public hud_menu_additem(const iMenu, const szText[], const szPos[], const iRed, const iGreen, const iBlue){
	if(g_iItemCount[iMenu] >= MAX_ITEMS_COUNT){
		log_amx("You can create only %d items per menu!", MAX_ITEMS_COUNT);
		return;
	}

	param_convert(2);

	if(strlen(szText) > MAX_LENGHT_ITEM){
		log_amx("Maximum %d Chracters!", MAX_LENGHT_ITEM);
		return;
	}

	param_convert(3);

	g_iItemCount[iMenu]++;

	new iData[MENU_ITEM_DATA];
	copy(iData[MENU_ITEM_TEXT], charsmax(iData), szText); copy(iData[MENU_ITEM_POS], charsmax(iData), szPos);
	iData[MENU_ITEM_RED] = iRed; iData[MENU_ITEM_GREEN] = iGreen; iData[MENU_ITEM_BLUE] = iBlue;
	ArrayPushArray(g_MenuItems[iMenu], iData);
}

public hud_menu_display(const iClient, const iMenu, iPage){
	if(iPage > (g_iItemCount[iMenu] / MAX_ITEMS_PER_PAGE)) iPage = 0;

	g_iMenuDisplay[iClient] = iMenu; g_iMenuPage[iClient] = iPage;

	new iDataTitle[MENU_TITLE_DATA]; ArrayGetArray(g_MenuTitle, iMenu, iDataTitle);
	show_menu(iClient, KEYSMENU, "^n", -1, iDataTitle[MENU_TITLE_TEXT]);
}

ShowHudMenu(const iClient, const iMenu, const iPage){
	static iDataTitle[MENU_TITLE_DATA]; ArrayGetArray(g_MenuTitle, iMenu, iDataTitle);
	
	set_dhudmessage(iDataTitle[MENU_TITLE_RED], iDataTitle[MENU_TITLE_GREEN], iDataTitle[MENU_TITLE_BLUE], iDataTitle[MENU_POS_X], iDataTitle[MENU_POS_Y], 0, 1.0, 0.1, 0.1, 0.9);
	show_dhudmessage(iClient, iDataTitle[MENU_TITLE_TEXT]);

	static iStart; iStart = (MAX_ITEMS_PER_PAGE * iPage); static iEnd; iEnd = (MAX_ITEMS_PER_PAGE * (iPage + 1));
	if(iEnd > g_iItemCount[iMenu]) iEnd = g_iItemCount[iMenu];

	static iDataItem[MENU_ITEM_DATA], iPosition; iPosition = 0;

	static i;
	for(i = iStart; i < iEnd; i++){
		ArrayGetArray(g_MenuItems[iMenu], i, iDataItem);

		set_dhudmessage(iDataItem[MENU_ITEM_RED], iDataItem[MENU_ITEM_GREEN], iDataItem[MENU_ITEM_BLUE], iDataTitle[MENU_POS_X], 
		iDataTitle[MENU_POS_Y]+fItemPositionYDiff[iPosition], 0, 1.0, 0.1, 0.1, 1.0);
		if(iDataTitle[MENU_POS_X] == 1.0)
			show_dhudmessage(iClient, "^n%s %s", iDataItem[MENU_ITEM_TEXT], iDataItem[MENU_ITEM_POS]);
		else
			show_dhudmessage(iClient, "^n%s %s", iDataItem[MENU_ITEM_POS], iDataItem[MENU_ITEM_TEXT]);

		iPosition++;
	}

	static iPagesCount; iPagesCount = (g_iItemCount[iMenu] / MAX_ITEMS_PER_PAGE);

	static szBuffer[40];
	if(iDataTitle[MENU_POS_X] == 1.0){
		formatex(szBuffer, charsmax(szBuffer), "EXIT 0");

		if(iPage > 0) format(szBuffer, charsmax(szBuffer), "%s^nBACK 8", szBuffer);
		if(iPage < iPagesCount) format(szBuffer, charsmax(szBuffer), "%s^nNEXT 9", szBuffer);
    }
	else {
		formatex(szBuffer, charsmax(szBuffer), "0 EXIT");

		if(iPage > 0) format(szBuffer, charsmax(szBuffer), "%s^n8 BACK", szBuffer);
		if(iPage < iPagesCount) format(szBuffer, charsmax(szBuffer), "%s^n9 NEXT", szBuffer);
    }

	set_dhudmessage(255, 255, 255, iDataTitle[MENU_POS_X], iDataTitle[MENU_POS_Y] + fItemPositionYDiff[iPosition-1] + 0.1, 0, 1.0, 0.1, 0.1, 1.0);
	show_dhudmessage(iClient, szBuffer);
}

public HudMenuEntity(const iEnt){
	if(!is_valid_ent(iEnt)) return HAM_IGNORED;

	for(new iClient = 1; iClient <= MAX_PLAYERS; iClient++){
		if(!is_user_connected(iClient) || g_iMenuDisplay[iClient] == MENU_NONE) continue;

		ShowHudMenu(iClient, g_iMenuDisplay[iClient], g_iMenuPage[iClient]);
	}

	entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 1.0);
	return HAM_IGNORED;
}
