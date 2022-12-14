//+------------------------------------------------------------------+
//|                                     Moving Average Reversion.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright "Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.0"
#property icon      "\\Images\\Mad_habitt.ico"
#property description"Este indicador visa informar a tendência do movimento \natravés da atecipação do cruzamento de médias móveis"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Up_arrow
#property indicator_label1  "Sinal de venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrchid
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Low_arrow
#property indicator_label2  "Sinal de Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkTurquoise
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

//--- input parameters
input int                 Fast_period = 9;                 //Média Rápida
input int                 Fast_desloc = 0;                // Deslocameno
input ENUM_MA_METHOD      Fast_meth  = MODE_SMA;         // Método
input ENUM_APPLIED_PRICE  Fast_price = PRICE_CLOSE;     // Preço
input int                 Low_period = 21;             //Média Lenta
input int                 Low_desloc = 1;             // Deslocamento
input ENUM_MA_METHOD      Low_meth   = MODE_SMA;     //Método
input ENUM_APPLIED_PRICE  Low_price  = PRICE_CLOSE; // Preço
input bool                SoundAlert = true;       // Aviso sonoro
//--- indicator buffers
double         Up_arrowBuffer[];
double         Low_arrowBuffer[];
double         Fast_MA[];
double         Low_MA[];

//---- Declaração de handles do indicador
int Fast_MAHandle;
int Low_MAHandle;

//---- Declaração de variável para definição de quantidade de barras iniciais do indicador

int StartBars = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//---- Cálculo de media móvel através de indicador base do sistema
   Fast_MAHandle = iMA(_Symbol,_Period,Fast_period,Fast_desloc,Fast_meth,Fast_price);
   Print ("FastMAHandle: ",Fast_MAHandle);
   Low_MAHandle  = iMA(_Symbol,_Period,Low_period,Low_desloc,Low_meth,Low_price);
   Print ("LowMAHandle: ",Low_MAHandle);
//---- Verificação se o Handle foi copiado corretamente
   if(Fast_MAHandle==INVALID_HANDLE)
      Print(" Failed to get handle of the iMA indicator");
   if(Low_MAHandle==INVALID_HANDLE)
      Print(" Failed to get handle of the iMA indicator");
// verifica qual dentre os parametros é o maior para inicialização das barras;
   StartBars=MathMax(Fast_period,Low_period);
      Print("Start bars; ", StartBars);
         
//--- indicator buffers mapping
   SetIndexBuffer(0,Up_arrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Low_arrowBuffer,INDICATOR_DATA);
   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-20);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,20);
   PlotIndexGetInteger(0,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexGetInteger(1,PLOT_DRAW_BEGIN,StartBars);
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
  

   //---- Verificando se o número de barras é suficiente para o cálculo dos indicadores.
   /*-- Se os valores iniciais forem menores no que zero a função OnCalculate terá o valor
   retorna do "0" o quer irá gerar um  alerta de erro */

   if(BarsCalculated(Fast_MAHandle)<rates_total
      || BarsCalculated(Low_MAHandle)<rates_total
      || rates_total<StartBars)
      return(0);

//---- Verificação da quantidade de barras 
int to_copy;
int limit;
int i;  

     //Print("rates total valor inicial: ", rates_total);
    //Print("prev calculated valor inicial: ", prev_calculated);
    
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      limit=rates_total-StartBars; // início com a quantidade de barras total - o maior período de média
            to_copy=rates_total; // calculated number of all bars
             //Print("Para copiar 1: ",to_copy);
             
         for( i=0; i<rates_total; i++)
              { Up_arrowBuffer[i]=EMPTY_VALUE;
                Low_arrowBuffer[i]=EMPTY_VALUE;
               // Print( "I value: ",i);   
               }          
     }
   else if(prev_calculated==rates_total)
      {
      limit=1; // starting index for calculation of new bars
      to_copy=3; // calculated number of new bars only
      // Print("Para copiar 2: ",to_copy);
      }
     else
     {
     limit=rates_total-prev_calculated; // starting index for calculation of new bars
      to_copy=limit+2; // calculated number of new bars only
      // Print("Para copiar 3: ",to_copy);
     }  
 /*---- Invertendo a indexação dos arrays para facilitar a contagem
    desta forma agora a série erá identificada como sendo "0" o identificador mais recente.*/     
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(Fast_MA,true);
   ArraySetAsSeries(Low_MA,true);
   ArraySetAsSeries(Up_arrowBuffer,true);
   ArraySetAsSeries(Low_arrowBuffer,true);
   

//--- Copiando Buffers e verificando se foram devidamente copiados
int Fast_Copied =0;
int Low_Copied = 0;
  
  
   Fast_Copied=CopyBuffer(Fast_MAHandle,0,0,to_copy,Fast_MA);
   Low_Copied=CopyBuffer(Low_MAHandle,0,0,to_copy,Low_MA);
  /* 
   Print("Buffers Low MA copiados: ",Low_Copied);
   Print("Buffers Fast MA copiados : ",Fast_Copied);
   Print("Buffers to be copied: "to_copy);
   
   
   if(Fast_Copied!=(to_copy)) //--- Faz-se necessário inserir o deslocamento para que a quantidade copiada inicial fique similar 
    {
    Print("Buffers Fast MA copiados com erro: ",Fast_Copied);
    return(0);
    }
   if( Low_Copied!=(to_copy))
   {
   Print("Buffers Low MA copiados com erro: ",Low_Copied);
   return(0);
   }
    
    //Print("Preve calculated: ",prev_calculated);
    //Print(" rates total: ",rates_total);
 */   

    
     

//--- Loop do cruzamento de médias
   int bar;
   int soundbuy=0;
   int soundsell=0;
   for(bar=limit; bar>0; bar--)
     {
    
      //Print("Bar :",bar);

      if(Fast_MA[bar] < Low_MA[bar] && Fast_MA[bar+1] > Low_MA[bar+1])
          {
         Up_arrowBuffer[bar-1] =high[bar-1];
        // Print("Sinal de venda");
          soundsell =1;
         if ((SoundAlert==true) && (soundsell==1) && bar==1)
            {PlaySound("\\Files\\Sound\\Register.wav"); Comment("Alerta de Venda"); soundsell=0;} 
           }
      if(Fast_MA[bar] > Low_MA[bar] && Fast_MA[bar+1] < Low_MA[bar+1])
          {
         Low_arrowBuffer[bar-1] = low[bar-1];
         //Print("Sinal de compra");
          if((SoundAlert==true) && (soundbuy==1) && bar==1)
            {PlaySound("\\Files\\Sound\\Register.wav"); Comment("Alerta de Venda"); soundbuy=0;}
         soundbuy =1;
          }   
     }
     
      
       
            
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
