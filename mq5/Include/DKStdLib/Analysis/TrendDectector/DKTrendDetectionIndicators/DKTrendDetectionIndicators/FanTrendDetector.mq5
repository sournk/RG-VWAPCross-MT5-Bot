//=====================================================================
//	��������� ������.
//=====================================================================
//---------------------------------------------------------------------
#include <MovingAverages.mqh>
//---------------------------------------------------------------------
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "��������� ������ �� ������ ����� ���������� �������."
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
input int   MA1Period = 200; // �������� ������� ������� ���������� �������
input int   MA2Period = 50;  // �������� ������� ������ ���������� �������
input int   MA3Period = 21;  // �������� ������� ������� ���������� �������
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
//	���������� ������� �������������:
//---------------------------------------------------------------------
void OnInit()
  {
//	������������ ������������ �����:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MA1Period);
   PlotIndexSetString(0,PLOT_LABEL,"FanTrendDetector( "+(string)MA1Period+
                      ", "+(string)MA2Period+", "+(string) MA3Period+" )");
  }
//---------------------------------------------------------------------
//	���������� ������� ������������� ��������� ����������:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int start,i,max_period;

//	���� ����� ����� �� ������ ������, ��� ������ ����������, �� ������� �� ��������:
   if(_rates_total<MA1Period)
     {
      return(0);
     }

//	��������� ��������� ��� ��� ������� ������������� ������:
   if(_prev_calculated==0)
     {
      start=MA1Period;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	���� ������� �������� ������������� ������:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(i,_price);
     }

   return(_rates_total);
  }
//---------------------------------------------------------------------
//	���������� ����������� �������� ������:
//---------------------------------------------------------------------
//	����������:
//		-1 - ����� ����;
//		+1 - ����� �����;
//		 0 - ����� �� ��������;
//---------------------------------------------------------------------
int TrendDetector(int _shift,const double &_price[])
  {
   double current_ma1,current_ma2,current_ma3;
   int trend_direction=0;

   current_ma1 = SimpleMA( _shift, MA1Period, _price );
   current_ma2 = SimpleMA( _shift, MA2Period, _price );
   current_ma3 = SimpleMA( _shift, MA3Period, _price );

   if(current_ma3>current_ma2 && current_ma2>current_ma1)
     {
      trend_direction=1;
     }
   else if(current_ma3<current_ma2 && current_ma2<current_ma1)
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+