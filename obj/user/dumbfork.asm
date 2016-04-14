
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 62 02 00 00       	call   800293 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800039:	e8 56 01 00 00       	call   800194 <dumbfork>
  80003e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800048:	eb 32                	jmp    80007c <umain+0x49>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80004a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80004e:	74 07                	je     800057 <umain+0x24>
  800050:	b8 40 16 80 00       	mov    $0x801640,%eax
  800055:	eb 05                	jmp    80005c <umain+0x29>
  800057:	b8 47 16 80 00       	mov    $0x801647,%eax
  80005c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800063:	89 44 24 04          	mov    %eax,0x4(%esp)
  800067:	c7 04 24 4d 16 80 00 	movl   $0x80164d,(%esp)
  80006e:	e8 9e 03 00 00       	call   800411 <cprintf>
		sys_yield();
  800073:	e8 12 11 00 00       	call   80118a <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800078:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80007c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800080:	74 07                	je     800089 <umain+0x56>
  800082:	b8 0a 00 00 00       	mov    $0xa,%eax
  800087:	eb 05                	jmp    80008e <umain+0x5b>
  800089:	b8 14 00 00 00       	mov    $0x14,%eax
  80008e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  800091:	7f b7                	jg     80004a <umain+0x17>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <duppage>:

void
duppage(envid_t dstenv, void *addr)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 38             	sub    $0x38,%esp
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80009b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8000a2:	00 
  8000a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ad:	89 04 24             	mov    %eax,(%esp)
  8000b0:	e8 19 11 00 00       	call   8011ce <sys_page_alloc>
  8000b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8000b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8000bc:	79 23                	jns    8000e1 <duppage+0x4c>
		panic("sys_page_alloc: %e", r);
  8000be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c5:	c7 44 24 08 5f 16 80 	movl   $0x80165f,0x8(%esp)
  8000cc:	00 
  8000cd:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d4:	00 
  8000d5:	c7 04 24 72 16 80 00 	movl   $0x801672,(%esp)
  8000dc:	e8 15 02 00 00       	call   8002f6 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8000e1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  8000f0:	00 
  8000f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000f8:	00 
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800100:	8b 45 08             	mov    0x8(%ebp),%eax
  800103:	89 04 24             	mov    %eax,(%esp)
  800106:	e8 04 11 00 00       	call   80120f <sys_page_map>
  80010b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80010e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800112:	79 23                	jns    800137 <duppage+0xa2>
		panic("sys_page_map: %e", r);
  800114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 82 16 80 	movl   $0x801682,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 72 16 80 00 	movl   $0x801672,(%esp)
  800132:	e8 bf 01 00 00       	call   8002f6 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800137:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80013e:	00 
  80013f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  80014d:	e8 e6 0b 00 00       	call   800d38 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800152:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800159:	00 
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 ef 10 00 00       	call   801255 <sys_page_unmap>
  800166:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80016d:	79 23                	jns    800192 <duppage+0xfd>
		panic("sys_page_unmap: %e", r);
  80016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800172:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800176:	c7 44 24 08 93 16 80 	movl   $0x801693,0x8(%esp)
  80017d:	00 
  80017e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800185:	00 
  800186:	c7 04 24 72 16 80 00 	movl   $0x801672,(%esp)
  80018d:	e8 64 01 00 00       	call   8002f6 <_panic>
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <dumbfork>:

envid_t
dumbfork(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 38             	sub    $0x38,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80019a:	b8 07 00 00 00       	mov    $0x7,%eax
  80019f:	cd 30                	int    $0x30
  8001a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8001a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
	// Allocate a new child environment.
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
  8001a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0)
  8001aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8001ae:	79 23                	jns    8001d3 <dumbfork+0x3f>
		panic("sys_exofork: %e", envid);
  8001b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b7:	c7 44 24 08 a6 16 80 	movl   $0x8016a6,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 72 16 80 00 	movl   $0x801672,(%esp)
  8001ce:	e8 23 01 00 00       	call   8002f6 <_panic>
	if (envid == 0) {
  8001d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8001d7:	75 29                	jne    800202 <dumbfork+0x6e>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8001d9:	e8 68 0f 00 00       	call   801146 <sys_getenvid>
  8001de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e3:	c1 e0 02             	shl    $0x2,%eax
  8001e6:	89 c2                	mov    %eax,%edx
  8001e8:	c1 e2 05             	shl    $0x5,%edx
  8001eb:	29 c2                	sub    %eax,%edx
  8001ed:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8001f3:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  8001f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fd:	e9 8f 00 00 00       	jmp    800291 <dumbfork+0xfd>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800202:	c7 45 e4 00 00 80 00 	movl   $0x800000,-0x1c(%ebp)
  800209:	eb 1d                	jmp    800228 <dumbfork+0x94>
		duppage(envid, addr);
  80020b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	e8 78 fe ff ff       	call   800095 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80021d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800220:	05 00 10 00 00       	add    $0x1000,%eax
  800225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022b:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800230:	72 d9                	jb     80020b <dumbfork+0x77>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800232:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800238:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80023b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	e8 46 fe ff ff       	call   800095 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80024f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800256:	00 
  800257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 35 10 00 00       	call   801297 <sys_env_set_status>
  800262:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800265:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800269:	79 23                	jns    80028e <dumbfork+0xfa>
		panic("sys_env_set_status: %e", r);
  80026b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	c7 44 24 08 b6 16 80 	movl   $0x8016b6,0x8(%esp)
  800279:	00 
  80027a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 72 16 80 00 	movl   $0x801672,(%esp)
  800289:	e8 68 00 00 00       	call   8002f6 <_panic>

	return envid;
  80028e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800299:	e8 a8 0e 00 00       	call   801146 <sys_getenvid>
  80029e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002a3:	c1 e0 02             	shl    $0x2,%eax
  8002a6:	89 c2                	mov    %eax,%edx
  8002a8:	c1 e2 05             	shl    $0x5,%edx
  8002ab:	29 c2                	sub    %eax,%edx
  8002ad:	89 d0                	mov    %edx,%eax
  8002af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002b4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8002bd:	7e 0a                	jle    8002c9 <libmain+0x36>
		binaryname = argv[0];
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c2:	8b 00                	mov    (%eax),%eax
  8002c4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	e8 58 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002db:	e8 02 00 00 00       	call   8002e2 <exit>
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ef:	e8 0f 0e 00 00       	call   801103 <sys_env_destroy>
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800300:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800303:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800309:	e8 38 0e 00 00       	call   801146 <sys_getenvid>
  80030e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800311:	89 54 24 10          	mov    %edx,0x10(%esp)
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80031c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	c7 04 24 d8 16 80 00 	movl   $0x8016d8,(%esp)
  80032b:	e8 e1 00 00 00       	call   800411 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800333:	89 44 24 04          	mov    %eax,0x4(%esp)
  800337:	8b 45 10             	mov    0x10(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	e8 6b 00 00 00       	call   8003ad <vcprintf>
	cprintf("\n");
  800342:	c7 04 24 fb 16 80 00 	movl   $0x8016fb,(%esp)
  800349:	e8 c3 00 00 00       	call   800411 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034e:	cc                   	int3   
  80034f:	eb fd                	jmp    80034e <_panic+0x58>

00800351 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	8d 48 01             	lea    0x1(%eax),%ecx
  80035f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800362:	89 0a                	mov    %ecx,(%edx)
  800364:	8b 55 08             	mov    0x8(%ebp),%edx
  800367:	89 d1                	mov    %edx,%ecx
  800369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	8b 00                	mov    (%eax),%eax
  800375:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037a:	75 20                	jne    80039c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80037c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037f:	8b 00                	mov    (%eax),%eax
  800381:	8b 55 0c             	mov    0xc(%ebp),%edx
  800384:	83 c2 08             	add    $0x8,%edx
  800387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038b:	89 14 24             	mov    %edx,(%esp)
  80038e:	e8 ea 0c 00 00       	call   80107d <sys_cputs>
		b->idx = 0;
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
  800396:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80039c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039f:	8b 40 04             	mov    0x4(%eax),%eax
  8003a2:	8d 50 01             	lea    0x1(%eax),%edx
  8003a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a8:	89 50 04             	mov    %edx,0x4(%eax)
}
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003b6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bd:	00 00 00 
	b.cnt = 0;
  8003c0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e2:	c7 04 24 51 03 80 00 	movl   $0x800351,(%esp)
  8003e9:	e8 bd 01 00 00       	call   8005ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ee:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fe:	83 c0 08             	add    $0x8,%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 74 0c 00 00       	call   80107d <sys_cputs>

	return b.cnt;
  800409:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800417:	8d 45 0c             	lea    0xc(%ebp),%eax
  80041a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80041d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800420:	89 44 24 04          	mov    %eax,0x4(%esp)
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	e8 7e ff ff ff       	call   8003ad <vcprintf>
  80042f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800432:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800435:	c9                   	leave  
  800436:	c3                   	ret    

00800437 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	53                   	push   %ebx
  80043b:	83 ec 34             	sub    $0x34,%esp
  80043e:	8b 45 10             	mov    0x10(%ebp),%eax
  800441:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044a:	8b 45 18             	mov    0x18(%ebp),%eax
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800455:	77 72                	ja     8004c9 <printnum+0x92>
  800457:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80045a:	72 05                	jb     800461 <printnum+0x2a>
  80045c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80045f:	77 68                	ja     8004c9 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800461:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800464:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800467:	8b 45 18             	mov    0x18(%ebp),%eax
  80046a:	ba 00 00 00 00       	mov    $0x0,%edx
  80046f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800473:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800477:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80047a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80047d:	89 04 24             	mov    %eax,(%esp)
  800480:	89 54 24 04          	mov    %edx,0x4(%esp)
  800484:	e8 17 0f 00 00       	call   8013a0 <__udivdi3>
  800489:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80048c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800490:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800494:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800497:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80049b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80049f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 82 ff ff ff       	call   800437 <printnum>
  8004b5:	eb 1c                	jmp    8004d3 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 20             	mov    0x20(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c7:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c9:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8004cd:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8004d1:	7f e4                	jg     8004b7 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d3:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8004e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f0:	e8 db 0f 00 00       	call   8014d0 <__umoddi3>
  8004f5:	05 c8 17 80 00       	add    $0x8017c8,%eax
  8004fa:	0f b6 00             	movzbl (%eax),%eax
  8004fd:	0f be c0             	movsbl %al,%eax
  800500:	8b 55 0c             	mov    0xc(%ebp),%edx
  800503:	89 54 24 04          	mov    %edx,0x4(%esp)
  800507:	89 04 24             	mov    %eax,(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	ff d0                	call   *%eax
}
  80050f:	83 c4 34             	add    $0x34,%esp
  800512:	5b                   	pop    %ebx
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800518:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80051c:	7e 14                	jle    800532 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	8b 00                	mov    (%eax),%eax
  800523:	8d 48 08             	lea    0x8(%eax),%ecx
  800526:	8b 55 08             	mov    0x8(%ebp),%edx
  800529:	89 0a                	mov    %ecx,(%edx)
  80052b:	8b 50 04             	mov    0x4(%eax),%edx
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	eb 30                	jmp    800562 <getuint+0x4d>
	else if (lflag)
  800532:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800536:	74 16                	je     80054e <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800538:	8b 45 08             	mov    0x8(%ebp),%eax
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	8d 48 04             	lea    0x4(%eax),%ecx
  800540:	8b 55 08             	mov    0x8(%ebp),%edx
  800543:	89 0a                	mov    %ecx,(%edx)
  800545:	8b 00                	mov    (%eax),%eax
  800547:	ba 00 00 00 00       	mov    $0x0,%edx
  80054c:	eb 14                	jmp    800562 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	8b 00                	mov    (%eax),%eax
  800553:	8d 48 04             	lea    0x4(%eax),%ecx
  800556:	8b 55 08             	mov    0x8(%ebp),%edx
  800559:	89 0a                	mov    %ecx,(%edx)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800562:	5d                   	pop    %ebp
  800563:	c3                   	ret    

00800564 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800567:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80056b:	7e 14                	jle    800581 <getint+0x1d>
		return va_arg(*ap, long long);
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	8b 00                	mov    (%eax),%eax
  800572:	8d 48 08             	lea    0x8(%eax),%ecx
  800575:	8b 55 08             	mov    0x8(%ebp),%edx
  800578:	89 0a                	mov    %ecx,(%edx)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	eb 28                	jmp    8005a9 <getint+0x45>
	else if (lflag)
  800581:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800585:	74 12                	je     800599 <getint+0x35>
		return va_arg(*ap, long);
  800587:	8b 45 08             	mov    0x8(%ebp),%eax
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	8d 48 04             	lea    0x4(%eax),%ecx
  80058f:	8b 55 08             	mov    0x8(%ebp),%edx
  800592:	89 0a                	mov    %ecx,(%edx)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	99                   	cltd   
  800597:	eb 10                	jmp    8005a9 <getint+0x45>
	else
		return va_arg(*ap, int);
  800599:	8b 45 08             	mov    0x8(%ebp),%eax
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	8d 48 04             	lea    0x4(%eax),%ecx
  8005a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a4:	89 0a                	mov    %ecx,(%edx)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	99                   	cltd   
}
  8005a9:	5d                   	pop    %ebp
  8005aa:	c3                   	ret    

008005ab <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ab:	55                   	push   %ebp
  8005ac:	89 e5                	mov    %esp,%ebp
  8005ae:	56                   	push   %esi
  8005af:	53                   	push   %ebx
  8005b0:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005b3:	eb 18                	jmp    8005cd <vprintfmt+0x22>
			if (ch == '\0')
  8005b5:	85 db                	test   %ebx,%ebx
  8005b7:	75 05                	jne    8005be <vprintfmt+0x13>
				return;
  8005b9:	e9 cc 03 00 00       	jmp    80098a <vprintfmt+0x3df>
			putch(ch, putdat);
  8005be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c5:	89 1c 24             	mov    %ebx,(%esp)
  8005c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cb:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8005d0:	8d 50 01             	lea    0x1(%eax),%edx
  8005d3:	89 55 10             	mov    %edx,0x10(%ebp)
  8005d6:	0f b6 00             	movzbl (%eax),%eax
  8005d9:	0f b6 d8             	movzbl %al,%ebx
  8005dc:	83 fb 25             	cmp    $0x25,%ebx
  8005df:	75 d4                	jne    8005b5 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8005e1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8005e5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8005ec:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005f3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8005fa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 45 10             	mov    0x10(%ebp),%eax
  800604:	8d 50 01             	lea    0x1(%eax),%edx
  800607:	89 55 10             	mov    %edx,0x10(%ebp)
  80060a:	0f b6 00             	movzbl (%eax),%eax
  80060d:	0f b6 d8             	movzbl %al,%ebx
  800610:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800613:	83 f8 55             	cmp    $0x55,%eax
  800616:	0f 87 3d 03 00 00    	ja     800959 <vprintfmt+0x3ae>
  80061c:	8b 04 85 ec 17 80 00 	mov    0x8017ec(,%eax,4),%eax
  800623:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800625:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800629:	eb d6                	jmp    800601 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80062b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80062f:	eb d0                	jmp    800601 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800631:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800638:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80063b:	89 d0                	mov    %edx,%eax
  80063d:	c1 e0 02             	shl    $0x2,%eax
  800640:	01 d0                	add    %edx,%eax
  800642:	01 c0                	add    %eax,%eax
  800644:	01 d8                	add    %ebx,%eax
  800646:	83 e8 30             	sub    $0x30,%eax
  800649:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80064c:	8b 45 10             	mov    0x10(%ebp),%eax
  80064f:	0f b6 00             	movzbl (%eax),%eax
  800652:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800655:	83 fb 2f             	cmp    $0x2f,%ebx
  800658:	7e 0b                	jle    800665 <vprintfmt+0xba>
  80065a:	83 fb 39             	cmp    $0x39,%ebx
  80065d:	7f 06                	jg     800665 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80065f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800663:	eb d3                	jmp    800638 <vprintfmt+0x8d>
			goto process_precision;
  800665:	eb 33                	jmp    80069a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8d 50 04             	lea    0x4(%eax),%edx
  80066d:	89 55 14             	mov    %edx,0x14(%ebp)
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800675:	eb 23                	jmp    80069a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800677:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067b:	79 0c                	jns    800689 <vprintfmt+0xde>
				width = 0;
  80067d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800684:	e9 78 ff ff ff       	jmp    800601 <vprintfmt+0x56>
  800689:	e9 73 ff ff ff       	jmp    800601 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80068e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800695:	e9 67 ff ff ff       	jmp    800601 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80069a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069e:	79 12                	jns    8006b2 <vprintfmt+0x107>
				width = precision, precision = -1;
  8006a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8006ad:	e9 4f ff ff ff       	jmp    800601 <vprintfmt+0x56>
  8006b2:	e9 4a ff ff ff       	jmp    800601 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b7:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8006bb:	e9 41 ff ff ff       	jmp    800601 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c9:	8b 00                	mov    (%eax),%eax
  8006cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d2:	89 04 24             	mov    %eax,(%esp)
  8006d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d8:	ff d0                	call   *%eax
			break;
  8006da:	e9 a5 02 00 00       	jmp    800984 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8006ea:	85 db                	test   %ebx,%ebx
  8006ec:	79 02                	jns    8006f0 <vprintfmt+0x145>
				err = -err;
  8006ee:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f0:	83 fb 09             	cmp    $0x9,%ebx
  8006f3:	7f 0b                	jg     800700 <vprintfmt+0x155>
  8006f5:	8b 34 9d a0 17 80 00 	mov    0x8017a0(,%ebx,4),%esi
  8006fc:	85 f6                	test   %esi,%esi
  8006fe:	75 23                	jne    800723 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800700:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800704:	c7 44 24 08 d9 17 80 	movl   $0x8017d9,0x8(%esp)
  80070b:	00 
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	e8 73 02 00 00       	call   800991 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80071e:	e9 61 02 00 00       	jmp    800984 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800723:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800727:	c7 44 24 08 e2 17 80 	movl   $0x8017e2,0x8(%esp)
  80072e:	00 
  80072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	8b 45 08             	mov    0x8(%ebp),%eax
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 50 02 00 00       	call   800991 <printfmt>
			break;
  800741:	e9 3e 02 00 00       	jmp    800984 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8d 50 04             	lea    0x4(%eax),%edx
  80074c:	89 55 14             	mov    %edx,0x14(%ebp)
  80074f:	8b 30                	mov    (%eax),%esi
  800751:	85 f6                	test   %esi,%esi
  800753:	75 05                	jne    80075a <vprintfmt+0x1af>
				p = "(null)";
  800755:	be e5 17 80 00       	mov    $0x8017e5,%esi
			if (width > 0 && padc != '-')
  80075a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80075e:	7e 37                	jle    800797 <vprintfmt+0x1ec>
  800760:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800764:	74 31                	je     800797 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800766:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076d:	89 34 24             	mov    %esi,(%esp)
  800770:	e8 39 03 00 00       	call   800aae <strnlen>
  800775:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800778:	eb 17                	jmp    800791 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80077a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800781:	89 54 24 04          	mov    %edx,0x4(%esp)
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
  80078b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80078d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800791:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800795:	7f e3                	jg     80077a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800797:	eb 38                	jmp    8007d1 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800799:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079d:	74 1f                	je     8007be <vprintfmt+0x213>
  80079f:	83 fb 1f             	cmp    $0x1f,%ebx
  8007a2:	7e 05                	jle    8007a9 <vprintfmt+0x1fe>
  8007a4:	83 fb 7e             	cmp    $0x7e,%ebx
  8007a7:	7e 15                	jle    8007be <vprintfmt+0x213>
					putch('?', putdat);
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	ff d0                	call   *%eax
  8007bc:	eb 0f                	jmp    8007cd <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8007be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	89 1c 24             	mov    %ebx,(%esp)
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007cd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	8d 70 01             	lea    0x1(%eax),%esi
  8007d6:	0f b6 00             	movzbl (%eax),%eax
  8007d9:	0f be d8             	movsbl %al,%ebx
  8007dc:	85 db                	test   %ebx,%ebx
  8007de:	74 10                	je     8007f0 <vprintfmt+0x245>
  8007e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007e4:	78 b3                	js     800799 <vprintfmt+0x1ee>
  8007e6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007ee:	79 a9                	jns    800799 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f0:	eb 17                	jmp    800809 <vprintfmt+0x25e>
				putch(' ', putdat);
  8007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800805:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800809:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080d:	7f e3                	jg     8007f2 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80080f:	e9 70 01 00 00       	jmp    800984 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800814:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 3e fd ff ff       	call   800564 <getint>
  800826:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800829:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80082c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800832:	85 d2                	test   %edx,%edx
  800834:	79 26                	jns    80085c <vprintfmt+0x2b1>
				putch('-', putdat);
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	ff d0                	call   *%eax
				num = -(long long) num;
  800849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084f:	f7 d8                	neg    %eax
  800851:	83 d2 00             	adc    $0x0,%edx
  800854:	f7 da                	neg    %edx
  800856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800859:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80085c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800863:	e9 a8 00 00 00       	jmp    800910 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800868:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	8d 45 14             	lea    0x14(%ebp),%eax
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	e8 9b fc ff ff       	call   800515 <getuint>
  80087a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80087d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800880:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800887:	e9 84 00 00 00       	jmp    800910 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80088c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 77 fc ff ff       	call   800515 <getuint>
  80089e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008a1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8008a4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8008ab:	eb 63                	jmp    800910 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	ff d0                	call   *%eax
			putch('x', putdat);
  8008c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d6:	8d 50 04             	lea    0x4(%eax),%edx
  8008d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008dc:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008e8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8008ef:	eb 1f                	jmp    800910 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fb:	89 04 24             	mov    %eax,(%esp)
  8008fe:	e8 12 fc ff ff       	call   800515 <getuint>
  800903:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800906:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800909:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800910:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800914:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800917:	89 54 24 18          	mov    %edx,0x18(%esp)
  80091b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80091e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800922:	89 44 24 10          	mov    %eax,0x10(%esp)
  800926:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800929:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80092c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800930:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	e8 f1 fa ff ff       	call   800437 <printnum>
			break;
  800946:	eb 3c                	jmp    800984 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	89 1c 24             	mov    %ebx,(%esp)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	ff d0                	call   *%eax
			break;
  800957:	eb 2b                	jmp    800984 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800959:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800960:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800970:	eb 04                	jmp    800976 <vprintfmt+0x3cb>
  800972:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800976:	8b 45 10             	mov    0x10(%ebp),%eax
  800979:	83 e8 01             	sub    $0x1,%eax
  80097c:	0f b6 00             	movzbl (%eax),%eax
  80097f:	3c 25                	cmp    $0x25,%al
  800981:	75 ef                	jne    800972 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800983:	90                   	nop
		}
	}
  800984:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800985:	e9 43 fc ff ff       	jmp    8005cd <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80098a:	83 c4 40             	add    $0x40,%esp
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800997:	8d 45 14             	lea    0x14(%ebp),%eax
  80099a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80099d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 04 24             	mov    %eax,(%esp)
  8009b8:	e8 ee fb ff ff       	call   8005ab <vprintfmt>
	va_end(ap);
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8009c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c5:	8b 40 08             	mov    0x8(%eax),%eax
  8009c8:	8d 50 01             	lea    0x1(%eax),%edx
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d4:	8b 10                	mov    (%eax),%edx
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	8b 40 04             	mov    0x4(%eax),%eax
  8009dc:	39 c2                	cmp    %eax,%edx
  8009de:	73 12                	jae    8009f2 <sprintputch+0x33>
		*b->buf++ = ch;
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	8b 00                	mov    (%eax),%eax
  8009e5:	8d 48 01             	lea    0x1(%eax),%ecx
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 0a                	mov    %ecx,(%edx)
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f0:	88 10                	mov    %dl,(%eax)
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a03:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	01 d0                	add    %edx,%eax
  800a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a15:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a19:	74 06                	je     800a21 <vsnprintf+0x2d>
  800a1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1f:	7f 07                	jg     800a28 <vsnprintf+0x34>
		return -E_INVAL;
  800a21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a26:	eb 2a                	jmp    800a52 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a28:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a36:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3d:	c7 04 24 bf 09 80 00 	movl   $0x8009bf,(%esp)
  800a44:	e8 62 fb ff ff       	call   8005ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a4c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800a60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a67:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	89 04 24             	mov    %eax,(%esp)
  800a7b:	e8 74 ff ff ff       	call   8009f4 <vsnprintf>
  800a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a95:	eb 08                	jmp    800a9f <strlen+0x17>
		n++;
  800a97:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a9b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	0f b6 00             	movzbl (%eax),%eax
  800aa5:	84 c0                	test   %al,%al
  800aa7:	75 ee                	jne    800a97 <strlen+0xf>
		n++;
	return n;
  800aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800aac:	c9                   	leave  
  800aad:	c3                   	ret    

