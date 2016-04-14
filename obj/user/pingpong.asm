
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 24             	sub    $0x24,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003a:	e8 9c 14 00 00       	call   8014db <fork>
  80003f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800042:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800045:	85 c0                	test   %eax,%eax
  800047:	74 3f                	je     800088 <umain+0x55>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800049:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80004c:	e8 0e 0f 00 00       	call   800f5f <sys_getenvid>
  800051:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 a0 1b 80 00 	movl   $0x801ba0,(%esp)
  800060:	e8 c5 01 00 00       	call   80022a <cprintf>
		ipc_send(who, 0, 0, 0);
  800065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006f:	00 
  800070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	89 04 24             	mov    %eax,(%esp)
  800083:	e8 a5 16 00 00       	call   80172d <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800088:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800097:	00 
  800098:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80009b:	89 04 24             	mov    %eax,(%esp)
  80009e:	e8 ec 15 00 00       	call   80168f <ipc_recv>
  8000a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8000a9:	e8 b1 0e 00 00       	call   800f5f <sys_getenvid>
  8000ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 b6 1b 80 00 	movl   $0x801bb6,(%esp)
  8000c4:	e8 61 01 00 00       	call   80022a <cprintf>
		if (i == 10)
  8000c9:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
  8000cd:	75 02                	jne    8000d1 <umain+0x9e>
			return;
  8000cf:	eb 30                	jmp    800101 <umain+0xce>
		i++;
  8000d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		ipc_send(who, i, 0, 0);
  8000d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000df:	00 
  8000e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e7:	00 
  8000e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8000ef:	89 04 24             	mov    %eax,(%esp)
  8000f2:	e8 36 16 00 00       	call   80172d <ipc_send>
		if (i == 10)
  8000f7:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
  8000fb:	75 02                	jne    8000ff <umain+0xcc>
			return;
  8000fd:	eb 02                	jmp    800101 <umain+0xce>
	}
  8000ff:	eb 87                	jmp    800088 <umain+0x55>

}
  800101:	83 c4 24             	add    $0x24,%esp
  800104:	5b                   	pop    %ebx
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80010d:	e8 4d 0e 00 00       	call   800f5f <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	c1 e0 02             	shl    $0x2,%eax
  80011a:	89 c2                	mov    %eax,%edx
  80011c:	c1 e2 05             	shl    $0x5,%edx
  80011f:	29 c2                	sub    %eax,%edx
  800121:	89 d0                	mov    %edx,%eax
  800123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800128:	a3 04 30 80 00       	mov    %eax,0x803004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800131:	7e 0a                	jle    80013d <libmain+0x36>
		binaryname = argv[0];
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	8b 00                	mov    (%eax),%eax
  800138:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	8b 45 08             	mov    0x8(%ebp),%eax
  800147:	89 04 24             	mov    %eax,(%esp)
  80014a:	e8 e4 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80014f:	e8 02 00 00 00       	call   800156 <exit>
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800163:	e8 b4 0d 00 00       	call   800f1c <sys_env_destroy>
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	8b 00                	mov    (%eax),%eax
  800175:	8d 48 01             	lea    0x1(%eax),%ecx
  800178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017b:	89 0a                	mov    %ecx,(%edx)
  80017d:	8b 55 08             	mov    0x8(%ebp),%edx
  800180:	89 d1                	mov    %edx,%ecx
  800182:	8b 55 0c             	mov    0xc(%ebp),%edx
  800185:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800189:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018c:	8b 00                	mov    (%eax),%eax
  80018e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800193:	75 20                	jne    8001b5 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800195:	8b 45 0c             	mov    0xc(%ebp),%eax
  800198:	8b 00                	mov    (%eax),%eax
  80019a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019d:	83 c2 08             	add    $0x8,%edx
  8001a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a4:	89 14 24             	mov    %edx,(%esp)
  8001a7:	e8 ea 0c 00 00       	call   800e96 <sys_cputs>
		b->idx = 0;
  8001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b8:	8b 40 04             	mov    0x4(%eax),%eax
  8001bb:	8d 50 01             	lea    0x1(%eax),%edx
  8001be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c1:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d6:	00 00 00 
	b.cnt = 0;
  8001d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	c7 04 24 6a 01 80 00 	movl   $0x80016a,(%esp)
  800202:	e8 bd 01 00 00       	call   8003c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800207:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800217:	83 c0 08             	add    $0x8,%eax
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	e8 74 0c 00 00       	call   800e96 <sys_cputs>

	return b.cnt;
  800222:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800230:	8d 45 0c             	lea    0xc(%ebp),%eax
  800233:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800236:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 7e ff ff ff       	call   8001c6 <vcprintf>
  800248:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80024b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	53                   	push   %ebx
  800254:	83 ec 34             	sub    $0x34,%esp
  800257:	8b 45 10             	mov    0x10(%ebp),%eax
  80025a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80025d:	8b 45 14             	mov    0x14(%ebp),%eax
  800260:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800263:	8b 45 18             	mov    0x18(%ebp),%eax
  800266:	ba 00 00 00 00       	mov    $0x0,%edx
  80026b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80026e:	77 72                	ja     8002e2 <printnum+0x92>
  800270:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800273:	72 05                	jb     80027a <printnum+0x2a>
  800275:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800278:	77 68                	ja     8002e2 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80027d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800280:	8b 45 18             	mov    0x18(%ebp),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
  800288:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800290:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800293:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800296:	89 04 24             	mov    %eax,(%esp)
  800299:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029d:	e8 6e 16 00 00       	call   801910 <__udivdi3>
  8002a2:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002a5:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002a9:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ad:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002b0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	e8 82 ff ff ff       	call   800250 <printnum>
  8002ce:	eb 1c                	jmp    8002ec <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d7:	8b 45 20             	mov    0x20(%ebp),%eax
  8002da:	89 04 24             	mov    %eax,(%esp)
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002e6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002ea:	7f e4                	jg     8002d0 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ec:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	89 54 24 04          	mov    %edx,0x4(%esp)
  800309:	e8 32 17 00 00       	call   801a40 <__umoddi3>
  80030e:	05 a8 1c 80 00       	add    $0x801ca8,%eax
  800313:	0f b6 00             	movzbl (%eax),%eax
  800316:	0f be c0             	movsbl %al,%eax
  800319:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	ff d0                	call   *%eax
}
  800328:	83 c4 34             	add    $0x34,%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800331:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800335:	7e 14                	jle    80034b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	8d 48 08             	lea    0x8(%eax),%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 0a                	mov    %ecx,(%edx)
  800344:	8b 50 04             	mov    0x4(%eax),%edx
  800347:	8b 00                	mov    (%eax),%eax
  800349:	eb 30                	jmp    80037b <getuint+0x4d>
	else if (lflag)
  80034b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80034f:	74 16                	je     800367 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	8b 00                	mov    (%eax),%eax
  800356:	8d 48 04             	lea    0x4(%eax),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 0a                	mov    %ecx,(%edx)
  80035e:	8b 00                	mov    (%eax),%eax
  800360:	ba 00 00 00 00       	mov    $0x0,%edx
  800365:	eb 14                	jmp    80037b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	8b 55 08             	mov    0x8(%ebp),%edx
  800372:	89 0a                	mov    %ecx,(%edx)
  800374:	8b 00                	mov    (%eax),%eax
  800376:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800380:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800384:	7e 14                	jle    80039a <getint+0x1d>
		return va_arg(*ap, long long);
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	8b 00                	mov    (%eax),%eax
  80038b:	8d 48 08             	lea    0x8(%eax),%ecx
  80038e:	8b 55 08             	mov    0x8(%ebp),%edx
  800391:	89 0a                	mov    %ecx,(%edx)
  800393:	8b 50 04             	mov    0x4(%eax),%edx
  800396:	8b 00                	mov    (%eax),%eax
  800398:	eb 28                	jmp    8003c2 <getint+0x45>
	else if (lflag)
  80039a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80039e:	74 12                	je     8003b2 <getint+0x35>
		return va_arg(*ap, long);
  8003a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ab:	89 0a                	mov    %ecx,(%edx)
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	99                   	cltd   
  8003b0:	eb 10                	jmp    8003c2 <getint+0x45>
	else
		return va_arg(*ap, int);
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 0a                	mov    %ecx,(%edx)
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
}
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    

