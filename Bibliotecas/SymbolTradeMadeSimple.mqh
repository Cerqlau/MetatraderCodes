//+-------------------------------------------------------------------------------------------------+
//|                                                                        Symbol Trade Made Simple |
//|                                                                     2019-2020 - Litoral Trading |
//|                                                        MQL5: www.mql5.com/pt/users/thiagoduarte |
//|                                                         Website: https://www.litoraltrading.com |
//|                                                                                                 |
//| Changelog:                                                                                      |
//|                                                                                                 |
//| 26/Oct/2020 - v1.15:                                                                            |
//|                                                                                                 |
//|             Added:                                                                              |
//|             - CheckStrategyTester - check if in strategy tester.                                |
//|             - CandeOpen - return candle open price with shift.                                  |
//|             - CandeClose - return candle close price with shift.                                |
//|             - CandeHigh - return candle high price with shift.                                  |
//|             - CandeLow - return candle low price with shift.                                    |
//|             - ChartGetScale - return scale of the chart.                                        |
//|             - AccountCheckReal - check if account is real or not (boolean).                     |
//|             - SymbolFilling - return symbol filling type as string.                             |
//|             - SymbolOpenPositionsBars - return the bars numbers (candles) from all open trades. |
//|             - SymbolOpenPositionsCloseAfterSeconds - close all trades after specified seconds.  |
//|                                                                                                 |
//|             Changed:                                                                            |
//|             - Nothing.                                                                          |
//|                                                                                                 |
//|             Fixed:                                                                              |
//|             - Nothing.                                                                          |
//|                                                                                                 |
//| Do you have a idea to this extension? Please tell me!                                           |
//| THIS LIBRARY IS RESULT OF HARD WORK. PLEASE GIVE HONEST STARS.                                  |
//+-------------------------------------------------------------------------------------------------+

#include <Trade\OrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\TradeAlt.mqh>

COrderInfo   myorder;
CTradeAlt    mytrade;
CAccountInfo myaccount;

MqlDateTime acc_time;
datetime    acc_tm;
string      ErrorMsg;
double      OpenPercentage, LastPrice;

int TradeFromHour = 01, TradeFromMinute = 0;
int TradeToHour   = 10, TradeToMinute   = 0;
datetime StartTradeTime = 0, EndTradeTime = 0, LastDate;

//+------------------------------------------------------------------+
//| PENDING ORDERS                                                   |
//+------------------------------------------------------------------+
int SymbolPendingOrdersTotal(const string symbol)
  {
    int PendingTotal = 0;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol) {PendingTotal++;}
          }
      }
    return(PendingTotal);
  }

//+------------------------------------------------------------------+
//| NUMBER OF SPECIFIC PENDING ORDERS BY COMMENT                     |
//+------------------------------------------------------------------+
int SymbolPendingOrdersSpecific(const string comment, const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    int PendingTotal = 0;
    string c_ = comment;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                if (myorder.Comment() == c_) {PendingTotal++;}
              }
          }
      }
    return(PendingTotal);
  }

//+------------------------------------------------------------------+
//| NUMBER OF SPECIFIC PENDING ORDERS BY COMMENT AND TYPE            |
//+------------------------------------------------------------------+
int SymbolPendingOrdersSpecificType(const string symbol, const string comment, ENUM_ORDER_TYPE ord_tipo)
  {
    int PendingTotal = 0;
    string c_ = comment;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                if (myorder.OrderType() == ord_tipo)
                  {
                    if (myorder.Comment() == c_) {PendingTotal++;}
                  }
              }
          }
      }
    return(PendingTotal);
  }

//+------------------------------------------------------------------+
//| NUMBER OF SPECIFIC TYPE OF PENDING ORDERS                        |
//+------------------------------------------------------------------+
int SymbolPendingOrdersType(const string symbol, const ENUM_ORDER_TYPE ord_type)
  {
    int PendingTotal = 0;
    long _ttt;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                myorder.InfoInteger(ORDER_TYPE,_ttt);
                if (_ttt == ord_type) {PendingTotal++;}
              }
          }
      }
    return(PendingTotal);
  }

//+------------------------------------------------------------------+
//| CLOSE SPECIFIC PENDIG ORDER BY COMMENT                           |
//+------------------------------------------------------------------+
void SymbolPendingOrderCloseSpecific(const string symbol, const string comment, string ErrorPrint="Error when closing penidng order specific")
  {
    string c_ = comment;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                if (myorder.Comment() == c_) {if (!mytrade.OrderDelete(OrderGetTicket(i))) {Print((string)GetLastError()+": "+ErrorPrint);};}
              }
          }
      }
  }

//+------------------------------------------------------------------+
//| CHECK IF THE SPECIFIC PRICE IS OCCUPIED BY A PENDING ORDER       |
//+------------------------------------------------------------------+
bool SymbolCheckPriceUsed(string symbol, double _price_, string comment="")
  {
    string c_ = comment;
    //bool result_ = false;
    int QtdUsed = 0;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
             {
               //if (myorder.Comment() == c_)
               //  {
                   if (myorder.PriceOpen() == _price_) {QtdUsed++;}
                   
               //  }
             }
          }
      }
    //Print(((QtdUsed>0) ? "Preço usado" : "Preço NÃO usado")+"  |  "+_price_);
    return((QtdUsed>0) ? true : false);
  }

//+------------------------------------------------------------------+
//| PENDING VOLUME                                                   |
//+------------------------------------------------------------------+
double SymbolPendingOrdersVolume(const string symbol)
  {
    double PendingVolume = 0;
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
            {
              PendingVolume+=OrderGetDouble(ORDER_VOLUME_INITIAL);
            }
          }
      }
    return(PendingVolume);
  }

//+------------------------------------------------------------------+
//| OPEN POSITIONS                                                   |
//+------------------------------------------------------------------+
int SymbolOpenPositionsTotal(const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    int OpenTotal = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol) {OpenTotal++;}
      }
    return(OpenTotal);
  }

//+------------------------------------------------------------------+
//| OPEN VOLUME                                                      |
//+------------------------------------------------------------------+
double SymbolOpenPositionsVolume(const string symbol)
  {
    double OpenVolume = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == symbol)
          {
            OpenVolume+=PositionGetDouble(POSITION_VOLUME);
          }
      }
    return(OpenVolume);
  }

//+------------------------------------------------------------------+
//| OPEN PROFIT                                                      |
//+------------------------------------------------------------------+
double SymbolOpenResult(const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    double OpenResult = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol)
          {
            OpenResult+=(PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP)+PositionGetDouble(POSITION_COMMISSION));
          }
      }
    return(NormalizeDouble(OpenResult,2));
  }

//+------------------------------------------------------------------+
//| OPEN PROFIT                                                      |
//+------------------------------------------------------------------+
double SymbolOpenResultSpecific(ENUM_POSITION_TYPE PosType, const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    double OpenResultSpecific = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol && PositionGetInteger(POSITION_TYPE) == PosType)
          {
            OpenResultSpecific+=(PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP)+PositionGetDouble(POSITION_COMMISSION));
          }
      }
    return(NormalizeDouble(OpenResultSpecific,2));
  }

//+------------------------------------------------------------------+
//| ACCOUNT BALANCE PERCENTAGE FROM OPEN POSITIONS                   |
//+------------------------------------------------------------------+
double SymbolOpenPercentage(const string symbol)
  {
    if (AccountInfoDouble(ACCOUNT_BALANCE) > 0) // This condition prevent from zero divide error if balance = zero
      {OpenPercentage = (SymbolOpenResult(symbol) / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;} else {OpenPercentage = 0;}
    return(NormalizeDouble(OpenPercentage,2));
  }

//+------------------------------------------------------------------+
//| OPEN PIPS                                                        |
//+------------------------------------------------------------------+
double SymbolOpenPips(const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    double OpenPips = 0, pp = 0;
    double symbol_point = SymbolInfoDouble(__symbol,SYMBOL_POINT);
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol)
          {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {pp = (SymbolInfoDouble(__symbol,SYMBOL_ASK) - PositionGetDouble(POSITION_PRICE_OPEN)) / symbol_point / 10;}
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {pp = (PositionGetDouble(POSITION_PRICE_OPEN) - SymbolInfoDouble(symbol,SYMBOL_BID)) / symbol_point / 10;}
            OpenPips+=pp;
          }
      }
    return(OpenPips);
  }

