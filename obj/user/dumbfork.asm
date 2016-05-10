
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
  800050:	b8 00 17 80 00       	mov    $0x801700,%eax
  800055:	eb 05                	jmp    80005c <umain+0x29>
  800057:	b8 07 17 80 00       	mov    $0x801707,%eax
  80005c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800063:	89 44 24 04          	mov    %eax,0x4(%esp)
  800067:	c7 04 24 0d 17 80 00 	movl   $0x80170d,(%esp)
  80006e:	e8 8e 03 00 00       	call   800401 <cprintf>
		sys_yield();
  800073:	e8 02 11 00 00       	call   80117a <sys_yield>

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
  8000b0:	e8 09 11 00 00       	call   8011be <sys_page_alloc>
  8000b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8000b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8000bc:	79 23                	jns    8000e1 <duppage+0x4c>
		panic("sys_page_alloc: %e", r);
  8000be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c5:	c7 44 24 08 1f 17 80 	movl   $0x80171f,0x8(%esp)
  8000cc:	00 
  8000cd:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d4:	00 
  8000d5:	c7 04 24 32 17 80 00 	movl   $0x801732,(%esp)
  8000dc:	e8 05 02 00 00       	call   8002e6 <_panic>
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
  800106:	e8 f4 10 00 00       	call   8011ff <sys_page_map>
  80010b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80010e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800112:	79 23                	jns    800137 <duppage+0xa2>
		panic("sys_page_map: %e", r);
  800114:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 42 17 80 	movl   $0x801742,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 32 17 80 00 	movl   $0x801732,(%esp)
  800132:	e8 af 01 00 00       	call   8002e6 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  800137:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80013e:	00 
  80013f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  80014d:	e8 d6 0b 00 00       	call   800d28 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800152:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800159:	00 
  80015a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800161:	e8 df 10 00 00       	call   801245 <sys_page_unmap>
  800166:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80016d:	79 23                	jns    800192 <duppage+0xfd>
		panic("sys_page_unmap: %e", r);
  80016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800172:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800176:	c7 44 24 08 53 17 80 	movl   $0x801753,0x8(%esp)
  80017d:	00 
  80017e:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800185:	00 
  800186:	c7 04 24 32 17 80 00 	movl   $0x801732,(%esp)
  80018d:	e8 54 01 00 00       	call   8002e6 <_panic>
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
  8001b7:	c7 44 24 08 66 17 80 	movl   $0x801766,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 32 17 80 00 	movl   $0x801732,(%esp)
  8001ce:	e8 13 01 00 00       	call   8002e6 <_panic>
	if (envid == 0) {
  8001d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8001d7:	75 29                	jne    800202 <dumbfork+0x6e>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8001d9:	e8 58 0f 00 00       	call   801136 <sys_getenvid>
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
  80025d:	e8 25 10 00 00       	call   801287 <sys_env_set_status>
  800262:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800265:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800269:	79 23                	jns    80028e <dumbfork+0xfa>
		panic("sys_env_set_status: %e", r);
  80026b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80026e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800272:	c7 44 24 08 76 17 80 	movl   $0x801776,0x8(%esp)
  800279:	00 
  80027a:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 32 17 80 00 	movl   $0x801732,(%esp)
  800289:	e8 58 00 00 00       	call   8002e6 <_panic>

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
  800299:	e8 98 0e 00 00       	call   801136 <sys_getenvid>
  80029e:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002a3:	c1 e0 02             	shl    $0x2,%eax
  8002a6:	89 c2                	mov    %eax,%edx
  8002a8:	c1 e2 05             	shl    $0x5,%edx
  8002ab:	29 c2                	sub    %eax,%edx
  8002ad:	89 d0                	mov    %edx,%eax
  8002af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002b4:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	e8 68 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002cb:	e8 02 00 00 00       	call   8002d2 <exit>
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002df:	e8 0f 0e 00 00       	call   8010f3 <sys_env_destroy>
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	53                   	push   %ebx
  8002ea:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8002f0:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002f9:	e8 38 0e 00 00       	call   801136 <sys_getenvid>
  8002fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800301:	89 54 24 10          	mov    %edx,0x10(%esp)
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	c7 04 24 98 17 80 00 	movl   $0x801798,(%esp)
  80031b:	e8 e1 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800320:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800323:	89 44 24 04          	mov    %eax,0x4(%esp)
  800327:	8b 45 10             	mov    0x10(%ebp),%eax
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	e8 6b 00 00 00       	call   80039d <vcprintf>
	cprintf("\n");
  800332:	c7 04 24 bb 17 80 00 	movl   $0x8017bb,(%esp)
  800339:	e8 c3 00 00 00       	call   800401 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033e:	cc                   	int3   
  80033f:	eb fd                	jmp    80033e <_panic+0x58>

00800341 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800347:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034a:	8b 00                	mov    (%eax),%eax
  80034c:	8d 48 01             	lea    0x1(%eax),%ecx
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	89 0a                	mov    %ecx,(%edx)
  800354:	8b 55 08             	mov    0x8(%ebp),%edx
  800357:	89 d1                	mov    %edx,%ecx
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800360:	8b 45 0c             	mov    0xc(%ebp),%eax
  800363:	8b 00                	mov    (%eax),%eax
  800365:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036a:	75 20                	jne    80038c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036f:	8b 00                	mov    (%eax),%eax
  800371:	8b 55 0c             	mov    0xc(%ebp),%edx
  800374:	83 c2 08             	add    $0x8,%edx
  800377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037b:	89 14 24             	mov    %edx,(%esp)
  80037e:	e8 ea 0c 00 00       	call   80106d <sys_cputs>
		b->idx = 0;
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
  800386:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038f:	8b 40 04             	mov    0x4(%eax),%eax
  800392:	8d 50 01             	lea    0x1(%eax),%edx
  800395:	8b 45 0c             	mov    0xc(%ebp),%eax
  800398:	89 50 04             	mov    %edx,0x4(%eax)
}
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ad:	00 00 00 
	b.cnt = 0;
  8003b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d2:	c7 04 24 41 03 80 00 	movl   $0x800341,(%esp)
  8003d9:	e8 bd 01 00 00       	call   80059b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003de:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ee:	83 c0 08             	add    $0x8,%eax
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	e8 74 0c 00 00       	call   80106d <sys_cputs>

	return b.cnt;
  8003f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800407:	8d 45 0c             	lea    0xc(%ebp),%eax
  80040a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80040d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800410:	89 44 24 04          	mov    %eax,0x4(%esp)
  800414:	8b 45 08             	mov    0x8(%ebp),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	e8 7e ff ff ff       	call   80039d <vcprintf>
  80041f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800422:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	53                   	push   %ebx
  80042b:	83 ec 34             	sub    $0x34,%esp
  80042e:	8b 45 10             	mov    0x10(%ebp),%eax
  800431:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043a:	8b 45 18             	mov    0x18(%ebp),%eax
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800445:	77 72                	ja     8004b9 <printnum+0x92>
  800447:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80044a:	72 05                	jb     800451 <printnum+0x2a>
  80044c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80044f:	77 68                	ja     8004b9 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800451:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800454:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800457:	8b 45 18             	mov    0x18(%ebp),%eax
  80045a:	ba 00 00 00 00       	mov    $0x0,%edx
  80045f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800463:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80046a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	89 54 24 04          	mov    %edx,0x4(%esp)
  800474:	e8 e7 0f 00 00       	call   801460 <__udivdi3>
  800479:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80047c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800480:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800484:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800487:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80048b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
  800496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049a:	8b 45 08             	mov    0x8(%ebp),%eax
  80049d:	89 04 24             	mov    %eax,(%esp)
  8004a0:	e8 82 ff ff ff       	call   800427 <printnum>
  8004a5:	eb 1c                	jmp    8004c3 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ae:	8b 45 20             	mov    0x20(%ebp),%eax
  8004b1:	89 04 24             	mov    %eax,(%esp)
  8004b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b7:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004b9:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8004bd:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8004c1:	7f e4                	jg     8004a7 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c3:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8004c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8004d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e0:	e8 ab 10 00 00       	call   801590 <__umoddi3>
  8004e5:	05 88 18 80 00       	add    $0x801888,%eax
  8004ea:	0f b6 00             	movzbl (%eax),%eax
  8004ed:	0f be c0             	movsbl %al,%eax
  8004f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	ff d0                	call   *%eax
}
  8004ff:	83 c4 34             	add    $0x34,%esp
  800502:	5b                   	pop    %ebx
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800508:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80050c:	7e 14                	jle    800522 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	8b 00                	mov    (%eax),%eax
  800513:	8d 48 08             	lea    0x8(%eax),%ecx
  800516:	8b 55 08             	mov    0x8(%ebp),%edx
  800519:	89 0a                	mov    %ecx,(%edx)
  80051b:	8b 50 04             	mov    0x4(%eax),%edx
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	eb 30                	jmp    800552 <getuint+0x4d>
	else if (lflag)
  800522:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800526:	74 16                	je     80053e <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800528:	8b 45 08             	mov    0x8(%ebp),%eax
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	8d 48 04             	lea    0x4(%eax),%ecx
  800530:	8b 55 08             	mov    0x8(%ebp),%edx
  800533:	89 0a                	mov    %ecx,(%edx)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	ba 00 00 00 00       	mov    $0x0,%edx
  80053c:	eb 14                	jmp    800552 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80053e:	8b 45 08             	mov    0x8(%ebp),%eax
  800541:	8b 00                	mov    (%eax),%eax
  800543:	8d 48 04             	lea    0x4(%eax),%ecx
  800546:	8b 55 08             	mov    0x8(%ebp),%edx
  800549:	89 0a                	mov    %ecx,(%edx)
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800552:	5d                   	pop    %ebp
  800553:	c3                   	ret    

