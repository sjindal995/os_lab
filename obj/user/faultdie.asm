
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
  80005b:	c7 04 24 20 15 80 00 	movl   $0x801520,(%esp)
  800062:	e8 51 01 00 00       	call   8001b8 <cprintf>
	sys_env_destroy(sys_getenvid());
  800067:	e8 81 0e 00 00       	call   800eed <sys_getenvid>
  80006c:	89 04 24             	mov    %eax,(%esp)
  80006f:	e8 36 0e 00 00       	call   800eaa <sys_env_destroy>
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
  800083:	e8 00 11 00 00       	call   801188 <set_pgfault_handler>
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
  80009b:	e8 4d 0e 00 00       	call   800eed <sys_getenvid>
  8000a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a5:	c1 e0 02             	shl    $0x2,%eax
  8000a8:	89 c2                	mov    %eax,%edx
  8000aa:	c1 e2 05             	shl    $0x5,%edx
  8000ad:	29 c2                	sub    %eax,%edx
  8000af:	89 d0                	mov    %edx,%eax
  8000b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b6:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000bf:	7e 0a                	jle    8000cb <libmain+0x36>
		binaryname = argv[0];
  8000c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c4:	8b 00                	mov    (%eax),%eax
  8000c6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d5:	89 04 24             	mov    %eax,(%esp)
  8000d8:	e8 99 ff ff ff       	call   800076 <umain>

	// exit gracefully
	exit();
  8000dd:	e8 02 00 00 00       	call   8000e4 <exit>
}
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 b4 0d 00 00       	call   800eaa <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8000fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800101:	8b 00                	mov    (%eax),%eax
  800103:	8d 48 01             	lea    0x1(%eax),%ecx
  800106:	8b 55 0c             	mov    0xc(%ebp),%edx
  800109:	89 0a                	mov    %ecx,(%edx)
  80010b:	8b 55 08             	mov    0x8(%ebp),%edx
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	8b 55 0c             	mov    0xc(%ebp),%edx
  800113:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011a:	8b 00                	mov    (%eax),%eax
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 20                	jne    800143 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800123:	8b 45 0c             	mov    0xc(%ebp),%eax
  800126:	8b 00                	mov    (%eax),%eax
  800128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012b:	83 c2 08             	add    $0x8,%edx
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	89 14 24             	mov    %edx,(%esp)
  800135:	e8 ea 0c 00 00       	call   800e24 <sys_cputs>
		b->idx = 0;
  80013a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800143:	8b 45 0c             	mov    0xc(%ebp),%eax
  800146:	8b 40 04             	mov    0x4(%eax),%eax
  800149:	8d 50 01             	lea    0x1(%eax),%edx
  80014c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014f:	89 50 04             	mov    %edx,0x4(%eax)
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80015d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800164:	00 00 00 
	b.cnt = 0;
  800167:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800171:	8b 45 0c             	mov    0xc(%ebp),%eax
  800174:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800178:	8b 45 08             	mov    0x8(%ebp),%eax
  80017b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	89 44 24 04          	mov    %eax,0x4(%esp)
  800189:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800190:	e8 bd 01 00 00       	call   800352 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800195:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a5:	83 c0 08             	add    $0x8,%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 74 0c 00 00       	call   800e24 <sys_cputs>

	return b.cnt;
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	89 04 24             	mov    %eax,(%esp)
  8001d1:	e8 7e ff ff ff       	call   800154 <vcprintf>
  8001d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    