//+------------------------------------------------------------------+
//| NUMBER OF SPECIFIC OPEN POSITION BY COMMENT                      |
//+------------------------------------------------------------------+
int SymbolOpenPositionsSpecific(const string comment, const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    int OpenTotal = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol)
          {
            if (PositionGetString(POSITION_COMMENT) == comment) {OpenTotal+=1;}
          }
      }
    return(OpenTotal);
  }

//+------------------------------------------------------------------+
//| NUMBER OF SPECIFIC OPEN POSITION BY COMMENT AND TYPE             |
//+------------------------------------------------------------------+
int SymbolOpenPositionsSpecificType(string comment, ENUM_POSITION_TYPE pos_type, string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    int OpenTotal = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol)
          {
            if (PositionGetInteger(POSITION_TYPE) == pos_type)
              {
                if (PositionGetString(POSITION_COMMENT) == comment) {OpenTotal+=1;}
              }
          }
      }
    return(OpenTotal);
  }

//+------------------------------------------------------------------+
//| CLOSE OPEN POSITIONS                                             |
//+------------------------------------------------------------------+
void SymbolOpenPositionsClose(const string symbol, string ErrorPrint="Error when closing open positions")
  {
    for (int i=PositionsTotal(); i>=0; i--)
     {
       if (PositionGetSymbol(i) == symbol)
         {
           if (!mytrade.PositionClose(PositionGetTicket(i))) {Print(ErrorPrint);}
         }
     }
  }

//+------------------------------------------------------------------+
//| CLOSE OPEN POSITIONS BY COMMENT                                  |
//+------------------------------------------------------------------+
void SymbolOpenPositionsCloseSpecific(const string symbol, const string comment, string ErrorPrint="Error when closing open positions")
  {
    for (int i=PositionsTotal(); i>=0; i--)
     {
       if (PositionGetSymbol(i) == symbol)
         {
           if (PositionGetString(POSITION_COMMENT) == comment) {mytrade.PositionClose(PositionGetTicket(i));}
         }
     }
  }

//+------------------------------------------------------------------+
//| CLOSE PARTIAL OPEN POSITIONS                                     |
//+------------------------------------------------------------------+
void SymbolOpenPositionsClosePartial(const string symbol, const double _volume, bool ProtectMinimalLot=false, string ErrorPrint="Error when closing partial open positions")
  {
    for (int i=PositionsTotal(); i>=0; i--)
     {
       if (PositionGetSymbol(i) == symbol)
         {
           if (ProtectMinimalLot == false)
             {if (!mytrade.PositionClosePartial(PositionGetTicket(i),_volume)) {ErrorMsg = (ErrorPrint+" | "+(string)GetLastError());}}
           else
             {
               if (PositionGetDouble(POSITION_VOLUME) > SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN))
                 {if (!mytrade.PositionClosePartial(PositionGetTicket(i),_volume)) {ErrorMsg = (ErrorPrint+" | "+(string)GetLastError());}}
             }
         }
     }
  }

//+------------------------------------------------------------------+
//| BREAKEVEN OPEN POSITIONS                                         |
//+------------------------------------------------------------------+
void SymbolOpenPositionsBreakevenAll(const string symbol, bool CalculateSpread, string ErrorPrint="Error when breakeven all positions")
  {
    int spread_ = (int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
    for (int i=PositionsTotal(); i>=0; i--)
     {
       if (PositionGetSymbol(i) == symbol)
         {
           if (CalculateSpread == true)
             {
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {if (!mytrade.PositionModify(PositionGetTicket(i),PositionGetDouble(POSITION_PRICE_OPEN)-(spread_*_Point),PositionGetDouble(POSITION_TP)))  {Print(ErrorPrint+" | "+(string)GetLastError());}}
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {if (!mytrade.PositionModify(PositionGetTicket(i),PositionGetDouble(POSITION_PRICE_OPEN)+(spread_*_Point),PositionGetDouble(POSITION_TP)))  {Print(ErrorPrint+" | "+(string)GetLastError());}}
             }
             else
           {if (!mytrade.PositionModify(PositionGetTicket(i),PositionGetDouble(POSITION_PRICE_OPEN),PositionGetDouble(POSITION_TP)))  {Print(mytrade.ResultComment()+" | "+(string)GetLastError());} else {ErrorMsg = "Ok";}}
         }
     }
  }

//+------------------------------------------------------------------+
//| BREAKEVEN SPECIFIC POSITION                                      |
//+------------------------------------------------------------------+
void SymbolOpenPositionsBreakeven(const string symbol, const double _ticket, bool CalculateSpread, string ErrorPrint="Error when breakeven position")
  {
    int spread_ = (int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
    for (int i=PositionsTotal(); i>=0; i--)
     {
       if (PositionGetSymbol(i) == symbol)
         {
           if (CalculateSpread == true)
             {
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {if (!mytrade.PositionModify(PositionGetTicket((int)_ticket),PositionGetDouble(POSITION_PRICE_OPEN)-(spread_*_Point),PositionGetDouble(POSITION_TP)))  {Print(ErrorPrint+" | "+(string)GetLastError());}}
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {if (!mytrade.PositionModify(PositionGetTicket((int)_ticket),PositionGetDouble(POSITION_PRICE_OPEN)+(spread_*_Point),PositionGetDouble(POSITION_TP)))  {Print(ErrorPrint+" | "+(string)GetLastError());}}
             }
         }
     }
  }

//+------------------------------------------------------------------+
//| CLOSE ALL PENDING ORDERS                                             |
//+------------------------------------------------------------------+
void SymbolPendingOrdersCloseAll(const string symbol, string ErrorPrint="Error when close all pending orders")
  {
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                if (!mytrade.OrderDelete(OrderGetTicket(i))) {Print(ErrorPrint);}
              }
          }
      }
  }

//+------------------------------------------------------------------+
//| CLOSE SELL PENDING ORDERS                                        |
//+------------------------------------------------------------------+
void SymbolPendingOrdersCloseSell(const string symbol, string ErrorPrint="Error when closing sell pending orders")
  {
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                if (myorder.OrderType() == ORDER_TYPE_SELL_LIMIT || myorder.OrderType() == ORDER_TYPE_SELL_STOP)
                {if (!mytrade.OrderDelete(OrderGetTicket(i))) {Print(ErrorPrint);}}
              }
          }
      }
  }

//+------------------------------------------------------------------+
//| CLOSE SELL PENDING ORDERS                                        |
//+------------------------------------------------------------------+
void SymbolPendingOrdersCloseBuy(const string symbol, string ErrorPrint="Error when closing buy pending orders")
  {
    for (int i=OrdersTotal(); i>=0; i--)
      {
        if (myorder.Select(OrderGetTicket(i)))
          {
            if (myorder.Symbol() == symbol)
              {
                if (myorder.OrderType() == ORDER_TYPE_BUY_LIMIT || myorder.OrderType() == ORDER_TYPE_BUY_STOP)
                {if (!mytrade.OrderDelete(OrderGetTicket(i))) {Print(ErrorPrint);}}
              }
          }
      }
  }

