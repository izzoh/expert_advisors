//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright   "Andrew R. Young"
#property link        "http://www.expertadvisorbook.com"
#property description "Trading classes and functions"
#property strict


/*
 Creative Commons Attribution-NonCommercial 3.0 Unported
 http://creativecommons.org/licenses/by-nc/3.0/

 You may use this file in your own personal projects. You may 
 modify it if necessary. You may even share it, provided the 
 copyright above is present. No commercial use is permitted! 
*/


#include <stdlib.mqh>

#define MAX_RETRIES 3		// Max retries on error
#define RETRY_DELAY 3000	// Retry delay in ms


//+------------------------------------------------------------------+
//| Trading class                                                    |
//+------------------------------------------------------------------+

class CTrade
{
   private:
      static int _magicNumber;
      static int _slippage;
      
      enum CLOSE_MARKET_TYPE
      {
         CLOSE_BUY,
         CLOSE_SELL,
         CLOSE_ALL_MARKET
      };
      
      enum CLOSE_PENDING_TYPE
      {
         CLOSE_BUY_LIMIT,
         CLOSE_SELL_LIMIT,
         CLOSE_BUY_STOP,
         CLOSE_SELL_STOP,
         CLOSE_ALL_PENDING
      };
      
      int OpenMarketOrder(string pSymbol, int pType, double pVolume, string pComment, color pArrow);
      int OpenPendingOrder(string pSymbol, int pType, double pVolume, double pPrice, double pStop, double pProfit, string pComment, datetime pExpiration, color pArrow);
      
      bool CloseMultipleOrders(CLOSE_MARKET_TYPE pCloseType);
      bool DeleteMultipleOrders(CLOSE_PENDING_TYPE pDeleteType);

   
   public:
      int OpenBuyOrder(string pSymbol, double pVolume, string pComment = "Buy order", color pArrow = clrGreen);
      int OpenSellOrder(string pSymbol, double pVolume, string pComment = "Sell order", color pArrow = clrRed);
      
      int OpenBuyStopOrder(string pSymbol, double pVolume, double pPrice, double pStop, double pProfit, string pComment = "Buy stop order", datetime pExpiration = 0, color pArrow = clrBlue);
      int OpenSellStopOrder(string pSymbol, double pVolume, double pPrice, double pStop, double pProfit, string pComment = "Sell stop order", datetime pExpiration = 0, color pArrow = clrIndigo);
      int OpenBuyLimitOrder(string pSymbol, double pVolume, double pPrice, double pStop, double pProfit, string pComment = "Buy limit order", datetime pExpiration = 0, color pArrow = clrCornflowerBlue);
      int OpenSellLimitOrder(string pSymbol, double pVolume, double pPrice, double pStop, double pProfit, string pComment = "Sell limit order", datetime pExpiration = 0, color pArrow = clrMediumSlateBlue);
      
      bool CloseMarketOrder(int pTicket, double pVolume = 0, color pArrow = clrRed);
      bool CloseAllBuyOrders();
      bool CloseAllSellOrders();
      bool CloseAllMarketOrders();
      
      bool DeletePendingOrder(int pTicket, color pArrow = clrRed);
      bool DeleteAllBuyStopOrders();
      bool DeleteAllSellStopOrders();
      bool DeleteAllBuyLimitOrders();
      bool DeleteAllSellLimitOrders();
      bool DeleteAllPendingOrders();
      
      static void SetMagicNumber(int pMagic);
      static int GetMagicNumber();
      
      static void SetSlippage(int pSlippage);     
};

int CTrade::_magicNumber = 0;
int CTrade::_slippage = 10;


//+------------------------------------------------------------------+
//| Market order functions                                           |
//+------------------------------------------------------------------+

