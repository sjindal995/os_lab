
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
  80004f:	e8 34 17 00 00       	call   801788 <ipc_recv>
  800054:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800057:	a1 04 30 80 00       	mov    0x803004,%eax
  80005c:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800062:	89 54 24 08          	mov    %edx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 40 1c 80 00 	movl   $0x801c40,(%esp)
  800071:	e8 69 02 00 00       	call   8002df <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 59 15 00 00       	call   8015d4 <fork>
  80007b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80007e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800082:	79 23                	jns    8000a7 <primeproc+0x74>
		panic("fork: %e", id);
  800084:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800087:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80008b:	c7 44 24 08 4c 1c 80 	movl   $0x801c4c,0x8(%esp)
  800092:	00 
  800093:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80009a:	00 
  80009b:	c7 04 24 55 1c 80 00 	movl   $0x801c55,(%esp)
  8000a2:	e8 1d 01 00 00       	call   8001c4 <_panic>
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
  8000c5:	e8 be 16 00 00       	call   801788 <ipc_recv>
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
  8000f7:	e8 2a 17 00 00       	call   801826 <ipc_send>
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
  800106:	e8 c9 14 00 00       	call   8015d4 <fork>
  80010b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80010e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800112:	79 23                	jns    800137 <umain+0x37>
		panic("fork: %e", id);
  800114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011b:	c7 44 24 08 4c 1c 80 	movl   $0x801c4c,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 55 1c 80 00 	movl   $0x801c55,(%esp)
  800132:	e8 8d 00 00 00       	call   8001c4 <_panic>
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
  800166:	e8 bb 16 00 00       	call   801826 <ipc_send>
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
  800177:	e8 98 0e 00 00       	call   801014 <sys_getenvid>
  80017c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800181:	c1 e0 02             	shl    $0x2,%eax
  800184:	89 c2                	mov    %eax,%edx
  800186:	c1 e2 05             	shl    $0x5,%edx
  800189:	29 c2                	sub    %eax,%edx
  80018b:	89 d0                	mov    %edx,%eax
  80018d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800192:	a3 04 30 80 00       	mov    %eax,0x803004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 57 ff ff ff       	call   800100 <umain>

	// exit gracefully
	exit();
  8001a9:	e8 02 00 00 00       	call   8001b0 <exit>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001bd:	e8 0f 0e 00 00       	call   800fd1 <sys_env_destroy>
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	53                   	push   %ebx
  8001c8:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8001cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8001ce:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d1:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001d7:	e8 38 0e 00 00       	call   801014 <sys_getenvid>
  8001dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	c7 04 24 70 1c 80 00 	movl   $0x801c70,(%esp)
  8001f9:	e8 e1 00 00 00       	call   8002df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	8b 45 10             	mov    0x10(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 6b 00 00 00       	call   80027b <vcprintf>
	cprintf("\n");
  800210:	c7 04 24 93 1c 80 00 	movl   $0x801c93,(%esp)
  800217:	e8 c3 00 00 00       	call   8002df <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021c:	cc                   	int3   
  80021d:	eb fd                	jmp    80021c <_panic+0x58>

0080021f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800225:	8b 45 0c             	mov    0xc(%ebp),%eax
  800228:	8b 00                	mov    (%eax),%eax
  80022a:	8d 48 01             	lea    0x1(%eax),%ecx
  80022d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800230:	89 0a                	mov    %ecx,(%edx)
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 d1                	mov    %edx,%ecx
  800237:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023a:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80023e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800241:	8b 00                	mov    (%eax),%eax
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 20                	jne    80026a <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80024a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024d:	8b 00                	mov    (%eax),%eax
  80024f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800252:	83 c2 08             	add    $0x8,%edx
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	89 14 24             	mov    %edx,(%esp)
  80025c:	e8 ea 0c 00 00       	call   800f4b <sys_cputs>
		b->idx = 0;
  800261:	8b 45 0c             	mov    0xc(%ebp),%eax
  800264:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026d:	8b 40 04             	mov    0x4(%eax),%eax
  800270:	8d 50 01             	lea    0x1(%eax),%edx
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
  800276:	89 50 04             	mov    %edx,0x4(%eax)
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800284:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80028b:	00 00 00 
	b.cnt = 0;
  80028e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800295:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b0:	c7 04 24 1f 02 80 00 	movl   $0x80021f,(%esp)
  8002b7:	e8 bd 01 00 00       	call   800479 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002bc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002cc:	83 c0 08             	add    $0x8,%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	e8 74 0c 00 00       	call   800f4b <sys_cputs>

	return b.cnt;
  8002d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002e5:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	e8 7e ff ff ff       	call   80027b <vcprintf>
  8002fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800300:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	53                   	push   %ebx
  800309:	83 ec 34             	sub    $0x34,%esp
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800312:	8b 45 14             	mov    0x14(%ebp),%eax
  800315:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800318:	8b 45 18             	mov    0x18(%ebp),%eax
  80031b:	ba 00 00 00 00       	mov    $0x0,%edx
  800320:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800323:	77 72                	ja     800397 <printnum+0x92>
  800325:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800328:	72 05                	jb     80032f <printnum+0x2a>
  80032a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80032d:	77 68                	ja     800397 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80032f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800332:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800335:	8b 45 18             	mov    0x18(%ebp),%eax
  800338:	ba 00 00 00 00       	mov    $0x0,%edx
  80033d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800341:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800348:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800352:	e8 59 16 00 00       	call   8019b0 <__udivdi3>
  800357:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80035a:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80035e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800362:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800365:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800369:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800371:	8b 45 0c             	mov    0xc(%ebp),%eax
  800374:	89 44 24 04          	mov    %eax,0x4(%esp)
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	e8 82 ff ff ff       	call   800305 <printnum>
  800383:	eb 1c                	jmp    8003a1 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800385:	8b 45 0c             	mov    0xc(%ebp),%eax
  800388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038c:	8b 45 20             	mov    0x20(%ebp),%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800397:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80039b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80039f:	7f e4                	jg     800385 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a1:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003be:	e8 1d 17 00 00       	call   801ae0 <__umoddi3>
  8003c3:	05 68 1d 80 00       	add    $0x801d68,%eax
  8003c8:	0f b6 00             	movzbl (%eax),%eax
  8003cb:	0f be c0             	movsbl %al,%eax
  8003ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d5:	89 04 24             	mov    %eax,(%esp)
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	ff d0                	call   *%eax
}
  8003dd:	83 c4 34             	add    $0x34,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ea:	7e 14                	jle    800400 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	8d 48 08             	lea    0x8(%eax),%ecx
  8003f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f7:	89 0a                	mov    %ecx,(%edx)
  8003f9:	8b 50 04             	mov    0x4(%eax),%edx
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	eb 30                	jmp    800430 <getuint+0x4d>
	else if (lflag)
  800400:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800404:	74 16                	je     80041c <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	8d 48 04             	lea    0x4(%eax),%ecx
  80040e:	8b 55 08             	mov    0x8(%ebp),%edx
  800411:	89 0a                	mov    %ecx,(%edx)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
  80041a:	eb 14                	jmp    800430 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80041c:	8b 45 08             	mov    0x8(%ebp),%eax
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	8d 48 04             	lea    0x4(%eax),%ecx
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	89 0a                	mov    %ecx,(%edx)
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800435:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800439:	7e 14                	jle    80044f <getint+0x1d>
		return va_arg(*ap, long long);
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	8d 48 08             	lea    0x8(%eax),%ecx
  800443:	8b 55 08             	mov    0x8(%ebp),%edx
  800446:	89 0a                	mov    %ecx,(%edx)
  800448:	8b 50 04             	mov    0x4(%eax),%edx
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	eb 28                	jmp    800477 <getint+0x45>
	else if (lflag)
  80044f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800453:	74 12                	je     800467 <getint+0x35>
		return va_arg(*ap, long);
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	8d 48 04             	lea    0x4(%eax),%ecx
  80045d:	8b 55 08             	mov    0x8(%ebp),%edx
  800460:	89 0a                	mov    %ecx,(%edx)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	eb 10                	jmp    800477 <getint+0x45>
	else
		return va_arg(*ap, int);
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	8d 48 04             	lea    0x4(%eax),%ecx
  80046f:	8b 55 08             	mov    0x8(%ebp),%edx
  800472:	89 0a                	mov    %ecx,(%edx)
  800474:	8b 00                	mov    (%eax),%eax
  800476:	99                   	cltd   
}
  800477:	5d                   	pop    %ebp
  800478:	c3                   	ret    