008001de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 34             	sub    $0x34,%esp
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f1:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f9:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001fc:	77 72                	ja     800270 <printnum+0x92>
  8001fe:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800201:	72 05                	jb     800208 <printnum+0x2a>
  800203:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800206:	77 68                	ja     800270 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800208:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80020b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020e:	8b 45 18             	mov    0x18(%ebp),%eax
  800211:	ba 00 00 00 00       	mov    $0x0,%edx
  800216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80021e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800221:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022b:	e8 50 10 00 00       	call   801280 <__udivdi3>
  800230:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800233:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800237:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80023b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80023e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800242:	89 44 24 08          	mov    %eax,0x8(%esp)
  800246:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 82 ff ff ff       	call   8001de <printnum>
  80025c:	eb 1c                	jmp    80027a <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	8b 45 20             	mov    0x20(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800270:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800274:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800278:	7f e4                	jg     80025e <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027a:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80027d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800285:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	89 54 24 04          	mov    %edx,0x4(%esp)
  800297:	e8 14 11 00 00       	call   8013b0 <__umoddi3>
  80029c:	05 28 16 80 00       	add    $0x801628,%eax
  8002a1:	0f b6 00             	movzbl (%eax),%eax
  8002a4:	0f be c0             	movsbl %al,%eax
  8002a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ae:	89 04 24             	mov    %eax,(%esp)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	ff d0                	call   *%eax
}
  8002b6:	83 c4 34             	add    $0x34,%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bf:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002c3:	7e 14                	jle    8002d9 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	8b 00                	mov    (%eax),%eax
  8002ca:	8d 48 08             	lea    0x8(%eax),%ecx
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 0a                	mov    %ecx,(%edx)
  8002d2:	8b 50 04             	mov    0x4(%eax),%edx
  8002d5:	8b 00                	mov    (%eax),%eax
  8002d7:	eb 30                	jmp    800309 <getuint+0x4d>
	else if (lflag)
  8002d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002dd:	74 16                	je     8002f5 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 00                	mov    (%eax),%eax
  8002e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	89 0a                	mov    %ecx,(%edx)
  8002ec:	8b 00                	mov    (%eax),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 14                	jmp    800309 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 00                	mov    (%eax),%eax
  8002fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	89 0a                	mov    %ecx,(%edx)
  800302:	8b 00                	mov    (%eax),%eax
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800312:	7e 14                	jle    800328 <getint+0x1d>
		return va_arg(*ap, long long);
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	8b 00                	mov    (%eax),%eax
  800319:	8d 48 08             	lea    0x8(%eax),%ecx
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	89 0a                	mov    %ecx,(%edx)
  800321:	8b 50 04             	mov    0x4(%eax),%edx
  800324:	8b 00                	mov    (%eax),%eax
  800326:	eb 28                	jmp    800350 <getint+0x45>
	else if (lflag)
  800328:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80032c:	74 12                	je     800340 <getint+0x35>
		return va_arg(*ap, long);
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	8b 00                	mov    (%eax),%eax
  800333:	8d 48 04             	lea    0x4(%eax),%ecx
  800336:	8b 55 08             	mov    0x8(%ebp),%edx
  800339:	89 0a                	mov    %ecx,(%edx)
  80033b:	8b 00                	mov    (%eax),%eax
  80033d:	99                   	cltd   
  80033e:	eb 10                	jmp    800350 <getint+0x45>
	else
		return va_arg(*ap, int);
  800340:	8b 45 08             	mov    0x8(%ebp),%eax
  800343:	8b 00                	mov    (%eax),%eax
  800345:	8d 48 04             	lea    0x4(%eax),%ecx
  800348:	8b 55 08             	mov    0x8(%ebp),%edx
  80034b:	89 0a                	mov    %ecx,(%edx)
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	99                   	cltd   
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
  800357:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035a:	eb 18                	jmp    800374 <vprintfmt+0x22>
			if (ch == '\0')
  80035c:	85 db                	test   %ebx,%ebx
  80035e:	75 05                	jne    800365 <vprintfmt+0x13>
				return;
  800360:	e9 cc 03 00 00       	jmp    800731 <vprintfmt+0x3df>
			putch(ch, putdat);
  800365:	8b 45 0c             	mov    0xc(%ebp),%eax
  800368:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036c:	89 1c 24             	mov    %ebx,(%esp)
  80036f:	8b 45 08             	mov    0x8(%ebp),%eax
  800372:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800374:	8b 45 10             	mov    0x10(%ebp),%eax
  800377:	8d 50 01             	lea    0x1(%eax),%edx
  80037a:	89 55 10             	mov    %edx,0x10(%ebp)
  80037d:	0f b6 00             	movzbl (%eax),%eax
  800380:	0f b6 d8             	movzbl %al,%ebx
  800383:	83 fb 25             	cmp    $0x25,%ebx
  800386:	75 d4                	jne    80035c <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800388:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80038c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800393:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80039a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003a1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ab:	8d 50 01             	lea    0x1(%eax),%edx
  8003ae:	89 55 10             	mov    %edx,0x10(%ebp)
  8003b1:	0f b6 00             	movzbl (%eax),%eax
  8003b4:	0f b6 d8             	movzbl %al,%ebx
  8003b7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003ba:	83 f8 55             	cmp    $0x55,%eax
  8003bd:	0f 87 3d 03 00 00    	ja     800700 <vprintfmt+0x3ae>
  8003c3:	8b 04 85 4c 16 80 00 	mov    0x80164c(,%eax,4),%eax
  8003ca:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003cc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003d0:	eb d6                	jmp    8003a8 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003d6:	eb d0                	jmp    8003a8 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003df:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003e2:	89 d0                	mov    %edx,%eax
  8003e4:	c1 e0 02             	shl    $0x2,%eax
  8003e7:	01 d0                	add    %edx,%eax
  8003e9:	01 c0                	add    %eax,%eax
  8003eb:	01 d8                	add    %ebx,%eax
  8003ed:	83 e8 30             	sub    $0x30,%eax
  8003f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f6:	0f b6 00             	movzbl (%eax),%eax
  8003f9:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003fc:	83 fb 2f             	cmp    $0x2f,%ebx
  8003ff:	7e 0b                	jle    80040c <vprintfmt+0xba>
  800401:	83 fb 39             	cmp    $0x39,%ebx
  800404:	7f 06                	jg     80040c <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800406:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040a:	eb d3                	jmp    8003df <vprintfmt+0x8d>
			goto process_precision;
  80040c:	eb 33                	jmp    800441 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80041c:	eb 23                	jmp    800441 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80041e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800422:	79 0c                	jns    800430 <vprintfmt+0xde>
				width = 0;
  800424:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80042b:	e9 78 ff ff ff       	jmp    8003a8 <vprintfmt+0x56>
  800430:	e9 73 ff ff ff       	jmp    8003a8 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800435:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80043c:	e9 67 ff ff ff       	jmp    8003a8 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800441:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800445:	79 12                	jns    800459 <vprintfmt+0x107>
				width = precision, precision = -1;
  800447:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800454:	e9 4f ff ff ff       	jmp    8003a8 <vprintfmt+0x56>
  800459:	e9 4a ff ff ff       	jmp    8003a8 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800462:	e9 41 ff ff ff       	jmp    8003a8 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	8b 55 0c             	mov    0xc(%ebp),%edx
  800475:	89 54 24 04          	mov    %edx,0x4(%esp)
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	8b 45 08             	mov    0x8(%ebp),%eax
  80047f:	ff d0                	call   *%eax
			break;
  800481:	e9 a5 02 00 00       	jmp    80072b <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800486:	8b 45 14             	mov    0x14(%ebp),%eax
  800489:	8d 50 04             	lea    0x4(%eax),%edx
  80048c:	89 55 14             	mov    %edx,0x14(%ebp)
  80048f:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800491:	85 db                	test   %ebx,%ebx
  800493:	79 02                	jns    800497 <vprintfmt+0x145>
				err = -err;
  800495:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800497:	83 fb 09             	cmp    $0x9,%ebx
  80049a:	7f 0b                	jg     8004a7 <vprintfmt+0x155>
  80049c:	8b 34 9d 00 16 80 00 	mov    0x801600(,%ebx,4),%esi
  8004a3:	85 f6                	test   %esi,%esi
  8004a5:	75 23                	jne    8004ca <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004a7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004ab:	c7 44 24 08 39 16 80 	movl   $0x801639,0x8(%esp)
  8004b2:	00 
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 04 24             	mov    %eax,(%esp)
  8004c0:	e8 73 02 00 00       	call   800738 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004c5:	e9 61 02 00 00       	jmp    80072b <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004ce:	c7 44 24 08 42 16 80 	movl   $0x801642,0x8(%esp)
  8004d5:	00 
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 50 02 00 00       	call   800738 <printfmt>
			break;
  8004e8:	e9 3e 02 00 00       	jmp    80072b <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	8b 30                	mov    (%eax),%esi
  8004f8:	85 f6                	test   %esi,%esi
  8004fa:	75 05                	jne    800501 <vprintfmt+0x1af>
				p = "(null)";
  8004fc:	be 45 16 80 00       	mov    $0x801645,%esi
			if (width > 0 && padc != '-')
  800501:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800505:	7e 37                	jle    80053e <vprintfmt+0x1ec>
  800507:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80050b:	74 31                	je     80053e <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800510:	89 44 24 04          	mov    %eax,0x4(%esp)
  800514:	89 34 24             	mov    %esi,(%esp)
  800517:	e8 39 03 00 00       	call   800855 <strnlen>
  80051c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80051f:	eb 17                	jmp    800538 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800521:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800525:	8b 55 0c             	mov    0xc(%ebp),%edx
  800528:	89 54 24 04          	mov    %edx,0x4(%esp)
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	8b 45 08             	mov    0x8(%ebp),%eax
  800532:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800538:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053c:	7f e3                	jg     800521 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	eb 38                	jmp    800578 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800540:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800544:	74 1f                	je     800565 <vprintfmt+0x213>
  800546:	83 fb 1f             	cmp    $0x1f,%ebx
  800549:	7e 05                	jle    800550 <vprintfmt+0x1fe>
  80054b:	83 fb 7e             	cmp    $0x7e,%ebx
  80054e:	7e 15                	jle    800565 <vprintfmt+0x213>
					putch('?', putdat);
  800550:	8b 45 0c             	mov    0xc(%ebp),%eax
  800553:	89 44 24 04          	mov    %eax,0x4(%esp)
  800557:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	ff d0                	call   *%eax
  800563:	eb 0f                	jmp    800574 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800565:	8b 45 0c             	mov    0xc(%ebp),%eax
  800568:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056c:	89 1c 24             	mov    %ebx,(%esp)
  80056f:	8b 45 08             	mov    0x8(%ebp),%eax
  800572:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800574:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800578:	89 f0                	mov    %esi,%eax
  80057a:	8d 70 01             	lea    0x1(%eax),%esi
  80057d:	0f b6 00             	movzbl (%eax),%eax
  800580:	0f be d8             	movsbl %al,%ebx
  800583:	85 db                	test   %ebx,%ebx
  800585:	74 10                	je     800597 <vprintfmt+0x245>
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	78 b3                	js     800540 <vprintfmt+0x1ee>
  80058d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800591:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800595:	79 a9                	jns    800540 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	eb 17                	jmp    8005b0 <vprintfmt+0x25e>
				putch(' ', putdat);
  800599:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005aa:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ac:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b4:	7f e3                	jg     800599 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005b6:	e9 70 01 00 00       	jmp    80072b <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	e8 3e fd ff ff       	call   80030b <getint>
  8005cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005d0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	79 26                	jns    800603 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	ff d0                	call   *%eax
				num = -(long long) num;
  8005f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f6:	f7 d8                	neg    %eax
  8005f8:	83 d2 00             	adc    $0x0,%edx
  8005fb:	f7 da                	neg    %edx
  8005fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800600:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800603:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80060a:	e9 a8 00 00 00       	jmp    8006b7 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800612:	89 44 24 04          	mov    %eax,0x4(%esp)
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 9b fc ff ff       	call   8002bc <getuint>
  800621:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800624:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800627:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80062e:	e9 84 00 00 00       	jmp    8006b7 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800633:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	e8 77 fc ff ff       	call   8002bc <getuint>
  800645:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800648:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80064b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800652:	eb 63                	jmp    8006b7 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800654:	8b 45 0c             	mov    0xc(%ebp),%eax
  800657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800662:	8b 45 08             	mov    0x8(%ebp),%eax
  800665:	ff d0                	call   *%eax
			putch('x', putdat);
  800667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800685:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800696:	eb 1f                	jmp    8006b7 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800698:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80069b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	89 04 24             	mov    %eax,(%esp)
  8006a5:	e8 12 fc ff ff       	call   8002bc <getuint>
  8006aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ad:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006b0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006be:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c5:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	89 04 24             	mov    %eax,(%esp)
  8006e8:	e8 f1 fa ff ff       	call   8001de <printnum>
			break;
  8006ed:	eb 3c                	jmp    80072b <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	89 1c 24             	mov    %ebx,(%esp)
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	ff d0                	call   *%eax
			break;
  8006fe:	eb 2b                	jmp    80072b <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
  800703:	89 44 24 04          	mov    %eax,0x4(%esp)
  800707:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800713:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800717:	eb 04                	jmp    80071d <vprintfmt+0x3cb>
  800719:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80071d:	8b 45 10             	mov    0x10(%ebp),%eax
  800720:	83 e8 01             	sub    $0x1,%eax
  800723:	0f b6 00             	movzbl (%eax),%eax
  800726:	3c 25                	cmp    $0x25,%al
  800728:	75 ef                	jne    800719 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80072a:	90                   	nop
		}
	}
  80072b:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072c:	e9 43 fc ff ff       	jmp    800374 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800731:	83 c4 40             	add    $0x40,%esp
  800734:	5b                   	pop    %ebx
  800735:	5e                   	pop    %esi
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800747:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074b:	8b 45 10             	mov    0x10(%ebp),%eax
  80074e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800752:	8b 45 0c             	mov    0xc(%ebp),%eax
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	e8 ee fb ff ff       	call   800352 <vprintfmt>
	va_end(ap);
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800769:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076c:	8b 40 08             	mov    0x8(%eax),%eax
  80076f:	8d 50 01             	lea    0x1(%eax),%edx
  800772:	8b 45 0c             	mov    0xc(%ebp),%eax
  800775:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800780:	8b 40 04             	mov    0x4(%eax),%eax
  800783:	39 c2                	cmp    %eax,%edx
  800785:	73 12                	jae    800799 <sprintputch+0x33>
		*b->buf++ = ch;
  800787:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	8d 48 01             	lea    0x1(%eax),%ecx
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	89 0a                	mov    %ecx,(%edx)
  800794:	8b 55 08             	mov    0x8(%ebp),%edx
  800797:	88 10                	mov    %dl,(%eax)
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007aa:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	01 d0                	add    %edx,%eax
  8007b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007c0:	74 06                	je     8007c8 <vsnprintf+0x2d>
  8007c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007c6:	7f 07                	jg     8007cf <vsnprintf+0x34>
		return -E_INVAL;
  8007c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cd:	eb 2a                	jmp    8007f9 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	c7 04 24 66 07 80 00 	movl   $0x800766,(%esp)
  8007eb:	e8 62 fb ff ff       	call   800352 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
  800804:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800807:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8b 45 0c             	mov    0xc(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	e8 74 ff ff ff       	call   80079b <vsnprintf>
  800827:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800835:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80083c:	eb 08                	jmp    800846 <strlen+0x17>
		n++;
  80083e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	0f b6 00             	movzbl (%eax),%eax
  80084c:	84 c0                	test   %al,%al
  80084e:	75 ee                	jne    80083e <strlen+0xf>
		n++;
	return n;
  800850:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800862:	eb 0c                	jmp    800870 <strnlen+0x1b>
		n++;
  800864:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800868:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80086c:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800870:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800874:	74 0a                	je     800880 <strnlen+0x2b>
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	0f b6 00             	movzbl (%eax),%eax
  80087c:	84 c0                	test   %al,%al
  80087e:	75 e4                	jne    800864 <strnlen+0xf>
		n++;
	return n;
  800880:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800891:	90                   	nop
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8d 50 01             	lea    0x1(%eax),%edx
  800898:	89 55 08             	mov    %edx,0x8(%ebp)
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	88 10                	mov    %dl,(%eax)
  8008a9:	0f b6 00             	movzbl (%eax),%eax
  8008ac:	84 c0                	test   %al,%al
  8008ae:	75 e2                	jne    800892 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	89 04 24             	mov    %eax,(%esp)
  8008c1:	e8 69 ff ff ff       	call   80082f <strlen>
  8008c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008c9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	01 c2                	add    %eax,%edx
  8008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	89 14 24             	mov    %edx,(%esp)
  8008db:	e8 a5 ff ff ff       	call   800885 <strcpy>
	return dst;
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008f8:	eb 23                	jmp    80091d <strncpy+0x38>
		*dst++ = *src;
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8d 50 01             	lea    0x1(%eax),%edx
  800900:	89 55 08             	mov    %edx,0x8(%ebp)
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
  800906:	0f b6 12             	movzbl (%edx),%edx
  800909:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	0f b6 00             	movzbl (%eax),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 04                	je     800919 <strncpy+0x34>
			src++;
  800915:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80091d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800920:	3b 45 10             	cmp    0x10(%ebp),%eax
  800923:	72 d5                	jb     8008fa <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800925:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800936:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80093a:	74 33                	je     80096f <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80093c:	eb 17                	jmp    800955 <strlcpy+0x2b>
			*dst++ = *src++;
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8d 50 01             	lea    0x1(%eax),%edx
  800944:	89 55 08             	mov    %edx,0x8(%ebp)
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80094d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800950:	0f b6 12             	movzbl (%edx),%edx
  800953:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800955:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800959:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80095d:	74 0a                	je     800969 <strlcpy+0x3f>
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	0f b6 00             	movzbl (%eax),%eax
  800965:	84 c0                	test   %al,%al
  800967:	75 d5                	jne    80093e <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096f:	8b 55 08             	mov    0x8(%ebp),%edx
  800972:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800975:	29 c2                	sub    %eax,%edx
  800977:	89 d0                	mov    %edx,%eax
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  80097e:	eb 08                	jmp    800988 <strcmp+0xd>
		p++, q++;
  800980:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800984:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	0f b6 00             	movzbl (%eax),%eax
  80098e:	84 c0                	test   %al,%al
  800990:	74 10                	je     8009a2 <strcmp+0x27>
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099b:	0f b6 00             	movzbl (%eax),%eax
  80099e:	38 c2                	cmp    %al,%dl
  8009a0:	74 de                	je     800980 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	0f b6 00             	movzbl (%eax),%eax
  8009a8:	0f b6 d0             	movzbl %al,%edx
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	29 c2                	sub    %eax,%edx
  8009b6:	89 d0                	mov    %edx,%eax
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009bd:	eb 0c                	jmp    8009cb <strncmp+0x11>
		n--, p++, q++;
  8009bf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009cf:	74 1a                	je     8009eb <strncmp+0x31>
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	0f b6 00             	movzbl (%eax),%eax
  8009d7:	84 c0                	test   %al,%al
  8009d9:	74 10                	je     8009eb <strncmp+0x31>
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 10             	movzbl (%eax),%edx
  8009e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e4:	0f b6 00             	movzbl (%eax),%eax
  8009e7:	38 c2                	cmp    %al,%dl
  8009e9:	74 d4                	je     8009bf <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ef:	75 07                	jne    8009f8 <strncmp+0x3e>
		return 0;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 16                	jmp    800a0e <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	0f b6 00             	movzbl (%eax),%eax
  8009fe:	0f b6 d0             	movzbl %al,%edx
  800a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a04:	0f b6 00             	movzbl (%eax),%eax
  800a07:	0f b6 c0             	movzbl %al,%eax
  800a0a:	29 c2                	sub    %eax,%edx
  800a0c:	89 d0                	mov    %edx,%eax
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 04             	sub    $0x4,%esp
  800a16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a19:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a1c:	eb 14                	jmp    800a32 <strchr+0x22>
		if (*s == c)
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 00             	movzbl (%eax),%eax
  800a24:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a27:	75 05                	jne    800a2e <strchr+0x1e>
			return (char *) s;
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	eb 13                	jmp    800a41 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	84 c0                	test   %al,%al
  800a3a:	75 e2                	jne    800a1e <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	83 ec 04             	sub    $0x4,%esp
  800a49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4c:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a4f:	eb 11                	jmp    800a62 <strfind+0x1f>
		if (*s == c)
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 00             	movzbl (%eax),%eax
  800a57:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a5a:	75 02                	jne    800a5e <strfind+0x1b>
			break;
  800a5c:	eb 0e                	jmp    800a6c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	0f b6 00             	movzbl (%eax),%eax
  800a68:	84 c0                	test   %al,%al
  800a6a:	75 e5                	jne    800a51 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a79:	75 05                	jne    800a80 <memset+0xf>
		return v;
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	eb 5c                	jmp    800adc <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	83 e0 03             	and    $0x3,%eax
  800a86:	85 c0                	test   %eax,%eax
  800a88:	75 41                	jne    800acb <memset+0x5a>
  800a8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8d:	83 e0 03             	and    $0x3,%eax
  800a90:	85 c0                	test   %eax,%eax
  800a92:	75 37                	jne    800acb <memset+0x5a>
		c &= 0xFF;
  800a94:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	c1 e0 18             	shl    $0x18,%eax
  800aa1:	89 c2                	mov    %eax,%edx
  800aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa6:	c1 e0 10             	shl    $0x10,%eax
  800aa9:	09 c2                	or     %eax,%edx
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	c1 e0 08             	shl    $0x8,%eax
  800ab1:	09 d0                	or     %edx,%eax
  800ab3:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab9:	c1 e8 02             	shr    $0x2,%eax
  800abc:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800abe:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac4:	89 d7                	mov    %edx,%edi
  800ac6:	fc                   	cld    
  800ac7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac9:	eb 0e                	jmp    800ad9 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ad4:	89 d7                	mov    %edx,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800afa:	73 6d                	jae    800b69 <memmove+0x8a>
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  800aff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b02:	01 d0                	add    %edx,%eax
  800b04:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b07:	76 60                	jbe    800b69 <memmove+0x8a>
		s += n;
  800b09:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0c:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b12:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b18:	83 e0 03             	and    $0x3,%eax
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	75 2f                	jne    800b4e <memmove+0x6f>
  800b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b22:	83 e0 03             	and    $0x3,%eax
  800b25:	85 c0                	test   %eax,%eax
  800b27:	75 25                	jne    800b4e <memmove+0x6f>
  800b29:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2c:	83 e0 03             	and    $0x3,%eax
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	75 1b                	jne    800b4e <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b36:	83 e8 04             	sub    $0x4,%eax
  800b39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b3c:	83 ea 04             	sub    $0x4,%edx
  800b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b42:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b45:	89 c7                	mov    %eax,%edi
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	fd                   	std    
  800b4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4c:	eb 18                	jmp    800b66 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b51:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b57:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5d:	89 d7                	mov    %edx,%edi
  800b5f:	89 de                	mov    %ebx,%esi
  800b61:	89 c1                	mov    %eax,%ecx
  800b63:	fd                   	std    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b66:	fc                   	cld    
  800b67:	eb 45                	jmp    800bae <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6c:	83 e0 03             	and    $0x3,%eax
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	75 2b                	jne    800b9e <memmove+0xbf>
  800b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b76:	83 e0 03             	and    $0x3,%eax
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	75 21                	jne    800b9e <memmove+0xbf>
  800b7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b80:	83 e0 03             	and    $0x3,%eax
  800b83:	85 c0                	test   %eax,%eax
  800b85:	75 17                	jne    800b9e <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b87:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8a:	c1 e8 02             	shr    $0x2,%eax
  800b8d:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b92:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	89 d6                	mov    %edx,%esi
  800b99:	fc                   	cld    
  800b9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9c:	eb 10                	jmp    800bae <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ba4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	fc                   	cld    
  800bac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb1:	83 c4 10             	add    $0x10,%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	89 04 24             	mov    %eax,(%esp)
  800bd3:	e8 07 ff ff ff       	call   800adf <memmove>
}
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    

