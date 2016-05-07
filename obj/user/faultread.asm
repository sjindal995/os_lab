
obj/user/faultread:     file format elf32-i386


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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	b8 00 00 00 00       	mov    $0x0,%eax
  80003e:	8b 00                	mov    (%eax),%eax
  800040:	89 44 24 04          	mov    %eax,0x4(%esp)
  800044:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  80004b:	e8 15 01 00 00       	call   800165 <cprintf>
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
  800058:	e8 3d 0e 00 00       	call   800e9a <sys_getenvid>
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	c1 e0 02             	shl    $0x2,%eax
  800065:	89 c2                	mov    %eax,%edx
  800067:	c1 e2 05             	shl    $0x5,%edx
  80006a:	29 c2                	sub    %eax,%edx
  80006c:	89 d0                	mov    %edx,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007f:	8b 45 08             	mov    0x8(%ebp),%eax
  800082:	89 04 24             	mov    %eax,(%esp)
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 02 00 00 00       	call   800091 <exit>
}
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009e:	e8 b4 0d 00 00       	call   800e57 <sys_env_destroy>
}
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ae:	8b 00                	mov    (%eax),%eax
  8000b0:	8d 48 01             	lea    0x1(%eax),%ecx
  8000b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000b6:	89 0a                	mov    %ecx,(%edx)
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 d1                	mov    %edx,%ecx
  8000bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000c0:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c7:	8b 00                	mov    (%eax),%eax
  8000c9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ce:	75 20                	jne    8000f0 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d3:	8b 00                	mov    (%eax),%eax
  8000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d8:	83 c2 08             	add    $0x8,%edx
  8000db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000df:	89 14 24             	mov    %edx,(%esp)
  8000e2:	e8 ea 0c 00 00       	call   800dd1 <sys_cputs>
		b->idx = 0;
  8000e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8000f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f3:	8b 40 04             	mov    0x4(%eax),%eax
  8000f6:	8d 50 01             	lea    0x1(%eax),%edx
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 50 04             	mov    %edx,0x4(%eax)
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800111:	00 00 00 
	b.cnt = 0;
  800114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800121:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800125:	8b 45 08             	mov    0x8(%ebp),%eax
  800128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	c7 04 24 a5 00 80 00 	movl   $0x8000a5,(%esp)
  80013d:	e8 bd 01 00 00       	call   8002ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800142:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800152:	83 c0 08             	add    $0x8,%eax
  800155:	89 04 24             	mov    %eax,(%esp)
  800158:	e8 74 0c 00 00       	call   800dd1 <sys_cputs>

	return b.cnt;
  80015d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80016e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800174:	89 44 24 04          	mov    %eax,0x4(%esp)
  800178:	8b 45 08             	mov    0x8(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 7e ff ff ff       	call   800101 <vcprintf>
  800183:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800186:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 34             	sub    $0x34,%esp
  800192:	8b 45 10             	mov    0x10(%ebp),%eax
  800195:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800198:	8b 45 14             	mov    0x14(%ebp),%eax
  80019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019e:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001a9:	77 72                	ja     80021d <printnum+0x92>
  8001ab:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ae:	72 05                	jb     8001b5 <printnum+0x2a>
  8001b0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001b3:	77 68                	ja     80021d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bb:	8b 45 18             	mov    0x18(%ebp),%eax
  8001be:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d8:	e8 03 10 00 00       	call   8011e0 <__udivdi3>
  8001dd:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001e0:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8001e4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8001e8:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001eb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 82 ff ff ff       	call   80018b <printnum>
  800209:	eb 1c                	jmp    800227 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800212:	8b 45 20             	mov    0x20(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800221:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800225:	7f e4                	jg     80020b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800232:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800235:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800239:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80023d:	89 04 24             	mov    %eax,(%esp)
  800240:	89 54 24 04          	mov    %edx,0x4(%esp)
  800244:	e8 c7 10 00 00       	call   801310 <__umoddi3>
  800249:	05 88 15 80 00       	add    $0x801588,%eax
  80024e:	0f b6 00             	movzbl (%eax),%eax
  800251:	0f be c0             	movsbl %al,%eax
  800254:	8b 55 0c             	mov    0xc(%ebp),%edx
  800257:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	ff d0                	call   *%eax
}
  800263:	83 c4 34             	add    $0x34,%esp
  800266:	5b                   	pop    %ebx
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800270:	7e 14                	jle    800286 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	8b 00                	mov    (%eax),%eax
  800277:	8d 48 08             	lea    0x8(%eax),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 0a                	mov    %ecx,(%edx)
  80027f:	8b 50 04             	mov    0x4(%eax),%edx
  800282:	8b 00                	mov    (%eax),%eax
  800284:	eb 30                	jmp    8002b6 <getuint+0x4d>
	else if (lflag)
  800286:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80028a:	74 16                	je     8002a2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	8b 00                	mov    (%eax),%eax
  800291:	8d 48 04             	lea    0x4(%eax),%ecx
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	89 0a                	mov    %ecx,(%edx)
  800299:	8b 00                	mov    (%eax),%eax
  80029b:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a0:	eb 14                	jmp    8002b6 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	8b 00                	mov    (%eax),%eax
  8002a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8002aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ad:	89 0a                	mov    %ecx,(%edx)
  8002af:	8b 00                	mov    (%eax),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002bf:	7e 14                	jle    8002d5 <getint+0x1d>
		return va_arg(*ap, long long);
  8002c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c4:	8b 00                	mov    (%eax),%eax
  8002c6:	8d 48 08             	lea    0x8(%eax),%ecx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	89 0a                	mov    %ecx,(%edx)
  8002ce:	8b 50 04             	mov    0x4(%eax),%edx
  8002d1:	8b 00                	mov    (%eax),%eax
  8002d3:	eb 28                	jmp    8002fd <getint+0x45>
	else if (lflag)
  8002d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002d9:	74 12                	je     8002ed <getint+0x35>
		return va_arg(*ap, long);
  8002db:	8b 45 08             	mov    0x8(%ebp),%eax
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	8d 48 04             	lea    0x4(%eax),%ecx
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 0a                	mov    %ecx,(%edx)
  8002e8:	8b 00                	mov    (%eax),%eax
  8002ea:	99                   	cltd   
  8002eb:	eb 10                	jmp    8002fd <getint+0x45>
	else
		return va_arg(*ap, int);
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	8b 00                	mov    (%eax),%eax
  8002f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	89 0a                	mov    %ecx,(%edx)
  8002fa:	8b 00                	mov    (%eax),%eax
  8002fc:	99                   	cltd   
}
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800307:	eb 18                	jmp    800321 <vprintfmt+0x22>
			if (ch == '\0')
  800309:	85 db                	test   %ebx,%ebx
  80030b:	75 05                	jne    800312 <vprintfmt+0x13>
				return;
  80030d:	e9 cc 03 00 00       	jmp    8006de <vprintfmt+0x3df>
			putch(ch, putdat);
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
  800315:	89 44 24 04          	mov    %eax,0x4(%esp)
  800319:	89 1c 24             	mov    %ebx,(%esp)
  80031c:	8b 45 08             	mov    0x8(%ebp),%eax
  80031f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800321:	8b 45 10             	mov    0x10(%ebp),%eax
  800324:	8d 50 01             	lea    0x1(%eax),%edx
  800327:	89 55 10             	mov    %edx,0x10(%ebp)
  80032a:	0f b6 00             	movzbl (%eax),%eax
  80032d:	0f b6 d8             	movzbl %al,%ebx
  800330:	83 fb 25             	cmp    $0x25,%ebx
  800333:	75 d4                	jne    800309 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800335:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800339:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800340:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800347:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80034e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 45 10             	mov    0x10(%ebp),%eax
  800358:	8d 50 01             	lea    0x1(%eax),%edx
  80035b:	89 55 10             	mov    %edx,0x10(%ebp)
  80035e:	0f b6 00             	movzbl (%eax),%eax
  800361:	0f b6 d8             	movzbl %al,%ebx
  800364:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800367:	83 f8 55             	cmp    $0x55,%eax
  80036a:	0f 87 3d 03 00 00    	ja     8006ad <vprintfmt+0x3ae>
  800370:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  800377:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800379:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80037d:	eb d6                	jmp    800355 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800383:	eb d0                	jmp    800355 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800385:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80038c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80038f:	89 d0                	mov    %edx,%eax
  800391:	c1 e0 02             	shl    $0x2,%eax
  800394:	01 d0                	add    %edx,%eax
  800396:	01 c0                	add    %eax,%eax
  800398:	01 d8                	add    %ebx,%eax
  80039a:	83 e8 30             	sub    $0x30,%eax
  80039d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a3:	0f b6 00             	movzbl (%eax),%eax
  8003a6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003a9:	83 fb 2f             	cmp    $0x2f,%ebx
  8003ac:	7e 0b                	jle    8003b9 <vprintfmt+0xba>
  8003ae:	83 fb 39             	cmp    $0x39,%ebx
  8003b1:	7f 06                	jg     8003b9 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b7:	eb d3                	jmp    80038c <vprintfmt+0x8d>
			goto process_precision;
  8003b9:	eb 33                	jmp    8003ee <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 50 04             	lea    0x4(%eax),%edx
  8003c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c4:	8b 00                	mov    (%eax),%eax
  8003c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003c9:	eb 23                	jmp    8003ee <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003cf:	79 0c                	jns    8003dd <vprintfmt+0xde>
				width = 0;
  8003d1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003d8:	e9 78 ff ff ff       	jmp    800355 <vprintfmt+0x56>
  8003dd:	e9 73 ff ff ff       	jmp    800355 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003e2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003e9:	e9 67 ff ff ff       	jmp    800355 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8003ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f2:	79 12                	jns    800406 <vprintfmt+0x107>
				width = precision, precision = -1;
  8003f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800401:	e9 4f ff ff ff       	jmp    800355 <vprintfmt+0x56>
  800406:	e9 4a ff ff ff       	jmp    800355 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80040f:	e9 41 ff ff ff       	jmp    800355 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800422:	89 54 24 04          	mov    %edx,0x4(%esp)
  800426:	89 04 24             	mov    %eax,(%esp)
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	ff d0                	call   *%eax
			break;
  80042e:	e9 a5 02 00 00       	jmp    8006d8 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 50 04             	lea    0x4(%eax),%edx
  800439:	89 55 14             	mov    %edx,0x14(%ebp)
  80043c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80043e:	85 db                	test   %ebx,%ebx
  800440:	79 02                	jns    800444 <vprintfmt+0x145>
				err = -err;
  800442:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800444:	83 fb 09             	cmp    $0x9,%ebx
  800447:	7f 0b                	jg     800454 <vprintfmt+0x155>
  800449:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  800450:	85 f6                	test   %esi,%esi
  800452:	75 23                	jne    800477 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800454:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800458:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  80045f:	00 
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	89 44 24 04          	mov    %eax,0x4(%esp)
  800467:	8b 45 08             	mov    0x8(%ebp),%eax
  80046a:	89 04 24             	mov    %eax,(%esp)
  80046d:	e8 73 02 00 00       	call   8006e5 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800472:	e9 61 02 00 00       	jmp    8006d8 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800477:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80047b:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  800482:	00 
  800483:	8b 45 0c             	mov    0xc(%ebp),%eax
  800486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048a:	8b 45 08             	mov    0x8(%ebp),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	e8 50 02 00 00       	call   8006e5 <printfmt>
			break;
  800495:	e9 3e 02 00 00       	jmp    8006d8 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 30                	mov    (%eax),%esi
  8004a5:	85 f6                	test   %esi,%esi
  8004a7:	75 05                	jne    8004ae <vprintfmt+0x1af>
				p = "(null)";
  8004a9:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8004ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b2:	7e 37                	jle    8004eb <vprintfmt+0x1ec>
  8004b4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004b8:	74 31                	je     8004eb <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c1:	89 34 24             	mov    %esi,(%esp)
  8004c4:	e8 39 03 00 00       	call   800802 <strnlen>
  8004c9:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004cc:	eb 17                	jmp    8004e5 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004ce:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004df:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e9:	7f e3                	jg     8004ce <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	eb 38                	jmp    800525 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f1:	74 1f                	je     800512 <vprintfmt+0x213>
  8004f3:	83 fb 1f             	cmp    $0x1f,%ebx
  8004f6:	7e 05                	jle    8004fd <vprintfmt+0x1fe>
  8004f8:	83 fb 7e             	cmp    $0x7e,%ebx
  8004fb:	7e 15                	jle    800512 <vprintfmt+0x213>
					putch('?', putdat);
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	ff d0                	call   *%eax
  800510:	eb 0f                	jmp    800521 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
  800515:	89 44 24 04          	mov    %eax,0x4(%esp)
  800519:	89 1c 24             	mov    %ebx,(%esp)
  80051c:	8b 45 08             	mov    0x8(%ebp),%eax
  80051f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800521:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800525:	89 f0                	mov    %esi,%eax
  800527:	8d 70 01             	lea    0x1(%eax),%esi
  80052a:	0f b6 00             	movzbl (%eax),%eax
  80052d:	0f be d8             	movsbl %al,%ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	74 10                	je     800544 <vprintfmt+0x245>
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	78 b3                	js     8004ed <vprintfmt+0x1ee>
  80053a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80053e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800542:	79 a9                	jns    8004ed <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800544:	eb 17                	jmp    80055d <vprintfmt+0x25e>
				putch(' ', putdat);
  800546:	8b 45 0c             	mov    0xc(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800554:	8b 45 08             	mov    0x8(%ebp),%eax
  800557:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800559:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80055d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800561:	7f e3                	jg     800546 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800563:	e9 70 01 00 00       	jmp    8006d8 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800568:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	8d 45 14             	lea    0x14(%ebp),%eax
  800572:	89 04 24             	mov    %eax,(%esp)
  800575:	e8 3e fd ff ff       	call   8002b8 <getint>
  80057a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80057d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800580:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800583:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	79 26                	jns    8005b0 <vprintfmt+0x2b1>
				putch('-', putdat);
  80058a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800598:	8b 45 08             	mov    0x8(%ebp),%eax
  80059b:	ff d0                	call   *%eax
				num = -(long long) num;
  80059d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a3:	f7 d8                	neg    %eax
  8005a5:	83 d2 00             	adc    $0x0,%edx
  8005a8:	f7 da                	neg    %edx
  8005aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005b0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005b7:	e9 a8 00 00 00       	jmp    800664 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	e8 9b fc ff ff       	call   800269 <getuint>
  8005ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005d4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005db:	e9 84 00 00 00       	jmp    800664 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	e8 77 fc ff ff       	call   800269 <getuint>
  8005f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8005f8:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8005ff:	eb 63                	jmp    800664 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800601:	8b 45 0c             	mov    0xc(%ebp),%eax
  800604:	89 44 24 04          	mov    %eax,0x4(%esp)
  800608:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80060f:	8b 45 08             	mov    0x8(%ebp),%eax
  800612:	ff d0                	call   *%eax
			putch('x', putdat);
  800614:	8b 45 0c             	mov    0xc(%ebp),%eax
  800617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800622:	8b 45 08             	mov    0x8(%ebp),%eax
  800625:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 50 04             	lea    0x4(%eax),%edx
  80062d:	89 55 14             	mov    %edx,0x14(%ebp)
  800630:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800632:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800643:	eb 1f                	jmp    800664 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800645:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 12 fc ff ff       	call   800269 <getuint>
  800657:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80065a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80065d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800668:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80066f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800672:	89 54 24 14          	mov    %edx,0x14(%esp)
  800676:	89 44 24 10          	mov    %eax,0x10(%esp)
  80067a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800680:	89 44 24 08          	mov    %eax,0x8(%esp)
  800684:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800688:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068f:	8b 45 08             	mov    0x8(%ebp),%eax
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	e8 f1 fa ff ff       	call   80018b <printnum>
			break;
  80069a:	eb 3c                	jmp    8006d8 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a3:	89 1c 24             	mov    %ebx,(%esp)
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	ff d0                	call   *%eax
			break;
  8006ab:	eb 2b                	jmp    8006d8 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006c4:	eb 04                	jmp    8006ca <vprintfmt+0x3cb>
  8006c6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	83 e8 01             	sub    $0x1,%eax
  8006d0:	0f b6 00             	movzbl (%eax),%eax
  8006d3:	3c 25                	cmp    $0x25,%al
  8006d5:	75 ef                	jne    8006c6 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8006d7:	90                   	nop
		}
	}
  8006d8:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d9:	e9 43 fc ff ff       	jmp    800321 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006de:	83 c4 40             	add    $0x40,%esp
  8006e1:	5b                   	pop    %ebx
  8006e2:	5e                   	pop    %esi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	89 04 24             	mov    %eax,(%esp)
  80070c:	e8 ee fb ff ff       	call   8002ff <vprintfmt>
	va_end(ap);
}
  800711:	c9                   	leave  
  800712:	c3                   	ret    

