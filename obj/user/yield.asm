
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
  800045:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  80004c:	e8 64 01 00 00       	call   8001b5 <cprintf>
	for (i = 0; i < 5; i++) {
  800051:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800058:	eb 28                	jmp    800082 <umain+0x4f>
		sys_yield();
  80005a:	e8 cf 0e 00 00       	call   800f2e <sys_yield>
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
  800072:	c7 04 24 20 15 80 00 	movl   $0x801520,(%esp)
  800079:	e8 37 01 00 00       	call   8001b5 <cprintf>
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
  800094:	c7 04 24 4c 15 80 00 	movl   $0x80154c,(%esp)
  80009b:	e8 15 01 00 00       	call   8001b5 <cprintf>
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
  8000a8:	e8 3d 0e 00 00       	call   800eea <sys_getenvid>
  8000ad:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b2:	c1 e0 02             	shl    $0x2,%eax
  8000b5:	89 c2                	mov    %eax,%edx
  8000b7:	c1 e2 05             	shl    $0x5,%edx
  8000ba:	29 c2                	sub    %eax,%edx
  8000bc:	89 d0                	mov    %edx,%eax
  8000be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c3:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  8000c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d2:	89 04 24             	mov    %eax,(%esp)
  8000d5:	e8 59 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000da:	e8 02 00 00 00       	call   8000e1 <exit>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ee:	e8 b4 0d 00 00       	call   800ea7 <sys_env_destroy>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fe:	8b 00                	mov    (%eax),%eax
  800100:	8d 48 01             	lea    0x1(%eax),%ecx
  800103:	8b 55 0c             	mov    0xc(%ebp),%edx
  800106:	89 0a                	mov    %ecx,(%edx)
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 d1                	mov    %edx,%ecx
  80010d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800110:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800114:	8b 45 0c             	mov    0xc(%ebp),%eax
  800117:	8b 00                	mov    (%eax),%eax
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 20                	jne    800140 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	8b 00                	mov    (%eax),%eax
  800125:	8b 55 0c             	mov    0xc(%ebp),%edx
  800128:	83 c2 08             	add    $0x8,%edx
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	89 14 24             	mov    %edx,(%esp)
  800132:	e8 ea 0c 00 00       	call   800e21 <sys_cputs>
		b->idx = 0;
  800137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800140:	8b 45 0c             	mov    0xc(%ebp),%eax
  800143:	8b 40 04             	mov    0x4(%eax),%eax
  800146:	8d 50 01             	lea    0x1(%eax),%edx
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800171:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	89 44 24 04          	mov    %eax,0x4(%esp)
  800186:	c7 04 24 f5 00 80 00 	movl   $0x8000f5,(%esp)
  80018d:	e8 bd 01 00 00       	call   80034f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800192:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a2:	83 c0 08             	add    $0x8,%eax
  8001a5:	89 04 24             	mov    %eax,(%esp)
  8001a8:	e8 74 0c 00 00       	call   800e21 <sys_cputs>

	return b.cnt;
  8001ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001be:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 7e ff ff ff       	call   800151 <vcprintf>
  8001d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	53                   	push   %ebx
  8001df:	83 ec 34             	sub    $0x34,%esp
  8001e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ee:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001f9:	77 72                	ja     80026d <printnum+0x92>
  8001fb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001fe:	72 05                	jb     800205 <printnum+0x2a>
  800200:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800203:	77 68                	ja     80026d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800205:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800208:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020b:	8b 45 18             	mov    0x18(%ebp),%eax
  80020e:	ba 00 00 00 00       	mov    $0x0,%edx
  800213:	89 44 24 08          	mov    %eax,0x8(%esp)
  800217:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80021b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80021e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	89 54 24 04          	mov    %edx,0x4(%esp)
  800228:	e8 43 10 00 00       	call   801270 <__udivdi3>
  80022d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800230:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800234:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800238:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80023b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	e8 82 ff ff ff       	call   8001db <printnum>
  800259:	eb 1c                	jmp    800277 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800262:	8b 45 20             	mov    0x20(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800271:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800275:	7f e4                	jg     80025b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800277:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800282:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800285:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800289:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	89 54 24 04          	mov    %edx,0x4(%esp)
  800294:	e8 07 11 00 00       	call   8013a0 <__umoddi3>
  800299:	05 48 16 80 00       	add    $0x801648,%eax
  80029e:	0f b6 00             	movzbl (%eax),%eax
  8002a1:	0f be c0             	movsbl %al,%eax
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	ff d0                	call   *%eax
}
  8002b3:	83 c4 34             	add    $0x34,%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002c0:	7e 14                	jle    8002d6 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	8b 00                	mov    (%eax),%eax
  8002c7:	8d 48 08             	lea    0x8(%eax),%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	89 0a                	mov    %ecx,(%edx)
  8002cf:	8b 50 04             	mov    0x4(%eax),%edx
  8002d2:	8b 00                	mov    (%eax),%eax
  8002d4:	eb 30                	jmp    800306 <getuint+0x4d>
	else if (lflag)
  8002d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002da:	74 16                	je     8002f2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	8b 00                	mov    (%eax),%eax
  8002e1:	8d 48 04             	lea    0x4(%eax),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 0a                	mov    %ecx,(%edx)
  8002e9:	8b 00                	mov    (%eax),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f0:	eb 14                	jmp    800306 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	8b 00                	mov    (%eax),%eax
  8002f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	89 0a                	mov    %ecx,(%edx)
  8002ff:	8b 00                	mov    (%eax),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80030f:	7e 14                	jle    800325 <getint+0x1d>
		return va_arg(*ap, long long);
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	8b 00                	mov    (%eax),%eax
  800316:	8d 48 08             	lea    0x8(%eax),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 0a                	mov    %ecx,(%edx)
  80031e:	8b 50 04             	mov    0x4(%eax),%edx
  800321:	8b 00                	mov    (%eax),%eax
  800323:	eb 28                	jmp    80034d <getint+0x45>
	else if (lflag)
  800325:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800329:	74 12                	je     80033d <getint+0x35>
		return va_arg(*ap, long);
  80032b:	8b 45 08             	mov    0x8(%ebp),%eax
  80032e:	8b 00                	mov    (%eax),%eax
  800330:	8d 48 04             	lea    0x4(%eax),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 0a                	mov    %ecx,(%edx)
  800338:	8b 00                	mov    (%eax),%eax
  80033a:	99                   	cltd   
  80033b:	eb 10                	jmp    80034d <getint+0x45>
	else
		return va_arg(*ap, int);
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	8b 00                	mov    (%eax),%eax
  800342:	8d 48 04             	lea    0x4(%eax),%ecx
  800345:	8b 55 08             	mov    0x8(%ebp),%edx
  800348:	89 0a                	mov    %ecx,(%edx)
  80034a:	8b 00                	mov    (%eax),%eax
  80034c:	99                   	cltd   
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800357:	eb 18                	jmp    800371 <vprintfmt+0x22>
			if (ch == '\0')
  800359:	85 db                	test   %ebx,%ebx
  80035b:	75 05                	jne    800362 <vprintfmt+0x13>
				return;
  80035d:	e9 cc 03 00 00       	jmp    80072e <vprintfmt+0x3df>
			putch(ch, putdat);
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
  800365:	89 44 24 04          	mov    %eax,0x4(%esp)
  800369:	89 1c 24             	mov    %ebx,(%esp)
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	8b 45 10             	mov    0x10(%ebp),%eax
  800374:	8d 50 01             	lea    0x1(%eax),%edx
  800377:	89 55 10             	mov    %edx,0x10(%ebp)
  80037a:	0f b6 00             	movzbl (%eax),%eax
  80037d:	0f b6 d8             	movzbl %al,%ebx
  800380:	83 fb 25             	cmp    $0x25,%ebx
  800383:	75 d4                	jne    800359 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800385:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800389:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800397:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80039e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a8:	8d 50 01             	lea    0x1(%eax),%edx
  8003ab:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ae:	0f b6 00             	movzbl (%eax),%eax
  8003b1:	0f b6 d8             	movzbl %al,%ebx
  8003b4:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003b7:	83 f8 55             	cmp    $0x55,%eax
  8003ba:	0f 87 3d 03 00 00    	ja     8006fd <vprintfmt+0x3ae>
  8003c0:	8b 04 85 6c 16 80 00 	mov    0x80166c(,%eax,4),%eax
  8003c7:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c9:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cf:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003d3:	eb d0                	jmp    8003a5 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003df:	89 d0                	mov    %edx,%eax
  8003e1:	c1 e0 02             	shl    $0x2,%eax
  8003e4:	01 d0                	add    %edx,%eax
  8003e6:	01 c0                	add    %eax,%eax
  8003e8:	01 d8                	add    %ebx,%eax
  8003ea:	83 e8 30             	sub    $0x30,%eax
  8003ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f3:	0f b6 00             	movzbl (%eax),%eax
  8003f6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003f9:	83 fb 2f             	cmp    $0x2f,%ebx
  8003fc:	7e 0b                	jle    800409 <vprintfmt+0xba>
  8003fe:	83 fb 39             	cmp    $0x39,%ebx
  800401:	7f 06                	jg     800409 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800403:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800407:	eb d3                	jmp    8003dc <vprintfmt+0x8d>
			goto process_precision;
  800409:	eb 33                	jmp    80043e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 50 04             	lea    0x4(%eax),%edx
  800411:	89 55 14             	mov    %edx,0x14(%ebp)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800419:	eb 23                	jmp    80043e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80041b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80041f:	79 0c                	jns    80042d <vprintfmt+0xde>
				width = 0;
  800421:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800428:	e9 78 ff ff ff       	jmp    8003a5 <vprintfmt+0x56>
  80042d:	e9 73 ff ff ff       	jmp    8003a5 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800432:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800439:	e9 67 ff ff ff       	jmp    8003a5 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80043e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800442:	79 12                	jns    800456 <vprintfmt+0x107>
				width = precision, precision = -1;
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800451:	e9 4f ff ff ff       	jmp    8003a5 <vprintfmt+0x56>
  800456:	e9 4a ff ff ff       	jmp    8003a5 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80045f:	e9 41 ff ff ff       	jmp    8003a5 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800472:	89 54 24 04          	mov    %edx,0x4(%esp)
  800476:	89 04 24             	mov    %eax,(%esp)
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	ff d0                	call   *%eax
			break;
  80047e:	e9 a5 02 00 00       	jmp    800728 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80048e:	85 db                	test   %ebx,%ebx
  800490:	79 02                	jns    800494 <vprintfmt+0x145>
				err = -err;
  800492:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800494:	83 fb 09             	cmp    $0x9,%ebx
  800497:	7f 0b                	jg     8004a4 <vprintfmt+0x155>
  800499:	8b 34 9d 20 16 80 00 	mov    0x801620(,%ebx,4),%esi
  8004a0:	85 f6                	test   %esi,%esi
  8004a2:	75 23                	jne    8004c7 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004a8:	c7 44 24 08 59 16 80 	movl   $0x801659,0x8(%esp)
  8004af:	00 
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ba:	89 04 24             	mov    %eax,(%esp)
  8004bd:	e8 73 02 00 00       	call   800735 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004c2:	e9 61 02 00 00       	jmp    800728 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004cb:	c7 44 24 08 62 16 80 	movl   $0x801662,0x8(%esp)
  8004d2:	00 
  8004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004da:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dd:	89 04 24             	mov    %eax,(%esp)
  8004e0:	e8 50 02 00 00       	call   800735 <printfmt>
			break;
  8004e5:	e9 3e 02 00 00       	jmp    800728 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8d 50 04             	lea    0x4(%eax),%edx
  8004f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f3:	8b 30                	mov    (%eax),%esi
  8004f5:	85 f6                	test   %esi,%esi
  8004f7:	75 05                	jne    8004fe <vprintfmt+0x1af>
				p = "(null)";
  8004f9:	be 65 16 80 00       	mov    $0x801665,%esi
			if (width > 0 && padc != '-')
  8004fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800502:	7e 37                	jle    80053b <vprintfmt+0x1ec>
  800504:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800508:	74 31                	je     80053b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	89 34 24             	mov    %esi,(%esp)
  800514:	e8 39 03 00 00       	call   800852 <strnlen>
  800519:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80051c:	eb 17                	jmp    800535 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80051e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800522:	8b 55 0c             	mov    0xc(%ebp),%edx
  800525:	89 54 24 04          	mov    %edx,0x4(%esp)
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800535:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800539:	7f e3                	jg     80051e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053b:	eb 38                	jmp    800575 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800541:	74 1f                	je     800562 <vprintfmt+0x213>
  800543:	83 fb 1f             	cmp    $0x1f,%ebx
  800546:	7e 05                	jle    80054d <vprintfmt+0x1fe>
  800548:	83 fb 7e             	cmp    $0x7e,%ebx
  80054b:	7e 15                	jle    800562 <vprintfmt+0x213>
					putch('?', putdat);
  80054d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800550:	89 44 24 04          	mov    %eax,0x4(%esp)
  800554:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055b:	8b 45 08             	mov    0x8(%ebp),%eax
  80055e:	ff d0                	call   *%eax
  800560:	eb 0f                	jmp    800571 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800562:	8b 45 0c             	mov    0xc(%ebp),%eax
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	89 1c 24             	mov    %ebx,(%esp)
  80056c:	8b 45 08             	mov    0x8(%ebp),%eax
  80056f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800571:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800575:	89 f0                	mov    %esi,%eax
  800577:	8d 70 01             	lea    0x1(%eax),%esi
  80057a:	0f b6 00             	movzbl (%eax),%eax
  80057d:	0f be d8             	movsbl %al,%ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	74 10                	je     800594 <vprintfmt+0x245>
  800584:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800588:	78 b3                	js     80053d <vprintfmt+0x1ee>
  80058a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80058e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800592:	79 a9                	jns    80053d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800594:	eb 17                	jmp    8005ad <vprintfmt+0x25e>
				putch(' ', putdat);
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a7:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b1:	7f e3                	jg     800596 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005b3:	e9 70 01 00 00       	jmp    800728 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	e8 3e fd ff ff       	call   800308 <getint>
  8005ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	79 26                	jns    800600 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	ff d0                	call   *%eax
				num = -(long long) num;
  8005ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f3:	f7 d8                	neg    %eax
  8005f5:	83 d2 00             	adc    $0x0,%edx
  8005f8:	f7 da                	neg    %edx
  8005fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800600:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800607:	e9 a8 00 00 00       	jmp    8006b4 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80060f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	e8 9b fc ff ff       	call   8002b9 <getuint>
  80061e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800621:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800624:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80062b:	e9 84 00 00 00       	jmp    8006b4 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800630:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800633:	89 44 24 04          	mov    %eax,0x4(%esp)
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	e8 77 fc ff ff       	call   8002b9 <getuint>
  800642:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800645:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800648:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80064f:	eb 63                	jmp    8006b4 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800651:	8b 45 0c             	mov    0xc(%ebp),%eax
  800654:	89 44 24 04          	mov    %eax,0x4(%esp)
  800658:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	ff d0                	call   *%eax
			putch('x', putdat);
  800664:	8b 45 0c             	mov    0xc(%ebp),%eax
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)
  800680:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800682:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800693:	eb 1f                	jmp    8006b4 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
  80069f:	89 04 24             	mov    %eax,(%esp)
  8006a2:	e8 12 fc ff ff       	call   8002b9 <getuint>
  8006a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006ad:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bb:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c2:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	89 04 24             	mov    %eax,(%esp)
  8006e5:	e8 f1 fa ff ff       	call   8001db <printnum>
			break;
  8006ea:	eb 3c                	jmp    800728 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f3:	89 1c 24             	mov    %ebx,(%esp)
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	ff d0                	call   *%eax
			break;
  8006fb:	eb 2b                	jmp    800728 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800710:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800714:	eb 04                	jmp    80071a <vprintfmt+0x3cb>
  800716:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	0f b6 00             	movzbl (%eax),%eax
  800723:	3c 25                	cmp    $0x25,%al
  800725:	75 ef                	jne    800716 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800727:	90                   	nop
		}
	}
  800728:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800729:	e9 43 fc ff ff       	jmp    800371 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80072e:	83 c4 40             	add    $0x40,%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800744:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800748:	8b 45 10             	mov    0x10(%ebp),%eax
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800752:	89 44 24 04          	mov    %eax,0x4(%esp)
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	89 04 24             	mov    %eax,(%esp)
  80075c:	e8 ee fb ff ff       	call   80034f <vprintfmt>
	va_end(ap);
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800766:	8b 45 0c             	mov    0xc(%ebp),%eax
  800769:	8b 40 08             	mov    0x8(%eax),%eax
  80076c:	8d 50 01             	lea    0x1(%eax),%edx
  80076f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800772:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800775:	8b 45 0c             	mov    0xc(%ebp),%eax
  800778:	8b 10                	mov    (%eax),%edx
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077d:	8b 40 04             	mov    0x4(%eax),%eax
  800780:	39 c2                	cmp    %eax,%edx
  800782:	73 12                	jae    800796 <sprintputch+0x33>
		*b->buf++ = ch;
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
  800787:	8b 00                	mov    (%eax),%eax
  800789:	8d 48 01             	lea    0x1(%eax),%ecx
  80078c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078f:	89 0a                	mov    %ecx,(%edx)
  800791:	8b 55 08             	mov    0x8(%ebp),%edx
  800794:	88 10                	mov    %dl,(%eax)
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	01 d0                	add    %edx,%eax
  8007af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007bd:	74 06                	je     8007c5 <vsnprintf+0x2d>
  8007bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007c3:	7f 07                	jg     8007cc <vsnprintf+0x34>
		return -E_INVAL;
  8007c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ca:	eb 2a                	jmp    8007f6 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e1:	c7 04 24 63 07 80 00 	movl   $0x800763,(%esp)
  8007e8:	e8 62 fb ff ff       	call   80034f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800801:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800804:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800807:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080b:	8b 45 10             	mov    0x10(%ebp),%eax
  80080e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	89 44 24 04          	mov    %eax,0x4(%esp)
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	e8 74 ff ff ff       	call   800798 <vsnprintf>
  800824:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800827:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800832:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800839:	eb 08                	jmp    800843 <strlen+0x17>
		n++;
  80083b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	0f b6 00             	movzbl (%eax),%eax
  800849:	84 c0                	test   %al,%al
  80084b:	75 ee                	jne    80083b <strlen+0xf>
		n++;
	return n;
  80084d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800850:	c9                   	leave  
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800858:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80085f:	eb 0c                	jmp    80086d <strnlen+0x1b>
		n++;
  800861:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800865:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800869:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80086d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800871:	74 0a                	je     80087d <strnlen+0x2b>
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	84 c0                	test   %al,%al
  80087b:	75 e4                	jne    800861 <strnlen+0xf>
		n++;
	return n;
  80087d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80088e:	90                   	nop
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8d 50 01             	lea    0x1(%eax),%edx
  800895:	89 55 08             	mov    %edx,0x8(%ebp)
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80089e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	88 10                	mov    %dl,(%eax)
  8008a6:	0f b6 00             	movzbl (%eax),%eax
  8008a9:	84 c0                	test   %al,%al
  8008ab:	75 e2                	jne    80088f <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	89 04 24             	mov    %eax,(%esp)
  8008be:	e8 69 ff ff ff       	call   80082c <strlen>
  8008c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	01 c2                	add    %eax,%edx
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d5:	89 14 24             	mov    %edx,(%esp)
  8008d8:	e8 a5 ff ff ff       	call   800882 <strcpy>
	return dst;
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008f5:	eb 23                	jmp    80091a <strncpy+0x38>
		*dst++ = *src;
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8d 50 01             	lea    0x1(%eax),%edx
  8008fd:	89 55 08             	mov    %edx,0x8(%ebp)
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
  800903:	0f b6 12             	movzbl (%edx),%edx
  800906:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	0f b6 00             	movzbl (%eax),%eax
  80090e:	84 c0                	test   %al,%al
  800910:	74 04                	je     800916 <strncpy+0x34>
			src++;
  800912:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800916:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80091a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80091d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800920:	72 d5                	jb     8008f7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800922:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800933:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800937:	74 33                	je     80096c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800939:	eb 17                	jmp    800952 <strlcpy+0x2b>
			*dst++ = *src++;
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8d 50 01             	lea    0x1(%eax),%edx
  800941:	89 55 08             	mov    %edx,0x8(%ebp)
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
  800947:	8d 4a 01             	lea    0x1(%edx),%ecx
  80094a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800952:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800956:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80095a:	74 0a                	je     800966 <strlcpy+0x3f>
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	0f b6 00             	movzbl (%eax),%eax
  800962:	84 c0                	test   %al,%al
  800964:	75 d5                	jne    80093b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096c:	8b 55 08             	mov    0x8(%ebp),%edx
  80096f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800972:	29 c2                	sub    %eax,%edx
  800974:	89 d0                	mov    %edx,%eax
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80097b:	eb 08                	jmp    800985 <strcmp+0xd>
		p++, q++;
  80097d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800981:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 00             	movzbl (%eax),%eax
  80098b:	84 c0                	test   %al,%al
  80098d:	74 10                	je     80099f <strcmp+0x27>
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	0f b6 10             	movzbl (%eax),%edx
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	38 c2                	cmp    %al,%dl
  80099d:	74 de                	je     80097d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	0f b6 d0             	movzbl %al,%edx
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ab:	0f b6 00             	movzbl (%eax),%eax
  8009ae:	0f b6 c0             	movzbl %al,%eax
  8009b1:	29 c2                	sub    %eax,%edx
  8009b3:	89 d0                	mov    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009ba:	eb 0c                	jmp    8009c8 <strncmp+0x11>
		n--, p++, q++;
  8009bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009cc:	74 1a                	je     8009e8 <strncmp+0x31>
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 00             	movzbl (%eax),%eax
  8009d4:	84 c0                	test   %al,%al
  8009d6:	74 10                	je     8009e8 <strncmp+0x31>
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	0f b6 00             	movzbl (%eax),%eax
  8009e4:	38 c2                	cmp    %al,%dl
  8009e6:	74 d4                	je     8009bc <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ec:	75 07                	jne    8009f5 <strncmp+0x3e>
		return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	eb 16                	jmp    800a0b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f8:	0f b6 00             	movzbl (%eax),%eax
  8009fb:	0f b6 d0             	movzbl %al,%edx
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	0f b6 00             	movzbl (%eax),%eax
  800a04:	0f b6 c0             	movzbl %al,%eax
  800a07:	29 c2                	sub    %eax,%edx
  800a09:	89 d0                	mov    %edx,%eax
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 04             	sub    $0x4,%esp
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a19:	eb 14                	jmp    800a2f <strchr+0x22>
		if (*s == c)
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	0f b6 00             	movzbl (%eax),%eax
  800a21:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a24:	75 05                	jne    800a2b <strchr+0x1e>
			return (char *) s;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	eb 13                	jmp    800a3e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	0f b6 00             	movzbl (%eax),%eax
  800a35:	84 c0                	test   %al,%al
  800a37:	75 e2                	jne    800a1b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	83 ec 04             	sub    $0x4,%esp
  800a46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a49:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a4c:	eb 11                	jmp    800a5f <strfind+0x1f>
		if (*s == c)
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 00             	movzbl (%eax),%eax
  800a54:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a57:	75 02                	jne    800a5b <strfind+0x1b>
			break;
  800a59:	eb 0e                	jmp    800a69 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	0f b6 00             	movzbl (%eax),%eax
  800a65:	84 c0                	test   %al,%al
  800a67:	75 e5                	jne    800a4e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a6c:	c9                   	leave  
  800a6d:	c3                   	ret    

