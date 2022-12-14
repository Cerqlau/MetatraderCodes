//+------------------------------------------------------------------+
//|                                          adRabbit_MédiaMóvel.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+


#property copyright "Copyright 2020, Lauro Cerqueira  MAD RABBIT LAB inc."
#property link      "https://www.mql5.com/pt/laurocerqueira"
#property version   "1.0"
#property icon      "\\Images\\Mad_habitt.ico"
#property description " Este projeto foi desenvolvido para conta netting e utilização de sinais dos ativos Indice, Dólar e Ações.\nNão utilize em demais ativos.\nProteja seu capital utilize estratégias testadas. \nO EA possui módulo Martingale não nos responsabilizamos pelo mau uso deste. \nBONS TRADES!!!"


// Inclusão de bibliotecas utilizadas
#include <Trade/Trade_My.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Expert/Expert.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include <ClassControlPanel.mqh>
#include <SymbolTradeMadeSimple.mqh>


// Definição dos Parâmetros indicadores

input group   "---------------------------INDICADORES-----------------------------------------"
input group   "Média Rápida"
input int                  PeriodoCurto   = 10;                   // Período Média Curta
input int                  PeriodoCurto_desloc = 0;               // Deslocamento Curta
input ENUM_MA_METHOD       PeriodoCurto_meth = MODE_SMA;          // Tipo Média Curta
input ENUM_APPLIED_PRICE   PeriodoCurto_price = PRICE_CLOSE;      //  Preço Media Curta
input group   "------------------------------------------------------------------------------------"
input group   "Média Lenta"
input int                  PeriodoLongo   = 11;                   // Período Média Longa
input int                  PeriodoLongo_desloc = 0;               // Deslocamento Longa
input ENUM_MA_METHOD       PeriodoLongo_meth = MODE_SMA;          // Tipo Média Longa
input ENUM_APPLIED_PRICE   PeriodoLongo_price = PRICE_CLOSE;      // Preço Média Longa
input group   "---------------------------ESTRATÉGIA-------------------------------------------------"
input group   "Configurações  EA"
input bool     inversao       = true;                            //Inversão de Posição
input bool     everynewbar    = true;                            //Every New Bar
input double   Volume         = 1;                               //Lotes
input int      tipolotes      = 1;                               //1-Tick(Todos); 2-Pontos(Dolar); 3-Financeiro(Ações);
input double   iSL             = 0;                              //Stop Loss
input double   iTP             = 0;                              //Take Profit
input ulong    ideviation      = 0;                              //Off Set de ordens
input ENUM_ORDER_TYPE_FILLING Tipo= ORDER_FILLING_IOC;           //Tipo de Execução de Ordens
input ulong    magicNumber    = 12345678;                        // Magic Number
input group   "------------------------------------------------------------------------------------"
input group   "Configurações  Stop Móvel"
input double   iTrailing_Start =0;                               //Distância. 0-Desativa a função
input double   iTrailing_Step  =0;                               //Passo
input group   "------------------------------------------------------------------------------------"
input group   "Configurações  Break Even"
input double   iBreak_Even_Start =0;                             //Distância. 0-Desativa a função
input double   iBreak_Even_Step  =0;                             //Ganho
input group   "------------------------------------------------------------------------------------"
input group   "Saídas Parciais"
input double   iParcial_distancia=0;                             //Distância(1). 0-Desativa a função
input double   iParcail_volume  =0;                              //Lotes(1)
input double   iParcial_distancia2=0;                             //Distância(2). 0-Desativa a função
input double   iParcail_volume2  =0;                              //Lotes(2)
input group   "------------------------------------------------------------------------------------"
input group   "Módulo Martingele"
input bool     martingale     =false;                           //Ativação do Módulo Martingale
input double   mult_martingale=0;                               //Índice inicial do multiplicador de volume
input double   vol_maximo_martingale=0;                         //Limite de lotes
input group   "------------------------------------------------------------------------------------"
input group   "Controle Financeiro"
input double   iLucromax      =0;                               //Lucro máximo em operações. 0-Desativa a função
input double   iPerdamax      =0;                               //Prejuízo máximo em operações. 0-Desativa a função
input double   iGanhomax      =0;                               //Lucro máximo diário. 0-Desativa a função
input double   iLossmax       =0;                               //Prejuízo máximo diário. 0-Desativa a função
input group   "------------------------------------------------------------------------------------"
input group   "Configurações  Horário"
input string   inicio         = "09:05";                        // Horário de Início (entradas)
input string   termino        = "17:00";                        // Horário de Término (entradas)
input string   fechamento     = "17:30";                        // Horário de Fechamento (posições)
input group   "------------------------------------------------------------------------------------"


//+------------------------------------------------------------------+
//| Globais                                                          |
//+------------------------------------------------------------------+



// Contador para a função Traillling
int cont=0;
int cont_trail=0;
double traillbuy=0;
double traillsell=0;

// Contador para a função parcial

int cont_parcial=0;
int cont_breakeven=0;

// Delcaração de variáveis globais e de classe
int handlemedialonga, handlemediacurta;                        // Manipuladores dos dois indicadores de média móvel
CTrade negocio;                                                // Classe responsável pela execução de negócios
CSymbolInfo simbolo;                                           // Classe responsável pelos dados do ativo
CPositionInfo PosicaoInfo;                                     // Classe responsável pela aquisição de informações de posições
CControlPainel Painel(0,0.2,0.95,4,3,CORNER_LEFT_LOWER);      // Classe responsável pela criação do painel de resumo
// Declaração de variáveis globais para ajuste de step

double  SL;
double  TP;
double  deviation;
double  Trailing_Start;
double  Trailing_Step;
double  Break_Even_Start;
double  Break_Even_Step;
double  Partial;
double  Partial2;
//Declaração de variável para martingale
double volumeatual = Volume;                                           //--Armazen um novo valor do volume após a verficação de martingale
ulong prova=1;                                                // responsávbel por verificar o ticket é o mesmo  do anterior
ulong ticket=0;                                               // responsável por captar o ticket da ultima operação negativa

// Estruturas de tempo para manipulação de horários
MqlDateTime horario_inicio, horario_termino, horario_fechamento, horario_atual,horario_final;
string   dia ="18:00";

// Estruturas para verificação do ticket
MqlTick tick;

// Declaração de variáveis para painel de resumo das operações

double lucro_painel, perda_painel;
int contador_trades_painel;
int contador_ordens_painel;
double resultado_painel;
ulong ticket_painel;
double fator_lucro_painel;
double resultado_liquido_painel;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |-------------------------O.N---I.N.I.T---------------------
//+------------------------------------------------------------------+
int OnInit()
  {

// Definição do símbolo utilizado para a classe responsável CSymbol
   if(!simbolo.Name(_Symbol))
     {
      printf("Ativo Inválido!");
      return INIT_FAILED;
     }


// Definição de Magic Number
   negocio.SetExpertMagicNumber(magicNumber);
// Definicação de OFF Set
   negocio.SetDeviationInPoints(ideviation);
// Tipo de execução de ordens
   negocio.SetTypeFilling(Tipo);

//--Verificação se o ativo encontra-se em leilão

   InformacaoPreco();

//-- Normalização de steps

   Normalizastep();

// Preenchimento das structs de tempo
   TimeToStruct(StringToTime(inicio), horario_inicio);
   TimeToStruct(StringToTime(termino), horario_termino);
   TimeToStruct(StringToTime(fechamento), horario_fechamento);
   TimeToStruct(StringToTime(dia), horario_final);



// Criação dos manipuladores com Períodos curto e longo
   handlemediacurta = iMA(_Symbol, _Period,PeriodoCurto,PeriodoCurto_desloc,PeriodoCurto_meth,PeriodoCurto_price);
   handlemedialonga = iMA(_Symbol, _Period,PeriodoLongo,PeriodoLongo_desloc,PeriodoLongo_meth,PeriodoLongo_price);


// Verificação do resultado da criação dos manipuladores
   if(handlemediacurta == INVALID_HANDLE || handlemedialonga == INVALID_HANDLE)
     {
      Print("Erro na criação dos manipuladores");
      return INIT_FAILED;
     }

// Verificação de inconsistências nos parâmetros de entrada
   if(PeriodoLongo <= PeriodoCurto && PeriodoCurto_desloc==PeriodoLongo_desloc)
     {
      Print("Parâmetros de médias incorretos");
      return INIT_FAILED;
     }

// Apaga as lihnas naturais do MT5 de Stop Loss e Stop Gain ( utilização em conjunto com a mudança de cores na função On int
   ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,0,clrNONE);