00800713 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800716:	8b 45 0c             	mov    0xc(%ebp),%eax
  800719:	8b 40 08             	mov    0x8(%eax),%eax
  80071c:	8d 50 01             	lea    0x1(%eax),%edx
  80071f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800722:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800725:	8b 45 0c             	mov    0xc(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072d:	8b 40 04             	mov    0x4(%eax),%eax
  800730:	39 c2                	cmp    %eax,%edx
  800732:	73 12                	jae    800746 <sprintputch+0x33>
		*b->buf++ = ch;
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	8b 00                	mov    (%eax),%eax
  800739:	8d 48 01             	lea    0x1(%eax),%ecx
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073f:	89 0a                	mov    %ecx,(%edx)
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
  800744:	88 10                	mov    %dl,(%eax)
}
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800754:	8b 45 0c             	mov    0xc(%ebp),%eax
  800757:	8d 50 ff             	lea    -0x1(%eax),%edx
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	01 d0                	add    %edx,%eax
  80075f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800762:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800769:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80076d:	74 06                	je     800775 <vsnprintf+0x2d>
  80076f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800773:	7f 07                	jg     80077c <vsnprintf+0x34>
		return -E_INVAL;
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077a:	eb 2a                	jmp    8007a6 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800783:	8b 45 10             	mov    0x10(%ebp),%eax
  800786:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	c7 04 24 13 07 80 00 	movl   $0x800713,(%esp)
  800798:	e8 62 fb ff ff       	call   8002ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	89 04 24             	mov    %eax,(%esp)
  8007cf:	e8 74 ff ff ff       	call   800748 <vsnprintf>
  8007d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8007d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007e9:	eb 08                	jmp    8007f3 <strlen+0x17>
		n++;
  8007eb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	0f b6 00             	movzbl (%eax),%eax
  8007f9:	84 c0                	test   %al,%al
  8007fb:	75 ee                	jne    8007eb <strlen+0xf>
		n++;
	return n;
  8007fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800808:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80080f:	eb 0c                	jmp    80081d <strnlen+0x1b>
		n++;
  800811:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800819:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80081d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800821:	74 0a                	je     80082d <strnlen+0x2b>
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	0f b6 00             	movzbl (%eax),%eax
  800829:	84 c0                	test   %al,%al
  80082b:	75 e4                	jne    800811 <strnlen+0xf>
		n++;
	return n;
  80082d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80083e:	90                   	nop
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8d 50 01             	lea    0x1(%eax),%edx
  800845:	89 55 08             	mov    %edx,0x8(%ebp)
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80084e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	88 10                	mov    %dl,(%eax)
  800856:	0f b6 00             	movzbl (%eax),%eax
  800859:	84 c0                	test   %al,%al
  80085b:	75 e2                	jne    80083f <strcpy+0xd>
		/* do nothing */;
	return ret;
  80085d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 69 ff ff ff       	call   8007dc <strlen>
  800873:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800876:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	01 c2                	add    %eax,%edx
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	89 14 24             	mov    %edx,(%esp)
  800888:	e8 a5 ff ff ff       	call   800832 <strcpy>
	return dst;
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80089e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a5:	eb 23                	jmp    8008ca <strncpy+0x38>
		*dst++ = *src;
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8d 50 01             	lea    0x1(%eax),%edx
  8008ad:	89 55 08             	mov    %edx,0x8(%ebp)
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strncpy+0x34>
			src++;
  8008c2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8008ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008cd:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008d0:	72 d5                	jb     8008a7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8008e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008e7:	74 33                	je     80091c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008e9:	eb 17                	jmp    800902 <strlcpy+0x2b>
			*dst++ = *src++;
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8d 50 01             	lea    0x1(%eax),%edx
  8008f1:	89 55 08             	mov    %edx,0x8(%ebp)
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008fa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008fd:	0f b6 12             	movzbl (%edx),%edx
  800900:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800902:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800906:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80090a:	74 0a                	je     800916 <strlcpy+0x3f>
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	0f b6 00             	movzbl (%eax),%eax
  800912:	84 c0                	test   %al,%al
  800914:	75 d5                	jne    8008eb <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80091c:	8b 55 08             	mov    0x8(%ebp),%edx
  80091f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800922:	29 c2                	sub    %eax,%edx
  800924:	89 d0                	mov    %edx,%eax
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80092b:	eb 08                	jmp    800935 <strcmp+0xd>
		p++, q++;
  80092d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800931:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 00             	movzbl (%eax),%eax
  80093b:	84 c0                	test   %al,%al
  80093d:	74 10                	je     80094f <strcmp+0x27>
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 10             	movzbl (%eax),%edx
  800945:	8b 45 0c             	mov    0xc(%ebp),%eax
  800948:	0f b6 00             	movzbl (%eax),%eax
  80094b:	38 c2                	cmp    %al,%dl
  80094d:	74 de                	je     80092d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	0f b6 00             	movzbl (%eax),%eax
  800955:	0f b6 d0             	movzbl %al,%edx
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	0f b6 00             	movzbl (%eax),%eax
  80095e:	0f b6 c0             	movzbl %al,%eax
  800961:	29 c2                	sub    %eax,%edx
  800963:	89 d0                	mov    %edx,%eax
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  80096a:	eb 0c                	jmp    800978 <strncmp+0x11>
		n--, p++, q++;
  80096c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800970:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800974:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800978:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80097c:	74 1a                	je     800998 <strncmp+0x31>
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 00             	movzbl (%eax),%eax
  800984:	84 c0                	test   %al,%al
  800986:	74 10                	je     800998 <strncmp+0x31>
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	0f b6 10             	movzbl (%eax),%edx
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800991:	0f b6 00             	movzbl (%eax),%eax
  800994:	38 c2                	cmp    %al,%dl
  800996:	74 d4                	je     80096c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800998:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80099c:	75 07                	jne    8009a5 <strncmp+0x3e>
		return 0;
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a3:	eb 16                	jmp    8009bb <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	0f b6 d0             	movzbl %al,%edx
  8009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b1:	0f b6 00             	movzbl (%eax),%eax
  8009b4:	0f b6 c0             	movzbl %al,%eax
  8009b7:	29 c2                	sub    %eax,%edx
  8009b9:	89 d0                	mov    %edx,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 04             	sub    $0x4,%esp
  8009c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009c9:	eb 14                	jmp    8009df <strchr+0x22>
		if (*s == c)
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 00             	movzbl (%eax),%eax
  8009d1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009d4:	75 05                	jne    8009db <strchr+0x1e>
			return (char *) s;
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	eb 13                	jmp    8009ee <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	0f b6 00             	movzbl (%eax),%eax
  8009e5:	84 c0                	test   %al,%al
  8009e7:	75 e2                	jne    8009cb <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	83 ec 04             	sub    $0x4,%esp
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009fc:	eb 11                	jmp    800a0f <strfind+0x1f>
		if (*s == c)
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 00             	movzbl (%eax),%eax
  800a04:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a07:	75 02                	jne    800a0b <strfind+0x1b>
			break;
  800a09:	eb 0e                	jmp    800a19 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a0b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	0f b6 00             	movzbl (%eax),%eax
  800a15:	84 c0                	test   %al,%al
  800a17:	75 e5                	jne    8009fe <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a26:	75 05                	jne    800a2d <memset+0xf>
		return v;
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	eb 5c                	jmp    800a89 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	83 e0 03             	and    $0x3,%eax
  800a33:	85 c0                	test   %eax,%eax
  800a35:	75 41                	jne    800a78 <memset+0x5a>
  800a37:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3a:	83 e0 03             	and    $0x3,%eax
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	75 37                	jne    800a78 <memset+0x5a>
		c &= 0xFF;
  800a41:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	c1 e0 18             	shl    $0x18,%eax
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a53:	c1 e0 10             	shl    $0x10,%eax
  800a56:	09 c2                	or     %eax,%edx
  800a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5b:	c1 e0 08             	shl    $0x8,%eax
  800a5e:	09 d0                	or     %edx,%eax
  800a60:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a63:	8b 45 10             	mov    0x10(%ebp),%eax
  800a66:	c1 e8 02             	shr    $0x2,%eax
  800a69:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	fc                   	cld    
  800a74:	f3 ab                	rep stos %eax,%es:(%edi)
  800a76:	eb 0e                	jmp    800a86 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a81:	89 d7                	mov    %edx,%edi
  800a83:	fc                   	cld    
  800a84:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800aa7:	73 6d                	jae    800b16 <memmove+0x8a>
  800aa9:	8b 45 10             	mov    0x10(%ebp),%eax
  800aac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800aaf:	01 d0                	add    %edx,%eax
  800ab1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ab4:	76 60                	jbe    800b16 <memmove+0x8a>
		s += n;
  800ab6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab9:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac5:	83 e0 03             	and    $0x3,%eax
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	75 2f                	jne    800afb <memmove+0x6f>
  800acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800acf:	83 e0 03             	and    $0x3,%eax
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	75 25                	jne    800afb <memmove+0x6f>
  800ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad9:	83 e0 03             	and    $0x3,%eax
  800adc:	85 c0                	test   %eax,%eax
  800ade:	75 1b                	jne    800afb <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ae3:	83 e8 04             	sub    $0x4,%eax
  800ae6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ae9:	83 ea 04             	sub    $0x4,%edx
  800aec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aef:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	fd                   	std    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb 18                	jmp    800b13 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afe:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b04:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b07:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0a:	89 d7                	mov    %edx,%edi
  800b0c:	89 de                	mov    %ebx,%esi
  800b0e:	89 c1                	mov    %eax,%ecx
  800b10:	fd                   	std    
  800b11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b13:	fc                   	cld    
  800b14:	eb 45                	jmp    800b5b <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b19:	83 e0 03             	and    $0x3,%eax
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	75 2b                	jne    800b4b <memmove+0xbf>
  800b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b23:	83 e0 03             	and    $0x3,%eax
  800b26:	85 c0                	test   %eax,%eax
  800b28:	75 21                	jne    800b4b <memmove+0xbf>
  800b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2d:	83 e0 03             	and    $0x3,%eax
  800b30:	85 c0                	test   %eax,%eax
  800b32:	75 17                	jne    800b4b <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b34:	8b 45 10             	mov    0x10(%ebp),%eax
  800b37:	c1 e8 02             	shr    $0x2,%eax
  800b3a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	fc                   	cld    
  800b47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b49:	eb 10                	jmp    800b5b <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	fc                   	cld    
  800b59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	89 04 24             	mov    %eax,(%esp)
  800b80:	e8 07 ff ff ff       	call   800a8c <memmove>
}
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b96:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800b99:	eb 30                	jmp    800bcb <memcmp+0x44>
		if (*s1 != *s2)
  800b9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b9e:	0f b6 10             	movzbl (%eax),%edx
  800ba1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ba4:	0f b6 00             	movzbl (%eax),%eax
  800ba7:	38 c2                	cmp    %al,%dl
  800ba9:	74 18                	je     800bc3 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bae:	0f b6 00             	movzbl (%eax),%eax
  800bb1:	0f b6 d0             	movzbl %al,%edx
  800bb4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bb7:	0f b6 00             	movzbl (%eax),%eax
  800bba:	0f b6 c0             	movzbl %al,%eax
  800bbd:	29 c2                	sub    %eax,%edx
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	eb 1a                	jmp    800bdd <memcmp+0x56>
		s1++, s2++;
  800bc3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800bc7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bce:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bd1:	89 55 10             	mov    %edx,0x10(%ebp)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	75 c3                	jne    800b9b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800be5:	8b 45 10             	mov    0x10(%ebp),%eax
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	01 d0                	add    %edx,%eax
  800bed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800bf0:	eb 13                	jmp    800c05 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf5:	0f b6 10             	movzbl (%eax),%edx
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfb:	38 c2                	cmp    %al,%dl
  800bfd:	75 02                	jne    800c01 <memfind+0x22>
			break;
  800bff:	eb 0c                	jmp    800c0d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c01:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c0b:	72 e5                	jb     800bf2 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c1f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c26:	eb 04                	jmp    800c2c <strtol+0x1a>
		s++;
  800c28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2f:	0f b6 00             	movzbl (%eax),%eax
  800c32:	3c 20                	cmp    $0x20,%al
  800c34:	74 f2                	je     800c28 <strtol+0x16>
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	0f b6 00             	movzbl (%eax),%eax
  800c3c:	3c 09                	cmp    $0x9,%al
  800c3e:	74 e8                	je     800c28 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c40:	8b 45 08             	mov    0x8(%ebp),%eax
  800c43:	0f b6 00             	movzbl (%eax),%eax
  800c46:	3c 2b                	cmp    $0x2b,%al
  800c48:	75 06                	jne    800c50 <strtol+0x3e>
		s++;
  800c4a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c4e:	eb 15                	jmp    800c65 <strtol+0x53>
	else if (*s == '-')
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	0f b6 00             	movzbl (%eax),%eax
  800c56:	3c 2d                	cmp    $0x2d,%al
  800c58:	75 0b                	jne    800c65 <strtol+0x53>
		s++, neg = 1;
  800c5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c5e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c69:	74 06                	je     800c71 <strtol+0x5f>
  800c6b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c6f:	75 24                	jne    800c95 <strtol+0x83>
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	0f b6 00             	movzbl (%eax),%eax
  800c77:	3c 30                	cmp    $0x30,%al
  800c79:	75 1a                	jne    800c95 <strtol+0x83>
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	83 c0 01             	add    $0x1,%eax
  800c81:	0f b6 00             	movzbl (%eax),%eax
  800c84:	3c 78                	cmp    $0x78,%al
  800c86:	75 0d                	jne    800c95 <strtol+0x83>
		s += 2, base = 16;
  800c88:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800c8c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c93:	eb 2a                	jmp    800cbf <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800c95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c99:	75 17                	jne    800cb2 <strtol+0xa0>
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	0f b6 00             	movzbl (%eax),%eax
  800ca1:	3c 30                	cmp    $0x30,%al
  800ca3:	75 0d                	jne    800cb2 <strtol+0xa0>
		s++, base = 8;
  800ca5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cb0:	eb 0d                	jmp    800cbf <strtol+0xad>
	else if (base == 0)
  800cb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb6:	75 07                	jne    800cbf <strtol+0xad>
		base = 10;
  800cb8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	0f b6 00             	movzbl (%eax),%eax
  800cc5:	3c 2f                	cmp    $0x2f,%al
  800cc7:	7e 1b                	jle    800ce4 <strtol+0xd2>
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	0f b6 00             	movzbl (%eax),%eax
  800ccf:	3c 39                	cmp    $0x39,%al
  800cd1:	7f 11                	jg     800ce4 <strtol+0xd2>
			dig = *s - '0';
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	0f b6 00             	movzbl (%eax),%eax
  800cd9:	0f be c0             	movsbl %al,%eax
  800cdc:	83 e8 30             	sub    $0x30,%eax
  800cdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ce2:	eb 48                	jmp    800d2c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	0f b6 00             	movzbl (%eax),%eax
  800cea:	3c 60                	cmp    $0x60,%al
  800cec:	7e 1b                	jle    800d09 <strtol+0xf7>
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 00             	movzbl (%eax),%eax
  800cf4:	3c 7a                	cmp    $0x7a,%al
  800cf6:	7f 11                	jg     800d09 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	0f b6 00             	movzbl (%eax),%eax
  800cfe:	0f be c0             	movsbl %al,%eax
  800d01:	83 e8 57             	sub    $0x57,%eax
  800d04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d07:	eb 23                	jmp    800d2c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	0f b6 00             	movzbl (%eax),%eax
  800d0f:	3c 40                	cmp    $0x40,%al
  800d11:	7e 3d                	jle    800d50 <strtol+0x13e>
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	0f b6 00             	movzbl (%eax),%eax
  800d19:	3c 5a                	cmp    $0x5a,%al
  800d1b:	7f 33                	jg     800d50 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	0f b6 00             	movzbl (%eax),%eax
  800d23:	0f be c0             	movsbl %al,%eax
  800d26:	83 e8 37             	sub    $0x37,%eax
  800d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d2f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d32:	7c 02                	jl     800d36 <strtol+0x124>
			break;
  800d34:	eb 1a                	jmp    800d50 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d3d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d41:	89 c2                	mov    %eax,%edx
  800d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d46:	01 d0                	add    %edx,%eax
  800d48:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d4b:	e9 6f ff ff ff       	jmp    800cbf <strtol+0xad>

	if (endptr)
  800d50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d54:	74 08                	je     800d5e <strtol+0x14c>
		*endptr = (char *) s;
  800d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d5e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d62:	74 07                	je     800d6b <strtol+0x159>
  800d64:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d67:	f7 d8                	neg    %eax
  800d69:	eb 03                	jmp    800d6e <strtol+0x15c>
  800d6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8b 55 10             	mov    0x10(%ebp),%edx
  800d7f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d82:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800d85:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800d88:	8b 75 20             	mov    0x20(%ebp),%esi
  800d8b:	cd 30                	int    $0x30
  800d8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d94:	74 30                	je     800dc6 <syscall+0x56>
  800d96:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d9a:	7e 2a                	jle    800dc6 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800daa:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800db1:	00 
  800db2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db9:	00 
  800dba:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800dc1:	e8 b3 03 00 00       	call   801179 <_panic>

	return ret;
  800dc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800dc9:	83 c4 3c             	add    $0x3c,%esp
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800de1:	00 
  800de2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800de9:	00 
  800dea:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800df1:	00 
  800df2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800df9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e04:	00 
  800e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e0c:	e8 5f ff ff ff       	call   800d70 <syscall>
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e19:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e20:	00 
  800e21:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e28:	00 
  800e29:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e30:	00 
  800e31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e50:	e8 1b ff ff ff       	call   800d70 <syscall>
}
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e67:	00 
  800e68:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e6f:	00 
  800e70:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e77:	00 
  800e78:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e7f:	00 
  800e80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e84:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800e93:	e8 d8 fe ff ff       	call   800d70 <syscall>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ea0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ecf:	00 
  800ed0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ed7:	e8 94 fe ff ff       	call   800d70 <syscall>
}
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <sys_yield>:

void
sys_yield(void)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ee4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eeb:	00 
  800eec:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800efb:	00 
  800efc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f03:	00 
  800f04:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f13:	00 
  800f14:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f1b:	e8 50 fe ff ff       	call   800d70 <syscall>
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f28:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f38:	00 
  800f39:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f40:	00 
  800f41:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f45:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f49:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f4d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f5c:	e8 0f fe ff ff       	call   800d70 <syscall>
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800f6e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f71:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f7e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800f82:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f86:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f95:	00 
  800f96:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800f9d:	e8 ce fd ff ff       	call   800d70 <syscall>
}
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800faf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fc4:	00 
  800fc5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fcc:	00 
  800fcd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800fe4:	e8 87 fd ff ff       	call   800d70 <syscall>
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ffe:	00 
  800fff:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801006:	00 
  801007:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80100e:	00 
  80100f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801013:	89 44 24 08          	mov    %eax,0x8(%esp)
  801017:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80101e:	00 
  80101f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801026:	e8 45 fd ff ff       	call   800d70 <syscall>
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801033:	8b 55 0c             	mov    0xc(%ebp),%edx
  801036:	8b 45 08             	mov    0x8(%ebp),%eax
  801039:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801040:	00 
  801041:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801048:	00 
  801049:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801050:	00 
  801051:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801055:	89 44 24 08          	mov    %eax,0x8(%esp)
  801059:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801060:	00 
  801061:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801068:	e8 03 fd ff ff       	call   800d70 <syscall>
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801075:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801078:	8b 55 10             	mov    0x10(%ebp),%edx
  80107b:	8b 45 08             	mov    0x8(%ebp),%eax
  80107e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801085:	00 
  801086:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80108a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80108e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801091:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801095:	89 44 24 08          	mov    %eax,0x8(%esp)
  801099:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a0:	00 
  8010a1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010a8:	e8 c3 fc ff ff       	call   800d70 <syscall>
}
  8010ad:	c9                   	leave  
  8010ae:	c3                   	ret    

