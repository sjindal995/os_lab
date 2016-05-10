
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
f0100015:	b8 00 50 12 00       	mov    $0x125000,%eax
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
f0100034:	bc 00 40 12 f0       	mov    $0xf0124000,%esp

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
f0100057:	c7 44 24 08 60 99 10 	movl   $0xf0109960,0x8(%esp)
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
f0100089:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f010008e:	39 c2                	cmp    %eax,%edx
f0100090:	72 21                	jb     f01000b3 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100092:	8b 45 10             	mov    0x10(%ebp),%eax
f0100095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100099:	c7 44 24 08 84 99 10 	movl   $0xf0109984,0x8(%esp)
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
f01000dd:	c7 04 24 e0 65 12 f0 	movl   $0xf01265e0,(%esp)
f01000e4:	e8 04 94 00 00       	call   f01094ed <spin_lock>
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
f01000f1:	ba 08 80 2d f0       	mov    $0xf02d8008,%edx
f01000f6:	b8 d3 2e 29 f0       	mov    $0xf0292ed3,%eax
f01000fb:	29 c2                	sub    %eax,%edx
f01000fd:	89 d0                	mov    %edx,%eax
f01000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100103:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010010a:	00 
f010010b:	c7 04 24 d3 2e 29 f0 	movl   $0xf0292ed3,(%esp)
f0100112:	e8 90 86 00 00       	call   f01087a7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100117:	e8 53 0a 00 00       	call   f0100b6f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010011c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100123:	00 
f0100124:	c7 04 24 a7 99 10 f0 	movl   $0xf01099a7,(%esp)
f010012b:	e8 1c 4e 00 00       	call   f0104f4c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100130:	e8 21 13 00 00       	call   f0101456 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 e2 42 00 00       	call   f010441c <env_init>
	trap_init();
f010013a:	e8 9f 4e 00 00       	call   f0104fde <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010013f:	e8 55 8d 00 00       	call   f0108e99 <mp_init>
	lapic_init();
f0100144:	e8 9f 8f 00 00       	call   f01090e8 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100149:	e8 bc 4b 00 00       	call   f0104d0a <pic_init>

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
f0100160:	c7 04 24 5e 4f 27 f0 	movl   $0xf0274f5e,(%esp)
f0100167:	e8 93 47 00 00       	call   f01048ff <env_create>
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010016c:	e8 1c 65 00 00       	call   f010668d <sched_yield>

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
f0100187:	c7 04 24 c2 99 10 f0 	movl   $0xf01099c2,(%esp)
f010018e:	e8 e8 fe ff ff       	call   f010007b <_kaddr>
f0100193:	89 45 f0             	mov    %eax,-0x10(%ebp)
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100196:	ba 76 8b 10 f0       	mov    $0xf0108b76,%edx
f010019b:	b8 fc 8a 10 f0       	mov    $0xf0108afc,%eax
f01001a0:	29 c2                	sub    %eax,%edx
f01001a2:	89 d0                	mov    %edx,%eax
f01001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001a8:	c7 44 24 04 fc 8a 10 	movl   $0xf0108afc,0x4(%esp)
f01001af:	f0 
f01001b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01001b3:	89 04 24             	mov    %eax,(%esp)
f01001b6:	e8 5a 86 00 00       	call   f0108815 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001bb:	c7 45 f4 20 70 29 f0 	movl   $0xf0297020,-0xc(%ebp)
f01001c2:	eb 79                	jmp    f010023d <boot_aps+0xcc>
		if (c == cpus + cpunum())  // We've started already.
f01001c4:	e8 a9 90 00 00       	call   f0109272 <cpunum>
f01001c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01001cc:	05 20 70 29 f0       	add    $0xf0297020,%eax
f01001d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01001d4:	75 02                	jne    f01001d8 <boot_aps+0x67>
			continue;
f01001d6:	eb 61                	jmp    f0100239 <boot_aps+0xc8>

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01001db:	b8 20 70 29 f0       	mov    $0xf0297020,%eax
f01001e0:	29 c2                	sub    %eax,%edx
f01001e2:	89 d0                	mov    %edx,%eax
f01001e4:	c1 f8 02             	sar    $0x2,%eax
f01001e7:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001ed:	83 c0 01             	add    $0x1,%eax
f01001f0:	c1 e0 0f             	shl    $0xf,%eax
f01001f3:	05 00 80 29 f0       	add    $0xf0298000,%eax
f01001f8:	a3 e4 6a 29 f0       	mov    %eax,0xf0296ae4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100200:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100204:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f010020b:	00 
f010020c:	c7 04 24 c2 99 10 f0 	movl   $0xf01099c2,(%esp)
f0100213:	e8 28 fe ff ff       	call   f0100040 <_paddr>
f0100218:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010021b:	0f b6 12             	movzbl (%edx),%edx
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	89 14 24             	mov    %edx,(%esp)
f0100228:	e8 91 90 00 00       	call   f01092be <lapic_startap>
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
f010023d:	a1 c4 73 29 f0       	mov    0xf02973c4,%eax
f0100242:	6b c0 74             	imul   $0x74,%eax,%eax
f0100245:	05 20 70 29 f0       	add    $0xf0297020,%eax
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
f010025b:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0100260:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100264:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f010026b:	00 
f010026c:	c7 04 24 c2 99 10 f0 	movl   $0xf01099c2,(%esp)
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
f0100281:	e8 ec 8f 00 00       	call   f0109272 <cpunum>
f0100286:	89 44 24 04          	mov    %eax,0x4(%esp)
f010028a:	c7 04 24 ce 99 10 f0 	movl   $0xf01099ce,(%esp)
f0100291:	e8 b6 4c 00 00       	call   f0104f4c <cprintf>

	lapic_init();
f0100296:	e8 4d 8e 00 00       	call   f01090e8 <lapic_init>
	env_init_percpu();
f010029b:	e8 f5 41 00 00       	call   f0104495 <env_init_percpu>
	trap_init_percpu();
f01002a0:	e8 2e 59 00 00       	call   f0105bd3 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002a5:	e8 c8 8f 00 00       	call   f0109272 <cpunum>
f01002aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01002ad:	05 20 70 29 f0       	add    $0xf0297020,%eax
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
f01002ca:	e8 be 63 00 00       	call   f010668d <sched_yield>

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
f01002d5:	a1 e0 6a 29 f0       	mov    0xf0296ae0,%eax
f01002da:	85 c0                	test   %eax,%eax
f01002dc:	74 02                	je     f01002e0 <_panic+0x11>
		goto dead;
f01002de:	eb 51                	jmp    f0100331 <_panic+0x62>
	panicstr = fmt;
f01002e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01002e3:	a3 e0 6a 29 f0       	mov    %eax,0xf0296ae0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01002e8:	fa                   	cli    
f01002e9:	fc                   	cld    

	va_start(ap, fmt);
f01002ea:	8d 45 14             	lea    0x14(%ebp),%eax
f01002ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01002f0:	e8 7d 8f 00 00       	call   f0109272 <cpunum>
f01002f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01002f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01002fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01002ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100303:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100307:	c7 04 24 e4 99 10 f0 	movl   $0xf01099e4,(%esp)
f010030e:	e8 39 4c 00 00       	call   f0104f4c <cprintf>
	vcprintf(fmt, ap);
f0100313:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100316:	89 44 24 04          	mov    %eax,0x4(%esp)
f010031a:	8b 45 10             	mov    0x10(%ebp),%eax
f010031d:	89 04 24             	mov    %eax,(%esp)
f0100320:	e8 f4 4b 00 00       	call   f0104f19 <vcprintf>
	cprintf("\n");
f0100325:	c7 04 24 06 9a 10 f0 	movl   $0xf0109a06,(%esp)
f010032c:	e8 1b 4c 00 00       	call   f0104f4c <cprintf>
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
f0100359:	c7 04 24 08 9a 10 f0 	movl   $0xf0109a08,(%esp)
f0100360:	e8 e7 4b 00 00       	call   f0104f4c <cprintf>
	vcprintf(fmt, ap);
f0100365:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100368:	89 44 24 04          	mov    %eax,0x4(%esp)
f010036c:	8b 45 10             	mov    0x10(%ebp),%eax
f010036f:	89 04 24             	mov    %eax,(%esp)
f0100372:	e8 a2 4b 00 00       	call   f0104f19 <vcprintf>
	cprintf("\n");
f0100377:	c7 04 24 06 9a 10 f0 	movl   $0xf0109a06,(%esp)
f010037e:	e8 c9 4b 00 00       	call   f0104f4c <cprintf>
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
f0100417:	0f b6 05 00 30 29 f0 	movzbl 0xf0293000,%eax
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
f010052d:	a2 00 30 29 f0       	mov    %al,0xf0293000
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
f01005ff:	c7 05 04 30 29 f0 b4 	movl   $0x3b4,0xf0293004
f0100606:	03 00 00 
f0100609:	eb 14                	jmp    f010061f <cga_init+0x52>
	} else {
		*cp = was;
f010060b:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010060e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
f0100612:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
f0100615:	c7 05 04 30 29 f0 d4 	movl   $0x3d4,0xf0293004
f010061c:	03 00 00 
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010061f:	a1 04 30 29 f0       	mov    0xf0293004,%eax
f0100624:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100627:	c6 45 ef 0e          	movb   $0xe,-0x11(%ebp)
f010062b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f010062f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100632:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100633:	a1 04 30 29 f0       	mov    0xf0293004,%eax
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
f0100654:	a1 04 30 29 f0       	mov    0xf0293004,%eax
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
f0100668:	a1 04 30 29 f0       	mov    0xf0293004,%eax
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
f0100689:	a3 08 30 29 f0       	mov    %eax,0xf0293008
	crt_pos = pos;
f010068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100691:	66 a3 0c 30 29 f0    	mov    %ax,0xf029300c
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
f01006dd:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f01006e4:	66 85 c0             	test   %ax,%ax
f01006e7:	74 33                	je     f010071c <cga_putc+0x83>
			crt_pos--;
f01006e9:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f01006f0:	83 e8 01             	sub    $0x1,%eax
f01006f3:	66 a3 0c 30 29 f0    	mov    %ax,0xf029300c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01006f9:	a1 08 30 29 f0       	mov    0xf0293008,%eax
f01006fe:	0f b7 15 0c 30 29 f0 	movzwl 0xf029300c,%edx
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
f0100721:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f0100728:	83 c0 50             	add    $0x50,%eax
f010072b:	66 a3 0c 30 29 f0    	mov    %ax,0xf029300c
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100731:	0f b7 1d 0c 30 29 f0 	movzwl 0xf029300c,%ebx
f0100738:	0f b7 0d 0c 30 29 f0 	movzwl 0xf029300c,%ecx
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
f0100763:	66 a3 0c 30 29 f0    	mov    %ax,0xf029300c
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
f01007a9:	8b 0d 08 30 29 f0    	mov    0xf0293008,%ecx
f01007af:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f01007b6:	8d 50 01             	lea    0x1(%eax),%edx
f01007b9:	66 89 15 0c 30 29 f0 	mov    %dx,0xf029300c
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
f01007cf:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f01007d6:	66 3d cf 07          	cmp    $0x7cf,%ax
f01007da:	76 5b                	jbe    f0100837 <cga_putc+0x19e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01007dc:	a1 08 30 29 f0       	mov    0xf0293008,%eax
f01007e1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01007e7:	a1 08 30 29 f0       	mov    0xf0293008,%eax
f01007ec:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01007f3:	00 
f01007f4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01007f8:	89 04 24             	mov    %eax,(%esp)
f01007fb:	e8 15 80 00 00       	call   f0108815 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100800:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f0100807:	eb 15                	jmp    f010081e <cga_putc+0x185>
			crt_buf[i] = 0x0700 | ' ';
f0100809:	a1 08 30 29 f0       	mov    0xf0293008,%eax
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
f0100827:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f010082e:	83 e8 50             	sub    $0x50,%eax
f0100831:	66 a3 0c 30 29 f0    	mov    %ax,0xf029300c
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100837:	a1 04 30 29 f0       	mov    0xf0293004,%eax
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
f010084b:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f0100852:	66 c1 e8 08          	shr    $0x8,%ax
f0100856:	0f b6 c0             	movzbl %al,%eax
f0100859:	8b 15 04 30 29 f0    	mov    0xf0293004,%edx
f010085f:	83 c2 01             	add    $0x1,%edx
f0100862:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100865:	88 45 e7             	mov    %al,-0x19(%ebp)
f0100868:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010086c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010086f:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100870:	a1 04 30 29 f0       	mov    0xf0293004,%eax
f0100875:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100878:	c6 45 df 0f          	movb   $0xf,-0x21(%ebp)
f010087c:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f0100880:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100883:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f0100884:	0f b7 05 0c 30 29 f0 	movzwl 0xf029300c,%eax
f010088b:	0f b6 c0             	movzbl %al,%eax
f010088e:	8b 15 04 30 29 f0    	mov    0xf0293004,%edx
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
f01008f6:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f01008fb:	83 c8 40             	or     $0x40,%eax
f01008fe:	a3 28 32 29 f0       	mov    %eax,0xf0293228
		return 0;
f0100903:	b8 00 00 00 00       	mov    $0x0,%eax
f0100908:	e9 25 01 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
	} else if (data & 0x80) {
f010090d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100911:	84 c0                	test   %al,%al
f0100913:	79 47                	jns    f010095c <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100915:	a1 28 32 29 f0       	mov    0xf0293228,%eax
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
f0100935:	0f b6 80 00 60 12 f0 	movzbl -0xfeda000(%eax),%eax
f010093c:	83 c8 40             	or     $0x40,%eax
f010093f:	0f b6 c0             	movzbl %al,%eax
f0100942:	f7 d0                	not    %eax
f0100944:	89 c2                	mov    %eax,%edx
f0100946:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f010094b:	21 d0                	and    %edx,%eax
f010094d:	a3 28 32 29 f0       	mov    %eax,0xf0293228
		return 0;
f0100952:	b8 00 00 00 00       	mov    $0x0,%eax
f0100957:	e9 d6 00 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
	} else if (shift & E0ESC) {
f010095c:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f0100961:	83 e0 40             	and    $0x40,%eax
f0100964:	85 c0                	test   %eax,%eax
f0100966:	74 11                	je     f0100979 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100968:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f010096c:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f0100971:	83 e0 bf             	and    $0xffffffbf,%eax
f0100974:	a3 28 32 29 f0       	mov    %eax,0xf0293228
	}

	shift |= shiftcode[data];
f0100979:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010097d:	0f b6 80 00 60 12 f0 	movzbl -0xfeda000(%eax),%eax
f0100984:	0f b6 d0             	movzbl %al,%edx
f0100987:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f010098c:	09 d0                	or     %edx,%eax
f010098e:	a3 28 32 29 f0       	mov    %eax,0xf0293228
	shift ^= togglecode[data];
f0100993:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100997:	0f b6 80 00 61 12 f0 	movzbl -0xfed9f00(%eax),%eax
f010099e:	0f b6 d0             	movzbl %al,%edx
f01009a1:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f01009a6:	31 d0                	xor    %edx,%eax
f01009a8:	a3 28 32 29 f0       	mov    %eax,0xf0293228

	c = charcode[shift & (CTL | SHIFT)][data];
f01009ad:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f01009b2:	83 e0 03             	and    $0x3,%eax
f01009b5:	8b 14 85 00 65 12 f0 	mov    -0xfed9b00(,%eax,4),%edx
f01009bc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01009c0:	01 d0                	add    %edx,%eax
f01009c2:	0f b6 00             	movzbl (%eax),%eax
f01009c5:	0f b6 c0             	movzbl %al,%eax
f01009c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f01009cb:	a1 28 32 29 f0       	mov    0xf0293228,%eax
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
f01009f9:	a1 28 32 29 f0       	mov    0xf0293228,%eax
f01009fe:	f7 d0                	not    %eax
f0100a00:	83 e0 06             	and    $0x6,%eax
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	75 28                	jne    f0100a2f <kbd_proc_data+0x184>
f0100a07:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f0100a0e:	75 1f                	jne    f0100a2f <kbd_proc_data+0x184>
		cprintf("Rebooting!\n");
f0100a10:	c7 04 24 22 9a 10 f0 	movl   $0xf0109a22,(%esp)
f0100a17:	e8 30 45 00 00       	call   f0104f4c <cprintf>
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
f0100a53:	0f b7 05 ce 65 12 f0 	movzwl 0xf01265ce,%eax
f0100a5a:	0f b7 c0             	movzwl %ax,%eax
f0100a5d:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100a62:	89 04 24             	mov    %eax,(%esp)
f0100a65:	e8 db 43 00 00       	call   f0104e45 <irq_setmask_8259A>
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
f0100a7c:	a1 24 32 29 f0       	mov    0xf0293224,%eax
f0100a81:	8d 50 01             	lea    0x1(%eax),%edx
f0100a84:	89 15 24 32 29 f0    	mov    %edx,0xf0293224
f0100a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100a8d:	88 90 20 30 29 f0    	mov    %dl,-0xfd6cfe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100a93:	a1 24 32 29 f0       	mov    0xf0293224,%eax
f0100a98:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100a9d:	75 0a                	jne    f0100aa9 <cons_intr+0x3d>
			cons.wpos = 0;
f0100a9f:	c7 05 24 32 29 f0 00 	movl   $0x0,0xf0293224
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
f0100ac9:	8b 15 20 32 29 f0    	mov    0xf0293220,%edx
f0100acf:	a1 24 32 29 f0       	mov    0xf0293224,%eax
f0100ad4:	39 c2                	cmp    %eax,%edx
f0100ad6:	74 36                	je     f0100b0e <cons_getc+0x55>
		c = cons.buf[cons.rpos++];
f0100ad8:	a1 20 32 29 f0       	mov    0xf0293220,%eax
f0100add:	8d 50 01             	lea    0x1(%eax),%edx
f0100ae0:	89 15 20 32 29 f0    	mov    %edx,0xf0293220
f0100ae6:	0f b6 80 20 30 29 f0 	movzbl -0xfd6cfe0(%eax),%eax
f0100aed:	0f b6 c0             	movzbl %al,%eax
f0100af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f0100af3:	a1 20 32 29 f0       	mov    0xf0293220,%eax
f0100af8:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100afd:	75 0a                	jne    f0100b09 <cons_getc+0x50>
			cons.rpos = 0;
f0100aff:	c7 05 20 32 29 f0 00 	movl   $0x0,0xf0293220
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
f0100b84:	0f b6 05 00 30 29 f0 	movzbl 0xf0293000,%eax
f0100b8b:	83 f0 01             	xor    $0x1,%eax
f0100b8e:	84 c0                	test   %al,%al
f0100b90:	74 0c                	je     f0100b9e <cons_init+0x2f>
		cprintf("Serial port does not exist!\n");
f0100b92:	c7 04 24 2e 9a 10 f0 	movl   $0xf0109a2e,(%esp)
f0100b99:	e8 ae 43 00 00       	call   f0104f4c <cprintf>
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
f0100be2:	c7 04 24 1a 9b 10 f0 	movl   $0xf0109b1a,(%esp)
f0100be9:	e8 5e 43 00 00       	call   f0104f4c <cprintf>
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
f0100c15:	c7 04 24 2c 9b 10 f0 	movl   $0xf0109b2c,(%esp)
f0100c1c:	e8 2b 43 00 00       	call   f0104f4c <cprintf>
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
f0100c4c:	c7 04 24 1a 9b 10 f0 	movl   $0xf0109b1a,(%esp)
f0100c53:	e8 f4 42 00 00       	call   f0104f4c <cprintf>
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
f0100c7f:	c7 04 24 2c 9b 10 f0 	movl   $0xf0109b2c,(%esp)
f0100c86:	e8 c1 42 00 00       	call   f0104f4c <cprintf>
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
f0100cc5:	05 20 65 12 f0       	add    $0xf0126520,%eax
f0100cca:	8b 48 04             	mov    0x4(%eax),%ecx
f0100ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100cd0:	89 d0                	mov    %edx,%eax
f0100cd2:	01 c0                	add    %eax,%eax
f0100cd4:	01 d0                	add    %edx,%eax
f0100cd6:	c1 e0 02             	shl    $0x2,%eax
f0100cd9:	05 20 65 12 f0       	add    $0xf0126520,%eax
f0100cde:	8b 00                	mov    (%eax),%eax
f0100ce0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce8:	c7 04 24 64 9b 10 f0 	movl   $0xf0109b64,(%esp)
f0100cef:	e8 58 42 00 00       	call   f0104f4c <cprintf>
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
f0100d0d:	c7 04 24 6d 9b 10 f0 	movl   $0xf0109b6d,(%esp)
f0100d14:	e8 33 42 00 00       	call   f0104f4c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100d19:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100d20:	00 
f0100d21:	c7 04 24 88 9b 10 f0 	movl   $0xf0109b88,(%esp)
f0100d28:	e8 1f 42 00 00       	call   f0104f4c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100d2d:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100d34:	00 
f0100d35:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100d3c:	f0 
f0100d3d:	c7 04 24 b0 9b 10 f0 	movl   $0xf0109bb0,(%esp)
f0100d44:	e8 03 42 00 00       	call   f0104f4c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100d49:	c7 44 24 08 57 99 10 	movl   $0x109957,0x8(%esp)
f0100d50:	00 
f0100d51:	c7 44 24 04 57 99 10 	movl   $0xf0109957,0x4(%esp)
f0100d58:	f0 
f0100d59:	c7 04 24 d4 9b 10 f0 	movl   $0xf0109bd4,(%esp)
f0100d60:	e8 e7 41 00 00       	call   f0104f4c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100d65:	c7 44 24 08 d3 2e 29 	movl   $0x292ed3,0x8(%esp)
f0100d6c:	00 
f0100d6d:	c7 44 24 04 d3 2e 29 	movl   $0xf0292ed3,0x4(%esp)
f0100d74:	f0 
f0100d75:	c7 04 24 f8 9b 10 f0 	movl   $0xf0109bf8,(%esp)
f0100d7c:	e8 cb 41 00 00       	call   f0104f4c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100d81:	c7 44 24 08 08 80 2d 	movl   $0x2d8008,0x8(%esp)
f0100d88:	00 
f0100d89:	c7 44 24 04 08 80 2d 	movl   $0xf02d8008,0x4(%esp)
f0100d90:	f0 
f0100d91:	c7 04 24 1c 9c 10 f0 	movl   $0xf0109c1c,(%esp)
f0100d98:	e8 af 41 00 00       	call   f0104f4c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100d9d:	c7 45 f4 00 04 00 00 	movl   $0x400,-0xc(%ebp)
f0100da4:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100dac:	29 c2                	sub    %eax,%edx
f0100dae:	b8 08 80 2d f0       	mov    $0xf02d8008,%eax
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
f0100de1:	c7 04 24 40 9c 10 f0 	movl   $0xf0109c40,(%esp)
f0100de8:	e8 5f 41 00 00       	call   f0104f4c <cprintf>
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
f0100e2f:	c7 04 24 6a 9c 10 f0 	movl   $0xf0109c6a,(%esp)
f0100e36:	e8 11 41 00 00       	call   f0104f4c <cprintf>

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
f0100e55:	c7 04 24 7c 9c 10 f0 	movl   $0xf0109c7c,(%esp)
f0100e5c:	e8 eb 40 00 00       	call   f0104f4c <cprintf>

	struct Eipdebuginfo eip_info;
	int eip_ret_info = debuginfo_eip(eip,&eip_info);
f0100e61:	8d 45 b8             	lea    -0x48(%ebp),%eax
f0100e64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e68:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e6b:	89 04 24             	mov    %eax,(%esp)
f0100e6e:	e8 6c 6b 00 00       	call   f01079df <debuginfo_eip>
f0100e73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(eip_ret_info == 0){
f0100e76:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100e7a:	75 6c                	jne    f0100ee8 <mon_backtrace+0xc2>
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
f0100e7c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100e7f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100e82:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e8a:	c7 04 24 90 9c 10 f0 	movl   $0xf0109c90,(%esp)
f0100e91:	e8 b6 40 00 00       	call   f0104f4c <cprintf>
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
f0100eb1:	c7 04 24 99 9c 10 f0 	movl   $0xf0109c99,(%esp)
f0100eb8:	e8 8f 40 00 00       	call   f0104f4c <cprintf>
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
f0100ed7:	c7 04 24 9c 9c 10 f0 	movl   $0xf0109c9c,(%esp)
f0100ede:	e8 69 40 00 00       	call   f0104f4c <cprintf>
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
f0100f3c:	c7 04 24 a4 9c 10 f0 	movl   $0xf0109ca4,(%esp)
f0100f43:	e8 04 40 00 00       	call   f0104f4c <cprintf>
		eip = *(ebp+1);
f0100f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4b:	8b 40 04             	mov    0x4(%eax),%eax
f0100f4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		eip_ret_info = debuginfo_eip(eip,&eip_info);
f0100f51:	8d 45 b8             	lea    -0x48(%ebp),%eax
f0100f54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f58:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f5b:	89 04 24             	mov    %eax,(%esp)
f0100f5e:	e8 7c 6a 00 00       	call   f01079df <debuginfo_eip>
f0100f63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if(eip_ret_info == 0){
f0100f66:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f6a:	75 67                	jne    f0100fd3 <mon_backtrace+0x1ad>
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
f0100f6c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100f6f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100f72:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100f76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7a:	c7 04 24 90 9c 10 f0 	movl   $0xf0109c90,(%esp)
f0100f81:	e8 c6 3f 00 00       	call   f0104f4c <cprintf>
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
f0100fa1:	c7 04 24 99 9c 10 f0 	movl   $0xf0109c99,(%esp)
f0100fa8:	e8 9f 3f 00 00       	call   f0104f4c <cprintf>
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
f0100fc7:	c7 04 24 9c 9c 10 f0 	movl   $0xf0109c9c,(%esp)
f0100fce:	e8 79 3f 00 00       	call   f0104f4c <cprintf>
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
f010102f:	c7 04 24 d9 9c 10 f0 	movl   $0xf0109cd9,(%esp)
f0101036:	e8 0b 77 00 00       	call   f0108746 <strchr>
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
f010106b:	c7 04 24 de 9c 10 f0 	movl   $0xf0109cde,(%esp)
f0101072:	e8 d5 3e 00 00       	call   f0104f4c <cprintf>
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
f01010ae:	c7 04 24 d9 9c 10 f0 	movl   $0xf0109cd9,(%esp)
f01010b5:	e8 8c 76 00 00       	call   f0108746 <strchr>
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
f01010e0:	05 20 65 12 f0       	add    $0xf0126520,%eax
f01010e5:	8b 10                	mov    (%eax),%edx
f01010e7:	8b 45 b0             	mov    -0x50(%ebp),%eax
f01010ea:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010ee:	89 04 24             	mov    %eax,(%esp)
f01010f1:	e8 bb 75 00 00       	call   f01086b1 <strcmp>
f01010f6:	85 c0                	test   %eax,%eax
f01010f8:	75 2c                	jne    f0101126 <runcmd+0x134>
			return commands[i].func(argc, argv, tf);
f01010fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01010fd:	89 d0                	mov    %edx,%eax
f01010ff:	01 c0                	add    %eax,%eax
f0101101:	01 d0                	add    %edx,%eax
f0101103:	c1 e0 02             	shl    $0x2,%eax
f0101106:	05 20 65 12 f0       	add    $0xf0126520,%eax
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
f0101139:	c7 04 24 fb 9c 10 f0 	movl   $0xf0109cfb,(%esp)
f0101140:	e8 07 3e 00 00       	call   f0104f4c <cprintf>
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
f0101152:	c7 04 24 14 9d 10 f0 	movl   $0xf0109d14,(%esp)
f0101159:	e8 ee 3d 00 00       	call   f0104f4c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010115e:	c7 04 24 38 9d 10 f0 	movl   $0xf0109d38,(%esp)
f0101165:	e8 e2 3d 00 00       	call   f0104f4c <cprintf>

	if (tf != NULL)
f010116a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010116e:	74 0b                	je     f010117b <monitor+0x2f>
		print_trapframe(tf);
f0101170:	8b 45 08             	mov    0x8(%ebp),%eax
f0101173:	89 04 24             	mov    %eax,(%esp)
f0101176:	e8 23 4c 00 00       	call   f0105d9e <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010117b:	c7 04 24 5d 9d 10 f0 	movl   $0xf0109d5d,(%esp)
f0101182:	e8 f1 72 00 00       	call   f0108478 <readline>
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
f01011c3:	c7 44 24 08 64 9d 10 	movl   $0xf0109d64,0x8(%esp)
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
f01011f5:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f01011fa:	39 c2                	cmp    %eax,%edx
f01011fc:	72 21                	jb     f010121f <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0101201:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101205:	c7 44 24 08 88 9d 10 	movl   $0xf0109d88,0x8(%esp)
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
f010122f:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
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
f010124e:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f0101253:	39 c2                	cmp    %eax,%edx
f0101255:	72 1c                	jb     f0101273 <pa2page+0x33>
		panic("pa2page called with invalid pa");
f0101257:	c7 44 24 08 ac 9d 10 	movl   $0xf0109dac,0x8(%esp)
f010125e:	f0 
f010125f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101266:	00 
f0101267:	c7 04 24 cb 9d 10 f0 	movl   $0xf0109dcb,(%esp)
f010126e:	e8 5c f0 ff ff       	call   f01002cf <_panic>
	return &pages[PGNUM(pa)];
f0101273:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
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
f01012a2:	c7 04 24 cb 9d 10 f0 	movl   $0xf0109dcb,(%esp)
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
f01012bd:	e8 d9 39 00 00       	call   f0104c9b <mc146818_read>
f01012c2:	89 c3                	mov    %eax,%ebx
f01012c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c7:	83 c0 01             	add    $0x1,%eax
f01012ca:	89 04 24             	mov    %eax,(%esp)
f01012cd:	e8 c9 39 00 00       	call   f0104c9b <mc146818_read>
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
f0101300:	a3 2c 32 29 f0       	mov    %eax,0xf029322c
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
f0101333:	a3 e8 6a 29 f0       	mov    %eax,0xf0296ae8
f0101338:	eb 0a                	jmp    f0101344 <i386_detect_memory+0x67>
	else
		npages = npages_basemem;
f010133a:	a1 2c 32 29 f0       	mov    0xf029322c,%eax
f010133f:	a3 e8 6a 29 f0       	mov    %eax,0xf0296ae8

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
f010134f:	a1 2c 32 29 f0       	mov    0xf029322c,%eax
f0101354:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101357:	c1 e8 0a             	shr    $0xa,%eax
f010135a:	89 c2                	mov    %eax,%edx
		npages * PGSIZE / 1024,
f010135c:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
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
f0101373:	c7 04 24 dc 9d 10 f0 	movl   $0xf0109ddc,(%esp)
f010137a:	e8 cd 3b 00 00       	call   f0104f4c <cprintf>
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
f0101387:	a1 38 32 29 f0       	mov    0xf0293238,%eax
f010138c:	85 c0                	test   %eax,%eax
f010138e:	75 30                	jne    f01013c0 <boot_alloc+0x3f>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101390:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0101397:	b8 08 80 2d f0       	mov    $0xf02d8008,%eax
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
f01013bb:	a3 38 32 29 f0       	mov    %eax,0xf0293238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01013c0:	a1 38 32 29 f0       	mov    0xf0293238,%eax
f01013c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char *nres = nextfree;
f01013c8:	a1 38 32 29 f0       	mov    0xf0293238,%eax
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
f01013fb:	a1 38 32 29 f0       	mov    0xf0293238,%eax
f0101400:	01 d0                	add    %edx,%eax
f0101402:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(PADDR(result) > npages*PGSIZE){
f0101405:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101408:	89 44 24 08          	mov    %eax,0x8(%esp)
f010140c:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f0101413:	00 
f0101414:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010141b:	e8 8c fd ff ff       	call   f01011ac <_paddr>
f0101420:	8b 15 e8 6a 29 f0    	mov    0xf0296ae8,%edx
f0101426:	c1 e2 0c             	shl    $0xc,%edx
f0101429:	39 d0                	cmp    %edx,%eax
f010142b:	76 1c                	jbe    f0101449 <boot_alloc+0xc8>
		panic("OUT OF MEMORY!\n");
f010142d:	c7 44 24 08 24 9e 10 	movl   $0xf0109e24,0x8(%esp)
f0101434:	f0 
f0101435:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f010143c:	00 
f010143d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101444:	e8 86 ee ff ff       	call   f01002cf <_panic>
	}
	else{
		nextfree = nres;
f0101449:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010144c:	a3 38 32 29 f0       	mov    %eax,0xf0293238
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
f010146e:	a3 ec 6a 29 f0       	mov    %eax,0xf0296aec
	memset(kern_pgdir, 0, PGSIZE);
f0101473:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0101478:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010147f:	00 
f0101480:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101487:	00 
f0101488:	89 04 24             	mov    %eax,(%esp)
f010148b:	e8 17 73 00 00       	call   f01087a7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101490:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0101495:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f010149b:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01014a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014a4:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014ab:	00 
f01014ac:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01014b3:	e8 f4 fc ff ff       	call   f01011ac <_paddr>
f01014b8:	83 c8 05             	or     $0x5,%eax
f01014bb:	89 03                	mov    %eax,(%ebx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = boot_alloc(npages*(sizeof(struct PageInfo)));
f01014bd:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f01014c2:	c1 e0 03             	shl    $0x3,%eax
f01014c5:	89 04 24             	mov    %eax,(%esp)
f01014c8:	e8 b4 fe ff ff       	call   f0101381 <boot_alloc>
f01014cd:	a3 f0 6a 29 f0       	mov    %eax,0xf0296af0
	memset(pages,0,npages*sizeof(struct PageInfo));
f01014d2:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f01014d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01014de:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f01014e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01014e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014ee:	00 
f01014ef:	89 04 24             	mov    %eax,(%esp)
f01014f2:	e8 b0 72 00 00       	call   f01087a7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env));
f01014f7:	c7 04 24 00 f0 01 00 	movl   $0x1f000,(%esp)
f01014fe:	e8 7e fe ff ff       	call   f0101381 <boot_alloc>
f0101503:	a3 3c 32 29 f0       	mov    %eax,0xf029323c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101508:	e8 03 02 00 00       	call   f0101710 <page_init>

	check_page_free_list(1);
f010150d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101514:	e8 32 09 00 00       	call   f0101e4b <check_page_free_list>
	check_page_alloc();
f0101519:	e8 d1 0c 00 00       	call   f01021ef <check_page_alloc>
	check_page();
f010151e:	e8 16 17 00 00       	call   f0102c39 <check_page>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,PTSIZE,PADDR(pages),PTE_U | PTE_P);
f0101523:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101528:	89 44 24 08          	mov    %eax,0x8(%esp)
f010152c:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
f0101533:	00 
f0101534:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010153b:	e8 6c fc ff ff       	call   f01011ac <_paddr>
f0101540:	8b 15 ec 6a 29 f0    	mov    0xf0296aec,%edx
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
f010156a:	a1 3c 32 29 f0       	mov    0xf029323c,%eax
f010156f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101573:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f010157a:	00 
f010157b:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101582:	e8 25 fc ff ff       	call   f01011ac <_paddr>
f0101587:	8b 15 ec 6a 29 f0    	mov    0xf0296aec,%edx
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
f01015b1:	c7 44 24 08 00 c0 11 	movl   $0xf011c000,0x8(%esp)
f01015b8:	f0 
f01015b9:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f01015c0:	00 
f01015c1:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01015c8:	e8 df fb ff ff       	call   f01011ac <_paddr>
f01015cd:	8b 15 ec 6a 29 f0    	mov    0xf0296aec,%edx
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
f01015f7:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
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
f0101629:	e8 73 11 00 00       	call   f01027a1 <check_kern_pgdir>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010162e:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0101633:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101637:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f010163e:	00 
f010163f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
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
f010165b:	e8 eb 07 00 00       	call   f0101e4b <check_page_free_list>

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
f0101683:	e8 28 28 00 00       	call   f0103eb0 <check_page_installed_pgdir>
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
f01016b8:	05 00 80 29 f0       	add    $0xf0298000,%eax
f01016bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016c1:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f01016c8:	00 
f01016c9:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01016d0:	e8 d7 fa ff ff       	call   f01011ac <_paddr>
f01016d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01016d8:	8d 8a 00 80 ff ff    	lea    -0x8000(%edx),%ecx
f01016de:	8b 15 ec 6a 29 f0    	mov    0xf0296aec,%edx
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
f0101716:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f010171b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0101721:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
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
f0101744:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101749:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010174c:	c1 e2 03             	shl    $0x3,%edx
f010174f:	01 d0                	add    %edx,%eax
f0101751:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0101757:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f010175c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010175f:	c1 e2 03             	shl    $0x3,%edx
f0101762:	01 c2                	add    %eax,%edx
f0101764:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0101769:	89 02                	mov    %eax,(%edx)
			page_free_list = &pages[i];
f010176b:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101770:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101773:	c1 e2 03             	shl    $0x3,%edx
f0101776:	01 d0                	add    %edx,%eax
f0101778:	a3 30 32 29 f0       	mov    %eax,0xf0293230
	// 	page_free_list = &pages[i];
	// }
	pages[0].pp_ref = 1;
	pages[0].pp_link = NULL;
	size_t mpentry_paddr_pg = PGNUM(MPENTRY_PADDR);
	for (i = 1; i<npages_basemem; i++){
f010177d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101781:	a1 2c 32 29 f0       	mov    0xf029322c,%eax
f0101786:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101789:	72 b1                	jb     f010173c <page_init+0x2c>
			page_free_list = &pages[i];
		}
	}
	// cprintf("npages_basemem : %d\n", npages_basemem);
	// cprintf("PGNUM(MPENTRY_PADDR): %d\n",PGNUM(MPENTRY_PADDR));
	pages[mpentry_paddr_pg].pp_ref = 1;
f010178b:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101790:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101793:	c1 e2 03             	shl    $0x3,%edx
f0101796:	01 d0                	add    %edx,%eax
f0101798:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[mpentry_paddr_pg].pp_link = NULL;
f010179e:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
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
f01017c9:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f01017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017d1:	c1 e2 03             	shl    $0x3,%edx
f01017d4:	01 d0                	add    %edx,%eax
f01017d6:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = NULL;
f01017dc:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
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
f0101802:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
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
f0101825:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010182c:	e8 7b f9 ff ff       	call   f01011ac <_paddr>
f0101831:	c1 e8 0c             	shr    $0xc,%eax
f0101834:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101837:	eb 3d                	jmp    f0101876 <page_init+0x166>
		pages[i].pp_ref = 0;
f0101839:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f010183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101841:	c1 e2 03             	shl    $0x3,%edx
f0101844:	01 d0                	add    %edx,%eax
f0101846:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f010184c:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101851:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101854:	c1 e2 03             	shl    $0x3,%edx
f0101857:	01 c2                	add    %eax,%edx
f0101859:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f010185e:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f0101860:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101865:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101868:	c1 e2 03             	shl    $0x3,%edx
f010186b:	01 d0                	add    %edx,%eax
f010186d:	a3 30 32 29 f0       	mov    %eax,0xf0293230
	char *next_free = boot_alloc(0);
	for (i = PGNUM(IOPHYSMEM);i<PGNUM(PADDR(next_free)); i++){
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for(i = PGNUM(PADDR(next_free)); i<npages; i++){
f0101872:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101876:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
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
f0101888:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f010188d:	85 c0                	test   %eax,%eax
f010188f:	75 07                	jne    f0101898 <page_alloc+0x16>
		return NULL;
f0101891:	b8 00 00 00 00       	mov    $0x0,%eax
f0101896:	eb 4b                	jmp    f01018e3 <page_alloc+0x61>
	}
	struct PageInfo *pp = page_free_list;
f0101898:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f010189d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	page_free_list = pp->pp_link;
f01018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018a3:	8b 00                	mov    (%eax),%eax
f01018a5:	a3 30 32 29 f0       	mov    %eax,0xf0293230
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
f01018d2:	e8 d0 6e 00 00       	call   f01087a7 <memset>
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
f01018f7:	c7 44 24 08 34 9e 10 	movl   $0xf0109e34,0x8(%esp)
f01018fe:	f0 
f01018ff:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0101906:	00 
f0101907:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010190e:	e8 bc e9 ff ff       	call   f01002cf <_panic>
	}
	else if(pp->pp_link){
f0101913:	8b 45 08             	mov    0x8(%ebp),%eax
f0101916:	8b 00                	mov    (%eax),%eax
f0101918:	85 c0                	test   %eax,%eax
f010191a:	74 1c                	je     f0101938 <page_free+0x53>
		panic("pp_link of page not null!\n");
f010191c:	c7 44 24 08 4e 9e 10 	movl   $0xf0109e4e,0x8(%esp)
f0101923:	f0 
f0101924:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f010192b:	00 
f010192c:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101933:	e8 97 e9 ff ff       	call   f01002cf <_panic>
	}
	else{
		pp->pp_link = page_free_list;
f0101938:	8b 15 30 32 29 f0    	mov    0xf0293230,%edx
f010193e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101941:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0101943:	8b 45 08             	mov    0x8(%ebp),%eax
f0101946:	a3 30 32 29 f0       	mov    %eax,0xf0293230
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
f0101a43:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
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
f0101a81:	c7 44 24 0c 69 9e 10 	movl   $0xf0109e69,0xc(%esp)
f0101a88:	f0 
f0101a89:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0101a90:	f0 
f0101a91:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0101a98:	00 
f0101a99:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
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
f0101c46:	e8 27 76 00 00       	call   f0109272 <cpunum>
f0101c4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c4e:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0101c53:	8b 00                	mov    (%eax),%eax
f0101c55:	85 c0                	test   %eax,%eax
f0101c57:	74 17                	je     f0101c70 <tlb_invalidate+0x30>
f0101c59:	e8 14 76 00 00       	call   f0109272 <cpunum>
f0101c5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c61:	05 28 70 29 f0       	add    $0xf0297028,%eax
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
f0101cb0:	8b 15 5c 65 12 f0    	mov    0xf012655c,%edx
f0101cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101cb9:	01 d0                	add    %edx,%eax
f0101cbb:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101cc0:	76 1c                	jbe    f0101cde <mmio_map_region+0x60>
f0101cc2:	c7 44 24 08 8f 9e 10 	movl   $0xf0109e8f,0x8(%esp)
f0101cc9:	f0 
f0101cca:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
f0101cd1:	00 
f0101cd2:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101cd9:	e8 f1 e5 ff ff       	call   f01002cf <_panic>

	boot_map_region(kern_pgdir, base, aligned_size, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101cde:	8b 15 5c 65 12 f0    	mov    0xf012655c,%edx
f0101ce4:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
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
f0101d0b:	a1 5c 65 12 f0       	mov    0xf012655c,%eax
f0101d10:	89 45 e8             	mov    %eax,-0x18(%ebp)
	base += aligned_size;
f0101d13:	8b 15 5c 65 12 f0    	mov    0xf012655c,%edx
f0101d19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d1c:	01 d0                	add    %edx,%eax
f0101d1e:	a3 5c 65 12 f0       	mov    %eax,0xf012655c
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
	pte_t *ptable_entry;
	uint32_t aligned_va = ROUNDDOWN((uint32_t)va,PGSIZE);
f0101d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
f0101d3f:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0101d46:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101d49:	8b 45 10             	mov    0x10(%ebp),%eax
f0101d4c:	01 c2                	add    %eax,%edx
f0101d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d51:	01 d0                	add    %edx,%eax
f0101d53:	83 e8 01             	sub    $0x1,%eax
f0101d56:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d5c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d61:	f7 75 ec             	divl   -0x14(%ebp)
f0101d64:	89 d0                	mov    %edx,%eax
f0101d66:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101d69:	29 c2                	sub    %eax,%edx
f0101d6b:	89 d0                	mov    %edx,%eax
f0101d6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;aligned_va < (uint32_t)va + len; aligned_va += PGSIZE){
f0101d70:	eb 6b                	jmp    f0101ddd <user_mem_check+0xb5>
		page_lookup(env->env_pgdir,(void *)aligned_va, &ptable_entry);
f0101d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101d75:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d78:	8b 40 60             	mov    0x60(%eax),%eax
f0101d7b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101d7e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101d82:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101d86:	89 04 24             	mov    %eax,(%esp)
f0101d89:	e8 0f fe ff ff       	call   f0101b9d <page_lookup>
		if(!ptable_entry || aligned_va > ULIM || (((uint32_t)*ptable_entry & (perm | PTE_P)) != (perm | PTE_P))){
f0101d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101d91:	85 c0                	test   %eax,%eax
f0101d93:	74 20                	je     f0101db5 <user_mem_check+0x8d>
f0101d95:	81 7d f4 00 00 80 ef 	cmpl   $0xef800000,-0xc(%ebp)
f0101d9c:	77 17                	ja     f0101db5 <user_mem_check+0x8d>
f0101d9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101da1:	8b 10                	mov    (%eax),%edx
f0101da3:	8b 45 14             	mov    0x14(%ebp),%eax
f0101da6:	83 c8 01             	or     $0x1,%eax
f0101da9:	21 c2                	and    %eax,%edx
f0101dab:	8b 45 14             	mov    0x14(%ebp),%eax
f0101dae:	83 c8 01             	or     $0x1,%eax
f0101db1:	39 c2                	cmp    %eax,%edx
f0101db3:	74 21                	je     f0101dd6 <user_mem_check+0xae>
			if(aligned_va > (uint32_t)va) user_mem_check_addr = (uintptr_t)aligned_va;
f0101db5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101db8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101dbb:	73 0a                	jae    f0101dc7 <user_mem_check+0x9f>
f0101dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101dc0:	a3 34 32 29 f0       	mov    %eax,0xf0293234
f0101dc5:	eb 08                	jmp    f0101dcf <user_mem_check+0xa7>
			else user_mem_check_addr = (uintptr_t)va;
f0101dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101dca:	a3 34 32 29 f0       	mov    %eax,0xf0293234
			return -E_FAULT;
f0101dcf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0101dd4:	eb 19                	jmp    f0101def <user_mem_check+0xc7>
{
	// LAB 3: Your code here.
	pte_t *ptable_entry;
	uint32_t aligned_va = ROUNDDOWN((uint32_t)va,PGSIZE);
	uint32_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
	for(;aligned_va < (uint32_t)va + len; aligned_va += PGSIZE){
f0101dd6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0101ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101de0:	8b 45 10             	mov    0x10(%ebp),%eax
f0101de3:	01 d0                	add    %edx,%eax
f0101de5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101de8:	77 88                	ja     f0101d72 <user_mem_check+0x4a>
			else user_mem_check_addr = (uintptr_t)va;
			return -E_FAULT;
		}
	}

	return 0;
f0101dea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101def:	c9                   	leave  
f0101df0:	c3                   	ret    

f0101df1 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101df1:	55                   	push   %ebp
f0101df2:	89 e5                	mov    %esp,%ebp
f0101df4:	83 ec 18             	sub    $0x18,%esp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0101df7:	8b 45 14             	mov    0x14(%ebp),%eax
f0101dfa:	83 c8 04             	or     $0x4,%eax
f0101dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e01:	8b 45 10             	mov    0x10(%ebp),%eax
f0101e04:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101e08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101e0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e12:	89 04 24             	mov    %eax,(%esp)
f0101e15:	e8 0e ff ff ff       	call   f0101d28 <user_mem_check>
f0101e1a:	85 c0                	test   %eax,%eax
f0101e1c:	79 2b                	jns    f0101e49 <user_mem_assert+0x58>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101e1e:	8b 15 34 32 29 f0    	mov    0xf0293234,%edx
f0101e24:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e27:	8b 40 48             	mov    0x48(%eax),%eax
f0101e2a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e32:	c7 04 24 ac 9e 10 f0 	movl   $0xf0109eac,(%esp)
f0101e39:	e8 0e 31 00 00       	call   f0104f4c <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e41:	89 04 24             	mov    %eax,(%esp)
f0101e44:	e8 9c 2c 00 00       	call   f0104ae5 <env_destroy>
	}
}
f0101e49:	c9                   	leave  
f0101e4a:	c3                   	ret    

f0101e4b <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101e4b:	55                   	push   %ebp
f0101e4c:	89 e5                	mov    %esp,%ebp
f0101e4e:	83 ec 58             	sub    $0x58,%esp
f0101e51:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e54:	88 45 c4             	mov    %al,-0x3c(%ebp)
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101e57:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0101e5b:	74 07                	je     f0101e64 <check_page_free_list+0x19>
f0101e5d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e62:	eb 05                	jmp    f0101e69 <check_page_free_list+0x1e>
f0101e64:	b8 00 04 00 00       	mov    $0x400,%eax
f0101e69:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101e6c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101e73:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	char *first_free_page;

	if (!page_free_list)
f0101e7a:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0101e7f:	85 c0                	test   %eax,%eax
f0101e81:	75 1c                	jne    f0101e9f <check_page_free_list+0x54>
		panic("'page_free_list' is a null pointer!");
f0101e83:	c7 44 24 08 e4 9e 10 	movl   $0xf0109ee4,0x8(%esp)
f0101e8a:	f0 
f0101e8b:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0101e92:	00 
f0101e93:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101e9a:	e8 30 e4 ff ff       	call   f01002cf <_panic>

	if (only_low_memory) {
f0101e9f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0101ea3:	74 6d                	je     f0101f12 <check_page_free_list+0xc7>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101ea5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101ea8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101eab:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101eae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101eb1:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0101eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101eb9:	eb 38                	jmp    f0101ef3 <check_page_free_list+0xa8>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ebe:	89 04 24             	mov    %eax,(%esp)
f0101ec1:	e8 63 f3 ff ff       	call   f0101229 <page2pa>
f0101ec6:	c1 e8 16             	shr    $0x16,%eax
f0101ec9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101ecc:	0f 93 c0             	setae  %al
f0101ecf:	0f b6 c0             	movzbl %al,%eax
f0101ed2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			*tp[pagetype] = pp;
f0101ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101ed8:	8b 44 85 d0          	mov    -0x30(%ebp,%eax,4),%eax
f0101edc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101edf:	89 10                	mov    %edx,(%eax)
			tp[pagetype] = &pp->pp_link;
f0101ee1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101ee7:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101eee:	8b 00                	mov    (%eax),%eax
f0101ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101ef3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101ef7:	75 c2                	jne    f0101ebb <check_page_free_list+0x70>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101ef9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101efc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101f02:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f05:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101f08:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101f0d:	a3 30 32 29 f0       	mov    %eax,0xf0293230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f12:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0101f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f1a:	eb 3e                	jmp    f0101f5a <check_page_free_list+0x10f>
		if (PDX(page2pa(pp)) < pdx_limit)
f0101f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f1f:	89 04 24             	mov    %eax,(%esp)
f0101f22:	e8 02 f3 ff ff       	call   f0101229 <page2pa>
f0101f27:	c1 e8 16             	shr    $0x16,%eax
f0101f2a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101f2d:	73 23                	jae    f0101f52 <check_page_free_list+0x107>
			memset(page2kva(pp), 0x97, 128);
f0101f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f32:	89 04 24             	mov    %eax,(%esp)
f0101f35:	e8 4b f3 ff ff       	call   f0101285 <page2kva>
f0101f3a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101f41:	00 
f0101f42:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101f49:	00 
f0101f4a:	89 04 24             	mov    %eax,(%esp)
f0101f4d:	e8 55 68 00 00       	call   f01087a7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f52:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f55:	8b 00                	mov    (%eax),%eax
f0101f57:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0101f5e:	75 bc                	jne    f0101f1c <check_page_free_list+0xd1>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f67:	e8 15 f4 ff ff       	call   f0101381 <boot_alloc>
f0101f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101f6f:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0101f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f77:	e9 13 02 00 00       	jmp    f010218f <check_page_free_list+0x344>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101f7c:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101f84:	73 24                	jae    f0101faa <check_page_free_list+0x15f>
f0101f86:	c7 44 24 0c 08 9f 10 	movl   $0xf0109f08,0xc(%esp)
f0101f8d:	f0 
f0101f8e:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101f9d:	00 
f0101f9e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101fa5:	e8 25 e3 ff ff       	call   f01002cf <_panic>
		assert(pp < pages + npages);
f0101faa:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101faf:	8b 15 e8 6a 29 f0    	mov    0xf0296ae8,%edx
f0101fb5:	c1 e2 03             	shl    $0x3,%edx
f0101fb8:	01 d0                	add    %edx,%eax
f0101fba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101fbd:	77 24                	ja     f0101fe3 <check_page_free_list+0x198>
f0101fbf:	c7 44 24 0c 14 9f 10 	movl   $0xf0109f14,0xc(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0101fce:	f0 
f0101fcf:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101fd6:	00 
f0101fd7:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0101fde:	e8 ec e2 ff ff       	call   f01002cf <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101fe3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101fe6:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0101feb:	29 c2                	sub    %eax,%edx
f0101fed:	89 d0                	mov    %edx,%eax
f0101fef:	83 e0 07             	and    $0x7,%eax
f0101ff2:	85 c0                	test   %eax,%eax
f0101ff4:	74 24                	je     f010201a <check_page_free_list+0x1cf>
f0101ff6:	c7 44 24 0c 28 9f 10 	movl   $0xf0109f28,0xc(%esp)
f0101ffd:	f0 
f0101ffe:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102005:	f0 
f0102006:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f010200d:	00 
f010200e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102015:	e8 b5 e2 ff ff       	call   f01002cf <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010201d:	89 04 24             	mov    %eax,(%esp)
f0102020:	e8 04 f2 ff ff       	call   f0101229 <page2pa>
f0102025:	85 c0                	test   %eax,%eax
f0102027:	75 24                	jne    f010204d <check_page_free_list+0x202>
f0102029:	c7 44 24 0c 5a 9f 10 	movl   $0xf0109f5a,0xc(%esp)
f0102030:	f0 
f0102031:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102038:	f0 
f0102039:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0102040:	00 
f0102041:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102048:	e8 82 e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010204d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102050:	89 04 24             	mov    %eax,(%esp)
f0102053:	e8 d1 f1 ff ff       	call   f0101229 <page2pa>
f0102058:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010205d:	75 24                	jne    f0102083 <check_page_free_list+0x238>
f010205f:	c7 44 24 0c 6b 9f 10 	movl   $0xf0109f6b,0xc(%esp)
f0102066:	f0 
f0102067:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010206e:	f0 
f010206f:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0102076:	00 
f0102077:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010207e:	e8 4c e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0102083:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102086:	89 04 24             	mov    %eax,(%esp)
f0102089:	e8 9b f1 ff ff       	call   f0101229 <page2pa>
f010208e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0102093:	75 24                	jne    f01020b9 <check_page_free_list+0x26e>
f0102095:	c7 44 24 0c 84 9f 10 	movl   $0xf0109f84,0xc(%esp)
f010209c:	f0 
f010209d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01020a4:	f0 
f01020a5:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f01020ac:	00 
f01020ad:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01020b4:	e8 16 e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01020b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020bc:	89 04 24             	mov    %eax,(%esp)
f01020bf:	e8 65 f1 ff ff       	call   f0101229 <page2pa>
f01020c4:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01020c9:	75 24                	jne    f01020ef <check_page_free_list+0x2a4>
f01020cb:	c7 44 24 0c a7 9f 10 	movl   $0xf0109fa7,0xc(%esp)
f01020d2:	f0 
f01020d3:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01020da:	f0 
f01020db:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01020e2:	00 
f01020e3:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01020ea:	e8 e0 e1 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01020ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020f2:	89 04 24             	mov    %eax,(%esp)
f01020f5:	e8 2f f1 ff ff       	call   f0101229 <page2pa>
f01020fa:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01020ff:	76 34                	jbe    f0102135 <check_page_free_list+0x2ea>
f0102101:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102104:	89 04 24             	mov    %eax,(%esp)
f0102107:	e8 79 f1 ff ff       	call   f0101285 <page2kva>
f010210c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010210f:	73 24                	jae    f0102135 <check_page_free_list+0x2ea>
f0102111:	c7 44 24 0c c4 9f 10 	movl   $0xf0109fc4,0xc(%esp)
f0102118:	f0 
f0102119:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102120:	f0 
f0102121:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0102128:	00 
f0102129:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102130:	e8 9a e1 ff ff       	call   f01002cf <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0102135:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102138:	89 04 24             	mov    %eax,(%esp)
f010213b:	e8 e9 f0 ff ff       	call   f0101229 <page2pa>
f0102140:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102145:	75 24                	jne    f010216b <check_page_free_list+0x320>
f0102147:	c7 44 24 0c 09 a0 10 	movl   $0xf010a009,0xc(%esp)
f010214e:	f0 
f010214f:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102156:	f0 
f0102157:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f010215e:	00 
f010215f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102166:	e8 64 e1 ff ff       	call   f01002cf <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010216b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010216e:	89 04 24             	mov    %eax,(%esp)
f0102171:	e8 b3 f0 ff ff       	call   f0101229 <page2pa>
f0102176:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010217b:	77 06                	ja     f0102183 <check_page_free_list+0x338>
			++nfree_basemem;
f010217d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0102181:	eb 04                	jmp    f0102187 <check_page_free_list+0x33c>
		else
			++nfree_extmem;
f0102183:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0102187:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010218a:	8b 00                	mov    (%eax),%eax
f010218c:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010218f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102193:	0f 85 e3 fd ff ff    	jne    f0101f7c <check_page_free_list+0x131>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0102199:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010219d:	7f 24                	jg     f01021c3 <check_page_free_list+0x378>
f010219f:	c7 44 24 0c 26 a0 10 	movl   $0xf010a026,0xc(%esp)
f01021a6:	f0 
f01021a7:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01021ae:	f0 
f01021af:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01021b6:	00 
f01021b7:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01021be:	e8 0c e1 ff ff       	call   f01002cf <_panic>
	assert(nfree_extmem > 0);
f01021c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01021c7:	7f 24                	jg     f01021ed <check_page_free_list+0x3a2>
f01021c9:	c7 44 24 0c 38 a0 10 	movl   $0xf010a038,0xc(%esp)
f01021d0:	f0 
f01021d1:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01021d8:	f0 
f01021d9:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01021e0:	00 
f01021e1:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01021e8:	e8 e2 e0 ff ff       	call   f01002cf <_panic>
}
f01021ed:	c9                   	leave  
f01021ee:	c3                   	ret    

f01021ef <check_page_alloc>:
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
f01021ef:	55                   	push   %ebp
f01021f0:	89 e5                	mov    %esp,%ebp
f01021f2:	83 ec 38             	sub    $0x38,%esp
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01021f5:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f01021fa:	85 c0                	test   %eax,%eax
f01021fc:	75 1c                	jne    f010221a <check_page_alloc+0x2b>
		panic("'pages' is a null pointer!");
f01021fe:	c7 44 24 08 49 a0 10 	movl   $0xf010a049,0x8(%esp)
f0102205:	f0 
f0102206:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f010220d:	00 
f010220e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102215:	e8 b5 e0 ff ff       	call   f01002cf <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010221a:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f010221f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102222:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102229:	eb 0c                	jmp    f0102237 <check_page_alloc+0x48>
		++nfree;
f010222b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010222f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102232:	8b 00                	mov    (%eax),%eax
f0102234:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102237:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010223b:	75 ee                	jne    f010222b <check_page_alloc+0x3c>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f010223d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0102244:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102247:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010224a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010224d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert((pp0 = page_alloc(0)));
f0102250:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102257:	e8 26 f6 ff ff       	call   f0101882 <page_alloc>
f010225c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010225f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102263:	75 24                	jne    f0102289 <check_page_alloc+0x9a>
f0102265:	c7 44 24 0c 64 a0 10 	movl   $0xf010a064,0xc(%esp)
f010226c:	f0 
f010226d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102274:	f0 
f0102275:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f010227c:	00 
f010227d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102284:	e8 46 e0 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0102289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102290:	e8 ed f5 ff ff       	call   f0101882 <page_alloc>
f0102295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102298:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010229c:	75 24                	jne    f01022c2 <check_page_alloc+0xd3>
f010229e:	c7 44 24 0c 7a a0 10 	movl   $0xf010a07a,0xc(%esp)
f01022a5:	f0 
f01022a6:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01022ad:	f0 
f01022ae:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f01022b5:	00 
f01022b6:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01022bd:	e8 0d e0 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f01022c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022c9:	e8 b4 f5 ff ff       	call   f0101882 <page_alloc>
f01022ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01022d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01022d5:	75 24                	jne    f01022fb <check_page_alloc+0x10c>
f01022d7:	c7 44 24 0c 90 a0 10 	movl   $0xf010a090,0xc(%esp)
f01022de:	f0 
f01022df:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01022e6:	f0 
f01022e7:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01022ee:	00 
f01022ef:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01022f6:	e8 d4 df ff ff       	call   f01002cf <_panic>

	assert(pp0);
f01022fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01022ff:	75 24                	jne    f0102325 <check_page_alloc+0x136>
f0102301:	c7 44 24 0c a6 a0 10 	movl   $0xf010a0a6,0xc(%esp)
f0102308:	f0 
f0102309:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102310:	f0 
f0102311:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0102318:	00 
f0102319:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102320:	e8 aa df ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102325:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102329:	74 08                	je     f0102333 <check_page_alloc+0x144>
f010232b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010232e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102331:	75 24                	jne    f0102357 <check_page_alloc+0x168>
f0102333:	c7 44 24 0c aa a0 10 	movl   $0xf010a0aa,0xc(%esp)
f010233a:	f0 
f010233b:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102342:	f0 
f0102343:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f010234a:	00 
f010234b:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102352:	e8 78 df ff ff       	call   f01002cf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102357:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010235b:	74 10                	je     f010236d <check_page_alloc+0x17e>
f010235d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102360:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0102363:	74 08                	je     f010236d <check_page_alloc+0x17e>
f0102365:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102368:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f010236b:	75 24                	jne    f0102391 <check_page_alloc+0x1a2>
f010236d:	c7 44 24 0c bc a0 10 	movl   $0xf010a0bc,0xc(%esp)
f0102374:	f0 
f0102375:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010237c:	f0 
f010237d:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0102384:	00 
f0102385:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010238c:	e8 3e df ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0102391:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102394:	89 04 24             	mov    %eax,(%esp)
f0102397:	e8 8d ee ff ff       	call   f0101229 <page2pa>
f010239c:	8b 15 e8 6a 29 f0    	mov    0xf0296ae8,%edx
f01023a2:	c1 e2 0c             	shl    $0xc,%edx
f01023a5:	39 d0                	cmp    %edx,%eax
f01023a7:	72 24                	jb     f01023cd <check_page_alloc+0x1de>
f01023a9:	c7 44 24 0c dc a0 10 	movl   $0xf010a0dc,0xc(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01023b8:	f0 
f01023b9:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f01023c0:	00 
f01023c1:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01023c8:	e8 02 df ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01023cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01023d0:	89 04 24             	mov    %eax,(%esp)
f01023d3:	e8 51 ee ff ff       	call   f0101229 <page2pa>
f01023d8:	8b 15 e8 6a 29 f0    	mov    0xf0296ae8,%edx
f01023de:	c1 e2 0c             	shl    $0xc,%edx
f01023e1:	39 d0                	cmp    %edx,%eax
f01023e3:	72 24                	jb     f0102409 <check_page_alloc+0x21a>
f01023e5:	c7 44 24 0c f9 a0 10 	movl   $0xf010a0f9,0xc(%esp)
f01023ec:	f0 
f01023ed:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01023f4:	f0 
f01023f5:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01023fc:	00 
f01023fd:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102404:	e8 c6 de ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102409:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010240c:	89 04 24             	mov    %eax,(%esp)
f010240f:	e8 15 ee ff ff       	call   f0101229 <page2pa>
f0102414:	8b 15 e8 6a 29 f0    	mov    0xf0296ae8,%edx
f010241a:	c1 e2 0c             	shl    $0xc,%edx
f010241d:	39 d0                	cmp    %edx,%eax
f010241f:	72 24                	jb     f0102445 <check_page_alloc+0x256>
f0102421:	c7 44 24 0c 16 a1 10 	movl   $0xf010a116,0xc(%esp)
f0102428:	f0 
f0102429:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102430:	f0 
f0102431:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0102438:	00 
f0102439:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102440:	e8 8a de ff ff       	call   f01002cf <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102445:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f010244a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f010244d:	c7 05 30 32 29 f0 00 	movl   $0x0,0xf0293230
f0102454:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010245e:	e8 1f f4 ff ff       	call   f0101882 <page_alloc>
f0102463:	85 c0                	test   %eax,%eax
f0102465:	74 24                	je     f010248b <check_page_alloc+0x29c>
f0102467:	c7 44 24 0c 33 a1 10 	movl   $0xf010a133,0xc(%esp)
f010246e:	f0 
f010246f:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102476:	f0 
f0102477:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f010247e:	00 
f010247f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102486:	e8 44 de ff ff       	call   f01002cf <_panic>

	// free and re-allocate?
	page_free(pp0);
f010248b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010248e:	89 04 24             	mov    %eax,(%esp)
f0102491:	e8 4f f4 ff ff       	call   f01018e5 <page_free>
	page_free(pp1);
f0102496:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102499:	89 04 24             	mov    %eax,(%esp)
f010249c:	e8 44 f4 ff ff       	call   f01018e5 <page_free>
	page_free(pp2);
f01024a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01024a4:	89 04 24             	mov    %eax,(%esp)
f01024a7:	e8 39 f4 ff ff       	call   f01018e5 <page_free>
	pp0 = pp1 = pp2 = 0;
f01024ac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f01024b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01024b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01024bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert((pp0 = page_alloc(0)));
f01024bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024c6:	e8 b7 f3 ff ff       	call   f0101882 <page_alloc>
f01024cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01024ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01024d2:	75 24                	jne    f01024f8 <check_page_alloc+0x309>
f01024d4:	c7 44 24 0c 64 a0 10 	movl   $0xf010a064,0xc(%esp)
f01024db:	f0 
f01024dc:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01024e3:	f0 
f01024e4:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f01024eb:	00 
f01024ec:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01024f3:	e8 d7 dd ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f01024f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024ff:	e8 7e f3 ff ff       	call   f0101882 <page_alloc>
f0102504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010250b:	75 24                	jne    f0102531 <check_page_alloc+0x342>
f010250d:	c7 44 24 0c 7a a0 10 	movl   $0xf010a07a,0xc(%esp)
f0102514:	f0 
f0102515:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010251c:	f0 
f010251d:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0102524:	00 
f0102525:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010252c:	e8 9e dd ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0102531:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102538:	e8 45 f3 ff ff       	call   f0101882 <page_alloc>
f010253d:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102544:	75 24                	jne    f010256a <check_page_alloc+0x37b>
f0102546:	c7 44 24 0c 90 a0 10 	movl   $0xf010a090,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102565:	e8 65 dd ff ff       	call   f01002cf <_panic>
	assert(pp0);
f010256a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010256e:	75 24                	jne    f0102594 <check_page_alloc+0x3a5>
f0102570:	c7 44 24 0c a6 a0 10 	movl   $0xf010a0a6,0xc(%esp)
f0102577:	f0 
f0102578:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010257f:	f0 
f0102580:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0102587:	00 
f0102588:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010258f:	e8 3b dd ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102594:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102598:	74 08                	je     f01025a2 <check_page_alloc+0x3b3>
f010259a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010259d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01025a0:	75 24                	jne    f01025c6 <check_page_alloc+0x3d7>
f01025a2:	c7 44 24 0c aa a0 10 	movl   $0xf010a0aa,0xc(%esp)
f01025a9:	f0 
f01025aa:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01025b1:	f0 
f01025b2:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f01025b9:	00 
f01025ba:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01025c1:	e8 09 dd ff ff       	call   f01002cf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01025c6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01025ca:	74 10                	je     f01025dc <check_page_alloc+0x3ed>
f01025cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01025cf:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f01025d2:	74 08                	je     f01025dc <check_page_alloc+0x3ed>
f01025d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01025d7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01025da:	75 24                	jne    f0102600 <check_page_alloc+0x411>
f01025dc:	c7 44 24 0c bc a0 10 	movl   $0xf010a0bc,0xc(%esp)
f01025e3:	f0 
f01025e4:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01025f3:	00 
f01025f4:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01025fb:	e8 cf dc ff ff       	call   f01002cf <_panic>
	assert(!page_alloc(0));
f0102600:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102607:	e8 76 f2 ff ff       	call   f0101882 <page_alloc>
f010260c:	85 c0                	test   %eax,%eax
f010260e:	74 24                	je     f0102634 <check_page_alloc+0x445>
f0102610:	c7 44 24 0c 33 a1 10 	movl   $0xf010a133,0xc(%esp)
f0102617:	f0 
f0102618:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010261f:	f0 
f0102620:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0102627:	00 
f0102628:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010262f:	e8 9b dc ff ff       	call   f01002cf <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102634:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102637:	89 04 24             	mov    %eax,(%esp)
f010263a:	e8 46 ec ff ff       	call   f0101285 <page2kva>
f010263f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102646:	00 
f0102647:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010264e:	00 
f010264f:	89 04 24             	mov    %eax,(%esp)
f0102652:	e8 50 61 00 00       	call   f01087a7 <memset>
	page_free(pp0);
f0102657:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010265a:	89 04 24             	mov    %eax,(%esp)
f010265d:	e8 83 f2 ff ff       	call   f01018e5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102662:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102669:	e8 14 f2 ff ff       	call   f0101882 <page_alloc>
f010266e:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102671:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102675:	75 24                	jne    f010269b <check_page_alloc+0x4ac>
f0102677:	c7 44 24 0c 42 a1 10 	movl   $0xf010a142,0xc(%esp)
f010267e:	f0 
f010267f:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102686:	f0 
f0102687:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010268e:	00 
f010268f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102696:	e8 34 dc ff ff       	call   f01002cf <_panic>
	assert(pp && pp0 == pp);
f010269b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010269f:	74 08                	je     f01026a9 <check_page_alloc+0x4ba>
f01026a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01026a4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01026a7:	74 24                	je     f01026cd <check_page_alloc+0x4de>
f01026a9:	c7 44 24 0c 60 a1 10 	movl   $0xf010a160,0xc(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01026b8:	f0 
f01026b9:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01026c0:	00 
f01026c1:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01026c8:	e8 02 dc ff ff       	call   f01002cf <_panic>
	c = page2kva(pp);
f01026cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01026d0:	89 04 24             	mov    %eax,(%esp)
f01026d3:	e8 ad eb ff ff       	call   f0101285 <page2kva>
f01026d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for (i = 0; i < PGSIZE; i++)
f01026db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f01026e2:	eb 37                	jmp    f010271b <check_page_alloc+0x52c>
		assert(c[i] == 0);
f01026e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01026e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01026ea:	01 d0                	add    %edx,%eax
f01026ec:	0f b6 00             	movzbl (%eax),%eax
f01026ef:	84 c0                	test   %al,%al
f01026f1:	74 24                	je     f0102717 <check_page_alloc+0x528>
f01026f3:	c7 44 24 0c 70 a1 10 	movl   $0xf010a170,0xc(%esp)
f01026fa:	f0 
f01026fb:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102702:	f0 
f0102703:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f010270a:	00 
f010270b:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102712:	e8 b8 db ff ff       	call   f01002cf <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102717:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f010271b:	81 7d ec ff 0f 00 00 	cmpl   $0xfff,-0x14(%ebp)
f0102722:	7e c0                	jle    f01026e4 <check_page_alloc+0x4f5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102724:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102727:	a3 30 32 29 f0       	mov    %eax,0xf0293230

	// free the pages we took
	page_free(pp0);
f010272c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010272f:	89 04 24             	mov    %eax,(%esp)
f0102732:	e8 ae f1 ff ff       	call   f01018e5 <page_free>
	page_free(pp1);
f0102737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010273a:	89 04 24             	mov    %eax,(%esp)
f010273d:	e8 a3 f1 ff ff       	call   f01018e5 <page_free>
	page_free(pp2);
f0102742:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102745:	89 04 24             	mov    %eax,(%esp)
f0102748:	e8 98 f1 ff ff       	call   f01018e5 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010274d:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0102752:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102755:	eb 0c                	jmp    f0102763 <check_page_alloc+0x574>
		--nfree;
f0102757:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010275b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010275e:	8b 00                	mov    (%eax),%eax
f0102760:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102763:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102767:	75 ee                	jne    f0102757 <check_page_alloc+0x568>
		--nfree;
	assert(nfree == 0);
f0102769:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010276d:	74 24                	je     f0102793 <check_page_alloc+0x5a4>
f010276f:	c7 44 24 0c 7a a1 10 	movl   $0xf010a17a,0xc(%esp)
f0102776:	f0 
f0102777:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010277e:	f0 
f010277f:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0102786:	00 
f0102787:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010278e:	e8 3c db ff ff       	call   f01002cf <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102793:	c7 04 24 88 a1 10 f0 	movl   $0xf010a188,(%esp)
f010279a:	e8 ad 27 00 00       	call   f0104f4c <cprintf>
}
f010279f:	c9                   	leave  
f01027a0:	c3                   	ret    

f01027a1 <check_kern_pgdir>:
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
f01027a1:	55                   	push   %ebp
f01027a2:	89 e5                	mov    %esp,%ebp
f01027a4:	53                   	push   %ebx
f01027a5:	83 ec 34             	sub    $0x34,%esp
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027a8:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01027ad:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027b0:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
f01027b7:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f01027bc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01027c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01027c6:	01 d0                	add    %edx,%eax
f01027c8:	83 e8 01             	sub    $0x1,%eax
f01027cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01027ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01027d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01027d6:	f7 75 e8             	divl   -0x18(%ebp)
f01027d9:	89 d0                	mov    %edx,%eax
f01027db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01027de:	29 c2                	sub    %eax,%edx
f01027e0:	89 d0                	mov    %edx,%eax
f01027e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01027e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01027ec:	eb 6a                	jmp    f0102858 <check_kern_pgdir+0xb7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01027f1:	2d 00 00 00 11       	sub    $0x11000000,%eax
f01027f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01027fd:	89 04 24             	mov    %eax,(%esp)
f0102800:	e8 a3 03 00 00       	call   f0102ba8 <check_va2pa>
f0102805:	89 c3                	mov    %eax,%ebx
f0102807:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f010280c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102810:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0102817:	00 
f0102818:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010281f:	e8 88 e9 ff ff       	call   f01011ac <_paddr>
f0102824:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102827:	01 d0                	add    %edx,%eax
f0102829:	39 c3                	cmp    %eax,%ebx
f010282b:	74 24                	je     f0102851 <check_kern_pgdir+0xb0>
f010282d:	c7 44 24 0c a8 a1 10 	movl   $0xf010a1a8,0xc(%esp)
f0102834:	f0 
f0102835:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010283c:	f0 
f010283d:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0102844:	00 
f0102845:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010284c:	e8 7e da ff ff       	call   f01002cf <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102851:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102858:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010285b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010285e:	72 8e                	jb     f01027ee <check_kern_pgdir+0x4d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
f0102860:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
f0102867:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010286a:	05 ff ef 01 00       	add    $0x1efff,%eax
f010286f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102872:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102875:	ba 00 00 00 00       	mov    $0x0,%edx
f010287a:	f7 75 e0             	divl   -0x20(%ebp)
f010287d:	89 d0                	mov    %edx,%eax
f010287f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102882:	29 c2                	sub    %eax,%edx
f0102884:	89 d0                	mov    %edx,%eax
f0102886:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102890:	eb 6a                	jmp    f01028fc <check_kern_pgdir+0x15b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102892:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102895:	2d 00 00 40 11       	sub    $0x11400000,%eax
f010289a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010289e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01028a1:	89 04 24             	mov    %eax,(%esp)
f01028a4:	e8 ff 02 00 00       	call   f0102ba8 <check_va2pa>
f01028a9:	89 c3                	mov    %eax,%ebx
f01028ab:	a1 3c 32 29 f0       	mov    0xf029323c,%eax
f01028b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01028b4:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01028bb:	00 
f01028bc:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01028c3:	e8 e4 e8 ff ff       	call   f01011ac <_paddr>
f01028c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01028cb:	01 d0                	add    %edx,%eax
f01028cd:	39 c3                	cmp    %eax,%ebx
f01028cf:	74 24                	je     f01028f5 <check_kern_pgdir+0x154>
f01028d1:	c7 44 24 0c dc a1 10 	movl   $0xf010a1dc,0xc(%esp)
f01028d8:	f0 
f01028d9:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01028e0:	f0 
f01028e1:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01028e8:	00 
f01028e9:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01028f0:	e8 da d9 ff ff       	call   f01002cf <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028f5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01028fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028ff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0102902:	72 8e                	jb     f0102892 <check_kern_pgdir+0xf1>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102904:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010290b:	eb 47                	jmp    f0102954 <check_kern_pgdir+0x1b3>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010290d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102910:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102915:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102919:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010291c:	89 04 24             	mov    %eax,(%esp)
f010291f:	e8 84 02 00 00       	call   f0102ba8 <check_va2pa>
f0102924:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102927:	74 24                	je     f010294d <check_kern_pgdir+0x1ac>
f0102929:	c7 44 24 0c 10 a2 10 	movl   $0xf010a210,0xc(%esp)
f0102930:	f0 
f0102931:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102938:	f0 
f0102939:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102940:	00 
f0102941:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102948:	e8 82 d9 ff ff       	call   f01002cf <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102954:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f0102959:	c1 e0 0c             	shl    $0xc,%eax
f010295c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010295f:	77 ac                	ja     f010290d <check_kern_pgdir+0x16c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102961:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102968:	e9 f9 00 00 00       	jmp    f0102a66 <check_kern_pgdir+0x2c5>
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
f010296d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102970:	b8 00 00 00 00       	mov    $0x0,%eax
f0102975:	29 d0                	sub    %edx,%eax
f0102977:	c1 e0 10             	shl    $0x10,%eax
f010297a:	2d 00 00 01 10       	sub    $0x10010000,%eax
f010297f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102982:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102989:	eb 75                	jmp    f0102a00 <check_kern_pgdir+0x25f>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010298b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010298e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102991:	01 d0                	add    %edx,%eax
f0102993:	05 00 80 00 00       	add    $0x8000,%eax
f0102998:	89 44 24 04          	mov    %eax,0x4(%esp)
f010299c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010299f:	89 04 24             	mov    %eax,(%esp)
f01029a2:	e8 01 02 00 00       	call   f0102ba8 <check_va2pa>
f01029a7:	89 c3                	mov    %eax,%ebx
f01029a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01029ac:	c1 e0 0f             	shl    $0xf,%eax
f01029af:	05 00 80 29 f0       	add    $0xf0298000,%eax
f01029b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01029b8:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01029bf:	00 
f01029c0:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01029c7:	e8 e0 e7 ff ff       	call   f01011ac <_paddr>
f01029cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01029cf:	01 d0                	add    %edx,%eax
f01029d1:	39 c3                	cmp    %eax,%ebx
f01029d3:	74 24                	je     f01029f9 <check_kern_pgdir+0x258>
f01029d5:	c7 44 24 0c 38 a2 10 	movl   $0xf010a238,0xc(%esp)
f01029dc:	f0 
f01029dd:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01029e4:	f0 
f01029e5:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01029ec:	00 
f01029ed:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01029f4:	e8 d6 d8 ff ff       	call   f01002cf <_panic>

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029f9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102a00:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0102a07:	76 82                	jbe    f010298b <check_kern_pgdir+0x1ea>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102a10:	eb 47                	jmp    f0102a59 <check_kern_pgdir+0x2b8>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a15:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a18:	01 d0                	add    %edx,%eax
f0102a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102a21:	89 04 24             	mov    %eax,(%esp)
f0102a24:	e8 7f 01 00 00       	call   f0102ba8 <check_va2pa>
f0102a29:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a2c:	74 24                	je     f0102a52 <check_kern_pgdir+0x2b1>
f0102a2e:	c7 44 24 0c 80 a2 10 	movl   $0xf010a280,0xc(%esp)
f0102a35:	f0 
f0102a36:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102a3d:	f0 
f0102a3e:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0102a45:	00 
f0102a46:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102a4d:	e8 7d d8 ff ff       	call   f01002cf <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a52:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102a59:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0102a60:	76 b0                	jbe    f0102a12 <check_kern_pgdir+0x271>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a62:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0102a66:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
f0102a6a:	0f 86 fd fe ff ff    	jbe    f010296d <check_kern_pgdir+0x1cc>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102a77:	e9 0d 01 00 00       	jmp    f0102b89 <check_kern_pgdir+0x3e8>
		switch (i) {
f0102a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a7f:	2d bb 03 00 00       	sub    $0x3bb,%eax
f0102a84:	83 f8 04             	cmp    $0x4,%eax
f0102a87:	77 41                	ja     f0102aca <check_kern_pgdir+0x329>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a8c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102a93:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102a96:	01 d0                	add    %edx,%eax
f0102a98:	8b 00                	mov    (%eax),%eax
f0102a9a:	83 e0 01             	and    $0x1,%eax
f0102a9d:	85 c0                	test   %eax,%eax
f0102a9f:	75 24                	jne    f0102ac5 <check_kern_pgdir+0x324>
f0102aa1:	c7 44 24 0c a3 a2 10 	movl   $0xf010a2a3,0xc(%esp)
f0102aa8:	f0 
f0102aa9:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102ab0:	f0 
f0102ab1:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102ab8:	00 
f0102ab9:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102ac0:	e8 0a d8 ff ff       	call   f01002cf <_panic>
			break;
f0102ac5:	e9 bb 00 00 00       	jmp    f0102b85 <check_kern_pgdir+0x3e4>
		default:
			if (i >= PDX(KERNBASE)) {
f0102aca:	81 7d f4 bf 03 00 00 	cmpl   $0x3bf,-0xc(%ebp)
f0102ad1:	76 78                	jbe    f0102b4b <check_kern_pgdir+0x3aa>
				assert(pgdir[i] & PTE_P);
f0102ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ad6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102add:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ae0:	01 d0                	add    %edx,%eax
f0102ae2:	8b 00                	mov    (%eax),%eax
f0102ae4:	83 e0 01             	and    $0x1,%eax
f0102ae7:	85 c0                	test   %eax,%eax
f0102ae9:	75 24                	jne    f0102b0f <check_kern_pgdir+0x36e>
f0102aeb:	c7 44 24 0c a3 a2 10 	movl   $0xf010a2a3,0xc(%esp)
f0102af2:	f0 
f0102af3:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102afa:	f0 
f0102afb:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0102b02:	00 
f0102b03:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102b0a:	e8 c0 d7 ff ff       	call   f01002cf <_panic>
				assert(pgdir[i] & PTE_W);
f0102b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102b19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b1c:	01 d0                	add    %edx,%eax
f0102b1e:	8b 00                	mov    (%eax),%eax
f0102b20:	83 e0 02             	and    $0x2,%eax
f0102b23:	85 c0                	test   %eax,%eax
f0102b25:	75 5d                	jne    f0102b84 <check_kern_pgdir+0x3e3>
f0102b27:	c7 44 24 0c b4 a2 10 	movl   $0xf010a2b4,0xc(%esp)
f0102b2e:	f0 
f0102b2f:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102b36:	f0 
f0102b37:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102b3e:	00 
f0102b3f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102b46:	e8 84 d7 ff ff       	call   f01002cf <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b58:	01 d0                	add    %edx,%eax
f0102b5a:	8b 00                	mov    (%eax),%eax
f0102b5c:	85 c0                	test   %eax,%eax
f0102b5e:	74 24                	je     f0102b84 <check_kern_pgdir+0x3e3>
f0102b60:	c7 44 24 0c c5 a2 10 	movl   $0xf010a2c5,0xc(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102b6f:	f0 
f0102b70:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0102b77:	00 
f0102b78:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102b7f:	e8 4b d7 ff ff       	call   f01002cf <_panic>
			break;
f0102b84:	90                   	nop
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0102b89:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0102b90:	0f 86 e6 fe ff ff    	jbe    f0102a7c <check_kern_pgdir+0x2db>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b96:	c7 04 24 d4 a2 10 f0 	movl   $0xf010a2d4,(%esp)
f0102b9d:	e8 aa 23 00 00       	call   f0104f4c <cprintf>
}
f0102ba2:	83 c4 34             	add    $0x34,%esp
f0102ba5:	5b                   	pop    %ebx
f0102ba6:	5d                   	pop    %ebp
f0102ba7:	c3                   	ret    

f0102ba8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0102ba8:	55                   	push   %ebp
f0102ba9:	89 e5                	mov    %esp,%ebp
f0102bab:	83 ec 28             	sub    $0x28,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0102bae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bb1:	c1 e8 16             	shr    $0x16,%eax
f0102bb4:	c1 e0 02             	shl    $0x2,%eax
f0102bb7:	01 45 08             	add    %eax,0x8(%ebp)
	if (!(*pgdir & PTE_P))
f0102bba:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bbd:	8b 00                	mov    (%eax),%eax
f0102bbf:	83 e0 01             	and    $0x1,%eax
f0102bc2:	85 c0                	test   %eax,%eax
f0102bc4:	75 07                	jne    f0102bcd <check_va2pa+0x25>
		return ~0;
f0102bc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bcb:	eb 6a                	jmp    f0102c37 <check_va2pa+0x8f>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0102bcd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bd0:	8b 00                	mov    (%eax),%eax
f0102bd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102bd7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102bdb:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102be2:	00 
f0102be3:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102bea:	e8 f8 e5 ff ff       	call   f01011e7 <_kaddr>
f0102bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!(p[PTX(va)] & PTE_P))
f0102bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bf5:	c1 e8 0c             	shr    $0xc,%eax
f0102bf8:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102bfd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c07:	01 d0                	add    %edx,%eax
f0102c09:	8b 00                	mov    (%eax),%eax
f0102c0b:	83 e0 01             	and    $0x1,%eax
f0102c0e:	85 c0                	test   %eax,%eax
f0102c10:	75 07                	jne    f0102c19 <check_va2pa+0x71>
		return ~0;
f0102c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c17:	eb 1e                	jmp    f0102c37 <check_va2pa+0x8f>
	return PTE_ADDR(p[PTX(va)]);
f0102c19:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c1c:	c1 e8 0c             	shr    $0xc,%eax
f0102c1f:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102c24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c2e:	01 d0                	add    %edx,%eax
f0102c30:	8b 00                	mov    (%eax),%eax
f0102c32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f0102c37:	c9                   	leave  
f0102c38:	c3                   	ret    

f0102c39 <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f0102c39:	55                   	push   %ebp
f0102c3a:	89 e5                	mov    %esp,%ebp
f0102c3c:	53                   	push   %ebx
f0102c3d:	83 ec 44             	sub    $0x44,%esp
	uintptr_t mm1, mm2;
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0102c40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0102c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c50:	89 45 e8             	mov    %eax,-0x18(%ebp)
	assert((pp0 = page_alloc(0)));
f0102c53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c5a:	e8 23 ec ff ff       	call   f0101882 <page_alloc>
f0102c5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102c62:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102c66:	75 24                	jne    f0102c8c <check_page+0x53>
f0102c68:	c7 44 24 0c 64 a0 10 	movl   $0xf010a064,0xc(%esp)
f0102c6f:	f0 
f0102c70:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102c77:	f0 
f0102c78:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102c7f:	00 
f0102c80:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102c87:	e8 43 d6 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0102c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c93:	e8 ea eb ff ff       	call   f0101882 <page_alloc>
f0102c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102c9f:	75 24                	jne    f0102cc5 <check_page+0x8c>
f0102ca1:	c7 44 24 0c 7a a0 10 	movl   $0xf010a07a,0xc(%esp)
f0102ca8:	f0 
f0102ca9:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102cb0:	f0 
f0102cb1:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102cb8:	00 
f0102cb9:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102cc0:	e8 0a d6 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0102cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ccc:	e8 b1 eb ff ff       	call   f0101882 <page_alloc>
f0102cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102cd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102cd8:	75 24                	jne    f0102cfe <check_page+0xc5>
f0102cda:	c7 44 24 0c 90 a0 10 	movl   $0xf010a090,0xc(%esp)
f0102ce1:	f0 
f0102ce2:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102ce9:	f0 
f0102cea:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102cf1:	00 
f0102cf2:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102cf9:	e8 d1 d5 ff ff       	call   f01002cf <_panic>

	assert(pp0);
f0102cfe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102d02:	75 24                	jne    f0102d28 <check_page+0xef>
f0102d04:	c7 44 24 0c a6 a0 10 	movl   $0xf010a0a6,0xc(%esp)
f0102d0b:	f0 
f0102d0c:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102d13:	f0 
f0102d14:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102d1b:	00 
f0102d1c:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102d23:	e8 a7 d5 ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102d28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102d2c:	74 08                	je     f0102d36 <check_page+0xfd>
f0102d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d31:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102d34:	75 24                	jne    f0102d5a <check_page+0x121>
f0102d36:	c7 44 24 0c aa a0 10 	movl   $0xf010a0aa,0xc(%esp)
f0102d3d:	f0 
f0102d3e:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102d45:	f0 
f0102d46:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102d4d:	00 
f0102d4e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102d55:	e8 75 d5 ff ff       	call   f01002cf <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102d5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102d5e:	74 10                	je     f0102d70 <check_page+0x137>
f0102d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d63:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0102d66:	74 08                	je     f0102d70 <check_page+0x137>
f0102d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d6b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102d6e:	75 24                	jne    f0102d94 <check_page+0x15b>
f0102d70:	c7 44 24 0c bc a0 10 	movl   $0xf010a0bc,0xc(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102d7f:	f0 
f0102d80:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102d87:	00 
f0102d88:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102d8f:	e8 3b d5 ff ff       	call   f01002cf <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102d94:	a1 30 32 29 f0       	mov    0xf0293230,%eax
f0102d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	page_free_list = 0;
f0102d9c:	c7 05 30 32 29 f0 00 	movl   $0x0,0xf0293230
f0102da3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102da6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dad:	e8 d0 ea ff ff       	call   f0101882 <page_alloc>
f0102db2:	85 c0                	test   %eax,%eax
f0102db4:	74 24                	je     f0102dda <check_page+0x1a1>
f0102db6:	c7 44 24 0c 33 a1 10 	movl   $0xf010a133,0xc(%esp)
f0102dbd:	f0 
f0102dbe:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102dcd:	00 
f0102dce:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102dd5:	e8 f5 d4 ff ff       	call   f01002cf <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102dda:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102ddf:	8d 55 cc             	lea    -0x34(%ebp),%edx
f0102de2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102de6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102ded:	00 
f0102dee:	89 04 24             	mov    %eax,(%esp)
f0102df1:	e8 a7 ed ff ff       	call   f0101b9d <page_lookup>
f0102df6:	85 c0                	test   %eax,%eax
f0102df8:	74 24                	je     f0102e1e <check_page+0x1e5>
f0102dfa:	c7 44 24 0c f4 a2 10 	movl   $0xf010a2f4,0xc(%esp)
f0102e01:	f0 
f0102e02:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102e09:	f0 
f0102e0a:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102e11:	00 
f0102e12:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102e19:	e8 b1 d4 ff ff       	call   f01002cf <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102e1e:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102e23:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102e2a:	00 
f0102e2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e32:	00 
f0102e33:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102e36:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102e3a:	89 04 24             	mov    %eax,(%esp)
f0102e3d:	e8 c9 ec ff ff       	call   f0101b0b <page_insert>
f0102e42:	85 c0                	test   %eax,%eax
f0102e44:	78 24                	js     f0102e6a <check_page+0x231>
f0102e46:	c7 44 24 0c 2c a3 10 	movl   $0xf010a32c,0xc(%esp)
f0102e4d:	f0 
f0102e4e:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102e5d:	00 
f0102e5e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102e65:	e8 65 d4 ff ff       	call   f01002cf <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e6d:	89 04 24             	mov    %eax,(%esp)
f0102e70:	e8 70 ea ff ff       	call   f01018e5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102e75:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102e7a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102e81:	00 
f0102e82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e89:	00 
f0102e8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102e8d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102e91:	89 04 24             	mov    %eax,(%esp)
f0102e94:	e8 72 ec ff ff       	call   f0101b0b <page_insert>
f0102e99:	85 c0                	test   %eax,%eax
f0102e9b:	74 24                	je     f0102ec1 <check_page+0x288>
f0102e9d:	c7 44 24 0c 5c a3 10 	movl   $0xf010a35c,0xc(%esp)
f0102ea4:	f0 
f0102ea5:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102eac:	f0 
f0102ead:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102eb4:	00 
f0102eb5:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102ebc:	e8 0e d4 ff ff       	call   f01002cf <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ec1:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102ec6:	8b 00                	mov    (%eax),%eax
f0102ec8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ecd:	89 c3                	mov    %eax,%ebx
f0102ecf:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102ed2:	89 04 24             	mov    %eax,(%esp)
f0102ed5:	e8 4f e3 ff ff       	call   f0101229 <page2pa>
f0102eda:	39 c3                	cmp    %eax,%ebx
f0102edc:	74 24                	je     f0102f02 <check_page+0x2c9>
f0102ede:	c7 44 24 0c 8c a3 10 	movl   $0xf010a38c,0xc(%esp)
f0102ee5:	f0 
f0102ee6:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102eed:	f0 
f0102eee:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102ef5:	00 
f0102ef6:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102efd:	e8 cd d3 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102f02:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102f07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f0e:	00 
f0102f0f:	89 04 24             	mov    %eax,(%esp)
f0102f12:	e8 91 fc ff ff       	call   f0102ba8 <check_va2pa>
f0102f17:	89 c3                	mov    %eax,%ebx
f0102f19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f1c:	89 04 24             	mov    %eax,(%esp)
f0102f1f:	e8 05 e3 ff ff       	call   f0101229 <page2pa>
f0102f24:	39 c3                	cmp    %eax,%ebx
f0102f26:	74 24                	je     f0102f4c <check_page+0x313>
f0102f28:	c7 44 24 0c b4 a3 10 	movl   $0xf010a3b4,0xc(%esp)
f0102f2f:	f0 
f0102f30:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102f37:	f0 
f0102f38:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102f3f:	00 
f0102f40:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102f47:	e8 83 d3 ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 1);
f0102f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f4f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f53:	66 83 f8 01          	cmp    $0x1,%ax
f0102f57:	74 24                	je     f0102f7d <check_page+0x344>
f0102f59:	c7 44 24 0c e1 a3 10 	movl   $0xf010a3e1,0xc(%esp)
f0102f60:	f0 
f0102f61:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102f68:	f0 
f0102f69:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102f70:	00 
f0102f71:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102f78:	e8 52 d3 ff ff       	call   f01002cf <_panic>
	assert(pp0->pp_ref == 1);
f0102f7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f80:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f84:	66 83 f8 01          	cmp    $0x1,%ax
f0102f88:	74 24                	je     f0102fae <check_page+0x375>
f0102f8a:	c7 44 24 0c f2 a3 10 	movl   $0xf010a3f2,0xc(%esp)
f0102f91:	f0 
f0102f92:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102f99:	f0 
f0102f9a:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0102fa1:	00 
f0102fa2:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102fa9:	e8 21 d3 ff ff       	call   f01002cf <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102fae:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102fb3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102fba:	00 
f0102fbb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102fc2:	00 
f0102fc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102fc6:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102fca:	89 04 24             	mov    %eax,(%esp)
f0102fcd:	e8 39 eb ff ff       	call   f0101b0b <page_insert>
f0102fd2:	85 c0                	test   %eax,%eax
f0102fd4:	74 24                	je     f0102ffa <check_page+0x3c1>
f0102fd6:	c7 44 24 0c 04 a4 10 	movl   $0xf010a404,0xc(%esp)
f0102fdd:	f0 
f0102fde:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0102fe5:	f0 
f0102fe6:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102fed:	00 
f0102fee:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0102ff5:	e8 d5 d2 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102ffa:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0102fff:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103006:	00 
f0103007:	89 04 24             	mov    %eax,(%esp)
f010300a:	e8 99 fb ff ff       	call   f0102ba8 <check_va2pa>
f010300f:	89 c3                	mov    %eax,%ebx
f0103011:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103014:	89 04 24             	mov    %eax,(%esp)
f0103017:	e8 0d e2 ff ff       	call   f0101229 <page2pa>
f010301c:	39 c3                	cmp    %eax,%ebx
f010301e:	74 24                	je     f0103044 <check_page+0x40b>
f0103020:	c7 44 24 0c 40 a4 10 	movl   $0xf010a440,0xc(%esp)
f0103027:	f0 
f0103028:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010302f:	f0 
f0103030:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0103037:	00 
f0103038:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010303f:	e8 8b d2 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f0103044:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103047:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010304b:	66 83 f8 01          	cmp    $0x1,%ax
f010304f:	74 24                	je     f0103075 <check_page+0x43c>
f0103051:	c7 44 24 0c 70 a4 10 	movl   $0xf010a470,0xc(%esp)
f0103058:	f0 
f0103059:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103060:	f0 
f0103061:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0103068:	00 
f0103069:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103070:	e8 5a d2 ff ff       	call   f01002cf <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010307c:	e8 01 e8 ff ff       	call   f0101882 <page_alloc>
f0103081:	85 c0                	test   %eax,%eax
f0103083:	74 24                	je     f01030a9 <check_page+0x470>
f0103085:	c7 44 24 0c 33 a1 10 	movl   $0xf010a133,0xc(%esp)
f010308c:	f0 
f010308d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103094:	f0 
f0103095:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f010309c:	00 
f010309d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01030a4:	e8 26 d2 ff ff       	call   f01002cf <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01030a9:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01030ae:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01030b5:	00 
f01030b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030bd:	00 
f01030be:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01030c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01030c5:	89 04 24             	mov    %eax,(%esp)
f01030c8:	e8 3e ea ff ff       	call   f0101b0b <page_insert>
f01030cd:	85 c0                	test   %eax,%eax
f01030cf:	74 24                	je     f01030f5 <check_page+0x4bc>
f01030d1:	c7 44 24 0c 04 a4 10 	movl   $0xf010a404,0xc(%esp)
f01030d8:	f0 
f01030d9:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01030e0:	f0 
f01030e1:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01030e8:	00 
f01030e9:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01030f0:	e8 da d1 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01030f5:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01030fa:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103101:	00 
f0103102:	89 04 24             	mov    %eax,(%esp)
f0103105:	e8 9e fa ff ff       	call   f0102ba8 <check_va2pa>
f010310a:	89 c3                	mov    %eax,%ebx
f010310c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010310f:	89 04 24             	mov    %eax,(%esp)
f0103112:	e8 12 e1 ff ff       	call   f0101229 <page2pa>
f0103117:	39 c3                	cmp    %eax,%ebx
f0103119:	74 24                	je     f010313f <check_page+0x506>
f010311b:	c7 44 24 0c 40 a4 10 	movl   $0xf010a440,0xc(%esp)
f0103122:	f0 
f0103123:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010312a:	f0 
f010312b:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0103132:	00 
f0103133:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010313a:	e8 90 d1 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f010313f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103142:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103146:	66 83 f8 01          	cmp    $0x1,%ax
f010314a:	74 24                	je     f0103170 <check_page+0x537>
f010314c:	c7 44 24 0c 70 a4 10 	movl   $0xf010a470,0xc(%esp)
f0103153:	f0 
f0103154:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010315b:	f0 
f010315c:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0103163:	00 
f0103164:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010316b:	e8 5f d1 ff ff       	call   f01002cf <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103177:	e8 06 e7 ff ff       	call   f0101882 <page_alloc>
f010317c:	85 c0                	test   %eax,%eax
f010317e:	74 24                	je     f01031a4 <check_page+0x56b>
f0103180:	c7 44 24 0c 33 a1 10 	movl   $0xf010a133,0xc(%esp)
f0103187:	f0 
f0103188:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010318f:	f0 
f0103190:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0103197:	00 
f0103198:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010319f:	e8 2b d1 ff ff       	call   f01002cf <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01031a4:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01031a9:	8b 00                	mov    (%eax),%eax
f01031ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031b4:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f01031bb:	00 
f01031bc:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01031c3:	e8 1f e0 ff ff       	call   f01011e7 <_kaddr>
f01031c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01031cb:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01031d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031d7:	00 
f01031d8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01031df:	00 
f01031e0:	89 04 24             	mov    %eax,(%esp)
f01031e3:	e8 95 e7 ff ff       	call   f010197d <pgdir_walk>
f01031e8:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01031eb:	83 c2 04             	add    $0x4,%edx
f01031ee:	39 d0                	cmp    %edx,%eax
f01031f0:	74 24                	je     f0103216 <check_page+0x5dd>
f01031f2:	c7 44 24 0c 84 a4 10 	movl   $0xf010a484,0xc(%esp)
f01031f9:	f0 
f01031fa:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103201:	f0 
f0103202:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0103209:	00 
f010320a:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103211:	e8 b9 d0 ff ff       	call   f01002cf <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0103216:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010321b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103222:	00 
f0103223:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010322a:	00 
f010322b:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010322e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103232:	89 04 24             	mov    %eax,(%esp)
f0103235:	e8 d1 e8 ff ff       	call   f0101b0b <page_insert>
f010323a:	85 c0                	test   %eax,%eax
f010323c:	74 24                	je     f0103262 <check_page+0x629>
f010323e:	c7 44 24 0c c4 a4 10 	movl   $0xf010a4c4,0xc(%esp)
f0103245:	f0 
f0103246:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010324d:	f0 
f010324e:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0103255:	00 
f0103256:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010325d:	e8 6d d0 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103262:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103267:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010326e:	00 
f010326f:	89 04 24             	mov    %eax,(%esp)
f0103272:	e8 31 f9 ff ff       	call   f0102ba8 <check_va2pa>
f0103277:	89 c3                	mov    %eax,%ebx
f0103279:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010327c:	89 04 24             	mov    %eax,(%esp)
f010327f:	e8 a5 df ff ff       	call   f0101229 <page2pa>
f0103284:	39 c3                	cmp    %eax,%ebx
f0103286:	74 24                	je     f01032ac <check_page+0x673>
f0103288:	c7 44 24 0c 40 a4 10 	movl   $0xf010a440,0xc(%esp)
f010328f:	f0 
f0103290:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103297:	f0 
f0103298:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f010329f:	00 
f01032a0:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01032a7:	e8 23 d0 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f01032ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01032af:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01032b3:	66 83 f8 01          	cmp    $0x1,%ax
f01032b7:	74 24                	je     f01032dd <check_page+0x6a4>
f01032b9:	c7 44 24 0c 70 a4 10 	movl   $0xf010a470,0xc(%esp)
f01032c0:	f0 
f01032c1:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01032c8:	f0 
f01032c9:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01032d0:	00 
f01032d1:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01032d8:	e8 f2 cf ff ff       	call   f01002cf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01032dd:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01032e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01032e9:	00 
f01032ea:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01032f1:	00 
f01032f2:	89 04 24             	mov    %eax,(%esp)
f01032f5:	e8 83 e6 ff ff       	call   f010197d <pgdir_walk>
f01032fa:	8b 00                	mov    (%eax),%eax
f01032fc:	83 e0 04             	and    $0x4,%eax
f01032ff:	85 c0                	test   %eax,%eax
f0103301:	75 24                	jne    f0103327 <check_page+0x6ee>
f0103303:	c7 44 24 0c 04 a5 10 	movl   $0xf010a504,0xc(%esp)
f010330a:	f0 
f010330b:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103312:	f0 
f0103313:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f010331a:	00 
f010331b:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103322:	e8 a8 cf ff ff       	call   f01002cf <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0103327:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010332c:	8b 00                	mov    (%eax),%eax
f010332e:	83 e0 04             	and    $0x4,%eax
f0103331:	85 c0                	test   %eax,%eax
f0103333:	75 24                	jne    f0103359 <check_page+0x720>
f0103335:	c7 44 24 0c 37 a5 10 	movl   $0xf010a537,0xc(%esp)
f010333c:	f0 
f010333d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103344:	f0 
f0103345:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f010334c:	00 
f010334d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103354:	e8 76 cf ff ff       	call   f01002cf <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103359:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010335e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103365:	00 
f0103366:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010336d:	00 
f010336e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103371:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103375:	89 04 24             	mov    %eax,(%esp)
f0103378:	e8 8e e7 ff ff       	call   f0101b0b <page_insert>
f010337d:	85 c0                	test   %eax,%eax
f010337f:	74 24                	je     f01033a5 <check_page+0x76c>
f0103381:	c7 44 24 0c 04 a4 10 	movl   $0xf010a404,0xc(%esp)
f0103388:	f0 
f0103389:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103390:	f0 
f0103391:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0103398:	00 
f0103399:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01033a0:	e8 2a cf ff ff       	call   f01002cf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01033a5:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01033aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01033b1:	00 
f01033b2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033b9:	00 
f01033ba:	89 04 24             	mov    %eax,(%esp)
f01033bd:	e8 bb e5 ff ff       	call   f010197d <pgdir_walk>
f01033c2:	8b 00                	mov    (%eax),%eax
f01033c4:	83 e0 02             	and    $0x2,%eax
f01033c7:	85 c0                	test   %eax,%eax
f01033c9:	75 24                	jne    f01033ef <check_page+0x7b6>
f01033cb:	c7 44 24 0c 50 a5 10 	movl   $0xf010a550,0xc(%esp)
f01033d2:	f0 
f01033d3:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01033da:	f0 
f01033db:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01033e2:	00 
f01033e3:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01033ea:	e8 e0 ce ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01033ef:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01033f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01033fb:	00 
f01033fc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103403:	00 
f0103404:	89 04 24             	mov    %eax,(%esp)
f0103407:	e8 71 e5 ff ff       	call   f010197d <pgdir_walk>
f010340c:	8b 00                	mov    (%eax),%eax
f010340e:	83 e0 04             	and    $0x4,%eax
f0103411:	85 c0                	test   %eax,%eax
f0103413:	74 24                	je     f0103439 <check_page+0x800>
f0103415:	c7 44 24 0c 84 a5 10 	movl   $0xf010a584,0xc(%esp)
f010341c:	f0 
f010341d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103424:	f0 
f0103425:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f010342c:	00 
f010342d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103434:	e8 96 ce ff ff       	call   f01002cf <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0103439:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010343e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103445:	00 
f0103446:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010344d:	00 
f010344e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103451:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103455:	89 04 24             	mov    %eax,(%esp)
f0103458:	e8 ae e6 ff ff       	call   f0101b0b <page_insert>
f010345d:	85 c0                	test   %eax,%eax
f010345f:	78 24                	js     f0103485 <check_page+0x84c>
f0103461:	c7 44 24 0c bc a5 10 	movl   $0xf010a5bc,0xc(%esp)
f0103468:	f0 
f0103469:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103470:	f0 
f0103471:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0103478:	00 
f0103479:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103480:	e8 4a ce ff ff       	call   f01002cf <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103485:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010348a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103491:	00 
f0103492:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103499:	00 
f010349a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010349d:	89 54 24 04          	mov    %edx,0x4(%esp)
f01034a1:	89 04 24             	mov    %eax,(%esp)
f01034a4:	e8 62 e6 ff ff       	call   f0101b0b <page_insert>
f01034a9:	85 c0                	test   %eax,%eax
f01034ab:	74 24                	je     f01034d1 <check_page+0x898>
f01034ad:	c7 44 24 0c f4 a5 10 	movl   $0xf010a5f4,0xc(%esp)
f01034b4:	f0 
f01034b5:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01034bc:	f0 
f01034bd:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01034c4:	00 
f01034c5:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01034cc:	e8 fe cd ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01034d1:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01034d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034dd:	00 
f01034de:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01034e5:	00 
f01034e6:	89 04 24             	mov    %eax,(%esp)
f01034e9:	e8 8f e4 ff ff       	call   f010197d <pgdir_walk>
f01034ee:	8b 00                	mov    (%eax),%eax
f01034f0:	83 e0 04             	and    $0x4,%eax
f01034f3:	85 c0                	test   %eax,%eax
f01034f5:	74 24                	je     f010351b <check_page+0x8e2>
f01034f7:	c7 44 24 0c 84 a5 10 	movl   $0xf010a584,0xc(%esp)
f01034fe:	f0 
f01034ff:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103506:	f0 
f0103507:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010350e:	00 
f010350f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103516:	e8 b4 cd ff ff       	call   f01002cf <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010351b:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103527:	00 
f0103528:	89 04 24             	mov    %eax,(%esp)
f010352b:	e8 78 f6 ff ff       	call   f0102ba8 <check_va2pa>
f0103530:	89 c3                	mov    %eax,%ebx
f0103532:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103535:	89 04 24             	mov    %eax,(%esp)
f0103538:	e8 ec dc ff ff       	call   f0101229 <page2pa>
f010353d:	39 c3                	cmp    %eax,%ebx
f010353f:	74 24                	je     f0103565 <check_page+0x92c>
f0103541:	c7 44 24 0c 30 a6 10 	movl   $0xf010a630,0xc(%esp)
f0103548:	f0 
f0103549:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103550:	f0 
f0103551:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0103558:	00 
f0103559:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103560:	e8 6a cd ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103565:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010356a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103571:	00 
f0103572:	89 04 24             	mov    %eax,(%esp)
f0103575:	e8 2e f6 ff ff       	call   f0102ba8 <check_va2pa>
f010357a:	89 c3                	mov    %eax,%ebx
f010357c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010357f:	89 04 24             	mov    %eax,(%esp)
f0103582:	e8 a2 dc ff ff       	call   f0101229 <page2pa>
f0103587:	39 c3                	cmp    %eax,%ebx
f0103589:	74 24                	je     f01035af <check_page+0x976>
f010358b:	c7 44 24 0c 5c a6 10 	movl   $0xf010a65c,0xc(%esp)
f0103592:	f0 
f0103593:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010359a:	f0 
f010359b:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01035a2:	00 
f01035a3:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01035aa:	e8 20 cd ff ff       	call   f01002cf <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01035af:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01035b2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01035b6:	66 83 f8 02          	cmp    $0x2,%ax
f01035ba:	74 24                	je     f01035e0 <check_page+0x9a7>
f01035bc:	c7 44 24 0c 8c a6 10 	movl   $0xf010a68c,0xc(%esp)
f01035c3:	f0 
f01035c4:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01035cb:	f0 
f01035cc:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01035d3:	00 
f01035d4:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01035db:	e8 ef cc ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f01035e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01035e3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01035e7:	66 85 c0             	test   %ax,%ax
f01035ea:	74 24                	je     f0103610 <check_page+0x9d7>
f01035ec:	c7 44 24 0c 9d a6 10 	movl   $0xf010a69d,0xc(%esp)
f01035f3:	f0 
f01035f4:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01035fb:	f0 
f01035fc:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0103603:	00 
f0103604:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010360b:	e8 bf cc ff ff       	call   f01002cf <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0103610:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103617:	e8 66 e2 ff ff       	call   f0101882 <page_alloc>
f010361c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010361f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103623:	74 08                	je     f010362d <check_page+0x9f4>
f0103625:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103628:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010362b:	74 24                	je     f0103651 <check_page+0xa18>
f010362d:	c7 44 24 0c b0 a6 10 	movl   $0xf010a6b0,0xc(%esp)
f0103634:	f0 
f0103635:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010363c:	f0 
f010363d:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0103644:	00 
f0103645:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010364c:	e8 7e cc ff ff       	call   f01002cf <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0103651:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103656:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010365d:	00 
f010365e:	89 04 24             	mov    %eax,(%esp)
f0103661:	e8 8a e5 ff ff       	call   f0101bf0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103666:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010366b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103672:	00 
f0103673:	89 04 24             	mov    %eax,(%esp)
f0103676:	e8 2d f5 ff ff       	call   f0102ba8 <check_va2pa>
f010367b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010367e:	74 24                	je     f01036a4 <check_page+0xa6b>
f0103680:	c7 44 24 0c d4 a6 10 	movl   $0xf010a6d4,0xc(%esp)
f0103687:	f0 
f0103688:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010368f:	f0 
f0103690:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0103697:	00 
f0103698:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010369f:	e8 2b cc ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01036a4:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01036a9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01036b0:	00 
f01036b1:	89 04 24             	mov    %eax,(%esp)
f01036b4:	e8 ef f4 ff ff       	call   f0102ba8 <check_va2pa>
f01036b9:	89 c3                	mov    %eax,%ebx
f01036bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01036be:	89 04 24             	mov    %eax,(%esp)
f01036c1:	e8 63 db ff ff       	call   f0101229 <page2pa>
f01036c6:	39 c3                	cmp    %eax,%ebx
f01036c8:	74 24                	je     f01036ee <check_page+0xab5>
f01036ca:	c7 44 24 0c 5c a6 10 	movl   $0xf010a65c,0xc(%esp)
f01036d1:	f0 
f01036d2:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01036d9:	f0 
f01036da:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01036e1:	00 
f01036e2:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01036e9:	e8 e1 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 1);
f01036ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01036f1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01036f5:	66 83 f8 01          	cmp    $0x1,%ax
f01036f9:	74 24                	je     f010371f <check_page+0xae6>
f01036fb:	c7 44 24 0c e1 a3 10 	movl   $0xf010a3e1,0xc(%esp)
f0103702:	f0 
f0103703:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010370a:	f0 
f010370b:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0103712:	00 
f0103713:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010371a:	e8 b0 cb ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f010371f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103722:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103726:	66 85 c0             	test   %ax,%ax
f0103729:	74 24                	je     f010374f <check_page+0xb16>
f010372b:	c7 44 24 0c 9d a6 10 	movl   $0xf010a69d,0xc(%esp)
f0103732:	f0 
f0103733:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010373a:	f0 
f010373b:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103742:	00 
f0103743:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010374a:	e8 80 cb ff ff       	call   f01002cf <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010374f:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103754:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010375b:	00 
f010375c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103763:	00 
f0103764:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103767:	89 54 24 04          	mov    %edx,0x4(%esp)
f010376b:	89 04 24             	mov    %eax,(%esp)
f010376e:	e8 98 e3 ff ff       	call   f0101b0b <page_insert>
f0103773:	85 c0                	test   %eax,%eax
f0103775:	74 24                	je     f010379b <check_page+0xb62>
f0103777:	c7 44 24 0c f8 a6 10 	movl   $0xf010a6f8,0xc(%esp)
f010377e:	f0 
f010377f:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103786:	f0 
f0103787:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f010378e:	00 
f010378f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103796:	e8 34 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref);
f010379b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010379e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01037a2:	66 85 c0             	test   %ax,%ax
f01037a5:	75 24                	jne    f01037cb <check_page+0xb92>
f01037a7:	c7 44 24 0c 2d a7 10 	movl   $0xf010a72d,0xc(%esp)
f01037ae:	f0 
f01037af:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01037b6:	f0 
f01037b7:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f01037be:	00 
f01037bf:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01037c6:	e8 04 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_link == NULL);
f01037cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037ce:	8b 00                	mov    (%eax),%eax
f01037d0:	85 c0                	test   %eax,%eax
f01037d2:	74 24                	je     f01037f8 <check_page+0xbbf>
f01037d4:	c7 44 24 0c 39 a7 10 	movl   $0xf010a739,0xc(%esp)
f01037db:	f0 
f01037dc:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01037e3:	f0 
f01037e4:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01037eb:	00 
f01037ec:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01037f3:	e8 d7 ca ff ff       	call   f01002cf <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01037f8:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01037fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103804:	00 
f0103805:	89 04 24             	mov    %eax,(%esp)
f0103808:	e8 e3 e3 ff ff       	call   f0101bf0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010380d:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103812:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103819:	00 
f010381a:	89 04 24             	mov    %eax,(%esp)
f010381d:	e8 86 f3 ff ff       	call   f0102ba8 <check_va2pa>
f0103822:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103825:	74 24                	je     f010384b <check_page+0xc12>
f0103827:	c7 44 24 0c d4 a6 10 	movl   $0xf010a6d4,0xc(%esp)
f010382e:	f0 
f010382f:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103836:	f0 
f0103837:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f010383e:	00 
f010383f:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103846:	e8 84 ca ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010384b:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103850:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103857:	00 
f0103858:	89 04 24             	mov    %eax,(%esp)
f010385b:	e8 48 f3 ff ff       	call   f0102ba8 <check_va2pa>
f0103860:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103863:	74 24                	je     f0103889 <check_page+0xc50>
f0103865:	c7 44 24 0c 50 a7 10 	movl   $0xf010a750,0xc(%esp)
f010386c:	f0 
f010386d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103874:	f0 
f0103875:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010387c:	00 
f010387d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103884:	e8 46 ca ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 0);
f0103889:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010388c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103890:	66 85 c0             	test   %ax,%ax
f0103893:	74 24                	je     f01038b9 <check_page+0xc80>
f0103895:	c7 44 24 0c 76 a7 10 	movl   $0xf010a776,0xc(%esp)
f010389c:	f0 
f010389d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01038a4:	f0 
f01038a5:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01038ac:	00 
f01038ad:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01038b4:	e8 16 ca ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f01038b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01038bc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01038c0:	66 85 c0             	test   %ax,%ax
f01038c3:	74 24                	je     f01038e9 <check_page+0xcb0>
f01038c5:	c7 44 24 0c 9d a6 10 	movl   $0xf010a69d,0xc(%esp)
f01038cc:	f0 
f01038cd:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01038d4:	f0 
f01038d5:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01038dc:	00 
f01038dd:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01038e4:	e8 e6 c9 ff ff       	call   f01002cf <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01038e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01038f0:	e8 8d df ff ff       	call   f0101882 <page_alloc>
f01038f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01038f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01038fc:	74 08                	je     f0103906 <check_page+0xccd>
f01038fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103901:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0103904:	74 24                	je     f010392a <check_page+0xcf1>
f0103906:	c7 44 24 0c 88 a7 10 	movl   $0xf010a788,0xc(%esp)
f010390d:	f0 
f010390e:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103915:	f0 
f0103916:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f010391d:	00 
f010391e:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103925:	e8 a5 c9 ff ff       	call   f01002cf <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010392a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103931:	e8 4c df ff ff       	call   f0101882 <page_alloc>
f0103936:	85 c0                	test   %eax,%eax
f0103938:	74 24                	je     f010395e <check_page+0xd25>
f010393a:	c7 44 24 0c 33 a1 10 	movl   $0xf010a133,0xc(%esp)
f0103941:	f0 
f0103942:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103949:	f0 
f010394a:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0103951:	00 
f0103952:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103959:	e8 71 c9 ff ff       	call   f01002cf <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010395e:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103963:	8b 00                	mov    (%eax),%eax
f0103965:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010396a:	89 c3                	mov    %eax,%ebx
f010396c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010396f:	89 04 24             	mov    %eax,(%esp)
f0103972:	e8 b2 d8 ff ff       	call   f0101229 <page2pa>
f0103977:	39 c3                	cmp    %eax,%ebx
f0103979:	74 24                	je     f010399f <check_page+0xd66>
f010397b:	c7 44 24 0c 8c a3 10 	movl   $0xf010a38c,0xc(%esp)
f0103982:	f0 
f0103983:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010398a:	f0 
f010398b:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0103992:	00 
f0103993:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010399a:	e8 30 c9 ff ff       	call   f01002cf <_panic>
	kern_pgdir[0] = 0;
f010399f:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01039a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01039aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039ad:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01039b1:	66 83 f8 01          	cmp    $0x1,%ax
f01039b5:	74 24                	je     f01039db <check_page+0xda2>
f01039b7:	c7 44 24 0c f2 a3 10 	movl   $0xf010a3f2,0xc(%esp)
f01039be:	f0 
f01039bf:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01039c6:	f0 
f01039c7:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01039ce:	00 
f01039cf:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01039d6:	e8 f4 c8 ff ff       	call   f01002cf <_panic>
	pp0->pp_ref = 0;
f01039db:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039de:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01039e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039e7:	89 04 24             	mov    %eax,(%esp)
f01039ea:	e8 f6 de ff ff       	call   f01018e5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
f01039ef:	c7 45 dc 00 10 40 00 	movl   $0x401000,-0x24(%ebp)
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01039f6:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01039fb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a02:	00 
f0103a03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a06:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a0a:	89 04 24             	mov    %eax,(%esp)
f0103a0d:	e8 6b df ff ff       	call   f010197d <pgdir_walk>
f0103a12:	89 45 cc             	mov    %eax,-0x34(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103a15:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103a1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a1d:	c1 ea 16             	shr    $0x16,%edx
f0103a20:	c1 e2 02             	shl    $0x2,%edx
f0103a23:	01 d0                	add    %edx,%eax
f0103a25:	8b 00                	mov    (%eax),%eax
f0103a27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a30:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0103a37:	00 
f0103a38:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103a3f:	e8 a3 d7 ff ff       	call   f01011e7 <_kaddr>
f0103a44:	89 45 d8             	mov    %eax,-0x28(%ebp)
	assert(ptep == ptep1 + PTX(va));
f0103a47:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a4a:	c1 e8 0c             	shr    $0xc,%eax
f0103a4d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103a52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0103a59:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a5c:	01 c2                	add    %eax,%edx
f0103a5e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103a61:	39 c2                	cmp    %eax,%edx
f0103a63:	74 24                	je     f0103a89 <check_page+0xe50>
f0103a65:	c7 44 24 0c aa a7 10 	movl   $0xf010a7aa,0xc(%esp)
f0103a6c:	f0 
f0103a6d:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103a74:	f0 
f0103a75:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0103a7c:	00 
f0103a7d:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103a84:	e8 46 c8 ff ff       	call   f01002cf <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103a89:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103a8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a91:	c1 ea 16             	shr    $0x16,%edx
f0103a94:	c1 e2 02             	shl    $0x2,%edx
f0103a97:	01 d0                	add    %edx,%eax
f0103a99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103a9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103aa2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0103aa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103aab:	89 04 24             	mov    %eax,(%esp)
f0103aae:	e8 d2 d7 ff ff       	call   f0101285 <page2kva>
f0103ab3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103aba:	00 
f0103abb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103ac2:	00 
f0103ac3:	89 04 24             	mov    %eax,(%esp)
f0103ac6:	e8 dc 4c 00 00       	call   f01087a7 <memset>
	page_free(pp0);
f0103acb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ace:	89 04 24             	mov    %eax,(%esp)
f0103ad1:	e8 0f de ff ff       	call   f01018e5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103ad6:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103adb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103ae2:	00 
f0103ae3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103aea:	00 
f0103aeb:	89 04 24             	mov    %eax,(%esp)
f0103aee:	e8 8a de ff ff       	call   f010197d <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0103af3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103af6:	89 04 24             	mov    %eax,(%esp)
f0103af9:	e8 87 d7 ff ff       	call   f0101285 <page2kva>
f0103afe:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for(i=0; i<NPTENTRIES; i++)
f0103b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0103b08:	eb 3c                	jmp    f0103b46 <check_page+0xf0d>
		assert((ptep[i] & PTE_P) == 0);
f0103b0a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b10:	c1 e2 02             	shl    $0x2,%edx
f0103b13:	01 d0                	add    %edx,%eax
f0103b15:	8b 00                	mov    (%eax),%eax
f0103b17:	83 e0 01             	and    $0x1,%eax
f0103b1a:	85 c0                	test   %eax,%eax
f0103b1c:	74 24                	je     f0103b42 <check_page+0xf09>
f0103b1e:	c7 44 24 0c c2 a7 10 	movl   $0xf010a7c2,0xc(%esp)
f0103b25:	f0 
f0103b26:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103b2d:	f0 
f0103b2e:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0103b35:	00 
f0103b36:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103b3d:	e8 8d c7 ff ff       	call   f01002cf <_panic>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0103b42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0103b46:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0103b4d:	7e bb                	jle    f0103b0a <check_page+0xed1>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0103b4f:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103b54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b5d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0103b63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b66:	a3 30 32 29 f0       	mov    %eax,0xf0293230

	// free the pages we took
	page_free(pp0);
f0103b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b6e:	89 04 24             	mov    %eax,(%esp)
f0103b71:	e8 6f dd ff ff       	call   f01018e5 <page_free>
	page_free(pp1);
f0103b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b79:	89 04 24             	mov    %eax,(%esp)
f0103b7c:	e8 64 dd ff ff       	call   f01018e5 <page_free>
	page_free(pp2);
f0103b81:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b84:	89 04 24             	mov    %eax,(%esp)
f0103b87:	e8 59 dd ff ff       	call   f01018e5 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0103b8c:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0103b93:	00 
f0103b94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103b9b:	e8 de e0 ff ff       	call   f0101c7e <mmio_map_region>
f0103ba0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0103ba3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103baa:	00 
f0103bab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103bb2:	e8 c7 e0 ff ff       	call   f0101c7e <mmio_map_region>
f0103bb7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0103bba:	81 7d d4 ff ff 7f ef 	cmpl   $0xef7fffff,-0x2c(%ebp)
f0103bc1:	76 0f                	jbe    f0103bd2 <check_page+0xf99>
f0103bc3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bc6:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103bcb:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103bd0:	76 24                	jbe    f0103bf6 <check_page+0xfbd>
f0103bd2:	c7 44 24 0c dc a7 10 	movl   $0xf010a7dc,0xc(%esp)
f0103bd9:	f0 
f0103bda:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103be1:	f0 
f0103be2:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f0103be9:	00 
f0103bea:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103bf1:	e8 d9 c6 ff ff       	call   f01002cf <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103bf6:	81 7d d0 ff ff 7f ef 	cmpl   $0xef7fffff,-0x30(%ebp)
f0103bfd:	76 0f                	jbe    f0103c0e <check_page+0xfd5>
f0103bff:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c02:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c07:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103c0c:	76 24                	jbe    f0103c32 <check_page+0xff9>
f0103c0e:	c7 44 24 0c 04 a8 10 	movl   $0xf010a804,0xc(%esp)
f0103c15:	f0 
f0103c16:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103c1d:	f0 
f0103c1e:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f0103c25:	00 
f0103c26:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103c2d:	e8 9d c6 ff ff       	call   f01002cf <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0103c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c35:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103c3a:	85 c0                	test   %eax,%eax
f0103c3c:	75 0c                	jne    f0103c4a <check_page+0x1011>
f0103c3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c41:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103c46:	85 c0                	test   %eax,%eax
f0103c48:	74 24                	je     f0103c6e <check_page+0x1035>
f0103c4a:	c7 44 24 0c 2c a8 10 	movl   $0xf010a82c,0xc(%esp)
f0103c51:	f0 
f0103c52:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103c59:	f0 
f0103c5a:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0103c61:	00 
f0103c62:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103c69:	e8 61 c6 ff ff       	call   f01002cf <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0103c6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c71:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c76:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103c79:	76 24                	jbe    f0103c9f <check_page+0x1066>
f0103c7b:	c7 44 24 0c 53 a8 10 	movl   $0xf010a853,0xc(%esp)
f0103c82:	f0 
f0103c83:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103c8a:	f0 
f0103c8b:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0103c92:	00 
f0103c93:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103c9a:	e8 30 c6 ff ff       	call   f01002cf <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103c9f:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103ca4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ca7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103cab:	89 04 24             	mov    %eax,(%esp)
f0103cae:	e8 f5 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103cb3:	85 c0                	test   %eax,%eax
f0103cb5:	74 24                	je     f0103cdb <check_page+0x10a2>
f0103cb7:	c7 44 24 0c 68 a8 10 	movl   $0xf010a868,0xc(%esp)
f0103cbe:	f0 
f0103cbf:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103cc6:	f0 
f0103cc7:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0103cce:	00 
f0103ccf:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103cd6:	e8 f4 c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0103cdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103cde:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103ce4:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103ce9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ced:	89 04 24             	mov    %eax,(%esp)
f0103cf0:	e8 b3 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103cf5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103cfa:	74 24                	je     f0103d20 <check_page+0x10e7>
f0103cfc:	c7 44 24 0c 8c a8 10 	movl   $0xf010a88c,0xc(%esp)
f0103d03:	f0 
f0103d04:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103d0b:	f0 
f0103d0c:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0103d13:	00 
f0103d14:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103d1b:	e8 af c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0103d20:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103d25:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103d28:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d2c:	89 04 24             	mov    %eax,(%esp)
f0103d2f:	e8 74 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103d34:	85 c0                	test   %eax,%eax
f0103d36:	74 24                	je     f0103d5c <check_page+0x1123>
f0103d38:	c7 44 24 0c bc a8 10 	movl   $0xf010a8bc,0xc(%esp)
f0103d3f:	f0 
f0103d40:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103d47:	f0 
f0103d48:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0103d4f:	00 
f0103d50:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103d57:	e8 73 c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103d5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d5f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103d65:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103d6a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d6e:	89 04 24             	mov    %eax,(%esp)
f0103d71:	e8 32 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103d76:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d79:	74 24                	je     f0103d9f <check_page+0x1166>
f0103d7b:	c7 44 24 0c e0 a8 10 	movl   $0xf010a8e0,0xc(%esp)
f0103d82:	f0 
f0103d83:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103d8a:	f0 
f0103d8b:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0103d92:	00 
f0103d93:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103d9a:	e8 30 c5 ff ff       	call   f01002cf <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0103d9f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103da2:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103da7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103dae:	00 
f0103daf:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103db3:	89 04 24             	mov    %eax,(%esp)
f0103db6:	e8 c2 db ff ff       	call   f010197d <pgdir_walk>
f0103dbb:	8b 00                	mov    (%eax),%eax
f0103dbd:	83 e0 1a             	and    $0x1a,%eax
f0103dc0:	85 c0                	test   %eax,%eax
f0103dc2:	75 24                	jne    f0103de8 <check_page+0x11af>
f0103dc4:	c7 44 24 0c 0c a9 10 	movl   $0xf010a90c,0xc(%esp)
f0103dcb:	f0 
f0103dcc:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103dd3:	f0 
f0103dd4:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0103ddb:	00 
f0103ddc:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103de3:	e8 e7 c4 ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0103de8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103deb:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103df0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103df7:	00 
f0103df8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103dfc:	89 04 24             	mov    %eax,(%esp)
f0103dff:	e8 79 db ff ff       	call   f010197d <pgdir_walk>
f0103e04:	8b 00                	mov    (%eax),%eax
f0103e06:	83 e0 04             	and    $0x4,%eax
f0103e09:	85 c0                	test   %eax,%eax
f0103e0b:	74 24                	je     f0103e31 <check_page+0x11f8>
f0103e0d:	c7 44 24 0c 50 a9 10 	movl   $0xf010a950,0xc(%esp)
f0103e14:	f0 
f0103e15:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103e1c:	f0 
f0103e1d:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0103e24:	00 
f0103e25:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103e2c:	e8 9e c4 ff ff       	call   f01002cf <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103e31:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e34:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103e39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e40:	00 
f0103e41:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e45:	89 04 24             	mov    %eax,(%esp)
f0103e48:	e8 30 db ff ff       	call   f010197d <pgdir_walk>
f0103e4d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103e53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103e56:	05 00 10 00 00       	add    $0x1000,%eax
f0103e5b:	89 c2                	mov    %eax,%edx
f0103e5d:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103e62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e69:	00 
f0103e6a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e6e:	89 04 24             	mov    %eax,(%esp)
f0103e71:	e8 07 db ff ff       	call   f010197d <pgdir_walk>
f0103e76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103e7c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103e7f:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103e84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e8b:	00 
f0103e8c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e90:	89 04 24             	mov    %eax,(%esp)
f0103e93:	e8 e5 da ff ff       	call   f010197d <pgdir_walk>
f0103e98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103e9e:	c7 04 24 83 a9 10 f0 	movl   $0xf010a983,(%esp)
f0103ea5:	e8 a2 10 00 00       	call   f0104f4c <cprintf>
}
f0103eaa:	83 c4 44             	add    $0x44,%esp
f0103ead:	5b                   	pop    %ebx
f0103eae:	5d                   	pop    %ebp
f0103eaf:	c3                   	ret    

f0103eb0 <check_page_installed_pgdir>:

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0103eb0:	55                   	push   %ebp
f0103eb1:	89 e5                	mov    %esp,%ebp
f0103eb3:	53                   	push   %ebx
f0103eb4:	83 ec 24             	sub    $0x24,%esp
	pte_t *ptep, *ptep1;
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
f0103eb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0103ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ec1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert((pp0 = page_alloc(0)));
f0103ec4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ecb:	e8 b2 d9 ff ff       	call   f0101882 <page_alloc>
f0103ed0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ed3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0103ed7:	75 24                	jne    f0103efd <check_page_installed_pgdir+0x4d>
f0103ed9:	c7 44 24 0c 64 a0 10 	movl   $0xf010a064,0xc(%esp)
f0103ee0:	f0 
f0103ee1:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103ee8:	f0 
f0103ee9:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0103ef0:	00 
f0103ef1:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103ef8:	e8 d2 c3 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0103efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f04:	e8 79 d9 ff ff       	call   f0101882 <page_alloc>
f0103f09:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0103f10:	75 24                	jne    f0103f36 <check_page_installed_pgdir+0x86>
f0103f12:	c7 44 24 0c 7a a0 10 	movl   $0xf010a07a,0xc(%esp)
f0103f19:	f0 
f0103f1a:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103f21:	f0 
f0103f22:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0103f29:	00 
f0103f2a:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103f31:	e8 99 c3 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0103f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f3d:	e8 40 d9 ff ff       	call   f0101882 <page_alloc>
f0103f42:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103f45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103f49:	75 24                	jne    f0103f6f <check_page_installed_pgdir+0xbf>
f0103f4b:	c7 44 24 0c 90 a0 10 	movl   $0xf010a090,0xc(%esp)
f0103f52:	f0 
f0103f53:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0103f5a:	f0 
f0103f5b:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0103f62:	00 
f0103f63:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0103f6a:	e8 60 c3 ff ff       	call   f01002cf <_panic>
	page_free(pp0);
f0103f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f72:	89 04 24             	mov    %eax,(%esp)
f0103f75:	e8 6b d9 ff ff       	call   f01018e5 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f7d:	89 04 24             	mov    %eax,(%esp)
f0103f80:	e8 00 d3 ff ff       	call   f0101285 <page2kva>
f0103f85:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f8c:	00 
f0103f8d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103f94:	00 
f0103f95:	89 04 24             	mov    %eax,(%esp)
f0103f98:	e8 0a 48 00 00       	call   f01087a7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fa0:	89 04 24             	mov    %eax,(%esp)
f0103fa3:	e8 dd d2 ff ff       	call   f0101285 <page2kva>
f0103fa8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103faf:	00 
f0103fb0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103fb7:	00 
f0103fb8:	89 04 24             	mov    %eax,(%esp)
f0103fbb:	e8 e7 47 00 00       	call   f01087a7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103fc0:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0103fc5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103fcc:	00 
f0103fcd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103fd4:	00 
f0103fd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103fd8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103fdc:	89 04 24             	mov    %eax,(%esp)
f0103fdf:	e8 27 db ff ff       	call   f0101b0b <page_insert>
	assert(pp1->pp_ref == 1);
f0103fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103fe7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103feb:	66 83 f8 01          	cmp    $0x1,%ax
f0103fef:	74 24                	je     f0104015 <check_page_installed_pgdir+0x165>
f0103ff1:	c7 44 24 0c e1 a3 10 	movl   $0xf010a3e1,0xc(%esp)
f0103ff8:	f0 
f0103ff9:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0104000:	f0 
f0104001:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f0104008:	00 
f0104009:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0104010:	e8 ba c2 ff ff       	call   f01002cf <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0104015:	b8 00 10 00 00       	mov    $0x1000,%eax
f010401a:	8b 00                	mov    (%eax),%eax
f010401c:	3d 01 01 01 01       	cmp    $0x1010101,%eax
f0104021:	74 24                	je     f0104047 <check_page_installed_pgdir+0x197>
f0104023:	c7 44 24 0c 9c a9 10 	movl   $0xf010a99c,0xc(%esp)
f010402a:	f0 
f010402b:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0104032:	f0 
f0104033:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f010403a:	00 
f010403b:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0104042:	e8 88 c2 ff ff       	call   f01002cf <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0104047:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010404c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104053:	00 
f0104054:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010405b:	00 
f010405c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010405f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104063:	89 04 24             	mov    %eax,(%esp)
f0104066:	e8 a0 da ff ff       	call   f0101b0b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010406b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0104070:	8b 00                	mov    (%eax),%eax
f0104072:	3d 02 02 02 02       	cmp    $0x2020202,%eax
f0104077:	74 24                	je     f010409d <check_page_installed_pgdir+0x1ed>
f0104079:	c7 44 24 0c c0 a9 10 	movl   $0xf010a9c0,0xc(%esp)
f0104080:	f0 
f0104081:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0104088:	f0 
f0104089:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0104090:	00 
f0104091:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0104098:	e8 32 c2 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040a0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01040a4:	66 83 f8 01          	cmp    $0x1,%ax
f01040a8:	74 24                	je     f01040ce <check_page_installed_pgdir+0x21e>
f01040aa:	c7 44 24 0c 70 a4 10 	movl   $0xf010a470,0xc(%esp)
f01040b1:	f0 
f01040b2:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01040b9:	f0 
f01040ba:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01040c1:	00 
f01040c2:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01040c9:	e8 01 c2 ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 0);
f01040ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01040d1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01040d5:	66 85 c0             	test   %ax,%ax
f01040d8:	74 24                	je     f01040fe <check_page_installed_pgdir+0x24e>
f01040da:	c7 44 24 0c 76 a7 10 	movl   $0xf010a776,0xc(%esp)
f01040e1:	f0 
f01040e2:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01040e9:	f0 
f01040ea:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01040f1:	00 
f01040f2:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01040f9:	e8 d1 c1 ff ff       	call   f01002cf <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01040fe:	b8 00 10 00 00       	mov    $0x1000,%eax
f0104103:	c7 00 03 03 03 03    	movl   $0x3030303,(%eax)
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0104109:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010410c:	89 04 24             	mov    %eax,(%esp)
f010410f:	e8 71 d1 ff ff       	call   f0101285 <page2kva>
f0104114:	8b 00                	mov    (%eax),%eax
f0104116:	3d 03 03 03 03       	cmp    $0x3030303,%eax
f010411b:	74 24                	je     f0104141 <check_page_installed_pgdir+0x291>
f010411d:	c7 44 24 0c e4 a9 10 	movl   $0xf010a9e4,0xc(%esp)
f0104124:	f0 
f0104125:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f010412c:	f0 
f010412d:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0104134:	00 
f0104135:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f010413c:	e8 8e c1 ff ff       	call   f01002cf <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0104141:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0104146:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010414d:	00 
f010414e:	89 04 24             	mov    %eax,(%esp)
f0104151:	e8 9a da ff ff       	call   f0101bf0 <page_remove>
	assert(pp2->pp_ref == 0);
f0104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104159:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010415d:	66 85 c0             	test   %ax,%ax
f0104160:	74 24                	je     f0104186 <check_page_installed_pgdir+0x2d6>
f0104162:	c7 44 24 0c 9d a6 10 	movl   $0xf010a69d,0xc(%esp)
f0104169:	f0 
f010416a:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f0104171:	f0 
f0104172:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0104179:	00 
f010417a:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f0104181:	e8 49 c1 ff ff       	call   f01002cf <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0104186:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010418b:	8b 00                	mov    (%eax),%eax
f010418d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104192:	89 c3                	mov    %eax,%ebx
f0104194:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104197:	89 04 24             	mov    %eax,(%esp)
f010419a:	e8 8a d0 ff ff       	call   f0101229 <page2pa>
f010419f:	39 c3                	cmp    %eax,%ebx
f01041a1:	74 24                	je     f01041c7 <check_page_installed_pgdir+0x317>
f01041a3:	c7 44 24 0c 8c a3 10 	movl   $0xf010a38c,0xc(%esp)
f01041aa:	f0 
f01041ab:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01041b2:	f0 
f01041b3:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01041ba:	00 
f01041bb:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01041c2:	e8 08 c1 ff ff       	call   f01002cf <_panic>
	kern_pgdir[0] = 0;
f01041c7:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01041cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01041d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041d5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01041d9:	66 83 f8 01          	cmp    $0x1,%ax
f01041dd:	74 24                	je     f0104203 <check_page_installed_pgdir+0x353>
f01041df:	c7 44 24 0c f2 a3 10 	movl   $0xf010a3f2,0xc(%esp)
f01041e6:	f0 
f01041e7:	c7 44 24 08 7a 9e 10 	movl   $0xf0109e7a,0x8(%esp)
f01041ee:	f0 
f01041ef:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f01041f6:	00 
f01041f7:	c7 04 24 18 9e 10 f0 	movl   $0xf0109e18,(%esp)
f01041fe:	e8 cc c0 ff ff       	call   f01002cf <_panic>
	pp0->pp_ref = 0;
f0104203:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104206:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// free the pages we took
	page_free(pp0);
f010420c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010420f:	89 04 24             	mov    %eax,(%esp)
f0104212:	e8 ce d6 ff ff       	call   f01018e5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0104217:	c7 04 24 10 aa 10 f0 	movl   $0xf010aa10,(%esp)
f010421e:	e8 29 0d 00 00       	call   f0104f4c <cprintf>
}
f0104223:	83 c4 24             	add    $0x24,%esp
f0104226:	5b                   	pop    %ebx
f0104227:	5d                   	pop    %ebp
f0104228:	c3                   	ret    

f0104229 <lgdt>:
	__asm __volatile("lidt (%0)" : : "r" (p));
}

static __inline void
lgdt(void *p)
{
f0104229:	55                   	push   %ebp
f010422a:	89 e5                	mov    %esp,%ebp
	__asm __volatile("lgdt (%0)" : : "r" (p));
f010422c:	8b 45 08             	mov    0x8(%ebp),%eax
f010422f:	0f 01 10             	lgdtl  (%eax)
}
f0104232:	5d                   	pop    %ebp
f0104233:	c3                   	ret    

f0104234 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0104234:	55                   	push   %ebp
f0104235:	89 e5                	mov    %esp,%ebp
f0104237:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f010423a:	8b 45 10             	mov    0x10(%ebp),%eax
f010423d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104242:	77 21                	ja     f0104265 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104244:	8b 45 10             	mov    0x10(%ebp),%eax
f0104247:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010424b:	c7 44 24 08 3c aa 10 	movl   $0xf010aa3c,0x8(%esp)
f0104252:	f0 
f0104253:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104256:	89 44 24 04          	mov    %eax,0x4(%esp)
f010425a:	8b 45 08             	mov    0x8(%ebp),%eax
f010425d:	89 04 24             	mov    %eax,(%esp)
f0104260:	e8 6a c0 ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104265:	8b 45 10             	mov    0x10(%ebp),%eax
f0104268:	05 00 00 00 10       	add    $0x10000000,%eax
}
f010426d:	c9                   	leave  
f010426e:	c3                   	ret    

f010426f <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f010426f:	55                   	push   %ebp
f0104270:	89 e5                	mov    %esp,%ebp
f0104272:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0104275:	8b 45 10             	mov    0x10(%ebp),%eax
f0104278:	c1 e8 0c             	shr    $0xc,%eax
f010427b:	89 c2                	mov    %eax,%edx
f010427d:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f0104282:	39 c2                	cmp    %eax,%edx
f0104284:	72 21                	jb     f01042a7 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104286:	8b 45 10             	mov    0x10(%ebp),%eax
f0104289:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010428d:	c7 44 24 08 60 aa 10 	movl   $0xf010aa60,0x8(%esp)
f0104294:	f0 
f0104295:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104298:	89 44 24 04          	mov    %eax,0x4(%esp)
f010429c:	8b 45 08             	mov    0x8(%ebp),%eax
f010429f:	89 04 24             	mov    %eax,(%esp)
f01042a2:	e8 28 c0 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f01042a7:	8b 45 10             	mov    0x10(%ebp),%eax
f01042aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f01042af:	c9                   	leave  
f01042b0:	c3                   	ret    

f01042b1 <page2pa>:
int	user_mem_check(struct Env *env, const void *va, size_t len, int perm);
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
f01042b1:	55                   	push   %ebp
f01042b2:	89 e5                	mov    %esp,%ebp
	return (pp - pages) << PGSHIFT;
f01042b4:	8b 55 08             	mov    0x8(%ebp),%edx
f01042b7:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f01042bc:	29 c2                	sub    %eax,%edx
f01042be:	89 d0                	mov    %edx,%eax
f01042c0:	c1 f8 03             	sar    $0x3,%eax
f01042c3:	c1 e0 0c             	shl    $0xc,%eax
}
f01042c6:	5d                   	pop    %ebp
f01042c7:	c3                   	ret    

f01042c8 <pa2page>:

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
f01042c8:	55                   	push   %ebp
f01042c9:	89 e5                	mov    %esp,%ebp
f01042cb:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f01042ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01042d1:	c1 e8 0c             	shr    $0xc,%eax
f01042d4:	89 c2                	mov    %eax,%edx
f01042d6:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f01042db:	39 c2                	cmp    %eax,%edx
f01042dd:	72 1c                	jb     f01042fb <pa2page+0x33>
		panic("pa2page called with invalid pa");
f01042df:	c7 44 24 08 84 aa 10 	movl   $0xf010aa84,0x8(%esp)
f01042e6:	f0 
f01042e7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01042ee:	00 
f01042ef:	c7 04 24 a3 aa 10 f0 	movl   $0xf010aaa3,(%esp)
f01042f6:	e8 d4 bf ff ff       	call   f01002cf <_panic>
	return &pages[PGNUM(pa)];
f01042fb:	a1 f0 6a 29 f0       	mov    0xf0296af0,%eax
f0104300:	8b 55 08             	mov    0x8(%ebp),%edx
f0104303:	c1 ea 0c             	shr    $0xc,%edx
f0104306:	c1 e2 03             	shl    $0x3,%edx
f0104309:	01 d0                	add    %edx,%eax
}
f010430b:	c9                   	leave  
f010430c:	c3                   	ret    

f010430d <page2kva>:

static inline void*
page2kva(struct PageInfo *pp)
{
f010430d:	55                   	push   %ebp
f010430e:	89 e5                	mov    %esp,%ebp
f0104310:	83 ec 18             	sub    $0x18,%esp
	return KADDR(page2pa(pp));
f0104313:	8b 45 08             	mov    0x8(%ebp),%eax
f0104316:	89 04 24             	mov    %eax,(%esp)
f0104319:	e8 93 ff ff ff       	call   f01042b1 <page2pa>
f010431e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104322:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0104329:	00 
f010432a:	c7 04 24 a3 aa 10 f0 	movl   $0xf010aaa3,(%esp)
f0104331:	e8 39 ff ff ff       	call   f010426f <_kaddr>
}
f0104336:	c9                   	leave  
f0104337:	c3                   	ret    

f0104338 <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f0104338:	55                   	push   %ebp
f0104339:	89 e5                	mov    %esp,%ebp
f010433b:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f010433e:	c7 04 24 e0 65 12 f0 	movl   $0xf01265e0,(%esp)
f0104345:	e8 2b 52 00 00       	call   f0109575 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010434a:	f3 90                	pause  
}
f010434c:	c9                   	leave  
f010434d:	c3                   	ret    

f010434e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010434e:	55                   	push   %ebp
f010434f:	89 e5                	mov    %esp,%ebp
f0104351:	53                   	push   %ebx
f0104352:	83 ec 24             	sub    $0x24,%esp
f0104355:	8b 45 10             	mov    0x10(%ebp),%eax
f0104358:	88 45 e4             	mov    %al,-0x1c(%ebp)
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010435b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010435f:	75 1e                	jne    f010437f <envid2env+0x31>
		*env_store = curenv;
f0104361:	e8 0c 4f 00 00       	call   f0109272 <cpunum>
f0104366:	6b c0 74             	imul   $0x74,%eax,%eax
f0104369:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010436e:	8b 10                	mov    (%eax),%edx
f0104370:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104373:	89 10                	mov    %edx,(%eax)
		return 0;
f0104375:	b8 00 00 00 00       	mov    $0x0,%eax
f010437a:	e9 97 00 00 00       	jmp    f0104416 <envid2env+0xc8>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010437f:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f0104385:	8b 45 08             	mov    0x8(%ebp),%eax
f0104388:	25 ff 03 00 00       	and    $0x3ff,%eax
f010438d:	c1 e0 02             	shl    $0x2,%eax
f0104390:	89 c1                	mov    %eax,%ecx
f0104392:	c1 e1 05             	shl    $0x5,%ecx
f0104395:	29 c1                	sub    %eax,%ecx
f0104397:	89 c8                	mov    %ecx,%eax
f0104399:	01 d0                	add    %edx,%eax
f010439b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010439e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043a1:	8b 40 54             	mov    0x54(%eax),%eax
f01043a4:	85 c0                	test   %eax,%eax
f01043a6:	74 0b                	je     f01043b3 <envid2env+0x65>
f01043a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043ab:	8b 40 48             	mov    0x48(%eax),%eax
f01043ae:	3b 45 08             	cmp    0x8(%ebp),%eax
f01043b1:	74 10                	je     f01043c3 <envid2env+0x75>
		*env_store = 0;
f01043b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01043bc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01043c1:	eb 53                	jmp    f0104416 <envid2env+0xc8>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01043c3:	80 7d e4 00          	cmpb   $0x0,-0x1c(%ebp)
f01043c7:	74 40                	je     f0104409 <envid2env+0xbb>
f01043c9:	e8 a4 4e 00 00       	call   f0109272 <cpunum>
f01043ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d1:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01043d6:	8b 00                	mov    (%eax),%eax
f01043d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01043db:	74 2c                	je     f0104409 <envid2env+0xbb>
f01043dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043e0:	8b 58 4c             	mov    0x4c(%eax),%ebx
f01043e3:	e8 8a 4e 00 00       	call   f0109272 <cpunum>
f01043e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043eb:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01043f0:	8b 00                	mov    (%eax),%eax
f01043f2:	8b 40 48             	mov    0x48(%eax),%eax
f01043f5:	39 c3                	cmp    %eax,%ebx
f01043f7:	74 10                	je     f0104409 <envid2env+0xbb>
		*env_store = 0;
f01043f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0104402:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104407:	eb 0d                	jmp    f0104416 <envid2env+0xc8>
	}

	*env_store = e;
f0104409:	8b 45 0c             	mov    0xc(%ebp),%eax
f010440c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010440f:	89 10                	mov    %edx,(%eax)
	return 0;
f0104411:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104416:	83 c4 24             	add    $0x24,%esp
f0104419:	5b                   	pop    %ebx
f010441a:	5d                   	pop    %ebp
f010441b:	c3                   	ret    

f010441c <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010441c:	55                   	push   %ebp
f010441d:	89 e5                	mov    %esp,%ebp
f010441f:	83 ec 18             	sub    $0x18,%esp
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i=NENV-1; i>=0; i--){
f0104422:	c7 45 f4 ff 03 00 00 	movl   $0x3ff,-0xc(%ebp)
f0104429:	eb 5d                	jmp    f0104488 <env_init+0x6c>
		envs[i].env_id = 0;
f010442b:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f0104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104434:	c1 e0 02             	shl    $0x2,%eax
f0104437:	89 c1                	mov    %eax,%ecx
f0104439:	c1 e1 05             	shl    $0x5,%ecx
f010443c:	29 c1                	sub    %eax,%ecx
f010443e:	89 c8                	mov    %ecx,%eax
f0104440:	01 d0                	add    %edx,%eax
f0104442:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0104449:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104452:	c1 e0 02             	shl    $0x2,%eax
f0104455:	89 c1                	mov    %eax,%ecx
f0104457:	c1 e1 05             	shl    $0x5,%ecx
f010445a:	29 c1                	sub    %eax,%ecx
f010445c:	89 c8                	mov    %ecx,%eax
f010445e:	01 c2                	add    %eax,%edx
f0104460:	a1 40 32 29 f0       	mov    0xf0293240,%eax
f0104465:	89 42 44             	mov    %eax,0x44(%edx)
		env_free_list = &envs[i];
f0104468:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104471:	c1 e0 02             	shl    $0x2,%eax
f0104474:	89 c1                	mov    %eax,%ecx
f0104476:	c1 e1 05             	shl    $0x5,%ecx
f0104479:	29 c1                	sub    %eax,%ecx
f010447b:	89 c8                	mov    %ecx,%eax
f010447d:	01 d0                	add    %edx,%eax
f010447f:	a3 40 32 29 f0       	mov    %eax,0xf0293240
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i=NENV-1; i>=0; i--){
f0104484:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
f0104488:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010448c:	79 9d                	jns    f010442b <env_init+0xf>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010448e:	e8 02 00 00 00       	call   f0104495 <env_init_percpu>
}
f0104493:	c9                   	leave  
f0104494:	c3                   	ret    

f0104495 <env_init_percpu>:

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0104495:	55                   	push   %ebp
f0104496:	89 e5                	mov    %esp,%ebp
f0104498:	83 ec 14             	sub    $0x14,%esp
	lgdt(&gdt_pd);
f010449b:	c7 04 24 c8 65 12 f0 	movl   $0xf01265c8,(%esp)
f01044a2:	e8 82 fd ff ff       	call   f0104229 <lgdt>
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01044a7:	b8 23 00 00 00       	mov    $0x23,%eax
f01044ac:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01044ae:	b8 23 00 00 00       	mov    $0x23,%eax
f01044b3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01044b5:	b8 10 00 00 00       	mov    $0x10,%eax
f01044ba:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01044bc:	b8 10 00 00 00       	mov    $0x10,%eax
f01044c1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01044c3:	b8 10 00 00 00       	mov    $0x10,%eax
f01044c8:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01044ca:	ea d1 44 10 f0 08 00 	ljmp   $0x8,$0xf01044d1
f01044d1:	66 c7 45 fe 00 00    	movw   $0x0,-0x2(%ebp)

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01044d7:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
f01044db:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01044de:	c9                   	leave  
f01044df:	c3                   	ret    

f01044e0 <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f01044e0:	55                   	push   %ebp
f01044e1:	89 e5                	mov    %esp,%ebp
f01044e3:	53                   	push   %ebx
f01044e4:	83 ec 24             	sub    $0x24,%esp
	int i;
	struct PageInfo *p = NULL;
f01044e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01044ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01044f5:	e8 88 d3 ff ff       	call   f0101882 <page_alloc>
f01044fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01044fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104501:	75 07                	jne    f010450a <env_setup_vm+0x2a>
		return -E_NO_MEM;
f0104503:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104508:	eb 76                	jmp    f0104580 <env_setup_vm+0xa0>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f010450a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010450d:	89 04 24             	mov    %eax,(%esp)
f0104510:	e8 f8 fd ff ff       	call   f010430d <page2kva>
f0104515:	8b 55 08             	mov    0x8(%ebp),%edx
f0104518:	89 42 60             	mov    %eax,0x60(%edx)
	p->pp_ref++;
f010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010451e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0104522:	8d 50 01             	lea    0x1(%eax),%edx
f0104525:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104528:	66 89 50 04          	mov    %dx,0x4(%eax)
	memcpy(e->env_pgdir,kern_pgdir,PGSIZE);
f010452c:	8b 15 ec 6a 29 f0    	mov    0xf0296aec,%edx
f0104532:	8b 45 08             	mov    0x8(%ebp),%eax
f0104535:	8b 40 60             	mov    0x60(%eax),%eax
f0104538:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010453f:	00 
f0104540:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104544:	89 04 24             	mov    %eax,(%esp)
f0104547:	e8 a3 43 00 00       	call   f01088ef <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010454c:	8b 45 08             	mov    0x8(%ebp),%eax
f010454f:	8b 40 60             	mov    0x60(%eax),%eax
f0104552:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f0104558:	8b 45 08             	mov    0x8(%ebp),%eax
f010455b:	8b 40 60             	mov    0x60(%eax),%eax
f010455e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104562:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
f0104569:	00 
f010456a:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104571:	e8 be fc ff ff       	call   f0104234 <_paddr>
f0104576:	83 c8 05             	or     $0x5,%eax
f0104579:	89 03                	mov    %eax,(%ebx)

	return 0;
f010457b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104580:	83 c4 24             	add    $0x24,%esp
f0104583:	5b                   	pop    %ebx
f0104584:	5d                   	pop    %ebp
f0104585:	c3                   	ret    

f0104586 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0104586:	55                   	push   %ebp
f0104587:	89 e5                	mov    %esp,%ebp
f0104589:	83 ec 28             	sub    $0x28,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010458c:	a1 40 32 29 f0       	mov    0xf0293240,%eax
f0104591:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104594:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104598:	75 0a                	jne    f01045a4 <env_alloc+0x1e>
		return -E_NO_FREE_ENV;
f010459a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010459f:	e9 06 01 00 00       	jmp    f01046aa <env_alloc+0x124>

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
f01045a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045a7:	89 04 24             	mov    %eax,(%esp)
f01045aa:	e8 31 ff ff ff       	call   f01044e0 <env_setup_vm>
f01045af:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01045b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01045b6:	79 08                	jns    f01045c0 <env_alloc+0x3a>
		return r;
f01045b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01045bb:	e9 ea 00 00 00       	jmp    f01046aa <env_alloc+0x124>

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01045c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045c3:	8b 40 48             	mov    0x48(%eax),%eax
f01045c6:	05 00 10 00 00       	add    $0x1000,%eax
f01045cb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01045d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f01045d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01045d7:	7f 07                	jg     f01045e0 <env_alloc+0x5a>
		generation = 1 << ENVGENSHIFT;
f01045d9:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f01045e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01045e3:	a1 3c 32 29 f0       	mov    0xf029323c,%eax
f01045e8:	29 c2                	sub    %eax,%edx
f01045ea:	89 d0                	mov    %edx,%eax
f01045ec:	c1 f8 02             	sar    $0x2,%eax
f01045ef:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f01045f5:	0b 45 f4             	or     -0xc(%ebp),%eax
f01045f8:	89 c2                	mov    %eax,%edx
f01045fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045fd:	89 50 48             	mov    %edx,0x48(%eax)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104600:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104603:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104606:	89 50 4c             	mov    %edx,0x4c(%eax)
	e->env_type = ENV_TYPE_USER;
f0104609:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010460c:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f0104613:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104616:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_runs = 0;
f010461d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104620:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0104627:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010462a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104631:	00 
f0104632:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104639:	00 
f010463a:	89 04 24             	mov    %eax,(%esp)
f010463d:	e8 65 41 00 00       	call   f01087a7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104642:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104645:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f010464b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010464e:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0104654:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104657:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = USTACKTOP;
f010465d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104660:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0104667:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010466a:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	e->env_tf.tf_eflags |= FL_IF;
f0104670:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104673:	8b 40 38             	mov    0x38(%eax),%eax
f0104676:	80 cc 02             	or     $0x2,%ah
f0104679:	89 c2                	mov    %eax,%edx
f010467b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010467e:	89 50 38             	mov    %edx,0x38(%eax)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104681:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104684:	c7 40 64 00 00 00 00 	movl   $0x0,0x64(%eax)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010468b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010468e:	c6 40 68 00          	movb   $0x0,0x68(%eax)

	// commit the allocation
	env_free_list = e->env_link;
f0104692:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104695:	8b 40 44             	mov    0x44(%eax),%eax
f0104698:	a3 40 32 29 f0       	mov    %eax,0xf0293240
	*newenv_store = e;
f010469d:	8b 45 08             	mov    0x8(%ebp),%eax
f01046a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01046a3:	89 10                	mov    %edx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01046a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046aa:	c9                   	leave  
f01046ab:	c3                   	ret    

f01046ac <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01046ac:	55                   	push   %ebp
f01046ad:	89 e5                	mov    %esp,%ebp
f01046af:	83 ec 38             	sub    $0x38,%esp
	// LAB 3: Your code here.
	int i;
	uintptr_t aligned_va = ROUNDDOWN((uintptr_t)va,PGSIZE);
f01046b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01046b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046bb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01046c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	size_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
f01046c3:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f01046ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046cd:	8b 45 10             	mov    0x10(%ebp),%eax
f01046d0:	01 c2                	add    %eax,%edx
f01046d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01046d5:	01 d0                	add    %edx,%eax
f01046d7:	83 e8 01             	sub    $0x1,%eax
f01046da:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01046dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01046e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01046e5:	f7 75 ec             	divl   -0x14(%ebp)
f01046e8:	89 d0                	mov    %edx,%eax
f01046ea:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01046ed:	29 c2                	sub    %eax,%edx
f01046ef:	89 d0                	mov    %edx,%eax
f01046f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;aligned_va < aligned_end_va;aligned_va += PGSIZE){
f01046f4:	eb 6b                	jmp    f0104761 <region_alloc+0xb5>
		struct PageInfo *p = NULL;
f01046f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		p = page_alloc(!ALLOC_ZERO);
f01046fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104704:	e8 79 d1 ff ff       	call   f0101882 <page_alloc>
f0104709:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (!p)
f010470c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104710:	75 24                	jne    f0104736 <region_alloc+0x8a>
			panic("env_alloc: %e",-E_NO_MEM);
f0104712:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f0104719:	ff 
f010471a:	c7 44 24 08 bc aa 10 	movl   $0xf010aabc,0x8(%esp)
f0104721:	f0 
f0104722:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0104729:	00 
f010472a:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104731:	e8 99 bb ff ff       	call   f01002cf <_panic>
		page_insert(e->env_pgdir, p, (void*)aligned_va, PTE_P | PTE_U | PTE_W);
f0104736:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104739:	8b 45 08             	mov    0x8(%ebp),%eax
f010473c:	8b 40 60             	mov    0x60(%eax),%eax
f010473f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104746:	00 
f0104747:	89 54 24 08          	mov    %edx,0x8(%esp)
f010474b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010474e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104752:	89 04 24             	mov    %eax,(%esp)
f0104755:	e8 b1 d3 ff ff       	call   f0101b0b <page_insert>
{
	// LAB 3: Your code here.
	int i;
	uintptr_t aligned_va = ROUNDDOWN((uintptr_t)va,PGSIZE);
	size_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
	for(;aligned_va < aligned_end_va;aligned_va += PGSIZE){
f010475a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0104761:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104764:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0104767:	72 8d                	jb     f01046f6 <region_alloc+0x4a>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0104769:	c9                   	leave  
f010476a:	c3                   	ret    

f010476b <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
void
load_icode(struct Env *e, uint8_t *binary)
{
f010476b:	55                   	push   %ebp
f010476c:	89 e5                	mov    %esp,%ebp
f010476e:	83 ec 38             	sub    $0x38,%esp

	// LAB 3: Your code here.
	struct Proghdr* ph;
	struct Proghdr* eph;
	struct Elf *elfhdr;
	elfhdr = (struct Elf *)binary;
f0104771:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104774:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(elfhdr->e_magic != ELF_MAGIC) panic("Error in ELF!\n");
f0104777:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010477a:	8b 00                	mov    (%eax),%eax
f010477c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0104781:	74 1c                	je     f010479f <load_icode+0x34>
f0104783:	c7 44 24 08 ca aa 10 	movl   $0xf010aaca,0x8(%esp)
f010478a:	f0 
f010478b:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0104792:	00 
f0104793:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f010479a:	e8 30 bb ff ff       	call   f01002cf <_panic>
	ph = (struct Proghdr *) (binary + elfhdr->e_phoff);
f010479f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047a2:	8b 50 1c             	mov    0x1c(%eax),%edx
f01047a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047a8:	01 d0                	add    %edx,%eax
f01047aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	eph = ph + elfhdr->e_phnum;
f01047ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047b0:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f01047b4:	0f b7 c0             	movzwl %ax,%eax
f01047b7:	c1 e0 05             	shl    $0x5,%eax
f01047ba:	89 c2                	mov    %eax,%edx
f01047bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047bf:	01 d0                	add    %edx,%eax
f01047c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	lcr3(PADDR(e->env_pgdir));
f01047c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01047c7:	8b 40 60             	mov    0x60(%eax),%eax
f01047ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047ce:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f01047d5:	00 
f01047d6:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f01047dd:	e8 52 fa ff ff       	call   f0104234 <_paddr>
f01047e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01047e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01047e8:	0f 22 d8             	mov    %eax,%cr3
	for (; ph < eph; ph++){
f01047eb:	e9 b4 00 00 00       	jmp    f01048a4 <load_icode+0x139>
		if(ph->p_type == ELF_PROG_LOAD){
f01047f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047f3:	8b 00                	mov    (%eax),%eax
f01047f5:	83 f8 01             	cmp    $0x1,%eax
f01047f8:	0f 85 a2 00 00 00    	jne    f01048a0 <load_icode+0x135>
			if(ph->p_filesz > ph->p_memsz) panic("ph->p_filesz > ph->p_memsz\n");
f01047fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104801:	8b 50 10             	mov    0x10(%eax),%edx
f0104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104807:	8b 40 14             	mov    0x14(%eax),%eax
f010480a:	39 c2                	cmp    %eax,%edx
f010480c:	76 1c                	jbe    f010482a <load_icode+0xbf>
f010480e:	c7 44 24 08 d9 aa 10 	movl   $0xf010aad9,0x8(%esp)
f0104815:	f0 
f0104816:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f010481d:	00 
f010481e:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104825:	e8 a5 ba ff ff       	call   f01002cf <_panic>
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f010482a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010482d:	8b 50 14             	mov    0x14(%eax),%edx
f0104830:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104833:	8b 40 08             	mov    0x8(%eax),%eax
f0104836:	89 54 24 08          	mov    %edx,0x8(%esp)
f010483a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010483e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104841:	89 04 24             	mov    %eax,(%esp)
f0104844:	e8 63 fe ff ff       	call   f01046ac <region_alloc>
			memcpy((void *)ph->p_va, (void *)(binary + ph->p_offset),ph->p_filesz);
f0104849:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010484c:	8b 50 10             	mov    0x10(%eax),%edx
f010484f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104852:	8b 48 04             	mov    0x4(%eax),%ecx
f0104855:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104858:	01 c1                	add    %eax,%ecx
f010485a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010485d:	8b 40 08             	mov    0x8(%eax),%eax
f0104860:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104864:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104868:	89 04 24             	mov    %eax,(%esp)
f010486b:	e8 7f 40 00 00       	call   f01088ef <memcpy>
			memset((void *)(ph->p_va + ph->p_filesz),0, ph->p_memsz - ph->p_filesz);
f0104870:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104873:	8b 50 14             	mov    0x14(%eax),%edx
f0104876:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104879:	8b 40 10             	mov    0x10(%eax),%eax
f010487c:	29 c2                	sub    %eax,%edx
f010487e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104881:	8b 48 08             	mov    0x8(%eax),%ecx
f0104884:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104887:	8b 40 10             	mov    0x10(%eax),%eax
f010488a:	01 c8                	add    %ecx,%eax
f010488c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104890:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104897:	00 
f0104898:	89 04 24             	mov    %eax,(%esp)
f010489b:	e8 07 3f 00 00       	call   f01087a7 <memset>
	elfhdr = (struct Elf *)binary;
	if(elfhdr->e_magic != ELF_MAGIC) panic("Error in ELF!\n");
	ph = (struct Proghdr *) (binary + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01048a0:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
f01048a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01048aa:	0f 82 40 ff ff ff    	jb     f01047f0 <load_icode+0x85>
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e,(void *)(USTACKTOP-PGSIZE),PGSIZE);
f01048b0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01048b7:	00 
f01048b8:	c7 44 24 04 00 d0 bf 	movl   $0xeebfd000,0x4(%esp)
f01048bf:	ee 
f01048c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c3:	89 04 24             	mov    %eax,(%esp)
f01048c6:	e8 e1 fd ff ff       	call   f01046ac <region_alloc>
	e->env_tf.tf_eip = elfhdr->e_entry;
f01048cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01048ce:	8b 50 18             	mov    0x18(%eax),%edx
f01048d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01048d4:	89 50 30             	mov    %edx,0x30(%eax)
	lcr3(PADDR(kern_pgdir));
f01048d7:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f01048dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048e0:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f01048e7:	00 
f01048e8:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f01048ef:	e8 40 f9 ff ff       	call   f0104234 <_paddr>
f01048f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01048f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048fa:	0f 22 d8             	mov    %eax,%cr3
}
f01048fd:	c9                   	leave  
f01048fe:	c3                   	ret    

f01048ff <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01048ff:	55                   	push   %ebp
f0104900:	89 e5                	mov    %esp,%ebp
f0104902:	83 ec 28             	sub    $0x28,%esp
	// LAB 3: Your code here.
	struct Env *e;
	if(env_alloc(&e,0) < 0) panic("env_alloc failed!\n");
f0104905:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010490c:	00 
f010490d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104910:	89 04 24             	mov    %eax,(%esp)
f0104913:	e8 6e fc ff ff       	call   f0104586 <env_alloc>
f0104918:	85 c0                	test   %eax,%eax
f010491a:	79 1c                	jns    f0104938 <env_create+0x39>
f010491c:	c7 44 24 08 f5 aa 10 	movl   $0xf010aaf5,0x8(%esp)
f0104923:	f0 
f0104924:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f010492b:	00 
f010492c:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104933:	e8 97 b9 ff ff       	call   f01002cf <_panic>
	load_icode(e,binary);
f0104938:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010493b:	8b 55 08             	mov    0x8(%ebp),%edx
f010493e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104942:	89 04 24             	mov    %eax,(%esp)
f0104945:	e8 21 fe ff ff       	call   f010476b <load_icode>
	e->env_type = type;
f010494a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010494d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104950:	89 50 50             	mov    %edx,0x50(%eax)
	e->env_parent_id = 0;
f0104953:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104956:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
}
f010495d:	c9                   	leave  
f010495e:	c3                   	ret    

f010495f <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010495f:	55                   	push   %ebp
f0104960:	89 e5                	mov    %esp,%ebp
f0104962:	83 ec 38             	sub    $0x38,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0104965:	e8 08 49 00 00       	call   f0109272 <cpunum>
f010496a:	6b c0 74             	imul   $0x74,%eax,%eax
f010496d:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104972:	8b 00                	mov    (%eax),%eax
f0104974:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104977:	75 26                	jne    f010499f <env_free+0x40>
		lcr3(PADDR(kern_pgdir));
f0104979:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010497e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104982:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0104989:	00 
f010498a:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104991:	e8 9e f8 ff ff       	call   f0104234 <_paddr>
f0104996:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104999:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010499c:	0f 22 d8             	mov    %eax,%cr3
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010499f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01049a6:	e9 cf 00 00 00       	jmp    f0104a7a <env_free+0x11b>

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01049ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ae:	8b 40 60             	mov    0x60(%eax),%eax
f01049b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01049b4:	c1 e2 02             	shl    $0x2,%edx
f01049b7:	01 d0                	add    %edx,%eax
f01049b9:	8b 00                	mov    (%eax),%eax
f01049bb:	83 e0 01             	and    $0x1,%eax
f01049be:	85 c0                	test   %eax,%eax
f01049c0:	75 05                	jne    f01049c7 <env_free+0x68>
			continue;
f01049c2:	e9 af 00 00 00       	jmp    f0104a76 <env_free+0x117>

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01049c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ca:	8b 40 60             	mov    0x60(%eax),%eax
f01049cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01049d0:	c1 e2 02             	shl    $0x2,%edx
f01049d3:	01 d0                	add    %edx,%eax
f01049d5:	8b 00                	mov    (%eax),%eax
f01049d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01049dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
		pt = (pte_t*) KADDR(pa);
f01049df:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01049e2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049e6:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01049ed:	00 
f01049ee:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f01049f5:	e8 75 f8 ff ff       	call   f010426f <_kaddr>
f01049fa:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01049fd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104a04:	eb 40                	jmp    f0104a46 <env_free+0xe7>
			if (pt[pteno] & PTE_P)
f0104a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a09:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104a13:	01 d0                	add    %edx,%eax
f0104a15:	8b 00                	mov    (%eax),%eax
f0104a17:	83 e0 01             	and    $0x1,%eax
f0104a1a:	85 c0                	test   %eax,%eax
f0104a1c:	74 24                	je     f0104a42 <env_free+0xe3>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a21:	c1 e0 16             	shl    $0x16,%eax
f0104a24:	89 c2                	mov    %eax,%edx
f0104a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a29:	c1 e0 0c             	shl    $0xc,%eax
f0104a2c:	09 d0                	or     %edx,%eax
f0104a2e:	89 c2                	mov    %eax,%edx
f0104a30:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a33:	8b 40 60             	mov    0x60(%eax),%eax
f0104a36:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a3a:	89 04 24             	mov    %eax,(%esp)
f0104a3d:	e8 ae d1 ff ff       	call   f0101bf0 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104a42:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0104a46:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0104a4d:	76 b7                	jbe    f0104a06 <env_free+0xa7>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104a4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a52:	8b 40 60             	mov    0x60(%eax),%eax
f0104a55:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a58:	c1 e2 02             	shl    $0x2,%edx
f0104a5b:	01 d0                	add    %edx,%eax
f0104a5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		page_decref(pa2page(pa));
f0104a63:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a66:	89 04 24             	mov    %eax,(%esp)
f0104a69:	e8 5a f8 ff ff       	call   f01042c8 <pa2page>
f0104a6e:	89 04 24             	mov    %eax,(%esp)
f0104a71:	e8 d7 ce ff ff       	call   f010194d <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104a76:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104a7a:	81 7d f4 ba 03 00 00 	cmpl   $0x3ba,-0xc(%ebp)
f0104a81:	0f 86 24 ff ff ff    	jbe    f01049ab <env_free+0x4c>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104a87:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a8a:	8b 40 60             	mov    0x60(%eax),%eax
f0104a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a91:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0104a98:	00 
f0104a99:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104aa0:	e8 8f f7 ff ff       	call   f0104234 <_paddr>
f0104aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	e->env_pgdir = 0;
f0104aa8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aab:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
	page_decref(pa2page(pa));
f0104ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ab5:	89 04 24             	mov    %eax,(%esp)
f0104ab8:	e8 0b f8 ff ff       	call   f01042c8 <pa2page>
f0104abd:	89 04 24             	mov    %eax,(%esp)
f0104ac0:	e8 88 ce ff ff       	call   f010194d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104ac5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac8:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0104acf:	8b 15 40 32 29 f0    	mov    0xf0293240,%edx
f0104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ad8:	89 50 44             	mov    %edx,0x44(%eax)
	env_free_list = e;
f0104adb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ade:	a3 40 32 29 f0       	mov    %eax,0xf0293240
}
f0104ae3:	c9                   	leave  
f0104ae4:	c3                   	ret    

f0104ae5 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104ae5:	55                   	push   %ebp
f0104ae6:	89 e5                	mov    %esp,%ebp
f0104ae8:	83 ec 28             	sub    $0x28,%esp
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	struct Env* parent_env;
	envid2env(e->env_parent_id, &parent_env, 0);
f0104aeb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aee:	8b 40 4c             	mov    0x4c(%eax),%eax
f0104af1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104af8:	00 
f0104af9:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104afc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b00:	89 04 24             	mov    %eax,(%esp)
f0104b03:	e8 46 f8 ff ff       	call   f010434e <envid2env>
	if(parent_env->env_status == ENV_WAIT_CHILD){
f0104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b0b:	8b 40 54             	mov    0x54(%eax),%eax
f0104b0e:	83 f8 05             	cmp    $0x5,%eax
f0104b11:	75 0a                	jne    f0104b1d <env_destroy+0x38>
		parent_env->env_status = ENV_RUNNABLE;
f0104b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b16:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104b1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b20:	8b 40 54             	mov    0x54(%eax),%eax
f0104b23:	83 f8 03             	cmp    $0x3,%eax
f0104b26:	75 20                	jne    f0104b48 <env_destroy+0x63>
f0104b28:	e8 45 47 00 00       	call   f0109272 <cpunum>
f0104b2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b30:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104b35:	8b 00                	mov    (%eax),%eax
f0104b37:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104b3a:	74 0c                	je     f0104b48 <env_destroy+0x63>
		e->env_status = ENV_DYING;
f0104b3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b3f:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
f0104b46:	eb 37                	jmp    f0104b7f <env_destroy+0x9a>
		return;
	}

	env_free(e);
f0104b48:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b4b:	89 04 24             	mov    %eax,(%esp)
f0104b4e:	e8 0c fe ff ff       	call   f010495f <env_free>

	if (curenv == e) {
f0104b53:	e8 1a 47 00 00       	call   f0109272 <cpunum>
f0104b58:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b5b:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104b60:	8b 00                	mov    (%eax),%eax
f0104b62:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104b65:	75 18                	jne    f0104b7f <env_destroy+0x9a>
		curenv = NULL;
f0104b67:	e8 06 47 00 00       	call   f0109272 <cpunum>
f0104b6c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6f:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104b74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		sched_yield();
f0104b7a:	e8 0e 1b 00 00       	call   f010668d <sched_yield>
	}
}
f0104b7f:	c9                   	leave  
f0104b80:	c3                   	ret    

f0104b81 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104b81:	55                   	push   %ebp
f0104b82:	89 e5                	mov    %esp,%ebp
f0104b84:	53                   	push   %ebx
f0104b85:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104b88:	e8 e5 46 00 00       	call   f0109272 <cpunum>
f0104b8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b90:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104b95:	8b 18                	mov    (%eax),%ebx
f0104b97:	e8 d6 46 00 00       	call   f0109272 <cpunum>
f0104b9c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104b9f:	8b 65 08             	mov    0x8(%ebp),%esp
f0104ba2:	61                   	popa   
f0104ba3:	07                   	pop    %es
f0104ba4:	1f                   	pop    %ds
f0104ba5:	83 c4 08             	add    $0x8,%esp
f0104ba8:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104ba9:	c7 44 24 08 08 ab 10 	movl   $0xf010ab08,0x8(%esp)
f0104bb0:	f0 
f0104bb1:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
f0104bb8:	00 
f0104bb9:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104bc0:	e8 0a b7 ff ff       	call   f01002cf <_panic>

f0104bc5 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104bc5:	55                   	push   %ebp
f0104bc6:	89 e5                	mov    %esp,%ebp
f0104bc8:	83 ec 28             	sub    $0x28,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if(curenv && (curenv->env_status == ENV_RUNNING)) curenv->env_status = ENV_RUNNABLE;
f0104bcb:	e8 a2 46 00 00       	call   f0109272 <cpunum>
f0104bd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd3:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104bd8:	8b 00                	mov    (%eax),%eax
f0104bda:	85 c0                	test   %eax,%eax
f0104bdc:	74 2d                	je     f0104c0b <env_run+0x46>
f0104bde:	e8 8f 46 00 00       	call   f0109272 <cpunum>
f0104be3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104be6:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104beb:	8b 00                	mov    (%eax),%eax
f0104bed:	8b 40 54             	mov    0x54(%eax),%eax
f0104bf0:	83 f8 03             	cmp    $0x3,%eax
f0104bf3:	75 16                	jne    f0104c0b <env_run+0x46>
f0104bf5:	e8 78 46 00 00       	call   f0109272 <cpunum>
f0104bfa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bfd:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104c02:	8b 00                	mov    (%eax),%eax
f0104c04:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0104c0b:	e8 62 46 00 00       	call   f0109272 <cpunum>
f0104c10:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c13:	8d 90 28 70 29 f0    	lea    -0xfd68fd8(%eax),%edx
f0104c19:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c1c:	89 02                	mov    %eax,(%edx)
	curenv->env_status = ENV_RUNNING;
f0104c1e:	e8 4f 46 00 00       	call   f0109272 <cpunum>
f0104c23:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c26:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104c2b:	8b 00                	mov    (%eax),%eax
f0104c2d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0104c34:	e8 39 46 00 00       	call   f0109272 <cpunum>
f0104c39:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c3c:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104c41:	8b 00                	mov    (%eax),%eax
f0104c43:	8b 50 58             	mov    0x58(%eax),%edx
f0104c46:	83 c2 01             	add    $0x1,%edx
f0104c49:	89 50 58             	mov    %edx,0x58(%eax)
	unlock_kernel();
f0104c4c:	e8 e7 f6 ff ff       	call   f0104338 <unlock_kernel>
	lcr3(PADDR(curenv->env_pgdir));
f0104c51:	e8 1c 46 00 00       	call   f0109272 <cpunum>
f0104c56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c59:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104c5e:	8b 00                	mov    (%eax),%eax
f0104c60:	8b 40 60             	mov    0x60(%eax),%eax
f0104c63:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c67:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
f0104c6e:	00 
f0104c6f:	c7 04 24 b1 aa 10 f0 	movl   $0xf010aab1,(%esp)
f0104c76:	e8 b9 f5 ff ff       	call   f0104234 <_paddr>
f0104c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c81:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(curenv->env_tf));
f0104c84:	e8 e9 45 00 00       	call   f0109272 <cpunum>
f0104c89:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c8c:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0104c91:	8b 00                	mov    (%eax),%eax
f0104c93:	89 04 24             	mov    %eax,(%esp)
f0104c96:	e8 e6 fe ff ff       	call   f0104b81 <env_pop_tf>

f0104c9b <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104c9b:	55                   	push   %ebp
f0104c9c:	89 e5                	mov    %esp,%ebp
f0104c9e:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104ca1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ca4:	0f b6 c0             	movzbl %al,%eax
f0104ca7:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104cae:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104cb1:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104cb5:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104cb8:	ee                   	out    %al,(%dx)
f0104cb9:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104cc3:	89 c2                	mov    %eax,%edx
f0104cc5:	ec                   	in     (%dx),%al
f0104cc6:	88 45 f3             	mov    %al,-0xd(%ebp)
	return data;
f0104cc9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
	return inb(IO_RTC+1);
f0104ccd:	0f b6 c0             	movzbl %al,%eax
}
f0104cd0:	c9                   	leave  
f0104cd1:	c3                   	ret    

f0104cd2 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104cd2:	55                   	push   %ebp
f0104cd3:	89 e5                	mov    %esp,%ebp
f0104cd5:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104cd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cdb:	0f b6 c0             	movzbl %al,%eax
f0104cde:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104ce5:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104ce8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104cec:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104cef:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0104cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cf3:	0f b6 c0             	movzbl %al,%eax
f0104cf6:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)
f0104cfd:	88 45 f3             	mov    %al,-0xd(%ebp)
f0104d00:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d04:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d07:	ee                   	out    %al,(%dx)
}
f0104d08:	c9                   	leave  
f0104d09:	c3                   	ret    

f0104d0a <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104d0a:	55                   	push   %ebp
f0104d0b:	89 e5                	mov    %esp,%ebp
f0104d0d:	81 ec 88 00 00 00    	sub    $0x88,%esp
	didinit = 1;
f0104d13:	c6 05 44 32 29 f0 01 	movb   $0x1,0xf0293244
f0104d1a:	c7 45 f4 21 00 00 00 	movl   $0x21,-0xc(%ebp)
f0104d21:	c6 45 f3 ff          	movb   $0xff,-0xd(%ebp)
f0104d25:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d29:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d2c:	ee                   	out    %al,(%dx)
f0104d2d:	c7 45 ec a1 00 00 00 	movl   $0xa1,-0x14(%ebp)
f0104d34:	c6 45 eb ff          	movb   $0xff,-0x15(%ebp)
f0104d38:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0104d3c:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104d3f:	ee                   	out    %al,(%dx)
f0104d40:	c7 45 e4 20 00 00 00 	movl   $0x20,-0x1c(%ebp)
f0104d47:	c6 45 e3 11          	movb   $0x11,-0x1d(%ebp)
f0104d4b:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0104d4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d52:	ee                   	out    %al,(%dx)
f0104d53:	c7 45 dc 21 00 00 00 	movl   $0x21,-0x24(%ebp)
f0104d5a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
f0104d5e:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0104d62:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d65:	ee                   	out    %al,(%dx)
f0104d66:	c7 45 d4 21 00 00 00 	movl   $0x21,-0x2c(%ebp)
f0104d6d:	c6 45 d3 04          	movb   $0x4,-0x2d(%ebp)
f0104d71:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f0104d75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104d78:	ee                   	out    %al,(%dx)
f0104d79:	c7 45 cc 21 00 00 00 	movl   $0x21,-0x34(%ebp)
f0104d80:	c6 45 cb 03          	movb   $0x3,-0x35(%ebp)
f0104d84:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
f0104d88:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104d8b:	ee                   	out    %al,(%dx)
f0104d8c:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%ebp)
f0104d93:	c6 45 c3 11          	movb   $0x11,-0x3d(%ebp)
f0104d97:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
f0104d9b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104d9e:	ee                   	out    %al,(%dx)
f0104d9f:	c7 45 bc a1 00 00 00 	movl   $0xa1,-0x44(%ebp)
f0104da6:	c6 45 bb 28          	movb   $0x28,-0x45(%ebp)
f0104daa:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
f0104dae:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104db1:	ee                   	out    %al,(%dx)
f0104db2:	c7 45 b4 a1 00 00 00 	movl   $0xa1,-0x4c(%ebp)
f0104db9:	c6 45 b3 02          	movb   $0x2,-0x4d(%ebp)
f0104dbd:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
f0104dc1:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104dc4:	ee                   	out    %al,(%dx)
f0104dc5:	c7 45 ac a1 00 00 00 	movl   $0xa1,-0x54(%ebp)
f0104dcc:	c6 45 ab 01          	movb   $0x1,-0x55(%ebp)
f0104dd0:	0f b6 45 ab          	movzbl -0x55(%ebp),%eax
f0104dd4:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0104dd7:	ee                   	out    %al,(%dx)
f0104dd8:	c7 45 a4 20 00 00 00 	movl   $0x20,-0x5c(%ebp)
f0104ddf:	c6 45 a3 68          	movb   $0x68,-0x5d(%ebp)
f0104de3:	0f b6 45 a3          	movzbl -0x5d(%ebp),%eax
f0104de7:	8b 55 a4             	mov    -0x5c(%ebp),%edx
f0104dea:	ee                   	out    %al,(%dx)
f0104deb:	c7 45 9c 20 00 00 00 	movl   $0x20,-0x64(%ebp)
f0104df2:	c6 45 9b 0a          	movb   $0xa,-0x65(%ebp)
f0104df6:	0f b6 45 9b          	movzbl -0x65(%ebp),%eax
f0104dfa:	8b 55 9c             	mov    -0x64(%ebp),%edx
f0104dfd:	ee                   	out    %al,(%dx)
f0104dfe:	c7 45 94 a0 00 00 00 	movl   $0xa0,-0x6c(%ebp)
f0104e05:	c6 45 93 68          	movb   $0x68,-0x6d(%ebp)
f0104e09:	0f b6 45 93          	movzbl -0x6d(%ebp),%eax
f0104e0d:	8b 55 94             	mov    -0x6c(%ebp),%edx
f0104e10:	ee                   	out    %al,(%dx)
f0104e11:	c7 45 8c a0 00 00 00 	movl   $0xa0,-0x74(%ebp)
f0104e18:	c6 45 8b 0a          	movb   $0xa,-0x75(%ebp)
f0104e1c:	0f b6 45 8b          	movzbl -0x75(%ebp),%eax
f0104e20:	8b 55 8c             	mov    -0x74(%ebp),%edx
f0104e23:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104e24:	0f b7 05 ce 65 12 f0 	movzwl 0xf01265ce,%eax
f0104e2b:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104e2f:	74 12                	je     f0104e43 <pic_init+0x139>
		irq_setmask_8259A(irq_mask_8259A);
f0104e31:	0f b7 05 ce 65 12 f0 	movzwl 0xf01265ce,%eax
f0104e38:	0f b7 c0             	movzwl %ax,%eax
f0104e3b:	89 04 24             	mov    %eax,(%esp)
f0104e3e:	e8 02 00 00 00       	call   f0104e45 <irq_setmask_8259A>
}
f0104e43:	c9                   	leave  
f0104e44:	c3                   	ret    

f0104e45 <irq_setmask_8259A>:

void
irq_setmask_8259A(uint16_t mask)
{
f0104e45:	55                   	push   %ebp
f0104e46:	89 e5                	mov    %esp,%ebp
f0104e48:	83 ec 38             	sub    $0x38,%esp
f0104e4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e4e:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
	int i;
	irq_mask_8259A = mask;
f0104e52:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104e56:	66 a3 ce 65 12 f0    	mov    %ax,0xf01265ce
	if (!didinit)
f0104e5c:	0f b6 05 44 32 29 f0 	movzbl 0xf0293244,%eax
f0104e63:	83 f0 01             	xor    $0x1,%eax
f0104e66:	84 c0                	test   %al,%al
f0104e68:	74 05                	je     f0104e6f <irq_setmask_8259A+0x2a>
		return;
f0104e6a:	e9 8c 00 00 00       	jmp    f0104efb <irq_setmask_8259A+0xb6>
	outb(IO_PIC1+1, (char)mask);
f0104e6f:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104e73:	0f b6 c0             	movzbl %al,%eax
f0104e76:	c7 45 f0 21 00 00 00 	movl   $0x21,-0x10(%ebp)
f0104e7d:	88 45 ef             	mov    %al,-0x11(%ebp)
f0104e80:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0104e84:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104e87:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104e88:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104e8c:	66 c1 e8 08          	shr    $0x8,%ax
f0104e90:	0f b6 c0             	movzbl %al,%eax
f0104e93:	c7 45 e8 a1 00 00 00 	movl   $0xa1,-0x18(%ebp)
f0104e9a:	88 45 e7             	mov    %al,-0x19(%ebp)
f0104e9d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0104ea1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104ea4:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104ea5:	c7 04 24 14 ab 10 f0 	movl   $0xf010ab14,(%esp)
f0104eac:	e8 9b 00 00 00       	call   f0104f4c <cprintf>
	for (i = 0; i < 16; i++)
f0104eb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0104eb8:	eb 2f                	jmp    f0104ee9 <irq_setmask_8259A+0xa4>
		if (~mask & (1<<i))
f0104eba:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104ebe:	f7 d0                	not    %eax
f0104ec0:	89 c2                	mov    %eax,%edx
f0104ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ec5:	89 c1                	mov    %eax,%ecx
f0104ec7:	d3 fa                	sar    %cl,%edx
f0104ec9:	89 d0                	mov    %edx,%eax
f0104ecb:	83 e0 01             	and    $0x1,%eax
f0104ece:	85 c0                	test   %eax,%eax
f0104ed0:	74 13                	je     f0104ee5 <irq_setmask_8259A+0xa0>
			cprintf(" %d", i);
f0104ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed9:	c7 04 24 28 ab 10 f0 	movl   $0xf010ab28,(%esp)
f0104ee0:	e8 67 00 00 00       	call   f0104f4c <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104ee5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104ee9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
f0104eed:	7e cb                	jle    f0104eba <irq_setmask_8259A+0x75>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104eef:	c7 04 24 2c ab 10 f0 	movl   $0xf010ab2c,(%esp)
f0104ef6:	e8 51 00 00 00       	call   f0104f4c <cprintf>
}
f0104efb:	c9                   	leave  
f0104efc:	c3                   	ret    

f0104efd <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104efd:	55                   	push   %ebp
f0104efe:	89 e5                	mov    %esp,%ebp
f0104f00:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104f03:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f06:	89 04 24             	mov    %eax,(%esp)
f0104f09:	e8 92 bc ff ff       	call   f0100ba0 <cputchar>
	*cnt++;
f0104f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f11:	83 c0 04             	add    $0x4,%eax
f0104f14:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0104f17:	c9                   	leave  
f0104f18:	c3                   	ret    

f0104f19 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104f19:	55                   	push   %ebp
f0104f1a:	89 e5                	mov    %esp,%ebp
f0104f1c:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104f1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104f26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f30:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f34:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f3b:	c7 04 24 fd 4e 10 f0 	movl   $0xf0104efd,(%esp)
f0104f42:	e8 54 30 00 00       	call   f0107f9b <vprintfmt>
	return cnt;
f0104f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104f4a:	c9                   	leave  
f0104f4b:	c3                   	ret    

f0104f4c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104f4c:	55                   	push   %ebp
f0104f4d:	89 e5                	mov    %esp,%ebp
f0104f4f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104f52:	8d 45 0c             	lea    0xc(%ebp),%eax
f0104f55:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
f0104f58:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f62:	89 04 24             	mov    %eax,(%esp)
f0104f65:	e8 af ff ff ff       	call   f0104f19 <vcprintf>
f0104f6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
f0104f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104f70:	c9                   	leave  
f0104f71:	c3                   	ret    

f0104f72 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0104f72:	55                   	push   %ebp
f0104f73:	89 e5                	mov    %esp,%ebp
f0104f75:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104f78:	8b 55 08             	mov    0x8(%ebp),%edx
f0104f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f81:	f0 87 02             	lock xchg %eax,(%edx)
f0104f84:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0104f87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104f8a:	c9                   	leave  
f0104f8b:	c3                   	ret    

f0104f8c <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0104f8c:	55                   	push   %ebp
f0104f8d:	89 e5                	mov    %esp,%ebp
f0104f8f:	83 ec 18             	sub    $0x18,%esp
	spin_lock(&kernel_lock);
f0104f92:	c7 04 24 e0 65 12 f0 	movl   $0xf01265e0,(%esp)
f0104f99:	e8 4f 45 00 00       	call   f01094ed <spin_lock>
}
f0104f9e:	c9                   	leave  
f0104f9f:	c3                   	ret    

f0104fa0 <trapname>:
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
f0104fa0:	55                   	push   %ebp
f0104fa1:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104fa3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fa6:	83 f8 13             	cmp    $0x13,%eax
f0104fa9:	77 0c                	ja     f0104fb7 <trapname+0x17>
		return excnames[trapno];
f0104fab:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fae:	8b 04 85 c0 af 10 f0 	mov    -0xfef5040(,%eax,4),%eax
f0104fb5:	eb 25                	jmp    f0104fdc <trapname+0x3c>
	if (trapno == T_SYSCALL)
f0104fb7:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f0104fbb:	75 07                	jne    f0104fc4 <trapname+0x24>
		return "System call";
f0104fbd:	b8 40 ab 10 f0       	mov    $0xf010ab40,%eax
f0104fc2:	eb 18                	jmp    f0104fdc <trapname+0x3c>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104fc4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
f0104fc8:	7e 0d                	jle    f0104fd7 <trapname+0x37>
f0104fca:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
f0104fce:	7f 07                	jg     f0104fd7 <trapname+0x37>
		return "Hardware Interrupt";
f0104fd0:	b8 4c ab 10 f0       	mov    $0xf010ab4c,%eax
f0104fd5:	eb 05                	jmp    f0104fdc <trapname+0x3c>
	return "(unknown trap)";
f0104fd7:	b8 5f ab 10 f0       	mov    $0xf010ab5f,%eax
}
f0104fdc:	5d                   	pop    %ebp
f0104fdd:	c3                   	ret    

f0104fde <trap_init>:
void irq_ide();
void irq_error();

void
trap_init(void)
{
f0104fde:	55                   	push   %ebp
f0104fdf:	89 e5                	mov    %esp,%ebp
f0104fe1:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0104fe4:	b8 8e 65 10 f0       	mov    $0xf010658e,%eax
f0104fe9:	66 a3 60 32 29 f0    	mov    %ax,0xf0293260
f0104fef:	66 c7 05 62 32 29 f0 	movw   $0x8,0xf0293262
f0104ff6:	08 00 
f0104ff8:	0f b6 05 64 32 29 f0 	movzbl 0xf0293264,%eax
f0104fff:	83 e0 e0             	and    $0xffffffe0,%eax
f0105002:	a2 64 32 29 f0       	mov    %al,0xf0293264
f0105007:	0f b6 05 64 32 29 f0 	movzbl 0xf0293264,%eax
f010500e:	83 e0 1f             	and    $0x1f,%eax
f0105011:	a2 64 32 29 f0       	mov    %al,0xf0293264
f0105016:	0f b6 05 65 32 29 f0 	movzbl 0xf0293265,%eax
f010501d:	83 e0 f0             	and    $0xfffffff0,%eax
f0105020:	83 c8 0e             	or     $0xe,%eax
f0105023:	a2 65 32 29 f0       	mov    %al,0xf0293265
f0105028:	0f b6 05 65 32 29 f0 	movzbl 0xf0293265,%eax
f010502f:	83 e0 ef             	and    $0xffffffef,%eax
f0105032:	a2 65 32 29 f0       	mov    %al,0xf0293265
f0105037:	0f b6 05 65 32 29 f0 	movzbl 0xf0293265,%eax
f010503e:	83 e0 9f             	and    $0xffffff9f,%eax
f0105041:	a2 65 32 29 f0       	mov    %al,0xf0293265
f0105046:	0f b6 05 65 32 29 f0 	movzbl 0xf0293265,%eax
f010504d:	83 c8 80             	or     $0xffffff80,%eax
f0105050:	a2 65 32 29 f0       	mov    %al,0xf0293265
f0105055:	b8 8e 65 10 f0       	mov    $0xf010658e,%eax
f010505a:	c1 e8 10             	shr    $0x10,%eax
f010505d:	66 a3 66 32 29 f0    	mov    %ax,0xf0293266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0105063:	b8 94 65 10 f0       	mov    $0xf0106594,%eax
f0105068:	66 a3 68 32 29 f0    	mov    %ax,0xf0293268
f010506e:	66 c7 05 6a 32 29 f0 	movw   $0x8,0xf029326a
f0105075:	08 00 
f0105077:	0f b6 05 6c 32 29 f0 	movzbl 0xf029326c,%eax
f010507e:	83 e0 e0             	and    $0xffffffe0,%eax
f0105081:	a2 6c 32 29 f0       	mov    %al,0xf029326c
f0105086:	0f b6 05 6c 32 29 f0 	movzbl 0xf029326c,%eax
f010508d:	83 e0 1f             	and    $0x1f,%eax
f0105090:	a2 6c 32 29 f0       	mov    %al,0xf029326c
f0105095:	0f b6 05 6d 32 29 f0 	movzbl 0xf029326d,%eax
f010509c:	83 e0 f0             	and    $0xfffffff0,%eax
f010509f:	83 c8 0e             	or     $0xe,%eax
f01050a2:	a2 6d 32 29 f0       	mov    %al,0xf029326d
f01050a7:	0f b6 05 6d 32 29 f0 	movzbl 0xf029326d,%eax
f01050ae:	83 e0 ef             	and    $0xffffffef,%eax
f01050b1:	a2 6d 32 29 f0       	mov    %al,0xf029326d
f01050b6:	0f b6 05 6d 32 29 f0 	movzbl 0xf029326d,%eax
f01050bd:	83 e0 9f             	and    $0xffffff9f,%eax
f01050c0:	a2 6d 32 29 f0       	mov    %al,0xf029326d
f01050c5:	0f b6 05 6d 32 29 f0 	movzbl 0xf029326d,%eax
f01050cc:	83 c8 80             	or     $0xffffff80,%eax
f01050cf:	a2 6d 32 29 f0       	mov    %al,0xf029326d
f01050d4:	b8 94 65 10 f0       	mov    $0xf0106594,%eax
f01050d9:	c1 e8 10             	shr    $0x10,%eax
f01050dc:	66 a3 6e 32 29 f0    	mov    %ax,0xf029326e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01050e2:	b8 9a 65 10 f0       	mov    $0xf010659a,%eax
f01050e7:	66 a3 70 32 29 f0    	mov    %ax,0xf0293270
f01050ed:	66 c7 05 72 32 29 f0 	movw   $0x8,0xf0293272
f01050f4:	08 00 
f01050f6:	0f b6 05 74 32 29 f0 	movzbl 0xf0293274,%eax
f01050fd:	83 e0 e0             	and    $0xffffffe0,%eax
f0105100:	a2 74 32 29 f0       	mov    %al,0xf0293274
f0105105:	0f b6 05 74 32 29 f0 	movzbl 0xf0293274,%eax
f010510c:	83 e0 1f             	and    $0x1f,%eax
f010510f:	a2 74 32 29 f0       	mov    %al,0xf0293274
f0105114:	0f b6 05 75 32 29 f0 	movzbl 0xf0293275,%eax
f010511b:	83 e0 f0             	and    $0xfffffff0,%eax
f010511e:	83 c8 0e             	or     $0xe,%eax
f0105121:	a2 75 32 29 f0       	mov    %al,0xf0293275
f0105126:	0f b6 05 75 32 29 f0 	movzbl 0xf0293275,%eax
f010512d:	83 e0 ef             	and    $0xffffffef,%eax
f0105130:	a2 75 32 29 f0       	mov    %al,0xf0293275
f0105135:	0f b6 05 75 32 29 f0 	movzbl 0xf0293275,%eax
f010513c:	83 e0 9f             	and    $0xffffff9f,%eax
f010513f:	a2 75 32 29 f0       	mov    %al,0xf0293275
f0105144:	0f b6 05 75 32 29 f0 	movzbl 0xf0293275,%eax
f010514b:	83 c8 80             	or     $0xffffff80,%eax
f010514e:	a2 75 32 29 f0       	mov    %al,0xf0293275
f0105153:	b8 9a 65 10 f0       	mov    $0xf010659a,%eax
f0105158:	c1 e8 10             	shr    $0x10,%eax
f010515b:	66 a3 76 32 29 f0    	mov    %ax,0xf0293276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0105161:	b8 a0 65 10 f0       	mov    $0xf01065a0,%eax
f0105166:	66 a3 78 32 29 f0    	mov    %ax,0xf0293278
f010516c:	66 c7 05 7a 32 29 f0 	movw   $0x8,0xf029327a
f0105173:	08 00 
f0105175:	0f b6 05 7c 32 29 f0 	movzbl 0xf029327c,%eax
f010517c:	83 e0 e0             	and    $0xffffffe0,%eax
f010517f:	a2 7c 32 29 f0       	mov    %al,0xf029327c
f0105184:	0f b6 05 7c 32 29 f0 	movzbl 0xf029327c,%eax
f010518b:	83 e0 1f             	and    $0x1f,%eax
f010518e:	a2 7c 32 29 f0       	mov    %al,0xf029327c
f0105193:	0f b6 05 7d 32 29 f0 	movzbl 0xf029327d,%eax
f010519a:	83 e0 f0             	and    $0xfffffff0,%eax
f010519d:	83 c8 0e             	or     $0xe,%eax
f01051a0:	a2 7d 32 29 f0       	mov    %al,0xf029327d
f01051a5:	0f b6 05 7d 32 29 f0 	movzbl 0xf029327d,%eax
f01051ac:	83 e0 ef             	and    $0xffffffef,%eax
f01051af:	a2 7d 32 29 f0       	mov    %al,0xf029327d
f01051b4:	0f b6 05 7d 32 29 f0 	movzbl 0xf029327d,%eax
f01051bb:	83 c8 60             	or     $0x60,%eax
f01051be:	a2 7d 32 29 f0       	mov    %al,0xf029327d
f01051c3:	0f b6 05 7d 32 29 f0 	movzbl 0xf029327d,%eax
f01051ca:	83 c8 80             	or     $0xffffff80,%eax
f01051cd:	a2 7d 32 29 f0       	mov    %al,0xf029327d
f01051d2:	b8 a0 65 10 f0       	mov    $0xf01065a0,%eax
f01051d7:	c1 e8 10             	shr    $0x10,%eax
f01051da:	66 a3 7e 32 29 f0    	mov    %ax,0xf029327e
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01051e0:	b8 a6 65 10 f0       	mov    $0xf01065a6,%eax
f01051e5:	66 a3 88 32 29 f0    	mov    %ax,0xf0293288
f01051eb:	66 c7 05 8a 32 29 f0 	movw   $0x8,0xf029328a
f01051f2:	08 00 
f01051f4:	0f b6 05 8c 32 29 f0 	movzbl 0xf029328c,%eax
f01051fb:	83 e0 e0             	and    $0xffffffe0,%eax
f01051fe:	a2 8c 32 29 f0       	mov    %al,0xf029328c
f0105203:	0f b6 05 8c 32 29 f0 	movzbl 0xf029328c,%eax
f010520a:	83 e0 1f             	and    $0x1f,%eax
f010520d:	a2 8c 32 29 f0       	mov    %al,0xf029328c
f0105212:	0f b6 05 8d 32 29 f0 	movzbl 0xf029328d,%eax
f0105219:	83 e0 f0             	and    $0xfffffff0,%eax
f010521c:	83 c8 0e             	or     $0xe,%eax
f010521f:	a2 8d 32 29 f0       	mov    %al,0xf029328d
f0105224:	0f b6 05 8d 32 29 f0 	movzbl 0xf029328d,%eax
f010522b:	83 e0 ef             	and    $0xffffffef,%eax
f010522e:	a2 8d 32 29 f0       	mov    %al,0xf029328d
f0105233:	0f b6 05 8d 32 29 f0 	movzbl 0xf029328d,%eax
f010523a:	83 e0 9f             	and    $0xffffff9f,%eax
f010523d:	a2 8d 32 29 f0       	mov    %al,0xf029328d
f0105242:	0f b6 05 8d 32 29 f0 	movzbl 0xf029328d,%eax
f0105249:	83 c8 80             	or     $0xffffff80,%eax
f010524c:	a2 8d 32 29 f0       	mov    %al,0xf029328d
f0105251:	b8 a6 65 10 f0       	mov    $0xf01065a6,%eax
f0105256:	c1 e8 10             	shr    $0x10,%eax
f0105259:	66 a3 8e 32 29 f0    	mov    %ax,0xf029328e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f010525f:	b8 ac 65 10 f0       	mov    $0xf01065ac,%eax
f0105264:	66 a3 90 32 29 f0    	mov    %ax,0xf0293290
f010526a:	66 c7 05 92 32 29 f0 	movw   $0x8,0xf0293292
f0105271:	08 00 
f0105273:	0f b6 05 94 32 29 f0 	movzbl 0xf0293294,%eax
f010527a:	83 e0 e0             	and    $0xffffffe0,%eax
f010527d:	a2 94 32 29 f0       	mov    %al,0xf0293294
f0105282:	0f b6 05 94 32 29 f0 	movzbl 0xf0293294,%eax
f0105289:	83 e0 1f             	and    $0x1f,%eax
f010528c:	a2 94 32 29 f0       	mov    %al,0xf0293294
f0105291:	0f b6 05 95 32 29 f0 	movzbl 0xf0293295,%eax
f0105298:	83 e0 f0             	and    $0xfffffff0,%eax
f010529b:	83 c8 0e             	or     $0xe,%eax
f010529e:	a2 95 32 29 f0       	mov    %al,0xf0293295
f01052a3:	0f b6 05 95 32 29 f0 	movzbl 0xf0293295,%eax
f01052aa:	83 e0 ef             	and    $0xffffffef,%eax
f01052ad:	a2 95 32 29 f0       	mov    %al,0xf0293295
f01052b2:	0f b6 05 95 32 29 f0 	movzbl 0xf0293295,%eax
f01052b9:	83 e0 9f             	and    $0xffffff9f,%eax
f01052bc:	a2 95 32 29 f0       	mov    %al,0xf0293295
f01052c1:	0f b6 05 95 32 29 f0 	movzbl 0xf0293295,%eax
f01052c8:	83 c8 80             	or     $0xffffff80,%eax
f01052cb:	a2 95 32 29 f0       	mov    %al,0xf0293295
f01052d0:	b8 ac 65 10 f0       	mov    $0xf01065ac,%eax
f01052d5:	c1 e8 10             	shr    $0x10,%eax
f01052d8:	66 a3 96 32 29 f0    	mov    %ax,0xf0293296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01052de:	b8 b2 65 10 f0       	mov    $0xf01065b2,%eax
f01052e3:	66 a3 98 32 29 f0    	mov    %ax,0xf0293298
f01052e9:	66 c7 05 9a 32 29 f0 	movw   $0x8,0xf029329a
f01052f0:	08 00 
f01052f2:	0f b6 05 9c 32 29 f0 	movzbl 0xf029329c,%eax
f01052f9:	83 e0 e0             	and    $0xffffffe0,%eax
f01052fc:	a2 9c 32 29 f0       	mov    %al,0xf029329c
f0105301:	0f b6 05 9c 32 29 f0 	movzbl 0xf029329c,%eax
f0105308:	83 e0 1f             	and    $0x1f,%eax
f010530b:	a2 9c 32 29 f0       	mov    %al,0xf029329c
f0105310:	0f b6 05 9d 32 29 f0 	movzbl 0xf029329d,%eax
f0105317:	83 e0 f0             	and    $0xfffffff0,%eax
f010531a:	83 c8 0e             	or     $0xe,%eax
f010531d:	a2 9d 32 29 f0       	mov    %al,0xf029329d
f0105322:	0f b6 05 9d 32 29 f0 	movzbl 0xf029329d,%eax
f0105329:	83 e0 ef             	and    $0xffffffef,%eax
f010532c:	a2 9d 32 29 f0       	mov    %al,0xf029329d
f0105331:	0f b6 05 9d 32 29 f0 	movzbl 0xf029329d,%eax
f0105338:	83 e0 9f             	and    $0xffffff9f,%eax
f010533b:	a2 9d 32 29 f0       	mov    %al,0xf029329d
f0105340:	0f b6 05 9d 32 29 f0 	movzbl 0xf029329d,%eax
f0105347:	83 c8 80             	or     $0xffffff80,%eax
f010534a:	a2 9d 32 29 f0       	mov    %al,0xf029329d
f010534f:	b8 b2 65 10 f0       	mov    $0xf01065b2,%eax
f0105354:	c1 e8 10             	shr    $0x10,%eax
f0105357:	66 a3 9e 32 29 f0    	mov    %ax,0xf029329e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f010535d:	b8 b8 65 10 f0       	mov    $0xf01065b8,%eax
f0105362:	66 a3 a0 32 29 f0    	mov    %ax,0xf02932a0
f0105368:	66 c7 05 a2 32 29 f0 	movw   $0x8,0xf02932a2
f010536f:	08 00 
f0105371:	0f b6 05 a4 32 29 f0 	movzbl 0xf02932a4,%eax
f0105378:	83 e0 e0             	and    $0xffffffe0,%eax
f010537b:	a2 a4 32 29 f0       	mov    %al,0xf02932a4
f0105380:	0f b6 05 a4 32 29 f0 	movzbl 0xf02932a4,%eax
f0105387:	83 e0 1f             	and    $0x1f,%eax
f010538a:	a2 a4 32 29 f0       	mov    %al,0xf02932a4
f010538f:	0f b6 05 a5 32 29 f0 	movzbl 0xf02932a5,%eax
f0105396:	83 e0 f0             	and    $0xfffffff0,%eax
f0105399:	83 c8 0e             	or     $0xe,%eax
f010539c:	a2 a5 32 29 f0       	mov    %al,0xf02932a5
f01053a1:	0f b6 05 a5 32 29 f0 	movzbl 0xf02932a5,%eax
f01053a8:	83 e0 ef             	and    $0xffffffef,%eax
f01053ab:	a2 a5 32 29 f0       	mov    %al,0xf02932a5
f01053b0:	0f b6 05 a5 32 29 f0 	movzbl 0xf02932a5,%eax
f01053b7:	83 e0 9f             	and    $0xffffff9f,%eax
f01053ba:	a2 a5 32 29 f0       	mov    %al,0xf02932a5
f01053bf:	0f b6 05 a5 32 29 f0 	movzbl 0xf02932a5,%eax
f01053c6:	83 c8 80             	or     $0xffffff80,%eax
f01053c9:	a2 a5 32 29 f0       	mov    %al,0xf02932a5
f01053ce:	b8 b8 65 10 f0       	mov    $0xf01065b8,%eax
f01053d3:	c1 e8 10             	shr    $0x10,%eax
f01053d6:	66 a3 a6 32 29 f0    	mov    %ax,0xf02932a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01053dc:	b8 bc 65 10 f0       	mov    $0xf01065bc,%eax
f01053e1:	66 a3 b0 32 29 f0    	mov    %ax,0xf02932b0
f01053e7:	66 c7 05 b2 32 29 f0 	movw   $0x8,0xf02932b2
f01053ee:	08 00 
f01053f0:	0f b6 05 b4 32 29 f0 	movzbl 0xf02932b4,%eax
f01053f7:	83 e0 e0             	and    $0xffffffe0,%eax
f01053fa:	a2 b4 32 29 f0       	mov    %al,0xf02932b4
f01053ff:	0f b6 05 b4 32 29 f0 	movzbl 0xf02932b4,%eax
f0105406:	83 e0 1f             	and    $0x1f,%eax
f0105409:	a2 b4 32 29 f0       	mov    %al,0xf02932b4
f010540e:	0f b6 05 b5 32 29 f0 	movzbl 0xf02932b5,%eax
f0105415:	83 e0 f0             	and    $0xfffffff0,%eax
f0105418:	83 c8 0e             	or     $0xe,%eax
f010541b:	a2 b5 32 29 f0       	mov    %al,0xf02932b5
f0105420:	0f b6 05 b5 32 29 f0 	movzbl 0xf02932b5,%eax
f0105427:	83 e0 ef             	and    $0xffffffef,%eax
f010542a:	a2 b5 32 29 f0       	mov    %al,0xf02932b5
f010542f:	0f b6 05 b5 32 29 f0 	movzbl 0xf02932b5,%eax
f0105436:	83 e0 9f             	and    $0xffffff9f,%eax
f0105439:	a2 b5 32 29 f0       	mov    %al,0xf02932b5
f010543e:	0f b6 05 b5 32 29 f0 	movzbl 0xf02932b5,%eax
f0105445:	83 c8 80             	or     $0xffffff80,%eax
f0105448:	a2 b5 32 29 f0       	mov    %al,0xf02932b5
f010544d:	b8 bc 65 10 f0       	mov    $0xf01065bc,%eax
f0105452:	c1 e8 10             	shr    $0x10,%eax
f0105455:	66 a3 b6 32 29 f0    	mov    %ax,0xf02932b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f010545b:	b8 c0 65 10 f0       	mov    $0xf01065c0,%eax
f0105460:	66 a3 b8 32 29 f0    	mov    %ax,0xf02932b8
f0105466:	66 c7 05 ba 32 29 f0 	movw   $0x8,0xf02932ba
f010546d:	08 00 
f010546f:	0f b6 05 bc 32 29 f0 	movzbl 0xf02932bc,%eax
f0105476:	83 e0 e0             	and    $0xffffffe0,%eax
f0105479:	a2 bc 32 29 f0       	mov    %al,0xf02932bc
f010547e:	0f b6 05 bc 32 29 f0 	movzbl 0xf02932bc,%eax
f0105485:	83 e0 1f             	and    $0x1f,%eax
f0105488:	a2 bc 32 29 f0       	mov    %al,0xf02932bc
f010548d:	0f b6 05 bd 32 29 f0 	movzbl 0xf02932bd,%eax
f0105494:	83 e0 f0             	and    $0xfffffff0,%eax
f0105497:	83 c8 0e             	or     $0xe,%eax
f010549a:	a2 bd 32 29 f0       	mov    %al,0xf02932bd
f010549f:	0f b6 05 bd 32 29 f0 	movzbl 0xf02932bd,%eax
f01054a6:	83 e0 ef             	and    $0xffffffef,%eax
f01054a9:	a2 bd 32 29 f0       	mov    %al,0xf02932bd
f01054ae:	0f b6 05 bd 32 29 f0 	movzbl 0xf02932bd,%eax
f01054b5:	83 e0 9f             	and    $0xffffff9f,%eax
f01054b8:	a2 bd 32 29 f0       	mov    %al,0xf02932bd
f01054bd:	0f b6 05 bd 32 29 f0 	movzbl 0xf02932bd,%eax
f01054c4:	83 c8 80             	or     $0xffffff80,%eax
f01054c7:	a2 bd 32 29 f0       	mov    %al,0xf02932bd
f01054cc:	b8 c0 65 10 f0       	mov    $0xf01065c0,%eax
f01054d1:	c1 e8 10             	shr    $0x10,%eax
f01054d4:	66 a3 be 32 29 f0    	mov    %ax,0xf02932be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01054da:	b8 c4 65 10 f0       	mov    $0xf01065c4,%eax
f01054df:	66 a3 c0 32 29 f0    	mov    %ax,0xf02932c0
f01054e5:	66 c7 05 c2 32 29 f0 	movw   $0x8,0xf02932c2
f01054ec:	08 00 
f01054ee:	0f b6 05 c4 32 29 f0 	movzbl 0xf02932c4,%eax
f01054f5:	83 e0 e0             	and    $0xffffffe0,%eax
f01054f8:	a2 c4 32 29 f0       	mov    %al,0xf02932c4
f01054fd:	0f b6 05 c4 32 29 f0 	movzbl 0xf02932c4,%eax
f0105504:	83 e0 1f             	and    $0x1f,%eax
f0105507:	a2 c4 32 29 f0       	mov    %al,0xf02932c4
f010550c:	0f b6 05 c5 32 29 f0 	movzbl 0xf02932c5,%eax
f0105513:	83 e0 f0             	and    $0xfffffff0,%eax
f0105516:	83 c8 0e             	or     $0xe,%eax
f0105519:	a2 c5 32 29 f0       	mov    %al,0xf02932c5
f010551e:	0f b6 05 c5 32 29 f0 	movzbl 0xf02932c5,%eax
f0105525:	83 e0 ef             	and    $0xffffffef,%eax
f0105528:	a2 c5 32 29 f0       	mov    %al,0xf02932c5
f010552d:	0f b6 05 c5 32 29 f0 	movzbl 0xf02932c5,%eax
f0105534:	83 e0 9f             	and    $0xffffff9f,%eax
f0105537:	a2 c5 32 29 f0       	mov    %al,0xf02932c5
f010553c:	0f b6 05 c5 32 29 f0 	movzbl 0xf02932c5,%eax
f0105543:	83 c8 80             	or     $0xffffff80,%eax
f0105546:	a2 c5 32 29 f0       	mov    %al,0xf02932c5
f010554b:	b8 c4 65 10 f0       	mov    $0xf01065c4,%eax
f0105550:	c1 e8 10             	shr    $0x10,%eax
f0105553:	66 a3 c6 32 29 f0    	mov    %ax,0xf02932c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0105559:	b8 c8 65 10 f0       	mov    $0xf01065c8,%eax
f010555e:	66 a3 c8 32 29 f0    	mov    %ax,0xf02932c8
f0105564:	66 c7 05 ca 32 29 f0 	movw   $0x8,0xf02932ca
f010556b:	08 00 
f010556d:	0f b6 05 cc 32 29 f0 	movzbl 0xf02932cc,%eax
f0105574:	83 e0 e0             	and    $0xffffffe0,%eax
f0105577:	a2 cc 32 29 f0       	mov    %al,0xf02932cc
f010557c:	0f b6 05 cc 32 29 f0 	movzbl 0xf02932cc,%eax
f0105583:	83 e0 1f             	and    $0x1f,%eax
f0105586:	a2 cc 32 29 f0       	mov    %al,0xf02932cc
f010558b:	0f b6 05 cd 32 29 f0 	movzbl 0xf02932cd,%eax
f0105592:	83 e0 f0             	and    $0xfffffff0,%eax
f0105595:	83 c8 0e             	or     $0xe,%eax
f0105598:	a2 cd 32 29 f0       	mov    %al,0xf02932cd
f010559d:	0f b6 05 cd 32 29 f0 	movzbl 0xf02932cd,%eax
f01055a4:	83 e0 ef             	and    $0xffffffef,%eax
f01055a7:	a2 cd 32 29 f0       	mov    %al,0xf02932cd
f01055ac:	0f b6 05 cd 32 29 f0 	movzbl 0xf02932cd,%eax
f01055b3:	83 e0 9f             	and    $0xffffff9f,%eax
f01055b6:	a2 cd 32 29 f0       	mov    %al,0xf02932cd
f01055bb:	0f b6 05 cd 32 29 f0 	movzbl 0xf02932cd,%eax
f01055c2:	83 c8 80             	or     $0xffffff80,%eax
f01055c5:	a2 cd 32 29 f0       	mov    %al,0xf02932cd
f01055ca:	b8 c8 65 10 f0       	mov    $0xf01065c8,%eax
f01055cf:	c1 e8 10             	shr    $0x10,%eax
f01055d2:	66 a3 ce 32 29 f0    	mov    %ax,0xf02932ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01055d8:	b8 cc 65 10 f0       	mov    $0xf01065cc,%eax
f01055dd:	66 a3 d0 32 29 f0    	mov    %ax,0xf02932d0
f01055e3:	66 c7 05 d2 32 29 f0 	movw   $0x8,0xf02932d2
f01055ea:	08 00 
f01055ec:	0f b6 05 d4 32 29 f0 	movzbl 0xf02932d4,%eax
f01055f3:	83 e0 e0             	and    $0xffffffe0,%eax
f01055f6:	a2 d4 32 29 f0       	mov    %al,0xf02932d4
f01055fb:	0f b6 05 d4 32 29 f0 	movzbl 0xf02932d4,%eax
f0105602:	83 e0 1f             	and    $0x1f,%eax
f0105605:	a2 d4 32 29 f0       	mov    %al,0xf02932d4
f010560a:	0f b6 05 d5 32 29 f0 	movzbl 0xf02932d5,%eax
f0105611:	83 e0 f0             	and    $0xfffffff0,%eax
f0105614:	83 c8 0e             	or     $0xe,%eax
f0105617:	a2 d5 32 29 f0       	mov    %al,0xf02932d5
f010561c:	0f b6 05 d5 32 29 f0 	movzbl 0xf02932d5,%eax
f0105623:	83 e0 ef             	and    $0xffffffef,%eax
f0105626:	a2 d5 32 29 f0       	mov    %al,0xf02932d5
f010562b:	0f b6 05 d5 32 29 f0 	movzbl 0xf02932d5,%eax
f0105632:	83 e0 9f             	and    $0xffffff9f,%eax
f0105635:	a2 d5 32 29 f0       	mov    %al,0xf02932d5
f010563a:	0f b6 05 d5 32 29 f0 	movzbl 0xf02932d5,%eax
f0105641:	83 c8 80             	or     $0xffffff80,%eax
f0105644:	a2 d5 32 29 f0       	mov    %al,0xf02932d5
f0105649:	b8 cc 65 10 f0       	mov    $0xf01065cc,%eax
f010564e:	c1 e8 10             	shr    $0x10,%eax
f0105651:	66 a3 d6 32 29 f0    	mov    %ax,0xf02932d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0105657:	b8 d0 65 10 f0       	mov    $0xf01065d0,%eax
f010565c:	66 a3 e0 32 29 f0    	mov    %ax,0xf02932e0
f0105662:	66 c7 05 e2 32 29 f0 	movw   $0x8,0xf02932e2
f0105669:	08 00 
f010566b:	0f b6 05 e4 32 29 f0 	movzbl 0xf02932e4,%eax
f0105672:	83 e0 e0             	and    $0xffffffe0,%eax
f0105675:	a2 e4 32 29 f0       	mov    %al,0xf02932e4
f010567a:	0f b6 05 e4 32 29 f0 	movzbl 0xf02932e4,%eax
f0105681:	83 e0 1f             	and    $0x1f,%eax
f0105684:	a2 e4 32 29 f0       	mov    %al,0xf02932e4
f0105689:	0f b6 05 e5 32 29 f0 	movzbl 0xf02932e5,%eax
f0105690:	83 e0 f0             	and    $0xfffffff0,%eax
f0105693:	83 c8 0e             	or     $0xe,%eax
f0105696:	a2 e5 32 29 f0       	mov    %al,0xf02932e5
f010569b:	0f b6 05 e5 32 29 f0 	movzbl 0xf02932e5,%eax
f01056a2:	83 e0 ef             	and    $0xffffffef,%eax
f01056a5:	a2 e5 32 29 f0       	mov    %al,0xf02932e5
f01056aa:	0f b6 05 e5 32 29 f0 	movzbl 0xf02932e5,%eax
f01056b1:	83 e0 9f             	and    $0xffffff9f,%eax
f01056b4:	a2 e5 32 29 f0       	mov    %al,0xf02932e5
f01056b9:	0f b6 05 e5 32 29 f0 	movzbl 0xf02932e5,%eax
f01056c0:	83 c8 80             	or     $0xffffff80,%eax
f01056c3:	a2 e5 32 29 f0       	mov    %al,0xf02932e5
f01056c8:	b8 d0 65 10 f0       	mov    $0xf01065d0,%eax
f01056cd:	c1 e8 10             	shr    $0x10,%eax
f01056d0:	66 a3 e6 32 29 f0    	mov    %ax,0xf02932e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01056d6:	b8 d6 65 10 f0       	mov    $0xf01065d6,%eax
f01056db:	66 a3 e8 32 29 f0    	mov    %ax,0xf02932e8
f01056e1:	66 c7 05 ea 32 29 f0 	movw   $0x8,0xf02932ea
f01056e8:	08 00 
f01056ea:	0f b6 05 ec 32 29 f0 	movzbl 0xf02932ec,%eax
f01056f1:	83 e0 e0             	and    $0xffffffe0,%eax
f01056f4:	a2 ec 32 29 f0       	mov    %al,0xf02932ec
f01056f9:	0f b6 05 ec 32 29 f0 	movzbl 0xf02932ec,%eax
f0105700:	83 e0 1f             	and    $0x1f,%eax
f0105703:	a2 ec 32 29 f0       	mov    %al,0xf02932ec
f0105708:	0f b6 05 ed 32 29 f0 	movzbl 0xf02932ed,%eax
f010570f:	83 e0 f0             	and    $0xfffffff0,%eax
f0105712:	83 c8 0e             	or     $0xe,%eax
f0105715:	a2 ed 32 29 f0       	mov    %al,0xf02932ed
f010571a:	0f b6 05 ed 32 29 f0 	movzbl 0xf02932ed,%eax
f0105721:	83 e0 ef             	and    $0xffffffef,%eax
f0105724:	a2 ed 32 29 f0       	mov    %al,0xf02932ed
f0105729:	0f b6 05 ed 32 29 f0 	movzbl 0xf02932ed,%eax
f0105730:	83 e0 9f             	and    $0xffffff9f,%eax
f0105733:	a2 ed 32 29 f0       	mov    %al,0xf02932ed
f0105738:	0f b6 05 ed 32 29 f0 	movzbl 0xf02932ed,%eax
f010573f:	83 c8 80             	or     $0xffffff80,%eax
f0105742:	a2 ed 32 29 f0       	mov    %al,0xf02932ed
f0105747:	b8 d6 65 10 f0       	mov    $0xf01065d6,%eax
f010574c:	c1 e8 10             	shr    $0x10,%eax
f010574f:	66 a3 ee 32 29 f0    	mov    %ax,0xf02932ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0105755:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f010575a:	66 a3 f0 32 29 f0    	mov    %ax,0xf02932f0
f0105760:	66 c7 05 f2 32 29 f0 	movw   $0x8,0xf02932f2
f0105767:	08 00 
f0105769:	0f b6 05 f4 32 29 f0 	movzbl 0xf02932f4,%eax
f0105770:	83 e0 e0             	and    $0xffffffe0,%eax
f0105773:	a2 f4 32 29 f0       	mov    %al,0xf02932f4
f0105778:	0f b6 05 f4 32 29 f0 	movzbl 0xf02932f4,%eax
f010577f:	83 e0 1f             	and    $0x1f,%eax
f0105782:	a2 f4 32 29 f0       	mov    %al,0xf02932f4
f0105787:	0f b6 05 f5 32 29 f0 	movzbl 0xf02932f5,%eax
f010578e:	83 e0 f0             	and    $0xfffffff0,%eax
f0105791:	83 c8 0e             	or     $0xe,%eax
f0105794:	a2 f5 32 29 f0       	mov    %al,0xf02932f5
f0105799:	0f b6 05 f5 32 29 f0 	movzbl 0xf02932f5,%eax
f01057a0:	83 e0 ef             	and    $0xffffffef,%eax
f01057a3:	a2 f5 32 29 f0       	mov    %al,0xf02932f5
f01057a8:	0f b6 05 f5 32 29 f0 	movzbl 0xf02932f5,%eax
f01057af:	83 e0 9f             	and    $0xffffff9f,%eax
f01057b2:	a2 f5 32 29 f0       	mov    %al,0xf02932f5
f01057b7:	0f b6 05 f5 32 29 f0 	movzbl 0xf02932f5,%eax
f01057be:	83 c8 80             	or     $0xffffff80,%eax
f01057c1:	a2 f5 32 29 f0       	mov    %al,0xf02932f5
f01057c6:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f01057cb:	c1 e8 10             	shr    $0x10,%eax
f01057ce:	66 a3 f6 32 29 f0    	mov    %ax,0xf02932f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f01057d4:	b8 e0 65 10 f0       	mov    $0xf01065e0,%eax
f01057d9:	66 a3 f8 32 29 f0    	mov    %ax,0xf02932f8
f01057df:	66 c7 05 fa 32 29 f0 	movw   $0x8,0xf02932fa
f01057e6:	08 00 
f01057e8:	0f b6 05 fc 32 29 f0 	movzbl 0xf02932fc,%eax
f01057ef:	83 e0 e0             	and    $0xffffffe0,%eax
f01057f2:	a2 fc 32 29 f0       	mov    %al,0xf02932fc
f01057f7:	0f b6 05 fc 32 29 f0 	movzbl 0xf02932fc,%eax
f01057fe:	83 e0 1f             	and    $0x1f,%eax
f0105801:	a2 fc 32 29 f0       	mov    %al,0xf02932fc
f0105806:	0f b6 05 fd 32 29 f0 	movzbl 0xf02932fd,%eax
f010580d:	83 e0 f0             	and    $0xfffffff0,%eax
f0105810:	83 c8 0e             	or     $0xe,%eax
f0105813:	a2 fd 32 29 f0       	mov    %al,0xf02932fd
f0105818:	0f b6 05 fd 32 29 f0 	movzbl 0xf02932fd,%eax
f010581f:	83 e0 ef             	and    $0xffffffef,%eax
f0105822:	a2 fd 32 29 f0       	mov    %al,0xf02932fd
f0105827:	0f b6 05 fd 32 29 f0 	movzbl 0xf02932fd,%eax
f010582e:	83 e0 9f             	and    $0xffffff9f,%eax
f0105831:	a2 fd 32 29 f0       	mov    %al,0xf02932fd
f0105836:	0f b6 05 fd 32 29 f0 	movzbl 0xf02932fd,%eax
f010583d:	83 c8 80             	or     $0xffffff80,%eax
f0105840:	a2 fd 32 29 f0       	mov    %al,0xf02932fd
f0105845:	b8 e0 65 10 f0       	mov    $0xf01065e0,%eax
f010584a:	c1 e8 10             	shr    $0x10,%eax
f010584d:	66 a3 fe 32 29 f0    	mov    %ax,0xf02932fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0105853:	b8 e6 65 10 f0       	mov    $0xf01065e6,%eax
f0105858:	66 a3 e0 33 29 f0    	mov    %ax,0xf02933e0
f010585e:	66 c7 05 e2 33 29 f0 	movw   $0x8,0xf02933e2
f0105865:	08 00 
f0105867:	0f b6 05 e4 33 29 f0 	movzbl 0xf02933e4,%eax
f010586e:	83 e0 e0             	and    $0xffffffe0,%eax
f0105871:	a2 e4 33 29 f0       	mov    %al,0xf02933e4
f0105876:	0f b6 05 e4 33 29 f0 	movzbl 0xf02933e4,%eax
f010587d:	83 e0 1f             	and    $0x1f,%eax
f0105880:	a2 e4 33 29 f0       	mov    %al,0xf02933e4
f0105885:	0f b6 05 e5 33 29 f0 	movzbl 0xf02933e5,%eax
f010588c:	83 e0 f0             	and    $0xfffffff0,%eax
f010588f:	83 c8 0e             	or     $0xe,%eax
f0105892:	a2 e5 33 29 f0       	mov    %al,0xf02933e5
f0105897:	0f b6 05 e5 33 29 f0 	movzbl 0xf02933e5,%eax
f010589e:	83 e0 ef             	and    $0xffffffef,%eax
f01058a1:	a2 e5 33 29 f0       	mov    %al,0xf02933e5
f01058a6:	0f b6 05 e5 33 29 f0 	movzbl 0xf02933e5,%eax
f01058ad:	83 c8 60             	or     $0x60,%eax
f01058b0:	a2 e5 33 29 f0       	mov    %al,0xf02933e5
f01058b5:	0f b6 05 e5 33 29 f0 	movzbl 0xf02933e5,%eax
f01058bc:	83 c8 80             	or     $0xffffff80,%eax
f01058bf:	a2 e5 33 29 f0       	mov    %al,0xf02933e5
f01058c4:	b8 e6 65 10 f0       	mov    $0xf01065e6,%eax
f01058c9:	c1 e8 10             	shr    $0x10,%eax
f01058cc:	66 a3 e6 33 29 f0    	mov    %ax,0xf02933e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f01058d2:	b8 ec 65 10 f0       	mov    $0xf01065ec,%eax
f01058d7:	66 a3 60 33 29 f0    	mov    %ax,0xf0293360
f01058dd:	66 c7 05 62 33 29 f0 	movw   $0x8,0xf0293362
f01058e4:	08 00 
f01058e6:	0f b6 05 64 33 29 f0 	movzbl 0xf0293364,%eax
f01058ed:	83 e0 e0             	and    $0xffffffe0,%eax
f01058f0:	a2 64 33 29 f0       	mov    %al,0xf0293364
f01058f5:	0f b6 05 64 33 29 f0 	movzbl 0xf0293364,%eax
f01058fc:	83 e0 1f             	and    $0x1f,%eax
f01058ff:	a2 64 33 29 f0       	mov    %al,0xf0293364
f0105904:	0f b6 05 65 33 29 f0 	movzbl 0xf0293365,%eax
f010590b:	83 e0 f0             	and    $0xfffffff0,%eax
f010590e:	83 c8 0e             	or     $0xe,%eax
f0105911:	a2 65 33 29 f0       	mov    %al,0xf0293365
f0105916:	0f b6 05 65 33 29 f0 	movzbl 0xf0293365,%eax
f010591d:	83 e0 ef             	and    $0xffffffef,%eax
f0105920:	a2 65 33 29 f0       	mov    %al,0xf0293365
f0105925:	0f b6 05 65 33 29 f0 	movzbl 0xf0293365,%eax
f010592c:	83 e0 9f             	and    $0xffffff9f,%eax
f010592f:	a2 65 33 29 f0       	mov    %al,0xf0293365
f0105934:	0f b6 05 65 33 29 f0 	movzbl 0xf0293365,%eax
f010593b:	83 c8 80             	or     $0xffffff80,%eax
f010593e:	a2 65 33 29 f0       	mov    %al,0xf0293365
f0105943:	b8 ec 65 10 f0       	mov    $0xf01065ec,%eax
f0105948:	c1 e8 10             	shr    $0x10,%eax
f010594b:	66 a3 66 33 29 f0    	mov    %ax,0xf0293366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f0105951:	b8 f2 65 10 f0       	mov    $0xf01065f2,%eax
f0105956:	66 a3 68 33 29 f0    	mov    %ax,0xf0293368
f010595c:	66 c7 05 6a 33 29 f0 	movw   $0x8,0xf029336a
f0105963:	08 00 
f0105965:	0f b6 05 6c 33 29 f0 	movzbl 0xf029336c,%eax
f010596c:	83 e0 e0             	and    $0xffffffe0,%eax
f010596f:	a2 6c 33 29 f0       	mov    %al,0xf029336c
f0105974:	0f b6 05 6c 33 29 f0 	movzbl 0xf029336c,%eax
f010597b:	83 e0 1f             	and    $0x1f,%eax
f010597e:	a2 6c 33 29 f0       	mov    %al,0xf029336c
f0105983:	0f b6 05 6d 33 29 f0 	movzbl 0xf029336d,%eax
f010598a:	83 e0 f0             	and    $0xfffffff0,%eax
f010598d:	83 c8 0e             	or     $0xe,%eax
f0105990:	a2 6d 33 29 f0       	mov    %al,0xf029336d
f0105995:	0f b6 05 6d 33 29 f0 	movzbl 0xf029336d,%eax
f010599c:	83 e0 ef             	and    $0xffffffef,%eax
f010599f:	a2 6d 33 29 f0       	mov    %al,0xf029336d
f01059a4:	0f b6 05 6d 33 29 f0 	movzbl 0xf029336d,%eax
f01059ab:	83 e0 9f             	and    $0xffffff9f,%eax
f01059ae:	a2 6d 33 29 f0       	mov    %al,0xf029336d
f01059b3:	0f b6 05 6d 33 29 f0 	movzbl 0xf029336d,%eax
f01059ba:	83 c8 80             	or     $0xffffff80,%eax
f01059bd:	a2 6d 33 29 f0       	mov    %al,0xf029336d
f01059c2:	b8 f2 65 10 f0       	mov    $0xf01065f2,%eax
f01059c7:	c1 e8 10             	shr    $0x10,%eax
f01059ca:	66 a3 6e 33 29 f0    	mov    %ax,0xf029336e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f01059d0:	b8 f8 65 10 f0       	mov    $0xf01065f8,%eax
f01059d5:	66 a3 80 33 29 f0    	mov    %ax,0xf0293380
f01059db:	66 c7 05 82 33 29 f0 	movw   $0x8,0xf0293382
f01059e2:	08 00 
f01059e4:	0f b6 05 84 33 29 f0 	movzbl 0xf0293384,%eax
f01059eb:	83 e0 e0             	and    $0xffffffe0,%eax
f01059ee:	a2 84 33 29 f0       	mov    %al,0xf0293384
f01059f3:	0f b6 05 84 33 29 f0 	movzbl 0xf0293384,%eax
f01059fa:	83 e0 1f             	and    $0x1f,%eax
f01059fd:	a2 84 33 29 f0       	mov    %al,0xf0293384
f0105a02:	0f b6 05 85 33 29 f0 	movzbl 0xf0293385,%eax
f0105a09:	83 e0 f0             	and    $0xfffffff0,%eax
f0105a0c:	83 c8 0e             	or     $0xe,%eax
f0105a0f:	a2 85 33 29 f0       	mov    %al,0xf0293385
f0105a14:	0f b6 05 85 33 29 f0 	movzbl 0xf0293385,%eax
f0105a1b:	83 e0 ef             	and    $0xffffffef,%eax
f0105a1e:	a2 85 33 29 f0       	mov    %al,0xf0293385
f0105a23:	0f b6 05 85 33 29 f0 	movzbl 0xf0293385,%eax
f0105a2a:	83 e0 9f             	and    $0xffffff9f,%eax
f0105a2d:	a2 85 33 29 f0       	mov    %al,0xf0293385
f0105a32:	0f b6 05 85 33 29 f0 	movzbl 0xf0293385,%eax
f0105a39:	83 c8 80             	or     $0xffffff80,%eax
f0105a3c:	a2 85 33 29 f0       	mov    %al,0xf0293385
f0105a41:	b8 f8 65 10 f0       	mov    $0xf01065f8,%eax
f0105a46:	c1 e8 10             	shr    $0x10,%eax
f0105a49:	66 a3 86 33 29 f0    	mov    %ax,0xf0293386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f0105a4f:	b8 fe 65 10 f0       	mov    $0xf01065fe,%eax
f0105a54:	66 a3 98 33 29 f0    	mov    %ax,0xf0293398
f0105a5a:	66 c7 05 9a 33 29 f0 	movw   $0x8,0xf029339a
f0105a61:	08 00 
f0105a63:	0f b6 05 9c 33 29 f0 	movzbl 0xf029339c,%eax
f0105a6a:	83 e0 e0             	and    $0xffffffe0,%eax
f0105a6d:	a2 9c 33 29 f0       	mov    %al,0xf029339c
f0105a72:	0f b6 05 9c 33 29 f0 	movzbl 0xf029339c,%eax
f0105a79:	83 e0 1f             	and    $0x1f,%eax
f0105a7c:	a2 9c 33 29 f0       	mov    %al,0xf029339c
f0105a81:	0f b6 05 9d 33 29 f0 	movzbl 0xf029339d,%eax
f0105a88:	83 e0 f0             	and    $0xfffffff0,%eax
f0105a8b:	83 c8 0e             	or     $0xe,%eax
f0105a8e:	a2 9d 33 29 f0       	mov    %al,0xf029339d
f0105a93:	0f b6 05 9d 33 29 f0 	movzbl 0xf029339d,%eax
f0105a9a:	83 e0 ef             	and    $0xffffffef,%eax
f0105a9d:	a2 9d 33 29 f0       	mov    %al,0xf029339d
f0105aa2:	0f b6 05 9d 33 29 f0 	movzbl 0xf029339d,%eax
f0105aa9:	83 e0 9f             	and    $0xffffff9f,%eax
f0105aac:	a2 9d 33 29 f0       	mov    %al,0xf029339d
f0105ab1:	0f b6 05 9d 33 29 f0 	movzbl 0xf029339d,%eax
f0105ab8:	83 c8 80             	or     $0xffffff80,%eax
f0105abb:	a2 9d 33 29 f0       	mov    %al,0xf029339d
f0105ac0:	b8 fe 65 10 f0       	mov    $0xf01065fe,%eax
f0105ac5:	c1 e8 10             	shr    $0x10,%eax
f0105ac8:	66 a3 9e 33 29 f0    	mov    %ax,0xf029339e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0105ace:	b8 04 66 10 f0       	mov    $0xf0106604,%eax
f0105ad3:	66 a3 d0 33 29 f0    	mov    %ax,0xf02933d0
f0105ad9:	66 c7 05 d2 33 29 f0 	movw   $0x8,0xf02933d2
f0105ae0:	08 00 
f0105ae2:	0f b6 05 d4 33 29 f0 	movzbl 0xf02933d4,%eax
f0105ae9:	83 e0 e0             	and    $0xffffffe0,%eax
f0105aec:	a2 d4 33 29 f0       	mov    %al,0xf02933d4
f0105af1:	0f b6 05 d4 33 29 f0 	movzbl 0xf02933d4,%eax
f0105af8:	83 e0 1f             	and    $0x1f,%eax
f0105afb:	a2 d4 33 29 f0       	mov    %al,0xf02933d4
f0105b00:	0f b6 05 d5 33 29 f0 	movzbl 0xf02933d5,%eax
f0105b07:	83 e0 f0             	and    $0xfffffff0,%eax
f0105b0a:	83 c8 0e             	or     $0xe,%eax
f0105b0d:	a2 d5 33 29 f0       	mov    %al,0xf02933d5
f0105b12:	0f b6 05 d5 33 29 f0 	movzbl 0xf02933d5,%eax
f0105b19:	83 e0 ef             	and    $0xffffffef,%eax
f0105b1c:	a2 d5 33 29 f0       	mov    %al,0xf02933d5
f0105b21:	0f b6 05 d5 33 29 f0 	movzbl 0xf02933d5,%eax
f0105b28:	83 e0 9f             	and    $0xffffff9f,%eax
f0105b2b:	a2 d5 33 29 f0       	mov    %al,0xf02933d5
f0105b30:	0f b6 05 d5 33 29 f0 	movzbl 0xf02933d5,%eax
f0105b37:	83 c8 80             	or     $0xffffff80,%eax
f0105b3a:	a2 d5 33 29 f0       	mov    %al,0xf02933d5
f0105b3f:	b8 04 66 10 f0       	mov    $0xf0106604,%eax
f0105b44:	c1 e8 10             	shr    $0x10,%eax
f0105b47:	66 a3 d6 33 29 f0    	mov    %ax,0xf02933d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0105b4d:	b8 0a 66 10 f0       	mov    $0xf010660a,%eax
f0105b52:	66 a3 f8 33 29 f0    	mov    %ax,0xf02933f8
f0105b58:	66 c7 05 fa 33 29 f0 	movw   $0x8,0xf02933fa
f0105b5f:	08 00 
f0105b61:	0f b6 05 fc 33 29 f0 	movzbl 0xf02933fc,%eax
f0105b68:	83 e0 e0             	and    $0xffffffe0,%eax
f0105b6b:	a2 fc 33 29 f0       	mov    %al,0xf02933fc
f0105b70:	0f b6 05 fc 33 29 f0 	movzbl 0xf02933fc,%eax
f0105b77:	83 e0 1f             	and    $0x1f,%eax
f0105b7a:	a2 fc 33 29 f0       	mov    %al,0xf02933fc
f0105b7f:	0f b6 05 fd 33 29 f0 	movzbl 0xf02933fd,%eax
f0105b86:	83 e0 f0             	and    $0xfffffff0,%eax
f0105b89:	83 c8 0e             	or     $0xe,%eax
f0105b8c:	a2 fd 33 29 f0       	mov    %al,0xf02933fd
f0105b91:	0f b6 05 fd 33 29 f0 	movzbl 0xf02933fd,%eax
f0105b98:	83 e0 ef             	and    $0xffffffef,%eax
f0105b9b:	a2 fd 33 29 f0       	mov    %al,0xf02933fd
f0105ba0:	0f b6 05 fd 33 29 f0 	movzbl 0xf02933fd,%eax
f0105ba7:	83 e0 9f             	and    $0xffffff9f,%eax
f0105baa:	a2 fd 33 29 f0       	mov    %al,0xf02933fd
f0105baf:	0f b6 05 fd 33 29 f0 	movzbl 0xf02933fd,%eax
f0105bb6:	83 c8 80             	or     $0xffffff80,%eax
f0105bb9:	a2 fd 33 29 f0       	mov    %al,0xf02933fd
f0105bbe:	b8 0a 66 10 f0       	mov    $0xf010660a,%eax
f0105bc3:	c1 e8 10             	shr    $0x10,%eax
f0105bc6:	66 a3 fe 33 29 f0    	mov    %ax,0xf02933fe
	// Per-CPU setup 
	trap_init_percpu();
f0105bcc:	e8 02 00 00 00       	call   f0105bd3 <trap_init_percpu>
}
f0105bd1:	c9                   	leave  
f0105bd2:	c3                   	ret    

f0105bd3 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0105bd3:	55                   	push   %ebp
f0105bd4:	89 e5                	mov    %esp,%ebp
f0105bd6:	57                   	push   %edi
f0105bd7:	56                   	push   %esi
f0105bd8:	53                   	push   %ebx
f0105bd9:	83 ec 1c             	sub    $0x1c,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP)*thiscpu->cpu_id;
f0105bdc:	e8 91 36 00 00       	call   f0109272 <cpunum>
f0105be1:	89 c3                	mov    %eax,%ebx
f0105be3:	e8 8a 36 00 00       	call   f0109272 <cpunum>
f0105be8:	6b c0 74             	imul   $0x74,%eax,%eax
f0105beb:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105bf0:	0f b6 00             	movzbl (%eax),%eax
f0105bf3:	0f b6 d0             	movzbl %al,%edx
f0105bf6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bfb:	29 d0                	sub    %edx,%eax
f0105bfd:	c1 e0 10             	shl    $0x10,%eax
f0105c00:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0105c06:	6b c3 74             	imul   $0x74,%ebx,%eax
f0105c09:	05 30 70 29 f0       	add    $0xf0297030,%eax
f0105c0e:	89 10                	mov    %edx,(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0105c10:	e8 5d 36 00 00       	call   f0109272 <cpunum>
f0105c15:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c18:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105c1d:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0105c23:	e8 4a 36 00 00       	call   f0109272 <cpunum>
f0105c28:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c2b:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105c30:	0f b6 00             	movzbl (%eax),%eax
f0105c33:	0f b6 c0             	movzbl %al,%eax
f0105c36:	8d 58 05             	lea    0x5(%eax),%ebx
f0105c39:	e8 34 36 00 00       	call   f0109272 <cpunum>
f0105c3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c41:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105c46:	83 c0 0c             	add    $0xc,%eax
f0105c49:	89 c7                	mov    %eax,%edi
f0105c4b:	e8 22 36 00 00       	call   f0109272 <cpunum>
f0105c50:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c53:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105c58:	83 c0 0c             	add    $0xc,%eax
f0105c5b:	c1 e8 10             	shr    $0x10,%eax
f0105c5e:	89 c6                	mov    %eax,%esi
f0105c60:	e8 0d 36 00 00       	call   f0109272 <cpunum>
f0105c65:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c68:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105c6d:	83 c0 0c             	add    $0xc,%eax
f0105c70:	c1 e8 18             	shr    $0x18,%eax
f0105c73:	66 c7 04 dd 60 65 12 	movw   $0x67,-0xfed9aa0(,%ebx,8)
f0105c7a:	f0 67 00 
f0105c7d:	66 89 3c dd 62 65 12 	mov    %di,-0xfed9a9e(,%ebx,8)
f0105c84:	f0 
f0105c85:	89 f1                	mov    %esi,%ecx
f0105c87:	88 0c dd 64 65 12 f0 	mov    %cl,-0xfed9a9c(,%ebx,8)
f0105c8e:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105c95:	f0 
f0105c96:	83 e2 f0             	and    $0xfffffff0,%edx
f0105c99:	83 ca 09             	or     $0x9,%edx
f0105c9c:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105ca3:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105caa:	f0 
f0105cab:	83 ca 10             	or     $0x10,%edx
f0105cae:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105cb5:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105cbc:	f0 
f0105cbd:	83 e2 9f             	and    $0xffffff9f,%edx
f0105cc0:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105cc7:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105cce:	f0 
f0105ccf:	83 ca 80             	or     $0xffffff80,%edx
f0105cd2:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105cd9:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105ce0:	f0 
f0105ce1:	83 e2 f0             	and    $0xfffffff0,%edx
f0105ce4:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105ceb:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105cf2:	f0 
f0105cf3:	83 e2 ef             	and    $0xffffffef,%edx
f0105cf6:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105cfd:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d04:	f0 
f0105d05:	83 e2 df             	and    $0xffffffdf,%edx
f0105d08:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d0f:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d16:	f0 
f0105d17:	83 ca 40             	or     $0x40,%edx
f0105d1a:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d21:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d28:	f0 
f0105d29:	83 e2 7f             	and    $0x7f,%edx
f0105d2c:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d33:	88 04 dd 67 65 12 f0 	mov    %al,-0xfed9a99(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0105d3a:	e8 33 35 00 00       	call   f0109272 <cpunum>
f0105d3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d42:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105d47:	0f b6 00             	movzbl (%eax),%eax
f0105d4a:	0f b6 c0             	movzbl %al,%eax
f0105d4d:	83 c0 05             	add    $0x5,%eax
f0105d50:	0f b6 14 c5 65 65 12 	movzbl -0xfed9a9b(,%eax,8),%edx
f0105d57:	f0 
f0105d58:	83 e2 ef             	and    $0xffffffef,%edx
f0105d5b:	88 14 c5 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%eax,8)

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(((GD_TSS0 >> 3) + thiscpu->cpu_id) << 3);
f0105d62:	e8 0b 35 00 00       	call   f0109272 <cpunum>
f0105d67:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d6a:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0105d6f:	0f b6 00             	movzbl (%eax),%eax
f0105d72:	0f b6 c0             	movzbl %al,%eax
f0105d75:	83 c0 05             	add    $0x5,%eax
f0105d78:	c1 e0 03             	shl    $0x3,%eax
f0105d7b:	0f b7 c0             	movzwl %ax,%eax
f0105d7e:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0105d82:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
f0105d86:	0f 00 d8             	ltr    %ax
f0105d89:	c7 45 e0 d0 65 12 f0 	movl   $0xf01265d0,-0x20(%ebp)
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0105d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d93:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0105d96:	83 c4 1c             	add    $0x1c,%esp
f0105d99:	5b                   	pop    %ebx
f0105d9a:	5e                   	pop    %esi
f0105d9b:	5f                   	pop    %edi
f0105d9c:	5d                   	pop    %ebp
f0105d9d:	c3                   	ret    

f0105d9e <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f0105d9e:	55                   	push   %ebp
f0105d9f:	89 e5                	mov    %esp,%ebp
f0105da1:	83 ec 28             	sub    $0x28,%esp
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105da4:	e8 c9 34 00 00       	call   f0109272 <cpunum>
f0105da9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dad:	8b 45 08             	mov    0x8(%ebp),%eax
f0105db0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105db4:	c7 04 24 6e ab 10 f0 	movl   $0xf010ab6e,(%esp)
f0105dbb:	e8 8c f1 ff ff       	call   f0104f4c <cprintf>
	print_regs(&tf->tf_regs);
f0105dc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dc3:	89 04 24             	mov    %eax,(%esp)
f0105dc6:	e8 a5 01 00 00       	call   f0105f70 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0105dcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dce:	0f b7 40 20          	movzwl 0x20(%eax),%eax
f0105dd2:	0f b7 c0             	movzwl %ax,%eax
f0105dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dd9:	c7 04 24 8c ab 10 f0 	movl   $0xf010ab8c,(%esp)
f0105de0:	e8 67 f1 ff ff       	call   f0104f4c <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0105de5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105de8:	0f b7 40 24          	movzwl 0x24(%eax),%eax
f0105dec:	0f b7 c0             	movzwl %ax,%eax
f0105def:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105df3:	c7 04 24 9f ab 10 f0 	movl   $0xf010ab9f,(%esp)
f0105dfa:	e8 4d f1 ff ff       	call   f0104f4c <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0105dff:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e02:	8b 40 28             	mov    0x28(%eax),%eax
f0105e05:	89 04 24             	mov    %eax,(%esp)
f0105e08:	e8 93 f1 ff ff       	call   f0104fa0 <trapname>
f0105e0d:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e10:	8b 52 28             	mov    0x28(%edx),%edx
f0105e13:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e17:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e1b:	c7 04 24 b2 ab 10 f0 	movl   $0xf010abb2,(%esp)
f0105e22:	e8 25 f1 ff ff       	call   f0104f4c <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0105e27:	a1 c8 3a 29 f0       	mov    0xf0293ac8,%eax
f0105e2c:	39 45 08             	cmp    %eax,0x8(%ebp)
f0105e2f:	75 24                	jne    f0105e55 <print_trapframe+0xb7>
f0105e31:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e34:	8b 40 28             	mov    0x28(%eax),%eax
f0105e37:	83 f8 0e             	cmp    $0xe,%eax
f0105e3a:	75 19                	jne    f0105e55 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105e3c:	0f 20 d0             	mov    %cr2,%eax
f0105e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f0105e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0105e45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e49:	c7 04 24 c4 ab 10 f0 	movl   $0xf010abc4,(%esp)
f0105e50:	e8 f7 f0 ff ff       	call   f0104f4c <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0105e55:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e58:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105e5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e5f:	c7 04 24 d3 ab 10 f0 	movl   $0xf010abd3,(%esp)
f0105e66:	e8 e1 f0 ff ff       	call   f0104f4c <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0105e6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e6e:	8b 40 28             	mov    0x28(%eax),%eax
f0105e71:	83 f8 0e             	cmp    $0xe,%eax
f0105e74:	75 65                	jne    f0105edb <print_trapframe+0x13d>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0105e76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e79:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105e7c:	83 e0 01             	and    $0x1,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105e7f:	85 c0                	test   %eax,%eax
f0105e81:	74 07                	je     f0105e8a <print_trapframe+0xec>
f0105e83:	b9 e1 ab 10 f0       	mov    $0xf010abe1,%ecx
f0105e88:	eb 05                	jmp    f0105e8f <print_trapframe+0xf1>
f0105e8a:	b9 ec ab 10 f0       	mov    $0xf010abec,%ecx
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
f0105e8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e92:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105e95:	83 e0 02             	and    $0x2,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105e98:	85 c0                	test   %eax,%eax
f0105e9a:	74 07                	je     f0105ea3 <print_trapframe+0x105>
f0105e9c:	ba f8 ab 10 f0       	mov    $0xf010abf8,%edx
f0105ea1:	eb 05                	jmp    f0105ea8 <print_trapframe+0x10a>
f0105ea3:	ba fe ab 10 f0       	mov    $0xf010abfe,%edx
			tf->tf_err & 4 ? "user" : "kernel",
f0105ea8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eab:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105eae:	83 e0 04             	and    $0x4,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105eb1:	85 c0                	test   %eax,%eax
f0105eb3:	74 07                	je     f0105ebc <print_trapframe+0x11e>
f0105eb5:	b8 03 ac 10 f0       	mov    $0xf010ac03,%eax
f0105eba:	eb 05                	jmp    f0105ec1 <print_trapframe+0x123>
f0105ebc:	b8 08 ac 10 f0       	mov    $0xf010ac08,%eax
f0105ec1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105ec5:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ecd:	c7 04 24 0f ac 10 f0 	movl   $0xf010ac0f,(%esp)
f0105ed4:	e8 73 f0 ff ff       	call   f0104f4c <cprintf>
f0105ed9:	eb 0c                	jmp    f0105ee7 <print_trapframe+0x149>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0105edb:	c7 04 24 1e ac 10 f0 	movl   $0xf010ac1e,(%esp)
f0105ee2:	e8 65 f0 ff ff       	call   f0104f4c <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0105ee7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eea:	8b 40 30             	mov    0x30(%eax),%eax
f0105eed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ef1:	c7 04 24 20 ac 10 f0 	movl   $0xf010ac20,(%esp)
f0105ef8:	e8 4f f0 ff ff       	call   f0104f4c <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0105efd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f00:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105f04:	0f b7 c0             	movzwl %ax,%eax
f0105f07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f0b:	c7 04 24 2f ac 10 f0 	movl   $0xf010ac2f,(%esp)
f0105f12:	e8 35 f0 ff ff       	call   f0104f4c <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0105f17:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f1a:	8b 40 38             	mov    0x38(%eax),%eax
f0105f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f21:	c7 04 24 42 ac 10 f0 	movl   $0xf010ac42,(%esp)
f0105f28:	e8 1f f0 ff ff       	call   f0104f4c <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0105f2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f30:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105f34:	0f b7 c0             	movzwl %ax,%eax
f0105f37:	83 e0 03             	and    $0x3,%eax
f0105f3a:	85 c0                	test   %eax,%eax
f0105f3c:	74 30                	je     f0105f6e <print_trapframe+0x1d0>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0105f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f41:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105f44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f48:	c7 04 24 51 ac 10 f0 	movl   $0xf010ac51,(%esp)
f0105f4f:	e8 f8 ef ff ff       	call   f0104f4c <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0105f54:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f57:	0f b7 40 40          	movzwl 0x40(%eax),%eax
f0105f5b:	0f b7 c0             	movzwl %ax,%eax
f0105f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f62:	c7 04 24 60 ac 10 f0 	movl   $0xf010ac60,(%esp)
f0105f69:	e8 de ef ff ff       	call   f0104f4c <cprintf>
	}
}
f0105f6e:	c9                   	leave  
f0105f6f:	c3                   	ret    

f0105f70 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f0105f70:	55                   	push   %ebp
f0105f71:	89 e5                	mov    %esp,%ebp
f0105f73:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f79:	8b 00                	mov    (%eax),%eax
f0105f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f7f:	c7 04 24 73 ac 10 f0 	movl   $0xf010ac73,(%esp)
f0105f86:	e8 c1 ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0105f8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f8e:	8b 40 04             	mov    0x4(%eax),%eax
f0105f91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f95:	c7 04 24 82 ac 10 f0 	movl   $0xf010ac82,(%esp)
f0105f9c:	e8 ab ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0105fa1:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa4:	8b 40 08             	mov    0x8(%eax),%eax
f0105fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fab:	c7 04 24 91 ac 10 f0 	movl   $0xf010ac91,(%esp)
f0105fb2:	e8 95 ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0105fb7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fba:	8b 40 0c             	mov    0xc(%eax),%eax
f0105fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc1:	c7 04 24 a0 ac 10 f0 	movl   $0xf010aca0,(%esp)
f0105fc8:	e8 7f ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0105fcd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fd0:	8b 40 10             	mov    0x10(%eax),%eax
f0105fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fd7:	c7 04 24 af ac 10 f0 	movl   $0xf010acaf,(%esp)
f0105fde:	e8 69 ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0105fe3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fe6:	8b 40 14             	mov    0x14(%eax),%eax
f0105fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fed:	c7 04 24 be ac 10 f0 	movl   $0xf010acbe,(%esp)
f0105ff4:	e8 53 ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0105ff9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ffc:	8b 40 18             	mov    0x18(%eax),%eax
f0105fff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106003:	c7 04 24 cd ac 10 f0 	movl   $0xf010accd,(%esp)
f010600a:	e8 3d ef ff ff       	call   f0104f4c <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010600f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106012:	8b 40 1c             	mov    0x1c(%eax),%eax
f0106015:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106019:	c7 04 24 dc ac 10 f0 	movl   $0xf010acdc,(%esp)
f0106020:	e8 27 ef ff ff       	call   f0104f4c <cprintf>
}
f0106025:	c9                   	leave  
f0106026:	c3                   	ret    

f0106027 <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f0106027:	55                   	push   %ebp
f0106028:	89 e5                	mov    %esp,%ebp
f010602a:	57                   	push   %edi
f010602b:	56                   	push   %esi
f010602c:	53                   	push   %ebx
f010602d:	83 ec 3c             	sub    $0x3c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0106030:	8b 45 08             	mov    0x8(%ebp),%eax
f0106033:	8b 40 28             	mov    0x28(%eax),%eax
f0106036:	83 f8 27             	cmp    $0x27,%eax
f0106039:	75 1c                	jne    f0106057 <trap_dispatch+0x30>
		cprintf("Spurious interrupt on irq 7\n");
f010603b:	c7 04 24 eb ac 10 f0 	movl   $0xf010aceb,(%esp)
f0106042:	e8 05 ef ff ff       	call   f0104f4c <cprintf>
		print_trapframe(tf);
f0106047:	8b 45 08             	mov    0x8(%ebp),%eax
f010604a:	89 04 24             	mov    %eax,(%esp)
f010604d:	e8 4c fd ff ff       	call   f0105d9e <print_trapframe>
		return;
f0106052:	e9 85 01 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	struct PushRegs *regs = &(tf->tf_regs);
f0106057:	8b 45 08             	mov    0x8(%ebp),%eax
f010605a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t ret_sys;
	switch(tf->tf_trapno){
f010605d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106060:	8b 40 28             	mov    0x28(%eax),%eax
f0106063:	83 f8 30             	cmp    $0x30,%eax
f0106066:	0f 87 24 01 00 00    	ja     f0106190 <trap_dispatch+0x169>
f010606c:	8b 04 85 30 ad 10 f0 	mov    -0xfef52d0(,%eax,4),%eax
f0106073:	ff e0                	jmp    *%eax
		case T_PGFLT:
			if(curenv->env_type != ENV_TYPE_GUEST)
f0106075:	e8 f8 31 00 00       	call   f0109272 <cpunum>
f010607a:	6b c0 74             	imul   $0x74,%eax,%eax
f010607d:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106082:	8b 00                	mov    (%eax),%eax
f0106084:	8b 40 50             	mov    0x50(%eax),%eax
f0106087:	83 f8 01             	cmp    $0x1,%eax
f010608a:	74 10                	je     f010609c <trap_dispatch+0x75>
				page_fault_handler(tf);
f010608c:	8b 45 08             	mov    0x8(%ebp),%eax
f010608f:	89 04 24             	mov    %eax,(%esp)
f0106092:	e8 e4 02 00 00       	call   f010637b <page_fault_handler>
			break;
f0106097:	e9 40 01 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>
f010609c:	e9 3b 01 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>
		case T_BRKPT:
			if(curenv->env_type != ENV_TYPE_GUEST)
f01060a1:	e8 cc 31 00 00       	call   f0109272 <cpunum>
f01060a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01060a9:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01060ae:	8b 00                	mov    (%eax),%eax
f01060b0:	8b 40 50             	mov    0x50(%eax),%eax
f01060b3:	83 f8 01             	cmp    $0x1,%eax
f01060b6:	74 10                	je     f01060c8 <trap_dispatch+0xa1>
				monitor(tf);
f01060b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01060bb:	89 04 24             	mov    %eax,(%esp)
f01060be:	e8 89 b0 ff ff       	call   f010114c <monitor>
			break;
f01060c3:	e9 14 01 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>
f01060c8:	e9 0f 01 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>
		case T_DEBUG:
			if(curenv->env_type != ENV_TYPE_GUEST)
f01060cd:	e8 a0 31 00 00       	call   f0109272 <cpunum>
f01060d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d5:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01060da:	8b 00                	mov    (%eax),%eax
f01060dc:	8b 40 50             	mov    0x50(%eax),%eax
f01060df:	83 f8 01             	cmp    $0x1,%eax
f01060e2:	74 10                	je     f01060f4 <trap_dispatch+0xcd>
				monitor(tf);
f01060e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01060e7:	89 04 24             	mov    %eax,(%esp)
f01060ea:	e8 5d b0 ff ff       	call   f010114c <monitor>
			break;
f01060ef:	e9 e8 00 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>
f01060f4:	e9 e3 00 00 00       	jmp    f01061dc <trap_dispatch+0x1b5>
		case T_SYSCALL:
			if(curenv->env_type != ENV_TYPE_GUEST){
f01060f9:	e8 74 31 00 00       	call   f0109272 <cpunum>
f01060fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0106101:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106106:	8b 00                	mov    (%eax),%eax
f0106108:	8b 40 50             	mov    0x50(%eax),%eax
f010610b:	83 f8 01             	cmp    $0x1,%eax
f010610e:	74 4d                	je     f010615d <trap_dispatch+0x136>
				ret_sys = syscall(regs->reg_eax, regs->reg_edx, regs->reg_ecx, regs->reg_ebx, regs->reg_edi, regs->reg_esi);
f0106110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106113:	8b 78 04             	mov    0x4(%eax),%edi
f0106116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106119:	8b 30                	mov    (%eax),%esi
f010611b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010611e:	8b 58 10             	mov    0x10(%eax),%ebx
f0106121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106124:	8b 48 18             	mov    0x18(%eax),%ecx
f0106127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010612a:	8b 50 14             	mov    0x14(%eax),%edx
f010612d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106130:	8b 40 1c             	mov    0x1c(%eax),%eax
f0106133:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106137:	89 74 24 10          	mov    %esi,0x10(%esp)
f010613b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010613f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106143:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106147:	89 04 24             	mov    %eax,(%esp)
f010614a:	e8 d2 15 00 00       	call   f0107721 <syscall>
f010614f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				regs->reg_eax = ret_sys;
f0106152:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106155:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106158:	89 50 1c             	mov    %edx,0x1c(%eax)
			}
			break;
f010615b:	eb 7f                	jmp    f01061dc <trap_dispatch+0x1b5>
f010615d:	eb 7d                	jmp    f01061dc <trap_dispatch+0x1b5>
		case IRQ_OFFSET+IRQ_TIMER:
			if(curenv->env_type != ENV_TYPE_GUEST){
f010615f:	e8 0e 31 00 00       	call   f0109272 <cpunum>
f0106164:	6b c0 74             	imul   $0x74,%eax,%eax
f0106167:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010616c:	8b 00                	mov    (%eax),%eax
f010616e:	8b 40 50             	mov    0x50(%eax),%eax
f0106171:	83 f8 01             	cmp    $0x1,%eax
f0106174:	74 0a                	je     f0106180 <trap_dispatch+0x159>
				lapic_eoi();
f0106176:	e8 19 31 00 00       	call   f0109294 <lapic_eoi>
				sched_yield();
f010617b:	e8 0d 05 00 00       	call   f010668d <sched_yield>
			}
			break;
f0106180:	eb 5a                	jmp    f01061dc <trap_dispatch+0x1b5>
		case IRQ_OFFSET+IRQ_KBD:
			kbd_intr();
f0106182:	e8 ad a8 ff ff       	call   f0100a34 <kbd_intr>
			break;
f0106187:	eb 53                	jmp    f01061dc <trap_dispatch+0x1b5>
		case IRQ_OFFSET+IRQ_SERIAL:
			serial_intr();
f0106189:	e8 83 a2 ff ff       	call   f0100411 <serial_intr>
			break;
f010618e:	eb 4c                	jmp    f01061dc <trap_dispatch+0x1b5>
		default:
			print_trapframe(tf);
f0106190:	8b 45 08             	mov    0x8(%ebp),%eax
f0106193:	89 04 24             	mov    %eax,(%esp)
f0106196:	e8 03 fc ff ff       	call   f0105d9e <print_trapframe>
			if (tf->tf_cs == GD_KT)
f010619b:	8b 45 08             	mov    0x8(%ebp),%eax
f010619e:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f01061a2:	66 83 f8 08          	cmp    $0x8,%ax
f01061a6:	75 1c                	jne    f01061c4 <trap_dispatch+0x19d>
				panic("unhandled trap in kernel");
f01061a8:	c7 44 24 08 08 ad 10 	movl   $0xf010ad08,0x8(%esp)
f01061af:	f0 
f01061b0:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f01061b7:	00 
f01061b8:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f01061bf:	e8 0b a1 ff ff       	call   f01002cf <_panic>
			else {
				env_destroy(curenv);
f01061c4:	e8 a9 30 00 00       	call   f0109272 <cpunum>
f01061c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01061cc:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01061d1:	8b 00                	mov    (%eax),%eax
f01061d3:	89 04 24             	mov    %eax,(%esp)
f01061d6:	e8 0a e9 ff ff       	call   f0104ae5 <env_destroy>
				return;
f01061db:	90                   	nop
			}
	}
	// Unexpected trap: The user process or the kernel has a bug.
}
f01061dc:	83 c4 3c             	add    $0x3c,%esp
f01061df:	5b                   	pop    %ebx
f01061e0:	5e                   	pop    %esi
f01061e1:	5f                   	pop    %edi
f01061e2:	5d                   	pop    %ebp
f01061e3:	c3                   	ret    

f01061e4 <trap>:

void
trap(struct Trapframe *tf)
{
f01061e4:	55                   	push   %ebp
f01061e5:	89 e5                	mov    %esp,%ebp
f01061e7:	57                   	push   %edi
f01061e8:	56                   	push   %esi
f01061e9:	53                   	push   %ebx
f01061ea:	83 ec 2c             	sub    $0x2c,%esp
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01061ed:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01061ee:	a1 e0 6a 29 f0       	mov    0xf0296ae0,%eax
f01061f3:	85 c0                	test   %eax,%eax
f01061f5:	74 01                	je     f01061f8 <trap+0x14>
		asm volatile("hlt");
f01061f7:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01061f8:	e8 75 30 00 00       	call   f0109272 <cpunum>
f01061fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0106200:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0106205:	83 c0 04             	add    $0x4,%eax
f0106208:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010620f:	00 
f0106210:	89 04 24             	mov    %eax,(%esp)
f0106213:	e8 5a ed ff ff       	call   f0104f72 <xchg>
f0106218:	83 f8 02             	cmp    $0x2,%eax
f010621b:	75 05                	jne    f0106222 <trap+0x3e>
		lock_kernel();
f010621d:	e8 6a ed ff ff       	call   f0104f8c <lock_kernel>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0106222:	9c                   	pushf  
f0106223:	58                   	pop    %eax
f0106224:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	return eflags;
f0106227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010622a:	25 00 02 00 00       	and    $0x200,%eax
f010622f:	85 c0                	test   %eax,%eax
f0106231:	74 24                	je     f0106257 <trap+0x73>
f0106233:	c7 44 24 0c f4 ad 10 	movl   $0xf010adf4,0xc(%esp)
f010623a:	f0 
f010623b:	c7 44 24 08 0d ae 10 	movl   $0xf010ae0d,0x8(%esp)
f0106242:	f0 
f0106243:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f010624a:	00 
f010624b:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f0106252:	e8 78 a0 ff ff       	call   f01002cf <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0106257:	8b 45 08             	mov    0x8(%ebp),%eax
f010625a:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f010625e:	0f b7 c0             	movzwl %ax,%eax
f0106261:	83 e0 03             	and    $0x3,%eax
f0106264:	83 f8 03             	cmp    $0x3,%eax
f0106267:	0f 85 b5 00 00 00    	jne    f0106322 <trap+0x13e>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
f010626d:	e8 1a ed ff ff       	call   f0104f8c <lock_kernel>
		assert(curenv);
f0106272:	e8 fb 2f 00 00       	call   f0109272 <cpunum>
f0106277:	6b c0 74             	imul   $0x74,%eax,%eax
f010627a:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010627f:	8b 00                	mov    (%eax),%eax
f0106281:	85 c0                	test   %eax,%eax
f0106283:	75 24                	jne    f01062a9 <trap+0xc5>
f0106285:	c7 44 24 0c 22 ae 10 	movl   $0xf010ae22,0xc(%esp)
f010628c:	f0 
f010628d:	c7 44 24 08 0d ae 10 	movl   $0xf010ae0d,0x8(%esp)
f0106294:	f0 
f0106295:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f010629c:	00 
f010629d:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f01062a4:	e8 26 a0 ff ff       	call   f01002cf <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01062a9:	e8 c4 2f 00 00       	call   f0109272 <cpunum>
f01062ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01062b1:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01062b6:	8b 00                	mov    (%eax),%eax
f01062b8:	8b 40 54             	mov    0x54(%eax),%eax
f01062bb:	83 f8 01             	cmp    $0x1,%eax
f01062be:	75 2f                	jne    f01062ef <trap+0x10b>
			env_free(curenv);
f01062c0:	e8 ad 2f 00 00       	call   f0109272 <cpunum>
f01062c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01062c8:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01062cd:	8b 00                	mov    (%eax),%eax
f01062cf:	89 04 24             	mov    %eax,(%esp)
f01062d2:	e8 88 e6 ff ff       	call   f010495f <env_free>
			curenv = NULL;
f01062d7:	e8 96 2f 00 00       	call   f0109272 <cpunum>
f01062dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01062df:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01062e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			sched_yield();
f01062ea:	e8 9e 03 00 00       	call   f010668d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01062ef:	e8 7e 2f 00 00       	call   f0109272 <cpunum>
f01062f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01062f7:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01062fc:	8b 10                	mov    (%eax),%edx
f01062fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0106301:	89 c3                	mov    %eax,%ebx
f0106303:	b8 11 00 00 00       	mov    $0x11,%eax
f0106308:	89 d7                	mov    %edx,%edi
f010630a:	89 de                	mov    %ebx,%esi
f010630c:	89 c1                	mov    %eax,%ecx
f010630e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0106310:	e8 5d 2f 00 00       	call   f0109272 <cpunum>
f0106315:	6b c0 74             	imul   $0x74,%eax,%eax
f0106318:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010631d:	8b 00                	mov    (%eax),%eax
f010631f:	89 45 08             	mov    %eax,0x8(%ebp)
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0106322:	8b 45 08             	mov    0x8(%ebp),%eax
f0106325:	a3 c8 3a 29 f0       	mov    %eax,0xf0293ac8

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f010632a:	8b 45 08             	mov    0x8(%ebp),%eax
f010632d:	89 04 24             	mov    %eax,(%esp)
f0106330:	e8 f2 fc ff ff       	call   f0106027 <trap_dispatch>

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0106335:	e8 38 2f 00 00       	call   f0109272 <cpunum>
f010633a:	6b c0 74             	imul   $0x74,%eax,%eax
f010633d:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106342:	8b 00                	mov    (%eax),%eax
f0106344:	85 c0                	test   %eax,%eax
f0106346:	74 2e                	je     f0106376 <trap+0x192>
f0106348:	e8 25 2f 00 00       	call   f0109272 <cpunum>
f010634d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106350:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106355:	8b 00                	mov    (%eax),%eax
f0106357:	8b 40 54             	mov    0x54(%eax),%eax
f010635a:	83 f8 03             	cmp    $0x3,%eax
f010635d:	75 17                	jne    f0106376 <trap+0x192>
		env_run(curenv);
f010635f:	e8 0e 2f 00 00       	call   f0109272 <cpunum>
f0106364:	6b c0 74             	imul   $0x74,%eax,%eax
f0106367:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010636c:	8b 00                	mov    (%eax),%eax
f010636e:	89 04 24             	mov    %eax,(%esp)
f0106371:	e8 4f e8 ff ff       	call   f0104bc5 <env_run>
	else
		sched_yield();
f0106376:	e8 12 03 00 00       	call   f010668d <sched_yield>

f010637b <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010637b:	55                   	push   %ebp
f010637c:	89 e5                	mov    %esp,%ebp
f010637e:	53                   	push   %ebx
f010637f:	83 ec 24             	sub    $0x24,%esp

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0106382:	0f 20 d0             	mov    %cr2,%eax
f0106385:	89 45 e8             	mov    %eax,-0x18(%ebp)
	return val;
f0106388:	8b 45 e8             	mov    -0x18(%ebp),%eax
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f010638b:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010638e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106391:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0106395:	66 83 f8 08          	cmp    $0x8,%ax
f0106399:	75 1c                	jne    f01063b7 <page_fault_handler+0x3c>
		panic("page fault in kernel");
f010639b:	c7 44 24 08 29 ae 10 	movl   $0xf010ae29,0x8(%esp)
f01063a2:	f0 
f01063a3:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f01063aa:	00 
f01063ab:	c7 04 24 21 ad 10 f0 	movl   $0xf010ad21,(%esp)
f01063b2:	e8 18 9f ff ff       	call   f01002cf <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall == NULL || tf->tf_esp > UXSTACKTOP || (tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE))){
f01063b7:	e8 b6 2e 00 00       	call   f0109272 <cpunum>
f01063bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01063bf:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01063c4:	8b 00                	mov    (%eax),%eax
f01063c6:	8b 40 64             	mov    0x64(%eax),%eax
f01063c9:	85 c0                	test   %eax,%eax
f01063cb:	74 27                	je     f01063f4 <page_fault_handler+0x79>
f01063cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01063d0:	8b 40 3c             	mov    0x3c(%eax),%eax
f01063d3:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f01063d8:	77 1a                	ja     f01063f4 <page_fault_handler+0x79>
f01063da:	8b 45 08             	mov    0x8(%ebp),%eax
f01063dd:	8b 40 3c             	mov    0x3c(%eax),%eax
f01063e0:	3d 00 e0 bf ee       	cmp    $0xeebfe000,%eax
f01063e5:	76 67                	jbe    f010644e <page_fault_handler+0xd3>
f01063e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01063ea:	8b 40 3c             	mov    0x3c(%eax),%eax
f01063ed:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f01063f2:	77 5a                	ja     f010644e <page_fault_handler+0xd3>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01063f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01063f7:	8b 58 30             	mov    0x30(%eax),%ebx
			curenv->env_id, fault_va, tf->tf_eip);
f01063fa:	e8 73 2e 00 00       	call   f0109272 <cpunum>
f01063ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0106402:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106407:	8b 00                	mov    (%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall == NULL || tf->tf_esp > UXSTACKTOP || (tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE))){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0106409:	8b 40 48             	mov    0x48(%eax),%eax
f010640c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106410:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106413:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106417:	89 44 24 04          	mov    %eax,0x4(%esp)
f010641b:	c7 04 24 40 ae 10 f0 	movl   $0xf010ae40,(%esp)
f0106422:	e8 25 eb ff ff       	call   f0104f4c <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0106427:	8b 45 08             	mov    0x8(%ebp),%eax
f010642a:	89 04 24             	mov    %eax,(%esp)
f010642d:	e8 6c f9 ff ff       	call   f0105d9e <print_trapframe>
		env_destroy(curenv);
f0106432:	e8 3b 2e 00 00       	call   f0109272 <cpunum>
f0106437:	6b c0 74             	imul   $0x74,%eax,%eax
f010643a:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010643f:	8b 00                	mov    (%eax),%eax
f0106441:	89 04 24             	mov    %eax,(%esp)
f0106444:	e8 9c e6 ff ff       	call   f0104ae5 <env_destroy>
f0106449:	e9 3a 01 00 00       	jmp    f0106588 <page_fault_handler+0x20d>
	}
	else{
		// cprintf("user fault\n");
		uint32_t ex_stack_top;
		if(tf->tf_esp < USTACKTOP) ex_stack_top = UXSTACKTOP - sizeof(struct UTrapframe);		//switch from user stack to user exception stack
f010644e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106451:	8b 40 3c             	mov    0x3c(%eax),%eax
f0106454:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f0106459:	77 09                	ja     f0106464 <page_fault_handler+0xe9>
f010645b:	c7 45 f4 cc ff bf ee 	movl   $0xeebfffcc,-0xc(%ebp)
f0106462:	eb 0c                	jmp    f0106470 <page_fault_handler+0xf5>
		else ex_stack_top = tf->tf_esp - sizeof(struct UTrapframe) - 4;		//recursive pagefault
f0106464:	8b 45 08             	mov    0x8(%ebp),%eax
f0106467:	8b 40 3c             	mov    0x3c(%eax),%eax
f010646a:	83 e8 38             	sub    $0x38,%eax
f010646d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		user_mem_assert(curenv, (void *)ex_stack_top, sizeof(struct UTrapframe), PTE_U | PTE_P | PTE_W);
f0106470:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106473:	e8 fa 2d 00 00       	call   f0109272 <cpunum>
f0106478:	6b c0 74             	imul   $0x74,%eax,%eax
f010647b:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106480:	8b 00                	mov    (%eax),%eax
f0106482:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0106489:	00 
f010648a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0106491:	00 
f0106492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106496:	89 04 24             	mov    %eax,(%esp)
f0106499:	e8 53 b9 ff ff       	call   f0101df1 <user_mem_assert>
		user_mem_assert(curenv, curenv->env_pgfault_upcall, PGSIZE, PTE_U | PTE_P);
f010649e:	e8 cf 2d 00 00       	call   f0109272 <cpunum>
f01064a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01064a6:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01064ab:	8b 00                	mov    (%eax),%eax
f01064ad:	8b 58 64             	mov    0x64(%eax),%ebx
f01064b0:	e8 bd 2d 00 00       	call   f0109272 <cpunum>
f01064b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01064b8:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01064bd:	8b 00                	mov    (%eax),%eax
f01064bf:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01064c6:	00 
f01064c7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01064ce:	00 
f01064cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01064d3:	89 04 24             	mov    %eax,(%esp)
f01064d6:	e8 16 b9 ff ff       	call   f0101df1 <user_mem_assert>
		struct UTrapframe *utf = (struct UTrapframe *)ex_stack_top;
f01064db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01064de:	89 45 ec             	mov    %eax,-0x14(%ebp)
		utf->utf_fault_va = fault_va;
f01064e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01064e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01064e7:	89 10                	mov    %edx,(%eax)
		utf->utf_err = tf->tf_err;
f01064e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01064ec:	8b 50 2c             	mov    0x2c(%eax),%edx
f01064ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01064f2:	89 50 04             	mov    %edx,0x4(%eax)
		utf->utf_regs = tf->tf_regs;
f01064f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01064f8:	8b 55 08             	mov    0x8(%ebp),%edx
f01064fb:	8b 0a                	mov    (%edx),%ecx
f01064fd:	89 48 08             	mov    %ecx,0x8(%eax)
f0106500:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106503:	89 48 0c             	mov    %ecx,0xc(%eax)
f0106506:	8b 4a 08             	mov    0x8(%edx),%ecx
f0106509:	89 48 10             	mov    %ecx,0x10(%eax)
f010650c:	8b 4a 0c             	mov    0xc(%edx),%ecx
f010650f:	89 48 14             	mov    %ecx,0x14(%eax)
f0106512:	8b 4a 10             	mov    0x10(%edx),%ecx
f0106515:	89 48 18             	mov    %ecx,0x18(%eax)
f0106518:	8b 4a 14             	mov    0x14(%edx),%ecx
f010651b:	89 48 1c             	mov    %ecx,0x1c(%eax)
f010651e:	8b 4a 18             	mov    0x18(%edx),%ecx
f0106521:	89 48 20             	mov    %ecx,0x20(%eax)
f0106524:	8b 52 1c             	mov    0x1c(%edx),%edx
f0106527:	89 50 24             	mov    %edx,0x24(%eax)
		utf->utf_eip = tf->tf_eip;
f010652a:	8b 45 08             	mov    0x8(%ebp),%eax
f010652d:	8b 50 30             	mov    0x30(%eax),%edx
f0106530:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106533:	89 50 28             	mov    %edx,0x28(%eax)
		utf->utf_eflags = tf->tf_eflags;
f0106536:	8b 45 08             	mov    0x8(%ebp),%eax
f0106539:	8b 50 38             	mov    0x38(%eax),%edx
f010653c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010653f:	89 50 2c             	mov    %edx,0x2c(%eax)
		utf->utf_esp = tf->tf_esp;
f0106542:	8b 45 08             	mov    0x8(%ebp),%eax
f0106545:	8b 50 3c             	mov    0x3c(%eax),%edx
f0106548:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010654b:	89 50 30             	mov    %edx,0x30(%eax)

		tf->tf_esp = (uintptr_t)ex_stack_top;
f010654e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106551:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106554:	89 50 3c             	mov    %edx,0x3c(%eax)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0106557:	e8 16 2d 00 00       	call   f0109272 <cpunum>
f010655c:	6b c0 74             	imul   $0x74,%eax,%eax
f010655f:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106564:	8b 00                	mov    (%eax),%eax
f0106566:	8b 40 64             	mov    0x64(%eax),%eax
f0106569:	89 c2                	mov    %eax,%edx
f010656b:	8b 45 08             	mov    0x8(%ebp),%eax
f010656e:	89 50 30             	mov    %edx,0x30(%eax)
		env_run(curenv);	
f0106571:	e8 fc 2c 00 00       	call   f0109272 <cpunum>
f0106576:	6b c0 74             	imul   $0x74,%eax,%eax
f0106579:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010657e:	8b 00                	mov    (%eax),%eax
f0106580:	89 04 24             	mov    %eax,(%esp)
f0106583:	e8 3d e6 ff ff       	call   f0104bc5 <env_run>
	}
}
f0106588:	83 c4 24             	add    $0x24,%esp
f010658b:	5b                   	pop    %ebx
f010658c:	5d                   	pop    %ebp
f010658d:	c3                   	ret    

f010658e <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.text
TRAPHANDLER_NOEC(t_divide , T_DIVIDE)
f010658e:	6a 00                	push   $0x0
f0106590:	6a 00                	push   $0x0
f0106592:	eb 7c                	jmp    f0106610 <_alltraps>

f0106594 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0106594:	6a 00                	push   $0x0
f0106596:	6a 01                	push   $0x1
f0106598:	eb 76                	jmp    f0106610 <_alltraps>

f010659a <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f010659a:	6a 00                	push   $0x0
f010659c:	6a 02                	push   $0x2
f010659e:	eb 70                	jmp    f0106610 <_alltraps>

f01065a0 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01065a0:	6a 00                	push   $0x0
f01065a2:	6a 03                	push   $0x3
f01065a4:	eb 6a                	jmp    f0106610 <_alltraps>

f01065a6 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01065a6:	6a 00                	push   $0x0
f01065a8:	6a 05                	push   $0x5
f01065aa:	eb 64                	jmp    f0106610 <_alltraps>

f01065ac <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01065ac:	6a 00                	push   $0x0
f01065ae:	6a 06                	push   $0x6
f01065b0:	eb 5e                	jmp    f0106610 <_alltraps>

f01065b2 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01065b2:	6a 00                	push   $0x0
f01065b4:	6a 07                	push   $0x7
f01065b6:	eb 58                	jmp    f0106610 <_alltraps>

f01065b8 <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT)
f01065b8:	6a 08                	push   $0x8
f01065ba:	eb 54                	jmp    f0106610 <_alltraps>

f01065bc <t_tss>:

TRAPHANDLER(t_tss, T_TSS)
f01065bc:	6a 0a                	push   $0xa
f01065be:	eb 50                	jmp    f0106610 <_alltraps>

f01065c0 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01065c0:	6a 0b                	push   $0xb
f01065c2:	eb 4c                	jmp    f0106610 <_alltraps>

f01065c4 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01065c4:	6a 0c                	push   $0xc
f01065c6:	eb 48                	jmp    f0106610 <_alltraps>

f01065c8 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01065c8:	6a 0d                	push   $0xd
f01065ca:	eb 44                	jmp    f0106610 <_alltraps>

f01065cc <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01065cc:	6a 0e                	push   $0xe
f01065ce:	eb 40                	jmp    f0106610 <_alltraps>

f01065d0 <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01065d0:	6a 00                	push   $0x0
f01065d2:	6a 10                	push   $0x10
f01065d4:	eb 3a                	jmp    f0106610 <_alltraps>

f01065d6 <t_align>:

TRAPHANDLER(t_align, T_ALIGN)
f01065d6:	6a 11                	push   $0x11
f01065d8:	eb 36                	jmp    f0106610 <_alltraps>

f01065da <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01065da:	6a 00                	push   $0x0
f01065dc:	6a 12                	push   $0x12
f01065de:	eb 30                	jmp    f0106610 <_alltraps>

f01065e0 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01065e0:	6a 00                	push   $0x0
f01065e2:	6a 13                	push   $0x13
f01065e4:	eb 2a                	jmp    f0106610 <_alltraps>

f01065e6 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01065e6:	6a 00                	push   $0x0
f01065e8:	6a 30                	push   $0x30
f01065ea:	eb 24                	jmp    f0106610 <_alltraps>

f01065ec <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET + IRQ_TIMER)
f01065ec:	6a 00                	push   $0x0
f01065ee:	6a 20                	push   $0x20
f01065f0:	eb 1e                	jmp    f0106610 <_alltraps>

f01065f2 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET + IRQ_KBD)
f01065f2:	6a 00                	push   $0x0
f01065f4:	6a 21                	push   $0x21
f01065f6:	eb 18                	jmp    f0106610 <_alltraps>

f01065f8 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET + IRQ_SERIAL)
f01065f8:	6a 00                	push   $0x0
f01065fa:	6a 24                	push   $0x24
f01065fc:	eb 12                	jmp    f0106610 <_alltraps>

f01065fe <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f01065fe:	6a 00                	push   $0x0
f0106600:	6a 27                	push   $0x27
f0106602:	eb 0c                	jmp    f0106610 <_alltraps>

f0106604 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET + IRQ_IDE)
f0106604:	6a 00                	push   $0x0
f0106606:	6a 2e                	push   $0x2e
f0106608:	eb 06                	jmp    f0106610 <_alltraps>

f010660a <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET + IRQ_ERROR)
f010660a:	6a 00                	push   $0x0
f010660c:	6a 33                	push   $0x33
f010660e:	eb 00                	jmp    f0106610 <_alltraps>

f0106610 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 

_alltraps:
	push %ds
f0106610:	1e                   	push   %ds
	push %es
f0106611:	06                   	push   %es
	pushal
f0106612:	60                   	pusha  
	movl $(GD_KD), %eax
f0106613:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f0106618:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f010661a:	8e c0                	mov    %eax,%es
	pushl %esp
f010661c:	54                   	push   %esp
	call trap
f010661d:	e8 c2 fb ff ff       	call   f01061e4 <trap>

f0106622 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0106622:	55                   	push   %ebp
f0106623:	89 e5                	mov    %esp,%ebp
f0106625:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106628:	8b 55 08             	mov    0x8(%ebp),%edx
f010662b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010662e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106631:	f0 87 02             	lock xchg %eax,(%edx)
f0106634:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0106637:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010663a:	c9                   	leave  
f010663b:	c3                   	ret    

f010663c <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010663c:	55                   	push   %ebp
f010663d:	89 e5                	mov    %esp,%ebp
f010663f:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f0106642:	c7 04 24 e0 65 12 f0 	movl   $0xf01265e0,(%esp)
f0106649:	e8 27 2f 00 00       	call   f0109575 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010664e:	f3 90                	pause  
}
f0106650:	c9                   	leave  
f0106651:	c3                   	ret    

f0106652 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0106652:	55                   	push   %ebp
f0106653:	89 e5                	mov    %esp,%ebp
f0106655:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f0106658:	8b 45 10             	mov    0x10(%ebp),%eax
f010665b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0106660:	77 21                	ja     f0106683 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106662:	8b 45 10             	mov    0x10(%ebp),%eax
f0106665:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106669:	c7 44 24 08 10 b0 10 	movl   $0xf010b010,0x8(%esp)
f0106670:	f0 
f0106671:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106674:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106678:	8b 45 08             	mov    0x8(%ebp),%eax
f010667b:	89 04 24             	mov    %eax,(%esp)
f010667e:	e8 4c 9c ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106683:	8b 45 10             	mov    0x10(%ebp),%eax
f0106686:	05 00 00 00 10       	add    $0x10000000,%eax
}
f010668b:	c9                   	leave  
f010668c:	c3                   	ret    

f010668d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010668d:	55                   	push   %ebp
f010668e:	89 e5                	mov    %esp,%ebp
f0106690:	83 ec 28             	sub    $0x28,%esp

	// LAB 4: Your code here.

	int cur_id;
 	int i;
 	bool no_runnable=true;
f0106693:	c6 45 ef 01          	movb   $0x1,-0x11(%ebp)
	if(!thiscpu->cpu_env) cur_id = 0;
f0106697:	e8 d6 2b 00 00       	call   f0109272 <cpunum>
f010669c:	6b c0 74             	imul   $0x74,%eax,%eax
f010669f:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01066a4:	8b 00                	mov    (%eax),%eax
f01066a6:	85 c0                	test   %eax,%eax
f01066a8:	75 0c                	jne    f01066b6 <sched_yield+0x29>
f01066aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01066b1:	e9 81 00 00 00       	jmp    f0106737 <sched_yield+0xaa>
	else if(thiscpu->cpu_env->env_status == ENV_RUNNING){
f01066b6:	e8 b7 2b 00 00       	call   f0109272 <cpunum>
f01066bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01066be:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01066c3:	8b 00                	mov    (%eax),%eax
f01066c5:	8b 40 54             	mov    0x54(%eax),%eax
f01066c8:	83 f8 03             	cmp    $0x3,%eax
f01066cb:	75 41                	jne    f010670e <sched_yield+0x81>
		thiscpu->cpu_env->env_status = ENV_RUNNABLE;
f01066cd:	e8 a0 2b 00 00       	call   f0109272 <cpunum>
f01066d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01066d5:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01066da:	8b 00                	mov    (%eax),%eax
f01066dc:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		cur_id = thiscpu->cpu_env - envs+1;
f01066e3:	e8 8a 2b 00 00       	call   f0109272 <cpunum>
f01066e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01066eb:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01066f0:	8b 00                	mov    (%eax),%eax
f01066f2:	89 c2                	mov    %eax,%edx
f01066f4:	a1 3c 32 29 f0       	mov    0xf029323c,%eax
f01066f9:	29 c2                	sub    %eax,%edx
f01066fb:	89 d0                	mov    %edx,%eax
f01066fd:	c1 f8 02             	sar    $0x2,%eax
f0106700:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0106706:	83 c0 01             	add    $0x1,%eax
f0106709:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010670c:	eb 29                	jmp    f0106737 <sched_yield+0xaa>
	}
	else{
		cur_id = thiscpu->cpu_env - envs + 1;
f010670e:	e8 5f 2b 00 00       	call   f0109272 <cpunum>
f0106713:	6b c0 74             	imul   $0x74,%eax,%eax
f0106716:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010671b:	8b 00                	mov    (%eax),%eax
f010671d:	89 c2                	mov    %eax,%edx
f010671f:	a1 3c 32 29 f0       	mov    0xf029323c,%eax
f0106724:	29 c2                	sub    %eax,%edx
f0106726:	89 d0                	mov    %edx,%eax
f0106728:	c1 f8 02             	sar    $0x2,%eax
f010672b:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0106731:	83 c0 01             	add    $0x1,%eax
f0106734:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
 	for(i = 0;i < NENV; cur_id++, i++){
f0106737:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010673e:	eb 62                	jmp    f01067a2 <sched_yield+0x115>
 		if(cur_id >= NENV) cur_id %= NENV;
f0106740:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0106747:	7e 13                	jle    f010675c <sched_yield+0xcf>
f0106749:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010674c:	99                   	cltd   
f010674d:	c1 ea 16             	shr    $0x16,%edx
f0106750:	01 d0                	add    %edx,%eax
f0106752:	25 ff 03 00 00       	and    $0x3ff,%eax
f0106757:	29 d0                	sub    %edx,%eax
f0106759:	89 45 f4             	mov    %eax,-0xc(%ebp)
 		if(envs[cur_id].env_status == ENV_RUNNABLE){
f010675c:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f0106762:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106765:	c1 e0 02             	shl    $0x2,%eax
f0106768:	89 c1                	mov    %eax,%ecx
f010676a:	c1 e1 05             	shl    $0x5,%ecx
f010676d:	29 c1                	sub    %eax,%ecx
f010676f:	89 c8                	mov    %ecx,%eax
f0106771:	01 d0                	add    %edx,%eax
f0106773:	8b 40 54             	mov    0x54(%eax),%eax
f0106776:	83 f8 02             	cmp    $0x2,%eax
f0106779:	75 1f                	jne    f010679a <sched_yield+0x10d>
 			env_run(&envs[cur_id]);
f010677b:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f0106781:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106784:	c1 e0 02             	shl    $0x2,%eax
f0106787:	89 c1                	mov    %eax,%ecx
f0106789:	c1 e1 05             	shl    $0x5,%ecx
f010678c:	29 c1                	sub    %eax,%ecx
f010678e:	89 c8                	mov    %ecx,%eax
f0106790:	01 d0                	add    %edx,%eax
f0106792:	89 04 24             	mov    %eax,(%esp)
f0106795:	e8 2b e4 ff ff       	call   f0104bc5 <env_run>
		cur_id = thiscpu->cpu_env - envs+1;
	}
	else{
		cur_id = thiscpu->cpu_env - envs + 1;
	}
 	for(i = 0;i < NENV; cur_id++, i++){
f010679a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010679e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f01067a2:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f01067a9:	7e 95                	jle    f0106740 <sched_yield+0xb3>
 			break;
 		}
 	}
 	// if((i == NENV) && (thiscpu->cpu_env->env_status == ENV_RUNNING)) env_run(&envs[cpunum()]);
	// sched_halt never returns
	if(no_runnable){
f01067ab:	80 7d ef 00          	cmpb   $0x0,-0x11(%ebp)
f01067af:	74 05                	je     f01067b6 <sched_yield+0x129>
		sched_halt();
f01067b1:	e8 02 00 00 00       	call   f01067b8 <sched_halt>
	}
}
f01067b6:	c9                   	leave  
f01067b7:	c3                   	ret    

f01067b8 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01067b8:	55                   	push   %ebp
f01067b9:	89 e5                	mov    %esp,%ebp
f01067bb:	83 ec 28             	sub    $0x28,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01067be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01067c5:	eb 61                	jmp    f0106828 <sched_halt+0x70>
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01067c7:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f01067cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01067d0:	c1 e0 02             	shl    $0x2,%eax
f01067d3:	89 c1                	mov    %eax,%ecx
f01067d5:	c1 e1 05             	shl    $0x5,%ecx
f01067d8:	29 c1                	sub    %eax,%ecx
f01067da:	89 c8                	mov    %ecx,%eax
f01067dc:	01 d0                	add    %edx,%eax
f01067de:	8b 40 54             	mov    0x54(%eax),%eax
f01067e1:	83 f8 02             	cmp    $0x2,%eax
f01067e4:	74 4b                	je     f0106831 <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
f01067e6:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f01067ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01067ef:	c1 e0 02             	shl    $0x2,%eax
f01067f2:	89 c1                	mov    %eax,%ecx
f01067f4:	c1 e1 05             	shl    $0x5,%ecx
f01067f7:	29 c1                	sub    %eax,%ecx
f01067f9:	89 c8                	mov    %ecx,%eax
f01067fb:	01 d0                	add    %edx,%eax
f01067fd:	8b 40 54             	mov    0x54(%eax),%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0106800:	83 f8 03             	cmp    $0x3,%eax
f0106803:	74 2c                	je     f0106831 <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
f0106805:	8b 15 3c 32 29 f0    	mov    0xf029323c,%edx
f010680b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010680e:	c1 e0 02             	shl    $0x2,%eax
f0106811:	89 c1                	mov    %eax,%ecx
f0106813:	c1 e1 05             	shl    $0x5,%ecx
f0106816:	29 c1                	sub    %eax,%ecx
f0106818:	89 c8                	mov    %ecx,%eax
f010681a:	01 d0                	add    %edx,%eax
f010681c:	8b 40 54             	mov    0x54(%eax),%eax

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010681f:	83 f8 01             	cmp    $0x1,%eax
f0106822:	74 0d                	je     f0106831 <sched_halt+0x79>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0106824:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0106828:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f010682f:	7e 96                	jle    f01067c7 <sched_halt+0xf>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0106831:	81 7d f4 00 04 00 00 	cmpl   $0x400,-0xc(%ebp)
f0106838:	75 1a                	jne    f0106854 <sched_halt+0x9c>
		cprintf("No runnable environments in the system!\n");
f010683a:	c7 04 24 34 b0 10 f0 	movl   $0xf010b034,(%esp)
f0106841:	e8 06 e7 ff ff       	call   f0104f4c <cprintf>
		while (1)
			monitor(NULL);
f0106846:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010684d:	e8 fa a8 ff ff       	call   f010114c <monitor>
f0106852:	eb f2                	jmp    f0106846 <sched_halt+0x8e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0106854:	e8 19 2a 00 00       	call   f0109272 <cpunum>
f0106859:	6b c0 74             	imul   $0x74,%eax,%eax
f010685c:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106861:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lcr3(PADDR(kern_pgdir));
f0106867:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f010686c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106870:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0106877:	00 
f0106878:	c7 04 24 5d b0 10 f0 	movl   $0xf010b05d,(%esp)
f010687f:	e8 ce fd ff ff       	call   f0106652 <_paddr>
f0106884:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0106887:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010688a:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010688d:	e8 e0 29 00 00       	call   f0109272 <cpunum>
f0106892:	6b c0 74             	imul   $0x74,%eax,%eax
f0106895:	05 20 70 29 f0       	add    $0xf0297020,%eax
f010689a:	83 c0 04             	add    $0x4,%eax
f010689d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01068a4:	00 
f01068a5:	89 04 24             	mov    %eax,(%esp)
f01068a8:	e8 75 fd ff ff       	call   f0106622 <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f01068ad:	e8 8a fd ff ff       	call   f010663c <unlock_kernel>
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01068b2:	e8 bb 29 00 00       	call   f0109272 <cpunum>
f01068b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01068ba:	05 30 70 29 f0       	add    $0xf0297030,%eax
f01068bf:	8b 00                	mov    (%eax),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01068c1:	bd 00 00 00 00       	mov    $0x0,%ebp
f01068c6:	89 c4                	mov    %eax,%esp
f01068c8:	6a 00                	push   $0x0
f01068ca:	6a 00                	push   $0x0
f01068cc:	fb                   	sti    
f01068cd:	f4                   	hlt    
f01068ce:	eb fd                	jmp    f01068cd <sched_halt+0x115>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01068d0:	c9                   	leave  
f01068d1:	c3                   	ret    

f01068d2 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f01068d2:	55                   	push   %ebp
f01068d3:	89 e5                	mov    %esp,%ebp
f01068d5:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f01068d8:	8b 45 10             	mov    0x10(%ebp),%eax
f01068db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01068e0:	77 21                	ja     f0106903 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01068e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01068e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01068e9:	c7 44 24 08 6c b0 10 	movl   $0xf010b06c,0x8(%esp)
f01068f0:	f0 
f01068f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01068f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01068fb:	89 04 24             	mov    %eax,(%esp)
f01068fe:	e8 cc 99 ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106903:	8b 45 10             	mov    0x10(%ebp),%eax
f0106906:	05 00 00 00 10       	add    $0x10000000,%eax
}
f010690b:	c9                   	leave  
f010690c:	c3                   	ret    

f010690d <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
f010690d:	55                   	push   %ebp
f010690e:	89 e5                	mov    %esp,%ebp
f0106910:	83 ec 18             	sub    $0x18,%esp
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv,s, len, 0);
f0106913:	e8 5a 29 00 00       	call   f0109272 <cpunum>
f0106918:	6b c0 74             	imul   $0x74,%eax,%eax
f010691b:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106920:	8b 00                	mov    (%eax),%eax
f0106922:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0106929:	00 
f010692a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010692d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106931:	8b 55 08             	mov    0x8(%ebp),%edx
f0106934:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106938:	89 04 24             	mov    %eax,(%esp)
f010693b:	e8 b1 b4 ff ff       	call   f0101df1 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0106940:	8b 45 08             	mov    0x8(%ebp),%eax
f0106943:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106947:	8b 45 0c             	mov    0xc(%ebp),%eax
f010694a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010694e:	c7 04 24 90 b0 10 f0 	movl   $0xf010b090,(%esp)
f0106955:	e8 f2 e5 ff ff       	call   f0104f4c <cprintf>
}
f010695a:	c9                   	leave  
f010695b:	c3                   	ret    

f010695c <sys_cgetc>:

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
f010695c:	55                   	push   %ebp
f010695d:	89 e5                	mov    %esp,%ebp
f010695f:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f0106962:	e8 52 a1 ff ff       	call   f0100ab9 <cons_getc>
}
f0106967:	c9                   	leave  
f0106968:	c3                   	ret    

f0106969 <sys_getenvid>:

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0106969:	55                   	push   %ebp
f010696a:	89 e5                	mov    %esp,%ebp
f010696c:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f010696f:	e8 fe 28 00 00       	call   f0109272 <cpunum>
f0106974:	6b c0 74             	imul   $0x74,%eax,%eax
f0106977:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010697c:	8b 00                	mov    (%eax),%eax
f010697e:	8b 40 48             	mov    0x48(%eax),%eax
}
f0106981:	c9                   	leave  
f0106982:	c3                   	ret    

f0106983 <sys_env_destroy>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
f0106983:	55                   	push   %ebp
f0106984:	89 e5                	mov    %esp,%ebp
f0106986:	53                   	push   %ebx
f0106987:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010698a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106991:	00 
f0106992:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106995:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106999:	8b 45 08             	mov    0x8(%ebp),%eax
f010699c:	89 04 24             	mov    %eax,(%esp)
f010699f:	e8 aa d9 ff ff       	call   f010434e <envid2env>
f01069a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01069a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01069ab:	79 05                	jns    f01069b2 <sys_env_destroy+0x2f>
		return r;
f01069ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01069b0:	eb 76                	jmp    f0106a28 <sys_env_destroy+0xa5>
	if (e == curenv)
f01069b2:	e8 bb 28 00 00       	call   f0109272 <cpunum>
f01069b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01069ba:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01069bf:	8b 10                	mov    (%eax),%edx
f01069c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01069c4:	39 c2                	cmp    %eax,%edx
f01069c6:	75 24                	jne    f01069ec <sys_env_destroy+0x69>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01069c8:	e8 a5 28 00 00       	call   f0109272 <cpunum>
f01069cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01069d0:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01069d5:	8b 00                	mov    (%eax),%eax
f01069d7:	8b 40 48             	mov    0x48(%eax),%eax
f01069da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069de:	c7 04 24 95 b0 10 f0 	movl   $0xf010b095,(%esp)
f01069e5:	e8 62 e5 ff ff       	call   f0104f4c <cprintf>
f01069ea:	eb 2c                	jmp    f0106a18 <sys_env_destroy+0x95>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01069ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01069ef:	8b 58 48             	mov    0x48(%eax),%ebx
f01069f2:	e8 7b 28 00 00       	call   f0109272 <cpunum>
f01069f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01069fa:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01069ff:	8b 00                	mov    (%eax),%eax
f0106a01:	8b 40 48             	mov    0x48(%eax),%eax
f0106a04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106a08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a0c:	c7 04 24 b0 b0 10 f0 	movl   $0xf010b0b0,(%esp)
f0106a13:	e8 34 e5 ff ff       	call   f0104f4c <cprintf>
	env_destroy(e);
f0106a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106a1b:	89 04 24             	mov    %eax,(%esp)
f0106a1e:	e8 c2 e0 ff ff       	call   f0104ae5 <env_destroy>
	return 0;
f0106a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106a28:	83 c4 24             	add    $0x24,%esp
f0106a2b:	5b                   	pop    %ebx
f0106a2c:	5d                   	pop    %ebp
f0106a2d:	c3                   	ret    

f0106a2e <sys_yield>:

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0106a2e:	55                   	push   %ebp
f0106a2f:	89 e5                	mov    %esp,%ebp
f0106a31:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0106a34:	e8 54 fc ff ff       	call   f010668d <sched_yield>

f0106a39 <sys_exofork>:
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
f0106a39:	55                   	push   %ebp
f0106a3a:	89 e5                	mov    %esp,%ebp
f0106a3c:	57                   	push   %edi
f0106a3d:	56                   	push   %esi
f0106a3e:	53                   	push   %ebx
f0106a3f:	83 ec 2c             	sub    $0x2c,%esp
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env* e;
	int r;
	if((r = env_alloc(&e,curenv->env_id)) < 0) return r;
f0106a42:	e8 2b 28 00 00       	call   f0109272 <cpunum>
f0106a47:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a4a:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106a4f:	8b 00                	mov    (%eax),%eax
f0106a51:	8b 40 48             	mov    0x48(%eax),%eax
f0106a54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a58:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0106a5b:	89 04 24             	mov    %eax,(%esp)
f0106a5e:	e8 23 db ff ff       	call   f0104586 <env_alloc>
f0106a63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106a66:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106a6a:	79 05                	jns    f0106a71 <sys_exofork+0x38>
f0106a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a6f:	eb 3d                	jmp    f0106aae <sys_exofork+0x75>
	e->env_status = ENV_NOT_RUNNABLE;
f0106a71:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106a74:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f0106a7b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0106a7e:	e8 ef 27 00 00       	call   f0109272 <cpunum>
f0106a83:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a86:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106a8b:	8b 00                	mov    (%eax),%eax
f0106a8d:	89 da                	mov    %ebx,%edx
f0106a8f:	89 c3                	mov    %eax,%ebx
f0106a91:	b8 11 00 00 00       	mov    $0x11,%eax
f0106a96:	89 d7                	mov    %edx,%edi
f0106a98:	89 de                	mov    %ebx,%esi
f0106a9a:	89 c1                	mov    %eax,%ecx
f0106a9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0106a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106aa1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0106aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106aab:	8b 40 48             	mov    0x48(%eax),%eax
	// panic("sys_exofork not implemented");
}
f0106aae:	83 c4 2c             	add    $0x2c,%esp
f0106ab1:	5b                   	pop    %ebx
f0106ab2:	5e                   	pop    %esi
f0106ab3:	5f                   	pop    %edi
f0106ab4:	5d                   	pop    %ebp
f0106ab5:	c3                   	ret    

f0106ab6 <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0106ab6:	55                   	push   %ebp
f0106ab7:	89 e5                	mov    %esp,%ebp
f0106ab9:	83 ec 28             	sub    $0x28,%esp
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106abc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106ac3:	00 
f0106ac4:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106acb:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ace:	89 04 24             	mov    %eax,(%esp)
f0106ad1:	e8 78 d8 ff ff       	call   f010434e <envid2env>
f0106ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106ad9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106add:	79 05                	jns    f0106ae4 <sys_env_set_status+0x2e>
f0106adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106ae2:	eb 21                	jmp    f0106b05 <sys_env_set_status+0x4f>
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
f0106ae4:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
f0106ae8:	74 06                	je     f0106af0 <sys_env_set_status+0x3a>
f0106aea:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
f0106aee:	75 10                	jne    f0106b00 <sys_env_set_status+0x4a>
f0106af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106af3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106af6:	89 50 54             	mov    %edx,0x54(%eax)
	else return -E_INVAL;
	return 0;
f0106af9:	b8 00 00 00 00       	mov    $0x0,%eax
f0106afe:	eb 05                	jmp    f0106b05 <sys_env_set_status+0x4f>
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
	else return -E_INVAL;
f0106b00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return 0;
	// panic("sys_env_set_status not implemented");
}
f0106b05:	c9                   	leave  
f0106b06:	c3                   	ret    

f0106b07 <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f0106b07:	55                   	push   %ebp
f0106b08:	89 e5                	mov    %esp,%ebp
f0106b0a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106b0d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106b14:	00 
f0106b15:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106b18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0106b1f:	89 04 24             	mov    %eax,(%esp)
f0106b22:	e8 27 d8 ff ff       	call   f010434e <envid2env>
f0106b27:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106b2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106b2e:	79 05                	jns    f0106b35 <sys_env_set_pgfault_upcall+0x2e>
f0106b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106b33:	eb 0e                	jmp    f0106b43 <sys_env_set_pgfault_upcall+0x3c>
	e->env_pgfault_upcall = func;
f0106b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106b38:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b3b:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f0106b3e:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_env_set_pgfault_upcall not implemented");
}
f0106b43:	c9                   	leave  
f0106b44:	c3                   	ret    

f0106b45 <sys_page_alloc>:
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
f0106b45:	55                   	push   %ebp
f0106b46:	89 e5                	mov    %esp,%ebp
f0106b48:	83 ec 38             	sub    $0x38,%esp

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
f0106b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106b4e:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106b53:	77 2e                	ja     f0106b83 <sys_page_alloc+0x3e>
f0106b55:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106b62:	01 d0                	add    %edx,%eax
f0106b64:	83 e8 01             	sub    $0x1,%eax
f0106b67:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106b6d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106b72:	f7 75 f4             	divl   -0xc(%ebp)
f0106b75:	89 d0                	mov    %edx,%eax
f0106b77:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106b7a:	29 c2                	sub    %eax,%edx
f0106b7c:	89 d0                	mov    %edx,%eax
f0106b7e:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106b81:	74 0a                	je     f0106b8d <sys_page_alloc+0x48>
f0106b83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b88:	e9 a3 00 00 00       	jmp    f0106c30 <sys_page_alloc+0xeb>
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
f0106b8d:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b90:	83 e0 04             	and    $0x4,%eax
f0106b93:	85 c0                	test   %eax,%eax
f0106b95:	74 0a                	je     f0106ba1 <sys_page_alloc+0x5c>
f0106b97:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b9a:	83 e0 01             	and    $0x1,%eax
f0106b9d:	85 c0                	test   %eax,%eax
f0106b9f:	75 0a                	jne    f0106bab <sys_page_alloc+0x66>
f0106ba1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ba6:	e9 85 00 00 00       	jmp    f0106c30 <sys_page_alloc+0xeb>
	if(perm & !PTE_SYSCALL) return -E_INVAL;
	
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106bab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106bb2:	00 
f0106bb3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106bba:	8b 45 08             	mov    0x8(%ebp),%eax
f0106bbd:	89 04 24             	mov    %eax,(%esp)
f0106bc0:	e8 89 d7 ff ff       	call   f010434e <envid2env>
f0106bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106bc8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106bcc:	79 05                	jns    f0106bd3 <sys_page_alloc+0x8e>
f0106bce:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106bd1:	eb 5d                	jmp    f0106c30 <sys_page_alloc+0xeb>
	struct PageInfo *p;
	if(!(p = page_alloc(ALLOC_ZERO))) return -E_NO_MEM;
f0106bd3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106bda:	e8 a3 ac ff ff       	call   f0101882 <page_alloc>
f0106bdf:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106be2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106be6:	75 07                	jne    f0106bef <sys_page_alloc+0xaa>
f0106be8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106bed:	eb 41                	jmp    f0106c30 <sys_page_alloc+0xeb>
	if((r = page_insert(e->env_pgdir, p, va, perm)) < 0){
f0106bef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106bf2:	8b 40 60             	mov    0x60(%eax),%eax
f0106bf5:	8b 55 10             	mov    0x10(%ebp),%edx
f0106bf8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106bff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c03:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106c06:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106c0a:	89 04 24             	mov    %eax,(%esp)
f0106c0d:	e8 f9 ae ff ff       	call   f0101b0b <page_insert>
f0106c12:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106c15:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106c19:	79 10                	jns    f0106c2b <sys_page_alloc+0xe6>
		page_free(p);
f0106c1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106c1e:	89 04 24             	mov    %eax,(%esp)
f0106c21:	e8 bf ac ff ff       	call   f01018e5 <page_free>
		return r;
f0106c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106c29:	eb 05                	jmp    f0106c30 <sys_page_alloc+0xeb>
	}
	return 0;
f0106c2b:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_alloc not implemented");
}
f0106c30:	c9                   	leave  
f0106c31:	c3                   	ret    

f0106c32 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0106c32:	55                   	push   %ebp
f0106c33:	89 e5                	mov    %esp,%ebp
f0106c35:	83 ec 48             	sub    $0x48,%esp
	// LAB 4: Your code here.
	struct Env *srce;
	struct Env *dste;
	int r;

	if((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE) != srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE) != dstva) return -E_INVAL;
f0106c38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106c3b:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106c40:	77 66                	ja     f0106ca8 <sys_page_map+0x76>
f0106c42:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106c49:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106c4f:	01 d0                	add    %edx,%eax
f0106c51:	83 e8 01             	sub    $0x1,%eax
f0106c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106c5a:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c5f:	f7 75 f4             	divl   -0xc(%ebp)
f0106c62:	89 d0                	mov    %edx,%eax
f0106c64:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106c67:	29 c2                	sub    %eax,%edx
f0106c69:	89 d0                	mov    %edx,%eax
f0106c6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106c6e:	75 38                	jne    f0106ca8 <sys_page_map+0x76>
f0106c70:	8b 45 14             	mov    0x14(%ebp),%eax
f0106c73:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106c78:	77 2e                	ja     f0106ca8 <sys_page_map+0x76>
f0106c7a:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0106c81:	8b 55 14             	mov    0x14(%ebp),%edx
f0106c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106c87:	01 d0                	add    %edx,%eax
f0106c89:	83 e8 01             	sub    $0x1,%eax
f0106c8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106c8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106c92:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c97:	f7 75 ec             	divl   -0x14(%ebp)
f0106c9a:	89 d0                	mov    %edx,%eax
f0106c9c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106c9f:	29 c2                	sub    %eax,%edx
f0106ca1:	89 d0                	mov    %edx,%eax
f0106ca3:	3b 45 14             	cmp    0x14(%ebp),%eax
f0106ca6:	74 0a                	je     f0106cb2 <sys_page_map+0x80>
f0106ca8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106cad:	e9 f5 00 00 00       	jmp    f0106da7 <sys_page_map+0x175>
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
f0106cb2:	8b 45 18             	mov    0x18(%ebp),%eax
f0106cb5:	83 e0 04             	and    $0x4,%eax
f0106cb8:	85 c0                	test   %eax,%eax
f0106cba:	74 0a                	je     f0106cc6 <sys_page_map+0x94>
f0106cbc:	8b 45 18             	mov    0x18(%ebp),%eax
f0106cbf:	83 e0 01             	and    $0x1,%eax
f0106cc2:	85 c0                	test   %eax,%eax
f0106cc4:	75 0a                	jne    f0106cd0 <sys_page_map+0x9e>
f0106cc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ccb:	e9 d7 00 00 00       	jmp    f0106da7 <sys_page_map+0x175>
	if(perm & !PTE_SYSCALL) return -E_INVAL;

	if((r = envid2env(srcenvid, &srce, 1)) < 0) return r;
f0106cd0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106cd7:	00 
f0106cd8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ce2:	89 04 24             	mov    %eax,(%esp)
f0106ce5:	e8 64 d6 ff ff       	call   f010434e <envid2env>
f0106cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106ced:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106cf1:	79 08                	jns    f0106cfb <sys_page_map+0xc9>
f0106cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106cf6:	e9 ac 00 00 00       	jmp    f0106da7 <sys_page_map+0x175>
	if((r = envid2env(dstenvid, &dste, 1)) < 0) return r;
f0106cfb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106d02:	00 
f0106d03:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0106d06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d0a:	8b 45 10             	mov    0x10(%ebp),%eax
f0106d0d:	89 04 24             	mov    %eax,(%esp)
f0106d10:	e8 39 d6 ff ff       	call   f010434e <envid2env>
f0106d15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106d18:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106d1c:	79 08                	jns    f0106d26 <sys_page_map+0xf4>
f0106d1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106d21:	e9 81 00 00 00       	jmp    f0106da7 <sys_page_map+0x175>
	struct PageInfo *srcp;
	struct PageInfo *dstp;
	pte_t *ptable_entry;
	if(!(srcp = page_lookup(srce->env_pgdir, srcva, &ptable_entry))) return -E_INVAL;
f0106d26:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106d29:	8b 40 60             	mov    0x60(%eax),%eax
f0106d2c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0106d2f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106d33:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106d36:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d3a:	89 04 24             	mov    %eax,(%esp)
f0106d3d:	e8 5b ae ff ff       	call   f0101b9d <page_lookup>
f0106d42:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0106d45:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0106d49:	75 07                	jne    f0106d52 <sys_page_map+0x120>
f0106d4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d50:	eb 55                	jmp    f0106da7 <sys_page_map+0x175>
	if(~(*ptable_entry & PTE_W) & (perm & PTE_W)) return -E_INVAL;
f0106d52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106d55:	8b 00                	mov    (%eax),%eax
f0106d57:	83 e0 02             	and    $0x2,%eax
f0106d5a:	f7 d0                	not    %eax
f0106d5c:	89 c2                	mov    %eax,%edx
f0106d5e:	8b 45 18             	mov    0x18(%ebp),%eax
f0106d61:	21 d0                	and    %edx,%eax
f0106d63:	83 e0 02             	and    $0x2,%eax
f0106d66:	85 c0                	test   %eax,%eax
f0106d68:	74 07                	je     f0106d71 <sys_page_map+0x13f>
f0106d6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d6f:	eb 36                	jmp    f0106da7 <sys_page_map+0x175>
	if((r = page_insert(dste->env_pgdir, srcp, dstva, perm)) < 0) return r;
f0106d71:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106d74:	8b 40 60             	mov    0x60(%eax),%eax
f0106d77:	8b 55 18             	mov    0x18(%ebp),%edx
f0106d7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106d7e:	8b 55 14             	mov    0x14(%ebp),%edx
f0106d81:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106d85:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106d88:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d8c:	89 04 24             	mov    %eax,(%esp)
f0106d8f:	e8 77 ad ff ff       	call   f0101b0b <page_insert>
f0106d94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106d97:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106d9b:	79 05                	jns    f0106da2 <sys_page_map+0x170>
f0106d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106da0:	eb 05                	jmp    f0106da7 <sys_page_map+0x175>
	return 0;
f0106da2:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_map not implemented");
}
f0106da7:	c9                   	leave  
f0106da8:	c3                   	ret    

f0106da9 <sys_page_unmap>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0106da9:	55                   	push   %ebp
f0106daa:	89 e5                	mov    %esp,%ebp
f0106dac:	83 ec 28             	sub    $0x28,%esp
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
f0106daf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106db2:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106db7:	77 2e                	ja     f0106de7 <sys_page_unmap+0x3e>
f0106db9:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106dc6:	01 d0                	add    %edx,%eax
f0106dc8:	83 e8 01             	sub    $0x1,%eax
f0106dcb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106dce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106dd1:	ba 00 00 00 00       	mov    $0x0,%edx
f0106dd6:	f7 75 f4             	divl   -0xc(%ebp)
f0106dd9:	89 d0                	mov    %edx,%eax
f0106ddb:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106dde:	29 c2                	sub    %eax,%edx
f0106de0:	89 d0                	mov    %edx,%eax
f0106de2:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106de5:	74 07                	je     f0106dee <sys_page_unmap+0x45>
f0106de7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106dec:	eb 42                	jmp    f0106e30 <sys_page_unmap+0x87>
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106dee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106df5:	00 
f0106df6:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106df9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106dfd:	8b 45 08             	mov    0x8(%ebp),%eax
f0106e00:	89 04 24             	mov    %eax,(%esp)
f0106e03:	e8 46 d5 ff ff       	call   f010434e <envid2env>
f0106e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106e0b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106e0f:	79 05                	jns    f0106e16 <sys_page_unmap+0x6d>
f0106e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106e14:	eb 1a                	jmp    f0106e30 <sys_page_unmap+0x87>
	page_remove(e->env_pgdir, va);
f0106e16:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106e19:	8b 40 60             	mov    0x60(%eax),%eax
f0106e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106e1f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e23:	89 04 24             	mov    %eax,(%esp)
f0106e26:	e8 c5 ad ff ff       	call   f0101bf0 <page_remove>
	return 0;
f0106e2b:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_unmap not implemented");
}
f0106e30:	c9                   	leave  
f0106e31:	c3                   	ret    

f0106e32 <sys_ipc_try_send>:
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
f0106e32:	55                   	push   %ebp
f0106e33:	89 e5                	mov    %esp,%ebp
f0106e35:	53                   	push   %ebx
f0106e36:	83 ec 34             	sub    $0x34,%esp
	// LAB 4: Your code here.
	struct Env *rec_env;
	int r;
	uint32_t i_srcva = (uint32_t)srcva;
f0106e39:	8b 45 10             	mov    0x10(%ebp),%eax
f0106e3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(i_srcva < UTOP && (ROUNDDOWN(srcva,PGSIZE) != srcva)) return -E_INVAL;
f0106e3f:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106e46:	77 1d                	ja     f0106e65 <sys_ipc_try_send+0x33>
f0106e48:	8b 45 10             	mov    0x10(%ebp),%eax
f0106e4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106e4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106e51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106e56:	3b 45 10             	cmp    0x10(%ebp),%eax
f0106e59:	74 0a                	je     f0106e65 <sys_ipc_try_send+0x33>
f0106e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e60:	e9 64 01 00 00       	jmp    f0106fc9 <sys_ipc_try_send+0x197>
	if(i_srcva < UTOP && (!(perm & PTE_U) || !(perm & PTE_P))) return -E_INVAL;
f0106e65:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106e6c:	77 1e                	ja     f0106e8c <sys_ipc_try_send+0x5a>
f0106e6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0106e71:	83 e0 04             	and    $0x4,%eax
f0106e74:	85 c0                	test   %eax,%eax
f0106e76:	74 0a                	je     f0106e82 <sys_ipc_try_send+0x50>
f0106e78:	8b 45 14             	mov    0x14(%ebp),%eax
f0106e7b:	83 e0 01             	and    $0x1,%eax
f0106e7e:	85 c0                	test   %eax,%eax
f0106e80:	75 0a                	jne    f0106e8c <sys_ipc_try_send+0x5a>
f0106e82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e87:	e9 3d 01 00 00       	jmp    f0106fc9 <sys_ipc_try_send+0x197>
	if(i_srcva < UTOP && (perm & !PTE_SYSCALL)) return -E_INVAL;
	pte_t *pte;
	struct PageInfo *pp;
	if(i_srcva < UTOP && !(pp = page_lookup(curenv->env_pgdir, srcva, &pte))) return -E_INVAL;
f0106e8c:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106e93:	77 3b                	ja     f0106ed0 <sys_ipc_try_send+0x9e>
f0106e95:	e8 d8 23 00 00       	call   f0109272 <cpunum>
f0106e9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e9d:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106ea2:	8b 00                	mov    (%eax),%eax
f0106ea4:	8b 40 60             	mov    0x60(%eax),%eax
f0106ea7:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0106eaa:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106eae:	8b 55 10             	mov    0x10(%ebp),%edx
f0106eb1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106eb5:	89 04 24             	mov    %eax,(%esp)
f0106eb8:	e8 e0 ac ff ff       	call   f0101b9d <page_lookup>
f0106ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106ec0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106ec4:	75 0a                	jne    f0106ed0 <sys_ipc_try_send+0x9e>
f0106ec6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ecb:	e9 f9 00 00 00       	jmp    f0106fc9 <sys_ipc_try_send+0x197>
	if((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0106ed0:	8b 45 14             	mov    0x14(%ebp),%eax
f0106ed3:	83 e0 02             	and    $0x2,%eax
f0106ed6:	85 c0                	test   %eax,%eax
f0106ed8:	74 16                	je     f0106ef0 <sys_ipc_try_send+0xbe>
f0106eda:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106edd:	8b 00                	mov    (%eax),%eax
f0106edf:	83 e0 02             	and    $0x2,%eax
f0106ee2:	85 c0                	test   %eax,%eax
f0106ee4:	75 0a                	jne    f0106ef0 <sys_ipc_try_send+0xbe>
f0106ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106eeb:	e9 d9 00 00 00       	jmp    f0106fc9 <sys_ipc_try_send+0x197>
	
	if((r = envid2env(envid,&rec_env,0)) < 0) return r;
f0106ef0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106ef7:	00 
f0106ef8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106efb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106eff:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f02:	89 04 24             	mov    %eax,(%esp)
f0106f05:	e8 44 d4 ff ff       	call   f010434e <envid2env>
f0106f0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106f0d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106f11:	79 08                	jns    f0106f1b <sys_ipc_try_send+0xe9>
f0106f13:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106f16:	e9 ae 00 00 00       	jmp    f0106fc9 <sys_ipc_try_send+0x197>
	
	if(!rec_env->env_ipc_recving) return -E_IPC_NOT_RECV;
f0106f1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f1e:	0f b6 40 68          	movzbl 0x68(%eax),%eax
f0106f22:	83 f0 01             	xor    $0x1,%eax
f0106f25:	84 c0                	test   %al,%al
f0106f27:	74 0a                	je     f0106f33 <sys_ipc_try_send+0x101>
f0106f29:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f0106f2e:	e9 96 00 00 00       	jmp    f0106fc9 <sys_ipc_try_send+0x197>

	if(i_srcva < UTOP && ((uint32_t)rec_env->env_ipc_dstva) < UTOP){
f0106f33:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106f3a:	77 4c                	ja     f0106f88 <sys_ipc_try_send+0x156>
f0106f3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f3f:	8b 40 6c             	mov    0x6c(%eax),%eax
f0106f42:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106f47:	77 3f                	ja     f0106f88 <sys_ipc_try_send+0x156>
		if((r = page_insert(rec_env->env_pgdir, pp, rec_env->env_ipc_dstva, perm)) < 0) return r;
f0106f49:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0106f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f4f:	8b 50 6c             	mov    0x6c(%eax),%edx
f0106f52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f55:	8b 40 60             	mov    0x60(%eax),%eax
f0106f58:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106f5c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f60:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106f63:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106f67:	89 04 24             	mov    %eax,(%esp)
f0106f6a:	e8 9c ab ff ff       	call   f0101b0b <page_insert>
f0106f6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106f72:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106f76:	79 05                	jns    f0106f7d <sys_ipc_try_send+0x14b>
f0106f78:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106f7b:	eb 4c                	jmp    f0106fc9 <sys_ipc_try_send+0x197>
		rec_env->env_ipc_perm = perm;
f0106f7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f80:	8b 55 14             	mov    0x14(%ebp),%edx
f0106f83:	89 50 78             	mov    %edx,0x78(%eax)
f0106f86:	eb 0a                	jmp    f0106f92 <sys_ipc_try_send+0x160>
	}
	else{
		rec_env->env_ipc_perm = 0;
f0106f88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f8b:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	rec_env->env_ipc_recving = 0;
f0106f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f95:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	rec_env->env_ipc_from = curenv->env_id;
f0106f99:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0106f9c:	e8 d1 22 00 00       	call   f0109272 <cpunum>
f0106fa1:	6b c0 74             	imul   $0x74,%eax,%eax
f0106fa4:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0106fa9:	8b 00                	mov    (%eax),%eax
f0106fab:	8b 40 48             	mov    0x48(%eax),%eax
f0106fae:	89 43 74             	mov    %eax,0x74(%ebx)
	rec_env->env_ipc_value = value;
f0106fb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106fb7:	89 50 70             	mov    %edx,0x70(%eax)
	rec_env->env_status = ENV_RUNNABLE;
f0106fba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106fbd:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0106fc4:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_ipc_try_send not implemented");
}
f0106fc9:	83 c4 34             	add    $0x34,%esp
f0106fcc:	5b                   	pop    %ebx
f0106fcd:	5d                   	pop    %ebp
f0106fce:	c3                   	ret    

f0106fcf <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f0106fcf:	55                   	push   %ebp
f0106fd0:	89 e5                	mov    %esp,%ebp
f0106fd2:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	if((uint32_t)dstva < UTOP && ROUNDDOWN((uint32_t)dstva,PGSIZE) != PGSIZE) return -E_INVAL;
f0106fd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0106fd8:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106fdd:	77 1c                	ja     f0106ffb <sys_ipc_recv+0x2c>
f0106fdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0106fe2:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106fe8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106fed:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0106ff2:	74 07                	je     f0106ffb <sys_ipc_recv+0x2c>
f0106ff4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ff9:	eb 5e                	jmp    f0107059 <sys_ipc_recv+0x8a>
	curenv->env_ipc_recving = 1;
f0106ffb:	e8 72 22 00 00       	call   f0109272 <cpunum>
f0107000:	6b c0 74             	imul   $0x74,%eax,%eax
f0107003:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107008:	8b 00                	mov    (%eax),%eax
f010700a:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f010700e:	e8 5f 22 00 00       	call   f0109272 <cpunum>
f0107013:	6b c0 74             	imul   $0x74,%eax,%eax
f0107016:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010701b:	8b 00                	mov    (%eax),%eax
f010701d:	8b 55 08             	mov    0x8(%ebp),%edx
f0107020:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0107023:	e8 4a 22 00 00       	call   f0109272 <cpunum>
f0107028:	6b c0 74             	imul   $0x74,%eax,%eax
f010702b:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107030:	8b 00                	mov    (%eax),%eax
f0107032:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	curenv->env_tf.tf_regs.reg_eax = 0;
f0107039:	e8 34 22 00 00       	call   f0109272 <cpunum>
f010703e:	6b c0 74             	imul   $0x74,%eax,%eax
f0107041:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107046:	8b 00                	mov    (%eax),%eax
f0107048:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	sys_yield();
f010704f:	e8 da f9 ff ff       	call   f0106a2e <sys_yield>
	// panic("sys_ipc_recv not implemented");
	return 0;
f0107054:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107059:	c9                   	leave  
f010705a:	c3                   	ret    

f010705b <get_cmd>:

static char cmd[1024] = {0};
static char args[10][1024] = {{0}};

void get_cmd(char* buf){
f010705b:	55                   	push   %ebp
f010705c:	89 e5                	mov    %esp,%ebp
f010705e:	57                   	push   %edi
f010705f:	53                   	push   %ebx
f0107060:	81 ec 30 04 00 00    	sub    $0x430,%esp
	int i;
	for(i=0;i <1024;i++){
f0107066:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010706d:	eb 0f                	jmp    f010707e <get_cmd+0x23>
		cmd[i] = '\0';
f010706f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107072:	05 e0 3a 29 f0       	add    $0xf0293ae0,%eax
f0107077:	c6 00 00             	movb   $0x0,(%eax)
static char cmd[1024] = {0};
static char args[10][1024] = {{0}};

void get_cmd(char* buf){
	int i;
	for(i=0;i <1024;i++){
f010707a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010707e:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0107085:	7e e8                	jle    f010706f <get_cmd+0x14>
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
f0107087:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010708e:	eb 2f                	jmp    f01070bf <get_cmd+0x64>
		int j;
		for(j=0;j<1024;j++){
f0107090:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0107097:	eb 19                	jmp    f01070b2 <get_cmd+0x57>
			args[i][j] = '\0';
f0107099:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010709c:	c1 e0 0a             	shl    $0xa,%eax
f010709f:	89 c2                	mov    %eax,%edx
f01070a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01070a4:	01 d0                	add    %edx,%eax
f01070a6:	05 e0 3e 29 f0       	add    $0xf0293ee0,%eax
f01070ab:	c6 00 00             	movb   $0x0,(%eax)
	for(i=0;i <1024;i++){
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
		int j;
		for(j=0;j<1024;j++){
f01070ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f01070b2:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f01070b9:	7e de                	jle    f0107099 <get_cmd+0x3e>
void get_cmd(char* buf){
	int i;
	for(i=0;i <1024;i++){
		cmd[i] = '\0';
	}
	for(i=0;i<5;i++){
f01070bb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01070bf:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
f01070c3:	7e cb                	jle    f0107090 <get_cmd+0x35>
		int j;
		for(j=0;j<1024;j++){
			args[i][j] = '\0';
		}
	}
	char* w_pos = strchr(buf, ' ');
f01070c5:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f01070cc:	00 
f01070cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01070d0:	89 04 24             	mov    %eax,(%esp)
f01070d3:	e8 6e 16 00 00       	call   f0108746 <strchr>
f01070d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// cprintf("hddddddddddddhdhh\n");
	char bufcpy[1024] = {0};
f01070db:	8d 9d e0 fb ff ff    	lea    -0x420(%ebp),%ebx
f01070e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01070e6:	ba 00 01 00 00       	mov    $0x100,%edx
f01070eb:	89 df                	mov    %ebx,%edi
f01070ed:	89 d1                	mov    %edx,%ecx
f01070ef:	f3 ab                	rep stos %eax,%es:(%edi)
	strcpy(bufcpy,buf);
f01070f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01070f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070f8:	8d 85 e0 fb ff ff    	lea    -0x420(%ebp),%eax
f01070fe:	89 04 24             	mov    %eax,(%esp)
f0107101:	e8 b5 14 00 00       	call   f01085bb <strcpy>
	if(w_pos == NULL){
f0107106:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010710a:	75 38                	jne    f0107144 <get_cmd+0xe9>
		for(i=0;i<strlen(buf);i++){
f010710c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0107113:	eb 1a                	jmp    f010712f <get_cmd+0xd4>
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
f0107115:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107118:	8b 45 08             	mov    0x8(%ebp),%eax
f010711b:	01 d0                	add    %edx,%eax
f010711d:	0f b6 00             	movzbl (%eax),%eax
f0107120:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107123:	81 c2 e0 3a 29 f0    	add    $0xf0293ae0,%edx
f0107129:	88 02                	mov    %al,(%edx)
	char* w_pos = strchr(buf, ' ');
	// cprintf("hddddddddddddhdhh\n");
	char bufcpy[1024] = {0};
	strcpy(bufcpy,buf);
	if(w_pos == NULL){
		for(i=0;i<strlen(buf);i++){
f010712b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010712f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107132:	89 04 24             	mov    %eax,(%esp)
f0107135:	e8 2b 14 00 00       	call   f0108565 <strlen>
f010713a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010713d:	7f d6                	jg     f0107115 <get_cmd+0xba>
f010713f:	e9 72 01 00 00       	jmp    f01072b6 <get_cmd+0x25b>
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
		}
		return;
	}
	for(i=0;i<(w_pos-buf);i++){
f0107144:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010714b:	eb 1a                	jmp    f0107167 <get_cmd+0x10c>
		// cprintf("heelo2: %s\n", buf[i]);
		cmd[i] = buf[i];
f010714d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107150:	8b 45 08             	mov    0x8(%ebp),%eax
f0107153:	01 d0                	add    %edx,%eax
f0107155:	0f b6 00             	movzbl (%eax),%eax
f0107158:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010715b:	81 c2 e0 3a 29 f0    	add    $0xf0293ae0,%edx
f0107161:	88 02                	mov    %al,(%edx)
			// cprintf("heelo1: %s\n", buf);
			cmd[i] = buf[i];
		}
		return;
	}
	for(i=0;i<(w_pos-buf);i++){
f0107163:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0107167:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010716a:	8b 45 08             	mov    0x8(%ebp),%eax
f010716d:	29 c2                	sub    %eax,%edx
f010716f:	89 d0                	mov    %edx,%eax
f0107171:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0107174:	7f d7                	jg     f010714d <get_cmd+0xf2>
		// cprintf("heelo2: %s\n", buf[i]);
		cmd[i] = buf[i];
	}
	if(w_pos-buf < strlen(buf)){
f0107176:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0107179:	8b 45 08             	mov    0x8(%ebp),%eax
f010717c:	89 d3                	mov    %edx,%ebx
f010717e:	29 c3                	sub    %eax,%ebx
f0107180:	8b 45 08             	mov    0x8(%ebp),%eax
f0107183:	89 04 24             	mov    %eax,(%esp)
f0107186:	e8 da 13 00 00       	call   f0108565 <strlen>
f010718b:	39 c3                	cmp    %eax,%ebx
f010718d:	0f 8d 23 01 00 00    	jge    f01072b6 <get_cmd+0x25b>
		int is_quote = 0;
f0107193:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		int index = 0;
f010719a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		// int done = 0;
		int curr = 0;
f01071a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		for(i = 0;i<strlen(buf)-(w_pos-buf)-1;i++){
f01071a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01071af:	e9 b0 00 00 00       	jmp    f0107264 <get_cmd+0x209>
			// cprintf("args[0]: %s\n", args[0]);
			if(is_quote == 0 && w_pos[i+1] == ' '){
f01071b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01071b8:	75 3b                	jne    f01071f5 <get_cmd+0x19a>
f01071ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01071bd:	8d 50 01             	lea    0x1(%eax),%edx
f01071c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01071c3:	01 d0                	add    %edx,%eax
f01071c5:	0f b6 00             	movzbl (%eax),%eax
f01071c8:	3c 20                	cmp    $0x20,%al
f01071ca:	75 29                	jne    f01071f5 <get_cmd+0x19a>
				while(w_pos[i+1] == ' ') i++;
f01071cc:	eb 04                	jmp    f01071d2 <get_cmd+0x177>
f01071ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01071d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01071d5:	8d 50 01             	lea    0x1(%eax),%edx
f01071d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01071db:	01 d0                	add    %edx,%eax
f01071dd:	0f b6 00             	movzbl (%eax),%eax
f01071e0:	3c 20                	cmp    $0x20,%al
f01071e2:	74 ea                	je     f01071ce <get_cmd+0x173>
				i--;
f01071e4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
				index += 1;
f01071e8:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
				// done = i+1;
				curr = 0;
f01071ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01071f3:	eb 6b                	jmp    f0107260 <get_cmd+0x205>
			}
			else if(is_quote == 1 && w_pos[i+1] == '\"') {
f01071f5:	83 7d ec 01          	cmpl   $0x1,-0x14(%ebp)
f01071f9:	75 1b                	jne    f0107216 <get_cmd+0x1bb>
f01071fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01071fe:	8d 50 01             	lea    0x1(%eax),%edx
f0107201:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107204:	01 d0                	add    %edx,%eax
f0107206:	0f b6 00             	movzbl (%eax),%eax
f0107209:	3c 22                	cmp    $0x22,%al
f010720b:	75 09                	jne    f0107216 <get_cmd+0x1bb>
				is_quote = 0;
f010720d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0107214:	eb 4a                	jmp    f0107260 <get_cmd+0x205>
			}
			else if(is_quote == 0 && w_pos[i+1] == '\"'){
f0107216:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010721a:	75 1b                	jne    f0107237 <get_cmd+0x1dc>
f010721c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010721f:	8d 50 01             	lea    0x1(%eax),%edx
f0107222:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107225:	01 d0                	add    %edx,%eax
f0107227:	0f b6 00             	movzbl (%eax),%eax
f010722a:	3c 22                	cmp    $0x22,%al
f010722c:	75 09                	jne    f0107237 <get_cmd+0x1dc>
				is_quote = 1;
f010722e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0107235:	eb 29                	jmp    f0107260 <get_cmd+0x205>
			}
			else{
				args[index][curr] = w_pos[1+i];
f0107237:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010723a:	83 c0 01             	add    $0x1,%eax
f010723d:	89 c2                	mov    %eax,%edx
f010723f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107242:	01 d0                	add    %edx,%eax
f0107244:	0f b6 00             	movzbl (%eax),%eax
f0107247:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010724a:	89 d1                	mov    %edx,%ecx
f010724c:	c1 e1 0a             	shl    $0xa,%ecx
f010724f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107252:	01 ca                	add    %ecx,%edx
f0107254:	81 c2 e0 3e 29 f0    	add    $0xf0293ee0,%edx
f010725a:	88 02                	mov    %al,(%edx)
				curr++;
f010725c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
	if(w_pos-buf < strlen(buf)){
		int is_quote = 0;
		int index = 0;
		// int done = 0;
		int curr = 0;
		for(i = 0;i<strlen(buf)-(w_pos-buf)-1;i++){
f0107260:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0107264:	8b 45 08             	mov    0x8(%ebp),%eax
f0107267:	89 04 24             	mov    %eax,(%esp)
f010726a:	e8 f6 12 00 00       	call   f0108565 <strlen>
f010726f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107272:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0107275:	29 d1                	sub    %edx,%ecx
f0107277:	89 ca                	mov    %ecx,%edx
f0107279:	01 d0                	add    %edx,%eax
f010727b:	83 e8 01             	sub    $0x1,%eax
f010727e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0107281:	0f 8f 2d ff ff ff    	jg     f01071b4 <get_cmd+0x159>
				args[index][curr] = w_pos[1+i];
				curr++;
				// cprintf("index: %d, args[1]: %c, i-done: %s\n", index, w_pos[i+1], args[index]);
			}
		}
		if(strcmp(args[index],"&")==0){
f0107287:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010728a:	c1 e0 0a             	shl    $0xa,%eax
f010728d:	05 e0 3e 29 f0       	add    $0xf0293ee0,%eax
f0107292:	c7 44 24 04 c8 b0 10 	movl   $0xf010b0c8,0x4(%esp)
f0107299:	f0 
f010729a:	89 04 24             	mov    %eax,(%esp)
f010729d:	e8 0f 14 00 00       	call   f01086b1 <strcmp>
f01072a2:	85 c0                	test   %eax,%eax
f01072a4:	75 10                	jne    f01072b6 <get_cmd+0x25b>
			args[index][0] = '\0';
f01072a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01072a9:	c1 e0 0a             	shl    $0xa,%eax
f01072ac:	05 e0 3e 29 f0       	add    $0xf0293ee0,%eax
f01072b1:	c6 00 00             	movb   $0x0,(%eax)
f01072b4:	eb 00                	jmp    f01072b6 <get_cmd+0x25b>
		}
	}
	// cprintf("buffer: %s, command: %s, arguement: %s\n", buf, cmd, args[0]);
}
f01072b6:	81 c4 30 04 00 00    	add    $0x430,%esp
f01072bc:	5b                   	pop    %ebx
f01072bd:	5f                   	pop    %edi
f01072be:	5d                   	pop    %ebp
f01072bf:	c3                   	ret    

f01072c0 <sys_exec>:


void sys_exec(char* buf){
f01072c0:	55                   	push   %ebp
f01072c1:	89 e5                	mov    %esp,%ebp
f01072c3:	56                   	push   %esi
f01072c4:	53                   	push   %ebx
f01072c5:	81 ec 70 28 00 00    	sub    $0x2870,%esp
	uint32_t parent_id = curenv->env_parent_id;
f01072cb:	e8 a2 1f 00 00       	call   f0109272 <cpunum>
f01072d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01072d3:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01072d8:	8b 00                	mov    (%eax),%eax
f01072da:	8b 40 4c             	mov    0x4c(%eax),%eax
f01072dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t cur_id = curenv->env_id;
f01072e0:	e8 8d 1f 00 00       	call   f0109272 <cpunum>
f01072e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01072e8:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01072ed:	8b 00                	mov    (%eax),%eax
f01072ef:	8b 40 48             	mov    0x48(%eax),%eax
f01072f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// char* bufcpy = "";
	// int code;
	// memcpy(bufcpy, buf, strlen(buf));
	get_cmd(buf);
f01072f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01072f8:	89 04 24             	mov    %eax,(%esp)
f01072fb:	e8 5b fd ff ff       	call   f010705b <get_cmd>
	env_free(curenv);
f0107300:	e8 6d 1f 00 00       	call   f0109272 <cpunum>
f0107305:	6b c0 74             	imul   $0x74,%eax,%eax
f0107308:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010730d:	8b 00                	mov    (%eax),%eax
f010730f:	89 04 24             	mov    %eax,(%esp)
f0107312:	e8 48 d6 ff ff       	call   f010495f <env_free>
	env_alloc(&curenv, parent_id);
f0107317:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010731a:	e8 53 1f 00 00       	call   f0109272 <cpunum>
f010731f:	6b c0 74             	imul   $0x74,%eax,%eax
f0107322:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0107327:	83 c0 08             	add    $0x8,%eax
f010732a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010732e:	89 04 24             	mov    %eax,(%esp)
f0107331:	e8 50 d2 ff ff       	call   f0104586 <env_alloc>
	curenv->env_id = cur_id;
f0107336:	e8 37 1f 00 00       	call   f0109272 <cpunum>
f010733b:	6b c0 74             	imul   $0x74,%eax,%eax
f010733e:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107343:	8b 00                	mov    (%eax),%eax
f0107345:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0107348:	89 50 48             	mov    %edx,0x48(%eax)
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
f010734b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0107352:	eb 48                	jmp    f010739c <sys_exec+0xdc>
		int j;
		for(j=0;j<1024;j++){
f0107354:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010735b:	eb 32                	jmp    f010738f <sys_exec+0xcf>
			argv[i][j] = args[i][j];
f010735d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107360:	c1 e0 0a             	shl    $0xa,%eax
f0107363:	89 c2                	mov    %eax,%edx
f0107365:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107368:	01 d0                	add    %edx,%eax
f010736a:	05 e0 3e 29 f0       	add    $0xf0293ee0,%eax
f010736f:	0f b6 00             	movzbl (%eax),%eax
f0107372:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107375:	c1 e2 0a             	shl    $0xa,%edx
f0107378:	8d 75 f8             	lea    -0x8(%ebp),%esi
f010737b:	8d 0c 16             	lea    (%esi,%edx,1),%ecx
f010737e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107381:	01 ca                	add    %ecx,%edx
f0107383:	81 ea 20 28 00 00    	sub    $0x2820,%edx
f0107389:	88 02                	mov    %al,(%edx)
	curenv->env_id = cur_id;
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
		int j;
		for(j=0;j<1024;j++){
f010738b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f010738f:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0107396:	7e c5                	jle    f010735d <sys_exec+0x9d>
	env_free(curenv);
	env_alloc(&curenv, parent_id);
	curenv->env_id = cur_id;
	char argv[10][1024];
	int i;
	for(i=0;i<10;i++){
f0107398:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010739c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
f01073a0:	7e b2                	jle    f0107354 <sys_exec+0x94>
		for(j=0;j<1024;j++){
			argv[i][j] = args[i][j];
		}
	}
	// cprintf("\n\ncommand: %s, args[0]: %s, args[1]: %s\n\n",cmd, args[0], args[1]);
	if(strcmp(cmd, (const char*)("factorial")) == 0){
f01073a2:	c7 44 24 04 ca b0 10 	movl   $0xf010b0ca,0x4(%esp)
f01073a9:	f0 
f01073aa:	c7 04 24 e0 3a 29 f0 	movl   $0xf0293ae0,(%esp)
f01073b1:	e8 fb 12 00 00       	call   f01086b1 <strcmp>
f01073b6:	85 c0                	test   %eax,%eax
f01073b8:	75 24                	jne    f01073de <sys_exec+0x11e>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_factorial , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_factorial , _start));
f01073ba:	e8 b3 1e 00 00       	call   f0109272 <cpunum>
f01073bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01073c2:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01073c7:	8b 00                	mov    (%eax),%eax
f01073c9:	c7 44 24 04 ee 10 1a 	movl   $0xf01a10ee,0x4(%esp)
f01073d0:	f0 
f01073d1:	89 04 24             	mov    %eax,(%esp)
f01073d4:	e8 92 d3 ff ff       	call   f010476b <load_icode>
f01073d9:	e9 06 01 00 00       	jmp    f01074e4 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("fibonacci")) == 0) {
f01073de:	c7 44 24 04 d4 b0 10 	movl   $0xf010b0d4,0x4(%esp)
f01073e5:	f0 
f01073e6:	c7 04 24 e0 3a 29 f0 	movl   $0xf0293ae0,(%esp)
f01073ed:	e8 bf 12 00 00       	call   f01086b1 <strcmp>
f01073f2:	85 c0                	test   %eax,%eax
f01073f4:	75 24                	jne    f010741a <sys_exec+0x15a>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_fibonacci , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_fibonacci , _start));
f01073f6:	e8 77 1e 00 00       	call   f0109272 <cpunum>
f01073fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01073fe:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107403:	8b 00                	mov    (%eax),%eax
f0107405:	c7 44 24 04 d2 9a 1a 	movl   $0xf01a9ad2,0x4(%esp)
f010740c:	f0 
f010740d:	89 04 24             	mov    %eax,(%esp)
f0107410:	e8 56 d3 ff ff       	call   f010476b <load_icode>
f0107415:	e9 ca 00 00 00       	jmp    f01074e4 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("help")) == 0) {
f010741a:	c7 44 24 04 de b0 10 	movl   $0xf010b0de,0x4(%esp)
f0107421:	f0 
f0107422:	c7 04 24 e0 3a 29 f0 	movl   $0xf0293ae0,(%esp)
f0107429:	e8 83 12 00 00       	call   f01086b1 <strcmp>
f010742e:	85 c0                	test   %eax,%eax
f0107430:	75 24                	jne    f0107456 <sys_exec+0x196>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_help , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_help , _start));
f0107432:	e8 3b 1e 00 00       	call   f0109272 <cpunum>
f0107437:	6b c0 74             	imul   $0x74,%eax,%eax
f010743a:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010743f:	8b 00                	mov    (%eax),%eax
f0107441:	c7 44 24 04 e6 ae 1b 	movl   $0xf01baee6,0x4(%esp)
f0107448:	f0 
f0107449:	89 04 24             	mov    %eax,(%esp)
f010744c:	e8 1a d3 ff ff       	call   f010476b <load_icode>
f0107451:	e9 8e 00 00 00       	jmp    f01074e4 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("date")) == 0) {
f0107456:	c7 44 24 04 e3 b0 10 	movl   $0xf010b0e3,0x4(%esp)
f010745d:	f0 
f010745e:	c7 04 24 e0 3a 29 f0 	movl   $0xf0293ae0,(%esp)
f0107465:	e8 47 12 00 00       	call   f01086b1 <strcmp>
f010746a:	85 c0                	test   %eax,%eax
f010746c:	75 21                	jne    f010748f <sys_exec+0x1cf>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_date , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_date , _start));
f010746e:	e8 ff 1d 00 00       	call   f0109272 <cpunum>
f0107473:	6b c0 74             	imul   $0x74,%eax,%eax
f0107476:	05 28 70 29 f0       	add    $0xf0297028,%eax
f010747b:	8b 00                	mov    (%eax),%eax
f010747d:	c7 44 24 04 b6 24 1b 	movl   $0xf01b24b6,0x4(%esp)
f0107484:	f0 
f0107485:	89 04 24             	mov    %eax,(%esp)
f0107488:	e8 de d2 ff ff       	call   f010476b <load_icode>
f010748d:	eb 55                	jmp    f01074e4 <sys_exec+0x224>
	}
	else if(strcmp(cmd, (const char*)("echo")) == 0) {
f010748f:	c7 44 24 04 e8 b0 10 	movl   $0xf010b0e8,0x4(%esp)
f0107496:	f0 
f0107497:	c7 04 24 e0 3a 29 f0 	movl   $0xf0293ae0,(%esp)
f010749e:	e8 0e 12 00 00       	call   f01086b1 <strcmp>
f01074a3:	85 c0                	test   %eax,%eax
f01074a5:	75 21                	jne    f01074c8 <sys_exec+0x208>
		extern uint8_t ENV_PASTE3(_binary_obj_, user_echo , _start)[];
		load_icode(curenv,ENV_PASTE3(_binary_obj_, user_echo , _start));
f01074a7:	e8 c6 1d 00 00       	call   f0109272 <cpunum>
f01074ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01074af:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01074b4:	8b 00                	mov    (%eax),%eax
f01074b6:	c7 44 24 04 ab 38 1c 	movl   $0xf01c38ab,0x4(%esp)
f01074bd:	f0 
f01074be:	89 04 24             	mov    %eax,(%esp)
f01074c1:	e8 a5 d2 ff ff       	call   f010476b <load_icode>
f01074c6:	eb 1c                	jmp    f01074e4 <sys_exec+0x224>
	}
	else{
		panic("command not supported");
f01074c8:	c7 44 24 08 ed b0 10 	movl   $0xf010b0ed,0x8(%esp)
f01074cf:	f0 
f01074d0:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f01074d7:	00 
f01074d8:	c7 04 24 03 b1 10 f0 	movl   $0xf010b103,(%esp)
f01074df:	e8 eb 8d ff ff       	call   f01002cf <_panic>
		return;
	}
	// extern uint8_t ENV_PASTE3(_binary_obj_, user_hello , _start)[];
	// load_icode(curenv,ENV_PASTE3(_binary_obj_, user_hello , _start));
	lcr3(PADDR(curenv->env_pgdir));
f01074e4:	e8 89 1d 00 00       	call   f0109272 <cpunum>
f01074e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01074ec:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01074f1:	8b 00                	mov    (%eax),%eax
f01074f3:	8b 40 60             	mov    0x60(%eax),%eax
f01074f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01074fa:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f0107501:	00 
f0107502:	c7 04 24 03 b1 10 f0 	movl   $0xf010b103,(%esp)
f0107509:	e8 c4 f3 ff ff       	call   f01068d2 <_paddr>
f010750e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0107511:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107514:	0f 22 d8             	mov    %eax,%cr3
	int argc = 0;
f0107517:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	uint32_t sp = USTACKTOP;
f010751e:	c7 45 e8 00 e0 bf ee 	movl   $0xeebfe000,-0x18(%ebp)
	uint32_t ustack[13];
	for(argc = 0; strlen(argv[argc]) > 0; argc++) {
f0107525:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f010752c:	e9 98 00 00 00       	jmp    f01075c9 <sys_exec+0x309>
	    if(argc >= 10) panic("argc>=10");
f0107531:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
f0107535:	7e 1c                	jle    f0107553 <sys_exec+0x293>
f0107537:	c7 44 24 08 12 b1 10 	movl   $0xf010b112,0x8(%esp)
f010753e:	f0 
f010753f:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0107546:	00 
f0107547:	c7 04 24 03 b1 10 f0 	movl   $0xf010b103,(%esp)
f010754e:	e8 7c 8d ff ff       	call   f01002cf <_panic>
	    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
f0107553:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f0107559:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010755c:	c1 e2 0a             	shl    $0xa,%edx
f010755f:	01 d0                	add    %edx,%eax
f0107561:	89 04 24             	mov    %eax,(%esp)
f0107564:	e8 fc 0f 00 00       	call   f0108565 <strlen>
f0107569:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010756c:	29 c2                	sub    %eax,%edx
f010756e:	89 d0                	mov    %edx,%eax
f0107570:	83 e8 01             	sub    $0x1,%eax
f0107573:	83 e0 fc             	and    $0xfffffffc,%eax
f0107576:	89 45 e8             	mov    %eax,-0x18(%ebp)
	    memcpy((void *)sp, argv[argc], strlen(argv[argc]) + 1);
f0107579:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f010757f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0107582:	c1 e2 0a             	shl    $0xa,%edx
f0107585:	01 d0                	add    %edx,%eax
f0107587:	89 04 24             	mov    %eax,(%esp)
f010758a:	e8 d6 0f 00 00       	call   f0108565 <strlen>
f010758f:	83 c0 01             	add    $0x1,%eax
f0107592:	89 c2                	mov    %eax,%edx
f0107594:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f010759a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010759d:	c1 e1 0a             	shl    $0xa,%ecx
f01075a0:	01 c1                	add    %eax,%ecx
f01075a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01075a5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01075a9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01075ad:	89 04 24             	mov    %eax,(%esp)
f01075b0:	e8 3a 13 00 00       	call   f01088ef <memcpy>
	    ustack[2+argc] = sp;
f01075b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01075b8:	8d 50 02             	lea    0x2(%eax),%edx
f01075bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01075be:	89 84 95 a4 d7 ff ff 	mov    %eax,-0x285c(%ebp,%edx,4)
	// load_icode(curenv,ENV_PASTE3(_binary_obj_, user_hello , _start));
	lcr3(PADDR(curenv->env_pgdir));
	int argc = 0;
	uint32_t sp = USTACKTOP;
	uint32_t ustack[13];
	for(argc = 0; strlen(argv[argc]) > 0; argc++) {
f01075c5:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
f01075c9:	8d 85 d8 d7 ff ff    	lea    -0x2828(%ebp),%eax
f01075cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01075d2:	c1 e2 0a             	shl    $0xa,%edx
f01075d5:	01 d0                	add    %edx,%eax
f01075d7:	89 04 24             	mov    %eax,(%esp)
f01075da:	e8 86 0f 00 00       	call   f0108565 <strlen>
f01075df:	85 c0                	test   %eax,%eax
f01075e1:	0f 8f 4a ff ff ff    	jg     f0107531 <sys_exec+0x271>
	    if(argc >= 10) panic("argc>=10");
	    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
	    memcpy((void *)sp, argv[argc], strlen(argv[argc]) + 1);
	    ustack[2+argc] = sp;
	  }
	  ustack[2+argc] = 0;
f01075e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01075ea:	83 c0 02             	add    $0x2,%eax
f01075ed:	c7 84 85 a4 d7 ff ff 	movl   $0x0,-0x285c(%ebp,%eax,4)
f01075f4:	00 00 00 00 

	  // ustack[0] = 0xffffffff;  // fake return PC
	  // cprintf("argc ppushed: %d\n", argc);
	  ustack[0] = argc;
f01075f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01075fb:	89 85 a4 d7 ff ff    	mov    %eax,-0x285c(%ebp)
	  ustack[1] = sp - (argc+1)*4;  // argv pointer
f0107601:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107604:	f7 d0                	not    %eax
f0107606:	c1 e0 02             	shl    $0x2,%eax
f0107609:	89 c2                	mov    %eax,%edx
f010760b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010760e:	01 d0                	add    %edx,%eax
f0107610:	89 85 a8 d7 ff ff    	mov    %eax,-0x2858(%ebp)

	  sp -= (2+argc+1) * 4;
f0107616:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010761b:	2b 45 ec             	sub    -0x14(%ebp),%eax
f010761e:	c1 e0 02             	shl    $0x2,%eax
f0107621:	01 45 e8             	add    %eax,-0x18(%ebp)
	  memcpy((void *)sp, ustack, (2+argc+1)*4);
f0107624:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107627:	83 c0 03             	add    $0x3,%eax
f010762a:	c1 e0 02             	shl    $0x2,%eax
f010762d:	89 c2                	mov    %eax,%edx
f010762f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107632:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107636:	8d 95 a4 d7 ff ff    	lea    -0x285c(%ebp),%edx
f010763c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107640:	89 04 24             	mov    %eax,(%esp)
f0107643:	e8 a7 12 00 00       	call   f01088ef <memcpy>
	  curenv->env_tf.tf_esp = sp;
f0107648:	e8 25 1c 00 00       	call   f0109272 <cpunum>
f010764d:	6b c0 74             	imul   $0x74,%eax,%eax
f0107650:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107655:	8b 00                	mov    (%eax),%eax
f0107657:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010765a:	89 50 3c             	mov    %edx,0x3c(%eax)
	lcr3(PADDR(kern_pgdir));
f010765d:	a1 ec 6a 29 f0       	mov    0xf0296aec,%eax
f0107662:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107666:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
f010766d:	00 
f010766e:	c7 04 24 03 b1 10 f0 	movl   $0xf010b103,(%esp)
f0107675:	e8 58 f2 ff ff       	call   f01068d2 <_paddr>
f010767a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010767d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107680:	0f 22 d8             	mov    %eax,%cr3
	env_run(curenv);
f0107683:	e8 ea 1b 00 00       	call   f0109272 <cpunum>
f0107688:	6b c0 74             	imul   $0x74,%eax,%eax
f010768b:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107690:	8b 00                	mov    (%eax),%eax
f0107692:	89 04 24             	mov    %eax,(%esp)
f0107695:	e8 2b d5 ff ff       	call   f0104bc5 <env_run>

f010769a <sys_wait>:
	// sched_yield();
	// cprintf("\n\nheeeeeeeeeeelo---------------\n\n");
	// env_destroy(e);
}

void sys_wait(){
f010769a:	55                   	push   %ebp
f010769b:	89 e5                	mov    %esp,%ebp
f010769d:	83 ec 08             	sub    $0x8,%esp
	curenv->env_status = ENV_WAIT_CHILD;
f01076a0:	e8 cd 1b 00 00       	call   f0109272 <cpunum>
f01076a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01076a8:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01076ad:	8b 00                	mov    (%eax),%eax
f01076af:	c7 40 54 05 00 00 00 	movl   $0x5,0x54(%eax)
}
f01076b6:	c9                   	leave  
f01076b7:	c3                   	ret    

f01076b8 <sys_guest>:

void sys_guest(){
f01076b8:	55                   	push   %ebp
f01076b9:	89 e5                	mov    %esp,%ebp
f01076bb:	83 ec 18             	sub    $0x18,%esp
	curenv->env_type = ENV_TYPE_GUEST;
f01076be:	e8 af 1b 00 00       	call   f0109272 <cpunum>
f01076c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01076c6:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01076cb:	8b 00                	mov    (%eax),%eax
f01076cd:	c7 40 50 01 00 00 00 	movl   $0x1,0x50(%eax)
	extern uint8_t ENV_PASTE3(_binary_obj_, guest_boot , _start)[];
	load_icode(curenv,ENV_PASTE3(_binary_obj_, guest_boot , _start));
f01076d4:	e8 99 1b 00 00       	call   f0109272 <cpunum>
f01076d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01076dc:	05 28 70 29 f0       	add    $0xf0297028,%eax
f01076e1:	8b 00                	mov    (%eax),%eax
f01076e3:	c7 44 24 04 12 18 29 	movl   $0xf0291812,0x4(%esp)
f01076ea:	f0 
f01076eb:	89 04 24             	mov    %eax,(%esp)
f01076ee:	e8 78 d0 ff ff       	call   f010476b <load_icode>
	curenv->env_tf.tf_eip = 0x7c00;
f01076f3:	e8 7a 1b 00 00       	call   f0109272 <cpunum>
f01076f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01076fb:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107700:	8b 00                	mov    (%eax),%eax
f0107702:	c7 40 30 00 7c 00 00 	movl   $0x7c00,0x30(%eax)
	curenv->env_tf.tf_esp = 0;
f0107709:	e8 64 1b 00 00       	call   f0109272 <cpunum>
f010770e:	6b c0 74             	imul   $0x74,%eax,%eax
f0107711:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107716:	8b 00                	mov    (%eax),%eax
f0107718:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
f010771f:	c9                   	leave  
f0107720:	c3                   	ret    

f0107721 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0107721:	55                   	push   %ebp
f0107722:	89 e5                	mov    %esp,%ebp
f0107724:	56                   	push   %esi
f0107725:	53                   	push   %ebx
f0107726:	83 ec 20             	sub    $0x20,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f0107729:	83 7d 08 0f          	cmpl   $0xf,0x8(%ebp)
f010772d:	0f 87 4a 01 00 00    	ja     f010787d <syscall+0x15c>
f0107733:	8b 45 08             	mov    0x8(%ebp),%eax
f0107736:	c1 e0 02             	shl    $0x2,%eax
f0107739:	05 1c b1 10 f0       	add    $0xf010b11c,%eax
f010773e:	8b 00                	mov    (%eax),%eax
f0107740:	ff e0                	jmp    *%eax
		case SYS_cputs:
			sys_cputs((char *)a1,a2);
f0107742:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107745:	8b 55 10             	mov    0x10(%ebp),%edx
f0107748:	89 54 24 04          	mov    %edx,0x4(%esp)
f010774c:	89 04 24             	mov    %eax,(%esp)
f010774f:	e8 b9 f1 ff ff       	call   f010690d <sys_cputs>
			return 0;
f0107754:	b8 00 00 00 00       	mov    $0x0,%eax
f0107759:	e9 24 01 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_cgetc:
			return sys_cgetc();
f010775e:	e8 f9 f1 ff ff       	call   f010695c <sys_cgetc>
f0107763:	e9 1a 01 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_getenvid:
			return sys_getenvid();
f0107768:	e8 fc f1 ff ff       	call   f0106969 <sys_getenvid>
f010776d:	e9 10 01 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f0107772:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107775:	89 04 24             	mov    %eax,(%esp)
f0107778:	e8 06 f2 ff ff       	call   f0106983 <sys_env_destroy>
f010777d:	e9 00 01 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_yield:
			sys_yield();
f0107782:	e8 a7 f2 ff ff       	call   f0106a2e <sys_yield>
			return 0;
f0107787:	b8 00 00 00 00       	mov    $0x0,%eax
f010778c:	e9 f1 00 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_exofork:
			return sys_exofork();
f0107791:	e8 a3 f2 ff ff       	call   f0106a39 <sys_exofork>
f0107796:	e9 e7 00 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f010779b:	8b 55 10             	mov    0x10(%ebp),%edx
f010779e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01077a1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01077a5:	89 04 24             	mov    %eax,(%esp)
f01077a8:	e8 09 f3 ff ff       	call   f0106ab6 <sys_env_set_status>
f01077ad:	e9 d0 00 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void *)a2,(int)a3);
f01077b2:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01077b5:	8b 55 10             	mov    0x10(%ebp),%edx
f01077b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01077bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01077bf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01077c3:	89 04 24             	mov    %eax,(%esp)
f01077c6:	e8 7a f3 ff ff       	call   f0106b45 <sys_page_alloc>
f01077cb:	e9 b2 00 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void *)a2,(envid_t)a3,(void *)a4,(int)a5);
f01077d0:	8b 75 1c             	mov    0x1c(%ebp),%esi
f01077d3:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01077d6:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01077d9:	8b 55 10             	mov    0x10(%ebp),%edx
f01077dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01077df:	89 74 24 10          	mov    %esi,0x10(%esp)
f01077e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01077e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01077eb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01077ef:	89 04 24             	mov    %eax,(%esp)
f01077f2:	e8 3b f4 ff ff       	call   f0106c32 <sys_page_map>
f01077f7:	e9 86 00 00 00       	jmp    f0107882 <syscall+0x161>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void *)a2);
f01077fc:	8b 55 10             	mov    0x10(%ebp),%edx
f01077ff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107802:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107806:	89 04 24             	mov    %eax,(%esp)
f0107809:	e8 9b f5 ff ff       	call   f0106da9 <sys_page_unmap>
f010780e:	eb 72                	jmp    f0107882 <syscall+0x161>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0107810:	8b 55 10             	mov    0x10(%ebp),%edx
f0107813:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107816:	89 54 24 04          	mov    %edx,0x4(%esp)
f010781a:	89 04 24             	mov    %eax,(%esp)
f010781d:	e8 e5 f2 ff ff       	call   f0106b07 <sys_env_set_pgfault_upcall>
f0107822:	eb 5e                	jmp    f0107882 <syscall+0x161>
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0107824:	8b 55 14             	mov    0x14(%ebp),%edx
f0107827:	8b 45 0c             	mov    0xc(%ebp),%eax
f010782a:	8b 4d 18             	mov    0x18(%ebp),%ecx
f010782d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0107831:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107835:	8b 55 10             	mov    0x10(%ebp),%edx
f0107838:	89 54 24 04          	mov    %edx,0x4(%esp)
f010783c:	89 04 24             	mov    %eax,(%esp)
f010783f:	e8 ee f5 ff ff       	call   f0106e32 <sys_ipc_try_send>
f0107844:	eb 3c                	jmp    f0107882 <syscall+0x161>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0107846:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107849:	89 04 24             	mov    %eax,(%esp)
f010784c:	e8 7e f7 ff ff       	call   f0106fcf <sys_ipc_recv>
f0107851:	eb 2f                	jmp    f0107882 <syscall+0x161>
		case SYS_exec:
			sys_exec((char *)a1);
f0107853:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107856:	89 04 24             	mov    %eax,(%esp)
f0107859:	e8 62 fa ff ff       	call   f01072c0 <sys_exec>
			return 0;
f010785e:	b8 00 00 00 00       	mov    $0x0,%eax
f0107863:	eb 1d                	jmp    f0107882 <syscall+0x161>
		case SYS_wait:
			sys_wait();
f0107865:	e8 30 fe ff ff       	call   f010769a <sys_wait>
			return 0;
f010786a:	b8 00 00 00 00       	mov    $0x0,%eax
f010786f:	eb 11                	jmp    f0107882 <syscall+0x161>
		case SYS_guest:
			sys_guest();
f0107871:	e8 42 fe ff ff       	call   f01076b8 <sys_guest>
			return 0;
f0107876:	b8 00 00 00 00       	mov    $0x0,%eax
f010787b:	eb 05                	jmp    f0107882 <syscall+0x161>
		default:
			return -E_INVAL;
f010787d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0107882:	83 c4 20             	add    $0x20,%esp
f0107885:	5b                   	pop    %ebx
f0107886:	5e                   	pop    %esi
f0107887:	5d                   	pop    %ebp
f0107888:	c3                   	ret    

f0107889 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0107889:	55                   	push   %ebp
f010788a:	89 e5                	mov    %esp,%ebp
f010788c:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f010788f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107892:	8b 00                	mov    (%eax),%eax
f0107894:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107897:	8b 45 10             	mov    0x10(%ebp),%eax
f010789a:	8b 00                	mov    (%eax),%eax
f010789c:	89 45 f8             	mov    %eax,-0x8(%ebp)
f010789f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	while (l <= r) {
f01078a6:	e9 d2 00 00 00       	jmp    f010797d <stab_binsearch+0xf4>
		int true_m = (l + r) / 2, m = true_m;
f01078ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01078ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01078b1:	01 d0                	add    %edx,%eax
f01078b3:	89 c2                	mov    %eax,%edx
f01078b5:	c1 ea 1f             	shr    $0x1f,%edx
f01078b8:	01 d0                	add    %edx,%eax
f01078ba:	d1 f8                	sar    %eax
f01078bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01078bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01078c2:	89 45 f0             	mov    %eax,-0x10(%ebp)

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01078c5:	eb 04                	jmp    f01078cb <stab_binsearch+0x42>
			m--;
f01078c7:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01078cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01078ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f01078d1:	7c 1f                	jl     f01078f2 <stab_binsearch+0x69>
f01078d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01078d6:	89 d0                	mov    %edx,%eax
f01078d8:	01 c0                	add    %eax,%eax
f01078da:	01 d0                	add    %edx,%eax
f01078dc:	c1 e0 02             	shl    $0x2,%eax
f01078df:	89 c2                	mov    %eax,%edx
f01078e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01078e4:	01 d0                	add    %edx,%eax
f01078e6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f01078ea:	0f b6 c0             	movzbl %al,%eax
f01078ed:	3b 45 14             	cmp    0x14(%ebp),%eax
f01078f0:	75 d5                	jne    f01078c7 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f01078f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01078f5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f01078f8:	7d 0b                	jge    f0107905 <stab_binsearch+0x7c>
			l = true_m + 1;
f01078fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01078fd:	83 c0 01             	add    $0x1,%eax
f0107900:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f0107903:	eb 78                	jmp    f010797d <stab_binsearch+0xf4>
		}

		// actual binary search
		any_matches = 1;
f0107905:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f010790c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010790f:	89 d0                	mov    %edx,%eax
f0107911:	01 c0                	add    %eax,%eax
f0107913:	01 d0                	add    %edx,%eax
f0107915:	c1 e0 02             	shl    $0x2,%eax
f0107918:	89 c2                	mov    %eax,%edx
f010791a:	8b 45 08             	mov    0x8(%ebp),%eax
f010791d:	01 d0                	add    %edx,%eax
f010791f:	8b 40 08             	mov    0x8(%eax),%eax
f0107922:	3b 45 18             	cmp    0x18(%ebp),%eax
f0107925:	73 13                	jae    f010793a <stab_binsearch+0xb1>
			*region_left = m;
f0107927:	8b 45 0c             	mov    0xc(%ebp),%eax
f010792a:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010792d:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f010792f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107932:	83 c0 01             	add    $0x1,%eax
f0107935:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107938:	eb 43                	jmp    f010797d <stab_binsearch+0xf4>
		} else if (stabs[m].n_value > addr) {
f010793a:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010793d:	89 d0                	mov    %edx,%eax
f010793f:	01 c0                	add    %eax,%eax
f0107941:	01 d0                	add    %edx,%eax
f0107943:	c1 e0 02             	shl    $0x2,%eax
f0107946:	89 c2                	mov    %eax,%edx
f0107948:	8b 45 08             	mov    0x8(%ebp),%eax
f010794b:	01 d0                	add    %edx,%eax
f010794d:	8b 40 08             	mov    0x8(%eax),%eax
f0107950:	3b 45 18             	cmp    0x18(%ebp),%eax
f0107953:	76 16                	jbe    f010796b <stab_binsearch+0xe2>
			*region_right = m - 1;
f0107955:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107958:	8d 50 ff             	lea    -0x1(%eax),%edx
f010795b:	8b 45 10             	mov    0x10(%ebp),%eax
f010795e:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f0107960:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107963:	83 e8 01             	sub    $0x1,%eax
f0107966:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0107969:	eb 12                	jmp    f010797d <stab_binsearch+0xf4>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010796b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010796e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107971:	89 10                	mov    %edx,(%eax)
			l = m;
f0107973:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107976:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f0107979:	83 45 18 01          	addl   $0x1,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010797d:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107980:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0107983:	0f 8e 22 ff ff ff    	jle    f01078ab <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0107989:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010798d:	75 0f                	jne    f010799e <stab_binsearch+0x115>
		*region_right = *region_left - 1;
f010798f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107992:	8b 00                	mov    (%eax),%eax
f0107994:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107997:	8b 45 10             	mov    0x10(%ebp),%eax
f010799a:	89 10                	mov    %edx,(%eax)
f010799c:	eb 3f                	jmp    f01079dd <stab_binsearch+0x154>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010799e:	8b 45 10             	mov    0x10(%ebp),%eax
f01079a1:	8b 00                	mov    (%eax),%eax
f01079a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
f01079a6:	eb 04                	jmp    f01079ac <stab_binsearch+0x123>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01079a8:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f01079ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079af:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01079b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f01079b4:	7d 1f                	jge    f01079d5 <stab_binsearch+0x14c>
		     l > *region_left && stabs[l].n_type != type;
f01079b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01079b9:	89 d0                	mov    %edx,%eax
f01079bb:	01 c0                	add    %eax,%eax
f01079bd:	01 d0                	add    %edx,%eax
f01079bf:	c1 e0 02             	shl    $0x2,%eax
f01079c2:	89 c2                	mov    %eax,%edx
f01079c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01079c7:	01 d0                	add    %edx,%eax
f01079c9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f01079cd:	0f b6 c0             	movzbl %al,%eax
f01079d0:	3b 45 14             	cmp    0x14(%ebp),%eax
f01079d3:	75 d3                	jne    f01079a8 <stab_binsearch+0x11f>
		     l--)
			/* do nothing */;
		*region_left = l;
f01079d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01079db:	89 10                	mov    %edx,(%eax)
	}
}
f01079dd:	c9                   	leave  
f01079de:	c3                   	ret    

f01079df <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01079df:	55                   	push   %ebp
f01079e0:	89 e5                	mov    %esp,%ebp
f01079e2:	53                   	push   %ebx
f01079e3:	83 ec 54             	sub    $0x54,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01079e6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079e9:	c7 00 5c b1 10 f0    	movl   $0xf010b15c,(%eax)
	info->eip_line = 0;
f01079ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079f2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f01079f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01079fc:	c7 40 08 5c b1 10 f0 	movl   $0xf010b15c,0x8(%eax)
	info->eip_fn_namelen = 9;
f0107a03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a06:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f0107a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a10:	8b 55 08             	mov    0x8(%ebp),%edx
f0107a13:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f0107a16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107a19:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0107a20:	81 7d 08 ff ff 7f ef 	cmpl   $0xef7fffff,0x8(%ebp)
f0107a27:	76 21                	jbe    f0107a4a <debuginfo_eip+0x6b>
		stabs = __STAB_BEGIN__;
f0107a29:	c7 45 f4 a0 b6 10 f0 	movl   $0xf010b6a0,-0xc(%ebp)
		stab_end = __STAB_END__;
f0107a30:	c7 45 f0 1c 7f 11 f0 	movl   $0xf0117f1c,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0107a37:	c7 45 ec 1d 7f 11 f0 	movl   $0xf0117f1d,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f0107a3e:	c7 45 e8 f4 be 11 f0 	movl   $0xf011bef4,-0x18(%ebp)
f0107a45:	e9 f8 00 00 00       	jmp    f0107b42 <debuginfo_eip+0x163>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f0107a4a:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)USTABDATA, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f0107a51:	e8 1c 18 00 00       	call   f0109272 <cpunum>
f0107a56:	6b c0 74             	imul   $0x74,%eax,%eax
f0107a59:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107a5e:	8b 00                	mov    (%eax),%eax
f0107a60:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107a67:	00 
f0107a68:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0107a6f:	00 
f0107a70:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0107a77:	00 
f0107a78:	89 04 24             	mov    %eax,(%esp)
f0107a7b:	e8 a8 a2 ff ff       	call   f0101d28 <user_mem_check>
f0107a80:	85 c0                	test   %eax,%eax
f0107a82:	79 0a                	jns    f0107a8e <debuginfo_eip+0xaf>
f0107a84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107a89:	e9 93 03 00 00       	jmp    f0107e21 <debuginfo_eip+0x442>
		stabs = usd->stabs;
f0107a8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107a91:	8b 00                	mov    (%eax),%eax
f0107a93:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f0107a96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107a99:	8b 40 04             	mov    0x4(%eax),%eax
f0107a9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f0107a9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107aa2:	8b 40 08             	mov    0x8(%eax),%eax
f0107aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f0107aa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107aab:	8b 40 0c             	mov    0xc(%eax),%eax
f0107aae:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs, stab_end-stabs, PTE_U) < 0) return -1;
f0107ab1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ab7:	29 c2                	sub    %eax,%edx
f0107ab9:	89 d0                	mov    %edx,%eax
f0107abb:	c1 f8 02             	sar    $0x2,%eax
f0107abe:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0107ac4:	89 c3                	mov    %eax,%ebx
f0107ac6:	e8 a7 17 00 00       	call   f0109272 <cpunum>
f0107acb:	6b c0 74             	imul   $0x74,%eax,%eax
f0107ace:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107ad3:	8b 00                	mov    (%eax),%eax
f0107ad5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107adc:	00 
f0107add:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107ae1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107ae4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107ae8:	89 04 24             	mov    %eax,(%esp)
f0107aeb:	e8 38 a2 ff ff       	call   f0101d28 <user_mem_check>
f0107af0:	85 c0                	test   %eax,%eax
f0107af2:	79 0a                	jns    f0107afe <debuginfo_eip+0x11f>
f0107af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107af9:	e9 23 03 00 00       	jmp    f0107e21 <debuginfo_eip+0x442>
		if(user_mem_check(curenv,stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f0107afe:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0107b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107b04:	29 c2                	sub    %eax,%edx
f0107b06:	89 d0                	mov    %edx,%eax
f0107b08:	89 c3                	mov    %eax,%ebx
f0107b0a:	e8 63 17 00 00       	call   f0109272 <cpunum>
f0107b0f:	6b c0 74             	imul   $0x74,%eax,%eax
f0107b12:	05 28 70 29 f0       	add    $0xf0297028,%eax
f0107b17:	8b 00                	mov    (%eax),%eax
f0107b19:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107b20:	00 
f0107b21:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107b25:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0107b28:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107b2c:	89 04 24             	mov    %eax,(%esp)
f0107b2f:	e8 f4 a1 ff ff       	call   f0101d28 <user_mem_check>
f0107b34:	85 c0                	test   %eax,%eax
f0107b36:	79 0a                	jns    f0107b42 <debuginfo_eip+0x163>
f0107b38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107b3d:	e9 df 02 00 00       	jmp    f0107e21 <debuginfo_eip+0x442>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0107b42:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107b45:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0107b48:	76 0d                	jbe    f0107b57 <debuginfo_eip+0x178>
f0107b4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107b4d:	83 e8 01             	sub    $0x1,%eax
f0107b50:	0f b6 00             	movzbl (%eax),%eax
f0107b53:	84 c0                	test   %al,%al
f0107b55:	74 0a                	je     f0107b61 <debuginfo_eip+0x182>
		return -1;
f0107b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107b5c:	e9 c0 02 00 00       	jmp    f0107e21 <debuginfo_eip+0x442>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0107b61:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	rfile = (stab_end - stabs) - 1;
f0107b68:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107b6e:	29 c2                	sub    %eax,%edx
f0107b70:	89 d0                	mov    %edx,%eax
f0107b72:	c1 f8 02             	sar    $0x2,%eax
f0107b75:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0107b7b:	83 e8 01             	sub    $0x1,%eax
f0107b7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0107b81:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b84:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107b88:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
f0107b8f:	00 
f0107b90:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0107b93:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107b97:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0107b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ba1:	89 04 24             	mov    %eax,(%esp)
f0107ba4:	e8 e0 fc ff ff       	call   f0107889 <stab_binsearch>
	if (lfile == 0)
f0107ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107bac:	85 c0                	test   %eax,%eax
f0107bae:	75 0a                	jne    f0107bba <debuginfo_eip+0x1db>
		return -1;
f0107bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107bb5:	e9 67 02 00 00       	jmp    f0107e21 <debuginfo_eip+0x442>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0107bba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107bbd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	rfun = rfile;
f0107bc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107bc3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0107bc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0107bc9:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107bcd:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
f0107bd4:	00 
f0107bd5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0107bd8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107bdc:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0107bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107be6:	89 04 24             	mov    %eax,(%esp)
f0107be9:	e8 9b fc ff ff       	call   f0107889 <stab_binsearch>

	if (lfun <= rfun) {
f0107bee:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107bf1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0107bf4:	39 c2                	cmp    %eax,%edx
f0107bf6:	7f 7c                	jg     f0107c74 <debuginfo_eip+0x295>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0107bf8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107bfb:	89 c2                	mov    %eax,%edx
f0107bfd:	89 d0                	mov    %edx,%eax
f0107bff:	01 c0                	add    %eax,%eax
f0107c01:	01 d0                	add    %edx,%eax
f0107c03:	c1 e0 02             	shl    $0x2,%eax
f0107c06:	89 c2                	mov    %eax,%edx
f0107c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107c0b:	01 d0                	add    %edx,%eax
f0107c0d:	8b 10                	mov    (%eax),%edx
f0107c0f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107c15:	29 c1                	sub    %eax,%ecx
f0107c17:	89 c8                	mov    %ecx,%eax
f0107c19:	39 c2                	cmp    %eax,%edx
f0107c1b:	73 22                	jae    f0107c3f <debuginfo_eip+0x260>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0107c1d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107c20:	89 c2                	mov    %eax,%edx
f0107c22:	89 d0                	mov    %edx,%eax
f0107c24:	01 c0                	add    %eax,%eax
f0107c26:	01 d0                	add    %edx,%eax
f0107c28:	c1 e0 02             	shl    $0x2,%eax
f0107c2b:	89 c2                	mov    %eax,%edx
f0107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107c30:	01 d0                	add    %edx,%eax
f0107c32:	8b 10                	mov    (%eax),%edx
f0107c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107c37:	01 c2                	add    %eax,%edx
f0107c39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c3c:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = stabs[lfun].n_value;
f0107c3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107c42:	89 c2                	mov    %eax,%edx
f0107c44:	89 d0                	mov    %edx,%eax
f0107c46:	01 c0                	add    %eax,%eax
f0107c48:	01 d0                	add    %edx,%eax
f0107c4a:	c1 e0 02             	shl    $0x2,%eax
f0107c4d:	89 c2                	mov    %eax,%edx
f0107c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107c52:	01 d0                	add    %edx,%eax
f0107c54:	8b 50 08             	mov    0x8(%eax),%edx
f0107c57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c5a:	89 50 10             	mov    %edx,0x10(%eax)
		addr -= info->eip_fn_addr;
f0107c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c60:	8b 40 10             	mov    0x10(%eax),%eax
f0107c63:	29 45 08             	sub    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0107c66:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107c69:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfun;
f0107c6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0107c6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0107c72:	eb 15                	jmp    f0107c89 <debuginfo_eip+0x2aa>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0107c74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c77:	8b 55 08             	mov    0x8(%ebp),%edx
f0107c7a:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f0107c7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107c80:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfile;
f0107c83:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107c86:	89 45 cc             	mov    %eax,-0x34(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0107c89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c8c:	8b 40 08             	mov    0x8(%eax),%eax
f0107c8f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0107c96:	00 
f0107c97:	89 04 24             	mov    %eax,(%esp)
f0107c9a:	e8 da 0a 00 00       	call   f0108779 <strfind>
f0107c9f:	89 c2                	mov    %eax,%edx
f0107ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ca4:	8b 40 08             	mov    0x8(%eax),%eax
f0107ca7:	29 c2                	sub    %eax,%edx
f0107ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107cac:	89 50 0c             	mov    %edx,0xc(%eax)
	// Your code here.
	// char* fn_name="";
	// strncpy(fn_name,info->eip_fn_name,info->eip_fn_namelen);
	// fn_name[info->eip_fn_namelen] = '\0';
	// info->eip_fn_name = fn_name;
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0107caf:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cb2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107cb6:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
f0107cbd:	00 
f0107cbe:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0107cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107cc5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0107cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ccf:	89 04 24             	mov    %eax,(%esp)
f0107cd2:	e8 b2 fb ff ff       	call   f0107889 <stab_binsearch>
	if(lline <= rline)
f0107cd7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107cda:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0107cdd:	39 c2                	cmp    %eax,%edx
f0107cdf:	7f 24                	jg     f0107d05 <debuginfo_eip+0x326>
		info->eip_line = stabs[rline].n_desc;
f0107ce1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0107ce4:	89 c2                	mov    %eax,%edx
f0107ce6:	89 d0                	mov    %edx,%eax
f0107ce8:	01 c0                	add    %eax,%eax
f0107cea:	01 d0                	add    %edx,%eax
f0107cec:	c1 e0 02             	shl    $0x2,%eax
f0107cef:	89 c2                	mov    %eax,%edx
f0107cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107cf4:	01 d0                	add    %edx,%eax
f0107cf6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
f0107cfa:	0f b7 d0             	movzwl %ax,%edx
f0107cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d00:	89 50 04             	mov    %edx,0x4(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0107d03:	eb 13                	jmp    f0107d18 <debuginfo_eip+0x339>
	// info->eip_fn_name = fn_name;
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline)
		info->eip_line = stabs[rline].n_desc;
	else
		return -1;
f0107d05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107d0a:	e9 12 01 00 00       	jmp    f0107e21 <debuginfo_eip+0x442>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0107d0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107d12:	83 e8 01             	sub    $0x1,%eax
f0107d15:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0107d18:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107d1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107d1e:	39 c2                	cmp    %eax,%edx
f0107d20:	7c 56                	jl     f0107d78 <debuginfo_eip+0x399>
	       && stabs[lline].n_type != N_SOL
f0107d22:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107d25:	89 c2                	mov    %eax,%edx
f0107d27:	89 d0                	mov    %edx,%eax
f0107d29:	01 c0                	add    %eax,%eax
f0107d2b:	01 d0                	add    %edx,%eax
f0107d2d:	c1 e0 02             	shl    $0x2,%eax
f0107d30:	89 c2                	mov    %eax,%edx
f0107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d35:	01 d0                	add    %edx,%eax
f0107d37:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107d3b:	3c 84                	cmp    $0x84,%al
f0107d3d:	74 39                	je     f0107d78 <debuginfo_eip+0x399>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0107d3f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107d42:	89 c2                	mov    %eax,%edx
f0107d44:	89 d0                	mov    %edx,%eax
f0107d46:	01 c0                	add    %eax,%eax
f0107d48:	01 d0                	add    %edx,%eax
f0107d4a:	c1 e0 02             	shl    $0x2,%eax
f0107d4d:	89 c2                	mov    %eax,%edx
f0107d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d52:	01 d0                	add    %edx,%eax
f0107d54:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107d58:	3c 64                	cmp    $0x64,%al
f0107d5a:	75 b3                	jne    f0107d0f <debuginfo_eip+0x330>
f0107d5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107d5f:	89 c2                	mov    %eax,%edx
f0107d61:	89 d0                	mov    %edx,%eax
f0107d63:	01 c0                	add    %eax,%eax
f0107d65:	01 d0                	add    %edx,%eax
f0107d67:	c1 e0 02             	shl    $0x2,%eax
f0107d6a:	89 c2                	mov    %eax,%edx
f0107d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d6f:	01 d0                	add    %edx,%eax
f0107d71:	8b 40 08             	mov    0x8(%eax),%eax
f0107d74:	85 c0                	test   %eax,%eax
f0107d76:	74 97                	je     f0107d0f <debuginfo_eip+0x330>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0107d78:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107d7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107d7e:	39 c2                	cmp    %eax,%edx
f0107d80:	7c 46                	jl     f0107dc8 <debuginfo_eip+0x3e9>
f0107d82:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107d85:	89 c2                	mov    %eax,%edx
f0107d87:	89 d0                	mov    %edx,%eax
f0107d89:	01 c0                	add    %eax,%eax
f0107d8b:	01 d0                	add    %edx,%eax
f0107d8d:	c1 e0 02             	shl    $0x2,%eax
f0107d90:	89 c2                	mov    %eax,%edx
f0107d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d95:	01 d0                	add    %edx,%eax
f0107d97:	8b 10                	mov    (%eax),%edx
f0107d99:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0107d9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107d9f:	29 c1                	sub    %eax,%ecx
f0107da1:	89 c8                	mov    %ecx,%eax
f0107da3:	39 c2                	cmp    %eax,%edx
f0107da5:	73 21                	jae    f0107dc8 <debuginfo_eip+0x3e9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0107da7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107daa:	89 c2                	mov    %eax,%edx
f0107dac:	89 d0                	mov    %edx,%eax
f0107dae:	01 c0                	add    %eax,%eax
f0107db0:	01 d0                	add    %edx,%eax
f0107db2:	c1 e0 02             	shl    $0x2,%eax
f0107db5:	89 c2                	mov    %eax,%edx
f0107db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107dba:	01 d0                	add    %edx,%eax
f0107dbc:	8b 10                	mov    (%eax),%edx
f0107dbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107dc1:	01 c2                	add    %eax,%edx
f0107dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107dc6:	89 10                	mov    %edx,(%eax)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0107dc8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107dcb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0107dce:	39 c2                	cmp    %eax,%edx
f0107dd0:	7d 4a                	jge    f0107e1c <debuginfo_eip+0x43d>
		for (lline = lfun + 1;
f0107dd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107dd5:	83 c0 01             	add    $0x1,%eax
f0107dd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0107ddb:	eb 18                	jmp    f0107df5 <debuginfo_eip+0x416>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0107ddd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107de0:	8b 40 14             	mov    0x14(%eax),%eax
f0107de3:	8d 50 01             	lea    0x1(%eax),%edx
f0107de6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107de9:	89 50 14             	mov    %edx,0x14(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0107dec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107def:	83 c0 01             	add    $0x1,%eax
f0107df2:	89 45 d0             	mov    %eax,-0x30(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107df5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0107dfb:	39 c2                	cmp    %eax,%edx
f0107dfd:	7d 1d                	jge    f0107e1c <debuginfo_eip+0x43d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0107dff:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107e02:	89 c2                	mov    %eax,%edx
f0107e04:	89 d0                	mov    %edx,%eax
f0107e06:	01 c0                	add    %eax,%eax
f0107e08:	01 d0                	add    %edx,%eax
f0107e0a:	c1 e0 02             	shl    $0x2,%eax
f0107e0d:	89 c2                	mov    %eax,%edx
f0107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e12:	01 d0                	add    %edx,%eax
f0107e14:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107e18:	3c a0                	cmp    $0xa0,%al
f0107e1a:	74 c1                	je     f0107ddd <debuginfo_eip+0x3fe>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0107e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0107e21:	83 c4 54             	add    $0x54,%esp
f0107e24:	5b                   	pop    %ebx
f0107e25:	5d                   	pop    %ebp
f0107e26:	c3                   	ret    

f0107e27 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0107e27:	55                   	push   %ebp
f0107e28:	89 e5                	mov    %esp,%ebp
f0107e2a:	53                   	push   %ebx
f0107e2b:	83 ec 34             	sub    $0x34,%esp
f0107e2e:	8b 45 10             	mov    0x10(%ebp),%eax
f0107e31:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107e34:	8b 45 14             	mov    0x14(%ebp),%eax
f0107e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0107e3a:	8b 45 18             	mov    0x18(%ebp),%eax
f0107e3d:	ba 00 00 00 00       	mov    $0x0,%edx
f0107e42:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0107e45:	77 72                	ja     f0107eb9 <printnum+0x92>
f0107e47:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0107e4a:	72 05                	jb     f0107e51 <printnum+0x2a>
f0107e4c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0107e4f:	77 68                	ja     f0107eb9 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0107e51:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0107e54:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0107e57:	8b 45 18             	mov    0x18(%ebp),%eax
f0107e5a:	ba 00 00 00 00       	mov    $0x0,%edx
f0107e5f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107e63:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107e6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107e6d:	89 04 24             	mov    %eax,(%esp)
f0107e70:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107e74:	e8 57 18 00 00       	call   f01096d0 <__udivdi3>
f0107e79:	8b 4d 20             	mov    0x20(%ebp),%ecx
f0107e7c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0107e80:	89 5c 24 14          	mov    %ebx,0x14(%esp)
f0107e84:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0107e87:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0107e8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107e8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107e93:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e9a:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e9d:	89 04 24             	mov    %eax,(%esp)
f0107ea0:	e8 82 ff ff ff       	call   f0107e27 <printnum>
f0107ea5:	eb 1c                	jmp    f0107ec3 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0107ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107eae:	8b 45 20             	mov    0x20(%ebp),%eax
f0107eb1:	89 04 24             	mov    %eax,(%esp)
f0107eb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0107eb7:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0107eb9:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
f0107ebd:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f0107ec1:	7f e4                	jg     f0107ea7 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0107ec3:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0107ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0107ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107ece:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107ed1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107ed5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107ed9:	89 04 24             	mov    %eax,(%esp)
f0107edc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107ee0:	e8 1b 19 00 00       	call   f0109800 <__umoddi3>
f0107ee5:	05 48 b2 10 f0       	add    $0xf010b248,%eax
f0107eea:	0f b6 00             	movzbl (%eax),%eax
f0107eed:	0f be c0             	movsbl %al,%eax
f0107ef0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107ef7:	89 04 24             	mov    %eax,(%esp)
f0107efa:	8b 45 08             	mov    0x8(%ebp),%eax
f0107efd:	ff d0                	call   *%eax
}
f0107eff:	83 c4 34             	add    $0x34,%esp
f0107f02:	5b                   	pop    %ebx
f0107f03:	5d                   	pop    %ebp
f0107f04:	c3                   	ret    

f0107f05 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0107f05:	55                   	push   %ebp
f0107f06:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0107f08:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0107f0c:	7e 14                	jle    f0107f22 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f0107f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f11:	8b 00                	mov    (%eax),%eax
f0107f13:	8d 48 08             	lea    0x8(%eax),%ecx
f0107f16:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f19:	89 0a                	mov    %ecx,(%edx)
f0107f1b:	8b 50 04             	mov    0x4(%eax),%edx
f0107f1e:	8b 00                	mov    (%eax),%eax
f0107f20:	eb 30                	jmp    f0107f52 <getuint+0x4d>
	else if (lflag)
f0107f22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107f26:	74 16                	je     f0107f3e <getuint+0x39>
		return va_arg(*ap, unsigned long);
f0107f28:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f2b:	8b 00                	mov    (%eax),%eax
f0107f2d:	8d 48 04             	lea    0x4(%eax),%ecx
f0107f30:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f33:	89 0a                	mov    %ecx,(%edx)
f0107f35:	8b 00                	mov    (%eax),%eax
f0107f37:	ba 00 00 00 00       	mov    $0x0,%edx
f0107f3c:	eb 14                	jmp    f0107f52 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
f0107f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f41:	8b 00                	mov    (%eax),%eax
f0107f43:	8d 48 04             	lea    0x4(%eax),%ecx
f0107f46:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f49:	89 0a                	mov    %ecx,(%edx)
f0107f4b:	8b 00                	mov    (%eax),%eax
f0107f4d:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0107f52:	5d                   	pop    %ebp
f0107f53:	c3                   	ret    

f0107f54 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0107f54:	55                   	push   %ebp
f0107f55:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0107f57:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0107f5b:	7e 14                	jle    f0107f71 <getint+0x1d>
		return va_arg(*ap, long long);
f0107f5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f60:	8b 00                	mov    (%eax),%eax
f0107f62:	8d 48 08             	lea    0x8(%eax),%ecx
f0107f65:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f68:	89 0a                	mov    %ecx,(%edx)
f0107f6a:	8b 50 04             	mov    0x4(%eax),%edx
f0107f6d:	8b 00                	mov    (%eax),%eax
f0107f6f:	eb 28                	jmp    f0107f99 <getint+0x45>
	else if (lflag)
f0107f71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107f75:	74 12                	je     f0107f89 <getint+0x35>
		return va_arg(*ap, long);
f0107f77:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f7a:	8b 00                	mov    (%eax),%eax
f0107f7c:	8d 48 04             	lea    0x4(%eax),%ecx
f0107f7f:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f82:	89 0a                	mov    %ecx,(%edx)
f0107f84:	8b 00                	mov    (%eax),%eax
f0107f86:	99                   	cltd   
f0107f87:	eb 10                	jmp    f0107f99 <getint+0x45>
	else
		return va_arg(*ap, int);
f0107f89:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f8c:	8b 00                	mov    (%eax),%eax
f0107f8e:	8d 48 04             	lea    0x4(%eax),%ecx
f0107f91:	8b 55 08             	mov    0x8(%ebp),%edx
f0107f94:	89 0a                	mov    %ecx,(%edx)
f0107f96:	8b 00                	mov    (%eax),%eax
f0107f98:	99                   	cltd   
}
f0107f99:	5d                   	pop    %ebp
f0107f9a:	c3                   	ret    

f0107f9b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0107f9b:	55                   	push   %ebp
f0107f9c:	89 e5                	mov    %esp,%ebp
f0107f9e:	56                   	push   %esi
f0107f9f:	53                   	push   %ebx
f0107fa0:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0107fa3:	eb 18                	jmp    f0107fbd <vprintfmt+0x22>
			if (ch == '\0')
f0107fa5:	85 db                	test   %ebx,%ebx
f0107fa7:	75 05                	jne    f0107fae <vprintfmt+0x13>
				return;
f0107fa9:	e9 cc 03 00 00       	jmp    f010837a <vprintfmt+0x3df>
			putch(ch, putdat);
f0107fae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107fb5:	89 1c 24             	mov    %ebx,(%esp)
f0107fb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0107fbb:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0107fbd:	8b 45 10             	mov    0x10(%ebp),%eax
f0107fc0:	8d 50 01             	lea    0x1(%eax),%edx
f0107fc3:	89 55 10             	mov    %edx,0x10(%ebp)
f0107fc6:	0f b6 00             	movzbl (%eax),%eax
f0107fc9:	0f b6 d8             	movzbl %al,%ebx
f0107fcc:	83 fb 25             	cmp    $0x25,%ebx
f0107fcf:	75 d4                	jne    f0107fa5 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0107fd1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f0107fd5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f0107fdc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0107fe3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f0107fea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0107ff1:	8b 45 10             	mov    0x10(%ebp),%eax
f0107ff4:	8d 50 01             	lea    0x1(%eax),%edx
f0107ff7:	89 55 10             	mov    %edx,0x10(%ebp)
f0107ffa:	0f b6 00             	movzbl (%eax),%eax
f0107ffd:	0f b6 d8             	movzbl %al,%ebx
f0108000:	8d 43 dd             	lea    -0x23(%ebx),%eax
f0108003:	83 f8 55             	cmp    $0x55,%eax
f0108006:	0f 87 3d 03 00 00    	ja     f0108349 <vprintfmt+0x3ae>
f010800c:	8b 04 85 6c b2 10 f0 	mov    -0xfef4d94(,%eax,4),%eax
f0108013:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f0108015:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f0108019:	eb d6                	jmp    f0107ff1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010801b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f010801f:	eb d0                	jmp    f0107ff1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0108021:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f0108028:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010802b:	89 d0                	mov    %edx,%eax
f010802d:	c1 e0 02             	shl    $0x2,%eax
f0108030:	01 d0                	add    %edx,%eax
f0108032:	01 c0                	add    %eax,%eax
f0108034:	01 d8                	add    %ebx,%eax
f0108036:	83 e8 30             	sub    $0x30,%eax
f0108039:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f010803c:	8b 45 10             	mov    0x10(%ebp),%eax
f010803f:	0f b6 00             	movzbl (%eax),%eax
f0108042:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f0108045:	83 fb 2f             	cmp    $0x2f,%ebx
f0108048:	7e 0b                	jle    f0108055 <vprintfmt+0xba>
f010804a:	83 fb 39             	cmp    $0x39,%ebx
f010804d:	7f 06                	jg     f0108055 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010804f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0108053:	eb d3                	jmp    f0108028 <vprintfmt+0x8d>
			goto process_precision;
f0108055:	eb 33                	jmp    f010808a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
f0108057:	8b 45 14             	mov    0x14(%ebp),%eax
f010805a:	8d 50 04             	lea    0x4(%eax),%edx
f010805d:	89 55 14             	mov    %edx,0x14(%ebp)
f0108060:	8b 00                	mov    (%eax),%eax
f0108062:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f0108065:	eb 23                	jmp    f010808a <vprintfmt+0xef>

		case '.':
			if (width < 0)
f0108067:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010806b:	79 0c                	jns    f0108079 <vprintfmt+0xde>
				width = 0;
f010806d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f0108074:	e9 78 ff ff ff       	jmp    f0107ff1 <vprintfmt+0x56>
f0108079:	e9 73 ff ff ff       	jmp    f0107ff1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
f010807e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0108085:	e9 67 ff ff ff       	jmp    f0107ff1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
f010808a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010808e:	79 12                	jns    f01080a2 <vprintfmt+0x107>
				width = precision, precision = -1;
f0108090:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0108093:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0108096:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f010809d:	e9 4f ff ff ff       	jmp    f0107ff1 <vprintfmt+0x56>
f01080a2:	e9 4a ff ff ff       	jmp    f0107ff1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01080a7:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
f01080ab:	e9 41 ff ff ff       	jmp    f0107ff1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01080b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01080b3:	8d 50 04             	lea    0x4(%eax),%edx
f01080b6:	89 55 14             	mov    %edx,0x14(%ebp)
f01080b9:	8b 00                	mov    (%eax),%eax
f01080bb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01080be:	89 54 24 04          	mov    %edx,0x4(%esp)
f01080c2:	89 04 24             	mov    %eax,(%esp)
f01080c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01080c8:	ff d0                	call   *%eax
			break;
f01080ca:	e9 a5 02 00 00       	jmp    f0108374 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01080cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01080d2:	8d 50 04             	lea    0x4(%eax),%edx
f01080d5:	89 55 14             	mov    %edx,0x14(%ebp)
f01080d8:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f01080da:	85 db                	test   %ebx,%ebx
f01080dc:	79 02                	jns    f01080e0 <vprintfmt+0x145>
				err = -err;
f01080de:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01080e0:	83 fb 09             	cmp    $0x9,%ebx
f01080e3:	7f 0b                	jg     f01080f0 <vprintfmt+0x155>
f01080e5:	8b 34 9d 20 b2 10 f0 	mov    -0xfef4de0(,%ebx,4),%esi
f01080ec:	85 f6                	test   %esi,%esi
f01080ee:	75 23                	jne    f0108113 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f01080f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01080f4:	c7 44 24 08 59 b2 10 	movl   $0xf010b259,0x8(%esp)
f01080fb:	f0 
f01080fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01080ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108103:	8b 45 08             	mov    0x8(%ebp),%eax
f0108106:	89 04 24             	mov    %eax,(%esp)
f0108109:	e8 73 02 00 00       	call   f0108381 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
f010810e:	e9 61 02 00 00       	jmp    f0108374 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0108113:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0108117:	c7 44 24 08 62 b2 10 	movl   $0xf010b262,0x8(%esp)
f010811e:	f0 
f010811f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108122:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108126:	8b 45 08             	mov    0x8(%ebp),%eax
f0108129:	89 04 24             	mov    %eax,(%esp)
f010812c:	e8 50 02 00 00       	call   f0108381 <printfmt>
			break;
f0108131:	e9 3e 02 00 00       	jmp    f0108374 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0108136:	8b 45 14             	mov    0x14(%ebp),%eax
f0108139:	8d 50 04             	lea    0x4(%eax),%edx
f010813c:	89 55 14             	mov    %edx,0x14(%ebp)
f010813f:	8b 30                	mov    (%eax),%esi
f0108141:	85 f6                	test   %esi,%esi
f0108143:	75 05                	jne    f010814a <vprintfmt+0x1af>
				p = "(null)";
f0108145:	be 65 b2 10 f0       	mov    $0xf010b265,%esi
			if (width > 0 && padc != '-')
f010814a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010814e:	7e 37                	jle    f0108187 <vprintfmt+0x1ec>
f0108150:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f0108154:	74 31                	je     f0108187 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
f0108156:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0108159:	89 44 24 04          	mov    %eax,0x4(%esp)
f010815d:	89 34 24             	mov    %esi,(%esp)
f0108160:	e8 26 04 00 00       	call   f010858b <strnlen>
f0108165:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f0108168:	eb 17                	jmp    f0108181 <vprintfmt+0x1e6>
					putch(padc, putdat);
f010816a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f010816e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108171:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108175:	89 04 24             	mov    %eax,(%esp)
f0108178:	8b 45 08             	mov    0x8(%ebp),%eax
f010817b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010817d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0108181:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0108185:	7f e3                	jg     f010816a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0108187:	eb 38                	jmp    f01081c1 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
f0108189:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010818d:	74 1f                	je     f01081ae <vprintfmt+0x213>
f010818f:	83 fb 1f             	cmp    $0x1f,%ebx
f0108192:	7e 05                	jle    f0108199 <vprintfmt+0x1fe>
f0108194:	83 fb 7e             	cmp    $0x7e,%ebx
f0108197:	7e 15                	jle    f01081ae <vprintfmt+0x213>
					putch('?', putdat);
f0108199:	8b 45 0c             	mov    0xc(%ebp),%eax
f010819c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01081a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01081a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01081aa:	ff d0                	call   *%eax
f01081ac:	eb 0f                	jmp    f01081bd <vprintfmt+0x222>
				else
					putch(ch, putdat);
f01081ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01081b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01081b5:	89 1c 24             	mov    %ebx,(%esp)
f01081b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01081bb:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01081bd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01081c1:	89 f0                	mov    %esi,%eax
f01081c3:	8d 70 01             	lea    0x1(%eax),%esi
f01081c6:	0f b6 00             	movzbl (%eax),%eax
f01081c9:	0f be d8             	movsbl %al,%ebx
f01081cc:	85 db                	test   %ebx,%ebx
f01081ce:	74 10                	je     f01081e0 <vprintfmt+0x245>
f01081d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01081d4:	78 b3                	js     f0108189 <vprintfmt+0x1ee>
f01081d6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01081da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01081de:	79 a9                	jns    f0108189 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01081e0:	eb 17                	jmp    f01081f9 <vprintfmt+0x25e>
				putch(' ', putdat);
f01081e2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01081e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01081e9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01081f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01081f3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01081f5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01081f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01081fd:	7f e3                	jg     f01081e2 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
f01081ff:	e9 70 01 00 00       	jmp    f0108374 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0108204:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108207:	89 44 24 04          	mov    %eax,0x4(%esp)
f010820b:	8d 45 14             	lea    0x14(%ebp),%eax
f010820e:	89 04 24             	mov    %eax,(%esp)
f0108211:	e8 3e fd ff ff       	call   f0107f54 <getint>
f0108216:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108219:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f010821c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010821f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0108222:	85 d2                	test   %edx,%edx
f0108224:	79 26                	jns    f010824c <vprintfmt+0x2b1>
				putch('-', putdat);
f0108226:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108229:	89 44 24 04          	mov    %eax,0x4(%esp)
f010822d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0108234:	8b 45 08             	mov    0x8(%ebp),%eax
f0108237:	ff d0                	call   *%eax
				num = -(long long) num;
f0108239:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010823c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010823f:	f7 d8                	neg    %eax
f0108241:	83 d2 00             	adc    $0x0,%edx
f0108244:	f7 da                	neg    %edx
f0108246:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108249:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f010824c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0108253:	e9 a8 00 00 00       	jmp    f0108300 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0108258:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010825b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010825f:	8d 45 14             	lea    0x14(%ebp),%eax
f0108262:	89 04 24             	mov    %eax,(%esp)
f0108265:	e8 9b fc ff ff       	call   f0107f05 <getuint>
f010826a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010826d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f0108270:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0108277:	e9 84 00 00 00       	jmp    f0108300 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010827c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010827f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108283:	8d 45 14             	lea    0x14(%ebp),%eax
f0108286:	89 04 24             	mov    %eax,(%esp)
f0108289:	e8 77 fc ff ff       	call   f0107f05 <getuint>
f010828e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108291:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
f0108294:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
f010829b:	eb 63                	jmp    f0108300 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010829d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01082a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01082a4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01082ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01082ae:	ff d0                	call   *%eax
			putch('x', putdat);
f01082b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01082b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01082b7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01082be:	8b 45 08             	mov    0x8(%ebp),%eax
f01082c1:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01082c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01082c6:	8d 50 04             	lea    0x4(%eax),%edx
f01082c9:	89 55 14             	mov    %edx,0x14(%ebp)
f01082cc:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01082ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01082d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01082d8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f01082df:	eb 1f                	jmp    f0108300 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01082e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01082e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01082e8:	8d 45 14             	lea    0x14(%ebp),%eax
f01082eb:	89 04 24             	mov    %eax,(%esp)
f01082ee:	e8 12 fc ff ff       	call   f0107f05 <getuint>
f01082f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01082f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f01082f9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f0108300:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f0108304:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108307:	89 54 24 18          	mov    %edx,0x18(%esp)
f010830b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010830e:	89 54 24 14          	mov    %edx,0x14(%esp)
f0108312:	89 44 24 10          	mov    %eax,0x10(%esp)
f0108316:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108319:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010831c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108320:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0108324:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108327:	89 44 24 04          	mov    %eax,0x4(%esp)
f010832b:	8b 45 08             	mov    0x8(%ebp),%eax
f010832e:	89 04 24             	mov    %eax,(%esp)
f0108331:	e8 f1 fa ff ff       	call   f0107e27 <printnum>
			break;
f0108336:	eb 3c                	jmp    f0108374 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0108338:	8b 45 0c             	mov    0xc(%ebp),%eax
f010833b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010833f:	89 1c 24             	mov    %ebx,(%esp)
f0108342:	8b 45 08             	mov    0x8(%ebp),%eax
f0108345:	ff d0                	call   *%eax
			break;
f0108347:	eb 2b                	jmp    f0108374 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0108349:	8b 45 0c             	mov    0xc(%ebp),%eax
f010834c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108350:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0108357:	8b 45 08             	mov    0x8(%ebp),%eax
f010835a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
f010835c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f0108360:	eb 04                	jmp    f0108366 <vprintfmt+0x3cb>
f0108362:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f0108366:	8b 45 10             	mov    0x10(%ebp),%eax
f0108369:	83 e8 01             	sub    $0x1,%eax
f010836c:	0f b6 00             	movzbl (%eax),%eax
f010836f:	3c 25                	cmp    $0x25,%al
f0108371:	75 ef                	jne    f0108362 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
f0108373:	90                   	nop
		}
	}
f0108374:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0108375:	e9 43 fc ff ff       	jmp    f0107fbd <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f010837a:	83 c4 40             	add    $0x40,%esp
f010837d:	5b                   	pop    %ebx
f010837e:	5e                   	pop    %esi
f010837f:	5d                   	pop    %ebp
f0108380:	c3                   	ret    

f0108381 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0108381:	55                   	push   %ebp
f0108382:	89 e5                	mov    %esp,%ebp
f0108384:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f0108387:	8d 45 14             	lea    0x14(%ebp),%eax
f010838a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f010838d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108390:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108394:	8b 45 10             	mov    0x10(%ebp),%eax
f0108397:	89 44 24 08          	mov    %eax,0x8(%esp)
f010839b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010839e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01083a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01083a5:	89 04 24             	mov    %eax,(%esp)
f01083a8:	e8 ee fb ff ff       	call   f0107f9b <vprintfmt>
	va_end(ap);
}
f01083ad:	c9                   	leave  
f01083ae:	c3                   	ret    

f01083af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01083af:	55                   	push   %ebp
f01083b0:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f01083b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083b5:	8b 40 08             	mov    0x8(%eax),%eax
f01083b8:	8d 50 01             	lea    0x1(%eax),%edx
f01083bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083be:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f01083c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083c4:	8b 10                	mov    (%eax),%edx
f01083c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083c9:	8b 40 04             	mov    0x4(%eax),%eax
f01083cc:	39 c2                	cmp    %eax,%edx
f01083ce:	73 12                	jae    f01083e2 <sprintputch+0x33>
		*b->buf++ = ch;
f01083d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083d3:	8b 00                	mov    (%eax),%eax
f01083d5:	8d 48 01             	lea    0x1(%eax),%ecx
f01083d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01083db:	89 0a                	mov    %ecx,(%edx)
f01083dd:	8b 55 08             	mov    0x8(%ebp),%edx
f01083e0:	88 10                	mov    %dl,(%eax)
}
f01083e2:	5d                   	pop    %ebp
f01083e3:	c3                   	ret    

f01083e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01083e4:	55                   	push   %ebp
f01083e5:	89 e5                	mov    %esp,%ebp
f01083e7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f01083ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01083ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01083f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01083f3:	8d 50 ff             	lea    -0x1(%eax),%edx
f01083f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01083f9:	01 d0                	add    %edx,%eax
f01083fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01083fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0108405:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0108409:	74 06                	je     f0108411 <vsnprintf+0x2d>
f010840b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010840f:	7f 07                	jg     f0108418 <vsnprintf+0x34>
		return -E_INVAL;
f0108411:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0108416:	eb 2a                	jmp    f0108442 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0108418:	8b 45 14             	mov    0x14(%ebp),%eax
f010841b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010841f:	8b 45 10             	mov    0x10(%ebp),%eax
f0108422:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108426:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0108429:	89 44 24 04          	mov    %eax,0x4(%esp)
f010842d:	c7 04 24 af 83 10 f0 	movl   $0xf01083af,(%esp)
f0108434:	e8 62 fb ff ff       	call   f0107f9b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0108439:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010843c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010843f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0108442:	c9                   	leave  
f0108443:	c3                   	ret    

f0108444 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0108444:	55                   	push   %ebp
f0108445:	89 e5                	mov    %esp,%ebp
f0108447:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010844a:	8d 45 14             	lea    0x14(%ebp),%eax
f010844d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f0108450:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108453:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108457:	8b 45 10             	mov    0x10(%ebp),%eax
f010845a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010845e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108461:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108465:	8b 45 08             	mov    0x8(%ebp),%eax
f0108468:	89 04 24             	mov    %eax,(%esp)
f010846b:	e8 74 ff ff ff       	call   f01083e4 <vsnprintf>
f0108470:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
f0108473:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0108476:	c9                   	leave  
f0108477:	c3                   	ret    

f0108478 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0108478:	55                   	push   %ebp
f0108479:	89 e5                	mov    %esp,%ebp
f010847b:	83 ec 28             	sub    $0x28,%esp
	int i, c, echoing;

	if (prompt != NULL)
f010847e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0108482:	74 13                	je     f0108497 <readline+0x1f>
		cprintf("%s", prompt);
f0108484:	8b 45 08             	mov    0x8(%ebp),%eax
f0108487:	89 44 24 04          	mov    %eax,0x4(%esp)
f010848b:	c7 04 24 c4 b3 10 f0 	movl   $0xf010b3c4,(%esp)
f0108492:	e8 b5 ca ff ff       	call   f0104f4c <cprintf>

	i = 0;
f0108497:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// echoing = iscons(0);
	echoing = 1;
f010849e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	while (1) {
		c = getchar();
f01084a5:	e8 09 87 ff ff       	call   f0100bb3 <getchar>
f01084aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
f01084ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01084b1:	79 1d                	jns    f01084d0 <readline+0x58>
			cprintf("read error: %e\n", c);
f01084b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01084b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01084ba:	c7 04 24 c7 b3 10 f0 	movl   $0xf010b3c7,(%esp)
f01084c1:	e8 86 ca ff ff       	call   f0104f4c <cprintf>
			return NULL;
f01084c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01084cb:	e9 93 00 00 00       	jmp    f0108563 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01084d0:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
f01084d4:	74 06                	je     f01084dc <readline+0x64>
f01084d6:	83 7d ec 7f          	cmpl   $0x7f,-0x14(%ebp)
f01084da:	75 1e                	jne    f01084fa <readline+0x82>
f01084dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01084e0:	7e 18                	jle    f01084fa <readline+0x82>
			if (echoing)
f01084e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01084e6:	74 0c                	je     f01084f4 <readline+0x7c>
				cputchar('\b');
f01084e8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01084ef:	e8 ac 86 ff ff       	call   f0100ba0 <cputchar>
			i--;
f01084f4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
f01084f8:	eb 64                	jmp    f010855e <readline+0xe6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01084fa:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
f01084fe:	7e 2e                	jle    f010852e <readline+0xb6>
f0108500:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f0108507:	7f 25                	jg     f010852e <readline+0xb6>
			if (echoing)
f0108509:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010850d:	74 0b                	je     f010851a <readline+0xa2>
				cputchar(c);
f010850f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108512:	89 04 24             	mov    %eax,(%esp)
f0108515:	e8 86 86 ff ff       	call   f0100ba0 <cputchar>
			buf[i++] = c;
f010851a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010851d:	8d 50 01             	lea    0x1(%eax),%edx
f0108520:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0108523:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108526:	88 90 e0 66 29 f0    	mov    %dl,-0xfd69920(%eax)
f010852c:	eb 30                	jmp    f010855e <readline+0xe6>
		} else if (c == '\n' || c == '\r') {
f010852e:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
f0108532:	74 06                	je     f010853a <readline+0xc2>
f0108534:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
f0108538:	75 24                	jne    f010855e <readline+0xe6>
			if (echoing)
f010853a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010853e:	74 0c                	je     f010854c <readline+0xd4>
				cputchar('\n');
f0108540:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0108547:	e8 54 86 ff ff       	call   f0100ba0 <cputchar>
			buf[i] = 0;
f010854c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010854f:	05 e0 66 29 f0       	add    $0xf02966e0,%eax
f0108554:	c6 00 00             	movb   $0x0,(%eax)
			return buf;
f0108557:	b8 e0 66 29 f0       	mov    $0xf02966e0,%eax
f010855c:	eb 05                	jmp    f0108563 <readline+0xeb>
		}
	}
f010855e:	e9 42 ff ff ff       	jmp    f01084a5 <readline+0x2d>
}
f0108563:	c9                   	leave  
f0108564:	c3                   	ret    

f0108565 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0108565:	55                   	push   %ebp
f0108566:	89 e5                	mov    %esp,%ebp
f0108568:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f010856b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0108572:	eb 08                	jmp    f010857c <strlen+0x17>
		n++;
f0108574:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0108578:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f010857c:	8b 45 08             	mov    0x8(%ebp),%eax
f010857f:	0f b6 00             	movzbl (%eax),%eax
f0108582:	84 c0                	test   %al,%al
f0108584:	75 ee                	jne    f0108574 <strlen+0xf>
		n++;
	return n;
f0108586:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0108589:	c9                   	leave  
f010858a:	c3                   	ret    

f010858b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010858b:	55                   	push   %ebp
f010858c:	89 e5                	mov    %esp,%ebp
f010858e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0108591:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0108598:	eb 0c                	jmp    f01085a6 <strnlen+0x1b>
		n++;
f010859a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010859e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01085a2:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
f01085a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01085aa:	74 0a                	je     f01085b6 <strnlen+0x2b>
f01085ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01085af:	0f b6 00             	movzbl (%eax),%eax
f01085b2:	84 c0                	test   %al,%al
f01085b4:	75 e4                	jne    f010859a <strnlen+0xf>
		n++;
	return n;
f01085b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01085b9:	c9                   	leave  
f01085ba:	c3                   	ret    

f01085bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01085bb:	55                   	push   %ebp
f01085bc:	89 e5                	mov    %esp,%ebp
f01085be:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f01085c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01085c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f01085c7:	90                   	nop
f01085c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01085cb:	8d 50 01             	lea    0x1(%eax),%edx
f01085ce:	89 55 08             	mov    %edx,0x8(%ebp)
f01085d1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01085d4:	8d 4a 01             	lea    0x1(%edx),%ecx
f01085d7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f01085da:	0f b6 12             	movzbl (%edx),%edx
f01085dd:	88 10                	mov    %dl,(%eax)
f01085df:	0f b6 00             	movzbl (%eax),%eax
f01085e2:	84 c0                	test   %al,%al
f01085e4:	75 e2                	jne    f01085c8 <strcpy+0xd>
		/* do nothing */;
	return ret;
f01085e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01085e9:	c9                   	leave  
f01085ea:	c3                   	ret    

f01085eb <strcat>:

char *
strcat(char *dst, const char *src)
{
f01085eb:	55                   	push   %ebp
f01085ec:	89 e5                	mov    %esp,%ebp
f01085ee:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
f01085f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01085f4:	89 04 24             	mov    %eax,(%esp)
f01085f7:	e8 69 ff ff ff       	call   f0108565 <strlen>
f01085fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
f01085ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0108602:	8b 45 08             	mov    0x8(%ebp),%eax
f0108605:	01 c2                	add    %eax,%edx
f0108607:	8b 45 0c             	mov    0xc(%ebp),%eax
f010860a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010860e:	89 14 24             	mov    %edx,(%esp)
f0108611:	e8 a5 ff ff ff       	call   f01085bb <strcpy>
	return dst;
f0108616:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108619:	c9                   	leave  
f010861a:	c3                   	ret    

f010861b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010861b:	55                   	push   %ebp
f010861c:	89 e5                	mov    %esp,%ebp
f010861e:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
f0108621:	8b 45 08             	mov    0x8(%ebp),%eax
f0108624:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f0108627:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010862e:	eb 23                	jmp    f0108653 <strncpy+0x38>
		*dst++ = *src;
f0108630:	8b 45 08             	mov    0x8(%ebp),%eax
f0108633:	8d 50 01             	lea    0x1(%eax),%edx
f0108636:	89 55 08             	mov    %edx,0x8(%ebp)
f0108639:	8b 55 0c             	mov    0xc(%ebp),%edx
f010863c:	0f b6 12             	movzbl (%edx),%edx
f010863f:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0108641:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108644:	0f b6 00             	movzbl (%eax),%eax
f0108647:	84 c0                	test   %al,%al
f0108649:	74 04                	je     f010864f <strncpy+0x34>
			src++;
f010864b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010864f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108653:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108656:	3b 45 10             	cmp    0x10(%ebp),%eax
f0108659:	72 d5                	jb     f0108630 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f010865b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f010865e:	c9                   	leave  
f010865f:	c3                   	ret    

f0108660 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0108660:	55                   	push   %ebp
f0108661:	89 e5                	mov    %esp,%ebp
f0108663:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f0108666:	8b 45 08             	mov    0x8(%ebp),%eax
f0108669:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f010866c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108670:	74 33                	je     f01086a5 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0108672:	eb 17                	jmp    f010868b <strlcpy+0x2b>
			*dst++ = *src++;
f0108674:	8b 45 08             	mov    0x8(%ebp),%eax
f0108677:	8d 50 01             	lea    0x1(%eax),%edx
f010867a:	89 55 08             	mov    %edx,0x8(%ebp)
f010867d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108680:	8d 4a 01             	lea    0x1(%edx),%ecx
f0108683:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f0108686:	0f b6 12             	movzbl (%edx),%edx
f0108689:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010868b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f010868f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108693:	74 0a                	je     f010869f <strlcpy+0x3f>
f0108695:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108698:	0f b6 00             	movzbl (%eax),%eax
f010869b:	84 c0                	test   %al,%al
f010869d:	75 d5                	jne    f0108674 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f010869f:	8b 45 08             	mov    0x8(%ebp),%eax
f01086a2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01086a5:	8b 55 08             	mov    0x8(%ebp),%edx
f01086a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01086ab:	29 c2                	sub    %eax,%edx
f01086ad:	89 d0                	mov    %edx,%eax
}
f01086af:	c9                   	leave  
f01086b0:	c3                   	ret    

f01086b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01086b1:	55                   	push   %ebp
f01086b2:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f01086b4:	eb 08                	jmp    f01086be <strcmp+0xd>
		p++, q++;
f01086b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01086ba:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01086be:	8b 45 08             	mov    0x8(%ebp),%eax
f01086c1:	0f b6 00             	movzbl (%eax),%eax
f01086c4:	84 c0                	test   %al,%al
f01086c6:	74 10                	je     f01086d8 <strcmp+0x27>
f01086c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01086cb:	0f b6 10             	movzbl (%eax),%edx
f01086ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01086d1:	0f b6 00             	movzbl (%eax),%eax
f01086d4:	38 c2                	cmp    %al,%dl
f01086d6:	74 de                	je     f01086b6 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01086d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01086db:	0f b6 00             	movzbl (%eax),%eax
f01086de:	0f b6 d0             	movzbl %al,%edx
f01086e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01086e4:	0f b6 00             	movzbl (%eax),%eax
f01086e7:	0f b6 c0             	movzbl %al,%eax
f01086ea:	29 c2                	sub    %eax,%edx
f01086ec:	89 d0                	mov    %edx,%eax
}
f01086ee:	5d                   	pop    %ebp
f01086ef:	c3                   	ret    

f01086f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01086f0:	55                   	push   %ebp
f01086f1:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f01086f3:	eb 0c                	jmp    f0108701 <strncmp+0x11>
		n--, p++, q++;
f01086f5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01086f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01086fd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0108701:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108705:	74 1a                	je     f0108721 <strncmp+0x31>
f0108707:	8b 45 08             	mov    0x8(%ebp),%eax
f010870a:	0f b6 00             	movzbl (%eax),%eax
f010870d:	84 c0                	test   %al,%al
f010870f:	74 10                	je     f0108721 <strncmp+0x31>
f0108711:	8b 45 08             	mov    0x8(%ebp),%eax
f0108714:	0f b6 10             	movzbl (%eax),%edx
f0108717:	8b 45 0c             	mov    0xc(%ebp),%eax
f010871a:	0f b6 00             	movzbl (%eax),%eax
f010871d:	38 c2                	cmp    %al,%dl
f010871f:	74 d4                	je     f01086f5 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f0108721:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108725:	75 07                	jne    f010872e <strncmp+0x3e>
		return 0;
f0108727:	b8 00 00 00 00       	mov    $0x0,%eax
f010872c:	eb 16                	jmp    f0108744 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010872e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108731:	0f b6 00             	movzbl (%eax),%eax
f0108734:	0f b6 d0             	movzbl %al,%edx
f0108737:	8b 45 0c             	mov    0xc(%ebp),%eax
f010873a:	0f b6 00             	movzbl (%eax),%eax
f010873d:	0f b6 c0             	movzbl %al,%eax
f0108740:	29 c2                	sub    %eax,%edx
f0108742:	89 d0                	mov    %edx,%eax
}
f0108744:	5d                   	pop    %ebp
f0108745:	c3                   	ret    

f0108746 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0108746:	55                   	push   %ebp
f0108747:	89 e5                	mov    %esp,%ebp
f0108749:	83 ec 04             	sub    $0x4,%esp
f010874c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010874f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0108752:	eb 14                	jmp    f0108768 <strchr+0x22>
		if (*s == c)
f0108754:	8b 45 08             	mov    0x8(%ebp),%eax
f0108757:	0f b6 00             	movzbl (%eax),%eax
f010875a:	3a 45 fc             	cmp    -0x4(%ebp),%al
f010875d:	75 05                	jne    f0108764 <strchr+0x1e>
			return (char *) s;
f010875f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108762:	eb 13                	jmp    f0108777 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0108764:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108768:	8b 45 08             	mov    0x8(%ebp),%eax
f010876b:	0f b6 00             	movzbl (%eax),%eax
f010876e:	84 c0                	test   %al,%al
f0108770:	75 e2                	jne    f0108754 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f0108772:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108777:	c9                   	leave  
f0108778:	c3                   	ret    

f0108779 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0108779:	55                   	push   %ebp
f010877a:	89 e5                	mov    %esp,%ebp
f010877c:	83 ec 04             	sub    $0x4,%esp
f010877f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108782:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0108785:	eb 11                	jmp    f0108798 <strfind+0x1f>
		if (*s == c)
f0108787:	8b 45 08             	mov    0x8(%ebp),%eax
f010878a:	0f b6 00             	movzbl (%eax),%eax
f010878d:	3a 45 fc             	cmp    -0x4(%ebp),%al
f0108790:	75 02                	jne    f0108794 <strfind+0x1b>
			break;
f0108792:	eb 0e                	jmp    f01087a2 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0108794:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108798:	8b 45 08             	mov    0x8(%ebp),%eax
f010879b:	0f b6 00             	movzbl (%eax),%eax
f010879e:	84 c0                	test   %al,%al
f01087a0:	75 e5                	jne    f0108787 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
f01087a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01087a5:	c9                   	leave  
f01087a6:	c3                   	ret    

f01087a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01087a7:	55                   	push   %ebp
f01087a8:	89 e5                	mov    %esp,%ebp
f01087aa:	57                   	push   %edi
	char *p;

	if (n == 0)
f01087ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01087af:	75 05                	jne    f01087b6 <memset+0xf>
		return v;
f01087b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01087b4:	eb 5c                	jmp    f0108812 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
f01087b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01087b9:	83 e0 03             	and    $0x3,%eax
f01087bc:	85 c0                	test   %eax,%eax
f01087be:	75 41                	jne    f0108801 <memset+0x5a>
f01087c0:	8b 45 10             	mov    0x10(%ebp),%eax
f01087c3:	83 e0 03             	and    $0x3,%eax
f01087c6:	85 c0                	test   %eax,%eax
f01087c8:	75 37                	jne    f0108801 <memset+0x5a>
		c &= 0xFF;
f01087ca:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01087d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01087d4:	c1 e0 18             	shl    $0x18,%eax
f01087d7:	89 c2                	mov    %eax,%edx
f01087d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01087dc:	c1 e0 10             	shl    $0x10,%eax
f01087df:	09 c2                	or     %eax,%edx
f01087e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01087e4:	c1 e0 08             	shl    $0x8,%eax
f01087e7:	09 d0                	or     %edx,%eax
f01087e9:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01087ec:	8b 45 10             	mov    0x10(%ebp),%eax
f01087ef:	c1 e8 02             	shr    $0x2,%eax
f01087f2:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01087f4:	8b 55 08             	mov    0x8(%ebp),%edx
f01087f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01087fa:	89 d7                	mov    %edx,%edi
f01087fc:	fc                   	cld    
f01087fd:	f3 ab                	rep stos %eax,%es:(%edi)
f01087ff:	eb 0e                	jmp    f010880f <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0108801:	8b 55 08             	mov    0x8(%ebp),%edx
f0108804:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108807:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010880a:	89 d7                	mov    %edx,%edi
f010880c:	fc                   	cld    
f010880d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
f010880f:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108812:	5f                   	pop    %edi
f0108813:	5d                   	pop    %ebp
f0108814:	c3                   	ret    

f0108815 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0108815:	55                   	push   %ebp
f0108816:	89 e5                	mov    %esp,%ebp
f0108818:	57                   	push   %edi
f0108819:	56                   	push   %esi
f010881a:	53                   	push   %ebx
f010881b:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f010881e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108821:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
f0108824:	8b 45 08             	mov    0x8(%ebp),%eax
f0108827:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
f010882a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010882d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0108830:	73 6d                	jae    f010889f <memmove+0x8a>
f0108832:	8b 45 10             	mov    0x10(%ebp),%eax
f0108835:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108838:	01 d0                	add    %edx,%eax
f010883a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f010883d:	76 60                	jbe    f010889f <memmove+0x8a>
		s += n;
f010883f:	8b 45 10             	mov    0x10(%ebp),%eax
f0108842:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
f0108845:	8b 45 10             	mov    0x10(%ebp),%eax
f0108848:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010884b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010884e:	83 e0 03             	and    $0x3,%eax
f0108851:	85 c0                	test   %eax,%eax
f0108853:	75 2f                	jne    f0108884 <memmove+0x6f>
f0108855:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108858:	83 e0 03             	and    $0x3,%eax
f010885b:	85 c0                	test   %eax,%eax
f010885d:	75 25                	jne    f0108884 <memmove+0x6f>
f010885f:	8b 45 10             	mov    0x10(%ebp),%eax
f0108862:	83 e0 03             	and    $0x3,%eax
f0108865:	85 c0                	test   %eax,%eax
f0108867:	75 1b                	jne    f0108884 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0108869:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010886c:	83 e8 04             	sub    $0x4,%eax
f010886f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108872:	83 ea 04             	sub    $0x4,%edx
f0108875:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108878:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010887b:	89 c7                	mov    %eax,%edi
f010887d:	89 d6                	mov    %edx,%esi
f010887f:	fd                   	std    
f0108880:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0108882:	eb 18                	jmp    f010889c <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0108884:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108887:	8d 50 ff             	lea    -0x1(%eax),%edx
f010888a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010888d:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0108890:	8b 45 10             	mov    0x10(%ebp),%eax
f0108893:	89 d7                	mov    %edx,%edi
f0108895:	89 de                	mov    %ebx,%esi
f0108897:	89 c1                	mov    %eax,%ecx
f0108899:	fd                   	std    
f010889a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010889c:	fc                   	cld    
f010889d:	eb 45                	jmp    f01088e4 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010889f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01088a2:	83 e0 03             	and    $0x3,%eax
f01088a5:	85 c0                	test   %eax,%eax
f01088a7:	75 2b                	jne    f01088d4 <memmove+0xbf>
f01088a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01088ac:	83 e0 03             	and    $0x3,%eax
f01088af:	85 c0                	test   %eax,%eax
f01088b1:	75 21                	jne    f01088d4 <memmove+0xbf>
f01088b3:	8b 45 10             	mov    0x10(%ebp),%eax
f01088b6:	83 e0 03             	and    $0x3,%eax
f01088b9:	85 c0                	test   %eax,%eax
f01088bb:	75 17                	jne    f01088d4 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01088bd:	8b 45 10             	mov    0x10(%ebp),%eax
f01088c0:	c1 e8 02             	shr    $0x2,%eax
f01088c3:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01088c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01088c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01088cb:	89 c7                	mov    %eax,%edi
f01088cd:	89 d6                	mov    %edx,%esi
f01088cf:	fc                   	cld    
f01088d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01088d2:	eb 10                	jmp    f01088e4 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01088d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01088d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01088da:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01088dd:	89 c7                	mov    %eax,%edi
f01088df:	89 d6                	mov    %edx,%esi
f01088e1:	fc                   	cld    
f01088e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
f01088e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01088e7:	83 c4 10             	add    $0x10,%esp
f01088ea:	5b                   	pop    %ebx
f01088eb:	5e                   	pop    %esi
f01088ec:	5f                   	pop    %edi
f01088ed:	5d                   	pop    %ebp
f01088ee:	c3                   	ret    

f01088ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01088ef:	55                   	push   %ebp
f01088f0:	89 e5                	mov    %esp,%ebp
f01088f2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01088f5:	8b 45 10             	mov    0x10(%ebp),%eax
f01088f8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01088fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01088ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108903:	8b 45 08             	mov    0x8(%ebp),%eax
f0108906:	89 04 24             	mov    %eax,(%esp)
f0108909:	e8 07 ff ff ff       	call   f0108815 <memmove>
}
f010890e:	c9                   	leave  
f010890f:	c3                   	ret    

f0108910 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0108910:	55                   	push   %ebp
f0108911:	89 e5                	mov    %esp,%ebp
f0108913:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
f0108916:	8b 45 08             	mov    0x8(%ebp),%eax
f0108919:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
f010891c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010891f:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f0108922:	eb 30                	jmp    f0108954 <memcmp+0x44>
		if (*s1 != *s2)
f0108924:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108927:	0f b6 10             	movzbl (%eax),%edx
f010892a:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010892d:	0f b6 00             	movzbl (%eax),%eax
f0108930:	38 c2                	cmp    %al,%dl
f0108932:	74 18                	je     f010894c <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
f0108934:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108937:	0f b6 00             	movzbl (%eax),%eax
f010893a:	0f b6 d0             	movzbl %al,%edx
f010893d:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108940:	0f b6 00             	movzbl (%eax),%eax
f0108943:	0f b6 c0             	movzbl %al,%eax
f0108946:	29 c2                	sub    %eax,%edx
f0108948:	89 d0                	mov    %edx,%eax
f010894a:	eb 1a                	jmp    f0108966 <memcmp+0x56>
		s1++, s2++;
f010894c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108950:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0108954:	8b 45 10             	mov    0x10(%ebp),%eax
f0108957:	8d 50 ff             	lea    -0x1(%eax),%edx
f010895a:	89 55 10             	mov    %edx,0x10(%ebp)
f010895d:	85 c0                	test   %eax,%eax
f010895f:	75 c3                	jne    f0108924 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0108961:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108966:	c9                   	leave  
f0108967:	c3                   	ret    

f0108968 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0108968:	55                   	push   %ebp
f0108969:	89 e5                	mov    %esp,%ebp
f010896b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f010896e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108971:	8b 55 08             	mov    0x8(%ebp),%edx
f0108974:	01 d0                	add    %edx,%eax
f0108976:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f0108979:	eb 13                	jmp    f010898e <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f010897b:	8b 45 08             	mov    0x8(%ebp),%eax
f010897e:	0f b6 10             	movzbl (%eax),%edx
f0108981:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108984:	38 c2                	cmp    %al,%dl
f0108986:	75 02                	jne    f010898a <memfind+0x22>
			break;
f0108988:	eb 0c                	jmp    f0108996 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010898a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f010898e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108991:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0108994:	72 e5                	jb     f010897b <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
f0108996:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108999:	c9                   	leave  
f010899a:	c3                   	ret    

f010899b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010899b:	55                   	push   %ebp
f010899c:	89 e5                	mov    %esp,%ebp
f010899e:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f01089a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f01089a8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01089af:	eb 04                	jmp    f01089b5 <strtol+0x1a>
		s++;
f01089b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01089b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01089b8:	0f b6 00             	movzbl (%eax),%eax
f01089bb:	3c 20                	cmp    $0x20,%al
f01089bd:	74 f2                	je     f01089b1 <strtol+0x16>
f01089bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01089c2:	0f b6 00             	movzbl (%eax),%eax
f01089c5:	3c 09                	cmp    $0x9,%al
f01089c7:	74 e8                	je     f01089b1 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f01089c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01089cc:	0f b6 00             	movzbl (%eax),%eax
f01089cf:	3c 2b                	cmp    $0x2b,%al
f01089d1:	75 06                	jne    f01089d9 <strtol+0x3e>
		s++;
f01089d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01089d7:	eb 15                	jmp    f01089ee <strtol+0x53>
	else if (*s == '-')
f01089d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01089dc:	0f b6 00             	movzbl (%eax),%eax
f01089df:	3c 2d                	cmp    $0x2d,%al
f01089e1:	75 0b                	jne    f01089ee <strtol+0x53>
		s++, neg = 1;
f01089e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01089e7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01089ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01089f2:	74 06                	je     f01089fa <strtol+0x5f>
f01089f4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f01089f8:	75 24                	jne    f0108a1e <strtol+0x83>
f01089fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01089fd:	0f b6 00             	movzbl (%eax),%eax
f0108a00:	3c 30                	cmp    $0x30,%al
f0108a02:	75 1a                	jne    f0108a1e <strtol+0x83>
f0108a04:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a07:	83 c0 01             	add    $0x1,%eax
f0108a0a:	0f b6 00             	movzbl (%eax),%eax
f0108a0d:	3c 78                	cmp    $0x78,%al
f0108a0f:	75 0d                	jne    f0108a1e <strtol+0x83>
		s += 2, base = 16;
f0108a11:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f0108a15:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0108a1c:	eb 2a                	jmp    f0108a48 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
f0108a1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108a22:	75 17                	jne    f0108a3b <strtol+0xa0>
f0108a24:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a27:	0f b6 00             	movzbl (%eax),%eax
f0108a2a:	3c 30                	cmp    $0x30,%al
f0108a2c:	75 0d                	jne    f0108a3b <strtol+0xa0>
		s++, base = 8;
f0108a2e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108a32:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0108a39:	eb 0d                	jmp    f0108a48 <strtol+0xad>
	else if (base == 0)
f0108a3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108a3f:	75 07                	jne    f0108a48 <strtol+0xad>
		base = 10;
f0108a41:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0108a48:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a4b:	0f b6 00             	movzbl (%eax),%eax
f0108a4e:	3c 2f                	cmp    $0x2f,%al
f0108a50:	7e 1b                	jle    f0108a6d <strtol+0xd2>
f0108a52:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a55:	0f b6 00             	movzbl (%eax),%eax
f0108a58:	3c 39                	cmp    $0x39,%al
f0108a5a:	7f 11                	jg     f0108a6d <strtol+0xd2>
			dig = *s - '0';
f0108a5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a5f:	0f b6 00             	movzbl (%eax),%eax
f0108a62:	0f be c0             	movsbl %al,%eax
f0108a65:	83 e8 30             	sub    $0x30,%eax
f0108a68:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108a6b:	eb 48                	jmp    f0108ab5 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
f0108a6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a70:	0f b6 00             	movzbl (%eax),%eax
f0108a73:	3c 60                	cmp    $0x60,%al
f0108a75:	7e 1b                	jle    f0108a92 <strtol+0xf7>
f0108a77:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a7a:	0f b6 00             	movzbl (%eax),%eax
f0108a7d:	3c 7a                	cmp    $0x7a,%al
f0108a7f:	7f 11                	jg     f0108a92 <strtol+0xf7>
			dig = *s - 'a' + 10;
f0108a81:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a84:	0f b6 00             	movzbl (%eax),%eax
f0108a87:	0f be c0             	movsbl %al,%eax
f0108a8a:	83 e8 57             	sub    $0x57,%eax
f0108a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108a90:	eb 23                	jmp    f0108ab5 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
f0108a92:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a95:	0f b6 00             	movzbl (%eax),%eax
f0108a98:	3c 40                	cmp    $0x40,%al
f0108a9a:	7e 3d                	jle    f0108ad9 <strtol+0x13e>
f0108a9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a9f:	0f b6 00             	movzbl (%eax),%eax
f0108aa2:	3c 5a                	cmp    $0x5a,%al
f0108aa4:	7f 33                	jg     f0108ad9 <strtol+0x13e>
			dig = *s - 'A' + 10;
f0108aa6:	8b 45 08             	mov    0x8(%ebp),%eax
f0108aa9:	0f b6 00             	movzbl (%eax),%eax
f0108aac:	0f be c0             	movsbl %al,%eax
f0108aaf:	83 e8 37             	sub    $0x37,%eax
f0108ab2:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0108ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108ab8:	3b 45 10             	cmp    0x10(%ebp),%eax
f0108abb:	7c 02                	jl     f0108abf <strtol+0x124>
			break;
f0108abd:	eb 1a                	jmp    f0108ad9 <strtol+0x13e>
		s++, val = (val * base) + dig;
f0108abf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108ac3:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108ac6:	0f af 45 10          	imul   0x10(%ebp),%eax
f0108aca:	89 c2                	mov    %eax,%edx
f0108acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108acf:	01 d0                	add    %edx,%eax
f0108ad1:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f0108ad4:	e9 6f ff ff ff       	jmp    f0108a48 <strtol+0xad>

	if (endptr)
f0108ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0108add:	74 08                	je     f0108ae7 <strtol+0x14c>
		*endptr = (char *) s;
f0108adf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108ae2:	8b 55 08             	mov    0x8(%ebp),%edx
f0108ae5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0108ae7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0108aeb:	74 07                	je     f0108af4 <strtol+0x159>
f0108aed:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108af0:	f7 d8                	neg    %eax
f0108af2:	eb 03                	jmp    f0108af7 <strtol+0x15c>
f0108af4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0108af7:	c9                   	leave  
f0108af8:	c3                   	ret    
f0108af9:	66 90                	xchg   %ax,%ax
f0108afb:	90                   	nop

f0108afc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0108afc:	fa                   	cli    

	xorw    %ax, %ax
f0108afd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0108aff:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0108b01:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0108b03:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0108b05:	0f 01 16             	lgdtl  (%esi)
f0108b08:	74 70                	je     f0108b7a <_kaddr+0x3>
	movl    %cr0, %eax
f0108b0a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0108b0d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0108b11:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0108b14:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0108b1a:	08 00                	or     %al,(%eax)

f0108b1c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0108b1c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0108b20:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0108b22:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0108b24:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0108b26:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0108b2a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0108b2c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0108b2e:	b8 00 50 12 00       	mov    $0x125000,%eax
	movl    %eax, %cr3
f0108b33:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0108b36:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0108b39:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0108b3e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0108b41:	8b 25 e4 6a 29 f0    	mov    0xf0296ae4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0108b47:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0108b4c:	b8 55 02 10 f0       	mov    $0xf0100255,%eax
	call    *%eax
f0108b51:	ff d0                	call   *%eax

f0108b53 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0108b53:	eb fe                	jmp    f0108b53 <spin>
f0108b55:	8d 76 00             	lea    0x0(%esi),%esi

f0108b58 <gdt>:
	...
f0108b60:	ff                   	(bad)  
f0108b61:	ff 00                	incl   (%eax)
f0108b63:	00 00                	add    %al,(%eax)
f0108b65:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0108b6c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0108b70 <gdtdesc>:
f0108b70:	17                   	pop    %ss
f0108b71:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0108b76 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0108b76:	90                   	nop

f0108b77 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0108b77:	55                   	push   %ebp
f0108b78:	89 e5                	mov    %esp,%ebp
f0108b7a:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0108b7d:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b80:	c1 e8 0c             	shr    $0xc,%eax
f0108b83:	89 c2                	mov    %eax,%edx
f0108b85:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f0108b8a:	39 c2                	cmp    %eax,%edx
f0108b8c:	72 21                	jb     f0108baf <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0108b8e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108b91:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108b95:	c7 44 24 08 d8 b3 10 	movl   $0xf010b3d8,0x8(%esp)
f0108b9c:	f0 
f0108b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108ba4:	8b 45 08             	mov    0x8(%ebp),%eax
f0108ba7:	89 04 24             	mov    %eax,(%esp)
f0108baa:	e8 20 77 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f0108baf:	8b 45 10             	mov    0x10(%ebp),%eax
f0108bb2:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0108bb7:	c9                   	leave  
f0108bb8:	c3                   	ret    

f0108bb9 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0108bb9:	55                   	push   %ebp
f0108bba:	89 e5                	mov    %esp,%ebp
f0108bbc:	83 ec 10             	sub    $0x10,%esp
	int i, sum;

	sum = 0;
f0108bbf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i = 0; i < len; i++)
f0108bc6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0108bcd:	eb 15                	jmp    f0108be4 <sum+0x2b>
		sum += ((uint8_t *)addr)[i];
f0108bcf:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0108bd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0108bd5:	01 d0                	add    %edx,%eax
f0108bd7:	0f b6 00             	movzbl (%eax),%eax
f0108bda:	0f b6 c0             	movzbl %al,%eax
f0108bdd:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0108be0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108be4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108be7:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0108bea:	7c e3                	jl     f0108bcf <sum+0x16>
		sum += ((uint8_t *)addr)[i];
	return sum;
f0108bec:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0108bef:	c9                   	leave  
f0108bf0:	c3                   	ret    

f0108bf1 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0108bf1:	55                   	push   %ebp
f0108bf2:	89 e5                	mov    %esp,%ebp
f0108bf4:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0108bf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0108bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108bfe:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0108c05:	00 
f0108c06:	c7 04 24 fb b3 10 f0 	movl   $0xf010b3fb,(%esp)
f0108c0d:	e8 65 ff ff ff       	call   f0108b77 <_kaddr>
f0108c12:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108c15:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108c18:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c1b:	01 d0                	add    %edx,%eax
f0108c1d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108c21:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0108c28:	00 
f0108c29:	c7 04 24 fb b3 10 f0 	movl   $0xf010b3fb,(%esp)
f0108c30:	e8 42 ff ff ff       	call   f0108b77 <_kaddr>
f0108c35:	89 45 f0             	mov    %eax,-0x10(%ebp)

	for (; mp < end; mp++)
f0108c38:	eb 3f                	jmp    f0108c79 <mpsearch1+0x88>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0108c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c3d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0108c44:	00 
f0108c45:	c7 44 24 04 0b b4 10 	movl   $0xf010b40b,0x4(%esp)
f0108c4c:	f0 
f0108c4d:	89 04 24             	mov    %eax,(%esp)
f0108c50:	e8 bb fc ff ff       	call   f0108910 <memcmp>
f0108c55:	85 c0                	test   %eax,%eax
f0108c57:	75 1c                	jne    f0108c75 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
f0108c59:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0108c60:	00 
f0108c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c64:	89 04 24             	mov    %eax,(%esp)
f0108c67:	e8 4d ff ff ff       	call   f0108bb9 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0108c6c:	84 c0                	test   %al,%al
f0108c6e:	75 05                	jne    f0108c75 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
f0108c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c73:	eb 11                	jmp    f0108c86 <mpsearch1+0x95>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0108c75:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
f0108c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108c7c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0108c7f:	72 b9                	jb     f0108c3a <mpsearch1+0x49>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0108c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108c86:	c9                   	leave  
f0108c87:	c3                   	ret    

f0108c88 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0108c88:	55                   	push   %ebp
f0108c89:	89 e5                	mov    %esp,%ebp
f0108c8b:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0108c8e:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f0108c95:	00 
f0108c96:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0108c9d:	00 
f0108c9e:	c7 04 24 fb b3 10 f0 	movl   $0xf010b3fb,(%esp)
f0108ca5:	e8 cd fe ff ff       	call   f0108b77 <_kaddr>
f0108caa:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0108cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108cb0:	83 c0 0e             	add    $0xe,%eax
f0108cb3:	0f b7 00             	movzwl (%eax),%eax
f0108cb6:	0f b7 c0             	movzwl %ax,%eax
f0108cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0108cbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108cc0:	74 25                	je     f0108ce7 <mpsearch+0x5f>
		p <<= 4;	// Translate from segment to PA
f0108cc2:	c1 65 f0 04          	shll   $0x4,-0x10(%ebp)
		if ((mp = mpsearch1(p, 1024)))
f0108cc6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0108ccd:	00 
f0108cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108cd1:	89 04 24             	mov    %eax,(%esp)
f0108cd4:	e8 18 ff ff ff       	call   f0108bf1 <mpsearch1>
f0108cd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108cdc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108ce0:	74 3d                	je     f0108d1f <mpsearch+0x97>
			return mp;
f0108ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108ce5:	eb 4c                	jmp    f0108d33 <mpsearch+0xab>
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0108ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108cea:	83 c0 13             	add    $0x13,%eax
f0108ced:	0f b7 00             	movzwl (%eax),%eax
f0108cf0:	0f b7 c0             	movzwl %ax,%eax
f0108cf3:	c1 e0 0a             	shl    $0xa,%eax
f0108cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if ((mp = mpsearch1(p - 1024, 1024)))
f0108cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108cfc:	2d 00 04 00 00       	sub    $0x400,%eax
f0108d01:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0108d08:	00 
f0108d09:	89 04 24             	mov    %eax,(%esp)
f0108d0c:	e8 e0 fe ff ff       	call   f0108bf1 <mpsearch1>
f0108d11:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108d14:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108d18:	74 05                	je     f0108d1f <mpsearch+0x97>
			return mp;
f0108d1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108d1d:	eb 14                	jmp    f0108d33 <mpsearch+0xab>
	}
	return mpsearch1(0xF0000, 0x10000);
f0108d1f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0108d26:	00 
f0108d27:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
f0108d2e:	e8 be fe ff ff       	call   f0108bf1 <mpsearch1>
}
f0108d33:	c9                   	leave  
f0108d34:	c3                   	ret    

f0108d35 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0108d35:	55                   	push   %ebp
f0108d36:	89 e5                	mov    %esp,%ebp
f0108d38:	83 ec 28             	sub    $0x28,%esp
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0108d3b:	e8 48 ff ff ff       	call   f0108c88 <mpsearch>
f0108d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108d43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0108d47:	75 0a                	jne    f0108d53 <mpconfig+0x1e>
		return NULL;
f0108d49:	b8 00 00 00 00       	mov    $0x0,%eax
f0108d4e:	e9 44 01 00 00       	jmp    f0108e97 <mpconfig+0x162>
	if (mp->physaddr == 0 || mp->type != 0) {
f0108d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108d56:	8b 40 04             	mov    0x4(%eax),%eax
f0108d59:	85 c0                	test   %eax,%eax
f0108d5b:	74 0b                	je     f0108d68 <mpconfig+0x33>
f0108d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108d60:	0f b6 40 0b          	movzbl 0xb(%eax),%eax
f0108d64:	84 c0                	test   %al,%al
f0108d66:	74 16                	je     f0108d7e <mpconfig+0x49>
		cprintf("SMP: Default configurations not implemented\n");
f0108d68:	c7 04 24 10 b4 10 f0 	movl   $0xf010b410,(%esp)
f0108d6f:	e8 d8 c1 ff ff       	call   f0104f4c <cprintf>
		return NULL;
f0108d74:	b8 00 00 00 00       	mov    $0x0,%eax
f0108d79:	e9 19 01 00 00       	jmp    f0108e97 <mpconfig+0x162>
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0108d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108d81:	8b 40 04             	mov    0x4(%eax),%eax
f0108d84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108d88:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0108d8f:	00 
f0108d90:	c7 04 24 fb b3 10 f0 	movl   $0xf010b3fb,(%esp)
f0108d97:	e8 db fd ff ff       	call   f0108b77 <_kaddr>
f0108d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0) {
f0108d9f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0108da6:	00 
f0108da7:	c7 44 24 04 3d b4 10 	movl   $0xf010b43d,0x4(%esp)
f0108dae:	f0 
f0108daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108db2:	89 04 24             	mov    %eax,(%esp)
f0108db5:	e8 56 fb ff ff       	call   f0108910 <memcmp>
f0108dba:	85 c0                	test   %eax,%eax
f0108dbc:	74 16                	je     f0108dd4 <mpconfig+0x9f>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0108dbe:	c7 04 24 44 b4 10 f0 	movl   $0xf010b444,(%esp)
f0108dc5:	e8 82 c1 ff ff       	call   f0104f4c <cprintf>
		return NULL;
f0108dca:	b8 00 00 00 00       	mov    $0x0,%eax
f0108dcf:	e9 c3 00 00 00       	jmp    f0108e97 <mpconfig+0x162>
	}
	if (sum(conf, conf->length) != 0) {
f0108dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108dd7:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0108ddb:	0f b7 c0             	movzwl %ax,%eax
f0108dde:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108de5:	89 04 24             	mov    %eax,(%esp)
f0108de8:	e8 cc fd ff ff       	call   f0108bb9 <sum>
f0108ded:	84 c0                	test   %al,%al
f0108def:	74 16                	je     f0108e07 <mpconfig+0xd2>
		cprintf("SMP: Bad MP configuration checksum\n");
f0108df1:	c7 04 24 78 b4 10 f0 	movl   $0xf010b478,(%esp)
f0108df8:	e8 4f c1 ff ff       	call   f0104f4c <cprintf>
		return NULL;
f0108dfd:	b8 00 00 00 00       	mov    $0x0,%eax
f0108e02:	e9 90 00 00 00       	jmp    f0108e97 <mpconfig+0x162>
	}
	if (conf->version != 1 && conf->version != 4) {
f0108e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108e0a:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0108e0e:	3c 01                	cmp    $0x1,%al
f0108e10:	74 2c                	je     f0108e3e <mpconfig+0x109>
f0108e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108e15:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0108e19:	3c 04                	cmp    $0x4,%al
f0108e1b:	74 21                	je     f0108e3e <mpconfig+0x109>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0108e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108e20:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f0108e24:	0f b6 c0             	movzbl %al,%eax
f0108e27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108e2b:	c7 04 24 9c b4 10 f0 	movl   $0xf010b49c,(%esp)
f0108e32:	e8 15 c1 ff ff       	call   f0104f4c <cprintf>
		return NULL;
f0108e37:	b8 00 00 00 00       	mov    $0x0,%eax
f0108e3c:	eb 59                	jmp    f0108e97 <mpconfig+0x162>
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0108e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108e41:	0f b7 40 28          	movzwl 0x28(%eax),%eax
f0108e45:	0f b7 c0             	movzwl %ax,%eax
f0108e48:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108e4b:	0f b7 52 04          	movzwl 0x4(%edx),%edx
f0108e4f:	0f b7 ca             	movzwl %dx,%ecx
f0108e52:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108e55:	01 ca                	add    %ecx,%edx
f0108e57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108e5b:	89 14 24             	mov    %edx,(%esp)
f0108e5e:	e8 56 fd ff ff       	call   f0108bb9 <sum>
f0108e63:	0f b6 d0             	movzbl %al,%edx
f0108e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108e69:	0f b6 40 2a          	movzbl 0x2a(%eax),%eax
f0108e6d:	0f b6 c0             	movzbl %al,%eax
f0108e70:	01 d0                	add    %edx,%eax
f0108e72:	0f b6 c0             	movzbl %al,%eax
f0108e75:	85 c0                	test   %eax,%eax
f0108e77:	74 13                	je     f0108e8c <mpconfig+0x157>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0108e79:	c7 04 24 bc b4 10 f0 	movl   $0xf010b4bc,(%esp)
f0108e80:	e8 c7 c0 ff ff       	call   f0104f4c <cprintf>
		return NULL;
f0108e85:	b8 00 00 00 00       	mov    $0x0,%eax
f0108e8a:	eb 0b                	jmp    f0108e97 <mpconfig+0x162>
	}
	*pmp = mp;
f0108e8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0108e92:	89 10                	mov    %edx,(%eax)
	return conf;
f0108e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0108e97:	c9                   	leave  
f0108e98:	c3                   	ret    

f0108e99 <mp_init>:

void
mp_init(void)
{
f0108e99:	55                   	push   %ebp
f0108e9a:	89 e5                	mov    %esp,%ebp
f0108e9c:	83 ec 48             	sub    $0x48,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0108e9f:	c7 05 c0 73 29 f0 20 	movl   $0xf0297020,0xf02973c0
f0108ea6:	70 29 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0108ea9:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0108eac:	89 04 24             	mov    %eax,(%esp)
f0108eaf:	e8 81 fe ff ff       	call   f0108d35 <mpconfig>
f0108eb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108eb7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108ebb:	75 05                	jne    f0108ec2 <mp_init+0x29>
		return;
f0108ebd:	e9 c1 01 00 00       	jmp    f0109083 <mp_init+0x1ea>
	ismp = 1;
f0108ec2:	c7 05 00 70 29 f0 01 	movl   $0x1,0xf0297000
f0108ec9:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0108ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108ecf:	8b 40 24             	mov    0x24(%eax),%eax
f0108ed2:	a3 00 80 2d f0       	mov    %eax,0xf02d8000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0108ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108eda:	83 c0 2c             	add    $0x2c,%eax
f0108edd:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108ee0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0108ee7:	e9 d2 00 00 00       	jmp    f0108fbe <mp_init+0x125>
		switch (*p) {
f0108eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108eef:	0f b6 00             	movzbl (%eax),%eax
f0108ef2:	0f b6 c0             	movzbl %al,%eax
f0108ef5:	85 c0                	test   %eax,%eax
f0108ef7:	74 13                	je     f0108f0c <mp_init+0x73>
f0108ef9:	85 c0                	test   %eax,%eax
f0108efb:	0f 88 89 00 00 00    	js     f0108f8a <mp_init+0xf1>
f0108f01:	83 f8 04             	cmp    $0x4,%eax
f0108f04:	0f 8f 80 00 00 00    	jg     f0108f8a <mp_init+0xf1>
f0108f0a:	eb 78                	jmp    f0108f84 <mp_init+0xeb>
		case MPPROC:
			proc = (struct mpproc *)p;
f0108f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108f0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if (proc->flags & MPPROC_BOOT)
f0108f12:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108f15:	0f b6 40 03          	movzbl 0x3(%eax),%eax
f0108f19:	0f b6 c0             	movzbl %al,%eax
f0108f1c:	83 e0 02             	and    $0x2,%eax
f0108f1f:	85 c0                	test   %eax,%eax
f0108f21:	74 12                	je     f0108f35 <mp_init+0x9c>
				bootcpu = &cpus[ncpu];
f0108f23:	a1 c4 73 29 f0       	mov    0xf02973c4,%eax
f0108f28:	6b c0 74             	imul   $0x74,%eax,%eax
f0108f2b:	05 20 70 29 f0       	add    $0xf0297020,%eax
f0108f30:	a3 c0 73 29 f0       	mov    %eax,0xf02973c0
			if (ncpu < NCPU) {
f0108f35:	a1 c4 73 29 f0       	mov    0xf02973c4,%eax
f0108f3a:	83 f8 07             	cmp    $0x7,%eax
f0108f3d:	7f 25                	jg     f0108f64 <mp_init+0xcb>
				cpus[ncpu].cpu_id = ncpu;
f0108f3f:	8b 15 c4 73 29 f0    	mov    0xf02973c4,%edx
f0108f45:	a1 c4 73 29 f0       	mov    0xf02973c4,%eax
f0108f4a:	6b d2 74             	imul   $0x74,%edx,%edx
f0108f4d:	81 c2 20 70 29 f0    	add    $0xf0297020,%edx
f0108f53:	88 02                	mov    %al,(%edx)
				ncpu++;
f0108f55:	a1 c4 73 29 f0       	mov    0xf02973c4,%eax
f0108f5a:	83 c0 01             	add    $0x1,%eax
f0108f5d:	a3 c4 73 29 f0       	mov    %eax,0xf02973c4
f0108f62:	eb 1a                	jmp    f0108f7e <mp_init+0xe5>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
f0108f64:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108f67:	0f b6 40 01          	movzbl 0x1(%eax),%eax
				bootcpu = &cpus[ncpu];
			if (ncpu < NCPU) {
				cpus[ncpu].cpu_id = ncpu;
				ncpu++;
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0108f6b:	0f b6 c0             	movzbl %al,%eax
f0108f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108f72:	c7 04 24 ec b4 10 f0 	movl   $0xf010b4ec,(%esp)
f0108f79:	e8 ce bf ff ff       	call   f0104f4c <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0108f7e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
			continue;
f0108f82:	eb 36                	jmp    f0108fba <mp_init+0x121>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0108f84:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
			continue;
f0108f88:	eb 30                	jmp    f0108fba <mp_init+0x121>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0108f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108f8d:	0f b6 00             	movzbl (%eax),%eax
f0108f90:	0f b6 c0             	movzbl %al,%eax
f0108f93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108f97:	c7 04 24 14 b5 10 f0 	movl   $0xf010b514,(%esp)
f0108f9e:	e8 a9 bf ff ff       	call   f0104f4c <cprintf>
			ismp = 0;
f0108fa3:	c7 05 00 70 29 f0 00 	movl   $0x0,0xf0297000
f0108faa:	00 00 00 
			i = conf->entry;
f0108fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108fb0:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0108fb4:	0f b7 c0             	movzwl %ax,%eax
f0108fb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0108fba:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0108fbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108fc1:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0108fc5:	0f b7 c0             	movzwl %ax,%eax
f0108fc8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0108fcb:	0f 87 1b ff ff ff    	ja     f0108eec <mp_init+0x53>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0108fd1:	a1 c0 73 29 f0       	mov    0xf02973c0,%eax
f0108fd6:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0108fdd:	a1 00 70 29 f0       	mov    0xf0297000,%eax
f0108fe2:	85 c0                	test   %eax,%eax
f0108fe4:	75 22                	jne    f0109008 <mp_init+0x16f>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0108fe6:	c7 05 c4 73 29 f0 01 	movl   $0x1,0xf02973c4
f0108fed:	00 00 00 
		lapicaddr = 0;
f0108ff0:	c7 05 00 80 2d f0 00 	movl   $0x0,0xf02d8000
f0108ff7:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0108ffa:	c7 04 24 34 b5 10 f0 	movl   $0xf010b534,(%esp)
f0109001:	e8 46 bf ff ff       	call   f0104f4c <cprintf>
		return;
f0109006:	eb 7b                	jmp    f0109083 <mp_init+0x1ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0109008:	8b 15 c4 73 29 f0    	mov    0xf02973c4,%edx
f010900e:	a1 c0 73 29 f0       	mov    0xf02973c0,%eax
f0109013:	0f b6 00             	movzbl (%eax),%eax
f0109016:	0f b6 c0             	movzbl %al,%eax
f0109019:	89 54 24 08          	mov    %edx,0x8(%esp)
f010901d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109021:	c7 04 24 60 b5 10 f0 	movl   $0xf010b560,(%esp)
f0109028:	e8 1f bf ff ff       	call   f0104f4c <cprintf>

	if (mp->imcrp) {
f010902d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0109030:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
f0109034:	84 c0                	test   %al,%al
f0109036:	74 4b                	je     f0109083 <mp_init+0x1ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0109038:	c7 04 24 80 b5 10 f0 	movl   $0xf010b580,(%esp)
f010903f:	e8 08 bf ff ff       	call   f0104f4c <cprintf>
f0109044:	c7 45 e4 22 00 00 00 	movl   $0x22,-0x1c(%ebp)
f010904b:	c6 45 e3 70          	movb   $0x70,-0x1d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010904f:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0109053:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0109056:	ee                   	out    %al,(%dx)
f0109057:	c7 45 dc 23 00 00 00 	movl   $0x23,-0x24(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010905e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0109061:	89 c2                	mov    %eax,%edx
f0109063:	ec                   	in     (%dx),%al
f0109064:	88 45 db             	mov    %al,-0x25(%ebp)
	return data;
f0109067:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010906b:	83 c8 01             	or     $0x1,%eax
f010906e:	0f b6 c0             	movzbl %al,%eax
f0109071:	c7 45 d4 23 00 00 00 	movl   $0x23,-0x2c(%ebp)
f0109078:	88 45 d3             	mov    %al,-0x2d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010907b:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f010907f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0109082:	ee                   	out    %al,(%dx)
	}
}
f0109083:	c9                   	leave  
f0109084:	c3                   	ret    

f0109085 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0109085:	55                   	push   %ebp
f0109086:	89 e5                	mov    %esp,%ebp
f0109088:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f010908b:	8b 45 10             	mov    0x10(%ebp),%eax
f010908e:	c1 e8 0c             	shr    $0xc,%eax
f0109091:	89 c2                	mov    %eax,%edx
f0109093:	a1 e8 6a 29 f0       	mov    0xf0296ae8,%eax
f0109098:	39 c2                	cmp    %eax,%edx
f010909a:	72 21                	jb     f01090bd <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010909c:	8b 45 10             	mov    0x10(%ebp),%eax
f010909f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01090a3:	c7 44 24 08 c4 b5 10 	movl   $0xf010b5c4,0x8(%esp)
f01090aa:	f0 
f01090ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01090ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01090b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01090b5:	89 04 24             	mov    %eax,(%esp)
f01090b8:	e8 12 72 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f01090bd:	8b 45 10             	mov    0x10(%ebp),%eax
f01090c0:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f01090c5:	c9                   	leave  
f01090c6:	c3                   	ret    

f01090c7 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01090c7:	55                   	push   %ebp
f01090c8:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01090ca:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f01090cf:	8b 55 08             	mov    0x8(%ebp),%edx
f01090d2:	c1 e2 02             	shl    $0x2,%edx
f01090d5:	01 c2                	add    %eax,%edx
f01090d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01090da:	89 02                	mov    %eax,(%edx)
	lapic[ID];  // wait for write to finish, by reading
f01090dc:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f01090e1:	83 c0 20             	add    $0x20,%eax
f01090e4:	8b 00                	mov    (%eax),%eax
}
f01090e6:	5d                   	pop    %ebp
f01090e7:	c3                   	ret    

f01090e8 <lapic_init>:

void
lapic_init(void)
{
f01090e8:	55                   	push   %ebp
f01090e9:	89 e5                	mov    %esp,%ebp
f01090eb:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01090ee:	a1 00 80 2d f0       	mov    0xf02d8000,%eax
f01090f3:	85 c0                	test   %eax,%eax
f01090f5:	75 05                	jne    f01090fc <lapic_init+0x14>
		return;
f01090f7:	e9 74 01 00 00       	jmp    f0109270 <lapic_init+0x188>

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01090fc:	a1 00 80 2d f0       	mov    0xf02d8000,%eax
f0109101:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0109108:	00 
f0109109:	89 04 24             	mov    %eax,(%esp)
f010910c:	e8 6d 8b ff ff       	call   f0101c7e <mmio_map_region>
f0109111:	a3 04 80 2d f0       	mov    %eax,0xf02d8004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0109116:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f010911d:	00 
f010911e:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
f0109125:	e8 9d ff ff ff       	call   f01090c7 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010912a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
f0109131:	00 
f0109132:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
f0109139:	e8 89 ff ff ff       	call   f01090c7 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010913e:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
f0109145:	00 
f0109146:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f010914d:	e8 75 ff ff ff       	call   f01090c7 <lapicw>
	lapicw(TICR, 10000000); 
f0109152:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
f0109159:	00 
f010915a:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
f0109161:	e8 61 ff ff ff       	call   f01090c7 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0109166:	e8 07 01 00 00       	call   f0109272 <cpunum>
f010916b:	6b c0 74             	imul   $0x74,%eax,%eax
f010916e:	8d 90 20 70 29 f0    	lea    -0xfd68fe0(%eax),%edx
f0109174:	a1 c0 73 29 f0       	mov    0xf02973c0,%eax
f0109179:	39 c2                	cmp    %eax,%edx
f010917b:	74 14                	je     f0109191 <lapic_init+0xa9>
		lapicw(LINT0, MASKED);
f010917d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0109184:	00 
f0109185:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
f010918c:	e8 36 ff ff ff       	call   f01090c7 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0109191:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0109198:	00 
f0109199:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
f01091a0:	e8 22 ff ff ff       	call   f01090c7 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01091a5:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f01091aa:	83 c0 30             	add    $0x30,%eax
f01091ad:	8b 00                	mov    (%eax),%eax
f01091af:	c1 e8 10             	shr    $0x10,%eax
f01091b2:	0f b6 c0             	movzbl %al,%eax
f01091b5:	83 f8 03             	cmp    $0x3,%eax
f01091b8:	76 14                	jbe    f01091ce <lapic_init+0xe6>
		lapicw(PCINT, MASKED);
f01091ba:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f01091c1:	00 
f01091c2:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
f01091c9:	e8 f9 fe ff ff       	call   f01090c7 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01091ce:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f01091d5:	00 
f01091d6:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
f01091dd:	e8 e5 fe ff ff       	call   f01090c7 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01091e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01091e9:	00 
f01091ea:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f01091f1:	e8 d1 fe ff ff       	call   f01090c7 <lapicw>
	lapicw(ESR, 0);
f01091f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01091fd:	00 
f01091fe:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f0109205:	e8 bd fe ff ff       	call   f01090c7 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010920a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109211:	00 
f0109212:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f0109219:	e8 a9 fe ff ff       	call   f01090c7 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010921e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109225:	00 
f0109226:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f010922d:	e8 95 fe ff ff       	call   f01090c7 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0109232:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
f0109239:	00 
f010923a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0109241:	e8 81 fe ff ff       	call   f01090c7 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0109246:	90                   	nop
f0109247:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f010924c:	05 00 03 00 00       	add    $0x300,%eax
f0109251:	8b 00                	mov    (%eax),%eax
f0109253:	25 00 10 00 00       	and    $0x1000,%eax
f0109258:	85 c0                	test   %eax,%eax
f010925a:	75 eb                	jne    f0109247 <lapic_init+0x15f>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010925c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109263:	00 
f0109264:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010926b:	e8 57 fe ff ff       	call   f01090c7 <lapicw>
}
f0109270:	c9                   	leave  
f0109271:	c3                   	ret    

f0109272 <cpunum>:

int
cpunum(void)
{
f0109272:	55                   	push   %ebp
f0109273:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0109275:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f010927a:	85 c0                	test   %eax,%eax
f010927c:	74 0f                	je     f010928d <cpunum+0x1b>
		return lapic[ID] >> 24;
f010927e:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f0109283:	83 c0 20             	add    $0x20,%eax
f0109286:	8b 00                	mov    (%eax),%eax
f0109288:	c1 e8 18             	shr    $0x18,%eax
f010928b:	eb 05                	jmp    f0109292 <cpunum+0x20>
	return 0;
f010928d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0109292:	5d                   	pop    %ebp
f0109293:	c3                   	ret    

f0109294 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0109294:	55                   	push   %ebp
f0109295:	89 e5                	mov    %esp,%ebp
f0109297:	83 ec 08             	sub    $0x8,%esp
	if (lapic)
f010929a:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f010929f:	85 c0                	test   %eax,%eax
f01092a1:	74 14                	je     f01092b7 <lapic_eoi+0x23>
		lapicw(EOI, 0);
f01092a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01092aa:	00 
f01092ab:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f01092b2:	e8 10 fe ff ff       	call   f01090c7 <lapicw>
}
f01092b7:	c9                   	leave  
f01092b8:	c3                   	ret    

f01092b9 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f01092b9:	55                   	push   %ebp
f01092ba:	89 e5                	mov    %esp,%ebp
}
f01092bc:	5d                   	pop    %ebp
f01092bd:	c3                   	ret    

f01092be <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01092be:	55                   	push   %ebp
f01092bf:	89 e5                	mov    %esp,%ebp
f01092c1:	83 ec 38             	sub    $0x38,%esp
f01092c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01092c7:	88 45 d4             	mov    %al,-0x2c(%ebp)
f01092ca:	c7 45 ec 70 00 00 00 	movl   $0x70,-0x14(%ebp)
f01092d1:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
f01092d5:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f01092d9:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01092dc:	ee                   	out    %al,(%dx)
f01092dd:	c7 45 e4 71 00 00 00 	movl   $0x71,-0x1c(%ebp)
f01092e4:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
f01092e8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01092ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01092ef:	ee                   	out    %al,(%dx)
	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f01092f0:	c7 44 24 08 67 04 00 	movl   $0x467,0x8(%esp)
f01092f7:	00 
f01092f8:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01092ff:	00 
f0109300:	c7 04 24 e7 b5 10 f0 	movl   $0xf010b5e7,(%esp)
f0109307:	e8 79 fd ff ff       	call   f0109085 <_kaddr>
f010930c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	wrv[0] = 0;
f010930f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0109312:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f0109317:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010931a:	8d 50 02             	lea    0x2(%eax),%edx
f010931d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109320:	c1 e8 04             	shr    $0x4,%eax
f0109323:	66 89 02             	mov    %ax,(%edx)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0109326:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f010932a:	c1 e0 18             	shl    $0x18,%eax
f010932d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109331:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0109338:	e8 8a fd ff ff       	call   f01090c7 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010933d:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
f0109344:	00 
f0109345:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f010934c:	e8 76 fd ff ff       	call   f01090c7 <lapicw>
	microdelay(200);
f0109351:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f0109358:	e8 5c ff ff ff       	call   f01092b9 <microdelay>
	lapicw(ICRLO, INIT | LEVEL);
f010935d:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
f0109364:	00 
f0109365:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f010936c:	e8 56 fd ff ff       	call   f01090c7 <lapicw>
	microdelay(100);    // should be 10ms, but too slow in Bochs!
f0109371:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0109378:	e8 3c ff ff ff       	call   f01092b9 <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f010937d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0109384:	eb 40                	jmp    f01093c6 <lapic_startap+0x108>
		lapicw(ICRHI, apicid << 24);
f0109386:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f010938a:	c1 e0 18             	shl    $0x18,%eax
f010938d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109391:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0109398:	e8 2a fd ff ff       	call   f01090c7 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010939d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01093a0:	c1 e8 0c             	shr    $0xc,%eax
f01093a3:	80 cc 06             	or     $0x6,%ah
f01093a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01093aa:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f01093b1:	e8 11 fd ff ff       	call   f01090c7 <lapicw>
		microdelay(200);
f01093b6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f01093bd:	e8 f7 fe ff ff       	call   f01092b9 <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f01093c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01093c6:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
f01093ca:	7e ba                	jle    f0109386 <lapic_startap+0xc8>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
f01093cc:	c9                   	leave  
f01093cd:	c3                   	ret    

f01093ce <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01093ce:	55                   	push   %ebp
f01093cf:	89 e5                	mov    %esp,%ebp
f01093d1:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01093d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01093d7:	0d 00 00 0c 00       	or     $0xc0000,%eax
f01093dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01093e0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f01093e7:	e8 db fc ff ff       	call   f01090c7 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01093ec:	90                   	nop
f01093ed:	a1 04 80 2d f0       	mov    0xf02d8004,%eax
f01093f2:	05 00 03 00 00       	add    $0x300,%eax
f01093f7:	8b 00                	mov    (%eax),%eax
f01093f9:	25 00 10 00 00       	and    $0x1000,%eax
f01093fe:	85 c0                	test   %eax,%eax
f0109400:	75 eb                	jne    f01093ed <lapic_ipi+0x1f>
		;
}
f0109402:	c9                   	leave  
f0109403:	c3                   	ret    

f0109404 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0109404:	55                   	push   %ebp
f0109405:	89 e5                	mov    %esp,%ebp
f0109407:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010940a:	8b 55 08             	mov    0x8(%ebp),%edx
f010940d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0109410:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0109413:	f0 87 02             	lock xchg %eax,(%edx)
f0109416:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0109419:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010941c:	c9                   	leave  
f010941d:	c3                   	ret    

f010941e <get_caller_pcs>:

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
f010941e:	55                   	push   %ebp
f010941f:	89 e5                	mov    %esp,%ebp
f0109421:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0109424:	89 e8                	mov    %ebp,%eax
f0109426:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return ebp;
f0109429:	8b 45 f4             	mov    -0xc(%ebp),%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010942c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < 10; i++){
f010942f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
f0109436:	eb 32                	jmp    f010946a <get_caller_pcs+0x4c>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0109438:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f010943c:	74 32                	je     f0109470 <get_caller_pcs+0x52>
f010943e:	81 7d fc ff ff 7f ef 	cmpl   $0xef7fffff,-0x4(%ebp)
f0109445:	76 29                	jbe    f0109470 <get_caller_pcs+0x52>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0109447:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010944a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0109451:	8b 45 08             	mov    0x8(%ebp),%eax
f0109454:	01 c2                	add    %eax,%edx
f0109456:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0109459:	8b 40 04             	mov    0x4(%eax),%eax
f010945c:	89 02                	mov    %eax,(%edx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010945e:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0109461:	8b 00                	mov    (%eax),%eax
f0109463:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0109466:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f010946a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f010946e:	7e c8                	jle    f0109438 <get_caller_pcs+0x1a>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0109470:	eb 19                	jmp    f010948b <get_caller_pcs+0x6d>
		pcs[i] = 0;
f0109472:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0109475:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010947c:	8b 45 08             	mov    0x8(%ebp),%eax
f010947f:	01 d0                	add    %edx,%eax
f0109481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0109487:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f010948b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f010948f:	7e e1                	jle    f0109472 <get_caller_pcs+0x54>
		pcs[i] = 0;
}
f0109491:	c9                   	leave  
f0109492:	c3                   	ret    

f0109493 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0109493:	55                   	push   %ebp
f0109494:	89 e5                	mov    %esp,%ebp
f0109496:	53                   	push   %ebx
f0109497:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010949a:	8b 45 08             	mov    0x8(%ebp),%eax
f010949d:	8b 00                	mov    (%eax),%eax
f010949f:	85 c0                	test   %eax,%eax
f01094a1:	74 1e                	je     f01094c1 <holding+0x2e>
f01094a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01094a6:	8b 58 08             	mov    0x8(%eax),%ebx
f01094a9:	e8 c4 fd ff ff       	call   f0109272 <cpunum>
f01094ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01094b1:	05 20 70 29 f0       	add    $0xf0297020,%eax
f01094b6:	39 c3                	cmp    %eax,%ebx
f01094b8:	75 07                	jne    f01094c1 <holding+0x2e>
f01094ba:	b8 01 00 00 00       	mov    $0x1,%eax
f01094bf:	eb 05                	jmp    f01094c6 <holding+0x33>
f01094c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01094c6:	83 c4 04             	add    $0x4,%esp
f01094c9:	5b                   	pop    %ebx
f01094ca:	5d                   	pop    %ebp
f01094cb:	c3                   	ret    

f01094cc <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01094cc:	55                   	push   %ebp
f01094cd:	89 e5                	mov    %esp,%ebp
	lk->locked = 0;
f01094cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01094d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01094d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01094db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01094de:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01094e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01094e4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01094eb:	5d                   	pop    %ebp
f01094ec:	c3                   	ret    

f01094ed <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01094ed:	55                   	push   %ebp
f01094ee:	89 e5                	mov    %esp,%ebp
f01094f0:	53                   	push   %ebx
f01094f1:	83 ec 24             	sub    $0x24,%esp
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01094f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01094f7:	89 04 24             	mov    %eax,(%esp)
f01094fa:	e8 94 ff ff ff       	call   f0109493 <holding>
f01094ff:	85 c0                	test   %eax,%eax
f0109501:	74 2f                	je     f0109532 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0109503:	8b 45 08             	mov    0x8(%ebp),%eax
f0109506:	8b 58 04             	mov    0x4(%eax),%ebx
f0109509:	e8 64 fd ff ff       	call   f0109272 <cpunum>
f010950e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0109512:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0109516:	c7 44 24 08 00 b6 10 	movl   $0xf010b600,0x8(%esp)
f010951d:	f0 
f010951e:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0109525:	00 
f0109526:	c7 04 24 2a b6 10 f0 	movl   $0xf010b62a,(%esp)
f010952d:	e8 9d 6d ff ff       	call   f01002cf <_panic>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0109532:	eb 02                	jmp    f0109536 <spin_lock+0x49>
		asm volatile ("pause");
f0109534:	f3 90                	pause  
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0109536:	8b 45 08             	mov    0x8(%ebp),%eax
f0109539:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0109540:	00 
f0109541:	89 04 24             	mov    %eax,(%esp)
f0109544:	e8 bb fe ff ff       	call   f0109404 <xchg>
f0109549:	85 c0                	test   %eax,%eax
f010954b:	75 e7                	jne    f0109534 <spin_lock+0x47>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010954d:	e8 20 fd ff ff       	call   f0109272 <cpunum>
f0109552:	6b c0 74             	imul   $0x74,%eax,%eax
f0109555:	8d 90 20 70 29 f0    	lea    -0xfd68fe0(%eax),%edx
f010955b:	8b 45 08             	mov    0x8(%ebp),%eax
f010955e:	89 50 08             	mov    %edx,0x8(%eax)
	get_caller_pcs(lk->pcs);
f0109561:	8b 45 08             	mov    0x8(%ebp),%eax
f0109564:	83 c0 0c             	add    $0xc,%eax
f0109567:	89 04 24             	mov    %eax,(%esp)
f010956a:	e8 af fe ff ff       	call   f010941e <get_caller_pcs>
#endif
}
f010956f:	83 c4 24             	add    $0x24,%esp
f0109572:	5b                   	pop    %ebx
f0109573:	5d                   	pop    %ebp
f0109574:	c3                   	ret    

f0109575 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0109575:	55                   	push   %ebp
f0109576:	89 e5                	mov    %esp,%ebp
f0109578:	57                   	push   %edi
f0109579:	56                   	push   %esi
f010957a:	53                   	push   %ebx
f010957b:	83 ec 7c             	sub    $0x7c,%esp
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010957e:	8b 45 08             	mov    0x8(%ebp),%eax
f0109581:	89 04 24             	mov    %eax,(%esp)
f0109584:	e8 0a ff ff ff       	call   f0109493 <holding>
f0109589:	85 c0                	test   %eax,%eax
f010958b:	0f 85 02 01 00 00    	jne    f0109693 <spin_unlock+0x11e>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0109591:	8b 45 08             	mov    0x8(%ebp),%eax
f0109594:	83 c0 0c             	add    $0xc,%eax
f0109597:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010959e:	00 
f010959f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01095a3:	8d 45 a4             	lea    -0x5c(%ebp),%eax
f01095a6:	89 04 24             	mov    %eax,(%esp)
f01095a9:	e8 67 f2 ff ff       	call   f0108815 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01095ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01095b1:	8b 40 08             	mov    0x8(%eax),%eax
f01095b4:	0f b6 00             	movzbl (%eax),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01095b7:	0f b6 f0             	movzbl %al,%esi
f01095ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01095bd:	8b 58 04             	mov    0x4(%eax),%ebx
f01095c0:	e8 ad fc ff ff       	call   f0109272 <cpunum>
f01095c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01095c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01095cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01095d1:	c7 04 24 3c b6 10 f0 	movl   $0xf010b63c,(%esp)
f01095d8:	e8 6f b9 ff ff       	call   f0104f4c <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01095dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01095e4:	eb 7c                	jmp    f0109662 <spin_unlock+0xed>
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01095e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01095e9:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f01095ed:	8d 55 cc             	lea    -0x34(%ebp),%edx
f01095f0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01095f4:	89 04 24             	mov    %eax,(%esp)
f01095f7:	e8 e3 e3 ff ff       	call   f01079df <debuginfo_eip>
f01095fc:	85 c0                	test   %eax,%eax
f01095fe:	78 47                	js     f0109647 <spin_unlock+0xd2>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0109600:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0109603:	8b 54 85 a4          	mov    -0x5c(%ebp,%eax,4),%edx
f0109607:	8b 45 dc             	mov    -0x24(%ebp),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010960a:	89 d7                	mov    %edx,%edi
f010960c:	29 c7                	sub    %eax,%edi
f010960e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0109611:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0109614:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0109617:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010961a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010961d:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0109621:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0109625:	89 74 24 14          	mov    %esi,0x14(%esp)
f0109629:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010962d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0109631:	89 54 24 08          	mov    %edx,0x8(%esp)
f0109635:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109639:	c7 04 24 72 b6 10 f0 	movl   $0xf010b672,(%esp)
f0109640:	e8 07 b9 ff ff       	call   f0104f4c <cprintf>
f0109645:	eb 17                	jmp    f010965e <spin_unlock+0xe9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0109647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010964a:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f010964e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109652:	c7 04 24 89 b6 10 f0 	movl   $0xf010b689,(%esp)
f0109659:	e8 ee b8 ff ff       	call   f0104f4c <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010965e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f0109662:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
f0109666:	7f 0f                	jg     f0109677 <spin_unlock+0x102>
f0109668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010966b:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f010966f:	85 c0                	test   %eax,%eax
f0109671:	0f 85 6f ff ff ff    	jne    f01095e6 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0109677:	c7 44 24 08 91 b6 10 	movl   $0xf010b691,0x8(%esp)
f010967e:	f0 
f010967f:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0109686:	00 
f0109687:	c7 04 24 2a b6 10 f0 	movl   $0xf010b62a,(%esp)
f010968e:	e8 3c 6c ff ff       	call   f01002cf <_panic>
	}

	lk->pcs[0] = 0;
f0109693:	8b 45 08             	mov    0x8(%ebp),%eax
f0109696:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	lk->cpu = 0;
f010969d:	8b 45 08             	mov    0x8(%ebp),%eax
f01096a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	// But the 2007 Intel 64 Architecture Memory Ordering White
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
f01096a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01096aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01096b1:	00 
f01096b2:	89 04 24             	mov    %eax,(%esp)
f01096b5:	e8 4a fd ff ff       	call   f0109404 <xchg>
}
f01096ba:	83 c4 7c             	add    $0x7c,%esp
f01096bd:	5b                   	pop    %ebx
f01096be:	5e                   	pop    %esi
f01096bf:	5f                   	pop    %edi
f01096c0:	5d                   	pop    %ebp
f01096c1:	c3                   	ret    
f01096c2:	66 90                	xchg   %ax,%ax
f01096c4:	66 90                	xchg   %ax,%ax
f01096c6:	66 90                	xchg   %ax,%ax
f01096c8:	66 90                	xchg   %ax,%ax
f01096ca:	66 90                	xchg   %ax,%ax
f01096cc:	66 90                	xchg   %ax,%ax
f01096ce:	66 90                	xchg   %ax,%ax

f01096d0 <__udivdi3>:
f01096d0:	55                   	push   %ebp
f01096d1:	57                   	push   %edi
f01096d2:	56                   	push   %esi
f01096d3:	83 ec 0c             	sub    $0xc,%esp
f01096d6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01096da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01096de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01096e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01096e6:	85 c0                	test   %eax,%eax
f01096e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01096ec:	89 ea                	mov    %ebp,%edx
f01096ee:	89 0c 24             	mov    %ecx,(%esp)
f01096f1:	75 2d                	jne    f0109720 <__udivdi3+0x50>
f01096f3:	39 e9                	cmp    %ebp,%ecx
f01096f5:	77 61                	ja     f0109758 <__udivdi3+0x88>
f01096f7:	85 c9                	test   %ecx,%ecx
f01096f9:	89 ce                	mov    %ecx,%esi
f01096fb:	75 0b                	jne    f0109708 <__udivdi3+0x38>
f01096fd:	b8 01 00 00 00       	mov    $0x1,%eax
f0109702:	31 d2                	xor    %edx,%edx
f0109704:	f7 f1                	div    %ecx
f0109706:	89 c6                	mov    %eax,%esi
f0109708:	31 d2                	xor    %edx,%edx
f010970a:	89 e8                	mov    %ebp,%eax
f010970c:	f7 f6                	div    %esi
f010970e:	89 c5                	mov    %eax,%ebp
f0109710:	89 f8                	mov    %edi,%eax
f0109712:	f7 f6                	div    %esi
f0109714:	89 ea                	mov    %ebp,%edx
f0109716:	83 c4 0c             	add    $0xc,%esp
f0109719:	5e                   	pop    %esi
f010971a:	5f                   	pop    %edi
f010971b:	5d                   	pop    %ebp
f010971c:	c3                   	ret    
f010971d:	8d 76 00             	lea    0x0(%esi),%esi
f0109720:	39 e8                	cmp    %ebp,%eax
f0109722:	77 24                	ja     f0109748 <__udivdi3+0x78>
f0109724:	0f bd e8             	bsr    %eax,%ebp
f0109727:	83 f5 1f             	xor    $0x1f,%ebp
f010972a:	75 3c                	jne    f0109768 <__udivdi3+0x98>
f010972c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0109730:	39 34 24             	cmp    %esi,(%esp)
f0109733:	0f 86 9f 00 00 00    	jbe    f01097d8 <__udivdi3+0x108>
f0109739:	39 d0                	cmp    %edx,%eax
f010973b:	0f 82 97 00 00 00    	jb     f01097d8 <__udivdi3+0x108>
f0109741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0109748:	31 d2                	xor    %edx,%edx
f010974a:	31 c0                	xor    %eax,%eax
f010974c:	83 c4 0c             	add    $0xc,%esp
f010974f:	5e                   	pop    %esi
f0109750:	5f                   	pop    %edi
f0109751:	5d                   	pop    %ebp
f0109752:	c3                   	ret    
f0109753:	90                   	nop
f0109754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109758:	89 f8                	mov    %edi,%eax
f010975a:	f7 f1                	div    %ecx
f010975c:	31 d2                	xor    %edx,%edx
f010975e:	83 c4 0c             	add    $0xc,%esp
f0109761:	5e                   	pop    %esi
f0109762:	5f                   	pop    %edi
f0109763:	5d                   	pop    %ebp
f0109764:	c3                   	ret    
f0109765:	8d 76 00             	lea    0x0(%esi),%esi
f0109768:	89 e9                	mov    %ebp,%ecx
f010976a:	8b 3c 24             	mov    (%esp),%edi
f010976d:	d3 e0                	shl    %cl,%eax
f010976f:	89 c6                	mov    %eax,%esi
f0109771:	b8 20 00 00 00       	mov    $0x20,%eax
f0109776:	29 e8                	sub    %ebp,%eax
f0109778:	89 c1                	mov    %eax,%ecx
f010977a:	d3 ef                	shr    %cl,%edi
f010977c:	89 e9                	mov    %ebp,%ecx
f010977e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0109782:	8b 3c 24             	mov    (%esp),%edi
f0109785:	09 74 24 08          	or     %esi,0x8(%esp)
f0109789:	89 d6                	mov    %edx,%esi
f010978b:	d3 e7                	shl    %cl,%edi
f010978d:	89 c1                	mov    %eax,%ecx
f010978f:	89 3c 24             	mov    %edi,(%esp)
f0109792:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109796:	d3 ee                	shr    %cl,%esi
f0109798:	89 e9                	mov    %ebp,%ecx
f010979a:	d3 e2                	shl    %cl,%edx
f010979c:	89 c1                	mov    %eax,%ecx
f010979e:	d3 ef                	shr    %cl,%edi
f01097a0:	09 d7                	or     %edx,%edi
f01097a2:	89 f2                	mov    %esi,%edx
f01097a4:	89 f8                	mov    %edi,%eax
f01097a6:	f7 74 24 08          	divl   0x8(%esp)
f01097aa:	89 d6                	mov    %edx,%esi
f01097ac:	89 c7                	mov    %eax,%edi
f01097ae:	f7 24 24             	mull   (%esp)
f01097b1:	39 d6                	cmp    %edx,%esi
f01097b3:	89 14 24             	mov    %edx,(%esp)
f01097b6:	72 30                	jb     f01097e8 <__udivdi3+0x118>
f01097b8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01097bc:	89 e9                	mov    %ebp,%ecx
f01097be:	d3 e2                	shl    %cl,%edx
f01097c0:	39 c2                	cmp    %eax,%edx
f01097c2:	73 05                	jae    f01097c9 <__udivdi3+0xf9>
f01097c4:	3b 34 24             	cmp    (%esp),%esi
f01097c7:	74 1f                	je     f01097e8 <__udivdi3+0x118>
f01097c9:	89 f8                	mov    %edi,%eax
f01097cb:	31 d2                	xor    %edx,%edx
f01097cd:	e9 7a ff ff ff       	jmp    f010974c <__udivdi3+0x7c>
f01097d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01097d8:	31 d2                	xor    %edx,%edx
f01097da:	b8 01 00 00 00       	mov    $0x1,%eax
f01097df:	e9 68 ff ff ff       	jmp    f010974c <__udivdi3+0x7c>
f01097e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01097e8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01097eb:	31 d2                	xor    %edx,%edx
f01097ed:	83 c4 0c             	add    $0xc,%esp
f01097f0:	5e                   	pop    %esi
f01097f1:	5f                   	pop    %edi
f01097f2:	5d                   	pop    %ebp
f01097f3:	c3                   	ret    
f01097f4:	66 90                	xchg   %ax,%ax
f01097f6:	66 90                	xchg   %ax,%ax
f01097f8:	66 90                	xchg   %ax,%ax
f01097fa:	66 90                	xchg   %ax,%ax
f01097fc:	66 90                	xchg   %ax,%ax
f01097fe:	66 90                	xchg   %ax,%ax

f0109800 <__umoddi3>:
f0109800:	55                   	push   %ebp
f0109801:	57                   	push   %edi
f0109802:	56                   	push   %esi
f0109803:	83 ec 14             	sub    $0x14,%esp
f0109806:	8b 44 24 28          	mov    0x28(%esp),%eax
f010980a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010980e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0109812:	89 c7                	mov    %eax,%edi
f0109814:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109818:	8b 44 24 30          	mov    0x30(%esp),%eax
f010981c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0109820:	89 34 24             	mov    %esi,(%esp)
f0109823:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0109827:	85 c0                	test   %eax,%eax
f0109829:	89 c2                	mov    %eax,%edx
f010982b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010982f:	75 17                	jne    f0109848 <__umoddi3+0x48>
f0109831:	39 fe                	cmp    %edi,%esi
f0109833:	76 4b                	jbe    f0109880 <__umoddi3+0x80>
f0109835:	89 c8                	mov    %ecx,%eax
f0109837:	89 fa                	mov    %edi,%edx
f0109839:	f7 f6                	div    %esi
f010983b:	89 d0                	mov    %edx,%eax
f010983d:	31 d2                	xor    %edx,%edx
f010983f:	83 c4 14             	add    $0x14,%esp
f0109842:	5e                   	pop    %esi
f0109843:	5f                   	pop    %edi
f0109844:	5d                   	pop    %ebp
f0109845:	c3                   	ret    
f0109846:	66 90                	xchg   %ax,%ax
f0109848:	39 f8                	cmp    %edi,%eax
f010984a:	77 54                	ja     f01098a0 <__umoddi3+0xa0>
f010984c:	0f bd e8             	bsr    %eax,%ebp
f010984f:	83 f5 1f             	xor    $0x1f,%ebp
f0109852:	75 5c                	jne    f01098b0 <__umoddi3+0xb0>
f0109854:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0109858:	39 3c 24             	cmp    %edi,(%esp)
f010985b:	0f 87 e7 00 00 00    	ja     f0109948 <__umoddi3+0x148>
f0109861:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109865:	29 f1                	sub    %esi,%ecx
f0109867:	19 c7                	sbb    %eax,%edi
f0109869:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010986d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0109871:	8b 44 24 08          	mov    0x8(%esp),%eax
f0109875:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0109879:	83 c4 14             	add    $0x14,%esp
f010987c:	5e                   	pop    %esi
f010987d:	5f                   	pop    %edi
f010987e:	5d                   	pop    %ebp
f010987f:	c3                   	ret    
f0109880:	85 f6                	test   %esi,%esi
f0109882:	89 f5                	mov    %esi,%ebp
f0109884:	75 0b                	jne    f0109891 <__umoddi3+0x91>
f0109886:	b8 01 00 00 00       	mov    $0x1,%eax
f010988b:	31 d2                	xor    %edx,%edx
f010988d:	f7 f6                	div    %esi
f010988f:	89 c5                	mov    %eax,%ebp
f0109891:	8b 44 24 04          	mov    0x4(%esp),%eax
f0109895:	31 d2                	xor    %edx,%edx
f0109897:	f7 f5                	div    %ebp
f0109899:	89 c8                	mov    %ecx,%eax
f010989b:	f7 f5                	div    %ebp
f010989d:	eb 9c                	jmp    f010983b <__umoddi3+0x3b>
f010989f:	90                   	nop
f01098a0:	89 c8                	mov    %ecx,%eax
f01098a2:	89 fa                	mov    %edi,%edx
f01098a4:	83 c4 14             	add    $0x14,%esp
f01098a7:	5e                   	pop    %esi
f01098a8:	5f                   	pop    %edi
f01098a9:	5d                   	pop    %ebp
f01098aa:	c3                   	ret    
f01098ab:	90                   	nop
f01098ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01098b0:	8b 04 24             	mov    (%esp),%eax
f01098b3:	be 20 00 00 00       	mov    $0x20,%esi
f01098b8:	89 e9                	mov    %ebp,%ecx
f01098ba:	29 ee                	sub    %ebp,%esi
f01098bc:	d3 e2                	shl    %cl,%edx
f01098be:	89 f1                	mov    %esi,%ecx
f01098c0:	d3 e8                	shr    %cl,%eax
f01098c2:	89 e9                	mov    %ebp,%ecx
f01098c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01098c8:	8b 04 24             	mov    (%esp),%eax
f01098cb:	09 54 24 04          	or     %edx,0x4(%esp)
f01098cf:	89 fa                	mov    %edi,%edx
f01098d1:	d3 e0                	shl    %cl,%eax
f01098d3:	89 f1                	mov    %esi,%ecx
f01098d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01098d9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01098dd:	d3 ea                	shr    %cl,%edx
f01098df:	89 e9                	mov    %ebp,%ecx
f01098e1:	d3 e7                	shl    %cl,%edi
f01098e3:	89 f1                	mov    %esi,%ecx
f01098e5:	d3 e8                	shr    %cl,%eax
f01098e7:	89 e9                	mov    %ebp,%ecx
f01098e9:	09 f8                	or     %edi,%eax
f01098eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01098ef:	f7 74 24 04          	divl   0x4(%esp)
f01098f3:	d3 e7                	shl    %cl,%edi
f01098f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01098f9:	89 d7                	mov    %edx,%edi
f01098fb:	f7 64 24 08          	mull   0x8(%esp)
f01098ff:	39 d7                	cmp    %edx,%edi
f0109901:	89 c1                	mov    %eax,%ecx
f0109903:	89 14 24             	mov    %edx,(%esp)
f0109906:	72 2c                	jb     f0109934 <__umoddi3+0x134>
f0109908:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010990c:	72 22                	jb     f0109930 <__umoddi3+0x130>
f010990e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0109912:	29 c8                	sub    %ecx,%eax
f0109914:	19 d7                	sbb    %edx,%edi
f0109916:	89 e9                	mov    %ebp,%ecx
f0109918:	89 fa                	mov    %edi,%edx
f010991a:	d3 e8                	shr    %cl,%eax
f010991c:	89 f1                	mov    %esi,%ecx
f010991e:	d3 e2                	shl    %cl,%edx
f0109920:	89 e9                	mov    %ebp,%ecx
f0109922:	d3 ef                	shr    %cl,%edi
f0109924:	09 d0                	or     %edx,%eax
f0109926:	89 fa                	mov    %edi,%edx
f0109928:	83 c4 14             	add    $0x14,%esp
f010992b:	5e                   	pop    %esi
f010992c:	5f                   	pop    %edi
f010992d:	5d                   	pop    %ebp
f010992e:	c3                   	ret    
f010992f:	90                   	nop
f0109930:	39 d7                	cmp    %edx,%edi
f0109932:	75 da                	jne    f010990e <__umoddi3+0x10e>
f0109934:	8b 14 24             	mov    (%esp),%edx
f0109937:	89 c1                	mov    %eax,%ecx
f0109939:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010993d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0109941:	eb cb                	jmp    f010990e <__umoddi3+0x10e>
f0109943:	90                   	nop
f0109944:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109948:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010994c:	0f 82 0f ff ff ff    	jb     f0109861 <__umoddi3+0x61>
f0109952:	e9 1a ff ff ff       	jmp    f0109871 <__umoddi3+0x71>
