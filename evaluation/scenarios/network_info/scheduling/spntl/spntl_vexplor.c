/*
 *BAB Branch and Bound algorithm for schedule with Positive and Negative Time-Lags
 *
 *    see also SPNTL_BAB.C, CANDIDATES.C

 *   Author(s): P. Sucha
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
#include <memory.h>


#define NORMAL_RETURN	0
#define ONE_LEVEL_UP	1

#define SHIFTED			0
#define NON_FEASIBLE	1


void printVector(int *vector,int n);
int loopShifting(int *partialSchedule, int *partialScheduleOrder, int *newPartialCmax, int bEfrom, int bEto, int virtualTask);


int bab(int *partialSchedule,int *partialScheduleOrder,int *partialTc,int *partialCmax,int nScheduled, int lastScheduled)
{
	int newPartialSchedule[N_MAX];              /*new... - "son" of current vrtex in searching tree*/
	int newPartialScheduleOrder[N_MAX];
	int newPartialTc[N_MAX];
	int newPartialCmax[M_MAX];
	int sk;					    /*start time of Tk*/
	int estOfSj,innerSum;	    /*estimation of sj*/
	int i,j,k,l;			    /*Index*/
	int newBwe,backupOfEdge;	/*transformed edge and backup of old edge*/
	int status;					/*return status of loopShifting function*/
	int temp,copyOfI,copyOfJ;	/*temporal variables*/
	int partialScheduleCmax,oldPartialCmax;
	int branchCounter=0;


	/*Initialisation - copy "father" to "son"*/
	memcpy(newPartialSchedule,partialSchedule,sizeof(int)*n);
	memcpy(newPartialScheduleOrder,partialScheduleOrder,sizeof(int)*n);
	memcpy(newPartialTc,partialTc,sizeof(int)*n);
	memcpy(newPartialCmax,partialCmax,sizeof(int)*(m+1));



	/********************************************************************************/
	/* Test relative deadlines - BOUND */

	for(i=0;i<n;i++)
	for(j=0;j<n;j++)
	if(W[j][i]<0 && newPartialSchedule[i]!=-1)		/*Backward edge and Ti is already scheduled*/
	{
		/*******************************/
		/* Basic bounding */
		/*******************************/
		if(newPartialSchedule[j]!=-1)
		if((newPartialSchedule[j]-newPartialSchedule[i]+W[j][i])>0)
		{
			copyOfI=i; copyOfJ=j;
			if(loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,copyOfJ,copyOfI,-1)==NON_FEASIBLE)
				return(ONE_LEVEL_UP);		/*The partial solution is not feasible*/
		}

		/*******************************/
		/* Longest Path */
		/*******************************/
		if(newPartialSchedule[j]==-1 && methodOption&OPTIONS_LONGPATH) /* && 0)*/
		{
			if(F[lastScheduled][j]>0)
				estOfSj = F[lastScheduled][j] + newPartialSchedule[lastScheduled];	/*estimate sj*/
			else
				estOfSj = newPartialCmax[machine[j]];	/*estimate sj*/

			if((estOfSj-newPartialSchedule[i]+W[j][i])>0)
			{
							
				/* Calculate new backward edge */
				if(F[lastScheduled][j]>0)
					newBwe=F[lastScheduled][j]+W[j][i];
				else
				{
					if(machine[lastScheduled]==machine[j])
						newBwe=p[lastScheduled]+W[j][i];
					else
						newBwe=1;	/*A positive value*/
				}

				/*Calculate latenes for new BEW*/
				temp=partialSchedule[i] - partialSchedule[lastScheduled] + W[i][lastScheduled];

				if(newBwe<0) /* && lastScheduled!=i && temp>0)	It must be a backvard edge.*/
				{
					backupOfEdge=W[lastScheduled][i];
					W[lastScheduled][i]=newBwe;				

					/* Shifting of the schedule */
					/*temp=i;*/
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,-1);
					W[lastScheduled][i]=backupOfEdge;	/*undo changes in matrix*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
					{
						if(F[lastScheduled][j]>0)
							return(ONE_LEVEL_UP);		/*The partial solution is not feasible.*/
						else
							return(NORMAL_RETURN);		/*The partial solution is not feasible.*/
					}

				
				}
				else /* POKUS */
				if(newBwe>=0) /* && temp>0)*/
				{
					/*newPartialSchedule[i]+=(estOfSj-newPartialSchedule[i]+W[j][i]);*/
					newPartialSchedule[j]=estOfSj;

					/* Shifting of the schedule */
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,copyOfJ);
					newPartialSchedule[j]=-1;	/*undo changes vector of starting times*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
					{
						if(F[lastScheduled][j]>0)
							return(ONE_LEVEL_UP);		/*The partial solution is not feasible*/
						else
							return(NORMAL_RETURN);		/*The partial solution is not feasible*/
					}
				
				}
				

			}
		}
	

		/*******************************/
		/* Sum of processing time */
		/*******************************/
		if(newPartialSchedule[j]==-1 && machine[j]==machine[lastScheduled] && methodOption&OPTIONS_SUMOFP) /* && 0)*/
		{
			innerSum=0;
			for(l=0;l<n;l++)
			{
				if(F[l][j]>0 && newPartialSchedule[l]==-1 && machine[j]==machine[l])
					innerSum+=p[l];
			}

			estOfSj = newPartialCmax[machine[j]] + innerSum;	/*estimate sj*/

			if((estOfSj-newPartialSchedule[i]+W[j][i])>0)
			{
							
				/* Calculate new backward edge */
				/*newBwe=innerSum+p[lastScheduled]+W[j][i];*/

				if(machine[lastScheduled]==machine[j])
					newBwe=innerSum+p[lastScheduled]+W[j][i];
				else
					newBwe=1;	/*A positive value*/

				/*Calculate latenes for new BEW*/
				temp=partialSchedule[i] - partialSchedule[lastScheduled] + W[i][lastScheduled];

				if(newBwe<0) /* && lastScheduled!=i && temp>0)	It must be a backvard edge*/
				{
					backupOfEdge=W[lastScheduled][i];
					W[lastScheduled][i]=newBwe;					

					/* Shifting of the schedule */
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,-1);
					W[lastScheduled][i]=backupOfEdge;	/*undo changes in matrix*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
						return(NORMAL_RETURN);		/*The partial solution is not feasible*/
				
				}
				else /* POKUS */
				if(newBwe>=0) /* && temp>0)*/
				{
					/*newPartialSchedule[i]+=(estOfSj-newPartialSchedule[i]+W[j][i]);*/
					newPartialSchedule[j]=estOfSj;

					/* Shifting of the schedule */
					copyOfI=i; copyOfJ=j;
					status=loopShifting(newPartialSchedule,newPartialScheduleOrder,newPartialCmax,lastScheduled,copyOfI,copyOfJ);
					newPartialSchedule[j]=-1;	/*undo changes vector of starting times*/

					/* Results of shifting */
					if(status==NON_FEASIBLE)
						return(NORMAL_RETURN);		/*The partial solution is not feasible*/
				}
				

			}
		}



	}



	/********************************************************************************/

	/*Debug informations*/
	if(verboseMode==2)
	{
        mexPrintf(":");
	    printVector(newPartialSchedule,n);
	}
	nodeCounter++;


	/********************************************************************************/
	/* Test if the partial schedule is final solution */
	if(nScheduled==n)
	{
		partialScheduleCmax=0;
		for(i=0;i<m;i++)
			partialScheduleCmax=max(partialScheduleCmax,newPartialCmax[i]);

		if(partialScheduleCmax<Cmax)
		{
			/*Better solution have been found.*/
			memcpy(Schedule,newPartialSchedule,sizeof(int)*n);
			Cmax=partialScheduleCmax;
			if(methodOption&OPTIONS_CMAX) W[n-1][0]=-Cmax+2;
			if(verboseMode>=1)
			{
			    mexPrintf("(Cmax=%d):",Cmax);       /*Print debug info.*/
			    printVector(newPartialSchedule,n);
			}
		}
		return(NORMAL_RETURN);
	}


	/********************************************************************************/
	/* Scheduling of candidates - BRANCH */

	/* Branching - MONO+*/
	for(k=0;k<n;k++)
	{
		if(newPartialTc[k]==0) continue;	/*It is not a candidate task.*/

		/*Calculate sk*/
		sk=newPartialCmax[machine[k]];
		for(i=0;i<n;i++)
		{
			if(newPartialSchedule[i]!=-1 && Wpos[i][k]!=0)
					sk=max(sk,newPartialSchedule[i]+Wpos[i][k]);
		}

		newPartialSchedule[k]=sk;				/*Schedule task Tk*/
		newPartialScheduleOrder[nScheduled]=k;
		oldPartialCmax=newPartialCmax[machine[k]];
		newPartialCmax[machine[k]]=sk+p[k];

		/*Find new candidates.*/
		candidates(newPartialSchedule,newPartialTc);

		/*Branch now*/
		if(bab(newPartialSchedule,newPartialScheduleOrder,newPartialTc,newPartialCmax,1+nScheduled,k)==ONE_LEVEL_UP)
		{
			if(methodOption!=0)	return NORMAL_RETURN;
		}

		/*Go back (remove Tk from schedule)*/
		newPartialSchedule[k]=-1;				/*Unschedule Tk*/
		memcpy(newPartialTc,partialTc,sizeof(int)*n);
		newPartialCmax[machine[k]]=oldPartialCmax;		/*Mozna to neni dost bezpecne!!!*/
		branchCounter++;
	}

	return NORMAL_RETURN;

}





