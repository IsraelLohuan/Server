
#include <a_samp>
#include <DOF2>
#include <sscanf>
#include <zcmd>

// --- Defines Dialog --

#define DIALOG_LOGIN 		0
#define DIALOG_REGISTER 	1
#define DIALOG_WELCOME      2
#define DIALOG_OPTION_SPAWN 3
#define DIALOG_ADMINS       4

// -- Defines Folders --

#define FOLDER_ACCOUNT      "Contas/%s.ini"
#define FOLDER_BANS         "Bans/%s.ini"
#define FOLDER_BANS_IP      "Bans/%s.ini"

// -- Others --

#define Minutes(%0) (1000 * %0 * 60)
#define Hours(%0) (1000 * %0 * 60 * 60)
#define Seconds(%0) (1000 * %0)

#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))

new __message[144];

#define SendClientMessageEx(%0,%1,%2,%3)             \
        (format(__message,sizeof(__message),%2,%3),SendClientMessage(%0,%1,__message))

#define SendClientMessageToAllEx(%0,%1,%2)             \
        (format(__message,sizeof(__message),%1,%2),SendClientMessageToAll(%0,__message))
        
#define COLOR_GREY    0xcfd0d1FF
#define COLOR_RED  	  0xb52410FF
#define COLOR_MAIN 	  0x799dc9FF
#define COLOR_WARNING 0xe05f38FF

#define MESSAGE_CMD_SUCESS  "| INFO | Comando executado com sucesso!"

enum p_Info {
	p_LevelStaff,
	p_Password[50],
	p_ErrorLogin,
	p_Notice,
	bool:p_isVotedInSurvey,
	bool:p_invisible,
	bool:p_ShutUp,
	bool:p_Frozen,
	bool:p_Spectating,
	Float:p_LastPosition[3],
}

enum s_Info {
	s_TimerMessages,
	bool:s_Locked,
	bool:s_AllFrozen
}

enum s_Survey {
	s_Title[128],
	s_VoteYes,
	s_VoteNo,
	bool:s_Created
}

enum {
	HELPER = 1,
	MODERATOR,
	COORDINATOR,
	MANAGER,
	FOUNDER
}

enum a_colors
{
	a_nameColor[40],
	a_colorHex
}

static const s_nameOffice[][] = {
	"Player",
	"Helper",
	"Coordenador",
	"Gerente",
	"Fundador"
};

static const Float: randomSpawn[][] = {
	{ 1479.5145, -1674.2843, 14.0469, 180.5089 },
	{ -373.6476, 1576.1531, 76.0177, 138.1406 }
};

static const colors[][a_colors] = {
	{ "amarelo", 0xf5f53bFF },
	{ "verde", 	 0x5be83fFF },
	{ "roxo", 	 0x4d567dFF },
	{ "preto",   0x24262bFF },
	{ "laranja", 0xeda828FF },
	{ "cinza",   0x858482FF },
	{ "branco",  0xfffefcFF }
};

static const messagesServer[][] = {
	{"{cfd0d1}| SERVER | {fcfcfc}Nossa equipe agradece sua preferencia, divirta-se :)"},
	{"{cfd0d1}| SERVER | {fcfcfc}Ainda nao esta em nosso discord? Acesse: {799dc9}discord.gg/pQazmUVcJF"},
	{"{cfd0d1}| SERVER | {fcfcfc}Precisa de ajuda? chame um de nossos staffs!"},
	{"{cfd0d1}| SERVER | {fcfcfc}Algum cheater? Alguma duvida? {799dc9}/admins"},
	{"{cfd0d1}| SERVER | {fcfcfc}Possuimos uma equipe pronta para te atender e garantir sua diversao!"},
	{"{cfd0d1}| SERVER | {fcfcfc}Bugs? Erros? relate em nosso discord: {799dc9}discord.gg/pQazmUVcJF"}
};

new playerInfo[MAX_PLAYERS][p_Info];

new server[s_Info];

new survey[s_Survey];

