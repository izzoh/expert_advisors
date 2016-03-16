//+------------------------------------------------------------------+
//|                                               IncludeExample.mqh |
//|                                                     Andrew Young |
//|                                   http://www.easyexpertforex.com |
//+------------------------------------------------------------------+

#property copyright "Andrew Young"
#property link      "http://www.easyexpertforex.com"

#include <stdlib.mqh>


double CalcLotSize(bool argDynamicLotSize, double argEquityPercent,double argStopLoss, double argFixedLotSize)
	{
		if(argDynamicLotSize == true && argStopLoss > 0)
			{
				double RiskAmount = AccountEquity() * (argEquityPercent / 100);
				double TickValue = MarketInfo(Symbol(),MODE_TICKVALUE);
				if(Point == 0.001 || Point == 0.00001) TickValue *= 10;
				double LotSize = (RiskAmount / argStopLoss) / TickValue;
			}
		else LotSize = argFixedLotSize;
	
		return(LotSize);
	}


double VerifyLotSize(double argLotSize)
	{
		if(argLotSize < MarketInfo(Symbol(),MODE_MINLOT))
			{
				argLotSize = MarketInfo(Symbol(),MODE_MINLOT);
			}
		else if(argLotSize > MarketInfo(Symbol(),MODE_MAXLOT))
			{
				argLotSize = MarketInfo(Symbol(),MODE_MAXLOT);
			}	
			
		if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1)
			{
				argLotSize = NormalizeDouble(argLotSize,1);
			}
		else argLotSize = NormalizeDouble(argLotSize,2);
		
		return(argLotSize);
	} 


int OpenBuyOrder(string argSymbol, double argLotSize, double argSlippage, double argMagicNumber, string argComment = "Buy Order")
	{
		while(IsTradeContextBusy()) Sleep(10);

		// Place Buy Order
		int Ticket = OrderSend(argSymbol,OP_BUY,argLotSize,MarketInfo(argSymbol,MODE_ASK),argSlippage,0,0,argComment,argMagicNumber,0,Green);

		// Error Handling
		if(Ticket == -1)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Open Buy Order - Error	",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK)," Lots: ",argLotSize);
				Print(ErrLog);
			}
		
		return(Ticket);
	}     
	
	
int OpenSellOrder(string argSymbol, double argLotSize, double argSlippage, double argMagicNumber, string argComment = "Sell Order")
	{
		while(IsTradeContextBusy()) Sleep(10);

		// Place Sell Order
		int Ticket = OrderSend(argSymbol,OP_SELL,argLotSize,MarketInfo(argSymbol,MODE_BID),argSlippage,0,0,argComment,argMagicNumber,0,Red);

		// Error Handling
		if(Ticket == -1)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Open Sell Order - Error ",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK)," Lots: ",argLotSize);
				Print(ErrLog);
			}

		return(Ticket);
	}     
	

int OpenBuyStopOrder(string argSymbol, double argLotSize, double argPendingPrice, double argStopLoss, double argTakeProfit, double argSlippage,  
	double argMagicNumber, datetime argExpiration = 0, string argComment = "Buy Stop Order")
	{
		while(IsTradeContextBusy()) Sleep(10);

		// Place Buy Stop Order
		int Ticket = OrderSend(argSymbol,OP_BUYSTOP,argLotSize,argPendingPrice,argSlippage,argStopLoss,argTakeProfit,argComment,argMagicNumber,argExpiration,Green);

		// Error Handling
		if(Ticket == -1)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Open Buy Stop Order - Error ",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Ask: ",MarketInfo(argSymbol,MODE_ASK)," Lots: ",argLotSize,
					" Price: ",argPendingPrice," Stop: ",argStopLoss," Profit: ",argTakeProfit," Expiration: ",TimeToStr(argExpiration));
				Print(ErrLog);
			}
	
		return(Ticket);
	} 
		
		
int OpenSellStopOrder(string argSymbol, double argLotSize, double argPendingPrice, 	double argStopLoss, double argTakeProfit, double argSlippage,  
	double argMagicNumber, datetime argExpiration = 0, string argComment = "Sell Stop Order")
	{
		while(IsTradeContextBusy()) Sleep(10);

		// Place Sell Stop Order
		int Ticket = OrderSend(argSymbol,OP_SELLSTOP,argLotSize,argPendingPrice,argSlippage,argStopLoss,argTakeProfit,argComment,argMagicNumber,argExpiration,Red);

		// Error Handling
		if(Ticket == -1)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Open Sell Stop Order - Error ",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Lots: ",argLotSize,
					" Price: ",argPendingPrice," Stop: ",argStopLoss," Profit: ",argTakeProfit," Expiration: ",TimeToStr(argExpiration));
				Print(ErrLog);
			}
			
		return(Ticket);
	} 


