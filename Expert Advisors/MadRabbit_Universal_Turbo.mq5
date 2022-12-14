//+------------------------------------------------------------------+
//|                                    MadRabbit_Universal_Turbo.mq5 |
//|                                  Copyright 2020, Lauro Cerqueira |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+

#property copyright "Copyright 2020, Lauro Cerqueira  MAD RABBIT LAB inc."
#property link      "https://www.mql5.com/pt/laurocerqueira"
#property version   "1.0"
#property icon      "\\Images\\Mad_habitt.ico"
#property description " Este projeto foi desenvolvido para conta netting e utilização de sinais dos ativos Indice, Dólar e Ações.\nNão utilize em demais ativos.\nProteja seu capital utilize estratégias testadas. \nO EA possui módulo Martingale não nos responsabilizamos pelo mau uso deste. \nBONS TRADES!!!"


// Inclusão de bibliotecas utilizadas
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Expert/Expert.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include <ClassControlPanel.mqh>
#include <SymbolTradeMadeSimple.mqh>
#include <Indicators\Series.mqh>

// Inclusão dos Recursos utilizados
#resource "\\Indicators\\Personal\\MadRabbit_VWAP_Indicator.ex5"
#resource "\\Indicators\\Downloads\\atrstops_v1.ex5"


// Definição dos Parâmetros
input string              nomedaestrategia ="-----";              //Nome da Estratégia 
input group"                       SINAIS"
input bool                s_CrossMA         = false;              // CROSS MA
input bool                s_MA              = false;              // MOVING AVERAGE
input bool                s_MACD            = false;              // MACD
input bool                s_VWAP            = false;              // VWAP
input bool                s_ATR             = false;              // STOP ATR
input bool                s_RSI             = false;              // RSI
input group"                      INDICADORES"
input group"Cross MA"
input group"Média Rápida"
input  ENUM_TIMEFRAMES     period_curto = PERIOD_CURRENT;         // Time Frame
input int                  PeriodoCurto   = 10;                   // Período Média Curta
input int                  PeriodoCurto_desloc = 0;               // Deslocamento Curta
input ENUM_MA_METHOD       PeriodoCurto_meth = MODE_SMA;          // Tipo Média Curta
input ENUM_APPLIED_PRICE   PeriodoCurto_price = PRICE_CLOSE;      // Preço Media Curta
input bool                 add_fastMA     = false;                // Exibir indicador
input group"Média Lenta"
input  ENUM_TIMEFRAMES     period_longo = PERIOD_CURRENT;         // Time Frame
input int                  PeriodoLongo   = 11;                   // Período Média Longa
input int                  PeriodoLongo_desloc = 0;               // Deslocamento Longa
input ENUM_MA_METHOD       PeriodoLongo_meth = MODE_SMA;          // Tipo Média Longa
input ENUM_APPLIED_PRICE   PeriodoLongo_price = PRICE_CLOSE;      // Preço Média Longa
input bool                 add_slowMA     = false;                // Exibir indicador
input group"Moving Average"
input  ENUM_TIMEFRAMES     period_ma= PERIOD_CURRENT;             // Time Frame
input int                  Periodo   =20;                         // Período da Média
input int                  Periodo_desloc = 0;                    // Deslocamento da Média
input ENUM_MA_METHOD       Periodo_meth = MODE_SMA;               // Tipo da Média
input ENUM_APPLIED_PRICE   Periodo_price = PRICE_CLOSE;           // Preço da Média
input bool                 add_MA     = false;                    // Exibir indicador
input group"Macd"
input  ENUM_TIMEFRAMES    period_macd = PERIOD_CURRENT;           // Time Frame
input int                 MACD_fast_ema_period = 12;              // Período para cálculo da média móvel rápida
input int                 MACD_low_ema_period = 26;               // Período para cálculo da média móvel lenta
input int                 MACD_signal_period = 9;                      // Período para diferença entre as médias
input ENUM_APPLIED_PRICE  applied_price = PRICE_CLOSE;            // Tipo de preço ou de manipulador
input bool                add_MACD      = false;                  // Exibir indicador
input group"Vwap"
enum  PRICE_TYPE { OPEN, CLOSE, HIGH,  LOW, OPEN_CLOSE, HIGH_LOW, CLOSE_HIGH_LOW, OPEN_CLOSE_HIGH_LOW};
input PRICE_TYPE vwapprice    = CLOSE_HIGH_LOW;                  // Define cálculo daVWAP
enum  estr_VWAP {Fechamento_candle = 1, Cruzamento_Media = 2, Filtro = 3};
input estr_VWAP            estrategiavwap = Filtro;               //Define a estratégia utilizada
input  ENUM_TIMEFRAMES     period_vwapma = PERIOD_CURRENT;        // Time Frame
input int                  PeriodoMAVWAP   = 21;                  // Período Média
input int                  PeriodoMAVWAP_desloc = 0;              // Deslocamento
input ENUM_MA_METHOD       PeriodoMAVWAP_meth = MODE_SMA;         // Tipo Média
input ENUM_APPLIED_PRICE   PeriodoMAVWAP_price = PRICE_CLOSE;     // Preço Média
input bool                 add_MAVWAP     = false;                // Exibir indicado MA_VWAP
input bool                 add_vwap     = false;                  // Exibir indicador
input group"Parabolic SAR"
input  ENUM_TIMEFRAMES     period_sar = PERIOD_CURRENT;            // Time Frame
input double               iSAR_step = 0.02;                       // Fator de aceleração
input double               iSAR_maximum = 0.2;                     // máximo valor do passo
input bool                 add_SAR     = false;                    // Exibir indicador
input group"Stop ATR"
input  ENUM_TIMEFRAMES     period_atr = PERIOD_CURRENT;           // Time Frame
input uint                 atr_Length=10;                          // Indicator period
input uint                 atr_ATRPeriod=5;                        // Period of ATR
input double               atr_Kv=2.5;                             // Volatility by ATR
input int                  atr_Shift=0;                            // Horizontal shift of the indicator in bars
input bool                 add_atr=false;                          // Exibir indicador
sinput group"RSI"
enum   estrategia_entrada {FECHAMENTO_DO_CANDLE,CANDLE_ABERTO};
input  estrategia_entrada  estr_RSI = FECHAMENTO_DO_CANDLE;        // Tipo de Estratégia
input  ENUM_TIMEFRAMES     period_rsi = PERIOD_CURRENT;            // Time Frame
input int                  rsi_superior   = 70;                    // Nível Superior RSI
input int                  rsi_inferior   = 30;                    // Nível inferior RSI
input int                  rsi_periodo    = 14;                    // Periodo RSI
input ENUM_APPLIED_PRICE   rsi_price = PRICE_CLOSE;                // Preço Média
input bool                 add_RSI = false;                        // Exibir indicador
input group"                  ESTRATÉGIA"
input group"Configurações  EA"
input bool     inversao       = false;                           //Inversão de Posição
input bool     everynewbar    = true;                            //Every New Bar
input bool     invertersinal  = false;                           //Sinal Invertido
input bool     manter_posicao = false;                           //Ignorar sinais quando posicionado
input double   Volume         = 1;                               //Volume(0-Volume minimo habilitado)
enum  tipolote {Tick = 1, Pontos = 2, Finaceiro = 3, Forex_ =4, Cripto = 5}; //Enumerador tipos de calculo para lotes
input tipolote tipolotes       = Tick;                           //Indice/Dolar/Ações/Forex/Cripto 
input double   iSL             = 0;                              //Stop Loss
input double   iTP             = 0;                              //Take Profit
input ulong    ideviation      = 0;                              //Off Set de ordens
input ENUM_ORDER_TYPE_FILLING Tipo = ORDER_FILLING_RETURN;       //Tipo de Execução de Ordens
input ulong    magicNumber    = 12345678;                        //Magic Number
input group"Configurações  Cross order"
sinput string  Ativo_Negociar                 ="Ativo";          // Ativo Negociação  (se = "Ativo" usa o simbolo corrente)
input group"Configurações  Stop Móvel"
enum  TipoStop {Step = 1, Alvos = 2, SAR = 3,ATR =4, MA=5};     // Enumerador tipos de calculo para Stop
input TipoStop TStop           = Step;                          // Tipo de Stop Móvel
input double   iTrailing_Start = 0;                             //Distância. 0-Desativa a função
input double   iTrailing_Step  = 0;                             //Passo
input group"Configurações  Break Even"
input double   iBreak_Even_Start = 0;                            //Distância. 0-Desativa a função
input double   iBreak_Even_Step  = 0;                            //Ganho
input group"Saídas Parciais à Favor"
input double   iParcial_distancia = 0;                           //Distância(1). 0-Desativa a função
input double   iParcail_volume  = 0;                             //Lotes(1)
input double   iParcial_distancia2 = 0;                          //Distância(2). 0-Desativa a função
input double   iParcial_volume2  = 0;                            //Lotes(2)
input group"Saídas Parciais Contra "
input double   iParcial_distancia_c = 0;                        //Distância(1). 0-Desativa a função
input double   iParcial_volume_c  = 0;                          //Lotes(1)
input double   iParcial_distancia2_c = 0;                       //Distância(2). 0-Desativa a função
input double   iParcial_volume2_c  = 0;                         //Lotes(2)
input group"Entradas Parciais à Favor"
input double   iEParcial_distancia = 0;                         //Distância(1). 0-Desativa a função
input double   iEParcail_volume  = 0;                           //Lotes(1)
input double   iEParcial_distancia2 = 0;                        //Distância(2). 0-Desativa a função
input double   iEParcial_volume2  = 0;                          //Lotes(2)
input group"Entradas Parciais Contra "
input double   iEParcial_distancia_c = 0;                       //Distância(1). 0-Desativa a função
input double   iEParcial_volume_c  = 0;                         //Lotes(1)
input double   iEParcial_distancia2_c = 0;                      //Distância(2). 0-Desativa a função
input double   iEParcial_volume2_c  = 0;                        //Lotes(2)
input group"Módulo Martingele"
input bool     martingale     = false;                          //Ativação do Módulo Martingale
input double   mult_martingale = 0;                             //Índice inicial do multiplicador de volume
input double   vol_maximo_martingale = 0;                       //Limite de lotes
input group"Controle Financeiro"
input double   iLucromax      = 0;                              //Lucro máximo em operações. 0-Desativa a função
input double   iPerdamax      = 0;                              //Prejuízo máximo em operações. 0-Desativa a função
input double   iGanhomax      = 0;                              //Lucro máximo diário. 0-Desativa a função
input double   iLossmax       = 0;                              //Prejuízo máximo diário. 0-Desativa a função
input group"Configurações  Horário"
input bool     horariomanager =  false;                         // Ativação de  módulo de controle de horário
enum  tipodia  {Forex = 1, Cripto = 2, B3 = 3};  
input tipodia   horariofechamentomercado = Forex;                   // Horário de Fechamento de mercado
input string   inicio         = "09:05";                        // Horário de Início (entradas)
input string   termino        = "17:00";                        // Horário de Término (entradas)
input string   fechamento     = "17:30";                        // Horário de Fechamento (posições)


//--------------  DEFINES ----------------------------------------
#define SIMBOLO  Ativo_Negociar!="Ativo" ? Ativo_Negociar : _Symbol

// Contador para a função Traillling
int cont = 0;
int cont_trail = 0;
double traillbuy = 0;
double traillsell = 0;
double SL_memory =0;

// Contador para intertravamento de funções
int cont_parcial = 0;
int cont_parcialc=0;
int cont_e_parcial = 0;
int cont_e_parcialc= 0;
int cont_breakeven = 0;

// Declaração de variáveis globais para a função de comprar SL e TP
ulong  ticket_comentario_SL_antigo;                                //Retém o valor do úlitmo tickt de SL para comparação posterior
ulong  ticket_comentario_TP_antigo;                                //Retém o valor do úlitmo tickt de SL para comparação posterior

// Declaração de variáveis globais para ajuste de step
double  SL;
double  TP;
double  slipage;
double  Trailing_Start;
double  Trailing_Step;
double  Break_Even_Start;
double  Break_Even_Step;
double  Partial;
double  Partial2;
double  Partial_c;
double  Partial2_c;
double  EParcial;
double  EParcial2;
double  EParcial_c;
double  EParcial2_c;
double  tick_size_ativo;
// Declaração de variáveis para painel de resumo das operações
static MqlDateTime paycheck;
static datetime    dia_alvos;                                     // captura na função resumo a data de do controle financeiro para posterior verificação ñas funções de envio de ordem
double lucro_painel, perda_painel=0.0;
int contador_trades_painel=0;
int contador_ordens_painel=0;
double resultado_painel=0.0;
ulong ticket_painel=0.0;
double fator_lucro_painel=0.0;
double resultado_liquido_painel=0.0;                             //utilizada como intertravamento de stop financeiro nas funções Resumo() recebnedo sinal,
bool  stopfinaceiro = false;
int tradespositivos=0;
int tradesnegativos=0;
static bool chartstate_max;
static int timeframe_antigo;
double EntradaPreco;
//logica operacional () evitando abertura de posições e Fecha() evitando a inversão de mão

//Declaração de variável para martingale
static double volumeatual =0;                                  //Armazen um novo valor do volume após a verficação de martingale
ulong prova = 1;                                              //Responsávbel por verificar o ticket é o mesmo  do anterior
ulong ticket_ea = 0;                                          // responsável por captar o ticket da ultima operação negativa
static MqlDateTime memoria_martingale;                        // Capatura da data para comparação dos dias zerando a variável volume_atual na passagem dos dias

// Delcaração de variáveis globais de classe
CTrade negocio;                                                // Classe responsável pela execução de negócios
CSymbolInfo simbolo;                                           // Classe responsável pelos dados do ativo
CPositionInfo PosicaoInfo;                                     // Classe responsável pela aquisição de informações de posições
CControlPainel Painel(0, 0.2, 0.6, 0, 0, CORNER_LEFT_LOWER);;  // Classe responsável pela criação do painel de resumo
CSeries timef;                                                  // Classe responsável pela verificação do timeframe

// Declaração de manipuladores dos indicadores

int handlemedialonga, handlemediacurta, handlemacd,
    handlevwap,handlemavwap, handleSAR, handleatr,
    handlema,handleRSI;

// Estruturas de tempo para manipulação de horários
MqlDateTime horario_inicio, horario_termino, horario_fechamento, horario_atual, horario_final;

