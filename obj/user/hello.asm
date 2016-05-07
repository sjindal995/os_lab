
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
  800039:	c7 04 24 80 14 80 00 	movl   $0x801480,(%esp)
  800040:	e8 2d 01 00 00       	call   800172 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800045:	a1 04 20 80 00       	mov    0x802004,%eax
  80004a:	8b 40 48             	mov    0x48(%eax),%eax
  80004d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800051:	c7 04 24 8e 14 80 00 	movl   $0x80148e,(%esp)
  800058:	e8 15 01 00 00       	call   800172 <cprintf>
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
  800065:	e8 3d 0e 00 00       	call   800ea7 <sys_getenvid>
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	c1 e0 02             	shl    $0x2,%eax
  800072:	89 c2                	mov    %eax,%edx
  800074:	c1 e2 05             	shl    $0x5,%edx
  800077:	29 c2                	sub    %eax,%edx
  800079:	89 d0                	mov    %edx,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800085:	8b 45 0c             	mov    0xc(%ebp),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	8b 45 08             	mov    0x8(%ebp),%eax
  80008f:	89 04 24             	mov    %eax,(%esp)
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 02 00 00 00       	call   80009e <exit>
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ab:	e8 b4 0d 00 00       	call   800e64 <sys_env_destroy>
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000bb:	8b 00                	mov    (%eax),%eax
  8000bd:	8d 48 01             	lea    0x1(%eax),%ecx
  8000c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000c3:	89 0a                	mov    %ecx,(%edx)
  8000c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000cd:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d4:	8b 00                	mov    (%eax),%eax
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 20                	jne    8000fd <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8000dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e0:	8b 00                	mov    (%eax),%eax
  8000e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000e5:	83 c2 08             	add    $0x8,%edx
  8000e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ec:	89 14 24             	mov    %edx,(%esp)
  8000ef:	e8 ea 0c 00 00       	call   800dde <sys_cputs>
		b->idx = 0;
  8000f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800100:	8b 40 04             	mov    0x4(%eax),%eax
  800103:	8d 50 01             	lea    0x1(%eax),%edx
  800106:	8b 45 0c             	mov    0xc(%ebp),%eax
  800109:	89 50 04             	mov    %edx,0x4(%eax)
}
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    

0080010e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	8b 45 08             	mov    0x8(%ebp),%eax
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	c7 04 24 b2 00 80 00 	movl   $0x8000b2,(%esp)
  80014a:	e8 bd 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800155:	89 44 24 04          	mov    %eax,0x4(%esp)
  800159:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015f:	83 c0 08             	add    $0x8,%eax
  800162:	89 04 24             	mov    %eax,(%esp)
  800165:	e8 74 0c 00 00       	call   800dde <sys_cputs>

	return b.cnt;
  80016a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800170:	c9                   	leave  
  800171:	c3                   	ret    

