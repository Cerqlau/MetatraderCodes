//+------------------------------------------------------------------+
//|                                               MadRabbit_MACD.mq5 |
//|              Lauro Cerqueira Copyright 2020, MAD RABBIT LAB Inc. |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+

//---
#include <Trade/Trade.mqh>

enum LIGA
  {
    SIM,   // Sim
    NAO    // Não
  };
  
enum estrategia_entrada
  {
    FECHAMENTO_DO_CANDLE,   // Fechamento do Candle
    CANDLE_ABERTO           // Candle Aberto
  };

sinput string s0; //-----------Configurações de Entrada-------------- 
input int magic_number_set            = 6548576;             // Numero Mágico deste Robô
input estrategia_entrada estrategia   = FECHAMENTO_DO_CANDLE; // Tipo de Gatilho de Entrada

sinput string s1; //--------------------RSI--------------------------
input int ifr_superior                = 70;                   // Nível Superior RSI
input int ifr_inferior                = 30;                   // Nível inferior RSI
input int ifr_periodo                 = 14;                   // Periodo RSI

sinput string s2; //-------------Gerenciamento de Risco--------------
input double num_lotes                = 0.01;                 // Volume de Negociação
input double pts_TK                   = 0.005;                // Take Profit
input double pts_SL                   = 0.005;                // Stop Loss
input int pts_spread                  = 10;                   // Spread Máximo Aceitável
input int pts_desvio                  = 10;                   // Desvio de Preço Aceitável

sinput string s3;  //------------Configurações de trade-------------- 
input LIGA liga_martingale            = NAO;                  // Liga Martingale
input double multiplicador_MG         = 2;                    // Multiplicador de Martingale
input double volume_max_MG            = 0.16;                  // Volume Máximo de Negociação de Martingale
input int num_loss                    = 5;                    // Nº Máximo de Martingale                    

sinput string s4; // -------------Stops Financeiros------------------
input LIGA stops_fin                  = NAO;                  // Operar com Stops Financeiros
input double sl_fin                   = 10;                   // Stop Loss Financeiro (R$ "a partir de 1"  US$ "a partir de 0.01")
input double tk_fin                   = 10;                   // STop Gain Financeiro (R$ "a partir de 1"  US$ "a partir de 0.01")

//+------------------------------------------------------------------+
//|      Váriaveis para os indicadores                               |
//+------------------------------------------------------------------+
double SL, TK, ultimo_tick,volume_atual,preco_medio, preco_parcial;   
int spread, contador_loss=0, contador_gale=0;
//+------------------------------------------------------------------+
//|       Váriaveis para as Funções                                  |
//+------------------------------------------------------------------+
int ifr_Handle;               //Handle controlador IFR
double ifr_Buffer[];          //Buffer para armazenamento dos dados de IFR

// função verifica SL e TP
ulong  ticket_comentario_SL_antigo;  
ulong  ticket_comentario_TP_antigo;

// Função Martingale
bool ultimo_loss = false;
int gale_efetuado = 0;


MqlRates velas[];             // Variável para armazenar velas
MqlTick tick;                 // Variável para armazenar ticks

CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    trade.SetTypeFilling(ORDER_FILLING_FOK); 
    trade.SetExpertMagicNumber(magic_number_set);
    trade.SetDeviationInPoints(pts_desvio);  

   volume_atual = num_lotes;
   Print("Contador de Loss: ",contador_loss);
   
   ifr_Handle = iRSI(_Symbol,PERIOD_CURRENT,ifr_periodo,PRICE_CLOSE);
   ArraySetAsSeries(velas,true);
   
   if(ifr_Handle<0)
      {
      Alert("Erro ao tentar criar Handle para o indicador - erro: ",GetLastError(),"!");
      return(-1);
      }   
   if(liga_martingale==SIM)
   {if ((volume_max_MG/multiplicador_MG)<double(num_loss))
       Alert("Erro na configuração do martingale");}
