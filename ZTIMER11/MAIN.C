/****************************************************************************
*
*								 Zen Timer
*
*							   From the book
*						 "Zen of Assembly Language"
*							Volume 1, Knowledge
*
*							 by Michael Abrash
*
*					Simple Test program by Kendall Bennett
*
* Filename:		$RCSfile: main.c $
* Version:		$Revision: 1.2 $
*
* Language:		ANSI C
* Environment:	MS DOS (IBM PC)
*
* Description:	Test program for the Zen Timer Library.
*
* $Id: main.c 1.2 92/04/20 17:34:03 kjb release $
*
* Revision History:
* -----------------
*
* $Log:	main.c $
* Revision 1.2  92/04/20  17:34:03  kjb
* Modified to allow timing across a midnight boundary
* 
* Revision 1.1  92/01/27  21:43:06  kjb
* Initial revision
* 
****************************************************************************/

#include <stdio.h>
#include <dos.h>
#include "debug.h"
#include "ztimer.h"

#define	DELAY_SECS	10

/*-------------------------- Implementation -------------------------------*/

/* The following routine takes a long count in microseconds and outputs
 * a string representing the count in seconds. It could be modified to
 * return a pointer to a static string representing the count rather
 * than printing it out.
 */

void ReportTime(ulong count)
{
	ulong	secs;

	secs = count / 1000000L;
	count = count - secs * 1000000L;
	printf("Time taken: %lu.%06lu seconds\n",secs,count);
}

int		i,j;								/* NON register variables! */

int main(void)
{
	ulong	count,start,finish;

	/* Test the precision timer routine */

	PZTimerOn();
	for (i = 0; i < 10000; i++)
		i = i;
	PZTimerOff();
	PZTimerReport();
	count = PZTimerCount();
	printf("Count returned: %lu\n",count);

	/* Test the precision timer routine for overflow */

	PZTimerOn();
	for (j = 0; j < 10; j++)
		for (i = 0; i < 20000; i++)
			i = i;
	PZTimerOff();
	PZTimerReport();
	count = PZTimerCount();
	printf("Count returned: %lu\n",count);

	/* Test the long period Zen Timer (we don't check for overflow coz
	 * it would take tooooo long!)
	 */

	LZTimerOn();
	for (j = 0; j < 10; j++)
		for (i = 0; i < 20000; i++)
			i = i;
	LZTimerOff();
	LZTimerReport();
	ReportTime(LZTimerCount());

	/* Test the ultra long period Zen Timer */

	start = ULZReadTime();
	delay(DELAY_SECS * 1000);
	finish = ULZReadTime();
	printf("Delay of %d secs took %d 1/10ths of a second\n",
		DELAY_SECS,ULZElapsedTime(start,finish));

	return 0;
}
