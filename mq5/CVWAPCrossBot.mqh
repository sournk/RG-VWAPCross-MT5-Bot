//+------------------------------------------------------------------+
//|                                                CVWAPCrossBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#include <Trade\OrderInfo.mqh>
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CVWAPCrossInputs.mqh"


class CVWAPCrossBot : public CDKBaseBot<CVWAPCrossBotInputs> {
public: // SETTINGS

protected:
  datetime                   NextExecutionDT;
  CArrayLong                 PosesHistory;
    
public:
  // Constructor & init
  void                       CVWAPCrossBot::CVWAPCrossBot(void):
                               NextExecutionDT(0)
                             {};
  void                       CVWAPCrossBot::~CVWAPCrossBot(void);
  void                       CVWAPCrossBot::InitChild();
  bool                       CVWAPCrossBot::Check(void);

  // Event Handlers
  void                       CVWAPCrossBot::OnDeinit(const int reason);
  void                       CVWAPCrossBot::OnTick(void);
  void                       CVWAPCrossBot::OnTrade(void);
  void                       CVWAPCrossBot::OnTimer(void);
  double                     CVWAPCrossBot::OnTester(void);
  void                       CVWAPCrossBot::OnBar(void);
  
//  void                       CVWAPCrossBot::OnOrderPlaced(ulong _order);
//  void                       CVWAPCrossBot::OnOrderModified(ulong _order);
//  void                       CVWAPCrossBot::OnOrderDeleted(ulong _order);
//  void                       CVWAPCrossBot::OnOrderExpired(ulong _order);
//  void                       CVWAPCrossBot::OnOrderTriggered(ulong _order);
//
//  void                       CVWAPCrossBot::OnPositionOpened(ulong _position, ulong _deal);
    void                       CVWAPCrossBot::OnPositionStopLoss(ulong _position, ulong _deal);
    void                       CVWAPCrossBot::OnPositionTakeProfit(ulong _position, ulong _deal);
//  void                       CVWAPCrossBot::OnPositionClosed(ulong _position, ulong _deal);
//  void                       CVWAPCrossBot::OnPositionCloseBy(ulong _position, ulong _deal);
//  void                       CVWAPCrossBot::OnPositionModified(ulong _position);  
  
  // Bot's logic
  void                       CVWAPCrossBot::UpdateComment(const bool _ignore_interval = false);
  
