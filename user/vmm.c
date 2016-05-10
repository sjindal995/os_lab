#include <inc/lib.h>

static void
pgfault_vm(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	// if(!(err & FEC_WR)){
	// 	panic("error pgfault: faulting access not a write: %d\n",err);
	// }
	// uint32_t page_num = PGNUM((uint32_t)addr);
	// if(!(uvpt[page_num] & PTE_COW)){
	// 	panic("error pgfault: faulting access on a non copy-on-write page\n");
	// }

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
	}

	// memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);

	// if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
	// 	panic("error pgfault: mapping new page to old page: %e\n", r);
	// }
}



void
umain(int argc, char **argv)
{
	// int addr;
	// uint32_t env_id = thisenv->env_id;
	// for(addr = 0; addr < 0x00400000; addr += PGSIZE){
	// 	sys_page_alloc(env_id, (void*)addr, PTE_W | PTE_P | PTE_U);
	// }
	// set_pgfault_handler(pgfault);
	sys_env_set_pgfault_upcall(thisenv->env_id, pgfault_vm);
	sys_guest();
}