//+------------------------------------------------------------------+
//| RISK REWARD STOP LOSS                                            |
//+------------------------------------------------------------------+
// Risk x Reward from Stop Loss
// Example: SymbolRiskRewardSL( _Symbol, ticket, position = true | order = false)
// Only after determine SL and TP the risk/reward will be calculated.
double SymbolRiskRewardSL(const string symbol, const int _ticket, const bool position, int digits_=2)
  {
    double risk = 0;
    // Open positions
    if (position == true)
      {
        if (PositionSelectByTicket(_ticket))
          {
            if (PositionGetString(POSITION_SYMBOL) == symbol)
              {
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                  {
                    risk = ((PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_SL)) / (PositionGetDouble(POSITION_TP)-PositionGetDouble(POSITION_PRICE_OPEN)));
                  }
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                  {
                    risk = ((PositionGetDouble(POSITION_SL)-PositionGetDouble(POSITION_PRICE_OPEN)) / (PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_TP)));
                  }
              }
          }
      }
    // Pending orders
    else
      {
        if (OrderSelect(_ticket))
          {
            if (OrderGetString(ORDER_SYMBOL) == symbol)
              {
                if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP)
                  {
                    risk = ((OrderGetDouble(ORDER_PRICE_OPEN)-OrderGetDouble(ORDER_SL)) / (OrderGetDouble(ORDER_TP)-OrderGetDouble(ORDER_PRICE_OPEN)));
                  }
                if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP)
                  {
                    risk = ((OrderGetDouble(ORDER_SL)-OrderGetDouble(ORDER_PRICE_OPEN)) / (OrderGetDouble(ORDER_PRICE_OPEN)-OrderGetDouble(ORDER_TP)));
                  }
              }
          }
      }
    return(NormalizeDouble(risk,digits_));
  }

//+------------------------------------------------------------------+
//| RISK REWARD TAKE PROFIT                                          |
//+------------------------------------------------------------------+
// Risk x Reward from Stop Loss
// Example: SymbolRiskRewardSL( _Symbol, ticket, position = true | order = false)
// Only after determine SL and TP the risk/reward will be calculated.
double SymbolRiskRewardTP(const string symbol, const int _ticket, const bool position, int digits_=2)
  {
    double risk = 0;
    // Open positions
    if (position == true)
      {
        if (PositionSelectByTicket(_ticket))
          {
            if (PositionGetString(POSITION_SYMBOL) == symbol)
              {
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                  {
                    risk = ((PositionGetDouble(POSITION_TP)-PositionGetDouble(POSITION_PRICE_OPEN)) / (PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_SL)));
                  }
                if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                  {
                    risk = ((PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_TP)) / (PositionGetDouble(POSITION_SL)-PositionGetDouble(POSITION_PRICE_OPEN)));
                  }
              }
          }
      }
    // Pending orders
    else
      {
        if (OrderSelect(_ticket))
          {
            if (OrderGetString(ORDER_SYMBOL) == symbol)
              {
                if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP)
                  {
                    risk = ((OrderGetDouble(ORDER_TP)-OrderGetDouble(ORDER_PRICE_OPEN)) / (OrderGetDouble(ORDER_PRICE_OPEN)-OrderGetDouble(ORDER_SL)));
                  }
                if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP)
                  {
                    risk = ((OrderGetDouble(ORDER_PRICE_OPEN)-OrderGetDouble(ORDER_TP)) / (OrderGetDouble(ORDER_SL)-OrderGetDouble(ORDER_PRICE_OPEN)));
                  }
              }
          }
      }
    return(NormalizeDouble(risk,digits_));
  }

//+------------------------------------------------------------------+
//| CANDLE TIME                                                      |
//+------------------------------------------------------------------+
string CandleTime(const string symbol_, ENUM_TIMEFRAMES period_, const string Comment_="Candle: ", const string MsgMarketClosed="Market closed")
  {
    int left_time;
    string sTime, sCurrentTime;
    datetime time_actual[];
    CopyTime(symbol_,period_,0,1,time_actual);
    sCurrentTime = TimeToString(SymbolInfoInteger(symbol_,SYMBOL_TIME),TIME_SECONDS);
    ArraySetAsSeries(time_actual,true);
    left_time = PeriodSeconds(period_)-(int)(SymbolInfoInteger(symbol_,SYMBOL_TIME)-time_actual[0]);
    
    if (AccountDayOfWeekInt() == 5 && sCurrentTime > "22:55:00")
      {
        sTime = MsgMarketClosed;
      }
    else
      {
        sTime = Comment_+TimeToString(left_time,TIME_SECONDS);
      }
    return(sTime);
  }

//+------------------------------------------------------------------+
//| IF MARKET CLOSED                                                 |
//+------------------------------------------------------------------+
bool IfMarketClosed(string symbol)
  {
    bool MarketClosed = false;
    if (AccountDayOfWeekInt() == 5 && TimeToString(SymbolInfoInteger(symbol,SYMBOL_TIME),TIME_SECONDS) > "22:55:00") {MarketClosed = true;} else {MarketClosed = false;}
    return(MarketClosed);
  }

//+------------------------------------------------------------------+
//| ACCOUNT MODE                                                     |
//+------------------------------------------------------------------+
string AccountMode(string StrNet="Netting", string StrHedge="Hedge", string StrExc="Exchange")
  {
    string acc_mode;
    if (AccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING) {acc_mode = StrNet;}
    else if (AccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_EXCHANGE) {acc_mode = StrExc;}
    else if (AccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {acc_mode = StrHedge;}
    return(acc_mode);
  }

//+------------------------------------------------------------------+
//| ACCOUNT TYPE AS STRING                                           |
//+------------------------------------------------------------------+
string AccountType()
  {
    string acc_type;
    if (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO) {acc_type = "Demo";}
    if (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_CONTEST) {acc_type = "Competition";}
    if (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL) {acc_type = "Real";}
    return(acc_type);
  }

//+------------------------------------------------------------------+
//| CHECK IF ACCOUNT IS REAL OR NOT                                  |
//+------------------------------------------------------------------+
bool AccountCheckReal()
  {
    return( (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL) ? true : false );
  }

//+------------------------------------------------------------------+
//| ACCOUNT OPEN RESULT                                              |
//+------------------------------------------------------------------+
double AccountOpenResult()
  {
    double OpenResult = 0;
    for (int i=0; i<=PositionsTotal(); i++)
      {
        PositionSelectByTicket(PositionGetTicket(i));
        OpenResult+=(PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP)+PositionGetDouble(POSITION_COMMISSION));
      }
    return(NormalizeDouble(OpenResult,2));
  }

//+------------------------------------------------------------------+
//| ACCOUNT OPEN RESULT PERCENTAGE                                   |
//+------------------------------------------------------------------+
double AccountOpenPercentage()
  {
    double OpenPercentage_ = (AccountOpenResult() / AccountInfoDouble(ACCOUNT_BALANCE)) * 100;
    return(NormalizeDouble(OpenPercentage_,2));
  }

//+------------------------------------------------------------------+
//| ACCOUNT POSITIONS CLOSE ALL                                      |
//+------------------------------------------------------------------+
bool AccountPositionsClose(string ErrorPrint="Error when closing all account positions")
  {
    bool return_ = true;
    for (int i=0; i<PositionsTotal(); i++)
      {
        if (!mytrade.PositionClose(PositionGetTicket(i))) {Print(ErrorPrint);return_=false;} else {return_=true;}
      }
    return(return_);
  }
//+------------------------------------------------------------------+
//| DAY OF WEEK                                                      |
//+------------------------------------------------------------------+
string AccountDate(const bool YearDay, const bool YearMonth, const bool Year, const string separator)
  {
    TimeToStruct(acc_tm,acc_time);
    string acc_day, acc_month, acc_year;
    
    if (YearDay == true) {acc_day = IntegerToString(acc_time.day);} else {acc_day = "";}
    if (YearMonth == true) {acc_month = IntegerToString(acc_time.mon);} else {acc_month = "";}
    if (Year == true) {acc_year = IntegerToString(acc_time.year);} else {acc_year = "";}
    
    return( ((YearDay) ? acc_day+separator : "")+
            ((YearMonth) ? acc_month+separator : "")+
            ((Year) ? acc_year : ""));
  }

