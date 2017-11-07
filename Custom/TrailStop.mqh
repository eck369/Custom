//+------------------------------------------------------------------+
//| Class CTrailStop                                                 |
//| Function : Child class of CTrailBase. Profit trailing Operation  |
//+------------------------------------------------------------------+
#include <Custom\Configuration.mqh>
#include <Custom\BaseClass\TrailBase.mqh>
#include <Custom\Trade.mqh>

//+------------------------------------------------------------------+
//| CTrailBase Class                                                 |
//+------------------------------------------------------------------+
class CTrailStop : public CTrailBase
  {  
public:
                     CTrailStop();
                    ~CTrailStop();
                    
   //--- Trail operation                  
   bool              AddTrailStop(int ticket_id, s_Trail &trail);
   bool              DeleteTrailStop(int ticket_id);
	bool              Trailing(CTicket *ticket);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrailStop::CTrailStop()
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrailStop::~CTrailStop()
{
}

//+------------------------------------------------------------------------------+
//| Function - bool CTrailBase::AddTrailStop(int ticket_id, s_Trail &trail)      |
//+------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                |
//|         &trail : Struct with trail info                                      |
//|                                                                              |
//| Return - TRUE : Successfully add/modify trail info                           |
//|          False : Failed to add/modify Internal trail info                    |
//|                                                                              |
//| Details - Add/modify trail info                                              |
//+------------------------------------------------------------------------------+
bool CTrailStop::AddTrailStop(int ticket_id, s_Trail &trail)
{
   if(trail.min_profit_pt >= 0 && 
      trail.trail_pt > 0 && 
      trail.step_pt >= 0)
   {
      return CTrailBase::AddTrailStop(ticket_id, trail);
   }
   return false;
}

//+---------------------------------------------------------------------------+
//| Function - bool CTrailBase::DeleteTrailStop(int ticket_id)                |
//+---------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                             |
//|                                                                           |
//| Return - TRUE : Successfully delete trail info                            |
//|          False : No trail info to delete                                  |
//|                                                                           |
//| Details - Delete trail info                                               |
//+---------------------------------------------------------------------------+
bool CTrailStop::DeleteTrailStop(int ticket_id)
{
   return CTrailBase::DeleteTrailStop(ticket_id);
}

//+---------------------------------------------------------------------------+
//| Function - bool CTrailStop::Trailing(CTicket *ticket)                     |
//+---------------------------------------------------------------------------+
//| Param - *ticket : Pointer to CTicket Inheritance                          |
//|                                                                           |
//| Return - void                                                             |
//|                                                                           |
//| Details - Check and close ticket when trail point hit                     |
//+---------------------------------------------------------------------------+
bool CTrailStop::Trailing(CTicket *ticket)
{
   if(OrderType() == OP_BUY || OrderType() == OP_SELL)
   {
   	double sl = OrderStopLoss();
   	double open_price = OrderOpenPrice();
   	string symbol = OrderSymbol();
   	int digit = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   	
   	double trail_price;
   	double curr_profit_pt;
   	
   	// Order loop
   	int retryCount = 0;
   	int checkRes = 0;
   
   	if(OP_BUY == OrderType())
   	{
   	   double bid = MarketInfo(OrderSymbol(), MODE_BID);
   		trail_price = NormalizeDouble((bid - ticket.trail.trail_pt), digit);
   		curr_profit_pt = NormalizeDouble((bid - open_price), digit);
   		
   		if(trail_price > sl + ticket.trail.step_pt && curr_profit_pt >= ticket.trail.min_profit_pt)
   		{
   			if(g_Trade.ModifyPosition(ticket.id, trail_price, 0))
   			{
   			   Print(__FUNCTION__+" : Ticket#",ticket.id," new stop price = ",trail_price);
   			}
   			else
   			{
   			   Print("[Err]"+__FUNCTION__+" : ModifyPosition failed");
   			   return false;				
   			}
   		}
   		else return(false);
   	}
   	else if(OP_SELL == OrderType())
   	{
   	   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   		trail_price = NormalizeDouble((ask + ticket.trail.trail_pt), digit);
   		curr_profit_pt = NormalizeDouble((open_price - ask), digit);
   		
      	if(trail_price < sl - ticket.trail.step_pt && curr_profit_pt >= ticket.trail.min_profit_pt)
   		{	
   			if(g_Trade.ModifyPosition(ticket.id, trail_price, 0))
   			{
   			   Print(__FUNCTION__+" : Ticket#",ticket.id," new stop price = ",trail_price);
   			}
   			else
   			{
   			   Print("[Err]"+__FUNCTION__+" : ModifyPosition failed");
   			   return false;				
   			}
   		}
   		else return(false);
   	}
   }
   return true;
}

//+------------------------------------------------------------------+