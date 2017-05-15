%%%-------------------------------------------------------------------
%%% @author countess
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Apr 2017 10:21 AM
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("countess").

-include_lib("eunit/include/eunit.hrl").

simple_test() ->
  ?assert(true).
createMonitor_test()->
  ?assert(pollution:createMonitor()=:=#{}).
addStation_test()->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("MojaStacja",{20,10},P),
  P2 = pollution:addStation("MojaStacja",{20,10},P1),
  P3 = pollution:addStation("MojaStacja2",{20,10},P1),
  P4 = pollution:addStation("MojaStacja",{22,11},P1),
  ?assertEqual(#{{"MojaStacja",{20,10}} => []},P1),
  ?assertEqual("There's already station with same name or coordinates",P2),
  ?assertEqual("There's already station with same name or coordinates",P3),
  ?assertEqual("There's already station with same name or coordinates",P4).


addValue_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Stacja1",{22.332,31.23231}, P),
  P2 = pollution:addValue("Stacja1","PM10",58254,{{2017,05,01},{15,20,12}},P1),
  P3 = pollution:addValue("Stacja1","PM10",58254,{{2017,05,01},{15,20,12}},P2),
  P4 = pollution:addValue({22.332,31.23231},"PM10",58254,{{2017,05,01},{15,20,12}},P2),
  P5 = pollution:addValue("Stacja1","PM10",54,{{2017,05,01},{15,20,12}},P2),
  P6 = pollution:addValue("Stacja2","PM10",15,{{2015,08,17},{14,52,12}},P1),
  ?assertEqual(#{{"Stacja1",{22.332,31.23231}} =>
    [{measurement,"PM10",{{2017,5,1},{15,20,12}},58254}]},P2),
  ?assertEqual("There's already this measurement in this station", P3),
  ?assertEqual("There's already this measurement in this station", P4),
  ?assertEqual("There's already this measurement in this station", P5),
  ?assertEqual("There's no such station", P6).

removeValue_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation("Station1", {1, 2}, M1),
  M3 = pollution:addStation("Station2", {2, 3}, M2),
  M4 = pollution:addValue("Station1", "PM10",6,{{2017, 04, 11},{20, 0, 0}}, M3),
  M5 = pollution:addValue("Station1", "PM10",6,{{2017, 04, 11},{19, 0, 0}}, M4),
  M6 = pollution:removeValue("Station1", {{2017, 04, 11},{19, 0, 0}}, "PM10", M5),
  ?assertEqual(M4, M6),
  M7 = pollution:addValue("Station1", "PM25",6, {{2017, 04, 11},{20, 0, 0}}, M6),
  M8 = pollution:removeValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM25", M7),
  ?assertEqual(M6, M8),
  M9 = pollution:addValue("Station2", "PM10", 6,{{2017, 04, 11},{20, 0, 0}}, M8),
  M10 = pollution:removeValue({2,3},{{2017, 04, 11},{20, 0, 0}}, "PM10", M9),
  ?assertEqual(M8, M10),
  M11 = pollution:addValue("Station2","PM10", 6,{{2017, 04, 11},{20, 0, 0}}, M10 ),
  M12 = pollution:removeValue("Station1", {{2017, 04, 11},{18, 0, 0}}, "PM10", M11),
  ?assertEqual(M11, M12).


getOneValue_test() ->
  P = pollution:createMonitor(),
  P2 = pollution:addStation( "Station 1", {52, 32}, P),
  P3 = pollution:addStation("Station 2", {55, 32}, P2),
  P4 = pollution:addValue( "Station 1","PM2", 10.0, {{2017,5,4},{21,22,39}} , P3),
  ?assertEqual(10.0, pollution:getOneValue("Station 1", {{2017,5,4},{21,22,39}}, "PM2", P4)),
  ?assertEqual("There's no such measurement", pollution:getOneValue("Station 2", {{2017,5,4},{21,22,39}}, "PM2", P4)),
  ?assertEqual("There's no such station",pollution:getOneValue("Stacja tzrecia",{{2017,5,4},{12,58,14}}, "PM10",P4)).

getStationMean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Stacja pierwsza", {32.123,{1.582}},P),
  P2 = pollution:addStation("Stacja druga",{21.47,4.147},P1),
  P3 = pollution:addValue("Stacja pierwsza", "PM10", 4,{{2017,5,12},{12,47,58}},P2),
  P4 = pollution:addValue("Stacja pierwsza", "PM10", 8,{{2017,5,13},{12,47,58}},P3),
  P5 = pollution:addValue("Stacja pierwsza", "PM10", 2,{{2017,5,14},{12,47,58}},P4),
  P6 = pollution:addValue("Stacja pierwsza", "PM10", 2,{{2017,5,14},{21,47,58}},P5),
  ?assertEqual(4.0,pollution:getStationMean("Stacja pierwsza", "PM10",P6)).

getDailyMean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Stacja pierwsza", {32.123,{1.582}},P),
  P2 = pollution:addStation("Stacja druga",{21.47,4.147},P1),
  P3 = pollution:addValue("Stacja pierwsza", "PM10", 3,{{2017,5,12},{11,14,8}},P2),
  P4 = pollution:addValue("Stacja druga", "PM10", 1,{{2017,5,12},{15,7,23}},P3),
  P5 = pollution:addValue("Stacja pierwsza", "PM10", 2,{{2017,5,12},{12,47,58}},P4),
  P6 = pollution:addValue("Stacja druga", "PM10", 2,{{2017,5,12},{21,47,58}},P5),
  ?assertEqual(2.0,pollution:getDailyMean("PM10",{2017,5,12},P6)).

importFromCsv_test() ->
  P = pollution:importFromCsv("Dane.csv"),
  ?assertEqual(#{{"Aleje Slowackiego",{12.34212,45.123}} =>
  [{measurement,"PM12",{{2017,4,11},{15,24,3}},25.9},
    {measurement,"PM10",{{2017,4,11},{15,24,3}},25.9}],
    {"Stacja Pierwsza",{14.585,25.173}} =>
    [{measurement,"PM12",{{2017,4,11},{15,24,3}},7.0},
      {measurement,"PM10",{{2017,4,11},{15,24,3}},2.9}]}, P).






