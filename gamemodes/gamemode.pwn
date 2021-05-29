
#include <a_samp>
#include <DOF2>

// --- Defines Dialog --

#define DIALOG_LOGIN 		0
#define DIALOG_REGISTER 	1
#define DIALOG_WELCOME      2

// -- Defines Folders --

#define FOLDER_ACCOUNT      "Contas/%s.ini"

// -- Others --

#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
 
enum p_Info {
	p_Money,
	p_LevelStaff,
	p_Password[50]
}

static const Float: randomSpawn[][] = {
	{ 1479.5145, -1674.2843, 14.0469, 180.5089 },
	{ -373.6476, 1576.1531, 76.0177, 138.1406 }
};

new playerInfo[MAX_PLAYERS][p_Info];

main()
{
	print("\n----------------------------------");
	print(" ZonePerfect v1.0 ");
	print("	Fundador: Fear \n");
	print("	Desenvolvedor: FerrariL \n");
	print("\n----------------------------------");
}

public OnGameModeInit()
{
	SetGameModeText("Blank Script");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	clearChat(playerid);
	
	SendClientMessage(playerid, -1, "{fcfcfc}| ZP | A Equipe {5085d9}ZonePerfect {fcfcfc}agradece sua preferencia!");
	
	verifyLogin(playerid);
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	DOF2_Exit();
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_REGISTER:
	    {
	        if(!response)
			{
				Kick(playerid);
	        }
	        else
	        {
	            if(isnull(inputtext))
	            {
	                showDialogRegister(playerid, "Necessario preencher o campo de senha!");
	            }
	            else if(strlen(inputtext) < 4 || strlen(inputtext) > 50)
	            {
	                showDialogRegister(playerid, "Sua senha deve conter no minimo 4 caracteres e no maximo 50!");
	            }
	            else
	            {
	                new message[195 + MAX_PLAYER_NAME];
	                
	                format(message, sizeof(message), "{fcfcfc}Parabens {32a852}%s, {fcfcfc}voce concluiu seu registro com sucesso e ja podera se divertir :)\n\n{cfd0d1}OBS: Guarde sua senha com cuidado, pois sera com ela que voce acessara sua conta!", getPlayerName(playerid));
	                
	                createAccount(playerid, inputtext);
	                
					ShowPlayerDialog(playerid, DIALOG_WELCOME, DIALOG_STYLE_MSGBOX, "Parabens", message, "Iniciar", "");
	            }
	        }
	    }
	    case DIALOG_WELCOME:
	    {
	        if(response)
	        {
	            spawnPlayerAfterLogin(playerid);
	        }
	    }
	}
	
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// -- Functions --
	
getTotalPlayersOnline()
{
	new total = 0;
	
	for(new i = 0, last = GetMaxPlayers(); i < last; i ++)
	{
	    if(IsPlayerConnected(i))
	    {
	        total ++;
	    }
	}
	
	return total;
}

spawnPlayerAfterLogin(playerid)
{
	new messageAll[144];
	
	format(messageAll, sizeof(messageAll), "{cfd0d1}| SERVER | O(a) jogador(a) %s conectou-se ao servidor (%d/%d)", getPlayerName(playerid), getTotalPlayersOnline(), GetMaxPlayers());
	
	SendClientMessageToAll(-1, messageAll);
	
    SendClientMessage(playerid, -1, "{fcfcfc}| LOGIN | Login realizado com sucesso!");
    
    SpawnPlayer(playerid);
    
	setPlayerRandomPos(playerid);
}

setPlayerRandomPos(playerid)
{
    new index = random(sizeof(randomSpawn));

    SetPlayerPos(playerid, randomSpawn[index][0], randomSpawn[index][1], randomSpawn[index][2]);
}

createAccount(playerid, password[]) {
	DOF2_CreateFile(getPlayerAccount(playerid));
	
	playerInfo[playerid][p_Money] = 200;
	playerInfo[playerid][p_LevelStaff] = 0;
	
	format(playerInfo[playerid][p_Password], 50, "%s", password);
	
	DOF2_SetInt(getPlayerAccount(playerid), "money", playerInfo[playerid][p_Money]);
	DOF2_SetInt(getPlayerAccount(playerid), "level_staff", playerInfo[playerid][p_LevelStaff]);
	DOF2_SetString(getPlayerAccount(playerid), "password", playerInfo[playerid][p_Password]);
	
	GivePlayerMoney(playerid, playerInfo[playerid][p_Money]);
}

getPlayerName(playerid)
{
	static name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));

	return name;
}

getPlayerAccount(playerid)
{
	static stringFormatted[MAX_PLAYER_NAME + 13];

	format(stringFormatted, sizeof(stringFormatted), FOLDER_ACCOUNT, getPlayerName(playerid));

	return stringFormatted;
}

clearChat(playerid)
{
	for(new i = 0; i < 20; i ++)
	{
	    SendClientMessage(playerid, -1, "");
	}
}

defaultMessage(playerid, accountExists)
{
	new stringFormatted[120 + 15 + MAX_PLAYER_NAME + 6], statusAccount[15];

	format(statusAccount, sizeof(statusAccount), "%s", accountExists ? ("Registrada") : ("Nao registrada"));

	format(stringFormatted, sizeof(stringFormatted), "\n\n{fcfcfc}Status da Conta: {cfd0d1}%s \n\n{fcfcfc}Discord: {cfd0d1}discord.gg/pQazmUVcJF \n\n{fcfcfc}Nick: {cfd0d1}%s\n\n{a84632}", statusAccount, getPlayerName(playerid));

	return stringFormatted;
}

showDialogRegister(playerid, error[] = "")
{
	new messageDialog[165 + 158 + MAX_PLAYER_NAME + 80];

  	format(messageDialog, sizeof(messageDialog), "{fcfcfc}Ola {32a852}%s {fcfcfc}seja bem vindo a {799dc9}ZonePerfect\n{fcfcfc}Verificamos que sua conta nao esta cadastrada, realize o cadastro para continuar.", getPlayerName(playerid));

	strcat(messageDialog, defaultMessage(playerid, false));

	if(strlen(error) > 0)
	{
		strcat(messageDialog, error);
	}

	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registro", messageDialog, "Registrar", "Sair");
}

showDialogLogin(playerid, error[] = "")
{
	new messageDialog[165 + 160 + MAX_PLAYER_NAME + 80];

	format(messageDialog, sizeof(messageDialog), "{fcfcfc}Ola {32a852}%s {fcfcfc}seja bem vindo a {799dc9}ZonePerfect\n{fcfcfc}Sua conta se encontra registrada em nosso servidor, realize o login para continuar.", getPlayerName(playerid));

	strcat(messageDialog, defaultMessage(playerid, true));

	if(strlen(error) > 0)
	{
		strcat(messageDialog, error);
	}

	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", messageDialog, "Login", "Sair");
}

verifyLogin(playerid)
{
	if(DOF2_FileExists(getPlayerAccount(playerid)))
	{
	    showDialogLogin(playerid);
	}
	else
	{
	    showDialogRegister(playerid);
	}
}

