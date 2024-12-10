//=====================================================================
//	��������� ������.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "��������� ������ �� ������ ���������� NRTR."
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price	PRICE_CLOSE
#property indicator_minimum				-1.4
#property indicator_maximum				+1.4
//---------------------------------------------------------------------
#property indicator_buffers 	1
#property indicator_plots   	1
//---------------------------------------------------------------------
#property indicator_type1   	DRAW_HISTOGRAM
#property indicator_color1  	Black
#property indicator_width1		2

//---------------------------------------------------------------------
//	������� ���������� ���������:
//---------------------------------------------------------------------
input int      ATRPeriod = 40;  // ������ ATR � �����
input double   Koeff = 2.0;     // ���������� ��������� �������� ATR   
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
int         indicator_handle=0;
//---------------------------------------------------------------------
//	���������� ������� �������������:
//---------------------------------------------------------------------
int OnInit()
  {
//	������������ ������������ �����:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ATRPeriod);
   PlotIndexSetString(0,PLOT_LABEL,"NRTRTrendDetector( "+(string)ATRPeriod+", "+(string)Koeff+" )");

//	�������� ����� �������� ���������� ��� ����������� ��������� � ����:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\NRTR",ATRPeriod,Koeff);
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("������ ������������� NRTR, ��� = ",GetLastError());
      return(-1);     // ��������� ��������� ��� - ������������� ������ ��������
     }

   return(0);
  }
//---------------------------------------------------------------------
//	���������� ������� ��������������� ����������:
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
//	���������� ������� ������������� ��������� ����������:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int   start,i;

//	���� ����� ����� �� ������ ������, ��� ������ ADX, �� ������� �� ��������:
   if(_rates_total<ATRPeriod)
     {
      return(0);
     }

//	��������� ��������� ��� ��� ������� ������������� ������:
   if(_prev_calculated==0)
     {
      start=ATRPeriod;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	���� ������� �������� ������������� ������:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(_rates_total-i-1);
     }

   return(_rates_total);
  }
//---------------------------------------------------------------------
//	���������� ����������� �������� ������:
//---------------------------------------------------------------------
//	����������:
//		-1 - ����� ����;
//		+1 - ����� �����;
//		 0 - ����� �� ���������;
//---------------------------------------------------------------------
int TrendDetector(int _shift)
  {
   int    trend_direction=0;
   double Support[1];
   double Resistance[1];

//	��������� �������� ���������� NRTR � ������:
   CopyBuffer(indicator_handle,0,_shift,1,Support);
   CopyBuffer(indicator_handle,1,_shift,1,Resistance);

//	��������� �������� ����� ����������:
   if(Support[0]>0.0 && Resistance[0]==0.0)
     {
      trend_direction=1;
     }
   else if(Resistance[0]>0.0 && Support[0]==0.0)
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+