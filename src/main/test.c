#include <stdio.h>
int main(int argc, const char *argv[])
{
    char str[50];
    fprintf(stdout, "Are you sure you want to continue conneting (yes/no)\n");
    scanf("%s", str);

    fprintf(stdout, "please enter your password: \n");
    scanf("%s", str);



    fprintf(stdout, "your string: %s\n",str);
    return 0;
}
