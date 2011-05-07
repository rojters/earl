%% @author Simon Young <youngen.simon@gmail.com>
%% @doc The Client module. This module allows a user to connect to Earl's Game Club
%% and speak to that server with client functions.
%% @todo add more client functions. Complete gamemode function.

-module(client).
-export([connect/0,wait/0, quit/0, runtest/0]).
-export([init/0]).

-include_lib("eunit/include/eunit.hrl").

%% @doc Starts the client.
%% @spec start() -> client
	     
init() ->
	io:format("~n---------------------------------------~n", []),
	io:format("------  Earl's Game Club client  ------~n", []),
	io:format("---------------------------------------~n", []),
    connect().

%% @doc connects to the server
%% @spec connect() -> {connect,Server}
connect() ->
	io:format("~nPlease enter the Earl server you wish to connect to: ~n", []),
    Input = io:get_line("> "),
    Temp = string:strip(Input, both, $\n),
    Server = list_to_atom(Temp),
    Answer = net_adm:ping(Server),
    if	
		Answer == pong -> 
			spawn(Server,client_handler,init,[self()]),
			wait();
		true -> 
			io:format("~nERROR: The specified server could not be found.~n",[]),
			connect()
    end.

wait() ->
    receive
		{quit} ->
			quit()
    end.

quit() ->
	init:stop().

%client(ClientHandler) ->
%    Command = io:get_line("> "),
%    Command2 = string:strip(Command, both, $\n), %% tar bort \n
%    command(string:tokens(Command2, " "),ClientHandler),
%    client(ClientHandler).


%% TEST CASES %%

runtest() ->
    test(),
    init:stop().
