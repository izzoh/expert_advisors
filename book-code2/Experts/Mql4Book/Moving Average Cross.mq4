//+------------------------------------------------------------------+
//|                                         Moving Average Cross.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright     "Andrew R. Young"
#property link          "http://www.expertadvisorbook.com"
#property description   "Trend trading system with two moving averages, money management and fixed trailing stop"
#property strict


//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

#include <Mql4Book\Trade.mqh>
CTrade Trade;
CCount Count;

#include <Mql4Book\Indicators.mqh>

#include <Mql4Book\Timer.mqh>
CNewBar NewBar;

#include <Mql4Book\TrailingStop.mqh>

#include <Mql4Book\MoneyManagement.mqh>


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+

sinput string TradeSettings;    // Trade Settings
input int MagicNumber = 101;
input int Slippage = 10;
input bool TradeOnBarOpen = true;

sinput string MoneySettings;  	// Money Management
input bool UseMoneyManagement = true;
input double RiskPercent = 2;
input double FixedLotSize = 0.1;

sinput string StopSettings;					// Stop Loss & Take Profit
input int StopLoss = 0;
input int TakeProfit = 0;

sinput string TrailingStopSettings;   	// Trailing Stop
input bool UseTrailingStop = true;
input int TrailingStop = 200;
input int MinProfit = 100;
input int Step = 10;

sinput string FastMaSettings;   // Fast Moving Average
input int FastMaPeriod = 5;
input ENUM_MA_METHOD FastMaMethod = MODE_EMA;
input ENUM_APPLIED_PRICE FastMaPrice = PRICE_CLOSE;
input int MinCrossSpread = 10;

sinput string SlowMaSettings;   // Slow Moving Average
input int SlowMaPeriod = 20;
input ENUM_MA_METHOD SlowMaMethod = MODE_EMA;
input ENUM_APPLIED_PRICE SlowMaPrice = PRICE_CLOSE;


//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+

CiMA FastMa(_Symbol,_Period,FastMaPeriod,0,FastMaMethod,FastMaPrice);
CiMA SlowMa(_Symbol,_Period,SlowMaPeriod,0,SlowMaMethod,SlowMaPrice);


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
   // Check for bar open
   bool newBar = true;
   int barShift = 0;
   
   if(TradeOnBarOpen == true)
   {
      newBar = NewBar.CheckNewBar(_Symbol,_Period);
      barShift = 1;
   }

   if(newBar == true)
   {
      double minSpread = MinCrossSpread * _Point;
      
      // Close orders
      if(FastMa.Main(barShift) > SlowMa.Main(barShift) + minSpread) 
      {
         Trade.CloseAllSellOrders();
      }
      else if(FastMa.Main(barShift) < SlowMa.Main(barShift) - minSpread)
      {
         Trade.CloseAllBuyOrders();
      } 
      
      // Money management
      double lotSize = FixedLotSize;
      if(UseMoneyManagement == true)
      {
         lotSize = MoneyManagement(_Symbol,FixedLotSize,RiskPercent,StopLoss); 
      }
      
      // Open buy order
      if( FastMa.Main(barShift) > SlowMa.Main(barShift) + minSpread 
         && FastMa.Main(barShift + 1) <= SlowMa.Main(barShift + 1) + minSpread 
         && Count.Buy() == 0 )
      {
         int ticket = Trade.OpenBuyOrder(_Symbol,lotSize);
         ModifyStopsByPoints(ticket,StopLoss,TakeProfit);
      }
      
      // Open sell order
      else if( FastMa.Main(barShift) < SlowMa.Main(barShift) - minSpread 
         && FastMa.Main(barShift + 1) >= SlowMa.Main(barShift + 1) - minSpread 
         && Count.Sell() == 0 )
      {
         int ticket = Trade.OpenSellOrder(_Symbol,lotSize);
         ModifyStopsByPoints(ticket,StopLoss,TakeProfit);
      }
   }  
   
   // Trailing stop
   if(UseTrailingStop == true)
   {
      TrailingStopAll(TrailingStop,MinProfit,Step);
   } 
    
}
  
//+------------------------------------------------------------------+
