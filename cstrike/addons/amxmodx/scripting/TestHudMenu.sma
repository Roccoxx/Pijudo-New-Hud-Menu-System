#include <amxmodx>
#include <hudmenu>

#pragma semicolon 1

new g_iStaticHudMenu;

public plugin_init(){
	register_plugin("Testing Hud Menues", "1.0", "Roccoxx");

	register_clcmd("say probando", "clcmdTest");

	register_clcmd("say probando2", "ShowMenuPlayers");

	CreateStaticHudMenu();
}

CreateStaticHudMenu(){
	g_iStaticHudMenu = hud_menu_create_title("Quien es el más pijudo?", 0, 255, 0);
	hud_menu_register("Quien es el más pijudo?", "hud_menu_test");

	hud_menu_additem(g_iStaticHudMenu, "Roccoxx", "-", 255, 0, 0);
	hud_menu_additem(g_iStaticHudMenu, "Metita", "2", 0, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Manu", "3", 255, 255, 255);
	hud_menu_additem(g_iStaticHudMenu, "Federicomb", "4", 0, 0, 255);
	hud_menu_additem(g_iStaticHudMenu, "Metalicross", "5", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Skylar", "6", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Hypnotize", "7", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Totopizza", "8", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Matias_Esf", "9", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Hud", "10", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Neeeeeeeeeeeeeeeeeel.-", "11", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Flys", "12", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "MarioAR", "13", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "R0ma'", "14", 255, 255, 0);
	hud_menu_additem(g_iStaticHudMenu, "Kikizon", "15", 255, 255, 0);
}

public clcmdTest(const iClient){
	hud_menu_display(iClient, g_iStaticHudMenu, 0);
}

public hud_menu_test(iClient, iKey)
{
	if(!is_user_connected(iClient)){
		hud_menu_destroy(iClient, 1);
		return PLUGIN_HANDLED;
	}

	if(iKey == 9){
		hud_menu_destroy(iClient, 1);
		return PLUGIN_HANDLED;
	}

	if(iKey == 7){
		hud_menu_back_page(iClient);
		return PLUGIN_HANDLED;
	}

	if(iKey == 8){
		hud_menu_next_page(iClient);
		return PLUGIN_HANDLED;
	}

	new iMenu = hud_menu_get_menu_index(iClient);

	if(iKey >= hud_menu_get_page_max_items()){
		hud_menu_display(iClient, iMenu, hud_menu_get_page(iClient));
		return PLUGIN_HANDLED;
	}

	new iOption = hud_menu_get_selected_option(iClient, iKey);

	if(iOption >= hud_menu_get_max_items(iMenu)){
		hud_menu_display(iClient, iMenu, hud_menu_get_page(iClient));
		return PLUGIN_HANDLED;
	}

	new szItem[100]; hud_menu_get_item_name(iMenu, iOption, szItem, charsmax(szItem));

	new szName[32]; get_user_name(iClient, szName, charsmax(szName));

	client_print(0, print_chat, "%s Elegio la opcion #%d: %s", szName, iOption, szItem);
	hud_menu_destroy(iClient, 1);
	return PLUGIN_HANDLED;
}

public ShowMenuPlayers(const iClient){
	new iMenu = hud_menu_create_title("Menu de jugadores", 255, 0, 255);

	hud_menu_register("Menu de jugadores", "MenuPlayers");

	new szPos[4], szName[32];
	for(new i = 1; i <= MAX_PLAYERS; i++){
		if(!is_user_connected(i)) continue;

		get_user_name(i, szName, charsmax(szName));
		num_to_str(i, szPos, charsmax(szPos));
		hud_menu_additem(iMenu, szName, szPos, 0, 255, 255);
	}
	
	hud_menu_display(iClient, iMenu, 0);
}

public MenuPlayers(iClient, iKey)
{
	if(!is_user_connected(iClient)){
		hud_menu_destroy(iClient, 0);
		return PLUGIN_HANDLED;
	}

	if(iKey == 9){
		hud_menu_destroy(iClient, 0);
		return PLUGIN_HANDLED;
	}

	if(iKey == 7){
		hud_menu_back_page(iClient);
		return PLUGIN_HANDLED;
	}

	if(iKey == 8){
		hud_menu_next_page(iClient);
		return PLUGIN_HANDLED;
	}

	new iMenu = hud_menu_get_menu_index(iClient);

	if(iKey >= hud_menu_get_page_max_items()){
		hud_menu_display(iClient, iMenu, hud_menu_get_page(iClient));
		return PLUGIN_HANDLED;
	}

	new iOption = hud_menu_get_selected_option(iClient, iKey);

	if(iOption >= hud_menu_get_max_items(iMenu)){
		hud_menu_display(iClient, iMenu, hud_menu_get_page(iClient));
		return PLUGIN_HANDLED;
	}

	new szItem[100]; hud_menu_get_item_name(iMenu, iOption, szItem, charsmax(szItem));
	new szName[32]; get_user_name(iClient, szName, charsmax(szName));

	client_print(0, print_chat, "%s Elegio al jugador: %s", szName, szItem);
	hud_menu_destroy(iClient, 0);
	return PLUGIN_HANDLED;
}