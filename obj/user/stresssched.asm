
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 f2 00 00 00       	call   800123 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800039:	e8 88 0f 00 00       	call   800fc6 <sys_getenvid>
  80003e:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// Fork several environments
	for (i = 0; i < 20; i++)
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800048:	eb 0f                	jmp    800059 <umain+0x26>
		if (fork() == 0)
  80004a:	e8 7b 15 00 00       	call   8015ca <fork>
  80004f:	85 c0                	test   %eax,%eax
  800051:	75 02                	jne    800055 <umain+0x22>
			break;
  800053:	eb 0a                	jmp    80005f <umain+0x2c>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  800055:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800059:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
  80005d:	7e eb                	jle    80004a <umain+0x17>
		if (fork() == 0)
			break;
	if (i == 20) {
  80005f:	83 7d f4 14          	cmpl   $0x14,-0xc(%ebp)
  800063:	75 0a                	jne    80006f <umain+0x3c>
		sys_yield();
  800065:	e8 a0 0f 00 00       	call   80100a <sys_yield>
		return;
  80006a:	e9 b2 00 00 00       	jmp    800121 <umain+0xee>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	c1 e0 02             	shl    $0x2,%eax
  80007e:	89 c2                	mov    %eax,%edx
  800080:	c1 e2 05             	shl    $0x5,%edx
  800083:	29 c2                	sub    %eax,%edx
  800085:	8d 82 54 00 c0 ee    	lea    -0x113fffac(%edx),%eax
  80008b:	8b 00                	mov    (%eax),%eax
  80008d:	85 c0                	test   %eax,%eax
  80008f:	75 e0                	jne    800071 <umain+0x3e>
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  800091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800098:	eb 2c                	jmp    8000c6 <umain+0x93>
		sys_yield();
  80009a:	e8 6b 0f 00 00       	call   80100a <sys_yield>
		for (j = 0; j < 10000; j++)
  80009f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000a6:	eb 11                	jmp    8000b9 <umain+0x86>
			counter++;
  8000a8:	a1 04 30 80 00       	mov    0x803004,%eax
  8000ad:	83 c0 01             	add    $0x1,%eax
  8000b0:	a3 04 30 80 00       	mov    %eax,0x803004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8000b9:	81 7d f0 0f 27 00 00 	cmpl   $0x270f,-0x10(%ebp)
  8000c0:	7e e6                	jle    8000a8 <umain+0x75>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000c6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  8000ca:	7e ce                	jle    80009a <umain+0x67>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000cc:	a1 04 30 80 00       	mov    0x803004,%eax
  8000d1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d6:	74 25                	je     8000fd <umain+0xca>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d8:	a1 04 30 80 00       	mov    0x803004,%eax
  8000dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e1:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f0:	00 
  8000f1:	c7 04 24 e8 1a 80 00 	movl   $0x801ae8,(%esp)
  8000f8:	e8 79 00 00 00       	call   800176 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000fd:	a1 08 30 80 00       	mov    0x803008,%eax
  800102:	8b 50 5c             	mov    0x5c(%eax),%edx
  800105:	a1 08 30 80 00       	mov    0x803008,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800111:	89 44 24 04          	mov    %eax,0x4(%esp)
  800115:	c7 04 24 fb 1a 80 00 	movl   $0x801afb,(%esp)
  80011c:	e8 70 01 00 00       	call   800291 <cprintf>

}
  800121:	c9                   	leave  
  800122:	c3                   	ret    

00800123 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800129:	e8 98 0e 00 00       	call   800fc6 <sys_getenvid>
  80012e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800133:	c1 e0 02             	shl    $0x2,%eax
  800136:	89 c2                	mov    %eax,%edx
  800138:	c1 e2 05             	shl    $0x5,%edx
  80013b:	29 c2                	sub    %eax,%edx
  80013d:	89 d0                	mov    %edx,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 08 30 80 00       	mov    %eax,0x803008
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 d8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80015b:	e8 02 00 00 00       	call   800162 <exit>
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80016f:	e8 0f 0e 00 00       	call   800f83 <sys_env_destroy>
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	53                   	push   %ebx
  80017a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80017d:	8d 45 14             	lea    0x14(%ebp),%eax
  800180:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800183:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800189:	e8 38 0e 00 00       	call   800fc6 <sys_getenvid>
  80018e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800191:	89 54 24 10          	mov    %edx,0x10(%esp)
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80019c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	c7 04 24 24 1b 80 00 	movl   $0x801b24,(%esp)
  8001ab:	e8 e1 00 00 00       	call   800291 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ba:	89 04 24             	mov    %eax,(%esp)
  8001bd:	e8 6b 00 00 00       	call   80022d <vcprintf>
	cprintf("\n");
  8001c2:	c7 04 24 47 1b 80 00 	movl   $0x801b47,(%esp)
  8001c9:	e8 c3 00 00 00       	call   800291 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ce:	cc                   	int3   
  8001cf:	eb fd                	jmp    8001ce <_panic+0x58>

008001d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001da:	8b 00                	mov    (%eax),%eax
  8001dc:	8d 48 01             	lea    0x1(%eax),%ecx
  8001df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e2:	89 0a                	mov    %ecx,(%edx)
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	89 d1                	mov    %edx,%ecx
  8001e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ec:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	8b 00                	mov    (%eax),%eax
  8001f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fa:	75 20                	jne    80021c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	8b 00                	mov    (%eax),%eax
  800201:	8b 55 0c             	mov    0xc(%ebp),%edx
  800204:	83 c2 08             	add    $0x8,%edx
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	89 14 24             	mov    %edx,(%esp)
  80020e:	e8 ea 0c 00 00       	call   800efd <sys_cputs>
		b->idx = 0;
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
  800216:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	8b 40 04             	mov    0x4(%eax),%eax
  800222:	8d 50 01             	lea    0x1(%eax),%edx
  800225:	8b 45 0c             	mov    0xc(%ebp),%eax
  800228:	89 50 04             	mov    %edx,0x4(%eax)
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800236:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023d:	00 00 00 
	b.cnt = 0;
  800240:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800247:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800262:	c7 04 24 d1 01 80 00 	movl   $0x8001d1,(%esp)
  800269:	e8 bd 01 00 00       	call   80042b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800274:	89 44 24 04          	mov    %eax,0x4(%esp)
  800278:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80027e:	83 c0 08             	add    $0x8,%eax
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	e8 74 0c 00 00       	call   800efd <sys_cputs>

	return b.cnt;
  800289:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800297:	8d 45 0c             	lea    0xc(%ebp),%eax
  80029a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80029d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 7e ff ff ff       	call   80022d <vcprintf>
  8002af:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 34             	sub    $0x34,%esp
  8002be:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ca:	8b 45 18             	mov    0x18(%ebp),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002d5:	77 72                	ja     800349 <printnum+0x92>
  8002d7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002da:	72 05                	jb     8002e1 <printnum+0x2a>
  8002dc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002df:	77 68                	ja     800349 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e1:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002e4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e7:	8b 45 18             	mov    0x18(%ebp),%eax
  8002ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002fd:	89 04 24             	mov    %eax,(%esp)
  800300:	89 54 24 04          	mov    %edx,0x4(%esp)
  800304:	e8 17 15 00 00       	call   801820 <__udivdi3>
  800309:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80030c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800310:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800314:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800317:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80031b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
  800326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	89 04 24             	mov    %eax,(%esp)
  800330:	e8 82 ff ff ff       	call   8002b7 <printnum>
  800335:	eb 1c                	jmp    800353 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800337:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033e:	8b 45 20             	mov    0x20(%ebp),%eax
  800341:	89 04 24             	mov    %eax,(%esp)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800349:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80034d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800351:	7f e4                	jg     800337 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800353:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800356:	bb 00 00 00 00       	mov    $0x0,%ebx
  80035b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80035e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800361:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800365:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800369:	89 04 24             	mov    %eax,(%esp)
  80036c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800370:	e8 db 15 00 00       	call   801950 <__umoddi3>
  800375:	05 28 1c 80 00       	add    $0x801c28,%eax
  80037a:	0f b6 00             	movzbl (%eax),%eax
  80037d:	0f be c0             	movsbl %al,%eax
  800380:	8b 55 0c             	mov    0xc(%ebp),%edx
  800383:	89 54 24 04          	mov    %edx,0x4(%esp)
  800387:	89 04 24             	mov    %eax,(%esp)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	ff d0                	call   *%eax
}
  80038f:	83 c4 34             	add    $0x34,%esp
  800392:	5b                   	pop    %ebx
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800398:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80039c:	7e 14                	jle    8003b2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	8d 48 08             	lea    0x8(%eax),%ecx
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 0a                	mov    %ecx,(%edx)
  8003ab:	8b 50 04             	mov    0x4(%eax),%edx
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	eb 30                	jmp    8003e2 <getuint+0x4d>
	else if (lflag)
  8003b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003b6:	74 16                	je     8003ce <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	8b 00                	mov    (%eax),%eax
  8003bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c3:	89 0a                	mov    %ecx,(%edx)
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cc:	eb 14                	jmp    8003e2 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d9:	89 0a                	mov    %ecx,(%edx)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003eb:	7e 14                	jle    800401 <getint+0x1d>
		return va_arg(*ap, long long);
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	8d 48 08             	lea    0x8(%eax),%ecx
  8003f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f8:	89 0a                	mov    %ecx,(%edx)
  8003fa:	8b 50 04             	mov    0x4(%eax),%edx
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	eb 28                	jmp    800429 <getint+0x45>
	else if (lflag)
  800401:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800405:	74 12                	je     800419 <getint+0x35>
		return va_arg(*ap, long);
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	8d 48 04             	lea    0x4(%eax),%ecx
  80040f:	8b 55 08             	mov    0x8(%ebp),%edx
  800412:	89 0a                	mov    %ecx,(%edx)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	99                   	cltd   
  800417:	eb 10                	jmp    800429 <getint+0x45>
	else
		return va_arg(*ap, int);
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	8d 48 04             	lea    0x4(%eax),%ecx
  800421:	8b 55 08             	mov    0x8(%ebp),%edx
  800424:	89 0a                	mov    %ecx,(%edx)
  800426:	8b 00                	mov    (%eax),%eax
  800428:	99                   	cltd   
}
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    

