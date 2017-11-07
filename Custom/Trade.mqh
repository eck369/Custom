//+------------------------------------------------------------------+
//| Class CTrade                                                     |
//| Function : Trade operations                                      |
//+------------------------------------------------------------------+
#include <Custom\Manager\Tickets.mqh>

//+------------------------------------------------------------------+
//| CTrade Class                                                     |
//+------------------------------------------------------------------+
class CTrade
  {
public:
                     CTrade(void);
                    ~CTrade(void);
                    
   //--- Close Ticket 
   int               CloseAllBuy(int slippage);
   int               CloseAllSell(int slippage);
   int               CloseAllPosition(int slippage);
   bool              ClosePosition(int ticket_id, double volume, int slippage=0, color arrow_color=clrNONE);
//   bool              ClosePositionBy(int ticket_id, ulong ticket_by);

   //--- Add/Modify Internal SLTP Ticket 
   bool              IntSltp(int ticket_id, s_IntSltp &sltp);
   bool              DeleteIntSltp(int ticket_id);

   //--- Modify Ticket 
   bool              ModifyPosition(int ticket_id, double sl, double tp, color arrow_color=clrNONE);
   bool              ModifyOrder(int ticket_id, double price, double sl, double tp, datetime expiration=0, color arrow_color=clrNONE);

   //--- Delete Ticket 
   bool              DeleteOrder(int ticket_id, color arrow_color=clrNONE);
   int               DeleteAllOrder(void);

   //--- Place Order
   int               Buy(string symbol, double volume, double price, double sl, double tp, int slippage, 
                           int magic=0, datetime expiration=0, string comment=NULL, color arrow_color=clrNONE);
   int               Sell(string symbol, double volume, double price, double sl, double tp, int slippage, 
                           int magic=0, datetime expiration=0, string comment=NULL, color arrow_color=clrNONE);
  };
  
/*  CTrade class instantiation */
CTrade g_Trade;
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrade::CTrade(void)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrade::~CTrade(void)
{
}

//+------------------------------------------------------------------+
//| Function - int CTrade::CloseAllBuy(int slippage)                 |
//+------------------------------------------------------------------+
//| Param - slippage : Allowable slippage to close a Buy position    |
//|                                                                  |
//| Return - Number of Buy Position closed                           |
//|                                                                  |
//| Details - Close All Buy Position                                 |
//+------------------------------------------------------------------+
int CTrade::CloseAllBuy(int slippage)
{
   int count = 0;   
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OP_BUY == OrderType())
         {
            if(ClosePosition(OrderTicket(), OrderLots(), slippage))
            {
               count++;
            }
            else
            {
               Print("[Err]"+__FUNCTION__+" : Delete ticket#",i," failed");
            }  
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Function - int CTrade::CloseAllSell(int slippage)                |
//+------------------------------------------------------------------+
//| Param - slippage : Allowable slippage to close a Sell position   |
//|                                                                  |
//| Return - Number of Sell Position closed                          |
//|                                                                  |
//| Details - Close All Sell Position                                |
//+------------------------------------------------------------------+
int CTrade::CloseAllSell(int slippage)
{
   int count = 0;   
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OP_SELL == OrderType())
         {
            if(ClosePosition(OrderTicket(), OrderLots(), slippage))
            {
               count++;
            }
            else
            {
               Print("[Err]"+__FUNCTION__+" : Delete ticket#",i," failed");
            }  
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Function - int CTrade::CloseAllPosition(int slippage)            |
//+------------------------------------------------------------------+
//| Param - slippage : Allowable slippage to close a position        |
//|                                                                  |
//| Return - Number of Position closed                               |
//|                                                                  |
//| Details - Close All Position                                     |
//+------------------------------------------------------------------+
int CTrade::CloseAllPosition(int slippage)
{
   int count = 0;   
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OP_BUY == OrderType() || OP_SELL == OrderType())
         {
            if(ClosePosition(OrderTicket(), OrderLots(), slippage))
            {
               count++;
            }
            else
            {
               Print("[Err]"+__FUNCTION__+" : Delete ticket#",i," failed");
            }
         }
      }
   }
   return count;
}

