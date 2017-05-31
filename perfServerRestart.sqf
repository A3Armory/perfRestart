/*
Name: perfServerRestart.sqf
Author: Gigatek
Credit to: soulkobk (soulkobk.blogspot.com)
Creation Date: 02/07/2017

Description:
This script must be used with real_date 3.0 (http://killzonekid.com/arma-extension-real_date-dll-v3-0)
extension to get the server time on script execution! Place the real_date.dll in the same directory where your arma3server.exe is.

This script needs to be placed in the SERVER SIDE folder...
'A3Wasteland_Settings\perfServerRestart.sqf'

The following line needs to be placed in the SERVER SIDE init.sqf (found in A3Wasteland_Settings folder).
execVM (externalConfigFolder + "\perfServerRestart.sqf");

The following needs to be placed in the MISSION description.ext file.
	class CfgDebriefing
	{
		class Reboot
		{
		title = "Restarting";
		subtitle = "Thank you for playing @ Servername";
		description = "Server will save the database and restart to increase performance. The server will remain locked until done.";
		};
	};

The following line needs to be placed in the MISSION globalCompile.sqf file.
A3W_fnc_reboot = {"Reboot" call BIS_fnc_endMission} call mf_compile;

The following line needs to be placed in the MISSION init.sqf file (then re-pack the mission.pbo).
"RM_DISPLAYTEXT_PUBVAR" addPublicVariableEventHandler {(_this select 1) spawn BIS_fnc_dynamicText;};
*/

private["_commandSend","_kickAllPlayers","_restartServer","_serverCommandPass","_serverStartTime"];

diag_log format ["[SERVER RESTART] -> SCRIPT LOADED"];

_serverStartTime = call compile ("real_date" callExtension "0");

_serverCommandPass = "testing123";

_commandSend = {
	private["_command","_password","_return"];
	_command = _this;
	_password = _serverCommandPass;

	if (_password isEqualTo "") then {_password = "empty";}; 
	_return = _password serverCommand _command;
	_return
};

_kickAllPlayers = {
	private["_i"];
	for "_i" from 0 to ((playableSlotsNumber BLUFOR + playableSlotsNumber OPFOR + playableSlotsNumber INDEPENDENT) - 1) do 
	{
		format ["#kick %1", _i] call _commandSend;
		uiSleep 0.2;
	};
	true
};