/************************************************************************************/
/************************************************************************************/
/* Complementray functions */
/************************************************************************************/
/************************************************************************************/


/************************************************************************************/
/* Print a vector to Matlab window */
void printVector(int *vector,int n)
{
	int i;

	for(i=0;i<n;i++)
		mexPrintf("%d,",vector[i]);
		
	mexPrintf("\n");
}


/************************************************************************************/
/* Loop shifting - Start time recalculation (anomaly) */

/* Shifts in schedule */
void scheduleShifting(int *partialSchedule,int *partialScheduleOrder, int bEfrom, int bEto, int Lk)
{
	int i,j,k,sk;
	int partialCmaxForShifting[M_MAX];

	for(i=0;i<m;i++) partialCmaxForShifting[i]=0;

	partialSchedule[bEto]+=Lk;		/*Shift task which the deadline is related to*/
	
	for(i=0;i<n;i++)
	{
		j=partialScheduleOrder[i];	/*Index of the "last" task where shifting begins*/
		partialCmaxForShifting[machine[j]]=max(partialCmaxForShifting[machine[j]],partialSchedule[j]+p[j]);

		if(j==bEto) break;
	}

	/*DEBUG*/
	/*partialCmaxForShifting[machine[bEto]]=partialSchedule[bEto]+p[bEto];*/
	if(partialCmaxForShifting[machine[bEto]]!=partialSchedule[bEto]+p[bEto])
	{
		i=0;
	}


	for(i=0;i<n;i++) if(partialScheduleOrder[i]==bEto) break;	/*Find position of T_{bEto} in the schedule (=k)*/

	for(j=i+1;j<n;j++)
	{
		/*Calculate sk*/
		k=partialScheduleOrder[j];	/*Take next scheduled task*/
		if(k==-1) break;
		sk=partialCmaxForShifting[machine[k]];
		for(i=0;i<n;i++)
		{
			if(partialSchedule[i]!=-1 && Wpos[i][k]!=0)
			{
				sk=max(sk,partialSchedule[i]+Wpos[i][k]);
				/*sk=max(sk,partialSchedule[i]+p[i]);*/
			}
		}
		partialSchedule[k]=sk;
		partialCmaxForShifting[machine[k]]=sk+p[k];
	}

}