int OpenBuyLimitOrder(string argSymbol, double argLotSize, double argPendingPrice, 	double argStopLoss, double argTakeProfit, double argSlippage,  
	double argMagicNumber, datetime argExpiration, string argComment = "Buy Limit Order")
	{
		while(IsTradeContextBusy()) Sleep(10);

		// Place Buy Limit Order
		int Ticket = OrderSend(argSymbol,OP_BUYLIMIT,argLotSize,argPendingPrice,argSlippage,argStopLoss,argTakeProfit,argComment,argMagicNumber,argExpiration,Green);

		// Error Handling
		if(Ticket == -1)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Open Buy Limit Order - Error ",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Lots: ",argLotSize,
					" Price: ",argPendingPrice," Stop: ",argStopLoss," Profit: ",argTakeProfit," Expiration: ",TimeToStr(argExpiration));
				Print(ErrLog);
			}
			
		return(Ticket);
	} 
		
		
int OpenSellLimitOrder(string argSymbol, double argLotSize, double argPendingPrice, double argStopLoss, double argTakeProfit, double argSlippage,  
	double argMagicNumber, datetime argExpiration, string argComment = "Sell Limit Order")
	{
		while(IsTradeContextBusy()) Sleep(10);

		// Place Sell Limit Order
		int Ticket = OrderSend(argSymbol,OP_SELLLIMIT,argLotSize,argPendingPrice,argSlippage,argStopLoss,argTakeProfit,argComment,argMagicNumber,argExpiration,Red);

		// Error Handling
		if(Ticket == -1)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Open Sell Stop Order - Error ",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Ask: ",MarketInfo(argSymbol,MODE_ASK)," Lots: ",argLotSize,
					" Price: ",argPendingPrice," Stop: ",argStopLoss," Profit: ",argTakeProfit," Expiration: ",TimeToStr(argExpiration));
				Print(ErrLog);
			}
			
		return(Ticket);
	} 

		
double PipPoint(string Currency)
	{
		int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
		if(CalcDigits == 2 || CalcDigits == 3) double CalcPoint = 0.01;
		else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
		return(CalcPoint);
	}


