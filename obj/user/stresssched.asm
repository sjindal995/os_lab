
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
  800039:	e8 98 0f 00 00       	call   800fd6 <sys_getenvid>
  80003e:	89 45 ec             	mov    %eax,-0x14(%ebp)

	// Fork several environments
	for (i = 0; i < 20; i++)
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800048:	eb 0f                	jmp    800059 <umain+0x26>
		if (fork() == 0)
  80004a:	e8 c0 14 00 00       	call   80150f <fork>
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
  800065:	e8 b0 0f 00 00       	call   80101a <sys_yield>
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
  80009a:	e8 7b 0f 00 00       	call   80101a <sys_yield>
		for (j = 0; j < 10000; j++)
  80009f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000a6:	eb 11                	jmp    8000b9 <umain+0x86>
			counter++;
  8000a8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ad:	83 c0 01             	add    $0x1,%eax
  8000b0:	a3 04 20 80 00       	mov    %eax,0x802004
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
  8000cc:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d1:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d6:	74 25                	je     8000fd <umain+0xca>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d8:	a1 04 20 80 00       	mov    0x802004,%eax
  8000dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e1:	c7 44 24 08 00 1a 80 	movl   $0x801a00,0x8(%esp)
  8000e8:	00 
  8000e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f0:	00 
  8000f1:	c7 04 24 28 1a 80 00 	movl   $0x801a28,(%esp)
  8000f8:	e8 89 00 00 00       	call   800186 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000fd:	a1 08 20 80 00       	mov    0x802008,%eax
  800102:	8b 50 5c             	mov    0x5c(%eax),%edx
  800105:	a1 08 20 80 00       	mov    0x802008,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800111:	89 44 24 04          	mov    %eax,0x4(%esp)
  800115:	c7 04 24 3b 1a 80 00 	movl   $0x801a3b,(%esp)
  80011c:	e8 80 01 00 00       	call   8002a1 <cprintf>

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
  800129:	e8 a8 0e 00 00       	call   800fd6 <sys_getenvid>
  80012e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800133:	c1 e0 02             	shl    $0x2,%eax
  800136:	89 c2                	mov    %eax,%edx
  800138:	c1 e2 05             	shl    $0x5,%edx
  80013b:	29 c2                	sub    %eax,%edx
  80013d:	89 d0                	mov    %edx,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80014d:	7e 0a                	jle    800159 <libmain+0x36>
		binaryname = argv[0];
  80014f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800152:	8b 00                	mov    (%eax),%eax
  800154:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800159:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	8b 45 08             	mov    0x8(%ebp),%eax
  800163:	89 04 24             	mov    %eax,(%esp)
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 02 00 00 00       	call   800172 <exit>
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017f:	e8 0f 0e 00 00       	call   800f93 <sys_env_destroy>
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	53                   	push   %ebx
  80018a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80018d:	8d 45 14             	lea    0x14(%ebp),%eax
  800190:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800199:	e8 38 0e 00 00       	call   800fd6 <sys_getenvid>
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 64 1a 80 00 	movl   $0x801a64,(%esp)
  8001bb:	e8 e1 00 00 00       	call   8002a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 6b 00 00 00       	call   80023d <vcprintf>
	cprintf("\n");
  8001d2:	c7 04 24 87 1a 80 00 	movl   $0x801a87,(%esp)
  8001d9:	e8 c3 00 00 00       	call   8002a1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001de:	cc                   	int3   
  8001df:	eb fd                	jmp    8001de <_panic+0x58>

008001e1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ea:	8b 00                	mov    (%eax),%eax
  8001ec:	8d 48 01             	lea    0x1(%eax),%ecx
  8001ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f2:	89 0a                	mov    %ecx,(%edx)
  8001f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f7:	89 d1                	mov    %edx,%ecx
  8001f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fc:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	8b 00                	mov    (%eax),%eax
  800205:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020a:	75 20                	jne    80022c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	8b 00                	mov    (%eax),%eax
  800211:	8b 55 0c             	mov    0xc(%ebp),%edx
  800214:	83 c2 08             	add    $0x8,%edx
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	89 14 24             	mov    %edx,(%esp)
  80021e:	e8 ea 0c 00 00       	call   800f0d <sys_cputs>
		b->idx = 0;
  800223:	8b 45 0c             	mov    0xc(%ebp),%eax
  800226:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	8b 40 04             	mov    0x4(%eax),%eax
  800232:	8d 50 01             	lea    0x1(%eax),%edx
  800235:	8b 45 0c             	mov    0xc(%ebp),%eax
  800238:	89 50 04             	mov    %edx,0x4(%eax)
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800246:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024d:	00 00 00 
	b.cnt = 0;
  800250:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800257:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800272:	c7 04 24 e1 01 80 00 	movl   $0x8001e1,(%esp)
  800279:	e8 bd 01 00 00       	call   80043b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028e:	83 c0 08             	add    $0x8,%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 74 0c 00 00       	call   800f0d <sys_cputs>

	return b.cnt;
  800299:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	e8 7e ff ff ff       	call   80023d <vcprintf>
  8002bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 34             	sub    $0x34,%esp
  8002ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002da:	8b 45 18             	mov    0x18(%ebp),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e5:	77 72                	ja     800359 <printnum+0x92>
  8002e7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ea:	72 05                	jb     8002f1 <printnum+0x2a>
  8002ec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002ef:	77 68                	ja     800359 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f1:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002f4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f7:	8b 45 18             	mov    0x18(%ebp),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80030a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80030d:	89 04 24             	mov    %eax,(%esp)
  800310:	89 54 24 04          	mov    %edx,0x4(%esp)
  800314:	e8 47 14 00 00       	call   801760 <__udivdi3>
  800319:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80031c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800320:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800324:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800327:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80032b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
  800336:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033a:	8b 45 08             	mov    0x8(%ebp),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	e8 82 ff ff ff       	call   8002c7 <printnum>
  800345:	eb 1c                	jmp    800363 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800347:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034e:	8b 45 20             	mov    0x20(%ebp),%eax
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	8b 45 08             	mov    0x8(%ebp),%eax
  800357:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800359:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80035d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800361:	7f e4                	jg     800347 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800363:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800366:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80036e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800371:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800375:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800380:	e8 0b 15 00 00       	call   801890 <__umoddi3>
  800385:	05 68 1b 80 00       	add    $0x801b68,%eax
  80038a:	0f b6 00             	movzbl (%eax),%eax
  80038d:	0f be c0             	movsbl %al,%eax
  800390:	8b 55 0c             	mov    0xc(%ebp),%edx
  800393:	89 54 24 04          	mov    %edx,0x4(%esp)
  800397:	89 04 24             	mov    %eax,(%esp)
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	ff d0                	call   *%eax
}
  80039f:	83 c4 34             	add    $0x34,%esp
  8003a2:	5b                   	pop    %ebx
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003ac:	7e 14                	jle    8003c2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	8d 48 08             	lea    0x8(%eax),%ecx
  8003b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b9:	89 0a                	mov    %ecx,(%edx)
  8003bb:	8b 50 04             	mov    0x4(%eax),%edx
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	eb 30                	jmp    8003f2 <getuint+0x4d>
	else if (lflag)
  8003c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003c6:	74 16                	je     8003de <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d3:	89 0a                	mov    %ecx,(%edx)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 14                	jmp    8003f2 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e9:	89 0a                	mov    %ecx,(%edx)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003fb:	7e 14                	jle    800411 <getint+0x1d>
		return va_arg(*ap, long long);
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	8b 00                	mov    (%eax),%eax
  800402:	8d 48 08             	lea    0x8(%eax),%ecx
  800405:	8b 55 08             	mov    0x8(%ebp),%edx
  800408:	89 0a                	mov    %ecx,(%edx)
  80040a:	8b 50 04             	mov    0x4(%eax),%edx
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	eb 28                	jmp    800439 <getint+0x45>
	else if (lflag)
  800411:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800415:	74 12                	je     800429 <getint+0x35>
		return va_arg(*ap, long);
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	8d 48 04             	lea    0x4(%eax),%ecx
  80041f:	8b 55 08             	mov    0x8(%ebp),%edx
  800422:	89 0a                	mov    %ecx,(%edx)
  800424:	8b 00                	mov    (%eax),%eax
  800426:	99                   	cltd   
  800427:	eb 10                	jmp    800439 <getint+0x45>
	else
		return va_arg(*ap, int);
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	8d 48 04             	lea    0x4(%eax),%ecx
  800431:	8b 55 08             	mov    0x8(%ebp),%edx
  800434:	89 0a                	mov    %ecx,(%edx)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
}
  800439:	5d                   	pop    %ebp
  80043a:	c3                   	ret    

