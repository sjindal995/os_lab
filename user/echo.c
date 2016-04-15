#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	if(argc < 1){
		cprintf("not enough arguments.\n");
		return;
	}
	// // char str[10][1024];
	int i;
	for(i = 0; i<argc-1;i++){
		cprintf("%s ",argv[i]);
		// strcat(argv[0],(const char*)argv[i+1]);
	}
	cprintf("%s\n",argv[i]);
}
