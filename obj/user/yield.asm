
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 71 00 00 00       	call   8000a2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  800039:	a1 04 20 80 00       	mov    0x802004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	89 44 24 04          	mov    %eax,0x4(%esp)
  800045:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  80004c:	e8 74 01 00 00       	call   8001c5 <cprintf>
	for (i = 0; i < 5; i++) {
  800051:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800058:	eb 28                	jmp    800082 <umain+0x4f>
		sys_yield();
  80005a:	e8 df 0e 00 00       	call   800f3e <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005f:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800064:	8b 40 48             	mov    0x48(%eax),%eax
  800067:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80006e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800072:	c7 04 24 a0 14 80 00 	movl   $0x8014a0,(%esp)
  800079:	e8 47 01 00 00       	call   8001c5 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  80007e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800082:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
  800086:	7e d2                	jle    80005a <umain+0x27>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800088:	a1 04 20 80 00       	mov    0x802004,%eax
  80008d:	8b 40 48             	mov    0x48(%eax),%eax
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
  800094:	c7 04 24 cc 14 80 00 	movl   $0x8014cc,(%esp)
  80009b:	e8 25 01 00 00       	call   8001c5 <cprintf>
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000a8:	e8 4d 0e 00 00       	call   800efa <sys_getenvid>
  8000ad:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b2:	c1 e0 02             	shl    $0x2,%eax
  8000b5:	89 c2                	mov    %eax,%edx
  8000b7:	c1 e2 05             	shl    $0x5,%edx
  8000ba:	29 c2                	sub    %eax,%edx
  8000bc:	89 d0                	mov    %edx,%eax
  8000be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000cc:	7e 0a                	jle    8000d8 <libmain+0x36>
		binaryname = argv[0];
  8000ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d1:	8b 00                	mov    (%eax),%eax
  8000d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000df:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 49 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ea:	e8 02 00 00 00       	call   8000f1 <exit>
}
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    

008000f1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fe:	e8 b4 0d 00 00       	call   800eb7 <sys_env_destroy>
}
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80010b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010e:	8b 00                	mov    (%eax),%eax
  800110:	8d 48 01             	lea    0x1(%eax),%ecx
  800113:	8b 55 0c             	mov    0xc(%ebp),%edx
  800116:	89 0a                	mov    %ecx,(%edx)
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	89 d1                	mov    %edx,%ecx
  80011d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800120:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800124:	8b 45 0c             	mov    0xc(%ebp),%eax
  800127:	8b 00                	mov    (%eax),%eax
  800129:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012e:	75 20                	jne    800150 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	8b 00                	mov    (%eax),%eax
  800135:	8b 55 0c             	mov    0xc(%ebp),%edx
  800138:	83 c2 08             	add    $0x8,%edx
  80013b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013f:	89 14 24             	mov    %edx,(%esp)
  800142:	e8 ea 0c 00 00       	call   800e31 <sys_cputs>
		b->idx = 0;
  800147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800150:	8b 45 0c             	mov    0xc(%ebp),%eax
  800153:	8b 40 04             	mov    0x4(%eax),%eax
  800156:	8d 50 01             	lea    0x1(%eax),%edx
  800159:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800171:	00 00 00 
	b.cnt = 0;
  800174:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800181:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800192:	89 44 24 04          	mov    %eax,0x4(%esp)
  800196:	c7 04 24 05 01 80 00 	movl   $0x800105,(%esp)
  80019d:	e8 bd 01 00 00       	call   80035f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b2:	83 c0 08             	add    $0x8,%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 74 0c 00 00       	call   800e31 <sys_cputs>

	return b.cnt;
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 7e ff ff ff       	call   800161 <vcprintf>
  8001e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001e9:	c9                   	leave  
  8001ea:	c3                   	ret    

