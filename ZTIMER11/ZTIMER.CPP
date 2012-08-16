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
* Filename:		$RCSfile: ztimer.cpp $
* Version:		$Revision: 1.4 $
*
* Language:		C++ 2.1
* Environment:	IBM PC (MS DOS)
*
* Description:	Non-inline member functions for the C++ class interface
*				to the Zen Timer Library.
*
* $Id: ztimer.cpp 1.4 92/04/21 01:47:50 kjb release $
*
* Revision History:
* -----------------
*
* $Log:	ztimer.cpp $
* Revision 1.4  92/04/21  01:47:50  kjb
* Fixed bug in display routine for ULZTimer.
* 
* Revision 1.3  92/04/21  01:19:54  kjb
* Converted to memory model dependant library.
* 
* Revision 1.2  92/04/21  00:47:36  kjb
* Fixed code to be memory model independant.
* 
* Revision 1.1  92/04/20  17:34:54  kjb
* Initial revision
* 
****************************************************************************/

#include <iostream.h>
#include "ztimer.h"

/*----------------------------- Implementation ----------------------------*/

// Routine to stop the ultra long period timer. The timer resolution is low
// enough to make this routine non-inline.

void ULZTimer::stop()
{
	_finish = ULZReadTime();
	if (!overflow()) {
		ulong newcount = _count + ULZElapsedTime(_start,_finish);
		if (newcount < _count || newcount == 0xFFFFFFFF)
			_overflow = true;
		else
			_count = newcount;
		}
}

// Member functions to output the timed count in seconds to a stream.

ostream& operator << (ostream& o,PZTimer& timer)
{
	if (!timer.overflow()) {
		o << timer.count() / timer.resolution() << '.';
		int width = o.width(6);
		char fill = o.fill('0');
		o << timer.count() % timer.resolution();
		o.width(width);
		o.fill(fill);
		}
	else
		o << "overflow";
	return o;
}

ostream& operator << (ostream& o,LZTimer& timer)
{
	if (!timer.overflow()) {
		o << timer.count() / timer.resolution() << '.';
		int width = o.width(6);
		char fill = o.fill('0');
		o << timer.count() % timer.resolution();
		o.width(width);
		o.fill(fill);
		}
	else
		o << "overflow";
	return o;
}

ostream& operator << (ostream& o,ULZTimer& timer)
{
	if (!timer.overflow())
		o << timer.count() / timer.resolution() << '.'
		  << timer.count() % timer.resolution();
	else
		o << "overflow";
	return o;
}
