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
* Filename:		$RCSfile: main.cpp $
* Version:		$Revision: 1.1 $
*
* Language:		C++ 2.1
* Environment:	MS DOS (IBM PC)
*
* Description:	Test program for the Zen Timer Library C++ interface.
*
* $Id: main.cpp 1.1 92/04/20 17:34:22 kjb release $
*
* Revision History:
* -----------------
*
* $Log:	main.cpp $
* Revision 1.1  92/04/20  17:34:22  kjb
* Initial revision
* 
****************************************************************************/

#include <iostream.h>
#include <dos.h>
#include "ztimer.h"

#define	DELAY_SECS	10

/*-------------------------- Implementation -------------------------------*/

int		i,j;								/* NON register variables! */

int main(void)
{
	PZTimer		ptimer;
	LZTimer		ltimer;
	ULZTimer	ultimer;

	/* Test the precision timer routine */

	for (j = 0; j < 5; j++) {
		ptimer.start();
		for (i = 0; i < 10000; i++)
			i = i;
		ptimer.stop();
		}
	cout << "Count: " << ptimer.count() << endl;
	cout << "Time: " << ptimer << " secs\n";

	/* Test the precision timer routine for overflow */

	ptimer.restart();
	for (j = 0; j < 10; j++)
		for (i = 0; i < 20000; i++)
			i = i;
	ptimer.stop();
	cout << "Count: " << ptimer.count() << endl;
	cout << "Time: " << ptimer << " secs\n";

	/* Test the long period Zen Timer (we don't check for overflow coz
	 * it would take tooooo long!)
	 */

	ltimer.start();
	for (j = 0; j < 10; j++)
		for (i = 0; i < 20000; i++)
			i = i;
	ltimer.stop();
	cout << "Count: " << ltimer.count() << endl;
	cout << "Time: " << ltimer << " secs\n";

	/* Test the ultra long period Zen Timer */

	ultimer.start();
	delay(DELAY_SECS * 1000);
	ultimer.stop();
	cout << "Delay of " << DELAY_SECS << " secs took " << ultimer.count()
		 << " 1/10ths of a second\n";
	cout << "Time: " << ultimer << " secs\n";

	return 0;
}