int CTrade::OpenMarketOrder(string pSymbol, int pType, double pVolume, string pComment, color pArrow)
{
	int retryCount = 0;
	int ticket = 0;
	int errorCode = 0;
	
	double orderPrice = 0;
	
	string orderType;
	string errDesc;
	
	// Order retry loop
	while(retryCount <= MAX_RETRIES) 
	{
		while(IsTradeContextBusy()) Sleep(10);
		
		// Get current bid/ask price
		if(pType == OP_BUY) orderPrice = MarketInfo(pSymbol,MODE_ASK);
		else if(pType == OP_SELL) orderPrice = MarketInfo(pSymbol,MODE_BID);

		// Place market order
		ticket = OrderSend(pSymbol,pType,pVolume,orderPrice,_slippage,0,0,pComment,_magicNumber,0,pArrow);
	   
		// Error handling
		if(ticket == -1)
		{
			errorCode = GetLastError();
			errDesc = ErrorDescription(errorCode);
			bool checkError = RetryOnError(errorCode);
			orderType = OrderTypeToString(pType);
			
			// Unrecoverable error
			if(checkError == false)
			{
				Alert("Open ",orderType," order: Error ",errorCode," - ",errDesc);
				Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",orderPrice);
				break;
			}
			
			// Retry on error
			else
			{
				Print("Server error detected, retrying...");
				Sleep(RETRY_DELAY);
				retryCount++;
			}
		}
		
		// Order successful
		else
		{
		   orderType = OrderTypeToString(pType);
		   Comment(orderType," order #",ticket," opened on ",pSymbol);
		   Print(orderType," order #",ticket," opened on ",pSymbol);
		   break;
		} 
   }
   
   // Failed after retry
	if(retryCount > MAX_RETRIES)
	{
		Alert("Open ",orderType," order: Max retries exceeded. Error ",errorCode," - ",errDesc);
		Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",orderPrice);
	}
   
   return(ticket);
}  


int CTrade::OpenBuyOrder(string pSymbol,double pVolume,string pComment="Buy order",color pArrow=32768)
{
   int ticket = OpenMarketOrder(pSymbol, OP_BUY, pVolume, pComment, pArrow);
   return(ticket);
}


int CTrade::OpenSellOrder(string pSymbol,double pVolume,string pComment="Sell order",color pArrow=255)
{
   int ticket = OpenMarketOrder(pSymbol, OP_SELL, pVolume, pComment, pArrow);
   return(ticket);
}


//+------------------------------------------------------------------+
//| Pending order functions                                          |
//+------------------------------------------------------------------+

int CTrade::OpenPendingOrder(string pSymbol,int pType,double pVolume,double pPrice,double pStop,double pProfit,string pComment,datetime pExpiration,color pArrow)
{
   int retryCount = 0;
	int ticket = 0;
	int errorCode = 0;

	string orderType;
	string errDesc;
	
	// Order retry loop
	while(retryCount <= MAX_RETRIES)
	{
		while(IsTradeContextBusy()) Sleep(10);
		ticket = OrderSend(pSymbol, pType, pVolume, pPrice, _slippage, pStop, pProfit, pComment, _magicNumber, pExpiration, pArrow);
		
		// Error handling
   	if(ticket == -1)
   	{
   		errorCode = GetLastError();
   		errDesc = ErrorDescription(errorCode);
   		bool checkError = RetryOnError(errorCode);
   		orderType = OrderTypeToString(pType);
      	
      	// Unrecoverable error
      	if(checkError == false)  
   		{
     			Alert("Open ",orderType," order: Error ",errorCode," - ",errDesc);
     			Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",pPrice,", SL: ",pStop,", TP: ",pProfit,", Expiration: ",pExpiration);
   			break;
   		}
   		
   		// Retry on error
   		else
   		{
   			Print("Server error detected, retrying...");
   			Sleep(RETRY_DELAY);
   			retryCount++;
   		}
   	}
   	
   	// Order successful
   	else
   	{
   	   orderType = OrderTypeToString(pType);
   	   Comment(orderType," order #",ticket," opened on ",pSymbol);
   	   Print(orderType," order #",ticket," opened on ",pSymbol);
   	   break;
   	} 
   }
   
   // Failed after retry
	if(retryCount > MAX_RETRIES)
	{
		Alert("Open ",orderType," order: Max retries exceeded. Error ",errorCode," - ",errDesc);
		Print("Symbol: ",pSymbol,", Volume: ",pVolume,", Price: ",pPrice,", SL: ",pStop,", TP: ",pProfit,", Expiration: ",pExpiration);
	}

	return(ticket);
}


