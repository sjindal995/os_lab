
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 fa 00 00 00       	call   80012b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 e0 14 80 00 	movl   $0x8014e0,(%esp)
  800040:	e8 64 02 00 00       	call   8002a9 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80004c:	eb 35                	jmp    800083 <umain+0x50>
		if (bigarray[i] != 0)
  80004e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800051:	8b 04 85 20 20 80 00 	mov    0x802020(,%eax,4),%eax
  800058:	85 c0                	test   %eax,%eax
  80005a:	74 23                	je     80007f <umain+0x4c>
			panic("bigarray[%d] isn't cleared!\n", i);
  80005c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80005f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800063:	c7 44 24 08 00 15 80 	movl   $0x801500,0x8(%esp)
  80006a:	00 
  80006b:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 1d 15 80 00 	movl   $0x80151d,(%esp)
  80007a:	e8 0f 01 00 00       	call   80018e <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80007f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800083:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  80008a:	7e c2                	jle    80004e <umain+0x1b>
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800093:	eb 11                	jmp    8000a6 <umain+0x73>
		bigarray[i] = i;
  800095:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80009b:	89 14 85 20 20 80 00 	mov    %edx,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  8000a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000a6:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  8000ad:	7e e6                	jle    800095 <umain+0x62>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8000b6:	eb 38                	jmp    8000f0 <umain+0xbd>
		if (bigarray[i] != i)
  8000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000bb:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  8000c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c5:	39 c2                	cmp    %eax,%edx
  8000c7:	74 23                	je     8000ec <umain+0xb9>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d0:	c7 44 24 08 2c 15 80 	movl   $0x80152c,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 1d 15 80 00 	movl   $0x80151d,(%esp)
  8000e7:	e8 a2 00 00 00       	call   80018e <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000f0:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  8000f7:	7e bf                	jle    8000b8 <umain+0x85>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000f9:	c7 04 24 54 15 80 00 	movl   $0x801554,(%esp)
  800100:	e8 a4 01 00 00       	call   8002a9 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  800105:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80010c:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  80010f:	c7 44 24 08 87 15 80 	movl   $0x801587,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 1d 15 80 00 	movl   $0x80151d,(%esp)
  800126:	e8 63 00 00 00       	call   80018e <_panic>

0080012b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800131:	e8 a8 0e 00 00       	call   800fde <sys_getenvid>
  800136:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013b:	c1 e0 02             	shl    $0x2,%eax
  80013e:	89 c2                	mov    %eax,%edx
  800140:	c1 e2 05             	shl    $0x5,%edx
  800143:	29 c2                	sub    %eax,%edx
  800145:	89 d0                	mov    %edx,%eax
  800147:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014c:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800151:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800155:	7e 0a                	jle    800161 <libmain+0x36>
		binaryname = argv[0];
  800157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015a:	8b 00                	mov    (%eax),%eax
  80015c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800161:	8b 45 0c             	mov    0xc(%ebp),%eax
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8b 45 08             	mov    0x8(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 c0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800173:	e8 02 00 00 00       	call   80017a <exit>
}
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800187:	e8 0f 0e 00 00       	call   800f9b <sys_env_destroy>
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800195:	8d 45 14             	lea    0x14(%ebp),%eax
  800198:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a1:	e8 38 0e 00 00       	call   800fde <sys_getenvid>
  8001a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  8001c3:	e8 e1 00 00 00       	call   8002a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d2:	89 04 24             	mov    %eax,(%esp)
  8001d5:	e8 6b 00 00 00       	call   800245 <vcprintf>
	cprintf("\n");
  8001da:	c7 04 24 cb 15 80 00 	movl   $0x8015cb,(%esp)
  8001e1:	e8 c3 00 00 00       	call   8002a9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e6:	cc                   	int3   
  8001e7:	eb fd                	jmp    8001e6 <_panic+0x58>

008001e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f2:	8b 00                	mov    (%eax),%eax
  8001f4:	8d 48 01             	lea    0x1(%eax),%ecx
  8001f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fa:	89 0a                	mov    %ecx,(%edx)
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	89 d1                	mov    %edx,%ecx
  800201:	8b 55 0c             	mov    0xc(%ebp),%edx
  800204:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	8b 00                	mov    (%eax),%eax
  80020d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800212:	75 20                	jne    800234 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	8b 00                	mov    (%eax),%eax
  800219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021c:	83 c2 08             	add    $0x8,%edx
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	89 14 24             	mov    %edx,(%esp)
  800226:	e8 ea 0c 00 00       	call   800f15 <sys_cputs>
		b->idx = 0;
  80022b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	8b 40 04             	mov    0x4(%eax),%eax
  80023a:	8d 50 01             	lea    0x1(%eax),%edx
  80023d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800240:	89 50 04             	mov    %edx,0x4(%eax)
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800255:	00 00 00 
	b.cnt = 0;
  800258:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800262:	8b 45 0c             	mov    0xc(%ebp),%eax
  800265:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800270:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800276:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027a:	c7 04 24 e9 01 80 00 	movl   $0x8001e9,(%esp)
  800281:	e8 bd 01 00 00       	call   800443 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800286:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	83 c0 08             	add    $0x8,%eax
  800299:	89 04 24             	mov    %eax,(%esp)
  80029c:	e8 74 0c 00 00       	call   800f15 <sys_cputs>

	return b.cnt;
  8002a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002af:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	89 04 24             	mov    %eax,(%esp)
  8002c2:	e8 7e ff ff ff       	call   800245 <vcprintf>
  8002c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002cd:	c9                   	leave  
  8002ce:	c3                   	ret    

