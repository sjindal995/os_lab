
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	8b 0d 04 20 80 00    	mov    0x802004,%ecx
  800049:	b8 01 00 00 00       	mov    $0x1,%eax
  80004e:	99                   	cltd   
  80004f:	f7 f9                	idiv   %ecx
  800051:	89 44 24 04          	mov    %eax,0x4(%esp)
  800055:	c7 04 24 00 14 80 00 	movl   $0x801400,(%esp)
  80005c:	e8 25 01 00 00       	call   800186 <cprintf>
}
  800061:	c9                   	leave  
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800069:	e8 4d 0e 00 00       	call   800ebb <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	c1 e0 02             	shl    $0x2,%eax
  800076:	89 c2                	mov    %eax,%edx
  800078:	c1 e2 05             	shl    $0x5,%edx
  80007b:	29 c2                	sub    %eax,%edx
  80007d:	89 d0                	mov    %edx,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80008d:	7e 0a                	jle    800099 <libmain+0x36>
		binaryname = argv[0];
  80008f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800092:	8b 00                	mov    (%eax),%eax
  800094:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800099:	8b 45 0c             	mov    0xc(%ebp),%eax
  80009c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a3:	89 04 24             	mov    %eax,(%esp)
  8000a6:	e8 88 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ab:	e8 02 00 00 00       	call   8000b2 <exit>
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bf:	e8 b4 0d 00 00       	call   800e78 <sys_env_destroy>
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cf:	8b 00                	mov    (%eax),%eax
  8000d1:	8d 48 01             	lea    0x1(%eax),%ecx
  8000d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d7:	89 0a                	mov    %ecx,(%edx)
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000e1:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e8:	8b 00                	mov    (%eax),%eax
  8000ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ef:	75 20                	jne    800111 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f4:	8b 00                	mov    (%eax),%eax
  8000f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000f9:	83 c2 08             	add    $0x8,%edx
  8000fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800100:	89 14 24             	mov    %edx,(%esp)
  800103:	e8 ea 0c 00 00       	call   800df2 <sys_cputs>
		b->idx = 0;
  800108:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800111:	8b 45 0c             	mov    0xc(%ebp),%eax
  800114:	8b 40 04             	mov    0x4(%eax),%eax
  800117:	8d 50 01             	lea    0x1(%eax),%edx
  80011a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800142:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800146:	8b 45 08             	mov    0x8(%ebp),%eax
  800149:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800153:	89 44 24 04          	mov    %eax,0x4(%esp)
  800157:	c7 04 24 c6 00 80 00 	movl   $0x8000c6,(%esp)
  80015e:	e8 bd 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800163:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800173:	83 c0 08             	add    $0x8,%eax
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 74 0c 00 00       	call   800df2 <sys_cputs>

	return b.cnt;
  80017e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018c:	8d 45 0c             	lea    0xc(%ebp),%eax
  80018f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800192:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 7e ff ff ff       	call   800122 <vcprintf>
  8001a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 34             	sub    $0x34,%esp
  8001b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bf:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ca:	77 72                	ja     80023e <printnum+0x92>
  8001cc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001cf:	72 05                	jb     8001d6 <printnum+0x2a>
  8001d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001d4:	77 68                	ja     80023e <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dc:	8b 45 18             	mov    0x18(%ebp),%eax
  8001df:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	e8 72 0f 00 00       	call   801170 <__udivdi3>
  8001fe:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800201:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800205:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800209:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80020c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800210:	89 44 24 08          	mov    %eax,0x8(%esp)
  800214:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	8b 45 08             	mov    0x8(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	e8 82 ff ff ff       	call   8001ac <printnum>
  80022a:	eb 1c                	jmp    800248 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	8b 45 20             	mov    0x20(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800242:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800246:	7f e4                	jg     80022c <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800248:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80024b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800253:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800256:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80025e:	89 04 24             	mov    %eax,(%esp)
  800261:	89 54 24 04          	mov    %edx,0x4(%esp)
  800265:	e8 36 10 00 00       	call   8012a0 <__umoddi3>
  80026a:	05 e8 14 80 00       	add    $0x8014e8,%eax
  80026f:	0f b6 00             	movzbl (%eax),%eax
  800272:	0f be c0             	movsbl %al,%eax
  800275:	8b 55 0c             	mov    0xc(%ebp),%edx
  800278:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027c:	89 04 24             	mov    %eax,(%esp)
  80027f:	8b 45 08             	mov    0x8(%ebp),%eax
  800282:	ff d0                	call   *%eax
}
  800284:	83 c4 34             	add    $0x34,%esp
  800287:	5b                   	pop    %ebx
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800291:	7e 14                	jle    8002a7 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	8b 00                	mov    (%eax),%eax
  800298:	8d 48 08             	lea    0x8(%eax),%ecx
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	89 0a                	mov    %ecx,(%edx)
  8002a0:	8b 50 04             	mov    0x4(%eax),%edx
  8002a3:	8b 00                	mov    (%eax),%eax
  8002a5:	eb 30                	jmp    8002d7 <getuint+0x4d>
	else if (lflag)
  8002a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002ab:	74 16                	je     8002c3 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 00                	mov    (%eax),%eax
  8002b2:	8d 48 04             	lea    0x4(%eax),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 0a                	mov    %ecx,(%edx)
  8002ba:	8b 00                	mov    (%eax),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c1:	eb 14                	jmp    8002d7 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	8b 00                	mov    (%eax),%eax
  8002c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 0a                	mov    %ecx,(%edx)
  8002d0:	8b 00                	mov    (%eax),%eax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002dc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002e0:	7e 14                	jle    8002f6 <getint+0x1d>
		return va_arg(*ap, long long);
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	8b 00                	mov    (%eax),%eax
  8002e7:	8d 48 08             	lea    0x8(%eax),%ecx
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	89 0a                	mov    %ecx,(%edx)
  8002ef:	8b 50 04             	mov    0x4(%eax),%edx
  8002f2:	8b 00                	mov    (%eax),%eax
  8002f4:	eb 28                	jmp    80031e <getint+0x45>
	else if (lflag)
  8002f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002fa:	74 12                	je     80030e <getint+0x35>
		return va_arg(*ap, long);
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	8b 00                	mov    (%eax),%eax
  800301:	8d 48 04             	lea    0x4(%eax),%ecx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	89 0a                	mov    %ecx,(%edx)
  800309:	8b 00                	mov    (%eax),%eax
  80030b:	99                   	cltd   
  80030c:	eb 10                	jmp    80031e <getint+0x45>
	else
		return va_arg(*ap, int);
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 00                	mov    (%eax),%eax
  800313:	8d 48 04             	lea    0x4(%eax),%ecx
  800316:	8b 55 08             	mov    0x8(%ebp),%edx
  800319:	89 0a                	mov    %ecx,(%edx)
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	99                   	cltd   
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	56                   	push   %esi
  800324:	53                   	push   %ebx
  800325:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800328:	eb 18                	jmp    800342 <vprintfmt+0x22>
			if (ch == '\0')
  80032a:	85 db                	test   %ebx,%ebx
  80032c:	75 05                	jne    800333 <vprintfmt+0x13>
				return;
  80032e:	e9 cc 03 00 00       	jmp    8006ff <vprintfmt+0x3df>
			putch(ch, putdat);
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
  800336:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033a:	89 1c 24             	mov    %ebx,(%esp)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800342:	8b 45 10             	mov    0x10(%ebp),%eax
  800345:	8d 50 01             	lea    0x1(%eax),%edx
  800348:	89 55 10             	mov    %edx,0x10(%ebp)
  80034b:	0f b6 00             	movzbl (%eax),%eax
  80034e:	0f b6 d8             	movzbl %al,%ebx
  800351:	83 fb 25             	cmp    $0x25,%ebx
  800354:	75 d4                	jne    80032a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800356:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80035a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800361:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800368:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80036f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 45 10             	mov    0x10(%ebp),%eax
  800379:	8d 50 01             	lea    0x1(%eax),%edx
  80037c:	89 55 10             	mov    %edx,0x10(%ebp)
  80037f:	0f b6 00             	movzbl (%eax),%eax
  800382:	0f b6 d8             	movzbl %al,%ebx
  800385:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800388:	83 f8 55             	cmp    $0x55,%eax
  80038b:	0f 87 3d 03 00 00    	ja     8006ce <vprintfmt+0x3ae>
  800391:	8b 04 85 0c 15 80 00 	mov    0x80150c(,%eax,4),%eax
  800398:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80039a:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80039e:	eb d6                	jmp    800376 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003a4:	eb d0                	jmp    800376 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003b0:	89 d0                	mov    %edx,%eax
  8003b2:	c1 e0 02             	shl    $0x2,%eax
  8003b5:	01 d0                	add    %edx,%eax
  8003b7:	01 c0                	add    %eax,%eax
  8003b9:	01 d8                	add    %ebx,%eax
  8003bb:	83 e8 30             	sub    $0x30,%eax
  8003be:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c4:	0f b6 00             	movzbl (%eax),%eax
  8003c7:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003ca:	83 fb 2f             	cmp    $0x2f,%ebx
  8003cd:	7e 0b                	jle    8003da <vprintfmt+0xba>
  8003cf:	83 fb 39             	cmp    $0x39,%ebx
  8003d2:	7f 06                	jg     8003da <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d8:	eb d3                	jmp    8003ad <vprintfmt+0x8d>
			goto process_precision;
  8003da:	eb 33                	jmp    80040f <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 50 04             	lea    0x4(%eax),%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003ea:	eb 23                	jmp    80040f <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f0:	79 0c                	jns    8003fe <vprintfmt+0xde>
				width = 0;
  8003f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003f9:	e9 78 ff ff ff       	jmp    800376 <vprintfmt+0x56>
  8003fe:	e9 73 ff ff ff       	jmp    800376 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800403:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80040a:	e9 67 ff ff ff       	jmp    800376 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80040f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800413:	79 12                	jns    800427 <vprintfmt+0x107>
				width = precision, precision = -1;
  800415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800418:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80041b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800422:	e9 4f ff ff ff       	jmp    800376 <vprintfmt+0x56>
  800427:	e9 4a ff ff ff       	jmp    800376 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800430:	e9 41 ff ff ff       	jmp    800376 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	8b 55 0c             	mov    0xc(%ebp),%edx
  800443:	89 54 24 04          	mov    %edx,0x4(%esp)
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	ff d0                	call   *%eax
			break;
  80044f:	e9 a5 02 00 00       	jmp    8006f9 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80045f:	85 db                	test   %ebx,%ebx
  800461:	79 02                	jns    800465 <vprintfmt+0x145>
				err = -err;
  800463:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800465:	83 fb 09             	cmp    $0x9,%ebx
  800468:	7f 0b                	jg     800475 <vprintfmt+0x155>
  80046a:	8b 34 9d c0 14 80 00 	mov    0x8014c0(,%ebx,4),%esi
  800471:	85 f6                	test   %esi,%esi
  800473:	75 23                	jne    800498 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800475:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800479:	c7 44 24 08 f9 14 80 	movl   $0x8014f9,0x8(%esp)
  800480:	00 
  800481:	8b 45 0c             	mov    0xc(%ebp),%eax
  800484:	89 44 24 04          	mov    %eax,0x4(%esp)
  800488:	8b 45 08             	mov    0x8(%ebp),%eax
  80048b:	89 04 24             	mov    %eax,(%esp)
  80048e:	e8 73 02 00 00       	call   800706 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800493:	e9 61 02 00 00       	jmp    8006f9 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800498:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80049c:	c7 44 24 08 02 15 80 	movl   $0x801502,0x8(%esp)
  8004a3:	00 
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	89 04 24             	mov    %eax,(%esp)
  8004b1:	e8 50 02 00 00       	call   800706 <printfmt>
			break;
  8004b6:	e9 3e 02 00 00       	jmp    8006f9 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 30                	mov    (%eax),%esi
  8004c6:	85 f6                	test   %esi,%esi
  8004c8:	75 05                	jne    8004cf <vprintfmt+0x1af>
				p = "(null)";
  8004ca:	be 05 15 80 00       	mov    $0x801505,%esi
			if (width > 0 && padc != '-')
  8004cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d3:	7e 37                	jle    80050c <vprintfmt+0x1ec>
  8004d5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004d9:	74 31                	je     80050c <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e2:	89 34 24             	mov    %esi,(%esp)
  8004e5:	e8 39 03 00 00       	call   800823 <strnlen>
  8004ea:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004ed:	eb 17                	jmp    800506 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004ef:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004fa:	89 04 24             	mov    %eax,(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800506:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050a:	7f e3                	jg     8004ef <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	eb 38                	jmp    800546 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800512:	74 1f                	je     800533 <vprintfmt+0x213>
  800514:	83 fb 1f             	cmp    $0x1f,%ebx
  800517:	7e 05                	jle    80051e <vprintfmt+0x1fe>
  800519:	83 fb 7e             	cmp    $0x7e,%ebx
  80051c:	7e 15                	jle    800533 <vprintfmt+0x213>
					putch('?', putdat);
  80051e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800521:	89 44 24 04          	mov    %eax,0x4(%esp)
  800525:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	ff d0                	call   *%eax
  800531:	eb 0f                	jmp    800542 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
  800536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053a:	89 1c 24             	mov    %ebx,(%esp)
  80053d:	8b 45 08             	mov    0x8(%ebp),%eax
  800540:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800542:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800546:	89 f0                	mov    %esi,%eax
  800548:	8d 70 01             	lea    0x1(%eax),%esi
  80054b:	0f b6 00             	movzbl (%eax),%eax
  80054e:	0f be d8             	movsbl %al,%ebx
  800551:	85 db                	test   %ebx,%ebx
  800553:	74 10                	je     800565 <vprintfmt+0x245>
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	78 b3                	js     80050e <vprintfmt+0x1ee>
  80055b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80055f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800563:	79 a9                	jns    80050e <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800565:	eb 17                	jmp    80057e <vprintfmt+0x25e>
				putch(' ', putdat);
  800567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800575:	8b 45 08             	mov    0x8(%ebp),%eax
  800578:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80057e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800582:	7f e3                	jg     800567 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800584:	e9 70 01 00 00       	jmp    8006f9 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800589:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80058c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800590:	8d 45 14             	lea    0x14(%ebp),%eax
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 3e fd ff ff       	call   8002d9 <getint>
  80059b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80059e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	79 26                	jns    8005d1 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	ff d0                	call   *%eax
				num = -(long long) num;
  8005be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005c4:	f7 d8                	neg    %eax
  8005c6:	83 d2 00             	adc    $0x0,%edx
  8005c9:	f7 da                	neg    %edx
  8005cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005d1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005d8:	e9 a8 00 00 00       	jmp    800685 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e7:	89 04 24             	mov    %eax,(%esp)
  8005ea:	e8 9b fc ff ff       	call   80028a <getuint>
  8005ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005f5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005fc:	e9 84 00 00 00       	jmp    800685 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800601:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800604:	89 44 24 04          	mov    %eax,0x4(%esp)
  800608:	8d 45 14             	lea    0x14(%ebp),%eax
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	e8 77 fc ff ff       	call   80028a <getuint>
  800613:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800616:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800619:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800620:	eb 63                	jmp    800685 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800622:	8b 45 0c             	mov    0xc(%ebp),%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800630:	8b 45 08             	mov    0x8(%ebp),%eax
  800633:	ff d0                	call   *%eax
			putch('x', putdat);
  800635:	8b 45 0c             	mov    0xc(%ebp),%eax
  800638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800643:	8b 45 08             	mov    0x8(%ebp),%eax
  800646:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800653:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800656:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800664:	eb 1f                	jmp    800685 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800666:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	89 04 24             	mov    %eax,(%esp)
  800673:	e8 12 fc ff ff       	call   80028a <getuint>
  800678:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80067b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80067e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800685:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800689:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068c:	89 54 24 18          	mov    %edx,0x18(%esp)
  800690:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800693:	89 54 24 14          	mov    %edx,0x14(%esp)
  800697:	89 44 24 10          	mov    %eax,0x10(%esp)
  80069b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	89 04 24             	mov    %eax,(%esp)
  8006b6:	e8 f1 fa ff ff       	call   8001ac <printnum>
			break;
  8006bb:	eb 3c                	jmp    8006f9 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	89 1c 24             	mov    %ebx,(%esp)
  8006c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ca:	ff d0                	call   *%eax
			break;
  8006cc:	eb 2b                	jmp    8006f9 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006e5:	eb 04                	jmp    8006eb <vprintfmt+0x3cb>
  8006e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ee:	83 e8 01             	sub    $0x1,%eax
  8006f1:	0f b6 00             	movzbl (%eax),%eax
  8006f4:	3c 25                	cmp    $0x25,%al
  8006f6:	75 ef                	jne    8006e7 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8006f8:	90                   	nop
		}
	}
  8006f9:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fa:	e9 43 fc ff ff       	jmp    800342 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006ff:	83 c4 40             	add    $0x40,%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800719:	8b 45 10             	mov    0x10(%ebp),%eax
  80071c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800720:	8b 45 0c             	mov    0xc(%ebp),%eax
  800723:	89 44 24 04          	mov    %eax,0x4(%esp)
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	e8 ee fb ff ff       	call   800320 <vprintfmt>
	va_end(ap);
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    

