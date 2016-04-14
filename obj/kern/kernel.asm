
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
f0100057:	c7 44 24 08 20 93 10 	movl   $0xf0109320,0x8(%esp)
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
f0100089:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f010008e:	39 c2                	cmp    %eax,%edx
f0100090:	72 21                	jb     f01000b3 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100092:	8b 45 10             	mov    0x10(%ebp),%eax
f0100095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100099:	c7 44 24 08 44 93 10 	movl   $0xf0109344,0x8(%esp)
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
f01000e4:	e8 b4 8d 00 00       	call   f0108e9d <spin_lock>
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
f01000f1:	ba 08 80 28 f0       	mov    $0xf0288008,%edx
f01000f6:	b8 7c 57 24 f0       	mov    $0xf024577c,%eax
f01000fb:	29 c2                	sub    %eax,%edx
f01000fd:	89 d0                	mov    %edx,%eax
f01000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100103:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010010a:	00 
f010010b:	c7 04 24 7c 57 24 f0 	movl   $0xf024577c,(%esp)
f0100112:	e8 40 80 00 00       	call   f0108157 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100117:	e8 53 0a 00 00       	call   f0100b6f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010011c:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100123:	00 
f0100124:	c7 04 24 67 93 10 f0 	movl   $0xf0109367,(%esp)
f010012b:	e8 80 4e 00 00       	call   f0104fb0 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100130:	e8 21 13 00 00       	call   f0101456 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100135:	e8 e2 42 00 00       	call   f010441c <env_init>
	trap_init();
f010013a:	e8 03 4f 00 00       	call   f0105042 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010013f:	e8 05 87 00 00       	call   f0108849 <mp_init>
	lapic_init();
f0100144:	e8 4f 89 00 00       	call   f0108a98 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100149:	e8 20 4c 00 00       	call   f0104d6e <pic_init>

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
f0100160:	c7 04 24 10 63 19 f0 	movl   $0xf0196310,(%esp)
f0100167:	e8 de 47 00 00       	call   f010494a <env_create>
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010016c:	e8 ec 64 00 00       	call   f010665d <sched_yield>

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
f0100187:	c7 04 24 82 93 10 f0 	movl   $0xf0109382,(%esp)
f010018e:	e8 e8 fe ff ff       	call   f010007b <_kaddr>
f0100193:	89 45 f0             	mov    %eax,-0x10(%ebp)
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100196:	ba 26 85 10 f0       	mov    $0xf0108526,%edx
f010019b:	b8 ac 84 10 f0       	mov    $0xf01084ac,%eax
f01001a0:	29 c2                	sub    %eax,%edx
f01001a2:	89 d0                	mov    %edx,%eax
f01001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001a8:	c7 44 24 04 ac 84 10 	movl   $0xf01084ac,0x4(%esp)
f01001af:	f0 
f01001b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01001b3:	89 04 24             	mov    %eax,(%esp)
f01001b6:	e8 0a 80 00 00       	call   f01081c5 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001bb:	c7 45 f4 20 70 24 f0 	movl   $0xf0247020,-0xc(%ebp)
f01001c2:	eb 79                	jmp    f010023d <boot_aps+0xcc>
		if (c == cpus + cpunum())  // We've started already.
f01001c4:	e8 59 8a 00 00       	call   f0108c22 <cpunum>
f01001c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01001cc:	05 20 70 24 f0       	add    $0xf0247020,%eax
f01001d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01001d4:	75 02                	jne    f01001d8 <boot_aps+0x67>
			continue;
f01001d6:	eb 61                	jmp    f0100239 <boot_aps+0xc8>

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01001db:	b8 20 70 24 f0       	mov    $0xf0247020,%eax
f01001e0:	29 c2                	sub    %eax,%edx
f01001e2:	89 d0                	mov    %edx,%eax
f01001e4:	c1 f8 02             	sar    $0x2,%eax
f01001e7:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001ed:	83 c0 01             	add    $0x1,%eax
f01001f0:	c1 e0 0f             	shl    $0xf,%eax
f01001f3:	05 00 80 24 f0       	add    $0xf0248000,%eax
f01001f8:	a3 e4 6e 24 f0       	mov    %eax,0xf0246ee4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100200:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100204:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
f010020b:	00 
f010020c:	c7 04 24 82 93 10 f0 	movl   $0xf0109382,(%esp)
f0100213:	e8 28 fe ff ff       	call   f0100040 <_paddr>
f0100218:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010021b:	0f b6 12             	movzbl (%edx),%edx
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	89 14 24             	mov    %edx,(%esp)
f0100228:	e8 41 8a 00 00       	call   f0108c6e <lapic_startap>
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
f010023d:	a1 c4 73 24 f0       	mov    0xf02473c4,%eax
f0100242:	6b c0 74             	imul   $0x74,%eax,%eax
f0100245:	05 20 70 24 f0       	add    $0xf0247020,%eax
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
f010025b:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0100260:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100264:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f010026b:	00 
f010026c:	c7 04 24 82 93 10 f0 	movl   $0xf0109382,(%esp)
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
f0100281:	e8 9c 89 00 00       	call   f0108c22 <cpunum>
f0100286:	89 44 24 04          	mov    %eax,0x4(%esp)
f010028a:	c7 04 24 8e 93 10 f0 	movl   $0xf010938e,(%esp)
f0100291:	e8 1a 4d 00 00       	call   f0104fb0 <cprintf>

	lapic_init();
f0100296:	e8 fd 87 00 00       	call   f0108a98 <lapic_init>
	env_init_percpu();
f010029b:	e8 f5 41 00 00       	call   f0104495 <env_init_percpu>
	trap_init_percpu();
f01002a0:	e8 92 59 00 00       	call   f0105c37 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002a5:	e8 78 89 00 00       	call   f0108c22 <cpunum>
f01002aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01002ad:	05 20 70 24 f0       	add    $0xf0247020,%eax
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
f01002ca:	e8 8e 63 00 00       	call   f010665d <sched_yield>

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
f01002d5:	a1 e0 6e 24 f0       	mov    0xf0246ee0,%eax
f01002da:	85 c0                	test   %eax,%eax
f01002dc:	74 02                	je     f01002e0 <_panic+0x11>
		goto dead;
f01002de:	eb 51                	jmp    f0100331 <_panic+0x62>
	panicstr = fmt;
f01002e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01002e3:	a3 e0 6e 24 f0       	mov    %eax,0xf0246ee0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01002e8:	fa                   	cli    
f01002e9:	fc                   	cld    

	va_start(ap, fmt);
f01002ea:	8d 45 14             	lea    0x14(%ebp),%eax
f01002ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01002f0:	e8 2d 89 00 00       	call   f0108c22 <cpunum>
f01002f5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01002f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01002fc:	8b 55 08             	mov    0x8(%ebp),%edx
f01002ff:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100303:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100307:	c7 04 24 a4 93 10 f0 	movl   $0xf01093a4,(%esp)
f010030e:	e8 9d 4c 00 00       	call   f0104fb0 <cprintf>
	vcprintf(fmt, ap);
f0100313:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100316:	89 44 24 04          	mov    %eax,0x4(%esp)
f010031a:	8b 45 10             	mov    0x10(%ebp),%eax
f010031d:	89 04 24             	mov    %eax,(%esp)
f0100320:	e8 58 4c 00 00       	call   f0104f7d <vcprintf>
	cprintf("\n");
f0100325:	c7 04 24 c6 93 10 f0 	movl   $0xf01093c6,(%esp)
f010032c:	e8 7f 4c 00 00       	call   f0104fb0 <cprintf>
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
f0100359:	c7 04 24 c8 93 10 f0 	movl   $0xf01093c8,(%esp)
f0100360:	e8 4b 4c 00 00       	call   f0104fb0 <cprintf>
	vcprintf(fmt, ap);
f0100365:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100368:	89 44 24 04          	mov    %eax,0x4(%esp)
f010036c:	8b 45 10             	mov    0x10(%ebp),%eax
f010036f:	89 04 24             	mov    %eax,(%esp)
f0100372:	e8 06 4c 00 00       	call   f0104f7d <vcprintf>
	cprintf("\n");
f0100377:	c7 04 24 c6 93 10 f0 	movl   $0xf01093c6,(%esp)
f010037e:	e8 2d 4c 00 00       	call   f0104fb0 <cprintf>
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
f0100417:	0f b6 05 00 60 24 f0 	movzbl 0xf0246000,%eax
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
f010052d:	a2 00 60 24 f0       	mov    %al,0xf0246000
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
f01005ff:	c7 05 04 60 24 f0 b4 	movl   $0x3b4,0xf0246004
f0100606:	03 00 00 
f0100609:	eb 14                	jmp    f010061f <cga_init+0x52>
	} else {
		*cp = was;
f010060b:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010060e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
f0100612:	66 89 10             	mov    %dx,(%eax)
		addr_6845 = CGA_BASE;
f0100615:	c7 05 04 60 24 f0 d4 	movl   $0x3d4,0xf0246004
f010061c:	03 00 00 
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010061f:	a1 04 60 24 f0       	mov    0xf0246004,%eax
f0100624:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100627:	c6 45 ef 0e          	movb   $0xe,-0x11(%ebp)
f010062b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f010062f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100632:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100633:	a1 04 60 24 f0       	mov    0xf0246004,%eax
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
f0100654:	a1 04 60 24 f0       	mov    0xf0246004,%eax
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
f0100668:	a1 04 60 24 f0       	mov    0xf0246004,%eax
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
f0100689:	a3 08 60 24 f0       	mov    %eax,0xf0246008
	crt_pos = pos;
f010068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100691:	66 a3 0c 60 24 f0    	mov    %ax,0xf024600c
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
f01006dd:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f01006e4:	66 85 c0             	test   %ax,%ax
f01006e7:	74 33                	je     f010071c <cga_putc+0x83>
			crt_pos--;
f01006e9:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f01006f0:	83 e8 01             	sub    $0x1,%eax
f01006f3:	66 a3 0c 60 24 f0    	mov    %ax,0xf024600c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01006f9:	a1 08 60 24 f0       	mov    0xf0246008,%eax
f01006fe:	0f b7 15 0c 60 24 f0 	movzwl 0xf024600c,%edx
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
f0100721:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f0100728:	83 c0 50             	add    $0x50,%eax
f010072b:	66 a3 0c 60 24 f0    	mov    %ax,0xf024600c
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100731:	0f b7 1d 0c 60 24 f0 	movzwl 0xf024600c,%ebx
f0100738:	0f b7 0d 0c 60 24 f0 	movzwl 0xf024600c,%ecx
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
f0100763:	66 a3 0c 60 24 f0    	mov    %ax,0xf024600c
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
f01007a9:	8b 0d 08 60 24 f0    	mov    0xf0246008,%ecx
f01007af:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f01007b6:	8d 50 01             	lea    0x1(%eax),%edx
f01007b9:	66 89 15 0c 60 24 f0 	mov    %dx,0xf024600c
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
f01007cf:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f01007d6:	66 3d cf 07          	cmp    $0x7cf,%ax
f01007da:	76 5b                	jbe    f0100837 <cga_putc+0x19e>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01007dc:	a1 08 60 24 f0       	mov    0xf0246008,%eax
f01007e1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01007e7:	a1 08 60 24 f0       	mov    0xf0246008,%eax
f01007ec:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01007f3:	00 
f01007f4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01007f8:	89 04 24             	mov    %eax,(%esp)
f01007fb:	e8 c5 79 00 00       	call   f01081c5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100800:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f0100807:	eb 15                	jmp    f010081e <cga_putc+0x185>
			crt_buf[i] = 0x0700 | ' ';
f0100809:	a1 08 60 24 f0       	mov    0xf0246008,%eax
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
f0100827:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f010082e:	83 e8 50             	sub    $0x50,%eax
f0100831:	66 a3 0c 60 24 f0    	mov    %ax,0xf024600c
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100837:	a1 04 60 24 f0       	mov    0xf0246004,%eax
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
f010084b:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f0100852:	66 c1 e8 08          	shr    $0x8,%ax
f0100856:	0f b6 c0             	movzbl %al,%eax
f0100859:	8b 15 04 60 24 f0    	mov    0xf0246004,%edx
f010085f:	83 c2 01             	add    $0x1,%edx
f0100862:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100865:	88 45 e7             	mov    %al,-0x19(%ebp)
f0100868:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010086c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010086f:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100870:	a1 04 60 24 f0       	mov    0xf0246004,%eax
f0100875:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100878:	c6 45 df 0f          	movb   $0xf,-0x21(%ebp)
f010087c:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
f0100880:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100883:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f0100884:	0f b7 05 0c 60 24 f0 	movzwl 0xf024600c,%eax
f010088b:	0f b6 c0             	movzbl %al,%eax
f010088e:	8b 15 04 60 24 f0    	mov    0xf0246004,%edx
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
f01008f6:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f01008fb:	83 c8 40             	or     $0x40,%eax
f01008fe:	a3 28 62 24 f0       	mov    %eax,0xf0246228
		return 0;
f0100903:	b8 00 00 00 00       	mov    $0x0,%eax
f0100908:	e9 25 01 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
	} else if (data & 0x80) {
f010090d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100911:	84 c0                	test   %al,%al
f0100913:	79 47                	jns    f010095c <kbd_proc_data+0xb1>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100915:	a1 28 62 24 f0       	mov    0xf0246228,%eax
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
f0100946:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f010094b:	21 d0                	and    %edx,%eax
f010094d:	a3 28 62 24 f0       	mov    %eax,0xf0246228
		return 0;
f0100952:	b8 00 00 00 00       	mov    $0x0,%eax
f0100957:	e9 d6 00 00 00       	jmp    f0100a32 <kbd_proc_data+0x187>
	} else if (shift & E0ESC) {
f010095c:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f0100961:	83 e0 40             	and    $0x40,%eax
f0100964:	85 c0                	test   %eax,%eax
f0100966:	74 11                	je     f0100979 <kbd_proc_data+0xce>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100968:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f010096c:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f0100971:	83 e0 bf             	and    $0xffffffbf,%eax
f0100974:	a3 28 62 24 f0       	mov    %eax,0xf0246228
	}

	shift |= shiftcode[data];
f0100979:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010097d:	0f b6 80 00 60 12 f0 	movzbl -0xfeda000(%eax),%eax
f0100984:	0f b6 d0             	movzbl %al,%edx
f0100987:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f010098c:	09 d0                	or     %edx,%eax
f010098e:	a3 28 62 24 f0       	mov    %eax,0xf0246228
	shift ^= togglecode[data];
f0100993:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100997:	0f b6 80 00 61 12 f0 	movzbl -0xfed9f00(%eax),%eax
f010099e:	0f b6 d0             	movzbl %al,%edx
f01009a1:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f01009a6:	31 d0                	xor    %edx,%eax
f01009a8:	a3 28 62 24 f0       	mov    %eax,0xf0246228

	c = charcode[shift & (CTL | SHIFT)][data];
f01009ad:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f01009b2:	83 e0 03             	and    $0x3,%eax
f01009b5:	8b 14 85 00 65 12 f0 	mov    -0xfed9b00(,%eax,4),%edx
f01009bc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01009c0:	01 d0                	add    %edx,%eax
f01009c2:	0f b6 00             	movzbl (%eax),%eax
f01009c5:	0f b6 c0             	movzbl %al,%eax
f01009c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f01009cb:	a1 28 62 24 f0       	mov    0xf0246228,%eax
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
f01009f9:	a1 28 62 24 f0       	mov    0xf0246228,%eax
f01009fe:	f7 d0                	not    %eax
f0100a00:	83 e0 06             	and    $0x6,%eax
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	75 28                	jne    f0100a2f <kbd_proc_data+0x184>
f0100a07:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f0100a0e:	75 1f                	jne    f0100a2f <kbd_proc_data+0x184>
		cprintf("Rebooting!\n");
f0100a10:	c7 04 24 e2 93 10 f0 	movl   $0xf01093e2,(%esp)
f0100a17:	e8 94 45 00 00       	call   f0104fb0 <cprintf>
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
f0100a65:	e8 3f 44 00 00       	call   f0104ea9 <irq_setmask_8259A>
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
f0100a7c:	a1 24 62 24 f0       	mov    0xf0246224,%eax
f0100a81:	8d 50 01             	lea    0x1(%eax),%edx
f0100a84:	89 15 24 62 24 f0    	mov    %edx,0xf0246224
f0100a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100a8d:	88 90 20 60 24 f0    	mov    %dl,-0xfdb9fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100a93:	a1 24 62 24 f0       	mov    0xf0246224,%eax
f0100a98:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100a9d:	75 0a                	jne    f0100aa9 <cons_intr+0x3d>
			cons.wpos = 0;
f0100a9f:	c7 05 24 62 24 f0 00 	movl   $0x0,0xf0246224
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
f0100ac9:	8b 15 20 62 24 f0    	mov    0xf0246220,%edx
f0100acf:	a1 24 62 24 f0       	mov    0xf0246224,%eax
f0100ad4:	39 c2                	cmp    %eax,%edx
f0100ad6:	74 36                	je     f0100b0e <cons_getc+0x55>
		c = cons.buf[cons.rpos++];
f0100ad8:	a1 20 62 24 f0       	mov    0xf0246220,%eax
f0100add:	8d 50 01             	lea    0x1(%eax),%edx
f0100ae0:	89 15 20 62 24 f0    	mov    %edx,0xf0246220
f0100ae6:	0f b6 80 20 60 24 f0 	movzbl -0xfdb9fe0(%eax),%eax
f0100aed:	0f b6 c0             	movzbl %al,%eax
f0100af0:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f0100af3:	a1 20 62 24 f0       	mov    0xf0246220,%eax
f0100af8:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100afd:	75 0a                	jne    f0100b09 <cons_getc+0x50>
			cons.rpos = 0;
f0100aff:	c7 05 20 62 24 f0 00 	movl   $0x0,0xf0246220
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
f0100b84:	0f b6 05 00 60 24 f0 	movzbl 0xf0246000,%eax
f0100b8b:	83 f0 01             	xor    $0x1,%eax
f0100b8e:	84 c0                	test   %al,%al
f0100b90:	74 0c                	je     f0100b9e <cons_init+0x2f>
		cprintf("Serial port does not exist!\n");
f0100b92:	c7 04 24 ee 93 10 f0 	movl   $0xf01093ee,(%esp)
f0100b99:	e8 12 44 00 00       	call   f0104fb0 <cprintf>
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
f0100be2:	c7 04 24 da 94 10 f0 	movl   $0xf01094da,(%esp)
f0100be9:	e8 c2 43 00 00       	call   f0104fb0 <cprintf>
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
f0100c15:	c7 04 24 ec 94 10 f0 	movl   $0xf01094ec,(%esp)
f0100c1c:	e8 8f 43 00 00       	call   f0104fb0 <cprintf>
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
f0100c4c:	c7 04 24 da 94 10 f0 	movl   $0xf01094da,(%esp)
f0100c53:	e8 58 43 00 00       	call   f0104fb0 <cprintf>
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
f0100c7f:	c7 04 24 ec 94 10 f0 	movl   $0xf01094ec,(%esp)
f0100c86:	e8 25 43 00 00       	call   f0104fb0 <cprintf>
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
f0100ce8:	c7 04 24 24 95 10 f0 	movl   $0xf0109524,(%esp)
f0100cef:	e8 bc 42 00 00       	call   f0104fb0 <cprintf>
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
f0100d0d:	c7 04 24 2d 95 10 f0 	movl   $0xf010952d,(%esp)
f0100d14:	e8 97 42 00 00       	call   f0104fb0 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100d19:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100d20:	00 
f0100d21:	c7 04 24 48 95 10 f0 	movl   $0xf0109548,(%esp)
f0100d28:	e8 83 42 00 00       	call   f0104fb0 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100d2d:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100d34:	00 
f0100d35:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100d3c:	f0 
f0100d3d:	c7 04 24 70 95 10 f0 	movl   $0xf0109570,(%esp)
f0100d44:	e8 67 42 00 00       	call   f0104fb0 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100d49:	c7 44 24 08 07 93 10 	movl   $0x109307,0x8(%esp)
f0100d50:	00 
f0100d51:	c7 44 24 04 07 93 10 	movl   $0xf0109307,0x4(%esp)
f0100d58:	f0 
f0100d59:	c7 04 24 94 95 10 f0 	movl   $0xf0109594,(%esp)
f0100d60:	e8 4b 42 00 00       	call   f0104fb0 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100d65:	c7 44 24 08 7c 57 24 	movl   $0x24577c,0x8(%esp)
f0100d6c:	00 
f0100d6d:	c7 44 24 04 7c 57 24 	movl   $0xf024577c,0x4(%esp)
f0100d74:	f0 
f0100d75:	c7 04 24 b8 95 10 f0 	movl   $0xf01095b8,(%esp)
f0100d7c:	e8 2f 42 00 00       	call   f0104fb0 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100d81:	c7 44 24 08 08 80 28 	movl   $0x288008,0x8(%esp)
f0100d88:	00 
f0100d89:	c7 44 24 04 08 80 28 	movl   $0xf0288008,0x4(%esp)
f0100d90:	f0 
f0100d91:	c7 04 24 dc 95 10 f0 	movl   $0xf01095dc,(%esp)
f0100d98:	e8 13 42 00 00       	call   f0104fb0 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100d9d:	c7 45 f4 00 04 00 00 	movl   $0x400,-0xc(%ebp)
f0100da4:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100dac:	29 c2                	sub    %eax,%edx
f0100dae:	b8 08 80 28 f0       	mov    $0xf0288008,%eax
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
f0100de1:	c7 04 24 00 96 10 f0 	movl   $0xf0109600,(%esp)
f0100de8:	e8 c3 41 00 00       	call   f0104fb0 <cprintf>
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
f0100e2f:	c7 04 24 2a 96 10 f0 	movl   $0xf010962a,(%esp)
f0100e36:	e8 75 41 00 00       	call   f0104fb0 <cprintf>

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
f0100e55:	c7 04 24 3c 96 10 f0 	movl   $0xf010963c,(%esp)
f0100e5c:	e8 4f 41 00 00       	call   f0104fb0 <cprintf>

	struct Eipdebuginfo eip_info;
	int eip_ret_info = debuginfo_eip(eip,&eip_info);
f0100e61:	8d 45 b8             	lea    -0x48(%ebp),%eax
f0100e64:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e68:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e6b:	89 04 24             	mov    %eax,(%esp)
f0100e6e:	e8 1c 65 00 00       	call   f010738f <debuginfo_eip>
f0100e73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if(eip_ret_info == 0){
f0100e76:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100e7a:	75 6c                	jne    f0100ee8 <mon_backtrace+0xc2>
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
f0100e7c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100e7f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100e82:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e8a:	c7 04 24 50 96 10 f0 	movl   $0xf0109650,(%esp)
f0100e91:	e8 1a 41 00 00       	call   f0104fb0 <cprintf>
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
f0100eb1:	c7 04 24 59 96 10 f0 	movl   $0xf0109659,(%esp)
f0100eb8:	e8 f3 40 00 00       	call   f0104fb0 <cprintf>
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
f0100ed7:	c7 04 24 5c 96 10 f0 	movl   $0xf010965c,(%esp)
f0100ede:	e8 cd 40 00 00       	call   f0104fb0 <cprintf>
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
f0100f3c:	c7 04 24 64 96 10 f0 	movl   $0xf0109664,(%esp)
f0100f43:	e8 68 40 00 00       	call   f0104fb0 <cprintf>
		eip = *(ebp+1);
f0100f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f4b:	8b 40 04             	mov    0x4(%eax),%eax
f0100f4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		eip_ret_info = debuginfo_eip(eip,&eip_info);
f0100f51:	8d 45 b8             	lea    -0x48(%ebp),%eax
f0100f54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f58:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f5b:	89 04 24             	mov    %eax,(%esp)
f0100f5e:	e8 2c 64 00 00       	call   f010738f <debuginfo_eip>
f0100f63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if(eip_ret_info == 0){
f0100f66:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f6a:	75 67                	jne    f0100fd3 <mon_backtrace+0x1ad>
			cprintf("\t%s:%d: ",eip_info.eip_file, eip_info.eip_line);
f0100f6c:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100f6f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100f72:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100f76:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f7a:	c7 04 24 50 96 10 f0 	movl   $0xf0109650,(%esp)
f0100f81:	e8 2a 40 00 00       	call   f0104fb0 <cprintf>
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
f0100fa1:	c7 04 24 59 96 10 f0 	movl   $0xf0109659,(%esp)
f0100fa8:	e8 03 40 00 00       	call   f0104fb0 <cprintf>
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
f0100fc7:	c7 04 24 5c 96 10 f0 	movl   $0xf010965c,(%esp)
f0100fce:	e8 dd 3f 00 00       	call   f0104fb0 <cprintf>
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
f010102f:	c7 04 24 99 96 10 f0 	movl   $0xf0109699,(%esp)
f0101036:	e8 bb 70 00 00       	call   f01080f6 <strchr>
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
f010106b:	c7 04 24 9e 96 10 f0 	movl   $0xf010969e,(%esp)
f0101072:	e8 39 3f 00 00       	call   f0104fb0 <cprintf>
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
f01010ae:	c7 04 24 99 96 10 f0 	movl   $0xf0109699,(%esp)
f01010b5:	e8 3c 70 00 00       	call   f01080f6 <strchr>
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
f01010f1:	e8 6b 6f 00 00       	call   f0108061 <strcmp>
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
f0101139:	c7 04 24 bb 96 10 f0 	movl   $0xf01096bb,(%esp)
f0101140:	e8 6b 3e 00 00       	call   f0104fb0 <cprintf>
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
f0101152:	c7 04 24 d4 96 10 f0 	movl   $0xf01096d4,(%esp)
f0101159:	e8 52 3e 00 00       	call   f0104fb0 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010115e:	c7 04 24 f8 96 10 f0 	movl   $0xf01096f8,(%esp)
f0101165:	e8 46 3e 00 00       	call   f0104fb0 <cprintf>

	if (tf != NULL)
f010116a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010116e:	74 0b                	je     f010117b <monitor+0x2f>
		print_trapframe(tf);
f0101170:	8b 45 08             	mov    0x8(%ebp),%eax
f0101173:	89 04 24             	mov    %eax,(%esp)
f0101176:	e8 87 4c 00 00       	call   f0105e02 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f010117b:	c7 04 24 1d 97 10 f0 	movl   $0xf010971d,(%esp)
f0101182:	e8 a1 6c 00 00       	call   f0107e28 <readline>
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
f01011c3:	c7 44 24 08 24 97 10 	movl   $0xf0109724,0x8(%esp)
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
f01011f5:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f01011fa:	39 c2                	cmp    %eax,%edx
f01011fc:	72 21                	jb     f010121f <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0101201:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101205:	c7 44 24 08 48 97 10 	movl   $0xf0109748,0x8(%esp)
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
f010122f:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f010124e:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f0101253:	39 c2                	cmp    %eax,%edx
f0101255:	72 1c                	jb     f0101273 <pa2page+0x33>
		panic("pa2page called with invalid pa");
f0101257:	c7 44 24 08 6c 97 10 	movl   $0xf010976c,0x8(%esp)
f010125e:	f0 
f010125f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101266:	00 
f0101267:	c7 04 24 8b 97 10 f0 	movl   $0xf010978b,(%esp)
f010126e:	e8 5c f0 ff ff       	call   f01002cf <_panic>
	return &pages[PGNUM(pa)];
f0101273:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f01012a2:	c7 04 24 8b 97 10 f0 	movl   $0xf010978b,(%esp)
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
f01012bd:	e8 3d 3a 00 00       	call   f0104cff <mc146818_read>
f01012c2:	89 c3                	mov    %eax,%ebx
f01012c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c7:	83 c0 01             	add    $0x1,%eax
f01012ca:	89 04 24             	mov    %eax,(%esp)
f01012cd:	e8 2d 3a 00 00       	call   f0104cff <mc146818_read>
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
f0101300:	a3 2c 62 24 f0       	mov    %eax,0xf024622c
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
f0101333:	a3 e8 6e 24 f0       	mov    %eax,0xf0246ee8
f0101338:	eb 0a                	jmp    f0101344 <i386_detect_memory+0x67>
	else
		npages = npages_basemem;
f010133a:	a1 2c 62 24 f0       	mov    0xf024622c,%eax
f010133f:	a3 e8 6e 24 f0       	mov    %eax,0xf0246ee8

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
f010134f:	a1 2c 62 24 f0       	mov    0xf024622c,%eax
f0101354:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101357:	c1 e8 0a             	shr    $0xa,%eax
f010135a:	89 c2                	mov    %eax,%edx
		npages * PGSIZE / 1024,
f010135c:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
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
f0101373:	c7 04 24 9c 97 10 f0 	movl   $0xf010979c,(%esp)
f010137a:	e8 31 3c 00 00       	call   f0104fb0 <cprintf>
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
f0101387:	a1 38 62 24 f0       	mov    0xf0246238,%eax
f010138c:	85 c0                	test   %eax,%eax
f010138e:	75 30                	jne    f01013c0 <boot_alloc+0x3f>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101390:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0101397:	b8 08 80 28 f0       	mov    $0xf0288008,%eax
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
f01013bb:	a3 38 62 24 f0       	mov    %eax,0xf0246238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01013c0:	a1 38 62 24 f0       	mov    0xf0246238,%eax
f01013c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	char *nres = nextfree;
f01013c8:	a1 38 62 24 f0       	mov    0xf0246238,%eax
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
f01013fb:	a1 38 62 24 f0       	mov    0xf0246238,%eax
f0101400:	01 d0                	add    %edx,%eax
f0101402:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(PADDR(result) > npages*PGSIZE){
f0101405:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101408:	89 44 24 08          	mov    %eax,0x8(%esp)
f010140c:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f0101413:	00 
f0101414:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010141b:	e8 8c fd ff ff       	call   f01011ac <_paddr>
f0101420:	8b 15 e8 6e 24 f0    	mov    0xf0246ee8,%edx
f0101426:	c1 e2 0c             	shl    $0xc,%edx
f0101429:	39 d0                	cmp    %edx,%eax
f010142b:	76 1c                	jbe    f0101449 <boot_alloc+0xc8>
		panic("OUT OF MEMORY!\n");
f010142d:	c7 44 24 08 e4 97 10 	movl   $0xf01097e4,0x8(%esp)
f0101434:	f0 
f0101435:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f010143c:	00 
f010143d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0101444:	e8 86 ee ff ff       	call   f01002cf <_panic>
	}
	else{
		nextfree = nres;
f0101449:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010144c:	a3 38 62 24 f0       	mov    %eax,0xf0246238
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
f010146e:	a3 ec 6e 24 f0       	mov    %eax,0xf0246eec
	memset(kern_pgdir, 0, PGSIZE);
f0101473:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0101478:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010147f:	00 
f0101480:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101487:	00 
f0101488:	89 04 24             	mov    %eax,(%esp)
f010148b:	e8 c7 6c 00 00       	call   f0108157 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101490:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0101495:	8d 98 f4 0e 00 00    	lea    0xef4(%eax),%ebx
f010149b:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01014a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014a4:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01014ab:	00 
f01014ac:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01014b3:	e8 f4 fc ff ff       	call   f01011ac <_paddr>
f01014b8:	83 c8 05             	or     $0x5,%eax
f01014bb:	89 03                	mov    %eax,(%ebx)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = boot_alloc(npages*(sizeof(struct PageInfo)));
f01014bd:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f01014c2:	c1 e0 03             	shl    $0x3,%eax
f01014c5:	89 04 24             	mov    %eax,(%esp)
f01014c8:	e8 b4 fe ff ff       	call   f0101381 <boot_alloc>
f01014cd:	a3 f0 6e 24 f0       	mov    %eax,0xf0246ef0
	memset(pages,0,npages*sizeof(struct PageInfo));
f01014d2:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f01014d7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01014de:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f01014e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01014e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014ee:	00 
f01014ef:	89 04 24             	mov    %eax,(%esp)
f01014f2:	e8 60 6c 00 00       	call   f0108157 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env));
f01014f7:	c7 04 24 00 f0 01 00 	movl   $0x1f000,(%esp)
f01014fe:	e8 7e fe ff ff       	call   f0101381 <boot_alloc>
f0101503:	a3 3c 62 24 f0       	mov    %eax,0xf024623c
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
f0101523:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101528:	89 44 24 08          	mov    %eax,0x8(%esp)
f010152c:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
f0101533:	00 
f0101534:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010153b:	e8 6c fc ff ff       	call   f01011ac <_paddr>
f0101540:	8b 15 ec 6e 24 f0    	mov    0xf0246eec,%edx
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
f010156a:	a1 3c 62 24 f0       	mov    0xf024623c,%eax
f010156f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101573:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f010157a:	00 
f010157b:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0101582:	e8 25 fc ff ff       	call   f01011ac <_paddr>
f0101587:	8b 15 ec 6e 24 f0    	mov    0xf0246eec,%edx
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
f01015c1:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01015c8:	e8 df fb ff ff       	call   f01011ac <_paddr>
f01015cd:	8b 15 ec 6e 24 f0    	mov    0xf0246eec,%edx
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
f01015f7:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f010162e:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0101633:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101637:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f010163e:	00 
f010163f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01016b8:	05 00 80 24 f0       	add    $0xf0248000,%eax
f01016bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016c1:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
f01016c8:	00 
f01016c9:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01016d0:	e8 d7 fa ff ff       	call   f01011ac <_paddr>
f01016d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01016d8:	8d 8a 00 80 ff ff    	lea    -0x8000(%edx),%ecx
f01016de:	8b 15 ec 6e 24 f0    	mov    0xf0246eec,%edx
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
f0101716:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f010171b:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0101721:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f0101744:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101749:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010174c:	c1 e2 03             	shl    $0x3,%edx
f010174f:	01 d0                	add    %edx,%eax
f0101751:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0101757:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f010175c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010175f:	c1 e2 03             	shl    $0x3,%edx
f0101762:	01 c2                	add    %eax,%edx
f0101764:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f0101769:	89 02                	mov    %eax,(%edx)
			page_free_list = &pages[i];
f010176b:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101770:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101773:	c1 e2 03             	shl    $0x3,%edx
f0101776:	01 d0                	add    %edx,%eax
f0101778:	a3 30 62 24 f0       	mov    %eax,0xf0246230
	// 	page_free_list = &pages[i];
	// }
	pages[0].pp_ref = 1;
	pages[0].pp_link = NULL;
	size_t mpentry_paddr_pg = PGNUM(MPENTRY_PADDR);
	for (i = 1; i<npages_basemem; i++){
f010177d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101781:	a1 2c 62 24 f0       	mov    0xf024622c,%eax
f0101786:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101789:	72 b1                	jb     f010173c <page_init+0x2c>
			page_free_list = &pages[i];
		}
	}
	// cprintf("npages_basemem : %d\n", npages_basemem);
	// cprintf("PGNUM(MPENTRY_PADDR): %d\n",PGNUM(MPENTRY_PADDR));
	pages[mpentry_paddr_pg].pp_ref = 1;
f010178b:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101790:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101793:	c1 e2 03             	shl    $0x3,%edx
f0101796:	01 d0                	add    %edx,%eax
f0101798:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[mpentry_paddr_pg].pp_link = NULL;
f010179e:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f01017c9:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f01017ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01017d1:	c1 e2 03             	shl    $0x3,%edx
f01017d4:	01 d0                	add    %edx,%eax
f01017d6:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = NULL;
f01017dc:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f0101802:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0101825:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010182c:	e8 7b f9 ff ff       	call   f01011ac <_paddr>
f0101831:	c1 e8 0c             	shr    $0xc,%eax
f0101834:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101837:	eb 3d                	jmp    f0101876 <page_init+0x166>
		pages[i].pp_ref = 0;
f0101839:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f010183e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101841:	c1 e2 03             	shl    $0x3,%edx
f0101844:	01 d0                	add    %edx,%eax
f0101846:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f010184c:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101851:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101854:	c1 e2 03             	shl    $0x3,%edx
f0101857:	01 c2                	add    %eax,%edx
f0101859:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f010185e:	89 02                	mov    %eax,(%edx)
		page_free_list = &pages[i];
f0101860:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101865:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101868:	c1 e2 03             	shl    $0x3,%edx
f010186b:	01 d0                	add    %edx,%eax
f010186d:	a3 30 62 24 f0       	mov    %eax,0xf0246230
	char *next_free = boot_alloc(0);
	for (i = PGNUM(IOPHYSMEM);i<PGNUM(PADDR(next_free)); i++){
		pages[i].pp_ref = 1;
		pages[i].pp_link = NULL;
	}
	for(i = PGNUM(PADDR(next_free)); i<npages; i++){
f0101872:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0101876:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
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
f0101888:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f010188d:	85 c0                	test   %eax,%eax
f010188f:	75 07                	jne    f0101898 <page_alloc+0x16>
		return NULL;
f0101891:	b8 00 00 00 00       	mov    $0x0,%eax
f0101896:	eb 4b                	jmp    f01018e3 <page_alloc+0x61>
	}
	struct PageInfo *pp = page_free_list;
f0101898:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f010189d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	page_free_list = pp->pp_link;
f01018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018a3:	8b 00                	mov    (%eax),%eax
f01018a5:	a3 30 62 24 f0       	mov    %eax,0xf0246230
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
f01018d2:	e8 80 68 00 00       	call   f0108157 <memset>
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
f01018f7:	c7 44 24 08 f4 97 10 	movl   $0xf01097f4,0x8(%esp)
f01018fe:	f0 
f01018ff:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0101906:	00 
f0101907:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010190e:	e8 bc e9 ff ff       	call   f01002cf <_panic>
	}
	else if(pp->pp_link){
f0101913:	8b 45 08             	mov    0x8(%ebp),%eax
f0101916:	8b 00                	mov    (%eax),%eax
f0101918:	85 c0                	test   %eax,%eax
f010191a:	74 1c                	je     f0101938 <page_free+0x53>
		panic("pp_link of page not null!\n");
f010191c:	c7 44 24 08 0e 98 10 	movl   $0xf010980e,0x8(%esp)
f0101923:	f0 
f0101924:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f010192b:	00 
f010192c:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0101933:	e8 97 e9 ff ff       	call   f01002cf <_panic>
	}
	else{
		pp->pp_link = page_free_list;
f0101938:	8b 15 30 62 24 f0    	mov    0xf0246230,%edx
f010193e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101941:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0101943:	8b 45 08             	mov    0x8(%ebp),%eax
f0101946:	a3 30 62 24 f0       	mov    %eax,0xf0246230
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
f0101a43:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0101a81:	c7 44 24 0c 29 98 10 	movl   $0xf0109829,0xc(%esp)
f0101a88:	f0 
f0101a89:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0101a90:	f0 
f0101a91:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0101a98:	00 
f0101a99:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0101c46:	e8 d7 6f 00 00       	call   f0108c22 <cpunum>
f0101c4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c4e:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0101c53:	8b 00                	mov    (%eax),%eax
f0101c55:	85 c0                	test   %eax,%eax
f0101c57:	74 17                	je     f0101c70 <tlb_invalidate+0x30>
f0101c59:	e8 c4 6f 00 00       	call   f0108c22 <cpunum>
f0101c5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101c61:	05 28 70 24 f0       	add    $0xf0247028,%eax
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
f0101cc2:	c7 44 24 08 4f 98 10 	movl   $0xf010984f,0x8(%esp)
f0101cc9:	f0 
f0101cca:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
f0101cd1:	00 
f0101cd2:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0101cd9:	e8 f1 e5 ff ff       	call   f01002cf <_panic>

	boot_map_region(kern_pgdir, base, aligned_size, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101cde:	8b 15 5c 65 12 f0    	mov    0xf012655c,%edx
f0101ce4:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0101dc0:	a3 34 62 24 f0       	mov    %eax,0xf0246234
f0101dc5:	eb 08                	jmp    f0101dcf <user_mem_check+0xa7>
			else user_mem_check_addr = (uintptr_t)va;
f0101dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101dca:	a3 34 62 24 f0       	mov    %eax,0xf0246234
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
f0101e1e:	8b 15 34 62 24 f0    	mov    0xf0246234,%edx
f0101e24:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e27:	8b 40 48             	mov    0x48(%eax),%eax
f0101e2a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101e2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e32:	c7 04 24 6c 98 10 f0 	movl   $0xf010986c,(%esp)
f0101e39:	e8 72 31 00 00       	call   f0104fb0 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0101e3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e41:	89 04 24             	mov    %eax,(%esp)
f0101e44:	e8 32 2d 00 00       	call   f0104b7b <env_destroy>
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
f0101e7a:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f0101e7f:	85 c0                	test   %eax,%eax
f0101e81:	75 1c                	jne    f0101e9f <check_page_free_list+0x54>
		panic("'page_free_list' is a null pointer!");
f0101e83:	c7 44 24 08 a4 98 10 	movl   $0xf01098a4,0x8(%esp)
f0101e8a:	f0 
f0101e8b:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0101e92:	00 
f0101e93:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0101eb1:	a1 30 62 24 f0       	mov    0xf0246230,%eax
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
f0101f0d:	a3 30 62 24 f0       	mov    %eax,0xf0246230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f12:	a1 30 62 24 f0       	mov    0xf0246230,%eax
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
f0101f4d:	e8 05 62 00 00       	call   f0108157 <memset>
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
f0101f6f:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f0101f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f77:	e9 13 02 00 00       	jmp    f010218f <check_page_free_list+0x344>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101f7c:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101f81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0101f84:	73 24                	jae    f0101faa <check_page_free_list+0x15f>
f0101f86:	c7 44 24 0c c8 98 10 	movl   $0xf01098c8,0xc(%esp)
f0101f8d:	f0 
f0101f8e:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101f9d:	00 
f0101f9e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0101fa5:	e8 25 e3 ff ff       	call   f01002cf <_panic>
		assert(pp < pages + npages);
f0101faa:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101faf:	8b 15 e8 6e 24 f0    	mov    0xf0246ee8,%edx
f0101fb5:	c1 e2 03             	shl    $0x3,%edx
f0101fb8:	01 d0                	add    %edx,%eax
f0101fba:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101fbd:	77 24                	ja     f0101fe3 <check_page_free_list+0x198>
f0101fbf:	c7 44 24 0c d4 98 10 	movl   $0xf01098d4,0xc(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0101fce:	f0 
f0101fcf:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101fd6:	00 
f0101fd7:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0101fde:	e8 ec e2 ff ff       	call   f01002cf <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101fe3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101fe6:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f0101feb:	29 c2                	sub    %eax,%edx
f0101fed:	89 d0                	mov    %edx,%eax
f0101fef:	83 e0 07             	and    $0x7,%eax
f0101ff2:	85 c0                	test   %eax,%eax
f0101ff4:	74 24                	je     f010201a <check_page_free_list+0x1cf>
f0101ff6:	c7 44 24 0c e8 98 10 	movl   $0xf01098e8,0xc(%esp)
f0101ffd:	f0 
f0101ffe:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102005:	f0 
f0102006:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f010200d:	00 
f010200e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102015:	e8 b5 e2 ff ff       	call   f01002cf <_panic>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010201a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010201d:	89 04 24             	mov    %eax,(%esp)
f0102020:	e8 04 f2 ff ff       	call   f0101229 <page2pa>
f0102025:	85 c0                	test   %eax,%eax
f0102027:	75 24                	jne    f010204d <check_page_free_list+0x202>
f0102029:	c7 44 24 0c 1a 99 10 	movl   $0xf010991a,0xc(%esp)
f0102030:	f0 
f0102031:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102038:	f0 
f0102039:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0102040:	00 
f0102041:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102048:	e8 82 e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010204d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102050:	89 04 24             	mov    %eax,(%esp)
f0102053:	e8 d1 f1 ff ff       	call   f0101229 <page2pa>
f0102058:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010205d:	75 24                	jne    f0102083 <check_page_free_list+0x238>
f010205f:	c7 44 24 0c 2b 99 10 	movl   $0xf010992b,0xc(%esp)
f0102066:	f0 
f0102067:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010206e:	f0 
f010206f:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0102076:	00 
f0102077:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010207e:	e8 4c e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0102083:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102086:	89 04 24             	mov    %eax,(%esp)
f0102089:	e8 9b f1 ff ff       	call   f0101229 <page2pa>
f010208e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0102093:	75 24                	jne    f01020b9 <check_page_free_list+0x26e>
f0102095:	c7 44 24 0c 44 99 10 	movl   $0xf0109944,0xc(%esp)
f010209c:	f0 
f010209d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01020a4:	f0 
f01020a5:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f01020ac:	00 
f01020ad:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01020b4:	e8 16 e2 ff ff       	call   f01002cf <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01020b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020bc:	89 04 24             	mov    %eax,(%esp)
f01020bf:	e8 65 f1 ff ff       	call   f0101229 <page2pa>
f01020c4:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01020c9:	75 24                	jne    f01020ef <check_page_free_list+0x2a4>
f01020cb:	c7 44 24 0c 67 99 10 	movl   $0xf0109967,0xc(%esp)
f01020d2:	f0 
f01020d3:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01020da:	f0 
f01020db:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01020e2:	00 
f01020e3:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102111:	c7 44 24 0c 84 99 10 	movl   $0xf0109984,0xc(%esp)
f0102118:	f0 
f0102119:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102120:	f0 
f0102121:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0102128:	00 
f0102129:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102130:	e8 9a e1 ff ff       	call   f01002cf <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0102135:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102138:	89 04 24             	mov    %eax,(%esp)
f010213b:	e8 e9 f0 ff ff       	call   f0101229 <page2pa>
f0102140:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0102145:	75 24                	jne    f010216b <check_page_free_list+0x320>
f0102147:	c7 44 24 0c c9 99 10 	movl   $0xf01099c9,0xc(%esp)
f010214e:	f0 
f010214f:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102156:	f0 
f0102157:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f010215e:	00 
f010215f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f010219f:	c7 44 24 0c e6 99 10 	movl   $0xf01099e6,0xc(%esp)
f01021a6:	f0 
f01021a7:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01021ae:	f0 
f01021af:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01021b6:	00 
f01021b7:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01021be:	e8 0c e1 ff ff       	call   f01002cf <_panic>
	assert(nfree_extmem > 0);
f01021c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01021c7:	7f 24                	jg     f01021ed <check_page_free_list+0x3a2>
f01021c9:	c7 44 24 0c f8 99 10 	movl   $0xf01099f8,0xc(%esp)
f01021d0:	f0 
f01021d1:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01021d8:	f0 
f01021d9:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01021e0:	00 
f01021e1:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01021f5:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f01021fa:	85 c0                	test   %eax,%eax
f01021fc:	75 1c                	jne    f010221a <check_page_alloc+0x2b>
		panic("'pages' is a null pointer!");
f01021fe:	c7 44 24 08 09 9a 10 	movl   $0xf0109a09,0x8(%esp)
f0102205:	f0 
f0102206:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f010220d:	00 
f010220e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102215:	e8 b5 e0 ff ff       	call   f01002cf <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010221a:	a1 30 62 24 f0       	mov    0xf0246230,%eax
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
f0102265:	c7 44 24 0c 24 9a 10 	movl   $0xf0109a24,0xc(%esp)
f010226c:	f0 
f010226d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102274:	f0 
f0102275:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f010227c:	00 
f010227d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102284:	e8 46 e0 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0102289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102290:	e8 ed f5 ff ff       	call   f0101882 <page_alloc>
f0102295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102298:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010229c:	75 24                	jne    f01022c2 <check_page_alloc+0xd3>
f010229e:	c7 44 24 0c 3a 9a 10 	movl   $0xf0109a3a,0xc(%esp)
f01022a5:	f0 
f01022a6:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01022ad:	f0 
f01022ae:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f01022b5:	00 
f01022b6:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01022bd:	e8 0d e0 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f01022c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022c9:	e8 b4 f5 ff ff       	call   f0101882 <page_alloc>
f01022ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01022d1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01022d5:	75 24                	jne    f01022fb <check_page_alloc+0x10c>
f01022d7:	c7 44 24 0c 50 9a 10 	movl   $0xf0109a50,0xc(%esp)
f01022de:	f0 
f01022df:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01022e6:	f0 
f01022e7:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01022ee:	00 
f01022ef:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01022f6:	e8 d4 df ff ff       	call   f01002cf <_panic>

	assert(pp0);
f01022fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01022ff:	75 24                	jne    f0102325 <check_page_alloc+0x136>
f0102301:	c7 44 24 0c 66 9a 10 	movl   $0xf0109a66,0xc(%esp)
f0102308:	f0 
f0102309:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102310:	f0 
f0102311:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0102318:	00 
f0102319:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102320:	e8 aa df ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102325:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102329:	74 08                	je     f0102333 <check_page_alloc+0x144>
f010232b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010232e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102331:	75 24                	jne    f0102357 <check_page_alloc+0x168>
f0102333:	c7 44 24 0c 6a 9a 10 	movl   $0xf0109a6a,0xc(%esp)
f010233a:	f0 
f010233b:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102342:	f0 
f0102343:	c7 44 24 04 fc 02 00 	movl   $0x2fc,0x4(%esp)
f010234a:	00 
f010234b:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f010236d:	c7 44 24 0c 7c 9a 10 	movl   $0xf0109a7c,0xc(%esp)
f0102374:	f0 
f0102375:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010237c:	f0 
f010237d:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0102384:	00 
f0102385:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010238c:	e8 3e df ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0102391:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102394:	89 04 24             	mov    %eax,(%esp)
f0102397:	e8 8d ee ff ff       	call   f0101229 <page2pa>
f010239c:	8b 15 e8 6e 24 f0    	mov    0xf0246ee8,%edx
f01023a2:	c1 e2 0c             	shl    $0xc,%edx
f01023a5:	39 d0                	cmp    %edx,%eax
f01023a7:	72 24                	jb     f01023cd <check_page_alloc+0x1de>
f01023a9:	c7 44 24 0c 9c 9a 10 	movl   $0xf0109a9c,0xc(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01023b8:	f0 
f01023b9:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f01023c0:	00 
f01023c1:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01023c8:	e8 02 df ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01023cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01023d0:	89 04 24             	mov    %eax,(%esp)
f01023d3:	e8 51 ee ff ff       	call   f0101229 <page2pa>
f01023d8:	8b 15 e8 6e 24 f0    	mov    0xf0246ee8,%edx
f01023de:	c1 e2 0c             	shl    $0xc,%edx
f01023e1:	39 d0                	cmp    %edx,%eax
f01023e3:	72 24                	jb     f0102409 <check_page_alloc+0x21a>
f01023e5:	c7 44 24 0c b9 9a 10 	movl   $0xf0109ab9,0xc(%esp)
f01023ec:	f0 
f01023ed:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01023f4:	f0 
f01023f5:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01023fc:	00 
f01023fd:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102404:	e8 c6 de ff ff       	call   f01002cf <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102409:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010240c:	89 04 24             	mov    %eax,(%esp)
f010240f:	e8 15 ee ff ff       	call   f0101229 <page2pa>
f0102414:	8b 15 e8 6e 24 f0    	mov    0xf0246ee8,%edx
f010241a:	c1 e2 0c             	shl    $0xc,%edx
f010241d:	39 d0                	cmp    %edx,%eax
f010241f:	72 24                	jb     f0102445 <check_page_alloc+0x256>
f0102421:	c7 44 24 0c d6 9a 10 	movl   $0xf0109ad6,0xc(%esp)
f0102428:	f0 
f0102429:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102430:	f0 
f0102431:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0102438:	00 
f0102439:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102440:	e8 8a de ff ff       	call   f01002cf <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102445:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f010244a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f010244d:	c7 05 30 62 24 f0 00 	movl   $0x0,0xf0246230
f0102454:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010245e:	e8 1f f4 ff ff       	call   f0101882 <page_alloc>
f0102463:	85 c0                	test   %eax,%eax
f0102465:	74 24                	je     f010248b <check_page_alloc+0x29c>
f0102467:	c7 44 24 0c f3 9a 10 	movl   $0xf0109af3,0xc(%esp)
f010246e:	f0 
f010246f:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102476:	f0 
f0102477:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f010247e:	00 
f010247f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01024d4:	c7 44 24 0c 24 9a 10 	movl   $0xf0109a24,0xc(%esp)
f01024db:	f0 
f01024dc:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01024e3:	f0 
f01024e4:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f01024eb:	00 
f01024ec:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01024f3:	e8 d7 dd ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f01024f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024ff:	e8 7e f3 ff ff       	call   f0101882 <page_alloc>
f0102504:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010250b:	75 24                	jne    f0102531 <check_page_alloc+0x342>
f010250d:	c7 44 24 0c 3a 9a 10 	movl   $0xf0109a3a,0xc(%esp)
f0102514:	f0 
f0102515:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010251c:	f0 
f010251d:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0102524:	00 
f0102525:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010252c:	e8 9e dd ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0102531:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102538:	e8 45 f3 ff ff       	call   f0101882 <page_alloc>
f010253d:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102544:	75 24                	jne    f010256a <check_page_alloc+0x37b>
f0102546:	c7 44 24 0c 50 9a 10 	movl   $0xf0109a50,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102565:	e8 65 dd ff ff       	call   f01002cf <_panic>
	assert(pp0);
f010256a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010256e:	75 24                	jne    f0102594 <check_page_alloc+0x3a5>
f0102570:	c7 44 24 0c 66 9a 10 	movl   $0xf0109a66,0xc(%esp)
f0102577:	f0 
f0102578:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010257f:	f0 
f0102580:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0102587:	00 
f0102588:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010258f:	e8 3b dd ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102594:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102598:	74 08                	je     f01025a2 <check_page_alloc+0x3b3>
f010259a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010259d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01025a0:	75 24                	jne    f01025c6 <check_page_alloc+0x3d7>
f01025a2:	c7 44 24 0c 6a 9a 10 	movl   $0xf0109a6a,0xc(%esp)
f01025a9:	f0 
f01025aa:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01025b1:	f0 
f01025b2:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f01025b9:	00 
f01025ba:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01025dc:	c7 44 24 0c 7c 9a 10 	movl   $0xf0109a7c,0xc(%esp)
f01025e3:	f0 
f01025e4:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01025f3:	00 
f01025f4:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01025fb:	e8 cf dc ff ff       	call   f01002cf <_panic>
	assert(!page_alloc(0));
f0102600:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102607:	e8 76 f2 ff ff       	call   f0101882 <page_alloc>
f010260c:	85 c0                	test   %eax,%eax
f010260e:	74 24                	je     f0102634 <check_page_alloc+0x445>
f0102610:	c7 44 24 0c f3 9a 10 	movl   $0xf0109af3,0xc(%esp)
f0102617:	f0 
f0102618:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010261f:	f0 
f0102620:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0102627:	00 
f0102628:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102652:	e8 00 5b 00 00       	call   f0108157 <memset>
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
f0102677:	c7 44 24 0c 02 9b 10 	movl   $0xf0109b02,0xc(%esp)
f010267e:	f0 
f010267f:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102686:	f0 
f0102687:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010268e:	00 
f010268f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102696:	e8 34 dc ff ff       	call   f01002cf <_panic>
	assert(pp && pp0 == pp);
f010269b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010269f:	74 08                	je     f01026a9 <check_page_alloc+0x4ba>
f01026a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01026a4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01026a7:	74 24                	je     f01026cd <check_page_alloc+0x4de>
f01026a9:	c7 44 24 0c 20 9b 10 	movl   $0xf0109b20,0xc(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01026b8:	f0 
f01026b9:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f01026c0:	00 
f01026c1:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01026f3:	c7 44 24 0c 30 9b 10 	movl   $0xf0109b30,0xc(%esp)
f01026fa:	f0 
f01026fb:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102702:	f0 
f0102703:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f010270a:	00 
f010270b:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102727:	a3 30 62 24 f0       	mov    %eax,0xf0246230

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
f010274d:	a1 30 62 24 f0       	mov    0xf0246230,%eax
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
f010276f:	c7 44 24 0c 3a 9b 10 	movl   $0xf0109b3a,0xc(%esp)
f0102776:	f0 
f0102777:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010277e:	f0 
f010277f:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0102786:	00 
f0102787:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010278e:	e8 3c db ff ff       	call   f01002cf <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102793:	c7 04 24 48 9b 10 f0 	movl   $0xf0109b48,(%esp)
f010279a:	e8 11 28 00 00       	call   f0104fb0 <cprintf>
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
f01027a8:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01027ad:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027b0:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
f01027b7:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
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
f0102807:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
f010280c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102810:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0102817:	00 
f0102818:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010281f:	e8 88 e9 ff ff       	call   f01011ac <_paddr>
f0102824:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102827:	01 d0                	add    %edx,%eax
f0102829:	39 c3                	cmp    %eax,%ebx
f010282b:	74 24                	je     f0102851 <check_kern_pgdir+0xb0>
f010282d:	c7 44 24 0c 68 9b 10 	movl   $0xf0109b68,0xc(%esp)
f0102834:	f0 
f0102835:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010283c:	f0 
f010283d:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0102844:	00 
f0102845:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01028ab:	a1 3c 62 24 f0       	mov    0xf024623c,%eax
f01028b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01028b4:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01028bb:	00 
f01028bc:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01028c3:	e8 e4 e8 ff ff       	call   f01011ac <_paddr>
f01028c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01028cb:	01 d0                	add    %edx,%eax
f01028cd:	39 c3                	cmp    %eax,%ebx
f01028cf:	74 24                	je     f01028f5 <check_kern_pgdir+0x154>
f01028d1:	c7 44 24 0c 9c 9b 10 	movl   $0xf0109b9c,0xc(%esp)
f01028d8:	f0 
f01028d9:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01028e0:	f0 
f01028e1:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01028e8:	00 
f01028e9:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102929:	c7 44 24 0c d0 9b 10 	movl   $0xf0109bd0,0xc(%esp)
f0102930:	f0 
f0102931:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102938:	f0 
f0102939:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102940:	00 
f0102941:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102948:	e8 82 d9 ff ff       	call   f01002cf <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0102954:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
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
f01029af:	05 00 80 24 f0       	add    $0xf0248000,%eax
f01029b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01029b8:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01029bf:	00 
f01029c0:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01029c7:	e8 e0 e7 ff ff       	call   f01011ac <_paddr>
f01029cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01029cf:	01 d0                	add    %edx,%eax
f01029d1:	39 c3                	cmp    %eax,%ebx
f01029d3:	74 24                	je     f01029f9 <check_kern_pgdir+0x258>
f01029d5:	c7 44 24 0c f8 9b 10 	movl   $0xf0109bf8,0xc(%esp)
f01029dc:	f0 
f01029dd:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01029e4:	f0 
f01029e5:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01029ec:	00 
f01029ed:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102a2e:	c7 44 24 0c 40 9c 10 	movl   $0xf0109c40,0xc(%esp)
f0102a35:	f0 
f0102a36:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102a3d:	f0 
f0102a3e:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0102a45:	00 
f0102a46:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102aa1:	c7 44 24 0c 63 9c 10 	movl   $0xf0109c63,0xc(%esp)
f0102aa8:	f0 
f0102aa9:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102ab0:	f0 
f0102ab1:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102ab8:	00 
f0102ab9:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102aeb:	c7 44 24 0c 63 9c 10 	movl   $0xf0109c63,0xc(%esp)
f0102af2:	f0 
f0102af3:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102afa:	f0 
f0102afb:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0102b02:	00 
f0102b03:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102b27:	c7 44 24 0c 74 9c 10 	movl   $0xf0109c74,0xc(%esp)
f0102b2e:	f0 
f0102b2f:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102b36:	f0 
f0102b37:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102b3e:	00 
f0102b3f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102b60:	c7 44 24 0c 85 9c 10 	movl   $0xf0109c85,0xc(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102b6f:	f0 
f0102b70:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0102b77:	00 
f0102b78:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102b96:	c7 04 24 94 9c 10 f0 	movl   $0xf0109c94,(%esp)
f0102b9d:	e8 0e 24 00 00       	call   f0104fb0 <cprintf>
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
f0102be3:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102c68:	c7 44 24 0c 24 9a 10 	movl   $0xf0109a24,0xc(%esp)
f0102c6f:	f0 
f0102c70:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102c77:	f0 
f0102c78:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102c7f:	00 
f0102c80:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102c87:	e8 43 d6 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0102c8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c93:	e8 ea eb ff ff       	call   f0101882 <page_alloc>
f0102c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102c9f:	75 24                	jne    f0102cc5 <check_page+0x8c>
f0102ca1:	c7 44 24 0c 3a 9a 10 	movl   $0xf0109a3a,0xc(%esp)
f0102ca8:	f0 
f0102ca9:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102cb0:	f0 
f0102cb1:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102cb8:	00 
f0102cb9:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102cc0:	e8 0a d6 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0102cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ccc:	e8 b1 eb ff ff       	call   f0101882 <page_alloc>
f0102cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102cd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0102cd8:	75 24                	jne    f0102cfe <check_page+0xc5>
f0102cda:	c7 44 24 0c 50 9a 10 	movl   $0xf0109a50,0xc(%esp)
f0102ce1:	f0 
f0102ce2:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102ce9:	f0 
f0102cea:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102cf1:	00 
f0102cf2:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102cf9:	e8 d1 d5 ff ff       	call   f01002cf <_panic>

	assert(pp0);
f0102cfe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102d02:	75 24                	jne    f0102d28 <check_page+0xef>
f0102d04:	c7 44 24 0c 66 9a 10 	movl   $0xf0109a66,0xc(%esp)
f0102d0b:	f0 
f0102d0c:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102d13:	f0 
f0102d14:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102d1b:	00 
f0102d1c:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102d23:	e8 a7 d5 ff ff       	call   f01002cf <_panic>
	assert(pp1 && pp1 != pp0);
f0102d28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102d2c:	74 08                	je     f0102d36 <check_page+0xfd>
f0102d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102d31:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0102d34:	75 24                	jne    f0102d5a <check_page+0x121>
f0102d36:	c7 44 24 0c 6a 9a 10 	movl   $0xf0109a6a,0xc(%esp)
f0102d3d:	f0 
f0102d3e:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102d45:	f0 
f0102d46:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102d4d:	00 
f0102d4e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0102d70:	c7 44 24 0c 7c 9a 10 	movl   $0xf0109a7c,0xc(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102d7f:	f0 
f0102d80:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102d87:	00 
f0102d88:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102d8f:	e8 3b d5 ff ff       	call   f01002cf <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102d94:	a1 30 62 24 f0       	mov    0xf0246230,%eax
f0102d99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	page_free_list = 0;
f0102d9c:	c7 05 30 62 24 f0 00 	movl   $0x0,0xf0246230
f0102da3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102da6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102dad:	e8 d0 ea ff ff       	call   f0101882 <page_alloc>
f0102db2:	85 c0                	test   %eax,%eax
f0102db4:	74 24                	je     f0102dda <check_page+0x1a1>
f0102db6:	c7 44 24 0c f3 9a 10 	movl   $0xf0109af3,0xc(%esp)
f0102dbd:	f0 
f0102dbe:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102dcd:	00 
f0102dce:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102dd5:	e8 f5 d4 ff ff       	call   f01002cf <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102dda:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0102ddf:	8d 55 cc             	lea    -0x34(%ebp),%edx
f0102de2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102de6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102ded:	00 
f0102dee:	89 04 24             	mov    %eax,(%esp)
f0102df1:	e8 a7 ed ff ff       	call   f0101b9d <page_lookup>
f0102df6:	85 c0                	test   %eax,%eax
f0102df8:	74 24                	je     f0102e1e <check_page+0x1e5>
f0102dfa:	c7 44 24 0c b4 9c 10 	movl   $0xf0109cb4,0xc(%esp)
f0102e01:	f0 
f0102e02:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102e09:	f0 
f0102e0a:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102e11:	00 
f0102e12:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102e19:	e8 b1 d4 ff ff       	call   f01002cf <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102e1e:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0102e46:	c7 44 24 0c ec 9c 10 	movl   $0xf0109cec,0xc(%esp)
f0102e4d:	f0 
f0102e4e:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102e5d:	00 
f0102e5e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102e65:	e8 65 d4 ff ff       	call   f01002cf <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102e6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102e6d:	89 04 24             	mov    %eax,(%esp)
f0102e70:	e8 70 ea ff ff       	call   f01018e5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102e75:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0102e9d:	c7 44 24 0c 1c 9d 10 	movl   $0xf0109d1c,0xc(%esp)
f0102ea4:	f0 
f0102ea5:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102eac:	f0 
f0102ead:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102eb4:	00 
f0102eb5:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102ebc:	e8 0e d4 ff ff       	call   f01002cf <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ec1:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0102ec6:	8b 00                	mov    (%eax),%eax
f0102ec8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ecd:	89 c3                	mov    %eax,%ebx
f0102ecf:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102ed2:	89 04 24             	mov    %eax,(%esp)
f0102ed5:	e8 4f e3 ff ff       	call   f0101229 <page2pa>
f0102eda:	39 c3                	cmp    %eax,%ebx
f0102edc:	74 24                	je     f0102f02 <check_page+0x2c9>
f0102ede:	c7 44 24 0c 4c 9d 10 	movl   $0xf0109d4c,0xc(%esp)
f0102ee5:	f0 
f0102ee6:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102eed:	f0 
f0102eee:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102ef5:	00 
f0102ef6:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102efd:	e8 cd d3 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102f02:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0102f28:	c7 44 24 0c 74 9d 10 	movl   $0xf0109d74,0xc(%esp)
f0102f2f:	f0 
f0102f30:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102f37:	f0 
f0102f38:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102f3f:	00 
f0102f40:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102f47:	e8 83 d3 ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 1);
f0102f4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f4f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f53:	66 83 f8 01          	cmp    $0x1,%ax
f0102f57:	74 24                	je     f0102f7d <check_page+0x344>
f0102f59:	c7 44 24 0c a1 9d 10 	movl   $0xf0109da1,0xc(%esp)
f0102f60:	f0 
f0102f61:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102f68:	f0 
f0102f69:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102f70:	00 
f0102f71:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102f78:	e8 52 d3 ff ff       	call   f01002cf <_panic>
	assert(pp0->pp_ref == 1);
f0102f7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f80:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0102f84:	66 83 f8 01          	cmp    $0x1,%ax
f0102f88:	74 24                	je     f0102fae <check_page+0x375>
f0102f8a:	c7 44 24 0c b2 9d 10 	movl   $0xf0109db2,0xc(%esp)
f0102f91:	f0 
f0102f92:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102f99:	f0 
f0102f9a:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0102fa1:	00 
f0102fa2:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102fa9:	e8 21 d3 ff ff       	call   f01002cf <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102fae:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0102fd6:	c7 44 24 0c c4 9d 10 	movl   $0xf0109dc4,0xc(%esp)
f0102fdd:	f0 
f0102fde:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0102fe5:	f0 
f0102fe6:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102fed:	00 
f0102fee:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0102ff5:	e8 d5 d2 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102ffa:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103020:	c7 44 24 0c 00 9e 10 	movl   $0xf0109e00,0xc(%esp)
f0103027:	f0 
f0103028:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010302f:	f0 
f0103030:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0103037:	00 
f0103038:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010303f:	e8 8b d2 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f0103044:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103047:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010304b:	66 83 f8 01          	cmp    $0x1,%ax
f010304f:	74 24                	je     f0103075 <check_page+0x43c>
f0103051:	c7 44 24 0c 30 9e 10 	movl   $0xf0109e30,0xc(%esp)
f0103058:	f0 
f0103059:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103060:	f0 
f0103061:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0103068:	00 
f0103069:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103070:	e8 5a d2 ff ff       	call   f01002cf <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0103075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010307c:	e8 01 e8 ff ff       	call   f0101882 <page_alloc>
f0103081:	85 c0                	test   %eax,%eax
f0103083:	74 24                	je     f01030a9 <check_page+0x470>
f0103085:	c7 44 24 0c f3 9a 10 	movl   $0xf0109af3,0xc(%esp)
f010308c:	f0 
f010308d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103094:	f0 
f0103095:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f010309c:	00 
f010309d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01030a4:	e8 26 d2 ff ff       	call   f01002cf <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01030a9:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f01030d1:	c7 44 24 0c c4 9d 10 	movl   $0xf0109dc4,0xc(%esp)
f01030d8:	f0 
f01030d9:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01030e0:	f0 
f01030e1:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01030e8:	00 
f01030e9:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01030f0:	e8 da d1 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01030f5:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f010311b:	c7 44 24 0c 00 9e 10 	movl   $0xf0109e00,0xc(%esp)
f0103122:	f0 
f0103123:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010312a:	f0 
f010312b:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0103132:	00 
f0103133:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010313a:	e8 90 d1 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f010313f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103142:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103146:	66 83 f8 01          	cmp    $0x1,%ax
f010314a:	74 24                	je     f0103170 <check_page+0x537>
f010314c:	c7 44 24 0c 30 9e 10 	movl   $0xf0109e30,0xc(%esp)
f0103153:	f0 
f0103154:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010315b:	f0 
f010315c:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0103163:	00 
f0103164:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010316b:	e8 5f d1 ff ff       	call   f01002cf <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0103170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103177:	e8 06 e7 ff ff       	call   f0101882 <page_alloc>
f010317c:	85 c0                	test   %eax,%eax
f010317e:	74 24                	je     f01031a4 <check_page+0x56b>
f0103180:	c7 44 24 0c f3 9a 10 	movl   $0xf0109af3,0xc(%esp)
f0103187:	f0 
f0103188:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010318f:	f0 
f0103190:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0103197:	00 
f0103198:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010319f:	e8 2b d1 ff ff       	call   f01002cf <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01031a4:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01031a9:	8b 00                	mov    (%eax),%eax
f01031ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01031b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031b4:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f01031bb:	00 
f01031bc:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01031c3:	e8 1f e0 ff ff       	call   f01011e7 <_kaddr>
f01031c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01031cb:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f01031f2:	c7 44 24 0c 44 9e 10 	movl   $0xf0109e44,0xc(%esp)
f01031f9:	f0 
f01031fa:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103201:	f0 
f0103202:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0103209:	00 
f010320a:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103211:	e8 b9 d0 ff ff       	call   f01002cf <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0103216:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f010323e:	c7 44 24 0c 84 9e 10 	movl   $0xf0109e84,0xc(%esp)
f0103245:	f0 
f0103246:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010324d:	f0 
f010324e:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0103255:	00 
f0103256:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010325d:	e8 6d d0 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0103262:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103288:	c7 44 24 0c 00 9e 10 	movl   $0xf0109e00,0xc(%esp)
f010328f:	f0 
f0103290:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103297:	f0 
f0103298:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f010329f:	00 
f01032a0:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01032a7:	e8 23 d0 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f01032ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01032af:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01032b3:	66 83 f8 01          	cmp    $0x1,%ax
f01032b7:	74 24                	je     f01032dd <check_page+0x6a4>
f01032b9:	c7 44 24 0c 30 9e 10 	movl   $0xf0109e30,0xc(%esp)
f01032c0:	f0 
f01032c1:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01032c8:	f0 
f01032c9:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01032d0:	00 
f01032d1:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01032d8:	e8 f2 cf ff ff       	call   f01002cf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01032dd:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103303:	c7 44 24 0c c4 9e 10 	movl   $0xf0109ec4,0xc(%esp)
f010330a:	f0 
f010330b:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103312:	f0 
f0103313:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f010331a:	00 
f010331b:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103322:	e8 a8 cf ff ff       	call   f01002cf <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0103327:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f010332c:	8b 00                	mov    (%eax),%eax
f010332e:	83 e0 04             	and    $0x4,%eax
f0103331:	85 c0                	test   %eax,%eax
f0103333:	75 24                	jne    f0103359 <check_page+0x720>
f0103335:	c7 44 24 0c f7 9e 10 	movl   $0xf0109ef7,0xc(%esp)
f010333c:	f0 
f010333d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103344:	f0 
f0103345:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f010334c:	00 
f010334d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103354:	e8 76 cf ff ff       	call   f01002cf <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0103359:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103381:	c7 44 24 0c c4 9d 10 	movl   $0xf0109dc4,0xc(%esp)
f0103388:	f0 
f0103389:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103390:	f0 
f0103391:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0103398:	00 
f0103399:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01033a0:	e8 2a cf ff ff       	call   f01002cf <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01033a5:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f01033cb:	c7 44 24 0c 10 9f 10 	movl   $0xf0109f10,0xc(%esp)
f01033d2:	f0 
f01033d3:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01033da:	f0 
f01033db:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01033e2:	00 
f01033e3:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01033ea:	e8 e0 ce ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01033ef:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103415:	c7 44 24 0c 44 9f 10 	movl   $0xf0109f44,0xc(%esp)
f010341c:	f0 
f010341d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103424:	f0 
f0103425:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f010342c:	00 
f010342d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103434:	e8 96 ce ff ff       	call   f01002cf <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0103439:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103461:	c7 44 24 0c 7c 9f 10 	movl   $0xf0109f7c,0xc(%esp)
f0103468:	f0 
f0103469:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103470:	f0 
f0103471:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0103478:	00 
f0103479:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103480:	e8 4a ce ff ff       	call   f01002cf <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0103485:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f01034ad:	c7 44 24 0c b4 9f 10 	movl   $0xf0109fb4,0xc(%esp)
f01034b4:	f0 
f01034b5:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01034bc:	f0 
f01034bd:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f01034c4:	00 
f01034c5:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01034cc:	e8 fe cd ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01034d1:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f01034f7:	c7 44 24 0c 44 9f 10 	movl   $0xf0109f44,0xc(%esp)
f01034fe:	f0 
f01034ff:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103506:	f0 
f0103507:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010350e:	00 
f010350f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103516:	e8 b4 cd ff ff       	call   f01002cf <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010351b:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103541:	c7 44 24 0c f0 9f 10 	movl   $0xf0109ff0,0xc(%esp)
f0103548:	f0 
f0103549:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103550:	f0 
f0103551:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0103558:	00 
f0103559:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103560:	e8 6a cd ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103565:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f010358b:	c7 44 24 0c 1c a0 10 	movl   $0xf010a01c,0xc(%esp)
f0103592:	f0 
f0103593:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010359a:	f0 
f010359b:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01035a2:	00 
f01035a3:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01035aa:	e8 20 cd ff ff       	call   f01002cf <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01035af:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01035b2:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01035b6:	66 83 f8 02          	cmp    $0x2,%ax
f01035ba:	74 24                	je     f01035e0 <check_page+0x9a7>
f01035bc:	c7 44 24 0c 4c a0 10 	movl   $0xf010a04c,0xc(%esp)
f01035c3:	f0 
f01035c4:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01035cb:	f0 
f01035cc:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01035d3:	00 
f01035d4:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01035db:	e8 ef cc ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f01035e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01035e3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01035e7:	66 85 c0             	test   %ax,%ax
f01035ea:	74 24                	je     f0103610 <check_page+0x9d7>
f01035ec:	c7 44 24 0c 5d a0 10 	movl   $0xf010a05d,0xc(%esp)
f01035f3:	f0 
f01035f4:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01035fb:	f0 
f01035fc:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0103603:	00 
f0103604:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f010362d:	c7 44 24 0c 70 a0 10 	movl   $0xf010a070,0xc(%esp)
f0103634:	f0 
f0103635:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010363c:	f0 
f010363d:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0103644:	00 
f0103645:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010364c:	e8 7e cc ff ff       	call   f01002cf <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0103651:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103656:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010365d:	00 
f010365e:	89 04 24             	mov    %eax,(%esp)
f0103661:	e8 8a e5 ff ff       	call   f0101bf0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103666:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f010366b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103672:	00 
f0103673:	89 04 24             	mov    %eax,(%esp)
f0103676:	e8 2d f5 ff ff       	call   f0102ba8 <check_va2pa>
f010367b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010367e:	74 24                	je     f01036a4 <check_page+0xa6b>
f0103680:	c7 44 24 0c 94 a0 10 	movl   $0xf010a094,0xc(%esp)
f0103687:	f0 
f0103688:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010368f:	f0 
f0103690:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0103697:	00 
f0103698:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010369f:	e8 2b cc ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01036a4:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f01036ca:	c7 44 24 0c 1c a0 10 	movl   $0xf010a01c,0xc(%esp)
f01036d1:	f0 
f01036d2:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01036d9:	f0 
f01036da:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01036e1:	00 
f01036e2:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01036e9:	e8 e1 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 1);
f01036ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01036f1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01036f5:	66 83 f8 01          	cmp    $0x1,%ax
f01036f9:	74 24                	je     f010371f <check_page+0xae6>
f01036fb:	c7 44 24 0c a1 9d 10 	movl   $0xf0109da1,0xc(%esp)
f0103702:	f0 
f0103703:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010370a:	f0 
f010370b:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0103712:	00 
f0103713:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010371a:	e8 b0 cb ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f010371f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103722:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103726:	66 85 c0             	test   %ax,%ax
f0103729:	74 24                	je     f010374f <check_page+0xb16>
f010372b:	c7 44 24 0c 5d a0 10 	movl   $0xf010a05d,0xc(%esp)
f0103732:	f0 
f0103733:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010373a:	f0 
f010373b:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103742:	00 
f0103743:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010374a:	e8 80 cb ff ff       	call   f01002cf <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010374f:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103777:	c7 44 24 0c b8 a0 10 	movl   $0xf010a0b8,0xc(%esp)
f010377e:	f0 
f010377f:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103786:	f0 
f0103787:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f010378e:	00 
f010378f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103796:	e8 34 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref);
f010379b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010379e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01037a2:	66 85 c0             	test   %ax,%ax
f01037a5:	75 24                	jne    f01037cb <check_page+0xb92>
f01037a7:	c7 44 24 0c ed a0 10 	movl   $0xf010a0ed,0xc(%esp)
f01037ae:	f0 
f01037af:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01037b6:	f0 
f01037b7:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f01037be:	00 
f01037bf:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01037c6:	e8 04 cb ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_link == NULL);
f01037cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037ce:	8b 00                	mov    (%eax),%eax
f01037d0:	85 c0                	test   %eax,%eax
f01037d2:	74 24                	je     f01037f8 <check_page+0xbbf>
f01037d4:	c7 44 24 0c f9 a0 10 	movl   $0xf010a0f9,0xc(%esp)
f01037db:	f0 
f01037dc:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01037e3:	f0 
f01037e4:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01037eb:	00 
f01037ec:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01037f3:	e8 d7 ca ff ff       	call   f01002cf <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01037f8:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01037fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103804:	00 
f0103805:	89 04 24             	mov    %eax,(%esp)
f0103808:	e8 e3 e3 ff ff       	call   f0101bf0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010380d:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103812:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103819:	00 
f010381a:	89 04 24             	mov    %eax,(%esp)
f010381d:	e8 86 f3 ff ff       	call   f0102ba8 <check_va2pa>
f0103822:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103825:	74 24                	je     f010384b <check_page+0xc12>
f0103827:	c7 44 24 0c 94 a0 10 	movl   $0xf010a094,0xc(%esp)
f010382e:	f0 
f010382f:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103836:	f0 
f0103837:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f010383e:	00 
f010383f:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103846:	e8 84 ca ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010384b:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103850:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103857:	00 
f0103858:	89 04 24             	mov    %eax,(%esp)
f010385b:	e8 48 f3 ff ff       	call   f0102ba8 <check_va2pa>
f0103860:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103863:	74 24                	je     f0103889 <check_page+0xc50>
f0103865:	c7 44 24 0c 10 a1 10 	movl   $0xf010a110,0xc(%esp)
f010386c:	f0 
f010386d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103874:	f0 
f0103875:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010387c:	00 
f010387d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103884:	e8 46 ca ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 0);
f0103889:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010388c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f0103890:	66 85 c0             	test   %ax,%ax
f0103893:	74 24                	je     f01038b9 <check_page+0xc80>
f0103895:	c7 44 24 0c 36 a1 10 	movl   $0xf010a136,0xc(%esp)
f010389c:	f0 
f010389d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01038a4:	f0 
f01038a5:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01038ac:	00 
f01038ad:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01038b4:	e8 16 ca ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 0);
f01038b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01038bc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01038c0:	66 85 c0             	test   %ax,%ax
f01038c3:	74 24                	je     f01038e9 <check_page+0xcb0>
f01038c5:	c7 44 24 0c 5d a0 10 	movl   $0xf010a05d,0xc(%esp)
f01038cc:	f0 
f01038cd:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01038d4:	f0 
f01038d5:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01038dc:	00 
f01038dd:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0103906:	c7 44 24 0c 48 a1 10 	movl   $0xf010a148,0xc(%esp)
f010390d:	f0 
f010390e:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103915:	f0 
f0103916:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f010391d:	00 
f010391e:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103925:	e8 a5 c9 ff ff       	call   f01002cf <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010392a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103931:	e8 4c df ff ff       	call   f0101882 <page_alloc>
f0103936:	85 c0                	test   %eax,%eax
f0103938:	74 24                	je     f010395e <check_page+0xd25>
f010393a:	c7 44 24 0c f3 9a 10 	movl   $0xf0109af3,0xc(%esp)
f0103941:	f0 
f0103942:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103949:	f0 
f010394a:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0103951:	00 
f0103952:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103959:	e8 71 c9 ff ff       	call   f01002cf <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010395e:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103963:	8b 00                	mov    (%eax),%eax
f0103965:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010396a:	89 c3                	mov    %eax,%ebx
f010396c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010396f:	89 04 24             	mov    %eax,(%esp)
f0103972:	e8 b2 d8 ff ff       	call   f0101229 <page2pa>
f0103977:	39 c3                	cmp    %eax,%ebx
f0103979:	74 24                	je     f010399f <check_page+0xd66>
f010397b:	c7 44 24 0c 4c 9d 10 	movl   $0xf0109d4c,0xc(%esp)
f0103982:	f0 
f0103983:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010398a:	f0 
f010398b:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0103992:	00 
f0103993:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010399a:	e8 30 c9 ff ff       	call   f01002cf <_panic>
	kern_pgdir[0] = 0;
f010399f:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01039a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01039aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01039ad:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01039b1:	66 83 f8 01          	cmp    $0x1,%ax
f01039b5:	74 24                	je     f01039db <check_page+0xda2>
f01039b7:	c7 44 24 0c b2 9d 10 	movl   $0xf0109db2,0xc(%esp)
f01039be:	f0 
f01039bf:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01039c6:	f0 
f01039c7:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01039ce:	00 
f01039cf:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f01039f6:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01039fb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a02:	00 
f0103a03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a06:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a0a:	89 04 24             	mov    %eax,(%esp)
f0103a0d:	e8 6b df ff ff       	call   f010197d <pgdir_walk>
f0103a12:	89 45 cc             	mov    %eax,-0x34(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0103a15:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103a1a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a1d:	c1 ea 16             	shr    $0x16,%edx
f0103a20:	c1 e2 02             	shl    $0x2,%edx
f0103a23:	01 d0                	add    %edx,%eax
f0103a25:	8b 00                	mov    (%eax),%eax
f0103a27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a30:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0103a37:	00 
f0103a38:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0103a65:	c7 44 24 0c 6a a1 10 	movl   $0xf010a16a,0xc(%esp)
f0103a6c:	f0 
f0103a6d:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103a74:	f0 
f0103a75:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0103a7c:	00 
f0103a7d:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103a84:	e8 46 c8 ff ff       	call   f01002cf <_panic>
	kern_pgdir[PDX(va)] = 0;
f0103a89:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103ac6:	e8 8c 46 00 00       	call   f0108157 <memset>
	page_free(pp0);
f0103acb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103ace:	89 04 24             	mov    %eax,(%esp)
f0103ad1:	e8 0f de ff ff       	call   f01018e5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0103ad6:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103b1e:	c7 44 24 0c 82 a1 10 	movl   $0xf010a182,0xc(%esp)
f0103b25:	f0 
f0103b26:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103b2d:	f0 
f0103b2e:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0103b35:	00 
f0103b36:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0103b4f:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103b54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0103b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b5d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0103b63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b66:	a3 30 62 24 f0       	mov    %eax,0xf0246230

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
f0103bd2:	c7 44 24 0c 9c a1 10 	movl   $0xf010a19c,0xc(%esp)
f0103bd9:	f0 
f0103bda:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103be1:	f0 
f0103be2:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f0103be9:	00 
f0103bea:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103bf1:	e8 d9 c6 ff ff       	call   f01002cf <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103bf6:	81 7d d0 ff ff 7f ef 	cmpl   $0xef7fffff,-0x30(%ebp)
f0103bfd:	76 0f                	jbe    f0103c0e <check_page+0xfd5>
f0103bff:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c02:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c07:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103c0c:	76 24                	jbe    f0103c32 <check_page+0xff9>
f0103c0e:	c7 44 24 0c c4 a1 10 	movl   $0xf010a1c4,0xc(%esp)
f0103c15:	f0 
f0103c16:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103c1d:	f0 
f0103c1e:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f0103c25:	00 
f0103c26:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0103c4a:	c7 44 24 0c ec a1 10 	movl   $0xf010a1ec,0xc(%esp)
f0103c51:	f0 
f0103c52:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103c59:	f0 
f0103c5a:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f0103c61:	00 
f0103c62:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103c69:	e8 61 c6 ff ff       	call   f01002cf <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0103c6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c71:	05 a0 1f 00 00       	add    $0x1fa0,%eax
f0103c76:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103c79:	76 24                	jbe    f0103c9f <check_page+0x1066>
f0103c7b:	c7 44 24 0c 13 a2 10 	movl   $0xf010a213,0xc(%esp)
f0103c82:	f0 
f0103c83:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103c8a:	f0 
f0103c8b:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0103c92:	00 
f0103c93:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103c9a:	e8 30 c6 ff ff       	call   f01002cf <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103c9f:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103ca4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ca7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103cab:	89 04 24             	mov    %eax,(%esp)
f0103cae:	e8 f5 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103cb3:	85 c0                	test   %eax,%eax
f0103cb5:	74 24                	je     f0103cdb <check_page+0x10a2>
f0103cb7:	c7 44 24 0c 28 a2 10 	movl   $0xf010a228,0xc(%esp)
f0103cbe:	f0 
f0103cbf:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103cc6:	f0 
f0103cc7:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0103cce:	00 
f0103ccf:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103cd6:	e8 f4 c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0103cdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103cde:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103ce4:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103ce9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ced:	89 04 24             	mov    %eax,(%esp)
f0103cf0:	e8 b3 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103cf5:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103cfa:	74 24                	je     f0103d20 <check_page+0x10e7>
f0103cfc:	c7 44 24 0c 4c a2 10 	movl   $0xf010a24c,0xc(%esp)
f0103d03:	f0 
f0103d04:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103d0b:	f0 
f0103d0c:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0103d13:	00 
f0103d14:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103d1b:	e8 af c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0103d20:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103d25:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103d28:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d2c:	89 04 24             	mov    %eax,(%esp)
f0103d2f:	e8 74 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103d34:	85 c0                	test   %eax,%eax
f0103d36:	74 24                	je     f0103d5c <check_page+0x1123>
f0103d38:	c7 44 24 0c 7c a2 10 	movl   $0xf010a27c,0xc(%esp)
f0103d3f:	f0 
f0103d40:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103d47:	f0 
f0103d48:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0103d4f:	00 
f0103d50:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103d57:	e8 73 c5 ff ff       	call   f01002cf <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103d5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d5f:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
f0103d65:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103d6a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d6e:	89 04 24             	mov    %eax,(%esp)
f0103d71:	e8 32 ee ff ff       	call   f0102ba8 <check_va2pa>
f0103d76:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103d79:	74 24                	je     f0103d9f <check_page+0x1166>
f0103d7b:	c7 44 24 0c a0 a2 10 	movl   $0xf010a2a0,0xc(%esp)
f0103d82:	f0 
f0103d83:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103d8a:	f0 
f0103d8b:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0103d92:	00 
f0103d93:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103d9a:	e8 30 c5 ff ff       	call   f01002cf <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0103d9f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103da2:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103da7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103dae:	00 
f0103daf:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103db3:	89 04 24             	mov    %eax,(%esp)
f0103db6:	e8 c2 db ff ff       	call   f010197d <pgdir_walk>
f0103dbb:	8b 00                	mov    (%eax),%eax
f0103dbd:	83 e0 1a             	and    $0x1a,%eax
f0103dc0:	85 c0                	test   %eax,%eax
f0103dc2:	75 24                	jne    f0103de8 <check_page+0x11af>
f0103dc4:	c7 44 24 0c cc a2 10 	movl   $0xf010a2cc,0xc(%esp)
f0103dcb:	f0 
f0103dcc:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103dd3:	f0 
f0103dd4:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0103ddb:	00 
f0103ddc:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103de3:	e8 e7 c4 ff ff       	call   f01002cf <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0103de8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103deb:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103df0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103df7:	00 
f0103df8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103dfc:	89 04 24             	mov    %eax,(%esp)
f0103dff:	e8 79 db ff ff       	call   f010197d <pgdir_walk>
f0103e04:	8b 00                	mov    (%eax),%eax
f0103e06:	83 e0 04             	and    $0x4,%eax
f0103e09:	85 c0                	test   %eax,%eax
f0103e0b:	74 24                	je     f0103e31 <check_page+0x11f8>
f0103e0d:	c7 44 24 0c 10 a3 10 	movl   $0xf010a310,0xc(%esp)
f0103e14:	f0 
f0103e15:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103e1c:	f0 
f0103e1d:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0103e24:	00 
f0103e25:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103e2c:	e8 9e c4 ff ff       	call   f01002cf <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103e31:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e34:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103e5d:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103e62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e69:	00 
f0103e6a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e6e:	89 04 24             	mov    %eax,(%esp)
f0103e71:	e8 07 db ff ff       	call   f010197d <pgdir_walk>
f0103e76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103e7c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103e7f:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0103e84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103e8b:	00 
f0103e8c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103e90:	89 04 24             	mov    %eax,(%esp)
f0103e93:	e8 e5 da ff ff       	call   f010197d <pgdir_walk>
f0103e98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0103e9e:	c7 04 24 43 a3 10 f0 	movl   $0xf010a343,(%esp)
f0103ea5:	e8 06 11 00 00       	call   f0104fb0 <cprintf>
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
f0103ed9:	c7 44 24 0c 24 9a 10 	movl   $0xf0109a24,0xc(%esp)
f0103ee0:	f0 
f0103ee1:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103ee8:	f0 
f0103ee9:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0103ef0:	00 
f0103ef1:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103ef8:	e8 d2 c3 ff ff       	call   f01002cf <_panic>
	assert((pp1 = page_alloc(0)));
f0103efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f04:	e8 79 d9 ff ff       	call   f0101882 <page_alloc>
f0103f09:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0103f10:	75 24                	jne    f0103f36 <check_page_installed_pgdir+0x86>
f0103f12:	c7 44 24 0c 3a 9a 10 	movl   $0xf0109a3a,0xc(%esp)
f0103f19:	f0 
f0103f1a:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103f21:	f0 
f0103f22:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0103f29:	00 
f0103f2a:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0103f31:	e8 99 c3 ff ff       	call   f01002cf <_panic>
	assert((pp2 = page_alloc(0)));
f0103f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103f3d:	e8 40 d9 ff ff       	call   f0101882 <page_alloc>
f0103f42:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103f45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103f49:	75 24                	jne    f0103f6f <check_page_installed_pgdir+0xbf>
f0103f4b:	c7 44 24 0c 50 9a 10 	movl   $0xf0109a50,0xc(%esp)
f0103f52:	f0 
f0103f53:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0103f5a:	f0 
f0103f5b:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0103f62:	00 
f0103f63:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0103f98:	e8 ba 41 00 00       	call   f0108157 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fa0:	89 04 24             	mov    %eax,(%esp)
f0103fa3:	e8 dd d2 ff ff       	call   f0101285 <page2kva>
f0103fa8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103faf:	00 
f0103fb0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103fb7:	00 
f0103fb8:	89 04 24             	mov    %eax,(%esp)
f0103fbb:	e8 97 41 00 00       	call   f0108157 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103fc0:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0103ff1:	c7 44 24 0c a1 9d 10 	movl   $0xf0109da1,0xc(%esp)
f0103ff8:	f0 
f0103ff9:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0104000:	f0 
f0104001:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f0104008:	00 
f0104009:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0104010:	e8 ba c2 ff ff       	call   f01002cf <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0104015:	b8 00 10 00 00       	mov    $0x1000,%eax
f010401a:	8b 00                	mov    (%eax),%eax
f010401c:	3d 01 01 01 01       	cmp    $0x1010101,%eax
f0104021:	74 24                	je     f0104047 <check_page_installed_pgdir+0x197>
f0104023:	c7 44 24 0c 5c a3 10 	movl   $0xf010a35c,0xc(%esp)
f010402a:	f0 
f010402b:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0104032:	f0 
f0104033:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f010403a:	00 
f010403b:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0104042:	e8 88 c2 ff ff       	call   f01002cf <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0104047:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
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
f0104079:	c7 44 24 0c 80 a3 10 	movl   $0xf010a380,0xc(%esp)
f0104080:	f0 
f0104081:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0104088:	f0 
f0104089:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0104090:	00 
f0104091:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0104098:	e8 32 c2 ff ff       	call   f01002cf <_panic>
	assert(pp2->pp_ref == 1);
f010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040a0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01040a4:	66 83 f8 01          	cmp    $0x1,%ax
f01040a8:	74 24                	je     f01040ce <check_page_installed_pgdir+0x21e>
f01040aa:	c7 44 24 0c 30 9e 10 	movl   $0xf0109e30,0xc(%esp)
f01040b1:	f0 
f01040b2:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01040b9:	f0 
f01040ba:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f01040c1:	00 
f01040c2:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01040c9:	e8 01 c2 ff ff       	call   f01002cf <_panic>
	assert(pp1->pp_ref == 0);
f01040ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01040d1:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01040d5:	66 85 c0             	test   %ax,%ax
f01040d8:	74 24                	je     f01040fe <check_page_installed_pgdir+0x24e>
f01040da:	c7 44 24 0c 36 a1 10 	movl   $0xf010a136,0xc(%esp)
f01040e1:	f0 
f01040e2:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01040e9:	f0 
f01040ea:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01040f1:	00 
f01040f2:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f010411d:	c7 44 24 0c a4 a3 10 	movl   $0xf010a3a4,0xc(%esp)
f0104124:	f0 
f0104125:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f010412c:	f0 
f010412d:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0104134:	00 
f0104135:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f010413c:	e8 8e c1 ff ff       	call   f01002cf <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0104141:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0104146:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010414d:	00 
f010414e:	89 04 24             	mov    %eax,(%esp)
f0104151:	e8 9a da ff ff       	call   f0101bf0 <page_remove>
	assert(pp2->pp_ref == 0);
f0104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104159:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010415d:	66 85 c0             	test   %ax,%ax
f0104160:	74 24                	je     f0104186 <check_page_installed_pgdir+0x2d6>
f0104162:	c7 44 24 0c 5d a0 10 	movl   $0xf010a05d,0xc(%esp)
f0104169:	f0 
f010416a:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f0104171:	f0 
f0104172:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0104179:	00 
f010417a:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f0104181:	e8 49 c1 ff ff       	call   f01002cf <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0104186:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f010418b:	8b 00                	mov    (%eax),%eax
f010418d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104192:	89 c3                	mov    %eax,%ebx
f0104194:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104197:	89 04 24             	mov    %eax,(%esp)
f010419a:	e8 8a d0 ff ff       	call   f0101229 <page2pa>
f010419f:	39 c3                	cmp    %eax,%ebx
f01041a1:	74 24                	je     f01041c7 <check_page_installed_pgdir+0x317>
f01041a3:	c7 44 24 0c 4c 9d 10 	movl   $0xf0109d4c,0xc(%esp)
f01041aa:	f0 
f01041ab:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01041b2:	f0 
f01041b3:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f01041ba:	00 
f01041bb:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
f01041c2:	e8 08 c1 ff ff       	call   f01002cf <_panic>
	kern_pgdir[0] = 0;
f01041c7:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01041cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01041d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041d5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f01041d9:	66 83 f8 01          	cmp    $0x1,%ax
f01041dd:	74 24                	je     f0104203 <check_page_installed_pgdir+0x353>
f01041df:	c7 44 24 0c b2 9d 10 	movl   $0xf0109db2,0xc(%esp)
f01041e6:	f0 
f01041e7:	c7 44 24 08 3a 98 10 	movl   $0xf010983a,0x8(%esp)
f01041ee:	f0 
f01041ef:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f01041f6:	00 
f01041f7:	c7 04 24 d8 97 10 f0 	movl   $0xf01097d8,(%esp)
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
f0104217:	c7 04 24 d0 a3 10 f0 	movl   $0xf010a3d0,(%esp)
f010421e:	e8 8d 0d 00 00       	call   f0104fb0 <cprintf>
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
f010424b:	c7 44 24 08 fc a3 10 	movl   $0xf010a3fc,0x8(%esp)
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
f010427d:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f0104282:	39 c2                	cmp    %eax,%edx
f0104284:	72 21                	jb     f01042a7 <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104286:	8b 45 10             	mov    0x10(%ebp),%eax
f0104289:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010428d:	c7 44 24 08 20 a4 10 	movl   $0xf010a420,0x8(%esp)
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
f01042b7:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f01042d6:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f01042db:	39 c2                	cmp    %eax,%edx
f01042dd:	72 1c                	jb     f01042fb <pa2page+0x33>
		panic("pa2page called with invalid pa");
f01042df:	c7 44 24 08 44 a4 10 	movl   $0xf010a444,0x8(%esp)
f01042e6:	f0 
f01042e7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01042ee:	00 
f01042ef:	c7 04 24 63 a4 10 f0 	movl   $0xf010a463,(%esp)
f01042f6:	e8 d4 bf ff ff       	call   f01002cf <_panic>
	return &pages[PGNUM(pa)];
f01042fb:	a1 f0 6e 24 f0       	mov    0xf0246ef0,%eax
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
f010432a:	c7 04 24 63 a4 10 f0 	movl   $0xf010a463,(%esp)
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
f0104345:	e8 db 4b 00 00       	call   f0108f25 <spin_unlock>

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
f0104361:	e8 bc 48 00 00       	call   f0108c22 <cpunum>
f0104366:	6b c0 74             	imul   $0x74,%eax,%eax
f0104369:	05 28 70 24 f0       	add    $0xf0247028,%eax
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
f010437f:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
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
f01043c9:	e8 54 48 00 00       	call   f0108c22 <cpunum>
f01043ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d1:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01043d6:	8b 00                	mov    (%eax),%eax
f01043d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01043db:	74 2c                	je     f0104409 <envid2env+0xbb>
f01043dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043e0:	8b 58 4c             	mov    0x4c(%eax),%ebx
f01043e3:	e8 3a 48 00 00       	call   f0108c22 <cpunum>
f01043e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043eb:	05 28 70 24 f0       	add    $0xf0247028,%eax
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
f010442b:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f0104431:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104434:	c1 e0 02             	shl    $0x2,%eax
f0104437:	89 c1                	mov    %eax,%ecx
f0104439:	c1 e1 05             	shl    $0x5,%ecx
f010443c:	29 c1                	sub    %eax,%ecx
f010443e:	89 c8                	mov    %ecx,%eax
f0104440:	01 d0                	add    %edx,%eax
f0104442:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0104449:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f010444f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104452:	c1 e0 02             	shl    $0x2,%eax
f0104455:	89 c1                	mov    %eax,%ecx
f0104457:	c1 e1 05             	shl    $0x5,%ecx
f010445a:	29 c1                	sub    %eax,%ecx
f010445c:	89 c8                	mov    %ecx,%eax
f010445e:	01 c2                	add    %eax,%edx
f0104460:	a1 40 62 24 f0       	mov    0xf0246240,%eax
f0104465:	89 42 44             	mov    %eax,0x44(%edx)
		env_free_list = &envs[i];
f0104468:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f010446e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104471:	c1 e0 02             	shl    $0x2,%eax
f0104474:	89 c1                	mov    %eax,%ecx
f0104476:	c1 e1 05             	shl    $0x5,%ecx
f0104479:	29 c1                	sub    %eax,%ecx
f010447b:	89 c8                	mov    %ecx,%eax
f010447d:	01 d0                	add    %edx,%eax
f010447f:	a3 40 62 24 f0       	mov    %eax,0xf0246240
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
f010452c:	8b 15 ec 6e 24 f0    	mov    0xf0246eec,%edx
f0104532:	8b 45 08             	mov    0x8(%ebp),%eax
f0104535:	8b 40 60             	mov    0x60(%eax),%eax
f0104538:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010453f:	00 
f0104540:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104544:	89 04 24             	mov    %eax,(%esp)
f0104547:	e8 53 3d 00 00       	call   f010829f <memcpy>

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
f010456a:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
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
f0104589:	53                   	push   %ebx
f010458a:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010458d:	a1 40 62 24 f0       	mov    0xf0246240,%eax
f0104592:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104599:	75 0a                	jne    f01045a5 <env_alloc+0x1f>
		return -E_NO_FREE_ENV;
f010459b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01045a0:	e9 4c 01 00 00       	jmp    f01046f1 <env_alloc+0x16b>

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
f01045a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045a8:	89 04 24             	mov    %eax,(%esp)
f01045ab:	e8 30 ff ff ff       	call   f01044e0 <env_setup_vm>
f01045b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01045b3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01045b7:	79 08                	jns    f01045c1 <env_alloc+0x3b>
		return r;
f01045b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01045bc:	e9 30 01 00 00       	jmp    f01046f1 <env_alloc+0x16b>

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01045c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045c4:	8b 40 48             	mov    0x48(%eax),%eax
f01045c7:	05 00 10 00 00       	add    $0x1000,%eax
f01045cc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01045d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f01045d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01045d8:	7f 07                	jg     f01045e1 <env_alloc+0x5b>
		generation = 1 << ENVGENSHIFT;
f01045da:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f01045e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01045e4:	a1 3c 62 24 f0       	mov    0xf024623c,%eax
f01045e9:	29 c2                	sub    %eax,%edx
f01045eb:	89 d0                	mov    %edx,%eax
f01045ed:	c1 f8 02             	sar    $0x2,%eax
f01045f0:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f01045f6:	0b 45 f4             	or     -0xc(%ebp),%eax
f01045f9:	89 c2                	mov    %eax,%edx
f01045fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045fe:	89 50 48             	mov    %edx,0x48(%eax)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104601:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104604:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104607:	89 50 4c             	mov    %edx,0x4c(%eax)
	e->env_type = ENV_TYPE_USER;
f010460a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010460d:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f0104614:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104617:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_runs = 0;
f010461e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104621:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0104628:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010462b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104632:	00 
f0104633:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010463a:	00 
f010463b:	89 04 24             	mov    %eax,(%esp)
f010463e:	e8 14 3b 00 00       	call   f0108157 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104643:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104646:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f010464c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010464f:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0104655:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104658:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = USTACKTOP;
f010465e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104661:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0104668:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010466b:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	e->env_tf.tf_eflags |= FL_IF;
f0104671:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104674:	8b 40 38             	mov    0x38(%eax),%eax
f0104677:	80 cc 02             	or     $0x2,%ah
f010467a:	89 c2                	mov    %eax,%edx
f010467c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010467f:	89 50 38             	mov    %edx,0x38(%eax)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104682:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104685:	c7 40 64 00 00 00 00 	movl   $0x0,0x64(%eax)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010468c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010468f:	c6 40 68 00          	movb   $0x0,0x68(%eax)

	// commit the allocation
	env_free_list = e->env_link;
f0104693:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104696:	8b 40 44             	mov    0x44(%eax),%eax
f0104699:	a3 40 62 24 f0       	mov    %eax,0xf0246240
	*newenv_store = e;
f010469e:	8b 45 08             	mov    0x8(%ebp),%eax
f01046a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01046a4:	89 10                	mov    %edx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01046a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046a9:	8b 58 48             	mov    0x48(%eax),%ebx
f01046ac:	e8 71 45 00 00       	call   f0108c22 <cpunum>
f01046b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b4:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01046b9:	8b 00                	mov    (%eax),%eax
f01046bb:	85 c0                	test   %eax,%eax
f01046bd:	74 14                	je     f01046d3 <env_alloc+0x14d>
f01046bf:	e8 5e 45 00 00       	call   f0108c22 <cpunum>
f01046c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c7:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01046cc:	8b 00                	mov    (%eax),%eax
f01046ce:	8b 40 48             	mov    0x48(%eax),%eax
f01046d1:	eb 05                	jmp    f01046d8 <env_alloc+0x152>
f01046d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01046d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01046dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e0:	c7 04 24 7c a4 10 f0 	movl   $0xf010a47c,(%esp)
f01046e7:	e8 c4 08 00 00       	call   f0104fb0 <cprintf>
	return 0;
f01046ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046f1:	83 c4 24             	add    $0x24,%esp
f01046f4:	5b                   	pop    %ebx
f01046f5:	5d                   	pop    %ebp
f01046f6:	c3                   	ret    

f01046f7 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01046f7:	55                   	push   %ebp
f01046f8:	89 e5                	mov    %esp,%ebp
f01046fa:	83 ec 38             	sub    $0x38,%esp
	// LAB 3: Your code here.
	int i;
	uintptr_t aligned_va = ROUNDDOWN((uintptr_t)va,PGSIZE);
f01046fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104700:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104703:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104706:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010470b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	size_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
f010470e:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0104715:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104718:	8b 45 10             	mov    0x10(%ebp),%eax
f010471b:	01 c2                	add    %eax,%edx
f010471d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104720:	01 d0                	add    %edx,%eax
f0104722:	83 e8 01             	sub    $0x1,%eax
f0104725:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0104728:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010472b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104730:	f7 75 ec             	divl   -0x14(%ebp)
f0104733:	89 d0                	mov    %edx,%eax
f0104735:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104738:	29 c2                	sub    %eax,%edx
f010473a:	89 d0                	mov    %edx,%eax
f010473c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(;aligned_va < aligned_end_va;aligned_va += PGSIZE){
f010473f:	eb 6b                	jmp    f01047ac <region_alloc+0xb5>
		struct PageInfo *p = NULL;
f0104741:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		p = page_alloc(!ALLOC_ZERO);
f0104748:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010474f:	e8 2e d1 ff ff       	call   f0101882 <page_alloc>
f0104754:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (!p)
f0104757:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010475b:	75 24                	jne    f0104781 <region_alloc+0x8a>
			panic("env_alloc: %e",-E_NO_MEM);
f010475d:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f0104764:	ff 
f0104765:	c7 44 24 08 91 a4 10 	movl   $0xf010a491,0x8(%esp)
f010476c:	f0 
f010476d:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0104774:	00 
f0104775:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f010477c:	e8 4e bb ff ff       	call   f01002cf <_panic>
		page_insert(e->env_pgdir, p, (void*)aligned_va, PTE_P | PTE_U | PTE_W);
f0104781:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104784:	8b 45 08             	mov    0x8(%ebp),%eax
f0104787:	8b 40 60             	mov    0x60(%eax),%eax
f010478a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104791:	00 
f0104792:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104796:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104799:	89 54 24 04          	mov    %edx,0x4(%esp)
f010479d:	89 04 24             	mov    %eax,(%esp)
f01047a0:	e8 66 d3 ff ff       	call   f0101b0b <page_insert>
{
	// LAB 3: Your code here.
	int i;
	uintptr_t aligned_va = ROUNDDOWN((uintptr_t)va,PGSIZE);
	size_t aligned_end_va = ROUNDUP((uint32_t)va + len,PGSIZE);
	for(;aligned_va < aligned_end_va;aligned_va += PGSIZE){
f01047a5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047af:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f01047b2:	72 8d                	jb     f0104741 <region_alloc+0x4a>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f01047b4:	c9                   	leave  
f01047b5:	c3                   	ret    

f01047b6 <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
void
load_icode(struct Env *e, uint8_t *binary)
{
f01047b6:	55                   	push   %ebp
f01047b7:	89 e5                	mov    %esp,%ebp
f01047b9:	83 ec 38             	sub    $0x38,%esp

	// LAB 3: Your code here.
	struct Proghdr* ph;
	struct Proghdr* eph;
	struct Elf *elfhdr;
	elfhdr = (struct Elf *)binary;
f01047bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(elfhdr->e_magic != ELF_MAGIC) panic("Error in ELF!\n");
f01047c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047c5:	8b 00                	mov    (%eax),%eax
f01047c7:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f01047cc:	74 1c                	je     f01047ea <load_icode+0x34>
f01047ce:	c7 44 24 08 9f a4 10 	movl   $0xf010a49f,0x8(%esp)
f01047d5:	f0 
f01047d6:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f01047dd:	00 
f01047de:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f01047e5:	e8 e5 ba ff ff       	call   f01002cf <_panic>
	ph = (struct Proghdr *) (binary + elfhdr->e_phoff);
f01047ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047ed:	8b 50 1c             	mov    0x1c(%eax),%edx
f01047f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047f3:	01 d0                	add    %edx,%eax
f01047f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	eph = ph + elfhdr->e_phnum;
f01047f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047fb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f01047ff:	0f b7 c0             	movzwl %ax,%eax
f0104802:	c1 e0 05             	shl    $0x5,%eax
f0104805:	89 c2                	mov    %eax,%edx
f0104807:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010480a:	01 d0                	add    %edx,%eax
f010480c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	lcr3(PADDR(e->env_pgdir));
f010480f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104812:	8b 40 60             	mov    0x60(%eax),%eax
f0104815:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104819:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0104820:	00 
f0104821:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f0104828:	e8 07 fa ff ff       	call   f0104234 <_paddr>
f010482d:	89 45 e8             	mov    %eax,-0x18(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104830:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104833:	0f 22 d8             	mov    %eax,%cr3
	for (; ph < eph; ph++){
f0104836:	e9 b4 00 00 00       	jmp    f01048ef <load_icode+0x139>
		if(ph->p_type == ELF_PROG_LOAD){
f010483b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010483e:	8b 00                	mov    (%eax),%eax
f0104840:	83 f8 01             	cmp    $0x1,%eax
f0104843:	0f 85 a2 00 00 00    	jne    f01048eb <load_icode+0x135>
			if(ph->p_filesz > ph->p_memsz) panic("ph->p_filesz > ph->p_memsz\n");
f0104849:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010484c:	8b 50 10             	mov    0x10(%eax),%edx
f010484f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104852:	8b 40 14             	mov    0x14(%eax),%eax
f0104855:	39 c2                	cmp    %eax,%edx
f0104857:	76 1c                	jbe    f0104875 <load_icode+0xbf>
f0104859:	c7 44 24 08 ae a4 10 	movl   $0xf010a4ae,0x8(%esp)
f0104860:	f0 
f0104861:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
f0104868:	00 
f0104869:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f0104870:	e8 5a ba ff ff       	call   f01002cf <_panic>
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0104875:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104878:	8b 50 14             	mov    0x14(%eax),%edx
f010487b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010487e:	8b 40 08             	mov    0x8(%eax),%eax
f0104881:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104885:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104889:	8b 45 08             	mov    0x8(%ebp),%eax
f010488c:	89 04 24             	mov    %eax,(%esp)
f010488f:	e8 63 fe ff ff       	call   f01046f7 <region_alloc>
			memcpy((void *)ph->p_va, (void *)(binary + ph->p_offset),ph->p_filesz);
f0104894:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104897:	8b 50 10             	mov    0x10(%eax),%edx
f010489a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010489d:	8b 48 04             	mov    0x4(%eax),%ecx
f01048a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01048a3:	01 c1                	add    %eax,%ecx
f01048a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048a8:	8b 40 08             	mov    0x8(%eax),%eax
f01048ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01048b3:	89 04 24             	mov    %eax,(%esp)
f01048b6:	e8 e4 39 00 00       	call   f010829f <memcpy>
			memset((void *)(ph->p_va + ph->p_filesz),0, ph->p_memsz - ph->p_filesz);
f01048bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048be:	8b 50 14             	mov    0x14(%eax),%edx
f01048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048c4:	8b 40 10             	mov    0x10(%eax),%eax
f01048c7:	29 c2                	sub    %eax,%edx
f01048c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048cc:	8b 48 08             	mov    0x8(%eax),%ecx
f01048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048d2:	8b 40 10             	mov    0x10(%eax),%eax
f01048d5:	01 c8                	add    %ecx,%eax
f01048d7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01048e2:	00 
f01048e3:	89 04 24             	mov    %eax,(%esp)
f01048e6:	e8 6c 38 00 00       	call   f0108157 <memset>
	elfhdr = (struct Elf *)binary;
	if(elfhdr->e_magic != ELF_MAGIC) panic("Error in ELF!\n");
	ph = (struct Proghdr *) (binary + elfhdr->e_phoff);
	eph = ph + elfhdr->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++){
f01048eb:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
f01048ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048f2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01048f5:	0f 82 40 ff ff ff    	jb     f010483b <load_icode+0x85>
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e,(void *)(USTACKTOP-PGSIZE),PGSIZE);
f01048fb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0104902:	00 
f0104903:	c7 44 24 04 00 d0 bf 	movl   $0xeebfd000,0x4(%esp)
f010490a:	ee 
f010490b:	8b 45 08             	mov    0x8(%ebp),%eax
f010490e:	89 04 24             	mov    %eax,(%esp)
f0104911:	e8 e1 fd ff ff       	call   f01046f7 <region_alloc>
	e->env_tf.tf_eip = elfhdr->e_entry;
f0104916:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104919:	8b 50 18             	mov    0x18(%eax),%edx
f010491c:	8b 45 08             	mov    0x8(%ebp),%eax
f010491f:	89 50 30             	mov    %edx,0x30(%eax)
	lcr3(PADDR(kern_pgdir));
f0104922:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f0104927:	89 44 24 08          	mov    %eax,0x8(%esp)
f010492b:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0104932:	00 
f0104933:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f010493a:	e8 f5 f8 ff ff       	call   f0104234 <_paddr>
f010493f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104942:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104945:	0f 22 d8             	mov    %eax,%cr3
}
f0104948:	c9                   	leave  
f0104949:	c3                   	ret    

f010494a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010494a:	55                   	push   %ebp
f010494b:	89 e5                	mov    %esp,%ebp
f010494d:	83 ec 28             	sub    $0x28,%esp
	// LAB 3: Your code here.
	struct Env *e;
	if(env_alloc(&e,0) < 0) panic("env_alloc failed!\n");
f0104950:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104957:	00 
f0104958:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010495b:	89 04 24             	mov    %eax,(%esp)
f010495e:	e8 23 fc ff ff       	call   f0104586 <env_alloc>
f0104963:	85 c0                	test   %eax,%eax
f0104965:	79 1c                	jns    f0104983 <env_create+0x39>
f0104967:	c7 44 24 08 ca a4 10 	movl   $0xf010a4ca,0x8(%esp)
f010496e:	f0 
f010496f:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f0104976:	00 
f0104977:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f010497e:	e8 4c b9 ff ff       	call   f01002cf <_panic>
	load_icode(e,binary);
f0104983:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104986:	8b 55 08             	mov    0x8(%ebp),%edx
f0104989:	89 54 24 04          	mov    %edx,0x4(%esp)
f010498d:	89 04 24             	mov    %eax,(%esp)
f0104990:	e8 21 fe ff ff       	call   f01047b6 <load_icode>
	e->env_type = type;
f0104995:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104998:	8b 55 0c             	mov    0xc(%ebp),%edx
f010499b:	89 50 50             	mov    %edx,0x50(%eax)
	e->env_parent_id = 0;
f010499e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01049a1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
}
f01049a8:	c9                   	leave  
f01049a9:	c3                   	ret    

f01049aa <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01049aa:	55                   	push   %ebp
f01049ab:	89 e5                	mov    %esp,%ebp
f01049ad:	53                   	push   %ebx
f01049ae:	83 ec 34             	sub    $0x34,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01049b1:	e8 6c 42 00 00       	call   f0108c22 <cpunum>
f01049b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b9:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01049be:	8b 00                	mov    (%eax),%eax
f01049c0:	3b 45 08             	cmp    0x8(%ebp),%eax
f01049c3:	75 26                	jne    f01049eb <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f01049c5:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f01049ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049ce:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f01049d5:	00 
f01049d6:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f01049dd:	e8 52 f8 ff ff       	call   f0104234 <_paddr>
f01049e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049e8:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01049eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ee:	8b 58 48             	mov    0x48(%eax),%ebx
f01049f1:	e8 2c 42 00 00       	call   f0108c22 <cpunum>
f01049f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f9:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01049fe:	8b 00                	mov    (%eax),%eax
f0104a00:	85 c0                	test   %eax,%eax
f0104a02:	74 14                	je     f0104a18 <env_free+0x6e>
f0104a04:	e8 19 42 00 00       	call   f0108c22 <cpunum>
f0104a09:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0c:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104a11:	8b 00                	mov    (%eax),%eax
f0104a13:	8b 40 48             	mov    0x48(%eax),%eax
f0104a16:	eb 05                	jmp    f0104a1d <env_free+0x73>
f0104a18:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a1d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a25:	c7 04 24 dd a4 10 f0 	movl   $0xf010a4dd,(%esp)
f0104a2c:	e8 7f 05 00 00       	call   f0104fb0 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104a31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0104a38:	e9 cf 00 00 00       	jmp    f0104b0c <env_free+0x162>

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0104a3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a40:	8b 40 60             	mov    0x60(%eax),%eax
f0104a43:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a46:	c1 e2 02             	shl    $0x2,%edx
f0104a49:	01 d0                	add    %edx,%eax
f0104a4b:	8b 00                	mov    (%eax),%eax
f0104a4d:	83 e0 01             	and    $0x1,%eax
f0104a50:	85 c0                	test   %eax,%eax
f0104a52:	75 05                	jne    f0104a59 <env_free+0xaf>
			continue;
f0104a54:	e9 af 00 00 00       	jmp    f0104b08 <env_free+0x15e>

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0104a59:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a5c:	8b 40 60             	mov    0x60(%eax),%eax
f0104a5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a62:	c1 e2 02             	shl    $0x2,%edx
f0104a65:	01 d0                	add    %edx,%eax
f0104a67:	8b 00                	mov    (%eax),%eax
f0104a69:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104a6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		pt = (pte_t*) KADDR(pa);
f0104a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a74:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a78:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f0104a7f:	00 
f0104a80:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f0104a87:	e8 e3 f7 ff ff       	call   f010426f <_kaddr>
f0104a8c:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104a8f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104a96:	eb 40                	jmp    f0104ad8 <env_free+0x12e>
			if (pt[pteno] & PTE_P)
f0104a98:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104aa2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0104aa5:	01 d0                	add    %edx,%eax
f0104aa7:	8b 00                	mov    (%eax),%eax
f0104aa9:	83 e0 01             	and    $0x1,%eax
f0104aac:	85 c0                	test   %eax,%eax
f0104aae:	74 24                	je     f0104ad4 <env_free+0x12a>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ab3:	c1 e0 16             	shl    $0x16,%eax
f0104ab6:	89 c2                	mov    %eax,%edx
f0104ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104abb:	c1 e0 0c             	shl    $0xc,%eax
f0104abe:	09 d0                	or     %edx,%eax
f0104ac0:	89 c2                	mov    %eax,%edx
f0104ac2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac5:	8b 40 60             	mov    0x60(%eax),%eax
f0104ac8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104acc:	89 04 24             	mov    %eax,(%esp)
f0104acf:	e8 1c d1 ff ff       	call   f0101bf0 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104ad4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0104ad8:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0104adf:	76 b7                	jbe    f0104a98 <env_free+0xee>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104ae1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ae4:	8b 40 60             	mov    0x60(%eax),%eax
f0104ae7:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104aea:	c1 e2 02             	shl    $0x2,%edx
f0104aed:	01 d0                	add    %edx,%eax
f0104aef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		page_decref(pa2page(pa));
f0104af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104af8:	89 04 24             	mov    %eax,(%esp)
f0104afb:	e8 c8 f7 ff ff       	call   f01042c8 <pa2page>
f0104b00:	89 04 24             	mov    %eax,(%esp)
f0104b03:	e8 45 ce ff ff       	call   f010194d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0104b08:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104b0c:	81 7d f4 ba 03 00 00 	cmpl   $0x3ba,-0xc(%ebp)
f0104b13:	0f 86 24 ff ff ff    	jbe    f0104a3d <env_free+0x93>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104b19:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b1c:	8b 40 60             	mov    0x60(%eax),%eax
f0104b1f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b23:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0104b2a:	00 
f0104b2b:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f0104b32:	e8 fd f6 ff ff       	call   f0104234 <_paddr>
f0104b37:	89 45 ec             	mov    %eax,-0x14(%ebp)
	e->env_pgdir = 0;
f0104b3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b3d:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
	page_decref(pa2page(pa));
f0104b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b47:	89 04 24             	mov    %eax,(%esp)
f0104b4a:	e8 79 f7 ff ff       	call   f01042c8 <pa2page>
f0104b4f:	89 04 24             	mov    %eax,(%esp)
f0104b52:	e8 f6 cd ff ff       	call   f010194d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104b57:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b5a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0104b61:	8b 15 40 62 24 f0    	mov    0xf0246240,%edx
f0104b67:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b6a:	89 50 44             	mov    %edx,0x44(%eax)
	env_free_list = e;
f0104b6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b70:	a3 40 62 24 f0       	mov    %eax,0xf0246240
}
f0104b75:	83 c4 34             	add    $0x34,%esp
f0104b78:	5b                   	pop    %ebx
f0104b79:	5d                   	pop    %ebp
f0104b7a:	c3                   	ret    

f0104b7b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104b7b:	55                   	push   %ebp
f0104b7c:	89 e5                	mov    %esp,%ebp
f0104b7e:	83 ec 18             	sub    $0x18,%esp
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104b81:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b84:	8b 40 54             	mov    0x54(%eax),%eax
f0104b87:	83 f8 03             	cmp    $0x3,%eax
f0104b8a:	75 20                	jne    f0104bac <env_destroy+0x31>
f0104b8c:	e8 91 40 00 00       	call   f0108c22 <cpunum>
f0104b91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b94:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104b99:	8b 00                	mov    (%eax),%eax
f0104b9b:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104b9e:	74 0c                	je     f0104bac <env_destroy+0x31>
		e->env_status = ENV_DYING;
f0104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ba3:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
		return;
f0104baa:	eb 37                	jmp    f0104be3 <env_destroy+0x68>
	}

	env_free(e);
f0104bac:	8b 45 08             	mov    0x8(%ebp),%eax
f0104baf:	89 04 24             	mov    %eax,(%esp)
f0104bb2:	e8 f3 fd ff ff       	call   f01049aa <env_free>

	if (curenv == e) {
f0104bb7:	e8 66 40 00 00       	call   f0108c22 <cpunum>
f0104bbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bbf:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104bc4:	8b 00                	mov    (%eax),%eax
f0104bc6:	3b 45 08             	cmp    0x8(%ebp),%eax
f0104bc9:	75 18                	jne    f0104be3 <env_destroy+0x68>
		curenv = NULL;
f0104bcb:	e8 52 40 00 00       	call   f0108c22 <cpunum>
f0104bd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bd3:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104bd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		sched_yield();
f0104bde:	e8 7a 1a 00 00       	call   f010665d <sched_yield>
	}
}
f0104be3:	c9                   	leave  
f0104be4:	c3                   	ret    

f0104be5 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104be5:	55                   	push   %ebp
f0104be6:	89 e5                	mov    %esp,%ebp
f0104be8:	53                   	push   %ebx
f0104be9:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0104bec:	e8 31 40 00 00       	call   f0108c22 <cpunum>
f0104bf1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bf4:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104bf9:	8b 18                	mov    (%eax),%ebx
f0104bfb:	e8 22 40 00 00       	call   f0108c22 <cpunum>
f0104c00:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104c03:	8b 65 08             	mov    0x8(%ebp),%esp
f0104c06:	61                   	popa   
f0104c07:	07                   	pop    %es
f0104c08:	1f                   	pop    %ds
f0104c09:	83 c4 08             	add    $0x8,%esp
f0104c0c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104c0d:	c7 44 24 08 f3 a4 10 	movl   $0xf010a4f3,0x8(%esp)
f0104c14:	f0 
f0104c15:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
f0104c1c:	00 
f0104c1d:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f0104c24:	e8 a6 b6 ff ff       	call   f01002cf <_panic>

f0104c29 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104c29:	55                   	push   %ebp
f0104c2a:	89 e5                	mov    %esp,%ebp
f0104c2c:	83 ec 28             	sub    $0x28,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if(curenv && (curenv->env_status == ENV_RUNNING)) curenv->env_status = ENV_RUNNABLE;
f0104c2f:	e8 ee 3f 00 00       	call   f0108c22 <cpunum>
f0104c34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c37:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104c3c:	8b 00                	mov    (%eax),%eax
f0104c3e:	85 c0                	test   %eax,%eax
f0104c40:	74 2d                	je     f0104c6f <env_run+0x46>
f0104c42:	e8 db 3f 00 00       	call   f0108c22 <cpunum>
f0104c47:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c4a:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104c4f:	8b 00                	mov    (%eax),%eax
f0104c51:	8b 40 54             	mov    0x54(%eax),%eax
f0104c54:	83 f8 03             	cmp    $0x3,%eax
f0104c57:	75 16                	jne    f0104c6f <env_run+0x46>
f0104c59:	e8 c4 3f 00 00       	call   f0108c22 <cpunum>
f0104c5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c61:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104c66:	8b 00                	mov    (%eax),%eax
f0104c68:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0104c6f:	e8 ae 3f 00 00       	call   f0108c22 <cpunum>
f0104c74:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c77:	8d 90 28 70 24 f0    	lea    -0xfdb8fd8(%eax),%edx
f0104c7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c80:	89 02                	mov    %eax,(%edx)
	curenv->env_status = ENV_RUNNING;
f0104c82:	e8 9b 3f 00 00       	call   f0108c22 <cpunum>
f0104c87:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c8a:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104c8f:	8b 00                	mov    (%eax),%eax
f0104c91:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0104c98:	e8 85 3f 00 00       	call   f0108c22 <cpunum>
f0104c9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca0:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104ca5:	8b 00                	mov    (%eax),%eax
f0104ca7:	8b 50 58             	mov    0x58(%eax),%edx
f0104caa:	83 c2 01             	add    $0x1,%edx
f0104cad:	89 50 58             	mov    %edx,0x58(%eax)
	unlock_kernel();
f0104cb0:	e8 83 f6 ff ff       	call   f0104338 <unlock_kernel>
	lcr3(PADDR(curenv->env_pgdir));
f0104cb5:	e8 68 3f 00 00       	call   f0108c22 <cpunum>
f0104cba:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cbd:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104cc2:	8b 00                	mov    (%eax),%eax
f0104cc4:	8b 40 60             	mov    0x60(%eax),%eax
f0104cc7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ccb:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
f0104cd2:	00 
f0104cd3:	c7 04 24 71 a4 10 f0 	movl   $0xf010a471,(%esp)
f0104cda:	e8 55 f5 ff ff       	call   f0104234 <_paddr>
f0104cdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ce5:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(curenv->env_tf));
f0104ce8:	e8 35 3f 00 00       	call   f0108c22 <cpunum>
f0104ced:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf0:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0104cf5:	8b 00                	mov    (%eax),%eax
f0104cf7:	89 04 24             	mov    %eax,(%esp)
f0104cfa:	e8 e6 fe ff ff       	call   f0104be5 <env_pop_tf>

f0104cff <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104cff:	55                   	push   %ebp
f0104d00:	89 e5                	mov    %esp,%ebp
f0104d02:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104d05:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d08:	0f b6 c0             	movzbl %al,%eax
f0104d0b:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104d12:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104d15:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104d19:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104d1c:	ee                   	out    %al,(%dx)
f0104d1d:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d27:	89 c2                	mov    %eax,%edx
f0104d29:	ec                   	in     (%dx),%al
f0104d2a:	88 45 f3             	mov    %al,-0xd(%ebp)
	return data;
f0104d2d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
	return inb(IO_RTC+1);
f0104d31:	0f b6 c0             	movzbl %al,%eax
}
f0104d34:	c9                   	leave  
f0104d35:	c3                   	ret    

f0104d36 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104d36:	55                   	push   %ebp
f0104d37:	89 e5                	mov    %esp,%ebp
f0104d39:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0104d3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d3f:	0f b6 c0             	movzbl %al,%eax
f0104d42:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0104d49:	88 45 fb             	mov    %al,-0x5(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104d4c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
f0104d50:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104d53:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0104d54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d57:	0f b6 c0             	movzbl %al,%eax
f0104d5a:	c7 45 f4 71 00 00 00 	movl   $0x71,-0xc(%ebp)
f0104d61:	88 45 f3             	mov    %al,-0xd(%ebp)
f0104d64:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d68:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d6b:	ee                   	out    %al,(%dx)
}
f0104d6c:	c9                   	leave  
f0104d6d:	c3                   	ret    

f0104d6e <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104d6e:	55                   	push   %ebp
f0104d6f:	89 e5                	mov    %esp,%ebp
f0104d71:	81 ec 88 00 00 00    	sub    $0x88,%esp
	didinit = 1;
f0104d77:	c6 05 44 62 24 f0 01 	movb   $0x1,0xf0246244
f0104d7e:	c7 45 f4 21 00 00 00 	movl   $0x21,-0xc(%ebp)
f0104d85:	c6 45 f3 ff          	movb   $0xff,-0xd(%ebp)
f0104d89:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0104d8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104d90:	ee                   	out    %al,(%dx)
f0104d91:	c7 45 ec a1 00 00 00 	movl   $0xa1,-0x14(%ebp)
f0104d98:	c6 45 eb ff          	movb   $0xff,-0x15(%ebp)
f0104d9c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0104da0:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104da3:	ee                   	out    %al,(%dx)
f0104da4:	c7 45 e4 20 00 00 00 	movl   $0x20,-0x1c(%ebp)
f0104dab:	c6 45 e3 11          	movb   $0x11,-0x1d(%ebp)
f0104daf:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0104db3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104db6:	ee                   	out    %al,(%dx)
f0104db7:	c7 45 dc 21 00 00 00 	movl   $0x21,-0x24(%ebp)
f0104dbe:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
f0104dc2:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
f0104dc6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104dc9:	ee                   	out    %al,(%dx)
f0104dca:	c7 45 d4 21 00 00 00 	movl   $0x21,-0x2c(%ebp)
f0104dd1:	c6 45 d3 04          	movb   $0x4,-0x2d(%ebp)
f0104dd5:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f0104dd9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104ddc:	ee                   	out    %al,(%dx)
f0104ddd:	c7 45 cc 21 00 00 00 	movl   $0x21,-0x34(%ebp)
f0104de4:	c6 45 cb 03          	movb   $0x3,-0x35(%ebp)
f0104de8:	0f b6 45 cb          	movzbl -0x35(%ebp),%eax
f0104dec:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104def:	ee                   	out    %al,(%dx)
f0104df0:	c7 45 c4 a0 00 00 00 	movl   $0xa0,-0x3c(%ebp)
f0104df7:	c6 45 c3 11          	movb   $0x11,-0x3d(%ebp)
f0104dfb:	0f b6 45 c3          	movzbl -0x3d(%ebp),%eax
f0104dff:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104e02:	ee                   	out    %al,(%dx)
f0104e03:	c7 45 bc a1 00 00 00 	movl   $0xa1,-0x44(%ebp)
f0104e0a:	c6 45 bb 28          	movb   $0x28,-0x45(%ebp)
f0104e0e:	0f b6 45 bb          	movzbl -0x45(%ebp),%eax
f0104e12:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104e15:	ee                   	out    %al,(%dx)
f0104e16:	c7 45 b4 a1 00 00 00 	movl   $0xa1,-0x4c(%ebp)
f0104e1d:	c6 45 b3 02          	movb   $0x2,-0x4d(%ebp)
f0104e21:	0f b6 45 b3          	movzbl -0x4d(%ebp),%eax
f0104e25:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104e28:	ee                   	out    %al,(%dx)
f0104e29:	c7 45 ac a1 00 00 00 	movl   $0xa1,-0x54(%ebp)
f0104e30:	c6 45 ab 01          	movb   $0x1,-0x55(%ebp)
f0104e34:	0f b6 45 ab          	movzbl -0x55(%ebp),%eax
f0104e38:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0104e3b:	ee                   	out    %al,(%dx)
f0104e3c:	c7 45 a4 20 00 00 00 	movl   $0x20,-0x5c(%ebp)
f0104e43:	c6 45 a3 68          	movb   $0x68,-0x5d(%ebp)
f0104e47:	0f b6 45 a3          	movzbl -0x5d(%ebp),%eax
f0104e4b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
f0104e4e:	ee                   	out    %al,(%dx)
f0104e4f:	c7 45 9c 20 00 00 00 	movl   $0x20,-0x64(%ebp)
f0104e56:	c6 45 9b 0a          	movb   $0xa,-0x65(%ebp)
f0104e5a:	0f b6 45 9b          	movzbl -0x65(%ebp),%eax
f0104e5e:	8b 55 9c             	mov    -0x64(%ebp),%edx
f0104e61:	ee                   	out    %al,(%dx)
f0104e62:	c7 45 94 a0 00 00 00 	movl   $0xa0,-0x6c(%ebp)
f0104e69:	c6 45 93 68          	movb   $0x68,-0x6d(%ebp)
f0104e6d:	0f b6 45 93          	movzbl -0x6d(%ebp),%eax
f0104e71:	8b 55 94             	mov    -0x6c(%ebp),%edx
f0104e74:	ee                   	out    %al,(%dx)
f0104e75:	c7 45 8c a0 00 00 00 	movl   $0xa0,-0x74(%ebp)
f0104e7c:	c6 45 8b 0a          	movb   $0xa,-0x75(%ebp)
f0104e80:	0f b6 45 8b          	movzbl -0x75(%ebp),%eax
f0104e84:	8b 55 8c             	mov    -0x74(%ebp),%edx
f0104e87:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104e88:	0f b7 05 ce 65 12 f0 	movzwl 0xf01265ce,%eax
f0104e8f:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104e93:	74 12                	je     f0104ea7 <pic_init+0x139>
		irq_setmask_8259A(irq_mask_8259A);
f0104e95:	0f b7 05 ce 65 12 f0 	movzwl 0xf01265ce,%eax
f0104e9c:	0f b7 c0             	movzwl %ax,%eax
f0104e9f:	89 04 24             	mov    %eax,(%esp)
f0104ea2:	e8 02 00 00 00       	call   f0104ea9 <irq_setmask_8259A>
}
f0104ea7:	c9                   	leave  
f0104ea8:	c3                   	ret    

f0104ea9 <irq_setmask_8259A>:

void
irq_setmask_8259A(uint16_t mask)
{
f0104ea9:	55                   	push   %ebp
f0104eaa:	89 e5                	mov    %esp,%ebp
f0104eac:	83 ec 38             	sub    $0x38,%esp
f0104eaf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104eb2:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
	int i;
	irq_mask_8259A = mask;
f0104eb6:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104eba:	66 a3 ce 65 12 f0    	mov    %ax,0xf01265ce
	if (!didinit)
f0104ec0:	0f b6 05 44 62 24 f0 	movzbl 0xf0246244,%eax
f0104ec7:	83 f0 01             	xor    $0x1,%eax
f0104eca:	84 c0                	test   %al,%al
f0104ecc:	74 05                	je     f0104ed3 <irq_setmask_8259A+0x2a>
		return;
f0104ece:	e9 8c 00 00 00       	jmp    f0104f5f <irq_setmask_8259A+0xb6>
	outb(IO_PIC1+1, (char)mask);
f0104ed3:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104ed7:	0f b6 c0             	movzbl %al,%eax
f0104eda:	c7 45 f0 21 00 00 00 	movl   $0x21,-0x10(%ebp)
f0104ee1:	88 45 ef             	mov    %al,-0x11(%ebp)
f0104ee4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
f0104ee8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104eeb:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104eec:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104ef0:	66 c1 e8 08          	shr    $0x8,%ax
f0104ef4:	0f b6 c0             	movzbl %al,%eax
f0104ef7:	c7 45 e8 a1 00 00 00 	movl   $0xa1,-0x18(%ebp)
f0104efe:	88 45 e7             	mov    %al,-0x19(%ebp)
f0104f01:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0104f05:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104f08:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104f09:	c7 04 24 ff a4 10 f0 	movl   $0xf010a4ff,(%esp)
f0104f10:	e8 9b 00 00 00       	call   f0104fb0 <cprintf>
	for (i = 0; i < 16; i++)
f0104f15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0104f1c:	eb 2f                	jmp    f0104f4d <irq_setmask_8259A+0xa4>
		if (~mask & (1<<i))
f0104f1e:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
f0104f22:	f7 d0                	not    %eax
f0104f24:	89 c2                	mov    %eax,%edx
f0104f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f29:	89 c1                	mov    %eax,%ecx
f0104f2b:	d3 fa                	sar    %cl,%edx
f0104f2d:	89 d0                	mov    %edx,%eax
f0104f2f:	83 e0 01             	and    $0x1,%eax
f0104f32:	85 c0                	test   %eax,%eax
f0104f34:	74 13                	je     f0104f49 <irq_setmask_8259A+0xa0>
			cprintf(" %d", i);
f0104f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104f39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f3d:	c7 04 24 13 a5 10 f0 	movl   $0xf010a513,(%esp)
f0104f44:	e8 67 00 00 00       	call   f0104fb0 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104f49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0104f4d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
f0104f51:	7e cb                	jle    f0104f1e <irq_setmask_8259A+0x75>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104f53:	c7 04 24 17 a5 10 f0 	movl   $0xf010a517,(%esp)
f0104f5a:	e8 51 00 00 00       	call   f0104fb0 <cprintf>
}
f0104f5f:	c9                   	leave  
f0104f60:	c3                   	ret    

f0104f61 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104f61:	55                   	push   %ebp
f0104f62:	89 e5                	mov    %esp,%ebp
f0104f64:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104f67:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f6a:	89 04 24             	mov    %eax,(%esp)
f0104f6d:	e8 2e bc ff ff       	call   f0100ba0 <cputchar>
	*cnt++;
f0104f72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f75:	83 c0 04             	add    $0x4,%eax
f0104f78:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0104f7b:	c9                   	leave  
f0104f7c:	c3                   	ret    

f0104f7d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104f7d:	55                   	push   %ebp
f0104f7e:	89 e5                	mov    %esp,%ebp
f0104f80:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104f83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104f91:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f9f:	c7 04 24 61 4f 10 f0 	movl   $0xf0104f61,(%esp)
f0104fa6:	e8 a0 29 00 00       	call   f010794b <vprintfmt>
	return cnt;
f0104fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104fae:	c9                   	leave  
f0104faf:	c3                   	ret    

f0104fb0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104fb0:	55                   	push   %ebp
f0104fb1:	89 e5                	mov    %esp,%ebp
f0104fb3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104fb6:	8d 45 0c             	lea    0xc(%ebp),%eax
f0104fb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
f0104fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fc6:	89 04 24             	mov    %eax,(%esp)
f0104fc9:	e8 af ff ff ff       	call   f0104f7d <vcprintf>
f0104fce:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
f0104fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104fd4:	c9                   	leave  
f0104fd5:	c3                   	ret    

f0104fd6 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0104fd6:	55                   	push   %ebp
f0104fd7:	89 e5                	mov    %esp,%ebp
f0104fd9:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104fdc:	8b 55 08             	mov    0x8(%ebp),%edx
f0104fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104fe2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104fe5:	f0 87 02             	lock xchg %eax,(%edx)
f0104fe8:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0104feb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104fee:	c9                   	leave  
f0104fef:	c3                   	ret    

f0104ff0 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0104ff0:	55                   	push   %ebp
f0104ff1:	89 e5                	mov    %esp,%ebp
f0104ff3:	83 ec 18             	sub    $0x18,%esp
	spin_lock(&kernel_lock);
f0104ff6:	c7 04 24 e0 65 12 f0 	movl   $0xf01265e0,(%esp)
f0104ffd:	e8 9b 3e 00 00       	call   f0108e9d <spin_lock>
}
f0105002:	c9                   	leave  
f0105003:	c3                   	ret    

f0105004 <trapname>:
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
f0105004:	55                   	push   %ebp
f0105005:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0105007:	8b 45 08             	mov    0x8(%ebp),%eax
f010500a:	83 f8 13             	cmp    $0x13,%eax
f010500d:	77 0c                	ja     f010501b <trapname+0x17>
		return excnames[trapno];
f010500f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105012:	8b 04 85 a0 a9 10 f0 	mov    -0xfef5660(,%eax,4),%eax
f0105019:	eb 25                	jmp    f0105040 <trapname+0x3c>
	if (trapno == T_SYSCALL)
f010501b:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f010501f:	75 07                	jne    f0105028 <trapname+0x24>
		return "System call";
f0105021:	b8 20 a5 10 f0       	mov    $0xf010a520,%eax
f0105026:	eb 18                	jmp    f0105040 <trapname+0x3c>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0105028:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
f010502c:	7e 0d                	jle    f010503b <trapname+0x37>
f010502e:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
f0105032:	7f 07                	jg     f010503b <trapname+0x37>
		return "Hardware Interrupt";
f0105034:	b8 2c a5 10 f0       	mov    $0xf010a52c,%eax
f0105039:	eb 05                	jmp    f0105040 <trapname+0x3c>
	return "(unknown trap)";
f010503b:	b8 3f a5 10 f0       	mov    $0xf010a53f,%eax
}
f0105040:	5d                   	pop    %ebp
f0105041:	c3                   	ret    

f0105042 <trap_init>:
void irq_ide();
void irq_error();

void
trap_init(void)
{
f0105042:	55                   	push   %ebp
f0105043:	89 e5                	mov    %esp,%ebp
f0105045:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0105048:	b8 5e 65 10 f0       	mov    $0xf010655e,%eax
f010504d:	66 a3 60 62 24 f0    	mov    %ax,0xf0246260
f0105053:	66 c7 05 62 62 24 f0 	movw   $0x8,0xf0246262
f010505a:	08 00 
f010505c:	0f b6 05 64 62 24 f0 	movzbl 0xf0246264,%eax
f0105063:	83 e0 e0             	and    $0xffffffe0,%eax
f0105066:	a2 64 62 24 f0       	mov    %al,0xf0246264
f010506b:	0f b6 05 64 62 24 f0 	movzbl 0xf0246264,%eax
f0105072:	83 e0 1f             	and    $0x1f,%eax
f0105075:	a2 64 62 24 f0       	mov    %al,0xf0246264
f010507a:	0f b6 05 65 62 24 f0 	movzbl 0xf0246265,%eax
f0105081:	83 e0 f0             	and    $0xfffffff0,%eax
f0105084:	83 c8 0e             	or     $0xe,%eax
f0105087:	a2 65 62 24 f0       	mov    %al,0xf0246265
f010508c:	0f b6 05 65 62 24 f0 	movzbl 0xf0246265,%eax
f0105093:	83 e0 ef             	and    $0xffffffef,%eax
f0105096:	a2 65 62 24 f0       	mov    %al,0xf0246265
f010509b:	0f b6 05 65 62 24 f0 	movzbl 0xf0246265,%eax
f01050a2:	83 e0 9f             	and    $0xffffff9f,%eax
f01050a5:	a2 65 62 24 f0       	mov    %al,0xf0246265
f01050aa:	0f b6 05 65 62 24 f0 	movzbl 0xf0246265,%eax
f01050b1:	83 c8 80             	or     $0xffffff80,%eax
f01050b4:	a2 65 62 24 f0       	mov    %al,0xf0246265
f01050b9:	b8 5e 65 10 f0       	mov    $0xf010655e,%eax
f01050be:	c1 e8 10             	shr    $0x10,%eax
f01050c1:	66 a3 66 62 24 f0    	mov    %ax,0xf0246266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f01050c7:	b8 64 65 10 f0       	mov    $0xf0106564,%eax
f01050cc:	66 a3 68 62 24 f0    	mov    %ax,0xf0246268
f01050d2:	66 c7 05 6a 62 24 f0 	movw   $0x8,0xf024626a
f01050d9:	08 00 
f01050db:	0f b6 05 6c 62 24 f0 	movzbl 0xf024626c,%eax
f01050e2:	83 e0 e0             	and    $0xffffffe0,%eax
f01050e5:	a2 6c 62 24 f0       	mov    %al,0xf024626c
f01050ea:	0f b6 05 6c 62 24 f0 	movzbl 0xf024626c,%eax
f01050f1:	83 e0 1f             	and    $0x1f,%eax
f01050f4:	a2 6c 62 24 f0       	mov    %al,0xf024626c
f01050f9:	0f b6 05 6d 62 24 f0 	movzbl 0xf024626d,%eax
f0105100:	83 e0 f0             	and    $0xfffffff0,%eax
f0105103:	83 c8 0e             	or     $0xe,%eax
f0105106:	a2 6d 62 24 f0       	mov    %al,0xf024626d
f010510b:	0f b6 05 6d 62 24 f0 	movzbl 0xf024626d,%eax
f0105112:	83 e0 ef             	and    $0xffffffef,%eax
f0105115:	a2 6d 62 24 f0       	mov    %al,0xf024626d
f010511a:	0f b6 05 6d 62 24 f0 	movzbl 0xf024626d,%eax
f0105121:	83 e0 9f             	and    $0xffffff9f,%eax
f0105124:	a2 6d 62 24 f0       	mov    %al,0xf024626d
f0105129:	0f b6 05 6d 62 24 f0 	movzbl 0xf024626d,%eax
f0105130:	83 c8 80             	or     $0xffffff80,%eax
f0105133:	a2 6d 62 24 f0       	mov    %al,0xf024626d
f0105138:	b8 64 65 10 f0       	mov    $0xf0106564,%eax
f010513d:	c1 e8 10             	shr    $0x10,%eax
f0105140:	66 a3 6e 62 24 f0    	mov    %ax,0xf024626e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0105146:	b8 6a 65 10 f0       	mov    $0xf010656a,%eax
f010514b:	66 a3 70 62 24 f0    	mov    %ax,0xf0246270
f0105151:	66 c7 05 72 62 24 f0 	movw   $0x8,0xf0246272
f0105158:	08 00 
f010515a:	0f b6 05 74 62 24 f0 	movzbl 0xf0246274,%eax
f0105161:	83 e0 e0             	and    $0xffffffe0,%eax
f0105164:	a2 74 62 24 f0       	mov    %al,0xf0246274
f0105169:	0f b6 05 74 62 24 f0 	movzbl 0xf0246274,%eax
f0105170:	83 e0 1f             	and    $0x1f,%eax
f0105173:	a2 74 62 24 f0       	mov    %al,0xf0246274
f0105178:	0f b6 05 75 62 24 f0 	movzbl 0xf0246275,%eax
f010517f:	83 e0 f0             	and    $0xfffffff0,%eax
f0105182:	83 c8 0e             	or     $0xe,%eax
f0105185:	a2 75 62 24 f0       	mov    %al,0xf0246275
f010518a:	0f b6 05 75 62 24 f0 	movzbl 0xf0246275,%eax
f0105191:	83 e0 ef             	and    $0xffffffef,%eax
f0105194:	a2 75 62 24 f0       	mov    %al,0xf0246275
f0105199:	0f b6 05 75 62 24 f0 	movzbl 0xf0246275,%eax
f01051a0:	83 e0 9f             	and    $0xffffff9f,%eax
f01051a3:	a2 75 62 24 f0       	mov    %al,0xf0246275
f01051a8:	0f b6 05 75 62 24 f0 	movzbl 0xf0246275,%eax
f01051af:	83 c8 80             	or     $0xffffff80,%eax
f01051b2:	a2 75 62 24 f0       	mov    %al,0xf0246275
f01051b7:	b8 6a 65 10 f0       	mov    $0xf010656a,%eax
f01051bc:	c1 e8 10             	shr    $0x10,%eax
f01051bf:	66 a3 76 62 24 f0    	mov    %ax,0xf0246276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01051c5:	b8 70 65 10 f0       	mov    $0xf0106570,%eax
f01051ca:	66 a3 78 62 24 f0    	mov    %ax,0xf0246278
f01051d0:	66 c7 05 7a 62 24 f0 	movw   $0x8,0xf024627a
f01051d7:	08 00 
f01051d9:	0f b6 05 7c 62 24 f0 	movzbl 0xf024627c,%eax
f01051e0:	83 e0 e0             	and    $0xffffffe0,%eax
f01051e3:	a2 7c 62 24 f0       	mov    %al,0xf024627c
f01051e8:	0f b6 05 7c 62 24 f0 	movzbl 0xf024627c,%eax
f01051ef:	83 e0 1f             	and    $0x1f,%eax
f01051f2:	a2 7c 62 24 f0       	mov    %al,0xf024627c
f01051f7:	0f b6 05 7d 62 24 f0 	movzbl 0xf024627d,%eax
f01051fe:	83 e0 f0             	and    $0xfffffff0,%eax
f0105201:	83 c8 0e             	or     $0xe,%eax
f0105204:	a2 7d 62 24 f0       	mov    %al,0xf024627d
f0105209:	0f b6 05 7d 62 24 f0 	movzbl 0xf024627d,%eax
f0105210:	83 e0 ef             	and    $0xffffffef,%eax
f0105213:	a2 7d 62 24 f0       	mov    %al,0xf024627d
f0105218:	0f b6 05 7d 62 24 f0 	movzbl 0xf024627d,%eax
f010521f:	83 c8 60             	or     $0x60,%eax
f0105222:	a2 7d 62 24 f0       	mov    %al,0xf024627d
f0105227:	0f b6 05 7d 62 24 f0 	movzbl 0xf024627d,%eax
f010522e:	83 c8 80             	or     $0xffffff80,%eax
f0105231:	a2 7d 62 24 f0       	mov    %al,0xf024627d
f0105236:	b8 70 65 10 f0       	mov    $0xf0106570,%eax
f010523b:	c1 e8 10             	shr    $0x10,%eax
f010523e:	66 a3 7e 62 24 f0    	mov    %ax,0xf024627e
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0105244:	b8 76 65 10 f0       	mov    $0xf0106576,%eax
f0105249:	66 a3 88 62 24 f0    	mov    %ax,0xf0246288
f010524f:	66 c7 05 8a 62 24 f0 	movw   $0x8,0xf024628a
f0105256:	08 00 
f0105258:	0f b6 05 8c 62 24 f0 	movzbl 0xf024628c,%eax
f010525f:	83 e0 e0             	and    $0xffffffe0,%eax
f0105262:	a2 8c 62 24 f0       	mov    %al,0xf024628c
f0105267:	0f b6 05 8c 62 24 f0 	movzbl 0xf024628c,%eax
f010526e:	83 e0 1f             	and    $0x1f,%eax
f0105271:	a2 8c 62 24 f0       	mov    %al,0xf024628c
f0105276:	0f b6 05 8d 62 24 f0 	movzbl 0xf024628d,%eax
f010527d:	83 e0 f0             	and    $0xfffffff0,%eax
f0105280:	83 c8 0e             	or     $0xe,%eax
f0105283:	a2 8d 62 24 f0       	mov    %al,0xf024628d
f0105288:	0f b6 05 8d 62 24 f0 	movzbl 0xf024628d,%eax
f010528f:	83 e0 ef             	and    $0xffffffef,%eax
f0105292:	a2 8d 62 24 f0       	mov    %al,0xf024628d
f0105297:	0f b6 05 8d 62 24 f0 	movzbl 0xf024628d,%eax
f010529e:	83 e0 9f             	and    $0xffffff9f,%eax
f01052a1:	a2 8d 62 24 f0       	mov    %al,0xf024628d
f01052a6:	0f b6 05 8d 62 24 f0 	movzbl 0xf024628d,%eax
f01052ad:	83 c8 80             	or     $0xffffff80,%eax
f01052b0:	a2 8d 62 24 f0       	mov    %al,0xf024628d
f01052b5:	b8 76 65 10 f0       	mov    $0xf0106576,%eax
f01052ba:	c1 e8 10             	shr    $0x10,%eax
f01052bd:	66 a3 8e 62 24 f0    	mov    %ax,0xf024628e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01052c3:	b8 7c 65 10 f0       	mov    $0xf010657c,%eax
f01052c8:	66 a3 90 62 24 f0    	mov    %ax,0xf0246290
f01052ce:	66 c7 05 92 62 24 f0 	movw   $0x8,0xf0246292
f01052d5:	08 00 
f01052d7:	0f b6 05 94 62 24 f0 	movzbl 0xf0246294,%eax
f01052de:	83 e0 e0             	and    $0xffffffe0,%eax
f01052e1:	a2 94 62 24 f0       	mov    %al,0xf0246294
f01052e6:	0f b6 05 94 62 24 f0 	movzbl 0xf0246294,%eax
f01052ed:	83 e0 1f             	and    $0x1f,%eax
f01052f0:	a2 94 62 24 f0       	mov    %al,0xf0246294
f01052f5:	0f b6 05 95 62 24 f0 	movzbl 0xf0246295,%eax
f01052fc:	83 e0 f0             	and    $0xfffffff0,%eax
f01052ff:	83 c8 0e             	or     $0xe,%eax
f0105302:	a2 95 62 24 f0       	mov    %al,0xf0246295
f0105307:	0f b6 05 95 62 24 f0 	movzbl 0xf0246295,%eax
f010530e:	83 e0 ef             	and    $0xffffffef,%eax
f0105311:	a2 95 62 24 f0       	mov    %al,0xf0246295
f0105316:	0f b6 05 95 62 24 f0 	movzbl 0xf0246295,%eax
f010531d:	83 e0 9f             	and    $0xffffff9f,%eax
f0105320:	a2 95 62 24 f0       	mov    %al,0xf0246295
f0105325:	0f b6 05 95 62 24 f0 	movzbl 0xf0246295,%eax
f010532c:	83 c8 80             	or     $0xffffff80,%eax
f010532f:	a2 95 62 24 f0       	mov    %al,0xf0246295
f0105334:	b8 7c 65 10 f0       	mov    $0xf010657c,%eax
f0105339:	c1 e8 10             	shr    $0x10,%eax
f010533c:	66 a3 96 62 24 f0    	mov    %ax,0xf0246296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0105342:	b8 82 65 10 f0       	mov    $0xf0106582,%eax
f0105347:	66 a3 98 62 24 f0    	mov    %ax,0xf0246298
f010534d:	66 c7 05 9a 62 24 f0 	movw   $0x8,0xf024629a
f0105354:	08 00 
f0105356:	0f b6 05 9c 62 24 f0 	movzbl 0xf024629c,%eax
f010535d:	83 e0 e0             	and    $0xffffffe0,%eax
f0105360:	a2 9c 62 24 f0       	mov    %al,0xf024629c
f0105365:	0f b6 05 9c 62 24 f0 	movzbl 0xf024629c,%eax
f010536c:	83 e0 1f             	and    $0x1f,%eax
f010536f:	a2 9c 62 24 f0       	mov    %al,0xf024629c
f0105374:	0f b6 05 9d 62 24 f0 	movzbl 0xf024629d,%eax
f010537b:	83 e0 f0             	and    $0xfffffff0,%eax
f010537e:	83 c8 0e             	or     $0xe,%eax
f0105381:	a2 9d 62 24 f0       	mov    %al,0xf024629d
f0105386:	0f b6 05 9d 62 24 f0 	movzbl 0xf024629d,%eax
f010538d:	83 e0 ef             	and    $0xffffffef,%eax
f0105390:	a2 9d 62 24 f0       	mov    %al,0xf024629d
f0105395:	0f b6 05 9d 62 24 f0 	movzbl 0xf024629d,%eax
f010539c:	83 e0 9f             	and    $0xffffff9f,%eax
f010539f:	a2 9d 62 24 f0       	mov    %al,0xf024629d
f01053a4:	0f b6 05 9d 62 24 f0 	movzbl 0xf024629d,%eax
f01053ab:	83 c8 80             	or     $0xffffff80,%eax
f01053ae:	a2 9d 62 24 f0       	mov    %al,0xf024629d
f01053b3:	b8 82 65 10 f0       	mov    $0xf0106582,%eax
f01053b8:	c1 e8 10             	shr    $0x10,%eax
f01053bb:	66 a3 9e 62 24 f0    	mov    %ax,0xf024629e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01053c1:	b8 88 65 10 f0       	mov    $0xf0106588,%eax
f01053c6:	66 a3 a0 62 24 f0    	mov    %ax,0xf02462a0
f01053cc:	66 c7 05 a2 62 24 f0 	movw   $0x8,0xf02462a2
f01053d3:	08 00 
f01053d5:	0f b6 05 a4 62 24 f0 	movzbl 0xf02462a4,%eax
f01053dc:	83 e0 e0             	and    $0xffffffe0,%eax
f01053df:	a2 a4 62 24 f0       	mov    %al,0xf02462a4
f01053e4:	0f b6 05 a4 62 24 f0 	movzbl 0xf02462a4,%eax
f01053eb:	83 e0 1f             	and    $0x1f,%eax
f01053ee:	a2 a4 62 24 f0       	mov    %al,0xf02462a4
f01053f3:	0f b6 05 a5 62 24 f0 	movzbl 0xf02462a5,%eax
f01053fa:	83 e0 f0             	and    $0xfffffff0,%eax
f01053fd:	83 c8 0e             	or     $0xe,%eax
f0105400:	a2 a5 62 24 f0       	mov    %al,0xf02462a5
f0105405:	0f b6 05 a5 62 24 f0 	movzbl 0xf02462a5,%eax
f010540c:	83 e0 ef             	and    $0xffffffef,%eax
f010540f:	a2 a5 62 24 f0       	mov    %al,0xf02462a5
f0105414:	0f b6 05 a5 62 24 f0 	movzbl 0xf02462a5,%eax
f010541b:	83 e0 9f             	and    $0xffffff9f,%eax
f010541e:	a2 a5 62 24 f0       	mov    %al,0xf02462a5
f0105423:	0f b6 05 a5 62 24 f0 	movzbl 0xf02462a5,%eax
f010542a:	83 c8 80             	or     $0xffffff80,%eax
f010542d:	a2 a5 62 24 f0       	mov    %al,0xf02462a5
f0105432:	b8 88 65 10 f0       	mov    $0xf0106588,%eax
f0105437:	c1 e8 10             	shr    $0x10,%eax
f010543a:	66 a3 a6 62 24 f0    	mov    %ax,0xf02462a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0105440:	b8 8c 65 10 f0       	mov    $0xf010658c,%eax
f0105445:	66 a3 b0 62 24 f0    	mov    %ax,0xf02462b0
f010544b:	66 c7 05 b2 62 24 f0 	movw   $0x8,0xf02462b2
f0105452:	08 00 
f0105454:	0f b6 05 b4 62 24 f0 	movzbl 0xf02462b4,%eax
f010545b:	83 e0 e0             	and    $0xffffffe0,%eax
f010545e:	a2 b4 62 24 f0       	mov    %al,0xf02462b4
f0105463:	0f b6 05 b4 62 24 f0 	movzbl 0xf02462b4,%eax
f010546a:	83 e0 1f             	and    $0x1f,%eax
f010546d:	a2 b4 62 24 f0       	mov    %al,0xf02462b4
f0105472:	0f b6 05 b5 62 24 f0 	movzbl 0xf02462b5,%eax
f0105479:	83 e0 f0             	and    $0xfffffff0,%eax
f010547c:	83 c8 0e             	or     $0xe,%eax
f010547f:	a2 b5 62 24 f0       	mov    %al,0xf02462b5
f0105484:	0f b6 05 b5 62 24 f0 	movzbl 0xf02462b5,%eax
f010548b:	83 e0 ef             	and    $0xffffffef,%eax
f010548e:	a2 b5 62 24 f0       	mov    %al,0xf02462b5
f0105493:	0f b6 05 b5 62 24 f0 	movzbl 0xf02462b5,%eax
f010549a:	83 e0 9f             	and    $0xffffff9f,%eax
f010549d:	a2 b5 62 24 f0       	mov    %al,0xf02462b5
f01054a2:	0f b6 05 b5 62 24 f0 	movzbl 0xf02462b5,%eax
f01054a9:	83 c8 80             	or     $0xffffff80,%eax
f01054ac:	a2 b5 62 24 f0       	mov    %al,0xf02462b5
f01054b1:	b8 8c 65 10 f0       	mov    $0xf010658c,%eax
f01054b6:	c1 e8 10             	shr    $0x10,%eax
f01054b9:	66 a3 b6 62 24 f0    	mov    %ax,0xf02462b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01054bf:	b8 90 65 10 f0       	mov    $0xf0106590,%eax
f01054c4:	66 a3 b8 62 24 f0    	mov    %ax,0xf02462b8
f01054ca:	66 c7 05 ba 62 24 f0 	movw   $0x8,0xf02462ba
f01054d1:	08 00 
f01054d3:	0f b6 05 bc 62 24 f0 	movzbl 0xf02462bc,%eax
f01054da:	83 e0 e0             	and    $0xffffffe0,%eax
f01054dd:	a2 bc 62 24 f0       	mov    %al,0xf02462bc
f01054e2:	0f b6 05 bc 62 24 f0 	movzbl 0xf02462bc,%eax
f01054e9:	83 e0 1f             	and    $0x1f,%eax
f01054ec:	a2 bc 62 24 f0       	mov    %al,0xf02462bc
f01054f1:	0f b6 05 bd 62 24 f0 	movzbl 0xf02462bd,%eax
f01054f8:	83 e0 f0             	and    $0xfffffff0,%eax
f01054fb:	83 c8 0e             	or     $0xe,%eax
f01054fe:	a2 bd 62 24 f0       	mov    %al,0xf02462bd
f0105503:	0f b6 05 bd 62 24 f0 	movzbl 0xf02462bd,%eax
f010550a:	83 e0 ef             	and    $0xffffffef,%eax
f010550d:	a2 bd 62 24 f0       	mov    %al,0xf02462bd
f0105512:	0f b6 05 bd 62 24 f0 	movzbl 0xf02462bd,%eax
f0105519:	83 e0 9f             	and    $0xffffff9f,%eax
f010551c:	a2 bd 62 24 f0       	mov    %al,0xf02462bd
f0105521:	0f b6 05 bd 62 24 f0 	movzbl 0xf02462bd,%eax
f0105528:	83 c8 80             	or     $0xffffff80,%eax
f010552b:	a2 bd 62 24 f0       	mov    %al,0xf02462bd
f0105530:	b8 90 65 10 f0       	mov    $0xf0106590,%eax
f0105535:	c1 e8 10             	shr    $0x10,%eax
f0105538:	66 a3 be 62 24 f0    	mov    %ax,0xf02462be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010553e:	b8 94 65 10 f0       	mov    $0xf0106594,%eax
f0105543:	66 a3 c0 62 24 f0    	mov    %ax,0xf02462c0
f0105549:	66 c7 05 c2 62 24 f0 	movw   $0x8,0xf02462c2
f0105550:	08 00 
f0105552:	0f b6 05 c4 62 24 f0 	movzbl 0xf02462c4,%eax
f0105559:	83 e0 e0             	and    $0xffffffe0,%eax
f010555c:	a2 c4 62 24 f0       	mov    %al,0xf02462c4
f0105561:	0f b6 05 c4 62 24 f0 	movzbl 0xf02462c4,%eax
f0105568:	83 e0 1f             	and    $0x1f,%eax
f010556b:	a2 c4 62 24 f0       	mov    %al,0xf02462c4
f0105570:	0f b6 05 c5 62 24 f0 	movzbl 0xf02462c5,%eax
f0105577:	83 e0 f0             	and    $0xfffffff0,%eax
f010557a:	83 c8 0e             	or     $0xe,%eax
f010557d:	a2 c5 62 24 f0       	mov    %al,0xf02462c5
f0105582:	0f b6 05 c5 62 24 f0 	movzbl 0xf02462c5,%eax
f0105589:	83 e0 ef             	and    $0xffffffef,%eax
f010558c:	a2 c5 62 24 f0       	mov    %al,0xf02462c5
f0105591:	0f b6 05 c5 62 24 f0 	movzbl 0xf02462c5,%eax
f0105598:	83 e0 9f             	and    $0xffffff9f,%eax
f010559b:	a2 c5 62 24 f0       	mov    %al,0xf02462c5
f01055a0:	0f b6 05 c5 62 24 f0 	movzbl 0xf02462c5,%eax
f01055a7:	83 c8 80             	or     $0xffffff80,%eax
f01055aa:	a2 c5 62 24 f0       	mov    %al,0xf02462c5
f01055af:	b8 94 65 10 f0       	mov    $0xf0106594,%eax
f01055b4:	c1 e8 10             	shr    $0x10,%eax
f01055b7:	66 a3 c6 62 24 f0    	mov    %ax,0xf02462c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01055bd:	b8 98 65 10 f0       	mov    $0xf0106598,%eax
f01055c2:	66 a3 c8 62 24 f0    	mov    %ax,0xf02462c8
f01055c8:	66 c7 05 ca 62 24 f0 	movw   $0x8,0xf02462ca
f01055cf:	08 00 
f01055d1:	0f b6 05 cc 62 24 f0 	movzbl 0xf02462cc,%eax
f01055d8:	83 e0 e0             	and    $0xffffffe0,%eax
f01055db:	a2 cc 62 24 f0       	mov    %al,0xf02462cc
f01055e0:	0f b6 05 cc 62 24 f0 	movzbl 0xf02462cc,%eax
f01055e7:	83 e0 1f             	and    $0x1f,%eax
f01055ea:	a2 cc 62 24 f0       	mov    %al,0xf02462cc
f01055ef:	0f b6 05 cd 62 24 f0 	movzbl 0xf02462cd,%eax
f01055f6:	83 e0 f0             	and    $0xfffffff0,%eax
f01055f9:	83 c8 0e             	or     $0xe,%eax
f01055fc:	a2 cd 62 24 f0       	mov    %al,0xf02462cd
f0105601:	0f b6 05 cd 62 24 f0 	movzbl 0xf02462cd,%eax
f0105608:	83 e0 ef             	and    $0xffffffef,%eax
f010560b:	a2 cd 62 24 f0       	mov    %al,0xf02462cd
f0105610:	0f b6 05 cd 62 24 f0 	movzbl 0xf02462cd,%eax
f0105617:	83 e0 9f             	and    $0xffffff9f,%eax
f010561a:	a2 cd 62 24 f0       	mov    %al,0xf02462cd
f010561f:	0f b6 05 cd 62 24 f0 	movzbl 0xf02462cd,%eax
f0105626:	83 c8 80             	or     $0xffffff80,%eax
f0105629:	a2 cd 62 24 f0       	mov    %al,0xf02462cd
f010562e:	b8 98 65 10 f0       	mov    $0xf0106598,%eax
f0105633:	c1 e8 10             	shr    $0x10,%eax
f0105636:	66 a3 ce 62 24 f0    	mov    %ax,0xf02462ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f010563c:	b8 9c 65 10 f0       	mov    $0xf010659c,%eax
f0105641:	66 a3 d0 62 24 f0    	mov    %ax,0xf02462d0
f0105647:	66 c7 05 d2 62 24 f0 	movw   $0x8,0xf02462d2
f010564e:	08 00 
f0105650:	0f b6 05 d4 62 24 f0 	movzbl 0xf02462d4,%eax
f0105657:	83 e0 e0             	and    $0xffffffe0,%eax
f010565a:	a2 d4 62 24 f0       	mov    %al,0xf02462d4
f010565f:	0f b6 05 d4 62 24 f0 	movzbl 0xf02462d4,%eax
f0105666:	83 e0 1f             	and    $0x1f,%eax
f0105669:	a2 d4 62 24 f0       	mov    %al,0xf02462d4
f010566e:	0f b6 05 d5 62 24 f0 	movzbl 0xf02462d5,%eax
f0105675:	83 e0 f0             	and    $0xfffffff0,%eax
f0105678:	83 c8 0e             	or     $0xe,%eax
f010567b:	a2 d5 62 24 f0       	mov    %al,0xf02462d5
f0105680:	0f b6 05 d5 62 24 f0 	movzbl 0xf02462d5,%eax
f0105687:	83 e0 ef             	and    $0xffffffef,%eax
f010568a:	a2 d5 62 24 f0       	mov    %al,0xf02462d5
f010568f:	0f b6 05 d5 62 24 f0 	movzbl 0xf02462d5,%eax
f0105696:	83 e0 9f             	and    $0xffffff9f,%eax
f0105699:	a2 d5 62 24 f0       	mov    %al,0xf02462d5
f010569e:	0f b6 05 d5 62 24 f0 	movzbl 0xf02462d5,%eax
f01056a5:	83 c8 80             	or     $0xffffff80,%eax
f01056a8:	a2 d5 62 24 f0       	mov    %al,0xf02462d5
f01056ad:	b8 9c 65 10 f0       	mov    $0xf010659c,%eax
f01056b2:	c1 e8 10             	shr    $0x10,%eax
f01056b5:	66 a3 d6 62 24 f0    	mov    %ax,0xf02462d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01056bb:	b8 a0 65 10 f0       	mov    $0xf01065a0,%eax
f01056c0:	66 a3 e0 62 24 f0    	mov    %ax,0xf02462e0
f01056c6:	66 c7 05 e2 62 24 f0 	movw   $0x8,0xf02462e2
f01056cd:	08 00 
f01056cf:	0f b6 05 e4 62 24 f0 	movzbl 0xf02462e4,%eax
f01056d6:	83 e0 e0             	and    $0xffffffe0,%eax
f01056d9:	a2 e4 62 24 f0       	mov    %al,0xf02462e4
f01056de:	0f b6 05 e4 62 24 f0 	movzbl 0xf02462e4,%eax
f01056e5:	83 e0 1f             	and    $0x1f,%eax
f01056e8:	a2 e4 62 24 f0       	mov    %al,0xf02462e4
f01056ed:	0f b6 05 e5 62 24 f0 	movzbl 0xf02462e5,%eax
f01056f4:	83 e0 f0             	and    $0xfffffff0,%eax
f01056f7:	83 c8 0e             	or     $0xe,%eax
f01056fa:	a2 e5 62 24 f0       	mov    %al,0xf02462e5
f01056ff:	0f b6 05 e5 62 24 f0 	movzbl 0xf02462e5,%eax
f0105706:	83 e0 ef             	and    $0xffffffef,%eax
f0105709:	a2 e5 62 24 f0       	mov    %al,0xf02462e5
f010570e:	0f b6 05 e5 62 24 f0 	movzbl 0xf02462e5,%eax
f0105715:	83 e0 9f             	and    $0xffffff9f,%eax
f0105718:	a2 e5 62 24 f0       	mov    %al,0xf02462e5
f010571d:	0f b6 05 e5 62 24 f0 	movzbl 0xf02462e5,%eax
f0105724:	83 c8 80             	or     $0xffffff80,%eax
f0105727:	a2 e5 62 24 f0       	mov    %al,0xf02462e5
f010572c:	b8 a0 65 10 f0       	mov    $0xf01065a0,%eax
f0105731:	c1 e8 10             	shr    $0x10,%eax
f0105734:	66 a3 e6 62 24 f0    	mov    %ax,0xf02462e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f010573a:	b8 a6 65 10 f0       	mov    $0xf01065a6,%eax
f010573f:	66 a3 e8 62 24 f0    	mov    %ax,0xf02462e8
f0105745:	66 c7 05 ea 62 24 f0 	movw   $0x8,0xf02462ea
f010574c:	08 00 
f010574e:	0f b6 05 ec 62 24 f0 	movzbl 0xf02462ec,%eax
f0105755:	83 e0 e0             	and    $0xffffffe0,%eax
f0105758:	a2 ec 62 24 f0       	mov    %al,0xf02462ec
f010575d:	0f b6 05 ec 62 24 f0 	movzbl 0xf02462ec,%eax
f0105764:	83 e0 1f             	and    $0x1f,%eax
f0105767:	a2 ec 62 24 f0       	mov    %al,0xf02462ec
f010576c:	0f b6 05 ed 62 24 f0 	movzbl 0xf02462ed,%eax
f0105773:	83 e0 f0             	and    $0xfffffff0,%eax
f0105776:	83 c8 0e             	or     $0xe,%eax
f0105779:	a2 ed 62 24 f0       	mov    %al,0xf02462ed
f010577e:	0f b6 05 ed 62 24 f0 	movzbl 0xf02462ed,%eax
f0105785:	83 e0 ef             	and    $0xffffffef,%eax
f0105788:	a2 ed 62 24 f0       	mov    %al,0xf02462ed
f010578d:	0f b6 05 ed 62 24 f0 	movzbl 0xf02462ed,%eax
f0105794:	83 e0 9f             	and    $0xffffff9f,%eax
f0105797:	a2 ed 62 24 f0       	mov    %al,0xf02462ed
f010579c:	0f b6 05 ed 62 24 f0 	movzbl 0xf02462ed,%eax
f01057a3:	83 c8 80             	or     $0xffffff80,%eax
f01057a6:	a2 ed 62 24 f0       	mov    %al,0xf02462ed
f01057ab:	b8 a6 65 10 f0       	mov    $0xf01065a6,%eax
f01057b0:	c1 e8 10             	shr    $0x10,%eax
f01057b3:	66 a3 ee 62 24 f0    	mov    %ax,0xf02462ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f01057b9:	b8 aa 65 10 f0       	mov    $0xf01065aa,%eax
f01057be:	66 a3 f0 62 24 f0    	mov    %ax,0xf02462f0
f01057c4:	66 c7 05 f2 62 24 f0 	movw   $0x8,0xf02462f2
f01057cb:	08 00 
f01057cd:	0f b6 05 f4 62 24 f0 	movzbl 0xf02462f4,%eax
f01057d4:	83 e0 e0             	and    $0xffffffe0,%eax
f01057d7:	a2 f4 62 24 f0       	mov    %al,0xf02462f4
f01057dc:	0f b6 05 f4 62 24 f0 	movzbl 0xf02462f4,%eax
f01057e3:	83 e0 1f             	and    $0x1f,%eax
f01057e6:	a2 f4 62 24 f0       	mov    %al,0xf02462f4
f01057eb:	0f b6 05 f5 62 24 f0 	movzbl 0xf02462f5,%eax
f01057f2:	83 e0 f0             	and    $0xfffffff0,%eax
f01057f5:	83 c8 0e             	or     $0xe,%eax
f01057f8:	a2 f5 62 24 f0       	mov    %al,0xf02462f5
f01057fd:	0f b6 05 f5 62 24 f0 	movzbl 0xf02462f5,%eax
f0105804:	83 e0 ef             	and    $0xffffffef,%eax
f0105807:	a2 f5 62 24 f0       	mov    %al,0xf02462f5
f010580c:	0f b6 05 f5 62 24 f0 	movzbl 0xf02462f5,%eax
f0105813:	83 e0 9f             	and    $0xffffff9f,%eax
f0105816:	a2 f5 62 24 f0       	mov    %al,0xf02462f5
f010581b:	0f b6 05 f5 62 24 f0 	movzbl 0xf02462f5,%eax
f0105822:	83 c8 80             	or     $0xffffff80,%eax
f0105825:	a2 f5 62 24 f0       	mov    %al,0xf02462f5
f010582a:	b8 aa 65 10 f0       	mov    $0xf01065aa,%eax
f010582f:	c1 e8 10             	shr    $0x10,%eax
f0105832:	66 a3 f6 62 24 f0    	mov    %ax,0xf02462f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0105838:	b8 b0 65 10 f0       	mov    $0xf01065b0,%eax
f010583d:	66 a3 f8 62 24 f0    	mov    %ax,0xf02462f8
f0105843:	66 c7 05 fa 62 24 f0 	movw   $0x8,0xf02462fa
f010584a:	08 00 
f010584c:	0f b6 05 fc 62 24 f0 	movzbl 0xf02462fc,%eax
f0105853:	83 e0 e0             	and    $0xffffffe0,%eax
f0105856:	a2 fc 62 24 f0       	mov    %al,0xf02462fc
f010585b:	0f b6 05 fc 62 24 f0 	movzbl 0xf02462fc,%eax
f0105862:	83 e0 1f             	and    $0x1f,%eax
f0105865:	a2 fc 62 24 f0       	mov    %al,0xf02462fc
f010586a:	0f b6 05 fd 62 24 f0 	movzbl 0xf02462fd,%eax
f0105871:	83 e0 f0             	and    $0xfffffff0,%eax
f0105874:	83 c8 0e             	or     $0xe,%eax
f0105877:	a2 fd 62 24 f0       	mov    %al,0xf02462fd
f010587c:	0f b6 05 fd 62 24 f0 	movzbl 0xf02462fd,%eax
f0105883:	83 e0 ef             	and    $0xffffffef,%eax
f0105886:	a2 fd 62 24 f0       	mov    %al,0xf02462fd
f010588b:	0f b6 05 fd 62 24 f0 	movzbl 0xf02462fd,%eax
f0105892:	83 e0 9f             	and    $0xffffff9f,%eax
f0105895:	a2 fd 62 24 f0       	mov    %al,0xf02462fd
f010589a:	0f b6 05 fd 62 24 f0 	movzbl 0xf02462fd,%eax
f01058a1:	83 c8 80             	or     $0xffffff80,%eax
f01058a4:	a2 fd 62 24 f0       	mov    %al,0xf02462fd
f01058a9:	b8 b0 65 10 f0       	mov    $0xf01065b0,%eax
f01058ae:	c1 e8 10             	shr    $0x10,%eax
f01058b1:	66 a3 fe 62 24 f0    	mov    %ax,0xf02462fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01058b7:	b8 b6 65 10 f0       	mov    $0xf01065b6,%eax
f01058bc:	66 a3 e0 63 24 f0    	mov    %ax,0xf02463e0
f01058c2:	66 c7 05 e2 63 24 f0 	movw   $0x8,0xf02463e2
f01058c9:	08 00 
f01058cb:	0f b6 05 e4 63 24 f0 	movzbl 0xf02463e4,%eax
f01058d2:	83 e0 e0             	and    $0xffffffe0,%eax
f01058d5:	a2 e4 63 24 f0       	mov    %al,0xf02463e4
f01058da:	0f b6 05 e4 63 24 f0 	movzbl 0xf02463e4,%eax
f01058e1:	83 e0 1f             	and    $0x1f,%eax
f01058e4:	a2 e4 63 24 f0       	mov    %al,0xf02463e4
f01058e9:	0f b6 05 e5 63 24 f0 	movzbl 0xf02463e5,%eax
f01058f0:	83 e0 f0             	and    $0xfffffff0,%eax
f01058f3:	83 c8 0e             	or     $0xe,%eax
f01058f6:	a2 e5 63 24 f0       	mov    %al,0xf02463e5
f01058fb:	0f b6 05 e5 63 24 f0 	movzbl 0xf02463e5,%eax
f0105902:	83 e0 ef             	and    $0xffffffef,%eax
f0105905:	a2 e5 63 24 f0       	mov    %al,0xf02463e5
f010590a:	0f b6 05 e5 63 24 f0 	movzbl 0xf02463e5,%eax
f0105911:	83 c8 60             	or     $0x60,%eax
f0105914:	a2 e5 63 24 f0       	mov    %al,0xf02463e5
f0105919:	0f b6 05 e5 63 24 f0 	movzbl 0xf02463e5,%eax
f0105920:	83 c8 80             	or     $0xffffff80,%eax
f0105923:	a2 e5 63 24 f0       	mov    %al,0xf02463e5
f0105928:	b8 b6 65 10 f0       	mov    $0xf01065b6,%eax
f010592d:	c1 e8 10             	shr    $0x10,%eax
f0105930:	66 a3 e6 63 24 f0    	mov    %ax,0xf02463e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f0105936:	b8 bc 65 10 f0       	mov    $0xf01065bc,%eax
f010593b:	66 a3 60 63 24 f0    	mov    %ax,0xf0246360
f0105941:	66 c7 05 62 63 24 f0 	movw   $0x8,0xf0246362
f0105948:	08 00 
f010594a:	0f b6 05 64 63 24 f0 	movzbl 0xf0246364,%eax
f0105951:	83 e0 e0             	and    $0xffffffe0,%eax
f0105954:	a2 64 63 24 f0       	mov    %al,0xf0246364
f0105959:	0f b6 05 64 63 24 f0 	movzbl 0xf0246364,%eax
f0105960:	83 e0 1f             	and    $0x1f,%eax
f0105963:	a2 64 63 24 f0       	mov    %al,0xf0246364
f0105968:	0f b6 05 65 63 24 f0 	movzbl 0xf0246365,%eax
f010596f:	83 e0 f0             	and    $0xfffffff0,%eax
f0105972:	83 c8 0e             	or     $0xe,%eax
f0105975:	a2 65 63 24 f0       	mov    %al,0xf0246365
f010597a:	0f b6 05 65 63 24 f0 	movzbl 0xf0246365,%eax
f0105981:	83 e0 ef             	and    $0xffffffef,%eax
f0105984:	a2 65 63 24 f0       	mov    %al,0xf0246365
f0105989:	0f b6 05 65 63 24 f0 	movzbl 0xf0246365,%eax
f0105990:	83 e0 9f             	and    $0xffffff9f,%eax
f0105993:	a2 65 63 24 f0       	mov    %al,0xf0246365
f0105998:	0f b6 05 65 63 24 f0 	movzbl 0xf0246365,%eax
f010599f:	83 c8 80             	or     $0xffffff80,%eax
f01059a2:	a2 65 63 24 f0       	mov    %al,0xf0246365
f01059a7:	b8 bc 65 10 f0       	mov    $0xf01065bc,%eax
f01059ac:	c1 e8 10             	shr    $0x10,%eax
f01059af:	66 a3 66 63 24 f0    	mov    %ax,0xf0246366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f01059b5:	b8 c2 65 10 f0       	mov    $0xf01065c2,%eax
f01059ba:	66 a3 68 63 24 f0    	mov    %ax,0xf0246368
f01059c0:	66 c7 05 6a 63 24 f0 	movw   $0x8,0xf024636a
f01059c7:	08 00 
f01059c9:	0f b6 05 6c 63 24 f0 	movzbl 0xf024636c,%eax
f01059d0:	83 e0 e0             	and    $0xffffffe0,%eax
f01059d3:	a2 6c 63 24 f0       	mov    %al,0xf024636c
f01059d8:	0f b6 05 6c 63 24 f0 	movzbl 0xf024636c,%eax
f01059df:	83 e0 1f             	and    $0x1f,%eax
f01059e2:	a2 6c 63 24 f0       	mov    %al,0xf024636c
f01059e7:	0f b6 05 6d 63 24 f0 	movzbl 0xf024636d,%eax
f01059ee:	83 e0 f0             	and    $0xfffffff0,%eax
f01059f1:	83 c8 0e             	or     $0xe,%eax
f01059f4:	a2 6d 63 24 f0       	mov    %al,0xf024636d
f01059f9:	0f b6 05 6d 63 24 f0 	movzbl 0xf024636d,%eax
f0105a00:	83 e0 ef             	and    $0xffffffef,%eax
f0105a03:	a2 6d 63 24 f0       	mov    %al,0xf024636d
f0105a08:	0f b6 05 6d 63 24 f0 	movzbl 0xf024636d,%eax
f0105a0f:	83 e0 9f             	and    $0xffffff9f,%eax
f0105a12:	a2 6d 63 24 f0       	mov    %al,0xf024636d
f0105a17:	0f b6 05 6d 63 24 f0 	movzbl 0xf024636d,%eax
f0105a1e:	83 c8 80             	or     $0xffffff80,%eax
f0105a21:	a2 6d 63 24 f0       	mov    %al,0xf024636d
f0105a26:	b8 c2 65 10 f0       	mov    $0xf01065c2,%eax
f0105a2b:	c1 e8 10             	shr    $0x10,%eax
f0105a2e:	66 a3 6e 63 24 f0    	mov    %ax,0xf024636e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f0105a34:	b8 c8 65 10 f0       	mov    $0xf01065c8,%eax
f0105a39:	66 a3 80 63 24 f0    	mov    %ax,0xf0246380
f0105a3f:	66 c7 05 82 63 24 f0 	movw   $0x8,0xf0246382
f0105a46:	08 00 
f0105a48:	0f b6 05 84 63 24 f0 	movzbl 0xf0246384,%eax
f0105a4f:	83 e0 e0             	and    $0xffffffe0,%eax
f0105a52:	a2 84 63 24 f0       	mov    %al,0xf0246384
f0105a57:	0f b6 05 84 63 24 f0 	movzbl 0xf0246384,%eax
f0105a5e:	83 e0 1f             	and    $0x1f,%eax
f0105a61:	a2 84 63 24 f0       	mov    %al,0xf0246384
f0105a66:	0f b6 05 85 63 24 f0 	movzbl 0xf0246385,%eax
f0105a6d:	83 e0 f0             	and    $0xfffffff0,%eax
f0105a70:	83 c8 0e             	or     $0xe,%eax
f0105a73:	a2 85 63 24 f0       	mov    %al,0xf0246385
f0105a78:	0f b6 05 85 63 24 f0 	movzbl 0xf0246385,%eax
f0105a7f:	83 e0 ef             	and    $0xffffffef,%eax
f0105a82:	a2 85 63 24 f0       	mov    %al,0xf0246385
f0105a87:	0f b6 05 85 63 24 f0 	movzbl 0xf0246385,%eax
f0105a8e:	83 e0 9f             	and    $0xffffff9f,%eax
f0105a91:	a2 85 63 24 f0       	mov    %al,0xf0246385
f0105a96:	0f b6 05 85 63 24 f0 	movzbl 0xf0246385,%eax
f0105a9d:	83 c8 80             	or     $0xffffff80,%eax
f0105aa0:	a2 85 63 24 f0       	mov    %al,0xf0246385
f0105aa5:	b8 c8 65 10 f0       	mov    $0xf01065c8,%eax
f0105aaa:	c1 e8 10             	shr    $0x10,%eax
f0105aad:	66 a3 86 63 24 f0    	mov    %ax,0xf0246386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f0105ab3:	b8 ce 65 10 f0       	mov    $0xf01065ce,%eax
f0105ab8:	66 a3 98 63 24 f0    	mov    %ax,0xf0246398
f0105abe:	66 c7 05 9a 63 24 f0 	movw   $0x8,0xf024639a
f0105ac5:	08 00 
f0105ac7:	0f b6 05 9c 63 24 f0 	movzbl 0xf024639c,%eax
f0105ace:	83 e0 e0             	and    $0xffffffe0,%eax
f0105ad1:	a2 9c 63 24 f0       	mov    %al,0xf024639c
f0105ad6:	0f b6 05 9c 63 24 f0 	movzbl 0xf024639c,%eax
f0105add:	83 e0 1f             	and    $0x1f,%eax
f0105ae0:	a2 9c 63 24 f0       	mov    %al,0xf024639c
f0105ae5:	0f b6 05 9d 63 24 f0 	movzbl 0xf024639d,%eax
f0105aec:	83 e0 f0             	and    $0xfffffff0,%eax
f0105aef:	83 c8 0e             	or     $0xe,%eax
f0105af2:	a2 9d 63 24 f0       	mov    %al,0xf024639d
f0105af7:	0f b6 05 9d 63 24 f0 	movzbl 0xf024639d,%eax
f0105afe:	83 e0 ef             	and    $0xffffffef,%eax
f0105b01:	a2 9d 63 24 f0       	mov    %al,0xf024639d
f0105b06:	0f b6 05 9d 63 24 f0 	movzbl 0xf024639d,%eax
f0105b0d:	83 e0 9f             	and    $0xffffff9f,%eax
f0105b10:	a2 9d 63 24 f0       	mov    %al,0xf024639d
f0105b15:	0f b6 05 9d 63 24 f0 	movzbl 0xf024639d,%eax
f0105b1c:	83 c8 80             	or     $0xffffff80,%eax
f0105b1f:	a2 9d 63 24 f0       	mov    %al,0xf024639d
f0105b24:	b8 ce 65 10 f0       	mov    $0xf01065ce,%eax
f0105b29:	c1 e8 10             	shr    $0x10,%eax
f0105b2c:	66 a3 9e 63 24 f0    	mov    %ax,0xf024639e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0105b32:	b8 d4 65 10 f0       	mov    $0xf01065d4,%eax
f0105b37:	66 a3 d0 63 24 f0    	mov    %ax,0xf02463d0
f0105b3d:	66 c7 05 d2 63 24 f0 	movw   $0x8,0xf02463d2
f0105b44:	08 00 
f0105b46:	0f b6 05 d4 63 24 f0 	movzbl 0xf02463d4,%eax
f0105b4d:	83 e0 e0             	and    $0xffffffe0,%eax
f0105b50:	a2 d4 63 24 f0       	mov    %al,0xf02463d4
f0105b55:	0f b6 05 d4 63 24 f0 	movzbl 0xf02463d4,%eax
f0105b5c:	83 e0 1f             	and    $0x1f,%eax
f0105b5f:	a2 d4 63 24 f0       	mov    %al,0xf02463d4
f0105b64:	0f b6 05 d5 63 24 f0 	movzbl 0xf02463d5,%eax
f0105b6b:	83 e0 f0             	and    $0xfffffff0,%eax
f0105b6e:	83 c8 0e             	or     $0xe,%eax
f0105b71:	a2 d5 63 24 f0       	mov    %al,0xf02463d5
f0105b76:	0f b6 05 d5 63 24 f0 	movzbl 0xf02463d5,%eax
f0105b7d:	83 e0 ef             	and    $0xffffffef,%eax
f0105b80:	a2 d5 63 24 f0       	mov    %al,0xf02463d5
f0105b85:	0f b6 05 d5 63 24 f0 	movzbl 0xf02463d5,%eax
f0105b8c:	83 e0 9f             	and    $0xffffff9f,%eax
f0105b8f:	a2 d5 63 24 f0       	mov    %al,0xf02463d5
f0105b94:	0f b6 05 d5 63 24 f0 	movzbl 0xf02463d5,%eax
f0105b9b:	83 c8 80             	or     $0xffffff80,%eax
f0105b9e:	a2 d5 63 24 f0       	mov    %al,0xf02463d5
f0105ba3:	b8 d4 65 10 f0       	mov    $0xf01065d4,%eax
f0105ba8:	c1 e8 10             	shr    $0x10,%eax
f0105bab:	66 a3 d6 63 24 f0    	mov    %ax,0xf02463d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0105bb1:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f0105bb6:	66 a3 f8 63 24 f0    	mov    %ax,0xf02463f8
f0105bbc:	66 c7 05 fa 63 24 f0 	movw   $0x8,0xf02463fa
f0105bc3:	08 00 
f0105bc5:	0f b6 05 fc 63 24 f0 	movzbl 0xf02463fc,%eax
f0105bcc:	83 e0 e0             	and    $0xffffffe0,%eax
f0105bcf:	a2 fc 63 24 f0       	mov    %al,0xf02463fc
f0105bd4:	0f b6 05 fc 63 24 f0 	movzbl 0xf02463fc,%eax
f0105bdb:	83 e0 1f             	and    $0x1f,%eax
f0105bde:	a2 fc 63 24 f0       	mov    %al,0xf02463fc
f0105be3:	0f b6 05 fd 63 24 f0 	movzbl 0xf02463fd,%eax
f0105bea:	83 e0 f0             	and    $0xfffffff0,%eax
f0105bed:	83 c8 0e             	or     $0xe,%eax
f0105bf0:	a2 fd 63 24 f0       	mov    %al,0xf02463fd
f0105bf5:	0f b6 05 fd 63 24 f0 	movzbl 0xf02463fd,%eax
f0105bfc:	83 e0 ef             	and    $0xffffffef,%eax
f0105bff:	a2 fd 63 24 f0       	mov    %al,0xf02463fd
f0105c04:	0f b6 05 fd 63 24 f0 	movzbl 0xf02463fd,%eax
f0105c0b:	83 e0 9f             	and    $0xffffff9f,%eax
f0105c0e:	a2 fd 63 24 f0       	mov    %al,0xf02463fd
f0105c13:	0f b6 05 fd 63 24 f0 	movzbl 0xf02463fd,%eax
f0105c1a:	83 c8 80             	or     $0xffffff80,%eax
f0105c1d:	a2 fd 63 24 f0       	mov    %al,0xf02463fd
f0105c22:	b8 da 65 10 f0       	mov    $0xf01065da,%eax
f0105c27:	c1 e8 10             	shr    $0x10,%eax
f0105c2a:	66 a3 fe 63 24 f0    	mov    %ax,0xf02463fe
	// Per-CPU setup 
	trap_init_percpu();
f0105c30:	e8 02 00 00 00       	call   f0105c37 <trap_init_percpu>
}
f0105c35:	c9                   	leave  
f0105c36:	c3                   	ret    

f0105c37 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0105c37:	55                   	push   %ebp
f0105c38:	89 e5                	mov    %esp,%ebp
f0105c3a:	57                   	push   %edi
f0105c3b:	56                   	push   %esi
f0105c3c:	53                   	push   %ebx
f0105c3d:	83 ec 1c             	sub    $0x1c,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - (KSTKSIZE + KSTKGAP)*thiscpu->cpu_id;
f0105c40:	e8 dd 2f 00 00       	call   f0108c22 <cpunum>
f0105c45:	89 c3                	mov    %eax,%ebx
f0105c47:	e8 d6 2f 00 00       	call   f0108c22 <cpunum>
f0105c4c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c4f:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105c54:	0f b6 00             	movzbl (%eax),%eax
f0105c57:	0f b6 d0             	movzbl %al,%edx
f0105c5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c5f:	29 d0                	sub    %edx,%eax
f0105c61:	c1 e0 10             	shl    $0x10,%eax
f0105c64:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0105c6a:	6b c3 74             	imul   $0x74,%ebx,%eax
f0105c6d:	05 30 70 24 f0       	add    $0xf0247030,%eax
f0105c72:	89 10                	mov    %edx,(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0105c74:	e8 a9 2f 00 00       	call   f0108c22 <cpunum>
f0105c79:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c7c:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105c81:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0105c87:	e8 96 2f 00 00       	call   f0108c22 <cpunum>
f0105c8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c8f:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105c94:	0f b6 00             	movzbl (%eax),%eax
f0105c97:	0f b6 c0             	movzbl %al,%eax
f0105c9a:	8d 58 05             	lea    0x5(%eax),%ebx
f0105c9d:	e8 80 2f 00 00       	call   f0108c22 <cpunum>
f0105ca2:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca5:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105caa:	83 c0 0c             	add    $0xc,%eax
f0105cad:	89 c7                	mov    %eax,%edi
f0105caf:	e8 6e 2f 00 00       	call   f0108c22 <cpunum>
f0105cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cb7:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105cbc:	83 c0 0c             	add    $0xc,%eax
f0105cbf:	c1 e8 10             	shr    $0x10,%eax
f0105cc2:	89 c6                	mov    %eax,%esi
f0105cc4:	e8 59 2f 00 00       	call   f0108c22 <cpunum>
f0105cc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ccc:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105cd1:	83 c0 0c             	add    $0xc,%eax
f0105cd4:	c1 e8 18             	shr    $0x18,%eax
f0105cd7:	66 c7 04 dd 60 65 12 	movw   $0x67,-0xfed9aa0(,%ebx,8)
f0105cde:	f0 67 00 
f0105ce1:	66 89 3c dd 62 65 12 	mov    %di,-0xfed9a9e(,%ebx,8)
f0105ce8:	f0 
f0105ce9:	89 f1                	mov    %esi,%ecx
f0105ceb:	88 0c dd 64 65 12 f0 	mov    %cl,-0xfed9a9c(,%ebx,8)
f0105cf2:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105cf9:	f0 
f0105cfa:	83 e2 f0             	and    $0xfffffff0,%edx
f0105cfd:	83 ca 09             	or     $0x9,%edx
f0105d00:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105d07:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105d0e:	f0 
f0105d0f:	83 ca 10             	or     $0x10,%edx
f0105d12:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105d19:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105d20:	f0 
f0105d21:	83 e2 9f             	and    $0xffffff9f,%edx
f0105d24:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105d2b:	0f b6 14 dd 65 65 12 	movzbl -0xfed9a9b(,%ebx,8),%edx
f0105d32:	f0 
f0105d33:	83 ca 80             	or     $0xffffff80,%edx
f0105d36:	88 14 dd 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%ebx,8)
f0105d3d:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d44:	f0 
f0105d45:	83 e2 f0             	and    $0xfffffff0,%edx
f0105d48:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d4f:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d56:	f0 
f0105d57:	83 e2 ef             	and    $0xffffffef,%edx
f0105d5a:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d61:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d68:	f0 
f0105d69:	83 e2 df             	and    $0xffffffdf,%edx
f0105d6c:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d73:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d7a:	f0 
f0105d7b:	83 ca 40             	or     $0x40,%edx
f0105d7e:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d85:	0f b6 14 dd 66 65 12 	movzbl -0xfed9a9a(,%ebx,8),%edx
f0105d8c:	f0 
f0105d8d:	83 e2 7f             	and    $0x7f,%edx
f0105d90:	88 14 dd 66 65 12 f0 	mov    %dl,-0xfed9a9a(,%ebx,8)
f0105d97:	88 04 dd 67 65 12 f0 	mov    %al,-0xfed9a99(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0105d9e:	e8 7f 2e 00 00       	call   f0108c22 <cpunum>
f0105da3:	6b c0 74             	imul   $0x74,%eax,%eax
f0105da6:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105dab:	0f b6 00             	movzbl (%eax),%eax
f0105dae:	0f b6 c0             	movzbl %al,%eax
f0105db1:	83 c0 05             	add    $0x5,%eax
f0105db4:	0f b6 14 c5 65 65 12 	movzbl -0xfed9a9b(,%eax,8),%edx
f0105dbb:	f0 
f0105dbc:	83 e2 ef             	and    $0xffffffef,%edx
f0105dbf:	88 14 c5 65 65 12 f0 	mov    %dl,-0xfed9a9b(,%eax,8)

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(((GD_TSS0 >> 3) + thiscpu->cpu_id) << 3);
f0105dc6:	e8 57 2e 00 00       	call   f0108c22 <cpunum>
f0105dcb:	6b c0 74             	imul   $0x74,%eax,%eax
f0105dce:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0105dd3:	0f b6 00             	movzbl (%eax),%eax
f0105dd6:	0f b6 c0             	movzbl %al,%eax
f0105dd9:	83 c0 05             	add    $0x5,%eax
f0105ddc:	c1 e0 03             	shl    $0x3,%eax
f0105ddf:	0f b7 c0             	movzwl %ax,%eax
f0105de2:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0105de6:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
f0105dea:	0f 00 d8             	ltr    %ax
f0105ded:	c7 45 e0 d0 65 12 f0 	movl   $0xf01265d0,-0x20(%ebp)
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0105df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105df7:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0105dfa:	83 c4 1c             	add    $0x1c,%esp
f0105dfd:	5b                   	pop    %ebx
f0105dfe:	5e                   	pop    %esi
f0105dff:	5f                   	pop    %edi
f0105e00:	5d                   	pop    %ebp
f0105e01:	c3                   	ret    

f0105e02 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f0105e02:	55                   	push   %ebp
f0105e03:	89 e5                	mov    %esp,%ebp
f0105e05:	83 ec 28             	sub    $0x28,%esp
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0105e08:	e8 15 2e 00 00       	call   f0108c22 <cpunum>
f0105e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e11:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e18:	c7 04 24 4e a5 10 f0 	movl   $0xf010a54e,(%esp)
f0105e1f:	e8 8c f1 ff ff       	call   f0104fb0 <cprintf>
	print_regs(&tf->tf_regs);
f0105e24:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e27:	89 04 24             	mov    %eax,(%esp)
f0105e2a:	e8 a5 01 00 00       	call   f0105fd4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0105e2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e32:	0f b7 40 20          	movzwl 0x20(%eax),%eax
f0105e36:	0f b7 c0             	movzwl %ax,%eax
f0105e39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e3d:	c7 04 24 6c a5 10 f0 	movl   $0xf010a56c,(%esp)
f0105e44:	e8 67 f1 ff ff       	call   f0104fb0 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0105e49:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e4c:	0f b7 40 24          	movzwl 0x24(%eax),%eax
f0105e50:	0f b7 c0             	movzwl %ax,%eax
f0105e53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e57:	c7 04 24 7f a5 10 f0 	movl   $0xf010a57f,(%esp)
f0105e5e:	e8 4d f1 ff ff       	call   f0104fb0 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0105e63:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e66:	8b 40 28             	mov    0x28(%eax),%eax
f0105e69:	89 04 24             	mov    %eax,(%esp)
f0105e6c:	e8 93 f1 ff ff       	call   f0105004 <trapname>
f0105e71:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e74:	8b 52 28             	mov    0x28(%edx),%edx
f0105e77:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e7b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e7f:	c7 04 24 92 a5 10 f0 	movl   $0xf010a592,(%esp)
f0105e86:	e8 25 f1 ff ff       	call   f0104fb0 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0105e8b:	a1 c8 6a 24 f0       	mov    0xf0246ac8,%eax
f0105e90:	39 45 08             	cmp    %eax,0x8(%ebp)
f0105e93:	75 24                	jne    f0105eb9 <print_trapframe+0xb7>
f0105e95:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e98:	8b 40 28             	mov    0x28(%eax),%eax
f0105e9b:	83 f8 0e             	cmp    $0xe,%eax
f0105e9e:	75 19                	jne    f0105eb9 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0105ea0:	0f 20 d0             	mov    %cr2,%eax
f0105ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f0105ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0105ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ead:	c7 04 24 a4 a5 10 f0 	movl   $0xf010a5a4,(%esp)
f0105eb4:	e8 f7 f0 ff ff       	call   f0104fb0 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0105eb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ebc:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ec3:	c7 04 24 b3 a5 10 f0 	movl   $0xf010a5b3,(%esp)
f0105eca:	e8 e1 f0 ff ff       	call   f0104fb0 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0105ecf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ed2:	8b 40 28             	mov    0x28(%eax),%eax
f0105ed5:	83 f8 0e             	cmp    $0xe,%eax
f0105ed8:	75 65                	jne    f0105f3f <print_trapframe+0x13d>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0105eda:	8b 45 08             	mov    0x8(%ebp),%eax
f0105edd:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105ee0:	83 e0 01             	and    $0x1,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105ee3:	85 c0                	test   %eax,%eax
f0105ee5:	74 07                	je     f0105eee <print_trapframe+0xec>
f0105ee7:	b9 c1 a5 10 f0       	mov    $0xf010a5c1,%ecx
f0105eec:	eb 05                	jmp    f0105ef3 <print_trapframe+0xf1>
f0105eee:	b9 cc a5 10 f0       	mov    $0xf010a5cc,%ecx
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
f0105ef3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ef6:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105ef9:	83 e0 02             	and    $0x2,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105efc:	85 c0                	test   %eax,%eax
f0105efe:	74 07                	je     f0105f07 <print_trapframe+0x105>
f0105f00:	ba d8 a5 10 f0       	mov    $0xf010a5d8,%edx
f0105f05:	eb 05                	jmp    f0105f0c <print_trapframe+0x10a>
f0105f07:	ba de a5 10 f0       	mov    $0xf010a5de,%edx
			tf->tf_err & 4 ? "user" : "kernel",
f0105f0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f0f:	8b 40 2c             	mov    0x2c(%eax),%eax
f0105f12:	83 e0 04             	and    $0x4,%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0105f15:	85 c0                	test   %eax,%eax
f0105f17:	74 07                	je     f0105f20 <print_trapframe+0x11e>
f0105f19:	b8 e3 a5 10 f0       	mov    $0xf010a5e3,%eax
f0105f1e:	eb 05                	jmp    f0105f25 <print_trapframe+0x123>
f0105f20:	b8 e8 a5 10 f0       	mov    $0xf010a5e8,%eax
f0105f25:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105f29:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f31:	c7 04 24 ef a5 10 f0 	movl   $0xf010a5ef,(%esp)
f0105f38:	e8 73 f0 ff ff       	call   f0104fb0 <cprintf>
f0105f3d:	eb 0c                	jmp    f0105f4b <print_trapframe+0x149>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0105f3f:	c7 04 24 fe a5 10 f0 	movl   $0xf010a5fe,(%esp)
f0105f46:	e8 65 f0 ff ff       	call   f0104fb0 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0105f4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f4e:	8b 40 30             	mov    0x30(%eax),%eax
f0105f51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f55:	c7 04 24 00 a6 10 f0 	movl   $0xf010a600,(%esp)
f0105f5c:	e8 4f f0 ff ff       	call   f0104fb0 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0105f61:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f64:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105f68:	0f b7 c0             	movzwl %ax,%eax
f0105f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f6f:	c7 04 24 0f a6 10 f0 	movl   $0xf010a60f,(%esp)
f0105f76:	e8 35 f0 ff ff       	call   f0104fb0 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0105f7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f7e:	8b 40 38             	mov    0x38(%eax),%eax
f0105f81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f85:	c7 04 24 22 a6 10 f0 	movl   $0xf010a622,(%esp)
f0105f8c:	e8 1f f0 ff ff       	call   f0104fb0 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0105f91:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f94:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0105f98:	0f b7 c0             	movzwl %ax,%eax
f0105f9b:	83 e0 03             	and    $0x3,%eax
f0105f9e:	85 c0                	test   %eax,%eax
f0105fa0:	74 30                	je     f0105fd2 <print_trapframe+0x1d0>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0105fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa5:	8b 40 3c             	mov    0x3c(%eax),%eax
f0105fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fac:	c7 04 24 31 a6 10 f0 	movl   $0xf010a631,(%esp)
f0105fb3:	e8 f8 ef ff ff       	call   f0104fb0 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0105fb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fbb:	0f b7 40 40          	movzwl 0x40(%eax),%eax
f0105fbf:	0f b7 c0             	movzwl %ax,%eax
f0105fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fc6:	c7 04 24 40 a6 10 f0 	movl   $0xf010a640,(%esp)
f0105fcd:	e8 de ef ff ff       	call   f0104fb0 <cprintf>
	}
}
f0105fd2:	c9                   	leave  
f0105fd3:	c3                   	ret    

f0105fd4 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f0105fd4:	55                   	push   %ebp
f0105fd5:	89 e5                	mov    %esp,%ebp
f0105fd7:	83 ec 18             	sub    $0x18,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0105fda:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fdd:	8b 00                	mov    (%eax),%eax
f0105fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fe3:	c7 04 24 53 a6 10 f0 	movl   $0xf010a653,(%esp)
f0105fea:	e8 c1 ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0105fef:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ff2:	8b 40 04             	mov    0x4(%eax),%eax
f0105ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ff9:	c7 04 24 62 a6 10 f0 	movl   $0xf010a662,(%esp)
f0106000:	e8 ab ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0106005:	8b 45 08             	mov    0x8(%ebp),%eax
f0106008:	8b 40 08             	mov    0x8(%eax),%eax
f010600b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010600f:	c7 04 24 71 a6 10 f0 	movl   $0xf010a671,(%esp)
f0106016:	e8 95 ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010601b:	8b 45 08             	mov    0x8(%ebp),%eax
f010601e:	8b 40 0c             	mov    0xc(%eax),%eax
f0106021:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106025:	c7 04 24 80 a6 10 f0 	movl   $0xf010a680,(%esp)
f010602c:	e8 7f ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0106031:	8b 45 08             	mov    0x8(%ebp),%eax
f0106034:	8b 40 10             	mov    0x10(%eax),%eax
f0106037:	89 44 24 04          	mov    %eax,0x4(%esp)
f010603b:	c7 04 24 8f a6 10 f0 	movl   $0xf010a68f,(%esp)
f0106042:	e8 69 ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0106047:	8b 45 08             	mov    0x8(%ebp),%eax
f010604a:	8b 40 14             	mov    0x14(%eax),%eax
f010604d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106051:	c7 04 24 9e a6 10 f0 	movl   $0xf010a69e,(%esp)
f0106058:	e8 53 ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010605d:	8b 45 08             	mov    0x8(%ebp),%eax
f0106060:	8b 40 18             	mov    0x18(%eax),%eax
f0106063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106067:	c7 04 24 ad a6 10 f0 	movl   $0xf010a6ad,(%esp)
f010606e:	e8 3d ef ff ff       	call   f0104fb0 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0106073:	8b 45 08             	mov    0x8(%ebp),%eax
f0106076:	8b 40 1c             	mov    0x1c(%eax),%eax
f0106079:	89 44 24 04          	mov    %eax,0x4(%esp)
f010607d:	c7 04 24 bc a6 10 f0 	movl   $0xf010a6bc,(%esp)
f0106084:	e8 27 ef ff ff       	call   f0104fb0 <cprintf>
}
f0106089:	c9                   	leave  
f010608a:	c3                   	ret    

f010608b <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f010608b:	55                   	push   %ebp
f010608c:	89 e5                	mov    %esp,%ebp
f010608e:	57                   	push   %edi
f010608f:	56                   	push   %esi
f0106090:	53                   	push   %ebx
f0106091:	83 ec 3c             	sub    $0x3c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0106094:	8b 45 08             	mov    0x8(%ebp),%eax
f0106097:	8b 40 28             	mov    0x28(%eax),%eax
f010609a:	83 f8 27             	cmp    $0x27,%eax
f010609d:	75 1c                	jne    f01060bb <trap_dispatch+0x30>
		cprintf("Spurious interrupt on irq 7\n");
f010609f:	c7 04 24 cb a6 10 f0 	movl   $0xf010a6cb,(%esp)
f01060a6:	e8 05 ef ff ff       	call   f0104fb0 <cprintf>
		print_trapframe(tf);
f01060ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ae:	89 04 24             	mov    %eax,(%esp)
f01060b1:	e8 4c fd ff ff       	call   f0105e02 <print_trapframe>
		return;
f01060b6:	e9 f1 00 00 00       	jmp    f01061ac <trap_dispatch+0x121>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	struct PushRegs *regs = &(tf->tf_regs);
f01060bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01060be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t ret_sys;
	switch(tf->tf_trapno){
f01060c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01060c4:	8b 40 28             	mov    0x28(%eax),%eax
f01060c7:	83 f8 30             	cmp    $0x30,%eax
f01060ca:	0f 87 90 00 00 00    	ja     f0106160 <trap_dispatch+0xd5>
f01060d0:	8b 04 85 10 a7 10 f0 	mov    -0xfef58f0(,%eax,4),%eax
f01060d7:	ff e0                	jmp    *%eax
		case T_PGFLT:
			page_fault_handler(tf);
f01060d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01060dc:	89 04 24             	mov    %eax,(%esp)
f01060df:	e8 67 02 00 00       	call   f010634b <page_fault_handler>
			break;
f01060e4:	e9 c3 00 00 00       	jmp    f01061ac <trap_dispatch+0x121>
		case T_BRKPT:
			monitor(tf);
f01060e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ec:	89 04 24             	mov    %eax,(%esp)
f01060ef:	e8 58 b0 ff ff       	call   f010114c <monitor>
			break;
f01060f4:	e9 b3 00 00 00       	jmp    f01061ac <trap_dispatch+0x121>
		case T_DEBUG:
			monitor(tf);
f01060f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01060fc:	89 04 24             	mov    %eax,(%esp)
f01060ff:	e8 48 b0 ff ff       	call   f010114c <monitor>
			break;
f0106104:	e9 a3 00 00 00       	jmp    f01061ac <trap_dispatch+0x121>
		case T_SYSCALL:
			ret_sys = syscall(regs->reg_eax, regs->reg_edx, regs->reg_ecx, regs->reg_ebx, regs->reg_edi, regs->reg_esi);
f0106109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010610c:	8b 78 04             	mov    0x4(%eax),%edi
f010610f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106112:	8b 30                	mov    (%eax),%esi
f0106114:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106117:	8b 58 10             	mov    0x10(%eax),%ebx
f010611a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010611d:	8b 48 18             	mov    0x18(%eax),%ecx
f0106120:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106123:	8b 50 14             	mov    0x14(%eax),%edx
f0106126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106129:	8b 40 1c             	mov    0x1c(%eax),%eax
f010612c:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0106130:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106134:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106138:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010613c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106140:	89 04 24             	mov    %eax,(%esp)
f0106143:	e8 a4 0f 00 00       	call   f01070ec <syscall>
f0106148:	89 45 e0             	mov    %eax,-0x20(%ebp)
			regs->reg_eax = ret_sys;
f010614b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010614e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106151:	89 50 1c             	mov    %edx,0x1c(%eax)
			break;
f0106154:	eb 56                	jmp    f01061ac <trap_dispatch+0x121>
		case IRQ_OFFSET+IRQ_TIMER:
			lapic_eoi();
f0106156:	e8 e9 2a 00 00       	call   f0108c44 <lapic_eoi>
			sched_yield();
f010615b:	e8 fd 04 00 00       	call   f010665d <sched_yield>
			break;
		default:
			print_trapframe(tf);
f0106160:	8b 45 08             	mov    0x8(%ebp),%eax
f0106163:	89 04 24             	mov    %eax,(%esp)
f0106166:	e8 97 fc ff ff       	call   f0105e02 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f010616b:	8b 45 08             	mov    0x8(%ebp),%eax
f010616e:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0106172:	66 83 f8 08          	cmp    $0x8,%ax
f0106176:	75 1c                	jne    f0106194 <trap_dispatch+0x109>
				panic("unhandled trap in kernel");
f0106178:	c7 44 24 08 e8 a6 10 	movl   $0xf010a6e8,0x8(%esp)
f010617f:	f0 
f0106180:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
f0106187:	00 
f0106188:	c7 04 24 01 a7 10 f0 	movl   $0xf010a701,(%esp)
f010618f:	e8 3b a1 ff ff       	call   f01002cf <_panic>
			else {
				env_destroy(curenv);
f0106194:	e8 89 2a 00 00       	call   f0108c22 <cpunum>
f0106199:	6b c0 74             	imul   $0x74,%eax,%eax
f010619c:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01061a1:	8b 00                	mov    (%eax),%eax
f01061a3:	89 04 24             	mov    %eax,(%esp)
f01061a6:	e8 d0 e9 ff ff       	call   f0104b7b <env_destroy>
				return;
f01061ab:	90                   	nop
			}
	}
	// Unexpected trap: The user process or the kernel has a bug.
}
f01061ac:	83 c4 3c             	add    $0x3c,%esp
f01061af:	5b                   	pop    %ebx
f01061b0:	5e                   	pop    %esi
f01061b1:	5f                   	pop    %edi
f01061b2:	5d                   	pop    %ebp
f01061b3:	c3                   	ret    

f01061b4 <trap>:

void
trap(struct Trapframe *tf)
{
f01061b4:	55                   	push   %ebp
f01061b5:	89 e5                	mov    %esp,%ebp
f01061b7:	57                   	push   %edi
f01061b8:	56                   	push   %esi
f01061b9:	53                   	push   %ebx
f01061ba:	83 ec 2c             	sub    $0x2c,%esp
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01061bd:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01061be:	a1 e0 6e 24 f0       	mov    0xf0246ee0,%eax
f01061c3:	85 c0                	test   %eax,%eax
f01061c5:	74 01                	je     f01061c8 <trap+0x14>
		asm volatile("hlt");
f01061c7:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01061c8:	e8 55 2a 00 00       	call   f0108c22 <cpunum>
f01061cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01061d0:	05 20 70 24 f0       	add    $0xf0247020,%eax
f01061d5:	83 c0 04             	add    $0x4,%eax
f01061d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01061df:	00 
f01061e0:	89 04 24             	mov    %eax,(%esp)
f01061e3:	e8 ee ed ff ff       	call   f0104fd6 <xchg>
f01061e8:	83 f8 02             	cmp    $0x2,%eax
f01061eb:	75 05                	jne    f01061f2 <trap+0x3e>
		lock_kernel();
f01061ed:	e8 fe ed ff ff       	call   f0104ff0 <lock_kernel>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01061f2:	9c                   	pushf  
f01061f3:	58                   	pop    %eax
f01061f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	return eflags;
f01061f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01061fa:	25 00 02 00 00       	and    $0x200,%eax
f01061ff:	85 c0                	test   %eax,%eax
f0106201:	74 24                	je     f0106227 <trap+0x73>
f0106203:	c7 44 24 0c d4 a7 10 	movl   $0xf010a7d4,0xc(%esp)
f010620a:	f0 
f010620b:	c7 44 24 08 ed a7 10 	movl   $0xf010a7ed,0x8(%esp)
f0106212:	f0 
f0106213:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f010621a:	00 
f010621b:	c7 04 24 01 a7 10 f0 	movl   $0xf010a701,(%esp)
f0106222:	e8 a8 a0 ff ff       	call   f01002cf <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0106227:	8b 45 08             	mov    0x8(%ebp),%eax
f010622a:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f010622e:	0f b7 c0             	movzwl %ax,%eax
f0106231:	83 e0 03             	and    $0x3,%eax
f0106234:	83 f8 03             	cmp    $0x3,%eax
f0106237:	0f 85 b5 00 00 00    	jne    f01062f2 <trap+0x13e>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
f010623d:	e8 ae ed ff ff       	call   f0104ff0 <lock_kernel>
		assert(curenv);
f0106242:	e8 db 29 00 00       	call   f0108c22 <cpunum>
f0106247:	6b c0 74             	imul   $0x74,%eax,%eax
f010624a:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010624f:	8b 00                	mov    (%eax),%eax
f0106251:	85 c0                	test   %eax,%eax
f0106253:	75 24                	jne    f0106279 <trap+0xc5>
f0106255:	c7 44 24 0c 02 a8 10 	movl   $0xf010a802,0xc(%esp)
f010625c:	f0 
f010625d:	c7 44 24 08 ed a7 10 	movl   $0xf010a7ed,0x8(%esp)
f0106264:	f0 
f0106265:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f010626c:	00 
f010626d:	c7 04 24 01 a7 10 f0 	movl   $0xf010a701,(%esp)
f0106274:	e8 56 a0 ff ff       	call   f01002cf <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0106279:	e8 a4 29 00 00       	call   f0108c22 <cpunum>
f010627e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106281:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106286:	8b 00                	mov    (%eax),%eax
f0106288:	8b 40 54             	mov    0x54(%eax),%eax
f010628b:	83 f8 01             	cmp    $0x1,%eax
f010628e:	75 2f                	jne    f01062bf <trap+0x10b>
			env_free(curenv);
f0106290:	e8 8d 29 00 00       	call   f0108c22 <cpunum>
f0106295:	6b c0 74             	imul   $0x74,%eax,%eax
f0106298:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010629d:	8b 00                	mov    (%eax),%eax
f010629f:	89 04 24             	mov    %eax,(%esp)
f01062a2:	e8 03 e7 ff ff       	call   f01049aa <env_free>
			curenv = NULL;
f01062a7:	e8 76 29 00 00       	call   f0108c22 <cpunum>
f01062ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01062af:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01062b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			sched_yield();
f01062ba:	e8 9e 03 00 00       	call   f010665d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01062bf:	e8 5e 29 00 00       	call   f0108c22 <cpunum>
f01062c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01062c7:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01062cc:	8b 10                	mov    (%eax),%edx
f01062ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01062d1:	89 c3                	mov    %eax,%ebx
f01062d3:	b8 11 00 00 00       	mov    $0x11,%eax
f01062d8:	89 d7                	mov    %edx,%edi
f01062da:	89 de                	mov    %ebx,%esi
f01062dc:	89 c1                	mov    %eax,%ecx
f01062de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01062e0:	e8 3d 29 00 00       	call   f0108c22 <cpunum>
f01062e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01062e8:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01062ed:	8b 00                	mov    (%eax),%eax
f01062ef:	89 45 08             	mov    %eax,0x8(%ebp)
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01062f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01062f5:	a3 c8 6a 24 f0       	mov    %eax,0xf0246ac8

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f01062fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01062fd:	89 04 24             	mov    %eax,(%esp)
f0106300:	e8 86 fd ff ff       	call   f010608b <trap_dispatch>

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0106305:	e8 18 29 00 00       	call   f0108c22 <cpunum>
f010630a:	6b c0 74             	imul   $0x74,%eax,%eax
f010630d:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106312:	8b 00                	mov    (%eax),%eax
f0106314:	85 c0                	test   %eax,%eax
f0106316:	74 2e                	je     f0106346 <trap+0x192>
f0106318:	e8 05 29 00 00       	call   f0108c22 <cpunum>
f010631d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106320:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106325:	8b 00                	mov    (%eax),%eax
f0106327:	8b 40 54             	mov    0x54(%eax),%eax
f010632a:	83 f8 03             	cmp    $0x3,%eax
f010632d:	75 17                	jne    f0106346 <trap+0x192>
		env_run(curenv);
f010632f:	e8 ee 28 00 00       	call   f0108c22 <cpunum>
f0106334:	6b c0 74             	imul   $0x74,%eax,%eax
f0106337:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010633c:	8b 00                	mov    (%eax),%eax
f010633e:	89 04 24             	mov    %eax,(%esp)
f0106341:	e8 e3 e8 ff ff       	call   f0104c29 <env_run>
	else
		sched_yield();
f0106346:	e8 12 03 00 00       	call   f010665d <sched_yield>

f010634b <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010634b:	55                   	push   %ebp
f010634c:	89 e5                	mov    %esp,%ebp
f010634e:	53                   	push   %ebx
f010634f:	83 ec 24             	sub    $0x24,%esp

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0106352:	0f 20 d0             	mov    %cr2,%eax
f0106355:	89 45 e8             	mov    %eax,-0x18(%ebp)
	return val;
f0106358:	8b 45 e8             	mov    -0x18(%ebp),%eax
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f010635b:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f010635e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106361:	0f b7 40 34          	movzwl 0x34(%eax),%eax
f0106365:	66 83 f8 08          	cmp    $0x8,%ax
f0106369:	75 1c                	jne    f0106387 <page_fault_handler+0x3c>
		panic("page fault in kernel");
f010636b:	c7 44 24 08 09 a8 10 	movl   $0xf010a809,0x8(%esp)
f0106372:	f0 
f0106373:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f010637a:	00 
f010637b:	c7 04 24 01 a7 10 f0 	movl   $0xf010a701,(%esp)
f0106382:	e8 48 9f ff ff       	call   f01002cf <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall == NULL || tf->tf_esp > UXSTACKTOP || (tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE))){
f0106387:	e8 96 28 00 00       	call   f0108c22 <cpunum>
f010638c:	6b c0 74             	imul   $0x74,%eax,%eax
f010638f:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106394:	8b 00                	mov    (%eax),%eax
f0106396:	8b 40 64             	mov    0x64(%eax),%eax
f0106399:	85 c0                	test   %eax,%eax
f010639b:	74 27                	je     f01063c4 <page_fault_handler+0x79>
f010639d:	8b 45 08             	mov    0x8(%ebp),%eax
f01063a0:	8b 40 3c             	mov    0x3c(%eax),%eax
f01063a3:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f01063a8:	77 1a                	ja     f01063c4 <page_fault_handler+0x79>
f01063aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01063ad:	8b 40 3c             	mov    0x3c(%eax),%eax
f01063b0:	3d 00 e0 bf ee       	cmp    $0xeebfe000,%eax
f01063b5:	76 67                	jbe    f010641e <page_fault_handler+0xd3>
f01063b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01063ba:	8b 40 3c             	mov    0x3c(%eax),%eax
f01063bd:	3d ff ef bf ee       	cmp    $0xeebfefff,%eax
f01063c2:	77 5a                	ja     f010641e <page_fault_handler+0xd3>
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01063c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01063c7:	8b 58 30             	mov    0x30(%eax),%ebx
			curenv->env_id, fault_va, tf->tf_eip);
f01063ca:	e8 53 28 00 00       	call   f0108c22 <cpunum>
f01063cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01063d2:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01063d7:	8b 00                	mov    (%eax),%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall == NULL || tf->tf_esp > UXSTACKTOP || (tf->tf_esp > USTACKTOP && tf->tf_esp < (UXSTACKTOP - PGSIZE))){
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
f01063d9:	8b 40 48             	mov    0x48(%eax),%eax
f01063dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01063e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01063e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063eb:	c7 04 24 20 a8 10 f0 	movl   $0xf010a820,(%esp)
f01063f2:	e8 b9 eb ff ff       	call   f0104fb0 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f01063f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01063fa:	89 04 24             	mov    %eax,(%esp)
f01063fd:	e8 00 fa ff ff       	call   f0105e02 <print_trapframe>
		env_destroy(curenv);
f0106402:	e8 1b 28 00 00       	call   f0108c22 <cpunum>
f0106407:	6b c0 74             	imul   $0x74,%eax,%eax
f010640a:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010640f:	8b 00                	mov    (%eax),%eax
f0106411:	89 04 24             	mov    %eax,(%esp)
f0106414:	e8 62 e7 ff ff       	call   f0104b7b <env_destroy>
f0106419:	e9 3a 01 00 00       	jmp    f0106558 <page_fault_handler+0x20d>
	}
	else{
		// cprintf("user fault\n");
		uint32_t ex_stack_top;
		if(tf->tf_esp < USTACKTOP) ex_stack_top = UXSTACKTOP - sizeof(struct UTrapframe);		//switch from user stack to user exception stack
f010641e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106421:	8b 40 3c             	mov    0x3c(%eax),%eax
f0106424:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f0106429:	77 09                	ja     f0106434 <page_fault_handler+0xe9>
f010642b:	c7 45 f4 cc ff bf ee 	movl   $0xeebfffcc,-0xc(%ebp)
f0106432:	eb 0c                	jmp    f0106440 <page_fault_handler+0xf5>
		else ex_stack_top = tf->tf_esp - sizeof(struct UTrapframe) - 4;		//recursive pagefault
f0106434:	8b 45 08             	mov    0x8(%ebp),%eax
f0106437:	8b 40 3c             	mov    0x3c(%eax),%eax
f010643a:	83 e8 38             	sub    $0x38,%eax
f010643d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		user_mem_assert(curenv, (void *)ex_stack_top, sizeof(struct UTrapframe), PTE_U | PTE_P | PTE_W);
f0106440:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106443:	e8 da 27 00 00       	call   f0108c22 <cpunum>
f0106448:	6b c0 74             	imul   $0x74,%eax,%eax
f010644b:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106450:	8b 00                	mov    (%eax),%eax
f0106452:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0106459:	00 
f010645a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0106461:	00 
f0106462:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106466:	89 04 24             	mov    %eax,(%esp)
f0106469:	e8 83 b9 ff ff       	call   f0101df1 <user_mem_assert>
		user_mem_assert(curenv, curenv->env_pgfault_upcall, PGSIZE, PTE_U | PTE_P);
f010646e:	e8 af 27 00 00       	call   f0108c22 <cpunum>
f0106473:	6b c0 74             	imul   $0x74,%eax,%eax
f0106476:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010647b:	8b 00                	mov    (%eax),%eax
f010647d:	8b 58 64             	mov    0x64(%eax),%ebx
f0106480:	e8 9d 27 00 00       	call   f0108c22 <cpunum>
f0106485:	6b c0 74             	imul   $0x74,%eax,%eax
f0106488:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010648d:	8b 00                	mov    (%eax),%eax
f010648f:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0106496:	00 
f0106497:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010649e:	00 
f010649f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01064a3:	89 04 24             	mov    %eax,(%esp)
f01064a6:	e8 46 b9 ff ff       	call   f0101df1 <user_mem_assert>
		struct UTrapframe *utf = (struct UTrapframe *)ex_stack_top;
f01064ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01064ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
		utf->utf_fault_va = fault_va;
f01064b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01064b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01064b7:	89 10                	mov    %edx,(%eax)
		utf->utf_err = tf->tf_err;
f01064b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01064bc:	8b 50 2c             	mov    0x2c(%eax),%edx
f01064bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01064c2:	89 50 04             	mov    %edx,0x4(%eax)
		utf->utf_regs = tf->tf_regs;
f01064c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01064c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01064cb:	8b 0a                	mov    (%edx),%ecx
f01064cd:	89 48 08             	mov    %ecx,0x8(%eax)
f01064d0:	8b 4a 04             	mov    0x4(%edx),%ecx
f01064d3:	89 48 0c             	mov    %ecx,0xc(%eax)
f01064d6:	8b 4a 08             	mov    0x8(%edx),%ecx
f01064d9:	89 48 10             	mov    %ecx,0x10(%eax)
f01064dc:	8b 4a 0c             	mov    0xc(%edx),%ecx
f01064df:	89 48 14             	mov    %ecx,0x14(%eax)
f01064e2:	8b 4a 10             	mov    0x10(%edx),%ecx
f01064e5:	89 48 18             	mov    %ecx,0x18(%eax)
f01064e8:	8b 4a 14             	mov    0x14(%edx),%ecx
f01064eb:	89 48 1c             	mov    %ecx,0x1c(%eax)
f01064ee:	8b 4a 18             	mov    0x18(%edx),%ecx
f01064f1:	89 48 20             	mov    %ecx,0x20(%eax)
f01064f4:	8b 52 1c             	mov    0x1c(%edx),%edx
f01064f7:	89 50 24             	mov    %edx,0x24(%eax)
		utf->utf_eip = tf->tf_eip;
f01064fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01064fd:	8b 50 30             	mov    0x30(%eax),%edx
f0106500:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106503:	89 50 28             	mov    %edx,0x28(%eax)
		utf->utf_eflags = tf->tf_eflags;
f0106506:	8b 45 08             	mov    0x8(%ebp),%eax
f0106509:	8b 50 38             	mov    0x38(%eax),%edx
f010650c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010650f:	89 50 2c             	mov    %edx,0x2c(%eax)
		utf->utf_esp = tf->tf_esp;
f0106512:	8b 45 08             	mov    0x8(%ebp),%eax
f0106515:	8b 50 3c             	mov    0x3c(%eax),%edx
f0106518:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010651b:	89 50 30             	mov    %edx,0x30(%eax)

		tf->tf_esp = (uintptr_t)ex_stack_top;
f010651e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106521:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106524:	89 50 3c             	mov    %edx,0x3c(%eax)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0106527:	e8 f6 26 00 00       	call   f0108c22 <cpunum>
f010652c:	6b c0 74             	imul   $0x74,%eax,%eax
f010652f:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106534:	8b 00                	mov    (%eax),%eax
f0106536:	8b 40 64             	mov    0x64(%eax),%eax
f0106539:	89 c2                	mov    %eax,%edx
f010653b:	8b 45 08             	mov    0x8(%ebp),%eax
f010653e:	89 50 30             	mov    %edx,0x30(%eax)
		env_run(curenv);	
f0106541:	e8 dc 26 00 00       	call   f0108c22 <cpunum>
f0106546:	6b c0 74             	imul   $0x74,%eax,%eax
f0106549:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010654e:	8b 00                	mov    (%eax),%eax
f0106550:	89 04 24             	mov    %eax,(%esp)
f0106553:	e8 d1 e6 ff ff       	call   f0104c29 <env_run>
	}
}
f0106558:	83 c4 24             	add    $0x24,%esp
f010655b:	5b                   	pop    %ebx
f010655c:	5d                   	pop    %ebp
f010655d:	c3                   	ret    

f010655e <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.text
TRAPHANDLER_NOEC(t_divide , T_DIVIDE)
f010655e:	6a 00                	push   $0x0
f0106560:	6a 00                	push   $0x0
f0106562:	eb 7c                	jmp    f01065e0 <_alltraps>

f0106564 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0106564:	6a 00                	push   $0x0
f0106566:	6a 01                	push   $0x1
f0106568:	eb 76                	jmp    f01065e0 <_alltraps>

f010656a <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f010656a:	6a 00                	push   $0x0
f010656c:	6a 02                	push   $0x2
f010656e:	eb 70                	jmp    f01065e0 <_alltraps>

f0106570 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0106570:	6a 00                	push   $0x0
f0106572:	6a 03                	push   $0x3
f0106574:	eb 6a                	jmp    f01065e0 <_alltraps>

f0106576 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0106576:	6a 00                	push   $0x0
f0106578:	6a 05                	push   $0x5
f010657a:	eb 64                	jmp    f01065e0 <_alltraps>

f010657c <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f010657c:	6a 00                	push   $0x0
f010657e:	6a 06                	push   $0x6
f0106580:	eb 5e                	jmp    f01065e0 <_alltraps>

f0106582 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0106582:	6a 00                	push   $0x0
f0106584:	6a 07                	push   $0x7
f0106586:	eb 58                	jmp    f01065e0 <_alltraps>

f0106588 <t_dblflt>:

TRAPHANDLER(t_dblflt, T_DBLFLT)
f0106588:	6a 08                	push   $0x8
f010658a:	eb 54                	jmp    f01065e0 <_alltraps>

f010658c <t_tss>:

TRAPHANDLER(t_tss, T_TSS)
f010658c:	6a 0a                	push   $0xa
f010658e:	eb 50                	jmp    f01065e0 <_alltraps>

f0106590 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0106590:	6a 0b                	push   $0xb
f0106592:	eb 4c                	jmp    f01065e0 <_alltraps>

f0106594 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0106594:	6a 0c                	push   $0xc
f0106596:	eb 48                	jmp    f01065e0 <_alltraps>

f0106598 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0106598:	6a 0d                	push   $0xd
f010659a:	eb 44                	jmp    f01065e0 <_alltraps>

f010659c <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f010659c:	6a 0e                	push   $0xe
f010659e:	eb 40                	jmp    f01065e0 <_alltraps>

f01065a0 <t_fperr>:

TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01065a0:	6a 00                	push   $0x0
f01065a2:	6a 10                	push   $0x10
f01065a4:	eb 3a                	jmp    f01065e0 <_alltraps>

f01065a6 <t_align>:

TRAPHANDLER(t_align, T_ALIGN)
f01065a6:	6a 11                	push   $0x11
f01065a8:	eb 36                	jmp    f01065e0 <_alltraps>

f01065aa <t_mchk>:

TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01065aa:	6a 00                	push   $0x0
f01065ac:	6a 12                	push   $0x12
f01065ae:	eb 30                	jmp    f01065e0 <_alltraps>

f01065b0 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01065b0:	6a 00                	push   $0x0
f01065b2:	6a 13                	push   $0x13
f01065b4:	eb 2a                	jmp    f01065e0 <_alltraps>

f01065b6 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01065b6:	6a 00                	push   $0x0
f01065b8:	6a 30                	push   $0x30
f01065ba:	eb 24                	jmp    f01065e0 <_alltraps>

f01065bc <irq_timer>:

TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET + IRQ_TIMER)
f01065bc:	6a 00                	push   $0x0
f01065be:	6a 20                	push   $0x20
f01065c0:	eb 1e                	jmp    f01065e0 <_alltraps>

f01065c2 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET + IRQ_KBD)
f01065c2:	6a 00                	push   $0x0
f01065c4:	6a 21                	push   $0x21
f01065c6:	eb 18                	jmp    f01065e0 <_alltraps>

f01065c8 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET + IRQ_SERIAL)
f01065c8:	6a 00                	push   $0x0
f01065ca:	6a 24                	push   $0x24
f01065cc:	eb 12                	jmp    f01065e0 <_alltraps>

f01065ce <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f01065ce:	6a 00                	push   $0x0
f01065d0:	6a 27                	push   $0x27
f01065d2:	eb 0c                	jmp    f01065e0 <_alltraps>

f01065d4 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET + IRQ_IDE)
f01065d4:	6a 00                	push   $0x0
f01065d6:	6a 2e                	push   $0x2e
f01065d8:	eb 06                	jmp    f01065e0 <_alltraps>

f01065da <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET + IRQ_ERROR)
f01065da:	6a 00                	push   $0x0
f01065dc:	6a 33                	push   $0x33
f01065de:	eb 00                	jmp    f01065e0 <_alltraps>

f01065e0 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 

_alltraps:
	push %ds
f01065e0:	1e                   	push   %ds
	push %es
f01065e1:	06                   	push   %es
	pushal
f01065e2:	60                   	pusha  
	movl $(GD_KD), %eax
f01065e3:	b8 10 00 00 00       	mov    $0x10,%eax
	movl %eax, %ds
f01065e8:	8e d8                	mov    %eax,%ds
	movl %eax, %es
f01065ea:	8e c0                	mov    %eax,%es
	pushl %esp
f01065ec:	54                   	push   %esp
	call trap
f01065ed:	e8 c2 fb ff ff       	call   f01061b4 <trap>

f01065f2 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f01065f2:	55                   	push   %ebp
f01065f3:	89 e5                	mov    %esp,%ebp
f01065f5:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01065f8:	8b 55 08             	mov    0x8(%ebp),%edx
f01065fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106601:	f0 87 02             	lock xchg %eax,(%edx)
f0106604:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0106607:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f010660a:	c9                   	leave  
f010660b:	c3                   	ret    

f010660c <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f010660c:	55                   	push   %ebp
f010660d:	89 e5                	mov    %esp,%ebp
f010660f:	83 ec 18             	sub    $0x18,%esp
	spin_unlock(&kernel_lock);
f0106612:	c7 04 24 e0 65 12 f0 	movl   $0xf01265e0,(%esp)
f0106619:	e8 07 29 00 00       	call   f0108f25 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010661e:	f3 90                	pause  
}
f0106620:	c9                   	leave  
f0106621:	c3                   	ret    

f0106622 <_paddr>:
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
f0106622:	55                   	push   %ebp
f0106623:	89 e5                	mov    %esp,%ebp
f0106625:	83 ec 18             	sub    $0x18,%esp
	if ((uint32_t)kva < KERNBASE)
f0106628:	8b 45 10             	mov    0x10(%ebp),%eax
f010662b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0106630:	77 21                	ja     f0106653 <_paddr+0x31>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106632:	8b 45 10             	mov    0x10(%ebp),%eax
f0106635:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106639:	c7 44 24 08 f0 a9 10 	movl   $0xf010a9f0,0x8(%esp)
f0106640:	f0 
f0106641:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106644:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106648:	8b 45 08             	mov    0x8(%ebp),%eax
f010664b:	89 04 24             	mov    %eax,(%esp)
f010664e:	e8 7c 9c ff ff       	call   f01002cf <_panic>
	return (physaddr_t)kva - KERNBASE;
f0106653:	8b 45 10             	mov    0x10(%ebp),%eax
f0106656:	05 00 00 00 10       	add    $0x10000000,%eax
}
f010665b:	c9                   	leave  
f010665c:	c3                   	ret    

f010665d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010665d:	55                   	push   %ebp
f010665e:	89 e5                	mov    %esp,%ebp
f0106660:	83 ec 28             	sub    $0x28,%esp

	// LAB 4: Your code here.

	int cur_id;
 	int i;
 	bool no_runnable=true;
f0106663:	c6 45 ef 01          	movb   $0x1,-0x11(%ebp)
	if(!thiscpu->cpu_env) cur_id = 0;
f0106667:	e8 b6 25 00 00       	call   f0108c22 <cpunum>
f010666c:	6b c0 74             	imul   $0x74,%eax,%eax
f010666f:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106674:	8b 00                	mov    (%eax),%eax
f0106676:	85 c0                	test   %eax,%eax
f0106678:	75 0c                	jne    f0106686 <sched_yield+0x29>
f010667a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0106681:	e9 81 00 00 00       	jmp    f0106707 <sched_yield+0xaa>
	else if(thiscpu->cpu_env->env_status == ENV_RUNNING){
f0106686:	e8 97 25 00 00       	call   f0108c22 <cpunum>
f010668b:	6b c0 74             	imul   $0x74,%eax,%eax
f010668e:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106693:	8b 00                	mov    (%eax),%eax
f0106695:	8b 40 54             	mov    0x54(%eax),%eax
f0106698:	83 f8 03             	cmp    $0x3,%eax
f010669b:	75 41                	jne    f01066de <sched_yield+0x81>
		thiscpu->cpu_env->env_status = ENV_RUNNABLE;
f010669d:	e8 80 25 00 00       	call   f0108c22 <cpunum>
f01066a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01066a5:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01066aa:	8b 00                	mov    (%eax),%eax
f01066ac:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		cur_id = thiscpu->cpu_env - envs+1;
f01066b3:	e8 6a 25 00 00       	call   f0108c22 <cpunum>
f01066b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01066bb:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01066c0:	8b 00                	mov    (%eax),%eax
f01066c2:	89 c2                	mov    %eax,%edx
f01066c4:	a1 3c 62 24 f0       	mov    0xf024623c,%eax
f01066c9:	29 c2                	sub    %eax,%edx
f01066cb:	89 d0                	mov    %edx,%eax
f01066cd:	c1 f8 02             	sar    $0x2,%eax
f01066d0:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f01066d6:	83 c0 01             	add    $0x1,%eax
f01066d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01066dc:	eb 29                	jmp    f0106707 <sched_yield+0xaa>
	}
	else{
		cur_id = thiscpu->cpu_env - envs + 1;
f01066de:	e8 3f 25 00 00       	call   f0108c22 <cpunum>
f01066e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01066e6:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01066eb:	8b 00                	mov    (%eax),%eax
f01066ed:	89 c2                	mov    %eax,%edx
f01066ef:	a1 3c 62 24 f0       	mov    0xf024623c,%eax
f01066f4:	29 c2                	sub    %eax,%edx
f01066f6:	89 d0                	mov    %edx,%eax
f01066f8:	c1 f8 02             	sar    $0x2,%eax
f01066fb:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f0106701:	83 c0 01             	add    $0x1,%eax
f0106704:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
 	for(i = 0;i < NENV; cur_id++, i++){
f0106707:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010670e:	eb 62                	jmp    f0106772 <sched_yield+0x115>
 		if(cur_id >= NENV) cur_id %= NENV;
f0106710:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0106717:	7e 13                	jle    f010672c <sched_yield+0xcf>
f0106719:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010671c:	99                   	cltd   
f010671d:	c1 ea 16             	shr    $0x16,%edx
f0106720:	01 d0                	add    %edx,%eax
f0106722:	25 ff 03 00 00       	and    $0x3ff,%eax
f0106727:	29 d0                	sub    %edx,%eax
f0106729:	89 45 f4             	mov    %eax,-0xc(%ebp)
 		if(envs[cur_id].env_status == ENV_RUNNABLE){
f010672c:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f0106732:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106735:	c1 e0 02             	shl    $0x2,%eax
f0106738:	89 c1                	mov    %eax,%ecx
f010673a:	c1 e1 05             	shl    $0x5,%ecx
f010673d:	29 c1                	sub    %eax,%ecx
f010673f:	89 c8                	mov    %ecx,%eax
f0106741:	01 d0                	add    %edx,%eax
f0106743:	8b 40 54             	mov    0x54(%eax),%eax
f0106746:	83 f8 02             	cmp    $0x2,%eax
f0106749:	75 1f                	jne    f010676a <sched_yield+0x10d>
 			env_run(&envs[cur_id]);
f010674b:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f0106751:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106754:	c1 e0 02             	shl    $0x2,%eax
f0106757:	89 c1                	mov    %eax,%ecx
f0106759:	c1 e1 05             	shl    $0x5,%ecx
f010675c:	29 c1                	sub    %eax,%ecx
f010675e:	89 c8                	mov    %ecx,%eax
f0106760:	01 d0                	add    %edx,%eax
f0106762:	89 04 24             	mov    %eax,(%esp)
f0106765:	e8 bf e4 ff ff       	call   f0104c29 <env_run>
		cur_id = thiscpu->cpu_env - envs+1;
	}
	else{
		cur_id = thiscpu->cpu_env - envs + 1;
	}
 	for(i = 0;i < NENV; cur_id++, i++){
f010676a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f010676e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f0106772:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
f0106779:	7e 95                	jle    f0106710 <sched_yield+0xb3>
 			break;
 		}
 	}
 	// if((i == NENV) && (thiscpu->cpu_env->env_status == ENV_RUNNING)) env_run(&envs[cpunum()]);
	// sched_halt never returns
	if(no_runnable){
f010677b:	80 7d ef 00          	cmpb   $0x0,-0x11(%ebp)
f010677f:	74 05                	je     f0106786 <sched_yield+0x129>
		sched_halt();
f0106781:	e8 02 00 00 00       	call   f0106788 <sched_halt>
	}
}
f0106786:	c9                   	leave  
f0106787:	c3                   	ret    

f0106788 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0106788:	55                   	push   %ebp
f0106789:	89 e5                	mov    %esp,%ebp
f010678b:	83 ec 28             	sub    $0x28,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010678e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0106795:	eb 61                	jmp    f01067f8 <sched_halt+0x70>
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0106797:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f010679d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01067a0:	c1 e0 02             	shl    $0x2,%eax
f01067a3:	89 c1                	mov    %eax,%ecx
f01067a5:	c1 e1 05             	shl    $0x5,%ecx
f01067a8:	29 c1                	sub    %eax,%ecx
f01067aa:	89 c8                	mov    %ecx,%eax
f01067ac:	01 d0                	add    %edx,%eax
f01067ae:	8b 40 54             	mov    0x54(%eax),%eax
f01067b1:	83 f8 02             	cmp    $0x2,%eax
f01067b4:	74 4b                	je     f0106801 <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
f01067b6:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f01067bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01067bf:	c1 e0 02             	shl    $0x2,%eax
f01067c2:	89 c1                	mov    %eax,%ecx
f01067c4:	c1 e1 05             	shl    $0x5,%ecx
f01067c7:	29 c1                	sub    %eax,%ecx
f01067c9:	89 c8                	mov    %ecx,%eax
f01067cb:	01 d0                	add    %edx,%eax
f01067cd:	8b 40 54             	mov    0x54(%eax),%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01067d0:	83 f8 03             	cmp    $0x3,%eax
f01067d3:	74 2c                	je     f0106801 <sched_halt+0x79>
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
f01067d5:	8b 15 3c 62 24 f0    	mov    0xf024623c,%edx
f01067db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01067de:	c1 e0 02             	shl    $0x2,%eax
f01067e1:	89 c1                	mov    %eax,%ecx
f01067e3:	c1 e1 05             	shl    $0x5,%ecx
f01067e6:	29 c1                	sub    %eax,%ecx
f01067e8:	89 c8                	mov    %ecx,%eax
f01067ea:	01 d0                	add    %edx,%eax
f01067ec:	8b 40 54             	mov    0x54(%eax),%eax

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01067ef:	83 f8 01             	cmp    $0x1,%eax
f01067f2:	74 0d                	je     f0106801 <sched_halt+0x79>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01067f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f01067f8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f01067ff:	7e 96                	jle    f0106797 <sched_halt+0xf>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0106801:	81 7d f4 00 04 00 00 	cmpl   $0x400,-0xc(%ebp)
f0106808:	75 1a                	jne    f0106824 <sched_halt+0x9c>
		cprintf("No runnable environments in the system!\n");
f010680a:	c7 04 24 14 aa 10 f0 	movl   $0xf010aa14,(%esp)
f0106811:	e8 9a e7 ff ff       	call   f0104fb0 <cprintf>
		while (1)
			monitor(NULL);
f0106816:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010681d:	e8 2a a9 ff ff       	call   f010114c <monitor>
f0106822:	eb f2                	jmp    f0106816 <sched_halt+0x8e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0106824:	e8 f9 23 00 00       	call   f0108c22 <cpunum>
f0106829:	6b c0 74             	imul   $0x74,%eax,%eax
f010682c:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106831:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	lcr3(PADDR(kern_pgdir));
f0106837:	a1 ec 6e 24 f0       	mov    0xf0246eec,%eax
f010683c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106840:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0106847:	00 
f0106848:	c7 04 24 3d aa 10 f0 	movl   $0xf010aa3d,(%esp)
f010684f:	e8 ce fd ff ff       	call   f0106622 <_paddr>
f0106854:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0106857:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010685a:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010685d:	e8 c0 23 00 00       	call   f0108c22 <cpunum>
f0106862:	6b c0 74             	imul   $0x74,%eax,%eax
f0106865:	05 20 70 24 f0       	add    $0xf0247020,%eax
f010686a:	83 c0 04             	add    $0x4,%eax
f010686d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0106874:	00 
f0106875:	89 04 24             	mov    %eax,(%esp)
f0106878:	e8 75 fd ff ff       	call   f01065f2 <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f010687d:	e8 8a fd ff ff       	call   f010660c <unlock_kernel>
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0106882:	e8 9b 23 00 00       	call   f0108c22 <cpunum>
f0106887:	6b c0 74             	imul   $0x74,%eax,%eax
f010688a:	05 30 70 24 f0       	add    $0xf0247030,%eax
f010688f:	8b 00                	mov    (%eax),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0106891:	bd 00 00 00 00       	mov    $0x0,%ebp
f0106896:	89 c4                	mov    %eax,%esp
f0106898:	6a 00                	push   $0x0
f010689a:	6a 00                	push   $0x0
f010689c:	fb                   	sti    
f010689d:	f4                   	hlt    
f010689e:	eb fd                	jmp    f010689d <sched_halt+0x115>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01068a0:	c9                   	leave  
f01068a1:	c3                   	ret    

f01068a2 <sys_cputs>:
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
f01068a2:	55                   	push   %ebp
f01068a3:	89 e5                	mov    %esp,%ebp
f01068a5:	83 ec 18             	sub    $0x18,%esp
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv,s, len, 0);
f01068a8:	e8 75 23 00 00       	call   f0108c22 <cpunum>
f01068ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01068b0:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01068b5:	8b 00                	mov    (%eax),%eax
f01068b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01068be:	00 
f01068bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01068c2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01068c6:	8b 55 08             	mov    0x8(%ebp),%edx
f01068c9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01068cd:	89 04 24             	mov    %eax,(%esp)
f01068d0:	e8 1c b5 ff ff       	call   f0101df1 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01068d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01068d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01068dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01068df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068e3:	c7 04 24 4c aa 10 f0 	movl   $0xf010aa4c,(%esp)
f01068ea:	e8 c1 e6 ff ff       	call   f0104fb0 <cprintf>
}
f01068ef:	c9                   	leave  
f01068f0:	c3                   	ret    

f01068f1 <sys_cgetc>:

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
f01068f1:	55                   	push   %ebp
f01068f2:	89 e5                	mov    %esp,%ebp
f01068f4:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f01068f7:	e8 bd a1 ff ff       	call   f0100ab9 <cons_getc>
}
f01068fc:	c9                   	leave  
f01068fd:	c3                   	ret    

f01068fe <sys_getenvid>:

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01068fe:	55                   	push   %ebp
f01068ff:	89 e5                	mov    %esp,%ebp
f0106901:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0106904:	e8 19 23 00 00       	call   f0108c22 <cpunum>
f0106909:	6b c0 74             	imul   $0x74,%eax,%eax
f010690c:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106911:	8b 00                	mov    (%eax),%eax
f0106913:	8b 40 48             	mov    0x48(%eax),%eax
}
f0106916:	c9                   	leave  
f0106917:	c3                   	ret    

f0106918 <sys_env_destroy>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
f0106918:	55                   	push   %ebp
f0106919:	89 e5                	mov    %esp,%ebp
f010691b:	53                   	push   %ebx
f010691c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010691f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106926:	00 
f0106927:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010692a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010692e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106931:	89 04 24             	mov    %eax,(%esp)
f0106934:	e8 15 da ff ff       	call   f010434e <envid2env>
f0106939:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010693c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106940:	79 05                	jns    f0106947 <sys_env_destroy+0x2f>
		return r;
f0106942:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106945:	eb 76                	jmp    f01069bd <sys_env_destroy+0xa5>
	if (e == curenv)
f0106947:	e8 d6 22 00 00       	call   f0108c22 <cpunum>
f010694c:	6b c0 74             	imul   $0x74,%eax,%eax
f010694f:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106954:	8b 10                	mov    (%eax),%edx
f0106956:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106959:	39 c2                	cmp    %eax,%edx
f010695b:	75 24                	jne    f0106981 <sys_env_destroy+0x69>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010695d:	e8 c0 22 00 00       	call   f0108c22 <cpunum>
f0106962:	6b c0 74             	imul   $0x74,%eax,%eax
f0106965:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010696a:	8b 00                	mov    (%eax),%eax
f010696c:	8b 40 48             	mov    0x48(%eax),%eax
f010696f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106973:	c7 04 24 51 aa 10 f0 	movl   $0xf010aa51,(%esp)
f010697a:	e8 31 e6 ff ff       	call   f0104fb0 <cprintf>
f010697f:	eb 2c                	jmp    f01069ad <sys_env_destroy+0x95>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0106981:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106984:	8b 58 48             	mov    0x48(%eax),%ebx
f0106987:	e8 96 22 00 00       	call   f0108c22 <cpunum>
f010698c:	6b c0 74             	imul   $0x74,%eax,%eax
f010698f:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106994:	8b 00                	mov    (%eax),%eax
f0106996:	8b 40 48             	mov    0x48(%eax),%eax
f0106999:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010699d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069a1:	c7 04 24 6c aa 10 f0 	movl   $0xf010aa6c,(%esp)
f01069a8:	e8 03 e6 ff ff       	call   f0104fb0 <cprintf>
	env_destroy(e);
f01069ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01069b0:	89 04 24             	mov    %eax,(%esp)
f01069b3:	e8 c3 e1 ff ff       	call   f0104b7b <env_destroy>
	return 0;
f01069b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01069bd:	83 c4 24             	add    $0x24,%esp
f01069c0:	5b                   	pop    %ebx
f01069c1:	5d                   	pop    %ebp
f01069c2:	c3                   	ret    

f01069c3 <sys_yield>:

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f01069c3:	55                   	push   %ebp
f01069c4:	89 e5                	mov    %esp,%ebp
f01069c6:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f01069c9:	e8 8f fc ff ff       	call   f010665d <sched_yield>

f01069ce <sys_exofork>:
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
f01069ce:	55                   	push   %ebp
f01069cf:	89 e5                	mov    %esp,%ebp
f01069d1:	57                   	push   %edi
f01069d2:	56                   	push   %esi
f01069d3:	53                   	push   %ebx
f01069d4:	83 ec 2c             	sub    $0x2c,%esp
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env* e;
	int r;
	if((r = env_alloc(&e,curenv->env_id)) < 0) return r;
f01069d7:	e8 46 22 00 00       	call   f0108c22 <cpunum>
f01069dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01069df:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01069e4:	8b 00                	mov    (%eax),%eax
f01069e6:	8b 40 48             	mov    0x48(%eax),%eax
f01069e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069ed:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01069f0:	89 04 24             	mov    %eax,(%esp)
f01069f3:	e8 8e db ff ff       	call   f0104586 <env_alloc>
f01069f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01069fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01069ff:	79 05                	jns    f0106a06 <sys_exofork+0x38>
f0106a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106a04:	eb 3d                	jmp    f0106a43 <sys_exofork+0x75>
	e->env_status = ENV_NOT_RUNNABLE;
f0106a06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106a09:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf = curenv->env_tf;
f0106a10:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0106a13:	e8 0a 22 00 00       	call   f0108c22 <cpunum>
f0106a18:	6b c0 74             	imul   $0x74,%eax,%eax
f0106a1b:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106a20:	8b 00                	mov    (%eax),%eax
f0106a22:	89 da                	mov    %ebx,%edx
f0106a24:	89 c3                	mov    %eax,%ebx
f0106a26:	b8 11 00 00 00       	mov    $0x11,%eax
f0106a2b:	89 d7                	mov    %edx,%edi
f0106a2d:	89 de                	mov    %ebx,%esi
f0106a2f:	89 c1                	mov    %eax,%ecx
f0106a31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0106a33:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106a36:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0106a3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106a40:	8b 40 48             	mov    0x48(%eax),%eax
	// panic("sys_exofork not implemented");
}
f0106a43:	83 c4 2c             	add    $0x2c,%esp
f0106a46:	5b                   	pop    %ebx
f0106a47:	5e                   	pop    %esi
f0106a48:	5f                   	pop    %edi
f0106a49:	5d                   	pop    %ebp
f0106a4a:	c3                   	ret    

f0106a4b <sys_env_set_status>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
f0106a4b:	55                   	push   %ebp
f0106a4c:	89 e5                	mov    %esp,%ebp
f0106a4e:	83 ec 28             	sub    $0x28,%esp
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106a51:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106a58:	00 
f0106a59:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a60:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a63:	89 04 24             	mov    %eax,(%esp)
f0106a66:	e8 e3 d8 ff ff       	call   f010434e <envid2env>
f0106a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106a6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106a72:	79 05                	jns    f0106a79 <sys_env_set_status+0x2e>
f0106a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106a77:	eb 21                	jmp    f0106a9a <sys_env_set_status+0x4f>
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
f0106a79:	83 7d 0c 02          	cmpl   $0x2,0xc(%ebp)
f0106a7d:	74 06                	je     f0106a85 <sys_env_set_status+0x3a>
f0106a7f:	83 7d 0c 04          	cmpl   $0x4,0xc(%ebp)
f0106a83:	75 10                	jne    f0106a95 <sys_env_set_status+0x4a>
f0106a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106a88:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106a8b:	89 50 54             	mov    %edx,0x54(%eax)
	else return -E_INVAL;
	return 0;
f0106a8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106a93:	eb 05                	jmp    f0106a9a <sys_env_set_status+0x4f>
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
	if(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE) e->env_status = status;
	else return -E_INVAL;
f0106a95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return 0;
	// panic("sys_env_set_status not implemented");
}
f0106a9a:	c9                   	leave  
f0106a9b:	c3                   	ret    

f0106a9c <sys_env_set_pgfault_upcall>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
f0106a9c:	55                   	push   %ebp
f0106a9d:	89 e5                	mov    %esp,%ebp
f0106a9f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106aa2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106aa9:	00 
f0106aaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0106aad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ab1:	8b 45 08             	mov    0x8(%ebp),%eax
f0106ab4:	89 04 24             	mov    %eax,(%esp)
f0106ab7:	e8 92 d8 ff ff       	call   f010434e <envid2env>
f0106abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106abf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106ac3:	79 05                	jns    f0106aca <sys_env_set_pgfault_upcall+0x2e>
f0106ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106ac8:	eb 0e                	jmp    f0106ad8 <sys_env_set_pgfault_upcall+0x3c>
	e->env_pgfault_upcall = func;
f0106aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106acd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106ad0:	89 50 64             	mov    %edx,0x64(%eax)
	return 0;
f0106ad3:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_env_set_pgfault_upcall not implemented");
}
f0106ad8:	c9                   	leave  
f0106ad9:	c3                   	ret    

f0106ada <sys_page_alloc>:
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
f0106ada:	55                   	push   %ebp
f0106adb:	89 e5                	mov    %esp,%ebp
f0106add:	83 ec 38             	sub    $0x38,%esp

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
f0106ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106ae3:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106ae8:	77 2e                	ja     f0106b18 <sys_page_alloc+0x3e>
f0106aea:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106af1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106af7:	01 d0                	add    %edx,%eax
f0106af9:	83 e8 01             	sub    $0x1,%eax
f0106afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106b02:	ba 00 00 00 00       	mov    $0x0,%edx
f0106b07:	f7 75 f4             	divl   -0xc(%ebp)
f0106b0a:	89 d0                	mov    %edx,%eax
f0106b0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106b0f:	29 c2                	sub    %eax,%edx
f0106b11:	89 d0                	mov    %edx,%eax
f0106b13:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106b16:	74 0a                	je     f0106b22 <sys_page_alloc+0x48>
f0106b18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b1d:	e9 a3 00 00 00       	jmp    f0106bc5 <sys_page_alloc+0xeb>
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
f0106b22:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b25:	83 e0 04             	and    $0x4,%eax
f0106b28:	85 c0                	test   %eax,%eax
f0106b2a:	74 0a                	je     f0106b36 <sys_page_alloc+0x5c>
f0106b2c:	8b 45 10             	mov    0x10(%ebp),%eax
f0106b2f:	83 e0 01             	and    $0x1,%eax
f0106b32:	85 c0                	test   %eax,%eax
f0106b34:	75 0a                	jne    f0106b40 <sys_page_alloc+0x66>
f0106b36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106b3b:	e9 85 00 00 00       	jmp    f0106bc5 <sys_page_alloc+0xeb>
	if(perm & !PTE_SYSCALL) return -E_INVAL;
	
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106b40:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106b47:	00 
f0106b48:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106b52:	89 04 24             	mov    %eax,(%esp)
f0106b55:	e8 f4 d7 ff ff       	call   f010434e <envid2env>
f0106b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106b5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106b61:	79 05                	jns    f0106b68 <sys_page_alloc+0x8e>
f0106b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106b66:	eb 5d                	jmp    f0106bc5 <sys_page_alloc+0xeb>
	struct PageInfo *p;
	if(!(p = page_alloc(ALLOC_ZERO))) return -E_NO_MEM;
f0106b68:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0106b6f:	e8 0e ad ff ff       	call   f0101882 <page_alloc>
f0106b74:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106b77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106b7b:	75 07                	jne    f0106b84 <sys_page_alloc+0xaa>
f0106b7d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0106b82:	eb 41                	jmp    f0106bc5 <sys_page_alloc+0xeb>
	if((r = page_insert(e->env_pgdir, p, va, perm)) < 0){
f0106b84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106b87:	8b 40 60             	mov    0x60(%eax),%eax
f0106b8a:	8b 55 10             	mov    0x10(%ebp),%edx
f0106b8d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b91:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b94:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b98:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106b9b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106b9f:	89 04 24             	mov    %eax,(%esp)
f0106ba2:	e8 64 af ff ff       	call   f0101b0b <page_insert>
f0106ba7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106baa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106bae:	79 10                	jns    f0106bc0 <sys_page_alloc+0xe6>
		page_free(p);
f0106bb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106bb3:	89 04 24             	mov    %eax,(%esp)
f0106bb6:	e8 2a ad ff ff       	call   f01018e5 <page_free>
		return r;
f0106bbb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106bbe:	eb 05                	jmp    f0106bc5 <sys_page_alloc+0xeb>
	}
	return 0;
f0106bc0:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_alloc not implemented");
}
f0106bc5:	c9                   	leave  
f0106bc6:	c3                   	ret    

f0106bc7 <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f0106bc7:	55                   	push   %ebp
f0106bc8:	89 e5                	mov    %esp,%ebp
f0106bca:	83 ec 48             	sub    $0x48,%esp
	// LAB 4: Your code here.
	struct Env *srce;
	struct Env *dste;
	int r;

	if((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE) != srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE) != dstva) return -E_INVAL;
f0106bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106bd0:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106bd5:	77 66                	ja     f0106c3d <sys_page_map+0x76>
f0106bd7:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106bde:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106be4:	01 d0                	add    %edx,%eax
f0106be6:	83 e8 01             	sub    $0x1,%eax
f0106be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106bef:	ba 00 00 00 00       	mov    $0x0,%edx
f0106bf4:	f7 75 f4             	divl   -0xc(%ebp)
f0106bf7:	89 d0                	mov    %edx,%eax
f0106bf9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106bfc:	29 c2                	sub    %eax,%edx
f0106bfe:	89 d0                	mov    %edx,%eax
f0106c00:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106c03:	75 38                	jne    f0106c3d <sys_page_map+0x76>
f0106c05:	8b 45 14             	mov    0x14(%ebp),%eax
f0106c08:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106c0d:	77 2e                	ja     f0106c3d <sys_page_map+0x76>
f0106c0f:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
f0106c16:	8b 55 14             	mov    0x14(%ebp),%edx
f0106c19:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106c1c:	01 d0                	add    %edx,%eax
f0106c1e:	83 e8 01             	sub    $0x1,%eax
f0106c21:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106c24:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106c27:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c2c:	f7 75 ec             	divl   -0x14(%ebp)
f0106c2f:	89 d0                	mov    %edx,%eax
f0106c31:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0106c34:	29 c2                	sub    %eax,%edx
f0106c36:	89 d0                	mov    %edx,%eax
f0106c38:	3b 45 14             	cmp    0x14(%ebp),%eax
f0106c3b:	74 0a                	je     f0106c47 <sys_page_map+0x80>
f0106c3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106c42:	e9 f5 00 00 00       	jmp    f0106d3c <sys_page_map+0x175>
	if(!(perm & PTE_U) || !(perm & PTE_P)) return -E_INVAL;
f0106c47:	8b 45 18             	mov    0x18(%ebp),%eax
f0106c4a:	83 e0 04             	and    $0x4,%eax
f0106c4d:	85 c0                	test   %eax,%eax
f0106c4f:	74 0a                	je     f0106c5b <sys_page_map+0x94>
f0106c51:	8b 45 18             	mov    0x18(%ebp),%eax
f0106c54:	83 e0 01             	and    $0x1,%eax
f0106c57:	85 c0                	test   %eax,%eax
f0106c59:	75 0a                	jne    f0106c65 <sys_page_map+0x9e>
f0106c5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106c60:	e9 d7 00 00 00       	jmp    f0106d3c <sys_page_map+0x175>
	if(perm & !PTE_SYSCALL) return -E_INVAL;

	if((r = envid2env(srcenvid, &srce, 1)) < 0) return r;
f0106c65:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106c6c:	00 
f0106c6d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0106c70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c74:	8b 45 08             	mov    0x8(%ebp),%eax
f0106c77:	89 04 24             	mov    %eax,(%esp)
f0106c7a:	e8 cf d6 ff ff       	call   f010434e <envid2env>
f0106c7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106c82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106c86:	79 08                	jns    f0106c90 <sys_page_map+0xc9>
f0106c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106c8b:	e9 ac 00 00 00       	jmp    f0106d3c <sys_page_map+0x175>
	if((r = envid2env(dstenvid, &dste, 1)) < 0) return r;
f0106c90:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106c97:	00 
f0106c98:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0106c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c9f:	8b 45 10             	mov    0x10(%ebp),%eax
f0106ca2:	89 04 24             	mov    %eax,(%esp)
f0106ca5:	e8 a4 d6 ff ff       	call   f010434e <envid2env>
f0106caa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106cad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106cb1:	79 08                	jns    f0106cbb <sys_page_map+0xf4>
f0106cb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106cb6:	e9 81 00 00 00       	jmp    f0106d3c <sys_page_map+0x175>
	struct PageInfo *srcp;
	struct PageInfo *dstp;
	pte_t *ptable_entry;
	if(!(srcp = page_lookup(srce->env_pgdir, srcva, &ptable_entry))) return -E_INVAL;
f0106cbb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0106cbe:	8b 40 60             	mov    0x60(%eax),%eax
f0106cc1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0106cc4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106ccb:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106ccf:	89 04 24             	mov    %eax,(%esp)
f0106cd2:	e8 c6 ae ff ff       	call   f0101b9d <page_lookup>
f0106cd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0106cda:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0106cde:	75 07                	jne    f0106ce7 <sys_page_map+0x120>
f0106ce0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106ce5:	eb 55                	jmp    f0106d3c <sys_page_map+0x175>
	if(~(*ptable_entry & PTE_W) & (perm & PTE_W)) return -E_INVAL;
f0106ce7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0106cea:	8b 00                	mov    (%eax),%eax
f0106cec:	83 e0 02             	and    $0x2,%eax
f0106cef:	f7 d0                	not    %eax
f0106cf1:	89 c2                	mov    %eax,%edx
f0106cf3:	8b 45 18             	mov    0x18(%ebp),%eax
f0106cf6:	21 d0                	and    %edx,%eax
f0106cf8:	83 e0 02             	and    $0x2,%eax
f0106cfb:	85 c0                	test   %eax,%eax
f0106cfd:	74 07                	je     f0106d06 <sys_page_map+0x13f>
f0106cff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d04:	eb 36                	jmp    f0106d3c <sys_page_map+0x175>
	if((r = page_insert(dste->env_pgdir, srcp, dstva, perm)) < 0) return r;
f0106d06:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106d09:	8b 40 60             	mov    0x60(%eax),%eax
f0106d0c:	8b 55 18             	mov    0x18(%ebp),%edx
f0106d0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106d13:	8b 55 14             	mov    0x14(%ebp),%edx
f0106d16:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106d1a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106d1d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106d21:	89 04 24             	mov    %eax,(%esp)
f0106d24:	e8 e2 ad ff ff       	call   f0101b0b <page_insert>
f0106d29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106d2c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106d30:	79 05                	jns    f0106d37 <sys_page_map+0x170>
f0106d32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106d35:	eb 05                	jmp    f0106d3c <sys_page_map+0x175>
	return 0;
f0106d37:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_map not implemented");
}
f0106d3c:	c9                   	leave  
f0106d3d:	c3                   	ret    

f0106d3e <sys_page_unmap>:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
f0106d3e:	55                   	push   %ebp
f0106d3f:	89 e5                	mov    %esp,%ebp
f0106d41:	83 ec 28             	sub    $0x28,%esp
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE) != va) return -E_INVAL;
f0106d44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106d47:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106d4c:	77 2e                	ja     f0106d7c <sys_page_unmap+0x3e>
f0106d4e:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
f0106d55:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106d5b:	01 d0                	add    %edx,%eax
f0106d5d:	83 e8 01             	sub    $0x1,%eax
f0106d60:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0106d66:	ba 00 00 00 00       	mov    $0x0,%edx
f0106d6b:	f7 75 f4             	divl   -0xc(%ebp)
f0106d6e:	89 d0                	mov    %edx,%eax
f0106d70:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106d73:	29 c2                	sub    %eax,%edx
f0106d75:	89 d0                	mov    %edx,%eax
f0106d77:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0106d7a:	74 07                	je     f0106d83 <sys_page_unmap+0x45>
f0106d7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106d81:	eb 42                	jmp    f0106dc5 <sys_page_unmap+0x87>
	if((r = envid2env(envid, &e, 1)) < 0) return r;
f0106d83:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0106d8a:	00 
f0106d8b:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d92:	8b 45 08             	mov    0x8(%ebp),%eax
f0106d95:	89 04 24             	mov    %eax,(%esp)
f0106d98:	e8 b1 d5 ff ff       	call   f010434e <envid2env>
f0106d9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106da0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0106da4:	79 05                	jns    f0106dab <sys_page_unmap+0x6d>
f0106da6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106da9:	eb 1a                	jmp    f0106dc5 <sys_page_unmap+0x87>
	page_remove(e->env_pgdir, va);
f0106dab:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106dae:	8b 40 60             	mov    0x60(%eax),%eax
f0106db1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106db4:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106db8:	89 04 24             	mov    %eax,(%esp)
f0106dbb:	e8 30 ae ff ff       	call   f0101bf0 <page_remove>
	return 0;
f0106dc0:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_page_unmap not implemented");
}
f0106dc5:	c9                   	leave  
f0106dc6:	c3                   	ret    

f0106dc7 <sys_ipc_try_send>:
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
f0106dc7:	55                   	push   %ebp
f0106dc8:	89 e5                	mov    %esp,%ebp
f0106dca:	53                   	push   %ebx
f0106dcb:	83 ec 34             	sub    $0x34,%esp
	// LAB 4: Your code here.
	struct Env *rec_env;
	int r;
	uint32_t i_srcva = (uint32_t)srcva;
f0106dce:	8b 45 10             	mov    0x10(%ebp),%eax
f0106dd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(i_srcva < UTOP && (ROUNDDOWN(srcva,PGSIZE) != srcva)) return -E_INVAL;
f0106dd4:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106ddb:	77 1d                	ja     f0106dfa <sys_ipc_try_send+0x33>
f0106ddd:	8b 45 10             	mov    0x10(%ebp),%eax
f0106de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106de3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106de6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106deb:	3b 45 10             	cmp    0x10(%ebp),%eax
f0106dee:	74 0a                	je     f0106dfa <sys_ipc_try_send+0x33>
f0106df0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106df5:	e9 64 01 00 00       	jmp    f0106f5e <sys_ipc_try_send+0x197>
	if(i_srcva < UTOP && (!(perm & PTE_U) || !(perm & PTE_P))) return -E_INVAL;
f0106dfa:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106e01:	77 1e                	ja     f0106e21 <sys_ipc_try_send+0x5a>
f0106e03:	8b 45 14             	mov    0x14(%ebp),%eax
f0106e06:	83 e0 04             	and    $0x4,%eax
f0106e09:	85 c0                	test   %eax,%eax
f0106e0b:	74 0a                	je     f0106e17 <sys_ipc_try_send+0x50>
f0106e0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0106e10:	83 e0 01             	and    $0x1,%eax
f0106e13:	85 c0                	test   %eax,%eax
f0106e15:	75 0a                	jne    f0106e21 <sys_ipc_try_send+0x5a>
f0106e17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e1c:	e9 3d 01 00 00       	jmp    f0106f5e <sys_ipc_try_send+0x197>
	if(i_srcva < UTOP && (perm & !PTE_SYSCALL)) return -E_INVAL;
	pte_t *pte;
	struct PageInfo *pp;
	if(i_srcva < UTOP && !(pp = page_lookup(curenv->env_pgdir, srcva, &pte))) return -E_INVAL;
f0106e21:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106e28:	77 3b                	ja     f0106e65 <sys_ipc_try_send+0x9e>
f0106e2a:	e8 f3 1d 00 00       	call   f0108c22 <cpunum>
f0106e2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0106e32:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106e37:	8b 00                	mov    (%eax),%eax
f0106e39:	8b 40 60             	mov    0x60(%eax),%eax
f0106e3c:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0106e3f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106e43:	8b 55 10             	mov    0x10(%ebp),%edx
f0106e46:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106e4a:	89 04 24             	mov    %eax,(%esp)
f0106e4d:	e8 4b ad ff ff       	call   f0101b9d <page_lookup>
f0106e52:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106e55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0106e59:	75 0a                	jne    f0106e65 <sys_ipc_try_send+0x9e>
f0106e5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e60:	e9 f9 00 00 00       	jmp    f0106f5e <sys_ipc_try_send+0x197>
	if((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0106e65:	8b 45 14             	mov    0x14(%ebp),%eax
f0106e68:	83 e0 02             	and    $0x2,%eax
f0106e6b:	85 c0                	test   %eax,%eax
f0106e6d:	74 16                	je     f0106e85 <sys_ipc_try_send+0xbe>
f0106e6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106e72:	8b 00                	mov    (%eax),%eax
f0106e74:	83 e0 02             	and    $0x2,%eax
f0106e77:	85 c0                	test   %eax,%eax
f0106e79:	75 0a                	jne    f0106e85 <sys_ipc_try_send+0xbe>
f0106e7b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106e80:	e9 d9 00 00 00       	jmp    f0106f5e <sys_ipc_try_send+0x197>
	
	if((r = envid2env(envid,&rec_env,0)) < 0) return r;
f0106e85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0106e8c:	00 
f0106e8d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0106e90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e94:	8b 45 08             	mov    0x8(%ebp),%eax
f0106e97:	89 04 24             	mov    %eax,(%esp)
f0106e9a:	e8 af d4 ff ff       	call   f010434e <envid2env>
f0106e9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106ea2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106ea6:	79 08                	jns    f0106eb0 <sys_ipc_try_send+0xe9>
f0106ea8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106eab:	e9 ae 00 00 00       	jmp    f0106f5e <sys_ipc_try_send+0x197>
	
	if(!rec_env->env_ipc_recving) return -E_IPC_NOT_RECV;
f0106eb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106eb3:	0f b6 40 68          	movzbl 0x68(%eax),%eax
f0106eb7:	83 f0 01             	xor    $0x1,%eax
f0106eba:	84 c0                	test   %al,%al
f0106ebc:	74 0a                	je     f0106ec8 <sys_ipc_try_send+0x101>
f0106ebe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f0106ec3:	e9 96 00 00 00       	jmp    f0106f5e <sys_ipc_try_send+0x197>

	if(i_srcva < UTOP && ((uint32_t)rec_env->env_ipc_dstva) < UTOP){
f0106ec8:	81 7d f0 ff ff bf ee 	cmpl   $0xeebfffff,-0x10(%ebp)
f0106ecf:	77 4c                	ja     f0106f1d <sys_ipc_try_send+0x156>
f0106ed1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106ed4:	8b 40 6c             	mov    0x6c(%eax),%eax
f0106ed7:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106edc:	77 3f                	ja     f0106f1d <sys_ipc_try_send+0x156>
		if((r = page_insert(rec_env->env_pgdir, pp, rec_env->env_ipc_dstva, perm)) < 0) return r;
f0106ede:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0106ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106ee4:	8b 50 6c             	mov    0x6c(%eax),%edx
f0106ee7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106eea:	8b 40 60             	mov    0x60(%eax),%eax
f0106eed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106ef1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106ef5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0106ef8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106efc:	89 04 24             	mov    %eax,(%esp)
f0106eff:	e8 07 ac ff ff       	call   f0101b0b <page_insert>
f0106f04:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0106f07:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0106f0b:	79 05                	jns    f0106f12 <sys_ipc_try_send+0x14b>
f0106f0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0106f10:	eb 4c                	jmp    f0106f5e <sys_ipc_try_send+0x197>
		rec_env->env_ipc_perm = perm;
f0106f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f15:	8b 55 14             	mov    0x14(%ebp),%edx
f0106f18:	89 50 78             	mov    %edx,0x78(%eax)
f0106f1b:	eb 0a                	jmp    f0106f27 <sys_ipc_try_send+0x160>
	}
	else{
		rec_env->env_ipc_perm = 0;
f0106f1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f20:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	rec_env->env_ipc_recving = 0;
f0106f27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f2a:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	rec_env->env_ipc_from = curenv->env_id;
f0106f2e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0106f31:	e8 ec 1c 00 00       	call   f0108c22 <cpunum>
f0106f36:	6b c0 74             	imul   $0x74,%eax,%eax
f0106f39:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106f3e:	8b 00                	mov    (%eax),%eax
f0106f40:	8b 40 48             	mov    0x48(%eax),%eax
f0106f43:	89 43 74             	mov    %eax,0x74(%ebx)
	rec_env->env_ipc_value = value;
f0106f46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f49:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106f4c:	89 50 70             	mov    %edx,0x70(%eax)
	rec_env->env_status = ENV_RUNNABLE;
f0106f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f52:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0106f59:	b8 00 00 00 00       	mov    $0x0,%eax
	// panic("sys_ipc_try_send not implemented");
}
f0106f5e:	83 c4 34             	add    $0x34,%esp
f0106f61:	5b                   	pop    %ebx
f0106f62:	5d                   	pop    %ebp
f0106f63:	c3                   	ret    

f0106f64 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f0106f64:	55                   	push   %ebp
f0106f65:	89 e5                	mov    %esp,%ebp
f0106f67:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	if((uint32_t)dstva < UTOP && ROUNDDOWN((uint32_t)dstva,PGSIZE) != PGSIZE) return -E_INVAL;
f0106f6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f6d:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0106f72:	77 1c                	ja     f0106f90 <sys_ipc_recv+0x2c>
f0106f74:	8b 45 08             	mov    0x8(%ebp),%eax
f0106f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106f7d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0106f82:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0106f87:	74 07                	je     f0106f90 <sys_ipc_recv+0x2c>
f0106f89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106f8e:	eb 5e                	jmp    f0106fee <sys_ipc_recv+0x8a>
	curenv->env_ipc_recving = 1;
f0106f90:	e8 8d 1c 00 00       	call   f0108c22 <cpunum>
f0106f95:	6b c0 74             	imul   $0x74,%eax,%eax
f0106f98:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106f9d:	8b 00                	mov    (%eax),%eax
f0106f9f:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0106fa3:	e8 7a 1c 00 00       	call   f0108c22 <cpunum>
f0106fa8:	6b c0 74             	imul   $0x74,%eax,%eax
f0106fab:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106fb0:	8b 00                	mov    (%eax),%eax
f0106fb2:	8b 55 08             	mov    0x8(%ebp),%edx
f0106fb5:	89 50 6c             	mov    %edx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0106fb8:	e8 65 1c 00 00       	call   f0108c22 <cpunum>
f0106fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0106fc0:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106fc5:	8b 00                	mov    (%eax),%eax
f0106fc7:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	curenv->env_tf.tf_regs.reg_eax = 0;
f0106fce:	e8 4f 1c 00 00       	call   f0108c22 <cpunum>
f0106fd3:	6b c0 74             	imul   $0x74,%eax,%eax
f0106fd6:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0106fdb:	8b 00                	mov    (%eax),%eax
f0106fdd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	sys_yield();
f0106fe4:	e8 da f9 ff ff       	call   f01069c3 <sys_yield>
	// panic("sys_ipc_recv not implemented");
	return 0;
f0106fe9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106fee:	c9                   	leave  
f0106fef:	c3                   	ret    

f0106ff0 <get_cmd>:

char* get_cmd(char* buf){
f0106ff0:	55                   	push   %ebp
f0106ff1:	89 e5                	mov    %esp,%ebp
f0106ff3:	83 ec 28             	sub    $0x28,%esp
	char* w_pos = strchr(buf, ' ');
f0106ff6:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0106ffd:	00 
f0106ffe:	8b 45 08             	mov    0x8(%ebp),%eax
f0107001:	89 04 24             	mov    %eax,(%esp)
f0107004:	e8 ed 10 00 00       	call   f01080f6 <strchr>
f0107009:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(w_pos == NULL){
f010700c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0107010:	75 05                	jne    f0107017 <get_cmd+0x27>
		return buf;
f0107012:	8b 45 08             	mov    0x8(%ebp),%eax
f0107015:	eb 2a                	jmp    f0107041 <get_cmd+0x51>
	}

	char* cmd = "";
f0107017:	c7 45 f0 84 aa 10 f0 	movl   $0xf010aa84,-0x10(%ebp)
	strncpy(cmd, (const char*)buf, w_pos-buf);
f010701e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107021:	8b 45 08             	mov    0x8(%ebp),%eax
f0107024:	29 c2                	sub    %eax,%edx
f0107026:	89 d0                	mov    %edx,%eax
f0107028:	89 44 24 08          	mov    %eax,0x8(%esp)
f010702c:	8b 45 08             	mov    0x8(%ebp),%eax
f010702f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107033:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107036:	89 04 24             	mov    %eax,(%esp)
f0107039:	e8 8d 0f 00 00       	call   f0107fcb <strncpy>
	return (cmd);
f010703e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0107041:	c9                   	leave  
f0107042:	c3                   	ret    

f0107043 <sys_exec>:


void sys_exec(char* buf){
f0107043:	55                   	push   %ebp
f0107044:	89 e5                	mov    %esp,%ebp
f0107046:	83 ec 28             	sub    $0x28,%esp
	cprintf("hello");
f0107049:	c7 04 24 85 aa 10 f0 	movl   $0xf010aa85,(%esp)
f0107050:	e8 5b df ff ff       	call   f0104fb0 <cprintf>
	uint32_t parent_id = curenv->env_parent_id;
f0107055:	e8 c8 1b 00 00       	call   f0108c22 <cpunum>
f010705a:	6b c0 74             	imul   $0x74,%eax,%eax
f010705d:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0107062:	8b 00                	mov    (%eax),%eax
f0107064:	8b 40 4c             	mov    0x4c(%eax),%eax
f0107067:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t cur_id = curenv->env_id;
f010706a:	e8 b3 1b 00 00       	call   f0108c22 <cpunum>
f010706f:	6b c0 74             	imul   $0x74,%eax,%eax
f0107072:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0107077:	8b 00                	mov    (%eax),%eax
f0107079:	8b 40 48             	mov    0x48(%eax),%eax
f010707c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	env_free(curenv);
f010707f:	e8 9e 1b 00 00       	call   f0108c22 <cpunum>
f0107084:	6b c0 74             	imul   $0x74,%eax,%eax
f0107087:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010708c:	8b 00                	mov    (%eax),%eax
f010708e:	89 04 24             	mov    %eax,(%esp)
f0107091:	e8 14 d9 ff ff       	call   f01049aa <env_free>
	struct Env* e;
	env_alloc(&e, curenv->env_parent_id);
f0107096:	e8 87 1b 00 00       	call   f0108c22 <cpunum>
f010709b:	6b c0 74             	imul   $0x74,%eax,%eax
f010709e:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01070a3:	8b 00                	mov    (%eax),%eax
f01070a5:	8b 40 4c             	mov    0x4c(%eax),%eax
f01070a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070ac:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01070af:	89 04 24             	mov    %eax,(%esp)
f01070b2:	e8 cf d4 ff ff       	call   f0104586 <env_alloc>
	e->env_id = cur_id;
f01070b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01070ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01070bd:	89 50 48             	mov    %edx,0x48(%eax)
	char* cmd = get_cmd(buf);
f01070c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01070c3:	89 04 24             	mov    %eax,(%esp)
f01070c6:	e8 25 ff ff ff       	call   f0106ff0 <get_cmd>
f01070cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	// char* x = strcat(x, (const char*)cmd);
	// uint8_t* binary;
	// if(strcmp(x, (const char*)("primes"))){
		extern uint8_t ENV_PASTE3(_binary_obj_, user_primes , _start)[];
	// }
	load_icode(e,ENV_PASTE3(_binary_obj_, user_primes , _start));
f01070ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01070d1:	c7 44 24 04 78 ac 23 	movl   $0xf023ac78,0x4(%esp)
f01070d8:	f0 
f01070d9:	89 04 24             	mov    %eax,(%esp)
f01070dc:	e8 d5 d6 ff ff       	call   f01047b6 <load_icode>
	// lcr3(e->env_pgdir);
	env_run(e);
f01070e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01070e4:	89 04 24             	mov    %eax,(%esp)
f01070e7:	e8 3d db ff ff       	call   f0104c29 <env_run>

f01070ec <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01070ec:	55                   	push   %ebp
f01070ed:	89 e5                	mov    %esp,%ebp
f01070ef:	56                   	push   %esi
f01070f0:	53                   	push   %ebx
f01070f1:	83 ec 20             	sub    $0x20,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f01070f4:	83 7d 08 0d          	cmpl   $0xd,0x8(%ebp)
f01070f8:	0f 87 2f 01 00 00    	ja     f010722d <syscall+0x141>
f01070fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0107101:	c1 e0 02             	shl    $0x2,%eax
f0107104:	05 8c aa 10 f0       	add    $0xf010aa8c,%eax
f0107109:	8b 00                	mov    (%eax),%eax
f010710b:	ff e0                	jmp    *%eax
		case SYS_cputs:
			sys_cputs((char *)a1,a2);
f010710d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107110:	8b 55 10             	mov    0x10(%ebp),%edx
f0107113:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107117:	89 04 24             	mov    %eax,(%esp)
f010711a:	e8 83 f7 ff ff       	call   f01068a2 <sys_cputs>
			return 0;
f010711f:	b8 00 00 00 00       	mov    $0x0,%eax
f0107124:	e9 09 01 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_cgetc:
			return sys_cgetc();
f0107129:	e8 c3 f7 ff ff       	call   f01068f1 <sys_cgetc>
f010712e:	e9 ff 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_getenvid:
			return sys_getenvid();
f0107133:	e8 c6 f7 ff ff       	call   f01068fe <sys_getenvid>
f0107138:	e9 f5 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f010713d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107140:	89 04 24             	mov    %eax,(%esp)
f0107143:	e8 d0 f7 ff ff       	call   f0106918 <sys_env_destroy>
f0107148:	e9 e5 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_yield:
			sys_yield();
f010714d:	e8 71 f8 ff ff       	call   f01069c3 <sys_yield>
			return 0;
f0107152:	b8 00 00 00 00       	mov    $0x0,%eax
f0107157:	e9 d6 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_exofork:
			return sys_exofork();
f010715c:	e8 6d f8 ff ff       	call   f01069ce <sys_exofork>
f0107161:	e9 cc 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f0107166:	8b 55 10             	mov    0x10(%ebp),%edx
f0107169:	8b 45 0c             	mov    0xc(%ebp),%eax
f010716c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107170:	89 04 24             	mov    %eax,(%esp)
f0107173:	e8 d3 f8 ff ff       	call   f0106a4b <sys_env_set_status>
f0107178:	e9 b5 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void *)a2,(int)a3);
f010717d:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0107180:	8b 55 10             	mov    0x10(%ebp),%edx
f0107183:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107186:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010718a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010718e:	89 04 24             	mov    %eax,(%esp)
f0107191:	e8 44 f9 ff ff       	call   f0106ada <sys_page_alloc>
f0107196:	e9 97 00 00 00       	jmp    f0107232 <syscall+0x146>
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void *)a2,(envid_t)a3,(void *)a4,(int)a5);
f010719b:	8b 75 1c             	mov    0x1c(%ebp),%esi
f010719e:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01071a1:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01071a4:	8b 55 10             	mov    0x10(%ebp),%edx
f01071a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01071aa:	89 74 24 10          	mov    %esi,0x10(%esp)
f01071ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01071b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01071b6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01071ba:	89 04 24             	mov    %eax,(%esp)
f01071bd:	e8 05 fa ff ff       	call   f0106bc7 <sys_page_map>
f01071c2:	eb 6e                	jmp    f0107232 <syscall+0x146>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void *)a2);
f01071c4:	8b 55 10             	mov    0x10(%ebp),%edx
f01071c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01071ca:	89 54 24 04          	mov    %edx,0x4(%esp)
f01071ce:	89 04 24             	mov    %eax,(%esp)
f01071d1:	e8 68 fb ff ff       	call   f0106d3e <sys_page_unmap>
f01071d6:	eb 5a                	jmp    f0107232 <syscall+0x146>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01071d8:	8b 55 10             	mov    0x10(%ebp),%edx
f01071db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01071de:	89 54 24 04          	mov    %edx,0x4(%esp)
f01071e2:	89 04 24             	mov    %eax,(%esp)
f01071e5:	e8 b2 f8 ff ff       	call   f0106a9c <sys_env_set_pgfault_upcall>
f01071ea:	eb 46                	jmp    f0107232 <syscall+0x146>
		case SYS_ipc_try_send:
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f01071ec:	8b 55 14             	mov    0x14(%ebp),%edx
f01071ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01071f2:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01071f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01071f9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01071fd:	8b 55 10             	mov    0x10(%ebp),%edx
f0107200:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107204:	89 04 24             	mov    %eax,(%esp)
f0107207:	e8 bb fb ff ff       	call   f0106dc7 <sys_ipc_try_send>
f010720c:	eb 24                	jmp    f0107232 <syscall+0x146>
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f010720e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107211:	89 04 24             	mov    %eax,(%esp)
f0107214:	e8 4b fd ff ff       	call   f0106f64 <sys_ipc_recv>
f0107219:	eb 17                	jmp    f0107232 <syscall+0x146>
		case SYS_exec:
			sys_exec((char *)a1);
f010721b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010721e:	89 04 24             	mov    %eax,(%esp)
f0107221:	e8 1d fe ff ff       	call   f0107043 <sys_exec>
			return 0;
f0107226:	b8 00 00 00 00       	mov    $0x0,%eax
f010722b:	eb 05                	jmp    f0107232 <syscall+0x146>
		default:
			return -E_INVAL;
f010722d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0107232:	83 c4 20             	add    $0x20,%esp
f0107235:	5b                   	pop    %ebx
f0107236:	5e                   	pop    %esi
f0107237:	5d                   	pop    %ebp
f0107238:	c3                   	ret    

f0107239 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0107239:	55                   	push   %ebp
f010723a:	89 e5                	mov    %esp,%ebp
f010723c:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f010723f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107242:	8b 00                	mov    (%eax),%eax
f0107244:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107247:	8b 45 10             	mov    0x10(%ebp),%eax
f010724a:	8b 00                	mov    (%eax),%eax
f010724c:	89 45 f8             	mov    %eax,-0x8(%ebp)
f010724f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	while (l <= r) {
f0107256:	e9 d2 00 00 00       	jmp    f010732d <stab_binsearch+0xf4>
		int true_m = (l + r) / 2, m = true_m;
f010725b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010725e:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107261:	01 d0                	add    %edx,%eax
f0107263:	89 c2                	mov    %eax,%edx
f0107265:	c1 ea 1f             	shr    $0x1f,%edx
f0107268:	01 d0                	add    %edx,%eax
f010726a:	d1 f8                	sar    %eax
f010726c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010726f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107272:	89 45 f0             	mov    %eax,-0x10(%ebp)

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0107275:	eb 04                	jmp    f010727b <stab_binsearch+0x42>
			m--;
f0107277:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010727b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010727e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0107281:	7c 1f                	jl     f01072a2 <stab_binsearch+0x69>
f0107283:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107286:	89 d0                	mov    %edx,%eax
f0107288:	01 c0                	add    %eax,%eax
f010728a:	01 d0                	add    %edx,%eax
f010728c:	c1 e0 02             	shl    $0x2,%eax
f010728f:	89 c2                	mov    %eax,%edx
f0107291:	8b 45 08             	mov    0x8(%ebp),%eax
f0107294:	01 d0                	add    %edx,%eax
f0107296:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f010729a:	0f b6 c0             	movzbl %al,%eax
f010729d:	3b 45 14             	cmp    0x14(%ebp),%eax
f01072a0:	75 d5                	jne    f0107277 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f01072a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01072a5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f01072a8:	7d 0b                	jge    f01072b5 <stab_binsearch+0x7c>
			l = true_m + 1;
f01072aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01072ad:	83 c0 01             	add    $0x1,%eax
f01072b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f01072b3:	eb 78                	jmp    f010732d <stab_binsearch+0xf4>
		}

		// actual binary search
		any_matches = 1;
f01072b5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f01072bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01072bf:	89 d0                	mov    %edx,%eax
f01072c1:	01 c0                	add    %eax,%eax
f01072c3:	01 d0                	add    %edx,%eax
f01072c5:	c1 e0 02             	shl    $0x2,%eax
f01072c8:	89 c2                	mov    %eax,%edx
f01072ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01072cd:	01 d0                	add    %edx,%eax
f01072cf:	8b 40 08             	mov    0x8(%eax),%eax
f01072d2:	3b 45 18             	cmp    0x18(%ebp),%eax
f01072d5:	73 13                	jae    f01072ea <stab_binsearch+0xb1>
			*region_left = m;
f01072d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01072da:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01072dd:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f01072df:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01072e2:	83 c0 01             	add    $0x1,%eax
f01072e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
f01072e8:	eb 43                	jmp    f010732d <stab_binsearch+0xf4>
		} else if (stabs[m].n_value > addr) {
f01072ea:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01072ed:	89 d0                	mov    %edx,%eax
f01072ef:	01 c0                	add    %eax,%eax
f01072f1:	01 d0                	add    %edx,%eax
f01072f3:	c1 e0 02             	shl    $0x2,%eax
f01072f6:	89 c2                	mov    %eax,%edx
f01072f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01072fb:	01 d0                	add    %edx,%eax
f01072fd:	8b 40 08             	mov    0x8(%eax),%eax
f0107300:	3b 45 18             	cmp    0x18(%ebp),%eax
f0107303:	76 16                	jbe    f010731b <stab_binsearch+0xe2>
			*region_right = m - 1;
f0107305:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107308:	8d 50 ff             	lea    -0x1(%eax),%edx
f010730b:	8b 45 10             	mov    0x10(%ebp),%eax
f010730e:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f0107310:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107313:	83 e8 01             	sub    $0x1,%eax
f0107316:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0107319:	eb 12                	jmp    f010732d <stab_binsearch+0xf4>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010731b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010731e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107321:	89 10                	mov    %edx,(%eax)
			l = m;
f0107323:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107326:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f0107329:	83 45 18 01          	addl   $0x1,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010732d:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0107330:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0107333:	0f 8e 22 ff ff ff    	jle    f010725b <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0107339:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010733d:	75 0f                	jne    f010734e <stab_binsearch+0x115>
		*region_right = *region_left - 1;
f010733f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107342:	8b 00                	mov    (%eax),%eax
f0107344:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107347:	8b 45 10             	mov    0x10(%ebp),%eax
f010734a:	89 10                	mov    %edx,(%eax)
f010734c:	eb 3f                	jmp    f010738d <stab_binsearch+0x154>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010734e:	8b 45 10             	mov    0x10(%ebp),%eax
f0107351:	8b 00                	mov    (%eax),%eax
f0107353:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0107356:	eb 04                	jmp    f010735c <stab_binsearch+0x123>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0107358:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f010735c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010735f:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0107361:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0107364:	7d 1f                	jge    f0107385 <stab_binsearch+0x14c>
		     l > *region_left && stabs[l].n_type != type;
f0107366:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107369:	89 d0                	mov    %edx,%eax
f010736b:	01 c0                	add    %eax,%eax
f010736d:	01 d0                	add    %edx,%eax
f010736f:	c1 e0 02             	shl    $0x2,%eax
f0107372:	89 c2                	mov    %eax,%edx
f0107374:	8b 45 08             	mov    0x8(%ebp),%eax
f0107377:	01 d0                	add    %edx,%eax
f0107379:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f010737d:	0f b6 c0             	movzbl %al,%eax
f0107380:	3b 45 14             	cmp    0x14(%ebp),%eax
f0107383:	75 d3                	jne    f0107358 <stab_binsearch+0x11f>
		     l--)
			/* do nothing */;
		*region_left = l;
f0107385:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107388:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010738b:	89 10                	mov    %edx,(%eax)
	}
}
f010738d:	c9                   	leave  
f010738e:	c3                   	ret    

f010738f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010738f:	55                   	push   %ebp
f0107390:	89 e5                	mov    %esp,%ebp
f0107392:	53                   	push   %ebx
f0107393:	83 ec 54             	sub    $0x54,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0107396:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107399:	c7 00 c4 aa 10 f0    	movl   $0xf010aac4,(%eax)
	info->eip_line = 0;
f010739f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073a2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f01073a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073ac:	c7 40 08 c4 aa 10 f0 	movl   $0xf010aac4,0x8(%eax)
	info->eip_fn_namelen = 9;
f01073b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073b6:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f01073bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073c0:	8b 55 08             	mov    0x8(%ebp),%edx
f01073c3:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f01073c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01073c9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01073d0:	81 7d 08 ff ff 7f ef 	cmpl   $0xef7fffff,0x8(%ebp)
f01073d7:	76 21                	jbe    f01073fa <debuginfo_eip+0x6b>
		stabs = __STAB_BEGIN__;
f01073d9:	c7 45 f4 00 b0 10 f0 	movl   $0xf010b000,-0xc(%ebp)
		stab_end = __STAB_END__;
f01073e0:	c7 45 f0 4c 72 11 f0 	movl   $0xf011724c,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01073e7:	c7 45 ec 4d 72 11 f0 	movl   $0xf011724d,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f01073ee:	c7 45 e8 f1 b0 11 f0 	movl   $0xf011b0f1,-0x18(%ebp)
f01073f5:	e9 f8 00 00 00       	jmp    f01074f2 <debuginfo_eip+0x163>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f01073fa:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)USTABDATA, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f0107401:	e8 1c 18 00 00       	call   f0108c22 <cpunum>
f0107406:	6b c0 74             	imul   $0x74,%eax,%eax
f0107409:	05 28 70 24 f0       	add    $0xf0247028,%eax
f010740e:	8b 00                	mov    (%eax),%eax
f0107410:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0107417:	00 
f0107418:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010741f:	00 
f0107420:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0107427:	00 
f0107428:	89 04 24             	mov    %eax,(%esp)
f010742b:	e8 f8 a8 ff ff       	call   f0101d28 <user_mem_check>
f0107430:	85 c0                	test   %eax,%eax
f0107432:	79 0a                	jns    f010743e <debuginfo_eip+0xaf>
f0107434:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107439:	e9 93 03 00 00       	jmp    f01077d1 <debuginfo_eip+0x442>
		stabs = usd->stabs;
f010743e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107441:	8b 00                	mov    (%eax),%eax
f0107443:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f0107446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107449:	8b 40 04             	mov    0x4(%eax),%eax
f010744c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f010744f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107452:	8b 40 08             	mov    0x8(%eax),%eax
f0107455:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f0107458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010745b:	8b 40 0c             	mov    0xc(%eax),%eax
f010745e:	89 45 e8             	mov    %eax,-0x18(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv,stabs, stab_end-stabs, PTE_U) < 0) return -1;
f0107461:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107464:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107467:	29 c2                	sub    %eax,%edx
f0107469:	89 d0                	mov    %edx,%eax
f010746b:	c1 f8 02             	sar    $0x2,%eax
f010746e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0107474:	89 c3                	mov    %eax,%ebx
f0107476:	e8 a7 17 00 00       	call   f0108c22 <cpunum>
f010747b:	6b c0 74             	imul   $0x74,%eax,%eax
f010747e:	05 28 70 24 f0       	add    $0xf0247028,%eax
f0107483:	8b 00                	mov    (%eax),%eax
f0107485:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010748c:	00 
f010748d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0107491:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107494:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107498:	89 04 24             	mov    %eax,(%esp)
f010749b:	e8 88 a8 ff ff       	call   f0101d28 <user_mem_check>
f01074a0:	85 c0                	test   %eax,%eax
f01074a2:	79 0a                	jns    f01074ae <debuginfo_eip+0x11f>
f01074a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01074a9:	e9 23 03 00 00       	jmp    f01077d1 <debuginfo_eip+0x442>
		if(user_mem_check(curenv,stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f01074ae:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01074b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01074b4:	29 c2                	sub    %eax,%edx
f01074b6:	89 d0                	mov    %edx,%eax
f01074b8:	89 c3                	mov    %eax,%ebx
f01074ba:	e8 63 17 00 00       	call   f0108c22 <cpunum>
f01074bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01074c2:	05 28 70 24 f0       	add    $0xf0247028,%eax
f01074c7:	8b 00                	mov    (%eax),%eax
f01074c9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01074d0:	00 
f01074d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01074d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01074d8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01074dc:	89 04 24             	mov    %eax,(%esp)
f01074df:	e8 44 a8 ff ff       	call   f0101d28 <user_mem_check>
f01074e4:	85 c0                	test   %eax,%eax
f01074e6:	79 0a                	jns    f01074f2 <debuginfo_eip+0x163>
f01074e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01074ed:	e9 df 02 00 00       	jmp    f01077d1 <debuginfo_eip+0x442>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01074f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01074f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01074f8:	76 0d                	jbe    f0107507 <debuginfo_eip+0x178>
f01074fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01074fd:	83 e8 01             	sub    $0x1,%eax
f0107500:	0f b6 00             	movzbl (%eax),%eax
f0107503:	84 c0                	test   %al,%al
f0107505:	74 0a                	je     f0107511 <debuginfo_eip+0x182>
		return -1;
f0107507:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010750c:	e9 c0 02 00 00       	jmp    f01077d1 <debuginfo_eip+0x442>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0107511:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	rfile = (stab_end - stabs) - 1;
f0107518:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010751b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010751e:	29 c2                	sub    %eax,%edx
f0107520:	89 d0                	mov    %edx,%eax
f0107522:	c1 f8 02             	sar    $0x2,%eax
f0107525:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010752b:	83 e8 01             	sub    $0x1,%eax
f010752e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0107531:	8b 45 08             	mov    0x8(%ebp),%eax
f0107534:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107538:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
f010753f:	00 
f0107540:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0107543:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107547:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010754a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010754e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107551:	89 04 24             	mov    %eax,(%esp)
f0107554:	e8 e0 fc ff ff       	call   f0107239 <stab_binsearch>
	if (lfile == 0)
f0107559:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010755c:	85 c0                	test   %eax,%eax
f010755e:	75 0a                	jne    f010756a <debuginfo_eip+0x1db>
		return -1;
f0107560:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0107565:	e9 67 02 00 00       	jmp    f01077d1 <debuginfo_eip+0x442>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010756a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010756d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	rfun = rfile;
f0107570:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107573:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0107576:	8b 45 08             	mov    0x8(%ebp),%eax
f0107579:	89 44 24 10          	mov    %eax,0x10(%esp)
f010757d:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
f0107584:	00 
f0107585:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0107588:	89 44 24 08          	mov    %eax,0x8(%esp)
f010758c:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010758f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107593:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107596:	89 04 24             	mov    %eax,(%esp)
f0107599:	e8 9b fc ff ff       	call   f0107239 <stab_binsearch>

	if (lfun <= rfun) {
f010759e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01075a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01075a4:	39 c2                	cmp    %eax,%edx
f01075a6:	7f 7c                	jg     f0107624 <debuginfo_eip+0x295>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01075a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01075ab:	89 c2                	mov    %eax,%edx
f01075ad:	89 d0                	mov    %edx,%eax
f01075af:	01 c0                	add    %eax,%eax
f01075b1:	01 d0                	add    %edx,%eax
f01075b3:	c1 e0 02             	shl    $0x2,%eax
f01075b6:	89 c2                	mov    %eax,%edx
f01075b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01075bb:	01 d0                	add    %edx,%eax
f01075bd:	8b 10                	mov    (%eax),%edx
f01075bf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01075c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01075c5:	29 c1                	sub    %eax,%ecx
f01075c7:	89 c8                	mov    %ecx,%eax
f01075c9:	39 c2                	cmp    %eax,%edx
f01075cb:	73 22                	jae    f01075ef <debuginfo_eip+0x260>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01075cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01075d0:	89 c2                	mov    %eax,%edx
f01075d2:	89 d0                	mov    %edx,%eax
f01075d4:	01 c0                	add    %eax,%eax
f01075d6:	01 d0                	add    %edx,%eax
f01075d8:	c1 e0 02             	shl    $0x2,%eax
f01075db:	89 c2                	mov    %eax,%edx
f01075dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01075e0:	01 d0                	add    %edx,%eax
f01075e2:	8b 10                	mov    (%eax),%edx
f01075e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01075e7:	01 c2                	add    %eax,%edx
f01075e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01075ec:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = stabs[lfun].n_value;
f01075ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01075f2:	89 c2                	mov    %eax,%edx
f01075f4:	89 d0                	mov    %edx,%eax
f01075f6:	01 c0                	add    %eax,%eax
f01075f8:	01 d0                	add    %edx,%eax
f01075fa:	c1 e0 02             	shl    $0x2,%eax
f01075fd:	89 c2                	mov    %eax,%edx
f01075ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107602:	01 d0                	add    %edx,%eax
f0107604:	8b 50 08             	mov    0x8(%eax),%edx
f0107607:	8b 45 0c             	mov    0xc(%ebp),%eax
f010760a:	89 50 10             	mov    %edx,0x10(%eax)
		addr -= info->eip_fn_addr;
f010760d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107610:	8b 40 10             	mov    0x10(%eax),%eax
f0107613:	29 45 08             	sub    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0107616:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107619:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfun;
f010761c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010761f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0107622:	eb 15                	jmp    f0107639 <debuginfo_eip+0x2aa>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0107624:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107627:	8b 55 08             	mov    0x8(%ebp),%edx
f010762a:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f010762d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107630:	89 45 d0             	mov    %eax,-0x30(%ebp)
		rline = rfile;
f0107633:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0107636:	89 45 cc             	mov    %eax,-0x34(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0107639:	8b 45 0c             	mov    0xc(%ebp),%eax
f010763c:	8b 40 08             	mov    0x8(%eax),%eax
f010763f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0107646:	00 
f0107647:	89 04 24             	mov    %eax,(%esp)
f010764a:	e8 da 0a 00 00       	call   f0108129 <strfind>
f010764f:	89 c2                	mov    %eax,%edx
f0107651:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107654:	8b 40 08             	mov    0x8(%eax),%eax
f0107657:	29 c2                	sub    %eax,%edx
f0107659:	8b 45 0c             	mov    0xc(%ebp),%eax
f010765c:	89 50 0c             	mov    %edx,0xc(%eax)
	// Your code here.
	// char* fn_name="";
	// strncpy(fn_name,info->eip_fn_name,info->eip_fn_namelen);
	// fn_name[info->eip_fn_namelen] = '\0';
	// info->eip_fn_name = fn_name;
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010765f:	8b 45 08             	mov    0x8(%ebp),%eax
f0107662:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107666:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
f010766d:	00 
f010766e:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0107671:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107675:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0107678:	89 44 24 04          	mov    %eax,0x4(%esp)
f010767c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010767f:	89 04 24             	mov    %eax,(%esp)
f0107682:	e8 b2 fb ff ff       	call   f0107239 <stab_binsearch>
	if(lline <= rline)
f0107687:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010768a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010768d:	39 c2                	cmp    %eax,%edx
f010768f:	7f 24                	jg     f01076b5 <debuginfo_eip+0x326>
		info->eip_line = stabs[rline].n_desc;
f0107691:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0107694:	89 c2                	mov    %eax,%edx
f0107696:	89 d0                	mov    %edx,%eax
f0107698:	01 c0                	add    %eax,%eax
f010769a:	01 d0                	add    %edx,%eax
f010769c:	c1 e0 02             	shl    $0x2,%eax
f010769f:	89 c2                	mov    %eax,%edx
f01076a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01076a4:	01 d0                	add    %edx,%eax
f01076a6:	0f b7 40 06          	movzwl 0x6(%eax),%eax
f01076aa:	0f b7 d0             	movzwl %ax,%edx
f01076ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01076b0:	89 50 04             	mov    %edx,0x4(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01076b3:	eb 13                	jmp    f01076c8 <debuginfo_eip+0x339>
	// info->eip_fn_name = fn_name;
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline)
		info->eip_line = stabs[rline].n_desc;
	else
		return -1;
f01076b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01076ba:	e9 12 01 00 00       	jmp    f01077d1 <debuginfo_eip+0x442>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01076bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01076c2:	83 e8 01             	sub    $0x1,%eax
f01076c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01076c8:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01076cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01076ce:	39 c2                	cmp    %eax,%edx
f01076d0:	7c 56                	jl     f0107728 <debuginfo_eip+0x399>
	       && stabs[lline].n_type != N_SOL
f01076d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01076d5:	89 c2                	mov    %eax,%edx
f01076d7:	89 d0                	mov    %edx,%eax
f01076d9:	01 c0                	add    %eax,%eax
f01076db:	01 d0                	add    %edx,%eax
f01076dd:	c1 e0 02             	shl    $0x2,%eax
f01076e0:	89 c2                	mov    %eax,%edx
f01076e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01076e5:	01 d0                	add    %edx,%eax
f01076e7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f01076eb:	3c 84                	cmp    $0x84,%al
f01076ed:	74 39                	je     f0107728 <debuginfo_eip+0x399>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01076ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01076f2:	89 c2                	mov    %eax,%edx
f01076f4:	89 d0                	mov    %edx,%eax
f01076f6:	01 c0                	add    %eax,%eax
f01076f8:	01 d0                	add    %edx,%eax
f01076fa:	c1 e0 02             	shl    $0x2,%eax
f01076fd:	89 c2                	mov    %eax,%edx
f01076ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107702:	01 d0                	add    %edx,%eax
f0107704:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f0107708:	3c 64                	cmp    $0x64,%al
f010770a:	75 b3                	jne    f01076bf <debuginfo_eip+0x330>
f010770c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010770f:	89 c2                	mov    %eax,%edx
f0107711:	89 d0                	mov    %edx,%eax
f0107713:	01 c0                	add    %eax,%eax
f0107715:	01 d0                	add    %edx,%eax
f0107717:	c1 e0 02             	shl    $0x2,%eax
f010771a:	89 c2                	mov    %eax,%edx
f010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010771f:	01 d0                	add    %edx,%eax
f0107721:	8b 40 08             	mov    0x8(%eax),%eax
f0107724:	85 c0                	test   %eax,%eax
f0107726:	74 97                	je     f01076bf <debuginfo_eip+0x330>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0107728:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010772b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010772e:	39 c2                	cmp    %eax,%edx
f0107730:	7c 46                	jl     f0107778 <debuginfo_eip+0x3e9>
f0107732:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0107735:	89 c2                	mov    %eax,%edx
f0107737:	89 d0                	mov    %edx,%eax
f0107739:	01 c0                	add    %eax,%eax
f010773b:	01 d0                	add    %edx,%eax
f010773d:	c1 e0 02             	shl    $0x2,%eax
f0107740:	89 c2                	mov    %eax,%edx
f0107742:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107745:	01 d0                	add    %edx,%eax
f0107747:	8b 10                	mov    (%eax),%edx
f0107749:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f010774c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010774f:	29 c1                	sub    %eax,%ecx
f0107751:	89 c8                	mov    %ecx,%eax
f0107753:	39 c2                	cmp    %eax,%edx
f0107755:	73 21                	jae    f0107778 <debuginfo_eip+0x3e9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0107757:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010775a:	89 c2                	mov    %eax,%edx
f010775c:	89 d0                	mov    %edx,%eax
f010775e:	01 c0                	add    %eax,%eax
f0107760:	01 d0                	add    %edx,%eax
f0107762:	c1 e0 02             	shl    $0x2,%eax
f0107765:	89 c2                	mov    %eax,%edx
f0107767:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010776a:	01 d0                	add    %edx,%eax
f010776c:	8b 10                	mov    (%eax),%edx
f010776e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107771:	01 c2                	add    %eax,%edx
f0107773:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107776:	89 10                	mov    %edx,(%eax)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0107778:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010777b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010777e:	39 c2                	cmp    %eax,%edx
f0107780:	7d 4a                	jge    f01077cc <debuginfo_eip+0x43d>
		for (lline = lfun + 1;
f0107782:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0107785:	83 c0 01             	add    $0x1,%eax
f0107788:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010778b:	eb 18                	jmp    f01077a5 <debuginfo_eip+0x416>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010778d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107790:	8b 40 14             	mov    0x14(%eax),%eax
f0107793:	8d 50 01             	lea    0x1(%eax),%edx
f0107796:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107799:	89 50 14             	mov    %edx,0x14(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010779c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010779f:	83 c0 01             	add    $0x1,%eax
f01077a2:	89 45 d0             	mov    %eax,-0x30(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01077a5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01077a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01077ab:	39 c2                	cmp    %eax,%edx
f01077ad:	7d 1d                	jge    f01077cc <debuginfo_eip+0x43d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01077af:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01077b2:	89 c2                	mov    %eax,%edx
f01077b4:	89 d0                	mov    %edx,%eax
f01077b6:	01 c0                	add    %eax,%eax
f01077b8:	01 d0                	add    %edx,%eax
f01077ba:	c1 e0 02             	shl    $0x2,%eax
f01077bd:	89 c2                	mov    %eax,%edx
f01077bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01077c2:	01 d0                	add    %edx,%eax
f01077c4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
f01077c8:	3c a0                	cmp    $0xa0,%al
f01077ca:	74 c1                	je     f010778d <debuginfo_eip+0x3fe>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01077cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01077d1:	83 c4 54             	add    $0x54,%esp
f01077d4:	5b                   	pop    %ebx
f01077d5:	5d                   	pop    %ebp
f01077d6:	c3                   	ret    

f01077d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01077d7:	55                   	push   %ebp
f01077d8:	89 e5                	mov    %esp,%ebp
f01077da:	53                   	push   %ebx
f01077db:	83 ec 34             	sub    $0x34,%esp
f01077de:	8b 45 10             	mov    0x10(%ebp),%eax
f01077e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01077e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01077e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01077ea:	8b 45 18             	mov    0x18(%ebp),%eax
f01077ed:	ba 00 00 00 00       	mov    $0x0,%edx
f01077f2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f01077f5:	77 72                	ja     f0107869 <printnum+0x92>
f01077f7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f01077fa:	72 05                	jb     f0107801 <printnum+0x2a>
f01077fc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f01077ff:	77 68                	ja     f0107869 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0107801:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0107804:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0107807:	8b 45 18             	mov    0x18(%ebp),%eax
f010780a:	ba 00 00 00 00       	mov    $0x0,%edx
f010780f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107813:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107817:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010781a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010781d:	89 04 24             	mov    %eax,(%esp)
f0107820:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107824:	e8 57 18 00 00       	call   f0109080 <__udivdi3>
f0107829:	8b 4d 20             	mov    0x20(%ebp),%ecx
f010782c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0107830:	89 5c 24 14          	mov    %ebx,0x14(%esp)
f0107834:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0107837:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010783b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010783f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107843:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107846:	89 44 24 04          	mov    %eax,0x4(%esp)
f010784a:	8b 45 08             	mov    0x8(%ebp),%eax
f010784d:	89 04 24             	mov    %eax,(%esp)
f0107850:	e8 82 ff ff ff       	call   f01077d7 <printnum>
f0107855:	eb 1c                	jmp    f0107873 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0107857:	8b 45 0c             	mov    0xc(%ebp),%eax
f010785a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010785e:	8b 45 20             	mov    0x20(%ebp),%eax
f0107861:	89 04 24             	mov    %eax,(%esp)
f0107864:	8b 45 08             	mov    0x8(%ebp),%eax
f0107867:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0107869:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
f010786d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f0107871:	7f e4                	jg     f0107857 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0107873:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0107876:	bb 00 00 00 00       	mov    $0x0,%ebx
f010787b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010787e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107881:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0107885:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107889:	89 04 24             	mov    %eax,(%esp)
f010788c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107890:	e8 1b 19 00 00       	call   f01091b0 <__umoddi3>
f0107895:	05 a8 ab 10 f0       	add    $0xf010aba8,%eax
f010789a:	0f b6 00             	movzbl (%eax),%eax
f010789d:	0f be c0             	movsbl %al,%eax
f01078a0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01078a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01078a7:	89 04 24             	mov    %eax,(%esp)
f01078aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01078ad:	ff d0                	call   *%eax
}
f01078af:	83 c4 34             	add    $0x34,%esp
f01078b2:	5b                   	pop    %ebx
f01078b3:	5d                   	pop    %ebp
f01078b4:	c3                   	ret    

f01078b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01078b5:	55                   	push   %ebp
f01078b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01078b8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f01078bc:	7e 14                	jle    f01078d2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
f01078be:	8b 45 08             	mov    0x8(%ebp),%eax
f01078c1:	8b 00                	mov    (%eax),%eax
f01078c3:	8d 48 08             	lea    0x8(%eax),%ecx
f01078c6:	8b 55 08             	mov    0x8(%ebp),%edx
f01078c9:	89 0a                	mov    %ecx,(%edx)
f01078cb:	8b 50 04             	mov    0x4(%eax),%edx
f01078ce:	8b 00                	mov    (%eax),%eax
f01078d0:	eb 30                	jmp    f0107902 <getuint+0x4d>
	else if (lflag)
f01078d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01078d6:	74 16                	je     f01078ee <getuint+0x39>
		return va_arg(*ap, unsigned long);
f01078d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01078db:	8b 00                	mov    (%eax),%eax
f01078dd:	8d 48 04             	lea    0x4(%eax),%ecx
f01078e0:	8b 55 08             	mov    0x8(%ebp),%edx
f01078e3:	89 0a                	mov    %ecx,(%edx)
f01078e5:	8b 00                	mov    (%eax),%eax
f01078e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01078ec:	eb 14                	jmp    f0107902 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
f01078ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01078f1:	8b 00                	mov    (%eax),%eax
f01078f3:	8d 48 04             	lea    0x4(%eax),%ecx
f01078f6:	8b 55 08             	mov    0x8(%ebp),%edx
f01078f9:	89 0a                	mov    %ecx,(%edx)
f01078fb:	8b 00                	mov    (%eax),%eax
f01078fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0107902:	5d                   	pop    %ebp
f0107903:	c3                   	ret    

f0107904 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0107904:	55                   	push   %ebp
f0107905:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0107907:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f010790b:	7e 14                	jle    f0107921 <getint+0x1d>
		return va_arg(*ap, long long);
f010790d:	8b 45 08             	mov    0x8(%ebp),%eax
f0107910:	8b 00                	mov    (%eax),%eax
f0107912:	8d 48 08             	lea    0x8(%eax),%ecx
f0107915:	8b 55 08             	mov    0x8(%ebp),%edx
f0107918:	89 0a                	mov    %ecx,(%edx)
f010791a:	8b 50 04             	mov    0x4(%eax),%edx
f010791d:	8b 00                	mov    (%eax),%eax
f010791f:	eb 28                	jmp    f0107949 <getint+0x45>
	else if (lflag)
f0107921:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107925:	74 12                	je     f0107939 <getint+0x35>
		return va_arg(*ap, long);
f0107927:	8b 45 08             	mov    0x8(%ebp),%eax
f010792a:	8b 00                	mov    (%eax),%eax
f010792c:	8d 48 04             	lea    0x4(%eax),%ecx
f010792f:	8b 55 08             	mov    0x8(%ebp),%edx
f0107932:	89 0a                	mov    %ecx,(%edx)
f0107934:	8b 00                	mov    (%eax),%eax
f0107936:	99                   	cltd   
f0107937:	eb 10                	jmp    f0107949 <getint+0x45>
	else
		return va_arg(*ap, int);
f0107939:	8b 45 08             	mov    0x8(%ebp),%eax
f010793c:	8b 00                	mov    (%eax),%eax
f010793e:	8d 48 04             	lea    0x4(%eax),%ecx
f0107941:	8b 55 08             	mov    0x8(%ebp),%edx
f0107944:	89 0a                	mov    %ecx,(%edx)
f0107946:	8b 00                	mov    (%eax),%eax
f0107948:	99                   	cltd   
}
f0107949:	5d                   	pop    %ebp
f010794a:	c3                   	ret    

f010794b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010794b:	55                   	push   %ebp
f010794c:	89 e5                	mov    %esp,%ebp
f010794e:	56                   	push   %esi
f010794f:	53                   	push   %ebx
f0107950:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0107953:	eb 18                	jmp    f010796d <vprintfmt+0x22>
			if (ch == '\0')
f0107955:	85 db                	test   %ebx,%ebx
f0107957:	75 05                	jne    f010795e <vprintfmt+0x13>
				return;
f0107959:	e9 cc 03 00 00       	jmp    f0107d2a <vprintfmt+0x3df>
			putch(ch, putdat);
f010795e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107961:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107965:	89 1c 24             	mov    %ebx,(%esp)
f0107968:	8b 45 08             	mov    0x8(%ebp),%eax
f010796b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010796d:	8b 45 10             	mov    0x10(%ebp),%eax
f0107970:	8d 50 01             	lea    0x1(%eax),%edx
f0107973:	89 55 10             	mov    %edx,0x10(%ebp)
f0107976:	0f b6 00             	movzbl (%eax),%eax
f0107979:	0f b6 d8             	movzbl %al,%ebx
f010797c:	83 fb 25             	cmp    $0x25,%ebx
f010797f:	75 d4                	jne    f0107955 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0107981:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f0107985:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f010798c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0107993:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f010799a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01079a1:	8b 45 10             	mov    0x10(%ebp),%eax
f01079a4:	8d 50 01             	lea    0x1(%eax),%edx
f01079a7:	89 55 10             	mov    %edx,0x10(%ebp)
f01079aa:	0f b6 00             	movzbl (%eax),%eax
f01079ad:	0f b6 d8             	movzbl %al,%ebx
f01079b0:	8d 43 dd             	lea    -0x23(%ebx),%eax
f01079b3:	83 f8 55             	cmp    $0x55,%eax
f01079b6:	0f 87 3d 03 00 00    	ja     f0107cf9 <vprintfmt+0x3ae>
f01079bc:	8b 04 85 cc ab 10 f0 	mov    -0xfef5434(,%eax,4),%eax
f01079c3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f01079c5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f01079c9:	eb d6                	jmp    f01079a1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01079cb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f01079cf:	eb d0                	jmp    f01079a1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01079d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f01079d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01079db:	89 d0                	mov    %edx,%eax
f01079dd:	c1 e0 02             	shl    $0x2,%eax
f01079e0:	01 d0                	add    %edx,%eax
f01079e2:	01 c0                	add    %eax,%eax
f01079e4:	01 d8                	add    %ebx,%eax
f01079e6:	83 e8 30             	sub    $0x30,%eax
f01079e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f01079ec:	8b 45 10             	mov    0x10(%ebp),%eax
f01079ef:	0f b6 00             	movzbl (%eax),%eax
f01079f2:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f01079f5:	83 fb 2f             	cmp    $0x2f,%ebx
f01079f8:	7e 0b                	jle    f0107a05 <vprintfmt+0xba>
f01079fa:	83 fb 39             	cmp    $0x39,%ebx
f01079fd:	7f 06                	jg     f0107a05 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01079ff:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0107a03:	eb d3                	jmp    f01079d8 <vprintfmt+0x8d>
			goto process_precision;
f0107a05:	eb 33                	jmp    f0107a3a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
f0107a07:	8b 45 14             	mov    0x14(%ebp),%eax
f0107a0a:	8d 50 04             	lea    0x4(%eax),%edx
f0107a0d:	89 55 14             	mov    %edx,0x14(%ebp)
f0107a10:	8b 00                	mov    (%eax),%eax
f0107a12:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f0107a15:	eb 23                	jmp    f0107a3a <vprintfmt+0xef>

		case '.':
			if (width < 0)
f0107a17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107a1b:	79 0c                	jns    f0107a29 <vprintfmt+0xde>
				width = 0;
f0107a1d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f0107a24:	e9 78 ff ff ff       	jmp    f01079a1 <vprintfmt+0x56>
f0107a29:	e9 73 ff ff ff       	jmp    f01079a1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
f0107a2e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0107a35:	e9 67 ff ff ff       	jmp    f01079a1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
f0107a3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107a3e:	79 12                	jns    f0107a52 <vprintfmt+0x107>
				width = precision, precision = -1;
f0107a40:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107a43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0107a46:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f0107a4d:	e9 4f ff ff ff       	jmp    f01079a1 <vprintfmt+0x56>
f0107a52:	e9 4a ff ff ff       	jmp    f01079a1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0107a57:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
f0107a5b:	e9 41 ff ff ff       	jmp    f01079a1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0107a60:	8b 45 14             	mov    0x14(%ebp),%eax
f0107a63:	8d 50 04             	lea    0x4(%eax),%edx
f0107a66:	89 55 14             	mov    %edx,0x14(%ebp)
f0107a69:	8b 00                	mov    (%eax),%eax
f0107a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107a6e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107a72:	89 04 24             	mov    %eax,(%esp)
f0107a75:	8b 45 08             	mov    0x8(%ebp),%eax
f0107a78:	ff d0                	call   *%eax
			break;
f0107a7a:	e9 a5 02 00 00       	jmp    f0107d24 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0107a7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0107a82:	8d 50 04             	lea    0x4(%eax),%edx
f0107a85:	89 55 14             	mov    %edx,0x14(%ebp)
f0107a88:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f0107a8a:	85 db                	test   %ebx,%ebx
f0107a8c:	79 02                	jns    f0107a90 <vprintfmt+0x145>
				err = -err;
f0107a8e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0107a90:	83 fb 09             	cmp    $0x9,%ebx
f0107a93:	7f 0b                	jg     f0107aa0 <vprintfmt+0x155>
f0107a95:	8b 34 9d 80 ab 10 f0 	mov    -0xfef5480(,%ebx,4),%esi
f0107a9c:	85 f6                	test   %esi,%esi
f0107a9e:	75 23                	jne    f0107ac3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0107aa0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0107aa4:	c7 44 24 08 b9 ab 10 	movl   $0xf010abb9,0x8(%esp)
f0107aab:	f0 
f0107aac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ab3:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ab6:	89 04 24             	mov    %eax,(%esp)
f0107ab9:	e8 73 02 00 00       	call   f0107d31 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
f0107abe:	e9 61 02 00 00       	jmp    f0107d24 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0107ac3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107ac7:	c7 44 24 08 c2 ab 10 	movl   $0xf010abc2,0x8(%esp)
f0107ace:	f0 
f0107acf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ad6:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ad9:	89 04 24             	mov    %eax,(%esp)
f0107adc:	e8 50 02 00 00       	call   f0107d31 <printfmt>
			break;
f0107ae1:	e9 3e 02 00 00       	jmp    f0107d24 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0107ae6:	8b 45 14             	mov    0x14(%ebp),%eax
f0107ae9:	8d 50 04             	lea    0x4(%eax),%edx
f0107aec:	89 55 14             	mov    %edx,0x14(%ebp)
f0107aef:	8b 30                	mov    (%eax),%esi
f0107af1:	85 f6                	test   %esi,%esi
f0107af3:	75 05                	jne    f0107afa <vprintfmt+0x1af>
				p = "(null)";
f0107af5:	be c5 ab 10 f0       	mov    $0xf010abc5,%esi
			if (width > 0 && padc != '-')
f0107afa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107afe:	7e 37                	jle    f0107b37 <vprintfmt+0x1ec>
f0107b00:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f0107b04:	74 31                	je     f0107b37 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
f0107b06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107b09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b0d:	89 34 24             	mov    %esi,(%esp)
f0107b10:	e8 26 04 00 00       	call   f0107f3b <strnlen>
f0107b15:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f0107b18:	eb 17                	jmp    f0107b31 <vprintfmt+0x1e6>
					putch(padc, putdat);
f0107b1a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f0107b1e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107b21:	89 54 24 04          	mov    %edx,0x4(%esp)
f0107b25:	89 04 24             	mov    %eax,(%esp)
f0107b28:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b2b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0107b2d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0107b31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107b35:	7f e3                	jg     f0107b1a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0107b37:	eb 38                	jmp    f0107b71 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
f0107b39:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0107b3d:	74 1f                	je     f0107b5e <vprintfmt+0x213>
f0107b3f:	83 fb 1f             	cmp    $0x1f,%ebx
f0107b42:	7e 05                	jle    f0107b49 <vprintfmt+0x1fe>
f0107b44:	83 fb 7e             	cmp    $0x7e,%ebx
f0107b47:	7e 15                	jle    f0107b5e <vprintfmt+0x213>
					putch('?', putdat);
f0107b49:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b50:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0107b57:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b5a:	ff d0                	call   *%eax
f0107b5c:	eb 0f                	jmp    f0107b6d <vprintfmt+0x222>
				else
					putch(ch, putdat);
f0107b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b65:	89 1c 24             	mov    %ebx,(%esp)
f0107b68:	8b 45 08             	mov    0x8(%ebp),%eax
f0107b6b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0107b6d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0107b71:	89 f0                	mov    %esi,%eax
f0107b73:	8d 70 01             	lea    0x1(%eax),%esi
f0107b76:	0f b6 00             	movzbl (%eax),%eax
f0107b79:	0f be d8             	movsbl %al,%ebx
f0107b7c:	85 db                	test   %ebx,%ebx
f0107b7e:	74 10                	je     f0107b90 <vprintfmt+0x245>
f0107b80:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0107b84:	78 b3                	js     f0107b39 <vprintfmt+0x1ee>
f0107b86:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0107b8a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0107b8e:	79 a9                	jns    f0107b39 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0107b90:	eb 17                	jmp    f0107ba9 <vprintfmt+0x25e>
				putch(' ', putdat);
f0107b92:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107b95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107b99:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0107ba0:	8b 45 08             	mov    0x8(%ebp),%eax
f0107ba3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0107ba5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0107ba9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0107bad:	7f e3                	jg     f0107b92 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
f0107baf:	e9 70 01 00 00       	jmp    f0107d24 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0107bb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bbb:	8d 45 14             	lea    0x14(%ebp),%eax
f0107bbe:	89 04 24             	mov    %eax,(%esp)
f0107bc1:	e8 3e fd ff ff       	call   f0107904 <getint>
f0107bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107bc9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f0107bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107bcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107bd2:	85 d2                	test   %edx,%edx
f0107bd4:	79 26                	jns    f0107bfc <vprintfmt+0x2b1>
				putch('-', putdat);
f0107bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107bdd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0107be4:	8b 45 08             	mov    0x8(%ebp),%eax
f0107be7:	ff d0                	call   *%eax
				num = -(long long) num;
f0107be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107bec:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107bef:	f7 d8                	neg    %eax
f0107bf1:	83 d2 00             	adc    $0x0,%edx
f0107bf4:	f7 da                	neg    %edx
f0107bf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107bf9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f0107bfc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0107c03:	e9 a8 00 00 00       	jmp    f0107cb0 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0107c08:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c0f:	8d 45 14             	lea    0x14(%ebp),%eax
f0107c12:	89 04 24             	mov    %eax,(%esp)
f0107c15:	e8 9b fc ff ff       	call   f01078b5 <getuint>
f0107c1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107c1d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f0107c20:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0107c27:	e9 84 00 00 00       	jmp    f0107cb0 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0107c2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c33:	8d 45 14             	lea    0x14(%ebp),%eax
f0107c36:	89 04 24             	mov    %eax,(%esp)
f0107c39:	e8 77 fc ff ff       	call   f01078b5 <getuint>
f0107c3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107c41:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
f0107c44:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
f0107c4b:	eb 63                	jmp    f0107cb0 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0107c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c54:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0107c5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c5e:	ff d0                	call   *%eax
			putch('x', putdat);
f0107c60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107c63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c67:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0107c6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0107c71:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0107c73:	8b 45 14             	mov    0x14(%ebp),%eax
f0107c76:	8d 50 04             	lea    0x4(%eax),%edx
f0107c79:	89 55 14             	mov    %edx,0x14(%ebp)
f0107c7c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0107c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107c81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0107c88:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f0107c8f:	eb 1f                	jmp    f0107cb0 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0107c91:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0107c94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c98:	8d 45 14             	lea    0x14(%ebp),%eax
f0107c9b:	89 04 24             	mov    %eax,(%esp)
f0107c9e:	e8 12 fc ff ff       	call   f01078b5 <getuint>
f0107ca3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107ca6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f0107ca9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f0107cb0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f0107cb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107cb7:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107cbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107cbe:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107cc2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107cc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0107ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107cd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0107cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107cdb:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cde:	89 04 24             	mov    %eax,(%esp)
f0107ce1:	e8 f1 fa ff ff       	call   f01077d7 <printnum>
			break;
f0107ce6:	eb 3c                	jmp    f0107d24 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0107ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107cef:	89 1c 24             	mov    %ebx,(%esp)
f0107cf2:	8b 45 08             	mov    0x8(%ebp),%eax
f0107cf5:	ff d0                	call   *%eax
			break;
f0107cf7:	eb 2b                	jmp    f0107d24 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0107cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d00:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0107d07:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d0a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
f0107d0c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f0107d10:	eb 04                	jmp    f0107d16 <vprintfmt+0x3cb>
f0107d12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f0107d16:	8b 45 10             	mov    0x10(%ebp),%eax
f0107d19:	83 e8 01             	sub    $0x1,%eax
f0107d1c:	0f b6 00             	movzbl (%eax),%eax
f0107d1f:	3c 25                	cmp    $0x25,%al
f0107d21:	75 ef                	jne    f0107d12 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
f0107d23:	90                   	nop
		}
	}
f0107d24:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0107d25:	e9 43 fc ff ff       	jmp    f010796d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0107d2a:	83 c4 40             	add    $0x40,%esp
f0107d2d:	5b                   	pop    %ebx
f0107d2e:	5e                   	pop    %esi
f0107d2f:	5d                   	pop    %ebp
f0107d30:	c3                   	ret    

f0107d31 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0107d31:	55                   	push   %ebp
f0107d32:	89 e5                	mov    %esp,%ebp
f0107d34:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
f0107d37:	8d 45 14             	lea    0x14(%ebp),%eax
f0107d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f0107d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107d40:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107d44:	8b 45 10             	mov    0x10(%ebp),%eax
f0107d47:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107d52:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d55:	89 04 24             	mov    %eax,(%esp)
f0107d58:	e8 ee fb ff ff       	call   f010794b <vprintfmt>
	va_end(ap);
}
f0107d5d:	c9                   	leave  
f0107d5e:	c3                   	ret    

f0107d5f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0107d5f:	55                   	push   %ebp
f0107d60:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f0107d62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d65:	8b 40 08             	mov    0x8(%eax),%eax
f0107d68:	8d 50 01             	lea    0x1(%eax),%edx
f0107d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d6e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f0107d71:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d74:	8b 10                	mov    (%eax),%edx
f0107d76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d79:	8b 40 04             	mov    0x4(%eax),%eax
f0107d7c:	39 c2                	cmp    %eax,%edx
f0107d7e:	73 12                	jae    f0107d92 <sprintputch+0x33>
		*b->buf++ = ch;
f0107d80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107d83:	8b 00                	mov    (%eax),%eax
f0107d85:	8d 48 01             	lea    0x1(%eax),%ecx
f0107d88:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107d8b:	89 0a                	mov    %ecx,(%edx)
f0107d8d:	8b 55 08             	mov    0x8(%ebp),%edx
f0107d90:	88 10                	mov    %dl,(%eax)
}
f0107d92:	5d                   	pop    %ebp
f0107d93:	c3                   	ret    

f0107d94 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0107d94:	55                   	push   %ebp
f0107d95:	89 e5                	mov    %esp,%ebp
f0107d97:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f0107d9a:	8b 45 08             	mov    0x8(%ebp),%eax
f0107d9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107da0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107da3:	8d 50 ff             	lea    -0x1(%eax),%edx
f0107da6:	8b 45 08             	mov    0x8(%ebp),%eax
f0107da9:	01 d0                	add    %edx,%eax
f0107dab:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0107dae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0107db5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0107db9:	74 06                	je     f0107dc1 <vsnprintf+0x2d>
f0107dbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107dbf:	7f 07                	jg     f0107dc8 <vsnprintf+0x34>
		return -E_INVAL;
f0107dc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0107dc6:	eb 2a                	jmp    f0107df2 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0107dc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0107dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107dcf:	8b 45 10             	mov    0x10(%ebp),%eax
f0107dd2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107dd6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0107dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ddd:	c7 04 24 5f 7d 10 f0 	movl   $0xf0107d5f,(%esp)
f0107de4:	e8 62 fb ff ff       	call   f010794b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0107de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107dec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0107def:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0107df2:	c9                   	leave  
f0107df3:	c3                   	ret    

f0107df4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0107df4:	55                   	push   %ebp
f0107df5:	89 e5                	mov    %esp,%ebp
f0107df7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0107dfa:	8d 45 14             	lea    0x14(%ebp),%eax
f0107dfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f0107e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0107e03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107e07:	8b 45 10             	mov    0x10(%ebp),%eax
f0107e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107e11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e15:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e18:	89 04 24             	mov    %eax,(%esp)
f0107e1b:	e8 74 ff ff ff       	call   f0107d94 <vsnprintf>
f0107e20:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
f0107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0107e26:	c9                   	leave  
f0107e27:	c3                   	ret    

f0107e28 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0107e28:	55                   	push   %ebp
f0107e29:	89 e5                	mov    %esp,%ebp
f0107e2b:	83 ec 28             	sub    $0x28,%esp
	int i, c, echoing;

	if (prompt != NULL)
f0107e2e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0107e32:	74 13                	je     f0107e47 <readline+0x1f>
		cprintf("%s", prompt);
f0107e34:	8b 45 08             	mov    0x8(%ebp),%eax
f0107e37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e3b:	c7 04 24 24 ad 10 f0 	movl   $0xf010ad24,(%esp)
f0107e42:	e8 69 d1 ff ff       	call   f0104fb0 <cprintf>

	i = 0;
f0107e47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// echoing = iscons(0);
	echoing = 1;
f0107e4e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	while (1) {
		c = getchar();
f0107e55:	e8 59 8d ff ff       	call   f0100bb3 <getchar>
f0107e5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
f0107e5d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0107e61:	79 1d                	jns    f0107e80 <readline+0x58>
			cprintf("read error: %e\n", c);
f0107e63:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107e66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107e6a:	c7 04 24 27 ad 10 f0 	movl   $0xf010ad27,(%esp)
f0107e71:	e8 3a d1 ff ff       	call   f0104fb0 <cprintf>
			return NULL;
f0107e76:	b8 00 00 00 00       	mov    $0x0,%eax
f0107e7b:	e9 93 00 00 00       	jmp    f0107f13 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0107e80:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
f0107e84:	74 06                	je     f0107e8c <readline+0x64>
f0107e86:	83 7d ec 7f          	cmpl   $0x7f,-0x14(%ebp)
f0107e8a:	75 1e                	jne    f0107eaa <readline+0x82>
f0107e8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0107e90:	7e 18                	jle    f0107eaa <readline+0x82>
			if (echoing)
f0107e92:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0107e96:	74 0c                	je     f0107ea4 <readline+0x7c>
				cputchar('\b');
f0107e98:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0107e9f:	e8 fc 8c ff ff       	call   f0100ba0 <cputchar>
			i--;
f0107ea4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
f0107ea8:	eb 64                	jmp    f0107f0e <readline+0xe6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0107eaa:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
f0107eae:	7e 2e                	jle    f0107ede <readline+0xb6>
f0107eb0:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f0107eb7:	7f 25                	jg     f0107ede <readline+0xb6>
			if (echoing)
f0107eb9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0107ebd:	74 0b                	je     f0107eca <readline+0xa2>
				cputchar(c);
f0107ebf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0107ec2:	89 04 24             	mov    %eax,(%esp)
f0107ec5:	e8 d6 8c ff ff       	call   f0100ba0 <cputchar>
			buf[i++] = c;
f0107eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ecd:	8d 50 01             	lea    0x1(%eax),%edx
f0107ed0:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107ed3:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0107ed6:	88 90 e0 6a 24 f0    	mov    %dl,-0xfdb9520(%eax)
f0107edc:	eb 30                	jmp    f0107f0e <readline+0xe6>
		} else if (c == '\n' || c == '\r') {
f0107ede:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
f0107ee2:	74 06                	je     f0107eea <readline+0xc2>
f0107ee4:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
f0107ee8:	75 24                	jne    f0107f0e <readline+0xe6>
			if (echoing)
f0107eea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0107eee:	74 0c                	je     f0107efc <readline+0xd4>
				cputchar('\n');
f0107ef0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0107ef7:	e8 a4 8c ff ff       	call   f0100ba0 <cputchar>
			buf[i] = 0;
f0107efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107eff:	05 e0 6a 24 f0       	add    $0xf0246ae0,%eax
f0107f04:	c6 00 00             	movb   $0x0,(%eax)
			return buf;
f0107f07:	b8 e0 6a 24 f0       	mov    $0xf0246ae0,%eax
f0107f0c:	eb 05                	jmp    f0107f13 <readline+0xeb>
		}
	}
f0107f0e:	e9 42 ff ff ff       	jmp    f0107e55 <readline+0x2d>
}
f0107f13:	c9                   	leave  
f0107f14:	c3                   	ret    

f0107f15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0107f15:	55                   	push   %ebp
f0107f16:	89 e5                	mov    %esp,%ebp
f0107f18:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f0107f1b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0107f22:	eb 08                	jmp    f0107f2c <strlen+0x17>
		n++;
f0107f24:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0107f28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107f2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f2f:	0f b6 00             	movzbl (%eax),%eax
f0107f32:	84 c0                	test   %al,%al
f0107f34:	75 ee                	jne    f0107f24 <strlen+0xf>
		n++;
	return n;
f0107f36:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0107f39:	c9                   	leave  
f0107f3a:	c3                   	ret    

f0107f3b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0107f3b:	55                   	push   %ebp
f0107f3c:	89 e5                	mov    %esp,%ebp
f0107f3e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107f41:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0107f48:	eb 0c                	jmp    f0107f56 <strnlen+0x1b>
		n++;
f0107f4a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0107f4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0107f52:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
f0107f56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0107f5a:	74 0a                	je     f0107f66 <strnlen+0x2b>
f0107f5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f5f:	0f b6 00             	movzbl (%eax),%eax
f0107f62:	84 c0                	test   %al,%al
f0107f64:	75 e4                	jne    f0107f4a <strnlen+0xf>
		n++;
	return n;
f0107f66:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0107f69:	c9                   	leave  
f0107f6a:	c3                   	ret    

f0107f6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0107f6b:	55                   	push   %ebp
f0107f6c:	89 e5                	mov    %esp,%ebp
f0107f6e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f0107f71:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f74:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f0107f77:	90                   	nop
f0107f78:	8b 45 08             	mov    0x8(%ebp),%eax
f0107f7b:	8d 50 01             	lea    0x1(%eax),%edx
f0107f7e:	89 55 08             	mov    %edx,0x8(%ebp)
f0107f81:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107f84:	8d 4a 01             	lea    0x1(%edx),%ecx
f0107f87:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f0107f8a:	0f b6 12             	movzbl (%edx),%edx
f0107f8d:	88 10                	mov    %dl,(%eax)
f0107f8f:	0f b6 00             	movzbl (%eax),%eax
f0107f92:	84 c0                	test   %al,%al
f0107f94:	75 e2                	jne    f0107f78 <strcpy+0xd>
		/* do nothing */;
	return ret;
f0107f96:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0107f99:	c9                   	leave  
f0107f9a:	c3                   	ret    

f0107f9b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0107f9b:	55                   	push   %ebp
f0107f9c:	89 e5                	mov    %esp,%ebp
f0107f9e:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
f0107fa1:	8b 45 08             	mov    0x8(%ebp),%eax
f0107fa4:	89 04 24             	mov    %eax,(%esp)
f0107fa7:	e8 69 ff ff ff       	call   f0107f15 <strlen>
f0107fac:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
f0107faf:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0107fb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0107fb5:	01 c2                	add    %eax,%edx
f0107fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107fba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107fbe:	89 14 24             	mov    %edx,(%esp)
f0107fc1:	e8 a5 ff ff ff       	call   f0107f6b <strcpy>
	return dst;
f0107fc6:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0107fc9:	c9                   	leave  
f0107fca:	c3                   	ret    

f0107fcb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0107fcb:	55                   	push   %ebp
f0107fcc:	89 e5                	mov    %esp,%ebp
f0107fce:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
f0107fd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0107fd4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f0107fd7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0107fde:	eb 23                	jmp    f0108003 <strncpy+0x38>
		*dst++ = *src;
f0107fe0:	8b 45 08             	mov    0x8(%ebp),%eax
f0107fe3:	8d 50 01             	lea    0x1(%eax),%edx
f0107fe6:	89 55 08             	mov    %edx,0x8(%ebp)
f0107fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0107fec:	0f b6 12             	movzbl (%edx),%edx
f0107fef:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0107ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0107ff4:	0f b6 00             	movzbl (%eax),%eax
f0107ff7:	84 c0                	test   %al,%al
f0107ff9:	74 04                	je     f0107fff <strncpy+0x34>
			src++;
f0107ffb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0107fff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108003:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108006:	3b 45 10             	cmp    0x10(%ebp),%eax
f0108009:	72 d5                	jb     f0107fe0 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f010800b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f010800e:	c9                   	leave  
f010800f:	c3                   	ret    

f0108010 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0108010:	55                   	push   %ebp
f0108011:	89 e5                	mov    %esp,%ebp
f0108013:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f0108016:	8b 45 08             	mov    0x8(%ebp),%eax
f0108019:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f010801c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108020:	74 33                	je     f0108055 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
f0108022:	eb 17                	jmp    f010803b <strlcpy+0x2b>
			*dst++ = *src++;
f0108024:	8b 45 08             	mov    0x8(%ebp),%eax
f0108027:	8d 50 01             	lea    0x1(%eax),%edx
f010802a:	89 55 08             	mov    %edx,0x8(%ebp)
f010802d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108030:	8d 4a 01             	lea    0x1(%edx),%ecx
f0108033:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f0108036:	0f b6 12             	movzbl (%edx),%edx
f0108039:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010803b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f010803f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0108043:	74 0a                	je     f010804f <strlcpy+0x3f>
f0108045:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108048:	0f b6 00             	movzbl (%eax),%eax
f010804b:	84 c0                	test   %al,%al
f010804d:	75 d5                	jne    f0108024 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f010804f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108052:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0108055:	8b 55 08             	mov    0x8(%ebp),%edx
f0108058:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010805b:	29 c2                	sub    %eax,%edx
f010805d:	89 d0                	mov    %edx,%eax
}
f010805f:	c9                   	leave  
f0108060:	c3                   	ret    

f0108061 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0108061:	55                   	push   %ebp
f0108062:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f0108064:	eb 08                	jmp    f010806e <strcmp+0xd>
		p++, q++;
f0108066:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f010806a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010806e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108071:	0f b6 00             	movzbl (%eax),%eax
f0108074:	84 c0                	test   %al,%al
f0108076:	74 10                	je     f0108088 <strcmp+0x27>
f0108078:	8b 45 08             	mov    0x8(%ebp),%eax
f010807b:	0f b6 10             	movzbl (%eax),%edx
f010807e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108081:	0f b6 00             	movzbl (%eax),%eax
f0108084:	38 c2                	cmp    %al,%dl
f0108086:	74 de                	je     f0108066 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0108088:	8b 45 08             	mov    0x8(%ebp),%eax
f010808b:	0f b6 00             	movzbl (%eax),%eax
f010808e:	0f b6 d0             	movzbl %al,%edx
f0108091:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108094:	0f b6 00             	movzbl (%eax),%eax
f0108097:	0f b6 c0             	movzbl %al,%eax
f010809a:	29 c2                	sub    %eax,%edx
f010809c:	89 d0                	mov    %edx,%eax
}
f010809e:	5d                   	pop    %ebp
f010809f:	c3                   	ret    

f01080a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01080a0:	55                   	push   %ebp
f01080a1:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f01080a3:	eb 0c                	jmp    f01080b1 <strncmp+0x11>
		n--, p++, q++;
f01080a5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
f01080a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01080ad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01080b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01080b5:	74 1a                	je     f01080d1 <strncmp+0x31>
f01080b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01080ba:	0f b6 00             	movzbl (%eax),%eax
f01080bd:	84 c0                	test   %al,%al
f01080bf:	74 10                	je     f01080d1 <strncmp+0x31>
f01080c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01080c4:	0f b6 10             	movzbl (%eax),%edx
f01080c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01080ca:	0f b6 00             	movzbl (%eax),%eax
f01080cd:	38 c2                	cmp    %al,%dl
f01080cf:	74 d4                	je     f01080a5 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f01080d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01080d5:	75 07                	jne    f01080de <strncmp+0x3e>
		return 0;
f01080d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01080dc:	eb 16                	jmp    f01080f4 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01080de:	8b 45 08             	mov    0x8(%ebp),%eax
f01080e1:	0f b6 00             	movzbl (%eax),%eax
f01080e4:	0f b6 d0             	movzbl %al,%edx
f01080e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01080ea:	0f b6 00             	movzbl (%eax),%eax
f01080ed:	0f b6 c0             	movzbl %al,%eax
f01080f0:	29 c2                	sub    %eax,%edx
f01080f2:	89 d0                	mov    %edx,%eax
}
f01080f4:	5d                   	pop    %ebp
f01080f5:	c3                   	ret    

f01080f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01080f6:	55                   	push   %ebp
f01080f7:	89 e5                	mov    %esp,%ebp
f01080f9:	83 ec 04             	sub    $0x4,%esp
f01080fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01080ff:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0108102:	eb 14                	jmp    f0108118 <strchr+0x22>
		if (*s == c)
f0108104:	8b 45 08             	mov    0x8(%ebp),%eax
f0108107:	0f b6 00             	movzbl (%eax),%eax
f010810a:	3a 45 fc             	cmp    -0x4(%ebp),%al
f010810d:	75 05                	jne    f0108114 <strchr+0x1e>
			return (char *) s;
f010810f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108112:	eb 13                	jmp    f0108127 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0108114:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108118:	8b 45 08             	mov    0x8(%ebp),%eax
f010811b:	0f b6 00             	movzbl (%eax),%eax
f010811e:	84 c0                	test   %al,%al
f0108120:	75 e2                	jne    f0108104 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f0108122:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108127:	c9                   	leave  
f0108128:	c3                   	ret    

f0108129 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0108129:	55                   	push   %ebp
f010812a:	89 e5                	mov    %esp,%ebp
f010812c:	83 ec 04             	sub    $0x4,%esp
f010812f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108132:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0108135:	eb 11                	jmp    f0108148 <strfind+0x1f>
		if (*s == c)
f0108137:	8b 45 08             	mov    0x8(%ebp),%eax
f010813a:	0f b6 00             	movzbl (%eax),%eax
f010813d:	3a 45 fc             	cmp    -0x4(%ebp),%al
f0108140:	75 02                	jne    f0108144 <strfind+0x1b>
			break;
f0108142:	eb 0e                	jmp    f0108152 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0108144:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108148:	8b 45 08             	mov    0x8(%ebp),%eax
f010814b:	0f b6 00             	movzbl (%eax),%eax
f010814e:	84 c0                	test   %al,%al
f0108150:	75 e5                	jne    f0108137 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
f0108152:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108155:	c9                   	leave  
f0108156:	c3                   	ret    

f0108157 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0108157:	55                   	push   %ebp
f0108158:	89 e5                	mov    %esp,%ebp
f010815a:	57                   	push   %edi
	char *p;

	if (n == 0)
f010815b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010815f:	75 05                	jne    f0108166 <memset+0xf>
		return v;
f0108161:	8b 45 08             	mov    0x8(%ebp),%eax
f0108164:	eb 5c                	jmp    f01081c2 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
f0108166:	8b 45 08             	mov    0x8(%ebp),%eax
f0108169:	83 e0 03             	and    $0x3,%eax
f010816c:	85 c0                	test   %eax,%eax
f010816e:	75 41                	jne    f01081b1 <memset+0x5a>
f0108170:	8b 45 10             	mov    0x10(%ebp),%eax
f0108173:	83 e0 03             	and    $0x3,%eax
f0108176:	85 c0                	test   %eax,%eax
f0108178:	75 37                	jne    f01081b1 <memset+0x5a>
		c &= 0xFF;
f010817a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0108181:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108184:	c1 e0 18             	shl    $0x18,%eax
f0108187:	89 c2                	mov    %eax,%edx
f0108189:	8b 45 0c             	mov    0xc(%ebp),%eax
f010818c:	c1 e0 10             	shl    $0x10,%eax
f010818f:	09 c2                	or     %eax,%edx
f0108191:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108194:	c1 e0 08             	shl    $0x8,%eax
f0108197:	09 d0                	or     %edx,%eax
f0108199:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010819c:	8b 45 10             	mov    0x10(%ebp),%eax
f010819f:	c1 e8 02             	shr    $0x2,%eax
f01081a2:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01081a4:	8b 55 08             	mov    0x8(%ebp),%edx
f01081a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01081aa:	89 d7                	mov    %edx,%edi
f01081ac:	fc                   	cld    
f01081ad:	f3 ab                	rep stos %eax,%es:(%edi)
f01081af:	eb 0e                	jmp    f01081bf <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01081b1:	8b 55 08             	mov    0x8(%ebp),%edx
f01081b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01081b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01081ba:	89 d7                	mov    %edx,%edi
f01081bc:	fc                   	cld    
f01081bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
f01081bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01081c2:	5f                   	pop    %edi
f01081c3:	5d                   	pop    %ebp
f01081c4:	c3                   	ret    

f01081c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01081c5:	55                   	push   %ebp
f01081c6:	89 e5                	mov    %esp,%ebp
f01081c8:	57                   	push   %edi
f01081c9:	56                   	push   %esi
f01081ca:	53                   	push   %ebx
f01081cb:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f01081ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01081d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
f01081d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01081d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
f01081da:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01081dd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01081e0:	73 6d                	jae    f010824f <memmove+0x8a>
f01081e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01081e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01081e8:	01 d0                	add    %edx,%eax
f01081ea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01081ed:	76 60                	jbe    f010824f <memmove+0x8a>
		s += n;
f01081ef:	8b 45 10             	mov    0x10(%ebp),%eax
f01081f2:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
f01081f5:	8b 45 10             	mov    0x10(%ebp),%eax
f01081f8:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01081fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01081fe:	83 e0 03             	and    $0x3,%eax
f0108201:	85 c0                	test   %eax,%eax
f0108203:	75 2f                	jne    f0108234 <memmove+0x6f>
f0108205:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108208:	83 e0 03             	and    $0x3,%eax
f010820b:	85 c0                	test   %eax,%eax
f010820d:	75 25                	jne    f0108234 <memmove+0x6f>
f010820f:	8b 45 10             	mov    0x10(%ebp),%eax
f0108212:	83 e0 03             	and    $0x3,%eax
f0108215:	85 c0                	test   %eax,%eax
f0108217:	75 1b                	jne    f0108234 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0108219:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010821c:	83 e8 04             	sub    $0x4,%eax
f010821f:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108222:	83 ea 04             	sub    $0x4,%edx
f0108225:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0108228:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010822b:	89 c7                	mov    %eax,%edi
f010822d:	89 d6                	mov    %edx,%esi
f010822f:	fd                   	std    
f0108230:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0108232:	eb 18                	jmp    f010824c <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0108234:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108237:	8d 50 ff             	lea    -0x1(%eax),%edx
f010823a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010823d:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0108240:	8b 45 10             	mov    0x10(%ebp),%eax
f0108243:	89 d7                	mov    %edx,%edi
f0108245:	89 de                	mov    %ebx,%esi
f0108247:	89 c1                	mov    %eax,%ecx
f0108249:	fd                   	std    
f010824a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010824c:	fc                   	cld    
f010824d:	eb 45                	jmp    f0108294 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010824f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108252:	83 e0 03             	and    $0x3,%eax
f0108255:	85 c0                	test   %eax,%eax
f0108257:	75 2b                	jne    f0108284 <memmove+0xbf>
f0108259:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010825c:	83 e0 03             	and    $0x3,%eax
f010825f:	85 c0                	test   %eax,%eax
f0108261:	75 21                	jne    f0108284 <memmove+0xbf>
f0108263:	8b 45 10             	mov    0x10(%ebp),%eax
f0108266:	83 e0 03             	and    $0x3,%eax
f0108269:	85 c0                	test   %eax,%eax
f010826b:	75 17                	jne    f0108284 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010826d:	8b 45 10             	mov    0x10(%ebp),%eax
f0108270:	c1 e8 02             	shr    $0x2,%eax
f0108273:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0108275:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108278:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010827b:	89 c7                	mov    %eax,%edi
f010827d:	89 d6                	mov    %edx,%esi
f010827f:	fc                   	cld    
f0108280:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0108282:	eb 10                	jmp    f0108294 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0108284:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108287:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010828a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010828d:	89 c7                	mov    %eax,%edi
f010828f:	89 d6                	mov    %edx,%esi
f0108291:	fc                   	cld    
f0108292:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
f0108294:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108297:	83 c4 10             	add    $0x10,%esp
f010829a:	5b                   	pop    %ebx
f010829b:	5e                   	pop    %esi
f010829c:	5f                   	pop    %edi
f010829d:	5d                   	pop    %ebp
f010829e:	c3                   	ret    

f010829f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010829f:	55                   	push   %ebp
f01082a0:	89 e5                	mov    %esp,%ebp
f01082a2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01082a5:	8b 45 10             	mov    0x10(%ebp),%eax
f01082a8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01082ac:	8b 45 0c             	mov    0xc(%ebp),%eax
f01082af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01082b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01082b6:	89 04 24             	mov    %eax,(%esp)
f01082b9:	e8 07 ff ff ff       	call   f01081c5 <memmove>
}
f01082be:	c9                   	leave  
f01082bf:	c3                   	ret    

f01082c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01082c0:	55                   	push   %ebp
f01082c1:	89 e5                	mov    %esp,%ebp
f01082c3:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
f01082c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01082c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
f01082cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01082cf:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f01082d2:	eb 30                	jmp    f0108304 <memcmp+0x44>
		if (*s1 != *s2)
f01082d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01082d7:	0f b6 10             	movzbl (%eax),%edx
f01082da:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01082dd:	0f b6 00             	movzbl (%eax),%eax
f01082e0:	38 c2                	cmp    %al,%dl
f01082e2:	74 18                	je     f01082fc <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
f01082e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01082e7:	0f b6 00             	movzbl (%eax),%eax
f01082ea:	0f b6 d0             	movzbl %al,%edx
f01082ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01082f0:	0f b6 00             	movzbl (%eax),%eax
f01082f3:	0f b6 c0             	movzbl %al,%eax
f01082f6:	29 c2                	sub    %eax,%edx
f01082f8:	89 d0                	mov    %edx,%eax
f01082fa:	eb 1a                	jmp    f0108316 <memcmp+0x56>
		s1++, s2++;
f01082fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108300:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0108304:	8b 45 10             	mov    0x10(%ebp),%eax
f0108307:	8d 50 ff             	lea    -0x1(%eax),%edx
f010830a:	89 55 10             	mov    %edx,0x10(%ebp)
f010830d:	85 c0                	test   %eax,%eax
f010830f:	75 c3                	jne    f01082d4 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0108311:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108316:	c9                   	leave  
f0108317:	c3                   	ret    

f0108318 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0108318:	55                   	push   %ebp
f0108319:	89 e5                	mov    %esp,%ebp
f010831b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f010831e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108321:	8b 55 08             	mov    0x8(%ebp),%edx
f0108324:	01 d0                	add    %edx,%eax
f0108326:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f0108329:	eb 13                	jmp    f010833e <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
f010832b:	8b 45 08             	mov    0x8(%ebp),%eax
f010832e:	0f b6 10             	movzbl (%eax),%edx
f0108331:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108334:	38 c2                	cmp    %al,%dl
f0108336:	75 02                	jne    f010833a <memfind+0x22>
			break;
f0108338:	eb 0c                	jmp    f0108346 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010833a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f010833e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108341:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0108344:	72 e5                	jb     f010832b <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
f0108346:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0108349:	c9                   	leave  
f010834a:	c3                   	ret    

f010834b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010834b:	55                   	push   %ebp
f010834c:	89 e5                	mov    %esp,%ebp
f010834e:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f0108351:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f0108358:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010835f:	eb 04                	jmp    f0108365 <strtol+0x1a>
		s++;
f0108361:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0108365:	8b 45 08             	mov    0x8(%ebp),%eax
f0108368:	0f b6 00             	movzbl (%eax),%eax
f010836b:	3c 20                	cmp    $0x20,%al
f010836d:	74 f2                	je     f0108361 <strtol+0x16>
f010836f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108372:	0f b6 00             	movzbl (%eax),%eax
f0108375:	3c 09                	cmp    $0x9,%al
f0108377:	74 e8                	je     f0108361 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f0108379:	8b 45 08             	mov    0x8(%ebp),%eax
f010837c:	0f b6 00             	movzbl (%eax),%eax
f010837f:	3c 2b                	cmp    $0x2b,%al
f0108381:	75 06                	jne    f0108389 <strtol+0x3e>
		s++;
f0108383:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108387:	eb 15                	jmp    f010839e <strtol+0x53>
	else if (*s == '-')
f0108389:	8b 45 08             	mov    0x8(%ebp),%eax
f010838c:	0f b6 00             	movzbl (%eax),%eax
f010838f:	3c 2d                	cmp    $0x2d,%al
f0108391:	75 0b                	jne    f010839e <strtol+0x53>
		s++, neg = 1;
f0108393:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108397:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010839e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01083a2:	74 06                	je     f01083aa <strtol+0x5f>
f01083a4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f01083a8:	75 24                	jne    f01083ce <strtol+0x83>
f01083aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01083ad:	0f b6 00             	movzbl (%eax),%eax
f01083b0:	3c 30                	cmp    $0x30,%al
f01083b2:	75 1a                	jne    f01083ce <strtol+0x83>
f01083b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01083b7:	83 c0 01             	add    $0x1,%eax
f01083ba:	0f b6 00             	movzbl (%eax),%eax
f01083bd:	3c 78                	cmp    $0x78,%al
f01083bf:	75 0d                	jne    f01083ce <strtol+0x83>
		s += 2, base = 16;
f01083c1:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f01083c5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01083cc:	eb 2a                	jmp    f01083f8 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
f01083ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01083d2:	75 17                	jne    f01083eb <strtol+0xa0>
f01083d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01083d7:	0f b6 00             	movzbl (%eax),%eax
f01083da:	3c 30                	cmp    $0x30,%al
f01083dc:	75 0d                	jne    f01083eb <strtol+0xa0>
		s++, base = 8;
f01083de:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f01083e2:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01083e9:	eb 0d                	jmp    f01083f8 <strtol+0xad>
	else if (base == 0)
f01083eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01083ef:	75 07                	jne    f01083f8 <strtol+0xad>
		base = 10;
f01083f1:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01083f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01083fb:	0f b6 00             	movzbl (%eax),%eax
f01083fe:	3c 2f                	cmp    $0x2f,%al
f0108400:	7e 1b                	jle    f010841d <strtol+0xd2>
f0108402:	8b 45 08             	mov    0x8(%ebp),%eax
f0108405:	0f b6 00             	movzbl (%eax),%eax
f0108408:	3c 39                	cmp    $0x39,%al
f010840a:	7f 11                	jg     f010841d <strtol+0xd2>
			dig = *s - '0';
f010840c:	8b 45 08             	mov    0x8(%ebp),%eax
f010840f:	0f b6 00             	movzbl (%eax),%eax
f0108412:	0f be c0             	movsbl %al,%eax
f0108415:	83 e8 30             	sub    $0x30,%eax
f0108418:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010841b:	eb 48                	jmp    f0108465 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
f010841d:	8b 45 08             	mov    0x8(%ebp),%eax
f0108420:	0f b6 00             	movzbl (%eax),%eax
f0108423:	3c 60                	cmp    $0x60,%al
f0108425:	7e 1b                	jle    f0108442 <strtol+0xf7>
f0108427:	8b 45 08             	mov    0x8(%ebp),%eax
f010842a:	0f b6 00             	movzbl (%eax),%eax
f010842d:	3c 7a                	cmp    $0x7a,%al
f010842f:	7f 11                	jg     f0108442 <strtol+0xf7>
			dig = *s - 'a' + 10;
f0108431:	8b 45 08             	mov    0x8(%ebp),%eax
f0108434:	0f b6 00             	movzbl (%eax),%eax
f0108437:	0f be c0             	movsbl %al,%eax
f010843a:	83 e8 57             	sub    $0x57,%eax
f010843d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108440:	eb 23                	jmp    f0108465 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
f0108442:	8b 45 08             	mov    0x8(%ebp),%eax
f0108445:	0f b6 00             	movzbl (%eax),%eax
f0108448:	3c 40                	cmp    $0x40,%al
f010844a:	7e 3d                	jle    f0108489 <strtol+0x13e>
f010844c:	8b 45 08             	mov    0x8(%ebp),%eax
f010844f:	0f b6 00             	movzbl (%eax),%eax
f0108452:	3c 5a                	cmp    $0x5a,%al
f0108454:	7f 33                	jg     f0108489 <strtol+0x13e>
			dig = *s - 'A' + 10;
f0108456:	8b 45 08             	mov    0x8(%ebp),%eax
f0108459:	0f b6 00             	movzbl (%eax),%eax
f010845c:	0f be c0             	movsbl %al,%eax
f010845f:	83 e8 37             	sub    $0x37,%eax
f0108462:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0108465:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108468:	3b 45 10             	cmp    0x10(%ebp),%eax
f010846b:	7c 02                	jl     f010846f <strtol+0x124>
			break;
f010846d:	eb 1a                	jmp    f0108489 <strtol+0x13e>
		s++, val = (val * base) + dig;
f010846f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
f0108473:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108476:	0f af 45 10          	imul   0x10(%ebp),%eax
f010847a:	89 c2                	mov    %eax,%edx
f010847c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010847f:	01 d0                	add    %edx,%eax
f0108481:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f0108484:	e9 6f ff ff ff       	jmp    f01083f8 <strtol+0xad>

	if (endptr)
f0108489:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010848d:	74 08                	je     f0108497 <strtol+0x14c>
		*endptr = (char *) s;
f010848f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108492:	8b 55 08             	mov    0x8(%ebp),%edx
f0108495:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0108497:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f010849b:	74 07                	je     f01084a4 <strtol+0x159>
f010849d:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01084a0:	f7 d8                	neg    %eax
f01084a2:	eb 03                	jmp    f01084a7 <strtol+0x15c>
f01084a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01084a7:	c9                   	leave  
f01084a8:	c3                   	ret    
f01084a9:	66 90                	xchg   %ax,%ax
f01084ab:	90                   	nop

f01084ac <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01084ac:	fa                   	cli    

	xorw    %ax, %ax
f01084ad:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01084af:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01084b1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01084b3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01084b5:	0f 01 16             	lgdtl  (%esi)
f01084b8:	74 70                	je     f010852a <_kaddr+0x3>
	movl    %cr0, %eax
f01084ba:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01084bd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01084c1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01084c4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01084ca:	08 00                	or     %al,(%eax)

f01084cc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01084cc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01084d0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01084d2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01084d4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01084d6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01084da:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01084dc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01084de:	b8 00 50 12 00       	mov    $0x125000,%eax
	movl    %eax, %cr3
f01084e3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01084e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01084e9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01084ee:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01084f1:	8b 25 e4 6e 24 f0    	mov    0xf0246ee4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01084f7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01084fc:	b8 55 02 10 f0       	mov    $0xf0100255,%eax
	call    *%eax
f0108501:	ff d0                	call   *%eax

f0108503 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0108503:	eb fe                	jmp    f0108503 <spin>
f0108505:	8d 76 00             	lea    0x0(%esi),%esi

f0108508 <gdt>:
	...
f0108510:	ff                   	(bad)  
f0108511:	ff 00                	incl   (%eax)
f0108513:	00 00                	add    %al,(%eax)
f0108515:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010851c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0108520 <gdtdesc>:
f0108520:	17                   	pop    %ss
f0108521:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0108526 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0108526:	90                   	nop

f0108527 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0108527:	55                   	push   %ebp
f0108528:	89 e5                	mov    %esp,%ebp
f010852a:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f010852d:	8b 45 10             	mov    0x10(%ebp),%eax
f0108530:	c1 e8 0c             	shr    $0xc,%eax
f0108533:	89 c2                	mov    %eax,%edx
f0108535:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f010853a:	39 c2                	cmp    %eax,%edx
f010853c:	72 21                	jb     f010855f <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010853e:	8b 45 10             	mov    0x10(%ebp),%eax
f0108541:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108545:	c7 44 24 08 38 ad 10 	movl   $0xf010ad38,0x8(%esp)
f010854c:	f0 
f010854d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108550:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108554:	8b 45 08             	mov    0x8(%ebp),%eax
f0108557:	89 04 24             	mov    %eax,(%esp)
f010855a:	e8 70 7d ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f010855f:	8b 45 10             	mov    0x10(%ebp),%eax
f0108562:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0108567:	c9                   	leave  
f0108568:	c3                   	ret    

f0108569 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0108569:	55                   	push   %ebp
f010856a:	89 e5                	mov    %esp,%ebp
f010856c:	83 ec 10             	sub    $0x10,%esp
	int i, sum;

	sum = 0;
f010856f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i = 0; i < len; i++)
f0108576:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010857d:	eb 15                	jmp    f0108594 <sum+0x2b>
		sum += ((uint8_t *)addr)[i];
f010857f:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0108582:	8b 45 08             	mov    0x8(%ebp),%eax
f0108585:	01 d0                	add    %edx,%eax
f0108587:	0f b6 00             	movzbl (%eax),%eax
f010858a:	0f b6 c0             	movzbl %al,%eax
f010858d:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0108590:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
f0108594:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108597:	3b 45 0c             	cmp    0xc(%ebp),%eax
f010859a:	7c e3                	jl     f010857f <sum+0x16>
		sum += ((uint8_t *)addr)[i];
	return sum;
f010859c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f010859f:	c9                   	leave  
f01085a0:	c3                   	ret    

f01085a1 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01085a1:	55                   	push   %ebp
f01085a2:	89 e5                	mov    %esp,%ebp
f01085a4:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01085a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01085aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01085ae:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01085b5:	00 
f01085b6:	c7 04 24 5b ad 10 f0 	movl   $0xf010ad5b,(%esp)
f01085bd:	e8 65 ff ff ff       	call   f0108527 <_kaddr>
f01085c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01085c5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01085c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01085cb:	01 d0                	add    %edx,%eax
f01085cd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01085d1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01085d8:	00 
f01085d9:	c7 04 24 5b ad 10 f0 	movl   $0xf010ad5b,(%esp)
f01085e0:	e8 42 ff ff ff       	call   f0108527 <_kaddr>
f01085e5:	89 45 f0             	mov    %eax,-0x10(%ebp)

	for (; mp < end; mp++)
f01085e8:	eb 3f                	jmp    f0108629 <mpsearch1+0x88>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01085ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01085ed:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01085f4:	00 
f01085f5:	c7 44 24 04 6b ad 10 	movl   $0xf010ad6b,0x4(%esp)
f01085fc:	f0 
f01085fd:	89 04 24             	mov    %eax,(%esp)
f0108600:	e8 bb fc ff ff       	call   f01082c0 <memcmp>
f0108605:	85 c0                	test   %eax,%eax
f0108607:	75 1c                	jne    f0108625 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
f0108609:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0108610:	00 
f0108611:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108614:	89 04 24             	mov    %eax,(%esp)
f0108617:	e8 4d ff ff ff       	call   f0108569 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010861c:	84 c0                	test   %al,%al
f010861e:	75 05                	jne    f0108625 <mpsearch1+0x84>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
f0108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108623:	eb 11                	jmp    f0108636 <mpsearch1+0x95>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0108625:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
f0108629:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010862c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010862f:	72 b9                	jb     f01085ea <mpsearch1+0x49>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0108631:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108636:	c9                   	leave  
f0108637:	c3                   	ret    

f0108638 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0108638:	55                   	push   %ebp
f0108639:	89 e5                	mov    %esp,%ebp
f010863b:	83 ec 28             	sub    $0x28,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f010863e:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
f0108645:	00 
f0108646:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010864d:	00 
f010864e:	c7 04 24 5b ad 10 f0 	movl   $0xf010ad5b,(%esp)
f0108655:	e8 cd fe ff ff       	call   f0108527 <_kaddr>
f010865a:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108660:	83 c0 0e             	add    $0xe,%eax
f0108663:	0f b7 00             	movzwl (%eax),%eax
f0108666:	0f b7 c0             	movzwl %ax,%eax
f0108669:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010866c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0108670:	74 25                	je     f0108697 <mpsearch+0x5f>
		p <<= 4;	// Translate from segment to PA
f0108672:	c1 65 f0 04          	shll   $0x4,-0x10(%ebp)
		if ((mp = mpsearch1(p, 1024)))
f0108676:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010867d:	00 
f010867e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108681:	89 04 24             	mov    %eax,(%esp)
f0108684:	e8 18 ff ff ff       	call   f01085a1 <mpsearch1>
f0108689:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010868c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0108690:	74 3d                	je     f01086cf <mpsearch+0x97>
			return mp;
f0108692:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108695:	eb 4c                	jmp    f01086e3 <mpsearch+0xab>
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0108697:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010869a:	83 c0 13             	add    $0x13,%eax
f010869d:	0f b7 00             	movzwl (%eax),%eax
f01086a0:	0f b7 c0             	movzwl %ax,%eax
f01086a3:	c1 e0 0a             	shl    $0xa,%eax
f01086a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if ((mp = mpsearch1(p - 1024, 1024)))
f01086a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01086ac:	2d 00 04 00 00       	sub    $0x400,%eax
f01086b1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01086b8:	00 
f01086b9:	89 04 24             	mov    %eax,(%esp)
f01086bc:	e8 e0 fe ff ff       	call   f01085a1 <mpsearch1>
f01086c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01086c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01086c8:	74 05                	je     f01086cf <mpsearch+0x97>
			return mp;
f01086ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01086cd:	eb 14                	jmp    f01086e3 <mpsearch+0xab>
	}
	return mpsearch1(0xF0000, 0x10000);
f01086cf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f01086d6:	00 
f01086d7:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
f01086de:	e8 be fe ff ff       	call   f01085a1 <mpsearch1>
}
f01086e3:	c9                   	leave  
f01086e4:	c3                   	ret    

f01086e5 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f01086e5:	55                   	push   %ebp
f01086e6:	89 e5                	mov    %esp,%ebp
f01086e8:	83 ec 28             	sub    $0x28,%esp
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01086eb:	e8 48 ff ff ff       	call   f0108638 <mpsearch>
f01086f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01086f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01086f7:	75 0a                	jne    f0108703 <mpconfig+0x1e>
		return NULL;
f01086f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01086fe:	e9 44 01 00 00       	jmp    f0108847 <mpconfig+0x162>
	if (mp->physaddr == 0 || mp->type != 0) {
f0108703:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108706:	8b 40 04             	mov    0x4(%eax),%eax
f0108709:	85 c0                	test   %eax,%eax
f010870b:	74 0b                	je     f0108718 <mpconfig+0x33>
f010870d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108710:	0f b6 40 0b          	movzbl 0xb(%eax),%eax
f0108714:	84 c0                	test   %al,%al
f0108716:	74 16                	je     f010872e <mpconfig+0x49>
		cprintf("SMP: Default configurations not implemented\n");
f0108718:	c7 04 24 70 ad 10 f0 	movl   $0xf010ad70,(%esp)
f010871f:	e8 8c c8 ff ff       	call   f0104fb0 <cprintf>
		return NULL;
f0108724:	b8 00 00 00 00       	mov    $0x0,%eax
f0108729:	e9 19 01 00 00       	jmp    f0108847 <mpconfig+0x162>
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f010872e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0108731:	8b 40 04             	mov    0x4(%eax),%eax
f0108734:	89 44 24 08          	mov    %eax,0x8(%esp)
f0108738:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010873f:	00 
f0108740:	c7 04 24 5b ad 10 f0 	movl   $0xf010ad5b,(%esp)
f0108747:	e8 db fd ff ff       	call   f0108527 <_kaddr>
f010874c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0) {
f010874f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0108756:	00 
f0108757:	c7 44 24 04 9d ad 10 	movl   $0xf010ad9d,0x4(%esp)
f010875e:	f0 
f010875f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108762:	89 04 24             	mov    %eax,(%esp)
f0108765:	e8 56 fb ff ff       	call   f01082c0 <memcmp>
f010876a:	85 c0                	test   %eax,%eax
f010876c:	74 16                	je     f0108784 <mpconfig+0x9f>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010876e:	c7 04 24 a4 ad 10 f0 	movl   $0xf010ada4,(%esp)
f0108775:	e8 36 c8 ff ff       	call   f0104fb0 <cprintf>
		return NULL;
f010877a:	b8 00 00 00 00       	mov    $0x0,%eax
f010877f:	e9 c3 00 00 00       	jmp    f0108847 <mpconfig+0x162>
	}
	if (sum(conf, conf->length) != 0) {
f0108784:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108787:	0f b7 40 04          	movzwl 0x4(%eax),%eax
f010878b:	0f b7 c0             	movzwl %ax,%eax
f010878e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108792:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108795:	89 04 24             	mov    %eax,(%esp)
f0108798:	e8 cc fd ff ff       	call   f0108569 <sum>
f010879d:	84 c0                	test   %al,%al
f010879f:	74 16                	je     f01087b7 <mpconfig+0xd2>
		cprintf("SMP: Bad MP configuration checksum\n");
f01087a1:	c7 04 24 d8 ad 10 f0 	movl   $0xf010add8,(%esp)
f01087a8:	e8 03 c8 ff ff       	call   f0104fb0 <cprintf>
		return NULL;
f01087ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01087b2:	e9 90 00 00 00       	jmp    f0108847 <mpconfig+0x162>
	}
	if (conf->version != 1 && conf->version != 4) {
f01087b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01087ba:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f01087be:	3c 01                	cmp    $0x1,%al
f01087c0:	74 2c                	je     f01087ee <mpconfig+0x109>
f01087c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01087c5:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f01087c9:	3c 04                	cmp    $0x4,%al
f01087cb:	74 21                	je     f01087ee <mpconfig+0x109>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01087cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01087d0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
f01087d4:	0f b6 c0             	movzbl %al,%eax
f01087d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01087db:	c7 04 24 fc ad 10 f0 	movl   $0xf010adfc,(%esp)
f01087e2:	e8 c9 c7 ff ff       	call   f0104fb0 <cprintf>
		return NULL;
f01087e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01087ec:	eb 59                	jmp    f0108847 <mpconfig+0x162>
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01087ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01087f1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
f01087f5:	0f b7 c0             	movzwl %ax,%eax
f01087f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01087fb:	0f b7 52 04          	movzwl 0x4(%edx),%edx
f01087ff:	0f b7 ca             	movzwl %dx,%ecx
f0108802:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0108805:	01 ca                	add    %ecx,%edx
f0108807:	89 44 24 04          	mov    %eax,0x4(%esp)
f010880b:	89 14 24             	mov    %edx,(%esp)
f010880e:	e8 56 fd ff ff       	call   f0108569 <sum>
f0108813:	0f b6 d0             	movzbl %al,%edx
f0108816:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108819:	0f b6 40 2a          	movzbl 0x2a(%eax),%eax
f010881d:	0f b6 c0             	movzbl %al,%eax
f0108820:	01 d0                	add    %edx,%eax
f0108822:	0f b6 c0             	movzbl %al,%eax
f0108825:	85 c0                	test   %eax,%eax
f0108827:	74 13                	je     f010883c <mpconfig+0x157>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0108829:	c7 04 24 1c ae 10 f0 	movl   $0xf010ae1c,(%esp)
f0108830:	e8 7b c7 ff ff       	call   f0104fb0 <cprintf>
		return NULL;
f0108835:	b8 00 00 00 00       	mov    $0x0,%eax
f010883a:	eb 0b                	jmp    f0108847 <mpconfig+0x162>
	}
	*pmp = mp;
f010883c:	8b 45 08             	mov    0x8(%ebp),%eax
f010883f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0108842:	89 10                	mov    %edx,(%eax)
	return conf;
f0108844:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0108847:	c9                   	leave  
f0108848:	c3                   	ret    

f0108849 <mp_init>:

void
mp_init(void)
{
f0108849:	55                   	push   %ebp
f010884a:	89 e5                	mov    %esp,%ebp
f010884c:	83 ec 48             	sub    $0x48,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010884f:	c7 05 c0 73 24 f0 20 	movl   $0xf0247020,0xf02473c0
f0108856:	70 24 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0108859:	8d 45 cc             	lea    -0x34(%ebp),%eax
f010885c:	89 04 24             	mov    %eax,(%esp)
f010885f:	e8 81 fe ff ff       	call   f01086e5 <mpconfig>
f0108864:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0108867:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010886b:	75 05                	jne    f0108872 <mp_init+0x29>
		return;
f010886d:	e9 c1 01 00 00       	jmp    f0108a33 <mp_init+0x1ea>
	ismp = 1;
f0108872:	c7 05 00 70 24 f0 01 	movl   $0x1,0xf0247000
f0108879:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010887c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010887f:	8b 40 24             	mov    0x24(%eax),%eax
f0108882:	a3 00 80 28 f0       	mov    %eax,0xf0288000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0108887:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010888a:	83 c0 2c             	add    $0x2c,%eax
f010888d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0108890:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0108897:	e9 d2 00 00 00       	jmp    f010896e <mp_init+0x125>
		switch (*p) {
f010889c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010889f:	0f b6 00             	movzbl (%eax),%eax
f01088a2:	0f b6 c0             	movzbl %al,%eax
f01088a5:	85 c0                	test   %eax,%eax
f01088a7:	74 13                	je     f01088bc <mp_init+0x73>
f01088a9:	85 c0                	test   %eax,%eax
f01088ab:	0f 88 89 00 00 00    	js     f010893a <mp_init+0xf1>
f01088b1:	83 f8 04             	cmp    $0x4,%eax
f01088b4:	0f 8f 80 00 00 00    	jg     f010893a <mp_init+0xf1>
f01088ba:	eb 78                	jmp    f0108934 <mp_init+0xeb>
		case MPPROC:
			proc = (struct mpproc *)p;
f01088bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01088bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if (proc->flags & MPPROC_BOOT)
f01088c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01088c5:	0f b6 40 03          	movzbl 0x3(%eax),%eax
f01088c9:	0f b6 c0             	movzbl %al,%eax
f01088cc:	83 e0 02             	and    $0x2,%eax
f01088cf:	85 c0                	test   %eax,%eax
f01088d1:	74 12                	je     f01088e5 <mp_init+0x9c>
				bootcpu = &cpus[ncpu];
f01088d3:	a1 c4 73 24 f0       	mov    0xf02473c4,%eax
f01088d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01088db:	05 20 70 24 f0       	add    $0xf0247020,%eax
f01088e0:	a3 c0 73 24 f0       	mov    %eax,0xf02473c0
			if (ncpu < NCPU) {
f01088e5:	a1 c4 73 24 f0       	mov    0xf02473c4,%eax
f01088ea:	83 f8 07             	cmp    $0x7,%eax
f01088ed:	7f 25                	jg     f0108914 <mp_init+0xcb>
				cpus[ncpu].cpu_id = ncpu;
f01088ef:	8b 15 c4 73 24 f0    	mov    0xf02473c4,%edx
f01088f5:	a1 c4 73 24 f0       	mov    0xf02473c4,%eax
f01088fa:	6b d2 74             	imul   $0x74,%edx,%edx
f01088fd:	81 c2 20 70 24 f0    	add    $0xf0247020,%edx
f0108903:	88 02                	mov    %al,(%edx)
				ncpu++;
f0108905:	a1 c4 73 24 f0       	mov    0xf02473c4,%eax
f010890a:	83 c0 01             	add    $0x1,%eax
f010890d:	a3 c4 73 24 f0       	mov    %eax,0xf02473c4
f0108912:	eb 1a                	jmp    f010892e <mp_init+0xe5>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
f0108914:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0108917:	0f b6 40 01          	movzbl 0x1(%eax),%eax
				bootcpu = &cpus[ncpu];
			if (ncpu < NCPU) {
				cpus[ncpu].cpu_id = ncpu;
				ncpu++;
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010891b:	0f b6 c0             	movzbl %al,%eax
f010891e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108922:	c7 04 24 4c ae 10 f0 	movl   $0xf010ae4c,(%esp)
f0108929:	e8 82 c6 ff ff       	call   f0104fb0 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010892e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
			continue;
f0108932:	eb 36                	jmp    f010896a <mp_init+0x121>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0108934:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
			continue;
f0108938:	eb 30                	jmp    f010896a <mp_init+0x121>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010893a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010893d:	0f b6 00             	movzbl (%eax),%eax
f0108940:	0f b6 c0             	movzbl %al,%eax
f0108943:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108947:	c7 04 24 74 ae 10 f0 	movl   $0xf010ae74,(%esp)
f010894e:	e8 5d c6 ff ff       	call   f0104fb0 <cprintf>
			ismp = 0;
f0108953:	c7 05 00 70 24 f0 00 	movl   $0x0,0xf0247000
f010895a:	00 00 00 
			i = conf->entry;
f010895d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108960:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0108964:	0f b7 c0             	movzwl %ax,%eax
f0108967:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010896a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
f010896e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0108971:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0108975:	0f b7 c0             	movzwl %ax,%eax
f0108978:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f010897b:	0f 87 1b ff ff ff    	ja     f010889c <mp_init+0x53>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0108981:	a1 c0 73 24 f0       	mov    0xf02473c0,%eax
f0108986:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010898d:	a1 00 70 24 f0       	mov    0xf0247000,%eax
f0108992:	85 c0                	test   %eax,%eax
f0108994:	75 22                	jne    f01089b8 <mp_init+0x16f>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0108996:	c7 05 c4 73 24 f0 01 	movl   $0x1,0xf02473c4
f010899d:	00 00 00 
		lapicaddr = 0;
f01089a0:	c7 05 00 80 28 f0 00 	movl   $0x0,0xf0288000
f01089a7:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01089aa:	c7 04 24 94 ae 10 f0 	movl   $0xf010ae94,(%esp)
f01089b1:	e8 fa c5 ff ff       	call   f0104fb0 <cprintf>
		return;
f01089b6:	eb 7b                	jmp    f0108a33 <mp_init+0x1ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01089b8:	8b 15 c4 73 24 f0    	mov    0xf02473c4,%edx
f01089be:	a1 c0 73 24 f0       	mov    0xf02473c0,%eax
f01089c3:	0f b6 00             	movzbl (%eax),%eax
f01089c6:	0f b6 c0             	movzbl %al,%eax
f01089c9:	89 54 24 08          	mov    %edx,0x8(%esp)
f01089cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01089d1:	c7 04 24 c0 ae 10 f0 	movl   $0xf010aec0,(%esp)
f01089d8:	e8 d3 c5 ff ff       	call   f0104fb0 <cprintf>

	if (mp->imcrp) {
f01089dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01089e0:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
f01089e4:	84 c0                	test   %al,%al
f01089e6:	74 4b                	je     f0108a33 <mp_init+0x1ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01089e8:	c7 04 24 e0 ae 10 f0 	movl   $0xf010aee0,(%esp)
f01089ef:	e8 bc c5 ff ff       	call   f0104fb0 <cprintf>
f01089f4:	c7 45 e4 22 00 00 00 	movl   $0x22,-0x1c(%ebp)
f01089fb:	c6 45 e3 70          	movb   $0x70,-0x1d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01089ff:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0108a03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0108a06:	ee                   	out    %al,(%dx)
f0108a07:	c7 45 dc 23 00 00 00 	movl   $0x23,-0x24(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0108a0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0108a11:	89 c2                	mov    %eax,%edx
f0108a13:	ec                   	in     (%dx),%al
f0108a14:	88 45 db             	mov    %al,-0x25(%ebp)
	return data;
f0108a17:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0108a1b:	83 c8 01             	or     $0x1,%eax
f0108a1e:	0f b6 c0             	movzbl %al,%eax
f0108a21:	c7 45 d4 23 00 00 00 	movl   $0x23,-0x2c(%ebp)
f0108a28:	88 45 d3             	mov    %al,-0x2d(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0108a2b:	0f b6 45 d3          	movzbl -0x2d(%ebp),%eax
f0108a2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0108a32:	ee                   	out    %al,(%dx)
	}
}
f0108a33:	c9                   	leave  
f0108a34:	c3                   	ret    

f0108a35 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0108a35:	55                   	push   %ebp
f0108a36:	89 e5                	mov    %esp,%ebp
f0108a38:	83 ec 18             	sub    $0x18,%esp
	if (PGNUM(pa) >= npages)
f0108a3b:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a3e:	c1 e8 0c             	shr    $0xc,%eax
f0108a41:	89 c2                	mov    %eax,%edx
f0108a43:	a1 e8 6e 24 f0       	mov    0xf0246ee8,%eax
f0108a48:	39 c2                	cmp    %eax,%edx
f0108a4a:	72 21                	jb     f0108a6d <_kaddr+0x38>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0108a4c:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108a53:	c7 44 24 08 24 af 10 	movl   $0xf010af24,0x8(%esp)
f0108a5a:	f0 
f0108a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108a62:	8b 45 08             	mov    0x8(%ebp),%eax
f0108a65:	89 04 24             	mov    %eax,(%esp)
f0108a68:	e8 62 78 ff ff       	call   f01002cf <_panic>
	return (void *)(pa + KERNBASE);
f0108a6d:	8b 45 10             	mov    0x10(%ebp),%eax
f0108a70:	2d 00 00 00 10       	sub    $0x10000000,%eax
}
f0108a75:	c9                   	leave  
f0108a76:	c3                   	ret    

f0108a77 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0108a77:	55                   	push   %ebp
f0108a78:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0108a7a:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108a7f:	8b 55 08             	mov    0x8(%ebp),%edx
f0108a82:	c1 e2 02             	shl    $0x2,%edx
f0108a85:	01 c2                	add    %eax,%edx
f0108a87:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108a8a:	89 02                	mov    %eax,(%edx)
	lapic[ID];  // wait for write to finish, by reading
f0108a8c:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108a91:	83 c0 20             	add    $0x20,%eax
f0108a94:	8b 00                	mov    (%eax),%eax
}
f0108a96:	5d                   	pop    %ebp
f0108a97:	c3                   	ret    

f0108a98 <lapic_init>:

void
lapic_init(void)
{
f0108a98:	55                   	push   %ebp
f0108a99:	89 e5                	mov    %esp,%ebp
f0108a9b:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0108a9e:	a1 00 80 28 f0       	mov    0xf0288000,%eax
f0108aa3:	85 c0                	test   %eax,%eax
f0108aa5:	75 05                	jne    f0108aac <lapic_init+0x14>
		return;
f0108aa7:	e9 74 01 00 00       	jmp    f0108c20 <lapic_init+0x188>

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0108aac:	a1 00 80 28 f0       	mov    0xf0288000,%eax
f0108ab1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0108ab8:	00 
f0108ab9:	89 04 24             	mov    %eax,(%esp)
f0108abc:	e8 bd 91 ff ff       	call   f0101c7e <mmio_map_region>
f0108ac1:	a3 04 80 28 f0       	mov    %eax,0xf0288004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0108ac6:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f0108acd:	00 
f0108ace:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
f0108ad5:	e8 9d ff ff ff       	call   f0108a77 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0108ada:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
f0108ae1:	00 
f0108ae2:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
f0108ae9:	e8 89 ff ff ff       	call   f0108a77 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0108aee:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
f0108af5:	00 
f0108af6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f0108afd:	e8 75 ff ff ff       	call   f0108a77 <lapicw>
	lapicw(TICR, 10000000); 
f0108b02:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
f0108b09:	00 
f0108b0a:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
f0108b11:	e8 61 ff ff ff       	call   f0108a77 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0108b16:	e8 07 01 00 00       	call   f0108c22 <cpunum>
f0108b1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0108b1e:	8d 90 20 70 24 f0    	lea    -0xfdb8fe0(%eax),%edx
f0108b24:	a1 c0 73 24 f0       	mov    0xf02473c0,%eax
f0108b29:	39 c2                	cmp    %eax,%edx
f0108b2b:	74 14                	je     f0108b41 <lapic_init+0xa9>
		lapicw(LINT0, MASKED);
f0108b2d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0108b34:	00 
f0108b35:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
f0108b3c:	e8 36 ff ff ff       	call   f0108a77 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0108b41:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0108b48:	00 
f0108b49:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
f0108b50:	e8 22 ff ff ff       	call   f0108a77 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0108b55:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108b5a:	83 c0 30             	add    $0x30,%eax
f0108b5d:	8b 00                	mov    (%eax),%eax
f0108b5f:	c1 e8 10             	shr    $0x10,%eax
f0108b62:	0f b6 c0             	movzbl %al,%eax
f0108b65:	83 f8 03             	cmp    $0x3,%eax
f0108b68:	76 14                	jbe    f0108b7e <lapic_init+0xe6>
		lapicw(PCINT, MASKED);
f0108b6a:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
f0108b71:	00 
f0108b72:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
f0108b79:	e8 f9 fe ff ff       	call   f0108a77 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0108b7e:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f0108b85:	00 
f0108b86:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
f0108b8d:	e8 e5 fe ff ff       	call   f0108a77 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0108b92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108b99:	00 
f0108b9a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f0108ba1:	e8 d1 fe ff ff       	call   f0108a77 <lapicw>
	lapicw(ESR, 0);
f0108ba6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108bad:	00 
f0108bae:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
f0108bb5:	e8 bd fe ff ff       	call   f0108a77 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0108bba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108bc1:	00 
f0108bc2:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f0108bc9:	e8 a9 fe ff ff       	call   f0108a77 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0108bce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108bd5:	00 
f0108bd6:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0108bdd:	e8 95 fe ff ff       	call   f0108a77 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0108be2:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
f0108be9:	00 
f0108bea:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108bf1:	e8 81 fe ff ff       	call   f0108a77 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0108bf6:	90                   	nop
f0108bf7:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108bfc:	05 00 03 00 00       	add    $0x300,%eax
f0108c01:	8b 00                	mov    (%eax),%eax
f0108c03:	25 00 10 00 00       	and    $0x1000,%eax
f0108c08:	85 c0                	test   %eax,%eax
f0108c0a:	75 eb                	jne    f0108bf7 <lapic_init+0x15f>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0108c0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108c13:	00 
f0108c14:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0108c1b:	e8 57 fe ff ff       	call   f0108a77 <lapicw>
}
f0108c20:	c9                   	leave  
f0108c21:	c3                   	ret    

f0108c22 <cpunum>:

int
cpunum(void)
{
f0108c22:	55                   	push   %ebp
f0108c23:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0108c25:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108c2a:	85 c0                	test   %eax,%eax
f0108c2c:	74 0f                	je     f0108c3d <cpunum+0x1b>
		return lapic[ID] >> 24;
f0108c2e:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108c33:	83 c0 20             	add    $0x20,%eax
f0108c36:	8b 00                	mov    (%eax),%eax
f0108c38:	c1 e8 18             	shr    $0x18,%eax
f0108c3b:	eb 05                	jmp    f0108c42 <cpunum+0x20>
	return 0;
f0108c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108c42:	5d                   	pop    %ebp
f0108c43:	c3                   	ret    

f0108c44 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0108c44:	55                   	push   %ebp
f0108c45:	89 e5                	mov    %esp,%ebp
f0108c47:	83 ec 08             	sub    $0x8,%esp
	if (lapic)
f0108c4a:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108c4f:	85 c0                	test   %eax,%eax
f0108c51:	74 14                	je     f0108c67 <lapic_eoi+0x23>
		lapicw(EOI, 0);
f0108c53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0108c5a:	00 
f0108c5b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
f0108c62:	e8 10 fe ff ff       	call   f0108a77 <lapicw>
}
f0108c67:	c9                   	leave  
f0108c68:	c3                   	ret    

f0108c69 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0108c69:	55                   	push   %ebp
f0108c6a:	89 e5                	mov    %esp,%ebp
}
f0108c6c:	5d                   	pop    %ebp
f0108c6d:	c3                   	ret    

f0108c6e <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0108c6e:	55                   	push   %ebp
f0108c6f:	89 e5                	mov    %esp,%ebp
f0108c71:	83 ec 38             	sub    $0x38,%esp
f0108c74:	8b 45 08             	mov    0x8(%ebp),%eax
f0108c77:	88 45 d4             	mov    %al,-0x2c(%ebp)
f0108c7a:	c7 45 ec 70 00 00 00 	movl   $0x70,-0x14(%ebp)
f0108c81:	c6 45 eb 0f          	movb   $0xf,-0x15(%ebp)
f0108c85:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
f0108c89:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0108c8c:	ee                   	out    %al,(%dx)
f0108c8d:	c7 45 e4 71 00 00 00 	movl   $0x71,-0x1c(%ebp)
f0108c94:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
f0108c98:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0108c9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0108c9f:	ee                   	out    %al,(%dx)
	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f0108ca0:	c7 44 24 08 67 04 00 	movl   $0x467,0x8(%esp)
f0108ca7:	00 
f0108ca8:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0108caf:	00 
f0108cb0:	c7 04 24 47 af 10 f0 	movl   $0xf010af47,(%esp)
f0108cb7:	e8 79 fd ff ff       	call   f0108a35 <_kaddr>
f0108cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	wrv[0] = 0;
f0108cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108cc2:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f0108cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0108cca:	8d 50 02             	lea    0x2(%eax),%edx
f0108ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108cd0:	c1 e8 04             	shr    $0x4,%eax
f0108cd3:	66 89 02             	mov    %ax,(%edx)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0108cd6:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f0108cda:	c1 e0 18             	shl    $0x18,%eax
f0108cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108ce1:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0108ce8:	e8 8a fd ff ff       	call   f0108a77 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0108ced:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
f0108cf4:	00 
f0108cf5:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108cfc:	e8 76 fd ff ff       	call   f0108a77 <lapicw>
	microdelay(200);
f0108d01:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f0108d08:	e8 5c ff ff ff       	call   f0108c69 <microdelay>
	lapicw(ICRLO, INIT | LEVEL);
f0108d0d:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
f0108d14:	00 
f0108d15:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108d1c:	e8 56 fd ff ff       	call   f0108a77 <lapicw>
	microdelay(100);    // should be 10ms, but too slow in Bochs!
f0108d21:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0108d28:	e8 3c ff ff ff       	call   f0108c69 <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f0108d2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0108d34:	eb 40                	jmp    f0108d76 <lapic_startap+0x108>
		lapicw(ICRHI, apicid << 24);
f0108d36:	0f b6 45 d4          	movzbl -0x2c(%ebp),%eax
f0108d3a:	c1 e0 18             	shl    $0x18,%eax
f0108d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108d41:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
f0108d48:	e8 2a fd ff ff       	call   f0108a77 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0108d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108d50:	c1 e8 0c             	shr    $0xc,%eax
f0108d53:	80 cc 06             	or     $0x6,%ah
f0108d56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108d5a:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108d61:	e8 11 fd ff ff       	call   f0108a77 <lapicw>
		microdelay(200);
f0108d66:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
f0108d6d:	e8 f7 fe ff ff       	call   f0108c69 <microdelay>
	// Send startup IPI (twice!) to enter code.
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
f0108d72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
f0108d76:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
f0108d7a:	7e ba                	jle    f0108d36 <lapic_startap+0xc8>
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
		microdelay(200);
	}
}
f0108d7c:	c9                   	leave  
f0108d7d:	c3                   	ret    

f0108d7e <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0108d7e:	55                   	push   %ebp
f0108d7f:	89 e5                	mov    %esp,%ebp
f0108d81:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0108d84:	8b 45 08             	mov    0x8(%ebp),%eax
f0108d87:	0d 00 00 0c 00       	or     $0xc0000,%eax
f0108d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108d90:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
f0108d97:	e8 db fc ff ff       	call   f0108a77 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0108d9c:	90                   	nop
f0108d9d:	a1 04 80 28 f0       	mov    0xf0288004,%eax
f0108da2:	05 00 03 00 00       	add    $0x300,%eax
f0108da7:	8b 00                	mov    (%eax),%eax
f0108da9:	25 00 10 00 00       	and    $0x1000,%eax
f0108dae:	85 c0                	test   %eax,%eax
f0108db0:	75 eb                	jne    f0108d9d <lapic_ipi+0x1f>
		;
}
f0108db2:	c9                   	leave  
f0108db3:	c3                   	ret    

f0108db4 <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f0108db4:	55                   	push   %ebp
f0108db5:	89 e5                	mov    %esp,%ebp
f0108db7:	83 ec 10             	sub    $0x10,%esp
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0108dba:	8b 55 08             	mov    0x8(%ebp),%edx
f0108dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0108dc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0108dc3:	f0 87 02             	lock xchg %eax,(%edx)
f0108dc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
			"+m" (*addr), "=a" (result) :
			"1" (newval) :
			"cc");
	return result;
f0108dc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0108dcc:	c9                   	leave  
f0108dcd:	c3                   	ret    

f0108dce <get_caller_pcs>:

#ifdef DEBUG_SPINLOCK
// Record the current call stack in pcs[] by following the %ebp chain.
static void
get_caller_pcs(uint32_t pcs[])
{
f0108dce:	55                   	push   %ebp
f0108dcf:	89 e5                	mov    %esp,%ebp
f0108dd1:	83 ec 10             	sub    $0x10,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0108dd4:	89 e8                	mov    %ebp,%eax
f0108dd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return ebp;
f0108dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0108ddc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (i = 0; i < 10; i++){
f0108ddf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
f0108de6:	eb 32                	jmp    f0108e1a <get_caller_pcs+0x4c>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0108de8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0108dec:	74 32                	je     f0108e20 <get_caller_pcs+0x52>
f0108dee:	81 7d fc ff ff 7f ef 	cmpl   $0xef7fffff,-0x4(%ebp)
f0108df5:	76 29                	jbe    f0108e20 <get_caller_pcs+0x52>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0108df7:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108dfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0108e01:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e04:	01 c2                	add    %eax,%edx
f0108e06:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108e09:	8b 40 04             	mov    0x4(%eax),%eax
f0108e0c:	89 02                	mov    %eax,(%edx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0108e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0108e11:	8b 00                	mov    (%eax),%eax
f0108e13:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0108e16:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f0108e1a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f0108e1e:	7e c8                	jle    f0108de8 <get_caller_pcs+0x1a>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0108e20:	eb 19                	jmp    f0108e3b <get_caller_pcs+0x6d>
		pcs[i] = 0;
f0108e22:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0108e25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0108e2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e2f:	01 d0                	add    %edx,%eax
f0108e31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0108e37:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
f0108e3b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
f0108e3f:	7e e1                	jle    f0108e22 <get_caller_pcs+0x54>
		pcs[i] = 0;
}
f0108e41:	c9                   	leave  
f0108e42:	c3                   	ret    

f0108e43 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0108e43:	55                   	push   %ebp
f0108e44:	89 e5                	mov    %esp,%ebp
f0108e46:	53                   	push   %ebx
f0108e47:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0108e4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e4d:	8b 00                	mov    (%eax),%eax
f0108e4f:	85 c0                	test   %eax,%eax
f0108e51:	74 1e                	je     f0108e71 <holding+0x2e>
f0108e53:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e56:	8b 58 08             	mov    0x8(%eax),%ebx
f0108e59:	e8 c4 fd ff ff       	call   f0108c22 <cpunum>
f0108e5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0108e61:	05 20 70 24 f0       	add    $0xf0247020,%eax
f0108e66:	39 c3                	cmp    %eax,%ebx
f0108e68:	75 07                	jne    f0108e71 <holding+0x2e>
f0108e6a:	b8 01 00 00 00       	mov    $0x1,%eax
f0108e6f:	eb 05                	jmp    f0108e76 <holding+0x33>
f0108e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0108e76:	83 c4 04             	add    $0x4,%esp
f0108e79:	5b                   	pop    %ebx
f0108e7a:	5d                   	pop    %ebp
f0108e7b:	c3                   	ret    

f0108e7c <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0108e7c:	55                   	push   %ebp
f0108e7d:	89 e5                	mov    %esp,%ebp
	lk->locked = 0;
f0108e7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e82:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0108e88:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0108e8e:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0108e91:	8b 45 08             	mov    0x8(%ebp),%eax
f0108e94:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0108e9b:	5d                   	pop    %ebp
f0108e9c:	c3                   	ret    

f0108e9d <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0108e9d:	55                   	push   %ebp
f0108e9e:	89 e5                	mov    %esp,%ebp
f0108ea0:	53                   	push   %ebx
f0108ea1:	83 ec 24             	sub    $0x24,%esp
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0108ea4:	8b 45 08             	mov    0x8(%ebp),%eax
f0108ea7:	89 04 24             	mov    %eax,(%esp)
f0108eaa:	e8 94 ff ff ff       	call   f0108e43 <holding>
f0108eaf:	85 c0                	test   %eax,%eax
f0108eb1:	74 2f                	je     f0108ee2 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0108eb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0108eb6:	8b 58 04             	mov    0x4(%eax),%ebx
f0108eb9:	e8 64 fd ff ff       	call   f0108c22 <cpunum>
f0108ebe:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0108ec2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0108ec6:	c7 44 24 08 60 af 10 	movl   $0xf010af60,0x8(%esp)
f0108ecd:	f0 
f0108ece:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0108ed5:	00 
f0108ed6:	c7 04 24 8a af 10 f0 	movl   $0xf010af8a,(%esp)
f0108edd:	e8 ed 73 ff ff       	call   f01002cf <_panic>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0108ee2:	eb 02                	jmp    f0108ee6 <spin_lock+0x49>
		asm volatile ("pause");
f0108ee4:	f3 90                	pause  
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0108ee6:	8b 45 08             	mov    0x8(%ebp),%eax
f0108ee9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0108ef0:	00 
f0108ef1:	89 04 24             	mov    %eax,(%esp)
f0108ef4:	e8 bb fe ff ff       	call   f0108db4 <xchg>
f0108ef9:	85 c0                	test   %eax,%eax
f0108efb:	75 e7                	jne    f0108ee4 <spin_lock+0x47>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0108efd:	e8 20 fd ff ff       	call   f0108c22 <cpunum>
f0108f02:	6b c0 74             	imul   $0x74,%eax,%eax
f0108f05:	8d 90 20 70 24 f0    	lea    -0xfdb8fe0(%eax),%edx
f0108f0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f0e:	89 50 08             	mov    %edx,0x8(%eax)
	get_caller_pcs(lk->pcs);
f0108f11:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f14:	83 c0 0c             	add    $0xc,%eax
f0108f17:	89 04 24             	mov    %eax,(%esp)
f0108f1a:	e8 af fe ff ff       	call   f0108dce <get_caller_pcs>
#endif
}
f0108f1f:	83 c4 24             	add    $0x24,%esp
f0108f22:	5b                   	pop    %ebx
f0108f23:	5d                   	pop    %ebp
f0108f24:	c3                   	ret    

f0108f25 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0108f25:	55                   	push   %ebp
f0108f26:	89 e5                	mov    %esp,%ebp
f0108f28:	57                   	push   %edi
f0108f29:	56                   	push   %esi
f0108f2a:	53                   	push   %ebx
f0108f2b:	83 ec 7c             	sub    $0x7c,%esp
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0108f2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f31:	89 04 24             	mov    %eax,(%esp)
f0108f34:	e8 0a ff ff ff       	call   f0108e43 <holding>
f0108f39:	85 c0                	test   %eax,%eax
f0108f3b:	0f 85 02 01 00 00    	jne    f0109043 <spin_unlock+0x11e>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0108f41:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f44:	83 c0 0c             	add    $0xc,%eax
f0108f47:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0108f4e:	00 
f0108f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108f53:	8d 45 a4             	lea    -0x5c(%ebp),%eax
f0108f56:	89 04 24             	mov    %eax,(%esp)
f0108f59:	e8 67 f2 ff ff       	call   f01081c5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0108f5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f61:	8b 40 08             	mov    0x8(%eax),%eax
f0108f64:	0f b6 00             	movzbl (%eax),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0108f67:	0f b6 f0             	movzbl %al,%esi
f0108f6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0108f6d:	8b 58 04             	mov    0x4(%eax),%ebx
f0108f70:	e8 ad fc ff ff       	call   f0108c22 <cpunum>
f0108f75:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0108f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0108f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108f81:	c7 04 24 9c af 10 f0 	movl   $0xf010af9c,(%esp)
f0108f88:	e8 23 c0 ff ff       	call   f0104fb0 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0108f8d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0108f94:	eb 7c                	jmp    f0109012 <spin_unlock+0xed>
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0108f96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108f99:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0108f9d:	8d 55 cc             	lea    -0x34(%ebp),%edx
f0108fa0:	89 54 24 04          	mov    %edx,0x4(%esp)
f0108fa4:	89 04 24             	mov    %eax,(%esp)
f0108fa7:	e8 e3 e3 ff ff       	call   f010738f <debuginfo_eip>
f0108fac:	85 c0                	test   %eax,%eax
f0108fae:	78 47                	js     f0108ff7 <spin_unlock+0xd2>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0108fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108fb3:	8b 54 85 a4          	mov    -0x5c(%ebp,%eax,4),%edx
f0108fb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0108fba:	89 d7                	mov    %edx,%edi
f0108fbc:	29 c7                	sub    %eax,%edi
f0108fbe:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0108fc1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0108fc4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0108fc7:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0108fca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108fcd:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0108fd1:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0108fd5:	89 74 24 14          	mov    %esi,0x14(%esp)
f0108fd9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0108fdd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0108fe1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0108fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0108fe9:	c7 04 24 d2 af 10 f0 	movl   $0xf010afd2,(%esp)
f0108ff0:	e8 bb bf ff ff       	call   f0104fb0 <cprintf>
f0108ff5:	eb 17                	jmp    f010900e <spin_unlock+0xe9>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0108ff7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0108ffa:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f0108ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109002:	c7 04 24 e9 af 10 f0 	movl   $0xf010afe9,(%esp)
f0109009:	e8 a2 bf ff ff       	call   f0104fb0 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010900e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f0109012:	83 7d e4 09          	cmpl   $0x9,-0x1c(%ebp)
f0109016:	7f 0f                	jg     f0109027 <spin_unlock+0x102>
f0109018:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010901b:	8b 44 85 a4          	mov    -0x5c(%ebp,%eax,4),%eax
f010901f:	85 c0                	test   %eax,%eax
f0109021:	0f 85 6f ff ff ff    	jne    f0108f96 <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0109027:	c7 44 24 08 f1 af 10 	movl   $0xf010aff1,0x8(%esp)
f010902e:	f0 
f010902f:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0109036:	00 
f0109037:	c7 04 24 8a af 10 f0 	movl   $0xf010af8a,(%esp)
f010903e:	e8 8c 72 ff ff       	call   f01002cf <_panic>
	}

	lk->pcs[0] = 0;
f0109043:	8b 45 08             	mov    0x8(%ebp),%eax
f0109046:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	lk->cpu = 0;
f010904d:	8b 45 08             	mov    0x8(%ebp),%eax
f0109050:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	// But the 2007 Intel 64 Architecture Memory Ordering White
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
f0109057:	8b 45 08             	mov    0x8(%ebp),%eax
f010905a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0109061:	00 
f0109062:	89 04 24             	mov    %eax,(%esp)
f0109065:	e8 4a fd ff ff       	call   f0108db4 <xchg>
}
f010906a:	83 c4 7c             	add    $0x7c,%esp
f010906d:	5b                   	pop    %ebx
f010906e:	5e                   	pop    %esi
f010906f:	5f                   	pop    %edi
f0109070:	5d                   	pop    %ebp
f0109071:	c3                   	ret    
f0109072:	66 90                	xchg   %ax,%ax
f0109074:	66 90                	xchg   %ax,%ax
f0109076:	66 90                	xchg   %ax,%ax
f0109078:	66 90                	xchg   %ax,%ax
f010907a:	66 90                	xchg   %ax,%ax
f010907c:	66 90                	xchg   %ax,%ax
f010907e:	66 90                	xchg   %ax,%ax

f0109080 <__udivdi3>:
f0109080:	55                   	push   %ebp
f0109081:	57                   	push   %edi
f0109082:	56                   	push   %esi
f0109083:	83 ec 0c             	sub    $0xc,%esp
f0109086:	8b 44 24 28          	mov    0x28(%esp),%eax
f010908a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010908e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0109092:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0109096:	85 c0                	test   %eax,%eax
f0109098:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010909c:	89 ea                	mov    %ebp,%edx
f010909e:	89 0c 24             	mov    %ecx,(%esp)
f01090a1:	75 2d                	jne    f01090d0 <__udivdi3+0x50>
f01090a3:	39 e9                	cmp    %ebp,%ecx
f01090a5:	77 61                	ja     f0109108 <__udivdi3+0x88>
f01090a7:	85 c9                	test   %ecx,%ecx
f01090a9:	89 ce                	mov    %ecx,%esi
f01090ab:	75 0b                	jne    f01090b8 <__udivdi3+0x38>
f01090ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01090b2:	31 d2                	xor    %edx,%edx
f01090b4:	f7 f1                	div    %ecx
f01090b6:	89 c6                	mov    %eax,%esi
f01090b8:	31 d2                	xor    %edx,%edx
f01090ba:	89 e8                	mov    %ebp,%eax
f01090bc:	f7 f6                	div    %esi
f01090be:	89 c5                	mov    %eax,%ebp
f01090c0:	89 f8                	mov    %edi,%eax
f01090c2:	f7 f6                	div    %esi
f01090c4:	89 ea                	mov    %ebp,%edx
f01090c6:	83 c4 0c             	add    $0xc,%esp
f01090c9:	5e                   	pop    %esi
f01090ca:	5f                   	pop    %edi
f01090cb:	5d                   	pop    %ebp
f01090cc:	c3                   	ret    
f01090cd:	8d 76 00             	lea    0x0(%esi),%esi
f01090d0:	39 e8                	cmp    %ebp,%eax
f01090d2:	77 24                	ja     f01090f8 <__udivdi3+0x78>
f01090d4:	0f bd e8             	bsr    %eax,%ebp
f01090d7:	83 f5 1f             	xor    $0x1f,%ebp
f01090da:	75 3c                	jne    f0109118 <__udivdi3+0x98>
f01090dc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01090e0:	39 34 24             	cmp    %esi,(%esp)
f01090e3:	0f 86 9f 00 00 00    	jbe    f0109188 <__udivdi3+0x108>
f01090e9:	39 d0                	cmp    %edx,%eax
f01090eb:	0f 82 97 00 00 00    	jb     f0109188 <__udivdi3+0x108>
f01090f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01090f8:	31 d2                	xor    %edx,%edx
f01090fa:	31 c0                	xor    %eax,%eax
f01090fc:	83 c4 0c             	add    $0xc,%esp
f01090ff:	5e                   	pop    %esi
f0109100:	5f                   	pop    %edi
f0109101:	5d                   	pop    %ebp
f0109102:	c3                   	ret    
f0109103:	90                   	nop
f0109104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109108:	89 f8                	mov    %edi,%eax
f010910a:	f7 f1                	div    %ecx
f010910c:	31 d2                	xor    %edx,%edx
f010910e:	83 c4 0c             	add    $0xc,%esp
f0109111:	5e                   	pop    %esi
f0109112:	5f                   	pop    %edi
f0109113:	5d                   	pop    %ebp
f0109114:	c3                   	ret    
f0109115:	8d 76 00             	lea    0x0(%esi),%esi
f0109118:	89 e9                	mov    %ebp,%ecx
f010911a:	8b 3c 24             	mov    (%esp),%edi
f010911d:	d3 e0                	shl    %cl,%eax
f010911f:	89 c6                	mov    %eax,%esi
f0109121:	b8 20 00 00 00       	mov    $0x20,%eax
f0109126:	29 e8                	sub    %ebp,%eax
f0109128:	89 c1                	mov    %eax,%ecx
f010912a:	d3 ef                	shr    %cl,%edi
f010912c:	89 e9                	mov    %ebp,%ecx
f010912e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0109132:	8b 3c 24             	mov    (%esp),%edi
f0109135:	09 74 24 08          	or     %esi,0x8(%esp)
f0109139:	89 d6                	mov    %edx,%esi
f010913b:	d3 e7                	shl    %cl,%edi
f010913d:	89 c1                	mov    %eax,%ecx
f010913f:	89 3c 24             	mov    %edi,(%esp)
f0109142:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109146:	d3 ee                	shr    %cl,%esi
f0109148:	89 e9                	mov    %ebp,%ecx
f010914a:	d3 e2                	shl    %cl,%edx
f010914c:	89 c1                	mov    %eax,%ecx
f010914e:	d3 ef                	shr    %cl,%edi
f0109150:	09 d7                	or     %edx,%edi
f0109152:	89 f2                	mov    %esi,%edx
f0109154:	89 f8                	mov    %edi,%eax
f0109156:	f7 74 24 08          	divl   0x8(%esp)
f010915a:	89 d6                	mov    %edx,%esi
f010915c:	89 c7                	mov    %eax,%edi
f010915e:	f7 24 24             	mull   (%esp)
f0109161:	39 d6                	cmp    %edx,%esi
f0109163:	89 14 24             	mov    %edx,(%esp)
f0109166:	72 30                	jb     f0109198 <__udivdi3+0x118>
f0109168:	8b 54 24 04          	mov    0x4(%esp),%edx
f010916c:	89 e9                	mov    %ebp,%ecx
f010916e:	d3 e2                	shl    %cl,%edx
f0109170:	39 c2                	cmp    %eax,%edx
f0109172:	73 05                	jae    f0109179 <__udivdi3+0xf9>
f0109174:	3b 34 24             	cmp    (%esp),%esi
f0109177:	74 1f                	je     f0109198 <__udivdi3+0x118>
f0109179:	89 f8                	mov    %edi,%eax
f010917b:	31 d2                	xor    %edx,%edx
f010917d:	e9 7a ff ff ff       	jmp    f01090fc <__udivdi3+0x7c>
f0109182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0109188:	31 d2                	xor    %edx,%edx
f010918a:	b8 01 00 00 00       	mov    $0x1,%eax
f010918f:	e9 68 ff ff ff       	jmp    f01090fc <__udivdi3+0x7c>
f0109194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109198:	8d 47 ff             	lea    -0x1(%edi),%eax
f010919b:	31 d2                	xor    %edx,%edx
f010919d:	83 c4 0c             	add    $0xc,%esp
f01091a0:	5e                   	pop    %esi
f01091a1:	5f                   	pop    %edi
f01091a2:	5d                   	pop    %ebp
f01091a3:	c3                   	ret    
f01091a4:	66 90                	xchg   %ax,%ax
f01091a6:	66 90                	xchg   %ax,%ax
f01091a8:	66 90                	xchg   %ax,%ax
f01091aa:	66 90                	xchg   %ax,%ax
f01091ac:	66 90                	xchg   %ax,%ax
f01091ae:	66 90                	xchg   %ax,%ax

f01091b0 <__umoddi3>:
f01091b0:	55                   	push   %ebp
f01091b1:	57                   	push   %edi
f01091b2:	56                   	push   %esi
f01091b3:	83 ec 14             	sub    $0x14,%esp
f01091b6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01091ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01091be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01091c2:	89 c7                	mov    %eax,%edi
f01091c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01091c8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01091cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01091d0:	89 34 24             	mov    %esi,(%esp)
f01091d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01091d7:	85 c0                	test   %eax,%eax
f01091d9:	89 c2                	mov    %eax,%edx
f01091db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01091df:	75 17                	jne    f01091f8 <__umoddi3+0x48>
f01091e1:	39 fe                	cmp    %edi,%esi
f01091e3:	76 4b                	jbe    f0109230 <__umoddi3+0x80>
f01091e5:	89 c8                	mov    %ecx,%eax
f01091e7:	89 fa                	mov    %edi,%edx
f01091e9:	f7 f6                	div    %esi
f01091eb:	89 d0                	mov    %edx,%eax
f01091ed:	31 d2                	xor    %edx,%edx
f01091ef:	83 c4 14             	add    $0x14,%esp
f01091f2:	5e                   	pop    %esi
f01091f3:	5f                   	pop    %edi
f01091f4:	5d                   	pop    %ebp
f01091f5:	c3                   	ret    
f01091f6:	66 90                	xchg   %ax,%ax
f01091f8:	39 f8                	cmp    %edi,%eax
f01091fa:	77 54                	ja     f0109250 <__umoddi3+0xa0>
f01091fc:	0f bd e8             	bsr    %eax,%ebp
f01091ff:	83 f5 1f             	xor    $0x1f,%ebp
f0109202:	75 5c                	jne    f0109260 <__umoddi3+0xb0>
f0109204:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0109208:	39 3c 24             	cmp    %edi,(%esp)
f010920b:	0f 87 e7 00 00 00    	ja     f01092f8 <__umoddi3+0x148>
f0109211:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0109215:	29 f1                	sub    %esi,%ecx
f0109217:	19 c7                	sbb    %eax,%edi
f0109219:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010921d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0109221:	8b 44 24 08          	mov    0x8(%esp),%eax
f0109225:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0109229:	83 c4 14             	add    $0x14,%esp
f010922c:	5e                   	pop    %esi
f010922d:	5f                   	pop    %edi
f010922e:	5d                   	pop    %ebp
f010922f:	c3                   	ret    
f0109230:	85 f6                	test   %esi,%esi
f0109232:	89 f5                	mov    %esi,%ebp
f0109234:	75 0b                	jne    f0109241 <__umoddi3+0x91>
f0109236:	b8 01 00 00 00       	mov    $0x1,%eax
f010923b:	31 d2                	xor    %edx,%edx
f010923d:	f7 f6                	div    %esi
f010923f:	89 c5                	mov    %eax,%ebp
f0109241:	8b 44 24 04          	mov    0x4(%esp),%eax
f0109245:	31 d2                	xor    %edx,%edx
f0109247:	f7 f5                	div    %ebp
f0109249:	89 c8                	mov    %ecx,%eax
f010924b:	f7 f5                	div    %ebp
f010924d:	eb 9c                	jmp    f01091eb <__umoddi3+0x3b>
f010924f:	90                   	nop
f0109250:	89 c8                	mov    %ecx,%eax
f0109252:	89 fa                	mov    %edi,%edx
f0109254:	83 c4 14             	add    $0x14,%esp
f0109257:	5e                   	pop    %esi
f0109258:	5f                   	pop    %edi
f0109259:	5d                   	pop    %ebp
f010925a:	c3                   	ret    
f010925b:	90                   	nop
f010925c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0109260:	8b 04 24             	mov    (%esp),%eax
f0109263:	be 20 00 00 00       	mov    $0x20,%esi
f0109268:	89 e9                	mov    %ebp,%ecx
f010926a:	29 ee                	sub    %ebp,%esi
f010926c:	d3 e2                	shl    %cl,%edx
f010926e:	89 f1                	mov    %esi,%ecx
f0109270:	d3 e8                	shr    %cl,%eax
f0109272:	89 e9                	mov    %ebp,%ecx
f0109274:	89 44 24 04          	mov    %eax,0x4(%esp)
f0109278:	8b 04 24             	mov    (%esp),%eax
f010927b:	09 54 24 04          	or     %edx,0x4(%esp)
f010927f:	89 fa                	mov    %edi,%edx
f0109281:	d3 e0                	shl    %cl,%eax
f0109283:	89 f1                	mov    %esi,%ecx
f0109285:	89 44 24 08          	mov    %eax,0x8(%esp)
f0109289:	8b 44 24 10          	mov    0x10(%esp),%eax
f010928d:	d3 ea                	shr    %cl,%edx
f010928f:	89 e9                	mov    %ebp,%ecx
f0109291:	d3 e7                	shl    %cl,%edi
f0109293:	89 f1                	mov    %esi,%ecx
f0109295:	d3 e8                	shr    %cl,%eax
f0109297:	89 e9                	mov    %ebp,%ecx
f0109299:	09 f8                	or     %edi,%eax
f010929b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010929f:	f7 74 24 04          	divl   0x4(%esp)
f01092a3:	d3 e7                	shl    %cl,%edi
f01092a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01092a9:	89 d7                	mov    %edx,%edi
f01092ab:	f7 64 24 08          	mull   0x8(%esp)
f01092af:	39 d7                	cmp    %edx,%edi
f01092b1:	89 c1                	mov    %eax,%ecx
f01092b3:	89 14 24             	mov    %edx,(%esp)
f01092b6:	72 2c                	jb     f01092e4 <__umoddi3+0x134>
f01092b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f01092bc:	72 22                	jb     f01092e0 <__umoddi3+0x130>
f01092be:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01092c2:	29 c8                	sub    %ecx,%eax
f01092c4:	19 d7                	sbb    %edx,%edi
f01092c6:	89 e9                	mov    %ebp,%ecx
f01092c8:	89 fa                	mov    %edi,%edx
f01092ca:	d3 e8                	shr    %cl,%eax
f01092cc:	89 f1                	mov    %esi,%ecx
f01092ce:	d3 e2                	shl    %cl,%edx
f01092d0:	89 e9                	mov    %ebp,%ecx
f01092d2:	d3 ef                	shr    %cl,%edi
f01092d4:	09 d0                	or     %edx,%eax
f01092d6:	89 fa                	mov    %edi,%edx
f01092d8:	83 c4 14             	add    $0x14,%esp
f01092db:	5e                   	pop    %esi
f01092dc:	5f                   	pop    %edi
f01092dd:	5d                   	pop    %ebp
f01092de:	c3                   	ret    
f01092df:	90                   	nop
f01092e0:	39 d7                	cmp    %edx,%edi
f01092e2:	75 da                	jne    f01092be <__umoddi3+0x10e>
f01092e4:	8b 14 24             	mov    (%esp),%edx
f01092e7:	89 c1                	mov    %eax,%ecx
f01092e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01092ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01092f1:	eb cb                	jmp    f01092be <__umoddi3+0x10e>
f01092f3:	90                   	nop
f01092f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01092f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01092fc:	0f 82 0f ff ff ff    	jb     f0109211 <__umoddi3+0x61>
f0109302:	e9 1a ff ff ff       	jmp    f0109221 <__umoddi3+0x71>