00800172 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800178:	8d 45 0c             	lea    0xc(%ebp),%eax
  80017b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80017e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 7e ff ff ff       	call   80010e <vcprintf>
  800190:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800193:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 34             	sub    $0x34,%esp
  80019f:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ab:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001b6:	77 72                	ja     80022a <printnum+0x92>
  8001b8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001bb:	72 05                	jb     8001c2 <printnum+0x2a>
  8001bd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001c0:	77 68                	ja     80022a <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001c5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c8:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e5:	e8 06 10 00 00       	call   8011f0 <__udivdi3>
  8001ea:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8001ed:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8001f1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8001f5:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001f8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800200:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	8b 45 08             	mov    0x8(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 82 ff ff ff       	call   800198 <printnum>
  800216:	eb 1c                	jmp    800234 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	8b 45 20             	mov    0x20(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 45 08             	mov    0x8(%ebp),%eax
  800228:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022a:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80022e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800232:	7f e4                	jg     800218 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800237:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80023f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800242:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800246:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024a:	89 04 24             	mov    %eax,(%esp)
  80024d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800251:	e8 ca 10 00 00       	call   801320 <__umoddi3>
  800256:	05 88 15 80 00       	add    $0x801588,%eax
  80025b:	0f b6 00             	movzbl (%eax),%eax
  80025e:	0f be c0             	movsbl %al,%eax
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	89 54 24 04          	mov    %edx,0x4(%esp)
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	ff d0                	call   *%eax
}
  800270:	83 c4 34             	add    $0x34,%esp
  800273:	5b                   	pop    %ebx
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80027d:	7e 14                	jle    800293 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 45 08             	mov    0x8(%ebp),%eax
  800282:	8b 00                	mov    (%eax),%eax
  800284:	8d 48 08             	lea    0x8(%eax),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 0a                	mov    %ecx,(%edx)
  80028c:	8b 50 04             	mov    0x4(%eax),%edx
  80028f:	8b 00                	mov    (%eax),%eax
  800291:	eb 30                	jmp    8002c3 <getuint+0x4d>
	else if (lflag)
  800293:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800297:	74 16                	je     8002af <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800299:	8b 45 08             	mov    0x8(%ebp),%eax
  80029c:	8b 00                	mov    (%eax),%eax
  80029e:	8d 48 04             	lea    0x4(%eax),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 0a                	mov    %ecx,(%edx)
  8002a6:	8b 00                	mov    (%eax),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ad:	eb 14                	jmp    8002c3 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	8b 00                	mov    (%eax),%eax
  8002b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 0a                	mov    %ecx,(%edx)
  8002bc:	8b 00                	mov    (%eax),%eax
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002cc:	7e 14                	jle    8002e2 <getint+0x1d>
		return va_arg(*ap, long long);
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	8b 00                	mov    (%eax),%eax
  8002d3:	8d 48 08             	lea    0x8(%eax),%ecx
  8002d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d9:	89 0a                	mov    %ecx,(%edx)
  8002db:	8b 50 04             	mov    0x4(%eax),%edx
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	eb 28                	jmp    80030a <getint+0x45>
	else if (lflag)
  8002e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e6:	74 12                	je     8002fa <getint+0x35>
		return va_arg(*ap, long);
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	8b 00                	mov    (%eax),%eax
  8002ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	89 0a                	mov    %ecx,(%edx)
  8002f5:	8b 00                	mov    (%eax),%eax
  8002f7:	99                   	cltd   
  8002f8:	eb 10                	jmp    80030a <getint+0x45>
	else
		return va_arg(*ap, int);
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	8b 00                	mov    (%eax),%eax
  8002ff:	8d 48 04             	lea    0x4(%eax),%ecx
  800302:	8b 55 08             	mov    0x8(%ebp),%edx
  800305:	89 0a                	mov    %ecx,(%edx)
  800307:	8b 00                	mov    (%eax),%eax
  800309:	99                   	cltd   
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	eb 18                	jmp    80032e <vprintfmt+0x22>
			if (ch == '\0')
  800316:	85 db                	test   %ebx,%ebx
  800318:	75 05                	jne    80031f <vprintfmt+0x13>
				return;
  80031a:	e9 cc 03 00 00       	jmp    8006eb <vprintfmt+0x3df>
			putch(ch, putdat);
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800322:	89 44 24 04          	mov    %eax,0x4(%esp)
  800326:	89 1c 24             	mov    %ebx,(%esp)
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032e:	8b 45 10             	mov    0x10(%ebp),%eax
  800331:	8d 50 01             	lea    0x1(%eax),%edx
  800334:	89 55 10             	mov    %edx,0x10(%ebp)
  800337:	0f b6 00             	movzbl (%eax),%eax
  80033a:	0f b6 d8             	movzbl %al,%ebx
  80033d:	83 fb 25             	cmp    $0x25,%ebx
  800340:	75 d4                	jne    800316 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800342:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800346:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80034d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800354:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80035b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 45 10             	mov    0x10(%ebp),%eax
  800365:	8d 50 01             	lea    0x1(%eax),%edx
  800368:	89 55 10             	mov    %edx,0x10(%ebp)
  80036b:	0f b6 00             	movzbl (%eax),%eax
  80036e:	0f b6 d8             	movzbl %al,%ebx
  800371:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800374:	83 f8 55             	cmp    $0x55,%eax
  800377:	0f 87 3d 03 00 00    	ja     8006ba <vprintfmt+0x3ae>
  80037d:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  800384:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800386:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80038a:	eb d6                	jmp    800362 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800390:	eb d0                	jmp    800362 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800392:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800399:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80039c:	89 d0                	mov    %edx,%eax
  80039e:	c1 e0 02             	shl    $0x2,%eax
  8003a1:	01 d0                	add    %edx,%eax
  8003a3:	01 c0                	add    %eax,%eax
  8003a5:	01 d8                	add    %ebx,%eax
  8003a7:	83 e8 30             	sub    $0x30,%eax
  8003aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b0:	0f b6 00             	movzbl (%eax),%eax
  8003b3:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003b6:	83 fb 2f             	cmp    $0x2f,%ebx
  8003b9:	7e 0b                	jle    8003c6 <vprintfmt+0xba>
  8003bb:	83 fb 39             	cmp    $0x39,%ebx
  8003be:	7f 06                	jg     8003c6 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c4:	eb d3                	jmp    800399 <vprintfmt+0x8d>
			goto process_precision;
  8003c6:	eb 33                	jmp    8003fb <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003d6:	eb 23                	jmp    8003fb <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8003d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003dc:	79 0c                	jns    8003ea <vprintfmt+0xde>
				width = 0;
  8003de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003e5:	e9 78 ff ff ff       	jmp    800362 <vprintfmt+0x56>
  8003ea:	e9 73 ff ff ff       	jmp    800362 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8003ef:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f6:	e9 67 ff ff ff       	jmp    800362 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8003fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ff:	79 12                	jns    800413 <vprintfmt+0x107>
				width = precision, precision = -1;
  800401:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80040e:	e9 4f ff ff ff       	jmp    800362 <vprintfmt+0x56>
  800413:	e9 4a ff ff ff       	jmp    800362 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800418:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80041c:	e9 41 ff ff ff       	jmp    800362 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800433:	89 04 24             	mov    %eax,(%esp)
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	ff d0                	call   *%eax
			break;
  80043b:	e9 a5 02 00 00       	jmp    8006e5 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80044b:	85 db                	test   %ebx,%ebx
  80044d:	79 02                	jns    800451 <vprintfmt+0x145>
				err = -err;
  80044f:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800451:	83 fb 09             	cmp    $0x9,%ebx
  800454:	7f 0b                	jg     800461 <vprintfmt+0x155>
  800456:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  80045d:	85 f6                	test   %esi,%esi
  80045f:	75 23                	jne    800484 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800461:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800465:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  80046c:	00 
  80046d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800470:	89 44 24 04          	mov    %eax,0x4(%esp)
  800474:	8b 45 08             	mov    0x8(%ebp),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	e8 73 02 00 00       	call   8006f2 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80047f:	e9 61 02 00 00       	jmp    8006e5 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800484:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800488:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  80048f:	00 
  800490:	8b 45 0c             	mov    0xc(%ebp),%eax
  800493:	89 44 24 04          	mov    %eax,0x4(%esp)
  800497:	8b 45 08             	mov    0x8(%ebp),%eax
  80049a:	89 04 24             	mov    %eax,(%esp)
  80049d:	e8 50 02 00 00       	call   8006f2 <printfmt>
			break;
  8004a2:	e9 3e 02 00 00       	jmp    8006e5 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	8b 30                	mov    (%eax),%esi
  8004b2:	85 f6                	test   %esi,%esi
  8004b4:	75 05                	jne    8004bb <vprintfmt+0x1af>
				p = "(null)";
  8004b6:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8004bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bf:	7e 37                	jle    8004f8 <vprintfmt+0x1ec>
  8004c1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004c5:	74 31                	je     8004f8 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ce:	89 34 24             	mov    %esi,(%esp)
  8004d1:	e8 39 03 00 00       	call   80080f <strnlen>
  8004d6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004d9:	eb 17                	jmp    8004f2 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8004db:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f6:	7f e3                	jg     8004db <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f8:	eb 38                	jmp    800532 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fe:	74 1f                	je     80051f <vprintfmt+0x213>
  800500:	83 fb 1f             	cmp    $0x1f,%ebx
  800503:	7e 05                	jle    80050a <vprintfmt+0x1fe>
  800505:	83 fb 7e             	cmp    $0x7e,%ebx
  800508:	7e 15                	jle    80051f <vprintfmt+0x213>
					putch('?', putdat);
  80050a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800518:	8b 45 08             	mov    0x8(%ebp),%eax
  80051b:	ff d0                	call   *%eax
  80051d:	eb 0f                	jmp    80052e <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80051f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800522:	89 44 24 04          	mov    %eax,0x4(%esp)
  800526:	89 1c 24             	mov    %ebx,(%esp)
  800529:	8b 45 08             	mov    0x8(%ebp),%eax
  80052c:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800532:	89 f0                	mov    %esi,%eax
  800534:	8d 70 01             	lea    0x1(%eax),%esi
  800537:	0f b6 00             	movzbl (%eax),%eax
  80053a:	0f be d8             	movsbl %al,%ebx
  80053d:	85 db                	test   %ebx,%ebx
  80053f:	74 10                	je     800551 <vprintfmt+0x245>
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	78 b3                	js     8004fa <vprintfmt+0x1ee>
  800547:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80054b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054f:	79 a9                	jns    8004fa <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800551:	eb 17                	jmp    80056a <vprintfmt+0x25e>
				putch(' ', putdat);
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
  800556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800566:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80056a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056e:	7f e3                	jg     800553 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800570:	e9 70 01 00 00       	jmp    8006e5 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800575:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800578:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057c:	8d 45 14             	lea    0x14(%ebp),%eax
  80057f:	89 04 24             	mov    %eax,(%esp)
  800582:	e8 3e fd ff ff       	call   8002c5 <getint>
  800587:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80058a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80058d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800590:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	79 26                	jns    8005bd <vprintfmt+0x2b1>
				putch('-', putdat);
  800597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059e:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a8:	ff d0                	call   *%eax
				num = -(long long) num;
  8005aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005b0:	f7 d8                	neg    %eax
  8005b2:	83 d2 00             	adc    $0x0,%edx
  8005b5:	f7 da                	neg    %edx
  8005b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005bd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005c4:	e9 a8 00 00 00       	jmp    800671 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	89 04 24             	mov    %eax,(%esp)
  8005d6:	e8 9b fc ff ff       	call   800276 <getuint>
  8005db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005de:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005e1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005e8:	e9 84 00 00 00       	jmp    800671 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	e8 77 fc ff ff       	call   800276 <getuint>
  8005ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800602:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800605:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80060c:	eb 63                	jmp    800671 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80060e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800611:	89 44 24 04          	mov    %eax,0x4(%esp)
  800615:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	ff d0                	call   *%eax
			putch('x', putdat);
  800621:	8b 45 0c             	mov    0xc(%ebp),%eax
  800624:	89 44 24 04          	mov    %eax,0x4(%esp)
  800628:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062f:	8b 45 08             	mov    0x8(%ebp),%eax
  800632:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800642:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800649:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800650:	eb 1f                	jmp    800671 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800652:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800655:	89 44 24 04          	mov    %eax,0x4(%esp)
  800659:	8d 45 14             	lea    0x14(%ebp),%eax
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	e8 12 fc ff ff       	call   800276 <getuint>
  800664:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800667:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80066a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800671:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800675:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800678:	89 54 24 18          	mov    %edx,0x18(%esp)
  80067c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800683:	89 44 24 10          	mov    %eax,0x10(%esp)
  800687:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80068d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800691:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800695:	8b 45 0c             	mov    0xc(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	89 04 24             	mov    %eax,(%esp)
  8006a2:	e8 f1 fa ff ff       	call   800198 <printnum>
			break;
  8006a7:	eb 3c                	jmp    8006e5 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	89 1c 24             	mov    %ebx,(%esp)
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	ff d0                	call   *%eax
			break;
  8006b8:	eb 2b                	jmp    8006e5 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cb:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006d1:	eb 04                	jmp    8006d7 <vprintfmt+0x3cb>
  8006d3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8006d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006da:	83 e8 01             	sub    $0x1,%eax
  8006dd:	0f b6 00             	movzbl (%eax),%eax
  8006e0:	3c 25                	cmp    $0x25,%al
  8006e2:	75 ef                	jne    8006d3 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8006e4:	90                   	nop
		}
	}
  8006e5:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e6:	e9 43 fc ff ff       	jmp    80032e <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006eb:	83 c4 40             	add    $0x40,%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5e                   	pop    %esi
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800705:	8b 45 10             	mov    0x10(%ebp),%eax
  800708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	e8 ee fb ff ff       	call   80030c <vprintfmt>
	va_end(ap);
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800723:	8b 45 0c             	mov    0xc(%ebp),%eax
  800726:	8b 40 08             	mov    0x8(%eax),%eax
  800729:	8d 50 01             	lea    0x1(%eax),%edx
  80072c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072f:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800732:	8b 45 0c             	mov    0xc(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073a:	8b 40 04             	mov    0x4(%eax),%eax
  80073d:	39 c2                	cmp    %eax,%edx
  80073f:	73 12                	jae    800753 <sprintputch+0x33>
		*b->buf++ = ch;
  800741:	8b 45 0c             	mov    0xc(%ebp),%eax
  800744:	8b 00                	mov    (%eax),%eax
  800746:	8d 48 01             	lea    0x1(%eax),%ecx
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074c:	89 0a                	mov    %ecx,(%edx)
  80074e:	8b 55 08             	mov    0x8(%ebp),%edx
  800751:	88 10                	mov    %dl,(%eax)
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8b 45 0c             	mov    0xc(%ebp),%eax
  800764:	8d 50 ff             	lea    -0x1(%eax),%edx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	01 d0                	add    %edx,%eax
  80076c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800776:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80077a:	74 06                	je     800782 <vsnprintf+0x2d>
  80077c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800780:	7f 07                	jg     800789 <vsnprintf+0x34>
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800787:	eb 2a                	jmp    8007b3 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800790:	8b 45 10             	mov    0x10(%ebp),%eax
  800793:	89 44 24 08          	mov    %eax,0x8(%esp)
  800797:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079e:	c7 04 24 20 07 80 00 	movl   $0x800720,(%esp)
  8007a5:	e8 62 fb ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	89 04 24             	mov    %eax,(%esp)
  8007dc:	e8 74 ff ff ff       	call   800755 <vsnprintf>
  8007e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8007e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ef:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007f6:	eb 08                	jmp    800800 <strlen+0x17>
		n++;
  8007f8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	0f b6 00             	movzbl (%eax),%eax
  800806:	84 c0                	test   %al,%al
  800808:	75 ee                	jne    8007f8 <strlen+0xf>
		n++;
	return n;
  80080a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80081c:	eb 0c                	jmp    80082a <strnlen+0x1b>
		n++;
  80081e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800822:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800826:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80082a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80082e:	74 0a                	je     80083a <strnlen+0x2b>
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	0f b6 00             	movzbl (%eax),%eax
  800836:	84 c0                	test   %al,%al
  800838:	75 e4                	jne    80081e <strnlen+0xf>
		n++;
	return n;
  80083a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80084b:	90                   	nop
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8d 50 01             	lea    0x1(%eax),%edx
  800852:	89 55 08             	mov    %edx,0x8(%ebp)
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
  800858:	8d 4a 01             	lea    0x1(%edx),%ecx
  80085b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80085e:	0f b6 12             	movzbl (%edx),%edx
  800861:	88 10                	mov    %dl,(%eax)
  800863:	0f b6 00             	movzbl (%eax),%eax
  800866:	84 c0                	test   %al,%al
  800868:	75 e2                	jne    80084c <strcpy+0xd>
		/* do nothing */;
	return ret;
  80086a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 69 ff ff ff       	call   8007e9 <strlen>
  800880:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800883:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	01 c2                	add    %eax,%edx
  80088b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800892:	89 14 24             	mov    %edx,(%esp)
  800895:	e8 a5 ff ff ff       	call   80083f <strcpy>
	return dst;
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008b2:	eb 23                	jmp    8008d7 <strncpy+0x38>
		*dst++ = *src;
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8d 50 01             	lea    0x1(%eax),%edx
  8008ba:	89 55 08             	mov    %edx,0x8(%ebp)
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	0f b6 12             	movzbl (%edx),%edx
  8008c3:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	0f b6 00             	movzbl (%eax),%eax
  8008cb:	84 c0                	test   %al,%al
  8008cd:	74 04                	je     8008d3 <strncpy+0x34>
			src++;
  8008cf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8008d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008da:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008dd:	72 d5                	jb     8008b4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008df:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8008f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008f4:	74 33                	je     800929 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8008f6:	eb 17                	jmp    80090f <strlcpy+0x2b>
			*dst++ = *src++;
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8d 50 01             	lea    0x1(%eax),%edx
  8008fe:	89 55 08             	mov    %edx,0x8(%ebp)
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	8d 4a 01             	lea    0x1(%edx),%ecx
  800907:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800913:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800917:	74 0a                	je     800923 <strlcpy+0x3f>
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	0f b6 00             	movzbl (%eax),%eax
  80091f:	84 c0                	test   %al,%al
  800921:	75 d5                	jne    8008f8 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
  80092c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80092f:	29 c2                	sub    %eax,%edx
  800931:	89 d0                	mov    %edx,%eax
}
  800933:	c9                   	leave  
  800934:	c3                   	ret    