008002cf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 34             	sub    $0x34,%esp
  8002d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002df:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e2:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ea:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ed:	77 72                	ja     800361 <printnum+0x92>
  8002ef:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002f2:	72 05                	jb     8002f9 <printnum+0x2a>
  8002f4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002f7:	77 68                	ja     800361 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f9:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ff:	8b 45 18             	mov    0x18(%ebp),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800312:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031c:	e8 1f 0f 00 00       	call   801240 <__udivdi3>
  800321:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800324:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800328:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80032c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80032f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800333:	89 44 24 08          	mov    %eax,0x8(%esp)
  800337:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800342:	8b 45 08             	mov    0x8(%ebp),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	e8 82 ff ff ff       	call   8002cf <printnum>
  80034d:	eb 1c                	jmp    80036b <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800352:	89 44 24 04          	mov    %eax,0x4(%esp)
  800356:	8b 45 20             	mov    0x20(%ebp),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	8b 45 08             	mov    0x8(%ebp),%eax
  80035f:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800361:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800365:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800369:	7f e4                	jg     80034f <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80036b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80036e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800373:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800376:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800379:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80037d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	89 54 24 04          	mov    %edx,0x4(%esp)
  800388:	e8 e3 0f 00 00       	call   801370 <__umoddi3>
  80038d:	05 a8 16 80 00       	add    $0x8016a8,%eax
  800392:	0f b6 00             	movzbl (%eax),%eax
  800395:	0f be c0             	movsbl %al,%eax
  800398:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	ff d0                	call   *%eax
}
  8003a7:	83 c4 34             	add    $0x34,%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003b4:	7e 14                	jle    8003ca <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	8d 48 08             	lea    0x8(%eax),%ecx
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 0a                	mov    %ecx,(%edx)
  8003c3:	8b 50 04             	mov    0x4(%eax),%edx
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	eb 30                	jmp    8003fa <getuint+0x4d>
	else if (lflag)
  8003ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003ce:	74 16                	je     8003e6 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003db:	89 0a                	mov    %ecx,(%edx)
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e4:	eb 14                	jmp    8003fa <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	8b 00                	mov    (%eax),%eax
  8003eb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f1:	89 0a                	mov    %ecx,(%edx)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ff:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800403:	7e 14                	jle    800419 <getint+0x1d>
		return va_arg(*ap, long long);
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	8d 48 08             	lea    0x8(%eax),%ecx
  80040d:	8b 55 08             	mov    0x8(%ebp),%edx
  800410:	89 0a                	mov    %ecx,(%edx)
  800412:	8b 50 04             	mov    0x4(%eax),%edx
  800415:	8b 00                	mov    (%eax),%eax
  800417:	eb 28                	jmp    800441 <getint+0x45>
	else if (lflag)
  800419:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80041d:	74 12                	je     800431 <getint+0x35>
		return va_arg(*ap, long);
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	8b 00                	mov    (%eax),%eax
  800424:	8d 48 04             	lea    0x4(%eax),%ecx
  800427:	8b 55 08             	mov    0x8(%ebp),%edx
  80042a:	89 0a                	mov    %ecx,(%edx)
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	99                   	cltd   
  80042f:	eb 10                	jmp    800441 <getint+0x45>
	else
		return va_arg(*ap, int);
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	8b 00                	mov    (%eax),%eax
  800436:	8d 48 04             	lea    0x4(%eax),%ecx
  800439:	8b 55 08             	mov    0x8(%ebp),%edx
  80043c:	89 0a                	mov    %ecx,(%edx)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	99                   	cltd   
}
  800441:	5d                   	pop    %ebp
  800442:	c3                   	ret    

