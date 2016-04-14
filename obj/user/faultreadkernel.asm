
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	b8 00 00 10 f0       	mov    $0xf0100000,%eax
  80003e:	8b 00                	mov    (%eax),%eax
  800040:	89 44 24 04          	mov    %eax,0x4(%esp)
  800044:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  80004b:	e8 25 01 00 00       	call   800175 <cprintf>
}
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800058:	e8 4d 0e 00 00       	call   800eaa <sys_getenvid>
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	c1 e0 02             	shl    $0x2,%eax
  800065:	89 c2                	mov    %eax,%edx
  800067:	c1 e2 05             	shl    $0x5,%edx
  80006a:	29 c2                	sub    %eax,%edx
  80006c:	89 d0                	mov    %edx,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80007c:	7e 0a                	jle    800088 <libmain+0x36>
		binaryname = argv[0];
  80007e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800081:	8b 00                	mov    (%eax),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008f:	8b 45 08             	mov    0x8(%ebp),%eax
  800092:	89 04 24             	mov    %eax,(%esp)
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 02 00 00 00       	call   8000a1 <exit>
}
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ae:	e8 b4 0d 00 00       	call   800e67 <sys_env_destroy>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000be:	8b 00                	mov    (%eax),%eax
  8000c0:	8d 48 01             	lea    0x1(%eax),%ecx
  8000c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000c6:	89 0a                	mov    %ecx,(%edx)
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d0:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d7:	8b 00                	mov    (%eax),%eax
  8000d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000de:	75 20                	jne    800100 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e3:	8b 00                	mov    (%eax),%eax
  8000e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000e8:	83 c2 08             	add    $0x8,%edx
  8000eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ef:	89 14 24             	mov    %edx,(%esp)
  8000f2:	e8 ea 0c 00 00       	call   800de1 <sys_cputs>
		b->idx = 0;
  8000f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800100:	8b 45 0c             	mov    0xc(%ebp),%eax
  800103:	8b 40 04             	mov    0x4(%eax),%eax
  800106:	8d 50 01             	lea    0x1(%eax),%edx
  800109:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800121:	00 00 00 
	b.cnt = 0;
  800124:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800131:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800135:	8b 45 08             	mov    0x8(%ebp),%eax
  800138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800142:	89 44 24 04          	mov    %eax,0x4(%esp)
  800146:	c7 04 24 b5 00 80 00 	movl   $0x8000b5,(%esp)
  80014d:	e8 bd 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800152:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800162:	83 c0 08             	add    $0x8,%eax
  800165:	89 04 24             	mov    %eax,(%esp)
  800168:	e8 74 0c 00 00       	call   800de1 <sys_cputs>

	return b.cnt;
  80016d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    

