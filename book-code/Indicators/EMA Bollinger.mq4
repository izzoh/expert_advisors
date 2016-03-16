//+------------------------------------------------------------------+
//|                                                EMA Bollinger.mq4 |
//|                                                     Andrew Young |
//|                                   http://www.easyexpertforex.com |
//+------------------------------------------------------------------+
#property copyright "Andrew Young"
#property link      "http://www.easyexpertforex.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DeepSkyBlue
#property indicator_color3 DeepSkyBlue

extern int BandsPeriod = 20;
extern int BandsShift = 0;
extern int BandsMethod = 1;
extern int BandsPrice = 0;
extern int Deviations = 1;



//---- buffers
double EMA[];
double UpperBand[];
double LowerBand[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,EMA);
	SetIndexLabel(0,"EMA");

   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,UpperBand);
   SetIndexLabel(1,"UpperBand");

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,LowerBand);
   SetIndexLabel(2,"LowerBand");


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   
   int CalculateBars = Bars - counted_bars;
   
   for(int Count = CalculateBars; Count >= 0; Count--)
	  {
  	      EMA[Count] = iMA(NULL,0,BandsPeriod,BandsShift,BandsMethod,BandsPrice,Count);
  	      
  	      double StdDev = iStdDev(NULL,0,BandsPeriod,BandsShift,BandsMethod,BandsPrice,Count);
  	      
  	      UpperBand[Count] = EMA[Count] + (StdDev * Deviations);
  	      LowerBand[Count] = EMA[Count] - (StdDev * Deviations);
	  }


//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+