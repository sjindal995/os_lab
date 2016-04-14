
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 96 00 00 00       	call   8000c7 <libmain>
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
	envid_t who, id;

	id = sys_getenvid();
  800039:	e8 e1 0e 00 00       	call   800f1f <sys_getenvid>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if (thisenv == &envs[1]) {
  800041:	a1 04 20 80 00       	mov    0x802004,%eax
  800046:	3d 7c 00 c0 ee       	cmp    $0xeec0007c,%eax
  80004b:	75 37                	jne    800084 <umain+0x51>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800054:	00 
  800055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80005c:	00 
  80005d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800060:	89 04 24             	mov    %eax,(%esp)
  800063:	e8 0f 11 00 00       	call   801177 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800068:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80006b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  80007d:	e8 68 01 00 00       	call   8001ea <cprintf>
		}
  800082:	eb c9                	jmp    80004d <umain+0x1a>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800084:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800089:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
  800094:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  80009b:	e8 4a 01 00 00       	call   8001ea <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  8000a0:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000ac:	00 
  8000ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b4:	00 
  8000b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bc:	00 
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 50 11 00 00       	call   801215 <ipc_send>
  8000c5:	eb d9                	jmp    8000a0 <umain+0x6d>

008000c7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000cd:	e8 4d 0e 00 00       	call   800f1f <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	c1 e0 02             	shl    $0x2,%eax
  8000da:	89 c2                	mov    %eax,%edx
  8000dc:	c1 e2 05             	shl    $0x5,%edx
  8000df:	29 c2                	sub    %eax,%edx
  8000e1:	89 d0                	mov    %edx,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000f1:	7e 0a                	jle    8000fd <libmain+0x36>
		binaryname = argv[0];
  8000f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f6:	8b 00                	mov    (%eax),%eax
  8000f8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800100:	89 44 24 04          	mov    %eax,0x4(%esp)
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 24 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80010f:	e8 02 00 00 00       	call   800116 <exit>
}
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800123:	e8 b4 0d 00 00       	call   800edc <sys_env_destroy>
}
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	8b 00                	mov    (%eax),%eax
  800135:	8d 48 01             	lea    0x1(%eax),%ecx
  800138:	8b 55 0c             	mov    0xc(%ebp),%edx
  80013b:	89 0a                	mov    %ecx,(%edx)
  80013d:	8b 55 08             	mov    0x8(%ebp),%edx
  800140:	89 d1                	mov    %edx,%ecx
  800142:	8b 55 0c             	mov    0xc(%ebp),%edx
  800145:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	8b 00                	mov    (%eax),%eax
  80014e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800153:	75 20                	jne    800175 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800155:	8b 45 0c             	mov    0xc(%ebp),%eax
  800158:	8b 00                	mov    (%eax),%eax
  80015a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015d:	83 c2 08             	add    $0x8,%edx
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	89 14 24             	mov    %edx,(%esp)
  800167:	e8 ea 0c 00 00       	call   800e56 <sys_cputs>
		b->idx = 0;
  80016c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800175:	8b 45 0c             	mov    0xc(%ebp),%eax
  800178:	8b 40 04             	mov    0x4(%eax),%eax
  80017b:	8d 50 01             	lea    0x1(%eax),%edx
  80017e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800181:	89 50 04             	mov    %edx,0x4(%eax)
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80018f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800196:	00 00 00 
	b.cnt = 0;
  800199:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bb:	c7 04 24 2a 01 80 00 	movl   $0x80012a,(%esp)
  8001c2:	e8 bd 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d7:	83 c0 08             	add    $0x8,%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 74 0c 00 00       	call   800e56 <sys_cputs>

	return b.cnt;
  8001e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	e8 7e ff ff ff       	call   800186 <vcprintf>
  800208:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80020b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	53                   	push   %ebx
  800214:	83 ec 34             	sub    $0x34,%esp
  800217:	8b 45 10             	mov    0x10(%ebp),%eax
  80021a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80021d:	8b 45 14             	mov    0x14(%ebp),%eax
  800220:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	8b 45 18             	mov    0x18(%ebp),%eax
  800226:	ba 00 00 00 00       	mov    $0x0,%edx
  80022b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80022e:	77 72                	ja     8002a2 <printnum+0x92>
  800230:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800233:	72 05                	jb     80023a <printnum+0x2a>
  800235:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800238:	77 68                	ja     8002a2 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80023d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800240:	8b 45 18             	mov    0x18(%ebp),%eax
  800243:	ba 00 00 00 00       	mov    $0x0,%edx
  800248:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800253:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025d:	e8 fe 10 00 00       	call   801360 <__udivdi3>
  800262:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800265:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800269:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80026d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800270:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800274:	89 44 24 08          	mov    %eax,0x8(%esp)
  800278:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	e8 82 ff ff ff       	call   800210 <printnum>
  80028e:	eb 1c                	jmp    8002ac <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 44 24 04          	mov    %eax,0x4(%esp)
  800297:	8b 45 20             	mov    0x20(%ebp),%eax
  80029a:	89 04 24             	mov    %eax,(%esp)
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002a6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002aa:	7f e4                	jg     800290 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c9:	e8 c2 11 00 00       	call   801490 <__umoddi3>
  8002ce:	05 08 17 80 00       	add    $0x801708,%eax
  8002d3:	0f b6 00             	movzbl (%eax),%eax
  8002d6:	0f be c0             	movsbl %al,%eax
  8002d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	ff d0                	call   *%eax
}
  8002e8:	83 c4 34             	add    $0x34,%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002f5:	7e 14                	jle    80030b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	8b 00                	mov    (%eax),%eax
  8002fc:	8d 48 08             	lea    0x8(%eax),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	89 0a                	mov    %ecx,(%edx)
  800304:	8b 50 04             	mov    0x4(%eax),%edx
  800307:	8b 00                	mov    (%eax),%eax
  800309:	eb 30                	jmp    80033b <getuint+0x4d>
	else if (lflag)
  80030b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80030f:	74 16                	je     800327 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	8b 00                	mov    (%eax),%eax
  800316:	8d 48 04             	lea    0x4(%eax),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 0a                	mov    %ecx,(%edx)
  80031e:	8b 00                	mov    (%eax),%eax
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
  800325:	eb 14                	jmp    80033b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	8b 00                	mov    (%eax),%eax
  80032c:	8d 48 04             	lea    0x4(%eax),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 0a                	mov    %ecx,(%edx)
  800334:	8b 00                	mov    (%eax),%eax
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800340:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800344:	7e 14                	jle    80035a <getint+0x1d>
		return va_arg(*ap, long long);
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	8b 00                	mov    (%eax),%eax
  80034b:	8d 48 08             	lea    0x8(%eax),%ecx
  80034e:	8b 55 08             	mov    0x8(%ebp),%edx
  800351:	89 0a                	mov    %ecx,(%edx)
  800353:	8b 50 04             	mov    0x4(%eax),%edx
  800356:	8b 00                	mov    (%eax),%eax
  800358:	eb 28                	jmp    800382 <getint+0x45>
	else if (lflag)
  80035a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80035e:	74 12                	je     800372 <getint+0x35>
		return va_arg(*ap, long);
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	8b 00                	mov    (%eax),%eax
  800365:	8d 48 04             	lea    0x4(%eax),%ecx
  800368:	8b 55 08             	mov    0x8(%ebp),%edx
  80036b:	89 0a                	mov    %ecx,(%edx)
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	99                   	cltd   
  800370:	eb 10                	jmp    800382 <getint+0x45>
	else
		return va_arg(*ap, int);
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	8b 00                	mov    (%eax),%eax
  800377:	8d 48 04             	lea    0x4(%eax),%ecx
  80037a:	8b 55 08             	mov    0x8(%ebp),%edx
  80037d:	89 0a                	mov    %ecx,(%edx)
  80037f:	8b 00                	mov    (%eax),%eax
  800381:	99                   	cltd   
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038c:	eb 18                	jmp    8003a6 <vprintfmt+0x22>
			if (ch == '\0')
  80038e:	85 db                	test   %ebx,%ebx
  800390:	75 05                	jne    800397 <vprintfmt+0x13>
				return;
  800392:	e9 cc 03 00 00       	jmp    800763 <vprintfmt+0x3df>
			putch(ch, putdat);
  800397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039e:	89 1c 24             	mov    %ebx,(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a9:	8d 50 01             	lea    0x1(%eax),%edx
  8003ac:	89 55 10             	mov    %edx,0x10(%ebp)
  8003af:	0f b6 00             	movzbl (%eax),%eax
  8003b2:	0f b6 d8             	movzbl %al,%ebx
  8003b5:	83 fb 25             	cmp    $0x25,%ebx
  8003b8:	75 d4                	jne    80038e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003ba:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003be:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003d3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dd:	8d 50 01             	lea    0x1(%eax),%edx
  8003e0:	89 55 10             	mov    %edx,0x10(%ebp)
  8003e3:	0f b6 00             	movzbl (%eax),%eax
  8003e6:	0f b6 d8             	movzbl %al,%ebx
  8003e9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003ec:	83 f8 55             	cmp    $0x55,%eax
  8003ef:	0f 87 3d 03 00 00    	ja     800732 <vprintfmt+0x3ae>
  8003f5:	8b 04 85 2c 17 80 00 	mov    0x80172c(,%eax,4),%eax
  8003fc:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fe:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800402:	eb d6                	jmp    8003da <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800408:	eb d0                	jmp    8003da <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800411:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800414:	89 d0                	mov    %edx,%eax
  800416:	c1 e0 02             	shl    $0x2,%eax
  800419:	01 d0                	add    %edx,%eax
  80041b:	01 c0                	add    %eax,%eax
  80041d:	01 d8                	add    %ebx,%eax
  80041f:	83 e8 30             	sub    $0x30,%eax
  800422:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800425:	8b 45 10             	mov    0x10(%ebp),%eax
  800428:	0f b6 00             	movzbl (%eax),%eax
  80042b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80042e:	83 fb 2f             	cmp    $0x2f,%ebx
  800431:	7e 0b                	jle    80043e <vprintfmt+0xba>
  800433:	83 fb 39             	cmp    $0x39,%ebx
  800436:	7f 06                	jg     80043e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800438:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043c:	eb d3                	jmp    800411 <vprintfmt+0x8d>
			goto process_precision;
  80043e:	eb 33                	jmp    800473 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80044e:	eb 23                	jmp    800473 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800450:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800454:	79 0c                	jns    800462 <vprintfmt+0xde>
				width = 0;
  800456:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80045d:	e9 78 ff ff ff       	jmp    8003da <vprintfmt+0x56>
  800462:	e9 73 ff ff ff       	jmp    8003da <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800467:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80046e:	e9 67 ff ff ff       	jmp    8003da <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800473:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800477:	79 12                	jns    80048b <vprintfmt+0x107>
				width = precision, precision = -1;
  800479:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800486:	e9 4f ff ff ff       	jmp    8003da <vprintfmt+0x56>
  80048b:	e9 4a ff ff ff       	jmp    8003da <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800490:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800494:	e9 41 ff ff ff       	jmp    8003da <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	ff d0                	call   *%eax
			break;
  8004b3:	e9 a5 02 00 00       	jmp    80075d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004c3:	85 db                	test   %ebx,%ebx
  8004c5:	79 02                	jns    8004c9 <vprintfmt+0x145>
				err = -err;
  8004c7:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 fb 09             	cmp    $0x9,%ebx
  8004cc:	7f 0b                	jg     8004d9 <vprintfmt+0x155>
  8004ce:	8b 34 9d e0 16 80 00 	mov    0x8016e0(,%ebx,4),%esi
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	75 23                	jne    8004fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004dd:	c7 44 24 08 19 17 80 	movl   $0x801719,0x8(%esp)
  8004e4:	00 
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	e8 73 02 00 00       	call   80076a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004f7:	e9 61 02 00 00       	jmp    80075d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004fc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800500:	c7 44 24 08 22 17 80 	movl   $0x801722,0x8(%esp)
  800507:	00 
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	e8 50 02 00 00       	call   80076a <printfmt>
			break;
  80051a:	e9 3e 02 00 00       	jmp    80075d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 30                	mov    (%eax),%esi
  80052a:	85 f6                	test   %esi,%esi
  80052c:	75 05                	jne    800533 <vprintfmt+0x1af>
				p = "(null)";
  80052e:	be 25 17 80 00       	mov    $0x801725,%esi
			if (width > 0 && padc != '-')
  800533:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800537:	7e 37                	jle    800570 <vprintfmt+0x1ec>
  800539:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80053d:	74 31                	je     800570 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800542:	89 44 24 04          	mov    %eax,0x4(%esp)
  800546:	89 34 24             	mov    %esi,(%esp)
  800549:	e8 39 03 00 00       	call   800887 <strnlen>
  80054e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800551:	eb 17                	jmp    80056a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800553:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800557:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	8b 45 08             	mov    0x8(%ebp),%eax
  800564:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800566:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80056a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80056e:	7f e3                	jg     800553 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	eb 38                	jmp    8005aa <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800572:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800576:	74 1f                	je     800597 <vprintfmt+0x213>
  800578:	83 fb 1f             	cmp    $0x1f,%ebx
  80057b:	7e 05                	jle    800582 <vprintfmt+0x1fe>
  80057d:	83 fb 7e             	cmp    $0x7e,%ebx
  800580:	7e 15                	jle    800597 <vprintfmt+0x213>
					putch('?', putdat);
  800582:	8b 45 0c             	mov    0xc(%ebp),%eax
  800585:	89 44 24 04          	mov    %eax,0x4(%esp)
  800589:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	ff d0                	call   *%eax
  800595:	eb 0f                	jmp    8005a6 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059e:	89 1c 24             	mov    %ebx,(%esp)
  8005a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a4:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005aa:	89 f0                	mov    %esi,%eax
  8005ac:	8d 70 01             	lea    0x1(%eax),%esi
  8005af:	0f b6 00             	movzbl (%eax),%eax
  8005b2:	0f be d8             	movsbl %al,%ebx
  8005b5:	85 db                	test   %ebx,%ebx
  8005b7:	74 10                	je     8005c9 <vprintfmt+0x245>
  8005b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bd:	78 b3                	js     800572 <vprintfmt+0x1ee>
  8005bf:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c7:	79 a9                	jns    800572 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c9:	eb 17                	jmp    8005e2 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e6:	7f e3                	jg     8005cb <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005e8:	e9 70 01 00 00       	jmp    80075d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	e8 3e fd ff ff       	call   80033d <getint>
  8005ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800602:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800608:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	79 26                	jns    800635 <vprintfmt+0x2b1>
				putch('-', putdat);
  80060f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800612:	89 44 24 04          	mov    %eax,0x4(%esp)
  800616:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	ff d0                	call   *%eax
				num = -(long long) num;
  800622:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800625:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800628:	f7 d8                	neg    %eax
  80062a:	83 d2 00             	adc    $0x0,%edx
  80062d:	f7 da                	neg    %edx
  80062f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800632:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800635:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80063c:	e9 a8 00 00 00       	jmp    8006e9 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800641:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800644:	89 44 24 04          	mov    %eax,0x4(%esp)
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	e8 9b fc ff ff       	call   8002ee <getuint>
  800653:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800656:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800659:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800660:	e9 84 00 00 00       	jmp    8006e9 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800665:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	e8 77 fc ff ff       	call   8002ee <getuint>
  800677:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80067a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80067d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800684:	eb 63                	jmp    8006e9 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	ff d0                	call   *%eax
			putch('x', putdat);
  800699:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006aa:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006c8:	eb 1f                	jmp    8006e9 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	e8 12 fc ff ff       	call   8002ee <getuint>
  8006dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006df:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006e2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f0:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800702:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800705:	89 44 24 08          	mov    %eax,0x8(%esp)
  800709:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	e8 f1 fa ff ff       	call   800210 <printnum>
			break;
  80071f:	eb 3c                	jmp    80075d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	89 1c 24             	mov    %ebx,(%esp)
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	ff d0                	call   *%eax
			break;
  800730:	eb 2b                	jmp    80075d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800732:	8b 45 0c             	mov    0xc(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800745:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800749:	eb 04                	jmp    80074f <vprintfmt+0x3cb>
  80074b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80074f:	8b 45 10             	mov    0x10(%ebp),%eax
  800752:	83 e8 01             	sub    $0x1,%eax
  800755:	0f b6 00             	movzbl (%eax),%eax
  800758:	3c 25                	cmp    $0x25,%al
  80075a:	75 ef                	jne    80074b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80075c:	90                   	nop
		}
	}
  80075d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075e:	e9 43 fc ff ff       	jmp    8003a6 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800763:	83 c4 40             	add    $0x40,%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
  800773:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800779:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077d:	8b 45 10             	mov    0x10(%ebp),%eax
  800780:	89 44 24 08          	mov    %eax,0x8(%esp)
  800784:	8b 45 0c             	mov    0xc(%ebp),%eax
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	e8 ee fb ff ff       	call   800384 <vprintfmt>
	va_end(ap);
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079e:	8b 40 08             	mov    0x8(%eax),%eax
  8007a1:	8d 50 01             	lea    0x1(%eax),%edx
  8007a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a7:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b2:	8b 40 04             	mov    0x4(%eax),%eax
  8007b5:	39 c2                	cmp    %eax,%edx
  8007b7:	73 12                	jae    8007cb <sprintputch+0x33>
		*b->buf++ = ch;
  8007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	8d 48 01             	lea    0x1(%eax),%ecx
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c4:	89 0a                	mov    %ecx,(%edx)
  8007c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c9:	88 10                	mov    %dl,(%eax)
}
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	01 d0                	add    %edx,%eax
  8007e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007f2:	74 06                	je     8007fa <vsnprintf+0x2d>
  8007f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007f8:	7f 07                	jg     800801 <vsnprintf+0x34>
		return -E_INVAL;
  8007fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ff:	eb 2a                	jmp    80082b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800801:	8b 45 14             	mov    0x14(%ebp),%eax
  800804:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800808:	8b 45 10             	mov    0x10(%ebp),%eax
  80080b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800812:	89 44 24 04          	mov    %eax,0x4(%esp)
  800816:	c7 04 24 98 07 80 00 	movl   $0x800798,(%esp)
  80081d:	e8 62 fb ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800825:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800828:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800840:	8b 45 10             	mov    0x10(%ebp),%eax
  800843:	89 44 24 08          	mov    %eax,0x8(%esp)
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	89 04 24             	mov    %eax,(%esp)
  800854:	e8 74 ff ff ff       	call   8007cd <vsnprintf>
  800859:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80085c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800867:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80086e:	eb 08                	jmp    800878 <strlen+0x17>
		n++;
  800870:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800874:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	75 ee                	jne    800870 <strlen+0xf>
		n++;
	return n;
  800882:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800894:	eb 0c                	jmp    8008a2 <strnlen+0x1b>
		n++;
  800896:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80089e:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008a6:	74 0a                	je     8008b2 <strnlen+0x2b>
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	84 c0                	test   %al,%al
  8008b0:	75 e4                	jne    800896 <strnlen+0xf>
		n++;
	return n;
  8008b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008c3:	90                   	nop
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8d 50 01             	lea    0x1(%eax),%edx
  8008ca:	89 55 08             	mov    %edx,0x8(%ebp)
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008d3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008d6:	0f b6 12             	movzbl (%edx),%edx
  8008d9:	88 10                	mov    %dl,(%eax)
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	75 e2                	jne    8008c4 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	e8 69 ff ff ff       	call   800861 <strlen>
  8008f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008fb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	01 c2                	add    %eax,%edx
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090a:	89 14 24             	mov    %edx,(%esp)
  80090d:	e8 a5 ff ff ff       	call   8008b7 <strcpy>
	return dst;
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800923:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80092a:	eb 23                	jmp    80094f <strncpy+0x38>
		*dst++ = *src;
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8d 50 01             	lea    0x1(%eax),%edx
  800932:	89 55 08             	mov    %edx,0x8(%ebp)
  800935:	8b 55 0c             	mov    0xc(%ebp),%edx
  800938:	0f b6 12             	movzbl (%edx),%edx
  80093b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	0f b6 00             	movzbl (%eax),%eax
  800943:	84 c0                	test   %al,%al
  800945:	74 04                	je     80094b <strncpy+0x34>
			src++;
  800947:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80094f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800952:	3b 45 10             	cmp    0x10(%ebp),%eax
  800955:	72 d5                	jb     80092c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800957:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800968:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80096c:	74 33                	je     8009a1 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80096e:	eb 17                	jmp    800987 <strlcpy+0x2b>
			*dst++ = *src++;
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8d 50 01             	lea    0x1(%eax),%edx
  800976:	89 55 08             	mov    %edx,0x8(%ebp)
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80097f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800982:	0f b6 12             	movzbl (%edx),%edx
  800985:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800987:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80098b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80098f:	74 0a                	je     80099b <strlcpy+0x3f>
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	0f b6 00             	movzbl (%eax),%eax
  800997:	84 c0                	test   %al,%al
  800999:	75 d5                	jne    800970 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009a7:	29 c2                	sub    %eax,%edx
  8009a9:	89 d0                	mov    %edx,%eax
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009b0:	eb 08                	jmp    8009ba <strcmp+0xd>
		p++, q++;
  8009b2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009b6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 00             	movzbl (%eax),%eax
  8009c0:	84 c0                	test   %al,%al
  8009c2:	74 10                	je     8009d4 <strcmp+0x27>
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cd:	0f b6 00             	movzbl (%eax),%eax
  8009d0:	38 c2                	cmp    %al,%dl
  8009d2:	74 de                	je     8009b2 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 d0             	movzbl %al,%edx
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	0f b6 00             	movzbl (%eax),%eax
  8009e3:	0f b6 c0             	movzbl %al,%eax
  8009e6:	29 c2                	sub    %eax,%edx
  8009e8:	89 d0                	mov    %edx,%eax
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009ef:	eb 0c                	jmp    8009fd <strncmp+0x11>
		n--, p++, q++;
  8009f1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009f9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a01:	74 1a                	je     800a1d <strncmp+0x31>
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	0f b6 00             	movzbl (%eax),%eax
  800a09:	84 c0                	test   %al,%al
  800a0b:	74 10                	je     800a1d <strncmp+0x31>
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	0f b6 00             	movzbl (%eax),%eax
  800a19:	38 c2                	cmp    %al,%dl
  800a1b:	74 d4                	je     8009f1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a21:	75 07                	jne    800a2a <strncmp+0x3e>
		return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	eb 16                	jmp    800a40 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	0f b6 00             	movzbl (%eax),%eax
  800a30:	0f b6 d0             	movzbl %al,%edx
  800a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a36:	0f b6 00             	movzbl (%eax),%eax
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	29 c2                	sub    %eax,%edx
  800a3e:	89 d0                	mov    %edx,%eax
}
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	83 ec 04             	sub    $0x4,%esp
  800a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a4e:	eb 14                	jmp    800a64 <strchr+0x22>
		if (*s == c)
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	0f b6 00             	movzbl (%eax),%eax
  800a56:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a59:	75 05                	jne    800a60 <strchr+0x1e>
			return (char *) s;
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	eb 13                	jmp    800a73 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	0f b6 00             	movzbl (%eax),%eax
  800a6a:	84 c0                	test   %al,%al
  800a6c:	75 e2                	jne    800a50 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a73:	c9                   	leave  
  800a74:	c3                   	ret    

