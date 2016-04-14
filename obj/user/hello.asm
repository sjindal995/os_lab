
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2e 00 00 00       	call   80005f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  800039:	c7 04 24 40 14 80 00 	movl   $0x801440,(%esp)
  800040:	e8 3d 01 00 00       	call   800182 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800045:	a1 04 20 80 00       	mov    0x802004,%eax
  80004a:	8b 40 48             	mov    0x48(%eax),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	c7 04 24 4e 14 80 00 	movl   $0x80144e,(%esp)
  800058:	e8 25 01 00 00       	call   800182 <cprintf>
}
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800065:	e8 4d 0e 00 00       	call   800eb7 <sys_getenvid>
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	c1 e0 02             	shl    $0x2,%eax
  800072:	89 c2                	mov    %eax,%edx
  800074:	c1 e2 05             	shl    $0x5,%edx
  800077:	29 c2                	sub    %eax,%edx
  800079:	89 d0                	mov    %edx,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800089:	7e 0a                	jle    800095 <libmain+0x36>
		binaryname = argv[0];
  80008b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80008e:	8b 00                	mov    (%eax),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	8b 45 0c             	mov    0xc(%ebp),%eax
  800098:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009c:	8b 45 08             	mov    0x8(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 8c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a7:	e8 02 00 00 00       	call   8000ae <exit>
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bb:	e8 b4 0d 00 00       	call   800e74 <sys_env_destroy>
}
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000cb:	8b 00                	mov    (%eax),%eax
  8000cd:	8d 48 01             	lea    0x1(%eax),%ecx
  8000d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000d3:	89 0a                	mov    %ecx,(%edx)
  8000d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000dd:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	8b 00                	mov    (%eax),%eax
  8000e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000eb:	75 20                	jne    80010d <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f0:	8b 00                	mov    (%eax),%eax
  8000f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000f5:	83 c2 08             	add    $0x8,%edx
  8000f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fc:	89 14 24             	mov    %edx,(%esp)
  8000ff:	e8 ea 0c 00 00       	call   800dee <sys_cputs>
		b->idx = 0;
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80010d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800110:	8b 40 04             	mov    0x4(%eax),%eax
  800113:	8d 50 01             	lea    0x1(%eax),%edx
  800116:	8b 45 0c             	mov    0xc(%ebp),%eax
  800119:	89 50 04             	mov    %edx,0x4(%eax)
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800127:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012e:	00 00 00 
	b.cnt = 0;
  800131:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800138:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 45 08             	mov    0x8(%ebp),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800153:	c7 04 24 c2 00 80 00 	movl   $0x8000c2,(%esp)
  80015a:	e8 bd 01 00 00       	call   80031c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016f:	83 c0 08             	add    $0x8,%eax
  800172:	89 04 24             	mov    %eax,(%esp)
  800175:	e8 74 0c 00 00       	call   800dee <sys_cputs>

	return b.cnt;
  80017a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    