// Verificação de inconsistências nos parâmetros de entrada de horas
   if(horario_inicio.hour > horario_termino.hour || (horario_inicio.hour == horario_termino.hour && horario_inicio.min > horario_termino.min))
     {
      printf("Parâmetros de Horário inválidos!");
      return INIT_FAILED;
     }

// Verificação de inconsistências nos parâmetros de entrada horas
   if(horario_termino.hour > horario_fechamento.hour || (horario_termino.hour == horario_fechamento.hour && horario_termino.min > horario_fechamento.min))
     {
      printf("Parâmetros de Horário inválidos!");
      return INIT_FAILED;
     }

//------ Definição de template básico
   ChartDefines(true,0);

//--Adiciona indicador ao gráfico
   if(!ChartIndicatorAdd(0,0,handlemediacurta))
     {
      Print("Erro ao adiocionar IMA");
      return INIT_FAILED;
     }

   if(!ChartIndicatorAdd(0,0,handlemedialonga))
     {
      Print("Erro ao adiocionar IMA");
      return INIT_FAILED;
     }




//----------------------------------Bloco de inicialização do painel de resumo-------------------------------//

   Painel.CreatePanel();
   Painel.CreateText("MAD RABBIT LAB Inc",clrWhite,7,true);
   Painel.CreateText("Lauro Cerqueira",clrWhite,7,true);
   Painel.CreateText("Copyright 2020",clrWhite,7,true);
   Painel.CreateText("----------------------------------------------------------------------",clrWhite,5,true);
   Painel.CreateText("Ask: 0.0 Bid: 0.0",clrWhite,9,true);
   Painel.CreateText("Prejuizo total(dia)",clrRed,9.5,true);
   Painel.CreateText("0",clrRed,8,true);
   Painel.CreateText("Lucro total(dia)",clrGreen,9.5,true);
   Painel.CreateText("0",clrGreen,8,true);
   Painel.CreateText("Resultado(dia)",clrWhite,9.5,true);
   Painel.CreateText("0",clrWhite,8,true);
   Painel.CreateText("Fator de Lucro(dia)",clrWhite,9.5,true);
   Painel.CreateText("0",clrWhite,8,true);
   Painel.CreateText("Qtd Trades(dia)",clrWhite,9.5,true);
   Painel.CreateText("0",clrWhite,8,true);
   Painel.CreateText("Qtd Ordens(dia)",clrWhite,9.5,true);
   Painel.CreateText("0",clrWhite,8,true);
   Painel.CreateButton("Zerar",clrWhite,clrRed);
   Painel.CreateText("",clrBlack,4,true);
   Painel.CreateButton("BuyAtMarket",clrWhite,clrBlue);
   Painel.CreateText("",clrBlack,4,true);
   Painel.CreateButton("SellAtMarket",clrWhite,clrGreen);
   Painel.CreateText("Temporizador do Candle",clrWhite,7.5,true);
   Painel.CreateText("0",clrWhite,7,true);
   Painel.CreateText("Volume das posições",clrWhite,7.5,true);
   Painel.CreateText("0",clrWhite,7,true);
   Painel.CreateText("Resultado Parcial",clrWhite,7.5,true);
   Painel.CreateText("0",clrWhite,7,true);



//--- Inicialização concluída
   PlaySound("\\Sounds\\race-robot-start.wav");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Função para verificação se o ativo encontra-se em leilão          |
//+-------------------------------------------------------------------+
void InformacaoPreco()
  {
   if(!MQLInfoInteger(MQL_TESTER))
     {
      if(SymbolInfoTick(_Symbol,tick)==true)
        {
         double   bid = tick.bid;
         double   ask = tick.ask;

         if(bid == 0 || ask == 0) //Cotacoes zeradas
           {
            Print("As cotações estão zeradas");
           }
         if(bid >= ask) //Leilão
           {
            Print("O Ativo atual está em leilão");
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Função para normalização dos lotes por ativo                     |
//+-------------------------------------------------------------------
void Normalizastep()
  {

   switch(tipolotes)
     {
      case 1:

         SL             = iSL*_Point;
         TP             = iTP*_Point;
         deviation      = ideviation*_Point;
         Trailing_Start = iTrailing_Start*_Point;
         Trailing_Step  = iTrailing_Step*_Point;
         Break_Even_Start = iBreak_Even_Start*_Point;
         Break_Even_Step  = iBreak_Even_Step*_Point;
         Partial        =iParcial_distancia*_Point;
         Partial2        =iParcial_distancia2*_Point;
         break;

      case 2:

         if(_Digits==3)
           {
            SL             = iSL*1000*_Point;
            TP             = iTP*1000*_Point;
            deviation      = ideviation*1000*_Point;
            Trailing_Start = iTrailing_Start*1000*_Point;
            Trailing_Step  = iTrailing_Step*1000*_Point;
            Break_Even_Start = iBreak_Even_Start*1000*_Point;
            Break_Even_Step  = iBreak_Even_Step*1000*_Point;
            Partial        =iParcial_distancia*1000*_Point;
            Partial2        =iParcial_distancia2*1000*_Point;
           }
         break;

      case 3 :


         if(_Digits==2)
           {
            SL             = iSL*100*_Point;
            TP             = iTP*100*_Point;
            deviation      = ideviation*100*_Point;
            Trailing_Start = iTrailing_Start*100*_Point;
            Trailing_Step  = iTrailing_Step*100*_Point;
            Break_Even_Start = iBreak_Even_Start*100*_Point;
            Break_Even_Step  = iBreak_Even_Step*100*_Point;
            Partial        =iParcial_distancia*100*_Point;
            Partial2        =iParcial_distancia2*100*_Point;
           }
         break;
     }
  }




//+------------------------------------------------------------------+
//| Definir um template básico ao gráfico                            |
//+------------------------------------------------------------------+
bool ChartDefines(const bool value,const long chart_ID=0)
  {
//--- Resetar Ultimo Erro
   ResetLastError();

//--- Definir Exibição Do Grid
   if(!ChartSetInteger(chart_ID,CHART_SHOW_GRID,0,false))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir Exibição Do de ask
   if(!ChartSetInteger(chart_ID,CHART_SHOW_ASK_LINE,0,true))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor da Linha Ask
   if(!ChartSetInteger(chart_ID,CHART_COLOR_ASK,clrDeepSkyBlue))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir Exibição Do de bid
   if(!ChartSetInteger(chart_ID,CHART_SHOW_BID_LINE,0,true))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor da Linha bid
   if(!ChartSetInteger(chart_ID,CHART_COLOR_BID,clrGold))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor do grafico de linha
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_LINE,clrBlue))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- Definir cor da linha do ultimo Preço
   if(!ChartSetInteger(chart_ID,CHART_SHOW_LAST_LINE,true))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- Definir cor da linha do ultimo Preço
   if(!ChartSetInteger(chart_ID,CHART_COLOR_LAST,clrBlue))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor do Primeiro Plano
   if(!ChartSetInteger(chart_ID,CHART_COLOR_FOREGROUND,clrBlack))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor Do Fundo
   if(!ChartSetInteger(chart_ID,CHART_COLOR_BACKGROUND,clrWhite))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor Do Candle De Alta
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BULL,clrGreen))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor da Barra de Alta
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,clrGreen))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor da Barra de baixa
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,clrRed))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }

//--- Definir cor do Candle de Baixa
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,clrRed))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }







   return(true);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |----------------------------------------------DEINT-----------------------------------------
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

