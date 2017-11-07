/* Maximum ticket number allowable to be tracked for :   */
/* 1. Ticket state                                       */
/* 2. Internal stop loss and take profit                 */
/* 3. Trailling                                          */
#define MAX_TICKET   100 
 
/* Maximum Symbol Bar to be stored */  
#define MAX_BAR      20

/* Trail Info */
struct s_Trail
{  
   double min_profit_pt;
   double trail_pt;
   double step_pt;
};