int CTrade::OpenBuyStopOrder(string pSymbol,double pVolume,double pPrice,double pStop,double pProfit,string pComment="Buy stop order",datetime pExpiration=0,color pArrow=16711680)
{
   int ticket = OpenPendingOrder(pSymbol, OP_BUYSTOP, pVolume, pPrice, pStop, pProfit, pComment, pExpiration, pArrow);
   return(ticket);
}


int CTrade::OpenSellStopOrder(string pSymbol,double pVolume,double pPrice,double pStop,double pProfit,string pComment="Sell stop order",datetime pExpiration=0,color pArrow=8519755)
{
   int ticket = OpenPendingOrder(pSymbol, OP_SELLSTOP, pVolume, pPrice, pStop, pProfit, pComment, pExpiration, pArrow);
   return(ticket);
}


int CTrade::OpenBuyLimitOrder(string pSymbol,double pVolume,double pPrice,double pStop,double pProfit,string pComment="Buy limit order",datetime pExpiration=0,color pArrow=15570276)
{
   int ticket = OpenPendingOrder(pSymbol, OP_BUYLIMIT, pVolume, pPrice, pStop, pProfit, pComment, pExpiration, pArrow);
   return(ticket);
}


int CTrade::OpenSellLimitOrder(string pSymbol,double pVolume,double pPrice,double pStop,double pProfit,string pComment="Sell limit order",datetime pExpiration=0,color pArrow=15624315)
{
   int ticket = OpenPendingOrder(pSymbol, OP_SELLLIMIT, pVolume, pPrice, pStop, pProfit, pComment, pExpiration, pArrow);
   return(ticket);
}


//+------------------------------------------------------------------+
//| Close market orders                                              |
//+------------------------------------------------------------------+

bool CTrade::CloseMarketOrder(int pTicket,double pVolume=0.000000,color pArrow=255)
{
   int retryCount = 0;
   int errorCode = 0;
   
   double closePrice = 0;
   double closeVolume = 0;
   
   bool result;
   
   string errDesc;
   
   // Select ticket
   result = OrderSelect(pTicket,SELECT_BY_TICKET);
   
   // Exit with error if order select fails
   if(result == false)
   {
      errorCode = GetLastError();
      errDesc = ErrorDescription(errorCode);
      
      Alert("Close order: Error selecting order #",pTicket,". Error ",errorCode," - ",errDesc);
      return(result);
   }
   
   // Close entire order if pVolume not specified, or if pVolume is greater than order volume
   if(pVolume == 0 || pVolume > OrderLots()) closeVolume = OrderLots();
   else closeVolume = pVolume;
   
   // Order retry loop
	while(retryCount <= MAX_RETRIES)    
	{
      while(IsTradeContextBusy()) Sleep(10);
      
      // Get current bid/ask price
      if(OrderType() == OP_BUY) closePrice = MarketInfo(OrderSymbol(),MODE_BID);
      else if(OrderType() == OP_SELL) closePrice = MarketInfo(OrderSymbol(),MODE_ASK);
      
      result = OrderClose(pTicket,closeVolume,closePrice,_slippage,pArrow);
      
      if(result == false)
      {
         errorCode = GetLastError();
         errDesc = ErrorDescription(errorCode);
   		bool checkError = RetryOnError(errorCode);
      	
      	// Unrecoverable error
      	if(checkError == false)
   		{
   			Alert("Close order #",pTicket,": Error ",errorCode," - ",errDesc);
   			Print("Price: ",closePrice,", Volume: ",closeVolume);
   			break;
   		}
   		
   		// Retry on error
   		else
   		{
   			Print("Server error detected, retrying...");
   			Sleep(RETRY_DELAY);
   			retryCount++;
   		}
      }
      
      // Order successful
   	else
   	{
   	   Comment("Order #",pTicket," closed");
   	   Print("Order #",pTicket," closed");
   	   break;
   	} 
   }
   
   // Failed after retry
	if(retryCount > MAX_RETRIES)
	{
		Alert("Close order #",pTicket,": Max retries exceeded. Error ",errorCode," - ",errDesc);
		Print("Price: ",closePrice,", Volume: ",closeVolume);
	}
	
	return(result);
}