0080043b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
  800440:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800443:	eb 18                	jmp    80045d <vprintfmt+0x22>
			if (ch == '\0')
  800445:	85 db                	test   %ebx,%ebx
  800447:	75 05                	jne    80044e <vprintfmt+0x13>
				return;
  800449:	e9 cc 03 00 00       	jmp    80081a <vprintfmt+0x3df>
			putch(ch, putdat);
  80044e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	89 1c 24             	mov    %ebx,(%esp)
  800458:	8b 45 08             	mov    0x8(%ebp),%eax
  80045b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80045d:	8b 45 10             	mov    0x10(%ebp),%eax
  800460:	8d 50 01             	lea    0x1(%eax),%edx
  800463:	89 55 10             	mov    %edx,0x10(%ebp)
  800466:	0f b6 00             	movzbl (%eax),%eax
  800469:	0f b6 d8             	movzbl %al,%ebx
  80046c:	83 fb 25             	cmp    $0x25,%ebx
  80046f:	75 d4                	jne    800445 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800471:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800475:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80047c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800483:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80048a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 45 10             	mov    0x10(%ebp),%eax
  800494:	8d 50 01             	lea    0x1(%eax),%edx
  800497:	89 55 10             	mov    %edx,0x10(%ebp)
  80049a:	0f b6 00             	movzbl (%eax),%eax
  80049d:	0f b6 d8             	movzbl %al,%ebx
  8004a0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004a3:	83 f8 55             	cmp    $0x55,%eax
  8004a6:	0f 87 3d 03 00 00    	ja     8007e9 <vprintfmt+0x3ae>
  8004ac:	8b 04 85 8c 1b 80 00 	mov    0x801b8c(,%eax,4),%eax
  8004b3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004b9:	eb d6                	jmp    800491 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004bb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004bf:	eb d0                	jmp    800491 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004cb:	89 d0                	mov    %edx,%eax
  8004cd:	c1 e0 02             	shl    $0x2,%eax
  8004d0:	01 d0                	add    %edx,%eax
  8004d2:	01 c0                	add    %eax,%eax
  8004d4:	01 d8                	add    %ebx,%eax
  8004d6:	83 e8 30             	sub    $0x30,%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004df:	0f b6 00             	movzbl (%eax),%eax
  8004e2:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004e5:	83 fb 2f             	cmp    $0x2f,%ebx
  8004e8:	7e 0b                	jle    8004f5 <vprintfmt+0xba>
  8004ea:	83 fb 39             	cmp    $0x39,%ebx
  8004ed:	7f 06                	jg     8004f5 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ef:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f3:	eb d3                	jmp    8004c8 <vprintfmt+0x8d>
			goto process_precision;
  8004f5:	eb 33                	jmp    80052a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 50 04             	lea    0x4(%eax),%edx
  8004fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800505:	eb 23                	jmp    80052a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050b:	79 0c                	jns    800519 <vprintfmt+0xde>
				width = 0;
  80050d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800514:	e9 78 ff ff ff       	jmp    800491 <vprintfmt+0x56>
  800519:	e9 73 ff ff ff       	jmp    800491 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80051e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800525:	e9 67 ff ff ff       	jmp    800491 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80052a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052e:	79 12                	jns    800542 <vprintfmt+0x107>
				width = precision, precision = -1;
  800530:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800536:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80053d:	e9 4f ff ff ff       	jmp    800491 <vprintfmt+0x56>
  800542:	e9 4a ff ff ff       	jmp    800491 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800547:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80054b:	e9 41 ff ff ff       	jmp    800491 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 50 04             	lea    0x4(%eax),%edx
  800556:	89 55 14             	mov    %edx,0x14(%ebp)
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	8b 45 08             	mov    0x8(%ebp),%eax
  800568:	ff d0                	call   *%eax
			break;
  80056a:	e9 a5 02 00 00       	jmp    800814 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80057a:	85 db                	test   %ebx,%ebx
  80057c:	79 02                	jns    800580 <vprintfmt+0x145>
				err = -err;
  80057e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800580:	83 fb 09             	cmp    $0x9,%ebx
  800583:	7f 0b                	jg     800590 <vprintfmt+0x155>
  800585:	8b 34 9d 40 1b 80 00 	mov    0x801b40(,%ebx,4),%esi
  80058c:	85 f6                	test   %esi,%esi
  80058e:	75 23                	jne    8005b3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800590:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800594:	c7 44 24 08 79 1b 80 	movl   $0x801b79,0x8(%esp)
  80059b:	00 
  80059c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	e8 73 02 00 00       	call   800821 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005ae:	e9 61 02 00 00       	jmp    800814 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005b7:	c7 44 24 08 82 1b 80 	movl   $0x801b82,0x8(%esp)
  8005be:	00 
  8005bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c9:	89 04 24             	mov    %eax,(%esp)
  8005cc:	e8 50 02 00 00       	call   800821 <printfmt>
			break;
  8005d1:	e9 3e 02 00 00       	jmp    800814 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 30                	mov    (%eax),%esi
  8005e1:	85 f6                	test   %esi,%esi
  8005e3:	75 05                	jne    8005ea <vprintfmt+0x1af>
				p = "(null)";
  8005e5:	be 85 1b 80 00       	mov    $0x801b85,%esi
			if (width > 0 && padc != '-')
  8005ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ee:	7e 37                	jle    800627 <vprintfmt+0x1ec>
  8005f0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005f4:	74 31                	je     800627 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	89 34 24             	mov    %esi,(%esp)
  800600:	e8 39 03 00 00       	call   80093e <strnlen>
  800605:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800608:	eb 17                	jmp    800621 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80060a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80060e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800611:	89 54 24 04          	mov    %edx,0x4(%esp)
  800615:	89 04 24             	mov    %eax,(%esp)
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800621:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800625:	7f e3                	jg     80060a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800627:	eb 38                	jmp    800661 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062d:	74 1f                	je     80064e <vprintfmt+0x213>
  80062f:	83 fb 1f             	cmp    $0x1f,%ebx
  800632:	7e 05                	jle    800639 <vprintfmt+0x1fe>
  800634:	83 fb 7e             	cmp    $0x7e,%ebx
  800637:	7e 15                	jle    80064e <vprintfmt+0x213>
					putch('?', putdat);
  800639:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800647:	8b 45 08             	mov    0x8(%ebp),%eax
  80064a:	ff d0                	call   *%eax
  80064c:	eb 0f                	jmp    80065d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80064e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800651:	89 44 24 04          	mov    %eax,0x4(%esp)
  800655:	89 1c 24             	mov    %ebx,(%esp)
  800658:	8b 45 08             	mov    0x8(%ebp),%eax
  80065b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800661:	89 f0                	mov    %esi,%eax
  800663:	8d 70 01             	lea    0x1(%eax),%esi
  800666:	0f b6 00             	movzbl (%eax),%eax
  800669:	0f be d8             	movsbl %al,%ebx
  80066c:	85 db                	test   %ebx,%ebx
  80066e:	74 10                	je     800680 <vprintfmt+0x245>
  800670:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800674:	78 b3                	js     800629 <vprintfmt+0x1ee>
  800676:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80067a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067e:	79 a9                	jns    800629 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	eb 17                	jmp    800699 <vprintfmt+0x25e>
				putch(' ', putdat);
  800682:	8b 45 0c             	mov    0xc(%ebp),%eax
  800685:	89 44 24 04          	mov    %eax,0x4(%esp)
  800689:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800695:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800699:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069d:	7f e3                	jg     800682 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80069f:	e9 70 01 00 00       	jmp    800814 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	89 04 24             	mov    %eax,(%esp)
  8006b1:	e8 3e fd ff ff       	call   8003f4 <getint>
  8006b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c2:	85 d2                	test   %edx,%edx
  8006c4:	79 26                	jns    8006ec <vprintfmt+0x2b1>
				putch('-', putdat);
  8006c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	ff d0                	call   *%eax
				num = -(long long) num;
  8006d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006df:	f7 d8                	neg    %eax
  8006e1:	83 d2 00             	adc    $0x0,%edx
  8006e4:	f7 da                	neg    %edx
  8006e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006ec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006f3:	e9 a8 00 00 00       	jmp    8007a0 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800702:	89 04 24             	mov    %eax,(%esp)
  800705:	e8 9b fc ff ff       	call   8003a5 <getuint>
  80070a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800710:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800717:	e9 84 00 00 00       	jmp    8007a0 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80071c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	89 04 24             	mov    %eax,(%esp)
  800729:	e8 77 fc ff ff       	call   8003a5 <getuint>
  80072e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800731:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800734:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80073b:	eb 63                	jmp    8007a0 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80073d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800740:	89 44 24 04          	mov    %eax,0x4(%esp)
  800744:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	ff d0                	call   *%eax
			putch('x', putdat);
  800750:	8b 45 0c             	mov    0xc(%ebp),%eax
  800753:	89 44 24 04          	mov    %eax,0x4(%esp)
  800757:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80076e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800778:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80077f:	eb 1f                	jmp    8007a0 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800781:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	8d 45 14             	lea    0x14(%ebp),%eax
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	e8 12 fc ff ff       	call   8003a5 <getuint>
  800793:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800796:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800799:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a7:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	89 04 24             	mov    %eax,(%esp)
  8007d1:	e8 f1 fa ff ff       	call   8002c7 <printnum>
			break;
  8007d6:	eb 3c                	jmp    800814 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007df:	89 1c 24             	mov    %ebx,(%esp)
  8007e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e5:	ff d0                	call   *%eax
			break;
  8007e7:	eb 2b                	jmp    800814 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800800:	eb 04                	jmp    800806 <vprintfmt+0x3cb>
  800802:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800806:	8b 45 10             	mov    0x10(%ebp),%eax
  800809:	83 e8 01             	sub    $0x1,%eax
  80080c:	0f b6 00             	movzbl (%eax),%eax
  80080f:	3c 25                	cmp    $0x25,%al
  800811:	75 ef                	jne    800802 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800813:	90                   	nop
		}
	}
  800814:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800815:	e9 43 fc ff ff       	jmp    80045d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80081a:	83 c4 40             	add    $0x40,%esp
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800827:	8d 45 14             	lea    0x14(%ebp),%eax
  80082a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80082d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800830:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800834:	8b 45 10             	mov    0x10(%ebp),%eax
  800837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	89 04 24             	mov    %eax,(%esp)
  800848:	e8 ee fb ff ff       	call   80043b <vprintfmt>
	va_end(ap);
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800852:	8b 45 0c             	mov    0xc(%ebp),%eax
  800855:	8b 40 08             	mov    0x8(%eax),%eax
  800858:	8d 50 01             	lea    0x1(%eax),%edx
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	8b 45 0c             	mov    0xc(%ebp),%eax
  800869:	8b 40 04             	mov    0x4(%eax),%eax
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	73 12                	jae    800882 <sprintputch+0x33>
		*b->buf++ = ch;
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
  800873:	8b 00                	mov    (%eax),%eax
  800875:	8d 48 01             	lea    0x1(%eax),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087b:	89 0a                	mov    %ecx,(%edx)
  80087d:	8b 55 08             	mov    0x8(%ebp),%edx
  800880:	88 10                	mov    %dl,(%eax)
}
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800890:	8b 45 0c             	mov    0xc(%ebp),%eax
  800893:	8d 50 ff             	lea    -0x1(%eax),%edx
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	01 d0                	add    %edx,%eax
  80089b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80089e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008a9:	74 06                	je     8008b1 <vsnprintf+0x2d>
  8008ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008af:	7f 07                	jg     8008b8 <vsnprintf+0x34>
		return -E_INVAL;
  8008b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b6:	eb 2a                	jmp    8008e2 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cd:	c7 04 24 4f 08 80 00 	movl   $0x80084f,(%esp)
  8008d4:	e8 62 fb ff ff       	call   80043b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	89 44 24 04          	mov    %eax,0x4(%esp)
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	89 04 24             	mov    %eax,(%esp)
  80090b:	e8 74 ff ff ff       	call   800884 <vsnprintf>
  800910:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800913:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80091e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800925:	eb 08                	jmp    80092f <strlen+0x17>
		n++;
  800927:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80092b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	0f b6 00             	movzbl (%eax),%eax
  800935:	84 c0                	test   %al,%al
  800937:	75 ee                	jne    800927 <strlen+0xf>
		n++;
	return n;
  800939:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800944:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80094b:	eb 0c                	jmp    800959 <strnlen+0x1b>
		n++;
  80094d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800951:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800955:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800959:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80095d:	74 0a                	je     800969 <strnlen+0x2b>
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	0f b6 00             	movzbl (%eax),%eax
  800965:	84 c0                	test   %al,%al
  800967:	75 e4                	jne    80094d <strnlen+0xf>
		n++;
	return n;
  800969:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80097a:	90                   	nop
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8d 50 01             	lea    0x1(%eax),%edx
  800981:	89 55 08             	mov    %edx,0x8(%ebp)
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
  800987:	8d 4a 01             	lea    0x1(%edx),%ecx
  80098a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	88 10                	mov    %dl,(%eax)
  800992:	0f b6 00             	movzbl (%eax),%eax
  800995:	84 c0                	test   %al,%al
  800997:	75 e2                	jne    80097b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800999:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	e8 69 ff ff ff       	call   800918 <strlen>
  8009af:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	01 c2                	add    %eax,%edx
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c1:	89 14 24             	mov    %edx,(%esp)
  8009c4:	e8 a5 ff ff ff       	call   80096e <strcpy>
	return dst;
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009e1:	eb 23                	jmp    800a06 <strncpy+0x38>
		*dst++ = *src;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8d 50 01             	lea    0x1(%eax),%edx
  8009e9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	0f b6 12             	movzbl (%edx),%edx
  8009f2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f7:	0f b6 00             	movzbl (%eax),%eax
  8009fa:	84 c0                	test   %al,%al
  8009fc:	74 04                	je     800a02 <strncpy+0x34>
			src++;
  8009fe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a02:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a06:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a09:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a0c:	72 d5                	jb     8009e3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a23:	74 33                	je     800a58 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a25:	eb 17                	jmp    800a3e <strlcpy+0x2b>
			*dst++ = *src++;
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8d 50 01             	lea    0x1(%eax),%edx
  800a2d:	89 55 08             	mov    %edx,0x8(%ebp)
  800a30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a33:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a36:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a39:	0f b6 12             	movzbl (%edx),%edx
  800a3c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a46:	74 0a                	je     800a52 <strlcpy+0x3f>
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	0f b6 00             	movzbl (%eax),%eax
  800a4e:	84 c0                	test   %al,%al
  800a50:	75 d5                	jne    800a27 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a58:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a5e:	29 c2                	sub    %eax,%edx
  800a60:	89 d0                	mov    %edx,%eax
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a67:	eb 08                	jmp    800a71 <strcmp+0xd>
		p++, q++;
  800a69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a6d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	0f b6 00             	movzbl (%eax),%eax
  800a77:	84 c0                	test   %al,%al
  800a79:	74 10                	je     800a8b <strcmp+0x27>
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	0f b6 00             	movzbl (%eax),%eax
  800a87:	38 c2                	cmp    %al,%dl
  800a89:	74 de                	je     800a69 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	0f b6 00             	movzbl (%eax),%eax
  800a91:	0f b6 d0             	movzbl %al,%edx
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	0f b6 00             	movzbl (%eax),%eax
  800a9a:	0f b6 c0             	movzbl %al,%eax
  800a9d:	29 c2                	sub    %eax,%edx
  800a9f:	89 d0                	mov    %edx,%eax
}
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800aa6:	eb 0c                	jmp    800ab4 <strncmp+0x11>
		n--, p++, q++;
  800aa8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ab0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab8:	74 1a                	je     800ad4 <strncmp+0x31>
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	0f b6 00             	movzbl (%eax),%eax
  800ac0:	84 c0                	test   %al,%al
  800ac2:	74 10                	je     800ad4 <strncmp+0x31>
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	0f b6 10             	movzbl (%eax),%edx
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	0f b6 00             	movzbl (%eax),%eax
  800ad0:	38 c2                	cmp    %al,%dl
  800ad2:	74 d4                	je     800aa8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ad4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ad8:	75 07                	jne    800ae1 <strncmp+0x3e>
		return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	eb 16                	jmp    800af7 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	0f b6 00             	movzbl (%eax),%eax
  800ae7:	0f b6 d0             	movzbl %al,%edx
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	0f b6 00             	movzbl (%eax),%eax
  800af0:	0f b6 c0             	movzbl %al,%eax
  800af3:	29 c2                	sub    %eax,%edx
  800af5:	89 d0                	mov    %edx,%eax
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	83 ec 04             	sub    $0x4,%esp
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b05:	eb 14                	jmp    800b1b <strchr+0x22>
		if (*s == c)
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	0f b6 00             	movzbl (%eax),%eax
  800b0d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b10:	75 05                	jne    800b17 <strchr+0x1e>
			return (char *) s;
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	eb 13                	jmp    800b2a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	0f b6 00             	movzbl (%eax),%eax
  800b21:	84 c0                	test   %al,%al
  800b23:	75 e2                	jne    800b07 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	83 ec 04             	sub    $0x4,%esp
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b38:	eb 11                	jmp    800b4b <strfind+0x1f>
		if (*s == c)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	0f b6 00             	movzbl (%eax),%eax
  800b40:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b43:	75 02                	jne    800b47 <strfind+0x1b>
			break;
  800b45:	eb 0e                	jmp    800b55 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b47:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	0f b6 00             	movzbl (%eax),%eax
  800b51:	84 c0                	test   %al,%al
  800b53:	75 e5                	jne    800b3a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b62:	75 05                	jne    800b69 <memset+0xf>
		return v;
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	eb 5c                	jmp    800bc5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	83 e0 03             	and    $0x3,%eax
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	75 41                	jne    800bb4 <memset+0x5a>
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	83 e0 03             	and    $0x3,%eax
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	75 37                	jne    800bb4 <memset+0x5a>
		c &= 0xFF;
  800b7d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	c1 e0 18             	shl    $0x18,%eax
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8f:	c1 e0 10             	shl    $0x10,%eax
  800b92:	09 c2                	or     %eax,%edx
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b97:	c1 e0 08             	shl    $0x8,%eax
  800b9a:	09 d0                	or     %edx,%eax
  800b9c:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba2:	c1 e8 02             	shr    $0x2,%eax
  800ba5:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	fc                   	cld    
  800bb0:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb2:	eb 0e                	jmp    800bc2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	fc                   	cld    
  800bc0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800be3:	73 6d                	jae    800c52 <memmove+0x8a>
  800be5:	8b 45 10             	mov    0x10(%ebp),%eax
  800be8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800beb:	01 d0                	add    %edx,%eax
  800bed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bf0:	76 60                	jbe    800c52 <memmove+0x8a>
		s += n;
  800bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf5:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfb:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c01:	83 e0 03             	and    $0x3,%eax
  800c04:	85 c0                	test   %eax,%eax
  800c06:	75 2f                	jne    800c37 <memmove+0x6f>
  800c08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0b:	83 e0 03             	and    $0x3,%eax
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	75 25                	jne    800c37 <memmove+0x6f>
  800c12:	8b 45 10             	mov    0x10(%ebp),%eax
  800c15:	83 e0 03             	and    $0x3,%eax
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	75 1b                	jne    800c37 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c1f:	83 e8 04             	sub    $0x4,%eax
  800c22:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c25:	83 ea 04             	sub    $0x4,%edx
  800c28:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c2b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	fd                   	std    
  800c33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c35:	eb 18                	jmp    800c4f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c3a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c40:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c43:	8b 45 10             	mov    0x10(%ebp),%eax
  800c46:	89 d7                	mov    %edx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	89 c1                	mov    %eax,%ecx
  800c4c:	fd                   	std    
  800c4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4f:	fc                   	cld    
  800c50:	eb 45                	jmp    800c97 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c55:	83 e0 03             	and    $0x3,%eax
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	75 2b                	jne    800c87 <memmove+0xbf>
  800c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5f:	83 e0 03             	and    $0x3,%eax
  800c62:	85 c0                	test   %eax,%eax
  800c64:	75 21                	jne    800c87 <memmove+0xbf>
  800c66:	8b 45 10             	mov    0x10(%ebp),%eax
  800c69:	83 e0 03             	and    $0x3,%eax
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	75 17                	jne    800c87 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	c1 e8 02             	shr    $0x2,%eax
  800c76:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c7e:	89 c7                	mov    %eax,%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	fc                   	cld    
  800c83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c85:	eb 10                	jmp    800c97 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c90:	89 c7                	mov    %eax,%edi
  800c92:	89 d6                	mov    %edx,%esi
  800c94:	fc                   	cld    
  800c95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	89 04 24             	mov    %eax,(%esp)
  800cbc:	e8 07 ff ff ff       	call   800bc8 <memmove>
}
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cd5:	eb 30                	jmp    800d07 <memcmp+0x44>
		if (*s1 != *s2)
  800cd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cda:	0f b6 10             	movzbl (%eax),%edx
  800cdd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ce0:	0f b6 00             	movzbl (%eax),%eax
  800ce3:	38 c2                	cmp    %al,%dl
  800ce5:	74 18                	je     800cff <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ce7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cea:	0f b6 00             	movzbl (%eax),%eax
  800ced:	0f b6 d0             	movzbl %al,%edx
  800cf0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cf3:	0f b6 00             	movzbl (%eax),%eax
  800cf6:	0f b6 c0             	movzbl %al,%eax
  800cf9:	29 c2                	sub    %eax,%edx
  800cfb:	89 d0                	mov    %edx,%eax
  800cfd:	eb 1a                	jmp    800d19 <memcmp+0x56>
		s1++, s2++;
  800cff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d03:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d07:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d0d:	89 55 10             	mov    %edx,0x10(%ebp)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	75 c3                	jne    800cd7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d21:	8b 45 10             	mov    0x10(%ebp),%eax
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	01 d0                	add    %edx,%eax
  800d29:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d2c:	eb 13                	jmp    800d41 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	0f b6 10             	movzbl (%eax),%edx
  800d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d37:	38 c2                	cmp    %al,%dl
  800d39:	75 02                	jne    800d3d <memfind+0x22>
			break;
  800d3b:	eb 0c                	jmp    800d49 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d47:	72 e5                	jb     800d2e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d4c:	c9                   	leave  
  800d4d:	c3                   	ret    

