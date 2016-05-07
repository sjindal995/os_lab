
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
  80003a:	e8 d0 14 00 00       	call   80150f <fork>
  80003f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800042:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800045:	85 c0                	test   %eax,%eax
  800047:	74 3f                	je     800088 <umain+0x55>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800049:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80004c:	e8 fe 0e 00 00       	call   800f4f <sys_getenvid>
  800051:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 e0 1b 80 00 	movl   $0x801be0,(%esp)
  800060:	e8 b5 01 00 00       	call   80021a <cprintf>
		ipc_send(who, 0, 0, 0);
  800065:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800068:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006f:	00 
  800070:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800077:	00 
  800078:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007f:	00 
  800080:	89 04 24             	mov    %eax,(%esp)
  800083:	e8 d9 16 00 00       	call   801761 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800088:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800097:	00 
  800098:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80009b:	89 04 24             	mov    %eax,(%esp)
  80009e:	e8 20 16 00 00       	call   8016c3 <ipc_recv>
  8000a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a6:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8000a9:	e8 a1 0e 00 00       	call   800f4f <sys_getenvid>
  8000ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 f6 1b 80 00 	movl   $0x801bf6,(%esp)
  8000c4:	e8 51 01 00 00       	call   80021a <cprintf>
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
  8000f2:	e8 6a 16 00 00       	call   801761 <ipc_send>
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
  80010d:	e8 3d 0e 00 00       	call   800f4f <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	c1 e0 02             	shl    $0x2,%eax
  80011a:	89 c2                	mov    %eax,%edx
  80011c:	c1 e2 05             	shl    $0x5,%edx
  80011f:	29 c2                	sub    %eax,%edx
  800121:	89 d0                	mov    %edx,%eax
  800123:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800128:	a3 04 30 80 00       	mov    %eax,0x803004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  80012d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800130:	89 44 24 04          	mov    %eax,0x4(%esp)
  800134:	8b 45 08             	mov    0x8(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 f4 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013f:	e8 02 00 00 00       	call   800146 <exit>
}
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800153:	e8 b4 0d 00 00       	call   800f0c <sys_env_destroy>
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800160:	8b 45 0c             	mov    0xc(%ebp),%eax
  800163:	8b 00                	mov    (%eax),%eax
  800165:	8d 48 01             	lea    0x1(%eax),%ecx
  800168:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016b:	89 0a                	mov    %ecx,(%edx)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 d1                	mov    %edx,%ecx
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017c:	8b 00                	mov    (%eax),%eax
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	75 20                	jne    8001a5 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800185:	8b 45 0c             	mov    0xc(%ebp),%eax
  800188:	8b 00                	mov    (%eax),%eax
  80018a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018d:	83 c2 08             	add    $0x8,%edx
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	89 14 24             	mov    %edx,(%esp)
  800197:	e8 ea 0c 00 00       	call   800e86 <sys_cputs>
		b->idx = 0;
  80019c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a8:	8b 40 04             	mov    0x4(%eax),%eax
  8001ab:	8d 50 01             	lea    0x1(%eax),%edx
  8001ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b1:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c6:	00 00 00 
	b.cnt = 0;
  8001c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001eb:	c7 04 24 5a 01 80 00 	movl   $0x80015a,(%esp)
  8001f2:	e8 bd 01 00 00       	call   8003b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800201:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800207:	83 c0 08             	add    $0x8,%eax
  80020a:	89 04 24             	mov    %eax,(%esp)
  80020d:	e8 74 0c 00 00       	call   800e86 <sys_cputs>

	return b.cnt;
  800212:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800220:	8d 45 0c             	lea    0xc(%ebp),%eax
  800223:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800226:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	8b 45 08             	mov    0x8(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 7e ff ff ff       	call   8001b6 <vcprintf>
  800238:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80023b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	53                   	push   %ebx
  800244:	83 ec 34             	sub    $0x34,%esp
  800247:	8b 45 10             	mov    0x10(%ebp),%eax
  80024a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 45 18             	mov    0x18(%ebp),%eax
  800256:	ba 00 00 00 00       	mov    $0x0,%edx
  80025b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80025e:	77 72                	ja     8002d2 <printnum+0x92>
  800260:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800263:	72 05                	jb     80026a <printnum+0x2a>
  800265:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800268:	77 68                	ja     8002d2 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80026d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800270:	8b 45 18             	mov    0x18(%ebp),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800283:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800286:	89 04 24             	mov    %eax,(%esp)
  800289:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028d:	e8 be 16 00 00       	call   801950 <__udivdi3>
  800292:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800295:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800299:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80029d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002a0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	89 04 24             	mov    %eax,(%esp)
  8002b9:	e8 82 ff ff ff       	call   800240 <printnum>
  8002be:	eb 1c                	jmp    8002dc <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	8b 45 20             	mov    0x20(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d0:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002d6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002da:	7f e4                	jg     8002c0 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002dc:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	e8 82 17 00 00       	call   801a80 <__umoddi3>
  8002fe:	05 e8 1c 80 00       	add    $0x801ce8,%eax
  800303:	0f b6 00             	movzbl (%eax),%eax
  800306:	0f be c0             	movsbl %al,%eax
  800309:	8b 55 0c             	mov    0xc(%ebp),%edx
  80030c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	ff d0                	call   *%eax
}
  800318:	83 c4 34             	add    $0x34,%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800321:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800325:	7e 14                	jle    80033b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	8b 00                	mov    (%eax),%eax
  80032c:	8d 48 08             	lea    0x8(%eax),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 0a                	mov    %ecx,(%edx)
  800334:	8b 50 04             	mov    0x4(%eax),%edx
  800337:	8b 00                	mov    (%eax),%eax
  800339:	eb 30                	jmp    80036b <getuint+0x4d>
	else if (lflag)
  80033b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80033f:	74 16                	je     800357 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	8b 00                	mov    (%eax),%eax
  800346:	8d 48 04             	lea    0x4(%eax),%ecx
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 0a                	mov    %ecx,(%edx)
  80034e:	8b 00                	mov    (%eax),%eax
  800350:	ba 00 00 00 00       	mov    $0x0,%edx
  800355:	eb 14                	jmp    80036b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	8b 00                	mov    (%eax),%eax
  80035c:	8d 48 04             	lea    0x4(%eax),%ecx
  80035f:	8b 55 08             	mov    0x8(%ebp),%edx
  800362:	89 0a                	mov    %ecx,(%edx)
  800364:	8b 00                	mov    (%eax),%eax
  800366:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800370:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800374:	7e 14                	jle    80038a <getint+0x1d>
		return va_arg(*ap, long long);
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	8d 48 08             	lea    0x8(%eax),%ecx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	89 0a                	mov    %ecx,(%edx)
  800383:	8b 50 04             	mov    0x4(%eax),%edx
  800386:	8b 00                	mov    (%eax),%eax
  800388:	eb 28                	jmp    8003b2 <getint+0x45>
	else if (lflag)
  80038a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80038e:	74 12                	je     8003a2 <getint+0x35>
		return va_arg(*ap, long);
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	8d 48 04             	lea    0x4(%eax),%ecx
  800398:	8b 55 08             	mov    0x8(%ebp),%edx
  80039b:	89 0a                	mov    %ecx,(%edx)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	99                   	cltd   
  8003a0:	eb 10                	jmp    8003b2 <getint+0x45>
	else
		return va_arg(*ap, int);
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 0a                	mov    %ecx,(%edx)
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	99                   	cltd   
}
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	56                   	push   %esi
  8003b8:	53                   	push   %ebx
  8003b9:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bc:	eb 18                	jmp    8003d6 <vprintfmt+0x22>
			if (ch == '\0')
  8003be:	85 db                	test   %ebx,%ebx
  8003c0:	75 05                	jne    8003c7 <vprintfmt+0x13>
				return;
  8003c2:	e9 cc 03 00 00       	jmp    800793 <vprintfmt+0x3df>
			putch(ch, putdat);
  8003c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ce:	89 1c 24             	mov    %ebx,(%esp)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d9:	8d 50 01             	lea    0x1(%eax),%edx
  8003dc:	89 55 10             	mov    %edx,0x10(%ebp)
  8003df:	0f b6 00             	movzbl (%eax),%eax
  8003e2:	0f b6 d8             	movzbl %al,%ebx
  8003e5:	83 fb 25             	cmp    $0x25,%ebx
  8003e8:	75 d4                	jne    8003be <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003ea:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800403:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 45 10             	mov    0x10(%ebp),%eax
  80040d:	8d 50 01             	lea    0x1(%eax),%edx
  800410:	89 55 10             	mov    %edx,0x10(%ebp)
  800413:	0f b6 00             	movzbl (%eax),%eax
  800416:	0f b6 d8             	movzbl %al,%ebx
  800419:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80041c:	83 f8 55             	cmp    $0x55,%eax
  80041f:	0f 87 3d 03 00 00    	ja     800762 <vprintfmt+0x3ae>
  800425:	8b 04 85 0c 1d 80 00 	mov    0x801d0c(,%eax,4),%eax
  80042c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80042e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800432:	eb d6                	jmp    80040a <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800434:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800438:	eb d0                	jmp    80040a <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800441:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800444:	89 d0                	mov    %edx,%eax
  800446:	c1 e0 02             	shl    $0x2,%eax
  800449:	01 d0                	add    %edx,%eax
  80044b:	01 c0                	add    %eax,%eax
  80044d:	01 d8                	add    %ebx,%eax
  80044f:	83 e8 30             	sub    $0x30,%eax
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800455:	8b 45 10             	mov    0x10(%ebp),%eax
  800458:	0f b6 00             	movzbl (%eax),%eax
  80045b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80045e:	83 fb 2f             	cmp    $0x2f,%ebx
  800461:	7e 0b                	jle    80046e <vprintfmt+0xba>
  800463:	83 fb 39             	cmp    $0x39,%ebx
  800466:	7f 06                	jg     80046e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800468:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046c:	eb d3                	jmp    800441 <vprintfmt+0x8d>
			goto process_precision;
  80046e:	eb 33                	jmp    8004a3 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80047e:	eb 23                	jmp    8004a3 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800480:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800484:	79 0c                	jns    800492 <vprintfmt+0xde>
				width = 0;
  800486:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80048d:	e9 78 ff ff ff       	jmp    80040a <vprintfmt+0x56>
  800492:	e9 73 ff ff ff       	jmp    80040a <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800497:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80049e:	e9 67 ff ff ff       	jmp    80040a <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8004a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a7:	79 12                	jns    8004bb <vprintfmt+0x107>
				width = precision, precision = -1;
  8004a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8004b6:	e9 4f ff ff ff       	jmp    80040a <vprintfmt+0x56>
  8004bb:	e9 4a ff ff ff       	jmp    80040a <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c0:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8004c4:	e9 41 ff ff ff       	jmp    80040a <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	8b 00                	mov    (%eax),%eax
  8004d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004db:	89 04 24             	mov    %eax,(%esp)
  8004de:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e1:	ff d0                	call   *%eax
			break;
  8004e3:	e9 a5 02 00 00       	jmp    80078d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004f3:	85 db                	test   %ebx,%ebx
  8004f5:	79 02                	jns    8004f9 <vprintfmt+0x145>
				err = -err;
  8004f7:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f9:	83 fb 09             	cmp    $0x9,%ebx
  8004fc:	7f 0b                	jg     800509 <vprintfmt+0x155>
  8004fe:	8b 34 9d c0 1c 80 00 	mov    0x801cc0(,%ebx,4),%esi
  800505:	85 f6                	test   %esi,%esi
  800507:	75 23                	jne    80052c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800509:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80050d:	c7 44 24 08 f9 1c 80 	movl   $0x801cf9,0x8(%esp)
  800514:	00 
  800515:	8b 45 0c             	mov    0xc(%ebp),%eax
  800518:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051c:	8b 45 08             	mov    0x8(%ebp),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 73 02 00 00       	call   80079a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800527:	e9 61 02 00 00       	jmp    80078d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80052c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800530:	c7 44 24 08 02 1d 80 	movl   $0x801d02,0x8(%esp)
  800537:	00 
  800538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	8b 45 08             	mov    0x8(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 50 02 00 00       	call   80079a <printfmt>
			break;
  80054a:	e9 3e 02 00 00       	jmp    80078d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 30                	mov    (%eax),%esi
  80055a:	85 f6                	test   %esi,%esi
  80055c:	75 05                	jne    800563 <vprintfmt+0x1af>
				p = "(null)";
  80055e:	be 05 1d 80 00       	mov    $0x801d05,%esi
			if (width > 0 && padc != '-')
  800563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800567:	7e 37                	jle    8005a0 <vprintfmt+0x1ec>
  800569:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80056d:	74 31                	je     8005a0 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800572:	89 44 24 04          	mov    %eax,0x4(%esp)
  800576:	89 34 24             	mov    %esi,(%esp)
  800579:	e8 39 03 00 00       	call   8008b7 <strnlen>
  80057e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800581:	eb 17                	jmp    80059a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800583:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800587:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80058e:	89 04 24             	mov    %eax,(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800596:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80059a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059e:	7f e3                	jg     800583 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a0:	eb 38                	jmp    8005da <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a6:	74 1f                	je     8005c7 <vprintfmt+0x213>
  8005a8:	83 fb 1f             	cmp    $0x1f,%ebx
  8005ab:	7e 05                	jle    8005b2 <vprintfmt+0x1fe>
  8005ad:	83 fb 7e             	cmp    $0x7e,%ebx
  8005b0:	7e 15                	jle    8005c7 <vprintfmt+0x213>
					putch('?', putdat);
  8005b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c3:	ff d0                	call   *%eax
  8005c5:	eb 0f                	jmp    8005d6 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8005c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ce:	89 1c 24             	mov    %ebx,(%esp)
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005da:	89 f0                	mov    %esi,%eax
  8005dc:	8d 70 01             	lea    0x1(%eax),%esi
  8005df:	0f b6 00             	movzbl (%eax),%eax
  8005e2:	0f be d8             	movsbl %al,%ebx
  8005e5:	85 db                	test   %ebx,%ebx
  8005e7:	74 10                	je     8005f9 <vprintfmt+0x245>
  8005e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ed:	78 b3                	js     8005a2 <vprintfmt+0x1ee>
  8005ef:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f7:	79 a9                	jns    8005a2 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f9:	eb 17                	jmp    800612 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800602:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800609:	8b 45 08             	mov    0x8(%ebp),%eax
  80060c:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800612:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800616:	7f e3                	jg     8005fb <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800618:	e9 70 01 00 00       	jmp    80078d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800620:	89 44 24 04          	mov    %eax,0x4(%esp)
  800624:	8d 45 14             	lea    0x14(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 3e fd ff ff       	call   80036d <getint>
  80062f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800632:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800638:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80063b:	85 d2                	test   %edx,%edx
  80063d:	79 26                	jns    800665 <vprintfmt+0x2b1>
				putch('-', putdat);
  80063f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800642:	89 44 24 04          	mov    %eax,0x4(%esp)
  800646:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	ff d0                	call   *%eax
				num = -(long long) num;
  800652:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800655:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
  80065f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800662:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800665:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80066c:	e9 a8 00 00 00       	jmp    800719 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800671:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800674:	89 44 24 04          	mov    %eax,0x4(%esp)
  800678:	8d 45 14             	lea    0x14(%ebp),%eax
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 9b fc ff ff       	call   80031e <getuint>
  800683:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800686:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800689:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800690:	e9 84 00 00 00       	jmp    800719 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800695:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	8d 45 14             	lea    0x14(%ebp),%eax
  80069f:	89 04 24             	mov    %eax,(%esp)
  8006a2:	e8 77 fc ff ff       	call   80031e <getuint>
  8006a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8006ad:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8006b4:	eb 63                	jmp    800719 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	ff d0                	call   *%eax
			putch('x', putdat);
  8006c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006f1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006f8:	eb 1f                	jmp    800719 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800701:	8d 45 14             	lea    0x14(%ebp),%eax
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	e8 12 fc ff ff       	call   80031e <getuint>
  80070c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800712:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800719:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	89 54 24 18          	mov    %edx,0x18(%esp)
  800724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800727:	89 54 24 14          	mov    %edx,0x14(%esp)
  80072b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800732:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800735:	89 44 24 08          	mov    %eax,0x8(%esp)
  800739:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80073d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800740:	89 44 24 04          	mov    %eax,0x4(%esp)
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	e8 f1 fa ff ff       	call   800240 <printnum>
			break;
  80074f:	eb 3c                	jmp    80078d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800751:	8b 45 0c             	mov    0xc(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	89 1c 24             	mov    %ebx,(%esp)
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	ff d0                	call   *%eax
			break;
  800760:	eb 2b                	jmp    80078d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800775:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800779:	eb 04                	jmp    80077f <vprintfmt+0x3cb>
  80077b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80077f:	8b 45 10             	mov    0x10(%ebp),%eax
  800782:	83 e8 01             	sub    $0x1,%eax
  800785:	0f b6 00             	movzbl (%eax),%eax
  800788:	3c 25                	cmp    $0x25,%al
  80078a:	75 ef                	jne    80077b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80078c:	90                   	nop
		}
	}
  80078d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078e:	e9 43 fc ff ff       	jmp    8003d6 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800793:	83 c4 40             	add    $0x40,%esp
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	e8 ee fb ff ff       	call   8003b4 <vprintfmt>
	va_end(ap);
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ce:	8b 40 08             	mov    0x8(%eax),%eax
  8007d1:	8d 50 01             	lea    0x1(%eax),%edx
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d7:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dd:	8b 10                	mov    (%eax),%edx
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e2:	8b 40 04             	mov    0x4(%eax),%eax
  8007e5:	39 c2                	cmp    %eax,%edx
  8007e7:	73 12                	jae    8007fb <sprintputch+0x33>
		*b->buf++ = ch;
  8007e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	8d 48 01             	lea    0x1(%eax),%ecx
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	89 0a                	mov    %ecx,(%edx)
  8007f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f9:	88 10                	mov    %dl,(%eax)
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800809:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	01 d0                	add    %edx,%eax
  800814:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800822:	74 06                	je     80082a <vsnprintf+0x2d>
  800824:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800828:	7f 07                	jg     800831 <vsnprintf+0x34>
		return -E_INVAL;
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082f:	eb 2a                	jmp    80085b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800838:	8b 45 10             	mov    0x10(%ebp),%eax
  80083b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	89 44 24 04          	mov    %eax,0x4(%esp)
  800846:	c7 04 24 c8 07 80 00 	movl   $0x8007c8,(%esp)
  80084d:	e8 62 fb ff ff       	call   8003b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800852:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800855:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800858:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800870:	8b 45 10             	mov    0x10(%ebp),%eax
  800873:	89 44 24 08          	mov    %eax,0x8(%esp)
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	89 04 24             	mov    %eax,(%esp)
  800884:	e8 74 ff ff ff       	call   8007fd <vsnprintf>
  800889:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80088c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800897:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80089e:	eb 08                	jmp    8008a8 <strlen+0x17>
		n++;
  8008a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	84 c0                	test   %al,%al
  8008b0:	75 ee                	jne    8008a0 <strlen+0xf>
		n++;
	return n;
  8008b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008c4:	eb 0c                	jmp    8008d2 <strnlen+0x1b>
		n++;
  8008c6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008ce:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008d6:	74 0a                	je     8008e2 <strnlen+0x2b>
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	84 c0                	test   %al,%al
  8008e0:	75 e4                	jne    8008c6 <strnlen+0xf>
		n++;
	return n;
  8008e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008f3:	90                   	nop
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8d 50 01             	lea    0x1(%eax),%edx
  8008fa:	89 55 08             	mov    %edx,0x8(%ebp)
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800900:	8d 4a 01             	lea    0x1(%edx),%ecx
  800903:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800906:	0f b6 12             	movzbl (%edx),%edx
  800909:	88 10                	mov    %dl,(%eax)
  80090b:	0f b6 00             	movzbl (%eax),%eax
  80090e:	84 c0                	test   %al,%al
  800910:	75 e2                	jne    8008f4 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800912:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	89 04 24             	mov    %eax,(%esp)
  800923:	e8 69 ff ff ff       	call   800891 <strlen>
  800928:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80092b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	01 c2                	add    %eax,%edx
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	89 14 24             	mov    %edx,(%esp)
  80093d:	e8 a5 ff ff ff       	call   8008e7 <strcpy>
	return dst;
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800953:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80095a:	eb 23                	jmp    80097f <strncpy+0x38>
		*dst++ = *src;
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8d 50 01             	lea    0x1(%eax),%edx
  800962:	89 55 08             	mov    %edx,0x8(%ebp)
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
  800968:	0f b6 12             	movzbl (%edx),%edx
  80096b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80096d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800970:	0f b6 00             	movzbl (%eax),%eax
  800973:	84 c0                	test   %al,%al
  800975:	74 04                	je     80097b <strncpy+0x34>
			src++;
  800977:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80097f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800982:	3b 45 10             	cmp    0x10(%ebp),%eax
  800985:	72 d5                	jb     80095c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800987:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800998:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80099c:	74 33                	je     8009d1 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80099e:	eb 17                	jmp    8009b7 <strlcpy+0x2b>
			*dst++ = *src++;
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8d 50 01             	lea    0x1(%eax),%edx
  8009a6:	89 55 08             	mov    %edx,0x8(%ebp)
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009af:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009b2:	0f b6 12             	movzbl (%edx),%edx
  8009b5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009bf:	74 0a                	je     8009cb <strlcpy+0x3f>
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	0f b6 00             	movzbl (%eax),%eax
  8009c7:	84 c0                	test   %al,%al
  8009c9:	75 d5                	jne    8009a0 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009d7:	29 c2                	sub    %eax,%edx
  8009d9:	89 d0                	mov    %edx,%eax
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009e0:	eb 08                	jmp    8009ea <strcmp+0xd>
		p++, q++;
  8009e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 00             	movzbl (%eax),%eax
  8009f0:	84 c0                	test   %al,%al
  8009f2:	74 10                	je     800a04 <strcmp+0x27>
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	0f b6 10             	movzbl (%eax),%edx
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	0f b6 00             	movzbl (%eax),%eax
  800a00:	38 c2                	cmp    %al,%dl
  800a02:	74 de                	je     8009e2 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	0f b6 00             	movzbl (%eax),%eax
  800a0a:	0f b6 d0             	movzbl %al,%edx
  800a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a10:	0f b6 00             	movzbl (%eax),%eax
  800a13:	0f b6 c0             	movzbl %al,%eax
  800a16:	29 c2                	sub    %eax,%edx
  800a18:	89 d0                	mov    %edx,%eax
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a1f:	eb 0c                	jmp    800a2d <strncmp+0x11>
		n--, p++, q++;
  800a21:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a25:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a29:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a31:	74 1a                	je     800a4d <strncmp+0x31>
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	0f b6 00             	movzbl (%eax),%eax
  800a39:	84 c0                	test   %al,%al
  800a3b:	74 10                	je     800a4d <strncmp+0x31>
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	0f b6 10             	movzbl (%eax),%edx
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	0f b6 00             	movzbl (%eax),%eax
  800a49:	38 c2                	cmp    %al,%dl
  800a4b:	74 d4                	je     800a21 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a51:	75 07                	jne    800a5a <strncmp+0x3e>
		return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	eb 16                	jmp    800a70 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	0f b6 00             	movzbl (%eax),%eax
  800a60:	0f b6 d0             	movzbl %al,%edx
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	0f b6 00             	movzbl (%eax),%eax
  800a69:	0f b6 c0             	movzbl %al,%eax
  800a6c:	29 c2                	sub    %eax,%edx
  800a6e:	89 d0                	mov    %edx,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a7e:	eb 14                	jmp    800a94 <strchr+0x22>
		if (*s == c)
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	0f b6 00             	movzbl (%eax),%eax
  800a86:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a89:	75 05                	jne    800a90 <strchr+0x1e>
			return (char *) s;
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	eb 13                	jmp    800aa3 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a90:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	0f b6 00             	movzbl (%eax),%eax
  800a9a:	84 c0                	test   %al,%al
  800a9c:	75 e2                	jne    800a80 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 04             	sub    $0x4,%esp
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ab1:	eb 11                	jmp    800ac4 <strfind+0x1f>
		if (*s == c)
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800abc:	75 02                	jne    800ac0 <strfind+0x1b>
			break;
  800abe:	eb 0e                	jmp    800ace <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ac0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	0f b6 00             	movzbl (%eax),%eax
  800aca:	84 c0                	test   %al,%al
  800acc:	75 e5                	jne    800ab3 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ad7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800adb:	75 05                	jne    800ae2 <memset+0xf>
		return v;
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	eb 5c                	jmp    800b3e <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	83 e0 03             	and    $0x3,%eax
  800ae8:	85 c0                	test   %eax,%eax
  800aea:	75 41                	jne    800b2d <memset+0x5a>
  800aec:	8b 45 10             	mov    0x10(%ebp),%eax
  800aef:	83 e0 03             	and    $0x3,%eax
  800af2:	85 c0                	test   %eax,%eax
  800af4:	75 37                	jne    800b2d <memset+0x5a>
		c &= 0xFF;
  800af6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	c1 e0 18             	shl    $0x18,%eax
  800b03:	89 c2                	mov    %eax,%edx
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	c1 e0 10             	shl    $0x10,%eax
  800b0b:	09 c2                	or     %eax,%edx
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	c1 e0 08             	shl    $0x8,%eax
  800b13:	09 d0                	or     %edx,%eax
  800b15:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b18:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1b:	c1 e8 02             	shr    $0x2,%eax
  800b1e:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	fc                   	cld    
  800b29:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2b:	eb 0e                	jmp    800b3b <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	fc                   	cld    
  800b39:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b59:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b5c:	73 6d                	jae    800bcb <memmove+0x8a>
  800b5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b61:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b64:	01 d0                	add    %edx,%eax
  800b66:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b69:	76 60                	jbe    800bcb <memmove+0x8a>
		s += n;
  800b6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b71:	8b 45 10             	mov    0x10(%ebp),%eax
  800b74:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7a:	83 e0 03             	and    $0x3,%eax
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	75 2f                	jne    800bb0 <memmove+0x6f>
  800b81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b84:	83 e0 03             	and    $0x3,%eax
  800b87:	85 c0                	test   %eax,%eax
  800b89:	75 25                	jne    800bb0 <memmove+0x6f>
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8e:	83 e0 03             	and    $0x3,%eax
  800b91:	85 c0                	test   %eax,%eax
  800b93:	75 1b                	jne    800bb0 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b98:	83 e8 04             	sub    $0x4,%eax
  800b9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b9e:	83 ea 04             	sub    $0x4,%edx
  800ba1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	fd                   	std    
  800bac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bae:	eb 18                	jmp    800bc8 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb9:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbf:	89 d7                	mov    %edx,%edi
  800bc1:	89 de                	mov    %ebx,%esi
  800bc3:	89 c1                	mov    %eax,%ecx
  800bc5:	fd                   	std    
  800bc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc8:	fc                   	cld    
  800bc9:	eb 45                	jmp    800c10 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bce:	83 e0 03             	and    $0x3,%eax
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	75 2b                	jne    800c00 <memmove+0xbf>
  800bd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd8:	83 e0 03             	and    $0x3,%eax
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	75 21                	jne    800c00 <memmove+0xbf>
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	83 e0 03             	and    $0x3,%eax
  800be5:	85 c0                	test   %eax,%eax
  800be7:	75 17                	jne    800c00 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bec:	c1 e8 02             	shr    $0x2,%eax
  800bef:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	fc                   	cld    
  800bfc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfe:	eb 10                	jmp    800c10 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c06:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	fc                   	cld    
  800c0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c21:	8b 45 10             	mov    0x10(%ebp),%eax
  800c24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	89 04 24             	mov    %eax,(%esp)
  800c35:	e8 07 ff ff ff       	call   800b41 <memmove>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c42:	8b 45 08             	mov    0x8(%ebp),%eax
  800c45:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c4e:	eb 30                	jmp    800c80 <memcmp+0x44>
		if (*s1 != *s2)
  800c50:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c53:	0f b6 10             	movzbl (%eax),%edx
  800c56:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c59:	0f b6 00             	movzbl (%eax),%eax
  800c5c:	38 c2                	cmp    %al,%dl
  800c5e:	74 18                	je     800c78 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c60:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c63:	0f b6 00             	movzbl (%eax),%eax
  800c66:	0f b6 d0             	movzbl %al,%edx
  800c69:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c6c:	0f b6 00             	movzbl (%eax),%eax
  800c6f:	0f b6 c0             	movzbl %al,%eax
  800c72:	29 c2                	sub    %eax,%edx
  800c74:	89 d0                	mov    %edx,%eax
  800c76:	eb 1a                	jmp    800c92 <memcmp+0x56>
		s1++, s2++;
  800c78:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c7c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c80:	8b 45 10             	mov    0x10(%ebp),%eax
  800c83:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c86:	89 55 10             	mov    %edx,0x10(%ebp)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	75 c3                	jne    800c50 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c9a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	01 d0                	add    %edx,%eax
  800ca2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800ca5:	eb 13                	jmp    800cba <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	0f b6 10             	movzbl (%eax),%edx
  800cad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb0:	38 c2                	cmp    %al,%dl
  800cb2:	75 02                	jne    800cb6 <memfind+0x22>
			break;
  800cb4:	eb 0c                	jmp    800cc2 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cc0:	72 e5                	jb     800ca7 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cc5:	c9                   	leave  
  800cc6:	c3                   	ret    

00800cc7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ccd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cd4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdb:	eb 04                	jmp    800ce1 <strtol+0x1a>
		s++;
  800cdd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce4:	0f b6 00             	movzbl (%eax),%eax
  800ce7:	3c 20                	cmp    $0x20,%al
  800ce9:	74 f2                	je     800cdd <strtol+0x16>
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	0f b6 00             	movzbl (%eax),%eax
  800cf1:	3c 09                	cmp    $0x9,%al
  800cf3:	74 e8                	je     800cdd <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	0f b6 00             	movzbl (%eax),%eax
  800cfb:	3c 2b                	cmp    $0x2b,%al
  800cfd:	75 06                	jne    800d05 <strtol+0x3e>
		s++;
  800cff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d03:	eb 15                	jmp    800d1a <strtol+0x53>
	else if (*s == '-')
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	0f b6 00             	movzbl (%eax),%eax
  800d0b:	3c 2d                	cmp    $0x2d,%al
  800d0d:	75 0b                	jne    800d1a <strtol+0x53>
		s++, neg = 1;
  800d0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d13:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1e:	74 06                	je     800d26 <strtol+0x5f>
  800d20:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d24:	75 24                	jne    800d4a <strtol+0x83>
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	0f b6 00             	movzbl (%eax),%eax
  800d2c:	3c 30                	cmp    $0x30,%al
  800d2e:	75 1a                	jne    800d4a <strtol+0x83>
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	83 c0 01             	add    $0x1,%eax
  800d36:	0f b6 00             	movzbl (%eax),%eax
  800d39:	3c 78                	cmp    $0x78,%al
  800d3b:	75 0d                	jne    800d4a <strtol+0x83>
		s += 2, base = 16;
  800d3d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d41:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d48:	eb 2a                	jmp    800d74 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d4e:	75 17                	jne    800d67 <strtol+0xa0>
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	0f b6 00             	movzbl (%eax),%eax
  800d56:	3c 30                	cmp    $0x30,%al
  800d58:	75 0d                	jne    800d67 <strtol+0xa0>
		s++, base = 8;
  800d5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d65:	eb 0d                	jmp    800d74 <strtol+0xad>
	else if (base == 0)
  800d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d6b:	75 07                	jne    800d74 <strtol+0xad>
		base = 10;
  800d6d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	0f b6 00             	movzbl (%eax),%eax
  800d7a:	3c 2f                	cmp    $0x2f,%al
  800d7c:	7e 1b                	jle    800d99 <strtol+0xd2>
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	0f b6 00             	movzbl (%eax),%eax
  800d84:	3c 39                	cmp    $0x39,%al
  800d86:	7f 11                	jg     800d99 <strtol+0xd2>
			dig = *s - '0';
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	0f b6 00             	movzbl (%eax),%eax
  800d8e:	0f be c0             	movsbl %al,%eax
  800d91:	83 e8 30             	sub    $0x30,%eax
  800d94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d97:	eb 48                	jmp    800de1 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	0f b6 00             	movzbl (%eax),%eax
  800d9f:	3c 60                	cmp    $0x60,%al
  800da1:	7e 1b                	jle    800dbe <strtol+0xf7>
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	0f b6 00             	movzbl (%eax),%eax
  800da9:	3c 7a                	cmp    $0x7a,%al
  800dab:	7f 11                	jg     800dbe <strtol+0xf7>
			dig = *s - 'a' + 10;
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	0f b6 00             	movzbl (%eax),%eax
  800db3:	0f be c0             	movsbl %al,%eax
  800db6:	83 e8 57             	sub    $0x57,%eax
  800db9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dbc:	eb 23                	jmp    800de1 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	0f b6 00             	movzbl (%eax),%eax
  800dc4:	3c 40                	cmp    $0x40,%al
  800dc6:	7e 3d                	jle    800e05 <strtol+0x13e>
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	0f b6 00             	movzbl (%eax),%eax
  800dce:	3c 5a                	cmp    $0x5a,%al
  800dd0:	7f 33                	jg     800e05 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	0f b6 00             	movzbl (%eax),%eax
  800dd8:	0f be c0             	movsbl %al,%eax
  800ddb:	83 e8 37             	sub    $0x37,%eax
  800dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800de7:	7c 02                	jl     800deb <strtol+0x124>
			break;
  800de9:	eb 1a                	jmp    800e05 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800deb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800def:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800df2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfb:	01 d0                	add    %edx,%eax
  800dfd:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e00:	e9 6f ff ff ff       	jmp    800d74 <strtol+0xad>

	if (endptr)
  800e05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e09:	74 08                	je     800e13 <strtol+0x14c>
		*endptr = (char *) s;
  800e0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e13:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e17:	74 07                	je     800e20 <strtol+0x159>
  800e19:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e1c:	f7 d8                	neg    %eax
  800e1e:	eb 03                	jmp    800e23 <strtol+0x15c>
  800e20:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	8b 55 10             	mov    0x10(%ebp),%edx
  800e34:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e37:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e3a:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e3d:	8b 75 20             	mov    0x20(%ebp),%esi
  800e40:	cd 30                	int    $0x30
  800e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e49:	74 30                	je     800e7b <syscall+0x56>
  800e4b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e4f:	7e 2a                	jle    800e7b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5f:	c7 44 24 08 64 1e 80 	movl   $0x801e64,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6e:	00 
  800e6f:	c7 04 24 81 1e 80 00 	movl   $0x801e81,(%esp)
  800e76:	e8 d3 09 00 00       	call   80184e <_panic>

	return ret;
  800e7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e7e:	83 c4 3c             	add    $0x3c,%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e96:	00 
  800e97:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ea6:	00 
  800ea7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eaa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eae:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb9:	00 
  800eba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec1:	e8 5f ff ff ff       	call   800e25 <syscall>
}
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ece:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800edd:	00 
  800ede:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eed:	00 
  800eee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f05:	e8 1b ff ff ff       	call   800e25 <syscall>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f24:	00 
  800f25:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f34:	00 
  800f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f39:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f48:	e8 d8 fe ff ff       	call   800e25 <syscall>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f55:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f64:	00 
  800f65:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f74:	00 
  800f75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f8c:	e8 94 fe ff ff       	call   800e25 <syscall>
}
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <sys_yield>:

