//+------------------------------------------------------------------+
//|                                                 Simple_Panel.mq5 |
//|                                  Copyright 2020, MadRabbit Labs. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lauro Cerqueira."
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"
// Inclusão de bibliotecas do painel 

#include <ClassControlPanel.mqh>                               // colar o arquivo ClassControlPanel.mqh na raiz da pasta Include do terminal 
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Expert/Expert.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include <ClassControlPanel.mqh>
#include <SymbolTradeMadeSimple.mqh>



CControlPainel Painel(0, 0.2, 0.95, 4, 3, CORNER_LEFT_LOWER);  // Classe responsável pela criação do painel de resumo o ajustes de altura e largura
							       // posição podem ser feitos diretamente nesta linha 
CTrade trade;                                                // Classe responsável pela execução de negócios
CSymbolInfo simbolo;                                           // Classe responsável pelos dados do ativo
CPositionInfo PosicaoInfo;                                     // Classe responsável pela aquisição de informações de posições
                               
input double magicNumber=123456;
input double volume_padrao= 100;                             
// Declaração de variáveis para painel de resumo das operações

double lucro_painel, perda_painel;
int contador_trades_painel;
int contador_ordens_painel;
double resultado_painel;
ulong ticket_painel;
double fator_lucro_painel;
double resultado_liquido_painel;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()

