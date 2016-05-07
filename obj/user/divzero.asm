
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
  800055:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  80005c:	e8 15 01 00 00       	call   800176 <cprintf>
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
  800069:	e8 3d 0e 00 00       	call   800eab <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	c1 e0 02             	shl    $0x2,%eax
  800076:	89 c2                	mov    %eax,%edx
  800078:	c1 e2 05             	shl    $0x5,%edx
  80007b:	29 c2                	sub    %eax,%edx
  80007d:	89 d0                	mov    %edx,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800089:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800090:	8b 45 08             	mov    0x8(%ebp),%eax
  800093:	89 04 24             	mov    %eax,(%esp)
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 02 00 00 00       	call   8000a2 <exit>
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000af:	e8 b4 0d 00 00       	call   800e68 <sys_env_destroy>
}
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000bf:	8b 00                	mov    (%eax),%eax
  8000c1:	8d 48 01             	lea    0x1(%eax),%ecx
  8000c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000c7:	89 0a                	mov    %ecx,(%edx)
  8000c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d1:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d8:	8b 00                	mov    (%eax),%eax
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 20                	jne    800101 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	8b 00                	mov    (%eax),%eax
  8000e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000e9:	83 c2 08             	add    $0x8,%edx
  8000ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f0:	89 14 24             	mov    %edx,(%esp)
  8000f3:	e8 ea 0c 00 00       	call   800de2 <sys_cputs>
		b->idx = 0;
  8000f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800101:	8b 45 0c             	mov    0xc(%ebp),%eax
  800104:	8b 40 04             	mov    0x4(%eax),%eax
  800107:	8d 50 01             	lea    0x1(%eax),%edx
  80010a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800110:	c9                   	leave  
  800111:	c3                   	ret    