00800a6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a76:	75 05                	jne    800a7d <memset+0xf>
		return v;
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	eb 5c                	jmp    800ad9 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	83 e0 03             	and    $0x3,%eax
  800a83:	85 c0                	test   %eax,%eax
  800a85:	75 41                	jne    800ac8 <memset+0x5a>
  800a87:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8a:	83 e0 03             	and    $0x3,%eax
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	75 37                	jne    800ac8 <memset+0x5a>
		c &= 0xFF;
  800a91:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	c1 e0 18             	shl    $0x18,%eax
  800a9e:	89 c2                	mov    %eax,%edx
  800aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa3:	c1 e0 10             	shl    $0x10,%eax
  800aa6:	09 c2                	or     %eax,%edx
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	c1 e0 08             	shl    $0x8,%eax
  800aae:	09 d0                	or     %edx,%eax
  800ab0:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab6:	c1 e8 02             	shr    $0x2,%eax
  800ab9:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800abb:	8b 55 08             	mov    0x8(%ebp),%edx
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 d7                	mov    %edx,%edi
  800ac3:	fc                   	cld    
  800ac4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac6:	eb 0e                	jmp    800ad6 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	fc                   	cld    
  800ad4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800af1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800af7:	73 6d                	jae    800b66 <memmove+0x8a>
  800af9:	8b 45 10             	mov    0x10(%ebp),%eax
  800afc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800aff:	01 d0                	add    %edx,%eax
  800b01:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b04:	76 60                	jbe    800b66 <memmove+0x8a>
		s += n;
  800b06:	8b 45 10             	mov    0x10(%ebp),%eax
  800b09:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b15:	83 e0 03             	and    $0x3,%eax
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	75 2f                	jne    800b4b <memmove+0x6f>
  800b1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b1f:	83 e0 03             	and    $0x3,%eax
  800b22:	85 c0                	test   %eax,%eax
  800b24:	75 25                	jne    800b4b <memmove+0x6f>
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	83 e0 03             	and    $0x3,%eax
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	75 1b                	jne    800b4b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b33:	83 e8 04             	sub    $0x4,%eax
  800b36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b39:	83 ea 04             	sub    $0x4,%edx
  800b3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	fd                   	std    
  800b47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b49:	eb 18                	jmp    800b63 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b54:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 de                	mov    %ebx,%esi
  800b5e:	89 c1                	mov    %eax,%ecx
  800b60:	fd                   	std    
  800b61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b63:	fc                   	cld    
  800b64:	eb 45                	jmp    800bab <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b69:	83 e0 03             	and    $0x3,%eax
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	75 2b                	jne    800b9b <memmove+0xbf>
  800b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b73:	83 e0 03             	and    $0x3,%eax
  800b76:	85 c0                	test   %eax,%eax
  800b78:	75 21                	jne    800b9b <memmove+0xbf>
  800b7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7d:	83 e0 03             	and    $0x3,%eax
  800b80:	85 c0                	test   %eax,%eax
  800b82:	75 17                	jne    800b9b <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b84:	8b 45 10             	mov    0x10(%ebp),%eax
  800b87:	c1 e8 02             	shr    $0x2,%eax
  800b8a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	fc                   	cld    
  800b97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b99:	eb 10                	jmp    800bab <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b9e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba4:	89 c7                	mov    %eax,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	fc                   	cld    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	89 04 24             	mov    %eax,(%esp)
  800bd0:	e8 07 ff ff ff       	call   800adc <memmove>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800be9:	eb 30                	jmp    800c1b <memcmp+0x44>
		if (*s1 != *s2)
  800beb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bee:	0f b6 10             	movzbl (%eax),%edx
  800bf1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf4:	0f b6 00             	movzbl (%eax),%eax
  800bf7:	38 c2                	cmp    %al,%dl
  800bf9:	74 18                	je     800c13 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bfe:	0f b6 00             	movzbl (%eax),%eax
  800c01:	0f b6 d0             	movzbl %al,%edx
  800c04:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c07:	0f b6 00             	movzbl (%eax),%eax
  800c0a:	0f b6 c0             	movzbl %al,%eax
  800c0d:	29 c2                	sub    %eax,%edx
  800c0f:	89 d0                	mov    %edx,%eax
  800c11:	eb 1a                	jmp    800c2d <memcmp+0x56>
		s1++, s2++;
  800c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c17:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c21:	89 55 10             	mov    %edx,0x10(%ebp)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	75 c3                	jne    800beb <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c35:	8b 45 10             	mov    0x10(%ebp),%eax
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	01 d0                	add    %edx,%eax
  800c3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c40:	eb 13                	jmp    800c55 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	0f b6 10             	movzbl (%eax),%edx
  800c48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4b:	38 c2                	cmp    %al,%dl
  800c4d:	75 02                	jne    800c51 <memfind+0x22>
			break;
  800c4f:	eb 0c                	jmp    800c5d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c51:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c5b:	72 e5                	jb     800c42 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c68:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c6f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c76:	eb 04                	jmp    800c7c <strtol+0x1a>
		s++;
  800c78:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	0f b6 00             	movzbl (%eax),%eax
  800c82:	3c 20                	cmp    $0x20,%al
  800c84:	74 f2                	je     800c78 <strtol+0x16>
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	0f b6 00             	movzbl (%eax),%eax
  800c8c:	3c 09                	cmp    $0x9,%al
  800c8e:	74 e8                	je     800c78 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	0f b6 00             	movzbl (%eax),%eax
  800c96:	3c 2b                	cmp    $0x2b,%al
  800c98:	75 06                	jne    800ca0 <strtol+0x3e>
		s++;
  800c9a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c9e:	eb 15                	jmp    800cb5 <strtol+0x53>
	else if (*s == '-')
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	0f b6 00             	movzbl (%eax),%eax
  800ca6:	3c 2d                	cmp    $0x2d,%al
  800ca8:	75 0b                	jne    800cb5 <strtol+0x53>
		s++, neg = 1;
  800caa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cae:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb9:	74 06                	je     800cc1 <strtol+0x5f>
  800cbb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cbf:	75 24                	jne    800ce5 <strtol+0x83>
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	0f b6 00             	movzbl (%eax),%eax
  800cc7:	3c 30                	cmp    $0x30,%al
  800cc9:	75 1a                	jne    800ce5 <strtol+0x83>
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	83 c0 01             	add    $0x1,%eax
  800cd1:	0f b6 00             	movzbl (%eax),%eax
  800cd4:	3c 78                	cmp    $0x78,%al
  800cd6:	75 0d                	jne    800ce5 <strtol+0x83>
		s += 2, base = 16;
  800cd8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cdc:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ce3:	eb 2a                	jmp    800d0f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ce5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce9:	75 17                	jne    800d02 <strtol+0xa0>
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	0f b6 00             	movzbl (%eax),%eax
  800cf1:	3c 30                	cmp    $0x30,%al
  800cf3:	75 0d                	jne    800d02 <strtol+0xa0>
		s++, base = 8;
  800cf5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cf9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d00:	eb 0d                	jmp    800d0f <strtol+0xad>
	else if (base == 0)
  800d02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d06:	75 07                	jne    800d0f <strtol+0xad>
		base = 10;
  800d08:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	0f b6 00             	movzbl (%eax),%eax
  800d15:	3c 2f                	cmp    $0x2f,%al
  800d17:	7e 1b                	jle    800d34 <strtol+0xd2>
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	0f b6 00             	movzbl (%eax),%eax
  800d1f:	3c 39                	cmp    $0x39,%al
  800d21:	7f 11                	jg     800d34 <strtol+0xd2>
			dig = *s - '0';
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	0f b6 00             	movzbl (%eax),%eax
  800d29:	0f be c0             	movsbl %al,%eax
  800d2c:	83 e8 30             	sub    $0x30,%eax
  800d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d32:	eb 48                	jmp    800d7c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	0f b6 00             	movzbl (%eax),%eax
  800d3a:	3c 60                	cmp    $0x60,%al
  800d3c:	7e 1b                	jle    800d59 <strtol+0xf7>
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	0f b6 00             	movzbl (%eax),%eax
  800d44:	3c 7a                	cmp    $0x7a,%al
  800d46:	7f 11                	jg     800d59 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	0f b6 00             	movzbl (%eax),%eax
  800d4e:	0f be c0             	movsbl %al,%eax
  800d51:	83 e8 57             	sub    $0x57,%eax
  800d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d57:	eb 23                	jmp    800d7c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	0f b6 00             	movzbl (%eax),%eax
  800d5f:	3c 40                	cmp    $0x40,%al
  800d61:	7e 3d                	jle    800da0 <strtol+0x13e>
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	3c 5a                	cmp    $0x5a,%al
  800d6b:	7f 33                	jg     800da0 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	0f b6 00             	movzbl (%eax),%eax
  800d73:	0f be c0             	movsbl %al,%eax
  800d76:	83 e8 37             	sub    $0x37,%eax
  800d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d7f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d82:	7c 02                	jl     800d86 <strtol+0x124>
			break;
  800d84:	eb 1a                	jmp    800da0 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d96:	01 d0                	add    %edx,%eax
  800d98:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d9b:	e9 6f ff ff ff       	jmp    800d0f <strtol+0xad>

	if (endptr)
  800da0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da4:	74 08                	je     800dae <strtol+0x14c>
		*endptr = (char *) s;
  800da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dae:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800db2:	74 07                	je     800dbb <strtol+0x159>
  800db4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800db7:	f7 d8                	neg    %eax
  800db9:	eb 03                	jmp    800dbe <strtol+0x15c>
  800dbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 55 10             	mov    0x10(%ebp),%edx
  800dcf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dd2:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dd5:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800dd8:	8b 75 20             	mov    0x20(%ebp),%esi
  800ddb:	cd 30                	int    $0x30
  800ddd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de4:	74 30                	je     800e16 <syscall+0x56>
  800de6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dea:	7e 2a                	jle    800e16 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800def:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dfa:	c7 44 24 08 c4 17 80 	movl   $0x8017c4,0x8(%esp)
  800e01:	00 
  800e02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e09:	00 
  800e0a:	c7 04 24 e1 17 80 00 	movl   $0x8017e1,(%esp)
  800e11:	e8 f7 03 00 00       	call   80120d <_panic>

	return ret;
  800e16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e19:	83 c4 3c             	add    $0x3c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e31:	00 
  800e32:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e39:	00 
  800e3a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e41:	00 
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e45:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5c:	e8 5f ff ff ff       	call   800dc0 <syscall>
}
  800e61:	c9                   	leave  
  800e62:	c3                   	ret    