void
sys_yield(void)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f99:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa0:	00 
  800fa1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fd0:	e8 50 fe ff ff       	call   800e25 <syscall>
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fed:	00 
  800fee:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff5:	00 
  800ff6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ffa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801002:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801009:	00 
  80100a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801011:	e8 0f fe ff ff       	call   800e25 <syscall>
}
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801020:	8b 75 18             	mov    0x18(%ebp),%esi
  801023:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801026:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801029:	8b 55 0c             	mov    0xc(%ebp),%edx
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
  80102f:	89 74 24 18          	mov    %esi,0x18(%esp)
  801033:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801037:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80103b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80103f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801043:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80104a:	00 
  80104b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801052:	e8 ce fd ff ff       	call   800e25 <syscall>
}
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	5b                   	pop    %ebx
  80105b:	5e                   	pop    %esi
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801064:	8b 55 0c             	mov    0xc(%ebp),%edx
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801071:	00 
  801072:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801079:	00 
  80107a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801081:	00 
  801082:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801086:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801091:	00 
  801092:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801099:	e8 87 fd ff ff       	call   800e25 <syscall>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010b3:	00 
  8010b4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010c3:	00 
  8010c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d3:	00 
  8010d4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010db:	e8 45 fd ff ff       	call   800e25 <syscall>
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010fd:	00 
  8010fe:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801105:	00 
  801106:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80110a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801115:	00 
  801116:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80111d:	e8 03 fd ff ff       	call   800e25 <syscall>
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80112a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80112d:	8b 55 10             	mov    0x10(%ebp),%edx
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80113a:	00 
  80113b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80113f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80114a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801155:	00 
  801156:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80115d:	e8 c3 fc ff ff       	call   800e25 <syscall>
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801174:	00 
  801175:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80117c:	00 
  80117d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801184:	00 
  801185:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80118c:	00 
  80118d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801191:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011a0:	e8 80 fc ff ff       	call   800e25 <syscall>
}
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <sys_exec>:

void sys_exec(char* buf){
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011cf:	00 
  8011d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8011e3:	e8 3d fc ff ff       	call   800e25 <syscall>
}
  8011e8:	c9                   	leave  
  8011e9:	c3                   	ret    

008011ea <sys_wait>:

void sys_wait(){
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  8011f0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011f7:	00 
  8011f8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011ff:	00 
  801200:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801207:	00 
  801208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80120f:	00 
  801210:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801217:	00 
  801218:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80121f:	00 
  801220:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801227:	e8 f9 fb ff ff       	call   800e25 <syscall>
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	8b 00                	mov    (%eax),%eax
  801239:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	8b 40 04             	mov    0x4(%eax),%eax
  801242:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801245:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801248:	83 e0 02             	and    $0x2,%eax
  80124b:	85 c0                	test   %eax,%eax
  80124d:	75 23                	jne    801272 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801256:	c7 44 24 08 90 1e 80 	movl   $0x801e90,0x8(%esp)
  80125d:	00 
  80125e:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801265:	00 
  801266:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  80126d:	e8 dc 05 00 00       	call   80184e <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801275:	c1 e8 0c             	shr    $0xc,%eax
  801278:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  80127b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80127e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801285:	25 00 08 00 00       	and    $0x800,%eax
  80128a:	85 c0                	test   %eax,%eax
  80128c:	75 1c                	jne    8012aa <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  80128e:	c7 44 24 08 cc 1e 80 	movl   $0x801ecc,0x8(%esp)
  801295:	00 
  801296:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80129d:	00 
  80129e:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  8012a5:	e8 a4 05 00 00       	call   80184e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8012aa:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b1:	00 
  8012b2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b9:	00 
  8012ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c1:	e8 11 fd ff ff       	call   800fd7 <sys_page_alloc>
  8012c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012c9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012cd:	79 23                	jns    8012f2 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8012cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d6:	c7 44 24 08 08 1f 80 	movl   $0x801f08,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  8012ed:	e8 5c 05 00 00       	call   80184e <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8012f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801300:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801307:	00 
  801308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130c:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801313:	e8 03 f9 ff ff       	call   800c1b <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80131e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801326:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80132d:	00 
  80132e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801332:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801339:	00 
  80133a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801341:	00 
  801342:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801349:	e8 ca fc ff ff       	call   801018 <sys_page_map>
  80134e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801351:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801355:	79 23                	jns    80137a <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801357:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80135a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135e:	c7 44 24 08 40 1f 80 	movl   $0x801f40,0x8(%esp)
  801365:	00 
  801366:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80136d:	00 
  80136e:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  801375:	e8 d4 04 00 00       	call   80184e <_panic>
	}

	// panic("pgfault not implemented");
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801384:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  80138b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801395:	25 00 08 00 00       	and    $0x800,%eax
  80139a:	85 c0                	test   %eax,%eax
  80139c:	75 15                	jne    8013b3 <duppage+0x37>
  80139e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a8:	83 e0 02             	and    $0x2,%eax
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	0f 84 e0 00 00 00    	je     801493 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8013b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bd:	83 e0 04             	and    $0x4,%eax
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 04                	je     8013c8 <duppage+0x4c>
  8013c4:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8013c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ce:	c1 e0 0c             	shl    $0xc,%eax
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d6:	c1 e0 0c             	shl    $0xc,%eax
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	a1 04 30 80 00       	mov    0x803004,%eax
  8013e0:	8b 40 48             	mov    0x48(%eax),%eax
  8013e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013e7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 1a fc ff ff       	call   801018 <sys_page_map>
  8013fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801401:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801405:	79 23                	jns    80142a <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801407:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140e:	c7 44 24 08 74 1f 80 	movl   $0x801f74,0x8(%esp)
  801415:	00 
  801416:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80141d:	00 
  80141e:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  801425:	e8 24 04 00 00       	call   80184e <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80142a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80142d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801430:	c1 e0 0c             	shl    $0xc,%eax
  801433:	89 c3                	mov    %eax,%ebx
  801435:	a1 04 30 80 00       	mov    0x803004,%eax
  80143a:	8b 48 48             	mov    0x48(%eax),%ecx
  80143d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801440:	c1 e0 0c             	shl    $0xc,%eax
  801443:	89 c2                	mov    %eax,%edx
  801445:	a1 04 30 80 00       	mov    0x803004,%eax
  80144a:	8b 40 48             	mov    0x48(%eax),%eax
  80144d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801451:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801455:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801459:	89 54 24 04          	mov    %edx,0x4(%esp)
  80145d:	89 04 24             	mov    %eax,(%esp)
  801460:	e8 b3 fb ff ff       	call   801018 <sys_page_map>
  801465:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801468:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80146c:	79 23                	jns    801491 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80146e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801471:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801475:	c7 44 24 08 b0 1f 80 	movl   $0x801fb0,0x8(%esp)
  80147c:	00 
  80147d:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801484:	00 
  801485:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  80148c:	e8 bd 03 00 00       	call   80184e <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801491:	eb 70                	jmp    801503 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801493:	8b 45 0c             	mov    0xc(%ebp),%eax
  801496:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149d:	25 ff 0f 00 00       	and    $0xfff,%eax
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a7:	c1 e0 0c             	shl    $0xc,%eax
  8014aa:	89 c1                	mov    %eax,%ecx
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	c1 e0 0c             	shl    $0xc,%eax
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	a1 04 30 80 00       	mov    0x803004,%eax
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014c0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014cf:	89 04 24             	mov    %eax,(%esp)
  8014d2:	e8 41 fb ff ff       	call   801018 <sys_page_map>
  8014d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014de:	79 23                	jns    801503 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  8014e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e7:	c7 44 24 08 e0 1f 80 	movl   $0x801fe0,0x8(%esp)
  8014ee:	00 
  8014ef:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8014f6:	00 
  8014f7:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  8014fe:	e8 4b 03 00 00       	call   80184e <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801508:	83 c4 30             	add    $0x30,%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    