0080042b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800433:	eb 18                	jmp    80044d <vprintfmt+0x22>
			if (ch == '\0')
  800435:	85 db                	test   %ebx,%ebx
  800437:	75 05                	jne    80043e <vprintfmt+0x13>
				return;
  800439:	e9 cc 03 00 00       	jmp    80080a <vprintfmt+0x3df>
			putch(ch, putdat);
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	89 1c 24             	mov    %ebx,(%esp)
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044d:	8b 45 10             	mov    0x10(%ebp),%eax
  800450:	8d 50 01             	lea    0x1(%eax),%edx
  800453:	89 55 10             	mov    %edx,0x10(%ebp)
  800456:	0f b6 00             	movzbl (%eax),%eax
  800459:	0f b6 d8             	movzbl %al,%ebx
  80045c:	83 fb 25             	cmp    $0x25,%ebx
  80045f:	75 d4                	jne    800435 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800461:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800465:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800473:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80047a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 45 10             	mov    0x10(%ebp),%eax
  800484:	8d 50 01             	lea    0x1(%eax),%edx
  800487:	89 55 10             	mov    %edx,0x10(%ebp)
  80048a:	0f b6 00             	movzbl (%eax),%eax
  80048d:	0f b6 d8             	movzbl %al,%ebx
  800490:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800493:	83 f8 55             	cmp    $0x55,%eax
  800496:	0f 87 3d 03 00 00    	ja     8007d9 <vprintfmt+0x3ae>
  80049c:	8b 04 85 4c 1c 80 00 	mov    0x801c4c(,%eax,4),%eax
  8004a3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ab:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004af:	eb d0                	jmp    800481 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004bb:	89 d0                	mov    %edx,%eax
  8004bd:	c1 e0 02             	shl    $0x2,%eax
  8004c0:	01 d0                	add    %edx,%eax
  8004c2:	01 c0                	add    %eax,%eax
  8004c4:	01 d8                	add    %ebx,%eax
  8004c6:	83 e8 30             	sub    $0x30,%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cf:	0f b6 00             	movzbl (%eax),%eax
  8004d2:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004d5:	83 fb 2f             	cmp    $0x2f,%ebx
  8004d8:	7e 0b                	jle    8004e5 <vprintfmt+0xba>
  8004da:	83 fb 39             	cmp    $0x39,%ebx
  8004dd:	7f 06                	jg     8004e5 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004df:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e3:	eb d3                	jmp    8004b8 <vprintfmt+0x8d>
			goto process_precision;
  8004e5:	eb 33                	jmp    80051a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004f5:	eb 23                	jmp    80051a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fb:	79 0c                	jns    800509 <vprintfmt+0xde>
				width = 0;
  8004fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800504:	e9 78 ff ff ff       	jmp    800481 <vprintfmt+0x56>
  800509:	e9 73 ff ff ff       	jmp    800481 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80050e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800515:	e9 67 ff ff ff       	jmp    800481 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80051a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051e:	79 12                	jns    800532 <vprintfmt+0x107>
				width = precision, precision = -1;
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800526:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80052d:	e9 4f ff ff ff       	jmp    800481 <vprintfmt+0x56>
  800532:	e9 4a ff ff ff       	jmp    800481 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80053b:	e9 41 ff ff ff       	jmp    800481 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	ff d0                	call   *%eax
			break;
  80055a:	e9 a5 02 00 00       	jmp    800804 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80056a:	85 db                	test   %ebx,%ebx
  80056c:	79 02                	jns    800570 <vprintfmt+0x145>
				err = -err;
  80056e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800570:	83 fb 09             	cmp    $0x9,%ebx
  800573:	7f 0b                	jg     800580 <vprintfmt+0x155>
  800575:	8b 34 9d 00 1c 80 00 	mov    0x801c00(,%ebx,4),%esi
  80057c:	85 f6                	test   %esi,%esi
  80057e:	75 23                	jne    8005a3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800580:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800584:	c7 44 24 08 39 1c 80 	movl   $0x801c39,0x8(%esp)
  80058b:	00 
  80058c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800593:	8b 45 08             	mov    0x8(%ebp),%eax
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	e8 73 02 00 00       	call   800811 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80059e:	e9 61 02 00 00       	jmp    800804 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005a7:	c7 44 24 08 42 1c 80 	movl   $0x801c42,0x8(%esp)
  8005ae:	00 
  8005af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b9:	89 04 24             	mov    %eax,(%esp)
  8005bc:	e8 50 02 00 00       	call   800811 <printfmt>
			break;
  8005c1:	e9 3e 02 00 00       	jmp    800804 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 30                	mov    (%eax),%esi
  8005d1:	85 f6                	test   %esi,%esi
  8005d3:	75 05                	jne    8005da <vprintfmt+0x1af>
				p = "(null)";
  8005d5:	be 45 1c 80 00       	mov    $0x801c45,%esi
			if (width > 0 && padc != '-')
  8005da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005de:	7e 37                	jle    800617 <vprintfmt+0x1ec>
  8005e0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005e4:	74 31                	je     800617 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	89 34 24             	mov    %esi,(%esp)
  8005f0:	e8 39 03 00 00       	call   80092e <strnlen>
  8005f5:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005f8:	eb 17                	jmp    800611 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005fa:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800601:	89 54 24 04          	mov    %edx,0x4(%esp)
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800611:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800615:	7f e3                	jg     8005fa <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800617:	eb 38                	jmp    800651 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061d:	74 1f                	je     80063e <vprintfmt+0x213>
  80061f:	83 fb 1f             	cmp    $0x1f,%ebx
  800622:	7e 05                	jle    800629 <vprintfmt+0x1fe>
  800624:	83 fb 7e             	cmp    $0x7e,%ebx
  800627:	7e 15                	jle    80063e <vprintfmt+0x213>
					putch('?', putdat);
  800629:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	ff d0                	call   *%eax
  80063c:	eb 0f                	jmp    80064d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80063e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800641:	89 44 24 04          	mov    %eax,0x4(%esp)
  800645:	89 1c 24             	mov    %ebx,(%esp)
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800651:	89 f0                	mov    %esi,%eax
  800653:	8d 70 01             	lea    0x1(%eax),%esi
  800656:	0f b6 00             	movzbl (%eax),%eax
  800659:	0f be d8             	movsbl %al,%ebx
  80065c:	85 db                	test   %ebx,%ebx
  80065e:	74 10                	je     800670 <vprintfmt+0x245>
  800660:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800664:	78 b3                	js     800619 <vprintfmt+0x1ee>
  800666:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80066a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066e:	79 a9                	jns    800619 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800670:	eb 17                	jmp    800689 <vprintfmt+0x25e>
				putch(' ', putdat);
  800672:	8b 45 0c             	mov    0xc(%ebp),%eax
  800675:	89 44 24 04          	mov    %eax,0x4(%esp)
  800679:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800685:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800689:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80068d:	7f e3                	jg     800672 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80068f:	e9 70 01 00 00       	jmp    800804 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	e8 3e fd ff ff       	call   8003e4 <getint>
  8006a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	79 26                	jns    8006dc <vprintfmt+0x2b1>
				putch('-', putdat);
  8006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	ff d0                	call   *%eax
				num = -(long long) num;
  8006c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006cf:	f7 d8                	neg    %eax
  8006d1:	83 d2 00             	adc    $0x0,%edx
  8006d4:	f7 da                	neg    %edx
  8006d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006dc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006e3:	e9 a8 00 00 00       	jmp    800790 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	e8 9b fc ff ff       	call   800395 <getuint>
  8006fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800700:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800707:	e9 84 00 00 00       	jmp    800790 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80070c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	e8 77 fc ff ff       	call   800395 <getuint>
  80071e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800721:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800724:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80072b:	eb 63                	jmp    800790 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80072d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800730:	89 44 24 04          	mov    %eax,0x4(%esp)
  800734:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	ff d0                	call   *%eax
			putch('x', putdat);
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 50 04             	lea    0x4(%eax),%edx
  800759:	89 55 14             	mov    %edx,0x14(%ebp)
  80075c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80075e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800768:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80076f:	eb 1f                	jmp    800790 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800771:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	8d 45 14             	lea    0x14(%ebp),%eax
  80077b:	89 04 24             	mov    %eax,(%esp)
  80077e:	e8 12 fc ff ff       	call   800395 <getuint>
  800783:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800786:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800789:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800790:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800794:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800797:	89 54 24 18          	mov    %edx,0x18(%esp)
  80079b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079e:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	e8 f1 fa ff ff       	call   8002b7 <printnum>
			break;
  8007c6:	eb 3c                	jmp    800804 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cf:	89 1c 24             	mov    %ebx,(%esp)
  8007d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d5:	ff d0                	call   *%eax
			break;
  8007d7:	eb 2b                	jmp    800804 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ec:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007f0:	eb 04                	jmp    8007f6 <vprintfmt+0x3cb>
  8007f2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f9:	83 e8 01             	sub    $0x1,%eax
  8007fc:	0f b6 00             	movzbl (%eax),%eax
  8007ff:	3c 25                	cmp    $0x25,%al
  800801:	75 ef                	jne    8007f2 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800803:	90                   	nop
		}
	}
  800804:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800805:	e9 43 fc ff ff       	jmp    80044d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80080a:	83 c4 40             	add    $0x40,%esp
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
  80081a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80081d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800820:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800824:	8b 45 10             	mov    0x10(%ebp),%eax
  800827:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	89 04 24             	mov    %eax,(%esp)
  800838:	e8 ee fb ff ff       	call   80042b <vprintfmt>
	va_end(ap);
}
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800842:	8b 45 0c             	mov    0xc(%ebp),%eax
  800845:	8b 40 08             	mov    0x8(%eax),%eax
  800848:	8d 50 01             	lea    0x1(%eax),%edx
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800851:	8b 45 0c             	mov    0xc(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	8b 40 04             	mov    0x4(%eax),%eax
  80085c:	39 c2                	cmp    %eax,%edx
  80085e:	73 12                	jae    800872 <sprintputch+0x33>
		*b->buf++ = ch;
  800860:	8b 45 0c             	mov    0xc(%ebp),%eax
  800863:	8b 00                	mov    (%eax),%eax
  800865:	8d 48 01             	lea    0x1(%eax),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 0a                	mov    %ecx,(%edx)
  80086d:	8b 55 08             	mov    0x8(%ebp),%edx
  800870:	88 10                	mov    %dl,(%eax)
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800880:	8b 45 0c             	mov    0xc(%ebp),%eax
  800883:	8d 50 ff             	lea    -0x1(%eax),%edx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	01 d0                	add    %edx,%eax
  80088b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80088e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800895:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800899:	74 06                	je     8008a1 <vsnprintf+0x2d>
  80089b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80089f:	7f 07                	jg     8008a8 <vsnprintf+0x34>
		return -E_INVAL;
  8008a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a6:	eb 2a                	jmp    8008d2 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008af:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bd:	c7 04 24 3f 08 80 00 	movl   $0x80083f,(%esp)
  8008c4:	e8 62 fb ff ff       	call   80042b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    

008008d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008da:	8d 45 14             	lea    0x14(%ebp),%eax
  8008dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	89 04 24             	mov    %eax,(%esp)
  8008fb:	e8 74 ff ff ff       	call   800874 <vsnprintf>
  800900:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800903:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800915:	eb 08                	jmp    80091f <strlen+0x17>
		n++;
  800917:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80091b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 00             	movzbl (%eax),%eax
  800925:	84 c0                	test   %al,%al
  800927:	75 ee                	jne    800917 <strlen+0xf>
		n++;
	return n;
  800929:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80093b:	eb 0c                	jmp    800949 <strnlen+0x1b>
		n++;
  80093d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800941:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800945:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800949:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80094d:	74 0a                	je     800959 <strnlen+0x2b>
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	0f b6 00             	movzbl (%eax),%eax
  800955:	84 c0                	test   %al,%al
  800957:	75 e4                	jne    80093d <strnlen+0xf>
		n++;
	return n;
  800959:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80095c:	c9                   	leave  
  80095d:	c3                   	ret    

0080095e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80096a:	90                   	nop
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8d 50 01             	lea    0x1(%eax),%edx
  800971:	89 55 08             	mov    %edx,0x8(%ebp)
  800974:	8b 55 0c             	mov    0xc(%ebp),%edx
  800977:	8d 4a 01             	lea    0x1(%edx),%ecx
  80097a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80097d:	0f b6 12             	movzbl (%edx),%edx
  800980:	88 10                	mov    %dl,(%eax)
  800982:	0f b6 00             	movzbl (%eax),%eax
  800985:	84 c0                	test   %al,%al
  800987:	75 e2                	jne    80096b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800989:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	89 04 24             	mov    %eax,(%esp)
  80099a:	e8 69 ff ff ff       	call   800908 <strlen>
  80099f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	01 c2                	add    %eax,%edx
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b1:	89 14 24             	mov    %edx,(%esp)
  8009b4:	e8 a5 ff ff ff       	call   80095e <strcpy>
	return dst;
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009d1:	eb 23                	jmp    8009f6 <strncpy+0x38>
		*dst++ = *src;
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8d 50 01             	lea    0x1(%eax),%edx
  8009d9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009df:	0f b6 12             	movzbl (%edx),%edx
  8009e2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e7:	0f b6 00             	movzbl (%eax),%eax
  8009ea:	84 c0                	test   %al,%al
  8009ec:	74 04                	je     8009f2 <strncpy+0x34>
			src++;
  8009ee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009f9:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009fc:	72 d5                	jb     8009d3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a13:	74 33                	je     800a48 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a15:	eb 17                	jmp    800a2e <strlcpy+0x2b>
			*dst++ = *src++;
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8d 50 01             	lea    0x1(%eax),%edx
  800a1d:	89 55 08             	mov    %edx,0x8(%ebp)
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a26:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a29:	0f b6 12             	movzbl (%edx),%edx
  800a2c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a2e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a36:	74 0a                	je     800a42 <strlcpy+0x3f>
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	0f b6 00             	movzbl (%eax),%eax
  800a3e:	84 c0                	test   %al,%al
  800a40:	75 d5                	jne    800a17 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a4e:	29 c2                	sub    %eax,%edx
  800a50:	89 d0                	mov    %edx,%eax
}
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a57:	eb 08                	jmp    800a61 <strcmp+0xd>
		p++, q++;
  800a59:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a5d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	0f b6 00             	movzbl (%eax),%eax
  800a67:	84 c0                	test   %al,%al
  800a69:	74 10                	je     800a7b <strcmp+0x27>
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	0f b6 10             	movzbl (%eax),%edx
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	0f b6 00             	movzbl (%eax),%eax
  800a77:	38 c2                	cmp    %al,%dl
  800a79:	74 de                	je     800a59 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	0f b6 d0             	movzbl %al,%edx
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	0f b6 00             	movzbl (%eax),%eax
  800a8a:	0f b6 c0             	movzbl %al,%eax
  800a8d:	29 c2                	sub    %eax,%edx
  800a8f:	89 d0                	mov    %edx,%eax
}
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a96:	eb 0c                	jmp    800aa4 <strncmp+0x11>
		n--, p++, q++;
  800a98:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a9c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aa0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa8:	74 1a                	je     800ac4 <strncmp+0x31>
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	0f b6 00             	movzbl (%eax),%eax
  800ab0:	84 c0                	test   %al,%al
  800ab2:	74 10                	je     800ac4 <strncmp+0x31>
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	0f b6 10             	movzbl (%eax),%edx
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	0f b6 00             	movzbl (%eax),%eax
  800ac0:	38 c2                	cmp    %al,%dl
  800ac2:	74 d4                	je     800a98 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ac4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac8:	75 07                	jne    800ad1 <strncmp+0x3e>
		return 0;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	eb 16                	jmp    800ae7 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	0f b6 00             	movzbl (%eax),%eax
  800ad7:	0f b6 d0             	movzbl %al,%edx
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	0f b6 00             	movzbl (%eax),%eax
  800ae0:	0f b6 c0             	movzbl %al,%eax
  800ae3:	29 c2                	sub    %eax,%edx
  800ae5:	89 d0                	mov    %edx,%eax
}
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 04             	sub    $0x4,%esp
  800aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af2:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800af5:	eb 14                	jmp    800b0b <strchr+0x22>
		if (*s == c)
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	0f b6 00             	movzbl (%eax),%eax
  800afd:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b00:	75 05                	jne    800b07 <strchr+0x1e>
			return (char *) s;
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	eb 13                	jmp    800b1a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b07:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	0f b6 00             	movzbl (%eax),%eax
  800b11:	84 c0                	test   %al,%al
  800b13:	75 e2                	jne    800af7 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 04             	sub    $0x4,%esp
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b28:	eb 11                	jmp    800b3b <strfind+0x1f>
		if (*s == c)
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	0f b6 00             	movzbl (%eax),%eax
  800b30:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b33:	75 02                	jne    800b37 <strfind+0x1b>
			break;
  800b35:	eb 0e                	jmp    800b45 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	0f b6 00             	movzbl (%eax),%eax
  800b41:	84 c0                	test   %al,%al
  800b43:	75 e5                	jne    800b2a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b52:	75 05                	jne    800b59 <memset+0xf>
		return v;
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	eb 5c                	jmp    800bb5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	83 e0 03             	and    $0x3,%eax
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	75 41                	jne    800ba4 <memset+0x5a>
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	83 e0 03             	and    $0x3,%eax
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	75 37                	jne    800ba4 <memset+0x5a>
		c &= 0xFF;
  800b6d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	c1 e0 18             	shl    $0x18,%eax
  800b7a:	89 c2                	mov    %eax,%edx
  800b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7f:	c1 e0 10             	shl    $0x10,%eax
  800b82:	09 c2                	or     %eax,%edx
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	c1 e0 08             	shl    $0x8,%eax
  800b8a:	09 d0                	or     %edx,%eax
  800b8c:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b92:	c1 e8 02             	shr    $0x2,%eax
  800b95:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9d:	89 d7                	mov    %edx,%edi
  800b9f:	fc                   	cld    
  800ba0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba2:	eb 0e                	jmp    800bb2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	fc                   	cld    
  800bb0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bd3:	73 6d                	jae    800c42 <memmove+0x8a>
  800bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bdb:	01 d0                	add    %edx,%eax
  800bdd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800be0:	76 60                	jbe    800c42 <memmove+0x8a>
		s += n;
  800be2:	8b 45 10             	mov    0x10(%ebp),%eax
  800be5:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800be8:	8b 45 10             	mov    0x10(%ebp),%eax
  800beb:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf1:	83 e0 03             	and    $0x3,%eax
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	75 2f                	jne    800c27 <memmove+0x6f>
  800bf8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bfb:	83 e0 03             	and    $0x3,%eax
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	75 25                	jne    800c27 <memmove+0x6f>
  800c02:	8b 45 10             	mov    0x10(%ebp),%eax
  800c05:	83 e0 03             	and    $0x3,%eax
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	75 1b                	jne    800c27 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0f:	83 e8 04             	sub    $0x4,%eax
  800c12:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c15:	83 ea 04             	sub    $0x4,%edx
  800c18:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c1b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	89 d6                	mov    %edx,%esi
  800c22:	fd                   	std    
  800c23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c25:	eb 18                	jmp    800c3f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c27:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c2a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c30:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c33:	8b 45 10             	mov    0x10(%ebp),%eax
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 de                	mov    %ebx,%esi
  800c3a:	89 c1                	mov    %eax,%ecx
  800c3c:	fd                   	std    
  800c3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3f:	fc                   	cld    
  800c40:	eb 45                	jmp    800c87 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c45:	83 e0 03             	and    $0x3,%eax
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	75 2b                	jne    800c77 <memmove+0xbf>
  800c4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c4f:	83 e0 03             	and    $0x3,%eax
  800c52:	85 c0                	test   %eax,%eax
  800c54:	75 21                	jne    800c77 <memmove+0xbf>
  800c56:	8b 45 10             	mov    0x10(%ebp),%eax
  800c59:	83 e0 03             	and    $0x3,%eax
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	75 17                	jne    800c77 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c60:	8b 45 10             	mov    0x10(%ebp),%eax
  800c63:	c1 e8 02             	shr    $0x2,%eax
  800c66:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c6e:	89 c7                	mov    %eax,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	fc                   	cld    
  800c73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c75:	eb 10                	jmp    800c87 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c80:	89 c7                	mov    %eax,%edi
  800c82:	89 d6                	mov    %edx,%esi
  800c84:	fc                   	cld    
  800c85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 07 ff ff ff       	call   800bb8 <memmove>
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cc5:	eb 30                	jmp    800cf7 <memcmp+0x44>
		if (*s1 != *s2)
  800cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cca:	0f b6 10             	movzbl (%eax),%edx
  800ccd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cd0:	0f b6 00             	movzbl (%eax),%eax
  800cd3:	38 c2                	cmp    %al,%dl
  800cd5:	74 18                	je     800cef <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cda:	0f b6 00             	movzbl (%eax),%eax
  800cdd:	0f b6 d0             	movzbl %al,%edx
  800ce0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ce3:	0f b6 00             	movzbl (%eax),%eax
  800ce6:	0f b6 c0             	movzbl %al,%eax
  800ce9:	29 c2                	sub    %eax,%edx
  800ceb:	89 d0                	mov    %edx,%eax
  800ced:	eb 1a                	jmp    800d09 <memcmp+0x56>
		s1++, s2++;
  800cef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cf3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfa:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cfd:	89 55 10             	mov    %edx,0x10(%ebp)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	75 c3                	jne    800cc7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d11:	8b 45 10             	mov    0x10(%ebp),%eax
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	01 d0                	add    %edx,%eax
  800d19:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d1c:	eb 13                	jmp    800d31 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 10             	movzbl (%eax),%edx
  800d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d27:	38 c2                	cmp    %al,%dl
  800d29:	75 02                	jne    800d2d <memfind+0x22>
			break;
  800d2b:	eb 0c                	jmp    800d39 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d2d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d37:	72 e5                	jb     800d1e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d4b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d52:	eb 04                	jmp    800d58 <strtol+0x1a>
		s++;
  800d54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	3c 20                	cmp    $0x20,%al
  800d60:	74 f2                	je     800d54 <strtol+0x16>
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	3c 09                	cmp    $0x9,%al
  800d6a:	74 e8                	je     800d54 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	0f b6 00             	movzbl (%eax),%eax
  800d72:	3c 2b                	cmp    $0x2b,%al
  800d74:	75 06                	jne    800d7c <strtol+0x3e>
		s++;
  800d76:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7a:	eb 15                	jmp    800d91 <strtol+0x53>
	else if (*s == '-')
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 00             	movzbl (%eax),%eax
  800d82:	3c 2d                	cmp    $0x2d,%al
  800d84:	75 0b                	jne    800d91 <strtol+0x53>
		s++, neg = 1;
  800d86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d95:	74 06                	je     800d9d <strtol+0x5f>
  800d97:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d9b:	75 24                	jne    800dc1 <strtol+0x83>
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	0f b6 00             	movzbl (%eax),%eax
  800da3:	3c 30                	cmp    $0x30,%al
  800da5:	75 1a                	jne    800dc1 <strtol+0x83>
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
  800daa:	83 c0 01             	add    $0x1,%eax
  800dad:	0f b6 00             	movzbl (%eax),%eax
  800db0:	3c 78                	cmp    $0x78,%al
  800db2:	75 0d                	jne    800dc1 <strtol+0x83>
		s += 2, base = 16;
  800db4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800db8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dbf:	eb 2a                	jmp    800deb <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800dc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc5:	75 17                	jne    800dde <strtol+0xa0>
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	3c 30                	cmp    $0x30,%al
  800dcf:	75 0d                	jne    800dde <strtol+0xa0>
		s++, base = 8;
  800dd1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ddc:	eb 0d                	jmp    800deb <strtol+0xad>
	else if (base == 0)
  800dde:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de2:	75 07                	jne    800deb <strtol+0xad>
		base = 10;
  800de4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	0f b6 00             	movzbl (%eax),%eax
  800df1:	3c 2f                	cmp    $0x2f,%al
  800df3:	7e 1b                	jle    800e10 <strtol+0xd2>
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	0f b6 00             	movzbl (%eax),%eax
  800dfb:	3c 39                	cmp    $0x39,%al
  800dfd:	7f 11                	jg     800e10 <strtol+0xd2>
			dig = *s - '0';
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	0f b6 00             	movzbl (%eax),%eax
  800e05:	0f be c0             	movsbl %al,%eax
  800e08:	83 e8 30             	sub    $0x30,%eax
  800e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e0e:	eb 48                	jmp    800e58 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	0f b6 00             	movzbl (%eax),%eax
  800e16:	3c 60                	cmp    $0x60,%al
  800e18:	7e 1b                	jle    800e35 <strtol+0xf7>
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	0f b6 00             	movzbl (%eax),%eax
  800e20:	3c 7a                	cmp    $0x7a,%al
  800e22:	7f 11                	jg     800e35 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	0f b6 00             	movzbl (%eax),%eax
  800e2a:	0f be c0             	movsbl %al,%eax
  800e2d:	83 e8 57             	sub    $0x57,%eax
  800e30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e33:	eb 23                	jmp    800e58 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	0f b6 00             	movzbl (%eax),%eax
  800e3b:	3c 40                	cmp    $0x40,%al
  800e3d:	7e 3d                	jle    800e7c <strtol+0x13e>
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	0f b6 00             	movzbl (%eax),%eax
  800e45:	3c 5a                	cmp    $0x5a,%al
  800e47:	7f 33                	jg     800e7c <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	0f b6 00             	movzbl (%eax),%eax
  800e4f:	0f be c0             	movsbl %al,%eax
  800e52:	83 e8 37             	sub    $0x37,%eax
  800e55:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e5e:	7c 02                	jl     800e62 <strtol+0x124>
			break;
  800e60:	eb 1a                	jmp    800e7c <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e62:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e66:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e69:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e72:	01 d0                	add    %edx,%eax
  800e74:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e77:	e9 6f ff ff ff       	jmp    800deb <strtol+0xad>

	if (endptr)
  800e7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e80:	74 08                	je     800e8a <strtol+0x14c>
		*endptr = (char *) s;
  800e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e85:	8b 55 08             	mov    0x8(%ebp),%edx
  800e88:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e8a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e8e:	74 07                	je     800e97 <strtol+0x159>
  800e90:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e93:	f7 d8                	neg    %eax
  800e95:	eb 03                	jmp    800e9a <strtol+0x15c>
  800e97:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	8b 55 10             	mov    0x10(%ebp),%edx
  800eab:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800eae:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800eb1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800eb4:	8b 75 20             	mov    0x20(%ebp),%esi
  800eb7:	cd 30                	int    $0x30
  800eb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec0:	74 30                	je     800ef2 <syscall+0x56>
  800ec2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec6:	7e 2a                	jle    800ef2 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ecb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed6:	c7 44 24 08 a4 1d 80 	movl   $0x801da4,0x8(%esp)
  800edd:	00 
  800ede:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee5:	00 
  800ee6:	c7 04 24 c1 1d 80 00 	movl   $0x801dc1,(%esp)
  800eed:	e8 84 f2 ff ff       	call   800176 <_panic>

	return ret;
  800ef2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800ef5:	83 c4 3c             	add    $0x3c,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f0d:	00 
  800f0e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f15:	00 
  800f16:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f1d:	00 
  800f1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 5f ff ff ff       	call   800e9c <syscall>
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f45:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f54:	00 
  800f55:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f64:	00 
  800f65:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f7c:	e8 1b ff ff ff       	call   800e9c <syscall>
}
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f93:	00 
  800f94:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fab:	00 
  800fac:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb7:	00 
  800fb8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fbf:	e8 d8 fe ff ff       	call   800e9c <syscall>
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fcc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800feb:	00 
  800fec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ffb:	00 
  800ffc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801003:	e8 94 fe ff ff       	call   800e9c <syscall>
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <sys_yield>:

void
sys_yield(void)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801010:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801017:	00 
  801018:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80101f:	00 
  801020:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801027:	00 
  801028:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102f:	00 
  801030:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801037:	00 
  801038:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103f:	00 
  801040:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801047:	e8 50 fe ff ff       	call   800e9c <syscall>
}
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801054:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801057:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105a:	8b 45 08             	mov    0x8(%ebp),%eax
  80105d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801064:	00 
  801065:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80106c:	00 
  80106d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801071:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801075:	89 44 24 08          	mov    %eax,0x8(%esp)
  801079:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801088:	e8 0f fe ff ff       	call   800e9c <syscall>
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801097:	8b 75 18             	mov    0x18(%ebp),%esi
  80109a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80109d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010aa:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010ae:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c1:	00 
  8010c2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010c9:	e8 ce fd ff ff       	call   800e9c <syscall>
}
  8010ce:	83 c4 20             	add    $0x20,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010de:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010f8:	00 
  8010f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801101:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801110:	e8 87 fd ff ff       	call   800e9c <syscall>
}
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80111d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80112a:	00 
  80112b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801132:	00 
  801133:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80113a:	00 
  80113b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80113f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801143:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801152:	e8 45 fd ff ff       	call   800e9c <syscall>
}
  801157:	c9                   	leave  
  801158:	c3                   	ret    

