#pragma semicolon 1

#define DEBUG

#define PLUGIN_VERSION "2.1"

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma newdecls required

char CONFIG_PATH[PLATFORM_MAX_PATH];
char comandoCompleto[128];
int commandCarry;
ArrayList arrayComandos;
ArrayList tempPhrases;

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
	CreateConVar("serverCommands_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY|FCVAR_REPLICATED);
	LoadTranslations("ServerCommands.phrases");
	BuildPath(Path_SM, CONFIG_PATH, sizeof(CONFIG_PATH), "configs/ServerCommands.cfg");
	RegConsoleCmd("sm_comandos", MenuComandos);
	RegConsoleCmd("sm_commands", MenuComandos);
}

public void OnMapStart()
{
	arrayComandos = new ArrayList(ByteCountToCells(128));
	tempPhrases = new ArrayList(ByteCountToCells(128));
	
	KeyValues kv = new KeyValues("ServerCommands");
	kv.ImportFromFile(CONFIG_PATH);
	
	if(!kv.GotoFirstSubKey())
	{
		delete kv;
		SetFailState("[ServerCommands] Cannot read from ServerCommands.cfg file. Plugin Halted!");
	}
	
	char commandNameBuffer[128];
	char commandDescBuffer[128];
	
	do
	{
		kv.GetString("commandName", commandNameBuffer, 127);
		kv.GetString("commandDescription", commandDescBuffer, 127, "");
		
		arrayComandos.PushString(commandNameBuffer);
		tempPhrases.PushString(commandDescBuffer);
		
	} while (kv.GotoNextKey());
	
	delete kv;
	
	int i;
	PrintToServer("[SM] Loading commands list");
	for (i = 0; i < arrayComandos.Length; i++)
	{
		char stringFromArray[128];
		char descFromArray[128];
		arrayComandos.GetString(i, stringFromArray, 127);
		tempPhrases.GetString(i, descFromArray, 127);
		PrintToServer("[%i] %s - %s", i, stringFromArray, descFromArray);
	}
	PrintToServer("[SM] Finished loading commands list");
	
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
	comandos.SetTitle("%t", "commands");
	
	if(arrayComandos.Length != 0)
	{
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
	}
	else
	{
		char noCommand[128];
		Format(noCommand, 127, "%t", "noCommand");
		comandos.AddItem("", noCommand, ITEMDRAW_DISABLED);
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
		 
	char infoText[128];
	tempPhrases.GetString(comando, infoText, 127);
	 
	info.AddItem("info", infoText, ITEMDRAW_DISABLED);
	 
	commandCarry = comando;
	char runCommand[128];
	Format(runCommand, 127, "%t", "runCommand");
	info.AddItem("exec", runCommand, ITEMDRAW_DEFAULT);
	
	info.ExitBackButton = true;
	info.ExitButton = true;
	
	return info;
}