0080150f <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801515:	c7 04 24 2e 12 80 00 	movl   $0x80122e,(%esp)
  80151c:	e8 88 03 00 00       	call   8018a9 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801521:	b8 07 00 00 00       	mov    $0x7,%eax
  801526:	cd 30                	int    $0x30
  801528:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80152b:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80152e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  801531:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801535:	79 23                	jns    80155a <fork+0x4b>
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153e:	c7 44 24 08 18 20 80 	movl   $0x802018,0x8(%esp)
  801545:	00 
  801546:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80154d:	00 
  80154e:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  801555:	e8 f4 02 00 00       	call   80184e <_panic>
	else if(childeid == 0){
  80155a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80155e:	75 29                	jne    801589 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801560:	e8 ea f9 ff ff       	call   800f4f <sys_getenvid>
  801565:	25 ff 03 00 00       	and    $0x3ff,%eax
  80156a:	c1 e0 02             	shl    $0x2,%eax
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	c1 e2 05             	shl    $0x5,%edx
  801572:	29 c2                	sub    %eax,%edx
  801574:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80157a:	a3 04 30 80 00       	mov    %eax,0x803004
		// set_pgfault_handler(pgfault);
		return 0;
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	e9 16 01 00 00       	jmp    80169f <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801589:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801590:	eb 3b                	jmp    8015cd <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801595:	c1 f8 0a             	sar    $0xa,%eax
  801598:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80159f:	83 e0 01             	and    $0x1,%eax
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	74 23                	je     8015c9 <fork+0xba>
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b0:	83 e0 01             	and    $0x1,%eax
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	74 12                	je     8015c9 <fork+0xba>
			duppage(childeid, i);
  8015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	89 04 24             	mov    %eax,(%esp)
  8015c4:	e8 b3 fd ff ff       	call   80137c <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015c9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8015cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d0:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  8015d5:	76 bb                	jbe    801592 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  8015d7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8015de:	00 
  8015df:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8015e6:	ee 
  8015e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ea:	89 04 24             	mov    %eax,(%esp)
  8015ed:	e8 e5 f9 ff ff       	call   800fd7 <sys_page_alloc>
  8015f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015f9:	79 23                	jns    80161e <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8015fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801602:	c7 44 24 08 40 20 80 	movl   $0x802040,0x8(%esp)
  801609:	00 
  80160a:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801611:	00 
  801612:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  801619:	e8 30 02 00 00       	call   80184e <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80161e:	c7 44 24 04 1f 19 80 	movl   $0x80191f,0x4(%esp)
  801625:	00 
  801626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 b1 fa ff ff       	call   8010e2 <sys_env_set_pgfault_upcall>
  801631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801634:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801638:	79 23                	jns    80165d <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  80163a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80163d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801641:	c7 44 24 08 68 20 80 	movl   $0x802068,0x8(%esp)
  801648:	00 
  801649:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801650:	00 
  801651:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  801658:	e8 f1 01 00 00       	call   80184e <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  80165d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801664:	00 
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	89 04 24             	mov    %eax,(%esp)
  80166b:	e8 30 fa ff ff       	call   8010a0 <sys_env_set_status>
  801670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801673:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801677:	79 23                	jns    80169c <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  801679:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801680:	c7 44 24 08 9c 20 80 	movl   $0x80209c,0x8(%esp)
  801687:	00 
  801688:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80168f:	00 
  801690:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  801697:	e8 b2 01 00 00       	call   80184e <_panic>
	}
	return childeid;
  80169c:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <sfork>:

// Challenge!
int
sfork(void)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016a7:	c7 44 24 08 c5 20 80 	movl   $0x8020c5,0x8(%esp)
  8016ae:	00 
  8016af:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8016b6:	00 
  8016b7:	c7 04 24 c0 1e 80 00 	movl   $0x801ec0,(%esp)
  8016be:	e8 8b 01 00 00       	call   80184e <_panic>

008016c3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  8016c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8016cd:	75 09                	jne    8016d8 <ipc_recv+0x15>
		i_dstva = UTOP;
  8016cf:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  8016d6:	eb 06                	jmp    8016de <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  8016d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016db:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  8016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e1:	89 04 24             	mov    %eax,(%esp)
  8016e4:	e8 7b fa ff ff       	call   801164 <sys_ipc_recv>
  8016e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  8016ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8016f0:	75 15                	jne    801707 <ipc_recv+0x44>
  8016f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8016f6:	74 0f                	je     801707 <ipc_recv+0x44>
  8016f8:	a1 04 30 80 00       	mov    0x803004,%eax
  8016fd:	8b 50 74             	mov    0x74(%eax),%edx
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	89 10                	mov    %edx,(%eax)
  801705:	eb 15                	jmp    80171c <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  801707:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80170b:	79 0f                	jns    80171c <ipc_recv+0x59>
  80170d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801711:	74 09                	je     80171c <ipc_recv+0x59>
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  80171c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801720:	75 15                	jne    801737 <ipc_recv+0x74>
  801722:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801726:	74 0f                	je     801737 <ipc_recv+0x74>
  801728:	a1 04 30 80 00       	mov    0x803004,%eax
  80172d:	8b 50 78             	mov    0x78(%eax),%edx
  801730:	8b 45 10             	mov    0x10(%ebp),%eax
  801733:	89 10                	mov    %edx,(%eax)
  801735:	eb 15                	jmp    80174c <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  801737:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80173b:	79 0f                	jns    80174c <ipc_recv+0x89>
  80173d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801741:	74 09                	je     80174c <ipc_recv+0x89>
  801743:	8b 45 10             	mov    0x10(%ebp),%eax
  801746:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  80174c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801750:	75 0a                	jne    80175c <ipc_recv+0x99>
  801752:	a1 04 30 80 00       	mov    0x803004,%eax
  801757:	8b 40 70             	mov    0x70(%eax),%eax
  80175a:	eb 03                	jmp    80175f <ipc_recv+0x9c>
	else return r;
  80175c:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  801767:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  80176e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801772:	74 06                	je     80177a <ipc_send+0x19>
  801774:	8b 45 10             	mov    0x10(%ebp),%eax
  801777:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  80177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177d:	8b 55 14             	mov    0x14(%ebp),%edx
  801780:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801784:	89 44 24 08          	mov    %eax,0x8(%esp)
  801788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	8b 45 08             	mov    0x8(%ebp),%eax
  801792:	89 04 24             	mov    %eax,(%esp)
  801795:	e8 8a f9 ff ff       	call   801124 <sys_ipc_try_send>
  80179a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  80179d:	eb 28                	jmp    8017c7 <ipc_send+0x66>
		sys_yield();
  80179f:	e8 ef f7 ff ff       	call   800f93 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8017a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a7:	8b 55 14             	mov    0x14(%ebp),%edx
  8017aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	89 04 24             	mov    %eax,(%esp)
  8017bf:	e8 60 f9 ff ff       	call   801124 <sys_ipc_try_send>
  8017c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  8017c7:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  8017cb:	74 d2                	je     80179f <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  8017cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017d1:	75 02                	jne    8017d5 <ipc_send+0x74>
  8017d3:	eb 23                	jmp    8017f8 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017dc:	c7 44 24 08 dc 20 80 	movl   $0x8020dc,0x8(%esp)
  8017e3:	00 
  8017e4:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8017eb:	00 
  8017ec:	c7 04 24 01 21 80 00 	movl   $0x802101,(%esp)
  8017f3:	e8 56 00 00 00       	call   80184e <_panic>
	panic("ipc_send not implemented");
}
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  801800:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801807:	eb 35                	jmp    80183e <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801809:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80180c:	c1 e0 02             	shl    $0x2,%eax
  80180f:	89 c2                	mov    %eax,%edx
  801811:	c1 e2 05             	shl    $0x5,%edx
  801814:	29 c2                	sub    %eax,%edx
  801816:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  80181c:	8b 00                	mov    (%eax),%eax
  80181e:	3b 45 08             	cmp    0x8(%ebp),%eax
  801821:	75 17                	jne    80183a <ipc_find_env+0x40>
			return envs[i].env_id;
  801823:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801826:	c1 e0 02             	shl    $0x2,%eax
  801829:	89 c2                	mov    %eax,%edx
  80182b:	c1 e2 05             	shl    $0x5,%edx
  80182e:	29 c2                	sub    %eax,%edx
  801830:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  801836:	8b 00                	mov    (%eax),%eax
  801838:	eb 12                	jmp    80184c <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80183a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80183e:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  801845:	7e c2                	jle    801809 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801847:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184c:	c9                   	leave  
  80184d:	c3                   	ret    