//+------------------------------------------------------------------+
//| MONTH OF YEAR                                                    |
//+------------------------------------------------------------------+
string AccountMonthOfYear(const string _jan="January", const string _feb="Febuary", const string _mar="March", const string _apr="April",
                         const string _may="May", const string _jun="June", const string _jul="July", const string _aug="August",
                          const string _sep="September", const string _oct="October", const string _nov="November", const string _dec="December")
  {
    string acc_month_ok;
    TimeToStruct(TimeCurrent(),acc_time);
    
    switch(acc_time.mon)
      {
        case 1: acc_month_ok = _jan; break;
        case 2: acc_month_ok = _feb; break;
        case 3: acc_month_ok = _mar; break;
        case 4: acc_month_ok = _apr; break;
        case 5: acc_month_ok = _may; break;
        case 6: acc_month_ok = _jun; break;
        case 7: acc_month_ok = _jul; break;
        case 8: acc_month_ok = _aug; break;
        case 9: acc_month_ok = _sep; break;
        case 10: acc_month_ok = _oct; break;
        case 11: acc_month_ok = _nov; break;
        case 12: acc_month_ok = _dec; break;
      }
    
    return(acc_month_ok);
  }

//+------------------------------------------------------------------+
//| DAY OF WEEK STRING                                               |
//+------------------------------------------------------------------+
string AccountDayOfWeek(const string _mon="Monday", const string _tue="Tuesday", const string _wed="Wednesday",
                         const string _thu="Thursday", const string _fri="Friday", const string _sat="Saturday", const string _sun="Sunday")
  {
    string acc_day_ok;
    TimeToStruct(TimeCurrent(),acc_time);
    
    switch(acc_time.day_of_week)
      {
        case 1: acc_day_ok = _mon; break;
        case 2: acc_day_ok = _tue; break;
        case 3: acc_day_ok = _wed; break;
        case 4: acc_day_ok = _thu; break;
        case 5: acc_day_ok = _fri; break;
        case 6: acc_day_ok = _sat; break;
        case 7: acc_day_ok = _sun; break;
      }
    
    return(acc_day_ok);
  }

//+------------------------------------------------------------------+
//| DAY OF WEEK STRING                                               |
//+------------------------------------------------------------------+
int AccountDayOfWeekInt()
  {
    TimeCurrent(acc_time);
    return(acc_time.day_of_week);
  }

//+------------------------------------------------------------------+
//| ACCOUNT HOUR                                                     |
//+------------------------------------------------------------------+
int AccountHour()
  {
    TimeToStruct(TimeCurrent(),acc_time);
    return(acc_time.hour);
  }

//+------------------------------------------------------------------+
//| ACCOUNT MINUTES                                                  |
//+------------------------------------------------------------------+
int AccountMinutes()
  {
    TimeToStruct(TimeCurrent(),acc_time);
    return(acc_time.min);
  }

//+------------------------------------------------------------------+
//| LOCAL HOUR                                                       |
//+------------------------------------------------------------------+
int LocalHour()
  {
    TimeToStruct(TimeLocal(),acc_time);
    return(acc_time.hour);
  }

//+------------------------------------------------------------------+
//| LOCAL MINUTES                                                    |
//+------------------------------------------------------------------+
int LocalMinutes()
  {
    TimeToStruct(TimeLocal(),acc_time);
    return(acc_time.min);
  }

//+------------------------------------------------------------------+
//| GMT HOUR                                                         |
//+------------------------------------------------------------------+
int GMTHour()
  {
    TimeToStruct(TimeGMT(),acc_time);
    return(acc_time.hour);
  }

//+------------------------------------------------------------------+
//| GMT MINUTES                                                      |
//+------------------------------------------------------------------+
int GMTMinutes()
  {
    TimeToStruct(TimeGMT(),acc_time);
    return(acc_time.min);
  }

//+------------------------------------------------------------------+
//| NORMALIZE VOLUME (LOT)                                           |
//+------------------------------------------------------------------+
double SymbolNormalizeVolume(const string symbol, double volume, const bool ShowErrorLog=true)
  {
    double resultado = 0;
    double LoteMin = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
    double LoteMax = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
    double LotePasso = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
    if (ShowErrorLog == true)
      {if (LoteMin == 0 && LoteMax == 0 && LotePasso == 0) {Print("Error on normalize volume!");}}
    if (volume > 0)
      {
        if (LotePasso>0) // Evita bug de inatividade
        {
          volume = MathMax(LoteMin,volume);
          volume = LoteMin+NormalizeDouble((volume-LoteMin)/LotePasso,0)*LotePasso;
          resultado = MathMin(LoteMax,volume);
        }
      }
    else
      {
        resultado = LoteMin;
        double compra_margem= myaccount.FreeMarginCheck(symbol,ORDER_TYPE_BUY,resultado,SymbolInfoDouble(symbol,SYMBOL_ASK));
        double venda_margem = myaccount.FreeMarginCheck(symbol,ORDER_TYPE_SELL,resultado,SymbolInfoDouble(symbol,SYMBOL_BID));
        if (compra_margem < 0 || venda_margem < 0)
          {
            if (resultado > LoteMin)
              {
                resultado = resultado*myaccount.FreeMargin()/(myaccount.FreeMargin()-MathMin(compra_margem,venda_margem));
                resultado = SymbolNormalizeVolume(symbol,resultado,false);
              }
            else {resultado = 0;}
          }
      }
    return(NormalizeDouble(resultado,2));
  }

//+------------------------------------------------------------------+
//| NORMALIZE PRICE                                                  |
//+------------------------------------------------------------------+
double SymbolNormalizePrice(string symbol, double price_)
  {
    int _digits_ = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
    double tick_ = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
    return(NormalizeDouble(MathRound(price_/tick_)*tick_,_digits_));
  }

//+------------------------------------------------------------------+
//| REVERSE SPECIFIC POSITION                                        |
//+------------------------------------------------------------------+
void SymbolPositionReverse(const string symbol, const bool sl_and_tp, const int _ticket)
  {
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionSelectByTicket(_ticket))
        {
        if (PositionGetSymbol(i) == symbol)
          {
            double _sl = (sl_and_tp) ? PositionGetDouble(POSITION_SL) : 0;
            double _tp = (sl_and_tp) ? PositionGetDouble(POSITION_TP) : 0;
            int _id = (int)PositionGetInteger(POSITION_TICKET);
            
            if (!mytrade.PositionClose(_id)) {Print(mytrade.ResultComment());}
            
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
                if (!mytrade.Sell(PositionGetDouble(POSITION_VOLUME),symbol,SymbolInfoDouble(symbol,SYMBOL_BID),_tp,_sl,NULL)) {Print(mytrade.ResultComment());}
              }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
                if (!mytrade.Buy(PositionGetDouble(POSITION_VOLUME),symbol,SymbolInfoDouble(symbol,SYMBOL_ASK),_tp,_sl,NULL)) {Print(mytrade.ResultComment());}
              }
            
          }
        }
      }
  }

