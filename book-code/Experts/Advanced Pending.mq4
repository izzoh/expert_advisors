//+------------------------------------------------------------------+
//|                                             Advanced Pending.mq4 |
//|                                                     Andrew Young |
//|                                   http://www.easyexpertforex.com |
//+------------------------------------------------------------------+

#property copyright "Andrew Young"
#include <stdlib.mqh>


// External Variables
extern int PendingPips = 20;
extern double LotSize = 0.1;
extern double StopLoss = 50;
extern double TakeProfit = 100;
extern int Slippage = 5;
extern int MagicNumber = 123;
extern int FastMAPeriod = 10;
extern int SlowMAPeriod = 20;


// Global Variables
int BuyTicket;
int SellTicket;
double UsePoint;
int UseSlippage;
int ErrorCode;


// Init function
int init()
	{
		UsePoint = PipPoint(Symbol());
		UseSlippage = GetSlippage(Symbol(),Slippage);
		
		return(0);
	}


// Start Function
int start()
	{
		
		// Moving Average
		double FastMA = iMA(NULL,0,FastMAPeriod,0,0,0,0);
		double SlowMA = iMA(NULL,0,SlowMAPeriod,0,0,0,0);
		
		
		// Buy Order 
		if(FastMA > SlowMA && BuyTicket == 0)
			{
			   
			   // Close order
			   OrderSelect(SellTicket,SELECT_BY_TICKET);

            if(OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_SELL)
	            {
		            double CloseLots = OrderLots();
		            
		            while(IsTradeContextBusy()) Sleep(10);

		            RefreshRates();
		            double ClosePrice = Ask;

		            bool Closed = OrderClose(SellTicket,CloseLots,ClosePrice,UseSlippage,Red);
		            
		            // Error handling
                  if(Closed == false)
                     {
                        ErrorCode = GetLastError();
                        string ErrDesc = ErrorDescription(ErrorCode);

                        string ErrAlert = StringConcatenate("Close Sell Order - Error ",ErrorCode,": ",ErrDesc);
                        Alert(ErrAlert);

                        string ErrLog = StringConcatenate("Ask: ",Ask," Lots: ",LotSize," Ticket: ",SellTicket);
                        Print(ErrLog);
                     }
	            }
	
            // Delete order			
            else if(OrderCloseTime() == 0 && SellTicket > 0 && OrderType() == OP_SELLSTOP)
	            {
		            bool Deleted = OrderDelete(SellTicket,Red);
		            if(Deleted == true) SellTicket = 0;
		            
		            // Error handling
                  if(Deleted == false)
                     {
                        ErrorCode = GetLastError();
                        ErrDesc = ErrorDescription(ErrorCode);

                        ErrAlert = StringConcatenate("Delete Sell Stop Order - Error ",ErrorCode,": ",ErrDesc);
                        Alert(ErrAlert);

                        ErrLog = StringConcatenate("Ask: ",Ask," Ticket: ",SellTicket);
                        Print(ErrLog);
                     }
	            }
	            
	            
	         // Calculate stop level
            double StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * Point;
            RefreshRates();
            double UpperStopLevel = Ask + StopLevel;
            double MinStop = 5 * UsePoint;
	         
	         
	         // Calculate pending price
	         double PendingPrice = High[0] + (PendingPips * UsePoint);
	         if(PendingPrice < UpperStopLevel) PendingPrice = UpperStopLevel + MinStop;
	         
	         
	         // Calculate stop loss and take profit
	         if(StopLoss > 0) double BuyStopLoss = PendingPrice - (StopLoss * UsePoint);
            if(TakeProfit > 0) double BuyTakeProfit = PendingPrice + (TakeProfit * UsePoint);
            
            
            // Verify stop loss and take profit
            UpperStopLevel = PendingPrice + StopLevel;
				double LowerStopLevel = PendingPrice - StopLevel;
            
		      if(BuyStopLoss > 0 && BuyStopLoss > LowerStopLevel) 
			      {					
				      BuyStopLoss = LowerStopLevel - MinStop;
			      }
		      
		      if(BuyTakeProfit  > 0 && BuyTakeProfit < UpperStopLevel) 
			      {
				      BuyTakeProfit = UpperStopLevel + MinStop;
			      } 


            // Place pending order
            if(IsTradeContextBusy()) Sleep(10);
           
            BuyTicket = OrderSend(Symbol(),OP_BUYSTOP,LotSize,PendingPrice,UseSlippage,BuyStopLoss,BuyTakeProfit,"Buy Stop Order",MagicNumber,0,Green);


            // Error handling
            if(BuyTicket == -1)
               {
                  ErrorCode = GetLastError();
                  ErrDesc = ErrorDescription(ErrorCode);

                  ErrAlert = StringConcatenate("Open Buy Stop Order - Error ",ErrorCode,": ",ErrDesc);
                  Alert(ErrAlert);

                  ErrLog = StringConcatenate("Ask: ",Ask," Lots: ",LotSize," Price: ",PendingPrice," Stop: ",BuyStopLoss," Profit: ",BuyTakeProfit);
                  Print(ErrLog);
               }

            SellTicket = 0;
			}
		
		
		// Sell Order 
		if(FastMA < SlowMA && SellTicket == 0)
			{
			   OrderSelect(BuyTicket,SELECT_BY_TICKET);

            if(OrderCloseTime() == 0 && BuyTicket > 0 && OrderType() == OP_BUY)
	            {	
		            CloseLots = OrderLots();
		            
		            while(IsTradeContextBusy()) Sleep(10);

		            RefreshRates();
		            ClosePrice = Bid;

		            Closed = OrderClose(BuyTicket,CloseLots,ClosePrice,UseSlippage,Red);
		            
                  if(Closed == false)
                     {
                        ErrorCode = GetLastError();
                        ErrDesc = ErrorDescription(ErrorCode);

                        ErrAlert = StringConcatenate("Close Buy Order - Error ",ErrorCode,": ",ErrDesc);
                        Alert(ErrAlert);

                        ErrLog = StringConcatenate("Bid: ",Bid," Lots: ",LotSize," Ticket: ",BuyTicket);
                        Print(ErrLog);
                     }
	            }
				
            else if(OrderCloseTime() == 0 && BuyTicket > 0 && OrderType() == OP_BUYSTOP)
	            {
		            while(IsTradeContextBusy()) Sleep(10);	
		            Closed = OrderDelete(BuyTicket,Red);
		            
                  if(Deleted == false)
                     {
                        ErrorCode = GetLastError();
                        ErrDesc = ErrorDescription(ErrorCode);

                        ErrAlert = StringConcatenate("Delete Buy Stop Order - Error ",ErrorCode,": ",ErrDesc);
                        Alert(ErrAlert);

                        ErrLog = StringConcatenate("Bid: ",Bid," Ticket: ",BuyTicket);
                        Print(ErrLog);
                     }
	            }
            
            StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * Point;
            RefreshRates();
            LowerStopLevel = Bid - StopLevel;
            MinStop = 5 * UsePoint;
            
            PendingPrice = Low[0] - (PendingPips * UsePoint);
            if(PendingPrice > LowerStopLevel) PendingPrice = LowerStopLevel - MinStop;
            
            if(StopLoss > 0) double SellStopLoss = PendingPrice + (StopLoss * UsePoint);
			   if(TakeProfit > 0) double SellTakeProfit = PendingPrice - (TakeProfit *	UsePoint);

            UpperStopLevel = PendingPrice + StopLevel;
				LowerStopLevel = PendingPrice - StopLevel;
            
		      if(SellStopLoss > 0 && SellStopLoss < UpperStopLevel) 
			      {					
				      SellStopLoss = UpperStopLevel + MinStop;
			      }
		      if(SellTakeProfit  > 0 && SellTakeProfit > LowerStopLevel) 
			      {
				      SellTakeProfit = LowerStopLevel - MinStop;
			      }

            if(IsTradeContextBusy()) Sleep(10);

            SellTicket = OrderSend(Symbol(),OP_SELLSTOP,LotSize,PendingPrice,UseSlippage,SellStopLoss,SellTakeProfit,"Sell Stop Order",MagicNumber,0,Red);
            
            if(SellTicket == -1)
               {
                  ErrorCode = GetLastError();
                  ErrDesc = ErrorDescription(ErrorCode);

                  ErrAlert = StringConcatenate("Open Sell Stop Order - Error ",ErrorCode,": ",ErrDesc);
                  Alert(ErrAlert);

                  ErrLog = StringConcatenate("Bid: ",Bid," Lots: ",LotSize," Price: ",PendingPrice," Stop: ",SellStopLoss," Profit: ",SellTakeProfit);
                  Print(ErrLog);
               }
            
            BuyTicket = 0;
			}
			
		return(0);
	}


// Pip Point Function
double PipPoint(string Currency)
	{
		int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
		if(CalcDigits == 2 || CalcDigits == 3) double CalcPoint = 0.01;
		else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
		return(CalcPoint);
	}


// Get Slippage Function
int GetSlippage(string Currency, int SlippagePips)
	{
		int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
		if(CalcDigits == 2 || CalcDigits == 4) double CalcSlippage = SlippagePips;
		else if(CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
		return(CalcSlippage);
	}