008001eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 34             	sub    $0x34,%esp
  8001f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fe:	8b 45 18             	mov    0x18(%ebp),%eax
  800201:	ba 00 00 00 00       	mov    $0x0,%edx
  800206:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800209:	77 72                	ja     80027d <printnum+0x92>
  80020b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80020e:	72 05                	jb     800215 <printnum+0x2a>
  800210:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800213:	77 68                	ja     80027d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800215:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800218:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021b:	8b 45 18             	mov    0x18(%ebp),%eax
  80021e:	ba 00 00 00 00       	mov    $0x0,%edx
  800223:	89 44 24 08          	mov    %eax,0x8(%esp)
  800227:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80022b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80022e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800231:	89 04 24             	mov    %eax,(%esp)
  800234:	89 54 24 04          	mov    %edx,0x4(%esp)
  800238:	e8 b3 0f 00 00       	call   8011f0 <__udivdi3>
  80023d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800240:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800244:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800248:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80024b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 82 ff ff ff       	call   8001eb <printnum>
  800269:	eb 1c                	jmp    800287 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800272:	8b 45 20             	mov    0x20(%ebp),%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
  80027b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800281:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800285:	7f e4                	jg     80026b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800287:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800295:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800299:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a4:	e8 77 10 00 00       	call   801320 <__umoddi3>
  8002a9:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8002ae:	0f b6 00             	movzbl (%eax),%eax
  8002b1:	0f be c0             	movsbl %al,%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	ff d0                	call   *%eax
}
  8002c3:	83 c4 34             	add    $0x34,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002d0:	7e 14                	jle    8002e6 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 00                	mov    (%eax),%eax
  8002d7:	8d 48 08             	lea    0x8(%eax),%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	89 0a                	mov    %ecx,(%edx)
  8002df:	8b 50 04             	mov    0x4(%eax),%edx
  8002e2:	8b 00                	mov    (%eax),%eax
  8002e4:	eb 30                	jmp    800316 <getuint+0x4d>
	else if (lflag)
  8002e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002ea:	74 16                	je     800302 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	8b 00                	mov    (%eax),%eax
  8002f1:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 0a                	mov    %ecx,(%edx)
  8002f9:	8b 00                	mov    (%eax),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 14                	jmp    800316 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	8b 00                	mov    (%eax),%eax
  800307:	8d 48 04             	lea    0x4(%eax),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	89 0a                	mov    %ecx,(%edx)
  80030f:	8b 00                	mov    (%eax),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80031f:	7e 14                	jle    800335 <getint+0x1d>
		return va_arg(*ap, long long);
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	8b 00                	mov    (%eax),%eax
  800326:	8d 48 08             	lea    0x8(%eax),%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 0a                	mov    %ecx,(%edx)
  80032e:	8b 50 04             	mov    0x4(%eax),%edx
  800331:	8b 00                	mov    (%eax),%eax
  800333:	eb 28                	jmp    80035d <getint+0x45>
	else if (lflag)
  800335:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800339:	74 12                	je     80034d <getint+0x35>
		return va_arg(*ap, long);
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	8b 00                	mov    (%eax),%eax
  800340:	8d 48 04             	lea    0x4(%eax),%ecx
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	89 0a                	mov    %ecx,(%edx)
  800348:	8b 00                	mov    (%eax),%eax
  80034a:	99                   	cltd   
  80034b:	eb 10                	jmp    80035d <getint+0x45>
	else
		return va_arg(*ap, int);
  80034d:	8b 45 08             	mov    0x8(%ebp),%eax
  800350:	8b 00                	mov    (%eax),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	8b 55 08             	mov    0x8(%ebp),%edx
  800358:	89 0a                	mov    %ecx,(%edx)
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	99                   	cltd   
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800367:	eb 18                	jmp    800381 <vprintfmt+0x22>
			if (ch == '\0')
  800369:	85 db                	test   %ebx,%ebx
  80036b:	75 05                	jne    800372 <vprintfmt+0x13>
				return;
  80036d:	e9 cc 03 00 00       	jmp    80073e <vprintfmt+0x3df>
			putch(ch, putdat);
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
  800375:	89 44 24 04          	mov    %eax,0x4(%esp)
  800379:	89 1c 24             	mov    %ebx,(%esp)
  80037c:	8b 45 08             	mov    0x8(%ebp),%eax
  80037f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800381:	8b 45 10             	mov    0x10(%ebp),%eax
  800384:	8d 50 01             	lea    0x1(%eax),%edx
  800387:	89 55 10             	mov    %edx,0x10(%ebp)
  80038a:	0f b6 00             	movzbl (%eax),%eax
  80038d:	0f b6 d8             	movzbl %al,%ebx
  800390:	83 fb 25             	cmp    $0x25,%ebx
  800393:	75 d4                	jne    800369 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800395:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800399:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003a0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b8:	8d 50 01             	lea    0x1(%eax),%edx
  8003bb:	89 55 10             	mov    %edx,0x10(%ebp)
  8003be:	0f b6 00             	movzbl (%eax),%eax
  8003c1:	0f b6 d8             	movzbl %al,%ebx
  8003c4:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003c7:	83 f8 55             	cmp    $0x55,%eax
  8003ca:	0f 87 3d 03 00 00    	ja     80070d <vprintfmt+0x3ae>
  8003d0:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  8003d7:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d9:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003dd:	eb d6                	jmp    8003b5 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003df:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003e3:	eb d0                	jmp    8003b5 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ef:	89 d0                	mov    %edx,%eax
  8003f1:	c1 e0 02             	shl    $0x2,%eax
  8003f4:	01 d0                	add    %edx,%eax
  8003f6:	01 c0                	add    %eax,%eax
  8003f8:	01 d8                	add    %ebx,%eax
  8003fa:	83 e8 30             	sub    $0x30,%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800400:	8b 45 10             	mov    0x10(%ebp),%eax
  800403:	0f b6 00             	movzbl (%eax),%eax
  800406:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800409:	83 fb 2f             	cmp    $0x2f,%ebx
  80040c:	7e 0b                	jle    800419 <vprintfmt+0xba>
  80040e:	83 fb 39             	cmp    $0x39,%ebx
  800411:	7f 06                	jg     800419 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800413:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800417:	eb d3                	jmp    8003ec <vprintfmt+0x8d>
			goto process_precision;
  800419:	eb 33                	jmp    80044e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	8b 00                	mov    (%eax),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800429:	eb 23                	jmp    80044e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80042b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042f:	79 0c                	jns    80043d <vprintfmt+0xde>
				width = 0;
  800431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800438:	e9 78 ff ff ff       	jmp    8003b5 <vprintfmt+0x56>
  80043d:	e9 73 ff ff ff       	jmp    8003b5 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800442:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800449:	e9 67 ff ff ff       	jmp    8003b5 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80044e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800452:	79 12                	jns    800466 <vprintfmt+0x107>
				width = precision, precision = -1;
  800454:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800457:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800461:	e9 4f ff ff ff       	jmp    8003b5 <vprintfmt+0x56>
  800466:	e9 4a ff ff ff       	jmp    8003b5 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80046f:	e9 41 ff ff ff       	jmp    8003b5 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 00                	mov    (%eax),%eax
  80047f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800482:	89 54 24 04          	mov    %edx,0x4(%esp)
  800486:	89 04 24             	mov    %eax,(%esp)
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	ff d0                	call   *%eax
			break;
  80048e:	e9 a5 02 00 00       	jmp    800738 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80049e:	85 db                	test   %ebx,%ebx
  8004a0:	79 02                	jns    8004a4 <vprintfmt+0x145>
				err = -err;
  8004a2:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 fb 09             	cmp    $0x9,%ebx
  8004a7:	7f 0b                	jg     8004b4 <vprintfmt+0x155>
  8004a9:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8004b0:	85 f6                	test   %esi,%esi
  8004b2:	75 23                	jne    8004d7 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004b4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004b8:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8004bf:	00 
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ca:	89 04 24             	mov    %eax,(%esp)
  8004cd:	e8 73 02 00 00       	call   800745 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004d2:	e9 61 02 00 00       	jmp    800738 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004db:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  8004e2:	00 
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	89 04 24             	mov    %eax,(%esp)
  8004f0:	e8 50 02 00 00       	call   800745 <printfmt>
			break;
  8004f5:	e9 3e 02 00 00       	jmp    800738 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 30                	mov    (%eax),%esi
  800505:	85 f6                	test   %esi,%esi
  800507:	75 05                	jne    80050e <vprintfmt+0x1af>
				p = "(null)";
  800509:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	7e 37                	jle    80054b <vprintfmt+0x1ec>
  800514:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800518:	74 31                	je     80054b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	89 34 24             	mov    %esi,(%esp)
  800524:	e8 39 03 00 00       	call   800862 <strnlen>
  800529:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80052c:	eb 17                	jmp    800545 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80052e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800532:	8b 55 0c             	mov    0xc(%ebp),%edx
  800535:	89 54 24 04          	mov    %edx,0x4(%esp)
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800545:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800549:	7f e3                	jg     80052e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054b:	eb 38                	jmp    800585 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80054d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800551:	74 1f                	je     800572 <vprintfmt+0x213>
  800553:	83 fb 1f             	cmp    $0x1f,%ebx
  800556:	7e 05                	jle    80055d <vprintfmt+0x1fe>
  800558:	83 fb 7e             	cmp    $0x7e,%ebx
  80055b:	7e 15                	jle    800572 <vprintfmt+0x213>
					putch('?', putdat);
  80055d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800560:	89 44 24 04          	mov    %eax,0x4(%esp)
  800564:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	ff d0                	call   *%eax
  800570:	eb 0f                	jmp    800581 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	89 1c 24             	mov    %ebx,(%esp)
  80057c:	8b 45 08             	mov    0x8(%ebp),%eax
  80057f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800581:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800585:	89 f0                	mov    %esi,%eax
  800587:	8d 70 01             	lea    0x1(%eax),%esi
  80058a:	0f b6 00             	movzbl (%eax),%eax
  80058d:	0f be d8             	movsbl %al,%ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	74 10                	je     8005a4 <vprintfmt+0x245>
  800594:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800598:	78 b3                	js     80054d <vprintfmt+0x1ee>
  80059a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80059e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a2:	79 a9                	jns    80054d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	eb 17                	jmp    8005bd <vprintfmt+0x25e>
				putch(' ', putdat);
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b7:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c1:	7f e3                	jg     8005a6 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005c3:	e9 70 01 00 00       	jmp    800738 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	89 04 24             	mov    %eax,(%esp)
  8005d5:	e8 3e fd ff ff       	call   800318 <getint>
  8005da:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005dd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	79 26                	jns    800610 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fb:	ff d0                	call   *%eax
				num = -(long long) num;
  8005fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800600:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800603:	f7 d8                	neg    %eax
  800605:	83 d2 00             	adc    $0x0,%edx
  800608:	f7 da                	neg    %edx
  80060a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80060d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800610:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800617:	e9 a8 00 00 00       	jmp    8006c4 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80061f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	e8 9b fc ff ff       	call   8002c9 <getuint>
  80062e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800631:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800634:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80063b:	e9 84 00 00 00       	jmp    8006c4 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800640:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800643:	89 44 24 04          	mov    %eax,0x4(%esp)
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	e8 77 fc ff ff       	call   8002c9 <getuint>
  800652:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800655:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800658:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80065f:	eb 63                	jmp    8006c4 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800661:	8b 45 0c             	mov    0xc(%ebp),%eax
  800664:	89 44 24 04          	mov    %eax,0x4(%esp)
  800668:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066f:	8b 45 08             	mov    0x8(%ebp),%eax
  800672:	ff d0                	call   *%eax
			putch('x', putdat);
  800674:	8b 45 0c             	mov    0xc(%ebp),%eax
  800677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800692:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800695:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006a3:	eb 1f                	jmp    8006c4 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	e8 12 fc ff ff       	call   8002c9 <getuint>
  8006b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006bd:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d2:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	e8 f1 fa ff ff       	call   8001eb <printnum>
			break;
  8006fa:	eb 3c                	jmp    800738 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	89 1c 24             	mov    %ebx,(%esp)
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	ff d0                	call   *%eax
			break;
  80070b:	eb 2b                	jmp    800738 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800724:	eb 04                	jmp    80072a <vprintfmt+0x3cb>
  800726:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	83 e8 01             	sub    $0x1,%eax
  800730:	0f b6 00             	movzbl (%eax),%eax
  800733:	3c 25                	cmp    $0x25,%al
  800735:	75 ef                	jne    800726 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800737:	90                   	nop
		}
	}
  800738:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800739:	e9 43 fc ff ff       	jmp    800381 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80073e:	83 c4 40             	add    $0x40,%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800754:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800758:	8b 45 10             	mov    0x10(%ebp),%eax
  80075b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800762:	89 44 24 04          	mov    %eax,0x4(%esp)
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	89 04 24             	mov    %eax,(%esp)
  80076c:	e8 ee fb ff ff       	call   80035f <vprintfmt>
	va_end(ap);
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
  800779:	8b 40 08             	mov    0x8(%eax),%eax
  80077c:	8d 50 01             	lea    0x1(%eax),%edx
  80077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800782:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800785:	8b 45 0c             	mov    0xc(%ebp),%eax
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078d:	8b 40 04             	mov    0x4(%eax),%eax
  800790:	39 c2                	cmp    %eax,%edx
  800792:	73 12                	jae    8007a6 <sprintputch+0x33>
		*b->buf++ = ch;
  800794:	8b 45 0c             	mov    0xc(%ebp),%eax
  800797:	8b 00                	mov    (%eax),%eax
  800799:	8d 48 01             	lea    0x1(%eax),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079f:	89 0a                	mov    %ecx,(%edx)
  8007a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a4:	88 10                	mov    %dl,(%eax)
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	01 d0                	add    %edx,%eax
  8007bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007cd:	74 06                	je     8007d5 <vsnprintf+0x2d>
  8007cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007d3:	7f 07                	jg     8007dc <vsnprintf+0x34>
		return -E_INVAL;
  8007d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007da:	eb 2a                	jmp    800806 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	c7 04 24 73 07 80 00 	movl   $0x800773,(%esp)
  8007f8:	e8 62 fb ff ff       	call   80035f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800800:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800803:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
  800811:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081b:	8b 45 10             	mov    0x10(%ebp),%eax
  80081e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800822:	8b 45 0c             	mov    0xc(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	89 04 24             	mov    %eax,(%esp)
  80082f:	e8 74 ff ff ff       	call   8007a8 <vsnprintf>
  800834:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800849:	eb 08                	jmp    800853 <strlen+0x17>
		n++;
  80084b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	0f b6 00             	movzbl (%eax),%eax
  800859:	84 c0                	test   %al,%al
  80085b:	75 ee                	jne    80084b <strlen+0xf>
		n++;
	return n;
  80085d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80086f:	eb 0c                	jmp    80087d <strnlen+0x1b>
		n++;
  800871:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800879:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80087d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800881:	74 0a                	je     80088d <strnlen+0x2b>
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	0f b6 00             	movzbl (%eax),%eax
  800889:	84 c0                	test   %al,%al
  80088b:	75 e4                	jne    800871 <strnlen+0xf>
		n++;
	return n;
  80088d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80089e:	90                   	nop
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8d 50 01             	lea    0x1(%eax),%edx
  8008a5:	89 55 08             	mov    %edx,0x8(%ebp)
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008ae:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	88 10                	mov    %dl,(%eax)
  8008b6:	0f b6 00             	movzbl (%eax),%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	75 e2                	jne    80089f <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 69 ff ff ff       	call   80083c <strlen>
  8008d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	01 c2                	add    %eax,%edx
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	89 14 24             	mov    %edx,(%esp)
  8008e8:	e8 a5 ff ff ff       	call   800892 <strcpy>
	return dst;
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800905:	eb 23                	jmp    80092a <strncpy+0x38>
		*dst++ = *src;
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8d 50 01             	lea    0x1(%eax),%edx
  80090d:	89 55 08             	mov    %edx,0x8(%ebp)
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
  800913:	0f b6 12             	movzbl (%edx),%edx
  800916:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	0f b6 00             	movzbl (%eax),%eax
  80091e:	84 c0                	test   %al,%al
  800920:	74 04                	je     800926 <strncpy+0x34>
			src++;
  800922:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800926:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80092a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80092d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800930:	72 d5                	jb     800907 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800932:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800943:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800947:	74 33                	je     80097c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800949:	eb 17                	jmp    800962 <strlcpy+0x2b>
			*dst++ = *src++;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8d 50 01             	lea    0x1(%eax),%edx
  800951:	89 55 08             	mov    %edx,0x8(%ebp)
  800954:	8b 55 0c             	mov    0xc(%ebp),%edx
  800957:	8d 4a 01             	lea    0x1(%edx),%ecx
  80095a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800962:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800966:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80096a:	74 0a                	je     800976 <strlcpy+0x3f>
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	0f b6 00             	movzbl (%eax),%eax
  800972:	84 c0                	test   %al,%al
  800974:	75 d5                	jne    80094b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097c:	8b 55 08             	mov    0x8(%ebp),%edx
  80097f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800982:	29 c2                	sub    %eax,%edx
  800984:	89 d0                	mov    %edx,%eax
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80098b:	eb 08                	jmp    800995 <strcmp+0xd>
		p++, q++;
  80098d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800991:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	84 c0                	test   %al,%al
  80099d:	74 10                	je     8009af <strcmp+0x27>
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 10             	movzbl (%eax),%edx
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	38 c2                	cmp    %al,%dl
  8009ad:	74 de                	je     80098d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 00             	movzbl (%eax),%eax
  8009b5:	0f b6 d0             	movzbl %al,%edx
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	0f b6 00             	movzbl (%eax),%eax
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	29 c2                	sub    %eax,%edx
  8009c3:	89 d0                	mov    %edx,%eax
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009ca:	eb 0c                	jmp    8009d8 <strncmp+0x11>
		n--, p++, q++;
  8009cc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009d0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009d4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009dc:	74 1a                	je     8009f8 <strncmp+0x31>
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 00             	movzbl (%eax),%eax
  8009e4:	84 c0                	test   %al,%al
  8009e6:	74 10                	je     8009f8 <strncmp+0x31>
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 10             	movzbl (%eax),%edx
  8009ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f1:	0f b6 00             	movzbl (%eax),%eax
  8009f4:	38 c2                	cmp    %al,%dl
  8009f6:	74 d4                	je     8009cc <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009fc:	75 07                	jne    800a05 <strncmp+0x3e>
		return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 16                	jmp    800a1b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	0f b6 d0             	movzbl %al,%edx
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	0f b6 00             	movzbl (%eax),%eax
  800a14:	0f b6 c0             	movzbl %al,%eax
  800a17:	29 c2                	sub    %eax,%edx
  800a19:	89 d0                	mov    %edx,%eax
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	83 ec 04             	sub    $0x4,%esp
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a29:	eb 14                	jmp    800a3f <strchr+0x22>
		if (*s == c)
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	0f b6 00             	movzbl (%eax),%eax
  800a31:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a34:	75 05                	jne    800a3b <strchr+0x1e>
			return (char *) s;
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	eb 13                	jmp    800a4e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	0f b6 00             	movzbl (%eax),%eax
  800a45:	84 c0                	test   %al,%al
  800a47:	75 e2                	jne    800a2b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 04             	sub    $0x4,%esp
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a5c:	eb 11                	jmp    800a6f <strfind+0x1f>
		if (*s == c)
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	0f b6 00             	movzbl (%eax),%eax
  800a64:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a67:	75 02                	jne    800a6b <strfind+0x1b>
			break;
  800a69:	eb 0e                	jmp    800a79 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	0f b6 00             	movzbl (%eax),%eax
  800a75:	84 c0                	test   %al,%al
  800a77:	75 e5                	jne    800a5e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a86:	75 05                	jne    800a8d <memset+0xf>
		return v;
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	eb 5c                	jmp    800ae9 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	83 e0 03             	and    $0x3,%eax
  800a93:	85 c0                	test   %eax,%eax
  800a95:	75 41                	jne    800ad8 <memset+0x5a>
  800a97:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9a:	83 e0 03             	and    $0x3,%eax
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	75 37                	jne    800ad8 <memset+0x5a>
		c &= 0xFF;
  800aa1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	c1 e0 18             	shl    $0x18,%eax
  800aae:	89 c2                	mov    %eax,%edx
  800ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab3:	c1 e0 10             	shl    $0x10,%eax
  800ab6:	09 c2                	or     %eax,%edx
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	c1 e0 08             	shl    $0x8,%eax
  800abe:	09 d0                	or     %edx,%eax
  800ac0:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac6:	c1 e8 02             	shr    $0x2,%eax
  800ac9:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	fc                   	cld    
  800ad4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad6:	eb 0e                	jmp    800ae6 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ae1:	89 d7                	mov    %edx,%edi
  800ae3:	fc                   	cld    
  800ae4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b04:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b07:	73 6d                	jae    800b76 <memmove+0x8a>
  800b09:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b0f:	01 d0                	add    %edx,%eax
  800b11:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b14:	76 60                	jbe    800b76 <memmove+0x8a>
		s += n;
  800b16:	8b 45 10             	mov    0x10(%ebp),%eax
  800b19:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b25:	83 e0 03             	and    $0x3,%eax
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	75 2f                	jne    800b5b <memmove+0x6f>
  800b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b2f:	83 e0 03             	and    $0x3,%eax
  800b32:	85 c0                	test   %eax,%eax
  800b34:	75 25                	jne    800b5b <memmove+0x6f>
  800b36:	8b 45 10             	mov    0x10(%ebp),%eax
  800b39:	83 e0 03             	and    $0x3,%eax
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	75 1b                	jne    800b5b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b43:	83 e8 04             	sub    $0x4,%eax
  800b46:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b49:	83 ea 04             	sub    $0x4,%edx
  800b4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b4f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	fd                   	std    
  800b57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b59:	eb 18                	jmp    800b73 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b64:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b67:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6a:	89 d7                	mov    %edx,%edi
  800b6c:	89 de                	mov    %ebx,%esi
  800b6e:	89 c1                	mov    %eax,%ecx
  800b70:	fd                   	std    
  800b71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b73:	fc                   	cld    
  800b74:	eb 45                	jmp    800bbb <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b79:	83 e0 03             	and    $0x3,%eax
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	75 2b                	jne    800bab <memmove+0xbf>
  800b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b83:	83 e0 03             	and    $0x3,%eax
  800b86:	85 c0                	test   %eax,%eax
  800b88:	75 21                	jne    800bab <memmove+0xbf>
  800b8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8d:	83 e0 03             	and    $0x3,%eax
  800b90:	85 c0                	test   %eax,%eax
  800b92:	75 17                	jne    800bab <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b94:	8b 45 10             	mov    0x10(%ebp),%eax
  800b97:	c1 e8 02             	shr    $0x2,%eax
  800b9a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	fc                   	cld    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 10                	jmp    800bbb <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bb1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	89 d6                	mov    %edx,%esi
  800bb8:	fc                   	cld    
  800bb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	89 04 24             	mov    %eax,(%esp)
  800be0:	e8 07 ff ff ff       	call   800aec <memmove>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bf9:	eb 30                	jmp    800c2b <memcmp+0x44>
		if (*s1 != *s2)
  800bfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bfe:	0f b6 10             	movzbl (%eax),%edx
  800c01:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c04:	0f b6 00             	movzbl (%eax),%eax
  800c07:	38 c2                	cmp    %al,%dl
  800c09:	74 18                	je     800c23 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c0e:	0f b6 00             	movzbl (%eax),%eax
  800c11:	0f b6 d0             	movzbl %al,%edx
  800c14:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c17:	0f b6 00             	movzbl (%eax),%eax
  800c1a:	0f b6 c0             	movzbl %al,%eax
  800c1d:	29 c2                	sub    %eax,%edx
  800c1f:	89 d0                	mov    %edx,%eax
  800c21:	eb 1a                	jmp    800c3d <memcmp+0x56>
		s1++, s2++;
  800c23:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c27:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c31:	89 55 10             	mov    %edx,0x10(%ebp)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	75 c3                	jne    800bfb <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c45:	8b 45 10             	mov    0x10(%ebp),%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	01 d0                	add    %edx,%eax
  800c4d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c50:	eb 13                	jmp    800c65 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	0f b6 10             	movzbl (%eax),%edx
  800c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5b:	38 c2                	cmp    %al,%dl
  800c5d:	75 02                	jne    800c61 <memfind+0x22>
			break;
  800c5f:	eb 0c                	jmp    800c6d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c61:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c6b:	72 e5                	jb     800c52 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c70:	c9                   	leave  
  800c71:	c3                   	ret    

00800c72 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c78:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c7f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c86:	eb 04                	jmp    800c8c <strtol+0x1a>
		s++;
  800c88:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	0f b6 00             	movzbl (%eax),%eax
  800c92:	3c 20                	cmp    $0x20,%al
  800c94:	74 f2                	je     800c88 <strtol+0x16>
  800c96:	8b 45 08             	mov    0x8(%ebp),%eax
  800c99:	0f b6 00             	movzbl (%eax),%eax
  800c9c:	3c 09                	cmp    $0x9,%al
  800c9e:	74 e8                	je     800c88 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	0f b6 00             	movzbl (%eax),%eax
  800ca6:	3c 2b                	cmp    $0x2b,%al
  800ca8:	75 06                	jne    800cb0 <strtol+0x3e>
		s++;
  800caa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cae:	eb 15                	jmp    800cc5 <strtol+0x53>
	else if (*s == '-')
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb3:	0f b6 00             	movzbl (%eax),%eax
  800cb6:	3c 2d                	cmp    $0x2d,%al
  800cb8:	75 0b                	jne    800cc5 <strtol+0x53>
		s++, neg = 1;
  800cba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cbe:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc9:	74 06                	je     800cd1 <strtol+0x5f>
  800ccb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ccf:	75 24                	jne    800cf5 <strtol+0x83>
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	0f b6 00             	movzbl (%eax),%eax
  800cd7:	3c 30                	cmp    $0x30,%al
  800cd9:	75 1a                	jne    800cf5 <strtol+0x83>
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	83 c0 01             	add    $0x1,%eax
  800ce1:	0f b6 00             	movzbl (%eax),%eax
  800ce4:	3c 78                	cmp    $0x78,%al
  800ce6:	75 0d                	jne    800cf5 <strtol+0x83>
		s += 2, base = 16;
  800ce8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cec:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cf3:	eb 2a                	jmp    800d1f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf9:	75 17                	jne    800d12 <strtol+0xa0>
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	0f b6 00             	movzbl (%eax),%eax
  800d01:	3c 30                	cmp    $0x30,%al
  800d03:	75 0d                	jne    800d12 <strtol+0xa0>
		s++, base = 8;
  800d05:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d09:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d10:	eb 0d                	jmp    800d1f <strtol+0xad>
	else if (base == 0)
  800d12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d16:	75 07                	jne    800d1f <strtol+0xad>
		base = 10;
  800d18:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	0f b6 00             	movzbl (%eax),%eax
  800d25:	3c 2f                	cmp    $0x2f,%al
  800d27:	7e 1b                	jle    800d44 <strtol+0xd2>
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	0f b6 00             	movzbl (%eax),%eax
  800d2f:	3c 39                	cmp    $0x39,%al
  800d31:	7f 11                	jg     800d44 <strtol+0xd2>
			dig = *s - '0';
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	0f b6 00             	movzbl (%eax),%eax
  800d39:	0f be c0             	movsbl %al,%eax
  800d3c:	83 e8 30             	sub    $0x30,%eax
  800d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d42:	eb 48                	jmp    800d8c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	0f b6 00             	movzbl (%eax),%eax
  800d4a:	3c 60                	cmp    $0x60,%al
  800d4c:	7e 1b                	jle    800d69 <strtol+0xf7>
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	0f b6 00             	movzbl (%eax),%eax
  800d54:	3c 7a                	cmp    $0x7a,%al
  800d56:	7f 11                	jg     800d69 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	0f be c0             	movsbl %al,%eax
  800d61:	83 e8 57             	sub    $0x57,%eax
  800d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d67:	eb 23                	jmp    800d8c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	0f b6 00             	movzbl (%eax),%eax
  800d6f:	3c 40                	cmp    $0x40,%al
  800d71:	7e 3d                	jle    800db0 <strtol+0x13e>
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	0f b6 00             	movzbl (%eax),%eax
  800d79:	3c 5a                	cmp    $0x5a,%al
  800d7b:	7f 33                	jg     800db0 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	0f b6 00             	movzbl (%eax),%eax
  800d83:	0f be c0             	movsbl %al,%eax
  800d86:	83 e8 37             	sub    $0x37,%eax
  800d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d92:	7c 02                	jl     800d96 <strtol+0x124>
			break;
  800d94:	eb 1a                	jmp    800db0 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d96:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d9d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da6:	01 d0                	add    %edx,%eax
  800da8:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dab:	e9 6f ff ff ff       	jmp    800d1f <strtol+0xad>

	if (endptr)
  800db0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db4:	74 08                	je     800dbe <strtol+0x14c>
		*endptr = (char *) s;
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dbe:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dc2:	74 07                	je     800dcb <strtol+0x159>
  800dc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dc7:	f7 d8                	neg    %eax
  800dc9:	eb 03                	jmp    800dce <strtol+0x15c>
  800dcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	8b 55 10             	mov    0x10(%ebp),%edx
  800ddf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800de2:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800de5:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800de8:	8b 75 20             	mov    0x20(%ebp),%esi
  800deb:	cd 30                	int    $0x30
  800ded:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df4:	74 30                	je     800e26 <syscall+0x56>
  800df6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dfa:	7e 2a                	jle    800e26 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0a:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 61 17 80 00 	movl   $0x801761,(%esp)
  800e21:	e8 6f 03 00 00       	call   801195 <_panic>

	return ret;
  800e26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e29:	83 c4 3c             	add    $0x3c,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e41:	00 
  800e42:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e49:	00 
  800e4a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e51:	00 
  800e52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e55:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e59:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e6c:	e8 5f ff ff ff       	call   800dd0 <syscall>
}
  800e71:	c9                   	leave  
  800e72:	c3                   	ret    

