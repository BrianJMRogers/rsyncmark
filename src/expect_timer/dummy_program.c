#include <stdlib.h>
#include <stdio.h>
#include <string.h>
int main(int argc, const char *argv[])
{
    char str[10];
    
    fprintf(stdout, "please enter your password: \n");
    scanf("%s", str);

    fprintf(stdout, "your password: %s\n",str);
    return 0;
}