00800d4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d54:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d5b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d62:	eb 04                	jmp    800d68 <strtol+0x1a>
		s++;
  800d64:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	0f b6 00             	movzbl (%eax),%eax
  800d6e:	3c 20                	cmp    $0x20,%al
  800d70:	74 f2                	je     800d64 <strtol+0x16>
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	0f b6 00             	movzbl (%eax),%eax
  800d78:	3c 09                	cmp    $0x9,%al
  800d7a:	74 e8                	je     800d64 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 00             	movzbl (%eax),%eax
  800d82:	3c 2b                	cmp    $0x2b,%al
  800d84:	75 06                	jne    800d8c <strtol+0x3e>
		s++;
  800d86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8a:	eb 15                	jmp    800da1 <strtol+0x53>
	else if (*s == '-')
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8f:	0f b6 00             	movzbl (%eax),%eax
  800d92:	3c 2d                	cmp    $0x2d,%al
  800d94:	75 0b                	jne    800da1 <strtol+0x53>
		s++, neg = 1;
  800d96:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d9a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da5:	74 06                	je     800dad <strtol+0x5f>
  800da7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800dab:	75 24                	jne    800dd1 <strtol+0x83>
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	0f b6 00             	movzbl (%eax),%eax
  800db3:	3c 30                	cmp    $0x30,%al
  800db5:	75 1a                	jne    800dd1 <strtol+0x83>
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dba:	83 c0 01             	add    $0x1,%eax
  800dbd:	0f b6 00             	movzbl (%eax),%eax
  800dc0:	3c 78                	cmp    $0x78,%al
  800dc2:	75 0d                	jne    800dd1 <strtol+0x83>
		s += 2, base = 16;
  800dc4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dc8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dcf:	eb 2a                	jmp    800dfb <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800dd1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd5:	75 17                	jne    800dee <strtol+0xa0>
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	0f b6 00             	movzbl (%eax),%eax
  800ddd:	3c 30                	cmp    $0x30,%al
  800ddf:	75 0d                	jne    800dee <strtol+0xa0>
		s++, base = 8;
  800de1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dec:	eb 0d                	jmp    800dfb <strtol+0xad>
	else if (base == 0)
  800dee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df2:	75 07                	jne    800dfb <strtol+0xad>
		base = 10;
  800df4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	0f b6 00             	movzbl (%eax),%eax
  800e01:	3c 2f                	cmp    $0x2f,%al
  800e03:	7e 1b                	jle    800e20 <strtol+0xd2>
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	0f b6 00             	movzbl (%eax),%eax
  800e0b:	3c 39                	cmp    $0x39,%al
  800e0d:	7f 11                	jg     800e20 <strtol+0xd2>
			dig = *s - '0';
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	0f b6 00             	movzbl (%eax),%eax
  800e15:	0f be c0             	movsbl %al,%eax
  800e18:	83 e8 30             	sub    $0x30,%eax
  800e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e1e:	eb 48                	jmp    800e68 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	0f b6 00             	movzbl (%eax),%eax
  800e26:	3c 60                	cmp    $0x60,%al
  800e28:	7e 1b                	jle    800e45 <strtol+0xf7>
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	0f b6 00             	movzbl (%eax),%eax
  800e30:	3c 7a                	cmp    $0x7a,%al
  800e32:	7f 11                	jg     800e45 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	0f b6 00             	movzbl (%eax),%eax
  800e3a:	0f be c0             	movsbl %al,%eax
  800e3d:	83 e8 57             	sub    $0x57,%eax
  800e40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e43:	eb 23                	jmp    800e68 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	0f b6 00             	movzbl (%eax),%eax
  800e4b:	3c 40                	cmp    $0x40,%al
  800e4d:	7e 3d                	jle    800e8c <strtol+0x13e>
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	0f b6 00             	movzbl (%eax),%eax
  800e55:	3c 5a                	cmp    $0x5a,%al
  800e57:	7f 33                	jg     800e8c <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	0f b6 00             	movzbl (%eax),%eax
  800e5f:	0f be c0             	movsbl %al,%eax
  800e62:	83 e8 37             	sub    $0x37,%eax
  800e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e6e:	7c 02                	jl     800e72 <strtol+0x124>
			break;
  800e70:	eb 1a                	jmp    800e8c <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e76:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e79:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e82:	01 d0                	add    %edx,%eax
  800e84:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e87:	e9 6f ff ff ff       	jmp    800dfb <strtol+0xad>

	if (endptr)
  800e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e90:	74 08                	je     800e9a <strtol+0x14c>
		*endptr = (char *) s;
  800e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e9a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e9e:	74 07                	je     800ea7 <strtol+0x159>
  800ea0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ea3:	f7 d8                	neg    %eax
  800ea5:	eb 03                	jmp    800eaa <strtol+0x15c>
  800ea7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	8b 55 10             	mov    0x10(%ebp),%edx
  800ebb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ebe:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ec1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ec4:	8b 75 20             	mov    0x20(%ebp),%esi
  800ec7:	cd 30                	int    $0x30
  800ec9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 30                	je     800f02 <syscall+0x56>
  800ed2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ed6:	7e 2a                	jle    800f02 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800edb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee6:	c7 44 24 08 e4 1c 80 	movl   $0x801ce4,0x8(%esp)
  800eed:	00 
  800eee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef5:	00 
  800ef6:	c7 04 24 01 1d 80 00 	movl   $0x801d01,(%esp)
  800efd:	e8 84 f2 ff ff       	call   800186 <_panic>

	return ret;
  800f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f05:	83 c4 3c             	add    $0x3c,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f25:	00 
  800f26:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f2d:	00 
  800f2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f31:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f48:	e8 5f ff ff ff       	call   800eac <syscall>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f55:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f64:	00 
  800f65:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f74:	00 
  800f75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f8c:	e8 1b ff ff ff       	call   800eac <syscall>
}
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fab:	00 
  800fac:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fbb:	00 
  800fbc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fc7:	00 
  800fc8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fcf:	e8 d8 fe ff ff       	call   800eac <syscall>
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fdc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800feb:	00 
  800fec:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801013:	e8 94 fe ff ff       	call   800eac <syscall>
}
  801018:	c9                   	leave  
  801019:	c3                   	ret    