00801159 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80115f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80116c:	00 
  80116d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801174:	00 
  801175:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80117c:	00 
  80117d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801181:	89 44 24 08          	mov    %eax,0x8(%esp)
  801185:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80118c:	00 
  80118d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801194:	e8 03 fd ff ff       	call   800e9c <syscall>
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011a1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011b1:	00 
  8011b2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011b6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011d4:	e8 c3 fc ff ff       	call   800e9c <syscall>
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011f3:	00 
  8011f4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801203:	00 
  801204:	89 44 24 08          	mov    %eax,0x8(%esp)
  801208:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801217:	e8 80 fc ff ff       	call   800e9c <syscall>
}
  80121c:	c9                   	leave  
  80121d:	c3                   	ret    

0080121e <sys_exec>:

void sys_exec(char* buf){
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80122e:	00 
  80122f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801236:	00 
  801237:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80123e:	00 
  80123f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801246:	00 
  801247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80124b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801252:	00 
  801253:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80125a:	e8 3d fc ff ff       	call   800e9c <syscall>
}
  80125f:	c9                   	leave  
  801260:	c3                   	ret    

00801261 <sys_wait>:

void sys_wait(){
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  801267:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80126e:	00 
  80126f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801276:	00 
  801277:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80127e:	00 
  80127f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801286:	00 
  801287:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80128e:	00 
  80128f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801296:	00 
  801297:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80129e:	e8 f9 fb ff ff       	call   800e9c <syscall>
}
  8012a3:	c9                   	leave  
  8012a4:	c3                   	ret    

