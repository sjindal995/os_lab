// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{"backtrace", "Display stack ebp, eip and arguements", mon_backtrace} ,
	{"continue", "Continue until next breakpoint", mon_continue},
	{"singlestep", "execute until next step", mon_single_step},
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int mon_continue(int argc, char **argv, struct Trapframe *tf){
	if(!tf){
		cprintf("Null Trapframe!\n");
		return 0;
	}
	if(tf->tf_trapno != T_BRKPT && tf->tf_trapno != T_DEBUG){
		cprintf("invalid trap number: %d\nShould be breakpoint or debug.\n", tf->tf_trapno);
		return 0;
	}
	tf->tf_eflags &= ~FL_TF;
	return -1;
}

int mon_single_step(int argc, char **argv, struct Trapframe *tf){
	if(!tf){
		cprintf("Null Trapframe!\n");
		return 0;
	}
	if(tf->tf_trapno != T_BRKPT && tf->tf_trapno != T_DEBUG){
		cprintf("invalid trap number: %d\nShould be breakpoint or debug.\n", tf->tf_trapno);
		return 0;
	}
	tf->tf_eflags |= FL_TF;
	return -1;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

uint32_t dummy(){
	uint32_t* ebp = (uint32_t *)read_ebp();
	uint32_t eip = *(ebp+1);
	int i=0;
	while(i<10){
		i++;
	}
	return (eip);
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();

	uint32_t eip = dummy();
	cprintf("  current eip=%08x\n",eip);

	struct Eipdebuginfo eip_info;
	int eip_ret_info = debuginfo_eip(eip,&eip_info);
	if(eip_ret_info == 0){
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
			int i=0;
			while(i<eip_info.eip_fn_namelen){
				cprintf("%c",eip_info.eip_fn_name[i]);
				i++;
			}
			cprintf("+%d\n", eip-eip_info.eip_fn_addr);
		}
	while(ebp != 0){
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", (ebp), *(ebp+1), *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6));
		eip = *(ebp+1);
		eip_ret_info = debuginfo_eip(eip,&eip_info);
		if(eip_ret_info == 0){
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
			int i=0;
			while(i<eip_info.eip_fn_namelen){
				cprintf("%c",eip_info.eip_fn_name[i]);
				i++;
			}
			cprintf("+%d\n", eip-eip_info.eip_fn_addr);
		}
		ebp = (uint32_t*)(*ebp);
	}
	// Your code here.
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