008003c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cc:	eb 18                	jmp    8003e6 <vprintfmt+0x22>
			if (ch == '\0')
  8003ce:	85 db                	test   %ebx,%ebx
  8003d0:	75 05                	jne    8003d7 <vprintfmt+0x13>
				return;
  8003d2:	e9 cc 03 00 00       	jmp    8007a3 <vprintfmt+0x3df>
			putch(ch, putdat);
  8003d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003de:	89 1c 24             	mov    %ebx,(%esp)
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e9:	8d 50 01             	lea    0x1(%eax),%edx
  8003ec:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ef:	0f b6 00             	movzbl (%eax),%eax
  8003f2:	0f b6 d8             	movzbl %al,%ebx
  8003f5:	83 fb 25             	cmp    $0x25,%ebx
  8003f8:	75 d4                	jne    8003ce <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003fa:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800405:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80040c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800413:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 45 10             	mov    0x10(%ebp),%eax
  80041d:	8d 50 01             	lea    0x1(%eax),%edx
  800420:	89 55 10             	mov    %edx,0x10(%ebp)
  800423:	0f b6 00             	movzbl (%eax),%eax
  800426:	0f b6 d8             	movzbl %al,%ebx
  800429:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80042c:	83 f8 55             	cmp    $0x55,%eax
  80042f:	0f 87 3d 03 00 00    	ja     800772 <vprintfmt+0x3ae>
  800435:	8b 04 85 cc 1c 80 00 	mov    0x801ccc(,%eax,4),%eax
  80043c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80043e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800442:	eb d6                	jmp    80041a <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800444:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800448:	eb d0                	jmp    80041a <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800451:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800454:	89 d0                	mov    %edx,%eax
  800456:	c1 e0 02             	shl    $0x2,%eax
  800459:	01 d0                	add    %edx,%eax
  80045b:	01 c0                	add    %eax,%eax
  80045d:	01 d8                	add    %ebx,%eax
  80045f:	83 e8 30             	sub    $0x30,%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	0f b6 00             	movzbl (%eax),%eax
  80046b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80046e:	83 fb 2f             	cmp    $0x2f,%ebx
  800471:	7e 0b                	jle    80047e <vprintfmt+0xba>
  800473:	83 fb 39             	cmp    $0x39,%ebx
  800476:	7f 06                	jg     80047e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800478:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80047c:	eb d3                	jmp    800451 <vprintfmt+0x8d>
			goto process_precision;
  80047e:	eb 33                	jmp    8004b3 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80048e:	eb 23                	jmp    8004b3 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800490:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800494:	79 0c                	jns    8004a2 <vprintfmt+0xde>
				width = 0;
  800496:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80049d:	e9 78 ff ff ff       	jmp    80041a <vprintfmt+0x56>
  8004a2:	e9 73 ff ff ff       	jmp    80041a <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004a7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004ae:	e9 67 ff ff ff       	jmp    80041a <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8004b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b7:	79 12                	jns    8004cb <vprintfmt+0x107>
				width = precision, precision = -1;
  8004b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8004c6:	e9 4f ff ff ff       	jmp    80041a <vprintfmt+0x56>
  8004cb:	e9 4a ff ff ff       	jmp    80041a <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d0:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8004d4:	e9 41 ff ff ff       	jmp    80041a <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 00                	mov    (%eax),%eax
  8004e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	ff d0                	call   *%eax
			break;
  8004f3:	e9 a5 02 00 00       	jmp    80079d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800503:	85 db                	test   %ebx,%ebx
  800505:	79 02                	jns    800509 <vprintfmt+0x145>
				err = -err;
  800507:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800509:	83 fb 09             	cmp    $0x9,%ebx
  80050c:	7f 0b                	jg     800519 <vprintfmt+0x155>
  80050e:	8b 34 9d 80 1c 80 00 	mov    0x801c80(,%ebx,4),%esi
  800515:	85 f6                	test   %esi,%esi
  800517:	75 23                	jne    80053c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800519:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80051d:	c7 44 24 08 b9 1c 80 	movl   $0x801cb9,0x8(%esp)
  800524:	00 
  800525:	8b 45 0c             	mov    0xc(%ebp),%eax
  800528:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052c:	8b 45 08             	mov    0x8(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	e8 73 02 00 00       	call   8007aa <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800537:	e9 61 02 00 00       	jmp    80079d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80053c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800540:	c7 44 24 08 c2 1c 80 	movl   $0x801cc2,0x8(%esp)
  800547:	00 
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	8b 45 08             	mov    0x8(%ebp),%eax
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	e8 50 02 00 00       	call   8007aa <printfmt>
			break;
  80055a:	e9 3e 02 00 00       	jmp    80079d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 30                	mov    (%eax),%esi
  80056a:	85 f6                	test   %esi,%esi
  80056c:	75 05                	jne    800573 <vprintfmt+0x1af>
				p = "(null)";
  80056e:	be c5 1c 80 00       	mov    $0x801cc5,%esi
			if (width > 0 && padc != '-')
  800573:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800577:	7e 37                	jle    8005b0 <vprintfmt+0x1ec>
  800579:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80057d:	74 31                	je     8005b0 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800582:	89 44 24 04          	mov    %eax,0x4(%esp)
  800586:	89 34 24             	mov    %esi,(%esp)
  800589:	e8 39 03 00 00       	call   8008c7 <strnlen>
  80058e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800591:	eb 17                	jmp    8005aa <vprintfmt+0x1e6>
					putch(padc, putdat);
  800593:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800597:	8b 55 0c             	mov    0xc(%ebp),%edx
  80059a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80059e:	89 04 24             	mov    %eax,(%esp)
  8005a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a4:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ae:	7f e3                	jg     800593 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b0:	eb 38                	jmp    8005ea <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b6:	74 1f                	je     8005d7 <vprintfmt+0x213>
  8005b8:	83 fb 1f             	cmp    $0x1f,%ebx
  8005bb:	7e 05                	jle    8005c2 <vprintfmt+0x1fe>
  8005bd:	83 fb 7e             	cmp    $0x7e,%ebx
  8005c0:	7e 15                	jle    8005d7 <vprintfmt+0x213>
					putch('?', putdat);
  8005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d3:	ff d0                	call   *%eax
  8005d5:	eb 0f                	jmp    8005e6 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8005d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005de:	89 1c 24             	mov    %ebx,(%esp)
  8005e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e4:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005ea:	89 f0                	mov    %esi,%eax
  8005ec:	8d 70 01             	lea    0x1(%eax),%esi
  8005ef:	0f b6 00             	movzbl (%eax),%eax
  8005f2:	0f be d8             	movsbl %al,%ebx
  8005f5:	85 db                	test   %ebx,%ebx
  8005f7:	74 10                	je     800609 <vprintfmt+0x245>
  8005f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fd:	78 b3                	js     8005b2 <vprintfmt+0x1ee>
  8005ff:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800603:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800607:	79 a9                	jns    8005b2 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800609:	eb 17                	jmp    800622 <vprintfmt+0x25e>
				putch(' ', putdat);
  80060b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800612:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800622:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800626:	7f e3                	jg     80060b <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800628:	e9 70 01 00 00       	jmp    80079d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800630:	89 44 24 04          	mov    %eax,0x4(%esp)
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	e8 3e fd ff ff       	call   80037d <getint>
  80063f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800642:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800648:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80064b:	85 d2                	test   %edx,%edx
  80064d:	79 26                	jns    800675 <vprintfmt+0x2b1>
				putch('-', putdat);
  80064f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800652:	89 44 24 04          	mov    %eax,0x4(%esp)
  800656:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	ff d0                	call   *%eax
				num = -(long long) num;
  800662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800665:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800668:	f7 d8                	neg    %eax
  80066a:	83 d2 00             	adc    $0x0,%edx
  80066d:	f7 da                	neg    %edx
  80066f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800672:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800675:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80067c:	e9 a8 00 00 00       	jmp    800729 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800681:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800684:	89 44 24 04          	mov    %eax,0x4(%esp)
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
  80068b:	89 04 24             	mov    %eax,(%esp)
  80068e:	e8 9b fc ff ff       	call   80032e <getuint>
  800693:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800696:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800699:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006a0:	e9 84 00 00 00       	jmp    800729 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	e8 77 fc ff ff       	call   80032e <getuint>
  8006b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8006bd:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8006c4:	eb 63                	jmp    800729 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	ff d0                	call   *%eax
			putch('x', putdat);
  8006d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ea:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 50 04             	lea    0x4(%eax),%edx
  8006f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800701:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800708:	eb 1f                	jmp    800729 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80070d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	e8 12 fc ff ff       	call   80032e <getuint>
  80071c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800722:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800729:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80072d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800730:	89 54 24 18          	mov    %edx,0x18(%esp)
  800734:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800737:	89 54 24 14          	mov    %edx,0x14(%esp)
  80073b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800750:	89 44 24 04          	mov    %eax,0x4(%esp)
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	e8 f1 fa ff ff       	call   800250 <printnum>
			break;
  80075f:	eb 3c                	jmp    80079d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800761:	8b 45 0c             	mov    0xc(%ebp),%eax
  800764:	89 44 24 04          	mov    %eax,0x4(%esp)
  800768:	89 1c 24             	mov    %ebx,(%esp)
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	ff d0                	call   *%eax
			break;
  800770:	eb 2b                	jmp    80079d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	8b 45 0c             	mov    0xc(%ebp),%eax
  800775:	89 44 24 04          	mov    %eax,0x4(%esp)
  800779:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800785:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800789:	eb 04                	jmp    80078f <vprintfmt+0x3cb>
  80078b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80078f:	8b 45 10             	mov    0x10(%ebp),%eax
  800792:	83 e8 01             	sub    $0x1,%eax
  800795:	0f b6 00             	movzbl (%eax),%eax
  800798:	3c 25                	cmp    $0x25,%al
  80079a:	75 ef                	jne    80078b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80079c:	90                   	nop
		}
	}
  80079d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079e:	e9 43 fc ff ff       	jmp    8003e6 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007a3:	83 c4 40             	add    $0x40,%esp
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	89 04 24             	mov    %eax,(%esp)
  8007d1:	e8 ee fb ff ff       	call   8003c4 <vprintfmt>
	va_end(ap);
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007de:	8b 40 08             	mov    0x8(%eax),%eax
  8007e1:	8d 50 01             	lea    0x1(%eax),%edx
  8007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e7:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	8b 10                	mov    (%eax),%edx
  8007ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f2:	8b 40 04             	mov    0x4(%eax),%eax
  8007f5:	39 c2                	cmp    %eax,%edx
  8007f7:	73 12                	jae    80080b <sprintputch+0x33>
		*b->buf++ = ch;
  8007f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fc:	8b 00                	mov    (%eax),%eax
  8007fe:	8d 48 01             	lea    0x1(%eax),%ecx
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
  800804:	89 0a                	mov    %ecx,(%edx)
  800806:	8b 55 08             	mov    0x8(%ebp),%edx
  800809:	88 10                	mov    %dl,(%eax)
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80081f:	8b 45 08             	mov    0x8(%ebp),%eax
  800822:	01 d0                	add    %edx,%eax
  800824:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800827:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800832:	74 06                	je     80083a <vsnprintf+0x2d>
  800834:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800838:	7f 07                	jg     800841 <vsnprintf+0x34>
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083f:	eb 2a                	jmp    80086b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800848:	8b 45 10             	mov    0x10(%ebp),%eax
  80084b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800852:	89 44 24 04          	mov    %eax,0x4(%esp)
  800856:	c7 04 24 d8 07 80 00 	movl   $0x8007d8,(%esp)
  80085d:	e8 62 fb ff ff       	call   8003c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800862:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800865:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800868:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
  800876:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800880:	8b 45 10             	mov    0x10(%ebp),%eax
  800883:	89 44 24 08          	mov    %eax,0x8(%esp)
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	89 04 24             	mov    %eax,(%esp)
  800894:	e8 74 ff ff ff       	call   80080d <vsnprintf>
  800899:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80089c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008ae:	eb 08                	jmp    8008b8 <strlen+0x17>
		n++;
  8008b0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	84 c0                	test   %al,%al
  8008c0:	75 ee                	jne    8008b0 <strlen+0xf>
		n++;
	return n;
  8008c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008d4:	eb 0c                	jmp    8008e2 <strnlen+0x1b>
		n++;
  8008d6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008de:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008e6:	74 0a                	je     8008f2 <strnlen+0x2b>
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	84 c0                	test   %al,%al
  8008f0:	75 e4                	jne    8008d6 <strnlen+0xf>
		n++;
	return n;
  8008f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800903:	90                   	nop
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8d 50 01             	lea    0x1(%eax),%edx
  80090a:	89 55 08             	mov    %edx,0x8(%ebp)
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	8d 4a 01             	lea    0x1(%edx),%ecx
  800913:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	88 10                	mov    %dl,(%eax)
  80091b:	0f b6 00             	movzbl (%eax),%eax
  80091e:	84 c0                	test   %al,%al
  800920:	75 e2                	jne    800904 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800922:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	89 04 24             	mov    %eax,(%esp)
  800933:	e8 69 ff ff ff       	call   8008a1 <strlen>
  800938:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80093b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	01 c2                	add    %eax,%edx
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094a:	89 14 24             	mov    %edx,(%esp)
  80094d:	e8 a5 ff ff ff       	call   8008f7 <strcpy>
	return dst;
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800955:	c9                   	leave  
  800956:	c3                   	ret    

