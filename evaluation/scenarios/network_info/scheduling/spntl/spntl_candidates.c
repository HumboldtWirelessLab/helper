/*
 *CANDIDATES Auxiliary algorithm for schedule with Positive and Negative Time-Lags
 *
 *    see also SPNTL_BAB.C, BAB.C

 *  Author(s): P. Sucha
 *   Copyright (c) 2005 CTU FEE
 *   $Revision: 589 $  $Date: 2006-11-03 09:01:23 +0100 (pá, 03 XI 2006) $

 *   This file is part of Scheduling Toolbox.
 *
 *   Scheduling Toolbox is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU General Public License as
 *   published by the Free Software Foundation; either version 2 of the
 *   License, or (at your option) any later version.
 *
 *   Scheduling Toolbox is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   General Public License for more details.
 * 
 *   You should have received a copy of the GNU General Public License
 *   along with Scheduling Toolbox; if not, write to the Free Software
 *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 *   USA *  This file is part of Scheduling Toolbox.
 */


#include "spntl_bab.h"


void candidates(int *partialSchedule, int *partialTc)
{

	int i,j;

	for(i=0;i<n;i++)
	{
		if(partialSchedule[i]!=-1)
		{
			partialTc[i]=0;
			continue;
		}

		partialTc[i]=1;

		for(j=0;j<n;j++)
			if(Wpos[j][i]!=0 && partialSchedule[j]==-1) partialTc[i]=0;
	}
}

/* End of file. */

