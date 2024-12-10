//=====================================================================
//	������� �� ���������� ������ ADXTrendDetector.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "������� �� ���������� ������ ADXTrendDetector."
//---------------------------------------------------------------------
//	������������ ����������:
//---------------------------------------------------------------------
#include <Trade\Trade.mqh>
//---------------------------------------------------------------------
//	������� ���������� ���������:
//---------------------------------------------------------------------
input double  Lots=0.1;
input int     PeriodADX=14;
input int     ADXTrendLevel=20;
//---------------------------------------------------------------------
int           indicator_handle=0;
//---------------------------------------------------------------------
//	���������� ������� �������������:
//---------------------------------------------------------------------
int OnInit()
  {
//	�������� ����� �������� ���������� ��� ����������� ��������� � ����:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ADXTrendDetector",PeriodADX,ADXTrendLevel);

//	���� ������������� ������ ��������, �� ��������� ��������� ���:
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("������ ������������� ADXTrendDetector, ��� = ",GetLastError());
      return(-1);
     }

   return(0);
  }
//---------------------------------------------------------------------
//	���������� ������� ��-�������������:
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
//	������ ����� ����������:
   if(indicator_handle!=INVALID_HANDLE)
     {
      IndicatorRelease(indicator_handle);
     }
  }

//---------------------------------------------------------------------
//	���������� ������� � ����������� ������ ���� �� �������� �������:
//---------------------------------------------------------------------
int   current_signal=0;
int   prev_signal=0;
bool  is_first_signal=true;
//---------------------------------------------------------------------
void OnTick()
  {
//	���� ������ ������ ����:
   if(CheckNewBar()!=1)
     {
      return;
     }

//	������� ������ �� ��������/�������� �������:
   current_signal=GetSignal();
   if(is_first_signal==true)
     {
      prev_signal=current_signal;
      is_first_signal=false;
     }

//	������� ������� �� �������� �������:
   if(PositionSelect(Symbol())==true)
     {
      //	��������, �� ���� �� ������� ��������������� �������:
      if(CheckPositionClose(current_signal)==1)
        {
         return;
        }
     }

//	��������� ������� ������� �� BUY:
   if(CheckBuySignal(current_signal,prev_signal)==1)
     {
      CTrade   trade;
      trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,Lots,SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0);
     }

//	��������� ������� ������� �� SELL:
   if(CheckSellSignal(current_signal,prev_signal)==1)
     {
      CTrade   trade;
      trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,Lots,SymbolInfoDouble(Symbol(),SYMBOL_BID),0,0);
     }

//	�������� ������� ������:
   prev_signal=current_signal;
  }
//---------------------------------------------------------------------
//	��������, �� ���� �� ������� �������:
//---------------------------------------------------------------------
//	����������:
//		0 - �������� ������� ���;
//		1 - ������� ��� ������� � ����������� �������;
//---------------------------------------------------------------------
int CheckPositionClose(int _signal)
  {
   long position_type=PositionGetInteger(POSITION_TYPE);

   if(_signal==1)
     {
      //	���� ��� ������� ������� BUY, �� �������:
      if(position_type==(long)POSITION_TYPE_BUY)
        {
         return(1);
        }
     }

   if(_signal==-1)
     {
      //	���� ��� ������� ������� SELL, �� �������:
      if(position_type==(long)POSITION_TYPE_SELL)
        {
         return(1);
        }
     }

//	�������� �������:
   CTrade   trade;
   trade.PositionClose(Symbol(),10);

   return(0);
  }
//---------------------------------------------------------------------
//	�������� ������� ������� �� BUY:
//---------------------------------------------------------------------
//	����������:
//		0 - ������� ���;
//		1 - ���� ������ �� BUY;
//---------------------------------------------------------------------
int CheckBuySignal(int _curr_signal,int _prev_signal)
  {
//	��������, ���� �� ��������� ����������� ������� �� BUY:
   if(( _curr_signal==1 && _prev_signal==0) || (_curr_signal==1 && _prev_signal==-1))
     {
      return(1);
     }

   return(0);
  }
//---------------------------------------------------------------------
//	�������� ������� ������� �� SELL:
//---------------------------------------------------------------------
//	����������:
//		0 - ������� ���;
//		1 - ���� ������ �� SELL;
//---------------------------------------------------------------------
int CheckSellSignal(int _curr_signal,int _prev_signal)
  {
//	��������, ���� �� ��������� ����������� ������� �� SELL:
   if(( _curr_signal==-1 && _prev_signal==0) || (_curr_signal==-1 && _prev_signal==1))
     {
      return(1);
     }

   return(0);
  }
//---------------------------------------------------------------------
//	��������� ������� �� ��������/�������� �������:
//---------------------------------------------------------------------
int GetSignal()
  {
   double      trend_direction[1];

//	�������� ������ �� ���������� ������:
   ResetLastError();
   if(CopyBuffer(indicator_handle,0,0,1,trend_direction)!=1)
     {
      Print("������ ����������� CopyBuffer, ��� = ",GetLastError());
      return(0);
     }

   return(( int)trend_direction[0]);
  }
//---------------------------------------------------------------------
//	���������� ������� ��������� ������ ����:
//---------------------------------------------------------------------
//	- ���� ���������� 1, �� ���� �����	���;
//---------------------------------------------------------------------
int CheckNewBar()
  {
   MqlRates      current_rates[1];

   ResetLastError();
   if(CopyRates(Symbol(),Period(),0,1,current_rates)!=1)
     {
      Print("������ ����������� CopyRates, ��� = ",GetLastError());
      return(0);
     }

   if(current_rates[0].tick_volume>1)
     {
      return(0);
     }

   return(1);
  }
//+------------------------------------------------------------------+