00800935 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800938:	eb 08                	jmp    800942 <strcmp+0xd>
		p++, q++;
  80093a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80093e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	0f b6 00             	movzbl (%eax),%eax
  800948:	84 c0                	test   %al,%al
  80094a:	74 10                	je     80095c <strcmp+0x27>
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	0f b6 10             	movzbl (%eax),%edx
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	0f b6 00             	movzbl (%eax),%eax
  800958:	38 c2                	cmp    %al,%dl
  80095a:	74 de                	je     80093a <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	0f b6 00             	movzbl (%eax),%eax
  800962:	0f b6 d0             	movzbl %al,%edx
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 c0             	movzbl %al,%eax
  80096e:	29 c2                	sub    %eax,%edx
  800970:	89 d0                	mov    %edx,%eax
}
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800977:	eb 0c                	jmp    800985 <strncmp+0x11>
		n--, p++, q++;
  800979:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80097d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800981:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800985:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800989:	74 1a                	je     8009a5 <strncmp+0x31>
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	0f b6 00             	movzbl (%eax),%eax
  800991:	84 c0                	test   %al,%al
  800993:	74 10                	je     8009a5 <strncmp+0x31>
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	0f b6 10             	movzbl (%eax),%edx
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	0f b6 00             	movzbl (%eax),%eax
  8009a1:	38 c2                	cmp    %al,%dl
  8009a3:	74 d4                	je     800979 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009a5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009a9:	75 07                	jne    8009b2 <strncmp+0x3e>
		return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b0:	eb 16                	jmp    8009c8 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	0f b6 00             	movzbl (%eax),%eax
  8009b8:	0f b6 d0             	movzbl %al,%edx
  8009bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009be:	0f b6 00             	movzbl (%eax),%eax
  8009c1:	0f b6 c0             	movzbl %al,%eax
  8009c4:	29 c2                	sub    %eax,%edx
  8009c6:	89 d0                	mov    %edx,%eax
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009d6:	eb 14                	jmp    8009ec <strchr+0x22>
		if (*s == c)
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	0f b6 00             	movzbl (%eax),%eax
  8009de:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009e1:	75 05                	jne    8009e8 <strchr+0x1e>
			return (char *) s;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	eb 13                	jmp    8009fb <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 00             	movzbl (%eax),%eax
  8009f2:	84 c0                	test   %al,%al
  8009f4:	75 e2                	jne    8009d8 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	83 ec 04             	sub    $0x4,%esp
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a09:	eb 11                	jmp    800a1c <strfind+0x1f>
		if (*s == c)
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	0f b6 00             	movzbl (%eax),%eax
  800a11:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a14:	75 02                	jne    800a18 <strfind+0x1b>
			break;
  800a16:	eb 0e                	jmp    800a26 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a18:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	0f b6 00             	movzbl (%eax),%eax
  800a22:	84 c0                	test   %al,%al
  800a24:	75 e5                	jne    800a0b <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a29:	c9                   	leave  
  800a2a:	c3                   	ret    

