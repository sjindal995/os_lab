
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 40 01 00 00       	call   800171 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800039:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800048:	00 
  800049:	8d 45 e8             	lea    -0x18(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 00 17 00 00       	call   801754 <ipc_recv>
  800054:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800057:	a1 04 30 80 00       	mov    0x803004,%eax
  80005c:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800062:	89 54 24 08          	mov    %edx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 20 1c 80 00 	movl   $0x801c20,(%esp)
  800071:	e8 79 02 00 00       	call   8002ef <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 25 15 00 00       	call   8015a0 <fork>
  80007b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80007e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800082:	79 23                	jns    8000a7 <primeproc+0x74>
		panic("fork: %e", id);
  800084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008b:	c7 44 24 08 2c 1c 80 	movl   $0x801c2c,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 35 1c 80 00 	movl   $0x801c35,(%esp)
  8000a2:	e8 2d 01 00 00       	call   8001d4 <_panic>
	if (id == 0)
  8000a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8000ab:	75 02                	jne    8000af <primeproc+0x7c>
		goto top;
  8000ad:	eb 8a                	jmp    800039 <primeproc+0x6>

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000be:	00 
  8000bf:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8000c2:	89 04 24             	mov    %eax,(%esp)
  8000c5:	e8 8a 16 00 00       	call   801754 <ipc_recv>
  8000ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (i % p)
  8000cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8000d0:	99                   	cltd   
  8000d1:	f7 7d f4             	idivl  -0xc(%ebp)
  8000d4:	89 d0                	mov    %edx,%eax
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	74 24                	je     8000fe <primeproc+0xcb>
			ipc_send(id, i, 0, 0);
  8000da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8000dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ec:	00 
  8000ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000f4:	89 04 24             	mov    %eax,(%esp)
  8000f7:	e8 f6 16 00 00       	call   8017f2 <ipc_send>
	}
  8000fc:	eb b1                	jmp    8000af <primeproc+0x7c>
  8000fe:	eb af                	jmp    8000af <primeproc+0x7c>

00800100 <umain>:
}

void
umain(int argc, char **argv)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	83 ec 28             	sub    $0x28,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  800106:	e8 95 14 00 00       	call   8015a0 <fork>
  80010b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80010e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800112:	79 23                	jns    800137 <umain+0x37>
		panic("fork: %e", id);
  800114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 2c 1c 80 	movl   $0x801c2c,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 35 1c 80 00 	movl   $0x801c35,(%esp)
  800132:	e8 9d 00 00 00       	call   8001d4 <_panic>
	if (id == 0)
  800137:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80013b:	75 05                	jne    800142 <umain+0x42>
		primeproc();
  80013d:	e8 f1 fe ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
  800142:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		ipc_send(id, i, 0, 0);
  800149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80014c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80015b:	00 
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800163:	89 04 24             	mov    %eax,(%esp)
  800166:	e8 87 16 00 00       	call   8017f2 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  80016b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		ipc_send(id, i, 0, 0);
  80016f:	eb d8                	jmp    800149 <umain+0x49>

00800171 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800177:	e8 a8 0e 00 00       	call   801024 <sys_getenvid>
  80017c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800181:	c1 e0 02             	shl    $0x2,%eax
  800184:	89 c2                	mov    %eax,%edx
  800186:	c1 e2 05             	shl    $0x5,%edx
  800189:	29 c2                	sub    %eax,%edx
  80018b:	89 d0                	mov    %edx,%eax
  80018d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800192:	a3 04 30 80 00       	mov    %eax,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800197:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80019b:	7e 0a                	jle    8001a7 <libmain+0x36>
		binaryname = argv[0];
  80019d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a0:	8b 00                	mov    (%eax),%eax
  8001a2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 47 ff ff ff       	call   800100 <umain>

	// exit gracefully
	exit();
  8001b9:	e8 02 00 00 00       	call   8001c0 <exit>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001cd:	e8 0f 0e 00 00       	call   800fe1 <sys_env_destroy>
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8001db:	8d 45 14             	lea    0x14(%ebp),%eax
  8001de:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e1:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001e7:	e8 38 0e 00 00       	call   801024 <sys_getenvid>
  8001ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ef:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800202:	c7 04 24 50 1c 80 00 	movl   $0x801c50,(%esp)
  800209:	e8 e1 00 00 00       	call   8002ef <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	8b 45 10             	mov    0x10(%ebp),%eax
  800218:	89 04 24             	mov    %eax,(%esp)
  80021b:	e8 6b 00 00 00       	call   80028b <vcprintf>
	cprintf("\n");
  800220:	c7 04 24 73 1c 80 00 	movl   $0x801c73,(%esp)
  800227:	e8 c3 00 00 00       	call   8002ef <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80022c:	cc                   	int3   
  80022d:	eb fd                	jmp    80022c <_panic+0x58>