//+------------------------------------------------------------------+
//| REVERSE ALL POSITIONS                                            |
//+------------------------------------------------------------------+
void SymbolPositionReverseAll(const string symbol, const bool sl_and_tp)
  {
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == symbol)
          {
            double _sl = (sl_and_tp) ? PositionGetDouble(POSITION_SL) : 0;
            double _tp = (sl_and_tp) ? PositionGetDouble(POSITION_TP) : 0;
            int _id = (int)PositionGetInteger(POSITION_TICKET);
            
            if (!mytrade.PositionClose(_id)) {Print(mytrade.ResultComment());}
            
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
                if (!mytrade.Sell(PositionGetDouble(POSITION_VOLUME),symbol,SymbolInfoDouble(symbol,SYMBOL_BID),_tp,_sl,NULL)) {Print(mytrade.ResultComment());}
              }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
                if (!mytrade.Buy(PositionGetDouble(POSITION_VOLUME),symbol,SymbolInfoDouble(symbol,SYMBOL_ASK),_tp,_sl,NULL)) {Print(mytrade.ResultComment());}
              }
            
          }
      }
  }

//+------------------------------------------------------------------+
//| CORRECT SYMBOL DIGITS                                            |
//+------------------------------------------------------------------+
int SymbolNormalizeDigits(const string symbol) // Return the normalized digit
  {
    int digits_;
    switch ((int)SymbolInfoInteger(symbol,SYMBOL_DIGITS))
      {
        case 0: digits_ = 1;break;
        case 1: digits_ = 1;break;
        case 2: digits_ = 10;break;
        case 3: digits_ = 100;break;
        case 4: digits_ = 1000;break;
        case 5: digits_ = 10000;break;
        default: digits_ = 1;
      }
    return(digits_);
  }

//+------------------------------------------------------------------+
//| CORRECT SYMBOL DIGITS                                            |
//+------------------------------------------------------------------+
void SymbolChartClean(const int chart, const bool RemoveDate, const bool RemovePrice, const bool OneClickTrade)
  {
    ChartSetInteger(chart,CHART_SHOW_ASK_LINE,0,false);
    ChartSetInteger(chart,CHART_SHOW_DATE_SCALE,0,RemoveDate);
    ChartSetInteger(chart,CHART_SHOW_GRID,0,false);
    ChartSetInteger(chart,CHART_SHOW_OHLC,0,false);
    ChartSetInteger(chart,CHART_SHOW_ONE_CLICK,0,OneClickTrade);
    ChartSetInteger(chart,CHART_SHOW_PERIOD_SEP,0,false);
    ChartSetInteger(chart,CHART_SHOW_TRADE_LEVELS,0,false);
    ChartSetInteger(chart,CHART_SHOW_VOLUMES,0,false);
    ChartSetInteger(chart,CHART_SHOW_PRICE_SCALE,0,RemovePrice);
  }

//+------------------------------------------------------------------+
//| SYMBOL TIMEFRAME                                                 |
//+------------------------------------------------------------------+
string SymbolTimeframe(const string daily_="Daily", const string weekly_="Weekly", const string monthly_="Monthly")
  {
    string tf_;
    switch (Period())
      {
        case PERIOD_M1: tf_ = "M1"; break;
        case PERIOD_M2: tf_ = "M2"; break;
        case PERIOD_M3: tf_ = "M3"; break;
        case PERIOD_M4: tf_ = "M4"; break;
        case PERIOD_M5: tf_ = "M5"; break;
        case PERIOD_M6: tf_ = "M6"; break;
        case PERIOD_M10: tf_ = "M10"; break;
        case PERIOD_M12: tf_ = "M12"; break;
        case PERIOD_M15: tf_ = "M15"; break;
        case PERIOD_M20: tf_ = "M20"; break;
        case PERIOD_M30: tf_ = "M30"; break;
        case PERIOD_H1: tf_ = "H1"; break;
        case PERIOD_H2: tf_ = "H2"; break;
        case PERIOD_H3: tf_ = "H3"; break;
        case PERIOD_H4: tf_ = "H4"; break;
        case PERIOD_H6: tf_ = "H6"; break;
        case PERIOD_H8: tf_ = "H8"; break;
        case PERIOD_H12: tf_ = "H12"; break;
        case PERIOD_D1: tf_ = daily_; break;
        case PERIOD_W1: tf_ = weekly_; break;
        case PERIOD_MN1: tf_ = monthly_; break;
      }
    return(tf_);
  }

//+------------------------------------------------------------------+
//| FIX DATETIME SECONDS                                             |
//+------------------------------------------------------------------+
datetime FixDatetimeSeconds(datetime date, const int SecondsToFix, const bool subtract)
  {
    datetime result;
    if (subtract == true) {result = date-SecondsToFix;} else {result = date+SecondsToFix;}
    return(result);
  }

//+------------------------------------------------------------------+
//| FIX DATETIME MINUTES                                             |
//+------------------------------------------------------------------+
datetime FixDatetimeMinutes(datetime date, const int MinutesToFix, const bool subtract)
  {
    datetime result;
    if (subtract == true) {result = date-(MinutesToFix*60);} else {result = date+(MinutesToFix*60);}
    return(result);
  }

//+------------------------------------------------------------------+
//| FIX DATETIME HOURS                                               |
//+------------------------------------------------------------------+
datetime FixDatetimeHours(datetime date, const int HoursToFix, const bool subtract)
  {
    datetime result;
    if (subtract == true) {result = date-(HoursToFix*60*60);} else {result = date+(HoursToFix*60*60);}
    return(result);
  }

//+------------------------------------------------------------------+
//| FIX DATETIME DAYS                                                |
//+------------------------------------------------------------------+
datetime FixDatetimeDays(datetime date, const int DaysToFix, const bool subtract)
  {
    datetime result;
    if (subtract == true) {result = date-((DaysToFix*24)*60*60);} else {result = date+((DaysToFix*24)*60*60);}
    return(result);
  }

//+------------------------------------------------------------------+
//| FIX DATETIME MONTHS                                              |
//+------------------------------------------------------------------+
datetime FixDatetimeMonths(datetime date, const int MonthsToFix, const bool subtract)
  {
    datetime result;
    if (subtract == true) {result = date-(((MonthsToFix*30)*24)*60*60);} else {result = date+((MonthsToFix*24)*60*60);}
    return(result);
  }

//+------------------------------------------------------------------+
//| POSITIONS SWAP TOTAL                                             |
//+------------------------------------------------------------------+
double SymbolOpenPositionsSwap(const string symbol_)
  {
    double swap_ = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == symbol_)
          {
            swap_+=PositionGetDouble(POSITION_SWAP);
          }
      }
    return(swap_);
  }

//+------------------------------------------------------------------+
//| POSITIONS COMISSION TOTAL                                        |
//+------------------------------------------------------------------+
double SymbolPositionsCommissionTotal(const string symbol_)
  {
    double commission_ = 0;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == symbol_)
          {
            commission_+=HistoryDealGetDouble(PositionGetTicket(i),DEAL_COMMISSION);
          }
      }
    return(commission_);
  }

//+------------------------------------------------------------------+
//| PRICE CHANGE IN %                                                |
//+------------------------------------------------------------------+
double SymbolPriceChange(double price1, double price2)
  {
    double PriceChange;
    if (price1 < price2)
      {
        PriceChange = ((price2 - price1) / price2) * 100;
      }
    else
      {
        PriceChange = ((price1 - price2) / price1) * 100;
      }
    return(NormalizeDouble(PriceChange,2));
  }

//+------------------------------------------------------------------+
//| ROUND VALUE                                                      |
//+------------------------------------------------------------------+
int RoundValue(double ValueToRound, int Round)
  {
    int RoundedValue = (int) MathCeil(ValueToRound);
    RoundedValue = (int) (RoundedValue + (Round - MathMod(RoundedValue,Round)));
    return(RoundedValue);
  }

//+------------------------------------------------------------------+
//| NEW CANDLE CHECK                                                 |
//+------------------------------------------------------------------+
bool NewCandleCheck(const string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    bool NewCandle;
    static datetime PrevTime = 0;
    datetime LastTime[1];
    if (CopyTime(__symbol,_Period,0,1,LastTime) == 1 && PrevTime != LastTime[0])
      {
        PrevTime = LastTime[0];
        NewCandle = true;
      }
      else {NewCandle = false;}
    return(NewCandle);
  }