00800182 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800188:	8d 45 0c             	lea    0xc(%ebp),%eax
  80018b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80018e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800191:	89 44 24 04          	mov    %eax,0x4(%esp)
  800195:	8b 45 08             	mov    0x8(%ebp),%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 7e ff ff ff       	call   80011e <vcprintf>
  8001a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 34             	sub    $0x34,%esp
  8001af:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bb:	8b 45 18             	mov    0x18(%ebp),%eax
  8001be:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001c6:	77 72                	ja     80023a <printnum+0x92>
  8001c8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001cb:	72 05                	jb     8001d2 <printnum+0x2a>
  8001cd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001d0:	77 68                	ja     80023a <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001d5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d8:	8b 45 18             	mov    0x18(%ebp),%eax
  8001db:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f5:	e8 b6 0f 00 00       	call   8011b0 <__udivdi3>
  8001fa:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001fd:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800201:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800205:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800208:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
  800217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021b:	8b 45 08             	mov    0x8(%ebp),%eax
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	e8 82 ff ff ff       	call   8001a8 <printnum>
  800226:	eb 1c                	jmp    800244 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022f:	8b 45 20             	mov    0x20(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023a:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80023e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800242:	7f e4                	jg     800228 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800247:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800252:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800256:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800261:	e8 7a 10 00 00       	call   8012e0 <__umoddi3>
  800266:	05 48 15 80 00       	add    $0x801548,%eax
  80026b:	0f b6 00             	movzbl (%eax),%eax
  80026e:	0f be c0             	movsbl %al,%eax
  800271:	8b 55 0c             	mov    0xc(%ebp),%edx
  800274:	89 54 24 04          	mov    %edx,0x4(%esp)
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	ff d0                	call   *%eax
}
  800280:	83 c4 34             	add    $0x34,%esp
  800283:	5b                   	pop    %ebx
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80028d:	7e 14                	jle    8002a3 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	8b 00                	mov    (%eax),%eax
  800294:	8d 48 08             	lea    0x8(%eax),%ecx
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 0a                	mov    %ecx,(%edx)
  80029c:	8b 50 04             	mov    0x4(%eax),%edx
  80029f:	8b 00                	mov    (%eax),%eax
  8002a1:	eb 30                	jmp    8002d3 <getuint+0x4d>
	else if (lflag)
  8002a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002a7:	74 16                	je     8002bf <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	8b 00                	mov    (%eax),%eax
  8002ae:	8d 48 04             	lea    0x4(%eax),%ecx
  8002b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b4:	89 0a                	mov    %ecx,(%edx)
  8002b6:	8b 00                	mov    (%eax),%eax
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bd:	eb 14                	jmp    8002d3 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	8b 00                	mov    (%eax),%eax
  8002c4:	8d 48 04             	lea    0x4(%eax),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 0a                	mov    %ecx,(%edx)
  8002cc:	8b 00                	mov    (%eax),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002dc:	7e 14                	jle    8002f2 <getint+0x1d>
		return va_arg(*ap, long long);
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	8d 48 08             	lea    0x8(%eax),%ecx
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	89 0a                	mov    %ecx,(%edx)
  8002eb:	8b 50 04             	mov    0x4(%eax),%edx
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	eb 28                	jmp    80031a <getint+0x45>
	else if (lflag)
  8002f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002f6:	74 12                	je     80030a <getint+0x35>
		return va_arg(*ap, long);
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	8b 00                	mov    (%eax),%eax
  8002fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	89 0a                	mov    %ecx,(%edx)
  800305:	8b 00                	mov    (%eax),%eax
  800307:	99                   	cltd   
  800308:	eb 10                	jmp    80031a <getint+0x45>
	else
		return va_arg(*ap, int);
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	8b 00                	mov    (%eax),%eax
  80030f:	8d 48 04             	lea    0x4(%eax),%ecx
  800312:	8b 55 08             	mov    0x8(%ebp),%edx
  800315:	89 0a                	mov    %ecx,(%edx)
  800317:	8b 00                	mov    (%eax),%eax
  800319:	99                   	cltd   
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800324:	eb 18                	jmp    80033e <vprintfmt+0x22>
			if (ch == '\0')
  800326:	85 db                	test   %ebx,%ebx
  800328:	75 05                	jne    80032f <vprintfmt+0x13>
				return;
  80032a:	e9 cc 03 00 00       	jmp    8006fb <vprintfmt+0x3df>
			putch(ch, putdat);
  80032f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800332:	89 44 24 04          	mov    %eax,0x4(%esp)
  800336:	89 1c 24             	mov    %ebx,(%esp)
  800339:	8b 45 08             	mov    0x8(%ebp),%eax
  80033c:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033e:	8b 45 10             	mov    0x10(%ebp),%eax
  800341:	8d 50 01             	lea    0x1(%eax),%edx
  800344:	89 55 10             	mov    %edx,0x10(%ebp)
  800347:	0f b6 00             	movzbl (%eax),%eax
  80034a:	0f b6 d8             	movzbl %al,%ebx
  80034d:	83 fb 25             	cmp    $0x25,%ebx
  800350:	75 d4                	jne    800326 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800352:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800356:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80035d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800364:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80036b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 45 10             	mov    0x10(%ebp),%eax
  800375:	8d 50 01             	lea    0x1(%eax),%edx
  800378:	89 55 10             	mov    %edx,0x10(%ebp)
  80037b:	0f b6 00             	movzbl (%eax),%eax
  80037e:	0f b6 d8             	movzbl %al,%ebx
  800381:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800384:	83 f8 55             	cmp    $0x55,%eax
  800387:	0f 87 3d 03 00 00    	ja     8006ca <vprintfmt+0x3ae>
  80038d:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800394:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800396:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80039a:	eb d6                	jmp    800372 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003a0:	eb d0                	jmp    800372 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003ac:	89 d0                	mov    %edx,%eax
  8003ae:	c1 e0 02             	shl    $0x2,%eax
  8003b1:	01 d0                	add    %edx,%eax
  8003b3:	01 c0                	add    %eax,%eax
  8003b5:	01 d8                	add    %ebx,%eax
  8003b7:	83 e8 30             	sub    $0x30,%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c0:	0f b6 00             	movzbl (%eax),%eax
  8003c3:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003c6:	83 fb 2f             	cmp    $0x2f,%ebx
  8003c9:	7e 0b                	jle    8003d6 <vprintfmt+0xba>
  8003cb:	83 fb 39             	cmp    $0x39,%ebx
  8003ce:	7f 06                	jg     8003d6 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d4:	eb d3                	jmp    8003a9 <vprintfmt+0x8d>
			goto process_precision;
  8003d6:	eb 33                	jmp    80040b <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 50 04             	lea    0x4(%eax),%edx
  8003de:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003e6:	eb 23                	jmp    80040b <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ec:	79 0c                	jns    8003fa <vprintfmt+0xde>
				width = 0;
  8003ee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003f5:	e9 78 ff ff ff       	jmp    800372 <vprintfmt+0x56>
  8003fa:	e9 73 ff ff ff       	jmp    800372 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003ff:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800406:	e9 67 ff ff ff       	jmp    800372 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80040b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040f:	79 12                	jns    800423 <vprintfmt+0x107>
				width = precision, precision = -1;
  800411:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800414:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800417:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80041e:	e9 4f ff ff ff       	jmp    800372 <vprintfmt+0x56>
  800423:	e9 4a ff ff ff       	jmp    800372 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800428:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80042c:	e9 41 ff ff ff       	jmp    800372 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	8b 45 08             	mov    0x8(%ebp),%eax
  800449:	ff d0                	call   *%eax
			break;
  80044b:	e9 a5 02 00 00       	jmp    8006f5 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80045b:	85 db                	test   %ebx,%ebx
  80045d:	79 02                	jns    800461 <vprintfmt+0x145>
				err = -err;
  80045f:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800461:	83 fb 09             	cmp    $0x9,%ebx
  800464:	7f 0b                	jg     800471 <vprintfmt+0x155>
  800466:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  80046d:	85 f6                	test   %esi,%esi
  80046f:	75 23                	jne    800494 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80047c:	00 
  80047d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800480:	89 44 24 04          	mov    %eax,0x4(%esp)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	e8 73 02 00 00       	call   800702 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80048f:	e9 61 02 00 00       	jmp    8006f5 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800494:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800498:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80049f:	00 
  8004a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	e8 50 02 00 00       	call   800702 <printfmt>
			break;
  8004b2:	e9 3e 02 00 00       	jmp    8006f5 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 50 04             	lea    0x4(%eax),%edx
  8004bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c0:	8b 30                	mov    (%eax),%esi
  8004c2:	85 f6                	test   %esi,%esi
  8004c4:	75 05                	jne    8004cb <vprintfmt+0x1af>
				p = "(null)";
  8004c6:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8004cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cf:	7e 37                	jle    800508 <vprintfmt+0x1ec>
  8004d1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004d5:	74 31                	je     800508 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004de:	89 34 24             	mov    %esi,(%esp)
  8004e1:	e8 39 03 00 00       	call   80081f <strnlen>
  8004e6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004e9:	eb 17                	jmp    800502 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004eb:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f6:	89 04 24             	mov    %eax,(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800502:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800506:	7f e3                	jg     8004eb <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	eb 38                	jmp    800542 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050e:	74 1f                	je     80052f <vprintfmt+0x213>
  800510:	83 fb 1f             	cmp    $0x1f,%ebx
  800513:	7e 05                	jle    80051a <vprintfmt+0x1fe>
  800515:	83 fb 7e             	cmp    $0x7e,%ebx
  800518:	7e 15                	jle    80052f <vprintfmt+0x213>
					putch('?', putdat);
  80051a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800528:	8b 45 08             	mov    0x8(%ebp),%eax
  80052b:	ff d0                	call   *%eax
  80052d:	eb 0f                	jmp    80053e <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80052f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	89 1c 24             	mov    %ebx,(%esp)
  800539:	8b 45 08             	mov    0x8(%ebp),%eax
  80053c:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800542:	89 f0                	mov    %esi,%eax
  800544:	8d 70 01             	lea    0x1(%eax),%esi
  800547:	0f b6 00             	movzbl (%eax),%eax
  80054a:	0f be d8             	movsbl %al,%ebx
  80054d:	85 db                	test   %ebx,%ebx
  80054f:	74 10                	je     800561 <vprintfmt+0x245>
  800551:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800555:	78 b3                	js     80050a <vprintfmt+0x1ee>
  800557:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80055b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055f:	79 a9                	jns    80050a <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800561:	eb 17                	jmp    80057a <vprintfmt+0x25e>
				putch(' ', putdat);
  800563:	8b 45 0c             	mov    0xc(%ebp),%eax
  800566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800571:	8b 45 08             	mov    0x8(%ebp),%eax
  800574:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800576:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80057a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057e:	7f e3                	jg     800563 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800580:	e9 70 01 00 00       	jmp    8006f5 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800585:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 3e fd ff ff       	call   8002d5 <getint>
  800597:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80059a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80059d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a3:	85 d2                	test   %edx,%edx
  8005a5:	79 26                	jns    8005cd <vprintfmt+0x2b1>
				putch('-', putdat);
  8005a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ae:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	ff d0                	call   *%eax
				num = -(long long) num;
  8005ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005c0:	f7 d8                	neg    %eax
  8005c2:	83 d2 00             	adc    $0x0,%edx
  8005c5:	f7 da                	neg    %edx
  8005c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005cd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005d4:	e9 a8 00 00 00       	jmp    800681 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 9b fc ff ff       	call   800286 <getuint>
  8005eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ee:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005f1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005f8:	e9 84 00 00 00       	jmp    800681 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	e8 77 fc ff ff       	call   800286 <getuint>
  80060f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800612:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800615:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80061c:	eb 63                	jmp    800681 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80061e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800621:	89 44 24 04          	mov    %eax,0x4(%esp)
  800625:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	ff d0                	call   *%eax
			putch('x', putdat);
  800631:	8b 45 0c             	mov    0xc(%ebp),%eax
  800634:	89 44 24 04          	mov    %eax,0x4(%esp)
  800638:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80063f:	8b 45 08             	mov    0x8(%ebp),%eax
  800642:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800659:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800660:	eb 1f                	jmp    800681 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800662:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800665:	89 44 24 04          	mov    %eax,0x4(%esp)
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	e8 12 fc ff ff       	call   800286 <getuint>
  800674:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800677:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80067a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800681:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800688:	89 54 24 18          	mov    %edx,0x18(%esp)
  80068c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800693:	89 44 24 10          	mov    %eax,0x10(%esp)
  800697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80069d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	e8 f1 fa ff ff       	call   8001a8 <printnum>
			break;
  8006b7:	eb 3c                	jmp    8006f5 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c0:	89 1c 24             	mov    %ebx,(%esp)
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	ff d0                	call   *%eax
			break;
  8006c8:	eb 2b                	jmp    8006f5 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006e1:	eb 04                	jmp    8006e7 <vprintfmt+0x3cb>
  8006e3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ea:	83 e8 01             	sub    $0x1,%eax
  8006ed:	0f b6 00             	movzbl (%eax),%eax
  8006f0:	3c 25                	cmp    $0x25,%al
  8006f2:	75 ef                	jne    8006e3 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8006f4:	90                   	nop
		}
	}
  8006f5:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f6:	e9 43 fc ff ff       	jmp    80033e <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006fb:	83 c4 40             	add    $0x40,%esp
  8006fe:	5b                   	pop    %ebx
  8006ff:	5e                   	pop    %esi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800708:	8d 45 14             	lea    0x14(%ebp),%eax
  80070b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800711:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800715:	8b 45 10             	mov    0x10(%ebp),%eax
  800718:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	89 04 24             	mov    %eax,(%esp)
  800729:	e8 ee fb ff ff       	call   80031c <vprintfmt>
	va_end(ap);
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800733:	8b 45 0c             	mov    0xc(%ebp),%eax
  800736:	8b 40 08             	mov    0x8(%eax),%eax
  800739:	8d 50 01             	lea    0x1(%eax),%edx
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073f:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074a:	8b 40 04             	mov    0x4(%eax),%eax
  80074d:	39 c2                	cmp    %eax,%edx
  80074f:	73 12                	jae    800763 <sprintputch+0x33>
		*b->buf++ = ch;
  800751:	8b 45 0c             	mov    0xc(%ebp),%eax
  800754:	8b 00                	mov    (%eax),%eax
  800756:	8d 48 01             	lea    0x1(%eax),%ecx
  800759:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075c:	89 0a                	mov    %ecx,(%edx)
  80075e:	8b 55 08             	mov    0x8(%ebp),%edx
  800761:	88 10                	mov    %dl,(%eax)
}
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	8d 50 ff             	lea    -0x1(%eax),%edx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	01 d0                	add    %edx,%eax
  80077c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800786:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80078a:	74 06                	je     800792 <vsnprintf+0x2d>
  80078c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800790:	7f 07                	jg     800799 <vsnprintf+0x34>
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800797:	eb 2a                	jmp    8007c3 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ae:	c7 04 24 30 07 80 00 	movl   $0x800730,(%esp)
  8007b5:	e8 62 fb ff ff       	call   80031c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	89 04 24             	mov    %eax,(%esp)
  8007ec:	e8 74 ff ff ff       	call   800765 <vsnprintf>
  8007f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8007f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800806:	eb 08                	jmp    800810 <strlen+0x17>
		n++;
  800808:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	0f b6 00             	movzbl (%eax),%eax
  800816:	84 c0                	test   %al,%al
  800818:	75 ee                	jne    800808 <strlen+0xf>
		n++;
	return n;
  80081a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800825:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80082c:	eb 0c                	jmp    80083a <strnlen+0x1b>
		n++;
  80082e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800832:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800836:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80083a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80083e:	74 0a                	je     80084a <strnlen+0x2b>
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	84 c0                	test   %al,%al
  800848:	75 e4                	jne    80082e <strnlen+0xf>
		n++;
	return n;
  80084a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80085b:	90                   	nop
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8d 50 01             	lea    0x1(%eax),%edx
  800862:	89 55 08             	mov    %edx,0x8(%ebp)
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
  800868:	8d 4a 01             	lea    0x1(%edx),%ecx
  80086b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	88 10                	mov    %dl,(%eax)
  800873:	0f b6 00             	movzbl (%eax),%eax
  800876:	84 c0                	test   %al,%al
  800878:	75 e2                	jne    80085c <strcpy+0xd>
		/* do nothing */;
	return ret;
  80087a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	e8 69 ff ff ff       	call   8007f9 <strlen>
  800890:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800893:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	01 c2                	add    %eax,%edx
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a2:	89 14 24             	mov    %edx,(%esp)
  8008a5:	e8 a5 ff ff ff       	call   80084f <strcpy>
	return dst;
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    