0080022f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800235:	8b 45 0c             	mov    0xc(%ebp),%eax
  800238:	8b 00                	mov    (%eax),%eax
  80023a:	8d 48 01             	lea    0x1(%eax),%ecx
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 0a                	mov    %ecx,(%edx)
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 d1                	mov    %edx,%ecx
  800247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024a:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800251:	8b 00                	mov    (%eax),%eax
  800253:	3d ff 00 00 00       	cmp    $0xff,%eax
  800258:	75 20                	jne    80027a <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025d:	8b 00                	mov    (%eax),%eax
  80025f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800262:	83 c2 08             	add    $0x8,%edx
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	89 14 24             	mov    %edx,(%esp)
  80026c:	e8 ea 0c 00 00       	call   800f5b <sys_cputs>
		b->idx = 0;
  800271:	8b 45 0c             	mov    0xc(%ebp),%eax
  800274:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80027a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027d:	8b 40 04             	mov    0x4(%eax),%eax
  800280:	8d 50 01             	lea    0x1(%eax),%edx
  800283:	8b 45 0c             	mov    0xc(%ebp),%eax
  800286:	89 50 04             	mov    %edx,0x4(%eax)
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800294:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029b:	00 00 00 
	b.cnt = 0;
  80029e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c0:	c7 04 24 2f 02 80 00 	movl   $0x80022f,(%esp)
  8002c7:	e8 bd 01 00 00       	call   800489 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002cc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dc:	83 c0 08             	add    $0x8,%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	e8 74 0c 00 00       	call   800f5b <sys_cputs>

	return b.cnt;
  8002e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f5:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	e8 7e ff ff ff       	call   80028b <vcprintf>
  80030d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800310:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	53                   	push   %ebx
  800319:	83 ec 34             	sub    $0x34,%esp
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800322:	8b 45 14             	mov    0x14(%ebp),%eax
  800325:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800328:	8b 45 18             	mov    0x18(%ebp),%eax
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800333:	77 72                	ja     8003a7 <printnum+0x92>
  800335:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800338:	72 05                	jb     80033f <printnum+0x2a>
  80033a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80033d:	77 68                	ja     8003a7 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80033f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800342:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800345:	8b 45 18             	mov    0x18(%ebp),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800351:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800358:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800362:	e8 19 16 00 00       	call   801980 <__udivdi3>
  800367:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80036a:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80036e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800372:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800375:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800379:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800381:	8b 45 0c             	mov    0xc(%ebp),%eax
  800384:	89 44 24 04          	mov    %eax,0x4(%esp)
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	89 04 24             	mov    %eax,(%esp)
  80038e:	e8 82 ff ff ff       	call   800315 <printnum>
  800393:	eb 1c                	jmp    8003b1 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800395:	8b 45 0c             	mov    0xc(%ebp),%eax
  800398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039c:	8b 45 20             	mov    0x20(%ebp),%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8003ab:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003af:	7f e4                	jg     800395 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b1:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003c3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ce:	e8 dd 16 00 00       	call   801ab0 <__umoddi3>
  8003d3:	05 48 1d 80 00       	add    $0x801d48,%eax
  8003d8:	0f b6 00             	movzbl (%eax),%eax
  8003db:	0f be c0             	movsbl %al,%eax
  8003de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e5:	89 04 24             	mov    %eax,(%esp)
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	ff d0                	call   *%eax
}
  8003ed:	83 c4 34             	add    $0x34,%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003fa:	7e 14                	jle    800410 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	8d 48 08             	lea    0x8(%eax),%ecx
  800404:	8b 55 08             	mov    0x8(%ebp),%edx
  800407:	89 0a                	mov    %ecx,(%edx)
  800409:	8b 50 04             	mov    0x4(%eax),%edx
  80040c:	8b 00                	mov    (%eax),%eax
  80040e:	eb 30                	jmp    800440 <getuint+0x4d>
	else if (lflag)
  800410:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800414:	74 16                	je     80042c <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	8d 48 04             	lea    0x4(%eax),%ecx
  80041e:	8b 55 08             	mov    0x8(%ebp),%edx
  800421:	89 0a                	mov    %ecx,(%edx)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	ba 00 00 00 00       	mov    $0x0,%edx
  80042a:	eb 14                	jmp    800440 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80042c:	8b 45 08             	mov    0x8(%ebp),%eax
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	8d 48 04             	lea    0x4(%eax),%ecx
  800434:	8b 55 08             	mov    0x8(%ebp),%edx
  800437:	89 0a                	mov    %ecx,(%edx)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800445:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800449:	7e 14                	jle    80045f <getint+0x1d>
		return va_arg(*ap, long long);
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	8d 48 08             	lea    0x8(%eax),%ecx
  800453:	8b 55 08             	mov    0x8(%ebp),%edx
  800456:	89 0a                	mov    %ecx,(%edx)
  800458:	8b 50 04             	mov    0x4(%eax),%edx
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	eb 28                	jmp    800487 <getint+0x45>
	else if (lflag)
  80045f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800463:	74 12                	je     800477 <getint+0x35>
		return va_arg(*ap, long);
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
  800468:	8b 00                	mov    (%eax),%eax
  80046a:	8d 48 04             	lea    0x4(%eax),%ecx
  80046d:	8b 55 08             	mov    0x8(%ebp),%edx
  800470:	89 0a                	mov    %ecx,(%edx)
  800472:	8b 00                	mov    (%eax),%eax
  800474:	99                   	cltd   
  800475:	eb 10                	jmp    800487 <getint+0x45>
	else
		return va_arg(*ap, int);
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	8d 48 04             	lea    0x4(%eax),%ecx
  80047f:	8b 55 08             	mov    0x8(%ebp),%edx
  800482:	89 0a                	mov    %ecx,(%edx)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800491:	eb 18                	jmp    8004ab <vprintfmt+0x22>
			if (ch == '\0')
  800493:	85 db                	test   %ebx,%ebx
  800495:	75 05                	jne    80049c <vprintfmt+0x13>
				return;
  800497:	e9 cc 03 00 00       	jmp    800868 <vprintfmt+0x3df>
			putch(ch, putdat);
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a3:	89 1c 24             	mov    %ebx,(%esp)
  8004a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a9:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ae:	8d 50 01             	lea    0x1(%eax),%edx
  8004b1:	89 55 10             	mov    %edx,0x10(%ebp)
  8004b4:	0f b6 00             	movzbl (%eax),%eax
  8004b7:	0f b6 d8             	movzbl %al,%ebx
  8004ba:	83 fb 25             	cmp    $0x25,%ebx
  8004bd:	75 d4                	jne    800493 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004bf:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004c3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004ca:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004d1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004d8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	8d 50 01             	lea    0x1(%eax),%edx
  8004e5:	89 55 10             	mov    %edx,0x10(%ebp)
  8004e8:	0f b6 00             	movzbl (%eax),%eax
  8004eb:	0f b6 d8             	movzbl %al,%ebx
  8004ee:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004f1:	83 f8 55             	cmp    $0x55,%eax
  8004f4:	0f 87 3d 03 00 00    	ja     800837 <vprintfmt+0x3ae>
  8004fa:	8b 04 85 6c 1d 80 00 	mov    0x801d6c(,%eax,4),%eax
  800501:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800503:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800507:	eb d6                	jmp    8004df <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800509:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80050d:	eb d0                	jmp    8004df <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800516:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800519:	89 d0                	mov    %edx,%eax
  80051b:	c1 e0 02             	shl    $0x2,%eax
  80051e:	01 d0                	add    %edx,%eax
  800520:	01 c0                	add    %eax,%eax
  800522:	01 d8                	add    %ebx,%eax
  800524:	83 e8 30             	sub    $0x30,%eax
  800527:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80052a:	8b 45 10             	mov    0x10(%ebp),%eax
  80052d:	0f b6 00             	movzbl (%eax),%eax
  800530:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800533:	83 fb 2f             	cmp    $0x2f,%ebx
  800536:	7e 0b                	jle    800543 <vprintfmt+0xba>
  800538:	83 fb 39             	cmp    $0x39,%ebx
  80053b:	7f 06                	jg     800543 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80053d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800541:	eb d3                	jmp    800516 <vprintfmt+0x8d>
			goto process_precision;
  800543:	eb 33                	jmp    800578 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800553:	eb 23                	jmp    800578 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800555:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800559:	79 0c                	jns    800567 <vprintfmt+0xde>
				width = 0;
  80055b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800562:	e9 78 ff ff ff       	jmp    8004df <vprintfmt+0x56>
  800567:	e9 73 ff ff ff       	jmp    8004df <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80056c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800573:	e9 67 ff ff ff       	jmp    8004df <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800578:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057c:	79 12                	jns    800590 <vprintfmt+0x107>
				width = precision, precision = -1;
  80057e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800581:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800584:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80058b:	e9 4f ff ff ff       	jmp    8004df <vprintfmt+0x56>
  800590:	e9 4a ff ff ff       	jmp    8004df <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800595:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800599:	e9 41 ff ff ff       	jmp    8004df <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 50 04             	lea    0x4(%eax),%edx
  8005a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b6:	ff d0                	call   *%eax
			break;
  8005b8:	e9 a5 02 00 00       	jmp    800862 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005c8:	85 db                	test   %ebx,%ebx
  8005ca:	79 02                	jns    8005ce <vprintfmt+0x145>
				err = -err;
  8005cc:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ce:	83 fb 09             	cmp    $0x9,%ebx
  8005d1:	7f 0b                	jg     8005de <vprintfmt+0x155>
  8005d3:	8b 34 9d 20 1d 80 00 	mov    0x801d20(,%ebx,4),%esi
  8005da:	85 f6                	test   %esi,%esi
  8005dc:	75 23                	jne    800601 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005e2:	c7 44 24 08 59 1d 80 	movl   $0x801d59,0x8(%esp)
  8005e9:	00 
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	e8 73 02 00 00       	call   80086f <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005fc:	e9 61 02 00 00       	jmp    800862 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800601:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800605:	c7 44 24 08 62 1d 80 	movl   $0x801d62,0x8(%esp)
  80060c:	00 
  80060d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	8b 45 08             	mov    0x8(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 50 02 00 00       	call   80086f <printfmt>
			break;
  80061f:	e9 3e 02 00 00       	jmp    800862 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 30                	mov    (%eax),%esi
  80062f:	85 f6                	test   %esi,%esi
  800631:	75 05                	jne    800638 <vprintfmt+0x1af>
				p = "(null)";
  800633:	be 65 1d 80 00       	mov    $0x801d65,%esi
			if (width > 0 && padc != '-')
  800638:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063c:	7e 37                	jle    800675 <vprintfmt+0x1ec>
  80063e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800642:	74 31                	je     800675 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800644:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064b:	89 34 24             	mov    %esi,(%esp)
  80064e:	e8 39 03 00 00       	call   80098c <strnlen>
  800653:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800656:	eb 17                	jmp    80066f <vprintfmt+0x1e6>
					putch(padc, putdat);
  800658:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80065c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80065f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	8b 45 08             	mov    0x8(%ebp),%eax
  800669:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80066f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800673:	7f e3                	jg     800658 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800675:	eb 38                	jmp    8006af <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800677:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067b:	74 1f                	je     80069c <vprintfmt+0x213>
  80067d:	83 fb 1f             	cmp    $0x1f,%ebx
  800680:	7e 05                	jle    800687 <vprintfmt+0x1fe>
  800682:	83 fb 7e             	cmp    $0x7e,%ebx
  800685:	7e 15                	jle    80069c <vprintfmt+0x213>
					putch('?', putdat);
  800687:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	ff d0                	call   *%eax
  80069a:	eb 0f                	jmp    8006ab <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80069c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a3:	89 1c 24             	mov    %ebx,(%esp)
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ab:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006af:	89 f0                	mov    %esi,%eax
  8006b1:	8d 70 01             	lea    0x1(%eax),%esi
  8006b4:	0f b6 00             	movzbl (%eax),%eax
  8006b7:	0f be d8             	movsbl %al,%ebx
  8006ba:	85 db                	test   %ebx,%ebx
  8006bc:	74 10                	je     8006ce <vprintfmt+0x245>
  8006be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c2:	78 b3                	js     800677 <vprintfmt+0x1ee>
  8006c4:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8006c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cc:	79 a9                	jns    800677 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ce:	eb 17                	jmp    8006e7 <vprintfmt+0x25e>
				putch(' ', putdat);
  8006d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006eb:	7f e3                	jg     8006d0 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8006ed:	e9 70 01 00 00       	jmp    800862 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	e8 3e fd ff ff       	call   800442 <getint>
  800704:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800707:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80070a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	79 26                	jns    80073a <vprintfmt+0x2b1>
				putch('-', putdat);
  800714:	8b 45 0c             	mov    0xc(%ebp),%eax
  800717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	ff d0                	call   *%eax
				num = -(long long) num;
  800727:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80072d:	f7 d8                	neg    %eax
  80072f:	83 d2 00             	adc    $0x0,%edx
  800732:	f7 da                	neg    %edx
  800734:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800737:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80073a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800741:	e9 a8 00 00 00       	jmp    8007ee <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800746:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	e8 9b fc ff ff       	call   8003f3 <getuint>
  800758:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80075b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80075e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800765:	e9 84 00 00 00       	jmp    8007ee <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80076a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80076d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	e8 77 fc ff ff       	call   8003f3 <getuint>
  80077c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800782:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800789:	eb 63                	jmp    8007ee <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80078b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800792:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	ff d0                	call   *%eax
			putch('x', putdat);
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8d 50 04             	lea    0x4(%eax),%edx
  8007b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ba:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007cd:	eb 1f                	jmp    8007ee <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d9:	89 04 24             	mov    %eax,(%esp)
  8007dc:	e8 12 fc ff ff       	call   8003f3 <getuint>
  8007e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007e4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007e7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ee:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f5:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fc:	89 54 24 14          	mov    %edx,0x14(%esp)
  800800:	89 44 24 10          	mov    %eax,0x10(%esp)
  800804:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800807:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	89 44 24 04          	mov    %eax,0x4(%esp)
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	e8 f1 fa ff ff       	call   800315 <printnum>
			break;
  800824:	eb 3c                	jmp    800862 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082d:	89 1c 24             	mov    %ebx,(%esp)
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	ff d0                	call   *%eax
			break;
  800835:	eb 2b                	jmp    800862 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80084a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80084e:	eb 04                	jmp    800854 <vprintfmt+0x3cb>
  800850:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800854:	8b 45 10             	mov    0x10(%ebp),%eax
  800857:	83 e8 01             	sub    $0x1,%eax
  80085a:	0f b6 00             	movzbl (%eax),%eax
  80085d:	3c 25                	cmp    $0x25,%al
  80085f:	75 ef                	jne    800850 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800861:	90                   	nop
		}
	}
  800862:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800863:	e9 43 fc ff ff       	jmp    8004ab <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800868:	83 c4 40             	add    $0x40,%esp
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
  800878:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 ee fb ff ff       	call   800489 <vprintfmt>
	va_end(ap);
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a3:	8b 40 08             	mov    0x8(%eax),%eax
  8008a6:	8d 50 01             	lea    0x1(%eax),%edx
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ac:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b2:	8b 10                	mov    (%eax),%edx
  8008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b7:	8b 40 04             	mov    0x4(%eax),%eax
  8008ba:	39 c2                	cmp    %eax,%edx
  8008bc:	73 12                	jae    8008d0 <sprintputch+0x33>
		*b->buf++ = ch;
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	8b 00                	mov    (%eax),%eax
  8008c3:	8d 48 01             	lea    0x1(%eax),%ecx
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c9:	89 0a                	mov    %ecx,(%edx)
  8008cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ce:	88 10                	mov    %dl,(%eax)
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	01 d0                	add    %edx,%eax
  8008e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008f7:	74 06                	je     8008ff <vsnprintf+0x2d>
  8008f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008fd:	7f 07                	jg     800906 <vsnprintf+0x34>
		return -E_INVAL;
  8008ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800904:	eb 2a                	jmp    800930 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090d:	8b 45 10             	mov    0x10(%ebp),%eax
  800910:	89 44 24 08          	mov    %eax,0x8(%esp)
  800914:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	c7 04 24 9d 08 80 00 	movl   $0x80089d,(%esp)
  800922:	e8 62 fb ff ff       	call   800489 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800927:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800938:	8d 45 14             	lea    0x14(%ebp),%eax
  80093b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80093e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800941:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800945:	8b 45 10             	mov    0x10(%ebp),%eax
  800948:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	e8 74 ff ff ff       	call   8008d2 <vsnprintf>
  80095e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800961:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80096c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800973:	eb 08                	jmp    80097d <strlen+0x17>
		n++;
  800975:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800979:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	84 c0                	test   %al,%al
  800985:	75 ee                	jne    800975 <strlen+0xf>
		n++;
	return n;
  800987:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800992:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800999:	eb 0c                	jmp    8009a7 <strnlen+0x1b>
		n++;
  80099b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009a3:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8009a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009ab:	74 0a                	je     8009b7 <strnlen+0x2b>
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 00             	movzbl (%eax),%eax
  8009b3:	84 c0                	test   %al,%al
  8009b5:	75 e4                	jne    80099b <strnlen+0xf>
		n++;
	return n;
  8009b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009c8:	90                   	nop
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8d 50 01             	lea    0x1(%eax),%edx
  8009cf:	89 55 08             	mov    %edx,0x8(%ebp)
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009d8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	88 10                	mov    %dl,(%eax)
  8009e0:	0f b6 00             	movzbl (%eax),%eax
  8009e3:	84 c0                	test   %al,%al
  8009e5:	75 e2                	jne    8009c9 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009ea:	c9                   	leave  
  8009eb:	c3                   	ret    

