-module(guess_the_number).
-export([init/1, nextTurn/3, checkFinished/2]).

init(Players) -> 
    random:seed(erlang:now()),
    The_number = random:uniform(100),
    Message = "\nWelcome to Guess The Number! Guess a number between 0 and 100.\n",
    gameAPI:print(Message,Players),
	{gameInProgress, The_number, {noPid, noPlayer}}.

nextTurn({_,The_number,_}, {PlayerPid, PlayerAlias}, Players) ->
    Remaining = lists:keydelete(PlayerPid, 1, Players),
	gameAPI:print("Your turn!", [{PlayerPid, PlayerAlias}]),
	gameAPI:print(PlayerAlias ++ "'s turn", Remaining),
    gameAPI:print("Guess the number: ", [{PlayerPid, PlayerAlias}]),
    The_guess = (gameAPI:getNumber(PlayerPid)),
	if
		is_pid(The_guess) ->
			gameAPI:print(element(2,lists:keyfind(The_guess, 1, Players)) ++ " has left the game", Players),
			{gameOver, The_number, hd(Remaining)};
		The_guess == The_number ->
			gameAPI:print(PlayerAlias ++ " guessed " ++ integer_to_list(The_guess), Remaining),
			gameAPI:print("That's the right number!!\n", Players),
			{gameOver, The_number, {PlayerPid, PlayerAlias}};
		The_guess < The_number ->
			gameAPI:print(PlayerAlias ++ " guessed " ++ integer_to_list(The_guess), Remaining),
			gameAPI:print("The number is bigger!\n", Players),
			{gameInProgress, The_number, {PlayerPid, PlayerAlias}};
		true ->
			gameAPI:print(PlayerAlias ++ " guessed " ++ integer_to_list(The_guess), Remaining),
			gameAPI:print("The number is smaller!\n", Players),
			{gameInProgress, The_number, {PlayerPid, PlayerAlias}}   
    end.

checkFinished({GameState,_, Player}, _) ->
    case GameState of
	gameOver ->
	    {true, Player};
	gameInProgress ->
	    {false}
    end.
		