0080184e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801855:	8d 45 14             	lea    0x14(%ebp),%eax
  801858:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80185b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801861:	e8 e9 f6 ff ff       	call   800f4f <sys_getenvid>
  801866:	8b 55 0c             	mov    0xc(%ebp),%edx
  801869:	89 54 24 10          	mov    %edx,0x10(%esp)
  80186d:	8b 55 08             	mov    0x8(%ebp),%edx
  801870:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801874:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187c:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  801883:	e8 92 e9 ff ff       	call   80021a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188f:	8b 45 10             	mov    0x10(%ebp),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 1c e9 ff ff       	call   8001b6 <vcprintf>
	cprintf("\n");
  80189a:	c7 04 24 2f 21 80 00 	movl   $0x80212f,(%esp)
  8018a1:	e8 74 e9 ff ff       	call   80021a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018a6:	cc                   	int3   
  8018a7:	eb fd                	jmp    8018a6 <_panic+0x58>

008018a9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018af:	a1 08 30 80 00       	mov    0x803008,%eax
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	75 5d                	jne    801915 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8018b8:	a1 04 30 80 00       	mov    0x803004,%eax
  8018bd:	8b 40 48             	mov    0x48(%eax),%eax
  8018c0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018c7:	00 
  8018c8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8018cf:	ee 
  8018d0:	89 04 24             	mov    %eax,(%esp)
  8018d3:	e8 ff f6 ff ff       	call   800fd7 <sys_page_alloc>
  8018d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8018db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018df:	79 1c                	jns    8018fd <set_pgfault_handler+0x54>
  8018e1:	c7 44 24 08 34 21 80 	movl   $0x802134,0x8(%esp)
  8018e8:	00 
  8018e9:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8018f0:	00 
  8018f1:	c7 04 24 60 21 80 00 	movl   $0x802160,(%esp)
  8018f8:	e8 51 ff ff ff       	call   80184e <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8018fd:	a1 04 30 80 00       	mov    0x803004,%eax
  801902:	8b 40 48             	mov    0x48(%eax),%eax
  801905:	c7 44 24 04 1f 19 80 	movl   $0x80191f,0x4(%esp)
  80190c:	00 
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	e8 cd f7 ff ff       	call   8010e2 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	a3 08 30 80 00       	mov    %eax,0x803008
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80191f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801920:	a1 08 30 80 00       	mov    0x803008,%eax
	call *%eax
  801925:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801927:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  80192a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  80192e:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801930:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801934:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801935:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801938:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  80193a:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  80193b:	58                   	pop    %eax
	popal 						// pop all the registers
  80193c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  80193d:	83 c4 04             	add    $0x4,%esp
	popfl
  801940:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801941:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801942:	c3                   	ret    
  801943:	66 90                	xchg   %ax,%ax
  801945:	66 90                	xchg   %ax,%ax
  801947:	66 90                	xchg   %ax,%ax
  801949:	66 90                	xchg   %ax,%ax
  80194b:	66 90                	xchg   %ax,%ax
  80194d:	66 90                	xchg   %ax,%ax
  80194f:	90                   	nop