bool CTrade::CloseMultipleOrders(CLOSE_MARKET_TYPE pCloseType)
{
   bool error = false;
   bool closeOrder = false;
   
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      int orderType = OrderType();
      int orderMagicNumber = OrderMagicNumber();
      int orderTicket = OrderTicket();
      double orderVolume = OrderLots();
      
      // Determine if order type matches pCloseType
      if( (pCloseType == CLOSE_ALL_MARKET && (orderType == OP_BUY || orderType == OP_SELL)) 
         || (pCloseType == CLOSE_BUY && orderType == OP_BUY) 
         || (pCloseType == CLOSE_SELL && orderType == OP_SELL) )
      {
         closeOrder = true;
      }
      else closeOrder = false;
      
      // Close order if pCloseType and magic number match currently selected order
      if(closeOrder == true && orderMagicNumber == _magicNumber)
      {
         result = CloseMarketOrder(orderTicket,orderVolume);
         
         if(result == false)
         {
            Print("Close multiple orders: ",OrderTypeToString(orderType)," #",orderTicket," not closed");
            error = true;
         }
         else order--;
      }
   }
   
   return(error);
}


bool CTrade::CloseAllBuyOrders(void)
{
   bool result = CloseMultipleOrders(CLOSE_BUY);
   return(result);
}


bool CTrade::CloseAllSellOrders(void)
{
   bool result = CloseMultipleOrders(CLOSE_SELL);
   return(result);
}


bool CTrade::CloseAllMarketOrders(void)
{
   bool result = CloseMultipleOrders(CLOSE_ALL_MARKET);
   return(result);
}


//+------------------------------------------------------------------+
//| Delete pending orders                                            |
//+------------------------------------------------------------------+

bool CTrade::DeletePendingOrder(int pTicket,color pArrow=255)
{
   int retryCount = 0;
   int errorCode = 0;
   
   bool result = false;
   
   string errDesc;
  
   // Order retry loop
	while(retryCount <= MAX_RETRIES)    
	{
      while(IsTradeContextBusy()) Sleep(10);
      result = OrderDelete(pTicket,pArrow);
      
      if(result == false)
      {
         errorCode = GetLastError();
         errDesc = ErrorDescription(errorCode);
   		bool checkError = RetryOnError(errorCode);
      	
      	// Unrecoverable error
      	if(checkError == false)
   		{
   			Alert("Delete pending order #",pTicket,": Error ",errorCode," - ",errDesc);
   			break;
   		}
   		
   		// Retry on error
   		else
   		{
   			Print("Server error detected, retrying...");
   			Sleep(RETRY_DELAY);
   			retryCount++;
   		}
      }
      
      // Order successful
   	else
   	{
   	   Comment("Pending order #",pTicket," deleted");
   	   Print("Pending order #",pTicket," deleted");
   	   break;
   	} 
   }
   
   // Failed after retry
	if(retryCount > MAX_RETRIES)
	{
		Alert("Delete pending order #",pTicket,": Max retries exceeded. Error ",errorCode," - ",errDesc);
	}
	
	return(result);
}


bool CTrade::DeleteMultipleOrders(CLOSE_PENDING_TYPE pDeleteType)
{
   bool error = false;
   bool deleteOrder = false;
   
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      int orderType = OrderType();
      int orderMagicNumber = OrderMagicNumber();
      int orderTicket = OrderTicket();
      double orderVolume = OrderLots();
      
      // Determine if order type matches pCloseType
      if( (pDeleteType == CLOSE_ALL_PENDING && orderType != OP_BUY && orderType != OP_SELL)
         || (pDeleteType == CLOSE_BUY_LIMIT && orderType == OP_BUYLIMIT) 
         || (pDeleteType == CLOSE_SELL_LIMIT && orderType == OP_SELLLIMIT) 
         || (pDeleteType == CLOSE_BUY_STOP && orderType == OP_BUYSTOP)
         || (pDeleteType == CLOSE_SELL_STOP && orderType == OP_SELLSTOP) )
      {
         deleteOrder = true;
      }
      else deleteOrder = false;
      
      // Close order if pCloseType and magic number match currently selected order
      if(deleteOrder == true && orderMagicNumber == _magicNumber)
      {
         result = DeletePendingOrder(orderTicket);
         
         if(result == false)
         {
            Print("Delete multiple orders: ",OrderTypeToString(orderType)," #",orderTicket," not deleted");
            error = true;
         }
         else order--;
      }
   }
   
   return(error);
}


