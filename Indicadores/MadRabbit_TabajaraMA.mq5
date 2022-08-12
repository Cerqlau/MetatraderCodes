//+------------------------------------------------------------------+
//|                                         MadRabbit_TabajaraMA.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MediaRapida
#property indicator_label1  "Media"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed,clrGreen,clrYellow,C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- input parameters
input int      Media=20;
//--- indicator buffers
double         MediaBuffer[];
double         MediaColors[];
double         mediavalue[];

int MC_handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MediaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MediaColors,INDICATOR_COLOR_INDEX);
   
MC_handle=iCustom(NULL,0,"Examples\\Custom Moving Average",Media,0,MODE_SMA,PRICE_CLOSE);
Print("MA_handle = ",MC_handle,"  error = ",GetLastError());

   
//--- 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
   int start;
   if(prev_calculated==0)
     {
      start=1;
        }else{
      start=prev_calculated-1;
     }
//---
   CopyBuffer(MC_handle,0,0,rates_total,MediaBuffer);
   CopyBuffer(MC_handle,0,0,rates_total,mediavalue);
  
  for(int i=start; i<rates_total; i++)
     {
      DefineColorMedia(mediavalue,i,close);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|Colors
//| 0 = Red
//| 1 = Green
//| 2 = yellow                                                             
//+------------------------------------------------------------------+
void DefineColorMedia(double &mediavalue[],int index,const double &close[])
  {
   bool Procura_Compra=(close[index]>mediavalue[index] && mediavalue[index]>mediavalue[index-1]);
   bool Procura_Venda=(close[index]<mediavalue[index] && mediavalue[index]<mediavalue[index-1]);
   if(Procura_Compra)
     {
      MediaColors[index]=1;
        }else if(Procura_Venda) {
      MediaColors[index]=0;
        }else{
      MediaColors[index]=2;
     }
  }