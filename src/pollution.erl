%%%-------------------------------------------------------------------
%%% @author countess
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2017 1:20 PM
%%%-------------------------------------------------------------------

-module(pollution).
-author("countess").

%% API
-export([crateMonitor/0, addStation/3, addValue/5, removeValue/4,getOneValue/4,getStationMean/3, getDailyMean/3]).
%%-record(station,{station_name,coordinates,measurements=[]}).
-record(measurement,{measurement_type,date,value}).

crateMonitor() -> #{}.

addStation(Name,{X,Y},Monitor) ->
  case maps:keys(maps:filter(fun({KeyN,{KeyX,KeyY}},_)->KeyN =:=Name orelse (KeyX=:=X andalso KeyY=:=Y) end,Monitor) ) of
    []-> Monitor#{{Name,{X,Y}}=>[]};
    _-> "There's already station with same name or coordinates"
  end.

addValue({X,Y},Type,Value,Date,Monitor)->
  case maps:keys(maps:filter(fun({_,{KeyX,KeyY}},_)->KeyY =:= Y andalso KeyX =:= X end, Monitor)) of
    [] -> "There's no such station";
    [H] -> Mes = maps:get(H,Monitor),
      case lists:any( fun(#measurement{measurement_type = MT, date = D, value = V})-> MT =:= Type andalso V =:= Value andalso D =:=Date end ,Mes) of
        true -> "There's already this measurement in this station";
        _ -> Monitor#{H := [#measurement{measurement_type = Type, date = Date, value = Value}|Mes]}
      end
  end;
addValue(Name,Type,Value,Date,Monitor)->
  case maps:keys(maps:filter(fun ({KeyN,{_,_}},_)->KeyN =:= Name end,Monitor)) of
    []-> "There's no such station";
    [H]-> Mes = maps:get(H,Monitor),
      case lists:any( fun(#measurement{measurement_type = MT, date = D, value = V})-> MT =:= Type andalso V =:= Value andalso D =:=Date end ,Mes) of
        true -> "There's already this measurement in this station";
        _ -> Monitor#{H := [#measurement{measurement_type = Type, date = Date, value = Value}|Mes]}
      end
  end.

removeValue({X,Y}, Date, Type,Monitor)->
  case maps:keys(maps:filter(fun({_,{KeyX,KeyY}},_)->KeyX =:=X andalso KeyY =:=Y end, Monitor)) of
    [] -> "There's no such station";
    [H]-> Mes =lists:filter(fun(#measurement{measurement_type = MT, date = D })-> MT =/= Type orelse D =/=Date end, maps:get(H,Monitor)),
        Monitor#{H:=Mes}
  end;
removeValue(Name, Date, Type,Monitor)->
  case maps:keys(maps:filter(fun ({KeyN,{_,_}},_)->KeyN =:= Name end,Monitor)) of
    [] -> "There's no such station";
    [H]-> Mes =lists:filter(fun(#measurement{measurement_type = MT, date =D })-> MT =/= Type orelse D =/=Date end, maps:get(H,Monitor)),
      Monitor#{H:=Mes}
  end.
getOneValue({X,Y},Date,Type,Monitor)->
  case maps:keys(maps:filter(fun({_,{KeyX,KeyY}},_)->KeyX =:=X andalso KeyY =:=Y end, Monitor)) of
    [] -> "There's no such station";
    [H]-> case lists:filter(fun(#measurement{measurement_type = MT, date =D })-> MT =:= Type andalso D =:=Date end, maps:get(H,Monitor) )of
            [] -> "There's no such measurement";
            [#measurement{value = V}] -> V
          end
  end;
getOneValue(Name,Date,Type,Monitor)->
  case maps:keys(maps:filter(fun ({KeyN,{_,_}},_)->KeyN =:= Name end,Monitor)) of
    [] -> "There's no such station";
    [H]-> case lists:filter(fun(#measurement{measurement_type = MT, date =D })-> MT =:= Type andalso D =:=Date end, maps:get(H,Monitor) )of
            [] -> "There's no such measurement";
            [#measurement{value = V}] -> V
          end
  end.

getStationMean({X,Y},Type,Monitor) ->
  case maps:keys(maps:filter(fun({_,{KeyX,KeyY}},_)->KeyX =:=X andalso KeyY =:=Y end, Monitor)) of
    [] -> "There's no such station";
    [H] -> Mes = [V|| #measurement{value = V} <- lists:filter(fun(#measurement{measurement_type = MT})-> MT =:= Type end,maps:get(H,Monitor) )],
           lists:sum(Mes)/length(Mes)
  end;
getStationMean(Name,Type,Monitor) ->
  case maps:keys(maps:filter(fun ({KeyN,{_,_}},_)->KeyN =:= Name end,Monitor)) of
    [] -> "There's no such station";
    [H] -> Mes = [V|| #measurement{value = V} <- lists:filter(fun(#measurement{measurement_type = MT})-> MT =:= Type end,maps:get(H,Monitor) )],
      lists:sum(Mes)/length(Mes)
  end.

getDailyMean(Type,Date,Monitor)->
  case [V||#measurement{value = V} <- lists:filter(fun(#measurement{measurement_type = MT, date = {D,_}})-> MT =:=Type andalso D =:= Date end, lists:append(maps:values(Monitor)))] of
    [] -> 0;
    List -> lists:sum(List)/length(List)
  end.