00800aae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800abb:	eb 0c                	jmp    800ac9 <strnlen+0x1b>
		n++;
  800abd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ac1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ac5:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800ac9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acd:	74 0a                	je     800ad9 <strnlen+0x2b>
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	0f b6 00             	movzbl (%eax),%eax
  800ad5:	84 c0                	test   %al,%al
  800ad7:	75 e4                	jne    800abd <strnlen+0xf>
		n++;
	return n;
  800ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800aea:	90                   	nop
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8d 50 01             	lea    0x1(%eax),%edx
  800af1:	89 55 08             	mov    %edx,0x8(%ebp)
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af7:	8d 4a 01             	lea    0x1(%edx),%ecx
  800afa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	88 10                	mov    %dl,(%eax)
  800b02:	0f b6 00             	movzbl (%eax),%eax
  800b05:	84 c0                	test   %al,%al
  800b07:	75 e2                	jne    800aeb <strcpy+0xd>
		/* do nothing */;
	return ret;
  800b09:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800b0c:	c9                   	leave  
  800b0d:	c3                   	ret    

00800b0e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	89 04 24             	mov    %eax,(%esp)
  800b1a:	e8 69 ff ff ff       	call   800a88 <strlen>
  800b1f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800b22:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	01 c2                	add    %eax,%edx
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b31:	89 14 24             	mov    %edx,(%esp)
  800b34:	e8 a5 ff ff ff       	call   800ade <strcpy>
	return dst;
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800b4a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800b51:	eb 23                	jmp    800b76 <strncpy+0x38>
		*dst++ = *src;
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	8d 50 01             	lea    0x1(%eax),%edx
  800b59:	89 55 08             	mov    %edx,0x8(%ebp)
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5f:	0f b6 12             	movzbl (%edx),%edx
  800b62:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b67:	0f b6 00             	movzbl (%eax),%eax
  800b6a:	84 c0                	test   %al,%al
  800b6c:	74 04                	je     800b72 <strncpy+0x34>
			src++;
  800b6e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b72:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800b76:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b79:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b7c:	72 d5                	jb     800b53 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800b7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800b8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b93:	74 33                	je     800bc8 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800b95:	eb 17                	jmp    800bae <strlcpy+0x2b>
			*dst++ = *src++;
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	8d 50 01             	lea    0x1(%eax),%edx
  800b9d:	89 55 08             	mov    %edx,0x8(%ebp)
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba3:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ba6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ba9:	0f b6 12             	movzbl (%edx),%edx
  800bac:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800bae:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800bb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bb6:	74 0a                	je     800bc2 <strlcpy+0x3f>
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	0f b6 00             	movzbl (%eax),%eax
  800bbe:	84 c0                	test   %al,%al
  800bc0:	75 d5                	jne    800b97 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bce:	29 c2                	sub    %eax,%edx
  800bd0:	89 d0                	mov    %edx,%eax
}
  800bd2:	c9                   	leave  
  800bd3:	c3                   	ret    