//+------------------------------------------------------------------+
//| HIDE OBJECTS CREATED BY USER                                     |
//+------------------------------------------------------------------+
void ChartObjectsHide(long chart_=0, ENUM_OBJECT ObjectType=-1)
  {
    for (int obj=0; obj<ObjectsTotal(chart_,-1,ObjectType); obj++)
      {
        string nome = ObjectName(chart_,obj,0,-1);
        if (ObjectGetInteger(chart_,nome,OBJPROP_HIDDEN) == false)
          {ObjectSetInteger(chart_,nome,OBJPROP_TIMEFRAMES,PeriodChange());}
      }
  }

//+------------------------------------------------------------------+
//| SHOW HIDDEN OBJECTS                                              |
//+------------------------------------------------------------------+
void ChartObjectsShowHidden(long chart_=0)
  {
    for (int obj=0; obj<=ObjectsTotal(chart_,-1,-1); obj++)
      {
        string nome = ObjectName(chart_,obj,0,-1);
        if (ObjectGetInteger(chart_,nome,OBJPROP_HIDDEN) == false)
          {ObjectSetInteger(chart_,nome,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);}
      }
  }

//+------------------------------------------------------------------+
//| DELETE OBJECTS CREATED BY USER                                   |
//+------------------------------------------------------------------+
void ChartObjectsDeleteAll(long chart_=0)
  {
    //Print(ObjectsTotal(chart_,-1,-1));
    for (int obj=ObjectsTotal(chart_,-1,-1); obj>=0; obj--)
      {
        string nome = ObjectName(chart_,obj,-1,-1);
        if (ObjectGetInteger(chart_,nome,OBJPROP_HIDDEN) == false) {Print("A");ObjectDelete(chart_,nome);}
      }
  }

//+------------------------------------------------------------------+
//| PERIOD CHANGE TO HIDE OBJECT                                     |
//+------------------------------------------------------------------+
int PeriodChange()
  {
    ENUM_TIMEFRAMES PeriodoOk;
    ENUM_TIMEFRAMES PeriodoDestino = PERIOD_M1;
    switch(_Period)
      {
        case PERIOD_M1: PeriodoOk = PERIOD_D1; break;
        case PERIOD_M2: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M3: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M4: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M5: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M6: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M10: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M12: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M15: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M20: PeriodoOk = PeriodoDestino; break;
        case PERIOD_M30: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H1: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H2: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H3: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H4: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H6: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H8: PeriodoOk = PeriodoDestino; break;
        case PERIOD_H12: PeriodoOk = PeriodoDestino; break;
        case PERIOD_D1: PeriodoOk = PeriodoDestino; break;
        case PERIOD_W1: PeriodoOk = PeriodoDestino; break;
        case PERIOD_MN1: PeriodoOk = PeriodoDestino; break;
        default: PeriodoOk = PeriodoDestino; break;
      }
    
    return(PeriodoOk);
  }

//+------------------------------------------------------------------+
//| FIRST TIME RUN                                                   |
//+------------------------------------------------------------------+
bool IsFirstTime(const string ProgramName)
  {
    bool ft;
    if (FileIsExist(ProgramName+".txt",FILE_COMMON|FILE_TXT) == false)
      {
        int file = FileOpen(ProgramName+".txt",FILE_READ|FILE_COMMON|FILE_TXT);
        FileClose(file);
        ft = true;
      }
      else {ft = false;}
    
    return(ft);
  }

//+------------------------------------------------------------------+
//| DEINITIALIZATION REASON                                          |
//+------------------------------------------------------------------+
string GetDeinitReason(int ReasonCode)
  {
    string ReasonResult;
    switch (ReasonCode)
      {
        case REASON_ACCOUNT:     ReasonResult = "Account was changed"; break;
        case REASON_CHARTCHANGE: ReasonResult = "Symbol or timeframe was changed"; break;
        case REASON_CHARTCLOSE:  ReasonResult = "Chart was closed"; break;
        case REASON_PARAMETERS:  ReasonResult = "Parameters was changed"; break;
        case REASON_RECOMPILE:   ReasonResult = "Program "+__FILE__+" was recompiled"; break;
        case REASON_REMOVE:      ReasonResult = "Program "+__FILE__+" was removed from chart"; break;
        case REASON_TEMPLATE:    ReasonResult = "New template was applied on chart"; break;
        default:                 ReasonResult = "Another reason";
      }
    return(ReasonResult);
  }

//+------------------------------------------------------------------+
//| CHECK IF NUMBER                                                  |
//+------------------------------------------------------------------+
bool CheckIfIsNumber(double ValueToCheck)
  {
    bool IsNumber;
    if (ValueToCheck != 0 && MathIsValidNumber(ValueToCheck)) {IsNumber = true;} else {IsNumber = false;}
    return(IsNumber);
  }

//+------------------------------------------------------------------+
//| POSITION SL OR TP RESULT IN $ (for SL just put minus signal)     |
//+------------------------------------------------------------------+
double SymbolPositionResultMoney(string symbol_, double volume_, double OpenPrice, double TargetPrice, bool invert)
  {
    
    double tick_value = SymbolInfoDouble(symbol_,SYMBOL_TRADE_TICK_VALUE);
    double tick_size  = SymbolInfoDouble(symbol_,SYMBOL_TRADE_TICK_SIZE);
    int symbol_digits = (int)SymbolInfoInteger(symbol_,SYMBOL_DIGITS);
    return( (invert) ? NormalizeDouble(volume_*tick_value*(TargetPrice - OpenPrice)/tick_size,symbol_digits)
                     : NormalizeDouble(volume_*tick_value*(OpenPrice - TargetPrice)/tick_size,symbol_digits));
  }

//+------------------------------------------------------------------+
//| POSITION SL OR TP RESULT IN %                                    |
//+------------------------------------------------------------------+
double SymbolPositionResultPercentage(string symbol_, double volume_, double OpenPrice, double TargetPrice, bool invert)
  {
    return((SymbolPositionResultMoney(symbol_,volume_,OpenPrice,TargetPrice,invert)/AccountInfoDouble(ACCOUNT_BALANCE))*100);
  }

//+------------------------------------------------------------------+
//| STRING REMOVE EMPTY SPACE                                        |
//+------------------------------------------------------------------+
string StringRemoveEmptySpace(string StringToRemove, string StringNew="")
  {
    int StrLen = StringLen(StringToRemove), i;
    string StrResult;
    for (i=0; i<StrLen; i++)
      {
        if (StringSubstr(StringToRemove,i,1) == " ")
          {
            StrResult = StrResult+StringNew;
            i = i;
          }
          else {StrResult = StrResult+StringSubstr(StringToRemove,i,1);}
      }
    return(StrResult);
  }

//+------------------------------------------------------------------+
//| CONNECTIONS WARNING                                               |
//+------------------------------------------------------------------+
void AccountCheckConnections(bool CheckServer, bool CheckTradingEnabled, bool CheckMQL5, string ServerError, string TradingError, string MQL5Error, string MsgCaption)
  {
    string ServerError_, TradingError_, MQL5Error_;
    bool ShowMsg = false;
    if (CheckServer == true)         {if (TerminalInfoInteger(TERMINAL_CONNECTED) == 0)            {ServerError_  = ServerError;ShowMsg = true;}}  else {ServerError_ = "";}
    if (CheckTradingEnabled == true) {if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 0)        {TradingError_ = TradingError;ShowMsg = true;}} else {TradingError_ = "";}
    if (CheckMQL5 == true)           {if (TerminalInfoInteger(TERMINAL_COMMUNITY_CONNECTION) == 0) {MQL5Error_    = MQL5Error;ShowMsg = true;}}    else {MQL5Error_ = "";}
    if (ShowMsg == true){ MessageBox(ServerError_+"\n"+TradingError_+"\n"+MQL5Error_,MsgCaption,MB_ICONERROR|MB_OK);}
  }

