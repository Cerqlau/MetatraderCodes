//+------------------------------------------------------------------+
//|                                  Monitoramento Multi Ativo 2.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"
#property description " Este projeto foi desenvolvido para verificação de sinais multi Ativo.Realizando uma varredura em todos ativos presentes na janela de visão do mercado.\n O usuário poderá acompanhar o seu carregamento e funcionamento na abaa Experts da Caixa de Ferramentas"

// Definição dos Parâmetros indicadores
input bool  novografico     =false;                           //Abrir Demais Gráficos
input ENUM_TIMEFRAMES      Periodografico_Timeframe = PERIOD_CURRENT; // Timeframe dos gráficos
input ENUM_TIMEFRAMES      Periodografico_Timeframep = PERIOD_CURRENT; // Timeframe do gráfico principal
input group   "---------------------------INDICADORES-----------------------------------------"
input group   "Média Rápida"
input int                  PeriodoCurto   = 9;                   // Período Média Curta
input int                  PeriodoCurto_desloc = 0;               // Deslocamento Curta
input ENUM_MA_METHOD       PeriodoCurto_meth = MODE_SMA;          // Tipo Média Curta
input ENUM_APPLIED_PRICE   PeriodoCurto_price = PRICE_CLOSE;      //  Preço Média Curta
input ENUM_TIMEFRAMES      PeriodoCurto_Timeframe = PERIOD_CURRENT; // Timeframe Média Curta
input group   "------------------------------------------------------------------------------------"
input group   "Média Lenta"
input int                  PeriodoLongo   = 21;                   // Período Média Longa
input int                  PeriodoLongo_desloc = 0;               // Deslocamento Longa
input ENUM_MA_METHOD       PeriodoLongo_meth = MODE_SMA;          // Tipo Média Longa
input ENUM_APPLIED_PRICE   PeriodoLongo_price = PRICE_CLOSE;      // Preço Média Longa
input ENUM_TIMEFRAMES      PeriodoLongo_Timeframe = PERIOD_CURRENT; // Timeframe Média Curta

// Delcaração de variáveis globais e de classe
int handlemedialonga,handlemediacurta,total_ativos;                        // Manipuladores dos dois indicadores de média móvel
int arraymedialonga[],arraymediacurta[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//--- Adicionando ativos
   total_ativos= SymbolsTotal(true);                                           // informa a quantidade de ativos na janela observação de mercado
   Print("Total de ativos: ",total_ativos);                                    // informa na aba de informações do experta a quantidade de ativos do mercado
   for(int i=0; i<total_ativos; i++) {
      Print("Ativo", i, " adicionando: ",SymbolName(i,true));
   }
//--- Verificação de inconsistências nos parâmetros de entrada
   if(PeriodoLongo <= PeriodoCurto && PeriodoCurto_desloc==PeriodoLongo_desloc) {
      MessageBox("Parâmetros de médias incorretos");
      return INIT_FAILED;
   }
//--- Criação dos manipuladores com Períodos curto e longo
   ArrayResize(arraymedialonga,total_ativos);
   ArrayResize(arraymediacurta,total_ativos);
   for(int i=0; i<total_ativos; i++) {
      handlemediacurta = iMA(SymbolName(i,true), PeriodoCurto_Timeframe,PeriodoCurto,PeriodoCurto_desloc,PeriodoCurto_meth,PeriodoCurto_price);
      handlemedialonga = iMA(SymbolName(i,true), PeriodoLongo_Timeframe,PeriodoLongo,PeriodoLongo_desloc,PeriodoLongo_meth,PeriodoLongo_price);
      arraymediacurta[i] = handlemediacurta;
      arraymedialonga[i] = handlemedialonga;
      // Verificação do resultado da criação dos manipuladores
      if(handlemediacurta == INVALID_HANDLE || handlemedialonga == INVALID_HANDLE) {
         MessageBox("Erro na criação dos manipuladores");
         return INIT_FAILED;
      }
   }
   MessageBox("Todos os ativos da janela de observação foram adicionados com sucesso");
   ChartApplyTemplate(0,"\\Files\\default.tpl");
   ChartIndicatorAdd(0,0,iMA(_Symbol, PeriodoCurto_Timeframe,PeriodoCurto,PeriodoCurto_desloc,PeriodoCurto_meth,PeriodoCurto_price));
   ChartIndicatorAdd(0,0,iMA(_Symbol, PeriodoLongo_Timeframe,PeriodoLongo,PeriodoLongo_desloc,PeriodoLongo_meth,PeriodoLongo_price));
   ChartIndicatorAdd(0,0,iCustom(_Symbol,PERIOD_CURRENT,"Market\\Blahtech Candle Timer MT5"));
   ChartSetSymbolPeriod(0,_Symbol,Periodografico_Timeframep);
   if (novografico==true) {
      for(int i=0; i<total_ativos; i++) {
         ChartOpen(SymbolName(i,true),Periodografico_Timeframe);
         long grafico =ChartID();
      }
      long currChart,prevChart=ChartFirst();
      int i=0,limit=100;
      bool errTemplate;
      while(i<limit) {
         currChart=ChartNext(prevChart); // Obter o ID do novo gráfico usando o ID gráfico anterior
         if(Periodografico_Timeframe!=PERIOD_CURRENT) { // Se o tempo grafico e diferente aplica a todos
            ChartSetSymbolPeriod(prevChart,ChartSymbol(prevChart),Periodografico_Timeframe);
         }
         // Aplica a template
         // errTemplate=ChartIndicatorAdd(prevChart,"Atual.tpl");
         // if(!errTemplate)
         // {
         // Print("Erro ao adicionar a template a ",ChartSymbol(prevChart),"-> ",GetLastError());
         //}
         if(currChart<0) break;          // Ter atingido o fim da lista de gráfico
         Print(i,ChartSymbol(currChart)," ID =",currChart);
         ChartIndicatorAdd(currChart,0,iMA(ChartSymbol(currChart), PeriodoCurto_Timeframe,PeriodoCurto,PeriodoCurto_desloc,PeriodoCurto_meth,PeriodoCurto_price));
         ChartIndicatorAdd(currChart,0,iMA(ChartSymbol(currChart), PeriodoLongo_Timeframe,PeriodoLongo,PeriodoLongo_desloc,PeriodoLongo_meth,PeriodoLongo_price));
         prevChart=currChart;// vamos salvar o ID do gráfico atual para o ChartNext()
         i++;// Não esqueça de aumentar o contador
      }
   }
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //Motivo do robo ter saido
   switch(reason) {
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
   for(int i = ChartIndicatorsTotal(0, 0); i > 0; i--) {
      ChartIndicatorDelete(0, 0, ChartIndicatorName(0, 0, ChartIndicatorsTotal(0, 0) - i));
      ChartIndicatorDelete(0, 1, ChartIndicatorName(0, 1, ChartIndicatorsTotal(0, 1) - i));
   }
   ChartRedraw();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---logica de análises de estratégias
   if(isNewBar()) {
      Cruzamento();
   }
}


//+------------------------------------------------------------------+


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
   if(last_time==0) {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
   }
//--- if the time differs
   if(last_time!=lastbar_time) {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
   }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
}

