//+------------------------------------------------------------------+
//|                                                 TrailingStop.mqh |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright   "Andrew R. Young"
#property link        "http://www.expertadvisorbook.com"
#property description "Trailing stop and break even stop functions"
#property strict

/*
 Creative Commons Attribution-NonCommercial 3.0 Unported
 http://creativecommons.org/licenses/by-nc/3.0/

 You may use this file in your own personal projects. You may 
 modify it if necessary. You may even share it, provided the 
 copyright above is present. No commercial use is permitted! 
*/

#include "Trade.mqh"


//+------------------------------------------------------------------+
//| Trailing stop (points)                                           |
//+------------------------------------------------------------------+

bool TrailingStop(int pTicket, int pTrailPoints, int pMinProfit = 0, int pStep = 10)
{
   if(pTrailPoints <= 0) return(false);

   bool result = OrderSelect(pTicket,SELECT_BY_TICKET);

   if(result == false)
   {
      Print("Trailing stop: #",pTicket," not found!");
      return false;
   }
   
   bool setTrailingStop = false;
   
   // Get order and symbol information
   double orderType = OrderType();
   string orderSymbol = OrderSymbol();
   double orderStopLoss = OrderStopLoss();
   double orderTakeProfit = OrderTakeProfit();
   double orderOpenPrice = OrderOpenPrice();
   
   double point = MarketInfo(orderSymbol,MODE_POINT);
   int digits = (int)MarketInfo(orderSymbol,MODE_DIGITS);
   
   // Convert inputs to prices
   double trailPoints = pTrailPoints * point;
   double minProfit = pMinProfit * point;
   
   double step = pStep * point;
   if(pStep < 10) step = 10 * point;
   
   double trailStopPrice = 0;
   double currentProfit = 0;
   
   // Calculate trailing stop
   if(orderType == OP_BUY)
   {
      double bid = MarketInfo(orderSymbol,MODE_BID);
      
      trailStopPrice = bid - trailPoints;
      trailStopPrice = NormalizeDouble(trailStopPrice,digits);
      
      currentProfit = bid - orderOpenPrice;
      
      if(trailStopPrice > orderStopLoss + step && currentProfit >= minProfit)
      {
         setTrailingStop = true;
      }
   }
   else if(orderType == OP_SELL)
   {
      double ask = MarketInfo(orderSymbol,MODE_ASK);
      
      trailStopPrice = ask + trailPoints;
      trailStopPrice = NormalizeDouble(trailStopPrice,digits);
      
      currentProfit = orderOpenPrice - ask;
      
      if((trailStopPrice < orderStopLoss - step || orderStopLoss == 0) && currentProfit >= minProfit)
      {
         setTrailingStop = true;
      }
   }
   
   // Set trailing stop
   if(setTrailingStop == true)
   {
      result = ModifyOrder(pTicket,0,trailStopPrice,orderTakeProfit);
      
      if(result == false)
      {
         Print("Trailing stop for #",pTicket," not set! Trail Stop: ",trailStopPrice,", Current Stop: ",orderStopLoss," Current Profit: ",currentProfit);
      }
      else
      {
         Comment("Trailing stop for #",pTicket," modified");
         Print("Trailing stop for #",pTicket," modified");
         return true;
      }   
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| Trailing stop (price)                                           |
//+------------------------------------------------------------------+

bool TrailingStop(int pTicket, double pTrailPrice, int pMinProfit = 0, int pStep = 10)
{
   if(pTrailPrice <= 0) return false;
   
   bool result = OrderSelect(pTicket,SELECT_BY_TICKET);

   if(result == false)
   {
      Print("Trailing stop: #",pTicket," not found!");
      return false;
   }
      
   bool setTrailingStop = false;
   
   // Get order and symbol information
   double orderType = OrderType();
   string orderSymbol = OrderSymbol();
   double orderStopLoss = OrderStopLoss();
   double orderTakeProfit = OrderTakeProfit();
   double orderOpenPrice = OrderOpenPrice();
   
   double point = MarketInfo(orderSymbol,MODE_POINT);
   int digits = (int)MarketInfo(orderSymbol,MODE_DIGITS);
   
   // Convert inputs to prices
   double minProfit = pMinProfit * point;
   double step = pStep * point;
   if(pStep < 10) step = 10 * point;
   
   double currentProfit = 0;
   
   // Calculate trailing stop
   if(orderType == OP_BUY)
   {
      pTrailPrice = AdjustBelowStopLevel(orderSymbol,pTrailPrice);
      
      double bid = MarketInfo(orderSymbol,MODE_BID);
      currentProfit = bid - orderOpenPrice;
      
      if(pTrailPrice > orderStopLoss + step && currentProfit >= minProfit)
      {
         setTrailingStop = true;
      }
   }
   else if(orderType == OP_SELL)
   {
      pTrailPrice = AdjustAboveStopLevel(orderSymbol,pTrailPrice);
      
      double ask = MarketInfo(orderSymbol,MODE_ASK);
      currentProfit = orderOpenPrice - ask;
      
      if((pTrailPrice < orderStopLoss - step || orderStopLoss == 0) && currentProfit >= minProfit)
      {
         setTrailingStop = true;
      }
   }
   
   // Set trailing stop
   if(setTrailingStop == true)
   {
      result = ModifyOrder(pTicket,0,pTrailPrice,orderTakeProfit);
      
      if(result == false)
      {
         Print("Trailing stop for #",pTicket," not set! Trail Stop: ",pTrailPrice,", Current Stop: ",orderStopLoss," Current Profit: ",currentProfit);
      }
      else
      {
         Comment("Trailing stop for #",pTicket," modified");
         Print("Trailing stop for #",pTicket," modified");
         return true;
      }
   }
   
   return false;
}


//+------------------------------------------------------------------+
//| Trailing stop (multiple orders)                                  |
//+------------------------------------------------------------------+

void TrailingStopAll(int pTrailPoints, int pMinProfit = 0, int pStep = 10)
{
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      // Skip if magic number doesn't match or order is pending
      int magicNumber = OrderMagicNumber();
      double orderType = OrderType();
      
      if(magicNumber == CTrade::GetMagicNumber() && (orderType == OP_BUY || orderType == OP_SELL))
      {
         TrailingStop(OrderTicket(),pTrailPoints,pMinProfit,pStep);
      } 
   }
}

void TrailingStopAll(double pTrailPrice, int pMinProfit = 0, int pStep = 10)
{
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      // Skip if magic number doesn't match or order is pending
      int magicNumber = OrderMagicNumber();
      double orderType = OrderType();
      
      if(magicNumber == CTrade::GetMagicNumber() && (orderType == OP_BUY || orderType == OP_SELL))
      {
         TrailingStop(OrderTicket(),pTrailPrice,pMinProfit,pStep);
      } 
   }
}