00800112 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800122:	00 00 00 
	b.cnt = 0;
  800125:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	8b 45 08             	mov    0x8(%ebp),%eax
  800139:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	89 44 24 04          	mov    %eax,0x4(%esp)
  800147:	c7 04 24 b6 00 80 00 	movl   $0x8000b6,(%esp)
  80014e:	e8 bd 01 00 00       	call   800310 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800153:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800159:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800163:	83 c0 08             	add    $0x8,%eax
  800166:	89 04 24             	mov    %eax,(%esp)
  800169:	e8 74 0c 00 00       	call   800de2 <sys_cputs>

	return b.cnt;
  80016e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017c:	8d 45 0c             	lea    0xc(%ebp),%eax
  80017f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800185:	89 44 24 04          	mov    %eax,0x4(%esp)
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 7e ff ff ff       	call   800112 <vcprintf>
  800194:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800197:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	53                   	push   %ebx
  8001a0:	83 ec 34             	sub    $0x34,%esp
  8001a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001af:	8b 45 18             	mov    0x18(%ebp),%eax
  8001b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ba:	77 72                	ja     80022e <printnum+0x92>
  8001bc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001bf:	72 05                	jb     8001c6 <printnum+0x2a>
  8001c1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001c4:	77 68                	ja     80022e <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001c9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001cc:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e9:	e8 02 10 00 00       	call   8011f0 <__udivdi3>
  8001ee:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001f1:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8001f5:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8001f9:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	e8 82 ff ff ff       	call   80019c <printnum>
  80021a:	eb 1c                	jmp    800238 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	8b 45 20             	mov    0x20(%ebp),%eax
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800232:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800236:	7f e4                	jg     80021c <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800238:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80023b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800243:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800246:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	89 54 24 04          	mov    %edx,0x4(%esp)
  800255:	e8 c6 10 00 00       	call   801320 <__umoddi3>
  80025a:	05 68 15 80 00       	add    $0x801568,%eax
  80025f:	0f b6 00             	movzbl (%eax),%eax
  800262:	0f be c0             	movsbl %al,%eax
  800265:	8b 55 0c             	mov    0xc(%ebp),%edx
  800268:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	ff d0                	call   *%eax
}
  800274:	83 c4 34             	add    $0x34,%esp
  800277:	5b                   	pop    %ebx
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800281:	7e 14                	jle    800297 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	8b 00                	mov    (%eax),%eax
  800288:	8d 48 08             	lea    0x8(%eax),%ecx
  80028b:	8b 55 08             	mov    0x8(%ebp),%edx
  80028e:	89 0a                	mov    %ecx,(%edx)
  800290:	8b 50 04             	mov    0x4(%eax),%edx
  800293:	8b 00                	mov    (%eax),%eax
  800295:	eb 30                	jmp    8002c7 <getuint+0x4d>
	else if (lflag)
  800297:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80029b:	74 16                	je     8002b3 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	8b 00                	mov    (%eax),%eax
  8002a2:	8d 48 04             	lea    0x4(%eax),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 0a                	mov    %ecx,(%edx)
  8002aa:	8b 00                	mov    (%eax),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	eb 14                	jmp    8002c7 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	8b 00                	mov    (%eax),%eax
  8002b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 0a                	mov    %ecx,(%edx)
  8002c0:	8b 00                	mov    (%eax),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002d0:	7e 14                	jle    8002e6 <getint+0x1d>
		return va_arg(*ap, long long);
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 00                	mov    (%eax),%eax
  8002d7:	8d 48 08             	lea    0x8(%eax),%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	89 0a                	mov    %ecx,(%edx)
  8002df:	8b 50 04             	mov    0x4(%eax),%edx
  8002e2:	8b 00                	mov    (%eax),%eax
  8002e4:	eb 28                	jmp    80030e <getint+0x45>
	else if (lflag)
  8002e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002ea:	74 12                	je     8002fe <getint+0x35>
		return va_arg(*ap, long);
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	8b 00                	mov    (%eax),%eax
  8002f1:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 0a                	mov    %ecx,(%edx)
  8002f9:	8b 00                	mov    (%eax),%eax
  8002fb:	99                   	cltd   
  8002fc:	eb 10                	jmp    80030e <getint+0x45>
	else
		return va_arg(*ap, int);
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	8b 00                	mov    (%eax),%eax
  800303:	8d 48 04             	lea    0x4(%eax),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 0a                	mov    %ecx,(%edx)
  80030b:	8b 00                	mov    (%eax),%eax
  80030d:	99                   	cltd   
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800318:	eb 18                	jmp    800332 <vprintfmt+0x22>
			if (ch == '\0')
  80031a:	85 db                	test   %ebx,%ebx
  80031c:	75 05                	jne    800323 <vprintfmt+0x13>
				return;
  80031e:	e9 cc 03 00 00       	jmp    8006ef <vprintfmt+0x3df>
			putch(ch, putdat);
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
  800326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032a:	89 1c 24             	mov    %ebx,(%esp)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	8b 45 10             	mov    0x10(%ebp),%eax
  800335:	8d 50 01             	lea    0x1(%eax),%edx
  800338:	89 55 10             	mov    %edx,0x10(%ebp)
  80033b:	0f b6 00             	movzbl (%eax),%eax
  80033e:	0f b6 d8             	movzbl %al,%ebx
  800341:	83 fb 25             	cmp    $0x25,%ebx
  800344:	75 d4                	jne    80031a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800346:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80034a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800351:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800358:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80035f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 45 10             	mov    0x10(%ebp),%eax
  800369:	8d 50 01             	lea    0x1(%eax),%edx
  80036c:	89 55 10             	mov    %edx,0x10(%ebp)
  80036f:	0f b6 00             	movzbl (%eax),%eax
  800372:	0f b6 d8             	movzbl %al,%ebx
  800375:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800378:	83 f8 55             	cmp    $0x55,%eax
  80037b:	0f 87 3d 03 00 00    	ja     8006be <vprintfmt+0x3ae>
  800381:	8b 04 85 8c 15 80 00 	mov    0x80158c(,%eax,4),%eax
  800388:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80038a:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80038e:	eb d6                	jmp    800366 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800390:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800394:	eb d0                	jmp    800366 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800396:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80039d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a0:	89 d0                	mov    %edx,%eax
  8003a2:	c1 e0 02             	shl    $0x2,%eax
  8003a5:	01 d0                	add    %edx,%eax
  8003a7:	01 c0                	add    %eax,%eax
  8003a9:	01 d8                	add    %ebx,%eax
  8003ab:	83 e8 30             	sub    $0x30,%eax
  8003ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b4:	0f b6 00             	movzbl (%eax),%eax
  8003b7:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003ba:	83 fb 2f             	cmp    $0x2f,%ebx
  8003bd:	7e 0b                	jle    8003ca <vprintfmt+0xba>
  8003bf:	83 fb 39             	cmp    $0x39,%ebx
  8003c2:	7f 06                	jg     8003ca <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c8:	eb d3                	jmp    80039d <vprintfmt+0x8d>
			goto process_precision;
  8003ca:	eb 33                	jmp    8003ff <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003da:	eb 23                	jmp    8003ff <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e0:	79 0c                	jns    8003ee <vprintfmt+0xde>
				width = 0;
  8003e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003e9:	e9 78 ff ff ff       	jmp    800366 <vprintfmt+0x56>
  8003ee:	e9 73 ff ff ff       	jmp    800366 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003f3:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003fa:	e9 67 ff ff ff       	jmp    800366 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8003ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800403:	79 12                	jns    800417 <vprintfmt+0x107>
				width = precision, precision = -1;
  800405:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800412:	e9 4f ff ff ff       	jmp    800366 <vprintfmt+0x56>
  800417:	e9 4a ff ff ff       	jmp    800366 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800420:	e9 41 ff ff ff       	jmp    800366 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 54 24 04          	mov    %edx,0x4(%esp)
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	ff d0                	call   *%eax
			break;
  80043f:	e9 a5 02 00 00       	jmp    8006e9 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80044f:	85 db                	test   %ebx,%ebx
  800451:	79 02                	jns    800455 <vprintfmt+0x145>
				err = -err;
  800453:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800455:	83 fb 09             	cmp    $0x9,%ebx
  800458:	7f 0b                	jg     800465 <vprintfmt+0x155>
  80045a:	8b 34 9d 40 15 80 00 	mov    0x801540(,%ebx,4),%esi
  800461:	85 f6                	test   %esi,%esi
  800463:	75 23                	jne    800488 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800465:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800469:	c7 44 24 08 79 15 80 	movl   $0x801579,0x8(%esp)
  800470:	00 
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	8b 45 08             	mov    0x8(%ebp),%eax
  80047b:	89 04 24             	mov    %eax,(%esp)
  80047e:	e8 73 02 00 00       	call   8006f6 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800483:	e9 61 02 00 00       	jmp    8006e9 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800488:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80048c:	c7 44 24 08 82 15 80 	movl   $0x801582,0x8(%esp)
  800493:	00 
  800494:	8b 45 0c             	mov    0xc(%ebp),%eax
  800497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049b:	8b 45 08             	mov    0x8(%ebp),%eax
  80049e:	89 04 24             	mov    %eax,(%esp)
  8004a1:	e8 50 02 00 00       	call   8006f6 <printfmt>
			break;
  8004a6:	e9 3e 02 00 00       	jmp    8006e9 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 50 04             	lea    0x4(%eax),%edx
  8004b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b4:	8b 30                	mov    (%eax),%esi
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	75 05                	jne    8004bf <vprintfmt+0x1af>
				p = "(null)";
  8004ba:	be 85 15 80 00       	mov    $0x801585,%esi
			if (width > 0 && padc != '-')
  8004bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c3:	7e 37                	jle    8004fc <vprintfmt+0x1ec>
  8004c5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004c9:	74 31                	je     8004fc <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d2:	89 34 24             	mov    %esi,(%esp)
  8004d5:	e8 39 03 00 00       	call   800813 <strnlen>
  8004da:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004dd:	eb 17                	jmp    8004f6 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004df:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fa:	7f e3                	jg     8004df <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fc:	eb 38                	jmp    800536 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800502:	74 1f                	je     800523 <vprintfmt+0x213>
  800504:	83 fb 1f             	cmp    $0x1f,%ebx
  800507:	7e 05                	jle    80050e <vprintfmt+0x1fe>
  800509:	83 fb 7e             	cmp    $0x7e,%ebx
  80050c:	7e 15                	jle    800523 <vprintfmt+0x213>
					putch('?', putdat);
  80050e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800511:	89 44 24 04          	mov    %eax,0x4(%esp)
  800515:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051c:	8b 45 08             	mov    0x8(%ebp),%eax
  80051f:	ff d0                	call   *%eax
  800521:	eb 0f                	jmp    800532 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800523:	8b 45 0c             	mov    0xc(%ebp),%eax
  800526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052a:	89 1c 24             	mov    %ebx,(%esp)
  80052d:	8b 45 08             	mov    0x8(%ebp),%eax
  800530:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800536:	89 f0                	mov    %esi,%eax
  800538:	8d 70 01             	lea    0x1(%eax),%esi
  80053b:	0f b6 00             	movzbl (%eax),%eax
  80053e:	0f be d8             	movsbl %al,%ebx
  800541:	85 db                	test   %ebx,%ebx
  800543:	74 10                	je     800555 <vprintfmt+0x245>
  800545:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800549:	78 b3                	js     8004fe <vprintfmt+0x1ee>
  80054b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80054f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800553:	79 a9                	jns    8004fe <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800555:	eb 17                	jmp    80056e <vprintfmt+0x25e>
				putch(' ', putdat);
  800557:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800565:	8b 45 08             	mov    0x8(%ebp),%eax
  800568:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80056e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800572:	7f e3                	jg     800557 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800574:	e9 70 01 00 00       	jmp    8006e9 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800579:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80057c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800580:	8d 45 14             	lea    0x14(%ebp),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	e8 3e fd ff ff       	call   8002c9 <getint>
  80058b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80058e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800594:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	79 26                	jns    8005c1 <vprintfmt+0x2b1>
				putch('-', putdat);
  80059b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ac:	ff d0                	call   *%eax
				num = -(long long) num;
  8005ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005b4:	f7 d8                	neg    %eax
  8005b6:	83 d2 00             	adc    $0x0,%edx
  8005b9:	f7 da                	neg    %edx
  8005bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005be:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005c1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005c8:	e9 a8 00 00 00       	jmp    800675 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	e8 9b fc ff ff       	call   80027a <getuint>
  8005df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005e5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005ec:	e9 84 00 00 00       	jmp    800675 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	e8 77 fc ff ff       	call   80027a <getuint>
  800603:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800606:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800609:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800610:	eb 63                	jmp    800675 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800612:	8b 45 0c             	mov    0xc(%ebp),%eax
  800615:	89 44 24 04          	mov    %eax,0x4(%esp)
  800619:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800620:	8b 45 08             	mov    0x8(%ebp),%eax
  800623:	ff d0                	call   *%eax
			putch('x', putdat);
  800625:	8b 45 0c             	mov    0xc(%ebp),%eax
  800628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800654:	eb 1f                	jmp    800675 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800656:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	8d 45 14             	lea    0x14(%ebp),%eax
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	e8 12 fc ff ff       	call   80027a <getuint>
  800668:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80066b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80066e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800675:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800679:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067c:	89 54 24 18          	mov    %edx,0x18(%esp)
  800680:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800683:	89 54 24 14          	mov    %edx,0x14(%esp)
  800687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800691:	89 44 24 08          	mov    %eax,0x8(%esp)
  800695:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	e8 f1 fa ff ff       	call   80019c <printnum>
			break;
  8006ab:	eb 3c                	jmp    8006e9 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b4:	89 1c 24             	mov    %ebx,(%esp)
  8006b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ba:	ff d0                	call   *%eax
			break;
  8006bc:	eb 2b                	jmp    8006e9 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006d5:	eb 04                	jmp    8006db <vprintfmt+0x3cb>
  8006d7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006db:	8b 45 10             	mov    0x10(%ebp),%eax
  8006de:	83 e8 01             	sub    $0x1,%eax
  8006e1:	0f b6 00             	movzbl (%eax),%eax
  8006e4:	3c 25                	cmp    $0x25,%al
  8006e6:	75 ef                	jne    8006d7 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8006e8:	90                   	nop
		}
	}
  8006e9:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ea:	e9 43 fc ff ff       	jmp    800332 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	83 c4 40             	add    $0x40,%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800709:	8b 45 10             	mov    0x10(%ebp),%eax
  80070c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800710:	8b 45 0c             	mov    0xc(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	89 04 24             	mov    %eax,(%esp)
  80071d:	e8 ee fb ff ff       	call   800310 <vprintfmt>
	va_end(ap);
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800727:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072a:	8b 40 08             	mov    0x8(%eax),%eax
  80072d:	8d 50 01             	lea    0x1(%eax),%edx
  800730:	8b 45 0c             	mov    0xc(%ebp),%eax
  800733:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800736:	8b 45 0c             	mov    0xc(%ebp),%eax
  800739:	8b 10                	mov    (%eax),%edx
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	8b 40 04             	mov    0x4(%eax),%eax
  800741:	39 c2                	cmp    %eax,%edx
  800743:	73 12                	jae    800757 <sprintputch+0x33>
		*b->buf++ = ch;
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	8d 48 01             	lea    0x1(%eax),%ecx
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800750:	89 0a                	mov    %ecx,(%edx)
  800752:	8b 55 08             	mov    0x8(%ebp),%edx
  800755:	88 10                	mov    %dl,(%eax)
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
  800768:	8d 50 ff             	lea    -0x1(%eax),%edx
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	01 d0                	add    %edx,%eax
  800770:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80077e:	74 06                	je     800786 <vsnprintf+0x2d>
  800780:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800784:	7f 07                	jg     80078d <vsnprintf+0x34>
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078b:	eb 2a                	jmp    8007b7 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800794:	8b 45 10             	mov    0x10(%ebp),%eax
  800797:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a2:	c7 04 24 24 07 80 00 	movl   $0x800724,(%esp)
  8007a9:	e8 62 fb ff ff       	call   800310 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	89 04 24             	mov    %eax,(%esp)
  8007e0:	e8 74 ff ff ff       	call   800759 <vsnprintf>
  8007e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    

008007ed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007fa:	eb 08                	jmp    800804 <strlen+0x17>
		n++;
  8007fc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800800:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	0f b6 00             	movzbl (%eax),%eax
  80080a:	84 c0                	test   %al,%al
  80080c:	75 ee                	jne    8007fc <strlen+0xf>
		n++;
	return n;
  80080e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800819:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800820:	eb 0c                	jmp    80082e <strnlen+0x1b>
		n++;
  800822:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80082a:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80082e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800832:	74 0a                	je     80083e <strnlen+0x2b>
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	0f b6 00             	movzbl (%eax),%eax
  80083a:	84 c0                	test   %al,%al
  80083c:	75 e4                	jne    800822 <strnlen+0xf>
		n++;
	return n;
  80083e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80084f:	90                   	nop
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8d 50 01             	lea    0x1(%eax),%edx
  800856:	89 55 08             	mov    %edx,0x8(%ebp)
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80085f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800862:	0f b6 12             	movzbl (%edx),%edx
  800865:	88 10                	mov    %dl,(%eax)
  800867:	0f b6 00             	movzbl (%eax),%eax
  80086a:	84 c0                	test   %al,%al
  80086c:	75 e2                	jne    800850 <strcpy+0xd>
		/* do nothing */;
	return ret;
  80086e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	e8 69 ff ff ff       	call   8007ed <strlen>
  800884:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800887:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	01 c2                	add    %eax,%edx
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800892:	89 44 24 04          	mov    %eax,0x4(%esp)
  800896:	89 14 24             	mov    %edx,(%esp)
  800899:	e8 a5 ff ff ff       	call   800843 <strcpy>
	return dst;
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    

008008a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008af:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008b6:	eb 23                	jmp    8008db <strncpy+0x38>
		*dst++ = *src;
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8d 50 01             	lea    0x1(%eax),%edx
  8008be:	89 55 08             	mov    %edx,0x8(%ebp)
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cc:	0f b6 00             	movzbl (%eax),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strncpy+0x34>
			src++;
  8008d3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8008db:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008de:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008e1:	72 d5                	jb     8008b8 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8008f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008f8:	74 33                	je     80092d <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008fa:	eb 17                	jmp    800913 <strlcpy+0x2b>
			*dst++ = *src++;
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	8d 50 01             	lea    0x1(%eax),%edx
  800902:	89 55 08             	mov    %edx,0x8(%ebp)
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	8d 4a 01             	lea    0x1(%edx),%ecx
  80090b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80090e:	0f b6 12             	movzbl (%edx),%edx
  800911:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800913:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800917:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80091b:	74 0a                	je     800927 <strlcpy+0x3f>
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	84 c0                	test   %al,%al
  800925:	75 d5                	jne    8008fc <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092d:	8b 55 08             	mov    0x8(%ebp),%edx
  800930:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800933:	29 c2                	sub    %eax,%edx
  800935:	89 d0                	mov    %edx,%eax
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    

00800939 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80093c:	eb 08                	jmp    800946 <strcmp+0xd>
		p++, q++;
  80093e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800942:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 00             	movzbl (%eax),%eax
  80094c:	84 c0                	test   %al,%al
  80094e:	74 10                	je     800960 <strcmp+0x27>
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	0f b6 10             	movzbl (%eax),%edx
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	0f b6 00             	movzbl (%eax),%eax
  80095c:	38 c2                	cmp    %al,%dl
  80095e:	74 de                	je     80093e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 00             	movzbl (%eax),%eax
  800966:	0f b6 d0             	movzbl %al,%edx
  800969:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	0f b6 c0             	movzbl %al,%eax
  800972:	29 c2                	sub    %eax,%edx
  800974:	89 d0                	mov    %edx,%eax
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  80097b:	eb 0c                	jmp    800989 <strncmp+0x11>
		n--, p++, q++;
  80097d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800981:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800985:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80098d:	74 1a                	je     8009a9 <strncmp+0x31>
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	0f b6 00             	movzbl (%eax),%eax
  800995:	84 c0                	test   %al,%al
  800997:	74 10                	je     8009a9 <strncmp+0x31>
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	0f b6 10             	movzbl (%eax),%edx
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	38 c2                	cmp    %al,%dl
  8009a7:	74 d4                	je     80097d <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ad:	75 07                	jne    8009b6 <strncmp+0x3e>
		return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	eb 16                	jmp    8009cc <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 00             	movzbl (%eax),%eax
  8009bc:	0f b6 d0             	movzbl %al,%edx
  8009bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c2:	0f b6 00             	movzbl (%eax),%eax
  8009c5:	0f b6 c0             	movzbl %al,%eax
  8009c8:	29 c2                	sub    %eax,%edx
  8009ca:	89 d0                	mov    %edx,%eax
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009da:	eb 14                	jmp    8009f0 <strchr+0x22>
		if (*s == c)
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	0f b6 00             	movzbl (%eax),%eax
  8009e2:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009e5:	75 05                	jne    8009ec <strchr+0x1e>
			return (char *) s;
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	eb 13                	jmp    8009ff <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	0f b6 00             	movzbl (%eax),%eax
  8009f6:	84 c0                	test   %al,%al
  8009f8:	75 e2                	jne    8009dc <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	83 ec 04             	sub    $0x4,%esp
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a0d:	eb 11                	jmp    800a20 <strfind+0x1f>
		if (*s == c)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	0f b6 00             	movzbl (%eax),%eax
  800a15:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a18:	75 02                	jne    800a1c <strfind+0x1b>
			break;
  800a1a:	eb 0e                	jmp    800a2a <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	0f b6 00             	movzbl (%eax),%eax
  800a26:	84 c0                	test   %al,%al
  800a28:	75 e5                	jne    800a0f <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a37:	75 05                	jne    800a3e <memset+0xf>
		return v;
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	eb 5c                	jmp    800a9a <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	83 e0 03             	and    $0x3,%eax
  800a44:	85 c0                	test   %eax,%eax
  800a46:	75 41                	jne    800a89 <memset+0x5a>
  800a48:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4b:	83 e0 03             	and    $0x3,%eax
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	75 37                	jne    800a89 <memset+0x5a>
		c &= 0xFF;
  800a52:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	c1 e0 18             	shl    $0x18,%eax
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	c1 e0 10             	shl    $0x10,%eax
  800a67:	09 c2                	or     %eax,%edx
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	c1 e0 08             	shl    $0x8,%eax
  800a6f:	09 d0                	or     %edx,%eax
  800a71:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a74:	8b 45 10             	mov    0x10(%ebp),%eax
  800a77:	c1 e8 02             	shr    $0x2,%eax
  800a7a:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a82:	89 d7                	mov    %edx,%edi
  800a84:	fc                   	cld    
  800a85:	f3 ab                	rep stos %eax,%es:(%edi)
  800a87:	eb 0e                	jmp    800a97 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a89:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a92:	89 d7                	mov    %edx,%edi
  800a94:	fc                   	cld    
  800a95:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ab8:	73 6d                	jae    800b27 <memmove+0x8a>
  800aba:	8b 45 10             	mov    0x10(%ebp),%eax
  800abd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ac0:	01 d0                	add    %edx,%eax
  800ac2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ac5:	76 60                	jbe    800b27 <memmove+0x8a>
		s += n;
  800ac7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aca:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800acd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad0:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad6:	83 e0 03             	and    $0x3,%eax
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	75 2f                	jne    800b0c <memmove+0x6f>
  800add:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae0:	83 e0 03             	and    $0x3,%eax
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	75 25                	jne    800b0c <memmove+0x6f>
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	83 e0 03             	and    $0x3,%eax
  800aed:	85 c0                	test   %eax,%eax
  800aef:	75 1b                	jne    800b0c <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af4:	83 e8 04             	sub    $0x4,%eax
  800af7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800afa:	83 ea 04             	sub    $0x4,%edx
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	fd                   	std    
  800b08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0a:	eb 18                	jmp    800b24 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b15:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b18:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1b:	89 d7                	mov    %edx,%edi
  800b1d:	89 de                	mov    %ebx,%esi
  800b1f:	89 c1                	mov    %eax,%ecx
  800b21:	fd                   	std    
  800b22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b24:	fc                   	cld    
  800b25:	eb 45                	jmp    800b6c <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b2a:	83 e0 03             	and    $0x3,%eax
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	75 2b                	jne    800b5c <memmove+0xbf>
  800b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b34:	83 e0 03             	and    $0x3,%eax
  800b37:	85 c0                	test   %eax,%eax
  800b39:	75 21                	jne    800b5c <memmove+0xbf>
  800b3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3e:	83 e0 03             	and    $0x3,%eax
  800b41:	85 c0                	test   %eax,%eax
  800b43:	75 17                	jne    800b5c <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b45:	8b 45 10             	mov    0x10(%ebp),%eax
  800b48:	c1 e8 02             	shr    $0x2,%eax
  800b4b:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	fc                   	cld    
  800b58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5a:	eb 10                	jmp    800b6c <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b62:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	fc                   	cld    
  800b6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b6f:	83 c4 10             	add    $0x10,%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	89 04 24             	mov    %eax,(%esp)
  800b91:	e8 07 ff ff ff       	call   800a9d <memmove>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800baa:	eb 30                	jmp    800bdc <memcmp+0x44>
		if (*s1 != *s2)
  800bac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800baf:	0f b6 10             	movzbl (%eax),%edx
  800bb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bb5:	0f b6 00             	movzbl (%eax),%eax
  800bb8:	38 c2                	cmp    %al,%dl
  800bba:	74 18                	je     800bd4 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbf:	0f b6 00             	movzbl (%eax),%eax
  800bc2:	0f b6 d0             	movzbl %al,%edx
  800bc5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bc8:	0f b6 00             	movzbl (%eax),%eax
  800bcb:	0f b6 c0             	movzbl %al,%eax
  800bce:	29 c2                	sub    %eax,%edx
  800bd0:	89 d0                	mov    %edx,%eax
  800bd2:	eb 1a                	jmp    800bee <memcmp+0x56>
		s1++, s2++;
  800bd4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800bd8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdf:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be2:	89 55 10             	mov    %edx,0x10(%ebp)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	75 c3                	jne    800bac <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800bf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfc:	01 d0                	add    %edx,%eax
  800bfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c01:	eb 13                	jmp    800c16 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	0f b6 10             	movzbl (%eax),%edx
  800c09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0c:	38 c2                	cmp    %al,%dl
  800c0e:	75 02                	jne    800c12 <memfind+0x22>
			break;
  800c10:	eb 0c                	jmp    800c1e <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c12:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c1c:	72 e5                	jb     800c03 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c30:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c37:	eb 04                	jmp    800c3d <strtol+0x1a>
		s++;
  800c39:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	0f b6 00             	movzbl (%eax),%eax
  800c43:	3c 20                	cmp    $0x20,%al
  800c45:	74 f2                	je     800c39 <strtol+0x16>
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	0f b6 00             	movzbl (%eax),%eax
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	74 e8                	je     800c39 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	0f b6 00             	movzbl (%eax),%eax
  800c57:	3c 2b                	cmp    $0x2b,%al
  800c59:	75 06                	jne    800c61 <strtol+0x3e>
		s++;
  800c5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c5f:	eb 15                	jmp    800c76 <strtol+0x53>
	else if (*s == '-')
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	0f b6 00             	movzbl (%eax),%eax
  800c67:	3c 2d                	cmp    $0x2d,%al
  800c69:	75 0b                	jne    800c76 <strtol+0x53>
		s++, neg = 1;
  800c6b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c7a:	74 06                	je     800c82 <strtol+0x5f>
  800c7c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c80:	75 24                	jne    800ca6 <strtol+0x83>
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	0f b6 00             	movzbl (%eax),%eax
  800c88:	3c 30                	cmp    $0x30,%al
  800c8a:	75 1a                	jne    800ca6 <strtol+0x83>
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	83 c0 01             	add    $0x1,%eax
  800c92:	0f b6 00             	movzbl (%eax),%eax
  800c95:	3c 78                	cmp    $0x78,%al
  800c97:	75 0d                	jne    800ca6 <strtol+0x83>
		s += 2, base = 16;
  800c99:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800c9d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ca4:	eb 2a                	jmp    800cd0 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ca6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800caa:	75 17                	jne    800cc3 <strtol+0xa0>
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	0f b6 00             	movzbl (%eax),%eax
  800cb2:	3c 30                	cmp    $0x30,%al
  800cb4:	75 0d                	jne    800cc3 <strtol+0xa0>
		s++, base = 8;
  800cb6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cba:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cc1:	eb 0d                	jmp    800cd0 <strtol+0xad>
	else if (base == 0)
  800cc3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc7:	75 07                	jne    800cd0 <strtol+0xad>
		base = 10;
  800cc9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	0f b6 00             	movzbl (%eax),%eax
  800cd6:	3c 2f                	cmp    $0x2f,%al
  800cd8:	7e 1b                	jle    800cf5 <strtol+0xd2>
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	0f b6 00             	movzbl (%eax),%eax
  800ce0:	3c 39                	cmp    $0x39,%al
  800ce2:	7f 11                	jg     800cf5 <strtol+0xd2>
			dig = *s - '0';
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	0f b6 00             	movzbl (%eax),%eax
  800cea:	0f be c0             	movsbl %al,%eax
  800ced:	83 e8 30             	sub    $0x30,%eax
  800cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cf3:	eb 48                	jmp    800d3d <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	0f b6 00             	movzbl (%eax),%eax
  800cfb:	3c 60                	cmp    $0x60,%al
  800cfd:	7e 1b                	jle    800d1a <strtol+0xf7>
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	0f b6 00             	movzbl (%eax),%eax
  800d05:	3c 7a                	cmp    $0x7a,%al
  800d07:	7f 11                	jg     800d1a <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	0f b6 00             	movzbl (%eax),%eax
  800d0f:	0f be c0             	movsbl %al,%eax
  800d12:	83 e8 57             	sub    $0x57,%eax
  800d15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d18:	eb 23                	jmp    800d3d <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	0f b6 00             	movzbl (%eax),%eax
  800d20:	3c 40                	cmp    $0x40,%al
  800d22:	7e 3d                	jle    800d61 <strtol+0x13e>
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	0f b6 00             	movzbl (%eax),%eax
  800d2a:	3c 5a                	cmp    $0x5a,%al
  800d2c:	7f 33                	jg     800d61 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	0f b6 00             	movzbl (%eax),%eax
  800d34:	0f be c0             	movsbl %al,%eax
  800d37:	83 e8 37             	sub    $0x37,%eax
  800d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d40:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d43:	7c 02                	jl     800d47 <strtol+0x124>
			break;
  800d45:	eb 1a                	jmp    800d61 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d47:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d4e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d57:	01 d0                	add    %edx,%eax
  800d59:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d5c:	e9 6f ff ff ff       	jmp    800cd0 <strtol+0xad>

	if (endptr)
  800d61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d65:	74 08                	je     800d6f <strtol+0x14c>
		*endptr = (char *) s;
  800d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d6f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d73:	74 07                	je     800d7c <strtol+0x159>
  800d75:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d78:	f7 d8                	neg    %eax
  800d7a:	eb 03                	jmp    800d7f <strtol+0x15c>
  800d7c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    

00800d81 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	8b 55 10             	mov    0x10(%ebp),%edx
  800d90:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d93:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800d96:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800d99:	8b 75 20             	mov    0x20(%ebp),%esi
  800d9c:	cd 30                	int    $0x30
  800d9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da5:	74 30                	je     800dd7 <syscall+0x56>
  800da7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dab:	7e 2a                	jle    800dd7 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbb:	c7 44 24 08 e4 16 80 	movl   $0x8016e4,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 01 17 80 00 	movl   $0x801701,(%esp)
  800dd2:	e8 b3 03 00 00       	call   80118a <_panic>

	return ret;
  800dd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800dda:	83 c4 3c             	add    $0x3c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800df2:	00 
  800df3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e02:	00 
  800e03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e06:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e1d:	e8 5f ff ff ff       	call   800d81 <syscall>
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e2a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e31:	00 
  800e32:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e39:	00 
  800e3a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e41:	00 
  800e42:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e49:	00 
  800e4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e61:	e8 1b ff ff ff       	call   800d81 <syscall>
}
  800e66:	c9                   	leave  
  800e67:	c3                   	ret    