//+---------------------------------------------------------------------------------------+
//| Function - bool CTrade::ClosePosition(int ticket_id, double volume,                   |
//|                                       int slippage=0, color arrow_color=clrNONE)      |
//+---------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                         |
//|         volume : Lot size to be closed                                                |
//|         slippage : Allowable slippage to close a position                             |
//|         arrow_color : Arrow color to be display on chart                              |
//|                                                                                       |
//| Return - TRUE : Successfully close ticket                                             |
//|          False : Failed to close ticket                                               |
//|                                                                                       |
//| Details - Close All Position                                                          |
//+---------------------------------------------------------------------------------------+
bool CTrade::ClosePosition(int ticket_id, double volume, int slippage=0, color arrow_color=clrNONE)
{
//--- Parameter Check   
   if(!OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {
      Print("[Err]"+__FUNCTION__+" : Invalid Ticket");
      return false;
   }
   
   if(0 >= volume)
   {
      Print("[Err]"+__FUNCTION__+" : Invalid volume, ",volume);
      return false;
   }
//---//
 
   double price = 0;
   if(OP_BUY == OrderType())
   {
      price = MarketInfo(OrderSymbol(), MODE_BID);
   }
   else if(OP_SELL == OrderType())
   {
      price = MarketInfo(OrderSymbol(), MODE_ASK);
   }
   else
   {
      Print("[Err]"+__FUNCTION__+" : Ticket is not in position anymore");
      return false;
   }
   
   return(OrderClose(ticket_id, volume, price, slippage, arrow_color));
}

//+------------------------------------------------------------------------------+
//| Function - bool CTrade::AddIntSltp(int ticket_id, s_IntSltp &sltp )          |
//+------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                |
//|         &sltp : Struct with Internal Stop Loss and Take Profit               |
//|                                                                              |
//| Return - TRUE : Successfully add/modify internal stop loss and take profit   |
//|          False : Failed to add/modify internal stop loss and take profit     |
//|                                                                              |
//| Details - Add/modify Internal stop loss and take profit                      |
//+------------------------------------------------------------------------------+
bool CTrade::IntSltp(int ticket_id, s_IntSltp &sltp)
{
   if(OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {
      if(0 <= sltp.i_sl && 
         0 <= sltp.i_tp)
      {
         return (g_Tickets.AddSltp(ticket_id, sltp));
      }
   }
   return false;
}

//+---------------------------------------------------------------------------+
//| Function - bool CTrade::DeleteIntSltp(int ticket_id)                      |
//+---------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                             |
//|                                                                           |
//| Return - TRUE : Successfully delete internal stop loss and take profit    |
//|          False : No internal stop loss and take profit to delete          |
//|                                                                           |
//| Details - Delete internal stop loss and take profit                       |
//+---------------------------------------------------------------------------+
bool CTrade::DeleteIntSltp(int ticket_id)
{
   return (g_Tickets.DeleteSltp(ticket_id));
}


//+---------------------------------------------------------------------------------------+
//| Function - bool CTrade::ModifyPosition(int ticket_id, double sl,                      |
//|                                        double tp, color arrow_color=clrNONE)          |
//+---------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                         |
//|         sl : Stop Loss                                                                |
//|         tp : Take Profit                                                              |
//|         arrow_color : Arrow color to be display on chart                              |
//|                                                                                       |
//| Return - TRUE : Successfully modify position ticket                                   |
//|          False : Failed to modify position ticket                                     |
//|                                                                                       |
//| Details - Modify position ticket                                                      |
//+---------------------------------------------------------------------------------------+
bool CTrade::ModifyPosition(int ticket_id, double sl, double tp, color arrow_color=clrNONE)
{
//--- Parameter Check 
   if(!OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {
      Print("[Err]"+__FUNCTION__+" : Invalid Ticket");
      return false;
   }
   
   if(OP_BUY != OrderType() && OP_SELL != OrderType())
   {
      Print("[Err]"+__FUNCTION__+" : Ticket is not in position anymore");
      return false;
   }
//---//    

   double temp_sl = sl;
   double temp_tp = tp;
   
   if(0 == sl) temp_sl = OrderStopLoss();
   if(0 == tp) temp_tp = OrderTakeProfit();
   
   return(OrderModify(ticket_id, 0, temp_sl, temp_tp, 0, arrow_color));
}
  
//+------------------------------------------------------------------------------------------+
//| Function - bool CTrade::ModifyOrder(int ticket_id, double price, double sl, double tp,   | 
//|                                     datetime expiration, color arrow_color=clrNONE)      |
//+------------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                            |
//|         sl : Stop Loss                                                                   |
//|         tp : Take Profit                                                                 |
//|         arrow_color : Arrow color to be display on chart                                 |
//|                                                                                          |
//| Return - TRUE : Successfully modify pending ticket                                       |
//|          False : Failed to modify pending ticket                                         |
//|                                                                                          |
//| Details - Modify pending ticket                                                          |
//+------------------------------------------------------------------------------------------+  
bool CTrade::ModifyOrder(int ticket_id, double price, double sl, double tp, datetime expiration, color arrow_color=clrNONE)
{
//--- Parameter Check 
   if(!OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {
      Print("[Err]"+__FUNCTION__+" : Invalid Ticket");
      return false;
   }
   
   if(OP_BUY == OrderType() || OP_SELL == OrderType())
   {
      Print("[Err]"+__FUNCTION__+" : Ticket is not in pending anymore");
      return false;
   }
//---// 
   
   double temp_price = price;
   double temp_sl = sl;
   double temp_tp = tp;
   datetime temp_exp = expiration;
   
   if(0 == price) temp_price = OrderOpenPrice();
   if(0 == sl) temp_sl = OrderStopLoss();
   if(0 == tp) temp_tp = OrderTakeProfit();
   if(0 == expiration)  temp_exp = OrderExpiration();
   
   return(OrderModify(ticket_id, temp_price, temp_sl, temp_tp, temp_exp, arrow_color));
}

//+---------------------------------------------------------------------------------------+
//| Function - bool CTrade::DeleteOrder(int ticket_id, color arrow_color=clrNONE)         |
//+---------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                         |
//|         arrow_color : Arrow color to be display on chart                              |
//|                                                                                       |
//| Return - TRUE : Successfully delete pending ticket                                    |
//|          False : Failed to delete pending ticket                                      |
//|                                                                                       |
//| Details - Delete pending ticket                                                       |
//+---------------------------------------------------------------------------------------+
bool CTrade::DeleteOrder(int ticket_id, color arrow_color=clrNONE)
{
//--- Parameter Check
   if(!OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {
      Print("[Err]"+__FUNCTION__+" : Invalid Ticket");
      return false;
   }
   
   if(OP_BUY == OrderType() || OP_SELL == OrderType())
   {
      Print("[Err]"+__FUNCTION__+" : Ticket is not in pending anymore");
      return false;
   }
//---// 
   return(OrderDelete(ticket_id, arrow_color));
}

//+---------------------------------------------------------------------------+
//| Function - int CTrade::DeleteAllOrder(void)                               |
//+---------------------------------------------------------------------------+
//| Param - void                                                              |
//|                                                                           |
//| Return - Number of pending ticket deleted                                 |
//|                                                                           |
//| Details - Delete all pending ticket                                       |
//+---------------------------------------------------------------------------+
int CTrade::DeleteAllOrder(void)
{
   int count = 0;   
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OP_BUY != OrderType() && OP_SELL != OrderType())
         {
            if(OrderDelete(OrderTicket()))
            {
               count++;
            }
            else
            {
               Print("[Err]"+__FUNCTION__+" : Delete ticket#",i," failed");
            }  
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------------------------------+
//| Function - int CTrade::Buy(string symbol, double volume, double price, double sl,        |
//|                            double tp, int slippage, int magic=0, datetime expiration=0,  | 
//|                            string comment=NULL, color arrow_color=clrNONE)               |
//+------------------------------------------------------------------------------------------+
//| Param - symbol : Symbol                                                                  |
//|         volume : Lot size                                                                |
//|         price : Price or 0 to buy on spot rate                                           |
//|         sl : Stop loss                                                                   |
//|         tp : Take profit                                                                 |
//|         slippage : Allowable slippage to open a position                                 |
//|         magic : Magic number                                                             |
//|         expiration : Expiration date time                                                |
//|         comment : Comment                                                                |
//|         arrow_color : Arrow color to be display on chart                                 |
//|                                                                                          |
//| Return - >= 0 : Ticket Id                                                                |
//|          < 0 : Failed to open position/pending ticket                                    |
//|                                                                                          |
//| Details - Open Buy/Buy Limit/Buy Stop Order                                              |
//+------------------------------------------------------------------------------------------+
int CTrade::Buy(string symbol, double volume, double price, double sl, double tp, int slippage, 
                  int magic=0, datetime expiration=0, string comment=NULL, color arrow_color=clrNONE)
{
//--- Parameter Check
   if(NULL == symbol)
   {
      Print("[Err]"+__FUNCTION__+" : NULL Symbol");
      return -1;
   }
   
   if(0 >= volume)
   {
      Print("[Err]"+__FUNCTION__+" : Invalid volume, ",volume);
      return false;
   }
//---//    

   int total_ticket = OrdersTotal();
   int ticket = -1;
   double open_price = 0;
   int cmd = OP_BUY;
   double ask = MarketInfo(symbol, MODE_ASK);
   double stop_pt = MarketInfo(symbol, MODE_STOPLEVEL)*MarketInfo(symbol, MODE_POINT);
 
   if(0.0 != price)
   {
      if(price > ask + stop_pt)
      {
         cmd = OP_BUYSTOP;
         open_price = price;
      }
      else if(price < ask - stop_pt)
      {
         cmd = OP_BUYLIMIT;
         open_price = price;
      } 
      else
      {
         Print("[Err]"+__FUNCTION__+" : Failed, ask = ",ask,", stop = ",stop_pt,", price = ",price);
         return -1;
      }    
   }
   else
   {
      cmd = OP_BUY;
      open_price = ask;
   }
   
   ticket = OrderSend(symbol, cmd, volume, open_price, slippage, sl, tp, comment, magic, expiration, arrow_color);
   if(-1 == ticket)
   {
      if(total_ticket < OrdersTotal())
      {
         if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS, MODE_TRADES))
         {
            if(cmd == OrderType()) { ticket = OrderTicket(); }
         }
      }
   }   
   return ticket;  
}

//+------------------------------------------------------------------------------------------+
//| Function - int CTrade::Sell(string symbol, double volume, double price, double sl,        |
//|                            double tp, int slippage, int magic=0, datetime expiration=0,  | 
//|                            string comment=NULL, color arrow_color=clrNONE)               |
//+------------------------------------------------------------------------------------------+
//| Param - symbol : Symbol                                                                  |
//|         volume : Lot size                                                                |
//|         price : Price or 0 to buy on spot rate                                           |
//|         sl : Stop loss                                                                   |
//|         tp : Take profit                                                                 |
//|         slippage : Allowable slippage to open a position                                 |
//|         magic : Magic number                                                             |
//|         expiration : Expiration date time                                                |
//|         comment : Comment                                                                |
//|         arrow_color : Arrow color to be display on chart                                 |
//|                                                                                          |
//| Return - >= 0 : Ticket Id                                                                |
//|          < 0 : Failed to open position/pending ticket                                    |
//|                                                                                          |
//| Details - Open Sell/Sell Sell/Buy Sell Order                                              |
//+------------------------------------------------------------------------------------------+
int CTrade::Sell(string symbol, double volume, double price, double sl, double tp, int slippage, 
                  int magic=0, datetime expiration=0, string comment=NULL, color arrow_color=clrNONE)
{
//--- Parameter Check
   if(NULL == symbol)
   {
      Print("[Err]"+__FUNCTION__+" : NULL Symbol");
      return -1;
   }
   
   if(0 >= volume)
   {
      Print("[Err]"+__FUNCTION__+" : Invalid volume, ",volume);
      return false;
   }
//---//  

   int total_ticket = OrdersTotal();
   int ticket = -1;
   double open_price = 0;
   int cmd = OP_SELL;
   double bid = MarketInfo(symbol, MODE_BID);
   double stop_pt = MarketInfo(symbol, MODE_STOPLEVEL)*MarketInfo(symbol, MODE_POINT);

   if(0.0 != price)
   {
      if(price > bid + stop_pt)
      {
         cmd = OP_SELLLIMIT;
         open_price = price;
      }
      else if(price < bid - stop_pt)
      {
         cmd = OP_SELLSTOP;
         open_price = price;
      }
      else
      {
         Print("[Err]"+__FUNCTION__+" : Failed, bid = ",bid,", stop = ",stop_pt,", price = ",price);
         return -1;
      } 
   }
   else
   {
      cmd = OP_SELL;
      open_price = bid;
   }
   
   ticket = OrderSend(symbol, cmd, volume, open_price, slippage, sl, tp, comment, magic, expiration, arrow_color);
   if(-1 == ticket)
   {
      if(total_ticket < OrdersTotal())
      {
         if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS, MODE_TRADES))
         {
            if(cmd == OrderType()) ticket = OrderTicket();
         }
      }
   }   
   return ticket;
}

//+------------------------------------------------------------------+