00800bd4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800bd7:	eb 08                	jmp    800be1 <strcmp+0xd>
		p++, q++;
  800bd9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bdd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800be1:	8b 45 08             	mov    0x8(%ebp),%eax
  800be4:	0f b6 00             	movzbl (%eax),%eax
  800be7:	84 c0                	test   %al,%al
  800be9:	74 10                	je     800bfb <strcmp+0x27>
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	0f b6 10             	movzbl (%eax),%edx
  800bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf4:	0f b6 00             	movzbl (%eax),%eax
  800bf7:	38 c2                	cmp    %al,%dl
  800bf9:	74 de                	je     800bd9 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	0f b6 00             	movzbl (%eax),%eax
  800c01:	0f b6 d0             	movzbl %al,%edx
  800c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c07:	0f b6 00             	movzbl (%eax),%eax
  800c0a:	0f b6 c0             	movzbl %al,%eax
  800c0d:	29 c2                	sub    %eax,%edx
  800c0f:	89 d0                	mov    %edx,%eax
}
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800c16:	eb 0c                	jmp    800c24 <strncmp+0x11>
		n--, p++, q++;
  800c18:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800c1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c20:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c28:	74 1a                	je     800c44 <strncmp+0x31>
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	0f b6 00             	movzbl (%eax),%eax
  800c30:	84 c0                	test   %al,%al
  800c32:	74 10                	je     800c44 <strncmp+0x31>
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	0f b6 10             	movzbl (%eax),%edx
  800c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3d:	0f b6 00             	movzbl (%eax),%eax
  800c40:	38 c2                	cmp    %al,%dl
  800c42:	74 d4                	je     800c18 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800c44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c48:	75 07                	jne    800c51 <strncmp+0x3e>
		return 0;
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	eb 16                	jmp    800c67 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	0f b6 00             	movzbl (%eax),%eax
  800c57:	0f b6 d0             	movzbl %al,%edx
  800c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5d:	0f b6 00             	movzbl (%eax),%eax
  800c60:	0f b6 c0             	movzbl %al,%eax
  800c63:	29 c2                	sub    %eax,%edx
  800c65:	89 d0                	mov    %edx,%eax
}
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 04             	sub    $0x4,%esp
  800c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c72:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800c75:	eb 14                	jmp    800c8b <strchr+0x22>
		if (*s == c)
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	0f b6 00             	movzbl (%eax),%eax
  800c7d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800c80:	75 05                	jne    800c87 <strchr+0x1e>
			return (char *) s;
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	eb 13                	jmp    800c9a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c87:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	0f b6 00             	movzbl (%eax),%eax
  800c91:	84 c0                	test   %al,%al
  800c93:	75 e2                	jne    800c77 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9a:	c9                   	leave  
  800c9b:	c3                   	ret    