008009ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 69 ff ff ff       	call   800966 <strlen>
  8009fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800a00:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	01 c2                	add    %eax,%edx
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	89 14 24             	mov    %edx,(%esp)
  800a12:	e8 a5 ff ff ff       	call   8009bc <strcpy>
	return dst;
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a1a:	c9                   	leave  
  800a1b:	c3                   	ret    

00800a1c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a2f:	eb 23                	jmp    800a54 <strncpy+0x38>
		*dst++ = *src;
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8d 50 01             	lea    0x1(%eax),%edx
  800a37:	89 55 08             	mov    %edx,0x8(%ebp)
  800a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	0f b6 00             	movzbl (%eax),%eax
  800a48:	84 c0                	test   %al,%al
  800a4a:	74 04                	je     800a50 <strncpy+0x34>
			src++;
  800a4c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a50:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a57:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a5a:	72 d5                	jb     800a31 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a71:	74 33                	je     800aa6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a73:	eb 17                	jmp    800a8c <strlcpy+0x2b>
			*dst++ = *src++;
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8d 50 01             	lea    0x1(%eax),%edx
  800a7b:	89 55 08             	mov    %edx,0x8(%ebp)
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a81:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a84:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a87:	0f b6 12             	movzbl (%edx),%edx
  800a8a:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a8c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a94:	74 0a                	je     800aa0 <strlcpy+0x3f>
  800a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a99:	0f b6 00             	movzbl (%eax),%eax
  800a9c:	84 c0                	test   %al,%al
  800a9e:	75 d5                	jne    800a75 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aac:	29 c2                	sub    %eax,%edx
  800aae:	89 d0                	mov    %edx,%eax
}
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800ab5:	eb 08                	jmp    800abf <strcmp+0xd>
		p++, q++;
  800ab7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800abb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	84 c0                	test   %al,%al
  800ac7:	74 10                	je     800ad9 <strcmp+0x27>
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	0f b6 10             	movzbl (%eax),%edx
  800acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad2:	0f b6 00             	movzbl (%eax),%eax
  800ad5:	38 c2                	cmp    %al,%dl
  800ad7:	74 de                	je     800ab7 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 00             	movzbl (%eax),%eax
  800adf:	0f b6 d0             	movzbl %al,%edx
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	0f b6 00             	movzbl (%eax),%eax
  800ae8:	0f b6 c0             	movzbl %al,%eax
  800aeb:	29 c2                	sub    %eax,%edx
  800aed:	89 d0                	mov    %edx,%eax
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800af4:	eb 0c                	jmp    800b02 <strncmp+0x11>
		n--, p++, q++;
  800af6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800afa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800afe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b06:	74 1a                	je     800b22 <strncmp+0x31>
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	0f b6 00             	movzbl (%eax),%eax
  800b0e:	84 c0                	test   %al,%al
  800b10:	74 10                	je     800b22 <strncmp+0x31>
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	0f b6 10             	movzbl (%eax),%edx
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	0f b6 00             	movzbl (%eax),%eax
  800b1e:	38 c2                	cmp    %al,%dl
  800b20:	74 d4                	je     800af6 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b26:	75 07                	jne    800b2f <strncmp+0x3e>
		return 0;
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	eb 16                	jmp    800b45 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	0f b6 00             	movzbl (%eax),%eax
  800b35:	0f b6 d0             	movzbl %al,%edx
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	0f b6 00             	movzbl (%eax),%eax
  800b3e:	0f b6 c0             	movzbl %al,%eax
  800b41:	29 c2                	sub    %eax,%edx
  800b43:	89 d0                	mov    %edx,%eax
}
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 04             	sub    $0x4,%esp
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b53:	eb 14                	jmp    800b69 <strchr+0x22>
		if (*s == c)
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	0f b6 00             	movzbl (%eax),%eax
  800b5b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b5e:	75 05                	jne    800b65 <strchr+0x1e>
			return (char *) s;
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	eb 13                	jmp    800b78 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b65:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	0f b6 00             	movzbl (%eax),%eax
  800b6f:	84 c0                	test   %al,%al
  800b71:	75 e2                	jne    800b55 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 04             	sub    $0x4,%esp
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b86:	eb 11                	jmp    800b99 <strfind+0x1f>
		if (*s == c)
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	0f b6 00             	movzbl (%eax),%eax
  800b8e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b91:	75 02                	jne    800b95 <strfind+0x1b>
			break;
  800b93:	eb 0e                	jmp    800ba3 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b95:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	0f b6 00             	movzbl (%eax),%eax
  800b9f:	84 c0                	test   %al,%al
  800ba1:	75 e5                	jne    800b88 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
	char *p;

	if (n == 0)
  800bac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bb0:	75 05                	jne    800bb7 <memset+0xf>
		return v;
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	eb 5c                	jmp    800c13 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	83 e0 03             	and    $0x3,%eax
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	75 41                	jne    800c02 <memset+0x5a>
  800bc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc4:	83 e0 03             	and    $0x3,%eax
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	75 37                	jne    800c02 <memset+0x5a>
		c &= 0xFF;
  800bcb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	c1 e0 18             	shl    $0x18,%eax
  800bd8:	89 c2                	mov    %eax,%edx
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	c1 e0 10             	shl    $0x10,%eax
  800be0:	09 c2                	or     %eax,%edx
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	c1 e0 08             	shl    $0x8,%eax
  800be8:	09 d0                	or     %edx,%eax
  800bea:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bed:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf0:	c1 e8 02             	shr    $0x2,%eax
  800bf3:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfb:	89 d7                	mov    %edx,%edi
  800bfd:	fc                   	cld    
  800bfe:	f3 ab                	rep stos %eax,%es:(%edi)
  800c00:	eb 0e                	jmp    800c10 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c08:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c0b:	89 d7                	mov    %edx,%edi
  800c0d:	fc                   	cld    
  800c0e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c31:	73 6d                	jae    800ca0 <memmove+0x8a>
  800c33:	8b 45 10             	mov    0x10(%ebp),%eax
  800c36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c39:	01 d0                	add    %edx,%eax
  800c3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c3e:	76 60                	jbe    800ca0 <memmove+0x8a>
		s += n;
  800c40:	8b 45 10             	mov    0x10(%ebp),%eax
  800c43:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c46:	8b 45 10             	mov    0x10(%ebp),%eax
  800c49:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4f:	83 e0 03             	and    $0x3,%eax
  800c52:	85 c0                	test   %eax,%eax
  800c54:	75 2f                	jne    800c85 <memmove+0x6f>
  800c56:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c59:	83 e0 03             	and    $0x3,%eax
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	75 25                	jne    800c85 <memmove+0x6f>
  800c60:	8b 45 10             	mov    0x10(%ebp),%eax
  800c63:	83 e0 03             	and    $0x3,%eax
  800c66:	85 c0                	test   %eax,%eax
  800c68:	75 1b                	jne    800c85 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6d:	83 e8 04             	sub    $0x4,%eax
  800c70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c73:	83 ea 04             	sub    $0x4,%edx
  800c76:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c79:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	89 d6                	mov    %edx,%esi
  800c80:	fd                   	std    
  800c81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c83:	eb 18                	jmp    800c9d <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c88:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c8e:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c91:	8b 45 10             	mov    0x10(%ebp),%eax
  800c94:	89 d7                	mov    %edx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	89 c1                	mov    %eax,%ecx
  800c9a:	fd                   	std    
  800c9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c9d:	fc                   	cld    
  800c9e:	eb 45                	jmp    800ce5 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca3:	83 e0 03             	and    $0x3,%eax
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	75 2b                	jne    800cd5 <memmove+0xbf>
  800caa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cad:	83 e0 03             	and    $0x3,%eax
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	75 21                	jne    800cd5 <memmove+0xbf>
  800cb4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb7:	83 e0 03             	and    $0x3,%eax
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	75 17                	jne    800cd5 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc1:	c1 e8 02             	shr    $0x2,%eax
  800cc4:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccc:	89 c7                	mov    %eax,%edi
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	fc                   	cld    
  800cd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cd3:	eb 10                	jmp    800ce5 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cde:	89 c7                	mov    %eax,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	fc                   	cld    
  800ce3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ce8:	83 c4 10             	add    $0x10,%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	89 04 24             	mov    %eax,(%esp)
  800d0a:	e8 07 ff ff ff       	call   800c16 <memmove>
}
  800d0f:	c9                   	leave  
  800d10:	c3                   	ret    

