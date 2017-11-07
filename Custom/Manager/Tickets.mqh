//+------------------------------------------------------------------+
//| Class CTicket and class CTickets                                 |
//| Function : Ticket Buffer class to store ticket                   |
//+------------------------------------------------------------------+
#include <Custom\Configuration.mqh>

enum e_TicketState
{
   TICKET_EMPTY = 0,
   TICKET_NEW,
   TICKET_PENDING,
   TICKET_POSITION,
   TICKET_CLOSE
};

struct s_TicketState
{
   int prev_cmd;
   int curr_cmd;
   e_TicketState prev_state;
   e_TicketState curr_state;
};

struct s_IntSltp
{
   double i_sl;
   double i_tp;
};

//+------------------------------------------------------------------+
//| CTicket Class                                                    |
//+------------------------------------------------------------------+
class CTicket
  { 
public:
   int               id;
   s_TicketState     state;
   s_IntSltp         sltp;
   s_Trail           trail;   
   
public:
                     CTicket();
                    ~CTicket();
  };
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTicket::CTicket()
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTicket::~CTicket()
{
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CTickets Class                                                   |
//+------------------------------------------------------------------+
class CTickets
  {
protected:
   CTicket           info[MAX_TICKET];   
   bool              state_mode[MAX_TICKET]; 
   bool              sltp_mode[MAX_TICKET]; 
   bool              trail_mode[MAX_TICKET]; 
   int               m_total;
   
public:
                     CTickets();
                    ~CTickets();
                              
   //--- Get Ticket Info                           
   int               Total(void) { return(m_total); }
   int               GetIndexByTicketId(int ticket_id);
   CTicket          *GetTicketById(int ticket_id);
   CTicket          *GetTicketByIndex(int idx);
   
   //--- Add/Modify Ticket
   bool              AddState(const int ticket_id, const s_TicketState &state);
   bool              AddSltp(const int ticket_id, const s_IntSltp &sltp);
   bool              AddTrail(const int ticket_id, const s_Trail &trail);
   
   //--- Delete Ticket
   bool              DeleteState(const int ticket_id);
   bool              DeleteSltp(const int ticket_id);
   bool              DeleteTrail(const int ticket_id);
   bool              DeleteTicket(int idx);
   
   //--- Get Ticket mode status
   bool              StateMode(const int idx)   const { return (state_mode[idx]); }
   bool              SltpMode(const int idx)   const { return (sltp_mode[idx]); }
   bool              TrailMode(const int idx)   const { return (trail_mode[idx]); }
  };

/*  CTickets class instantiation */ 
CTickets g_Tickets;
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTickets::CTickets()
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTickets::~CTickets()
{
}

//+------------------------------------------------------------------+
//| Function - CTicket *CTickets::GetTicketById(int ticket_id)       |
//+------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                    |
//|                                                                  |
//| Return - Pointer of ticket instance                              |
//|                                                                  |
//| Details - Get pointer of ticket instance by ticket id            |
//+------------------------------------------------------------------+
CTicket *CTickets::GetTicketById(int ticket_id)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         return &info[i];
      }
   }
   return NULL;
}

//+------------------------------------------------------------------+
//| Function - CTicket *CTickets::GetTicketByIndex(int idx)          |
//+------------------------------------------------------------------+
//| Param - idx : Index number                                       |
//|                                                                  |
//| Return - Pointer of ticket instance                              |
//|                                                                  |
//| Details - Get pointer of ticket instance by index number         |
//+------------------------------------------------------------------+
CTicket *CTickets::GetTicketByIndex(int idx)
{
   if(idx < MAX_TICKET)
   {
      return &info[idx];
   }
   return NULL;
}

//+------------------------------------------------------------------+
//| Function - int CTickets::GetIndexByTicketId(int ticket_id)       |
//+------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                    |
//|                                                                  |
//| Return - Index number point to ticket id                         |
//|                                                                  |
//| Details - Get index number point to ticket id                    |
//+------------------------------------------------------------------+
int CTickets::GetIndexByTicketId(int ticket_id)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         return i;
      }
   }
   return -1;
}

//+---------------------------------------------------------------------------------------+
//| Function - bool CTickets::AddState(const int ticket_id, const s_TicketState &state)   |
//+---------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                         |
//|         &state : Struct with ticket state                                             |
//|                                                                                       |
//| Return - TRUE : Successfully add/modify ticket state to buffer                        |
//|          False : Failed to add/modify ticket state to buffer                          |
//|                                                                                       |
//| Details - Add/modify ticket state to buffer                                           |
//+---------------------------------------------------------------------------------------+
bool CTickets::AddState(const int ticket_id, const s_TicketState &state)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         info[i].state = state;
         state_mode[i] = true;
         return true;
      }
   }
   
   if(m_total >= MAX_TICKET)
   {
      info[m_total].id = ticket_id;
      info[m_total].state = state;
      state_mode[m_total] = true;
      m_total++;
      return true;
   }
   return false;
}

