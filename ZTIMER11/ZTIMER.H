/****************************************************************************
*
*						   The Zen Timer Library
*
*							   From the book
*						 "Zen of Assembly Language"
*							Volume 1, Knowledge
*
*							 by Michael Abrash
*
*					  Modifications by Kendall Bennett
*
* Filename:		$RCSfile: ztimer.h $
* Version:		$Revision: 1.9 $
*
* Language:		ANSI C, C++ 2.1
* Environment:	IBM PC (MS DOS)
*
* Description:	Header file for the Zen Timer library. Provides a number
*				of routines to accurately time segments of code. A
*				precision timer is provided for highly accurate timing of
*				code that takes less than 54 ms to execute, and a long
*				period timer is provided to time code that takes up to
*				one hour to execute. All output is in microseconds.
*
*				The ultra long period timer can be used to time code
*				that takes up to 24 hours to execute (raytracing
*				etc).
*
*				We also now provide a set of C++ classes to manipulate
*				the Zen Timers. Note that you can only have one timer
*				running at a time!! Note that all of the code is inline
*				to make it memory model independant, and to avoid the
*				extra cost of a function call overhead in the C++ wrappers.
*
* $Id: ztimer.h 1.9 92/04/21 01:19:51 kjb release $
*
* Revision History:
* -----------------
*
* $Log:	ztimer.h $
* Revision 1.9  92/04/21  01:19:51  kjb
* Converted to memory model dependant library.
* 
* Revision 1.8  92/04/21  00:47:55  kjb
* Fixed code to be memory model independant.
* 
* Revision 1.7  92/04/20  23:30:52  kjb
* Cosmetic changes.
* 
* Revision 1.6  92/04/20  17:35:07  kjb
* Added C++ classes to manipulate the timers.
* ./
* 
* Revision 1.5  92/01/27  21:40:01  kjb
* Converted to a memory model independant library, and released to the
* public.,
*
* Revision 1.4  91/12/31  19:34:51  kjb
* Changed include file directories.
*
* Revision 1.3  91/12/26  17:56:38  kjb
* Added dependency on DEBUG.H
*
* Revision 1.2  91/11/16  17:12:20  kjb
* Modified to return a long integer representing the count rather than a
* string.
*
* Revision 1.1  91/11/14  17:19:58  kjb
* Initial revision
*
****************************************************************************/

#ifndef	__ZTIMER_H
#define	__ZTIMER_H

#ifndef __DEBUG_H
#include "debug.h"
#endif

/*-------------------------- Function Prototypes --------------------------*/

#ifdef	__cplusplus
extern "C" {			/* Use "C" linkage when in C++ mode	*/
#endif

/* Precision timing routines in PZTIMER.ASM */

void	far PZTimerOn(void);
void	far PZTimerOff(void);
void	far PZTimerReport(void);
ulong	far PZTimerCount(void);

/* Long period timing routines in LZTIMER.ASM */

void 	far LZTimerOn(void);
void 	far LZTimerOff(void);
void 	far LZTimerReport(void);
ulong 	far LZTimerCount(void);

/* Ultra long period timing routines in TIMER.C */

ulong	ULZReadTime(void);
ulong	ULZElapsedTime(ulong start,ulong finish);

#ifdef	__cplusplus
}						/* End of "C" linkage for C++	*/
#endif

/*--------------------------- Class Definitions ---------------------------*/

#ifdef	__cplusplus

#ifndef	__IOSTREAM_H
#include <iostream.h>
#endif

//---------------------------------------------------------------------------
// Precision Zen Timer class. This can be used to time code that takes up
// to 54 ms to execute between calls to start() and stop() or lap(). The
// aggregate count can be up to 2^32 - 1 microseconds (about 1 hour
// and 10 mins).
//---------------------------------------------------------------------------

class PZTimer {
protected:
	ulong	_count;				// Running count
	short	_overflow;			// Flags an overflow

public:
			// Constructor
			PZTimer()		{ _count = 0; _overflow = false; };

			// Method to start the timer
			void start()	{ PZTimerOn(); };

			// Method to restart the timer
			void restart()	{ reset(); start(); };

			// Method to stop the timer
			void stop()
			{
				PZTimerOff();
				if (!overflow()) {
					ulong newcount = _count + PZTimerCount();
					if (newcount < _count || newcount == 0xFFFFFFFF)
						_overflow = true;
					else
						_count = newcount;
					}
			};

			// Method to return the current count
			ulong count()	{ return overflow() ? 0xFFFFFFFF : _count; };

			// Method to reset the timer to a zero count
			void reset()	{ _count = 0; _overflow = false; };

			// Method to determine if overflow occurred
			bool overflow()	{ return _overflow; };

			// Method to return timer resolution (counts in a second).
			ulong resolution()	{ return 1000000L; };

			// Method to display the timed count in seconds
	friend	ostream& operator << (ostream& o,PZTimer& timer);
	};

//---------------------------------------------------------------------------
// Long Period Zen Timer class. This can be used to time code that takes up
// to 1 hour to execute between calls to start() and stop() or lap(). The
// aggregate count can be up to 2^32 - 1 microseconds (about 1 hour
// and 10 mins).
//---------------------------------------------------------------------------

class LZTimer {
protected:
	ulong	_count;
	short	_overflow;
public:
			// Constructor
			LZTimer()		{ _count = 0; _overflow = false; };

			// Method to start the timer
			void start()	{ LZTimerOn(); };

			// Method to restart the timer
			void restart()	{ reset(); start(); };

			// Method to stop the timer
			void stop()
			{
				LZTimerOff();
				if (!overflow()) {
					ulong newcount = _count + LZTimerCount();
					if (newcount < _count || newcount == 0xFFFFFFFF)
						_overflow = true;
					else
						_count = newcount;
					}
			};

			// Method to return the current count
			ulong count()	{ return overflow() ? 0xFFFFFFFF : _count; };

			// Method to reset the timer to a zero count
			void reset()	{ _count = 0; _overflow = false; };

			// Method to determine if overflow occurred
			bool overflow()	{ return _overflow; };

			// Method to return timer resolution (counts in a second).
			ulong resolution()	{ return 1000000L; };

			// Method to display the timed count in seconds
	friend	ostream& operator << (ostream& o,LZTimer& timer);
	};

//---------------------------------------------------------------------------
// Ultra Long Period Zen Timer class. This can be used to time code that
// takes up 24 hours total to execute between calls to start() and stop().
// The aggregate count can be up to 2^32 - 1 tenths of a second, which
// is about 119,000 hours! Should be enough for most applications.
//---------------------------------------------------------------------------

class ULZTimer {
protected:
	ulong	_count,_start,_finish;
	short	_overflow;
public:
			// Constructor
			ULZTimer()		{ _count = 0; _overflow = false; };

			// Method to start the timer
			void start()	{ _start = ULZReadTime(); };

			// Method to restart the timer
			void restart()	{ reset(); start(); };

			// Method to stop the timer
			void stop();

			// Method to return the current count
			ulong count()	{ return overflow() ? 0xFFFFFFFF : _count; };

			// Method to reset the timer to a zero count
			void reset()	{ _count = 0; _overflow = false; };

			// Method to determine if overflow occurred
			bool overflow()	{ return _overflow; };

			// Method to return timer resolution (counts in a second).
			ulong resolution()	{ return 10L; };

			// Method to display the timed count in seconds
	friend	ostream& operator << (ostream& o,ULZTimer& timer);
	};

#endif

#endif	__ZTIMER_H