00800bda <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800be6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be9:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bec:	eb 30                	jmp    800c1e <memcmp+0x44>
		if (*s1 != *s2)
  800bee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf1:	0f b6 10             	movzbl (%eax),%edx
  800bf4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf7:	0f b6 00             	movzbl (%eax),%eax
  800bfa:	38 c2                	cmp    %al,%dl
  800bfc:	74 18                	je     800c16 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800bfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c01:	0f b6 00             	movzbl (%eax),%eax
  800c04:	0f b6 d0             	movzbl %al,%edx
  800c07:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c0a:	0f b6 00             	movzbl (%eax),%eax
  800c0d:	0f b6 c0             	movzbl %al,%eax
  800c10:	29 c2                	sub    %eax,%edx
  800c12:	89 d0                	mov    %edx,%eax
  800c14:	eb 1a                	jmp    800c30 <memcmp+0x56>
		s1++, s2++;
  800c16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c1a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c21:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c24:	89 55 10             	mov    %edx,0x10(%ebp)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	75 c3                	jne    800bee <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	01 d0                	add    %edx,%eax
  800c40:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c43:	eb 13                	jmp    800c58 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	0f b6 10             	movzbl (%eax),%edx
  800c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4e:	38 c2                	cmp    %al,%dl
  800c50:	75 02                	jne    800c54 <memfind+0x22>
			break;
  800c52:	eb 0c                	jmp    800c60 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c5e:	72 e5                	jb     800c45 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c63:	c9                   	leave  
  800c64:	c3                   	ret    