008010af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010c7:	00 
  8010c8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010cf:	00 
  8010d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d7:	00 
  8010d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010dc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8010eb:	e8 80 fc ff ff       	call   800d70 <syscall>
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <sys_exec>:

void sys_exec(char* buf){
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801102:	00 
  801103:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80110a:	00 
  80110b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801112:	00 
  801113:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80111a:	00 
  80111b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801126:	00 
  801127:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80112e:	e8 3d fc ff ff       	call   800d70 <syscall>
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <sys_wait>:

void sys_wait(){
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80113b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801142:	00 
  801143:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114a:	00 
  80114b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801152:	00 
  801153:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80115a:	00 
  80115b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801172:	e8 f9 fb ff ff       	call   800d70 <syscall>
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	53                   	push   %ebx
  80117d:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801180:	8d 45 14             	lea    0x14(%ebp),%eax
  801183:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801186:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80118c:	e8 09 fd ff ff       	call   800e9a <sys_getenvid>
  801191:	8b 55 0c             	mov    0xc(%ebp),%edx
  801194:	89 54 24 10          	mov    %edx,0x10(%esp)
  801198:	8b 55 08             	mov    0x8(%ebp),%edx
  80119b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80119f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a7:	c7 04 24 30 17 80 00 	movl   $0x801730,(%esp)
  8011ae:	e8 b2 ef ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bd:	89 04 24             	mov    %eax,(%esp)
  8011c0:	e8 3c ef ff ff       	call   800101 <vcprintf>
	cprintf("\n");
  8011c5:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  8011cc:	e8 94 ef ff ff       	call   800165 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011d1:	cc                   	int3   
  8011d2:	eb fd                	jmp    8011d1 <_panic+0x58>
  8011d4:	66 90                	xchg   %ax,%ax
  8011d6:	66 90                	xchg   %ax,%ax
  8011d8:	66 90                	xchg   %ax,%ax
  8011da:	66 90                	xchg   %ax,%ax
  8011dc:	66 90                	xchg   %ax,%ax
  8011de:	66 90                	xchg   %ax,%ax

008011e0 <__udivdi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011fc:	89 ea                	mov    %ebp,%edx
  8011fe:	89 0c 24             	mov    %ecx,(%esp)
  801201:	75 2d                	jne    801230 <__udivdi3+0x50>
  801203:	39 e9                	cmp    %ebp,%ecx
  801205:	77 61                	ja     801268 <__udivdi3+0x88>
  801207:	85 c9                	test   %ecx,%ecx
  801209:	89 ce                	mov    %ecx,%esi
  80120b:	75 0b                	jne    801218 <__udivdi3+0x38>
  80120d:	b8 01 00 00 00       	mov    $0x1,%eax
  801212:	31 d2                	xor    %edx,%edx
  801214:	f7 f1                	div    %ecx
  801216:	89 c6                	mov    %eax,%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	89 e8                	mov    %ebp,%eax
  80121c:	f7 f6                	div    %esi
  80121e:	89 c5                	mov    %eax,%ebp
  801220:	89 f8                	mov    %edi,%eax
  801222:	f7 f6                	div    %esi
  801224:	89 ea                	mov    %ebp,%edx
  801226:	83 c4 0c             	add    $0xc,%esp
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    
  80122d:	8d 76 00             	lea    0x0(%esi),%esi
  801230:	39 e8                	cmp    %ebp,%eax
  801232:	77 24                	ja     801258 <__udivdi3+0x78>
  801234:	0f bd e8             	bsr    %eax,%ebp
  801237:	83 f5 1f             	xor    $0x1f,%ebp
  80123a:	75 3c                	jne    801278 <__udivdi3+0x98>
  80123c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801240:	39 34 24             	cmp    %esi,(%esp)
  801243:	0f 86 9f 00 00 00    	jbe    8012e8 <__udivdi3+0x108>
  801249:	39 d0                	cmp    %edx,%eax
  80124b:	0f 82 97 00 00 00    	jb     8012e8 <__udivdi3+0x108>
  801251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	31 c0                	xor    %eax,%eax
  80125c:	83 c4 0c             	add    $0xc,%esp
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
  801263:	90                   	nop
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	89 f8                	mov    %edi,%eax
  80126a:	f7 f1                	div    %ecx
  80126c:	31 d2                	xor    %edx,%edx
  80126e:	83 c4 0c             	add    $0xc,%esp
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
  801275:	8d 76 00             	lea    0x0(%esi),%esi
  801278:	89 e9                	mov    %ebp,%ecx
  80127a:	8b 3c 24             	mov    (%esp),%edi
  80127d:	d3 e0                	shl    %cl,%eax
  80127f:	89 c6                	mov    %eax,%esi
  801281:	b8 20 00 00 00       	mov    $0x20,%eax
  801286:	29 e8                	sub    %ebp,%eax
  801288:	89 c1                	mov    %eax,%ecx
  80128a:	d3 ef                	shr    %cl,%edi
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801292:	8b 3c 24             	mov    (%esp),%edi
  801295:	09 74 24 08          	or     %esi,0x8(%esp)
  801299:	89 d6                	mov    %edx,%esi
  80129b:	d3 e7                	shl    %cl,%edi
  80129d:	89 c1                	mov    %eax,%ecx
  80129f:	89 3c 24             	mov    %edi,(%esp)
  8012a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012a6:	d3 ee                	shr    %cl,%esi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	d3 e2                	shl    %cl,%edx
  8012ac:	89 c1                	mov    %eax,%ecx
  8012ae:	d3 ef                	shr    %cl,%edi
  8012b0:	09 d7                	or     %edx,%edi
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	f7 74 24 08          	divl   0x8(%esp)
  8012ba:	89 d6                	mov    %edx,%esi
  8012bc:	89 c7                	mov    %eax,%edi
  8012be:	f7 24 24             	mull   (%esp)
  8012c1:	39 d6                	cmp    %edx,%esi
  8012c3:	89 14 24             	mov    %edx,(%esp)
  8012c6:	72 30                	jb     8012f8 <__udivdi3+0x118>
  8012c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	39 c2                	cmp    %eax,%edx
  8012d2:	73 05                	jae    8012d9 <__udivdi3+0xf9>
  8012d4:	3b 34 24             	cmp    (%esp),%esi
  8012d7:	74 1f                	je     8012f8 <__udivdi3+0x118>
  8012d9:	89 f8                	mov    %edi,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	e9 7a ff ff ff       	jmp    80125c <__udivdi3+0x7c>
  8012e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ef:	e9 68 ff ff ff       	jmp    80125c <__udivdi3+0x7c>
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	83 c4 0c             	add    $0xc,%esp
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
  801304:	66 90                	xchg   %ax,%ax
  801306:	66 90                	xchg   %ax,%ax
  801308:	66 90                	xchg   %ax,%ax
  80130a:	66 90                	xchg   %ax,%ax
  80130c:	66 90                	xchg   %ax,%ax
  80130e:	66 90                	xchg   %ax,%ax

00801310 <__umoddi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80131a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80131e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801322:	89 c7                	mov    %eax,%edi
  801324:	89 44 24 04          	mov    %eax,0x4(%esp)
  801328:	8b 44 24 30          	mov    0x30(%esp),%eax
  80132c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801330:	89 34 24             	mov    %esi,(%esp)
  801333:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801337:	85 c0                	test   %eax,%eax
  801339:	89 c2                	mov    %eax,%edx
  80133b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80133f:	75 17                	jne    801358 <__umoddi3+0x48>
  801341:	39 fe                	cmp    %edi,%esi
  801343:	76 4b                	jbe    801390 <__umoddi3+0x80>
  801345:	89 c8                	mov    %ecx,%eax
  801347:	89 fa                	mov    %edi,%edx
  801349:	f7 f6                	div    %esi
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	31 d2                	xor    %edx,%edx
  80134f:	83 c4 14             	add    $0x14,%esp
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    
  801356:	66 90                	xchg   %ax,%ax
  801358:	39 f8                	cmp    %edi,%eax
  80135a:	77 54                	ja     8013b0 <__umoddi3+0xa0>
  80135c:	0f bd e8             	bsr    %eax,%ebp
  80135f:	83 f5 1f             	xor    $0x1f,%ebp
  801362:	75 5c                	jne    8013c0 <__umoddi3+0xb0>
  801364:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801368:	39 3c 24             	cmp    %edi,(%esp)
  80136b:	0f 87 e7 00 00 00    	ja     801458 <__umoddi3+0x148>
  801371:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801375:	29 f1                	sub    %esi,%ecx
  801377:	19 c7                	sbb    %eax,%edi
  801379:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801381:	8b 44 24 08          	mov    0x8(%esp),%eax
  801385:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801389:	83 c4 14             	add    $0x14,%esp
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    
  801390:	85 f6                	test   %esi,%esi
  801392:	89 f5                	mov    %esi,%ebp
  801394:	75 0b                	jne    8013a1 <__umoddi3+0x91>
  801396:	b8 01 00 00 00       	mov    $0x1,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	f7 f6                	div    %esi
  80139f:	89 c5                	mov    %eax,%ebp
  8013a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013a5:	31 d2                	xor    %edx,%edx
  8013a7:	f7 f5                	div    %ebp
  8013a9:	89 c8                	mov    %ecx,%eax
  8013ab:	f7 f5                	div    %ebp
  8013ad:	eb 9c                	jmp    80134b <__umoddi3+0x3b>
  8013af:	90                   	nop
  8013b0:	89 c8                	mov    %ecx,%eax
  8013b2:	89 fa                	mov    %edi,%edx
  8013b4:	83 c4 14             	add    $0x14,%esp
  8013b7:	5e                   	pop    %esi
  8013b8:	5f                   	pop    %edi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    
  8013bb:	90                   	nop
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	8b 04 24             	mov    (%esp),%eax
  8013c3:	be 20 00 00 00       	mov    $0x20,%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	29 ee                	sub    %ebp,%esi
  8013cc:	d3 e2                	shl    %cl,%edx
  8013ce:	89 f1                	mov    %esi,%ecx
  8013d0:	d3 e8                	shr    %cl,%eax
  8013d2:	89 e9                	mov    %ebp,%ecx
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 04 24             	mov    (%esp),%eax
  8013db:	09 54 24 04          	or     %edx,0x4(%esp)
  8013df:	89 fa                	mov    %edi,%edx
  8013e1:	d3 e0                	shl    %cl,%eax
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ed:	d3 ea                	shr    %cl,%edx
  8013ef:	89 e9                	mov    %ebp,%ecx
  8013f1:	d3 e7                	shl    %cl,%edi
  8013f3:	89 f1                	mov    %esi,%ecx
  8013f5:	d3 e8                	shr    %cl,%eax
  8013f7:	89 e9                	mov    %ebp,%ecx
  8013f9:	09 f8                	or     %edi,%eax
  8013fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013ff:	f7 74 24 04          	divl   0x4(%esp)
  801403:	d3 e7                	shl    %cl,%edi
  801405:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801409:	89 d7                	mov    %edx,%edi
  80140b:	f7 64 24 08          	mull   0x8(%esp)
  80140f:	39 d7                	cmp    %edx,%edi
  801411:	89 c1                	mov    %eax,%ecx
  801413:	89 14 24             	mov    %edx,(%esp)
  801416:	72 2c                	jb     801444 <__umoddi3+0x134>
  801418:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80141c:	72 22                	jb     801440 <__umoddi3+0x130>
  80141e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801422:	29 c8                	sub    %ecx,%eax
  801424:	19 d7                	sbb    %edx,%edi
  801426:	89 e9                	mov    %ebp,%ecx
  801428:	89 fa                	mov    %edi,%edx
  80142a:	d3 e8                	shr    %cl,%eax
  80142c:	89 f1                	mov    %esi,%ecx
  80142e:	d3 e2                	shl    %cl,%edx
  801430:	89 e9                	mov    %ebp,%ecx
  801432:	d3 ef                	shr    %cl,%edi
  801434:	09 d0                	or     %edx,%eax
  801436:	89 fa                	mov    %edi,%edx
  801438:	83 c4 14             	add    $0x14,%esp
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    
  80143f:	90                   	nop
  801440:	39 d7                	cmp    %edx,%edi
  801442:	75 da                	jne    80141e <__umoddi3+0x10e>
  801444:	8b 14 24             	mov    (%esp),%edx
  801447:	89 c1                	mov    %eax,%ecx
  801449:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80144d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801451:	eb cb                	jmp    80141e <__umoddi3+0x10e>
  801453:	90                   	nop
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80145c:	0f 82 0f ff ff ff    	jb     801371 <__umoddi3+0x61>
  801462:	e9 1a ff ff ff       	jmp    801381 <__umoddi3+0x71>
