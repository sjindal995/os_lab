
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 64 00 00 00       	call   800095 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	void *addr = (void*)utf->utf_fault_va;
  800039:	8b 45 08             	mov    0x8(%ebp),%eax
  80003c:	8b 00                	mov    (%eax),%eax
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	8b 40 04             	mov    0x4(%eax),%eax
  800047:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80004a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80004d:	83 e0 07             	and    $0x7,%eax
  800050:	89 44 24 08          	mov    %eax,0x8(%esp)
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005b:	c7 04 24 60 15 80 00 	movl   $0x801560,(%esp)
  800062:	e8 41 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(sys_getenvid());
  800067:	e8 71 0e 00 00       	call   800edd <sys_getenvid>
  80006c:	89 04 24             	mov    %eax,(%esp)
  80006f:	e8 26 0e 00 00       	call   800e9a <sys_env_destroy>
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    

00800076 <umain>:

void
umain(int argc, char **argv)
{
  800076:	55                   	push   %ebp
  800077:	89 e5                	mov    %esp,%ebp
  800079:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007c:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  800083:	e8 34 11 00 00       	call   8011bc <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800088:	b8 ef be ad de       	mov    $0xdeadbeef,%eax
  80008d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80009b:	e8 3d 0e 00 00       	call   800edd <sys_getenvid>
  8000a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a5:	c1 e0 02             	shl    $0x2,%eax
  8000a8:	89 c2                	mov    %eax,%edx
  8000aa:	c1 e2 05             	shl    $0x5,%edx
  8000ad:	29 c2                	sub    %eax,%edx
  8000af:	89 d0                	mov    %edx,%eax
  8000b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b6:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  8000bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c5:	89 04 24             	mov    %eax,(%esp)
  8000c8:	e8 a9 ff ff ff       	call   800076 <umain>

	// exit gracefully
	exit();
  8000cd:	e8 02 00 00 00       	call   8000d4 <exit>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e1:	e8 b4 0d 00 00       	call   800e9a <sys_env_destroy>
}
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f1:	8b 00                	mov    (%eax),%eax
  8000f3:	8d 48 01             	lea    0x1(%eax),%ecx
  8000f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000f9:	89 0a                	mov    %ecx,(%edx)
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	89 d1                	mov    %edx,%ecx
  800100:	8b 55 0c             	mov    0xc(%ebp),%edx
  800103:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010a:	8b 00                	mov    (%eax),%eax
  80010c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800111:	75 20                	jne    800133 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800113:	8b 45 0c             	mov    0xc(%ebp),%eax
  800116:	8b 00                	mov    (%eax),%eax
  800118:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011b:	83 c2 08             	add    $0x8,%edx
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	89 14 24             	mov    %edx,(%esp)
  800125:	e8 ea 0c 00 00       	call   800e14 <sys_cputs>
		b->idx = 0;
  80012a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	8b 40 04             	mov    0x4(%eax),%eax
  800139:	8d 50 01             	lea    0x1(%eax),%edx
  80013c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013f:	89 50 04             	mov    %edx,0x4(%eax)
}
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800154:	00 00 00 
	b.cnt = 0;
  800157:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800161:	8b 45 0c             	mov    0xc(%ebp),%eax
  800164:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800168:	8b 45 08             	mov    0x8(%ebp),%eax
  80016b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80016f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	c7 04 24 e8 00 80 00 	movl   $0x8000e8,(%esp)
  800180:	e8 bd 01 00 00       	call   800342 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	83 c0 08             	add    $0x8,%eax
  800198:	89 04 24             	mov    %eax,(%esp)
  80019b:	e8 74 0c 00 00       	call   800e14 <sys_cputs>

	return b.cnt;
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 7e ff ff ff       	call   800144 <vcprintf>
  8001c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 34             	sub    $0x34,%esp
  8001d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001db:	8b 45 14             	mov    0x14(%ebp),%eax
  8001de:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001e9:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ec:	77 72                	ja     800260 <printnum+0x92>
  8001ee:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001f1:	72 05                	jb     8001f8 <printnum+0x2a>
  8001f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001f6:	77 68                	ja     800260 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001fb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fe:	8b 45 18             	mov    0x18(%ebp),%eax
  800201:	ba 00 00 00 00       	mov    $0x0,%edx
  800206:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80020e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800211:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021b:	e8 a0 10 00 00       	call   8012c0 <__udivdi3>
  800220:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800223:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800227:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80022b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80022e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800232:	89 44 24 08          	mov    %eax,0x8(%esp)
  800236:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80023a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	e8 82 ff ff ff       	call   8001ce <printnum>
  80024c:	eb 1c                	jmp    80026a <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	8b 45 20             	mov    0x20(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800264:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800268:	7f e4                	jg     80024e <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026a:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800275:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	89 54 24 04          	mov    %edx,0x4(%esp)
  800287:	e8 64 11 00 00       	call   8013f0 <__umoddi3>
  80028c:	05 68 16 80 00       	add    $0x801668,%eax
  800291:	0f b6 00             	movzbl (%eax),%eax
  800294:	0f be c0             	movsbl %al,%eax
  800297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029e:	89 04 24             	mov    %eax,(%esp)
  8002a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a4:	ff d0                	call   *%eax
}
  8002a6:	83 c4 34             	add    $0x34,%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002b3:	7e 14                	jle    8002c9 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 00                	mov    (%eax),%eax
  8002ba:	8d 48 08             	lea    0x8(%eax),%ecx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 0a                	mov    %ecx,(%edx)
  8002c2:	8b 50 04             	mov    0x4(%eax),%edx
  8002c5:	8b 00                	mov    (%eax),%eax
  8002c7:	eb 30                	jmp    8002f9 <getuint+0x4d>
	else if (lflag)
  8002c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002cd:	74 16                	je     8002e5 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	8b 00                	mov    (%eax),%eax
  8002d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	89 0a                	mov    %ecx,(%edx)
  8002dc:	8b 00                	mov    (%eax),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	eb 14                	jmp    8002f9 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	8b 00                	mov    (%eax),%eax
  8002ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	89 0a                	mov    %ecx,(%edx)
  8002f2:	8b 00                	mov    (%eax),%eax
  8002f4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fe:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800302:	7e 14                	jle    800318 <getint+0x1d>
		return va_arg(*ap, long long);
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	8b 00                	mov    (%eax),%eax
  800309:	8d 48 08             	lea    0x8(%eax),%ecx
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	89 0a                	mov    %ecx,(%edx)
  800311:	8b 50 04             	mov    0x4(%eax),%edx
  800314:	8b 00                	mov    (%eax),%eax
  800316:	eb 28                	jmp    800340 <getint+0x45>
	else if (lflag)
  800318:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80031c:	74 12                	je     800330 <getint+0x35>
		return va_arg(*ap, long);
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	8b 00                	mov    (%eax),%eax
  800323:	8d 48 04             	lea    0x4(%eax),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 0a                	mov    %ecx,(%edx)
  80032b:	8b 00                	mov    (%eax),%eax
  80032d:	99                   	cltd   
  80032e:	eb 10                	jmp    800340 <getint+0x45>
	else
		return va_arg(*ap, int);
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 00                	mov    (%eax),%eax
  800335:	8d 48 04             	lea    0x4(%eax),%ecx
  800338:	8b 55 08             	mov    0x8(%ebp),%edx
  80033b:	89 0a                	mov    %ecx,(%edx)
  80033d:	8b 00                	mov    (%eax),%eax
  80033f:	99                   	cltd   
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
  800347:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034a:	eb 18                	jmp    800364 <vprintfmt+0x22>
			if (ch == '\0')
  80034c:	85 db                	test   %ebx,%ebx
  80034e:	75 05                	jne    800355 <vprintfmt+0x13>
				return;
  800350:	e9 cc 03 00 00       	jmp    800721 <vprintfmt+0x3df>
			putch(ch, putdat);
  800355:	8b 45 0c             	mov    0xc(%ebp),%eax
  800358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035c:	89 1c 24             	mov    %ebx,(%esp)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
  800367:	8d 50 01             	lea    0x1(%eax),%edx
  80036a:	89 55 10             	mov    %edx,0x10(%ebp)
  80036d:	0f b6 00             	movzbl (%eax),%eax
  800370:	0f b6 d8             	movzbl %al,%ebx
  800373:	83 fb 25             	cmp    $0x25,%ebx
  800376:	75 d4                	jne    80034c <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800378:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80037c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800383:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80038a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800391:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 45 10             	mov    0x10(%ebp),%eax
  80039b:	8d 50 01             	lea    0x1(%eax),%edx
  80039e:	89 55 10             	mov    %edx,0x10(%ebp)
  8003a1:	0f b6 00             	movzbl (%eax),%eax
  8003a4:	0f b6 d8             	movzbl %al,%ebx
  8003a7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003aa:	83 f8 55             	cmp    $0x55,%eax
  8003ad:	0f 87 3d 03 00 00    	ja     8006f0 <vprintfmt+0x3ae>
  8003b3:	8b 04 85 8c 16 80 00 	mov    0x80168c(,%eax,4),%eax
  8003ba:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003c6:	eb d0                	jmp    800398 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d2:	89 d0                	mov    %edx,%eax
  8003d4:	c1 e0 02             	shl    $0x2,%eax
  8003d7:	01 d0                	add    %edx,%eax
  8003d9:	01 c0                	add    %eax,%eax
  8003db:	01 d8                	add    %ebx,%eax
  8003dd:	83 e8 30             	sub    $0x30,%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e6:	0f b6 00             	movzbl (%eax),%eax
  8003e9:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003ec:	83 fb 2f             	cmp    $0x2f,%ebx
  8003ef:	7e 0b                	jle    8003fc <vprintfmt+0xba>
  8003f1:	83 fb 39             	cmp    $0x39,%ebx
  8003f4:	7f 06                	jg     8003fc <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fa:	eb d3                	jmp    8003cf <vprintfmt+0x8d>
			goto process_precision;
  8003fc:	eb 33                	jmp    800431 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80040c:	eb 23                	jmp    800431 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80040e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800412:	79 0c                	jns    800420 <vprintfmt+0xde>
				width = 0;
  800414:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80041b:	e9 78 ff ff ff       	jmp    800398 <vprintfmt+0x56>
  800420:	e9 73 ff ff ff       	jmp    800398 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800425:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80042c:	e9 67 ff ff ff       	jmp    800398 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800431:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800435:	79 12                	jns    800449 <vprintfmt+0x107>
				width = precision, precision = -1;
  800437:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80043a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800444:	e9 4f ff ff ff       	jmp    800398 <vprintfmt+0x56>
  800449:	e9 4a ff ff ff       	jmp    800398 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800452:	e9 41 ff ff ff       	jmp    800398 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	8b 00                	mov    (%eax),%eax
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 54 24 04          	mov    %edx,0x4(%esp)
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	8b 45 08             	mov    0x8(%ebp),%eax
  80046f:	ff d0                	call   *%eax
			break;
  800471:	e9 a5 02 00 00       	jmp    80071b <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800481:	85 db                	test   %ebx,%ebx
  800483:	79 02                	jns    800487 <vprintfmt+0x145>
				err = -err;
  800485:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800487:	83 fb 09             	cmp    $0x9,%ebx
  80048a:	7f 0b                	jg     800497 <vprintfmt+0x155>
  80048c:	8b 34 9d 40 16 80 00 	mov    0x801640(,%ebx,4),%esi
  800493:	85 f6                	test   %esi,%esi
  800495:	75 23                	jne    8004ba <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800497:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80049b:	c7 44 24 08 79 16 80 	movl   $0x801679,0x8(%esp)
  8004a2:	00 
  8004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ad:	89 04 24             	mov    %eax,(%esp)
  8004b0:	e8 73 02 00 00       	call   800728 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004b5:	e9 61 02 00 00       	jmp    80071b <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004be:	c7 44 24 08 82 16 80 	movl   $0x801682,0x8(%esp)
  8004c5:	00 
  8004c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 50 02 00 00       	call   800728 <printfmt>
			break;
  8004d8:	e9 3e 02 00 00       	jmp    80071b <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 30                	mov    (%eax),%esi
  8004e8:	85 f6                	test   %esi,%esi
  8004ea:	75 05                	jne    8004f1 <vprintfmt+0x1af>
				p = "(null)";
  8004ec:	be 85 16 80 00       	mov    $0x801685,%esi
			if (width > 0 && padc != '-')
  8004f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f5:	7e 37                	jle    80052e <vprintfmt+0x1ec>
  8004f7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004fb:	74 31                	je     80052e <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	89 34 24             	mov    %esi,(%esp)
  800507:	e8 39 03 00 00       	call   800845 <strnlen>
  80050c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80050f:	eb 17                	jmp    800528 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800511:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800515:	8b 55 0c             	mov    0xc(%ebp),%edx
  800518:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051c:	89 04 24             	mov    %eax,(%esp)
  80051f:	8b 45 08             	mov    0x8(%ebp),%eax
  800522:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800528:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052c:	7f e3                	jg     800511 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	eb 38                	jmp    800568 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800530:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800534:	74 1f                	je     800555 <vprintfmt+0x213>
  800536:	83 fb 1f             	cmp    $0x1f,%ebx
  800539:	7e 05                	jle    800540 <vprintfmt+0x1fe>
  80053b:	83 fb 7e             	cmp    $0x7e,%ebx
  80053e:	7e 15                	jle    800555 <vprintfmt+0x213>
					putch('?', putdat);
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
  800543:	89 44 24 04          	mov    %eax,0x4(%esp)
  800547:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	ff d0                	call   *%eax
  800553:	eb 0f                	jmp    800564 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	89 1c 24             	mov    %ebx,(%esp)
  80055f:	8b 45 08             	mov    0x8(%ebp),%eax
  800562:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800564:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800568:	89 f0                	mov    %esi,%eax
  80056a:	8d 70 01             	lea    0x1(%eax),%esi
  80056d:	0f b6 00             	movzbl (%eax),%eax
  800570:	0f be d8             	movsbl %al,%ebx
  800573:	85 db                	test   %ebx,%ebx
  800575:	74 10                	je     800587 <vprintfmt+0x245>
  800577:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057b:	78 b3                	js     800530 <vprintfmt+0x1ee>
  80057d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	79 a9                	jns    800530 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	eb 17                	jmp    8005a0 <vprintfmt+0x25e>
				putch(' ', putdat);
  800589:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800590:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800597:	8b 45 08             	mov    0x8(%ebp),%eax
  80059a:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a4:	7f e3                	jg     800589 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005a6:	e9 70 01 00 00       	jmp    80071b <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	e8 3e fd ff ff       	call   8002fb <getint>
  8005bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005c0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	79 26                	jns    8005f3 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005db:	8b 45 08             	mov    0x8(%ebp),%eax
  8005de:	ff d0                	call   *%eax
				num = -(long long) num;
  8005e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e6:	f7 d8                	neg    %eax
  8005e8:	83 d2 00             	adc    $0x0,%edx
  8005eb:	f7 da                	neg    %edx
  8005ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005f3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005fa:	e9 a8 00 00 00       	jmp    8006a7 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800602:	89 44 24 04          	mov    %eax,0x4(%esp)
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	89 04 24             	mov    %eax,(%esp)
  80060c:	e8 9b fc ff ff       	call   8002ac <getuint>
  800611:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800614:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800617:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80061e:	e9 84 00 00 00       	jmp    8006a7 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800623:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	e8 77 fc ff ff       	call   8002ac <getuint>
  800635:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800638:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80063b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800642:	eb 63                	jmp    8006a7 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	8b 45 0c             	mov    0xc(%ebp),%eax
  800647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	ff d0                	call   *%eax
			putch('x', putdat);
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 50 04             	lea    0x4(%eax),%edx
  800670:	89 55 14             	mov    %edx,0x14(%ebp)
  800673:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800675:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800678:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800686:	eb 1f                	jmp    8006a7 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800688:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80068b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	e8 12 fc ff ff       	call   8002ac <getuint>
  80069a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80069d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006a0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ae:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b5:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	e8 f1 fa ff ff       	call   8001ce <printnum>
			break;
  8006dd:	eb 3c                	jmp    80071b <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	89 1c 24             	mov    %ebx,(%esp)
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	ff d0                	call   *%eax
			break;
  8006ee:	eb 2b                	jmp    80071b <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800703:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800707:	eb 04                	jmp    80070d <vprintfmt+0x3cb>
  800709:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80070d:	8b 45 10             	mov    0x10(%ebp),%eax
  800710:	83 e8 01             	sub    $0x1,%eax
  800713:	0f b6 00             	movzbl (%eax),%eax
  800716:	3c 25                	cmp    $0x25,%al
  800718:	75 ef                	jne    800709 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80071a:	90                   	nop
		}
	}
  80071b:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071c:	e9 43 fc ff ff       	jmp    800364 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800721:	83 c4 40             	add    $0x40,%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80072e:	8d 45 14             	lea    0x14(%ebp),%eax
  800731:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073b:	8b 45 10             	mov    0x10(%ebp),%eax
  80073e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
  800745:	89 44 24 04          	mov    %eax,0x4(%esp)
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	89 04 24             	mov    %eax,(%esp)
  80074f:	e8 ee fb ff ff       	call   800342 <vprintfmt>
	va_end(ap);
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075c:	8b 40 08             	mov    0x8(%eax),%eax
  80075f:	8d 50 01             	lea    0x1(%eax),%edx
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
  800765:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076b:	8b 10                	mov    (%eax),%edx
  80076d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800770:	8b 40 04             	mov    0x4(%eax),%eax
  800773:	39 c2                	cmp    %eax,%edx
  800775:	73 12                	jae    800789 <sprintputch+0x33>
		*b->buf++ = ch;
  800777:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077a:	8b 00                	mov    (%eax),%eax
  80077c:	8d 48 01             	lea    0x1(%eax),%ecx
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800782:	89 0a                	mov    %ecx,(%edx)
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
  800787:	88 10                	mov    %dl,(%eax)
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	01 d0                	add    %edx,%eax
  8007a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007b0:	74 06                	je     8007b8 <vsnprintf+0x2d>
  8007b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007b6:	7f 07                	jg     8007bf <vsnprintf+0x34>
		return -E_INVAL;
  8007b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bd:	eb 2a                	jmp    8007e9 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	c7 04 24 56 07 80 00 	movl   $0x800756,(%esp)
  8007db:	e8 62 fb ff ff       	call   800342 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    