//--------------------------------------------------------------------------------------------------------
     
   if(_Digits == 0)
     {
         SL = pts_SL; 
         TK = pts_TK;
     }    
         
   if(_Digits == 1)
     {
         SL = pts_SL*10; 
         TK = pts_TK*10;     
      } 
        
   if(_Digits == 2)
     {
         SL = pts_SL*100; 
         TK = pts_TK*100; 
      } 
        
    if(_Digits == 3)
     {
         SL = pts_SL*1000; 
         TK = pts_TK*1000;
      } 
        
     if(_Digits == 4)
     {
         SL = pts_SL*10000; 
         TK = pts_TK*10000;                
      } 
            
     if(_Digits == 5)
     {
         SL = pts_SL*100000; 
         TK = pts_TK*100000;               
     }   

//---
   ChartIndicatorAdd(0,1,ifr_Handle);
     
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(ifr_Handle);
   ChartRedraw();
   
   for(int i = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL); i >= 0 ; i--)
     {
      for(int j = ChartIndicatorsTotal(0, i); j >= 0; j--)
        {
         ChartIndicatorDelete(0, i, ChartIndicatorName(0, i, 0));
        }
      }  
      
  }
//---------------------------------------------------------------------------------------------------------------------


void OnTick()
  {
//----------------------------------------------------------------------------------------------------------------------
   bool temosNovaVela = TemosNovaVela();
   bool temosNovaVela_M1 = TemosNovaVela_M1();
   gale_efetuado = 0;
   CopyBuffer(ifr_Handle,0,0,4,ifr_Buffer);
   ArraySetAsSeries(ifr_Buffer,true);
   CopyRates(_Symbol,_Period,0,4,velas);  
   ArraySetAsSeries(velas,true);   
   SymbolInfoTick(_Symbol,tick);
   ultimo_tick = velas[0].close;
   spread      = velas[0].spread;        



   Comment ("Robô""\nNº mágico : ", magic_number_set);

//-------------------------------------------------------------------------------------------------------------------     

      bool compra_fechada = ifr_Buffer[1] < ifr_inferior;  //30                          
      bool venda_fechada = ifr_Buffer[1] > ifr_superior;   //70 
      bool compra_aberta = ifr_Buffer[0] < ifr_inferior;   //30                        
      bool venda_aberta = ifr_Buffer[0] > ifr_superior;    //70          
//-----------------------------------------------------------------

//--------------------------------------------------------------
      bool Comprar = false; 
      bool Vender = false;      
   
   if(estrategia == FECHAMENTO_DO_CANDLE)
     { 
       if(temosNovaVela)
         {
          Comprar =  compra_fechada;                         
          Vender = venda_fechada;          
         }
      
     }
else if(estrategia == CANDLE_ABERTO)
     {
       Comprar =  compra_aberta;                         
       Vender = venda_aberta;   
     } 
//-------------------------------------------------------------------------------------------------------------------------------------------------------     


  VerificaSLTP();
 
   if(liga_martingale == SIM)
     {                
       if(contador_loss < num_loss)
          {
           if(ultimo_loss == true && gale_efetuado==1)
              {              
                volume_atual *= multiplicador_MG;
                contador_loss++;
                
                if(volume_atual>volume_max_MG)
                  { 
                   volume_atual = volume_max_MG;
                  } 
                  gale_efetuado=0;               
               }        
           }
        
        }
      if(ultimo_loss == false|| contador_loss>num_loss)
        {
          volume_atual = num_lotes;
                 
        }
      
    //  if(contador_loss>num_loss){contador_loss=0;}  // zera o contador de perca 
         
        
     
            
////Print("volume atual: ",volume_atual);          
  
       
                 
//----------------------------------------------------------------------------------------------------------------
   if( PositionSelect(_Symbol)==false && spread <=pts_spread)
     {            
      if(Comprar)
        {         
         Compra_a_mercado();
         bool trade_efetuado = true;
         Print("Spread: ",spread);
        } 
      if(Vender)
        {        
         Venda_a_mercado();
        bool trade_efetuado = true;                  
         Print("Spread: ",spread);                
        }
      }    

//-------------------------------------------------------------------------------------------------------------------      
 if(stops_fin == SIM)
    {      
     for(int i= OrdersTotal()-1; i>=0; i--)
      {
       ulong ticket = OrderGetTicket(i);
       string symbol = OrderGetString(ORDER_SYMBOL);
       ulong magic = OrderGetInteger(ORDER_MAGIC);
       double lucro = PositionGetDouble(POSITION_PROFIT);
       
       if(symbol == _Symbol && magic == magic_number_set)
         {
           if(lucro <= - sl_fin)
            {
              FecharPosicao();
              DeletarOrdens();
              Print (":: Limite de perda financeira atingida = $ ",sl_fin);
            }
           if(lucro >= + tk_fin)
            {
               FecharPosicao();
               DeletarOrdens();               
               Print (":: Limite de ganho financeiro atingido = $ ",tk_fin);
            } 
         }
      }        
    }                 

  }  
