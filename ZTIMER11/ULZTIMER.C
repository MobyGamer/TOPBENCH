/****************************************************************************
*
*						  Ultra Long Period Timer
*
*					Copyright (C) 1992 Kendall Bennett.
*							All rights reserved.
*
* Filename:		$RCSfile: ulztimer.c $
* Version:		$Revision: 1.3 $
*
* Language:		ANSI C
* Environment:	any
*
* Description:	Module to interface to the BIOS Timer Tick for timing
*				code that takes up to 24 hours (ray tracing etc). There
*				is a small overhead in calculating the time, this
*				will be negligible for such long periods of time.
*
* $Id: ulztimer.c 1.3 92/04/21 01:47:37 kjb release $
*
* Revision History:
* -----------------
*
* $Log:	ulztimer.c $
* Revision 1.3  92/04/21  01:47:37  kjb
* Fixed bug in ULZElapsedTime().
* 
* Revision 1.2  92/04/21  01:19:36  kjb
* Converted to memory model dependant library.
* 
* Revision 1.1  92/04/20  17:34:35  kjb
* Initial revision
* 
****************************************************************************/

#include "ztimer.h"

/* Macro to obtain the current timer tick value */

#define peekul(__segment,__offset) (*((ulong  far*)FP(__segment, __offset)))
#define	readticks()	peekul(0x40,0x6C)

/* Macros to enable and disable interrupts. These work under Borland C++
 * but will probably need to be modified for other compilers.
 */

#define disable( ) __emit__( (char )( 0xfa ) )
#define enable( )  __emit__( (char )( 0xfb ) )

PUBLIC ulong ULZReadTime(void)
/****************************************************************************
*
* Function:		ULZReadTime
* Returns:		Current timer tick count.
*
* Description:	We turn of interrupts while we
*				get the value from the BIOS data area since it is stored
*				as two bytes and an interrupt COULD stuff up our reading.
*
****************************************************************************/
{
	ulong	ticks;

	disable();				/* Turn of interrupts 				*/
	ticks = readticks();	/* Read the BIOS timer tick value	*/
	enable();				/* Turn on interrupts again 		*/

	return ticks;
}

PUBLIC ulong ULZElapsedTime(ulong start,ulong finish)
/****************************************************************************
*
* Function:		ULZElapsedTime
* Parameters:	start	- Starting timer tick value
*				finish	- Ending timer tick value
*
* Returns:		Elapsed timer between starting time and ending time in
*				1/10 ths of a second.
*
****************************************************************************/
{
	/* Check to see whether a midnight boundary has passed, and if so
	 * adjust the finish time to account for this. We cannot detect if
	 * more that one midnight boundary has passed, so if this happens
	 * we will be generating erronouse results.
	 */

	if (finish < start)
		finish += 1573040L;			/* Number of ticks in 24 hours		*/

	finish -= start;

	/* Convert to 1/10ths of a second. We dont have enough precision in
	 * an unsigned long to convert the value accurately, so we must
	 * do the conversion in floating point. I prefer the answer as an
	 * unsigned long so it is returned that way rather than as a double.
	 */

	return (finish / ((double)119318.0 / 65536.0));
}