00800479 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	56                   	push   %esi
  80047d:	53                   	push   %ebx
  80047e:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800481:	eb 18                	jmp    80049b <vprintfmt+0x22>
			if (ch == '\0')
  800483:	85 db                	test   %ebx,%ebx
  800485:	75 05                	jne    80048c <vprintfmt+0x13>
				return;
  800487:	e9 cc 03 00 00       	jmp    800858 <vprintfmt+0x3df>
			putch(ch, putdat);
  80048c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800493:	89 1c 24             	mov    %ebx,(%esp)
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80049b:	8b 45 10             	mov    0x10(%ebp),%eax
  80049e:	8d 50 01             	lea    0x1(%eax),%edx
  8004a1:	89 55 10             	mov    %edx,0x10(%ebp)
  8004a4:	0f b6 00             	movzbl (%eax),%eax
  8004a7:	0f b6 d8             	movzbl %al,%ebx
  8004aa:	83 fb 25             	cmp    $0x25,%ebx
  8004ad:	75 d4                	jne    800483 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004af:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004b3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004c1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004c8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d2:	8d 50 01             	lea    0x1(%eax),%edx
  8004d5:	89 55 10             	mov    %edx,0x10(%ebp)
  8004d8:	0f b6 00             	movzbl (%eax),%eax
  8004db:	0f b6 d8             	movzbl %al,%ebx
  8004de:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004e1:	83 f8 55             	cmp    $0x55,%eax
  8004e4:	0f 87 3d 03 00 00    	ja     800827 <vprintfmt+0x3ae>
  8004ea:	8b 04 85 8c 1d 80 00 	mov    0x801d8c(,%eax,4),%eax
  8004f1:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004f3:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004f7:	eb d6                	jmp    8004cf <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f9:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004fd:	eb d0                	jmp    8004cf <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ff:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800506:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800509:	89 d0                	mov    %edx,%eax
  80050b:	c1 e0 02             	shl    $0x2,%eax
  80050e:	01 d0                	add    %edx,%eax
  800510:	01 c0                	add    %eax,%eax
  800512:	01 d8                	add    %ebx,%eax
  800514:	83 e8 30             	sub    $0x30,%eax
  800517:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80051a:	8b 45 10             	mov    0x10(%ebp),%eax
  80051d:	0f b6 00             	movzbl (%eax),%eax
  800520:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800523:	83 fb 2f             	cmp    $0x2f,%ebx
  800526:	7e 0b                	jle    800533 <vprintfmt+0xba>
  800528:	83 fb 39             	cmp    $0x39,%ebx
  80052b:	7f 06                	jg     800533 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800531:	eb d3                	jmp    800506 <vprintfmt+0x8d>
			goto process_precision;
  800533:	eb 33                	jmp    800568 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800543:	eb 23                	jmp    800568 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800545:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800549:	79 0c                	jns    800557 <vprintfmt+0xde>
				width = 0;
  80054b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800552:	e9 78 ff ff ff       	jmp    8004cf <vprintfmt+0x56>
  800557:	e9 73 ff ff ff       	jmp    8004cf <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80055c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800563:	e9 67 ff ff ff       	jmp    8004cf <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800568:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056c:	79 12                	jns    800580 <vprintfmt+0x107>
				width = precision, precision = -1;
  80056e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80057b:	e9 4f ff ff ff       	jmp    8004cf <vprintfmt+0x56>
  800580:	e9 4a ff ff ff       	jmp    8004cf <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800585:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800589:	e9 41 ff ff ff       	jmp    8004cf <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a6:	ff d0                	call   *%eax
			break;
  8005a8:	e9 a5 02 00 00       	jmp    800852 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b6:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005b8:	85 db                	test   %ebx,%ebx
  8005ba:	79 02                	jns    8005be <vprintfmt+0x145>
				err = -err;
  8005bc:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005be:	83 fb 09             	cmp    $0x9,%ebx
  8005c1:	7f 0b                	jg     8005ce <vprintfmt+0x155>
  8005c3:	8b 34 9d 40 1d 80 00 	mov    0x801d40(,%ebx,4),%esi
  8005ca:	85 f6                	test   %esi,%esi
  8005cc:	75 23                	jne    8005f1 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005ce:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005d2:	c7 44 24 08 79 1d 80 	movl   $0x801d79,0x8(%esp)
  8005d9:	00 
  8005da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	e8 73 02 00 00       	call   80085f <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005ec:	e9 61 02 00 00       	jmp    800852 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005f5:	c7 44 24 08 82 1d 80 	movl   $0x801d82,0x8(%esp)
  8005fc:	00 
  8005fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	e8 50 02 00 00       	call   80085f <printfmt>
			break;
  80060f:	e9 3e 02 00 00       	jmp    800852 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	85 f6                	test   %esi,%esi
  800621:	75 05                	jne    800628 <vprintfmt+0x1af>
				p = "(null)";
  800623:	be 85 1d 80 00       	mov    $0x801d85,%esi
			if (width > 0 && padc != '-')
  800628:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062c:	7e 37                	jle    800665 <vprintfmt+0x1ec>
  80062e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800632:	74 31                	je     800665 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800634:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063b:	89 34 24             	mov    %esi,(%esp)
  80063e:	e8 39 03 00 00       	call   80097c <strnlen>
  800643:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800646:	eb 17                	jmp    80065f <vprintfmt+0x1e6>
					putch(padc, putdat);
  800648:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80064c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80064f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	8b 45 08             	mov    0x8(%ebp),%eax
  800659:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80065b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80065f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800663:	7f e3                	jg     800648 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	eb 38                	jmp    80069f <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800667:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066b:	74 1f                	je     80068c <vprintfmt+0x213>
  80066d:	83 fb 1f             	cmp    $0x1f,%ebx
  800670:	7e 05                	jle    800677 <vprintfmt+0x1fe>
  800672:	83 fb 7e             	cmp    $0x7e,%ebx
  800675:	7e 15                	jle    80068c <vprintfmt+0x213>
					putch('?', putdat);
  800677:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	ff d0                	call   *%eax
  80068a:	eb 0f                	jmp    80069b <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800693:	89 1c 24             	mov    %ebx,(%esp)
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	8d 70 01             	lea    0x1(%eax),%esi
  8006a4:	0f b6 00             	movzbl (%eax),%eax
  8006a7:	0f be d8             	movsbl %al,%ebx
  8006aa:	85 db                	test   %ebx,%ebx
  8006ac:	74 10                	je     8006be <vprintfmt+0x245>
  8006ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b2:	78 b3                	js     800667 <vprintfmt+0x1ee>
  8006b4:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8006b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bc:	79 a9                	jns    800667 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006be:	eb 17                	jmp    8006d7 <vprintfmt+0x25e>
				putch(' ', putdat);
  8006c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006db:	7f e3                	jg     8006c0 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8006dd:	e9 70 01 00 00       	jmp    800852 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	e8 3e fd ff ff       	call   800432 <getint>
  8006f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	79 26                	jns    80072a <vprintfmt+0x2b1>
				putch('-', putdat);
  800704:	8b 45 0c             	mov    0xc(%ebp),%eax
  800707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	ff d0                	call   *%eax
				num = -(long long) num;
  800717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071d:	f7 d8                	neg    %eax
  80071f:	83 d2 00             	adc    $0x0,%edx
  800722:	f7 da                	neg    %edx
  800724:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800727:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80072a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800731:	e9 a8 00 00 00       	jmp    8007de <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800736:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073d:	8d 45 14             	lea    0x14(%ebp),%eax
  800740:	89 04 24             	mov    %eax,(%esp)
  800743:	e8 9b fc ff ff       	call   8003e3 <getuint>
  800748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80074b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80074e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800755:	e9 84 00 00 00       	jmp    8007de <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80075d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800761:	8d 45 14             	lea    0x14(%ebp),%eax
  800764:	89 04 24             	mov    %eax,(%esp)
  800767:	e8 77 fc ff ff       	call   8003e3 <getuint>
  80076c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800772:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800779:	eb 63                	jmp    8007de <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800782:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	ff d0                	call   *%eax
			putch('x', putdat);
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 50 04             	lea    0x4(%eax),%edx
  8007a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007aa:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007bd:	eb 1f                	jmp    8007de <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	89 04 24             	mov    %eax,(%esp)
  8007cc:	e8 12 fc ff ff       	call   8003e3 <getuint>
  8007d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007d4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007d7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007de:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e5:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ec:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800802:	8b 45 0c             	mov    0xc(%ebp),%eax
  800805:	89 44 24 04          	mov    %eax,0x4(%esp)
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	89 04 24             	mov    %eax,(%esp)
  80080f:	e8 f1 fa ff ff       	call   800305 <printnum>
			break;
  800814:	eb 3c                	jmp    800852 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	89 1c 24             	mov    %ebx,(%esp)
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	ff d0                	call   *%eax
			break;
  800825:	eb 2b                	jmp    800852 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80083e:	eb 04                	jmp    800844 <vprintfmt+0x3cb>
  800840:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800844:	8b 45 10             	mov    0x10(%ebp),%eax
  800847:	83 e8 01             	sub    $0x1,%eax
  80084a:	0f b6 00             	movzbl (%eax),%eax
  80084d:	3c 25                	cmp    $0x25,%al
  80084f:	75 ef                	jne    800840 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800851:	90                   	nop
		}
	}
  800852:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800853:	e9 43 fc ff ff       	jmp    80049b <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800858:	83 c4 40             	add    $0x40,%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
  800875:	89 44 24 08          	mov    %eax,0x8(%esp)
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 ee fb ff ff       	call   800479 <vprintfmt>
	va_end(ap);
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800890:	8b 45 0c             	mov    0xc(%ebp),%eax
  800893:	8b 40 08             	mov    0x8(%eax),%eax
  800896:	8d 50 01             	lea    0x1(%eax),%edx
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089c:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	8b 10                	mov    (%eax),%edx
  8008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a7:	8b 40 04             	mov    0x4(%eax),%eax
  8008aa:	39 c2                	cmp    %eax,%edx
  8008ac:	73 12                	jae    8008c0 <sprintputch+0x33>
		*b->buf++ = ch;
  8008ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b1:	8b 00                	mov    (%eax),%eax
  8008b3:	8d 48 01             	lea    0x1(%eax),%ecx
  8008b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b9:	89 0a                	mov    %ecx,(%edx)
  8008bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008be:	88 10                	mov    %dl,(%eax)
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	01 d0                	add    %edx,%eax
  8008d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008e7:	74 06                	je     8008ef <vsnprintf+0x2d>
  8008e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ed:	7f 07                	jg     8008f6 <vsnprintf+0x34>
		return -E_INVAL;
  8008ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f4:	eb 2a                	jmp    800920 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800900:	89 44 24 08          	mov    %eax,0x8(%esp)
  800904:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090b:	c7 04 24 8d 08 80 00 	movl   $0x80088d,(%esp)
  800912:	e8 62 fb ff ff       	call   800479 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800917:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
  80092b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80092e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800931:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800935:	8b 45 10             	mov    0x10(%ebp),%eax
  800938:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 74 ff ff ff       	call   8008c2 <vsnprintf>
  80094e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800951:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80095c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800963:	eb 08                	jmp    80096d <strlen+0x17>
		n++;
  800965:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800969:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	0f b6 00             	movzbl (%eax),%eax
  800973:	84 c0                	test   %al,%al
  800975:	75 ee                	jne    800965 <strlen+0xf>
		n++;
	return n;
  800977:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800982:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800989:	eb 0c                	jmp    800997 <strnlen+0x1b>
		n++;
  80098b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800993:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800997:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80099b:	74 0a                	je     8009a7 <strnlen+0x2b>
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 00             	movzbl (%eax),%eax
  8009a3:	84 c0                	test   %al,%al
  8009a5:	75 e4                	jne    80098b <strnlen+0xf>
		n++;
	return n;
  8009a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009b8:	90                   	nop
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8d 50 01             	lea    0x1(%eax),%edx
  8009bf:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009c8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	88 10                	mov    %dl,(%eax)
  8009d0:	0f b6 00             	movzbl (%eax),%eax
  8009d3:	84 c0                	test   %al,%al
  8009d5:	75 e2                	jne    8009b9 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	89 04 24             	mov    %eax,(%esp)
  8009e8:	e8 69 ff ff ff       	call   800956 <strlen>
  8009ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	01 c2                	add    %eax,%edx
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	89 14 24             	mov    %edx,(%esp)
  800a02:	e8 a5 ff ff ff       	call   8009ac <strcpy>
	return dst;
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a1f:	eb 23                	jmp    800a44 <strncpy+0x38>
		*dst++ = *src;
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	8d 50 01             	lea    0x1(%eax),%edx
  800a27:	89 55 08             	mov    %edx,0x8(%ebp)
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	0f b6 12             	movzbl (%edx),%edx
  800a30:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	84 c0                	test   %al,%al
  800a3a:	74 04                	je     800a40 <strncpy+0x34>
			src++;
  800a3c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a40:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a44:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a47:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a4a:	72 d5                	jb     800a21 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    

