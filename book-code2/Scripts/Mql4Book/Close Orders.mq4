//+------------------------------------------------------------------+
//|                                                 Close Orders.mq4 |
//|                                                     Andrew Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright   "Andrew Young"
#property link        "http://www.expertadvisorbook.com"
#property description "Close all orders of the specified type for the specified symbol."

/*
Creative Commons Attribution-NonCommercial 3.0 Unported
http://creativecommons.org/licenses/by-nc/3.0/

You may use this file in your own personal projects. You
may modify it if necessary. You may even share it, provided
the copyright above is present. No commercial use permitted. 
*/


#property script_show_inputs

#include <Mql4Book\Trade.mqh>
CTrade Trade;

enum CloseTypes
{
	All,		// All Orders
	Market,		// Market Orders
	Pending,	// Pending Orders
	Buy,		// Buy Market
	Sell,		// Sell Market
	BuyStop,	// Buy Stop
	SellStop,	// Sell Stop
	BuyLimit,	// Buy Limit
	SellLimit,	// Sell Limit
};

input CloseTypes CloseType = All;
input string CloseSymbol = "";


void OnStart()
{
	for(int i = 0; i <= OrdersTotal() - 1; i++)
	{
		// Select order
		bool result = OrderSelect(i,SELECT_BY_POS);
		
		if(result == true)
		{
			string orderSymbol = OrderSymbol();
			string closeSymbol = StringTrimRight(CloseSymbol);
			
			if(closeSymbol != "" && closeSymbol != orderSymbol) continue;
			
			int orderType = OrderType();
			int orderTicket = OrderTicket();
			
			bool closeOrder = false;
			
			switch(CloseType)
			{
				case All:
					closeOrder = true;
					break;
					
				case Market:
					if(orderType == OP_BUY || orderType == OP_SELL) closeOrder = true;
					break;
					
				case Pending:
					if(orderType >= 2) closeOrder = true;		
					break;
					
				case Buy:
					if(orderType == OP_BUY) closeOrder = true;
					break;
					
				case Sell:
					if(orderType == OP_SELL) closeOrder = true;
					break;
					
				case BuyStop:
					if(orderType == OP_BUYSTOP) closeOrder = true;
					break;
				
				case SellStop:
					if(orderType == OP_SELLSTOP) closeOrder = true;
					break;
					
				case BuyLimit:
					if(orderType == OP_BUYLIMIT) closeOrder = true;
					break;
					
				case SellLimit:
					if(orderType == OP_SELLLIMIT) closeOrder = true;
					break;
			}
			
			if(closeOrder == true)
			{
				bool closed = false;
				
				if(orderType == OP_BUY || orderType == OP_SELL)
				{
					closed = Trade.CloseMarketOrder(orderTicket,0,clrNONE);
				}
				else
				{
					closed = Trade.DeletePendingOrder(orderTicket,clrNONE);
				}
				
				if(closed == true) i--;
			}
		}
	}
}