00800443 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
  800448:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044b:	eb 18                	jmp    800465 <vprintfmt+0x22>
			if (ch == '\0')
  80044d:	85 db                	test   %ebx,%ebx
  80044f:	75 05                	jne    800456 <vprintfmt+0x13>
				return;
  800451:	e9 cc 03 00 00       	jmp    800822 <vprintfmt+0x3df>
			putch(ch, putdat);
  800456:	8b 45 0c             	mov    0xc(%ebp),%eax
  800459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045d:	89 1c 24             	mov    %ebx,(%esp)
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	8d 50 01             	lea    0x1(%eax),%edx
  80046b:	89 55 10             	mov    %edx,0x10(%ebp)
  80046e:	0f b6 00             	movzbl (%eax),%eax
  800471:	0f b6 d8             	movzbl %al,%ebx
  800474:	83 fb 25             	cmp    $0x25,%ebx
  800477:	75 d4                	jne    80044d <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800479:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80047d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800484:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800492:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 45 10             	mov    0x10(%ebp),%eax
  80049c:	8d 50 01             	lea    0x1(%eax),%edx
  80049f:	89 55 10             	mov    %edx,0x10(%ebp)
  8004a2:	0f b6 00             	movzbl (%eax),%eax
  8004a5:	0f b6 d8             	movzbl %al,%ebx
  8004a8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8004ab:	83 f8 55             	cmp    $0x55,%eax
  8004ae:	0f 87 3d 03 00 00    	ja     8007f1 <vprintfmt+0x3ae>
  8004b4:	8b 04 85 cc 16 80 00 	mov    0x8016cc(,%eax,4),%eax
  8004bb:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004bd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004c1:	eb d6                	jmp    800499 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004c7:	eb d0                	jmp    800499 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d3:	89 d0                	mov    %edx,%eax
  8004d5:	c1 e0 02             	shl    $0x2,%eax
  8004d8:	01 d0                	add    %edx,%eax
  8004da:	01 c0                	add    %eax,%eax
  8004dc:	01 d8                	add    %ebx,%eax
  8004de:	83 e8 30             	sub    $0x30,%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e7:	0f b6 00             	movzbl (%eax),%eax
  8004ea:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ed:	83 fb 2f             	cmp    $0x2f,%ebx
  8004f0:	7e 0b                	jle    8004fd <vprintfmt+0xba>
  8004f2:	83 fb 39             	cmp    $0x39,%ebx
  8004f5:	7f 06                	jg     8004fd <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f7:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fb:	eb d3                	jmp    8004d0 <vprintfmt+0x8d>
			goto process_precision;
  8004fd:	eb 33                	jmp    800532 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 50 04             	lea    0x4(%eax),%edx
  800505:	89 55 14             	mov    %edx,0x14(%ebp)
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80050d:	eb 23                	jmp    800532 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80050f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800513:	79 0c                	jns    800521 <vprintfmt+0xde>
				width = 0;
  800515:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80051c:	e9 78 ff ff ff       	jmp    800499 <vprintfmt+0x56>
  800521:	e9 73 ff ff ff       	jmp    800499 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800526:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80052d:	e9 67 ff ff ff       	jmp    800499 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800532:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800536:	79 12                	jns    80054a <vprintfmt+0x107>
				width = precision, precision = -1;
  800538:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80053e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800545:	e9 4f ff ff ff       	jmp    800499 <vprintfmt+0x56>
  80054a:	e9 4a ff ff ff       	jmp    800499 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800553:	e9 41 ff ff ff       	jmp    800499 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 00                	mov    (%eax),%eax
  800563:	8b 55 0c             	mov    0xc(%ebp),%edx
  800566:	89 54 24 04          	mov    %edx,0x4(%esp)
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	8b 45 08             	mov    0x8(%ebp),%eax
  800570:	ff d0                	call   *%eax
			break;
  800572:	e9 a5 02 00 00       	jmp    80081c <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800582:	85 db                	test   %ebx,%ebx
  800584:	79 02                	jns    800588 <vprintfmt+0x145>
				err = -err;
  800586:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800588:	83 fb 09             	cmp    $0x9,%ebx
  80058b:	7f 0b                	jg     800598 <vprintfmt+0x155>
  80058d:	8b 34 9d 80 16 80 00 	mov    0x801680(,%ebx,4),%esi
  800594:	85 f6                	test   %esi,%esi
  800596:	75 23                	jne    8005bb <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800598:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80059c:	c7 44 24 08 b9 16 80 	movl   $0x8016b9,0x8(%esp)
  8005a3:	00 
  8005a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	e8 73 02 00 00       	call   800829 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005b6:	e9 61 02 00 00       	jmp    80081c <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005bf:	c7 44 24 08 c2 16 80 	movl   $0x8016c2,0x8(%esp)
  8005c6:	00 
  8005c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d1:	89 04 24             	mov    %eax,(%esp)
  8005d4:	e8 50 02 00 00       	call   800829 <printfmt>
			break;
  8005d9:	e9 3e 02 00 00       	jmp    80081c <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 30                	mov    (%eax),%esi
  8005e9:	85 f6                	test   %esi,%esi
  8005eb:	75 05                	jne    8005f2 <vprintfmt+0x1af>
				p = "(null)";
  8005ed:	be c5 16 80 00       	mov    $0x8016c5,%esi
			if (width > 0 && padc != '-')
  8005f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f6:	7e 37                	jle    80062f <vprintfmt+0x1ec>
  8005f8:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005fc:	74 31                	je     80062f <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800601:	89 44 24 04          	mov    %eax,0x4(%esp)
  800605:	89 34 24             	mov    %esi,(%esp)
  800608:	e8 39 03 00 00       	call   800946 <strnlen>
  80060d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800610:	eb 17                	jmp    800629 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800612:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800616:	8b 55 0c             	mov    0xc(%ebp),%edx
  800619:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	8b 45 08             	mov    0x8(%ebp),%eax
  800623:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800625:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800629:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062d:	7f e3                	jg     800612 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062f:	eb 38                	jmp    800669 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800631:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800635:	74 1f                	je     800656 <vprintfmt+0x213>
  800637:	83 fb 1f             	cmp    $0x1f,%ebx
  80063a:	7e 05                	jle    800641 <vprintfmt+0x1fe>
  80063c:	83 fb 7e             	cmp    $0x7e,%ebx
  80063f:	7e 15                	jle    800656 <vprintfmt+0x213>
					putch('?', putdat);
  800641:	8b 45 0c             	mov    0xc(%ebp),%eax
  800644:	89 44 24 04          	mov    %eax,0x4(%esp)
  800648:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	ff d0                	call   *%eax
  800654:	eb 0f                	jmp    800665 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	89 1c 24             	mov    %ebx,(%esp)
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800665:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800669:	89 f0                	mov    %esi,%eax
  80066b:	8d 70 01             	lea    0x1(%eax),%esi
  80066e:	0f b6 00             	movzbl (%eax),%eax
  800671:	0f be d8             	movsbl %al,%ebx
  800674:	85 db                	test   %ebx,%ebx
  800676:	74 10                	je     800688 <vprintfmt+0x245>
  800678:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067c:	78 b3                	js     800631 <vprintfmt+0x1ee>
  80067e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800682:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800686:	79 a9                	jns    800631 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800688:	eb 17                	jmp    8006a1 <vprintfmt+0x25e>
				putch(' ', putdat);
  80068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800691:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800698:	8b 45 08             	mov    0x8(%ebp),%eax
  80069b:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a5:	7f e3                	jg     80068a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8006a7:	e9 70 01 00 00       	jmp    80081c <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	89 04 24             	mov    %eax,(%esp)
  8006b9:	e8 3e fd ff ff       	call   8003fc <getint>
  8006be:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ca:	85 d2                	test   %edx,%edx
  8006cc:	79 26                	jns    8006f4 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	ff d0                	call   *%eax
				num = -(long long) num;
  8006e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e7:	f7 d8                	neg    %eax
  8006e9:	83 d2 00             	adc    $0x0,%edx
  8006ec:	f7 da                	neg    %edx
  8006ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006f4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006fb:	e9 a8 00 00 00       	jmp    8007a8 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800700:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800703:	89 44 24 04          	mov    %eax,0x4(%esp)
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	e8 9b fc ff ff       	call   8003ad <getuint>
  800712:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800715:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800718:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80071f:	e9 84 00 00 00       	jmp    8007a8 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800724:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	89 04 24             	mov    %eax,(%esp)
  800731:	e8 77 fc ff ff       	call   8003ad <getuint>
  800736:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800739:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80073c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800743:	eb 63                	jmp    8007a8 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	ff d0                	call   *%eax
			putch('x', putdat);
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)
  800774:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800776:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800779:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800780:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800787:	eb 1f                	jmp    8007a8 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800789:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 12 fc ff ff       	call   8003ad <getuint>
  80079b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80079e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007a1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8007ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007af:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b6:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 f1 fa ff ff       	call   8002cf <printnum>
			break;
  8007de:	eb 3c                	jmp    80081c <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e7:	89 1c 24             	mov    %ebx,(%esp)
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	ff d0                	call   *%eax
			break;
  8007ef:	eb 2b                	jmp    80081c <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800804:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800808:	eb 04                	jmp    80080e <vprintfmt+0x3cb>
  80080a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	83 e8 01             	sub    $0x1,%eax
  800814:	0f b6 00             	movzbl (%eax),%eax
  800817:	3c 25                	cmp    $0x25,%al
  800819:	75 ef                	jne    80080a <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80081b:	90                   	nop
		}
	}
  80081c:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80081d:	e9 43 fc ff ff       	jmp    800465 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800822:	83 c4 40             	add    $0x40,%esp
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800838:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083c:	8b 45 10             	mov    0x10(%ebp),%eax
  80083f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800843:	8b 45 0c             	mov    0xc(%ebp),%eax
  800846:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	89 04 24             	mov    %eax,(%esp)
  800850:	e8 ee fb ff ff       	call   800443 <vprintfmt>
	va_end(ap);
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	8b 40 08             	mov    0x8(%eax),%eax
  800860:	8d 50 01             	lea    0x1(%eax),%edx
  800863:	8b 45 0c             	mov    0xc(%ebp),%eax
  800866:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086c:	8b 10                	mov    (%eax),%edx
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	8b 40 04             	mov    0x4(%eax),%eax
  800874:	39 c2                	cmp    %eax,%edx
  800876:	73 12                	jae    80088a <sprintputch+0x33>
		*b->buf++ = ch;
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	8d 48 01             	lea    0x1(%eax),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 0a                	mov    %ecx,(%edx)
  800885:	8b 55 08             	mov    0x8(%ebp),%edx
  800888:	88 10                	mov    %dl,(%eax)
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800898:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	01 d0                	add    %edx,%eax
  8008a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008b1:	74 06                	je     8008b9 <vsnprintf+0x2d>
  8008b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008b7:	7f 07                	jg     8008c0 <vsnprintf+0x34>
		return -E_INVAL;
  8008b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008be:	eb 2a                	jmp    8008ea <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d5:	c7 04 24 57 08 80 00 	movl   $0x800857,(%esp)
  8008dc:	e8 62 fb ff ff       	call   800443 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800902:	89 44 24 08          	mov    %eax,0x8(%esp)
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	89 04 24             	mov    %eax,(%esp)
  800913:	e8 74 ff ff ff       	call   80088c <vsnprintf>
  800918:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80091b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800926:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80092d:	eb 08                	jmp    800937 <strlen+0x17>
		n++;
  80092f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800933:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	0f b6 00             	movzbl (%eax),%eax
  80093d:	84 c0                	test   %al,%al
  80093f:	75 ee                	jne    80092f <strlen+0xf>
		n++;
	return n;
  800941:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800953:	eb 0c                	jmp    800961 <strnlen+0x1b>
		n++;
  800955:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800959:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80095d:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800961:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800965:	74 0a                	je     800971 <strnlen+0x2b>
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	0f b6 00             	movzbl (%eax),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	75 e4                	jne    800955 <strnlen+0xf>
		n++;
	return n;
  800971:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800982:	90                   	nop
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8d 50 01             	lea    0x1(%eax),%edx
  800989:	89 55 08             	mov    %edx,0x8(%ebp)
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800992:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800995:	0f b6 12             	movzbl (%edx),%edx
  800998:	88 10                	mov    %dl,(%eax)
  80099a:	0f b6 00             	movzbl (%eax),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	75 e2                	jne    800983 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	e8 69 ff ff ff       	call   800920 <strlen>
  8009b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009ba:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	01 c2                	add    %eax,%edx
  8009c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c9:	89 14 24             	mov    %edx,(%esp)
  8009cc:	e8 a5 ff ff ff       	call   800976 <strcpy>
	return dst;
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009e9:	eb 23                	jmp    800a0e <strncpy+0x38>
		*dst++ = *src;
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8d 50 01             	lea    0x1(%eax),%edx
  8009f1:	89 55 08             	mov    %edx,0x8(%ebp)
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f7:	0f b6 12             	movzbl (%edx),%edx
  8009fa:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ff:	0f b6 00             	movzbl (%eax),%eax
  800a02:	84 c0                	test   %al,%al
  800a04:	74 04                	je     800a0a <strncpy+0x34>
			src++;
  800a06:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a11:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a14:	72 d5                	jb     8009eb <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a16:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a2b:	74 33                	je     800a60 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a2d:	eb 17                	jmp    800a46 <strlcpy+0x2b>
			*dst++ = *src++;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8d 50 01             	lea    0x1(%eax),%edx
  800a35:	89 55 08             	mov    %edx,0x8(%ebp)
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a3e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a41:	0f b6 12             	movzbl (%edx),%edx
  800a44:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a46:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a4e:	74 0a                	je     800a5a <strlcpy+0x3f>
  800a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a53:	0f b6 00             	movzbl (%eax),%eax
  800a56:	84 c0                	test   %al,%al
  800a58:	75 d5                	jne    800a2f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a60:	8b 55 08             	mov    0x8(%ebp),%edx
  800a63:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a66:	29 c2                	sub    %eax,%edx
  800a68:	89 d0                	mov    %edx,%eax
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a6f:	eb 08                	jmp    800a79 <strcmp+0xd>
		p++, q++;
  800a71:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a75:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	0f b6 00             	movzbl (%eax),%eax
  800a7f:	84 c0                	test   %al,%al
  800a81:	74 10                	je     800a93 <strcmp+0x27>
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	0f b6 10             	movzbl (%eax),%edx
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	0f b6 00             	movzbl (%eax),%eax
  800a8f:	38 c2                	cmp    %al,%dl
  800a91:	74 de                	je     800a71 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	0f b6 00             	movzbl (%eax),%eax
  800a99:	0f b6 d0             	movzbl %al,%edx
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	0f b6 00             	movzbl (%eax),%eax
  800aa2:	0f b6 c0             	movzbl %al,%eax
  800aa5:	29 c2                	sub    %eax,%edx
  800aa7:	89 d0                	mov    %edx,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800aae:	eb 0c                	jmp    800abc <strncmp+0x11>
		n--, p++, q++;
  800ab0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ab4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ab8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800abc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac0:	74 1a                	je     800adc <strncmp+0x31>
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	0f b6 00             	movzbl (%eax),%eax
  800ac8:	84 c0                	test   %al,%al
  800aca:	74 10                	je     800adc <strncmp+0x31>
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	0f b6 10             	movzbl (%eax),%edx
  800ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad5:	0f b6 00             	movzbl (%eax),%eax
  800ad8:	38 c2                	cmp    %al,%dl
  800ada:	74 d4                	je     800ab0 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800adc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ae0:	75 07                	jne    800ae9 <strncmp+0x3e>
		return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	eb 16                	jmp    800aff <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 00             	movzbl (%eax),%eax
  800aef:	0f b6 d0             	movzbl %al,%edx
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	0f b6 00             	movzbl (%eax),%eax
  800af8:	0f b6 c0             	movzbl %al,%eax
  800afb:	29 c2                	sub    %eax,%edx
  800afd:	89 d0                	mov    %edx,%eax
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 04             	sub    $0x4,%esp
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b0d:	eb 14                	jmp    800b23 <strchr+0x22>
		if (*s == c)
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	0f b6 00             	movzbl (%eax),%eax
  800b15:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b18:	75 05                	jne    800b1f <strchr+0x1e>
			return (char *) s;
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	eb 13                	jmp    800b32 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	0f b6 00             	movzbl (%eax),%eax
  800b29:	84 c0                	test   %al,%al
  800b2b:	75 e2                	jne    800b0f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	83 ec 04             	sub    $0x4,%esp
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b40:	eb 11                	jmp    800b53 <strfind+0x1f>
		if (*s == c)
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	0f b6 00             	movzbl (%eax),%eax
  800b48:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b4b:	75 02                	jne    800b4f <strfind+0x1b>
			break;
  800b4d:	eb 0e                	jmp    800b5d <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	0f b6 00             	movzbl (%eax),%eax
  800b59:	84 c0                	test   %al,%al
  800b5b:	75 e5                	jne    800b42 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b6a:	75 05                	jne    800b71 <memset+0xf>
		return v;
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	eb 5c                	jmp    800bcd <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	83 e0 03             	and    $0x3,%eax
  800b77:	85 c0                	test   %eax,%eax
  800b79:	75 41                	jne    800bbc <memset+0x5a>
  800b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7e:	83 e0 03             	and    $0x3,%eax
  800b81:	85 c0                	test   %eax,%eax
  800b83:	75 37                	jne    800bbc <memset+0x5a>
		c &= 0xFF;
  800b85:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8f:	c1 e0 18             	shl    $0x18,%eax
  800b92:	89 c2                	mov    %eax,%edx
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b97:	c1 e0 10             	shl    $0x10,%eax
  800b9a:	09 c2                	or     %eax,%edx
  800b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9f:	c1 e0 08             	shl    $0x8,%eax
  800ba2:	09 d0                	or     %edx,%eax
  800ba4:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
  800baa:	c1 e8 02             	shr    $0x2,%eax
  800bad:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	fc                   	cld    
  800bb8:	f3 ab                	rep stos %eax,%es:(%edi)
  800bba:	eb 0e                	jmp    800bca <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	fc                   	cld    
  800bc8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bcd:	5f                   	pop    %edi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800beb:	73 6d                	jae    800c5a <memmove+0x8a>
  800bed:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf3:	01 d0                	add    %edx,%eax
  800bf5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bf8:	76 60                	jbe    800c5a <memmove+0x8a>
		s += n;
  800bfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfd:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c00:	8b 45 10             	mov    0x10(%ebp),%eax
  800c03:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c09:	83 e0 03             	and    $0x3,%eax
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	75 2f                	jne    800c3f <memmove+0x6f>
  800c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c13:	83 e0 03             	and    $0x3,%eax
  800c16:	85 c0                	test   %eax,%eax
  800c18:	75 25                	jne    800c3f <memmove+0x6f>
  800c1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1d:	83 e0 03             	and    $0x3,%eax
  800c20:	85 c0                	test   %eax,%eax
  800c22:	75 1b                	jne    800c3f <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c27:	83 e8 04             	sub    $0x4,%eax
  800c2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c2d:	83 ea 04             	sub    $0x4,%edx
  800c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c33:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	fd                   	std    
  800c3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3d:	eb 18                	jmp    800c57 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c42:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c48:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	89 c1                	mov    %eax,%ecx
  800c54:	fd                   	std    
  800c55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c57:	fc                   	cld    
  800c58:	eb 45                	jmp    800c9f <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5d:	83 e0 03             	and    $0x3,%eax
  800c60:	85 c0                	test   %eax,%eax
  800c62:	75 2b                	jne    800c8f <memmove+0xbf>
  800c64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c67:	83 e0 03             	and    $0x3,%eax
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	75 21                	jne    800c8f <memmove+0xbf>
  800c6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c71:	83 e0 03             	and    $0x3,%eax
  800c74:	85 c0                	test   %eax,%eax
  800c76:	75 17                	jne    800c8f <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	c1 e8 02             	shr    $0x2,%eax
  800c7e:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c83:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c86:	89 c7                	mov    %eax,%edi
  800c88:	89 d6                	mov    %edx,%esi
  800c8a:	fc                   	cld    
  800c8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c8d:	eb 10                	jmp    800c9f <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c92:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c95:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c98:	89 c7                	mov    %eax,%edi
  800c9a:	89 d6                	mov    %edx,%esi
  800c9c:	fc                   	cld    
  800c9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	89 04 24             	mov    %eax,(%esp)
  800cc4:	e8 07 ff ff ff       	call   800bd0 <memmove>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cda:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cdd:	eb 30                	jmp    800d0f <memcmp+0x44>
		if (*s1 != *s2)
  800cdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce2:	0f b6 10             	movzbl (%eax),%edx
  800ce5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ce8:	0f b6 00             	movzbl (%eax),%eax
  800ceb:	38 c2                	cmp    %al,%dl
  800ced:	74 18                	je     800d07 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf2:	0f b6 00             	movzbl (%eax),%eax
  800cf5:	0f b6 d0             	movzbl %al,%edx
  800cf8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cfb:	0f b6 00             	movzbl (%eax),%eax
  800cfe:	0f b6 c0             	movzbl %al,%eax
  800d01:	29 c2                	sub    %eax,%edx
  800d03:	89 d0                	mov    %edx,%eax
  800d05:	eb 1a                	jmp    800d21 <memcmp+0x56>
		s1++, s2++;
  800d07:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d0b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d12:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d15:	89 55 10             	mov    %edx,0x10(%ebp)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	75 c3                	jne    800cdf <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d29:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	01 d0                	add    %edx,%eax
  800d31:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d34:	eb 13                	jmp    800d49 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	0f b6 10             	movzbl (%eax),%edx
  800d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3f:	38 c2                	cmp    %al,%dl
  800d41:	75 02                	jne    800d45 <memfind+0x22>
			break;
  800d43:	eb 0c                	jmp    800d51 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d4f:	72 e5                	jb     800d36 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d5c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d63:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6a:	eb 04                	jmp    800d70 <strtol+0x1a>
		s++;
  800d6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	0f b6 00             	movzbl (%eax),%eax
  800d76:	3c 20                	cmp    $0x20,%al
  800d78:	74 f2                	je     800d6c <strtol+0x16>
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	0f b6 00             	movzbl (%eax),%eax
  800d80:	3c 09                	cmp    $0x9,%al
  800d82:	74 e8                	je     800d6c <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	0f b6 00             	movzbl (%eax),%eax
  800d8a:	3c 2b                	cmp    $0x2b,%al
  800d8c:	75 06                	jne    800d94 <strtol+0x3e>
		s++;
  800d8e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d92:	eb 15                	jmp    800da9 <strtol+0x53>
	else if (*s == '-')
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	3c 2d                	cmp    $0x2d,%al
  800d9c:	75 0b                	jne    800da9 <strtol+0x53>
		s++, neg = 1;
  800d9e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dad:	74 06                	je     800db5 <strtol+0x5f>
  800daf:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800db3:	75 24                	jne    800dd9 <strtol+0x83>
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	0f b6 00             	movzbl (%eax),%eax
  800dbb:	3c 30                	cmp    $0x30,%al
  800dbd:	75 1a                	jne    800dd9 <strtol+0x83>
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	83 c0 01             	add    $0x1,%eax
  800dc5:	0f b6 00             	movzbl (%eax),%eax
  800dc8:	3c 78                	cmp    $0x78,%al
  800dca:	75 0d                	jne    800dd9 <strtol+0x83>
		s += 2, base = 16;
  800dcc:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dd0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dd7:	eb 2a                	jmp    800e03 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800dd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ddd:	75 17                	jne    800df6 <strtol+0xa0>
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	3c 30                	cmp    $0x30,%al
  800de7:	75 0d                	jne    800df6 <strtol+0xa0>
		s++, base = 8;
  800de9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ded:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800df4:	eb 0d                	jmp    800e03 <strtol+0xad>
	else if (base == 0)
  800df6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfa:	75 07                	jne    800e03 <strtol+0xad>
		base = 10;
  800dfc:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	0f b6 00             	movzbl (%eax),%eax
  800e09:	3c 2f                	cmp    $0x2f,%al
  800e0b:	7e 1b                	jle    800e28 <strtol+0xd2>
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	0f b6 00             	movzbl (%eax),%eax
  800e13:	3c 39                	cmp    $0x39,%al
  800e15:	7f 11                	jg     800e28 <strtol+0xd2>
			dig = *s - '0';
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 00             	movzbl (%eax),%eax
  800e1d:	0f be c0             	movsbl %al,%eax
  800e20:	83 e8 30             	sub    $0x30,%eax
  800e23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e26:	eb 48                	jmp    800e70 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	0f b6 00             	movzbl (%eax),%eax
  800e2e:	3c 60                	cmp    $0x60,%al
  800e30:	7e 1b                	jle    800e4d <strtol+0xf7>
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	0f b6 00             	movzbl (%eax),%eax
  800e38:	3c 7a                	cmp    $0x7a,%al
  800e3a:	7f 11                	jg     800e4d <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	0f b6 00             	movzbl (%eax),%eax
  800e42:	0f be c0             	movsbl %al,%eax
  800e45:	83 e8 57             	sub    $0x57,%eax
  800e48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e4b:	eb 23                	jmp    800e70 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e50:	0f b6 00             	movzbl (%eax),%eax
  800e53:	3c 40                	cmp    $0x40,%al
  800e55:	7e 3d                	jle    800e94 <strtol+0x13e>
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	0f b6 00             	movzbl (%eax),%eax
  800e5d:	3c 5a                	cmp    $0x5a,%al
  800e5f:	7f 33                	jg     800e94 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	0f b6 00             	movzbl (%eax),%eax
  800e67:	0f be c0             	movsbl %al,%eax
  800e6a:	83 e8 37             	sub    $0x37,%eax
  800e6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e73:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e76:	7c 02                	jl     800e7a <strtol+0x124>
			break;
  800e78:	eb 1a                	jmp    800e94 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e7a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e7e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e81:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8a:	01 d0                	add    %edx,%eax
  800e8c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e8f:	e9 6f ff ff ff       	jmp    800e03 <strtol+0xad>

	if (endptr)
  800e94:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e98:	74 08                	je     800ea2 <strtol+0x14c>
		*endptr = (char *) s;
  800e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ea2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ea6:	74 07                	je     800eaf <strtol+0x159>
  800ea8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800eab:	f7 d8                	neg    %eax
  800ead:	eb 03                	jmp    800eb2 <strtol+0x15c>
  800eaf:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	8b 55 10             	mov    0x10(%ebp),%edx
  800ec3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ec6:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ec9:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ecc:	8b 75 20             	mov    0x20(%ebp),%esi
  800ecf:	cd 30                	int    $0x30
  800ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed8:	74 30                	je     800f0a <syscall+0x56>
  800eda:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ede:	7e 2a                	jle    800f0a <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eee:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800f05:	e8 84 f2 ff ff       	call   80018e <_panic>

	return ret;
  800f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f0d:	83 c4 3c             	add    $0x3c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f25:	00 
  800f26:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f35:	00 
  800f36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f39:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f48:	00 
  800f49:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f50:	e8 5f ff ff ff       	call   800eb4 <syscall>
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f5d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f64:	00 
  800f65:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f74:	00 
  800f75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f94:	e8 1b ff ff ff       	call   800eb4 <syscall>
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    