00800a75 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	83 ec 04             	sub    $0x4,%esp
  800a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a81:	eb 11                	jmp    800a94 <strfind+0x1f>
		if (*s == c)
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	0f b6 00             	movzbl (%eax),%eax
  800a89:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a8c:	75 02                	jne    800a90 <strfind+0x1b>
			break;
  800a8e:	eb 0e                	jmp    800a9e <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a90:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	0f b6 00             	movzbl (%eax),%eax
  800a9a:	84 c0                	test   %al,%al
  800a9c:	75 e5                	jne    800a83 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
	char *p;

	if (n == 0)
  800aa7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aab:	75 05                	jne    800ab2 <memset+0xf>
		return v;
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	eb 5c                	jmp    800b0e <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	83 e0 03             	and    $0x3,%eax
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	75 41                	jne    800afd <memset+0x5a>
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	83 e0 03             	and    $0x3,%eax
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	75 37                	jne    800afd <memset+0x5a>
		c &= 0xFF;
  800ac6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad0:	c1 e0 18             	shl    $0x18,%eax
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	c1 e0 10             	shl    $0x10,%eax
  800adb:	09 c2                	or     %eax,%edx
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	c1 e0 08             	shl    $0x8,%eax
  800ae3:	09 d0                	or     %edx,%eax
  800ae5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aeb:	c1 e8 02             	shr    $0x2,%eax
  800aee:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	fc                   	cld    
  800af9:	f3 ab                	rep stos %eax,%es:(%edi)
  800afb:	eb 0e                	jmp    800b0b <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b03:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	fc                   	cld    
  800b09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b2c:	73 6d                	jae    800b9b <memmove+0x8a>
  800b2e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b31:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b34:	01 d0                	add    %edx,%eax
  800b36:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b39:	76 60                	jbe    800b9b <memmove+0x8a>
		s += n;
  800b3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4a:	83 e0 03             	and    $0x3,%eax
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 2f                	jne    800b80 <memmove+0x6f>
  800b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b54:	83 e0 03             	and    $0x3,%eax
  800b57:	85 c0                	test   %eax,%eax
  800b59:	75 25                	jne    800b80 <memmove+0x6f>
  800b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5e:	83 e0 03             	and    $0x3,%eax
  800b61:	85 c0                	test   %eax,%eax
  800b63:	75 1b                	jne    800b80 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b65:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b68:	83 e8 04             	sub    $0x4,%eax
  800b6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b6e:	83 ea 04             	sub    $0x4,%edx
  800b71:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b74:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b77:	89 c7                	mov    %eax,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	fd                   	std    
  800b7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7e:	eb 18                	jmp    800b98 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b83:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b89:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 de                	mov    %ebx,%esi
  800b93:	89 c1                	mov    %eax,%ecx
  800b95:	fd                   	std    
  800b96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b98:	fc                   	cld    
  800b99:	eb 45                	jmp    800be0 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b9e:	83 e0 03             	and    $0x3,%eax
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	75 2b                	jne    800bd0 <memmove+0xbf>
  800ba5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba8:	83 e0 03             	and    $0x3,%eax
  800bab:	85 c0                	test   %eax,%eax
  800bad:	75 21                	jne    800bd0 <memmove+0xbf>
  800baf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb2:	83 e0 03             	and    $0x3,%eax
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	75 17                	jne    800bd0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbc:	c1 e8 02             	shr    $0x2,%eax
  800bbf:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bc7:	89 c7                	mov    %eax,%edi
  800bc9:	89 d6                	mov    %edx,%esi
  800bcb:	fc                   	cld    
  800bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bce:	eb 10                	jmp    800be0 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	89 d6                	mov    %edx,%esi
  800bdd:	fc                   	cld    
  800bde:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	89 04 24             	mov    %eax,(%esp)
  800c05:	e8 07 ff ff ff       	call   800b11 <memmove>
}
  800c0a:	c9                   	leave  
  800c0b:	c3                   	ret    

