/*
 *SPNTL_BAB Header file for algorithm for schedule with Positive and Negative Time-Lags
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


#include <stdio.h>
#include <string.h>
#include <time.h>


#define N_MAX	100
#define M_MAX	10
/*#define CMAXINF	200*/


#define OPTIONS_LONGPATH	0x01
#define OPTIONS_SUMOFP		0x02
#define OPTIONS_CMAX		0x04


#define max(a, b)  (((a) > (b)) ? (a) : (b))
#define min(a, b)  (((a) < (b)) ? (a) : (b))

extern int n,m;
extern int p[N_MAX],machine[N_MAX];
extern int W[N_MAX][N_MAX];
extern int Wpos[N_MAX][N_MAX];
extern int F[N_MAX][N_MAX];
extern int Schedule[N_MAX];
extern int Cmax;
extern int nodeCounter;
extern int Tc[N_MAX];
extern int methodOption;
extern int verboseMode;

extern int CMAXINF;


void candidates(int *partialSchedule, int *partialTc);
int bab(int *partialSchedule,int *partialScheduleOrder,int *partialTc,int *partialCmax,int nScheduled, int lastScheduled);


/*End of file*/