00800e68 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e78:	00 
  800e79:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e80:	00 
  800e81:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e88:	00 
  800e89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e90:	00 
  800e91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e95:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800e9c:	00 
  800e9d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ea4:	e8 d8 fe ff ff       	call   800d81 <syscall>
}
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800eb1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ee8:	e8 94 fe ff ff       	call   800d81 <syscall>
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <sys_yield>:

void
sys_yield(void)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ef5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800efc:	00 
  800efd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f04:	00 
  800f05:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f14:	00 
  800f15:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f2c:	e8 50 fe ff ff       	call   800d81 <syscall>
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f39:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f42:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f49:	00 
  800f4a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f51:	00 
  800f52:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f56:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f65:	00 
  800f66:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f6d:	e8 0f fe ff ff       	call   800d81 <syscall>
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800f7f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f82:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f8f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800f93:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f97:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fae:	e8 ce fd ff ff       	call   800d81 <syscall>
}
  800fb3:	83 c4 20             	add    $0x20,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fcd:	00 
  800fce:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fdd:	00 
  800fde:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fed:	00 
  800fee:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800ff5:	e8 87 fd ff ff       	call   800d81 <syscall>
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801002:	8b 55 0c             	mov    0xc(%ebp),%edx
  801005:	8b 45 08             	mov    0x8(%ebp),%eax
  801008:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80100f:	00 
  801010:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801017:	00 
  801018:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80101f:	00 
  801020:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801024:	89 44 24 08          	mov    %eax,0x8(%esp)
  801028:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80102f:	00 
  801030:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801037:	e8 45 fd ff ff       	call   800d81 <syscall>
}
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801044:	8b 55 0c             	mov    0xc(%ebp),%edx
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801051:	00 
  801052:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801059:	00 
  80105a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801061:	00 
  801062:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801066:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801071:	00 
  801072:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801079:	e8 03 fd ff ff       	call   800d81 <syscall>
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801086:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801089:	8b 55 10             	mov    0x10(%ebp),%edx
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801096:	00 
  801097:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80109b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80109f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b1:	00 
  8010b2:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010b9:	e8 c3 fc ff ff       	call   800d81 <syscall>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e8:	00 
  8010e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8010fc:	e8 80 fc ff ff       	call   800d81 <syscall>
}
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <sys_exec>:

void sys_exec(char* buf){
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
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
  801130:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801137:	00 
  801138:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80113f:	e8 3d fc ff ff       	call   800d81 <syscall>
}
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <sys_wait>:

void sys_wait(){
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
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
  80117c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801183:	e8 f9 fb ff ff       	call   800d81 <syscall>
  801188:	c9                   	leave  
  801189:	c3                   	ret    

0080118a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	53                   	push   %ebx
  80118e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801191:	8d 45 14             	lea    0x14(%ebp),%eax
  801194:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801197:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80119d:	e8 09 fd ff ff       	call   800eab <sys_getenvid>
  8011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b8:	c7 04 24 10 17 80 00 	movl   $0x801710,(%esp)
  8011bf:	e8 b2 ef ff ff       	call   800176 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ce:	89 04 24             	mov    %eax,(%esp)
  8011d1:	e8 3c ef ff ff       	call   800112 <vcprintf>
	cprintf("\n");
  8011d6:	c7 04 24 33 17 80 00 	movl   $0x801733,(%esp)
  8011dd:	e8 94 ef ff ff       	call   800176 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011e2:	cc                   	int3   
  8011e3:	eb fd                	jmp    8011e2 <_panic+0x58>
  8011e5:	66 90                	xchg   %ax,%ax
  8011e7:	66 90                	xchg   %ax,%ax
  8011e9:	66 90                	xchg   %ax,%ax
  8011eb:	66 90                	xchg   %ax,%ax
  8011ed:	66 90                	xchg   %ax,%ax
  8011ef:	90                   	nop

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