00800c65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c6b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c72:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c79:	eb 04                	jmp    800c7f <strtol+0x1a>
		s++;
  800c7b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	0f b6 00             	movzbl (%eax),%eax
  800c85:	3c 20                	cmp    $0x20,%al
  800c87:	74 f2                	je     800c7b <strtol+0x16>
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	0f b6 00             	movzbl (%eax),%eax
  800c8f:	3c 09                	cmp    $0x9,%al
  800c91:	74 e8                	je     800c7b <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	0f b6 00             	movzbl (%eax),%eax
  800c99:	3c 2b                	cmp    $0x2b,%al
  800c9b:	75 06                	jne    800ca3 <strtol+0x3e>
		s++;
  800c9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca1:	eb 15                	jmp    800cb8 <strtol+0x53>
	else if (*s == '-')
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	0f b6 00             	movzbl (%eax),%eax
  800ca9:	3c 2d                	cmp    $0x2d,%al
  800cab:	75 0b                	jne    800cb8 <strtol+0x53>
		s++, neg = 1;
  800cad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb1:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cbc:	74 06                	je     800cc4 <strtol+0x5f>
  800cbe:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cc2:	75 24                	jne    800ce8 <strtol+0x83>
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	0f b6 00             	movzbl (%eax),%eax
  800cca:	3c 30                	cmp    $0x30,%al
  800ccc:	75 1a                	jne    800ce8 <strtol+0x83>
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	0f b6 00             	movzbl (%eax),%eax
  800cd7:	3c 78                	cmp    $0x78,%al
  800cd9:	75 0d                	jne    800ce8 <strtol+0x83>
		s += 2, base = 16;
  800cdb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cdf:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800ce6:	eb 2a                	jmp    800d12 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800ce8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cec:	75 17                	jne    800d05 <strtol+0xa0>
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 00             	movzbl (%eax),%eax
  800cf4:	3c 30                	cmp    $0x30,%al
  800cf6:	75 0d                	jne    800d05 <strtol+0xa0>
		s++, base = 8;
  800cf8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cfc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d03:	eb 0d                	jmp    800d12 <strtol+0xad>
	else if (base == 0)
  800d05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d09:	75 07                	jne    800d12 <strtol+0xad>
		base = 10;
  800d0b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	0f b6 00             	movzbl (%eax),%eax
  800d18:	3c 2f                	cmp    $0x2f,%al
  800d1a:	7e 1b                	jle    800d37 <strtol+0xd2>
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	0f b6 00             	movzbl (%eax),%eax
  800d22:	3c 39                	cmp    $0x39,%al
  800d24:	7f 11                	jg     800d37 <strtol+0xd2>
			dig = *s - '0';
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	0f b6 00             	movzbl (%eax),%eax
  800d2c:	0f be c0             	movsbl %al,%eax
  800d2f:	83 e8 30             	sub    $0x30,%eax
  800d32:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d35:	eb 48                	jmp    800d7f <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	0f b6 00             	movzbl (%eax),%eax
  800d3d:	3c 60                	cmp    $0x60,%al
  800d3f:	7e 1b                	jle    800d5c <strtol+0xf7>
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	0f b6 00             	movzbl (%eax),%eax
  800d47:	3c 7a                	cmp    $0x7a,%al
  800d49:	7f 11                	jg     800d5c <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	0f b6 00             	movzbl (%eax),%eax
  800d51:	0f be c0             	movsbl %al,%eax
  800d54:	83 e8 57             	sub    $0x57,%eax
  800d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d5a:	eb 23                	jmp    800d7f <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	0f b6 00             	movzbl (%eax),%eax
  800d62:	3c 40                	cmp    $0x40,%al
  800d64:	7e 3d                	jle    800da3 <strtol+0x13e>
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	3c 5a                	cmp    $0x5a,%al
  800d6e:	7f 33                	jg     800da3 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	0f b6 00             	movzbl (%eax),%eax
  800d76:	0f be c0             	movsbl %al,%eax
  800d79:	83 e8 37             	sub    $0x37,%eax
  800d7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d82:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d85:	7c 02                	jl     800d89 <strtol+0x124>
			break;
  800d87:	eb 1a                	jmp    800da3 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d89:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d90:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d99:	01 d0                	add    %edx,%eax
  800d9b:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800d9e:	e9 6f ff ff ff       	jmp    800d12 <strtol+0xad>

	if (endptr)
  800da3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da7:	74 08                	je     800db1 <strtol+0x14c>
		*endptr = (char *) s;
  800da9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800db1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800db5:	74 07                	je     800dbe <strtol+0x159>
  800db7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dba:	f7 d8                	neg    %eax
  800dbc:	eb 03                	jmp    800dc1 <strtol+0x15c>
  800dbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	57                   	push   %edi
  800dc7:	56                   	push   %esi
  800dc8:	53                   	push   %ebx
  800dc9:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dd5:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dd8:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ddb:	8b 75 20             	mov    0x20(%ebp),%esi
  800dde:	cd 30                	int    $0x30
  800de0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de7:	74 30                	je     800e19 <syscall+0x56>
  800de9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ded:	7e 2a                	jle    800e19 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800df2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dfd:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  800e04:	00 
  800e05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0c:	00 
  800e0d:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  800e14:	e8 09 04 00 00       	call   801222 <_panic>

	return ret;
  800e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e1c:	83 c4 3c             	add    $0x3c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e34:	00 
  800e35:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e3c:	00 
  800e3d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e44:	00 
  800e45:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e48:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e57:	00 
  800e58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5f:	e8 5f ff ff ff       	call   800dc3 <syscall>
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e6c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e73:	00 
  800e74:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e83:	00 
  800e84:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ea3:	e8 1b ff ff ff       	call   800dc3 <syscall>
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eba:	00 
  800ebb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ec2:	00 
  800ec3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eca:	00 
  800ecb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed2:	00 
  800ed3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ee6:	e8 d8 fe ff ff       	call   800dc3 <syscall>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ef3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800efa:	00 
  800efb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f02:	00 
  800f03:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f12:	00 
  800f13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f22:	00 
  800f23:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f2a:	e8 94 fe ff ff       	call   800dc3 <syscall>
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <sys_yield>:

void
sys_yield(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f37:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f46:	00 
  800f47:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f56:	00 
  800f57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f6e:	e8 50 fe ff ff       	call   800dc3 <syscall>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f93:	00 
  800f94:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f98:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa7:	00 
  800fa8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800faf:	e8 0f fe ff ff       	call   800dc3 <syscall>
}
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fbe:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fca:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcd:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fd1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fd5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800ff0:	e8 ce fd ff ff       	call   800dc3 <syscall>
}
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  801030:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801037:	e8 87 fd ff ff       	call   800dc3 <syscall>
}
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  801072:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801079:	e8 45 fd ff ff       	call   800dc3 <syscall>
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801086:	8b 55 0c             	mov    0xc(%ebp),%edx
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801093:	00 
  801094:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80109b:	00 
  80109c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010a3:	00 
  8010a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b3:	00 
  8010b4:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010bb:	e8 03 fd ff ff       	call   800dc3 <syscall>
}
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010cb:	8b 55 10             	mov    0x10(%ebp),%edx
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010d8:	00 
  8010d9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f3:	00 
  8010f4:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8010fb:	e8 c3 fc ff ff       	call   800dc3 <syscall>
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  80112f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801136:	00 
  801137:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80113e:	e8 80 fc ff ff       	call   800dc3 <syscall>
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <sys_exec>:

void sys_exec(char* buf){
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801155:	00 
  801156:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115d:	00 
  80115e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801165:	00 
  801166:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80116d:	00 
  80116e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801172:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801179:	00 
  80117a:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801181:	e8 3d fc ff ff       	call   800dc3 <syscall>
}
  801186:	c9                   	leave  
  801187:	c3                   	ret    

00801188 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80118e:	a1 08 20 80 00       	mov    0x802008,%eax
  801193:	85 c0                	test   %eax,%eax
  801195:	75 5d                	jne    8011f4 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801197:	a1 04 20 80 00       	mov    0x802004,%eax
  80119c:	8b 40 48             	mov    0x48(%eax),%eax
  80119f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011ae:	ee 
  8011af:	89 04 24             	mov    %eax,(%esp)
  8011b2:	e8 be fd ff ff       	call   800f75 <sys_page_alloc>
  8011b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011be:	79 1c                	jns    8011dc <set_pgfault_handler+0x54>
  8011c0:	c7 44 24 08 d0 17 80 	movl   $0x8017d0,0x8(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011cf:	00 
  8011d0:	c7 04 24 fc 17 80 00 	movl   $0x8017fc,(%esp)
  8011d7:	e8 46 00 00 00       	call   801222 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8011dc:	a1 04 20 80 00       	mov    0x802004,%eax
  8011e1:	8b 40 48             	mov    0x48(%eax),%eax
  8011e4:	c7 44 24 04 fe 11 80 	movl   $0x8011fe,0x4(%esp)
  8011eb:	00 
  8011ec:	89 04 24             	mov    %eax,(%esp)
  8011ef:	e8 8c fe ff ff       	call   801080 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    

008011fe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011fe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011ff:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801204:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801206:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801209:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  80120d:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80120f:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801213:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801214:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801217:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801219:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  80121a:	58                   	pop    %eax
	popal 						// pop all the registers
  80121b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  80121c:	83 c4 04             	add    $0x4,%esp
	popfl
  80121f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801220:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801221:	c3                   	ret    

00801222 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	53                   	push   %ebx
  801226:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801229:	8d 45 14             	lea    0x14(%ebp),%eax
  80122c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80122f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801235:	e8 b3 fc ff ff       	call   800eed <sys_getenvid>
  80123a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801241:	8b 55 08             	mov    0x8(%ebp),%edx
  801244:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801248:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	c7 04 24 0c 18 80 00 	movl   $0x80180c,(%esp)
  801257:	e8 5c ef ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80125c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	8b 45 10             	mov    0x10(%ebp),%eax
  801266:	89 04 24             	mov    %eax,(%esp)
  801269:	e8 e6 ee ff ff       	call   800154 <vcprintf>
	cprintf("\n");
  80126e:	c7 04 24 2f 18 80 00 	movl   $0x80182f,(%esp)
  801275:	e8 3e ef ff ff       	call   8001b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80127a:	cc                   	int3   
  80127b:	eb fd                	jmp    80127a <_panic+0x58>
  80127d:	66 90                	xchg   %ax,%ax
  80127f:	90                   	nop

00801280 <__udivdi3>:
  801280:	55                   	push   %ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	8b 44 24 28          	mov    0x28(%esp),%eax
  80128a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80128e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801292:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801296:	85 c0                	test   %eax,%eax
  801298:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80129c:	89 ea                	mov    %ebp,%edx
  80129e:	89 0c 24             	mov    %ecx,(%esp)
  8012a1:	75 2d                	jne    8012d0 <__udivdi3+0x50>
  8012a3:	39 e9                	cmp    %ebp,%ecx
  8012a5:	77 61                	ja     801308 <__udivdi3+0x88>
  8012a7:	85 c9                	test   %ecx,%ecx
  8012a9:	89 ce                	mov    %ecx,%esi
  8012ab:	75 0b                	jne    8012b8 <__udivdi3+0x38>
  8012ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b2:	31 d2                	xor    %edx,%edx
  8012b4:	f7 f1                	div    %ecx
  8012b6:	89 c6                	mov    %eax,%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	89 e8                	mov    %ebp,%eax
  8012bc:	f7 f6                	div    %esi
  8012be:	89 c5                	mov    %eax,%ebp
  8012c0:	89 f8                	mov    %edi,%eax
  8012c2:	f7 f6                	div    %esi
  8012c4:	89 ea                	mov    %ebp,%edx
  8012c6:	83 c4 0c             	add    $0xc,%esp
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    
  8012cd:	8d 76 00             	lea    0x0(%esi),%esi
  8012d0:	39 e8                	cmp    %ebp,%eax
  8012d2:	77 24                	ja     8012f8 <__udivdi3+0x78>
  8012d4:	0f bd e8             	bsr    %eax,%ebp
  8012d7:	83 f5 1f             	xor    $0x1f,%ebp
  8012da:	75 3c                	jne    801318 <__udivdi3+0x98>
  8012dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012e0:	39 34 24             	cmp    %esi,(%esp)
  8012e3:	0f 86 9f 00 00 00    	jbe    801388 <__udivdi3+0x108>
  8012e9:	39 d0                	cmp    %edx,%eax
  8012eb:	0f 82 97 00 00 00    	jb     801388 <__udivdi3+0x108>
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	31 c0                	xor    %eax,%eax
  8012fc:	83 c4 0c             	add    $0xc,%esp
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    
  801303:	90                   	nop
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	89 f8                	mov    %edi,%eax
  80130a:	f7 f1                	div    %ecx
  80130c:	31 d2                	xor    %edx,%edx
  80130e:	83 c4 0c             	add    $0xc,%esp
  801311:	5e                   	pop    %esi
  801312:	5f                   	pop    %edi
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    
  801315:	8d 76 00             	lea    0x0(%esi),%esi
  801318:	89 e9                	mov    %ebp,%ecx
  80131a:	8b 3c 24             	mov    (%esp),%edi
  80131d:	d3 e0                	shl    %cl,%eax
  80131f:	89 c6                	mov    %eax,%esi
  801321:	b8 20 00 00 00       	mov    $0x20,%eax
  801326:	29 e8                	sub    %ebp,%eax
  801328:	89 c1                	mov    %eax,%ecx
  80132a:	d3 ef                	shr    %cl,%edi
  80132c:	89 e9                	mov    %ebp,%ecx
  80132e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801332:	8b 3c 24             	mov    (%esp),%edi
  801335:	09 74 24 08          	or     %esi,0x8(%esp)
  801339:	89 d6                	mov    %edx,%esi
  80133b:	d3 e7                	shl    %cl,%edi
  80133d:	89 c1                	mov    %eax,%ecx
  80133f:	89 3c 24             	mov    %edi,(%esp)
  801342:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801346:	d3 ee                	shr    %cl,%esi
  801348:	89 e9                	mov    %ebp,%ecx
  80134a:	d3 e2                	shl    %cl,%edx
  80134c:	89 c1                	mov    %eax,%ecx
  80134e:	d3 ef                	shr    %cl,%edi
  801350:	09 d7                	or     %edx,%edi
  801352:	89 f2                	mov    %esi,%edx
  801354:	89 f8                	mov    %edi,%eax
  801356:	f7 74 24 08          	divl   0x8(%esp)
  80135a:	89 d6                	mov    %edx,%esi
  80135c:	89 c7                	mov    %eax,%edi
  80135e:	f7 24 24             	mull   (%esp)
  801361:	39 d6                	cmp    %edx,%esi
  801363:	89 14 24             	mov    %edx,(%esp)
  801366:	72 30                	jb     801398 <__udivdi3+0x118>
  801368:	8b 54 24 04          	mov    0x4(%esp),%edx
  80136c:	89 e9                	mov    %ebp,%ecx
  80136e:	d3 e2                	shl    %cl,%edx
  801370:	39 c2                	cmp    %eax,%edx
  801372:	73 05                	jae    801379 <__udivdi3+0xf9>
  801374:	3b 34 24             	cmp    (%esp),%esi
  801377:	74 1f                	je     801398 <__udivdi3+0x118>
  801379:	89 f8                	mov    %edi,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	e9 7a ff ff ff       	jmp    8012fc <__udivdi3+0x7c>
  801382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801388:	31 d2                	xor    %edx,%edx
  80138a:	b8 01 00 00 00       	mov    $0x1,%eax
  80138f:	e9 68 ff ff ff       	jmp    8012fc <__udivdi3+0x7c>
  801394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801398:	8d 47 ff             	lea    -0x1(%edi),%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	83 c4 0c             	add    $0xc,%esp
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    
  8013a4:	66 90                	xchg   %ax,%ax
  8013a6:	66 90                	xchg   %ax,%ax
  8013a8:	66 90                	xchg   %ax,%ax
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__umoddi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	83 ec 14             	sub    $0x14,%esp
  8013b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013c2:	89 c7                	mov    %eax,%edi
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013d0:	89 34 24             	mov    %esi,(%esp)
  8013d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013df:	75 17                	jne    8013f8 <__umoddi3+0x48>
  8013e1:	39 fe                	cmp    %edi,%esi
  8013e3:	76 4b                	jbe    801430 <__umoddi3+0x80>
  8013e5:	89 c8                	mov    %ecx,%eax
  8013e7:	89 fa                	mov    %edi,%edx
  8013e9:	f7 f6                	div    %esi
  8013eb:	89 d0                	mov    %edx,%eax
  8013ed:	31 d2                	xor    %edx,%edx
  8013ef:	83 c4 14             	add    $0x14,%esp
  8013f2:	5e                   	pop    %esi
  8013f3:	5f                   	pop    %edi
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    
  8013f6:	66 90                	xchg   %ax,%ax
  8013f8:	39 f8                	cmp    %edi,%eax
  8013fa:	77 54                	ja     801450 <__umoddi3+0xa0>
  8013fc:	0f bd e8             	bsr    %eax,%ebp
  8013ff:	83 f5 1f             	xor    $0x1f,%ebp
  801402:	75 5c                	jne    801460 <__umoddi3+0xb0>
  801404:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801408:	39 3c 24             	cmp    %edi,(%esp)
  80140b:	0f 87 e7 00 00 00    	ja     8014f8 <__umoddi3+0x148>
  801411:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801415:	29 f1                	sub    %esi,%ecx
  801417:	19 c7                	sbb    %eax,%edi
  801419:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80141d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801421:	8b 44 24 08          	mov    0x8(%esp),%eax
  801425:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801429:	83 c4 14             	add    $0x14,%esp
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    
  801430:	85 f6                	test   %esi,%esi
  801432:	89 f5                	mov    %esi,%ebp
  801434:	75 0b                	jne    801441 <__umoddi3+0x91>
  801436:	b8 01 00 00 00       	mov    $0x1,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	f7 f6                	div    %esi
  80143f:	89 c5                	mov    %eax,%ebp
  801441:	8b 44 24 04          	mov    0x4(%esp),%eax
  801445:	31 d2                	xor    %edx,%edx
  801447:	f7 f5                	div    %ebp
  801449:	89 c8                	mov    %ecx,%eax
  80144b:	f7 f5                	div    %ebp
  80144d:	eb 9c                	jmp    8013eb <__umoddi3+0x3b>
  80144f:	90                   	nop
  801450:	89 c8                	mov    %ecx,%eax
  801452:	89 fa                	mov    %edi,%edx
  801454:	83 c4 14             	add    $0x14,%esp
  801457:	5e                   	pop    %esi
  801458:	5f                   	pop    %edi
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    
  80145b:	90                   	nop
  80145c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801460:	8b 04 24             	mov    (%esp),%eax
  801463:	be 20 00 00 00       	mov    $0x20,%esi
  801468:	89 e9                	mov    %ebp,%ecx
  80146a:	29 ee                	sub    %ebp,%esi
  80146c:	d3 e2                	shl    %cl,%edx
  80146e:	89 f1                	mov    %esi,%ecx
  801470:	d3 e8                	shr    %cl,%eax
  801472:	89 e9                	mov    %ebp,%ecx
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	8b 04 24             	mov    (%esp),%eax
  80147b:	09 54 24 04          	or     %edx,0x4(%esp)
  80147f:	89 fa                	mov    %edi,%edx
  801481:	d3 e0                	shl    %cl,%eax
  801483:	89 f1                	mov    %esi,%ecx
  801485:	89 44 24 08          	mov    %eax,0x8(%esp)
  801489:	8b 44 24 10          	mov    0x10(%esp),%eax
  80148d:	d3 ea                	shr    %cl,%edx
  80148f:	89 e9                	mov    %ebp,%ecx
  801491:	d3 e7                	shl    %cl,%edi
  801493:	89 f1                	mov    %esi,%ecx
  801495:	d3 e8                	shr    %cl,%eax
  801497:	89 e9                	mov    %ebp,%ecx
  801499:	09 f8                	or     %edi,%eax
  80149b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80149f:	f7 74 24 04          	divl   0x4(%esp)
  8014a3:	d3 e7                	shl    %cl,%edi
  8014a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014a9:	89 d7                	mov    %edx,%edi
  8014ab:	f7 64 24 08          	mull   0x8(%esp)
  8014af:	39 d7                	cmp    %edx,%edi
  8014b1:	89 c1                	mov    %eax,%ecx
  8014b3:	89 14 24             	mov    %edx,(%esp)
  8014b6:	72 2c                	jb     8014e4 <__umoddi3+0x134>
  8014b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014bc:	72 22                	jb     8014e0 <__umoddi3+0x130>
  8014be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014c2:	29 c8                	sub    %ecx,%eax
  8014c4:	19 d7                	sbb    %edx,%edi
  8014c6:	89 e9                	mov    %ebp,%ecx
  8014c8:	89 fa                	mov    %edi,%edx
  8014ca:	d3 e8                	shr    %cl,%eax
  8014cc:	89 f1                	mov    %esi,%ecx
  8014ce:	d3 e2                	shl    %cl,%edx
  8014d0:	89 e9                	mov    %ebp,%ecx
  8014d2:	d3 ef                	shr    %cl,%edi
  8014d4:	09 d0                	or     %edx,%eax
  8014d6:	89 fa                	mov    %edi,%edx
  8014d8:	83 c4 14             	add    $0x14,%esp
  8014db:	5e                   	pop    %esi
  8014dc:	5f                   	pop    %edi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    
  8014df:	90                   	nop
  8014e0:	39 d7                	cmp    %edx,%edi
  8014e2:	75 da                	jne    8014be <__umoddi3+0x10e>
  8014e4:	8b 14 24             	mov    (%esp),%edx
  8014e7:	89 c1                	mov    %eax,%ecx
  8014e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014f1:	eb cb                	jmp    8014be <__umoddi3+0x10e>
  8014f3:	90                   	nop
  8014f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014fc:	0f 82 0f ff ff ff    	jb     801411 <__umoddi3+0x61>
  801502:	e9 1a ff ff ff       	jmp    801421 <__umoddi3+0x71>