00800f9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fab:	00 
  800fac:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc3:	00 
  800fc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fcf:	00 
  800fd0:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fd7:	e8 d8 fe ff ff       	call   800eb4 <syscall>
}
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fe4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800feb:	00 
  800fec:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801003:	00 
  801004:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80100b:	00 
  80100c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801013:	00 
  801014:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80101b:	e8 94 fe ff ff       	call   800eb4 <syscall>
}
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <sys_yield>:

void
sys_yield(void)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801028:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80102f:	00 
  801030:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801037:	00 
  801038:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80103f:	00 
  801040:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801047:	00 
  801048:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80105f:	e8 50 fe ff ff       	call   800eb4 <syscall>
}
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80106c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80106f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801072:	8b 45 08             	mov    0x8(%ebp),%eax
  801075:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80107c:	00 
  80107d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801084:	00 
  801085:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801089:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80108d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010a0:	e8 0f fe ff ff       	call   800eb4 <syscall>
}
  8010a5:	c9                   	leave  
  8010a6:	c3                   	ret    

008010a7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010af:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010c2:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010c6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d9:	00 
  8010da:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010e1:	e8 ce fd ff ff       	call   800eb4 <syscall>
}
  8010e6:	83 c4 20             	add    $0x20,%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801100:	00 
  801101:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801108:	00 
  801109:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801110:	00 
  801111:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801115:	89 44 24 08          	mov    %eax,0x8(%esp)
  801119:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801128:	e8 87 fd ff ff       	call   800eb4 <syscall>
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801135:	8b 55 0c             	mov    0xc(%ebp),%edx
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801142:	00 
  801143:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114a:	00 
  80114b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801152:	00 
  801153:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801162:	00 
  801163:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80116a:	e8 45 fd ff ff       	call   800eb4 <syscall>
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117a:	8b 45 08             	mov    0x8(%ebp),%eax
  80117d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801184:	00 
  801185:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80118c:	00 
  80118d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801194:	00 
  801195:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801199:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011a4:	00 
  8011a5:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011ac:	e8 03 fd ff ff       	call   800eb4 <syscall>
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011b9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011bc:	8b 55 10             	mov    0x10(%ebp),%edx
  8011bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011c9:	00 
  8011ca:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011ce:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011e4:	00 
  8011e5:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011ec:	e8 c3 fc ff ff       	call   800eb4 <syscall>
}
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801203:	00 
  801204:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80120b:	00 
  80120c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801213:	00 
  801214:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80121b:	00 
  80121c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801220:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801227:	00 
  801228:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80122f:	e8 80 fc ff ff       	call   800eb4 <syscall>
}
  801234:	c9                   	leave  
  801235:	c3                   	ret    
  801236:	66 90                	xchg   %ax,%ax
  801238:	66 90                	xchg   %ax,%ax
  80123a:	66 90                	xchg   %ax,%ax
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <__udivdi3>:
  801240:	55                   	push   %ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	8b 44 24 28          	mov    0x28(%esp),%eax
  80124a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80124e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801252:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801256:	85 c0                	test   %eax,%eax
  801258:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80125c:	89 ea                	mov    %ebp,%edx
  80125e:	89 0c 24             	mov    %ecx,(%esp)
  801261:	75 2d                	jne    801290 <__udivdi3+0x50>
  801263:	39 e9                	cmp    %ebp,%ecx
  801265:	77 61                	ja     8012c8 <__udivdi3+0x88>
  801267:	85 c9                	test   %ecx,%ecx
  801269:	89 ce                	mov    %ecx,%esi
  80126b:	75 0b                	jne    801278 <__udivdi3+0x38>
  80126d:	b8 01 00 00 00       	mov    $0x1,%eax
  801272:	31 d2                	xor    %edx,%edx
  801274:	f7 f1                	div    %ecx
  801276:	89 c6                	mov    %eax,%esi
  801278:	31 d2                	xor    %edx,%edx
  80127a:	89 e8                	mov    %ebp,%eax
  80127c:	f7 f6                	div    %esi
  80127e:	89 c5                	mov    %eax,%ebp
  801280:	89 f8                	mov    %edi,%eax
  801282:	f7 f6                	div    %esi
  801284:	89 ea                	mov    %ebp,%edx
  801286:	83 c4 0c             	add    $0xc,%esp
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	39 e8                	cmp    %ebp,%eax
  801292:	77 24                	ja     8012b8 <__udivdi3+0x78>
  801294:	0f bd e8             	bsr    %eax,%ebp
  801297:	83 f5 1f             	xor    $0x1f,%ebp
  80129a:	75 3c                	jne    8012d8 <__udivdi3+0x98>
  80129c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012a0:	39 34 24             	cmp    %esi,(%esp)
  8012a3:	0f 86 9f 00 00 00    	jbe    801348 <__udivdi3+0x108>
  8012a9:	39 d0                	cmp    %edx,%eax
  8012ab:	0f 82 97 00 00 00    	jb     801348 <__udivdi3+0x108>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	31 c0                	xor    %eax,%eax
  8012bc:	83 c4 0c             	add    $0xc,%esp
  8012bf:	5e                   	pop    %esi
  8012c0:	5f                   	pop    %edi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    
  8012c3:	90                   	nop
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	f7 f1                	div    %ecx
  8012cc:	31 d2                	xor    %edx,%edx
  8012ce:	83 c4 0c             	add    $0xc,%esp
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	89 e9                	mov    %ebp,%ecx
  8012da:	8b 3c 24             	mov    (%esp),%edi
  8012dd:	d3 e0                	shl    %cl,%eax
  8012df:	89 c6                	mov    %eax,%esi
  8012e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e6:	29 e8                	sub    %ebp,%eax
  8012e8:	89 c1                	mov    %eax,%ecx
  8012ea:	d3 ef                	shr    %cl,%edi
  8012ec:	89 e9                	mov    %ebp,%ecx
  8012ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012f2:	8b 3c 24             	mov    (%esp),%edi
  8012f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012f9:	89 d6                	mov    %edx,%esi
  8012fb:	d3 e7                	shl    %cl,%edi
  8012fd:	89 c1                	mov    %eax,%ecx
  8012ff:	89 3c 24             	mov    %edi,(%esp)
  801302:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801306:	d3 ee                	shr    %cl,%esi
  801308:	89 e9                	mov    %ebp,%ecx
  80130a:	d3 e2                	shl    %cl,%edx
  80130c:	89 c1                	mov    %eax,%ecx
  80130e:	d3 ef                	shr    %cl,%edi
  801310:	09 d7                	or     %edx,%edi
  801312:	89 f2                	mov    %esi,%edx
  801314:	89 f8                	mov    %edi,%eax
  801316:	f7 74 24 08          	divl   0x8(%esp)
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	f7 24 24             	mull   (%esp)
  801321:	39 d6                	cmp    %edx,%esi
  801323:	89 14 24             	mov    %edx,(%esp)
  801326:	72 30                	jb     801358 <__udivdi3+0x118>
  801328:	8b 54 24 04          	mov    0x4(%esp),%edx
  80132c:	89 e9                	mov    %ebp,%ecx
  80132e:	d3 e2                	shl    %cl,%edx
  801330:	39 c2                	cmp    %eax,%edx
  801332:	73 05                	jae    801339 <__udivdi3+0xf9>
  801334:	3b 34 24             	cmp    (%esp),%esi
  801337:	74 1f                	je     801358 <__udivdi3+0x118>
  801339:	89 f8                	mov    %edi,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	e9 7a ff ff ff       	jmp    8012bc <__udivdi3+0x7c>
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	b8 01 00 00 00       	mov    $0x1,%eax
  80134f:	e9 68 ff ff ff       	jmp    8012bc <__udivdi3+0x7c>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	8d 47 ff             	lea    -0x1(%edi),%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	83 c4 0c             	add    $0xc,%esp
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
  801364:	66 90                	xchg   %ax,%ax
  801366:	66 90                	xchg   %ax,%ax
  801368:	66 90                	xchg   %ax,%ax
  80136a:	66 90                	xchg   %ax,%ax
  80136c:	66 90                	xchg   %ax,%ax
  80136e:	66 90                	xchg   %ax,%ax

