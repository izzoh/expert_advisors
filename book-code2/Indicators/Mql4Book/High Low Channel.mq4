//+------------------------------------------------------------------+
//|                                             High Low Channel.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright   "Andrew R. Young"
#property link        "http://www.expertadvisorbook.com"
#property description "A Donchian channel indicator"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot HighestHigh
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- plot LowestLow
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int      HighLowBars=8;

//--- indicator buffers
double         UpperBuffer[];
double         LowerBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
{
//--- indicator buffers mapping
	SetIndexBuffer(0,UpperBuffer);
	SetIndexBuffer(1,LowerBuffer);

	return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
				const int prev_calculated,
				const datetime &time[],
				const double &open[],
				const double &high[],
				const double &low[],
				const double &close[],
				const long &tick_volume[],
				const long &volume[],
				const int &spread[])
{

	ArraySetAsSeries(UpperBuffer,true);
	ArraySetAsSeries(LowerBuffer,true);
	ArraySetAsSeries(high,true);
	ArraySetAsSeries(low,true);

	int bars = rates_total - 1;
	if(prev_calculated > 0) bars = rates_total - prev_calculated;

	for(int i = bars; i >= 0; i--)   
	{
		int highShift = ArrayMaximum(high,HighLowBars,i);
		int lowShift = ArrayMinimum(low,HighLowBars,i);
		
		double highestHigh = high[highShift];
		double lowestLow = low[lowShift];
		
		UpperBuffer[i] = highestHigh;
		LowerBuffer[i] = lowestLow;
	}

	//--- return value of prev_calculated for next call
	return(rates_total);
}
//+------------------------------------------------------------------+