00800e63 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e69:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e70:	00 
  800e71:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e78:	00 
  800e79:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e80:	00 
  800e81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ea0:	e8 1b ff ff ff       	call   800dc0 <syscall>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ecf:	00 
  800ed0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800edb:	00 
  800edc:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ee3:	e8 d8 fe ff ff       	call   800dc0 <syscall>
}
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ef0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eff:	00 
  800f00:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f07:	00 
  800f08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f0f:	00 
  800f10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f17:	00 
  800f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f1f:	00 
  800f20:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f27:	e8 94 fe ff ff       	call   800dc0 <syscall>
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <sys_yield>:

void
sys_yield(void)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f34:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f43:	00 
  800f44:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f53:	00 
  800f54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f6b:	e8 50 fe ff ff       	call   800dc0 <syscall>
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f78:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f88:	00 
  800f89:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f90:	00 
  800f91:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f95:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f99:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fac:	e8 0f fe ff ff       	call   800dc0 <syscall>
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fbb:	8b 75 18             	mov    0x18(%ebp),%esi
  800fbe:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fc1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fce:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fd2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fd6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fde:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe5:	00 
  800fe6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fed:	e8 ce fd ff ff       	call   800dc0 <syscall>
}
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    

00800ff9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80100c:	00 
  80100d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801014:	00 
  801015:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80101c:	00 
  80101d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801021:	89 44 24 08          	mov    %eax,0x8(%esp)
  801025:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80102c:	00 
  80102d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801034:	e8 87 fd ff ff       	call   800dc0 <syscall>
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801041:	8b 55 0c             	mov    0xc(%ebp),%edx
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80104e:	00 
  80104f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801056:	00 
  801057:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80105e:	00 
  80105f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801063:	89 44 24 08          	mov    %eax,0x8(%esp)
  801067:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80106e:	00 
  80106f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801076:	e8 45 fd ff ff       	call   800dc0 <syscall>
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801083:	8b 55 0c             	mov    0xc(%ebp),%edx
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801090:	00 
  801091:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801098:	00 
  801099:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010a0:	00 
  8010a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010b8:	e8 03 fd ff ff       	call   800dc0 <syscall>
}
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010c5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010d5:	00 
  8010d6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010da:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010f8:	e8 c3 fc ff ff       	call   800dc0 <syscall>
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80110f:	00 
  801110:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801117:	00 
  801118:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80111f:	00 
  801120:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801127:	00 
  801128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801133:	00 
  801134:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80113b:	e8 80 fc ff ff       	call   800dc0 <syscall>
}
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <sys_exec>:

void sys_exec(char* buf){
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801148:	8b 45 08             	mov    0x8(%ebp),%eax
  80114b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801152:	00 
  801153:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115a:	00 
  80115b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801162:	00 
  801163:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80116a:	00 
  80116b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801176:	00 
  801177:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80117e:	e8 3d fc ff ff       	call   800dc0 <syscall>
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <sys_wait>:

void sys_wait(){
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80118b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801192:	00 
  801193:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80119a:	00 
  80119b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8011c2:	e8 f9 fb ff ff       	call   800dc0 <syscall>
}
  8011c7:	c9                   	leave  
  8011c8:	c3                   	ret    

008011c9 <sys_guest>:

void sys_guest(){
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8011cf:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011d6:	00 
  8011d7:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011de:	00 
  8011df:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011ee:	00 
  8011ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011fe:	00 
  8011ff:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  801206:	e8 b5 fb ff ff       	call   800dc0 <syscall>
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	53                   	push   %ebx
  801211:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801214:	8d 45 14             	lea    0x14(%ebp),%eax
  801217:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80121a:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801220:	e8 c5 fc ff ff       	call   800eea <sys_getenvid>
  801225:	8b 55 0c             	mov    0xc(%ebp),%edx
  801228:	89 54 24 10          	mov    %edx,0x10(%esp)
  80122c:	8b 55 08             	mov    0x8(%ebp),%edx
  80122f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801233:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801237:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123b:	c7 04 24 f0 17 80 00 	movl   $0x8017f0,(%esp)
  801242:	e8 6e ef ff ff       	call   8001b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801247:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124e:	8b 45 10             	mov    0x10(%ebp),%eax
  801251:	89 04 24             	mov    %eax,(%esp)
  801254:	e8 f8 ee ff ff       	call   800151 <vcprintf>
	cprintf("\n");
  801259:	c7 04 24 13 18 80 00 	movl   $0x801813,(%esp)
  801260:	e8 50 ef ff ff       	call   8001b5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801265:	cc                   	int3   
  801266:	eb fd                	jmp    801265 <_panic+0x58>
  801268:	66 90                	xchg   %ax,%ax
  80126a:	66 90                	xchg   %ax,%ax
  80126c:	66 90                	xchg   %ax,%ax
  80126e:	66 90                	xchg   %ax,%ax

00801270 <__udivdi3>:
  801270:	55                   	push   %ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	83 ec 0c             	sub    $0xc,%esp
  801276:	8b 44 24 28          	mov    0x28(%esp),%eax
  80127a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80127e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801282:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801286:	85 c0                	test   %eax,%eax
  801288:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128c:	89 ea                	mov    %ebp,%edx
  80128e:	89 0c 24             	mov    %ecx,(%esp)
  801291:	75 2d                	jne    8012c0 <__udivdi3+0x50>
  801293:	39 e9                	cmp    %ebp,%ecx
  801295:	77 61                	ja     8012f8 <__udivdi3+0x88>
  801297:	85 c9                	test   %ecx,%ecx
  801299:	89 ce                	mov    %ecx,%esi
  80129b:	75 0b                	jne    8012a8 <__udivdi3+0x38>
  80129d:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a2:	31 d2                	xor    %edx,%edx
  8012a4:	f7 f1                	div    %ecx
  8012a6:	89 c6                	mov    %eax,%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	89 e8                	mov    %ebp,%eax
  8012ac:	f7 f6                	div    %esi
  8012ae:	89 c5                	mov    %eax,%ebp
  8012b0:	89 f8                	mov    %edi,%eax
  8012b2:	f7 f6                	div    %esi
  8012b4:	89 ea                	mov    %ebp,%edx
  8012b6:	83 c4 0c             	add    $0xc,%esp
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    
  8012bd:	8d 76 00             	lea    0x0(%esi),%esi
  8012c0:	39 e8                	cmp    %ebp,%eax
  8012c2:	77 24                	ja     8012e8 <__udivdi3+0x78>
  8012c4:	0f bd e8             	bsr    %eax,%ebp
  8012c7:	83 f5 1f             	xor    $0x1f,%ebp
  8012ca:	75 3c                	jne    801308 <__udivdi3+0x98>
  8012cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012d0:	39 34 24             	cmp    %esi,(%esp)
  8012d3:	0f 86 9f 00 00 00    	jbe    801378 <__udivdi3+0x108>
  8012d9:	39 d0                	cmp    %edx,%eax
  8012db:	0f 82 97 00 00 00    	jb     801378 <__udivdi3+0x108>
  8012e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	31 c0                	xor    %eax,%eax
  8012ec:	83 c4 0c             	add    $0xc,%esp
  8012ef:	5e                   	pop    %esi
  8012f0:	5f                   	pop    %edi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    
  8012f3:	90                   	nop
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	89 f8                	mov    %edi,%eax
  8012fa:	f7 f1                	div    %ecx
  8012fc:	31 d2                	xor    %edx,%edx
  8012fe:	83 c4 0c             	add    $0xc,%esp
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    
  801305:	8d 76 00             	lea    0x0(%esi),%esi
  801308:	89 e9                	mov    %ebp,%ecx
  80130a:	8b 3c 24             	mov    (%esp),%edi
  80130d:	d3 e0                	shl    %cl,%eax
  80130f:	89 c6                	mov    %eax,%esi
  801311:	b8 20 00 00 00       	mov    $0x20,%eax
  801316:	29 e8                	sub    %ebp,%eax
  801318:	89 c1                	mov    %eax,%ecx
  80131a:	d3 ef                	shr    %cl,%edi
  80131c:	89 e9                	mov    %ebp,%ecx
  80131e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801322:	8b 3c 24             	mov    (%esp),%edi
  801325:	09 74 24 08          	or     %esi,0x8(%esp)
  801329:	89 d6                	mov    %edx,%esi
  80132b:	d3 e7                	shl    %cl,%edi
  80132d:	89 c1                	mov    %eax,%ecx
  80132f:	89 3c 24             	mov    %edi,(%esp)
  801332:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801336:	d3 ee                	shr    %cl,%esi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	d3 e2                	shl    %cl,%edx
  80133c:	89 c1                	mov    %eax,%ecx
  80133e:	d3 ef                	shr    %cl,%edi
  801340:	09 d7                	or     %edx,%edi
  801342:	89 f2                	mov    %esi,%edx
  801344:	89 f8                	mov    %edi,%eax
  801346:	f7 74 24 08          	divl   0x8(%esp)
  80134a:	89 d6                	mov    %edx,%esi
  80134c:	89 c7                	mov    %eax,%edi
  80134e:	f7 24 24             	mull   (%esp)
  801351:	39 d6                	cmp    %edx,%esi
  801353:	89 14 24             	mov    %edx,(%esp)
  801356:	72 30                	jb     801388 <__udivdi3+0x118>
  801358:	8b 54 24 04          	mov    0x4(%esp),%edx
  80135c:	89 e9                	mov    %ebp,%ecx
  80135e:	d3 e2                	shl    %cl,%edx
  801360:	39 c2                	cmp    %eax,%edx
  801362:	73 05                	jae    801369 <__udivdi3+0xf9>
  801364:	3b 34 24             	cmp    (%esp),%esi
  801367:	74 1f                	je     801388 <__udivdi3+0x118>
  801369:	89 f8                	mov    %edi,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	e9 7a ff ff ff       	jmp    8012ec <__udivdi3+0x7c>
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 d2                	xor    %edx,%edx
  80137a:	b8 01 00 00 00       	mov    $0x1,%eax
  80137f:	e9 68 ff ff ff       	jmp    8012ec <__udivdi3+0x7c>
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	8d 47 ff             	lea    -0x1(%edi),%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	83 c4 0c             	add    $0xc,%esp
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    
  801394:	66 90                	xchg   %ax,%ax
  801396:	66 90                	xchg   %ax,%ax
  801398:	66 90                	xchg   %ax,%ax
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__umoddi3>:
  8013a0:	55                   	push   %ebp
  8013a1:	57                   	push   %edi
  8013a2:	56                   	push   %esi
  8013a3:	83 ec 14             	sub    $0x14,%esp
  8013a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013b2:	89 c7                	mov    %eax,%edi
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013c0:	89 34 24             	mov    %esi,(%esp)
  8013c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cf:	75 17                	jne    8013e8 <__umoddi3+0x48>
  8013d1:	39 fe                	cmp    %edi,%esi
  8013d3:	76 4b                	jbe    801420 <__umoddi3+0x80>
  8013d5:	89 c8                	mov    %ecx,%eax
  8013d7:	89 fa                	mov    %edi,%edx
  8013d9:	f7 f6                	div    %esi
  8013db:	89 d0                	mov    %edx,%eax
  8013dd:	31 d2                	xor    %edx,%edx
  8013df:	83 c4 14             	add    $0x14,%esp
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	39 f8                	cmp    %edi,%eax
  8013ea:	77 54                	ja     801440 <__umoddi3+0xa0>
  8013ec:	0f bd e8             	bsr    %eax,%ebp
  8013ef:	83 f5 1f             	xor    $0x1f,%ebp
  8013f2:	75 5c                	jne    801450 <__umoddi3+0xb0>
  8013f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013f8:	39 3c 24             	cmp    %edi,(%esp)
  8013fb:	0f 87 e7 00 00 00    	ja     8014e8 <__umoddi3+0x148>
  801401:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801405:	29 f1                	sub    %esi,%ecx
  801407:	19 c7                	sbb    %eax,%edi
  801409:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801411:	8b 44 24 08          	mov    0x8(%esp),%eax
  801415:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801419:	83 c4 14             	add    $0x14,%esp
  80141c:	5e                   	pop    %esi
  80141d:	5f                   	pop    %edi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
  801420:	85 f6                	test   %esi,%esi
  801422:	89 f5                	mov    %esi,%ebp
  801424:	75 0b                	jne    801431 <__umoddi3+0x91>
  801426:	b8 01 00 00 00       	mov    $0x1,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f6                	div    %esi
  80142f:	89 c5                	mov    %eax,%ebp
  801431:	8b 44 24 04          	mov    0x4(%esp),%eax
  801435:	31 d2                	xor    %edx,%edx
  801437:	f7 f5                	div    %ebp
  801439:	89 c8                	mov    %ecx,%eax
  80143b:	f7 f5                	div    %ebp
  80143d:	eb 9c                	jmp    8013db <__umoddi3+0x3b>
  80143f:	90                   	nop
  801440:	89 c8                	mov    %ecx,%eax
  801442:	89 fa                	mov    %edi,%edx
  801444:	83 c4 14             	add    $0x14,%esp
  801447:	5e                   	pop    %esi
  801448:	5f                   	pop    %edi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    
  80144b:	90                   	nop
  80144c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801450:	8b 04 24             	mov    (%esp),%eax
  801453:	be 20 00 00 00       	mov    $0x20,%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	29 ee                	sub    %ebp,%esi
  80145c:	d3 e2                	shl    %cl,%edx
  80145e:	89 f1                	mov    %esi,%ecx
  801460:	d3 e8                	shr    %cl,%eax
  801462:	89 e9                	mov    %ebp,%ecx
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 04 24             	mov    (%esp),%eax
  80146b:	09 54 24 04          	or     %edx,0x4(%esp)
  80146f:	89 fa                	mov    %edi,%edx
  801471:	d3 e0                	shl    %cl,%eax
  801473:	89 f1                	mov    %esi,%ecx
  801475:	89 44 24 08          	mov    %eax,0x8(%esp)
  801479:	8b 44 24 10          	mov    0x10(%esp),%eax
  80147d:	d3 ea                	shr    %cl,%edx
  80147f:	89 e9                	mov    %ebp,%ecx
  801481:	d3 e7                	shl    %cl,%edi
  801483:	89 f1                	mov    %esi,%ecx
  801485:	d3 e8                	shr    %cl,%eax
  801487:	89 e9                	mov    %ebp,%ecx
  801489:	09 f8                	or     %edi,%eax
  80148b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80148f:	f7 74 24 04          	divl   0x4(%esp)
  801493:	d3 e7                	shl    %cl,%edi
  801495:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801499:	89 d7                	mov    %edx,%edi
  80149b:	f7 64 24 08          	mull   0x8(%esp)
  80149f:	39 d7                	cmp    %edx,%edi
  8014a1:	89 c1                	mov    %eax,%ecx
  8014a3:	89 14 24             	mov    %edx,(%esp)
  8014a6:	72 2c                	jb     8014d4 <__umoddi3+0x134>
  8014a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014ac:	72 22                	jb     8014d0 <__umoddi3+0x130>
  8014ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014b2:	29 c8                	sub    %ecx,%eax
  8014b4:	19 d7                	sbb    %edx,%edi
  8014b6:	89 e9                	mov    %ebp,%ecx
  8014b8:	89 fa                	mov    %edi,%edx
  8014ba:	d3 e8                	shr    %cl,%eax
  8014bc:	89 f1                	mov    %esi,%ecx
  8014be:	d3 e2                	shl    %cl,%edx
  8014c0:	89 e9                	mov    %ebp,%ecx
  8014c2:	d3 ef                	shr    %cl,%edi
  8014c4:	09 d0                	or     %edx,%eax
  8014c6:	89 fa                	mov    %edi,%edx
  8014c8:	83 c4 14             	add    $0x14,%esp
  8014cb:	5e                   	pop    %esi
  8014cc:	5f                   	pop    %edi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    
  8014cf:	90                   	nop
  8014d0:	39 d7                	cmp    %edx,%edi
  8014d2:	75 da                	jne    8014ae <__umoddi3+0x10e>
  8014d4:	8b 14 24             	mov    (%esp),%edx
  8014d7:	89 c1                	mov    %eax,%ecx
  8014d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014e1:	eb cb                	jmp    8014ae <__umoddi3+0x10e>
  8014e3:	90                   	nop
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014ec:	0f 82 0f ff ff ff    	jb     801401 <__umoddi3+0x61>
  8014f2:	e9 1a ff ff ff       	jmp    801411 <__umoddi3+0x71>