008012a5 <sys_guest>:

void sys_guest(){
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8012ab:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012b2:	00 
  8012b3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012ba:	00 
  8012bb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012c2:	00 
  8012c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012ca:	00 
  8012cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012da:	00 
  8012db:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8012e2:	e8 b5 fb ff ff       	call   800e9c <syscall>
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	8b 00                	mov    (%eax),%eax
  8012f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8012f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fa:	8b 40 04             	mov    0x4(%eax),%eax
  8012fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801303:	83 e0 02             	and    $0x2,%eax
  801306:	85 c0                	test   %eax,%eax
  801308:	75 23                	jne    80132d <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  80130a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801311:	c7 44 24 08 d0 1d 80 	movl   $0x801dd0,0x8(%esp)
  801318:	00 
  801319:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801320:	00 
  801321:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801328:	e8 49 ee ff ff       	call   800176 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  80132d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801330:	c1 e8 0c             	shr    $0xc,%eax
  801333:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  801336:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801339:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801340:	25 00 08 00 00       	and    $0x800,%eax
  801345:	85 c0                	test   %eax,%eax
  801347:	75 1c                	jne    801365 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  801349:	c7 44 24 08 0c 1e 80 	movl   $0x801e0c,0x8(%esp)
  801350:	00 
  801351:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801358:	00 
  801359:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801360:	e8 11 ee ff ff       	call   800176 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  801365:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80136c:	00 
  80136d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801374:	00 
  801375:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137c:	e8 cd fc ff ff       	call   80104e <sys_page_alloc>
  801381:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801384:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801388:	79 23                	jns    8013ad <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  80138a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80138d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801391:	c7 44 24 08 48 1e 80 	movl   $0x801e48,0x8(%esp)
  801398:	00 
  801399:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8013a0:	00 
  8013a1:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  8013a8:	e8 c9 ed ff ff       	call   800176 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8013ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013bb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013c2:	00 
  8013c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c7:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013ce:	e8 bf f8 ff ff       	call   800c92 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  8013d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013e1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013e8:	00 
  8013e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013f4:	00 
  8013f5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013fc:	00 
  8013fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801404:	e8 86 fc ff ff       	call   80108f <sys_page_map>
  801409:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80140c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801410:	79 23                	jns    801435 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801412:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801415:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801419:	c7 44 24 08 80 1e 80 	movl   $0x801e80,0x8(%esp)
  801420:	00 
  801421:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  801428:	00 
  801429:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801430:	e8 41 ed ff ff       	call   800176 <_panic>
	}

	// panic("pgfault not implemented");
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	56                   	push   %esi
  80143b:	53                   	push   %ebx
  80143c:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  80143f:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  801446:	8b 45 0c             	mov    0xc(%ebp),%eax
  801449:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801450:	25 00 08 00 00       	and    $0x800,%eax
  801455:	85 c0                	test   %eax,%eax
  801457:	75 15                	jne    80146e <duppage+0x37>
  801459:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801463:	83 e0 02             	and    $0x2,%eax
  801466:	85 c0                	test   %eax,%eax
  801468:	0f 84 e0 00 00 00    	je     80154e <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  80146e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801471:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801478:	83 e0 04             	and    $0x4,%eax
  80147b:	85 c0                	test   %eax,%eax
  80147d:	74 04                	je     801483 <duppage+0x4c>
  80147f:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  801483:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801486:	8b 45 0c             	mov    0xc(%ebp),%eax
  801489:	c1 e0 0c             	shl    $0xc,%eax
  80148c:	89 c1                	mov    %eax,%ecx
  80148e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801491:	c1 e0 0c             	shl    $0xc,%eax
  801494:	89 c2                	mov    %eax,%edx
  801496:	a1 08 30 80 00       	mov    0x803008,%eax
  80149b:	8b 40 48             	mov    0x48(%eax),%eax
  80149e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014a2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 d6 fb ff ff       	call   80108f <sys_page_map>
  8014b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014c0:	79 23                	jns    8014e5 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014c9:	c7 44 24 08 b4 1e 80 	movl   $0x801eb4,0x8(%esp)
  8014d0:	00 
  8014d1:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8014d8:	00 
  8014d9:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  8014e0:	e8 91 ec ff ff       	call   800176 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014e5:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8014e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014eb:	c1 e0 0c             	shl    $0xc,%eax
  8014ee:	89 c3                	mov    %eax,%ebx
  8014f0:	a1 08 30 80 00       	mov    0x803008,%eax
  8014f5:	8b 48 48             	mov    0x48(%eax),%ecx
  8014f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fb:	c1 e0 0c             	shl    $0xc,%eax
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	a1 08 30 80 00       	mov    0x803008,%eax
  801505:	8b 40 48             	mov    0x48(%eax),%eax
  801508:	89 74 24 10          	mov    %esi,0x10(%esp)
  80150c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801510:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801514:	89 54 24 04          	mov    %edx,0x4(%esp)
  801518:	89 04 24             	mov    %eax,(%esp)
  80151b:	e8 6f fb ff ff       	call   80108f <sys_page_map>
  801520:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801523:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801527:	79 23                	jns    80154c <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801530:	c7 44 24 08 f0 1e 80 	movl   $0x801ef0,0x8(%esp)
  801537:	00 
  801538:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80153f:	00 
  801540:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801547:	e8 2a ec ff ff       	call   800176 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80154c:	eb 70                	jmp    8015be <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  80154e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801551:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801558:	25 ff 0f 00 00       	and    $0xfff,%eax
  80155d:	89 c3                	mov    %eax,%ebx
  80155f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801562:	c1 e0 0c             	shl    $0xc,%eax
  801565:	89 c1                	mov    %eax,%ecx
  801567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156a:	c1 e0 0c             	shl    $0xc,%eax
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	a1 08 30 80 00       	mov    0x803008,%eax
  801574:	8b 40 48             	mov    0x48(%eax),%eax
  801577:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80157b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80157f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801582:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801586:	89 54 24 04          	mov    %edx,0x4(%esp)
  80158a:	89 04 24             	mov    %eax,(%esp)
  80158d:	e8 fd fa ff ff       	call   80108f <sys_page_map>
  801592:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801595:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801599:	79 23                	jns    8015be <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a2:	c7 44 24 08 20 1f 80 	movl   $0x801f20,0x8(%esp)
  8015a9:	00 
  8015aa:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8015b1:	00 
  8015b2:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  8015b9:	e8 b8 eb ff ff       	call   800176 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  8015be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c3:	83 c4 30             	add    $0x30,%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    