int GetSlippage(string Currency, int SlippagePips)
	{
		int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
		if(CalcDigits == 2 || CalcDigits == 4) double CalcSlippage = SlippagePips;
		else if(CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
		return(CalcSlippage);
	}
	

bool CloseBuyOrder(string argSymbol, int argCloseTicket, double argSlippage)
	{
		OrderSelect(argCloseTicket,SELECT_BY_TICKET);

		if(OrderCloseTime() == 0)
			{
				double CloseLots = OrderLots();		
				
				while(IsTradeContextBusy()) Sleep(10);

				double ClosePrice = MarketInfo(argSymbol,MODE_BID);

				bool Closed = OrderClose(argCloseTicket,CloseLots,ClosePrice,argSlippage,Green);

				if(Closed == false)
					{
						int ErrorCode = GetLastError();
						string ErrDesc = ErrorDescription(ErrorCode);

						string ErrAlert = StringConcatenate("Close Buy Order - Error: ",ErrorCode,": ",ErrDesc);
						Alert(ErrAlert);

						string ErrLog = StringConcatenate("Ticket: ",argCloseTicket," Bid: ",MarketInfo(argSymbol,MODE_BID));
						Print(ErrLog);
					}
			}
		return(Closed);
	}
	
	
bool CloseSellOrder(string argSymbol, int argCloseTicket, double argSlippage)
	{
		OrderSelect(argCloseTicket,SELECT_BY_TICKET);

		if(OrderCloseTime() == 0)
			{
				double CloseLots = OrderLots();		
				
				while(IsTradeContextBusy()) Sleep(10);

				double ClosePrice = MarketInfo(argSymbol,MODE_ASK);

				bool Closed = OrderClose(argCloseTicket,CloseLots,ClosePrice,argSlippage,Red);

				if(Closed == false)
					{
						int ErrorCode = GetLastError();
						string ErrDesc = ErrorDescription(ErrorCode);

						string ErrAlert = StringConcatenate("Close Sell Order - Error: ",ErrorCode,": ",ErrDesc);
						Alert(ErrAlert);

						string ErrLog = StringConcatenate("Ticket: ",argCloseTicket," Ask: ",MarketInfo(argSymbol,MODE_ASK));
						Print(ErrLog);
					}
			}
		return(Closed);
	}
		
	
bool ClosePendingOrder(string argSymbol, int argCloseTicket)
	{
		OrderSelect(argCloseTicket,SELECT_BY_TICKET);

		if(OrderCloseTime() == 0)
			{			
				while(IsTradeContextBusy()) Sleep(10);

				bool Deleted = OrderDelete(argCloseTicket,Red);

				if(Deleted == false)
					{
						int ErrorCode = GetLastError();
						string ErrDesc = ErrorDescription(ErrorCode);

						string ErrAlert = StringConcatenate("Close Pending Order - Error: ",ErrorCode,": ",ErrDesc);
						Alert(ErrAlert);

						string ErrLog = StringConcatenate("Ticket: ",argCloseTicket," Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK));
						Print(ErrLog);
					}
			}
		return(Deleted);
	}
	
	
double CalcBuyStopLoss(string argSymbol, int argStopLoss, double argOpenPrice)
	{
		if(argStopLoss == 0) return(0);

		double BuyStopLoss = argOpenPrice - (argStopLoss * PipPoint(argSymbol));
		return(BuyStopLoss);
	}
	
	
double CalcSellStopLoss(string argSymbol, int argStopLoss, double argOpenPrice)
	{
		if(argStopLoss == 0) return(0);

		double SellStopLoss = argOpenPrice + (argStopLoss * PipPoint(argSymbol));
		return(SellStopLoss);
	}


double CalcBuyTakeProfit(string argSymbol, int argTakeProfit, double argOpenPrice)
	{
		if(argTakeProfit == 0) return(0);

		double BuyTakeProfit = argOpenPrice + (argTakeProfit * PipPoint(argSymbol));
		return(BuyTakeProfit);
	}
	
	
double CalcSellTakeProfit(string argSymbol, int argTakeProfit, double argOpenPrice)
	{
		if(argTakeProfit == 0) return(0);

		double SellTakeProfit = argOpenPrice - (argTakeProfit * PipPoint(argSymbol));
		return(SellTakeProfit);
	}
	
	
bool VerifyUpperStopLevel(string argSymbol, double argVerifyPrice, double argOpenPrice = 0)
	{
		double StopLevel = MarketInfo(argSymbol,MODE_STOPLEVEL) * Point;
		
		if(argOpenPrice == 0) double OpenPrice = MarketInfo(argSymbol,MODE_ASK);
		else OpenPrice = argOpenPrice;
			
		double UpperStopLevel = OpenPrice + StopLevel;
			
		if(argVerifyPrice > UpperStopLevel) bool StopVerify = true;
		else StopVerify = false;
		
		return(StopVerify);
	}
	
	
bool VerifyLowerStopLevel(string argSymbol, double argVerifyPrice, double argOpenPrice = 0)
	{
		double StopLevel = MarketInfo(argSymbol,MODE_STOPLEVEL) * Point;
		
		if(argOpenPrice == 0) double OpenPrice = MarketInfo(argSymbol,MODE_BID);
		else OpenPrice = argOpenPrice;
			
		double LowerStopLevel = OpenPrice - StopLevel;
			
		if(argVerifyPrice < LowerStopLevel) bool StopVerify = true;
		else StopVerify = false;
		
		return(StopVerify);
	}


double AdjustAboveStopLevel(string argSymbol, double argAdjustPrice, int argAddPips = 0, double argOpenPrice = 0)
	{
		double StopLevel = MarketInfo(argSymbol,MODE_STOPLEVEL) * Point;
		
		if(argOpenPrice == 0) double OpenPrice = MarketInfo(argSymbol,MODE_ASK);
		else OpenPrice = argOpenPrice;

		double UpperStopLevel = OpenPrice + StopLevel;

		if(argAdjustPrice <= UpperStopLevel) double AdjustedPrice = UpperStopLevel + (argAddPips * PipPoint(argSymbol));
		else AdjustedPrice = argAdjustPrice;
					
		return(AdjustedPrice);
	}	
	
	
double AdjustBelowStopLevel(string argSymbol, double argAdjustPrice, int argAddPips = 0, double argOpenPrice = 0)
	{
		double StopLevel = MarketInfo(argSymbol,MODE_STOPLEVEL) * Point;
		
		if(argOpenPrice == 0) double OpenPrice = MarketInfo(argSymbol,MODE_BID);
		else OpenPrice = argOpenPrice;

		double LowerStopLevel = OpenPrice - StopLevel;
			
		if(argAdjustPrice >= LowerStopLevel) double AdjustedPrice = LowerStopLevel - (argAddPips * PipPoint(argSymbol));
		else AdjustedPrice = argAdjustPrice;
		
		return(AdjustedPrice);
	}	
	
	
bool AddStopProfit(int argTicket, double argStopLoss, double argTakeProfit)
	{
		OrderSelect(argTicket,SELECT_BY_TICKET);
		double OpenPrice = OrderOpenPrice();

		while(IsTradeContextBusy()) Sleep(10);

		// Modify Order
		bool TicketMod = OrderModify(argTicket,OrderOpenPrice(),argStopLoss,argTakeProfit,0);

		// Error Handling
		if(TicketMod == false)
			{
				int ErrorCode = GetLastError();
				string ErrDesc = ErrorDescription(ErrorCode);

				string ErrAlert = StringConcatenate("Add Stop/Profit - Error ",ErrorCode,": ",ErrDesc);
				Alert(ErrAlert);

				string ErrLog = StringConcatenate("Bid: ",MarketInfo(OrderSymbol(),MODE_BID)," Ask: ",MarketInfo(OrderSymbol(),MODE_ASK)," Ticket: ",argTicket," Stop: ",argStopLoss," Profit: ",argTakeProfit);
				Print(ErrLog);
			}
			
		return(TicketMod);
	}     


int TotalOrderCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	
	
int BuyMarketCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	
	
int SellMarketCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	
	
int BuyStopCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUYSTOP)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	
	
int SellStopCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELLSTOP)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	

int BuyLimitCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUYLIMIT)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	

int SellLimitCount(string argSymbol, int argMagicNumber)
	{
		int OrderCount;
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELLLIMIT)
					{
						OrderCount++;
					}
			}
		return(OrderCount);
	}
	

void CloseAllBuyOrders(string argSymbol, int argMagicNumber, int argSlippage)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY) 
					{
						// Close Order
						int CloseTicket = OrderTicket();
						double CloseLots = OrderLots();

						while(IsTradeContextBusy()) Sleep(10);

						double ClosePrice = MarketInfo(argSymbol,MODE_BID);

						bool Closed = OrderClose(CloseTicket,CloseLots,ClosePrice,argSlippage,Red);

						// Error Handling
						if(Closed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Close All Buy Orders - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ticket: ",CloseTicket," Price: ",ClosePrice);
								Print(ErrLog);
							}
						else Counter--;
					}
			}
	}
	
	

void CloseAllSellOrders(string argSymbol, int argMagicNumber, int argSlippage)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL) 
					{
						// Close Order
						int CloseTicket = OrderTicket();
						double CloseLots = OrderLots();

						while(IsTradeContextBusy()) Sleep(10);

						double ClosePrice = MarketInfo(argSymbol,MODE_ASK);

						bool Closed = OrderClose(CloseTicket,CloseLots,ClosePrice,argSlippage,Red);

						// Error Handling
						if(Closed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Close All Sell Orders - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Ask: ",MarketInfo(argSymbol,MODE_ASK)," Ticket: ",CloseTicket," Price: ",ClosePrice);
									Print(ErrLog);
							}
						else Counter--;
					}
			}
	}
	
	
	
void CloseAllBuyStopOrders(string argSymbol, int argMagicNumber)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUYSTOP) 
					{
						// Delete Order
						int CloseTicket = OrderTicket();

						while(IsTradeContextBusy()) Sleep(10);

						bool Closed = OrderDelete(CloseTicket,Red);

						// Error Handling
						if(Closed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Close All Buy Stop Orders - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK)," Ticket: ",CloseTicket);
								Print(ErrLog);
							}
						else Counter--;
					}
			}
	}  
	
	

void CloseAllSellStopOrders(string argSymbol, int argMagicNumber)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELLSTOP) 
					{
						// Delete Order
						int CloseTicket = OrderTicket();

						while(IsTradeContextBusy()) Sleep(10);

						bool Closed = OrderDelete(CloseTicket,Red);

						// Error Handling
						if(Closed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Close All Sell Stop Orders - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK)," Ticket: ",CloseTicket);
								Print(ErrLog);
							}
						else Counter--;
					}
			}
	}
	
	