00800957 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800963:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80096a:	eb 23                	jmp    80098f <strncpy+0x38>
		*dst++ = *src;
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8d 50 01             	lea    0x1(%eax),%edx
  800972:	89 55 08             	mov    %edx,0x8(%ebp)
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	0f b6 00             	movzbl (%eax),%eax
  800983:	84 c0                	test   %al,%al
  800985:	74 04                	je     80098b <strncpy+0x34>
			src++;
  800987:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80098f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800992:	3b 45 10             	cmp    0x10(%ebp),%eax
  800995:	72 d5                	jb     80096c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800997:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ac:	74 33                	je     8009e1 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009ae:	eb 17                	jmp    8009c7 <strlcpy+0x2b>
			*dst++ = *src++;
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8d 50 01             	lea    0x1(%eax),%edx
  8009b6:	89 55 08             	mov    %edx,0x8(%ebp)
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009bf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009c2:	0f b6 12             	movzbl (%edx),%edx
  8009c5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009cf:	74 0a                	je     8009db <strlcpy+0x3f>
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d4:	0f b6 00             	movzbl (%eax),%eax
  8009d7:	84 c0                	test   %al,%al
  8009d9:	75 d5                	jne    8009b0 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009e7:	29 c2                	sub    %eax,%edx
  8009e9:	89 d0                	mov    %edx,%eax
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009f0:	eb 08                	jmp    8009fa <strcmp+0xd>
		p++, q++;
  8009f2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009f6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	0f b6 00             	movzbl (%eax),%eax
  800a00:	84 c0                	test   %al,%al
  800a02:	74 10                	je     800a14 <strcmp+0x27>
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	0f b6 10             	movzbl (%eax),%edx
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	0f b6 00             	movzbl (%eax),%eax
  800a10:	38 c2                	cmp    %al,%dl
  800a12:	74 de                	je     8009f2 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	0f b6 00             	movzbl (%eax),%eax
  800a1a:	0f b6 d0             	movzbl %al,%edx
  800a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a20:	0f b6 00             	movzbl (%eax),%eax
  800a23:	0f b6 c0             	movzbl %al,%eax
  800a26:	29 c2                	sub    %eax,%edx
  800a28:	89 d0                	mov    %edx,%eax
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a2f:	eb 0c                	jmp    800a3d <strncmp+0x11>
		n--, p++, q++;
  800a31:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a35:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a39:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a41:	74 1a                	je     800a5d <strncmp+0x31>
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	0f b6 00             	movzbl (%eax),%eax
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 10                	je     800a5d <strncmp+0x31>
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 10             	movzbl (%eax),%edx
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	0f b6 00             	movzbl (%eax),%eax
  800a59:	38 c2                	cmp    %al,%dl
  800a5b:	74 d4                	je     800a31 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a61:	75 07                	jne    800a6a <strncmp+0x3e>
		return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	eb 16                	jmp    800a80 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 00             	movzbl (%eax),%eax
  800a70:	0f b6 d0             	movzbl %al,%edx
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	0f b6 00             	movzbl (%eax),%eax
  800a79:	0f b6 c0             	movzbl %al,%eax
  800a7c:	29 c2                	sub    %eax,%edx
  800a7e:	89 d0                	mov    %edx,%eax
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 04             	sub    $0x4,%esp
  800a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a8e:	eb 14                	jmp    800aa4 <strchr+0x22>
		if (*s == c)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	0f b6 00             	movzbl (%eax),%eax
  800a96:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a99:	75 05                	jne    800aa0 <strchr+0x1e>
			return (char *) s;
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	eb 13                	jmp    800ab3 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aa0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	0f b6 00             	movzbl (%eax),%eax
  800aaa:	84 c0                	test   %al,%al
  800aac:	75 e2                	jne    800a90 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab3:	c9                   	leave  
  800ab4:	c3                   	ret    