00800c9c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 04             	sub    $0x4,%esp
  800ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca5:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ca8:	eb 11                	jmp    800cbb <strfind+0x1f>
		if (*s == c)
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cad:	0f b6 00             	movzbl (%eax),%eax
  800cb0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800cb3:	75 02                	jne    800cb7 <strfind+0x1b>
			break;
  800cb5:	eb 0e                	jmp    800cc5 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cb7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	0f b6 00             	movzbl (%eax),%eax
  800cc1:	84 c0                	test   %al,%al
  800cc3:	75 e5                	jne    800caa <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
	char *p;

	if (n == 0)
  800cce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd2:	75 05                	jne    800cd9 <memset+0xf>
		return v;
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	eb 5c                	jmp    800d35 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	83 e0 03             	and    $0x3,%eax
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	75 41                	jne    800d24 <memset+0x5a>
  800ce3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce6:	83 e0 03             	and    $0x3,%eax
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	75 37                	jne    800d24 <memset+0x5a>
		c &= 0xFF;
  800ced:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf7:	c1 e0 18             	shl    $0x18,%eax
  800cfa:	89 c2                	mov    %eax,%edx
  800cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cff:	c1 e0 10             	shl    $0x10,%eax
  800d02:	09 c2                	or     %eax,%edx
  800d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d07:	c1 e0 08             	shl    $0x8,%eax
  800d0a:	09 d0                	or     %edx,%eax
  800d0c:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d12:	c1 e8 02             	shr    $0x2,%eax
  800d15:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1d:	89 d7                	mov    %edx,%edi
  800d1f:	fc                   	cld    
  800d20:	f3 ab                	rep stos %eax,%es:(%edi)
  800d22:	eb 0e                	jmp    800d32 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d2d:	89 d7                	mov    %edx,%edi
  800d2f:	fc                   	cld    
  800d30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d44:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800d4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d50:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d53:	73 6d                	jae    800dc2 <memmove+0x8a>
  800d55:	8b 45 10             	mov    0x10(%ebp),%eax
  800d58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d5b:	01 d0                	add    %edx,%eax
  800d5d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d60:	76 60                	jbe    800dc2 <memmove+0x8a>
		s += n;
  800d62:	8b 45 10             	mov    0x10(%ebp),%eax
  800d65:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800d68:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d71:	83 e0 03             	and    $0x3,%eax
  800d74:	85 c0                	test   %eax,%eax
  800d76:	75 2f                	jne    800da7 <memmove+0x6f>
  800d78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d7b:	83 e0 03             	and    $0x3,%eax
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	75 25                	jne    800da7 <memmove+0x6f>
  800d82:	8b 45 10             	mov    0x10(%ebp),%eax
  800d85:	83 e0 03             	and    $0x3,%eax
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	75 1b                	jne    800da7 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d8f:	83 e8 04             	sub    $0x4,%eax
  800d92:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d95:	83 ea 04             	sub    $0x4,%edx
  800d98:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d9b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d9e:	89 c7                	mov    %eax,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	fd                   	std    
  800da3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da5:	eb 18                	jmp    800dbf <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800daa:	8d 50 ff             	lea    -0x1(%eax),%edx
  800dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db0:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800db3:	8b 45 10             	mov    0x10(%ebp),%eax
  800db6:	89 d7                	mov    %edx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	89 c1                	mov    %eax,%ecx
  800dbc:	fd                   	std    
  800dbd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dbf:	fc                   	cld    
  800dc0:	eb 45                	jmp    800e07 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc5:	83 e0 03             	and    $0x3,%eax
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	75 2b                	jne    800df7 <memmove+0xbf>
  800dcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dcf:	83 e0 03             	and    $0x3,%eax
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	75 21                	jne    800df7 <memmove+0xbf>
  800dd6:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd9:	83 e0 03             	and    $0x3,%eax
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	75 17                	jne    800df7 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800de0:	8b 45 10             	mov    0x10(%ebp),%eax
  800de3:	c1 e8 02             	shr    $0x2,%eax
  800de6:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800de8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800deb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dee:	89 c7                	mov    %eax,%edi
  800df0:	89 d6                	mov    %edx,%esi
  800df2:	fc                   	cld    
  800df3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800df5:	eb 10                	jmp    800e07 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800df7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dfa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e00:	89 c7                	mov    %eax,%edi
  800e02:	89 d6                	mov    %edx,%esi
  800e04:	fc                   	cld    
  800e05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e0a:	83 c4 10             	add    $0x10,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e18:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	89 04 24             	mov    %eax,(%esp)
  800e2c:	e8 07 ff ff ff       	call   800d38 <memmove>
}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    