008008af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008bb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008c2:	eb 23                	jmp    8008e7 <strncpy+0x38>
		*dst++ = *src;
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8d 50 01             	lea    0x1(%eax),%edx
  8008ca:	89 55 08             	mov    %edx,0x8(%ebp)
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	0f b6 00             	movzbl (%eax),%eax
  8008db:	84 c0                	test   %al,%al
  8008dd:	74 04                	je     8008e3 <strncpy+0x34>
			src++;
  8008df:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8008e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ea:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008ed:	72 d5                	jb     8008c4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800900:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800904:	74 33                	je     800939 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800906:	eb 17                	jmp    80091f <strlcpy+0x2b>
			*dst++ = *src++;
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8d 50 01             	lea    0x1(%eax),%edx
  80090e:	89 55 08             	mov    %edx,0x8(%ebp)
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
  800914:	8d 4a 01             	lea    0x1(%edx),%ecx
  800917:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80091a:	0f b6 12             	movzbl (%edx),%edx
  80091d:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800923:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800927:	74 0a                	je     800933 <strlcpy+0x3f>
  800929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	84 c0                	test   %al,%al
  800931:	75 d5                	jne    800908 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800939:	8b 55 08             	mov    0x8(%ebp),%edx
  80093c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80093f:	29 c2                	sub    %eax,%edx
  800941:	89 d0                	mov    %edx,%eax
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800948:	eb 08                	jmp    800952 <strcmp+0xd>
		p++, q++;
  80094a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80094e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	0f b6 00             	movzbl (%eax),%eax
  800958:	84 c0                	test   %al,%al
  80095a:	74 10                	je     80096c <strcmp+0x27>
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	0f b6 10             	movzbl (%eax),%edx
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	0f b6 00             	movzbl (%eax),%eax
  800968:	38 c2                	cmp    %al,%dl
  80096a:	74 de                	je     80094a <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	0f b6 00             	movzbl (%eax),%eax
  800972:	0f b6 d0             	movzbl %al,%edx
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 c0             	movzbl %al,%eax
  80097e:	29 c2                	sub    %eax,%edx
  800980:	89 d0                	mov    %edx,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800987:	eb 0c                	jmp    800995 <strncmp+0x11>
		n--, p++, q++;
  800989:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80098d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800991:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800995:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800999:	74 1a                	je     8009b5 <strncmp+0x31>
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	0f b6 00             	movzbl (%eax),%eax
  8009a1:	84 c0                	test   %al,%al
  8009a3:	74 10                	je     8009b5 <strncmp+0x31>
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	0f b6 10             	movzbl (%eax),%edx
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	38 c2                	cmp    %al,%dl
  8009b3:	74 d4                	je     800989 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009b9:	75 07                	jne    8009c2 <strncmp+0x3e>
		return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	eb 16                	jmp    8009d8 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	0f b6 00             	movzbl (%eax),%eax
  8009c8:	0f b6 d0             	movzbl %al,%edx
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	0f b6 00             	movzbl (%eax),%eax
  8009d1:	0f b6 c0             	movzbl %al,%eax
  8009d4:	29 c2                	sub    %eax,%edx
  8009d6:	89 d0                	mov    %edx,%eax
}
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 04             	sub    $0x4,%esp
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009e6:	eb 14                	jmp    8009fc <strchr+0x22>
		if (*s == c)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 00             	movzbl (%eax),%eax
  8009ee:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009f1:	75 05                	jne    8009f8 <strchr+0x1e>
			return (char *) s;
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	eb 13                	jmp    800a0b <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	0f b6 00             	movzbl (%eax),%eax
  800a02:	84 c0                	test   %al,%al
  800a04:	75 e2                	jne    8009e8 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	83 ec 04             	sub    $0x4,%esp
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a19:	eb 11                	jmp    800a2c <strfind+0x1f>
		if (*s == c)
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	0f b6 00             	movzbl (%eax),%eax
  800a21:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a24:	75 02                	jne    800a28 <strfind+0x1b>
			break;
  800a26:	eb 0e                	jmp    800a36 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	0f b6 00             	movzbl (%eax),%eax
  800a32:	84 c0                	test   %al,%al
  800a34:	75 e5                	jne    800a1b <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a43:	75 05                	jne    800a4a <memset+0xf>
		return v;
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	eb 5c                	jmp    800aa6 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	83 e0 03             	and    $0x3,%eax
  800a50:	85 c0                	test   %eax,%eax
  800a52:	75 41                	jne    800a95 <memset+0x5a>
  800a54:	8b 45 10             	mov    0x10(%ebp),%eax
  800a57:	83 e0 03             	and    $0x3,%eax
  800a5a:	85 c0                	test   %eax,%eax
  800a5c:	75 37                	jne    800a95 <memset+0x5a>
		c &= 0xFF;
  800a5e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	c1 e0 18             	shl    $0x18,%eax
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a70:	c1 e0 10             	shl    $0x10,%eax
  800a73:	09 c2                	or     %eax,%edx
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	c1 e0 08             	shl    $0x8,%eax
  800a7b:	09 d0                	or     %edx,%eax
  800a7d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a80:	8b 45 10             	mov    0x10(%ebp),%eax
  800a83:	c1 e8 02             	shr    $0x2,%eax
  800a86:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 d7                	mov    %edx,%edi
  800a90:	fc                   	cld    
  800a91:	f3 ab                	rep stos %eax,%es:(%edi)
  800a93:	eb 0e                	jmp    800aa3 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a95:	8b 55 08             	mov    0x8(%ebp),%edx
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a9e:	89 d7                	mov    %edx,%edi
  800aa0:	fc                   	cld    
  800aa1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ac4:	73 6d                	jae    800b33 <memmove+0x8a>
  800ac6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800acc:	01 d0                	add    %edx,%eax
  800ace:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ad1:	76 60                	jbe    800b33 <memmove+0x8a>
		s += n;
  800ad3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad6:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ad9:	8b 45 10             	mov    0x10(%ebp),%eax
  800adc:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae2:	83 e0 03             	and    $0x3,%eax
  800ae5:	85 c0                	test   %eax,%eax
  800ae7:	75 2f                	jne    800b18 <memmove+0x6f>
  800ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aec:	83 e0 03             	and    $0x3,%eax
  800aef:	85 c0                	test   %eax,%eax
  800af1:	75 25                	jne    800b18 <memmove+0x6f>
  800af3:	8b 45 10             	mov    0x10(%ebp),%eax
  800af6:	83 e0 03             	and    $0x3,%eax
  800af9:	85 c0                	test   %eax,%eax
  800afb:	75 1b                	jne    800b18 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800afd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b00:	83 e8 04             	sub    $0x4,%eax
  800b03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b06:	83 ea 04             	sub    $0x4,%edx
  800b09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b0c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	fd                   	std    
  800b14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b16:	eb 18                	jmp    800b30 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b1b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b21:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b24:	8b 45 10             	mov    0x10(%ebp),%eax
  800b27:	89 d7                	mov    %edx,%edi
  800b29:	89 de                	mov    %ebx,%esi
  800b2b:	89 c1                	mov    %eax,%ecx
  800b2d:	fd                   	std    
  800b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b30:	fc                   	cld    
  800b31:	eb 45                	jmp    800b78 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b36:	83 e0 03             	and    $0x3,%eax
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	75 2b                	jne    800b68 <memmove+0xbf>
  800b3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b40:	83 e0 03             	and    $0x3,%eax
  800b43:	85 c0                	test   %eax,%eax
  800b45:	75 21                	jne    800b68 <memmove+0xbf>
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	83 e0 03             	and    $0x3,%eax
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 17                	jne    800b68 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b51:	8b 45 10             	mov    0x10(%ebp),%eax
  800b54:	c1 e8 02             	shr    $0x2,%eax
  800b57:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 d6                	mov    %edx,%esi
  800b63:	fc                   	cld    
  800b64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b66:	eb 10                	jmp    800b78 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b71:	89 c7                	mov    %eax,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	89 04 24             	mov    %eax,(%esp)
  800b9d:	e8 07 ff ff ff       	call   800aa9 <memmove>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb3:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bb6:	eb 30                	jmp    800be8 <memcmp+0x44>
		if (*s1 != *s2)
  800bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbb:	0f b6 10             	movzbl (%eax),%edx
  800bbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bc1:	0f b6 00             	movzbl (%eax),%eax
  800bc4:	38 c2                	cmp    %al,%dl
  800bc6:	74 18                	je     800be0 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bcb:	0f b6 00             	movzbl (%eax),%eax
  800bce:	0f b6 d0             	movzbl %al,%edx
  800bd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bd4:	0f b6 00             	movzbl (%eax),%eax
  800bd7:	0f b6 c0             	movzbl %al,%eax
  800bda:	29 c2                	sub    %eax,%edx
  800bdc:	89 d0                	mov    %edx,%eax
  800bde:	eb 1a                	jmp    800bfa <memcmp+0x56>
		s1++, s2++;
  800be0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800be4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be8:	8b 45 10             	mov    0x10(%ebp),%eax
  800beb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bee:	89 55 10             	mov    %edx,0x10(%ebp)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	75 c3                	jne    800bb8 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c02:	8b 45 10             	mov    0x10(%ebp),%eax
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	01 d0                	add    %edx,%eax
  800c0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c0d:	eb 13                	jmp    800c22 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	0f b6 10             	movzbl (%eax),%edx
  800c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c18:	38 c2                	cmp    %al,%dl
  800c1a:	75 02                	jne    800c1e <memfind+0x22>
			break;
  800c1c:	eb 0c                	jmp    800c2a <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c28:	72 e5                	jb     800c0f <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c35:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c3c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	eb 04                	jmp    800c49 <strtol+0x1a>
		s++;
  800c45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	0f b6 00             	movzbl (%eax),%eax
  800c4f:	3c 20                	cmp    $0x20,%al
  800c51:	74 f2                	je     800c45 <strtol+0x16>
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	0f b6 00             	movzbl (%eax),%eax
  800c59:	3c 09                	cmp    $0x9,%al
  800c5b:	74 e8                	je     800c45 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	0f b6 00             	movzbl (%eax),%eax
  800c63:	3c 2b                	cmp    $0x2b,%al
  800c65:	75 06                	jne    800c6d <strtol+0x3e>
		s++;
  800c67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6b:	eb 15                	jmp    800c82 <strtol+0x53>
	else if (*s == '-')
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	0f b6 00             	movzbl (%eax),%eax
  800c73:	3c 2d                	cmp    $0x2d,%al
  800c75:	75 0b                	jne    800c82 <strtol+0x53>
		s++, neg = 1;
  800c77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c86:	74 06                	je     800c8e <strtol+0x5f>
  800c88:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c8c:	75 24                	jne    800cb2 <strtol+0x83>
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	0f b6 00             	movzbl (%eax),%eax
  800c94:	3c 30                	cmp    $0x30,%al
  800c96:	75 1a                	jne    800cb2 <strtol+0x83>
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	83 c0 01             	add    $0x1,%eax
  800c9e:	0f b6 00             	movzbl (%eax),%eax
  800ca1:	3c 78                	cmp    $0x78,%al
  800ca3:	75 0d                	jne    800cb2 <strtol+0x83>
		s += 2, base = 16;
  800ca5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800ca9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cb0:	eb 2a                	jmp    800cdc <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cb6:	75 17                	jne    800ccf <strtol+0xa0>
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	0f b6 00             	movzbl (%eax),%eax
  800cbe:	3c 30                	cmp    $0x30,%al
  800cc0:	75 0d                	jne    800ccf <strtol+0xa0>
		s++, base = 8;
  800cc2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cc6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ccd:	eb 0d                	jmp    800cdc <strtol+0xad>
	else if (base == 0)
  800ccf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd3:	75 07                	jne    800cdc <strtol+0xad>
		base = 10;
  800cd5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	0f b6 00             	movzbl (%eax),%eax
  800ce2:	3c 2f                	cmp    $0x2f,%al
  800ce4:	7e 1b                	jle    800d01 <strtol+0xd2>
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	0f b6 00             	movzbl (%eax),%eax
  800cec:	3c 39                	cmp    $0x39,%al
  800cee:	7f 11                	jg     800d01 <strtol+0xd2>
			dig = *s - '0';
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	0f b6 00             	movzbl (%eax),%eax
  800cf6:	0f be c0             	movsbl %al,%eax
  800cf9:	83 e8 30             	sub    $0x30,%eax
  800cfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cff:	eb 48                	jmp    800d49 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	0f b6 00             	movzbl (%eax),%eax
  800d07:	3c 60                	cmp    $0x60,%al
  800d09:	7e 1b                	jle    800d26 <strtol+0xf7>
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	0f b6 00             	movzbl (%eax),%eax
  800d11:	3c 7a                	cmp    $0x7a,%al
  800d13:	7f 11                	jg     800d26 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	0f b6 00             	movzbl (%eax),%eax
  800d1b:	0f be c0             	movsbl %al,%eax
  800d1e:	83 e8 57             	sub    $0x57,%eax
  800d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d24:	eb 23                	jmp    800d49 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	0f b6 00             	movzbl (%eax),%eax
  800d2c:	3c 40                	cmp    $0x40,%al
  800d2e:	7e 3d                	jle    800d6d <strtol+0x13e>
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	0f b6 00             	movzbl (%eax),%eax
  800d36:	3c 5a                	cmp    $0x5a,%al
  800d38:	7f 33                	jg     800d6d <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	0f b6 00             	movzbl (%eax),%eax
  800d40:	0f be c0             	movsbl %al,%eax
  800d43:	83 e8 37             	sub    $0x37,%eax
  800d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d4f:	7c 02                	jl     800d53 <strtol+0x124>
			break;
  800d51:	eb 1a                	jmp    800d6d <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d53:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d57:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d5a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d5e:	89 c2                	mov    %eax,%edx
  800d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d63:	01 d0                	add    %edx,%eax
  800d65:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d68:	e9 6f ff ff ff       	jmp    800cdc <strtol+0xad>

	if (endptr)
  800d6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d71:	74 08                	je     800d7b <strtol+0x14c>
		*endptr = (char *) s;
  800d73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d7b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d7f:	74 07                	je     800d88 <strtol+0x159>
  800d81:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d84:	f7 d8                	neg    %eax
  800d86:	eb 03                	jmp    800d8b <strtol+0x15c>
  800d88:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	8b 55 10             	mov    0x10(%ebp),%edx
  800d9c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d9f:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800da2:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800da5:	8b 75 20             	mov    0x20(%ebp),%esi
  800da8:	cd 30                	int    $0x30
  800daa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db1:	74 30                	je     800de3 <syscall+0x56>
  800db3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800db7:	7e 2a                	jle    800de3 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dc7:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd6:	00 
  800dd7:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800dde:	e8 6f 03 00 00       	call   801152 <_panic>

	return ret;
  800de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800de6:	83 c4 3c             	add    $0x3c,%esp
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800dfe:	00 
  800dff:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e06:	00 
  800e07:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e0e:	00 
  800e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e12:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e21:	00 
  800e22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e29:	e8 5f ff ff ff       	call   800d8d <syscall>
}
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    

