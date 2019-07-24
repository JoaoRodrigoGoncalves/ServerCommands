#pragma semicolon 1

#define PLUGIN_VERSION "3.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma newdecls required

char CONFIG_PATH[PLATFORM_MAX_PATH];
char completeCommand[128];
int commandCarry;
Handle debugMode;
ArrayList commandsArray;
ArrayList phrasesArray;

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
	debugMode = CreateConVar("serverCommands_debug", "0", "Enables or disables the debug option");
	AutoExecConfig(true, "plugin.ServerCommands");
	LoadTranslations("ServerCommands.phrases");
	BuildPath(Path_SM, CONFIG_PATH, sizeof(CONFIG_PATH), "configs/ServerCommands.cfg");
	RegConsoleCmd("sm_comandos", CommandsMenu);
	RegConsoleCmd("sm_commands", CommandsMenu);
}

public void OnMapStart()
{
	commandsArray = new ArrayList(ByteCountToCells(128));
	phrasesArray = new ArrayList(ByteCountToCells(128));
	
	KeyValues kv = new KeyValues("ServerCommands");
	kv.ImportFromFile(CONFIG_PATH);
	
	if(!kv.GotoFirstSubKey())
	{
		delete kv;
		SetFailState("[ServerCommands] %t", "cant read from config file");
	}
	
	char commandNameBuffer[128];
	char commandDescBuffer[128];
	
	do
	{
		kv.GetString("commandName", commandNameBuffer, 127);
		kv.GetString("commandDescription", commandDescBuffer, 127, "");
		
		commandsArray.PushString(commandNameBuffer);
		phrasesArray.PushString(commandDescBuffer);
		
	} while (kv.GotoNextKey());
	
	delete kv;
	
	if(GetConVarInt(debugMode) == 1)
	{
		int i;
		PrintToServer("[ServerCommands] %t", "Loading commands list");
		for (i = 0; i < commandsArray.Length; i++)
		{
			char commandFromArray[128];
			char descFromArray[128];
			commandsArray.GetString(i, commandFromArray, 127);
			phrasesArray.GetString(i, descFromArray, 127);
			PrintToServer("[%i] %s - %s", i, commandFromArray, descFromArray);
		}
		PrintToServer("[ServerCommands] %t", "Finished loading commands list");
	}
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

public Action CommandsMenu(int client, int agrs)
{	
	Menu commands = new Menu(CommandMenuHandler);
	commands.SetTitle("%t", "commands");
	
	if(commandsArray.Length != 0)
	{
		int i;
		for (i = 0; i < commandsArray.Length; i++)
		{
			char commandClean[128];
			char userFriendlyCommand[128];
			char itemID[128];
			commandsArray.GetString(i, commandClean, 127);
			Format(userFriendlyCommand, 127, "!%s", commandClean);
					
			IntToString(i, itemID, 127);
			commands.AddItem(itemID, userFriendlyCommand, ITEMDRAW_DEFAULT);
		}
	}
	else
	{
		char noCommand[128];
		Format(noCommand, 127, "%t", "noCommand");
		commands.AddItem("", noCommand, ITEMDRAW_DISABLED);
	}

	commands.ExitButton = true;
	commands.Display(client, 50);
	
	
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
				commandsArray.GetString(commandCarry, command, 127);
				Format(completeCommand, 127, "sm_%s", command);
				ClientCommand(client, completeCommand);
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

Menu CustomMenu(int client, int command)
{
	if(client){} //To suppress warnings
	
	Menu info = new Menu(CustomMenuHandler);
	char commandClean[128];
	commandsArray.GetString(command, commandClean, 127);
	info.SetTitle("!%s", commandClean);
		 
	char infoText[128];
	phrasesArray.GetString(command, infoText, 127);
	 
	info.AddItem("info", infoText, ITEMDRAW_DISABLED);
	 
	commandCarry = command;
	char runCommand[128];
	Format(runCommand, 127, "%t", "runCommand");
	info.AddItem("exec", runCommand, ITEMDRAW_DEFAULT);
	
	info.ExitBackButton = true;
	info.ExitButton = true;
	
	return info;
}