void CloseAllBuyLimitOrders(string argSymbol, int argMagicNumber)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUYLIMIT) 
					{
						// Delete Order
						int CloseTicket = OrderTicket();

						while(IsTradeContextBusy()) Sleep(10);

						bool Closed = OrderDelete(CloseTicket,Red);

						// Error Handling
						if(Closed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Close All Buy Limit Orders - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK)," Ticket: ",CloseTicket);
								Print(ErrLog);
							}
						else Counter--;
					}
			}
	}
	
	

void CloseAllSellLimitOrders(string argSymbol, int argMagicNumber)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELLLIMIT) 
					{
						// Delete Order
						int CloseTicket = OrderTicket();

						while(IsTradeContextBusy()) Sleep(10);

						bool Closed = OrderDelete(CloseTicket,Red);

						// Error Handling
						if(Closed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Close All Sell Limit Orders - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ask: ",MarketInfo(argSymbol,MODE_ASK)," Ticket: ",CloseTicket);
								Print(ErrLog);
							}
						else Counter--;
					}
			}
	}
	
	
	
void BuyTrailingStop(string argSymbol, int argTrailingStop, int argMinProfit, int argMagicNumber)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				// Calculate Max Stop and Min Profit
				double MaxStopLoss = MarketInfo(argSymbol,MODE_BID) - (argTrailingStop * PipPoint(argSymbol));
				MaxStopLoss = NormalizeDouble(MaxStopLoss,MarketInfo(OrderSymbol(),MODE_DIGITS));
				
				double CurrentStop = NormalizeDouble(OrderStopLoss(),MarketInfo(OrderSymbol(),MODE_DIGITS));

				double PipsProfit = MarketInfo(argSymbol,MODE_BID) - OrderOpenPrice();
				double MinProfit = argMinProfit * PipPoint(argSymbol);

				// Modify Stop
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY && CurrentStop < MaxStopLoss && PipsProfit >= MinProfit)
					{
						bool Trailed = OrderModify(OrderTicket(),OrderOpenPrice(),MaxStopLoss,OrderTakeProfit(),0);

						// Error Handling
						if(Trailed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Buy Trailing Stop - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Bid: ",MarketInfo(argSymbol,MODE_BID)," Ticket: ",OrderTicket()," Stop: ",OrderStopLoss()," Trail: ",MaxStopLoss);
								Print(ErrLog);
							}
					}			
			}
	}
	
	
	
void SellTrailingStop(string argSymbol, int argTrailingStop, int argMinProfit, int argMagicNumber)
	{
		for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
			{
				OrderSelect(Counter,SELECT_BY_POS);

				// Calculate Max Stop and Min Profit
				double MaxStopLoss = MarketInfo(argSymbol,MODE_ASK) + (argTrailingStop * PipPoint(argSymbol));
				MaxStopLoss = NormalizeDouble(MaxStopLoss,MarketInfo(OrderSymbol(),MODE_DIGITS));
				
				double CurrentStop = NormalizeDouble(OrderStopLoss(),MarketInfo(OrderSymbol(),MODE_DIGITS));

				double PipsProfit = OrderOpenPrice() - MarketInfo(argSymbol,MODE_ASK);
				double MinProfit = argMinProfit * PipPoint(argSymbol);

				// Modify Stop
				if(OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL && (CurrentStop > MaxStopLoss || CurrentStop == 0) && PipsProfit >= MinProfit)
					{
						bool Trailed = OrderModify(OrderTicket(),OrderOpenPrice(),MaxStopLoss,OrderTakeProfit(),0);

						// Error Handling
						if(Trailed == false)
							{
								int ErrorCode = GetLastError();
								string ErrDesc = ErrorDescription(ErrorCode);

								string ErrAlert = StringConcatenate("Sell Trailing Stop - Error ",ErrorCode,": ",ErrDesc);
								Alert(ErrAlert);

								string ErrLog = StringConcatenate("Ask: ",MarketInfo(argSymbol,MODE_ASK)," Ticket: ",OrderTicket()," Stop: ",OrderStopLoss()," Trail: ",MaxStopLoss);
								Print(ErrLog);
							}
					}			
			}
	}