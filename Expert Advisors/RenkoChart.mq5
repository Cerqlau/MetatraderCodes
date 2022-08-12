//+------------------------------------------------------------------+
//|                                                 Simple_Panel.mq5 |
//|                                  Copyright 2020, Lauro Cerqueira |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
//--- input parameters
enum TickMode
  {
   Bid,
   Last,
  };
input datetime StartDateTime=D'2018.08.01 09:00:00';//Data e hora do início do desenho do gráfico
input string   BaseSymbol="BR-9.18";//Propriedades do símbolo que são copiadas para um símbolo personalizado
input TickMode Mode=Last;// Tipo de Tick
input int      Range=5;// Tamanho da barra Renko em pontos

#include <CustomSymbols\CustomSymbols.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

datetime curt;
bool ok=true;
long tms=0;
uint type=0;
long chart;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MqlRates ticks[];
   CustomSymbolCreate("Renko-"+Symbol(),"Renko");
   CustomRatesDelete("Renko-"+Symbol(),0,curt);
   CopyProperty("Renko-"+Symbol(),BaseSymbol);
   curt=TimeCurrent();

   MqlTick tk[];
   type=COPY_TICKS_TRADE;
   if(Mode==Bid) type=COPY_TICKS_INFO;
   int ct=CopyTicksRange(Symbol(),tk,type,StartDateTime*1000,(curt+10)*1000);
   if(ct==-1 || ct<2) {ok=false; Print("Ticks copy failed"); return(INIT_FAILED);}
   tms=tk[ct-1].time_msc;
   ArrayResize(ticks,ct);
   int limit=0;
   datetime dg=tk[0].time;
   MqlDateTime df;
   TimeToStruct(dg,df);
   df.sec=0;
   dg=StructToTime(df);
   if(type==COPY_TICKS_TRADE)
     {
      ticks[0].open=tk[0].last;
      ticks[0].low=tk[0].last;
      ticks[0].high=tk[0].last;
      ticks[0].close=tk[0].last;
      ticks[0].time=dg;
      ticks[0].spread=1;
      ticks[0].tick_volume=1;
      ticks[0].real_volume=tk[0].volume;
     }
   else
     {
      ticks[0].open=tk[0].bid;
      ticks[0].low=tk[0].bid;
      ticks[0].high=tk[0].bid;
      ticks[0].close=tk[0].bid;
      ticks[0].time=dg;
      ticks[0].spread=1;
      ticks[0].tick_volume=1;
      ticks[0].real_volume=tk[0].volume;
     }

   for(int i=1;i<ct;i++)
     {

      double ttk=tk[i].last;
      if(type==COPY_TICKS_INFO)
         ttk=tk[i].bid;
      do
        {

         datetime ds=ticks[limit].time+60;

         if(ticks[limit].low-Range*Point()>=ttk)
           {

            double h=ticks[limit].low;
            limit++;
            ticks[limit].open=h;
            ticks[limit].low=h-Range*Point();
            ticks[limit].high=h;
            ticks[limit].close=h-Range*Point();
            ticks[limit].time=ds;
            ticks[limit].spread=1;
            ticks[limit].tick_volume=1;
            ticks[limit].real_volume=tk[i].volume;
           }
         else
           {
            if(ticks[limit].high+Range*Point()<=ttk)
              {

               double h=ticks[limit].high;
               limit++;
               ticks[limit].open=h;
               ticks[limit].low=h;
               ticks[limit].high=h+Range*Point();
               ticks[limit].close=h+Range*Point();
               ticks[limit].time=ds;
               ticks[limit].spread=1;
               ticks[limit].tick_volume=1;
               ticks[limit].real_volume=tk[i].volume;
              }
            else
              {
               ticks[limit].tick_volume++;
               ticks[limit].real_volume+=tk[i].volume;
              }
           }
        }
      while(ticks[limit].high+Range*Point()<=ttk || ticks[limit].low-Range*Point()>=ttk);
     }
   limit++;

   double h=ticks[limit-1].close;
   datetime ds=ticks[limit-1].time+60;
   limit=ArraySize(ticks)-1;
   ticks[limit].open=h;
   ticks[limit].low=h;
   ticks[limit].high=h;
   ticks[limit].close=h;
   ticks[limit].time=ds;
   ticks[limit].spread=1;
   ticks[limit].tick_volume=1;
   ticks[limit].real_volume=tk[ct-1].volume;
   ArrayResize(ticks,limit+1);
   CustomRatesReplace("Renko-"+Symbol(),ticks[0].time,ticks[limit].time,ticks);
   SymbolSelect("Renko-"+Symbol(),true);
   chart=ChartOpen("Renko-"+Symbol(),PERIOD_M1);
   MqlTick tr[1];
   tr[0]=tk[ct-1];
   tr[0].time_msc=0;
   tr[0].time=ticks[limit].time;
   CustomTicksAdd("Renko-"+Symbol(),tr);
   ChartRedraw(chart);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTick tk[];
   MqlRates ticks[];
   int ct=CopyTicksRange(Symbol(),tk,type,tms,(TimeCurrent()+10)*1000);
   if(ct==-1 || ct<1) {ok=false; Print("Ticks copy failed"); return;}
   tms=tk[ct-1].time_msc;
   
   MqlRates rt[2];
   CopyRates("Renko-"+Symbol(),PERIOD_M1,0,2,rt);
   int limit=1;
   ArrayResize(ticks,ct+1000);
   ticks[0]=rt[0];
   ticks[1]=rt[1];
   for(int i=0;i<ct;i++)
     {
      double ttk=tk[i].last;
      if(type==COPY_TICKS_INFO)
         ttk=tk[i].bid;

      do
        {

         datetime ds=ticks[limit].time+60;

         if(ticks[limit-1].low-Range*Point()>=ttk)
           {

            double h=ticks[limit-1].low;
            
            ticks[limit].open=h;
            ticks[limit].low=h-Range*Point();
            ticks[limit].high=h;
            ticks[limit].close=h-Range*Point();
            
            ticks[limit].spread=1;
            ticks[limit].tick_volume++;
            ticks[limit].real_volume=ticks[limit].real_volume+tk[i].volume;;
            
            h=ticks[limit].low;
            limit++;
            ticks[limit].open=h;
            ticks[limit].low=h;
            ticks[limit].high=h;
            ticks[limit].close=h;
            ticks[limit].time=ds;
            ticks[limit].spread=1;
            ticks[limit].tick_volume=1;
            ticks[limit].real_volume=tk[i].volume;
           }
         else
           {
            if(ticks[limit-1].high+Range*Point()<=ttk)
              {
               double h=ticks[limit-1].high;
               
               ticks[limit].open=h;
               ticks[limit].low=h;
               ticks[limit].high=h+Range*Point();
               ticks[limit].close=h+Range*Point();
               
               ticks[limit].spread=1;
               ticks[limit].tick_volume++;
               ticks[limit].real_volume=ticks[limit].real_volume+tk[i].volume;
               
               h=ticks[limit].high;
               limit++;
               ticks[limit].open=h;
               ticks[limit].low=h;
               ticks[limit].high=h;
               ticks[limit].close=h;
               ticks[limit].time=ds;
               ticks[limit].spread=1;
               ticks[limit].tick_volume=1;
               ticks[limit].real_volume=tk[i].volume;
              }
            else
              {
               if(ticks[limit].open<ttk)
                 {
                  ticks[limit].high=ttk;
                  ticks[limit].close=ttk;                 
                 }
               else
                 {
                  ticks[limit].low=ttk;
                  ticks[limit].close=ttk;
                 }
               ticks[limit].tick_volume++;
               ticks[limit].real_volume+=tk[i].volume;
              }
           }
        }
      while(ticks[limit-1].high+Range*Point()<=ttk || ticks[limit-1].low-Range*Point()>=ttk);
     }
   ArrayResize(ticks,limit+1);
   CustomRatesUpdate("Renko-"+Symbol(),ticks);
   MqlTick tr[1];
   tr[0]=tk[ct-1];
   tr[0].time_msc=0;
   tr[0].time=ticks[ArraySize(ticks)-1].time;
   CustomTicksAdd("Renko-"+Symbol(),tr);
   ChartRedraw(chart);
  }
//+------------------------------------------------------------------+