forward closedSurvey();
forward messageRandom();

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
	server[s_TimerMessages] = SetTimer("messageRandom", Seconds(30), true);
	
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
    SetPlayerPos(playerid, 2620.7007, 1717.2212, 11.0234);
    
	SetPlayerFacingAngle(playerid, 89.0025);
	
	SetPlayerCameraPos(playerid, 2616.5374, 1716.9574, 10.8203);
	
	SetPlayerCameraLookAt(playerid, 2616.5374, 1716.9574, 10.8203);
	
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
	desconectedPlayer(playerid);

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
	if(playerInfo[playerid][p_ShutUp])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce esta calado e nao pode falar no chat!");
	    
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

					ShowPlayerDialog(playerid, DIALOG_WELCOME, DIALOG_STYLE_MSGBOX, "Parabens", message, "Iniciar", "-");
	            }
	        }
	    }
	    case DIALOG_WELCOME:
	    {
	        if(response)
	        {
	            spawnPlayerAfterLogin(playerid);
	        }
			else
			{
			    new message[195 + MAX_PLAYER_NAME];

	            format(message, sizeof(message), "{fcfcfc}Parabens {32a852}%s, {fcfcfc}voce concluiu seu registro com sucesso e ja podera se divertir :)\n\n{cfd0d1}OBS: Guarde sua senha com cuidado, pois sera com ela que voce acessara sua conta!", getPlayerName(playerid));

	        	ShowPlayerDialog(playerid, DIALOG_WELCOME, DIALOG_STYLE_MSGBOX, "Parabens", message, "Iniciar", "-");
	        }
	    }
	    case DIALOG_LOGIN:
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
	            else if(!strcmp(DOF2_GetString(getPlayerAccount(playerid), "password"), inputtext))
	            {
					loadingAccount(playerid);

					ShowPlayerDialog(playerid, DIALOG_OPTION_SPAWN, DIALOG_STYLE_INPUT, "Escolha seu Spawn", "{799dc9}1. {fcfcfc}Voltar para ultima posicao que estava\n\n{799dc9}2. {fcfcfc}Spawn aleatorio", "Escolher", "-");
	            }
	            else
	            {
	            	new message[64];

					playerInfo[playerid][p_ErrorLogin] ++;
					
					if(playerInfo[playerid][p_ErrorLogin] == 3)
					{
					    Kick(playerid);
					}
					
					format(message, sizeof(message), "Senha incorreta, favor tente novamente!\n\nTentativas: %d de 3.", playerInfo[playerid][p_ErrorLogin]);
					
	            	showDialogLogin(playerid, message);
	            }
	        }
	    }
	    case DIALOG_OPTION_SPAWN:
	    {
	        if(response)
	        {
				if(isnull(inputtext))
				{
					ShowPlayerDialog(playerid, DIALOG_OPTION_SPAWN, DIALOG_STYLE_INPUT, "Escolha seu Spawn", "{799dc9}1. {fcfcfc}Voltar para ultima posicao que estava\n\n{799dc9}2. {fcfcfc}Spawn aleatorio", "Escolher", "-");
				}
				else
				{
				    new itemSelected = strval(inputtext);

				    switch(itemSelected)
				    {
				        case 1: spawnPlayerAfterLogin(playerid, true);
				        case 2: spawnPlayerAfterLogin(playerid, false);
				        default: ShowPlayerDialog(playerid, DIALOG_OPTION_SPAWN, DIALOG_STYLE_INPUT, "Escolha seu Spawn", "{799dc9}1. {fcfcfc}Voltar para ultima posicao que estava\n\n{799dc9}2. {fcfcfc}Spawn aleatorio", "Escolher", "-");
				    }
				}
	        }
			else
			{
	            ShowPlayerDialog(playerid, DIALOG_OPTION_SPAWN, DIALOG_STYLE_INPUT, "Escolha seu Spawn", "{799dc9}1. {fcfcfc}Voltar para ultima posicao que estava\n\n{799dc9}2. {fcfcfc}Spawn aleatorio", "Escolher", "-");
	        }
	    }
	}

	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// -- Commands --

CMD:avisar(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");
		
	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /avisar [id]");
	    
	new id = strval(params);
	
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");
		
	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	playerInfo[id][p_Notice] ++;
	
	if(playerInfo[id][p_Notice] == 3)
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | O(a) jogador(a) %s cumpriu 3 avisos e foi kickado!", getPlayerName(id));
	    SendClientMessageToAllEx(COLOR_MAIN, "| SERVER | O(a) jogador(a) %s cumpriu 3 avisos e foi kickado!", getPlayerName(id));
	    
	    Kick(id);
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce setou +1 aviso para o jogador %s", getPlayerName(id));
	    SendClientMessageEx(id, COLOR_GREY, "| INFO | O %s %s lhe setou 1 aviso, total: (%d/3). No ultimo aviso voce sera kickado!", getOfficePlayer(playerid), getPlayerName(playerid));
	}
	
	return 1;
}

CMD:kickar(playerid, params[])
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	new id, reason[30];
	
	if(sscanf(params, "ds[30]", id, reason))
	     return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /kickar [id] [motivo]");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(strlen(reason) > 30)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Motivo muito extenso!");

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s Kickou o jogador(a) %s, motivo: %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), reason);
	
	Kick(id);

	return 1;
}

CMD:tapa(playerid, params[])
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

    if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /tapa [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

    new Float:pos[3];
    
    GetPlayerPos(id, pos[0], pos[1], pos[2]);
    SetPlayerPos(id, pos[0], pos[1], pos[2] + 20);
    
    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce deu um tapa no jogador %s", getPlayerName(id));
    SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s deu um tapa em voce!", getPlayerName(playerid));
    
    return 1;
}

CMD:assistir(playerid, params[])
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

    if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /assistir [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	TogglePlayerSpectating(playerid, 1);
    PlayerSpectatePlayer(playerid, id);
    playerInfo[playerid][p_Spectating] = true;
    
    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce esta assistindo o jogador %s, para parar de assistir digite: /passistir", getPlayerName(id));
    
    return 1;
}