00800554 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800557:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80055b:	7e 14                	jle    800571 <getint+0x1d>
		return va_arg(*ap, long long);
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	8d 48 08             	lea    0x8(%eax),%ecx
  800565:	8b 55 08             	mov    0x8(%ebp),%edx
  800568:	89 0a                	mov    %ecx,(%edx)
  80056a:	8b 50 04             	mov    0x4(%eax),%edx
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	eb 28                	jmp    800599 <getint+0x45>
	else if (lflag)
  800571:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800575:	74 12                	je     800589 <getint+0x35>
		return va_arg(*ap, long);
  800577:	8b 45 08             	mov    0x8(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	8d 48 04             	lea    0x4(%eax),%ecx
  80057f:	8b 55 08             	mov    0x8(%ebp),%edx
  800582:	89 0a                	mov    %ecx,(%edx)
  800584:	8b 00                	mov    (%eax),%eax
  800586:	99                   	cltd   
  800587:	eb 10                	jmp    800599 <getint+0x45>
	else
		return va_arg(*ap, int);
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	8d 48 04             	lea    0x4(%eax),%ecx
  800591:	8b 55 08             	mov    0x8(%ebp),%edx
  800594:	89 0a                	mov    %ecx,(%edx)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	99                   	cltd   
}
  800599:	5d                   	pop    %ebp
  80059a:	c3                   	ret    