bool CTrade::DeleteAllBuyLimitOrders(void)
{
   bool result = DeleteMultipleOrders(CLOSE_BUY_LIMIT);
   return(result);
}


bool CTrade::DeleteAllBuyStopOrders(void)
{
   bool result = DeleteMultipleOrders(CLOSE_BUY_STOP);
   return(result);
}


bool CTrade::DeleteAllSellLimitOrders(void)
{
   bool result = DeleteMultipleOrders(CLOSE_SELL_LIMIT);
   return(result);
}


bool CTrade::DeleteAllSellStopOrders(void)
{
   bool result = DeleteMultipleOrders(CLOSE_SELL_STOP);
   return(result);
}


bool CTrade::DeleteAllPendingOrders(void)
{
   bool result = DeleteMultipleOrders(CLOSE_ALL_PENDING);
   return(result);
}


//+------------------------------------------------------------------+
//| Set trade properties                                             |
//+------------------------------------------------------------------+

static void CTrade::SetMagicNumber(int pMagic)
{
   if(_magicNumber != 0)
   {
      Alert("Magic number changed! Any orders previously opened by this expert advisor will no longer be handled!");
   }
   
   _magicNumber = pMagic;
}

static int CTrade::GetMagicNumber(void)
{
   return(_magicNumber);
}


static void CTrade::SetSlippage(int pSlippage)
{
   _slippage = pSlippage;
}


//+------------------------------------------------------------------+
//| Internal functions                                               |
//+------------------------------------------------------------------+

bool RetryOnError(int pErrorCode)
{
	// Retry on these error codes
	switch(pErrorCode)
	{
		case ERR_BROKER_BUSY:
		case ERR_COMMON_ERROR:
		case ERR_NO_ERROR:
		case ERR_NO_CONNECTION:
		case ERR_NO_RESULT:
		case ERR_SERVER_BUSY:
		case ERR_NOT_ENOUGH_RIGHTS:
      case ERR_MALFUNCTIONAL_TRADE:
      case ERR_TRADE_CONTEXT_BUSY:
      case ERR_TRADE_TIMEOUT:
      case ERR_REQUOTE:
      case ERR_TOO_MANY_REQUESTS:
      case ERR_OFF_QUOTES:
      case ERR_PRICE_CHANGED:
      case ERR_TOO_FREQUENT_REQUESTS:
		
		return(true);
	}
	
	return(false);
}


string OrderTypeToString(int pType)
{
	string orderType;
	if(pType == OP_BUY) orderType = "Buy";
	else if(pType == OP_SELL) orderType = "Sell";
	else if(pType == OP_BUYSTOP) orderType = "Buy stop";
	else if(pType == OP_BUYLIMIT) orderType = "Buy limit";
	else if(pType == OP_SELLSTOP) orderType = "Sell stop";
	else if(pType == OP_SELLLIMIT) orderType = "Sell limit";
	else orderType = "Invalid order type";
	return(orderType);
}


//+------------------------------------------------------------------+
//| Modify orders                                                    |
//+------------------------------------------------------------------+

bool ModifyOrder(int pTicket, double pPrice, double pStop = 0, double pProfit = 0, datetime pExpiration = 0, color pArrow = clrOrange)
{
   int retryCount = 0;
   int errorCode = 0;
   
	bool result = false;
	
	string errDesc;
	
	// Order retry loop
	while(retryCount <= MAX_RETRIES)
	{
		while(IsTradeContextBusy()) Sleep(10);
		
		result = OrderModify(pTicket, pPrice, pStop, pProfit, pExpiration, pArrow);
		errorCode = GetLastError();
		
		// Error handling - Ignore error code 1
   	if(result == false && errorCode != ERR_NO_RESULT)
   	{
   		errDesc = ErrorDescription(errorCode);
   		bool checkError = RetryOnError(errorCode);
      	
      	// Unrecoverable error
      	if(checkError == false)
   		{
   			Alert("Modify order #",pTicket,": Error ",errorCode," - ",errDesc);
   			Print("Price: ",pPrice,", SL: ",pStop,", TP: ",pProfit,", Expiration: ",pExpiration);
   			break;
   		}
   		
   		// Retry on error
   		else
   		{
   			Print("Server error detected, retrying...");
   			Sleep(RETRY_DELAY);
   			retryCount++;
   		}
   	}
   	
   	// Order successful
   	else
   	{
   	   Comment("Order #",pTicket," modified");
   	   Print("Order #",pTicket," modified");
   	   break;
   	} 
   }
   
   // Failed after retry
	if(retryCount > MAX_RETRIES)
	{
		Alert("Modify order #",pTicket,": Max retries exceeded. Error ",errorCode," - ",errDesc);
		Print("Price: ",pPrice,", SL: ",pStop,", TP: ",pProfit,", Expiration: ",pExpiration);
	}

	return(result);
}