//+---------------------------------------------------------------------------------------+
//| Function - bool CTickets::AddSltp(const int ticket_id, const s_IntSltp &sltp)         |
//+---------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                         |
//|         &sltp : Struct with internal stop loss and take profit                        |
//|                                                                                       |
//| Return - TRUE : Successfully add/modify internal stop loss and take profit to buffer  |
//|          False : Failed to add/modify internal stop loss and take profit to buffer    |
//|                                                                                       |
//| Details - Add/modify internal stop loss and take profit to buffer                     |
//+---------------------------------------------------------------------------------------+
bool CTickets::AddSltp(const int ticket_id, const s_IntSltp &sltp)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         info[i].sltp = sltp;
         sltp_mode[i] = true;
         return true;
      }
   }

   if(m_total >= MAX_TICKET)
   {
      info[m_total].id = ticket_id;
      info[m_total].sltp = sltp;
      sltp_mode[m_total] = true;
      m_total++;
      return true;
   }
   return false;
}

//+---------------------------------------------------------------------------------------+
//| Function - bool CTickets::AddTrail(const int ticket_id, const s_Trail &trail)         |
//+---------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                         |
//|         &trail : Struct with trail info                                               |
//|                                                                                       |
//| Return - TRUE : Successfully add/modify trail info to buffer                          |
//|          False : Failed to add/modify trail info to buffer                            |
//|                                                                                       |
//| Details - Add/modify trail info to buffer                                             |
//+---------------------------------------------------------------------------------------+
bool CTickets::AddTrail(const int ticket_id, const s_Trail &trail)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         info[i].trail = trail;
         trail_mode[i] = true;
         return true;
      }
   }
   
   if(m_total >= MAX_TICKET)
   {
      info[m_total].id = ticket_id;
      info[m_total].trail = trail;
      trail_mode[m_total] = true;
      m_total++;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Function - bool CTickets::DeleteState(const int ticket_id)       |
//+------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                    |
//|                                                                  |
//| Return - TRUE : Successfully delete ticket state from buffer     |
//|          False : Ticket state not found from buffer              |
//|                                                                  |
//| Details - Delete ticket state from bufferd                       |
//+------------------------------------------------------------------+
bool CTickets::DeleteState(const int ticket_id)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         ZeroMemory(info[i].state);
         if(false == sltp_mode[i] && false == trail_mode[i])
         {
            DeleteTicket(i);
         }
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------------------------+
//| Function - bool CTickets::DeleteSltp(const int ticket_id)                          |
//+------------------------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                                      |
//|                                                                                    |
//| Return - TRUE : Successfully delete internal stop loss and take profit from buffer |
//|          False : Internal stop loss and take profit not found from buffer          |
//|                                                                                    |
//| Details - Delete internal stop loss and take profit from buffer                    |
//+------------------------------------------------------------------------------------+
bool CTickets::DeleteSltp(const int ticket_id)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         ZeroMemory(info[i].sltp);
         if(false == state_mode[i] && false == trail_mode[i])
         {
            DeleteTicket(i);
         }
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Function - bool CTickets::DeleteTrail(const int ticket_id)       |
//+------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                    |
//|                                                                  |
//| Return - TRUE : Successfully delete trail info from buffer       |
//|          False : Trail info not found from buffer                |
//|                                                                  |
//| Details - Delete trail info from bufferd                         |
//+------------------------------------------------------------------+
bool CTickets::DeleteTrail(const int ticket_id)
{
   for(int i=0; i<m_total && i<MAX_TICKET; i++)
   {
      if(ticket_id == info[i].id)
      {
         ZeroMemory(info[i].trail);
         if(false == state_mode[i] && false == sltp_mode[i])
         {
            DeleteTicket(i);
         }
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Function - bool CTickets::DeleteTicket(const int ticket_id)      |
//+------------------------------------------------------------------+
//| Param - ticket_id : Ticket Id                                    |
//|                                                                  |
//| Return - TRUE : Successfully delete ticket from buffer           |
//|          False : Ticket not found from buffer                    |
//|                                                                  |
//| Details - Delete ticket from bufferd                             |
//+------------------------------------------------------------------+
bool CTickets::DeleteTicket(int idx)
{
   if(idx > MAX_TICKET)
   {
      info[idx].id = info[m_total-1].id;
      info[idx].state = info[m_total-1].state;
      info[idx].sltp = info[m_total-1].sltp;
      info[idx].trail = info[m_total-1].trail;
      ZeroMemory(info[m_total-1]);
      m_total--;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+