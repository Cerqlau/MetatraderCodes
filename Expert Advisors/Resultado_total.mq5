//+------------------------------------------------------------------+
//|                                              Resultado_total.mq5 |
//|                                  Copyright 2020, Lauro Cerqueira |
//|                    https://www.mql5.com/pt/users/laurorcerqueira |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lauro Cerqueira"
#property link      "https://www.mql5.com/pt/users/laurorcerqueira"
#property version   "1.00"

//inputs para verificação


input group   "VerifSLrole Financeiro"
input double   iLucromax      = 0;                              //Lucro máximo em operações. 0-Desativa a função
input double   iPerdamax      = 0;                              //Prejuízo máximo em operações. 0-Desativa a função
input double   iGanhomax      = 0;                              //Lucro máximo diário. 0-Desativa a função
input double   iLossmax       = 0;                              //Prejuízo máximo diário. 0-Desativa a função

#define magicNumber =123456789;                                // Magic Number do EA

#include <Trade/SymbolInfo.mqh>
CSymbolInfo simbolo;  

ulong  ticket_comentario_SL_antigo;
ulong  ticket_comentario_TP_antigo;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ticket_comentario_SL_antigo= 0;
   ticket_comentario_TP_antigo= 0;
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  ObjectsDeleteAll(0,-1,-1);
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
 
 // Atualização dos dados do ativo
   if(!simbolo.RefreshRates())
      return; 
  
    Comment(Resultados());
         VerificaSLTP();     
      
  
//---
   
  }
//+------------------------------------------------------------------+
  string Resultados()
{
  
  ulong TicketNumero=0;
  long  Tipodeordem, Transacao;
  double LucrodaOrdem=0,lucro = 0, perda = 0,Total=0;
  string MeuSimbolo="";
  string PosicaoDirecao="";
  string Meuresultado="";
   
  
 
  
  HistorySelect(0,TimeCurrent());

  for(uint i=0;i<HistoryDealsTotal();i++)
  { double resultado =0;
        if((TicketNumero=HistoryDealGetTicket(i))>0)
        if(HistoryDealGetString(TicketNumero, DEAL_SYMBOL) == string(_Symbol))
        {
        MeuSimbolo = HistoryDealGetString(TicketNumero,DEAL_SYMBOL);
        LucrodaOrdem=HistoryDealGetDouble(TicketNumero,DEAL_PROFIT);
        Tipodeordem=HistoryDealGetInteger(TicketNumero,DEAL_TYPE);
        Transacao=HistoryDealGetInteger(TicketNumero,DEAL_ENTRY);
        
        if(Transacao == DEAL_ENTRY_OUT || Transacao == DEAL_ENTRY_INOUT)
        {
         if(LucrodaOrdem < 0)
               perda += -LucrodaOrdem;
            else
               lucro += LucrodaOrdem;
         
        Total =  lucro- perda;
         Meuresultado = Meuresultado + "TICKET  " +TicketNumero+" SIMBOLO:   " +MeuSimbolo+"  TIPO ORDEM:  " +EnumToString((ENUM_POSITION_TYPE)Tipodeordem)+"  Lucro  "+LucrodaOrdem+
                       
                       "   LUCRO TOTAL => " +Total+ "\n";
              
          
         
              
              
                
           }
        }
     }
                                                  
   if(lucro >= iLucromax && iLucromax > 0) // verficiação de lucro máxima nas operações e remoção do EA
      {Alert(" Atenção atingido o LUCRO máximo em operações determinado");}
   if(perda >= iPerdamax && iPerdamax > 0) // verficiação de perca maxima nas operações ou lucro máximo do dia e remoção do EA
     {Alert(" Atenção atingido o PREJUÍZO máximo em operaçõeso determinado" );}
   if(Total <= iLossmax * -1 && iLossmax > 0) // verficiação de perca maxima do dia máximo do dia e remoção do EA
     {Alert(" Atenção atingido o PREJUÍZO máximo diário determinado" );}
   if(Total >= iGanhomax && iGanhomax > 0) // verficiação de perca maxima nas operações ou lucro máximo do dia e remoção do EA
     {MessageBox(" Atenção atingido o LUCRO máximo do dia determinado");}



     return Meuresultado;
}

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
   int comentario;
   bool VerifSL= false, VerifTP=false;
   
      HistorySelect(StructToTime(inicio_dia), hora_atual);
      
     for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
     { 
       DealNumero = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket
          
      if(HistoryDealGetString(DealNumero , DEAL_SYMBOL) == string(_Symbol))
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
     ticket_comentario_SL_antigo=DealNumero; 
       Print("Novo SL, ticket=> "+ticket_comentario_SL_antigo);}}
     
     for(int i = HistoryDealsTotal() - 1; i >= 0; i--){
      DealNumero = HistoryDealGetTicket(i); // index do último negocio e armazena em ticket  
      if(HistoryDealGetString(DealNumero , DEAL_SYMBOL) == string(_Symbol)){ 
      if((HistoryDealGetInteger(DealNumero,DEAL_ENTRY)==DEAL_ENTRY_OUT)){ 
      comentario  = HistoryDealGetInteger(DealNumero,DEAL_REASON);
      if(comentario == 5){
        VerifTP= true;
        break;
      }
     }
    }
   }
    if (VerifTP){
    if(DealNumero!=ticket_comentario_TP_antigo){
       ticket_comentario_TP_antigo=DealNumero;
       Print("Novo TP, ticket=> "+ticket_comentario_TP_antigo);
       }}
 }
   