00800ab5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	83 ec 04             	sub    $0x4,%esp
  800abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abe:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ac1:	eb 11                	jmp    800ad4 <strfind+0x1f>
		if (*s == c)
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	0f b6 00             	movzbl (%eax),%eax
  800ac9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800acc:	75 02                	jne    800ad0 <strfind+0x1b>
			break;
  800ace:	eb 0e                	jmp    800ade <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ad0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	0f b6 00             	movzbl (%eax),%eax
  800ada:	84 c0                	test   %al,%al
  800adc:	75 e5                	jne    800ac3 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ae7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aeb:	75 05                	jne    800af2 <memset+0xf>
		return v;
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	eb 5c                	jmp    800b4e <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	83 e0 03             	and    $0x3,%eax
  800af8:	85 c0                	test   %eax,%eax
  800afa:	75 41                	jne    800b3d <memset+0x5a>
  800afc:	8b 45 10             	mov    0x10(%ebp),%eax
  800aff:	83 e0 03             	and    $0x3,%eax
  800b02:	85 c0                	test   %eax,%eax
  800b04:	75 37                	jne    800b3d <memset+0x5a>
		c &= 0xFF;
  800b06:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	c1 e0 18             	shl    $0x18,%eax
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	c1 e0 10             	shl    $0x10,%eax
  800b1b:	09 c2                	or     %eax,%edx
  800b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b20:	c1 e0 08             	shl    $0x8,%eax
  800b23:	09 d0                	or     %edx,%eax
  800b25:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b28:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2b:	c1 e8 02             	shr    $0x2,%eax
  800b2e:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	fc                   	cld    
  800b39:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3b:	eb 0e                	jmp    800b4b <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	fc                   	cld    
  800b49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b69:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b6c:	73 6d                	jae    800bdb <memmove+0x8a>
  800b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b71:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b74:	01 d0                	add    %edx,%eax
  800b76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b79:	76 60                	jbe    800bdb <memmove+0x8a>
		s += n;
  800b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b81:	8b 45 10             	mov    0x10(%ebp),%eax
  800b84:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8a:	83 e0 03             	and    $0x3,%eax
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	75 2f                	jne    800bc0 <memmove+0x6f>
  800b91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b94:	83 e0 03             	and    $0x3,%eax
  800b97:	85 c0                	test   %eax,%eax
  800b99:	75 25                	jne    800bc0 <memmove+0x6f>
  800b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9e:	83 e0 03             	and    $0x3,%eax
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	75 1b                	jne    800bc0 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ba8:	83 e8 04             	sub    $0x4,%eax
  800bab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bae:	83 ea 04             	sub    $0x4,%edx
  800bb1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bb7:	89 c7                	mov    %eax,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	fd                   	std    
  800bbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbe:	eb 18                	jmp    800bd8 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc9:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 de                	mov    %ebx,%esi
  800bd3:	89 c1                	mov    %eax,%ecx
  800bd5:	fd                   	std    
  800bd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd8:	fc                   	cld    
  800bd9:	eb 45                	jmp    800c20 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bde:	83 e0 03             	and    $0x3,%eax
  800be1:	85 c0                	test   %eax,%eax
  800be3:	75 2b                	jne    800c10 <memmove+0xbf>
  800be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be8:	83 e0 03             	and    $0x3,%eax
  800beb:	85 c0                	test   %eax,%eax
  800bed:	75 21                	jne    800c10 <memmove+0xbf>
  800bef:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf2:	83 e0 03             	and    $0x3,%eax
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	75 17                	jne    800c10 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfc:	c1 e8 02             	shr    $0x2,%eax
  800bff:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	fc                   	cld    
  800c0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0e:	eb 10                	jmp    800c20 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c13:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c16:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	fc                   	cld    
  800c1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c31:	8b 45 10             	mov    0x10(%ebp),%eax
  800c34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	89 04 24             	mov    %eax,(%esp)
  800c45:	e8 07 ff ff ff       	call   800b51 <memmove>
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c5e:	eb 30                	jmp    800c90 <memcmp+0x44>
		if (*s1 != *s2)
  800c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c63:	0f b6 10             	movzbl (%eax),%edx
  800c66:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c69:	0f b6 00             	movzbl (%eax),%eax
  800c6c:	38 c2                	cmp    %al,%dl
  800c6e:	74 18                	je     800c88 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c73:	0f b6 00             	movzbl (%eax),%eax
  800c76:	0f b6 d0             	movzbl %al,%edx
  800c79:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c7c:	0f b6 00             	movzbl (%eax),%eax
  800c7f:	0f b6 c0             	movzbl %al,%eax
  800c82:	29 c2                	sub    %eax,%edx
  800c84:	89 d0                	mov    %edx,%eax
  800c86:	eb 1a                	jmp    800ca2 <memcmp+0x56>
		s1++, s2++;
  800c88:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c8c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c90:	8b 45 10             	mov    0x10(%ebp),%eax
  800c93:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c96:	89 55 10             	mov    %edx,0x10(%ebp)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	75 c3                	jne    800c60 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca2:	c9                   	leave  
  800ca3:	c3                   	ret    

00800ca4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800caa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	01 d0                	add    %edx,%eax
  800cb2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800cb5:	eb 13                	jmp    800cca <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	0f b6 10             	movzbl (%eax),%edx
  800cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc0:	38 c2                	cmp    %al,%dl
  800cc2:	75 02                	jne    800cc6 <memfind+0x22>
			break;
  800cc4:	eb 0c                	jmp    800cd2 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cd0:	72 e5                	jb     800cb7 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cdd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ce4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ceb:	eb 04                	jmp    800cf1 <strtol+0x1a>
		s++;
  800ced:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	0f b6 00             	movzbl (%eax),%eax
  800cf7:	3c 20                	cmp    $0x20,%al
  800cf9:	74 f2                	je     800ced <strtol+0x16>
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	0f b6 00             	movzbl (%eax),%eax
  800d01:	3c 09                	cmp    $0x9,%al
  800d03:	74 e8                	je     800ced <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	0f b6 00             	movzbl (%eax),%eax
  800d0b:	3c 2b                	cmp    $0x2b,%al
  800d0d:	75 06                	jne    800d15 <strtol+0x3e>
		s++;
  800d0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d13:	eb 15                	jmp    800d2a <strtol+0x53>
	else if (*s == '-')
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	0f b6 00             	movzbl (%eax),%eax
  800d1b:	3c 2d                	cmp    $0x2d,%al
  800d1d:	75 0b                	jne    800d2a <strtol+0x53>
		s++, neg = 1;
  800d1f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d23:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d2e:	74 06                	je     800d36 <strtol+0x5f>
  800d30:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d34:	75 24                	jne    800d5a <strtol+0x83>
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	0f b6 00             	movzbl (%eax),%eax
  800d3c:	3c 30                	cmp    $0x30,%al
  800d3e:	75 1a                	jne    800d5a <strtol+0x83>
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	83 c0 01             	add    $0x1,%eax
  800d46:	0f b6 00             	movzbl (%eax),%eax
  800d49:	3c 78                	cmp    $0x78,%al
  800d4b:	75 0d                	jne    800d5a <strtol+0x83>
		s += 2, base = 16;
  800d4d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d51:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d58:	eb 2a                	jmp    800d84 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5e:	75 17                	jne    800d77 <strtol+0xa0>
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	3c 30                	cmp    $0x30,%al
  800d68:	75 0d                	jne    800d77 <strtol+0xa0>
		s++, base = 8;
  800d6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d6e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d75:	eb 0d                	jmp    800d84 <strtol+0xad>
	else if (base == 0)
  800d77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d7b:	75 07                	jne    800d84 <strtol+0xad>
		base = 10;
  800d7d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	0f b6 00             	movzbl (%eax),%eax
  800d8a:	3c 2f                	cmp    $0x2f,%al
  800d8c:	7e 1b                	jle    800da9 <strtol+0xd2>
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	3c 39                	cmp    $0x39,%al
  800d96:	7f 11                	jg     800da9 <strtol+0xd2>
			dig = *s - '0';
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	0f be c0             	movsbl %al,%eax
  800da1:	83 e8 30             	sub    $0x30,%eax
  800da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800da7:	eb 48                	jmp    800df1 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	0f b6 00             	movzbl (%eax),%eax
  800daf:	3c 60                	cmp    $0x60,%al
  800db1:	7e 1b                	jle    800dce <strtol+0xf7>
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	0f b6 00             	movzbl (%eax),%eax
  800db9:	3c 7a                	cmp    $0x7a,%al
  800dbb:	7f 11                	jg     800dce <strtol+0xf7>
			dig = *s - 'a' + 10;
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	0f b6 00             	movzbl (%eax),%eax
  800dc3:	0f be c0             	movsbl %al,%eax
  800dc6:	83 e8 57             	sub    $0x57,%eax
  800dc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dcc:	eb 23                	jmp    800df1 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	0f b6 00             	movzbl (%eax),%eax
  800dd4:	3c 40                	cmp    $0x40,%al
  800dd6:	7e 3d                	jle    800e15 <strtol+0x13e>
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	0f b6 00             	movzbl (%eax),%eax
  800dde:	3c 5a                	cmp    $0x5a,%al
  800de0:	7f 33                	jg     800e15 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	0f b6 00             	movzbl (%eax),%eax
  800de8:	0f be c0             	movsbl %al,%eax
  800deb:	83 e8 37             	sub    $0x37,%eax
  800dee:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800df7:	7c 02                	jl     800dfb <strtol+0x124>
			break;
  800df9:	eb 1a                	jmp    800e15 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dfb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e02:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0b:	01 d0                	add    %edx,%eax
  800e0d:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e10:	e9 6f ff ff ff       	jmp    800d84 <strtol+0xad>

	if (endptr)
  800e15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e19:	74 08                	je     800e23 <strtol+0x14c>
		*endptr = (char *) s;
  800e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e23:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e27:	74 07                	je     800e30 <strtol+0x159>
  800e29:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e2c:	f7 d8                	neg    %eax
  800e2e:	eb 03                	jmp    800e33 <strtol+0x15c>
  800e30:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	8b 55 10             	mov    0x10(%ebp),%edx
  800e44:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e47:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e4a:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e4d:	8b 75 20             	mov    0x20(%ebp),%esi
  800e50:	cd 30                	int    $0x30
  800e52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e59:	74 30                	je     800e8b <syscall+0x56>
  800e5b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e5f:	7e 2a                	jle    800e8b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e6f:	c7 44 24 08 24 1e 80 	movl   $0x801e24,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7e:	00 
  800e7f:	c7 04 24 41 1e 80 00 	movl   $0x801e41,(%esp)
  800e86:	e8 8f 09 00 00       	call   80181a <_panic>

	return ret;
  800e8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e8e:	83 c4 3c             	add    $0x3c,%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eae:	00 
  800eaf:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eb6:	00 
  800eb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ebe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed1:	e8 5f ff ff ff       	call   800e35 <syscall>
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ede:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eed:	00 
  800eee:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800efd:	00 
  800efe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f05:	00 
  800f06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f0d:	00 
  800f0e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f15:	e8 1b ff ff ff       	call   800e35 <syscall>
}
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f34:	00 
  800f35:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f44:	00 
  800f45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f49:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f58:	e8 d8 fe ff ff       	call   800e35 <syscall>
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f65:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f74:	00 
  800f75:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f9c:	e8 94 fe ff ff       	call   800e35 <syscall>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <sys_yield>:

void
sys_yield(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fa9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc8:	00 
  800fc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd8:	00 
  800fd9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fe0:	e8 50 fe ff ff       	call   800e35 <syscall>
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801005:	00 
  801006:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80100a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80100e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801012:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801019:	00 
  80101a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801021:	e8 0f fe ff ff       	call   800e35 <syscall>
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801030:	8b 75 18             	mov    0x18(%ebp),%esi
  801033:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801036:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801039:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103c:	8b 45 08             	mov    0x8(%ebp),%eax
  80103f:	89 74 24 18          	mov    %esi,0x18(%esp)
  801043:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801047:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80104b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80104f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801053:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80105a:	00 
  80105b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801062:	e8 ce fd ff ff       	call   800e35 <syscall>
}
  801067:	83 c4 20             	add    $0x20,%esp
  80106a:	5b                   	pop    %ebx
  80106b:	5e                   	pop    %esi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801074:	8b 55 0c             	mov    0xc(%ebp),%edx
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801081:	00 
  801082:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801089:	00 
  80108a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801091:	00 
  801092:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801096:	89 44 24 08          	mov    %eax,0x8(%esp)
  80109a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a1:	00 
  8010a2:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010a9:	e8 87 fd ff ff       	call   800e35 <syscall>
}
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010c3:	00 
  8010c4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010cb:	00 
  8010cc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010d3:	00 
  8010d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010dc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010e3:	00 
  8010e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010eb:	e8 45 fd ff ff       	call   800e35 <syscall>
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801105:	00 
  801106:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80110d:	00 
  80110e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801115:	00 
  801116:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80111a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801125:	00 
  801126:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80112d:	e8 03 fd ff ff       	call   800e35 <syscall>
}
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80113a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80113d:	8b 55 10             	mov    0x10(%ebp),%edx
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80114a:	00 
  80114b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80114f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801153:	8b 55 0c             	mov    0xc(%ebp),%edx
  801156:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80115a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80116d:	e8 c3 fc ff ff       	call   800e35 <syscall>
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80117a:	8b 45 08             	mov    0x8(%ebp),%eax
  80117d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801184:	00 
  801185:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80118c:	00 
  80118d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801194:	00 
  801195:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80119c:	00 
  80119d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011a8:	00 
  8011a9:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011b0:	e8 80 fc ff ff       	call   800e35 <syscall>
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <sys_exec>:

void sys_exec(char* buf){
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011df:	00 
  8011e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011eb:	00 
  8011ec:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8011f3:	e8 3d fc ff ff       	call   800e35 <syscall>
}
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	8b 00                	mov    (%eax),%eax
  801205:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801208:	8b 45 08             	mov    0x8(%ebp),%eax
  80120b:	8b 40 04             	mov    0x4(%eax),%eax
  80120e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801214:	83 e0 02             	and    $0x2,%eax
  801217:	85 c0                	test   %eax,%eax
  801219:	75 23                	jne    80123e <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801222:	c7 44 24 08 50 1e 80 	movl   $0x801e50,0x8(%esp)
  801229:	00 
  80122a:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801239:	e8 dc 05 00 00       	call   80181a <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  80123e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801241:	c1 e8 0c             	shr    $0xc,%eax
  801244:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  801247:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80124a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801251:	25 00 08 00 00       	and    $0x800,%eax
  801256:	85 c0                	test   %eax,%eax
  801258:	75 1c                	jne    801276 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  80125a:	c7 44 24 08 8c 1e 80 	movl   $0x801e8c,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801271:	e8 a4 05 00 00       	call   80181a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  801276:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128d:	e8 55 fd ff ff       	call   800fe7 <sys_page_alloc>
  801292:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801295:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801299:	79 23                	jns    8012be <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  80129b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80129e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a2:	c7 44 24 08 c8 1e 80 	movl   $0x801ec8,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  8012b9:	e8 5c 05 00 00       	call   80181a <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8012be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012cc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012d3:	00 
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8012df:	e8 47 f9 ff ff       	call   800c2b <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  8012e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f2:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012f9:	00 
  8012fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801305:	00 
  801306:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80130d:	00 
  80130e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801315:	e8 0e fd ff ff       	call   801028 <sys_page_map>
  80131a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80131d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801321:	79 23                	jns    801346 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801323:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801326:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132a:	c7 44 24 08 00 1f 80 	movl   $0x801f00,0x8(%esp)
  801331:	00 
  801332:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  801339:	00 
  80133a:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801341:	e8 d4 04 00 00       	call   80181a <_panic>
	}

	// panic("pgfault not implemented");
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
  80134d:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801350:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  801357:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801361:	25 00 08 00 00       	and    $0x800,%eax
  801366:	85 c0                	test   %eax,%eax
  801368:	75 15                	jne    80137f <duppage+0x37>
  80136a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801374:	83 e0 02             	and    $0x2,%eax
  801377:	85 c0                	test   %eax,%eax
  801379:	0f 84 e0 00 00 00    	je     80145f <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  80137f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801382:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801389:	83 e0 04             	and    $0x4,%eax
  80138c:	85 c0                	test   %eax,%eax
  80138e:	74 04                	je     801394 <duppage+0x4c>
  801390:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  801394:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801397:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139a:	c1 e0 0c             	shl    $0xc,%eax
  80139d:	89 c1                	mov    %eax,%ecx
  80139f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a2:	c1 e0 0c             	shl    $0xc,%eax
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	a1 04 30 80 00       	mov    0x803004,%eax
  8013ac:	8b 40 48             	mov    0x48(%eax),%eax
  8013af:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	e8 5e fc ff ff       	call   801028 <sys_page_map>
  8013ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8013cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013d1:	79 23                	jns    8013f6 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013da:	c7 44 24 08 34 1f 80 	movl   $0x801f34,0x8(%esp)
  8013e1:	00 
  8013e2:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8013e9:	00 
  8013ea:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  8013f1:	e8 24 04 00 00       	call   80181a <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8013f6:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fc:	c1 e0 0c             	shl    $0xc,%eax
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	a1 04 30 80 00       	mov    0x803004,%eax
  801406:	8b 48 48             	mov    0x48(%eax),%ecx
  801409:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140c:	c1 e0 0c             	shl    $0xc,%eax
  80140f:	89 c2                	mov    %eax,%edx
  801411:	a1 04 30 80 00       	mov    0x803004,%eax
  801416:	8b 40 48             	mov    0x48(%eax),%eax
  801419:	89 74 24 10          	mov    %esi,0x10(%esp)
  80141d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801421:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801425:	89 54 24 04          	mov    %edx,0x4(%esp)
  801429:	89 04 24             	mov    %eax,(%esp)
  80142c:	e8 f7 fb ff ff       	call   801028 <sys_page_map>
  801431:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801434:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801438:	79 23                	jns    80145d <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801441:	c7 44 24 08 70 1f 80 	movl   $0x801f70,0x8(%esp)
  801448:	00 
  801449:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801450:	00 
  801451:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801458:	e8 bd 03 00 00       	call   80181a <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80145d:	eb 70                	jmp    8014cf <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  80145f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801469:	25 ff 0f 00 00       	and    $0xfff,%eax
  80146e:	89 c3                	mov    %eax,%ebx
  801470:	8b 45 0c             	mov    0xc(%ebp),%eax
  801473:	c1 e0 0c             	shl    $0xc,%eax
  801476:	89 c1                	mov    %eax,%ecx
  801478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147b:	c1 e0 0c             	shl    $0xc,%eax
  80147e:	89 c2                	mov    %eax,%edx
  801480:	a1 04 30 80 00       	mov    0x803004,%eax
  801485:	8b 40 48             	mov    0x48(%eax),%eax
  801488:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80148c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801493:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801497:	89 54 24 04          	mov    %edx,0x4(%esp)
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 85 fb ff ff       	call   801028 <sys_page_map>
  8014a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014aa:	79 23                	jns    8014cf <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b3:	c7 44 24 08 a0 1f 80 	movl   $0x801fa0,0x8(%esp)
  8014ba:	00 
  8014bb:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8014c2:	00 
  8014c3:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  8014ca:	e8 4b 03 00 00       	call   80181a <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  8014cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d4:	83 c4 30             	add    $0x30,%esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5e                   	pop    %esi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014e1:	c7 04 24 fa 11 80 00 	movl   $0x8011fa,(%esp)
  8014e8:	e8 88 03 00 00       	call   801875 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014ed:	b8 07 00 00 00       	mov    $0x7,%eax
  8014f2:	cd 30                	int    $0x30
  8014f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8014f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8014fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8014fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801501:	79 23                	jns    801526 <fork+0x4b>
  801503:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801506:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150a:	c7 44 24 08 d8 1f 80 	movl   $0x801fd8,0x8(%esp)
  801511:	00 
  801512:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  801519:	00 
  80151a:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801521:	e8 f4 02 00 00       	call   80181a <_panic>
	else if(childeid == 0){
  801526:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80152a:	75 29                	jne    801555 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80152c:	e8 2e fa ff ff       	call   800f5f <sys_getenvid>
  801531:	25 ff 03 00 00       	and    $0x3ff,%eax
  801536:	c1 e0 02             	shl    $0x2,%eax
  801539:	89 c2                	mov    %eax,%edx
  80153b:	c1 e2 05             	shl    $0x5,%edx
  80153e:	29 c2                	sub    %eax,%edx
  801540:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  801546:	a3 04 30 80 00       	mov    %eax,0x803004
		// set_pgfault_handler(pgfault);
		return 0;
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
  801550:	e9 16 01 00 00       	jmp    80166b <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801555:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80155c:	eb 3b                	jmp    801599 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	c1 f8 0a             	sar    $0xa,%eax
  801564:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156b:	83 e0 01             	and    $0x1,%eax
  80156e:	85 c0                	test   %eax,%eax
  801570:	74 23                	je     801595 <fork+0xba>
  801572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801575:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157c:	83 e0 01             	and    $0x1,%eax
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 12                	je     801595 <fork+0xba>
			duppage(childeid, i);
  801583:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 b3 fd ff ff       	call   801348 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801595:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  8015a1:	76 bb                	jbe    80155e <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  8015a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015aa:	00 
  8015ab:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015b2:	ee 
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	89 04 24             	mov    %eax,(%esp)
  8015b9:	e8 29 fa ff ff       	call   800fe7 <sys_page_alloc>
  8015be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015c5:	79 23                	jns    8015ea <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8015c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ce:	c7 44 24 08 00 20 80 	movl   $0x802000,0x8(%esp)
  8015d5:	00 
  8015d6:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8015dd:	00 
  8015de:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  8015e5:	e8 30 02 00 00       	call   80181a <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  8015ea:	c7 44 24 04 eb 18 80 	movl   $0x8018eb,0x4(%esp)
  8015f1:	00 
  8015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f5:	89 04 24             	mov    %eax,(%esp)
  8015f8:	e8 f5 fa ff ff       	call   8010f2 <sys_env_set_pgfault_upcall>
  8015fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801600:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801604:	79 23                	jns    801629 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  801606:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801609:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160d:	c7 44 24 08 28 20 80 	movl   $0x802028,0x8(%esp)
  801614:	00 
  801615:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80161c:	00 
  80161d:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801624:	e8 f1 01 00 00       	call   80181a <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  801629:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801630:	00 
  801631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	e8 74 fa ff ff       	call   8010b0 <sys_env_set_status>
  80163c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80163f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801643:	79 23                	jns    801668 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  801645:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801648:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80164c:	c7 44 24 08 5c 20 80 	movl   $0x80205c,0x8(%esp)
  801653:	00 
  801654:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80165b:	00 
  80165c:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  801663:	e8 b2 01 00 00       	call   80181a <_panic>
	}
	return childeid;
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <sfork>:

// Challenge!
int
sfork(void)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801673:	c7 44 24 08 85 20 80 	movl   $0x802085,0x8(%esp)
  80167a:	00 
  80167b:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801682:	00 
  801683:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  80168a:	e8 8b 01 00 00       	call   80181a <_panic>

0080168f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  801695:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801699:	75 09                	jne    8016a4 <ipc_recv+0x15>
		i_dstva = UTOP;
  80169b:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  8016a2:	eb 06                	jmp    8016aa <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  8016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  8016aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ad:	89 04 24             	mov    %eax,(%esp)
  8016b0:	e8 bf fa ff ff       	call   801174 <sys_ipc_recv>
  8016b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  8016b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8016bc:	75 15                	jne    8016d3 <ipc_recv+0x44>
  8016be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8016c2:	74 0f                	je     8016d3 <ipc_recv+0x44>
  8016c4:	a1 04 30 80 00       	mov    0x803004,%eax
  8016c9:	8b 50 74             	mov    0x74(%eax),%edx
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	89 10                	mov    %edx,(%eax)
  8016d1:	eb 15                	jmp    8016e8 <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  8016d3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8016d7:	79 0f                	jns    8016e8 <ipc_recv+0x59>
  8016d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8016dd:	74 09                	je     8016e8 <ipc_recv+0x59>
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  8016e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8016ec:	75 15                	jne    801703 <ipc_recv+0x74>
  8016ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016f2:	74 0f                	je     801703 <ipc_recv+0x74>
  8016f4:	a1 04 30 80 00       	mov    0x803004,%eax
  8016f9:	8b 50 78             	mov    0x78(%eax),%edx
  8016fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ff:	89 10                	mov    %edx,(%eax)
  801701:	eb 15                	jmp    801718 <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  801703:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801707:	79 0f                	jns    801718 <ipc_recv+0x89>
  801709:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80170d:	74 09                	je     801718 <ipc_recv+0x89>
  80170f:	8b 45 10             	mov    0x10(%ebp),%eax
  801712:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  801718:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80171c:	75 0a                	jne    801728 <ipc_recv+0x99>
  80171e:	a1 04 30 80 00       	mov    0x803004,%eax
  801723:	8b 40 70             	mov    0x70(%eax),%eax
  801726:	eb 03                	jmp    80172b <ipc_recv+0x9c>
	else return r;
  801728:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  801733:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  80173a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80173e:	74 06                	je     801746 <ipc_send+0x19>
  801740:	8b 45 10             	mov    0x10(%ebp),%eax
  801743:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801749:	8b 55 14             	mov    0x14(%ebp),%edx
  80174c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801750:	89 44 24 08          	mov    %eax,0x8(%esp)
  801754:	8b 45 0c             	mov    0xc(%ebp),%eax
  801757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	89 04 24             	mov    %eax,(%esp)
  801761:	e8 ce f9 ff ff       	call   801134 <sys_ipc_try_send>
  801766:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  801769:	eb 28                	jmp    801793 <ipc_send+0x66>
		sys_yield();
  80176b:	e8 33 f8 ff ff       	call   800fa3 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801773:	8b 55 14             	mov    0x14(%ebp),%edx
  801776:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80177a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801781:	89 44 24 04          	mov    %eax,0x4(%esp)
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	e8 a4 f9 ff ff       	call   801134 <sys_ipc_try_send>
  801790:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  801793:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  801797:	74 d2                	je     80176b <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  801799:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80179d:	75 02                	jne    8017a1 <ipc_send+0x74>
  80179f:	eb 23                	jmp    8017c4 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a8:	c7 44 24 08 9c 20 80 	movl   $0x80209c,0x8(%esp)
  8017af:	00 
  8017b0:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8017b7:	00 
  8017b8:	c7 04 24 c1 20 80 00 	movl   $0x8020c1,(%esp)
  8017bf:	e8 56 00 00 00       	call   80181a <_panic>
	panic("ipc_send not implemented");
}
  8017c4:	c9                   	leave  
  8017c5:	c3                   	ret    