00800c0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c1e:	eb 30                	jmp    800c50 <memcmp+0x44>
		if (*s1 != *s2)
  800c20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c23:	0f b6 10             	movzbl (%eax),%edx
  800c26:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c29:	0f b6 00             	movzbl (%eax),%eax
  800c2c:	38 c2                	cmp    %al,%dl
  800c2e:	74 18                	je     800c48 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c33:	0f b6 00             	movzbl (%eax),%eax
  800c36:	0f b6 d0             	movzbl %al,%edx
  800c39:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c3c:	0f b6 00             	movzbl (%eax),%eax
  800c3f:	0f b6 c0             	movzbl %al,%eax
  800c42:	29 c2                	sub    %eax,%edx
  800c44:	89 d0                	mov    %edx,%eax
  800c46:	eb 1a                	jmp    800c62 <memcmp+0x56>
		s1++, s2++;
  800c48:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c4c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c50:	8b 45 10             	mov    0x10(%ebp),%eax
  800c53:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c56:	89 55 10             	mov    %edx,0x10(%ebp)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	75 c3                	jne    800c20 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	01 d0                	add    %edx,%eax
  800c72:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c75:	eb 13                	jmp    800c8a <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	0f b6 10             	movzbl (%eax),%edx
  800c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c80:	38 c2                	cmp    %al,%dl
  800c82:	75 02                	jne    800c86 <memfind+0x22>
			break;
  800c84:	eb 0c                	jmp    800c92 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c90:	72 e5                	jb     800c77 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ca4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cab:	eb 04                	jmp    800cb1 <strtol+0x1a>
		s++;
  800cad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	0f b6 00             	movzbl (%eax),%eax
  800cb7:	3c 20                	cmp    $0x20,%al
  800cb9:	74 f2                	je     800cad <strtol+0x16>
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	0f b6 00             	movzbl (%eax),%eax
  800cc1:	3c 09                	cmp    $0x9,%al
  800cc3:	74 e8                	je     800cad <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	0f b6 00             	movzbl (%eax),%eax
  800ccb:	3c 2b                	cmp    $0x2b,%al
  800ccd:	75 06                	jne    800cd5 <strtol+0x3e>
		s++;
  800ccf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cd3:	eb 15                	jmp    800cea <strtol+0x53>
	else if (*s == '-')
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	0f b6 00             	movzbl (%eax),%eax
  800cdb:	3c 2d                	cmp    $0x2d,%al
  800cdd:	75 0b                	jne    800cea <strtol+0x53>
		s++, neg = 1;
  800cdf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ce3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cee:	74 06                	je     800cf6 <strtol+0x5f>
  800cf0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cf4:	75 24                	jne    800d1a <strtol+0x83>
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	0f b6 00             	movzbl (%eax),%eax
  800cfc:	3c 30                	cmp    $0x30,%al
  800cfe:	75 1a                	jne    800d1a <strtol+0x83>
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	83 c0 01             	add    $0x1,%eax
  800d06:	0f b6 00             	movzbl (%eax),%eax
  800d09:	3c 78                	cmp    $0x78,%al
  800d0b:	75 0d                	jne    800d1a <strtol+0x83>
		s += 2, base = 16;
  800d0d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d11:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d18:	eb 2a                	jmp    800d44 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1e:	75 17                	jne    800d37 <strtol+0xa0>
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	0f b6 00             	movzbl (%eax),%eax
  800d26:	3c 30                	cmp    $0x30,%al
  800d28:	75 0d                	jne    800d37 <strtol+0xa0>
		s++, base = 8;
  800d2a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d2e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d35:	eb 0d                	jmp    800d44 <strtol+0xad>
	else if (base == 0)
  800d37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d3b:	75 07                	jne    800d44 <strtol+0xad>
		base = 10;
  800d3d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	0f b6 00             	movzbl (%eax),%eax
  800d4a:	3c 2f                	cmp    $0x2f,%al
  800d4c:	7e 1b                	jle    800d69 <strtol+0xd2>
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	0f b6 00             	movzbl (%eax),%eax
  800d54:	3c 39                	cmp    $0x39,%al
  800d56:	7f 11                	jg     800d69 <strtol+0xd2>
			dig = *s - '0';
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	0f be c0             	movsbl %al,%eax
  800d61:	83 e8 30             	sub    $0x30,%eax
  800d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d67:	eb 48                	jmp    800db1 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	0f b6 00             	movzbl (%eax),%eax
  800d6f:	3c 60                	cmp    $0x60,%al
  800d71:	7e 1b                	jle    800d8e <strtol+0xf7>
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	0f b6 00             	movzbl (%eax),%eax
  800d79:	3c 7a                	cmp    $0x7a,%al
  800d7b:	7f 11                	jg     800d8e <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	0f b6 00             	movzbl (%eax),%eax
  800d83:	0f be c0             	movsbl %al,%eax
  800d86:	83 e8 57             	sub    $0x57,%eax
  800d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d8c:	eb 23                	jmp    800db1 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	3c 40                	cmp    $0x40,%al
  800d96:	7e 3d                	jle    800dd5 <strtol+0x13e>
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	3c 5a                	cmp    $0x5a,%al
  800da0:	7f 33                	jg     800dd5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	0f b6 00             	movzbl (%eax),%eax
  800da8:	0f be c0             	movsbl %al,%eax
  800dab:	83 e8 37             	sub    $0x37,%eax
  800dae:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800db7:	7c 02                	jl     800dbb <strtol+0x124>
			break;
  800db9:	eb 1a                	jmp    800dd5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dc2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dc6:	89 c2                	mov    %eax,%edx
  800dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcb:	01 d0                	add    %edx,%eax
  800dcd:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dd0:	e9 6f ff ff ff       	jmp    800d44 <strtol+0xad>

	if (endptr)
  800dd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd9:	74 08                	je     800de3 <strtol+0x14c>
		*endptr = (char *) s;
  800ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800de3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800de7:	74 07                	je     800df0 <strtol+0x159>
  800de9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dec:	f7 d8                	neg    %eax
  800dee:	eb 03                	jmp    800df3 <strtol+0x15c>
  800df0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	8b 55 10             	mov    0x10(%ebp),%edx
  800e04:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e07:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e0a:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e0d:	8b 75 20             	mov    0x20(%ebp),%esi
  800e10:	cd 30                	int    $0x30
  800e12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e19:	74 30                	je     800e4b <syscall+0x56>
  800e1b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e1f:	7e 2a                	jle    800e4b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2f:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3e:	00 
  800e3f:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800e46:	e8 b7 04 00 00       	call   801302 <_panic>

	return ret;
  800e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e4e:	83 c4 3c             	add    $0x3c,%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e66:	00 
  800e67:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e76:	00 
  800e77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e89:	00 
  800e8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e91:	e8 5f ff ff ff       	call   800df5 <syscall>
}
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e9e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ead:	00 
  800eae:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ec5:	00 
  800ec6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ecd:	00 
  800ece:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ed5:	e8 1b ff ff ff       	call   800df5 <syscall>
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800eec:	00 
  800eed:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800efc:	00 
  800efd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f04:	00 
  800f05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f09:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f10:	00 
  800f11:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f18:	e8 d8 fe ff ff       	call   800df5 <syscall>
}
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f25:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f34:	00 
  800f35:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f44:	00 
  800f45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f5c:	e8 94 fe ff ff       	call   800df5 <syscall>
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <sys_yield>:

void
sys_yield(void)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f69:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f70:	00 
  800f71:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f78:	00 
  800f79:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f80:	00 
  800f81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f88:	00 
  800f89:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fa0:	e8 50 fe ff ff       	call   800df5 <syscall>
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fc5:	00 
  800fc6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fe1:	e8 0f fe ff ff       	call   800df5 <syscall>
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ff0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ff3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800ff6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ff9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	89 74 24 18          	mov    %esi,0x18(%esp)
  801003:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801007:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80100b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80100f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801013:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801022:	e8 ce fd ff ff       	call   800df5 <syscall>
}
  801027:	83 c4 20             	add    $0x20,%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  801062:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801069:	e8 87 fd ff ff       	call   800df5 <syscall>
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  8010a4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010ab:	e8 45 fd ff ff       	call   800df5 <syscall>
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010d5:	00 
  8010d6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010e5:	00 
  8010e6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010ed:	e8 03 fd ff ff       	call   800df5 <syscall>
}
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010fa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010fd:	8b 55 10             	mov    0x10(%ebp),%edx
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80110a:	00 
  80110b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80110f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801113:	8b 55 0c             	mov    0xc(%ebp),%edx
  801116:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80111a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80112d:	e8 c3 fc ff ff       	call   800df5 <syscall>
}
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801144:	00 
  801145:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114c:	00 
  80114d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801154:	00 
  801155:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80115c:	00 
  80115d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801161:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801168:	00 
  801169:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801170:	e8 80 fc ff ff       	call   800df5 <syscall>
}
  801175:	c9                   	leave  
  801176:	c3                   	ret    

