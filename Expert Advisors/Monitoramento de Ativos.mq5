//+------------------------------------------------------------------+
//|                                      Monitoramento de Ativos.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"
#include <Arrays\ArrayInt.mqh> 

// Criação das variáveis

CArrayInt handle;
int total_ativos;
double buffer[];


 


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   total_ativos= SymbolsTotal(true); // informa a quantidade de ativos na janela observação de mercado
   Print("Total de ativos: ",total_ativos); // informa na aba de informações do experta a quantidade de ativos do mercado
   for(int i=0; i<total_ativos; i++){
   Print("Ativo", i, "adicionando: ",SymbolName(i,true));}
   for(int i=0; i<total_ativos; i++){
   handle.Insert(iMA(SymbolName(i,true),_Period,50,0,MODE_SMA,PRICE_CLOSE),i);
   Print ("handle numero ",i," copiado, valor: ",handle.At(i));}
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   for(int i = 0; i<total_ativos;i++)
      {
         IndicatorRelease(handle.At(i));
      }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
// Verifica se possuimos um ativo com mais de 60 barras para analisar 
   if(Bars(_Symbol,_Period)<60) // if total bars is less than 60 bars
     {
      Alert("Não possuimos mais que 60 barras no ativo, EA será removido!!");
      return;
     }
//Verificação se temos um novo tick
   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;


   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);  // copiando a nova data file pela variável New_Time[0]
   if(copied>0) // podemos prosseguir pois foi copiada corretamente
     {
      if(Old_Time!=New_Time[0]) // se for a barra antiga então não poderá ser igual a nova barra
        {
         IsNewBar=true;  
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("Temos uma nova barra",New_Time[0]," Antiga foi em ",Old_Time);
          Old_Time=New_Time[0];            // Salvando a nova barra
        }
     }
   else
     {
      Alert("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
      return;
     }

//--- EA should only check for new trade if we have a new bar
   if(IsNewBar==false)
     {
      return;
     }

//--- Do we have enough bars to work with
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }
  
     
//=========================================================================
  
      for(int z = 0; z<total_ativos;z++)
      {
         SymbolSelect(SymbolName(z,true),true);

         CopyBuffer(handle.At(z),4,0,3,buffer);
        
         if(buffer[1] == 0.0 && buffer[2] == 1.0)
         {
            Comment("------------>>COMPRA");
            sinal_compra(z);
            //fechar posição vendidas
            //Abrir posição compra
            //return;
         }
         else if(buffer[1] == 1.0 && buffer[2] == 0.0)
         {
            Comment("------------->>VENDA");
            sinal_venda(z);
            //fechar posições compradas
            //Abrir posição vendida
            //return;
         }
        
      }
    }

//+------------------------------------------------------------------+

void sinal_compra(int posicao_ativo)
{
   string symbol = SymbolName(posicao_ativo,true);
   PlaySound("expert.wav");
   //SendMail("Call de Metatrader5",SymbolInfoString(_Symbol,SYMBOL_DESCRIPTION));
   Print("Call de Compra MT5\n",symbol,SymbolInfoString(symbol,SYMBOL_DESCRIPTION),"\n",SymbolInfoDouble(symbol,SYMBOL_LAST));
}

void sinal_venda(int posicao_ativo)
{
   string symbol = SymbolName(posicao_ativo,true);
   PlaySound("timeout.wav");
   //SendMail("Call de Metatrader5",SymbolInfoString(_Symbol,SYMBOL_DESCRIPTION));
   Print("Call de Venda MT5\n",symbol,SymbolInfoString(symbol,SYMBOL_DESCRIPTION),"\n",SymbolInfoDouble(symbol,SYMBOL_LAST));
}
   
 
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