008007eb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800801:	89 44 24 08          	mov    %eax,0x8(%esp)
  800805:	8b 45 0c             	mov    0xc(%ebp),%eax
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	8b 45 08             	mov    0x8(%ebp),%eax
  80080f:	89 04 24             	mov    %eax,(%esp)
  800812:	e8 74 ff ff ff       	call   80078b <vsnprintf>
  800817:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80081a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800825:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80082c:	eb 08                	jmp    800836 <strlen+0x17>
		n++;
  80082e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800832:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	0f b6 00             	movzbl (%eax),%eax
  80083c:	84 c0                	test   %al,%al
  80083e:	75 ee                	jne    80082e <strlen+0xf>
		n++;
	return n;
  800840:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800852:	eb 0c                	jmp    800860 <strnlen+0x1b>
		n++;
  800854:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800858:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80085c:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800860:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800864:	74 0a                	je     800870 <strnlen+0x2b>
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	0f b6 00             	movzbl (%eax),%eax
  80086c:	84 c0                	test   %al,%al
  80086e:	75 e4                	jne    800854 <strnlen+0xf>
		n++;
	return n;
  800870:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800881:	90                   	nop
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8d 50 01             	lea    0x1(%eax),%edx
  800888:	89 55 08             	mov    %edx,0x8(%ebp)
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800891:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800894:	0f b6 12             	movzbl (%edx),%edx
  800897:	88 10                	mov    %dl,(%eax)
  800899:	0f b6 00             	movzbl (%eax),%eax
  80089c:	84 c0                	test   %al,%al
  80089e:	75 e2                	jne    800882 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	e8 69 ff ff ff       	call   80081f <strlen>
  8008b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008b9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	01 c2                	add    %eax,%edx
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	89 14 24             	mov    %edx,(%esp)
  8008cb:	e8 a5 ff ff ff       	call   800875 <strcpy>
	return dst;
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008e8:	eb 23                	jmp    80090d <strncpy+0x38>
		*dst++ = *src;
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8d 50 01             	lea    0x1(%eax),%edx
  8008f0:	89 55 08             	mov    %edx,0x8(%ebp)
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	0f b6 12             	movzbl (%edx),%edx
  8008f9:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	84 c0                	test   %al,%al
  800903:	74 04                	je     800909 <strncpy+0x34>
			src++;
  800905:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80090d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800910:	3b 45 10             	cmp    0x10(%ebp),%eax
  800913:	72 d5                	jb     8008ea <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800915:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800926:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80092a:	74 33                	je     80095f <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80092c:	eb 17                	jmp    800945 <strlcpy+0x2b>
			*dst++ = *src++;
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8d 50 01             	lea    0x1(%eax),%edx
  800934:	89 55 08             	mov    %edx,0x8(%ebp)
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80093d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800940:	0f b6 12             	movzbl (%edx),%edx
  800943:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800945:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800949:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80094d:	74 0a                	je     800959 <strlcpy+0x3f>
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	0f b6 00             	movzbl (%eax),%eax
  800955:	84 c0                	test   %al,%al
  800957:	75 d5                	jne    80092e <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095f:	8b 55 08             	mov    0x8(%ebp),%edx
  800962:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800965:	29 c2                	sub    %eax,%edx
  800967:	89 d0                	mov    %edx,%eax
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80096e:	eb 08                	jmp    800978 <strcmp+0xd>
		p++, q++;
  800970:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800974:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	0f b6 00             	movzbl (%eax),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 10                	je     800992 <strcmp+0x27>
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098b:	0f b6 00             	movzbl (%eax),%eax
  80098e:	38 c2                	cmp    %al,%dl
  800990:	74 de                	je     800970 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	0f b6 00             	movzbl (%eax),%eax
  800998:	0f b6 d0             	movzbl %al,%edx
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	0f b6 00             	movzbl (%eax),%eax
  8009a1:	0f b6 c0             	movzbl %al,%eax
  8009a4:	29 c2                	sub    %eax,%edx
  8009a6:	89 d0                	mov    %edx,%eax
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009ad:	eb 0c                	jmp    8009bb <strncmp+0x11>
		n--, p++, q++;
  8009af:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009b3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009b7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009bf:	74 1a                	je     8009db <strncmp+0x31>
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	0f b6 00             	movzbl (%eax),%eax
  8009c7:	84 c0                	test   %al,%al
  8009c9:	74 10                	je     8009db <strncmp+0x31>
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d4:	0f b6 00             	movzbl (%eax),%eax
  8009d7:	38 c2                	cmp    %al,%dl
  8009d9:	74 d4                	je     8009af <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009df:	75 07                	jne    8009e8 <strncmp+0x3e>
		return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	eb 16                	jmp    8009fe <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 00             	movzbl (%eax),%eax
  8009ee:	0f b6 d0             	movzbl %al,%edx
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	0f b6 00             	movzbl (%eax),%eax
  8009f7:	0f b6 c0             	movzbl %al,%eax
  8009fa:	29 c2                	sub    %eax,%edx
  8009fc:	89 d0                	mov    %edx,%eax
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 04             	sub    $0x4,%esp
  800a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a09:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a0c:	eb 14                	jmp    800a22 <strchr+0x22>
		if (*s == c)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 00             	movzbl (%eax),%eax
  800a14:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a17:	75 05                	jne    800a1e <strchr+0x1e>
			return (char *) s;
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	eb 13                	jmp    800a31 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 00             	movzbl (%eax),%eax
  800a28:	84 c0                	test   %al,%al
  800a2a:	75 e2                	jne    800a0e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	83 ec 04             	sub    $0x4,%esp
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a3f:	eb 11                	jmp    800a52 <strfind+0x1f>
		if (*s == c)
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	0f b6 00             	movzbl (%eax),%eax
  800a47:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a4a:	75 02                	jne    800a4e <strfind+0x1b>
			break;
  800a4c:	eb 0e                	jmp    800a5c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	0f b6 00             	movzbl (%eax),%eax
  800a58:	84 c0                	test   %al,%al
  800a5a:	75 e5                	jne    800a41 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a5f:	c9                   	leave  
  800a60:	c3                   	ret    

