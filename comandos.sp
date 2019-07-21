#pragma semicolon 1

#define DEBUG

#define PLUGIN_VERSION "1.0"
#define CONFIG_FILE "";

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

#pragma newdecls required

char comandoCompleto[128];
int commandCarry;
ArrayList arrayComandos;
ArrayList tempPhrases;
//static KVPath[PLATFORM_MAX_PATH];

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "[CS:GO/CSS] Server Commands",
	author = "JoaoRodrigoGamer",
	description = "Server Commands Menu",
	version = PLUGIN_VERSION,
	url = "https://joaogoncalves.myftp.org"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	//BuildPath(Path_SM, KVPath, sizeof(KVPath), "configs/serverCommandsList.txt");
	RegConsoleCmd("sm_comandos", MenuComandos);
	RegConsoleCmd("sm_commands", MenuComandos);
}

public void OnMapStart()
{
	arrayComandos = new ArrayList(ByteCountToCells(128));
	//TO-DO: Get rid of these PushStrings and create a config file to get the information from
	arrayComandos.PushString("credits");
	arrayComandos.PushString("discord");
	arrayComandos.PushString("gloves");
	arrayComandos.PushString("grupo");
	arrayComandos.PushString("knife");
	arrayComandos.PushString("mm");
	arrayComandos.PushString("quake");
	arrayComandos.PushString("rankme");
	arrayComandos.PushString("resetmyrank");
	arrayComandos.PushString("roleta");
	arrayComandos.PushString("rs");
	arrayComandos.PushString("shop");
	arrayComandos.PushString("trade");
	arrayComandos.PushString("vip");
	arrayComandos.PushString("vipspawn");
	arrayComandos.PushString("ws");
	int i;
	PrintToServer("[SM] Loading commands list");
	for (i = 0; i < arrayComandos.Length; i++)
	{
		char stringFromArray[128];
		arrayComandos.GetString(i, stringFromArray, 127);
		PrintToServer("[%i] %s", i, stringFromArray);
	}
	PrintToServer("[SM] Finished loading the commands list");
	tempPhrases = new ArrayList(ByteCountToCells(128));
	tempPhrases.PushString("Mostra quantos creditos é que tens!");
	tempPhrases.PushString("Mostra o link do nosso discord!");
	tempPhrases.PushString("Escolhe umas gloves!");
	tempPhrases.PushString("Mostra o lonk do nosso grupo Steam!");
	tempPhrases.PushString("Escolhe uma faca!");
	tempPhrases.PushString("Mostra os pontos para o próximo rank!");
	tempPhrases.PushString("Menu de configuração dos sons do QUAKE!");
	tempPhrases.PushString("Mostra os teus pontos!");
	tempPhrases.PushString("Dá reset ao teu rank!");
	tempPhrases.PushString("Aposta os teus créditos!");
	tempPhrases.PushString("Dá reset á tua score da tabela de pontuações!");
	tempPhrases.PushString("A loja do Servidor!");
	tempPhrases.PushString("Troca créditos com outros jogadores!");
	tempPhrases.PushString("Preços dos VIPs!");
	tempPhrases.PushString("[VIP] Dá respawn!");
	tempPhrases.PushString("Escolhe uma skin para a tua arma!");
}

public int CommandMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			CustomMenu(client, selection).Display(client, 90);
		}
		
		case MenuAction_Cancel:
		{
			delete menu;
		}
	}
}

public Action MenuComandos(int client, int agrs)
{	
	Menu comandos = new Menu(CommandMenuHandler);
	comandos.SetTitle("Comandos");
	
	int i;
	for (i = 0; i < arrayComandos.Length; i++)
	{
		char stringFromArray[128];
		char userFriendlyCommand[128];
		char itemID[128];
		arrayComandos.GetString(i, stringFromArray, 127);
		Format(userFriendlyCommand, 127, "!%s", stringFromArray);
		Format(itemID, 127, "%i", StringToInt(stringFromArray));
		
		comandos.AddItem(itemID, userFriendlyCommand, ITEMDRAW_DEFAULT);
	}

	comandos.ExitButton = true;
	comandos.Display(client, 50);
	
	
	return Plugin_Handled;
}

public int CustomMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char command[128];
				arrayComandos.GetString(commandCarry, command, 127);
				Format(comandoCompleto, 127, "sm_%s", command);
				//PrintToConsole(client, "[commands.smx] Carry: %i. Command: %s. CommandComplete: %s.", commandCarry, command, comandoCompleto);
				ClientCommand(client, comandoCompleto);
			}
		}
		
		case MenuAction_Cancel:
		{
			delete menu;
		}
		
		default:
		{
			delete menu;
		}
	}
}

Menu CustomMenu(int client, int comando)
{
	
	Menu info = new Menu(CustomMenuHandler);
	char stringFromArray[128];
	arrayComandos.GetString(comando, stringFromArray, 127);
	info.SetTitle("!%s", stringFromArray);
	
	/*TO-DO: Add a description about the selected command 
	 * (Description coming from the config file)	
	 */
	 
	 char infoText[128];
	 tempPhrases.GetString(comando, infoText, 127);
	 
	 info.AddItem("info", infoText, ITEMDRAW_DISABLED);
	 
	 
	commandCarry = comando;
	info.AddItem("exec", "Executar", ITEMDRAW_DEFAULT);
	
	info.ExitBackButton = true;
	info.ExitButton = true;
	
	return info;
}