00800a2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a33:	75 05                	jne    800a3a <memset+0xf>
		return v;
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	eb 5c                	jmp    800a96 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	83 e0 03             	and    $0x3,%eax
  800a40:	85 c0                	test   %eax,%eax
  800a42:	75 41                	jne    800a85 <memset+0x5a>
  800a44:	8b 45 10             	mov    0x10(%ebp),%eax
  800a47:	83 e0 03             	and    $0x3,%eax
  800a4a:	85 c0                	test   %eax,%eax
  800a4c:	75 37                	jne    800a85 <memset+0x5a>
		c &= 0xFF;
  800a4e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	c1 e0 18             	shl    $0x18,%eax
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	c1 e0 10             	shl    $0x10,%eax
  800a63:	09 c2                	or     %eax,%edx
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	c1 e0 08             	shl    $0x8,%eax
  800a6b:	09 d0                	or     %edx,%eax
  800a6d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a70:	8b 45 10             	mov    0x10(%ebp),%eax
  800a73:	c1 e8 02             	shr    $0x2,%eax
  800a76:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	89 d7                	mov    %edx,%edi
  800a80:	fc                   	cld    
  800a81:	f3 ab                	rep stos %eax,%es:(%edi)
  800a83:	eb 0e                	jmp    800a93 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a85:	8b 55 08             	mov    0x8(%ebp),%edx
  800a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a8e:	89 d7                	mov    %edx,%edi
  800a90:	fc                   	cld    
  800a91:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ab4:	73 6d                	jae    800b23 <memmove+0x8a>
  800ab6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800abc:	01 d0                	add    %edx,%eax
  800abe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ac1:	76 60                	jbe    800b23 <memmove+0x8a>
		s += n;
  800ac3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac6:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ac9:	8b 45 10             	mov    0x10(%ebp),%eax
  800acc:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad2:	83 e0 03             	and    $0x3,%eax
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	75 2f                	jne    800b08 <memmove+0x6f>
  800ad9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800adc:	83 e0 03             	and    $0x3,%eax
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	75 25                	jne    800b08 <memmove+0x6f>
  800ae3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae6:	83 e0 03             	and    $0x3,%eax
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	75 1b                	jne    800b08 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af0:	83 e8 04             	sub    $0x4,%eax
  800af3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af6:	83 ea 04             	sub    $0x4,%edx
  800af9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800afc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	89 d6                	mov    %edx,%esi
  800b03:	fd                   	std    
  800b04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b06:	eb 18                	jmp    800b20 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b11:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
  800b17:	89 d7                	mov    %edx,%edi
  800b19:	89 de                	mov    %ebx,%esi
  800b1b:	89 c1                	mov    %eax,%ecx
  800b1d:	fd                   	std    
  800b1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b20:	fc                   	cld    
  800b21:	eb 45                	jmp    800b68 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b26:	83 e0 03             	and    $0x3,%eax
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	75 2b                	jne    800b58 <memmove+0xbf>
  800b2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b30:	83 e0 03             	and    $0x3,%eax
  800b33:	85 c0                	test   %eax,%eax
  800b35:	75 21                	jne    800b58 <memmove+0xbf>
  800b37:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3a:	83 e0 03             	and    $0x3,%eax
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 17                	jne    800b58 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	c1 e8 02             	shr    $0x2,%eax
  800b47:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b49:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	fc                   	cld    
  800b54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b56:	eb 10                	jmp    800b68 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b58:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	fc                   	cld    
  800b66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	89 04 24             	mov    %eax,(%esp)
  800b8d:	e8 07 ff ff ff       	call   800a99 <memmove>
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba3:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ba6:	eb 30                	jmp    800bd8 <memcmp+0x44>
		if (*s1 != *s2)
  800ba8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bab:	0f b6 10             	movzbl (%eax),%edx
  800bae:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bb1:	0f b6 00             	movzbl (%eax),%eax
  800bb4:	38 c2                	cmp    %al,%dl
  800bb6:	74 18                	je     800bd0 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbb:	0f b6 00             	movzbl (%eax),%eax
  800bbe:	0f b6 d0             	movzbl %al,%edx
  800bc1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bc4:	0f b6 00             	movzbl (%eax),%eax
  800bc7:	0f b6 c0             	movzbl %al,%eax
  800bca:	29 c2                	sub    %eax,%edx
  800bcc:	89 d0                	mov    %edx,%eax
  800bce:	eb 1a                	jmp    800bea <memcmp+0x56>
		s1++, s2++;
  800bd0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800bd4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bde:	89 55 10             	mov    %edx,0x10(%ebp)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	75 c3                	jne    800ba8 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	01 d0                	add    %edx,%eax
  800bfa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800bfd:	eb 13                	jmp    800c12 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	0f b6 10             	movzbl (%eax),%edx
  800c05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c08:	38 c2                	cmp    %al,%dl
  800c0a:	75 02                	jne    800c0e <memfind+0x22>
			break;
  800c0c:	eb 0c                	jmp    800c1a <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c18:	72 e5                	jb     800bff <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c25:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c2c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c33:	eb 04                	jmp    800c39 <strtol+0x1a>
		s++;
  800c35:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	0f b6 00             	movzbl (%eax),%eax
  800c3f:	3c 20                	cmp    $0x20,%al
  800c41:	74 f2                	je     800c35 <strtol+0x16>
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	0f b6 00             	movzbl (%eax),%eax
  800c49:	3c 09                	cmp    $0x9,%al
  800c4b:	74 e8                	je     800c35 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	0f b6 00             	movzbl (%eax),%eax
  800c53:	3c 2b                	cmp    $0x2b,%al
  800c55:	75 06                	jne    800c5d <strtol+0x3e>
		s++;
  800c57:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c5b:	eb 15                	jmp    800c72 <strtol+0x53>
	else if (*s == '-')
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	0f b6 00             	movzbl (%eax),%eax
  800c63:	3c 2d                	cmp    $0x2d,%al
  800c65:	75 0b                	jne    800c72 <strtol+0x53>
		s++, neg = 1;
  800c67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c76:	74 06                	je     800c7e <strtol+0x5f>
  800c78:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c7c:	75 24                	jne    800ca2 <strtol+0x83>
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	0f b6 00             	movzbl (%eax),%eax
  800c84:	3c 30                	cmp    $0x30,%al
  800c86:	75 1a                	jne    800ca2 <strtol+0x83>
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	83 c0 01             	add    $0x1,%eax
  800c8e:	0f b6 00             	movzbl (%eax),%eax
  800c91:	3c 78                	cmp    $0x78,%al
  800c93:	75 0d                	jne    800ca2 <strtol+0x83>
		s += 2, base = 16;
  800c95:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800c99:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ca0:	eb 2a                	jmp    800ccc <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ca2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ca6:	75 17                	jne    800cbf <strtol+0xa0>
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	0f b6 00             	movzbl (%eax),%eax
  800cae:	3c 30                	cmp    $0x30,%al
  800cb0:	75 0d                	jne    800cbf <strtol+0xa0>
		s++, base = 8;
  800cb2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cbd:	eb 0d                	jmp    800ccc <strtol+0xad>
	else if (base == 0)
  800cbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc3:	75 07                	jne    800ccc <strtol+0xad>
		base = 10;
  800cc5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	0f b6 00             	movzbl (%eax),%eax
  800cd2:	3c 2f                	cmp    $0x2f,%al
  800cd4:	7e 1b                	jle    800cf1 <strtol+0xd2>
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	0f b6 00             	movzbl (%eax),%eax
  800cdc:	3c 39                	cmp    $0x39,%al
  800cde:	7f 11                	jg     800cf1 <strtol+0xd2>
			dig = *s - '0';
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	0f b6 00             	movzbl (%eax),%eax
  800ce6:	0f be c0             	movsbl %al,%eax
  800ce9:	83 e8 30             	sub    $0x30,%eax
  800cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800cef:	eb 48                	jmp    800d39 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	0f b6 00             	movzbl (%eax),%eax
  800cf7:	3c 60                	cmp    $0x60,%al
  800cf9:	7e 1b                	jle    800d16 <strtol+0xf7>
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	0f b6 00             	movzbl (%eax),%eax
  800d01:	3c 7a                	cmp    $0x7a,%al
  800d03:	7f 11                	jg     800d16 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	0f b6 00             	movzbl (%eax),%eax
  800d0b:	0f be c0             	movsbl %al,%eax
  800d0e:	83 e8 57             	sub    $0x57,%eax
  800d11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d14:	eb 23                	jmp    800d39 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	0f b6 00             	movzbl (%eax),%eax
  800d1c:	3c 40                	cmp    $0x40,%al
  800d1e:	7e 3d                	jle    800d5d <strtol+0x13e>
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	0f b6 00             	movzbl (%eax),%eax
  800d26:	3c 5a                	cmp    $0x5a,%al
  800d28:	7f 33                	jg     800d5d <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	0f b6 00             	movzbl (%eax),%eax
  800d30:	0f be c0             	movsbl %al,%eax
  800d33:	83 e8 37             	sub    $0x37,%eax
  800d36:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d3f:	7c 02                	jl     800d43 <strtol+0x124>
			break;
  800d41:	eb 1a                	jmp    800d5d <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d47:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4e:	89 c2                	mov    %eax,%edx
  800d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d53:	01 d0                	add    %edx,%eax
  800d55:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d58:	e9 6f ff ff ff       	jmp    800ccc <strtol+0xad>

	if (endptr)
  800d5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d61:	74 08                	je     800d6b <strtol+0x14c>
		*endptr = (char *) s;
  800d63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d6b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800d6f:	74 07                	je     800d78 <strtol+0x159>
  800d71:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d74:	f7 d8                	neg    %eax
  800d76:	eb 03                	jmp    800d7b <strtol+0x15c>
  800d78:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	8b 55 10             	mov    0x10(%ebp),%edx
  800d8c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800d8f:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800d92:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800d95:	8b 75 20             	mov    0x20(%ebp),%esi
  800d98:	cd 30                	int    $0x30
  800d9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da1:	74 30                	je     800dd3 <syscall+0x56>
  800da3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800da7:	7e 2a                	jle    800dd3 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800db7:	c7 44 24 08 04 17 80 	movl   $0x801704,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 21 17 80 00 	movl   $0x801721,(%esp)
  800dce:	e8 b3 03 00 00       	call   801186 <_panic>

	return ret;
  800dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800dd6:	83 c4 3c             	add    $0x3c,%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800dee:	00 
  800def:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800df6:	00 
  800df7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800dfe:	00 
  800dff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e02:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e06:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e11:	00 
  800e12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e19:	e8 5f ff ff ff       	call   800d7d <syscall>
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e26:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e2d:	00 
  800e2e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e35:	00 
  800e36:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e45:	00 
  800e46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e55:	00 
  800e56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e5d:	e8 1b ff ff ff       	call   800d7d <syscall>
}
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e74:	00 
  800e75:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e84:	00 
  800e85:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8c:	00 
  800e8d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e91:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ea0:	e8 d8 fe ff ff       	call   800d7d <syscall>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ead:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800edc:	00 
  800edd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ee4:	e8 94 fe ff ff       	call   800d7d <syscall>
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <sys_yield>:

void
sys_yield(void)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ef1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f00:	00 
  800f01:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f08:	00 
  800f09:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f10:	00 
  800f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f18:	00 
  800f19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f20:	00 
  800f21:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f28:	e8 50 fe ff ff       	call   800d7d <syscall>
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f35:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f45:	00 
  800f46:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f4d:	00 
  800f4e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f52:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f69:	e8 0f fe ff ff       	call   800d7d <syscall>
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f78:	8b 75 18             	mov    0x18(%ebp),%esi
  800f7b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	89 74 24 18          	mov    %esi,0x18(%esp)
  800f8b:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800f8f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f93:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa2:	00 
  800fa3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800faa:	e8 ce fd ff ff       	call   800d7d <syscall>
}
  800faf:	83 c4 20             	add    $0x20,%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fc9:	00 
  800fca:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fd9:	00 
  800fda:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fde:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe9:	00 
  800fea:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800ff1:	e8 87 fd ff ff       	call   800d7d <syscall>
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ffe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801001:	8b 45 08             	mov    0x8(%ebp),%eax
  801004:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80100b:	00 
  80100c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801013:	00 
  801014:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80101b:	00 
  80101c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801020:	89 44 24 08          	mov    %eax,0x8(%esp)
  801024:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80102b:	00 
  80102c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801033:	e8 45 fd ff ff       	call   800d7d <syscall>
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801040:	8b 55 0c             	mov    0xc(%ebp),%edx
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80104d:	00 
  80104e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801055:	00 
  801056:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80105d:	00 
  80105e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801062:	89 44 24 08          	mov    %eax,0x8(%esp)
  801066:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80106d:	00 
  80106e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801075:	e8 03 fd ff ff       	call   800d7d <syscall>
}
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801082:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801085:	8b 55 10             	mov    0x10(%ebp),%edx
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
  80108b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801092:	00 
  801093:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801097:	89 54 24 10          	mov    %edx,0x10(%esp)
  80109b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010b5:	e8 c3 fc ff ff       	call   800d7d <syscall>
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cc:	00 
  8010cd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e4:	00 
  8010e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8010f8:	e8 80 fc ff ff       	call   800d7d <syscall>
}
  8010fd:	c9                   	leave  
  8010fe:	c3                   	ret    

