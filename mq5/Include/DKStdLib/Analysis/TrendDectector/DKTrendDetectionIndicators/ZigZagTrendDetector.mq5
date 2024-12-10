//=====================================================================
//	��������� ������.
//=====================================================================
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.01"
#property description "��������� ������ �� ������ ���������� ZigZag."
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price	PRICE_CLOSE
#property indicator_minimum				-1.4
#property indicator_maximum				+1.4
//---------------------------------------------------------------------
#property indicator_buffers 	3
#property indicator_plots   	1
//---------------------------------------------------------------------
#property indicator_type1   	DRAW_HISTOGRAM
#property indicator_color1  	Black
#property indicator_width1		2
//---------------------------------------------------------------------
//	������� ���������� ���������:
//---------------------------------------------------------------------
input int   ExtDepth=12;
input int   ExtDeviation= 5;
input int   ExtBackstep = 3;
//---------------------------------------------------------------------
double   TrendBuffer[];
double   ZigZagHighs[];   // ������� �������� ���-����
double   ZigZagLows[ ];   // ������ �������� ���-����
//---------------------------------------------------------------------
int      indicator_handle=0;
//---------------------------------------------------------------------
//	���������� ������� �������������:
//---------------------------------------------------------------------
int OnInit()
  {
//	������������ ������������ �����:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtDepth);
   PlotIndexSetString(0,PLOT_LABEL,"ZigZagTrendDetector( "
                      +(string)ExtDepth+", "
                      +(string)ExtDeviation+", "
                      +(string) ExtBackstep+" )");

//	������ ��� �������� ��������� ���-����:
   SetIndexBuffer(1,ZigZagHighs,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ZigZagLows,INDICATOR_CALCULATIONS);

//	�������� ����� �������� ���������� ��� ����������� ��������� � ����:
   ResetLastError();
   indicator_handle=iCustom(Symbol(),PERIOD_CURRENT,"Examples\\ZigZag",ExtDepth,ExtDeviation,ExtBackstep);
   if(indicator_handle==INVALID_HANDLE)
     {
      Print("������ ������������� ZigZag, ��� = ",GetLastError());
      return(-1);     // ��������� ��������� ��� - ������������� ������ ��������
     }

   return(0);
  }
//---------------------------------------------------------------------
//	���������� ������� ��������������� ����������:
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
//	������ ����� ���������� ���-����:
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

//	���� ����� ����� �� ������ ������, ��� ����� ��� ��� ���������� �������� ���-����, �� ������� ����������:
   if(_rates_total<ExtDepth)
     {
      return(0);
     }

//	��������� ��������� ��� ��� ������� ������������� ������:
   if(_prev_calculated==0)
     {
      start=ExtDepth;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	��������� ������� � ������ �������� ���-���� � ������:
   CopyBuffer(indicator_handle,1,0,_rates_total-_prev_calculated,ZigZagHighs);
   CopyBuffer(indicator_handle,2,0,_rates_total-_prev_calculated,ZigZagLows);

//	���� ������� �������� ������������� ������:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(i);
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
double   ZigZagExtHigh[2];
double   ZigZagExtLow[2];
//---------------------------------------------------------------------
int TrendDetector(int _shift)
  {
   int   trend_direction=0;

//	���� ��������� ������ �������� ���-����:
   int   ext_high_count= 0;
   int   ext_low_count = 0;

   for(int i=_shift; i>=0; i--)
     {
      if(ZigZagHighs[i]>0.1)
        {
         if(ext_high_count<2)
           {
            ZigZagExtHigh[ext_high_count]=ZigZagHighs[i];
            ext_high_count++;
           }
        }
      else if(ZigZagLows[i]>0.1)
        {
         if(ext_low_count<2)
           {
            ZigZagExtLow[ext_low_count]=ZigZagLows[i];
            ext_low_count++;
           }
        }
      //	���� ��� ���� ����������� �������, �� ���� ���������:
      if(ext_low_count==2 && ext_high_count==2)
        {
         break;
        }
     }

//	���� ����������� ����� ����������� �� �������, �� ����� ���������� �� ��������:
   if(ext_low_count!=2 || ext_high_count!=2)
     {
      return(trend_direction);
     }

//	�������� ���������� ������� ���:
   if(ZigZagExtHigh[0]>ZigZagExtHigh[1] && ZigZagExtLow[0]>ZigZagExtLow[1])
     {
      trend_direction=1;
     }
   else if(ZigZagExtHigh[0]<ZigZagExtHigh[1] && ZigZagExtLow[0]<ZigZagExtLow[1])
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+