00801177 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  80117d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801181:	75 09                	jne    80118c <ipc_recv+0x15>
		i_dstva = UTOP;
  801183:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  80118a:	eb 06                	jmp    801192 <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  80118c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  801192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	e8 97 ff ff ff       	call   801134 <sys_ipc_recv>
  80119d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  8011a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011a4:	75 15                	jne    8011bb <ipc_recv+0x44>
  8011a6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011aa:	74 0f                	je     8011bb <ipc_recv+0x44>
  8011ac:	a1 04 20 80 00       	mov    0x802004,%eax
  8011b1:	8b 50 74             	mov    0x74(%eax),%edx
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	89 10                	mov    %edx,(%eax)
  8011b9:	eb 15                	jmp    8011d0 <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  8011bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011bf:	79 0f                	jns    8011d0 <ipc_recv+0x59>
  8011c1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011c5:	74 09                	je     8011d0 <ipc_recv+0x59>
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  8011d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011d4:	75 15                	jne    8011eb <ipc_recv+0x74>
  8011d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011da:	74 0f                	je     8011eb <ipc_recv+0x74>
  8011dc:	a1 04 20 80 00       	mov    0x802004,%eax
  8011e1:	8b 50 78             	mov    0x78(%eax),%edx
  8011e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011e7:	89 10                	mov    %edx,(%eax)
  8011e9:	eb 15                	jmp    801200 <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  8011eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011ef:	79 0f                	jns    801200 <ipc_recv+0x89>
  8011f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011f5:	74 09                	je     801200 <ipc_recv+0x89>
  8011f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8011fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  801200:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801204:	75 0a                	jne    801210 <ipc_recv+0x99>
  801206:	a1 04 20 80 00       	mov    0x802004,%eax
  80120b:	8b 40 70             	mov    0x70(%eax),%eax
  80120e:	eb 03                	jmp    801213 <ipc_recv+0x9c>
	else return r;
  801210:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  80121b:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  801222:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801226:	74 06                	je     80122e <ipc_send+0x19>
  801228:	8b 45 10             	mov    0x10(%ebp),%eax
  80122b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  80122e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801231:	8b 55 14             	mov    0x14(%ebp),%edx
  801234:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	89 04 24             	mov    %eax,(%esp)
  801249:	e8 a6 fe ff ff       	call   8010f4 <sys_ipc_try_send>
  80124e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  801251:	eb 28                	jmp    80127b <ipc_send+0x66>
		sys_yield();
  801253:	e8 0b fd ff ff       	call   800f63 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125b:	8b 55 14             	mov    0x14(%ebp),%edx
  80125e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801262:	89 44 24 08          	mov    %eax,0x8(%esp)
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
  801269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	89 04 24             	mov    %eax,(%esp)
  801273:	e8 7c fe ff ff       	call   8010f4 <sys_ipc_try_send>
  801278:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  80127b:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  80127f:	74 d2                	je     801253 <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  801281:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801285:	75 02                	jne    801289 <ipc_send+0x74>
  801287:	eb 23                	jmp    8012ac <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  801289:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801290:	c7 44 24 08 b0 18 80 	movl   $0x8018b0,0x8(%esp)
  801297:	00 
  801298:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80129f:	00 
  8012a0:	c7 04 24 d5 18 80 00 	movl   $0x8018d5,(%esp)
  8012a7:	e8 56 00 00 00       	call   801302 <_panic>
	panic("ipc_send not implemented");
}
  8012ac:	c9                   	leave  
  8012ad:	c3                   	ret    

