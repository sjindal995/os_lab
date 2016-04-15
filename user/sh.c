#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	char* buf;
	while(1){
		buf = readline("U> ");
		cprintf("proceeding in env: ", thisenv->env_id);
		if(buf == NULL)
			break;
		if(fork()==0){
			sys_exec(buf);
		}
	}
}