00800a61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a69:	75 05                	jne    800a70 <memset+0xf>
		return v;
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	eb 5c                	jmp    800acc <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	83 e0 03             	and    $0x3,%eax
  800a76:	85 c0                	test   %eax,%eax
  800a78:	75 41                	jne    800abb <memset+0x5a>
  800a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7d:	83 e0 03             	and    $0x3,%eax
  800a80:	85 c0                	test   %eax,%eax
  800a82:	75 37                	jne    800abb <memset+0x5a>
		c &= 0xFF;
  800a84:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	c1 e0 18             	shl    $0x18,%eax
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	c1 e0 10             	shl    $0x10,%eax
  800a99:	09 c2                	or     %eax,%edx
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	c1 e0 08             	shl    $0x8,%eax
  800aa1:	09 d0                	or     %edx,%eax
  800aa3:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa9:	c1 e8 02             	shr    $0x2,%eax
  800aac:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	89 d7                	mov    %edx,%edi
  800ab6:	fc                   	cld    
  800ab7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab9:	eb 0e                	jmp    800ac9 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abb:	8b 55 08             	mov    0x8(%ebp),%edx
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ac4:	89 d7                	mov    %edx,%edi
  800ac6:	fc                   	cld    
  800ac7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800aea:	73 6d                	jae    800b59 <memmove+0x8a>
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
  800aef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800af2:	01 d0                	add    %edx,%eax
  800af4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800af7:	76 60                	jbe    800b59 <memmove+0x8a>
		s += n;
  800af9:	8b 45 10             	mov    0x10(%ebp),%eax
  800afc:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800aff:	8b 45 10             	mov    0x10(%ebp),%eax
  800b02:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b08:	83 e0 03             	and    $0x3,%eax
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	75 2f                	jne    800b3e <memmove+0x6f>
  800b0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b12:	83 e0 03             	and    $0x3,%eax
  800b15:	85 c0                	test   %eax,%eax
  800b17:	75 25                	jne    800b3e <memmove+0x6f>
  800b19:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1c:	83 e0 03             	and    $0x3,%eax
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	75 1b                	jne    800b3e <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b23:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b26:	83 e8 04             	sub    $0x4,%eax
  800b29:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b2c:	83 ea 04             	sub    $0x4,%edx
  800b2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b32:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	fd                   	std    
  800b3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3c:	eb 18                	jmp    800b56 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b41:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b47:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 de                	mov    %ebx,%esi
  800b51:	89 c1                	mov    %eax,%ecx
  800b53:	fd                   	std    
  800b54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b56:	fc                   	cld    
  800b57:	eb 45                	jmp    800b9e <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5c:	83 e0 03             	and    $0x3,%eax
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	75 2b                	jne    800b8e <memmove+0xbf>
  800b63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b66:	83 e0 03             	and    $0x3,%eax
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	75 21                	jne    800b8e <memmove+0xbf>
  800b6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b70:	83 e0 03             	and    $0x3,%eax
  800b73:	85 c0                	test   %eax,%eax
  800b75:	75 17                	jne    800b8e <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b77:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7a:	c1 e8 02             	shr    $0x2,%eax
  800b7d:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b82:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	fc                   	cld    
  800b8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8c:	eb 10                	jmp    800b9e <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b91:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b94:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b97:	89 c7                	mov    %eax,%edi
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	fc                   	cld    
  800b9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ba1:	83 c4 10             	add    $0x10,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800baf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	89 04 24             	mov    %eax,(%esp)
  800bc3:	e8 07 ff ff ff       	call   800acf <memmove>
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd9:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bdc:	eb 30                	jmp    800c0e <memcmp+0x44>
		if (*s1 != *s2)
  800bde:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800be1:	0f b6 10             	movzbl (%eax),%edx
  800be4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800be7:	0f b6 00             	movzbl (%eax),%eax
  800bea:	38 c2                	cmp    %al,%dl
  800bec:	74 18                	je     800c06 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf1:	0f b6 00             	movzbl (%eax),%eax
  800bf4:	0f b6 d0             	movzbl %al,%edx
  800bf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bfa:	0f b6 00             	movzbl (%eax),%eax
  800bfd:	0f b6 c0             	movzbl %al,%eax
  800c00:	29 c2                	sub    %eax,%edx
  800c02:	89 d0                	mov    %edx,%eax
  800c04:	eb 1a                	jmp    800c20 <memcmp+0x56>
		s1++, s2++;
  800c06:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c0a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c11:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c14:	89 55 10             	mov    %edx,0x10(%ebp)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	75 c3                	jne    800bde <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c28:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	01 d0                	add    %edx,%eax
  800c30:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c33:	eb 13                	jmp    800c48 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	0f b6 10             	movzbl (%eax),%edx
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	38 c2                	cmp    %al,%dl
  800c40:	75 02                	jne    800c44 <memfind+0x22>
			break;
  800c42:	eb 0c                	jmp    800c50 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c4e:	72 e5                	jb     800c35 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c5b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c62:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	eb 04                	jmp    800c6f <strtol+0x1a>
		s++;
  800c6b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	0f b6 00             	movzbl (%eax),%eax
  800c75:	3c 20                	cmp    $0x20,%al
  800c77:	74 f2                	je     800c6b <strtol+0x16>
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	0f b6 00             	movzbl (%eax),%eax
  800c7f:	3c 09                	cmp    $0x9,%al
  800c81:	74 e8                	je     800c6b <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	0f b6 00             	movzbl (%eax),%eax
  800c89:	3c 2b                	cmp    $0x2b,%al
  800c8b:	75 06                	jne    800c93 <strtol+0x3e>
		s++;
  800c8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c91:	eb 15                	jmp    800ca8 <strtol+0x53>
	else if (*s == '-')
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	0f b6 00             	movzbl (%eax),%eax
  800c99:	3c 2d                	cmp    $0x2d,%al
  800c9b:	75 0b                	jne    800ca8 <strtol+0x53>
		s++, neg = 1;
  800c9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca1:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cac:	74 06                	je     800cb4 <strtol+0x5f>
  800cae:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cb2:	75 24                	jne    800cd8 <strtol+0x83>
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	0f b6 00             	movzbl (%eax),%eax
  800cba:	3c 30                	cmp    $0x30,%al
  800cbc:	75 1a                	jne    800cd8 <strtol+0x83>
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	0f b6 00             	movzbl (%eax),%eax
  800cc7:	3c 78                	cmp    $0x78,%al
  800cc9:	75 0d                	jne    800cd8 <strtol+0x83>
		s += 2, base = 16;
  800ccb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800ccf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cd6:	eb 2a                	jmp    800d02 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cdc:	75 17                	jne    800cf5 <strtol+0xa0>
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 00             	movzbl (%eax),%eax
  800ce4:	3c 30                	cmp    $0x30,%al
  800ce6:	75 0d                	jne    800cf5 <strtol+0xa0>
		s++, base = 8;
  800ce8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cec:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800cf3:	eb 0d                	jmp    800d02 <strtol+0xad>
	else if (base == 0)
  800cf5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf9:	75 07                	jne    800d02 <strtol+0xad>
		base = 10;
  800cfb:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	0f b6 00             	movzbl (%eax),%eax
  800d08:	3c 2f                	cmp    $0x2f,%al
  800d0a:	7e 1b                	jle    800d27 <strtol+0xd2>
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	0f b6 00             	movzbl (%eax),%eax
  800d12:	3c 39                	cmp    $0x39,%al
  800d14:	7f 11                	jg     800d27 <strtol+0xd2>
			dig = *s - '0';
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	0f b6 00             	movzbl (%eax),%eax
  800d1c:	0f be c0             	movsbl %al,%eax
  800d1f:	83 e8 30             	sub    $0x30,%eax
  800d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d25:	eb 48                	jmp    800d6f <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	0f b6 00             	movzbl (%eax),%eax
  800d2d:	3c 60                	cmp    $0x60,%al
  800d2f:	7e 1b                	jle    800d4c <strtol+0xf7>
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	0f b6 00             	movzbl (%eax),%eax
  800d37:	3c 7a                	cmp    $0x7a,%al
  800d39:	7f 11                	jg     800d4c <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	0f b6 00             	movzbl (%eax),%eax
  800d41:	0f be c0             	movsbl %al,%eax
  800d44:	83 e8 57             	sub    $0x57,%eax
  800d47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d4a:	eb 23                	jmp    800d6f <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	3c 40                	cmp    $0x40,%al
  800d54:	7e 3d                	jle    800d93 <strtol+0x13e>
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	0f b6 00             	movzbl (%eax),%eax
  800d5c:	3c 5a                	cmp    $0x5a,%al
  800d5e:	7f 33                	jg     800d93 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	0f be c0             	movsbl %al,%eax
  800d69:	83 e8 37             	sub    $0x37,%eax
  800d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d72:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d75:	7c 02                	jl     800d79 <strtol+0x124>
			break;
  800d77:	eb 1a                	jmp    800d93 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d79:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d80:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d89:	01 d0                	add    %edx,%eax
  800d8b:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d8e:	e9 6f ff ff ff       	jmp    800d02 <strtol+0xad>

	if (endptr)
  800d93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d97:	74 08                	je     800da1 <strtol+0x14c>
		*endptr = (char *) s;
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800da1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800da5:	74 07                	je     800dae <strtol+0x159>
  800da7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800daa:	f7 d8                	neg    %eax
  800dac:	eb 03                	jmp    800db1 <strtol+0x15c>
  800dae:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	8b 55 10             	mov    0x10(%ebp),%edx
  800dc2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dc5:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dc8:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800dcb:	8b 75 20             	mov    0x20(%ebp),%esi
  800dce:	cd 30                	int    $0x30
  800dd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd7:	74 30                	je     800e09 <syscall+0x56>
  800dd9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ddd:	7e 2a                	jle    800e09 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ded:	c7 44 24 08 e4 17 80 	movl   $0x8017e4,0x8(%esp)
  800df4:	00 
  800df5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfc:	00 
  800dfd:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  800e04:	e8 4d 04 00 00       	call   801256 <_panic>

	return ret;
  800e09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e0c:	83 c4 3c             	add    $0x3c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e24:	00 
  800e25:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e34:	00 
  800e35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e38:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e47:	00 
  800e48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4f:	e8 5f ff ff ff       	call   800db3 <syscall>
}
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e5c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e63:	00 
  800e64:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e6b:	00 
  800e6c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e73:	00 
  800e74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e93:	e8 1b ff ff ff       	call   800db3 <syscall>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eaa:	00 
  800eab:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eb2:	00 
  800eb3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eba:	00 
  800ebb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec2:	00 
  800ec3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ece:	00 
  800ecf:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ed6:	e8 d8 fe ff ff       	call   800db3 <syscall>
}
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ee3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eea:	00 
  800eeb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800efa:	00 
  800efb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f02:	00 
  800f03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f12:	00 
  800f13:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f1a:	e8 94 fe ff ff       	call   800db3 <syscall>
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <sys_yield>:

void
sys_yield(void)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f27:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f2e:	00 
  800f2f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f36:	00 
  800f37:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f56:	00 
  800f57:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f5e:	e8 50 fe ff ff       	call   800db3 <syscall>
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
  800f74:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f83:	00 
  800f84:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f88:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f90:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f97:	00 
  800f98:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800f9f:	e8 0f fe ff ff       	call   800db3 <syscall>
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
  800fab:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fae:	8b 75 18             	mov    0x18(%ebp),%esi
  800fb1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fc1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fc5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fcd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fd8:	00 
  800fd9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800fe0:	e8 ce fd ff ff       	call   800db3 <syscall>
}
  800fe5:	83 c4 20             	add    $0x20,%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fff:	00 
  801000:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801007:	00 
  801008:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80100f:	00 
  801010:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801014:	89 44 24 08          	mov    %eax,0x8(%esp)
  801018:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80101f:	00 
  801020:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801027:	e8 87 fd ff ff       	call   800db3 <syscall>
}
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801034:	8b 55 0c             	mov    0xc(%ebp),%edx
  801037:	8b 45 08             	mov    0x8(%ebp),%eax
  80103a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801041:	00 
  801042:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801049:	00 
  80104a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801051:	00 
  801052:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801056:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801061:	00 
  801062:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801069:	e8 45 fd ff ff       	call   800db3 <syscall>
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801076:	8b 55 0c             	mov    0xc(%ebp),%edx
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801083:	00 
  801084:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80108b:	00 
  80108c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801093:	00 
  801094:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801098:	89 44 24 08          	mov    %eax,0x8(%esp)
  80109c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a3:	00 
  8010a4:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010ab:	e8 03 fd ff ff       	call   800db3 <syscall>
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010b8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010c8:	00 
  8010c9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010eb:	e8 c3 fc ff ff       	call   800db3 <syscall>
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  80111f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801126:	00 
  801127:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80112e:	e8 80 fc ff ff       	call   800db3 <syscall>
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <sys_exec>:

void sys_exec(char* buf){
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801145:	00 
  801146:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114d:	00 
  80114e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801155:	00 
  801156:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80115d:	00 
  80115e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801171:	e8 3d fc ff ff       	call   800db3 <syscall>
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <sys_wait>:

void sys_wait(){
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80117e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801185:	00 
  801186:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80118d:	00 
  80118e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801195:	00 
  801196:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80119d:	00 
  80119e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a5:	00 
  8011a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011ad:	00 
  8011ae:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8011b5:	e8 f9 fb ff ff       	call   800db3 <syscall>
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011c2:	a1 08 20 80 00       	mov    0x802008,%eax
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	75 5d                	jne    801228 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8011cb:	a1 04 20 80 00       	mov    0x802004,%eax
  8011d0:	8b 40 48             	mov    0x48(%eax),%eax
  8011d3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011da:	00 
  8011db:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011e2:	ee 
  8011e3:	89 04 24             	mov    %eax,(%esp)
  8011e6:	e8 7a fd ff ff       	call   800f65 <sys_page_alloc>
  8011eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011f2:	79 1c                	jns    801210 <set_pgfault_handler+0x54>
  8011f4:	c7 44 24 08 10 18 80 	movl   $0x801810,0x8(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801203:	00 
  801204:	c7 04 24 3c 18 80 00 	movl   $0x80183c,(%esp)
  80120b:	e8 46 00 00 00       	call   801256 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801210:	a1 04 20 80 00       	mov    0x802004,%eax
  801215:	8b 40 48             	mov    0x48(%eax),%eax
  801218:	c7 44 24 04 32 12 80 	movl   $0x801232,0x4(%esp)
  80121f:	00 
  801220:	89 04 24             	mov    %eax,(%esp)
  801223:	e8 48 fe ff ff       	call   801070 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801228:	8b 45 08             	mov    0x8(%ebp),%eax
  80122b:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801232:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801233:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801238:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80123a:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  80123d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801241:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801243:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801247:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801248:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80124b:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  80124d:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  80124e:	58                   	pop    %eax
	popal 						// pop all the registers
  80124f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801250:	83 c4 04             	add    $0x4,%esp
	popfl
  801253:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801254:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801255:	c3                   	ret    

00801256 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	53                   	push   %ebx
  80125a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80125d:	8d 45 14             	lea    0x14(%ebp),%eax
  801260:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801263:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801269:	e8 6f fc ff ff       	call   800edd <sys_getenvid>
  80126e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801271:	89 54 24 10          	mov    %edx,0x10(%esp)
  801275:	8b 55 08             	mov    0x8(%ebp),%edx
  801278:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80127c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801280:	89 44 24 04          	mov    %eax,0x4(%esp)
  801284:	c7 04 24 4c 18 80 00 	movl   $0x80184c,(%esp)
  80128b:	e8 18 ef ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801290:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801293:	89 44 24 04          	mov    %eax,0x4(%esp)
  801297:	8b 45 10             	mov    0x10(%ebp),%eax
  80129a:	89 04 24             	mov    %eax,(%esp)
  80129d:	e8 a2 ee ff ff       	call   800144 <vcprintf>
	cprintf("\n");
  8012a2:	c7 04 24 6f 18 80 00 	movl   $0x80186f,(%esp)
  8012a9:	e8 fa ee ff ff       	call   8001a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012ae:	cc                   	int3   
  8012af:	eb fd                	jmp    8012ae <_panic+0x58>
  8012b1:	66 90                	xchg   %ax,%ax
  8012b3:	66 90                	xchg   %ax,%ax
  8012b5:	66 90                	xchg   %ax,%ax
  8012b7:	66 90                	xchg   %ax,%ax
  8012b9:	66 90                	xchg   %ax,%ax
  8012bb:	66 90                	xchg   %ax,%ax
  8012bd:	66 90                	xchg   %ax,%ax
  8012bf:	90                   	nop

008012c0 <__udivdi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012dc:	89 ea                	mov    %ebp,%edx
  8012de:	89 0c 24             	mov    %ecx,(%esp)
  8012e1:	75 2d                	jne    801310 <__udivdi3+0x50>
  8012e3:	39 e9                	cmp    %ebp,%ecx
  8012e5:	77 61                	ja     801348 <__udivdi3+0x88>
  8012e7:	85 c9                	test   %ecx,%ecx
  8012e9:	89 ce                	mov    %ecx,%esi
  8012eb:	75 0b                	jne    8012f8 <__udivdi3+0x38>
  8012ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f2:	31 d2                	xor    %edx,%edx
  8012f4:	f7 f1                	div    %ecx
  8012f6:	89 c6                	mov    %eax,%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	89 e8                	mov    %ebp,%eax
  8012fc:	f7 f6                	div    %esi
  8012fe:	89 c5                	mov    %eax,%ebp
  801300:	89 f8                	mov    %edi,%eax
  801302:	f7 f6                	div    %esi
  801304:	89 ea                	mov    %ebp,%edx
  801306:	83 c4 0c             	add    $0xc,%esp
  801309:	5e                   	pop    %esi
  80130a:	5f                   	pop    %edi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
  801310:	39 e8                	cmp    %ebp,%eax
  801312:	77 24                	ja     801338 <__udivdi3+0x78>
  801314:	0f bd e8             	bsr    %eax,%ebp
  801317:	83 f5 1f             	xor    $0x1f,%ebp
  80131a:	75 3c                	jne    801358 <__udivdi3+0x98>
  80131c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801320:	39 34 24             	cmp    %esi,(%esp)
  801323:	0f 86 9f 00 00 00    	jbe    8013c8 <__udivdi3+0x108>
  801329:	39 d0                	cmp    %edx,%eax
  80132b:	0f 82 97 00 00 00    	jb     8013c8 <__udivdi3+0x108>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	31 d2                	xor    %edx,%edx
  80133a:	31 c0                	xor    %eax,%eax
  80133c:	83 c4 0c             	add    $0xc,%esp
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    
  801343:	90                   	nop
  801344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801348:	89 f8                	mov    %edi,%eax
  80134a:	f7 f1                	div    %ecx
  80134c:	31 d2                	xor    %edx,%edx
  80134e:	83 c4 0c             	add    $0xc,%esp
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
  801355:	8d 76 00             	lea    0x0(%esi),%esi
  801358:	89 e9                	mov    %ebp,%ecx
  80135a:	8b 3c 24             	mov    (%esp),%edi
  80135d:	d3 e0                	shl    %cl,%eax
  80135f:	89 c6                	mov    %eax,%esi
  801361:	b8 20 00 00 00       	mov    $0x20,%eax
  801366:	29 e8                	sub    %ebp,%eax
  801368:	89 c1                	mov    %eax,%ecx
  80136a:	d3 ef                	shr    %cl,%edi
  80136c:	89 e9                	mov    %ebp,%ecx
  80136e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801372:	8b 3c 24             	mov    (%esp),%edi
  801375:	09 74 24 08          	or     %esi,0x8(%esp)
  801379:	89 d6                	mov    %edx,%esi
  80137b:	d3 e7                	shl    %cl,%edi
  80137d:	89 c1                	mov    %eax,%ecx
  80137f:	89 3c 24             	mov    %edi,(%esp)
  801382:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801386:	d3 ee                	shr    %cl,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	d3 e2                	shl    %cl,%edx
  80138c:	89 c1                	mov    %eax,%ecx
  80138e:	d3 ef                	shr    %cl,%edi
  801390:	09 d7                	or     %edx,%edi
  801392:	89 f2                	mov    %esi,%edx
  801394:	89 f8                	mov    %edi,%eax
  801396:	f7 74 24 08          	divl   0x8(%esp)
  80139a:	89 d6                	mov    %edx,%esi
  80139c:	89 c7                	mov    %eax,%edi
  80139e:	f7 24 24             	mull   (%esp)
  8013a1:	39 d6                	cmp    %edx,%esi
  8013a3:	89 14 24             	mov    %edx,(%esp)
  8013a6:	72 30                	jb     8013d8 <__udivdi3+0x118>
  8013a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	d3 e2                	shl    %cl,%edx
  8013b0:	39 c2                	cmp    %eax,%edx
  8013b2:	73 05                	jae    8013b9 <__udivdi3+0xf9>
  8013b4:	3b 34 24             	cmp    (%esp),%esi
  8013b7:	74 1f                	je     8013d8 <__udivdi3+0x118>
  8013b9:	89 f8                	mov    %edi,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	e9 7a ff ff ff       	jmp    80133c <__udivdi3+0x7c>
  8013c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cf:	e9 68 ff ff ff       	jmp    80133c <__udivdi3+0x7c>
  8013d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	83 c4 0c             	add    $0xc,%esp
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
  8013e4:	66 90                	xchg   %ax,%ax
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	66 90                	xchg   %ax,%ax
  8013ea:	66 90                	xchg   %ax,%ax
  8013ec:	66 90                	xchg   %ax,%ax
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <__umoddi3>:
  8013f0:	55                   	push   %ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	83 ec 14             	sub    $0x14,%esp
  8013f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801402:	89 c7                	mov    %eax,%edi
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 44 24 30          	mov    0x30(%esp),%eax
  80140c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801410:	89 34 24             	mov    %esi,(%esp)
  801413:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801417:	85 c0                	test   %eax,%eax
  801419:	89 c2                	mov    %eax,%edx
  80141b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80141f:	75 17                	jne    801438 <__umoddi3+0x48>
  801421:	39 fe                	cmp    %edi,%esi
  801423:	76 4b                	jbe    801470 <__umoddi3+0x80>
  801425:	89 c8                	mov    %ecx,%eax
  801427:	89 fa                	mov    %edi,%edx
  801429:	f7 f6                	div    %esi
  80142b:	89 d0                	mov    %edx,%eax
  80142d:	31 d2                	xor    %edx,%edx
  80142f:	83 c4 14             	add    $0x14,%esp
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    
  801436:	66 90                	xchg   %ax,%ax
  801438:	39 f8                	cmp    %edi,%eax
  80143a:	77 54                	ja     801490 <__umoddi3+0xa0>
  80143c:	0f bd e8             	bsr    %eax,%ebp
  80143f:	83 f5 1f             	xor    $0x1f,%ebp
  801442:	75 5c                	jne    8014a0 <__umoddi3+0xb0>
  801444:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801448:	39 3c 24             	cmp    %edi,(%esp)
  80144b:	0f 87 e7 00 00 00    	ja     801538 <__umoddi3+0x148>
  801451:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801455:	29 f1                	sub    %esi,%ecx
  801457:	19 c7                	sbb    %eax,%edi
  801459:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801461:	8b 44 24 08          	mov    0x8(%esp),%eax
  801465:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801469:	83 c4 14             	add    $0x14,%esp
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    
  801470:	85 f6                	test   %esi,%esi
  801472:	89 f5                	mov    %esi,%ebp
  801474:	75 0b                	jne    801481 <__umoddi3+0x91>
  801476:	b8 01 00 00 00       	mov    $0x1,%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	f7 f6                	div    %esi
  80147f:	89 c5                	mov    %eax,%ebp
  801481:	8b 44 24 04          	mov    0x4(%esp),%eax
  801485:	31 d2                	xor    %edx,%edx
  801487:	f7 f5                	div    %ebp
  801489:	89 c8                	mov    %ecx,%eax
  80148b:	f7 f5                	div    %ebp
  80148d:	eb 9c                	jmp    80142b <__umoddi3+0x3b>
  80148f:	90                   	nop
  801490:	89 c8                	mov    %ecx,%eax
  801492:	89 fa                	mov    %edi,%edx
  801494:	83 c4 14             	add    $0x14,%esp
  801497:	5e                   	pop    %esi
  801498:	5f                   	pop    %edi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
  80149b:	90                   	nop
  80149c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	8b 04 24             	mov    (%esp),%eax
  8014a3:	be 20 00 00 00       	mov    $0x20,%esi
  8014a8:	89 e9                	mov    %ebp,%ecx
  8014aa:	29 ee                	sub    %ebp,%esi
  8014ac:	d3 e2                	shl    %cl,%edx
  8014ae:	89 f1                	mov    %esi,%ecx
  8014b0:	d3 e8                	shr    %cl,%eax
  8014b2:	89 e9                	mov    %ebp,%ecx
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	8b 04 24             	mov    (%esp),%eax
  8014bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014bf:	89 fa                	mov    %edi,%edx
  8014c1:	d3 e0                	shl    %cl,%eax
  8014c3:	89 f1                	mov    %esi,%ecx
  8014c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014cd:	d3 ea                	shr    %cl,%edx
  8014cf:	89 e9                	mov    %ebp,%ecx
  8014d1:	d3 e7                	shl    %cl,%edi
  8014d3:	89 f1                	mov    %esi,%ecx
  8014d5:	d3 e8                	shr    %cl,%eax
  8014d7:	89 e9                	mov    %ebp,%ecx
  8014d9:	09 f8                	or     %edi,%eax
  8014db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8014df:	f7 74 24 04          	divl   0x4(%esp)
  8014e3:	d3 e7                	shl    %cl,%edi
  8014e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014e9:	89 d7                	mov    %edx,%edi
  8014eb:	f7 64 24 08          	mull   0x8(%esp)
  8014ef:	39 d7                	cmp    %edx,%edi
  8014f1:	89 c1                	mov    %eax,%ecx
  8014f3:	89 14 24             	mov    %edx,(%esp)
  8014f6:	72 2c                	jb     801524 <__umoddi3+0x134>
  8014f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014fc:	72 22                	jb     801520 <__umoddi3+0x130>
  8014fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801502:	29 c8                	sub    %ecx,%eax
  801504:	19 d7                	sbb    %edx,%edi
  801506:	89 e9                	mov    %ebp,%ecx
  801508:	89 fa                	mov    %edi,%edx
  80150a:	d3 e8                	shr    %cl,%eax
  80150c:	89 f1                	mov    %esi,%ecx
  80150e:	d3 e2                	shl    %cl,%edx
  801510:	89 e9                	mov    %ebp,%ecx
  801512:	d3 ef                	shr    %cl,%edi
  801514:	09 d0                	or     %edx,%eax
  801516:	89 fa                	mov    %edi,%edx
  801518:	83 c4 14             	add    $0x14,%esp
  80151b:	5e                   	pop    %esi
  80151c:	5f                   	pop    %edi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    
  80151f:	90                   	nop
  801520:	39 d7                	cmp    %edx,%edi
  801522:	75 da                	jne    8014fe <__umoddi3+0x10e>
  801524:	8b 14 24             	mov    (%esp),%edx
  801527:	89 c1                	mov    %eax,%ecx
  801529:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80152d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801531:	eb cb                	jmp    8014fe <__umoddi3+0x10e>
  801533:	90                   	nop
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80153c:	0f 82 0f ff ff ff    	jb     801451 <__umoddi3+0x61>
  801542:	e9 1a ff ff ff       	jmp    801461 <__umoddi3+0x71>