//+------------------------------------------------------------------+
//|         FUNÇÕES PARA ENVIO DE ORDENS                                                         |
//+------------------------------------------------------------------+

void Compra_a_mercado()
   {
        
      trade.Buy(volume_atual,_Symbol,NormalizeDouble(tick.ask,_Digits),NormalizeDouble(tick.ask - SL*_Point,_Digits),
                  NormalizeDouble(tick.ask + TK*_Point,_Digits));
                  
                                    
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de compra colocada com sucesso!");
        }else
           {
            Print("Erro de execução...", GetLastError());
            ResetLastError();
           }
   }
   
void Venda_a_mercado()
   {
      trade.Sell(volume_atual,_Symbol,NormalizeDouble(tick.bid,_Digits),NormalizeDouble(tick.bid + SL*_Point,_Digits),
                  NormalizeDouble(tick.bid - TK*_Point,_Digits));
                  
            if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)          
        {
            Print("Ordem de venda colocada com sucesso!");
        }else
           {
            Print("Erro de execução...", GetLastError());
            ResetLastError();
           }
   }
   


void FecharPosicao()
   {
      for(int i= PositionsTotal()-1; i>=0; i--)
        {
          string symbol = PositionGetSymbol(i);
          ulong magic = PositionGetInteger(POSITION_MAGIC);
          if(symbol == _Symbol && magic == magic_number_set)
            {
              ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
              if(trade.PositionClose(PositionTicket, pts_desvio))
                {
                 Print ("Fechamento de Posições realizado com sucesso, ResultRetcode = ",trade.ResultRetcode(),"   RetcodeDescription = ",trade.ResultRetcodeDescription());                       
                }
             else
                {
                 Print ("Fechamento de Posições com falha, ResultRetcode = ",trade.ResultRetcode(),"   RetcodeDescription = ",trade.ResultRetcodeDescription());                       
                }   
            }
         }
    }
    
void DeletarOrdens()
   {
     for(int i= OrdersTotal()-1; i>=0; i--)
      {
       ulong ticket = OrderGetTicket(i);
       string symbol = OrderGetString(ORDER_SYMBOL);
       ulong magic = OrderGetInteger(ORDER_MAGIC);
       if(symbol == _Symbol && magic == magic_number_set)
         {
           if(trade.OrderDelete(ticket))
             {
               Print ("Ordens Deletadas com sucesso, ResultRetcode = ",trade.ResultRetcode(),"   RetcodeDescription = ",trade.ResultRetcodeDescription());                       
             }
           else
             {
               Print ("Ordens Deletadas com falha, ResultRetcode = ",trade.ResultRetcode(),"   RetcodeDescription = ",trade.ResultRetcodeDescription());                       
             }  
         }
      }
   }     
//+------------------------------------------------------------------+
//|                 FUNÇÕES UTEIS                                    |
//+------------------------------------------------------------------+

bool TemosNovaVela()
   {
      static datetime last_time=0;
      datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

      if(last_time==0)
        {
         last_time=lastbar_time;
         return(false);
        }
      if(last_time!=lastbar_time)
        {
         last_time=lastbar_time;
         return(true);
        }
      return(false);
  }

bool TemosNovaVela_M1()
   {
      static datetime last_time=0;
      datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),PERIOD_M1,SERIES_LASTBAR_DATE);

      if(last_time==0)
        {
         last_time=lastbar_time;
         return(false);
        }
      if(last_time!=lastbar_time)
        {
         last_time=lastbar_time;
         return(true);
        }
      return(false);
  } 



//-------------------------------------------------------------------
  
void VerificaSLTP()

