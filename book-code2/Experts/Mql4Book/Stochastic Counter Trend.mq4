//+------------------------------------------------------------------+
//|                                     Stochastic Counter Trend.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright     "Andrew R. Young"
#property link          "http://www.expertadvisorbook.com"
#property description   "Counter-trend system with stochastics"
#property strict


//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

#include <Mql4Book\Trade.mqh>
CTrade Trade;
CCount Count;

#include <Mql4Book\Indicators.mqh>
#include <Mql4Book\TrailingStop.mqh>
#include <Mql4Book\MoneyManagement.mqh>


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string TS;    // Trade Settings
input int MagicNumber = 101;
input int Slippage = 10;
input bool TradeOnBarOpen = true;

sinput string MM; 	// Money Management
input bool UseMoneyManagement = true;
input double RiskPercent = 2;
input double FixedLotSize = 0.1;
input int StopLoss = 200;
input int TakeProfit = 0;

sinput string ST;    // Stochastics Settings
input int KPeriod = 14;
input int DPeriod = 3;
input int Slowing = 5;
input ENUM_MA_METHOD MaMethod = MODE_SMA;
input int PriceField = 0;


//+------------------------------------------------------------------+
//| Global variables and indicators                                   |
//+------------------------------------------------------------------+

CiStochastic Stoch(_Symbol,_Period,KPeriod,DPeriod,Slowing,MaMethod,PriceField);


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   // Set magic number
   Trade.SetMagicNumber(MagicNumber);
   Trade.SetSlippage(Slippage);
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   // Money management
   double lotSize = FixedLotSize;
   if(UseMoneyManagement == true)
   {
      lotSize = MoneyManagement(_Symbol,FixedLotSize,RiskPercent,StopLoss); 
   }
   
   // Close buy order
   if(Stoch.Main(1) < Stoch.Signal(1) && Count.Buy() > 0)
   {
      Trade.CloseAllBuyOrders();
   }
   
   // Close sell order
   if(Stoch.Main(1) > Stoch.Signal(1) && Count.Sell() > 0)
   {
      Trade.CloseAllSellOrders();
   }
   
   // Open buy order
   if( Stoch.Main(2) < 20 && Stoch.Main(2) < Stoch.Signal(2) 
      && Stoch.Main(1) > Stoch.Signal(1) && Count.Buy() == 0 )
   {
      int ticket = Trade.OpenBuyOrder(_Symbol,lotSize);
      ModifyStopsByPoints(ticket,StopLoss,TakeProfit);
   }
   
   // Open sell order
   else if( Stoch.Main(2) > 80 && Stoch.Main(2) > Stoch.Signal(2) 
      && Stoch.Main(1) < Stoch.Signal(1) && Count.Sell() == 0 )
   {
      int ticket = Trade.OpenSellOrder(_Symbol,lotSize);
      ModifyStopsByPoints(ticket,StopLoss,TakeProfit);
   }
}
  
//+------------------------------------------------------------------+