008012ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
  8012b1:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  8012b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8012bb:	eb 35                	jmp    8012f2 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8012bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c0:	c1 e0 02             	shl    $0x2,%eax
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	c1 e2 05             	shl    $0x5,%edx
  8012c8:	29 c2                	sub    %eax,%edx
  8012ca:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8012d0:	8b 00                	mov    (%eax),%eax
  8012d2:	3b 45 08             	cmp    0x8(%ebp),%eax
  8012d5:	75 17                	jne    8012ee <ipc_find_env+0x40>
			return envs[i].env_id;
  8012d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012da:	c1 e0 02             	shl    $0x2,%eax
  8012dd:	89 c2                	mov    %eax,%edx
  8012df:	c1 e2 05             	shl    $0x5,%edx
  8012e2:	29 c2                	sub    %eax,%edx
  8012e4:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8012ea:	8b 00                	mov    (%eax),%eax
  8012ec:	eb 12                	jmp    801300 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012ee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8012f2:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8012f9:	7e c2                	jle    8012bd <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	53                   	push   %ebx
  801306:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801309:	8d 45 14             	lea    0x14(%ebp),%eax
  80130c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80130f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801315:	e8 05 fc ff ff       	call   800f1f <sys_getenvid>
  80131a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801321:	8b 55 08             	mov    0x8(%ebp),%edx
  801324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801328:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80132c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801330:	c7 04 24 e0 18 80 00 	movl   $0x8018e0,(%esp)
  801337:	e8 ae ee ff ff       	call   8001ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801343:	8b 45 10             	mov    0x10(%ebp),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 38 ee ff ff       	call   800186 <vcprintf>
	cprintf("\n");
  80134e:	c7 04 24 03 19 80 00 	movl   $0x801903,(%esp)
  801355:	e8 90 ee ff ff       	call   8001ea <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80135a:	cc                   	int3   
  80135b:	eb fd                	jmp    80135a <_panic+0x58>
  80135d:	66 90                	xchg   %ax,%ax
  80135f:	90                   	nop