00800d11 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d23:	eb 30                	jmp    800d55 <memcmp+0x44>
		if (*s1 != *s2)
  800d25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d28:	0f b6 10             	movzbl (%eax),%edx
  800d2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d2e:	0f b6 00             	movzbl (%eax),%eax
  800d31:	38 c2                	cmp    %al,%dl
  800d33:	74 18                	je     800d4d <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d38:	0f b6 00             	movzbl (%eax),%eax
  800d3b:	0f b6 d0             	movzbl %al,%edx
  800d3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d41:	0f b6 00             	movzbl (%eax),%eax
  800d44:	0f b6 c0             	movzbl %al,%eax
  800d47:	29 c2                	sub    %eax,%edx
  800d49:	89 d0                	mov    %edx,%eax
  800d4b:	eb 1a                	jmp    800d67 <memcmp+0x56>
		s1++, s2++;
  800d4d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d51:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d55:	8b 45 10             	mov    0x10(%ebp),%eax
  800d58:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d5b:	89 55 10             	mov    %edx,0x10(%ebp)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	75 c3                	jne    800d25 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	01 d0                	add    %edx,%eax
  800d77:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d7a:	eb 13                	jmp    800d8f <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 10             	movzbl (%eax),%edx
  800d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d85:	38 c2                	cmp    %al,%dl
  800d87:	75 02                	jne    800d8b <memfind+0x22>
			break;
  800d89:	eb 0c                	jmp    800d97 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d8b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d95:	72 e5                	jb     800d7c <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d9a:	c9                   	leave  
  800d9b:	c3                   	ret    