00801950 <__udivdi3>:
  801950:	55                   	push   %ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	8b 44 24 28          	mov    0x28(%esp),%eax
  80195a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80195e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801962:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801966:	85 c0                	test   %eax,%eax
  801968:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80196c:	89 ea                	mov    %ebp,%edx
  80196e:	89 0c 24             	mov    %ecx,(%esp)
  801971:	75 2d                	jne    8019a0 <__udivdi3+0x50>
  801973:	39 e9                	cmp    %ebp,%ecx
  801975:	77 61                	ja     8019d8 <__udivdi3+0x88>
  801977:	85 c9                	test   %ecx,%ecx
  801979:	89 ce                	mov    %ecx,%esi
  80197b:	75 0b                	jne    801988 <__udivdi3+0x38>
  80197d:	b8 01 00 00 00       	mov    $0x1,%eax
  801982:	31 d2                	xor    %edx,%edx
  801984:	f7 f1                	div    %ecx
  801986:	89 c6                	mov    %eax,%esi
  801988:	31 d2                	xor    %edx,%edx
  80198a:	89 e8                	mov    %ebp,%eax
  80198c:	f7 f6                	div    %esi
  80198e:	89 c5                	mov    %eax,%ebp
  801990:	89 f8                	mov    %edi,%eax
  801992:	f7 f6                	div    %esi
  801994:	89 ea                	mov    %ebp,%edx
  801996:	83 c4 0c             	add    $0xc,%esp
  801999:	5e                   	pop    %esi
  80199a:	5f                   	pop    %edi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    
  80199d:	8d 76 00             	lea    0x0(%esi),%esi
  8019a0:	39 e8                	cmp    %ebp,%eax
  8019a2:	77 24                	ja     8019c8 <__udivdi3+0x78>
  8019a4:	0f bd e8             	bsr    %eax,%ebp
  8019a7:	83 f5 1f             	xor    $0x1f,%ebp
  8019aa:	75 3c                	jne    8019e8 <__udivdi3+0x98>
  8019ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019b0:	39 34 24             	cmp    %esi,(%esp)
  8019b3:	0f 86 9f 00 00 00    	jbe    801a58 <__udivdi3+0x108>
  8019b9:	39 d0                	cmp    %edx,%eax
  8019bb:	0f 82 97 00 00 00    	jb     801a58 <__udivdi3+0x108>
  8019c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019c8:	31 d2                	xor    %edx,%edx
  8019ca:	31 c0                	xor    %eax,%eax
  8019cc:	83 c4 0c             	add    $0xc,%esp
  8019cf:	5e                   	pop    %esi
  8019d0:	5f                   	pop    %edi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    
  8019d3:	90                   	nop
  8019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d8:	89 f8                	mov    %edi,%eax
  8019da:	f7 f1                	div    %ecx
  8019dc:	31 d2                	xor    %edx,%edx
  8019de:	83 c4 0c             	add    $0xc,%esp
  8019e1:	5e                   	pop    %esi
  8019e2:	5f                   	pop    %edi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    
  8019e5:	8d 76 00             	lea    0x0(%esi),%esi
  8019e8:	89 e9                	mov    %ebp,%ecx
  8019ea:	8b 3c 24             	mov    (%esp),%edi
  8019ed:	d3 e0                	shl    %cl,%eax
  8019ef:	89 c6                	mov    %eax,%esi
  8019f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8019f6:	29 e8                	sub    %ebp,%eax
  8019f8:	89 c1                	mov    %eax,%ecx
  8019fa:	d3 ef                	shr    %cl,%edi
  8019fc:	89 e9                	mov    %ebp,%ecx
  8019fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a02:	8b 3c 24             	mov    (%esp),%edi
  801a05:	09 74 24 08          	or     %esi,0x8(%esp)
  801a09:	89 d6                	mov    %edx,%esi
  801a0b:	d3 e7                	shl    %cl,%edi
  801a0d:	89 c1                	mov    %eax,%ecx
  801a0f:	89 3c 24             	mov    %edi,(%esp)
  801a12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a16:	d3 ee                	shr    %cl,%esi
  801a18:	89 e9                	mov    %ebp,%ecx
  801a1a:	d3 e2                	shl    %cl,%edx
  801a1c:	89 c1                	mov    %eax,%ecx
  801a1e:	d3 ef                	shr    %cl,%edi
  801a20:	09 d7                	or     %edx,%edi
  801a22:	89 f2                	mov    %esi,%edx
  801a24:	89 f8                	mov    %edi,%eax
  801a26:	f7 74 24 08          	divl   0x8(%esp)
  801a2a:	89 d6                	mov    %edx,%esi
  801a2c:	89 c7                	mov    %eax,%edi
  801a2e:	f7 24 24             	mull   (%esp)
  801a31:	39 d6                	cmp    %edx,%esi
  801a33:	89 14 24             	mov    %edx,(%esp)
  801a36:	72 30                	jb     801a68 <__udivdi3+0x118>
  801a38:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a3c:	89 e9                	mov    %ebp,%ecx
  801a3e:	d3 e2                	shl    %cl,%edx
  801a40:	39 c2                	cmp    %eax,%edx
  801a42:	73 05                	jae    801a49 <__udivdi3+0xf9>
  801a44:	3b 34 24             	cmp    (%esp),%esi
  801a47:	74 1f                	je     801a68 <__udivdi3+0x118>
  801a49:	89 f8                	mov    %edi,%eax
  801a4b:	31 d2                	xor    %edx,%edx
  801a4d:	e9 7a ff ff ff       	jmp    8019cc <__udivdi3+0x7c>
  801a52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a58:	31 d2                	xor    %edx,%edx
  801a5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a5f:	e9 68 ff ff ff       	jmp    8019cc <__udivdi3+0x7c>
  801a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a68:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a6b:	31 d2                	xor    %edx,%edx
  801a6d:	83 c4 0c             	add    $0xc,%esp
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    
  801a74:	66 90                	xchg   %ax,%ax
  801a76:	66 90                	xchg   %ax,%ax
  801a78:	66 90                	xchg   %ax,%ax
  801a7a:	66 90                	xchg   %ax,%ax
  801a7c:	66 90                	xchg   %ax,%ax
  801a7e:	66 90                	xchg   %ax,%ax