00800175 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80017e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 7e ff ff ff       	call   800111 <vcprintf>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	83 ec 34             	sub    $0x34,%esp
  8001a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ae:	8b 45 18             	mov    0x18(%ebp),%eax
  8001b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001b9:	77 72                	ja     80022d <printnum+0x92>
  8001bb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001be:	72 05                	jb     8001c5 <printnum+0x2a>
  8001c0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001c3:	77 68                	ja     80022d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001c8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001cb:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001e1:	89 04 24             	mov    %eax,(%esp)
  8001e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e8:	e8 b3 0f 00 00       	call   8011a0 <__udivdi3>
  8001ed:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001f0:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8001f4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8001f8:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001fb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800203:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 04 24             	mov    %eax,(%esp)
  800214:	e8 82 ff ff ff       	call   80019b <printnum>
  800219:	eb 1c                	jmp    800237 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8b 45 20             	mov    0x20(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 45 08             	mov    0x8(%ebp),%eax
  80022b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800231:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800235:	7f e4                	jg     80021b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800237:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800245:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	89 54 24 04          	mov    %edx,0x4(%esp)
  800254:	e8 77 10 00 00       	call   8012d0 <__umoddi3>
  800259:	05 48 15 80 00       	add    $0x801548,%eax
  80025e:	0f b6 00             	movzbl (%eax),%eax
  800261:	0f be c0             	movsbl %al,%eax
  800264:	8b 55 0c             	mov    0xc(%ebp),%edx
  800267:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	ff d0                	call   *%eax
}
  800273:	83 c4 34             	add    $0x34,%esp
  800276:	5b                   	pop    %ebx
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800280:	7e 14                	jle    800296 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	8b 00                	mov    (%eax),%eax
  800287:	8d 48 08             	lea    0x8(%eax),%ecx
  80028a:	8b 55 08             	mov    0x8(%ebp),%edx
  80028d:	89 0a                	mov    %ecx,(%edx)
  80028f:	8b 50 04             	mov    0x4(%eax),%edx
  800292:	8b 00                	mov    (%eax),%eax
  800294:	eb 30                	jmp    8002c6 <getuint+0x4d>
	else if (lflag)
  800296:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80029a:	74 16                	je     8002b2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	8b 00                	mov    (%eax),%eax
  8002a1:	8d 48 04             	lea    0x4(%eax),%ecx
  8002a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a7:	89 0a                	mov    %ecx,(%edx)
  8002a9:	8b 00                	mov    (%eax),%eax
  8002ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b0:	eb 14                	jmp    8002c6 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 00                	mov    (%eax),%eax
  8002b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8002ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bd:	89 0a                	mov    %ecx,(%edx)
  8002bf:	8b 00                	mov    (%eax),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002cf:	7e 14                	jle    8002e5 <getint+0x1d>
		return va_arg(*ap, long long);
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	8b 00                	mov    (%eax),%eax
  8002d6:	8d 48 08             	lea    0x8(%eax),%ecx
  8002d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dc:	89 0a                	mov    %ecx,(%edx)
  8002de:	8b 50 04             	mov    0x4(%eax),%edx
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	eb 28                	jmp    80030d <getint+0x45>
	else if (lflag)
  8002e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e9:	74 12                	je     8002fd <getint+0x35>
		return va_arg(*ap, long);
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 0a                	mov    %ecx,(%edx)
  8002f8:	8b 00                	mov    (%eax),%eax
  8002fa:	99                   	cltd   
  8002fb:	eb 10                	jmp    80030d <getint+0x45>
	else
		return va_arg(*ap, int);
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	8b 00                	mov    (%eax),%eax
  800302:	8d 48 04             	lea    0x4(%eax),%ecx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	89 0a                	mov    %ecx,(%edx)
  80030a:	8b 00                	mov    (%eax),%eax
  80030c:	99                   	cltd   
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800317:	eb 18                	jmp    800331 <vprintfmt+0x22>
			if (ch == '\0')
  800319:	85 db                	test   %ebx,%ebx
  80031b:	75 05                	jne    800322 <vprintfmt+0x13>
				return;
  80031d:	e9 cc 03 00 00       	jmp    8006ee <vprintfmt+0x3df>
			putch(ch, putdat);
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
  800325:	89 44 24 04          	mov    %eax,0x4(%esp)
  800329:	89 1c 24             	mov    %ebx,(%esp)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	8b 45 10             	mov    0x10(%ebp),%eax
  800334:	8d 50 01             	lea    0x1(%eax),%edx
  800337:	89 55 10             	mov    %edx,0x10(%ebp)
  80033a:	0f b6 00             	movzbl (%eax),%eax
  80033d:	0f b6 d8             	movzbl %al,%ebx
  800340:	83 fb 25             	cmp    $0x25,%ebx
  800343:	75 d4                	jne    800319 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800345:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800349:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800350:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800357:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80035e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 45 10             	mov    0x10(%ebp),%eax
  800368:	8d 50 01             	lea    0x1(%eax),%edx
  80036b:	89 55 10             	mov    %edx,0x10(%ebp)
  80036e:	0f b6 00             	movzbl (%eax),%eax
  800371:	0f b6 d8             	movzbl %al,%ebx
  800374:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800377:	83 f8 55             	cmp    $0x55,%eax
  80037a:	0f 87 3d 03 00 00    	ja     8006bd <vprintfmt+0x3ae>
  800380:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800387:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800389:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80038d:	eb d6                	jmp    800365 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800393:	eb d0                	jmp    800365 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800395:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80039c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039f:	89 d0                	mov    %edx,%eax
  8003a1:	c1 e0 02             	shl    $0x2,%eax
  8003a4:	01 d0                	add    %edx,%eax
  8003a6:	01 c0                	add    %eax,%eax
  8003a8:	01 d8                	add    %ebx,%eax
  8003aa:	83 e8 30             	sub    $0x30,%eax
  8003ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b3:	0f b6 00             	movzbl (%eax),%eax
  8003b6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003b9:	83 fb 2f             	cmp    $0x2f,%ebx
  8003bc:	7e 0b                	jle    8003c9 <vprintfmt+0xba>
  8003be:	83 fb 39             	cmp    $0x39,%ebx
  8003c1:	7f 06                	jg     8003c9 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c7:	eb d3                	jmp    80039c <vprintfmt+0x8d>
			goto process_precision;
  8003c9:	eb 33                	jmp    8003fe <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	8d 50 04             	lea    0x4(%eax),%edx
  8003d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003d9:	eb 23                	jmp    8003fe <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003df:	79 0c                	jns    8003ed <vprintfmt+0xde>
				width = 0;
  8003e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003e8:	e9 78 ff ff ff       	jmp    800365 <vprintfmt+0x56>
  8003ed:	e9 73 ff ff ff       	jmp    800365 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f9:	e9 67 ff ff ff       	jmp    800365 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8003fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800402:	79 12                	jns    800416 <vprintfmt+0x107>
				width = precision, precision = -1;
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800411:	e9 4f ff ff ff       	jmp    800365 <vprintfmt+0x56>
  800416:	e9 4a ff ff ff       	jmp    800365 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80041f:	e9 41 ff ff ff       	jmp    800365 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 50 04             	lea    0x4(%eax),%edx
  80042a:	89 55 14             	mov    %edx,0x14(%ebp)
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800432:	89 54 24 04          	mov    %edx,0x4(%esp)
  800436:	89 04 24             	mov    %eax,(%esp)
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
  80043c:	ff d0                	call   *%eax
			break;
  80043e:	e9 a5 02 00 00       	jmp    8006e8 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80044e:	85 db                	test   %ebx,%ebx
  800450:	79 02                	jns    800454 <vprintfmt+0x145>
				err = -err;
  800452:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800454:	83 fb 09             	cmp    $0x9,%ebx
  800457:	7f 0b                	jg     800464 <vprintfmt+0x155>
  800459:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800460:	85 f6                	test   %esi,%esi
  800462:	75 23                	jne    800487 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80046f:	00 
  800470:	8b 45 0c             	mov    0xc(%ebp),%eax
  800473:	89 44 24 04          	mov    %eax,0x4(%esp)
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
  80047a:	89 04 24             	mov    %eax,(%esp)
  80047d:	e8 73 02 00 00       	call   8006f5 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800482:	e9 61 02 00 00       	jmp    8006e8 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800487:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80048b:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  800492:	00 
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
  800496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049a:	8b 45 08             	mov    0x8(%ebp),%eax
  80049d:	89 04 24             	mov    %eax,(%esp)
  8004a0:	e8 50 02 00 00       	call   8006f5 <printfmt>
			break;
  8004a5:	e9 3e 02 00 00       	jmp    8006e8 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	8b 30                	mov    (%eax),%esi
  8004b5:	85 f6                	test   %esi,%esi
  8004b7:	75 05                	jne    8004be <vprintfmt+0x1af>
				p = "(null)";
  8004b9:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8004be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c2:	7e 37                	jle    8004fb <vprintfmt+0x1ec>
  8004c4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004c8:	74 31                	je     8004fb <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	89 34 24             	mov    %esi,(%esp)
  8004d4:	e8 39 03 00 00       	call   800812 <strnlen>
  8004d9:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004dc:	eb 17                	jmp    8004f5 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004de:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ef:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f9:	7f e3                	jg     8004de <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fb:	eb 38                	jmp    800535 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800501:	74 1f                	je     800522 <vprintfmt+0x213>
  800503:	83 fb 1f             	cmp    $0x1f,%ebx
  800506:	7e 05                	jle    80050d <vprintfmt+0x1fe>
  800508:	83 fb 7e             	cmp    $0x7e,%ebx
  80050b:	7e 15                	jle    800522 <vprintfmt+0x213>
					putch('?', putdat);
  80050d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800510:	89 44 24 04          	mov    %eax,0x4(%esp)
  800514:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051b:	8b 45 08             	mov    0x8(%ebp),%eax
  80051e:	ff d0                	call   *%eax
  800520:	eb 0f                	jmp    800531 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800522:	8b 45 0c             	mov    0xc(%ebp),%eax
  800525:	89 44 24 04          	mov    %eax,0x4(%esp)
  800529:	89 1c 24             	mov    %ebx,(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800535:	89 f0                	mov    %esi,%eax
  800537:	8d 70 01             	lea    0x1(%eax),%esi
  80053a:	0f b6 00             	movzbl (%eax),%eax
  80053d:	0f be d8             	movsbl %al,%ebx
  800540:	85 db                	test   %ebx,%ebx
  800542:	74 10                	je     800554 <vprintfmt+0x245>
  800544:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800548:	78 b3                	js     8004fd <vprintfmt+0x1ee>
  80054a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80054e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800552:	79 a9                	jns    8004fd <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800554:	eb 17                	jmp    80056d <vprintfmt+0x25e>
				putch(' ', putdat);
  800556:	8b 45 0c             	mov    0xc(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800564:	8b 45 08             	mov    0x8(%ebp),%eax
  800567:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800569:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80056d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800571:	7f e3                	jg     800556 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800573:	e9 70 01 00 00       	jmp    8006e8 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800578:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	8d 45 14             	lea    0x14(%ebp),%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	e8 3e fd ff ff       	call   8002c8 <getint>
  80058a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80058d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800596:	85 d2                	test   %edx,%edx
  800598:	79 26                	jns    8005c0 <vprintfmt+0x2b1>
				putch('-', putdat);
  80059a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ab:	ff d0                	call   *%eax
				num = -(long long) num;
  8005ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005b3:	f7 d8                	neg    %eax
  8005b5:	83 d2 00             	adc    $0x0,%edx
  8005b8:	f7 da                	neg    %edx
  8005ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005c0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005c7:	e9 a8 00 00 00       	jmp    800674 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	e8 9b fc ff ff       	call   800279 <getuint>
  8005de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005e4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005eb:	e9 84 00 00 00       	jmp    800674 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 77 fc ff ff       	call   800279 <getuint>
  800602:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800605:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800608:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80060f:	eb 63                	jmp    800674 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800611:	8b 45 0c             	mov    0xc(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061f:	8b 45 08             	mov    0x8(%ebp),%eax
  800622:	ff d0                	call   *%eax
			putch('x', putdat);
  800624:	8b 45 0c             	mov    0xc(%ebp),%eax
  800627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800632:	8b 45 08             	mov    0x8(%ebp),%eax
  800635:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
  800640:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800642:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800653:	eb 1f                	jmp    800674 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800655:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	e8 12 fc ff ff       	call   800279 <getuint>
  800667:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80066a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80066d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800674:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800678:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80067b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80067f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800682:	89 54 24 14          	mov    %edx,0x14(%esp)
  800686:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800690:	89 44 24 08          	mov    %eax,0x8(%esp)
  800694:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	89 04 24             	mov    %eax,(%esp)
  8006a5:	e8 f1 fa ff ff       	call   80019b <printnum>
			break;
  8006aa:	eb 3c                	jmp    8006e8 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b3:	89 1c 24             	mov    %ebx,(%esp)
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	ff d0                	call   *%eax
			break;
  8006bb:	eb 2b                	jmp    8006e8 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006d4:	eb 04                	jmp    8006da <vprintfmt+0x3cb>
  8006d6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	83 e8 01             	sub    $0x1,%eax
  8006e0:	0f b6 00             	movzbl (%eax),%eax
  8006e3:	3c 25                	cmp    $0x25,%al
  8006e5:	75 ef                	jne    8006d6 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8006e7:	90                   	nop
		}
	}
  8006e8:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e9:	e9 43 fc ff ff       	jmp    800331 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	83 c4 40             	add    $0x40,%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800704:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800708:	8b 45 10             	mov    0x10(%ebp),%eax
  80070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800712:	89 44 24 04          	mov    %eax,0x4(%esp)
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	89 04 24             	mov    %eax,(%esp)
  80071c:	e8 ee fb ff ff       	call   80030f <vprintfmt>
	va_end(ap);
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800726:	8b 45 0c             	mov    0xc(%ebp),%eax
  800729:	8b 40 08             	mov    0x8(%eax),%eax
  80072c:	8d 50 01             	lea    0x1(%eax),%edx
  80072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800732:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800735:	8b 45 0c             	mov    0xc(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073d:	8b 40 04             	mov    0x4(%eax),%eax
  800740:	39 c2                	cmp    %eax,%edx
  800742:	73 12                	jae    800756 <sprintputch+0x33>
		*b->buf++ = ch;
  800744:	8b 45 0c             	mov    0xc(%ebp),%eax
  800747:	8b 00                	mov    (%eax),%eax
  800749:	8d 48 01             	lea    0x1(%eax),%ecx
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074f:	89 0a                	mov    %ecx,(%edx)
  800751:	8b 55 08             	mov    0x8(%ebp),%edx
  800754:	88 10                	mov    %dl,(%eax)
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800764:	8b 45 0c             	mov    0xc(%ebp),%eax
  800767:	8d 50 ff             	lea    -0x1(%eax),%edx
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	01 d0                	add    %edx,%eax
  80076f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800779:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80077d:	74 06                	je     800785 <vsnprintf+0x2d>
  80077f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800783:	7f 07                	jg     80078c <vsnprintf+0x34>
		return -E_INVAL;
  800785:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078a:	eb 2a                	jmp    8007b6 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800793:	8b 45 10             	mov    0x10(%ebp),%eax
  800796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	c7 04 24 23 07 80 00 	movl   $0x800723,(%esp)
  8007a8:	e8 62 fb ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	e8 74 ff ff ff       	call   800758 <vsnprintf>
  8007e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ea:	c9                   	leave  
  8007eb:	c3                   	ret    

008007ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007f9:	eb 08                	jmp    800803 <strlen+0x17>
		n++;
  8007fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 00             	movzbl (%eax),%eax
  800809:	84 c0                	test   %al,%al
  80080b:	75 ee                	jne    8007fb <strlen+0xf>
		n++;
	return n;
  80080d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800818:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80081f:	eb 0c                	jmp    80082d <strnlen+0x1b>
		n++;
  800821:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800825:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800829:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80082d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800831:	74 0a                	je     80083d <strnlen+0x2b>
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	0f b6 00             	movzbl (%eax),%eax
  800839:	84 c0                	test   %al,%al
  80083b:	75 e4                	jne    800821 <strnlen+0xf>
		n++;
	return n;
  80083d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80084e:	90                   	nop
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8d 50 01             	lea    0x1(%eax),%edx
  800855:	89 55 08             	mov    %edx,0x8(%ebp)
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80085e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	88 10                	mov    %dl,(%eax)
  800866:	0f b6 00             	movzbl (%eax),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	75 e2                	jne    80084f <strcpy+0xd>
		/* do nothing */;
	return ret;
  80086d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 69 ff ff ff       	call   8007ec <strlen>
  800883:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800886:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	01 c2                	add    %eax,%edx
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	89 44 24 04          	mov    %eax,0x4(%esp)
  800895:	89 14 24             	mov    %edx,(%esp)
  800898:	e8 a5 ff ff ff       	call   800842 <strcpy>
	return dst;
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008b5:	eb 23                	jmp    8008da <strncpy+0x38>
		*dst++ = *src;
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8d 50 01             	lea    0x1(%eax),%edx
  8008bd:	89 55 08             	mov    %edx,0x8(%ebp)
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	0f b6 00             	movzbl (%eax),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	74 04                	je     8008d6 <strncpy+0x34>
			src++;
  8008d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8008da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008dd:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008e0:	72 d5                	jb     8008b7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8008f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008f7:	74 33                	je     80092c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008f9:	eb 17                	jmp    800912 <strlcpy+0x2b>
			*dst++ = *src++;
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8d 50 01             	lea    0x1(%eax),%edx
  800901:	89 55 08             	mov    %edx,0x8(%ebp)
  800904:	8b 55 0c             	mov    0xc(%ebp),%edx
  800907:	8d 4a 01             	lea    0x1(%edx),%ecx
  80090a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80090d:	0f b6 12             	movzbl (%edx),%edx
  800910:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800912:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800916:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80091a:	74 0a                	je     800926 <strlcpy+0x3f>
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	0f b6 00             	movzbl (%eax),%eax
  800922:	84 c0                	test   %al,%al
  800924:	75 d5                	jne    8008fb <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80092c:	8b 55 08             	mov    0x8(%ebp),%edx
  80092f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800932:	29 c2                	sub    %eax,%edx
  800934:	89 d0                	mov    %edx,%eax
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80093b:	eb 08                	jmp    800945 <strcmp+0xd>
		p++, q++;
  80093d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800941:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	0f b6 00             	movzbl (%eax),%eax
  80094b:	84 c0                	test   %al,%al
  80094d:	74 10                	je     80095f <strcmp+0x27>
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	0f b6 10             	movzbl (%eax),%edx
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	38 c2                	cmp    %al,%dl
  80095d:	74 de                	je     80093d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	0f b6 00             	movzbl (%eax),%eax
  800965:	0f b6 d0             	movzbl %al,%edx
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	0f b6 00             	movzbl (%eax),%eax
  80096e:	0f b6 c0             	movzbl %al,%eax
  800971:	29 c2                	sub    %eax,%edx
  800973:	89 d0                	mov    %edx,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  80097a:	eb 0c                	jmp    800988 <strncmp+0x11>
		n--, p++, q++;
  80097c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800980:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800984:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800988:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80098c:	74 1a                	je     8009a8 <strncmp+0x31>
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 00             	movzbl (%eax),%eax
  800994:	84 c0                	test   %al,%al
  800996:	74 10                	je     8009a8 <strncmp+0x31>
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	0f b6 00             	movzbl (%eax),%eax
  8009a4:	38 c2                	cmp    %al,%dl
  8009a6:	74 d4                	je     80097c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ac:	75 07                	jne    8009b5 <strncmp+0x3e>
		return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	eb 16                	jmp    8009cb <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	0f b6 d0             	movzbl %al,%edx
  8009be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c1:	0f b6 00             	movzbl (%eax),%eax
  8009c4:	0f b6 c0             	movzbl %al,%eax
  8009c7:	29 c2                	sub    %eax,%edx
  8009c9:	89 d0                	mov    %edx,%eax
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 04             	sub    $0x4,%esp
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009d9:	eb 14                	jmp    8009ef <strchr+0x22>
		if (*s == c)
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 00             	movzbl (%eax),%eax
  8009e1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009e4:	75 05                	jne    8009eb <strchr+0x1e>
			return (char *) s;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	eb 13                	jmp    8009fe <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	0f b6 00             	movzbl (%eax),%eax
  8009f5:	84 c0                	test   %al,%al
  8009f7:	75 e2                	jne    8009db <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 04             	sub    $0x4,%esp
  800a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a09:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a0c:	eb 11                	jmp    800a1f <strfind+0x1f>
		if (*s == c)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 00             	movzbl (%eax),%eax
  800a14:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a17:	75 02                	jne    800a1b <strfind+0x1b>
			break;
  800a19:	eb 0e                	jmp    800a29 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	0f b6 00             	movzbl (%eax),%eax
  800a25:	84 c0                	test   %al,%al
  800a27:	75 e5                	jne    800a0e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a36:	75 05                	jne    800a3d <memset+0xf>
		return v;
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	eb 5c                	jmp    800a99 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	83 e0 03             	and    $0x3,%eax
  800a43:	85 c0                	test   %eax,%eax
  800a45:	75 41                	jne    800a88 <memset+0x5a>
  800a47:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4a:	83 e0 03             	and    $0x3,%eax
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	75 37                	jne    800a88 <memset+0x5a>
		c &= 0xFF;
  800a51:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5b:	c1 e0 18             	shl    $0x18,%eax
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a63:	c1 e0 10             	shl    $0x10,%eax
  800a66:	09 c2                	or     %eax,%edx
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	c1 e0 08             	shl    $0x8,%eax
  800a6e:	09 d0                	or     %edx,%eax
  800a70:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a73:	8b 45 10             	mov    0x10(%ebp),%eax
  800a76:	c1 e8 02             	shr    $0x2,%eax
  800a79:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	89 d7                	mov    %edx,%edi
  800a83:	fc                   	cld    
  800a84:	f3 ab                	rep stos %eax,%es:(%edi)
  800a86:	eb 0e                	jmp    800a96 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a91:	89 d7                	mov    %edx,%edi
  800a93:	fc                   	cld    
  800a94:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ab7:	73 6d                	jae    800b26 <memmove+0x8a>
  800ab9:	8b 45 10             	mov    0x10(%ebp),%eax
  800abc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800abf:	01 d0                	add    %edx,%eax
  800ac1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ac4:	76 60                	jbe    800b26 <memmove+0x8a>
		s += n;
  800ac6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac9:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800acc:	8b 45 10             	mov    0x10(%ebp),%eax
  800acf:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad5:	83 e0 03             	and    $0x3,%eax
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	75 2f                	jne    800b0b <memmove+0x6f>
  800adc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800adf:	83 e0 03             	and    $0x3,%eax
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	75 25                	jne    800b0b <memmove+0x6f>
  800ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae9:	83 e0 03             	and    $0x3,%eax
  800aec:	85 c0                	test   %eax,%eax
  800aee:	75 1b                	jne    800b0b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af3:	83 e8 04             	sub    $0x4,%eax
  800af6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af9:	83 ea 04             	sub    $0x4,%edx
  800afc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aff:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	fd                   	std    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 18                	jmp    800b23 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b14:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b17:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 de                	mov    %ebx,%esi
  800b1e:	89 c1                	mov    %eax,%ecx
  800b20:	fd                   	std    
  800b21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b23:	fc                   	cld    
  800b24:	eb 45                	jmp    800b6b <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b29:	83 e0 03             	and    $0x3,%eax
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	75 2b                	jne    800b5b <memmove+0xbf>
  800b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b33:	83 e0 03             	and    $0x3,%eax
  800b36:	85 c0                	test   %eax,%eax
  800b38:	75 21                	jne    800b5b <memmove+0xbf>
  800b3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3d:	83 e0 03             	and    $0x3,%eax
  800b40:	85 c0                	test   %eax,%eax
  800b42:	75 17                	jne    800b5b <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
  800b47:	c1 e8 02             	shr    $0x2,%eax
  800b4a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	fc                   	cld    
  800b57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b59:	eb 10                	jmp    800b6b <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b61:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b64:	89 c7                	mov    %eax,%edi
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	fc                   	cld    
  800b69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	89 04 24             	mov    %eax,(%esp)
  800b90:	e8 07 ff ff ff       	call   800a9c <memmove>
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ba9:	eb 30                	jmp    800bdb <memcmp+0x44>
		if (*s1 != *s2)
  800bab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bae:	0f b6 10             	movzbl (%eax),%edx
  800bb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bb4:	0f b6 00             	movzbl (%eax),%eax
  800bb7:	38 c2                	cmp    %al,%dl
  800bb9:	74 18                	je     800bd3 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbe:	0f b6 00             	movzbl (%eax),%eax
  800bc1:	0f b6 d0             	movzbl %al,%edx
  800bc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bc7:	0f b6 00             	movzbl (%eax),%eax
  800bca:	0f b6 c0             	movzbl %al,%eax
  800bcd:	29 c2                	sub    %eax,%edx
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	eb 1a                	jmp    800bed <memcmp+0x56>
		s1++, s2++;
  800bd3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800bd7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bde:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be1:	89 55 10             	mov    %edx,0x10(%ebp)
  800be4:	85 c0                	test   %eax,%eax
  800be6:	75 c3                	jne    800bab <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	01 d0                	add    %edx,%eax
  800bfd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c00:	eb 13                	jmp    800c15 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	0f b6 10             	movzbl (%eax),%edx
  800c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0b:	38 c2                	cmp    %al,%dl
  800c0d:	75 02                	jne    800c11 <memfind+0x22>
			break;
  800c0f:	eb 0c                	jmp    800c1d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c1b:	72 e5                	jb     800c02 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c2f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c36:	eb 04                	jmp    800c3c <strtol+0x1a>
		s++;
  800c38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	0f b6 00             	movzbl (%eax),%eax
  800c42:	3c 20                	cmp    $0x20,%al
  800c44:	74 f2                	je     800c38 <strtol+0x16>
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	0f b6 00             	movzbl (%eax),%eax
  800c4c:	3c 09                	cmp    $0x9,%al
  800c4e:	74 e8                	je     800c38 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	0f b6 00             	movzbl (%eax),%eax
  800c56:	3c 2b                	cmp    $0x2b,%al
  800c58:	75 06                	jne    800c60 <strtol+0x3e>
		s++;
  800c5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c5e:	eb 15                	jmp    800c75 <strtol+0x53>
	else if (*s == '-')
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	0f b6 00             	movzbl (%eax),%eax
  800c66:	3c 2d                	cmp    $0x2d,%al
  800c68:	75 0b                	jne    800c75 <strtol+0x53>
		s++, neg = 1;
  800c6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c79:	74 06                	je     800c81 <strtol+0x5f>
  800c7b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c7f:	75 24                	jne    800ca5 <strtol+0x83>
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	3c 30                	cmp    $0x30,%al
  800c89:	75 1a                	jne    800ca5 <strtol+0x83>
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	83 c0 01             	add    $0x1,%eax
  800c91:	0f b6 00             	movzbl (%eax),%eax
  800c94:	3c 78                	cmp    $0x78,%al
  800c96:	75 0d                	jne    800ca5 <strtol+0x83>
		s += 2, base = 16;
  800c98:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800c9c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ca3:	eb 2a                	jmp    800ccf <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ca5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ca9:	75 17                	jne    800cc2 <strtol+0xa0>
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	0f b6 00             	movzbl (%eax),%eax
  800cb1:	3c 30                	cmp    $0x30,%al
  800cb3:	75 0d                	jne    800cc2 <strtol+0xa0>
		s++, base = 8;
  800cb5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cc0:	eb 0d                	jmp    800ccf <strtol+0xad>
	else if (base == 0)
  800cc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc6:	75 07                	jne    800ccf <strtol+0xad>
		base = 10;
  800cc8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	0f b6 00             	movzbl (%eax),%eax
  800cd5:	3c 2f                	cmp    $0x2f,%al
  800cd7:	7e 1b                	jle    800cf4 <strtol+0xd2>
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	0f b6 00             	movzbl (%eax),%eax
  800cdf:	3c 39                	cmp    $0x39,%al
  800ce1:	7f 11                	jg     800cf4 <strtol+0xd2>
			dig = *s - '0';
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	0f b6 00             	movzbl (%eax),%eax
  800ce9:	0f be c0             	movsbl %al,%eax
  800cec:	83 e8 30             	sub    $0x30,%eax
  800cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cf2:	eb 48                	jmp    800d3c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 00             	movzbl (%eax),%eax
  800cfa:	3c 60                	cmp    $0x60,%al
  800cfc:	7e 1b                	jle    800d19 <strtol+0xf7>
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	0f b6 00             	movzbl (%eax),%eax
  800d04:	3c 7a                	cmp    $0x7a,%al
  800d06:	7f 11                	jg     800d19 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	0f b6 00             	movzbl (%eax),%eax
  800d0e:	0f be c0             	movsbl %al,%eax
  800d11:	83 e8 57             	sub    $0x57,%eax
  800d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d17:	eb 23                	jmp    800d3c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	0f b6 00             	movzbl (%eax),%eax
  800d1f:	3c 40                	cmp    $0x40,%al
  800d21:	7e 3d                	jle    800d60 <strtol+0x13e>
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	0f b6 00             	movzbl (%eax),%eax
  800d29:	3c 5a                	cmp    $0x5a,%al
  800d2b:	7f 33                	jg     800d60 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	0f b6 00             	movzbl (%eax),%eax
  800d33:	0f be c0             	movsbl %al,%eax
  800d36:	83 e8 37             	sub    $0x37,%eax
  800d39:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d42:	7c 02                	jl     800d46 <strtol+0x124>
			break;
  800d44:	eb 1a                	jmp    800d60 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d4d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d51:	89 c2                	mov    %eax,%edx
  800d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d56:	01 d0                	add    %edx,%eax
  800d58:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d5b:	e9 6f ff ff ff       	jmp    800ccf <strtol+0xad>

	if (endptr)
  800d60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d64:	74 08                	je     800d6e <strtol+0x14c>
		*endptr = (char *) s;
  800d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d6e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d72:	74 07                	je     800d7b <strtol+0x159>
  800d74:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d77:	f7 d8                	neg    %eax
  800d79:	eb 03                	jmp    800d7e <strtol+0x15c>
  800d7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	8b 55 10             	mov    0x10(%ebp),%edx
  800d8f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d92:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800d95:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800d98:	8b 75 20             	mov    0x20(%ebp),%esi
  800d9b:	cd 30                	int    $0x30
  800d9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da4:	74 30                	je     800dd6 <syscall+0x56>
  800da6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800daa:	7e 2a                	jle    800dd6 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dba:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc9:	00 
  800dca:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800dd1:	e8 6f 03 00 00       	call   801145 <_panic>

	return ret;
  800dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800dd9:	83 c4 3c             	add    $0x3c,%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800df1:	00 
  800df2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800df9:	00 
  800dfa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e01:	00 
  800e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e05:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e14:	00 
  800e15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e1c:	e8 5f ff ff ff       	call   800d80 <syscall>
}
  800e21:	c9                   	leave  
  800e22:	c3                   	ret    

00800e23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e29:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e30:	00 
  800e31:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e38:	00 
  800e39:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e40:	00 
  800e41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e48:	00 
  800e49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e60:	e8 1b ff ff ff       	call   800d80 <syscall>
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e77:	00 
  800e78:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e7f:	00 
  800e80:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e87:	00 
  800e88:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8f:	00 
  800e90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e94:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ea3:	e8 d8 fe ff ff       	call   800d80 <syscall>
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800eb0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800edf:	00 
  800ee0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ee7:	e8 94 fe ff ff       	call   800d80 <syscall>
}
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <sys_yield>:

void
sys_yield(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ef4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800efb:	00 
  800efc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f03:	00 
  800f04:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f13:	00 
  800f14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f2b:	e8 50 fe ff ff       	call   800d80 <syscall>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f38:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f48:	00 
  800f49:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f50:	00 
  800f51:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f55:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f59:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f6c:	e8 0f fe ff ff       	call   800d80 <syscall>
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800f7e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f81:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f8e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800f92:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f96:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fad:	e8 ce fd ff ff       	call   800d80 <syscall>
}
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fcc:	00 
  800fcd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fdc:	00 
  800fdd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fec:	00 
  800fed:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800ff4:	e8 87 fd ff ff       	call   800d80 <syscall>
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801001:	8b 55 0c             	mov    0xc(%ebp),%edx
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
  801007:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80100e:	00 
  80100f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801016:	00 
  801017:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80101e:	00 
  80101f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801023:	89 44 24 08          	mov    %eax,0x8(%esp)
  801027:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80102e:	00 
  80102f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801036:	e8 45 fd ff ff       	call   800d80 <syscall>
}
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    

0080103d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801043:	8b 55 0c             	mov    0xc(%ebp),%edx
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801050:	00 
  801051:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801058:	00 
  801059:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801060:	00 
  801061:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801065:	89 44 24 08          	mov    %eax,0x8(%esp)
  801069:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801078:	e8 03 fd ff ff       	call   800d80 <syscall>
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801085:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801088:	8b 55 10             	mov    0x10(%ebp),%edx
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801095:	00 
  801096:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80109a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80109e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010b8:	e8 c3 fc ff ff       	call   800d80 <syscall>
}
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cf:	00 
  8010d0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010df:	00 
  8010e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e7:	00 
  8010e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f3:	00 
  8010f4:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8010fb:	e8 80 fc ff ff       	call   800d80 <syscall>
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <sys_exec>:

void sys_exec(char* buf){
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
  80110b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801112:	00 
  801113:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80111a:	00 
  80111b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801122:	00 
  801123:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80112a:	00 
  80112b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80113e:	e8 3d fc ff ff       	call   800d80 <syscall>
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	53                   	push   %ebx
  801149:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80114c:	8d 45 14             	lea    0x14(%ebp),%eax
  80114f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801152:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801158:	e8 4d fd ff ff       	call   800eaa <sys_getenvid>
  80115d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801160:	89 54 24 10          	mov    %edx,0x10(%esp)
  801164:	8b 55 08             	mov    0x8(%ebp),%edx
  801167:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80116f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801173:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  80117a:	e8 f6 ef ff ff       	call   800175 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80117f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801182:	89 44 24 04          	mov    %eax,0x4(%esp)
  801186:	8b 45 10             	mov    0x10(%ebp),%eax
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 80 ef ff ff       	call   800111 <vcprintf>
	cprintf("\n");
  801191:	c7 04 24 13 17 80 00 	movl   $0x801713,(%esp)
  801198:	e8 d8 ef ff ff       	call   800175 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80119d:	cc                   	int3   
  80119e:	eb fd                	jmp    80119d <_panic+0x58>

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011bc:	89 ea                	mov    %ebp,%edx
  8011be:	89 0c 24             	mov    %ecx,(%esp)
  8011c1:	75 2d                	jne    8011f0 <__udivdi3+0x50>
  8011c3:	39 e9                	cmp    %ebp,%ecx
  8011c5:	77 61                	ja     801228 <__udivdi3+0x88>
  8011c7:	85 c9                	test   %ecx,%ecx
  8011c9:	89 ce                	mov    %ecx,%esi
  8011cb:	75 0b                	jne    8011d8 <__udivdi3+0x38>
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	f7 f1                	div    %ecx
  8011d6:	89 c6                	mov    %eax,%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	89 e8                	mov    %ebp,%eax
  8011dc:	f7 f6                	div    %esi
  8011de:	89 c5                	mov    %eax,%ebp
  8011e0:	89 f8                	mov    %edi,%eax
  8011e2:	f7 f6                	div    %esi
  8011e4:	89 ea                	mov    %ebp,%edx
  8011e6:	83 c4 0c             	add    $0xc,%esp
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
  8011ed:	8d 76 00             	lea    0x0(%esi),%esi
  8011f0:	39 e8                	cmp    %ebp,%eax
  8011f2:	77 24                	ja     801218 <__udivdi3+0x78>
  8011f4:	0f bd e8             	bsr    %eax,%ebp
  8011f7:	83 f5 1f             	xor    $0x1f,%ebp
  8011fa:	75 3c                	jne    801238 <__udivdi3+0x98>
  8011fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801200:	39 34 24             	cmp    %esi,(%esp)
  801203:	0f 86 9f 00 00 00    	jbe    8012a8 <__udivdi3+0x108>
  801209:	39 d0                	cmp    %edx,%eax
  80120b:	0f 82 97 00 00 00    	jb     8012a8 <__udivdi3+0x108>
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	31 c0                	xor    %eax,%eax
  80121c:	83 c4 0c             	add    $0xc,%esp
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	89 f8                	mov    %edi,%eax
  80122a:	f7 f1                	div    %ecx
  80122c:	31 d2                	xor    %edx,%edx
  80122e:	83 c4 0c             	add    $0xc,%esp
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    
  801235:	8d 76 00             	lea    0x0(%esi),%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	8b 3c 24             	mov    (%esp),%edi
  80123d:	d3 e0                	shl    %cl,%eax
  80123f:	89 c6                	mov    %eax,%esi
  801241:	b8 20 00 00 00       	mov    $0x20,%eax
  801246:	29 e8                	sub    %ebp,%eax
  801248:	89 c1                	mov    %eax,%ecx
  80124a:	d3 ef                	shr    %cl,%edi
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801252:	8b 3c 24             	mov    (%esp),%edi
  801255:	09 74 24 08          	or     %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	d3 e7                	shl    %cl,%edi
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 3c 24             	mov    %edi,(%esp)
  801262:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801266:	d3 ee                	shr    %cl,%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	d3 e2                	shl    %cl,%edx
  80126c:	89 c1                	mov    %eax,%ecx
  80126e:	d3 ef                	shr    %cl,%edi
  801270:	09 d7                	or     %edx,%edi
  801272:	89 f2                	mov    %esi,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	f7 74 24 08          	divl   0x8(%esp)
  80127a:	89 d6                	mov    %edx,%esi
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	f7 24 24             	mull   (%esp)
  801281:	39 d6                	cmp    %edx,%esi
  801283:	89 14 24             	mov    %edx,(%esp)
  801286:	72 30                	jb     8012b8 <__udivdi3+0x118>
  801288:	8b 54 24 04          	mov    0x4(%esp),%edx
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	39 c2                	cmp    %eax,%edx
  801292:	73 05                	jae    801299 <__udivdi3+0xf9>
  801294:	3b 34 24             	cmp    (%esp),%esi
  801297:	74 1f                	je     8012b8 <__udivdi3+0x118>
  801299:	89 f8                	mov    %edi,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	e9 7a ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012af:	e9 68 ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 0c             	add    $0xc,%esp
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012e2:	89 c7                	mov    %eax,%edi
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012f0:	89 34 24             	mov    %esi,(%esp)
  8012f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	75 17                	jne    801318 <__umoddi3+0x48>
  801301:	39 fe                	cmp    %edi,%esi
  801303:	76 4b                	jbe    801350 <__umoddi3+0x80>
  801305:	89 c8                	mov    %ecx,%eax
  801307:	89 fa                	mov    %edi,%edx
  801309:	f7 f6                	div    %esi
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	31 d2                	xor    %edx,%edx
  80130f:	83 c4 14             	add    $0x14,%esp
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
  801316:	66 90                	xchg   %ax,%ax
  801318:	39 f8                	cmp    %edi,%eax
  80131a:	77 54                	ja     801370 <__umoddi3+0xa0>
  80131c:	0f bd e8             	bsr    %eax,%ebp
  80131f:	83 f5 1f             	xor    $0x1f,%ebp
  801322:	75 5c                	jne    801380 <__umoddi3+0xb0>
  801324:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801328:	39 3c 24             	cmp    %edi,(%esp)
  80132b:	0f 87 e7 00 00 00    	ja     801418 <__umoddi3+0x148>
  801331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801335:	29 f1                	sub    %esi,%ecx
  801337:	19 c7                	sbb    %eax,%edi
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801341:	8b 44 24 08          	mov    0x8(%esp),%eax
  801345:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801349:	83 c4 14             	add    $0x14,%esp
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    
  801350:	85 f6                	test   %esi,%esi
  801352:	89 f5                	mov    %esi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f6                	div    %esi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	8b 44 24 04          	mov    0x4(%esp),%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	f7 f5                	div    %ebp
  801369:	89 c8                	mov    %ecx,%eax
  80136b:	f7 f5                	div    %ebp
  80136d:	eb 9c                	jmp    80130b <__umoddi3+0x3b>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 fa                	mov    %edi,%edx
  801374:	83 c4 14             	add    $0x14,%esp
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
  80137b:	90                   	nop
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 04 24             	mov    (%esp),%eax
  801383:	be 20 00 00 00       	mov    $0x20,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ee                	sub    %ebp,%esi
  80138c:	d3 e2                	shl    %cl,%edx
  80138e:	89 f1                	mov    %esi,%ecx
  801390:	d3 e8                	shr    %cl,%eax
  801392:	89 e9                	mov    %ebp,%ecx
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	8b 04 24             	mov    (%esp),%eax
  80139b:	09 54 24 04          	or     %edx,0x4(%esp)
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e0                	shl    %cl,%eax
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ad:	d3 ea                	shr    %cl,%edx
  8013af:	89 e9                	mov    %ebp,%ecx
  8013b1:	d3 e7                	shl    %cl,%edi
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	d3 e8                	shr    %cl,%eax
  8013b7:	89 e9                	mov    %ebp,%ecx
  8013b9:	09 f8                	or     %edi,%eax
  8013bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013bf:	f7 74 24 04          	divl   0x4(%esp)
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c9:	89 d7                	mov    %edx,%edi
  8013cb:	f7 64 24 08          	mull   0x8(%esp)
  8013cf:	39 d7                	cmp    %edx,%edi
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 2c                	jb     801404 <__umoddi3+0x134>
  8013d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013dc:	72 22                	jb     801400 <__umoddi3+0x130>
  8013de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013e2:	29 c8                	sub    %ecx,%eax
  8013e4:	19 d7                	sbb    %edx,%edi
  8013e6:	89 e9                	mov    %ebp,%ecx
  8013e8:	89 fa                	mov    %edi,%edx
  8013ea:	d3 e8                	shr    %cl,%eax
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	89 e9                	mov    %ebp,%ecx
  8013f2:	d3 ef                	shr    %cl,%edi
  8013f4:	09 d0                	or     %edx,%eax
  8013f6:	89 fa                	mov    %edi,%edx
  8013f8:	83 c4 14             	add    $0x14,%esp
  8013fb:	5e                   	pop    %esi
  8013fc:	5f                   	pop    %edi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
  8013ff:	90                   	nop
  801400:	39 d7                	cmp    %edx,%edi
  801402:	75 da                	jne    8013de <__umoddi3+0x10e>
  801404:	8b 14 24             	mov    (%esp),%edx
  801407:	89 c1                	mov    %eax,%ecx
  801409:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80140d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801411:	eb cb                	jmp    8013de <__umoddi3+0x10e>
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80141c:	0f 82 0f ff ff ff    	jb     801331 <__umoddi3+0x61>
  801422:	e9 1a ff ff ff       	jmp    801341 <__umoddi3+0x71>