00800d9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800da2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800da9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db0:	eb 04                	jmp    800db6 <strtol+0x1a>
		s++;
  800db2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	0f b6 00             	movzbl (%eax),%eax
  800dbc:	3c 20                	cmp    $0x20,%al
  800dbe:	74 f2                	je     800db2 <strtol+0x16>
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	0f b6 00             	movzbl (%eax),%eax
  800dc6:	3c 09                	cmp    $0x9,%al
  800dc8:	74 e8                	je     800db2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	0f b6 00             	movzbl (%eax),%eax
  800dd0:	3c 2b                	cmp    $0x2b,%al
  800dd2:	75 06                	jne    800dda <strtol+0x3e>
		s++;
  800dd4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd8:	eb 15                	jmp    800def <strtol+0x53>
	else if (*s == '-')
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	3c 2d                	cmp    $0x2d,%al
  800de2:	75 0b                	jne    800def <strtol+0x53>
		s++, neg = 1;
  800de4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800def:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df3:	74 06                	je     800dfb <strtol+0x5f>
  800df5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800df9:	75 24                	jne    800e1f <strtol+0x83>
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	0f b6 00             	movzbl (%eax),%eax
  800e01:	3c 30                	cmp    $0x30,%al
  800e03:	75 1a                	jne    800e1f <strtol+0x83>
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	83 c0 01             	add    $0x1,%eax
  800e0b:	0f b6 00             	movzbl (%eax),%eax
  800e0e:	3c 78                	cmp    $0x78,%al
  800e10:	75 0d                	jne    800e1f <strtol+0x83>
		s += 2, base = 16;
  800e12:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e16:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e1d:	eb 2a                	jmp    800e49 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e23:	75 17                	jne    800e3c <strtol+0xa0>
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	0f b6 00             	movzbl (%eax),%eax
  800e2b:	3c 30                	cmp    $0x30,%al
  800e2d:	75 0d                	jne    800e3c <strtol+0xa0>
		s++, base = 8;
  800e2f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e33:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e3a:	eb 0d                	jmp    800e49 <strtol+0xad>
	else if (base == 0)
  800e3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e40:	75 07                	jne    800e49 <strtol+0xad>
		base = 10;
  800e42:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	0f b6 00             	movzbl (%eax),%eax
  800e4f:	3c 2f                	cmp    $0x2f,%al
  800e51:	7e 1b                	jle    800e6e <strtol+0xd2>
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	3c 39                	cmp    $0x39,%al
  800e5b:	7f 11                	jg     800e6e <strtol+0xd2>
			dig = *s - '0';
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	0f b6 00             	movzbl (%eax),%eax
  800e63:	0f be c0             	movsbl %al,%eax
  800e66:	83 e8 30             	sub    $0x30,%eax
  800e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e6c:	eb 48                	jmp    800eb6 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	0f b6 00             	movzbl (%eax),%eax
  800e74:	3c 60                	cmp    $0x60,%al
  800e76:	7e 1b                	jle    800e93 <strtol+0xf7>
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	0f b6 00             	movzbl (%eax),%eax
  800e7e:	3c 7a                	cmp    $0x7a,%al
  800e80:	7f 11                	jg     800e93 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e82:	8b 45 08             	mov    0x8(%ebp),%eax
  800e85:	0f b6 00             	movzbl (%eax),%eax
  800e88:	0f be c0             	movsbl %al,%eax
  800e8b:	83 e8 57             	sub    $0x57,%eax
  800e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e91:	eb 23                	jmp    800eb6 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	0f b6 00             	movzbl (%eax),%eax
  800e99:	3c 40                	cmp    $0x40,%al
  800e9b:	7e 3d                	jle    800eda <strtol+0x13e>
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	0f b6 00             	movzbl (%eax),%eax
  800ea3:	3c 5a                	cmp    $0x5a,%al
  800ea5:	7f 33                	jg     800eda <strtol+0x13e>
			dig = *s - 'A' + 10;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	0f b6 00             	movzbl (%eax),%eax
  800ead:	0f be c0             	movsbl %al,%eax
  800eb0:	83 e8 37             	sub    $0x37,%eax
  800eb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ebc:	7c 02                	jl     800ec0 <strtol+0x124>
			break;
  800ebe:	eb 1a                	jmp    800eda <strtol+0x13e>
		s++, val = (val * base) + dig;
  800ec0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ec4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ec7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed0:	01 d0                	add    %edx,%eax
  800ed2:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ed5:	e9 6f ff ff ff       	jmp    800e49 <strtol+0xad>

	if (endptr)
  800eda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ede:	74 08                	je     800ee8 <strtol+0x14c>
		*endptr = (char *) s;
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ee8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800eec:	74 07                	je     800ef5 <strtol+0x159>
  800eee:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ef1:	f7 d8                	neg    %eax
  800ef3:	eb 03                	jmp    800ef8 <strtol+0x15c>
  800ef5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
  800f00:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	8b 55 10             	mov    0x10(%ebp),%edx
  800f09:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f0c:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800f0f:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f12:	8b 75 20             	mov    0x20(%ebp),%esi
  800f15:	cd 30                	int    $0x30
  800f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f1e:	74 30                	je     800f50 <syscall+0x56>
  800f20:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f24:	7e 2a                	jle    800f50 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f34:	c7 44 24 08 c4 1e 80 	movl   $0x801ec4,0x8(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f43:	00 
  800f44:	c7 04 24 e1 1e 80 00 	movl   $0x801ee1,(%esp)
  800f4b:	e8 84 f2 ff ff       	call   8001d4 <_panic>

	return ret;
  800f50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f53:	83 c4 3c             	add    $0x3c,%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f73:	00 
  800f74:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f7b:	00 
  800f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f8e:	00 
  800f8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f96:	e8 5f ff ff ff       	call   800efa <syscall>
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <sys_cgetc>:

int
sys_cgetc(void)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fa3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800faa:	00 
  800fab:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fba:	00 
  800fbb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fda:	e8 1b ff ff ff       	call   800efa <syscall>
}
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801001:	00 
  801002:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801009:	00 
  80100a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801015:	00 
  801016:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80101d:	e8 d8 fe ff ff       	call   800efa <syscall>
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80102a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801031:	00 
  801032:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801039:	00 
  80103a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801041:	00 
  801042:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801049:	00 
  80104a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801051:	00 
  801052:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801059:	00 
  80105a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801061:	e8 94 fe ff ff       	call   800efa <syscall>
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <sys_yield>:

void
sys_yield(void)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80106e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801075:	00 
  801076:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80107d:	00 
  80107e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801085:	00 
  801086:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80108d:	00 
  80108e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801095:	00 
  801096:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80109d:	00 
  80109e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8010a5:	e8 50 fe ff ff       	call   800efa <syscall>
}
  8010aa:	c9                   	leave  
  8010ab:	c3                   	ret    

008010ac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010c2:	00 
  8010c3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ca:	00 
  8010cb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010de:	00 
  8010df:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010e6:	e8 0f fe ff ff       	call   800efa <syscall>
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010f5:	8b 75 18             	mov    0x18(%ebp),%esi
  8010f8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	89 74 24 18          	mov    %esi,0x18(%esp)
  801108:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80110c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801110:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801114:	89 44 24 08          	mov    %eax,0x8(%esp)
  801118:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801127:	e8 ce fd ff ff       	call   800efa <syscall>
}
  80112c:	83 c4 20             	add    $0x20,%esp
  80112f:	5b                   	pop    %ebx
  801130:	5e                   	pop    %esi
  801131:	5d                   	pop    %ebp
  801132:	c3                   	ret    

00801133 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801139:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113c:	8b 45 08             	mov    0x8(%ebp),%eax
  80113f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801146:	00 
  801147:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114e:	00 
  80114f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801156:	00 
  801157:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80115b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801166:	00 
  801167:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80116e:	e8 87 fd ff ff       	call   800efa <syscall>
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80117b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801188:	00 
  801189:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801190:	00 
  801191:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801198:	00 
  801199:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80119d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011a8:	00 
  8011a9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011b0:	e8 45 fd ff ff       	call   800efa <syscall>
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011da:	00 
  8011db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011f2:	e8 03 fd ff ff       	call   800efa <syscall>
}
  8011f7:	c9                   	leave  
  8011f8:	c3                   	ret    

008011f9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801202:	8b 55 10             	mov    0x10(%ebp),%edx
  801205:	8b 45 08             	mov    0x8(%ebp),%eax
  801208:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80120f:	00 
  801210:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801214:	89 54 24 10          	mov    %edx,0x10(%esp)
  801218:	8b 55 0c             	mov    0xc(%ebp),%edx
  80121b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80121f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801223:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80122a:	00 
  80122b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801232:	e8 c3 fc ff ff       	call   800efa <syscall>
}
  801237:	c9                   	leave  
  801238:	c3                   	ret    

00801239 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801249:	00 
  80124a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801251:	00 
  801252:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801259:	00 
  80125a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801261:	00 
  801262:	89 44 24 08          	mov    %eax,0x8(%esp)
  801266:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80126d:	00 
  80126e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801275:	e8 80 fc ff ff       	call   800efa <syscall>
}
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <sys_exec>:

void sys_exec(char* buf){
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
  801285:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80128c:	00 
  80128d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801294:	00 
  801295:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80129c:	00 
  80129d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012a4:	00 
  8012a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8012b8:	e8 3d fc ff ff       	call   800efa <syscall>
}
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c8:	8b 00                	mov    (%eax),%eax
  8012ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8012cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d0:	8b 40 04             	mov    0x4(%eax),%eax
  8012d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  8012d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d9:	83 e0 02             	and    $0x2,%eax
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	75 23                	jne    801303 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8012e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e7:	c7 44 24 08 f0 1e 80 	movl   $0x801ef0,0x8(%esp)
  8012ee:	00 
  8012ef:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8012f6:	00 
  8012f7:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  8012fe:	e8 d1 ee ff ff       	call   8001d4 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801306:	c1 e8 0c             	shr    $0xc,%eax
  801309:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  80130c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80130f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801316:	25 00 08 00 00       	and    $0x800,%eax
  80131b:	85 c0                	test   %eax,%eax
  80131d:	75 1c                	jne    80133b <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  80131f:	c7 44 24 08 2c 1f 80 	movl   $0x801f2c,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  801336:	e8 99 ee ff ff       	call   8001d4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  80133b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801342:	00 
  801343:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80134a:	00 
  80134b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801352:	e8 55 fd ff ff       	call   8010ac <sys_page_alloc>
  801357:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80135a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80135e:	79 23                	jns    801383 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  801360:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801363:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801367:	c7 44 24 08 68 1f 80 	movl   $0x801f68,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  80137e:	e8 51 ee ff ff       	call   8001d4 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801383:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801386:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801389:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80138c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801391:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801398:	00 
  801399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013a4:	e8 47 f9 ff ff       	call   800cf0 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  8013a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013be:	00 
  8013bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013da:	e8 0e fd ff ff       	call   8010ed <sys_page_map>
  8013df:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8013e2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013e6:	79 23                	jns    80140b <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8013e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ef:	c7 44 24 08 a0 1f 80 	movl   $0x801fa0,0x8(%esp)
  8013f6:	00 
  8013f7:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  8013fe:	00 
  8013ff:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  801406:	e8 c9 ed ff ff       	call   8001d4 <_panic>
	}

	// panic("pgfault not implemented");
}
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
  801412:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801415:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801426:	25 00 08 00 00       	and    $0x800,%eax
  80142b:	85 c0                	test   %eax,%eax
  80142d:	75 15                	jne    801444 <duppage+0x37>
  80142f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801432:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801439:	83 e0 02             	and    $0x2,%eax
  80143c:	85 c0                	test   %eax,%eax
  80143e:	0f 84 e0 00 00 00    	je     801524 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  801444:	8b 45 0c             	mov    0xc(%ebp),%eax
  801447:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144e:	83 e0 04             	and    $0x4,%eax
  801451:	85 c0                	test   %eax,%eax
  801453:	74 04                	je     801459 <duppage+0x4c>
  801455:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  801459:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	c1 e0 0c             	shl    $0xc,%eax
  801462:	89 c1                	mov    %eax,%ecx
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
  801467:	c1 e0 0c             	shl    $0xc,%eax
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	a1 04 30 80 00       	mov    0x803004,%eax
  801471:	8b 40 48             	mov    0x48(%eax),%eax
  801474:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801478:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80147c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801483:	89 54 24 04          	mov    %edx,0x4(%esp)
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 5e fc ff ff       	call   8010ed <sys_page_map>
  80148f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801492:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801496:	79 23                	jns    8014bb <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801498:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80149f:	c7 44 24 08 d4 1f 80 	movl   $0x801fd4,0x8(%esp)
  8014a6:	00 
  8014a7:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8014ae:	00 
  8014af:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  8014b6:	e8 19 ed ff ff       	call   8001d4 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014bb:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8014be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c1:	c1 e0 0c             	shl    $0xc,%eax
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	a1 04 30 80 00       	mov    0x803004,%eax
  8014cb:	8b 48 48             	mov    0x48(%eax),%ecx
  8014ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d1:	c1 e0 0c             	shl    $0xc,%eax
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	a1 04 30 80 00       	mov    0x803004,%eax
  8014db:	8b 40 48             	mov    0x48(%eax),%eax
  8014de:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014e6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014ee:	89 04 24             	mov    %eax,(%esp)
  8014f1:	e8 f7 fb ff ff       	call   8010ed <sys_page_map>
  8014f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014fd:	79 23                	jns    801522 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801506:	c7 44 24 08 10 20 80 	movl   $0x802010,0x8(%esp)
  80150d:	00 
  80150e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801515:	00 
  801516:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  80151d:	e8 b2 ec ff ff       	call   8001d4 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801522:	eb 70                	jmp    801594 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801524:	8b 45 0c             	mov    0xc(%ebp),%eax
  801527:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80152e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801533:	89 c3                	mov    %eax,%ebx
  801535:	8b 45 0c             	mov    0xc(%ebp),%eax
  801538:	c1 e0 0c             	shl    $0xc,%eax
  80153b:	89 c1                	mov    %eax,%ecx
  80153d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801540:	c1 e0 0c             	shl    $0xc,%eax
  801543:	89 c2                	mov    %eax,%edx
  801545:	a1 04 30 80 00       	mov    0x803004,%eax
  80154a:	8b 40 48             	mov    0x48(%eax),%eax
  80154d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801551:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801555:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80155c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801560:	89 04 24             	mov    %eax,(%esp)
  801563:	e8 85 fb ff ff       	call   8010ed <sys_page_map>
  801568:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80156b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80156f:	79 23                	jns    801594 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801578:	c7 44 24 08 40 20 80 	movl   $0x802040,0x8(%esp)
  80157f:	00 
  801580:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801587:	00 
  801588:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  80158f:	e8 40 ec ff ff       	call   8001d4 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801594:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801599:	83 c4 30             	add    $0x30,%esp
  80159c:	5b                   	pop    %ebx
  80159d:	5e                   	pop    %esi
  80159e:	5d                   	pop    %ebp
  80159f:	c3                   	ret    

008015a0 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8015a6:	c7 04 24 bf 12 80 00 	movl   $0x8012bf,(%esp)
  8015ad:	e8 2d 03 00 00       	call   8018df <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8015b7:	cd 30                	int    $0x30
  8015b9:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8015bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8015bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8015c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015c6:	79 23                	jns    8015eb <fork+0x4b>
  8015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015cf:	c7 44 24 08 78 20 80 	movl   $0x802078,0x8(%esp)
  8015d6:	00 
  8015d7:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015de:	00 
  8015df:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  8015e6:	e8 e9 eb ff ff       	call   8001d4 <_panic>
	else if(childeid == 0){
  8015eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015ef:	75 29                	jne    80161a <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8015f1:	e8 2e fa ff ff       	call   801024 <sys_getenvid>
  8015f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015fb:	c1 e0 02             	shl    $0x2,%eax
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	c1 e2 05             	shl    $0x5,%edx
  801603:	29 c2                	sub    %eax,%edx
  801605:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80160b:	a3 04 30 80 00       	mov    %eax,0x803004
		// set_pgfault_handler(pgfault);
		return 0;
  801610:	b8 00 00 00 00       	mov    $0x0,%eax
  801615:	e9 16 01 00 00       	jmp    801730 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80161a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801621:	eb 3b                	jmp    80165e <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	c1 f8 0a             	sar    $0xa,%eax
  801629:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801630:	83 e0 01             	and    $0x1,%eax
  801633:	85 c0                	test   %eax,%eax
  801635:	74 23                	je     80165a <fork+0xba>
  801637:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801641:	83 e0 01             	and    $0x1,%eax
  801644:	85 c0                	test   %eax,%eax
  801646:	74 12                	je     80165a <fork+0xba>
			duppage(childeid, i);
  801648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	89 04 24             	mov    %eax,(%esp)
  801655:	e8 b3 fd ff ff       	call   80140d <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80165a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801666:	76 bb                	jbe    801623 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801668:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80166f:	00 
  801670:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801677:	ee 
  801678:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 29 fa ff ff       	call   8010ac <sys_page_alloc>
  801683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801686:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80168a:	79 23                	jns    8016af <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  80168c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80168f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801693:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  80169a:	00 
  80169b:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8016a2:	00 
  8016a3:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  8016aa:	e8 25 eb ff ff       	call   8001d4 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  8016af:	c7 44 24 04 55 19 80 	movl   $0x801955,0x4(%esp)
  8016b6:	00 
  8016b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 f5 fa ff ff       	call   8011b7 <sys_env_set_pgfault_upcall>
  8016c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016c9:	79 23                	jns    8016ee <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8016cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d2:	c7 44 24 08 c8 20 80 	movl   $0x8020c8,0x8(%esp)
  8016d9:	00 
  8016da:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8016e1:	00 
  8016e2:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  8016e9:	e8 e6 ea ff ff       	call   8001d4 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  8016ee:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016f5:	00 
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 74 fa ff ff       	call   801175 <sys_env_set_status>
  801701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801704:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801708:	79 23                	jns    80172d <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  80170a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80170d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801711:	c7 44 24 08 fc 20 80 	movl   $0x8020fc,0x8(%esp)
  801718:	00 
  801719:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801720:	00 
  801721:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  801728:	e8 a7 ea ff ff       	call   8001d4 <_panic>
	}
	return childeid;
  80172d:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <sfork>:

// Challenge!
int
sfork(void)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801738:	c7 44 24 08 25 21 80 	movl   $0x802125,0x8(%esp)
  80173f:	00 
  801740:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801747:	00 
  801748:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  80174f:	e8 80 ea ff ff       	call   8001d4 <_panic>

