//+------------------------------------------------------------------+
//|                                   Copyright 2020, Julio Monteiro |
//|                     https://www.mql5.com/en/users/havok2k/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Julio Monteiro"
#property link      "https://www.mql5.com/en/users/havok2k/seller"
#property version   "1.00"
//+------------------------------------------------------------------+
struct S_DEAL
{
   datetime        Time;
   string          Symbol;
   ulong           Ticket;
   ENUM_DEAL_TYPE  Type;
   ENUM_DEAL_ENTRY Direction;
   double          Volume;
   double          Price;
   double          Commission;
   double          Profit;
   long            Magic;
};
//+------------------------------------------------------------------+
typedef void (*TDealCheckerCallback)(S_DEAL &deal);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ForEachDeal(datetime        time,
                 string          symbol,
                 ulong           magic,
                 TDealCheckerCallback callback)
{
   S_DEAL   deal;

   ResetLastError();
   if (!HistorySelect(time, TimeCurrent())) {
      Print("===> ERROR: ", _LastError, " LINE: ", __LINE__);
      return false;
   }

   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
   {
      if ((deal.Ticket = HistoryDealGetTicket(i)) > 0)
      {
         deal.Symbol     = HistoryDealGetString(deal.Ticket,  DEAL_SYMBOL);
         deal.Magic      = HistoryDealGetInteger(deal.Ticket, DEAL_MAGIC);
         deal.Type       = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal.Ticket, DEAL_TYPE);
         deal.Direction  = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal.Ticket, DEAL_ENTRY);
         deal.Time       = (datetime)HistoryDealGetInteger(deal.Ticket, DEAL_TIME);
         deal.Price      = HistoryDealGetDouble(deal.Ticket,  DEAL_PRICE);
         deal.Commission = HistoryDealGetDouble(deal.Ticket,  DEAL_COMMISSION);
         deal.Profit     = HistoryDealGetDouble(deal.Ticket,  DEAL_PROFIT);

         if (deal.Magic     == magic  || magic  == 0)
         if (deal.Symbol    == symbol || symbol == NULL || symbol == "")
         if (deal.Type      == DEAL_TYPE_BUY  || deal.Type == DEAL_TYPE_SELL)
   		if (deal.Direction == DEAL_ENTRY_IN
   		||  deal.Direction == DEAL_ENTRY_OUT
   		||  deal.Direction == DEAL_ENTRY_INOUT
   		||  deal.Direction == DEAL_ENTRY_OUT_BY)
         {
            callback(deal);
         }
      }
   }
   return true;
}
