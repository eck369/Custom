//+------------------------------------------------------------------+
//| Class CTicketMgr                                                 |
//| Function : Ticket related operations                             |
//+------------------------------------------------------------------+
#include <Custom\Configuration.mqh>
#include <Custom\BaseClass\StrategyBase.mqh>
#include <Custom\BaseClass\TrailBase.mqh>
#include <Custom\Trade.mqh>

//+------------------------------------------------------------------+
//| CTicketMgr Class                                                 |
//+------------------------------------------------------------------+
class CTicketMgr
  {
protected:
   CStrategyBase       *m_strategy;
   CTrailBase          *m_trail;
   
public:
                        CTicketMgr();
                       ~CTicketMgr();
                       
   //--- Initialization                      
   void                 Init(CStrategyBase *strategy, CTrailBase* trail);
   
   //--- Get Ticket Info   
   int                  TotalActiveTicket(void);
   int                  TotalPendingTicket(void);
   int                  TotalPositionTicket(void);
   int                  TotalTicketByCmd(int cmd);
   const CTicket const *GetTicketById(int ticket_id);

   //--- Subscribe Ticket for event callback on OnTicketEvent()
   bool                 SubscribeEvent(int ticket_id);
   bool                 UnsubscribeEvent(int ticket_id);

   //--- Cbeck and update ticket info 
   void                 UpdateTicket(void);
  
protected:
   //--- Update ticket
   void                 UpdateTicketState(CTicket *ticket);
   void                 CloseTicketState(CTicket *ticket);
   void                 RunIntSltp(CTicket *ticket);
   
  };

/*  CTicketMgr class instantiation */
CTicketMgr g_TicketMgr;
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTicketMgr::CTicketMgr()                  
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTicketMgr::~CTicketMgr()
{
}

//+------------------------------------------------------------------------------+
//| Function - void CTicketMgr::Init(CStrategyBase* strategy, CTrailBase* trail) |
//+------------------------------------------------------------------------------+
//| Param - *strategy : Pointer to strategy Inheritance of CStrategyBase         |
//|         *trail : Pointer to trail Inheritance of CTrailBase                  |
//|                                                                              |
//| Return - Void                                                                |
//|                                                                              |
//| Details - Get strategy instance for OnTicketEvent()                          | 
//|           Get trail instance for Trailing()                                  |   
//+------------------------------------------------------------------------------+
void CTicketMgr::Init(CStrategyBase* strategy, CTrailBase* trail)
{
   if(NULL != strategy) 
   {
      m_strategy = strategy;
   }
   else
   {
      Print("[Err]"+__FUNCTION__+" : Invalid strategy pointer");
   }
   
   if(NULL != trail) 
   {
      m_trail = trail;
   }
   else
   {
      Print("[Err]"+__FUNCTION__+" : Invalid trail pointer");
   } 
}

//+------------------------------------------------------------------+
//| Function - int CTicketMgr::TotalActiveTicket(void)               |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Total number of position and pending ticket             |
//|                                                                  |
//| Details - Get total number of position and pending ticket        |  
//+------------------------------------------------------------------+
int CTicketMgr::TotalActiveTicket(void)
{
   return (OrdersTotal());
}

//+------------------------------------------------------------------+
//| Function - int CTicketMgr::TotalPendingTicket(void)              |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Total number of pending ticket                          |
//|                                                                  |
//| Details - Get total number pending ticket                        |  
//+------------------------------------------------------------------+
int CTicketMgr::TotalPendingTicket(void)
{
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType() == OP_BUYLIMIT || 
            OrderType() == OP_BUYSTOP|| 
            OrderType() == OP_SELLLIMIT|| 
            OrderType() == OP_SELLLIMIT)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Function - int CTicketMgr::TotalPositionTicket(void)             |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Total number of position ticket                         |
