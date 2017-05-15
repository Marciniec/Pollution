%%%-------------------------------------------------------------------
%%% @author countess
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. May 2017 10:15 PM
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("countess").

%% API
-export([start/0,loop/1,getData/0,stop/0,addValue/4,addStation/2,removeValue/3, getOneValue/3, getStationMean/2,getDailyMean/2, importFromCsv/1]).

start() ->
  Monitor = pollution:createMonitor(),
  register(server, spawn(?MODULE, loop, [Monitor])).

loop(Monitor) ->
  receive
    {request, Pid, addStation, Name, {X,Y}}->
     P = pollution:addStation(Name,{X,Y}, Monitor),
     loop(P);
    {request, Pid, addValue, {X,Y},Type,Value,Date} ->
      P = pollution:addValue({X,Y},Type,Value,Date, Monitor),
      loop(P);
    {request, Pid, addValue, Name,Type,Value,Date} ->
      P = pollution:addValue(Name,Type,Value,Date, Monitor),
      loop(P);
    {request, Pid, removeValue,{X,Y}, Date, Type} ->
      P = pollution:removeValue({X,Y}, Date, Type, Monitor),
      loop(P);
    {request, Pid, removeValue, Name, Date, Type} ->
      P = pollution:removeValue(Name, Date, Type, Monitor),
      loop(P);
    {request, Pid, getOneValue,{X,Y},Date,Type} ->
      P = pollution:getOneValue({X,Y},Date,Type, Monitor),
      Pid ! {response, P},
      loop(Monitor);
    {request,Pid, getOneValue,Name,Date,Type} ->
      P = pollution:getOneValue(Name,Date,Type, Monitor),
      Pid ! {response, P},
      loop(Monitor);
    {request, Pid, getStationMean,{X,Y},Type}->
      P = pollution:getStationMean({X,Y},Type, Monitor),
      Pid ! {response, P},
      loop(Monitor);
    {request, Pid, getStationMean, Name, Type} ->
      P = pollution:getStationMean(Name, Type, Monitor),
      Pid ! {response, P},
      loop(Monitor);
    {request, Pid, getDailyMean, Type,Date} ->
      P = pollution:getDailyMean(Type,Date, Monitor),
      Pid ! {response, P},
      loop(Monitor);
    {request, Pid, importFromCsv, File} ->
      P = pollution:importFromCsv(File),
      loop(P);
    {request, Pid, quit} ->
      ok;
    _ -> io:format("Something went wrong"),
      loop(Monitor)
  end.

stop()->
  server ! {request, self(), quit}.
getData() ->
  receive
    {response, Data}-> Data;
    _ -> io:format("Something went wrong")
    after
      1000 -> io:format("Did not received any data")
  end.

addStation(Name, {X,Y}) ->
  server ! {request, self() ,addStation, Name, {X,Y}}.
addValue({X,Y},Type,Value,Date) ->
  server ! {request, self(),addValue, {X,Y},Type,Value,Date};
addValue(Name,Type,Value,Date) ->
  server ! {request, self(),addValue, Name,Type,Value,Date}.
removeValue({X,Y}, Date, Type) ->
  server ! {request, self(), removeValue,{X,Y}, Date, Type};
removeValue(Name, Date, Type) ->
  server ! {request, self(), removeValue,Name, Date, Type}.
getOneValue ({X,Y},Date,Type) ->
  server ! {request, self(), getOneValue, {X,Y},Date,Type},
  getData();
getOneValue (Name,Date,Type) ->
  server ! {request, self(),getOneValue, Name,Date,Type},
  getData().
getStationMean({X,Y},Type) ->
  server ! {request, self(),getStationMean,{X,Y},Type},
  getData();
getStationMean(Name,Type) ->
  server ! {request, self(),getStationMean,Name,Type},
  getData().
getDailyMean(Type,Date) ->
  server ! {request, self(),getDailyMean, Type, Date},
  getData().
importFromCsv(File)->
  server ! {request, self(), importFromCsv, File}.