00800a51 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a61:	74 33                	je     800a96 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a63:	eb 17                	jmp    800a7c <strlcpy+0x2b>
			*dst++ = *src++;
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8d 50 01             	lea    0x1(%eax),%edx
  800a6b:	89 55 08             	mov    %edx,0x8(%ebp)
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a74:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a77:	0f b6 12             	movzbl (%edx),%edx
  800a7a:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a84:	74 0a                	je     800a90 <strlcpy+0x3f>
  800a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a89:	0f b6 00             	movzbl (%eax),%eax
  800a8c:	84 c0                	test   %al,%al
  800a8e:	75 d5                	jne    800a65 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a9c:	29 c2                	sub    %eax,%edx
  800a9e:	89 d0                	mov    %edx,%eax
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800aa5:	eb 08                	jmp    800aaf <strcmp+0xd>
		p++, q++;
  800aa7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aab:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	0f b6 00             	movzbl (%eax),%eax
  800ab5:	84 c0                	test   %al,%al
  800ab7:	74 10                	je     800ac9 <strcmp+0x27>
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	0f b6 10             	movzbl (%eax),%edx
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	38 c2                	cmp    %al,%dl
  800ac7:	74 de                	je     800aa7 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	0f b6 00             	movzbl (%eax),%eax
  800acf:	0f b6 d0             	movzbl %al,%edx
  800ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad5:	0f b6 00             	movzbl (%eax),%eax
  800ad8:	0f b6 c0             	movzbl %al,%eax
  800adb:	29 c2                	sub    %eax,%edx
  800add:	89 d0                	mov    %edx,%eax
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800ae4:	eb 0c                	jmp    800af2 <strncmp+0x11>
		n--, p++, q++;
  800ae6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800af6:	74 1a                	je     800b12 <strncmp+0x31>
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	0f b6 00             	movzbl (%eax),%eax
  800afe:	84 c0                	test   %al,%al
  800b00:	74 10                	je     800b12 <strncmp+0x31>
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	0f b6 10             	movzbl (%eax),%edx
  800b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0b:	0f b6 00             	movzbl (%eax),%eax
  800b0e:	38 c2                	cmp    %al,%dl
  800b10:	74 d4                	je     800ae6 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b16:	75 07                	jne    800b1f <strncmp+0x3e>
		return 0;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	eb 16                	jmp    800b35 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	0f b6 00             	movzbl (%eax),%eax
  800b25:	0f b6 d0             	movzbl %al,%edx
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	0f b6 00             	movzbl (%eax),%eax
  800b2e:	0f b6 c0             	movzbl %al,%eax
  800b31:	29 c2                	sub    %eax,%edx
  800b33:	89 d0                	mov    %edx,%eax
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 04             	sub    $0x4,%esp
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b43:	eb 14                	jmp    800b59 <strchr+0x22>
		if (*s == c)
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	0f b6 00             	movzbl (%eax),%eax
  800b4b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b4e:	75 05                	jne    800b55 <strchr+0x1e>
			return (char *) s;
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	eb 13                	jmp    800b68 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b55:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	0f b6 00             	movzbl (%eax),%eax
  800b5f:	84 c0                	test   %al,%al
  800b61:	75 e2                	jne    800b45 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 04             	sub    $0x4,%esp
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b76:	eb 11                	jmp    800b89 <strfind+0x1f>
		if (*s == c)
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7b:	0f b6 00             	movzbl (%eax),%eax
  800b7e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b81:	75 02                	jne    800b85 <strfind+0x1b>
			break;
  800b83:	eb 0e                	jmp    800b93 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b85:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 00             	movzbl (%eax),%eax
  800b8f:	84 c0                	test   %al,%al
  800b91:	75 e5                	jne    800b78 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ba0:	75 05                	jne    800ba7 <memset+0xf>
		return v;
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	eb 5c                	jmp    800c03 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	83 e0 03             	and    $0x3,%eax
  800bad:	85 c0                	test   %eax,%eax
  800baf:	75 41                	jne    800bf2 <memset+0x5a>
  800bb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb4:	83 e0 03             	and    $0x3,%eax
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	75 37                	jne    800bf2 <memset+0x5a>
		c &= 0xFF;
  800bbb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	c1 e0 18             	shl    $0x18,%eax
  800bc8:	89 c2                	mov    %eax,%edx
  800bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcd:	c1 e0 10             	shl    $0x10,%eax
  800bd0:	09 c2                	or     %eax,%edx
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	c1 e0 08             	shl    $0x8,%eax
  800bd8:	09 d0                	or     %edx,%eax
  800bda:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800be0:	c1 e8 02             	shr    $0x2,%eax
  800be3:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	fc                   	cld    
  800bee:	f3 ab                	rep stos %eax,%es:(%edi)
  800bf0:	eb 0e                	jmp    800c00 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bfb:	89 d7                	mov    %edx,%edi
  800bfd:	fc                   	cld    
  800bfe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c12:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c21:	73 6d                	jae    800c90 <memmove+0x8a>
  800c23:	8b 45 10             	mov    0x10(%ebp),%eax
  800c26:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c29:	01 d0                	add    %edx,%eax
  800c2b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c2e:	76 60                	jbe    800c90 <memmove+0x8a>
		s += n;
  800c30:	8b 45 10             	mov    0x10(%ebp),%eax
  800c33:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c36:	8b 45 10             	mov    0x10(%ebp),%eax
  800c39:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3f:	83 e0 03             	and    $0x3,%eax
  800c42:	85 c0                	test   %eax,%eax
  800c44:	75 2f                	jne    800c75 <memmove+0x6f>
  800c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c49:	83 e0 03             	and    $0x3,%eax
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	75 25                	jne    800c75 <memmove+0x6f>
  800c50:	8b 45 10             	mov    0x10(%ebp),%eax
  800c53:	83 e0 03             	and    $0x3,%eax
  800c56:	85 c0                	test   %eax,%eax
  800c58:	75 1b                	jne    800c75 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5d:	83 e8 04             	sub    $0x4,%eax
  800c60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c63:	83 ea 04             	sub    $0x4,%edx
  800c66:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c69:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c6c:	89 c7                	mov    %eax,%edi
  800c6e:	89 d6                	mov    %edx,%esi
  800c70:	fd                   	std    
  800c71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c73:	eb 18                	jmp    800c8d <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c75:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c78:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c7e:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c81:	8b 45 10             	mov    0x10(%ebp),%eax
  800c84:	89 d7                	mov    %edx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	89 c1                	mov    %eax,%ecx
  800c8a:	fd                   	std    
  800c8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c8d:	fc                   	cld    
  800c8e:	eb 45                	jmp    800cd5 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c93:	83 e0 03             	and    $0x3,%eax
  800c96:	85 c0                	test   %eax,%eax
  800c98:	75 2b                	jne    800cc5 <memmove+0xbf>
  800c9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c9d:	83 e0 03             	and    $0x3,%eax
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	75 21                	jne    800cc5 <memmove+0xbf>
  800ca4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca7:	83 e0 03             	and    $0x3,%eax
  800caa:	85 c0                	test   %eax,%eax
  800cac:	75 17                	jne    800cc5 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb1:	c1 e8 02             	shr    $0x2,%eax
  800cb4:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cb9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	89 d6                	mov    %edx,%esi
  800cc0:	fc                   	cld    
  800cc1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cc3:	eb 10                	jmp    800cd5 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ccb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cce:	89 c7                	mov    %eax,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	fc                   	cld    
  800cd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ce6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	89 04 24             	mov    %eax,(%esp)
  800cfa:	e8 07 ff ff ff       	call   800c06 <memmove>
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d10:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d13:	eb 30                	jmp    800d45 <memcmp+0x44>
		if (*s1 != *s2)
  800d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d18:	0f b6 10             	movzbl (%eax),%edx
  800d1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d1e:	0f b6 00             	movzbl (%eax),%eax
  800d21:	38 c2                	cmp    %al,%dl
  800d23:	74 18                	je     800d3d <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d28:	0f b6 00             	movzbl (%eax),%eax
  800d2b:	0f b6 d0             	movzbl %al,%edx
  800d2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d31:	0f b6 00             	movzbl (%eax),%eax
  800d34:	0f b6 c0             	movzbl %al,%eax
  800d37:	29 c2                	sub    %eax,%edx
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	eb 1a                	jmp    800d57 <memcmp+0x56>
		s1++, s2++;
  800d3d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d41:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d45:	8b 45 10             	mov    0x10(%ebp),%eax
  800d48:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d4b:	89 55 10             	mov    %edx,0x10(%ebp)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	75 c3                	jne    800d15 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	01 d0                	add    %edx,%eax
  800d67:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d6a:	eb 13                	jmp    800d7f <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	0f b6 10             	movzbl (%eax),%edx
  800d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d75:	38 c2                	cmp    %al,%dl
  800d77:	75 02                	jne    800d7b <memfind+0x22>
			break;
  800d79:	eb 0c                	jmp    800d87 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d7b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d85:	72 e5                	jb     800d6c <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d92:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d99:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da0:	eb 04                	jmp    800da6 <strtol+0x1a>
		s++;
  800da2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	0f b6 00             	movzbl (%eax),%eax
  800dac:	3c 20                	cmp    $0x20,%al
  800dae:	74 f2                	je     800da2 <strtol+0x16>
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	0f b6 00             	movzbl (%eax),%eax
  800db6:	3c 09                	cmp    $0x9,%al
  800db8:	74 e8                	je     800da2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	0f b6 00             	movzbl (%eax),%eax
  800dc0:	3c 2b                	cmp    $0x2b,%al
  800dc2:	75 06                	jne    800dca <strtol+0x3e>
		s++;
  800dc4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc8:	eb 15                	jmp    800ddf <strtol+0x53>
	else if (*s == '-')
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	0f b6 00             	movzbl (%eax),%eax
  800dd0:	3c 2d                	cmp    $0x2d,%al
  800dd2:	75 0b                	jne    800ddf <strtol+0x53>
		s++, neg = 1;
  800dd4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ddf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de3:	74 06                	je     800deb <strtol+0x5f>
  800de5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800de9:	75 24                	jne    800e0f <strtol+0x83>
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	0f b6 00             	movzbl (%eax),%eax
  800df1:	3c 30                	cmp    $0x30,%al
  800df3:	75 1a                	jne    800e0f <strtol+0x83>
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	83 c0 01             	add    $0x1,%eax
  800dfb:	0f b6 00             	movzbl (%eax),%eax
  800dfe:	3c 78                	cmp    $0x78,%al
  800e00:	75 0d                	jne    800e0f <strtol+0x83>
		s += 2, base = 16;
  800e02:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e06:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e0d:	eb 2a                	jmp    800e39 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e13:	75 17                	jne    800e2c <strtol+0xa0>
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	3c 30                	cmp    $0x30,%al
  800e1d:	75 0d                	jne    800e2c <strtol+0xa0>
		s++, base = 8;
  800e1f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e23:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e2a:	eb 0d                	jmp    800e39 <strtol+0xad>
	else if (base == 0)
  800e2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e30:	75 07                	jne    800e39 <strtol+0xad>
		base = 10;
  800e32:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	0f b6 00             	movzbl (%eax),%eax
  800e3f:	3c 2f                	cmp    $0x2f,%al
  800e41:	7e 1b                	jle    800e5e <strtol+0xd2>
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	0f b6 00             	movzbl (%eax),%eax
  800e49:	3c 39                	cmp    $0x39,%al
  800e4b:	7f 11                	jg     800e5e <strtol+0xd2>
			dig = *s - '0';
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e50:	0f b6 00             	movzbl (%eax),%eax
  800e53:	0f be c0             	movsbl %al,%eax
  800e56:	83 e8 30             	sub    $0x30,%eax
  800e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e5c:	eb 48                	jmp    800ea6 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	0f b6 00             	movzbl (%eax),%eax
  800e64:	3c 60                	cmp    $0x60,%al
  800e66:	7e 1b                	jle    800e83 <strtol+0xf7>
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	0f b6 00             	movzbl (%eax),%eax
  800e6e:	3c 7a                	cmp    $0x7a,%al
  800e70:	7f 11                	jg     800e83 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	0f b6 00             	movzbl (%eax),%eax
  800e78:	0f be c0             	movsbl %al,%eax
  800e7b:	83 e8 57             	sub    $0x57,%eax
  800e7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e81:	eb 23                	jmp    800ea6 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
  800e86:	0f b6 00             	movzbl (%eax),%eax
  800e89:	3c 40                	cmp    $0x40,%al
  800e8b:	7e 3d                	jle    800eca <strtol+0x13e>
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	0f b6 00             	movzbl (%eax),%eax
  800e93:	3c 5a                	cmp    $0x5a,%al
  800e95:	7f 33                	jg     800eca <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	0f b6 00             	movzbl (%eax),%eax
  800e9d:	0f be c0             	movsbl %al,%eax
  800ea0:	83 e8 37             	sub    $0x37,%eax
  800ea3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800eac:	7c 02                	jl     800eb0 <strtol+0x124>
			break;
  800eae:	eb 1a                	jmp    800eca <strtol+0x13e>
		s++, val = (val * base) + dig;
  800eb0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ebb:	89 c2                	mov    %eax,%edx
  800ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec0:	01 d0                	add    %edx,%eax
  800ec2:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ec5:	e9 6f ff ff ff       	jmp    800e39 <strtol+0xad>

	if (endptr)
  800eca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ece:	74 08                	je     800ed8 <strtol+0x14c>
		*endptr = (char *) s;
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ed8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800edc:	74 07                	je     800ee5 <strtol+0x159>
  800ede:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ee1:	f7 d8                	neg    %eax
  800ee3:	eb 03                	jmp    800ee8 <strtol+0x15c>
  800ee5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	8b 55 10             	mov    0x10(%ebp),%edx
  800ef9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800efc:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800eff:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f02:	8b 75 20             	mov    0x20(%ebp),%esi
  800f05:	cd 30                	int    $0x30
  800f07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f0e:	74 30                	je     800f40 <syscall+0x56>
  800f10:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f14:	7e 2a                	jle    800f40 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f24:	c7 44 24 08 e4 1e 80 	movl   $0x801ee4,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 01 1f 80 00 	movl   $0x801f01,(%esp)
  800f3b:	e8 84 f2 ff ff       	call   8001c4 <_panic>

	return ret;
  800f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f43:	83 c4 3c             	add    $0x3c,%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
  800f54:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f63:	00 
  800f64:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f6b:	00 
  800f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f86:	e8 5f ff ff ff       	call   800eea <syscall>
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <sys_cgetc>:

int
sys_cgetc(void)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f93:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fa2:	00 
  800fa3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800faa:	00 
  800fab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb2:	00 
  800fb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fca:	e8 1b ff ff ff       	call   800eea <syscall>
}
  800fcf:	c9                   	leave  
  800fd0:	c3                   	ret    

00800fd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fda:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe9:	00 
  800fea:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff9:	00 
  800ffa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801005:	00 
  801006:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80100d:	e8 d8 fe ff ff       	call   800eea <syscall>
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80101a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801021:	00 
  801022:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801029:	00 
  80102a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801031:	00 
  801032:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801039:	00 
  80103a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801041:	00 
  801042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801049:	00 
  80104a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801051:	e8 94 fe ff ff       	call   800eea <syscall>
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <sys_yield>:

void
sys_yield(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80105e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801065:	00 
  801066:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80106d:	00 
  80106e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801075:	00 
  801076:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80107d:	00 
  80107e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801085:	00 
  801086:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80108d:	00 
  80108e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801095:	e8 50 fe ff ff       	call   800eea <syscall>
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ba:	00 
  8010bb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010d6:	e8 0f fe ff ff       	call   800eea <syscall>
}
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010e5:	8b 75 18             	mov    0x18(%ebp),%esi
  8010e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010f8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801100:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801104:	89 44 24 08          	mov    %eax,0x8(%esp)
  801108:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80110f:	00 
  801110:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801117:	e8 ce fd ff ff       	call   800eea <syscall>
}
  80111c:	83 c4 20             	add    $0x20,%esp
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801129:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801136:	00 
  801137:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80113e:	00 
  80113f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801146:	00 
  801147:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801156:	00 
  801157:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80115e:	e8 87 fd ff ff       	call   800eea <syscall>
}
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80116b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801178:	00 
  801179:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801180:	00 
  801181:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801188:	00 
  801189:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80118d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801191:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011a0:	e8 45 fd ff ff       	call   800eea <syscall>
}
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011ba:	00 
  8011bb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011ca:	00 
  8011cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011da:	00 
  8011db:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011e2:	e8 03 fd ff ff       	call   800eea <syscall>
}
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011ef:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011f2:	8b 55 10             	mov    0x10(%ebp),%edx
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011ff:	00 
  801200:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801204:	89 54 24 10          	mov    %edx,0x10(%esp)
  801208:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80120f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801213:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801222:	e8 c3 fc ff ff       	call   800eea <syscall>
}
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80122f:	8b 45 08             	mov    0x8(%ebp),%eax
  801232:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801239:	00 
  80123a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801241:	00 
  801242:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801249:	00 
  80124a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801251:	00 
  801252:	89 44 24 08          	mov    %eax,0x8(%esp)
  801256:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80125d:	00 
  80125e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801265:	e8 80 fc ff ff       	call   800eea <syscall>
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <sys_exec>:

void sys_exec(char* buf){
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80127c:	00 
  80127d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801284:	00 
  801285:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80128c:	00 
  80128d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801294:	00 
  801295:	89 44 24 08          	mov    %eax,0x8(%esp)
  801299:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012a0:	00 
  8012a1:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8012a8:	e8 3d fc ff ff       	call   800eea <syscall>
}
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <sys_wait>:

void sys_wait(){
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  8012b5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012c4:	00 
  8012c5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012d4:	00 
  8012d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012dc:	00 
  8012dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012e4:	00 
  8012e5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8012ec:	e8 f9 fb ff ff       	call   800eea <syscall>
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fc:	8b 00                	mov    (%eax),%eax
  8012fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801301:	8b 45 08             	mov    0x8(%ebp),%eax
  801304:	8b 40 04             	mov    0x4(%eax),%eax
  801307:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  80130a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130d:	83 e0 02             	and    $0x2,%eax
  801310:	85 c0                	test   %eax,%eax
  801312:	75 23                	jne    801337 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  801314:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131b:	c7 44 24 08 10 1f 80 	movl   $0x801f10,0x8(%esp)
  801322:	00 
  801323:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80132a:	00 
  80132b:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801332:	e8 8d ee ff ff       	call   8001c4 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133a:	c1 e8 0c             	shr    $0xc,%eax
  80133d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  801340:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801343:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134a:	25 00 08 00 00       	and    $0x800,%eax
  80134f:	85 c0                	test   %eax,%eax
  801351:	75 1c                	jne    80136f <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  801353:	c7 44 24 08 4c 1f 80 	movl   $0x801f4c,0x8(%esp)
  80135a:	00 
  80135b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801362:	00 
  801363:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80136a:	e8 55 ee ff ff       	call   8001c4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  80136f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801376:	00 
  801377:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80137e:	00 
  80137f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801386:	e8 11 fd ff ff       	call   80109c <sys_page_alloc>
  80138b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80138e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801392:	79 23                	jns    8013b7 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  801394:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139b:	c7 44 24 08 88 1f 80 	movl   $0x801f88,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8013aa:	00 
  8013ab:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8013b2:	e8 0d ee ff ff       	call   8001c4 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013cc:	00 
  8013cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013d8:	e8 03 f9 ff ff       	call   800ce0 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  8013dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013eb:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013f2:	00 
  8013f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013fe:	00 
  8013ff:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801406:	00 
  801407:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80140e:	e8 ca fc ff ff       	call   8010dd <sys_page_map>
  801413:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801416:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80141a:	79 23                	jns    80143f <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  80141c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80141f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801423:	c7 44 24 08 c0 1f 80 	movl   $0x801fc0,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  801432:	00 
  801433:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80143a:	e8 85 ed ff ff       	call   8001c4 <_panic>
	}

	// panic("pgfault not implemented");
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	56                   	push   %esi
  801445:	53                   	push   %ebx
  801446:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801449:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  801450:	8b 45 0c             	mov    0xc(%ebp),%eax
  801453:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145a:	25 00 08 00 00       	and    $0x800,%eax
  80145f:	85 c0                	test   %eax,%eax
  801461:	75 15                	jne    801478 <duppage+0x37>
  801463:	8b 45 0c             	mov    0xc(%ebp),%eax
  801466:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146d:	83 e0 02             	and    $0x2,%eax
  801470:	85 c0                	test   %eax,%eax
  801472:	0f 84 e0 00 00 00    	je     801558 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  801478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801482:	83 e0 04             	and    $0x4,%eax
  801485:	85 c0                	test   %eax,%eax
  801487:	74 04                	je     80148d <duppage+0x4c>
  801489:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  80148d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801490:	8b 45 0c             	mov    0xc(%ebp),%eax
  801493:	c1 e0 0c             	shl    $0xc,%eax
  801496:	89 c1                	mov    %eax,%ecx
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	c1 e0 0c             	shl    $0xc,%eax
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	a1 04 30 80 00       	mov    0x803004,%eax
  8014a5:	8b 40 48             	mov    0x48(%eax),%eax
  8014a8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014ac:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 1a fc ff ff       	call   8010dd <sys_page_map>
  8014c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014ca:	79 23                	jns    8014ef <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  8014cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d3:	c7 44 24 08 f4 1f 80 	movl   $0x801ff4,0x8(%esp)
  8014da:	00 
  8014db:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8014e2:	00 
  8014e3:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8014ea:	e8 d5 ec ff ff       	call   8001c4 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014ef:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8014f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f5:	c1 e0 0c             	shl    $0xc,%eax
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	a1 04 30 80 00       	mov    0x803004,%eax
  8014ff:	8b 48 48             	mov    0x48(%eax),%ecx
  801502:	8b 45 0c             	mov    0xc(%ebp),%eax
  801505:	c1 e0 0c             	shl    $0xc,%eax
  801508:	89 c2                	mov    %eax,%edx
  80150a:	a1 04 30 80 00       	mov    0x803004,%eax
  80150f:	8b 40 48             	mov    0x48(%eax),%eax
  801512:	89 74 24 10          	mov    %esi,0x10(%esp)
  801516:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80151a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801522:	89 04 24             	mov    %eax,(%esp)
  801525:	e8 b3 fb ff ff       	call   8010dd <sys_page_map>
  80152a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80152d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801531:	79 23                	jns    801556 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153a:	c7 44 24 08 30 20 80 	movl   $0x802030,0x8(%esp)
  801541:	00 
  801542:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801549:	00 
  80154a:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801551:	e8 6e ec ff ff       	call   8001c4 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801556:	eb 70                	jmp    8015c8 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801562:	25 ff 0f 00 00       	and    $0xfff,%eax
  801567:	89 c3                	mov    %eax,%ebx
  801569:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156c:	c1 e0 0c             	shl    $0xc,%eax
  80156f:	89 c1                	mov    %eax,%ecx
  801571:	8b 45 0c             	mov    0xc(%ebp),%eax
  801574:	c1 e0 0c             	shl    $0xc,%eax
  801577:	89 c2                	mov    %eax,%edx
  801579:	a1 04 30 80 00       	mov    0x803004,%eax
  80157e:	8b 40 48             	mov    0x48(%eax),%eax
  801581:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801585:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801589:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80158c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801590:	89 54 24 04          	mov    %edx,0x4(%esp)
  801594:	89 04 24             	mov    %eax,(%esp)
  801597:	e8 41 fb ff ff       	call   8010dd <sys_page_map>
  80159c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80159f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015a3:	79 23                	jns    8015c8 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  8015a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ac:	c7 44 24 08 60 20 80 	movl   $0x802060,0x8(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8015bb:	00 
  8015bc:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8015c3:	e8 fc eb ff ff       	call   8001c4 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cd:	83 c4 30             	add    $0x30,%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8015da:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  8015e1:	e8 2d 03 00 00       	call   801913 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015e6:	b8 07 00 00 00       	mov    $0x7,%eax
  8015eb:	cd 30                	int    $0x30
  8015ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8015f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8015f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8015f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015fa:	79 23                	jns    80161f <fork+0x4b>
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801603:	c7 44 24 08 98 20 80 	movl   $0x802098,0x8(%esp)
  80160a:	00 
  80160b:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  801612:	00 
  801613:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80161a:	e8 a5 eb ff ff       	call   8001c4 <_panic>
	else if(childeid == 0){
  80161f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801623:	75 29                	jne    80164e <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801625:	e8 ea f9 ff ff       	call   801014 <sys_getenvid>
  80162a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80162f:	c1 e0 02             	shl    $0x2,%eax
  801632:	89 c2                	mov    %eax,%edx
  801634:	c1 e2 05             	shl    $0x5,%edx
  801637:	29 c2                	sub    %eax,%edx
  801639:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80163f:	a3 04 30 80 00       	mov    %eax,0x803004
		// set_pgfault_handler(pgfault);
		return 0;
  801644:	b8 00 00 00 00       	mov    $0x0,%eax
  801649:	e9 16 01 00 00       	jmp    801764 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80164e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801655:	eb 3b                	jmp    801692 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801657:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165a:	c1 f8 0a             	sar    $0xa,%eax
  80165d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801664:	83 e0 01             	and    $0x1,%eax
  801667:	85 c0                	test   %eax,%eax
  801669:	74 23                	je     80168e <fork+0xba>
  80166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801675:	83 e0 01             	and    $0x1,%eax
  801678:	85 c0                	test   %eax,%eax
  80167a:	74 12                	je     80168e <fork+0xba>
			duppage(childeid, i);
  80167c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801686:	89 04 24             	mov    %eax,(%esp)
  801689:	e8 b3 fd ff ff       	call   801441 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80168e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801695:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  80169a:	76 bb                	jbe    801657 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  80169c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016a3:	00 
  8016a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016ab:	ee 
  8016ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016af:	89 04 24             	mov    %eax,(%esp)
  8016b2:	e8 e5 f9 ff ff       	call   80109c <sys_page_alloc>
  8016b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016be:	79 23                	jns    8016e3 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8016c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c7:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  8016ce:	00 
  8016cf:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8016d6:	00 
  8016d7:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8016de:	e8 e1 ea ff ff       	call   8001c4 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  8016e3:	c7 44 24 04 89 19 80 	movl   $0x801989,0x4(%esp)
  8016ea:	00 
  8016eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ee:	89 04 24             	mov    %eax,(%esp)
  8016f1:	e8 b1 fa ff ff       	call   8011a7 <sys_env_set_pgfault_upcall>
  8016f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016fd:	79 23                	jns    801722 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8016ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801702:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801706:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  80170d:	00 
  80170e:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801715:	00 
  801716:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80171d:	e8 a2 ea ff ff       	call   8001c4 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  801722:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801729:	00 
  80172a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172d:	89 04 24             	mov    %eax,(%esp)
  801730:	e8 30 fa ff ff       	call   801165 <sys_env_set_status>
  801735:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801738:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80173c:	79 23                	jns    801761 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  80173e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801741:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801745:	c7 44 24 08 1c 21 80 	movl   $0x80211c,0x8(%esp)
  80174c:	00 
  80174d:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801754:	00 
  801755:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80175c:	e8 63 ea ff ff       	call   8001c4 <_panic>
	}
	return childeid;
  801761:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  801764:	c9                   	leave  
  801765:	c3                   	ret    

00801766 <sfork>:

// Challenge!
int
sfork(void)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80176c:	c7 44 24 08 45 21 80 	movl   $0x802145,0x8(%esp)
  801773:	00 
  801774:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  80177b:	00 
  80177c:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801783:	e8 3c ea ff ff       	call   8001c4 <_panic>

00801788 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  80178e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801792:	75 09                	jne    80179d <ipc_recv+0x15>
		i_dstva = UTOP;
  801794:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  80179b:	eb 06                	jmp    8017a3 <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  80179d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  8017a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a6:	89 04 24             	mov    %eax,(%esp)
  8017a9:	e8 7b fa ff ff       	call   801229 <sys_ipc_recv>
  8017ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  8017b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017b5:	75 15                	jne    8017cc <ipc_recv+0x44>
  8017b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8017bb:	74 0f                	je     8017cc <ipc_recv+0x44>
  8017bd:	a1 04 30 80 00       	mov    0x803004,%eax
  8017c2:	8b 50 74             	mov    0x74(%eax),%edx
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	89 10                	mov    %edx,(%eax)
  8017ca:	eb 15                	jmp    8017e1 <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  8017cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017d0:	79 0f                	jns    8017e1 <ipc_recv+0x59>
  8017d2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8017d6:	74 09                	je     8017e1 <ipc_recv+0x59>
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  8017e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017e5:	75 15                	jne    8017fc <ipc_recv+0x74>
  8017e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017eb:	74 0f                	je     8017fc <ipc_recv+0x74>
  8017ed:	a1 04 30 80 00       	mov    0x803004,%eax
  8017f2:	8b 50 78             	mov    0x78(%eax),%edx
  8017f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f8:	89 10                	mov    %edx,(%eax)
  8017fa:	eb 15                	jmp    801811 <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  8017fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801800:	79 0f                	jns    801811 <ipc_recv+0x89>
  801802:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801806:	74 09                	je     801811 <ipc_recv+0x89>
  801808:	8b 45 10             	mov    0x10(%ebp),%eax
  80180b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  801811:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801815:	75 0a                	jne    801821 <ipc_recv+0x99>
  801817:	a1 04 30 80 00       	mov    0x803004,%eax
  80181c:	8b 40 70             	mov    0x70(%eax),%eax
  80181f:	eb 03                	jmp    801824 <ipc_recv+0x9c>
	else return r;
  801821:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  80182c:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  801833:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801837:	74 06                	je     80183f <ipc_send+0x19>
  801839:	8b 45 10             	mov    0x10(%ebp),%eax
  80183c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  80183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801842:	8b 55 14             	mov    0x14(%ebp),%edx
  801845:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801849:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	89 44 24 04          	mov    %eax,0x4(%esp)
  801854:	8b 45 08             	mov    0x8(%ebp),%eax
  801857:	89 04 24             	mov    %eax,(%esp)
  80185a:	e8 8a f9 ff ff       	call   8011e9 <sys_ipc_try_send>
  80185f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  801862:	eb 28                	jmp    80188c <ipc_send+0x66>
		sys_yield();
  801864:	e8 ef f7 ff ff       	call   801058 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186c:	8b 55 14             	mov    0x14(%ebp),%edx
  80186f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801873:	89 44 24 08          	mov    %eax,0x8(%esp)
  801877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	89 04 24             	mov    %eax,(%esp)
  801884:	e8 60 f9 ff ff       	call   8011e9 <sys_ipc_try_send>
  801889:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  80188c:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  801890:	74 d2                	je     801864 <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  801892:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801896:	75 02                	jne    80189a <ipc_send+0x74>
  801898:	eb 23                	jmp    8018bd <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  80189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a1:	c7 44 24 08 5c 21 80 	movl   $0x80215c,0x8(%esp)
  8018a8:	00 
  8018a9:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8018b0:	00 
  8018b1:	c7 04 24 81 21 80 00 	movl   $0x802181,(%esp)
  8018b8:	e8 07 e9 ff ff       	call   8001c4 <_panic>
	panic("ipc_send not implemented");
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  8018c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8018cc:	eb 35                	jmp    801903 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8018ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d1:	c1 e0 02             	shl    $0x2,%eax
  8018d4:	89 c2                	mov    %eax,%edx
  8018d6:	c1 e2 05             	shl    $0x5,%edx
  8018d9:	29 c2                	sub    %eax,%edx
  8018db:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8018e1:	8b 00                	mov    (%eax),%eax
  8018e3:	3b 45 08             	cmp    0x8(%ebp),%eax
  8018e6:	75 17                	jne    8018ff <ipc_find_env+0x40>
			return envs[i].env_id;
  8018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018eb:	c1 e0 02             	shl    $0x2,%eax
  8018ee:	89 c2                	mov    %eax,%edx
  8018f0:	c1 e2 05             	shl    $0x5,%edx
  8018f3:	29 c2                	sub    %eax,%edx
  8018f5:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8018fb:	8b 00                	mov    (%eax),%eax
  8018fd:	eb 12                	jmp    801911 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801903:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  80190a:	7e c2                	jle    8018ce <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80190c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801911:	c9                   	leave  
  801912:	c3                   	ret    

00801913 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801919:	a1 08 30 80 00       	mov    0x803008,%eax
  80191e:	85 c0                	test   %eax,%eax
  801920:	75 5d                	jne    80197f <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801922:	a1 04 30 80 00       	mov    0x803004,%eax
  801927:	8b 40 48             	mov    0x48(%eax),%eax
  80192a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801931:	00 
  801932:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801939:	ee 
  80193a:	89 04 24             	mov    %eax,(%esp)
  80193d:	e8 5a f7 ff ff       	call   80109c <sys_page_alloc>
  801942:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801945:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801949:	79 1c                	jns    801967 <set_pgfault_handler+0x54>
  80194b:	c7 44 24 08 8c 21 80 	movl   $0x80218c,0x8(%esp)
  801952:	00 
  801953:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80195a:	00 
  80195b:	c7 04 24 b8 21 80 00 	movl   $0x8021b8,(%esp)
  801962:	e8 5d e8 ff ff       	call   8001c4 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801967:	a1 04 30 80 00       	mov    0x803004,%eax
  80196c:	8b 40 48             	mov    0x48(%eax),%eax
  80196f:	c7 44 24 04 89 19 80 	movl   $0x801989,0x4(%esp)
  801976:	00 
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 28 f8 ff ff       	call   8011a7 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	a3 08 30 80 00       	mov    %eax,0x803008
}
  801987:	c9                   	leave  
  801988:	c3                   	ret    

