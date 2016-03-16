//+------------------------------------------------------------------+
//|                                                   Indicators.mqh |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+

#property copyright   "Andrew R. Young"
#property link        "http://www.expertadvisorbook.com"
#property description "Popular indicator classes"
#property strict

/*
 Creative Commons Attribution-NonCommercial 3.0 Unported
 http://creativecommons.org/licenses/by-nc/3.0/

 You may use this file in your own personal projects. You may 
 modify it if necessary. You may even share it, provided the 
 copyright above is present. No commercial use is permitted! 
*/


//+------------------------------------------------------------------+
//| Base class                                                       |
//+------------------------------------------------------------------+

class CIndicator
{
	protected:
		string _symbol;
		int _timeFrame;
		int _digits;
		
		void Init(string pSymbol, int pTimeFrame);
};

void CIndicator::Init(string pSymbol,int pTimeFrame)
{
   _symbol = pSymbol;
   _timeFrame = pTimeFrame;
   _digits = (int)MarketInfo(pSymbol,MODE_DIGITS);
}


//+------------------------------------------------------------------+
//| Moving average class                                             |
//+------------------------------------------------------------------+

class CiMA : CIndicator
{
   private:
      int _maPeriod;
      int _maShift;
      int _maMethod;
      int _appliedPrice;
      
   public:
      CiMA(string pSymbol, int pTimeFrame, int pMaPeriod, int pMaShift, int pMaMethod, int pAppliedPrice);
      double Main(int pShift = 0);
};

void CiMA::CiMA(string pSymbol,int pTimeFrame,int pMaPeriod,int pMaShift,int pMaMethod,int pAppliedPrice)
{
   Init(pSymbol, pTimeFrame);
   
   _maPeriod = pMaPeriod;
   _maMethod = pMaMethod;
   _maShift = pMaShift;
   _appliedPrice = pAppliedPrice;
}

double CiMA::Main(int pShift=0)
{
   double value = iMA(_symbol,_timeFrame,_maPeriod,_maShift,_maMethod,_appliedPrice,pShift);
   return NormalizeDouble(value,_digits);
}


//+------------------------------------------------------------------+
//| Stochastic class                                                 |
//+------------------------------------------------------------------+

class CiStochastic : CIndicator
{
   private:
      int _kPeriod;
      int _dPeriod;
      int _slowing;
      int _method;
      int _appliedPrice;
      
   public:
      CiStochastic(string pSymbol, int pTimeFrame, int pKPeriod, int pDPeriod, int pSlowing, int pMethod, int pAppliedPrice);
      double Main(int pShift = 0);
      double Signal(int pShift = 0);
};


void CiStochastic::CiStochastic(string pSymbol,int pTimeFrame,int pKPeriod,int pDPeriod,int pSlowing,int pMethod,int pAppliedPrice)
{
   Init(pSymbol,pTimeFrame);
   
   _kPeriod = pKPeriod;
   _dPeriod = pDPeriod;
   _slowing = pSlowing;
   _method = pMethod;
   _appliedPrice = pAppliedPrice;
}

double CiStochastic::Main(int pShift=0)
{
   double value = iStochastic(_symbol,_timeFrame,_kPeriod,_dPeriod,_slowing,_method,_appliedPrice,MODE_MAIN,pShift);
   return NormalizeDouble(value,_digits);
}

double CiStochastic::Signal(int pShift=0)
{
   double value = iStochastic(_symbol,_timeFrame,_kPeriod,_dPeriod,_slowing,_method,_appliedPrice,MODE_SIGNAL,pShift);
   return NormalizeDouble(value,_digits);
}


//+------------------------------------------------------------------+
//| RSI class                                                        |
//+------------------------------------------------------------------+

class CiRSI : CIndicator
{
   private:
      int _appliedPrice;
      int _period;
      
   public:
      CiRSI(string pSymbol, int pTimeFrame, int pPeriod, int pAppliedPrice);
      double Main(int pShift = 0);
};


CiRSI::CiRSI(string pSymbol,int pTimeFrame,int pPeriod,int pAppliedPrice)
{
   Init(pSymbol,pTimeFrame);
   
   _period = pPeriod;
   _appliedPrice = pAppliedPrice;
}

double CiRSI::Main(int pShift=0)
{
   double value = iRSI(_symbol,_timeFrame,_period,_appliedPrice,pShift);
   return NormalizeDouble(value,_digits);
}


//+------------------------------------------------------------------+
//| Bollinger bands class                                            |
//+------------------------------------------------------------------+

class CiBands : CIndicator
{
   private:
      int _period;
      double _deviation;
      int _shift;
      int _appliedPrice;
      
   public:
      void CiBands(string pSymbol, int pTimeFrame, int pPeriod, double pDeviation, int pShift, int pAppliedPrice);
      double Main(int pShift = 0);
      double Upper(int pShift = 0);
      double Lower(int pShift = 0); 
};

void CiBands::CiBands(string pSymbol,int pTimeFrame,int pPeriod,double pDeviation,int pShift,int pAppliedPrice)
{
   Init(pSymbol,pTimeFrame);
   
   _period = pPeriod;
   _deviation = pDeviation;
   _shift = pShift;
   _appliedPrice = pAppliedPrice;
}

double CiBands::Lower(int pShift=0)
{
   double value = iBands(_symbol,_timeFrame,_period,_deviation,_shift,_appliedPrice,MODE_LOWER,pShift);
   return NormalizeDouble(value,_digits);
}

double CiBands::Main(int pShift=0)
{
   double value = iBands(_symbol,_timeFrame,_period,_deviation,_shift,_appliedPrice,MODE_MAIN,pShift);
   return NormalizeDouble(value,_digits);
}

double CiBands::Upper(int pShift=0)
{
   double value = iBands(_symbol,_timeFrame,_period,_deviation,_shift,_appliedPrice,MODE_UPPER,pShift);
   return NormalizeDouble(value,_digits);
}


//+------------------------------------------------------------------+
//| MACD class                                                       |
//+------------------------------------------------------------------+

class CiMACD : CIndicator
{
   private:   
      int _fastEmaPeriod;
      int _slowEmaPeriod;
      int _signalPeriod;
      int _appliedPrice;
      
   public:
      void CiMACD(string pSymbol, int pTimeFrame, int pFastEmaPeriod, int pSlowEmaPeriod, int pSignalPeriod, int pAppliedPrice);
      double Main(int pShift = 0);
      double Signal(int pShift = 0);
};

void CiMACD::CiMACD(string pSymbol,int pTimeFrame,int pFastEmaPeriod,int pSlowEmaPeriod,int pSignalPeriod,int pAppliedPrice)
{
   CIndicator::Init(pSymbol,pTimeFrame);
   
   _fastEmaPeriod = pFastEmaPeriod;
   _slowEmaPeriod = pSlowEmaPeriod;
   _signalPeriod = pSignalPeriod;
   _appliedPrice = pAppliedPrice;
}

double CiMACD::Main(int pShift=0)
{
   double value = iMACD(_symbol,_timeFrame,_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_MAIN,pShift);
   return NormalizeDouble(value,_digits);
}

double CiMACD::Signal(int pShift=0)
{
   double value = iMACD(_symbol,_timeFrame,_fastEmaPeriod,_slowEmaPeriod,_signalPeriod,_appliedPrice,MODE_SIGNAL,pShift);
   return NormalizeDouble(value,_digits);
}