CMD:passistir(playerid, params[])
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

    if(!playerInfo[playerid][p_Spectating])
        return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao esta assistindo ninguem!");
        
	TogglePlayerSpectating(playerid, 0);
    playerInfo[playerid][p_Spectating] = false;

    SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);

    return 1;
}

CMD:texto(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /texto [mensagem]");

	new message[144];
	
	format(message, sizeof(message), "~y~%s: ~w~%s", getPlayerName(playerid), params);
	
	GameTextForAll(message, 2000, 4);
	
	return 1;
}

CMD:a(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /a [mensagem]");

	new messageFormatted[144];
	
	format(messageFormatted, sizeof(messageFormatted), "| CHAT-STAFF | O(a) %s %s[%d] diz: %s", getOfficePlayer(playerid), getPlayerName(playerid), params);
	
    sendMessageStaff(messageFormatted);
    
	return 1;
}

CMD:limparchat(playerid)
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	clearChatAll();
	
	return 1;
}

CMD:congelar(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /congelar [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

    TogglePlayerControllable(id, false);
    
    SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s congelou o(a) jogador(a) %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id));
    
    return 1;
}

CMD:descongelar(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /congelar [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(!playerInfo[id][p_Frozen])
    	return SendClientMessage(playerid, COLOR_RED, "| ERRO | Este jogador(a) nao esta congelado!");

	TogglePlayerControllable(id, false);

 	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s descongelou o(a) jogador(a) %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id));

	return 1;
}

CMD:ir(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /ir [id]");

	new id = strval(params);
	
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce foi ate o jogador %s", getPlayerName(id));
	SendClientMessageEx(playerid, COLOR_MAIN, "| INFO | O(a) %s %s veio ate voce", getOfficePlayer(playerid), getPlayerName(playerid));
	
	new Float:posPlayer[3];
	
	GetPlayerPos(id, posPlayer[0], posPlayer[1], posPlayer[2]);
	SetPlayerPos(playerid, posPlayer[0], posPlayer[1], posPlayer[2]);
	
	return 1;
}

CMD:trazer(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /trazer [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce trouxe o jogador %s", getPlayerName(id));
	SendClientMessageEx(playerid, COLOR_MAIN, "| INFO | O(a) %s %s trouxe voce ate ele", getOfficePlayer(playerid), getPlayerName(playerid));

	new Float:posPlayer[3];

	GetPlayerPos(playerid, posPlayer[0], posPlayer[1], posPlayer[2]);
	SetPlayerPos(id, posPlayer[0], posPlayer[1], posPlayer[2]);

	return 1;
}

CMD:destruircarros(playerid)
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	destroyAllVehicles();
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s deletou todos os veiculos nao ocupados!", getOfficePlayer(playerid), getPlayerName(playerid));
	
	return 1;
}

CMD:calar(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /calar [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(playerInfo[id][p_ShutUp])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Este jogador ja esta calado!");

	playerInfo[id][p_ShutUp] = true;
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO| O %s %s calou o(a) jogador(a) %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id));
	
	return 1;
}

CMD:descalar(playerid, params[])
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /calar [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(!playerInfo[id][p_ShutUp])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Este jogador nao esta calado!");

	playerInfo[id][p_ShutUp] = false;

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO| O %s %s descalou o(a) jogador(a) %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id));

	return 1;
}

CMD:jetpack(playerid)
{
	if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	SetPlayerSpecialAction(playerid, 2);

	SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);
	
	return 1;
}

CMD:moverplayer(playerid, params[])
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	new idFirst, idSecond;
	
	if(sscanf(params, "dd", idFirst, idSecond))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /moverplayer [id-1] [id-2]");
	    
	if(!IsPlayerConnected(idFirst) || !IsPlayerConnected(idSecond))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Um dos ids escolhidos esta offline!");
	    
	new Float:pos[3];
	
	GetPlayerPos(idSecond, pos[0], pos[1], pos[2]);
	
	SetPlayerPos(idFirst, pos[0], pos[1], pos[2]);
	
	SendClientMessageEx(idFirst, COLOR_MAIN, "| INFO | O %s %s lhe moveu ate o jogador %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(idSecond));
	SendClientMessageEx(idSecond, COLOR_MAIN, "| INFO | O %s %s trouxe o jogador %s ate voce", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(idFirst));

	SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);
	
	return 1;
}

CMD:godmode(playerid)
{
    if(!isPlayerOffice(playerid, HELPER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

    SetPlayerHealth(playerid, 999999);
    
    SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);
    
    return 1;
}

CMD:verip(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | /verip [id]");
	    
	new id = strval(params);
	
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");
	    
	new ip[16];
	
	GetPlayerIp(id, ip, sizeof(ip));
	
	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | IP do jogador %s: %s", getPlayerName(playerid), ip);
	
	return 1;
}

CMD:setarscore(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	new id, score;
	
	if(sscanf(params, "dd", id, score))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarscore [id] [score]");
	    
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) desconectado!");
	    
	SetPlayerScore(id, score);
	
	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce deu ao jogador %s, %d niveis de score!", getPlayerName(id), score);
	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s lhe setou %d niveis de score!", getOfficePlayer(playerid), getPlayerName(playerid), score);
	
	return 1;
}

