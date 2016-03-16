//+------------------------------------------------------------------+
//|                                                  Sample Code.mq4 |
//|                                                     Andrew Young |
//|                                   http://www.easyexpertforex.com |
//+------------------------------------------------------------------+

#property copyright "Andrew Young"
#property link      "http://www.easyexpertforex.com"


// ----------------------
// Error Handling - pg 58
// ----------------------


   ErrorCode = GetLastError();
   string ErrDesc;
   
   if(ErrorCode == 129) ErrDesc = "Order opening price is invalid!";
   if(ErrorCode == 130) ErrDesc = "Stop loss or take profit is invalid!";
   if(ErrorCode == 131) ErrDesc = "Lot size is invalid!";
   // Add other error codes as appropriate

   string ErrAlert = StringConcatenate("Open Buy Order - Error ",ErrorCode,": ",ErrDesc);
   Alert(ErrAlert);
   
   

// ------------------
// Order Loop - pg 84
// ------------------


  for(Counter = 0; Counter <= OrdersTotal()-1; Counter++)
     {
        OrderSelect(Counter,SELECT_BY_POS);
        // Evaluate condition 
     }
   
   
   
// -----------------------   
// Break Even Stop - pg 93
// -----------------------


   // External variables
   extern double BreakEvenProfit = 25;


   // Post-order placement
   for(int Counter = 0; Counter <= OrdersTotal()-1; Counter++)
	   {
		   OrderSelect(Counter,SELECT_BY_POS);
		   RefreshRates();

		   double PipsProfit = Bid – OrderOpenPrice();
		   double MinProfit = BreakEvenProfit * PipPoint(OrderSymbol());

		   if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == OP_BUY && PipsProfit >= MinProfit && OrderOpenPrice() != OrderStopLoss())
			   {
				   bool BreakEven = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);

				   if(BreakEven == false)
					   {
						   ErrorCode = GetLastError();
						   string ErrDesc = ErrorDescription(ErrorCode);

						   string ErrAlert = StringConcatenate("Buy Break Even - Error ",ErrorCode,": ",ErrDesc);
						   Alert(ErrAlert);
						
						   string ErrLog = StringConcatenate("Bid: ",Bid,", Ask: ",Ask,", Ticket: ",CloseTicket,", Stop: ",OrderStopLoss(),", Break: ",MinProfit);
	  					 Print(ErrLog);
					   }
			   }
	   }


// ---------------------
// Simple Timer - pg 118
// ---------------------


// Extern variables
extern bool UseTimer = true;
extern bool UseLocalTime = false;

extern int StartMonth = 6;
extern int StartDay = 15;
extern int StartHour = 7;
extern int StartMinute = 0;

extern int EndMonth = 6;
extern int EndDay = 15;
extern int EndHour = 2;
extern int EndMinute = 30;


   // Beginning of start() function
   if(UseTimer == true)
	   {	
		   // Convert start time
		   string StartConstant = StringConcatenate(Year(),".",StartMonth,".",StartDay," ",StartHour,":",StartMinute);    

		   datetime StartTime = StrToTime(StartConstant);

		   if(StartMonth == 12 && StartDay == 31 && EndMonth == 1) int EndYear = Year() + 1;
		   else EndYear = Year();

		   // Convert end time
		   string EndConstant = StringConcatenate(EndYear,".",EndMonth,".",EndDay," ",EndHour,":",EndMinute);  

		   datetime EndTime = StrToTime(EndConstant);

		   // Choose local or server time
		   if(UseLocalTime == true) datetime CurrentTime = TimeLocal();  	
		   else CurrentTime = TimeCurrent();	

		   // Check for trade condition
		   if(StartTime <= CurrentTime && EndTime > CurrentTime) 
			   {
				   bool TradeAllowed = true;	
			   }
		   else TradeAllowed = false;
	   }
   else TradeAllowed = true;


	
// -----------------------
// Check Settings - pg 125
// -----------------------


   // init() function
   if(IsTradeAllowed() == false) Alert("Enable the setting \'Allow live trading\' in the Expert Properties!");
   if(IsLibrariesAllowed() == false) Alert("Enable the setting \'Allow import of external experts\' in the Expert Properties!");
   if(IsDllsAllowed() == false) Alert("Enable the setting \'Allow DLL imports\' in the Expert Properties!");



// ----------------------------
// Demo Account Checks - pg 127
// ----------------------------


   // start() function
   if(IsDemo() == false) 
	   {
		   Alert("This EA only for use on a demo account!");
		   return(0);
	   }
	
	// Account number check - start() function
   int CustomerAccount = 123456;

   if(AccountNumber() != CustomerAccount)
	   {
		   Alert("Account number does not match!");
		   return(0);
	   }



// -----------------------
// Retry on Error - pg 131
// -----------------------


   // Order placement
   int Retries = 0;
   int MaxRetries = 5;
   int Ticket = 0;
   
   while(Ticket <= 0)
	   {
		   Ticket = OrderSend(Symbol(),OP_BUY,LotSize,OpenPrice,UseSlippage,BuyStopLoss,BuyTakeProfit);
		   if(Ticket == -1) int ErrCode = GetLastError();
		   if(Retries <= MaxRetries && ErrorCheck(ErrCode) == true) Retries++;
		   else break;
	   }
	
	
	// Error check function
   bool ErrorCheck(int ErrorCode)
	   {
		   switch(ErrorCode)	
			   {
				   case 128:			// Trade timeout
				   return(true);

				   case 136:			// Off quotes
				   return(true);

				   case 138:			// Requotes
				   return(true);
				
				   case 146:			// Trade context busy
				   return(true);
				
				   default:
				   return(false);
			   }
	   }