{

//=====================================================Bloco de inicialização do painel de resumo===============================================================
   Painel.CreatePanel();                                                         // inicialização da função do painel 
   Painel.CreateText("Cabeçalho1", clrWhite, 7, true);                           // código pra criação de texto, este será o texto de ídice "0"
   Painel.CreateText("Cabeçalho2", clrWhite, 7, true);                           // código pra criação de texto, este será o texto de ídice "1"
   Painel.CreateText("Cabeçalho3", clrWhite, 7, true);
   Painel.CreateText("----------------------------------------------------------------------", clrWhite, 5, true);
   Painel.CreateText("Ask: 0.0 Bid: 0.0", clrWhite, 9, true);
   Painel.CreateText("Prejuizo total(dia)", clrRed, 9, true);
   Painel.CreateText("0", clrRed, 8, true);
   Painel.CreateText("Lucro total(dia)", clrGreen, 9, true);
   Painel.CreateText("0", clrGreen, 8, true);
   Painel.CreateText("Resultado(dia)", clrWhite, 9, true);
   Painel.CreateText("0", clrWhite, 8, true);
   Painel.CreateText("Fator de Lucro(dia)", clrWhite, 9, true);
   Painel.CreateText("0", clrWhite, 8, true);
   Painel.CreateText("Qtd Trades(dia)", clrWhite, 9, true);
   Painel.CreateText("0", clrWhite, 8, true);
   Painel.CreateText("Qtd Ordens(dia)", clrWhite, 9, true);
   Painel.CreateText("0", clrWhite, 8, true);
   Painel.CreateButton("Zerar", clrWhite, clrRed);                            // código pra criação de botão, este será o texto de ídice "0"
   Painel.CreateText("", clrBlack, 4, true);
   Painel.CreateButton("BuyAtMarket", clrWhite, clrBlue);
   Painel.CreateText("", clrBlack, 4, true);
   Painel.CreateButton("SellAtMarket", clrWhite, clrGreen);
   Painel.CreateText("Temporizador do Candle", clrWhite, 7, true);
   Painel.CreateText("0", clrWhite, 7, true);
   Painel.CreateText("Volume das posições", clrWhite, 7, true);
   Painel.CreateText("0", clrWhite, 7, true);
   Painel.CreateText("Resultado Parcial", clrWhite, 7, true);
   Painel.CreateText("0", clrWhite, 7, true);


return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
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
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {


   if(!simbolo.RefreshRates()) return;  // Atualização dos dados do ativo

   	// ####LÓGICA DO ROBÔ #####

   Drawings(); // função criada para organizar desenhos melhorando a visualização da função principal deve colocada no final da lógica do robô

  }




//+------------------------------------------------------------------+
//|           Função de interação com painel gráfico                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(Painel.ButtonGetState(1))						// botão zerar 
         if(trade.PositionClose(_Symbol)) 					// fecha todas a posições enviando ordens contrárias a mercado 
           {
            Alert("Fechamento de posição efetuado pelo botão zerar");
            Painel.ButtonSetState(1, false);
           }
      if(Painel.ButtonGetState(2))						//botão Buy at market	
        {
         if(PositionSelect(_Symbol))
           if(PosicaoInfo.PositionType() == POSITION_TYPE_SELL)                 //se  estiver posicionado em venda o botão faz uma compra
              {
               
               trade.Buy(volume_padrao,NULL,0,0,0,NULL); 						        // colar a função de compra ou a função de ordem a mercado 						
               Alert("Buy at Market");						                      // alerta enviado confirmando a operação 
               Painel.ButtonSetState(2, false);
              }
            else							       // se estiver posicionado em compra  o botão  encerra a posição enviando ordens contrária a mercado
              {
               trade.PositionClose(_Symbol);
               Alert("Buy at Market");					      // alerta enviado confirmando a operação 
               Painel.ButtonSetState(2, false);
              }
            
         else
           {
            
            trade.Buy(volume_padrao,NULL,0,0,0,NULL);    // se não estiver posicionado o botão faz um compra a mercado
            Alert("Buy at Market");
            Painel.ButtonSetState(2, false);
           }
        }

      if(Painel.ButtonGetState(3))                                           // botão de venda a mercado ( sell at market) segue a mesma lógica do de compra 
        {
         if(PositionSelect(_Symbol))
            if(PosicaoInfo.PositionType() == POSITION_TYPE_BUY)
              {
              
               trade.Sell(volume_padrao,NULL,0,0,0,NULL);             					// colar a função de venda ou a de envio de ordens a mercado           
               Alert("Sell at Market");
               Painel.ButtonSetState(2, false);
              }
            else
              {
               trade.PositionClose(_Symbol);
               Alert("Sell at Market");
               Painel.ButtonSetState(2, false);
              }
         else
           {
            
            trade.Sell(volume_padrao,NULL,0,0,0,NULL);				                  	// colar a função de venda ou a de envio de ordens a mercado   
            Alert("Buy at Market");
            Painel.ButtonSetState(2, false);
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
   ulong ticket1 = 0;
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
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ticket1 = HistoryDealGetTicket(i);
      long Entry  = HistoryDealGetInteger(ticket1, DEAL_ENTRY);

      if(ticket1 > 0)
         if(HistoryDealGetString(ticket1, DEAL_SYMBOL) == string(_Symbol) && (HistoryDealGetInteger(ticket1, DEAL_MAGIC) == magicNumber||HistoryDealGetInteger(ticket1, DEAL_MAGIC) == 0))
           {
            contador_ordens++;
            resultado = HistoryDealGetDouble(ticket1, DEAL_PROFIT);

            if(resultado < 0)
               perda += -resultado;
            else
               lucro += resultado;
       
                      
               if(Entry == DEAL_ENTRY_OUT || Entry == DEAL_ENTRY_INOUT ) // ----- Se inversão de mão estiver ativa o contador tbm irá receber os resultados das saídas dos trades e das inversões
                  contador_trades++;

          }
     }

   if(perda > 0)
      fator_lucro = lucro / perda;
   else
      fator_lucro = -1;

   resultado_liquido = lucro - perda;

//---- Transferindo resultado para variáveis globais a fim de alimentar o painel de resumo na função Drawing
   lucro_painel = lucro;
   perda_painel = perda;
   contador_trades_painel = contador_trades;
   contador_ordens_painel = contador_ordens;
   ticket_painel = ticket1;
   fator_lucro_painel = fator_lucro;
   resultado_liquido_painel = resultado_liquido;
  }

//+------------------------------------------------------------------+
//|  Função Para Ogranizar Drawings                                  |
//+------------------------------------------------------------------+
void Drawings()
  {
   

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

   Painel.TextModifyString(5, TEXT_TEXTSHOW, "Ask: " + AskS + " Bid: " + BidS);
   Painel.TextModifyString(7, TEXT_TEXTSHOW, "" + NormalizeDouble(prejuizo,2));
   Painel.TextModifyString(9, TEXT_TEXTSHOW, "" + NormalizeDouble(lucro,2));
   Painel.TextModifyString(11, TEXT_TEXTSHOW, "" + NormalizeDouble(resultadodia,2));
   Painel.TextModifyString(13, TEXT_TEXTSHOW, "" + fator_lucro);
   Painel.TextModifyString(15, TEXT_TEXTSHOW, "" + qtd_trades);
   Painel.TextModifyString(17, TEXT_TEXTSHOW, "" + qtd_ordens);
   Painel.TextModifyString(21, TEXT_TEXTSHOW, "" + CandleTime(_Symbol,_Period));
   Painel.TextModifyString(23, TEXT_TEXTSHOW, "" + (string)SymbolOpenPositionsVolume(_Symbol));
   Painel.TextModifyString(25, TEXT_TEXTSHOW, "" + (string)SymbolOpenResult(_Symbol));

   if(resultado_liquido_painel > 0)
     {
      Painel.TextModifyInteger(11, TEXT_FONTCOLOR, clrGreen);
      return;
     }
   if(resultado_liquido_painel < 0)
      Painel.TextModifyInteger(11, TEXT_FONTCOLOR, clrRed);
   else
      Painel.TextModifyInteger(11, TEXT_FONTCOLOR, clrWhite);
  }