00800e33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800e45:	eb 30                	jmp    800e77 <memcmp+0x44>
		if (*s1 != *s2)
  800e47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e4a:	0f b6 10             	movzbl (%eax),%edx
  800e4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e50:	0f b6 00             	movzbl (%eax),%eax
  800e53:	38 c2                	cmp    %al,%dl
  800e55:	74 18                	je     800e6f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e5a:	0f b6 00             	movzbl (%eax),%eax
  800e5d:	0f b6 d0             	movzbl %al,%edx
  800e60:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e63:	0f b6 00             	movzbl (%eax),%eax
  800e66:	0f b6 c0             	movzbl %al,%eax
  800e69:	29 c2                	sub    %eax,%edx
  800e6b:	89 d0                	mov    %edx,%eax
  800e6d:	eb 1a                	jmp    800e89 <memcmp+0x56>
		s1++, s2++;
  800e6f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800e73:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e77:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e7d:	89 55 10             	mov    %edx,0x10(%ebp)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	75 c3                	jne    800e47 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800e91:	8b 45 10             	mov    0x10(%ebp),%eax
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	01 d0                	add    %edx,%eax
  800e99:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800e9c:	eb 13                	jmp    800eb1 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	0f b6 10             	movzbl (%eax),%edx
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	38 c2                	cmp    %al,%dl
  800ea9:	75 02                	jne    800ead <memfind+0x22>
			break;
  800eab:	eb 0c                	jmp    800eb9 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ead:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800eb7:	72 e5                	jb     800e9e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ec4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ecb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed2:	eb 04                	jmp    800ed8 <strtol+0x1a>
		s++;
  800ed4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	0f b6 00             	movzbl (%eax),%eax
  800ede:	3c 20                	cmp    $0x20,%al
  800ee0:	74 f2                	je     800ed4 <strtol+0x16>
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	0f b6 00             	movzbl (%eax),%eax
  800ee8:	3c 09                	cmp    $0x9,%al
  800eea:	74 e8                	je     800ed4 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	0f b6 00             	movzbl (%eax),%eax
  800ef2:	3c 2b                	cmp    $0x2b,%al
  800ef4:	75 06                	jne    800efc <strtol+0x3e>
		s++;
  800ef6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800efa:	eb 15                	jmp    800f11 <strtol+0x53>
	else if (*s == '-')
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	0f b6 00             	movzbl (%eax),%eax
  800f02:	3c 2d                	cmp    $0x2d,%al
  800f04:	75 0b                	jne    800f11 <strtol+0x53>
		s++, neg = 1;
  800f06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f0a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f15:	74 06                	je     800f1d <strtol+0x5f>
  800f17:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800f1b:	75 24                	jne    800f41 <strtol+0x83>
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	0f b6 00             	movzbl (%eax),%eax
  800f23:	3c 30                	cmp    $0x30,%al
  800f25:	75 1a                	jne    800f41 <strtol+0x83>
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2a:	83 c0 01             	add    $0x1,%eax
  800f2d:	0f b6 00             	movzbl (%eax),%eax
  800f30:	3c 78                	cmp    $0x78,%al
  800f32:	75 0d                	jne    800f41 <strtol+0x83>
		s += 2, base = 16;
  800f34:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800f38:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800f3f:	eb 2a                	jmp    800f6b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800f41:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f45:	75 17                	jne    800f5e <strtol+0xa0>
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	0f b6 00             	movzbl (%eax),%eax
  800f4d:	3c 30                	cmp    $0x30,%al
  800f4f:	75 0d                	jne    800f5e <strtol+0xa0>
		s++, base = 8;
  800f51:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f55:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800f5c:	eb 0d                	jmp    800f6b <strtol+0xad>
	else if (base == 0)
  800f5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f62:	75 07                	jne    800f6b <strtol+0xad>
		base = 10;
  800f64:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	0f b6 00             	movzbl (%eax),%eax
  800f71:	3c 2f                	cmp    $0x2f,%al
  800f73:	7e 1b                	jle    800f90 <strtol+0xd2>
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	0f b6 00             	movzbl (%eax),%eax
  800f7b:	3c 39                	cmp    $0x39,%al
  800f7d:	7f 11                	jg     800f90 <strtol+0xd2>
			dig = *s - '0';
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	0f b6 00             	movzbl (%eax),%eax
  800f85:	0f be c0             	movsbl %al,%eax
  800f88:	83 e8 30             	sub    $0x30,%eax
  800f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f8e:	eb 48                	jmp    800fd8 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	0f b6 00             	movzbl (%eax),%eax
  800f96:	3c 60                	cmp    $0x60,%al
  800f98:	7e 1b                	jle    800fb5 <strtol+0xf7>
  800f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9d:	0f b6 00             	movzbl (%eax),%eax
  800fa0:	3c 7a                	cmp    $0x7a,%al
  800fa2:	7f 11                	jg     800fb5 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	0f b6 00             	movzbl (%eax),%eax
  800faa:	0f be c0             	movsbl %al,%eax
  800fad:	83 e8 57             	sub    $0x57,%eax
  800fb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fb3:	eb 23                	jmp    800fd8 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb8:	0f b6 00             	movzbl (%eax),%eax
  800fbb:	3c 40                	cmp    $0x40,%al
  800fbd:	7e 3d                	jle    800ffc <strtol+0x13e>
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	0f b6 00             	movzbl (%eax),%eax
  800fc5:	3c 5a                	cmp    $0x5a,%al
  800fc7:	7f 33                	jg     800ffc <strtol+0x13e>
			dig = *s - 'A' + 10;
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	0f b6 00             	movzbl (%eax),%eax
  800fcf:	0f be c0             	movsbl %al,%eax
  800fd2:	83 e8 37             	sub    $0x37,%eax
  800fd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800fde:	7c 02                	jl     800fe2 <strtol+0x124>
			break;
  800fe0:	eb 1a                	jmp    800ffc <strtol+0x13e>
		s++, val = (val * base) + dig;
  800fe2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fe6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fe9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fed:	89 c2                	mov    %eax,%edx
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	01 d0                	add    %edx,%eax
  800ff4:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ff7:	e9 6f ff ff ff       	jmp    800f6b <strtol+0xad>

	if (endptr)
  800ffc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801000:	74 08                	je     80100a <strtol+0x14c>
		*endptr = (char *) s;
  801002:	8b 45 0c             	mov    0xc(%ebp),%eax
  801005:	8b 55 08             	mov    0x8(%ebp),%edx
  801008:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80100a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80100e:	74 07                	je     801017 <strtol+0x159>
  801010:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801013:	f7 d8                	neg    %eax
  801015:	eb 03                	jmp    80101a <strtol+0x15c>
  801017:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	8b 55 10             	mov    0x10(%ebp),%edx
  80102b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80102e:	8b 5d 18             	mov    0x18(%ebp),%ebx
  801031:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  801034:	8b 75 20             	mov    0x20(%ebp),%esi
  801037:	cd 30                	int    $0x30
  801039:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801040:	74 30                	je     801072 <syscall+0x56>
  801042:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801046:	7e 2a                	jle    801072 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  801048:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801056:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  80105d:	00 
  80105e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801065:	00 
  801066:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  80106d:	e8 84 f2 ff ff       	call   8002f6 <_panic>

	return ret;
  801072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801075:	83 c4 3c             	add    $0x3c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80108d:	00 
  80108e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801095:	00 
  801096:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80109d:	00 
  80109e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b8:	e8 5f ff ff ff       	call   80101c <syscall>
}
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <sys_cgetc>:

int
sys_cgetc(void)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010c5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cc:	00 
  8010cd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010fc:	e8 1b ff ff ff       	call   80101c <syscall>
}
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
  80110c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801113:	00 
  801114:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80111b:	00 
  80111c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801123:	00 
  801124:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80112b:	00 
  80112c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801130:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801137:	00 
  801138:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80113f:	e8 d8 fe ff ff       	call   80101c <syscall>
}
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80114c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801153:	00 
  801154:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115b:	00 
  80115c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801163:	00 
  801164:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80116b:	00 
  80116c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801183:	e8 94 fe ff ff       	call   80101c <syscall>
}
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <sys_yield>:

