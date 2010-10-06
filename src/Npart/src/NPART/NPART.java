package NPART;

import java.util.*;

/**
 * @author milic bratislav
 * Humboldt University, Berlin
 * milic@informatik.hu-berlin.de
 * 
 * NPART generator
 * http://www.rok.informatik.hu-berlin.de/npart
 * 
 *  this version of the class uses data from main partitions of Berlin and Leipzig networks. 
 * 
 */


public class NPART {
	public static boolean useAdaptive=true;
	
	int retries=100;
	double negativePenalty=5;

	private static final int avgFFnodes=275;
	private static final int avgLnodes=346;

	static double distroFF[]={0, 78465, 68843, 73207, 48042, 33645, 27735, 19989, 13656, 6941, 6901, 5705, 4695, 4648, 4018, 2517, 1532, 938, 776, 411, 156, 40, 12, 6};
	static double distroL[]={0, 51487, 94048, 81781, 70696, 62997, 48679, 38265, 30233, 19277, 15383, 12252, 9611, 5748, 3366, 2322, 1570, 1060, 593, 307, 135, 36, 10, 0, 1, 5, 2, 2, 1, 1, 2};

	static double distroRWM[]={0, 0.03544906, 0.05118465, 0.06427446, 0.07541387, 0.08437332, 0.09012567, 0.09205094, 0.09063003, 0.08496314, 0.07598861, 0.06482574, 0.05270275, 0.04041555, 0.02891086, 0.01993800};
	static double distroUNI[]={0, 0.03177250, 0.07457625, 0.12269125, 0.15764750, 0.16582500, 0.14864000, 0.11547000, 0.07915625, 0.04790250, 0.02611750, 0.01289625, 0.00593625, 0.00258250, 0.00101875, 0.00041875};

	// by default not used
	// if set to non-zero value it is activated
	static private double secondaryMetricWeight=0;