  ulong                      CVWAPCrossBot::OpenPosOnSignal(ENUM_DK_POS_TYPE _dir);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CVWAPCrossBot::~CVWAPCrossBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CVWAPCrossBot::InitChild() {
  if(Inputs.IND_TYP == VWAP_INDICATOR_DAILY) {
    Inputs.IND_NAM = "Market\\Daily VWAP Indicator";
    Inputs.IndHndl = iCustom(Sym.Name(), TF, Inputs.IND_NAM,
                             Inputs.IND_APP,
                             Inputs.IND_APV);
  }
  if(Inputs.IND_TYP == VWAP_INDICATOR_SWEET) {
    Inputs.IND_NAM = "Market\\Sweet VWAP Anchored MT5";
    Inputs.IndHndl = iCustom(Sym.Name(), TF, Inputs.IND_NAM,
                             Inputs.IND_TTA,
                             Inputs.IND_APP);
  }
  
  NextExecutionDT = TimeCurrent();
  PosesHistory.Clear();
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CVWAPCrossBot::Check(void) {
  if(!CDKBaseBot<CVWAPCrossBotInputs>::Check())
    return false;
    
  if(Inputs.IndHndl < 0) {
    Logger.Critical(StringFormat("Indicator '%s' load error", Inputs.IND_NAM), true);
    return false;  
  }

  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CVWAPCrossBot::OnDeinit(const int reason) {
  IndicatorRelease(Inputs.IndHndl);
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CVWAPCrossBot::OnTick(void) {
  CDKBaseBot<CVWAPCrossBotInputs>::OnTick(); // Check new bar and show comment
  
  // 03. Channels update
  bool need_update = false;

  // 06. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CVWAPCrossBot::OnBar(void) {
  datetime dt_curr = TimeCurrent();
  
  // 00. Close pos
  if(Inputs.EXT_HCT != "") {
    datetime dt_close = StringToTime(Inputs.EXT_HCT);
    if(dt_curr >= dt_close) {
      for(int i=0;i<Poses.Total();i++) 
        Logger.Assert(Trade.PositionClose(Poses.At(i)), 
                      LSF(StringFormat("Position close by time: RET_CODE=%d; TICKET=%I64u",
                                       Trade.ResultRetcode(), Poses.At(i))),
                      WARN, ERROR);   
      for(int i=0;i<Orders.Total();i++) 
        Logger.Assert(Trade.OrderDelete(Orders.At(i)), 
                      LSF(StringFormat("Order delete by time: RET_CODE=%d; TICKET=%I64u",
                                       Trade.ResultRetcode(), Poses.At(i))),
                      WARN, ERROR);   
    }
  }
  
  // 01. Check Time Filter
  datetime dt_fr = StringToTime(Inputs.FIL_TIM_FR);
  bool fil_dt_fr = Inputs.FIL_TIM_FR != "" && dt_curr >= dt_fr;
  datetime dt_to = StringToTime(Inputs.FIL_TIM_TO);
  bool fil_dt_to = Inputs.FIL_TIM_TO != "" && dt_curr <= dt_to;
  Logger.Assert(fil_dt_to && fil_dt_fr,
                LSF(StringFormat("FILTER: Time allowed: RES=%s; TIME=[%s-%s]",
                                 (fil_dt_to && fil_dt_fr) ? "PASS" : "FILTERED_OUT",
                                 TimeToString(dt_fr),
                                 TimeToString(dt_to))),
                DEBUG, INFO);
  if(!(fil_dt_to && fil_dt_fr)) return;

  // 02. Check Next Execution (Pause)
  bool res = TimeCurrent() >= NextExecutionDT;
  Logger.Assert(res,
                LSF(StringFormat("FILTER: Pause till: RES=%s; NEXT_EXEC_DT=%s", 
                                 (TimeCurrent() >= NextExecutionDT) ? "PASS" : "FILTERED_OUT",
                                 NextExecutionDT)),
                DEBUG, INFO);
  if(!res) return;
  
  // 03. Del order in market
  COrderInfo order;
  for(int i=0;i<Orders.Total();i++) 
    if(order.Select(Orders.At(i)))
      Logger.Assert(Trade.OrderDelete(Orders.At(i)),
                    LSF(StringFormat("Order deleted: RET_CODE=%d; TICKET=%I64u", Trade.ResultRetcode(), Orders.At(i))),
                    WARN, ERROR);
  
  // 04. OpenOrders
  if(OpenPosOnSignal(BUY) > 0) return;
  if(OpenPosOnSignal(SELL) > 0) return;
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CVWAPCrossBot::OnTrade(void) {
  CDKBaseBot<CVWAPCrossBotInputs>::OnTrade();
  
  PosesHistory.Clear();
  CDKPositionInfo pos;
  for (int i=0; i<PositionsTotal(); i++) {
    if(!pos.SelectByIndex(i)) continue;
    if(pos.Magic() != Magic) continue;
    if(pos.Symbol() != Sym.Name()) continue;
    if(PosesHistory.SearchLinear(pos.Ticket()) >= 0) continue;
    PosesHistory.Add(pos.Ticket());
  }
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CVWAPCrossBot::OnTimer(void) {
  CDKBaseBot<CVWAPCrossBotInputs>::OnTimer();
  UpdateComment();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CVWAPCrossBot::OnTester(void) {
  return 0;
}

//void CVWAPCrossBot::OnOrderPlaced(ulong _order){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}
//
//void CVWAPCrossBot::OnOrderModified(ulong _order){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}
//
//void CVWAPCrossBot::OnOrderDeleted(ulong _order){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}
//
//void CVWAPCrossBot::OnOrderExpired(ulong _order){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}
//
//void CVWAPCrossBot::OnOrderTriggered(ulong _order){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}

void CVWAPCrossBot::OnPositionTakeProfit(ulong _position, ulong _deal){
  if(Inputs.FIL_PTM_TP <= 0) return;
  
  for(int i=0;i<PosesHistory.Total();i++) 
    if(PosesHistory.At(i) == _position) {
      //// If part of pos still in market => close the rest
      //CDKPositionInfo pos;
      //if(pos.SelectByTicket(_position))
      //  Logger.Assert(Trade.PositionClose(_position),
      //                LSF(StringFormat("Close partial pos: RET_CODE=%d; TICKET=%I64u", Trade.ResultRetcode(), _position)),
      //                WARN, ERROR);
                                            
      // Close order even part of TP executed   
      // https://www.mql5.com/ru/job/229538/discussion?id=1111560&comment=55357211
      for(int i=0;i<Orders.Total();i++) 
        Logger.Assert(Trade.OrderDelete(Orders.At(i)), 
                      LSF(StringFormat("Order delete by time: RET_CODE=%d; TICKET=%I64u",
                                       Trade.ResultRetcode(), Poses.At(i))),
                      WARN, ERROR);                       
      
      NextExecutionDT = TimeCurrent() + Inputs.FIL_PTM_TP*60;
      Logger.Warn(LSF(StringFormat("Pause execution by pos TP: TICKET=%I64u; NEXT_EXEC_DT=%s", _position, TimeToString(NextExecutionDT))));
      UpdateComment(true);
      break;
    }     

}

//void CVWAPCrossBot::OnPositionClosed(ulong _position, ulong _deal){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}
//
//void CVWAPCrossBot::OnPositionCloseBy(ulong _position, ulong _deal){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}
//
//void CVWAPCrossBot::OnPositionModified(ulong _position){
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}  
//  
////+------------------------------------------------------------------+
////| OnPositionOpened
////+------------------------------------------------------------------+
//void CVWAPCrossBot::OnPositionOpened(ulong _position, ulong _deal) {
//  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
//}

//+------------------------------------------------------------------+
//| OnStopLoss Handler
//+------------------------------------------------------------------+
void CVWAPCrossBot::OnPositionStopLoss(ulong _position, ulong _deal) {
  if(Inputs.FIL_PTM_SL <= 0) return;
  
  for(int i=0;i<PosesHistory.Total();i++) 
    if(PosesHistory.At(i) == _position) {
      NextExecutionDT = TimeCurrent() + Inputs.FIL_PTM_SL*60;
      Logger.Warn(LSF(StringFormat("Pause execution by pos SL: TICKET=%I64u; NEXT_EXEC_DT=%s", _position, TimeToString(NextExecutionDT))));
      UpdateComment(true);
      break;
    }     
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CVWAPCrossBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();
  if(NextExecutionDT > TimeCurrent())
    AddCommentLine(StringFormat("Режим: Пауза до %s", TimeToString(NextExecutionDT)), 0, clrPink);
  else 
    AddCommentLine("Режим: В работе", 0, clrLightGreen);
  ShowComment(_ignore_interval);     
}



//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CVWAPCrossBot::OpenPosOnSignal(ENUM_DK_POS_TYPE _dir) {
  ulong ticket = 0;
  
  double buf[];
  if(CopyBuffer(Inputs.IndHndl, Inputs.IND_BUF, 0, 1, buf) < 0) {
    Logger.Error(LSF("CopyBuffer() failed"));
    return 0;
  }
  double ind_val = buf[0];
  
  MqlRates rates_arr[];
  if(CopyRates(Sym.Name(), TF, 0, 1, rates_arr) < 0) {
    Logger.Error(LSF("CopyRated() failed"));
    return 0;
  }
  MqlRates rate = rates_arr[0];
  
  // 01. Check no pos
  ulong pos_ticket = 0;
  if(Inputs.FIL_ADD) {
    CDKPositionInfo pos;
    for(int i=0;i<Poses.Total();i++) 
      if(pos.SelectByTicket(Poses.At(i)) && pos.PositionType() == (ENUM_POSITION_TYPE)_dir){
        pos_ticket = Poses.At(i);
        break;
      }
  }
  else
    pos_ticket = (Poses.Total() > 0) ? Poses.At(0) : 0;
  Logger.Assert(pos_ticket <= 0,
                LSF(StringFormat("FILTER: Pos exists: RES=%s; DIR=%s; TICKET=%I64u", 
                                 (pos_ticket <= 0) ? "PASS" : "FILTERED_OUT",
                                 PosTypeDKToString(_dir),
                                 pos_ticket)),
                DEBUG, INFO);
  if(pos_ticket > 0) return 0;
  
  
  // 02. Checks price pos against Ind
  bool res = (_dir == BUY && rate.close > ind_val) || (_dir == SELL && rate.close < ind_val);
  Logger.Assert(res,
                LSF(StringFormat("FILTER: Price is %s indicator: RES=%s; DIR=%s; C=%f; IND=%f", 
                                 (_dir == BUY) ? "above" : "bellow", 
                                 (res) ? "PASS" : "FILTER_OUT",
                                 PosTypeDKToString(_dir),
                                 rate.close, ind_val)),
                DEBUG, INFO);
  if(!res) return 0;
  
  // 10. Place LIMIT order
  ENUM_ORDER_TYPE order_type = (_dir == BUY) ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
  double ep = Sym.AddToPrice((ENUM_POSITION_TYPE)_dir, ind_val, -1*Inputs.ENT_OEP);
  double sl = Sym.AddToPrice((ENUM_POSITION_TYPE)_dir, ep, -1*Inputs.ENT_OSL);
  double tp = Sym.AddToPrice((ENUM_POSITION_TYPE)_dir, ep, Inputs.ENT_OTP);
  double lot = CalculateLotSuper(Sym.Name(), Inputs.ENT_MMT, Inputs.ENT_MMV, ep, sl);
  string comment = StringFormat("%s", Logger.Name);

  ticket = Trade.OrderOpen(Sym.Name(), order_type, lot, 0, ep, sl, tp, ORDER_TIME_GTC, 0, comment);
  Logger.Assert(ticket > 0,
                LSF(StringFormat("RET_CODE=%d; DIR=%s; TICKET=%I64u",
                                 Trade.ResultRetcode(), PosTypeDKToString(_dir), ticket)),
                INFO, ERROR);
  
  return ticket;    
}