CMD:setarvida(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(isnull(params))
 		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarvida [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) desconectado!");

    SetPlayerHealth(id, 100);

	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce setou a vida do jogador %s para 100%!", getPlayerName(id));
	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s lhe setou 100% de vida", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:setarcolete(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(isnull(params))
 		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarcolete [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) desconectado!");

	SetPlayerArmour(id, 100);

	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce deu colete ao jogador %s!", getPlayerName(id));
	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s lhe deu colete!", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:ejetar(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /ejetar [id]");

	new id = strval(params);

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(!IsPlayerInAnyVehicle(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador nao esta em um veiculo!");

	RemovePlayerFromVehicle(id);
	
	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce removeu o jogador %s de seu veiculo", getPlayerName(id));
	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s removeu ejetou voce do veiculo!", getOfficePlayer(playerid), getPlayerName(playerid));
	
	return 1;
}

CMD:invisivel(playerid)
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(playerInfo[playerid][p_invisible])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce ja esta em modo invisivel!");
	    
    SetPlayerVirtualWorld(playerid, 5);
    
    SendClientMessage(playerid, COLOR_GREY, "| INFO | Voce esta em modo invisivel, para voltar digite: /visivel");
    
    return 1;
}

CMD:visivel(playerid)
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(!playerInfo[playerid][p_invisible])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao esta em modo invisivel!");

    SetPlayerVirtualWorld(playerid, 0);
    
    SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);
    
    return 1;
}

CMD:crashar(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	new id, reason[30];
	
	if(sscanf(params, "ds[30", id, reason))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /crashar [id] [motivo]");
	    
    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s crashou o jogador %s, motivo: %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), reason);
	
    GameTextForPlayer(id, "~k~~INVALID_KEY~", 5000, 5);
    
	return 1;
}

CMD:textoprivado(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	new id, message[30];
	
	if(sscanf(params, "ds[30]", id, message))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /textoprivado [id] [mensagem]");

	new messageFormatted[144];
	
	format(messageFormatted, sizeof(messageFormatted), "~w~~%s", message);
	
    GameTextForPlayer(id, messageFormatted, 5000, 5);

	return 1;
}

CMD:enquete(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /enquete [descricao]");
	    
	if(survey[s_Created])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Ja possui uma enquete aberta, aguarde ser finalizada!");
	    
	survey[s_Created] = true;
	
	format(survey[s_Title], sizeof(survey[s_Title]), "%s", params);
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s abriu uma enquete: %s. Digite [/sim] ou [/nao] para participar", getOfficePlayer(playerid), getPlayerName(playerid), params);
	SendClientMessageToAll(COLOR_MAIN, "| INFO | A enquete fechara em 50 segundos!");
	
	SetTimer("closedSurvey", Seconds(50), false);
	
	return 1;
}