00800e30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e36:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e45:	00 
  800e46:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e55:	00 
  800e56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e65:	00 
  800e66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e6d:	e8 1b ff ff ff       	call   800d8d <syscall>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e84:	00 
  800e85:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e94:	00 
  800e95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e9c:	00 
  800e9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800eb0:	e8 d8 fe ff ff       	call   800d8d <syscall>
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ebd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800edc:	00 
  800edd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ef4:	e8 94 fe ff ff       	call   800d8d <syscall>
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <sys_yield>:

void
sys_yield(void)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f01:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f08:	00 
  800f09:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f10:	00 
  800f11:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f18:	00 
  800f19:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f20:	00 
  800f21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f38:	e8 50 fe ff ff       	call   800d8d <syscall>
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f45:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f55:	00 
  800f56:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f5d:	00 
  800f5e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f62:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f71:	00 
  800f72:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f79:	e8 0f fe ff ff       	call   800d8d <syscall>
}
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
  800f85:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f88:	8b 75 18             	mov    0x18(%ebp),%esi
  800f8b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f9b:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800f9f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb2:	00 
  800fb3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fba:	e8 ce fd ff ff       	call   800d8d <syscall>
}
  800fbf:	83 c4 20             	add    $0x20,%esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fd9:	00 
  800fda:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fe9:	00 
  800fea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fee:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ff9:	00 
  800ffa:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801001:	e8 87 fd ff ff       	call   800d8d <syscall>
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80100e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80101b:	00 
  80101c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801023:	00 
  801024:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80102b:	00 
  80102c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801030:	89 44 24 08          	mov    %eax,0x8(%esp)
  801034:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80103b:	00 
  80103c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801043:	e8 45 fd ff ff       	call   800d8d <syscall>
}
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801050:	8b 55 0c             	mov    0xc(%ebp),%edx
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80105d:	00 
  80105e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801065:	00 
  801066:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80106d:	00 
  80106e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801072:	89 44 24 08          	mov    %eax,0x8(%esp)
  801076:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801085:	e8 03 fd ff ff       	call   800d8d <syscall>
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801092:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801095:	8b 55 10             	mov    0x10(%ebp),%edx
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010a2:	00 
  8010a3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010c5:	e8 c3 fc ff ff       	call   800d8d <syscall>
}
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010f4:	00 
  8010f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801108:	e8 80 fc ff ff       	call   800d8d <syscall>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <sys_exec>:

void sys_exec(char* buf){
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
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
  80113c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80114b:	e8 3d fc ff ff       	call   800d8d <syscall>
}
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	53                   	push   %ebx
  801156:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801159:	8d 45 14             	lea    0x14(%ebp),%eax
  80115c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80115f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801165:	e8 4d fd ff ff       	call   800eb7 <sys_getenvid>
  80116a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
  801174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801180:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  801187:	e8 f6 ef ff ff       	call   800182 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80118c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801193:	8b 45 10             	mov    0x10(%ebp),%eax
  801196:	89 04 24             	mov    %eax,(%esp)
  801199:	e8 80 ef ff ff       	call   80011e <vcprintf>
	cprintf("\n");
  80119e:	c7 04 24 13 17 80 00 	movl   $0x801713,(%esp)
  8011a5:	e8 d8 ef ff ff       	call   800182 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011aa:	cc                   	int3   
  8011ab:	eb fd                	jmp    8011aa <_panic+0x58>
  8011ad:	66 90                	xchg   %ax,%ax
  8011af:	90                   	nop

008011b0 <__udivdi3>:
  8011b0:	55                   	push   %ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011cc:	89 ea                	mov    %ebp,%edx
  8011ce:	89 0c 24             	mov    %ecx,(%esp)
  8011d1:	75 2d                	jne    801200 <__udivdi3+0x50>
  8011d3:	39 e9                	cmp    %ebp,%ecx
  8011d5:	77 61                	ja     801238 <__udivdi3+0x88>
  8011d7:	85 c9                	test   %ecx,%ecx
  8011d9:	89 ce                	mov    %ecx,%esi
  8011db:	75 0b                	jne    8011e8 <__udivdi3+0x38>
  8011dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e2:	31 d2                	xor    %edx,%edx
  8011e4:	f7 f1                	div    %ecx
  8011e6:	89 c6                	mov    %eax,%esi
  8011e8:	31 d2                	xor    %edx,%edx
  8011ea:	89 e8                	mov    %ebp,%eax
  8011ec:	f7 f6                	div    %esi
  8011ee:	89 c5                	mov    %eax,%ebp
  8011f0:	89 f8                	mov    %edi,%eax
  8011f2:	f7 f6                	div    %esi
  8011f4:	89 ea                	mov    %ebp,%edx
  8011f6:	83 c4 0c             	add    $0xc,%esp
  8011f9:	5e                   	pop    %esi
  8011fa:	5f                   	pop    %edi
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    
  8011fd:	8d 76 00             	lea    0x0(%esi),%esi
  801200:	39 e8                	cmp    %ebp,%eax
  801202:	77 24                	ja     801228 <__udivdi3+0x78>
  801204:	0f bd e8             	bsr    %eax,%ebp
  801207:	83 f5 1f             	xor    $0x1f,%ebp
  80120a:	75 3c                	jne    801248 <__udivdi3+0x98>
  80120c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801210:	39 34 24             	cmp    %esi,(%esp)
  801213:	0f 86 9f 00 00 00    	jbe    8012b8 <__udivdi3+0x108>
  801219:	39 d0                	cmp    %edx,%eax
  80121b:	0f 82 97 00 00 00    	jb     8012b8 <__udivdi3+0x108>
  801221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801228:	31 d2                	xor    %edx,%edx
  80122a:	31 c0                	xor    %eax,%eax
  80122c:	83 c4 0c             	add    $0xc,%esp
  80122f:	5e                   	pop    %esi
  801230:	5f                   	pop    %edi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    
  801233:	90                   	nop
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	89 f8                	mov    %edi,%eax
  80123a:	f7 f1                	div    %ecx
  80123c:	31 d2                	xor    %edx,%edx
  80123e:	83 c4 0c             	add    $0xc,%esp
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    
  801245:	8d 76 00             	lea    0x0(%esi),%esi
  801248:	89 e9                	mov    %ebp,%ecx
  80124a:	8b 3c 24             	mov    (%esp),%edi
  80124d:	d3 e0                	shl    %cl,%eax
  80124f:	89 c6                	mov    %eax,%esi
  801251:	b8 20 00 00 00       	mov    $0x20,%eax
  801256:	29 e8                	sub    %ebp,%eax
  801258:	89 c1                	mov    %eax,%ecx
  80125a:	d3 ef                	shr    %cl,%edi
  80125c:	89 e9                	mov    %ebp,%ecx
  80125e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801262:	8b 3c 24             	mov    (%esp),%edi
  801265:	09 74 24 08          	or     %esi,0x8(%esp)
  801269:	89 d6                	mov    %edx,%esi
  80126b:	d3 e7                	shl    %cl,%edi
  80126d:	89 c1                	mov    %eax,%ecx
  80126f:	89 3c 24             	mov    %edi,(%esp)
  801272:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801276:	d3 ee                	shr    %cl,%esi
  801278:	89 e9                	mov    %ebp,%ecx
  80127a:	d3 e2                	shl    %cl,%edx
  80127c:	89 c1                	mov    %eax,%ecx
  80127e:	d3 ef                	shr    %cl,%edi
  801280:	09 d7                	or     %edx,%edi
  801282:	89 f2                	mov    %esi,%edx
  801284:	89 f8                	mov    %edi,%eax
  801286:	f7 74 24 08          	divl   0x8(%esp)
  80128a:	89 d6                	mov    %edx,%esi
  80128c:	89 c7                	mov    %eax,%edi
  80128e:	f7 24 24             	mull   (%esp)
  801291:	39 d6                	cmp    %edx,%esi
  801293:	89 14 24             	mov    %edx,(%esp)
  801296:	72 30                	jb     8012c8 <__udivdi3+0x118>
  801298:	8b 54 24 04          	mov    0x4(%esp),%edx
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 e2                	shl    %cl,%edx
  8012a0:	39 c2                	cmp    %eax,%edx
  8012a2:	73 05                	jae    8012a9 <__udivdi3+0xf9>
  8012a4:	3b 34 24             	cmp    (%esp),%esi
  8012a7:	74 1f                	je     8012c8 <__udivdi3+0x118>
  8012a9:	89 f8                	mov    %edi,%eax
  8012ab:	31 d2                	xor    %edx,%edx
  8012ad:	e9 7a ff ff ff       	jmp    80122c <__udivdi3+0x7c>
  8012b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bf:	e9 68 ff ff ff       	jmp    80122c <__udivdi3+0x7c>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	83 c4 0c             	add    $0xc,%esp
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    
  8012d4:	66 90                	xchg   %ax,%ax
  8012d6:	66 90                	xchg   %ax,%ax
  8012d8:	66 90                	xchg   %ax,%ax
  8012da:	66 90                	xchg   %ax,%ax
  8012dc:	66 90                	xchg   %ax,%ax
  8012de:	66 90                	xchg   %ax,%ax