008017c6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017c6:	55                   	push   %ebp
  8017c7:	89 e5                	mov    %esp,%ebp
  8017c9:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  8017cc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8017d3:	eb 35                	jmp    80180a <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8017d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017d8:	c1 e0 02             	shl    $0x2,%eax
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	c1 e2 05             	shl    $0x5,%edx
  8017e0:	29 c2                	sub    %eax,%edx
  8017e2:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8017e8:	8b 00                	mov    (%eax),%eax
  8017ea:	3b 45 08             	cmp    0x8(%ebp),%eax
  8017ed:	75 17                	jne    801806 <ipc_find_env+0x40>
			return envs[i].env_id;
  8017ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017f2:	c1 e0 02             	shl    $0x2,%eax
  8017f5:	89 c2                	mov    %eax,%edx
  8017f7:	c1 e2 05             	shl    $0x5,%edx
  8017fa:	29 c2                	sub    %eax,%edx
  8017fc:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  801802:	8b 00                	mov    (%eax),%eax
  801804:	eb 12                	jmp    801818 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801806:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80180a:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  801811:	7e c2                	jle    8017d5 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801813:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801821:	8d 45 14             	lea    0x14(%ebp),%eax
  801824:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801827:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80182d:	e8 2d f7 ff ff       	call   800f5f <sys_getenvid>
  801832:	8b 55 0c             	mov    0xc(%ebp),%edx
  801835:	89 54 24 10          	mov    %edx,0x10(%esp)
  801839:	8b 55 08             	mov    0x8(%ebp),%edx
  80183c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801840:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801844:	89 44 24 04          	mov    %eax,0x4(%esp)
  801848:	c7 04 24 cc 20 80 00 	movl   $0x8020cc,(%esp)
  80184f:	e8 d6 e9 ff ff       	call   80022a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185b:	8b 45 10             	mov    0x10(%ebp),%eax
  80185e:	89 04 24             	mov    %eax,(%esp)
  801861:	e8 60 e9 ff ff       	call   8001c6 <vcprintf>
	cprintf("\n");
  801866:	c7 04 24 ef 20 80 00 	movl   $0x8020ef,(%esp)
  80186d:	e8 b8 e9 ff ff       	call   80022a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801872:	cc                   	int3   
  801873:	eb fd                	jmp    801872 <_panic+0x58>

00801875 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80187b:	a1 08 30 80 00       	mov    0x803008,%eax
  801880:	85 c0                	test   %eax,%eax
  801882:	75 5d                	jne    8018e1 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801884:	a1 04 30 80 00       	mov    0x803004,%eax
  801889:	8b 40 48             	mov    0x48(%eax),%eax
  80188c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801893:	00 
  801894:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80189b:	ee 
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 43 f7 ff ff       	call   800fe7 <sys_page_alloc>
  8018a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8018a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018ab:	79 1c                	jns    8018c9 <set_pgfault_handler+0x54>
  8018ad:	c7 44 24 08 f4 20 80 	movl   $0x8020f4,0x8(%esp)
  8018b4:	00 
  8018b5:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8018bc:	00 
  8018bd:	c7 04 24 20 21 80 00 	movl   $0x802120,(%esp)
  8018c4:	e8 51 ff ff ff       	call   80181a <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8018c9:	a1 04 30 80 00       	mov    0x803004,%eax
  8018ce:	8b 40 48             	mov    0x48(%eax),%eax
  8018d1:	c7 44 24 04 eb 18 80 	movl   $0x8018eb,0x4(%esp)
  8018d8:	00 
  8018d9:	89 04 24             	mov    %eax,(%esp)
  8018dc:	e8 11 f8 ff ff       	call   8010f2 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8018e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e4:	a3 08 30 80 00       	mov    %eax,0x803008
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8018eb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8018ec:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  8018f1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8018f3:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8018f6:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8018fa:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8018fc:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801900:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801901:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801904:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801906:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801907:	58                   	pop    %eax
	popal 						// pop all the registers
  801908:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801909:	83 c4 04             	add    $0x4,%esp
	popfl
  80190c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80190d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80190e:	c3                   	ret    
  80190f:	90                   	nop

00801910 <__udivdi3>:
  801910:	55                   	push   %ebp
  801911:	57                   	push   %edi
  801912:	56                   	push   %esi
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	8b 44 24 28          	mov    0x28(%esp),%eax
  80191a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80191e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801922:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801926:	85 c0                	test   %eax,%eax
  801928:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80192c:	89 ea                	mov    %ebp,%edx
  80192e:	89 0c 24             	mov    %ecx,(%esp)
  801931:	75 2d                	jne    801960 <__udivdi3+0x50>
  801933:	39 e9                	cmp    %ebp,%ecx
  801935:	77 61                	ja     801998 <__udivdi3+0x88>
  801937:	85 c9                	test   %ecx,%ecx
  801939:	89 ce                	mov    %ecx,%esi
  80193b:	75 0b                	jne    801948 <__udivdi3+0x38>
  80193d:	b8 01 00 00 00       	mov    $0x1,%eax
  801942:	31 d2                	xor    %edx,%edx
  801944:	f7 f1                	div    %ecx
  801946:	89 c6                	mov    %eax,%esi
  801948:	31 d2                	xor    %edx,%edx
  80194a:	89 e8                	mov    %ebp,%eax
  80194c:	f7 f6                	div    %esi
  80194e:	89 c5                	mov    %eax,%ebp
  801950:	89 f8                	mov    %edi,%eax
  801952:	f7 f6                	div    %esi
  801954:	89 ea                	mov    %ebp,%edx
  801956:	83 c4 0c             	add    $0xc,%esp
  801959:	5e                   	pop    %esi
  80195a:	5f                   	pop    %edi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    
  80195d:	8d 76 00             	lea    0x0(%esi),%esi
  801960:	39 e8                	cmp    %ebp,%eax
  801962:	77 24                	ja     801988 <__udivdi3+0x78>
  801964:	0f bd e8             	bsr    %eax,%ebp
  801967:	83 f5 1f             	xor    $0x1f,%ebp
  80196a:	75 3c                	jne    8019a8 <__udivdi3+0x98>
  80196c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801970:	39 34 24             	cmp    %esi,(%esp)
  801973:	0f 86 9f 00 00 00    	jbe    801a18 <__udivdi3+0x108>
  801979:	39 d0                	cmp    %edx,%eax
  80197b:	0f 82 97 00 00 00    	jb     801a18 <__udivdi3+0x108>
  801981:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801988:	31 d2                	xor    %edx,%edx
  80198a:	31 c0                	xor    %eax,%eax
  80198c:	83 c4 0c             	add    $0xc,%esp
  80198f:	5e                   	pop    %esi
  801990:	5f                   	pop    %edi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    
  801993:	90                   	nop
  801994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801998:	89 f8                	mov    %edi,%eax
  80199a:	f7 f1                	div    %ecx
  80199c:	31 d2                	xor    %edx,%edx
  80199e:	83 c4 0c             	add    $0xc,%esp
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    
  8019a5:	8d 76 00             	lea    0x0(%esi),%esi
  8019a8:	89 e9                	mov    %ebp,%ecx
  8019aa:	8b 3c 24             	mov    (%esp),%edi
  8019ad:	d3 e0                	shl    %cl,%eax
  8019af:	89 c6                	mov    %eax,%esi
  8019b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8019b6:	29 e8                	sub    %ebp,%eax
  8019b8:	89 c1                	mov    %eax,%ecx
  8019ba:	d3 ef                	shr    %cl,%edi
  8019bc:	89 e9                	mov    %ebp,%ecx
  8019be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019c2:	8b 3c 24             	mov    (%esp),%edi
  8019c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8019c9:	89 d6                	mov    %edx,%esi
  8019cb:	d3 e7                	shl    %cl,%edi
  8019cd:	89 c1                	mov    %eax,%ecx
  8019cf:	89 3c 24             	mov    %edi,(%esp)
  8019d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019d6:	d3 ee                	shr    %cl,%esi
  8019d8:	89 e9                	mov    %ebp,%ecx
  8019da:	d3 e2                	shl    %cl,%edx
  8019dc:	89 c1                	mov    %eax,%ecx
  8019de:	d3 ef                	shr    %cl,%edi
  8019e0:	09 d7                	or     %edx,%edi
  8019e2:	89 f2                	mov    %esi,%edx
  8019e4:	89 f8                	mov    %edi,%eax
  8019e6:	f7 74 24 08          	divl   0x8(%esp)
  8019ea:	89 d6                	mov    %edx,%esi
  8019ec:	89 c7                	mov    %eax,%edi
  8019ee:	f7 24 24             	mull   (%esp)
  8019f1:	39 d6                	cmp    %edx,%esi
  8019f3:	89 14 24             	mov    %edx,(%esp)
  8019f6:	72 30                	jb     801a28 <__udivdi3+0x118>
  8019f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8019fc:	89 e9                	mov    %ebp,%ecx
  8019fe:	d3 e2                	shl    %cl,%edx
  801a00:	39 c2                	cmp    %eax,%edx
  801a02:	73 05                	jae    801a09 <__udivdi3+0xf9>
  801a04:	3b 34 24             	cmp    (%esp),%esi
  801a07:	74 1f                	je     801a28 <__udivdi3+0x118>
  801a09:	89 f8                	mov    %edi,%eax
  801a0b:	31 d2                	xor    %edx,%edx
  801a0d:	e9 7a ff ff ff       	jmp    80198c <__udivdi3+0x7c>
  801a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a18:	31 d2                	xor    %edx,%edx
  801a1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1f:	e9 68 ff ff ff       	jmp    80198c <__udivdi3+0x7c>
  801a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a28:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a2b:	31 d2                	xor    %edx,%edx
  801a2d:	83 c4 0c             	add    $0xc,%esp
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    
  801a34:	66 90                	xchg   %ax,%ax
  801a36:	66 90                	xchg   %ax,%ax
  801a38:	66 90                	xchg   %ax,%ax
  801a3a:	66 90                	xchg   %ax,%ax
  801a3c:	66 90                	xchg   %ax,%ax
  801a3e:	66 90                	xchg   %ax,%ax