0080101a <sys_yield>:

void
sys_yield(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801020:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801027:	00 
  801028:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80102f:	00 
  801030:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801037:	00 
  801038:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80103f:	00 
  801040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801047:	00 
  801048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80104f:	00 
  801050:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801057:	e8 50 fe ff ff       	call   800eac <syscall>
}
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    

0080105e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801064:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801067:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106a:	8b 45 08             	mov    0x8(%ebp),%eax
  80106d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801074:	00 
  801075:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80107c:	00 
  80107d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801081:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801085:	89 44 24 08          	mov    %eax,0x8(%esp)
  801089:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801098:	e8 0f fe ff ff       	call   800eac <syscall>
}
  80109d:	c9                   	leave  
  80109e:	c3                   	ret    

0080109f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010a7:	8b 75 18             	mov    0x18(%ebp),%esi
  8010aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010ba:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010be:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d1:	00 
  8010d2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010d9:	e8 ce fd ff ff       	call   800eac <syscall>
}
  8010de:	83 c4 20             	add    $0x20,%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801100:	00 
  801101:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801108:	00 
  801109:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80110d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801111:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801118:	00 
  801119:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801120:	e8 87 fd ff ff       	call   800eac <syscall>
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80112d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80113a:	00 
  80113b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801142:	00 
  801143:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80114a:	00 
  80114b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801153:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80115a:	00 
  80115b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801162:	e8 45 fd ff ff       	call   800eac <syscall>
}
  801167:	c9                   	leave  
  801168:	c3                   	ret    