0080059b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	56                   	push   %esi
  80059f:	53                   	push   %ebx
  8005a0:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a3:	eb 18                	jmp    8005bd <vprintfmt+0x22>
			if (ch == '\0')
  8005a5:	85 db                	test   %ebx,%ebx
  8005a7:	75 05                	jne    8005ae <vprintfmt+0x13>
				return;
  8005a9:	e9 cc 03 00 00       	jmp    80097a <vprintfmt+0x3df>
			putch(ch, putdat);
  8005ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b5:	89 1c 24             	mov    %ebx,(%esp)
  8005b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bb:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c0:	8d 50 01             	lea    0x1(%eax),%edx
  8005c3:	89 55 10             	mov    %edx,0x10(%ebp)
  8005c6:	0f b6 00             	movzbl (%eax),%eax
  8005c9:	0f b6 d8             	movzbl %al,%ebx
  8005cc:	83 fb 25             	cmp    $0x25,%ebx
  8005cf:	75 d4                	jne    8005a5 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8005d1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8005d5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8005dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8005ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f4:	8d 50 01             	lea    0x1(%eax),%edx
  8005f7:	89 55 10             	mov    %edx,0x10(%ebp)
  8005fa:	0f b6 00             	movzbl (%eax),%eax
  8005fd:	0f b6 d8             	movzbl %al,%ebx
  800600:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800603:	83 f8 55             	cmp    $0x55,%eax
  800606:	0f 87 3d 03 00 00    	ja     800949 <vprintfmt+0x3ae>
  80060c:	8b 04 85 ac 18 80 00 	mov    0x8018ac(,%eax,4),%eax
  800613:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800615:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800619:	eb d6                	jmp    8005f1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80061b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80061f:	eb d0                	jmp    8005f1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800621:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800628:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062b:	89 d0                	mov    %edx,%eax
  80062d:	c1 e0 02             	shl    $0x2,%eax
  800630:	01 d0                	add    %edx,%eax
  800632:	01 c0                	add    %eax,%eax
  800634:	01 d8                	add    %ebx,%eax
  800636:	83 e8 30             	sub    $0x30,%eax
  800639:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80063c:	8b 45 10             	mov    0x10(%ebp),%eax
  80063f:	0f b6 00             	movzbl (%eax),%eax
  800642:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800645:	83 fb 2f             	cmp    $0x2f,%ebx
  800648:	7e 0b                	jle    800655 <vprintfmt+0xba>
  80064a:	83 fb 39             	cmp    $0x39,%ebx
  80064d:	7f 06                	jg     800655 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80064f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800653:	eb d3                	jmp    800628 <vprintfmt+0x8d>
			goto process_precision;
  800655:	eb 33                	jmp    80068a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800665:	eb 23                	jmp    80068a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	79 0c                	jns    800679 <vprintfmt+0xde>
				width = 0;
  80066d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800674:	e9 78 ff ff ff       	jmp    8005f1 <vprintfmt+0x56>
  800679:	e9 73 ff ff ff       	jmp    8005f1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80067e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800685:	e9 67 ff ff ff       	jmp    8005f1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80068a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068e:	79 12                	jns    8006a2 <vprintfmt+0x107>
				width = precision, precision = -1;
  800690:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800693:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800696:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80069d:	e9 4f ff ff ff       	jmp    8005f1 <vprintfmt+0x56>
  8006a2:	e9 4a ff ff ff       	jmp    8005f1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006a7:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8006ab:	e9 41 ff ff ff       	jmp    8005f1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c2:	89 04 24             	mov    %eax,(%esp)
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	ff d0                	call   *%eax
			break;
  8006ca:	e9 a5 02 00 00       	jmp    800974 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 04             	lea    0x4(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8006da:	85 db                	test   %ebx,%ebx
  8006dc:	79 02                	jns    8006e0 <vprintfmt+0x145>
				err = -err;
  8006de:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e0:	83 fb 09             	cmp    $0x9,%ebx
  8006e3:	7f 0b                	jg     8006f0 <vprintfmt+0x155>
  8006e5:	8b 34 9d 60 18 80 00 	mov    0x801860(,%ebx,4),%esi
  8006ec:	85 f6                	test   %esi,%esi
  8006ee:	75 23                	jne    800713 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8006f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006f4:	c7 44 24 08 99 18 80 	movl   $0x801899,0x8(%esp)
  8006fb:	00 
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	89 04 24             	mov    %eax,(%esp)
  800709:	e8 73 02 00 00       	call   800981 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80070e:	e9 61 02 00 00       	jmp    800974 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800713:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800717:	c7 44 24 08 a2 18 80 	movl   $0x8018a2,0x8(%esp)
  80071e:	00 
  80071f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800722:	89 44 24 04          	mov    %eax,0x4(%esp)
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	89 04 24             	mov    %eax,(%esp)
  80072c:	e8 50 02 00 00       	call   800981 <printfmt>
			break;
  800731:	e9 3e 02 00 00       	jmp    800974 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 50 04             	lea    0x4(%eax),%edx
  80073c:	89 55 14             	mov    %edx,0x14(%ebp)
  80073f:	8b 30                	mov    (%eax),%esi
  800741:	85 f6                	test   %esi,%esi
  800743:	75 05                	jne    80074a <vprintfmt+0x1af>
				p = "(null)";
  800745:	be a5 18 80 00       	mov    $0x8018a5,%esi
			if (width > 0 && padc != '-')
  80074a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80074e:	7e 37                	jle    800787 <vprintfmt+0x1ec>
  800750:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800754:	74 31                	je     800787 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800756:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	89 34 24             	mov    %esi,(%esp)
  800760:	e8 39 03 00 00       	call   800a9e <strnlen>
  800765:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800768:	eb 17                	jmp    800781 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80076a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80076e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800771:	89 54 24 04          	mov    %edx,0x4(%esp)
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80077d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800781:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800785:	7f e3                	jg     80076a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800787:	eb 38                	jmp    8007c1 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800789:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80078d:	74 1f                	je     8007ae <vprintfmt+0x213>
  80078f:	83 fb 1f             	cmp    $0x1f,%ebx
  800792:	7e 05                	jle    800799 <vprintfmt+0x1fe>
  800794:	83 fb 7e             	cmp    $0x7e,%ebx
  800797:	7e 15                	jle    8007ae <vprintfmt+0x213>
					putch('?', putdat);
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	ff d0                	call   *%eax
  8007ac:	eb 0f                	jmp    8007bd <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b5:	89 1c 24             	mov    %ebx,(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007bd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	8d 70 01             	lea    0x1(%eax),%esi
  8007c6:	0f b6 00             	movzbl (%eax),%eax
  8007c9:	0f be d8             	movsbl %al,%ebx
  8007cc:	85 db                	test   %ebx,%ebx
  8007ce:	74 10                	je     8007e0 <vprintfmt+0x245>
  8007d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007d4:	78 b3                	js     800789 <vprintfmt+0x1ee>
  8007d6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007de:	79 a9                	jns    800789 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007e0:	eb 17                	jmp    8007f9 <vprintfmt+0x25e>
				putch(' ', putdat);
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007f5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007fd:	7f e3                	jg     8007e2 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8007ff:	e9 70 01 00 00       	jmp    800974 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800804:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 3e fd ff ff       	call   800554 <getint>
  800816:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800819:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80081c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800822:	85 d2                	test   %edx,%edx
  800824:	79 26                	jns    80084c <vprintfmt+0x2b1>
				putch('-', putdat);
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	ff d0                	call   *%eax
				num = -(long long) num;
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	f7 d8                	neg    %eax
  800841:	83 d2 00             	adc    $0x0,%edx
  800844:	f7 da                	neg    %edx
  800846:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800849:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80084c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800853:	e9 a8 00 00 00       	jmp    800900 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800858:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80085b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085f:	8d 45 14             	lea    0x14(%ebp),%eax
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	e8 9b fc ff ff       	call   800505 <getuint>
  80086a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80086d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800870:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800877:	e9 84 00 00 00       	jmp    800900 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80087c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80087f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 77 fc ff ff       	call   800505 <getuint>
  80088e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800891:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800894:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80089b:	eb 63                	jmp    800900 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	ff d0                	call   *%eax
			putch('x', putdat);
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 04             	lea    0x4(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cc:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008d8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8008df:	eb 1f                	jmp    800900 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8008e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	e8 12 fc ff ff       	call   800505 <getuint>
  8008f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8008f9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800900:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800904:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800907:	89 54 24 18          	mov    %edx,0x18(%esp)
  80090b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80090e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800912:	89 44 24 10          	mov    %eax,0x10(%esp)
  800916:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800919:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80091c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800920:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	e8 f1 fa ff ff       	call   800427 <printnum>
			break;
  800936:	eb 3c                	jmp    800974 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093f:	89 1c 24             	mov    %ebx,(%esp)
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	ff d0                	call   *%eax
			break;
  800947:	eb 2b                	jmp    800974 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800960:	eb 04                	jmp    800966 <vprintfmt+0x3cb>
  800962:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800966:	8b 45 10             	mov    0x10(%ebp),%eax
  800969:	83 e8 01             	sub    $0x1,%eax
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	3c 25                	cmp    $0x25,%al
  800971:	75 ef                	jne    800962 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800973:	90                   	nop
		}
	}
  800974:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800975:	e9 43 fc ff ff       	jmp    8005bd <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80097a:	83 c4 40             	add    $0x40,%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800987:	8d 45 14             	lea    0x14(%ebp),%eax
  80098a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80098d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800990:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800994:	8b 45 10             	mov    0x10(%ebp),%eax
  800997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	e8 ee fb ff ff       	call   80059b <vprintfmt>
	va_end(ap);
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	8b 40 08             	mov    0x8(%eax),%eax
  8009b8:	8d 50 01             	lea    0x1(%eax),%edx
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	8b 10                	mov    (%eax),%edx
  8009c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c9:	8b 40 04             	mov    0x4(%eax),%eax
  8009cc:	39 c2                	cmp    %eax,%edx
  8009ce:	73 12                	jae    8009e2 <sprintputch+0x33>
		*b->buf++ = ch;
  8009d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d3:	8b 00                	mov    (%eax),%eax
  8009d5:	8d 48 01             	lea    0x1(%eax),%ecx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	89 0a                	mov    %ecx,(%edx)
  8009dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e0:	88 10                	mov    %dl,(%eax)
}
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	01 d0                	add    %edx,%eax
  8009fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a05:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a09:	74 06                	je     800a11 <vsnprintf+0x2d>
  800a0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a0f:	7f 07                	jg     800a18 <vsnprintf+0x34>
		return -E_INVAL;
  800a11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a16:	eb 2a                	jmp    800a42 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a22:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a26:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2d:	c7 04 24 af 09 80 00 	movl   $0x8009af,(%esp)
  800a34:	e8 62 fb ff ff       	call   80059b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a3c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a57:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	89 04 24             	mov    %eax,(%esp)
  800a6b:	e8 74 ff ff ff       	call   8009e4 <vsnprintf>
  800a70:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800a7e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a85:	eb 08                	jmp    800a8f <strlen+0x17>
		n++;
  800a87:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	0f b6 00             	movzbl (%eax),%eax
  800a95:	84 c0                	test   %al,%al
  800a97:	75 ee                	jne    800a87 <strlen+0xf>
		n++;
	return n;
  800a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800aab:	eb 0c                	jmp    800ab9 <strnlen+0x1b>
		n++;
  800aad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ab5:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abd:	74 0a                	je     800ac9 <strnlen+0x2b>
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	84 c0                	test   %al,%al
  800ac7:	75 e4                	jne    800aad <strnlen+0xf>
		n++;
	return n;
  800ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800ada:	90                   	nop
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8d 50 01             	lea    0x1(%eax),%edx
  800ae1:	89 55 08             	mov    %edx,0x8(%ebp)
  800ae4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae7:	8d 4a 01             	lea    0x1(%edx),%ecx
  800aea:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800aed:	0f b6 12             	movzbl (%edx),%edx
  800af0:	88 10                	mov    %dl,(%eax)
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	84 c0                	test   %al,%al
  800af7:	75 e2                	jne    800adb <strcpy+0xd>
		/* do nothing */;
	return ret;
  800af9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    

