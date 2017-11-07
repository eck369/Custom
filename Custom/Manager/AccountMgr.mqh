//+------------------------------------------------------------------+
//| Class CAccountMgr                                                |
//| Function : Account opetation                                     |
//+------------------------------------------------------------------+
#include <Custom\Configuration.mqh>

struct s_Margin
{
   double used;
   double free;
};

//+------------------------------------------------------------------+
//| CAccountMgr Class                                                |
//+------------------------------------------------------------------+
class CAccountMgr
  {  
public:
                     CAccountMgr();
                    ~CAccountMgr();
   double            Balance(void);
   double            Equity(void);
   double            Profit(void);
   double            Deposit(void);
   double            UsedMargin(void);
   double            FreeMargin(void);
   
   s_Margin          MarginCheck(string symbol,double volume, double price);
   double            CalcVolumeBySl(string symbol, double percent, double sl_delta_pt);
  };

/*  CAccountMgr class instantiation */
CAccountMgr g_AccountMgr;

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAccountMgr::CAccountMgr()
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAccountMgr::~CAccountMgr()
{
}

//+------------------------------------------------------------------+
//| Function - double CAccountMgr::Balance(void)                     |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Account balance                                         |
//|                                                                  |
//| Details - Get account balance                                    |  
//+------------------------------------------------------------------+
double CAccountMgr::Balance(void)
{
   return(AccountInfoDouble(ACCOUNT_BALANCE));
}

//+------------------------------------------------------------------+
//| Function - double CAccountMgr::Equity(void)                      |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Account equity                                          |
//|                                                                  |
//| Details - Get account equity                                     |  
//+------------------------------------------------------------------+
double CAccountMgr::Equity(void)
{
   return(AccountInfoDouble(ACCOUNT_EQUITY));
}

//+------------------------------------------------------------------+
//| Function - double CAccountMgr::Profit(void)                      |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Account profit                                          |
//|                                                                  |
//| Details - Get account profit                                     |  
//+------------------------------------------------------------------+
double CAccountMgr::Profit(void)
{
   return(AccountInfoDouble(ACCOUNT_PROFIT));
}

//+------------------------------------------------------------------+
//| Function - double CAccountMgr::Deposit(void)                     |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Account deposit                                         |
//|                                                                  |
//| Details - Get account deposit                                    |  
//+------------------------------------------------------------------+
double CAccountMgr::Deposit(void)
{
   double deposit = -1; 
   for (int i=0; i<OrdersHistoryTotal(); i++) 
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) 
      {
         if(6 == OrderType())
         {
            deposit = OrderProfit(); 
            break;      
         }
      }     
   } 
   return deposit;
}

//+------------------------------------------------------------------+
//| Function - double CAccountMgr::UsedMargin(void)                  |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Account used margin                                     |
//|                                                                  |
//| Details - Get account used margin                                |  
//+------------------------------------------------------------------+
double CAccountMgr::UsedMargin(void)
{
   return(AccountInfoDouble(ACCOUNT_MARGIN));
}

//+------------------------------------------------------------------+
//| Function - double CAccountMgr::FreeMargin(void)                  |
//+------------------------------------------------------------------+
//| Param - void                                                     |
//|                                                                  |
//| Return - Account free margin                                     |
//|                                                                  |
//| Details - Get account free margin                                |  
//+------------------------------------------------------------------+
double CAccountMgr::FreeMargin(void)
{
   return(AccountInfoDouble(ACCOUNT_MARGIN_FREE));
}

//+---------------------------------------------------------------------------------+
//| Function - double CAccountMgr::CalcVolumeBySl(string symbol, double percent,    |
//|                                               double sl_delta_pt)               |
//+---------------------------------------------------------------------------------+
//| Param - symbol : Symbol                                                         |
//|         percent : Percentage of Free Margin                                     |
//|         sl_delta_pt : Maximum affordable stop loss point                        |
//|                                                                                 |
//| Return - Volume                                                                 |
//|                                                                                 |
//| Details - Calculate volume by maximum stop loss point                           |  
//+---------------------------------------------------------------------------------+
double CAccountMgr::CalcVolumeBySl(string symbol, double percent, double sl_delta_pt)
{
//--- Parameter Check  
   if(NULL == symbol)
   {
      Print("[Err]"+__FUNCTION__+" : NULL Symbol");
      return -1;
   }
   
   if(percent < 0 || percent > 100)
   {
      Print("[Err]"+__FUNCTION__+" : Invalid Percentage, ",percent);
      return -1;
   }
   
   if(sl_delta_pt < 0)
   {
      Print("[Err]"+__FUNCTION__+" : Invalid stop loss point, ",sl_delta_pt);
      return -1;
   }
//---//
   
   double step_vol = SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double min_vol = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double max_vol=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double volume = NormalizeDouble(AccountFreeMargin()*percent/100.00, 2)/(SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE)*sl_delta_pt);

   if(step_vol > 0.0) volume = step_vol*MathFloor(volume/step_vol);
   if(volume < min_vol) volume = 0.0;
   if(volume > max_vol) volume = max_vol;
   
   return volume;
}

//+------------------------------------------------------------------------------------+
//| Function - double s_Margin CAccountMgr::MarginCheck(string symbol, double volume,  | 
//|                                                     double price)                  |
//+------------------------------------------------------------------------------------+
//| Param - symbol : Symbol                                                            |
//|         volume : Order lot size                                                    |
//|         price : Order price                                                        |
//|                                                                                    |
//| Return - Available free margin after order                                         |
//|                                                                                    |
//| Details - Calculate available margin left after order is placed                    |  
//+------------------------------------------------------------------------------------+
s_Margin CAccountMgr::MarginCheck(string symbol, double volume, double price)
{
   s_Margin margin;
   margin.used = price*volume*SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE)/AccountLeverage();
   margin.free =  AccountFreeMargin() - margin.used;
   return margin;
}

//+------------------------------------------------------------------+