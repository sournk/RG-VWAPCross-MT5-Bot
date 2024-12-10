//+------------------------------------------------------------------+
//|                                             CVWAPCrossInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include  "Include\DKStdLib\Common\DKStdLib.mqh"

enum ENUM_LTF_CONFIRM_MODE {
  LTF_CONFIRM_MODE_MACD_SIG_CROSS     = 0,    // MACD Histogram crosses Signal
  LTF_CONFIRM_MODE_RSI_EXTREME_SIMPLE = 1,    // RSI Simple Peak/Bottom
  LTF_CONFIRM_MODE_RSI_EXTREME        = 2,    // RSI Extreme Peak/Bottom
};

struct CVWAPCrossBotInputs {
  // USER INPUTS
  string                     IND_NAM;                                         // IND_NAM: Имя файла индикатора в Market без расширения
  uint                       IND_BUF;                                         // IND_BUF: Номер буфера индикатора
  
  ENUM_MM_TYPE               ENT_MMT;                                         // ENT_MMT: Money Managment Type
  double                     ENT_MMV;                                         // ENT_MMV: Lot Size
  uint                       ENT_OEP;                                         // ENT_OEP: Сдвиг EP LIMIT ордера от индикатора, пункт
  uint                       ENT_OTP;                                         // ENT_OTP: Дистанция TP LIMIT ордера от EP, пункт
  uint                       ENT_OSL;                                         // ENT_OSL: Дистанция SL LIMIT ордера от EP, пункт
  bool                       ENT_ADD;                                         // ENT_ADD: Разрешить несколько позиций (в разных направлениях)
  uint                       ENT_PTM_SL;                                      // ENT_PTM_SL: Длительность паузы после SL, мин (0-откл)  
  uint                       ENT_PTM_TP;                                      // ENT_PTM_TP: Длительность паузы после TP, мин (0-откл)  
  
  
  
  // GLOBAL VARS
  int                        IndHndl;
  
  void                       CVWAPCrossBotInputs():
                               IND_NAM("Daily VWAP Indicator"),
                               IND_BUF(0),
                               
                               ENT_MMT(ENUM_MM_TYPE_FIXED_LOT),
                               ENT_MMV(0.01),
                               ENT_OEP(100),
                               ENT_OTP(400),
                               ENT_OSL(100),
                               ENT_ADD(false),
                               ENT_PTM_SL(15),
                               ENT_PTM_TP(5),
                               
                               IndHndl(-1)
                               
                               {};
};
