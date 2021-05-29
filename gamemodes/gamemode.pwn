
#include <a_samp>
#include <DOF2>

// --- Defines Dialog --

#define DIALOG_LOGIN 		0
#define DIALOG_REGISTER 	1

// -- Defines Folders --

#define FOLDER_ACCOUNT      "Contas/%s.ini"

const COD_ERROR_LOGIN 	 = 0;
const COD_ERROR_REGISTER = 1;

enum p_Info {
	pMoney,
	pLevel,
	pLevelStaff,
}

enum s_Error {
	s_CodeError,
	s_MessageError[48]
}

new playerInfo[MAX_PLAYERS][p_Info];

static const Errors[][s_Error] = {
	{COD_ERROR_LOGIN, 	 "Senha inserida incorreta, favor tente novamente"},
	{COD_ERROR_REGISTER, "Sua senha deve conter no minimo 4 caracteres"}
};

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

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
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

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

// -- Functions --

getPlayerName(playerid) {
	static name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));

	return name;
}

getPlayerAccount(playerid) {
	static stringFormatted[MAX_PLAYER_NAME + 13];

	format(stringFormatted, sizeof(stringFormatted), FOLDER_ACCOUNT, getPlayerName(playerid));

	return stringFormatted;
}

clearChat(playerid) {
	for(new i = 0; i < 20; i ++) {
	    SendClientMessage(playerid, -1, "");
	}
}

defaultMessage(playerid, accountExists) {

	new stringFormatted[120 + 15 + MAX_PLAYER_NAME], statusAccount[15];

	format(statusAccount, sizeof(statusAccount), "%s", accountExists ? ("Registrada") : ("Nao registrada"));

	format(stringFormatted, sizeof(stringFormatted), "\n\n{fcfcfc}Status da Conta: {cfd0d1}%s \n\n{fcfcfc}Discord: {cfd0d1}discord.gg/pQazmUVcJF \n\n{fcfcfc}Nick: {cfd0d1}%s", statusAccount, getPlayerName(playerid));

	return stringFormatted;
}

showDialogRegister(playerid, codeError = -1) {

	new messageDialog[300];

  	format(messageDialog, sizeof(messageDialog), "{fcfcfc}Ola {32a852}%s {fcfcfc}seja bem vindo a {799dc9}ZonePerfect\n{fcfcfc}Verificamos que sua conta nao esta cadastrada, realize o cadastro para continuar.", getPlayerName(playerid));

	strcat(messageDialog, defaultMessage(playerid, false));

	if(codeError != -1) {
		strcat(messageDialog, Errors[codeError][s_MessageError]);
	}

	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registro", messageDialog, "Registrar", "Sair");
}

showDialogLogin(playerid, codeError = -1) {

	new messageDialog[300];

	format(messageDialog, sizeof(messageDialog), "{fcfcfc}Ola {32a852}%s {fcfcfc}seja bem vindo a {799dc9}ZonePerfect\nSua conta se encontra registrada em onsso servidor, realize o login para continuar.", getPlayerName(playerid));

	strcat(messageDialog, defaultMessage(playerid, true));

	if(codeError != -1) {
		strcat(messageDialog, Errors[codeError][s_MessageError]);
	}

	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Login", messageDialog, "Login", "Sair");
}

verifyLogin(playerid) {
	if(DOF2_FileExists(getPlayerAccount(playerid))) {
	    showDialogLogin(playerid);
	} else {
	    showDialogRegister(playerid);
	}
}

