//+------------------------------------------------------------------+
//|                                         RG-VWAPCross-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "CVWAPCrossBot.mqh"


input  group                    "1. INDICATOR (IND)"
input  string                   Inp_IND_NAM                                            = "Daily VWAP Indicator";        // IND_NAM: Имя файла индикатора в Market без расширения
input  uint                     Inp_IND_BUF                                            = 0;                             // IND_BUF: Номер буфера индикатора

input  group                    "2. SIGNAL (SIG)"

input  group                    "3. FILTER IMPULSE PRICE ACTION (FIL)"


input  group                    "4. ENTRY (ENT)"
       ENUM_MM_TYPE             Inp_ENT_MMT                                             = ENUM_MM_TYPE_FIXED_LOT;       // ENT_MMT: Money Managment Type
input  double                   Inp_ENT_MMV                                             = 0.01;                         // ENT_MMV: Lot Size
input  uint                     Inp_ENT_OEP                                             = 100;                          // ENT_OEP: Сдвиг EP LIMIT ордера от индикатора, пункт
input  uint                     Inp_ENT_OSL                                             = 100;                          // ENT_OSL: Дистанция SL LIMIT ордера от EP, пункт
input  uint                     Inp_ENT_OTP                                             = 400;                          // ENT_OTP: Дистанция TP LIMIT ордера от EP, пункт
input  bool                     Inp_ENT_ADD                                             = false;                        // ENT_ADD: Разрешить несколько позиций (в разных направлениях)
input  uint                     Inp_ENT_PTM_SL                                          = 15;                           // ENT_PTM_SL: Длительность паузы после SL, мин (0-откл)
input  uint                     Inp_ENT_PTM_TP                                          = 5;                            // ENT_PTM_TP: Длительность паузы после TP, мин (0-откл)

input  group                    "5. EXIT (EXT)"

input  group                    "6. MISCELLANEOUS (MS)"
input  ulong                    Inp_MS_MGC                                              = 20241210;             // MS_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "RGVW";               // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);       // MS_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                                           = "";                   // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                   Inp_MS_LOG_FO                                           = "";                   // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                     Inp_MS_PHV                                              = false;                // MS_PHV: Print Historical Event Data
sinput bool                     Inp_MS_COM_EN                                           = true;                 // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput uint                     Inp_MS_COM_IS                                           = 5;                    // MS_COM_IS: Comment Interval, Sec
sinput bool                     Inp_MS_COM_CW                                           = true;                 // MS_COM_EW: Comment Custom Window


CVWAPCrossBot                   bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CVWAPCrossBotInputs inputs;
  inputs.IND_NAM          = Inp_IND_NAM;
  inputs.IND_BUF          = Inp_IND_BUF;
  
  inputs.ENT_MMT          = Inp_ENT_MMT;
  inputs.ENT_MMV          = Inp_ENT_MMV;
  inputs.ENT_OEP          = Inp_ENT_OEP;
  inputs.ENT_OTP          = Inp_ENT_OTP;
  inputs.ENT_OSL          = Inp_ENT_OSL;
  inputs.ENT_ADD          = Inp_ENT_ADD;
  inputs.ENT_PTM_SL       = Inp_ENT_PTM_SL;
  inputs.ENT_PTM_TP       = Inp_ENT_PTM_TP;
  
  bot.CommentEnable       = Inp_MS_COM_EN;
  bot.CommentIntervalSec  = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Period(), Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  EventSetTimer(Inp_MS_COM_IS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  bot.OnDeinit(reason);
  EventKillTimer();
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}