008015ca <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8015d0:	c7 04 24 e9 12 80 00 	movl   $0x8012e9,(%esp)
  8015d7:	e8 a2 01 00 00       	call   80177e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015dc:	b8 07 00 00 00       	mov    $0x7,%eax
  8015e1:	cd 30                	int    $0x30
  8015e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8015e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8015e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8015ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015f0:	79 23                	jns    801615 <fork+0x4b>
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f9:	c7 44 24 08 58 1f 80 	movl   $0x801f58,0x8(%esp)
  801600:	00 
  801601:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  801608:	00 
  801609:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801610:	e8 61 eb ff ff       	call   800176 <_panic>
	else if(childeid == 0){
  801615:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801619:	75 29                	jne    801644 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80161b:	e8 a6 f9 ff ff       	call   800fc6 <sys_getenvid>
  801620:	25 ff 03 00 00       	and    $0x3ff,%eax
  801625:	c1 e0 02             	shl    $0x2,%eax
  801628:	89 c2                	mov    %eax,%edx
  80162a:	c1 e2 05             	shl    $0x5,%edx
  80162d:	29 c2                	sub    %eax,%edx
  80162f:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  801635:	a3 08 30 80 00       	mov    %eax,0x803008
		// set_pgfault_handler(pgfault);
		return 0;
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
  80163f:	e9 16 01 00 00       	jmp    80175a <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801644:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80164b:	eb 3b                	jmp    801688 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  80164d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801650:	c1 f8 0a             	sar    $0xa,%eax
  801653:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80165a:	83 e0 01             	and    $0x1,%eax
  80165d:	85 c0                	test   %eax,%eax
  80165f:	74 23                	je     801684 <fork+0xba>
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80166b:	83 e0 01             	and    $0x1,%eax
  80166e:	85 c0                	test   %eax,%eax
  801670:	74 12                	je     801684 <fork+0xba>
			duppage(childeid, i);
  801672:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801675:	89 44 24 04          	mov    %eax,0x4(%esp)
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	89 04 24             	mov    %eax,(%esp)
  80167f:	e8 b3 fd ff ff       	call   801437 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801684:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168b:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801690:	76 bb                	jbe    80164d <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801692:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801699:	00 
  80169a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016a1:	ee 
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	89 04 24             	mov    %eax,(%esp)
  8016a8:	e8 a1 f9 ff ff       	call   80104e <sys_page_alloc>
  8016ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016b4:	79 23                	jns    8016d9 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8016b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016bd:	c7 44 24 08 80 1f 80 	movl   $0x801f80,0x8(%esp)
  8016c4:	00 
  8016c5:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8016cc:	00 
  8016cd:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  8016d4:	e8 9d ea ff ff       	call   800176 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  8016d9:	c7 44 24 04 f4 17 80 	movl   $0x8017f4,0x4(%esp)
  8016e0:	00 
  8016e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e4:	89 04 24             	mov    %eax,(%esp)
  8016e7:	e8 6d fa ff ff       	call   801159 <sys_env_set_pgfault_upcall>
  8016ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016f3:	79 23                	jns    801718 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8016f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016fc:	c7 44 24 08 a8 1f 80 	movl   $0x801fa8,0x8(%esp)
  801703:	00 
  801704:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80170b:	00 
  80170c:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801713:	e8 5e ea ff ff       	call   800176 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  801718:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80171f:	00 
  801720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 ec f9 ff ff       	call   801117 <sys_env_set_status>
  80172b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80172e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801732:	79 23                	jns    801757 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  801734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801737:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80173b:	c7 44 24 08 dc 1f 80 	movl   $0x801fdc,0x8(%esp)
  801742:	00 
  801743:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80174a:	00 
  80174b:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801752:	e8 1f ea ff ff       	call   800176 <_panic>
	}
	return childeid;
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <sfork>:

// Challenge!
int
sfork(void)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801762:	c7 44 24 08 05 20 80 	movl   $0x802005,0x8(%esp)
  801769:	00 
  80176a:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801771:	00 
  801772:	c7 04 24 00 1e 80 00 	movl   $0x801e00,(%esp)
  801779:	e8 f8 e9 ff ff       	call   800176 <_panic>

0080177e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801784:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801789:	85 c0                	test   %eax,%eax
  80178b:	75 5d                	jne    8017ea <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80178d:	a1 08 30 80 00       	mov    0x803008,%eax
  801792:	8b 40 48             	mov    0x48(%eax),%eax
  801795:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80179c:	00 
  80179d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017a4:	ee 
  8017a5:	89 04 24             	mov    %eax,(%esp)
  8017a8:	e8 a1 f8 ff ff       	call   80104e <sys_page_alloc>
  8017ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8017b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017b4:	79 1c                	jns    8017d2 <set_pgfault_handler+0x54>
  8017b6:	c7 44 24 08 1c 20 80 	movl   $0x80201c,0x8(%esp)
  8017bd:	00 
  8017be:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8017c5:	00 
  8017c6:	c7 04 24 48 20 80 00 	movl   $0x802048,(%esp)
  8017cd:	e8 a4 e9 ff ff       	call   800176 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8017d2:	a1 08 30 80 00       	mov    0x803008,%eax
  8017d7:	8b 40 48             	mov    0x48(%eax),%eax
  8017da:	c7 44 24 04 f4 17 80 	movl   $0x8017f4,0x4(%esp)
  8017e1:	00 
  8017e2:	89 04 24             	mov    %eax,(%esp)
  8017e5:	e8 6f f9 ff ff       	call   801159 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017f5:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  8017fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8017fc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8017ff:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801803:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801805:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801809:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80180a:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80180d:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  80180f:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801810:	58                   	pop    %eax
	popal 						// pop all the registers
  801811:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801812:	83 c4 04             	add    $0x4,%esp
	popfl
  801815:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801816:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801817:	c3                   	ret    
  801818:	66 90                	xchg   %ax,%ax
  80181a:	66 90                	xchg   %ax,%ax
  80181c:	66 90                	xchg   %ax,%ax
  80181e:	66 90                	xchg   %ax,%ax

00801820 <__udivdi3>:
  801820:	55                   	push   %ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	8b 44 24 28          	mov    0x28(%esp),%eax
  80182a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80182e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801832:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801836:	85 c0                	test   %eax,%eax
  801838:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80183c:	89 ea                	mov    %ebp,%edx
  80183e:	89 0c 24             	mov    %ecx,(%esp)
  801841:	75 2d                	jne    801870 <__udivdi3+0x50>
  801843:	39 e9                	cmp    %ebp,%ecx
  801845:	77 61                	ja     8018a8 <__udivdi3+0x88>
  801847:	85 c9                	test   %ecx,%ecx
  801849:	89 ce                	mov    %ecx,%esi
  80184b:	75 0b                	jne    801858 <__udivdi3+0x38>
  80184d:	b8 01 00 00 00       	mov    $0x1,%eax
  801852:	31 d2                	xor    %edx,%edx
  801854:	f7 f1                	div    %ecx
  801856:	89 c6                	mov    %eax,%esi
  801858:	31 d2                	xor    %edx,%edx
  80185a:	89 e8                	mov    %ebp,%eax
  80185c:	f7 f6                	div    %esi
  80185e:	89 c5                	mov    %eax,%ebp
  801860:	89 f8                	mov    %edi,%eax
  801862:	f7 f6                	div    %esi
  801864:	89 ea                	mov    %ebp,%edx
  801866:	83 c4 0c             	add    $0xc,%esp
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    
  80186d:	8d 76 00             	lea    0x0(%esi),%esi
  801870:	39 e8                	cmp    %ebp,%eax
  801872:	77 24                	ja     801898 <__udivdi3+0x78>
  801874:	0f bd e8             	bsr    %eax,%ebp
  801877:	83 f5 1f             	xor    $0x1f,%ebp
  80187a:	75 3c                	jne    8018b8 <__udivdi3+0x98>
  80187c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801880:	39 34 24             	cmp    %esi,(%esp)
  801883:	0f 86 9f 00 00 00    	jbe    801928 <__udivdi3+0x108>
  801889:	39 d0                	cmp    %edx,%eax
  80188b:	0f 82 97 00 00 00    	jb     801928 <__udivdi3+0x108>
  801891:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801898:	31 d2                	xor    %edx,%edx
  80189a:	31 c0                	xor    %eax,%eax
  80189c:	83 c4 0c             	add    $0xc,%esp
  80189f:	5e                   	pop    %esi
  8018a0:	5f                   	pop    %edi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    
  8018a3:	90                   	nop
  8018a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	89 f8                	mov    %edi,%eax
  8018aa:	f7 f1                	div    %ecx
  8018ac:	31 d2                	xor    %edx,%edx
  8018ae:	83 c4 0c             	add    $0xc,%esp
  8018b1:	5e                   	pop    %esi
  8018b2:	5f                   	pop    %edi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    
  8018b5:	8d 76 00             	lea    0x0(%esi),%esi
  8018b8:	89 e9                	mov    %ebp,%ecx
  8018ba:	8b 3c 24             	mov    (%esp),%edi
  8018bd:	d3 e0                	shl    %cl,%eax
  8018bf:	89 c6                	mov    %eax,%esi
  8018c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8018c6:	29 e8                	sub    %ebp,%eax
  8018c8:	89 c1                	mov    %eax,%ecx
  8018ca:	d3 ef                	shr    %cl,%edi
  8018cc:	89 e9                	mov    %ebp,%ecx
  8018ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018d2:	8b 3c 24             	mov    (%esp),%edi
  8018d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018d9:	89 d6                	mov    %edx,%esi
  8018db:	d3 e7                	shl    %cl,%edi
  8018dd:	89 c1                	mov    %eax,%ecx
  8018df:	89 3c 24             	mov    %edi,(%esp)
  8018e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018e6:	d3 ee                	shr    %cl,%esi
  8018e8:	89 e9                	mov    %ebp,%ecx
  8018ea:	d3 e2                	shl    %cl,%edx
  8018ec:	89 c1                	mov    %eax,%ecx
  8018ee:	d3 ef                	shr    %cl,%edi
  8018f0:	09 d7                	or     %edx,%edi
  8018f2:	89 f2                	mov    %esi,%edx
  8018f4:	89 f8                	mov    %edi,%eax
  8018f6:	f7 74 24 08          	divl   0x8(%esp)
  8018fa:	89 d6                	mov    %edx,%esi
  8018fc:	89 c7                	mov    %eax,%edi
  8018fe:	f7 24 24             	mull   (%esp)
  801901:	39 d6                	cmp    %edx,%esi
  801903:	89 14 24             	mov    %edx,(%esp)
  801906:	72 30                	jb     801938 <__udivdi3+0x118>
  801908:	8b 54 24 04          	mov    0x4(%esp),%edx
  80190c:	89 e9                	mov    %ebp,%ecx
  80190e:	d3 e2                	shl    %cl,%edx
  801910:	39 c2                	cmp    %eax,%edx
  801912:	73 05                	jae    801919 <__udivdi3+0xf9>
  801914:	3b 34 24             	cmp    (%esp),%esi
  801917:	74 1f                	je     801938 <__udivdi3+0x118>
  801919:	89 f8                	mov    %edi,%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	e9 7a ff ff ff       	jmp    80189c <__udivdi3+0x7c>
  801922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801928:	31 d2                	xor    %edx,%edx
  80192a:	b8 01 00 00 00       	mov    $0x1,%eax
  80192f:	e9 68 ff ff ff       	jmp    80189c <__udivdi3+0x7c>
  801934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801938:	8d 47 ff             	lea    -0x1(%edi),%eax
  80193b:	31 d2                	xor    %edx,%edx
  80193d:	83 c4 0c             	add    $0xc,%esp
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    
  801944:	66 90                	xchg   %ax,%ax
  801946:	66 90                	xchg   %ax,%ax
  801948:	66 90                	xchg   %ax,%ax
  80194a:	66 90                	xchg   %ax,%ax
  80194c:	66 90                	xchg   %ax,%ax
  80194e:	66 90                	xchg   %ax,%ax

