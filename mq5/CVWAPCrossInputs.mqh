//+------------------------------------------------------------------+
//|                                             CVWAPCrossInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include  "Include\DKStdLib\Common\DKStdLib.mqh"

enum ENUM_VWAP_INDICATOR {
  VWAP_INDICATOR_DAILY = 0, // Daily VWAP Indicator
  VWAP_INDICATOR_SWEET = 1, // Sweet VWAP Anchored MT5
};

struct CVWAPCrossBotInputs {
  // USER INPUTS
  ENUM_VWAP_INDICATOR        IND_TYP;                                         // IND_TYP: Какой индикатор использовать  
  string                     IND_NAM;                                         // IND_NAM: Имя файла индикатора в Market без расширения
  uint                       IND_BUF;                                         // IND_BUF: Номер буфера индикатора
  datetime                   IND_TTA;                                         // IND_TTA: Time to Anchor  
  ENUM_APPLIED_PRICE         IND_APP;                                         // IND_APP: Price type
  ENUM_APPLIED_VOLUME        IND_APV;                                         // IND_APV: Volume type  

  string                     FIL_TIM_FR;                                      // FIL_TIM_FR: Время начала работы
  string                     FIL_TIM_TO;                                      // FIL_TIM_TO: Время окончания работы  
  uint                       FIL_PTM_SL;                                      // FIL_PTM_SL: Длительность паузы после SL, мин (0-откл)  
  uint                       FIL_PTM_TP;                                      // FIL_PTM_TP: Длительность паузы после TP, мин (0-откл)  
  bool                       FIL_ADD;                                         // FIL_ADD: Разрешить несколько позиций (в разных направлениях)
  
  ENUM_MM_TYPE               ENT_MMT;                                         // ENT_MMT: Money Managment Type
  double                     ENT_MMV;                                         // ENT_MMV: Lot Size
  int                        ENT_OEP;                                         // ENT_OEP: Сдвиг EP LIMIT ордера от индикатора, пункт
  uint                       ENT_OTP;                                         // ENT_OTP: Дистанция TP LIMIT ордера от EP, пункт
  uint                       ENT_OSL;                                         // ENT_OSL: Дистанция SL LIMIT ордера от EP, пункт
  
  string                     EXT_HCT;                                         // FIL_EXT_HCT: Время закрытия позиций (пусто-откл)
  
  
  
  
  // GLOBAL VARS
  int                        IndHndl;
  
  void                       CVWAPCrossBotInputs():
                               IND_TYP(VWAP_INDICATOR_DAILY),
                               IND_NAM("Market\\Daily VWAP Indicator"),
                               IND_BUF(0),
                               IND_TTA(D'2024-01-01'),
                               IND_APP(PRICE_CLOSE),
                               IND_APV(VOLUME_TICK),

                               FIL_TIM_FR(""),
                               FIL_TIM_TO(""),
                               FIL_PTM_SL(15),
                               FIL_PTM_TP(5),
                               FIL_ADD(false),                               
                               
                               ENT_MMT(ENUM_MM_TYPE_FIXED_LOT),
                               ENT_MMV(0.01),
                               ENT_OEP(100),
                               ENT_OTP(400),
                               ENT_OSL(100),
                               
                               EXT_HCT(""),
                                                              
                               IndHndl(-1)
                               
                               {};
};