void
sys_yield(void)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801190:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801197:	00 
  801198:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80119f:	00 
  8011a0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011af:	00 
  8011b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011bf:	00 
  8011c0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8011c7:	e8 50 fe ff ff       	call   80101c <syscall>
}
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8011d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011da:	8b 45 08             	mov    0x8(%ebp),%eax
  8011dd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011e4:	00 
  8011e5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011ec:	00 
  8011ed:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8011f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801200:	00 
  801201:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801208:	e8 0f fe ff ff       	call   80101c <syscall>
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801217:	8b 75 18             	mov    0x18(%ebp),%esi
  80121a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80121d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801220:	8b 55 0c             	mov    0xc(%ebp),%edx
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	89 74 24 18          	mov    %esi,0x18(%esp)
  80122a:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80122e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801232:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801241:	00 
  801242:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801249:	e8 ce fd ff ff       	call   80101c <syscall>
}
  80124e:	83 c4 20             	add    $0x20,%esp
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80125b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125e:	8b 45 08             	mov    0x8(%ebp),%eax
  801261:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801268:	00 
  801269:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801270:	00 
  801271:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801278:	00 
  801279:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80127d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801281:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801290:	e8 87 fd ff ff       	call   80101c <syscall>
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80129d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012aa:	00 
  8012ab:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012b2:	00 
  8012b3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012ba:	00 
  8012bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012ca:	00 
  8012cb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8012d2:	e8 45 fd ff ff       	call   80101c <syscall>
}
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8012df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012f4:	00 
  8012f5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012fc:	00 
  8012fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801301:	89 44 24 08          	mov    %eax,0x8(%esp)
  801305:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80130c:	00 
  80130d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801314:	e8 03 fd ff ff       	call   80101c <syscall>
}
  801319:	c9                   	leave  
  80131a:	c3                   	ret    

0080131b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801321:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801324:	8b 55 10             	mov    0x10(%ebp),%edx
  801327:	8b 45 08             	mov    0x8(%ebp),%eax
  80132a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801331:	00 
  801332:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801336:	89 54 24 10          	mov    %edx,0x10(%esp)
  80133a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801341:	89 44 24 08          	mov    %eax,0x8(%esp)
  801345:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80134c:	00 
  80134d:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801354:	e8 c3 fc ff ff       	call   80101c <syscall>
}
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80136b:	00 
  80136c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801373:	00 
  801374:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80137b:	00 
  80137c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801383:	00 
  801384:	89 44 24 08          	mov    %eax,0x8(%esp)
  801388:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80138f:	00 
  801390:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801397:	e8 80 fc ff ff       	call   80101c <syscall>
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__udivdi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8013ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013bc:	89 ea                	mov    %ebp,%edx
  8013be:	89 0c 24             	mov    %ecx,(%esp)
  8013c1:	75 2d                	jne    8013f0 <__udivdi3+0x50>
  8013c3:	39 e9                	cmp    %ebp,%ecx
  8013c5:	77 61                	ja     801428 <__udivdi3+0x88>
  8013c7:	85 c9                	test   %ecx,%ecx
  8013c9:	89 ce                	mov    %ecx,%esi
  8013cb:	75 0b                	jne    8013d8 <__udivdi3+0x38>
  8013cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8013d2:	31 d2                	xor    %edx,%edx
  8013d4:	f7 f1                	div    %ecx
  8013d6:	89 c6                	mov    %eax,%esi
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	89 e8                	mov    %ebp,%eax
  8013dc:	f7 f6                	div    %esi
  8013de:	89 c5                	mov    %eax,%ebp
  8013e0:	89 f8                	mov    %edi,%eax
  8013e2:	f7 f6                	div    %esi
  8013e4:	89 ea                	mov    %ebp,%edx
  8013e6:	83 c4 0c             	add    $0xc,%esp
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    
  8013ed:	8d 76 00             	lea    0x0(%esi),%esi
  8013f0:	39 e8                	cmp    %ebp,%eax
  8013f2:	77 24                	ja     801418 <__udivdi3+0x78>
  8013f4:	0f bd e8             	bsr    %eax,%ebp
  8013f7:	83 f5 1f             	xor    $0x1f,%ebp
  8013fa:	75 3c                	jne    801438 <__udivdi3+0x98>
  8013fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801400:	39 34 24             	cmp    %esi,(%esp)
  801403:	0f 86 9f 00 00 00    	jbe    8014a8 <__udivdi3+0x108>
  801409:	39 d0                	cmp    %edx,%eax
  80140b:	0f 82 97 00 00 00    	jb     8014a8 <__udivdi3+0x108>
  801411:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801418:	31 d2                	xor    %edx,%edx
  80141a:	31 c0                	xor    %eax,%eax
  80141c:	83 c4 0c             	add    $0xc,%esp
  80141f:	5e                   	pop    %esi
  801420:	5f                   	pop    %edi
  801421:	5d                   	pop    %ebp
  801422:	c3                   	ret    
  801423:	90                   	nop
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	89 f8                	mov    %edi,%eax
  80142a:	f7 f1                	div    %ecx
  80142c:	31 d2                	xor    %edx,%edx
  80142e:	83 c4 0c             	add    $0xc,%esp
  801431:	5e                   	pop    %esi
  801432:	5f                   	pop    %edi
  801433:	5d                   	pop    %ebp
  801434:	c3                   	ret    
  801435:	8d 76 00             	lea    0x0(%esi),%esi
  801438:	89 e9                	mov    %ebp,%ecx
  80143a:	8b 3c 24             	mov    (%esp),%edi
  80143d:	d3 e0                	shl    %cl,%eax
  80143f:	89 c6                	mov    %eax,%esi
  801441:	b8 20 00 00 00       	mov    $0x20,%eax
  801446:	29 e8                	sub    %ebp,%eax
  801448:	89 c1                	mov    %eax,%ecx
  80144a:	d3 ef                	shr    %cl,%edi
  80144c:	89 e9                	mov    %ebp,%ecx
  80144e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801452:	8b 3c 24             	mov    (%esp),%edi
  801455:	09 74 24 08          	or     %esi,0x8(%esp)
  801459:	89 d6                	mov    %edx,%esi
  80145b:	d3 e7                	shl    %cl,%edi
  80145d:	89 c1                	mov    %eax,%ecx
  80145f:	89 3c 24             	mov    %edi,(%esp)
  801462:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801466:	d3 ee                	shr    %cl,%esi
  801468:	89 e9                	mov    %ebp,%ecx
  80146a:	d3 e2                	shl    %cl,%edx
  80146c:	89 c1                	mov    %eax,%ecx
  80146e:	d3 ef                	shr    %cl,%edi
  801470:	09 d7                	or     %edx,%edi
  801472:	89 f2                	mov    %esi,%edx
  801474:	89 f8                	mov    %edi,%eax
  801476:	f7 74 24 08          	divl   0x8(%esp)
  80147a:	89 d6                	mov    %edx,%esi
  80147c:	89 c7                	mov    %eax,%edi
  80147e:	f7 24 24             	mull   (%esp)
  801481:	39 d6                	cmp    %edx,%esi
  801483:	89 14 24             	mov    %edx,(%esp)
  801486:	72 30                	jb     8014b8 <__udivdi3+0x118>
  801488:	8b 54 24 04          	mov    0x4(%esp),%edx
  80148c:	89 e9                	mov    %ebp,%ecx
  80148e:	d3 e2                	shl    %cl,%edx
  801490:	39 c2                	cmp    %eax,%edx
  801492:	73 05                	jae    801499 <__udivdi3+0xf9>
  801494:	3b 34 24             	cmp    (%esp),%esi
  801497:	74 1f                	je     8014b8 <__udivdi3+0x118>
  801499:	89 f8                	mov    %edi,%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	e9 7a ff ff ff       	jmp    80141c <__udivdi3+0x7c>
  8014a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014a8:	31 d2                	xor    %edx,%edx
  8014aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8014af:	e9 68 ff ff ff       	jmp    80141c <__udivdi3+0x7c>
  8014b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	83 c4 0c             	add    $0xc,%esp
  8014c0:	5e                   	pop    %esi
  8014c1:	5f                   	pop    %edi
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    
  8014c4:	66 90                	xchg   %ax,%ax
  8014c6:	66 90                	xchg   %ax,%ax
  8014c8:	66 90                	xchg   %ax,%ax
  8014ca:	66 90                	xchg   %ax,%ax
  8014cc:	66 90                	xchg   %ax,%ax
  8014ce:	66 90                	xchg   %ax,%ax

