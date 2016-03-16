//+------------------------------------------------------------------+
//|                                                     Advanced.mq4 |
//|                                                     Andrew Young |
//|                                   http://www.easyexpertforex.com |
//+------------------------------------------------------------------+


#property copyright "Andrew Young"
#include <stdlib.mqh>


// External variables
extern bool DynamicLotSize = true;
extern double EquityPercent = 2;
extern double FixedLotSize = 0.1;
extern double StopLoss = 50;
extern double TakeProfit = 100;
extern int Slippage = 5;
extern int MagicNumber = 123;
extern int FastMAPeriod = 10;
extern int SlowMAPeriod = 20;


// Global variables
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


// Start function
int start()
	{
     
     // Moving averages
		double FastMA = iMA(NULL,0,FastMAPeriod,0,0,0,1);
		double SlowMA = iMA(NULL,0,SlowMAPeriod,0,0,0,1);
		
		
      // Lot size calculation
      if(DynamicLotSize == true)
        {
           double RiskAmount = AccountEquity() * (EquityPercent / 100);
           double TickValue = MarketInfo(Symbol(),MODE_TICKVALUE);
           if(Point == 0.001 || Point == 0.00001) TickValue *= 10;
           double CalcLots = (RiskAmount / StopLoss) / TickValue;
           double LotSize = CalcLots;
        }
      else LotSize = FixedLotSize;
     
     
      // Lot size verification
      if(LotSize < MarketInfo(Symbol(),MODE_MINLOT))
        {
           LotSize = MarketInfo(Symbol(),MODE_MINLOT);
        }
      else if(LotSize > MarketInfo(Symbol(),MODE_MAXLOT))
        {
           LotSize = MarketInfo(Symbol(),MODE_MAXLOT);
        }
		
      if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1)
        {
           LotSize = NormalizeDouble(LotSize,1);
        }
      else LotSize = NormalizeDouble(LotSize,2);
	
		
		// Buy Order 
		if(FastMA > SlowMA && BuyTicket == 0)
         {
            // Close Order
            OrderSelect(SellTicket,SELECT_BY_TICKET);
		      
		      if(OrderCloseTime() == 0 && SellTicket > 0)
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
				
				// Open buy order
				while(IsTradeContextBusy()) Sleep(10);
				RefreshRates();	
			
            BuyTicket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,UseSlippage,0,0,"Buy Order",MagicNumber,0,Green);
            
            // Error handling
            if(BuyTicket == -1)
               {
                  ErrorCode = GetLastError();
                  ErrDesc = ErrorDescription(ErrorCode);

                  ErrAlert = StringConcatenate("Open Buy Order - Error ",ErrorCode,": ",ErrDesc);
                  Alert(ErrAlert);

                  ErrLog = StringConcatenate("Ask: ",Ask," Lots: ",LotSize);
                  Print(ErrLog);
               }

            // Order modification
            else 
               {
                  OrderSelect(BuyTicket,SELECT_BY_TICKET);
                  double OpenPrice = OrderOpenPrice();

                  // Calculate stop level				
				      double StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * Point;

				      RefreshRates();	
				      double UpperStopLevel = Ask + StopLevel;
				      double LowerStopLevel = Bid - StopLevel;

				      double MinStop = 5 * UsePoint;
				      
				      // Calculate stop loss and take profit
				      if(StopLoss > 0) double BuyStopLoss = OpenPrice - (StopLoss * UsePoint);
                  if(TakeProfit > 0) double BuyTakeProfit = OpenPrice + (TakeProfit * UsePoint);

				      // Verify stop loss and take profit
				      if(BuyStopLoss > 0 && BuyStopLoss > LowerStopLevel) 
					      {					
						      BuyStopLoss = LowerStopLevel - MinStop;
					      }
				      
				      if(BuyTakeProfit > 0 && BuyTakeProfit < UpperStopLevel) 
					      {
						      BuyTakeProfit = UpperStopLevel + MinStop;
					      }

				      // Modify order
				      if(IsTradeContextBusy()) Sleep(10);	

                  if(BuyStopLoss > 0 || BuyTakeProfit > 0) 
                     {		
                        bool TicketMod = OrderModify(BuyTicket,OpenPrice,BuyStopLoss,BuyTakeProfit,0);
                       
                        // Error handling
                        if(TicketMod == false)
                           {
                              ErrorCode = GetLastError();
                              ErrDesc = ErrorDescription(ErrorCode);

                              ErrAlert = StringConcatenate("Modify Buy Order - Error ",ErrorCode,": ",ErrDesc);
                              Alert(ErrAlert);

                              ErrLog = StringConcatenate("Ask: ",Ask," Bid: ",Bid," Ticket: ",BuyTicket," Stop: ",BuyStopLoss," Profit: ",BuyTakeProfit);
                              Print(ErrLog);
                           }
                     }
               }

		      SellTicket = 0;
	     }
		
		
		// Sell Order 
		if(FastMA < SlowMA && SellTicket == 0)
			{
				OrderSelect(BuyTicket,SELECT_BY_TICKET);
		
		      if(OrderCloseTime() == 0 && BuyTicket > 0)
               {
                  CloseLots = OrderLots();

                  while(IsTradeContextBusy()) Sleep(10);

                  RefreshRates();
                  ClosePrice = Bid;

                  Closed = OrderClose(BuyTicket,CloseLots,ClosePrice,UseSlippage,Red);
                  
                  // Error handling
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
				
			   while(IsTradeContextBusy()) Sleep(10);
				RefreshRates();	
							
				SellTicket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,UseSlippage,0,0,"Sell Order",MagicNumber,0,Red);
				
				// Error handling
            if(SellTicket == -1)
               {
                  ErrorCode = GetLastError();
                  ErrDesc = ErrorDescription(ErrorCode);

                  ErrAlert = StringConcatenate("Open Sell Order - Error ",ErrorCode,": ",ErrDesc);
                  Alert(ErrAlert);

                  ErrLog = StringConcatenate("Bid: ",Bid," Lots: ",LotSize);
                  Print(ErrLog);
               }
					
				else
               {
                  OrderSelect(SellTicket,SELECT_BY_TICKET);
                  OpenPrice = OrderOpenPrice();

				      StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * Point;

				      RefreshRates();	
				      UpperStopLevel = Ask + StopLevel;
				      LowerStopLevel = Bid - StopLevel;

				      MinStop = 5 * UsePoint;
				      
				      if(StopLoss > 0) double SellStopLoss = OpenPrice + (StopLoss * UsePoint);
				      if(TakeProfit > 0) double SellTakeProfit = OpenPrice - (TakeProfit *	UsePoint);

				      if(SellStopLoss > 0 && SellStopLoss < UpperStopLevel) 
					      {					
						      SellStopLoss = UpperStopLevel + MinStop;
					      }
				      if(SellTakeProfit  > 0 && SellTakeProfit > LowerStopLevel) 
					      {
						      SellTakeProfit = LowerStopLevel - MinStop;
					      }

				      if(IsTradeContextBusy()) Sleep(10);	

                  if(SellStopLoss > 0 || SellTakeProfit > 0) 
                    {		
                       TicketMod = OrderModify(SellTicket,OpenPrice,SellStopLoss,SellTakeProfit,0);
                       
                       // Error handling
                       if(TicketMod == false)
                          {
                             ErrorCode = GetLastError();
                             ErrDesc = ErrorDescription(ErrorCode);

                             ErrAlert = StringConcatenate("Modify Sell Order - Error ",ErrorCode,": ",ErrDesc);
                             Alert(ErrAlert);

                             ErrLog = StringConcatenate("Ask: ",Ask," Bid: ",Bid," Ticket: ",SellTicket," Stop: ",SellStopLoss," Profit: ",SellTakeProfit);
                             Print(ErrLog);
                          }
                    }
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