_restartServer = {
	diag_log format ["[SERVER RESTART IN 30 MINUTES] -> SERVER FPS IS %1 - RESTART TRIGGERED AT %2 - TICK TIME IS %3", floor(diag_fps), _serverUpTime, floor(diag_TickTime)];
	RM_DISPLAYTEXT_PUBVAR = ["<t color='#FFFF00' size='0.65'>ATTENTION</t><br/><t size='0.65'>THE SERVER WILL RESTART IN 30 MINUTES",0,0.7,10,0];
	publicVariable "RM_DISPLAYTEXT_PUBVAR";
	uiSleep 600;

	diag_log format ["[SERVER RESTART IN 20 MINUTES] -> SERVER FPS IS %1 - TICK TIME IS %2", floor(diag_fps), floor(diag_TickTime)];
	RM_DISPLAYTEXT_PUBVAR = ["<t color='#FFFF00' size='0.65'>ATTENTION</t><br/><t size='0.65'>THE SERVER WILL RESTART IN 20 MINUTES",0,0.7,10,0];
	publicVariable "RM_DISPLAYTEXT_PUBVAR";
	uiSleep 600;

	diag_log format ["[SERVER RESTART IN 10 MINUTES] -> SERVER FPS IS %1 - TICK TIME IS %2", floor(diag_fps), floor(diag_TickTime)];
	RM_DISPLAYTEXT_PUBVAR = ["<t color='#FF5500' size='0.65'>ATTENTION</t><br/><t size='0.65'>THE SERVER WILL RESTART IN 10 MINUTES<br/><t color='#FF5500' size='0.65'>LOCK/SAVE VEHICLES AND OBJECTS IF YOU HAVEN'T ALREADY",0,0.7,10,0];
	publicVariable "RM_DISPLAYTEXT_PUBVAR";
	uiSleep 300;

	diag_log format ["[SERVER RESTART IN 5 MINUTES] -> SERVER FPS IS %1 - TICK TIME IS %2", floor(diag_fps), floor(diag_TickTime)];
	format ["#lock" call _commandSend];
	diag_log format ["[SERVER RESTART] -> SERVER LOCKED"];
	RM_DISPLAYTEXT_PUBVAR = ["<t color='#FF5500' size='0.65'>ATTENTION</t><br/><t size='0.65'>THE SERVER WILL RESTART IN 5 MINUTES<br/><t color='#FF5500' size='0.65'>LAND ALL AIR VEHICLES BEFORE RESTART",0,0.7,10,0];
	publicVariable "RM_DISPLAYTEXT_PUBVAR";
	uiSleep 180;

	diag_log format ["[SERVER RESTART IN 2 MINUTES] -> SERVER FPS IS %1 - TICK TIME IS %2", floor(diag_fps), floor(diag_TickTime)];
	RM_DISPLAYTEXT_PUBVAR = ["<t color='#FF5500' size='0.65'>ATTENTION</t><br/><t size='0.65'>THE SERVER WILL RESTART IN 2 MINUTES<br/><t color='#FF5500' size='0.65'>EXIT VEHICLE BEFORE RESTART",0,0.7,10,0];
	publicVariable "RM_DISPLAYTEXT_PUBVAR";
	uiSleep 60;

	diag_log format ["[SERVER RESTART IN 60 SECONDS] -> SERVER FPS IS %1 - TICK TIME IS %2", floor(diag_fps), floor(diag_TickTime)];
	RM_DISPLAYTEXT_PUBVAR = ["<t color='#FF5500' size='0.65'>ATTENTION</t><br/><t size='0.65'>THE SERVER WILL RESTART IN 60 SECONDS",0,0.7,10,0];
	publicVariable "RM_DISPLAYTEXT_PUBVAR";
	uiSleep 60;

	[[], "A3W_fnc_reboot", BLUFOR, true] call BIS_fnc_MP;
	[[], "A3W_fnc_reboot", OPFOR, true] call BIS_fnc_MP;
	[[], "A3W_fnc_reboot", INDEPENDENT, true] call BIS_fnc_MP;
	call fn_saveAllObjects;
	diag_log format ["[SERVER RESTART SAVED ALL OBJECTS] -> SERVER FPS IS %1 - TICK TIME IS %2", floor(diag_fps), floor(diag_TickTime)];
	uiSleep 30;
	call _kickAllPlayers;
	uiSleep 30;
	diag_log format ["[SERVER RESTART] -> SERVER SHUTDOWN"];
	format ["#shutdown" call _commandSend];
};

restartCheckActive = true;
while {restartCheckActive} do
{
	private["_currentTime","_serverFPS","_serverFPS1","_serverFPS2","_serverFPS3","_serverUpTime"];

	_currentTime = call compile ("real_date" callExtension "0");
	_serverUpTime = _currentTime - _serverStartTime;

	_serverFPS1 = diag_fps;
	uiSleep 1;
	_serverFPS2 = diag_fps;
	uiSleep 1;
	_serverFPS3 = diag_fps;

	_serverFPS = floor((_serverFPS1 + _serverFPS2 + _serverFPS3) / 3);

	If (_serverUpTime >= 9600 && _serverUpTime < 12600 && _serverFPS < 15) then // 3 hour restart
	{
		restartCheckActive = false;
		call _restartServer;
		diag_log format ["[SERVER RESTART] -> SERVER FPS IS %1 - UP TIME IS %2 - TICK TIME IS %3", _serverFPS, _serverUpTime, floor(diag_TickTime)];
	};

	If (_serverUpTime >= 12600 && _serverUpTime < 16200 && _serverFPS < 20) then // 4 hour restart
	{
		restartCheckActive = false;
		call _restartServer;
		diag_log format ["[SERVER RESTART] -> SERVER FPS IS %1 - UP TIME IS %2 - TICK TIME IS %3", _serverFPS, _serverUpTime, floor(diag_TickTime)];
	};

	If (_serverUpTime >= 16200 && _serverUpTime < 19800 && _serverFPS < 25) then // 5 hour restart
	{
		restartCheckActive = false;
		call _restartServer;
		diag_log format ["[SERVER RESTART] -> SERVER FPS IS %1 - UP TIME IS %2 - TICK TIME IS %3", _serverFPS, _serverUpTime, floor(diag_TickTime)];
	};

	If (_serverUpTime >= 19800) then // 6 hour forced restart
	{
		restartCheckActive = false;
		call _restartServer;
		diag_log format ["[SERVER RESTART] -> SERVER FPS IS %1 - UP TIME IS %2 - TICK TIME IS %3", _serverFPS, _serverUpTime, floor(diag_TickTime)];
	};

	uiSleep 300;
};