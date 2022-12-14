//+------------------------------------------------------------------+
//|                                             Martingale_teste.mq5 |
//|                                  Copyright 2020, Lauro Cerqueira |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lauro Cerqueira"
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"


#include <Trade/SymbolInfo.mqh>
CSymbolInfo simbolo;

//--inputs
input double   Volume=1;                                        // Volume Inicial
input double   mult_martingale = 2;                             //Índice inicial do multiplicador de volume
input double   vol_maximo_martingale = 10;                       //Limite de lotes

//Declaração de variável para martingale
double volumeatual = Volume;                                  //--Armazena um novo valor do volume após a verficação de martingale
ulong prova = 1;                                              // responsávbel por verificar o ticket é o mesmo  do anterior
ulong ticket_ea = 0;                                          // responsável por captar o ticket da ultima operação negativa
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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

   if(!simbolo.RefreshRates()) // Atualização dos dados do ativo
      return;                     
      if(isNewBar()) //--Função IsNewbar para evitar efetuar cálculos a cada tick e sim a cada fechamento de barra para envio de ordens

       {}// logicaoperacial - lógica de sinais do robô //

      else               // -Não sendo uma nova barra verificar funções a cada tick
        {Martingale(); } // martingale precisa ser verificado a cada tick   

  }

//+------------------------------------------------------------------+
//|       Função verifica se é uma nova barra                        |
//+------------------------------------------------------------------+
//--- Função utilizada para em conjunto com ONTICK para evitar processamento desnecessário de dados
//----Desta forma o robô só ira
bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time = 0;
//--- current time
   datetime lastbar_time = (datetime)SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time == 0)
     {
      //--- set the time and exit
      last_time = lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time != lastbar_time)
     {
      //--- memorize the time and return true
      last_time = lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
}
//+------------------------------------------------------------------+
//|  FUNÇÕES DO MÓDULO MARTINGALE                                    |
//+------------------------------------------------------------------+
void Martingale()
  {
   if(Saidadaoperacao())
     {
      if(prova != ticket_ea)   //--- intercalar a variavel ticket da função de saída para verficar eu o tícket informado da operação negativa são diferentes
         volumeatual = volumeatual * mult_martingale;
      prova = ticket_ea; //-- a variável prova recebe o novo valor do ultimo tick com resultado negativo
      if(volumeatual > vol_maximo_martingale)
         volumeatual = vol_maximo_martingale;
      Print(volumeatual);
     }
   else
      {volumeatual = Volume;}
 
 
  }
//+------------------------------------------------------------------+
//|  "Saída da operação"    (ultimo valor negativo)                  |
//+------------------------------------------------------------------+
bool Saidadaoperacao()
  {
   MqlDateTime  inicio_dia;
   datetime hora_atual = TimeCurrent(inicio_dia);
   inicio_dia.hour = 0;
   inicio_dia.min = 0;
   inicio_dia.sec = 0;
   double result = 0.0;

   if(!HistorySelect(StructToTime(inicio_dia), hora_atual))
      return (false);
    
   if(HistoryDealsTotal() == 0)
      return (false);

   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      ticket_ea = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket
      
      if(HistoryDealGetString(ticket_ea, DEAL_SYMBOL) != string(_Symbol))
         return (false);
       
      if ((HistoryDealGetInteger(ticket_ea,DEAL_ENTRY)==DEAL_ENTRY_OUT)|| (HistoryDealGetInteger(ticket_ea,DEAL_ENTRY)==DEAL_ENTRY_INOUT))
      
      {result = HistoryDealGetDouble(ticket_ea, DEAL_PROFIT);
     
      break;
      }  // --- interrompe o laço for na primeira verificação (ultima operação de acordo com a ordem de verificação)
     }
   if(result <= -1) // verifica se o resultado da ultima operação é negativo
      return (true);

   return (false);
  }


 //SEM INVERSÃO DE MÃO 
// Utilzar a variável (volumeatual) para negociação 

/*COM INVERSÃO DE MÃO
utilizar dentro da função para inversão de mão, caputar o ultimo volume utilizado.

   if(!PositionSelect(SIMBOLO))
      return;

   long tipo = PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta
   double volume_fechamento = PositionGetDouble(POSITION_VOLUME);

 utilizar 2 ordens uma com o ultimo volume para fechar a posição (volume_fechamento) e outra ordem com 
 volume utilizado para o martingale (volumeatual)
 */ 