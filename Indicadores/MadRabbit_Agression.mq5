//+------------------------------------------------------------------+
//|                                          MadRabbit_Agression.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
