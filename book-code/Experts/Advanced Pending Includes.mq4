//+------------------------------------------------------------------+
//|                                    Advanced Pending Includes.mq4 |
//|                                                     Andrew Young |
//|                                   http://www.easyexpertforex.com |
//+------------------------------------------------------------------+

// Preprocessor
#property copyright "Andrew Young"
#include <IncludeExample.mqh>


// External variables
extern bool DynamicLotSize = true;
extern double EquityPercent = 2;
extern double FixedLotSize = 0.1;

extern double StopLoss = 50;
extern double TakeProfit = 100;

extern int TrailingStop = 50;
extern int MinimumProfit = 50;

extern int PendingPips = 1;

extern int Slippage = 5;
extern int MagicNumber = 123;

extern int FastMAPeriod = 10;
extern int SlowMAPeriod = 20;

extern bool CheckOncePerBar = true;


// Global Variables
int BuyTicket;
int SellTicket;

double UsePoint;
int UseSlippage;

datetime CurrentTimeStamp;


// Init function
int init()
	{
		//SetEAName(EA_NAME);
		UsePoint = PipPoint(Symbol());
		UseSlippage = GetSlippage(Symbol(),Slippage);
		
		return(0);
	}
	

// Start Function
int start()
	{
		
		// Execute on bar open
		if(CheckOncePerBar == true)
			{
				int BarShift = 1;
				if(CurrentTimeStamp != Time[0]) 
					{
						CurrentTimeStamp = Time[0];
						bool NewBar = true;
					}
				else NewBar = false;
			}
		else 
			{
				NewBar = true;
				BarShift = 0;
			}
		
		
		// Moving averages
		double FastMA = iMA(NULL,0,FastMAPeriod,0,0,0,BarShift);
		double SlowMA = iMA(NULL,0,SlowMAPeriod,0,0,0,BarShift);
		

		// Calculate lot size
		double LotSize = CalcLotSize(DynamicLotSize,EquityPercent,StopLoss,FixedLotSize);
		LotSize = VerifyLotSize(LotSize);
		
		
		// Begin trade block
		if(NewBar == true)
			{
		
				// Buy order 
				if(FastMA > SlowMA && BuyTicket == 0 && BuyMarketCount(Symbol(),MagicNumber) == 0 && BuyStopCount(Symbol(),MagicNumber) == 0)
					{
						// Close sell order
						if(SellMarketCount(Symbol(),MagicNumber) > 0)
							{ 
								CloseAllSellOrders(Symbol(),MagicNumber,Slippage);
							}
	
						// Delete sell stop order			
						if(SellStopCount(Symbol(),MagicNumber) > 0)
							{
								CloseAllSellStopOrders(Symbol(),MagicNumber);
							}

						SellTicket = 0;
			
						double PendingPrice = High[BarShift] + (PendingPips * UsePoint);
						PendingPrice = AdjustAboveStopLevel(Symbol(),PendingPrice,5);
			
						double BuyStopLoss = CalcBuyStopLoss(Symbol(),StopLoss,PendingPrice);
						if(BuyStopLoss > 0) BuyStopLoss = AdjustBelowStopLevel(Symbol(),BuyStopLoss,5,PendingPrice);

						double BuyTakeProfit = CalcBuyTakeProfit(Symbol(),TakeProfit,PendingPrice);
						if(BuyTakeProfit > 0) BuyTakeProfit = AdjustAboveStopLevel(Symbol(),BuyTakeProfit,5,PendingPrice);

						BuyTicket = OpenBuyStopOrder(Symbol(),LotSize,PendingPrice,BuyStopLoss,BuyTakeProfit,UseSlippage,MagicNumber,0);
					}
		
		
				// Sell Order 
				if(FastMA < SlowMA && SellTicket == 0 && SellMarketCount(Symbol(),MagicNumber) == 0 && SellStopCount(Symbol(),MagicNumber) == 0)
					{
						if(BuyMarketCount(Symbol(),MagicNumber) > 0)
							{ 
								CloseAllBuyOrders(Symbol(),MagicNumber,Slippage);
							}

						if(BuyStopCount(Symbol(),MagicNumber) > 0)
							{
								CloseAllBuyStopOrders(Symbol(),MagicNumber);
							}

						BuyTicket = 0;

						PendingPrice = Low[BarShift] - (PendingPips * UsePoint);
						PendingPrice = AdjustBelowStopLevel(Symbol(),PendingPrice,5);

						double SellStopLoss = CalcSellStopLoss(Symbol(),StopLoss,PendingPrice);
						if(SellStopLoss > 0) SellStopLoss = AdjustAboveStopLevel(Symbol(),SellStopLoss,5,PendingPrice);
			
						double SellTakeProfit = CalcSellTakeProfit(Symbol(),TakeProfit,PendingPrice);
						if(SellTakeProfit > 0) AdjustBelowStopLevel(Symbol(),SellTakeProfit,5,PendingPrice);		

						SellTicket = OpenSellStopOrder(Symbol(),LotSize,PendingPrice,SellStopLoss,SellTakeProfit,UseSlippage,MagicNumber,0);
					}
				
			}  // End trade block
			
			
		// Adjust trailing stops		
		if(BuyMarketCount(Symbol(),MagicNumber) > 0 && TrailingStop > 0)
			{
				BuyTrailingStop(Symbol(),TrailingStop,MinimumProfit,MagicNumber);
			}

		if(SellMarketCount(Symbol(),MagicNumber) > 0 && TrailingStop > 0)
			{
				SellTrailingStop(Symbol(),TrailingStop,MinimumProfit,MagicNumber);
			}
			
			
		return(0);
	}