// ---------------------
// Margin Check - pg 134
// ---------------------


// External variables
extern int MinimumEquity = 8000;


   // Order placement
   if(AccountEquity() > MinimumEquity)
	   {
		   // Place order
	   }
   else if(AccountEquity() <= MinimumEquity)
	   {
		    Alert("Current equity is less than minimum equity! Order not placed.");
	   }
	


// ---------------------
// Spread Check - pg 135
// ---------------------


// External variables
extern int MaximumSpread = 5;
extern int MinimumEquity = 8000;

   
   // Order placement
   if(AccountEquity() > MinimumEquity && MarketInfo(Symbol(),MODE_SPREAD) < MaximumSpread)
	   {
		   // Place order
	   }
   else
	   {
		   if(AccountEquity() <= MinimumEquity) Alert("Current equity is less than minimum equity! Order not placed.");
		
		   if(MarketInfo(Symbol(),MODE_SPREAD) > MaximumSpread) Alert("Current spread is greater than maximum spread! Order not placed.");
	   }



// ------------------------
// Multiple Orders - pg 136
// ------------------------


// External variables
extern int StopLoss1 = 20;
extern int StopLoss2 = 40;
extern int StopLoss3 = 60;

extern int TakeProfit1 = 40;
extern int TakeProfit2 = 80;
extern int TakeProfit3 = 120;

extern int MaxOrders = 3;


   // start() function
   double BuyTakeProfit[3];
   double BuyStopLoss[3];

   BuyTakeProfit[0] = CalcBuyTakeProfit(Symbol(),TakeProfit1,Ask);
   BuyTakeProfit[1] = CalcBuyTakeProfit(Symbol(),TakeProfit2,Ask);
   BuyTakeProfit[2] = CalcBuyTakeProfit(Symbol(),TakeProfit3,Ask);

   BuyStopLoss[0] = CalcBuyStopLoss(Symbol(),StopLoss1,Ask);
   BuyStopLoss[1] = CalcBuyStopLoss(Symbol(),StopLoss2,Ask);
   BuyStopLoss[2] = CalcBuyStopLoss(Symbol(),StopLoss3,Ask);


   // Order placement
   for(int Count = 0; Count <= MaxOrders - 1; Count++)
	   {
		   int OrdInt = Count + 1;
		   OrderSend(Symbol(),OP_BUY,LotSize,Ask,UseSlippage,BuyStopLoss[Count],BuyTakeProfit[Count],"Buy Order "+OrdInt,MagicNumber,0,Green);
	   }
	
	
// Alternate method	

// External variables
extern int StopLossStart = 20;
extern int StopLossIncr = 20;

extern int TakeProfitStart = 40;
extern int TakeProfitIncr = 40;

extern int MaxOrders = 5;

   
   // Order placement
   for(int Count = 0; Count <= MaxOrders - 1; Count++)
	   {
		   int OrdInt = Count + 1;		

		   int UseStopLoss =  StopLossStart + (StopLossIncr * Count);
		   int UseTakeProfit =  TakeProfitStart + (TakeProfitIncr * Count);

		   double BuyStopLoss = CalcBuyStopLoss(Symbol(),UseStopLoss,Ask);
		   double BuyTakeProfit = CalcBuyTakeProfit(Symbol(),UseTakeProfit,Ask);

		   OrderSend(Symbol(),OP_BUY,LotSize,Ask,UseSlippage,BuyStopLoss,BuyTakeProfit,"Buy Order "+OrdInt,MagicNumber,0,Green);
	   }
	


// -------------------------------
// Global Variable Prefix - pg 139
// -------------------------------


// Global variables
string GlobalVariablePrefix;
string EAName;


   // init() function
   GlobalVariablePrefix = Symbol()+Period()+"_"+EAName+"_"+MagicNumber+"_";



// -----------------------------------
// Check Order Profit in Pips - pg 140
// -----------------------------------

   
   OrderSelect(Ticket,SELECT_BY_TICKET);

   if(OrderType() == OP_BUY) double GetProfit = OrderClosePrice() - OrderOpenPrice();
   else if(OrderType() == OP_SELL) GetProfit = OrderOpenPrice() - OrderClosePrice();

   GetProfit /= PipPoint(Symbol());


// -------------------
// Martingale - pg 141
// -------------------


// External variables
extern int MartingaleType = 0;	// 0: Martingale, 1: Anti-Martingale
extern int LotMultiplier = 2;
extern int MaxMartingale = 4;
extern double BaseLotSize = 0.1;


   // Win/Loss count
   int WinCount;
   int LossCount;

   for(int Count = OrdersHistoryTotal()-1; Count >= 0; Count--)
   {
	   OrderSelect(Count,SELECT_BY_POS,MODE_HISTORY);
 	 	if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
	  	{
   	   if(OrderProfit() > 0 && LossCount == 0) WinCount++;
        	else if(OrderProfit() < 0 && WinCount == 0) LossCount++;
        	else break;
	  	}    
   }
	

   // Lot size calculation
   if(MartingaleType == 0) int ConsecutiveCount = LossCount;
   else if(MartingaleType == 1) ConsecutiveCount = WinCount;

   if(ConsecutiveCount > MaxMartingale) ConsecutiveCount = MaxMartingale;

   double LotSize = BaseLotSize * MathPow(LotMultiplier,ConsecutiveCount);