{     
   MqlDateTime  inicio_dia;
   datetime hora_atual = TimeCurrent(inicio_dia);
   inicio_dia.hour = 0;
   inicio_dia.min = 0;
   inicio_dia.sec = 0;
   string verifcacao;
   ulong DealNumero=0;
   int comentario;
   double result;
   bool VerifSL= false, VerifTP=false;
   
      HistorySelect(StructToTime(inicio_dia), hora_atual);
      
     for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     { 
       DealNumero = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket
          
      if(HistoryDealGetString(DealNumero , DEAL_SYMBOL) == string(_Symbol))
      //&&PositionGetInteger(POSITION_MAGIC) == magicNumber)
      { 
      if((HistoryDealGetInteger(DealNumero,DEAL_ENTRY)==DEAL_ENTRY_OUT))
      { comentario  = HistoryDealGetInteger(DealNumero,DEAL_REASON);
         if(comentario == 4)
            { VerifSL = true;
               break;}
      }
     }
    }
    if(VerifSL){
    if(DealNumero!=ticket_comentario_SL_antigo){
       ultimo_loss=true;                                     // variável confirmação do martingale
       gale_efetuado=1;                                     // intertravamento contador do volume de gale
       ticket_comentario_SL_antigo=DealNumero; 
       Print(EnumToString((ENUM_DEAL_REASON)comentario)," ",ticket_comentario_SL_antigo);
       }}
     
     for(int i = HistoryDealsTotal() - 1; i >= 0; i--){
      DealNumero = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket  
      if(HistoryDealGetString(DealNumero , DEAL_SYMBOL) == string(_Symbol)){
       
      if((HistoryDealGetInteger(DealNumero,DEAL_ENTRY)==DEAL_ENTRY_OUT)){ 
      result  = HistoryDealGetDouble(DealNumero,DEAL_PROFIT);
      if(result>0 )
      VerifTP= true;
      break;}
     }
    }
      if (VerifTP){
      if(DealNumero!=ticket_comentario_TP_antigo){
       ultimo_loss=false;
       ticket_comentario_TP_antigo=DealNumero;}  
   }
  }

 
 /*      
 
 void OnTradeTransaction(const MqlTradeTransaction & trans,
                        const MqlTradeRequest & request,
                        const MqlTradeResult & result)
  {     
     for(int i= OrdersTotal()-1; i>=0; i--)
      {
       ulong ticket = OrderGetTicket(i);
       string symbol = OrderGetString(ORDER_SYMBOL);
       ulong magic = OrderGetInteger(ORDER_MAGIC);
       if(symbol == _Symbol && magic == magic_number_set)
         {
          if (HistoryDealSelect(trans.deal))
            {
             ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY) HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
             ENUM_DEAL_REASON deal_reason = (ENUM_DEAL_REASON) HistoryDealGetInteger(trans.deal, DEAL_REASON);
         
              if(EnumToString(deal_entry) == "DEAL_ENTRY_OUT")
                 {
                  if(EnumToString(deal_reason) == "DEAL_REASON_SL") 
                  {
                     Print("Loss!!! ",_Symbol);
                     ultimo_loss = true;
                     gale_efetuado = 0;
                     contador_loss +=1;
                     Print("Numero de Loss seguidos: ",contador_loss);                     
                  }
                   if(EnumToString(deal_reason) == "DEAL_REASON_TP")
                  {
                     Print("Gain!!! ",_Symbol);
                     ultimo_loss = false;
                     gale_efetuado = 1;                     
                     contador_loss =0;

                     Print("Numero de Loss seguidos: ",contador_loss);                     
                  }  
                } 
            }      

         }
      }
   }
 */    
           
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
           




















//void ResultadoUltimoTrade(ulong magic_number_set)
//  {
//   datetime inicio, fim;
//   double resultado;
//   ulong ticket;
//
//   //Obtenção do Histórico
//   MqlDateTime inicio_struct;
//   fim = TimeCurrent(inicio_struct);
//   inicio_struct.hour = 0;
//   inicio_struct.min  = 0;
//   inicio_struct.sec  = 0;
//   inicio = StructToTime(inicio_struct);
//   HistorySelect(inicio, fim);
//
//
//   for(int i=HistoryDealsTotal()-1; i>=0; i--)
//     {
//      ticket = HistoryDealGetTicket(i);
//      if(ticket > 0)
//        {
//         if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol
//            && HistoryDealGetInteger(ticket, DEAL_MAGIC) == magic_number_set)
//           {
//            resultado = HistoryDealGetDouble(ticket, DEAL_PROFIT);
//            Print("Resultado: ", resultado);
//            break;
//           }
//        }
//     }
//  }
// 