008010ff <sys_exec>:

void sys_exec(char* buf){
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
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
  80112c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801133:	00 
  801134:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80113b:	e8 3d fc ff ff       	call   800d7d <syscall>
}
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <sys_wait>:

void sys_wait(){
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  801148:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80114f:	00 
  801150:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801157:	00 
  801158:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80115f:	00 
  801160:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801167:	00 
  801168:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80116f:	00 
  801170:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801177:	00 
  801178:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80117f:	e8 f9 fb ff ff       	call   800d7d <syscall>
  801184:	c9                   	leave  
  801185:	c3                   	ret    

00801186 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80118d:	8d 45 14             	lea    0x14(%ebp),%eax
  801190:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801193:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801199:	e8 09 fd ff ff       	call   800ea7 <sys_getenvid>
  80119e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b4:	c7 04 24 30 17 80 00 	movl   $0x801730,(%esp)
  8011bb:	e8 b2 ef ff ff       	call   800172 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ca:	89 04 24             	mov    %eax,(%esp)
  8011cd:	e8 3c ef ff ff       	call   80010e <vcprintf>
	cprintf("\n");
  8011d2:	c7 04 24 53 17 80 00 	movl   $0x801753,(%esp)
  8011d9:	e8 94 ef ff ff       	call   800172 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011de:	cc                   	int3   
  8011df:	eb fd                	jmp    8011de <_panic+0x58>
  8011e1:	66 90                	xchg   %ax,%ax
  8011e3:	66 90                	xchg   %ax,%ax
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