// Estruturas para verificação do ticket
MqlTick tick;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |-------------------------O.N---I.N.I.T---------------------
//+------------------------------------------------------------------+
int OnInit()
  {
// Definição do símbolo utilizado para a classe responsável CSymbol
   if(!simbolo.Name(SIMBOLO))
     {
      printf("Ativo Inválido!");
      return INIT_FAILED;
     }
// Inicialização de variáverio para recriação do Painel Gráfico
   timeframe_antigo=timef.Timeframe();
   chartstate_max = ChartGetInteger(0,CHART_IS_MAXIMIZED);
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
//--Inicialização da variável de controle de tempo do Martingale
   TimeCurrent(memoria_martingale);
//--Inicialização da variável de controle de tempo do Resultado
   paycheck.day=0;
//-- inicialização da variáveis de volume e tick
   tick_size_ativo= SymbolInfoDouble(SIMBOLO,SYMBOL_TRADE_TICK_SIZE);
   volumeatual = NormalizeVolume(Volume);
// Preenchimento das structs de tempo
   TimeToStruct(StringToTime(inicio), horario_inicio);
   TimeToStruct(StringToTime(termino), horario_termino);
   TimeToStruct(StringToTime(fechamento), horario_fechamento);
   string dia; 
   switch(horariofechamentomercado) // define a hora final a partir da escolha do mercado
     {
      case 1:
      dia= "23:58";
      break;
      case 2:
      dia= "23:58";
      break;
      case 3 :
      dia= "17:58"; 
      break;
     }
   TimeToStruct(StringToTime(dia), horario_final);
   
// Criação dos manipuladores
   if(s_CrossMA == true)
      handlemediacurta = iMA(_Symbol, period_curto, PeriodoCurto, PeriodoCurto_desloc, PeriodoCurto_meth, PeriodoCurto_price);  //- Caso seja desabilitado o handle recebe valor zero
   else
      handlemediacurta = NULL;// - Não permitindo plotagem desta forma

   if(s_CrossMA == true)
      handlemedialonga = iMA(_Symbol, period_longo, PeriodoLongo, PeriodoLongo_desloc, PeriodoLongo_meth, PeriodoLongo_price);
   else
      handlemedialonga = NULL;

   if(s_VWAP == true)
      handlevwap = iCustom(_Symbol, _Period, "::Indicators\\Personal\\MadRabbit_VWAP_Indicator.ex5", vwapprice);
   else
      handlevwap = NULL;

   if(add_MAVWAP == true)
      handlemavwap = iMA(_Symbol, period_vwapma, PeriodoMAVWAP, PeriodoMAVWAP_desloc, PeriodoMAVWAP_meth, PeriodoMAVWAP_price);
   else
      handlemavwap = NULL;

   if(add_SAR == true)
      handleSAR = iSAR(_Symbol,period_sar,iSAR_step,iSAR_maximum);
   else
      handleSAR = NULL;
   if(add_atr == true || TStop==4)

      handleatr = iCustom(_Symbol,period_atr,"::Indicators\\Downloads\\atrstops_v1.ex5",atr_Length,atr_ATRPeriod,atr_Kv,atr_Shift);
   else
      handleatr = NULL;

   if(s_MA == true || TStop==5)
      handlema = iMA(_Symbol, period_ma, Periodo, Periodo_desloc, Periodo_meth, Periodo_price);
   else
      handlema = NULL;

   if(s_MACD == true)
      handlemacd = iMACD(_Symbol, period_macd, MACD_fast_ema_period,MACD_low_ema_period,MACD_signal_period, applied_price);
   else
      handlemacd = NULL;

   if(s_RSI == true)
      handleRSI = iRSI(_Symbol,period_rsi,rsi_periodo,rsi_price);
   else
      handleRSI = NULL;


// -------------------------------------Bloco de verificações para inicialização do EA--------------------------------------------------------------
// Verificação do resultado da criação dos manipuladores
   if(handlemediacurta == INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador FAST MA"); return INIT_FAILED;}
   if(handlemedialonga == INVALID_HANDLE)
     {MessageBox("Erro na criação dos manipulador SLOW MA"); return INIT_FAILED;}
   if(handlema ==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador MA"); return INIT_FAILED;}
   if(handlemacd ==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador MACD"); return INIT_FAILED;}
   if(handlevwap ==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador VWAP"); return INIT_FAILED;}
   if(handlemavwap==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador MAVWAP"); return INIT_FAILED;}
   if(handleSAR ==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador SAR"); return INIT_FAILED;}
   if(handleatr ==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador ATR"); return INIT_FAILED;}
   if(handleRSI ==  INVALID_HANDLE)
     {MessageBox("Erro na criação do manipulador RSI"); return INIT_FAILED;}

//-- Verificação de inconsistências nos parâmetros de entrada-
   if(PeriodoLongo <= PeriodoCurto && PeriodoCurto_desloc == PeriodoLongo_desloc)
     {MessageBox("Parâmetros de médias incorretos"); return INIT_FAILED;}
   if(iParcial_distancia > 0 && iParcial_distancia2 > 0)
     {if(iParcial_distancia >= iParcial_distancia2) {MessageBox("Parâmetros de parciais à favor incorretos! Parcial1 dever ser menor que Parcial2"); return INIT_FAILED;}}
   if(iParcial_distancia_c > 0 && iParcial_distancia2_c > 0)
     {if(iParcial_distancia_c >= iParcial_distancia2_c) {MessageBox("Parâmetros de parciais contra incorretos! Parcial1 dever ser menor que Parcial2"); return INIT_FAILED;}}
   if((iTrailing_Start <= 0 && iBreak_Even_Start <= 0 && iSL <= 0 && TStop!=1 && TStop!=2)||(iTrailing_Start > 0 && iBreak_Even_Start == 0 && iSL <= 0) || (iTrailing_Start > 0 && iBreak_Even_Start > 0 && iTrailing_Start < iBreak_Even_Start && iSL < 0))
     {MessageBox("Parâmetros de Stop Movel incorretos"); return INIT_FAILED;}
   if((tipolotes == 1 && _Digits!=0)|| (tipolotes==2 && _Digits!=3) || (tipolotes==3 &&_Digits!=2))
     {
      MessageBox("Parâmetros de cálculo do ativo com erro verificar tipo de Ticks");
     }
   if(Volume==0)
     {
      MessageBox("Atenção!Volume minimo definido para operação");
     }
   if(martingale)
     {
      if(MathMod(vol_maximo_martingale,mult_martingale)!=0)
        {
         MessageBox("Martingale incompativel! verificar volume");
         return INIT_FAILED;
        }
      if(Volume >(vol_maximo_martingale/mult_martingale))
        {
         MessageBox("Martingale incompativel! verificar multiplicador");
         return INIT_FAILED;
        }
     }
// Verificação de inconsistências nos parâmetros de entrada de horas
   if(horario_inicio.hour > horario_termino.hour || (horario_inicio.hour == horario_termino.hour && horario_inicio.min > horario_termino.min))
     { MessageBox("Parâmetros de Horário inválidos!"); return INIT_FAILED;}
// Verificação de inconsistências nos parâmetros de entrada horas
   if(horario_termino.hour > horario_fechamento.hour || (horario_termino.hour == horario_fechamento.hour && horario_termino.min > horario_fechamento.min))
     {MessageBox("Parâmetros de Horário inválidos!"); return INIT_FAILED;}
// Verificação de inconsistências nos parâmetros de lucro
   if(iGanhomax < 0 || iLossmax < 0 || iPerdamax < 0 || iLucromax < 0)
     {
      MessageBox(" Atenção erro !!! Controle financero definido menor que o permitido, EA será removido", NULL, MB_OK);
      PlaySound("\\Sounds\\alert2.wav");
      ExpertRemove();
     }
//============================================================================================================================================================
// -Apaga as lihnas naturais do MT5 de Stop Loss e Stop Gain ( utilização em conjunto com a mudança de cores na função Onint
   ChartSetInteger(0, CHART_COLOR_STOP_LEVEL, 0, clrNONE);
// -Apaga as lihnas naturais do MT5 de Negociação
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS,0,false);


//-Definição de template básico
   ChartDefines(true, 0);
//================================================Bloco para adição de  indicador ao gráfico===================================================================
// - Gráfico
   if(add_fastMA == true)
     {
      if(!ChartIndicatorAdd(0, 0, handlemediacurta))
        {
         MessageBox("Erro ao adiocionar FAST MA");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 0));

   if(add_slowMA == true)
     {
      if(!ChartIndicatorAdd(0, 0, handlemedialonga))
        {MessageBox("Erro ao adiocionar SLOW MA"); return INIT_FAILED;}
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 1));


   if(add_vwap == true)
     {
      if(!ChartIndicatorAdd(0, 0, handlevwap))
        {
         MessageBox("Erro ao adiocionar VWAP");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 2));

   if(add_MAVWAP == true)
     {
      if(!ChartIndicatorAdd(0,0, handlemavwap))
        {
         MessageBox("Erro ao adiocionar MA MAVWAP");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 3));

   if(add_SAR == true)
     {
      if(!ChartIndicatorAdd(0, 0, handleSAR))
        {
         MessageBox("Erro ao adiocionar ISAR");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 4));

   if(add_atr == true)
     {
      if(!ChartIndicatorAdd(0, 0, handleatr))
        {
         MessageBox("Erro ao adiocionar ATR");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 5));

   if(add_MA == true)
     {
      if(!ChartIndicatorAdd(0, 0, handlema))
        {
         MessageBox("Erro ao adiocionar MA");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, 5));

//---Janela Separada

   if(add_MACD == true)
     {
      if(!ChartIndicatorAdd(0, 1, handlemacd))
        {
         MessageBox("Erro ao adiocionar MACD");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 1, ChartIndicatorName(0, 1, 0));



   if(add_RSI == true)
     {
      if(!ChartIndicatorAdd(0, 1, handleRSI))
        {
         MessageBox("Erro ao adiocionar RSI");
         return INIT_FAILED;
        }
     }
   else
      ChartIndicatorDelete(0, 1, ChartIndicatorName(0, 1, 1));



//=====================================================Bloco de inicialização do painel de resumo===============================================================
   Painel.CreatePanel();                                                         // inicialização da função do painel
   Painel.CreateText("MAD RABBIT LAB Inc Lauro cerqueira,Copyright 2020", clrWhite, 7, true);                           // código pra criação de texto, este será o texto de ídice "0"                           // código pra criação de texto, este será o texto de ídice "1"
   Painel.CreateText("===========================================================", clrWhite, 5, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 11, true);
   Painel.CreateText("-----------------------------------------------------------", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateText("Loading.....", clrWhite, 9, true);
   Painel.CreateButton("Zerar", clrWhite, clrRed);                   // código pra criação de botão, este será o texto de ídice "0"
   Painel.CreateButton("BuyAtMarket", clrWhite, clrBlue);
   Painel.CreateButton("SellAtMarket", clrWhite, clrGreen);
   

   string ativo = SIMBOLO;
   if(ativo != _Symbol)
      Painel.CreateText("CrossOrder: " + ativo, clrRed, 9, true);

//===============================================================================================================================================================
//--- Inicialização concluída
   PlaySound("\\Sounds\\race-robot-start.wav");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |----------------------------------------------ONDEINT-----------------------------------------
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
   for(int i = ChartIndicatorsTotal(0, 0); i > 0; i--)
     {
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, ChartIndicatorsTotal(0, 0) - i));
      ChartIndicatorDelete(0, 1, ChartIndicatorName(0, 1, ChartIndicatorsTotal(0, 1) - i));
     }
//--- Deleta todos os objetos do gráfico
   ObjectsDeleteAll(0, -1, -1);

//--- Deleta Painel Gráfico

   Painel.DeletePanel();
//--Solicita redesenho do gráfico
   ChartRedraw();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |-------------------------------------------------MAIN FUNCTION--------------------------------//
//+------------------------------------------------------------------+
void OnTick()
  {
// Atualização dos dados do ativo
   if(!simbolo.RefreshRates())
      return;

   if(everynewbar == true) //--Função IsNewbar para evitar efetuar cálculos a cada tick e sim a cada fechamento de barra para envio de ordens
      if(isNewBar())
         logicaoperacional();
      else               // -Não sendo uma nova barra verificar somente breakeaven , Stop Movel, Parcial
        {
         Martingale();
         BREAK_EVEN();
         TRAILING_STOP();
         Parcial();
         EntradaParcial();
         if(timef.Timeframe() != timeframe_antigo || ChartGetInteger(0,CHART_IS_MAXIMIZED) != chartstate_max)
           {Painel.DeletePanel();}  // Função de reorientação do painel gráfico
         Drawings();                // Função para redesenhar no gráfico
         ObjectsArrowToBack();      // coloca todos os obejetos para parte posterior do painel
         VerificaSLTP();

        }
   else
     {
      Martingale();
      logicaoperacional();
      BREAK_EVEN();
      TRAILING_STOP();
      Parcial();
      EntradaParcial();
      if(timef.Timeframe() != timeframe_antigo || ChartGetInteger(0,CHART_IS_MAXIMIZED) != chartstate_max)
        {Painel.DeletePanel();}
      Drawings();
      ObjectsArrowToBack();
      VerificaSLTP();
     }


  }
//+------------------------------------------------------------------+
//|  Função de interação com painel gráfico                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(Painel.ButtonGetState(1))
         if(negocio.PositionClose(SIMBOLO))
           {
            Alert("Fechamento de posição efetuado pelo botão zerar");
            ObjectDelete(0, "Trailling");
            ObjectDelete(0, "Breakeven");
            ObjectDelete(0, "StopLoss");
            ObjectDelete(0, "TakeProfit");
            ObjectDelete(0, "Parcial");
            ObjectDelete(0,"Posição");
            ObjectDelete(0, "Parcial2");
            ObjectDelete(0, "Parcialc");
            ObjectDelete(0, "Parcial2c");
            ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
            Painel.ButtonSetState(1, false);
           }
      if(Painel.ButtonGetState(2))
        {
         if(PositionSelect(SIMBOLO))
            if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL)
              {
               ObjectDelete(0, "Trailling");
               ObjectDelete(0, "Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               ObjectDelete(0,"Posição");
               ObjectDelete(0, "Parcial2");
               ObjectDelete(0, "Parcialc");
               ObjectDelete(0, "Parcial2c");
               ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
               Compra();
               Alert("Buy at Market");
               Painel.ButtonSetState(2, false);
              }
            else
              {
               negocio.PositionClose(SIMBOLO);
               ObjectDelete(0, "Trailling");
               ObjectDelete(0, "Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               ObjectDelete(0,"Posição");
               ObjectDelete(0, "Parcial2");
               ObjectDelete(0, "Parcialc");
               ObjectDelete(0, "Parcial2c");
               ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
               Alert("Buy at Market");
               Painel.ButtonSetState(2, false);
              }
         else
           {
            ObjectDelete(0, "Trailling");
            ObjectDelete(0, "Breakeven");
            ObjectDelete(0, "StopLoss");
            ObjectDelete(0, "TakeProfit");
            ObjectDelete(0, "Parcial");
            ObjectDelete(0,"Posição");
            ObjectDelete(0, "Parcial2");
            ObjectDelete(0, "Parcialc");
            ObjectDelete(0, "Parcial2c");
            ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
            Compra();
            Alert("Buy at Market");
            Painel.ButtonSetState(2, false);
           }
        }

      if(Painel.ButtonGetState(3))
        {
         if(PositionSelect(SIMBOLO))
            if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY)
              {
               ObjectDelete(0, "Trailling");
               ObjectDelete(0, "Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               ObjectDelete(0,"Posição");
               ObjectDelete(0, "Parcial2");
               ObjectDelete(0, "Parcialc");
               ObjectDelete(0, "Parcial2c");
               ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
               Venda();
               Alert("Sell at Market");
               Painel.ButtonSetState(2, false);
              }
            else
              {
               negocio.PositionClose(SIMBOLO);
               ObjectDelete(0, "Trailling");
               ObjectDelete(0, "Breakeven");
               ObjectDelete(0, "StopLoss");
               ObjectDelete(0, "TakeProfit");
               ObjectDelete(0, "Parcial");
               ObjectDelete(0,"Posição");
               ObjectDelete(0, "Parcial2");
               ObjectDelete(0, "Parcialc");
               ObjectDelete(0, "Parcial2c");
               ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
               ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
               Alert("Sell at Market");
               Painel.ButtonSetState(2, false);
              }
         else
           {
            ObjectDelete(0, "Trailling");
            ObjectDelete(0, "Breakeven");
            ObjectDelete(0, "StopLoss");
            ObjectDelete(0, "TakeProfit");
            ObjectDelete(0, "Parcial");
            ObjectDelete(0,"Posição");
            ObjectDelete(0, "Parcial2");
            ObjectDelete(0, "Parcialc");
            ObjectDelete(0, "Parcial2c");
            ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
            ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
            Venda();
            Alert("Buy at Market");
            Painel.ButtonSetState(2, false);
           }
        }
     }
  }

//=======================================================================FUNÇÕES ÚTEIS ======================================================================================
//+------------------------------------------------------------------+
//| Função para normalização dos lotes por ativo                     |
//+-------------------------------------------------------------------
void Normalizastep()
  {


         SL             = iSL * MathPow(10,_Digits)* _Point;
         TP             = iTP * MathPow(10,_Digits)* _Point;
         slipage      = ideviation * _Point;
         Trailing_Start = iTrailing_Start * MathPow(10,_Digits)* _Point;
         Trailing_Step  = iTrailing_Step * MathPow(10,_Digits)* _Point;
         Break_Even_Start = iBreak_Even_Start * MathPow(10,_Digits)* _Point;
         Break_Even_Step  = iBreak_Even_Step * MathPow(10,_Digits)* _Point;
         Partial        = iParcial_distancia * MathPow(10,_Digits)* _Point;
         Partial2        = iParcial_distancia2 * MathPow(10,_Digits)* _Point;
         Partial_c   =iParcial_distancia_c* MathPow(10,_Digits)* _Point;
         Partial2_c  =iParcial_distancia2_c* MathPow(10,_Digits)* _Point;
         EParcial        = iEParcial_distancia * MathPow(10,_Digits)* _Point;
         EParcial2        = iEParcial_distancia2 * MathPow(10,_Digits)* _Point;
         EParcial_c   =iEParcial_distancia_c* MathPow(10,_Digits)* _Point;
         EParcial2_c  =iEParcial_distancia2_c* MathPow(10,_Digits)* _Point;
  /* switch(tipolotes)
     {
      case 1:

         SL             = iSL * _Point;
         TP             = iTP * _Point;
         slipage      = ideviation * _Point;
         Trailing_Start = iTrailing_Start * _Point;
         Trailing_Step  = iTrailing_Step * _Point;
         Break_Even_Start = iBreak_Even_Start * _Point;
         Break_Even_Step  = iBreak_Even_Step * _Point;
         Partial        = iParcial_distancia * _Point;
         Partial2        = iParcial_distancia2 * _Point;
         Partial_c   =iParcial_distancia_c*_Point;
         Partial2_c  =iParcial_distancia2_c*_Point;
         EParcial        = iEParcial_distancia * _Point;
         EParcial2        = iEParcial_distancia2 * _Point;
         EParcial_c   =iEParcial_distancia_c*_Point;
         EParcial2_c  =iEParcial_distancia2_c*_Point;

         break;

      case 2:

         if(_Digits == 3)
           {
            SL             = iSL * 1000 * _Point;
            TP             = iTP * 1000 * _Point;
            slipage      = ideviation * 1000 * _Point;
            Trailing_Start = iTrailing_Start * 1000 * _Point;
            Trailing_Step  = iTrailing_Step * 1000 * _Point;
            Break_Even_Start = iBreak_Even_Start * 1000 * _Point;
            Break_Even_Step  = iBreak_Even_Step * 1000 * _Point;
            Partial        = iParcial_distancia * 1000 * _Point;
            Partial2        = iParcial_distancia2 * 1000 * _Point;
            Partial_c   =iParcial_distancia_c*1000*_Point;
            Partial2_c  =iParcial_distancia2_c*1000*_Point;
            EParcial        = iEParcial_distancia *1000* _Point;
            EParcial2        = iEParcial_distancia2 *1000* _Point;
            EParcial_c   =iEParcial_distancia_c*1000*_Point;
            EParcial2_c  =iEParcial_distancia2_c*1000*_Point;
           }
         break;

      case 3 :

         if(_Digits == 2)
           {
            SL             = iSL * 100 * _Point;
            TP             = iTP * 100 * _Point;
            slipage      = ideviation * 100 * _Point;
            Trailing_Start = iTrailing_Start * 100 * _Point;
            Trailing_Step  = iTrailing_Step * 100 * _Point;
            Break_Even_Start = iBreak_Even_Start * 100 * _Point;
            Break_Even_Step  = iBreak_Even_Step * 100 * _Point;
            Partial        = iParcial_distancia * 100 * _Point;
            Partial2        = iParcial_distancia2 * 100 * _Point;
            Partial_c   =iParcial_distancia_c*100*_Point;
            Partial2_c  =iParcial_distancia2_c*100*_Point;
            EParcial        = iEParcial_distancia *100* _Point;
            EParcial2        = iEParcial_distancia2 *100* _Point;
            EParcial_c   =iEParcial_distancia_c*100*_Point;
            EParcial2_c  =iEParcial_distancia2_c*100*_Point;
           }
         break;
         
    

     } */
  }
//+------------------------------------------------------------------+
//| Definir um template básico ao gráfico                            |
//+------------------------------------------------------------------+
bool ChartDefines(const bool value, const long chart_ID = 0)
  {
//--- Resetar Ultimo Erro
   ResetLastError();

//--- Definir Exibição Do Grid
   if(!ChartSetInteger(chart_ID, CHART_SHOW_GRID, 0, false))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir Exibição Do de ask
   if(!ChartSetInteger(chart_ID, CHART_SHOW_ASK_LINE, 0, false))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor da Linha Ask
   if(!ChartSetInteger(chart_ID, CHART_COLOR_ASK, clrDeepSkyBlue))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir Exibição Do de bid
   if(!ChartSetInteger(chart_ID, CHART_SHOW_BID_LINE, 0, false))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor da Linha bid
   if(!ChartSetInteger(chart_ID, CHART_COLOR_BID, clrGold))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor do grafico de linha
   if(!ChartSetInteger(chart_ID, CHART_COLOR_CHART_LINE, clrWhite))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }
//--- Definir cor da linha do ultimo Preço
   if(!ChartSetInteger(chart_ID, CHART_SHOW_LAST_LINE, true))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }
//--- Definir cor da linha do ultimo Preço
   if(!ChartSetInteger(chart_ID, CHART_COLOR_LAST, clrWhite))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor do Primeiro Plano
   if(!ChartSetInteger(chart_ID, CHART_COLOR_FOREGROUND, clrWhite))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor Do Fundo
   if(!ChartSetInteger(chart_ID, CHART_COLOR_BACKGROUND, clrBlack))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor Do Candle De Alta
   if(!ChartSetInteger(chart_ID, CHART_COLOR_CANDLE_BULL, clrGreen))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor da Barra de Alta
   if(!ChartSetInteger(chart_ID, CHART_COLOR_CHART_UP, clrGreen))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor da Barra de baixa
   if(!ChartSetInteger(chart_ID, CHART_COLOR_CHART_DOWN, clrRed))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);
     }

//--- Definir cor do Candle de Baixa
   if(!ChartSetInteger(chart_ID, CHART_COLOR_CANDLE_BEAR, clrRed))
     {
      //--- Caso Der Erro Exibilo
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(false);

     }
   return(true);
  }
//+-------------------------------------------------------------------+
//| Função para verificação se o ativo encontra-se em leilão          |
//+-------------------------------------------------------------------+
void InformacaoPreco()
  {
   if(!MQLInfoInteger(MQL_TESTER))
      if(SymbolInfoTick(SIMBOLO, tick) == true)
        {
         double   bid = tick.bid;
         double   ask = tick.ask;

         if(bid == 0 || ask == 0) //Cotacoes zeradas
            Print("As cotações estão zeradas");

         if(bid >= ask) //Leilão
            Print("O Ativo atual está em leilão");
        }
  }
//+------------------------------------------------------------------+
//| Lógica operacional                                               |
//+------------------------------------------------------------------+
// EA em horário de entrada em novas operações
void logicaoperacional()
  {
  
  if (horariomanager == true) {      // Verifica se o módulo de controles de horário está ativado

   if(HorarioEntrada())
     {

      // EA não está posicionado
      if(SemPosicao())
        {
         ObjectDelete(0, "Breakeven"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Trailling"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcial");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcial2");  // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcialc");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcial2c");  // Apaga o objeto caso não esteja posicionado

         ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado

         ObjectDelete(0, "Posição");   // Apaga o objeto caso não esteja posicionado

         cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
         cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
         cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
         cont_parcialc =0;             // zeragem do contador do loop  saídas de parciais
         cont_breakeven =0;            // zeragem do contador de loop brakeven
         SL_memory =0;                 // Zeragem da memória de SL da função trailling

         if(martingale == true)        // Ativação da função martingale
            Martingale();

         // Módulo Sinais identifica a direação de compra e venda
         if(stopfinaceiro==false)
           {
            if(Signals() == 1)         // Estratégia indicou compra
               Compra();

            if(Signals() == -1)        // Estratégia indicou venda
               Venda();
           }
        }
      else
        {
         if ( manter_posicao == false)  // Mantem a posição em caso de seleção true não  fechando a posição pelo módulo de sinais 
               {
               // Verificar estratégia e determinar compra ou venda
               if(Signals() == 1) // Estratégia indicou compra
                  if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL)
                     Fechar();
      
               if(Signals() == -1)   // Estratégia indicou venda
                  if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY)
                     Fechar();
                }
        }
     }