//+------------------------------------------------------------------+
//| CHECK TERMINAL CONNECTED                                         |
//+------------------------------------------------------------------+
string AccountConnectionState(string online_="On-line", string offline_="Off-line")
  {
    string state_;
    if (TerminalInfoInteger(TERMINAL_CONNECTED) == true) {state_ = online_;} else {state_ = offline_;}
    return(state_);
  }

//+------------------------------------------------------------------+
//| SYMBOL PERIOD CHANGE PIPS                                        |
//+------------------------------------------------------------------+
double SymbolPeriodChangePips(string symbol, ENUM_TIMEFRAMES period)
  {
    double ChangePips = (SymbolInfoDouble(symbol,SYMBOL_BID) - iClose(symbol,period,1));
    return(NormalizeDouble(ChangePips,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)));
  }

//+------------------------------------------------------------------+
//| SYMBOL PERIOD CHANGE PERCENTAGE                                  |
//+------------------------------------------------------------------+
double SymbolPeriodChangePercentage(string symbol, ENUM_TIMEFRAMES period)
  {
    double ChangePercentage = 100 - ((iClose(symbol,period,1) / SymbolInfoDouble(symbol,SYMBOL_BID))*100);
    return(NormalizeDouble(ChangePercentage,2));
  }

//+------------------------------------------------------------------+
//| KEYBOARD KEY CODE AS STRING                                      |
//+------------------------------------------------------------------+
string KeyboardKeyCode(int KeyID, string strNumeric="(numeric)", string strLeft="Left Arrow", string strUp="Up Arrow", string strRight="Right Arrow", string strDown="Down Arrow")
  {
    string strKey;
    
    switch(KeyID)
      {
        case(27): strKey = "Esc"; break;
        case(13): strKey = "Enter"; break;
        case(32): strKey = "Space"; break;
        case(8): strKey = "Backspace"; break;
        case(16): strKey = "Shift"; break;
        case(18): strKey = "Alt"; break;
        case(9): strKey = "Tab"; break;
        case(46): strKey = "Delete"; break;
        case(45): strKey = "Insert"; break;
        case(36): strKey = "Home"; break;
        case(35): strKey = "End"; break;
        case(33): strKey = "PgUp"; break;
        case(34): strKey = "PgDown"; break;
        case(19): strKey = "Pause"; break;
        case(112): strKey = "F1"; break;
        case(113): strKey = "F2"; break;
        case(114): strKey = "F3"; break;
        case(115): strKey = "F4"; break;
        case(116): strKey = "F5"; break;
        case(117): strKey = "F6"; break;
        case(118): strKey = "F7"; break;
        case(119): strKey = "F8"; break;
        case(120): strKey = "F9"; break;
        case(121): strKey = "F10"; break;
        case(122): strKey = "F11"; break;
        case(123): strKey = "F11"; break;
        case(48): strKey = "0"; break;
        case(49): strKey = "1"; break;
        case(50): strKey = "2"; break;
        case(51): strKey = "3"; break;
        case(52): strKey = "4"; break;
        case(53): strKey = "5"; break;
        case(54): strKey = "6"; break;
        case(55): strKey = "7"; break;
        case(56): strKey = "8"; break;
        case(57): strKey = "9"; break;
        case(189): strKey = "-"; break;
        case(187): strKey = "+"; break;
        case(96): strKey = "0 "+strNumeric; break;
        case(97): strKey = "1 "+strNumeric; break;
        case(98): strKey = "2 "+strNumeric; break;
        case(99): strKey = "3 "+strNumeric; break;
        case(100): strKey = "4 "+strNumeric; break;
        case(101): strKey = "5 "+strNumeric; break;
        case(102): strKey = "6 "+strNumeric; break;
        case(103): strKey = "7 "+strNumeric; break;
        case(104): strKey = "8 "+strNumeric; break;
        case(105): strKey = "9 "+strNumeric; break;
        case(111): strKey = "/ "+strNumeric; break;
        case(106): strKey = "* "+strNumeric; break;
        case(109): strKey = "- "+strNumeric; break;
        case(107): strKey = "+ "+strNumeric; break;
        case(194): strKey = ". "+strNumeric; break;
        case(110): strKey = ", "+strNumeric; break;
        case(65): strKey = "A"; break;
        case(66): strKey = "B"; break;
        case(67): strKey = "C"; break;
        case(68): strKey = "D"; break;
        case(69): strKey = "E"; break;
        case(70): strKey = "F"; break;
        case(71): strKey = "G"; break;
        case(72): strKey = "H"; break;
        case(73): strKey = "I"; break;
        case(74): strKey = "J"; break;
        case(75): strKey = "K"; break;
        case(76): strKey = "L"; break;
        case(77): strKey = "M"; break;
        case(78): strKey = "N"; break;
        case(79): strKey = "O"; break;
        case(80): strKey = "P"; break;
        case(81): strKey = "Q"; break;
        case(82): strKey = "R"; break;
        case(83): strKey = "S"; break;
        case(84): strKey = "T"; break;
        case(85): strKey = "U"; break;
        case(86): strKey = "V"; break;
        case(87): strKey = "W"; break;
        case(88): strKey = "X"; break;
        case(89): strKey = "Y"; break;
        case(90): strKey = "Z"; break;
        case(186): strKey = "Ç"; break;
        case(37): strKey = strLeft; break;
        case(38): strKey = strUp; break;
        case(39): strKey = strRight; break;
        case(40): strKey = strDown; break;
        default: strKey = ""; break;
      }
    return(strKey);
  }

//+------------------------------------------------------------------+
//| BID                                                              |
//+------------------------------------------------------------------+
double SymbolBID()
  {
    return(SymbolInfoDouble(_Symbol,SYMBOL_BID));
  }

//+------------------------------------------------------------------+
//| ASK                                                              |
//+------------------------------------------------------------------+
double SymbolASK()
  {
    return(SymbolInfoDouble(_Symbol,SYMBOL_ASK));
  }

//+------------------------------------------------------------------+
//| SPREAD                                                           |
//+------------------------------------------------------------------+
long SymbolSpread(string _symbol_)
  {
    return(SymbolInfoInteger(_symbol_,SYMBOL_SPREAD));
  }

//+------------------------------------------------------------------+
//| SYMBOL AUTO VOLUME BY BALANCE (big factor = small growth)        |
//+------------------------------------------------------------------+
double SymbolVolumeByBalance(string _symbol_, int VolumeFactor)
  {
    return(SymbolNormalizeVolume(_symbol_,AccountInfoDouble(ACCOUNT_BALANCE) * SymbolInfoDouble(_symbol_,SYMBOL_VOLUME_MIN) / VolumeFactor,false));
  }

//+------------------------------------------------------------------+
//| HISTORY LAST DEAL ENTRY REASON AS STRING                         |
//+------------------------------------------------------------------+
string HistoryDealLastEntryAsString()
  {
    HistorySelect(0,TimeCurrent());
    ulong _ticket   = HistoryDealGetTicket(HistoryDealsTotal()-1);
    long DealReason = HistoryDealGetInteger(_ticket,DEAL_REASON);
    if (DealReason==DEAL_ENTRY_IN) return("Entry In");
    if (DealReason==DEAL_ENTRY_OUT) return("Entry Out");
    if (DealReason==DEAL_ENTRY_INOUT) return("Entry InOut (reversion)");
    if (DealReason==DEAL_ENTRY_OUT_BY) return("Entry Out By (opposite position)");
    return("Unknow deal reason");
  }