00801169 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80116f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80117c:	00 
  80117d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801184:	00 
  801185:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80118c:	00 
  80118d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801191:	89 44 24 08          	mov    %eax,0x8(%esp)
  801195:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80119c:	00 
  80119d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011a4:	e8 03 fd ff ff       	call   800eac <syscall>
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011b1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011c1:	00 
  8011c2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011c6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011dc:	00 
  8011dd:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011e4:	e8 c3 fc ff ff       	call   800eac <syscall>
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    

008011eb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801203:	00 
  801204:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80120b:	00 
  80120c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801213:	00 
  801214:	89 44 24 08          	mov    %eax,0x8(%esp)
  801218:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801227:	e8 80 fc ff ff       	call   800eac <syscall>
}
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	8b 00                	mov    (%eax),%eax
  801239:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	8b 40 04             	mov    0x4(%eax),%eax
  801242:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801245:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801248:	83 e0 02             	and    $0x2,%eax
  80124b:	85 c0                	test   %eax,%eax
  80124d:	75 23                	jne    801272 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801256:	c7 44 24 08 10 1d 80 	movl   $0x801d10,0x8(%esp)
  80125d:	00 
  80125e:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801265:	00 
  801266:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  80126d:	e8 14 ef ff ff       	call   800186 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  80127b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80127e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801285:	25 00 08 00 00       	and    $0x800,%eax
  80128a:	85 c0                	test   %eax,%eax
  80128c:	75 1c                	jne    8012aa <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  80128e:	c7 44 24 08 4c 1d 80 	movl   $0x801d4c,0x8(%esp)
  801295:	00 
  801296:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80129d:	00 
  80129e:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  8012a5:	e8 dc ee ff ff       	call   800186 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8012aa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b9:	00 
  8012ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c1:	e8 98 fd ff ff       	call   80105e <sys_page_alloc>
  8012c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012cd:	79 23                	jns    8012f2 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8012cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d6:	c7 44 24 08 88 1d 80 	movl   $0x801d88,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  8012ed:	e8 94 ee ff ff       	call   800186 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8012f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801300:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801307:	00 
  801308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130c:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801313:	e8 8a f9 ff ff       	call   800ca2 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80131e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801326:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80132d:	00 
  80132e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801332:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801339:	00 
  80133a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801341:	00 
  801342:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801349:	e8 51 fd ff ff       	call   80109f <sys_page_map>
  80134e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801351:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801355:	79 23                	jns    80137a <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801357:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80135a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135e:	c7 44 24 08 c0 1d 80 	movl   $0x801dc0,0x8(%esp)
  801365:	00 
  801366:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80136d:	00 
  80136e:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  801375:	e8 0c ee ff ff       	call   800186 <_panic>
	}

	// panic("pgfault not implemented");
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801384:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801395:	25 00 08 00 00       	and    $0x800,%eax
  80139a:	85 c0                	test   %eax,%eax
  80139c:	75 15                	jne    8013b3 <duppage+0x37>
  80139e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a8:	83 e0 02             	and    $0x2,%eax
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	0f 84 e0 00 00 00    	je     801493 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8013b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bd:	83 e0 04             	and    $0x4,%eax
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 04                	je     8013c8 <duppage+0x4c>
  8013c4:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8013c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ce:	c1 e0 0c             	shl    $0xc,%eax
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d6:	c1 e0 0c             	shl    $0xc,%eax
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	a1 08 20 80 00       	mov    0x802008,%eax
  8013e0:	8b 40 48             	mov    0x48(%eax),%eax
  8013e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013e7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 a1 fc ff ff       	call   80109f <sys_page_map>
  8013fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801401:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801405:	79 23                	jns    80142a <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801407:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140e:	c7 44 24 08 f4 1d 80 	movl   $0x801df4,0x8(%esp)
  801415:	00 
  801416:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80141d:	00 
  80141e:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  801425:	e8 5c ed ff ff       	call   800186 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80142a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80142d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801430:	c1 e0 0c             	shl    $0xc,%eax
  801433:	89 c3                	mov    %eax,%ebx
  801435:	a1 08 20 80 00       	mov    0x802008,%eax
  80143a:	8b 48 48             	mov    0x48(%eax),%ecx
  80143d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801440:	c1 e0 0c             	shl    $0xc,%eax
  801443:	89 c2                	mov    %eax,%edx
  801445:	a1 08 20 80 00       	mov    0x802008,%eax
  80144a:	8b 40 48             	mov    0x48(%eax),%eax
  80144d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801451:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801455:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801459:	89 54 24 04          	mov    %edx,0x4(%esp)
  80145d:	89 04 24             	mov    %eax,(%esp)
  801460:	e8 3a fc ff ff       	call   80109f <sys_page_map>
  801465:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801468:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80146c:	79 23                	jns    801491 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80146e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801471:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801475:	c7 44 24 08 30 1e 80 	movl   $0x801e30,0x8(%esp)
  80147c:	00 
  80147d:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801484:	00 
  801485:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  80148c:	e8 f5 ec ff ff       	call   800186 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801491:	eb 70                	jmp    801503 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801493:	8b 45 0c             	mov    0xc(%ebp),%eax
  801496:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149d:	25 ff 0f 00 00       	and    $0xfff,%eax
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a7:	c1 e0 0c             	shl    $0xc,%eax
  8014aa:	89 c1                	mov    %eax,%ecx
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	c1 e0 0c             	shl    $0xc,%eax
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	a1 08 20 80 00       	mov    0x802008,%eax
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014c0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014cf:	89 04 24             	mov    %eax,(%esp)
  8014d2:	e8 c8 fb ff ff       	call   80109f <sys_page_map>
  8014d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014de:	79 23                	jns    801503 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e7:	c7 44 24 08 60 1e 80 	movl   $0x801e60,0x8(%esp)
  8014ee:	00 
  8014ef:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8014f6:	00 
  8014f7:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  8014fe:	e8 83 ec ff ff       	call   800186 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801508:	83 c4 30             	add    $0x30,%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801515:	c7 04 24 2e 12 80 00 	movl   $0x80122e,(%esp)
  80151c:	e8 a2 01 00 00       	call   8016c3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801521:	b8 07 00 00 00       	mov    $0x7,%eax
  801526:	cd 30                	int    $0x30
  801528:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80152b:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80152e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  801531:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801535:	79 23                	jns    80155a <fork+0x4b>
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153e:	c7 44 24 08 98 1e 80 	movl   $0x801e98,0x8(%esp)
  801545:	00 
  801546:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80154d:	00 
  80154e:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  801555:	e8 2c ec ff ff       	call   800186 <_panic>
	else if(childeid == 0){
  80155a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80155e:	75 29                	jne    801589 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801560:	e8 71 fa ff ff       	call   800fd6 <sys_getenvid>
  801565:	25 ff 03 00 00       	and    $0x3ff,%eax
  80156a:	c1 e0 02             	shl    $0x2,%eax
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	c1 e2 05             	shl    $0x5,%edx
  801572:	29 c2                	sub    %eax,%edx
  801574:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80157a:	a3 08 20 80 00       	mov    %eax,0x802008
		// set_pgfault_handler(pgfault);
		return 0;
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	e9 16 01 00 00       	jmp    80169f <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801589:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801590:	eb 3b                	jmp    8015cd <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801595:	c1 f8 0a             	sar    $0xa,%eax
  801598:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80159f:	83 e0 01             	and    $0x1,%eax
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	74 23                	je     8015c9 <fork+0xba>
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b0:	83 e0 01             	and    $0x1,%eax
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	74 12                	je     8015c9 <fork+0xba>
			duppage(childeid, i);
  8015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	89 04 24             	mov    %eax,(%esp)
  8015c4:	e8 b3 fd ff ff       	call   80137c <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8015cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d0:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  8015d5:	76 bb                	jbe    801592 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  8015d7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015de:	00 
  8015df:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015e6:	ee 
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	89 04 24             	mov    %eax,(%esp)
  8015ed:	e8 6c fa ff ff       	call   80105e <sys_page_alloc>
  8015f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015f9:	79 23                	jns    80161e <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8015fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801602:	c7 44 24 08 c0 1e 80 	movl   $0x801ec0,0x8(%esp)
  801609:	00 
  80160a:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801611:	00 
  801612:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  801619:	e8 68 eb ff ff       	call   800186 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80161e:	c7 44 24 04 39 17 80 	movl   $0x801739,0x4(%esp)
  801625:	00 
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 38 fb ff ff       	call   801169 <sys_env_set_pgfault_upcall>
  801631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801634:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801638:	79 23                	jns    80165d <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  80163a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80163d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801641:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  801648:	00 
  801649:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801650:	00 
  801651:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  801658:	e8 29 eb ff ff       	call   800186 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  80165d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801664:	00 
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	89 04 24             	mov    %eax,(%esp)
  80166b:	e8 b7 fa ff ff       	call   801127 <sys_env_set_status>
  801670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801673:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801677:	79 23                	jns    80169c <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  801679:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801680:	c7 44 24 08 1c 1f 80 	movl   $0x801f1c,0x8(%esp)
  801687:	00 
  801688:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80168f:	00 
  801690:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  801697:	e8 ea ea ff ff       	call   800186 <_panic>
	}
	return childeid;
  80169c:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <sfork>:

// Challenge!
int
sfork(void)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016a7:	c7 44 24 08 45 1f 80 	movl   $0x801f45,0x8(%esp)
  8016ae:	00 
  8016af:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8016b6:	00 
  8016b7:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  8016be:	e8 c3 ea ff ff       	call   800186 <_panic>

008016c3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8016c9:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	75 5d                	jne    80172f <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8016d2:	a1 08 20 80 00       	mov    0x802008,%eax
  8016d7:	8b 40 48             	mov    0x48(%eax),%eax
  8016da:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016e1:	00 
  8016e2:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016e9:	ee 
  8016ea:	89 04 24             	mov    %eax,(%esp)
  8016ed:	e8 6c f9 ff ff       	call   80105e <sys_page_alloc>
  8016f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016f9:	79 1c                	jns    801717 <set_pgfault_handler+0x54>
  8016fb:	c7 44 24 08 5c 1f 80 	movl   $0x801f5c,0x8(%esp)
  801702:	00 
  801703:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80170a:	00 
  80170b:	c7 04 24 88 1f 80 00 	movl   $0x801f88,(%esp)
  801712:	e8 6f ea ff ff       	call   800186 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801717:	a1 08 20 80 00       	mov    0x802008,%eax
  80171c:	8b 40 48             	mov    0x48(%eax),%eax
  80171f:	c7 44 24 04 39 17 80 	movl   $0x801739,0x4(%esp)
  801726:	00 
  801727:	89 04 24             	mov    %eax,(%esp)
  80172a:	e8 3a fa ff ff       	call   801169 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801739:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80173a:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80173f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801741:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801744:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801748:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80174a:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80174e:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80174f:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801752:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801754:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801755:	58                   	pop    %eax
	popal 						// pop all the registers
  801756:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801757:	83 c4 04             	add    $0x4,%esp
	popfl
  80175a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80175b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80175c:	c3                   	ret    
  80175d:	66 90                	xchg   %ax,%ax
  80175f:	90                   	nop