// EA em horário de fechamento de posições abertas
   if(HorarioFechamento())
      if(!SemPosicao())// Se EA está posicionado, fechar posição
         Fechar();
    }
 else {             //Inicia a logica caso o modulo de controles de horario não esteja ativado
 
 
   // EA não está posicionado
      if(SemPosicao())
        {
         ObjectDelete(0, "Breakeven"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Trailling"); // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcial");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcial2");  // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcialc");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "Parcial2c");  // Apaga o objeto caso não esteja posicionado

         ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
         ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado

         ObjectDelete(0, "Posição");   // Apaga o objeto caso não esteja posicionado

         cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
         cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
         cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
         cont_parcialc =0;             // zeragem do contador do loop  saídas de parciais
         cont_breakeven =0;            // zeragem do contador de loop brakeven
         SL_memory =0;                 // Zeragem da memória de SL da função trailling

         if(martingale == true)        // Ativação da função martingale
            Martingale();

         // Módulo Sinais identifica a direação de compra e venda
         if(stopfinaceiro==false)
           {
            if(Signals() == 1)         // Estratégia indicou compra
               Compra();

            if(Signals() == -1)        // Estratégia indicou venda
               Venda();
           }
        }
      else
        {
         if ( manter_posicao == false)  // Mantem a posição em caso de seleção true não  fechando a posição pelo módulo de sinais 
               {
               // Verificar estratégia e determinar compra ou venda
               if(Signals() == 1) // Estratégia indicou compra
                  if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL)
                     Fechar();
      
               if(Signals() == -1)   // Estratégia indicou venda
                  if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY)
                     Fechar();
                }
        }
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
         if(horario_atual.min >= horario_inicio.min)// Se minuto atual maior ou igual ao de início => está no horário de entradas
            return true;
         else
            return false;// Do contrário não está no horário de entradas

      // Hora atual igual a de término
      if(horario_atual.hour == horario_termino.hour)
         if(horario_atual.min <= horario_termino.min) // Se minuto atual menor ou igual ao de término => está no horário de entradas
            return true;
         else
            return false;// Do contrário não está no horário de entradas

      // Hora atual maior que a de início e menor que a de término
      return true;
     }
// Hora fora do horário de entradas
   return false;
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
         if(horario_atual.min >= horario_fechamento.min) // Se minuto atual maior ou igual ao de fechamento => está no horário de fechamento
            return true;
         else
            return false;// Do contrário não está no horário de fechamento

      // Hora atual maior que a de fechamento
      return true;
     }
// Hora fora do horário de fechamento
   return false;
  }
