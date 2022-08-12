//+------------------------------------------------------------------+
//|                                               MadRabbit_VWAP.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"



#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "VWAP MadRabbit"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFuchsia
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum DATE_TYPE 
  {
   DAILY,
   WEEKLY,
   MONTHLY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_TYPE 
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CreateDateTime(DATE_TYPE nReturnType=DAILY,datetime dtDay=D'2000.01.01 00:00:00',int pHour=0,int pMinute=0,int pSecond=0) 
  {
   datetime    dtReturnDate;
   MqlDateTime timeStruct;

   TimeToStruct(dtDay,timeStruct);
   timeStruct.hour = pHour;
   timeStruct.min  = pMinute;
   timeStruct.sec  = pSecond;
   dtReturnDate=(StructToTime(timeStruct));

    return dtReturnDate;
  }

input PRICE_TYPE iPricetype        = CLOSE_HIGH_LOW;



bool            Calc_Every_Tick     = false;
bool            Enable_Daily        = true;
bool            Show_Daily_Value    = true;
double          VWAP_Buffer_Daily[];
double          nPriceArr[],nTotalTPV[],nTotalVol[];
double          nSumDailyTPV = 0, nSumWeeklyTPV = 0, nSumMonthlyTPV = 0;
double          nSumDailyVol = 0, nSumWeeklyVol = 0, nSumMonthlyVol = 0;
int             nIdxDaily=0,nIdxWeekly=0,nIdxMonthly=0,nIdx=0;
bool            bIsFirstRun=true;
string          sDailyStr = "";
datetime        dtLastDay = CreateDateTime(DAILY), dtLastWeek = CreateDateTime(WEEKLY), dtLastMonth = CreateDateTime(MONTHLY);
ENUM_TIMEFRAMES LastTimePeriod=PERIOD_MN1;
int             nStringYDistance=40;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() 
  {
   
 //  SymbolSelect("WINQ20",true);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   SetIndexBuffer(0,VWAP_Buffer_Daily,INDICATOR_DATA);
 

      ObjectCreate(0,"VWAP_Daily",OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_CORNER,3);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_XDISTANCE,180);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_YDISTANCE,nStringYDistance);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_COLOR,indicator_color1);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_FONTSIZE,7);
      ObjectSetString(0,"VWAP_Daily",OBJPROP_FONT,"Verdana");
      ObjectSetString(0,"VWAP_Daily",OBJPROP_TEXT," ");
      nStringYDistance=nStringYDistance+20;
    
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int pReason) 
  {
  ObjectDelete(0,"VWAP_Daily");
 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[]) 
  {

   if(PERIOD_CURRENT!=LastTimePeriod) 
     {
      bIsFirstRun=true;
      LastTimePeriod=PERIOD_CURRENT;
     }

   if(rates_total>prev_calculated || bIsFirstRun || Calc_Every_Tick) 
     {
      ArrayResize(nPriceArr,rates_total);
      ArrayResize(nTotalTPV,rates_total);
      ArrayResize(nTotalVol,rates_total);

        nIdx = nIdxDaily;   
        nSumDailyTPV = 0;   
        nSumDailyVol = 0;
     

      for(; nIdx<rates_total; nIdx++) 
        {
         VWAP_Buffer_Daily[nIdx]=EMPTY_VALUE;
       

         if(CreateDateTime(DAILY,time[nIdx])!=dtLastDay) 
           {
            nIdxDaily=nIdx;
            nSumDailyTPV = 0;
            nSumDailyVol = 0;
           }
         

         nPriceArr[nIdx] = 0;
         nTotalTPV[nIdx] = 0;
         nTotalVol[nIdx] = 0;

         switch(iPricetype) 
           {
            case OPEN:
               nPriceArr[nIdx]=open[nIdx];
               break;
            case CLOSE:
               nPriceArr[nIdx]=close[nIdx];
               break;
            case HIGH:
               nPriceArr[nIdx]=high[nIdx];
               break;
            case LOW:
               nPriceArr[nIdx]=low[nIdx];
               break;
            case HIGH_LOW:
               nPriceArr[nIdx]=(high[nIdx]+low[nIdx])/2;
               break;
            case OPEN_CLOSE:
               nPriceArr[nIdx]=(open[nIdx]+close[nIdx])/2;
               break;
            case CLOSE_HIGH_LOW:
               nPriceArr[nIdx]=(close[nIdx]+high[nIdx]+low[nIdx])/3;
               break;
            case OPEN_CLOSE_HIGH_LOW:
               nPriceArr[nIdx]=(open[nIdx]+close[nIdx]+high[nIdx]+low[nIdx])/4;
               break;
            default:
               nPriceArr[nIdx]=(close[nIdx]+high[nIdx]+low[nIdx])/3;
               break;
           }

         if(tick_volume[nIdx]) 
           {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * tick_volume[nIdx]);
            nTotalVol[nIdx] = (double)tick_volume[nIdx];
              } else if(volume[nIdx]) {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * volume[nIdx]);
            nTotalVol[nIdx] = (double)volume[nIdx];
           }

         if(Enable_Daily && (nIdx>=nIdxDaily)) 
           {
            nSumDailyTPV += nTotalTPV[nIdx];
            nSumDailyVol += nTotalVol[nIdx];

            if(nSumDailyVol)
             double test =  VWAP_Buffer_Daily[nIdx]=(nSumDailyTPV/nSumDailyVol);

            if((sDailyStr!="VWAP Daily: "+(string)NormalizeDouble(VWAP_Buffer_Daily[nIdx],_Digits)) && Show_Daily_Value) 
              {
               sDailyStr="VWAP Daily: "+(string)NormalizeDouble(VWAP_Buffer_Daily[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Daily",OBJPROP_TEXT,sDailyStr);
              }
           }

              

         dtLastDay=CreateDateTime(DAILY,time[nIdx]);
         dtLastWeek=CreateDateTime(WEEKLY,time[nIdx]);
         dtLastMonth=CreateDateTime(MONTHLY,time[nIdx]);
        }

      bIsFirstRun=false;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