//+------------------------------------------------------------------+
//| Break even stop                                                  |
//+------------------------------------------------------------------+

bool BreakEvenStop(int pTicket, int pMinProfit, int pLockProfit = 0)
{
   if(pMinProfit <= 0) return false;
   
   bool result = OrderSelect(pTicket,SELECT_BY_TICKET);

   if(result == false)
   {
      Print("Break even stop: #",pTicket," not found!");
      return false;
   }

   bool setBreakEvenStop = false;
   
   // Get order and symbol information
   double orderType = OrderType();
   string orderSymbol = OrderSymbol();
   double orderStopLoss = OrderStopLoss();
   double orderTakeProfit = OrderTakeProfit();
   double orderOpenPrice = OrderOpenPrice();
   
   double point = MarketInfo(orderSymbol,MODE_POINT);
   int digits = (int)MarketInfo(orderSymbol,MODE_DIGITS);
   
   // Convert inputs to prices
   double minProfit = pMinProfit * point;
   
   double lockProfit = 0;
   if(pLockProfit > 0) lockProfit = pLockProfit * point;
   
   double breakEvenStop = 0;
   double currentProfit = 0;
   
   if(orderType == OP_BUY)
   {
      double bid = MarketInfo(orderSymbol,MODE_BID);
      
      breakEvenStop = orderOpenPrice + lockProfit;
      breakEvenStop = NormalizeDouble(breakEvenStop,digits);
            
      currentProfit = bid - orderOpenPrice;
      currentProfit = NormalizeDouble(currentProfit,digits);
      
      orderStopLoss = NormalizeDouble(orderStopLoss,digits);
      
      if(breakEvenStop > orderStopLoss && currentProfit >= minProfit)
      {
         setBreakEvenStop = true;
      }
   } 
   else if(orderType == OP_SELL)
   {
      double ask = MarketInfo(orderSymbol,MODE_ASK);
      
      breakEvenStop = orderOpenPrice - lockProfit;
      breakEvenStop = NormalizeDouble(breakEvenStop,digits);
      
      currentProfit = orderOpenPrice - ask;
      currentProfit = NormalizeDouble(currentProfit,digits);
      
      orderStopLoss = NormalizeDouble(orderStopLoss,digits);
      
      if((breakEvenStop < orderStopLoss || orderStopLoss == 0) && currentProfit >= minProfit)
      {
         setBreakEvenStop = true;
      }
   } 
   
   if(setBreakEvenStop == true)
   {
      result = ModifyOrder(pTicket,0,breakEvenStop,orderTakeProfit);
      
      if(result == false)
      {
         Print("Break even stop for #",pTicket," not set! Break Even Stop: ",breakEvenStop,", Current Stop: ",orderStopLoss," Current Profit: ",currentProfit);
      }
      else
      {
         Comment("Break even stop for #",pTicket," modified");
         Print("Break even stop for #",pTicket," modified");
         return true;
      }
   }
   
   return false; 
}

void BreakEvenStopAll(int pMinProfit, int pLockProfit = 0)
{
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      // Skip if magic number doesn't match or order is pending
      int magicNumber = OrderMagicNumber();
      double orderType = OrderType();
      
      if(magicNumber == CTrade::GetMagicNumber() && (orderType == OP_BUY || orderType == OP_SELL))
      {
         BreakEvenStop(OrderTicket(),pMinProfit,pLockProfit);
      } 
   }
}