00801989 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801989:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80198a:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  80198f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801991:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801994:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801998:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80199a:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80199e:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80199f:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8019a2:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8019a4:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8019a5:	58                   	pop    %eax
	popal 						// pop all the registers
  8019a6:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8019a7:	83 c4 04             	add    $0x4,%esp
	popfl
  8019aa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8019ab:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8019ac:	c3                   	ret    
  8019ad:	66 90                	xchg   %ax,%ax
  8019af:	90                   	nop

008019b0 <__udivdi3>:
  8019b0:	55                   	push   %ebp
  8019b1:	57                   	push   %edi
  8019b2:	56                   	push   %esi
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8019be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8019c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019cc:	89 ea                	mov    %ebp,%edx
  8019ce:	89 0c 24             	mov    %ecx,(%esp)
  8019d1:	75 2d                	jne    801a00 <__udivdi3+0x50>
  8019d3:	39 e9                	cmp    %ebp,%ecx
  8019d5:	77 61                	ja     801a38 <__udivdi3+0x88>
  8019d7:	85 c9                	test   %ecx,%ecx
  8019d9:	89 ce                	mov    %ecx,%esi
  8019db:	75 0b                	jne    8019e8 <__udivdi3+0x38>
  8019dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e2:	31 d2                	xor    %edx,%edx
  8019e4:	f7 f1                	div    %ecx
  8019e6:	89 c6                	mov    %eax,%esi
  8019e8:	31 d2                	xor    %edx,%edx
  8019ea:	89 e8                	mov    %ebp,%eax
  8019ec:	f7 f6                	div    %esi
  8019ee:	89 c5                	mov    %eax,%ebp
  8019f0:	89 f8                	mov    %edi,%eax
  8019f2:	f7 f6                	div    %esi
  8019f4:	89 ea                	mov    %ebp,%edx
  8019f6:	83 c4 0c             	add    $0xc,%esp
  8019f9:	5e                   	pop    %esi
  8019fa:	5f                   	pop    %edi
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    
  8019fd:	8d 76 00             	lea    0x0(%esi),%esi
  801a00:	39 e8                	cmp    %ebp,%eax
  801a02:	77 24                	ja     801a28 <__udivdi3+0x78>
  801a04:	0f bd e8             	bsr    %eax,%ebp
  801a07:	83 f5 1f             	xor    $0x1f,%ebp
  801a0a:	75 3c                	jne    801a48 <__udivdi3+0x98>
  801a0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a10:	39 34 24             	cmp    %esi,(%esp)
  801a13:	0f 86 9f 00 00 00    	jbe    801ab8 <__udivdi3+0x108>
  801a19:	39 d0                	cmp    %edx,%eax
  801a1b:	0f 82 97 00 00 00    	jb     801ab8 <__udivdi3+0x108>
  801a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a28:	31 d2                	xor    %edx,%edx
  801a2a:	31 c0                	xor    %eax,%eax
  801a2c:	83 c4 0c             	add    $0xc,%esp
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    
  801a33:	90                   	nop
  801a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a38:	89 f8                	mov    %edi,%eax
  801a3a:	f7 f1                	div    %ecx
  801a3c:	31 d2                	xor    %edx,%edx
  801a3e:	83 c4 0c             	add    $0xc,%esp
  801a41:	5e                   	pop    %esi
  801a42:	5f                   	pop    %edi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    
  801a45:	8d 76 00             	lea    0x0(%esi),%esi
  801a48:	89 e9                	mov    %ebp,%ecx
  801a4a:	8b 3c 24             	mov    (%esp),%edi
  801a4d:	d3 e0                	shl    %cl,%eax
  801a4f:	89 c6                	mov    %eax,%esi
  801a51:	b8 20 00 00 00       	mov    $0x20,%eax
  801a56:	29 e8                	sub    %ebp,%eax
  801a58:	89 c1                	mov    %eax,%ecx
  801a5a:	d3 ef                	shr    %cl,%edi
  801a5c:	89 e9                	mov    %ebp,%ecx
  801a5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a62:	8b 3c 24             	mov    (%esp),%edi
  801a65:	09 74 24 08          	or     %esi,0x8(%esp)
  801a69:	89 d6                	mov    %edx,%esi
  801a6b:	d3 e7                	shl    %cl,%edi
  801a6d:	89 c1                	mov    %eax,%ecx
  801a6f:	89 3c 24             	mov    %edi,(%esp)
  801a72:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a76:	d3 ee                	shr    %cl,%esi
  801a78:	89 e9                	mov    %ebp,%ecx
  801a7a:	d3 e2                	shl    %cl,%edx
  801a7c:	89 c1                	mov    %eax,%ecx
  801a7e:	d3 ef                	shr    %cl,%edi
  801a80:	09 d7                	or     %edx,%edi
  801a82:	89 f2                	mov    %esi,%edx
  801a84:	89 f8                	mov    %edi,%eax
  801a86:	f7 74 24 08          	divl   0x8(%esp)
  801a8a:	89 d6                	mov    %edx,%esi
  801a8c:	89 c7                	mov    %eax,%edi
  801a8e:	f7 24 24             	mull   (%esp)
  801a91:	39 d6                	cmp    %edx,%esi
  801a93:	89 14 24             	mov    %edx,(%esp)
  801a96:	72 30                	jb     801ac8 <__udivdi3+0x118>
  801a98:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a9c:	89 e9                	mov    %ebp,%ecx
  801a9e:	d3 e2                	shl    %cl,%edx
  801aa0:	39 c2                	cmp    %eax,%edx
  801aa2:	73 05                	jae    801aa9 <__udivdi3+0xf9>
  801aa4:	3b 34 24             	cmp    (%esp),%esi
  801aa7:	74 1f                	je     801ac8 <__udivdi3+0x118>
  801aa9:	89 f8                	mov    %edi,%eax
  801aab:	31 d2                	xor    %edx,%edx
  801aad:	e9 7a ff ff ff       	jmp    801a2c <__udivdi3+0x7c>
  801ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ab8:	31 d2                	xor    %edx,%edx
  801aba:	b8 01 00 00 00       	mov    $0x1,%eax
  801abf:	e9 68 ff ff ff       	jmp    801a2c <__udivdi3+0x7c>
  801ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ac8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801acb:	31 d2                	xor    %edx,%edx
  801acd:	83 c4 0c             	add    $0xc,%esp
  801ad0:	5e                   	pop    %esi
  801ad1:	5f                   	pop    %edi
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    
  801ad4:	66 90                	xchg   %ax,%ax
  801ad6:	66 90                	xchg   %ax,%ax
  801ad8:	66 90                	xchg   %ax,%ax
  801ada:	66 90                	xchg   %ax,%ax
  801adc:	66 90                	xchg   %ax,%ax
  801ade:	66 90                	xchg   %ax,%ax

