/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv,s, len, 0);
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env* e;
	int r;
	if((r = env_alloc(&e,curenv->env_id)) < 0) return r;
	e->env_status = ENV_NOT_RUNNABLE;
	e->env_tf = curenv->env_tf;
	e->env_tf.tf_regs.reg_eax = 0;
	return e->env_id;
	// panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
	else return -E_INVAL;
	return 0;
	// panic("sys_env_set_status not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	e->env_pgfault_upcall = func;
	return 0;
	// panic("sys_env_set_pgfault_upcall not implemented");
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
	if(perm & !PTE_SYSCALL) return -E_INVAL;
	
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	struct PageInfo *p;
	if(!(p = page_alloc(ALLOC_ZERO))) return -E_NO_MEM;
	if((r = page_insert(e->env_pgdir, p, va, perm)) < 0){
		page_free(p);
		return r;
	}
	return 0;
	// panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *srce;
	struct Env *dste;
	int r;

	if((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE) != srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE) != dstva) return -E_INVAL;
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
	if(perm & !PTE_SYSCALL) return -E_INVAL;

	if((r = envid2env(srcenvid, &srce, 1)) < 0) return r;
	if((r = envid2env(dstenvid, &dste, 1)) < 0) return r;
	struct PageInfo *srcp;
	struct PageInfo *dstp;
	pte_t *ptable_entry;
	if(!(srcp = page_lookup(srce->env_pgdir, srcva, &ptable_entry))) return -E_INVAL;
	if(~(*ptable_entry & PTE_W) & (perm & PTE_W)) return -E_INVAL;
	if((r = page_insert(dste->env_pgdir, srcp, dstva, perm)) < 0) return r;
	return 0;
	// panic("sys_page_map not implemented");
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	page_remove(e->env_pgdir, va);
	return 0;
	// panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *rec_env;
	int r;
	uint32_t i_srcva = (uint32_t)srcva;
	if(i_srcva < UTOP && (ROUNDDOWN(srcva,PGSIZE) != srcva)) return -E_INVAL;
	if(i_srcva < UTOP && (!(perm & PTE_U) || !(perm & PTE_P))) return -E_INVAL;
	if(i_srcva < UTOP && (perm & !PTE_SYSCALL)) return -E_INVAL;
	pte_t *pte;
	struct PageInfo *pp;
	if(i_srcva < UTOP && !(pp = page_lookup(curenv->env_pgdir, srcva, &pte))) return -E_INVAL;
	if((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
	
	if((r = envid2env(envid,&rec_env,0)) < 0) return r;
	
	if(!rec_env->env_ipc_recving) return -E_IPC_NOT_RECV;

	if(i_srcva < UTOP && ((uint32_t)rec_env->env_ipc_dstva) < UTOP){
		if((r = page_insert(rec_env->env_pgdir, pp, rec_env->env_ipc_dstva, perm)) < 0) return r;
		rec_env->env_ipc_perm = perm;
	}
	else{
		rec_env->env_ipc_perm = 0;
	}

	rec_env->env_ipc_recving = 0;
	rec_env->env_ipc_from = curenv->env_id;
	rec_env->env_ipc_value = value;
	rec_env->env_status = ENV_RUNNABLE;
	return 0;
	// panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if((uint32_t)dstva < UTOP && ROUNDDOWN((uint32_t)dstva,PGSIZE) != PGSIZE) return -E_INVAL;
	curenv->env_ipc_recving = 1;
	curenv->env_ipc_dstva = dstva;
	curenv->env_status = ENV_NOT_RUNNABLE;

	curenv->env_tf.tf_regs.reg_eax = 0;
	sys_yield();
	// panic("sys_ipc_recv not implemented");
	return 0;
}

static char cmd[1024] = {0};
static char args[10][1024] = {{0}};

void get_cmd(char* buf){
	int i;
	for(i=0;i <1024;i++){
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
		int j;
		for(j=0;j<1024;j++){
			args[i][j] = '\0';
		}
	}
	char* w_pos = strchr(buf, ' ');
	// cprintf("hddddddddddddhdhh\n");
	char bufcpy[1024] = {0};
	strcpy(bufcpy,buf);
	if(w_pos == NULL){
		for(i=0;i<strlen(buf);i++){
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
		}
		return;
	}
	for(i=0;i<(w_pos-buf);i++){
		// cprintf("heelo2: %s\n", buf[i]);
		cmd[i] = buf[i];
	}
	if(w_pos-buf < strlen(buf)){
		int is_quote = 0;
		int index = 0;
		// int done = 0;
		int curr = 0;
		for(i = 0;i<strlen(buf)-(w_pos-buf)-1;i++){
			// cprintf("args[0]: %s\n", args[0]);
			if(is_quote == 0 && w_pos[i+1] == ' '){
				while(w_pos[i+1] == ' ') i++;
				i--;
				index += 1;
				// done = i+1;
				curr = 0;
			}
			else if(is_quote == 1 && w_pos[i+1] == '\"') {
				is_quote = 0;
			}
			else if(is_quote == 0 && w_pos[i+1] == '\"'){
				is_quote = 1;
			}
			else{
				args[index][curr] = w_pos[1+i];
				curr++;
				// cprintf("index: %d, args[1]: %c, i-done: %s\n", index, w_pos[i+1], args[index]);
			}
		}
		if(strcmp(args[index],"&")==0){
			args[index][0] = '\0';
		}
	}
	// cprintf("buffer: %s, command: %s, arguement: %s\n", buf, cmd, args[0]);
}


void sys_exec(char* buf){
	uint32_t parent_id = curenv->env_parent_id;
	uint32_t cur_id = curenv->env_id;
	// char* bufcpy = "";
	// int code;
	// memcpy(bufcpy, buf, strlen(buf));
	get_cmd(buf);
	env_free(curenv);
	env_alloc(&curenv, parent_id);
	curenv->env_id = cur_id;
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
		int j;
		for(j=0;j<1024;j++){
			argv[i][j] = args[i][j];
		}
	}
	// cprintf("\n\ncommand: %s, args[0]: %s, args[1]: %s\n\n",cmd, args[0], args[1]);
	if(strcmp(cmd, (const char*)("factorial")) == 0){
		extern uint8_t ENV_PASTE3(_binary_obj_, user_factorial , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_factorial , _start));
	}
	else if(strcmp(cmd, (const char*)("fibonacci")) == 0) {
		extern uint8_t ENV_PASTE3(_binary_obj_, user_fibonacci , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_fibonacci , _start));
	}
	else if(strcmp(cmd, (const char*)("help")) == 0) {
		extern uint8_t ENV_PASTE3(_binary_obj_, user_help , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_help , _start));
	}
	else if(strcmp(cmd, (const char*)("date")) == 0) {
		extern uint8_t ENV_PASTE3(_binary_obj_, user_date , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_date , _start));
	}
	else if(strcmp(cmd, (const char*)("echo")) == 0) {
		extern uint8_t ENV_PASTE3(_binary_obj_, user_echo , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_echo , _start));
	}
	else{
		panic("command not supported");
		return;
	}
	// extern uint8_t ENV_PASTE3(_binary_obj_, user_hello , _start)[];
	// load_icode(curenv,ENV_PASTE3(_binary_obj_, user_hello , _start));
	lcr3(PADDR(curenv->env_pgdir));
	int argc = 0;
	uint32_t sp = USTACKTOP;
	uint32_t ustack[13];
	for(argc = 0; strlen(argv[argc]) > 0; argc++) {
	    if(argc >= 10) panic("argc>=10");
	    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
	    memcpy((void *)sp, argv[argc], strlen(argv[argc]) + 1);
	    ustack[2+argc] = sp;
	  }
	  ustack[2+argc] = 0;

	  // ustack[0] = 0xffffffff;  // fake return PC
	  // cprintf("argc ppushed: %d\n", argc);
	  ustack[0] = argc;
	  ustack[1] = sp - (argc+1)*4;  // argv pointer

	  sp -= (2+argc+1) * 4;
	  memcpy((void *)sp, ustack, (2+argc+1)*4);
	  curenv->env_tf.tf_esp = sp;
	lcr3(PADDR(kern_pgdir));
	env_run(curenv);
	// sched_yield();
	// cprintf("\n\nheeeeeeeeeeelo---------------\n\n");
	// env_destroy(e);
}

void sys_wait(){
	curenv->env_status = ENV_WAIT_CHILD;
}

void sys_guest(){
	curenv->env_type = ENV_TYPE_GUEST;
	extern uint8_t ENV_PASTE3(_binary_obj_, guest_boot , _start)[];
	load_icode(curenv,ENV_PASTE3(_binary_obj_, guest_boot , _start));
	curenv->env_tf.tf_eip = 0x7c00;
	curenv->env_tf.tf_esp = 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1,a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void *)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void *)a2,(envid_t)a3,(void *)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_exec:
			sys_exec((char *)a1);
			return 0;
		case SYS_wait:
			sys_wait();
			return 0;
		case SYS_guest:
			sys_guest();
			return 0;
		default:
			return -E_INVAL;
	}
}