00801950 <__umoddi3>:
  801950:	55                   	push   %ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	83 ec 14             	sub    $0x14,%esp
  801956:	8b 44 24 28          	mov    0x28(%esp),%eax
  80195a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80195e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801962:	89 c7                	mov    %eax,%edi
  801964:	89 44 24 04          	mov    %eax,0x4(%esp)
  801968:	8b 44 24 30          	mov    0x30(%esp),%eax
  80196c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801970:	89 34 24             	mov    %esi,(%esp)
  801973:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801977:	85 c0                	test   %eax,%eax
  801979:	89 c2                	mov    %eax,%edx
  80197b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80197f:	75 17                	jne    801998 <__umoddi3+0x48>
  801981:	39 fe                	cmp    %edi,%esi
  801983:	76 4b                	jbe    8019d0 <__umoddi3+0x80>
  801985:	89 c8                	mov    %ecx,%eax
  801987:	89 fa                	mov    %edi,%edx
  801989:	f7 f6                	div    %esi
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	31 d2                	xor    %edx,%edx
  80198f:	83 c4 14             	add    $0x14,%esp
  801992:	5e                   	pop    %esi
  801993:	5f                   	pop    %edi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    
  801996:	66 90                	xchg   %ax,%ax
  801998:	39 f8                	cmp    %edi,%eax
  80199a:	77 54                	ja     8019f0 <__umoddi3+0xa0>
  80199c:	0f bd e8             	bsr    %eax,%ebp
  80199f:	83 f5 1f             	xor    $0x1f,%ebp
  8019a2:	75 5c                	jne    801a00 <__umoddi3+0xb0>
  8019a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8019a8:	39 3c 24             	cmp    %edi,(%esp)
  8019ab:	0f 87 e7 00 00 00    	ja     801a98 <__umoddi3+0x148>
  8019b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019b5:	29 f1                	sub    %esi,%ecx
  8019b7:	19 c7                	sbb    %eax,%edi
  8019b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8019c9:	83 c4 14             	add    $0x14,%esp
  8019cc:	5e                   	pop    %esi
  8019cd:	5f                   	pop    %edi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    
  8019d0:	85 f6                	test   %esi,%esi
  8019d2:	89 f5                	mov    %esi,%ebp
  8019d4:	75 0b                	jne    8019e1 <__umoddi3+0x91>
  8019d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019db:	31 d2                	xor    %edx,%edx
  8019dd:	f7 f6                	div    %esi
  8019df:	89 c5                	mov    %eax,%ebp
  8019e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019e5:	31 d2                	xor    %edx,%edx
  8019e7:	f7 f5                	div    %ebp
  8019e9:	89 c8                	mov    %ecx,%eax
  8019eb:	f7 f5                	div    %ebp
  8019ed:	eb 9c                	jmp    80198b <__umoddi3+0x3b>
  8019ef:	90                   	nop
  8019f0:	89 c8                	mov    %ecx,%eax
  8019f2:	89 fa                	mov    %edi,%edx
  8019f4:	83 c4 14             	add    $0x14,%esp
  8019f7:	5e                   	pop    %esi
  8019f8:	5f                   	pop    %edi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    
  8019fb:	90                   	nop
  8019fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a00:	8b 04 24             	mov    (%esp),%eax
  801a03:	be 20 00 00 00       	mov    $0x20,%esi
  801a08:	89 e9                	mov    %ebp,%ecx
  801a0a:	29 ee                	sub    %ebp,%esi
  801a0c:	d3 e2                	shl    %cl,%edx
  801a0e:	89 f1                	mov    %esi,%ecx
  801a10:	d3 e8                	shr    %cl,%eax
  801a12:	89 e9                	mov    %ebp,%ecx
  801a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a18:	8b 04 24             	mov    (%esp),%eax
  801a1b:	09 54 24 04          	or     %edx,0x4(%esp)
  801a1f:	89 fa                	mov    %edi,%edx
  801a21:	d3 e0                	shl    %cl,%eax
  801a23:	89 f1                	mov    %esi,%ecx
  801a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a2d:	d3 ea                	shr    %cl,%edx
  801a2f:	89 e9                	mov    %ebp,%ecx
  801a31:	d3 e7                	shl    %cl,%edi
  801a33:	89 f1                	mov    %esi,%ecx
  801a35:	d3 e8                	shr    %cl,%eax
  801a37:	89 e9                	mov    %ebp,%ecx
  801a39:	09 f8                	or     %edi,%eax
  801a3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a3f:	f7 74 24 04          	divl   0x4(%esp)
  801a43:	d3 e7                	shl    %cl,%edi
  801a45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a49:	89 d7                	mov    %edx,%edi
  801a4b:	f7 64 24 08          	mull   0x8(%esp)
  801a4f:	39 d7                	cmp    %edx,%edi
  801a51:	89 c1                	mov    %eax,%ecx
  801a53:	89 14 24             	mov    %edx,(%esp)
  801a56:	72 2c                	jb     801a84 <__umoddi3+0x134>
  801a58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a5c:	72 22                	jb     801a80 <__umoddi3+0x130>
  801a5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a62:	29 c8                	sub    %ecx,%eax
  801a64:	19 d7                	sbb    %edx,%edi
  801a66:	89 e9                	mov    %ebp,%ecx
  801a68:	89 fa                	mov    %edi,%edx
  801a6a:	d3 e8                	shr    %cl,%eax
  801a6c:	89 f1                	mov    %esi,%ecx
  801a6e:	d3 e2                	shl    %cl,%edx
  801a70:	89 e9                	mov    %ebp,%ecx
  801a72:	d3 ef                	shr    %cl,%edi
  801a74:	09 d0                	or     %edx,%eax
  801a76:	89 fa                	mov    %edi,%edx
  801a78:	83 c4 14             	add    $0x14,%esp
  801a7b:	5e                   	pop    %esi
  801a7c:	5f                   	pop    %edi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    
  801a7f:	90                   	nop
  801a80:	39 d7                	cmp    %edx,%edi
  801a82:	75 da                	jne    801a5e <__umoddi3+0x10e>
  801a84:	8b 14 24             	mov    (%esp),%edx
  801a87:	89 c1                	mov    %eax,%ecx
  801a89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801a91:	eb cb                	jmp    801a5e <__umoddi3+0x10e>
  801a93:	90                   	nop
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801a9c:	0f 82 0f ff ff ff    	jb     8019b1 <__umoddi3+0x61>
  801aa2:	e9 1a ff ff ff       	jmp    8019c1 <__umoddi3+0x71>
