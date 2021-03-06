
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
#define DIALOG_BANS         5
#define DIALOG_COLORS       6
#define DIALOG_COMMANDS     7

// -- Defines Folders --

#define FOLDER_ACCOUNT      "Contas/%s.ini"
#define FOLDER_BANS         "Bans/%s.ini"
#define FOLDER_BANS_IP      "BansIp/%s.ini"

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
#define COLOR_GREEN   0x48d948FF

#define MESSAGE_CMD_SUCESS  "| INFO | Comando executado com sucesso!"

#define BAN_ACCOUNT  1
#define BAN_IP       2

#define Kick(%0) SetTimerEx("kickEx", 100, false, "i", %0)

enum p_Info {
	p_LevelStaff,
	p_Password[50],
	p_ErrorLogin,
	p_Notice,
	p_JailedTimer,
	p_JailedTime,
	bool:p_isVotedInSurvey,
	bool:p_invisible,
	bool:p_ShutUp,
	bool:p_Frozen,
	bool:p_Spectating,
	Float:p_LastPosition[3],
}

enum s_Info {
	s_TimerMessages,
	bool:s_chatActived,
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

static const staffCommands[][] = {
	{"Helper", "/avisar"},
    {"Helper", "/kickar"},
    {"Helper", "/tapa"},
    {"Helper", "/assistir"},
    {"Helper", "/passistir"},
    {"Helper", "/texto"},
    {"Helper", "/a"},
    {"Helper", "/limparchat"},
    {"Helper", "/congelar"},
    {"Helper", "/descongelar"},
    {"Helper", "/ir"},
    {"Helper", "/trazer"},
    {"Helper", "/destruircarros"},
    {"Helper", "/calar"},
    {"Helper", "/descalar"},
    {"Helper", "/jetpack"},
    {"Helper", "/moverplayer"},
    {"Helper", "/godmode"},
    {"Moderador", "/verip"},
    {"Moderador", "/prender"},
    {"Moderador", "/soltar"},
    {"Moderador", "/ejetar"},
    {"Moderador", "/setarscore"},
    {"Moderador", "/setarvida"},
    {"Moderador", "/setarcolete"},
    {"Moderador", "/setarvida"},
    {"Moderador", "/setarcolete"},
    {"Moderador", "/banir"},
    {"Moderador", "/desbanir"},
    {"Moderador", "/enquete"},
    {"Moderador", "/invisivel"},
    {"Moderador", "/visivel"},
    {"Moderador", "/crashar"},
    {"Moderador", "/textoprivado"},
    {"Coordenador", "/setarskin"},
    {"Coordenador", "/setarnome"},
    {"Coordenador", "/setarpos"},
    {"Coordenador", "/setarcor"},
    {"Coordenador", "/fakechat"},
    {"Coordenador", "/fakekick"},
    {"Coordenador", "/fakeban"},
    {"Coordenador", "/force"},
    {"Coordenador", "/verpos"},
    {"Gerente", "/ativarmsgs"},
    {"Gerente", "/desativarmsgs"},
    {"Gerente", "/kickartodos"},
    {"Gerente", "/congelartodos"},
    {"Gerente", "/descongelartodos"},
    {"Gerente", "/desarmartodos"},
    {"Gerente", "/matartodos"},
    {"Gerente", "/trazertodos"},
    {"Gerente", "/crashartodos"},
    {"Fundador", "/nomeserver"},
    {"Fundador", "/nomegm"},
    {"Fundador", "/nomelinguagem"},
    {"Fundador", "/daradmin"},
    {"Fundador", "/setargravidade"},
    {"Fundador", "/trancarserver"},
    {"Fundador", "/destrancarserver"}
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

forward kickEx(playerid);
forward verifyJailed(playerid);
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
	{
	    SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce esta calado e nao pode falar no chat!");
	    
	    return 0;
	}
	    
	if(server[s_chatActived] && !isPlayerStaff(playerid))
	{
 		SendClientMessage(playerid, COLOR_RED, "| ERRO | As mensagens via chat estao desativadas!");

	    return 0;
	}
	
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
	            else if(!strcmp(DOF2_GetString(getFolder(playerid, FOLDER_ACCOUNT), "password"), inputtext))
	            {
					loadingAccount(playerid);

					if(isPlayerJailed(playerid))
					{
					    SendClientMessageToAllEx(COLOR_WARNING, "| CADEIA | Voce ainda nao cumpriu sua pena! tempo restante: %s", convertTimer(playerInfo[playerid][p_JailedTime]));

						setPlayerJailed(playerid, playerInfo[playerid][p_JailedTime]);
					}
					else
					{
					    ShowPlayerDialog(playerid, DIALOG_OPTION_SPAWN, DIALOG_STYLE_INPUT, "Escolha seu Spawn", "{799dc9}1. {fcfcfc}Voltar para ultima posicao que estava\n\n{799dc9}2. {fcfcfc}Spawn aleatorio", "Escolher", "-");
					}
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

	++ playerInfo[id][p_Notice];
	
	if(playerInfo[id][p_Notice] >= 3)
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | O(a) jogador(a) %s cumpriu 3 avisos e foi kickado!", getPlayerName(id));
	    SendClientMessageToAllEx(COLOR_MAIN, "| SERVER | O(a) jogador(a) %s cumpriu 3 avisos e foi kickado!", getPlayerName(id));
	    
	    Kick(id);
	}
	else
	{
	    SendClientMessageEx(playerid, COLOR_GREY, "| INFO | Voce setou +1 aviso para o jogador %s", getPlayerName(id));
	    SendClientMessageEx(id, COLOR_GREY, "| INFO | O %s %s lhe setou 1 aviso, total: (%d/3). No ultimo aviso voce sera kickado!", getOfficePlayer(playerid), getPlayerName(playerid), playerInfo[id][p_Notice]);
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
	
	format(messageFormatted, sizeof(messageFormatted), "| CHAT-STAFF | O(a) %s %s[%d] diz: %s", getOfficePlayer(playerid), getPlayerName(playerid), playerid, params);
	
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

    playerInfo[id][p_Frozen] = true;
    
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

	TogglePlayerControllable(id, true);

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
	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O(a) %s %s veio ate voce", getOfficePlayer(playerid), getPlayerName(playerid));
	
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
	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O(a) %s %s trouxe voce ate ele", getOfficePlayer(playerid), getPlayerName(playerid));

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
	    
    playerInfo[playerid][p_invisible] = true;
    
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

	SendClientMessageEx(id, COLOR_MAIN, "| INFO | O %s %s crashou lhe deu crash, motivo: %s", getOfficePlayer(playerid), getPlayerName(playerid), reason);
	
	SendClientMessage(playerid, COLOR_GREY, MESSAGE_CMD_SUCESS);
	
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

CMD:banir(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	new id, typeBan[10], reason[30];
	
	if(sscanf(params, "ds[10]s[30]", id, typeBan, reason))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /banir [tipo do ban: conta ou ip] [motivo]");
	    
	if(strlen(reason) > 30)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Motivo muito extenso!");
	    
	if(isPlayerStaff(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");
	    
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(strcmp(typeBan, "conta") == 0)
	{
	   	ban(playerid, reason, id, BAN_ACCOUNT);
	}
	else if(strcmp(typeBan, "ip") == 0)
	{
 		ban(playerid, reason, id, BAN_IP);
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "| ERRO | Tipo de banimento invalido, tipos validos: [conta/ip]");
	    
	    return 1;
	}
	
	SendClientMessageToAllEx(COLOR_WARNING, "| ADMIN | O %s %s baniu o(a) jogador(a) %s, motivo: %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), reason);
	
	return 1;
}

CMD:desbanir(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	new typeBan[10], data[MAX_PLAYER_NAME];

	if(sscanf(params, "s[10]s[24]", typeBan, data))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /banir [tipo do ban: conta ou ip] [nome da conta ou ip]");

	new result;
	
	if(strcmp(typeBan, "conta") == 0)
	{
	   	result = desban(data, BAN_ACCOUNT);
	}
	else if(strcmp(typeBan, "ip") == 0)
	{
 		result = desban(data, BAN_IP);
	}
	
	if(result == -1)
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Esta conta ou ip nao esta banida!");
		
	SendClientMessage(playerid, COLOR_WARNING, "| ADMIN | Conta desbanida com sucesso!");
	
	return 1;
}

CMD:prender(playerid, params[])
{
    if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	new id, reason[30], time;
	
	if(sscanf(params, "ds[30]d", id, reason, time))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /prender [id] [motivo] [tempo]");
	    
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(isPlayerStaff(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(strlen(reason) > 30)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Motivo muito extenso!");
	    
	if(isPlayerJailed(playerid))
	     return SendClientMessage(playerid, COLOR_RED, "| ERRO | Este player ja se encontra preso!");

	SendClientMessageToAllEx(COLOR_WARNING, "| CADEIA | O %s %s prendeu o jogador %s, motivo: %s, tempo: %s", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id), reason, convertTimer(time));
	
	SendClientMessage(id, COLOR_GREEN, "| CADEIA | para ver o tempo restante digite: /cadeiatempo");
	
	setPlayerJailed(id, time);
	
	return 1;
}

CMD:soltar(playerid, params[])
{
	if(!isPlayerOffice(playerid, MODERATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Moderadores!");

	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /soltar [id]");

	new id = strval(params);
	
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

	if(!isPlayerJailed(playerid))
	     return SendClientMessage(playerid, COLOR_RED, "| ERRO | Este player nao esta preso!");

    SendClientMessageToAllEx(COLOR_WARNING, "| CADEIA | O %s %s removeu o jogador %s da prisao!", getOfficePlayer(playerid), getPlayerName(playerid), getPlayerName(id));

    removePlayerFromJailed(id);
    
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

	if(sscanf(params, "ds[24]", id, name))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarnome [id] [nome]");

    if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Jogador(a) nao conectado!");

    if(isPlayerStaff(id))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao pode usar este comando com um staff!");

	if(strlen(name) > MAX_PLAYER_NAME)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Numero de caracteres invalido, maximo permitido: 24!");
	    
	new folderOld[MAX_PLAYER_NAME + 13];
	
	format(folderOld, sizeof(folderOld), "%s", getFolder(playerid, FOLDER_ACCOUNT));
	
	SetPlayerName(id, name);
	
	DOF2_RenameFile(folderOld, getFolder(playerid, FOLDER_ACCOUNT));
	
	return 1;
}

CMD:cores(playerid)
{
    if(!isPlayerOffice(playerid, COORDINATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new colorsMessage[144];
	
	for(new i = 0; i < sizeof(colors); i ++)
	{
	    format(colorsMessage, sizeof(colorsMessage), "%s\n%s", colorsMessage, colors[i][a_nameColor]);
	}
	
	ShowPlayerDialog(playerid, DIALOG_COLORS, DIALOG_STYLE_MSGBOX, "Cores Disponiveis", colorsMessage, "Ok", "-");
	
	return 1;
}

CMD:setarcor(playerid, params[])
{
    if(!isPlayerOffice(playerid, COORDINATOR))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Coordenador!");

	new id, color[40];
	
	if(sscanf(params, "ds[40]", id, color))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Use: /setarcor [id] [cor] (para ver as cores disponiveis use: /cores)");
	    
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

    SendClientMessageToAllEx(-1, "{%06x} %s(%d):{FFFFFF} %s", GetPlayerColor(playerid) >>> 8, getPlayerName(id), id, message);
    
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
		
	if(server[s_chatActived])
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | O chat ja esta ativado!");
	    
    server[s_chatActived] = true;
    
    SendClientMessage(playerid, COLOR_GREY, "| INFO | Para desativar as mensagens digite: /desativarmsgs");
    
    return 1;
}

CMD:desativarmsgs(playerid)
{
	if(!isPlayerOffice(playerid, MANAGER))
		return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Gerente!");

	if(server[s_chatActived] == false)
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | O chat nao esta ativado!");
	    
    server[s_chatActived] = false;

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
    if(!IsPlayerAdmin(playerid))
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
	new stringFormatted[500], totalAdmins = 0;
	
	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
	{
	    if(isPlayerStaff(i))
	    {
	        totalAdmins ++;
	        
	        format(stringFormatted, sizeof(stringFormatted), "%s\n{cfd0d1}%s {fcfcfc}(Level Staff: {5be83f}%d{fcfcfc}) {fcfcfc}(Funcao: {5be83f}%s{fcfcfc})\n\n", stringFormatted, getPlayerName(i), playerInfo[i][p_LevelStaff], getOfficePlayer(i));
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

    playerInfo[playerid][p_isVotedInSurvey] = true;
    
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

	playerInfo[playerid][p_isVotedInSurvey] = true;

	survey[s_VoteNo] ++;

	SendClientMessage(playerid, COLOR_GREY, "| INFO | Seu voto foi computado com sucesso, aguarde o termino da enquete!");

	return 1;
}

CMD:cadeiatempo(playerid)
{
	if(!isPlayerJailed(playerid))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Voce nao esta preso!");

	SendClientMessageEx(playerid, COLOR_GREEN, "| CADEIA | Tempo restante %s", convertTimer(playerInfo[playerid][p_JailedTime]));
	
	return 1;
}

CMD:comandosadm(playerid)
{
	if(!isPlayerStaff(playerid))
	    return SendClientMessage(playerid, COLOR_RED, "| ERRO | Comando exclusivo para Staff!");

	new stringFormatted[500];
	
	for(new i = 0; i < sizeof(staffCommands); i ++)
	{
 		format(stringFormatted, sizeof(stringFormatted), "%s\n [Cargo: %s] %s", stringFormatted, staffCommands[i][0], staffCommands[i][1]);
	}
	
	ShowPlayerDialog(playerid, DIALOG_COMMANDS, DIALOG_STYLE_MSGBOX, "Comandos Staff", stringFormatted, "Ok", "-");

	return 1;
}

// -- Callbacks --

public kickEx(playerid)
{
	Kick(playerid);
}

public verifyJailed(playerid)
{
    playerInfo[playerid][p_JailedTime] --;
    
	if(playerInfo[playerid][p_JailedTime] <= 0)
	{
	   removePlayerFromJailed(playerid);
	}
	
	return 1;
}

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
	else if(survey[s_VoteNo] > survey[s_VoteYes])
	{
	    SendClientMessageToAll(-1, "{cfd0d1}| ENQUETE | O {5be83f}NAO {fcfcfc}teve maior voto!");
	}
	else
	{
	    SendClientMessageToAll(-1, "{cfd0d1}| ENQUETE | A Enquete finalizou com empate!");
	}
	
	survey[s_VoteYes] = 0;
	survey[s_VoteNo] = 0;
	
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

        if(playerInVehicle == false)
        {
            DestroyVehicle(v);
        }

        playerInVehicle = false;
    }
}

sendMessageStaff(text[], color = COLOR_MAIN)
{
	for(new i = 0, players = GetPlayerPoolSize(); i <= players; i ++)
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
	static office[12];
	
	switch(playerInfo[playerid][p_LevelStaff])
	{
	    case 1: format(office, sizeof(office), "%s", "Helper");
		case 2: format(office, sizeof(office), "%s", "Moderador");
		case 3: format(office, sizeof(office), "%s", "Coordenador");
		case 4: format(office, sizeof(office), "%s", "Gerente");
		case 5: format(office, sizeof(office), "%s", "Fundador");
	}
	
	return office;
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
    format(playerInfo[playerid][p_Password], 50, "%s", DOF2_GetString(getFolder(playerid, FOLDER_ACCOUNT), "password"));

	playerInfo[playerid][p_LevelStaff] = DOF2_GetInt(getFolder(playerid, FOLDER_ACCOUNT), "level_staff");
	playerInfo[playerid][p_LastPosition][0] = DOF2_GetFloat(getFolder(playerid, FOLDER_ACCOUNT), "last_position_x");
	playerInfo[playerid][p_LastPosition][1] = DOF2_GetFloat(getFolder(playerid, FOLDER_ACCOUNT), "last_position_y");
	playerInfo[playerid][p_LastPosition][2] = DOF2_GetFloat(getFolder(playerid, FOLDER_ACCOUNT), "last_position_z");
	playerInfo[playerid][p_JailedTime] = DOF2_GetInt(getFolder(playerid, FOLDER_ACCOUNT), "time_jailed");
	
	GivePlayerMoney(playerid, DOF2_GetInt(getFolder(playerid, FOLDER_ACCOUNT), "money"));
	SetPlayerScore(playerid, DOF2_GetInt(getFolder(playerid, FOLDER_ACCOUNT), "score"));
	SetPlayerSkin(playerid, DOF2_GetInt(getFolder(playerid, FOLDER_ACCOUNT), "skin"));
}

updatePlayerAccount(playerid)
{
	new Float:posPlayer[3];

	GetPlayerPos(playerid, posPlayer[0], posPlayer[1], posPlayer[2]);

	if(!DOF2_FileExists(getFolder(playerid, FOLDER_ACCOUNT)))
	{
		DOF2_CreateFile(getFolder(playerid, FOLDER_ACCOUNT));
	}

	DOF2_SetInt(getFolder(playerid, FOLDER_ACCOUNT), "skin", GetPlayerSkin(playerid));
	DOF2_SetInt(getFolder(playerid, FOLDER_ACCOUNT), "money", GetPlayerMoney(playerid));
	DOF2_SetInt(getFolder(playerid, FOLDER_ACCOUNT), "score", GetPlayerScore(playerid));
	DOF2_SetInt(getFolder(playerid, FOLDER_ACCOUNT), "level_staff", playerInfo[playerid][p_LevelStaff]);
	DOF2_SetInt(getFolder(playerid, FOLDER_ACCOUNT), "time_jailed", playerInfo[playerid][p_JailedTime]);
	DOF2_SetString(getFolder(playerid, FOLDER_ACCOUNT), "password", playerInfo[playerid][p_Password]);
	DOF2_SetFloat(getFolder(playerid, FOLDER_ACCOUNT), "last_position_x", posPlayer[0]);
	DOF2_SetFloat(getFolder(playerid, FOLDER_ACCOUNT), "last_position_y", posPlayer[1]);
	DOF2_SetFloat(getFolder(playerid, FOLDER_ACCOUNT), "last_position_z", posPlayer[2]);
}

createAccount(playerid, password[])
{
	format(playerInfo[playerid][p_Password], 50, "%s", password);

	playerInfo[playerid][p_LevelStaff] = 0;
	playerInfo[playerid][p_LastPosition][0] = randomSpawn[0][0];
	playerInfo[playerid][p_LastPosition][1] = randomSpawn[0][1];
	playerInfo[playerid][p_LastPosition][2] = randomSpawn[0][2];

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
    playerInfo[playerid][p_JailedTime] = 0;
    playerInfo[playerid][p_isVotedInSurvey] = false;
    playerInfo[playerid][p_invisible] = false;
    playerInfo[playerid][p_ShutUp] = false;
    playerInfo[playerid][p_Frozen] = false;
    playerInfo[playerid][p_Spectating] = false;
    
    KillTimer(playerInfo[playerid][p_JailedTimer]);
}

desconectedPlayer(playerid)
{
    updatePlayerAccount(playerid);
	resetPlayerData(playerid);
}

setPlayerJailed(playerid, time)
{
	SpawnPlayer(playerid);
	
	SetPlayerPos(playerid, 264.6288, 77.5742, 1001.0391);
	
    SetPlayerInterior(playerid, 6);
    
    playerInfo[playerid][p_JailedTime] = time;
    playerInfo[playerid][p_JailedTimer] = SetTimerEx("verifyJailed", Seconds(1), true, "i", playerid);
}

removePlayerFromJailed(playerid)
{
    SetPlayerInterior(playerid, 0);
    
	setPlayerRandomPos(playerid);
	
	SendClientMessage(playerid, COLOR_GREEN, "| CADEIA | Voce cumpriu sua pena e esta livre novamente!");

	playerInfo[playerid][p_JailedTime] = 0;
	KillTimer(playerInfo[playerid][p_JailedTimer]);
}

isPlayerJailed(playerid)
{
	return playerInfo[playerid][p_JailedTime] > 0;
}

ban(idStaff, reason[], playerid, typeBan = BAN_ACCOUNT)
{
	new folder[30], day[3], hour[3];
	
	getdate(day[0], day[1], day[2]);
	gettime(hour[0], hour[1], hour[2]);
		
	if(typeBan == BAN_ACCOUNT)
	{
	    format(folder, sizeof(folder), "%s", getFolder(playerid, FOLDER_BANS));
	}
	else
	{
	    format(folder, sizeof(folder), "%s", getFolder(playerid, FOLDER_BANS_IP));
	}
	
	DOF2_CreateFile(folder);

	DOF2_SetString(folder, "staff", getPlayerName(idStaff));
	DOF2_SetString(folder, "reason", reason);
	DOF2_SetInt(folder, "year", day[0]);
	DOF2_SetInt(folder, "month", day[1]);
	DOF2_SetInt(folder, "day", day[2]);
	DOF2_SetInt(folder, "hour", hour[0]);
	DOF2_SetInt(folder, "minute", hour[1]);
	DOF2_SetInt(folder, "seconds", hour[2]);

	Kick(playerid);
	
	return 1;
}

desban(data[], typeBan = BAN_ACCOUNT)
{
	new folder[30];
	
	if(typeBan == BAN_ACCOUNT)
	{
	    format(folder, sizeof(folder), FOLDER_BANS, data);
	}
	else
	{
	    format(folder, sizeof(folder), FOLDER_BANS_IP, data);
	}
	
 	if(!DOF2_FileExists(folder))
	{
 		return -1;
	}
	else
	{
 		DOF2_RemoveFile(folder);
	}
	
	return 1;
}

getPlayerIp(playerid)
{
	static ip[16];

	GetPlayerIp(playerid, ip, sizeof(ip));
	
	return ip;
}

getPlayerName(playerid)
{
	static name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));

	return name;
}

getFolder(playerid, folder[])
{
	new stringFormatted[30];
	
	if(strcmp(folder, FOLDER_BANS_IP) == 0)
	{
	    format(stringFormatted, sizeof(stringFormatted), folder, getPlayerIp(playerid));
	}

	else
	{
		format(stringFormatted, sizeof(stringFormatted), folder, getPlayerName(playerid));
	}
	    
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

getDateFormatted(day, month, year)
{
	new dateFormatted[30];
	
	format(dateFormatted, sizeof(dateFormatted), "%d/%d/%d", day, month, year);
	
	return dateFormatted;
}

getHourFormatted(hour, minute, seconds)
{
	new hourFormatted[30];
	
	format(hourFormatted, sizeof(hourFormatted), "%d:%d:%d", hour, minute, seconds);
	
	return hourFormatted;
}

showDetailsBan(playerid, typeBan, folder[])
{
	new messageFormatted[400], staff[MAX_PLAYER_NAME], reason[30], day, month, year, hour, minute, seconds;

	format(staff, sizeof(staff), "%s", DOF2_GetString(folder, "staff"));
	format(reason, sizeof(reason), "%s", DOF2_GetString(folder, "reason"));

	day   = DOF2_GetInt(folder, "day");
 	month = DOF2_GetInt(folder, "month");
	year  = DOF2_GetInt(folder, "year");

	hour    = DOF2_GetInt(folder, "hour");
	minute  = DOF2_GetInt(folder, "minute");
	seconds = DOF2_GetInt(folder, "seconds");

	switch(typeBan)
	{
	    case BAN_ACCOUNT: format(messageFormatted, sizeof(messageFormatted), "{fcfcfc}Ol? {32a852}%s {fcfcfc}sua conta se encontra {b52410}banida {fcfcfc}de nosso servidor, veja abaixo os detalhes do banimento!\n\nStaff Responsavel: {cfd0d1}%s\n{fcfcfc}Motivo: {cfd0d1}%s\n{fcfcfc}Data: {cfd0d1}%s\n{fcfcfc}Horario: {cfd0d1}%s\n{fcfcfc}Acha seu banimento injusto? exponha o caso em nosso discord.", staff, reason, getDateFormatted(day, month, year), getHourFormatted(hour, minute, seconds));
		case BAN_IP: format(messageFormatted, sizeof(messageFormatted), "{fcfcfc}Ol? %s {fcfcfc}seu ip se encontra {b52410}banido {fcfcfc}de nosso servidor, veja abaixo os detalhes do banimento!\n\nStaff Responsavel: {cfd0d1}%s\n{fcfcfc}Motivo: {cfd0d1}%s\n{fcfcfc}Data: {cfd0d1}%s\n{fcfcfc}Horario: {cfd0d1}%s\n{fcfcfc}Acha seu banimento injusto? exponha o caso em nosso discord.", staff, reason, getDateFormatted(day, month, year), getHourFormatted(hour, minute, seconds));
	}
	
	ShowPlayerDialog(playerid, DIALOG_BANS, DIALOG_STYLE_MSGBOX, "Conta Banida", messageFormatted, "Ok", "-");
	
	kickEx(playerid);
}

verifyTypeBanned(playerid, folder_Ban[])
{
	format(folder_Ban, 30, "%s", getFolder(playerid, FOLDER_BANS));
	
	if(DOF2_FileExists(folder_Ban))
	{
	   	return BAN_ACCOUNT;
	}
	
	format(folder_Ban, 30, "%s", getFolder(playerid, FOLDER_BANS_IP));
	
	if(DOF2_FileExists(folder_Ban))
	{
	    return BAN_IP;
	}
	
	return -1;
}

verifyLogin(playerid)
{
	new typeBanned, folder[30];
	
	typeBanned = verifyTypeBanned(playerid, folder);
	
	if(typeBanned == -1)
	{
		if(DOF2_FileExists(getFolder(playerid, FOLDER_ACCOUNT)))
		{
		    showDialogLogin(playerid);
		}
		else
		{
		    showDialogRegister(playerid);
		}
	}
	else
	{
	    showDetailsBan(playerid, typeBanned, folder);
	}
}

convertTimer(number)
{
    new timer[5], formatted[75];

    timer[4] = number - gettime();
    timer[0] = timer[4] / 3600;
    timer[1] = ((timer[4] / 60) - (timer[0] * 60));
    timer[2] = (timer[4] - ((timer[0] * 3600) + (timer[1] * 60)));
    timer[3] = (timer[0]/24);

    if(timer[3] > 0)
    {
        timer[0] = timer[0] % 24,
        format(formatted, sizeof(formatted), "%ddias, %02dh %02dm e %02ds", timer[3], timer[0], timer[1], timer[2]);
    }
        
    else if(timer[0] > 0)
    {
        format(formatted, sizeof(formatted), "%02dh %02dm e %02ds", timer[0], timer[1], timer[2]);
    }
        
    else
    {
        format(formatted, sizeof(formatted), "%02dm e %02ds", timer[1], timer[2]);
    }
        
    return formatted;
}