//Motivo do robo ter saido
   switch(reason)
     {
      case 0:
         Print("ATENÇÃO: Motivo de remoção: O Expert Advisor terminou sua operação chamando a função ExpertRemove().");
         PlaySound("\\Sounds\\alert-1");
         break;
      case 1:
         Print("ATENÇÃO: Motivo de remoção: O robo foi excluído do gráfico.");
         PlaySound("\\Sounds\\mission-complete.wav");
         break;
      case 2:
         Print("ATENÇÃO: Motivo de remoção: O robo foi recompilado.");
         break;
      case 3:
         Print("ATENÇÃO: Motivo de remoção: O período do símbolo ou gráfico foi alterado.");
         break;
      case 4:
         Print("ATENÇÃO: Motivo de remoção: O gráfico foi encerrado.");
         PlaySound("\\Sounds\\mission-complete.wav");
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
         PlaySound("\\Sounds\\alert-1");
         break;
      case 9:
         Print("ATENÇÃO: Motivo de remoção: Terminal foi fechado.");
         PlaySound("\\Sounds\\mission-complete.wav");
         break;
      default:
         Print("ATENÇÃO: Motivo de remoção: Desconhecido.");
         PlaySound("\\Sounds\\alert-1");
     }

//---Deletar todos os indicadores
   for(int i = ChartIndicatorsTotal(0,0); i>0; i--)
     {ChartIndicatorDelete(0,0,ChartIndicatorName(0,0,ChartIndicatorsTotal(0,0)-i));}


//--- Deleta todos os objetos do gráfico

   ObjectsDeleteAll(0,-1,-1);


  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |-------------------------------------------------MAIN FUNCTION--------------------------------//
//+------------------------------------------------------------------+
void OnTick()
  {

// Atualização dos dados do ativo
   if(!simbolo.RefreshRates())
      return;

//--Função IsNewbar para evitar efetuar cálculos a cada tick e sim a cada fechamento de barra para envio de ordens

   if(everynewbar==true)
     {
      if(isNewBar())
        { logicaoperacional();}
      // -Não sendo uma nova barra verificar somente breakeaven , Stop Movel, Parcial
      else
        {
         BREAK_EVEN();
         TRAILING_STOP();
         Parcial();
         Drawings();
        }
     }
   else
     {
      logicaoperacional();
      BREAK_EVEN();
      TRAILING_STOP();
      Parcial();
     }

//---Chamada organizadora para funções de desenhos e painel

   



//--
  }