00801754 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  80175a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80175e:	75 09                	jne    801769 <ipc_recv+0x15>
		i_dstva = UTOP;
  801760:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  801767:	eb 06                	jmp    80176f <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  801769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  80176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801772:	89 04 24             	mov    %eax,(%esp)
  801775:	e8 bf fa ff ff       	call   801239 <sys_ipc_recv>
  80177a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  80177d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801781:	75 15                	jne    801798 <ipc_recv+0x44>
  801783:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801787:	74 0f                	je     801798 <ipc_recv+0x44>
  801789:	a1 04 30 80 00       	mov    0x803004,%eax
  80178e:	8b 50 74             	mov    0x74(%eax),%edx
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	89 10                	mov    %edx,(%eax)
  801796:	eb 15                	jmp    8017ad <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  801798:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80179c:	79 0f                	jns    8017ad <ipc_recv+0x59>
  80179e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8017a2:	74 09                	je     8017ad <ipc_recv+0x59>
  8017a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  8017ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017b1:	75 15                	jne    8017c8 <ipc_recv+0x74>
  8017b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017b7:	74 0f                	je     8017c8 <ipc_recv+0x74>
  8017b9:	a1 04 30 80 00       	mov    0x803004,%eax
  8017be:	8b 50 78             	mov    0x78(%eax),%edx
  8017c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c4:	89 10                	mov    %edx,(%eax)
  8017c6:	eb 15                	jmp    8017dd <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  8017c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017cc:	79 0f                	jns    8017dd <ipc_recv+0x89>
  8017ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017d2:	74 09                	je     8017dd <ipc_recv+0x89>
  8017d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  8017dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017e1:	75 0a                	jne    8017ed <ipc_recv+0x99>
  8017e3:	a1 04 30 80 00       	mov    0x803004,%eax
  8017e8:	8b 40 70             	mov    0x70(%eax),%eax
  8017eb:	eb 03                	jmp    8017f0 <ipc_recv+0x9c>
	else return r;
  8017ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  8017f8:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  8017ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801803:	74 06                	je     80180b <ipc_send+0x19>
  801805:	8b 45 10             	mov    0x10(%ebp),%eax
  801808:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  80180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180e:	8b 55 14             	mov    0x14(%ebp),%edx
  801811:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801815:	89 44 24 08          	mov    %eax,0x8(%esp)
  801819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 ce f9 ff ff       	call   8011f9 <sys_ipc_try_send>
  80182b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  80182e:	eb 28                	jmp    801858 <ipc_send+0x66>
		sys_yield();
  801830:	e8 33 f8 ff ff       	call   801068 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801838:	8b 55 14             	mov    0x14(%ebp),%edx
  80183b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80183f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801843:	8b 45 0c             	mov    0xc(%ebp),%eax
  801846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	89 04 24             	mov    %eax,(%esp)
  801850:	e8 a4 f9 ff ff       	call   8011f9 <sys_ipc_try_send>
  801855:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  801858:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  80185c:	74 d2                	je     801830 <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  80185e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801862:	75 02                	jne    801866 <ipc_send+0x74>
  801864:	eb 23                	jmp    801889 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  801866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186d:	c7 44 24 08 3c 21 80 	movl   $0x80213c,0x8(%esp)
  801874:	00 
  801875:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80187c:	00 
  80187d:	c7 04 24 61 21 80 00 	movl   $0x802161,(%esp)
  801884:	e8 4b e9 ff ff       	call   8001d4 <_panic>
	panic("ipc_send not implemented");
}
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  801891:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801898:	eb 35                	jmp    8018cf <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  80189a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80189d:	c1 e0 02             	shl    $0x2,%eax
  8018a0:	89 c2                	mov    %eax,%edx
  8018a2:	c1 e2 05             	shl    $0x5,%edx
  8018a5:	29 c2                	sub    %eax,%edx
  8018a7:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8018ad:	8b 00                	mov    (%eax),%eax
  8018af:	3b 45 08             	cmp    0x8(%ebp),%eax
  8018b2:	75 17                	jne    8018cb <ipc_find_env+0x40>
			return envs[i].env_id;
  8018b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018b7:	c1 e0 02             	shl    $0x2,%eax
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	c1 e2 05             	shl    $0x5,%edx
  8018bf:	29 c2                	sub    %eax,%edx
  8018c1:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8018c7:	8b 00                	mov    (%eax),%eax
  8018c9:	eb 12                	jmp    8018dd <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018cb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8018cf:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8018d6:	7e c2                	jle    80189a <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018e5:	a1 08 30 80 00       	mov    0x803008,%eax
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	75 5d                	jne    80194b <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8018ee:	a1 04 30 80 00       	mov    0x803004,%eax
  8018f3:	8b 40 48             	mov    0x48(%eax),%eax
  8018f6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018fd:	00 
  8018fe:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801905:	ee 
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 9e f7 ff ff       	call   8010ac <sys_page_alloc>
  80190e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801911:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801915:	79 1c                	jns    801933 <set_pgfault_handler+0x54>
  801917:	c7 44 24 08 6c 21 80 	movl   $0x80216c,0x8(%esp)
  80191e:	00 
  80191f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801926:	00 
  801927:	c7 04 24 98 21 80 00 	movl   $0x802198,(%esp)
  80192e:	e8 a1 e8 ff ff       	call   8001d4 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801933:	a1 04 30 80 00       	mov    0x803004,%eax
  801938:	8b 40 48             	mov    0x48(%eax),%eax
  80193b:	c7 44 24 04 55 19 80 	movl   $0x801955,0x4(%esp)
  801942:	00 
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 6c f8 ff ff       	call   8011b7 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	a3 08 30 80 00       	mov    %eax,0x803008
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801955:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801956:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  80195b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80195d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801960:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801964:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801966:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80196a:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80196b:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80196e:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801970:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801971:	58                   	pop    %eax
	popal 						// pop all the registers
  801972:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801973:	83 c4 04             	add    $0x4,%esp
	popfl
  801976:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801977:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801978:	c3                   	ret    
  801979:	66 90                	xchg   %ax,%ax
  80197b:	66 90                	xchg   %ax,%ax
  80197d:	66 90                	xchg   %ax,%ax
  80197f:	90                   	nop

00801980 <__udivdi3>:
  801980:	55                   	push   %ebp
  801981:	57                   	push   %edi
  801982:	56                   	push   %esi
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	8b 44 24 28          	mov    0x28(%esp),%eax
  80198a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80198e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801992:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801996:	85 c0                	test   %eax,%eax
  801998:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80199c:	89 ea                	mov    %ebp,%edx
  80199e:	89 0c 24             	mov    %ecx,(%esp)
  8019a1:	75 2d                	jne    8019d0 <__udivdi3+0x50>
  8019a3:	39 e9                	cmp    %ebp,%ecx
  8019a5:	77 61                	ja     801a08 <__udivdi3+0x88>
  8019a7:	85 c9                	test   %ecx,%ecx
  8019a9:	89 ce                	mov    %ecx,%esi
  8019ab:	75 0b                	jne    8019b8 <__udivdi3+0x38>
  8019ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b2:	31 d2                	xor    %edx,%edx
  8019b4:	f7 f1                	div    %ecx
  8019b6:	89 c6                	mov    %eax,%esi
  8019b8:	31 d2                	xor    %edx,%edx
  8019ba:	89 e8                	mov    %ebp,%eax
  8019bc:	f7 f6                	div    %esi
  8019be:	89 c5                	mov    %eax,%ebp
  8019c0:	89 f8                	mov    %edi,%eax
  8019c2:	f7 f6                	div    %esi
  8019c4:	89 ea                	mov    %ebp,%edx
  8019c6:	83 c4 0c             	add    $0xc,%esp
  8019c9:	5e                   	pop    %esi
  8019ca:	5f                   	pop    %edi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    
  8019cd:	8d 76 00             	lea    0x0(%esi),%esi
  8019d0:	39 e8                	cmp    %ebp,%eax
  8019d2:	77 24                	ja     8019f8 <__udivdi3+0x78>
  8019d4:	0f bd e8             	bsr    %eax,%ebp
  8019d7:	83 f5 1f             	xor    $0x1f,%ebp
  8019da:	75 3c                	jne    801a18 <__udivdi3+0x98>
  8019dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019e0:	39 34 24             	cmp    %esi,(%esp)
  8019e3:	0f 86 9f 00 00 00    	jbe    801a88 <__udivdi3+0x108>
  8019e9:	39 d0                	cmp    %edx,%eax
  8019eb:	0f 82 97 00 00 00    	jb     801a88 <__udivdi3+0x108>
  8019f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019f8:	31 d2                	xor    %edx,%edx
  8019fa:	31 c0                	xor    %eax,%eax
  8019fc:	83 c4 0c             	add    $0xc,%esp
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    
  801a03:	90                   	nop
  801a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a08:	89 f8                	mov    %edi,%eax
  801a0a:	f7 f1                	div    %ecx
  801a0c:	31 d2                	xor    %edx,%edx
  801a0e:	83 c4 0c             	add    $0xc,%esp
  801a11:	5e                   	pop    %esi
  801a12:	5f                   	pop    %edi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    
  801a15:	8d 76 00             	lea    0x0(%esi),%esi
  801a18:	89 e9                	mov    %ebp,%ecx
  801a1a:	8b 3c 24             	mov    (%esp),%edi
  801a1d:	d3 e0                	shl    %cl,%eax
  801a1f:	89 c6                	mov    %eax,%esi
  801a21:	b8 20 00 00 00       	mov    $0x20,%eax
  801a26:	29 e8                	sub    %ebp,%eax
  801a28:	89 c1                	mov    %eax,%ecx
  801a2a:	d3 ef                	shr    %cl,%edi
  801a2c:	89 e9                	mov    %ebp,%ecx
  801a2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a32:	8b 3c 24             	mov    (%esp),%edi
  801a35:	09 74 24 08          	or     %esi,0x8(%esp)
  801a39:	89 d6                	mov    %edx,%esi
  801a3b:	d3 e7                	shl    %cl,%edi
  801a3d:	89 c1                	mov    %eax,%ecx
  801a3f:	89 3c 24             	mov    %edi,(%esp)
  801a42:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a46:	d3 ee                	shr    %cl,%esi
  801a48:	89 e9                	mov    %ebp,%ecx
  801a4a:	d3 e2                	shl    %cl,%edx
  801a4c:	89 c1                	mov    %eax,%ecx
  801a4e:	d3 ef                	shr    %cl,%edi
  801a50:	09 d7                	or     %edx,%edi
  801a52:	89 f2                	mov    %esi,%edx
  801a54:	89 f8                	mov    %edi,%eax
  801a56:	f7 74 24 08          	divl   0x8(%esp)
  801a5a:	89 d6                	mov    %edx,%esi
  801a5c:	89 c7                	mov    %eax,%edi
  801a5e:	f7 24 24             	mull   (%esp)
  801a61:	39 d6                	cmp    %edx,%esi
  801a63:	89 14 24             	mov    %edx,(%esp)
  801a66:	72 30                	jb     801a98 <__udivdi3+0x118>
  801a68:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a6c:	89 e9                	mov    %ebp,%ecx
  801a6e:	d3 e2                	shl    %cl,%edx
  801a70:	39 c2                	cmp    %eax,%edx
  801a72:	73 05                	jae    801a79 <__udivdi3+0xf9>
  801a74:	3b 34 24             	cmp    (%esp),%esi
  801a77:	74 1f                	je     801a98 <__udivdi3+0x118>
  801a79:	89 f8                	mov    %edi,%eax
  801a7b:	31 d2                	xor    %edx,%edx
  801a7d:	e9 7a ff ff ff       	jmp    8019fc <__udivdi3+0x7c>
  801a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a88:	31 d2                	xor    %edx,%edx
  801a8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8f:	e9 68 ff ff ff       	jmp    8019fc <__udivdi3+0x7c>
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a9b:	31 d2                	xor    %edx,%edx
  801a9d:	83 c4 0c             	add    $0xc,%esp
  801aa0:	5e                   	pop    %esi
  801aa1:	5f                   	pop    %edi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    
  801aa4:	66 90                	xchg   %ax,%ax
  801aa6:	66 90                	xchg   %ax,%ax
  801aa8:	66 90                	xchg   %ax,%ax
  801aaa:	66 90                	xchg   %ax,%ax
  801aac:	66 90                	xchg   %ax,%ax
  801aae:	66 90                	xchg   %ax,%ax