bool ModifyStopsByPoints(int pTicket, int pStopPoints, int pProfitPoints = 0, int pMinPoints = 10)
{
   if(pStopPoints == 0 && pProfitPoints == 0) return false;
   
   bool result = OrderSelect(pTicket,SELECT_BY_TICKET);
   
   if(result == false)
   {
      Print("Modify stops: #",pTicket," not found!");
      return false;
   }
   
   double orderType = OrderType();
   double orderOpenPrice = OrderOpenPrice();
   string orderSymbol = OrderSymbol();
   
   double stopLoss = 0;
   double takeProfit = 0;
   
   if(orderType == OP_BUY)
   {
      stopLoss = BuyStopLoss(orderSymbol,pStopPoints,orderOpenPrice);
      if(stopLoss != 0) stopLoss = AdjustBelowStopLevel(orderSymbol,stopLoss,pMinPoints);
      
      takeProfit = BuyTakeProfit(orderSymbol,pProfitPoints,orderOpenPrice);
      if(takeProfit != 0) takeProfit = AdjustAboveStopLevel(orderSymbol,takeProfit,pMinPoints);
   }
   else if(orderType == OP_SELL)
   {
      stopLoss = SellStopLoss(orderSymbol,pStopPoints,orderOpenPrice);
      if(stopLoss != 0) stopLoss = AdjustAboveStopLevel(orderSymbol,stopLoss,pMinPoints);
      
      takeProfit = SellTakeProfit(orderSymbol,pProfitPoints,orderOpenPrice);
      if(takeProfit != 0) takeProfit = AdjustBelowStopLevel(orderSymbol,takeProfit,pMinPoints);
   }
   
   result = ModifyOrder(pTicket,0,stopLoss,takeProfit);
   return(result);
}


bool ModifyStopsByPrice(int pTicket, double pStopPrice, double pProfitPrice = 0, int pMinPoints = 10)
{
   if(pStopPrice == 0 && pProfitPrice == 0) return false;
   
   bool result = OrderSelect(pTicket,SELECT_BY_TICKET);
   
   if(result == false)
   {
      Print("Modify stops: #",pTicket," not found!");
      return false;
   }
   
   double orderType = OrderType();
   string orderSymbol = OrderSymbol();
   
   double stopLoss = 0;
   double takeProfit = 0;
   
   if(orderType == OP_BUY)
   {
      if(pStopPrice != 0) stopLoss = AdjustBelowStopLevel(orderSymbol,pStopPrice,pMinPoints);
      if(pProfitPrice != 0) takeProfit = AdjustAboveStopLevel(orderSymbol,pProfitPrice,pMinPoints);
   }
   else if(orderType == OP_SELL)
   {
      if(pStopPrice != 0) stopLoss = AdjustAboveStopLevel(orderSymbol,pStopPrice,pMinPoints);
      if(pProfitPrice != 0) takeProfit = AdjustBelowStopLevel(orderSymbol,pProfitPrice,pMinPoints);
   }
   
   result = ModifyOrder(pTicket,0,stopLoss,takeProfit);
   return(result);
}


//+------------------------------------------------------------------+
//| Stop loss & take profit calculation                              |
//+------------------------------------------------------------------+

double BuyStopLoss(string pSymbol,int pStopPoints, double pOpenPrice = 0)
{
	if(pStopPoints <= 0) return(0);
	
	double openPrice;
	if(pOpenPrice > 0) openPrice = pOpenPrice;
	else openPrice = SymbolInfoDouble(pSymbol,SYMBOL_ASK);
	
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double stopLoss = openPrice - (pStopPoints * point);
	
	long digits = SymbolInfoInteger(pSymbol,SYMBOL_DIGITS);
	stopLoss = NormalizeDouble(stopLoss,(int)digits);
	
	return(stopLoss);
}