008012e0 <__umoddi3>:
  8012e0:	55                   	push   %ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	83 ec 14             	sub    $0x14,%esp
  8012e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012f2:	89 c7                	mov    %eax,%edi
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801300:	89 34 24             	mov    %esi,(%esp)
  801303:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801307:	85 c0                	test   %eax,%eax
  801309:	89 c2                	mov    %eax,%edx
  80130b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80130f:	75 17                	jne    801328 <__umoddi3+0x48>
  801311:	39 fe                	cmp    %edi,%esi
  801313:	76 4b                	jbe    801360 <__umoddi3+0x80>
  801315:	89 c8                	mov    %ecx,%eax
  801317:	89 fa                	mov    %edi,%edx
  801319:	f7 f6                	div    %esi
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	31 d2                	xor    %edx,%edx
  80131f:	83 c4 14             	add    $0x14,%esp
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    
  801326:	66 90                	xchg   %ax,%ax
  801328:	39 f8                	cmp    %edi,%eax
  80132a:	77 54                	ja     801380 <__umoddi3+0xa0>
  80132c:	0f bd e8             	bsr    %eax,%ebp
  80132f:	83 f5 1f             	xor    $0x1f,%ebp
  801332:	75 5c                	jne    801390 <__umoddi3+0xb0>
  801334:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801338:	39 3c 24             	cmp    %edi,(%esp)
  80133b:	0f 87 e7 00 00 00    	ja     801428 <__umoddi3+0x148>
  801341:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801345:	29 f1                	sub    %esi,%ecx
  801347:	19 c7                	sbb    %eax,%edi
  801349:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801351:	8b 44 24 08          	mov    0x8(%esp),%eax
  801355:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801359:	83 c4 14             	add    $0x14,%esp
  80135c:	5e                   	pop    %esi
  80135d:	5f                   	pop    %edi
  80135e:	5d                   	pop    %ebp
  80135f:	c3                   	ret    
  801360:	85 f6                	test   %esi,%esi
  801362:	89 f5                	mov    %esi,%ebp
  801364:	75 0b                	jne    801371 <__umoddi3+0x91>
  801366:	b8 01 00 00 00       	mov    $0x1,%eax
  80136b:	31 d2                	xor    %edx,%edx
  80136d:	f7 f6                	div    %esi
  80136f:	89 c5                	mov    %eax,%ebp
  801371:	8b 44 24 04          	mov    0x4(%esp),%eax
  801375:	31 d2                	xor    %edx,%edx
  801377:	f7 f5                	div    %ebp
  801379:	89 c8                	mov    %ecx,%eax
  80137b:	f7 f5                	div    %ebp
  80137d:	eb 9c                	jmp    80131b <__umoddi3+0x3b>
  80137f:	90                   	nop
  801380:	89 c8                	mov    %ecx,%eax
  801382:	89 fa                	mov    %edi,%edx
  801384:	83 c4 14             	add    $0x14,%esp
  801387:	5e                   	pop    %esi
  801388:	5f                   	pop    %edi
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    
  80138b:	90                   	nop
  80138c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801390:	8b 04 24             	mov    (%esp),%eax
  801393:	be 20 00 00 00       	mov    $0x20,%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	29 ee                	sub    %ebp,%esi
  80139c:	d3 e2                	shl    %cl,%edx
  80139e:	89 f1                	mov    %esi,%ecx
  8013a0:	d3 e8                	shr    %cl,%eax
  8013a2:	89 e9                	mov    %ebp,%ecx
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	8b 04 24             	mov    (%esp),%eax
  8013ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8013af:	89 fa                	mov    %edi,%edx
  8013b1:	d3 e0                	shl    %cl,%eax
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013bd:	d3 ea                	shr    %cl,%edx
  8013bf:	89 e9                	mov    %ebp,%ecx
  8013c1:	d3 e7                	shl    %cl,%edi
  8013c3:	89 f1                	mov    %esi,%ecx
  8013c5:	d3 e8                	shr    %cl,%eax
  8013c7:	89 e9                	mov    %ebp,%ecx
  8013c9:	09 f8                	or     %edi,%eax
  8013cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013cf:	f7 74 24 04          	divl   0x4(%esp)
  8013d3:	d3 e7                	shl    %cl,%edi
  8013d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013d9:	89 d7                	mov    %edx,%edi
  8013db:	f7 64 24 08          	mull   0x8(%esp)
  8013df:	39 d7                	cmp    %edx,%edi
  8013e1:	89 c1                	mov    %eax,%ecx
  8013e3:	89 14 24             	mov    %edx,(%esp)
  8013e6:	72 2c                	jb     801414 <__umoddi3+0x134>
  8013e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013ec:	72 22                	jb     801410 <__umoddi3+0x130>
  8013ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013f2:	29 c8                	sub    %ecx,%eax
  8013f4:	19 d7                	sbb    %edx,%edi
  8013f6:	89 e9                	mov    %ebp,%ecx
  8013f8:	89 fa                	mov    %edi,%edx
  8013fa:	d3 e8                	shr    %cl,%eax
  8013fc:	89 f1                	mov    %esi,%ecx
  8013fe:	d3 e2                	shl    %cl,%edx
  801400:	89 e9                	mov    %ebp,%ecx
  801402:	d3 ef                	shr    %cl,%edi
  801404:	09 d0                	or     %edx,%eax
  801406:	89 fa                	mov    %edi,%edx
  801408:	83 c4 14             	add    $0x14,%esp
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    
  80140f:	90                   	nop
  801410:	39 d7                	cmp    %edx,%edi
  801412:	75 da                	jne    8013ee <__umoddi3+0x10e>
  801414:	8b 14 24             	mov    (%esp),%edx
  801417:	89 c1                	mov    %eax,%ecx
  801419:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80141d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801421:	eb cb                	jmp    8013ee <__umoddi3+0x10e>
  801423:	90                   	nop
  801424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801428:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80142c:	0f 82 0f ff ff ff    	jb     801341 <__umoddi3+0x61>
  801432:	e9 1a ff ff ff       	jmp    801351 <__umoddi3+0x71>