00800afe <strcat>:

char *
strcat(char *dst, const char *src)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	89 04 24             	mov    %eax,(%esp)
  800b0a:	e8 69 ff ff ff       	call   800a78 <strlen>
  800b0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800b12:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	01 c2                	add    %eax,%edx
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b21:	89 14 24             	mov    %edx,(%esp)
  800b24:	e8 a5 ff ff ff       	call   800ace <strcpy>
	return dst;
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800b3a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800b41:	eb 23                	jmp    800b66 <strncpy+0x38>
		*dst++ = *src;
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	8d 50 01             	lea    0x1(%eax),%edx
  800b49:	89 55 08             	mov    %edx,0x8(%ebp)
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4f:	0f b6 12             	movzbl (%edx),%edx
  800b52:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	0f b6 00             	movzbl (%eax),%eax
  800b5a:	84 c0                	test   %al,%al
  800b5c:	74 04                	je     800b62 <strncpy+0x34>
			src++;
  800b5e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b62:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800b66:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b69:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b6c:	72 d5                	jb     800b43 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800b6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800b7f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b83:	74 33                	je     800bb8 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800b85:	eb 17                	jmp    800b9e <strlcpy+0x2b>
			*dst++ = *src++;
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8d 50 01             	lea    0x1(%eax),%edx
  800b8d:	89 55 08             	mov    %edx,0x8(%ebp)
  800b90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b93:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b96:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800b99:	0f b6 12             	movzbl (%edx),%edx
  800b9c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b9e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ba2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ba6:	74 0a                	je     800bb2 <strlcpy+0x3f>
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	0f b6 00             	movzbl (%eax),%eax
  800bae:	84 c0                	test   %al,%al
  800bb0:	75 d5                	jne    800b87 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbe:	29 c2                	sub    %eax,%edx
  800bc0:	89 d0                	mov    %edx,%eax
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800bc7:	eb 08                	jmp    800bd1 <strcmp+0xd>
		p++, q++;
  800bc9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bcd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	0f b6 00             	movzbl (%eax),%eax
  800bd7:	84 c0                	test   %al,%al
  800bd9:	74 10                	je     800beb <strcmp+0x27>
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	0f b6 10             	movzbl (%eax),%edx
  800be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be4:	0f b6 00             	movzbl (%eax),%eax
  800be7:	38 c2                	cmp    %al,%dl
  800be9:	74 de                	je     800bc9 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	0f b6 00             	movzbl (%eax),%eax
  800bf1:	0f b6 d0             	movzbl %al,%edx
  800bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf7:	0f b6 00             	movzbl (%eax),%eax
  800bfa:	0f b6 c0             	movzbl %al,%eax
  800bfd:	29 c2                	sub    %eax,%edx
  800bff:	89 d0                	mov    %edx,%eax
}
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800c06:	eb 0c                	jmp    800c14 <strncmp+0x11>
		n--, p++, q++;
  800c08:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800c0c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c10:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c18:	74 1a                	je     800c34 <strncmp+0x31>
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	0f b6 00             	movzbl (%eax),%eax
  800c20:	84 c0                	test   %al,%al
  800c22:	74 10                	je     800c34 <strncmp+0x31>
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	0f b6 10             	movzbl (%eax),%edx
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	0f b6 00             	movzbl (%eax),%eax
  800c30:	38 c2                	cmp    %al,%dl
  800c32:	74 d4                	je     800c08 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800c34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c38:	75 07                	jne    800c41 <strncmp+0x3e>
		return 0;
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	eb 16                	jmp    800c57 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	0f b6 00             	movzbl (%eax),%eax
  800c47:	0f b6 d0             	movzbl %al,%edx
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	0f b6 00             	movzbl (%eax),%eax
  800c50:	0f b6 c0             	movzbl %al,%eax
  800c53:	29 c2                	sub    %eax,%edx
  800c55:	89 d0                	mov    %edx,%eax
}
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	83 ec 04             	sub    $0x4,%esp
  800c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c62:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800c65:	eb 14                	jmp    800c7b <strchr+0x22>
		if (*s == c)
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	0f b6 00             	movzbl (%eax),%eax
  800c6d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800c70:	75 05                	jne    800c77 <strchr+0x1e>
			return (char *) s;
  800c72:	8b 45 08             	mov    0x8(%ebp),%eax
  800c75:	eb 13                	jmp    800c8a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	0f b6 00             	movzbl (%eax),%eax
  800c81:	84 c0                	test   %al,%al
  800c83:	75 e2                	jne    800c67 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800c85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 04             	sub    $0x4,%esp
  800c92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c95:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800c98:	eb 11                	jmp    800cab <strfind+0x1f>
		if (*s == c)
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	0f b6 00             	movzbl (%eax),%eax
  800ca0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ca3:	75 02                	jne    800ca7 <strfind+0x1b>
			break;
  800ca5:	eb 0e                	jmp    800cb5 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ca7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	0f b6 00             	movzbl (%eax),%eax
  800cb1:	84 c0                	test   %al,%al
  800cb3:	75 e5                	jne    800c9a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
	char *p;

	if (n == 0)
  800cbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc2:	75 05                	jne    800cc9 <memset+0xf>
		return v;
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	eb 5c                	jmp    800d25 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	83 e0 03             	and    $0x3,%eax
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	75 41                	jne    800d14 <memset+0x5a>
  800cd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd6:	83 e0 03             	and    $0x3,%eax
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	75 37                	jne    800d14 <memset+0x5a>
		c &= 0xFF;
  800cdd:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce7:	c1 e0 18             	shl    $0x18,%eax
  800cea:	89 c2                	mov    %eax,%edx
  800cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cef:	c1 e0 10             	shl    $0x10,%eax
  800cf2:	09 c2                	or     %eax,%edx
  800cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf7:	c1 e0 08             	shl    $0x8,%eax
  800cfa:	09 d0                	or     %edx,%eax
  800cfc:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800cff:	8b 45 10             	mov    0x10(%ebp),%eax
  800d02:	c1 e8 02             	shr    $0x2,%eax
  800d05:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0d:	89 d7                	mov    %edx,%edi
  800d0f:	fc                   	cld    
  800d10:	f3 ab                	rep stos %eax,%es:(%edi)
  800d12:	eb 0e                	jmp    800d22 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d1d:	89 d7                	mov    %edx,%edi
  800d1f:	fc                   	cld    
  800d20:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800d31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d40:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d43:	73 6d                	jae    800db2 <memmove+0x8a>
  800d45:	8b 45 10             	mov    0x10(%ebp),%eax
  800d48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d4b:	01 d0                	add    %edx,%eax
  800d4d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d50:	76 60                	jbe    800db2 <memmove+0x8a>
		s += n;
  800d52:	8b 45 10             	mov    0x10(%ebp),%eax
  800d55:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800d58:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d61:	83 e0 03             	and    $0x3,%eax
  800d64:	85 c0                	test   %eax,%eax
  800d66:	75 2f                	jne    800d97 <memmove+0x6f>
  800d68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d6b:	83 e0 03             	and    $0x3,%eax
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	75 25                	jne    800d97 <memmove+0x6f>
  800d72:	8b 45 10             	mov    0x10(%ebp),%eax
  800d75:	83 e0 03             	and    $0x3,%eax
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	75 1b                	jne    800d97 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d7f:	83 e8 04             	sub    $0x4,%eax
  800d82:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d85:	83 ea 04             	sub    $0x4,%edx
  800d88:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d8b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d8e:	89 c7                	mov    %eax,%edi
  800d90:	89 d6                	mov    %edx,%esi
  800d92:	fd                   	std    
  800d93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d95:	eb 18                	jmp    800daf <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d9a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800da0:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800da3:	8b 45 10             	mov    0x10(%ebp),%eax
  800da6:	89 d7                	mov    %edx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	89 c1                	mov    %eax,%ecx
  800dac:	fd                   	std    
  800dad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800daf:	fc                   	cld    
  800db0:	eb 45                	jmp    800df7 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db5:	83 e0 03             	and    $0x3,%eax
  800db8:	85 c0                	test   %eax,%eax
  800dba:	75 2b                	jne    800de7 <memmove+0xbf>
  800dbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dbf:	83 e0 03             	and    $0x3,%eax
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	75 21                	jne    800de7 <memmove+0xbf>
  800dc6:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc9:	83 e0 03             	and    $0x3,%eax
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	75 17                	jne    800de7 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd3:	c1 e8 02             	shr    $0x2,%eax
  800dd6:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800dd8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ddb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dde:	89 c7                	mov    %eax,%edi
  800de0:	89 d6                	mov    %edx,%esi
  800de2:	fc                   	cld    
  800de3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800de5:	eb 10                	jmp    800df7 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800de7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800dea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ded:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800df0:	89 c7                	mov    %eax,%edi
  800df2:	89 d6                	mov    %edx,%esi
  800df4:	fc                   	cld    
  800df5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e08:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	89 04 24             	mov    %eax,(%esp)
  800e1c:	e8 07 ff ff ff       	call   800d28 <memmove>
}
  800e21:	c9                   	leave  
  800e22:	c3                   	ret    