00801360 <__udivdi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	83 ec 0c             	sub    $0xc,%esp
  801366:	8b 44 24 28          	mov    0x28(%esp),%eax
  80136a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80136e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801372:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801376:	85 c0                	test   %eax,%eax
  801378:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80137c:	89 ea                	mov    %ebp,%edx
  80137e:	89 0c 24             	mov    %ecx,(%esp)
  801381:	75 2d                	jne    8013b0 <__udivdi3+0x50>
  801383:	39 e9                	cmp    %ebp,%ecx
  801385:	77 61                	ja     8013e8 <__udivdi3+0x88>
  801387:	85 c9                	test   %ecx,%ecx
  801389:	89 ce                	mov    %ecx,%esi
  80138b:	75 0b                	jne    801398 <__udivdi3+0x38>
  80138d:	b8 01 00 00 00       	mov    $0x1,%eax
  801392:	31 d2                	xor    %edx,%edx
  801394:	f7 f1                	div    %ecx
  801396:	89 c6                	mov    %eax,%esi
  801398:	31 d2                	xor    %edx,%edx
  80139a:	89 e8                	mov    %ebp,%eax
  80139c:	f7 f6                	div    %esi
  80139e:	89 c5                	mov    %eax,%ebp
  8013a0:	89 f8                	mov    %edi,%eax
  8013a2:	f7 f6                	div    %esi
  8013a4:	89 ea                	mov    %ebp,%edx
  8013a6:	83 c4 0c             	add    $0xc,%esp
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    
  8013ad:	8d 76 00             	lea    0x0(%esi),%esi
  8013b0:	39 e8                	cmp    %ebp,%eax
  8013b2:	77 24                	ja     8013d8 <__udivdi3+0x78>
  8013b4:	0f bd e8             	bsr    %eax,%ebp
  8013b7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ba:	75 3c                	jne    8013f8 <__udivdi3+0x98>
  8013bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013c0:	39 34 24             	cmp    %esi,(%esp)
  8013c3:	0f 86 9f 00 00 00    	jbe    801468 <__udivdi3+0x108>
  8013c9:	39 d0                	cmp    %edx,%eax
  8013cb:	0f 82 97 00 00 00    	jb     801468 <__udivdi3+0x108>
  8013d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	31 c0                	xor    %eax,%eax
  8013dc:	83 c4 0c             	add    $0xc,%esp
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    
  8013e3:	90                   	nop
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	89 f8                	mov    %edi,%eax
  8013ea:	f7 f1                	div    %ecx
  8013ec:	31 d2                	xor    %edx,%edx
  8013ee:	83 c4 0c             	add    $0xc,%esp
  8013f1:	5e                   	pop    %esi
  8013f2:	5f                   	pop    %edi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    
  8013f5:	8d 76 00             	lea    0x0(%esi),%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	8b 3c 24             	mov    (%esp),%edi
  8013fd:	d3 e0                	shl    %cl,%eax
  8013ff:	89 c6                	mov    %eax,%esi
  801401:	b8 20 00 00 00       	mov    $0x20,%eax
  801406:	29 e8                	sub    %ebp,%eax
  801408:	89 c1                	mov    %eax,%ecx
  80140a:	d3 ef                	shr    %cl,%edi
  80140c:	89 e9                	mov    %ebp,%ecx
  80140e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801412:	8b 3c 24             	mov    (%esp),%edi
  801415:	09 74 24 08          	or     %esi,0x8(%esp)
  801419:	89 d6                	mov    %edx,%esi
  80141b:	d3 e7                	shl    %cl,%edi
  80141d:	89 c1                	mov    %eax,%ecx
  80141f:	89 3c 24             	mov    %edi,(%esp)
  801422:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801426:	d3 ee                	shr    %cl,%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	d3 e2                	shl    %cl,%edx
  80142c:	89 c1                	mov    %eax,%ecx
  80142e:	d3 ef                	shr    %cl,%edi
  801430:	09 d7                	or     %edx,%edi
  801432:	89 f2                	mov    %esi,%edx
  801434:	89 f8                	mov    %edi,%eax
  801436:	f7 74 24 08          	divl   0x8(%esp)
  80143a:	89 d6                	mov    %edx,%esi
  80143c:	89 c7                	mov    %eax,%edi
  80143e:	f7 24 24             	mull   (%esp)
  801441:	39 d6                	cmp    %edx,%esi
  801443:	89 14 24             	mov    %edx,(%esp)
  801446:	72 30                	jb     801478 <__udivdi3+0x118>
  801448:	8b 54 24 04          	mov    0x4(%esp),%edx
  80144c:	89 e9                	mov    %ebp,%ecx
  80144e:	d3 e2                	shl    %cl,%edx
  801450:	39 c2                	cmp    %eax,%edx
  801452:	73 05                	jae    801459 <__udivdi3+0xf9>
  801454:	3b 34 24             	cmp    (%esp),%esi
  801457:	74 1f                	je     801478 <__udivdi3+0x118>
  801459:	89 f8                	mov    %edi,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	e9 7a ff ff ff       	jmp    8013dc <__udivdi3+0x7c>
  801462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801468:	31 d2                	xor    %edx,%edx
  80146a:	b8 01 00 00 00       	mov    $0x1,%eax
  80146f:	e9 68 ff ff ff       	jmp    8013dc <__udivdi3+0x7c>
  801474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801478:	8d 47 ff             	lea    -0x1(%edi),%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	83 c4 0c             	add    $0xc,%esp
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    
  801484:	66 90                	xchg   %ax,%ax
  801486:	66 90                	xchg   %ax,%ax
  801488:	66 90                	xchg   %ax,%ax
  80148a:	66 90                	xchg   %ax,%ax
  80148c:	66 90                	xchg   %ax,%ax
  80148e:	66 90                	xchg   %ax,%ax

