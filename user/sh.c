#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	char* buf;
	while(1){
		cprintf("inside parent environment: %08x\n", thisenv->env_id);
		buf = readline("U> ");
		// cprintf("proceeding in env: ", thisenv->env_id);
		if(buf == NULL)
			break;
		if(fork()==0){
			cprintf("inside child environment: %08x\n", thisenv->env_id);
			sys_exec(buf);
			// cprintf("\n\nbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n\n");
		}
		else{
			if(buf[strlen(buf)-1] != '&'){
				sys_wait();
			}
		}
	}
}