//----------------------------------------------------------------------------------------------------------------------------------MAIN FUNCTION--------------------------------//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)


  {

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(Painel.ButtonGetState(1))
        {
         if(negocio.PositionClose(_Symbol))
           {
            Alert("Fechamento de posição efetuado pelo botão zerar");
            ObjectDelete(0,"Trailling");
            ObjectDelete(0,"Breakeven");
            ObjectDelete(0, "StopLoss");
            ObjectDelete(0, "TakeProfit");
            ObjectDelete(0, "Parcial");
            Painel.ButtonSetState(1,false);
           }
        }

      if(Painel.ButtonGetState(2))
        {
         if(PositionSelect(_Symbol))
           {
            if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL)
              {
               ObjectDelete(0,"Trailling");
               ObjectDelete(0,"Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               Compra();
               Alert("Buy at Market");
               Painel.ButtonSetState(2,false);
              }
            else
              {
               negocio.PositionClose(_Symbol);
               ObjectDelete(0,"Trailling");
               ObjectDelete(0,"Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               Alert("Buy at Market");
               Painel.ButtonSetState(2,false);
              }
           }
         else

           {
            ObjectDelete(0,"Trailling");
            ObjectDelete(0,"Breakeven");
            ObjectDelete(0, "StopLoss");
            ObjectDelete(0, "TakeProfit");
            ObjectDelete(0, "Parcial");
            Compra();
            Alert("Buy at Market");
            Painel.ButtonSetState(2,false);
           }
        }

      if(Painel.ButtonGetState(3))
        {
         if(PositionSelect(_Symbol))
           {
            if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY)
              {
               ObjectDelete(0,"Trailling");
               ObjectDelete(0,"Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               Venda();
               Alert("Sell at Market");
               Painel.ButtonSetState(2,false);
              }
            else
              {
               negocio.PositionClose(_Symbol);
               ObjectDelete(0,"Trailling");
               ObjectDelete(0,"Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               Alert("Sell at Market");
               Painel.ButtonSetState(2,false);
              }
           }

         else

           {
            ObjectDelete(0,"Trailling");
            ObjectDelete(0,"Breakeven");
            ObjectDelete(0, "StopLoss");
            ObjectDelete(0, "TakeProfit");
            ObjectDelete(0, "Parcial");
            Venda();
            Alert("Buy at Market");
            Painel.ButtonSetState(2,false);
           }
        }
     }
//-----
  }
//+------------------------------------------------------------------+
//| Lógica operacional                                               |
//+------------------------------------------------------------------+
// EA em horário de entrada em novas operações
void logicaoperacional()
  {
   if(HorarioEntrada())
     {
      // EA não está posicionado
      if(SemPosicao())
        {
         ObjectDelete(0,"Breakeven"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0,"Trailling"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0,"Parcial"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0,"Parcial2"); // Apaga o objeto caso não esteja posicionado
         cont_parcial=0;// zeragem do contador do loop de parciais
         cont_breakeven=0; // zeragem do contador de loop brakeven
         // Variável recebe o valor após verificação da estratégia de cruzamento e determinar compra ou venda
         int resultado_cruzamento = Cruzamento();


         if(martingale==true)  //--- Ativação da função martingale
           {Martingale();}

         // Estratégia indicou compra
         if(resultado_cruzamento == 1)
           {Compra();}

         // Estratégia indicou venda
         if(resultado_cruzamento == -1)
           {Venda();}
        }
      else
        {
         // Verificar estratégia e determinar compra ou venda

         int resultado_cruzamento = Cruzamento();
         // Estratégia indicou compra
         if(resultado_cruzamento == 1)
           {Fechar();}
         // Estratégia indicou venda
         if(resultado_cruzamento == -1)
           {Fechar();}

        }
     }

// EA em horário de fechamento de posições abertas
   if(HorarioFechamento())
     {
      // EA está posicionado, fechar posição
      if(!SemPosicao())
         Fechar();
     }

  }

//+------------------------------------------------------------------+
//| Checar se horário atual está dentro do horário de entradas       |
//+------------------------------------------------------------------+
bool HorarioEntrada()
  {
   TimeToStruct(TimeCurrent(), horario_atual); // Obtenção do horário atual

// Hora dentro do horário de entradas
   if(horario_atual.hour >= horario_inicio.hour && horario_atual.hour <= horario_termino.hour)
     {
      // Hora atual igual a de início
      if(horario_atual.hour == horario_inicio.hour)
         // Se minuto atual maior ou igual ao de início => está no horário de entradas
         if(horario_atual.min >= horario_inicio.min)
            return true;
      // Do contrário não está no horário de entradas
         else
            return false;

      // Hora atual igual a de término
      if(horario_atual.hour == horario_termino.hour)
         // Se minuto atual menor ou igual ao de término => está no horário de entradas
         if(horario_atual.min <= horario_termino.min)
            return true;
      // Do contrário não está no horário de entradas
         else
            return false;

      // Hora atual maior que a de início e menor que a de término
      return true;
     }

// Hora fora do horário de entradas
   return false;
//--
  }
//+------------------------------------------------------------------+
//| Checar se horário atual está dentro do horário de fechamento     |
//+------------------------------------------------------------------+
bool HorarioFechamento()
  {
   TimeToStruct(TimeCurrent(), horario_atual); // Obtenção do horário atual

// Hora dentro do horário de fechamento
   if(horario_atual.hour >= horario_fechamento.hour)
     {
      // Hora atual igual a de fechamento
      if(horario_atual.hour == horario_fechamento.hour)
         // Se minuto atual maior ou igual ao de fechamento => está no horário de fechamento
         if(horario_atual.min >= horario_fechamento.min)
            return true;
      // Do contrário não está no horário de fechamento
         else
            return false;

      // Hora atual maior que a de fechamento
      return true;
     }

// Hora fora do horário de fechamento
   return false;
//--
  }
//+------------------------------------------------------------------+
//| Realizar compra com parâmetros especificados por input           |
//+------------------------------------------------------------------+
void Compra()
  {
   double stoploss;
   double takeprofit;
   double price = simbolo.Ask(); // Determinação do preço da ordem a mercado
   double price_normalized = NormalizePrice(price,NULL,0);

   if(SL>0)
     {
      stoploss = (price_normalized - SL);  // Cálculo normalizado do stoploss
     }
   if(SL==0)
     {
      stoploss=0;
     }
   if(TP>0)
     {
      takeprofit = (price_normalized + TP);  // Cálculo normalizado do takeprofit
     }
   if(TP==0)
     {
      takeprofit=0;
     }

   if(martingale==false)
     {ObjectDelete(0,"Breakeven");
      ObjectDelete(0,"Parcial");
      ObjectDelete(0,"Parcial2");
      ObjectDelete(0,"Trailling");
      negocio.Buy(Volume,NULL,price_normalized,stoploss,takeprofit,"Buy at Market CruzamentodeMediaEA"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      PlaySound("\\Sounds\\Register.wav");
      
      if(iBreak_Even_Start>0)
        {Linha_Horizontal("Breakeven",negocio.RequestPrice()+Break_Even_Start,1,clrBlueViolet,STYLE_DASHDOT);}// criação de linha para visualização do breakeven com a função Linha_Horizontal
     
      if(iParcial_distancia>0)
        {Linha_Horizontal("Parcial",negocio.RequestPrice()+Partial,1,clrBrown,STYLE_DASHDOT);}
      
      if(iParcial_distancia2>0)
        {Linha_Horizontal("Parcial2",negocio.RequestPrice()+Partial2,1,clrBrown,STYLE_DASHDOT);}
     } // criação da linha de parcial

   else
     {ObjectDelete(0,"Breakeven");
      ObjectDelete(0,"Parcial");
      ObjectDelete(0,"Parcial2");
      ObjectDelete(0,"Trailling");
      negocio.Buy(volumeatual,NULL,price_normalized,stoploss,takeprofit,"Buy at Market Martingale CruzamentodeMediaEA"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      PlaySound("\\Sounds\\Register.wav");
      
      if(iBreak_Even_Start>0)
        {Linha_Horizontal("Breakeven",negocio.RequestPrice()+Break_Even_Start,1,clrBlueViolet,STYLE_DASHDOT);}// criação de linha para visualização do breakeven com a função Linha_Horizontal
      if(iParcial_distancia>0)
        {Linha_Horizontal("Parcial",negocio.RequestPrice()+Partial,1,clrBrown,STYLE_DASHDOT);}

      if(iParcial_distancia2>0)
        {Linha_Horizontal("Parcial2",negocio.RequestPrice()+Partial2,1,clrBrown,STYLE_DASHDOT);}
     } // criação da linha de parcial
  }
//+------------------------------------------------------------------+
//| Realizar venda com parâmetros especificados por input            |
//+------------------------------------------------------------------+
void Venda()
  {
   double stoploss;
   double takeprofit;
   double price = simbolo.Bid(); // Determinação do preço da ordem a mercado
   double price_normalized = NormalizePrice(price,NULL,0);

   if(SL>0)
     {
      stoploss = (price_normalized + SL);  // Cálculo normalizado do stoploss
     }
   if(SL==0)
     {
      stoploss=0;
     }
   if(TP>0)
     {
      takeprofit = (price_normalized - TP);  // Cálculo normalizado do takeprofit
     }
   if(TP==0)
     {
      takeprofit=0;
     }

   if(martingale==false)
     {ObjectDelete(0,"Breakeven");
      ObjectDelete(0,"Parcial");
      ObjectDelete(0,"Parcial2");
      ObjectDelete(0,"Trailling");
      negocio.Sell(Volume,NULL,price_normalized,stoploss,takeprofit,"Sell at Market CruzamentodeMediaEA"); // Envio da ordem de compra pela classe responsável
      SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
      negocio.PrintRequest();
      PlaySound("\\Sounds\\Register.wav");
      
      if(iBreak_Even_Start>0)
        {Linha_Horizontal("Breakeven",negocio.RequestPrice()-Break_Even_Start,1,clrBlueViolet,STYLE_DASHDOT);} // criação de linha para visualização do breakeven com a função Linha_Horizontal
      if(iParcial_distancia>0)
        {Linha_Horizontal("Parcial",negocio.RequestPrice()-Partial,1,clrBrown,STYLE_DASHDOT);}

      if(iParcial_distancia2>0)
        {Linha_Horizontal("Parcial2",negocio.RequestPrice()-Partial2,1,clrBrown,STYLE_DASHDOT);}
     } // criação da linha de parcial
   else
     {ObjectDelete(0,"Breakeven");
      ObjectDelete(0,"Parcial");
      ObjectDelete(0,"Parcial2");
      ObjectDelete(0,"Trailling");
      negocio.Sell(volumeatual,NULL,price_normalized,stoploss,takeprofit,"Sell at Market Martingale CruzamentodeMediaEA"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
      PlaySound("\\Sounds\\Register.wav");
      
      if(iBreak_Even_Start>0)
        {Linha_Horizontal("Breakeven",PosicaoInfo.PriceOpen()-Break_Even_Start,1,clrBlueViolet,STYLE_DASHDOT);} // criação de linha para visualização do breakeven com a função Linha_Horizontal
      if(iParcial_distancia>0)
        {Linha_Horizontal("Parcial",negocio.RequestPrice()-Partial,1,clrBrown,STYLE_DASHDOT);}
      if(iParcial_distancia2>0)
        {Linha_Horizontal("Parcial2",negocio.RequestPrice()-Partial2,1,clrBrown,STYLE_DASHDOT);}
     } // criação da linha de parcial
  }
//+------------------------------------------------------------------+
//| Função para normalizar preço                                     |
//+------------------------------------------------------------------+
double NormalizePrice(double price_to, string symbol, double tick)
  {
   static const double _tick = tick ? tick : SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double finalprice =NormalizeDouble((round(price_to / _tick)*_tick),0);

   return round(finalprice);

  }


//+------------------------------------------------------------------+
//| Fechar posição aberta                                            |
//+------------------------------------------------------------------+
void Fechar()
  {
   double stoploss_sell=0.0;
   double stoploss_buy=0.0;
   double takeprofit_sell=0.0;
   double takeprofit_buy=0.0;
   double price_sell = simbolo.Bid(); // Determinação do preço da ordem a mercado
   double price_normalized_sell = NormalizePrice(price_sell,NULL,0);
   double price_buy = simbolo.Ask(); // Determinação do preço da ordem a mercado
   double price_normalized_buy = NormalizePrice(price_buy,NULL,0);




   if(SL>0)
     {
      stoploss_sell= (price_normalized_sell + SL); // Cálculo normalizado do stoploss sell
      stoploss_buy= (price_normalized_buy - SL);
     } // Cálculo normalizado do stoploss buy
   if(TP>0)
     {
      takeprofit_sell =(price_normalized_sell- TP); // Cálculo normalizado do takeprofit sell
      takeprofit_buy =(price_normalized_buy+ TP);
     } // Cálculo normalizado do takeprofit buy



// Verificação de posição aberta
   if(!PositionSelect(_Symbol))
      return;

   long tipo = PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta
   double volume_fechamento = PositionGetDouble(POSITION_VOLUME);

// Vender em caso de posição comprada
   if(tipo == POSITION_TYPE_BUY)
     {
      if(martingale ==false)
        {
         if(inversao==true) //--Ativação da inversão de posição
           {
            if(horario_atual.hour <=horario_termino.hour)
              {
               if(horario_atual.hour <horario_termino.hour)

                 {
               
                  negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Venda -> Fechamento de posição ");
                  SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  negocio.Sell(Volume, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Compra -> Venda Inversão de mão");
                  PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                  cont_parcial=0;
                  cont_breakeven=0;
                  cont_trail=1;
                 }// zeragem do contador do loop de parciais

             



               else
                  if(horario_atual.hour == horario_termino.hour && horario_atual.min<=horario_termino.min)
                    {
                     
                     negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Venda -> Fechamento de posição");
                     SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Sell(Volume, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Compra -> Venda Inversão de mão");
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                     cont_parcial=0;
                     cont_breakeven=0;
                     cont_trail=1;
                    }// zeragem do contador do loop de parciais

              }

            if(horario_atual.hour>=horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
              {
              
               negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, "Fechamento de posição do dia");
               SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
               PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
               cont_parcial=0;
            
              }// zeragem do contador do loop de parciais

           }
         else
           {
           
            negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, "Fechamento de Posição");
            SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_parcial=0;
           }// zeragem do contador do loop de parciais


        }
      else
        {
         if(inversao==true) //--Ativação da inversão de posição
           {
            if(horario_atual.hour <=horario_termino.hour)
              {
               if(horario_atual.hour <horario_termino.hour)

                 {
               
                  negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Venda -> Fechamento de posição "); //--fechamento de posição
                  SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  negocio.Sell(volumeatual, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Venda inversão martingale");
                  PlaySound("\\Sounds\\Register.wav"); //--Inversão martingale
                  cont_parcial=0;  ///
                  cont_breakeven=0; /////// zeragem para intertravamentos
                  cont_trail=1; ////
                 }
              

               else
                  if(horario_atual.hour == horario_termino.hour && horario_atual.min<=horario_termino.min)

                    {
                    
                     negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Venda -> Fechamento de posição "); //--fechamento de posição
                     SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Sell(volumeatual, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, " Venda inversão martingale");
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão martingaleo
                     cont_parcial=0;
                     cont_breakeven=0;
                     cont_trail=1;
                    }// zeragem do contador do loop de parciais
             
              }

            if(horario_atual.hour>=horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
              {
               
               negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, "Fechamento de posição do dia");
               SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
               PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
               cont_parcial=0;
              
              }// zeragem do contador do loop de parciais

           }
         else
           {
            negocio.Sell(volume_fechamento, NULL,price_normalized_sell,stoploss_sell,takeprofit_sell, "Fechamento de Posição");
            SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_parcial=0;
           
           }// zeragem do contador do loop de parciais


        }
     }
// Comprar em caso de posição vendida
   else
     {
      if(martingale ==false)
        {

         if(inversao==true) //--Ativação da inversão de posição
           {
            if(horario_atual.hour <=horario_termino.hour)
              {

               if(horario_atual.hour <horario_termino.hour)
                 {
                
                  negocio.Buy(volume_fechamento, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Compra ->Fechamento de posição");
                  SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  negocio.Buy(Volume, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Venda ->Compra Inversão de mão");
                  PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                  cont_parcial=0;
                  cont_breakeven=0;
                  cont_trail=1;
                 }// zeragem do contador do loop de parciais


               else
                  if(horario_atual.hour == horario_termino.hour && horario_atual.min<=horario_termino.min)
                    {
                    
                     negocio.Buy(volume_fechamento, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Compra ->Fechamento de posição");
                     SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Buy(Volume, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Venda ->Compra Inversão de mão");
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                     cont_parcial=0;
                     cont_breakeven=0;
                     cont_trail=1;
                    }// zeragem do contador do loop de parciais

              }

            if(horario_atual.hour>=horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
              {
               
               negocio.Buy(Volume, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, "Fechamento Posição do Dia");
               SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
               PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
               cont_parcial=0;
             
              }// zeragem do contador do loop de parciais


           }
         else
           {
           
            negocio.Buy(Volume, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, "Fechamento de Posição");
            SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_parcial=0;
          
           }// zeragem do contador do loop de parciais

        }
      else
        {
         if(inversao==true) //--Ativação da inversão de posição
           {
            if(horario_atual.hour <=horario_termino.hour)
              {

               if(horario_atual.hour <horario_termino.hour)
                 {
                 
                  negocio.Buy(volume_fechamento, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Compra -> fechamento de posição"); //--Fechamento de posição
                  SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  negocio.Buy(volumeatual, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Compra Inversão de mão martingale");
                  SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição martigale
                  cont_parcial=0;
                  cont_breakeven=0;
                  cont_trail=1;
                 }// zeragem do contador do loop de parciais


               else
                  if(horario_atual.hour == horario_termino.hour && horario_atual.min<=horario_termino.min)
                    {
                    
                     negocio.Buy(volume_fechamento, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, "Compra -> fechamento de posição"); //--Fechamento de posição
                     SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Buy(volumeatual, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, " Compra Inversão de mão martingale");
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição martigale
                     cont_parcial=0;
                     cont_breakeven=0;
                     cont_trail=1;
                    }// zeragem do contador do loop de parciais

              }

            if(horario_atual.hour>=horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
              {
              
               negocio.Buy(volume_fechamento, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, "Fechamento Posição do Dia");
               SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
               PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
               cont_parcial=0;
               
              }// zeragem do contador do loop de parciais


           }
         else
           {
     
            negocio.Buy(volume_fechamento, NULL,price_normalized_buy,stoploss_buy,takeprofit_buy, "Fechamento de Posição");
            SymbolPendingOrdersCloseAll(_Symbol); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_parcial=0;
           
           }// zeragem do contador do loop de parciais


        }
     }

//---
  }

//+------------------------------------------------------------------+
//| Função para Fechar parcialmente posição                          |
//+------------------------------------------------------------------+
void Parcial()
  {
  
  
     MqlDateTime  inicio_dia;
   datetime hora_atual =TimeCurrent(inicio_dia);
   inicio_dia.hour =0;
   inicio_dia.min =0;
   inicio_dia.sec =0;
   double result;
   ulong ticket1;
   double teste = negocio.RequestPrice();
   double teste2 = PosicaoInfo.PriceCurrent();

   if(!HistorySelect(StructToTime(inicio_dia),hora_atual))
     {Alert("Erro Aquisição de dados para parcial");}

   if(HistoryDealsTotal()>0)
     {

   for(int i=HistoryDealsTotal()-1; i>=0; i--)
     {
      ticket1 = HistoryOrderGetTicket(i); // index do último negocio e armazena em ticket

      if(HistoryDealGetString(ticket1,DEAL_SYMBOL) !=_Symbol)
         continue;

     PosicaoInfo.SelectByTicket(ticket1);
      break;   // --- interrompe o laço for na primeira verificação (ultima operação de acordo com a ordem de verificação)
     }
    } 
     
   
   if(iParcial_distancia>0 && PositionSelect(_Symbol) && cont_parcial<1)
     {teste = negocio.RequestPrice(); teste2 = PosicaoInfo.PriceCurrent();
      if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY && PosicaoInfo.PriceCurrent()- PosicaoInfo.PriceOpen()>= Partial)

        {
         negocio.Sell(iParcail_volume,_Symbol,0,0,0,"Realização Parcial de Compra");
         teste = negocio.RequestPrice();
         ObjectDelete(0,"Parcial");
         cont_parcial++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && PosicaoInfo.PriceOpen()- PosicaoInfo.PriceCurrent()>=Partial)

        {
         negocio.Buy(iParcail_volume,_Symbol,0,0,0,"Realização Parcial de Venda");
         teste = negocio.RequestPrice();
         ObjectDelete(0,"Parcial");
         cont_parcial++;
        }
     }


   if(iParcial_distancia2>0 && PositionSelect(_Symbol) && Partial2>Partial && cont_parcial<2)
     {
      if((PosicaoInfo.PositionType() == POSITION_TYPE_BUY) && (PosicaoInfo.PriceCurrent() - PosicaoInfo.PriceOpen()==Partial2) && cont_parcial==1)

        {
         teste = negocio.RequestPrice();
         negocio.Sell(iParcail_volume2,_Symbol,0,0,0,"Realização Parcial de Compra");
         teste = negocio.RequestPrice();
         ObjectDelete(0,"Parcial2");
         cont_parcial++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && (PosicaoInfo.PriceOpen()- PosicaoInfo.PriceCurrent()==Partial2) && cont_parcial==1)

        {
         teste = negocio.RequestPrice();
         negocio.Buy(iParcail_volume2,_Symbol,0,0,0,"Realização Parcial de Venda");
         teste = negocio.RequestPrice();
         ObjectDelete(0,"Parcial2");
         cont_parcial++;
        }
     }



//----
  }
//+------------------------------------------------------------------+
//| Verificar se há ordem aberta no ativo atual                      |
//+------------------------------------------------------------------+
bool SemOrdem()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL)==_Symbol)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool SemPosicao()
  {
   return (!PositionSelect(_Symbol));
  }

//+------------------------------------------------------------------+
//|FUNÇÂO QUE FECHA Todas As POSIÇÕES                                |
//+------------------------------------------------------------------+
void Close_All_Positions(ulong magig,string _symbol)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PosicaoInfo.SelectByIndex(i))
         if((PosicaoInfo.Magic()==magig)&&(PosicaoInfo.Symbol()==_symbol))
            negocio.PositionClose(PosicaoInfo.Ticket());
     }
  }
//+------------------------------------------------------------------+
//| Estratégia de cruzamento de médias                               |
//+------------------------------------------------------------------+
int Cruzamento()
  {
// Cópia dos buffers dos indicadores de média móvel com períodos curto e longo
   double MediaCurta[], MediaLonga[];
   ArraySetAsSeries(MediaCurta, true);
   ArraySetAsSeries(MediaLonga, true);
   int Copied_1= CopyBuffer(handlemediacurta,0,PeriodoCurto_desloc, 3, MediaCurta);
   int Copied_2= CopyBuffer(handlemedialonga, 0,PeriodoLongo_desloc , 3, MediaLonga);
//  Print ( "Dados Copiados MediaLonga: ",Copied_1);
// Print ("Dados Copiados MediaCurta: ",Copied_2);
// Compra em caso de cruzamento da média curta para cima da média longa

   if(MediaCurta[2]<=MediaLonga[2] && MediaCurta[1]>MediaLonga[1])
      return 1;

// Venda em caso de cruzamento da média curta para baixo da média longa
   if(MediaCurta[2]>=MediaLonga[2] && MediaCurta[1]<MediaLonga[1])
      return -1;


   return 0;
  }


//+------------------------------------------------------------------+
//|       Função verifica se é uma nova barra                        |
//+------------------------------------------------------------------+
//--- Função utilizada para em conjunto com ONTICK para evitar processamento desnecessário de dados
//----Desta forma o robô só ira
bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }

//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+
//| Função para Trailing Stop                                        |
//+------------------------------------------------------------------+
void TRAILING_STOP()
  {
   double traill_line_buy;
   double traill_line_sell;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);
   if(!PositionSelect(_Symbol) || cont_trail==1)
     {
      cont=0;
      traillbuy =0;
      traillsell=0;
      cont_trail=0;
     }
   if(iTrailing_Start >0 && iBreak_Even_Start==0)
     {
      for(int i = 0 ; i < PositionsTotal() ; i++)
        {
         if(PosicaoInfo.SelectByIndex(i))
           {
            cont++;
            if(cont ==1)

              {
               traillbuy = PosicaoInfo.PriceOpen()+Trailing_Start;
               traillsell= PosicaoInfo.PriceOpen()-Trailing_Start;
              }

            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PosicaoInfo.PriceCurrent() >= traillbuy && PositionGetInteger(POSITION_MAGIC)==magicNumber)
              {
               traillbuy=traillbuy+Trailing_Start;
               ulong ticket=PosicaoInfo.Ticket();
               negocio.PositionModify(ticket,(PosicaoInfo.StopLoss() + Trailing_Step),PosicaoInfo.TakeProfit());
               ObjectDelete(0,"Trailling");
              }
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PosicaoInfo.PriceCurrent() <= traillsell && PosicaoInfo.Magic()==magicNumber)
              {

               traillsell=traillsell-Trailing_Start;
               ulong ticket=PosicaoInfo.Ticket();
               negocio.PositionModify(ticket,(PosicaoInfo.StopLoss() - Trailing_Step),PosicaoInfo.TakeProfit());
                ObjectDelete(0,"Trailling");
              }
           }
        }

     }

   if(iTrailing_Start>0 && iBreak_Even_Start>0)
     {
      for(int i = 0 ; i < PositionsTotal() ; i++)
        {
         if(PosicaoInfo.SelectByIndex(i))
           {
              {
               cont++;
               if(cont ==1)

                 {
                  traillbuy = PosicaoInfo.PriceOpen()+Trailing_Start;
                  traillsell= PosicaoInfo.PriceOpen()-Trailing_Start;
                 }
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PosicaoInfo.PriceOpen() <= PosicaoInfo.TakeProfit() && PosicaoInfo.Magic()==magicNumber)
                 {
                  if((PosicaoInfo.PriceCurrent() - PosicaoInfo.StopLoss()) >= Trailing_Start)
                    {
                     if(PosicaoInfo.PriceCurrent() >= traillbuy)
                       {
                        ulong ticket=PosicaoInfo.Ticket();
                        negocio.PositionModify(ticket,(PosicaoInfo.StopLoss() + Trailing_Step),PosicaoInfo.TakeProfit());
                        traillbuy=traillbuy+Trailing_Start;
                        ObjectDelete(0,"Trailling");
                       }
                    }
                 }
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PosicaoInfo.PriceOpen() >= PosicaoInfo.TakeProfit() && PosicaoInfo.Magic()==magicNumber)
                 {
                  if((PosicaoInfo.StopLoss() - PosicaoInfo.PriceCurrent()) >= Trailing_Start)
                    {

                     if(PosicaoInfo.PriceCurrent() <= traillsell)
                       {
                        
                        ulong ticket=PosicaoInfo.Ticket();
                        negocio.PositionModify(ticket,(PosicaoInfo.StopLoss() - Trailing_Step),PosicaoInfo.TakeProfit());
                        traillsell=traillsell-Trailing_Start;
                        ObjectDelete(0,"Trailling");
                                                
                       }

                    }
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Função para posição BreakEven                                    |
//+------------------------------------------------------------------+
void BREAK_EVEN()
  {

   if(iBreak_Even_Start>0.0)
     {
      for(int i = 0 ; i < PositionsTotal() ; i++)
        {
         if(PosicaoInfo.SelectByIndex(i))
           {
            long postion = PositionGetInteger(POSITION_TYPE);
            if(postion == POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC)==magicNumber)
              {
               double Diferenca=PosicaoInfo.PriceCurrent() - PosicaoInfo.PriceOpen();
               double breakeven=PosicaoInfo.PriceOpen()+ Break_Even_Start;
               if(Diferenca >= Break_Even_Start && PosicaoInfo.StopLoss() <= PosicaoInfo.PriceOpen() && cont_breakeven==0)
                 {
                  negocio.PositionModify(PosicaoInfo.Ticket(),PosicaoInfo.PriceOpen()+Break_Even_Step,PosicaoInfo.TakeProfit());
                  ObjectDelete(0,"Breakeven"); // apagar a linha de break Even após atingir o mesmo;
                  cont_breakeven++;
                 }
              }
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PosicaoInfo.Magic()==magicNumber)
              {
               double Diferenca=PosicaoInfo.PriceOpen() - PosicaoInfo.PriceCurrent();
               if(Diferenca >=  Break_Even_Start && PosicaoInfo.StopLoss() >= PosicaoInfo.PriceOpen() && cont_breakeven ==0)
                 {
                  negocio.PositionModify(PosicaoInfo.Ticket(),PosicaoInfo.PriceOpen()-Break_Even_Step,PosicaoInfo.TakeProfit());
                  ObjectDelete(0,"Breakeven"); // apagar a linha de break Even após atingir o mesmo;
                  cont_breakeven++;
                 }
               if(Diferenca >=  Break_Even_Start && PosicaoInfo.StopLoss()==0 && cont_breakeven==0) // Necessidade desta comparação quando o SL não for definido pelo usuário
                 {
                  negocio.PositionModify(PosicaoInfo.Ticket(),PosicaoInfo.PriceOpen()-Break_Even_Step,PosicaoInfo.TakeProfit());
                  ObjectDelete(0,"Breakeven"); // apagar a linha de break Even após atingir o mesmo;
                  cont_breakeven++;
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Função para resumo das operações                                 |
//+------------------------------------------------------------------


void ResumoOperacoes()
  {

//Declaração de Variáveis
   datetime inicio_, fim;
   double lucro = 0, perda = 0;
   int contador_trades = 0;
   int contador_ordens = 0;
   double resultado;
   ulong ticket;
   double fator_lucro;
   double resultado_liquido;

//Obtenção do Histórico
   MqlDateTime inicio_struct;
   fim = TimeCurrent(inicio_struct);
   inicio_struct.hour = 0;
   inicio_struct.min = 0;
   inicio_struct.sec = 0;
   inicio_ = StructToTime(inicio_struct);

   HistorySelect(inicio_, fim);

//Cálculos
   for(int i=0; i<HistoryDealsTotal(); i++)
     {
      ticket = HistoryDealGetTicket(i);
      long Entry  = HistoryDealGetInteger(ticket, DEAL_ENTRY);

      if(ticket > 0)
        {
         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol && HistoryDealGetInteger(ticket, DEAL_MAGIC) == magicNumber)
           {
            contador_ordens++;
            resultado = HistoryDealGetDouble(ticket, DEAL_PROFIT);

            if(resultado < 0)
              {
               perda += -resultado;
              }
            else
              {
               lucro += resultado;
              }
            if(inversao == false)
              {
               if(Entry == DEAL_ENTRY_OUT) // ----- Se inversão de mão  não estiver ativa o contador irá receber  somente os resultados das saídas dos trades e não das inversões
                 {
                  contador_trades++;
                 }
              }
            if(inversao == true)
              {
               if(Entry == DEAL_ENTRY_OUT || Entry == DEAL_ENTRY_INOUT) // ----- Se inversão de mão estiver ativa o contador irá receber os resultados das saídas dos trades e das inversões
                 {
                  contador_trades++;
                 }
              }
           }
        }
     }



   if(perda > 0)
     {
      fator_lucro = lucro/perda;
     }
   else
     {fator_lucro = -1;}

   resultado_liquido = lucro - perda;


//---- Transferindo resultado para variáveis globais a fim de alimentar o painel de resumo na função ONTICK
   lucro_painel = lucro;
   perda_painel = perda;
   contador_trades_painel= contador_trades;
   contador_ordens_painel=contador_ordens;
   ticket_painel = ticket;
   fator_lucro_painel = fator_lucro;
   resultado_liquido_painel = resultado_liquido;


   if(lucro>=iLucromax && iLucromax>0) // verficiação de lucro máxima nas operações e remoção do EA
     {
      negocio.PositionClose(_Symbol);
      ObjectDelete(0,"Trailling");
      ObjectDelete(0,"Breakeven");
      ObjectDelete(0, "StopLoss");
      ObjectDelete(0, "TakeProfit"); // utilização da função para fechar todas as posições do gráfico
      MessageBox(" Atenção atingido o lucro máximo em operações determinado, EA será removido",NULL,MB_OK);
      PlaySound("\\Sounds\\mission-complete");
      ExpertRemove();
     }

   if(perda>=iPerdamax && iPerdamax>0) // verficiação de perca maxima nas operações ou lucro máximo do dia e remoção do EA
     {
      negocio.PositionClose(_Symbol);
      ObjectDelete(0,"Trailling");
      ObjectDelete(0,"Breakeven");
      ObjectDelete(0, "StopLoss");
      ObjectDelete(0, "TakeProfit");// utilização da função para fechar todas as posições do gráfico
      MessageBox(" Atenção atingido o prejuízo máxim em operaçõeso determinado, EA será removido",NULL,MB_OK);
      PlaySound("\\Sounds\\alert-1");
      ExpertRemove();
     }


   if(resultado_liquido<=iLossmax*-1 && iLossmax>0)  // verficiação de perca maxima do dia máximo do dia e remoção do EA
     {
      negocio.PositionClose(_Symbol);
      ObjectDelete(0,"Trailling");
      ObjectDelete(0,"Breakeven");
      ObjectDelete(0, "StopLoss");
      ObjectDelete(0, "TakeProfit");// utilização da função para fechar todas as posições do gráfico
      MessageBox(" Atenção atingido o prejuízo máximo diário determinado, EA será removido",NULL,MB_OK);
      PlaySound("\\Sounds\\alert-1");
      ExpertRemove();
     }

   if(resultado_liquido>=iGanhomax && iGanhomax>0) // verficiação de perca maxima nas operações ou lucro máximo do dia e remoção do EA
     {
      negocio.PositionClose(_Symbol);
      ObjectDelete(0,"Trailling");
      ObjectDelete(0,"Breakeven");
      ObjectDelete(0, "StopLoss");
      ObjectDelete(0, "TakeProfit");// utilização da função para fechar todas as posições do gráfico
      MessageBox(" Atenção atingido o prejuízo máximo do dia determinado, EA será removido",NULL,MB_OK);
      PlaySound("\\Sounds\\mission-complete");
      ExpertRemove();
     }

   if(iGanhomax<0 || iLossmax <0|| iPerdamax<0 || iLucromax <0)
     {
      MessageBox(" Atenção erro !!! Controle financero definido menor que o permitido, EA será removido",NULL,MB_OK);
      PlaySound("\\Sounds\\alert-1");
      ExpertRemove();
     }



//Exibição
   /*Comment("\nCopyright 2020, Lauro Cerqueira\nResumo do dia:\n--------------\nTrades:", contador_trades, "\nOrdens: ", contador_ordens,
    "\nLucro: R$ ", DoubleToString(lucro, 2), "\nPerdas: R$ -", DoubleToString(perda, 2),
   "\nResultado: R$ ", DoubleToString(resultado_liquido, 2), "\nFator de Lucro: ", DoubleToString(fator_lucro, 2));
   */

//-----
  }

//+------------------------------------------------------------------+
//|  "FUNÇÕES PARA AUXILIAR NA VISUALIZAÇÃO DOS TP E SL"             |
//+------------------------------------------------------------------+
void Linha_Horizontal(string nome, double Price, int largura, color cor = clrBlue, ENUM_LINE_STYLE style = STYLE_SOLID)
  {
   static datetime last_time=0;
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

   ObjectCreate(0, nome, OBJ_HLINE, 0, lastbar_time, Price, 0);

   ObjectSetInteger(0, nome, OBJPROP_WIDTH, largura);
   ObjectSetInteger(0, nome, OBJPROP_STYLE, style);
   ObjectSetInteger(0, nome, OBJPROP_COLOR, cor);
   ObjectSetInteger(0, nome, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nome, OBJPROP_ZORDER, 0);
  }

//+------------------------------------------------------------------+
//|  Função Para Ogranizar Main Function                             |
//+------------------------------------------------------------------+
void Drawings()

  {
  
                  ObjectDelete(0,"Breakeven");
                  ObjectDelete(0,"Parcial");
                  ObjectDelete(0,"Parcial2");
                  if(PositionsTotal()>0)
                  {
                  if(iParcial_distancia>0 && PosicaoInfo.PositionType()==POSITION_TYPE_BUY && cont_parcial<1)
                 { Linha_Horizontal("Parcial",PosicaoInfo.PriceOpen()+Partial,1,clrBrown,STYLE_DASHDOT);} // criação da linha de parcial
                 
                   if(iParcial_distancia>0 && PosicaoInfo.PositionType()==POSITION_TYPE_SELL && cont_parcial<1)
                 { Linha_Horizontal("Parcial",PosicaoInfo.PriceOpen()-Partial,1,clrBrown,STYLE_DASHDOT);} // criação da linha de parcial
                 
                  if(iParcial_distancia2>0 && PosicaoInfo.PositionType()==POSITION_TYPE_BUY && cont_parcial<=1)
                 { Linha_Horizontal("Parcial2",PosicaoInfo.PriceOpen()+Partial2,1,clrBrown,STYLE_DASHDOT);} // criação da linha de parcial
                 
                   if(iParcial_distancia2>0 && PosicaoInfo.PositionType()==POSITION_TYPE_SELL && cont_parcial<=1)
                 { Linha_Horizontal("Parcial2",PosicaoInfo.PriceOpen()-Partial2,1,clrBrown,STYLE_DASHDOT);} // criação da linha de parcial
                   
                   if(iBreak_Even_Start>0 && PosicaoInfo.PositionType()== POSITION_TYPE_BUY&& cont_breakeven <1)
                 {Linha_Horizontal("Breakeven",PosicaoInfo.PriceOpen()+Break_Even_Start,1,clrBlueViolet,STYLE_DASHDOT);} // criação de linha para visualização do breakeven com a função Linha_Horizontal
                   
                   if(iBreak_Even_Start>0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_breakeven <1)
                 {Linha_Horizontal("Breakeven",PosicaoInfo.PriceOpen()-Break_Even_Start,1,clrBlueViolet,STYLE_DASHDOT);} // criação de linha para visualização do breakeven com a função Linha_Horizontal
                 
                 
                 }
                 
//Redesenha as linhas de STOP e TAKE PROFIT

   ObjectDelete(0, "StopLoss");
   ObjectDelete(0, "TakeProfit");
   Linha_Horizontal("StopLoss",PosicaoInfo.StopLoss(),2,clrRed,STYLE_SOLID);
   Linha_Horizontal("TakeProfit",PosicaoInfo.TakeProfit(),2,clrLimeGreen,STYLE_SOLID);

// Redesenhas as linhas de alvo para trailling stop
   if(iTrailing_Start>0 && iBreak_Even_Start>=0)
     {ObjectDelete(0,"Trailling");
      if(PositionsTotal()>0 )
        { 
         if(PosicaoInfo.PositionType()==POSITION_TYPE_BUY)
           {Linha_Horizontal("Trailling",traillbuy,1,clrFuchsia,STYLE_DASHDOT);} //--Cria linha de alvo stop movel no primeiro loop em caso de posição comprada

         if(PosicaoInfo.PositionType()==POSITION_TYPE_SELL)
           {Linha_Horizontal("Trailling",traillsell,1,clrFuchsia,STYLE_DASHDOT);} //--Cria linha de alvo stop movel no primeiro loop em caso de posição vendida
        }
   
     }

// Redesenha linhas com horário de compra e venda do dia.

   ObjectCreate(0,"HoraInicio",OBJ_VLINE,0,StringToTime(inicio),0);
   ObjectSetInteger(0,"HoraInicio",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"HoraTermino",OBJ_VLINE,0,StringToTime(termino),0);
   ObjectSetInteger(0,"HoraTermino",OBJPROP_COLOR,clrYellow);
   ObjectCreate(0,"HoraFechamento",OBJ_VLINE,0,StringToTime(fechamento),0);

   if(horario_atual.hour >= horario_fechamento.hour && horario_atual.min>horario_fechamento.min)
     {
      ObjectDelete(0,"HoraInicio");
      ObjectDelete(0,"HoraTermino");
      ObjectDelete(0,"HoraFechamento");
     }
// --- Chamada da função para painel de resumo das operações diárias
   ResumoOperacoes();

// ----------- Alimentação do Painel Gráfico---------------------------------//

   double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   string AskS=DoubleToString(Ask,_Digits);
   string BidS=DoubleToString(Bid,_Digits);
   string prejuizo=DoubleToString(perda_painel,_Digits);
   string lucro=DoubleToString(lucro_painel,_Digits);
   string resultadodia=DoubleToString(resultado_liquido_painel,_Digits);
   string fator_lucro=DoubleToString(fator_lucro_painel,2);
   string qtd_trades=IntegerToString(contador_trades_painel);
   string qtd_ordens=IntegerToString(contador_ordens_painel);

   Painel.TextModifyString(5,TEXT_TEXTSHOW,"Ask: "+AskS+" Bid: "+BidS);
   Painel.TextModifyString(7,TEXT_TEXTSHOW,""+prejuizo);
   Painel.TextModifyString(9,TEXT_TEXTSHOW,""+lucro);
   Painel.TextModifyString(11,TEXT_TEXTSHOW,""+resultadodia);
   Painel.TextModifyString(13,TEXT_TEXTSHOW,""+fator_lucro);
   Painel.TextModifyString(15,TEXT_TEXTSHOW,""+qtd_trades);
   Painel.TextModifyString(17,TEXT_TEXTSHOW,""+qtd_ordens);
   Painel.TextModifyString(21,TEXT_TEXTSHOW,""+CandleTime(_Symbol,_Period));
   Painel.TextModifyString(23,TEXT_TEXTSHOW,""+SymbolOpenPositionsVolume(_Symbol));
   Painel.TextModifyString(25,TEXT_TEXTSHOW,""+SymbolOpenResult(_Symbol));

   if(resultado_liquido_painel>0)
     {
      Painel.TextModifyInteger(11,TEXT_FONTCOLOR,clrGreen);
      return;
     }
   if(resultado_liquido_painel<0)
     {
      Painel.TextModifyInteger(11,TEXT_FONTCOLOR,clrRed);
     }
   else
     {
      Painel.TextModifyInteger(11,TEXT_FONTCOLOR,clrWhite);
     }
//-----
  }

//+------------------------------------------------------------------+
//|  "FUNÇÕES DO MÓDULO MARTINGALE"                                  |
//+------------------------------------------------------------------+
void Martingale()
  {
   if(Saidadaoperacao())
     {
      if(prova != ticket)   //--- intercalar a variavel ticket da função de saída para verficar eu o tícket informado da operação negativa são diferentes
         volumeatual=volumeatual*mult_martingale;
      prova= ticket; //-- a variável prova recebe o novo valor do ultimo tick com resultado negativo
      if(volumeatual > vol_maximo_martingale)
        {volumeatual=vol_maximo_martingale;}
     }

   else
     {volumeatual =Volume;}
  }

//+------------------------------------------------------------------+
//|  "Saída da operação"    (ultimo valor negativo)                  |
//+------------------------------------------------------------------+

bool Saidadaoperacao()
  {

   MqlDateTime  inicio_dia;
   datetime hora_atual =TimeCurrent(inicio_dia);
   inicio_dia.hour =0;
   inicio_dia.min =0;
   inicio_dia.sec =0;
   double result;

   if(!HistorySelect(StructToTime(inicio_dia),hora_atual))
     {return (false);}

   if(HistoryDealsTotal()==0)
     {return (false);}

   for(int i=HistoryDealsTotal()-1; i>=0; i--)
     {
      ticket = HistoryOrderGetTicket(i); // index do último negocio e armazena em ticket

      if(HistoryDealGetString(ticket,DEAL_SYMBOL) !=_Symbol)
         continue;

      result=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      break;   // --- interrompe o laço for na primeira verificação (ultima operação de acordo com a ordem de verificação)
     }
   if(result<=-1)  // verifica se o resultado da ultima operação é negativo
     {

      return (true);
     }

   return (false);
  }


//+------------------------------------------------------------------+
//|  Função posição do momento                                       |
//+------------------------------------------------------------------+
double GetPositionResult()
  {
   double temp=0;
   int N=PositionsTotal();
   ulong Ticket;
   for(int i=N-1; i>=0; i--)
     {
      Ticket=PositionGetTicket(i);
      temp+=PositionGetDouble(POSITION_PROFIT);
     }
   return temp;

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