00801ae0 <__umoddi3>:
  801ae0:	55                   	push   %ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	83 ec 14             	sub    $0x14,%esp
  801ae6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801aea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801aee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801af2:	89 c7                	mov    %eax,%edi
  801af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801afc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801b00:	89 34 24             	mov    %esi,(%esp)
  801b03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b07:	85 c0                	test   %eax,%eax
  801b09:	89 c2                	mov    %eax,%edx
  801b0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b0f:	75 17                	jne    801b28 <__umoddi3+0x48>
  801b11:	39 fe                	cmp    %edi,%esi
  801b13:	76 4b                	jbe    801b60 <__umoddi3+0x80>
  801b15:	89 c8                	mov    %ecx,%eax
  801b17:	89 fa                	mov    %edi,%edx
  801b19:	f7 f6                	div    %esi
  801b1b:	89 d0                	mov    %edx,%eax
  801b1d:	31 d2                	xor    %edx,%edx
  801b1f:	83 c4 14             	add    $0x14,%esp
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    
  801b26:	66 90                	xchg   %ax,%ax
  801b28:	39 f8                	cmp    %edi,%eax
  801b2a:	77 54                	ja     801b80 <__umoddi3+0xa0>
  801b2c:	0f bd e8             	bsr    %eax,%ebp
  801b2f:	83 f5 1f             	xor    $0x1f,%ebp
  801b32:	75 5c                	jne    801b90 <__umoddi3+0xb0>
  801b34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b38:	39 3c 24             	cmp    %edi,(%esp)
  801b3b:	0f 87 e7 00 00 00    	ja     801c28 <__umoddi3+0x148>
  801b41:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b45:	29 f1                	sub    %esi,%ecx
  801b47:	19 c7                	sbb    %eax,%edi
  801b49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b51:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b55:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b59:	83 c4 14             	add    $0x14,%esp
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    
  801b60:	85 f6                	test   %esi,%esi
  801b62:	89 f5                	mov    %esi,%ebp
  801b64:	75 0b                	jne    801b71 <__umoddi3+0x91>
  801b66:	b8 01 00 00 00       	mov    $0x1,%eax
  801b6b:	31 d2                	xor    %edx,%edx
  801b6d:	f7 f6                	div    %esi
  801b6f:	89 c5                	mov    %eax,%ebp
  801b71:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b75:	31 d2                	xor    %edx,%edx
  801b77:	f7 f5                	div    %ebp
  801b79:	89 c8                	mov    %ecx,%eax
  801b7b:	f7 f5                	div    %ebp
  801b7d:	eb 9c                	jmp    801b1b <__umoddi3+0x3b>
  801b7f:	90                   	nop
  801b80:	89 c8                	mov    %ecx,%eax
  801b82:	89 fa                	mov    %edi,%edx
  801b84:	83 c4 14             	add    $0x14,%esp
  801b87:	5e                   	pop    %esi
  801b88:	5f                   	pop    %edi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    
  801b8b:	90                   	nop
  801b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b90:	8b 04 24             	mov    (%esp),%eax
  801b93:	be 20 00 00 00       	mov    $0x20,%esi
  801b98:	89 e9                	mov    %ebp,%ecx
  801b9a:	29 ee                	sub    %ebp,%esi
  801b9c:	d3 e2                	shl    %cl,%edx
  801b9e:	89 f1                	mov    %esi,%ecx
  801ba0:	d3 e8                	shr    %cl,%eax
  801ba2:	89 e9                	mov    %ebp,%ecx
  801ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba8:	8b 04 24             	mov    (%esp),%eax
  801bab:	09 54 24 04          	or     %edx,0x4(%esp)
  801baf:	89 fa                	mov    %edi,%edx
  801bb1:	d3 e0                	shl    %cl,%eax
  801bb3:	89 f1                	mov    %esi,%ecx
  801bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bbd:	d3 ea                	shr    %cl,%edx
  801bbf:	89 e9                	mov    %ebp,%ecx
  801bc1:	d3 e7                	shl    %cl,%edi
  801bc3:	89 f1                	mov    %esi,%ecx
  801bc5:	d3 e8                	shr    %cl,%eax
  801bc7:	89 e9                	mov    %ebp,%ecx
  801bc9:	09 f8                	or     %edi,%eax
  801bcb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801bcf:	f7 74 24 04          	divl   0x4(%esp)
  801bd3:	d3 e7                	shl    %cl,%edi
  801bd5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bd9:	89 d7                	mov    %edx,%edi
  801bdb:	f7 64 24 08          	mull   0x8(%esp)
  801bdf:	39 d7                	cmp    %edx,%edi
  801be1:	89 c1                	mov    %eax,%ecx
  801be3:	89 14 24             	mov    %edx,(%esp)
  801be6:	72 2c                	jb     801c14 <__umoddi3+0x134>
  801be8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bec:	72 22                	jb     801c10 <__umoddi3+0x130>
  801bee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bf2:	29 c8                	sub    %ecx,%eax
  801bf4:	19 d7                	sbb    %edx,%edi
  801bf6:	89 e9                	mov    %ebp,%ecx
  801bf8:	89 fa                	mov    %edi,%edx
  801bfa:	d3 e8                	shr    %cl,%eax
  801bfc:	89 f1                	mov    %esi,%ecx
  801bfe:	d3 e2                	shl    %cl,%edx
  801c00:	89 e9                	mov    %ebp,%ecx
  801c02:	d3 ef                	shr    %cl,%edi
  801c04:	09 d0                	or     %edx,%eax
  801c06:	89 fa                	mov    %edi,%edx
  801c08:	83 c4 14             	add    $0x14,%esp
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    
  801c0f:	90                   	nop
  801c10:	39 d7                	cmp    %edx,%edi
  801c12:	75 da                	jne    801bee <__umoddi3+0x10e>
  801c14:	8b 14 24             	mov    (%esp),%edx
  801c17:	89 c1                	mov    %eax,%ecx
  801c19:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c1d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c21:	eb cb                	jmp    801bee <__umoddi3+0x10e>
  801c23:	90                   	nop
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c2c:	0f 82 0f ff ff ff    	jb     801b41 <__umoddi3+0x61>
  801c32:	e9 1a ff ff ff       	jmp    801b51 <__umoddi3+0x71>
