#include <stdlib.h>
#include <stdio.h>
int main(int argc, const char *argv[])
{
	double arg = 0;
	if (argc != 3)
	{
		fprintf(stderr, "[!] float_is_greater: need two arguments to compare\n");
		fflush(stderr);
		exit(0);
	}

	if (atof(argv[1]) >= atof(argv[2]))
	{
		fprintf(stdout, "true\n");
	}
	else {
		fprintf(stdout, "false\n");
	}

	return 0;
}