//+------------------------------------------------------------------+
//| HISTORY LAST DEAL PROFIT AS DOUBLE                               |
//+------------------------------------------------------------------+
double HistoryDealLastResult()
  {
    HistorySelect(0,TimeCurrent());
    ulong _ticket = HistoryDealGetTicket(HistoryDealsTotal()-1);
    return(HistoryDealGetDouble(_ticket,DEAL_PROFIT));
  }

//+------------------------------------------------------------------+
//| CONVERT TO SYMBOL POINT                                          |
//+------------------------------------------------------------------+
double ToPoint(double _ToPoint)
  {
    return(_ToPoint*_Point);
  }

//+------------------------------------------------------------------+
//| SYMBOL DIGITS                                                    |
//+------------------------------------------------------------------+
long SymbolDigits()
  {
    return(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
  }

//+------------------------------------------------------------------+
//| TRADE TIME CHECK  - TradeTime(8, 0, 12, 0, TimeGMT())            |
//+------------------------------------------------------------------+
bool TradeTime(int _FromHour, int _FromMinute, int _ToHour, int _ToMinute, datetime _ClockType)
  {
    bool TradeTimeBool;
    StartTradeTime = StringToTime(IntegerToString(_FromHour)+":"+IntegerToString(_FromMinute));
    EndTradeTime   = StringToTime(IntegerToString(_ToHour)+":"+IntegerToString(_ToMinute));
    if (_ClockType >= StartTradeTime && _ClockType <= EndTradeTime) {StartTradeTime += 86400; TradeTimeBool = true;} else {TradeTimeBool = false;}
    return(TradeTimeBool);
  }

//+------------------------------------------------------------------+
//| CALCULATE MARGIN                                                 |
//+------------------------------------------------------------------+
double SymbolCalculateMargin(double _volume_, double _price_, ENUM_ORDER_TYPE OrderType=ORDER_TYPE_SELL, string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    double MarginReq = 0;
    if (!OrderCalcMargin(OrderType, __symbol, _volume_, _price_, MarginReq)) {Print("Error when calculating required order margin!");};
    return(MarginReq);
  }

//+------------------------------------------------------------------+
//| PRICE FROM LAST TRADE                                            |
//+------------------------------------------------------------------+
double SymbolOpenPositionsLast(string symbol="ACTUAL", const string comment="")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol && PositionGetString(POSITION_COMMENT) == comment)
          {
            if (PositionGetInteger(POSITION_TIME) > LastDate) {LastDate = (datetime)PositionGetInteger(POSITION_TIME); LastPrice = PositionGetDouble(POSITION_PRICE_OPEN);}
          }
      }
    return(LastPrice);
  }

//+------------------------------------------------------------------+
//| RETURN THE HIGHEST TRADE PRICE                                   |
//+------------------------------------------------------------------+
double SymbolOpenPositionsHighest(ENUM_POSITION_TYPE pos_type=POSITION_TYPE_SELL, string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    double HighestPrice = -999999;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol && PositionGetInteger(POSITION_TYPE) == pos_type)
          {
            if (PositionGetDouble(POSITION_PRICE_OPEN) > HighestPrice) {HighestPrice = PositionGetDouble(POSITION_PRICE_OPEN);}
          }
      }
    return(HighestPrice);
  }

//+------------------------------------------------------------------+
//| RETURN THE LOWEST TRADE PRICE                                    |
//+------------------------------------------------------------------+
double SymbolOpenPositionsLowest(ENUM_POSITION_TYPE pos_type=POSITION_TYPE_SELL, string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    double LowestPrice = 999999;
    for (int i=PositionsTotal(); i>=0; i--)
      {
        if (PositionGetSymbol(i) == __symbol && PositionGetInteger(POSITION_TYPE) == pos_type)
          {
            if (PositionGetDouble(POSITION_PRICE_OPEN) < LowestPrice) {LowestPrice = PositionGetDouble(POSITION_PRICE_OPEN);}
          }
      }
    return(LowestPrice);
  }

//+------------------------------------------------------------------+
//| SYMBOL SWAP BUY                                                  |
//+------------------------------------------------------------------+
double SymbolSwapBuy(string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    return(SymbolInfoDouble(__symbol,SYMBOL_SWAP_LONG));
  }

//+------------------------------------------------------------------+
//| SYMBOL SWAP SELL                                                 |
//+------------------------------------------------------------------+
double SymbolSwapSell(string symbol="ACTUAL")
  {
    string __symbol = (symbol!="ACTUAL") ? symbol : _Symbol;
    return(SymbolInfoDouble(__symbol,SYMBOL_SWAP_SHORT));
  }

//+------------------------------------------------------------------+
//| SCREEN DPI FACTOR (for multiplication)                           |
//+------------------------------------------------------------------+
double ScreenDPIFactor()
  {
    return(TerminalInfoInteger(TERMINAL_SCREEN_DPI)/100);
  }

//+------------------------------------------------------------------+
//| CANDLE CLOSE VALUE                                               |
//+------------------------------------------------------------------+
double CandleClose(int shift)
  {
    return(iClose(_Symbol, _Period, shift));
  }

//+------------------------------------------------------------------+
//| CANDLE OPEN VALUE                                                |
//+------------------------------------------------------------------+
double CandleOpen(int shift)
  {
    return(iOpen(_Symbol, _Period, shift));
  }

//+------------------------------------------------------------------+
//| CANDLE HIGH VALUE                                                |
//+------------------------------------------------------------------+
double CandleHigh(int shift)
  {
    return(iHigh(_Symbol, _Period, shift));
  }

//+------------------------------------------------------------------+
//| CANDLE LOW VALUE                                                 |
//+------------------------------------------------------------------+
double CandleLow(int shift)
  {
    return(iLow(_Symbol, _Period, shift));
  }

//+------------------------------------------------------------------+
//| CHECK IF IN STRATEGY TESTER                                      |
//+------------------------------------------------------------------+
bool CheckStrategyTester()
  {
    return((bool)MQLInfoInteger(MQL_TESTER));
  }

//+------------------------------------------------------------------+
//| CHART SCALE                                                      |
//+------------------------------------------------------------------+
long ChartGetScale()
  {
    return(ChartGetInteger(0, CHART_SCALE));
  }

//+------------------------------------------------------------------+
//| SYMBOL FILLING                                                   |
//+------------------------------------------------------------------+
string SymbolFilling()
  {
    string StrFilling;
    if (SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE) == 1) {StrFilling = "FOK";}
    if (SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE) == 2) {StrFilling = "IOC";}
    if (SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE) == NULL || SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE) == 0) {StrFilling = "RETURN";}
    return(StrFilling);
  }

//+------------------------------------------------------------------+
//| POSITIONS CALCULATE BARS                                         |
//+------------------------------------------------------------------+
int SymbolOpenPositionsBars(string symbol)
  {
    int _bars = 0;
    for (int i=0; i<PositionsTotal(); i++)
      {
        PositionSelectByTicket(PositionGetTicket(i));
        if (PositionGetString(POSITION_SYMBOL) == symbol)
          {
            _bars += Bars(_Symbol, _Period, PositionGetInteger(POSITION_TIME), TimeCurrent());
          }
      }
    return(_bars);
  }

//+------------------------------------------------------------------+
//| CLOSE TRADES AFTER SPECIFIED SECONDS                             |
//+------------------------------------------------------------------+
void SymbolOpenPositionsCloseAfterSeconds(string symbol, int _seconds)
  {
    int ActualTime = TimeCurrent();
    for (int i=0; i<PositionsTotal(); i++)
      {
        PositionSelectByTicket(PositionGetTicket(i));
        if (PositionGetString(POSITION_SYMBOL) == symbol)
          {
            int PosTime   = (int)PositionGetInteger(POSITION_TIME);
            int PosTimeOk = PosTime+_seconds;
            if (ActualTime > PosTimeOk) {SymbolOpenPositionsClose(symbol);}
          }
      }
  }