00800734 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073a:	8b 40 08             	mov    0x8(%eax),%eax
  80073d:	8d 50 01             	lea    0x1(%eax),%edx
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800746:	8b 45 0c             	mov    0xc(%ebp),%eax
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074e:	8b 40 04             	mov    0x4(%eax),%eax
  800751:	39 c2                	cmp    %eax,%edx
  800753:	73 12                	jae    800767 <sprintputch+0x33>
		*b->buf++ = ch;
  800755:	8b 45 0c             	mov    0xc(%ebp),%eax
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	8d 48 01             	lea    0x1(%eax),%ecx
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800760:	89 0a                	mov    %ecx,(%edx)
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
  800765:	88 10                	mov    %dl,(%eax)
}
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8b 45 0c             	mov    0xc(%ebp),%eax
  800778:	8d 50 ff             	lea    -0x1(%eax),%edx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	01 d0                	add    %edx,%eax
  800780:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80078e:	74 06                	je     800796 <vsnprintf+0x2d>
  800790:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800794:	7f 07                	jg     80079d <vsnprintf+0x34>
		return -E_INVAL;
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079b:	eb 2a                	jmp    8007c7 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b2:	c7 04 24 34 07 80 00 	movl   $0x800734,(%esp)
  8007b9:	e8 62 fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	e8 74 ff ff ff       	call   800769 <vsnprintf>
  8007f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80080a:	eb 08                	jmp    800814 <strlen+0x17>
		n++;
  80080c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800810:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	0f b6 00             	movzbl (%eax),%eax
  80081a:	84 c0                	test   %al,%al
  80081c:	75 ee                	jne    80080c <strlen+0xf>
		n++;
	return n;
  80081e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800829:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800830:	eb 0c                	jmp    80083e <strnlen+0x1b>
		n++;
  800832:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80083a:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80083e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800842:	74 0a                	je     80084e <strnlen+0x2b>
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 00             	movzbl (%eax),%eax
  80084a:	84 c0                	test   %al,%al
  80084c:	75 e4                	jne    800832 <strnlen+0xf>
		n++;
	return n;
  80084e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80085f:	90                   	nop
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8d 50 01             	lea    0x1(%eax),%edx
  800866:	89 55 08             	mov    %edx,0x8(%ebp)
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80086f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	88 10                	mov    %dl,(%eax)
  800877:	0f b6 00             	movzbl (%eax),%eax
  80087a:	84 c0                	test   %al,%al
  80087c:	75 e2                	jne    800860 <strcpy+0xd>
		/* do nothing */;
	return ret;
  80087e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	89 04 24             	mov    %eax,(%esp)
  80088f:	e8 69 ff ff ff       	call   8007fd <strlen>
  800894:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800897:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	01 c2                	add    %eax,%edx
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a6:	89 14 24             	mov    %edx,(%esp)
  8008a9:	e8 a5 ff ff ff       	call   800853 <strcpy>
	return dst;
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008c6:	eb 23                	jmp    8008eb <strncpy+0x38>
		*dst++ = *src;
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8d 50 01             	lea    0x1(%eax),%edx
  8008ce:	89 55 08             	mov    %edx,0x8(%ebp)
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dc:	0f b6 00             	movzbl (%eax),%eax
  8008df:	84 c0                	test   %al,%al
  8008e1:	74 04                	je     8008e7 <strncpy+0x34>
			src++;
  8008e3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8008eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ee:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008f1:	72 d5                	jb     8008c8 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800904:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800908:	74 33                	je     80093d <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80090a:	eb 17                	jmp    800923 <strlcpy+0x2b>
			*dst++ = *src++;
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8d 50 01             	lea    0x1(%eax),%edx
  800912:	89 55 08             	mov    %edx,0x8(%ebp)
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
  800918:	8d 4a 01             	lea    0x1(%edx),%ecx
  80091b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80091e:	0f b6 12             	movzbl (%edx),%edx
  800921:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800923:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800927:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80092b:	74 0a                	je     800937 <strlcpy+0x3f>
  80092d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800930:	0f b6 00             	movzbl (%eax),%eax
  800933:	84 c0                	test   %al,%al
  800935:	75 d5                	jne    80090c <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093d:	8b 55 08             	mov    0x8(%ebp),%edx
  800940:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800943:	29 c2                	sub    %eax,%edx
  800945:	89 d0                	mov    %edx,%eax
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80094c:	eb 08                	jmp    800956 <strcmp+0xd>
		p++, q++;
  80094e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800952:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	0f b6 00             	movzbl (%eax),%eax
  80095c:	84 c0                	test   %al,%al
  80095e:	74 10                	je     800970 <strcmp+0x27>
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 10             	movzbl (%eax),%edx
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	0f b6 00             	movzbl (%eax),%eax
  80096c:	38 c2                	cmp    %al,%dl
  80096e:	74 de                	je     80094e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	0f b6 00             	movzbl (%eax),%eax
  800976:	0f b6 d0             	movzbl %al,%edx
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	0f b6 00             	movzbl (%eax),%eax
  80097f:	0f b6 c0             	movzbl %al,%eax
  800982:	29 c2                	sub    %eax,%edx
  800984:	89 d0                	mov    %edx,%eax
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  80098b:	eb 0c                	jmp    800999 <strncmp+0x11>
		n--, p++, q++;
  80098d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800991:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800995:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80099d:	74 1a                	je     8009b9 <strncmp+0x31>
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 10                	je     8009b9 <strncmp+0x31>
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	0f b6 10             	movzbl (%eax),%edx
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	0f b6 00             	movzbl (%eax),%eax
  8009b5:	38 c2                	cmp    %al,%dl
  8009b7:	74 d4                	je     80098d <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009bd:	75 07                	jne    8009c6 <strncmp+0x3e>
		return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c4:	eb 16                	jmp    8009dc <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	0f b6 00             	movzbl (%eax),%eax
  8009cc:	0f b6 d0             	movzbl %al,%edx
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	0f b6 00             	movzbl (%eax),%eax
  8009d5:	0f b6 c0             	movzbl %al,%eax
  8009d8:	29 c2                	sub    %eax,%edx
  8009da:	89 d0                	mov    %edx,%eax
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 04             	sub    $0x4,%esp
  8009e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009ea:	eb 14                	jmp    800a00 <strchr+0x22>
		if (*s == c)
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 00             	movzbl (%eax),%eax
  8009f2:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009f5:	75 05                	jne    8009fc <strchr+0x1e>
			return (char *) s;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	eb 13                	jmp    800a0f <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 00             	movzbl (%eax),%eax
  800a06:	84 c0                	test   %al,%al
  800a08:	75 e2                	jne    8009ec <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 04             	sub    $0x4,%esp
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a1d:	eb 11                	jmp    800a30 <strfind+0x1f>
		if (*s == c)
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	0f b6 00             	movzbl (%eax),%eax
  800a25:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a28:	75 02                	jne    800a2c <strfind+0x1b>
			break;
  800a2a:	eb 0e                	jmp    800a3a <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	0f b6 00             	movzbl (%eax),%eax
  800a36:	84 c0                	test   %al,%al
  800a38:	75 e5                	jne    800a1f <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a47:	75 05                	jne    800a4e <memset+0xf>
		return v;
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	eb 5c                	jmp    800aaa <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	83 e0 03             	and    $0x3,%eax
  800a54:	85 c0                	test   %eax,%eax
  800a56:	75 41                	jne    800a99 <memset+0x5a>
  800a58:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5b:	83 e0 03             	and    $0x3,%eax
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	75 37                	jne    800a99 <memset+0x5a>
		c &= 0xFF;
  800a62:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	c1 e0 18             	shl    $0x18,%eax
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	c1 e0 10             	shl    $0x10,%eax
  800a77:	09 c2                	or     %eax,%edx
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	c1 e0 08             	shl    $0x8,%eax
  800a7f:	09 d0                	or     %edx,%eax
  800a81:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a84:	8b 45 10             	mov    0x10(%ebp),%eax
  800a87:	c1 e8 02             	shr    $0x2,%eax
  800a8a:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	fc                   	cld    
  800a95:	f3 ab                	rep stos %eax,%es:(%edi)
  800a97:	eb 0e                	jmp    800aa7 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aa2:	89 d7                	mov    %edx,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ac8:	73 6d                	jae    800b37 <memmove+0x8a>
  800aca:	8b 45 10             	mov    0x10(%ebp),%eax
  800acd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ad0:	01 d0                	add    %edx,%eax
  800ad2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ad5:	76 60                	jbe    800b37 <memmove+0x8a>
		s += n;
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800add:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae0:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae6:	83 e0 03             	and    $0x3,%eax
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	75 2f                	jne    800b1c <memmove+0x6f>
  800aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af0:	83 e0 03             	and    $0x3,%eax
  800af3:	85 c0                	test   %eax,%eax
  800af5:	75 25                	jne    800b1c <memmove+0x6f>
  800af7:	8b 45 10             	mov    0x10(%ebp),%eax
  800afa:	83 e0 03             	and    $0x3,%eax
  800afd:	85 c0                	test   %eax,%eax
  800aff:	75 1b                	jne    800b1c <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b04:	83 e8 04             	sub    $0x4,%eax
  800b07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b0a:	83 ea 04             	sub    $0x4,%edx
  800b0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b13:	89 c7                	mov    %eax,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	fd                   	std    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb 18                	jmp    800b34 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b1f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b25:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b28:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2b:	89 d7                	mov    %edx,%edi
  800b2d:	89 de                	mov    %ebx,%esi
  800b2f:	89 c1                	mov    %eax,%ecx
  800b31:	fd                   	std    
  800b32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b34:	fc                   	cld    
  800b35:	eb 45                	jmp    800b7c <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3a:	83 e0 03             	and    $0x3,%eax
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 2b                	jne    800b6c <memmove+0xbf>
  800b41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b44:	83 e0 03             	and    $0x3,%eax
  800b47:	85 c0                	test   %eax,%eax
  800b49:	75 21                	jne    800b6c <memmove+0xbf>
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	83 e0 03             	and    $0x3,%eax
  800b51:	85 c0                	test   %eax,%eax
  800b53:	75 17                	jne    800b6c <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b55:	8b 45 10             	mov    0x10(%ebp),%eax
  800b58:	c1 e8 02             	shr    $0x2,%eax
  800b5b:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b63:	89 c7                	mov    %eax,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	fc                   	cld    
  800b68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6a:	eb 10                	jmp    800b7c <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b72:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	fc                   	cld    
  800b7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	89 04 24             	mov    %eax,(%esp)
  800ba1:	e8 07 ff ff ff       	call   800aad <memmove>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bba:	eb 30                	jmp    800bec <memcmp+0x44>
		if (*s1 != *s2)
  800bbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbf:	0f b6 10             	movzbl (%eax),%edx
  800bc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bc5:	0f b6 00             	movzbl (%eax),%eax
  800bc8:	38 c2                	cmp    %al,%dl
  800bca:	74 18                	je     800be4 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bcf:	0f b6 00             	movzbl (%eax),%eax
  800bd2:	0f b6 d0             	movzbl %al,%edx
  800bd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bd8:	0f b6 00             	movzbl (%eax),%eax
  800bdb:	0f b6 c0             	movzbl %al,%eax
  800bde:	29 c2                	sub    %eax,%edx
  800be0:	89 d0                	mov    %edx,%eax
  800be2:	eb 1a                	jmp    800bfe <memcmp+0x56>
		s1++, s2++;
  800be4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800be8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bec:	8b 45 10             	mov    0x10(%ebp),%eax
  800bef:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bf2:	89 55 10             	mov    %edx,0x10(%ebp)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	75 c3                	jne    800bbc <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c06:	8b 45 10             	mov    0x10(%ebp),%eax
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	01 d0                	add    %edx,%eax
  800c0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c11:	eb 13                	jmp    800c26 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	0f b6 10             	movzbl (%eax),%edx
  800c19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1c:	38 c2                	cmp    %al,%dl
  800c1e:	75 02                	jne    800c22 <memfind+0x22>
			break;
  800c20:	eb 0c                	jmp    800c2e <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c2c:	72 e5                	jb     800c13 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c39:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c40:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c47:	eb 04                	jmp    800c4d <strtol+0x1a>
		s++;
  800c49:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 00             	movzbl (%eax),%eax
  800c53:	3c 20                	cmp    $0x20,%al
  800c55:	74 f2                	je     800c49 <strtol+0x16>
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	0f b6 00             	movzbl (%eax),%eax
  800c5d:	3c 09                	cmp    $0x9,%al
  800c5f:	74 e8                	je     800c49 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	0f b6 00             	movzbl (%eax),%eax
  800c67:	3c 2b                	cmp    $0x2b,%al
  800c69:	75 06                	jne    800c71 <strtol+0x3e>
		s++;
  800c6b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6f:	eb 15                	jmp    800c86 <strtol+0x53>
	else if (*s == '-')
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	0f b6 00             	movzbl (%eax),%eax
  800c77:	3c 2d                	cmp    $0x2d,%al
  800c79:	75 0b                	jne    800c86 <strtol+0x53>
		s++, neg = 1;
  800c7b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c86:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c8a:	74 06                	je     800c92 <strtol+0x5f>
  800c8c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c90:	75 24                	jne    800cb6 <strtol+0x83>
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	0f b6 00             	movzbl (%eax),%eax
  800c98:	3c 30                	cmp    $0x30,%al
  800c9a:	75 1a                	jne    800cb6 <strtol+0x83>
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	83 c0 01             	add    $0x1,%eax
  800ca2:	0f b6 00             	movzbl (%eax),%eax
  800ca5:	3c 78                	cmp    $0x78,%al
  800ca7:	75 0d                	jne    800cb6 <strtol+0x83>
		s += 2, base = 16;
  800ca9:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cad:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cb4:	eb 2a                	jmp    800ce0 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cb6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cba:	75 17                	jne    800cd3 <strtol+0xa0>
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	0f b6 00             	movzbl (%eax),%eax
  800cc2:	3c 30                	cmp    $0x30,%al
  800cc4:	75 0d                	jne    800cd3 <strtol+0xa0>
		s++, base = 8;
  800cc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cca:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cd1:	eb 0d                	jmp    800ce0 <strtol+0xad>
	else if (base == 0)
  800cd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd7:	75 07                	jne    800ce0 <strtol+0xad>
		base = 10;
  800cd9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	0f b6 00             	movzbl (%eax),%eax
  800ce6:	3c 2f                	cmp    $0x2f,%al
  800ce8:	7e 1b                	jle    800d05 <strtol+0xd2>
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	0f b6 00             	movzbl (%eax),%eax
  800cf0:	3c 39                	cmp    $0x39,%al
  800cf2:	7f 11                	jg     800d05 <strtol+0xd2>
			dig = *s - '0';
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 00             	movzbl (%eax),%eax
  800cfa:	0f be c0             	movsbl %al,%eax
  800cfd:	83 e8 30             	sub    $0x30,%eax
  800d00:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d03:	eb 48                	jmp    800d4d <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	0f b6 00             	movzbl (%eax),%eax
  800d0b:	3c 60                	cmp    $0x60,%al
  800d0d:	7e 1b                	jle    800d2a <strtol+0xf7>
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	0f b6 00             	movzbl (%eax),%eax
  800d15:	3c 7a                	cmp    $0x7a,%al
  800d17:	7f 11                	jg     800d2a <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	0f b6 00             	movzbl (%eax),%eax
  800d1f:	0f be c0             	movsbl %al,%eax
  800d22:	83 e8 57             	sub    $0x57,%eax
  800d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d28:	eb 23                	jmp    800d4d <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	0f b6 00             	movzbl (%eax),%eax
  800d30:	3c 40                	cmp    $0x40,%al
  800d32:	7e 3d                	jle    800d71 <strtol+0x13e>
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	0f b6 00             	movzbl (%eax),%eax
  800d3a:	3c 5a                	cmp    $0x5a,%al
  800d3c:	7f 33                	jg     800d71 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	0f b6 00             	movzbl (%eax),%eax
  800d44:	0f be c0             	movsbl %al,%eax
  800d47:	83 e8 37             	sub    $0x37,%eax
  800d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d50:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d53:	7c 02                	jl     800d57 <strtol+0x124>
			break;
  800d55:	eb 1a                	jmp    800d71 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d57:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d62:	89 c2                	mov    %eax,%edx
  800d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d67:	01 d0                	add    %edx,%eax
  800d69:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d6c:	e9 6f ff ff ff       	jmp    800ce0 <strtol+0xad>

	if (endptr)
  800d71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d75:	74 08                	je     800d7f <strtol+0x14c>
		*endptr = (char *) s;
  800d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d7f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d83:	74 07                	je     800d8c <strtol+0x159>
  800d85:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d88:	f7 d8                	neg    %eax
  800d8a:	eb 03                	jmp    800d8f <strtol+0x15c>
  800d8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	8b 55 10             	mov    0x10(%ebp),%edx
  800da0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800da3:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800da6:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800da9:	8b 75 20             	mov    0x20(%ebp),%esi
  800dac:	cd 30                	int    $0x30
  800dae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db5:	74 30                	je     800de7 <syscall+0x56>
  800db7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dbb:	7e 2a                	jle    800de7 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcb:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dda:	00 
  800ddb:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800de2:	e8 2c 03 00 00       	call   801113 <_panic>

	return ret;
  800de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800dea:	83 c4 3c             	add    $0x3c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e02:	00 
  800e03:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e12:	00 
  800e13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e16:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e2d:	e8 5f ff ff ff       	call   800d91 <syscall>
}
  800e32:	c9                   	leave  
  800e33:	c3                   	ret    