00801760 <__udivdi3>:
  801760:	55                   	push   %ebp
  801761:	57                   	push   %edi
  801762:	56                   	push   %esi
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	8b 44 24 28          	mov    0x28(%esp),%eax
  80176a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80176e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801772:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801776:	85 c0                	test   %eax,%eax
  801778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80177c:	89 ea                	mov    %ebp,%edx
  80177e:	89 0c 24             	mov    %ecx,(%esp)
  801781:	75 2d                	jne    8017b0 <__udivdi3+0x50>
  801783:	39 e9                	cmp    %ebp,%ecx
  801785:	77 61                	ja     8017e8 <__udivdi3+0x88>
  801787:	85 c9                	test   %ecx,%ecx
  801789:	89 ce                	mov    %ecx,%esi
  80178b:	75 0b                	jne    801798 <__udivdi3+0x38>
  80178d:	b8 01 00 00 00       	mov    $0x1,%eax
  801792:	31 d2                	xor    %edx,%edx
  801794:	f7 f1                	div    %ecx
  801796:	89 c6                	mov    %eax,%esi
  801798:	31 d2                	xor    %edx,%edx
  80179a:	89 e8                	mov    %ebp,%eax
  80179c:	f7 f6                	div    %esi
  80179e:	89 c5                	mov    %eax,%ebp
  8017a0:	89 f8                	mov    %edi,%eax
  8017a2:	f7 f6                	div    %esi
  8017a4:	89 ea                	mov    %ebp,%edx
  8017a6:	83 c4 0c             	add    $0xc,%esp
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    
  8017ad:	8d 76 00             	lea    0x0(%esi),%esi
  8017b0:	39 e8                	cmp    %ebp,%eax
  8017b2:	77 24                	ja     8017d8 <__udivdi3+0x78>
  8017b4:	0f bd e8             	bsr    %eax,%ebp
  8017b7:	83 f5 1f             	xor    $0x1f,%ebp
  8017ba:	75 3c                	jne    8017f8 <__udivdi3+0x98>
  8017bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017c0:	39 34 24             	cmp    %esi,(%esp)
  8017c3:	0f 86 9f 00 00 00    	jbe    801868 <__udivdi3+0x108>
  8017c9:	39 d0                	cmp    %edx,%eax
  8017cb:	0f 82 97 00 00 00    	jb     801868 <__udivdi3+0x108>
  8017d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017d8:	31 d2                	xor    %edx,%edx
  8017da:	31 c0                	xor    %eax,%eax
  8017dc:	83 c4 0c             	add    $0xc,%esp
  8017df:	5e                   	pop    %esi
  8017e0:	5f                   	pop    %edi
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    
  8017e3:	90                   	nop
  8017e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017e8:	89 f8                	mov    %edi,%eax
  8017ea:	f7 f1                	div    %ecx
  8017ec:	31 d2                	xor    %edx,%edx
  8017ee:	83 c4 0c             	add    $0xc,%esp
  8017f1:	5e                   	pop    %esi
  8017f2:	5f                   	pop    %edi
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    
  8017f5:	8d 76 00             	lea    0x0(%esi),%esi
  8017f8:	89 e9                	mov    %ebp,%ecx
  8017fa:	8b 3c 24             	mov    (%esp),%edi
  8017fd:	d3 e0                	shl    %cl,%eax
  8017ff:	89 c6                	mov    %eax,%esi
  801801:	b8 20 00 00 00       	mov    $0x20,%eax
  801806:	29 e8                	sub    %ebp,%eax
  801808:	89 c1                	mov    %eax,%ecx
  80180a:	d3 ef                	shr    %cl,%edi
  80180c:	89 e9                	mov    %ebp,%ecx
  80180e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801812:	8b 3c 24             	mov    (%esp),%edi
  801815:	09 74 24 08          	or     %esi,0x8(%esp)
  801819:	89 d6                	mov    %edx,%esi
  80181b:	d3 e7                	shl    %cl,%edi
  80181d:	89 c1                	mov    %eax,%ecx
  80181f:	89 3c 24             	mov    %edi,(%esp)
  801822:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801826:	d3 ee                	shr    %cl,%esi
  801828:	89 e9                	mov    %ebp,%ecx
  80182a:	d3 e2                	shl    %cl,%edx
  80182c:	89 c1                	mov    %eax,%ecx
  80182e:	d3 ef                	shr    %cl,%edi
  801830:	09 d7                	or     %edx,%edi
  801832:	89 f2                	mov    %esi,%edx
  801834:	89 f8                	mov    %edi,%eax
  801836:	f7 74 24 08          	divl   0x8(%esp)
  80183a:	89 d6                	mov    %edx,%esi
  80183c:	89 c7                	mov    %eax,%edi
  80183e:	f7 24 24             	mull   (%esp)
  801841:	39 d6                	cmp    %edx,%esi
  801843:	89 14 24             	mov    %edx,(%esp)
  801846:	72 30                	jb     801878 <__udivdi3+0x118>
  801848:	8b 54 24 04          	mov    0x4(%esp),%edx
  80184c:	89 e9                	mov    %ebp,%ecx
  80184e:	d3 e2                	shl    %cl,%edx
  801850:	39 c2                	cmp    %eax,%edx
  801852:	73 05                	jae    801859 <__udivdi3+0xf9>
  801854:	3b 34 24             	cmp    (%esp),%esi
  801857:	74 1f                	je     801878 <__udivdi3+0x118>
  801859:	89 f8                	mov    %edi,%eax
  80185b:	31 d2                	xor    %edx,%edx
  80185d:	e9 7a ff ff ff       	jmp    8017dc <__udivdi3+0x7c>
  801862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801868:	31 d2                	xor    %edx,%edx
  80186a:	b8 01 00 00 00       	mov    $0x1,%eax
  80186f:	e9 68 ff ff ff       	jmp    8017dc <__udivdi3+0x7c>
  801874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801878:	8d 47 ff             	lea    -0x1(%edi),%eax
  80187b:	31 d2                	xor    %edx,%edx
  80187d:	83 c4 0c             	add    $0xc,%esp
  801880:	5e                   	pop    %esi
  801881:	5f                   	pop    %edi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    
  801884:	66 90                	xchg   %ax,%ax
  801886:	66 90                	xchg   %ax,%ax
  801888:	66 90                	xchg   %ax,%ax
  80188a:	66 90                	xchg   %ax,%ax
  80188c:	66 90                	xchg   %ax,%ax
  80188e:	66 90                	xchg   %ax,%ax

