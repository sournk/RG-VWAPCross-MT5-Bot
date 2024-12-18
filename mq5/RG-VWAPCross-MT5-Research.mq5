//+------------------------------------------------------------------+
//|                                 DS-NewsBrakeout-MT5-Research.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"

#define CRARR(_arr) CreateArray(_arr)

#include <Arrays\ArrayLong.mqh>
#include <Math\Stat\Math.mqh>

#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\TradingManager\CDKSymbolInfo.mqh"





//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  string dt = "44:15:55";
  Print(StringToTime(dt));
}