00801a40 <__umoddi3>:
  801a40:	55                   	push   %ebp
  801a41:	57                   	push   %edi
  801a42:	56                   	push   %esi
  801a43:	83 ec 14             	sub    $0x14,%esp
  801a46:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a4a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a4e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801a52:	89 c7                	mov    %eax,%edi
  801a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a58:	8b 44 24 30          	mov    0x30(%esp),%eax
  801a5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801a60:	89 34 24             	mov    %esi,(%esp)
  801a63:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a67:	85 c0                	test   %eax,%eax
  801a69:	89 c2                	mov    %eax,%edx
  801a6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a6f:	75 17                	jne    801a88 <__umoddi3+0x48>
  801a71:	39 fe                	cmp    %edi,%esi
  801a73:	76 4b                	jbe    801ac0 <__umoddi3+0x80>
  801a75:	89 c8                	mov    %ecx,%eax
  801a77:	89 fa                	mov    %edi,%edx
  801a79:	f7 f6                	div    %esi
  801a7b:	89 d0                	mov    %edx,%eax
  801a7d:	31 d2                	xor    %edx,%edx
  801a7f:	83 c4 14             	add    $0x14,%esp
  801a82:	5e                   	pop    %esi
  801a83:	5f                   	pop    %edi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    
  801a86:	66 90                	xchg   %ax,%ax
  801a88:	39 f8                	cmp    %edi,%eax
  801a8a:	77 54                	ja     801ae0 <__umoddi3+0xa0>
  801a8c:	0f bd e8             	bsr    %eax,%ebp
  801a8f:	83 f5 1f             	xor    $0x1f,%ebp
  801a92:	75 5c                	jne    801af0 <__umoddi3+0xb0>
  801a94:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a98:	39 3c 24             	cmp    %edi,(%esp)
  801a9b:	0f 87 e7 00 00 00    	ja     801b88 <__umoddi3+0x148>
  801aa1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801aa5:	29 f1                	sub    %esi,%ecx
  801aa7:	19 c7                	sbb    %eax,%edi
  801aa9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ab1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ab5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ab9:	83 c4 14             	add    $0x14,%esp
  801abc:	5e                   	pop    %esi
  801abd:	5f                   	pop    %edi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    
  801ac0:	85 f6                	test   %esi,%esi
  801ac2:	89 f5                	mov    %esi,%ebp
  801ac4:	75 0b                	jne    801ad1 <__umoddi3+0x91>
  801ac6:	b8 01 00 00 00       	mov    $0x1,%eax
  801acb:	31 d2                	xor    %edx,%edx
  801acd:	f7 f6                	div    %esi
  801acf:	89 c5                	mov    %eax,%ebp
  801ad1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ad5:	31 d2                	xor    %edx,%edx
  801ad7:	f7 f5                	div    %ebp
  801ad9:	89 c8                	mov    %ecx,%eax
  801adb:	f7 f5                	div    %ebp
  801add:	eb 9c                	jmp    801a7b <__umoddi3+0x3b>
  801adf:	90                   	nop
  801ae0:	89 c8                	mov    %ecx,%eax
  801ae2:	89 fa                	mov    %edi,%edx
  801ae4:	83 c4 14             	add    $0x14,%esp
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    
  801aeb:	90                   	nop
  801aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af0:	8b 04 24             	mov    (%esp),%eax
  801af3:	be 20 00 00 00       	mov    $0x20,%esi
  801af8:	89 e9                	mov    %ebp,%ecx
  801afa:	29 ee                	sub    %ebp,%esi
  801afc:	d3 e2                	shl    %cl,%edx
  801afe:	89 f1                	mov    %esi,%ecx
  801b00:	d3 e8                	shr    %cl,%eax
  801b02:	89 e9                	mov    %ebp,%ecx
  801b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b08:	8b 04 24             	mov    (%esp),%eax
  801b0b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b0f:	89 fa                	mov    %edi,%edx
  801b11:	d3 e0                	shl    %cl,%eax
  801b13:	89 f1                	mov    %esi,%ecx
  801b15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b1d:	d3 ea                	shr    %cl,%edx
  801b1f:	89 e9                	mov    %ebp,%ecx
  801b21:	d3 e7                	shl    %cl,%edi
  801b23:	89 f1                	mov    %esi,%ecx
  801b25:	d3 e8                	shr    %cl,%eax
  801b27:	89 e9                	mov    %ebp,%ecx
  801b29:	09 f8                	or     %edi,%eax
  801b2b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b2f:	f7 74 24 04          	divl   0x4(%esp)
  801b33:	d3 e7                	shl    %cl,%edi
  801b35:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b39:	89 d7                	mov    %edx,%edi
  801b3b:	f7 64 24 08          	mull   0x8(%esp)
  801b3f:	39 d7                	cmp    %edx,%edi
  801b41:	89 c1                	mov    %eax,%ecx
  801b43:	89 14 24             	mov    %edx,(%esp)
  801b46:	72 2c                	jb     801b74 <__umoddi3+0x134>
  801b48:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801b4c:	72 22                	jb     801b70 <__umoddi3+0x130>
  801b4e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b52:	29 c8                	sub    %ecx,%eax
  801b54:	19 d7                	sbb    %edx,%edi
  801b56:	89 e9                	mov    %ebp,%ecx
  801b58:	89 fa                	mov    %edi,%edx
  801b5a:	d3 e8                	shr    %cl,%eax
  801b5c:	89 f1                	mov    %esi,%ecx
  801b5e:	d3 e2                	shl    %cl,%edx
  801b60:	89 e9                	mov    %ebp,%ecx
  801b62:	d3 ef                	shr    %cl,%edi
  801b64:	09 d0                	or     %edx,%eax
  801b66:	89 fa                	mov    %edi,%edx
  801b68:	83 c4 14             	add    $0x14,%esp
  801b6b:	5e                   	pop    %esi
  801b6c:	5f                   	pop    %edi
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    
  801b6f:	90                   	nop
  801b70:	39 d7                	cmp    %edx,%edi
  801b72:	75 da                	jne    801b4e <__umoddi3+0x10e>
  801b74:	8b 14 24             	mov    (%esp),%edx
  801b77:	89 c1                	mov    %eax,%ecx
  801b79:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801b7d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801b81:	eb cb                	jmp    801b4e <__umoddi3+0x10e>
  801b83:	90                   	nop
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801b8c:	0f 82 0f ff ff ff    	jb     801aa1 <__umoddi3+0x61>
  801b92:	e9 1a ff ff ff       	jmp    801ab1 <__umoddi3+0x71>