00801890 <__umoddi3>:
  801890:	55                   	push   %ebp
  801891:	57                   	push   %edi
  801892:	56                   	push   %esi
  801893:	83 ec 14             	sub    $0x14,%esp
  801896:	8b 44 24 28          	mov    0x28(%esp),%eax
  80189a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80189e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8018a2:	89 c7                	mov    %eax,%edi
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8018ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018b0:	89 34 24             	mov    %esi,(%esp)
  8018b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018bf:	75 17                	jne    8018d8 <__umoddi3+0x48>
  8018c1:	39 fe                	cmp    %edi,%esi
  8018c3:	76 4b                	jbe    801910 <__umoddi3+0x80>
  8018c5:	89 c8                	mov    %ecx,%eax
  8018c7:	89 fa                	mov    %edi,%edx
  8018c9:	f7 f6                	div    %esi
  8018cb:	89 d0                	mov    %edx,%eax
  8018cd:	31 d2                	xor    %edx,%edx
  8018cf:	83 c4 14             	add    $0x14,%esp
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    
  8018d6:	66 90                	xchg   %ax,%ax
  8018d8:	39 f8                	cmp    %edi,%eax
  8018da:	77 54                	ja     801930 <__umoddi3+0xa0>
  8018dc:	0f bd e8             	bsr    %eax,%ebp
  8018df:	83 f5 1f             	xor    $0x1f,%ebp
  8018e2:	75 5c                	jne    801940 <__umoddi3+0xb0>
  8018e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8018e8:	39 3c 24             	cmp    %edi,(%esp)
  8018eb:	0f 87 e7 00 00 00    	ja     8019d8 <__umoddi3+0x148>
  8018f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018f5:	29 f1                	sub    %esi,%ecx
  8018f7:	19 c7                	sbb    %eax,%edi
  8018f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801901:	8b 44 24 08          	mov    0x8(%esp),%eax
  801905:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801909:	83 c4 14             	add    $0x14,%esp
  80190c:	5e                   	pop    %esi
  80190d:	5f                   	pop    %edi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    
  801910:	85 f6                	test   %esi,%esi
  801912:	89 f5                	mov    %esi,%ebp
  801914:	75 0b                	jne    801921 <__umoddi3+0x91>
  801916:	b8 01 00 00 00       	mov    $0x1,%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	f7 f6                	div    %esi
  80191f:	89 c5                	mov    %eax,%ebp
  801921:	8b 44 24 04          	mov    0x4(%esp),%eax
  801925:	31 d2                	xor    %edx,%edx
  801927:	f7 f5                	div    %ebp
  801929:	89 c8                	mov    %ecx,%eax
  80192b:	f7 f5                	div    %ebp
  80192d:	eb 9c                	jmp    8018cb <__umoddi3+0x3b>
  80192f:	90                   	nop
  801930:	89 c8                	mov    %ecx,%eax
  801932:	89 fa                	mov    %edi,%edx
  801934:	83 c4 14             	add    $0x14,%esp
  801937:	5e                   	pop    %esi
  801938:	5f                   	pop    %edi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    
  80193b:	90                   	nop
  80193c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801940:	8b 04 24             	mov    (%esp),%eax
  801943:	be 20 00 00 00       	mov    $0x20,%esi
  801948:	89 e9                	mov    %ebp,%ecx
  80194a:	29 ee                	sub    %ebp,%esi
  80194c:	d3 e2                	shl    %cl,%edx
  80194e:	89 f1                	mov    %esi,%ecx
  801950:	d3 e8                	shr    %cl,%eax
  801952:	89 e9                	mov    %ebp,%ecx
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	8b 04 24             	mov    (%esp),%eax
  80195b:	09 54 24 04          	or     %edx,0x4(%esp)
  80195f:	89 fa                	mov    %edi,%edx
  801961:	d3 e0                	shl    %cl,%eax
  801963:	89 f1                	mov    %esi,%ecx
  801965:	89 44 24 08          	mov    %eax,0x8(%esp)
  801969:	8b 44 24 10          	mov    0x10(%esp),%eax
  80196d:	d3 ea                	shr    %cl,%edx
  80196f:	89 e9                	mov    %ebp,%ecx
  801971:	d3 e7                	shl    %cl,%edi
  801973:	89 f1                	mov    %esi,%ecx
  801975:	d3 e8                	shr    %cl,%eax
  801977:	89 e9                	mov    %ebp,%ecx
  801979:	09 f8                	or     %edi,%eax
  80197b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80197f:	f7 74 24 04          	divl   0x4(%esp)
  801983:	d3 e7                	shl    %cl,%edi
  801985:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801989:	89 d7                	mov    %edx,%edi
  80198b:	f7 64 24 08          	mull   0x8(%esp)
  80198f:	39 d7                	cmp    %edx,%edi
  801991:	89 c1                	mov    %eax,%ecx
  801993:	89 14 24             	mov    %edx,(%esp)
  801996:	72 2c                	jb     8019c4 <__umoddi3+0x134>
  801998:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80199c:	72 22                	jb     8019c0 <__umoddi3+0x130>
  80199e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8019a2:	29 c8                	sub    %ecx,%eax
  8019a4:	19 d7                	sbb    %edx,%edi
  8019a6:	89 e9                	mov    %ebp,%ecx
  8019a8:	89 fa                	mov    %edi,%edx
  8019aa:	d3 e8                	shr    %cl,%eax
  8019ac:	89 f1                	mov    %esi,%ecx
  8019ae:	d3 e2                	shl    %cl,%edx
  8019b0:	89 e9                	mov    %ebp,%ecx
  8019b2:	d3 ef                	shr    %cl,%edi
  8019b4:	09 d0                	or     %edx,%eax
  8019b6:	89 fa                	mov    %edi,%edx
  8019b8:	83 c4 14             	add    $0x14,%esp
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    
  8019bf:	90                   	nop
  8019c0:	39 d7                	cmp    %edx,%edi
  8019c2:	75 da                	jne    80199e <__umoddi3+0x10e>
  8019c4:	8b 14 24             	mov    (%esp),%edx
  8019c7:	89 c1                	mov    %eax,%ecx
  8019c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8019cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8019d1:	eb cb                	jmp    80199e <__umoddi3+0x10e>
  8019d3:	90                   	nop
  8019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8019dc:	0f 82 0f ff ff ff    	jb     8018f1 <__umoddi3+0x61>
  8019e2:	e9 1a ff ff ff       	jmp    801901 <__umoddi3+0x71>
