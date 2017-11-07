//+------------------------------------------------------------------+
//| Class CTrailBase                                                 |
//| Function : Base class for Trail Class                            |
//+------------------------------------------------------------------+
#include <Custom\Configuration.mqh>
#include <Custom\Manager\Tickets.mqh>

//+------------------------------------------------------------------+
//| CTrailBase Class                                                 |
//+------------------------------------------------------------------+
class CTrailBase
  {  
public:
                     CTrailBase();
                    ~CTrailBase();
                    
   //--- Trail operation                 
   bool              AddTrailStop(int ticket_id, s_Trail &trail);
   bool              DeleteTrailStop(int ticket_id);
	virtual bool      Trailing(CTicket *ticket) = 0;
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrailBase::CTrailBase()
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrailBase::~CTrailBase()
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
bool CTrailBase::AddTrailStop(int ticket_id, s_Trail &trail)
{
   if(OrderSelect(ticket_id, SELECT_BY_TICKET, MODE_TRADES))
   {
      return (g_Tickets.AddTrail(ticket_id, trail));
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
bool CTrailBase::DeleteTrailStop(int ticket_id)
{
   return (g_Tickets.DeleteTrail(ticket_id));
}

//+------------------------------------------------------------------+