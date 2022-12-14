//+------------------------------------------------------------------+
//|                                       MAD RABBIT LAB CARCAÇA.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+

#include <SymbolTradeMadeSimple.mqh>
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Expert/Trailing/TrailingFixedPips.mqh>

// Definição dos Parâmetros
input string              nomedaestrategia ="-----";              //Nome da Estratégia
input group"                      INDICADORES"
input group"Cross MA"
input group"Média Rápida"
input  ENUM_TIMEFRAMES     period_curto = PERIOD_CURRENT;         // Time Frame
input int                  PeriodoCurto   = 9;                   // Período Média Curta
input int                  PeriodoCurto_desloc = 0;               // Deslocamento Curta
input ENUM_MA_METHOD       PeriodoCurto_meth = MODE_SMA;          // Tipo Média Curta
input ENUM_APPLIED_PRICE   PeriodoCurto_price = PRICE_CLOSE;      // Preço Media Curta
input bool                 add_fastMA     = true;                // Exibir indicador
input group"Média Lenta"
input  ENUM_TIMEFRAMES     period_longo = PERIOD_CURRENT;         // Time Frame
input int                  PeriodoLongo   = 21;                   // Período Média Longa
input int                  PeriodoLongo_desloc = 0;               // Deslocamento Longa
input ENUM_MA_METHOD       PeriodoLongo_meth = MODE_SMA;          // Tipo Média Longa
input ENUM_APPLIED_PRICE   PeriodoLongo_price = PRICE_CLOSE;     // Preço Média Longa
input bool                 add_slowMA     = true;                // Exibir indicador
input group"                  ESTRATÉGIA"
input group"Configurações  EA"
input bool     inversao       = false;                           //Inversão de Posição
input bool     everynewbar    = true;                            //Every New Bar
input bool     invertersinal  =false;                            //Sinal Invertido
input double   Volume         = 0;                               //Volume(0-Volume minimo habilitado)
enum  tipolote {Tick = 1, Pontos = 2, Finaceiro = 3};            //Enumerador tipos de calculo para lotes
input tipolote tipolotes       = Tick;                           //Tick(Todos);Pontos(Dolar);Financeiro(Ações);
input double   iSL             = 0;                              //Stop Loss
input double   iTP             = 0;                              //Take Profit
input ulong    ideviation      = 0;                              //Off Set de ordens
input ENUM_ORDER_TYPE_FILLING Tipo = ORDER_FILLING_RETURN;       //Tipo de Execução de Ordens
input ulong    magicNumber    = 12345678;                        //Magic Number
input group"Configurações  Stop Móvel"
input double   iTrailing_Start = 0;                              //Distância. 0-Desativa a função
input double   iTrailing_Step  = 0;                              //Passo
input group"Configurações  Break Even"
input double   iBreak_Even_Start = 0;                            //Distância. 0-Desativa a função
input double   iBreak_Even_Step  = 0;                            //Ganho

//--Delcaração handle
int handlemedialonga, handlemediacurta;

//--Declaração variável global de classe
CTrade negocio;
CSymbolInfo simbolo;
CTrailingFixedPips expert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//-- Set configuraçõe gerais de envio de ordem-
negocio.SetExpertMagicNumber(magicNumber);
negocio.SetTypeFilling(Tipo);
negocio.SetDeviationInPoints(ideviation);

//--- create timer
   EventSetTimer(60);
// Criação dos manipuladores
   handlemediacurta = iMA(_Symbol, period_curto, PeriodoCurto, PeriodoCurto_desloc, PeriodoCurto_meth, PeriodoCurto_price);
   handlemedialonga = iMA(_Symbol, period_longo, PeriodoLongo, PeriodoLongo_desloc, PeriodoLongo_meth, PeriodoLongo_price);