00800e23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e32:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800e35:	eb 30                	jmp    800e67 <memcmp+0x44>
		if (*s1 != *s2)
  800e37:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e3a:	0f b6 10             	movzbl (%eax),%edx
  800e3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e40:	0f b6 00             	movzbl (%eax),%eax
  800e43:	38 c2                	cmp    %al,%dl
  800e45:	74 18                	je     800e5f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800e47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e4a:	0f b6 00             	movzbl (%eax),%eax
  800e4d:	0f b6 d0             	movzbl %al,%edx
  800e50:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e53:	0f b6 00             	movzbl (%eax),%eax
  800e56:	0f b6 c0             	movzbl %al,%eax
  800e59:	29 c2                	sub    %eax,%edx
  800e5b:	89 d0                	mov    %edx,%eax
  800e5d:	eb 1a                	jmp    800e79 <memcmp+0x56>
		s1++, s2++;
  800e5f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800e63:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e67:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e6d:	89 55 10             	mov    %edx,0x10(%ebp)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	75 c3                	jne    800e37 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    

00800e7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800e81:	8b 45 10             	mov    0x10(%ebp),%eax
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	01 d0                	add    %edx,%eax
  800e89:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800e8c:	eb 13                	jmp    800ea1 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	0f b6 10             	movzbl (%eax),%edx
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	38 c2                	cmp    %al,%dl
  800e99:	75 02                	jne    800e9d <memfind+0x22>
			break;
  800e9b:	eb 0c                	jmp    800ea9 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ea7:	72 e5                	jb     800e8e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800eb4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ebb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec2:	eb 04                	jmp    800ec8 <strtol+0x1a>
		s++;
  800ec4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	0f b6 00             	movzbl (%eax),%eax
  800ece:	3c 20                	cmp    $0x20,%al
  800ed0:	74 f2                	je     800ec4 <strtol+0x16>
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	0f b6 00             	movzbl (%eax),%eax
  800ed8:	3c 09                	cmp    $0x9,%al
  800eda:	74 e8                	je     800ec4 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	0f b6 00             	movzbl (%eax),%eax
  800ee2:	3c 2b                	cmp    $0x2b,%al
  800ee4:	75 06                	jne    800eec <strtol+0x3e>
		s++;
  800ee6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eea:	eb 15                	jmp    800f01 <strtol+0x53>
	else if (*s == '-')
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	0f b6 00             	movzbl (%eax),%eax
  800ef2:	3c 2d                	cmp    $0x2d,%al
  800ef4:	75 0b                	jne    800f01 <strtol+0x53>
		s++, neg = 1;
  800ef6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800efa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f05:	74 06                	je     800f0d <strtol+0x5f>
  800f07:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800f0b:	75 24                	jne    800f31 <strtol+0x83>
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	0f b6 00             	movzbl (%eax),%eax
  800f13:	3c 30                	cmp    $0x30,%al
  800f15:	75 1a                	jne    800f31 <strtol+0x83>
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	83 c0 01             	add    $0x1,%eax
  800f1d:	0f b6 00             	movzbl (%eax),%eax
  800f20:	3c 78                	cmp    $0x78,%al
  800f22:	75 0d                	jne    800f31 <strtol+0x83>
		s += 2, base = 16;
  800f24:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800f28:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800f2f:	eb 2a                	jmp    800f5b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800f31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f35:	75 17                	jne    800f4e <strtol+0xa0>
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	0f b6 00             	movzbl (%eax),%eax
  800f3d:	3c 30                	cmp    $0x30,%al
  800f3f:	75 0d                	jne    800f4e <strtol+0xa0>
		s++, base = 8;
  800f41:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f45:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800f4c:	eb 0d                	jmp    800f5b <strtol+0xad>
	else if (base == 0)
  800f4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f52:	75 07                	jne    800f5b <strtol+0xad>
		base = 10;
  800f54:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	0f b6 00             	movzbl (%eax),%eax
  800f61:	3c 2f                	cmp    $0x2f,%al
  800f63:	7e 1b                	jle    800f80 <strtol+0xd2>
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	0f b6 00             	movzbl (%eax),%eax
  800f6b:	3c 39                	cmp    $0x39,%al
  800f6d:	7f 11                	jg     800f80 <strtol+0xd2>
			dig = *s - '0';
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	0f b6 00             	movzbl (%eax),%eax
  800f75:	0f be c0             	movsbl %al,%eax
  800f78:	83 e8 30             	sub    $0x30,%eax
  800f7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800f7e:	eb 48                	jmp    800fc8 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	0f b6 00             	movzbl (%eax),%eax
  800f86:	3c 60                	cmp    $0x60,%al
  800f88:	7e 1b                	jle    800fa5 <strtol+0xf7>
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	0f b6 00             	movzbl (%eax),%eax
  800f90:	3c 7a                	cmp    $0x7a,%al
  800f92:	7f 11                	jg     800fa5 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	0f b6 00             	movzbl (%eax),%eax
  800f9a:	0f be c0             	movsbl %al,%eax
  800f9d:	83 e8 57             	sub    $0x57,%eax
  800fa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800fa3:	eb 23                	jmp    800fc8 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa8:	0f b6 00             	movzbl (%eax),%eax
  800fab:	3c 40                	cmp    $0x40,%al
  800fad:	7e 3d                	jle    800fec <strtol+0x13e>
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	0f b6 00             	movzbl (%eax),%eax
  800fb5:	3c 5a                	cmp    $0x5a,%al
  800fb7:	7f 33                	jg     800fec <strtol+0x13e>
			dig = *s - 'A' + 10;
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbc:	0f b6 00             	movzbl (%eax),%eax
  800fbf:	0f be c0             	movsbl %al,%eax
  800fc2:	83 e8 37             	sub    $0x37,%eax
  800fc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800fce:	7c 02                	jl     800fd2 <strtol+0x124>
			break;
  800fd0:	eb 1a                	jmp    800fec <strtol+0x13e>
		s++, val = (val * base) + dig;
  800fd2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fd6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fdd:	89 c2                	mov    %eax,%edx
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	01 d0                	add    %edx,%eax
  800fe4:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800fe7:	e9 6f ff ff ff       	jmp    800f5b <strtol+0xad>

	if (endptr)
  800fec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ff0:	74 08                	je     800ffa <strtol+0x14c>
		*endptr = (char *) s;
  800ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ffa:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ffe:	74 07                	je     801007 <strtol+0x159>
  801000:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801003:	f7 d8                	neg    %eax
  801005:	eb 03                	jmp    80100a <strtol+0x15c>
  801007:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	8b 55 10             	mov    0x10(%ebp),%edx
  80101b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80101e:	8b 5d 18             	mov    0x18(%ebp),%ebx
  801021:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  801024:	8b 75 20             	mov    0x20(%ebp),%esi
  801027:	cd 30                	int    $0x30
  801029:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801030:	74 30                	je     801062 <syscall+0x56>
  801032:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801036:	7e 2a                	jle    801062 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  801038:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80103b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801046:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  80104d:	00 
  80104e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801055:	00 
  801056:	c7 04 24 21 1a 80 00 	movl   $0x801a21,(%esp)
  80105d:	e8 84 f2 ff ff       	call   8002e6 <_panic>

	return ret;
  801062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801065:	83 c4 3c             	add    $0x3c,%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80107d:	00 
  80107e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801085:	00 
  801086:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80108d:	00 
  80108e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801091:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801095:	89 44 24 08          	mov    %eax,0x8(%esp)
  801099:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010a8:	e8 5f ff ff ff       	call   80100c <syscall>
}
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <sys_cgetc>:

int
sys_cgetc(void)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010b5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010bc:	00 
  8010bd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010c4:	00 
  8010c5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010cc:	00 
  8010cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010ec:	e8 1b ff ff ff       	call   80100c <syscall>
}
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    

008010f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801103:	00 
  801104:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80110b:	00 
  80110c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801113:	00 
  801114:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80111b:	00 
  80111c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801120:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801127:	00 
  801128:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80112f:	e8 d8 fe ff ff       	call   80100c <syscall>
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80113c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801143:	00 
  801144:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114b:	00 
  80114c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801153:	00 
  801154:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80115b:	00 
  80115c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801163:	00 
  801164:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80116b:	00 
  80116c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801173:	e8 94 fe ff ff       	call   80100c <syscall>
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <sys_yield>:

void
sys_yield(void)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801180:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801187:	00 
  801188:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80118f:	00 
  801190:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801197:	00 
  801198:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80119f:	00 
  8011a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011af:	00 
  8011b0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8011b7:	e8 50 fe ff ff       	call   80100c <syscall>
}
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8011c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011d4:	00 
  8011d5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011dc:	00 
  8011dd:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8011e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011f0:	00 
  8011f1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8011f8:	e8 0f fe ff ff       	call   80100c <syscall>
}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801207:	8b 75 18             	mov    0x18(%ebp),%esi
  80120a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80120d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801210:	8b 55 0c             	mov    0xc(%ebp),%edx
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	89 74 24 18          	mov    %esi,0x18(%esp)
  80121a:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80121e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801222:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801226:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801239:	e8 ce fd ff ff       	call   80100c <syscall>
}
  80123e:	83 c4 20             	add    $0x20,%esp
  801241:	5b                   	pop    %ebx
  801242:	5e                   	pop    %esi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	8b 45 08             	mov    0x8(%ebp),%eax
  801251:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801258:	00 
  801259:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801260:	00 
  801261:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801268:	00 
  801269:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80126d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801271:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801278:	00 
  801279:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801280:	e8 87 fd ff ff       	call   80100c <syscall>
}
  801285:	c9                   	leave  
  801286:	c3                   	ret    

00801287 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80128d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80129a:	00 
  80129b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012a2:	00 
  8012a3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012aa:	00 
  8012ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012ba:	00 
  8012bb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8012c2:	e8 45 fd ff ff       	call   80100c <syscall>
}
  8012c7:	c9                   	leave  
  8012c8:	c3                   	ret    

008012c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8012cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012dc:	00 
  8012dd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012e4:	00 
  8012e5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012ec:	00 
  8012ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8012fc:	00 
  8012fd:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801304:	e8 03 fd ff ff       	call   80100c <syscall>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801311:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801314:	8b 55 10             	mov    0x10(%ebp),%edx
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
  80131a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801321:	00 
  801322:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801326:	89 54 24 10          	mov    %edx,0x10(%esp)
  80132a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801331:	89 44 24 08          	mov    %eax,0x8(%esp)
  801335:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80133c:	00 
  80133d:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801344:	e8 c3 fc ff ff       	call   80100c <syscall>
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80135b:	00 
  80135c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801363:	00 
  801364:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80136b:	00 
  80136c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801373:	00 
  801374:	89 44 24 08          	mov    %eax,0x8(%esp)
  801378:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80137f:	00 
  801380:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801387:	e8 80 fc ff ff       	call   80100c <syscall>
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <sys_exec>:

void sys_exec(char* buf){
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801394:	8b 45 08             	mov    0x8(%ebp),%eax
  801397:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80139e:	00 
  80139f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8013a6:	00 
  8013a7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8013ae:	00 
  8013af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013b6:	00 
  8013b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013c2:	00 
  8013c3:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8013ca:	e8 3d fc ff ff       	call   80100c <syscall>
}
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <sys_wait>:

void sys_wait(){
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  8013d7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8013de:	00 
  8013df:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8013e6:	00 
  8013e7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8013ee:	00 
  8013ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013f6:	00 
  8013f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80140e:	e8 f9 fb ff ff       	call   80100c <syscall>
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    

00801415 <sys_guest>:

void sys_guest(){
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  80141b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801422:	00 
  801423:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80142a:	00 
  80142b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801432:	00 
  801433:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80143a:	00 
  80143b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801442:	00 
  801443:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80144a:	00 
  80144b:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  801452:	e8 b5 fb ff ff       	call   80100c <syscall>
  801457:	c9                   	leave  
  801458:	c3                   	ret    
  801459:	66 90                	xchg   %ax,%ax
  80145b:	66 90                	xchg   %ax,%ax
  80145d:	66 90                	xchg   %ax,%ax
  80145f:	90                   	nop

00801460 <__udivdi3>:
  801460:	55                   	push   %ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	83 ec 0c             	sub    $0xc,%esp
  801466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80146a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80146e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801472:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801476:	85 c0                	test   %eax,%eax
  801478:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80147c:	89 ea                	mov    %ebp,%edx
  80147e:	89 0c 24             	mov    %ecx,(%esp)
  801481:	75 2d                	jne    8014b0 <__udivdi3+0x50>
  801483:	39 e9                	cmp    %ebp,%ecx
  801485:	77 61                	ja     8014e8 <__udivdi3+0x88>
  801487:	85 c9                	test   %ecx,%ecx
  801489:	89 ce                	mov    %ecx,%esi
  80148b:	75 0b                	jne    801498 <__udivdi3+0x38>
  80148d:	b8 01 00 00 00       	mov    $0x1,%eax
  801492:	31 d2                	xor    %edx,%edx
  801494:	f7 f1                	div    %ecx
  801496:	89 c6                	mov    %eax,%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	89 e8                	mov    %ebp,%eax
  80149c:	f7 f6                	div    %esi
  80149e:	89 c5                	mov    %eax,%ebp
  8014a0:	89 f8                	mov    %edi,%eax
  8014a2:	f7 f6                	div    %esi
  8014a4:	89 ea                	mov    %ebp,%edx
  8014a6:	83 c4 0c             	add    $0xc,%esp
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    
  8014ad:	8d 76 00             	lea    0x0(%esi),%esi
  8014b0:	39 e8                	cmp    %ebp,%eax
  8014b2:	77 24                	ja     8014d8 <__udivdi3+0x78>
  8014b4:	0f bd e8             	bsr    %eax,%ebp
  8014b7:	83 f5 1f             	xor    $0x1f,%ebp
  8014ba:	75 3c                	jne    8014f8 <__udivdi3+0x98>
  8014bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014c0:	39 34 24             	cmp    %esi,(%esp)
  8014c3:	0f 86 9f 00 00 00    	jbe    801568 <__udivdi3+0x108>
  8014c9:	39 d0                	cmp    %edx,%eax
  8014cb:	0f 82 97 00 00 00    	jb     801568 <__udivdi3+0x108>
  8014d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	31 d2                	xor    %edx,%edx
  8014da:	31 c0                	xor    %eax,%eax
  8014dc:	83 c4 0c             	add    $0xc,%esp
  8014df:	5e                   	pop    %esi
  8014e0:	5f                   	pop    %edi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    
  8014e3:	90                   	nop
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	89 f8                	mov    %edi,%eax
  8014ea:	f7 f1                	div    %ecx
  8014ec:	31 d2                	xor    %edx,%edx
  8014ee:	83 c4 0c             	add    $0xc,%esp
  8014f1:	5e                   	pop    %esi
  8014f2:	5f                   	pop    %edi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    
  8014f5:	8d 76 00             	lea    0x0(%esi),%esi
  8014f8:	89 e9                	mov    %ebp,%ecx
  8014fa:	8b 3c 24             	mov    (%esp),%edi
  8014fd:	d3 e0                	shl    %cl,%eax
  8014ff:	89 c6                	mov    %eax,%esi
  801501:	b8 20 00 00 00       	mov    $0x20,%eax
  801506:	29 e8                	sub    %ebp,%eax
  801508:	89 c1                	mov    %eax,%ecx
  80150a:	d3 ef                	shr    %cl,%edi
  80150c:	89 e9                	mov    %ebp,%ecx
  80150e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801512:	8b 3c 24             	mov    (%esp),%edi
  801515:	09 74 24 08          	or     %esi,0x8(%esp)
  801519:	89 d6                	mov    %edx,%esi
  80151b:	d3 e7                	shl    %cl,%edi
  80151d:	89 c1                	mov    %eax,%ecx
  80151f:	89 3c 24             	mov    %edi,(%esp)
  801522:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801526:	d3 ee                	shr    %cl,%esi
  801528:	89 e9                	mov    %ebp,%ecx
  80152a:	d3 e2                	shl    %cl,%edx
  80152c:	89 c1                	mov    %eax,%ecx
  80152e:	d3 ef                	shr    %cl,%edi
  801530:	09 d7                	or     %edx,%edi
  801532:	89 f2                	mov    %esi,%edx
  801534:	89 f8                	mov    %edi,%eax
  801536:	f7 74 24 08          	divl   0x8(%esp)
  80153a:	89 d6                	mov    %edx,%esi
  80153c:	89 c7                	mov    %eax,%edi
  80153e:	f7 24 24             	mull   (%esp)
  801541:	39 d6                	cmp    %edx,%esi
  801543:	89 14 24             	mov    %edx,(%esp)
  801546:	72 30                	jb     801578 <__udivdi3+0x118>
  801548:	8b 54 24 04          	mov    0x4(%esp),%edx
  80154c:	89 e9                	mov    %ebp,%ecx
  80154e:	d3 e2                	shl    %cl,%edx
  801550:	39 c2                	cmp    %eax,%edx
  801552:	73 05                	jae    801559 <__udivdi3+0xf9>
  801554:	3b 34 24             	cmp    (%esp),%esi
  801557:	74 1f                	je     801578 <__udivdi3+0x118>
  801559:	89 f8                	mov    %edi,%eax
  80155b:	31 d2                	xor    %edx,%edx
  80155d:	e9 7a ff ff ff       	jmp    8014dc <__udivdi3+0x7c>
  801562:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801568:	31 d2                	xor    %edx,%edx
  80156a:	b8 01 00 00 00       	mov    $0x1,%eax
  80156f:	e9 68 ff ff ff       	jmp    8014dc <__udivdi3+0x7c>
  801574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801578:	8d 47 ff             	lea    -0x1(%edi),%eax
  80157b:	31 d2                	xor    %edx,%edx
  80157d:	83 c4 0c             	add    $0xc,%esp
  801580:	5e                   	pop    %esi
  801581:	5f                   	pop    %edi
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    
  801584:	66 90                	xchg   %ax,%ax
  801586:	66 90                	xchg   %ax,%ax
  801588:	66 90                	xchg   %ax,%ax
  80158a:	66 90                	xchg   %ax,%ax
  80158c:	66 90                	xchg   %ax,%ax
  80158e:	66 90                	xchg   %ax,%ax

00801590 <__umoddi3>:
  801590:	55                   	push   %ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	83 ec 14             	sub    $0x14,%esp
  801596:	8b 44 24 28          	mov    0x28(%esp),%eax
  80159a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80159e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8015a2:	89 c7                	mov    %eax,%edi
  8015a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8015ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8015b0:	89 34 24             	mov    %esi,(%esp)
  8015b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015bf:	75 17                	jne    8015d8 <__umoddi3+0x48>
  8015c1:	39 fe                	cmp    %edi,%esi
  8015c3:	76 4b                	jbe    801610 <__umoddi3+0x80>
  8015c5:	89 c8                	mov    %ecx,%eax
  8015c7:	89 fa                	mov    %edi,%edx
  8015c9:	f7 f6                	div    %esi
  8015cb:	89 d0                	mov    %edx,%eax
  8015cd:	31 d2                	xor    %edx,%edx
  8015cf:	83 c4 14             	add    $0x14,%esp
  8015d2:	5e                   	pop    %esi
  8015d3:	5f                   	pop    %edi
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    
  8015d6:	66 90                	xchg   %ax,%ax
  8015d8:	39 f8                	cmp    %edi,%eax
  8015da:	77 54                	ja     801630 <__umoddi3+0xa0>
  8015dc:	0f bd e8             	bsr    %eax,%ebp
  8015df:	83 f5 1f             	xor    $0x1f,%ebp
  8015e2:	75 5c                	jne    801640 <__umoddi3+0xb0>
  8015e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8015e8:	39 3c 24             	cmp    %edi,(%esp)
  8015eb:	0f 87 e7 00 00 00    	ja     8016d8 <__umoddi3+0x148>
  8015f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015f5:	29 f1                	sub    %esi,%ecx
  8015f7:	19 c7                	sbb    %eax,%edi
  8015f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801601:	8b 44 24 08          	mov    0x8(%esp),%eax
  801605:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801609:	83 c4 14             	add    $0x14,%esp
  80160c:	5e                   	pop    %esi
  80160d:	5f                   	pop    %edi
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    
  801610:	85 f6                	test   %esi,%esi
  801612:	89 f5                	mov    %esi,%ebp
  801614:	75 0b                	jne    801621 <__umoddi3+0x91>
  801616:	b8 01 00 00 00       	mov    $0x1,%eax
  80161b:	31 d2                	xor    %edx,%edx
  80161d:	f7 f6                	div    %esi
  80161f:	89 c5                	mov    %eax,%ebp
  801621:	8b 44 24 04          	mov    0x4(%esp),%eax
  801625:	31 d2                	xor    %edx,%edx
  801627:	f7 f5                	div    %ebp
  801629:	89 c8                	mov    %ecx,%eax
  80162b:	f7 f5                	div    %ebp
  80162d:	eb 9c                	jmp    8015cb <__umoddi3+0x3b>
  80162f:	90                   	nop
  801630:	89 c8                	mov    %ecx,%eax
  801632:	89 fa                	mov    %edi,%edx
  801634:	83 c4 14             	add    $0x14,%esp
  801637:	5e                   	pop    %esi
  801638:	5f                   	pop    %edi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    
  80163b:	90                   	nop
  80163c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801640:	8b 04 24             	mov    (%esp),%eax
  801643:	be 20 00 00 00       	mov    $0x20,%esi
  801648:	89 e9                	mov    %ebp,%ecx
  80164a:	29 ee                	sub    %ebp,%esi
  80164c:	d3 e2                	shl    %cl,%edx
  80164e:	89 f1                	mov    %esi,%ecx
  801650:	d3 e8                	shr    %cl,%eax
  801652:	89 e9                	mov    %ebp,%ecx
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	8b 04 24             	mov    (%esp),%eax
  80165b:	09 54 24 04          	or     %edx,0x4(%esp)
  80165f:	89 fa                	mov    %edi,%edx
  801661:	d3 e0                	shl    %cl,%eax
  801663:	89 f1                	mov    %esi,%ecx
  801665:	89 44 24 08          	mov    %eax,0x8(%esp)
  801669:	8b 44 24 10          	mov    0x10(%esp),%eax
  80166d:	d3 ea                	shr    %cl,%edx
  80166f:	89 e9                	mov    %ebp,%ecx
  801671:	d3 e7                	shl    %cl,%edi
  801673:	89 f1                	mov    %esi,%ecx
  801675:	d3 e8                	shr    %cl,%eax
  801677:	89 e9                	mov    %ebp,%ecx
  801679:	09 f8                	or     %edi,%eax
  80167b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80167f:	f7 74 24 04          	divl   0x4(%esp)
  801683:	d3 e7                	shl    %cl,%edi
  801685:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801689:	89 d7                	mov    %edx,%edi
  80168b:	f7 64 24 08          	mull   0x8(%esp)
  80168f:	39 d7                	cmp    %edx,%edi
  801691:	89 c1                	mov    %eax,%ecx
  801693:	89 14 24             	mov    %edx,(%esp)
  801696:	72 2c                	jb     8016c4 <__umoddi3+0x134>
  801698:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80169c:	72 22                	jb     8016c0 <__umoddi3+0x130>
  80169e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8016a2:	29 c8                	sub    %ecx,%eax
  8016a4:	19 d7                	sbb    %edx,%edi
  8016a6:	89 e9                	mov    %ebp,%ecx
  8016a8:	89 fa                	mov    %edi,%edx
  8016aa:	d3 e8                	shr    %cl,%eax
  8016ac:	89 f1                	mov    %esi,%ecx
  8016ae:	d3 e2                	shl    %cl,%edx
  8016b0:	89 e9                	mov    %ebp,%ecx
  8016b2:	d3 ef                	shr    %cl,%edi
  8016b4:	09 d0                	or     %edx,%eax
  8016b6:	89 fa                	mov    %edi,%edx
  8016b8:	83 c4 14             	add    $0x14,%esp
  8016bb:	5e                   	pop    %esi
  8016bc:	5f                   	pop    %edi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    
  8016bf:	90                   	nop
  8016c0:	39 d7                	cmp    %edx,%edi
  8016c2:	75 da                	jne    80169e <__umoddi3+0x10e>
  8016c4:	8b 14 24             	mov    (%esp),%edx
  8016c7:	89 c1                	mov    %eax,%ecx
  8016c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8016cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8016d1:	eb cb                	jmp    80169e <__umoddi3+0x10e>
  8016d3:	90                   	nop
  8016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8016dc:	0f 82 0f ff ff ff    	jb     8015f1 <__umoddi3+0x61>
  8016e2:	e9 1a ff ff ff       	jmp    801601 <__umoddi3+0x71>
