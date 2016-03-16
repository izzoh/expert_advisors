//+------------------------------------------------------------------+
//|                                      Expert Advisor Template.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright     "Andrew R. Young"
#property link          "http://www.expertadvisorbook.com"
#property description   ""
#property strict


//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

#include <Mql4Book\Trade.mqh>
CTrade Trade;
CCount Count;

#include <Mql4Book\Timer.mqh>
CTimer Timer;
CNewBar NewBar;

#include <Mql4Book\TrailingStop.mqh>
#include <Mql4Book\MoneyManagement.mqh>
#include <Mql4Book\Indicators.mqh>


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string TradeSettings;    	// Trade Settings
input int MagicNumber = 101;
input int Slippage = 10;
input bool TradeOnBarOpen = true;

sinput string MoneyManagement;  	// Money Management
input bool UseMoneyManagement = true;
input double RiskPercent = 2;
input double FixedLotSize = 0.1;

sinput string Stops;				   // Stop Loss & Take Profit
input int StopLoss = 0;
input int TakeProfit = 0;

sinput string TrailingStopSettings;	// Trailing Stop
input bool UseTrailingStop = true;
input int TrailingStop = 0;
input int MinProfit = 0;
input int Step = 10;

sinput string BreakEvenSettings;		// Break Even Stop
input bool UseBreakEvenStop = false;
input int MinimumProfit = 0;
input int LockProfit = 0;

sinput string TimerSettings;			// Timer
input bool UseTimer = false;
input int StartHour = 0;
input int StartMinute = 0;
input int EndHour = 0;
input int EndMinute = 0;
input bool UseLocalTime = false;


//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+

int gBuyTicket, gSellTicket;


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
   // Check timer
   bool tradeEnabled = true;
   if(UseTimer == true)
   {
      tradeEnabled = Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute,UseLocalTime);
   }
   
   // Check for bar open
   bool newBar = true;
   int barShift = 0;
   
   if(TradeOnBarOpen == true)
   {
      newBar = NewBar.CheckNewBar(_Symbol,_Period);
      barShift = 1;
   }

   // Trading
   if(newBar == true && tradeEnabled == true)
   {
	   // Money management
      double lotSize = FixedLotSize;
      if(UseMoneyManagement == true)
      {
         lotSize = MoneyManagement(_Symbol,FixedLotSize,RiskPercent,StopLoss); 
      }
      
      // Open buy order
      if(  )
      {
         gBuyTicket = Trade.OpenBuyOrder(_Symbol,lotSize);
         ModifyStopsByPoints(gBuyTicket,StopLoss,TakeProfit);
      }
      
      // Open sell order
      else if(  )
      {
         gSellTicket = Trade.OpenSellOrder(_Symbol,lotSize);
         ModifyStopsByPoints(gSellTicket,StopLoss,TakeProfit);
      }
   } 

   // Break even stop
   if(UseBreakEvenStop == true)
   {
      BreakEvenStopAll(MinimumProfit,LockProfit);   
   }
   
   // Trailing stop
   if(UseTrailingStop == true)
   {
      TrailingStopAll(TrailingStop,MinProfit,Step);
   }   
 
}