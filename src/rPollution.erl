%%%-------------------------------------------------------------------
%%% @author countess
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. May 2017 10:39 AM
%%%-------------------------------------------------------------------
-module(rPollution).
-behaviour(gen_server).
-version('1.0').
-author("countess").

%% API
-export([start_link/0, init/1, addStation/2, terminate/2, handle_call/3, addValue/4,removeValue/3,getOneValue/3,getStationMean/2, getDailyMean/2,importFromCsv/1]).

-export([crash/0, handle_cast/2, handle_info/2, code_change/3]).
-define(SERVER, rPollution).
-record(state,{}).

-spec(start_link() ->
  {ok, Pid :: pid()} | ignore |{error, Reason :: term()}).
start_link()->
  gen_server:start_link({local, rPollution}, rPollution, [],[]).
-spec(init(Args :: term()) ->
{ok,State :: #state{}} | {ok,State :: #state{}, timeout() | hibernate}|
{stop, Reason :: term()} | ignore).
init(_) ->
  {ok, pollution:createMonitor()}.

addStation(Name, {X,Y}) ->
  gen_server:call(rPollution,{addStation, Name, {X,Y}}).
addValue({X,Y},Type,Value,Date)->
  gen_server:call(rPollution,{addValue, {X,Y},Type,Value,Date});
addValue(Name,Type,Value,Date)->
  gen_server:call(rPollution,{addValue, Name,Type,Value,Date}).
removeValue({X,Y}, Date, Type)->
  gen_server:call(rPollution, {removeValue, {X,Y},Date,Type});
removeValue(Name, Date, Type)->
  gen_server:call(rPollution, {removeValue, Name,Date,Type}).
getOneValue({X,Y},Date,Type)->
  gen_server:call(rPollution,{getOneValue,{X,Y},Date,Type});
getOneValue(Name,Date,Type)->
  gen_server:call(rPollution,{getOneValue,Name,Date,Type}).
getStationMean({X,Y},Type) ->
  gen_server:call(rPollution,{getStationMean,{X,Y},Type});
getStationMean(Name,Type) ->
  gen_server:call(rPollution,{getStationMean,Name,Type}).
getDailyMean(Type,Date)->
  gen_server:call(rPollution,{getStationMean,Type,Date}).
importFromCsv(File)->
  gen_server:call(rPollution,{importFromCsv,File}).
crash() -> 2/0.

-spec(handle_call((Request :: term()), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).

handle_call({addStation, Name, {X,Y}}, _From , LoopData) ->
  P = pollution:addStation(Name,{X,Y}, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
      _ -> {reply, ok, P}
  end;
handle_call({addValue,{X,Y},Type, Value, Data}, _From , LoopData) ->
  P = pollution:addValue({X,Y},Type, Value, Data, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end;
handle_call({addValue,Name,Type, Value, Data}, _From , LoopData) ->
  P = pollution:addValue(Name,Type, Value, Data, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end;
handle_call({removeValue,{X,Y},Type, Value, Data}, _From , LoopData) ->
  P = pollution:addValue({X,Y},Type, Value, Data, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end;
handle_call({removeValue,Name,Type, Value, Data}, _From , LoopData) ->
  P = pollution:addValue(Name,Type, Value, Data, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end;
handle_call({getOneValue,{X,Y},Data, Type}, _From , LoopData) ->
  P = pollution:getOneValue({X,Y}, Data,Type, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end;
handle_call({getOneValue,Name,Data, Type}, _From , LoopData) ->
  P = pollution:getOneValue(Name, Data,Type, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, LoopData}
  end;
handle_call({getStationMean,{X,Y},Type}, _From , LoopData) ->
  P = pollution:getStationMean({X,Y},Type, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, LoopData}
  end;
handle_call({getStationMean,Name,Type}, _From , LoopData) ->
  P = pollution:getStationMean(Name,Type, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, LoopData}
  end;
handle_call({getDailyMean,Type, Date}, _From , LoopData) ->
  P = pollution:getStationMean(Type,Date, LoopData),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end;
handle_call({importFromCsv,File}, _From , LoopData) ->
  P = pollution:importFromCsv(File),
  case P of
    {error, ErrMsg}-> {reply, ErrMsg, LoopData};
    _ -> {reply, ok, P}
  end.
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.