//|                                                                  |
//| Details - Get total number position ticket                       |
//+------------------------------------------------------------------+
int CTicketMgr::TotalPositionTicket(void)
{
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType() == OP_BUY || 
            OrderType() == OP_SELL)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Function - int CTicketMgr::TotalTicketByCmd(int cmd)             |
//+------------------------------------------------------------------+
//| Param - cmd : OP_BUY   / OP_BUYLIMIT  / OP_BUYSTOP               |
//|               OP_SELL  / OP_SELLLIMIT / OP_SELLSTOP              |
//|                                                                  |
//| Return - Total number of cmd type ticket                         |
//|                                                                  |
//| Details - Get total number cmd type ticket                       |
//+------------------------------------------------------------------+
int CTicketMgr::TotalTicketByCmd(int cmd)
{
   int count = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType() == cmd) count++;
      }
   }
   return count;
}

//+---------------------------------------------------------------------------+
//| Function - const CTicket const *CTicketMgr::GetTicketById(int ticket_id)  |
//+---------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                             |
//|                                                                           |
//| Return - Pointer of ticket instance                                       |
//|                                                                           |
//| Details - Get pointer to ticket by ticket id                              |
//+---------------------------------------------------------------------------+
const CTicket const *CTicketMgr::GetTicketById(int ticket_id)
{
   return g_Tickets.GetTicketById(ticket_id);
}