00801a80 <__umoddi3>:
  801a80:	55                   	push   %ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	83 ec 14             	sub    $0x14,%esp
  801a86:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a8a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a8e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801a92:	89 c7                	mov    %eax,%edi
  801a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a98:	8b 44 24 30          	mov    0x30(%esp),%eax
  801a9c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801aa0:	89 34 24             	mov    %esi,(%esp)
  801aa3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aaf:	75 17                	jne    801ac8 <__umoddi3+0x48>
  801ab1:	39 fe                	cmp    %edi,%esi
  801ab3:	76 4b                	jbe    801b00 <__umoddi3+0x80>
  801ab5:	89 c8                	mov    %ecx,%eax
  801ab7:	89 fa                	mov    %edi,%edx
  801ab9:	f7 f6                	div    %esi
  801abb:	89 d0                	mov    %edx,%eax
  801abd:	31 d2                	xor    %edx,%edx
  801abf:	83 c4 14             	add    $0x14,%esp
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    
  801ac6:	66 90                	xchg   %ax,%ax
  801ac8:	39 f8                	cmp    %edi,%eax
  801aca:	77 54                	ja     801b20 <__umoddi3+0xa0>
  801acc:	0f bd e8             	bsr    %eax,%ebp
  801acf:	83 f5 1f             	xor    $0x1f,%ebp
  801ad2:	75 5c                	jne    801b30 <__umoddi3+0xb0>
  801ad4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ad8:	39 3c 24             	cmp    %edi,(%esp)
  801adb:	0f 87 e7 00 00 00    	ja     801bc8 <__umoddi3+0x148>
  801ae1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ae5:	29 f1                	sub    %esi,%ecx
  801ae7:	19 c7                	sbb    %eax,%edi
  801ae9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801af1:	8b 44 24 08          	mov    0x8(%esp),%eax
  801af5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801af9:	83 c4 14             	add    $0x14,%esp
  801afc:	5e                   	pop    %esi
  801afd:	5f                   	pop    %edi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    
  801b00:	85 f6                	test   %esi,%esi
  801b02:	89 f5                	mov    %esi,%ebp
  801b04:	75 0b                	jne    801b11 <__umoddi3+0x91>
  801b06:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	f7 f6                	div    %esi
  801b0f:	89 c5                	mov    %eax,%ebp
  801b11:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b15:	31 d2                	xor    %edx,%edx
  801b17:	f7 f5                	div    %ebp
  801b19:	89 c8                	mov    %ecx,%eax
  801b1b:	f7 f5                	div    %ebp
  801b1d:	eb 9c                	jmp    801abb <__umoddi3+0x3b>
  801b1f:	90                   	nop
  801b20:	89 c8                	mov    %ecx,%eax
  801b22:	89 fa                	mov    %edi,%edx
  801b24:	83 c4 14             	add    $0x14,%esp
  801b27:	5e                   	pop    %esi
  801b28:	5f                   	pop    %edi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    
  801b2b:	90                   	nop
  801b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b30:	8b 04 24             	mov    (%esp),%eax
  801b33:	be 20 00 00 00       	mov    $0x20,%esi
  801b38:	89 e9                	mov    %ebp,%ecx
  801b3a:	29 ee                	sub    %ebp,%esi
  801b3c:	d3 e2                	shl    %cl,%edx
  801b3e:	89 f1                	mov    %esi,%ecx
  801b40:	d3 e8                	shr    %cl,%eax
  801b42:	89 e9                	mov    %ebp,%ecx
  801b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b48:	8b 04 24             	mov    (%esp),%eax
  801b4b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b4f:	89 fa                	mov    %edi,%edx
  801b51:	d3 e0                	shl    %cl,%eax
  801b53:	89 f1                	mov    %esi,%ecx
  801b55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b59:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b5d:	d3 ea                	shr    %cl,%edx
  801b5f:	89 e9                	mov    %ebp,%ecx
  801b61:	d3 e7                	shl    %cl,%edi
  801b63:	89 f1                	mov    %esi,%ecx
  801b65:	d3 e8                	shr    %cl,%eax
  801b67:	89 e9                	mov    %ebp,%ecx
  801b69:	09 f8                	or     %edi,%eax
  801b6b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b6f:	f7 74 24 04          	divl   0x4(%esp)
  801b73:	d3 e7                	shl    %cl,%edi
  801b75:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b79:	89 d7                	mov    %edx,%edi
  801b7b:	f7 64 24 08          	mull   0x8(%esp)
  801b7f:	39 d7                	cmp    %edx,%edi
  801b81:	89 c1                	mov    %eax,%ecx
  801b83:	89 14 24             	mov    %edx,(%esp)
  801b86:	72 2c                	jb     801bb4 <__umoddi3+0x134>
  801b88:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801b8c:	72 22                	jb     801bb0 <__umoddi3+0x130>
  801b8e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b92:	29 c8                	sub    %ecx,%eax
  801b94:	19 d7                	sbb    %edx,%edi
  801b96:	89 e9                	mov    %ebp,%ecx
  801b98:	89 fa                	mov    %edi,%edx
  801b9a:	d3 e8                	shr    %cl,%eax
  801b9c:	89 f1                	mov    %esi,%ecx
  801b9e:	d3 e2                	shl    %cl,%edx
  801ba0:	89 e9                	mov    %ebp,%ecx
  801ba2:	d3 ef                	shr    %cl,%edi
  801ba4:	09 d0                	or     %edx,%eax
  801ba6:	89 fa                	mov    %edi,%edx
  801ba8:	83 c4 14             	add    $0x14,%esp
  801bab:	5e                   	pop    %esi
  801bac:	5f                   	pop    %edi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    
  801baf:	90                   	nop
  801bb0:	39 d7                	cmp    %edx,%edi
  801bb2:	75 da                	jne    801b8e <__umoddi3+0x10e>
  801bb4:	8b 14 24             	mov    (%esp),%edx
  801bb7:	89 c1                	mov    %eax,%ecx
  801bb9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bbd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801bc1:	eb cb                	jmp    801b8e <__umoddi3+0x10e>
  801bc3:	90                   	nop
  801bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bc8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801bcc:	0f 82 0f ff ff ff    	jb     801ae1 <__umoddi3+0x61>
  801bd2:	e9 1a ff ff ff       	jmp    801af1 <__umoddi3+0x71>
