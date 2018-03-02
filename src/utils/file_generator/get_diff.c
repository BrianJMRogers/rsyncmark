/*
 * this file takes in two numbers and returns a diff.
 * this file is knowingly not super robust
 * examples: x and y will return |x-y|/2
 * 					 1 and 2 will return 0.5
 * 					 2 and 4 will return 1
 * 					 8 and 4 will return 2
 */
// includes
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int main(int argc, const char *argv[])
{
	// variables
	double x = -1;
	double y = -1;
	double result = -1;

	// argument check
	if (argc != 3)
	{
		fprintf(stderr, "[!] get_diff: need exactly two numbers as arguments\n");
		fflush(stderr);
		exit(0);
	}

	x = atof(argv[1]);
	y = atof(argv[2]);

	result = fabs((x-y)/2);

	fprintf(stdout, "diff from [%f] and [%f]: %f\n", x, y, result);

	return 0;
}