// Verificação do resultado da criação dos manipuladores
   if(handlemediacurta == INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador FAST MA"); return INIT_FAILED;}
   if(handlemedialonga == INVALID_HANDLE)
     {MessageBox("Erro na criação dos manipulador SLOW MA"); return INIT_FAILED;}

//-- Verificação de inconsistências nos parâmetros de entrada-
   if(PeriodoLongo <= PeriodoCurto && PeriodoCurto_desloc == PeriodoLongo_desloc)
     {MessageBox("Parâmetros de médias incorretos"); return INIT_FAILED;}
   if((iTrailing_Start <= 0 && iBreak_Even_Start <= 0)||(iTrailing_Start > 0 && iBreak_Even_Start == 0 && iSL <= 0) || (iTrailing_Start > 0 && iBreak_Even_Start > 0 && iTrailing_Start < iBreak_Even_Start && iSL < 0))
     {MessageBox("Parâmetros de Stop Movel incorretos"); return INIT_FAILED;}
   if(Volume==0)
     {MessageBox("Atenção!Volume minimo definido para operação");}

//--Bloco para adição de  indicador ao gráfico-
   if(add_fastMA == true){if(!ChartIndicatorAdd(0, 0, handlemediacurta))
   {MessageBox("Erro ao adiocionar FAST MA");
   return INIT_FAILED;}}
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 0));

   if(add_slowMA == true){if(!ChartIndicatorAdd(0, 0, handlemedialonga))
   {MessageBox("Erro ao adiocionar SLOW MA"); 
   return INIT_FAILED;}}
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 1));


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  //Motivo do robo ter saido
   switch(reason)
     {
      case 0:
         Print("ATENÇÃO: Motivo de remoção: O Expert Advisor terminou sua operação chamando a função ExpertRemove().");
         break;
      case 1:
         Print("ATENÇÃO: Motivo de remoção: O robo foi excluído do gráfico.");
         break;
      case 2:
         Print("ATENÇÃO: Motivo de remoção: O robo foi recompilado.");
         break;
      case 3:
         Print("ATENÇÃO: Motivo de remoção: O período do símbolo ou gráfico foi alterado.");
         break;
      case 4:
         Print("ATENÇÃO: Motivo de remoção: O gráfico foi encerrado.");
         break;
      case 5:
         Print("ATENÇÃO: Motivo de remoção: Os parâmetros de entrada foram alterados pelo usuário.");
         break;
      case 6:
         Print("ATENÇÃO: Motivo de remoção: Outra conta foi ativada ou o servidor de negociação foi reconectado devido a alterações nas configurações de conta.");
         break;
      case 7:
         Print("ATENÇÃO: Motivo de remoção: Um novo modelo foi aplicado.");
         break;
      case 8:
         Print("ATENÇÃO: Motivo de remoção: O manipulador OnInit() retornou um valor diferente de zero.");
         break;
      case 9:
         Print("ATENÇÃO: Motivo de remoção: Terminal foi fechado.");
         break;
      default:
        Print("ATENÇÃO: Motivo de remoção: Desconhecido.");
   }
//---Deletar todos os indicadores
   for(int i = ChartIndicatorsTotal(0, 0); i > 0; i--)
     {
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, ChartIndicatorsTotal(0, 0) - i));
      ChartIndicatorDelete(0, 1, ChartIndicatorName(0, 1, ChartIndicatorsTotal(0, 1) - i));
     }
//--- Deleta todos os objetos do gráfico
   ObjectsDeleteAll(0, -1, -1);
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
   if (NewCandleCheck("Actual"))
      { 
        if (SinalMedia()=="compra");
           Compra();
        if (SinalMedia()=="venda");
           Venda();
        
        Trailling();
        Breakeaven();
        
      }

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

 

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---

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