	//distribution of node degree of neighbors: starting from degree 1
	static int[][] FFsec=
	{{0, 0, 9687, 13823, 11731, 9820, 7083, 4807, 4053, 3222, 2477, 1913, 2247, 2455, 1735, 1434, 698, 535, 357, 215, 92, 52, 15, 13, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 9687, 25818, 24126, 14213, 13876, 9558, 6791, 5290, 3527, 3908, 3650, 3560, 3126, 2639, 2000, 1219, 1470, 1573, 1019, 433, 136, 47, 16, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 13823, 24126, 42522, 23584, 18983, 19588, 13023, 9896, 6600, 7223, 7132, 6546, 7900, 6817, 4128, 2401, 1957, 1920, 946, 355, 93, 37, 19, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 11731, 14213, 23584, 24154, 23289, 19007, 17346, 13436, 7038, 7748, 7798, 5616, 5012, 4191, 2414, 1320, 1441, 1496, 855, 339, 103, 25, 9, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 9820, 13876, 18983, 23289, 22094, 17539, 14793, 9222, 6430, 6110, 5516, 4742, 3776, 2985, 2157, 1634, 1746, 1825, 1113, 434, 95, 31, 14, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 7083, 9558, 19588, 19007, 17539, 23942, 18298, 13166, 7753, 7446, 5736, 3633, 2832, 2651, 2230, 1827, 1475, 1458, 773, 293, 78, 23, 19, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4807, 6791, 13023, 17346, 14793, 18298, 17782, 12011, 6378, 5646, 4885, 4560, 3596, 3077, 2181, 1462, 1100, 1060, 661, 311, 102, 29, 20, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4053, 5290, 9896, 13436, 9222, 13166, 12011, 8174, 4155, 5073, 4178, 3580, 4457, 4929, 3456, 2371, 937, 414, 261, 120, 41, 16, 10, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 3222, 3527, 6600, 7038, 6430, 7753, 6378, 4155, 2814, 2807, 2093, 2030, 1720, 1820, 1561, 1164, 645, 408, 170, 95, 24, 9, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 2477, 3908, 7223, 7748, 6110, 7446, 5646, 5073, 2807, 2810, 2699, 3003, 3185, 3197, 2268, 1655, 791, 563, 253, 120, 17, 9, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 1913, 3650, 7132, 7798, 5516, 5736, 4885, 4178, 2093, 2699, 2560, 2680, 3181, 3165, 2138, 1436, 752, 694, 388, 133, 24, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 2247, 3560, 6546, 5616, 4742, 3633, 4560, 3580, 2030, 3003, 2680, 2588, 3416, 3212, 1857, 1191, 627, 667, 423, 139, 17, 4, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 2455, 3126, 7900, 5012, 3776, 2832, 3596, 4457, 1720, 3185, 3181, 3416, 4646, 4669, 2874, 1870, 711, 569, 322, 90, 12, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 1735, 2639, 6817, 4191, 2985, 2651, 3077, 4929, 1820, 3197, 3165, 3212, 4669, 4718, 3091, 2025, 688, 400, 166, 65, 8, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 1434, 2000, 4128, 2414, 2157, 2230, 2181, 3456, 1561, 2268, 2138, 1857, 2874, 3091, 1898, 1165, 489, 235, 122, 46, 10, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};

	static int[][] Lsec=
	{{0, 0, 6847, 7660, 4600, 4960, 4688, 4628, 4266, 3413, 2733, 1532, 1422, 1127, 934, 978, 725, 438, 268, 155, 82, 21, 8, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 6847, 21724, 18653, 21539, 22161, 18266, 16849, 15064, 10517, 9864, 6635, 5918, 4306, 3100, 2622, 1855, 1201, 574, 254, 101, 25, 7, 0, 1, 2, 3, 2, 1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 7660, 18653, 36614, 33895, 26574, 23894, 20691, 18733, 14351, 12357, 10377, 9356, 5773, 2871, 1482, 864, 562, 325, 180, 74, 21, 5, 0, 0, 8, 5, 6, 3, 1, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4600, 21539, 33895, 34464, 35794, 32161, 27615, 22199, 15236, 14260, 12728, 10701, 6933, 4379, 2749, 1690, 861, 450, 270, 170, 47, 12, 0, 2, 11, 1, 6, 0, 2, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4960, 22161, 26574, 35794, 42490, 38403, 31453, 28340, 20514, 17066, 14359, 12270, 7134, 4113, 2955, 2234, 1702, 1209, 748, 343, 89, 29, 0, 2, 12, 9, 9, 2, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4688, 18266, 23894, 32161, 38403, 34468, 30235, 26590, 18101, 14555, 14639, 12594, 7566, 4982, 4034, 2786, 1988, 1122, 573, 265, 78, 22, 0, 3, 18, 12, 9, 5, 2, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4628, 16849, 20691, 27615, 31453, 30235, 27294, 25409, 17567, 16213, 15275, 11858, 7450, 4782, 3667, 2738, 1901, 1113, 623, 316, 102, 33, 0, 2, 18, 4, 6, 3, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 4266, 15064, 18733, 22199, 28340, 26590, 25409, 22292, 17091, 15090, 13556, 11372, 7066, 4766, 3514, 2609, 1888, 1046, 584, 270, 66, 21, 0, 3, 6, 3, 4, 4, 4, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 3413, 10517, 14351, 15236, 20514, 18101, 17567, 17091, 11932, 10445, 9651, 8408, 5275, 3222, 2566, 1922, 1502, 943, 519, 214, 57, 13, 0, 2, 11, 5, 1, 3, 2, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 2733, 9864, 12357, 14260, 17066, 14555, 16213, 15090, 10445, 9500, 9017, 7903, 5157, 2918, 2033, 1542, 1387, 947, 521, 233, 50, 17, 0, 1, 8, 1, 2, 2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 1532, 6635, 10377, 12728, 14359, 14639, 15275, 13556, 9651, 9017, 7546, 6241, 4703, 2902, 1978, 1358, 1029, 668, 367, 141, 51, 4, 0, 1, 5, 1, 0, 1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 1422, 5918, 9356, 10701, 12270, 12594, 11858, 11372, 8408, 7903, 6241, 5300, 4062, 2687, 1943, 1323, 912, 527, 291, 162, 48, 18, 0, 0, 4, 3, 1, 2, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 1127, 4306, 5773, 6933, 7134, 7566, 7450, 7066, 5275, 5157, 4703, 4062, 2598, 1693, 1325, 1035, 719, 409, 218, 125, 31, 9, 0, 2, 3, 1, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 934, 3100, 2871, 4379, 4113, 4982, 4782, 4766, 3222, 2918, 2902, 2687, 1693, 1126, 826, 724, 547, 307, 157, 43, 20, 7, 0, 1, 7, 0, 2, 1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
		{0, 978, 2622, 1482, 2749, 2955, 4034, 3667, 3514, 2566, 2033, 1978, 1943, 1325, 826, 664, 525, 450, 288, 145, 56, 18, 2, 0, 1, 5, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} };

	static double[][] FFsecondary, Lsecondary;
	static  {
		FFsecondary=normalize(FFsec);
		Lsecondary=normalize(Lsec);
	}

	public static void reduce(double reduction) {
		distroFF[1]*=reduction;
		distroL[1]*=reduction;
	}

	public static void setSecondaryMetricWeight(double d) {
		secondaryMetricWeight=d;
	}

	/*
	 * normalize int[][] by rows so that sum of each row is 1
	 */
	private static double[][] normalize(int[][] arr) {
		double dd[][]=new double[arr.length][arr[0].length];
		double sum;
		for(int i=0;i<arr.length;i++) {
			sum=0;
			for(int j=0;j<arr[0].length;j++) {
				sum+=arr[i][j];
			}
			for(int j=0;j<100;j++) {
				if(sum!=0)
					dd[i][j]=arr[i][j]/sum;
				else dd[i][j]=0;
			}
		}
		return dd;
	}

	private static double[] normalize(double[] dd) {
		double sum=0;
		int i;
		for(i=0;i<dd.length;i++) sum+=dd[i];
		if(sum!=1) 
			for(i=0;i<dd.length;i++) dd[i]=dd[i]/sum;	
		return dd;
	}

	private static double[] normalize(int[] ii) {
		double sum=0;
		int i;
		double dd[]=new double[ii.length];
		for(i=0;i<dd.length;i++) sum+=ii[i];
		if(sum!=1 && sum!=0) 
			for(i=0;i<dd.length;i++) dd[i]=(double)ii[i]/sum;	
		return dd;
	}

	private static int[][] CalculateSecondary(Pair[] candidates, int length, double radius) {
		int[][] secondary=new int[15][100]; //don't go over 15

		int deg, ndeg;
		Node.resetId();
		NetworkModel nm=new NetworkModel();
		for(int i=0;i<length;i++) {
			nm.addNode(new Node(candidates[i].x, candidates[i].y));
		}

		nm.setCommunicationRadius(radius);
		nm.connectivityGraph(0, 0); 

		Iterator it=nm.allNodes.values().iterator();
		Iterator<Node> neighs;
		while(it.hasNext()) {
			Node n=(Node)it.next();
			deg=n.degree();
			if(deg>=15) continue;
			neighs=n.getNeighborIterator();
			while(neighs.hasNext()) {
				ndeg=neighs.next().degree();
				secondary[deg][ndeg]++;
			}


		}

		/*System.out.print("new secondary for " + length + " nodes ");
		for(int i=0;i<length;i++) System.out.print(" " + candidates[i]);
		System.out.print("");

		for(int i=0;i<15;i++) {
			for(int j=0;j<100;j++) {
				System.out.print(secondary[i][j] + " ");
			}
			System.out.println();
		}*/

		return secondary;
	}

	private class Pair{
		double x, y;
		int degree;
		Pair(double xx, double yy) {x=xx;y=yy;degree=0;}
		Pair(double xx, double yy, int d) {x=xx;y=yy;degree=d;}
		double distance(Pair n) {
			double distance=Math.abs(x-n.x)+Math.abs(y-n.y);

			if (distance<2*radius)
				return Math.sqrt(Math.pow(n.x-x,2)+Math.pow(n.y-y,2));
			else return 20000;
		}

		double distance(double xx, double yy) {
			double distance=Math.abs(x-xx)+Math.abs(y-yy);

			if (distance<2*radius)
				return Math.sqrt(Math.pow(xx-x,2)+Math.pow(yy-y,2));
			else return 20000;
		}
		public String toString() {
			return "(" + x + ", " + y + ") <" + degree +"> ";
		}
	}
	private int n;
	private double[] distro;
	private double[][] secondaryD; // secondary distribution
	private double radius;
	double minX, minY, maxX, maxY;
	int[] desire;
	String topoType;

	NPART(int nn, double[] dd, double r) {
		n=nn;
		distro=normalize(dd);
		desire=new int[n];
		radius=r;
		for(int i=0;i<distro.length;i++) {
			desire[i]=(int)(distro[i]*n);
			//System.out.println(desire[i]);
		}
	}

	NPART(int nn, String type, double r) {
		secondaryD=null;
		if(type.equalsIgnoreCase("distroFF")) {distro=distroFF;secondaryD=FFsecondary;}
		else if(type.equalsIgnoreCase("distroL")) {distro=distroL;secondaryD=Lsecondary;}
		else throw new RuntimeException();
		
		n=nn;
		distro=normalize(distro);
		desire=new int[n];
		radius=r;
		for(int i=0;i<distro.length;i++) {
			desire[i]=(int)(distro[i]*n);
			//System.out.println(desire[i]);
		}
		topoType=type;
	}

	NPART(int[] degrees, double r) {
		n=degrees.length;
		//desire=new int[n];
		int[] dd=new int[n];
		radius=r;
		int maxDeg=0;
		int i;
		for(i=0;i<degrees.length;i++) dd[i]=0;

		for(i=0;i<degrees.length;i++) {
			dd[degrees[i]]++;
			if(degrees[i]>maxDeg) maxDeg=degrees[i];
			//System.out.println(desire[i]);
		}

		desire=new int[maxDeg+1];
		for(i=1;i<maxDeg+1;i++) if(dd[i]!=0) desire[i]=dd[i]; else desire[i]=1; 

	}

	public double createNM(NetworkModel nm){
		/*
		System.out.println("Generating NPART topology. Using parameters: ");
		System.out.println("distro type: " + topoType);
		System.out.println("nodes: " + n);
		System.out.println("radius: " + radius);
		System.out.println("retries: " + retries);
		System.out.println("secondary weight: " + secondaryMetricWeight);
		*/
		
		int i;
		Pair[] location=new Pair[n];

		location=distribute(location);
		Node.resetId();
		for(i=0;i<location.length;i++) {
			//Node n;
			nm.addNode(new Node(location[i].x, location[i].y));
			//System.out.println(n);
		}

		nm.setXArea(maxX-minX);
		nm.setYArea(maxY-minY);
		nm.setCommunicationRadius(radius);
		nm.connectivityGraph(0, 0); 

		return badness(location);
	}

	private int[] degreeDistribution(Pair[] nodes, int len) {
		int max=0, sum=0;
		int[] degrees=new int[nodes.length+1];
		for(int i=0;i<=len;i++) degrees[i]=0;

		for(int i=0;i<=len;i++) {
			degrees[nodes[i].degree]++;
			if(max<nodes[i].degree) max=nodes[i].degree;
			sum+=nodes[i].degree;
		}

		//for(int i=0;i<max+1;i++) System.out.println("" + i + "->" + degrees[i]);
		//System.out.println("Mean degree: " + (double)sum/n);
		return degrees;
	}

	private Pair[] copy(Pair[] old, int len) {
		Pair[] neu=new Pair[old.length];
		for(int i=0;i<len;i++) neu[i]=new Pair(old[i].x, old[i].y, old[i].degree);
		return neu;
	}

	//different metric versions
	// this one calculates simple distance, negative values (overboarding some of the cells is punished with double value)
	private double badness(Pair[] proposal) {
		int m=0, t;
		int[] d=degreeDistribution(proposal, proposal.length-1);
		for(int i=0;i<desire.length;i++) {
			t=Math.abs(desire[i]-d[i]);
			//if(t<0) m-=negativePenalty*t;
			//else
			m+=t;
		}
		return m;
	}

	//different metric versions
	// this one calculates simple distance, negative values (overboarding some of the cells is punished with double value)
	private double distanceMetric(Pair[] actual, Pair[] proposal, int len) {
		int m=0, t;
		int[] d=degreeDistribution(proposal, len);
		//System.out.println("desire: " + arrToString(desire));
		//System.out.println("actual: " + arrToString(d));
		for(int i=0;i<desire.length;i++) {
			t=desire[i]-d[i];
			if(t<0) m-=negativePenalty*t;
			else m+=t;
		}
		//System.out.println("m: " + m);
		return m;
	}

	/*
	 * this metric focuses on filling up first the parts that are least populated.
	 * for instance if desired is 2, 22, 12
	 * and variations are #1      1, 22, 11
	 * or                 #2      2, 21, 12
	 * it will pick up the second as it reduces the most critical part first
	 */ 
	private double adaptiveMetric(Pair[] actual, Pair[] proposal, int len) {
		int t, i;
		double m=0;
		int[] newDist=degreeDistribution(proposal, len);
		int[] stand=degreeDistribution(actual, len-1);
		for(i=0;i<desire.length;i++) stand[i]=Math.abs(desire[i]-stand[i]);
		double[] weights=normalize(stand);

		/*System.out.println("metric: " + arrToString(stand));
		System.out.println("desire: " + arrToString(desire));
		System.out.println("tested: " + arrToString(newDist)); */
		for(i=0;i<desire.length;i++) {
			t=desire[i]-newDist[i];
			if(t<0) m-=negativePenalty*t;
			else m+=t*weights[i];
		}
		//System.out.println("m: " + m);
		return m;
	}

	private double secondaryMetric(Pair[] proposal, int length) {
		if(secondaryD==null) {System.out.println(" secondary metric cannot be calculated since secondary distribution is null"); return 0;} // if secondary distribution is unknown, return 0 else calculate it
		double metric=0, diff;
		int[][]secDegrees=CalculateSecondary(proposal, length, radius);
		double[][] currentSecondary=normalize(secDegrees);
		for(int i=0;i<secDegrees.length&&i<15;i++) { // secondary data is known for up to degree of 15, after it, dataset becomes too small to be compared to 
			for(int j=0;j<secDegrees[0].length;j++) {
				diff=secondaryD[i][j]-currentSecondary[i][j];
				if(diff>0) metric+=diff;
				else metric=metric-diff;
			}
		}
		return metric;
	}

	private Pair[] distribute(Pair[] nodes) {
		//if(variableSteps) return distributeVariable(nodes);
		//else 
		// 	VARIABLE DISTRIBUTION IS NOT USED ANYMORE, small performance gain, large topology-quality loss
		return distributeFixed(nodes);
	}


	/*
	 * distribute with fixed number of retries
	 */
	private Pair[] distributeFixed(Pair[] nodes) {
		double x, y, tX, tY;
		Pair p;
		int i, degM, tries,created=0;
		nodes[0]=new Pair(0,0);
		maxX=maxY=minX=minY=0;
		x=y=tX=tY=degM=0;
		Pair[][] backupVersion=new Pair[retries][nodes.length];
		int loc;
		double m, minM, minSecondary;

		while(created<n-1) {
			int newDegree=0;
			//System.out.println("\n created: " + (created+1));
			minM=100000; // preset: minMetric is at maximal value
			minSecondary=100000000;
			loc=-1;
			for(tries=0;tries<retries;tries++) {
				boolean connected=false;
				//System.out.println("tries=" + tries );
				while(!connected) {
					backupVersion[tries]=copy(nodes, created+1);
					newDegree=0;
					tX=CommonClass.mt.nextDouble()*(maxX-minX+2*radius)+minX-radius;
					tY=CommonClass.mt.nextDouble()*(maxY-minY+2*radius)+minY-radius;
					//System.out.println("new proposed coordinates x=" + x + " y=" +y);
					for(i=0;i<=created;i++) {
						p=backupVersion[tries][i];
						double dist=p.distance(tX,tY);
						//System.out.println("distance; " + dist + " Radius; " + radius);
						//Set minimal distance here?
						if(dist<=radius) {
								connected=true; newDegree++;
								p.degree++;
								//System.out.println("accepted!");
								//System.out.println("distance; " + dist + " Radius; " + radius);
							}
								
					}
				}
				backupVersion[tries][created+1]=new Pair(tX, tY, newDegree);
				//System.out.println(arrToString(backupVersion[tries], created+1));
				if(useAdaptive)
					m=adaptiveMetric(nodes, backupVersion[tries], created+1);
				else
					m=distanceMetric(nodes, backupVersion[tries], created+1);
				
				if(secondaryMetricWeight!=0) {
					m+=(secondaryMetricWeight*secondaryMetric(backupVersion[tries], created+2));
				}

				if(m<minM) {
					minM=m; loc=tries;x=tX; y=tY;degM=newDegree;
				}
			}
			if(x>maxX) maxX=x;
			if(y>maxY) maxY=y;
			if(x<minX) minX=x;
			if(y<minY) minY=y;
			nodes=backupVersion[loc];
			//System.out.println("selected: " +loc);
			nodes[++created]=new Pair(x,y,degM);
		}

		for(i=0;i<nodes.length;i++) {
			nodes[i].x-=minX;
			nodes[i].y-=minY;
		}

		//System.out.println("desire: " + arrToString(desire));
		//System.out.println("actual: " + arrToString(degreeDistribution(nodes, n-1)));
		return nodes;
	}

	/*
	 * TEMP VERSION, TO TEST BEHAVIOR OF BADNESS METRIC ONLY
	 */
	private Pair[] distributeFixedBadness(Pair[] nodes) {
		double x, y, tX, tY;
		Pair p;
		int i, degM, tries,created=0;
		nodes[0]=new Pair(0,0);
		maxX=maxY=minX=minY=0;
		x=y=tX=tY=degM=0;
		Pair[][] backupVersion=new Pair[retries][nodes.length];
		int loc;
		double m, minM;

		while(created<n-1) {
			int newDegree=0;
			//System.out.println("\n created: " + (created+1));
			minM=100000; // preset: minMetric is at maximal value
			loc=-1;
			for(tries=0;tries<retries;tries++) {
				boolean connected=false;
				//System.out.println("tries=" + tries );
				while(!connected) {
					backupVersion[tries]=copy(nodes, created+1);
					newDegree=0;
					tX=CommonClass.mt.nextDouble()*(maxX-minX+2*radius)+minX-radius;
					tY=CommonClass.mt.nextDouble()*(maxY-minY+2*radius)+minY-radius;
					//System.out.println("new proposed coordinates x=" + x + " y=" +y);
					for(i=0;i<=created;i++) {
						p=backupVersion[tries][i];
						double dist=p.distance(tX,tY);
						//System.out.println("distance; " + dist);
						if(dist<=radius) {
							connected=true; newDegree++;
							p.degree++;
							//System.out.println("accepted!");
						}
					}
				}
				backupVersion[tries][created+1]=new Pair(tX, tY, newDegree);
				//System.out.println(arrToString(backupVersion[tries], created+1));
				m=distanceMetric(nodes, backupVersion[tries], created+1);

				if(m<minM) {
					minM=m; loc=tries;x=tX; y=tY;degM=newDegree;
				}
			}
			if(x>maxX) maxX=x;
			if(y>maxY) maxY=y;
			if(x<minX) minX=x;
			if(y<minY) minY=y;
			nodes=backupVersion[loc];
			//System.out.println("selected: " +loc);
			nodes[++created]=new Pair(x,y,degM);
		}

		for(i=0;i<nodes.length;i++) {
			nodes[i].x-=minX;
			nodes[i].y-=minY;
		}

		return nodes;
	}


	private String arrToString(int[] a) {
		String s=new String();
		for(int i=0;i<a.length; i++) s+=" " + a[i];
		return s;
	}
	private String arrToString(Pair[] a, int len) {
		String s=new String();
		for(int i=0;i<=len; i++) s+=" " + a[i];
		return s;
	}
}