00800e73 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e79:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e80:	00 
  800e81:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e88:	00 
  800e89:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e90:	00 
  800e91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800eb0:	e8 1b ff ff ff       	call   800dd0 <syscall>
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800edf:	00 
  800ee0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ef3:	e8 d8 fe ff ff       	call   800dd0 <syscall>
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f00:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f07:	00 
  800f08:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f0f:	00 
  800f10:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f17:	00 
  800f18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1f:	00 
  800f20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f27:	00 
  800f28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f2f:	00 
  800f30:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f37:	e8 94 fe ff ff       	call   800dd0 <syscall>
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    

00800f3e <sys_yield>:

void
sys_yield(void)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f44:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f53:	00 
  800f54:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f63:	00 
  800f64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f7b:	e8 50 fe ff ff       	call   800dd0 <syscall>
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f88:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f98:	00 
  800f99:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fa0:	00 
  800fa1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb4:	00 
  800fb5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fbc:	e8 0f fe ff ff       	call   800dd0 <syscall>
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	56                   	push   %esi
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800fce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fda:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fde:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fe2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ff5:	00 
  800ff6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800ffd:	e8 ce fd ff ff       	call   800dd0 <syscall>
}
  801002:	83 c4 20             	add    $0x20,%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80100f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801012:	8b 45 08             	mov    0x8(%ebp),%eax
  801015:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80101c:	00 
  80101d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801024:	00 
  801025:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80102c:	00 
  80102d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801031:	89 44 24 08          	mov    %eax,0x8(%esp)
  801035:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80103c:	00 
  80103d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801044:	e8 87 fd ff ff       	call   800dd0 <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801051:	8b 55 0c             	mov    0xc(%ebp),%edx
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80105e:	00 
  80105f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801066:	00 
  801067:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80106e:	00 
  80106f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801073:	89 44 24 08          	mov    %eax,0x8(%esp)
  801077:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80107e:	00 
  80107f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801086:	e8 45 fd ff ff       	call   800dd0 <syscall>
}
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801093:	8b 55 0c             	mov    0xc(%ebp),%edx
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010b0:	00 
  8010b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c0:	00 
  8010c1:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010c8:	e8 03 fd ff ff       	call   800dd0 <syscall>
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010d5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010d8:	8b 55 10             	mov    0x10(%ebp),%edx
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e5:	00 
  8010e6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010ea:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801108:	e8 c3 fc ff ff       	call   800dd0 <syscall>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80111f:	00 
  801120:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801127:	00 
  801128:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80112f:	00 
  801130:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801137:	00 
  801138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80114b:	e8 80 fc ff ff       	call   800dd0 <syscall>
}
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <sys_exec>:

void sys_exec(char* buf){
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801162:	00 
  801163:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80116a:	00 
  80116b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801172:	00 
  801173:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80117a:	00 
  80117b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80118e:	e8 3d fc ff ff       	call   800dd0 <syscall>
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	53                   	push   %ebx
  801199:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80119c:	8d 45 14             	lea    0x14(%ebp),%eax
  80119f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011a2:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011a8:	e8 4d fd ff ff       	call   800efa <sys_getenvid>
  8011ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c3:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  8011ca:	e8 f6 ef ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d9:	89 04 24             	mov    %eax,(%esp)
  8011dc:	e8 80 ef ff ff       	call   800161 <vcprintf>
	cprintf("\n");
  8011e1:	c7 04 24 93 17 80 00 	movl   $0x801793,(%esp)
  8011e8:	e8 d8 ef ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011ed:	cc                   	int3   
  8011ee:	eb fd                	jmp    8011ed <_panic+0x58>

008011f0 <__udivdi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801202:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801206:	85 c0                	test   %eax,%eax
  801208:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120c:	89 ea                	mov    %ebp,%edx
  80120e:	89 0c 24             	mov    %ecx,(%esp)
  801211:	75 2d                	jne    801240 <__udivdi3+0x50>
  801213:	39 e9                	cmp    %ebp,%ecx
  801215:	77 61                	ja     801278 <__udivdi3+0x88>
  801217:	85 c9                	test   %ecx,%ecx
  801219:	89 ce                	mov    %ecx,%esi
  80121b:	75 0b                	jne    801228 <__udivdi3+0x38>
  80121d:	b8 01 00 00 00       	mov    $0x1,%eax
  801222:	31 d2                	xor    %edx,%edx
  801224:	f7 f1                	div    %ecx
  801226:	89 c6                	mov    %eax,%esi
  801228:	31 d2                	xor    %edx,%edx
  80122a:	89 e8                	mov    %ebp,%eax
  80122c:	f7 f6                	div    %esi
  80122e:	89 c5                	mov    %eax,%ebp
  801230:	89 f8                	mov    %edi,%eax
  801232:	f7 f6                	div    %esi
  801234:	89 ea                	mov    %ebp,%edx
  801236:	83 c4 0c             	add    $0xc,%esp
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    
  80123d:	8d 76 00             	lea    0x0(%esi),%esi
  801240:	39 e8                	cmp    %ebp,%eax
  801242:	77 24                	ja     801268 <__udivdi3+0x78>
  801244:	0f bd e8             	bsr    %eax,%ebp
  801247:	83 f5 1f             	xor    $0x1f,%ebp
  80124a:	75 3c                	jne    801288 <__udivdi3+0x98>
  80124c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801250:	39 34 24             	cmp    %esi,(%esp)
  801253:	0f 86 9f 00 00 00    	jbe    8012f8 <__udivdi3+0x108>
  801259:	39 d0                	cmp    %edx,%eax
  80125b:	0f 82 97 00 00 00    	jb     8012f8 <__udivdi3+0x108>
  801261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801268:	31 d2                	xor    %edx,%edx
  80126a:	31 c0                	xor    %eax,%eax
  80126c:	83 c4 0c             	add    $0xc,%esp
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	89 f8                	mov    %edi,%eax
  80127a:	f7 f1                	div    %ecx
  80127c:	31 d2                	xor    %edx,%edx
  80127e:	83 c4 0c             	add    $0xc,%esp
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	89 e9                	mov    %ebp,%ecx
  80128a:	8b 3c 24             	mov    (%esp),%edi
  80128d:	d3 e0                	shl    %cl,%eax
  80128f:	89 c6                	mov    %eax,%esi
  801291:	b8 20 00 00 00       	mov    $0x20,%eax
  801296:	29 e8                	sub    %ebp,%eax
  801298:	89 c1                	mov    %eax,%ecx
  80129a:	d3 ef                	shr    %cl,%edi
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012a2:	8b 3c 24             	mov    (%esp),%edi
  8012a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012a9:	89 d6                	mov    %edx,%esi
  8012ab:	d3 e7                	shl    %cl,%edi
  8012ad:	89 c1                	mov    %eax,%ecx
  8012af:	89 3c 24             	mov    %edi,(%esp)
  8012b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012b6:	d3 ee                	shr    %cl,%esi
  8012b8:	89 e9                	mov    %ebp,%ecx
  8012ba:	d3 e2                	shl    %cl,%edx
  8012bc:	89 c1                	mov    %eax,%ecx
  8012be:	d3 ef                	shr    %cl,%edi
  8012c0:	09 d7                	or     %edx,%edi
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	89 f8                	mov    %edi,%eax
  8012c6:	f7 74 24 08          	divl   0x8(%esp)
  8012ca:	89 d6                	mov    %edx,%esi
  8012cc:	89 c7                	mov    %eax,%edi
  8012ce:	f7 24 24             	mull   (%esp)
  8012d1:	39 d6                	cmp    %edx,%esi
  8012d3:	89 14 24             	mov    %edx,(%esp)
  8012d6:	72 30                	jb     801308 <__udivdi3+0x118>
  8012d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	39 c2                	cmp    %eax,%edx
  8012e2:	73 05                	jae    8012e9 <__udivdi3+0xf9>
  8012e4:	3b 34 24             	cmp    (%esp),%esi
  8012e7:	74 1f                	je     801308 <__udivdi3+0x118>
  8012e9:	89 f8                	mov    %edi,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	e9 7a ff ff ff       	jmp    80126c <__udivdi3+0x7c>
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ff:	e9 68 ff ff ff       	jmp    80126c <__udivdi3+0x7c>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	8d 47 ff             	lea    -0x1(%edi),%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	83 c4 0c             	add    $0xc,%esp
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
  801314:	66 90                	xchg   %ax,%ax
  801316:	66 90                	xchg   %ax,%ax
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	83 ec 14             	sub    $0x14,%esp
  801326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80132a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80132e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801332:	89 c7                	mov    %eax,%edi
  801334:	89 44 24 04          	mov    %eax,0x4(%esp)
  801338:	8b 44 24 30          	mov    0x30(%esp),%eax
  80133c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801340:	89 34 24             	mov    %esi,(%esp)
  801343:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801347:	85 c0                	test   %eax,%eax
  801349:	89 c2                	mov    %eax,%edx
  80134b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80134f:	75 17                	jne    801368 <__umoddi3+0x48>
  801351:	39 fe                	cmp    %edi,%esi
  801353:	76 4b                	jbe    8013a0 <__umoddi3+0x80>
  801355:	89 c8                	mov    %ecx,%eax
  801357:	89 fa                	mov    %edi,%edx
  801359:	f7 f6                	div    %esi
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	31 d2                	xor    %edx,%edx
  80135f:	83 c4 14             	add    $0x14,%esp
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    
  801366:	66 90                	xchg   %ax,%ax
  801368:	39 f8                	cmp    %edi,%eax
  80136a:	77 54                	ja     8013c0 <__umoddi3+0xa0>
  80136c:	0f bd e8             	bsr    %eax,%ebp
  80136f:	83 f5 1f             	xor    $0x1f,%ebp
  801372:	75 5c                	jne    8013d0 <__umoddi3+0xb0>
  801374:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801378:	39 3c 24             	cmp    %edi,(%esp)
  80137b:	0f 87 e7 00 00 00    	ja     801468 <__umoddi3+0x148>
  801381:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801385:	29 f1                	sub    %esi,%ecx
  801387:	19 c7                	sbb    %eax,%edi
  801389:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801391:	8b 44 24 08          	mov    0x8(%esp),%eax
  801395:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801399:	83 c4 14             	add    $0x14,%esp
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    
  8013a0:	85 f6                	test   %esi,%esi
  8013a2:	89 f5                	mov    %esi,%ebp
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f6                	div    %esi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013b5:	31 d2                	xor    %edx,%edx
  8013b7:	f7 f5                	div    %ebp
  8013b9:	89 c8                	mov    %ecx,%eax
  8013bb:	f7 f5                	div    %ebp
  8013bd:	eb 9c                	jmp    80135b <__umoddi3+0x3b>
  8013bf:	90                   	nop
  8013c0:	89 c8                	mov    %ecx,%eax
  8013c2:	89 fa                	mov    %edi,%edx
  8013c4:	83 c4 14             	add    $0x14,%esp
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    
  8013cb:	90                   	nop
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	8b 04 24             	mov    (%esp),%eax
  8013d3:	be 20 00 00 00       	mov    $0x20,%esi
  8013d8:	89 e9                	mov    %ebp,%ecx
  8013da:	29 ee                	sub    %ebp,%esi
  8013dc:	d3 e2                	shl    %cl,%edx
  8013de:	89 f1                	mov    %esi,%ecx
  8013e0:	d3 e8                	shr    %cl,%eax
  8013e2:	89 e9                	mov    %ebp,%ecx
  8013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e8:	8b 04 24             	mov    (%esp),%eax
  8013eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013ef:	89 fa                	mov    %edi,%edx
  8013f1:	d3 e0                	shl    %cl,%eax
  8013f3:	89 f1                	mov    %esi,%ecx
  8013f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013fd:	d3 ea                	shr    %cl,%edx
  8013ff:	89 e9                	mov    %ebp,%ecx
  801401:	d3 e7                	shl    %cl,%edi
  801403:	89 f1                	mov    %esi,%ecx
  801405:	d3 e8                	shr    %cl,%eax
  801407:	89 e9                	mov    %ebp,%ecx
  801409:	09 f8                	or     %edi,%eax
  80140b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80140f:	f7 74 24 04          	divl   0x4(%esp)
  801413:	d3 e7                	shl    %cl,%edi
  801415:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801419:	89 d7                	mov    %edx,%edi
  80141b:	f7 64 24 08          	mull   0x8(%esp)
  80141f:	39 d7                	cmp    %edx,%edi
  801421:	89 c1                	mov    %eax,%ecx
  801423:	89 14 24             	mov    %edx,(%esp)
  801426:	72 2c                	jb     801454 <__umoddi3+0x134>
  801428:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80142c:	72 22                	jb     801450 <__umoddi3+0x130>
  80142e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801432:	29 c8                	sub    %ecx,%eax
  801434:	19 d7                	sbb    %edx,%edi
  801436:	89 e9                	mov    %ebp,%ecx
  801438:	89 fa                	mov    %edi,%edx
  80143a:	d3 e8                	shr    %cl,%eax
  80143c:	89 f1                	mov    %esi,%ecx
  80143e:	d3 e2                	shl    %cl,%edx
  801440:	89 e9                	mov    %ebp,%ecx
  801442:	d3 ef                	shr    %cl,%edi
  801444:	09 d0                	or     %edx,%eax
  801446:	89 fa                	mov    %edi,%edx
  801448:	83 c4 14             	add    $0x14,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	39 d7                	cmp    %edx,%edi
  801452:	75 da                	jne    80142e <__umoddi3+0x10e>
  801454:	8b 14 24             	mov    (%esp),%edx
  801457:	89 c1                	mov    %eax,%ecx
  801459:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80145d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801461:	eb cb                	jmp    80142e <__umoddi3+0x10e>
  801463:	90                   	nop
  801464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801468:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80146c:	0f 82 0f ff ff ff    	jb     801381 <__umoddi3+0x61>
  801472:	e9 1a ff ff ff       	jmp    801391 <__umoddi3+0x71>