//+------------------------------------------------------------------+
//| Estratégia de cruzamento de médias                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Cruzamento()
{
// Cópia dos buffers dos indicadores de média móvel com períodos curto e longo
   for(int i=0; i<total_ativos; i++) {
      string symbol = SymbolName(i,true);
      double MediaCurta[], MediaLonga[];
      ArraySetAsSeries(MediaCurta, true);
      ArraySetAsSeries(MediaLonga, true);
      CopyBuffer(arraymediacurta[i],0,PeriodoCurto_desloc, 3, MediaCurta);
      CopyBuffer(arraymedialonga[i], 0,PeriodoLongo_desloc, 3, MediaLonga);
// Compra em caso de cruzamento da média curta para cima da média longa
      if(MediaCurta[2]<=MediaLonga[2] && MediaCurta[1]>MediaLonga[1]) {
         Alert("Call de Compra ",symbol," ",SymbolInfoString(symbol,SYMBOL_DESCRIPTION)," ",SymbolInfoDouble(symbol,SYMBOL_ASK));
         SendNotification("Call de Compra MT5 "+(string)symbol+" "+(string)SymbolInfoString(symbol,SYMBOL_DESCRIPTION)+" "+(string)SymbolInfoDouble(symbol,SYMBOL_ASK)+" "+ (string)PERIOD_CURRENT );
      }
      //  SendMail("Call de Compra MT5","Call de Compra MT5 "+(string)symbol+" "+(string)SymbolInfoString(symbol,SYMBOL_DESCRIPTION)+" "+(string)SymbolInfoDouble(symbol,SYMBOL_ASK));
// Venda em caso de cruzamento da média curta para baixo da média longa
      if(MediaCurta[2]>=MediaLonga[2] && MediaCurta[1]<MediaLonga[1]) {
         Alert("Call de Venda ",symbol," ",SymbolInfoString(symbol,SYMBOL_DESCRIPTION)," ",SymbolInfoDouble(symbol,SYMBOL_BID));
         SendNotification("Call de Venda MT5 "+(string)symbol+" "+(string)SymbolInfoString(symbol,SYMBOL_DESCRIPTION)+" "+(string)SymbolInfoDouble(symbol,SYMBOL_ASK)+" "+ (string)PERIOD_CURRENT);
      }
      // SendMail("Call de Venda MT5","Call de Compra MT5 "+(string)symbol+" "+(string)SymbolInfoString(symbol,SYMBOL_DESCRIPTION)+" "+(string)SymbolInfoDouble(symbol,SYMBOL_ASK));
   }
}
//+------------------------------------------------------------------+