00801490 <__umoddi3>:
  801490:	55                   	push   %ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	83 ec 14             	sub    $0x14,%esp
  801496:	8b 44 24 28          	mov    0x28(%esp),%eax
  80149a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80149e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014a2:	89 c7                	mov    %eax,%edi
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014b0:	89 34 24             	mov    %esi,(%esp)
  8014b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	89 c2                	mov    %eax,%edx
  8014bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014bf:	75 17                	jne    8014d8 <__umoddi3+0x48>
  8014c1:	39 fe                	cmp    %edi,%esi
  8014c3:	76 4b                	jbe    801510 <__umoddi3+0x80>
  8014c5:	89 c8                	mov    %ecx,%eax
  8014c7:	89 fa                	mov    %edi,%edx
  8014c9:	f7 f6                	div    %esi
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	31 d2                	xor    %edx,%edx
  8014cf:	83 c4 14             	add    $0x14,%esp
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    
  8014d6:	66 90                	xchg   %ax,%ax
  8014d8:	39 f8                	cmp    %edi,%eax
  8014da:	77 54                	ja     801530 <__umoddi3+0xa0>
  8014dc:	0f bd e8             	bsr    %eax,%ebp
  8014df:	83 f5 1f             	xor    $0x1f,%ebp
  8014e2:	75 5c                	jne    801540 <__umoddi3+0xb0>
  8014e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014e8:	39 3c 24             	cmp    %edi,(%esp)
  8014eb:	0f 87 e7 00 00 00    	ja     8015d8 <__umoddi3+0x148>
  8014f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014f5:	29 f1                	sub    %esi,%ecx
  8014f7:	19 c7                	sbb    %eax,%edi
  8014f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801501:	8b 44 24 08          	mov    0x8(%esp),%eax
  801505:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801509:	83 c4 14             	add    $0x14,%esp
  80150c:	5e                   	pop    %esi
  80150d:	5f                   	pop    %edi
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    
  801510:	85 f6                	test   %esi,%esi
  801512:	89 f5                	mov    %esi,%ebp
  801514:	75 0b                	jne    801521 <__umoddi3+0x91>
  801516:	b8 01 00 00 00       	mov    $0x1,%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	f7 f6                	div    %esi
  80151f:	89 c5                	mov    %eax,%ebp
  801521:	8b 44 24 04          	mov    0x4(%esp),%eax
  801525:	31 d2                	xor    %edx,%edx
  801527:	f7 f5                	div    %ebp
  801529:	89 c8                	mov    %ecx,%eax
  80152b:	f7 f5                	div    %ebp
  80152d:	eb 9c                	jmp    8014cb <__umoddi3+0x3b>
  80152f:	90                   	nop
  801530:	89 c8                	mov    %ecx,%eax
  801532:	89 fa                	mov    %edi,%edx
  801534:	83 c4 14             	add    $0x14,%esp
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    
  80153b:	90                   	nop
  80153c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801540:	8b 04 24             	mov    (%esp),%eax
  801543:	be 20 00 00 00       	mov    $0x20,%esi
  801548:	89 e9                	mov    %ebp,%ecx
  80154a:	29 ee                	sub    %ebp,%esi
  80154c:	d3 e2                	shl    %cl,%edx
  80154e:	89 f1                	mov    %esi,%ecx
  801550:	d3 e8                	shr    %cl,%eax
  801552:	89 e9                	mov    %ebp,%ecx
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	8b 04 24             	mov    (%esp),%eax
  80155b:	09 54 24 04          	or     %edx,0x4(%esp)
  80155f:	89 fa                	mov    %edi,%edx
  801561:	d3 e0                	shl    %cl,%eax
  801563:	89 f1                	mov    %esi,%ecx
  801565:	89 44 24 08          	mov    %eax,0x8(%esp)
  801569:	8b 44 24 10          	mov    0x10(%esp),%eax
  80156d:	d3 ea                	shr    %cl,%edx
  80156f:	89 e9                	mov    %ebp,%ecx
  801571:	d3 e7                	shl    %cl,%edi
  801573:	89 f1                	mov    %esi,%ecx
  801575:	d3 e8                	shr    %cl,%eax
  801577:	89 e9                	mov    %ebp,%ecx
  801579:	09 f8                	or     %edi,%eax
  80157b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80157f:	f7 74 24 04          	divl   0x4(%esp)
  801583:	d3 e7                	shl    %cl,%edi
  801585:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801589:	89 d7                	mov    %edx,%edi
  80158b:	f7 64 24 08          	mull   0x8(%esp)
  80158f:	39 d7                	cmp    %edx,%edi
  801591:	89 c1                	mov    %eax,%ecx
  801593:	89 14 24             	mov    %edx,(%esp)
  801596:	72 2c                	jb     8015c4 <__umoddi3+0x134>
  801598:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80159c:	72 22                	jb     8015c0 <__umoddi3+0x130>
  80159e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015a2:	29 c8                	sub    %ecx,%eax
  8015a4:	19 d7                	sbb    %edx,%edi
  8015a6:	89 e9                	mov    %ebp,%ecx
  8015a8:	89 fa                	mov    %edi,%edx
  8015aa:	d3 e8                	shr    %cl,%eax
  8015ac:	89 f1                	mov    %esi,%ecx
  8015ae:	d3 e2                	shl    %cl,%edx
  8015b0:	89 e9                	mov    %ebp,%ecx
  8015b2:	d3 ef                	shr    %cl,%edi
  8015b4:	09 d0                	or     %edx,%eax
  8015b6:	89 fa                	mov    %edi,%edx
  8015b8:	83 c4 14             	add    $0x14,%esp
  8015bb:	5e                   	pop    %esi
  8015bc:	5f                   	pop    %edi
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    
  8015bf:	90                   	nop
  8015c0:	39 d7                	cmp    %edx,%edi
  8015c2:	75 da                	jne    80159e <__umoddi3+0x10e>
  8015c4:	8b 14 24             	mov    (%esp),%edx
  8015c7:	89 c1                	mov    %eax,%ecx
  8015c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8015d1:	eb cb                	jmp    80159e <__umoddi3+0x10e>
  8015d3:	90                   	nop
  8015d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015dc:	0f 82 0f ff ff ff    	jb     8014f1 <__umoddi3+0x61>
  8015e2:	e9 1a ff ff ff       	jmp    801501 <__umoddi3+0x71>