CMD:setarskin(playerid, params[])
{
	if(!isPlayerOffice(playerid, COORDINATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");
		
	new id, skin;
	
	if(sscanf(params, "dd", id, skin))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarskin [id] [skin]");
	    
    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

    if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

    if(skin < 0 || skin > 299)
        return SendClientMessage(playerid, COLOR_RED, "| ERRO | Id de skin invalida, valores de 0 a 299!");
        
	SetPlayerSkin(id, skin);
	
	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Skin do jogador %s alterada com sucesso!", getPlayerName(id));
	SendClientMessageEx(id, COLOR_GREY, "| INFO | O %s %s alterou sua skin!", getOfficePlayer(playerid), getPlayerName(playerid));
	
	return 1;
}

CMD:setarnome(playerid, params[])
{
	if(!isPlayerOffice(playerid, COORDINATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, name[MAX_PLAYER_NAME];

	if(sscanf(params, "dd", id, name))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarnome [id] [nome]");

    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

    if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(strlen(name) > MAX_PLAYER_NAME)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Numero de caracteres invalido, maximo permitido: 24!");
	    
	new folderOld[MAX_PLAYER_NAME + 13];
	
	format(folderOld, sizeof(folderOld), "%s", getPlayerAccount(playerid));
	
	SetPlayerName(id, name);
	
	DOF2_RenameFile(folderOld, getPlayerAccount(playerid));
	
	return 1;
}

CMD:setarcor(playerid, params[])
{
    if(!isPlayerOffice(playerid, COORDINATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, color[40];
	
	if(sscanf(params, "ds[40]", id, color))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarcor [id] [cor]");
	    
    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

    if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	for(new i = 0; i < sizeof(colors); i ++)
	{
	    if(strcmp(color, colors[i][a_nameColor]) == 0)
	    {
	        SetPlayerColor(id, colors[i][a_colorHex]);
	        
	        SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce alterou a cor do nick do jogador %s para %s", getPlayerName(id), colors[i][a_nameColor]);
	        SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s alterou a cor de seu nick para %s", getOfficePlayer(playerid), getPlayerName(playerid), colors[i][a_nameColor]);
	        
	        return 1;
	    }
	}
	
	SendClientMessage(playerid, COLOR_RED, "| ERRO | A cor escolhida e invalida!");
	
	return 1;
}

CMD:setarpos(playerid, params[])
{
	if(!isPlayerOffice(playerid, COORDINATOR))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, Float:posSelected[3];
	
	if(sscanf(params, "diii", id, posSelected[0], posSelected[1], posSelected[2]))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarpos [id] [posicao X] [posicao Y] [posicao Z]");
	    
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

    if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	SetPlayerPos(id, posSelected[0], posSelected[1], posSelected[2]);
	
	SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce levou o player %s para as coordenadas %d %d %d", getPlayerName(id), posSelected[0], posSelected[1], posSelected[2]);
	SendClientMessageEx(id, COLOR_GREY, "| INFO | O %s %s levou alterou suas coordenadas", getOfficePlayer(playerid), getPlayerName(playerid));
	
	return 1;
}

CMD:verpos(playerid)
{
	if(!isPlayerOffice(playerid, COORDINATOR))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new Float:pos[3];
	
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    
    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce esta na posicao %f %f %f", pos[0], pos[1], pos[2]);
    
    return 1;
}

CMD:force(playerid, params[])
{
	if(!isPlayerOffice(playerid, COORDINATOR))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");
	    
	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /force [id]");
	    
	new id = strval(params);
	
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

    ForceClassSelection(id);
    
	TogglePlayerSpectating(id, true);
    TogglePlayerSpectating(id, false);
    
	return 1;
}

CMD:fakechat(playerid, params[])
{
	if(!isPlayerOffice(playerid, COORDINATOR))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, message[50];
	
	if(sscanf(params, "ds[50]", id, message))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /fakechat [id] [mensagem]");

    SendClientMessageToAllEx(-1, "{%06x}%s(%d):{FFFFFF} %s", GetPlayerColor(id) >>> 8, message);
    
	return 1;
}

CMD:fakekick(playerid, params[])
{
    if(!isPlayerOffice(playerid, COORDINATOR))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, reason[30];
	
	if(sscanf(params, "ds[30]", id, reason))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /fakekick [id] [motivo]");
	    
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");
	    
	if(isPlayerStaff(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");
	    
	if(strlen(reason) > 30)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Motivo muito extenso");
	    
	SendClientMessageToAllEx(COLOR_WARNING, "| ADMIN | O %s %s kickou o(a) jogador(a) %s, motivo: %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), reason);
	
	return 1;
}

CMD:fakeban(playerid, params[])
{
    if(!isPlayerOffice(playerid, COORDINATOR))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, reason[30];

	if(sscanf(params, "ds[30]", id, reason))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /fakeban [id] [motivo]");

	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(strlen(reason) > 30)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Motivo muito extenso");

	SendClientMessageToAllEx(COLOR_WARNING, "| ADMIN | O %s %s baniu o(a) jogador(a) %s, motivo: %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), reason);

	return 1;
}

CMD:kickartodos(playerid)
{
    if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		if(isPlayerStaff(i))
		    continue;
		    
		Kick(i);
	}
	
	SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);
	
	return 1;
}

CMD:congelartodos(playerid)
{
	if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

    server[s_AllFrozen] = true;
    
	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		if(isPlayerStaff(i))
		    continue;

		TogglePlayerControllable(i, false);
	}

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s congelou todos!", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:descongelartodos(playerid)
{
	if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

	if(!server[s_AllFrozen])
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Nao foi usado o comando /congelartodos!");

    server[s_AllFrozen] = false;
    
	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		if(isPlayerStaff(i))
		    continue;

		TogglePlayerControllable(i, true);
	}

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s descongelou todos!", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:desarmartodos(playerid)
{
    if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

    for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		if(isPlayerStaff(i))
		    continue;

		ResetPlayerWeapons(i);
	}
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s removeu a arma de todos os jogadores", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:matartodos(playerid)
{
    if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

    for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		if(isPlayerStaff(i))
		    continue;

		SetPlayerHealth(i, 0);
	}
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s matou todos!", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:trazertodos(playerid)
{
    if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

	new Float:pos[3];
	
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	
    for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		SetPlayerPos(i, pos[0], pos[1], pos[2]);
	}

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s trouxe todos para sua posicao!", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:crashartodos(playerid)
{
    if(!isPlayerOffice(playerid, MANAGER))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

    for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
		if(isPlayerStaff(i))
		    continue;

		GameTextForPlayer(i, "~k~~INVALID_KEY~", 5000, 5);
	}

	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s crashou todos!", getOfficePlayer(playerid), getPlayerName(playerid));

	return 1;
}

CMD:ativarmsgs(playerid)
{
	if(!isPlayerOffice(playerid, MANAGER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");
		
    server[s_TimerMessages] = SetTimer("messageRandom", Seconds(30), true);
    
    SendClientMessage(playerid, COLOR_GREY, "| INFO | Para desativar as mensagens digite: /desativarmsgs");
    
    return 1;
}

CMD:desativarmsgs(playerid)
{
	if(!isPlayerOffice(playerid, MANAGER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

    KillTimer(server[s_TimerMessages]);

    SendClientMessage(playerid, COLOR_GREY, "| INFO | Para desativar as mensagens digite: /desativarmsgs");

    return 1;
}

CMD:nomeserver(playerid, params[])
{
	if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /nomeserver [nome]");
	    
	new stringRcon[100];
	
    format(stringRcon, sizeof(stringRcon), "hostname %s", params);
    
    SendRconCommand(stringRcon);
    
    SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s mudou o nome do server para %s", getOfficePlayer(playerid), getPlayerName(playerid), params);
    
	return 1;
}

CMD:nomegm(playerid, params[])
{
	if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /nomegm [nome]");

    SetGameModeText(params);

    SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s mudou o nome do server para %s", getOfficePlayer(playerid), getPlayerName(playerid), params);

	return 1;
}

CMD:nomelinguagem(playerid, params[])
{
	if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /nomelinguagem [nome]");

    new stringRcon[100];

    format(stringRcon, sizeof(stringRcon), "language %s", params);

    SendRconCommand(stringRcon);

    SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s mudou a linguagem do server para %s", getOfficePlayer(playerid), getPlayerName(playerid), params);

	return 1;
}

CMD:daradmin(playerid, params[])
{
    if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	new id, level;
	
	if(sscanf(params, "dd", id, level))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /daradmin [id] [level]");
	    
	if(!IsPlayerConnected(id))
	     return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(level > 4)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Leveis de 1 a 4!");

	if(level == 0)
	{
	    playerInfo[id][p_LevelStaff] = 0;

		SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce removeu o cargo administrativo do jogador %s", getPlayerName(id));
		SendClientMessageEx(id, COLOR_GREY, "| INFO | O %s %s removeu seu cargo administrativo", getOfficePlayer(playerid), getPlayerName(playerid));
	}
	else if(level < playerInfo[id][p_LevelStaff])
	{
	    playerInfo[id][p_LevelStaff] = level;

		SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce abaixou o cargo de administrador do jogador %s para %s", getPlayerName(id), getOfficePlayer(id));
		SendClientMessageEx(id, COLOR_GREY, "| INFO | O %s %s rebaixou seu cargo administrativo para %s", getOfficePlayer(playerid), getPlayerName(playerid), getOfficePlayer(id));
	}
	else
	{
	    playerInfo[id][p_LevelStaff] = level;

		SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce promoveu o jogador %s para o cargo %s", getPlayerName(id), getOfficePlayer(id));
		SendClientMessageEx(id, COLOR_GREY, "| INFO | Parabens, O %s %s promoveu voce para %s", getOfficePlayer(playerid), getPlayerName(playerid), getOfficePlayer(id));
		
		SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s promoveu o jogador %s para o cargo de %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), getOfficePlayer(id));
	}
	
	return 1;
}

CMD:setargravidade(playerid, params[])
{
    if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setargravidade [gravidade]");
	    
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s mudou a gravidade do servidor", getOfficePlayer(playerid), getPlayerName(playerid));
	
	SetGravity(strval(params));
	
	return 1;
}

CMD:trancarserver(playerid, params[])
{
    if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /trancarserver [senha]");

	new stringRcon[100];
	
    format(stringRcon, sizeof(stringRcon), "password %s", stringRcon);
    
	SendRconCommand(stringRcon);
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s trancou o servidor!", getOfficePlayer(playerid), getPlayerName(playerid));

	server[s_Locked] = true;
	
	return 1;
}

CMD:destrancarserver(playerid)
{
    if(!isPlayerOffice(playerid, FOUNDER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Fundador!");

	if(!server[s_Locked])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | O servidor nao esta trancado!");

	SendRconCommand("password 0");
	
	SendClientMessageToAllEx(COLOR_MAIN, "| INFO | O %s %s destrancou o servidor!", getOfficePlayer(playerid), getPlayerName(playerid));

	server[s_Locked] = true;

	return 1;
}

CMD:reportar(playerid, params[])
{
	if(isPlayerStaff(playerid))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Players!");

	if(getTotalStaffOn() == 0)
	    return SendClientMessage(playerid, COLOR_WARNING, "| AVISO | Nossa staff nao se encontra online, em caso urgente favor denuncie em nosso discord!");

	new id, reason[30];
	
	if(sscanf(params, "ds[30]", id, reason))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /reportar [id] [motivo]");
	    
	if(strlen(reason) > 30)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Motivo muito extenso, limite de caracteres: 30!");

	new stringFormatted[144];
	
	format(stringFormatted, sizeof(stringFormatted), "| STAFF | O(a) jogador(a) %s[%d] reportou o(a) jogador(a) %s[%d], motivo: %s", getPlayerName(playerid), playerid, getPlayerName(id), id, reason);
	
    sendMessageStaff(stringFormatted, COLOR_WARNING);
    
	return 1;
}

CMD:admins(playerid)
{
	new stringFormatted[250], totalAdmins = 0;
	
	for(new i = 0, players = GetPlayerPoolSize(); i < players; i ++)
	{
	    if(isPlayerStaff(i))
	    {
	        totalAdmins ++;
	        
	        format(stringFormatted, sizeof(stringFormatted), "%s\n{cfd0d1}%s {fcfcfc}(Level Staff: {5be83f}%d{fcfcfc}) {fcfcfc}(Funcao: {5be83f}%s{fcfcfc})", stringFormatted, getPlayerName(i), playerInfo[i][p_LevelStaff], getOfficePlayer(i));
	    }
	}

	if(!totalAdmins)
	    return SendClientMessage(playerid, COLOR_WARNING, "| AVISO | Nossa staff nao se encontra online!");

	new title[30];
	
	format(title, sizeof(title), "Administradores (%d)", totalAdmins);
	
	ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX, title, stringFormatted, "Ok", "-");
	
	return 1;
}

CMD:sim(playerid)
{
	if(!survey[s_Created])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Nao ha enquete criada!");
	    
	if(playerInfo[playerid][p_isVotedInSurvey])
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce ja votou na enquete, aguarde o resultado!");

	survey[s_VoteYes] ++;
	
	SendClientMessage(playerid, COLOR_GREY, "| INFO | Seu voto foi computado com sucesso, aguarde o termino da enquete!");
	
	return 1;
}

CMD:nao(playerid)
{
	if(!survey[s_Created])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Nao ha enquete criada!");

    if(playerInfo[playerid][p_isVotedInSurvey])
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce ja votou na enquete, aguarde o resultado!");

	survey[s_VoteNo] ++;

	SendClientMessage(playerid, COLOR_GREY, "| INFO | Seu voto foi computado com sucesso, aguarde o termino da enquete!");

	return 1;
}

// -- Callbacks --

public closedSurvey()
{
	survey[s_Created] = false;
	
	survey[s_Title] = EOS;
	
	SendClientMessageToAll(-1, "{cfd0d1}| ENQUETE | {fcfcfc}A enquete foi encerrada, veja abaixo os resultados!");
	
	SendClientMessageToAllEx(-1, "{cfd0d1}| ENQUETE | {fcfcfc}Votos {5be83f}Sim {fcfcfc}({cfd0d1}%d{fcfcfc}) | Votos {b52410}Nao {fcfcfc}({cfd0d1}%d{fcfcfc})", survey[s_VoteYes], survey[s_VoteNo]);
	
	if(survey[s_VoteYes] > survey[s_VoteNo])
	{
	    SendClientMessageToAll(-1, "{cfd0d1}| ENQUETE | O {5be83f}SIM {fcfcfc}teve maior voto!");
	}
	else
	{
	    SendClientMessageToAll(-1, "{cfd0d1}| ENQUETE | O {5be83f}NAO {fcfcfc}teve maior voto!");
	}
	
	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
	    playerInfo[i][p_isVotedInSurvey] = false;
	}
}

public messageRandom()
{
	new index = random(sizeof(messagesServer));
	
	SendClientMessageToAll(-1, messagesServer[index]);
}

// -- Functions --

getTotalStaffOn()
{
	new total = 0;
	
	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
	    if(IsPlayerConnected(i) && isPlayerStaff(i))
	    {
	        total ++;
	    }
	}
	
	return total;
}

destroyAllVehicles()
{
    new bool:playerInVehicle = false;

    for(new v = 1, vehicles = GetVehiclePoolSize(); v <= vehicles; v ++)
    {
        for(new p = 0, players = GetPlayerPoolSize(); p <= players; p ++)
        {
            if(IsPlayerInVehicle(p, v))
            {
                playerInVehicle = true;
                break;
            }
        }

        if(!playerInVehicle)
        {
            DestroyVehicle(v);
        }

        playerInVehicle = false;
    }
}

sendMessageStaff(text[], color = COLOR_MAIN)
{
	for(new i = 0, players = GetPlayerPoolSize(); i < players; i ++)
	{
	    if(isPlayerStaff(i))
	    {
	        SendClientMessage(i, color, text);
	    }
	}
}

isPlayerStaff(playerid)
{
	return playerInfo[playerid][p_LevelStaff] >= HELPER;
}

isPlayerOffice(playerid, office)
{
	return playerInfo[playerid][p_LevelStaff] >= office;
}

getOfficePlayer(playerid)
{
	return s_nameOffice[ playerInfo[playerid][p_LevelStaff] ];
}

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

spawnPlayerAfterLogin(playerid, lastPosition = false)
{
	new messageAll[144];

	format(messageAll, sizeof(messageAll), "{cfd0d1}| SERVER | O(a) jogador(a) %s conectou-se ao servidor (%d/%d)", getPlayerName(playerid), getTotalPlayersOnline(), GetMaxPlayers());

	SendClientMessageToAll(-1, messageAll);

    SendClientMessage(playerid, -1, "{fcfcfc}| LOGIN | Login realizado com sucesso!");

    SpawnPlayer(playerid);

    if(lastPosition)
    {
        SetPlayerPos(playerid, playerInfo[playerid][p_LastPosition][0], playerInfo[playerid][p_LastPosition][1], playerInfo[playerid][p_LastPosition][2]);
        SetPlayerFacingAngle(playerid, 0);
    }
    else
    {
        setPlayerRandomPos(playerid);
    }
}

setPlayerRandomPos(playerid)
{
    new index = random(sizeof(randomSpawn));

    SetPlayerPos(playerid, randomSpawn[index][0], randomSpawn[index][1], randomSpawn[index][2]);
    
    SetPlayerFacingAngle(playerid, randomSpawn[index][3]);
}

loadingAccount(playerid)
{
    format(playerInfo[playerid][p_Password], 50, "%s", DOF2_GetString(getPlayerAccount(playerid), "password"));

	playerInfo[playerid][p_LevelStaff] = DOF2_GetInt(getPlayerAccount(playerid), "level_staff");
	playerInfo[playerid][p_LastPosition][0] = DOF2_GetFloat(getPlayerAccount(playerid), "last_position_x");
	playerInfo[playerid][p_LastPosition][1] = DOF2_GetFloat(getPlayerAccount(playerid), "last_position_y");
	playerInfo[playerid][p_LastPosition][2] = DOF2_GetFloat(getPlayerAccount(playerid), "last_position_z");

	GivePlayerMoney(playerid, DOF2_GetInt(getPlayerAccount(playerid), "money"));
	SetPlayerScore(playerid, DOF2_GetInt(getPlayerAccount(playerid), "score"));
	SetPlayerSkin(playerid, DOF2_GetInt(getPlayerAccount(playerid), "skin"));
}

updatePlayerAccount(playerid)
{
	new Float:posPlayer[3];

	GetPlayerPos(playerid, posPlayer[0], posPlayer[1], posPlayer[2]);

	if(!DOF2_FileExists(getPlayerAccount(playerid)))
	{
		DOF2_CreateFile(getPlayerAccount(playerid));
	}

	DOF2_SetInt(getPlayerAccount(playerid), "skin", GetPlayerSkin(playerid));
	DOF2_SetInt(getPlayerAccount(playerid), "money", GetPlayerMoney(playerid));
	DOF2_SetInt(getPlayerAccount(playerid), "score", GetPlayerScore(playerid));
	DOF2_SetInt(getPlayerAccount(playerid), "level_staff", playerInfo[playerid][p_LevelStaff]);
	DOF2_SetString(getPlayerAccount(playerid), "password", playerInfo[playerid][p_Password]);
	DOF2_SetFloat(getPlayerAccount(playerid), "last_position_x", posPlayer[0]);
	DOF2_SetFloat(getPlayerAccount(playerid), "last_position_y", posPlayer[1]);
	DOF2_SetFloat(getPlayerAccount(playerid), "last_position_z", posPlayer[2]);
}

createAccount(playerid, password[])
{
	format(playerInfo[playerid][p_Password], 50, "%s", password);

	playerInfo[playerid][p_LevelStaff] = 0;
	playerInfo[playerid][p_LastPosition][0] = randomSpawn[0][0];
	playerInfo[playerid][p_LastPosition][1] = randomSpawn[0][0];
	playerInfo[playerid][p_LastPosition][2] = randomSpawn[0][0];

	GivePlayerMoney(playerid, 500);

	updatePlayerAccount(playerid);
}

resetPlayerData(playerid)
{
    playerInfo[playerid][p_LevelStaff] = 0;
    playerInfo[playerid][p_LastPosition][0] = 0.0;
    playerInfo[playerid][p_LastPosition][1] = 0.0;
    playerInfo[playerid][p_LastPosition][2] = 0.0;
    playerInfo[playerid][p_ErrorLogin] = 0;
    playerInfo[playerid][p_Notice] = 0;
    playerInfo[playerid][p_isVotedInSurvey] = false;
    playerInfo[playerid][p_invisible] = false;
    playerInfo[playerid][p_ShutUp] = false;
    playerInfo[playerid][p_Frozen] = false;
    playerInfo[playerid][p_Spectating] = false;
}

desconectedPlayer(playerid)
{
    updatePlayerAccount(playerid);
	resetPlayerData(playerid);
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

clearChatAll()
{
	for(new i = 0; i < 20; i ++)
	{
	    SendClientMessageToAll(-1, "");
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

