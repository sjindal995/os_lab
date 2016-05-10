
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 50 12 f0       	mov    $0xf0125000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 ad 00 00 00       	call   f01000eb <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f0100046:	8b 45 10             	mov    0x10(%ebp),%eax
f0100049:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010004e:	77 21                	ja     f0100071 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100050:	8b 45 10             	mov    0x10(%ebp),%eax
f0100053:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100057:	c7 44 24 08 c0 9b 10 	movl   $0xf0109bc0,0x8(%esp)
f010005e:	f0 
f010005f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100062:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100066:	8b 45 08             	mov    0x8(%ebp),%eax
f0100069:	89 04 24             	mov    %eax,(%esp)
f010006c:	e8 5e 02 00 00       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100071:	8b 45 10             	mov    0x10(%ebp),%eax
f0100074:	05 00 00 00 10       	add    $0x10000000,%eax
}
f0100079:	c9                   	leave  
f010007a:	c3                   	ret    

f010007b <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f010007b:	55                   	push   %ebp
f010007c:	89 e5                	mov    %esp,%ebp
f010007e:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0100081:	8b 45 10             	mov    0x10(%ebp),%eax
f0100084:	c1 e8 0c             	shr    $0xc,%eax
f0100087:	89 c2                	mov    %eax,%edx
f0100089:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f010008e:	39 c2                	cmp    %eax,%edx
f0100090:	72 21                	jb     f01000b3 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100092:	8b 45 10             	mov    0x10(%ebp),%eax
f0100095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100099:	c7 44 24 08 e4 9b 10 	movl   $0xf0109be4,0x8(%esp)
f01000a0:	f0 
f01000a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ab:	89 04 24             	mov    %eax,(%esp)
f01000ae:	e8 1c 02 00 00       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f01000b3:	8b 45 10             	mov    0x10(%ebp),%eax
f01000b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f01000bb:	c9                   	leave  
f01000bc:	c3                   	ret    

f01000bd <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f01000bd:	55                   	push   %ebp
f01000be:	89 e5                	mov    %esp,%ebp
f01000c0:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01000c3:	8b 55 08             	mov    0x8(%ebp),%edx
f01000c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01000cc:	f0 87 02             	lock xchg %eax,(%edx)
f01000cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f01000d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01000d5:	c9                   	leave  
f01000d6:	c3                   	ret    

f01000d7 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f01000d7:	55                   	push   %ebp
f01000d8:	89 e5                	mov    %esp,%ebp
f01000da:	83 ec 18             	sub    $0x18,%esp
	spin_lock(&kernel_lock);
f01000dd:	c7 04 24 e0 75 12 f0 	movl   $0xf01275e0,(%esp)
f01000e4:	e8 60 96 00 00       	call   f0109749 <spin_lock>
}
f01000e9:	c9                   	leave  
f01000ea:	c3                   	ret    

f01000eb <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000eb:	55                   	push   %ebp
f01000ec:	89 e5                	mov    %esp,%ebp
f01000ee:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000f1:	ba 08 90 2d f0       	mov    $0xf02d9008,%edx
f01000f6:	b8 e6 3e 29 f0       	mov    $0xf0293ee6,%eax
f01000fb:	29 c2                	sub    %eax,%edx
f01000fd:	89 d0                	mov    %edx,%eax
f01000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100103:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010010a:	00 
f010010b:	c7 04 24 e6 3e 29 f0 	movl   $0xf0293ee6,(%esp)
f0100112:	e8 ee 88 00 00       	call   f0108a05 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100117:	e8 53 0a 00 00       	call   f0100b6f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010011c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100123:	00 
f0100124:	c7 04 24 07 9c 10 f0 	movl   $0xf0109c07,(%esp)
f010012b:	e8 1e 4e 00 00       	call   f0104f4e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100130:	e8 21 13 00 00       	call   f0101456 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 f5 42 00 00       	call   f010442f <env_init>
	trap_init();
f010013a:	e8 a1 4e 00 00       	call   f0104fe0 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010013f:	e8 b1 8f 00 00       	call   f01090f5 <mp_init>
	lapic_init();
f0100144:	e8 fb 91 00 00       	call   f0109344 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100149:	e8 be 4b 00 00       	call   f0104d0c <pic_init>

	// Acquire the big kernel lock before waking up APs
	// Your code here:
	lock_kernel();
f010014e:	e8 84 ff ff ff       	call   f01000d7 <lock_kernel>
	// Starting non-boot CPUs
	boot_aps();
f0100153:	e8 19 00 00 00       	call   f0100171 <boot_aps>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100158:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010015f:	00 
f0100160:	c7 04 24 5e 5f 27 f0 	movl   $0xf0275f5e,(%esp)
f0100167:	e8 95 47 00 00       	call   f0104901 <env_create>
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010016c:	e8 7a 67 00 00       	call   f01068eb <sched_yield>

f0100171 <boot_aps>:
void *mpentry_kstack;

// Start the non-boot (AP) processors.
static void
boot_aps(void)
{
f0100171:	55                   	push   %ebp
f0100172:	89 e5                	mov    %esp,%ebp
f0100174:	83 ec 28             	sub    $0x28,%esp
	extern unsigned char mpentry_start[], mpentry_end[];
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
f0100177:	c7 44 24 08 00 70 00 	movl   $0x7000,0x8(%esp)
f010017e:	00 
f010017f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0100186:	00 
f0100187:	c7 04 24 22 9c 10 f0 	movl   $0xf0109c22,(%esp)
f010018e:	e8 e8 fe ff ff       	call   f010007b <_kaddr>
f0100193:	89 45 f0             	mov    %eax,-0x10(%ebp)
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100196:	ba d2 8d 10 f0       	mov    $0xf0108dd2,%edx
f010019b:	b8 58 8d 10 f0       	mov    $0xf0108d58,%eax
f01001a0:	29 c2                	sub    %eax,%edx
f01001a2:	89 d0                	mov    %edx,%eax
f01001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001a8:	c7 44 24 04 58 8d 10 	movl   $0xf0108d58,0x4(%esp)
f01001af:	f0 
f01001b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01001b3:	89 04 24             	mov    %eax,(%esp)
f01001b6:	e8 b8 88 00 00       	call   f0108a73 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001bb:	c7 45 f4 20 80 29 f0 	movl   $0xf0298020,-0xc(%ebp)
f01001c2:	eb 79                	jmp    f010023d <boot_aps+0xcc>
		if (c == cpus + cpunum())  // We've started already.
f01001c4:	e8 05 93 00 00       	call   f01094ce <cpunum>
f01001c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01001cc:	05 20 80 29 f0       	add    $0xf0298020,%eax
f01001d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01001d4:	75 02                	jne    f01001d8 <boot_aps+0x67>
			continue;
f01001d6:	eb 61                	jmp    f0100239 <boot_aps+0xc8>

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01001db:	b8 20 80 29 f0       	mov    $0xf0298020,%eax
f01001e0:	29 c2                	sub    %eax,%edx
f01001e2:	89 d0                	mov    %edx,%eax
f01001e4:	c1 f8 02             	sar    $0x2,%eax
f01001e7:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001ed:	83 c0 01             	add    $0x1,%eax
f01001f0:	c1 e0 0f             	shl    $0xf,%eax
f01001f3:	05 00 90 29 f0       	add    $0xf0299000,%eax
f01001f8:	a3 e4 7a 29 f0       	mov    %eax,0xf0297ae4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100200:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100204:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f010020b:	00 
f010020c:	c7 04 24 22 9c 10 f0 	movl   $0xf0109c22,(%esp)
f0100213:	e8 28 fe ff ff       	call   f0100040 <_paddr>
f0100218:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010021b:	0f b6 12             	movzbl (%edx),%edx
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	89 14 24             	mov    %edx,(%esp)
f0100228:	e8 ed 92 00 00       	call   f010951a <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010022d:	90                   	nop
f010022e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100231:	8b 40 04             	mov    0x4(%eax),%eax
f0100234:	83 f8 01             	cmp    $0x1,%eax
f0100237:	75 f5                	jne    f010022e <boot_aps+0xbd>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100239:	83 45 f4 74          	addl   $0x74,-0xc(%ebp)
f010023d:	a1 c4 83 29 f0       	mov    0xf02983c4,%eax
f0100242:	6b c0 74             	imul   $0x74,%eax,%eax
f0100245:	05 20 80 29 f0       	add    $0xf0298020,%eax
f010024a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010024d:	0f 87 71 ff ff ff    	ja     f01001c4 <boot_aps+0x53>
		lapic_startap(c->cpu_id, PADDR(code));
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
			;
	}
}
f0100253:	c9                   	leave  
f0100254:	c3                   	ret    

f0100255 <mp_main>:

// Setup code for APs
void
mp_main(void)
{
f0100255:	55                   	push   %ebp
f0100256:	89 e5                	mov    %esp,%ebp
f0100258:	83 ec 28             	sub    $0x28,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f010025b:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0100260:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100264:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f010026b:	00 
f010026c:	c7 04 24 22 9c 10 f0 	movl   $0xf0109c22,(%esp)
f0100273:	e8 c8 fd ff ff       	call   f0100040 <_paddr>
f0100278:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010027b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010027e:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100281:	e8 48 92 00 00       	call   f01094ce <cpunum>
f0100286:	89 44 24 04          	mov    %eax,0x4(%esp)
f010028a:	c7 04 24 2e 9c 10 f0 	movl   $0xf0109c2e,(%esp)
f0100291:	e8 b8 4c 00 00       	call   f0104f4e <cprintf>

	lapic_init();
f0100296:	e8 a9 90 00 00       	call   f0109344 <lapic_init>
	env_init_percpu();
f010029b:	e8 08 42 00 00       	call   f01044a8 <env_init_percpu>
	trap_init_percpu();
f01002a0:	e8 30 59 00 00       	call   f0105bd5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002a5:	e8 24 92 00 00       	call   f01094ce <cpunum>
f01002aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01002ad:	05 20 80 29 f0       	add    $0xf0298020,%eax
f01002b2:	83 c0 04             	add    $0x4,%eax
f01002b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01002bc:	00 
f01002bd:	89 04 24             	mov    %eax,(%esp)
f01002c0:	e8 f8 fd ff ff       	call   f01000bd <xchg>
	// Now that we have finished some basic setup, call sched_yield()
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
f01002c5:	e8 0d fe ff ff       	call   f01000d7 <lock_kernel>
	sched_yield();
f01002ca:	e8 1c 66 00 00       	call   f01068eb <sched_yield>

f01002cf <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01002cf:	55                   	push   %ebp
f01002d0:	89 e5                	mov    %esp,%ebp
f01002d2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	if (panicstr)
f01002d5:	a1 e0 7a 29 f0       	mov    0xf0297ae0,%eax
f01002da:	85 c0                	test   %eax,%eax
f01002dc:	74 02                	je     f01002e0 <_panic+0x11>
		goto dead;
f01002de:	eb 51                	jmp    f0100331 <_panic+0x62>
	panicstr = fmt;
f01002e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01002e3:	a3 e0 7a 29 f0       	mov    %eax,0xf0297ae0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01002e8:	fa                   	cli    
f01002e9:	fc                   	cld    

	va_start(ap, fmt);
f01002ea:	8d 45 14             	lea    0x14(%ebp),%eax
f01002ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01002f0:	e8 d9 91 00 00       	call   f01094ce <cpunum>
f01002f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01002f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01002fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01002ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100303:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100307:	c7 04 24 44 9c 10 f0 	movl   $0xf0109c44,(%esp)
f010030e:	e8 3b 4c 00 00       	call   f0104f4e <cprintf>
	vcprintf(fmt, ap);
f0100313:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100316:	89 44 24 04          	mov    %eax,0x4(%esp)
f010031a:	8b 45 10             	mov    0x10(%ebp),%eax
f010031d:	89 04 24             	mov    %eax,(%esp)
f0100320:	e8 f6 4b 00 00       	call   f0104f1b <vcprintf>
	cprintf("\n");
f0100325:	c7 04 24 66 9c 10 f0 	movl   $0xf0109c66,(%esp)
f010032c:	e8 1d 4c 00 00       	call   f0104f4e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100331:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100338:	e8 0f 0e 00 00       	call   f010114c <monitor>
f010033d:	eb f2                	jmp    f0100331 <_panic+0x62>

f010033f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010033f:	55                   	push   %ebp
f0100340:	89 e5                	mov    %esp,%ebp
f0100342:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f0100345:	8d 45 14             	lea    0x14(%ebp),%eax
f0100348:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f010034b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010034e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100352:	8b 45 08             	mov    0x8(%ebp),%eax
f0100355:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100359:	c7 04 24 68 9c 10 f0 	movl   $0xf0109c68,(%esp)
f0100360:	e8 e9 4b 00 00       	call   f0104f4e <cprintf>
	vcprintf(fmt, ap);
f0100365:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100368:	89 44 24 04          	mov    %eax,0x4(%esp)
f010036c:	8b 45 10             	mov    0x10(%ebp),%eax
f010036f:	89 04 24             	mov    %eax,(%esp)
f0100372:	e8 a4 4b 00 00       	call   f0104f1b <vcprintf>
	cprintf("\n");
f0100377:	c7 04 24 66 9c 10 f0 	movl   $0xf0109c66,(%esp)
f010037e:	e8 cb 4b 00 00       	call   f0104f4e <cprintf>
	va_end(ap);
}
f0100383:	c9                   	leave  
f0100384:	c3                   	ret    

f0100385 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100385:	55                   	push   %ebp
f0100386:	89 e5                	mov    %esp,%ebp
f0100388:	83 ec 20             	sub    $0x20,%esp
f010038b:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100392:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100395:	89 c2                	mov    %eax,%edx
f0100397:	ec                   	in     (%dx),%al
f0100398:	88 45 fb             	mov    %al,-0x5(%ebp)
f010039b:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%ebp)
f01003a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01003a5:	89 c2                	mov    %eax,%edx
f01003a7:	ec                   	in     (%dx),%al
f01003a8:	88 45 f3             	mov    %al,-0xd(%ebp)
f01003ab:	c7 45 ec 84 00 00 00 	movl   $0x84,-0x14(%ebp)
f01003b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01003b5:	89 c2                	mov    %eax,%edx
f01003b7:	ec                   	in     (%dx),%al
f01003b8:	88 45 eb             	mov    %al,-0x15(%ebp)
f01003bb:	c7 45 e4 84 00 00 00 	movl   $0x84,-0x1c(%ebp)
f01003c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01003c5:	89 c2                	mov    %eax,%edx
f01003c7:	ec                   	in     (%dx),%al
f01003c8:	88 45 e3             	mov    %al,-0x1d(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01003cb:	c9                   	leave  
f01003cc:	c3                   	ret    

f01003cd <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01003cd:	55                   	push   %ebp
f01003ce:	89 e5                	mov    %esp,%ebp
f01003d0:	83 ec 10             	sub    $0x10,%esp
f01003d3:	c7 45 fc fd 03 00 00 	movl   $0x3fd,-0x4(%ebp)
f01003da:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003dd:	89 c2                	mov    %eax,%edx
f01003df:	ec                   	in     (%dx),%al
f01003e0:	88 45 fb             	mov    %al,-0x5(%ebp)
	return data;
f01003e3:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01003e7:	0f b6 c0             	movzbl %al,%eax
f01003ea:	83 e0 01             	and    $0x1,%eax
f01003ed:	85 c0                	test   %eax,%eax
f01003ef:	75 07                	jne    f01003f8 <serial_proc_data+0x2b>
		return -1;
f01003f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003f6:	eb 17                	jmp    f010040f <serial_proc_data+0x42>
f01003f8:	c7 45 f4 f8 03 00 00 	movl   $0x3f8,-0xc(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100402:	89 c2                	mov    %eax,%edx
f0100404:	ec                   	in     (%dx),%al
f0100405:	88 45 f3             	mov    %al,-0xd(%ebp)
	return data;
f0100408:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
	return inb(COM1+COM_RX);
f010040c:	0f b6 c0             	movzbl %al,%eax
}
f010040f:	c9                   	leave  
f0100410:	c3                   	ret    

f0100411 <serial_intr>:

void
serial_intr(void)
{
f0100411:	55                   	push   %ebp
f0100412:	89 e5                	mov    %esp,%ebp
f0100414:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100417:	0f b6 05 00 40 29 f0 	movzbl 0xf0294000,%eax
f010041e:	84 c0                	test   %al,%al
f0100420:	74 0c                	je     f010042e <serial_intr+0x1d>
		cons_intr(serial_proc_data);
f0100422:	c7 04 24 cd 03 10 f0 	movl   $0xf01003cd,(%esp)
f0100429:	e8 3e 06 00 00       	call   f0100a6c <cons_intr>
}
f010042e:	c9                   	leave  
f010042f:	c3                   	ret    

f0100430 <serial_putc>:

static void
serial_putc(int c)
{
f0100430:	55                   	push   %ebp
f0100431:	89 e5                	mov    %esp,%ebp
f0100433:	83 ec 20             	sub    $0x20,%esp
	int i;

	for (i = 0;
f0100436:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010043d:	eb 09                	jmp    f0100448 <serial_putc+0x18>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010043f:	e8 41 ff ff ff       	call   f0100385 <delay>
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100444:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0100448:	c7 45 f8 fd 03 00 00 	movl   $0x3fd,-0x8(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010044f:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0100452:	89 c2                	mov    %eax,%edx
f0100454:	ec                   	in     (%dx),%al
f0100455:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f0100458:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010045c:	0f b6 c0             	movzbl %al,%eax
f010045f:	83 e0 20             	and    $0x20,%eax
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100462:	85 c0                	test   %eax,%eax
f0100464:	75 09                	jne    f010046f <serial_putc+0x3f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100466:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
f010046d:	7e d0                	jle    f010043f <serial_putc+0xf>
	     i++)
		delay();

	//printf to shell using serial interface. code to follow
	outb(COM1+COM_TX, c);
f010046f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100472:	0f b6 c0             	movzbl %al,%eax
f0100475:	c7 45 f0 f8 03 00 00 	movl   $0x3f8,-0x10(%ebp)
f010047c:	88 45 ef             	mov    %al,-0x11(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0100483:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100486:	ee                   	out    %al,(%dx)
}
f0100487:	c9                   	leave  
f0100488:	c3                   	ret    

f0100489 <serial_init>:

static void
serial_init(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 50             	sub    $0x50,%esp
f010048f:	c7 45 fc fa 03 00 00 	movl   $0x3fa,-0x4(%ebp)
f0100496:	c6 45 fb 00          	movb   $0x0,-0x5(%ebp)
f010049a:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f010049e:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01004a1:	ee                   	out    %al,(%dx)
f01004a2:	c7 45 f4 fb 03 00 00 	movl   $0x3fb,-0xc(%ebp)
f01004a9:	c6 45 f3 80          	movb   $0x80,-0xd(%ebp)
f01004ad:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01004b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01004b4:	ee                   	out    %al,(%dx)
f01004b5:	c7 45 ec f8 03 00 00 	movl   $0x3f8,-0x14(%ebp)
f01004bc:	c6 45 eb 0c          	movb   $0xc,-0x15(%ebp)
f01004c0:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f01004c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01004c7:	ee                   	out    %al,(%dx)
f01004c8:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
f01004cf:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f01004d3:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01004d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01004da:	ee                   	out    %al,(%dx)
f01004db:	c7 45 dc fb 03 00 00 	movl   $0x3fb,-0x24(%ebp)
f01004e2:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
f01004e6:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f01004ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01004ed:	ee                   	out    %al,(%dx)
f01004ee:	c7 45 d4 fc 03 00 00 	movl   $0x3fc,-0x2c(%ebp)
f01004f5:	c6 45 d3 00          	movb   $0x0,-0x2d(%ebp)
f01004f9:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f01004fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100500:	ee                   	out    %al,(%dx)
f0100501:	c7 45 cc f9 03 00 00 	movl   $0x3f9,-0x34(%ebp)
f0100508:	c6 45 cb 01          	movb   $0x1,-0x35(%ebp)
f010050c:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
f0100510:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100513:	ee                   	out    %al,(%dx)
f0100514:	c7 45 c4 fd 03 00 00 	movl   $0x3fd,-0x3c(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010051b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010051e:	89 c2                	mov    %eax,%edx
f0100520:	ec                   	in     (%dx),%al
f0100521:	88 45 c3             	mov    %al,-0x3d(%ebp)
	return data;
f0100524:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100528:	3c ff                	cmp    $0xff,%al
f010052a:	0f 95 c0             	setne  %al
f010052d:	a2 00 40 29 f0       	mov    %al,0xf0294000
f0100532:	c7 45 bc fa 03 00 00 	movl   $0x3fa,-0x44(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100539:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010053c:	89 c2                	mov    %eax,%edx
f010053e:	ec                   	in     (%dx),%al
f010053f:	88 45 bb             	mov    %al,-0x45(%ebp)
f0100542:	c7 45 b4 f8 03 00 00 	movl   $0x3f8,-0x4c(%ebp)
f0100549:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f010054c:	89 c2                	mov    %eax,%edx
f010054e:	ec                   	in     (%dx),%al
f010054f:	88 45 b3             	mov    %al,-0x4d(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f0100552:	c9                   	leave  
f0100553:	c3                   	ret    

f0100554 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f0100554:	55                   	push   %ebp
f0100555:	89 e5                	mov    %esp,%ebp
f0100557:	83 ec 30             	sub    $0x30,%esp
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010055a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0100561:	eb 09                	jmp    f010056c <lpt_putc+0x18>
		delay();
f0100563:	e8 1d fe ff ff       	call   f0100385 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100568:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f010056c:	c7 45 f8 79 03 00 00 	movl   $0x379,-0x8(%ebp)
f0100573:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0100576:	89 c2                	mov    %eax,%edx
f0100578:	ec                   	in     (%dx),%al
f0100579:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f010057c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
f0100580:	84 c0                	test   %al,%al
f0100582:	78 09                	js     f010058d <lpt_putc+0x39>
f0100584:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
f010058b:	7e d6                	jle    f0100563 <lpt_putc+0xf>
		delay();
	outb(0x378+0, c);
f010058d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100590:	0f b6 c0             	movzbl %al,%eax
f0100593:	c7 45 f0 78 03 00 00 	movl   $0x378,-0x10(%ebp)
f010059a:	88 45 ef             	mov    %al,-0x11(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f01005a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	c7 45 e8 7a 03 00 00 	movl   $0x37a,-0x18(%ebp)
f01005ac:	c6 45 e7 0d          	movb   $0xd,-0x19(%ebp)
f01005b0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01005b4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	c7 45 e0 7a 03 00 00 	movl   $0x37a,-0x20(%ebp)
f01005bf:	c6 45 df 08          	movb   $0x8,-0x21(%ebp)
f01005c3:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f01005c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01005ca:	ee                   	out    %al,(%dx)
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f01005cb:	c9                   	leave  
f01005cc:	c3                   	ret    

f01005cd <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f01005cd:	55                   	push   %ebp
f01005ce:	89 e5                	mov    %esp,%ebp
f01005d0:	83 ec 30             	sub    $0x30,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005d3:	c7 45 fc 00 80 0b f0 	movl   $0xf00b8000,-0x4(%ebp)
	was = *cp;
f01005da:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01005dd:	0f b7 00             	movzwl (%eax),%eax
f01005e0:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
	*cp = (uint16_t) 0xA55A;
f01005e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01005e7:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01005ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01005ef:	0f b7 00             	movzwl (%eax),%eax
f01005f2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005f6:	74 13                	je     f010060b <cga_init+0x3e>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005f8:	c7 45 fc 00 00 0b f0 	movl   $0xf00b0000,-0x4(%ebp)
		addr_6845 = MONO_BASE;
f01005ff:	c7 05 04 40 29 f0 b4 	movl   $0x3b4,0xf0294004
f0100606:	03 00 00 
f0100609:	eb 14                	jmp    f010061f <cga_init+0x52>
	} else {
		*cp = was;
f010060b:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010060e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
f0100612:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
f0100615:	c7 05 04 40 29 f0 d4 	movl   $0x3d4,0xf0294004
f010061c:	03 00 00 
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010061f:	a1 04 40 29 f0       	mov    0xf0294004,%eax
f0100624:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100627:	c6 45 ef 0e          	movb   $0xe,-0x11(%ebp)
f010062b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f010062f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100632:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100633:	a1 04 40 29 f0       	mov    0xf0294004,%eax
f0100638:	83 c0 01             	add    $0x1,%eax
f010063b:	89 45 e8             	mov    %eax,-0x18(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010063e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100641:	89 c2                	mov    %eax,%edx
f0100643:	ec                   	in     (%dx),%al
f0100644:	88 45 e7             	mov    %al,-0x19(%ebp)
	return data;
f0100647:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010064b:	0f b6 c0             	movzbl %al,%eax
f010064e:	c1 e0 08             	shl    $0x8,%eax
f0100651:	89 45 f4             	mov    %eax,-0xc(%ebp)
	outb(addr_6845, 15);
f0100654:	a1 04 40 29 f0       	mov    0xf0294004,%eax
f0100659:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010065c:	c6 45 df 0f          	movb   $0xf,-0x21(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100660:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f0100664:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100667:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
f0100668:	a1 04 40 29 f0       	mov    0xf0294004,%eax
f010066d:	83 c0 01             	add    $0x1,%eax
f0100670:	89 45 d8             	mov    %eax,-0x28(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100673:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100676:	89 c2                	mov    %eax,%edx
f0100678:	ec                   	in     (%dx),%al
f0100679:	88 45 d7             	mov    %al,-0x29(%ebp)
	return data;
f010067c:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
f0100680:	0f b6 c0             	movzbl %al,%eax
f0100683:	09 45 f4             	or     %eax,-0xc(%ebp)

	crt_buf = (uint16_t*) cp;
f0100686:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100689:	a3 08 40 29 f0       	mov    %eax,0xf0294008
	crt_pos = pos;
f010068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100691:	66 a3 0c 40 29 f0    	mov    %ax,0xf029400c
}
f0100697:	c9                   	leave  
f0100698:	c3                   	ret    

f0100699 <cga_putc>:



static void
cga_putc(int c)
{
f0100699:	55                   	push   %ebp
f010069a:	89 e5                	mov    %esp,%ebp
f010069c:	53                   	push   %ebx
f010069d:	83 ec 44             	sub    $0x44,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01006a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a3:	b0 00                	mov    $0x0,%al
f01006a5:	85 c0                	test   %eax,%eax
f01006a7:	75 07                	jne    f01006b0 <cga_putc+0x17>
		c |= 0x0700;
f01006a9:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
f01006b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01006b3:	0f b6 c0             	movzbl %al,%eax
f01006b6:	83 f8 09             	cmp    $0x9,%eax
f01006b9:	0f 84 ac 00 00 00    	je     f010076b <cga_putc+0xd2>
f01006bf:	83 f8 09             	cmp    $0x9,%eax
f01006c2:	7f 0a                	jg     f01006ce <cga_putc+0x35>
f01006c4:	83 f8 08             	cmp    $0x8,%eax
f01006c7:	74 14                	je     f01006dd <cga_putc+0x44>
f01006c9:	e9 db 00 00 00       	jmp    f01007a9 <cga_putc+0x110>
f01006ce:	83 f8 0a             	cmp    $0xa,%eax
f01006d1:	74 4e                	je     f0100721 <cga_putc+0x88>
f01006d3:	83 f8 0d             	cmp    $0xd,%eax
f01006d6:	74 59                	je     f0100731 <cga_putc+0x98>
f01006d8:	e9 cc 00 00 00       	jmp    f01007a9 <cga_putc+0x110>
	case '\b':
		if (crt_pos > 0) {
f01006dd:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f01006e4:	66 85 c0             	test   %ax,%ax
f01006e7:	74 33                	je     f010071c <cga_putc+0x83>
			crt_pos--;
f01006e9:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f01006f0:	83 e8 01             	sub    $0x1,%eax
f01006f3:	66 a3 0c 40 29 f0    	mov    %ax,0xf029400c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01006f9:	a1 08 40 29 f0       	mov    0xf0294008,%eax
f01006fe:	0f b7 15 0c 40 29 f0 	movzwl 0xf029400c,%edx
f0100705:	0f b7 d2             	movzwl %dx,%edx
f0100708:	01 d2                	add    %edx,%edx
f010070a:	01 c2                	add    %eax,%edx
f010070c:	8b 45 08             	mov    0x8(%ebp),%eax
f010070f:	b0 00                	mov    $0x0,%al
f0100711:	83 c8 20             	or     $0x20,%eax
f0100714:	66 89 02             	mov    %ax,(%edx)
		}
		break;
f0100717:	e9 b3 00 00 00       	jmp    f01007cf <cga_putc+0x136>
f010071c:	e9 ae 00 00 00       	jmp    f01007cf <cga_putc+0x136>
	case '\n':
		crt_pos += CRT_COLS;
f0100721:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f0100728:	83 c0 50             	add    $0x50,%eax
f010072b:	66 a3 0c 40 29 f0    	mov    %ax,0xf029400c
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100731:	0f b7 1d 0c 40 29 f0 	movzwl 0xf029400c,%ebx
f0100738:	0f b7 0d 0c 40 29 f0 	movzwl 0xf029400c,%ecx
f010073f:	0f b7 c1             	movzwl %cx,%eax
f0100742:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100748:	c1 e8 10             	shr    $0x10,%eax
f010074b:	89 c2                	mov    %eax,%edx
f010074d:	66 c1 ea 06          	shr    $0x6,%dx
f0100751:	89 d0                	mov    %edx,%eax
f0100753:	c1 e0 02             	shl    $0x2,%eax
f0100756:	01 d0                	add    %edx,%eax
f0100758:	c1 e0 04             	shl    $0x4,%eax
f010075b:	29 c1                	sub    %eax,%ecx
f010075d:	89 ca                	mov    %ecx,%edx
f010075f:	89 d8                	mov    %ebx,%eax
f0100761:	29 d0                	sub    %edx,%eax
f0100763:	66 a3 0c 40 29 f0    	mov    %ax,0xf029400c
		break;
f0100769:	eb 64                	jmp    f01007cf <cga_putc+0x136>
	case '\t':
		cons_putc(' ');
f010076b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100772:	e8 9e 03 00 00       	call   f0100b15 <cons_putc>
		cons_putc(' ');
f0100777:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010077e:	e8 92 03 00 00       	call   f0100b15 <cons_putc>
		cons_putc(' ');
f0100783:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010078a:	e8 86 03 00 00       	call   f0100b15 <cons_putc>
		cons_putc(' ');
f010078f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100796:	e8 7a 03 00 00       	call   f0100b15 <cons_putc>
		cons_putc(' ');
f010079b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01007a2:	e8 6e 03 00 00       	call   f0100b15 <cons_putc>
		break;
f01007a7:	eb 26                	jmp    f01007cf <cga_putc+0x136>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01007a9:	8b 0d 08 40 29 f0    	mov    0xf0294008,%ecx
f01007af:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f01007b6:	8d 50 01             	lea    0x1(%eax),%edx
f01007b9:	66 89 15 0c 40 29 f0 	mov    %dx,0xf029400c
f01007c0:	0f b7 c0             	movzwl %ax,%eax
f01007c3:	01 c0                	add    %eax,%eax
f01007c5:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f01007c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007cb:	66 89 02             	mov    %ax,(%edx)
		break;
f01007ce:	90                   	nop
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01007cf:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f01007d6:	66 3d cf 07          	cmp    $0x7cf,%ax
f01007da:	76 5b                	jbe    f0100837 <cga_putc+0x19e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01007dc:	a1 08 40 29 f0       	mov    0xf0294008,%eax
f01007e1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01007e7:	a1 08 40 29 f0       	mov    0xf0294008,%eax
f01007ec:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01007f3:	00 
f01007f4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01007f8:	89 04 24             	mov    %eax,(%esp)
f01007fb:	e8 73 82 00 00       	call   f0108a73 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100800:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f0100807:	eb 15                	jmp    f010081e <cga_putc+0x185>
			crt_buf[i] = 0x0700 | ' ';
f0100809:	a1 08 40 29 f0       	mov    0xf0294008,%eax
f010080e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100811:	01 d2                	add    %edx,%edx
f0100813:	01 d0                	add    %edx,%eax
f0100815:	66 c7 00 20 07       	movw   $0x720,(%eax)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010081a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010081e:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
f0100825:	7e e2                	jle    f0100809 <cga_putc+0x170>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100827:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f010082e:	83 e8 50             	sub    $0x50,%eax
f0100831:	66 a3 0c 40 29 f0    	mov    %ax,0xf029400c
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100837:	a1 04 40 29 f0       	mov    0xf0294004,%eax
f010083c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010083f:	c6 45 ef 0e          	movb   $0xe,-0x11(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100843:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0100847:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010084a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010084b:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f0100852:	66 c1 e8 08          	shr    $0x8,%ax
f0100856:	0f b6 c0             	movzbl %al,%eax
f0100859:	8b 15 04 40 29 f0    	mov    0xf0294004,%edx
f010085f:	83 c2 01             	add    $0x1,%edx
f0100862:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100865:	88 45 e7             	mov    %al,-0x19(%ebp)
f0100868:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010086c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010086f:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100870:	a1 04 40 29 f0       	mov    0xf0294004,%eax
f0100875:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100878:	c6 45 df 0f          	movb   $0xf,-0x21(%ebp)
f010087c:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f0100880:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100883:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f0100884:	0f b7 05 0c 40 29 f0 	movzwl 0xf029400c,%eax
f010088b:	0f b6 c0             	movzbl %al,%eax
f010088e:	8b 15 04 40 29 f0    	mov    0xf0294004,%edx
f0100894:	83 c2 01             	add    $0x1,%edx
f0100897:	89 55 d8             	mov    %edx,-0x28(%ebp)
f010089a:	88 45 d7             	mov    %al,-0x29(%ebp)
f010089d:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
f01008a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01008a4:	ee                   	out    %al,(%dx)
}
f01008a5:	83 c4 44             	add    $0x44,%esp
f01008a8:	5b                   	pop    %ebx
f01008a9:	5d                   	pop    %ebp
f01008aa:	c3                   	ret    

f01008ab <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01008ab:	55                   	push   %ebp
f01008ac:	89 e5                	mov    %esp,%ebp
f01008ae:	83 ec 38             	sub    $0x38,%esp
f01008b1:	c7 45 ec 64 00 00 00 	movl   $0x64,-0x14(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01008bb:	89 c2                	mov    %eax,%edx
f01008bd:	ec                   	in     (%dx),%al
f01008be:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
f01008c1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01008c5:	0f b6 c0             	movzbl %al,%eax
f01008c8:	83 e0 01             	and    $0x1,%eax
f01008cb:	85 c0                	test   %eax,%eax
f01008cd:	75 0a                	jne    f01008d9 <kbd_proc_data+0x2e>
		return -1;
f01008cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008d4:	e9 59 01 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
f01008d9:	c7 45 e4 60 00 00 00 	movl   $0x60,-0x1c(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01008e3:	89 c2                	mov    %eax,%edx
f01008e5:	ec                   	in     (%dx),%al
f01008e6:	88 45 e3             	mov    %al,-0x1d(%ebp)
	return data;
f01008e9:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax

	data = inb(KBDATAP);
f01008ed:	88 45 f3             	mov    %al,-0xd(%ebp)

	if (data == 0xE0) {
f01008f0:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
f01008f4:	75 17                	jne    f010090d <kbd_proc_data+0x62>
		// E0 escape character
		shift |= E0ESC;
f01008f6:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f01008fb:	83 c8 40             	or     $0x40,%eax
f01008fe:	a3 28 42 29 f0       	mov    %eax,0xf0294228
		return 0;
f0100903:	b8 00 00 00 00       	mov    $0x0,%eax
f0100908:	e9 25 01 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
	} else if (data & 0x80) {
f010090d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100911:	84 c0                	test   %al,%al
f0100913:	79 47                	jns    f010095c <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100915:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f010091a:	83 e0 40             	and    $0x40,%eax
f010091d:	85 c0                	test   %eax,%eax
f010091f:	75 09                	jne    f010092a <kbd_proc_data+0x7f>
f0100921:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100925:	83 e0 7f             	and    $0x7f,%eax
f0100928:	eb 04                	jmp    f010092e <kbd_proc_data+0x83>
f010092a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010092e:	88 45 f3             	mov    %al,-0xd(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
f0100931:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100935:	0f b6 80 00 70 12 f0 	movzbl -0xfed9000(%eax),%eax
f010093c:	83 c8 40             	or     $0x40,%eax
f010093f:	0f b6 c0             	movzbl %al,%eax
f0100942:	f7 d0                	not    %eax
f0100944:	89 c2                	mov    %eax,%edx
f0100946:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f010094b:	21 d0                	and    %edx,%eax
f010094d:	a3 28 42 29 f0       	mov    %eax,0xf0294228
		return 0;
f0100952:	b8 00 00 00 00       	mov    $0x0,%eax
f0100957:	e9 d6 00 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
	} else if (shift & E0ESC) {
f010095c:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f0100961:	83 e0 40             	and    $0x40,%eax
f0100964:	85 c0                	test   %eax,%eax
f0100966:	74 11                	je     f0100979 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100968:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f010096c:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f0100971:	83 e0 bf             	and    $0xffffffbf,%eax
f0100974:	a3 28 42 29 f0       	mov    %eax,0xf0294228
	}

	shift |= shiftcode[data];
f0100979:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010097d:	0f b6 80 00 70 12 f0 	movzbl -0xfed9000(%eax),%eax
f0100984:	0f b6 d0             	movzbl %al,%edx
f0100987:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f010098c:	09 d0                	or     %edx,%eax
f010098e:	a3 28 42 29 f0       	mov    %eax,0xf0294228
	shift ^= togglecode[data];
f0100993:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100997:	0f b6 80 00 71 12 f0 	movzbl -0xfed8f00(%eax),%eax
f010099e:	0f b6 d0             	movzbl %al,%edx
f01009a1:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f01009a6:	31 d0                	xor    %edx,%eax
f01009a8:	a3 28 42 29 f0       	mov    %eax,0xf0294228

	c = charcode[shift & (CTL | SHIFT)][data];
f01009ad:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f01009b2:	83 e0 03             	and    $0x3,%eax
f01009b5:	8b 14 85 00 75 12 f0 	mov    -0xfed8b00(,%eax,4),%edx
f01009bc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01009c0:	01 d0                	add    %edx,%eax
f01009c2:	0f b6 00             	movzbl (%eax),%eax
f01009c5:	0f b6 c0             	movzbl %al,%eax
f01009c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f01009cb:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f01009d0:	83 e0 08             	and    $0x8,%eax
f01009d3:	85 c0                	test   %eax,%eax
f01009d5:	74 22                	je     f01009f9 <kbd_proc_data+0x14e>
		if ('a' <= c && c <= 'z')
f01009d7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
f01009db:	7e 0c                	jle    f01009e9 <kbd_proc_data+0x13e>
f01009dd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
f01009e1:	7f 06                	jg     f01009e9 <kbd_proc_data+0x13e>
			c += 'A' - 'a';
f01009e3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
f01009e7:	eb 10                	jmp    f01009f9 <kbd_proc_data+0x14e>
		else if ('A' <= c && c <= 'Z')
f01009e9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
f01009ed:	7e 0a                	jle    f01009f9 <kbd_proc_data+0x14e>
f01009ef:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
f01009f3:	7f 04                	jg     f01009f9 <kbd_proc_data+0x14e>
			c += 'a' - 'A';
f01009f5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01009f9:	a1 28 42 29 f0       	mov    0xf0294228,%eax
f01009fe:	f7 d0                	not    %eax
f0100a00:	83 e0 06             	and    $0x6,%eax
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	75 28                	jne    f0100a2f <kbd_proc_data+0x184>
f0100a07:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f0100a0e:	75 1f                	jne    f0100a2f <kbd_proc_data+0x184>
		cprintf("Rebooting!\n");
f0100a10:	c7 04 24 82 9c 10 f0 	movl   $0xf0109c82,(%esp)
f0100a17:	e8 32 45 00 00       	call   f0104f4e <cprintf>
f0100a1c:	c7 45 dc 92 00 00 00 	movl   $0x92,-0x24(%ebp)
f0100a23:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100a27:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0100a2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a2e:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100a32:	c9                   	leave  
f0100a33:	c3                   	ret    

f0100a34 <kbd_intr>:

void
kbd_intr(void)
{
f0100a34:	55                   	push   %ebp
f0100a35:	89 e5                	mov    %esp,%ebp
f0100a37:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100a3a:	c7 04 24 ab 08 10 f0 	movl   $0xf01008ab,(%esp)
f0100a41:	e8 26 00 00 00       	call   f0100a6c <cons_intr>
}
f0100a46:	c9                   	leave  
f0100a47:	c3                   	ret    

f0100a48 <kbd_init>:

static void
kbd_init(void)
{
f0100a48:	55                   	push   %ebp
f0100a49:	89 e5                	mov    %esp,%ebp
f0100a4b:	83 ec 18             	sub    $0x18,%esp
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100a4e:	e8 e1 ff ff ff       	call   f0100a34 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100a53:	0f b7 05 ce 75 12 f0 	movzwl 0xf01275ce,%eax
f0100a5a:	0f b7 c0             	movzwl %ax,%eax
f0100a5d:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100a62:	89 04 24             	mov    %eax,(%esp)
f0100a65:	e8 dd 43 00 00       	call   f0104e47 <irq_setmask_8259A>
}
f0100a6a:	c9                   	leave  
f0100a6b:	c3                   	ret    

f0100a6c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100a6c:	55                   	push   %ebp
f0100a6d:	89 e5                	mov    %esp,%ebp
f0100a6f:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
f0100a72:	eb 35                	jmp    f0100aa9 <cons_intr+0x3d>
		if (c == 0)
f0100a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100a78:	75 02                	jne    f0100a7c <cons_intr+0x10>
			continue;
f0100a7a:	eb 2d                	jmp    f0100aa9 <cons_intr+0x3d>
		cons.buf[cons.wpos++] = c;
f0100a7c:	a1 24 42 29 f0       	mov    0xf0294224,%eax
f0100a81:	8d 50 01             	lea    0x1(%eax),%edx
f0100a84:	89 15 24 42 29 f0    	mov    %edx,0xf0294224
f0100a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100a8d:	88 90 20 40 29 f0    	mov    %dl,-0xfd6bfe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100a93:	a1 24 42 29 f0       	mov    0xf0294224,%eax
f0100a98:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100a9d:	75 0a                	jne    f0100aa9 <cons_intr+0x3d>
			cons.wpos = 0;
f0100a9f:	c7 05 24 42 29 f0 00 	movl   $0x0,0xf0294224
f0100aa6:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100aa9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100aac:	ff d0                	call   *%eax
f0100aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100ab1:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
f0100ab5:	75 bd                	jne    f0100a74 <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100ab7:	c9                   	leave  
f0100ab8:	c3                   	ret    

f0100ab9 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100ab9:	55                   	push   %ebp
f0100aba:	89 e5                	mov    %esp,%ebp
f0100abc:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100abf:	e8 4d f9 ff ff       	call   f0100411 <serial_intr>
	kbd_intr();
f0100ac4:	e8 6b ff ff ff       	call   f0100a34 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100ac9:	8b 15 20 42 29 f0    	mov    0xf0294220,%edx
f0100acf:	a1 24 42 29 f0       	mov    0xf0294224,%eax
f0100ad4:	39 c2                	cmp    %eax,%edx
f0100ad6:	74 36                	je     f0100b0e <cons_getc+0x55>
		c = cons.buf[cons.rpos++];
f0100ad8:	a1 20 42 29 f0       	mov    0xf0294220,%eax
f0100add:	8d 50 01             	lea    0x1(%eax),%edx
f0100ae0:	89 15 20 42 29 f0    	mov    %edx,0xf0294220
f0100ae6:	0f b6 80 20 40 29 f0 	movzbl -0xfd6bfe0(%eax),%eax
f0100aed:	0f b6 c0             	movzbl %al,%eax
f0100af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f0100af3:	a1 20 42 29 f0       	mov    0xf0294220,%eax
f0100af8:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100afd:	75 0a                	jne    f0100b09 <cons_getc+0x50>
			cons.rpos = 0;
f0100aff:	c7 05 20 42 29 f0 00 	movl   $0x0,0xf0294220
f0100b06:	00 00 00 
		return c;
f0100b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b0c:	eb 05                	jmp    f0100b13 <cons_getc+0x5a>
	}
	return 0;
f0100b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b13:	c9                   	leave  
f0100b14:	c3                   	ret    

f0100b15 <cons_putc>:

// output a character to the console
static void
cons_putc(int c)
{
f0100b15:	55                   	push   %ebp
f0100b16:	89 e5                	mov    %esp,%ebp
f0100b18:	83 ec 18             	sub    $0x18,%esp
	if((c & 0xff) == '\b'){
f0100b1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b1e:	0f b6 c0             	movzbl %al,%eax
f0100b21:	83 f8 08             	cmp    $0x8,%eax
f0100b24:	75 26                	jne    f0100b4c <cons_putc+0x37>
		serial_putc('\b');
f0100b26:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0100b2d:	e8 fe f8 ff ff       	call   f0100430 <serial_putc>
		serial_putc(' ');
f0100b32:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100b39:	e8 f2 f8 ff ff       	call   f0100430 <serial_putc>
		serial_putc('\b');
f0100b3e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0100b45:	e8 e6 f8 ff ff       	call   f0100430 <serial_putc>
f0100b4a:	eb 0b                	jmp    f0100b57 <cons_putc+0x42>
	}
	else
		serial_putc(c);
f0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b4f:	89 04 24             	mov    %eax,(%esp)
f0100b52:	e8 d9 f8 ff ff       	call   f0100430 <serial_putc>
	lpt_putc(c);
f0100b57:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b5a:	89 04 24             	mov    %eax,(%esp)
f0100b5d:	e8 f2 f9 ff ff       	call   f0100554 <lpt_putc>
	cga_putc(c);
f0100b62:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b65:	89 04 24             	mov    %eax,(%esp)
f0100b68:	e8 2c fb ff ff       	call   f0100699 <cga_putc>
}
f0100b6d:	c9                   	leave  
f0100b6e:	c3                   	ret    

f0100b6f <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100b6f:	55                   	push   %ebp
f0100b70:	89 e5                	mov    %esp,%ebp
f0100b72:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100b75:	e8 53 fa ff ff       	call   f01005cd <cga_init>
	kbd_init();
f0100b7a:	e8 c9 fe ff ff       	call   f0100a48 <kbd_init>
	serial_init();
f0100b7f:	e8 05 f9 ff ff       	call   f0100489 <serial_init>

	if (!serial_exists)
f0100b84:	0f b6 05 00 40 29 f0 	movzbl 0xf0294000,%eax
f0100b8b:	83 f0 01             	xor    $0x1,%eax
f0100b8e:	84 c0                	test   %al,%al
f0100b90:	74 0c                	je     f0100b9e <cons_init+0x2f>
		cprintf("Serial port does not exist!\n");
f0100b92:	c7 04 24 8e 9c 10 f0 	movl   $0xf0109c8e,(%esp)
f0100b99:	e8 b0 43 00 00       	call   f0104f4e <cprintf>
}
f0100b9e:	c9                   	leave  
f0100b9f:	c3                   	ret    

f0100ba0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100ba0:	55                   	push   %ebp
f0100ba1:	89 e5                	mov    %esp,%ebp
f0100ba3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100ba6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ba9:	89 04 24             	mov    %eax,(%esp)
f0100bac:	e8 64 ff ff ff       	call   f0100b15 <cons_putc>
}
f0100bb1:	c9                   	leave  
f0100bb2:	c3                   	ret    

f0100bb3 <getchar>:

int
getchar(void)
{
f0100bb3:	55                   	push   %ebp
f0100bb4:	89 e5                	mov    %esp,%ebp
f0100bb6:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100bb9:	e8 fb fe ff ff       	call   f0100ab9 <cons_getc>
f0100bbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100bc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100bc5:	74 f2                	je     f0100bb9 <getchar+0x6>
		/* do nothing */;
	return c;
f0100bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100bca:	c9                   	leave  
f0100bcb:	c3                   	ret    

f0100bcc <iscons>:

int
iscons(int fdnum)
{
f0100bcc:	55                   	push   %ebp
f0100bcd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
f0100bcf:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0100bd4:	5d                   	pop    %ebp
f0100bd5:	c3                   	ret    

f0100bd6 <mon_continue>:
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int mon_continue(int argc, char **argv, struct Trapframe *tf){
f0100bd6:	55                   	push   %ebp
f0100bd7:	89 e5                	mov    %esp,%ebp
f0100bd9:	83 ec 18             	sub    $0x18,%esp
	if(!tf){
f0100bdc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100be0:	75 13                	jne    f0100bf5 <mon_continue+0x1f>
		cprintf("Null Trapframe!\n");
f0100be2:	c7 04 24 7a 9d 10 f0 	movl   $0xf0109d7a,(%esp)
f0100be9:	e8 60 43 00 00       	call   f0104f4e <cprintf>
		return 0;
f0100bee:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bf3:	eb 49                	jmp    f0100c3e <mon_continue+0x68>
	}
	if(tf->tf_trapno != T_BRKPT && tf->tf_trapno != T_DEBUG){
f0100bf5:	8b 45 10             	mov    0x10(%ebp),%eax
f0100bf8:	8b 40 28             	mov    0x28(%eax),%eax
f0100bfb:	83 f8 03             	cmp    $0x3,%eax
f0100bfe:	74 28                	je     f0100c28 <mon_continue+0x52>
f0100c00:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c03:	8b 40 28             	mov    0x28(%eax),%eax
f0100c06:	83 f8 01             	cmp    $0x1,%eax
f0100c09:	74 1d                	je     f0100c28 <mon_continue+0x52>
		cprintf("invalid trap number: %d\nShould be breakpoint or debug.\n", tf->tf_trapno);
f0100c0b:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c0e:	8b 40 28             	mov    0x28(%eax),%eax
f0100c11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c15:	c7 04 24 8c 9d 10 f0 	movl   $0xf0109d8c,(%esp)
f0100c1c:	e8 2d 43 00 00       	call   f0104f4e <cprintf>
		return 0;
f0100c21:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c26:	eb 16                	jmp    f0100c3e <mon_continue+0x68>
	}
	tf->tf_eflags &= ~FL_TF;
f0100c28:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c2b:	8b 40 38             	mov    0x38(%eax),%eax
f0100c2e:	80 e4 fe             	and    $0xfe,%ah
f0100c31:	89 c2                	mov    %eax,%edx
f0100c33:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c36:	89 50 38             	mov    %edx,0x38(%eax)
	return -1;
f0100c39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c3e:	c9                   	leave  
f0100c3f:	c3                   	ret    

f0100c40 <mon_single_step>:

int mon_single_step(int argc, char **argv, struct Trapframe *tf){
f0100c40:	55                   	push   %ebp
f0100c41:	89 e5                	mov    %esp,%ebp
f0100c43:	83 ec 18             	sub    $0x18,%esp
	if(!tf){
f0100c46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100c4a:	75 13                	jne    f0100c5f <mon_single_step+0x1f>
		cprintf("Null Trapframe!\n");
f0100c4c:	c7 04 24 7a 9d 10 f0 	movl   $0xf0109d7a,(%esp)
f0100c53:	e8 f6 42 00 00       	call   f0104f4e <cprintf>
		return 0;
f0100c58:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c5d:	eb 49                	jmp    f0100ca8 <mon_single_step+0x68>
	}
	if(tf->tf_trapno != T_BRKPT && tf->tf_trapno != T_DEBUG){
f0100c5f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c62:	8b 40 28             	mov    0x28(%eax),%eax
f0100c65:	83 f8 03             	cmp    $0x3,%eax
f0100c68:	74 28                	je     f0100c92 <mon_single_step+0x52>
f0100c6a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c6d:	8b 40 28             	mov    0x28(%eax),%eax
f0100c70:	83 f8 01             	cmp    $0x1,%eax
f0100c73:	74 1d                	je     f0100c92 <mon_single_step+0x52>
		cprintf("invalid trap number: %d\nShould be breakpoint or debug.\n", tf->tf_trapno);
f0100c75:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c78:	8b 40 28             	mov    0x28(%eax),%eax
f0100c7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c7f:	c7 04 24 8c 9d 10 f0 	movl   $0xf0109d8c,(%esp)
f0100c86:	e8 c3 42 00 00       	call   f0104f4e <cprintf>
		return 0;
f0100c8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c90:	eb 16                	jmp    f0100ca8 <mon_single_step+0x68>
	}
	tf->tf_eflags |= FL_TF;
f0100c92:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c95:	8b 40 38             	mov    0x38(%eax),%eax
f0100c98:	80 cc 01             	or     $0x1,%ah
f0100c9b:	89 c2                	mov    %eax,%edx
f0100c9d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ca0:	89 50 38             	mov    %edx,0x38(%eax)
	return -1;
f0100ca3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100ca8:	c9                   	leave  
f0100ca9:	c3                   	ret    

f0100caa <mon_help>:

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100caa:	55                   	push   %ebp
f0100cab:	89 e5                	mov    %esp,%ebp
f0100cad:	83 ec 28             	sub    $0x28,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100cb0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100cb7:	eb 3f                	jmp    f0100cf8 <mon_help+0x4e>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100cbc:	89 d0                	mov    %edx,%eax
f0100cbe:	01 c0                	add    %eax,%eax
f0100cc0:	01 d0                	add    %edx,%eax
f0100cc2:	c1 e0 02             	shl    $0x2,%eax
f0100cc5:	05 20 75 12 f0       	add    $0xf0127520,%eax
f0100cca:	8b 48 04             	mov    0x4(%eax),%ecx
f0100ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100cd0:	89 d0                	mov    %edx,%eax
f0100cd2:	01 c0                	add    %eax,%eax
f0100cd4:	01 d0                	add    %edx,%eax
f0100cd6:	c1 e0 02             	shl    $0x2,%eax
f0100cd9:	05 20 75 12 f0       	add    $0xf0127520,%eax
f0100cde:	8b 00                	mov    (%eax),%eax
f0100ce0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce8:	c7 04 24 c4 9d 10 f0 	movl   $0xf0109dc4,(%esp)
f0100cef:	e8 5a 42 00 00       	call   f0104f4e <cprintf>
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100cf4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0100cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100cfb:	83 f8 04             	cmp    $0x4,%eax
f0100cfe:	76 b9                	jbe    f0100cb9 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
f0100d00:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d05:	c9                   	leave  
f0100d06:	c3                   	ret    

f0100d07 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100d07:	55                   	push   %ebp
f0100d08:	89 e5                	mov    %esp,%ebp
f0100d0a:	83 ec 28             	sub    $0x28,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100d0d:	c7 04 24 cd 9d 10 f0 	movl   $0xf0109dcd,(%esp)
f0100d14:	e8 35 42 00 00       	call   f0104f4e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100d19:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100d20:	00 
f0100d21:	c7 04 24 e8 9d 10 f0 	movl   $0xf0109de8,(%esp)
f0100d28:	e8 21 42 00 00       	call   f0104f4e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100d2d:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100d34:	00 
f0100d35:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100d3c:	f0 
f0100d3d:	c7 04 24 10 9e 10 f0 	movl   $0xf0109e10,(%esp)
f0100d44:	e8 05 42 00 00       	call   f0104f4e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100d49:	c7 44 24 08 a7 9b 10 	movl   $0x109ba7,0x8(%esp)
f0100d50:	00 
f0100d51:	c7 44 24 04 a7 9b 10 	movl   $0xf0109ba7,0x4(%esp)
f0100d58:	f0 
f0100d59:	c7 04 24 34 9e 10 f0 	movl   $0xf0109e34,(%esp)
f0100d60:	e8 e9 41 00 00       	call   f0104f4e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100d65:	c7 44 24 08 e6 3e 29 	movl   $0x293ee6,0x8(%esp)
f0100d6c:	00 
f0100d6d:	c7 44 24 04 e6 3e 29 	movl   $0xf0293ee6,0x4(%esp)
f0100d74:	f0 
f0100d75:	c7 04 24 58 9e 10 f0 	movl   $0xf0109e58,(%esp)
f0100d7c:	e8 cd 41 00 00       	call   f0104f4e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100d81:	c7 44 24 08 08 90 2d 	movl   $0x2d9008,0x8(%esp)
f0100d88:	00 
f0100d89:	c7 44 24 04 08 90 2d 	movl   $0xf02d9008,0x4(%esp)
f0100d90:	f0 
f0100d91:	c7 04 24 7c 9e 10 f0 	movl   $0xf0109e7c,(%esp)
f0100d98:	e8 b1 41 00 00       	call   f0104f4e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100d9d:	c7 45 f4 00 04 00 00 	movl   $0x400,-0xc(%ebp)
f0100da4:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100dac:	29 c2                	sub    %eax,%edx
f0100dae:	b8 08 90 2d f0       	mov    $0xf02d9008,%eax
f0100db3:	83 e8 01             	sub    $0x1,%eax
f0100db6:	01 d0                	add    %edx,%eax
f0100db8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100dbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100dbe:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dc3:	f7 75 f4             	divl   -0xc(%ebp)
f0100dc6:	89 d0                	mov    %edx,%eax
f0100dc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100dcb:	29 c2                	sub    %eax,%edx
f0100dcd:	89 d0                	mov    %edx,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100dcf:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100dd5:	85 c0                	test   %eax,%eax
f0100dd7:	0f 48 c2             	cmovs  %edx,%eax
f0100dda:	c1 f8 0a             	sar    $0xa,%eax
f0100ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100de1:	c7 04 24 a0 9e 10 f0 	movl   $0xf0109ea0,(%esp)
f0100de8:	e8 61 41 00 00       	call   f0104f4e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
f0100ded:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100df2:	c9                   	leave  
f0100df3:	c3                   	ret    

f0100df4 <dummy>:

uint32_t dummy(){
f0100df4:	55                   	push   %ebp
f0100df5:	89 e5                	mov    %esp,%ebp
f0100df7:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100dfa:	89 e8                	mov    %ebp,%eax
f0100dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return ebp;
f0100dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
	uint32_t* ebp = (uint32_t *)read_ebp();
f0100e02:	89 45 f8             	mov    %eax,-0x8(%ebp)
	uint32_t eip = *(ebp+1);
f0100e05:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0100e08:	8b 40 04             	mov    0x4(%eax),%eax
f0100e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int i=0;
f0100e0e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	while(i<10){
f0100e15:	eb 04                	jmp    f0100e1b <dummy+0x27>
		i++;
f0100e17:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)

uint32_t dummy(){
	uint32_t* ebp = (uint32_t *)read_ebp();
	uint32_t eip = *(ebp+1);
	int i=0;
	while(i<10){
f0100e1b:	83 7d fc 09          	cmpl   $0x9,-0x4(%ebp)
f0100e1f:	7e f6                	jle    f0100e17 <dummy+0x23>
		i++;
	}
	return (eip);
f0100e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100e24:	c9                   	leave  
f0100e25:	c3                   	ret    

f0100e26 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100e26:	55                   	push   %ebp
f0100e27:	89 e5                	mov    %esp,%ebp
f0100e29:	57                   	push   %edi
f0100e2a:	56                   	push   %esi
f0100e2b:	53                   	push   %ebx
f0100e2c:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f0100e2f:	c7 04 24 ca 9e 10 f0 	movl   $0xf0109eca,(%esp)
f0100e36:	e8 13 41 00 00       	call   f0104f4e <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100e3b:	89 e8                	mov    %ebp,%eax
f0100e3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return ebp;
f0100e40:	8b 45 d0             	mov    -0x30(%ebp),%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100e43:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	uint32_t eip = dummy();
f0100e46:	e8 a9 ff ff ff       	call   f0100df4 <dummy>
f0100e4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	cprintf("  current eip=%08x\n",eip);
f0100e4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e55:	c7 04 24 dc 9e 10 f0 	movl   $0xf0109edc,(%esp)
f0100e5c:	e8 ed 40 00 00       	call   f0104f4e <cprintf>

	struct Eipdebuginfo eip_info;
	int eip_ret_info = debuginfo_eip(eip,&eip_info);
f0100e61:	8d 45 b8             	lea    -0x48(%ebp),%eax
f0100e64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e68:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e6b:	89 04 24             	mov    %eax,(%esp)
f0100e6e:	e8 ca 6d 00 00       	call   f0107c3d <debuginfo_eip>
f0100e73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(eip_ret_info == 0){
f0100e76:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100e7a:	75 6c                	jne    f0100ee8 <mon_backtrace+0xc2>
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
f0100e7c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100e7f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100e82:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e8a:	c7 04 24 f0 9e 10 f0 	movl   $0xf0109ef0,(%esp)
f0100e91:	e8 b8 40 00 00       	call   f0104f4e <cprintf>
			int i=0;
f0100e96:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			while(i<eip_info.eip_fn_namelen){
f0100e9d:	eb 22                	jmp    f0100ec1 <mon_backtrace+0x9b>
				cprintf("%c",eip_info.eip_fn_name[i]);
f0100e9f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100ea2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ea5:	01 d0                	add    %edx,%eax
f0100ea7:	0f b6 00             	movzbl (%eax),%eax
f0100eaa:	0f be c0             	movsbl %al,%eax
f0100ead:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100eb1:	c7 04 24 f9 9e 10 f0 	movl   $0xf0109ef9,(%esp)
f0100eb8:	e8 91 40 00 00       	call   f0104f4e <cprintf>
				i++;
f0100ebd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
	struct Eipdebuginfo eip_info;
	int eip_ret_info = debuginfo_eip(eip,&eip_info);
	if(eip_ret_info == 0){
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
			int i=0;
			while(i<eip_info.eip_fn_namelen){
f0100ec1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100ec4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100ec7:	7f d6                	jg     f0100e9f <mon_backtrace+0x79>
				cprintf("%c",eip_info.eip_fn_name[i]);
				i++;
			}
			cprintf("+%d\n", eip-eip_info.eip_fn_addr);
f0100ec9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100ecc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ecf:	29 c2                	sub    %eax,%edx
f0100ed1:	89 d0                	mov    %edx,%eax
f0100ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ed7:	c7 04 24 fc 9e 10 f0 	movl   $0xf0109efc,(%esp)
f0100ede:	e8 6b 40 00 00       	call   f0104f4e <cprintf>
		}
	while(ebp != 0){
f0100ee3:	e9 f3 00 00 00       	jmp    f0100fdb <mon_backtrace+0x1b5>
f0100ee8:	e9 ee 00 00 00       	jmp    f0100fdb <mon_backtrace+0x1b5>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", (ebp), *(ebp+1), *(ebp+2), *(ebp+3), *(ebp+4), *(ebp+5), *(ebp+6));
f0100eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ef0:	83 c0 18             	add    $0x18,%eax
f0100ef3:	8b 38                	mov    (%eax),%edi
f0100ef5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ef8:	83 c0 14             	add    $0x14,%eax
f0100efb:	8b 30                	mov    (%eax),%esi
f0100efd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f00:	83 c0 10             	add    $0x10,%eax
f0100f03:	8b 18                	mov    (%eax),%ebx
f0100f05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f08:	83 c0 0c             	add    $0xc,%eax
f0100f0b:	8b 08                	mov    (%eax),%ecx
f0100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f10:	83 c0 08             	add    $0x8,%eax
f0100f13:	8b 10                	mov    (%eax),%edx
f0100f15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f18:	83 c0 04             	add    $0x4,%eax
f0100f1b:	8b 00                	mov    (%eax),%eax
f0100f1d:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100f21:	89 74 24 18          	mov    %esi,0x18(%esp)
f0100f25:	89 5c 24 14          	mov    %ebx,0x14(%esp)
f0100f29:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100f2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f31:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f3c:	c7 04 24 04 9f 10 f0 	movl   $0xf0109f04,(%esp)
f0100f43:	e8 06 40 00 00       	call   f0104f4e <cprintf>
		eip = *(ebp+1);
f0100f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4b:	8b 40 04             	mov    0x4(%eax),%eax
f0100f4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		eip_ret_info = debuginfo_eip(eip,&eip_info);
f0100f51:	8d 45 b8             	lea    -0x48(%ebp),%eax
f0100f54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f58:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f5b:	89 04 24             	mov    %eax,(%esp)
f0100f5e:	e8 da 6c 00 00       	call   f0107c3d <debuginfo_eip>
f0100f63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if(eip_ret_info == 0){
f0100f66:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f6a:	75 67                	jne    f0100fd3 <mon_backtrace+0x1ad>
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
f0100f6c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100f6f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100f72:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100f76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7a:	c7 04 24 f0 9e 10 f0 	movl   $0xf0109ef0,(%esp)
f0100f81:	e8 c8 3f 00 00       	call   f0104f4e <cprintf>
			int i=0;
f0100f86:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
			while(i<eip_info.eip_fn_namelen){
f0100f8d:	eb 22                	jmp    f0100fb1 <mon_backtrace+0x18b>
				cprintf("%c",eip_info.eip_fn_name[i]);
f0100f8f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100f92:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f95:	01 d0                	add    %edx,%eax
f0100f97:	0f b6 00             	movzbl (%eax),%eax
f0100f9a:	0f be c0             	movsbl %al,%eax
f0100f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa1:	c7 04 24 f9 9e 10 f0 	movl   $0xf0109ef9,(%esp)
f0100fa8:	e8 a1 3f 00 00       	call   f0104f4e <cprintf>
				i++;
f0100fad:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
		eip = *(ebp+1);
		eip_ret_info = debuginfo_eip(eip,&eip_info);
		if(eip_ret_info == 0){
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
			int i=0;
			while(i<eip_info.eip_fn_namelen){
f0100fb1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100fb4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0100fb7:	7f d6                	jg     f0100f8f <mon_backtrace+0x169>
				cprintf("%c",eip_info.eip_fn_name[i]);
				i++;
			}
			cprintf("+%d\n", eip-eip_info.eip_fn_addr);
f0100fb9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100fbc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fbf:	29 c2                	sub    %eax,%edx
f0100fc1:	89 d0                	mov    %edx,%eax
f0100fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc7:	c7 04 24 fc 9e 10 f0 	movl   $0xf0109efc,(%esp)
f0100fce:	e8 7b 3f 00 00       	call   f0104f4e <cprintf>
		}
		ebp = (uint32_t*)(*ebp);
f0100fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fd6:	8b 00                	mov    (%eax),%eax
f0100fd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				cprintf("%c",eip_info.eip_fn_name[i]);
				i++;
			}
			cprintf("+%d\n", eip-eip_info.eip_fn_addr);
		}
	while(ebp != 0){
f0100fdb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100fdf:	0f 85 08 ff ff ff    	jne    f0100eed <mon_backtrace+0xc7>
			cprintf("+%d\n", eip-eip_info.eip_fn_addr);
		}
		ebp = (uint32_t*)(*ebp);
	}
	// Your code here.
	return 0;
f0100fe5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fea:	83 c4 5c             	add    $0x5c,%esp
f0100fed:	5b                   	pop    %ebx
f0100fee:	5e                   	pop    %esi
f0100fef:	5f                   	pop    %edi
f0100ff0:	5d                   	pop    %ebp
f0100ff1:	c3                   	ret    

f0100ff2 <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f0100ff2:	55                   	push   %ebp
f0100ff3:	89 e5                	mov    %esp,%ebp
f0100ff5:	83 ec 68             	sub    $0x68,%esp
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ff8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	argv[argc] = 0;
f0100fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101002:	c7 44 85 b0 00 00 00 	movl   $0x0,-0x50(%ebp,%eax,4)
f0101009:	00 
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010100a:	eb 0c                	jmp    f0101018 <runcmd+0x26>
			*buf++ = 0;
f010100c:	8b 45 08             	mov    0x8(%ebp),%eax
f010100f:	8d 50 01             	lea    0x1(%eax),%edx
f0101012:	89 55 08             	mov    %edx,0x8(%ebp)
f0101015:	c6 00 00             	movb   $0x0,(%eax)
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0101018:	8b 45 08             	mov    0x8(%ebp),%eax
f010101b:	0f b6 00             	movzbl (%eax),%eax
f010101e:	84 c0                	test   %al,%al
f0101020:	74 1d                	je     f010103f <runcmd+0x4d>
f0101022:	8b 45 08             	mov    0x8(%ebp),%eax
f0101025:	0f b6 00             	movzbl (%eax),%eax
f0101028:	0f be c0             	movsbl %al,%eax
f010102b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010102f:	c7 04 24 39 9f 10 f0 	movl   $0xf0109f39,(%esp)
f0101036:	e8 69 79 00 00       	call   f01089a4 <strchr>
f010103b:	85 c0                	test   %eax,%eax
f010103d:	75 cd                	jne    f010100c <runcmd+0x1a>
			*buf++ = 0;
		if (*buf == 0)
f010103f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101042:	0f b6 00             	movzbl (%eax),%eax
f0101045:	84 c0                	test   %al,%al
f0101047:	75 14                	jne    f010105d <runcmd+0x6b>
			break;
f0101049:	90                   	nop
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f010104a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010104d:	c7 44 85 b0 00 00 00 	movl   $0x0,-0x50(%ebp,%eax,4)
f0101054:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101055:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101059:	75 70                	jne    f01010cb <runcmd+0xd9>
f010105b:	eb 67                	jmp    f01010c4 <runcmd+0xd2>
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010105d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
f0101061:	75 1e                	jne    f0101081 <runcmd+0x8f>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101063:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010106a:	00 
f010106b:	c7 04 24 3e 9f 10 f0 	movl   $0xf0109f3e,(%esp)
f0101072:	e8 d7 3e 00 00       	call   f0104f4e <cprintf>
			return 0;
f0101077:	b8 00 00 00 00       	mov    $0x0,%eax
f010107c:	e9 c9 00 00 00       	jmp    f010114a <runcmd+0x158>
		}
		argv[argc++] = buf;
f0101081:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101084:	8d 50 01             	lea    0x1(%eax),%edx
f0101087:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010108a:	8b 55 08             	mov    0x8(%ebp),%edx
f010108d:	89 54 85 b0          	mov    %edx,-0x50(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0101091:	eb 04                	jmp    f0101097 <runcmd+0xa5>
			buf++;
f0101093:	83 45 08 01          	addl   $0x1,0x8(%ebp)
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101097:	8b 45 08             	mov    0x8(%ebp),%eax
f010109a:	0f b6 00             	movzbl (%eax),%eax
f010109d:	84 c0                	test   %al,%al
f010109f:	74 1d                	je     f01010be <runcmd+0xcc>
f01010a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a4:	0f b6 00             	movzbl (%eax),%eax
f01010a7:	0f be c0             	movsbl %al,%eax
f01010aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010ae:	c7 04 24 39 9f 10 f0 	movl   $0xf0109f39,(%esp)
f01010b5:	e8 ea 78 00 00       	call   f01089a4 <strchr>
f01010ba:	85 c0                	test   %eax,%eax
f01010bc:	74 d5                	je     f0101093 <runcmd+0xa1>
			buf++;
	}
f01010be:	90                   	nop
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01010bf:	e9 54 ff ff ff       	jmp    f0101018 <runcmd+0x26>
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
f01010c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c9:	eb 7f                	jmp    f010114a <runcmd+0x158>
	for (i = 0; i < NCOMMANDS; i++) {
f01010cb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01010d2:	eb 56                	jmp    f010112a <runcmd+0x138>
		if (strcmp(argv[0], commands[i].name) == 0)
f01010d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01010d7:	89 d0                	mov    %edx,%eax
f01010d9:	01 c0                	add    %eax,%eax
f01010db:	01 d0                	add    %edx,%eax
f01010dd:	c1 e0 02             	shl    $0x2,%eax
f01010e0:	05 20 75 12 f0       	add    $0xf0127520,%eax
f01010e5:	8b 10                	mov    (%eax),%edx
f01010e7:	8b 45 b0             	mov    -0x50(%ebp),%eax
f01010ea:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010ee:	89 04 24             	mov    %eax,(%esp)
f01010f1:	e8 19 78 00 00       	call   f010890f <strcmp>
f01010f6:	85 c0                	test   %eax,%eax
f01010f8:	75 2c                	jne    f0101126 <runcmd+0x134>
			return commands[i].func(argc, argv, tf);
f01010fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01010fd:	89 d0                	mov    %edx,%eax
f01010ff:	01 c0                	add    %eax,%eax
f0101101:	01 d0                	add    %edx,%eax
f0101103:	c1 e0 02             	shl    $0x2,%eax
f0101106:	05 20 75 12 f0       	add    $0xf0127520,%eax
f010110b:	8b 40 08             	mov    0x8(%eax),%eax
f010110e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101111:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101115:	8d 55 b0             	lea    -0x50(%ebp),%edx
f0101118:	89 54 24 04          	mov    %edx,0x4(%esp)
f010111c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010111f:	89 14 24             	mov    %edx,(%esp)
f0101122:	ff d0                	call   *%eax
f0101124:	eb 24                	jmp    f010114a <runcmd+0x158>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0101126:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f010112a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010112d:	83 f8 04             	cmp    $0x4,%eax
f0101130:	76 a2                	jbe    f01010d4 <runcmd+0xe2>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0101132:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0101135:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101139:	c7 04 24 5b 9f 10 f0 	movl   $0xf0109f5b,(%esp)
f0101140:	e8 09 3e 00 00       	call   f0104f4e <cprintf>
	return 0;
f0101145:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010114a:	c9                   	leave  
f010114b:	c3                   	ret    

f010114c <monitor>:

void
monitor(struct Trapframe *tf)
{
f010114c:	55                   	push   %ebp
f010114d:	89 e5                	mov    %esp,%ebp
f010114f:	83 ec 28             	sub    $0x28,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101152:	c7 04 24 74 9f 10 f0 	movl   $0xf0109f74,(%esp)
f0101159:	e8 f0 3d 00 00       	call   f0104f4e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010115e:	c7 04 24 98 9f 10 f0 	movl   $0xf0109f98,(%esp)
f0101165:	e8 e4 3d 00 00       	call   f0104f4e <cprintf>

	if (tf != NULL)
f010116a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010116e:	74 0b                	je     f010117b <monitor+0x2f>
		print_trapframe(tf);
f0101170:	8b 45 08             	mov    0x8(%ebp),%eax
f0101173:	89 04 24             	mov    %eax,(%esp)
f0101176:	e8 25 4c 00 00       	call   f0105da0 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010117b:	c7 04 24 bd 9f 10 f0 	movl   $0xf0109fbd,(%esp)
f0101182:	e8 4f 75 00 00       	call   f01086d6 <readline>
f0101187:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (buf != NULL)
f010118a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010118e:	74 18                	je     f01011a8 <monitor+0x5c>
			if (runcmd(buf, tf) < 0)
f0101190:	8b 45 08             	mov    0x8(%ebp),%eax
f0101193:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101197:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010119a:	89 04 24             	mov    %eax,(%esp)
f010119d:	e8 50 fe ff ff       	call   f0100ff2 <runcmd>
f01011a2:	85 c0                	test   %eax,%eax
f01011a4:	79 02                	jns    f01011a8 <monitor+0x5c>
				break;
f01011a6:	eb 02                	jmp    f01011aa <monitor+0x5e>
	}
f01011a8:	eb d1                	jmp    f010117b <monitor+0x2f>
}
f01011aa:	c9                   	leave  
f01011ab:	c3                   	ret    

f01011ac <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01011ac:	55                   	push   %ebp
f01011ad:	89 e5                	mov    %esp,%ebp
f01011af:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f01011b2:	8b 45 10             	mov    0x10(%ebp),%eax
f01011b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011ba:	77 21                	ja     f01011dd <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01011bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011c3:	c7 44 24 08 c4 9f 10 	movl   $0xf0109fc4,0x8(%esp)
f01011ca:	f0 
f01011cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01011d5:	89 04 24             	mov    %eax,(%esp)
f01011d8:	e8 f2 f0 ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f01011dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01011e0:	05 00 00 00 10       	add    $0x10000000,%eax
}
f01011e5:	c9                   	leave  
f01011e6:	c3                   	ret    

f01011e7 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01011e7:	55                   	push   %ebp
f01011e8:	89 e5                	mov    %esp,%ebp
f01011ea:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f01011ed:	8b 45 10             	mov    0x10(%ebp),%eax
f01011f0:	c1 e8 0c             	shr    $0xc,%eax
f01011f3:	89 c2                	mov    %eax,%edx
f01011f5:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f01011fa:	39 c2                	cmp    %eax,%edx
f01011fc:	72 21                	jb     f010121f <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0101201:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101205:	c7 44 24 08 e8 9f 10 	movl   $0xf0109fe8,0x8(%esp)
f010120c:	f0 
f010120d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101210:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101214:	8b 45 08             	mov    0x8(%ebp),%eax
f0101217:	89 04 24             	mov    %eax,(%esp)
f010121a:	e8 b0 f0 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f010121f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101222:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0101227:	c9                   	leave  
f0101228:	c3                   	ret    

f0101229 <page2pa>:
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
f0101229:	55                   	push   %ebp
f010122a:	89 e5                	mov    %esp,%ebp
	return (pp - pages) << PGSHIFT;
f010122c:	8b 55 08             	mov    0x8(%ebp),%edx
f010122f:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101234:	29 c2                	sub    %eax,%edx
f0101236:	89 d0                	mov    %edx,%eax
f0101238:	c1 f8 03             	sar    $0x3,%eax
f010123b:	c1 e0 0c             	shl    $0xc,%eax
}
f010123e:	5d                   	pop    %ebp
f010123f:	c3                   	ret    

f0101240 <pa2page>:

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
f0101240:	55                   	push   %ebp
f0101241:	89 e5                	mov    %esp,%ebp
f0101243:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0101246:	8b 45 08             	mov    0x8(%ebp),%eax
f0101249:	c1 e8 0c             	shr    $0xc,%eax
f010124c:	89 c2                	mov    %eax,%edx
f010124e:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f0101253:	39 c2                	cmp    %eax,%edx
f0101255:	72 1c                	jb     f0101273 <pa2page+0x33>
		panic("pa2page called with invalid pa");
f0101257:	c7 44 24 08 0c a0 10 	movl   $0xf010a00c,0x8(%esp)
f010125e:	f0 
f010125f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101266:	00 
f0101267:	c7 04 24 2b a0 10 f0 	movl   $0xf010a02b,(%esp)
f010126e:	e8 5c f0 ff ff       	call   f01002cf <_panic>
	return &pages[PGNUM(pa)];
f0101273:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101278:	8b 55 08             	mov    0x8(%ebp),%edx
f010127b:	c1 ea 0c             	shr    $0xc,%edx
f010127e:	c1 e2 03             	shl    $0x3,%edx
f0101281:	01 d0                	add    %edx,%eax
}
f0101283:	c9                   	leave  
f0101284:	c3                   	ret    

f0101285 <page2kva>:

static inline void*
page2kva(struct PageInfo *pp)
{
f0101285:	55                   	push   %ebp
f0101286:	89 e5                	mov    %esp,%ebp
f0101288:	83 ec 18             	sub    $0x18,%esp
	return KADDR(page2pa(pp));
f010128b:	8b 45 08             	mov    0x8(%ebp),%eax
f010128e:	89 04 24             	mov    %eax,(%esp)
f0101291:	e8 93 ff ff ff       	call   f0101229 <page2pa>
f0101296:	89 44 24 08          	mov    %eax,0x8(%esp)
f010129a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012a1:	00 
f01012a2:	c7 04 24 2b a0 10 f0 	movl   $0xf010a02b,(%esp)
f01012a9:	e8 39 ff ff ff       	call   f01011e7 <_kaddr>
}
f01012ae:	c9                   	leave  
f01012af:	c3                   	ret    

f01012b0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01012b0:	55                   	push   %ebp
f01012b1:	89 e5                	mov    %esp,%ebp
f01012b3:	53                   	push   %ebx
f01012b4:	83 ec 14             	sub    $0x14,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ba:	89 04 24             	mov    %eax,(%esp)
f01012bd:	e8 db 39 00 00       	call   f0104c9d <mc146818_read>
f01012c2:	89 c3                	mov    %eax,%ebx
f01012c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c7:	83 c0 01             	add    $0x1,%eax
f01012ca:	89 04 24             	mov    %eax,(%esp)
f01012cd:	e8 cb 39 00 00       	call   f0104c9d <mc146818_read>
f01012d2:	c1 e0 08             	shl    $0x8,%eax
f01012d5:	09 d8                	or     %ebx,%eax
}
f01012d7:	83 c4 14             	add    $0x14,%esp
f01012da:	5b                   	pop    %ebx
f01012db:	5d                   	pop    %ebp
f01012dc:	c3                   	ret    

f01012dd <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f01012dd:	55                   	push   %ebp
f01012de:	89 e5                	mov    %esp,%ebp
f01012e0:	83 ec 28             	sub    $0x28,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012e3:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01012ea:	e8 c1 ff ff ff       	call   f01012b0 <nvram_read>
f01012ef:	c1 e0 0a             	shl    $0xa,%eax
f01012f2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012f8:	85 c0                	test   %eax,%eax
f01012fa:	0f 48 c2             	cmovs  %edx,%eax
f01012fd:	c1 f8 0c             	sar    $0xc,%eax
f0101300:	a3 2c 42 29 f0       	mov    %eax,0xf029422c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101305:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010130c:	e8 9f ff ff ff       	call   f01012b0 <nvram_read>
f0101311:	c1 e0 0a             	shl    $0xa,%eax
f0101314:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010131a:	85 c0                	test   %eax,%eax
f010131c:	0f 48 c2             	cmovs  %edx,%eax
f010131f:	c1 f8 0c             	sar    $0xc,%eax
f0101322:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101325:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101329:	74 0f                	je     f010133a <i386_detect_memory+0x5d>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010132b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010132e:	05 00 01 00 00       	add    $0x100,%eax
f0101333:	a3 e8 7a 29 f0       	mov    %eax,0xf0297ae8
f0101338:	eb 0a                	jmp    f0101344 <i386_detect_memory+0x67>
	else
		npages = npages_basemem;
f010133a:	a1 2c 42 29 f0       	mov    0xf029422c,%eax
f010133f:	a3 e8 7a 29 f0       	mov    %eax,0xf0297ae8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101344:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101347:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010134a:	c1 e8 0a             	shr    $0xa,%eax
f010134d:	89 c1                	mov    %eax,%ecx
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010134f:	a1 2c 42 29 f0       	mov    0xf029422c,%eax
f0101354:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101357:	c1 e8 0a             	shr    $0xa,%eax
f010135a:	89 c2                	mov    %eax,%edx
		npages * PGSIZE / 1024,
f010135c:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f0101361:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101364:	c1 e8 0a             	shr    $0xa,%eax
f0101367:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010136b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010136f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101373:	c7 04 24 3c a0 10 f0 	movl   $0xf010a03c,(%esp)
f010137a:	e8 cf 3b 00 00       	call   f0104f4e <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f010137f:	c9                   	leave  
f0101380:	c3                   	ret    

f0101381 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101381:	55                   	push   %ebp
f0101382:	89 e5                	mov    %esp,%ebp
f0101384:	83 ec 38             	sub    $0x38,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101387:	a1 38 42 29 f0       	mov    0xf0294238,%eax
f010138c:	85 c0                	test   %eax,%eax
f010138e:	75 30                	jne    f01013c0 <boot_alloc+0x3f>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101390:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0101397:	b8 08 90 2d f0       	mov    $0xf02d9008,%eax
f010139c:	8d 50 ff             	lea    -0x1(%eax),%edx
f010139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013a2:	01 d0                	add    %edx,%eax
f01013a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01013a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01013aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01013af:	f7 75 f4             	divl   -0xc(%ebp)
f01013b2:	89 d0                	mov    %edx,%eax
f01013b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01013b7:	29 c2                	sub    %eax,%edx
f01013b9:	89 d0                	mov    %edx,%eax
f01013bb:	a3 38 42 29 f0       	mov    %eax,0xf0294238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01013c0:	a1 38 42 29 f0       	mov    0xf0294238,%eax
f01013c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char *nres = nextfree;
f01013c8:	a1 38 42 29 f0       	mov    0xf0294238,%eax
f01013cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
	nres = (char *)((uint32_t)nextfree + (uint32_t)ROUNDUP((char *)n,PGSIZE));
f01013d0:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
f01013d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013da:	8b 55 08             	mov    0x8(%ebp),%edx
f01013dd:	01 d0                	add    %edx,%eax
f01013df:	83 e8 01             	sub    $0x1,%eax
f01013e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01013e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01013ed:	f7 75 e4             	divl   -0x1c(%ebp)
f01013f0:	89 d0                	mov    %edx,%eax
f01013f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01013f5:	29 c2                	sub    %eax,%edx
f01013f7:	89 d0                	mov    %edx,%eax
f01013f9:	89 c2                	mov    %eax,%edx
f01013fb:	a1 38 42 29 f0       	mov    0xf0294238,%eax
f0101400:	01 d0                	add    %edx,%eax
f0101402:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(PADDR(result) > npages*PGSIZE){
f0101405:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101408:	89 44 24 08          	mov    %eax,0x8(%esp)
f010140c:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f0101413:	00 
f0101414:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010141b:	e8 8c fd ff ff       	call   f01011ac <_paddr>
f0101420:	8b 15 e8 7a 29 f0    	mov    0xf0297ae8,%edx
f0101426:	c1 e2 0c             	shl    $0xc,%edx
f0101429:	39 d0                	cmp    %edx,%eax
f010142b:	76 1c                	jbe    f0101449 <boot_alloc+0xc8>
		panic("OUT OF MEMORY!\n");
f010142d:	c7 44 24 08 84 a0 10 	movl   $0xf010a084,0x8(%esp)
f0101434:	f0 
f0101435:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f010143c:	00 
f010143d:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101444:	e8 86 ee ff ff       	call   f01002cf <_panic>
	}
	else{
		nextfree = nres;
f0101449:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010144c:	a3 38 42 29 f0       	mov    %eax,0xf0294238
	}
	return (void *)result;
f0101451:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
f0101454:	c9                   	leave  
f0101455:	c3                   	ret    

f0101456 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101456:	55                   	push   %ebp
f0101457:	89 e5                	mov    %esp,%ebp
f0101459:	53                   	push   %ebx
f010145a:	83 ec 34             	sub    $0x34,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f010145d:	e8 7b fe ff ff       	call   f01012dd <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101462:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
f0101469:	e8 13 ff ff ff       	call   f0101381 <boot_alloc>
f010146e:	a3 ec 7a 29 f0       	mov    %eax,0xf0297aec
	memset(kern_pgdir, 0, PGSIZE);
f0101473:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0101478:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010147f:	00 
f0101480:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101487:	00 
f0101488:	89 04 24             	mov    %eax,(%esp)
f010148b:	e8 75 75 00 00       	call   f0108a05 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101490:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0101495:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f010149b:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01014a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014a4:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014ab:	00 
f01014ac:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01014b3:	e8 f4 fc ff ff       	call   f01011ac <_paddr>
f01014b8:	83 c8 05             	or     $0x5,%eax
f01014bb:	89 03                	mov    %eax,(%ebx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = boot_alloc(npages*(sizeof(struct PageInfo)));
f01014bd:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f01014c2:	c1 e0 03             	shl    $0x3,%eax
f01014c5:	89 04 24             	mov    %eax,(%esp)
f01014c8:	e8 b4 fe ff ff       	call   f0101381 <boot_alloc>
f01014cd:	a3 f0 7a 29 f0       	mov    %eax,0xf0297af0
	memset(pages,0,npages*sizeof(struct PageInfo));
f01014d2:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f01014d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01014de:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f01014e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01014e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014ee:	00 
f01014ef:	89 04 24             	mov    %eax,(%esp)
f01014f2:	e8 0e 75 00 00       	call   f0108a05 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env));
f01014f7:	c7 04 24 00 f0 01 00 	movl   $0x1f000,(%esp)
f01014fe:	e8 7e fe ff ff       	call   f0101381 <boot_alloc>
f0101503:	a3 3c 42 29 f0       	mov    %eax,0xf029423c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101508:	e8 03 02 00 00       	call   f0101710 <page_init>

	check_page_free_list(1);
f010150d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101514:	e8 45 09 00 00       	call   f0101e5e <check_page_free_list>
	check_page_alloc();
f0101519:	e8 e4 0c 00 00       	call   f0102202 <check_page_alloc>
	check_page();
f010151e:	e8 29 17 00 00       	call   f0102c4c <check_page>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U | PTE_P);
f0101523:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101528:	89 44 24 08          	mov    %eax,0x8(%esp)
f010152c:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
f0101533:	00 
f0101534:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010153b:	e8 6c fc ff ff       	call   f01011ac <_paddr>
f0101540:	8b 15 ec 7a 29 f0    	mov    0xf0297aec,%edx
f0101546:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
f010154d:	00 
f010154e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101552:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101559:	00 
f010155a:	c7 44 24 04 00 00 00 	movl   $0xef000000,0x4(%esp)
f0101561:	ef 
f0101562:	89 14 24             	mov    %edx,(%esp)
f0101565:	e8 05 05 00 00       	call   f0101a6f <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,PTSIZE,PADDR(envs),PTE_U | PTE_P);
f010156a:	a1 3c 42 29 f0       	mov    0xf029423c,%eax
f010156f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101573:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f010157a:	00 
f010157b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101582:	e8 25 fc ff ff       	call   f01011ac <_paddr>
f0101587:	8b 15 ec 7a 29 f0    	mov    0xf0297aec,%edx
f010158d:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
f0101594:	00 
f0101595:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101599:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01015a0:	00 
f01015a1:	c7 44 24 04 00 00 c0 	movl   $0xeec00000,0x4(%esp)
f01015a8:	ee 
f01015a9:	89 14 24             	mov    %edx,(%esp)
f01015ac:	e8 be 04 00 00       	call   f0101a6f <boot_map_region>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_P | PTE_W);
f01015b1:	c7 44 24 08 00 d0 11 	movl   $0xf011d000,0x8(%esp)
f01015b8:	f0 
f01015b9:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f01015c0:	00 
f01015c1:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01015c8:	e8 df fb ff ff       	call   f01011ac <_paddr>
f01015cd:	8b 15 ec 7a 29 f0    	mov    0xf0297aec,%edx
f01015d3:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f01015da:	00 
f01015db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015df:	c7 44 24 08 00 80 00 	movl   $0x8000,0x8(%esp)
f01015e6:	00 
f01015e7:	c7 44 24 04 00 80 ff 	movl   $0xefff8000,0x4(%esp)
f01015ee:	ef 
f01015ef:	89 14 24             	mov    %edx,(%esp)
f01015f2:	e8 78 04 00 00       	call   f0101a6f <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KERNBASE,-KERNBASE,0x0,PTE_P | PTE_W);
f01015f7:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01015fc:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f0101603:	00 
f0101604:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010160b:	00 
f010160c:	c7 44 24 08 00 00 00 	movl   $0x10000000,0x8(%esp)
f0101613:	10 
f0101614:	c7 44 24 04 00 00 00 	movl   $0xf0000000,0x4(%esp)
f010161b:	f0 
f010161c:	89 04 24             	mov    %eax,(%esp)
f010161f:	e8 4b 04 00 00       	call   f0101a6f <boot_map_region>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();
f0101624:	e8 65 00 00 00       	call   f010168e <mem_init_mp>

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
f0101629:	e8 86 11 00 00       	call   f01027b4 <check_kern_pgdir>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010162e:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0101633:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101637:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f010163e:	00 
f010163f:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101646:	e8 61 fb ff ff       	call   f01011ac <_paddr>
f010164b:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101651:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0101654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010165b:	e8 fe 07 00 00       	call   f0101e5e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101660:	0f 20 c0             	mov    %cr0,%eax
f0101663:	89 45 ec             	mov    %eax,-0x14(%ebp)
	return val;
f0101666:	8b 45 ec             	mov    -0x14(%ebp),%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
f0101669:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010166c:	81 4d f4 23 00 05 80 	orl    $0x80050023,-0xc(%ebp)
	cr0 &= ~(CR0_TS|CR0_EM);
f0101673:	83 65 f4 f3          	andl   $0xfffffff3,-0xc(%ebp)
f0101677:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010167a:	89 45 e8             	mov    %eax,-0x18(%ebp)
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010167d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101680:	0f 22 c0             	mov    %eax,%cr0
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0101683:	e8 3b 28 00 00       	call   f0103ec3 <check_page_installed_pgdir>
}
f0101688:	83 c4 34             	add    $0x34,%esp
f010168b:	5b                   	pop    %ebx
f010168c:	5d                   	pop    %ebp
f010168d:	c3                   	ret    

f010168e <mem_init_mp>:
// Modify mappings in kern_pgdir to support SMP
//   - Map the per-CPU stacks in the region [KSTACKTOP-PTSIZE, KSTACKTOP)
//
static void
mem_init_mp(void)
{
f010168e:	55                   	push   %ebp
f010168f:	89 e5                	mov    %esp,%ebp
f0101691:	83 ec 38             	sub    $0x38,%esp
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for(i = 0; i < NCPU; i++){
f0101694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010169b:	eb 6b                	jmp    f0101708 <mem_init_mp+0x7a>
		size_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
f010169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01016a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01016a5:	29 d0                	sub    %edx,%eax
f01016a7:	c1 e0 10             	shl    $0x10,%eax
f01016aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016af:	89 45 f0             	mov    %eax,-0x10(%ebp)
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W | PTE_P);
f01016b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01016b5:	c1 e0 0f             	shl    $0xf,%eax
f01016b8:	05 00 90 29 f0       	add    $0xf0299000,%eax
f01016bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016c1:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f01016c8:	00 
f01016c9:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01016d0:	e8 d7 fa ff ff       	call   f01011ac <_paddr>
f01016d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01016d8:	8d 8a 00 80 ff ff    	lea    -0x8000(%edx),%ecx
f01016de:	8b 15 ec 7a 29 f0    	mov    0xf0297aec,%edx
f01016e4:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f01016eb:	00 
f01016ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016f0:	c7 44 24 08 00 80 00 	movl   $0x8000,0x8(%esp)
f01016f7:	00 
f01016f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01016fc:	89 14 24             	mov    %edx,(%esp)
f01016ff:	e8 6b 03 00 00       	call   f0101a6f <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for(i = 0; i < NCPU; i++){
f0101704:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101708:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
f010170c:	7e 8f                	jle    f010169d <mem_init_mp+0xf>
		size_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE , KSTKSIZE, PADDR(percpu_kstacks[i]),PTE_W | PTE_P);
	}
}
f010170e:	c9                   	leave  
f010170f:	c3                   	ret    

f0101710 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101710:	55                   	push   %ebp
f0101711:	89 e5                	mov    %esp,%ebp
f0101713:	83 ec 28             	sub    $0x28,%esp
	// for (i = 0; i < npages; i++) {
	// 	pages[i].pp_ref = 0;
	// 	pages[i].pp_link = page_free_list;
	// 	page_free_list = &pages[i];
	// }
	pages[0].pp_ref = 1;
f0101716:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f010171b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0101721:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101726:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	size_t mpentry_paddr_pg = PGNUM(MPENTRY_PADDR);
f010172c:	c7 45 f0 07 00 00 00 	movl   $0x7,-0x10(%ebp)
	for (i = 1; i<npages_basemem; i++){
f0101733:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
f010173a:	eb 45                	jmp    f0101781 <page_init+0x71>
		if(i != mpentry_paddr_pg){
f010173c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010173f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0101742:	74 39                	je     f010177d <page_init+0x6d>
			pages[i].pp_ref = 0;
f0101744:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101749:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010174c:	c1 e2 03             	shl    $0x3,%edx
f010174f:	01 d0                	add    %edx,%eax
f0101751:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0101757:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f010175c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010175f:	c1 e2 03             	shl    $0x3,%edx
f0101762:	01 c2                	add    %eax,%edx
f0101764:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0101769:	89 02                	mov    %eax,(%edx)
			page_free_list = &pages[i];
f010176b:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101770:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101773:	c1 e2 03             	shl    $0x3,%edx
f0101776:	01 d0                	add    %edx,%eax
f0101778:	a3 30 42 29 f0       	mov    %eax,0xf0294230
	// 	page_free_list = &pages[i];
	// }
	pages[0].pp_ref = 1;
	pages[0].pp_link = NULL;
	size_t mpentry_paddr_pg = PGNUM(MPENTRY_PADDR);
	for (i = 1; i<npages_basemem; i++){
f010177d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101781:	a1 2c 42 29 f0       	mov    0xf029422c,%eax
f0101786:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101789:	72 b1                	jb     f010173c <page_init+0x2c>
			page_free_list = &pages[i];
		}
	}
	// cprintf("npages_basemem : %d\n", npages_basemem);
	// cprintf("PGNUM(MPENTRY_PADDR): %d\n",PGNUM(MPENTRY_PADDR));
	pages[mpentry_paddr_pg].pp_ref = 1;
f010178b:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101790:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101793:	c1 e2 03             	shl    $0x3,%edx
f0101796:	01 d0                	add    %edx,%eax
f0101798:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[mpentry_paddr_pg].pp_link = NULL;
f010179e:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f01017a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01017a6:	c1 e2 03             	shl    $0x3,%edx
f01017a9:	01 d0                	add    %edx,%eax
f01017ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	char *next_free = boot_alloc(0);
f01017b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017b8:	e8 c4 fb ff ff       	call   f0101381 <boot_alloc>
f01017bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (i = PGNUM(IOPHYSMEM);i<PGNUM(PADDR(next_free)); i++){
f01017c0:	c7 45 f4 a0 00 00 00 	movl   $0xa0,-0xc(%ebp)
f01017c7:	eb 2a                	jmp    f01017f3 <page_init+0xe3>
		pages[i].pp_ref = 1;
f01017c9:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f01017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017d1:	c1 e2 03             	shl    $0x3,%edx
f01017d4:	01 d0                	add    %edx,%eax
f01017d6:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = NULL;
f01017dc:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f01017e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017e4:	c1 e2 03             	shl    $0x3,%edx
f01017e7:	01 d0                	add    %edx,%eax
f01017e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	// cprintf("npages_basemem : %d\n", npages_basemem);
	// cprintf("PGNUM(MPENTRY_PADDR): %d\n",PGNUM(MPENTRY_PADDR));
	pages[mpentry_paddr_pg].pp_ref = 1;
	pages[mpentry_paddr_pg].pp_link = NULL;
	char *next_free = boot_alloc(0);
	for (i = PGNUM(IOPHYSMEM);i<PGNUM(PADDR(next_free)); i++){
f01017ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01017f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017fa:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0101801:	00 
f0101802:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101809:	e8 9e f9 ff ff       	call   f01011ac <_paddr>
f010180e:	c1 e8 0c             	shr    $0xc,%eax
f0101811:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101814:	77 b3                	ja     f01017c9 <page_init+0xb9>
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for(i = PGNUM(PADDR(next_free)); i<npages; i++){
f0101816:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101819:	89 44 24 08          	mov    %eax,0x8(%esp)
f010181d:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f0101824:	00 
f0101825:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010182c:	e8 7b f9 ff ff       	call   f01011ac <_paddr>
f0101831:	c1 e8 0c             	shr    $0xc,%eax
f0101834:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101837:	eb 3d                	jmp    f0101876 <page_init+0x166>
		pages[i].pp_ref = 0;
f0101839:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f010183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101841:	c1 e2 03             	shl    $0x3,%edx
f0101844:	01 d0                	add    %edx,%eax
f0101846:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f010184c:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101851:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101854:	c1 e2 03             	shl    $0x3,%edx
f0101857:	01 c2                	add    %eax,%edx
f0101859:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f010185e:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f0101860:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101865:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101868:	c1 e2 03             	shl    $0x3,%edx
f010186b:	01 d0                	add    %edx,%eax
f010186d:	a3 30 42 29 f0       	mov    %eax,0xf0294230
	char *next_free = boot_alloc(0);
	for (i = PGNUM(IOPHYSMEM);i<PGNUM(PADDR(next_free)); i++){
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for(i = PGNUM(PADDR(next_free)); i<npages; i++){
f0101872:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101876:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f010187b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f010187e:	72 b9                	jb     f0101839 <page_init+0x129>
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0101880:	c9                   	leave  
f0101881:	c3                   	ret    

f0101882 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101882:	55                   	push   %ebp
f0101883:	89 e5                	mov    %esp,%ebp
f0101885:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	if(!page_free_list){
f0101888:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f010188d:	85 c0                	test   %eax,%eax
f010188f:	75 07                	jne    f0101898 <page_alloc+0x16>
		return NULL;
f0101891:	b8 00 00 00 00       	mov    $0x0,%eax
f0101896:	eb 4b                	jmp    f01018e3 <page_alloc+0x61>
	}
	struct PageInfo *pp = page_free_list;
f0101898:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f010189d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	page_free_list = pp->pp_link;
f01018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018a3:	8b 00                	mov    (%eax),%eax
f01018a5:	a3 30 42 29 f0       	mov    %eax,0xf0294230
	if(alloc_flags & ALLOC_ZERO){
f01018aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01018ad:	83 e0 01             	and    $0x1,%eax
f01018b0:	85 c0                	test   %eax,%eax
f01018b2:	74 23                	je     f01018d7 <page_alloc+0x55>
		memset(page2kva(pp),0,PGSIZE);
f01018b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018b7:	89 04 24             	mov    %eax,(%esp)
f01018ba:	e8 c6 f9 ff ff       	call   f0101285 <page2kva>
f01018bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018c6:	00 
f01018c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018ce:	00 
f01018cf:	89 04 24             	mov    %eax,(%esp)
f01018d2:	e8 2e 71 00 00       	call   f0108a05 <memset>
	}
	pp->pp_link = NULL;
f01018d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return pp;
f01018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01018e3:	c9                   	leave  
f01018e4:	c3                   	ret    

f01018e5 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01018e5:	55                   	push   %ebp
f01018e6:	89 e5                	mov    %esp,%ebp
f01018e8:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0){
f01018eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01018ee:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01018f2:	66 85 c0             	test   %ax,%ax
f01018f5:	74 1c                	je     f0101913 <page_free+0x2e>
		panic("pp_ref of page not null!\n");
f01018f7:	c7 44 24 08 94 a0 10 	movl   $0xf010a094,0x8(%esp)
f01018fe:	f0 
f01018ff:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0101906:	00 
f0101907:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010190e:	e8 bc e9 ff ff       	call   f01002cf <_panic>
	}
	else if(pp->pp_link){
f0101913:	8b 45 08             	mov    0x8(%ebp),%eax
f0101916:	8b 00                	mov    (%eax),%eax
f0101918:	85 c0                	test   %eax,%eax
f010191a:	74 1c                	je     f0101938 <page_free+0x53>
		panic("pp_link of page not null!\n");
f010191c:	c7 44 24 08 ae a0 10 	movl   $0xf010a0ae,0x8(%esp)
f0101923:	f0 
f0101924:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f010192b:	00 
f010192c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101933:	e8 97 e9 ff ff       	call   f01002cf <_panic>
	}
	else{
		pp->pp_link = page_free_list;
f0101938:	8b 15 30 42 29 f0    	mov    0xf0294230,%edx
f010193e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101941:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0101943:	8b 45 08             	mov    0x8(%ebp),%eax
f0101946:	a3 30 42 29 f0       	mov    %eax,0xf0294230
	}
}
f010194b:	c9                   	leave  
f010194c:	c3                   	ret    

f010194d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010194d:	55                   	push   %ebp
f010194e:	89 e5                	mov    %esp,%ebp
f0101950:	83 ec 18             	sub    $0x18,%esp
	if (--pp->pp_ref == 0)
f0101953:	8b 45 08             	mov    0x8(%ebp),%eax
f0101956:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010195a:	8d 50 ff             	lea    -0x1(%eax),%edx
f010195d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101960:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101964:	8b 45 08             	mov    0x8(%ebp),%eax
f0101967:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010196b:	66 85 c0             	test   %ax,%ax
f010196e:	75 0b                	jne    f010197b <page_decref+0x2e>
		page_free(pp);
f0101970:	8b 45 08             	mov    0x8(%ebp),%eax
f0101973:	89 04 24             	mov    %eax,(%esp)
f0101976:	e8 6a ff ff ff       	call   f01018e5 <page_free>
}
f010197b:	c9                   	leave  
f010197c:	c3                   	ret    

f010197d <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010197d:	55                   	push   %ebp
f010197e:	89 e5                	mov    %esp,%ebp
f0101980:	53                   	push   %ebx
f0101981:	83 ec 24             	sub    $0x24,%esp
	// Fill this function in
	pte_t pte_pt = pgdir[PDX(va)];
f0101984:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101987:	c1 e8 16             	shr    $0x16,%eax
f010198a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101991:	8b 45 08             	mov    0x8(%ebp),%eax
f0101994:	01 d0                	add    %edx,%eax
f0101996:	8b 00                	mov    (%eax),%eax
f0101998:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!(pte_pt & PTE_P) && !create) return NULL;
f010199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010199e:	83 e0 01             	and    $0x1,%eax
f01019a1:	85 c0                	test   %eax,%eax
f01019a3:	75 10                	jne    f01019b5 <pgdir_walk+0x38>
f01019a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01019a9:	75 0a                	jne    f01019b5 <pgdir_walk+0x38>
f01019ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01019b0:	e9 b4 00 00 00       	jmp    f0101a69 <pgdir_walk+0xec>
	else if(!(pte_pt & PTE_P) && create){
f01019b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01019b8:	83 e0 01             	and    $0x1,%eax
f01019bb:	85 c0                	test   %eax,%eax
f01019bd:	75 70                	jne    f0101a2f <pgdir_walk+0xb2>
f01019bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01019c3:	74 6a                	je     f0101a2f <pgdir_walk+0xb2>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01019c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019cc:	e8 b1 fe ff ff       	call   f0101882 <page_alloc>
f01019d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if(!pp) return NULL;
f01019d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01019d8:	75 0a                	jne    f01019e4 <pgdir_walk+0x67>
f01019da:	b8 00 00 00 00       	mov    $0x0,%eax
f01019df:	e9 85 00 00 00       	jmp    f0101a69 <pgdir_walk+0xec>
		pp->pp_ref++;
f01019e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019e7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01019eb:	8d 50 01             	lea    0x1(%eax),%edx
f01019ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019f1:	66 89 50 04          	mov    %dx,0x4(%eax)
		// memset(page2kva(pp),0,PGSIZE);
		pgdir[PDX(va)] = page2pa(pp) | PTE_P | PTE_U | PTE_W;
f01019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019f8:	c1 e8 16             	shr    $0x16,%eax
f01019fb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101a02:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a05:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
f0101a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101a0b:	89 04 24             	mov    %eax,(%esp)
f0101a0e:	e8 16 f8 ff ff       	call   f0101229 <page2pa>
f0101a13:	83 c8 07             	or     $0x7,%eax
f0101a16:	89 03                	mov    %eax,(%ebx)
		pte_pt = pgdir[PDX(va)];
f0101a18:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a1b:	c1 e8 16             	shr    $0x16,%eax
f0101a1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101a25:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a28:	01 d0                	add    %edx,%eax
f0101a2a:	8b 00                	mov    (%eax),%eax
f0101a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	pte_t *res = KADDR(PTE_ADDR(pte_pt));
f0101a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101a37:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a3b:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0101a42:	00 
f0101a43:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101a4a:	e8 98 f7 ff ff       	call   f01011e7 <_kaddr>
f0101a4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	return (res + PTX(va));
f0101a52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a55:	c1 e8 0c             	shr    $0xc,%eax
f0101a58:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101a5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101a64:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a67:	01 d0                	add    %edx,%eax
}
f0101a69:	83 c4 24             	add    $0x24,%esp
f0101a6c:	5b                   	pop    %ebx
f0101a6d:	5d                   	pop    %ebp
f0101a6e:	c3                   	ret    

f0101a6f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101a6f:	55                   	push   %ebp
f0101a70:	89 e5                	mov    %esp,%ebp
f0101a72:	83 ec 28             	sub    $0x28,%esp
	assert(size%PGSIZE == 0);
f0101a75:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a78:	25 ff 0f 00 00       	and    $0xfff,%eax
f0101a7d:	85 c0                	test   %eax,%eax
f0101a7f:	74 24                	je     f0101aa5 <boot_map_region+0x36>
f0101a81:	c7 44 24 0c c9 a0 10 	movl   $0xf010a0c9,0xc(%esp)
f0101a88:	f0 
f0101a89:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0101a90:	f0 
f0101a91:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0101a98:	00 
f0101a99:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101aa0:	e8 2a e8 ff ff       	call   f01002cf <_panic>
	int i=0;
f0101aa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for(i = 0; i<size/PGSIZE; i++){
f0101aac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0101ab3:	eb 47                	jmp    f0101afc <boot_map_region+0x8d>
		pte_t *pte_pt = pgdir_walk(pgdir,(void *)(va + i*PGSIZE),1);
f0101ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ab8:	c1 e0 0c             	shl    $0xc,%eax
f0101abb:	89 c2                	mov    %eax,%edx
f0101abd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ac0:	01 d0                	add    %edx,%eax
f0101ac2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101ac9:	00 
f0101aca:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ace:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ad1:	89 04 24             	mov    %eax,(%esp)
f0101ad4:	e8 a4 fe ff ff       	call   f010197d <pgdir_walk>
f0101ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
		*pte_pt = (pa + i*PGSIZE) | perm | PTE_P;
f0101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101adf:	c1 e0 0c             	shl    $0xc,%eax
f0101ae2:	89 c2                	mov    %eax,%edx
f0101ae4:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ae7:	01 c2                	add    %eax,%edx
f0101ae9:	8b 45 18             	mov    0x18(%ebp),%eax
f0101aec:	09 d0                	or     %edx,%eax
f0101aee:	83 c8 01             	or     $0x1,%eax
f0101af1:	89 c2                	mov    %eax,%edx
f0101af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101af6:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	assert(size%PGSIZE == 0);
	int i=0;
	for(i = 0; i<size/PGSIZE; i++){
f0101af8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101aff:	8b 55 10             	mov    0x10(%ebp),%edx
f0101b02:	c1 ea 0c             	shr    $0xc,%edx
f0101b05:	39 d0                	cmp    %edx,%eax
f0101b07:	72 ac                	jb     f0101ab5 <boot_map_region+0x46>
		pte_t *pte_pt = pgdir_walk(pgdir,(void *)(va + i*PGSIZE),1);
		*pte_pt = (pa + i*PGSIZE) | perm | PTE_P;
	}
	// Fill this function in
}
f0101b09:	c9                   	leave  
f0101b0a:	c3                   	ret    

f0101b0b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101b0b:	55                   	push   %ebp
f0101b0c:	89 e5                	mov    %esp,%ebp
f0101b0e:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	pte_t *ptable_entry = pgdir_walk(pgdir,va,1);
f0101b11:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101b18:	00 
f0101b19:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b20:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b23:	89 04 24             	mov    %eax,(%esp)
f0101b26:	e8 52 fe ff ff       	call   f010197d <pgdir_walk>
f0101b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(ptable_entry){
f0101b2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101b32:	74 62                	je     f0101b96 <page_insert+0x8b>
		pp->pp_ref++;
f0101b34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b37:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0101b3b:	8d 50 01             	lea    0x1(%eax),%edx
f0101b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b41:	66 89 50 04          	mov    %dx,0x4(%eax)
		if((*ptable_entry) & PTE_P){
f0101b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b48:	8b 00                	mov    (%eax),%eax
f0101b4a:	83 e0 01             	and    $0x1,%eax
f0101b4d:	85 c0                	test   %eax,%eax
f0101b4f:	74 24                	je     f0101b75 <page_insert+0x6a>
			page_remove(pgdir,va);
f0101b51:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b58:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b5b:	89 04 24             	mov    %eax,(%esp)
f0101b5e:	e8 8d 00 00 00       	call   f0101bf0 <page_remove>
			tlb_invalidate(pgdir,va);
f0101b63:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b6d:	89 04 24             	mov    %eax,(%esp)
f0101b70:	e8 cb 00 00 00       	call   f0101c40 <tlb_invalidate>
		}
		*ptable_entry = page2pa(pp) | perm | PTE_P;
f0101b75:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b78:	89 04 24             	mov    %eax,(%esp)
f0101b7b:	e8 a9 f6 ff ff       	call   f0101229 <page2pa>
f0101b80:	8b 55 14             	mov    0x14(%ebp),%edx
f0101b83:	09 d0                	or     %edx,%eax
f0101b85:	83 c8 01             	or     $0x1,%eax
f0101b88:	89 c2                	mov    %eax,%edx
f0101b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b8d:	89 10                	mov    %edx,(%eax)
		return 0;
f0101b8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b94:	eb 05                	jmp    f0101b9b <page_insert+0x90>
	}
	return -E_NO_MEM;
f0101b96:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0101b9b:	c9                   	leave  
f0101b9c:	c3                   	ret    

f0101b9d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101b9d:	55                   	push   %ebp
f0101b9e:	89 e5                	mov    %esp,%ebp
f0101ba0:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	pte_t *ptable_entry = pgdir_walk(pgdir,va,0);
f0101ba3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101baa:	00 
f0101bab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bb5:	89 04 24             	mov    %eax,(%esp)
f0101bb8:	e8 c0 fd ff ff       	call   f010197d <pgdir_walk>
f0101bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!ptable_entry) return NULL;
f0101bc0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101bc4:	75 07                	jne    f0101bcd <page_lookup+0x30>
f0101bc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0101bcb:	eb 21                	jmp    f0101bee <page_lookup+0x51>
	struct PageInfo *pp = pa2page(*ptable_entry);
f0101bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101bd0:	8b 00                	mov    (%eax),%eax
f0101bd2:	89 04 24             	mov    %eax,(%esp)
f0101bd5:	e8 66 f6 ff ff       	call   f0101240 <pa2page>
f0101bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(pte_store){
f0101bdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101be1:	74 08                	je     f0101beb <page_lookup+0x4e>
		*pte_store = ptable_entry;
f0101be3:	8b 45 10             	mov    0x10(%ebp),%eax
f0101be6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101be9:	89 10                	mov    %edx,(%eax)
	}
	return pp;
f0101beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0101bee:	c9                   	leave  
f0101bef:	c3                   	ret    

f0101bf0 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101bf0:	55                   	push   %ebp
f0101bf1:	89 e5                	mov    %esp,%ebp
f0101bf3:	83 ec 28             	sub    $0x28,%esp
	pte_t *ptable_entry;
	struct PageInfo *pp = page_lookup(pgdir,va,&ptable_entry);
f0101bf6:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c04:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c07:	89 04 24             	mov    %eax,(%esp)
f0101c0a:	e8 8e ff ff ff       	call   f0101b9d <page_lookup>
f0101c0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(!pp) return;
f0101c12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101c16:	74 26                	je     f0101c3e <page_remove+0x4e>
	page_decref(pp);
f0101c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c1b:	89 04 24             	mov    %eax,(%esp)
f0101c1e:	e8 2a fd ff ff       	call   f010194d <page_decref>
	*ptable_entry = 0;
f0101c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101c26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir,va);
f0101c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c33:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c36:	89 04 24             	mov    %eax,(%esp)
f0101c39:	e8 02 00 00 00       	call   f0101c40 <tlb_invalidate>
	// Fill this function in
}
f0101c3e:	c9                   	leave  
f0101c3f:	c3                   	ret    

f0101c40 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101c40:	55                   	push   %ebp
f0101c41:	89 e5                	mov    %esp,%ebp
f0101c43:	83 ec 18             	sub    $0x18,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101c46:	e8 83 78 00 00       	call   f01094ce <cpunum>
f0101c4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c4e:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0101c53:	8b 00                	mov    (%eax),%eax
f0101c55:	85 c0                	test   %eax,%eax
f0101c57:	74 17                	je     f0101c70 <tlb_invalidate+0x30>
f0101c59:	e8 70 78 00 00       	call   f01094ce <cpunum>
f0101c5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c61:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0101c66:	8b 00                	mov    (%eax),%eax
f0101c68:	8b 40 60             	mov    0x60(%eax),%eax
f0101c6b:	3b 45 08             	cmp    0x8(%ebp),%eax
f0101c6e:	75 0c                	jne    f0101c7c <tlb_invalidate+0x3c>
f0101c70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c79:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101c7c:	c9                   	leave  
f0101c7d:	c3                   	ret    

f0101c7e <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101c7e:	55                   	push   %ebp
f0101c7f:	89 e5                	mov    %esp,%ebp
f0101c81:	83 ec 38             	sub    $0x38,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t aligned_size = ROUNDUP(size,PGSIZE);
f0101c84:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0101c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101c91:	01 d0                	add    %edx,%eax
f0101c93:	83 e8 01             	sub    $0x1,%eax
f0101c96:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101c9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ca1:	f7 75 f4             	divl   -0xc(%ebp)
f0101ca4:	89 d0                	mov    %edx,%eax
f0101ca6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101ca9:	29 c2                	sub    %eax,%edx
f0101cab:	89 d0                	mov    %edx,%eax
f0101cad:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(aligned_size + base > MMIOLIM) panic("overflow in mmio_map_region");
f0101cb0:	8b 15 5c 75 12 f0    	mov    0xf012755c,%edx
f0101cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101cb9:	01 d0                	add    %edx,%eax
f0101cbb:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101cc0:	76 1c                	jbe    f0101cde <mmio_map_region+0x60>
f0101cc2:	c7 44 24 08 ef a0 10 	movl   $0xf010a0ef,0x8(%esp)
f0101cc9:	f0 
f0101cca:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
f0101cd1:	00 
f0101cd2:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101cd9:	e8 f1 e5 ff ff       	call   f01002cf <_panic>

	boot_map_region(kern_pgdir, base, aligned_size, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101cde:	8b 15 5c 75 12 f0    	mov    0xf012755c,%edx
f0101ce4:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0101ce9:	c7 44 24 10 1a 00 00 	movl   $0x1a,0x10(%esp)
f0101cf0:	00 
f0101cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101cf4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101cf8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101cfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101cff:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d03:	89 04 24             	mov    %eax,(%esp)
f0101d06:	e8 64 fd ff ff       	call   f0101a6f <boot_map_region>
	uintptr_t old_base = base;
f0101d0b:	a1 5c 75 12 f0       	mov    0xf012755c,%eax
f0101d10:	89 45 e8             	mov    %eax,-0x18(%ebp)
	base += aligned_size;
f0101d13:	8b 15 5c 75 12 f0    	mov    0xf012755c,%edx
f0101d19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d1c:	01 d0                	add    %edx,%eax
f0101d1e:	a3 5c 75 12 f0       	mov    %eax,0xf012755c
	// panic("mmio_map_region not implemented");
	return (void *)old_base;
f0101d23:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
f0101d26:	c9                   	leave  
f0101d27:	c3                   	ret    

f0101d28 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101d28:	55                   	push   %ebp
f0101d29:	89 e5                	mov    %esp,%ebp
f0101d2b:	83 ec 38             	sub    $0x38,%esp
	// LAB 3: Your code here.
	cprintf("lengthhhhH: %d\n", len);
f0101d2e:	8b 45 10             	mov    0x10(%ebp),%eax
f0101d31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d35:	c7 04 24 0b a1 10 f0 	movl   $0xf010a10b,(%esp)
f0101d3c:	e8 0d 32 00 00       	call   f0104f4e <cprintf>
	pte_t *ptable_entry;
	uint32_t aligned_va = ROUNDDOWN((uint32_t)va,PGSIZE);
f0101d41:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d44:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101d4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
f0101d52:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0101d59:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101d5c:	8b 45 10             	mov    0x10(%ebp),%eax
f0101d5f:	01 c2                	add    %eax,%edx
f0101d61:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d64:	01 d0                	add    %edx,%eax
f0101d66:	83 e8 01             	sub    $0x1,%eax
f0101d69:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101d6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d6f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d74:	f7 75 ec             	divl   -0x14(%ebp)
f0101d77:	89 d0                	mov    %edx,%eax
f0101d79:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101d7c:	29 c2                	sub    %eax,%edx
f0101d7e:	89 d0                	mov    %edx,%eax
f0101d80:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;aligned_va < (uint32_t)va + len; aligned_va += PGSIZE){
f0101d83:	eb 6b                	jmp    f0101df0 <user_mem_check+0xc8>
		page_lookup(env->env_pgdir,(void *)aligned_va, &ptable_entry);
f0101d85:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101d88:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d8b:	8b 40 60             	mov    0x60(%eax),%eax
f0101d8e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101d91:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101d95:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d99:	89 04 24             	mov    %eax,(%esp)
f0101d9c:	e8 fc fd ff ff       	call   f0101b9d <page_lookup>
		if(!ptable_entry || aligned_va > ULIM || (((uint32_t)*ptable_entry & (perm | PTE_P)) != (perm | PTE_P))){
f0101da1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101da4:	85 c0                	test   %eax,%eax
f0101da6:	74 20                	je     f0101dc8 <user_mem_check+0xa0>
f0101da8:	81 7d f4 00 00 80 ef 	cmpl   $0xef800000,-0xc(%ebp)
f0101daf:	77 17                	ja     f0101dc8 <user_mem_check+0xa0>
f0101db1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101db4:	8b 10                	mov    (%eax),%edx
f0101db6:	8b 45 14             	mov    0x14(%ebp),%eax
f0101db9:	83 c8 01             	or     $0x1,%eax
f0101dbc:	21 c2                	and    %eax,%edx
f0101dbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101dc1:	83 c8 01             	or     $0x1,%eax
f0101dc4:	39 c2                	cmp    %eax,%edx
f0101dc6:	74 21                	je     f0101de9 <user_mem_check+0xc1>
			if(aligned_va > (uint32_t)va) user_mem_check_addr = (uintptr_t)aligned_va;
f0101dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101dcb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101dce:	73 0a                	jae    f0101dda <user_mem_check+0xb2>
f0101dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101dd3:	a3 34 42 29 f0       	mov    %eax,0xf0294234
f0101dd8:	eb 08                	jmp    f0101de2 <user_mem_check+0xba>
			else user_mem_check_addr = (uintptr_t)va;
f0101dda:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ddd:	a3 34 42 29 f0       	mov    %eax,0xf0294234
			return -E_FAULT;
f0101de2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101de7:	eb 19                	jmp    f0101e02 <user_mem_check+0xda>
	// LAB 3: Your code here.
	cprintf("lengthhhhH: %d\n", len);
	pte_t *ptable_entry;
	uint32_t aligned_va = ROUNDDOWN((uint32_t)va,PGSIZE);
	uint32_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
	for(;aligned_va < (uint32_t)va + len; aligned_va += PGSIZE){
f0101de9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0101df0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101df3:	8b 45 10             	mov    0x10(%ebp),%eax
f0101df6:	01 d0                	add    %edx,%eax
f0101df8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101dfb:	77 88                	ja     f0101d85 <user_mem_check+0x5d>
			else user_mem_check_addr = (uintptr_t)va;
			return -E_FAULT;
		}
	}

	return 0;
f0101dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101e02:	c9                   	leave  
f0101e03:	c3                   	ret    

f0101e04 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101e04:	55                   	push   %ebp
f0101e05:	89 e5                	mov    %esp,%ebp
f0101e07:	83 ec 18             	sub    $0x18,%esp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101e0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0101e0d:	83 c8 04             	or     $0x4,%eax
f0101e10:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e14:	8b 45 10             	mov    0x10(%ebp),%eax
f0101e17:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101e1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e22:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e25:	89 04 24             	mov    %eax,(%esp)
f0101e28:	e8 fb fe ff ff       	call   f0101d28 <user_mem_check>
f0101e2d:	85 c0                	test   %eax,%eax
f0101e2f:	79 2b                	jns    f0101e5c <user_mem_assert+0x58>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101e31:	8b 15 34 42 29 f0    	mov    0xf0294234,%edx
f0101e37:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e3a:	8b 40 48             	mov    0x48(%eax),%eax
f0101e3d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101e41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e45:	c7 04 24 1c a1 10 f0 	movl   $0xf010a11c,(%esp)
f0101e4c:	e8 fd 30 00 00       	call   f0104f4e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101e51:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e54:	89 04 24             	mov    %eax,(%esp)
f0101e57:	e8 8b 2c 00 00       	call   f0104ae7 <env_destroy>
	}
}
f0101e5c:	c9                   	leave  
f0101e5d:	c3                   	ret    

f0101e5e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101e5e:	55                   	push   %ebp
f0101e5f:	89 e5                	mov    %esp,%ebp
f0101e61:	83 ec 58             	sub    $0x58,%esp
f0101e64:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e67:	88 45 c4             	mov    %al,-0x3c(%ebp)
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101e6a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0101e6e:	74 07                	je     f0101e77 <check_page_free_list+0x19>
f0101e70:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e75:	eb 05                	jmp    f0101e7c <check_page_free_list+0x1e>
f0101e77:	b8 00 04 00 00       	mov    $0x400,%eax
f0101e7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101e7f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101e86:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	char *first_free_page;

	if (!page_free_list)
f0101e8d:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0101e92:	85 c0                	test   %eax,%eax
f0101e94:	75 1c                	jne    f0101eb2 <check_page_free_list+0x54>
		panic("'page_free_list' is a null pointer!");
f0101e96:	c7 44 24 08 54 a1 10 	movl   $0xf010a154,0x8(%esp)
f0101e9d:	f0 
f0101e9e:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f0101ea5:	00 
f0101ea6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101ead:	e8 1d e4 ff ff       	call   f01002cf <_panic>

	if (only_low_memory) {
f0101eb2:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0101eb6:	74 6d                	je     f0101f25 <check_page_free_list+0xc7>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101eb8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101ebb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ebe:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101ec1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101ec4:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0101ec9:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101ecc:	eb 38                	jmp    f0101f06 <check_page_free_list+0xa8>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ed1:	89 04 24             	mov    %eax,(%esp)
f0101ed4:	e8 50 f3 ff ff       	call   f0101229 <page2pa>
f0101ed9:	c1 e8 16             	shr    $0x16,%eax
f0101edc:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101edf:	0f 93 c0             	setae  %al
f0101ee2:	0f b6 c0             	movzbl %al,%eax
f0101ee5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			*tp[pagetype] = pp;
f0101ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101eeb:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
f0101eef:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101ef2:	89 10                	mov    %edx,(%eax)
			tp[pagetype] = &pp->pp_link;
f0101ef4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101ef7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101efa:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f01:	8b 00                	mov    (%eax),%eax
f0101f03:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101f0a:	75 c2                	jne    f0101ece <check_page_free_list+0x70>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101f0c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f0f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101f15:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f18:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101f1b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101f1d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101f20:	a3 30 42 29 f0       	mov    %eax,0xf0294230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f25:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0101f2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f2d:	eb 3e                	jmp    f0101f6d <check_page_free_list+0x10f>
		if (PDX(page2pa(pp)) < pdx_limit)
f0101f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f32:	89 04 24             	mov    %eax,(%esp)
f0101f35:	e8 ef f2 ff ff       	call   f0101229 <page2pa>
f0101f3a:	c1 e8 16             	shr    $0x16,%eax
f0101f3d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101f40:	73 23                	jae    f0101f65 <check_page_free_list+0x107>
			memset(page2kva(pp), 0x97, 128);
f0101f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f45:	89 04 24             	mov    %eax,(%esp)
f0101f48:	e8 38 f3 ff ff       	call   f0101285 <page2kva>
f0101f4d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101f54:	00 
f0101f55:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101f5c:	00 
f0101f5d:	89 04 24             	mov    %eax,(%esp)
f0101f60:	e8 a0 6a 00 00       	call   f0108a05 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f68:	8b 00                	mov    (%eax),%eax
f0101f6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101f71:	75 bc                	jne    f0101f2f <check_page_free_list+0xd1>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101f73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f7a:	e8 02 f4 ff ff       	call   f0101381 <boot_alloc>
f0101f7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101f82:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0101f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f8a:	e9 13 02 00 00       	jmp    f01021a2 <check_page_free_list+0x344>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101f8f:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101f94:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101f97:	73 24                	jae    f0101fbd <check_page_free_list+0x15f>
f0101f99:	c7 44 24 0c 78 a1 10 	movl   $0xf010a178,0xc(%esp)
f0101fa0:	f0 
f0101fa1:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0101fa8:	f0 
f0101fa9:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101fb0:	00 
f0101fb1:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101fb8:	e8 12 e3 ff ff       	call   f01002cf <_panic>
		assert(pp < pages + npages);
f0101fbd:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101fc2:	8b 15 e8 7a 29 f0    	mov    0xf0297ae8,%edx
f0101fc8:	c1 e2 03             	shl    $0x3,%edx
f0101fcb:	01 d0                	add    %edx,%eax
f0101fcd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101fd0:	77 24                	ja     f0101ff6 <check_page_free_list+0x198>
f0101fd2:	c7 44 24 0c 84 a1 10 	movl   $0xf010a184,0xc(%esp)
f0101fd9:	f0 
f0101fda:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0101fe1:	f0 
f0101fe2:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101fe9:	00 
f0101fea:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0101ff1:	e8 d9 e2 ff ff       	call   f01002cf <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101ff6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101ff9:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0101ffe:	29 c2                	sub    %eax,%edx
f0102000:	89 d0                	mov    %edx,%eax
f0102002:	83 e0 07             	and    $0x7,%eax
f0102005:	85 c0                	test   %eax,%eax
f0102007:	74 24                	je     f010202d <check_page_free_list+0x1cf>
f0102009:	c7 44 24 0c 98 a1 10 	movl   $0xf010a198,0xc(%esp)
f0102010:	f0 
f0102011:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102018:	f0 
f0102019:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0102020:	00 
f0102021:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102028:	e8 a2 e2 ff ff       	call   f01002cf <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010202d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102030:	89 04 24             	mov    %eax,(%esp)
f0102033:	e8 f1 f1 ff ff       	call   f0101229 <page2pa>
f0102038:	85 c0                	test   %eax,%eax
f010203a:	75 24                	jne    f0102060 <check_page_free_list+0x202>
f010203c:	c7 44 24 0c ca a1 10 	movl   $0xf010a1ca,0xc(%esp)
f0102043:	f0 
f0102044:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010204b:	f0 
f010204c:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0102053:	00 
f0102054:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010205b:	e8 6f e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0102060:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102063:	89 04 24             	mov    %eax,(%esp)
f0102066:	e8 be f1 ff ff       	call   f0101229 <page2pa>
f010206b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0102070:	75 24                	jne    f0102096 <check_page_free_list+0x238>
f0102072:	c7 44 24 0c db a1 10 	movl   $0xf010a1db,0xc(%esp)
f0102079:	f0 
f010207a:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102081:	f0 
f0102082:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0102089:	00 
f010208a:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102091:	e8 39 e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0102096:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102099:	89 04 24             	mov    %eax,(%esp)
f010209c:	e8 88 f1 ff ff       	call   f0101229 <page2pa>
f01020a1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01020a6:	75 24                	jne    f01020cc <check_page_free_list+0x26e>
f01020a8:	c7 44 24 0c f4 a1 10 	movl   $0xf010a1f4,0xc(%esp)
f01020af:	f0 
f01020b0:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01020b7:	f0 
f01020b8:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01020bf:	00 
f01020c0:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01020c7:	e8 03 e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01020cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020cf:	89 04 24             	mov    %eax,(%esp)
f01020d2:	e8 52 f1 ff ff       	call   f0101229 <page2pa>
f01020d7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01020dc:	75 24                	jne    f0102102 <check_page_free_list+0x2a4>
f01020de:	c7 44 24 0c 17 a2 10 	movl   $0xf010a217,0xc(%esp)
f01020e5:	f0 
f01020e6:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01020ed:	f0 
f01020ee:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01020f5:	00 
f01020f6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01020fd:	e8 cd e1 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0102102:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102105:	89 04 24             	mov    %eax,(%esp)
f0102108:	e8 1c f1 ff ff       	call   f0101229 <page2pa>
f010210d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0102112:	76 34                	jbe    f0102148 <check_page_free_list+0x2ea>
f0102114:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102117:	89 04 24             	mov    %eax,(%esp)
f010211a:	e8 66 f1 ff ff       	call   f0101285 <page2kva>
f010211f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102122:	73 24                	jae    f0102148 <check_page_free_list+0x2ea>
f0102124:	c7 44 24 0c 34 a2 10 	movl   $0xf010a234,0xc(%esp)
f010212b:	f0 
f010212c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102133:	f0 
f0102134:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f010213b:	00 
f010213c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102143:	e8 87 e1 ff ff       	call   f01002cf <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0102148:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010214b:	89 04 24             	mov    %eax,(%esp)
f010214e:	e8 d6 f0 ff ff       	call   f0101229 <page2pa>
f0102153:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102158:	75 24                	jne    f010217e <check_page_free_list+0x320>
f010215a:	c7 44 24 0c 79 a2 10 	movl   $0xf010a279,0xc(%esp)
f0102161:	f0 
f0102162:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102169:	f0 
f010216a:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0102171:	00 
f0102172:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102179:	e8 51 e1 ff ff       	call   f01002cf <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102181:	89 04 24             	mov    %eax,(%esp)
f0102184:	e8 a0 f0 ff ff       	call   f0101229 <page2pa>
f0102189:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010218e:	77 06                	ja     f0102196 <check_page_free_list+0x338>
			++nfree_basemem;
f0102190:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0102194:	eb 04                	jmp    f010219a <check_page_free_list+0x33c>
		else
			++nfree_extmem;
f0102196:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010219a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010219d:	8b 00                	mov    (%eax),%eax
f010219f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01021a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01021a6:	0f 85 e3 fd ff ff    	jne    f0101f8f <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01021ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01021b0:	7f 24                	jg     f01021d6 <check_page_free_list+0x378>
f01021b2:	c7 44 24 0c 96 a2 10 	movl   $0xf010a296,0xc(%esp)
f01021b9:	f0 
f01021ba:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01021c1:	f0 
f01021c2:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01021c9:	00 
f01021ca:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01021d1:	e8 f9 e0 ff ff       	call   f01002cf <_panic>
	assert(nfree_extmem > 0);
f01021d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01021da:	7f 24                	jg     f0102200 <check_page_free_list+0x3a2>
f01021dc:	c7 44 24 0c a8 a2 10 	movl   $0xf010a2a8,0xc(%esp)
f01021e3:	f0 
f01021e4:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01021eb:	f0 
f01021ec:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f01021f3:	00 
f01021f4:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01021fb:	e8 cf e0 ff ff       	call   f01002cf <_panic>
}
f0102200:	c9                   	leave  
f0102201:	c3                   	ret    

f0102202 <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
f0102202:	55                   	push   %ebp
f0102203:	89 e5                	mov    %esp,%ebp
f0102205:	83 ec 38             	sub    $0x38,%esp
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0102208:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f010220d:	85 c0                	test   %eax,%eax
f010220f:	75 1c                	jne    f010222d <check_page_alloc+0x2b>
		panic("'pages' is a null pointer!");
f0102211:	c7 44 24 08 b9 a2 10 	movl   $0xf010a2b9,0x8(%esp)
f0102218:	f0 
f0102219:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0102220:	00 
f0102221:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102228:	e8 a2 e0 ff ff       	call   f01002cf <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010222d:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0102232:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102235:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010223c:	eb 0c                	jmp    f010224a <check_page_alloc+0x48>
		++nfree;
f010223e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102242:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102245:	8b 00                	mov    (%eax),%eax
f0102247:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010224a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010224e:	75 ee                	jne    f010223e <check_page_alloc+0x3c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0102250:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0102257:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010225a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010225d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102260:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert((pp0 = page_alloc(0)));
f0102263:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010226a:	e8 13 f6 ff ff       	call   f0101882 <page_alloc>
f010226f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102272:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102276:	75 24                	jne    f010229c <check_page_alloc+0x9a>
f0102278:	c7 44 24 0c d4 a2 10 	movl   $0xf010a2d4,0xc(%esp)
f010227f:	f0 
f0102280:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102287:	f0 
f0102288:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f010228f:	00 
f0102290:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102297:	e8 33 e0 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f010229c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022a3:	e8 da f5 ff ff       	call   f0101882 <page_alloc>
f01022a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01022af:	75 24                	jne    f01022d5 <check_page_alloc+0xd3>
f01022b1:	c7 44 24 0c ea a2 10 	movl   $0xf010a2ea,0xc(%esp)
f01022b8:	f0 
f01022b9:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01022c0:	f0 
f01022c1:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01022c8:	00 
f01022c9:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01022d0:	e8 fa df ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f01022d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022dc:	e8 a1 f5 ff ff       	call   f0101882 <page_alloc>
f01022e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01022e4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01022e8:	75 24                	jne    f010230e <check_page_alloc+0x10c>
f01022ea:	c7 44 24 0c 00 a3 10 	movl   $0xf010a300,0xc(%esp)
f01022f1:	f0 
f01022f2:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01022f9:	f0 
f01022fa:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f0102301:	00 
f0102302:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102309:	e8 c1 df ff ff       	call   f01002cf <_panic>

	assert(pp0);
f010230e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102312:	75 24                	jne    f0102338 <check_page_alloc+0x136>
f0102314:	c7 44 24 0c 16 a3 10 	movl   $0xf010a316,0xc(%esp)
f010231b:	f0 
f010231c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102323:	f0 
f0102324:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f010232b:	00 
f010232c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102333:	e8 97 df ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102338:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010233c:	74 08                	je     f0102346 <check_page_alloc+0x144>
f010233e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102341:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102344:	75 24                	jne    f010236a <check_page_alloc+0x168>
f0102346:	c7 44 24 0c 1a a3 10 	movl   $0xf010a31a,0xc(%esp)
f010234d:	f0 
f010234e:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102355:	f0 
f0102356:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f010235d:	00 
f010235e:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102365:	e8 65 df ff ff       	call   f01002cf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010236a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010236e:	74 10                	je     f0102380 <check_page_alloc+0x17e>
f0102370:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102373:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0102376:	74 08                	je     f0102380 <check_page_alloc+0x17e>
f0102378:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010237b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010237e:	75 24                	jne    f01023a4 <check_page_alloc+0x1a2>
f0102380:	c7 44 24 0c 2c a3 10 	movl   $0xf010a32c,0xc(%esp)
f0102387:	f0 
f0102388:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010238f:	f0 
f0102390:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0102397:	00 
f0102398:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010239f:	e8 2b df ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01023a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01023a7:	89 04 24             	mov    %eax,(%esp)
f01023aa:	e8 7a ee ff ff       	call   f0101229 <page2pa>
f01023af:	8b 15 e8 7a 29 f0    	mov    0xf0297ae8,%edx
f01023b5:	c1 e2 0c             	shl    $0xc,%edx
f01023b8:	39 d0                	cmp    %edx,%eax
f01023ba:	72 24                	jb     f01023e0 <check_page_alloc+0x1de>
f01023bc:	c7 44 24 0c 4c a3 10 	movl   $0xf010a34c,0xc(%esp)
f01023c3:	f0 
f01023c4:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01023cb:	f0 
f01023cc:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01023d3:	00 
f01023d4:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01023db:	e8 ef de ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01023e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01023e3:	89 04 24             	mov    %eax,(%esp)
f01023e6:	e8 3e ee ff ff       	call   f0101229 <page2pa>
f01023eb:	8b 15 e8 7a 29 f0    	mov    0xf0297ae8,%edx
f01023f1:	c1 e2 0c             	shl    $0xc,%edx
f01023f4:	39 d0                	cmp    %edx,%eax
f01023f6:	72 24                	jb     f010241c <check_page_alloc+0x21a>
f01023f8:	c7 44 24 0c 69 a3 10 	movl   $0xf010a369,0xc(%esp)
f01023ff:	f0 
f0102400:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102407:	f0 
f0102408:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f010240f:	00 
f0102410:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102417:	e8 b3 de ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010241c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010241f:	89 04 24             	mov    %eax,(%esp)
f0102422:	e8 02 ee ff ff       	call   f0101229 <page2pa>
f0102427:	8b 15 e8 7a 29 f0    	mov    0xf0297ae8,%edx
f010242d:	c1 e2 0c             	shl    $0xc,%edx
f0102430:	39 d0                	cmp    %edx,%eax
f0102432:	72 24                	jb     f0102458 <check_page_alloc+0x256>
f0102434:	c7 44 24 0c 86 a3 10 	movl   $0xf010a386,0xc(%esp)
f010243b:	f0 
f010243c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102443:	f0 
f0102444:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010244b:	00 
f010244c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102453:	e8 77 de ff ff       	call   f01002cf <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102458:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f010245d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f0102460:	c7 05 30 42 29 f0 00 	movl   $0x0,0xf0294230
f0102467:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010246a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102471:	e8 0c f4 ff ff       	call   f0101882 <page_alloc>
f0102476:	85 c0                	test   %eax,%eax
f0102478:	74 24                	je     f010249e <check_page_alloc+0x29c>
f010247a:	c7 44 24 0c a3 a3 10 	movl   $0xf010a3a3,0xc(%esp)
f0102481:	f0 
f0102482:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102489:	f0 
f010248a:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f0102491:	00 
f0102492:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102499:	e8 31 de ff ff       	call   f01002cf <_panic>

	// free and re-allocate?
	page_free(pp0);
f010249e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01024a1:	89 04 24             	mov    %eax,(%esp)
f01024a4:	e8 3c f4 ff ff       	call   f01018e5 <page_free>
	page_free(pp1);
f01024a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01024ac:	89 04 24             	mov    %eax,(%esp)
f01024af:	e8 31 f4 ff ff       	call   f01018e5 <page_free>
	page_free(pp2);
f01024b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01024b7:	89 04 24             	mov    %eax,(%esp)
f01024ba:	e8 26 f4 ff ff       	call   f01018e5 <page_free>
	pp0 = pp1 = pp2 = 0;
f01024bf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f01024c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01024c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01024cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert((pp0 = page_alloc(0)));
f01024d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024d9:	e8 a4 f3 ff ff       	call   f0101882 <page_alloc>
f01024de:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01024e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01024e5:	75 24                	jne    f010250b <check_page_alloc+0x309>
f01024e7:	c7 44 24 0c d4 a2 10 	movl   $0xf010a2d4,0xc(%esp)
f01024ee:	f0 
f01024ef:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01024f6:	f0 
f01024f7:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f01024fe:	00 
f01024ff:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102506:	e8 c4 dd ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f010250b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102512:	e8 6b f3 ff ff       	call   f0101882 <page_alloc>
f0102517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010251a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010251e:	75 24                	jne    f0102544 <check_page_alloc+0x342>
f0102520:	c7 44 24 0c ea a2 10 	movl   $0xf010a2ea,0xc(%esp)
f0102527:	f0 
f0102528:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010252f:	f0 
f0102530:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0102537:	00 
f0102538:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010253f:	e8 8b dd ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0102544:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010254b:	e8 32 f3 ff ff       	call   f0101882 <page_alloc>
f0102550:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102553:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102557:	75 24                	jne    f010257d <check_page_alloc+0x37b>
f0102559:	c7 44 24 0c 00 a3 10 	movl   $0xf010a300,0xc(%esp)
f0102560:	f0 
f0102561:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102568:	f0 
f0102569:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0102570:	00 
f0102571:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102578:	e8 52 dd ff ff       	call   f01002cf <_panic>
	assert(pp0);
f010257d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102581:	75 24                	jne    f01025a7 <check_page_alloc+0x3a5>
f0102583:	c7 44 24 0c 16 a3 10 	movl   $0xf010a316,0xc(%esp)
f010258a:	f0 
f010258b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102592:	f0 
f0102593:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f010259a:	00 
f010259b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01025a2:	e8 28 dd ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f01025a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01025ab:	74 08                	je     f01025b5 <check_page_alloc+0x3b3>
f01025ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01025b0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01025b3:	75 24                	jne    f01025d9 <check_page_alloc+0x3d7>
f01025b5:	c7 44 24 0c 1a a3 10 	movl   $0xf010a31a,0xc(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01025c4:	f0 
f01025c5:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01025cc:	00 
f01025cd:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01025d4:	e8 f6 dc ff ff       	call   f01002cf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01025d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01025dd:	74 10                	je     f01025ef <check_page_alloc+0x3ed>
f01025df:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01025e2:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f01025e5:	74 08                	je     f01025ef <check_page_alloc+0x3ed>
f01025e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01025ea:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01025ed:	75 24                	jne    f0102613 <check_page_alloc+0x411>
f01025ef:	c7 44 24 0c 2c a3 10 	movl   $0xf010a32c,0xc(%esp)
f01025f6:	f0 
f01025f7:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01025fe:	f0 
f01025ff:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0102606:	00 
f0102607:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010260e:	e8 bc dc ff ff       	call   f01002cf <_panic>
	assert(!page_alloc(0));
f0102613:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010261a:	e8 63 f2 ff ff       	call   f0101882 <page_alloc>
f010261f:	85 c0                	test   %eax,%eax
f0102621:	74 24                	je     f0102647 <check_page_alloc+0x445>
f0102623:	c7 44 24 0c a3 a3 10 	movl   $0xf010a3a3,0xc(%esp)
f010262a:	f0 
f010262b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102632:	f0 
f0102633:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f010263a:	00 
f010263b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102642:	e8 88 dc ff ff       	call   f01002cf <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102647:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010264a:	89 04 24             	mov    %eax,(%esp)
f010264d:	e8 33 ec ff ff       	call   f0101285 <page2kva>
f0102652:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102659:	00 
f010265a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102661:	00 
f0102662:	89 04 24             	mov    %eax,(%esp)
f0102665:	e8 9b 63 00 00       	call   f0108a05 <memset>
	page_free(pp0);
f010266a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010266d:	89 04 24             	mov    %eax,(%esp)
f0102670:	e8 70 f2 ff ff       	call   f01018e5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102675:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010267c:	e8 01 f2 ff ff       	call   f0101882 <page_alloc>
f0102681:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102684:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102688:	75 24                	jne    f01026ae <check_page_alloc+0x4ac>
f010268a:	c7 44 24 0c b2 a3 10 	movl   $0xf010a3b2,0xc(%esp)
f0102691:	f0 
f0102692:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102699:	f0 
f010269a:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01026a1:	00 
f01026a2:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01026a9:	e8 21 dc ff ff       	call   f01002cf <_panic>
	assert(pp && pp0 == pp);
f01026ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01026b2:	74 08                	je     f01026bc <check_page_alloc+0x4ba>
f01026b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01026b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01026ba:	74 24                	je     f01026e0 <check_page_alloc+0x4de>
f01026bc:	c7 44 24 0c d0 a3 10 	movl   $0xf010a3d0,0xc(%esp)
f01026c3:	f0 
f01026c4:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01026cb:	f0 
f01026cc:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01026d3:	00 
f01026d4:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01026db:	e8 ef db ff ff       	call   f01002cf <_panic>
	c = page2kva(pp);
f01026e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026e3:	89 04 24             	mov    %eax,(%esp)
f01026e6:	e8 9a eb ff ff       	call   f0101285 <page2kva>
f01026eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for (i = 0; i < PGSIZE; i++)
f01026ee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01026f5:	eb 37                	jmp    f010272e <check_page_alloc+0x52c>
		assert(c[i] == 0);
f01026f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01026fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01026fd:	01 d0                	add    %edx,%eax
f01026ff:	0f b6 00             	movzbl (%eax),%eax
f0102702:	84 c0                	test   %al,%al
f0102704:	74 24                	je     f010272a <check_page_alloc+0x528>
f0102706:	c7 44 24 0c e0 a3 10 	movl   $0xf010a3e0,0xc(%esp)
f010270d:	f0 
f010270e:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102715:	f0 
f0102716:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010271d:	00 
f010271e:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102725:	e8 a5 db ff ff       	call   f01002cf <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010272a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f010272e:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%ebp)
f0102735:	7e c0                	jle    f01026f7 <check_page_alloc+0x4f5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102737:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010273a:	a3 30 42 29 f0       	mov    %eax,0xf0294230

	// free the pages we took
	page_free(pp0);
f010273f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102742:	89 04 24             	mov    %eax,(%esp)
f0102745:	e8 9b f1 ff ff       	call   f01018e5 <page_free>
	page_free(pp1);
f010274a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010274d:	89 04 24             	mov    %eax,(%esp)
f0102750:	e8 90 f1 ff ff       	call   f01018e5 <page_free>
	page_free(pp2);
f0102755:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102758:	89 04 24             	mov    %eax,(%esp)
f010275b:	e8 85 f1 ff ff       	call   f01018e5 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102760:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0102765:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102768:	eb 0c                	jmp    f0102776 <check_page_alloc+0x574>
		--nfree;
f010276a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010276e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102771:	8b 00                	mov    (%eax),%eax
f0102773:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102776:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010277a:	75 ee                	jne    f010276a <check_page_alloc+0x568>
		--nfree;
	assert(nfree == 0);
f010277c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102780:	74 24                	je     f01027a6 <check_page_alloc+0x5a4>
f0102782:	c7 44 24 0c ea a3 10 	movl   $0xf010a3ea,0xc(%esp)
f0102789:	f0 
f010278a:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102791:	f0 
f0102792:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0102799:	00 
f010279a:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01027a1:	e8 29 db ff ff       	call   f01002cf <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01027a6:	c7 04 24 f8 a3 10 f0 	movl   $0xf010a3f8,(%esp)
f01027ad:	e8 9c 27 00 00       	call   f0104f4e <cprintf>
}
f01027b2:	c9                   	leave  
f01027b3:	c3                   	ret    

f01027b4 <check_kern_pgdir>:
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
f01027b4:	55                   	push   %ebp
f01027b5:	89 e5                	mov    %esp,%ebp
f01027b7:	53                   	push   %ebx
f01027b8:	83 ec 34             	sub    $0x34,%esp
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027bb:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01027c0:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027c3:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
f01027ca:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f01027cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01027d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01027d9:	01 d0                	add    %edx,%eax
f01027db:	83 e8 01             	sub    $0x1,%eax
f01027de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01027e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01027e9:	f7 75 e8             	divl   -0x18(%ebp)
f01027ec:	89 d0                	mov    %edx,%eax
f01027ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01027f1:	29 c2                	sub    %eax,%edx
f01027f3:	89 d0                	mov    %edx,%eax
f01027f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01027f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01027ff:	eb 6a                	jmp    f010286b <check_kern_pgdir+0xb7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102801:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102804:	2d 00 00 00 11       	sub    $0x11000000,%eax
f0102809:	89 44 24 04          	mov    %eax,0x4(%esp)
f010280d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102810:	89 04 24             	mov    %eax,(%esp)
f0102813:	e8 a3 03 00 00       	call   f0102bbb <check_va2pa>
f0102818:	89 c3                	mov    %eax,%ebx
f010281a:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f010281f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102823:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f010282a:	00 
f010282b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102832:	e8 75 e9 ff ff       	call   f01011ac <_paddr>
f0102837:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010283a:	01 d0                	add    %edx,%eax
f010283c:	39 c3                	cmp    %eax,%ebx
f010283e:	74 24                	je     f0102864 <check_kern_pgdir+0xb0>
f0102840:	c7 44 24 0c 18 a4 10 	movl   $0xf010a418,0xc(%esp)
f0102847:	f0 
f0102848:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010284f:	f0 
f0102850:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0102857:	00 
f0102858:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010285f:	e8 6b da ff ff       	call   f01002cf <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102864:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f010286b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010286e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0102871:	72 8e                	jb     f0102801 <check_kern_pgdir+0x4d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
f0102873:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
f010287a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010287d:	05 ff ef 01 00       	add    $0x1efff,%eax
f0102882:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102885:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102888:	ba 00 00 00 00       	mov    $0x0,%edx
f010288d:	f7 75 e0             	divl   -0x20(%ebp)
f0102890:	89 d0                	mov    %edx,%eax
f0102892:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102895:	29 c2                	sub    %eax,%edx
f0102897:	89 d0                	mov    %edx,%eax
f0102899:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010289c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01028a3:	eb 6a                	jmp    f010290f <check_kern_pgdir+0x15b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028a8:	2d 00 00 40 11       	sub    $0x11400000,%eax
f01028ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01028b4:	89 04 24             	mov    %eax,(%esp)
f01028b7:	e8 ff 02 00 00       	call   f0102bbb <check_va2pa>
f01028bc:	89 c3                	mov    %eax,%ebx
f01028be:	a1 3c 42 29 f0       	mov    0xf029423c,%eax
f01028c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01028c7:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01028ce:	00 
f01028cf:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01028d6:	e8 d1 e8 ff ff       	call   f01011ac <_paddr>
f01028db:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01028de:	01 d0                	add    %edx,%eax
f01028e0:	39 c3                	cmp    %eax,%ebx
f01028e2:	74 24                	je     f0102908 <check_kern_pgdir+0x154>
f01028e4:	c7 44 24 0c 4c a4 10 	movl   $0xf010a44c,0xc(%esp)
f01028eb:	f0 
f01028ec:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01028f3:	f0 
f01028f4:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01028fb:	00 
f01028fc:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102903:	e8 c7 d9 ff ff       	call   f01002cf <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102908:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f010290f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102912:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0102915:	72 8e                	jb     f01028a5 <check_kern_pgdir+0xf1>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102917:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010291e:	eb 47                	jmp    f0102967 <check_kern_pgdir+0x1b3>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102920:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102923:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102928:	89 44 24 04          	mov    %eax,0x4(%esp)
f010292c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010292f:	89 04 24             	mov    %eax,(%esp)
f0102932:	e8 84 02 00 00       	call   f0102bbb <check_va2pa>
f0102937:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010293a:	74 24                	je     f0102960 <check_kern_pgdir+0x1ac>
f010293c:	c7 44 24 0c 80 a4 10 	movl   $0xf010a480,0xc(%esp)
f0102943:	f0 
f0102944:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010294b:	f0 
f010294c:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0102953:	00 
f0102954:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010295b:	e8 6f d9 ff ff       	call   f01002cf <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102960:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102967:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f010296c:	c1 e0 0c             	shl    $0xc,%eax
f010296f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102972:	77 ac                	ja     f0102920 <check_kern_pgdir+0x16c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102974:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010297b:	e9 f9 00 00 00       	jmp    f0102a79 <check_kern_pgdir+0x2c5>
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
f0102980:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102983:	b8 00 00 00 00       	mov    $0x0,%eax
f0102988:	29 d0                	sub    %edx,%eax
f010298a:	c1 e0 10             	shl    $0x10,%eax
f010298d:	2d 00 00 01 10       	sub    $0x10010000,%eax
f0102992:	89 45 d8             	mov    %eax,-0x28(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102995:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010299c:	eb 75                	jmp    f0102a13 <check_kern_pgdir+0x25f>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010299e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01029a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029a4:	01 d0                	add    %edx,%eax
f01029a6:	05 00 80 00 00       	add    $0x8000,%eax
f01029ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029af:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01029b2:	89 04 24             	mov    %eax,(%esp)
f01029b5:	e8 01 02 00 00       	call   f0102bbb <check_va2pa>
f01029ba:	89 c3                	mov    %eax,%ebx
f01029bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01029bf:	c1 e0 0f             	shl    $0xf,%eax
f01029c2:	05 00 90 29 f0       	add    $0xf0299000,%eax
f01029c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01029cb:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01029d2:	00 
f01029d3:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01029da:	e8 cd e7 ff ff       	call   f01011ac <_paddr>
f01029df:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01029e2:	01 d0                	add    %edx,%eax
f01029e4:	39 c3                	cmp    %eax,%ebx
f01029e6:	74 24                	je     f0102a0c <check_kern_pgdir+0x258>
f01029e8:	c7 44 24 0c a8 a4 10 	movl   $0xf010a4a8,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102a07:	e8 c3 d8 ff ff       	call   f01002cf <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a0c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102a13:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0102a1a:	76 82                	jbe    f010299e <check_kern_pgdir+0x1ea>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102a23:	eb 47                	jmp    f0102a6c <check_kern_pgdir+0x2b8>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a28:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a2b:	01 d0                	add    %edx,%eax
f0102a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102a34:	89 04 24             	mov    %eax,(%esp)
f0102a37:	e8 7f 01 00 00       	call   f0102bbb <check_va2pa>
f0102a3c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a3f:	74 24                	je     f0102a65 <check_kern_pgdir+0x2b1>
f0102a41:	c7 44 24 0c f0 a4 10 	movl   $0xf010a4f0,0xc(%esp)
f0102a48:	f0 
f0102a49:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0102a58:	00 
f0102a59:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102a60:	e8 6a d8 ff ff       	call   f01002cf <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a65:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102a6c:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0102a73:	76 b0                	jbe    f0102a25 <check_kern_pgdir+0x271>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a75:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0102a79:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
f0102a7d:	0f 86 fd fe ff ff    	jbe    f0102980 <check_kern_pgdir+0x1cc>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102a8a:	e9 0d 01 00 00       	jmp    f0102b9c <check_kern_pgdir+0x3e8>
		switch (i) {
f0102a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a92:	2d bb 03 00 00       	sub    $0x3bb,%eax
f0102a97:	83 f8 04             	cmp    $0x4,%eax
f0102a9a:	77 41                	ja     f0102add <check_kern_pgdir+0x329>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102aa9:	01 d0                	add    %edx,%eax
f0102aab:	8b 00                	mov    (%eax),%eax
f0102aad:	83 e0 01             	and    $0x1,%eax
f0102ab0:	85 c0                	test   %eax,%eax
f0102ab2:	75 24                	jne    f0102ad8 <check_kern_pgdir+0x324>
f0102ab4:	c7 44 24 0c 13 a5 10 	movl   $0xf010a513,0xc(%esp)
f0102abb:	f0 
f0102abc:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102ac3:	f0 
f0102ac4:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0102acb:	00 
f0102acc:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102ad3:	e8 f7 d7 ff ff       	call   f01002cf <_panic>
			break;
f0102ad8:	e9 bb 00 00 00       	jmp    f0102b98 <check_kern_pgdir+0x3e4>
		default:
			if (i >= PDX(KERNBASE)) {
f0102add:	81 7d f4 bf 03 00 00 	cmpl   $0x3bf,-0xc(%ebp)
f0102ae4:	76 78                	jbe    f0102b5e <check_kern_pgdir+0x3aa>
				assert(pgdir[i] & PTE_P);
f0102ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ae9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102af3:	01 d0                	add    %edx,%eax
f0102af5:	8b 00                	mov    (%eax),%eax
f0102af7:	83 e0 01             	and    $0x1,%eax
f0102afa:	85 c0                	test   %eax,%eax
f0102afc:	75 24                	jne    f0102b22 <check_kern_pgdir+0x36e>
f0102afe:	c7 44 24 0c 13 a5 10 	movl   $0xf010a513,0xc(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102b0d:	f0 
f0102b0e:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102b15:	00 
f0102b16:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102b1d:	e8 ad d7 ff ff       	call   f01002cf <_panic>
				assert(pgdir[i] & PTE_W);
f0102b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b2f:	01 d0                	add    %edx,%eax
f0102b31:	8b 00                	mov    (%eax),%eax
f0102b33:	83 e0 02             	and    $0x2,%eax
f0102b36:	85 c0                	test   %eax,%eax
f0102b38:	75 5d                	jne    f0102b97 <check_kern_pgdir+0x3e3>
f0102b3a:	c7 44 24 0c 24 a5 10 	movl   $0xf010a524,0xc(%esp)
f0102b41:	f0 
f0102b42:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102b49:	f0 
f0102b4a:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102b51:	00 
f0102b52:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102b59:	e8 71 d7 ff ff       	call   f01002cf <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b61:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b6b:	01 d0                	add    %edx,%eax
f0102b6d:	8b 00                	mov    (%eax),%eax
f0102b6f:	85 c0                	test   %eax,%eax
f0102b71:	74 24                	je     f0102b97 <check_kern_pgdir+0x3e3>
f0102b73:	c7 44 24 0c 35 a5 10 	movl   $0xf010a535,0xc(%esp)
f0102b7a:	f0 
f0102b7b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102b82:	f0 
f0102b83:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102b8a:	00 
f0102b8b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102b92:	e8 38 d7 ff ff       	call   f01002cf <_panic>
			break;
f0102b97:	90                   	nop
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b98:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0102b9c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0102ba3:	0f 86 e6 fe ff ff    	jbe    f0102a8f <check_kern_pgdir+0x2db>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102ba9:	c7 04 24 44 a5 10 f0 	movl   $0xf010a544,(%esp)
f0102bb0:	e8 99 23 00 00       	call   f0104f4e <cprintf>
}
f0102bb5:	83 c4 34             	add    $0x34,%esp
f0102bb8:	5b                   	pop    %ebx
f0102bb9:	5d                   	pop    %ebp
f0102bba:	c3                   	ret    

f0102bbb <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0102bbb:	55                   	push   %ebp
f0102bbc:	89 e5                	mov    %esp,%ebp
f0102bbe:	83 ec 28             	sub    $0x28,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0102bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bc4:	c1 e8 16             	shr    $0x16,%eax
f0102bc7:	c1 e0 02             	shl    $0x2,%eax
f0102bca:	01 45 08             	add    %eax,0x8(%ebp)
	if (!(*pgdir & PTE_P))
f0102bcd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bd0:	8b 00                	mov    (%eax),%eax
f0102bd2:	83 e0 01             	and    $0x1,%eax
f0102bd5:	85 c0                	test   %eax,%eax
f0102bd7:	75 07                	jne    f0102be0 <check_va2pa+0x25>
		return ~0;
f0102bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bde:	eb 6a                	jmp    f0102c4a <check_va2pa+0x8f>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0102be0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102be3:	8b 00                	mov    (%eax),%eax
f0102be5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102bea:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102bee:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0102bf5:	00 
f0102bf6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102bfd:	e8 e5 e5 ff ff       	call   f01011e7 <_kaddr>
f0102c02:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!(p[PTX(va)] & PTE_P))
f0102c05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c08:	c1 e8 0c             	shr    $0xc,%eax
f0102c0b:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102c10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c1a:	01 d0                	add    %edx,%eax
f0102c1c:	8b 00                	mov    (%eax),%eax
f0102c1e:	83 e0 01             	and    $0x1,%eax
f0102c21:	85 c0                	test   %eax,%eax
f0102c23:	75 07                	jne    f0102c2c <check_va2pa+0x71>
		return ~0;
f0102c25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c2a:	eb 1e                	jmp    f0102c4a <check_va2pa+0x8f>
	return PTE_ADDR(p[PTX(va)]);
f0102c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c2f:	c1 e8 0c             	shr    $0xc,%eax
f0102c32:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102c37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c41:	01 d0                	add    %edx,%eax
f0102c43:	8b 00                	mov    (%eax),%eax
f0102c45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f0102c4a:	c9                   	leave  
f0102c4b:	c3                   	ret    

f0102c4c <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f0102c4c:	55                   	push   %ebp
f0102c4d:	89 e5                	mov    %esp,%ebp
f0102c4f:	53                   	push   %ebx
f0102c50:	83 ec 44             	sub    $0x44,%esp
	uintptr_t mm1, mm2;
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0102c53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c60:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c63:	89 45 e8             	mov    %eax,-0x18(%ebp)
	assert((pp0 = page_alloc(0)));
f0102c66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c6d:	e8 10 ec ff ff       	call   f0101882 <page_alloc>
f0102c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102c75:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102c79:	75 24                	jne    f0102c9f <check_page+0x53>
f0102c7b:	c7 44 24 0c d4 a2 10 	movl   $0xf010a2d4,0xc(%esp)
f0102c82:	f0 
f0102c83:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102c8a:	f0 
f0102c8b:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102c92:	00 
f0102c93:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102c9a:	e8 30 d6 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0102c9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ca6:	e8 d7 eb ff ff       	call   f0101882 <page_alloc>
f0102cab:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102cae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102cb2:	75 24                	jne    f0102cd8 <check_page+0x8c>
f0102cb4:	c7 44 24 0c ea a2 10 	movl   $0xf010a2ea,0xc(%esp)
f0102cbb:	f0 
f0102cbc:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102cc3:	f0 
f0102cc4:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102ccb:	00 
f0102ccc:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102cd3:	e8 f7 d5 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0102cd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cdf:	e8 9e eb ff ff       	call   f0101882 <page_alloc>
f0102ce4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102ce7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102ceb:	75 24                	jne    f0102d11 <check_page+0xc5>
f0102ced:	c7 44 24 0c 00 a3 10 	movl   $0xf010a300,0xc(%esp)
f0102cf4:	f0 
f0102cf5:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102cfc:	f0 
f0102cfd:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0102d04:	00 
f0102d05:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102d0c:	e8 be d5 ff ff       	call   f01002cf <_panic>

	assert(pp0);
f0102d11:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102d15:	75 24                	jne    f0102d3b <check_page+0xef>
f0102d17:	c7 44 24 0c 16 a3 10 	movl   $0xf010a316,0xc(%esp)
f0102d1e:	f0 
f0102d1f:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102d26:	f0 
f0102d27:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102d2e:	00 
f0102d2f:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102d36:	e8 94 d5 ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102d3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102d3f:	74 08                	je     f0102d49 <check_page+0xfd>
f0102d41:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d44:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102d47:	75 24                	jne    f0102d6d <check_page+0x121>
f0102d49:	c7 44 24 0c 1a a3 10 	movl   $0xf010a31a,0xc(%esp)
f0102d50:	f0 
f0102d51:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102d58:	f0 
f0102d59:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102d60:	00 
f0102d61:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102d68:	e8 62 d5 ff ff       	call   f01002cf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102d6d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102d71:	74 10                	je     f0102d83 <check_page+0x137>
f0102d73:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0102d79:	74 08                	je     f0102d83 <check_page+0x137>
f0102d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d7e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102d81:	75 24                	jne    f0102da7 <check_page+0x15b>
f0102d83:	c7 44 24 0c 2c a3 10 	movl   $0xf010a32c,0xc(%esp)
f0102d8a:	f0 
f0102d8b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102d92:	f0 
f0102d93:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102d9a:	00 
f0102d9b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102da2:	e8 28 d5 ff ff       	call   f01002cf <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102da7:	a1 30 42 29 f0       	mov    0xf0294230,%eax
f0102dac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	page_free_list = 0;
f0102daf:	c7 05 30 42 29 f0 00 	movl   $0x0,0xf0294230
f0102db6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102db9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dc0:	e8 bd ea ff ff       	call   f0101882 <page_alloc>
f0102dc5:	85 c0                	test   %eax,%eax
f0102dc7:	74 24                	je     f0102ded <check_page+0x1a1>
f0102dc9:	c7 44 24 0c a3 a3 10 	movl   $0xf010a3a3,0xc(%esp)
f0102dd0:	f0 
f0102dd1:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102dd8:	f0 
f0102dd9:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0102de0:	00 
f0102de1:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102de8:	e8 e2 d4 ff ff       	call   f01002cf <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102ded:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0102df2:	8d 55 cc             	lea    -0x34(%ebp),%edx
f0102df5:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102df9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102e00:	00 
f0102e01:	89 04 24             	mov    %eax,(%esp)
f0102e04:	e8 94 ed ff ff       	call   f0101b9d <page_lookup>
f0102e09:	85 c0                	test   %eax,%eax
f0102e0b:	74 24                	je     f0102e31 <check_page+0x1e5>
f0102e0d:	c7 44 24 0c 64 a5 10 	movl   $0xf010a564,0xc(%esp)
f0102e14:	f0 
f0102e15:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102e1c:	f0 
f0102e1d:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102e24:	00 
f0102e25:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102e2c:	e8 9e d4 ff ff       	call   f01002cf <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102e31:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0102e36:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102e3d:	00 
f0102e3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e45:	00 
f0102e46:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102e49:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102e4d:	89 04 24             	mov    %eax,(%esp)
f0102e50:	e8 b6 ec ff ff       	call   f0101b0b <page_insert>
f0102e55:	85 c0                	test   %eax,%eax
f0102e57:	78 24                	js     f0102e7d <check_page+0x231>
f0102e59:	c7 44 24 0c 9c a5 10 	movl   $0xf010a59c,0xc(%esp)
f0102e60:	f0 
f0102e61:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102e68:	f0 
f0102e69:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102e70:	00 
f0102e71:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102e78:	e8 52 d4 ff ff       	call   f01002cf <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102e7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e80:	89 04 24             	mov    %eax,(%esp)
f0102e83:	e8 5d ea ff ff       	call   f01018e5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102e88:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0102e8d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102e94:	00 
f0102e95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e9c:	00 
f0102e9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102ea0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102ea4:	89 04 24             	mov    %eax,(%esp)
f0102ea7:	e8 5f ec ff ff       	call   f0101b0b <page_insert>
f0102eac:	85 c0                	test   %eax,%eax
f0102eae:	74 24                	je     f0102ed4 <check_page+0x288>
f0102eb0:	c7 44 24 0c cc a5 10 	movl   $0xf010a5cc,0xc(%esp)
f0102eb7:	f0 
f0102eb8:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102ebf:	f0 
f0102ec0:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102ec7:	00 
f0102ec8:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102ecf:	e8 fb d3 ff ff       	call   f01002cf <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ed4:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0102ed9:	8b 00                	mov    (%eax),%eax
f0102edb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ee0:	89 c3                	mov    %eax,%ebx
f0102ee2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102ee5:	89 04 24             	mov    %eax,(%esp)
f0102ee8:	e8 3c e3 ff ff       	call   f0101229 <page2pa>
f0102eed:	39 c3                	cmp    %eax,%ebx
f0102eef:	74 24                	je     f0102f15 <check_page+0x2c9>
f0102ef1:	c7 44 24 0c fc a5 10 	movl   $0xf010a5fc,0xc(%esp)
f0102ef8:	f0 
f0102ef9:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102f00:	f0 
f0102f01:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102f08:	00 
f0102f09:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102f10:	e8 ba d3 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102f15:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0102f1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f21:	00 
f0102f22:	89 04 24             	mov    %eax,(%esp)
f0102f25:	e8 91 fc ff ff       	call   f0102bbb <check_va2pa>
f0102f2a:	89 c3                	mov    %eax,%ebx
f0102f2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f2f:	89 04 24             	mov    %eax,(%esp)
f0102f32:	e8 f2 e2 ff ff       	call   f0101229 <page2pa>
f0102f37:	39 c3                	cmp    %eax,%ebx
f0102f39:	74 24                	je     f0102f5f <check_page+0x313>
f0102f3b:	c7 44 24 0c 24 a6 10 	movl   $0xf010a624,0xc(%esp)
f0102f42:	f0 
f0102f43:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102f4a:	f0 
f0102f4b:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102f52:	00 
f0102f53:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102f5a:	e8 70 d3 ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 1);
f0102f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f62:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f66:	66 83 f8 01          	cmp    $0x1,%ax
f0102f6a:	74 24                	je     f0102f90 <check_page+0x344>
f0102f6c:	c7 44 24 0c 51 a6 10 	movl   $0xf010a651,0xc(%esp)
f0102f73:	f0 
f0102f74:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102f7b:	f0 
f0102f7c:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0102f83:	00 
f0102f84:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102f8b:	e8 3f d3 ff ff       	call   f01002cf <_panic>
	assert(pp0->pp_ref == 1);
f0102f90:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f93:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f97:	66 83 f8 01          	cmp    $0x1,%ax
f0102f9b:	74 24                	je     f0102fc1 <check_page+0x375>
f0102f9d:	c7 44 24 0c 62 a6 10 	movl   $0xf010a662,0xc(%esp)
f0102fa4:	f0 
f0102fa5:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102fac:	f0 
f0102fad:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102fb4:	00 
f0102fb5:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0102fbc:	e8 0e d3 ff ff       	call   f01002cf <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102fc1:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0102fc6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102fcd:	00 
f0102fce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102fd5:	00 
f0102fd6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102fd9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102fdd:	89 04 24             	mov    %eax,(%esp)
f0102fe0:	e8 26 eb ff ff       	call   f0101b0b <page_insert>
f0102fe5:	85 c0                	test   %eax,%eax
f0102fe7:	74 24                	je     f010300d <check_page+0x3c1>
f0102fe9:	c7 44 24 0c 74 a6 10 	movl   $0xf010a674,0xc(%esp)
f0102ff0:	f0 
f0102ff1:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0102ff8:	f0 
f0102ff9:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0103000:	00 
f0103001:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103008:	e8 c2 d2 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010300d:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103012:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103019:	00 
f010301a:	89 04 24             	mov    %eax,(%esp)
f010301d:	e8 99 fb ff ff       	call   f0102bbb <check_va2pa>
f0103022:	89 c3                	mov    %eax,%ebx
f0103024:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103027:	89 04 24             	mov    %eax,(%esp)
f010302a:	e8 fa e1 ff ff       	call   f0101229 <page2pa>
f010302f:	39 c3                	cmp    %eax,%ebx
f0103031:	74 24                	je     f0103057 <check_page+0x40b>
f0103033:	c7 44 24 0c b0 a6 10 	movl   $0xf010a6b0,0xc(%esp)
f010303a:	f0 
f010303b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103042:	f0 
f0103043:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f010304a:	00 
f010304b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103052:	e8 78 d2 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f0103057:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010305a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010305e:	66 83 f8 01          	cmp    $0x1,%ax
f0103062:	74 24                	je     f0103088 <check_page+0x43c>
f0103064:	c7 44 24 0c e0 a6 10 	movl   $0xf010a6e0,0xc(%esp)
f010306b:	f0 
f010306c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103073:	f0 
f0103074:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f010307b:	00 
f010307c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103083:	e8 47 d2 ff ff       	call   f01002cf <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010308f:	e8 ee e7 ff ff       	call   f0101882 <page_alloc>
f0103094:	85 c0                	test   %eax,%eax
f0103096:	74 24                	je     f01030bc <check_page+0x470>
f0103098:	c7 44 24 0c a3 a3 10 	movl   $0xf010a3a3,0xc(%esp)
f010309f:	f0 
f01030a0:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01030a7:	f0 
f01030a8:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f01030af:	00 
f01030b0:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01030b7:	e8 13 d2 ff ff       	call   f01002cf <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01030bc:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01030c1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01030c8:	00 
f01030c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030d0:	00 
f01030d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01030d4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01030d8:	89 04 24             	mov    %eax,(%esp)
f01030db:	e8 2b ea ff ff       	call   f0101b0b <page_insert>
f01030e0:	85 c0                	test   %eax,%eax
f01030e2:	74 24                	je     f0103108 <check_page+0x4bc>
f01030e4:	c7 44 24 0c 74 a6 10 	movl   $0xf010a674,0xc(%esp)
f01030eb:	f0 
f01030ec:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01030f3:	f0 
f01030f4:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f01030fb:	00 
f01030fc:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103103:	e8 c7 d1 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103108:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010310d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103114:	00 
f0103115:	89 04 24             	mov    %eax,(%esp)
f0103118:	e8 9e fa ff ff       	call   f0102bbb <check_va2pa>
f010311d:	89 c3                	mov    %eax,%ebx
f010311f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103122:	89 04 24             	mov    %eax,(%esp)
f0103125:	e8 ff e0 ff ff       	call   f0101229 <page2pa>
f010312a:	39 c3                	cmp    %eax,%ebx
f010312c:	74 24                	je     f0103152 <check_page+0x506>
f010312e:	c7 44 24 0c b0 a6 10 	movl   $0xf010a6b0,0xc(%esp)
f0103135:	f0 
f0103136:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010313d:	f0 
f010313e:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0103145:	00 
f0103146:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010314d:	e8 7d d1 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f0103152:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103155:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103159:	66 83 f8 01          	cmp    $0x1,%ax
f010315d:	74 24                	je     f0103183 <check_page+0x537>
f010315f:	c7 44 24 0c e0 a6 10 	movl   $0xf010a6e0,0xc(%esp)
f0103166:	f0 
f0103167:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010316e:	f0 
f010316f:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0103176:	00 
f0103177:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010317e:	e8 4c d1 ff ff       	call   f01002cf <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010318a:	e8 f3 e6 ff ff       	call   f0101882 <page_alloc>
f010318f:	85 c0                	test   %eax,%eax
f0103191:	74 24                	je     f01031b7 <check_page+0x56b>
f0103193:	c7 44 24 0c a3 a3 10 	movl   $0xf010a3a3,0xc(%esp)
f010319a:	f0 
f010319b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01031a2:	f0 
f01031a3:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f01031aa:	00 
f01031ab:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01031b2:	e8 18 d1 ff ff       	call   f01002cf <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01031b7:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01031bc:	8b 00                	mov    (%eax),%eax
f01031be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031c7:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01031ce:	00 
f01031cf:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01031d6:	e8 0c e0 ff ff       	call   f01011e7 <_kaddr>
f01031db:	89 45 cc             	mov    %eax,-0x34(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01031de:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01031e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031ea:	00 
f01031eb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01031f2:	00 
f01031f3:	89 04 24             	mov    %eax,(%esp)
f01031f6:	e8 82 e7 ff ff       	call   f010197d <pgdir_walk>
f01031fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01031fe:	83 c2 04             	add    $0x4,%edx
f0103201:	39 d0                	cmp    %edx,%eax
f0103203:	74 24                	je     f0103229 <check_page+0x5dd>
f0103205:	c7 44 24 0c f4 a6 10 	movl   $0xf010a6f4,0xc(%esp)
f010320c:	f0 
f010320d:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103214:	f0 
f0103215:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f010321c:	00 
f010321d:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103224:	e8 a6 d0 ff ff       	call   f01002cf <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0103229:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010322e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103235:	00 
f0103236:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010323d:	00 
f010323e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103241:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103245:	89 04 24             	mov    %eax,(%esp)
f0103248:	e8 be e8 ff ff       	call   f0101b0b <page_insert>
f010324d:	85 c0                	test   %eax,%eax
f010324f:	74 24                	je     f0103275 <check_page+0x629>
f0103251:	c7 44 24 0c 34 a7 10 	movl   $0xf010a734,0xc(%esp)
f0103258:	f0 
f0103259:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103260:	f0 
f0103261:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0103268:	00 
f0103269:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103270:	e8 5a d0 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103275:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010327a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103281:	00 
f0103282:	89 04 24             	mov    %eax,(%esp)
f0103285:	e8 31 f9 ff ff       	call   f0102bbb <check_va2pa>
f010328a:	89 c3                	mov    %eax,%ebx
f010328c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010328f:	89 04 24             	mov    %eax,(%esp)
f0103292:	e8 92 df ff ff       	call   f0101229 <page2pa>
f0103297:	39 c3                	cmp    %eax,%ebx
f0103299:	74 24                	je     f01032bf <check_page+0x673>
f010329b:	c7 44 24 0c b0 a6 10 	movl   $0xf010a6b0,0xc(%esp)
f01032a2:	f0 
f01032a3:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01032aa:	f0 
f01032ab:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01032b2:	00 
f01032b3:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01032ba:	e8 10 d0 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f01032bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01032c2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01032c6:	66 83 f8 01          	cmp    $0x1,%ax
f01032ca:	74 24                	je     f01032f0 <check_page+0x6a4>
f01032cc:	c7 44 24 0c e0 a6 10 	movl   $0xf010a6e0,0xc(%esp)
f01032d3:	f0 
f01032d4:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01032db:	f0 
f01032dc:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f01032e3:	00 
f01032e4:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01032eb:	e8 df cf ff ff       	call   f01002cf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01032f0:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01032f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01032fc:	00 
f01032fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103304:	00 
f0103305:	89 04 24             	mov    %eax,(%esp)
f0103308:	e8 70 e6 ff ff       	call   f010197d <pgdir_walk>
f010330d:	8b 00                	mov    (%eax),%eax
f010330f:	83 e0 04             	and    $0x4,%eax
f0103312:	85 c0                	test   %eax,%eax
f0103314:	75 24                	jne    f010333a <check_page+0x6ee>
f0103316:	c7 44 24 0c 74 a7 10 	movl   $0xf010a774,0xc(%esp)
f010331d:	f0 
f010331e:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103325:	f0 
f0103326:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f010332d:	00 
f010332e:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103335:	e8 95 cf ff ff       	call   f01002cf <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010333a:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010333f:	8b 00                	mov    (%eax),%eax
f0103341:	83 e0 04             	and    $0x4,%eax
f0103344:	85 c0                	test   %eax,%eax
f0103346:	75 24                	jne    f010336c <check_page+0x720>
f0103348:	c7 44 24 0c a7 a7 10 	movl   $0xf010a7a7,0xc(%esp)
f010334f:	f0 
f0103350:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103357:	f0 
f0103358:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f010335f:	00 
f0103360:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103367:	e8 63 cf ff ff       	call   f01002cf <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010336c:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103371:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103378:	00 
f0103379:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103380:	00 
f0103381:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103384:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103388:	89 04 24             	mov    %eax,(%esp)
f010338b:	e8 7b e7 ff ff       	call   f0101b0b <page_insert>
f0103390:	85 c0                	test   %eax,%eax
f0103392:	74 24                	je     f01033b8 <check_page+0x76c>
f0103394:	c7 44 24 0c 74 a6 10 	movl   $0xf010a674,0xc(%esp)
f010339b:	f0 
f010339c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01033a3:	f0 
f01033a4:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01033ab:	00 
f01033ac:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01033b3:	e8 17 cf ff ff       	call   f01002cf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01033b8:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01033bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01033c4:	00 
f01033c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033cc:	00 
f01033cd:	89 04 24             	mov    %eax,(%esp)
f01033d0:	e8 a8 e5 ff ff       	call   f010197d <pgdir_walk>
f01033d5:	8b 00                	mov    (%eax),%eax
f01033d7:	83 e0 02             	and    $0x2,%eax
f01033da:	85 c0                	test   %eax,%eax
f01033dc:	75 24                	jne    f0103402 <check_page+0x7b6>
f01033de:	c7 44 24 0c c0 a7 10 	movl   $0xf010a7c0,0xc(%esp)
f01033e5:	f0 
f01033e6:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01033ed:	f0 
f01033ee:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f01033f5:	00 
f01033f6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01033fd:	e8 cd ce ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0103402:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103407:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010340e:	00 
f010340f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103416:	00 
f0103417:	89 04 24             	mov    %eax,(%esp)
f010341a:	e8 5e e5 ff ff       	call   f010197d <pgdir_walk>
f010341f:	8b 00                	mov    (%eax),%eax
f0103421:	83 e0 04             	and    $0x4,%eax
f0103424:	85 c0                	test   %eax,%eax
f0103426:	74 24                	je     f010344c <check_page+0x800>
f0103428:	c7 44 24 0c f4 a7 10 	movl   $0xf010a7f4,0xc(%esp)
f010342f:	f0 
f0103430:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103437:	f0 
f0103438:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f010343f:	00 
f0103440:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103447:	e8 83 ce ff ff       	call   f01002cf <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010344c:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103451:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103458:	00 
f0103459:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0103460:	00 
f0103461:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103464:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103468:	89 04 24             	mov    %eax,(%esp)
f010346b:	e8 9b e6 ff ff       	call   f0101b0b <page_insert>
f0103470:	85 c0                	test   %eax,%eax
f0103472:	78 24                	js     f0103498 <check_page+0x84c>
f0103474:	c7 44 24 0c 2c a8 10 	movl   $0xf010a82c,0xc(%esp)
f010347b:	f0 
f010347c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103483:	f0 
f0103484:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f010348b:	00 
f010348c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103493:	e8 37 ce ff ff       	call   f01002cf <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103498:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010349d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01034a4:	00 
f01034a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01034ac:	00 
f01034ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01034b0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01034b4:	89 04 24             	mov    %eax,(%esp)
f01034b7:	e8 4f e6 ff ff       	call   f0101b0b <page_insert>
f01034bc:	85 c0                	test   %eax,%eax
f01034be:	74 24                	je     f01034e4 <check_page+0x898>
f01034c0:	c7 44 24 0c 64 a8 10 	movl   $0xf010a864,0xc(%esp)
f01034c7:	f0 
f01034c8:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01034cf:	f0 
f01034d0:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f01034d7:	00 
f01034d8:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01034df:	e8 eb cd ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01034e4:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01034e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034f0:	00 
f01034f1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01034f8:	00 
f01034f9:	89 04 24             	mov    %eax,(%esp)
f01034fc:	e8 7c e4 ff ff       	call   f010197d <pgdir_walk>
f0103501:	8b 00                	mov    (%eax),%eax
f0103503:	83 e0 04             	and    $0x4,%eax
f0103506:	85 c0                	test   %eax,%eax
f0103508:	74 24                	je     f010352e <check_page+0x8e2>
f010350a:	c7 44 24 0c f4 a7 10 	movl   $0xf010a7f4,0xc(%esp)
f0103511:	f0 
f0103512:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103519:	f0 
f010351a:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0103521:	00 
f0103522:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103529:	e8 a1 cd ff ff       	call   f01002cf <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010352e:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103533:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010353a:	00 
f010353b:	89 04 24             	mov    %eax,(%esp)
f010353e:	e8 78 f6 ff ff       	call   f0102bbb <check_va2pa>
f0103543:	89 c3                	mov    %eax,%ebx
f0103545:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103548:	89 04 24             	mov    %eax,(%esp)
f010354b:	e8 d9 dc ff ff       	call   f0101229 <page2pa>
f0103550:	39 c3                	cmp    %eax,%ebx
f0103552:	74 24                	je     f0103578 <check_page+0x92c>
f0103554:	c7 44 24 0c a0 a8 10 	movl   $0xf010a8a0,0xc(%esp)
f010355b:	f0 
f010355c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103563:	f0 
f0103564:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f010356b:	00 
f010356c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103573:	e8 57 cd ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103578:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010357d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103584:	00 
f0103585:	89 04 24             	mov    %eax,(%esp)
f0103588:	e8 2e f6 ff ff       	call   f0102bbb <check_va2pa>
f010358d:	89 c3                	mov    %eax,%ebx
f010358f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103592:	89 04 24             	mov    %eax,(%esp)
f0103595:	e8 8f dc ff ff       	call   f0101229 <page2pa>
f010359a:	39 c3                	cmp    %eax,%ebx
f010359c:	74 24                	je     f01035c2 <check_page+0x976>
f010359e:	c7 44 24 0c cc a8 10 	movl   $0xf010a8cc,0xc(%esp)
f01035a5:	f0 
f01035a6:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01035ad:	f0 
f01035ae:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01035b5:	00 
f01035b6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01035bd:	e8 0d cd ff ff       	call   f01002cf <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01035c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01035c5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01035c9:	66 83 f8 02          	cmp    $0x2,%ax
f01035cd:	74 24                	je     f01035f3 <check_page+0x9a7>
f01035cf:	c7 44 24 0c fc a8 10 	movl   $0xf010a8fc,0xc(%esp)
f01035d6:	f0 
f01035d7:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01035de:	f0 
f01035df:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f01035e6:	00 
f01035e7:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01035ee:	e8 dc cc ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f01035f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01035f6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01035fa:	66 85 c0             	test   %ax,%ax
f01035fd:	74 24                	je     f0103623 <check_page+0x9d7>
f01035ff:	c7 44 24 0c 0d a9 10 	movl   $0xf010a90d,0xc(%esp)
f0103606:	f0 
f0103607:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010360e:	f0 
f010360f:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0103616:	00 
f0103617:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010361e:	e8 ac cc ff ff       	call   f01002cf <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0103623:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010362a:	e8 53 e2 ff ff       	call   f0101882 <page_alloc>
f010362f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103632:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103636:	74 08                	je     f0103640 <check_page+0x9f4>
f0103638:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010363b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010363e:	74 24                	je     f0103664 <check_page+0xa18>
f0103640:	c7 44 24 0c 20 a9 10 	movl   $0xf010a920,0xc(%esp)
f0103647:	f0 
f0103648:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010364f:	f0 
f0103650:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0103657:	00 
f0103658:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010365f:	e8 6b cc ff ff       	call   f01002cf <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0103664:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103669:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103670:	00 
f0103671:	89 04 24             	mov    %eax,(%esp)
f0103674:	e8 77 e5 ff ff       	call   f0101bf0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103679:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010367e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103685:	00 
f0103686:	89 04 24             	mov    %eax,(%esp)
f0103689:	e8 2d f5 ff ff       	call   f0102bbb <check_va2pa>
f010368e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103691:	74 24                	je     f01036b7 <check_page+0xa6b>
f0103693:	c7 44 24 0c 44 a9 10 	movl   $0xf010a944,0xc(%esp)
f010369a:	f0 
f010369b:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01036a2:	f0 
f01036a3:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01036aa:	00 
f01036ab:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01036b2:	e8 18 cc ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01036b7:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01036bc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01036c3:	00 
f01036c4:	89 04 24             	mov    %eax,(%esp)
f01036c7:	e8 ef f4 ff ff       	call   f0102bbb <check_va2pa>
f01036cc:	89 c3                	mov    %eax,%ebx
f01036ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01036d1:	89 04 24             	mov    %eax,(%esp)
f01036d4:	e8 50 db ff ff       	call   f0101229 <page2pa>
f01036d9:	39 c3                	cmp    %eax,%ebx
f01036db:	74 24                	je     f0103701 <check_page+0xab5>
f01036dd:	c7 44 24 0c cc a8 10 	movl   $0xf010a8cc,0xc(%esp)
f01036e4:	f0 
f01036e5:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01036ec:	f0 
f01036ed:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01036f4:	00 
f01036f5:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01036fc:	e8 ce cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 1);
f0103701:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103704:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103708:	66 83 f8 01          	cmp    $0x1,%ax
f010370c:	74 24                	je     f0103732 <check_page+0xae6>
f010370e:	c7 44 24 0c 51 a6 10 	movl   $0xf010a651,0xc(%esp)
f0103715:	f0 
f0103716:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010371d:	f0 
f010371e:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103725:	00 
f0103726:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010372d:	e8 9d cb ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f0103732:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103735:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103739:	66 85 c0             	test   %ax,%ax
f010373c:	74 24                	je     f0103762 <check_page+0xb16>
f010373e:	c7 44 24 0c 0d a9 10 	movl   $0xf010a90d,0xc(%esp)
f0103745:	f0 
f0103746:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010374d:	f0 
f010374e:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0103755:	00 
f0103756:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010375d:	e8 6d cb ff ff       	call   f01002cf <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0103762:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103767:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010376e:	00 
f010376f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103776:	00 
f0103777:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010377a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010377e:	89 04 24             	mov    %eax,(%esp)
f0103781:	e8 85 e3 ff ff       	call   f0101b0b <page_insert>
f0103786:	85 c0                	test   %eax,%eax
f0103788:	74 24                	je     f01037ae <check_page+0xb62>
f010378a:	c7 44 24 0c 68 a9 10 	movl   $0xf010a968,0xc(%esp)
f0103791:	f0 
f0103792:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103799:	f0 
f010379a:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f01037a1:	00 
f01037a2:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01037a9:	e8 21 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref);
f01037ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037b1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01037b5:	66 85 c0             	test   %ax,%ax
f01037b8:	75 24                	jne    f01037de <check_page+0xb92>
f01037ba:	c7 44 24 0c 9d a9 10 	movl   $0xf010a99d,0xc(%esp)
f01037c1:	f0 
f01037c2:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01037c9:	f0 
f01037ca:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01037d1:	00 
f01037d2:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01037d9:	e8 f1 ca ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_link == NULL);
f01037de:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037e1:	8b 00                	mov    (%eax),%eax
f01037e3:	85 c0                	test   %eax,%eax
f01037e5:	74 24                	je     f010380b <check_page+0xbbf>
f01037e7:	c7 44 24 0c a9 a9 10 	movl   $0xf010a9a9,0xc(%esp)
f01037ee:	f0 
f01037ef:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01037f6:	f0 
f01037f7:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01037fe:	00 
f01037ff:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103806:	e8 c4 ca ff ff       	call   f01002cf <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010380b:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103810:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103817:	00 
f0103818:	89 04 24             	mov    %eax,(%esp)
f010381b:	e8 d0 e3 ff ff       	call   f0101bf0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103820:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103825:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010382c:	00 
f010382d:	89 04 24             	mov    %eax,(%esp)
f0103830:	e8 86 f3 ff ff       	call   f0102bbb <check_va2pa>
f0103835:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103838:	74 24                	je     f010385e <check_page+0xc12>
f010383a:	c7 44 24 0c 44 a9 10 	movl   $0xf010a944,0xc(%esp)
f0103841:	f0 
f0103842:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103849:	f0 
f010384a:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0103851:	00 
f0103852:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103859:	e8 71 ca ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010385e:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103863:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010386a:	00 
f010386b:	89 04 24             	mov    %eax,(%esp)
f010386e:	e8 48 f3 ff ff       	call   f0102bbb <check_va2pa>
f0103873:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103876:	74 24                	je     f010389c <check_page+0xc50>
f0103878:	c7 44 24 0c c0 a9 10 	movl   $0xf010a9c0,0xc(%esp)
f010387f:	f0 
f0103880:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103887:	f0 
f0103888:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f010388f:	00 
f0103890:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103897:	e8 33 ca ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 0);
f010389c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010389f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01038a3:	66 85 c0             	test   %ax,%ax
f01038a6:	74 24                	je     f01038cc <check_page+0xc80>
f01038a8:	c7 44 24 0c e6 a9 10 	movl   $0xf010a9e6,0xc(%esp)
f01038af:	f0 
f01038b0:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01038b7:	f0 
f01038b8:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01038bf:	00 
f01038c0:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01038c7:	e8 03 ca ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f01038cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01038cf:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01038d3:	66 85 c0             	test   %ax,%ax
f01038d6:	74 24                	je     f01038fc <check_page+0xcb0>
f01038d8:	c7 44 24 0c 0d a9 10 	movl   $0xf010a90d,0xc(%esp)
f01038df:	f0 
f01038e0:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01038e7:	f0 
f01038e8:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f01038ef:	00 
f01038f0:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01038f7:	e8 d3 c9 ff ff       	call   f01002cf <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01038fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103903:	e8 7a df ff ff       	call   f0101882 <page_alloc>
f0103908:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010390b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010390f:	74 08                	je     f0103919 <check_page+0xccd>
f0103911:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103914:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0103917:	74 24                	je     f010393d <check_page+0xcf1>
f0103919:	c7 44 24 0c f8 a9 10 	movl   $0xf010a9f8,0xc(%esp)
f0103920:	f0 
f0103921:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103928:	f0 
f0103929:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0103930:	00 
f0103931:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103938:	e8 92 c9 ff ff       	call   f01002cf <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010393d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103944:	e8 39 df ff ff       	call   f0101882 <page_alloc>
f0103949:	85 c0                	test   %eax,%eax
f010394b:	74 24                	je     f0103971 <check_page+0xd25>
f010394d:	c7 44 24 0c a3 a3 10 	movl   $0xf010a3a3,0xc(%esp)
f0103954:	f0 
f0103955:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010395c:	f0 
f010395d:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0103964:	00 
f0103965:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010396c:	e8 5e c9 ff ff       	call   f01002cf <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103971:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103976:	8b 00                	mov    (%eax),%eax
f0103978:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010397d:	89 c3                	mov    %eax,%ebx
f010397f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103982:	89 04 24             	mov    %eax,(%esp)
f0103985:	e8 9f d8 ff ff       	call   f0101229 <page2pa>
f010398a:	39 c3                	cmp    %eax,%ebx
f010398c:	74 24                	je     f01039b2 <check_page+0xd66>
f010398e:	c7 44 24 0c fc a5 10 	movl   $0xf010a5fc,0xc(%esp)
f0103995:	f0 
f0103996:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010399d:	f0 
f010399e:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01039a5:	00 
f01039a6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01039ad:	e8 1d c9 ff ff       	call   f01002cf <_panic>
	kern_pgdir[0] = 0;
f01039b2:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01039b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01039bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039c0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01039c4:	66 83 f8 01          	cmp    $0x1,%ax
f01039c8:	74 24                	je     f01039ee <check_page+0xda2>
f01039ca:	c7 44 24 0c 62 a6 10 	movl   $0xf010a662,0xc(%esp)
f01039d1:	f0 
f01039d2:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01039d9:	f0 
f01039da:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01039e1:	00 
f01039e2:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01039e9:	e8 e1 c8 ff ff       	call   f01002cf <_panic>
	pp0->pp_ref = 0;
f01039ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039f1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01039f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039fa:	89 04 24             	mov    %eax,(%esp)
f01039fd:	e8 e3 de ff ff       	call   f01018e5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
f0103a02:	c7 45 dc 00 10 40 00 	movl   $0x401000,-0x24(%ebp)
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0103a09:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103a0e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a15:	00 
f0103a16:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a1d:	89 04 24             	mov    %eax,(%esp)
f0103a20:	e8 58 df ff ff       	call   f010197d <pgdir_walk>
f0103a25:	89 45 cc             	mov    %eax,-0x34(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103a28:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103a2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a30:	c1 ea 16             	shr    $0x16,%edx
f0103a33:	c1 e2 02             	shl    $0x2,%edx
f0103a36:	01 d0                	add    %edx,%eax
f0103a38:	8b 00                	mov    (%eax),%eax
f0103a3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a43:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0103a4a:	00 
f0103a4b:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103a52:	e8 90 d7 ff ff       	call   f01011e7 <_kaddr>
f0103a57:	89 45 d8             	mov    %eax,-0x28(%ebp)
	assert(ptep == ptep1 + PTX(va));
f0103a5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a5d:	c1 e8 0c             	shr    $0xc,%eax
f0103a60:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103a65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103a6c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a6f:	01 c2                	add    %eax,%edx
f0103a71:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103a74:	39 c2                	cmp    %eax,%edx
f0103a76:	74 24                	je     f0103a9c <check_page+0xe50>
f0103a78:	c7 44 24 0c 1a aa 10 	movl   $0xf010aa1a,0xc(%esp)
f0103a7f:	f0 
f0103a80:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103a87:	f0 
f0103a88:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0103a8f:	00 
f0103a90:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103a97:	e8 33 c8 ff ff       	call   f01002cf <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103a9c:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103aa1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103aa4:	c1 ea 16             	shr    $0x16,%edx
f0103aa7:	c1 e2 02             	shl    $0x2,%edx
f0103aaa:	01 d0                	add    %edx,%eax
f0103aac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ab5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103abb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103abe:	89 04 24             	mov    %eax,(%esp)
f0103ac1:	e8 bf d7 ff ff       	call   f0101285 <page2kva>
f0103ac6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103acd:	00 
f0103ace:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103ad5:	00 
f0103ad6:	89 04 24             	mov    %eax,(%esp)
f0103ad9:	e8 27 4f 00 00       	call   f0108a05 <memset>
	page_free(pp0);
f0103ade:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ae1:	89 04 24             	mov    %eax,(%esp)
f0103ae4:	e8 fc dd ff ff       	call   f01018e5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103ae9:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103aee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103af5:	00 
f0103af6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103afd:	00 
f0103afe:	89 04 24             	mov    %eax,(%esp)
f0103b01:	e8 77 de ff ff       	call   f010197d <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0103b06:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b09:	89 04 24             	mov    %eax,(%esp)
f0103b0c:	e8 74 d7 ff ff       	call   f0101285 <page2kva>
f0103b11:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for(i=0; i<NPTENTRIES; i++)
f0103b14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0103b1b:	eb 3c                	jmp    f0103b59 <check_page+0xf0d>
		assert((ptep[i] & PTE_P) == 0);
f0103b1d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103b20:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b23:	c1 e2 02             	shl    $0x2,%edx
f0103b26:	01 d0                	add    %edx,%eax
f0103b28:	8b 00                	mov    (%eax),%eax
f0103b2a:	83 e0 01             	and    $0x1,%eax
f0103b2d:	85 c0                	test   %eax,%eax
f0103b2f:	74 24                	je     f0103b55 <check_page+0xf09>
f0103b31:	c7 44 24 0c 32 aa 10 	movl   $0xf010aa32,0xc(%esp)
f0103b38:	f0 
f0103b39:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103b40:	f0 
f0103b41:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0103b48:	00 
f0103b49:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103b50:	e8 7a c7 ff ff       	call   f01002cf <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103b55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0103b59:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0103b60:	7e bb                	jle    f0103b1d <check_page+0xed1>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103b62:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103b67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103b6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b70:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0103b76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b79:	a3 30 42 29 f0       	mov    %eax,0xf0294230

	// free the pages we took
	page_free(pp0);
f0103b7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b81:	89 04 24             	mov    %eax,(%esp)
f0103b84:	e8 5c dd ff ff       	call   f01018e5 <page_free>
	page_free(pp1);
f0103b89:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b8c:	89 04 24             	mov    %eax,(%esp)
f0103b8f:	e8 51 dd ff ff       	call   f01018e5 <page_free>
	page_free(pp2);
f0103b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b97:	89 04 24             	mov    %eax,(%esp)
f0103b9a:	e8 46 dd ff ff       	call   f01018e5 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0103b9f:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0103ba6:	00 
f0103ba7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103bae:	e8 cb e0 ff ff       	call   f0101c7e <mmio_map_region>
f0103bb3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0103bb6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103bbd:	00 
f0103bbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103bc5:	e8 b4 e0 ff ff       	call   f0101c7e <mmio_map_region>
f0103bca:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0103bcd:	81 7d d4 ff ff 7f ef 	cmpl   $0xef7fffff,-0x2c(%ebp)
f0103bd4:	76 0f                	jbe    f0103be5 <check_page+0xf99>
f0103bd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bd9:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103bde:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103be3:	76 24                	jbe    f0103c09 <check_page+0xfbd>
f0103be5:	c7 44 24 0c 4c aa 10 	movl   $0xf010aa4c,0xc(%esp)
f0103bec:	f0 
f0103bed:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103bf4:	f0 
f0103bf5:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f0103bfc:	00 
f0103bfd:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103c04:	e8 c6 c6 ff ff       	call   f01002cf <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103c09:	81 7d d0 ff ff 7f ef 	cmpl   $0xef7fffff,-0x30(%ebp)
f0103c10:	76 0f                	jbe    f0103c21 <check_page+0xfd5>
f0103c12:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c15:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c1a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103c1f:	76 24                	jbe    f0103c45 <check_page+0xff9>
f0103c21:	c7 44 24 0c 74 aa 10 	movl   $0xf010aa74,0xc(%esp)
f0103c28:	f0 
f0103c29:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103c30:	f0 
f0103c31:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0103c38:	00 
f0103c39:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103c40:	e8 8a c6 ff ff       	call   f01002cf <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0103c45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c48:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103c4d:	85 c0                	test   %eax,%eax
f0103c4f:	75 0c                	jne    f0103c5d <check_page+0x1011>
f0103c51:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c54:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103c59:	85 c0                	test   %eax,%eax
f0103c5b:	74 24                	je     f0103c81 <check_page+0x1035>
f0103c5d:	c7 44 24 0c 9c aa 10 	movl   $0xf010aa9c,0xc(%esp)
f0103c64:	f0 
f0103c65:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103c6c:	f0 
f0103c6d:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0103c74:	00 
f0103c75:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103c7c:	e8 4e c6 ff ff       	call   f01002cf <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0103c81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c84:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c89:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103c8c:	76 24                	jbe    f0103cb2 <check_page+0x1066>
f0103c8e:	c7 44 24 0c c3 aa 10 	movl   $0xf010aac3,0xc(%esp)
f0103c95:	f0 
f0103c96:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103c9d:	f0 
f0103c9e:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f0103ca5:	00 
f0103ca6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103cad:	e8 1d c6 ff ff       	call   f01002cf <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103cb2:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103cb7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103cba:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103cbe:	89 04 24             	mov    %eax,(%esp)
f0103cc1:	e8 f5 ee ff ff       	call   f0102bbb <check_va2pa>
f0103cc6:	85 c0                	test   %eax,%eax
f0103cc8:	74 24                	je     f0103cee <check_page+0x10a2>
f0103cca:	c7 44 24 0c d8 aa 10 	movl   $0xf010aad8,0xc(%esp)
f0103cd1:	f0 
f0103cd2:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103cd9:	f0 
f0103cda:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0103ce1:	00 
f0103ce2:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103ce9:	e8 e1 c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0103cee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103cf1:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103cf7:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103cfc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d00:	89 04 24             	mov    %eax,(%esp)
f0103d03:	e8 b3 ee ff ff       	call   f0102bbb <check_va2pa>
f0103d08:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103d0d:	74 24                	je     f0103d33 <check_page+0x10e7>
f0103d0f:	c7 44 24 0c fc aa 10 	movl   $0xf010aafc,0xc(%esp)
f0103d16:	f0 
f0103d17:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103d1e:	f0 
f0103d1f:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0103d26:	00 
f0103d27:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103d2e:	e8 9c c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0103d33:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103d38:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103d3b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d3f:	89 04 24             	mov    %eax,(%esp)
f0103d42:	e8 74 ee ff ff       	call   f0102bbb <check_va2pa>
f0103d47:	85 c0                	test   %eax,%eax
f0103d49:	74 24                	je     f0103d6f <check_page+0x1123>
f0103d4b:	c7 44 24 0c 2c ab 10 	movl   $0xf010ab2c,0xc(%esp)
f0103d52:	f0 
f0103d53:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103d5a:	f0 
f0103d5b:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0103d62:	00 
f0103d63:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103d6a:	e8 60 c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103d6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d72:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103d78:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103d7d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d81:	89 04 24             	mov    %eax,(%esp)
f0103d84:	e8 32 ee ff ff       	call   f0102bbb <check_va2pa>
f0103d89:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d8c:	74 24                	je     f0103db2 <check_page+0x1166>
f0103d8e:	c7 44 24 0c 50 ab 10 	movl   $0xf010ab50,0xc(%esp)
f0103d95:	f0 
f0103d96:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103d9d:	f0 
f0103d9e:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0103da5:	00 
f0103da6:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103dad:	e8 1d c5 ff ff       	call   f01002cf <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0103db2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103db5:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103dba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103dc1:	00 
f0103dc2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103dc6:	89 04 24             	mov    %eax,(%esp)
f0103dc9:	e8 af db ff ff       	call   f010197d <pgdir_walk>
f0103dce:	8b 00                	mov    (%eax),%eax
f0103dd0:	83 e0 1a             	and    $0x1a,%eax
f0103dd3:	85 c0                	test   %eax,%eax
f0103dd5:	75 24                	jne    f0103dfb <check_page+0x11af>
f0103dd7:	c7 44 24 0c 7c ab 10 	movl   $0xf010ab7c,0xc(%esp)
f0103dde:	f0 
f0103ddf:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103de6:	f0 
f0103de7:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0103dee:	00 
f0103def:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103df6:	e8 d4 c4 ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0103dfb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103dfe:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103e03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e0a:	00 
f0103e0b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e0f:	89 04 24             	mov    %eax,(%esp)
f0103e12:	e8 66 db ff ff       	call   f010197d <pgdir_walk>
f0103e17:	8b 00                	mov    (%eax),%eax
f0103e19:	83 e0 04             	and    $0x4,%eax
f0103e1c:	85 c0                	test   %eax,%eax
f0103e1e:	74 24                	je     f0103e44 <check_page+0x11f8>
f0103e20:	c7 44 24 0c c0 ab 10 	movl   $0xf010abc0,0xc(%esp)
f0103e27:	f0 
f0103e28:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103e2f:	f0 
f0103e30:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0103e37:	00 
f0103e38:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103e3f:	e8 8b c4 ff ff       	call   f01002cf <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103e44:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e47:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103e4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e53:	00 
f0103e54:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e58:	89 04 24             	mov    %eax,(%esp)
f0103e5b:	e8 1d db ff ff       	call   f010197d <pgdir_walk>
f0103e60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103e66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103e69:	05 00 10 00 00       	add    $0x1000,%eax
f0103e6e:	89 c2                	mov    %eax,%edx
f0103e70:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103e75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e7c:	00 
f0103e7d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e81:	89 04 24             	mov    %eax,(%esp)
f0103e84:	e8 f4 da ff ff       	call   f010197d <pgdir_walk>
f0103e89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103e8f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103e92:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103e97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e9e:	00 
f0103e9f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ea3:	89 04 24             	mov    %eax,(%esp)
f0103ea6:	e8 d2 da ff ff       	call   f010197d <pgdir_walk>
f0103eab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103eb1:	c7 04 24 f3 ab 10 f0 	movl   $0xf010abf3,(%esp)
f0103eb8:	e8 91 10 00 00       	call   f0104f4e <cprintf>
}
f0103ebd:	83 c4 44             	add    $0x44,%esp
f0103ec0:	5b                   	pop    %ebx
f0103ec1:	5d                   	pop    %ebp
f0103ec2:	c3                   	ret    

f0103ec3 <check_page_installed_pgdir>:

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0103ec3:	55                   	push   %ebp
f0103ec4:	89 e5                	mov    %esp,%ebp
f0103ec6:	53                   	push   %ebx
f0103ec7:	83 ec 24             	sub    $0x24,%esp
	pte_t *ptep, *ptep1;
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
f0103eca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0103ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ed4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert((pp0 = page_alloc(0)));
f0103ed7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ede:	e8 9f d9 ff ff       	call   f0101882 <page_alloc>
f0103ee3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ee6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0103eea:	75 24                	jne    f0103f10 <check_page_installed_pgdir+0x4d>
f0103eec:	c7 44 24 0c d4 a2 10 	movl   $0xf010a2d4,0xc(%esp)
f0103ef3:	f0 
f0103ef4:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103efb:	f0 
f0103efc:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0103f03:	00 
f0103f04:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103f0b:	e8 bf c3 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0103f10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f17:	e8 66 d9 ff ff       	call   f0101882 <page_alloc>
f0103f1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0103f23:	75 24                	jne    f0103f49 <check_page_installed_pgdir+0x86>
f0103f25:	c7 44 24 0c ea a2 10 	movl   $0xf010a2ea,0xc(%esp)
f0103f2c:	f0 
f0103f2d:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103f34:	f0 
f0103f35:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0103f3c:	00 
f0103f3d:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103f44:	e8 86 c3 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0103f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f50:	e8 2d d9 ff ff       	call   f0101882 <page_alloc>
f0103f55:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103f58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103f5c:	75 24                	jne    f0103f82 <check_page_installed_pgdir+0xbf>
f0103f5e:	c7 44 24 0c 00 a3 10 	movl   $0xf010a300,0xc(%esp)
f0103f65:	f0 
f0103f66:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0103f6d:	f0 
f0103f6e:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0103f75:	00 
f0103f76:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0103f7d:	e8 4d c3 ff ff       	call   f01002cf <_panic>
	page_free(pp0);
f0103f82:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f85:	89 04 24             	mov    %eax,(%esp)
f0103f88:	e8 58 d9 ff ff       	call   f01018e5 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f90:	89 04 24             	mov    %eax,(%esp)
f0103f93:	e8 ed d2 ff ff       	call   f0101285 <page2kva>
f0103f98:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f9f:	00 
f0103fa0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103fa7:	00 
f0103fa8:	89 04 24             	mov    %eax,(%esp)
f0103fab:	e8 55 4a 00 00       	call   f0108a05 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fb3:	89 04 24             	mov    %eax,(%esp)
f0103fb6:	e8 ca d2 ff ff       	call   f0101285 <page2kva>
f0103fbb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103fc2:	00 
f0103fc3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103fca:	00 
f0103fcb:	89 04 24             	mov    %eax,(%esp)
f0103fce:	e8 32 4a 00 00       	call   f0108a05 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103fd3:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0103fd8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103fdf:	00 
f0103fe0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103fe7:	00 
f0103fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103feb:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103fef:	89 04 24             	mov    %eax,(%esp)
f0103ff2:	e8 14 db ff ff       	call   f0101b0b <page_insert>
	assert(pp1->pp_ref == 1);
f0103ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103ffa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103ffe:	66 83 f8 01          	cmp    $0x1,%ax
f0104002:	74 24                	je     f0104028 <check_page_installed_pgdir+0x165>
f0104004:	c7 44 24 0c 51 a6 10 	movl   $0xf010a651,0xc(%esp)
f010400b:	f0 
f010400c:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0104013:	f0 
f0104014:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f010401b:	00 
f010401c:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0104023:	e8 a7 c2 ff ff       	call   f01002cf <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0104028:	b8 00 10 00 00       	mov    $0x1000,%eax
f010402d:	8b 00                	mov    (%eax),%eax
f010402f:	3d 01 01 01 01       	cmp    $0x1010101,%eax
f0104034:	74 24                	je     f010405a <check_page_installed_pgdir+0x197>
f0104036:	c7 44 24 0c 0c ac 10 	movl   $0xf010ac0c,0xc(%esp)
f010403d:	f0 
f010403e:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0104045:	f0 
f0104046:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f010404d:	00 
f010404e:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0104055:	e8 75 c2 ff ff       	call   f01002cf <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010405a:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010405f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104066:	00 
f0104067:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010406e:	00 
f010406f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104072:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104076:	89 04 24             	mov    %eax,(%esp)
f0104079:	e8 8d da ff ff       	call   f0101b0b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010407e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0104083:	8b 00                	mov    (%eax),%eax
f0104085:	3d 02 02 02 02       	cmp    $0x2020202,%eax
f010408a:	74 24                	je     f01040b0 <check_page_installed_pgdir+0x1ed>
f010408c:	c7 44 24 0c 30 ac 10 	movl   $0xf010ac30,0xc(%esp)
f0104093:	f0 
f0104094:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010409b:	f0 
f010409c:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01040a3:	00 
f01040a4:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01040ab:	e8 1f c2 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f01040b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040b3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01040b7:	66 83 f8 01          	cmp    $0x1,%ax
f01040bb:	74 24                	je     f01040e1 <check_page_installed_pgdir+0x21e>
f01040bd:	c7 44 24 0c e0 a6 10 	movl   $0xf010a6e0,0xc(%esp)
f01040c4:	f0 
f01040c5:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01040cc:	f0 
f01040cd:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01040d4:	00 
f01040d5:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01040dc:	e8 ee c1 ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 0);
f01040e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01040e4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01040e8:	66 85 c0             	test   %ax,%ax
f01040eb:	74 24                	je     f0104111 <check_page_installed_pgdir+0x24e>
f01040ed:	c7 44 24 0c e6 a9 10 	movl   $0xf010a9e6,0xc(%esp)
f01040f4:	f0 
f01040f5:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01040fc:	f0 
f01040fd:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0104104:	00 
f0104105:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010410c:	e8 be c1 ff ff       	call   f01002cf <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0104111:	b8 00 10 00 00       	mov    $0x1000,%eax
f0104116:	c7 00 03 03 03 03    	movl   $0x3030303,(%eax)
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010411f:	89 04 24             	mov    %eax,(%esp)
f0104122:	e8 5e d1 ff ff       	call   f0101285 <page2kva>
f0104127:	8b 00                	mov    (%eax),%eax
f0104129:	3d 03 03 03 03       	cmp    $0x3030303,%eax
f010412e:	74 24                	je     f0104154 <check_page_installed_pgdir+0x291>
f0104130:	c7 44 24 0c 54 ac 10 	movl   $0xf010ac54,0xc(%esp)
f0104137:	f0 
f0104138:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f010413f:	f0 
f0104140:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0104147:	00 
f0104148:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f010414f:	e8 7b c1 ff ff       	call   f01002cf <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0104154:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0104159:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0104160:	00 
f0104161:	89 04 24             	mov    %eax,(%esp)
f0104164:	e8 87 da ff ff       	call   f0101bf0 <page_remove>
	assert(pp2->pp_ref == 0);
f0104169:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010416c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0104170:	66 85 c0             	test   %ax,%ax
f0104173:	74 24                	je     f0104199 <check_page_installed_pgdir+0x2d6>
f0104175:	c7 44 24 0c 0d a9 10 	movl   $0xf010a90d,0xc(%esp)
f010417c:	f0 
f010417d:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0104184:	f0 
f0104185:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f010418c:	00 
f010418d:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0104194:	e8 36 c1 ff ff       	call   f01002cf <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0104199:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f010419e:	8b 00                	mov    (%eax),%eax
f01041a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01041a5:	89 c3                	mov    %eax,%ebx
f01041a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041aa:	89 04 24             	mov    %eax,(%esp)
f01041ad:	e8 77 d0 ff ff       	call   f0101229 <page2pa>
f01041b2:	39 c3                	cmp    %eax,%ebx
f01041b4:	74 24                	je     f01041da <check_page_installed_pgdir+0x317>
f01041b6:	c7 44 24 0c fc a5 10 	movl   $0xf010a5fc,0xc(%esp)
f01041bd:	f0 
f01041be:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f01041c5:	f0 
f01041c6:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f01041cd:	00 
f01041ce:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f01041d5:	e8 f5 c0 ff ff       	call   f01002cf <_panic>
	kern_pgdir[0] = 0;
f01041da:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01041df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01041e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041e8:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01041ec:	66 83 f8 01          	cmp    $0x1,%ax
f01041f0:	74 24                	je     f0104216 <check_page_installed_pgdir+0x353>
f01041f2:	c7 44 24 0c 62 a6 10 	movl   $0xf010a662,0xc(%esp)
f01041f9:	f0 
f01041fa:	c7 44 24 08 da a0 10 	movl   $0xf010a0da,0x8(%esp)
f0104201:	f0 
f0104202:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0104209:	00 
f010420a:	c7 04 24 78 a0 10 f0 	movl   $0xf010a078,(%esp)
f0104211:	e8 b9 c0 ff ff       	call   f01002cf <_panic>
	pp0->pp_ref = 0;
f0104216:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104219:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// free the pages we took
	page_free(pp0);
f010421f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104222:	89 04 24             	mov    %eax,(%esp)
f0104225:	e8 bb d6 ff ff       	call   f01018e5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010422a:	c7 04 24 80 ac 10 f0 	movl   $0xf010ac80,(%esp)
f0104231:	e8 18 0d 00 00       	call   f0104f4e <cprintf>
}
f0104236:	83 c4 24             	add    $0x24,%esp
f0104239:	5b                   	pop    %ebx
f010423a:	5d                   	pop    %ebp
f010423b:	c3                   	ret    

f010423c <lgdt>:
	__asm __volatile("lidt (%0)" : : "r" (p));
}

static __inline void
lgdt(void *p)
{
f010423c:	55                   	push   %ebp
f010423d:	89 e5                	mov    %esp,%ebp
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010423f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104242:	0f 01 10             	lgdtl  (%eax)
}
f0104245:	5d                   	pop    %ebp
f0104246:	c3                   	ret    

f0104247 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0104247:	55                   	push   %ebp
f0104248:	89 e5                	mov    %esp,%ebp
f010424a:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f010424d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104250:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104255:	77 21                	ja     f0104278 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104257:	8b 45 10             	mov    0x10(%ebp),%eax
f010425a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010425e:	c7 44 24 08 ac ac 10 	movl   $0xf010acac,0x8(%esp)
f0104265:	f0 
f0104266:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104269:	89 44 24 04          	mov    %eax,0x4(%esp)
f010426d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104270:	89 04 24             	mov    %eax,(%esp)
f0104273:	e8 57 c0 ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104278:	8b 45 10             	mov    0x10(%ebp),%eax
f010427b:	05 00 00 00 10       	add    $0x10000000,%eax
}
f0104280:	c9                   	leave  
f0104281:	c3                   	ret    

f0104282 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0104282:	55                   	push   %ebp
f0104283:	89 e5                	mov    %esp,%ebp
f0104285:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0104288:	8b 45 10             	mov    0x10(%ebp),%eax
f010428b:	c1 e8 0c             	shr    $0xc,%eax
f010428e:	89 c2                	mov    %eax,%edx
f0104290:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f0104295:	39 c2                	cmp    %eax,%edx
f0104297:	72 21                	jb     f01042ba <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104299:	8b 45 10             	mov    0x10(%ebp),%eax
f010429c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01042a0:	c7 44 24 08 d0 ac 10 	movl   $0xf010acd0,0x8(%esp)
f01042a7:	f0 
f01042a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042af:	8b 45 08             	mov    0x8(%ebp),%eax
f01042b2:	89 04 24             	mov    %eax,(%esp)
f01042b5:	e8 15 c0 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f01042ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01042bd:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f01042c2:	c9                   	leave  
f01042c3:	c3                   	ret    

f01042c4 <page2pa>:
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
f01042c4:	55                   	push   %ebp
f01042c5:	89 e5                	mov    %esp,%ebp
	return (pp - pages) << PGSHIFT;
f01042c7:	8b 55 08             	mov    0x8(%ebp),%edx
f01042ca:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f01042cf:	29 c2                	sub    %eax,%edx
f01042d1:	89 d0                	mov    %edx,%eax
f01042d3:	c1 f8 03             	sar    $0x3,%eax
f01042d6:	c1 e0 0c             	shl    $0xc,%eax
}
f01042d9:	5d                   	pop    %ebp
f01042da:	c3                   	ret    

f01042db <pa2page>:

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
f01042db:	55                   	push   %ebp
f01042dc:	89 e5                	mov    %esp,%ebp
f01042de:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f01042e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01042e4:	c1 e8 0c             	shr    $0xc,%eax
f01042e7:	89 c2                	mov    %eax,%edx
f01042e9:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f01042ee:	39 c2                	cmp    %eax,%edx
f01042f0:	72 1c                	jb     f010430e <pa2page+0x33>
		panic("pa2page called with invalid pa");
f01042f2:	c7 44 24 08 f4 ac 10 	movl   $0xf010acf4,0x8(%esp)
f01042f9:	f0 
f01042fa:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0104301:	00 
f0104302:	c7 04 24 13 ad 10 f0 	movl   $0xf010ad13,(%esp)
f0104309:	e8 c1 bf ff ff       	call   f01002cf <_panic>
	return &pages[PGNUM(pa)];
f010430e:	a1 f0 7a 29 f0       	mov    0xf0297af0,%eax
f0104313:	8b 55 08             	mov    0x8(%ebp),%edx
f0104316:	c1 ea 0c             	shr    $0xc,%edx
f0104319:	c1 e2 03             	shl    $0x3,%edx
f010431c:	01 d0                	add    %edx,%eax
}
f010431e:	c9                   	leave  
f010431f:	c3                   	ret    

f0104320 <page2kva>:

static inline void*
page2kva(struct PageInfo *pp)
{
f0104320:	55                   	push   %ebp
f0104321:	89 e5                	mov    %esp,%ebp
f0104323:	83 ec 18             	sub    $0x18,%esp
	return KADDR(page2pa(pp));
f0104326:	8b 45 08             	mov    0x8(%ebp),%eax
f0104329:	89 04 24             	mov    %eax,(%esp)
f010432c:	e8 93 ff ff ff       	call   f01042c4 <page2pa>
f0104331:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104335:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010433c:	00 
f010433d:	c7 04 24 13 ad 10 f0 	movl   $0xf010ad13,(%esp)
f0104344:	e8 39 ff ff ff       	call   f0104282 <_kaddr>
}
f0104349:	c9                   	leave  
f010434a:	c3                   	ret    

f010434b <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010434b:	55                   	push   %ebp
f010434c:	89 e5                	mov    %esp,%ebp
f010434e:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f0104351:	c7 04 24 e0 75 12 f0 	movl   $0xf01275e0,(%esp)
f0104358:	e8 74 54 00 00       	call   f01097d1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010435d:	f3 90                	pause  
}
f010435f:	c9                   	leave  
f0104360:	c3                   	ret    

f0104361 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0104361:	55                   	push   %ebp
f0104362:	89 e5                	mov    %esp,%ebp
f0104364:	53                   	push   %ebx
f0104365:	83 ec 24             	sub    $0x24,%esp
f0104368:	8b 45 10             	mov    0x10(%ebp),%eax
f010436b:	88 45 e4             	mov    %al,-0x1c(%ebp)
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010436e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0104372:	75 1e                	jne    f0104392 <envid2env+0x31>
		*env_store = curenv;
f0104374:	e8 55 51 00 00       	call   f01094ce <cpunum>
f0104379:	6b c0 74             	imul   $0x74,%eax,%eax
f010437c:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104381:	8b 10                	mov    (%eax),%edx
f0104383:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104386:	89 10                	mov    %edx,(%eax)
		return 0;
f0104388:	b8 00 00 00 00       	mov    $0x0,%eax
f010438d:	e9 97 00 00 00       	jmp    f0104429 <envid2env+0xc8>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0104392:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0104398:	8b 45 08             	mov    0x8(%ebp),%eax
f010439b:	25 ff 03 00 00       	and    $0x3ff,%eax
f01043a0:	c1 e0 02             	shl    $0x2,%eax
f01043a3:	89 c1                	mov    %eax,%ecx
f01043a5:	c1 e1 05             	shl    $0x5,%ecx
f01043a8:	29 c1                	sub    %eax,%ecx
f01043aa:	89 c8                	mov    %ecx,%eax
f01043ac:	01 d0                	add    %edx,%eax
f01043ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01043b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043b4:	8b 40 54             	mov    0x54(%eax),%eax
f01043b7:	85 c0                	test   %eax,%eax
f01043b9:	74 0b                	je     f01043c6 <envid2env+0x65>
f01043bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043be:	8b 40 48             	mov    0x48(%eax),%eax
f01043c1:	3b 45 08             	cmp    0x8(%ebp),%eax
f01043c4:	74 10                	je     f01043d6 <envid2env+0x75>
		*env_store = 0;
f01043c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01043cf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01043d4:	eb 53                	jmp    f0104429 <envid2env+0xc8>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01043d6:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
f01043da:	74 40                	je     f010441c <envid2env+0xbb>
f01043dc:	e8 ed 50 00 00       	call   f01094ce <cpunum>
f01043e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e4:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01043e9:	8b 00                	mov    (%eax),%eax
f01043eb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01043ee:	74 2c                	je     f010441c <envid2env+0xbb>
f01043f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043f3:	8b 58 4c             	mov    0x4c(%eax),%ebx
f01043f6:	e8 d3 50 00 00       	call   f01094ce <cpunum>
f01043fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fe:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104403:	8b 00                	mov    (%eax),%eax
f0104405:	8b 40 48             	mov    0x48(%eax),%eax
f0104408:	39 c3                	cmp    %eax,%ebx
f010440a:	74 10                	je     f010441c <envid2env+0xbb>
		*env_store = 0;
f010440c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010440f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0104415:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010441a:	eb 0d                	jmp    f0104429 <envid2env+0xc8>
	}

	*env_store = e;
f010441c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010441f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104422:	89 10                	mov    %edx,(%eax)
	return 0;
f0104424:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104429:	83 c4 24             	add    $0x24,%esp
f010442c:	5b                   	pop    %ebx
f010442d:	5d                   	pop    %ebp
f010442e:	c3                   	ret    

f010442f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010442f:	55                   	push   %ebp
f0104430:	89 e5                	mov    %esp,%ebp
f0104432:	83 ec 18             	sub    $0x18,%esp
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i=NENV-1; i>=0; i--){
f0104435:	c7 45 f4 ff 03 00 00 	movl   $0x3ff,-0xc(%ebp)
f010443c:	eb 5d                	jmp    f010449b <env_init+0x6c>
		envs[i].env_id = 0;
f010443e:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104447:	c1 e0 02             	shl    $0x2,%eax
f010444a:	89 c1                	mov    %eax,%ecx
f010444c:	c1 e1 05             	shl    $0x5,%ecx
f010444f:	29 c1                	sub    %eax,%ecx
f0104451:	89 c8                	mov    %ecx,%eax
f0104453:	01 d0                	add    %edx,%eax
f0104455:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010445c:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0104462:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104465:	c1 e0 02             	shl    $0x2,%eax
f0104468:	89 c1                	mov    %eax,%ecx
f010446a:	c1 e1 05             	shl    $0x5,%ecx
f010446d:	29 c1                	sub    %eax,%ecx
f010446f:	89 c8                	mov    %ecx,%eax
f0104471:	01 c2                	add    %eax,%edx
f0104473:	a1 40 42 29 f0       	mov    0xf0294240,%eax
f0104478:	89 42 44             	mov    %eax,0x44(%edx)
		env_free_list = &envs[i];
f010447b:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0104481:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104484:	c1 e0 02             	shl    $0x2,%eax
f0104487:	89 c1                	mov    %eax,%ecx
f0104489:	c1 e1 05             	shl    $0x5,%ecx
f010448c:	29 c1                	sub    %eax,%ecx
f010448e:	89 c8                	mov    %ecx,%eax
f0104490:	01 d0                	add    %edx,%eax
f0104492:	a3 40 42 29 f0       	mov    %eax,0xf0294240
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i=NENV-1; i>=0; i--){
f0104497:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
f010449b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010449f:	79 9d                	jns    f010443e <env_init+0xf>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01044a1:	e8 02 00 00 00       	call   f01044a8 <env_init_percpu>
}
f01044a6:	c9                   	leave  
f01044a7:	c3                   	ret    

f01044a8 <env_init_percpu>:

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01044a8:	55                   	push   %ebp
f01044a9:	89 e5                	mov    %esp,%ebp
f01044ab:	83 ec 14             	sub    $0x14,%esp
	lgdt(&gdt_pd);
f01044ae:	c7 04 24 c8 75 12 f0 	movl   $0xf01275c8,(%esp)
f01044b5:	e8 82 fd ff ff       	call   f010423c <lgdt>
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01044ba:	b8 23 00 00 00       	mov    $0x23,%eax
f01044bf:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01044c1:	b8 23 00 00 00       	mov    $0x23,%eax
f01044c6:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01044c8:	b8 10 00 00 00       	mov    $0x10,%eax
f01044cd:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01044cf:	b8 10 00 00 00       	mov    $0x10,%eax
f01044d4:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01044d6:	b8 10 00 00 00       	mov    $0x10,%eax
f01044db:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01044dd:	ea e4 44 10 f0 08 00 	ljmp   $0x8,$0xf01044e4
f01044e4:	66 c7 45 fe 00 00    	movw   $0x0,-0x2(%ebp)

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01044ea:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
f01044ee:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01044f1:	c9                   	leave  
f01044f2:	c3                   	ret    

f01044f3 <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f01044f3:	55                   	push   %ebp
f01044f4:	89 e5                	mov    %esp,%ebp
f01044f6:	53                   	push   %ebx
f01044f7:	83 ec 24             	sub    $0x24,%esp
	int i;
	struct PageInfo *p = NULL;
f01044fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0104501:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104508:	e8 75 d3 ff ff       	call   f0101882 <page_alloc>
f010450d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104514:	75 07                	jne    f010451d <env_setup_vm+0x2a>
		return -E_NO_MEM;
f0104516:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010451b:	eb 76                	jmp    f0104593 <env_setup_vm+0xa0>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f010451d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104520:	89 04 24             	mov    %eax,(%esp)
f0104523:	e8 f8 fd ff ff       	call   f0104320 <page2kva>
f0104528:	8b 55 08             	mov    0x8(%ebp),%edx
f010452b:	89 42 60             	mov    %eax,0x60(%edx)
	p->pp_ref++;
f010452e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104531:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0104535:	8d 50 01             	lea    0x1(%eax),%edx
f0104538:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010453b:	66 89 50 04          	mov    %dx,0x4(%eax)
	memcpy(e->env_pgdir,kern_pgdir,PGSIZE);
f010453f:	8b 15 ec 7a 29 f0    	mov    0xf0297aec,%edx
f0104545:	8b 45 08             	mov    0x8(%ebp),%eax
f0104548:	8b 40 60             	mov    0x60(%eax),%eax
f010454b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104552:	00 
f0104553:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104557:	89 04 24             	mov    %eax,(%esp)
f010455a:	e8 ee 45 00 00       	call   f0108b4d <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010455f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104562:	8b 40 60             	mov    0x60(%eax),%eax
f0104565:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f010456b:	8b 45 08             	mov    0x8(%ebp),%eax
f010456e:	8b 40 60             	mov    0x60(%eax),%eax
f0104571:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104575:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f010457c:	00 
f010457d:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104584:	e8 be fc ff ff       	call   f0104247 <_paddr>
f0104589:	83 c8 05             	or     $0x5,%eax
f010458c:	89 03                	mov    %eax,(%ebx)

	return 0;
f010458e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104593:	83 c4 24             	add    $0x24,%esp
f0104596:	5b                   	pop    %ebx
f0104597:	5d                   	pop    %ebp
f0104598:	c3                   	ret    

f0104599 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0104599:	55                   	push   %ebp
f010459a:	89 e5                	mov    %esp,%ebp
f010459c:	83 ec 28             	sub    $0x28,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010459f:	a1 40 42 29 f0       	mov    0xf0294240,%eax
f01045a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01045ab:	75 0a                	jne    f01045b7 <env_alloc+0x1e>
		return -E_NO_FREE_ENV;
f01045ad:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01045b2:	e9 f5 00 00 00       	jmp    f01046ac <env_alloc+0x113>

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
f01045b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045ba:	89 04 24             	mov    %eax,(%esp)
f01045bd:	e8 31 ff ff ff       	call   f01044f3 <env_setup_vm>
f01045c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01045c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01045c9:	79 08                	jns    f01045d3 <env_alloc+0x3a>
		return r;
f01045cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01045ce:	e9 d9 00 00 00       	jmp    f01046ac <env_alloc+0x113>

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01045d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045d6:	8b 40 48             	mov    0x48(%eax),%eax
f01045d9:	05 00 10 00 00       	add    $0x1000,%eax
f01045de:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01045e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f01045e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01045ea:	7f 07                	jg     f01045f3 <env_alloc+0x5a>
		generation = 1 << ENVGENSHIFT;
f01045ec:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f01045f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01045f6:	a1 3c 42 29 f0       	mov    0xf029423c,%eax
f01045fb:	29 c2                	sub    %eax,%edx
f01045fd:	89 d0                	mov    %edx,%eax
f01045ff:	c1 f8 02             	sar    $0x2,%eax
f0104602:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0104608:	0b 45 f4             	or     -0xc(%ebp),%eax
f010460b:	89 c2                	mov    %eax,%edx
f010460d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104610:	89 50 48             	mov    %edx,0x48(%eax)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104613:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104616:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104619:	89 50 4c             	mov    %edx,0x4c(%eax)
	e->env_type = ENV_TYPE_USER;
f010461c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010461f:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f0104626:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104629:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_runs = 0;
f0104630:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104633:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010463a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010463d:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104644:	00 
f0104645:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010464c:	00 
f010464d:	89 04 24             	mov    %eax,(%esp)
f0104650:	e8 b0 43 00 00       	call   f0108a05 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104655:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104658:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f010465e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104661:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0104667:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010466a:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = USTACKTOP;
f0104670:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104673:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f010467a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010467d:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104683:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104686:	c7 40 64 00 00 00 00 	movl   $0x0,0x64(%eax)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010468d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104690:	c6 40 68 00          	movb   $0x0,0x68(%eax)

	// commit the allocation
	env_free_list = e->env_link;
f0104694:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104697:	8b 40 44             	mov    0x44(%eax),%eax
f010469a:	a3 40 42 29 f0       	mov    %eax,0xf0294240
	*newenv_store = e;
f010469f:	8b 45 08             	mov    0x8(%ebp),%eax
f01046a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01046a5:	89 10                	mov    %edx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01046a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046ac:	c9                   	leave  
f01046ad:	c3                   	ret    

f01046ae <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01046ae:	55                   	push   %ebp
f01046af:	89 e5                	mov    %esp,%ebp
f01046b1:	83 ec 38             	sub    $0x38,%esp
	// LAB 3: Your code here.
	int i;
	uintptr_t aligned_va = ROUNDDOWN((uintptr_t)va,PGSIZE);
f01046b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01046ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01046c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	size_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
f01046c5:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f01046cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046cf:	8b 45 10             	mov    0x10(%ebp),%eax
f01046d2:	01 c2                	add    %eax,%edx
f01046d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01046d7:	01 d0                	add    %edx,%eax
f01046d9:	83 e8 01             	sub    $0x1,%eax
f01046dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01046df:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01046e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01046e7:	f7 75 ec             	divl   -0x14(%ebp)
f01046ea:	89 d0                	mov    %edx,%eax
f01046ec:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01046ef:	29 c2                	sub    %eax,%edx
f01046f1:	89 d0                	mov    %edx,%eax
f01046f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;aligned_va < aligned_end_va;aligned_va += PGSIZE){
f01046f6:	eb 6b                	jmp    f0104763 <region_alloc+0xb5>
		struct PageInfo *p = NULL;
f01046f8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		p = page_alloc(!ALLOC_ZERO);
f01046ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104706:	e8 77 d1 ff ff       	call   f0101882 <page_alloc>
f010470b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (!p)
f010470e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104712:	75 24                	jne    f0104738 <region_alloc+0x8a>
			panic("env_alloc: %e",-E_NO_MEM);
f0104714:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f010471b:	ff 
f010471c:	c7 44 24 08 2c ad 10 	movl   $0xf010ad2c,0x8(%esp)
f0104723:	f0 
f0104724:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f010472b:	00 
f010472c:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104733:	e8 97 bb ff ff       	call   f01002cf <_panic>
		page_insert(e->env_pgdir, p, (void*)aligned_va, PTE_P | PTE_U | PTE_W);
f0104738:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010473b:	8b 45 08             	mov    0x8(%ebp),%eax
f010473e:	8b 40 60             	mov    0x60(%eax),%eax
f0104741:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104748:	00 
f0104749:	89 54 24 08          	mov    %edx,0x8(%esp)
f010474d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104750:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104754:	89 04 24             	mov    %eax,(%esp)
f0104757:	e8 af d3 ff ff       	call   f0101b0b <page_insert>
{
	// LAB 3: Your code here.
	int i;
	uintptr_t aligned_va = ROUNDDOWN((uintptr_t)va,PGSIZE);
	size_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
	for(;aligned_va < aligned_end_va;aligned_va += PGSIZE){
f010475c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0104763:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104766:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0104769:	72 8d                	jb     f01046f8 <region_alloc+0x4a>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f010476b:	c9                   	leave  
f010476c:	c3                   	ret    

f010476d <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
void
load_icode(struct Env *e, uint8_t *binary)
{
f010476d:	55                   	push   %ebp
f010476e:	89 e5                	mov    %esp,%ebp
f0104770:	83 ec 38             	sub    $0x38,%esp

	// LAB 3: Your code here.
	struct Proghdr* ph;
	struct Proghdr* eph;
	struct Elf *elfhdr;
	elfhdr = (struct Elf *)binary;
f0104773:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104776:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(elfhdr->e_magic != ELF_MAGIC) panic("Error in ELF!\n");
f0104779:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010477c:	8b 00                	mov    (%eax),%eax
f010477e:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0104783:	74 1c                	je     f01047a1 <load_icode+0x34>
f0104785:	c7 44 24 08 3a ad 10 	movl   $0xf010ad3a,0x8(%esp)
f010478c:	f0 
f010478d:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0104794:	00 
f0104795:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f010479c:	e8 2e bb ff ff       	call   f01002cf <_panic>
	ph = (struct Proghdr *) (binary + elfhdr->e_phoff);
f01047a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047a4:	8b 50 1c             	mov    0x1c(%eax),%edx
f01047a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047aa:	01 d0                	add    %edx,%eax
f01047ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
	eph = ph + elfhdr->e_phnum;
f01047af:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047b2:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f01047b6:	0f b7 c0             	movzwl %ax,%eax
f01047b9:	c1 e0 05             	shl    $0x5,%eax
f01047bc:	89 c2                	mov    %eax,%edx
f01047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047c1:	01 d0                	add    %edx,%eax
f01047c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	lcr3(PADDR(e->env_pgdir));
f01047c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01047c9:	8b 40 60             	mov    0x60(%eax),%eax
f01047cc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047d0:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f01047d7:	00 
f01047d8:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f01047df:	e8 63 fa ff ff       	call   f0104247 <_paddr>
f01047e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01047e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01047ea:	0f 22 d8             	mov    %eax,%cr3
	for (; ph < eph; ph++){
f01047ed:	e9 b4 00 00 00       	jmp    f01048a6 <load_icode+0x139>
		if(ph->p_type == ELF_PROG_LOAD){
f01047f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047f5:	8b 00                	mov    (%eax),%eax
f01047f7:	83 f8 01             	cmp    $0x1,%eax
f01047fa:	0f 85 a2 00 00 00    	jne    f01048a2 <load_icode+0x135>
			if(ph->p_filesz > ph->p_memsz) panic("ph->p_filesz > ph->p_memsz\n");
f0104800:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104803:	8b 50 10             	mov    0x10(%eax),%edx
f0104806:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104809:	8b 40 14             	mov    0x14(%eax),%eax
f010480c:	39 c2                	cmp    %eax,%edx
f010480e:	76 1c                	jbe    f010482c <load_icode+0xbf>
f0104810:	c7 44 24 08 49 ad 10 	movl   $0xf010ad49,0x8(%esp)
f0104817:	f0 
f0104818:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f010481f:	00 
f0104820:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104827:	e8 a3 ba ff ff       	call   f01002cf <_panic>
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f010482c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010482f:	8b 50 14             	mov    0x14(%eax),%edx
f0104832:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104835:	8b 40 08             	mov    0x8(%eax),%eax
f0104838:	89 54 24 08          	mov    %edx,0x8(%esp)
f010483c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104840:	8b 45 08             	mov    0x8(%ebp),%eax
f0104843:	89 04 24             	mov    %eax,(%esp)
f0104846:	e8 63 fe ff ff       	call   f01046ae <region_alloc>
			memcpy((void *)ph->p_va, (void *)(binary + ph->p_offset),ph->p_filesz);
f010484b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010484e:	8b 50 10             	mov    0x10(%eax),%edx
f0104851:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104854:	8b 48 04             	mov    0x4(%eax),%ecx
f0104857:	8b 45 0c             	mov    0xc(%ebp),%eax
f010485a:	01 c1                	add    %eax,%ecx
f010485c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010485f:	8b 40 08             	mov    0x8(%eax),%eax
f0104862:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010486a:	89 04 24             	mov    %eax,(%esp)
f010486d:	e8 db 42 00 00       	call   f0108b4d <memcpy>
			memset((void *)(ph->p_va + ph->p_filesz),0, ph->p_memsz - ph->p_filesz);
f0104872:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104875:	8b 50 14             	mov    0x14(%eax),%edx
f0104878:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010487b:	8b 40 10             	mov    0x10(%eax),%eax
f010487e:	29 c2                	sub    %eax,%edx
f0104880:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104883:	8b 48 08             	mov    0x8(%eax),%ecx
f0104886:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104889:	8b 40 10             	mov    0x10(%eax),%eax
f010488c:	01 c8                	add    %ecx,%eax
f010488e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104892:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104899:	00 
f010489a:	89 04 24             	mov    %eax,(%esp)
f010489d:	e8 63 41 00 00       	call   f0108a05 <memset>
	elfhdr = (struct Elf *)binary;
	if(elfhdr->e_magic != ELF_MAGIC) panic("Error in ELF!\n");
	ph = (struct Proghdr *) (binary + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01048a2:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
f01048a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048a9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01048ac:	0f 82 40 ff ff ff    	jb     f01047f2 <load_icode+0x85>
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e,(void *)(USTACKTOP-PGSIZE),PGSIZE);
f01048b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01048b9:	00 
f01048ba:	c7 44 24 04 00 d0 bf 	movl   $0xeebfd000,0x4(%esp)
f01048c1:	ee 
f01048c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c5:	89 04 24             	mov    %eax,(%esp)
f01048c8:	e8 e1 fd ff ff       	call   f01046ae <region_alloc>
	e->env_tf.tf_eip = elfhdr->e_entry;
f01048cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01048d0:	8b 50 18             	mov    0x18(%eax),%edx
f01048d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01048d6:	89 50 30             	mov    %edx,0x30(%eax)
	lcr3(PADDR(kern_pgdir));
f01048d9:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01048de:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048e2:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f01048e9:	00 
f01048ea:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f01048f1:	e8 51 f9 ff ff       	call   f0104247 <_paddr>
f01048f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01048f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048fc:	0f 22 d8             	mov    %eax,%cr3
}
f01048ff:	c9                   	leave  
f0104900:	c3                   	ret    

f0104901 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0104901:	55                   	push   %ebp
f0104902:	89 e5                	mov    %esp,%ebp
f0104904:	83 ec 28             	sub    $0x28,%esp
	// LAB 3: Your code here.
	struct Env *e;
	if(env_alloc(&e,0) < 0) panic("env_alloc failed!\n");
f0104907:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010490e:	00 
f010490f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104912:	89 04 24             	mov    %eax,(%esp)
f0104915:	e8 7f fc ff ff       	call   f0104599 <env_alloc>
f010491a:	85 c0                	test   %eax,%eax
f010491c:	79 1c                	jns    f010493a <env_create+0x39>
f010491e:	c7 44 24 08 65 ad 10 	movl   $0xf010ad65,0x8(%esp)
f0104925:	f0 
f0104926:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f010492d:	00 
f010492e:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104935:	e8 95 b9 ff ff       	call   f01002cf <_panic>
	load_icode(e,binary);
f010493a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010493d:	8b 55 08             	mov    0x8(%ebp),%edx
f0104940:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104944:	89 04 24             	mov    %eax,(%esp)
f0104947:	e8 21 fe ff ff       	call   f010476d <load_icode>
	e->env_type = type;
f010494c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010494f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104952:	89 50 50             	mov    %edx,0x50(%eax)
	e->env_parent_id = 0;
f0104955:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104958:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
}
f010495f:	c9                   	leave  
f0104960:	c3                   	ret    

f0104961 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0104961:	55                   	push   %ebp
f0104962:	89 e5                	mov    %esp,%ebp
f0104964:	83 ec 38             	sub    $0x38,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0104967:	e8 62 4b 00 00       	call   f01094ce <cpunum>
f010496c:	6b c0 74             	imul   $0x74,%eax,%eax
f010496f:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104974:	8b 00                	mov    (%eax),%eax
f0104976:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104979:	75 26                	jne    f01049a1 <env_free+0x40>
		lcr3(PADDR(kern_pgdir));
f010497b:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0104980:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104984:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f010498b:	00 
f010498c:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104993:	e8 af f8 ff ff       	call   f0104247 <_paddr>
f0104998:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010499b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010499e:	0f 22 d8             	mov    %eax,%cr3
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01049a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01049a8:	e9 cf 00 00 00       	jmp    f0104a7c <env_free+0x11b>

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01049ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01049b0:	8b 40 60             	mov    0x60(%eax),%eax
f01049b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01049b6:	c1 e2 02             	shl    $0x2,%edx
f01049b9:	01 d0                	add    %edx,%eax
f01049bb:	8b 00                	mov    (%eax),%eax
f01049bd:	83 e0 01             	and    $0x1,%eax
f01049c0:	85 c0                	test   %eax,%eax
f01049c2:	75 05                	jne    f01049c9 <env_free+0x68>
			continue;
f01049c4:	e9 af 00 00 00       	jmp    f0104a78 <env_free+0x117>

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01049c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01049cc:	8b 40 60             	mov    0x60(%eax),%eax
f01049cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01049d2:	c1 e2 02             	shl    $0x2,%edx
f01049d5:	01 d0                	add    %edx,%eax
f01049d7:	8b 00                	mov    (%eax),%eax
f01049d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01049de:	89 45 ec             	mov    %eax,-0x14(%ebp)
		pt = (pte_t*) KADDR(pa);
f01049e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01049e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049e8:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01049ef:	00 
f01049f0:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f01049f7:	e8 86 f8 ff ff       	call   f0104282 <_kaddr>
f01049fc:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01049ff:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104a06:	eb 40                	jmp    f0104a48 <env_free+0xe7>
			if (pt[pteno] & PTE_P)
f0104a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a0b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104a12:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104a15:	01 d0                	add    %edx,%eax
f0104a17:	8b 00                	mov    (%eax),%eax
f0104a19:	83 e0 01             	and    $0x1,%eax
f0104a1c:	85 c0                	test   %eax,%eax
f0104a1e:	74 24                	je     f0104a44 <env_free+0xe3>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a23:	c1 e0 16             	shl    $0x16,%eax
f0104a26:	89 c2                	mov    %eax,%edx
f0104a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a2b:	c1 e0 0c             	shl    $0xc,%eax
f0104a2e:	09 d0                	or     %edx,%eax
f0104a30:	89 c2                	mov    %eax,%edx
f0104a32:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a35:	8b 40 60             	mov    0x60(%eax),%eax
f0104a38:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a3c:	89 04 24             	mov    %eax,(%esp)
f0104a3f:	e8 ac d1 ff ff       	call   f0101bf0 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104a44:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0104a48:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0104a4f:	76 b7                	jbe    f0104a08 <env_free+0xa7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104a51:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a54:	8b 40 60             	mov    0x60(%eax),%eax
f0104a57:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a5a:	c1 e2 02             	shl    $0x2,%edx
f0104a5d:	01 d0                	add    %edx,%eax
f0104a5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		page_decref(pa2page(pa));
f0104a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a68:	89 04 24             	mov    %eax,(%esp)
f0104a6b:	e8 6b f8 ff ff       	call   f01042db <pa2page>
f0104a70:	89 04 24             	mov    %eax,(%esp)
f0104a73:	e8 d5 ce ff ff       	call   f010194d <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104a78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104a7c:	81 7d f4 ba 03 00 00 	cmpl   $0x3ba,-0xc(%ebp)
f0104a83:	0f 86 24 ff ff ff    	jbe    f01049ad <env_free+0x4c>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104a89:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a8c:	8b 40 60             	mov    0x60(%eax),%eax
f0104a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a93:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0104a9a:	00 
f0104a9b:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104aa2:	e8 a0 f7 ff ff       	call   f0104247 <_paddr>
f0104aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	e->env_pgdir = 0;
f0104aaa:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aad:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
	page_decref(pa2page(pa));
f0104ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ab7:	89 04 24             	mov    %eax,(%esp)
f0104aba:	e8 1c f8 ff ff       	call   f01042db <pa2page>
f0104abf:	89 04 24             	mov    %eax,(%esp)
f0104ac2:	e8 86 ce ff ff       	call   f010194d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104ac7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aca:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0104ad1:	8b 15 40 42 29 f0    	mov    0xf0294240,%edx
f0104ad7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ada:	89 50 44             	mov    %edx,0x44(%eax)
	env_free_list = e;
f0104add:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ae0:	a3 40 42 29 f0       	mov    %eax,0xf0294240
}
f0104ae5:	c9                   	leave  
f0104ae6:	c3                   	ret    

f0104ae7 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104ae7:	55                   	push   %ebp
f0104ae8:	89 e5                	mov    %esp,%ebp
f0104aea:	83 ec 28             	sub    $0x28,%esp
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	struct Env* parent_env;
	envid2env(e->env_parent_id, &parent_env, 0);
f0104aed:	8b 45 08             	mov    0x8(%ebp),%eax
f0104af0:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104af3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104afa:	00 
f0104afb:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104afe:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b02:	89 04 24             	mov    %eax,(%esp)
f0104b05:	e8 57 f8 ff ff       	call   f0104361 <envid2env>
	if(parent_env->env_status == ENV_WAIT_CHILD){
f0104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b0d:	8b 40 54             	mov    0x54(%eax),%eax
f0104b10:	83 f8 05             	cmp    $0x5,%eax
f0104b13:	75 0a                	jne    f0104b1f <env_destroy+0x38>
		parent_env->env_status = ENV_RUNNABLE;
f0104b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b18:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104b1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b22:	8b 40 54             	mov    0x54(%eax),%eax
f0104b25:	83 f8 03             	cmp    $0x3,%eax
f0104b28:	75 20                	jne    f0104b4a <env_destroy+0x63>
f0104b2a:	e8 9f 49 00 00       	call   f01094ce <cpunum>
f0104b2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b32:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104b37:	8b 00                	mov    (%eax),%eax
f0104b39:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104b3c:	74 0c                	je     f0104b4a <env_destroy+0x63>
		e->env_status = ENV_DYING;
f0104b3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b41:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
f0104b48:	eb 37                	jmp    f0104b81 <env_destroy+0x9a>
		return;
	}

	env_free(e);
f0104b4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b4d:	89 04 24             	mov    %eax,(%esp)
f0104b50:	e8 0c fe ff ff       	call   f0104961 <env_free>

	if (curenv == e) {
f0104b55:	e8 74 49 00 00       	call   f01094ce <cpunum>
f0104b5a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b5d:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104b62:	8b 00                	mov    (%eax),%eax
f0104b64:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104b67:	75 18                	jne    f0104b81 <env_destroy+0x9a>
		curenv = NULL;
f0104b69:	e8 60 49 00 00       	call   f01094ce <cpunum>
f0104b6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b71:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104b76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		sched_yield();
f0104b7c:	e8 6a 1d 00 00       	call   f01068eb <sched_yield>
	}
}
f0104b81:	c9                   	leave  
f0104b82:	c3                   	ret    

f0104b83 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104b83:	55                   	push   %ebp
f0104b84:	89 e5                	mov    %esp,%ebp
f0104b86:	53                   	push   %ebx
f0104b87:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104b8a:	e8 3f 49 00 00       	call   f01094ce <cpunum>
f0104b8f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b92:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104b97:	8b 18                	mov    (%eax),%ebx
f0104b99:	e8 30 49 00 00       	call   f01094ce <cpunum>
f0104b9e:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104ba1:	8b 65 08             	mov    0x8(%ebp),%esp
f0104ba4:	61                   	popa   
f0104ba5:	07                   	pop    %es
f0104ba6:	1f                   	pop    %ds
f0104ba7:	83 c4 08             	add    $0x8,%esp
f0104baa:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104bab:	c7 44 24 08 78 ad 10 	movl   $0xf010ad78,0x8(%esp)
f0104bb2:	f0 
f0104bb3:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
f0104bba:	00 
f0104bbb:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104bc2:	e8 08 b7 ff ff       	call   f01002cf <_panic>

f0104bc7 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104bc7:	55                   	push   %ebp
f0104bc8:	89 e5                	mov    %esp,%ebp
f0104bca:	83 ec 28             	sub    $0x28,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if(curenv && (curenv->env_status == ENV_RUNNING)) curenv->env_status = ENV_RUNNABLE;
f0104bcd:	e8 fc 48 00 00       	call   f01094ce <cpunum>
f0104bd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd5:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104bda:	8b 00                	mov    (%eax),%eax
f0104bdc:	85 c0                	test   %eax,%eax
f0104bde:	74 2d                	je     f0104c0d <env_run+0x46>
f0104be0:	e8 e9 48 00 00       	call   f01094ce <cpunum>
f0104be5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be8:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104bed:	8b 00                	mov    (%eax),%eax
f0104bef:	8b 40 54             	mov    0x54(%eax),%eax
f0104bf2:	83 f8 03             	cmp    $0x3,%eax
f0104bf5:	75 16                	jne    f0104c0d <env_run+0x46>
f0104bf7:	e8 d2 48 00 00       	call   f01094ce <cpunum>
f0104bfc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bff:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104c04:	8b 00                	mov    (%eax),%eax
f0104c06:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0104c0d:	e8 bc 48 00 00       	call   f01094ce <cpunum>
f0104c12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c15:	8d 90 28 80 29 f0    	lea    -0xfd67fd8(%eax),%edx
f0104c1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c1e:	89 02                	mov    %eax,(%edx)
	curenv->env_status = ENV_RUNNING;
f0104c20:	e8 a9 48 00 00       	call   f01094ce <cpunum>
f0104c25:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c28:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104c2d:	8b 00                	mov    (%eax),%eax
f0104c2f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0104c36:	e8 93 48 00 00       	call   f01094ce <cpunum>
f0104c3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c3e:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104c43:	8b 00                	mov    (%eax),%eax
f0104c45:	8b 50 58             	mov    0x58(%eax),%edx
f0104c48:	83 c2 01             	add    $0x1,%edx
f0104c4b:	89 50 58             	mov    %edx,0x58(%eax)
	unlock_kernel();
f0104c4e:	e8 f8 f6 ff ff       	call   f010434b <unlock_kernel>
	lcr3(PADDR(curenv->env_pgdir));
f0104c53:	e8 76 48 00 00       	call   f01094ce <cpunum>
f0104c58:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c5b:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104c60:	8b 00                	mov    (%eax),%eax
f0104c62:	8b 40 60             	mov    0x60(%eax),%eax
f0104c65:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c69:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
f0104c70:	00 
f0104c71:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0104c78:	e8 ca f5 ff ff       	call   f0104247 <_paddr>
f0104c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c83:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(curenv->env_tf));
f0104c86:	e8 43 48 00 00       	call   f01094ce <cpunum>
f0104c8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c8e:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0104c93:	8b 00                	mov    (%eax),%eax
f0104c95:	89 04 24             	mov    %eax,(%esp)
f0104c98:	e8 e6 fe ff ff       	call   f0104b83 <env_pop_tf>

f0104c9d <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104c9d:	55                   	push   %ebp
f0104c9e:	89 e5                	mov    %esp,%ebp
f0104ca0:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104ca3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ca6:	0f b6 c0             	movzbl %al,%eax
f0104ca9:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104cb0:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104cb3:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104cb7:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104cba:	ee                   	out    %al,(%dx)
f0104cbb:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104cc5:	89 c2                	mov    %eax,%edx
f0104cc7:	ec                   	in     (%dx),%al
f0104cc8:	88 45 f3             	mov    %al,-0xd(%ebp)
	return data;
f0104ccb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
	return inb(IO_RTC+1);
f0104ccf:	0f b6 c0             	movzbl %al,%eax
}
f0104cd2:	c9                   	leave  
f0104cd3:	c3                   	ret    

f0104cd4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104cd4:	55                   	push   %ebp
f0104cd5:	89 e5                	mov    %esp,%ebp
f0104cd7:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104cda:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cdd:	0f b6 c0             	movzbl %al,%eax
f0104ce0:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104ce7:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104cea:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104cee:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104cf1:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0104cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cf5:	0f b6 c0             	movzbl %al,%eax
f0104cf8:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)
f0104cff:	88 45 f3             	mov    %al,-0xd(%ebp)
f0104d02:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d06:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d09:	ee                   	out    %al,(%dx)
}
f0104d0a:	c9                   	leave  
f0104d0b:	c3                   	ret    

f0104d0c <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104d0c:	55                   	push   %ebp
f0104d0d:	89 e5                	mov    %esp,%ebp
f0104d0f:	81 ec 88 00 00 00    	sub    $0x88,%esp
	didinit = 1;
f0104d15:	c6 05 44 42 29 f0 01 	movb   $0x1,0xf0294244
f0104d1c:	c7 45 f4 21 00 00 00 	movl   $0x21,-0xc(%ebp)
f0104d23:	c6 45 f3 ff          	movb   $0xff,-0xd(%ebp)
f0104d27:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d2e:	ee                   	out    %al,(%dx)
f0104d2f:	c7 45 ec a1 00 00 00 	movl   $0xa1,-0x14(%ebp)
f0104d36:	c6 45 eb ff          	movb   $0xff,-0x15(%ebp)
f0104d3a:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0104d3e:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104d41:	ee                   	out    %al,(%dx)
f0104d42:	c7 45 e4 20 00 00 00 	movl   $0x20,-0x1c(%ebp)
f0104d49:	c6 45 e3 11          	movb   $0x11,-0x1d(%ebp)
f0104d4d:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0104d51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d54:	ee                   	out    %al,(%dx)
f0104d55:	c7 45 dc 21 00 00 00 	movl   $0x21,-0x24(%ebp)
f0104d5c:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
f0104d60:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0104d64:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d67:	ee                   	out    %al,(%dx)
f0104d68:	c7 45 d4 21 00 00 00 	movl   $0x21,-0x2c(%ebp)
f0104d6f:	c6 45 d3 04          	movb   $0x4,-0x2d(%ebp)
f0104d73:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f0104d77:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d7a:	ee                   	out    %al,(%dx)
f0104d7b:	c7 45 cc 21 00 00 00 	movl   $0x21,-0x34(%ebp)
f0104d82:	c6 45 cb 03          	movb   $0x3,-0x35(%ebp)
f0104d86:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
f0104d8a:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104d8d:	ee                   	out    %al,(%dx)
f0104d8e:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%ebp)
f0104d95:	c6 45 c3 11          	movb   $0x11,-0x3d(%ebp)
f0104d99:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
f0104d9d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104da0:	ee                   	out    %al,(%dx)
f0104da1:	c7 45 bc a1 00 00 00 	movl   $0xa1,-0x44(%ebp)
f0104da8:	c6 45 bb 28          	movb   $0x28,-0x45(%ebp)
f0104dac:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
f0104db0:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104db3:	ee                   	out    %al,(%dx)
f0104db4:	c7 45 b4 a1 00 00 00 	movl   $0xa1,-0x4c(%ebp)
f0104dbb:	c6 45 b3 02          	movb   $0x2,-0x4d(%ebp)
f0104dbf:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
f0104dc3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104dc6:	ee                   	out    %al,(%dx)
f0104dc7:	c7 45 ac a1 00 00 00 	movl   $0xa1,-0x54(%ebp)
f0104dce:	c6 45 ab 01          	movb   $0x1,-0x55(%ebp)
f0104dd2:	0f b6 45 ab          	movzbl -0x55(%ebp),%eax
f0104dd6:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0104dd9:	ee                   	out    %al,(%dx)
f0104dda:	c7 45 a4 20 00 00 00 	movl   $0x20,-0x5c(%ebp)
f0104de1:	c6 45 a3 68          	movb   $0x68,-0x5d(%ebp)
f0104de5:	0f b6 45 a3          	movzbl -0x5d(%ebp),%eax
f0104de9:	8b 55 a4             	mov    -0x5c(%ebp),%edx
f0104dec:	ee                   	out    %al,(%dx)
f0104ded:	c7 45 9c 20 00 00 00 	movl   $0x20,-0x64(%ebp)
f0104df4:	c6 45 9b 0a          	movb   $0xa,-0x65(%ebp)
f0104df8:	0f b6 45 9b          	movzbl -0x65(%ebp),%eax
f0104dfc:	8b 55 9c             	mov    -0x64(%ebp),%edx
f0104dff:	ee                   	out    %al,(%dx)
f0104e00:	c7 45 94 a0 00 00 00 	movl   $0xa0,-0x6c(%ebp)
f0104e07:	c6 45 93 68          	movb   $0x68,-0x6d(%ebp)
f0104e0b:	0f b6 45 93          	movzbl -0x6d(%ebp),%eax
f0104e0f:	8b 55 94             	mov    -0x6c(%ebp),%edx
f0104e12:	ee                   	out    %al,(%dx)
f0104e13:	c7 45 8c a0 00 00 00 	movl   $0xa0,-0x74(%ebp)
f0104e1a:	c6 45 8b 0a          	movb   $0xa,-0x75(%ebp)
f0104e1e:	0f b6 45 8b          	movzbl -0x75(%ebp),%eax
f0104e22:	8b 55 8c             	mov    -0x74(%ebp),%edx
f0104e25:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104e26:	0f b7 05 ce 75 12 f0 	movzwl 0xf01275ce,%eax
f0104e2d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104e31:	74 12                	je     f0104e45 <pic_init+0x139>
		irq_setmask_8259A(irq_mask_8259A);
f0104e33:	0f b7 05 ce 75 12 f0 	movzwl 0xf01275ce,%eax
f0104e3a:	0f b7 c0             	movzwl %ax,%eax
f0104e3d:	89 04 24             	mov    %eax,(%esp)
f0104e40:	e8 02 00 00 00       	call   f0104e47 <irq_setmask_8259A>
}
f0104e45:	c9                   	leave  
f0104e46:	c3                   	ret    

f0104e47 <irq_setmask_8259A>:

void
irq_setmask_8259A(uint16_t mask)
{
f0104e47:	55                   	push   %ebp
f0104e48:	89 e5                	mov    %esp,%ebp
f0104e4a:	83 ec 38             	sub    $0x38,%esp
f0104e4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e50:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
	int i;
	irq_mask_8259A = mask;
f0104e54:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104e58:	66 a3 ce 75 12 f0    	mov    %ax,0xf01275ce
	if (!didinit)
f0104e5e:	0f b6 05 44 42 29 f0 	movzbl 0xf0294244,%eax
f0104e65:	83 f0 01             	xor    $0x1,%eax
f0104e68:	84 c0                	test   %al,%al
f0104e6a:	74 05                	je     f0104e71 <irq_setmask_8259A+0x2a>
		return;
f0104e6c:	e9 8c 00 00 00       	jmp    f0104efd <irq_setmask_8259A+0xb6>
	outb(IO_PIC1+1, (char)mask);
f0104e71:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104e75:	0f b6 c0             	movzbl %al,%eax
f0104e78:	c7 45 f0 21 00 00 00 	movl   $0x21,-0x10(%ebp)
f0104e7f:	88 45 ef             	mov    %al,-0x11(%ebp)
f0104e82:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0104e86:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104e89:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104e8a:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104e8e:	66 c1 e8 08          	shr    $0x8,%ax
f0104e92:	0f b6 c0             	movzbl %al,%eax
f0104e95:	c7 45 e8 a1 00 00 00 	movl   $0xa1,-0x18(%ebp)
f0104e9c:	88 45 e7             	mov    %al,-0x19(%ebp)
f0104e9f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0104ea3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104ea6:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104ea7:	c7 04 24 84 ad 10 f0 	movl   $0xf010ad84,(%esp)
f0104eae:	e8 9b 00 00 00       	call   f0104f4e <cprintf>
	for (i = 0; i < 16; i++)
f0104eb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0104eba:	eb 2f                	jmp    f0104eeb <irq_setmask_8259A+0xa4>
		if (~mask & (1<<i))
f0104ebc:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104ec0:	f7 d0                	not    %eax
f0104ec2:	89 c2                	mov    %eax,%edx
f0104ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ec7:	89 c1                	mov    %eax,%ecx
f0104ec9:	d3 fa                	sar    %cl,%edx
f0104ecb:	89 d0                	mov    %edx,%eax
f0104ecd:	83 e0 01             	and    $0x1,%eax
f0104ed0:	85 c0                	test   %eax,%eax
f0104ed2:	74 13                	je     f0104ee7 <irq_setmask_8259A+0xa0>
			cprintf(" %d", i);
f0104ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104edb:	c7 04 24 98 ad 10 f0 	movl   $0xf010ad98,(%esp)
f0104ee2:	e8 67 00 00 00       	call   f0104f4e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104ee7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104eeb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
f0104eef:	7e cb                	jle    f0104ebc <irq_setmask_8259A+0x75>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104ef1:	c7 04 24 9c ad 10 f0 	movl   $0xf010ad9c,(%esp)
f0104ef8:	e8 51 00 00 00       	call   f0104f4e <cprintf>
}
f0104efd:	c9                   	leave  
f0104efe:	c3                   	ret    

f0104eff <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104eff:	55                   	push   %ebp
f0104f00:	89 e5                	mov    %esp,%ebp
f0104f02:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104f05:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f08:	89 04 24             	mov    %eax,(%esp)
f0104f0b:	e8 90 bc ff ff       	call   f0100ba0 <cputchar>
	*cnt++;
f0104f10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f13:	83 c0 04             	add    $0x4,%eax
f0104f16:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0104f19:	c9                   	leave  
f0104f1a:	c3                   	ret    

f0104f1b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104f1b:	55                   	push   %ebp
f0104f1c:	89 e5                	mov    %esp,%ebp
f0104f1e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104f21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104f28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f32:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f36:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f3d:	c7 04 24 ff 4e 10 f0 	movl   $0xf0104eff,(%esp)
f0104f44:	e8 b0 32 00 00       	call   f01081f9 <vprintfmt>
	return cnt;
f0104f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104f4c:	c9                   	leave  
f0104f4d:	c3                   	ret    

f0104f4e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104f4e:	55                   	push   %ebp
f0104f4f:	89 e5                	mov    %esp,%ebp
f0104f51:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104f54:	8d 45 0c             	lea    0xc(%ebp),%eax
f0104f57:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
f0104f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f61:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f64:	89 04 24             	mov    %eax,(%esp)
f0104f67:	e8 af ff ff ff       	call   f0104f1b <vcprintf>
f0104f6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
f0104f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104f72:	c9                   	leave  
f0104f73:	c3                   	ret    

f0104f74 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0104f74:	55                   	push   %ebp
f0104f75:	89 e5                	mov    %esp,%ebp
f0104f77:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104f7a:	8b 55 08             	mov    0x8(%ebp),%edx
f0104f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f80:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f83:	f0 87 02             	lock xchg %eax,(%edx)
f0104f86:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0104f89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104f8c:	c9                   	leave  
f0104f8d:	c3                   	ret    

f0104f8e <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0104f8e:	55                   	push   %ebp
f0104f8f:	89 e5                	mov    %esp,%ebp
f0104f91:	83 ec 18             	sub    $0x18,%esp
	spin_lock(&kernel_lock);
f0104f94:	c7 04 24 e0 75 12 f0 	movl   $0xf01275e0,(%esp)
f0104f9b:	e8 a9 47 00 00       	call   f0109749 <spin_lock>
}
f0104fa0:	c9                   	leave  
f0104fa1:	c3                   	ret    

f0104fa2 <trapname>:
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
f0104fa2:	55                   	push   %ebp
f0104fa3:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104fa5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fa8:	83 f8 13             	cmp    $0x13,%eax
f0104fab:	77 0c                	ja     f0104fb9 <trapname+0x17>
		return excnames[trapno];
f0104fad:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb0:	8b 04 85 a0 b2 10 f0 	mov    -0xfef4d60(,%eax,4),%eax
f0104fb7:	eb 25                	jmp    f0104fde <trapname+0x3c>
	if (trapno == T_SYSCALL)
f0104fb9:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f0104fbd:	75 07                	jne    f0104fc6 <trapname+0x24>
		return "System call";
f0104fbf:	b8 a0 ad 10 f0       	mov    $0xf010ada0,%eax
f0104fc4:	eb 18                	jmp    f0104fde <trapname+0x3c>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104fc6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
f0104fca:	7e 0d                	jle    f0104fd9 <trapname+0x37>
f0104fcc:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
f0104fd0:	7f 07                	jg     f0104fd9 <trapname+0x37>
		return "Hardware Interrupt";
f0104fd2:	b8 ac ad 10 f0       	mov    $0xf010adac,%eax
f0104fd7:	eb 05                	jmp    f0104fde <trapname+0x3c>
	return "(unknown trap)";
f0104fd9:	b8 bf ad 10 f0       	mov    $0xf010adbf,%eax
}
f0104fde:	5d                   	pop    %ebp
f0104fdf:	c3                   	ret    

f0104fe0 <trap_init>:
void irq_ide();
void irq_error();

void
trap_init(void)
{
f0104fe0:	55                   	push   %ebp
f0104fe1:	89 e5                	mov    %esp,%ebp
f0104fe3:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0104fe6:	b8 ec 67 10 f0       	mov    $0xf01067ec,%eax
f0104feb:	66 a3 60 42 29 f0    	mov    %ax,0xf0294260
f0104ff1:	66 c7 05 62 42 29 f0 	movw   $0x8,0xf0294262
f0104ff8:	08 00 
f0104ffa:	0f b6 05 64 42 29 f0 	movzbl 0xf0294264,%eax
f0105001:	83 e0 e0             	and    $0xffffffe0,%eax
f0105004:	a2 64 42 29 f0       	mov    %al,0xf0294264
f0105009:	0f b6 05 64 42 29 f0 	movzbl 0xf0294264,%eax
f0105010:	83 e0 1f             	and    $0x1f,%eax
f0105013:	a2 64 42 29 f0       	mov    %al,0xf0294264
f0105018:	0f b6 05 65 42 29 f0 	movzbl 0xf0294265,%eax
f010501f:	83 e0 f0             	and    $0xfffffff0,%eax
f0105022:	83 c8 0e             	or     $0xe,%eax
f0105025:	a2 65 42 29 f0       	mov    %al,0xf0294265
f010502a:	0f b6 05 65 42 29 f0 	movzbl 0xf0294265,%eax
f0105031:	83 e0 ef             	and    $0xffffffef,%eax
f0105034:	a2 65 42 29 f0       	mov    %al,0xf0294265
f0105039:	0f b6 05 65 42 29 f0 	movzbl 0xf0294265,%eax
f0105040:	83 e0 9f             	and    $0xffffff9f,%eax
f0105043:	a2 65 42 29 f0       	mov    %al,0xf0294265
f0105048:	0f b6 05 65 42 29 f0 	movzbl 0xf0294265,%eax
f010504f:	83 c8 80             	or     $0xffffff80,%eax
f0105052:	a2 65 42 29 f0       	mov    %al,0xf0294265
f0105057:	b8 ec 67 10 f0       	mov    $0xf01067ec,%eax
f010505c:	c1 e8 10             	shr    $0x10,%eax
f010505f:	66 a3 66 42 29 f0    	mov    %ax,0xf0294266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0105065:	b8 f2 67 10 f0       	mov    $0xf01067f2,%eax
f010506a:	66 a3 68 42 29 f0    	mov    %ax,0xf0294268
f0105070:	66 c7 05 6a 42 29 f0 	movw   $0x8,0xf029426a
f0105077:	08 00 
f0105079:	0f b6 05 6c 42 29 f0 	movzbl 0xf029426c,%eax
f0105080:	83 e0 e0             	and    $0xffffffe0,%eax
f0105083:	a2 6c 42 29 f0       	mov    %al,0xf029426c
f0105088:	0f b6 05 6c 42 29 f0 	movzbl 0xf029426c,%eax
f010508f:	83 e0 1f             	and    $0x1f,%eax
f0105092:	a2 6c 42 29 f0       	mov    %al,0xf029426c
f0105097:	0f b6 05 6d 42 29 f0 	movzbl 0xf029426d,%eax
f010509e:	83 e0 f0             	and    $0xfffffff0,%eax
f01050a1:	83 c8 0e             	or     $0xe,%eax
f01050a4:	a2 6d 42 29 f0       	mov    %al,0xf029426d
f01050a9:	0f b6 05 6d 42 29 f0 	movzbl 0xf029426d,%eax
f01050b0:	83 e0 ef             	and    $0xffffffef,%eax
f01050b3:	a2 6d 42 29 f0       	mov    %al,0xf029426d
f01050b8:	0f b6 05 6d 42 29 f0 	movzbl 0xf029426d,%eax
f01050bf:	83 e0 9f             	and    $0xffffff9f,%eax
f01050c2:	a2 6d 42 29 f0       	mov    %al,0xf029426d
f01050c7:	0f b6 05 6d 42 29 f0 	movzbl 0xf029426d,%eax
f01050ce:	83 c8 80             	or     $0xffffff80,%eax
f01050d1:	a2 6d 42 29 f0       	mov    %al,0xf029426d
f01050d6:	b8 f2 67 10 f0       	mov    $0xf01067f2,%eax
f01050db:	c1 e8 10             	shr    $0x10,%eax
f01050de:	66 a3 6e 42 29 f0    	mov    %ax,0xf029426e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01050e4:	b8 f8 67 10 f0       	mov    $0xf01067f8,%eax
f01050e9:	66 a3 70 42 29 f0    	mov    %ax,0xf0294270
f01050ef:	66 c7 05 72 42 29 f0 	movw   $0x8,0xf0294272
f01050f6:	08 00 
f01050f8:	0f b6 05 74 42 29 f0 	movzbl 0xf0294274,%eax
f01050ff:	83 e0 e0             	and    $0xffffffe0,%eax
f0105102:	a2 74 42 29 f0       	mov    %al,0xf0294274
f0105107:	0f b6 05 74 42 29 f0 	movzbl 0xf0294274,%eax
f010510e:	83 e0 1f             	and    $0x1f,%eax
f0105111:	a2 74 42 29 f0       	mov    %al,0xf0294274
f0105116:	0f b6 05 75 42 29 f0 	movzbl 0xf0294275,%eax
f010511d:	83 e0 f0             	and    $0xfffffff0,%eax
f0105120:	83 c8 0e             	or     $0xe,%eax
f0105123:	a2 75 42 29 f0       	mov    %al,0xf0294275
f0105128:	0f b6 05 75 42 29 f0 	movzbl 0xf0294275,%eax
f010512f:	83 e0 ef             	and    $0xffffffef,%eax
f0105132:	a2 75 42 29 f0       	mov    %al,0xf0294275
f0105137:	0f b6 05 75 42 29 f0 	movzbl 0xf0294275,%eax
f010513e:	83 e0 9f             	and    $0xffffff9f,%eax
f0105141:	a2 75 42 29 f0       	mov    %al,0xf0294275
f0105146:	0f b6 05 75 42 29 f0 	movzbl 0xf0294275,%eax
f010514d:	83 c8 80             	or     $0xffffff80,%eax
f0105150:	a2 75 42 29 f0       	mov    %al,0xf0294275
f0105155:	b8 f8 67 10 f0       	mov    $0xf01067f8,%eax
f010515a:	c1 e8 10             	shr    $0x10,%eax
f010515d:	66 a3 76 42 29 f0    	mov    %ax,0xf0294276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0105163:	b8 fe 67 10 f0       	mov    $0xf01067fe,%eax
f0105168:	66 a3 78 42 29 f0    	mov    %ax,0xf0294278
f010516e:	66 c7 05 7a 42 29 f0 	movw   $0x8,0xf029427a
f0105175:	08 00 
f0105177:	0f b6 05 7c 42 29 f0 	movzbl 0xf029427c,%eax
f010517e:	83 e0 e0             	and    $0xffffffe0,%eax
f0105181:	a2 7c 42 29 f0       	mov    %al,0xf029427c
f0105186:	0f b6 05 7c 42 29 f0 	movzbl 0xf029427c,%eax
f010518d:	83 e0 1f             	and    $0x1f,%eax
f0105190:	a2 7c 42 29 f0       	mov    %al,0xf029427c
f0105195:	0f b6 05 7d 42 29 f0 	movzbl 0xf029427d,%eax
f010519c:	83 e0 f0             	and    $0xfffffff0,%eax
f010519f:	83 c8 0e             	or     $0xe,%eax
f01051a2:	a2 7d 42 29 f0       	mov    %al,0xf029427d
f01051a7:	0f b6 05 7d 42 29 f0 	movzbl 0xf029427d,%eax
f01051ae:	83 e0 ef             	and    $0xffffffef,%eax
f01051b1:	a2 7d 42 29 f0       	mov    %al,0xf029427d
f01051b6:	0f b6 05 7d 42 29 f0 	movzbl 0xf029427d,%eax
f01051bd:	83 c8 60             	or     $0x60,%eax
f01051c0:	a2 7d 42 29 f0       	mov    %al,0xf029427d
f01051c5:	0f b6 05 7d 42 29 f0 	movzbl 0xf029427d,%eax
f01051cc:	83 c8 80             	or     $0xffffff80,%eax
f01051cf:	a2 7d 42 29 f0       	mov    %al,0xf029427d
f01051d4:	b8 fe 67 10 f0       	mov    $0xf01067fe,%eax
f01051d9:	c1 e8 10             	shr    $0x10,%eax
f01051dc:	66 a3 7e 42 29 f0    	mov    %ax,0xf029427e
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01051e2:	b8 04 68 10 f0       	mov    $0xf0106804,%eax
f01051e7:	66 a3 88 42 29 f0    	mov    %ax,0xf0294288
f01051ed:	66 c7 05 8a 42 29 f0 	movw   $0x8,0xf029428a
f01051f4:	08 00 
f01051f6:	0f b6 05 8c 42 29 f0 	movzbl 0xf029428c,%eax
f01051fd:	83 e0 e0             	and    $0xffffffe0,%eax
f0105200:	a2 8c 42 29 f0       	mov    %al,0xf029428c
f0105205:	0f b6 05 8c 42 29 f0 	movzbl 0xf029428c,%eax
f010520c:	83 e0 1f             	and    $0x1f,%eax
f010520f:	a2 8c 42 29 f0       	mov    %al,0xf029428c
f0105214:	0f b6 05 8d 42 29 f0 	movzbl 0xf029428d,%eax
f010521b:	83 e0 f0             	and    $0xfffffff0,%eax
f010521e:	83 c8 0e             	or     $0xe,%eax
f0105221:	a2 8d 42 29 f0       	mov    %al,0xf029428d
f0105226:	0f b6 05 8d 42 29 f0 	movzbl 0xf029428d,%eax
f010522d:	83 e0 ef             	and    $0xffffffef,%eax
f0105230:	a2 8d 42 29 f0       	mov    %al,0xf029428d
f0105235:	0f b6 05 8d 42 29 f0 	movzbl 0xf029428d,%eax
f010523c:	83 e0 9f             	and    $0xffffff9f,%eax
f010523f:	a2 8d 42 29 f0       	mov    %al,0xf029428d
f0105244:	0f b6 05 8d 42 29 f0 	movzbl 0xf029428d,%eax
f010524b:	83 c8 80             	or     $0xffffff80,%eax
f010524e:	a2 8d 42 29 f0       	mov    %al,0xf029428d
f0105253:	b8 04 68 10 f0       	mov    $0xf0106804,%eax
f0105258:	c1 e8 10             	shr    $0x10,%eax
f010525b:	66 a3 8e 42 29 f0    	mov    %ax,0xf029428e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0105261:	b8 0a 68 10 f0       	mov    $0xf010680a,%eax
f0105266:	66 a3 90 42 29 f0    	mov    %ax,0xf0294290
f010526c:	66 c7 05 92 42 29 f0 	movw   $0x8,0xf0294292
f0105273:	08 00 
f0105275:	0f b6 05 94 42 29 f0 	movzbl 0xf0294294,%eax
f010527c:	83 e0 e0             	and    $0xffffffe0,%eax
f010527f:	a2 94 42 29 f0       	mov    %al,0xf0294294
f0105284:	0f b6 05 94 42 29 f0 	movzbl 0xf0294294,%eax
f010528b:	83 e0 1f             	and    $0x1f,%eax
f010528e:	a2 94 42 29 f0       	mov    %al,0xf0294294
f0105293:	0f b6 05 95 42 29 f0 	movzbl 0xf0294295,%eax
f010529a:	83 e0 f0             	and    $0xfffffff0,%eax
f010529d:	83 c8 0e             	or     $0xe,%eax
f01052a0:	a2 95 42 29 f0       	mov    %al,0xf0294295
f01052a5:	0f b6 05 95 42 29 f0 	movzbl 0xf0294295,%eax
f01052ac:	83 e0 ef             	and    $0xffffffef,%eax
f01052af:	a2 95 42 29 f0       	mov    %al,0xf0294295
f01052b4:	0f b6 05 95 42 29 f0 	movzbl 0xf0294295,%eax
f01052bb:	83 e0 9f             	and    $0xffffff9f,%eax
f01052be:	a2 95 42 29 f0       	mov    %al,0xf0294295
f01052c3:	0f b6 05 95 42 29 f0 	movzbl 0xf0294295,%eax
f01052ca:	83 c8 80             	or     $0xffffff80,%eax
f01052cd:	a2 95 42 29 f0       	mov    %al,0xf0294295
f01052d2:	b8 0a 68 10 f0       	mov    $0xf010680a,%eax
f01052d7:	c1 e8 10             	shr    $0x10,%eax
f01052da:	66 a3 96 42 29 f0    	mov    %ax,0xf0294296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01052e0:	b8 10 68 10 f0       	mov    $0xf0106810,%eax
f01052e5:	66 a3 98 42 29 f0    	mov    %ax,0xf0294298
f01052eb:	66 c7 05 9a 42 29 f0 	movw   $0x8,0xf029429a
f01052f2:	08 00 
f01052f4:	0f b6 05 9c 42 29 f0 	movzbl 0xf029429c,%eax
f01052fb:	83 e0 e0             	and    $0xffffffe0,%eax
f01052fe:	a2 9c 42 29 f0       	mov    %al,0xf029429c
f0105303:	0f b6 05 9c 42 29 f0 	movzbl 0xf029429c,%eax
f010530a:	83 e0 1f             	and    $0x1f,%eax
f010530d:	a2 9c 42 29 f0       	mov    %al,0xf029429c
f0105312:	0f b6 05 9d 42 29 f0 	movzbl 0xf029429d,%eax
f0105319:	83 e0 f0             	and    $0xfffffff0,%eax
f010531c:	83 c8 0e             	or     $0xe,%eax
f010531f:	a2 9d 42 29 f0       	mov    %al,0xf029429d
f0105324:	0f b6 05 9d 42 29 f0 	movzbl 0xf029429d,%eax
f010532b:	83 e0 ef             	and    $0xffffffef,%eax
f010532e:	a2 9d 42 29 f0       	mov    %al,0xf029429d
f0105333:	0f b6 05 9d 42 29 f0 	movzbl 0xf029429d,%eax
f010533a:	83 e0 9f             	and    $0xffffff9f,%eax
f010533d:	a2 9d 42 29 f0       	mov    %al,0xf029429d
f0105342:	0f b6 05 9d 42 29 f0 	movzbl 0xf029429d,%eax
f0105349:	83 c8 80             	or     $0xffffff80,%eax
f010534c:	a2 9d 42 29 f0       	mov    %al,0xf029429d
f0105351:	b8 10 68 10 f0       	mov    $0xf0106810,%eax
f0105356:	c1 e8 10             	shr    $0x10,%eax
f0105359:	66 a3 9e 42 29 f0    	mov    %ax,0xf029429e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f010535f:	b8 16 68 10 f0       	mov    $0xf0106816,%eax
f0105364:	66 a3 a0 42 29 f0    	mov    %ax,0xf02942a0
f010536a:	66 c7 05 a2 42 29 f0 	movw   $0x8,0xf02942a2
f0105371:	08 00 
f0105373:	0f b6 05 a4 42 29 f0 	movzbl 0xf02942a4,%eax
f010537a:	83 e0 e0             	and    $0xffffffe0,%eax
f010537d:	a2 a4 42 29 f0       	mov    %al,0xf02942a4
f0105382:	0f b6 05 a4 42 29 f0 	movzbl 0xf02942a4,%eax
f0105389:	83 e0 1f             	and    $0x1f,%eax
f010538c:	a2 a4 42 29 f0       	mov    %al,0xf02942a4
f0105391:	0f b6 05 a5 42 29 f0 	movzbl 0xf02942a5,%eax
f0105398:	83 e0 f0             	and    $0xfffffff0,%eax
f010539b:	83 c8 0e             	or     $0xe,%eax
f010539e:	a2 a5 42 29 f0       	mov    %al,0xf02942a5
f01053a3:	0f b6 05 a5 42 29 f0 	movzbl 0xf02942a5,%eax
f01053aa:	83 e0 ef             	and    $0xffffffef,%eax
f01053ad:	a2 a5 42 29 f0       	mov    %al,0xf02942a5
f01053b2:	0f b6 05 a5 42 29 f0 	movzbl 0xf02942a5,%eax
f01053b9:	83 e0 9f             	and    $0xffffff9f,%eax
f01053bc:	a2 a5 42 29 f0       	mov    %al,0xf02942a5
f01053c1:	0f b6 05 a5 42 29 f0 	movzbl 0xf02942a5,%eax
f01053c8:	83 c8 80             	or     $0xffffff80,%eax
f01053cb:	a2 a5 42 29 f0       	mov    %al,0xf02942a5
f01053d0:	b8 16 68 10 f0       	mov    $0xf0106816,%eax
f01053d5:	c1 e8 10             	shr    $0x10,%eax
f01053d8:	66 a3 a6 42 29 f0    	mov    %ax,0xf02942a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01053de:	b8 1a 68 10 f0       	mov    $0xf010681a,%eax
f01053e3:	66 a3 b0 42 29 f0    	mov    %ax,0xf02942b0
f01053e9:	66 c7 05 b2 42 29 f0 	movw   $0x8,0xf02942b2
f01053f0:	08 00 
f01053f2:	0f b6 05 b4 42 29 f0 	movzbl 0xf02942b4,%eax
f01053f9:	83 e0 e0             	and    $0xffffffe0,%eax
f01053fc:	a2 b4 42 29 f0       	mov    %al,0xf02942b4
f0105401:	0f b6 05 b4 42 29 f0 	movzbl 0xf02942b4,%eax
f0105408:	83 e0 1f             	and    $0x1f,%eax
f010540b:	a2 b4 42 29 f0       	mov    %al,0xf02942b4
f0105410:	0f b6 05 b5 42 29 f0 	movzbl 0xf02942b5,%eax
f0105417:	83 e0 f0             	and    $0xfffffff0,%eax
f010541a:	83 c8 0e             	or     $0xe,%eax
f010541d:	a2 b5 42 29 f0       	mov    %al,0xf02942b5
f0105422:	0f b6 05 b5 42 29 f0 	movzbl 0xf02942b5,%eax
f0105429:	83 e0 ef             	and    $0xffffffef,%eax
f010542c:	a2 b5 42 29 f0       	mov    %al,0xf02942b5
f0105431:	0f b6 05 b5 42 29 f0 	movzbl 0xf02942b5,%eax
f0105438:	83 e0 9f             	and    $0xffffff9f,%eax
f010543b:	a2 b5 42 29 f0       	mov    %al,0xf02942b5
f0105440:	0f b6 05 b5 42 29 f0 	movzbl 0xf02942b5,%eax
f0105447:	83 c8 80             	or     $0xffffff80,%eax
f010544a:	a2 b5 42 29 f0       	mov    %al,0xf02942b5
f010544f:	b8 1a 68 10 f0       	mov    $0xf010681a,%eax
f0105454:	c1 e8 10             	shr    $0x10,%eax
f0105457:	66 a3 b6 42 29 f0    	mov    %ax,0xf02942b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f010545d:	b8 1e 68 10 f0       	mov    $0xf010681e,%eax
f0105462:	66 a3 b8 42 29 f0    	mov    %ax,0xf02942b8
f0105468:	66 c7 05 ba 42 29 f0 	movw   $0x8,0xf02942ba
f010546f:	08 00 
f0105471:	0f b6 05 bc 42 29 f0 	movzbl 0xf02942bc,%eax
f0105478:	83 e0 e0             	and    $0xffffffe0,%eax
f010547b:	a2 bc 42 29 f0       	mov    %al,0xf02942bc
f0105480:	0f b6 05 bc 42 29 f0 	movzbl 0xf02942bc,%eax
f0105487:	83 e0 1f             	and    $0x1f,%eax
f010548a:	a2 bc 42 29 f0       	mov    %al,0xf02942bc
f010548f:	0f b6 05 bd 42 29 f0 	movzbl 0xf02942bd,%eax
f0105496:	83 e0 f0             	and    $0xfffffff0,%eax
f0105499:	83 c8 0e             	or     $0xe,%eax
f010549c:	a2 bd 42 29 f0       	mov    %al,0xf02942bd
f01054a1:	0f b6 05 bd 42 29 f0 	movzbl 0xf02942bd,%eax
f01054a8:	83 e0 ef             	and    $0xffffffef,%eax
f01054ab:	a2 bd 42 29 f0       	mov    %al,0xf02942bd
f01054b0:	0f b6 05 bd 42 29 f0 	movzbl 0xf02942bd,%eax
f01054b7:	83 e0 9f             	and    $0xffffff9f,%eax
f01054ba:	a2 bd 42 29 f0       	mov    %al,0xf02942bd
f01054bf:	0f b6 05 bd 42 29 f0 	movzbl 0xf02942bd,%eax
f01054c6:	83 c8 80             	or     $0xffffff80,%eax
f01054c9:	a2 bd 42 29 f0       	mov    %al,0xf02942bd
f01054ce:	b8 1e 68 10 f0       	mov    $0xf010681e,%eax
f01054d3:	c1 e8 10             	shr    $0x10,%eax
f01054d6:	66 a3 be 42 29 f0    	mov    %ax,0xf02942be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01054dc:	b8 22 68 10 f0       	mov    $0xf0106822,%eax
f01054e1:	66 a3 c0 42 29 f0    	mov    %ax,0xf02942c0
f01054e7:	66 c7 05 c2 42 29 f0 	movw   $0x8,0xf02942c2
f01054ee:	08 00 
f01054f0:	0f b6 05 c4 42 29 f0 	movzbl 0xf02942c4,%eax
f01054f7:	83 e0 e0             	and    $0xffffffe0,%eax
f01054fa:	a2 c4 42 29 f0       	mov    %al,0xf02942c4
f01054ff:	0f b6 05 c4 42 29 f0 	movzbl 0xf02942c4,%eax
f0105506:	83 e0 1f             	and    $0x1f,%eax
f0105509:	a2 c4 42 29 f0       	mov    %al,0xf02942c4
f010550e:	0f b6 05 c5 42 29 f0 	movzbl 0xf02942c5,%eax
f0105515:	83 e0 f0             	and    $0xfffffff0,%eax
f0105518:	83 c8 0e             	or     $0xe,%eax
f010551b:	a2 c5 42 29 f0       	mov    %al,0xf02942c5
f0105520:	0f b6 05 c5 42 29 f0 	movzbl 0xf02942c5,%eax
f0105527:	83 e0 ef             	and    $0xffffffef,%eax
f010552a:	a2 c5 42 29 f0       	mov    %al,0xf02942c5
f010552f:	0f b6 05 c5 42 29 f0 	movzbl 0xf02942c5,%eax
f0105536:	83 e0 9f             	and    $0xffffff9f,%eax
f0105539:	a2 c5 42 29 f0       	mov    %al,0xf02942c5
f010553e:	0f b6 05 c5 42 29 f0 	movzbl 0xf02942c5,%eax
f0105545:	83 c8 80             	or     $0xffffff80,%eax
f0105548:	a2 c5 42 29 f0       	mov    %al,0xf02942c5
f010554d:	b8 22 68 10 f0       	mov    $0xf0106822,%eax
f0105552:	c1 e8 10             	shr    $0x10,%eax
f0105555:	66 a3 c6 42 29 f0    	mov    %ax,0xf02942c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f010555b:	b8 26 68 10 f0       	mov    $0xf0106826,%eax
f0105560:	66 a3 c8 42 29 f0    	mov    %ax,0xf02942c8
f0105566:	66 c7 05 ca 42 29 f0 	movw   $0x8,0xf02942ca
f010556d:	08 00 
f010556f:	0f b6 05 cc 42 29 f0 	movzbl 0xf02942cc,%eax
f0105576:	83 e0 e0             	and    $0xffffffe0,%eax
f0105579:	a2 cc 42 29 f0       	mov    %al,0xf02942cc
f010557e:	0f b6 05 cc 42 29 f0 	movzbl 0xf02942cc,%eax
f0105585:	83 e0 1f             	and    $0x1f,%eax
f0105588:	a2 cc 42 29 f0       	mov    %al,0xf02942cc
f010558d:	0f b6 05 cd 42 29 f0 	movzbl 0xf02942cd,%eax
f0105594:	83 e0 f0             	and    $0xfffffff0,%eax
f0105597:	83 c8 0e             	or     $0xe,%eax
f010559a:	a2 cd 42 29 f0       	mov    %al,0xf02942cd
f010559f:	0f b6 05 cd 42 29 f0 	movzbl 0xf02942cd,%eax
f01055a6:	83 e0 ef             	and    $0xffffffef,%eax
f01055a9:	a2 cd 42 29 f0       	mov    %al,0xf02942cd
f01055ae:	0f b6 05 cd 42 29 f0 	movzbl 0xf02942cd,%eax
f01055b5:	83 e0 9f             	and    $0xffffff9f,%eax
f01055b8:	a2 cd 42 29 f0       	mov    %al,0xf02942cd
f01055bd:	0f b6 05 cd 42 29 f0 	movzbl 0xf02942cd,%eax
f01055c4:	83 c8 80             	or     $0xffffff80,%eax
f01055c7:	a2 cd 42 29 f0       	mov    %al,0xf02942cd
f01055cc:	b8 26 68 10 f0       	mov    $0xf0106826,%eax
f01055d1:	c1 e8 10             	shr    $0x10,%eax
f01055d4:	66 a3 ce 42 29 f0    	mov    %ax,0xf02942ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01055da:	b8 2a 68 10 f0       	mov    $0xf010682a,%eax
f01055df:	66 a3 d0 42 29 f0    	mov    %ax,0xf02942d0
f01055e5:	66 c7 05 d2 42 29 f0 	movw   $0x8,0xf02942d2
f01055ec:	08 00 
f01055ee:	0f b6 05 d4 42 29 f0 	movzbl 0xf02942d4,%eax
f01055f5:	83 e0 e0             	and    $0xffffffe0,%eax
f01055f8:	a2 d4 42 29 f0       	mov    %al,0xf02942d4
f01055fd:	0f b6 05 d4 42 29 f0 	movzbl 0xf02942d4,%eax
f0105604:	83 e0 1f             	and    $0x1f,%eax
f0105607:	a2 d4 42 29 f0       	mov    %al,0xf02942d4
f010560c:	0f b6 05 d5 42 29 f0 	movzbl 0xf02942d5,%eax
f0105613:	83 e0 f0             	and    $0xfffffff0,%eax
f0105616:	83 c8 0e             	or     $0xe,%eax
f0105619:	a2 d5 42 29 f0       	mov    %al,0xf02942d5
f010561e:	0f b6 05 d5 42 29 f0 	movzbl 0xf02942d5,%eax
f0105625:	83 e0 ef             	and    $0xffffffef,%eax
f0105628:	a2 d5 42 29 f0       	mov    %al,0xf02942d5
f010562d:	0f b6 05 d5 42 29 f0 	movzbl 0xf02942d5,%eax
f0105634:	83 e0 9f             	and    $0xffffff9f,%eax
f0105637:	a2 d5 42 29 f0       	mov    %al,0xf02942d5
f010563c:	0f b6 05 d5 42 29 f0 	movzbl 0xf02942d5,%eax
f0105643:	83 c8 80             	or     $0xffffff80,%eax
f0105646:	a2 d5 42 29 f0       	mov    %al,0xf02942d5
f010564b:	b8 2a 68 10 f0       	mov    $0xf010682a,%eax
f0105650:	c1 e8 10             	shr    $0x10,%eax
f0105653:	66 a3 d6 42 29 f0    	mov    %ax,0xf02942d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0105659:	b8 2e 68 10 f0       	mov    $0xf010682e,%eax
f010565e:	66 a3 e0 42 29 f0    	mov    %ax,0xf02942e0
f0105664:	66 c7 05 e2 42 29 f0 	movw   $0x8,0xf02942e2
f010566b:	08 00 
f010566d:	0f b6 05 e4 42 29 f0 	movzbl 0xf02942e4,%eax
f0105674:	83 e0 e0             	and    $0xffffffe0,%eax
f0105677:	a2 e4 42 29 f0       	mov    %al,0xf02942e4
f010567c:	0f b6 05 e4 42 29 f0 	movzbl 0xf02942e4,%eax
f0105683:	83 e0 1f             	and    $0x1f,%eax
f0105686:	a2 e4 42 29 f0       	mov    %al,0xf02942e4
f010568b:	0f b6 05 e5 42 29 f0 	movzbl 0xf02942e5,%eax
f0105692:	83 e0 f0             	and    $0xfffffff0,%eax
f0105695:	83 c8 0e             	or     $0xe,%eax
f0105698:	a2 e5 42 29 f0       	mov    %al,0xf02942e5
f010569d:	0f b6 05 e5 42 29 f0 	movzbl 0xf02942e5,%eax
f01056a4:	83 e0 ef             	and    $0xffffffef,%eax
f01056a7:	a2 e5 42 29 f0       	mov    %al,0xf02942e5
f01056ac:	0f b6 05 e5 42 29 f0 	movzbl 0xf02942e5,%eax
f01056b3:	83 e0 9f             	and    $0xffffff9f,%eax
f01056b6:	a2 e5 42 29 f0       	mov    %al,0xf02942e5
f01056bb:	0f b6 05 e5 42 29 f0 	movzbl 0xf02942e5,%eax
f01056c2:	83 c8 80             	or     $0xffffff80,%eax
f01056c5:	a2 e5 42 29 f0       	mov    %al,0xf02942e5
f01056ca:	b8 2e 68 10 f0       	mov    $0xf010682e,%eax
f01056cf:	c1 e8 10             	shr    $0x10,%eax
f01056d2:	66 a3 e6 42 29 f0    	mov    %ax,0xf02942e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01056d8:	b8 34 68 10 f0       	mov    $0xf0106834,%eax
f01056dd:	66 a3 e8 42 29 f0    	mov    %ax,0xf02942e8
f01056e3:	66 c7 05 ea 42 29 f0 	movw   $0x8,0xf02942ea
f01056ea:	08 00 
f01056ec:	0f b6 05 ec 42 29 f0 	movzbl 0xf02942ec,%eax
f01056f3:	83 e0 e0             	and    $0xffffffe0,%eax
f01056f6:	a2 ec 42 29 f0       	mov    %al,0xf02942ec
f01056fb:	0f b6 05 ec 42 29 f0 	movzbl 0xf02942ec,%eax
f0105702:	83 e0 1f             	and    $0x1f,%eax
f0105705:	a2 ec 42 29 f0       	mov    %al,0xf02942ec
f010570a:	0f b6 05 ed 42 29 f0 	movzbl 0xf02942ed,%eax
f0105711:	83 e0 f0             	and    $0xfffffff0,%eax
f0105714:	83 c8 0e             	or     $0xe,%eax
f0105717:	a2 ed 42 29 f0       	mov    %al,0xf02942ed
f010571c:	0f b6 05 ed 42 29 f0 	movzbl 0xf02942ed,%eax
f0105723:	83 e0 ef             	and    $0xffffffef,%eax
f0105726:	a2 ed 42 29 f0       	mov    %al,0xf02942ed
f010572b:	0f b6 05 ed 42 29 f0 	movzbl 0xf02942ed,%eax
f0105732:	83 e0 9f             	and    $0xffffff9f,%eax
f0105735:	a2 ed 42 29 f0       	mov    %al,0xf02942ed
f010573a:	0f b6 05 ed 42 29 f0 	movzbl 0xf02942ed,%eax
f0105741:	83 c8 80             	or     $0xffffff80,%eax
f0105744:	a2 ed 42 29 f0       	mov    %al,0xf02942ed
f0105749:	b8 34 68 10 f0       	mov    $0xf0106834,%eax
f010574e:	c1 e8 10             	shr    $0x10,%eax
f0105751:	66 a3 ee 42 29 f0    	mov    %ax,0xf02942ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0105757:	b8 38 68 10 f0       	mov    $0xf0106838,%eax
f010575c:	66 a3 f0 42 29 f0    	mov    %ax,0xf02942f0
f0105762:	66 c7 05 f2 42 29 f0 	movw   $0x8,0xf02942f2
f0105769:	08 00 
f010576b:	0f b6 05 f4 42 29 f0 	movzbl 0xf02942f4,%eax
f0105772:	83 e0 e0             	and    $0xffffffe0,%eax
f0105775:	a2 f4 42 29 f0       	mov    %al,0xf02942f4
f010577a:	0f b6 05 f4 42 29 f0 	movzbl 0xf02942f4,%eax
f0105781:	83 e0 1f             	and    $0x1f,%eax
f0105784:	a2 f4 42 29 f0       	mov    %al,0xf02942f4
f0105789:	0f b6 05 f5 42 29 f0 	movzbl 0xf02942f5,%eax
f0105790:	83 e0 f0             	and    $0xfffffff0,%eax
f0105793:	83 c8 0e             	or     $0xe,%eax
f0105796:	a2 f5 42 29 f0       	mov    %al,0xf02942f5
f010579b:	0f b6 05 f5 42 29 f0 	movzbl 0xf02942f5,%eax
f01057a2:	83 e0 ef             	and    $0xffffffef,%eax
f01057a5:	a2 f5 42 29 f0       	mov    %al,0xf02942f5
f01057aa:	0f b6 05 f5 42 29 f0 	movzbl 0xf02942f5,%eax
f01057b1:	83 e0 9f             	and    $0xffffff9f,%eax
f01057b4:	a2 f5 42 29 f0       	mov    %al,0xf02942f5
f01057b9:	0f b6 05 f5 42 29 f0 	movzbl 0xf02942f5,%eax
f01057c0:	83 c8 80             	or     $0xffffff80,%eax
f01057c3:	a2 f5 42 29 f0       	mov    %al,0xf02942f5
f01057c8:	b8 38 68 10 f0       	mov    $0xf0106838,%eax
f01057cd:	c1 e8 10             	shr    $0x10,%eax
f01057d0:	66 a3 f6 42 29 f0    	mov    %ax,0xf02942f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f01057d6:	b8 3e 68 10 f0       	mov    $0xf010683e,%eax
f01057db:	66 a3 f8 42 29 f0    	mov    %ax,0xf02942f8
f01057e1:	66 c7 05 fa 42 29 f0 	movw   $0x8,0xf02942fa
f01057e8:	08 00 
f01057ea:	0f b6 05 fc 42 29 f0 	movzbl 0xf02942fc,%eax
f01057f1:	83 e0 e0             	and    $0xffffffe0,%eax
f01057f4:	a2 fc 42 29 f0       	mov    %al,0xf02942fc
f01057f9:	0f b6 05 fc 42 29 f0 	movzbl 0xf02942fc,%eax
f0105800:	83 e0 1f             	and    $0x1f,%eax
f0105803:	a2 fc 42 29 f0       	mov    %al,0xf02942fc
f0105808:	0f b6 05 fd 42 29 f0 	movzbl 0xf02942fd,%eax
f010580f:	83 e0 f0             	and    $0xfffffff0,%eax
f0105812:	83 c8 0e             	or     $0xe,%eax
f0105815:	a2 fd 42 29 f0       	mov    %al,0xf02942fd
f010581a:	0f b6 05 fd 42 29 f0 	movzbl 0xf02942fd,%eax
f0105821:	83 e0 ef             	and    $0xffffffef,%eax
f0105824:	a2 fd 42 29 f0       	mov    %al,0xf02942fd
f0105829:	0f b6 05 fd 42 29 f0 	movzbl 0xf02942fd,%eax
f0105830:	83 e0 9f             	and    $0xffffff9f,%eax
f0105833:	a2 fd 42 29 f0       	mov    %al,0xf02942fd
f0105838:	0f b6 05 fd 42 29 f0 	movzbl 0xf02942fd,%eax
f010583f:	83 c8 80             	or     $0xffffff80,%eax
f0105842:	a2 fd 42 29 f0       	mov    %al,0xf02942fd
f0105847:	b8 3e 68 10 f0       	mov    $0xf010683e,%eax
f010584c:	c1 e8 10             	shr    $0x10,%eax
f010584f:	66 a3 fe 42 29 f0    	mov    %ax,0xf02942fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0105855:	b8 44 68 10 f0       	mov    $0xf0106844,%eax
f010585a:	66 a3 e0 43 29 f0    	mov    %ax,0xf02943e0
f0105860:	66 c7 05 e2 43 29 f0 	movw   $0x8,0xf02943e2
f0105867:	08 00 
f0105869:	0f b6 05 e4 43 29 f0 	movzbl 0xf02943e4,%eax
f0105870:	83 e0 e0             	and    $0xffffffe0,%eax
f0105873:	a2 e4 43 29 f0       	mov    %al,0xf02943e4
f0105878:	0f b6 05 e4 43 29 f0 	movzbl 0xf02943e4,%eax
f010587f:	83 e0 1f             	and    $0x1f,%eax
f0105882:	a2 e4 43 29 f0       	mov    %al,0xf02943e4
f0105887:	0f b6 05 e5 43 29 f0 	movzbl 0xf02943e5,%eax
f010588e:	83 e0 f0             	and    $0xfffffff0,%eax
f0105891:	83 c8 0e             	or     $0xe,%eax
f0105894:	a2 e5 43 29 f0       	mov    %al,0xf02943e5
f0105899:	0f b6 05 e5 43 29 f0 	movzbl 0xf02943e5,%eax
f01058a0:	83 e0 ef             	and    $0xffffffef,%eax
f01058a3:	a2 e5 43 29 f0       	mov    %al,0xf02943e5
f01058a8:	0f b6 05 e5 43 29 f0 	movzbl 0xf02943e5,%eax
f01058af:	83 c8 60             	or     $0x60,%eax
f01058b2:	a2 e5 43 29 f0       	mov    %al,0xf02943e5
f01058b7:	0f b6 05 e5 43 29 f0 	movzbl 0xf02943e5,%eax
f01058be:	83 c8 80             	or     $0xffffff80,%eax
f01058c1:	a2 e5 43 29 f0       	mov    %al,0xf02943e5
f01058c6:	b8 44 68 10 f0       	mov    $0xf0106844,%eax
f01058cb:	c1 e8 10             	shr    $0x10,%eax
f01058ce:	66 a3 e6 43 29 f0    	mov    %ax,0xf02943e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f01058d4:	b8 4a 68 10 f0       	mov    $0xf010684a,%eax
f01058d9:	66 a3 60 43 29 f0    	mov    %ax,0xf0294360
f01058df:	66 c7 05 62 43 29 f0 	movw   $0x8,0xf0294362
f01058e6:	08 00 
f01058e8:	0f b6 05 64 43 29 f0 	movzbl 0xf0294364,%eax
f01058ef:	83 e0 e0             	and    $0xffffffe0,%eax
f01058f2:	a2 64 43 29 f0       	mov    %al,0xf0294364
f01058f7:	0f b6 05 64 43 29 f0 	movzbl 0xf0294364,%eax
f01058fe:	83 e0 1f             	and    $0x1f,%eax
f0105901:	a2 64 43 29 f0       	mov    %al,0xf0294364
f0105906:	0f b6 05 65 43 29 f0 	movzbl 0xf0294365,%eax
f010590d:	83 e0 f0             	and    $0xfffffff0,%eax
f0105910:	83 c8 0e             	or     $0xe,%eax
f0105913:	a2 65 43 29 f0       	mov    %al,0xf0294365
f0105918:	0f b6 05 65 43 29 f0 	movzbl 0xf0294365,%eax
f010591f:	83 e0 ef             	and    $0xffffffef,%eax
f0105922:	a2 65 43 29 f0       	mov    %al,0xf0294365
f0105927:	0f b6 05 65 43 29 f0 	movzbl 0xf0294365,%eax
f010592e:	83 e0 9f             	and    $0xffffff9f,%eax
f0105931:	a2 65 43 29 f0       	mov    %al,0xf0294365
f0105936:	0f b6 05 65 43 29 f0 	movzbl 0xf0294365,%eax
f010593d:	83 c8 80             	or     $0xffffff80,%eax
f0105940:	a2 65 43 29 f0       	mov    %al,0xf0294365
f0105945:	b8 4a 68 10 f0       	mov    $0xf010684a,%eax
f010594a:	c1 e8 10             	shr    $0x10,%eax
f010594d:	66 a3 66 43 29 f0    	mov    %ax,0xf0294366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f0105953:	b8 50 68 10 f0       	mov    $0xf0106850,%eax
f0105958:	66 a3 68 43 29 f0    	mov    %ax,0xf0294368
f010595e:	66 c7 05 6a 43 29 f0 	movw   $0x8,0xf029436a
f0105965:	08 00 
f0105967:	0f b6 05 6c 43 29 f0 	movzbl 0xf029436c,%eax
f010596e:	83 e0 e0             	and    $0xffffffe0,%eax
f0105971:	a2 6c 43 29 f0       	mov    %al,0xf029436c
f0105976:	0f b6 05 6c 43 29 f0 	movzbl 0xf029436c,%eax
f010597d:	83 e0 1f             	and    $0x1f,%eax
f0105980:	a2 6c 43 29 f0       	mov    %al,0xf029436c
f0105985:	0f b6 05 6d 43 29 f0 	movzbl 0xf029436d,%eax
f010598c:	83 e0 f0             	and    $0xfffffff0,%eax
f010598f:	83 c8 0e             	or     $0xe,%eax
f0105992:	a2 6d 43 29 f0       	mov    %al,0xf029436d
f0105997:	0f b6 05 6d 43 29 f0 	movzbl 0xf029436d,%eax
f010599e:	83 e0 ef             	and    $0xffffffef,%eax
f01059a1:	a2 6d 43 29 f0       	mov    %al,0xf029436d
f01059a6:	0f b6 05 6d 43 29 f0 	movzbl 0xf029436d,%eax
f01059ad:	83 e0 9f             	and    $0xffffff9f,%eax
f01059b0:	a2 6d 43 29 f0       	mov    %al,0xf029436d
f01059b5:	0f b6 05 6d 43 29 f0 	movzbl 0xf029436d,%eax
f01059bc:	83 c8 80             	or     $0xffffff80,%eax
f01059bf:	a2 6d 43 29 f0       	mov    %al,0xf029436d
f01059c4:	b8 50 68 10 f0       	mov    $0xf0106850,%eax
f01059c9:	c1 e8 10             	shr    $0x10,%eax
f01059cc:	66 a3 6e 43 29 f0    	mov    %ax,0xf029436e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f01059d2:	b8 56 68 10 f0       	mov    $0xf0106856,%eax
f01059d7:	66 a3 80 43 29 f0    	mov    %ax,0xf0294380
f01059dd:	66 c7 05 82 43 29 f0 	movw   $0x8,0xf0294382
f01059e4:	08 00 
f01059e6:	0f b6 05 84 43 29 f0 	movzbl 0xf0294384,%eax
f01059ed:	83 e0 e0             	and    $0xffffffe0,%eax
f01059f0:	a2 84 43 29 f0       	mov    %al,0xf0294384
f01059f5:	0f b6 05 84 43 29 f0 	movzbl 0xf0294384,%eax
f01059fc:	83 e0 1f             	and    $0x1f,%eax
f01059ff:	a2 84 43 29 f0       	mov    %al,0xf0294384
f0105a04:	0f b6 05 85 43 29 f0 	movzbl 0xf0294385,%eax
f0105a0b:	83 e0 f0             	and    $0xfffffff0,%eax
f0105a0e:	83 c8 0e             	or     $0xe,%eax
f0105a11:	a2 85 43 29 f0       	mov    %al,0xf0294385
f0105a16:	0f b6 05 85 43 29 f0 	movzbl 0xf0294385,%eax
f0105a1d:	83 e0 ef             	and    $0xffffffef,%eax
f0105a20:	a2 85 43 29 f0       	mov    %al,0xf0294385
f0105a25:	0f b6 05 85 43 29 f0 	movzbl 0xf0294385,%eax
f0105a2c:	83 e0 9f             	and    $0xffffff9f,%eax
f0105a2f:	a2 85 43 29 f0       	mov    %al,0xf0294385
f0105a34:	0f b6 05 85 43 29 f0 	movzbl 0xf0294385,%eax
f0105a3b:	83 c8 80             	or     $0xffffff80,%eax
f0105a3e:	a2 85 43 29 f0       	mov    %al,0xf0294385
f0105a43:	b8 56 68 10 f0       	mov    $0xf0106856,%eax
f0105a48:	c1 e8 10             	shr    $0x10,%eax
f0105a4b:	66 a3 86 43 29 f0    	mov    %ax,0xf0294386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f0105a51:	b8 5c 68 10 f0       	mov    $0xf010685c,%eax
f0105a56:	66 a3 98 43 29 f0    	mov    %ax,0xf0294398
f0105a5c:	66 c7 05 9a 43 29 f0 	movw   $0x8,0xf029439a
f0105a63:	08 00 
f0105a65:	0f b6 05 9c 43 29 f0 	movzbl 0xf029439c,%eax
f0105a6c:	83 e0 e0             	and    $0xffffffe0,%eax
f0105a6f:	a2 9c 43 29 f0       	mov    %al,0xf029439c
f0105a74:	0f b6 05 9c 43 29 f0 	movzbl 0xf029439c,%eax
f0105a7b:	83 e0 1f             	and    $0x1f,%eax
f0105a7e:	a2 9c 43 29 f0       	mov    %al,0xf029439c
f0105a83:	0f b6 05 9d 43 29 f0 	movzbl 0xf029439d,%eax
f0105a8a:	83 e0 f0             	and    $0xfffffff0,%eax
f0105a8d:	83 c8 0e             	or     $0xe,%eax
f0105a90:	a2 9d 43 29 f0       	mov    %al,0xf029439d
f0105a95:	0f b6 05 9d 43 29 f0 	movzbl 0xf029439d,%eax
f0105a9c:	83 e0 ef             	and    $0xffffffef,%eax
f0105a9f:	a2 9d 43 29 f0       	mov    %al,0xf029439d
f0105aa4:	0f b6 05 9d 43 29 f0 	movzbl 0xf029439d,%eax
f0105aab:	83 e0 9f             	and    $0xffffff9f,%eax
f0105aae:	a2 9d 43 29 f0       	mov    %al,0xf029439d
f0105ab3:	0f b6 05 9d 43 29 f0 	movzbl 0xf029439d,%eax
f0105aba:	83 c8 80             	or     $0xffffff80,%eax
f0105abd:	a2 9d 43 29 f0       	mov    %al,0xf029439d
f0105ac2:	b8 5c 68 10 f0       	mov    $0xf010685c,%eax
f0105ac7:	c1 e8 10             	shr    $0x10,%eax
f0105aca:	66 a3 9e 43 29 f0    	mov    %ax,0xf029439e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0105ad0:	b8 62 68 10 f0       	mov    $0xf0106862,%eax
f0105ad5:	66 a3 d0 43 29 f0    	mov    %ax,0xf02943d0
f0105adb:	66 c7 05 d2 43 29 f0 	movw   $0x8,0xf02943d2
f0105ae2:	08 00 
f0105ae4:	0f b6 05 d4 43 29 f0 	movzbl 0xf02943d4,%eax
f0105aeb:	83 e0 e0             	and    $0xffffffe0,%eax
f0105aee:	a2 d4 43 29 f0       	mov    %al,0xf02943d4
f0105af3:	0f b6 05 d4 43 29 f0 	movzbl 0xf02943d4,%eax
f0105afa:	83 e0 1f             	and    $0x1f,%eax
f0105afd:	a2 d4 43 29 f0       	mov    %al,0xf02943d4
f0105b02:	0f b6 05 d5 43 29 f0 	movzbl 0xf02943d5,%eax
f0105b09:	83 e0 f0             	and    $0xfffffff0,%eax
f0105b0c:	83 c8 0e             	or     $0xe,%eax
f0105b0f:	a2 d5 43 29 f0       	mov    %al,0xf02943d5
f0105b14:	0f b6 05 d5 43 29 f0 	movzbl 0xf02943d5,%eax
f0105b1b:	83 e0 ef             	and    $0xffffffef,%eax
f0105b1e:	a2 d5 43 29 f0       	mov    %al,0xf02943d5
f0105b23:	0f b6 05 d5 43 29 f0 	movzbl 0xf02943d5,%eax
f0105b2a:	83 e0 9f             	and    $0xffffff9f,%eax
f0105b2d:	a2 d5 43 29 f0       	mov    %al,0xf02943d5
f0105b32:	0f b6 05 d5 43 29 f0 	movzbl 0xf02943d5,%eax
f0105b39:	83 c8 80             	or     $0xffffff80,%eax
f0105b3c:	a2 d5 43 29 f0       	mov    %al,0xf02943d5
f0105b41:	b8 62 68 10 f0       	mov    $0xf0106862,%eax
f0105b46:	c1 e8 10             	shr    $0x10,%eax
f0105b49:	66 a3 d6 43 29 f0    	mov    %ax,0xf02943d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0105b4f:	b8 68 68 10 f0       	mov    $0xf0106868,%eax
f0105b54:	66 a3 f8 43 29 f0    	mov    %ax,0xf02943f8
f0105b5a:	66 c7 05 fa 43 29 f0 	movw   $0x8,0xf02943fa
f0105b61:	08 00 
f0105b63:	0f b6 05 fc 43 29 f0 	movzbl 0xf02943fc,%eax
f0105b6a:	83 e0 e0             	and    $0xffffffe0,%eax
f0105b6d:	a2 fc 43 29 f0       	mov    %al,0xf02943fc
f0105b72:	0f b6 05 fc 43 29 f0 	movzbl 0xf02943fc,%eax
f0105b79:	83 e0 1f             	and    $0x1f,%eax
f0105b7c:	a2 fc 43 29 f0       	mov    %al,0xf02943fc
f0105b81:	0f b6 05 fd 43 29 f0 	movzbl 0xf02943fd,%eax
f0105b88:	83 e0 f0             	and    $0xfffffff0,%eax
f0105b8b:	83 c8 0e             	or     $0xe,%eax
f0105b8e:	a2 fd 43 29 f0       	mov    %al,0xf02943fd
f0105b93:	0f b6 05 fd 43 29 f0 	movzbl 0xf02943fd,%eax
f0105b9a:	83 e0 ef             	and    $0xffffffef,%eax
f0105b9d:	a2 fd 43 29 f0       	mov    %al,0xf02943fd
f0105ba2:	0f b6 05 fd 43 29 f0 	movzbl 0xf02943fd,%eax
f0105ba9:	83 e0 9f             	and    $0xffffff9f,%eax
f0105bac:	a2 fd 43 29 f0       	mov    %al,0xf02943fd
f0105bb1:	0f b6 05 fd 43 29 f0 	movzbl 0xf02943fd,%eax
f0105bb8:	83 c8 80             	or     $0xffffff80,%eax
f0105bbb:	a2 fd 43 29 f0       	mov    %al,0xf02943fd
f0105bc0:	b8 68 68 10 f0       	mov    $0xf0106868,%eax
f0105bc5:	c1 e8 10             	shr    $0x10,%eax
f0105bc8:	66 a3 fe 43 29 f0    	mov    %ax,0xf02943fe
	// Per-CPU setup 
	trap_init_percpu();
f0105bce:	e8 02 00 00 00       	call   f0105bd5 <trap_init_percpu>
}
f0105bd3:	c9                   	leave  
f0105bd4:	c3                   	ret    

f0105bd5 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0105bd5:	55                   	push   %ebp
f0105bd6:	89 e5                	mov    %esp,%ebp
f0105bd8:	57                   	push   %edi
f0105bd9:	56                   	push   %esi
f0105bda:	53                   	push   %ebx
f0105bdb:	83 ec 1c             	sub    $0x1c,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP)*thiscpu->cpu_id;
f0105bde:	e8 eb 38 00 00       	call   f01094ce <cpunum>
f0105be3:	89 c3                	mov    %eax,%ebx
f0105be5:	e8 e4 38 00 00       	call   f01094ce <cpunum>
f0105bea:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bed:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105bf2:	0f b6 00             	movzbl (%eax),%eax
f0105bf5:	0f b6 d0             	movzbl %al,%edx
f0105bf8:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bfd:	29 d0                	sub    %edx,%eax
f0105bff:	c1 e0 10             	shl    $0x10,%eax
f0105c02:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0105c08:	6b c3 74             	imul   $0x74,%ebx,%eax
f0105c0b:	05 30 80 29 f0       	add    $0xf0298030,%eax
f0105c10:	89 10                	mov    %edx,(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0105c12:	e8 b7 38 00 00       	call   f01094ce <cpunum>
f0105c17:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c1a:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105c1f:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0105c25:	e8 a4 38 00 00       	call   f01094ce <cpunum>
f0105c2a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c2d:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105c32:	0f b6 00             	movzbl (%eax),%eax
f0105c35:	0f b6 c0             	movzbl %al,%eax
f0105c38:	8d 58 05             	lea    0x5(%eax),%ebx
f0105c3b:	e8 8e 38 00 00       	call   f01094ce <cpunum>
f0105c40:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c43:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105c48:	83 c0 0c             	add    $0xc,%eax
f0105c4b:	89 c7                	mov    %eax,%edi
f0105c4d:	e8 7c 38 00 00       	call   f01094ce <cpunum>
f0105c52:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c55:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105c5a:	83 c0 0c             	add    $0xc,%eax
f0105c5d:	c1 e8 10             	shr    $0x10,%eax
f0105c60:	89 c6                	mov    %eax,%esi
f0105c62:	e8 67 38 00 00       	call   f01094ce <cpunum>
f0105c67:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c6a:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105c6f:	83 c0 0c             	add    $0xc,%eax
f0105c72:	c1 e8 18             	shr    $0x18,%eax
f0105c75:	66 c7 04 dd 60 75 12 	movw   $0x67,-0xfed8aa0(,%ebx,8)
f0105c7c:	f0 67 00 
f0105c7f:	66 89 3c dd 62 75 12 	mov    %di,-0xfed8a9e(,%ebx,8)
f0105c86:	f0 
f0105c87:	89 f1                	mov    %esi,%ecx
f0105c89:	88 0c dd 64 75 12 f0 	mov    %cl,-0xfed8a9c(,%ebx,8)
f0105c90:	0f b6 14 dd 65 75 12 	movzbl -0xfed8a9b(,%ebx,8),%edx
f0105c97:	f0 
f0105c98:	83 e2 f0             	and    $0xfffffff0,%edx
f0105c9b:	83 ca 09             	or     $0x9,%edx
f0105c9e:	88 14 dd 65 75 12 f0 	mov    %dl,-0xfed8a9b(,%ebx,8)
f0105ca5:	0f b6 14 dd 65 75 12 	movzbl -0xfed8a9b(,%ebx,8),%edx
f0105cac:	f0 
f0105cad:	83 ca 10             	or     $0x10,%edx
f0105cb0:	88 14 dd 65 75 12 f0 	mov    %dl,-0xfed8a9b(,%ebx,8)
f0105cb7:	0f b6 14 dd 65 75 12 	movzbl -0xfed8a9b(,%ebx,8),%edx
f0105cbe:	f0 
f0105cbf:	83 e2 9f             	and    $0xffffff9f,%edx
f0105cc2:	88 14 dd 65 75 12 f0 	mov    %dl,-0xfed8a9b(,%ebx,8)
f0105cc9:	0f b6 14 dd 65 75 12 	movzbl -0xfed8a9b(,%ebx,8),%edx
f0105cd0:	f0 
f0105cd1:	83 ca 80             	or     $0xffffff80,%edx
f0105cd4:	88 14 dd 65 75 12 f0 	mov    %dl,-0xfed8a9b(,%ebx,8)
f0105cdb:	0f b6 14 dd 66 75 12 	movzbl -0xfed8a9a(,%ebx,8),%edx
f0105ce2:	f0 
f0105ce3:	83 e2 f0             	and    $0xfffffff0,%edx
f0105ce6:	88 14 dd 66 75 12 f0 	mov    %dl,-0xfed8a9a(,%ebx,8)
f0105ced:	0f b6 14 dd 66 75 12 	movzbl -0xfed8a9a(,%ebx,8),%edx
f0105cf4:	f0 
f0105cf5:	83 e2 ef             	and    $0xffffffef,%edx
f0105cf8:	88 14 dd 66 75 12 f0 	mov    %dl,-0xfed8a9a(,%ebx,8)
f0105cff:	0f b6 14 dd 66 75 12 	movzbl -0xfed8a9a(,%ebx,8),%edx
f0105d06:	f0 
f0105d07:	83 e2 df             	and    $0xffffffdf,%edx
f0105d0a:	88 14 dd 66 75 12 f0 	mov    %dl,-0xfed8a9a(,%ebx,8)
f0105d11:	0f b6 14 dd 66 75 12 	movzbl -0xfed8a9a(,%ebx,8),%edx
f0105d18:	f0 
f0105d19:	83 ca 40             	or     $0x40,%edx
f0105d1c:	88 14 dd 66 75 12 f0 	mov    %dl,-0xfed8a9a(,%ebx,8)
f0105d23:	0f b6 14 dd 66 75 12 	movzbl -0xfed8a9a(,%ebx,8),%edx
f0105d2a:	f0 
f0105d2b:	83 e2 7f             	and    $0x7f,%edx
f0105d2e:	88 14 dd 66 75 12 f0 	mov    %dl,-0xfed8a9a(,%ebx,8)
f0105d35:	88 04 dd 67 75 12 f0 	mov    %al,-0xfed8a99(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0105d3c:	e8 8d 37 00 00       	call   f01094ce <cpunum>
f0105d41:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d44:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105d49:	0f b6 00             	movzbl (%eax),%eax
f0105d4c:	0f b6 c0             	movzbl %al,%eax
f0105d4f:	83 c0 05             	add    $0x5,%eax
f0105d52:	0f b6 14 c5 65 75 12 	movzbl -0xfed8a9b(,%eax,8),%edx
f0105d59:	f0 
f0105d5a:	83 e2 ef             	and    $0xffffffef,%edx
f0105d5d:	88 14 c5 65 75 12 f0 	mov    %dl,-0xfed8a9b(,%eax,8)

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(((GD_TSS0 >> 3) + thiscpu->cpu_id) << 3);
f0105d64:	e8 65 37 00 00       	call   f01094ce <cpunum>
f0105d69:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d6c:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0105d71:	0f b6 00             	movzbl (%eax),%eax
f0105d74:	0f b6 c0             	movzbl %al,%eax
f0105d77:	83 c0 05             	add    $0x5,%eax
f0105d7a:	c1 e0 03             	shl    $0x3,%eax
f0105d7d:	0f b7 c0             	movzwl %ax,%eax
f0105d80:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0105d84:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
f0105d88:	0f 00 d8             	ltr    %ax
f0105d8b:	c7 45 e0 d0 75 12 f0 	movl   $0xf01275d0,-0x20(%ebp)
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0105d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d95:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0105d98:	83 c4 1c             	add    $0x1c,%esp
f0105d9b:	5b                   	pop    %ebx
f0105d9c:	5e                   	pop    %esi
f0105d9d:	5f                   	pop    %edi
f0105d9e:	5d                   	pop    %ebp
f0105d9f:	c3                   	ret    

f0105da0 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f0105da0:	55                   	push   %ebp
f0105da1:	89 e5                	mov    %esp,%ebp
f0105da3:	83 ec 28             	sub    $0x28,%esp
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105da6:	e8 23 37 00 00       	call   f01094ce <cpunum>
f0105dab:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105daf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105db2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105db6:	c7 04 24 ce ad 10 f0 	movl   $0xf010adce,(%esp)
f0105dbd:	e8 8c f1 ff ff       	call   f0104f4e <cprintf>
	print_regs(&tf->tf_regs);
f0105dc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dc5:	89 04 24             	mov    %eax,(%esp)
f0105dc8:	e8 a5 01 00 00       	call   f0105f72 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0105dcd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dd0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
f0105dd4:	0f b7 c0             	movzwl %ax,%eax
f0105dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ddb:	c7 04 24 ec ad 10 f0 	movl   $0xf010adec,(%esp)
f0105de2:	e8 67 f1 ff ff       	call   f0104f4e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0105de7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dea:	0f b7 40 24          	movzwl 0x24(%eax),%eax
f0105dee:	0f b7 c0             	movzwl %ax,%eax
f0105df1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105df5:	c7 04 24 ff ad 10 f0 	movl   $0xf010adff,(%esp)
f0105dfc:	e8 4d f1 ff ff       	call   f0104f4e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0105e01:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e04:	8b 40 28             	mov    0x28(%eax),%eax
f0105e07:	89 04 24             	mov    %eax,(%esp)
f0105e0a:	e8 93 f1 ff ff       	call   f0104fa2 <trapname>
f0105e0f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e12:	8b 52 28             	mov    0x28(%edx),%edx
f0105e15:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e1d:	c7 04 24 12 ae 10 f0 	movl   $0xf010ae12,(%esp)
f0105e24:	e8 25 f1 ff ff       	call   f0104f4e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0105e29:	a1 c8 4a 29 f0       	mov    0xf0294ac8,%eax
f0105e2e:	39 45 08             	cmp    %eax,0x8(%ebp)
f0105e31:	75 24                	jne    f0105e57 <print_trapframe+0xb7>
f0105e33:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e36:	8b 40 28             	mov    0x28(%eax),%eax
f0105e39:	83 f8 0e             	cmp    $0xe,%eax
f0105e3c:	75 19                	jne    f0105e57 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105e3e:	0f 20 d0             	mov    %cr2,%eax
f0105e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f0105e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0105e47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e4b:	c7 04 24 24 ae 10 f0 	movl   $0xf010ae24,(%esp)
f0105e52:	e8 f7 f0 ff ff       	call   f0104f4e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0105e57:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e5a:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e61:	c7 04 24 33 ae 10 f0 	movl   $0xf010ae33,(%esp)
f0105e68:	e8 e1 f0 ff ff       	call   f0104f4e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0105e6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e70:	8b 40 28             	mov    0x28(%eax),%eax
f0105e73:	83 f8 0e             	cmp    $0xe,%eax
f0105e76:	75 65                	jne    f0105edd <print_trapframe+0x13d>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0105e78:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e7b:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105e7e:	83 e0 01             	and    $0x1,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105e81:	85 c0                	test   %eax,%eax
f0105e83:	74 07                	je     f0105e8c <print_trapframe+0xec>
f0105e85:	b9 41 ae 10 f0       	mov    $0xf010ae41,%ecx
f0105e8a:	eb 05                	jmp    f0105e91 <print_trapframe+0xf1>
f0105e8c:	b9 4c ae 10 f0       	mov    $0xf010ae4c,%ecx
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
f0105e91:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e94:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105e97:	83 e0 02             	and    $0x2,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105e9a:	85 c0                	test   %eax,%eax
f0105e9c:	74 07                	je     f0105ea5 <print_trapframe+0x105>
f0105e9e:	ba 58 ae 10 f0       	mov    $0xf010ae58,%edx
f0105ea3:	eb 05                	jmp    f0105eaa <print_trapframe+0x10a>
f0105ea5:	ba 5e ae 10 f0       	mov    $0xf010ae5e,%edx
			tf->tf_err & 4 ? "user" : "kernel",
f0105eaa:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ead:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105eb0:	83 e0 04             	and    $0x4,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105eb3:	85 c0                	test   %eax,%eax
f0105eb5:	74 07                	je     f0105ebe <print_trapframe+0x11e>
f0105eb7:	b8 63 ae 10 f0       	mov    $0xf010ae63,%eax
f0105ebc:	eb 05                	jmp    f0105ec3 <print_trapframe+0x123>
f0105ebe:	b8 68 ae 10 f0       	mov    $0xf010ae68,%eax
f0105ec3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ec7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ecf:	c7 04 24 6f ae 10 f0 	movl   $0xf010ae6f,(%esp)
f0105ed6:	e8 73 f0 ff ff       	call   f0104f4e <cprintf>
f0105edb:	eb 0c                	jmp    f0105ee9 <print_trapframe+0x149>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0105edd:	c7 04 24 7e ae 10 f0 	movl   $0xf010ae7e,(%esp)
f0105ee4:	e8 65 f0 ff ff       	call   f0104f4e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0105ee9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eec:	8b 40 30             	mov    0x30(%eax),%eax
f0105eef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ef3:	c7 04 24 80 ae 10 f0 	movl   $0xf010ae80,(%esp)
f0105efa:	e8 4f f0 ff ff       	call   f0104f4e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0105eff:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f02:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105f06:	0f b7 c0             	movzwl %ax,%eax
f0105f09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f0d:	c7 04 24 8f ae 10 f0 	movl   $0xf010ae8f,(%esp)
f0105f14:	e8 35 f0 ff ff       	call   f0104f4e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0105f19:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f1c:	8b 40 38             	mov    0x38(%eax),%eax
f0105f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f23:	c7 04 24 a2 ae 10 f0 	movl   $0xf010aea2,(%esp)
f0105f2a:	e8 1f f0 ff ff       	call   f0104f4e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0105f2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f32:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105f36:	0f b7 c0             	movzwl %ax,%eax
f0105f39:	83 e0 03             	and    $0x3,%eax
f0105f3c:	85 c0                	test   %eax,%eax
f0105f3e:	74 30                	je     f0105f70 <print_trapframe+0x1d0>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0105f40:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f43:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105f46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f4a:	c7 04 24 b1 ae 10 f0 	movl   $0xf010aeb1,(%esp)
f0105f51:	e8 f8 ef ff ff       	call   f0104f4e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0105f56:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f59:	0f b7 40 40          	movzwl 0x40(%eax),%eax
f0105f5d:	0f b7 c0             	movzwl %ax,%eax
f0105f60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f64:	c7 04 24 c0 ae 10 f0 	movl   $0xf010aec0,(%esp)
f0105f6b:	e8 de ef ff ff       	call   f0104f4e <cprintf>
	}
}
f0105f70:	c9                   	leave  
f0105f71:	c3                   	ret    

f0105f72 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f0105f72:	55                   	push   %ebp
f0105f73:	89 e5                	mov    %esp,%ebp
f0105f75:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105f78:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f7b:	8b 00                	mov    (%eax),%eax
f0105f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f81:	c7 04 24 d3 ae 10 f0 	movl   $0xf010aed3,(%esp)
f0105f88:	e8 c1 ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0105f8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f90:	8b 40 04             	mov    0x4(%eax),%eax
f0105f93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f97:	c7 04 24 e2 ae 10 f0 	movl   $0xf010aee2,(%esp)
f0105f9e:	e8 ab ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0105fa3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa6:	8b 40 08             	mov    0x8(%eax),%eax
f0105fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fad:	c7 04 24 f1 ae 10 f0 	movl   $0xf010aef1,(%esp)
f0105fb4:	e8 95 ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0105fb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fbc:	8b 40 0c             	mov    0xc(%eax),%eax
f0105fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc3:	c7 04 24 00 af 10 f0 	movl   $0xf010af00,(%esp)
f0105fca:	e8 7f ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0105fcf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fd2:	8b 40 10             	mov    0x10(%eax),%eax
f0105fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fd9:	c7 04 24 0f af 10 f0 	movl   $0xf010af0f,(%esp)
f0105fe0:	e8 69 ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0105fe5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fe8:	8b 40 14             	mov    0x14(%eax),%eax
f0105feb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fef:	c7 04 24 1e af 10 f0 	movl   $0xf010af1e,(%esp)
f0105ff6:	e8 53 ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105ffb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ffe:	8b 40 18             	mov    0x18(%eax),%eax
f0106001:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106005:	c7 04 24 2d af 10 f0 	movl   $0xf010af2d,(%esp)
f010600c:	e8 3d ef ff ff       	call   f0104f4e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0106011:	8b 45 08             	mov    0x8(%ebp),%eax
f0106014:	8b 40 1c             	mov    0x1c(%eax),%eax
f0106017:	89 44 24 04          	mov    %eax,0x4(%esp)
f010601b:	c7 04 24 3c af 10 f0 	movl   $0xf010af3c,(%esp)
f0106022:	e8 27 ef ff ff       	call   f0104f4e <cprintf>
}
f0106027:	c9                   	leave  
f0106028:	c3                   	ret    

f0106029 <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f0106029:	55                   	push   %ebp
f010602a:	89 e5                	mov    %esp,%ebp
f010602c:	57                   	push   %edi
f010602d:	56                   	push   %esi
f010602e:	53                   	push   %ebx
f010602f:	83 ec 4c             	sub    $0x4c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0106032:	8b 45 08             	mov    0x8(%ebp),%eax
f0106035:	8b 40 28             	mov    0x28(%eax),%eax
f0106038:	83 f8 27             	cmp    $0x27,%eax
f010603b:	75 1c                	jne    f0106059 <trap_dispatch+0x30>
		cprintf("Spurious interrupt on irq 7\n");
f010603d:	c7 04 24 4b af 10 f0 	movl   $0xf010af4b,(%esp)
f0106044:	e8 05 ef ff ff       	call   f0104f4e <cprintf>
		print_trapframe(tf);
f0106049:	8b 45 08             	mov    0x8(%ebp),%eax
f010604c:	89 04 24             	mov    %eax,(%esp)
f010604f:	e8 4c fd ff ff       	call   f0105da0 <print_trapframe>
		return;
f0106054:	e9 e1 03 00 00       	jmp    f010643a <trap_dispatch+0x411>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	struct PushRegs *regs = &(tf->tf_regs);
f0106059:	8b 45 08             	mov    0x8(%ebp),%eax
f010605c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t ret_sys;
	uint32_t opcode = *(uint32_t*)tf->tf_eip;
f010605f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106062:	8b 40 30             	mov    0x30(%eax),%eax
f0106065:	8b 00                	mov    (%eax),%eax
f0106067:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t opcode1 = opcode & 0xff;
f010606a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010606d:	0f b6 c0             	movzbl %al,%eax
f0106070:	89 45 dc             	mov    %eax,-0x24(%ebp)
	uint32_t opcode2 = opcode & 0xffff;
f0106073:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106076:	0f b7 c0             	movzwl %ax,%eax
f0106079:	89 45 d8             	mov    %eax,-0x28(%ebp)
	uint32_t opcode3 = opcode & 0xffffff;
f010607c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010607f:	25 ff ff ff 00       	and    $0xffffff,%eax
f0106084:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if(curenv->env_type == ENV_TYPE_GUEST){
f0106087:	e8 42 34 00 00       	call   f01094ce <cpunum>
f010608c:	6b c0 74             	imul   $0x74,%eax,%eax
f010608f:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106094:	8b 00                	mov    (%eax),%eax
f0106096:	8b 40 50             	mov    0x50(%eax),%eax
f0106099:	83 f8 01             	cmp    $0x1,%eax
f010609c:	0f 85 9f 02 00 00    	jne    f0106341 <trap_dispatch+0x318>
		switch(tf->tf_trapno){
f01060a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01060a5:	8b 40 28             	mov    0x28(%eax),%eax
f01060a8:	83 f8 0d             	cmp    $0xd,%eax
f01060ab:	74 4e                	je     f01060fb <trap_dispatch+0xd2>
f01060ad:	83 f8 0e             	cmp    $0xe,%eax
f01060b0:	0f 85 f5 01 00 00    	jne    f01062ab <trap_dispatch+0x282>
			case T_PGFLT:
				cprintf("***********pgfault opcode: %08x\n", opcode);
f01060b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060bd:	c7 04 24 68 af 10 f0 	movl   $0xf010af68,(%esp)
f01060c4:	e8 85 ee ff ff       	call   f0104f4e <cprintf>
				cprintf("***********pgfault eip: %08x\n", curenv->env_tf.tf_eip);
f01060c9:	e8 00 34 00 00       	call   f01094ce <cpunum>
f01060ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d1:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01060d6:	8b 00                	mov    (%eax),%eax
f01060d8:	8b 40 30             	mov    0x30(%eax),%eax
f01060db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060df:	c7 04 24 89 af 10 f0 	movl   $0xf010af89,(%esp)
f01060e6:	e8 63 ee ff ff       	call   f0104f4e <cprintf>
				// struct PageInfo *p;
				// cprintf("entry\n");
				// p = page_alloc(ALLOC_ZERO);
				// int r = page_insert(curenv->env_pgdir, p, (void *)(rcr2()), PTE_W | PTE_P | PTE_U);
				// cprintf("exit: %d\n", 1);
				page_fault_handler(tf);
f01060eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ee:	89 04 24             	mov    %eax,(%esp)
f01060f1:	e8 e3 04 00 00       	call   f01065d9 <page_fault_handler>
				break;
f01060f6:	e9 41 02 00 00       	jmp    f010633c <trap_dispatch+0x313>
				// break;
			
			case T_GPFLT:
				// cprintf("===========opcode: %08x\n", opcode);
				// cprintf("===========eip: %08x\n", curenv->env_tf.tf_eip);
				switch(opcode3){
f01060fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01060fe:	3d 0f 01 16 00       	cmp    $0x16010f,%eax
f0106103:	74 09                	je     f010610e <trap_dispatch+0xe5>
f0106105:	3d 0f 22 c0 00       	cmp    $0xc0220f,%eax
f010610a:	74 1f                	je     f010612b <trap_dispatch+0x102>
f010610c:	eb 3a                	jmp    f0106148 <trap_dispatch+0x11f>
					case 0x16010f:
						curenv->env_tf.tf_eip += 3;
f010610e:	e8 bb 33 00 00       	call   f01094ce <cpunum>
f0106113:	6b c0 74             	imul   $0x74,%eax,%eax
f0106116:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010611b:	8b 00                	mov    (%eax),%eax
f010611d:	8b 50 30             	mov    0x30(%eax),%edx
f0106120:	83 c2 03             	add    $0x3,%edx
f0106123:	89 50 30             	mov    %edx,0x30(%eax)
						break;
f0106126:	e9 7b 01 00 00       	jmp    f01062a6 <trap_dispatch+0x27d>
					case 0xc0220f:
						curenv->env_tf.tf_eip += 3;
f010612b:	e8 9e 33 00 00       	call   f01094ce <cpunum>
f0106130:	6b c0 74             	imul   $0x74,%eax,%eax
f0106133:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106138:	8b 00                	mov    (%eax),%eax
f010613a:	8b 50 30             	mov    0x30(%eax),%edx
f010613d:	83 c2 03             	add    $0x3,%edx
f0106140:	89 50 30             	mov    %edx,0x30(%eax)
						break;
f0106143:	e9 5e 01 00 00       	jmp    f01062a6 <trap_dispatch+0x27d>
					// case 0x7c32ea:
					// 	curenv->env_tf.tf_eip += 5;
					// 	break;
					default:
						switch(opcode2){
f0106148:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010614b:	3d 8e d8 00 00       	cmp    $0xd88e,%eax
f0106150:	74 4a                	je     f010619c <trap_dispatch+0x173>
f0106152:	3d 8e d8 00 00       	cmp    $0xd88e,%eax
f0106157:	77 13                	ja     f010616c <trap_dispatch+0x143>
f0106159:	3d 8e c0 00 00       	cmp    $0xc08e,%eax
f010615e:	74 59                	je     f01061b9 <trap_dispatch+0x190>
f0106160:	3d 8e d0 00 00       	cmp    $0xd08e,%eax
f0106165:	74 18                	je     f010617f <trap_dispatch+0x156>
f0106167:	e9 a4 00 00 00       	jmp    f0106210 <trap_dispatch+0x1e7>
f010616c:	3d 8e e0 00 00       	cmp    $0xe08e,%eax
f0106171:	74 63                	je     f01061d6 <trap_dispatch+0x1ad>
f0106173:	3d 8e e8 00 00       	cmp    $0xe88e,%eax
f0106178:	74 79                	je     f01061f3 <trap_dispatch+0x1ca>
f010617a:	e9 91 00 00 00       	jmp    f0106210 <trap_dispatch+0x1e7>
							case 0xd08e:
								curenv->env_tf.tf_eip += 2;
f010617f:	e8 4a 33 00 00       	call   f01094ce <cpunum>
f0106184:	6b c0 74             	imul   $0x74,%eax,%eax
f0106187:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010618c:	8b 00                	mov    (%eax),%eax
f010618e:	8b 50 30             	mov    0x30(%eax),%edx
f0106191:	83 c2 02             	add    $0x2,%edx
f0106194:	89 50 30             	mov    %edx,0x30(%eax)
								break;
f0106197:	e9 09 01 00 00       	jmp    f01062a5 <trap_dispatch+0x27c>
							case 0xd88e:
								curenv->env_tf.tf_eip += 2;
f010619c:	e8 2d 33 00 00       	call   f01094ce <cpunum>
f01061a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01061a4:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01061a9:	8b 00                	mov    (%eax),%eax
f01061ab:	8b 50 30             	mov    0x30(%eax),%edx
f01061ae:	83 c2 02             	add    $0x2,%edx
f01061b1:	89 50 30             	mov    %edx,0x30(%eax)
								break;
f01061b4:	e9 ec 00 00 00       	jmp    f01062a5 <trap_dispatch+0x27c>
							case 0xc08e:
								curenv->env_tf.tf_eip += 2;
f01061b9:	e8 10 33 00 00       	call   f01094ce <cpunum>
f01061be:	6b c0 74             	imul   $0x74,%eax,%eax
f01061c1:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01061c6:	8b 00                	mov    (%eax),%eax
f01061c8:	8b 50 30             	mov    0x30(%eax),%edx
f01061cb:	83 c2 02             	add    $0x2,%edx
f01061ce:	89 50 30             	mov    %edx,0x30(%eax)
								break;
f01061d1:	e9 cf 00 00 00       	jmp    f01062a5 <trap_dispatch+0x27c>
							case 0xe08e:
								curenv->env_tf.tf_eip += 2;
f01061d6:	e8 f3 32 00 00       	call   f01094ce <cpunum>
f01061db:	6b c0 74             	imul   $0x74,%eax,%eax
f01061de:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01061e3:	8b 00                	mov    (%eax),%eax
f01061e5:	8b 50 30             	mov    0x30(%eax),%edx
f01061e8:	83 c2 02             	add    $0x2,%edx
f01061eb:	89 50 30             	mov    %edx,0x30(%eax)
								break;
f01061ee:	e9 b2 00 00 00       	jmp    f01062a5 <trap_dispatch+0x27c>
							case 0xe88e:
								curenv->env_tf.tf_eip += 2;
f01061f3:	e8 d6 32 00 00       	call   f01094ce <cpunum>
f01061f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01061fb:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106200:	8b 00                	mov    (%eax),%eax
f0106202:	8b 50 30             	mov    0x30(%eax),%edx
f0106205:	83 c2 02             	add    $0x2,%edx
f0106208:	89 50 30             	mov    %edx,0x30(%eax)
								break;
f010620b:	e9 95 00 00 00       	jmp    f01062a5 <trap_dispatch+0x27c>
							default:
								switch(opcode1){
f0106210:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106213:	3d ea 00 00 00       	cmp    $0xea,%eax
f0106218:	74 21                	je     f010623b <trap_dispatch+0x212>
f010621a:	3d fa 00 00 00       	cmp    $0xfa,%eax
f010621f:	75 34                	jne    f0106255 <trap_dispatch+0x22c>
									case 0xfa:
										curenv->env_tf.tf_eip += 1;
f0106221:	e8 a8 32 00 00       	call   f01094ce <cpunum>
f0106226:	6b c0 74             	imul   $0x74,%eax,%eax
f0106229:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010622e:	8b 00                	mov    (%eax),%eax
f0106230:	8b 50 30             	mov    0x30(%eax),%edx
f0106233:	83 c2 01             	add    $0x1,%edx
f0106236:	89 50 30             	mov    %edx,0x30(%eax)
										break;
f0106239:	eb 69                	jmp    f01062a4 <trap_dispatch+0x27b>
									case 0xea:
										// cprintf("===========opcode: %x\n", opcode);
										// cprintf("===========eip: %x\n", curenv->env_tf.tf_eip);
										// cprintf("=============================");
										curenv->env_tf.tf_eip += 1;
f010623b:	e8 8e 32 00 00       	call   f01094ce <cpunum>
f0106240:	6b c0 74             	imul   $0x74,%eax,%eax
f0106243:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106248:	8b 00                	mov    (%eax),%eax
f010624a:	8b 50 30             	mov    0x30(%eax),%edx
f010624d:	83 c2 01             	add    $0x1,%edx
f0106250:	89 50 30             	mov    %edx,0x30(%eax)
										break;
f0106253:	eb 4f                	jmp    f01062a4 <trap_dispatch+0x27b>
									default:
										cprintf("===========opcode: %x\n", opcode);
f0106255:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106258:	89 44 24 04          	mov    %eax,0x4(%esp)
f010625c:	c7 04 24 a7 af 10 f0 	movl   $0xf010afa7,(%esp)
f0106263:	e8 e6 ec ff ff       	call   f0104f4e <cprintf>
										cprintf("===========eip: %x\n", curenv->env_tf.tf_eip);
f0106268:	e8 61 32 00 00       	call   f01094ce <cpunum>
f010626d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106270:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106275:	8b 00                	mov    (%eax),%eax
f0106277:	8b 40 30             	mov    0x30(%eax),%eax
f010627a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010627e:	c7 04 24 be af 10 f0 	movl   $0xf010afbe,(%esp)
f0106285:	e8 c4 ec ff ff       	call   f0104f4e <cprintf>
										curenv->env_tf.tf_eip += 1;
f010628a:	e8 3f 32 00 00       	call   f01094ce <cpunum>
f010628f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106292:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106297:	8b 00                	mov    (%eax),%eax
f0106299:	8b 50 30             	mov    0x30(%eax),%edx
f010629c:	83 c2 01             	add    $0x1,%edx
f010629f:	89 50 30             	mov    %edx,0x30(%eax)
								}
								break;
f01062a2:	eb 00                	jmp    f01062a4 <trap_dispatch+0x27b>
f01062a4:	90                   	nop
						}
						break;
f01062a5:	90                   	nop
				}
				break;
f01062a6:	e9 91 00 00 00       	jmp    f010633c <trap_dispatch+0x313>
			default:
				cprintf("===========opcode: %x\n", opcode);
f01062ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01062ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062b2:	c7 04 24 a7 af 10 f0 	movl   $0xf010afa7,(%esp)
f01062b9:	e8 90 ec ff ff       	call   f0104f4e <cprintf>
				cprintf("===========eip: %x\n", curenv->env_tf.tf_eip);
f01062be:	e8 0b 32 00 00       	call   f01094ce <cpunum>
f01062c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01062c6:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01062cb:	8b 00                	mov    (%eax),%eax
f01062cd:	8b 40 30             	mov    0x30(%eax),%eax
f01062d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062d4:	c7 04 24 be af 10 f0 	movl   $0xf010afbe,(%esp)
f01062db:	e8 6e ec ff ff       	call   f0104f4e <cprintf>
				cprintf("ggggggggggggggggggggggggggggg\n");
f01062e0:	c7 04 24 d4 af 10 f0 	movl   $0xf010afd4,(%esp)
f01062e7:	e8 62 ec ff ff       	call   f0104f4e <cprintf>
				print_trapframe(tf);
f01062ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01062ef:	89 04 24             	mov    %eax,(%esp)
f01062f2:	e8 a9 fa ff ff       	call   f0105da0 <print_trapframe>
				if (tf->tf_cs == GD_KT)
f01062f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01062fa:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f01062fe:	66 83 f8 08          	cmp    $0x8,%ax
f0106302:	75 1c                	jne    f0106320 <trap_dispatch+0x2f7>
					panic("unhandled trap in kernel");
f0106304:	c7 44 24 08 f3 af 10 	movl   $0xf010aff3,0x8(%esp)
f010630b:	f0 
f010630c:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
f0106313:	00 
f0106314:	c7 04 24 0c b0 10 f0 	movl   $0xf010b00c,(%esp)
f010631b:	e8 af 9f ff ff       	call   f01002cf <_panic>
				else {
					env_destroy(curenv);
f0106320:	e8 a9 31 00 00       	call   f01094ce <cpunum>
f0106325:	6b c0 74             	imul   $0x74,%eax,%eax
f0106328:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010632d:	8b 00                	mov    (%eax),%eax
f010632f:	89 04 24             	mov    %eax,(%esp)
f0106332:	e8 b0 e7 ff ff       	call   f0104ae7 <env_destroy>
					return;
f0106337:	e9 fe 00 00 00       	jmp    f010643a <trap_dispatch+0x411>
f010633c:	e9 f9 00 00 00       	jmp    f010643a <trap_dispatch+0x411>
				}
		}	
	}
	else{
		switch(tf->tf_trapno){
f0106341:	8b 45 08             	mov    0x8(%ebp),%eax
f0106344:	8b 40 28             	mov    0x28(%eax),%eax
f0106347:	83 f8 30             	cmp    $0x30,%eax
f010634a:	0f 87 9e 00 00 00    	ja     f01063ee <trap_dispatch+0x3c5>
f0106350:	8b 04 85 18 b0 10 f0 	mov    -0xfef4fe8(,%eax,4),%eax
f0106357:	ff e0                	jmp    *%eax
			case T_PGFLT:
				// if(curenv->env_type != ENV_TYPE_GUEST)
					page_fault_handler(tf);
f0106359:	8b 45 08             	mov    0x8(%ebp),%eax
f010635c:	89 04 24             	mov    %eax,(%esp)
f010635f:	e8 75 02 00 00       	call   f01065d9 <page_fault_handler>
				break;
f0106364:	e9 d1 00 00 00       	jmp    f010643a <trap_dispatch+0x411>
			case T_BRKPT:
				// if(curenv->env_type != ENV_TYPE_GUEST)
					monitor(tf);
f0106369:	8b 45 08             	mov    0x8(%ebp),%eax
f010636c:	89 04 24             	mov    %eax,(%esp)
f010636f:	e8 d8 ad ff ff       	call   f010114c <monitor>
				break;
f0106374:	e9 c1 00 00 00       	jmp    f010643a <trap_dispatch+0x411>
			case T_DEBUG:
				// if(curenv->env_type != ENV_TYPE_GUEST)
					monitor(tf);
f0106379:	8b 45 08             	mov    0x8(%ebp),%eax
f010637c:	89 04 24             	mov    %eax,(%esp)
f010637f:	e8 c8 ad ff ff       	call   f010114c <monitor>
				break;
f0106384:	e9 b1 00 00 00       	jmp    f010643a <trap_dispatch+0x411>
			case T_SYSCALL:
				// if(curenv->env_type != ENV_TYPE_GUEST){
					ret_sys = syscall(regs->reg_eax, regs->reg_edx, regs->reg_ecx, regs->reg_ebx, regs->reg_edi, regs->reg_esi);
f0106389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010638c:	8b 78 04             	mov    0x4(%eax),%edi
f010638f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106392:	8b 30                	mov    (%eax),%esi
f0106394:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106397:	8b 58 10             	mov    0x10(%eax),%ebx
f010639a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010639d:	8b 48 18             	mov    0x18(%eax),%ecx
f01063a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063a3:	8b 50 14             	mov    0x14(%eax),%edx
f01063a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063a9:	8b 40 1c             	mov    0x1c(%eax),%eax
f01063ac:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01063b0:	89 74 24 10          	mov    %esi,0x10(%esp)
f01063b4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01063b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01063bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01063c0:	89 04 24             	mov    %eax,(%esp)
f01063c3:	e8 b7 15 00 00       	call   f010797f <syscall>
f01063c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
					regs->reg_eax = ret_sys;
f01063cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063ce:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01063d1:	89 50 1c             	mov    %edx,0x1c(%eax)
				// }
				break;
f01063d4:	eb 64                	jmp    f010643a <trap_dispatch+0x411>
			case IRQ_OFFSET+IRQ_TIMER:
				// if(curenv->env_type != ENV_TYPE_GUEST){
					lapic_eoi();
f01063d6:	e8 15 31 00 00       	call   f01094f0 <lapic_eoi>
					sched_yield();
f01063db:	e8 0b 05 00 00       	call   f01068eb <sched_yield>
				// }
				break;
			case IRQ_OFFSET+IRQ_KBD:
				kbd_intr();
f01063e0:	e8 4f a6 ff ff       	call   f0100a34 <kbd_intr>
				break;
f01063e5:	eb 53                	jmp    f010643a <trap_dispatch+0x411>
			case IRQ_OFFSET+IRQ_SERIAL:
				serial_intr();
f01063e7:	e8 25 a0 ff ff       	call   f0100411 <serial_intr>
				break;
f01063ec:	eb 4c                	jmp    f010643a <trap_dispatch+0x411>
			default:
				print_trapframe(tf);
f01063ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01063f1:	89 04 24             	mov    %eax,(%esp)
f01063f4:	e8 a7 f9 ff ff       	call   f0105da0 <print_trapframe>
				if (tf->tf_cs == GD_KT)
f01063f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01063fc:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0106400:	66 83 f8 08          	cmp    $0x8,%ax
f0106404:	75 1c                	jne    f0106422 <trap_dispatch+0x3f9>
					panic("unhandled trap in kernel");
f0106406:	c7 44 24 08 f3 af 10 	movl   $0xf010aff3,0x8(%esp)
f010640d:	f0 
f010640e:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0106415:	00 
f0106416:	c7 04 24 0c b0 10 f0 	movl   $0xf010b00c,(%esp)
f010641d:	e8 ad 9e ff ff       	call   f01002cf <_panic>
				else {
					env_destroy(curenv);
f0106422:	e8 a7 30 00 00       	call   f01094ce <cpunum>
f0106427:	6b c0 74             	imul   $0x74,%eax,%eax
f010642a:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010642f:	8b 00                	mov    (%eax),%eax
f0106431:	89 04 24             	mov    %eax,(%esp)
f0106434:	e8 ae e6 ff ff       	call   f0104ae7 <env_destroy>
					return;
f0106439:	90                   	nop
				}
		}
	}
	// Unexpected trap: The user process or the kernel has a bug.
}
f010643a:	83 c4 4c             	add    $0x4c,%esp
f010643d:	5b                   	pop    %ebx
f010643e:	5e                   	pop    %esi
f010643f:	5f                   	pop    %edi
f0106440:	5d                   	pop    %ebp
f0106441:	c3                   	ret    

f0106442 <trap>:

void
trap(struct Trapframe *tf)
{
f0106442:	55                   	push   %ebp
f0106443:	89 e5                	mov    %esp,%ebp
f0106445:	57                   	push   %edi
f0106446:	56                   	push   %esi
f0106447:	53                   	push   %ebx
f0106448:	83 ec 2c             	sub    $0x2c,%esp
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010644b:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010644c:	a1 e0 7a 29 f0       	mov    0xf0297ae0,%eax
f0106451:	85 c0                	test   %eax,%eax
f0106453:	74 01                	je     f0106456 <trap+0x14>
		asm volatile("hlt");
f0106455:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0106456:	e8 73 30 00 00       	call   f01094ce <cpunum>
f010645b:	6b c0 74             	imul   $0x74,%eax,%eax
f010645e:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0106463:	83 c0 04             	add    $0x4,%eax
f0106466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010646d:	00 
f010646e:	89 04 24             	mov    %eax,(%esp)
f0106471:	e8 fe ea ff ff       	call   f0104f74 <xchg>
f0106476:	83 f8 02             	cmp    $0x2,%eax
f0106479:	75 05                	jne    f0106480 <trap+0x3e>
		lock_kernel();
f010647b:	e8 0e eb ff ff       	call   f0104f8e <lock_kernel>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0106480:	9c                   	pushf  
f0106481:	58                   	pop    %eax
f0106482:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	return eflags;
f0106485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0106488:	25 00 02 00 00       	and    $0x200,%eax
f010648d:	85 c0                	test   %eax,%eax
f010648f:	74 24                	je     f01064b5 <trap+0x73>
f0106491:	c7 44 24 0c dc b0 10 	movl   $0xf010b0dc,0xc(%esp)
f0106498:	f0 
f0106499:	c7 44 24 08 f5 b0 10 	movl   $0xf010b0f5,0x8(%esp)
f01064a0:	f0 
f01064a1:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
f01064a8:	00 
f01064a9:	c7 04 24 0c b0 10 f0 	movl   $0xf010b00c,(%esp)
f01064b0:	e8 1a 9e ff ff       	call   f01002cf <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01064b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01064b8:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f01064bc:	0f b7 c0             	movzwl %ax,%eax
f01064bf:	83 e0 03             	and    $0x3,%eax
f01064c2:	83 f8 03             	cmp    $0x3,%eax
f01064c5:	0f 85 b5 00 00 00    	jne    f0106580 <trap+0x13e>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
f01064cb:	e8 be ea ff ff       	call   f0104f8e <lock_kernel>
		assert(curenv);
f01064d0:	e8 f9 2f 00 00       	call   f01094ce <cpunum>
f01064d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01064d8:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01064dd:	8b 00                	mov    (%eax),%eax
f01064df:	85 c0                	test   %eax,%eax
f01064e1:	75 24                	jne    f0106507 <trap+0xc5>
f01064e3:	c7 44 24 0c 0a b1 10 	movl   $0xf010b10a,0xc(%esp)
f01064ea:	f0 
f01064eb:	c7 44 24 08 f5 b0 10 	movl   $0xf010b0f5,0x8(%esp)
f01064f2:	f0 
f01064f3:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f01064fa:	00 
f01064fb:	c7 04 24 0c b0 10 f0 	movl   $0xf010b00c,(%esp)
f0106502:	e8 c8 9d ff ff       	call   f01002cf <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0106507:	e8 c2 2f 00 00       	call   f01094ce <cpunum>
f010650c:	6b c0 74             	imul   $0x74,%eax,%eax
f010650f:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106514:	8b 00                	mov    (%eax),%eax
f0106516:	8b 40 54             	mov    0x54(%eax),%eax
f0106519:	83 f8 01             	cmp    $0x1,%eax
f010651c:	75 2f                	jne    f010654d <trap+0x10b>
			env_free(curenv);
f010651e:	e8 ab 2f 00 00       	call   f01094ce <cpunum>
f0106523:	6b c0 74             	imul   $0x74,%eax,%eax
f0106526:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010652b:	8b 00                	mov    (%eax),%eax
f010652d:	89 04 24             	mov    %eax,(%esp)
f0106530:	e8 2c e4 ff ff       	call   f0104961 <env_free>
			curenv = NULL;
f0106535:	e8 94 2f 00 00       	call   f01094ce <cpunum>
f010653a:	6b c0 74             	imul   $0x74,%eax,%eax
f010653d:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106542:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			sched_yield();
f0106548:	e8 9e 03 00 00       	call   f01068eb <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010654d:	e8 7c 2f 00 00       	call   f01094ce <cpunum>
f0106552:	6b c0 74             	imul   $0x74,%eax,%eax
f0106555:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010655a:	8b 10                	mov    (%eax),%edx
f010655c:	8b 45 08             	mov    0x8(%ebp),%eax
f010655f:	89 c3                	mov    %eax,%ebx
f0106561:	b8 11 00 00 00       	mov    $0x11,%eax
f0106566:	89 d7                	mov    %edx,%edi
f0106568:	89 de                	mov    %ebx,%esi
f010656a:	89 c1                	mov    %eax,%ecx
f010656c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010656e:	e8 5b 2f 00 00       	call   f01094ce <cpunum>
f0106573:	6b c0 74             	imul   $0x74,%eax,%eax
f0106576:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010657b:	8b 00                	mov    (%eax),%eax
f010657d:	89 45 08             	mov    %eax,0x8(%ebp)
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0106580:	8b 45 08             	mov    0x8(%ebp),%eax
f0106583:	a3 c8 4a 29 f0       	mov    %eax,0xf0294ac8

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f0106588:	8b 45 08             	mov    0x8(%ebp),%eax
f010658b:	89 04 24             	mov    %eax,(%esp)
f010658e:	e8 96 fa ff ff       	call   f0106029 <trap_dispatch>

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0106593:	e8 36 2f 00 00       	call   f01094ce <cpunum>
f0106598:	6b c0 74             	imul   $0x74,%eax,%eax
f010659b:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01065a0:	8b 00                	mov    (%eax),%eax
f01065a2:	85 c0                	test   %eax,%eax
f01065a4:	74 2e                	je     f01065d4 <trap+0x192>
f01065a6:	e8 23 2f 00 00       	call   f01094ce <cpunum>
f01065ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01065ae:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01065b3:	8b 00                	mov    (%eax),%eax
f01065b5:	8b 40 54             	mov    0x54(%eax),%eax
f01065b8:	83 f8 03             	cmp    $0x3,%eax
f01065bb:	75 17                	jne    f01065d4 <trap+0x192>
		env_run(curenv);
f01065bd:	e8 0c 2f 00 00       	call   f01094ce <cpunum>
f01065c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01065c5:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01065ca:	8b 00                	mov    (%eax),%eax
f01065cc:	89 04 24             	mov    %eax,(%esp)
f01065cf:	e8 f3 e5 ff ff       	call   f0104bc7 <env_run>
	else
		sched_yield();
f01065d4:	e8 12 03 00 00       	call   f01068eb <sched_yield>

f01065d9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01065d9:	55                   	push   %ebp
f01065da:	89 e5                	mov    %esp,%ebp
f01065dc:	53                   	push   %ebx
f01065dd:	83 ec 24             	sub    $0x24,%esp

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01065e0:	0f 20 d0             	mov    %cr2,%eax
f01065e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
	return val;
f01065e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f01065e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f01065ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01065ef:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f01065f3:	66 83 f8 08          	cmp    $0x8,%ax
f01065f7:	75 1c                	jne    f0106615 <page_fault_handler+0x3c>
		panic("page fault in kernel");
f01065f9:	c7 44 24 08 11 b1 10 	movl   $0xf010b111,0x8(%esp)
f0106600:	f0 
f0106601:	c7 44 24 04 ca 01 00 	movl   $0x1ca,0x4(%esp)
f0106608:	00 
f0106609:	c7 04 24 0c b0 10 f0 	movl   $0xf010b00c,(%esp)
f0106610:	e8 ba 9c ff ff       	call   f01002cf <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall == NULL || tf->tf_esp > UXSTACKTOP || (tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE))){
f0106615:	e8 b4 2e 00 00       	call   f01094ce <cpunum>
f010661a:	6b c0 74             	imul   $0x74,%eax,%eax
f010661d:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106622:	8b 00                	mov    (%eax),%eax
f0106624:	8b 40 64             	mov    0x64(%eax),%eax
f0106627:	85 c0                	test   %eax,%eax
f0106629:	74 27                	je     f0106652 <page_fault_handler+0x79>
f010662b:	8b 45 08             	mov    0x8(%ebp),%eax
f010662e:	8b 40 3c             	mov    0x3c(%eax),%eax
f0106631:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0106636:	77 1a                	ja     f0106652 <page_fault_handler+0x79>
f0106638:	8b 45 08             	mov    0x8(%ebp),%eax
f010663b:	8b 40 3c             	mov    0x3c(%eax),%eax
f010663e:	3d 00 e0 bf ee       	cmp    $0xeebfe000,%eax
f0106643:	76 67                	jbe    f01066ac <page_fault_handler+0xd3>
f0106645:	8b 45 08             	mov    0x8(%ebp),%eax
f0106648:	8b 40 3c             	mov    0x3c(%eax),%eax
f010664b:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f0106650:	77 5a                	ja     f01066ac <page_fault_handler+0xd3>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0106652:	8b 45 08             	mov    0x8(%ebp),%eax
f0106655:	8b 58 30             	mov    0x30(%eax),%ebx
			curenv->env_id, fault_va, tf->tf_eip);
f0106658:	e8 71 2e 00 00       	call   f01094ce <cpunum>
f010665d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106660:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106665:	8b 00                	mov    (%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall == NULL || tf->tf_esp > UXSTACKTOP || (tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE))){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0106667:	8b 40 48             	mov    0x48(%eax),%eax
f010666a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010666e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106671:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106675:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106679:	c7 04 24 28 b1 10 f0 	movl   $0xf010b128,(%esp)
f0106680:	e8 c9 e8 ff ff       	call   f0104f4e <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0106685:	8b 45 08             	mov    0x8(%ebp),%eax
f0106688:	89 04 24             	mov    %eax,(%esp)
f010668b:	e8 10 f7 ff ff       	call   f0105da0 <print_trapframe>
		env_destroy(curenv);
f0106690:	e8 39 2e 00 00       	call   f01094ce <cpunum>
f0106695:	6b c0 74             	imul   $0x74,%eax,%eax
f0106698:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010669d:	8b 00                	mov    (%eax),%eax
f010669f:	89 04 24             	mov    %eax,(%esp)
f01066a2:	e8 40 e4 ff ff       	call   f0104ae7 <env_destroy>
f01066a7:	e9 3a 01 00 00       	jmp    f01067e6 <page_fault_handler+0x20d>
	}
	else{
		// cprintf("user fault\n");
		uint32_t ex_stack_top;
		if(tf->tf_esp < USTACKTOP) ex_stack_top = UXSTACKTOP - sizeof(struct UTrapframe);		//switch from user stack to user exception stack
f01066ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01066af:	8b 40 3c             	mov    0x3c(%eax),%eax
f01066b2:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f01066b7:	77 09                	ja     f01066c2 <page_fault_handler+0xe9>
f01066b9:	c7 45 f4 cc ff bf ee 	movl   $0xeebfffcc,-0xc(%ebp)
f01066c0:	eb 0c                	jmp    f01066ce <page_fault_handler+0xf5>
		else ex_stack_top = tf->tf_esp - sizeof(struct UTrapframe) - 4;		//recursive pagefault
f01066c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01066c5:	8b 40 3c             	mov    0x3c(%eax),%eax
f01066c8:	83 e8 38             	sub    $0x38,%eax
f01066cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
		user_mem_assert(curenv, (void *)ex_stack_top, sizeof(struct UTrapframe), PTE_U | PTE_P | PTE_W);
f01066ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01066d1:	e8 f8 2d 00 00       	call   f01094ce <cpunum>
f01066d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01066d9:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01066de:	8b 00                	mov    (%eax),%eax
f01066e0:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01066e7:	00 
f01066e8:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01066ef:	00 
f01066f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01066f4:	89 04 24             	mov    %eax,(%esp)
f01066f7:	e8 08 b7 ff ff       	call   f0101e04 <user_mem_assert>
		user_mem_assert(curenv, curenv->env_pgfault_upcall, PGSIZE, PTE_U | PTE_P);
f01066fc:	e8 cd 2d 00 00       	call   f01094ce <cpunum>
f0106701:	6b c0 74             	imul   $0x74,%eax,%eax
f0106704:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106709:	8b 00                	mov    (%eax),%eax
f010670b:	8b 58 64             	mov    0x64(%eax),%ebx
f010670e:	e8 bb 2d 00 00       	call   f01094ce <cpunum>
f0106713:	6b c0 74             	imul   $0x74,%eax,%eax
f0106716:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010671b:	8b 00                	mov    (%eax),%eax
f010671d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0106724:	00 
f0106725:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010672c:	00 
f010672d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106731:	89 04 24             	mov    %eax,(%esp)
f0106734:	e8 cb b6 ff ff       	call   f0101e04 <user_mem_assert>
		struct UTrapframe *utf = (struct UTrapframe *)ex_stack_top;
f0106739:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010673c:	89 45 ec             	mov    %eax,-0x14(%ebp)
		utf->utf_fault_va = fault_va;
f010673f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106742:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106745:	89 10                	mov    %edx,(%eax)
		utf->utf_err = tf->tf_err;
f0106747:	8b 45 08             	mov    0x8(%ebp),%eax
f010674a:	8b 50 2c             	mov    0x2c(%eax),%edx
f010674d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106750:	89 50 04             	mov    %edx,0x4(%eax)
		utf->utf_regs = tf->tf_regs;
f0106753:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106756:	8b 55 08             	mov    0x8(%ebp),%edx
f0106759:	8b 0a                	mov    (%edx),%ecx
f010675b:	89 48 08             	mov    %ecx,0x8(%eax)
f010675e:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106761:	89 48 0c             	mov    %ecx,0xc(%eax)
f0106764:	8b 4a 08             	mov    0x8(%edx),%ecx
f0106767:	89 48 10             	mov    %ecx,0x10(%eax)
f010676a:	8b 4a 0c             	mov    0xc(%edx),%ecx
f010676d:	89 48 14             	mov    %ecx,0x14(%eax)
f0106770:	8b 4a 10             	mov    0x10(%edx),%ecx
f0106773:	89 48 18             	mov    %ecx,0x18(%eax)
f0106776:	8b 4a 14             	mov    0x14(%edx),%ecx
f0106779:	89 48 1c             	mov    %ecx,0x1c(%eax)
f010677c:	8b 4a 18             	mov    0x18(%edx),%ecx
f010677f:	89 48 20             	mov    %ecx,0x20(%eax)
f0106782:	8b 52 1c             	mov    0x1c(%edx),%edx
f0106785:	89 50 24             	mov    %edx,0x24(%eax)
		utf->utf_eip = tf->tf_eip;
f0106788:	8b 45 08             	mov    0x8(%ebp),%eax
f010678b:	8b 50 30             	mov    0x30(%eax),%edx
f010678e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106791:	89 50 28             	mov    %edx,0x28(%eax)
		utf->utf_eflags = tf->tf_eflags;
f0106794:	8b 45 08             	mov    0x8(%ebp),%eax
f0106797:	8b 50 38             	mov    0x38(%eax),%edx
f010679a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010679d:	89 50 2c             	mov    %edx,0x2c(%eax)
		utf->utf_esp = tf->tf_esp;
f01067a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01067a3:	8b 50 3c             	mov    0x3c(%eax),%edx
f01067a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01067a9:	89 50 30             	mov    %edx,0x30(%eax)

		tf->tf_esp = (uintptr_t)ex_stack_top;
f01067ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01067af:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01067b2:	89 50 3c             	mov    %edx,0x3c(%eax)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01067b5:	e8 14 2d 00 00       	call   f01094ce <cpunum>
f01067ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01067bd:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01067c2:	8b 00                	mov    (%eax),%eax
f01067c4:	8b 40 64             	mov    0x64(%eax),%eax
f01067c7:	89 c2                	mov    %eax,%edx
f01067c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01067cc:	89 50 30             	mov    %edx,0x30(%eax)
		env_run(curenv);	
f01067cf:	e8 fa 2c 00 00       	call   f01094ce <cpunum>
f01067d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01067d7:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01067dc:	8b 00                	mov    (%eax),%eax
f01067de:	89 04 24             	mov    %eax,(%esp)
f01067e1:	e8 e1 e3 ff ff       	call   f0104bc7 <env_run>
	}
}
f01067e6:	83 c4 24             	add    $0x24,%esp
f01067e9:	5b                   	pop    %ebx
f01067ea:	5d                   	pop    %ebp
f01067eb:	c3                   	ret    

f01067ec <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.text
TRAPHANDLER_NOEC(t_divide , T_DIVIDE)
f01067ec:	6a 00                	push   $0x0
f01067ee:	6a 00                	push   $0x0
f01067f0:	eb 7c                	jmp    f010686e <_alltraps>

f01067f2 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f01067f2:	6a 00                	push   $0x0
f01067f4:	6a 01                	push   $0x1
f01067f6:	eb 76                	jmp    f010686e <_alltraps>

f01067f8 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f01067f8:	6a 00                	push   $0x0
f01067fa:	6a 02                	push   $0x2
f01067fc:	eb 70                	jmp    f010686e <_alltraps>

f01067fe <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01067fe:	6a 00                	push   $0x0
f0106800:	6a 03                	push   $0x3
f0106802:	eb 6a                	jmp    f010686e <_alltraps>

f0106804 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0106804:	6a 00                	push   $0x0
f0106806:	6a 05                	push   $0x5
f0106808:	eb 64                	jmp    f010686e <_alltraps>

f010680a <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f010680a:	6a 00                	push   $0x0
f010680c:	6a 06                	push   $0x6
f010680e:	eb 5e                	jmp    f010686e <_alltraps>

f0106810 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0106810:	6a 00                	push   $0x0
f0106812:	6a 07                	push   $0x7
f0106814:	eb 58                	jmp    f010686e <_alltraps>

f0106816 <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT)
f0106816:	6a 08                	push   $0x8
f0106818:	eb 54                	jmp    f010686e <_alltraps>

f010681a <t_tss>:

TRAPHANDLER(t_tss, T_TSS)
f010681a:	6a 0a                	push   $0xa
f010681c:	eb 50                	jmp    f010686e <_alltraps>

f010681e <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f010681e:	6a 0b                	push   $0xb
f0106820:	eb 4c                	jmp    f010686e <_alltraps>

f0106822 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0106822:	6a 0c                	push   $0xc
f0106824:	eb 48                	jmp    f010686e <_alltraps>

f0106826 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0106826:	6a 0d                	push   $0xd
f0106828:	eb 44                	jmp    f010686e <_alltraps>

f010682a <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f010682a:	6a 0e                	push   $0xe
f010682c:	eb 40                	jmp    f010686e <_alltraps>

f010682e <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f010682e:	6a 00                	push   $0x0
f0106830:	6a 10                	push   $0x10
f0106832:	eb 3a                	jmp    f010686e <_alltraps>

f0106834 <t_align>:

TRAPHANDLER(t_align, T_ALIGN)
f0106834:	6a 11                	push   $0x11
f0106836:	eb 36                	jmp    f010686e <_alltraps>

f0106838 <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0106838:	6a 00                	push   $0x0
f010683a:	6a 12                	push   $0x12
f010683c:	eb 30                	jmp    f010686e <_alltraps>

f010683e <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f010683e:	6a 00                	push   $0x0
f0106840:	6a 13                	push   $0x13
f0106842:	eb 2a                	jmp    f010686e <_alltraps>

f0106844 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0106844:	6a 00                	push   $0x0
f0106846:	6a 30                	push   $0x30
f0106848:	eb 24                	jmp    f010686e <_alltraps>

f010684a <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET + IRQ_TIMER)
f010684a:	6a 00                	push   $0x0
f010684c:	6a 20                	push   $0x20
f010684e:	eb 1e                	jmp    f010686e <_alltraps>

f0106850 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET + IRQ_KBD)
f0106850:	6a 00                	push   $0x0
f0106852:	6a 21                	push   $0x21
f0106854:	eb 18                	jmp    f010686e <_alltraps>

f0106856 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET + IRQ_SERIAL)
f0106856:	6a 00                	push   $0x0
f0106858:	6a 24                	push   $0x24
f010685a:	eb 12                	jmp    f010686e <_alltraps>

f010685c <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f010685c:	6a 00                	push   $0x0
f010685e:	6a 27                	push   $0x27
f0106860:	eb 0c                	jmp    f010686e <_alltraps>

f0106862 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET + IRQ_IDE)
f0106862:	6a 00                	push   $0x0
f0106864:	6a 2e                	push   $0x2e
f0106866:	eb 06                	jmp    f010686e <_alltraps>

f0106868 <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET + IRQ_ERROR)
f0106868:	6a 00                	push   $0x0
f010686a:	6a 33                	push   $0x33
f010686c:	eb 00                	jmp    f010686e <_alltraps>

f010686e <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 

_alltraps:
	push %ds
f010686e:	1e                   	push   %ds
	push %es
f010686f:	06                   	push   %es
	pushal
f0106870:	60                   	pusha  
	movl $(GD_KD), %eax
f0106871:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0106876:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f0106878:	8e c0                	mov    %eax,%es
	pushl %esp
f010687a:	54                   	push   %esp
	call trap
f010687b:	e8 c2 fb ff ff       	call   f0106442 <trap>

f0106880 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0106880:	55                   	push   %ebp
f0106881:	89 e5                	mov    %esp,%ebp
f0106883:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106886:	8b 55 08             	mov    0x8(%ebp),%edx
f0106889:	8b 45 0c             	mov    0xc(%ebp),%eax
f010688c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010688f:	f0 87 02             	lock xchg %eax,(%edx)
f0106892:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0106895:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0106898:	c9                   	leave  
f0106899:	c3                   	ret    

f010689a <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010689a:	55                   	push   %ebp
f010689b:	89 e5                	mov    %esp,%ebp
f010689d:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f01068a0:	c7 04 24 e0 75 12 f0 	movl   $0xf01275e0,(%esp)
f01068a7:	e8 25 2f 00 00       	call   f01097d1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01068ac:	f3 90                	pause  
}
f01068ae:	c9                   	leave  
f01068af:	c3                   	ret    

f01068b0 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01068b0:	55                   	push   %ebp
f01068b1:	89 e5                	mov    %esp,%ebp
f01068b3:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f01068b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01068b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01068be:	77 21                	ja     f01068e1 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01068c0:	8b 45 10             	mov    0x10(%ebp),%eax
f01068c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01068c7:	c7 44 24 08 f0 b2 10 	movl   $0xf010b2f0,0x8(%esp)
f01068ce:	f0 
f01068cf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01068d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01068d9:	89 04 24             	mov    %eax,(%esp)
f01068dc:	e8 ee 99 ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f01068e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01068e4:	05 00 00 00 10       	add    $0x10000000,%eax
}
f01068e9:	c9                   	leave  
f01068ea:	c3                   	ret    

f01068eb <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01068eb:	55                   	push   %ebp
f01068ec:	89 e5                	mov    %esp,%ebp
f01068ee:	83 ec 28             	sub    $0x28,%esp

	// LAB 4: Your code here.

	int cur_id;
 	int i;
 	bool no_runnable=true;
f01068f1:	c6 45 ef 01          	movb   $0x1,-0x11(%ebp)
	if(!thiscpu->cpu_env) cur_id = 0;
f01068f5:	e8 d4 2b 00 00       	call   f01094ce <cpunum>
f01068fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01068fd:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106902:	8b 00                	mov    (%eax),%eax
f0106904:	85 c0                	test   %eax,%eax
f0106906:	75 0c                	jne    f0106914 <sched_yield+0x29>
f0106908:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010690f:	e9 81 00 00 00       	jmp    f0106995 <sched_yield+0xaa>
	else if(thiscpu->cpu_env->env_status == ENV_RUNNING){
f0106914:	e8 b5 2b 00 00       	call   f01094ce <cpunum>
f0106919:	6b c0 74             	imul   $0x74,%eax,%eax
f010691c:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106921:	8b 00                	mov    (%eax),%eax
f0106923:	8b 40 54             	mov    0x54(%eax),%eax
f0106926:	83 f8 03             	cmp    $0x3,%eax
f0106929:	75 41                	jne    f010696c <sched_yield+0x81>
		thiscpu->cpu_env->env_status = ENV_RUNNABLE;
f010692b:	e8 9e 2b 00 00       	call   f01094ce <cpunum>
f0106930:	6b c0 74             	imul   $0x74,%eax,%eax
f0106933:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106938:	8b 00                	mov    (%eax),%eax
f010693a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		cur_id = thiscpu->cpu_env - envs+1;
f0106941:	e8 88 2b 00 00       	call   f01094ce <cpunum>
f0106946:	6b c0 74             	imul   $0x74,%eax,%eax
f0106949:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010694e:	8b 00                	mov    (%eax),%eax
f0106950:	89 c2                	mov    %eax,%edx
f0106952:	a1 3c 42 29 f0       	mov    0xf029423c,%eax
f0106957:	29 c2                	sub    %eax,%edx
f0106959:	89 d0                	mov    %edx,%eax
f010695b:	c1 f8 02             	sar    $0x2,%eax
f010695e:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0106964:	83 c0 01             	add    $0x1,%eax
f0106967:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010696a:	eb 29                	jmp    f0106995 <sched_yield+0xaa>
	}
	else{
		cur_id = thiscpu->cpu_env - envs + 1;
f010696c:	e8 5d 2b 00 00       	call   f01094ce <cpunum>
f0106971:	6b c0 74             	imul   $0x74,%eax,%eax
f0106974:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106979:	8b 00                	mov    (%eax),%eax
f010697b:	89 c2                	mov    %eax,%edx
f010697d:	a1 3c 42 29 f0       	mov    0xf029423c,%eax
f0106982:	29 c2                	sub    %eax,%edx
f0106984:	89 d0                	mov    %edx,%eax
f0106986:	c1 f8 02             	sar    $0x2,%eax
f0106989:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f010698f:	83 c0 01             	add    $0x1,%eax
f0106992:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
 	for(i = 0;i < NENV; cur_id++, i++){
f0106995:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010699c:	eb 62                	jmp    f0106a00 <sched_yield+0x115>
 		if(cur_id >= NENV) cur_id %= NENV;
f010699e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f01069a5:	7e 13                	jle    f01069ba <sched_yield+0xcf>
f01069a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01069aa:	99                   	cltd   
f01069ab:	c1 ea 16             	shr    $0x16,%edx
f01069ae:	01 d0                	add    %edx,%eax
f01069b0:	25 ff 03 00 00       	and    $0x3ff,%eax
f01069b5:	29 d0                	sub    %edx,%eax
f01069b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 		if(envs[cur_id].env_status == ENV_RUNNABLE){
f01069ba:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f01069c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01069c3:	c1 e0 02             	shl    $0x2,%eax
f01069c6:	89 c1                	mov    %eax,%ecx
f01069c8:	c1 e1 05             	shl    $0x5,%ecx
f01069cb:	29 c1                	sub    %eax,%ecx
f01069cd:	89 c8                	mov    %ecx,%eax
f01069cf:	01 d0                	add    %edx,%eax
f01069d1:	8b 40 54             	mov    0x54(%eax),%eax
f01069d4:	83 f8 02             	cmp    $0x2,%eax
f01069d7:	75 1f                	jne    f01069f8 <sched_yield+0x10d>
 			env_run(&envs[cur_id]);
f01069d9:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f01069df:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01069e2:	c1 e0 02             	shl    $0x2,%eax
f01069e5:	89 c1                	mov    %eax,%ecx
f01069e7:	c1 e1 05             	shl    $0x5,%ecx
f01069ea:	29 c1                	sub    %eax,%ecx
f01069ec:	89 c8                	mov    %ecx,%eax
f01069ee:	01 d0                	add    %edx,%eax
f01069f0:	89 04 24             	mov    %eax,(%esp)
f01069f3:	e8 cf e1 ff ff       	call   f0104bc7 <env_run>
		cur_id = thiscpu->cpu_env - envs+1;
	}
	else{
		cur_id = thiscpu->cpu_env - envs + 1;
	}
 	for(i = 0;i < NENV; cur_id++, i++){
f01069f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01069fc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0106a00:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0106a07:	7e 95                	jle    f010699e <sched_yield+0xb3>
 			break;
 		}
 	}
 	// if((i == NENV) && (thiscpu->cpu_env->env_status == ENV_RUNNING)) env_run(&envs[cpunum()]);
	// sched_halt never returns
	if(no_runnable){
f0106a09:	80 7d ef 00          	cmpb   $0x0,-0x11(%ebp)
f0106a0d:	74 05                	je     f0106a14 <sched_yield+0x129>
		sched_halt();
f0106a0f:	e8 02 00 00 00       	call   f0106a16 <sched_halt>
	}
}
f0106a14:	c9                   	leave  
f0106a15:	c3                   	ret    

f0106a16 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0106a16:	55                   	push   %ebp
f0106a17:	89 e5                	mov    %esp,%ebp
f0106a19:	83 ec 28             	sub    $0x28,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0106a23:	eb 61                	jmp    f0106a86 <sched_halt+0x70>
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0106a25:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0106a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106a2e:	c1 e0 02             	shl    $0x2,%eax
f0106a31:	89 c1                	mov    %eax,%ecx
f0106a33:	c1 e1 05             	shl    $0x5,%ecx
f0106a36:	29 c1                	sub    %eax,%ecx
f0106a38:	89 c8                	mov    %ecx,%eax
f0106a3a:	01 d0                	add    %edx,%eax
f0106a3c:	8b 40 54             	mov    0x54(%eax),%eax
f0106a3f:	83 f8 02             	cmp    $0x2,%eax
f0106a42:	74 4b                	je     f0106a8f <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
f0106a44:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0106a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106a4d:	c1 e0 02             	shl    $0x2,%eax
f0106a50:	89 c1                	mov    %eax,%ecx
f0106a52:	c1 e1 05             	shl    $0x5,%ecx
f0106a55:	29 c1                	sub    %eax,%ecx
f0106a57:	89 c8                	mov    %ecx,%eax
f0106a59:	01 d0                	add    %edx,%eax
f0106a5b:	8b 40 54             	mov    0x54(%eax),%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0106a5e:	83 f8 03             	cmp    $0x3,%eax
f0106a61:	74 2c                	je     f0106a8f <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
f0106a63:	8b 15 3c 42 29 f0    	mov    0xf029423c,%edx
f0106a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106a6c:	c1 e0 02             	shl    $0x2,%eax
f0106a6f:	89 c1                	mov    %eax,%ecx
f0106a71:	c1 e1 05             	shl    $0x5,%ecx
f0106a74:	29 c1                	sub    %eax,%ecx
f0106a76:	89 c8                	mov    %ecx,%eax
f0106a78:	01 d0                	add    %edx,%eax
f0106a7a:	8b 40 54             	mov    0x54(%eax),%eax

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0106a7d:	83 f8 01             	cmp    $0x1,%eax
f0106a80:	74 0d                	je     f0106a8f <sched_halt+0x79>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106a82:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0106a86:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0106a8d:	7e 96                	jle    f0106a25 <sched_halt+0xf>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0106a8f:	81 7d f4 00 04 00 00 	cmpl   $0x400,-0xc(%ebp)
f0106a96:	75 1a                	jne    f0106ab2 <sched_halt+0x9c>
		cprintf("No runnable environments in the system!\n");
f0106a98:	c7 04 24 14 b3 10 f0 	movl   $0xf010b314,(%esp)
f0106a9f:	e8 aa e4 ff ff       	call   f0104f4e <cprintf>
		while (1)
			monitor(NULL);
f0106aa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106aab:	e8 9c a6 ff ff       	call   f010114c <monitor>
f0106ab0:	eb f2                	jmp    f0106aa4 <sched_halt+0x8e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0106ab2:	e8 17 2a 00 00       	call   f01094ce <cpunum>
f0106ab7:	6b c0 74             	imul   $0x74,%eax,%eax
f0106aba:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106abf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lcr3(PADDR(kern_pgdir));
f0106ac5:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f0106aca:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ace:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0106ad5:	00 
f0106ad6:	c7 04 24 3d b3 10 f0 	movl   $0xf010b33d,(%esp)
f0106add:	e8 ce fd ff ff       	call   f01068b0 <_paddr>
f0106ae2:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0106ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106ae8:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0106aeb:	e8 de 29 00 00       	call   f01094ce <cpunum>
f0106af0:	6b c0 74             	imul   $0x74,%eax,%eax
f0106af3:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0106af8:	83 c0 04             	add    $0x4,%eax
f0106afb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0106b02:	00 
f0106b03:	89 04 24             	mov    %eax,(%esp)
f0106b06:	e8 75 fd ff ff       	call   f0106880 <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f0106b0b:	e8 8a fd ff ff       	call   f010689a <unlock_kernel>
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0106b10:	e8 b9 29 00 00       	call   f01094ce <cpunum>
f0106b15:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b18:	05 30 80 29 f0       	add    $0xf0298030,%eax
f0106b1d:	8b 00                	mov    (%eax),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0106b1f:	bd 00 00 00 00       	mov    $0x0,%ebp
f0106b24:	89 c4                	mov    %eax,%esp
f0106b26:	6a 00                	push   $0x0
f0106b28:	6a 00                	push   $0x0
f0106b2a:	fb                   	sti    
f0106b2b:	f4                   	hlt    
f0106b2c:	eb fd                	jmp    f0106b2b <sched_halt+0x115>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0106b2e:	c9                   	leave  
f0106b2f:	c3                   	ret    

f0106b30 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0106b30:	55                   	push   %ebp
f0106b31:	89 e5                	mov    %esp,%ebp
f0106b33:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f0106b36:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b39:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0106b3e:	77 21                	ja     f0106b61 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106b40:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106b47:	c7 44 24 08 4c b3 10 	movl   $0xf010b34c,0x8(%esp)
f0106b4e:	f0 
f0106b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b56:	8b 45 08             	mov    0x8(%ebp),%eax
f0106b59:	89 04 24             	mov    %eax,(%esp)
f0106b5c:	e8 6e 97 ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106b61:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b64:	05 00 00 00 10       	add    $0x10000000,%eax
}
f0106b69:	c9                   	leave  
f0106b6a:	c3                   	ret    

f0106b6b <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
f0106b6b:	55                   	push   %ebp
f0106b6c:	89 e5                	mov    %esp,%ebp
f0106b6e:	83 ec 18             	sub    $0x18,%esp
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv,s, len, 0);
f0106b71:	e8 58 29 00 00       	call   f01094ce <cpunum>
f0106b76:	6b c0 74             	imul   $0x74,%eax,%eax
f0106b79:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106b7e:	8b 00                	mov    (%eax),%eax
f0106b80:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106b87:	00 
f0106b88:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b8b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b8f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106b92:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b96:	89 04 24             	mov    %eax,(%esp)
f0106b99:	e8 66 b2 ff ff       	call   f0101e04 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0106b9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bac:	c7 04 24 70 b3 10 f0 	movl   $0xf010b370,(%esp)
f0106bb3:	e8 96 e3 ff ff       	call   f0104f4e <cprintf>
}
f0106bb8:	c9                   	leave  
f0106bb9:	c3                   	ret    

f0106bba <sys_cgetc>:

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
f0106bba:	55                   	push   %ebp
f0106bbb:	89 e5                	mov    %esp,%ebp
f0106bbd:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f0106bc0:	e8 f4 9e ff ff       	call   f0100ab9 <cons_getc>
}
f0106bc5:	c9                   	leave  
f0106bc6:	c3                   	ret    

f0106bc7 <sys_getenvid>:

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0106bc7:	55                   	push   %ebp
f0106bc8:	89 e5                	mov    %esp,%ebp
f0106bca:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0106bcd:	e8 fc 28 00 00       	call   f01094ce <cpunum>
f0106bd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0106bd5:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106bda:	8b 00                	mov    (%eax),%eax
f0106bdc:	8b 40 48             	mov    0x48(%eax),%eax
}
f0106bdf:	c9                   	leave  
f0106be0:	c3                   	ret    

f0106be1 <sys_env_destroy>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
f0106be1:	55                   	push   %ebp
f0106be2:	89 e5                	mov    %esp,%ebp
f0106be4:	53                   	push   %ebx
f0106be5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0106be8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106bef:	00 
f0106bf0:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0106bfa:	89 04 24             	mov    %eax,(%esp)
f0106bfd:	e8 5f d7 ff ff       	call   f0104361 <envid2env>
f0106c02:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106c05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106c09:	79 05                	jns    f0106c10 <sys_env_destroy+0x2f>
		return r;
f0106c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106c0e:	eb 76                	jmp    f0106c86 <sys_env_destroy+0xa5>
	if (e == curenv)
f0106c10:	e8 b9 28 00 00       	call   f01094ce <cpunum>
f0106c15:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c18:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106c1d:	8b 10                	mov    (%eax),%edx
f0106c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c22:	39 c2                	cmp    %eax,%edx
f0106c24:	75 24                	jne    f0106c4a <sys_env_destroy+0x69>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0106c26:	e8 a3 28 00 00       	call   f01094ce <cpunum>
f0106c2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c2e:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106c33:	8b 00                	mov    (%eax),%eax
f0106c35:	8b 40 48             	mov    0x48(%eax),%eax
f0106c38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c3c:	c7 04 24 75 b3 10 f0 	movl   $0xf010b375,(%esp)
f0106c43:	e8 06 e3 ff ff       	call   f0104f4e <cprintf>
f0106c48:	eb 2c                	jmp    f0106c76 <sys_env_destroy+0x95>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0106c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c4d:	8b 58 48             	mov    0x48(%eax),%ebx
f0106c50:	e8 79 28 00 00       	call   f01094ce <cpunum>
f0106c55:	6b c0 74             	imul   $0x74,%eax,%eax
f0106c58:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106c5d:	8b 00                	mov    (%eax),%eax
f0106c5f:	8b 40 48             	mov    0x48(%eax),%eax
f0106c62:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106c66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c6a:	c7 04 24 90 b3 10 f0 	movl   $0xf010b390,(%esp)
f0106c71:	e8 d8 e2 ff ff       	call   f0104f4e <cprintf>
	env_destroy(e);
f0106c76:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c79:	89 04 24             	mov    %eax,(%esp)
f0106c7c:	e8 66 de ff ff       	call   f0104ae7 <env_destroy>
	return 0;
f0106c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106c86:	83 c4 24             	add    $0x24,%esp
f0106c89:	5b                   	pop    %ebx
f0106c8a:	5d                   	pop    %ebp
f0106c8b:	c3                   	ret    

f0106c8c <sys_yield>:

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0106c8c:	55                   	push   %ebp
f0106c8d:	89 e5                	mov    %esp,%ebp
f0106c8f:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0106c92:	e8 54 fc ff ff       	call   f01068eb <sched_yield>

f0106c97 <sys_exofork>:
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
f0106c97:	55                   	push   %ebp
f0106c98:	89 e5                	mov    %esp,%ebp
f0106c9a:	57                   	push   %edi
f0106c9b:	56                   	push   %esi
f0106c9c:	53                   	push   %ebx
f0106c9d:	83 ec 2c             	sub    $0x2c,%esp
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env* e;
	int r;
	if((r = env_alloc(&e,curenv->env_id)) < 0) return r;
f0106ca0:	e8 29 28 00 00       	call   f01094ce <cpunum>
f0106ca5:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ca8:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106cad:	8b 00                	mov    (%eax),%eax
f0106caf:	8b 40 48             	mov    0x48(%eax),%eax
f0106cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cb6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106cb9:	89 04 24             	mov    %eax,(%esp)
f0106cbc:	e8 d8 d8 ff ff       	call   f0104599 <env_alloc>
f0106cc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106cc4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106cc8:	79 05                	jns    f0106ccf <sys_exofork+0x38>
f0106cca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106ccd:	eb 3d                	jmp    f0106d0c <sys_exofork+0x75>
	e->env_status = ENV_NOT_RUNNABLE;
f0106ccf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106cd2:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f0106cd9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0106cdc:	e8 ed 27 00 00       	call   f01094ce <cpunum>
f0106ce1:	6b c0 74             	imul   $0x74,%eax,%eax
f0106ce4:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0106ce9:	8b 00                	mov    (%eax),%eax
f0106ceb:	89 da                	mov    %ebx,%edx
f0106ced:	89 c3                	mov    %eax,%ebx
f0106cef:	b8 11 00 00 00       	mov    $0x11,%eax
f0106cf4:	89 d7                	mov    %edx,%edi
f0106cf6:	89 de                	mov    %ebx,%esi
f0106cf8:	89 c1                	mov    %eax,%ecx
f0106cfa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0106cfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106cff:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0106d06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106d09:	8b 40 48             	mov    0x48(%eax),%eax
	// panic("sys_exofork not implemented");
}
f0106d0c:	83 c4 2c             	add    $0x2c,%esp
f0106d0f:	5b                   	pop    %ebx
f0106d10:	5e                   	pop    %esi
f0106d11:	5f                   	pop    %edi
f0106d12:	5d                   	pop    %ebp
f0106d13:	c3                   	ret    

f0106d14 <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0106d14:	55                   	push   %ebp
f0106d15:	89 e5                	mov    %esp,%ebp
f0106d17:	83 ec 28             	sub    $0x28,%esp
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106d1a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106d21:	00 
f0106d22:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106d25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d29:	8b 45 08             	mov    0x8(%ebp),%eax
f0106d2c:	89 04 24             	mov    %eax,(%esp)
f0106d2f:	e8 2d d6 ff ff       	call   f0104361 <envid2env>
f0106d34:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106d37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106d3b:	79 05                	jns    f0106d42 <sys_env_set_status+0x2e>
f0106d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106d40:	eb 21                	jmp    f0106d63 <sys_env_set_status+0x4f>
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
f0106d42:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
f0106d46:	74 06                	je     f0106d4e <sys_env_set_status+0x3a>
f0106d48:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
f0106d4c:	75 10                	jne    f0106d5e <sys_env_set_status+0x4a>
f0106d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106d51:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106d54:	89 50 54             	mov    %edx,0x54(%eax)
	else return -E_INVAL;
	return 0;
f0106d57:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d5c:	eb 05                	jmp    f0106d63 <sys_env_set_status+0x4f>
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
	else return -E_INVAL;
f0106d5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return 0;
	// panic("sys_env_set_status not implemented");
}
f0106d63:	c9                   	leave  
f0106d64:	c3                   	ret    

f0106d65 <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f0106d65:	55                   	push   %ebp
f0106d66:	89 e5                	mov    %esp,%ebp
f0106d68:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106d6b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106d72:	00 
f0106d73:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106d76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0106d7d:	89 04 24             	mov    %eax,(%esp)
f0106d80:	e8 dc d5 ff ff       	call   f0104361 <envid2env>
f0106d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106d88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106d8c:	79 05                	jns    f0106d93 <sys_env_set_pgfault_upcall+0x2e>
f0106d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106d91:	eb 0e                	jmp    f0106da1 <sys_env_set_pgfault_upcall+0x3c>
	e->env_pgfault_upcall = func;
f0106d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106d96:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106d99:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f0106d9c:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_env_set_pgfault_upcall not implemented");
}
f0106da1:	c9                   	leave  
f0106da2:	c3                   	ret    

f0106da3 <sys_page_alloc>:
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
f0106da3:	55                   	push   %ebp
f0106da4:	89 e5                	mov    %esp,%ebp
f0106da6:	83 ec 38             	sub    $0x38,%esp

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
f0106da9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106dac:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106db1:	77 2e                	ja     f0106de1 <sys_page_alloc+0x3e>
f0106db3:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106dba:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106dc0:	01 d0                	add    %edx,%eax
f0106dc2:	83 e8 01             	sub    $0x1,%eax
f0106dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106dc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106dcb:	ba 00 00 00 00       	mov    $0x0,%edx
f0106dd0:	f7 75 f4             	divl   -0xc(%ebp)
f0106dd3:	89 d0                	mov    %edx,%eax
f0106dd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106dd8:	29 c2                	sub    %eax,%edx
f0106dda:	89 d0                	mov    %edx,%eax
f0106ddc:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106ddf:	74 0a                	je     f0106deb <sys_page_alloc+0x48>
f0106de1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106de6:	e9 a3 00 00 00       	jmp    f0106e8e <sys_page_alloc+0xeb>
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
f0106deb:	8b 45 10             	mov    0x10(%ebp),%eax
f0106dee:	83 e0 04             	and    $0x4,%eax
f0106df1:	85 c0                	test   %eax,%eax
f0106df3:	74 0a                	je     f0106dff <sys_page_alloc+0x5c>
f0106df5:	8b 45 10             	mov    0x10(%ebp),%eax
f0106df8:	83 e0 01             	and    $0x1,%eax
f0106dfb:	85 c0                	test   %eax,%eax
f0106dfd:	75 0a                	jne    f0106e09 <sys_page_alloc+0x66>
f0106dff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e04:	e9 85 00 00 00       	jmp    f0106e8e <sys_page_alloc+0xeb>
	if(perm & !PTE_SYSCALL) return -E_INVAL;
	
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106e09:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106e10:	00 
f0106e11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106e14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e18:	8b 45 08             	mov    0x8(%ebp),%eax
f0106e1b:	89 04 24             	mov    %eax,(%esp)
f0106e1e:	e8 3e d5 ff ff       	call   f0104361 <envid2env>
f0106e23:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106e26:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106e2a:	79 05                	jns    f0106e31 <sys_page_alloc+0x8e>
f0106e2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106e2f:	eb 5d                	jmp    f0106e8e <sys_page_alloc+0xeb>
	struct PageInfo *p;
	if(!(p = page_alloc(ALLOC_ZERO))) return -E_NO_MEM;
f0106e31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106e38:	e8 45 aa ff ff       	call   f0101882 <page_alloc>
f0106e3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106e40:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106e44:	75 07                	jne    f0106e4d <sys_page_alloc+0xaa>
f0106e46:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106e4b:	eb 41                	jmp    f0106e8e <sys_page_alloc+0xeb>
	if((r = page_insert(e->env_pgdir, p, va, perm)) < 0){
f0106e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106e50:	8b 40 60             	mov    0x60(%eax),%eax
f0106e53:	8b 55 10             	mov    0x10(%ebp),%edx
f0106e56:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106e5a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e5d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106e61:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106e64:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e68:	89 04 24             	mov    %eax,(%esp)
f0106e6b:	e8 9b ac ff ff       	call   f0101b0b <page_insert>
f0106e70:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106e73:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106e77:	79 10                	jns    f0106e89 <sys_page_alloc+0xe6>
		page_free(p);
f0106e79:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106e7c:	89 04 24             	mov    %eax,(%esp)
f0106e7f:	e8 61 aa ff ff       	call   f01018e5 <page_free>
		return r;
f0106e84:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106e87:	eb 05                	jmp    f0106e8e <sys_page_alloc+0xeb>
	}
	return 0;
f0106e89:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_alloc not implemented");
}
f0106e8e:	c9                   	leave  
f0106e8f:	c3                   	ret    

f0106e90 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0106e90:	55                   	push   %ebp
f0106e91:	89 e5                	mov    %esp,%ebp
f0106e93:	83 ec 48             	sub    $0x48,%esp
	// LAB 4: Your code here.
	struct Env *srce;
	struct Env *dste;
	int r;

	if((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE) != srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE) != dstva) return -E_INVAL;
f0106e96:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106e99:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106e9e:	77 66                	ja     f0106f06 <sys_page_map+0x76>
f0106ea0:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106ea7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106ead:	01 d0                	add    %edx,%eax
f0106eaf:	83 e8 01             	sub    $0x1,%eax
f0106eb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106eb8:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ebd:	f7 75 f4             	divl   -0xc(%ebp)
f0106ec0:	89 d0                	mov    %edx,%eax
f0106ec2:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106ec5:	29 c2                	sub    %eax,%edx
f0106ec7:	89 d0                	mov    %edx,%eax
f0106ec9:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106ecc:	75 38                	jne    f0106f06 <sys_page_map+0x76>
f0106ece:	8b 45 14             	mov    0x14(%ebp),%eax
f0106ed1:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106ed6:	77 2e                	ja     f0106f06 <sys_page_map+0x76>
f0106ed8:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0106edf:	8b 55 14             	mov    0x14(%ebp),%edx
f0106ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106ee5:	01 d0                	add    %edx,%eax
f0106ee7:	83 e8 01             	sub    $0x1,%eax
f0106eea:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106eed:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106ef0:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ef5:	f7 75 ec             	divl   -0x14(%ebp)
f0106ef8:	89 d0                	mov    %edx,%eax
f0106efa:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106efd:	29 c2                	sub    %eax,%edx
f0106eff:	89 d0                	mov    %edx,%eax
f0106f01:	3b 45 14             	cmp    0x14(%ebp),%eax
f0106f04:	74 0a                	je     f0106f10 <sys_page_map+0x80>
f0106f06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106f0b:	e9 f5 00 00 00       	jmp    f0107005 <sys_page_map+0x175>
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
f0106f10:	8b 45 18             	mov    0x18(%ebp),%eax
f0106f13:	83 e0 04             	and    $0x4,%eax
f0106f16:	85 c0                	test   %eax,%eax
f0106f18:	74 0a                	je     f0106f24 <sys_page_map+0x94>
f0106f1a:	8b 45 18             	mov    0x18(%ebp),%eax
f0106f1d:	83 e0 01             	and    $0x1,%eax
f0106f20:	85 c0                	test   %eax,%eax
f0106f22:	75 0a                	jne    f0106f2e <sys_page_map+0x9e>
f0106f24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106f29:	e9 d7 00 00 00       	jmp    f0107005 <sys_page_map+0x175>
	if(perm & !PTE_SYSCALL) return -E_INVAL;

	if((r = envid2env(srcenvid, &srce, 1)) < 0) return r;
f0106f2e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106f35:	00 
f0106f36:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106f39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f40:	89 04 24             	mov    %eax,(%esp)
f0106f43:	e8 19 d4 ff ff       	call   f0104361 <envid2env>
f0106f48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106f4b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106f4f:	79 08                	jns    f0106f59 <sys_page_map+0xc9>
f0106f51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f54:	e9 ac 00 00 00       	jmp    f0107005 <sys_page_map+0x175>
	if((r = envid2env(dstenvid, &dste, 1)) < 0) return r;
f0106f59:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106f60:	00 
f0106f61:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0106f64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f68:	8b 45 10             	mov    0x10(%ebp),%eax
f0106f6b:	89 04 24             	mov    %eax,(%esp)
f0106f6e:	e8 ee d3 ff ff       	call   f0104361 <envid2env>
f0106f73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106f76:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106f7a:	79 08                	jns    f0106f84 <sys_page_map+0xf4>
f0106f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f7f:	e9 81 00 00 00       	jmp    f0107005 <sys_page_map+0x175>
	struct PageInfo *srcp;
	struct PageInfo *dstp;
	pte_t *ptable_entry;
	if(!(srcp = page_lookup(srce->env_pgdir, srcva, &ptable_entry))) return -E_INVAL;
f0106f84:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106f87:	8b 40 60             	mov    0x60(%eax),%eax
f0106f8a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0106f8d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f91:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106f94:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106f98:	89 04 24             	mov    %eax,(%esp)
f0106f9b:	e8 fd ab ff ff       	call   f0101b9d <page_lookup>
f0106fa0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0106fa3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0106fa7:	75 07                	jne    f0106fb0 <sys_page_map+0x120>
f0106fa9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106fae:	eb 55                	jmp    f0107005 <sys_page_map+0x175>
	if(~(*ptable_entry & PTE_W) & (perm & PTE_W)) return -E_INVAL;
f0106fb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106fb3:	8b 00                	mov    (%eax),%eax
f0106fb5:	83 e0 02             	and    $0x2,%eax
f0106fb8:	f7 d0                	not    %eax
f0106fba:	89 c2                	mov    %eax,%edx
f0106fbc:	8b 45 18             	mov    0x18(%ebp),%eax
f0106fbf:	21 d0                	and    %edx,%eax
f0106fc1:	83 e0 02             	and    $0x2,%eax
f0106fc4:	85 c0                	test   %eax,%eax
f0106fc6:	74 07                	je     f0106fcf <sys_page_map+0x13f>
f0106fc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106fcd:	eb 36                	jmp    f0107005 <sys_page_map+0x175>
	if((r = page_insert(dste->env_pgdir, srcp, dstva, perm)) < 0) return r;
f0106fcf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106fd2:	8b 40 60             	mov    0x60(%eax),%eax
f0106fd5:	8b 55 18             	mov    0x18(%ebp),%edx
f0106fd8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106fdc:	8b 55 14             	mov    0x14(%ebp),%edx
f0106fdf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106fe3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106fe6:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106fea:	89 04 24             	mov    %eax,(%esp)
f0106fed:	e8 19 ab ff ff       	call   f0101b0b <page_insert>
f0106ff2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106ff5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106ff9:	79 05                	jns    f0107000 <sys_page_map+0x170>
f0106ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106ffe:	eb 05                	jmp    f0107005 <sys_page_map+0x175>
	return 0;
f0107000:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_map not implemented");
}
f0107005:	c9                   	leave  
f0107006:	c3                   	ret    

f0107007 <sys_page_unmap>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0107007:	55                   	push   %ebp
f0107008:	89 e5                	mov    %esp,%ebp
f010700a:	83 ec 28             	sub    $0x28,%esp
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
f010700d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107010:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0107015:	77 2e                	ja     f0107045 <sys_page_unmap+0x3e>
f0107017:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f010701e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107021:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107024:	01 d0                	add    %edx,%eax
f0107026:	83 e8 01             	sub    $0x1,%eax
f0107029:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010702c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010702f:	ba 00 00 00 00       	mov    $0x0,%edx
f0107034:	f7 75 f4             	divl   -0xc(%ebp)
f0107037:	89 d0                	mov    %edx,%eax
f0107039:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010703c:	29 c2                	sub    %eax,%edx
f010703e:	89 d0                	mov    %edx,%eax
f0107040:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0107043:	74 07                	je     f010704c <sys_page_unmap+0x45>
f0107045:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010704a:	eb 42                	jmp    f010708e <sys_page_unmap+0x87>
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f010704c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0107053:	00 
f0107054:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0107057:	89 44 24 04          	mov    %eax,0x4(%esp)
f010705b:	8b 45 08             	mov    0x8(%ebp),%eax
f010705e:	89 04 24             	mov    %eax,(%esp)
f0107061:	e8 fb d2 ff ff       	call   f0104361 <envid2env>
f0107066:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107069:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010706d:	79 05                	jns    f0107074 <sys_page_unmap+0x6d>
f010706f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107072:	eb 1a                	jmp    f010708e <sys_page_unmap+0x87>
	page_remove(e->env_pgdir, va);
f0107074:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107077:	8b 40 60             	mov    0x60(%eax),%eax
f010707a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010707d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107081:	89 04 24             	mov    %eax,(%esp)
f0107084:	e8 67 ab ff ff       	call   f0101bf0 <page_remove>
	return 0;
f0107089:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_unmap not implemented");
}
f010708e:	c9                   	leave  
f010708f:	c3                   	ret    

f0107090 <sys_ipc_try_send>:
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
f0107090:	55                   	push   %ebp
f0107091:	89 e5                	mov    %esp,%ebp
f0107093:	53                   	push   %ebx
f0107094:	83 ec 34             	sub    $0x34,%esp
	// LAB 4: Your code here.
	struct Env *rec_env;
	int r;
	uint32_t i_srcva = (uint32_t)srcva;
f0107097:	8b 45 10             	mov    0x10(%ebp),%eax
f010709a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(i_srcva < UTOP && (ROUNDDOWN(srcva,PGSIZE) != srcva)) return -E_INVAL;
f010709d:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f01070a4:	77 1d                	ja     f01070c3 <sys_ipc_try_send+0x33>
f01070a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01070a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01070ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01070af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01070b4:	3b 45 10             	cmp    0x10(%ebp),%eax
f01070b7:	74 0a                	je     f01070c3 <sys_ipc_try_send+0x33>
f01070b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01070be:	e9 64 01 00 00       	jmp    f0107227 <sys_ipc_try_send+0x197>
	if(i_srcva < UTOP && (!(perm & PTE_U) || !(perm & PTE_P))) return -E_INVAL;
f01070c3:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f01070ca:	77 1e                	ja     f01070ea <sys_ipc_try_send+0x5a>
f01070cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01070cf:	83 e0 04             	and    $0x4,%eax
f01070d2:	85 c0                	test   %eax,%eax
f01070d4:	74 0a                	je     f01070e0 <sys_ipc_try_send+0x50>
f01070d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01070d9:	83 e0 01             	and    $0x1,%eax
f01070dc:	85 c0                	test   %eax,%eax
f01070de:	75 0a                	jne    f01070ea <sys_ipc_try_send+0x5a>
f01070e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01070e5:	e9 3d 01 00 00       	jmp    f0107227 <sys_ipc_try_send+0x197>
	if(i_srcva < UTOP && (perm & !PTE_SYSCALL)) return -E_INVAL;
	pte_t *pte;
	struct PageInfo *pp;
	if(i_srcva < UTOP && !(pp = page_lookup(curenv->env_pgdir, srcva, &pte))) return -E_INVAL;
f01070ea:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f01070f1:	77 3b                	ja     f010712e <sys_ipc_try_send+0x9e>
f01070f3:	e8 d6 23 00 00       	call   f01094ce <cpunum>
f01070f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01070fb:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107100:	8b 00                	mov    (%eax),%eax
f0107102:	8b 40 60             	mov    0x60(%eax),%eax
f0107105:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0107108:	89 54 24 08          	mov    %edx,0x8(%esp)
f010710c:	8b 55 10             	mov    0x10(%ebp),%edx
f010710f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107113:	89 04 24             	mov    %eax,(%esp)
f0107116:	e8 82 aa ff ff       	call   f0101b9d <page_lookup>
f010711b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010711e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0107122:	75 0a                	jne    f010712e <sys_ipc_try_send+0x9e>
f0107124:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107129:	e9 f9 00 00 00       	jmp    f0107227 <sys_ipc_try_send+0x197>
	if((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f010712e:	8b 45 14             	mov    0x14(%ebp),%eax
f0107131:	83 e0 02             	and    $0x2,%eax
f0107134:	85 c0                	test   %eax,%eax
f0107136:	74 16                	je     f010714e <sys_ipc_try_send+0xbe>
f0107138:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010713b:	8b 00                	mov    (%eax),%eax
f010713d:	83 e0 02             	and    $0x2,%eax
f0107140:	85 c0                	test   %eax,%eax
f0107142:	75 0a                	jne    f010714e <sys_ipc_try_send+0xbe>
f0107144:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107149:	e9 d9 00 00 00       	jmp    f0107227 <sys_ipc_try_send+0x197>
	
	if((r = envid2env(envid,&rec_env,0)) < 0) return r;
f010714e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0107155:	00 
f0107156:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0107159:	89 44 24 04          	mov    %eax,0x4(%esp)
f010715d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107160:	89 04 24             	mov    %eax,(%esp)
f0107163:	e8 f9 d1 ff ff       	call   f0104361 <envid2env>
f0107168:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010716b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010716f:	79 08                	jns    f0107179 <sys_ipc_try_send+0xe9>
f0107171:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107174:	e9 ae 00 00 00       	jmp    f0107227 <sys_ipc_try_send+0x197>
	
	if(!rec_env->env_ipc_recving) return -E_IPC_NOT_RECV;
f0107179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010717c:	0f b6 40 68          	movzbl 0x68(%eax),%eax
f0107180:	83 f0 01             	xor    $0x1,%eax
f0107183:	84 c0                	test   %al,%al
f0107185:	74 0a                	je     f0107191 <sys_ipc_try_send+0x101>
f0107187:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f010718c:	e9 96 00 00 00       	jmp    f0107227 <sys_ipc_try_send+0x197>

	if(i_srcva < UTOP && ((uint32_t)rec_env->env_ipc_dstva) < UTOP){
f0107191:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0107198:	77 4c                	ja     f01071e6 <sys_ipc_try_send+0x156>
f010719a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010719d:	8b 40 6c             	mov    0x6c(%eax),%eax
f01071a0:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01071a5:	77 3f                	ja     f01071e6 <sys_ipc_try_send+0x156>
		if((r = page_insert(rec_env->env_pgdir, pp, rec_env->env_ipc_dstva, perm)) < 0) return r;
f01071a7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01071aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01071ad:	8b 50 6c             	mov    0x6c(%eax),%edx
f01071b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01071b3:	8b 40 60             	mov    0x60(%eax),%eax
f01071b6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01071ba:	89 54 24 08          	mov    %edx,0x8(%esp)
f01071be:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01071c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01071c5:	89 04 24             	mov    %eax,(%esp)
f01071c8:	e8 3e a9 ff ff       	call   f0101b0b <page_insert>
f01071cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01071d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01071d4:	79 05                	jns    f01071db <sys_ipc_try_send+0x14b>
f01071d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01071d9:	eb 4c                	jmp    f0107227 <sys_ipc_try_send+0x197>
		rec_env->env_ipc_perm = perm;
f01071db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01071de:	8b 55 14             	mov    0x14(%ebp),%edx
f01071e1:	89 50 78             	mov    %edx,0x78(%eax)
f01071e4:	eb 0a                	jmp    f01071f0 <sys_ipc_try_send+0x160>
	}
	else{
		rec_env->env_ipc_perm = 0;
f01071e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01071e9:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	rec_env->env_ipc_recving = 0;
f01071f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01071f3:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	rec_env->env_ipc_from = curenv->env_id;
f01071f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01071fa:	e8 cf 22 00 00       	call   f01094ce <cpunum>
f01071ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0107202:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107207:	8b 00                	mov    (%eax),%eax
f0107209:	8b 40 48             	mov    0x48(%eax),%eax
f010720c:	89 43 74             	mov    %eax,0x74(%ebx)
	rec_env->env_ipc_value = value;
f010720f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107212:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107215:	89 50 70             	mov    %edx,0x70(%eax)
	rec_env->env_status = ENV_RUNNABLE;
f0107218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010721b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0107222:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_ipc_try_send not implemented");
}
f0107227:	83 c4 34             	add    $0x34,%esp
f010722a:	5b                   	pop    %ebx
f010722b:	5d                   	pop    %ebp
f010722c:	c3                   	ret    

f010722d <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f010722d:	55                   	push   %ebp
f010722e:	89 e5                	mov    %esp,%ebp
f0107230:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	if((uint32_t)dstva < UTOP && ROUNDDOWN((uint32_t)dstva,PGSIZE) != PGSIZE) return -E_INVAL;
f0107233:	8b 45 08             	mov    0x8(%ebp),%eax
f0107236:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f010723b:	77 1c                	ja     f0107259 <sys_ipc_recv+0x2c>
f010723d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107240:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107243:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107246:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010724b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0107250:	74 07                	je     f0107259 <sys_ipc_recv+0x2c>
f0107252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107257:	eb 5e                	jmp    f01072b7 <sys_ipc_recv+0x8a>
	curenv->env_ipc_recving = 1;
f0107259:	e8 70 22 00 00       	call   f01094ce <cpunum>
f010725e:	6b c0 74             	imul   $0x74,%eax,%eax
f0107261:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107266:	8b 00                	mov    (%eax),%eax
f0107268:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f010726c:	e8 5d 22 00 00       	call   f01094ce <cpunum>
f0107271:	6b c0 74             	imul   $0x74,%eax,%eax
f0107274:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107279:	8b 00                	mov    (%eax),%eax
f010727b:	8b 55 08             	mov    0x8(%ebp),%edx
f010727e:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0107281:	e8 48 22 00 00       	call   f01094ce <cpunum>
f0107286:	6b c0 74             	imul   $0x74,%eax,%eax
f0107289:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010728e:	8b 00                	mov    (%eax),%eax
f0107290:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	curenv->env_tf.tf_regs.reg_eax = 0;
f0107297:	e8 32 22 00 00       	call   f01094ce <cpunum>
f010729c:	6b c0 74             	imul   $0x74,%eax,%eax
f010729f:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01072a4:	8b 00                	mov    (%eax),%eax
f01072a6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	sys_yield();
f01072ad:	e8 da f9 ff ff       	call   f0106c8c <sys_yield>
	// panic("sys_ipc_recv not implemented");
	return 0;
f01072b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01072b7:	c9                   	leave  
f01072b8:	c3                   	ret    

f01072b9 <get_cmd>:

static char cmd[1024] = {0};
static char args[10][1024] = {{0}};

void get_cmd(char* buf){
f01072b9:	55                   	push   %ebp
f01072ba:	89 e5                	mov    %esp,%ebp
f01072bc:	57                   	push   %edi
f01072bd:	53                   	push   %ebx
f01072be:	81 ec 30 04 00 00    	sub    $0x430,%esp
	int i;
	for(i=0;i <1024;i++){
f01072c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01072cb:	eb 0f                	jmp    f01072dc <get_cmd+0x23>
		cmd[i] = '\0';
f01072cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01072d0:	05 e0 4a 29 f0       	add    $0xf0294ae0,%eax
f01072d5:	c6 00 00             	movb   $0x0,(%eax)
static char cmd[1024] = {0};
static char args[10][1024] = {{0}};

void get_cmd(char* buf){
	int i;
	for(i=0;i <1024;i++){
f01072d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01072dc:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f01072e3:	7e e8                	jle    f01072cd <get_cmd+0x14>
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
f01072e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01072ec:	eb 2f                	jmp    f010731d <get_cmd+0x64>
		int j;
		for(j=0;j<1024;j++){
f01072ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01072f5:	eb 19                	jmp    f0107310 <get_cmd+0x57>
			args[i][j] = '\0';
f01072f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01072fa:	c1 e0 0a             	shl    $0xa,%eax
f01072fd:	89 c2                	mov    %eax,%edx
f01072ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107302:	01 d0                	add    %edx,%eax
f0107304:	05 e0 4e 29 f0       	add    $0xf0294ee0,%eax
f0107309:	c6 00 00             	movb   $0x0,(%eax)
	for(i=0;i <1024;i++){
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
		int j;
		for(j=0;j<1024;j++){
f010730c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0107310:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0107317:	7e de                	jle    f01072f7 <get_cmd+0x3e>
void get_cmd(char* buf){
	int i;
	for(i=0;i <1024;i++){
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
f0107319:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010731d:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
f0107321:	7e cb                	jle    f01072ee <get_cmd+0x35>
		int j;
		for(j=0;j<1024;j++){
			args[i][j] = '\0';
		}
	}
	char* w_pos = strchr(buf, ' ');
f0107323:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f010732a:	00 
f010732b:	8b 45 08             	mov    0x8(%ebp),%eax
f010732e:	89 04 24             	mov    %eax,(%esp)
f0107331:	e8 6e 16 00 00       	call   f01089a4 <strchr>
f0107336:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// cprintf("hddddddddddddhdhh\n");
	char bufcpy[1024] = {0};
f0107339:	8d 9d e0 fb ff ff    	lea    -0x420(%ebp),%ebx
f010733f:	b8 00 00 00 00       	mov    $0x0,%eax
f0107344:	ba 00 01 00 00       	mov    $0x100,%edx
f0107349:	89 df                	mov    %ebx,%edi
f010734b:	89 d1                	mov    %edx,%ecx
f010734d:	f3 ab                	rep stos %eax,%es:(%edi)
	strcpy(bufcpy,buf);
f010734f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107352:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107356:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
f010735c:	89 04 24             	mov    %eax,(%esp)
f010735f:	e8 b5 14 00 00       	call   f0108819 <strcpy>
	if(w_pos == NULL){
f0107364:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0107368:	75 38                	jne    f01073a2 <get_cmd+0xe9>
		for(i=0;i<strlen(buf);i++){
f010736a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0107371:	eb 1a                	jmp    f010738d <get_cmd+0xd4>
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
f0107373:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107376:	8b 45 08             	mov    0x8(%ebp),%eax
f0107379:	01 d0                	add    %edx,%eax
f010737b:	0f b6 00             	movzbl (%eax),%eax
f010737e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107381:	81 c2 e0 4a 29 f0    	add    $0xf0294ae0,%edx
f0107387:	88 02                	mov    %al,(%edx)
	char* w_pos = strchr(buf, ' ');
	// cprintf("hddddddddddddhdhh\n");
	char bufcpy[1024] = {0};
	strcpy(bufcpy,buf);
	if(w_pos == NULL){
		for(i=0;i<strlen(buf);i++){
f0107389:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010738d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107390:	89 04 24             	mov    %eax,(%esp)
f0107393:	e8 2b 14 00 00       	call   f01087c3 <strlen>
f0107398:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010739b:	7f d6                	jg     f0107373 <get_cmd+0xba>
f010739d:	e9 72 01 00 00       	jmp    f0107514 <get_cmd+0x25b>
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
		}
		return;
	}
	for(i=0;i<(w_pos-buf);i++){
f01073a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01073a9:	eb 1a                	jmp    f01073c5 <get_cmd+0x10c>
		// cprintf("heelo2: %s\n", buf[i]);
		cmd[i] = buf[i];
f01073ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01073ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01073b1:	01 d0                	add    %edx,%eax
f01073b3:	0f b6 00             	movzbl (%eax),%eax
f01073b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01073b9:	81 c2 e0 4a 29 f0    	add    $0xf0294ae0,%edx
f01073bf:	88 02                	mov    %al,(%edx)
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
		}
		return;
	}
	for(i=0;i<(w_pos-buf);i++){
f01073c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01073c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01073c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01073cb:	29 c2                	sub    %eax,%edx
f01073cd:	89 d0                	mov    %edx,%eax
f01073cf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01073d2:	7f d7                	jg     f01073ab <get_cmd+0xf2>
		// cprintf("heelo2: %s\n", buf[i]);
		cmd[i] = buf[i];
	}
	if(w_pos-buf < strlen(buf)){
f01073d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01073d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01073da:	89 d3                	mov    %edx,%ebx
f01073dc:	29 c3                	sub    %eax,%ebx
f01073de:	8b 45 08             	mov    0x8(%ebp),%eax
f01073e1:	89 04 24             	mov    %eax,(%esp)
f01073e4:	e8 da 13 00 00       	call   f01087c3 <strlen>
f01073e9:	39 c3                	cmp    %eax,%ebx
f01073eb:	0f 8d 23 01 00 00    	jge    f0107514 <get_cmd+0x25b>
		int is_quote = 0;
f01073f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		int index = 0;
f01073f8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		// int done = 0;
		int curr = 0;
f01073ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		for(i = 0;i<strlen(buf)-(w_pos-buf)-1;i++){
f0107406:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010740d:	e9 b0 00 00 00       	jmp    f01074c2 <get_cmd+0x209>
			// cprintf("args[0]: %s\n", args[0]);
			if(is_quote == 0 && w_pos[i+1] == ' '){
f0107412:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0107416:	75 3b                	jne    f0107453 <get_cmd+0x19a>
f0107418:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010741b:	8d 50 01             	lea    0x1(%eax),%edx
f010741e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107421:	01 d0                	add    %edx,%eax
f0107423:	0f b6 00             	movzbl (%eax),%eax
f0107426:	3c 20                	cmp    $0x20,%al
f0107428:	75 29                	jne    f0107453 <get_cmd+0x19a>
				while(w_pos[i+1] == ' ') i++;
f010742a:	eb 04                	jmp    f0107430 <get_cmd+0x177>
f010742c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0107430:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107433:	8d 50 01             	lea    0x1(%eax),%edx
f0107436:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107439:	01 d0                	add    %edx,%eax
f010743b:	0f b6 00             	movzbl (%eax),%eax
f010743e:	3c 20                	cmp    $0x20,%al
f0107440:	74 ea                	je     f010742c <get_cmd+0x173>
				i--;
f0107442:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
				index += 1;
f0107446:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
				// done = i+1;
				curr = 0;
f010744a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0107451:	eb 6b                	jmp    f01074be <get_cmd+0x205>
			}
			else if(is_quote == 1 && w_pos[i+1] == '\"') {
f0107453:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
f0107457:	75 1b                	jne    f0107474 <get_cmd+0x1bb>
f0107459:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010745c:	8d 50 01             	lea    0x1(%eax),%edx
f010745f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107462:	01 d0                	add    %edx,%eax
f0107464:	0f b6 00             	movzbl (%eax),%eax
f0107467:	3c 22                	cmp    $0x22,%al
f0107469:	75 09                	jne    f0107474 <get_cmd+0x1bb>
				is_quote = 0;
f010746b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0107472:	eb 4a                	jmp    f01074be <get_cmd+0x205>
			}
			else if(is_quote == 0 && w_pos[i+1] == '\"'){
f0107474:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0107478:	75 1b                	jne    f0107495 <get_cmd+0x1dc>
f010747a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010747d:	8d 50 01             	lea    0x1(%eax),%edx
f0107480:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107483:	01 d0                	add    %edx,%eax
f0107485:	0f b6 00             	movzbl (%eax),%eax
f0107488:	3c 22                	cmp    $0x22,%al
f010748a:	75 09                	jne    f0107495 <get_cmd+0x1dc>
				is_quote = 1;
f010748c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0107493:	eb 29                	jmp    f01074be <get_cmd+0x205>
			}
			else{
				args[index][curr] = w_pos[1+i];
f0107495:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107498:	83 c0 01             	add    $0x1,%eax
f010749b:	89 c2                	mov    %eax,%edx
f010749d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01074a0:	01 d0                	add    %edx,%eax
f01074a2:	0f b6 00             	movzbl (%eax),%eax
f01074a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01074a8:	89 d1                	mov    %edx,%ecx
f01074aa:	c1 e1 0a             	shl    $0xa,%ecx
f01074ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01074b0:	01 ca                	add    %ecx,%edx
f01074b2:	81 c2 e0 4e 29 f0    	add    $0xf0294ee0,%edx
f01074b8:	88 02                	mov    %al,(%edx)
				curr++;
f01074ba:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
	if(w_pos-buf < strlen(buf)){
		int is_quote = 0;
		int index = 0;
		// int done = 0;
		int curr = 0;
		for(i = 0;i<strlen(buf)-(w_pos-buf)-1;i++){
f01074be:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01074c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01074c5:	89 04 24             	mov    %eax,(%esp)
f01074c8:	e8 f6 12 00 00       	call   f01087c3 <strlen>
f01074cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01074d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01074d3:	29 d1                	sub    %edx,%ecx
f01074d5:	89 ca                	mov    %ecx,%edx
f01074d7:	01 d0                	add    %edx,%eax
f01074d9:	83 e8 01             	sub    $0x1,%eax
f01074dc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01074df:	0f 8f 2d ff ff ff    	jg     f0107412 <get_cmd+0x159>
				args[index][curr] = w_pos[1+i];
				curr++;
				// cprintf("index: %d, args[1]: %c, i-done: %s\n", index, w_pos[i+1], args[index]);
			}
		}
		if(strcmp(args[index],"&")==0){
f01074e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01074e8:	c1 e0 0a             	shl    $0xa,%eax
f01074eb:	05 e0 4e 29 f0       	add    $0xf0294ee0,%eax
f01074f0:	c7 44 24 04 a8 b3 10 	movl   $0xf010b3a8,0x4(%esp)
f01074f7:	f0 
f01074f8:	89 04 24             	mov    %eax,(%esp)
f01074fb:	e8 0f 14 00 00       	call   f010890f <strcmp>
f0107500:	85 c0                	test   %eax,%eax
f0107502:	75 10                	jne    f0107514 <get_cmd+0x25b>
			args[index][0] = '\0';
f0107504:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107507:	c1 e0 0a             	shl    $0xa,%eax
f010750a:	05 e0 4e 29 f0       	add    $0xf0294ee0,%eax
f010750f:	c6 00 00             	movb   $0x0,(%eax)
f0107512:	eb 00                	jmp    f0107514 <get_cmd+0x25b>
		}
	}
	// cprintf("buffer: %s, command: %s, arguement: %s\n", buf, cmd, args[0]);
}
f0107514:	81 c4 30 04 00 00    	add    $0x430,%esp
f010751a:	5b                   	pop    %ebx
f010751b:	5f                   	pop    %edi
f010751c:	5d                   	pop    %ebp
f010751d:	c3                   	ret    

f010751e <sys_exec>:


void sys_exec(char* buf){
f010751e:	55                   	push   %ebp
f010751f:	89 e5                	mov    %esp,%ebp
f0107521:	56                   	push   %esi
f0107522:	53                   	push   %ebx
f0107523:	81 ec 70 28 00 00    	sub    $0x2870,%esp
	uint32_t parent_id = curenv->env_parent_id;
f0107529:	e8 a0 1f 00 00       	call   f01094ce <cpunum>
f010752e:	6b c0 74             	imul   $0x74,%eax,%eax
f0107531:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107536:	8b 00                	mov    (%eax),%eax
f0107538:	8b 40 4c             	mov    0x4c(%eax),%eax
f010753b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t cur_id = curenv->env_id;
f010753e:	e8 8b 1f 00 00       	call   f01094ce <cpunum>
f0107543:	6b c0 74             	imul   $0x74,%eax,%eax
f0107546:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010754b:	8b 00                	mov    (%eax),%eax
f010754d:	8b 40 48             	mov    0x48(%eax),%eax
f0107550:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// char* bufcpy = "";
	// int code;
	// memcpy(bufcpy, buf, strlen(buf));
	get_cmd(buf);
f0107553:	8b 45 08             	mov    0x8(%ebp),%eax
f0107556:	89 04 24             	mov    %eax,(%esp)
f0107559:	e8 5b fd ff ff       	call   f01072b9 <get_cmd>
	env_free(curenv);
f010755e:	e8 6b 1f 00 00       	call   f01094ce <cpunum>
f0107563:	6b c0 74             	imul   $0x74,%eax,%eax
f0107566:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010756b:	8b 00                	mov    (%eax),%eax
f010756d:	89 04 24             	mov    %eax,(%esp)
f0107570:	e8 ec d3 ff ff       	call   f0104961 <env_free>
	env_alloc(&curenv, parent_id);
f0107575:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0107578:	e8 51 1f 00 00       	call   f01094ce <cpunum>
f010757d:	6b c0 74             	imul   $0x74,%eax,%eax
f0107580:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0107585:	83 c0 08             	add    $0x8,%eax
f0107588:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010758c:	89 04 24             	mov    %eax,(%esp)
f010758f:	e8 05 d0 ff ff       	call   f0104599 <env_alloc>
	curenv->env_id = cur_id;
f0107594:	e8 35 1f 00 00       	call   f01094ce <cpunum>
f0107599:	6b c0 74             	imul   $0x74,%eax,%eax
f010759c:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01075a1:	8b 00                	mov    (%eax),%eax
f01075a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01075a6:	89 50 48             	mov    %edx,0x48(%eax)
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
f01075a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01075b0:	eb 48                	jmp    f01075fa <sys_exec+0xdc>
		int j;
		for(j=0;j<1024;j++){
f01075b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01075b9:	eb 32                	jmp    f01075ed <sys_exec+0xcf>
			argv[i][j] = args[i][j];
f01075bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01075be:	c1 e0 0a             	shl    $0xa,%eax
f01075c1:	89 c2                	mov    %eax,%edx
f01075c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01075c6:	01 d0                	add    %edx,%eax
f01075c8:	05 e0 4e 29 f0       	add    $0xf0294ee0,%eax
f01075cd:	0f b6 00             	movzbl (%eax),%eax
f01075d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01075d3:	c1 e2 0a             	shl    $0xa,%edx
f01075d6:	8d 75 f8             	lea    -0x8(%ebp),%esi
f01075d9:	8d 0c 16             	lea    (%esi,%edx,1),%ecx
f01075dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01075df:	01 ca                	add    %ecx,%edx
f01075e1:	81 ea 20 28 00 00    	sub    $0x2820,%edx
f01075e7:	88 02                	mov    %al,(%edx)
	curenv->env_id = cur_id;
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
		int j;
		for(j=0;j<1024;j++){
f01075e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f01075ed:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f01075f4:	7e c5                	jle    f01075bb <sys_exec+0x9d>
	env_free(curenv);
	env_alloc(&curenv, parent_id);
	curenv->env_id = cur_id;
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
f01075f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01075fa:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
f01075fe:	7e b2                	jle    f01075b2 <sys_exec+0x94>
		for(j=0;j<1024;j++){
			argv[i][j] = args[i][j];
		}
	}
	// cprintf("\n\ncommand: %s, args[0]: %s, args[1]: %s\n\n",cmd, args[0], args[1]);
	if(strcmp(cmd, (const char*)("factorial")) == 0){
f0107600:	c7 44 24 04 aa b3 10 	movl   $0xf010b3aa,0x4(%esp)
f0107607:	f0 
f0107608:	c7 04 24 e0 4a 29 f0 	movl   $0xf0294ae0,(%esp)
f010760f:	e8 fb 12 00 00       	call   f010890f <strcmp>
f0107614:	85 c0                	test   %eax,%eax
f0107616:	75 24                	jne    f010763c <sys_exec+0x11e>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_factorial , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_factorial , _start));
f0107618:	e8 b1 1e 00 00       	call   f01094ce <cpunum>
f010761d:	6b c0 74             	imul   $0x74,%eax,%eax
f0107620:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107625:	8b 00                	mov    (%eax),%eax
f0107627:	c7 44 24 04 ee 20 1a 	movl   $0xf01a20ee,0x4(%esp)
f010762e:	f0 
f010762f:	89 04 24             	mov    %eax,(%esp)
f0107632:	e8 36 d1 ff ff       	call   f010476d <load_icode>
f0107637:	e9 06 01 00 00       	jmp    f0107742 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("fibonacci")) == 0) {
f010763c:	c7 44 24 04 b4 b3 10 	movl   $0xf010b3b4,0x4(%esp)
f0107643:	f0 
f0107644:	c7 04 24 e0 4a 29 f0 	movl   $0xf0294ae0,(%esp)
f010764b:	e8 bf 12 00 00       	call   f010890f <strcmp>
f0107650:	85 c0                	test   %eax,%eax
f0107652:	75 24                	jne    f0107678 <sys_exec+0x15a>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_fibonacci , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_fibonacci , _start));
f0107654:	e8 75 1e 00 00       	call   f01094ce <cpunum>
f0107659:	6b c0 74             	imul   $0x74,%eax,%eax
f010765c:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107661:	8b 00                	mov    (%eax),%eax
f0107663:	c7 44 24 04 d2 aa 1a 	movl   $0xf01aaad2,0x4(%esp)
f010766a:	f0 
f010766b:	89 04 24             	mov    %eax,(%esp)
f010766e:	e8 fa d0 ff ff       	call   f010476d <load_icode>
f0107673:	e9 ca 00 00 00       	jmp    f0107742 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("help")) == 0) {
f0107678:	c7 44 24 04 be b3 10 	movl   $0xf010b3be,0x4(%esp)
f010767f:	f0 
f0107680:	c7 04 24 e0 4a 29 f0 	movl   $0xf0294ae0,(%esp)
f0107687:	e8 83 12 00 00       	call   f010890f <strcmp>
f010768c:	85 c0                	test   %eax,%eax
f010768e:	75 24                	jne    f01076b4 <sys_exec+0x196>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_help , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_help , _start));
f0107690:	e8 39 1e 00 00       	call   f01094ce <cpunum>
f0107695:	6b c0 74             	imul   $0x74,%eax,%eax
f0107698:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010769d:	8b 00                	mov    (%eax),%eax
f010769f:	c7 44 24 04 e6 be 1b 	movl   $0xf01bbee6,0x4(%esp)
f01076a6:	f0 
f01076a7:	89 04 24             	mov    %eax,(%esp)
f01076aa:	e8 be d0 ff ff       	call   f010476d <load_icode>
f01076af:	e9 8e 00 00 00       	jmp    f0107742 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("date")) == 0) {
f01076b4:	c7 44 24 04 c3 b3 10 	movl   $0xf010b3c3,0x4(%esp)
f01076bb:	f0 
f01076bc:	c7 04 24 e0 4a 29 f0 	movl   $0xf0294ae0,(%esp)
f01076c3:	e8 47 12 00 00       	call   f010890f <strcmp>
f01076c8:	85 c0                	test   %eax,%eax
f01076ca:	75 21                	jne    f01076ed <sys_exec+0x1cf>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_date , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_date , _start));
f01076cc:	e8 fd 1d 00 00       	call   f01094ce <cpunum>
f01076d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01076d4:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01076d9:	8b 00                	mov    (%eax),%eax
f01076db:	c7 44 24 04 b6 34 1b 	movl   $0xf01b34b6,0x4(%esp)
f01076e2:	f0 
f01076e3:	89 04 24             	mov    %eax,(%esp)
f01076e6:	e8 82 d0 ff ff       	call   f010476d <load_icode>
f01076eb:	eb 55                	jmp    f0107742 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("echo")) == 0) {
f01076ed:	c7 44 24 04 c8 b3 10 	movl   $0xf010b3c8,0x4(%esp)
f01076f4:	f0 
f01076f5:	c7 04 24 e0 4a 29 f0 	movl   $0xf0294ae0,(%esp)
f01076fc:	e8 0e 12 00 00       	call   f010890f <strcmp>
f0107701:	85 c0                	test   %eax,%eax
f0107703:	75 21                	jne    f0107726 <sys_exec+0x208>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_echo , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_echo , _start));
f0107705:	e8 c4 1d 00 00       	call   f01094ce <cpunum>
f010770a:	6b c0 74             	imul   $0x74,%eax,%eax
f010770d:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107712:	8b 00                	mov    (%eax),%eax
f0107714:	c7 44 24 04 ab 48 1c 	movl   $0xf01c48ab,0x4(%esp)
f010771b:	f0 
f010771c:	89 04 24             	mov    %eax,(%esp)
f010771f:	e8 49 d0 ff ff       	call   f010476d <load_icode>
f0107724:	eb 1c                	jmp    f0107742 <sys_exec+0x224>
	}
	else{
		panic("command not supported");
f0107726:	c7 44 24 08 cd b3 10 	movl   $0xf010b3cd,0x8(%esp)
f010772d:	f0 
f010772e:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0107735:	00 
f0107736:	c7 04 24 e3 b3 10 f0 	movl   $0xf010b3e3,(%esp)
f010773d:	e8 8d 8b ff ff       	call   f01002cf <_panic>
		return;
	}
	// extern uint8_t ENV_PASTE3(_binary_obj_, user_hello , _start)[];
	// load_icode(curenv,ENV_PASTE3(_binary_obj_, user_hello , _start));
	lcr3(PADDR(curenv->env_pgdir));
f0107742:	e8 87 1d 00 00       	call   f01094ce <cpunum>
f0107747:	6b c0 74             	imul   $0x74,%eax,%eax
f010774a:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010774f:	8b 00                	mov    (%eax),%eax
f0107751:	8b 40 60             	mov    0x60(%eax),%eax
f0107754:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107758:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f010775f:	00 
f0107760:	c7 04 24 e3 b3 10 f0 	movl   $0xf010b3e3,(%esp)
f0107767:	e8 c4 f3 ff ff       	call   f0106b30 <_paddr>
f010776c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010776f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107772:	0f 22 d8             	mov    %eax,%cr3
	int argc = 0;
f0107775:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	uint32_t sp = USTACKTOP;
f010777c:	c7 45 e8 00 e0 bf ee 	movl   $0xeebfe000,-0x18(%ebp)
	uint32_t ustack[13];
	for(argc = 0; strlen(argv[argc]) > 0; argc++) {
f0107783:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f010778a:	e9 98 00 00 00       	jmp    f0107827 <sys_exec+0x309>
	    if(argc >= 10) panic("argc>=10");
f010778f:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
f0107793:	7e 1c                	jle    f01077b1 <sys_exec+0x293>
f0107795:	c7 44 24 08 f2 b3 10 	movl   $0xf010b3f2,0x8(%esp)
f010779c:	f0 
f010779d:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f01077a4:	00 
f01077a5:	c7 04 24 e3 b3 10 f0 	movl   $0xf010b3e3,(%esp)
f01077ac:	e8 1e 8b ff ff       	call   f01002cf <_panic>
	    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
f01077b1:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f01077b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01077ba:	c1 e2 0a             	shl    $0xa,%edx
f01077bd:	01 d0                	add    %edx,%eax
f01077bf:	89 04 24             	mov    %eax,(%esp)
f01077c2:	e8 fc 0f 00 00       	call   f01087c3 <strlen>
f01077c7:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01077ca:	29 c2                	sub    %eax,%edx
f01077cc:	89 d0                	mov    %edx,%eax
f01077ce:	83 e8 01             	sub    $0x1,%eax
f01077d1:	83 e0 fc             	and    $0xfffffffc,%eax
f01077d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    memcpy((void *)sp, argv[argc], strlen(argv[argc]) + 1);
f01077d7:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f01077dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01077e0:	c1 e2 0a             	shl    $0xa,%edx
f01077e3:	01 d0                	add    %edx,%eax
f01077e5:	89 04 24             	mov    %eax,(%esp)
f01077e8:	e8 d6 0f 00 00       	call   f01087c3 <strlen>
f01077ed:	83 c0 01             	add    $0x1,%eax
f01077f0:	89 c2                	mov    %eax,%edx
f01077f2:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f01077f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01077fb:	c1 e1 0a             	shl    $0xa,%ecx
f01077fe:	01 c1                	add    %eax,%ecx
f0107800:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107803:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107807:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010780b:	89 04 24             	mov    %eax,(%esp)
f010780e:	e8 3a 13 00 00       	call   f0108b4d <memcpy>
	    ustack[2+argc] = sp;
f0107813:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107816:	8d 50 02             	lea    0x2(%eax),%edx
f0107819:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010781c:	89 84 95 a4 d7 ff ff 	mov    %eax,-0x285c(%ebp,%edx,4)
	// load_icode(curenv,ENV_PASTE3(_binary_obj_, user_hello , _start));
	lcr3(PADDR(curenv->env_pgdir));
	int argc = 0;
	uint32_t sp = USTACKTOP;
	uint32_t ustack[13];
	for(argc = 0; strlen(argv[argc]) > 0; argc++) {
f0107823:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f0107827:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f010782d:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0107830:	c1 e2 0a             	shl    $0xa,%edx
f0107833:	01 d0                	add    %edx,%eax
f0107835:	89 04 24             	mov    %eax,(%esp)
f0107838:	e8 86 0f 00 00       	call   f01087c3 <strlen>
f010783d:	85 c0                	test   %eax,%eax
f010783f:	0f 8f 4a ff ff ff    	jg     f010778f <sys_exec+0x271>
	    if(argc >= 10) panic("argc>=10");
	    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
	    memcpy((void *)sp, argv[argc], strlen(argv[argc]) + 1);
	    ustack[2+argc] = sp;
	  }
	  ustack[2+argc] = 0;
f0107845:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107848:	83 c0 02             	add    $0x2,%eax
f010784b:	c7 84 85 a4 d7 ff ff 	movl   $0x0,-0x285c(%ebp,%eax,4)
f0107852:	00 00 00 00 

	  // ustack[0] = 0xffffffff;  // fake return PC
	  // cprintf("argc ppushed: %d\n", argc);
	  ustack[0] = argc;
f0107856:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107859:	89 85 a4 d7 ff ff    	mov    %eax,-0x285c(%ebp)
	  ustack[1] = sp - (argc+1)*4;  // argv pointer
f010785f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107862:	f7 d0                	not    %eax
f0107864:	c1 e0 02             	shl    $0x2,%eax
f0107867:	89 c2                	mov    %eax,%edx
f0107869:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010786c:	01 d0                	add    %edx,%eax
f010786e:	89 85 a8 d7 ff ff    	mov    %eax,-0x2858(%ebp)

	  sp -= (2+argc+1) * 4;
f0107874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107879:	2b 45 ec             	sub    -0x14(%ebp),%eax
f010787c:	c1 e0 02             	shl    $0x2,%eax
f010787f:	01 45 e8             	add    %eax,-0x18(%ebp)
	  memcpy((void *)sp, ustack, (2+argc+1)*4);
f0107882:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107885:	83 c0 03             	add    $0x3,%eax
f0107888:	c1 e0 02             	shl    $0x2,%eax
f010788b:	89 c2                	mov    %eax,%edx
f010788d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107890:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107894:	8d 95 a4 d7 ff ff    	lea    -0x285c(%ebp),%edx
f010789a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010789e:	89 04 24             	mov    %eax,(%esp)
f01078a1:	e8 a7 12 00 00       	call   f0108b4d <memcpy>
	  curenv->env_tf.tf_esp = sp;
f01078a6:	e8 23 1c 00 00       	call   f01094ce <cpunum>
f01078ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01078ae:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01078b3:	8b 00                	mov    (%eax),%eax
f01078b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01078b8:	89 50 3c             	mov    %edx,0x3c(%eax)
	lcr3(PADDR(kern_pgdir));
f01078bb:	a1 ec 7a 29 f0       	mov    0xf0297aec,%eax
f01078c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01078c4:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
f01078cb:	00 
f01078cc:	c7 04 24 e3 b3 10 f0 	movl   $0xf010b3e3,(%esp)
f01078d3:	e8 58 f2 ff ff       	call   f0106b30 <_paddr>
f01078d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01078db:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01078de:	0f 22 d8             	mov    %eax,%cr3
	env_run(curenv);
f01078e1:	e8 e8 1b 00 00       	call   f01094ce <cpunum>
f01078e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01078e9:	05 28 80 29 f0       	add    $0xf0298028,%eax
f01078ee:	8b 00                	mov    (%eax),%eax
f01078f0:	89 04 24             	mov    %eax,(%esp)
f01078f3:	e8 cf d2 ff ff       	call   f0104bc7 <env_run>

f01078f8 <sys_wait>:
	// sched_yield();
	// cprintf("\n\nheeeeeeeeeeelo---------------\n\n");
	// env_destroy(e);
}

void sys_wait(){
f01078f8:	55                   	push   %ebp
f01078f9:	89 e5                	mov    %esp,%ebp
f01078fb:	83 ec 08             	sub    $0x8,%esp
	curenv->env_status = ENV_WAIT_CHILD;
f01078fe:	e8 cb 1b 00 00       	call   f01094ce <cpunum>
f0107903:	6b c0 74             	imul   $0x74,%eax,%eax
f0107906:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010790b:	8b 00                	mov    (%eax),%eax
f010790d:	c7 40 54 05 00 00 00 	movl   $0x5,0x54(%eax)
}
f0107914:	c9                   	leave  
f0107915:	c3                   	ret    

f0107916 <sys_guest>:

void sys_guest(){
f0107916:	55                   	push   %ebp
f0107917:	89 e5                	mov    %esp,%ebp
f0107919:	83 ec 18             	sub    $0x18,%esp
	curenv->env_type = ENV_TYPE_GUEST;
f010791c:	e8 ad 1b 00 00       	call   f01094ce <cpunum>
f0107921:	6b c0 74             	imul   $0x74,%eax,%eax
f0107924:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107929:	8b 00                	mov    (%eax),%eax
f010792b:	c7 40 50 01 00 00 00 	movl   $0x1,0x50(%eax)
	extern uint8_t ENV_PASTE3(_binary_obj_, guest_boot , _start)[];
	load_icode(curenv,ENV_PASTE3(_binary_obj_, guest_boot , _start));
f0107932:	e8 97 1b 00 00       	call   f01094ce <cpunum>
f0107937:	6b c0 74             	imul   $0x74,%eax,%eax
f010793a:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010793f:	8b 00                	mov    (%eax),%eax
f0107941:	c7 44 24 04 2d 28 29 	movl   $0xf029282d,0x4(%esp)
f0107948:	f0 
f0107949:	89 04 24             	mov    %eax,(%esp)
f010794c:	e8 1c ce ff ff       	call   f010476d <load_icode>
	curenv->env_tf.tf_eip = 0x7c00;
f0107951:	e8 78 1b 00 00       	call   f01094ce <cpunum>
f0107956:	6b c0 74             	imul   $0x74,%eax,%eax
f0107959:	05 28 80 29 f0       	add    $0xf0298028,%eax
f010795e:	8b 00                	mov    (%eax),%eax
f0107960:	c7 40 30 00 7c 00 00 	movl   $0x7c00,0x30(%eax)
	curenv->env_tf.tf_esp = 0;
f0107967:	e8 62 1b 00 00       	call   f01094ce <cpunum>
f010796c:	6b c0 74             	imul   $0x74,%eax,%eax
f010796f:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107974:	8b 00                	mov    (%eax),%eax
f0107976:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
f010797d:	c9                   	leave  
f010797e:	c3                   	ret    

f010797f <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010797f:	55                   	push   %ebp
f0107980:	89 e5                	mov    %esp,%ebp
f0107982:	56                   	push   %esi
f0107983:	53                   	push   %ebx
f0107984:	83 ec 20             	sub    $0x20,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0107987:	83 7d 08 0f          	cmpl   $0xf,0x8(%ebp)
f010798b:	0f 87 4a 01 00 00    	ja     f0107adb <syscall+0x15c>
f0107991:	8b 45 08             	mov    0x8(%ebp),%eax
f0107994:	c1 e0 02             	shl    $0x2,%eax
f0107997:	05 fc b3 10 f0       	add    $0xf010b3fc,%eax
f010799c:	8b 00                	mov    (%eax),%eax
f010799e:	ff e0                	jmp    *%eax
		case SYS_cputs:
			sys_cputs((char *)a1,a2);
f01079a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079a3:	8b 55 10             	mov    0x10(%ebp),%edx
f01079a6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01079aa:	89 04 24             	mov    %eax,(%esp)
f01079ad:	e8 b9 f1 ff ff       	call   f0106b6b <sys_cputs>
			return 0;
f01079b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01079b7:	e9 24 01 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_cgetc:
			return sys_cgetc();
f01079bc:	e8 f9 f1 ff ff       	call   f0106bba <sys_cgetc>
f01079c1:	e9 1a 01 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_getenvid:
			return sys_getenvid();
f01079c6:	e8 fc f1 ff ff       	call   f0106bc7 <sys_getenvid>
f01079cb:	e9 10 01 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f01079d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079d3:	89 04 24             	mov    %eax,(%esp)
f01079d6:	e8 06 f2 ff ff       	call   f0106be1 <sys_env_destroy>
f01079db:	e9 00 01 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_yield:
			sys_yield();
f01079e0:	e8 a7 f2 ff ff       	call   f0106c8c <sys_yield>
			return 0;
f01079e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01079ea:	e9 f1 00 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_exofork:
			return sys_exofork();
f01079ef:	e8 a3 f2 ff ff       	call   f0106c97 <sys_exofork>
f01079f4:	e9 e7 00 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f01079f9:	8b 55 10             	mov    0x10(%ebp),%edx
f01079fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079ff:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a03:	89 04 24             	mov    %eax,(%esp)
f0107a06:	e8 09 f3 ff ff       	call   f0106d14 <sys_env_set_status>
f0107a0b:	e9 d0 00 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void *)a2,(int)a3);
f0107a10:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0107a13:	8b 55 10             	mov    0x10(%ebp),%edx
f0107a16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107a1d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a21:	89 04 24             	mov    %eax,(%esp)
f0107a24:	e8 7a f3 ff ff       	call   f0106da3 <sys_page_alloc>
f0107a29:	e9 b2 00 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void *)a2,(envid_t)a3,(void *)a4,(int)a5);
f0107a2e:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0107a31:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0107a34:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0107a37:	8b 55 10             	mov    0x10(%ebp),%edx
f0107a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a3d:	89 74 24 10          	mov    %esi,0x10(%esp)
f0107a41:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107a45:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107a49:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a4d:	89 04 24             	mov    %eax,(%esp)
f0107a50:	e8 3b f4 ff ff       	call   f0106e90 <sys_page_map>
f0107a55:	e9 86 00 00 00       	jmp    f0107ae0 <syscall+0x161>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void *)a2);
f0107a5a:	8b 55 10             	mov    0x10(%ebp),%edx
f0107a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a60:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a64:	89 04 24             	mov    %eax,(%esp)
f0107a67:	e8 9b f5 ff ff       	call   f0107007 <sys_page_unmap>
f0107a6c:	eb 72                	jmp    f0107ae0 <syscall+0x161>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0107a6e:	8b 55 10             	mov    0x10(%ebp),%edx
f0107a71:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a74:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a78:	89 04 24             	mov    %eax,(%esp)
f0107a7b:	e8 e5 f2 ff ff       	call   f0106d65 <sys_env_set_pgfault_upcall>
f0107a80:	eb 5e                	jmp    f0107ae0 <syscall+0x161>
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0107a82:	8b 55 14             	mov    0x14(%ebp),%edx
f0107a85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a88:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0107a8b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0107a8f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107a93:	8b 55 10             	mov    0x10(%ebp),%edx
f0107a96:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a9a:	89 04 24             	mov    %eax,(%esp)
f0107a9d:	e8 ee f5 ff ff       	call   f0107090 <sys_ipc_try_send>
f0107aa2:	eb 3c                	jmp    f0107ae0 <syscall+0x161>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0107aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107aa7:	89 04 24             	mov    %eax,(%esp)
f0107aaa:	e8 7e f7 ff ff       	call   f010722d <sys_ipc_recv>
f0107aaf:	eb 2f                	jmp    f0107ae0 <syscall+0x161>
		case SYS_exec:
			sys_exec((char *)a1);
f0107ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ab4:	89 04 24             	mov    %eax,(%esp)
f0107ab7:	e8 62 fa ff ff       	call   f010751e <sys_exec>
			return 0;
f0107abc:	b8 00 00 00 00       	mov    $0x0,%eax
f0107ac1:	eb 1d                	jmp    f0107ae0 <syscall+0x161>
		case SYS_wait:
			sys_wait();
f0107ac3:	e8 30 fe ff ff       	call   f01078f8 <sys_wait>
			return 0;
f0107ac8:	b8 00 00 00 00       	mov    $0x0,%eax
f0107acd:	eb 11                	jmp    f0107ae0 <syscall+0x161>
		case SYS_guest:
			sys_guest();
f0107acf:	e8 42 fe ff ff       	call   f0107916 <sys_guest>
			return 0;
f0107ad4:	b8 00 00 00 00       	mov    $0x0,%eax
f0107ad9:	eb 05                	jmp    f0107ae0 <syscall+0x161>
		default:
			return -E_INVAL;
f0107adb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0107ae0:	83 c4 20             	add    $0x20,%esp
f0107ae3:	5b                   	pop    %ebx
f0107ae4:	5e                   	pop    %esi
f0107ae5:	5d                   	pop    %ebp
f0107ae6:	c3                   	ret    

f0107ae7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0107ae7:	55                   	push   %ebp
f0107ae8:	89 e5                	mov    %esp,%ebp
f0107aea:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f0107aed:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107af0:	8b 00                	mov    (%eax),%eax
f0107af2:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107af5:	8b 45 10             	mov    0x10(%ebp),%eax
f0107af8:	8b 00                	mov    (%eax),%eax
f0107afa:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0107afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	while (l <= r) {
f0107b04:	e9 d2 00 00 00       	jmp    f0107bdb <stab_binsearch+0xf4>
		int true_m = (l + r) / 2, m = true_m;
f0107b09:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0107b0c:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107b0f:	01 d0                	add    %edx,%eax
f0107b11:	89 c2                	mov    %eax,%edx
f0107b13:	c1 ea 1f             	shr    $0x1f,%edx
f0107b16:	01 d0                	add    %edx,%eax
f0107b18:	d1 f8                	sar    %eax
f0107b1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107b1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107b20:	89 45 f0             	mov    %eax,-0x10(%ebp)

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0107b23:	eb 04                	jmp    f0107b29 <stab_binsearch+0x42>
			m--;
f0107b25:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0107b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107b2c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0107b2f:	7c 1f                	jl     f0107b50 <stab_binsearch+0x69>
f0107b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107b34:	89 d0                	mov    %edx,%eax
f0107b36:	01 c0                	add    %eax,%eax
f0107b38:	01 d0                	add    %edx,%eax
f0107b3a:	c1 e0 02             	shl    $0x2,%eax
f0107b3d:	89 c2                	mov    %eax,%edx
f0107b3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b42:	01 d0                	add    %edx,%eax
f0107b44:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107b48:	0f b6 c0             	movzbl %al,%eax
f0107b4b:	3b 45 14             	cmp    0x14(%ebp),%eax
f0107b4e:	75 d5                	jne    f0107b25 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f0107b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107b53:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0107b56:	7d 0b                	jge    f0107b63 <stab_binsearch+0x7c>
			l = true_m + 1;
f0107b58:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107b5b:	83 c0 01             	add    $0x1,%eax
f0107b5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f0107b61:	eb 78                	jmp    f0107bdb <stab_binsearch+0xf4>
		}

		// actual binary search
		any_matches = 1;
f0107b63:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f0107b6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107b6d:	89 d0                	mov    %edx,%eax
f0107b6f:	01 c0                	add    %eax,%eax
f0107b71:	01 d0                	add    %edx,%eax
f0107b73:	c1 e0 02             	shl    $0x2,%eax
f0107b76:	89 c2                	mov    %eax,%edx
f0107b78:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b7b:	01 d0                	add    %edx,%eax
f0107b7d:	8b 40 08             	mov    0x8(%eax),%eax
f0107b80:	3b 45 18             	cmp    0x18(%ebp),%eax
f0107b83:	73 13                	jae    f0107b98 <stab_binsearch+0xb1>
			*region_left = m;
f0107b85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107b8b:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f0107b8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107b90:	83 c0 01             	add    $0x1,%eax
f0107b93:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107b96:	eb 43                	jmp    f0107bdb <stab_binsearch+0xf4>
		} else if (stabs[m].n_value > addr) {
f0107b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107b9b:	89 d0                	mov    %edx,%eax
f0107b9d:	01 c0                	add    %eax,%eax
f0107b9f:	01 d0                	add    %edx,%eax
f0107ba1:	c1 e0 02             	shl    $0x2,%eax
f0107ba4:	89 c2                	mov    %eax,%edx
f0107ba6:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ba9:	01 d0                	add    %edx,%eax
f0107bab:	8b 40 08             	mov    0x8(%eax),%eax
f0107bae:	3b 45 18             	cmp    0x18(%ebp),%eax
f0107bb1:	76 16                	jbe    f0107bc9 <stab_binsearch+0xe2>
			*region_right = m - 1;
f0107bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107bb6:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107bb9:	8b 45 10             	mov    0x10(%ebp),%eax
f0107bbc:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f0107bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107bc1:	83 e8 01             	sub    $0x1,%eax
f0107bc4:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0107bc7:	eb 12                	jmp    f0107bdb <stab_binsearch+0xf4>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0107bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107bcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107bcf:	89 10                	mov    %edx,(%eax)
			l = m;
f0107bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107bd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f0107bd7:	83 45 18 01          	addl   $0x1,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0107bdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107bde:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0107be1:	0f 8e 22 ff ff ff    	jle    f0107b09 <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0107be7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0107beb:	75 0f                	jne    f0107bfc <stab_binsearch+0x115>
		*region_right = *region_left - 1;
f0107bed:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107bf0:	8b 00                	mov    (%eax),%eax
f0107bf2:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107bf5:	8b 45 10             	mov    0x10(%ebp),%eax
f0107bf8:	89 10                	mov    %edx,(%eax)
f0107bfa:	eb 3f                	jmp    f0107c3b <stab_binsearch+0x154>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0107bfc:	8b 45 10             	mov    0x10(%ebp),%eax
f0107bff:	8b 00                	mov    (%eax),%eax
f0107c01:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107c04:	eb 04                	jmp    f0107c0a <stab_binsearch+0x123>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0107c06:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0107c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c0d:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0107c0f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0107c12:	7d 1f                	jge    f0107c33 <stab_binsearch+0x14c>
		     l > *region_left && stabs[l].n_type != type;
f0107c14:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107c17:	89 d0                	mov    %edx,%eax
f0107c19:	01 c0                	add    %eax,%eax
f0107c1b:	01 d0                	add    %edx,%eax
f0107c1d:	c1 e0 02             	shl    $0x2,%eax
f0107c20:	89 c2                	mov    %eax,%edx
f0107c22:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c25:	01 d0                	add    %edx,%eax
f0107c27:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107c2b:	0f b6 c0             	movzbl %al,%eax
f0107c2e:	3b 45 14             	cmp    0x14(%ebp),%eax
f0107c31:	75 d3                	jne    f0107c06 <stab_binsearch+0x11f>
		     l--)
			/* do nothing */;
		*region_left = l;
f0107c33:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c36:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107c39:	89 10                	mov    %edx,(%eax)
	}
}
f0107c3b:	c9                   	leave  
f0107c3c:	c3                   	ret    

f0107c3d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0107c3d:	55                   	push   %ebp
f0107c3e:	89 e5                	mov    %esp,%ebp
f0107c40:	53                   	push   %ebx
f0107c41:	83 ec 54             	sub    $0x54,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0107c44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c47:	c7 00 3c b4 10 f0    	movl   $0xf010b43c,(%eax)
	info->eip_line = 0;
f0107c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c50:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f0107c57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c5a:	c7 40 08 3c b4 10 f0 	movl   $0xf010b43c,0x8(%eax)
	info->eip_fn_namelen = 9;
f0107c61:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c64:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f0107c6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c6e:	8b 55 08             	mov    0x8(%ebp),%edx
f0107c71:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f0107c74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c77:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0107c7e:	81 7d 08 ff ff 7f ef 	cmpl   $0xef7fffff,0x8(%ebp)
f0107c85:	76 21                	jbe    f0107ca8 <debuginfo_eip+0x6b>
		stabs = __STAB_BEGIN__;
f0107c87:	c7 45 f4 80 b9 10 f0 	movl   $0xf010b980,-0xc(%ebp)
		stab_end = __STAB_END__;
f0107c8e:	c7 45 f0 00 84 11 f0 	movl   $0xf0118400,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0107c95:	c7 45 ec 01 84 11 f0 	movl   $0xf0118401,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f0107c9c:	c7 45 e8 0f c4 11 f0 	movl   $0xf011c40f,-0x18(%ebp)
f0107ca3:	e9 f8 00 00 00       	jmp    f0107da0 <debuginfo_eip+0x163>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f0107ca8:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)USTABDATA, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f0107caf:	e8 1a 18 00 00       	call   f01094ce <cpunum>
f0107cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0107cb7:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107cbc:	8b 00                	mov    (%eax),%eax
f0107cbe:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107cc5:	00 
f0107cc6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0107ccd:	00 
f0107cce:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0107cd5:	00 
f0107cd6:	89 04 24             	mov    %eax,(%esp)
f0107cd9:	e8 4a a0 ff ff       	call   f0101d28 <user_mem_check>
f0107cde:	85 c0                	test   %eax,%eax
f0107ce0:	79 0a                	jns    f0107cec <debuginfo_eip+0xaf>
f0107ce2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107ce7:	e9 93 03 00 00       	jmp    f010807f <debuginfo_eip+0x442>
		stabs = usd->stabs;
f0107cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107cef:	8b 00                	mov    (%eax),%eax
f0107cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f0107cf4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107cf7:	8b 40 04             	mov    0x4(%eax),%eax
f0107cfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f0107cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107d00:	8b 40 08             	mov    0x8(%eax),%eax
f0107d03:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f0107d06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107d09:	8b 40 0c             	mov    0xc(%eax),%eax
f0107d0c:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs, stab_end-stabs, PTE_U) < 0) return -1;
f0107d0f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d15:	29 c2                	sub    %eax,%edx
f0107d17:	89 d0                	mov    %edx,%eax
f0107d19:	c1 f8 02             	sar    $0x2,%eax
f0107d1c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0107d22:	89 c3                	mov    %eax,%ebx
f0107d24:	e8 a5 17 00 00       	call   f01094ce <cpunum>
f0107d29:	6b c0 74             	imul   $0x74,%eax,%eax
f0107d2c:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107d31:	8b 00                	mov    (%eax),%eax
f0107d33:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107d3a:	00 
f0107d3b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107d3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107d42:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107d46:	89 04 24             	mov    %eax,(%esp)
f0107d49:	e8 da 9f ff ff       	call   f0101d28 <user_mem_check>
f0107d4e:	85 c0                	test   %eax,%eax
f0107d50:	79 0a                	jns    f0107d5c <debuginfo_eip+0x11f>
f0107d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107d57:	e9 23 03 00 00       	jmp    f010807f <debuginfo_eip+0x442>
		if(user_mem_check(curenv,stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f0107d5c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107d5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107d62:	29 c2                	sub    %eax,%edx
f0107d64:	89 d0                	mov    %edx,%eax
f0107d66:	89 c3                	mov    %eax,%ebx
f0107d68:	e8 61 17 00 00       	call   f01094ce <cpunum>
f0107d6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0107d70:	05 28 80 29 f0       	add    $0xf0298028,%eax
f0107d75:	8b 00                	mov    (%eax),%eax
f0107d77:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107d7e:	00 
f0107d7f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107d83:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0107d86:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107d8a:	89 04 24             	mov    %eax,(%esp)
f0107d8d:	e8 96 9f ff ff       	call   f0101d28 <user_mem_check>
f0107d92:	85 c0                	test   %eax,%eax
f0107d94:	79 0a                	jns    f0107da0 <debuginfo_eip+0x163>
f0107d96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107d9b:	e9 df 02 00 00       	jmp    f010807f <debuginfo_eip+0x442>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0107da0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107da3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0107da6:	76 0d                	jbe    f0107db5 <debuginfo_eip+0x178>
f0107da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107dab:	83 e8 01             	sub    $0x1,%eax
f0107dae:	0f b6 00             	movzbl (%eax),%eax
f0107db1:	84 c0                	test   %al,%al
f0107db3:	74 0a                	je     f0107dbf <debuginfo_eip+0x182>
		return -1;
f0107db5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107dba:	e9 c0 02 00 00       	jmp    f010807f <debuginfo_eip+0x442>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0107dbf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	rfile = (stab_end - stabs) - 1;
f0107dc6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107dcc:	29 c2                	sub    %eax,%edx
f0107dce:	89 d0                	mov    %edx,%eax
f0107dd0:	c1 f8 02             	sar    $0x2,%eax
f0107dd3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0107dd9:	83 e8 01             	sub    $0x1,%eax
f0107ddc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0107ddf:	8b 45 08             	mov    0x8(%ebp),%eax
f0107de2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107de6:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
f0107ded:	00 
f0107dee:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0107df1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107df5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0107df8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107dff:	89 04 24             	mov    %eax,(%esp)
f0107e02:	e8 e0 fc ff ff       	call   f0107ae7 <stab_binsearch>
	if (lfile == 0)
f0107e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107e0a:	85 c0                	test   %eax,%eax
f0107e0c:	75 0a                	jne    f0107e18 <debuginfo_eip+0x1db>
		return -1;
f0107e0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107e13:	e9 67 02 00 00       	jmp    f010807f <debuginfo_eip+0x442>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0107e18:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107e1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	rfun = rfile;
f0107e1e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107e21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0107e24:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e27:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107e2b:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
f0107e32:	00 
f0107e33:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0107e36:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107e3a:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0107e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e44:	89 04 24             	mov    %eax,(%esp)
f0107e47:	e8 9b fc ff ff       	call   f0107ae7 <stab_binsearch>

	if (lfun <= rfun) {
f0107e4c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107e4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0107e52:	39 c2                	cmp    %eax,%edx
f0107e54:	7f 7c                	jg     f0107ed2 <debuginfo_eip+0x295>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0107e56:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107e59:	89 c2                	mov    %eax,%edx
f0107e5b:	89 d0                	mov    %edx,%eax
f0107e5d:	01 c0                	add    %eax,%eax
f0107e5f:	01 d0                	add    %edx,%eax
f0107e61:	c1 e0 02             	shl    $0x2,%eax
f0107e64:	89 c2                	mov    %eax,%edx
f0107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e69:	01 d0                	add    %edx,%eax
f0107e6b:	8b 10                	mov    (%eax),%edx
f0107e6d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107e73:	29 c1                	sub    %eax,%ecx
f0107e75:	89 c8                	mov    %ecx,%eax
f0107e77:	39 c2                	cmp    %eax,%edx
f0107e79:	73 22                	jae    f0107e9d <debuginfo_eip+0x260>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0107e7b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107e7e:	89 c2                	mov    %eax,%edx
f0107e80:	89 d0                	mov    %edx,%eax
f0107e82:	01 c0                	add    %eax,%eax
f0107e84:	01 d0                	add    %edx,%eax
f0107e86:	c1 e0 02             	shl    $0x2,%eax
f0107e89:	89 c2                	mov    %eax,%edx
f0107e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e8e:	01 d0                	add    %edx,%eax
f0107e90:	8b 10                	mov    (%eax),%edx
f0107e92:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107e95:	01 c2                	add    %eax,%edx
f0107e97:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e9a:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = stabs[lfun].n_value;
f0107e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107ea0:	89 c2                	mov    %eax,%edx
f0107ea2:	89 d0                	mov    %edx,%eax
f0107ea4:	01 c0                	add    %eax,%eax
f0107ea6:	01 d0                	add    %edx,%eax
f0107ea8:	c1 e0 02             	shl    $0x2,%eax
f0107eab:	89 c2                	mov    %eax,%edx
f0107ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107eb0:	01 d0                	add    %edx,%eax
f0107eb2:	8b 50 08             	mov    0x8(%eax),%edx
f0107eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107eb8:	89 50 10             	mov    %edx,0x10(%eax)
		addr -= info->eip_fn_addr;
f0107ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ebe:	8b 40 10             	mov    0x10(%eax),%eax
f0107ec1:	29 45 08             	sub    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0107ec4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107ec7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfun;
f0107eca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0107ecd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0107ed0:	eb 15                	jmp    f0107ee7 <debuginfo_eip+0x2aa>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0107ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ed5:	8b 55 08             	mov    0x8(%ebp),%edx
f0107ed8:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f0107edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107ede:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfile;
f0107ee1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107ee4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0107ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107eea:	8b 40 08             	mov    0x8(%eax),%eax
f0107eed:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0107ef4:	00 
f0107ef5:	89 04 24             	mov    %eax,(%esp)
f0107ef8:	e8 da 0a 00 00       	call   f01089d7 <strfind>
f0107efd:	89 c2                	mov    %eax,%edx
f0107eff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107f02:	8b 40 08             	mov    0x8(%eax),%eax
f0107f05:	29 c2                	sub    %eax,%edx
f0107f07:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107f0a:	89 50 0c             	mov    %edx,0xc(%eax)
	// Your code here.
	// char* fn_name="";
	// strncpy(fn_name,info->eip_fn_name,info->eip_fn_namelen);
	// fn_name[info->eip_fn_namelen] = '\0';
	// info->eip_fn_name = fn_name;
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0107f0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f10:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107f14:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
f0107f1b:	00 
f0107f1c:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0107f1f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107f23:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0107f26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107f2d:	89 04 24             	mov    %eax,(%esp)
f0107f30:	e8 b2 fb ff ff       	call   f0107ae7 <stab_binsearch>
	if(lline <= rline)
f0107f35:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107f38:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0107f3b:	39 c2                	cmp    %eax,%edx
f0107f3d:	7f 24                	jg     f0107f63 <debuginfo_eip+0x326>
		info->eip_line = stabs[rline].n_desc;
f0107f3f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0107f42:	89 c2                	mov    %eax,%edx
f0107f44:	89 d0                	mov    %edx,%eax
f0107f46:	01 c0                	add    %eax,%eax
f0107f48:	01 d0                	add    %edx,%eax
f0107f4a:	c1 e0 02             	shl    $0x2,%eax
f0107f4d:	89 c2                	mov    %eax,%edx
f0107f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107f52:	01 d0                	add    %edx,%eax
f0107f54:	0f b7 40 06          	movzwl 0x6(%eax),%eax
f0107f58:	0f b7 d0             	movzwl %ax,%edx
f0107f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107f5e:	89 50 04             	mov    %edx,0x4(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0107f61:	eb 13                	jmp    f0107f76 <debuginfo_eip+0x339>
	// info->eip_fn_name = fn_name;
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline)
		info->eip_line = stabs[rline].n_desc;
	else
		return -1;
f0107f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107f68:	e9 12 01 00 00       	jmp    f010807f <debuginfo_eip+0x442>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0107f6d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107f70:	83 e8 01             	sub    $0x1,%eax
f0107f73:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0107f76:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107f79:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107f7c:	39 c2                	cmp    %eax,%edx
f0107f7e:	7c 56                	jl     f0107fd6 <debuginfo_eip+0x399>
	       && stabs[lline].n_type != N_SOL
f0107f80:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107f83:	89 c2                	mov    %eax,%edx
f0107f85:	89 d0                	mov    %edx,%eax
f0107f87:	01 c0                	add    %eax,%eax
f0107f89:	01 d0                	add    %edx,%eax
f0107f8b:	c1 e0 02             	shl    $0x2,%eax
f0107f8e:	89 c2                	mov    %eax,%edx
f0107f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107f93:	01 d0                	add    %edx,%eax
f0107f95:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107f99:	3c 84                	cmp    $0x84,%al
f0107f9b:	74 39                	je     f0107fd6 <debuginfo_eip+0x399>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0107f9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107fa0:	89 c2                	mov    %eax,%edx
f0107fa2:	89 d0                	mov    %edx,%eax
f0107fa4:	01 c0                	add    %eax,%eax
f0107fa6:	01 d0                	add    %edx,%eax
f0107fa8:	c1 e0 02             	shl    $0x2,%eax
f0107fab:	89 c2                	mov    %eax,%edx
f0107fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107fb0:	01 d0                	add    %edx,%eax
f0107fb2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107fb6:	3c 64                	cmp    $0x64,%al
f0107fb8:	75 b3                	jne    f0107f6d <debuginfo_eip+0x330>
f0107fba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107fbd:	89 c2                	mov    %eax,%edx
f0107fbf:	89 d0                	mov    %edx,%eax
f0107fc1:	01 c0                	add    %eax,%eax
f0107fc3:	01 d0                	add    %edx,%eax
f0107fc5:	c1 e0 02             	shl    $0x2,%eax
f0107fc8:	89 c2                	mov    %eax,%edx
f0107fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107fcd:	01 d0                	add    %edx,%eax
f0107fcf:	8b 40 08             	mov    0x8(%eax),%eax
f0107fd2:	85 c0                	test   %eax,%eax
f0107fd4:	74 97                	je     f0107f6d <debuginfo_eip+0x330>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0107fd6:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107fd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107fdc:	39 c2                	cmp    %eax,%edx
f0107fde:	7c 46                	jl     f0108026 <debuginfo_eip+0x3e9>
f0107fe0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107fe3:	89 c2                	mov    %eax,%edx
f0107fe5:	89 d0                	mov    %edx,%eax
f0107fe7:	01 c0                	add    %eax,%eax
f0107fe9:	01 d0                	add    %edx,%eax
f0107feb:	c1 e0 02             	shl    $0x2,%eax
f0107fee:	89 c2                	mov    %eax,%edx
f0107ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ff3:	01 d0                	add    %edx,%eax
f0107ff5:	8b 10                	mov    (%eax),%edx
f0107ff7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107ffa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107ffd:	29 c1                	sub    %eax,%ecx
f0107fff:	89 c8                	mov    %ecx,%eax
f0108001:	39 c2                	cmp    %eax,%edx
f0108003:	73 21                	jae    f0108026 <debuginfo_eip+0x3e9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0108005:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0108008:	89 c2                	mov    %eax,%edx
f010800a:	89 d0                	mov    %edx,%eax
f010800c:	01 c0                	add    %eax,%eax
f010800e:	01 d0                	add    %edx,%eax
f0108010:	c1 e0 02             	shl    $0x2,%eax
f0108013:	89 c2                	mov    %eax,%edx
f0108015:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108018:	01 d0                	add    %edx,%eax
f010801a:	8b 10                	mov    (%eax),%edx
f010801c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010801f:	01 c2                	add    %eax,%edx
f0108021:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108024:	89 10                	mov    %edx,(%eax)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0108026:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0108029:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010802c:	39 c2                	cmp    %eax,%edx
f010802e:	7d 4a                	jge    f010807a <debuginfo_eip+0x43d>
		for (lline = lfun + 1;
f0108030:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0108033:	83 c0 01             	add    $0x1,%eax
f0108036:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0108039:	eb 18                	jmp    f0108053 <debuginfo_eip+0x416>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010803b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010803e:	8b 40 14             	mov    0x14(%eax),%eax
f0108041:	8d 50 01             	lea    0x1(%eax),%edx
f0108044:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108047:	89 50 14             	mov    %edx,0x14(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010804a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010804d:	83 c0 01             	add    $0x1,%eax
f0108050:	89 45 d0             	mov    %eax,-0x30(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0108053:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0108056:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0108059:	39 c2                	cmp    %eax,%edx
f010805b:	7d 1d                	jge    f010807a <debuginfo_eip+0x43d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010805d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0108060:	89 c2                	mov    %eax,%edx
f0108062:	89 d0                	mov    %edx,%eax
f0108064:	01 c0                	add    %eax,%eax
f0108066:	01 d0                	add    %edx,%eax
f0108068:	c1 e0 02             	shl    $0x2,%eax
f010806b:	89 c2                	mov    %eax,%edx
f010806d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108070:	01 d0                	add    %edx,%eax
f0108072:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0108076:	3c a0                	cmp    $0xa0,%al
f0108078:	74 c1                	je     f010803b <debuginfo_eip+0x3fe>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010807a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010807f:	83 c4 54             	add    $0x54,%esp
f0108082:	5b                   	pop    %ebx
f0108083:	5d                   	pop    %ebp
f0108084:	c3                   	ret    

f0108085 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0108085:	55                   	push   %ebp
f0108086:	89 e5                	mov    %esp,%ebp
f0108088:	53                   	push   %ebx
f0108089:	83 ec 34             	sub    $0x34,%esp
f010808c:	8b 45 10             	mov    0x10(%ebp),%eax
f010808f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108092:	8b 45 14             	mov    0x14(%ebp),%eax
f0108095:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0108098:	8b 45 18             	mov    0x18(%ebp),%eax
f010809b:	ba 00 00 00 00       	mov    $0x0,%edx
f01080a0:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f01080a3:	77 72                	ja     f0108117 <printnum+0x92>
f01080a5:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f01080a8:	72 05                	jb     f01080af <printnum+0x2a>
f01080aa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f01080ad:	77 68                	ja     f0108117 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01080af:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01080b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01080b5:	8b 45 18             	mov    0x18(%ebp),%eax
f01080b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01080bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01080c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01080c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01080c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01080cb:	89 04 24             	mov    %eax,(%esp)
f01080ce:	89 54 24 04          	mov    %edx,0x4(%esp)
f01080d2:	e8 49 18 00 00       	call   f0109920 <__udivdi3>
f01080d7:	8b 4d 20             	mov    0x20(%ebp),%ecx
f01080da:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01080de:	89 5c 24 14          	mov    %ebx,0x14(%esp)
f01080e2:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01080e5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01080e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01080ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01080f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01080f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01080f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01080fb:	89 04 24             	mov    %eax,(%esp)
f01080fe:	e8 82 ff ff ff       	call   f0108085 <printnum>
f0108103:	eb 1c                	jmp    f0108121 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0108105:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108108:	89 44 24 04          	mov    %eax,0x4(%esp)
f010810c:	8b 45 20             	mov    0x20(%ebp),%eax
f010810f:	89 04 24             	mov    %eax,(%esp)
f0108112:	8b 45 08             	mov    0x8(%ebp),%eax
f0108115:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0108117:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
f010811b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f010811f:	7f e4                	jg     f0108105 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0108121:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0108124:	bb 00 00 00 00       	mov    $0x0,%ebx
f0108129:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010812c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010812f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0108133:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0108137:	89 04 24             	mov    %eax,(%esp)
f010813a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010813e:	e8 0d 19 00 00       	call   f0109a50 <__umoddi3>
f0108143:	05 28 b5 10 f0       	add    $0xf010b528,%eax
f0108148:	0f b6 00             	movzbl (%eax),%eax
f010814b:	0f be c0             	movsbl %al,%eax
f010814e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108151:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108155:	89 04 24             	mov    %eax,(%esp)
f0108158:	8b 45 08             	mov    0x8(%ebp),%eax
f010815b:	ff d0                	call   *%eax
}
f010815d:	83 c4 34             	add    $0x34,%esp
f0108160:	5b                   	pop    %ebx
f0108161:	5d                   	pop    %ebp
f0108162:	c3                   	ret    

f0108163 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0108163:	55                   	push   %ebp
f0108164:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0108166:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f010816a:	7e 14                	jle    f0108180 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f010816c:	8b 45 08             	mov    0x8(%ebp),%eax
f010816f:	8b 00                	mov    (%eax),%eax
f0108171:	8d 48 08             	lea    0x8(%eax),%ecx
f0108174:	8b 55 08             	mov    0x8(%ebp),%edx
f0108177:	89 0a                	mov    %ecx,(%edx)
f0108179:	8b 50 04             	mov    0x4(%eax),%edx
f010817c:	8b 00                	mov    (%eax),%eax
f010817e:	eb 30                	jmp    f01081b0 <getuint+0x4d>
	else if (lflag)
f0108180:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108184:	74 16                	je     f010819c <getuint+0x39>
		return va_arg(*ap, unsigned long);
f0108186:	8b 45 08             	mov    0x8(%ebp),%eax
f0108189:	8b 00                	mov    (%eax),%eax
f010818b:	8d 48 04             	lea    0x4(%eax),%ecx
f010818e:	8b 55 08             	mov    0x8(%ebp),%edx
f0108191:	89 0a                	mov    %ecx,(%edx)
f0108193:	8b 00                	mov    (%eax),%eax
f0108195:	ba 00 00 00 00       	mov    $0x0,%edx
f010819a:	eb 14                	jmp    f01081b0 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
f010819c:	8b 45 08             	mov    0x8(%ebp),%eax
f010819f:	8b 00                	mov    (%eax),%eax
f01081a1:	8d 48 04             	lea    0x4(%eax),%ecx
f01081a4:	8b 55 08             	mov    0x8(%ebp),%edx
f01081a7:	89 0a                	mov    %ecx,(%edx)
f01081a9:	8b 00                	mov    (%eax),%eax
f01081ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01081b0:	5d                   	pop    %ebp
f01081b1:	c3                   	ret    

f01081b2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01081b2:	55                   	push   %ebp
f01081b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01081b5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f01081b9:	7e 14                	jle    f01081cf <getint+0x1d>
		return va_arg(*ap, long long);
f01081bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01081be:	8b 00                	mov    (%eax),%eax
f01081c0:	8d 48 08             	lea    0x8(%eax),%ecx
f01081c3:	8b 55 08             	mov    0x8(%ebp),%edx
f01081c6:	89 0a                	mov    %ecx,(%edx)
f01081c8:	8b 50 04             	mov    0x4(%eax),%edx
f01081cb:	8b 00                	mov    (%eax),%eax
f01081cd:	eb 28                	jmp    f01081f7 <getint+0x45>
	else if (lflag)
f01081cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01081d3:	74 12                	je     f01081e7 <getint+0x35>
		return va_arg(*ap, long);
f01081d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01081d8:	8b 00                	mov    (%eax),%eax
f01081da:	8d 48 04             	lea    0x4(%eax),%ecx
f01081dd:	8b 55 08             	mov    0x8(%ebp),%edx
f01081e0:	89 0a                	mov    %ecx,(%edx)
f01081e2:	8b 00                	mov    (%eax),%eax
f01081e4:	99                   	cltd   
f01081e5:	eb 10                	jmp    f01081f7 <getint+0x45>
	else
		return va_arg(*ap, int);
f01081e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01081ea:	8b 00                	mov    (%eax),%eax
f01081ec:	8d 48 04             	lea    0x4(%eax),%ecx
f01081ef:	8b 55 08             	mov    0x8(%ebp),%edx
f01081f2:	89 0a                	mov    %ecx,(%edx)
f01081f4:	8b 00                	mov    (%eax),%eax
f01081f6:	99                   	cltd   
}
f01081f7:	5d                   	pop    %ebp
f01081f8:	c3                   	ret    

f01081f9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01081f9:	55                   	push   %ebp
f01081fa:	89 e5                	mov    %esp,%ebp
f01081fc:	56                   	push   %esi
f01081fd:	53                   	push   %ebx
f01081fe:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0108201:	eb 18                	jmp    f010821b <vprintfmt+0x22>
			if (ch == '\0')
f0108203:	85 db                	test   %ebx,%ebx
f0108205:	75 05                	jne    f010820c <vprintfmt+0x13>
				return;
f0108207:	e9 cc 03 00 00       	jmp    f01085d8 <vprintfmt+0x3df>
			putch(ch, putdat);
f010820c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010820f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108213:	89 1c 24             	mov    %ebx,(%esp)
f0108216:	8b 45 08             	mov    0x8(%ebp),%eax
f0108219:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010821b:	8b 45 10             	mov    0x10(%ebp),%eax
f010821e:	8d 50 01             	lea    0x1(%eax),%edx
f0108221:	89 55 10             	mov    %edx,0x10(%ebp)
f0108224:	0f b6 00             	movzbl (%eax),%eax
f0108227:	0f b6 d8             	movzbl %al,%ebx
f010822a:	83 fb 25             	cmp    $0x25,%ebx
f010822d:	75 d4                	jne    f0108203 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f010822f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f0108233:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f010823a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0108241:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f0108248:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010824f:	8b 45 10             	mov    0x10(%ebp),%eax
f0108252:	8d 50 01             	lea    0x1(%eax),%edx
f0108255:	89 55 10             	mov    %edx,0x10(%ebp)
f0108258:	0f b6 00             	movzbl (%eax),%eax
f010825b:	0f b6 d8             	movzbl %al,%ebx
f010825e:	8d 43 dd             	lea    -0x23(%ebx),%eax
f0108261:	83 f8 55             	cmp    $0x55,%eax
f0108264:	0f 87 3d 03 00 00    	ja     f01085a7 <vprintfmt+0x3ae>
f010826a:	8b 04 85 4c b5 10 f0 	mov    -0xfef4ab4(,%eax,4),%eax
f0108271:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f0108273:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f0108277:	eb d6                	jmp    f010824f <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0108279:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f010827d:	eb d0                	jmp    f010824f <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010827f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f0108286:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0108289:	89 d0                	mov    %edx,%eax
f010828b:	c1 e0 02             	shl    $0x2,%eax
f010828e:	01 d0                	add    %edx,%eax
f0108290:	01 c0                	add    %eax,%eax
f0108292:	01 d8                	add    %ebx,%eax
f0108294:	83 e8 30             	sub    $0x30,%eax
f0108297:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f010829a:	8b 45 10             	mov    0x10(%ebp),%eax
f010829d:	0f b6 00             	movzbl (%eax),%eax
f01082a0:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f01082a3:	83 fb 2f             	cmp    $0x2f,%ebx
f01082a6:	7e 0b                	jle    f01082b3 <vprintfmt+0xba>
f01082a8:	83 fb 39             	cmp    $0x39,%ebx
f01082ab:	7f 06                	jg     f01082b3 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01082ad:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01082b1:	eb d3                	jmp    f0108286 <vprintfmt+0x8d>
			goto process_precision;
f01082b3:	eb 33                	jmp    f01082e8 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
f01082b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01082b8:	8d 50 04             	lea    0x4(%eax),%edx
f01082bb:	89 55 14             	mov    %edx,0x14(%ebp)
f01082be:	8b 00                	mov    (%eax),%eax
f01082c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f01082c3:	eb 23                	jmp    f01082e8 <vprintfmt+0xef>

		case '.':
			if (width < 0)
f01082c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01082c9:	79 0c                	jns    f01082d7 <vprintfmt+0xde>
				width = 0;
f01082cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f01082d2:	e9 78 ff ff ff       	jmp    f010824f <vprintfmt+0x56>
f01082d7:	e9 73 ff ff ff       	jmp    f010824f <vprintfmt+0x56>

		case '#':
			altflag = 1;
f01082dc:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01082e3:	e9 67 ff ff ff       	jmp    f010824f <vprintfmt+0x56>

		process_precision:
			if (width < 0)
f01082e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01082ec:	79 12                	jns    f0108300 <vprintfmt+0x107>
				width = precision, precision = -1;
f01082ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01082f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01082f4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f01082fb:	e9 4f ff ff ff       	jmp    f010824f <vprintfmt+0x56>
f0108300:	e9 4a ff ff ff       	jmp    f010824f <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0108305:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
f0108309:	e9 41 ff ff ff       	jmp    f010824f <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010830e:	8b 45 14             	mov    0x14(%ebp),%eax
f0108311:	8d 50 04             	lea    0x4(%eax),%edx
f0108314:	89 55 14             	mov    %edx,0x14(%ebp)
f0108317:	8b 00                	mov    (%eax),%eax
f0108319:	8b 55 0c             	mov    0xc(%ebp),%edx
f010831c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108320:	89 04 24             	mov    %eax,(%esp)
f0108323:	8b 45 08             	mov    0x8(%ebp),%eax
f0108326:	ff d0                	call   *%eax
			break;
f0108328:	e9 a5 02 00 00       	jmp    f01085d2 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010832d:	8b 45 14             	mov    0x14(%ebp),%eax
f0108330:	8d 50 04             	lea    0x4(%eax),%edx
f0108333:	89 55 14             	mov    %edx,0x14(%ebp)
f0108336:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f0108338:	85 db                	test   %ebx,%ebx
f010833a:	79 02                	jns    f010833e <vprintfmt+0x145>
				err = -err;
f010833c:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010833e:	83 fb 09             	cmp    $0x9,%ebx
f0108341:	7f 0b                	jg     f010834e <vprintfmt+0x155>
f0108343:	8b 34 9d 00 b5 10 f0 	mov    -0xfef4b00(,%ebx,4),%esi
f010834a:	85 f6                	test   %esi,%esi
f010834c:	75 23                	jne    f0108371 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f010834e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0108352:	c7 44 24 08 39 b5 10 	movl   $0xf010b539,0x8(%esp)
f0108359:	f0 
f010835a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010835d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108361:	8b 45 08             	mov    0x8(%ebp),%eax
f0108364:	89 04 24             	mov    %eax,(%esp)
f0108367:	e8 73 02 00 00       	call   f01085df <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
f010836c:	e9 61 02 00 00       	jmp    f01085d2 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0108371:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0108375:	c7 44 24 08 42 b5 10 	movl   $0xf010b542,0x8(%esp)
f010837c:	f0 
f010837d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108380:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108384:	8b 45 08             	mov    0x8(%ebp),%eax
f0108387:	89 04 24             	mov    %eax,(%esp)
f010838a:	e8 50 02 00 00       	call   f01085df <printfmt>
			break;
f010838f:	e9 3e 02 00 00       	jmp    f01085d2 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0108394:	8b 45 14             	mov    0x14(%ebp),%eax
f0108397:	8d 50 04             	lea    0x4(%eax),%edx
f010839a:	89 55 14             	mov    %edx,0x14(%ebp)
f010839d:	8b 30                	mov    (%eax),%esi
f010839f:	85 f6                	test   %esi,%esi
f01083a1:	75 05                	jne    f01083a8 <vprintfmt+0x1af>
				p = "(null)";
f01083a3:	be 45 b5 10 f0       	mov    $0xf010b545,%esi
			if (width > 0 && padc != '-')
f01083a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01083ac:	7e 37                	jle    f01083e5 <vprintfmt+0x1ec>
f01083ae:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f01083b2:	74 31                	je     f01083e5 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
f01083b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01083b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01083bb:	89 34 24             	mov    %esi,(%esp)
f01083be:	e8 26 04 00 00       	call   f01087e9 <strnlen>
f01083c3:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01083c6:	eb 17                	jmp    f01083df <vprintfmt+0x1e6>
					putch(padc, putdat);
f01083c8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f01083cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01083cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01083d3:	89 04 24             	mov    %eax,(%esp)
f01083d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01083d9:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01083db:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01083df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01083e3:	7f e3                	jg     f01083c8 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01083e5:	eb 38                	jmp    f010841f <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
f01083e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01083eb:	74 1f                	je     f010840c <vprintfmt+0x213>
f01083ed:	83 fb 1f             	cmp    $0x1f,%ebx
f01083f0:	7e 05                	jle    f01083f7 <vprintfmt+0x1fe>
f01083f2:	83 fb 7e             	cmp    $0x7e,%ebx
f01083f5:	7e 15                	jle    f010840c <vprintfmt+0x213>
					putch('?', putdat);
f01083f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01083fe:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0108405:	8b 45 08             	mov    0x8(%ebp),%eax
f0108408:	ff d0                	call   *%eax
f010840a:	eb 0f                	jmp    f010841b <vprintfmt+0x222>
				else
					putch(ch, putdat);
f010840c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010840f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108413:	89 1c 24             	mov    %ebx,(%esp)
f0108416:	8b 45 08             	mov    0x8(%ebp),%eax
f0108419:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010841b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010841f:	89 f0                	mov    %esi,%eax
f0108421:	8d 70 01             	lea    0x1(%eax),%esi
f0108424:	0f b6 00             	movzbl (%eax),%eax
f0108427:	0f be d8             	movsbl %al,%ebx
f010842a:	85 db                	test   %ebx,%ebx
f010842c:	74 10                	je     f010843e <vprintfmt+0x245>
f010842e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0108432:	78 b3                	js     f01083e7 <vprintfmt+0x1ee>
f0108434:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0108438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010843c:	79 a9                	jns    f01083e7 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010843e:	eb 17                	jmp    f0108457 <vprintfmt+0x25e>
				putch(' ', putdat);
f0108440:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108443:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108447:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010844e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108451:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0108453:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0108457:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010845b:	7f e3                	jg     f0108440 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
f010845d:	e9 70 01 00 00       	jmp    f01085d2 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0108462:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108465:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108469:	8d 45 14             	lea    0x14(%ebp),%eax
f010846c:	89 04 24             	mov    %eax,(%esp)
f010846f:	e8 3e fd ff ff       	call   f01081b2 <getint>
f0108474:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108477:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f010847a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010847d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0108480:	85 d2                	test   %edx,%edx
f0108482:	79 26                	jns    f01084aa <vprintfmt+0x2b1>
				putch('-', putdat);
f0108484:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108487:	89 44 24 04          	mov    %eax,0x4(%esp)
f010848b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0108492:	8b 45 08             	mov    0x8(%ebp),%eax
f0108495:	ff d0                	call   *%eax
				num = -(long long) num;
f0108497:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010849a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010849d:	f7 d8                	neg    %eax
f010849f:	83 d2 00             	adc    $0x0,%edx
f01084a2:	f7 da                	neg    %edx
f01084a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01084a7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f01084aa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f01084b1:	e9 a8 00 00 00       	jmp    f010855e <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01084b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01084b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084bd:	8d 45 14             	lea    0x14(%ebp),%eax
f01084c0:	89 04 24             	mov    %eax,(%esp)
f01084c3:	e8 9b fc ff ff       	call   f0108163 <getuint>
f01084c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01084cb:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f01084ce:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f01084d5:	e9 84 00 00 00       	jmp    f010855e <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01084da:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01084dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084e1:	8d 45 14             	lea    0x14(%ebp),%eax
f01084e4:	89 04 24             	mov    %eax,(%esp)
f01084e7:	e8 77 fc ff ff       	call   f0108163 <getuint>
f01084ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01084ef:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
f01084f2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
f01084f9:	eb 63                	jmp    f010855e <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01084fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01084fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108502:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0108509:	8b 45 08             	mov    0x8(%ebp),%eax
f010850c:	ff d0                	call   *%eax
			putch('x', putdat);
f010850e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108511:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108515:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010851c:	8b 45 08             	mov    0x8(%ebp),%eax
f010851f:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0108521:	8b 45 14             	mov    0x14(%ebp),%eax
f0108524:	8d 50 04             	lea    0x4(%eax),%edx
f0108527:	89 55 14             	mov    %edx,0x14(%ebp)
f010852a:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010852c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010852f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0108536:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f010853d:	eb 1f                	jmp    f010855e <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010853f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108542:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108546:	8d 45 14             	lea    0x14(%ebp),%eax
f0108549:	89 04 24             	mov    %eax,(%esp)
f010854c:	e8 12 fc ff ff       	call   f0108163 <getuint>
f0108551:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108554:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f0108557:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f010855e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f0108562:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108565:	89 54 24 18          	mov    %edx,0x18(%esp)
f0108569:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010856c:	89 54 24 14          	mov    %edx,0x14(%esp)
f0108570:	89 44 24 10          	mov    %eax,0x10(%esp)
f0108574:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108577:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010857a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010857e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108582:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108585:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108589:	8b 45 08             	mov    0x8(%ebp),%eax
f010858c:	89 04 24             	mov    %eax,(%esp)
f010858f:	e8 f1 fa ff ff       	call   f0108085 <printnum>
			break;
f0108594:	eb 3c                	jmp    f01085d2 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0108596:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108599:	89 44 24 04          	mov    %eax,0x4(%esp)
f010859d:	89 1c 24             	mov    %ebx,(%esp)
f01085a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01085a3:	ff d0                	call   *%eax
			break;
f01085a5:	eb 2b                	jmp    f01085d2 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01085a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01085aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01085ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01085b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01085b8:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
f01085ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01085be:	eb 04                	jmp    f01085c4 <vprintfmt+0x3cb>
f01085c0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01085c4:	8b 45 10             	mov    0x10(%ebp),%eax
f01085c7:	83 e8 01             	sub    $0x1,%eax
f01085ca:	0f b6 00             	movzbl (%eax),%eax
f01085cd:	3c 25                	cmp    $0x25,%al
f01085cf:	75 ef                	jne    f01085c0 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
f01085d1:	90                   	nop
		}
	}
f01085d2:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01085d3:	e9 43 fc ff ff       	jmp    f010821b <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01085d8:	83 c4 40             	add    $0x40,%esp
f01085db:	5b                   	pop    %ebx
f01085dc:	5e                   	pop    %esi
f01085dd:	5d                   	pop    %ebp
f01085de:	c3                   	ret    

f01085df <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01085df:	55                   	push   %ebp
f01085e0:	89 e5                	mov    %esp,%ebp
f01085e2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f01085e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01085e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f01085eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01085ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01085f2:	8b 45 10             	mov    0x10(%ebp),%eax
f01085f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01085f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01085fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108600:	8b 45 08             	mov    0x8(%ebp),%eax
f0108603:	89 04 24             	mov    %eax,(%esp)
f0108606:	e8 ee fb ff ff       	call   f01081f9 <vprintfmt>
	va_end(ap);
}
f010860b:	c9                   	leave  
f010860c:	c3                   	ret    

f010860d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010860d:	55                   	push   %ebp
f010860e:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f0108610:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108613:	8b 40 08             	mov    0x8(%eax),%eax
f0108616:	8d 50 01             	lea    0x1(%eax),%edx
f0108619:	8b 45 0c             	mov    0xc(%ebp),%eax
f010861c:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f010861f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108622:	8b 10                	mov    (%eax),%edx
f0108624:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108627:	8b 40 04             	mov    0x4(%eax),%eax
f010862a:	39 c2                	cmp    %eax,%edx
f010862c:	73 12                	jae    f0108640 <sprintputch+0x33>
		*b->buf++ = ch;
f010862e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108631:	8b 00                	mov    (%eax),%eax
f0108633:	8d 48 01             	lea    0x1(%eax),%ecx
f0108636:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108639:	89 0a                	mov    %ecx,(%edx)
f010863b:	8b 55 08             	mov    0x8(%ebp),%edx
f010863e:	88 10                	mov    %dl,(%eax)
}
f0108640:	5d                   	pop    %ebp
f0108641:	c3                   	ret    

f0108642 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0108642:	55                   	push   %ebp
f0108643:	89 e5                	mov    %esp,%ebp
f0108645:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f0108648:	8b 45 08             	mov    0x8(%ebp),%eax
f010864b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010864e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108651:	8d 50 ff             	lea    -0x1(%eax),%edx
f0108654:	8b 45 08             	mov    0x8(%ebp),%eax
f0108657:	01 d0                	add    %edx,%eax
f0108659:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010865c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0108663:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0108667:	74 06                	je     f010866f <vsnprintf+0x2d>
f0108669:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010866d:	7f 07                	jg     f0108676 <vsnprintf+0x34>
		return -E_INVAL;
f010866f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0108674:	eb 2a                	jmp    f01086a0 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0108676:	8b 45 14             	mov    0x14(%ebp),%eax
f0108679:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010867d:	8b 45 10             	mov    0x10(%ebp),%eax
f0108680:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108684:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0108687:	89 44 24 04          	mov    %eax,0x4(%esp)
f010868b:	c7 04 24 0d 86 10 f0 	movl   $0xf010860d,(%esp)
f0108692:	e8 62 fb ff ff       	call   f01081f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0108697:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010869a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010869d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01086a0:	c9                   	leave  
f01086a1:	c3                   	ret    

f01086a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01086a2:	55                   	push   %ebp
f01086a3:	89 e5                	mov    %esp,%ebp
f01086a5:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01086a8:	8d 45 14             	lea    0x14(%ebp),%eax
f01086ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f01086ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01086b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01086b5:	8b 45 10             	mov    0x10(%ebp),%eax
f01086b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01086bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01086bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01086c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01086c6:	89 04 24             	mov    %eax,(%esp)
f01086c9:	e8 74 ff ff ff       	call   f0108642 <vsnprintf>
f01086ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
f01086d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01086d4:	c9                   	leave  
f01086d5:	c3                   	ret    

f01086d6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01086d6:	55                   	push   %ebp
f01086d7:	89 e5                	mov    %esp,%ebp
f01086d9:	83 ec 28             	sub    $0x28,%esp
	int i, c, echoing;

	if (prompt != NULL)
f01086dc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01086e0:	74 13                	je     f01086f5 <readline+0x1f>
		cprintf("%s", prompt);
f01086e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01086e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01086e9:	c7 04 24 a4 b6 10 f0 	movl   $0xf010b6a4,(%esp)
f01086f0:	e8 59 c8 ff ff       	call   f0104f4e <cprintf>

	i = 0;
f01086f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// echoing = iscons(0);
	echoing = 1;
f01086fc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	while (1) {
		c = getchar();
f0108703:	e8 ab 84 ff ff       	call   f0100bb3 <getchar>
f0108708:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
f010870b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010870f:	79 1d                	jns    f010872e <readline+0x58>
			cprintf("read error: %e\n", c);
f0108711:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108714:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108718:	c7 04 24 a7 b6 10 f0 	movl   $0xf010b6a7,(%esp)
f010871f:	e8 2a c8 ff ff       	call   f0104f4e <cprintf>
			return NULL;
f0108724:	b8 00 00 00 00       	mov    $0x0,%eax
f0108729:	e9 93 00 00 00       	jmp    f01087c1 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010872e:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
f0108732:	74 06                	je     f010873a <readline+0x64>
f0108734:	83 7d ec 7f          	cmpl   $0x7f,-0x14(%ebp)
f0108738:	75 1e                	jne    f0108758 <readline+0x82>
f010873a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010873e:	7e 18                	jle    f0108758 <readline+0x82>
			if (echoing)
f0108740:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108744:	74 0c                	je     f0108752 <readline+0x7c>
				cputchar('\b');
f0108746:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010874d:	e8 4e 84 ff ff       	call   f0100ba0 <cputchar>
			i--;
f0108752:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
f0108756:	eb 64                	jmp    f01087bc <readline+0xe6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0108758:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
f010875c:	7e 2e                	jle    f010878c <readline+0xb6>
f010875e:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f0108765:	7f 25                	jg     f010878c <readline+0xb6>
			if (echoing)
f0108767:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010876b:	74 0b                	je     f0108778 <readline+0xa2>
				cputchar(c);
f010876d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108770:	89 04 24             	mov    %eax,(%esp)
f0108773:	e8 28 84 ff ff       	call   f0100ba0 <cputchar>
			buf[i++] = c;
f0108778:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010877b:	8d 50 01             	lea    0x1(%eax),%edx
f010877e:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0108781:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108784:	88 90 e0 76 29 f0    	mov    %dl,-0xfd68920(%eax)
f010878a:	eb 30                	jmp    f01087bc <readline+0xe6>
		} else if (c == '\n' || c == '\r') {
f010878c:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
f0108790:	74 06                	je     f0108798 <readline+0xc2>
f0108792:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
f0108796:	75 24                	jne    f01087bc <readline+0xe6>
			if (echoing)
f0108798:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010879c:	74 0c                	je     f01087aa <readline+0xd4>
				cputchar('\n');
f010879e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01087a5:	e8 f6 83 ff ff       	call   f0100ba0 <cputchar>
			buf[i] = 0;
f01087aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01087ad:	05 e0 76 29 f0       	add    $0xf02976e0,%eax
f01087b2:	c6 00 00             	movb   $0x0,(%eax)
			return buf;
f01087b5:	b8 e0 76 29 f0       	mov    $0xf02976e0,%eax
f01087ba:	eb 05                	jmp    f01087c1 <readline+0xeb>
		}
	}
f01087bc:	e9 42 ff ff ff       	jmp    f0108703 <readline+0x2d>
}
f01087c1:	c9                   	leave  
f01087c2:	c3                   	ret    

f01087c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01087c3:	55                   	push   %ebp
f01087c4:	89 e5                	mov    %esp,%ebp
f01087c6:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f01087c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01087d0:	eb 08                	jmp    f01087da <strlen+0x17>
		n++;
f01087d2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01087d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01087da:	8b 45 08             	mov    0x8(%ebp),%eax
f01087dd:	0f b6 00             	movzbl (%eax),%eax
f01087e0:	84 c0                	test   %al,%al
f01087e2:	75 ee                	jne    f01087d2 <strlen+0xf>
		n++;
	return n;
f01087e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01087e7:	c9                   	leave  
f01087e8:	c3                   	ret    

f01087e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01087e9:	55                   	push   %ebp
f01087ea:	89 e5                	mov    %esp,%ebp
f01087ec:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01087ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01087f6:	eb 0c                	jmp    f0108804 <strnlen+0x1b>
		n++;
f01087f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01087fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108800:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
f0108804:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108808:	74 0a                	je     f0108814 <strnlen+0x2b>
f010880a:	8b 45 08             	mov    0x8(%ebp),%eax
f010880d:	0f b6 00             	movzbl (%eax),%eax
f0108810:	84 c0                	test   %al,%al
f0108812:	75 e4                	jne    f01087f8 <strnlen+0xf>
		n++;
	return n;
f0108814:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0108817:	c9                   	leave  
f0108818:	c3                   	ret    

f0108819 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0108819:	55                   	push   %ebp
f010881a:	89 e5                	mov    %esp,%ebp
f010881c:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f010881f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108822:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f0108825:	90                   	nop
f0108826:	8b 45 08             	mov    0x8(%ebp),%eax
f0108829:	8d 50 01             	lea    0x1(%eax),%edx
f010882c:	89 55 08             	mov    %edx,0x8(%ebp)
f010882f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108832:	8d 4a 01             	lea    0x1(%edx),%ecx
f0108835:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f0108838:	0f b6 12             	movzbl (%edx),%edx
f010883b:	88 10                	mov    %dl,(%eax)
f010883d:	0f b6 00             	movzbl (%eax),%eax
f0108840:	84 c0                	test   %al,%al
f0108842:	75 e2                	jne    f0108826 <strcpy+0xd>
		/* do nothing */;
	return ret;
f0108844:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0108847:	c9                   	leave  
f0108848:	c3                   	ret    

f0108849 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0108849:	55                   	push   %ebp
f010884a:	89 e5                	mov    %esp,%ebp
f010884c:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
f010884f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108852:	89 04 24             	mov    %eax,(%esp)
f0108855:	e8 69 ff ff ff       	call   f01087c3 <strlen>
f010885a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
f010885d:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0108860:	8b 45 08             	mov    0x8(%ebp),%eax
f0108863:	01 c2                	add    %eax,%edx
f0108865:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108868:	89 44 24 04          	mov    %eax,0x4(%esp)
f010886c:	89 14 24             	mov    %edx,(%esp)
f010886f:	e8 a5 ff ff ff       	call   f0108819 <strcpy>
	return dst;
f0108874:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108877:	c9                   	leave  
f0108878:	c3                   	ret    

f0108879 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0108879:	55                   	push   %ebp
f010887a:	89 e5                	mov    %esp,%ebp
f010887c:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
f010887f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108882:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f0108885:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010888c:	eb 23                	jmp    f01088b1 <strncpy+0x38>
		*dst++ = *src;
f010888e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108891:	8d 50 01             	lea    0x1(%eax),%edx
f0108894:	89 55 08             	mov    %edx,0x8(%ebp)
f0108897:	8b 55 0c             	mov    0xc(%ebp),%edx
f010889a:	0f b6 12             	movzbl (%edx),%edx
f010889d:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f010889f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01088a2:	0f b6 00             	movzbl (%eax),%eax
f01088a5:	84 c0                	test   %al,%al
f01088a7:	74 04                	je     f01088ad <strncpy+0x34>
			src++;
f01088a9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01088ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f01088b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01088b4:	3b 45 10             	cmp    0x10(%ebp),%eax
f01088b7:	72 d5                	jb     f010888e <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f01088b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01088bc:	c9                   	leave  
f01088bd:	c3                   	ret    

f01088be <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01088be:	55                   	push   %ebp
f01088bf:	89 e5                	mov    %esp,%ebp
f01088c1:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f01088c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01088c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f01088ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01088ce:	74 33                	je     f0108903 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f01088d0:	eb 17                	jmp    f01088e9 <strlcpy+0x2b>
			*dst++ = *src++;
f01088d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01088d5:	8d 50 01             	lea    0x1(%eax),%edx
f01088d8:	89 55 08             	mov    %edx,0x8(%ebp)
f01088db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01088de:	8d 4a 01             	lea    0x1(%edx),%ecx
f01088e1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f01088e4:	0f b6 12             	movzbl (%edx),%edx
f01088e7:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01088e9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01088ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01088f1:	74 0a                	je     f01088fd <strlcpy+0x3f>
f01088f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01088f6:	0f b6 00             	movzbl (%eax),%eax
f01088f9:	84 c0                	test   %al,%al
f01088fb:	75 d5                	jne    f01088d2 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f01088fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0108900:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0108903:	8b 55 08             	mov    0x8(%ebp),%edx
f0108906:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108909:	29 c2                	sub    %eax,%edx
f010890b:	89 d0                	mov    %edx,%eax
}
f010890d:	c9                   	leave  
f010890e:	c3                   	ret    

f010890f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010890f:	55                   	push   %ebp
f0108910:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f0108912:	eb 08                	jmp    f010891c <strcmp+0xd>
		p++, q++;
f0108914:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108918:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010891c:	8b 45 08             	mov    0x8(%ebp),%eax
f010891f:	0f b6 00             	movzbl (%eax),%eax
f0108922:	84 c0                	test   %al,%al
f0108924:	74 10                	je     f0108936 <strcmp+0x27>
f0108926:	8b 45 08             	mov    0x8(%ebp),%eax
f0108929:	0f b6 10             	movzbl (%eax),%edx
f010892c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010892f:	0f b6 00             	movzbl (%eax),%eax
f0108932:	38 c2                	cmp    %al,%dl
f0108934:	74 de                	je     f0108914 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0108936:	8b 45 08             	mov    0x8(%ebp),%eax
f0108939:	0f b6 00             	movzbl (%eax),%eax
f010893c:	0f b6 d0             	movzbl %al,%edx
f010893f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108942:	0f b6 00             	movzbl (%eax),%eax
f0108945:	0f b6 c0             	movzbl %al,%eax
f0108948:	29 c2                	sub    %eax,%edx
f010894a:	89 d0                	mov    %edx,%eax
}
f010894c:	5d                   	pop    %ebp
f010894d:	c3                   	ret    

f010894e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010894e:	55                   	push   %ebp
f010894f:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f0108951:	eb 0c                	jmp    f010895f <strncmp+0x11>
		n--, p++, q++;
f0108953:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f0108957:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f010895b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010895f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108963:	74 1a                	je     f010897f <strncmp+0x31>
f0108965:	8b 45 08             	mov    0x8(%ebp),%eax
f0108968:	0f b6 00             	movzbl (%eax),%eax
f010896b:	84 c0                	test   %al,%al
f010896d:	74 10                	je     f010897f <strncmp+0x31>
f010896f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108972:	0f b6 10             	movzbl (%eax),%edx
f0108975:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108978:	0f b6 00             	movzbl (%eax),%eax
f010897b:	38 c2                	cmp    %al,%dl
f010897d:	74 d4                	je     f0108953 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f010897f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108983:	75 07                	jne    f010898c <strncmp+0x3e>
		return 0;
f0108985:	b8 00 00 00 00       	mov    $0x0,%eax
f010898a:	eb 16                	jmp    f01089a2 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010898c:	8b 45 08             	mov    0x8(%ebp),%eax
f010898f:	0f b6 00             	movzbl (%eax),%eax
f0108992:	0f b6 d0             	movzbl %al,%edx
f0108995:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108998:	0f b6 00             	movzbl (%eax),%eax
f010899b:	0f b6 c0             	movzbl %al,%eax
f010899e:	29 c2                	sub    %eax,%edx
f01089a0:	89 d0                	mov    %edx,%eax
}
f01089a2:	5d                   	pop    %ebp
f01089a3:	c3                   	ret    

f01089a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01089a4:	55                   	push   %ebp
f01089a5:	89 e5                	mov    %esp,%ebp
f01089a7:	83 ec 04             	sub    $0x4,%esp
f01089aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01089ad:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f01089b0:	eb 14                	jmp    f01089c6 <strchr+0x22>
		if (*s == c)
f01089b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01089b5:	0f b6 00             	movzbl (%eax),%eax
f01089b8:	3a 45 fc             	cmp    -0x4(%ebp),%al
f01089bb:	75 05                	jne    f01089c2 <strchr+0x1e>
			return (char *) s;
f01089bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01089c0:	eb 13                	jmp    f01089d5 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01089c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01089c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01089c9:	0f b6 00             	movzbl (%eax),%eax
f01089cc:	84 c0                	test   %al,%al
f01089ce:	75 e2                	jne    f01089b2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f01089d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01089d5:	c9                   	leave  
f01089d6:	c3                   	ret    

f01089d7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01089d7:	55                   	push   %ebp
f01089d8:	89 e5                	mov    %esp,%ebp
f01089da:	83 ec 04             	sub    $0x4,%esp
f01089dd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01089e0:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f01089e3:	eb 11                	jmp    f01089f6 <strfind+0x1f>
		if (*s == c)
f01089e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01089e8:	0f b6 00             	movzbl (%eax),%eax
f01089eb:	3a 45 fc             	cmp    -0x4(%ebp),%al
f01089ee:	75 02                	jne    f01089f2 <strfind+0x1b>
			break;
f01089f0:	eb 0e                	jmp    f0108a00 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01089f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01089f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01089f9:	0f b6 00             	movzbl (%eax),%eax
f01089fc:	84 c0                	test   %al,%al
f01089fe:	75 e5                	jne    f01089e5 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
f0108a00:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108a03:	c9                   	leave  
f0108a04:	c3                   	ret    

f0108a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0108a05:	55                   	push   %ebp
f0108a06:	89 e5                	mov    %esp,%ebp
f0108a08:	57                   	push   %edi
	char *p;

	if (n == 0)
f0108a09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108a0d:	75 05                	jne    f0108a14 <memset+0xf>
		return v;
f0108a0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a12:	eb 5c                	jmp    f0108a70 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
f0108a14:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a17:	83 e0 03             	and    $0x3,%eax
f0108a1a:	85 c0                	test   %eax,%eax
f0108a1c:	75 41                	jne    f0108a5f <memset+0x5a>
f0108a1e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a21:	83 e0 03             	and    $0x3,%eax
f0108a24:	85 c0                	test   %eax,%eax
f0108a26:	75 37                	jne    f0108a5f <memset+0x5a>
		c &= 0xFF;
f0108a28:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0108a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a32:	c1 e0 18             	shl    $0x18,%eax
f0108a35:	89 c2                	mov    %eax,%edx
f0108a37:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a3a:	c1 e0 10             	shl    $0x10,%eax
f0108a3d:	09 c2                	or     %eax,%edx
f0108a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a42:	c1 e0 08             	shl    $0x8,%eax
f0108a45:	09 d0                	or     %edx,%eax
f0108a47:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0108a4a:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a4d:	c1 e8 02             	shr    $0x2,%eax
f0108a50:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0108a52:	8b 55 08             	mov    0x8(%ebp),%edx
f0108a55:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a58:	89 d7                	mov    %edx,%edi
f0108a5a:	fc                   	cld    
f0108a5b:	f3 ab                	rep stos %eax,%es:(%edi)
f0108a5d:	eb 0e                	jmp    f0108a6d <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0108a5f:	8b 55 08             	mov    0x8(%ebp),%edx
f0108a62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108a68:	89 d7                	mov    %edx,%edi
f0108a6a:	fc                   	cld    
f0108a6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
f0108a6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108a70:	5f                   	pop    %edi
f0108a71:	5d                   	pop    %ebp
f0108a72:	c3                   	ret    

f0108a73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0108a73:	55                   	push   %ebp
f0108a74:	89 e5                	mov    %esp,%ebp
f0108a76:	57                   	push   %edi
f0108a77:	56                   	push   %esi
f0108a78:	53                   	push   %ebx
f0108a79:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f0108a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
f0108a82:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
f0108a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108a8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0108a8e:	73 6d                	jae    f0108afd <memmove+0x8a>
f0108a90:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a93:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108a96:	01 d0                	add    %edx,%eax
f0108a98:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0108a9b:	76 60                	jbe    f0108afd <memmove+0x8a>
		s += n;
f0108a9d:	8b 45 10             	mov    0x10(%ebp),%eax
f0108aa0:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
f0108aa3:	8b 45 10             	mov    0x10(%ebp),%eax
f0108aa6:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0108aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108aac:	83 e0 03             	and    $0x3,%eax
f0108aaf:	85 c0                	test   %eax,%eax
f0108ab1:	75 2f                	jne    f0108ae2 <memmove+0x6f>
f0108ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108ab6:	83 e0 03             	and    $0x3,%eax
f0108ab9:	85 c0                	test   %eax,%eax
f0108abb:	75 25                	jne    f0108ae2 <memmove+0x6f>
f0108abd:	8b 45 10             	mov    0x10(%ebp),%eax
f0108ac0:	83 e0 03             	and    $0x3,%eax
f0108ac3:	85 c0                	test   %eax,%eax
f0108ac5:	75 1b                	jne    f0108ae2 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0108ac7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108aca:	83 e8 04             	sub    $0x4,%eax
f0108acd:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108ad0:	83 ea 04             	sub    $0x4,%edx
f0108ad3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108ad6:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0108ad9:	89 c7                	mov    %eax,%edi
f0108adb:	89 d6                	mov    %edx,%esi
f0108add:	fd                   	std    
f0108ade:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0108ae0:	eb 18                	jmp    f0108afa <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0108ae2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108ae5:	8d 50 ff             	lea    -0x1(%eax),%edx
f0108ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108aeb:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0108aee:	8b 45 10             	mov    0x10(%ebp),%eax
f0108af1:	89 d7                	mov    %edx,%edi
f0108af3:	89 de                	mov    %ebx,%esi
f0108af5:	89 c1                	mov    %eax,%ecx
f0108af7:	fd                   	std    
f0108af8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0108afa:	fc                   	cld    
f0108afb:	eb 45                	jmp    f0108b42 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0108afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108b00:	83 e0 03             	and    $0x3,%eax
f0108b03:	85 c0                	test   %eax,%eax
f0108b05:	75 2b                	jne    f0108b32 <memmove+0xbf>
f0108b07:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108b0a:	83 e0 03             	and    $0x3,%eax
f0108b0d:	85 c0                	test   %eax,%eax
f0108b0f:	75 21                	jne    f0108b32 <memmove+0xbf>
f0108b11:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b14:	83 e0 03             	and    $0x3,%eax
f0108b17:	85 c0                	test   %eax,%eax
f0108b19:	75 17                	jne    f0108b32 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0108b1b:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b1e:	c1 e8 02             	shr    $0x2,%eax
f0108b21:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0108b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108b26:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108b29:	89 c7                	mov    %eax,%edi
f0108b2b:	89 d6                	mov    %edx,%esi
f0108b2d:	fc                   	cld    
f0108b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0108b30:	eb 10                	jmp    f0108b42 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0108b32:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108b35:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108b38:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108b3b:	89 c7                	mov    %eax,%edi
f0108b3d:	89 d6                	mov    %edx,%esi
f0108b3f:	fc                   	cld    
f0108b40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
f0108b42:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108b45:	83 c4 10             	add    $0x10,%esp
f0108b48:	5b                   	pop    %ebx
f0108b49:	5e                   	pop    %esi
f0108b4a:	5f                   	pop    %edi
f0108b4b:	5d                   	pop    %ebp
f0108b4c:	c3                   	ret    

f0108b4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0108b4d:	55                   	push   %ebp
f0108b4e:	89 e5                	mov    %esp,%ebp
f0108b50:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0108b53:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108b61:	8b 45 08             	mov    0x8(%ebp),%eax
f0108b64:	89 04 24             	mov    %eax,(%esp)
f0108b67:	e8 07 ff ff ff       	call   f0108a73 <memmove>
}
f0108b6c:	c9                   	leave  
f0108b6d:	c3                   	ret    

f0108b6e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0108b6e:	55                   	push   %ebp
f0108b6f:	89 e5                	mov    %esp,%ebp
f0108b71:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
f0108b74:	8b 45 08             	mov    0x8(%ebp),%eax
f0108b77:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
f0108b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108b7d:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f0108b80:	eb 30                	jmp    f0108bb2 <memcmp+0x44>
		if (*s1 != *s2)
f0108b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108b85:	0f b6 10             	movzbl (%eax),%edx
f0108b88:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108b8b:	0f b6 00             	movzbl (%eax),%eax
f0108b8e:	38 c2                	cmp    %al,%dl
f0108b90:	74 18                	je     f0108baa <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
f0108b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108b95:	0f b6 00             	movzbl (%eax),%eax
f0108b98:	0f b6 d0             	movzbl %al,%edx
f0108b9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108b9e:	0f b6 00             	movzbl (%eax),%eax
f0108ba1:	0f b6 c0             	movzbl %al,%eax
f0108ba4:	29 c2                	sub    %eax,%edx
f0108ba6:	89 d0                	mov    %edx,%eax
f0108ba8:	eb 1a                	jmp    f0108bc4 <memcmp+0x56>
		s1++, s2++;
f0108baa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108bae:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0108bb2:	8b 45 10             	mov    0x10(%ebp),%eax
f0108bb5:	8d 50 ff             	lea    -0x1(%eax),%edx
f0108bb8:	89 55 10             	mov    %edx,0x10(%ebp)
f0108bbb:	85 c0                	test   %eax,%eax
f0108bbd:	75 c3                	jne    f0108b82 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0108bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108bc4:	c9                   	leave  
f0108bc5:	c3                   	ret    

f0108bc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0108bc6:	55                   	push   %ebp
f0108bc7:	89 e5                	mov    %esp,%ebp
f0108bc9:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f0108bcc:	8b 45 10             	mov    0x10(%ebp),%eax
f0108bcf:	8b 55 08             	mov    0x8(%ebp),%edx
f0108bd2:	01 d0                	add    %edx,%eax
f0108bd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f0108bd7:	eb 13                	jmp    f0108bec <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f0108bd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0108bdc:	0f b6 10             	movzbl (%eax),%edx
f0108bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108be2:	38 c2                	cmp    %al,%dl
f0108be4:	75 02                	jne    f0108be8 <memfind+0x22>
			break;
f0108be6:	eb 0c                	jmp    f0108bf4 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0108be8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108bec:	8b 45 08             	mov    0x8(%ebp),%eax
f0108bef:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0108bf2:	72 e5                	jb     f0108bd9 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
f0108bf4:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108bf7:	c9                   	leave  
f0108bf8:	c3                   	ret    

f0108bf9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0108bf9:	55                   	push   %ebp
f0108bfa:	89 e5                	mov    %esp,%ebp
f0108bfc:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f0108bff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f0108c06:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0108c0d:	eb 04                	jmp    f0108c13 <strtol+0x1a>
		s++;
f0108c0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0108c13:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c16:	0f b6 00             	movzbl (%eax),%eax
f0108c19:	3c 20                	cmp    $0x20,%al
f0108c1b:	74 f2                	je     f0108c0f <strtol+0x16>
f0108c1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c20:	0f b6 00             	movzbl (%eax),%eax
f0108c23:	3c 09                	cmp    $0x9,%al
f0108c25:	74 e8                	je     f0108c0f <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f0108c27:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c2a:	0f b6 00             	movzbl (%eax),%eax
f0108c2d:	3c 2b                	cmp    $0x2b,%al
f0108c2f:	75 06                	jne    f0108c37 <strtol+0x3e>
		s++;
f0108c31:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108c35:	eb 15                	jmp    f0108c4c <strtol+0x53>
	else if (*s == '-')
f0108c37:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c3a:	0f b6 00             	movzbl (%eax),%eax
f0108c3d:	3c 2d                	cmp    $0x2d,%al
f0108c3f:	75 0b                	jne    f0108c4c <strtol+0x53>
		s++, neg = 1;
f0108c41:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108c45:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0108c4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108c50:	74 06                	je     f0108c58 <strtol+0x5f>
f0108c52:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f0108c56:	75 24                	jne    f0108c7c <strtol+0x83>
f0108c58:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c5b:	0f b6 00             	movzbl (%eax),%eax
f0108c5e:	3c 30                	cmp    $0x30,%al
f0108c60:	75 1a                	jne    f0108c7c <strtol+0x83>
f0108c62:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c65:	83 c0 01             	add    $0x1,%eax
f0108c68:	0f b6 00             	movzbl (%eax),%eax
f0108c6b:	3c 78                	cmp    $0x78,%al
f0108c6d:	75 0d                	jne    f0108c7c <strtol+0x83>
		s += 2, base = 16;
f0108c6f:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f0108c73:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0108c7a:	eb 2a                	jmp    f0108ca6 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
f0108c7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108c80:	75 17                	jne    f0108c99 <strtol+0xa0>
f0108c82:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c85:	0f b6 00             	movzbl (%eax),%eax
f0108c88:	3c 30                	cmp    $0x30,%al
f0108c8a:	75 0d                	jne    f0108c99 <strtol+0xa0>
		s++, base = 8;
f0108c8c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108c90:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0108c97:	eb 0d                	jmp    f0108ca6 <strtol+0xad>
	else if (base == 0)
f0108c99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108c9d:	75 07                	jne    f0108ca6 <strtol+0xad>
		base = 10;
f0108c9f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0108ca6:	8b 45 08             	mov    0x8(%ebp),%eax
f0108ca9:	0f b6 00             	movzbl (%eax),%eax
f0108cac:	3c 2f                	cmp    $0x2f,%al
f0108cae:	7e 1b                	jle    f0108ccb <strtol+0xd2>
f0108cb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0108cb3:	0f b6 00             	movzbl (%eax),%eax
f0108cb6:	3c 39                	cmp    $0x39,%al
f0108cb8:	7f 11                	jg     f0108ccb <strtol+0xd2>
			dig = *s - '0';
f0108cba:	8b 45 08             	mov    0x8(%ebp),%eax
f0108cbd:	0f b6 00             	movzbl (%eax),%eax
f0108cc0:	0f be c0             	movsbl %al,%eax
f0108cc3:	83 e8 30             	sub    $0x30,%eax
f0108cc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108cc9:	eb 48                	jmp    f0108d13 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
f0108ccb:	8b 45 08             	mov    0x8(%ebp),%eax
f0108cce:	0f b6 00             	movzbl (%eax),%eax
f0108cd1:	3c 60                	cmp    $0x60,%al
f0108cd3:	7e 1b                	jle    f0108cf0 <strtol+0xf7>
f0108cd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0108cd8:	0f b6 00             	movzbl (%eax),%eax
f0108cdb:	3c 7a                	cmp    $0x7a,%al
f0108cdd:	7f 11                	jg     f0108cf0 <strtol+0xf7>
			dig = *s - 'a' + 10;
f0108cdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0108ce2:	0f b6 00             	movzbl (%eax),%eax
f0108ce5:	0f be c0             	movsbl %al,%eax
f0108ce8:	83 e8 57             	sub    $0x57,%eax
f0108ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108cee:	eb 23                	jmp    f0108d13 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
f0108cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0108cf3:	0f b6 00             	movzbl (%eax),%eax
f0108cf6:	3c 40                	cmp    $0x40,%al
f0108cf8:	7e 3d                	jle    f0108d37 <strtol+0x13e>
f0108cfa:	8b 45 08             	mov    0x8(%ebp),%eax
f0108cfd:	0f b6 00             	movzbl (%eax),%eax
f0108d00:	3c 5a                	cmp    $0x5a,%al
f0108d02:	7f 33                	jg     f0108d37 <strtol+0x13e>
			dig = *s - 'A' + 10;
f0108d04:	8b 45 08             	mov    0x8(%ebp),%eax
f0108d07:	0f b6 00             	movzbl (%eax),%eax
f0108d0a:	0f be c0             	movsbl %al,%eax
f0108d0d:	83 e8 37             	sub    $0x37,%eax
f0108d10:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0108d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108d16:	3b 45 10             	cmp    0x10(%ebp),%eax
f0108d19:	7c 02                	jl     f0108d1d <strtol+0x124>
			break;
f0108d1b:	eb 1a                	jmp    f0108d37 <strtol+0x13e>
		s++, val = (val * base) + dig;
f0108d1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108d21:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108d24:	0f af 45 10          	imul   0x10(%ebp),%eax
f0108d28:	89 c2                	mov    %eax,%edx
f0108d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108d2d:	01 d0                	add    %edx,%eax
f0108d2f:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f0108d32:	e9 6f ff ff ff       	jmp    f0108ca6 <strtol+0xad>

	if (endptr)
f0108d37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108d3b:	74 08                	je     f0108d45 <strtol+0x14c>
		*endptr = (char *) s;
f0108d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108d40:	8b 55 08             	mov    0x8(%ebp),%edx
f0108d43:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0108d45:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0108d49:	74 07                	je     f0108d52 <strtol+0x159>
f0108d4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108d4e:	f7 d8                	neg    %eax
f0108d50:	eb 03                	jmp    f0108d55 <strtol+0x15c>
f0108d52:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0108d55:	c9                   	leave  
f0108d56:	c3                   	ret    
f0108d57:	90                   	nop

f0108d58 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0108d58:	fa                   	cli    

	xorw    %ax, %ax
f0108d59:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0108d5b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0108d5d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0108d5f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0108d61:	0f 01 16             	lgdtl  (%esi)
f0108d64:	74 70                	je     f0108dd6 <_kaddr+0x3>
	movl    %cr0, %eax
f0108d66:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0108d69:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0108d6d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0108d70:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0108d76:	08 00                	or     %al,(%eax)

f0108d78 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0108d78:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0108d7c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0108d7e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0108d80:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0108d82:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0108d86:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0108d88:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0108d8a:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f0108d8f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0108d92:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0108d95:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0108d9a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0108d9d:	8b 25 e4 7a 29 f0    	mov    0xf0297ae4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0108da3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0108da8:	b8 55 02 10 f0       	mov    $0xf0100255,%eax
	call    *%eax
f0108dad:	ff d0                	call   *%eax

f0108daf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0108daf:	eb fe                	jmp    f0108daf <spin>
f0108db1:	8d 76 00             	lea    0x0(%esi),%esi

f0108db4 <gdt>:
	...
f0108dbc:	ff                   	(bad)  
f0108dbd:	ff 00                	incl   (%eax)
f0108dbf:	00 00                	add    %al,(%eax)
f0108dc1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0108dc8:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0108dcc <gdtdesc>:
f0108dcc:	17                   	pop    %ss
f0108dcd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0108dd2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0108dd2:	90                   	nop

f0108dd3 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0108dd3:	55                   	push   %ebp
f0108dd4:	89 e5                	mov    %esp,%ebp
f0108dd6:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0108dd9:	8b 45 10             	mov    0x10(%ebp),%eax
f0108ddc:	c1 e8 0c             	shr    $0xc,%eax
f0108ddf:	89 c2                	mov    %eax,%edx
f0108de1:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f0108de6:	39 c2                	cmp    %eax,%edx
f0108de8:	72 21                	jb     f0108e0b <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0108dea:	8b 45 10             	mov    0x10(%ebp),%eax
f0108ded:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108df1:	c7 44 24 08 b8 b6 10 	movl   $0xf010b6b8,0x8(%esp)
f0108df8:	f0 
f0108df9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108e00:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e03:	89 04 24             	mov    %eax,(%esp)
f0108e06:	e8 c4 74 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f0108e0b:	8b 45 10             	mov    0x10(%ebp),%eax
f0108e0e:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0108e13:	c9                   	leave  
f0108e14:	c3                   	ret    

f0108e15 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0108e15:	55                   	push   %ebp
f0108e16:	89 e5                	mov    %esp,%ebp
f0108e18:	83 ec 10             	sub    $0x10,%esp
	int i, sum;

	sum = 0;
f0108e1b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i = 0; i < len; i++)
f0108e22:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0108e29:	eb 15                	jmp    f0108e40 <sum+0x2b>
		sum += ((uint8_t *)addr)[i];
f0108e2b:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0108e2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e31:	01 d0                	add    %edx,%eax
f0108e33:	0f b6 00             	movzbl (%eax),%eax
f0108e36:	0f b6 c0             	movzbl %al,%eax
f0108e39:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0108e3c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108e43:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0108e46:	7c e3                	jl     f0108e2b <sum+0x16>
		sum += ((uint8_t *)addr)[i];
	return sum;
f0108e48:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0108e4b:	c9                   	leave  
f0108e4c:	c3                   	ret    

f0108e4d <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0108e4d:	55                   	push   %ebp
f0108e4e:	89 e5                	mov    %esp,%ebp
f0108e50:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0108e53:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108e5a:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0108e61:	00 
f0108e62:	c7 04 24 db b6 10 f0 	movl   $0xf010b6db,(%esp)
f0108e69:	e8 65 ff ff ff       	call   f0108dd3 <_kaddr>
f0108e6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108e71:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108e74:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e77:	01 d0                	add    %edx,%eax
f0108e79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108e7d:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0108e84:	00 
f0108e85:	c7 04 24 db b6 10 f0 	movl   $0xf010b6db,(%esp)
f0108e8c:	e8 42 ff ff ff       	call   f0108dd3 <_kaddr>
f0108e91:	89 45 f0             	mov    %eax,-0x10(%ebp)

	for (; mp < end; mp++)
f0108e94:	eb 3f                	jmp    f0108ed5 <mpsearch1+0x88>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0108e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108e99:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0108ea0:	00 
f0108ea1:	c7 44 24 04 eb b6 10 	movl   $0xf010b6eb,0x4(%esp)
f0108ea8:	f0 
f0108ea9:	89 04 24             	mov    %eax,(%esp)
f0108eac:	e8 bd fc ff ff       	call   f0108b6e <memcmp>
f0108eb1:	85 c0                	test   %eax,%eax
f0108eb3:	75 1c                	jne    f0108ed1 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
f0108eb5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0108ebc:	00 
f0108ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108ec0:	89 04 24             	mov    %eax,(%esp)
f0108ec3:	e8 4d ff ff ff       	call   f0108e15 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0108ec8:	84 c0                	test   %al,%al
f0108eca:	75 05                	jne    f0108ed1 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
f0108ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108ecf:	eb 11                	jmp    f0108ee2 <mpsearch1+0x95>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0108ed1:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
f0108ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108ed8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0108edb:	72 b9                	jb     f0108e96 <mpsearch1+0x49>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0108edd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108ee2:	c9                   	leave  
f0108ee3:	c3                   	ret    

f0108ee4 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0108ee4:	55                   	push   %ebp
f0108ee5:	89 e5                	mov    %esp,%ebp
f0108ee7:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0108eea:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f0108ef1:	00 
f0108ef2:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0108ef9:	00 
f0108efa:	c7 04 24 db b6 10 f0 	movl   $0xf010b6db,(%esp)
f0108f01:	e8 cd fe ff ff       	call   f0108dd3 <_kaddr>
f0108f06:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0108f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108f0c:	83 c0 0e             	add    $0xe,%eax
f0108f0f:	0f b7 00             	movzwl (%eax),%eax
f0108f12:	0f b7 c0             	movzwl %ax,%eax
f0108f15:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108f18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108f1c:	74 25                	je     f0108f43 <mpsearch+0x5f>
		p <<= 4;	// Translate from segment to PA
f0108f1e:	c1 65 f0 04          	shll   $0x4,-0x10(%ebp)
		if ((mp = mpsearch1(p, 1024)))
f0108f22:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0108f29:	00 
f0108f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108f2d:	89 04 24             	mov    %eax,(%esp)
f0108f30:	e8 18 ff ff ff       	call   f0108e4d <mpsearch1>
f0108f35:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108f38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108f3c:	74 3d                	je     f0108f7b <mpsearch+0x97>
			return mp;
f0108f3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108f41:	eb 4c                	jmp    f0108f8f <mpsearch+0xab>
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0108f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108f46:	83 c0 13             	add    $0x13,%eax
f0108f49:	0f b7 00             	movzwl (%eax),%eax
f0108f4c:	0f b7 c0             	movzwl %ax,%eax
f0108f4f:	c1 e0 0a             	shl    $0xa,%eax
f0108f52:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if ((mp = mpsearch1(p - 1024, 1024)))
f0108f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108f58:	2d 00 04 00 00       	sub    $0x400,%eax
f0108f5d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0108f64:	00 
f0108f65:	89 04 24             	mov    %eax,(%esp)
f0108f68:	e8 e0 fe ff ff       	call   f0108e4d <mpsearch1>
f0108f6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108f70:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108f74:	74 05                	je     f0108f7b <mpsearch+0x97>
			return mp;
f0108f76:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108f79:	eb 14                	jmp    f0108f8f <mpsearch+0xab>
	}
	return mpsearch1(0xF0000, 0x10000);
f0108f7b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0108f82:	00 
f0108f83:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
f0108f8a:	e8 be fe ff ff       	call   f0108e4d <mpsearch1>
}
f0108f8f:	c9                   	leave  
f0108f90:	c3                   	ret    

f0108f91 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0108f91:	55                   	push   %ebp
f0108f92:	89 e5                	mov    %esp,%ebp
f0108f94:	83 ec 28             	sub    $0x28,%esp
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0108f97:	e8 48 ff ff ff       	call   f0108ee4 <mpsearch>
f0108f9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108f9f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0108fa3:	75 0a                	jne    f0108faf <mpconfig+0x1e>
		return NULL;
f0108fa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0108faa:	e9 44 01 00 00       	jmp    f01090f3 <mpconfig+0x162>
	if (mp->physaddr == 0 || mp->type != 0) {
f0108faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108fb2:	8b 40 04             	mov    0x4(%eax),%eax
f0108fb5:	85 c0                	test   %eax,%eax
f0108fb7:	74 0b                	je     f0108fc4 <mpconfig+0x33>
f0108fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108fbc:	0f b6 40 0b          	movzbl 0xb(%eax),%eax
f0108fc0:	84 c0                	test   %al,%al
f0108fc2:	74 16                	je     f0108fda <mpconfig+0x49>
		cprintf("SMP: Default configurations not implemented\n");
f0108fc4:	c7 04 24 f0 b6 10 f0 	movl   $0xf010b6f0,(%esp)
f0108fcb:	e8 7e bf ff ff       	call   f0104f4e <cprintf>
		return NULL;
f0108fd0:	b8 00 00 00 00       	mov    $0x0,%eax
f0108fd5:	e9 19 01 00 00       	jmp    f01090f3 <mpconfig+0x162>
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0108fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108fdd:	8b 40 04             	mov    0x4(%eax),%eax
f0108fe0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108fe4:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0108feb:	00 
f0108fec:	c7 04 24 db b6 10 f0 	movl   $0xf010b6db,(%esp)
f0108ff3:	e8 db fd ff ff       	call   f0108dd3 <_kaddr>
f0108ff8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0) {
f0108ffb:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0109002:	00 
f0109003:	c7 44 24 04 1d b7 10 	movl   $0xf010b71d,0x4(%esp)
f010900a:	f0 
f010900b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010900e:	89 04 24             	mov    %eax,(%esp)
f0109011:	e8 58 fb ff ff       	call   f0108b6e <memcmp>
f0109016:	85 c0                	test   %eax,%eax
f0109018:	74 16                	je     f0109030 <mpconfig+0x9f>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010901a:	c7 04 24 24 b7 10 f0 	movl   $0xf010b724,(%esp)
f0109021:	e8 28 bf ff ff       	call   f0104f4e <cprintf>
		return NULL;
f0109026:	b8 00 00 00 00       	mov    $0x0,%eax
f010902b:	e9 c3 00 00 00       	jmp    f01090f3 <mpconfig+0x162>
	}
	if (sum(conf, conf->length) != 0) {
f0109030:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109033:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0109037:	0f b7 c0             	movzwl %ax,%eax
f010903a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010903e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109041:	89 04 24             	mov    %eax,(%esp)
f0109044:	e8 cc fd ff ff       	call   f0108e15 <sum>
f0109049:	84 c0                	test   %al,%al
f010904b:	74 16                	je     f0109063 <mpconfig+0xd2>
		cprintf("SMP: Bad MP configuration checksum\n");
f010904d:	c7 04 24 58 b7 10 f0 	movl   $0xf010b758,(%esp)
f0109054:	e8 f5 be ff ff       	call   f0104f4e <cprintf>
		return NULL;
f0109059:	b8 00 00 00 00       	mov    $0x0,%eax
f010905e:	e9 90 00 00 00       	jmp    f01090f3 <mpconfig+0x162>
	}
	if (conf->version != 1 && conf->version != 4) {
f0109063:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109066:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f010906a:	3c 01                	cmp    $0x1,%al
f010906c:	74 2c                	je     f010909a <mpconfig+0x109>
f010906e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109071:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0109075:	3c 04                	cmp    $0x4,%al
f0109077:	74 21                	je     f010909a <mpconfig+0x109>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0109079:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010907c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0109080:	0f b6 c0             	movzbl %al,%eax
f0109083:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109087:	c7 04 24 7c b7 10 f0 	movl   $0xf010b77c,(%esp)
f010908e:	e8 bb be ff ff       	call   f0104f4e <cprintf>
		return NULL;
f0109093:	b8 00 00 00 00       	mov    $0x0,%eax
f0109098:	eb 59                	jmp    f01090f3 <mpconfig+0x162>
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010909a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010909d:	0f b7 40 28          	movzwl 0x28(%eax),%eax
f01090a1:	0f b7 c0             	movzwl %ax,%eax
f01090a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01090a7:	0f b7 52 04          	movzwl 0x4(%edx),%edx
f01090ab:	0f b7 ca             	movzwl %dx,%ecx
f01090ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01090b1:	01 ca                	add    %ecx,%edx
f01090b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01090b7:	89 14 24             	mov    %edx,(%esp)
f01090ba:	e8 56 fd ff ff       	call   f0108e15 <sum>
f01090bf:	0f b6 d0             	movzbl %al,%edx
f01090c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01090c5:	0f b6 40 2a          	movzbl 0x2a(%eax),%eax
f01090c9:	0f b6 c0             	movzbl %al,%eax
f01090cc:	01 d0                	add    %edx,%eax
f01090ce:	0f b6 c0             	movzbl %al,%eax
f01090d1:	85 c0                	test   %eax,%eax
f01090d3:	74 13                	je     f01090e8 <mpconfig+0x157>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01090d5:	c7 04 24 9c b7 10 f0 	movl   $0xf010b79c,(%esp)
f01090dc:	e8 6d be ff ff       	call   f0104f4e <cprintf>
		return NULL;
f01090e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01090e6:	eb 0b                	jmp    f01090f3 <mpconfig+0x162>
	}
	*pmp = mp;
f01090e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01090eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01090ee:	89 10                	mov    %edx,(%eax)
	return conf;
f01090f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f01090f3:	c9                   	leave  
f01090f4:	c3                   	ret    

f01090f5 <mp_init>:

void
mp_init(void)
{
f01090f5:	55                   	push   %ebp
f01090f6:	89 e5                	mov    %esp,%ebp
f01090f8:	83 ec 48             	sub    $0x48,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01090fb:	c7 05 c0 83 29 f0 20 	movl   $0xf0298020,0xf02983c0
f0109102:	80 29 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0109105:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0109108:	89 04 24             	mov    %eax,(%esp)
f010910b:	e8 81 fe ff ff       	call   f0108f91 <mpconfig>
f0109110:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0109113:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0109117:	75 05                	jne    f010911e <mp_init+0x29>
		return;
f0109119:	e9 c1 01 00 00       	jmp    f01092df <mp_init+0x1ea>
	ismp = 1;
f010911e:	c7 05 00 80 29 f0 01 	movl   $0x1,0xf0298000
f0109125:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0109128:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010912b:	8b 40 24             	mov    0x24(%eax),%eax
f010912e:	a3 00 90 2d f0       	mov    %eax,0xf02d9000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0109133:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0109136:	83 c0 2c             	add    $0x2c,%eax
f0109139:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010913c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0109143:	e9 d2 00 00 00       	jmp    f010921a <mp_init+0x125>
		switch (*p) {
f0109148:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010914b:	0f b6 00             	movzbl (%eax),%eax
f010914e:	0f b6 c0             	movzbl %al,%eax
f0109151:	85 c0                	test   %eax,%eax
f0109153:	74 13                	je     f0109168 <mp_init+0x73>
f0109155:	85 c0                	test   %eax,%eax
f0109157:	0f 88 89 00 00 00    	js     f01091e6 <mp_init+0xf1>
f010915d:	83 f8 04             	cmp    $0x4,%eax
f0109160:	0f 8f 80 00 00 00    	jg     f01091e6 <mp_init+0xf1>
f0109166:	eb 78                	jmp    f01091e0 <mp_init+0xeb>
		case MPPROC:
			proc = (struct mpproc *)p;
f0109168:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010916b:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if (proc->flags & MPPROC_BOOT)
f010916e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0109171:	0f b6 40 03          	movzbl 0x3(%eax),%eax
f0109175:	0f b6 c0             	movzbl %al,%eax
f0109178:	83 e0 02             	and    $0x2,%eax
f010917b:	85 c0                	test   %eax,%eax
f010917d:	74 12                	je     f0109191 <mp_init+0x9c>
				bootcpu = &cpus[ncpu];
f010917f:	a1 c4 83 29 f0       	mov    0xf02983c4,%eax
f0109184:	6b c0 74             	imul   $0x74,%eax,%eax
f0109187:	05 20 80 29 f0       	add    $0xf0298020,%eax
f010918c:	a3 c0 83 29 f0       	mov    %eax,0xf02983c0
			if (ncpu < NCPU) {
f0109191:	a1 c4 83 29 f0       	mov    0xf02983c4,%eax
f0109196:	83 f8 07             	cmp    $0x7,%eax
f0109199:	7f 25                	jg     f01091c0 <mp_init+0xcb>
				cpus[ncpu].cpu_id = ncpu;
f010919b:	8b 15 c4 83 29 f0    	mov    0xf02983c4,%edx
f01091a1:	a1 c4 83 29 f0       	mov    0xf02983c4,%eax
f01091a6:	6b d2 74             	imul   $0x74,%edx,%edx
f01091a9:	81 c2 20 80 29 f0    	add    $0xf0298020,%edx
f01091af:	88 02                	mov    %al,(%edx)
				ncpu++;
f01091b1:	a1 c4 83 29 f0       	mov    0xf02983c4,%eax
f01091b6:	83 c0 01             	add    $0x1,%eax
f01091b9:	a3 c4 83 29 f0       	mov    %eax,0xf02983c4
f01091be:	eb 1a                	jmp    f01091da <mp_init+0xe5>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
f01091c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01091c3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
				bootcpu = &cpus[ncpu];
			if (ncpu < NCPU) {
				cpus[ncpu].cpu_id = ncpu;
				ncpu++;
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01091c7:	0f b6 c0             	movzbl %al,%eax
f01091ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01091ce:	c7 04 24 cc b7 10 f0 	movl   $0xf010b7cc,(%esp)
f01091d5:	e8 74 bd ff ff       	call   f0104f4e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01091da:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
			continue;
f01091de:	eb 36                	jmp    f0109216 <mp_init+0x121>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01091e0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
			continue;
f01091e4:	eb 30                	jmp    f0109216 <mp_init+0x121>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01091e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01091e9:	0f b6 00             	movzbl (%eax),%eax
f01091ec:	0f b6 c0             	movzbl %al,%eax
f01091ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01091f3:	c7 04 24 f4 b7 10 f0 	movl   $0xf010b7f4,(%esp)
f01091fa:	e8 4f bd ff ff       	call   f0104f4e <cprintf>
			ismp = 0;
f01091ff:	c7 05 00 80 29 f0 00 	movl   $0x0,0xf0298000
f0109206:	00 00 00 
			i = conf->entry;
f0109209:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010920c:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0109210:	0f b7 c0             	movzwl %ax,%eax
f0109213:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0109216:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f010921a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010921d:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0109221:	0f b7 c0             	movzwl %ax,%eax
f0109224:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0109227:	0f 87 1b ff ff ff    	ja     f0109148 <mp_init+0x53>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010922d:	a1 c0 83 29 f0       	mov    0xf02983c0,%eax
f0109232:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0109239:	a1 00 80 29 f0       	mov    0xf0298000,%eax
f010923e:	85 c0                	test   %eax,%eax
f0109240:	75 22                	jne    f0109264 <mp_init+0x16f>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0109242:	c7 05 c4 83 29 f0 01 	movl   $0x1,0xf02983c4
f0109249:	00 00 00 
		lapicaddr = 0;
f010924c:	c7 05 00 90 2d f0 00 	movl   $0x0,0xf02d9000
f0109253:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0109256:	c7 04 24 14 b8 10 f0 	movl   $0xf010b814,(%esp)
f010925d:	e8 ec bc ff ff       	call   f0104f4e <cprintf>
		return;
f0109262:	eb 7b                	jmp    f01092df <mp_init+0x1ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0109264:	8b 15 c4 83 29 f0    	mov    0xf02983c4,%edx
f010926a:	a1 c0 83 29 f0       	mov    0xf02983c0,%eax
f010926f:	0f b6 00             	movzbl (%eax),%eax
f0109272:	0f b6 c0             	movzbl %al,%eax
f0109275:	89 54 24 08          	mov    %edx,0x8(%esp)
f0109279:	89 44 24 04          	mov    %eax,0x4(%esp)
f010927d:	c7 04 24 40 b8 10 f0 	movl   $0xf010b840,(%esp)
f0109284:	e8 c5 bc ff ff       	call   f0104f4e <cprintf>

	if (mp->imcrp) {
f0109289:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010928c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
f0109290:	84 c0                	test   %al,%al
f0109292:	74 4b                	je     f01092df <mp_init+0x1ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0109294:	c7 04 24 60 b8 10 f0 	movl   $0xf010b860,(%esp)
f010929b:	e8 ae bc ff ff       	call   f0104f4e <cprintf>
f01092a0:	c7 45 e4 22 00 00 00 	movl   $0x22,-0x1c(%ebp)
f01092a7:	c6 45 e3 70          	movb   $0x70,-0x1d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01092ab:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01092af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01092b2:	ee                   	out    %al,(%dx)
f01092b3:	c7 45 dc 23 00 00 00 	movl   $0x23,-0x24(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01092ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01092bd:	89 c2                	mov    %eax,%edx
f01092bf:	ec                   	in     (%dx),%al
f01092c0:	88 45 db             	mov    %al,-0x25(%ebp)
	return data;
f01092c3:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01092c7:	83 c8 01             	or     $0x1,%eax
f01092ca:	0f b6 c0             	movzbl %al,%eax
f01092cd:	c7 45 d4 23 00 00 00 	movl   $0x23,-0x2c(%ebp)
f01092d4:	88 45 d3             	mov    %al,-0x2d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01092d7:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f01092db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01092de:	ee                   	out    %al,(%dx)
	}
}
f01092df:	c9                   	leave  
f01092e0:	c3                   	ret    

f01092e1 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01092e1:	55                   	push   %ebp
f01092e2:	89 e5                	mov    %esp,%ebp
f01092e4:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f01092e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01092ea:	c1 e8 0c             	shr    $0xc,%eax
f01092ed:	89 c2                	mov    %eax,%edx
f01092ef:	a1 e8 7a 29 f0       	mov    0xf0297ae8,%eax
f01092f4:	39 c2                	cmp    %eax,%edx
f01092f6:	72 21                	jb     f0109319 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01092f8:	8b 45 10             	mov    0x10(%ebp),%eax
f01092fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01092ff:	c7 44 24 08 a4 b8 10 	movl   $0xf010b8a4,0x8(%esp)
f0109306:	f0 
f0109307:	8b 45 0c             	mov    0xc(%ebp),%eax
f010930a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010930e:	8b 45 08             	mov    0x8(%ebp),%eax
f0109311:	89 04 24             	mov    %eax,(%esp)
f0109314:	e8 b6 6f ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f0109319:	8b 45 10             	mov    0x10(%ebp),%eax
f010931c:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0109321:	c9                   	leave  
f0109322:	c3                   	ret    

f0109323 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0109323:	55                   	push   %ebp
f0109324:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0109326:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f010932b:	8b 55 08             	mov    0x8(%ebp),%edx
f010932e:	c1 e2 02             	shl    $0x2,%edx
f0109331:	01 c2                	add    %eax,%edx
f0109333:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109336:	89 02                	mov    %eax,(%edx)
	lapic[ID];  // wait for write to finish, by reading
f0109338:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f010933d:	83 c0 20             	add    $0x20,%eax
f0109340:	8b 00                	mov    (%eax),%eax
}
f0109342:	5d                   	pop    %ebp
f0109343:	c3                   	ret    

f0109344 <lapic_init>:

void
lapic_init(void)
{
f0109344:	55                   	push   %ebp
f0109345:	89 e5                	mov    %esp,%ebp
f0109347:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f010934a:	a1 00 90 2d f0       	mov    0xf02d9000,%eax
f010934f:	85 c0                	test   %eax,%eax
f0109351:	75 05                	jne    f0109358 <lapic_init+0x14>
		return;
f0109353:	e9 74 01 00 00       	jmp    f01094cc <lapic_init+0x188>

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0109358:	a1 00 90 2d f0       	mov    0xf02d9000,%eax
f010935d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0109364:	00 
f0109365:	89 04 24             	mov    %eax,(%esp)
f0109368:	e8 11 89 ff ff       	call   f0101c7e <mmio_map_region>
f010936d:	a3 04 90 2d f0       	mov    %eax,0xf02d9004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0109372:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f0109379:	00 
f010937a:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
f0109381:	e8 9d ff ff ff       	call   f0109323 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0109386:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
f010938d:	00 
f010938e:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
f0109395:	e8 89 ff ff ff       	call   f0109323 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010939a:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
f01093a1:	00 
f01093a2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f01093a9:	e8 75 ff ff ff       	call   f0109323 <lapicw>
	lapicw(TICR, 10000000); 
f01093ae:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
f01093b5:	00 
f01093b6:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
f01093bd:	e8 61 ff ff ff       	call   f0109323 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01093c2:	e8 07 01 00 00       	call   f01094ce <cpunum>
f01093c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01093ca:	8d 90 20 80 29 f0    	lea    -0xfd67fe0(%eax),%edx
f01093d0:	a1 c0 83 29 f0       	mov    0xf02983c0,%eax
f01093d5:	39 c2                	cmp    %eax,%edx
f01093d7:	74 14                	je     f01093ed <lapic_init+0xa9>
		lapicw(LINT0, MASKED);
f01093d9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f01093e0:	00 
f01093e1:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
f01093e8:	e8 36 ff ff ff       	call   f0109323 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01093ed:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f01093f4:	00 
f01093f5:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
f01093fc:	e8 22 ff ff ff       	call   f0109323 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0109401:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f0109406:	83 c0 30             	add    $0x30,%eax
f0109409:	8b 00                	mov    (%eax),%eax
f010940b:	c1 e8 10             	shr    $0x10,%eax
f010940e:	0f b6 c0             	movzbl %al,%eax
f0109411:	83 f8 03             	cmp    $0x3,%eax
f0109414:	76 14                	jbe    f010942a <lapic_init+0xe6>
		lapicw(PCINT, MASKED);
f0109416:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f010941d:	00 
f010941e:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
f0109425:	e8 f9 fe ff ff       	call   f0109323 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010942a:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f0109431:	00 
f0109432:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
f0109439:	e8 e5 fe ff ff       	call   f0109323 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010943e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109445:	00 
f0109446:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f010944d:	e8 d1 fe ff ff       	call   f0109323 <lapicw>
	lapicw(ESR, 0);
f0109452:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109459:	00 
f010945a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f0109461:	e8 bd fe ff ff       	call   f0109323 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0109466:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010946d:	00 
f010946e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f0109475:	e8 a9 fe ff ff       	call   f0109323 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010947a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109481:	00 
f0109482:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0109489:	e8 95 fe ff ff       	call   f0109323 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010948e:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
f0109495:	00 
f0109496:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f010949d:	e8 81 fe ff ff       	call   f0109323 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01094a2:	90                   	nop
f01094a3:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f01094a8:	05 00 03 00 00       	add    $0x300,%eax
f01094ad:	8b 00                	mov    (%eax),%eax
f01094af:	25 00 10 00 00       	and    $0x1000,%eax
f01094b4:	85 c0                	test   %eax,%eax
f01094b6:	75 eb                	jne    f01094a3 <lapic_init+0x15f>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01094b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01094bf:	00 
f01094c0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01094c7:	e8 57 fe ff ff       	call   f0109323 <lapicw>
}
f01094cc:	c9                   	leave  
f01094cd:	c3                   	ret    

f01094ce <cpunum>:

int
cpunum(void)
{
f01094ce:	55                   	push   %ebp
f01094cf:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01094d1:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f01094d6:	85 c0                	test   %eax,%eax
f01094d8:	74 0f                	je     f01094e9 <cpunum+0x1b>
		return lapic[ID] >> 24;
f01094da:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f01094df:	83 c0 20             	add    $0x20,%eax
f01094e2:	8b 00                	mov    (%eax),%eax
f01094e4:	c1 e8 18             	shr    $0x18,%eax
f01094e7:	eb 05                	jmp    f01094ee <cpunum+0x20>
	return 0;
f01094e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01094ee:	5d                   	pop    %ebp
f01094ef:	c3                   	ret    

f01094f0 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01094f0:	55                   	push   %ebp
f01094f1:	89 e5                	mov    %esp,%ebp
f01094f3:	83 ec 08             	sub    $0x8,%esp
	if (lapic)
f01094f6:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f01094fb:	85 c0                	test   %eax,%eax
f01094fd:	74 14                	je     f0109513 <lapic_eoi+0x23>
		lapicw(EOI, 0);
f01094ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109506:	00 
f0109507:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f010950e:	e8 10 fe ff ff       	call   f0109323 <lapicw>
}
f0109513:	c9                   	leave  
f0109514:	c3                   	ret    

f0109515 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0109515:	55                   	push   %ebp
f0109516:	89 e5                	mov    %esp,%ebp
}
f0109518:	5d                   	pop    %ebp
f0109519:	c3                   	ret    

f010951a <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010951a:	55                   	push   %ebp
f010951b:	89 e5                	mov    %esp,%ebp
f010951d:	83 ec 38             	sub    $0x38,%esp
f0109520:	8b 45 08             	mov    0x8(%ebp),%eax
f0109523:	88 45 d4             	mov    %al,-0x2c(%ebp)
f0109526:	c7 45 ec 70 00 00 00 	movl   $0x70,-0x14(%ebp)
f010952d:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
f0109531:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0109535:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0109538:	ee                   	out    %al,(%dx)
f0109539:	c7 45 e4 71 00 00 00 	movl   $0x71,-0x1c(%ebp)
f0109540:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
f0109544:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0109548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010954b:	ee                   	out    %al,(%dx)
	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f010954c:	c7 44 24 08 67 04 00 	movl   $0x467,0x8(%esp)
f0109553:	00 
f0109554:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f010955b:	00 
f010955c:	c7 04 24 c7 b8 10 f0 	movl   $0xf010b8c7,(%esp)
f0109563:	e8 79 fd ff ff       	call   f01092e1 <_kaddr>
f0109568:	89 45 f0             	mov    %eax,-0x10(%ebp)
	wrv[0] = 0;
f010956b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010956e:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f0109573:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109576:	8d 50 02             	lea    0x2(%eax),%edx
f0109579:	8b 45 0c             	mov    0xc(%ebp),%eax
f010957c:	c1 e8 04             	shr    $0x4,%eax
f010957f:	66 89 02             	mov    %ax,(%edx)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0109582:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f0109586:	c1 e0 18             	shl    $0x18,%eax
f0109589:	89 44 24 04          	mov    %eax,0x4(%esp)
f010958d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0109594:	e8 8a fd ff ff       	call   f0109323 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0109599:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
f01095a0:	00 
f01095a1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f01095a8:	e8 76 fd ff ff       	call   f0109323 <lapicw>
	microdelay(200);
f01095ad:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f01095b4:	e8 5c ff ff ff       	call   f0109515 <microdelay>
	lapicw(ICRLO, INIT | LEVEL);
f01095b9:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
f01095c0:	00 
f01095c1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f01095c8:	e8 56 fd ff ff       	call   f0109323 <lapicw>
	microdelay(100);    // should be 10ms, but too slow in Bochs!
f01095cd:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01095d4:	e8 3c ff ff ff       	call   f0109515 <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f01095d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01095e0:	eb 40                	jmp    f0109622 <lapic_startap+0x108>
		lapicw(ICRHI, apicid << 24);
f01095e2:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f01095e6:	c1 e0 18             	shl    $0x18,%eax
f01095e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01095ed:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f01095f4:	e8 2a fd ff ff       	call   f0109323 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01095f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01095fc:	c1 e8 0c             	shr    $0xc,%eax
f01095ff:	80 cc 06             	or     $0x6,%ah
f0109602:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109606:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f010960d:	e8 11 fd ff ff       	call   f0109323 <lapicw>
		microdelay(200);
f0109612:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f0109619:	e8 f7 fe ff ff       	call   f0109515 <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f010961e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0109622:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
f0109626:	7e ba                	jle    f01095e2 <lapic_startap+0xc8>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
f0109628:	c9                   	leave  
f0109629:	c3                   	ret    

f010962a <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010962a:	55                   	push   %ebp
f010962b:	89 e5                	mov    %esp,%ebp
f010962d:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0109630:	8b 45 08             	mov    0x8(%ebp),%eax
f0109633:	0d 00 00 0c 00       	or     $0xc0000,%eax
f0109638:	89 44 24 04          	mov    %eax,0x4(%esp)
f010963c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0109643:	e8 db fc ff ff       	call   f0109323 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0109648:	90                   	nop
f0109649:	a1 04 90 2d f0       	mov    0xf02d9004,%eax
f010964e:	05 00 03 00 00       	add    $0x300,%eax
f0109653:	8b 00                	mov    (%eax),%eax
f0109655:	25 00 10 00 00       	and    $0x1000,%eax
f010965a:	85 c0                	test   %eax,%eax
f010965c:	75 eb                	jne    f0109649 <lapic_ipi+0x1f>
		;
}
f010965e:	c9                   	leave  
f010965f:	c3                   	ret    

f0109660 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0109660:	55                   	push   %ebp
f0109661:	89 e5                	mov    %esp,%ebp
f0109663:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0109666:	8b 55 08             	mov    0x8(%ebp),%edx
f0109669:	8b 45 0c             	mov    0xc(%ebp),%eax
f010966c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010966f:	f0 87 02             	lock xchg %eax,(%edx)
f0109672:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0109675:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0109678:	c9                   	leave  
f0109679:	c3                   	ret    

f010967a <get_caller_pcs>:

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
f010967a:	55                   	push   %ebp
f010967b:	89 e5                	mov    %esp,%ebp
f010967d:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0109680:	89 e8                	mov    %ebp,%eax
f0109682:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return ebp;
f0109685:	8b 45 f4             	mov    -0xc(%ebp),%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0109688:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < 10; i++){
f010968b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
f0109692:	eb 32                	jmp    f01096c6 <get_caller_pcs+0x4c>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0109694:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0109698:	74 32                	je     f01096cc <get_caller_pcs+0x52>
f010969a:	81 7d fc ff ff 7f ef 	cmpl   $0xef7fffff,-0x4(%ebp)
f01096a1:	76 29                	jbe    f01096cc <get_caller_pcs+0x52>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01096a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01096a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01096ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01096b0:	01 c2                	add    %eax,%edx
f01096b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01096b5:	8b 40 04             	mov    0x4(%eax),%eax
f01096b8:	89 02                	mov    %eax,(%edx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01096ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01096bd:	8b 00                	mov    (%eax),%eax
f01096bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01096c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f01096c6:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f01096ca:	7e c8                	jle    f0109694 <get_caller_pcs+0x1a>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01096cc:	eb 19                	jmp    f01096e7 <get_caller_pcs+0x6d>
		pcs[i] = 0;
f01096ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01096d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01096d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01096db:	01 d0                	add    %edx,%eax
f01096dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01096e3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f01096e7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f01096eb:	7e e1                	jle    f01096ce <get_caller_pcs+0x54>
		pcs[i] = 0;
}
f01096ed:	c9                   	leave  
f01096ee:	c3                   	ret    

f01096ef <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01096ef:	55                   	push   %ebp
f01096f0:	89 e5                	mov    %esp,%ebp
f01096f2:	53                   	push   %ebx
f01096f3:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01096f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01096f9:	8b 00                	mov    (%eax),%eax
f01096fb:	85 c0                	test   %eax,%eax
f01096fd:	74 1e                	je     f010971d <holding+0x2e>
f01096ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0109702:	8b 58 08             	mov    0x8(%eax),%ebx
f0109705:	e8 c4 fd ff ff       	call   f01094ce <cpunum>
f010970a:	6b c0 74             	imul   $0x74,%eax,%eax
f010970d:	05 20 80 29 f0       	add    $0xf0298020,%eax
f0109712:	39 c3                	cmp    %eax,%ebx
f0109714:	75 07                	jne    f010971d <holding+0x2e>
f0109716:	b8 01 00 00 00       	mov    $0x1,%eax
f010971b:	eb 05                	jmp    f0109722 <holding+0x33>
f010971d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0109722:	83 c4 04             	add    $0x4,%esp
f0109725:	5b                   	pop    %ebx
f0109726:	5d                   	pop    %ebp
f0109727:	c3                   	ret    

f0109728 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0109728:	55                   	push   %ebp
f0109729:	89 e5                	mov    %esp,%ebp
	lk->locked = 0;
f010972b:	8b 45 08             	mov    0x8(%ebp),%eax
f010972e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0109734:	8b 45 08             	mov    0x8(%ebp),%eax
f0109737:	8b 55 0c             	mov    0xc(%ebp),%edx
f010973a:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010973d:	8b 45 08             	mov    0x8(%ebp),%eax
f0109740:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0109747:	5d                   	pop    %ebp
f0109748:	c3                   	ret    

f0109749 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0109749:	55                   	push   %ebp
f010974a:	89 e5                	mov    %esp,%ebp
f010974c:	53                   	push   %ebx
f010974d:	83 ec 24             	sub    $0x24,%esp
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0109750:	8b 45 08             	mov    0x8(%ebp),%eax
f0109753:	89 04 24             	mov    %eax,(%esp)
f0109756:	e8 94 ff ff ff       	call   f01096ef <holding>
f010975b:	85 c0                	test   %eax,%eax
f010975d:	74 2f                	je     f010978e <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010975f:	8b 45 08             	mov    0x8(%ebp),%eax
f0109762:	8b 58 04             	mov    0x4(%eax),%ebx
f0109765:	e8 64 fd ff ff       	call   f01094ce <cpunum>
f010976a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010976e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109772:	c7 44 24 08 e0 b8 10 	movl   $0xf010b8e0,0x8(%esp)
f0109779:	f0 
f010977a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0109781:	00 
f0109782:	c7 04 24 0a b9 10 f0 	movl   $0xf010b90a,(%esp)
f0109789:	e8 41 6b ff ff       	call   f01002cf <_panic>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010978e:	eb 02                	jmp    f0109792 <spin_lock+0x49>
		asm volatile ("pause");
f0109790:	f3 90                	pause  
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0109792:	8b 45 08             	mov    0x8(%ebp),%eax
f0109795:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010979c:	00 
f010979d:	89 04 24             	mov    %eax,(%esp)
f01097a0:	e8 bb fe ff ff       	call   f0109660 <xchg>
f01097a5:	85 c0                	test   %eax,%eax
f01097a7:	75 e7                	jne    f0109790 <spin_lock+0x47>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01097a9:	e8 20 fd ff ff       	call   f01094ce <cpunum>
f01097ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01097b1:	8d 90 20 80 29 f0    	lea    -0xfd67fe0(%eax),%edx
f01097b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01097ba:	89 50 08             	mov    %edx,0x8(%eax)
	get_caller_pcs(lk->pcs);
f01097bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01097c0:	83 c0 0c             	add    $0xc,%eax
f01097c3:	89 04 24             	mov    %eax,(%esp)
f01097c6:	e8 af fe ff ff       	call   f010967a <get_caller_pcs>
#endif
}
f01097cb:	83 c4 24             	add    $0x24,%esp
f01097ce:	5b                   	pop    %ebx
f01097cf:	5d                   	pop    %ebp
f01097d0:	c3                   	ret    

f01097d1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01097d1:	55                   	push   %ebp
f01097d2:	89 e5                	mov    %esp,%ebp
f01097d4:	57                   	push   %edi
f01097d5:	56                   	push   %esi
f01097d6:	53                   	push   %ebx
f01097d7:	83 ec 7c             	sub    $0x7c,%esp
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01097da:	8b 45 08             	mov    0x8(%ebp),%eax
f01097dd:	89 04 24             	mov    %eax,(%esp)
f01097e0:	e8 0a ff ff ff       	call   f01096ef <holding>
f01097e5:	85 c0                	test   %eax,%eax
f01097e7:	0f 85 02 01 00 00    	jne    f01098ef <spin_unlock+0x11e>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01097ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01097f0:	83 c0 0c             	add    $0xc,%eax
f01097f3:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01097fa:	00 
f01097fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01097ff:	8d 45 a4             	lea    -0x5c(%ebp),%eax
f0109802:	89 04 24             	mov    %eax,(%esp)
f0109805:	e8 69 f2 ff ff       	call   f0108a73 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010980a:	8b 45 08             	mov    0x8(%ebp),%eax
f010980d:	8b 40 08             	mov    0x8(%eax),%eax
f0109810:	0f b6 00             	movzbl (%eax),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0109813:	0f b6 f0             	movzbl %al,%esi
f0109816:	8b 45 08             	mov    0x8(%ebp),%eax
f0109819:	8b 58 04             	mov    0x4(%eax),%ebx
f010981c:	e8 ad fc ff ff       	call   f01094ce <cpunum>
f0109821:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0109825:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0109829:	89 44 24 04          	mov    %eax,0x4(%esp)
f010982d:	c7 04 24 1c b9 10 f0 	movl   $0xf010b91c,(%esp)
f0109834:	e8 15 b7 ff ff       	call   f0104f4e <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0109839:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0109840:	eb 7c                	jmp    f01098be <spin_unlock+0xed>
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0109842:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0109845:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0109849:	8d 55 cc             	lea    -0x34(%ebp),%edx
f010984c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0109850:	89 04 24             	mov    %eax,(%esp)
f0109853:	e8 e5 e3 ff ff       	call   f0107c3d <debuginfo_eip>
f0109858:	85 c0                	test   %eax,%eax
f010985a:	78 47                	js     f01098a3 <spin_unlock+0xd2>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010985c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010985f:	8b 54 85 a4          	mov    -0x5c(%ebp,%eax,4),%edx
f0109863:	8b 45 dc             	mov    -0x24(%ebp),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0109866:	89 d7                	mov    %edx,%edi
f0109868:	29 c7                	sub    %eax,%edi
f010986a:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010986d:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0109870:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0109873:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0109876:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0109879:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f010987d:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0109881:	89 74 24 14          	mov    %esi,0x14(%esp)
f0109885:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0109889:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010988d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0109891:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109895:	c7 04 24 52 b9 10 f0 	movl   $0xf010b952,(%esp)
f010989c:	e8 ad b6 ff ff       	call   f0104f4e <cprintf>
f01098a1:	eb 17                	jmp    f01098ba <spin_unlock+0xe9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01098a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01098a6:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f01098aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01098ae:	c7 04 24 69 b9 10 f0 	movl   $0xf010b969,(%esp)
f01098b5:	e8 94 b6 ff ff       	call   f0104f4e <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01098ba:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f01098be:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
f01098c2:	7f 0f                	jg     f01098d3 <spin_unlock+0x102>
f01098c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01098c7:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f01098cb:	85 c0                	test   %eax,%eax
f01098cd:	0f 85 6f ff ff ff    	jne    f0109842 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01098d3:	c7 44 24 08 71 b9 10 	movl   $0xf010b971,0x8(%esp)
f01098da:	f0 
f01098db:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01098e2:	00 
f01098e3:	c7 04 24 0a b9 10 f0 	movl   $0xf010b90a,(%esp)
f01098ea:	e8 e0 69 ff ff       	call   f01002cf <_panic>
	}

	lk->pcs[0] = 0;
f01098ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01098f2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	lk->cpu = 0;
f01098f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01098fc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	// But the 2007 Intel 64 Architecture Memory Ordering White
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
f0109903:	8b 45 08             	mov    0x8(%ebp),%eax
f0109906:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010990d:	00 
f010990e:	89 04 24             	mov    %eax,(%esp)
f0109911:	e8 4a fd ff ff       	call   f0109660 <xchg>
}
f0109916:	83 c4 7c             	add    $0x7c,%esp
f0109919:	5b                   	pop    %ebx
f010991a:	5e                   	pop    %esi
f010991b:	5f                   	pop    %edi
f010991c:	5d                   	pop    %ebp
f010991d:	c3                   	ret    
f010991e:	66 90                	xchg   %ax,%ax

f0109920 <__udivdi3>:
f0109920:	55                   	push   %ebp
f0109921:	57                   	push   %edi
f0109922:	56                   	push   %esi
f0109923:	83 ec 0c             	sub    $0xc,%esp
f0109926:	8b 44 24 28          	mov    0x28(%esp),%eax
f010992a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010992e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0109932:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0109936:	85 c0                	test   %eax,%eax
f0109938:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010993c:	89 ea                	mov    %ebp,%edx
f010993e:	89 0c 24             	mov    %ecx,(%esp)
f0109941:	75 2d                	jne    f0109970 <__udivdi3+0x50>
f0109943:	39 e9                	cmp    %ebp,%ecx
f0109945:	77 61                	ja     f01099a8 <__udivdi3+0x88>
f0109947:	85 c9                	test   %ecx,%ecx
f0109949:	89 ce                	mov    %ecx,%esi
f010994b:	75 0b                	jne    f0109958 <__udivdi3+0x38>
f010994d:	b8 01 00 00 00       	mov    $0x1,%eax
f0109952:	31 d2                	xor    %edx,%edx
f0109954:	f7 f1                	div    %ecx
f0109956:	89 c6                	mov    %eax,%esi
f0109958:	31 d2                	xor    %edx,%edx
f010995a:	89 e8                	mov    %ebp,%eax
f010995c:	f7 f6                	div    %esi
f010995e:	89 c5                	mov    %eax,%ebp
f0109960:	89 f8                	mov    %edi,%eax
f0109962:	f7 f6                	div    %esi
f0109964:	89 ea                	mov    %ebp,%edx
f0109966:	83 c4 0c             	add    $0xc,%esp
f0109969:	5e                   	pop    %esi
f010996a:	5f                   	pop    %edi
f010996b:	5d                   	pop    %ebp
f010996c:	c3                   	ret    
f010996d:	8d 76 00             	lea    0x0(%esi),%esi
f0109970:	39 e8                	cmp    %ebp,%eax
f0109972:	77 24                	ja     f0109998 <__udivdi3+0x78>
f0109974:	0f bd e8             	bsr    %eax,%ebp
f0109977:	83 f5 1f             	xor    $0x1f,%ebp
f010997a:	75 3c                	jne    f01099b8 <__udivdi3+0x98>
f010997c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0109980:	39 34 24             	cmp    %esi,(%esp)
f0109983:	0f 86 9f 00 00 00    	jbe    f0109a28 <__udivdi3+0x108>
f0109989:	39 d0                	cmp    %edx,%eax
f010998b:	0f 82 97 00 00 00    	jb     f0109a28 <__udivdi3+0x108>
f0109991:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0109998:	31 d2                	xor    %edx,%edx
f010999a:	31 c0                	xor    %eax,%eax
f010999c:	83 c4 0c             	add    $0xc,%esp
f010999f:	5e                   	pop    %esi
f01099a0:	5f                   	pop    %edi
f01099a1:	5d                   	pop    %ebp
f01099a2:	c3                   	ret    
f01099a3:	90                   	nop
f01099a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01099a8:	89 f8                	mov    %edi,%eax
f01099aa:	f7 f1                	div    %ecx
f01099ac:	31 d2                	xor    %edx,%edx
f01099ae:	83 c4 0c             	add    $0xc,%esp
f01099b1:	5e                   	pop    %esi
f01099b2:	5f                   	pop    %edi
f01099b3:	5d                   	pop    %ebp
f01099b4:	c3                   	ret    
f01099b5:	8d 76 00             	lea    0x0(%esi),%esi
f01099b8:	89 e9                	mov    %ebp,%ecx
f01099ba:	8b 3c 24             	mov    (%esp),%edi
f01099bd:	d3 e0                	shl    %cl,%eax
f01099bf:	89 c6                	mov    %eax,%esi
f01099c1:	b8 20 00 00 00       	mov    $0x20,%eax
f01099c6:	29 e8                	sub    %ebp,%eax
f01099c8:	89 c1                	mov    %eax,%ecx
f01099ca:	d3 ef                	shr    %cl,%edi
f01099cc:	89 e9                	mov    %ebp,%ecx
f01099ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01099d2:	8b 3c 24             	mov    (%esp),%edi
f01099d5:	09 74 24 08          	or     %esi,0x8(%esp)
f01099d9:	89 d6                	mov    %edx,%esi
f01099db:	d3 e7                	shl    %cl,%edi
f01099dd:	89 c1                	mov    %eax,%ecx
f01099df:	89 3c 24             	mov    %edi,(%esp)
f01099e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01099e6:	d3 ee                	shr    %cl,%esi
f01099e8:	89 e9                	mov    %ebp,%ecx
f01099ea:	d3 e2                	shl    %cl,%edx
f01099ec:	89 c1                	mov    %eax,%ecx
f01099ee:	d3 ef                	shr    %cl,%edi
f01099f0:	09 d7                	or     %edx,%edi
f01099f2:	89 f2                	mov    %esi,%edx
f01099f4:	89 f8                	mov    %edi,%eax
f01099f6:	f7 74 24 08          	divl   0x8(%esp)
f01099fa:	89 d6                	mov    %edx,%esi
f01099fc:	89 c7                	mov    %eax,%edi
f01099fe:	f7 24 24             	mull   (%esp)
f0109a01:	39 d6                	cmp    %edx,%esi
f0109a03:	89 14 24             	mov    %edx,(%esp)
f0109a06:	72 30                	jb     f0109a38 <__udivdi3+0x118>
f0109a08:	8b 54 24 04          	mov    0x4(%esp),%edx
f0109a0c:	89 e9                	mov    %ebp,%ecx
f0109a0e:	d3 e2                	shl    %cl,%edx
f0109a10:	39 c2                	cmp    %eax,%edx
f0109a12:	73 05                	jae    f0109a19 <__udivdi3+0xf9>
f0109a14:	3b 34 24             	cmp    (%esp),%esi
f0109a17:	74 1f                	je     f0109a38 <__udivdi3+0x118>
f0109a19:	89 f8                	mov    %edi,%eax
f0109a1b:	31 d2                	xor    %edx,%edx
f0109a1d:	e9 7a ff ff ff       	jmp    f010999c <__udivdi3+0x7c>
f0109a22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0109a28:	31 d2                	xor    %edx,%edx
f0109a2a:	b8 01 00 00 00       	mov    $0x1,%eax
f0109a2f:	e9 68 ff ff ff       	jmp    f010999c <__udivdi3+0x7c>
f0109a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109a38:	8d 47 ff             	lea    -0x1(%edi),%eax
f0109a3b:	31 d2                	xor    %edx,%edx
f0109a3d:	83 c4 0c             	add    $0xc,%esp
f0109a40:	5e                   	pop    %esi
f0109a41:	5f                   	pop    %edi
f0109a42:	5d                   	pop    %ebp
f0109a43:	c3                   	ret    
f0109a44:	66 90                	xchg   %ax,%ax
f0109a46:	66 90                	xchg   %ax,%ax
f0109a48:	66 90                	xchg   %ax,%ax
f0109a4a:	66 90                	xchg   %ax,%ax
f0109a4c:	66 90                	xchg   %ax,%ax
f0109a4e:	66 90                	xchg   %ax,%ax

f0109a50 <__umoddi3>:
f0109a50:	55                   	push   %ebp
f0109a51:	57                   	push   %edi
f0109a52:	56                   	push   %esi
f0109a53:	83 ec 14             	sub    $0x14,%esp
f0109a56:	8b 44 24 28          	mov    0x28(%esp),%eax
f0109a5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0109a5e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0109a62:	89 c7                	mov    %eax,%edi
f0109a64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109a68:	8b 44 24 30          	mov    0x30(%esp),%eax
f0109a6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0109a70:	89 34 24             	mov    %esi,(%esp)
f0109a73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0109a77:	85 c0                	test   %eax,%eax
f0109a79:	89 c2                	mov    %eax,%edx
f0109a7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0109a7f:	75 17                	jne    f0109a98 <__umoddi3+0x48>
f0109a81:	39 fe                	cmp    %edi,%esi
f0109a83:	76 4b                	jbe    f0109ad0 <__umoddi3+0x80>
f0109a85:	89 c8                	mov    %ecx,%eax
f0109a87:	89 fa                	mov    %edi,%edx
f0109a89:	f7 f6                	div    %esi
f0109a8b:	89 d0                	mov    %edx,%eax
f0109a8d:	31 d2                	xor    %edx,%edx
f0109a8f:	83 c4 14             	add    $0x14,%esp
f0109a92:	5e                   	pop    %esi
f0109a93:	5f                   	pop    %edi
f0109a94:	5d                   	pop    %ebp
f0109a95:	c3                   	ret    
f0109a96:	66 90                	xchg   %ax,%ax
f0109a98:	39 f8                	cmp    %edi,%eax
f0109a9a:	77 54                	ja     f0109af0 <__umoddi3+0xa0>
f0109a9c:	0f bd e8             	bsr    %eax,%ebp
f0109a9f:	83 f5 1f             	xor    $0x1f,%ebp
f0109aa2:	75 5c                	jne    f0109b00 <__umoddi3+0xb0>
f0109aa4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0109aa8:	39 3c 24             	cmp    %edi,(%esp)
f0109aab:	0f 87 e7 00 00 00    	ja     f0109b98 <__umoddi3+0x148>
f0109ab1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109ab5:	29 f1                	sub    %esi,%ecx
f0109ab7:	19 c7                	sbb    %eax,%edi
f0109ab9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0109abd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0109ac1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0109ac5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0109ac9:	83 c4 14             	add    $0x14,%esp
f0109acc:	5e                   	pop    %esi
f0109acd:	5f                   	pop    %edi
f0109ace:	5d                   	pop    %ebp
f0109acf:	c3                   	ret    
f0109ad0:	85 f6                	test   %esi,%esi
f0109ad2:	89 f5                	mov    %esi,%ebp
f0109ad4:	75 0b                	jne    f0109ae1 <__umoddi3+0x91>
f0109ad6:	b8 01 00 00 00       	mov    $0x1,%eax
f0109adb:	31 d2                	xor    %edx,%edx
f0109add:	f7 f6                	div    %esi
f0109adf:	89 c5                	mov    %eax,%ebp
f0109ae1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0109ae5:	31 d2                	xor    %edx,%edx
f0109ae7:	f7 f5                	div    %ebp
f0109ae9:	89 c8                	mov    %ecx,%eax
f0109aeb:	f7 f5                	div    %ebp
f0109aed:	eb 9c                	jmp    f0109a8b <__umoddi3+0x3b>
f0109aef:	90                   	nop
f0109af0:	89 c8                	mov    %ecx,%eax
f0109af2:	89 fa                	mov    %edi,%edx
f0109af4:	83 c4 14             	add    $0x14,%esp
f0109af7:	5e                   	pop    %esi
f0109af8:	5f                   	pop    %edi
f0109af9:	5d                   	pop    %ebp
f0109afa:	c3                   	ret    
f0109afb:	90                   	nop
f0109afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109b00:	8b 04 24             	mov    (%esp),%eax
f0109b03:	be 20 00 00 00       	mov    $0x20,%esi
f0109b08:	89 e9                	mov    %ebp,%ecx
f0109b0a:	29 ee                	sub    %ebp,%esi
f0109b0c:	d3 e2                	shl    %cl,%edx
f0109b0e:	89 f1                	mov    %esi,%ecx
f0109b10:	d3 e8                	shr    %cl,%eax
f0109b12:	89 e9                	mov    %ebp,%ecx
f0109b14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109b18:	8b 04 24             	mov    (%esp),%eax
f0109b1b:	09 54 24 04          	or     %edx,0x4(%esp)
f0109b1f:	89 fa                	mov    %edi,%edx
f0109b21:	d3 e0                	shl    %cl,%eax
f0109b23:	89 f1                	mov    %esi,%ecx
f0109b25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109b29:	8b 44 24 10          	mov    0x10(%esp),%eax
f0109b2d:	d3 ea                	shr    %cl,%edx
f0109b2f:	89 e9                	mov    %ebp,%ecx
f0109b31:	d3 e7                	shl    %cl,%edi
f0109b33:	89 f1                	mov    %esi,%ecx
f0109b35:	d3 e8                	shr    %cl,%eax
f0109b37:	89 e9                	mov    %ebp,%ecx
f0109b39:	09 f8                	or     %edi,%eax
f0109b3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0109b3f:	f7 74 24 04          	divl   0x4(%esp)
f0109b43:	d3 e7                	shl    %cl,%edi
f0109b45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0109b49:	89 d7                	mov    %edx,%edi
f0109b4b:	f7 64 24 08          	mull   0x8(%esp)
f0109b4f:	39 d7                	cmp    %edx,%edi
f0109b51:	89 c1                	mov    %eax,%ecx
f0109b53:	89 14 24             	mov    %edx,(%esp)
f0109b56:	72 2c                	jb     f0109b84 <__umoddi3+0x134>
f0109b58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0109b5c:	72 22                	jb     f0109b80 <__umoddi3+0x130>
f0109b5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0109b62:	29 c8                	sub    %ecx,%eax
f0109b64:	19 d7                	sbb    %edx,%edi
f0109b66:	89 e9                	mov    %ebp,%ecx
f0109b68:	89 fa                	mov    %edi,%edx
f0109b6a:	d3 e8                	shr    %cl,%eax
f0109b6c:	89 f1                	mov    %esi,%ecx
f0109b6e:	d3 e2                	shl    %cl,%edx
f0109b70:	89 e9                	mov    %ebp,%ecx
f0109b72:	d3 ef                	shr    %cl,%edi
f0109b74:	09 d0                	or     %edx,%eax
f0109b76:	89 fa                	mov    %edi,%edx
f0109b78:	83 c4 14             	add    $0x14,%esp
f0109b7b:	5e                   	pop    %esi
f0109b7c:	5f                   	pop    %edi
f0109b7d:	5d                   	pop    %ebp
f0109b7e:	c3                   	ret    
f0109b7f:	90                   	nop
f0109b80:	39 d7                	cmp    %edx,%edi
f0109b82:	75 da                	jne    f0109b5e <__umoddi3+0x10e>
f0109b84:	8b 14 24             	mov    (%esp),%edx
f0109b87:	89 c1                	mov    %eax,%ecx
f0109b89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0109b8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0109b91:	eb cb                	jmp    f0109b5e <__umoddi3+0x10e>
f0109b93:	90                   	nop
f0109b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109b98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0109b9c:	0f 82 0f ff ff ff    	jb     f0109ab1 <__umoddi3+0x61>
f0109ba2:	e9 1a ff ff ff       	jmp    f0109ac1 <__umoddi3+0x71>
