%% @author Tobias Ericsson <tobiasericsson90@hotmail.com>
%% @author Andreas Hammar <andreashammar@gmail.com>
%% @author Gabriella Lundborg <gabriella_lundborg@hotmail.com>
%% @author Emma Rangert <emma.rangert@gmail.com>ß
%% @author John Reuterswärd <rojters@gmail.com>
%% @author Simon Young <youngen.simon@gmail.com>
%% @doc this module contains all the functions that is related to the game room.

-module(game_room).
-export([init/2, room/3, handleInput/6, commandParser/5, sendMessage/3, printPlayers/1, sendToClient/2]).
-include_lib("eunit/include/eunit.hrl").

%% @doc initiates the game room
%% @spec init(Game,GameName) -> room(Game,GAmeName,PlayerList)

init(Game, GameName) ->
    srv ! {debug, "New game room spawned."},
    srv ! {getSameStatus, [game, Game], self()},
    receive
	{statusList, PlayersList} ->
	    room(Game, GameName, PlayersList)
    end.
	
%% @doc the game room, it handles data between users.

room(Game, GameName, PlayerList) ->
    receive
	{newPlayer, Pid, Alias} ->
	    srv ! {debug, "New player added to "++GameName++" room"},
	    Pid ! {message, GameName, "Welcome to "++GameName++" game room!\n\n"
								++"Available commands are: /players, /quit\n"},
	    sendMessage(PlayerList, "", Alias++" has joined the room"),
	    NewPlayerList = [{Pid, Alias, [game, Game]} | PlayerList];
	{quitPlayer, Pid, Alias} ->
	    NewPlayerList = lists:keydelete(Pid, 1, PlayerList),
	    srv ! {setStatus, Pid, Alias, [main]},
	    sendMessage(PlayerList, "", Alias++" has left the room.");
	{input, Pid, Alias, Input} ->
	    srv ! {debug, "Handle player input "++GameName++" room"},
	    spawn(game_room,handleInput, [self(), Input, Pid, Alias, PlayerList, Game]),
	    NewPlayerList = PlayerList		
    end,
    room(Game, GameName, NewPlayerList).

%% @doc handles the input depending on if it starts with "/" or not
%% @hidden

handleInput(RoomPid, Input, Pid, Alias, PlayerList, Game) ->
    if 
	[hd(Input)] == "/" ->
	    commandParser(Input,Pid,Alias, PlayerList, Game);
	true ->
%	    spawn(game_room,sendMessage,[PlayerList,Alias,Input])
    ok
	end.

%% @doc this function decides which command the user wants to input.
%% @hidden
	
commandParser([_ | Input], Pid, Alias, PlayerList, Game) ->
    {Command,Params} = lists:splitwith(fun(A) -> A /= 32 end, Input),
    case Command of
	"challenge" ->
	    {challenge, Params};
	"quit" ->
	    Game ! {quitPlayer, Pid, Alias},
	    Pid ! {back};
	"players" ->
		AliasList = lists:sort([X || {_, X, _} <- PlayerList]),	
	    Pid ! {printPlayers, AliasList};
%		sendToClient(Pid, AliasList);
	_ ->
		Pid ! {message, "", "Invalid Command."}
	end.

%% @doc prints all the players in the game room

printPlayers([]) -> ok;
printPlayers([Alias | AliasList]) ->
    io:format("~w ", [Alias]),
    printPlayers(AliasList).

%% @doc sends a message to all the users in the game room.
%% @hidden

sendMessage([], _, _) ->
    ok;
sendMessage([{H, User, _} | T], Alias, Message) ->
    if 
	User == Alias ->
	    ok;
	true ->
	    H ! {message, Alias, Message}
    end,
    sendMessage(T, Alias, Message).

sendToClient(Pid, Message) ->
    Pid ! {directMessage, Message}.

