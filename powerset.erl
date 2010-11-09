%%%----------------------------------------------------------------------
%%% Description: A (pretty geeky) powerset function benchmarking module.
%%% Authors: Alkis Gotovos, Maria Christakis
%%%----------------------------------------------------------------------

-module(powerset).
-export([run/0, cons/2]).

%%%----------------------------------------------------------------------
%%% Definitions
%%%----------------------------------------------------------------------

%% List of functions to benchmark.
-define(BENCH_FUNS,
	[fun(X) -> ps1(X) end,
	 fun(X) -> ps2(X) end,
         fun(X) -> ps3(X) end,
         fun(X) -> ps4(X) end,
         fun(X) -> ps5(X) end]).

%% List of lists to use for benchmarking.
-define(BENCH_LISTS,
        [lists:seq(1, 8),
         lists:seq(1, 9),
         lists:seq(1, 10),
         lists:seq(1, 20),
         lists:seq(1, 21),
         lists:seq(1, 22),
         lists:seq(1, 23),
	 lists:seq(1, 24),
	 lists:seq(1, 25)]).

%%%----------------------------------------------------------------------
%%% Exported
%%%----------------------------------------------------------------------

-spec run() -> ['ok'] | 'error'.

run() -> run(?BENCH_FUNS).	 

run(Funs) ->
    case test(Funs, ok) of
	ok -> [bench(List, Funs) || List <- ?BENCH_LISTS];
	error -> error
    end.

%%%----------------------------------------------------------------------
%%% Testing and benchmarking tools
%%%----------------------------------------------------------------------

test([], Flag) -> Flag;
test([H | T], Flag) ->
    Correct = [[], [1], [1,2], [1,2,3], [1,3], [2], [2,3], [3]],
    io:format("Testing ~p...", [H]),
    try lists:sort(H([1, 2, 3])) of
	Correct ->
	    io:format(" ok~n"),
	    test(T, Flag);
	_Any ->
	    io:format(" error~n"),
	    test(T, error)
    catch
	_:_ ->
	    io:format(" error~n"),
	    test(T, error)
    end.

bench(_List, []) -> ok;
bench(List, [H | T]) ->
    io:format("Benchmarking ~p (length ~p)...", [H, length(List)]),
    {T1, _} = statistics(wall_clock),
    H(List),
    {T2, _} = statistics(wall_clock),
    {Mins, Secs} = elapsed_time(T1, T2),
    io:format(" done in ~wm~.2fs~n", [Mins, Secs]),
    bench(List, T).

elapsed_time(T1, T2) ->
    ElapsedTime = T2 - T1,
    Mins = ElapsedTime div 60000,
    Secs = (ElapsedTime rem 60000) / 1000,
    {Mins, Secs}.

%%%----------------------------------------------------------------------
%%% Powerset function implementations
%%%----------------------------------------------------------------------

ps1([]) -> [[]];
ps1([H | T]) -> P = ps1(T), [[H | X] || X <- P] ++ P.

ps2([]) -> [[]];
ps2([H | T]) -> P = ps2(T), ps2aux(H, P, []).

ps2aux(_Head, [], Acc) -> Acc;
ps2aux(Head, [H | T], Acc) -> ps2aux(Head, T, [H, [Head | H] | Acc]).

ps3([]) -> [[]];
ps3([H | T]) -> P = ps3(T), rpc:pmap({?MODULE, cons}, [H], P) ++ P.

-spec cons([any()], any()) -> [any(),...].

cons(T, H) -> [H | T].

ps4(Lst) ->
    N = length(Lst),
    Max = trunc(math:pow(2, N)),
    [[lists:nth(Pos + 1, Lst) || Pos <- lists:seq(0, N - 1),
                               I band (1 bsl Pos) =/= 0]
     || I <- lists:seq(0, Max - 1)].

ps5([]) -> [[]];
ps5(L)  -> lists:usort([[]|[[E] || E <- L]] ++ ps5aux(L, L, [])).

ps5aux([], _L, Acc) -> Acc;
ps5aux([H | T], L, Acc) ->
    ps5aux(T, L, [lists:usort([H | E]) || E <- ps5(L -- [H])] ++ Acc).