00801ab0 <__umoddi3>:
  801ab0:	55                   	push   %ebp
  801ab1:	57                   	push   %edi
  801ab2:	56                   	push   %esi
  801ab3:	83 ec 14             	sub    $0x14,%esp
  801ab6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801aba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801abe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ac2:	89 c7                	mov    %eax,%edi
  801ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801acc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ad0:	89 34 24             	mov    %esi,(%esp)
  801ad3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	89 c2                	mov    %eax,%edx
  801adb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801adf:	75 17                	jne    801af8 <__umoddi3+0x48>
  801ae1:	39 fe                	cmp    %edi,%esi
  801ae3:	76 4b                	jbe    801b30 <__umoddi3+0x80>
  801ae5:	89 c8                	mov    %ecx,%eax
  801ae7:	89 fa                	mov    %edi,%edx
  801ae9:	f7 f6                	div    %esi
  801aeb:	89 d0                	mov    %edx,%eax
  801aed:	31 d2                	xor    %edx,%edx
  801aef:	83 c4 14             	add    $0x14,%esp
  801af2:	5e                   	pop    %esi
  801af3:	5f                   	pop    %edi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    
  801af6:	66 90                	xchg   %ax,%ax
  801af8:	39 f8                	cmp    %edi,%eax
  801afa:	77 54                	ja     801b50 <__umoddi3+0xa0>
  801afc:	0f bd e8             	bsr    %eax,%ebp
  801aff:	83 f5 1f             	xor    $0x1f,%ebp
  801b02:	75 5c                	jne    801b60 <__umoddi3+0xb0>
  801b04:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b08:	39 3c 24             	cmp    %edi,(%esp)
  801b0b:	0f 87 e7 00 00 00    	ja     801bf8 <__umoddi3+0x148>
  801b11:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b15:	29 f1                	sub    %esi,%ecx
  801b17:	19 c7                	sbb    %eax,%edi
  801b19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b21:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b25:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b29:	83 c4 14             	add    $0x14,%esp
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    
  801b30:	85 f6                	test   %esi,%esi
  801b32:	89 f5                	mov    %esi,%ebp
  801b34:	75 0b                	jne    801b41 <__umoddi3+0x91>
  801b36:	b8 01 00 00 00       	mov    $0x1,%eax
  801b3b:	31 d2                	xor    %edx,%edx
  801b3d:	f7 f6                	div    %esi
  801b3f:	89 c5                	mov    %eax,%ebp
  801b41:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b45:	31 d2                	xor    %edx,%edx
  801b47:	f7 f5                	div    %ebp
  801b49:	89 c8                	mov    %ecx,%eax
  801b4b:	f7 f5                	div    %ebp
  801b4d:	eb 9c                	jmp    801aeb <__umoddi3+0x3b>
  801b4f:	90                   	nop
  801b50:	89 c8                	mov    %ecx,%eax
  801b52:	89 fa                	mov    %edi,%edx
  801b54:	83 c4 14             	add    $0x14,%esp
  801b57:	5e                   	pop    %esi
  801b58:	5f                   	pop    %edi
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    
  801b5b:	90                   	nop
  801b5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b60:	8b 04 24             	mov    (%esp),%eax
  801b63:	be 20 00 00 00       	mov    $0x20,%esi
  801b68:	89 e9                	mov    %ebp,%ecx
  801b6a:	29 ee                	sub    %ebp,%esi
  801b6c:	d3 e2                	shl    %cl,%edx
  801b6e:	89 f1                	mov    %esi,%ecx
  801b70:	d3 e8                	shr    %cl,%eax
  801b72:	89 e9                	mov    %ebp,%ecx
  801b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b78:	8b 04 24             	mov    (%esp),%eax
  801b7b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b7f:	89 fa                	mov    %edi,%edx
  801b81:	d3 e0                	shl    %cl,%eax
  801b83:	89 f1                	mov    %esi,%ecx
  801b85:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b89:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b8d:	d3 ea                	shr    %cl,%edx
  801b8f:	89 e9                	mov    %ebp,%ecx
  801b91:	d3 e7                	shl    %cl,%edi
  801b93:	89 f1                	mov    %esi,%ecx
  801b95:	d3 e8                	shr    %cl,%eax
  801b97:	89 e9                	mov    %ebp,%ecx
  801b99:	09 f8                	or     %edi,%eax
  801b9b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b9f:	f7 74 24 04          	divl   0x4(%esp)
  801ba3:	d3 e7                	shl    %cl,%edi
  801ba5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ba9:	89 d7                	mov    %edx,%edi
  801bab:	f7 64 24 08          	mull   0x8(%esp)
  801baf:	39 d7                	cmp    %edx,%edi
  801bb1:	89 c1                	mov    %eax,%ecx
  801bb3:	89 14 24             	mov    %edx,(%esp)
  801bb6:	72 2c                	jb     801be4 <__umoddi3+0x134>
  801bb8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bbc:	72 22                	jb     801be0 <__umoddi3+0x130>
  801bbe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bc2:	29 c8                	sub    %ecx,%eax
  801bc4:	19 d7                	sbb    %edx,%edi
  801bc6:	89 e9                	mov    %ebp,%ecx
  801bc8:	89 fa                	mov    %edi,%edx
  801bca:	d3 e8                	shr    %cl,%eax
  801bcc:	89 f1                	mov    %esi,%ecx
  801bce:	d3 e2                	shl    %cl,%edx
  801bd0:	89 e9                	mov    %ebp,%ecx
  801bd2:	d3 ef                	shr    %cl,%edi
  801bd4:	09 d0                	or     %edx,%eax
  801bd6:	89 fa                	mov    %edi,%edx
  801bd8:	83 c4 14             	add    $0x14,%esp
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    
  801bdf:	90                   	nop
  801be0:	39 d7                	cmp    %edx,%edi
  801be2:	75 da                	jne    801bbe <__umoddi3+0x10e>
  801be4:	8b 14 24             	mov    (%esp),%edx
  801be7:	89 c1                	mov    %eax,%ecx
  801be9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801bf1:	eb cb                	jmp    801bbe <__umoddi3+0x10e>
  801bf3:	90                   	nop
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801bfc:	0f 82 0f ff ff ff    	jb     801b11 <__umoddi3+0x61>
  801c02:	e9 1a ff ff ff       	jmp    801b21 <__umoddi3+0x71>
