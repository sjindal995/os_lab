#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	char* buf;
	while(1){
		buf = readline(" ");
		if(buf == NULL)
			break;
		if(fork()==0){
			sys_exec(buf);
		}
	}
}