00800e34 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e3a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e41:	00 
  800e42:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e49:	00 
  800e4a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e51:	00 
  800e52:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e59:	00 
  800e5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e61:	00 
  800e62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e69:	00 
  800e6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e71:	e8 1b ff ff ff       	call   800d91 <syscall>
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e88:	00 
  800e89:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e90:	00 
  800e91:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e98:	00 
  800e99:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea0:	00 
  800ea1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800eb4:	e8 d8 fe ff ff       	call   800d91 <syscall>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ec1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ef8:	e8 94 fe ff ff       	call   800d91 <syscall>
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <sys_yield>:

void
sys_yield(void)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f05:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f14:	00 
  800f15:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f3c:	e8 50 fe ff ff       	call   800d91 <syscall>
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f49:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f59:	00 
  800f5a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f61:	00 
  800f62:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f66:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f75:	00 
  800f76:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f7d:	e8 0f fe ff ff       	call   800d91 <syscall>
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f8c:	8b 75 18             	mov    0x18(%ebp),%esi
  800f8f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f92:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9b:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f9f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fa3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800faf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb6:	00 
  800fb7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fbe:	e8 ce fd ff ff       	call   800d91 <syscall>
}
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fdd:	00 
  800fde:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe5:	00 
  800fe6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fed:	00 
  800fee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ffd:	00 
  800ffe:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801005:	e8 87 fd ff ff       	call   800d91 <syscall>
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801012:	8b 55 0c             	mov    0xc(%ebp),%edx
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80101f:	00 
  801020:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801027:	00 
  801028:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80102f:	00 
  801030:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801034:	89 44 24 08          	mov    %eax,0x8(%esp)
  801038:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80103f:	00 
  801040:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801047:	e8 45 fd ff ff       	call   800d91 <syscall>
}
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    