string SinalMedia()
{ 
    double buffer_curta[], buffer_longa[];
    int copy;
    ArraySetAsSeries(buffer_curta,true);
    ArraySetAsSeries(buffer_longa,true);
    copy=CopyBuffer(handlemediacurta,0,PeriodoCurto_desloc,3,buffer_curta);
    if (copy=-1)
    {Print("Erro ao copiar Buffer de média curta");}
    copy=CopyBuffer(handlemedialonga,0,PeriodoLongo_desloc,3,buffer_longa);
    if (copy=-1)
    {Print("Erro ao copiar Buffer de média longa");}
    if (buffer_curta[2]<= buffer_longa[2] && buffer_curta[1]> buffer_longa[1])
        {return("compra");}
    if (buffer_curta[2]>= buffer_longa[2] && buffer_curta[1]< buffer_longa[1])
        {return("venda");}    
    return ("nada");
} 
//+------------------------------------------------------------------+  
void Compra()
{  
   double stoploss, takeprofit;
   if (SymbolOpenPositionsTotal()==0)
     { 
      negocio.Buy(SymbolNormalizeVolume(_Symbol,Volume,true),_Symbol,SymbolNormalizePrice(_Symbol,simbolo.Ask()),Stoploss(),Takeprofit(),"Ordem de Compra à Mercado");
      Print(negocio.ResultRetcodeDescription());}
   if (SymbolOpenPositionsTotal()>0)
      {SymbolOpenPositionsClose(_Symbol,"Erro ao fechar posição");}

}

//+------------------------------------------------------------------+  
void Venda()
{
   if (SymbolOpenPositionsTotal()==0)
     { 
      negocio.Sell(SymbolNormalizeVolume(_Symbol,Volume,true),_Symbol,SymbolNormalizePrice(_Symbol,simbolo.Ask()),Stoploss(),Takeprofit(),"Ordem de Venda à Mercado");
      Print(negocio.ResultRetcodeDescription());}
   if (SymbolOpenPositionsTotal()>0)
      {SymbolOpenPositionsClose(_Symbol,"Erro ao fechar posição");}
} 

//+------------------------------------------------------------------+  
void Trailling() 
{
  /* ulong ticket1;

   if(!HistorySelect(Dia_atual(),TimeCurrent()))
      Alert("Erro Aquisição de dados para parcial");

   if(HistoryDealsTotal() > 0)
     {
      for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
        {
         ticket1 = HistoryOrderGetTicket(i); // index do último negocio e armazena em ticket

         if(HistoryDealGetString(ticket1, DEAL_SYMBOL) != string(SIMBOLO))
            continue;

         PosicaoInfo.SelectByTicket(ticket1);
         break;   // --- interrompe o laço for na primeira verificação (ultima operação de acordo com a ordem de verificação)
        }
     }
 
  
  if(iTrailing_Start>0)
  negocio.PositionModify(_Symbol,SymbolNormalizePrice(_Symbol,(Stoploss()+iTrailing_Step)));
  */
  
  if(iTrailing_Start>0)
  expert.StopLevel(iTrailing_Step*_Point);
  
}


//+------------------------------------------------------------------+  
void Breakeaven() 
{
}

//+------------------------------------------------------------------+
double Stoploss()
{  double stoploss=0;
  
  if(iSL>0)
  {
  if(SinalMedia()=="venda")
      {stoploss= SymbolNormalizePrice(_Symbol,(simbolo.Ask()+iSL));
        return stoploss;}
        
    if(SinalMedia()=="compra")
      {stoploss= SymbolNormalizePrice(_Symbol,(simbolo.Ask()-iSL));
        return stoploss;}
  }
  
  return stoploss;
}


//+------------------------------------------------------------------+
double Takeprofit()
{  double takeprofit=0;
  
  if(iTP>0)
  {
  if(SinalMedia()=="venda")
      {takeprofit= SymbolNormalizePrice(_Symbol,(simbolo.Ask()-iTP));
        return takeprofit;}
        
    if(SinalMedia()=="compra")
      {takeprofit= SymbolNormalizePrice(_Symbol,(simbolo.Ask()+iTP));
        return takeprofit;}
  }
  
  return takeprofit;
}

//+------------------------------------------------------------------+

MqlDateTime Dia_atual()

{
   MqlDateTime  inicio_dia;
   TimeCurrent(inicio_dia);
   inicio_dia.hour = 0;
   inicio_dia.min = 0;
   inicio_dia.sec = 0;
  

return inicio_dia;

}