double SellStopLoss(string pSymbol,int pStopPoints, double pOpenPrice = 0)
{
	if(pStopPoints <= 0) return(0);
	
	double openPrice;
	if(pOpenPrice > 0) openPrice = pOpenPrice;
	else openPrice = SymbolInfoDouble(pSymbol,SYMBOL_BID);
	
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double stopLoss = openPrice + (pStopPoints * point);
	
	long digits = SymbolInfoInteger(pSymbol,SYMBOL_DIGITS);
	stopLoss = NormalizeDouble(stopLoss,(int)digits);
	
	return(stopLoss);
}


double BuyTakeProfit(string pSymbol,int pProfitPoints, double pOpenPrice = 0)
{
	if(pProfitPoints <= 0) return(0);
	
	double openPrice;
	if(pOpenPrice > 0) openPrice = pOpenPrice;
	else openPrice = SymbolInfoDouble(pSymbol,SYMBOL_ASK);
	
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double takeProfit = openPrice + (pProfitPoints * point);
	
	long digits = SymbolInfoInteger(pSymbol,SYMBOL_DIGITS);
	takeProfit = NormalizeDouble(takeProfit,(int)digits);
	return(takeProfit);
}


double SellTakeProfit(string pSymbol,int pProfitPoints, double pOpenPrice = 0)
{
	if(pProfitPoints <= 0) return(0);
	
	double openPrice;
	if(pOpenPrice > 0) openPrice = pOpenPrice;
	else openPrice = SymbolInfoDouble(pSymbol,SYMBOL_BID);
	
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double takeProfit = openPrice - (pProfitPoints * point);
	
	long digits = SymbolInfoInteger(pSymbol,SYMBOL_DIGITS);
	takeProfit = NormalizeDouble(takeProfit,(int)digits);
	return(takeProfit);
}


//+------------------------------------------------------------------+
//| Stop level verification                                         |
//+------------------------------------------------------------------+

// Check stop level
bool CheckAboveStopLevel(string pSymbol, double pPrice, int pPoints = 10)
{
	double currPrice = SymbolInfoDouble(pSymbol,SYMBOL_ASK);
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double stopLevel = SymbolInfoInteger(pSymbol,SYMBOL_TRADE_STOPS_LEVEL) * point;
	double stopPrice = currPrice + stopLevel;
	double addPoints = pPoints * point;
	
	if(pPrice >= stopPrice + addPoints) return(true);
	else return(false);
}


bool CheckBelowStopLevel(string pSymbol, double pPrice, int pPoints = 10)
{
	double currPrice = SymbolInfoDouble(pSymbol,SYMBOL_BID);
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double stopLevel = SymbolInfoInteger(pSymbol,SYMBOL_TRADE_STOPS_LEVEL) * point;
	double stopPrice = currPrice - stopLevel;
	double addPoints = pPoints * point;
	
	if(pPrice <= stopPrice - addPoints) return(true);
	else return(false);
}


// Adjust price to stop level
double AdjustAboveStopLevel(string pSymbol, double pPrice, int pPoints = 10)
{
	double currPrice = SymbolInfoDouble(pSymbol,SYMBOL_ASK);
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double stopLevel = SymbolInfoInteger(pSymbol,SYMBOL_TRADE_STOPS_LEVEL) * point;
	double stopPrice = currPrice + stopLevel;
	double addPoints = pPoints * point;
	
	if(pPrice > stopPrice + addPoints) return(pPrice);
	else
	{
		double newPrice = stopPrice + addPoints;
		Print("Price adjusted above stop level to "+DoubleToString(newPrice));
		return(newPrice);
	}
}


double AdjustBelowStopLevel(string pSymbol, double pPrice, int pPoints = 10)
{
	double currPrice = SymbolInfoDouble(pSymbol,SYMBOL_BID);
	double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
	double stopLevel = SymbolInfoInteger(pSymbol,SYMBOL_TRADE_STOPS_LEVEL) * point;
	double stopPrice = currPrice - stopLevel;
	double addPoints = pPoints * point;
	
	if(pPrice < stopPrice - addPoints) return(pPrice);
	else
	{
		double newPrice = stopPrice - addPoints;
		Print("Price adjusted below stop level to "+DoubleToString(newPrice));
		return(newPrice);
	}
}