0080104e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801054:	8b 55 0c             	mov    0xc(%ebp),%edx
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801061:	00 
  801062:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801069:	00 
  80106a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801071:	00 
  801072:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801076:	89 44 24 08          	mov    %eax,0x8(%esp)
  80107a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801081:	00 
  801082:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801089:	e8 03 fd ff ff       	call   800d91 <syscall>
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801096:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801099:	8b 55 10             	mov    0x10(%ebp),%edx
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010a6:	00 
  8010a7:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010c1:	00 
  8010c2:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010c9:	e8 c3 fc ff ff       	call   800d91 <syscall>
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010f8:	00 
  8010f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010fd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801104:	00 
  801105:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80110c:	e8 80 fc ff ff       	call   800d91 <syscall>
}
  801111:	c9                   	leave  
  801112:	c3                   	ret    

00801113 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	53                   	push   %ebx
  801117:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80111a:	8d 45 14             	lea    0x14(%ebp),%eax
  80111d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801120:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801126:	e8 90 fd ff ff       	call   800ebb <sys_getenvid>
  80112b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801132:	8b 55 08             	mov    0x8(%ebp),%edx
  801135:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80113d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801141:	c7 04 24 90 16 80 00 	movl   $0x801690,(%esp)
  801148:	e8 39 f0 ff ff       	call   800186 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	89 44 24 04          	mov    %eax,0x4(%esp)
  801154:	8b 45 10             	mov    0x10(%ebp),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	e8 c3 ef ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  80115f:	c7 04 24 b3 16 80 00 	movl   $0x8016b3,(%esp)
  801166:	e8 1b f0 ff ff       	call   800186 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80116b:	cc                   	int3   
  80116c:	eb fd                	jmp    80116b <_panic+0x58>
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__udivdi3>:
  801170:	55                   	push   %ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	8b 44 24 28          	mov    0x28(%esp),%eax
  80117a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80117e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801182:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801186:	85 c0                	test   %eax,%eax
  801188:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80118c:	89 ea                	mov    %ebp,%edx
  80118e:	89 0c 24             	mov    %ecx,(%esp)
  801191:	75 2d                	jne    8011c0 <__udivdi3+0x50>
  801193:	39 e9                	cmp    %ebp,%ecx
  801195:	77 61                	ja     8011f8 <__udivdi3+0x88>
  801197:	85 c9                	test   %ecx,%ecx
  801199:	89 ce                	mov    %ecx,%esi
  80119b:	75 0b                	jne    8011a8 <__udivdi3+0x38>
  80119d:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a2:	31 d2                	xor    %edx,%edx
  8011a4:	f7 f1                	div    %ecx
  8011a6:	89 c6                	mov    %eax,%esi
  8011a8:	31 d2                	xor    %edx,%edx
  8011aa:	89 e8                	mov    %ebp,%eax
  8011ac:	f7 f6                	div    %esi
  8011ae:	89 c5                	mov    %eax,%ebp
  8011b0:	89 f8                	mov    %edi,%eax
  8011b2:	f7 f6                	div    %esi
  8011b4:	89 ea                	mov    %ebp,%edx
  8011b6:	83 c4 0c             	add    $0xc,%esp
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    
  8011bd:	8d 76 00             	lea    0x0(%esi),%esi
  8011c0:	39 e8                	cmp    %ebp,%eax
  8011c2:	77 24                	ja     8011e8 <__udivdi3+0x78>
  8011c4:	0f bd e8             	bsr    %eax,%ebp
  8011c7:	83 f5 1f             	xor    $0x1f,%ebp
  8011ca:	75 3c                	jne    801208 <__udivdi3+0x98>
  8011cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011d0:	39 34 24             	cmp    %esi,(%esp)
  8011d3:	0f 86 9f 00 00 00    	jbe    801278 <__udivdi3+0x108>
  8011d9:	39 d0                	cmp    %edx,%eax
  8011db:	0f 82 97 00 00 00    	jb     801278 <__udivdi3+0x108>
  8011e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	31 d2                	xor    %edx,%edx
  8011ea:	31 c0                	xor    %eax,%eax
  8011ec:	83 c4 0c             	add    $0xc,%esp
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    
  8011f3:	90                   	nop
  8011f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	89 f8                	mov    %edi,%eax
  8011fa:	f7 f1                	div    %ecx
  8011fc:	31 d2                	xor    %edx,%edx
  8011fe:	83 c4 0c             	add    $0xc,%esp
  801201:	5e                   	pop    %esi
  801202:	5f                   	pop    %edi
  801203:	5d                   	pop    %ebp
  801204:	c3                   	ret    
  801205:	8d 76 00             	lea    0x0(%esi),%esi
  801208:	89 e9                	mov    %ebp,%ecx
  80120a:	8b 3c 24             	mov    (%esp),%edi
  80120d:	d3 e0                	shl    %cl,%eax
  80120f:	89 c6                	mov    %eax,%esi
  801211:	b8 20 00 00 00       	mov    $0x20,%eax
  801216:	29 e8                	sub    %ebp,%eax
  801218:	89 c1                	mov    %eax,%ecx
  80121a:	d3 ef                	shr    %cl,%edi
  80121c:	89 e9                	mov    %ebp,%ecx
  80121e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801222:	8b 3c 24             	mov    (%esp),%edi
  801225:	09 74 24 08          	or     %esi,0x8(%esp)
  801229:	89 d6                	mov    %edx,%esi
  80122b:	d3 e7                	shl    %cl,%edi
  80122d:	89 c1                	mov    %eax,%ecx
  80122f:	89 3c 24             	mov    %edi,(%esp)
  801232:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801236:	d3 ee                	shr    %cl,%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	d3 e2                	shl    %cl,%edx
  80123c:	89 c1                	mov    %eax,%ecx
  80123e:	d3 ef                	shr    %cl,%edi
  801240:	09 d7                	or     %edx,%edi
  801242:	89 f2                	mov    %esi,%edx
  801244:	89 f8                	mov    %edi,%eax
  801246:	f7 74 24 08          	divl   0x8(%esp)
  80124a:	89 d6                	mov    %edx,%esi
  80124c:	89 c7                	mov    %eax,%edi
  80124e:	f7 24 24             	mull   (%esp)
  801251:	39 d6                	cmp    %edx,%esi
  801253:	89 14 24             	mov    %edx,(%esp)
  801256:	72 30                	jb     801288 <__udivdi3+0x118>
  801258:	8b 54 24 04          	mov    0x4(%esp),%edx
  80125c:	89 e9                	mov    %ebp,%ecx
  80125e:	d3 e2                	shl    %cl,%edx
  801260:	39 c2                	cmp    %eax,%edx
  801262:	73 05                	jae    801269 <__udivdi3+0xf9>
  801264:	3b 34 24             	cmp    (%esp),%esi
  801267:	74 1f                	je     801288 <__udivdi3+0x118>
  801269:	89 f8                	mov    %edi,%eax
  80126b:	31 d2                	xor    %edx,%edx
  80126d:	e9 7a ff ff ff       	jmp    8011ec <__udivdi3+0x7c>
  801272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801278:	31 d2                	xor    %edx,%edx
  80127a:	b8 01 00 00 00       	mov    $0x1,%eax
  80127f:	e9 68 ff ff ff       	jmp    8011ec <__udivdi3+0x7c>
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	8d 47 ff             	lea    -0x1(%edi),%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	83 c4 0c             	add    $0xc,%esp
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    
  801294:	66 90                	xchg   %ax,%ax
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__umoddi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	83 ec 14             	sub    $0x14,%esp
  8012a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012b2:	89 c7                	mov    %eax,%edi
  8012b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012c0:	89 34 24             	mov    %esi,(%esp)
  8012c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c7:	85 c0                	test   %eax,%eax
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012cf:	75 17                	jne    8012e8 <__umoddi3+0x48>
  8012d1:	39 fe                	cmp    %edi,%esi
  8012d3:	76 4b                	jbe    801320 <__umoddi3+0x80>
  8012d5:	89 c8                	mov    %ecx,%eax
  8012d7:	89 fa                	mov    %edi,%edx
  8012d9:	f7 f6                	div    %esi
  8012db:	89 d0                	mov    %edx,%eax
  8012dd:	31 d2                	xor    %edx,%edx
  8012df:	83 c4 14             	add    $0x14,%esp
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	39 f8                	cmp    %edi,%eax
  8012ea:	77 54                	ja     801340 <__umoddi3+0xa0>
  8012ec:	0f bd e8             	bsr    %eax,%ebp
  8012ef:	83 f5 1f             	xor    $0x1f,%ebp
  8012f2:	75 5c                	jne    801350 <__umoddi3+0xb0>
  8012f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012f8:	39 3c 24             	cmp    %edi,(%esp)
  8012fb:	0f 87 e7 00 00 00    	ja     8013e8 <__umoddi3+0x148>
  801301:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801305:	29 f1                	sub    %esi,%ecx
  801307:	19 c7                	sbb    %eax,%edi
  801309:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80130d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801311:	8b 44 24 08          	mov    0x8(%esp),%eax
  801315:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801319:	83 c4 14             	add    $0x14,%esp
  80131c:	5e                   	pop    %esi
  80131d:	5f                   	pop    %edi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    
  801320:	85 f6                	test   %esi,%esi
  801322:	89 f5                	mov    %esi,%ebp
  801324:	75 0b                	jne    801331 <__umoddi3+0x91>
  801326:	b8 01 00 00 00       	mov    $0x1,%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	f7 f6                	div    %esi
  80132f:	89 c5                	mov    %eax,%ebp
  801331:	8b 44 24 04          	mov    0x4(%esp),%eax
  801335:	31 d2                	xor    %edx,%edx
  801337:	f7 f5                	div    %ebp
  801339:	89 c8                	mov    %ecx,%eax
  80133b:	f7 f5                	div    %ebp
  80133d:	eb 9c                	jmp    8012db <__umoddi3+0x3b>
  80133f:	90                   	nop
  801340:	89 c8                	mov    %ecx,%eax
  801342:	89 fa                	mov    %edi,%edx
  801344:	83 c4 14             	add    $0x14,%esp
  801347:	5e                   	pop    %esi
  801348:	5f                   	pop    %edi
  801349:	5d                   	pop    %ebp
  80134a:	c3                   	ret    
  80134b:	90                   	nop
  80134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801350:	8b 04 24             	mov    (%esp),%eax
  801353:	be 20 00 00 00       	mov    $0x20,%esi
  801358:	89 e9                	mov    %ebp,%ecx
  80135a:	29 ee                	sub    %ebp,%esi
  80135c:	d3 e2                	shl    %cl,%edx
  80135e:	89 f1                	mov    %esi,%ecx
  801360:	d3 e8                	shr    %cl,%eax
  801362:	89 e9                	mov    %ebp,%ecx
  801364:	89 44 24 04          	mov    %eax,0x4(%esp)
  801368:	8b 04 24             	mov    (%esp),%eax
  80136b:	09 54 24 04          	or     %edx,0x4(%esp)
  80136f:	89 fa                	mov    %edi,%edx
  801371:	d3 e0                	shl    %cl,%eax
  801373:	89 f1                	mov    %esi,%ecx
  801375:	89 44 24 08          	mov    %eax,0x8(%esp)
  801379:	8b 44 24 10          	mov    0x10(%esp),%eax
  80137d:	d3 ea                	shr    %cl,%edx
  80137f:	89 e9                	mov    %ebp,%ecx
  801381:	d3 e7                	shl    %cl,%edi
  801383:	89 f1                	mov    %esi,%ecx
  801385:	d3 e8                	shr    %cl,%eax
  801387:	89 e9                	mov    %ebp,%ecx
  801389:	09 f8                	or     %edi,%eax
  80138b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80138f:	f7 74 24 04          	divl   0x4(%esp)
  801393:	d3 e7                	shl    %cl,%edi
  801395:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801399:	89 d7                	mov    %edx,%edi
  80139b:	f7 64 24 08          	mull   0x8(%esp)
  80139f:	39 d7                	cmp    %edx,%edi
  8013a1:	89 c1                	mov    %eax,%ecx
  8013a3:	89 14 24             	mov    %edx,(%esp)
  8013a6:	72 2c                	jb     8013d4 <__umoddi3+0x134>
  8013a8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013ac:	72 22                	jb     8013d0 <__umoddi3+0x130>
  8013ae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013b2:	29 c8                	sub    %ecx,%eax
  8013b4:	19 d7                	sbb    %edx,%edi
  8013b6:	89 e9                	mov    %ebp,%ecx
  8013b8:	89 fa                	mov    %edi,%edx
  8013ba:	d3 e8                	shr    %cl,%eax
  8013bc:	89 f1                	mov    %esi,%ecx
  8013be:	d3 e2                	shl    %cl,%edx
  8013c0:	89 e9                	mov    %ebp,%ecx
  8013c2:	d3 ef                	shr    %cl,%edi
  8013c4:	09 d0                	or     %edx,%eax
  8013c6:	89 fa                	mov    %edi,%edx
  8013c8:	83 c4 14             	add    $0x14,%esp
  8013cb:	5e                   	pop    %esi
  8013cc:	5f                   	pop    %edi
  8013cd:	5d                   	pop    %ebp
  8013ce:	c3                   	ret    
  8013cf:	90                   	nop
  8013d0:	39 d7                	cmp    %edx,%edi
  8013d2:	75 da                	jne    8013ae <__umoddi3+0x10e>
  8013d4:	8b 14 24             	mov    (%esp),%edx
  8013d7:	89 c1                	mov    %eax,%ecx
  8013d9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8013dd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8013e1:	eb cb                	jmp    8013ae <__umoddi3+0x10e>
  8013e3:	90                   	nop
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8013ec:	0f 82 0f ff ff ff    	jb     801301 <__umoddi3+0x61>
  8013f2:	e9 1a ff ff ff       	jmp    801311 <__umoddi3+0x71>