//+---------------------------------------------------------------------------------+
//| Function - bool CTicketMgr::SubscribeEvent(int ticket_id)                       |
//+---------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                   |
//|                                                                                 |
//| Return - Pointer of ticket instance                                             |
//|                                                                                 |
//| Details - Subscribe ticket to get OnTicketEvent when ticket status has changed  |
//+---------------------------------------------------------------------------------+
bool CTicketMgr::SubscribeEvent(int ticket_id)
{
   if(OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {  
      s_TicketState state;
      state.prev_cmd = -1;
      state.curr_cmd = OrderType();
      state.prev_state = TICKET_NEW;
      if(OrderType() == OP_BUY ||
         OrderType() == OP_SELL)
      {
         state.curr_state = TICKET_POSITION;
      }
      else
      {
         state.curr_state = TICKET_PENDING;
      }
         
      CTicket *ticket = g_Tickets.GetTicketById(ticket_id);
      if(NULL != ticket)
      {
         ticket.state = state;
      }
      else
      {
         return g_Tickets.AddState(ticket_id, state);
      }
   }
   return false;
}

//+---------------------------------------------------------------------------------+
//| Function - bool CTicketMgr::UnsubscribeEvent(int ticket_id)                     |
//+---------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                   |
//|                                                                                 |
//| Return - TRUE : Successfully unsubscribe for ticket                             |
//|          False : No ticket to be unsubscribed                                   |
//|                                                                                 |
//| Details - Unsubscribe ticket for status update                                  |
//+---------------------------------------------------------------------------------+
bool CTicketMgr::UnsubscribeEvent(int ticket_id)
{ 
   CTicket *ticket = g_Tickets.GetTicketById(ticket_id);
   if(NULL != ticket)
   {
      g_Tickets.DeleteState(ticket_id);
   }
   return false;
}

//+---------------------------------------------------------------------------------+
//| Function - void CTicketMgr::UpdateTicket(void)                                  |
//+---------------------------------------------------------------------------------+
//| Param - void                                                                    |
//|                                                                                 |
//| Return - void                                                                   |
//|                                                                                 |
//| Details - Update ticket for state, internal stop loss and take profit           |
//|           and trailing                                                          |
//+---------------------------------------------------------------------------------+
void CTicketMgr::UpdateTicket(void)
{
   CTicket *ticket = NULL;
   for(int i=0; i<g_Tickets.Total() && i<MAX_TICKET; i++)
   {
      ticket = g_Tickets.GetTicketByIndex(i);
      if(OrderSelect(ticket.id, SELECT_BY_TICKET, MODE_TRADES))
      {
      //--- Update ticket state
         if(g_Tickets.StateMode(i)) UpdateTicketState(ticket);
      //--- Check and close when take profit and stop loss is hit
         if(g_Tickets.SltpMode(i)) RunIntSltp(ticket);
      //--- Check and trail profit
         if(g_Tickets.TrailMode(i)) m_trail.Trailing(ticket);    
      }
      else
      {
      //--- Close Ticket State when ticket is in history 
         CloseTicketState(ticket);
         g_Tickets.DeleteTicket(i);
         i--;
      }
   }
}

//+---------------------------------------------------------------------------------+
//| Function - void CTicketMgr::UpdateTicketState(CTicket *ticket)                  |
//+---------------------------------------------------------------------------------+
//| Param - *ticket : Pointer to CTicket Inheritance                                |
//|                                                                                 |
//| Return - void                                                                   |
//|                                                                                 |
//| Details - Update ticket state                                                   |
//+---------------------------------------------------------------------------------+
void CTicketMgr::UpdateTicketState(CTicket *ticket)
{
   if(ticket.state.curr_cmd != OrderType())
   {
      ticket.state.prev_cmd = ticket.state.curr_cmd;
      ticket.state.prev_state = ticket.state.curr_state;
      ticket.state.curr_cmd = OrderType();
      
      if(OrderType() == OP_BUY ||
         OrderType() == OP_SELL)
      {
         ticket.state.curr_state = TICKET_POSITION;
      }
      else
      {
         ticket.state.curr_state = TICKET_PENDING;
      }
      m_strategy.OnTicketEvent(ticket.id, ticket.state);
   }           
}

//+---------------------------------------------------------------------------------+
//| Function - void CTicketMgr::CloseTicketState(CTicket *ticket)                   |
//+---------------------------------------------------------------------------------+
//| Param - *ticket : Pointer to CTicket Inheritance                                |
//|                                                                                 |
//| Return - void                                                                   |
//|                                                                                 |
//| Details - Close ticket when ticket is in history                                |
//+---------------------------------------------------------------------------------+
void CTicketMgr::CloseTicketState(CTicket *ticket)
{
   ticket.state.prev_cmd = ticket.state.curr_cmd;
   ticket.state.prev_state = ticket.state.curr_state;
   ticket.state.curr_cmd = -1;
   ticket.state.curr_state = TICKET_CLOSE;     
   
   m_strategy.OnTicketEvent(ticket.id, ticket.state);     
}

//+---------------------------------------------------------------------------------+
//| Function - void CTicketMgr::RunIntSltp(CTicket *ticket)                         |
//+---------------------------------------------------------------------------------+
//| Param - *ticket : Pointer to CTicket Inheritance                                |
//|                                                                                 |
//| Return - void                                                                   |
//|                                                                                 |
//| Details - Check and close ticket when take profit and stop loss is hit          |
//+---------------------------------------------------------------------------------+
void CTicketMgr::RunIntSltp(CTicket *ticket)
{
   if(OrderType() == OP_BUY || OrderType() == OP_SELL)
   {
      double price = 0;
      bool close = false;
      if(OP_BUY == OrderType())
      {
         price = MarketInfo(OrderSymbol(), MODE_BID);
         if(0 == ticket.sltp.i_sl) { ticket.sltp.i_sl = 100; }
         if(ticket.sltp.i_sl >= price && ticket.sltp.i_tp <= price) { close = true; }      
      }
      else if(OP_SELL == OrderType())
      {
         price = MarketInfo(OrderSymbol(), MODE_ASK);
         if(0 == ticket.sltp.i_tp)  { ticket.sltp.i_tp = 100; }
         if(ticket.sltp.i_sl <= price && ticket.sltp.i_tp >= price)  { close = true; }  
      }
      else
      {
         Print("[Err]"+__FUNCTION__+" : Ticket is not in position anymore");
         return;
      }
      
      if(close)
      {
         g_Trade.ClosePosition(ticket.id, OrderLots());
      }
   }
}

//+------------------------------------------------------------------+