//+------------------------------------------------------------------+
//| Order counts                                                     |
//+------------------------------------------------------------------+

class CCount
{
   private:  
      enum COUNT_ORDER_TYPE
      {
         COUNT_BUY,
         COUNT_SELL,
         COUNT_BUY_STOP,
         COUNT_SELL_STOP,
         COUNT_BUY_LIMIT,
         COUNT_SELL_LIMIT,
         COUNT_MARKET,
         COUNT_PENDING,
         COUNT_ALL
      };
      
      int CountOrders(COUNT_ORDER_TYPE pType);
 
      
   public:
      int Buy();
      int Sell();
      int BuyStop();
      int SellStop();
      int BuyLimit();
      int SellLimit();
      int TotalMarket();
      int TotalPending();
      int TotalOrders();
};


int CCount::CountOrders(COUNT_ORDER_TYPE pType)
{
   // Order counts
   int buy = 0, sell = 0, buyStop = 0, sellStop = 0, 
      buyLimit = 0, sellLimit = 0, totalOrders = 0;
   
   // Loop through open order pool from oldest to newest
   for(int order = 0; order <= OrdersTotal() - 1; order++)
   {
      // Select order
      bool result = OrderSelect(order,SELECT_BY_POS);
      
      int orderType = OrderType();
      int orderMagicNumber = OrderMagicNumber();
      
      // Add to order count if magic number matches
      if(orderMagicNumber == CTrade::GetMagicNumber())
      {
         switch(orderType)
         {
            case OP_BUY:
               buy++;
               break;
               
            case OP_SELL:
               sell++;
               break;
               
            case OP_BUYLIMIT:
               buyLimit++;
               break;
               
            case OP_SELLLIMIT:
               sellLimit++;
               break;   
               
            case OP_BUYSTOP:
               buyStop++;
               break;
               
            case OP_SELLSTOP:
               sellStop++;
               break;          
         }
         
         totalOrders++;
      }
   }
   
   // Return order count based on pType
   int returnTotal = 0;
   switch(pType)
   {
      case COUNT_BUY:
         returnTotal = buy;
         break;
         
      case COUNT_SELL:
         returnTotal = sell;
         break;
         
      case COUNT_BUY_LIMIT:
         returnTotal = buyLimit;
         break;
         
      case COUNT_SELL_LIMIT:
         returnTotal = sellLimit;
         break;
         
      case COUNT_BUY_STOP:
         returnTotal = buyStop;
         break;
         
      case COUNT_SELL_STOP:
         returnTotal = sellStop;
         break;
         
      case COUNT_MARKET:
         returnTotal = buy + sell;
         break;
         
      case COUNT_PENDING:
         returnTotal = buyLimit + sellLimit + buyStop + sellStop;
         break;   
         
      case COUNT_ALL:
         returnTotal = totalOrders; 
         break;        
   }
   
   return(returnTotal);
}


int CCount::Buy(void)
{
   int total = CountOrders(COUNT_BUY);
   return(total);
}

int CCount::Sell(void)
{
   int total = CountOrders(COUNT_SELL);
   return(total);
}

int CCount::BuyLimit(void)
{
   int total = CountOrders(COUNT_BUY_LIMIT);
   return(total);
}

int CCount::SellLimit(void)
{
   int total = CountOrders(COUNT_SELL_LIMIT);
   return(total);
}

int CCount::BuyStop(void)
{
   int total = CountOrders(COUNT_BUY_STOP);
   return(total);
}

int CCount::SellStop(void)
{
   int total = CountOrders(COUNT_SELL_STOP);
   return(total);
}

int CCount::TotalMarket(void)
{
   int total = CountOrders(COUNT_MARKET);
   return(total);
}

int CCount::TotalPending(void)
{
   int total = CountOrders(COUNT_PENDING);
   return(total);
}

int CCount::TotalOrders(void)
{
   int total = CountOrders(COUNT_ALL);
   return(total);
}