//+------------------------------------------------------------------+
//| Realizar compra com parâmetros especificados por input           |
//+------------------------------------------------------------------+
void Compra()
  {
   double stoploss = 0;
   double takeprofit = 0;
   double price =  SymbolInfoDouble(SIMBOLO, SYMBOL_ASK); // Determinação do preço da ordem a mercado
   double price_normalized = NormalizePrice(price, SIMBOLO,tick_size_ativo);

   if(SL > 0)
     { stoploss = (price_normalized - NormalizePrice(SL, SIMBOLO,tick_size_ativo));} // Cálculo normalizado do stoploss
   if(TP > 0)
     { takeprofit = (price_normalized + NormalizePrice(TP, SIMBOLO, tick_size_ativo));}// Cálculo normalizado do takeprofit

   if(!martingale)
     {
      ObjectDelete(0, "Breakeven");
      ObjectDelete(0, "Parcial");
      ObjectDelete(0, "Parcial2");
      ObjectDelete(0, "Trailling");
      ObjectDelete(0, "Parcial2c");
      ObjectDelete(0, "Posição");
      ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
      negocio.Buy(volumeatual, SIMBOLO, price_normalized, stoploss, takeprofit, "Entrada de Compra"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      negocio.PrintResult();
      negocio.CheckResultRetcode();
      PlaySound("\\Sounds\\Register.wav");

      if(iBreak_Even_Start > 0)
         Linha_Horizontal("Breakeven", negocio.ResultPrice() + Break_Even_Start, 1, clrYellow, STYLE_DASHDOT); // criação de linha para visualização do breakeven com a função Linha_Horizontal

      // Saídas Parciaias

      if(iParcial_distancia > 0)
         Linha_Horizontal("Parcial", negocio.ResultPrice() + Partial, 1, clrBrown, STYLE_DASHDOT);

      if(iParcial_distancia2 > 0)
         Linha_Horizontal("Parcial2", negocio.ResultPrice() + Partial2, 1, clrBrown, STYLE_DASHDOT);

      if(iParcial_distancia_c > 0)
         Linha_Horizontal("Parcialc", negocio.ResultPrice() - Partial_c, 1, clrBrown, STYLE_DASHDOT);

      if(iParcial_distancia2_c > 0)
         Linha_Horizontal("Parcial2c", negocio.ResultPrice() - Partial2_c, 1, clrBrown, STYLE_DASHDOT);

      // Entradas Parciais
      if(iEParcial_distancia > 0)
         Linha_Horizontal("EParcial", negocio.ResultPrice() + EParcial, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia2 > 0)
         Linha_Horizontal("EParcial2", negocio.ResultPrice()+ EParcial2, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia_c > 0)
         Linha_Horizontal("EParcialc", negocio.ResultPrice() - EParcial_c, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia2_c > 0)
         Linha_Horizontal("EParcial2c", negocio.ResultPrice() - EParcial2_c, 1, clrOrange, STYLE_DASHDOT);

      if(PositionsTotal() > 0)
        {
         Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
         ObjectSetInteger(0,"Posição",OBJPROP_BACK,true);
         EntradaPreco= negocio.ResultPrice();
        }

     } // criação da linha de parcial

   else
     {
      ObjectDelete(0, "Breakeven");
      ObjectDelete(0, "Parcial");
      ObjectDelete(0, "Parcial2");
      ObjectDelete(0, "Trailling");
      ObjectDelete(0, "Parcial2c");
      ObjectDelete(0, "Posição");
      ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
      negocio.Buy(volumeatual, SIMBOLO, price_normalized, stoploss, takeprofit, "Entrada Martingale Compra"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      PlaySound("\\Sounds\\Register.wav");

      if(iBreak_Even_Start > 0)
         Linha_Horizontal("Breakeven", negocio.ResultPrice() + Break_Even_Start, 1, clrYellow, STYLE_DASHDOT); // criação de linha para visualização do breakeven com a função Linha_Horizontal


      //-- Saídas Parciais
      if(iParcial_distancia > 0)
         Linha_Horizontal("Parcial", negocio.ResultPrice() + Partial, 1, clrBrown, STYLE_DASHDOT);

      if(iParcial_distancia2 > 0)
         Linha_Horizontal("Parcial2", negocio.ResultPrice() + Partial2, 1, clrBrown, STYLE_DASHDOT);

      if(iParcial_distancia_c > 0)
         Linha_Horizontal("Parcialc", negocio.ResultPrice() - Partial_c, 1, clrBrown, STYLE_DASHDOT);

      if(iParcial_distancia2_c > 0)
         Linha_Horizontal("Parcial2c", negocio.ResultPrice() - Partial2_c, 1, clrBrown, STYLE_DASHDOT);

      // Entradas Parciais
      if(iEParcial_distancia > 0)
         Linha_Horizontal("EParcial", negocio.ResultPrice() + EParcial, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia2 > 0)
         Linha_Horizontal("EParcial2", negocio.ResultPrice() + EParcial2, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia_c > 0)
         Linha_Horizontal("EParcialc", negocio.ResultPrice() - EParcial_c, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia2_c > 0)
         Linha_Horizontal("EParcial2c", negocio.ResultPrice() - EParcial2_c, 1, clrOrange, STYLE_DASHDOT);

      if(PositionsTotal() > 0)
        {
         Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
         ObjectSetInteger(0,"Posição",OBJPROP_BACK,true);
         EntradaPreco= negocio.ResultPrice();
        }
     }
  }
//+------------------------------------------------------------------+
//| Realizar venda com parâmetros especificados por input            |
//+------------------------------------------------------------------+
void Venda()
  {
   double stoploss = 0;
   double takeprofit = 0;
   double price = SymbolInfoDouble(SIMBOLO, SYMBOL_BID); // Determinação do preço da ordem a mercado
   double price_normalized = NormalizePrice(price, SIMBOLO, tick_size_ativo);

   if(SL > 0)
     { stoploss = (price_normalized + NormalizePrice(SL, SIMBOLO, tick_size_ativo));} // Cálculo normalizado do stoploss
   if(TP > 0)
     { takeprofit = (price_normalized - NormalizePrice(TP, SIMBOLO, tick_size_ativo));} // Cálculo normalizado do takeprofit

   if(!martingale)
     {
      ObjectDelete(0, "Breakeven");
      ObjectDelete(0, "Parcial");
      ObjectDelete(0, "Parcial2");
      ObjectDelete(0, "Trailling");
      ObjectDelete(0, "Parcial2c");
      ObjectDelete(0, "Posição");
      ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
      SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
      negocio.Sell(NormalizeVolume(Volume), SIMBOLO, price_normalized, stoploss, takeprofit, "Entrada Venda"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      negocio.PrintResult();
      PlaySound("\\Sounds\\Register.wav");

      if(iBreak_Even_Start > 0)
         Linha_Horizontal("Breakeven", negocio.ResultPrice() - Break_Even_Start, 1, clrYellow, STYLE_DASHDOT); // criação de linha para visualização do breakeven com a função Linha_Horizontal
      if(iParcial_distancia > 0)
         Linha_Horizontal("Parcial", negocio.ResultPrice() - Partial, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial

      if(iParcial_distancia2 > 0)
         Linha_Horizontal("Parcial2", negocio.ResultPrice() - Partial2, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial2


      if(iParcial_distancia_c > 0)
         Linha_Horizontal("Parcialc", negocio.ResultPrice() + Partial_c, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial Contrária ao movimento

      if(iParcial_distancia2_c > 0)
         Linha_Horizontal("Parcial2c", negocio.ResultPrice() + Partial2_c, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial2 Contrária ao movimento




      // Entradas Parciais
      if(iEParcial_distancia > 0)
         Linha_Horizontal("EParcial", negocio.ResultPrice() - EParcial, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia2 > 0)
         Linha_Horizontal("EParcial2", negocio.ResultPrice() - EParcial2, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia_c > 0)
         Linha_Horizontal("EParcialc", negocio.ResultPrice() + EParcial_c, 1, clrOrange, STYLE_DASHDOT);

      if(iEParcial_distancia2_c > 0)
         Linha_Horizontal("EParcial2c", negocio.ResultPrice() + EParcial2_c, 1, clrOrange, STYLE_DASHDOT);

      if(PositionsTotal() > 0)
        {
         Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
         ObjectSetInteger(0,"Posição",OBJPROP_BACK,true);
         EntradaPreco= negocio.ResultPrice();
        }
     }
   else
     {
      ObjectDelete(0, "Breakeven");
      ObjectDelete(0, "Parcial");
      ObjectDelete(0, "Parcial2");
      ObjectDelete(0, "Trailling");
      ObjectDelete(0, "Parcial2c");
      ObjectDelete(0, "Posição");
      ObjectDelete(0, "EParcial");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2");  // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcialc");   // Apaga o objeto caso não esteja posicionado
      ObjectDelete(0, "EParcial2c");  // Apaga o objeto caso não esteja posicionado
      SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
      negocio.Sell(NormalizeVolume(Volume), SIMBOLO, price_normalized, stoploss, takeprofit, "Entrada Martingale Venda"); // Envio da ordem de compra pela classe responsável
      negocio.PrintRequest();
      negocio.PrintResult();
      PlaySound("\\Sounds\\Register.wav");

      if(iBreak_Even_Start > 0)
         Linha_Horizontal("Breakeven", negocio.ResultPrice() - Break_Even_Start, 1, clrYellow, STYLE_DASHDOT);// criação de linha para visualização do breakeven com a função Linha_Horizontal
      if(iParcial_distancia > 0)
         Linha_Horizontal("Parcial", negocio.ResultPrice() - Partial, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial
      if(iParcial_distancia2 > 0)
         Linha_Horizontal("Parcial2", negocio.ResultPrice() - Partial2, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial2

      if(iParcial_distancia_c > 0)
         Linha_Horizontal("Parcialc", negocio.ResultPrice() + Partial_c, 1, clrBrown, STYLE_DASHDOT); // criação da linha de parcial Contrária ao movimento

      if(iParcial_distancia2_c > 0)
         Linha_Horizontal("Parcial2c", negocio.ResultPrice() + Partial2_c, 1, clrBrown, STYLE_DASHDOT); // criação da linha de p

      if(PositionsTotal() > 0)
        {
         Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
         ObjectSetInteger(0,"Posição",OBJPROP_BACK,true);
         EntradaPreco= negocio.ResultPrice();
        }
     }
  }
//+------------------------------------------------------------------+
//| Função para normalizar preço                                     |
//+------------------------------------------------------------------+
double NormalizePrice(double price_to, string symbol, double tick_)
  {
   double finalprice;
   int _digits_ = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   if(tipolotes ==1 || tipolotes == 2)
     {
      static const double _tick = tick_ ? tick_ : SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      finalprice = NormalizeDouble((round(price_to / _tick) * _tick), 0);
      return round(finalprice);
     }
  if (tipolotes == 3)
      {finalprice=NormalizeDouble(price_to - MathMod(price_to,tick_size_ativo),2);
      return finalprice ;}
      
   if (tipolotes == 4 || tipolotes == 5)
      {static const double _tick = tick_ ? tick_ : SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      finalprice = NormalizeDouble((round(price_to / _tick) * _tick),_digits_);}
  
   return finalprice;
  }

//+------------------------------------------------------------------+
//| Função para normalizar volume                                    |
//+------------------------------------------------------------------+
double NormalizeVolume(double volume)
  {
   double result;
   static const double min  = SymbolInfoDouble(SIMBOLO,SYMBOL_VOLUME_MIN);
   static const double max  = SymbolInfoDouble(SIMBOLO,SYMBOL_VOLUME_MAX);
   static const int digits  = (int)MathLog10(SymbolInfoDouble(SIMBOLO,SYMBOL_VOLUME_STEP));
   if(volume < min)
      volume = min;
   if(volume > max)
      volume = max;
   result =NormalizeDouble(volume, digits);
   return result;
  }
//+------------------------------------------------------------------+
//| Fechar posição aberta                                            |
//+------------------------------------------------------------------+
void Fechar()
  {
   double stoploss_sell = 0.0;
   double stoploss_buy = 0.0;
   double takeprofit_sell = 0.0;
   double takeprofit_buy = 0.0;
   double price_sell = SymbolInfoDouble(SIMBOLO, SYMBOL_BID); // Determinação do preço da ordem a mercado
   double price_normalized_sell = NormalizePrice(price_sell, SIMBOLO, tick_size_ativo);
   double price_buy = SymbolInfoDouble(SIMBOLO, SYMBOL_ASK); // Determinação do preço da ordem a mercado
   double price_normalized_buy = NormalizePrice(price_buy, SIMBOLO, tick_size_ativo);

   if(SL > 0)
     {
      stoploss_sell = (price_normalized_sell + NormalizePrice(SL, SIMBOLO, tick_size_ativo)); // Cálculo normalizado do stoploss sell
      stoploss_buy = (price_normalized_buy - NormalizePrice(SL, SIMBOLO, tick_size_ativo));
     } // Cálculo normalizado do stoploss buy
   if(TP > 0)
     {
      takeprofit_sell = (price_normalized_sell - NormalizePrice(TP,SIMBOLO,tick_size_ativo)); // Cálculo normalizado do takeprofit sell
      takeprofit_buy = (price_normalized_buy + NormalizePrice(TP, SIMBOLO,tick_size_ativo));
     } // Cálculo normalizado do takeprofit buy

// Verificação de posição aberta
   if(!PositionSelect(SIMBOLO))
      return;

   long tipo = PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta
   double volume_fechamento = PositionGetDouble(POSITION_VOLUME); // verificação do volume utilizado no último negócio e armazenado para fehcamento da posição

// Vender em caso de posição comprada
   if(tipo == POSITION_TYPE_BUY)
     {
      if(!martingale)
        {
         if(inversao) //--Ativação da inversão de posição
           {
            if(stopfinaceiro==false)
              {
               if(horario_atual.hour <= horario_termino.hour)
                 {
                  if(horario_atual.hour < horario_termino.hour)
                    {
                     negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Venda -> Fechamento de posição ");
                     ObjectDelete(0, "Posição");
                     SymbolPendingOrdersCloseAll(SIMBOLO);                                                          // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Sell(NormalizeVolume(Volume), SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Compra -> Venda Inversão de mão");
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     if(PositionsTotal() > 0)
                       {
                        Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                        ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                        EntradaPreco=negocio.ResultPrice();
                       } // Linha de preço de entrada
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                     cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                     cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                     cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                     cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                     cont_breakeven = 0; // zeragem do contador loop breakeven
                     cont_trail = 1; // intertravamento trailling
                     SL_memory =0; // zeragem memória do último valor SL trailling
                    }
                  else
                     if(horario_atual.hour == horario_termino.hour && horario_atual.min <= horario_termino.min)
                       {
                        negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Venda -> Fechamento de posição");
                        ObjectDelete(0, "Posição");
                        SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                        negocio.Sell(NormalizeVolume(Volume), SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Compra -> Venda Inversão de mão");
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        if(PositionsTotal() > 0)
                          {
                           Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                           ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                           EntradaPreco=negocio.ResultPrice();
                          }
                        PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                        cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                        cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                        cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                        cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                        cont_breakeven = 0; // zeragem do contador loop breakeven
                        cont_trail = 1; // intertravamento trailling
                        SL_memory =0; // zeragem memória do último valor SL trailling
                       }
                 }

               if(horario_atual.hour >= horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
                 {
                  SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, "Fechamento de posição do dia");
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  ObjectDelete(0, "Posição");
                  PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
                  cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                  cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                  cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                  cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                  cont_breakeven = 0; // zeragem do contador loop breakeven
                  SL_memory =0; // zeragem memória do último valor SL trailling
                 }
              }
           }
         else
           {
            SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, "Fechamento de Posição");
            ObjectDelete(0, "Posição");
            negocio.PrintRequest();
            negocio.PrintResult();
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
            cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
            cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
            cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
            cont_breakeven = 0; // zeragem do contador loop breakeven
            SL_memory =0; // zeragem memória do último valor SL trailling
           }
        }
      else // Martingale ativado
        {
         if(inversao) //--Ativação da inversão de posição
           {
            if(stopfinaceiro==false)
              {
               if(horario_atual.hour <= horario_termino.hour)
                 {
                  if(horario_atual.hour < horario_termino.hour)
                    {
                     SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Venda fechamento martingale "); //--fechamento de posição
                     ObjectDelete(0, "Posição");
                     Martingale(); // --- verificação do modo Martingale
                     negocio.Sell(volumeatual, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Venda inversão martingale");
                     if(PositionsTotal() > 0)
                       {
                        Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                        ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                        EntradaPreco=negocio.ResultPrice();
                       }
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão martingale
                     cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                     cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                     cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                     cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                     cont_breakeven = 0; // zeragem do contador loop breakeven
                     cont_trail = 1; // intertravamento trailling
                     SL_memory =0; // zeragem memória do último valor SL trailling
                    }
                  else
                     if(horario_atual.hour == horario_termino.hour && horario_atual.min <= horario_termino.min)
                       {
                        SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                        negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Venda Fechamento Martingale "); //--fechamento de posição
                        ObjectDelete(0,"Posição");
                        Martingale(); // --- verificação do modo Martingale
                        negocio.Sell(volumeatual, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, " Venda inversão martingale");
                        if(PositionsTotal() > 0)
                          {
                           Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                           ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                           EntradaPreco=negocio.ResultPrice();
                          }
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        PlaySound("\\Sounds\\Register.wav"); //--Inversão martingaleo
                        cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                        cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                        cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                        cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                        cont_breakeven = 0; // zeragem do contador loop breakeven
                        cont_trail = 1; // intertravamento trailling
                        SL_memory =0; // zeragem memória do último valor SL trailling
                       }
                 }

               if(horario_atual.hour >= horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
                 {
                  SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, "Fechamento de posição do dia");
                  ObjectDelete(0,"Posição");
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
                  cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                  cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                  cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                  cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                  cont_breakeven = 0; // zeragem do contador loop breakeven
                  SL_memory =0; // zeragem memória do último valor SL trailling
                 }
              }
           }
         else
           {
            SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            negocio.Sell(volume_fechamento, SIMBOLO, price_normalized_sell, stoploss_sell, takeprofit_sell, "Fechamento de Posição");
            ObjectDelete(0, "Posição");
            negocio.PrintRequest();
            negocio.PrintResult();
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
            cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
            cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
            cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
            cont_breakeven = 0; // zeragem do contador loop breakeven
            SL_memory =0; // zeragem memória do último valor SL trailling
           }
        }
     }
// Comprar em caso de posição vendida
   else
     {
      if(!martingale)
        {
         if(inversao) //--Ativação da inversão de posição
           {
            if(stopfinaceiro==false)
              {
               if(horario_atual.hour <= horario_termino.hour)
                 {
                  if(horario_atual.hour < horario_termino.hour)
                    {
                     SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, " Compra ->Fechamento de posição");
                     ObjectDelete(0, "Posição");
                     negocio.Buy(NormalizeVolume(Volume), SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, " Compra Inversão de mão");
                     if(PositionsTotal() > 0)
                       {
                        Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                        ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                        EntradaPreco=negocio.ResultPrice();
                       }
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                     cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                     cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                     cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                     cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                     cont_breakeven = 0; // zeragem do contador loop breakeven
                     cont_trail = 1; // intertravamento trailling
                     SL_memory =0; // zeragem memória do último valor SL trailling;
                    }
                  else
                     if(horario_atual.hour == horario_termino.hour && horario_atual.min <= horario_termino.min)
                       {
                        negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, " Compra ->Fechamento de posição");
                        ObjectDelete(0, "Posição");
                        SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                        negocio.Buy(NormalizeVolume(Volume), SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, " Compra Inversão de mão");
                        if(PositionsTotal() > 0)
                          {
                           Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                           ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                           EntradaPreco=negocio.ResultPrice();
                          }
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição
                        cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                        cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                        cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                        cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                        cont_breakeven = 0; // zeragem do contador loop breakeven
                        cont_trail = 1; // intertravamento trailling
                        SL_memory =0; // zeragem memória do último valor SL trailling
                       }
                 }

               if(horario_atual.hour >= horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
                 {
                  negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, "Fechamento Posição do Dia");
                  ObjectDelete(0, "Posição");
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
                  cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                  cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                  cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                  cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                  cont_breakeven = 0; // zeragem do contador loop breakeven
                  SL_memory =0; // zeragem memória do último valor SL trailling
                 }
              }
           }
         else
           {
            negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, "Fechamento de Posição");
            ObjectDelete(0, "Posição");
            negocio.PrintRequest();
            negocio.PrintResult();
            SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
            cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
            cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
            cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
            cont_breakeven = 0; // zeragem do contador loop breakeven
            SL_memory =0; // zeragem memória do último valor SL trailling
           }
        }
      else // MARTINGALE
        {
         if(inversao) //--Ativação da inversão de posição
           {
            if(stopfinaceiro==false)
              {
               if(horario_atual.hour <= horario_termino.hour)
                 {
                  if(horario_atual.hour < horario_termino.hour)
                    {
                     negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, " Compra fechamento Martingale"); //--Fechamento de posição
                     ObjectDelete(0, "Posição");
                     SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     Martingale(); // --- verificação do modo Martingale
                     negocio.Buy(volumeatual, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, " Inversão Martingale");
                     if(PositionsTotal() > 0)
                       {
                        Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                        ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                        EntradaPreco=negocio.ResultPrice();
                       }
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                     PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição martigale
                     cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                     cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                     cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                     cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                     cont_breakeven = 0; // zeragem do contador loop breakeven
                     cont_trail = 1; // intertravamento trailling
                     SL_memory =0; // zeragem memória do último valor SL trailling
                    }
                  else
                     if(horario_atual.hour == horario_termino.hour && horario_atual.min <= horario_termino.min)
                       {
                        negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, "Compra fechamento Martingale"); //--Fechamento de posição
                        ObjectDelete(0, "Posição");
                        SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                        Martingale(); // --- verificação do modo Martingale
                        negocio.Buy(volumeatual, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, "Compra Inversão Martingale");
                        if(PositionsTotal() > 0)
                          {
                           Linha_Horizontal("Posição", negocio.ResultPrice(),2, clrAqua, STYLE_SOLID);
                           ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
                           EntradaPreco=negocio.ResultPrice();
                          }
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        PlaySound("\\Sounds\\Register.wav"); //--Inversão de posição martigale
                        cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                        cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                        cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                        cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                        cont_breakeven = 0; // zeragem do contador loop breakeven
                        cont_trail = 1; // intertravamento trailling
                        SL_memory =0; // zeragem memória do último valor SL trailling
                       }
                 }
               if(horario_atual.hour >= horario_fechamento.hour && horario_atual.min > horario_fechamento.min)
                 {
                  negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, "Fechamento Posição do Dia");
                  ObjectDelete(0, "Posição");
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
                  PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
                  cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
                  cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
                  cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
                  cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
                  cont_breakeven = 0; // zeragem do contador loop breakeven
                  SL_memory =0; // zeragem memória do último valor SL trailling
                 }
              }
           }
         else
           {
            negocio.Buy(volume_fechamento, SIMBOLO, price_normalized_buy, stoploss_buy, takeprofit_buy, "Fechamento de Posição");
            ObjectDelete(0, "Posição");
            negocio.PrintRequest();
            negocio.PrintResult();
            SymbolPendingOrdersCloseAll(SIMBOLO); // Utiliza a Biblioteca SymbolTradeMadeSimple para fechar todas as ordens pendentes
            PlaySound("\\Sounds\\Register.wav"); //---Fechamento de posição do dia
            cont_e_parcial =0;              // zeragem do contador do loop de entradas parciais
            cont_e_parcialc=0;              // zeragem do contador do loop de entradas  parciais
            cont_parcial =0;              // zeragem do contador do loop  saídas de parciais
            cont_parcialc =0;              // zeragem do contador do loop  saídas de parciais
            cont_breakeven = 0; // zeragem do contador loop breakeven
            SL_memory =0; // zeragem memória do último valor SL trailling
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Função Saídas Parciais                                           |
//+------------------------------------------------------------------+
void Parcial()
  {
   MqlDateTime  inicio_dia;
   datetime hora_atual = TimeCurrent(inicio_dia);
   inicio_dia.hour = 0;
   inicio_dia.min = 0;
   inicio_dia.sec = 0;
   double result = 0;
   ulong ticket1;

   if(!HistorySelect(StructToTime(inicio_dia), hora_atual))
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

// -- Parcial contrária ao movimento

   if(iParcial_distancia_c > 0 && PositionSelect(SIMBOLO) && cont_parcialc < 1)
     {
      if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY && EntradaPreco-PosicaoInfo.PriceCurrent() >= Partial_c)
        {
         negocio.Sell(NormalizeVolume(iParcial_volume_c),SIMBOLO,0,0,0, "1ª Saída Sell Contra");
         ObjectDelete(0, "Parcialc");
         cont_parcialc++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && PosicaoInfo.PriceCurrent()-EntradaPreco >= Partial_c)
        {
         negocio.Buy(NormalizeVolume(iParcial_volume_c),SIMBOLO,0,0,0, "1ª Saída Buy Contra");
         ObjectDelete(0, "Parcialc");
         cont_parcialc++;
        }
     }

   if(iParcial_distancia2_c > 0 && PositionSelect(SIMBOLO) && Partial2_c > Partial_c && cont_parcialc < 2)
     {
      if((PosicaoInfo.PositionType() == POSITION_TYPE_BUY) && (EntradaPreco-PosicaoInfo.PriceCurrent()>= Partial2_c) && cont_parcialc == 1)
        {
         negocio.Sell(NormalizeVolume(iParcial_volume2_c),SIMBOLO,0,0,0, "2ª Saída Sell Contra");
         ObjectDelete(0, "Parcial2c");
         cont_parcialc++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && (PosicaoInfo.PriceCurrent()-EntradaPreco>= Partial2_c) && cont_parcialc == 1)
        {
         negocio.Buy(NormalizeVolume(iParcial_volume2_c),SIMBOLO,0,0,0, "2ª Saída Buy Contra");
         ObjectDelete(0, "Parcial2c");
         cont_parcialc++;
        }
     }
//---- Parcial a favor do Movimento
   if(iParcial_distancia > 0 && PositionSelect(SIMBOLO) && cont_parcial < 1)
     {
      if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY && PosicaoInfo.PriceCurrent() - EntradaPreco >= Partial)
        {
         negocio.Sell(NormalizeVolume(iParcail_volume),SIMBOLO,0,0,0, "1ª Saída Sell à Favor");
         ObjectDelete(0, "Parcial");
         cont_parcial++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && EntradaPreco - PosicaoInfo.PriceCurrent() >= Partial)
        {
         negocio.Buy(NormalizeVolume(iParcail_volume),SIMBOLO,0,0,0, "1ª Saída Buy à Favor");
         ObjectDelete(0, "Parcial");
         cont_parcial++;
        }
     }

   if(iParcial_distancia2 > 0 && PositionSelect(SIMBOLO) && Partial2 > Partial && cont_parcial < 2)
     {
      if((PosicaoInfo.PositionType() == POSITION_TYPE_BUY) && (PosicaoInfo.PriceCurrent() - EntradaPreco == Partial2) && cont_parcial == 1)
        {
         negocio.Sell(NormalizeVolume(iParcial_volume2),SIMBOLO,0,0,0, "2ª Saída Sell à Favor");
         ObjectDelete(0, "Parcial2");
         cont_parcial++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && (EntradaPreco - PosicaoInfo.PriceCurrent() == Partial2) && cont_parcial == 1)
        {
         negocio.Buy(NormalizeVolume(iParcial_volume2),SIMBOLO,0,0,0, "2ª Saída Buy à Favor");
         ObjectDelete(0, "Parcial2");
         cont_parcial++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Função Entradas Parciais                                         |
//+------------------------------------------------------------------+
void EntradaParcial()
  {
   MqlDateTime  inicio_dia;
   datetime hora_atual = TimeCurrent(inicio_dia);
   inicio_dia.hour = 0;
   inicio_dia.min = 0;
   inicio_dia.sec = 0;
   double result = 0;
   ulong ticket1;

   if(!HistorySelect(StructToTime(inicio_dia), hora_atual))
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

// -- Entra Parcial contrária ao movimento

   if(iEParcial_distancia_c > 0 && PositionSelect(SIMBOLO) && cont_e_parcialc < 1)
     {
      if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY && EntradaPreco-PosicaoInfo.PriceCurrent() >= EParcial_c)
        {
         negocio.Buy(NormalizeVolume(iEParcial_volume_c),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "1ªEntrada Buy Contra");
         ObjectDelete(0, "EParcialc");
         cont_e_parcialc++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && PosicaoInfo.PriceCurrent()-EntradaPreco >= EParcial_c)
        {
         negocio.Sell(NormalizeVolume(iEParcial_volume_c),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "1ªEntrada Sell Contra");
         ObjectDelete(0, "EParcialc");
         cont_e_parcialc++;
        }
     }

   if(iEParcial_distancia2_c > 0 && PositionSelect(SIMBOLO) && EParcial2_c > EParcial_c && cont_e_parcialc < 2)
     {
      if((PosicaoInfo.PositionType() == POSITION_TYPE_BUY) && (EntradaPreco-PosicaoInfo.PriceCurrent()>= EParcial2_c) && cont_e_parcialc == 1)
        {
         negocio.Buy(NormalizeVolume(iEParcial_volume2_c),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "2ª Entrada Buy Contra");
         ObjectDelete(0, "EParcial2c");
         cont_e_parcialc++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && (PosicaoInfo.PriceCurrent()-EntradaPreco>= EParcial2_c) && cont_e_parcialc == 1)
        {
         negocio.Sell(NormalizeVolume(iEParcial_volume2_c),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "2ª Entrada Sell Contra");
         ObjectDelete(0, "EParcial2c");
         cont_e_parcialc++;
        }
     }
//---- Entrada Parcial a favor do Movimento
   if(iEParcial_distancia > 0 && PositionSelect(SIMBOLO) && cont_e_parcial < 1)
     {
      if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY && PosicaoInfo.PriceCurrent() - EntradaPreco >= EParcial)
        {
         negocio.Buy(NormalizeVolume(iEParcail_volume),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "1ª Entrada Buy à Favor");
         ObjectDelete(0, "EParcial");
         cont_e_parcial++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && EntradaPreco - PosicaoInfo.PriceCurrent() >= EParcial)
        {
         negocio.Sell(NormalizeVolume(iEParcail_volume),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "1ª Entrada Sell à Favor");
         ObjectDelete(0, "EParcial");
         cont_e_parcial++;
        }
     }

   if(iEParcial_distancia2 > 0 && PositionSelect(SIMBOLO) && EParcial2 > EParcial && cont_e_parcial < 2)
     {
      if((PosicaoInfo.PositionType() == POSITION_TYPE_BUY) && (PosicaoInfo.PriceCurrent() - EntradaPreco == EParcial2) && cont_e_parcial == 1)
        {
         negocio.Buy(NormalizeVolume(iEParcial_volume2),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "2ª Entrada Buy à Favor");
         ObjectDelete(0, "EParcial2");
         cont_e_parcial++;
        }

      if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && (EntradaPreco - PosicaoInfo.PriceCurrent() == EParcial2) && cont_e_parcial == 1)
        {
         negocio.Sell(NormalizeVolume(iEParcial_volume2),SIMBOLO,0,PosicaoInfo.StopLoss(),PosicaoInfo.TakeProfit(), "2ª Entrada Sell à Favor");
         ObjectDelete(0, "EParcial2");
         cont_e_parcial++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Verificar se há ordem aberta no ativo de escolha                 |
//+------------------------------------------------------------------+
bool SemOrdem()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == string(SIMBOLO))
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool SemPosicao()
  {
   return (!PositionSelect(SIMBOLO));
  }
//+------------------------------------------------------------------+
//|FUNÇÂO QUE FECHA Todas As POSIÇÕES                                |
//+------------------------------------------------------------------+
void Close_All_Positions(ulong magig, string _symbol)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PosicaoInfo.SelectByIndex(i))
         if((PosicaoInfo.Magic() == magig) && (PosicaoInfo.Symbol() == _symbol))
            negocio.PositionClose(PosicaoInfo.Ticket());
     }
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
//| Função para Trailing Stop                                        |
//+------------------------------------------------------------------+
void TRAILING_STOP()
  {

   datetime lastbar_time = (datetime)SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);
   static ulong ticket_trail;

   if(!PositionSelect(SIMBOLO) || cont_trail == 1)
     {
      cont = 0;
      traillbuy = 0;
      traillsell = 0;
      cont_trail = 0;

     }
   if(iTrailing_Start > 0 && iBreak_Even_Start == 0)
     {
      for(int i = 0 ; i < PositionsTotal() ; i++)
        {
         if(PosicaoInfo.SelectByIndex(i))
           {
            cont++;
            if(cont == 1) // recebe o primeiro preço
              {
               traillbuy = EntradaPreco + NormalizePrice(Trailing_Start,SIMBOLO,tick_size_ativo);
               traillsell = EntradaPreco - NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo);
               if(TStop !=1 && TStop!=2 && TStop!=5) // Condução por indicadores
                 {
                  traillbuy = 0;
                  traillsell = 0;
                 }
              }

            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PosicaoInfo.PriceCurrent() >= traillbuy && PositionGetInteger(POSITION_MAGIC) == magicNumber)
              {
               ticket_trail = PosicaoInfo.Ticket();
               if(TStop == 1) // Condução por STEP
                  traillbuy = traillbuy + NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo);

               if(TStop == 2) // Condução por Alvo
                  traillbuy = traillbuy + NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo);

               // Condução por Pontos
               if(TStop == 1 || TStop == 2)
                 {
                  if(PosicaoInfo.StopLoss() + NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)!= SL_memory)
                    {
                     negocio.PositionModify(ticket_trail, (PosicaoInfo.StopLoss() + NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)), PosicaoInfo.TakeProfit());
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     SL_memory=negocio.RequestSL();
                    }
                 }
               if(TStop == 3) // Condução por SAR
                 {
                  if(Step_SAR() >= PosicaoInfo.StopLoss() && Step_SAR() <= PosicaoInfo.PriceCurrent())
                    {
                     if(SL_memory != Step_SAR()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                       {
                        negocio.PositionModify(ticket_trail, Step_SAR(), PosicaoInfo.TakeProfit());
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        SL_memory=negocio.RequestSL();
                       }
                    }
                 }

               if(TStop == 4) // Condução por STOP ATR
                 {
                  if(Step_ATRupper() >= PosicaoInfo.StopLoss() && Step_ATRupper() <= PosicaoInfo.PriceCurrent())
                    {
                     if(SL_memory != Step_ATRupper()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                       {
                        negocio.PositionModify(ticket_trail, Step_ATRupper(), PosicaoInfo.TakeProfit());
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        SL_memory=negocio.RequestSL();
                       }
                    }
                 }

               if(TStop == 5) // Condução por MA
                 {
                  if(PosicaoInfo.PriceCurrent() >= traillbuy)
                    {
                     traillbuy = 0;

                     if(Step_MovingAverage() >= PosicaoInfo.StopLoss() && Step_MovingAverage() < PosicaoInfo.PriceCurrent())
                       {
                        if(SL_memory != Step_MovingAverage()&& Step_MovingAverage()>= SL_memory) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                          {
                           negocio.PositionModify(ticket_trail, Step_MovingAverage(), PosicaoInfo.TakeProfit());
                           negocio.PrintRequest();
                           negocio.PrintResult();
                           SL_memory=negocio.RequestSL();
                          }
                       }
                    }
                 }

               ObjectDelete(0, "Trailling");
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PosicaoInfo.Magic() == magicNumber)
              {
               ticket_trail = PosicaoInfo.Ticket();
               if(PosicaoInfo.PriceCurrent() <= traillsell)
                 {
                  if(TStop == 1)
                     traillsell = traillsell - NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo);

                  if(TStop == 2)
                     traillsell = traillsell - NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo);

                  // Condução por Pontos
                  if(TStop == 1 || TStop == 2)
                    {
                     if(SL_memory!= (PosicaoInfo.StopLoss() - NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)))
                       {
                        negocio.PositionModify(ticket_trail, (PosicaoInfo.StopLoss() - NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)), PosicaoInfo.TakeProfit());
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        SL_memory=negocio.RequestSL();
                       }
                    }

                  ObjectDelete(0, "Trailling");
                 }
               if(TStop == 3 && Step_SAR() <= PosicaoInfo.StopLoss() && Step_SAR() >= PosicaoInfo.PriceCurrent()) // Condução por SAR
                 {
                  if(SL_memory != Step_SAR()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                    {
                     negocio.PositionModify(ticket_trail, Step_SAR(), PosicaoInfo.TakeProfit());
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     SL_memory=negocio.RequestSL();
                    }
                 }
               if(TStop == 4 && Step_ATRlower() <= PosicaoInfo.StopLoss() && Step_ATRlower() >= PosicaoInfo.PriceCurrent()) // Condução por STOP ATR
                 {
                  if(SL_memory != Step_ATRlower()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                    {
                     negocio.PositionModify(ticket_trail, Step_ATRlower(), PosicaoInfo.TakeProfit());
                     negocio.PrintRequest();
                     negocio.PrintResult();
                     SL_memory=negocio.RequestSL();
                    }
                 }

               if(TStop == 5 && Step_MovingAverage() <= PosicaoInfo.StopLoss() && Step_MovingAverage() >= PosicaoInfo.PriceCurrent()) // Condução por MA
                 {
                  if(PosicaoInfo.PriceCurrent() <= traillsell)
                    {

                     traillsell=PosicaoInfo.PriceCurrent()+1000;
                     if(SL_memory != Step_MovingAverage()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                       {
                        negocio.PositionModify(ticket_trail, Step_MovingAverage(), PosicaoInfo.TakeProfit());
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        SL_memory=negocio.RequestSL();

                       }
                    }
                 }
               ObjectDelete(0, "Trailling");
              }
           }
        }
     }

   if(iTrailing_Start > 0 && iBreak_Even_Start > 0)
     {
      for(int i = 0 ; i < PositionsTotal() ; i++)
        {
         if(PosicaoInfo.SelectByIndex(i))
           {
              {
               cont++;
               if(cont == 1)
                 {
                  traillbuy = EntradaPreco + NormalizePrice(Trailing_Start, SIMBOLO,tick_size_ativo);
                  traillsell = EntradaPreco - NormalizePrice(Trailing_Start, SIMBOLO,tick_size_ativo);
                  if(TStop !=1 && TStop !=2 && TStop!=5)  // Condução por indicadores
                    {
                     traillbuy = 0;
                     traillsell = 0;
                    }
                 }
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&  PosicaoInfo.Magic() == magicNumber)
                 {
                  ticket_trail = PosicaoInfo.Ticket();
                  if(PosicaoInfo.PriceCurrent() >= NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo))
                     if(PosicaoInfo.PriceCurrent() >= traillbuy)
                       {
                        if(TStop == 1 || TStop == 2)
                          {
                           if(SL_memory != (PosicaoInfo.StopLoss() + NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)))
                             {
                              negocio.PositionModify(ticket_trail, (PosicaoInfo.StopLoss() + NormalizePrice(Trailing_Step, SIMBOLO,tick_size_ativo)), PosicaoInfo.TakeProfit());
                              negocio.PrintRequest();
                              negocio.PrintResult();
                              SL_memory=negocio.RequestSL();
                             }
                          }

                        if(TStop == 3) // Condução por SAR
                           if(Step_SAR() >= PosicaoInfo.StopLoss() && Step_SAR() <= PosicaoInfo.PriceCurrent())
                              if(SL_memory != Step_SAR())
                                {
                                 negocio.PositionModify(ticket_trail, Step_SAR(), PosicaoInfo.TakeProfit());
                                 negocio.PrintRequest();
                                 negocio.PrintResult();
                                 SL_memory=negocio.RequestSL();
                                }

                        if(TStop == 4) // Condução por STOP ATR
                          {
                           if(Step_ATRupper() >= PosicaoInfo.StopLoss() && Step_ATRupper() <= PosicaoInfo.PriceCurrent())
                             {
                              if(SL_memory != Step_ATRupper()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                                {
                                 negocio.PositionModify(ticket_trail, Step_ATRupper(), PosicaoInfo.TakeProfit());
                                 negocio.PrintRequest();
                                 negocio.PrintResult();
                                 SL_memory=negocio.RequestSL();
                                }
                             }
                          }

                        if(TStop == 5) // Condução por Moving Average
                          {
                           if(PosicaoInfo.PriceCurrent() >= traillbuy)
                             {
                              traillbuy = 0;
                              if(Step_MovingAverage() >= PosicaoInfo.StopLoss() && Step_MovingAverage() <= PosicaoInfo.PriceCurrent())
                                {
                                 if(SL_memory != Step_MovingAverage()&& Step_MovingAverage()>= SL_memory) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                                   {
                                    negocio.PositionModify(ticket_trail, Step_MovingAverage(), PosicaoInfo.TakeProfit());
                                    negocio.PrintRequest();
                                    negocio.PrintResult();
                                    SL_memory=negocio.RequestSL();
                                   }
                                }
                             }
                          }

                        ObjectDelete(0, "Trailling");

                        if(TStop == 1)
                           traillbuy = traillbuy + NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo);

                        if(TStop == 2)
                           traillbuy = traillbuy + NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo);
                       }
                 }
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&  PosicaoInfo.Magic() == magicNumber)
                 {
                  ticket_trail = PosicaoInfo.Ticket();
                  if(PosicaoInfo.PriceCurrent() >= NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo))
                     if(PosicaoInfo.PriceCurrent() <= traillsell)
                        if(SL_memory != (PosicaoInfo.StopLoss() - NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)) && (TStop==1 || TStop==2))
                          {
                           negocio.PositionModify(ticket_trail, (PosicaoInfo.StopLoss() - NormalizePrice(Trailing_Step,SIMBOLO, tick_size_ativo)), PosicaoInfo.TakeProfit());
                           SL_memory=negocio.RequestSL();
                           negocio.PrintRequest();
                           negocio.PrintResult();
                           if(TStop == 1)
                              traillsell = traillsell - NormalizePrice(Trailing_Step, SIMBOLO,tick_size_ativo);

                           if(TStop == 2)
                              traillsell = traillsell + NormalizePrice(Trailing_Start,SIMBOLO, tick_size_ativo);

                           ObjectDelete(0, "Trailling");
                          }

                  if(TStop == 3 && Step_SAR()<= PosicaoInfo.StopLoss() && Step_SAR()>= PosicaoInfo.PriceCurrent()) // Condução por SAR
                    {
                     if(SL_memory != Step_SAR())
                       {
                        negocio.PositionModify(ticket_trail, Step_SAR(), PosicaoInfo.TakeProfit());
                        SL_memory=negocio.RequestSL();
                        negocio.PrintRequest();
                        negocio.PrintResult();
                       }
                    }
                  if(TStop == 4 && Step_ATRlower() <= PosicaoInfo.StopLoss() && Step_ATRlower() >= PosicaoInfo.PriceCurrent()) // Condução por STOP ATR
                    {
                     if(SL_memory != Step_ATRlower()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                       {
                        negocio.PositionModify(ticket_trail, Step_ATRlower(), PosicaoInfo.TakeProfit());
                        negocio.PrintRequest();
                        negocio.PrintResult();
                        SL_memory=negocio.RequestSL();
                       }
                    }

                  if(TStop == 5 && Step_MovingAverage() <= PosicaoInfo.StopLoss() && Step_MovingAverage() >= PosicaoInfo.PriceCurrent()) // Condução por STOP ATR
                    {
                     if(PosicaoInfo.PriceCurrent() <= traillsell)
                       {

                        traillsell=PosicaoInfo.PriceCurrent()+1000;

                        if(SL_memory != Step_MovingAverage()) // verifica se o SL é o mesmo anterior e evita o envio de ordem
                          {
                           negocio.PositionModify(ticket_trail, Step_MovingAverage(), PosicaoInfo.TakeProfit());
                           negocio.PrintRequest();
                           negocio.PrintResult();
                           SL_memory=negocio.RequestSL();
                          }
                       }
                    }
                  ObjectDelete(0, "Trailling");
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
   if(iBreak_Even_Start > 0.0)
     {
      for(int i = 0 ; i < PositionsTotal() ; i++)
        {
         if(PosicaoInfo.SelectByIndex(i))
           {
            long postion = PositionGetInteger(POSITION_TYPE);
            if(postion == POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC) == magicNumber)
              {
               ulong ticket = PosicaoInfo.Ticket();
               double Diferenca = PosicaoInfo.PriceCurrent() - EntradaPreco;
               double breakeven = EntradaPreco + NormalizePrice(Break_Even_Start,SIMBOLO, tick_size_ativo);
               if(Diferenca >= NormalizePrice(Break_Even_Start,SIMBOLO, tick_size_ativo) && PosicaoInfo.StopLoss() <= EntradaPreco && cont_breakeven == 0)
                 {
                  negocio.PositionModify(PosicaoInfo.Ticket(), EntradaPreco + NormalizePrice(Break_Even_Step,SIMBOLO, tick_size_ativo), PosicaoInfo.TakeProfit());
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  ObjectDelete(0, "Breakeven"); // apagar a linha de break Even após atingir o mesmo;
                  cont_breakeven++;
                 }
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PosicaoInfo.Magic() == magicNumber)
              {
               ulong ticket = PosicaoInfo.Ticket();
               double Diferenca = EntradaPreco - PosicaoInfo.PriceCurrent();
               if(Diferenca >= NormalizePrice(Break_Even_Start,SIMBOLO, tick_size_ativo) && PosicaoInfo.StopLoss() >= EntradaPreco && cont_breakeven == 0)
                 {
                  negocio.PositionModify(PosicaoInfo.Ticket(), EntradaPreco - NormalizePrice(Break_Even_Step,SIMBOLO,tick_size_ativo), PosicaoInfo.TakeProfit());
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  ObjectDelete(0, "Breakeven"); // apagar a linha de break Even após atingir o mesmo;
                  cont_breakeven++;
                 }
               if(Diferenca >=  NormalizePrice(Break_Even_Start,SIMBOLO, tick_size_ativo) && PosicaoInfo.StopLoss() == 0 && cont_breakeven == 0) // Necessidade desta comparação quando o SL não for definido pelo usuário
                 {
                  negocio.PositionModify(PosicaoInfo.Ticket(), EntradaPreco - NormalizePrice(Break_Even_Step,SIMBOLO, tick_size_ativo), PosicaoInfo.TakeProfit());
                  negocio.PrintRequest();
                  negocio.PrintResult();
                  ObjectDelete(0, "Breakeven"); // apagar a linha de break Even após atingir o mesmo;
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
   int contador_trades = 0, contadortradespositivos=0;
   int contador_ordens = 0, contadortradesnegativos=0;
   double resultado;
   ulong ticket1 = 0;
   double fator_lucro;
   double resultado_liquido;
   ulong  ticket_comentario_antigo =0;

//Obtenção do Histórico
   MqlDateTime inicio_struct;
   fim = TimeCurrent(inicio_struct);
   inicio_struct.hour = 0;
   inicio_struct.min = 0;
   inicio_struct.sec = 0;
   inicio_ = StructToTime(inicio_struct);

   HistorySelect(inicio_, fim);
   
   

//Cálculos
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ticket1 = HistoryDealGetTicket(i);
      long Entry  = HistoryDealGetInteger(ticket1, DEAL_ENTRY);

      if(ticket1 > 0)
         if(HistoryDealGetString(ticket1, DEAL_SYMBOL) == string(SIMBOLO) && HistoryDealGetInteger(ticket1, DEAL_MAGIC) == magicNumber)
           {
            contador_ordens++;
            resultado = HistoryDealGetDouble(ticket1, DEAL_PROFIT);

            if(resultado < 0)
              {
               perda += -resultado;
               contadortradesnegativos++;
              }
            if(resultado > 0)
              {
               lucro += resultado;
               contadortradespositivos++;
              }
            if(inversao == false)
               if(Entry == DEAL_ENTRY_OUT) // ----- Se inversão de mão se não estiver ativa o contador irá receber  somente os resultados das saídas dos trades e não das inversões
                  contador_trades++;

            if(inversao == true)
               if(Entry == DEAL_ENTRY_OUT || Entry == DEAL_ENTRY_INOUT) // ----- Se inversão de mão estiver ativa o contador irá receber os resultados das saídas dos trades e das inversões
                  contador_trades++;
           }
     }

   if(perda > 0)
      fator_lucro = lucro / perda;
   else
      fator_lucro = -1;

   resultado_liquido = lucro - perda;

//---- Transferindo resultado para variáveis globais a fim de alimentar o painel de resumo na função ONTICK
   tradesnegativos=contadortradesnegativos;
   tradespositivos=contadortradespositivos;
   lucro_painel = lucro;
   perda_painel = perda;
   contador_trades_painel = contador_trades;
   contador_ordens_painel = contador_ordens;
   ticket_painel = ticket1;
   fator_lucro_painel = fator_lucro;
   resultado_liquido_painel = resultado_liquido;

   if(paycheck.day != inicio_struct.day)

     {
      stopfinaceiro=false;

      if(lucro >= iLucromax && iLucromax > 0) // verficiação de lucro máxima nas operações e remoção do EA
        {
         negocio.PositionClose(SIMBOLO);
         ObjectDelete(0, "Posição");
         ObjectDelete(0, "Trailling");
         ObjectDelete(0, "Breakeven");
         ObjectDelete(0, "StopLoss");
         ObjectDelete(0, "TakeProfit"); // utilização da função para fechar todas as posições do gráfico
         MessageBox(" Atenção atingido o LUCRO máximo em operações determinado, Negociação desativada", NULL, MB_OK);
         PlaySound("\\Sounds\\mission-complete");
         stopfinaceiro=true;
         TimeCurrent(paycheck);

        }


      if(perda >= iPerdamax && iPerdamax > 0)  // verficiação de perca maxima nas operações ou lucro máximo do dia e remoção do EA
        {
         negocio.PositionClose(SIMBOLO);
         ObjectDelete(0, "Posição");
         ObjectDelete(0, "Trailling");
         ObjectDelete(0, "Breakeven");
         ObjectDelete(0, "StopLoss");
         ObjectDelete(0, "TakeProfit");// utilização da função para fechar todas as posições do gráfico
         MessageBox(" Atenção atingido o PREJUÍZO máximo em operaçõeso determinado. Negociação desativada", NULL, MB_OK);
         PlaySound("\\Sounds\\alert-1");
         stopfinaceiro=true;
         TimeCurrent(paycheck);

        }


      if(resultado_liquido <= iLossmax * -1 && iLossmax > 0)   // verficiação de perca maxima do dia máximo do dia e remoção do EA
        {
         negocio.PositionClose(SIMBOLO);
         ObjectDelete(0, "Posição");
         ObjectDelete(0, "Trailling");
         ObjectDelete(0, "Breakeven");
         ObjectDelete(0, "StopLoss");
         ObjectDelete(0, "TakeProfit");// utilização da função para fechar todas as posições do gráfico
         MessageBox(" Atenção atingido o PREJUÍZO máximo diário determinado, Negociação desativada", NULL, MB_OK);
         PlaySound("\\Sounds\\alert-1");
         stopfinaceiro=true;
         TimeCurrent(paycheck);

        }


      if(resultado_liquido >= iGanhomax && iGanhomax > 0)  // verficiação de perca maxima nas operações ou lucro máximo do dia e remoção do EA
        {
         negocio.PositionClose(SIMBOLO);

         ObjectDelete(0, "Posição");
         ObjectDelete(0, "Trailling");
         ObjectDelete(0, "Breakeven");
         ObjectDelete(0, "StopLoss");
         ObjectDelete(0, "TakeProfit");// utilização da função para fechar todas as posições do gráfico
         MessageBox(" Atenção atingido o LUCRO máximo do dia determinado, Negociação desativada", NULL, MB_OK);
         PlaySound("\\Sounds\\mission-complete");
         stopfinaceiro=true;
         TimeCurrent(paycheck);

        }

     }

  }



//+------------------------------------------------------------------+
//| Função para verificação de último SL e TP                        |
//+------------------------------------------------------------------+
/////----------------------------
void VerificaSLTP()

  {
   MqlDateTime  inicio_dia;
   datetime hora_atual = TimeCurrent(inicio_dia);
   inicio_dia.hour = 0;
   inicio_dia.min = 0;
   inicio_dia.sec = 0;
   string verifcacao;
   ulong DealNumero=0;
   int comentario_atual;
   bool VerifSL= false, VerifTP=false;

   HistorySelect(StructToTime(inicio_dia), hora_atual);

   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      DealNumero = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket

      if(HistoryDealGetString(DealNumero, DEAL_SYMBOL) == string(_Symbol))
        {
         if((HistoryDealGetInteger(DealNumero,DEAL_ENTRY)==DEAL_ENTRY_OUT))
           {
            comentario_atual  = HistoryDealGetInteger(DealNumero,DEAL_REASON);
            if(comentario_atual == 4)
              {
               VerifSL = true;
               break;
              }
           }
        }
     }
   if(VerifSL)
     {
      if(DealNumero!=ticket_comentario_SL_antigo)
        {
         ticket_comentario_SL_antigo=DealNumero;
         Print(EnumToString((ENUM_DEAL_REASON)comentario_atual)," ",ticket_comentario_SL_antigo);
         PlaySound("\\Sounds\\disconnect.wav");
        }
     }

   for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     {
      DealNumero = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket
      if(HistoryDealGetString(DealNumero, DEAL_SYMBOL) == string(_Symbol))
        {
         if((HistoryDealGetInteger(DealNumero,DEAL_ENTRY)==DEAL_ENTRY_OUT))
           {
            comentario_atual  = HistoryDealGetInteger(DealNumero,DEAL_REASON);
            if(comentario_atual == 5)
              {
               VerifTP= true;
               break;
              }
           }
        }
     }
   if(VerifTP)
     {
      if(DealNumero!=ticket_comentario_TP_antigo)
        {
         ticket_comentario_TP_antigo=DealNumero;
         Print(EnumToString((ENUM_DEAL_REASON)comentario_atual)," ",ticket_comentario_SL_antigo);
         PlaySound("\\connect\\disconnect.wav");
        }
     }
  }

//+------------------------------------------------------------------+
//|  "FUNÇÕES PARA AUXILIAR NA VISUALIZAÇÃO DOS TP E SL"             |
//+------------------------------------------------------------------+
void Linha_Horizontal(string nome, double Price, int largura, color cor = clrBlue, ENUM_LINE_STYLE style = STYLE_SOLID)
  {
   static datetime last_time = 0;
   datetime lastbar_time = (datetime)SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);

   ObjectCreate(0, nome, OBJ_HLINE, 0, lastbar_time, Price, 0);

   ObjectSetInteger(0, nome, OBJPROP_WIDTH, largura);
   ObjectSetInteger(0, nome, OBJPROP_STYLE, style);
   ObjectSetInteger(0, nome, OBJPROP_COLOR, cor);
   ObjectSetInteger(0, nome, OBJPROP_SELECTED,true);
   ObjectGetInteger(0, nome,OBJPROP_BACK,true);
   ObjectSetInteger(0, nome, OBJPROP_ZORDER, 0);
   ObjectGetInteger(0,nome,OBJPROP_HIDDEN,false);

  }


//+------------------------------------------------------------------+
//|  Função Para enviar objetos fundo do gráfico                     |
//+------------------------------------------------------------------+
void ObjectsArrowToBack()
  {
   static int totalLast = 0;
   string objeto;
   int total = ObjectsTotal(0);
   if(total == totalLast)
      return;
   totalLast = total;
   for(int i = total - 1; i >= 0; i--)
     {
      objeto = ObjectName(0, i,-1,-1);
      if(StringFind(objeto,"#") >= 0)
        {ObjectSetInteger(0, ObjectName(0, i,-1,-1), OBJPROP_BACK, true);}
     }
  }
//+------------------------------------------------------------------+
//|  Função Para Ogranizar Drawings                                  |
//+------------------------------------------------------------------+
void Drawings()
  {
   ObjectDelete(0, "Breakeven");
   ObjectDelete(0, "Parcial");
   ObjectDelete(0, "Parcial2");
   ObjectDelete(0, "Parcialc");
   ObjectDelete(0, "Parcial2c");
   ObjectDelete(0, "EParcial");
   ObjectDelete(0, "EParcial2");
   ObjectDelete(0, "EParcialc");
   ObjectDelete(0, "EParcial2c");
   ObjectDelete(0,"Posição");

   if(PositionsTotal() > 0)
     {

      if(iEParcial_distancia > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_e_parcial < 1)
         Linha_Horizontal("EParcial", EntradaPreco + EParcial, 1, clrOrange, STYLE_DASHDOT);    // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcial",OBJPROP_BACK,true);                                               // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iEParcial_distancia > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_e_parcial< 1)
         Linha_Horizontal("EParcial", EntradaPreco - EParcial, 1, clrOrange, STYLE_DASHDOT);    // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcial",OBJPROP_BACK,true);                                              // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iEParcial_distancia2 > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_e_parcial <= 1)
         Linha_Horizontal("EParcial2", EntradaPreco + EParcial2, 1, clrOrange, STYLE_DASHDOT);  // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcial2",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iEParcial_distancia2 > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_e_parcial <= 1)
         Linha_Horizontal("EParcial2", EntradaPreco - EParcial2, 1, clrOrange, STYLE_DASHDOT);  // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcial2",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico


      if(iEParcial_distancia_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_e_parcialc < 1)
         Linha_Horizontal("EParcialc", EntradaPreco - EParcial_c, 1, clrOrange, STYLE_DASHDOT);    // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcialc",OBJPROP_BACK,true);                                               // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iEParcial_distancia_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_e_parcialc < 1)
         Linha_Horizontal("EParcialc", EntradaPreco + EParcial_c, 1, clrOrange, STYLE_DASHDOT);    // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcialc",OBJPROP_BACK,true);                                              // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iEParcial_distancia2_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_e_parcialc <= 1)
         Linha_Horizontal("EParcial2c", EntradaPreco - EParcial2_c, 1, clrOrange, STYLE_DASHDOT);  // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcial2c",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iEParcial_distancia2_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_e_parcialc <= 1)
         Linha_Horizontal("EParcial2c", EntradaPreco + EParcial2_c, 1, clrOrange, STYLE_DASHDOT);  // criação da linha de entrada parcial
      ObjectSetInteger(0,"EParcial2c",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico

      if(iParcial_distancia > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_parcial < 1)
         Linha_Horizontal("Parcial", EntradaPreco + Partial, 1, clrBrown, STYLE_DASHDOT);    // criação da linha de parcial
      ObjectSetInteger(0,"Parcial",OBJPROP_BACK,true);                                               // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iParcial_distancia > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_parcial < 1)
         Linha_Horizontal("Parcial", EntradaPreco - Partial, 1, clrBrown, STYLE_DASHDOT);    // criação da linha de parcial
      ObjectSetInteger(0,"Parcial",OBJPROP_BACK,true);                                              // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iParcial_distancia2 > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_parcial <= 1)
         Linha_Horizontal("Parcial2", EntradaPreco + Partial2, 1, clrBrown, STYLE_DASHDOT);  // criação da linha de parcial
      ObjectSetInteger(0,"Parcial2",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iParcial_distancia2 > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_parcial <= 1)
         Linha_Horizontal("Parcial2", EntradaPreco - Partial2, 1, clrBrown, STYLE_DASHDOT);  // criação da linha de parcial
      ObjectSetInteger(0,"Parcial2",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico

      if(iParcial_distancia_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_parcialc < 1)
         Linha_Horizontal("Parcialc", EntradaPreco - Partial_c, 1, clrBrown, STYLE_DASHDOT);    // criação da linha de parcial
      ObjectSetInteger(0,"Parcialc",OBJPROP_BACK,true);                                               // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iParcial_distancia_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_parcialc < 1)
         Linha_Horizontal("Parcialc", EntradaPreco + Partial_c, 1, clrBrown, STYLE_DASHDOT);    // criação da linha de parcial
      ObjectSetInteger(0,"Parcialc",OBJPROP_BACK,true);                                              // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iParcial_distancia2_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_parcialc <= 1)
         Linha_Horizontal("Parcial2c", EntradaPreco - Partial2_c, 1, clrBrown, STYLE_DASHDOT);  // criação da linha de parcial
      ObjectSetInteger(0,"Parcial2c",OBJPROP_BACK,true);                                           // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iParcial_distancia2_c > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_parcialc <= 1)
         Linha_Horizontal("Parcial2c", EntradaPreco + Partial2_c, 1, clrBrown, STYLE_DASHDOT);  // criação da linha de parcial
      ObjectSetInteger(0,"Parcial2c",OBJPROP_BACK,true);

      if(iBreak_Even_Start > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_BUY && cont_breakeven < 1)
         Linha_Horizontal("Breakeven", EntradaPreco + Break_Even_Start, 1, clrYellow, STYLE_DASHDOT); // criação de linha para visualização do breakeven
      ObjectSetInteger(0,"Breakeven",OBJPROP_BACK,true);                                            // Envio do objeto para a fim de evitar cruzamento com o painel gráfico
      if(iBreak_Even_Start > 0 && PosicaoInfo.PositionType() == POSITION_TYPE_SELL && cont_breakeven < 1)
         Linha_Horizontal("Breakeven", EntradaPreco - Break_Even_Start, 1, clrYellow, STYLE_DASHDOT); // criação de linha para visualização do breakeven
      ObjectSetInteger(0,"Breakeven",OBJPROP_BACK,true);                                            // Envio do objeto para a fim de evitar cruzamento com o painel gráfico

      Linha_Horizontal("Posição", EntradaPreco,2, clrAqua, STYLE_SOLID);
      ObjectGetInteger(0,"Posição",OBJPROP_BACK,true);
     }
//Redesenha as linhas de STOP e TAKE PROFIT
   ObjectDelete(0, "StopLoss");
   ObjectDelete(0, "TakeProfit");
   Linha_Horizontal("StopLoss", PosicaoInfo.StopLoss(), 2, clrRed, STYLE_SOLID);
   ObjectSetInteger(0,"StopLoss",OBJPROP_BACK,true);
   Linha_Horizontal("TakeProfit", PosicaoInfo.TakeProfit(), 2, clrLimeGreen, STYLE_SOLID);
   ObjectSetInteger(0,"TakeProfit",OBJPROP_BACK,true);

// Redesenhas as linhas de alvo para trailling stop
   if(iTrailing_Start > 0 && iBreak_Even_Start >= 0)
     {
      ObjectDelete(0, "Trailling");
      if(PositionsTotal() > 0)
        {
         if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY && TStop != 3)
            Linha_Horizontal("Trailling", traillbuy, 1, clrFuchsia, STYLE_DASHDOT);//--Cria linha de alvo stop movel no primeiro loop em caso de posição comprada
         ObjectSetInteger(0,"Trailling",OBJPROP_BACK,true);
         if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL && TStop != 3)
            Linha_Horizontal("Trailling", traillsell, 1, clrFuchsia, STYLE_DASHDOT); //--Cria linha de alvo stop movel no primeiro loop em caso de posição vendida
         ObjectSetInteger(0,"Trailling",OBJPROP_BACK,true);
        }
     }

// Redesenha linhas com horário de compra e venda do dia.
   if (horariomanager == true){     // condiciona a criação de linhas de horário com a ativação do módulo de gerenciamento de horários
   ObjectCreate(0, "HoraInicio", OBJ_VLINE, 0, StringToTime(inicio), 0);
   ObjectSetInteger(0, "HoraInicio", OBJPROP_COLOR, clrGreen);
   ObjectSetInteger(0,"HoraInicio",OBJPROP_BACK,true);
   ObjectCreate(0, "HoraTermino", OBJ_VLINE, 0, StringToTime(termino), 0);
   ObjectSetInteger(0,"HoraTermino",OBJPROP_BACK,true);
   ObjectSetInteger(0, "HoraTermino", OBJPROP_COLOR, clrYellow);
   ObjectCreate(0, "HoraFechamento", OBJ_VLINE, 0, StringToTime(fechamento), 0);
   ObjectSetInteger(0,"HoraInicio",OBJPROP_BACK,true);
   }

   if(horario_atual.hour >= horario_final.hour && horario_atual.min > horario_final.min) // Apaga de horários após o fechamendo do dia
     {ObjectDelete(0, "HoraInicio"); ObjectDelete(0, "HoraTermino"); ObjectDelete(0, "HoraFechamento");}


//---Reconstrução do Painel em caso de mudança de tamanho da janela ou período de tempo
   if(timef.Timeframe() != timeframe_antigo || ChartGetInteger(0,CHART_IS_MAXIMIZED) != chartstate_max)
     {
      timeframe_antigo=timef.Timeframe();
      chartstate_max=ChartGetInteger(0,CHART_IS_MAXIMIZED);

      Painel.CreatePanel();                                                         // inicialização da função do painel
      Painel.CreateText("MAD RABBIT LAB Inc Lauro cerqueira,Copyright 2020", clrWhite, 7, true);                           // código pra criação de texto, este será o texto de ídice "0"                           // código pra criação de texto, este será o texto de ídice "1"
      Painel.CreateText("===========================================================", clrWhite, 5, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 11, true);
      Painel.CreateText("-----------------------------------------------------------", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateText("Loading.....", clrWhite, 9, true);
      Painel.CreateButton("Zerar", clrWhite, clrRed);                   // código pra criação de botão, este será o texto de ídice "0"
      Painel.CreateButton("BuyAtMarket", clrWhite, clrBlue);
      Painel.CreateButton("SellAtMarket", clrWhite, clrGreen);
     }

// --- Chamada da função para painel de resumo das operações diárias
   ResumoOperacoes();

// ----------- Alimentação do Painel Gráfico---------------------------------//
   double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string AskS = DoubleToString(Ask, _Digits);
   string BidS = DoubleToString(Bid, _Digits);
   string prejuizo = DoubleToString(perda_painel, _Digits);
   string lucro = DoubleToString(lucro_painel, _Digits);
   string resultadodia = DoubleToString(resultado_liquido_painel, _Digits);
   string fator_lucro = DoubleToString(fator_lucro_painel, 2);
   string qtd_trades = IntegerToString(contador_trades_painel);
   string qtd_ordens = IntegerToString(contador_ordens_painel);
   string qt_trades_positivos = IntegerToString(tradespositivos);

   Painel.TextModifyString(3, TEXT_TEXTSHOW, "Setup: "+nomedaestrategia+"   ");
   Painel.TextModifyString(4, TEXT_TEXTSHOW, "       Ask: " + AskS + "       Bid: " + BidS+"              ");
   Painel.TextModifyString(6, TEXT_TEXTSHOW, "Prejuizo total(dia): " + (string)NormalizeDouble(prejuizo,_Point)+"                          ");
   Painel.TextModifyString(7, TEXT_TEXTSHOW, "Lucro total(dia): " +(string)NormalizeDouble(lucro,_Point)+"                                  ");
   Painel.TextModifyString(8, TEXT_TEXTSHOW, "Resultado(dia): " + (string)NormalizeDouble(resultadodia,_Point)+"                               ");
   Painel.TextModifyString(9, TEXT_TEXTSHOW, "Fator de Lucro(dia): " + fator_lucro+"                         ");
   Painel.TextModifyString(10, TEXT_TEXTSHOW, "Acertividade(dia): "+qt_trades_positivos +"/"+ qtd_trades+"                                   ");
   Painel.TextModifyString(11, TEXT_TEXTSHOW,"Qtd Ordens (dia): " + qtd_ordens+"                                   ");
   Painel.TextModifyString(12, TEXT_TEXTSHOW, "Volume: " + (string)SymbolOpenPositionsVolume(SIMBOLO)+"                                               ");
   Painel.TextModifyString(13, TEXT_TEXTSHOW, "Resultado da posição: " + (string)SymbolOpenResult(SIMBOLO)+"                          ");
   Painel.TextModifyString(14, TEXT_TEXTSHOW, "Candle Time: " + CandleTime(SIMBOLO,_Period)+"                    ");

   if(resultado_liquido_painel > 0)
     {
      Painel.TextModifyInteger(8, TEXT_FONTCOLOR, clrGreen);
      return;
     }
   if(resultado_liquido_painel < 0)
      Painel.TextModifyInteger(8, TEXT_FONTCOLOR, clrRed);
   else
      Painel.TextModifyInteger(8, TEXT_FONTCOLOR, clrWhite);

   if(SymbolOpenResult(SIMBOLO) > 0)
     {
      Painel.TextModifyInteger(13, TEXT_FONTCOLOR, clrGreen);
      return;
     }
   if(SymbolOpenResult(SIMBOLO) < 0)
      Painel.TextModifyInteger(13, TEXT_FONTCOLOR, clrRed);
   else
      Painel.TextModifyInteger(14, TEXT_FONTCOLOR, clrWhite);

   if(fator_lucro_painel > 0)
     {
      Painel.TextModifyInteger(9, TEXT_FONTCOLOR, clrGreen);
      return;
     }
   if(fator_lucro_painel < -1)
      Painel.TextModifyInteger(9, TEXT_FONTCOLOR, clrRed);
   else
      Painel.TextModifyInteger(9, TEXT_FONTCOLOR, clrWhite);

   if(perda_painel < 0)
      Painel.TextModifyInteger(6, TEXT_FONTCOLOR, clrRed);
   else
      Painel.TextModifyInteger(6, TEXT_FONTCOLOR, clrWhite);

   if(lucro_painel > 0)
      Painel.TextModifyInteger(7, TEXT_FONTCOLOR, clrRed);
   else
      Painel.TextModifyInteger(7, TEXT_FONTCOLOR, clrWhite);
  }

//+------------------------------------------------------------------+
//|  FUNÇÕES DO MÓDULO MARTINGALE                                    |
//+------------------------------------------------------------------+
void Martingale()
  {
   MqlDateTime dia_atual;
   TimeCurrent(dia_atual);
   if(dia_atual.day == memoria_martingale.day)
     {
      if(Saidadaoperacao())
        {
         if(prova != ticket_ea)   //--- intercalar a variavel ticket da função de saída para verficar eu o tícket informado da operação negativa são diferentes
            volumeatual = volumeatual * mult_martingale;
         prova = ticket_ea; //-- a variável prova recebe o novo valor do ultimo tick com resultado negativo
         if(volumeatual > vol_maximo_martingale)
            volumeatual = vol_maximo_martingale;
        }
      else
        {
         volumeatual = NormalizeVolume(Volume);
        }
     }
   else
     {
      volumeatual = NormalizeVolume(Volume);
      TimeCurrent(memoria_martingale);
     }
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
      if(HistoryDealGetString(ticket_ea, DEAL_SYMBOL) != string(SIMBOLO))
         return (false);
      if((HistoryDealGetInteger(ticket_ea,DEAL_ENTRY)==DEAL_ENTRY_OUT)|| (HistoryDealGetInteger(ticket_ea,DEAL_ENTRY)==DEAL_ENTRY_INOUT))
        {
         result = HistoryDealGetDouble(ticket_ea, DEAL_PROFIT);
         break;
        }  // --- interrompe o laço for na primeira verificação (ultima operação de acordo com a ordem de verificação)
     }
   if(result <= -1) // verifica se o resultado da ultima operação é negativo
      return (true);

   return (false);
  }
//+------------------------------------------------------------------+
//|  Função posição do momento                                       |
//+------------------------------------------------------------------+
double GetPositionResult()
  {
   double temp = 0;
   int N = PositionsTotal();
   ulong Ticket;
   for(int i = N - 1; i >= 0; i--)
     {
      Ticket = PositionGetTicket(i);
      temp += PositionGetDouble(POSITION_PROFIT);
     }
   return temp;
  }
//+--------------------------------------------------------------------------------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------------------------------ESTRATÉRGIAS-----------------------------------+
//-------------------------------------------------------------------+
//| Módulo de sinais                                                 |
//+------------------------------------------------------------------+
int Signals()
  {
   int cont_signals = 0;
   int soma_signals = 0;

   if(s_CrossMA)
      cont_signals++;
   if(s_MACD)
      cont_signals++;
   if(s_VWAP)
      cont_signals++;
   if(s_ATR)
      cont_signals++;
   if(s_MA)
      cont_signals++;
   if(s_RSI)
      cont_signals++;

   soma_signals = CruzamentoMA() + SinalMACD() + SinalVWAP()+SinalATR()+ MovingAverage()+SinalRSI();
    
   if(soma_signals == cont_signals)
 
      if(!invertersinal)
         return 1;
      else
         return -1;

   if(soma_signals == cont_signals * -1)
      if(!invertersinal)
         return -1;
      else
         return 1;

   return 0;
  }
//-------------------------------------------------------------------+
//| Estratégia de cruzamento de médias Móveis                        |
//+------------------------------------------------------------------+
int CruzamentoMA()
  {
   if(s_CrossMA)
     {
      // Cópia dos buffers dos indicadores de média móvel com períodos curto e longo
      double MediaCurta[], MediaLonga[];
      ArraySetAsSeries(MediaCurta, true);
      ArraySetAsSeries(MediaLonga, true);
      CopyBuffer(handlemediacurta, 0, PeriodoCurto_desloc, 3, MediaCurta);
      CopyBuffer(handlemedialonga, 0, PeriodoLongo_desloc, 3, MediaLonga);
      bool  sinal_compra_Cruzamento = false;
      bool  sinal_venda_Cruzamento  = false;

      // Compra em caso de cruzamento da média curta para cima da média longa

      if(MediaCurta[2] <= MediaLonga[2] && MediaCurta[1] > MediaLonga[1])
         return 1;

      // Venda em caso de cruzamento da média curta para baixo da média longa
      if(MediaCurta[2] >= MediaLonga[2] && MediaCurta[1] < MediaLonga[1])
         return -1;
      return 0;
     }
   return 0;
  }
//-------------------------------------------------------------------+
//| Estratégia de cruzamento MACD                                    |
//+------------------------------------------------------------------+
int SinalMACD()
  {
   if(s_MACD)
     {
      double MACD[];
      ArraySetAsSeries(MACD, true);
      CopyBuffer(handlemacd, 0, 0, 2, MACD); //--- copia 2 arrays  a partir do segundo buffer (1)

      if(MACD[0] > 0) //---compra
        {return 1;}

      if(MACD[0] < 0) //--- venda
        {return -1;}

      return 0;
     }
   return 0;
  }
//-------------------------------------------------------------------+
//|        VWAP                                                      |
//+------------------------------------------------------------------+
int SinalVWAP()
  {
   int result = 0;
   if(s_VWAP)
     {
      double VWAPbuffer[], close[], MAVWAPBuffer[];
      ArraySetAsSeries(VWAPbuffer, true);
      ArraySetAsSeries(MAVWAPBuffer, true);
      ArraySetAsSeries(close, true);
      CopyBuffer(handlevwap, 0, 0, 3, VWAPbuffer);
      CopyBuffer(handlemavwap, 0, 0, 3, MAVWAPBuffer);
      CopyClose(_Symbol, _Period, 0, 3, close);

      switch(estrategiavwap)
        {
         case 1:
            if(close[2] <= VWAPbuffer[2] && close[1] > VWAPbuffer[1]) //---compra
              {
               result = 1;
               break;
              }
            if(close[2] >= VWAPbuffer[2] && close[1] < VWAPbuffer[1]) //--- venda
              {
               result = -1;
               break;
              }
            result = 0;
            break;

         case 2:
            if(MAVWAPBuffer[2] <= VWAPbuffer[2] && MAVWAPBuffer[1] > VWAPbuffer[1]) //---compra
              {
               result = 1;
               break;
              }
            if(MAVWAPBuffer[2] >= VWAPbuffer[2] && MAVWAPBuffer[1] < VWAPbuffer[1]) //--- venda
              {
               result = -1;
               break;
              }
            result = 0;
            break;

         case 3:
            if(VWAPbuffer[1] < VWAPbuffer[0] && VWAPbuffer[2] >= VWAPbuffer[1]) //---compra
              {
               result = 1;
               break;
              }
            if(VWAPbuffer[1] > VWAPbuffer[0] && VWAPbuffer[2] >= VWAPbuffer[1]) //--- venda
              {
               result = -1;
               break;
              }
            result = 0;
            break;
        }
      return result;
     }
   return 0;
  }
//-------------------------------------------------------------------+
//|        PARABOLIC SAR                                             |
//+------------------------------------------------------------------+
double Step_SAR()
  {
   double SARBuffer[];
   if(TStop == 3)

      ArraySetAsSeries(SARBuffer, true);
   CopyBuffer(handleSAR, 0, 0, 3, SARBuffer);
   double result ;
   if(tipolotes != 3)
      result=NormalizePrice(SARBuffer[0],SIMBOLO,tick_size_ativo);
   else
      result = NormalizeDouble(SARBuffer[0] - MathMod(SARBuffer[0],tick_size_ativo),2);
   return result;

  }

//-------------------------------------------------------------------+
//|        Average True Range                                        |
//+------------------------------------------------------------------+
double Step_ATRupper()
  {
   double ATRBufferupper[];
   if(TStop == 4)
      ArraySetAsSeries(ATRBufferupper, true);
   CopyBuffer(handleatr, 0, 0, 3, ATRBufferupper);
   double result ;
   if(tipolotes !=3)
      result=NormalizePrice(ATRBufferupper[0],SIMBOLO,tick_size_ativo);
   else
      result = NormalizeDouble(ATRBufferupper[0] - MathMod(ATRBufferupper[0],tick_size_ativo),2);
   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Step_ATRlower()
  {
   double ATRBufferlower[] ;
   if(TStop == 4)
      ArraySetAsSeries(ATRBufferlower, true);
   CopyBuffer(handleatr, 1, 0, 3, ATRBufferlower);
   double result ;
   if(tipolotes !=3)
      result=NormalizePrice(ATRBufferlower[0],SIMBOLO,tick_size_ativo);
   else
      result = NormalizeDouble(ATRBufferlower[0] - MathMod(ATRBufferlower[0],tick_size_ativo),2);
   return result;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SinalATR()
  {
   if(s_ATR)
     {
      double ATRBufferupper[],ATRBufferlower[],ATRBuy[],ATRSell[], close[];

      ArraySetAsSeries(ATRBufferlower, true);
      ArraySetAsSeries(ATRBufferupper, true);
      ArraySetAsSeries(ATRSell, true);
      ArraySetAsSeries(ATRBuy, true);
      ArraySetAsSeries(close,true);
      CopyBuffer(handleatr,0, 0, 3, ATRBufferupper);
      CopyBuffer(handleatr,1, 0, 3, ATRBufferlower);
      CopyBuffer(handleatr,2,0,3,ATRBuy);
      CopyBuffer(handleatr,3,0,3,ATRSell);
      CopyClose(_Symbol,_Period,0,3,close);

      //  if(ATRBufferupper[0]==ATRBuy[0] && ATRBufferupper[0]>1000.0 && ATRBuy[0]>1000.0)
      if(ATRSell[0]>1000)
         return -1;
      // if(ATRBufferlower[0] == ATRSell[0] && ATRBufferlower[0]>1000.0 && ATRSell[0]>1000.0)
      if(ATRBuy[0]>1000)
         return 1;

      return 0;
     }
   return 0;
  }
//-------------------------------------------------------------------+
//| Médias Móvel                                                     |
//+------------------------------------------------------------------+
int MovingAverage()
  {
   if(s_MA)
     {
      // Cópia dos buffers dos indicadores de média móvel
      double Mediabuffer[],close[];
      ArraySetAsSeries(Mediabuffer, true);
      ArraySetAsSeries(close, true);
      CopyBuffer(handlema, 0, Periodo_desloc, 3, Mediabuffer);
      CopyClose(_Symbol,_Period,0,3,close);

      // Compra em caso de preço cruze média para cima

      if(Mediabuffer[1] < Mediabuffer[0] && Mediabuffer[2] >= Mediabuffer[1])
         return 1;

      // Venda em caso preço cruze a média para baixo
      if(Mediabuffer[1] > Mediabuffer[0] && Mediabuffer[2] >= Mediabuffer[1])
         return -1;

      return 0;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|           Step Moving Average                                    |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Step_MovingAverage()
  {
   double StepMediabuffer[];
   if(TStop==5)
     {
      ArraySetAsSeries(StepMediabuffer, true);// Cópia dos buffers dos indicadores de média móvel
      CopyBuffer(handlema, 0, Periodo_desloc, 3, StepMediabuffer);
      double result ;
      if(tipolotes !=3)
         result=NormalizePrice(StepMediabuffer[0],SIMBOLO,tick_size_ativo);
      else
         result = NormalizeDouble(StepMediabuffer[0] - MathMod(StepMediabuffer[0],tick_size_ativo),2);
      return result;
     }
   else
      return 0;
  }


//-------------------------------------------------------------------+
//|               RSI                                                |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SinalRSI()
  {
   int result=0;
   if(s_RSI)
     {
      double RSIbuffer[];
      ArraySetAsSeries(RSIbuffer, true);
      ArraySetAsSeries(RSIbuffer, true);
      CopyBuffer(handleRSI, 0,0, 4, RSIbuffer);
      switch(estr_RSI)
        {
         case FECHAMENTO_DO_CANDLE:
            if(RSIbuffer[1]< rsi_inferior)//---compra
              {
               result = 1;
               break;
              }
            if(RSIbuffer[1]> rsi_superior) //--- venda
              {
               result = -1;
               break;
              }
            result = 0;
            break;


         case CANDLE_ABERTO:

            if(RSIbuffer[0]< rsi_inferior) //---compra
              {
               result = 1;
               break;
              }
            if(RSIbuffer[0]> rsi_superior) //--- venda
              {
               result = -1;
               break;
              }
            result = 0;
            break;

        }
     }
   return result;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
