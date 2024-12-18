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
input  ENUM_VWAP_INDICATOR      Inp_IND_TYP                                             = VWAP_INDICATOR_DAILY;          // IND_TYP: Индикатор
       string                   Inp_IND_NAM                                             = "Market\\Daily VWAP Indicator";// IND_NAM: Путь до файла индикатора без расширения
       uint                     Inp_IND_BUF                                             = 0;                             // IND_BUF: Номер буфера индикатора
input  datetime                 Inp_IND_TTA                                             = D'2024-01-01';                 // IND_TTA: Time to Anchor
input  ENUM_APPLIED_PRICE       Inp_IND_APP                                             = PRICE_CLOSE;                   // IND_APP: Price type
input  ENUM_APPLIED_VOLUME      Inp_IND_APV                                             = VOLUME_TICK;                   // IND_APV: Volume type


input  group                    "2. ENTRY (ENT)"
       ENUM_MM_TYPE             Inp_ENT_MMT                                             = ENUM_MM_TYPE_FIXED_LOT;       // ENT_MMT: Money Managment Type
input  double                   Inp_ENT_MMV                                             = 3;                            // ENT_MMV: Lot Size
input  int                      Inp_ENT_OEP                                             = 100;                          // ENT_OEP: Сдвиг EP LIMIT ордера от индикатора, пункт
input  uint                     Inp_ENT_OSL                                             = 100;                          // ENT_OSL: Дистанция SL LIMIT ордера от EP, пункт
input  uint                     Inp_ENT_OTP                                             = 400;                          // ENT_OTP: Дистанция TP LIMIT ордера от EP, пункт

input  group                    "3. FILTER (FIL)"
input  string                   Inp_FIL_TIM_FR                                          = "10:15";                      // FIL_TIM_FR: Время начала работы 'ЧЧ:ММ' (пусто-откл)
input  string                   Inp_FIL_TIM_TO                                          = "18:40";                      // FIL_TIM_TO: Время окончания работы 'ЧЧ:ММ' (пусто-откл)
input  uint                     Inp_FIL_PTM_SL                                          = 15;                           // FIL_PTM_SL: Длительность паузы после SL, мин (0-откл)
input  uint                     Inp_FIL_PTM_TP                                          = 5;                            // FIL_PTM_TP: Длительность паузы после TP, мин (0-откл)
input  bool                     Inp_FIL_ADD                                             = false;                        // FIL_ADD: Разрешить несколько позиций (в разных направлениях)

input  group                    "4. EXIT (EXT)"
input  string                   Inp_EXT_HCT                                             = "18:39";                      // EXT_HCT: После этого времени закрывать позиции 'ЧЧ:ММ' (пусто-откл)

input  group                    "5. MISCELLANEOUS (MS)"
input  ulong                    Inp_MS_MGC                                              = 20241210;             // MS_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "RGVW";               // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);       // MS_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                                           = "";                   // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                   Inp_MS_LOG_FO                                           = "";                   // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                     Inp_MS_COM_EN                                           = true;                 // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput uint                     Inp_MS_COM_IS                                           = 5;                    // MS_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                                           = false;                // MS_COM_EW: Comment Custom Window
       
       long                     Inp_PublishDate                                         = 20241211;                          // Date of publish
       int                      Inp_DurationBeforeExpireSec                             = 10*24*60*60;                       // Duration before expire, sec       


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
  
  //if (TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
  //  logger.Critical("Test version is expired", true);
  //  return(INIT_FAILED);
  //}    
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CVWAPCrossBotInputs inputs;
  inputs.IND_TYP          = Inp_IND_TYP;
  inputs.IND_NAM          = Inp_IND_NAM;
  inputs.IND_BUF          = Inp_IND_BUF;
  inputs.IND_TTA          = Inp_IND_TTA;
  inputs.IND_APP          = Inp_IND_APP;
  inputs.IND_APV          = Inp_IND_APV;

  inputs.FIL_TIM_FR       = Inp_FIL_TIM_FR;
  inputs.FIL_TIM_TO       = Inp_FIL_TIM_TO;
  inputs.FIL_ADD          = Inp_FIL_ADD;
  inputs.FIL_PTM_SL       = Inp_FIL_PTM_SL;
  inputs.FIL_PTM_TP       = Inp_FIL_PTM_TP;
  
  inputs.ENT_MMT          = Inp_ENT_MMT;
  inputs.ENT_MMV          = Inp_ENT_MMV;
  inputs.ENT_OEP          = Inp_ENT_OEP;
  inputs.ENT_OTP          = Inp_ENT_OTP;
  inputs.ENT_OSL          = Inp_ENT_OSL;
  
  inputs.EXT_HCT          = Inp_EXT_HCT;
  
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