/************************************************************************************/
/* Decide anomaly */
int loopShifting(int *partialSchedule, int *partialScheduleOrder, int *partialCmax, int bEfrom, int bEto, int virtualTask)
{
	int i,j,Lk,LkLocal,oldPartialCmax;
	int iCritical, jCritical;	/*A nonrespected backward edge*/
	int watchDogCounter=0;	

	oldPartialCmax=partialSchedule[bEfrom];
	Lk = partialSchedule[bEfrom] - partialSchedule[bEto] + W[bEfrom][bEto];

	/*DEBUG*/
	if(Lk<0)
	{
		int temp=0;
		return NON_FEASIBLE;
	}


	if(W[bEfrom][bEto]==0) Lk=0;	/*Lk<0*/

	/*Shift task T_{bEto} and reshedule the schedule*/
	scheduleShifting(partialSchedule,partialScheduleOrder,bEfrom,bEto,Lk);

	while(1)
	{
	watchDogCounter++;

	if(watchDogCounter>N_MAX*2)
		return NON_FEASIBLE;		/*Moje chyba*/

	if(oldPartialCmax<partialSchedule[bEfrom])
		return NON_FEASIBLE;		/*The task under the deadline was shifted to => non-feasible solution*/

	/* Test all activated deadlines */
	Lk=0;
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			if(partialSchedule[i]!=-1 && partialSchedule[j]!=-1)		/*Ti and Tj must be scheduled*/
			{
				if(W[i][j]<0)
				{
					LkLocal=partialSchedule[i]-partialSchedule[j]+W[i][j];
					if(Lk<LkLocal)
					{
						Lk=LkLocal;
						iCritical=i; jCritical=j;
					}
				}
			}
		}
	}

	if(Lk>0)
	{
		scheduleShifting(partialSchedule,partialScheduleOrder,iCritical,jCritical,Lk);		/*a subconflict*/
	}
	else
	{
		for(i=0;i<m;i++) partialCmax[i]=0;

		for(i=0;i<n;i++)
		{
			int curMachine;

			curMachine=machine[i];
			if(partialSchedule[i]!=-1 && i!=virtualTask)
				partialCmax[curMachine]=max(partialCmax[curMachine],partialSchedule[i]+p[i]);
		}
		return SHIFTED;			/*Rescheduling was successful.*/
	}

	}
}




/* End of file. */
