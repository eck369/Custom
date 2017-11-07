//+------------------------------------------------------------------+
//| Class CStrategyBase                                              |
//| Function : Base class for Strategy Class                         |
//+------------------------------------------------------------------+
#include <Custom\Manager\Tickets.mqh>

//+------------------------------------------------------------------+
//| CStrategyBase Class                                              |
//+------------------------------------------------------------------+
class CStrategyBase
  {
public:
                     CStrategyBase();
                    ~CStrategyBase();
                    
   virtual bool      AutoTrade(void) = 0;
   void              OnTicketEvent(const int ticket_id, const s_TicketState &state);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStrategyBase::CStrategyBase()
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStrategyBase::~CStrategyBase()
{
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
void CStrategyBase::OnTicketEvent(const int ticket_id, const s_TicketState &state)
{
}

//+------------------------------------------------------------------+
