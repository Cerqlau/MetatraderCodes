//+------------------------------------------------------------------+
//|                                                   Resultados.mq5 |
//|                                                  Thiago Oliveira |
//|                                           thiago_aof@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Oliveira"
#property link      "thiago_aof@hotmail.com"
#property version   "1.00"

enum e_meta
  {
   Diario  = 0,  // Diária
   Semanal = 1,  // Semanal
   Mensal  = 2   // Mensal
  };

input  ulong  MagicNumber = 1704;        // Magic number do Expert
input  e_meta EscMeta     = Diario;      // Análise das metas
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   datetime start = 0;

   switch(EscMeta)
     {
      case Diario:
         start = iTime(_Symbol,PERIOD_D1,0);
         break;
      case Semanal:
         start = iTime(_Symbol,PERIOD_W1,0);
         break;
      case Mensal:
         start = iTime(_Symbol,PERIOD_MN1,0);
         break;
     }

   HistorySelect(start,TimeCurrent());
   int    total = HistoryDealsTotal();
   double lucro = 0;

   if(total>0)
      for(int i=0; i<total; i++)
        {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
            continue;

         if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=MagicNumber)
            continue;

         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol)
            continue;

         lucro += HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_SWAP);
        }

   printf("Lucro %s do expert %d no ativo %s: %.2f",EnumToString((e_meta)EscMeta),MagicNumber,_Symbol,lucro);
   ExpertRemove();
  }
//+------------------------------------------------------------------+