00801370 <__umoddi3>:
  801370:	55                   	push   %ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	83 ec 14             	sub    $0x14,%esp
  801376:	8b 44 24 28          	mov    0x28(%esp),%eax
  80137a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80137e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801382:	89 c7                	mov    %eax,%edi
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 44 24 30          	mov    0x30(%esp),%eax
  80138c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801390:	89 34 24             	mov    %esi,(%esp)
  801393:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801397:	85 c0                	test   %eax,%eax
  801399:	89 c2                	mov    %eax,%edx
  80139b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80139f:	75 17                	jne    8013b8 <__umoddi3+0x48>
  8013a1:	39 fe                	cmp    %edi,%esi
  8013a3:	76 4b                	jbe    8013f0 <__umoddi3+0x80>
  8013a5:	89 c8                	mov    %ecx,%eax
  8013a7:	89 fa                	mov    %edi,%edx
  8013a9:	f7 f6                	div    %esi
  8013ab:	89 d0                	mov    %edx,%eax
  8013ad:	31 d2                	xor    %edx,%edx
  8013af:	83 c4 14             	add    $0x14,%esp
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    
  8013b6:	66 90                	xchg   %ax,%ax
  8013b8:	39 f8                	cmp    %edi,%eax
  8013ba:	77 54                	ja     801410 <__umoddi3+0xa0>
  8013bc:	0f bd e8             	bsr    %eax,%ebp
  8013bf:	83 f5 1f             	xor    $0x1f,%ebp
  8013c2:	75 5c                	jne    801420 <__umoddi3+0xb0>
  8013c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013c8:	39 3c 24             	cmp    %edi,(%esp)
  8013cb:	0f 87 e7 00 00 00    	ja     8014b8 <__umoddi3+0x148>
  8013d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d5:	29 f1                	sub    %esi,%ecx
  8013d7:	19 c7                	sbb    %eax,%edi
  8013d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013e9:	83 c4 14             	add    $0x14,%esp
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    
  8013f0:	85 f6                	test   %esi,%esi
  8013f2:	89 f5                	mov    %esi,%ebp
  8013f4:	75 0b                	jne    801401 <__umoddi3+0x91>
  8013f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	f7 f6                	div    %esi
  8013ff:	89 c5                	mov    %eax,%ebp
  801401:	8b 44 24 04          	mov    0x4(%esp),%eax
  801405:	31 d2                	xor    %edx,%edx
  801407:	f7 f5                	div    %ebp
  801409:	89 c8                	mov    %ecx,%eax
  80140b:	f7 f5                	div    %ebp
  80140d:	eb 9c                	jmp    8013ab <__umoddi3+0x3b>
  80140f:	90                   	nop
  801410:	89 c8                	mov    %ecx,%eax
  801412:	89 fa                	mov    %edi,%edx
  801414:	83 c4 14             	add    $0x14,%esp
  801417:	5e                   	pop    %esi
  801418:	5f                   	pop    %edi
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    
  80141b:	90                   	nop
  80141c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801420:	8b 04 24             	mov    (%esp),%eax
  801423:	be 20 00 00 00       	mov    $0x20,%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	29 ee                	sub    %ebp,%esi
  80142c:	d3 e2                	shl    %cl,%edx
  80142e:	89 f1                	mov    %esi,%ecx
  801430:	d3 e8                	shr    %cl,%eax
  801432:	89 e9                	mov    %ebp,%ecx
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	8b 04 24             	mov    (%esp),%eax
  80143b:	09 54 24 04          	or     %edx,0x4(%esp)
  80143f:	89 fa                	mov    %edi,%edx
  801441:	d3 e0                	shl    %cl,%eax
  801443:	89 f1                	mov    %esi,%ecx
  801445:	89 44 24 08          	mov    %eax,0x8(%esp)
  801449:	8b 44 24 10          	mov    0x10(%esp),%eax
  80144d:	d3 ea                	shr    %cl,%edx
  80144f:	89 e9                	mov    %ebp,%ecx
  801451:	d3 e7                	shl    %cl,%edi
  801453:	89 f1                	mov    %esi,%ecx
  801455:	d3 e8                	shr    %cl,%eax
  801457:	89 e9                	mov    %ebp,%ecx
  801459:	09 f8                	or     %edi,%eax
  80145b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80145f:	f7 74 24 04          	divl   0x4(%esp)
  801463:	d3 e7                	shl    %cl,%edi
  801465:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801469:	89 d7                	mov    %edx,%edi
  80146b:	f7 64 24 08          	mull   0x8(%esp)
  80146f:	39 d7                	cmp    %edx,%edi
  801471:	89 c1                	mov    %eax,%ecx
  801473:	89 14 24             	mov    %edx,(%esp)
  801476:	72 2c                	jb     8014a4 <__umoddi3+0x134>
  801478:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80147c:	72 22                	jb     8014a0 <__umoddi3+0x130>
  80147e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801482:	29 c8                	sub    %ecx,%eax
  801484:	19 d7                	sbb    %edx,%edi
  801486:	89 e9                	mov    %ebp,%ecx
  801488:	89 fa                	mov    %edi,%edx
  80148a:	d3 e8                	shr    %cl,%eax
  80148c:	89 f1                	mov    %esi,%ecx
  80148e:	d3 e2                	shl    %cl,%edx
  801490:	89 e9                	mov    %ebp,%ecx
  801492:	d3 ef                	shr    %cl,%edi
  801494:	09 d0                	or     %edx,%eax
  801496:	89 fa                	mov    %edi,%edx
  801498:	83 c4 14             	add    $0x14,%esp
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    
  80149f:	90                   	nop
  8014a0:	39 d7                	cmp    %edx,%edi
  8014a2:	75 da                	jne    80147e <__umoddi3+0x10e>
  8014a4:	8b 14 24             	mov    (%esp),%edx
  8014a7:	89 c1                	mov    %eax,%ecx
  8014a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014b1:	eb cb                	jmp    80147e <__umoddi3+0x10e>
  8014b3:	90                   	nop
  8014b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014bc:	0f 82 0f ff ff ff    	jb     8013d1 <__umoddi3+0x61>
  8014c2:	e9 1a ff ff ff       	jmp    8013e1 <__umoddi3+0x71>