008014d0 <__umoddi3>:
  8014d0:	55                   	push   %ebp
  8014d1:	57                   	push   %edi
  8014d2:	56                   	push   %esi
  8014d3:	83 ec 14             	sub    $0x14,%esp
  8014d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014e2:	89 c7                	mov    %eax,%edi
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014f0:	89 34 24             	mov    %esi,(%esp)
  8014f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014ff:	75 17                	jne    801518 <__umoddi3+0x48>
  801501:	39 fe                	cmp    %edi,%esi
  801503:	76 4b                	jbe    801550 <__umoddi3+0x80>
  801505:	89 c8                	mov    %ecx,%eax
  801507:	89 fa                	mov    %edi,%edx
  801509:	f7 f6                	div    %esi
  80150b:	89 d0                	mov    %edx,%eax
  80150d:	31 d2                	xor    %edx,%edx
  80150f:	83 c4 14             	add    $0x14,%esp
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    
  801516:	66 90                	xchg   %ax,%ax
  801518:	39 f8                	cmp    %edi,%eax
  80151a:	77 54                	ja     801570 <__umoddi3+0xa0>
  80151c:	0f bd e8             	bsr    %eax,%ebp
  80151f:	83 f5 1f             	xor    $0x1f,%ebp
  801522:	75 5c                	jne    801580 <__umoddi3+0xb0>
  801524:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801528:	39 3c 24             	cmp    %edi,(%esp)
  80152b:	0f 87 e7 00 00 00    	ja     801618 <__umoddi3+0x148>
  801531:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801535:	29 f1                	sub    %esi,%ecx
  801537:	19 c7                	sbb    %eax,%edi
  801539:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80153d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801541:	8b 44 24 08          	mov    0x8(%esp),%eax
  801545:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801549:	83 c4 14             	add    $0x14,%esp
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    
  801550:	85 f6                	test   %esi,%esi
  801552:	89 f5                	mov    %esi,%ebp
  801554:	75 0b                	jne    801561 <__umoddi3+0x91>
  801556:	b8 01 00 00 00       	mov    $0x1,%eax
  80155b:	31 d2                	xor    %edx,%edx
  80155d:	f7 f6                	div    %esi
  80155f:	89 c5                	mov    %eax,%ebp
  801561:	8b 44 24 04          	mov    0x4(%esp),%eax
  801565:	31 d2                	xor    %edx,%edx
  801567:	f7 f5                	div    %ebp
  801569:	89 c8                	mov    %ecx,%eax
  80156b:	f7 f5                	div    %ebp
  80156d:	eb 9c                	jmp    80150b <__umoddi3+0x3b>
  80156f:	90                   	nop
  801570:	89 c8                	mov    %ecx,%eax
  801572:	89 fa                	mov    %edi,%edx
  801574:	83 c4 14             	add    $0x14,%esp
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    
  80157b:	90                   	nop
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	8b 04 24             	mov    (%esp),%eax
  801583:	be 20 00 00 00       	mov    $0x20,%esi
  801588:	89 e9                	mov    %ebp,%ecx
  80158a:	29 ee                	sub    %ebp,%esi
  80158c:	d3 e2                	shl    %cl,%edx
  80158e:	89 f1                	mov    %esi,%ecx
  801590:	d3 e8                	shr    %cl,%eax
  801592:	89 e9                	mov    %ebp,%ecx
  801594:	89 44 24 04          	mov    %eax,0x4(%esp)
  801598:	8b 04 24             	mov    (%esp),%eax
  80159b:	09 54 24 04          	or     %edx,0x4(%esp)
  80159f:	89 fa                	mov    %edi,%edx
  8015a1:	d3 e0                	shl    %cl,%eax
  8015a3:	89 f1                	mov    %esi,%ecx
  8015a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8015ad:	d3 ea                	shr    %cl,%edx
  8015af:	89 e9                	mov    %ebp,%ecx
  8015b1:	d3 e7                	shl    %cl,%edi
  8015b3:	89 f1                	mov    %esi,%ecx
  8015b5:	d3 e8                	shr    %cl,%eax
  8015b7:	89 e9                	mov    %ebp,%ecx
  8015b9:	09 f8                	or     %edi,%eax
  8015bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015bf:	f7 74 24 04          	divl   0x4(%esp)
  8015c3:	d3 e7                	shl    %cl,%edi
  8015c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015c9:	89 d7                	mov    %edx,%edi
  8015cb:	f7 64 24 08          	mull   0x8(%esp)
  8015cf:	39 d7                	cmp    %edx,%edi
  8015d1:	89 c1                	mov    %eax,%ecx
  8015d3:	89 14 24             	mov    %edx,(%esp)
  8015d6:	72 2c                	jb     801604 <__umoddi3+0x134>
  8015d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015dc:	72 22                	jb     801600 <__umoddi3+0x130>
  8015de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015e2:	29 c8                	sub    %ecx,%eax
  8015e4:	19 d7                	sbb    %edx,%edi
  8015e6:	89 e9                	mov    %ebp,%ecx
  8015e8:	89 fa                	mov    %edi,%edx
  8015ea:	d3 e8                	shr    %cl,%eax
  8015ec:	89 f1                	mov    %esi,%ecx
  8015ee:	d3 e2                	shl    %cl,%edx
  8015f0:	89 e9                	mov    %ebp,%ecx
  8015f2:	d3 ef                	shr    %cl,%edi
  8015f4:	09 d0                	or     %edx,%eax
  8015f6:	89 fa                	mov    %edi,%edx
  8015f8:	83 c4 14             	add    $0x14,%esp
  8015fb:	5e                   	pop    %esi
  8015fc:	5f                   	pop    %edi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    
  8015ff:	90                   	nop
  801600:	39 d7                	cmp    %edx,%edi
  801602:	75 da                	jne    8015de <__umoddi3+0x10e>
  801604:	8b 14 24             	mov    (%esp),%edx
  801607:	89 c1                	mov    %eax,%ecx
  801609:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80160d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801611:	eb cb                	jmp    8015de <__umoddi3+0x10e>
  801613:	90                   	nop
  801614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801618:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80161c:	0f 82 0f ff ff ff    	jb     801531 <__umoddi3+0x61>
  801622:	e9 1a ff ff ff       	jmp    801541 <__umoddi3+0x71>
