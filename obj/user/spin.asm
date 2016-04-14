
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 7d 00 00 00       	call   8000ae <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800039:	c7 04 24 80 19 80 00 	movl   $0x801980,(%esp)
  800040:	e8 8c 01 00 00       	call   8001d1 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 f5 13 00 00       	call   80143f <fork>
  80004a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80004d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800051:	75 0e                	jne    800061 <umain+0x2e>
		cprintf("I am the child.  Spinning...\n");
  800053:	c7 04 24 a8 19 80 00 	movl   $0x8019a8,(%esp)
  80005a:	e8 72 01 00 00       	call   8001d1 <cprintf>
		while (1)
			/* do nothing */;
  80005f:	eb fe                	jmp    80005f <umain+0x2c>
	}

	cprintf("I am the parent.  Running the child...\n");
  800061:	c7 04 24 c8 19 80 00 	movl   $0x8019c8,(%esp)
  800068:	e8 64 01 00 00       	call   8001d1 <cprintf>
	sys_yield();
  80006d:	e8 d8 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  800072:	e8 d3 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  800077:	e8 ce 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  80007c:	e8 c9 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  800081:	e8 c4 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  800086:	e8 bf 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  80008b:	e8 ba 0e 00 00       	call   800f4a <sys_yield>
	sys_yield();
  800090:	e8 b5 0e 00 00       	call   800f4a <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800095:	c7 04 24 f0 19 80 00 	movl   $0x8019f0,(%esp)
  80009c:	e8 30 01 00 00       	call   8001d1 <cprintf>
	sys_env_destroy(env);
  8000a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a4:	89 04 24             	mov    %eax,(%esp)
  8000a7:	e8 17 0e 00 00       	call   800ec3 <sys_env_destroy>
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000b4:	e8 4d 0e 00 00       	call   800f06 <sys_getenvid>
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	c1 e0 02             	shl    $0x2,%eax
  8000c1:	89 c2                	mov    %eax,%edx
  8000c3:	c1 e2 05             	shl    $0x5,%edx
  8000c6:	29 c2                	sub    %eax,%edx
  8000c8:	89 d0                	mov    %edx,%eax
  8000ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000cf:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000d8:	7e 0a                	jle    8000e4 <libmain+0x36>
		binaryname = argv[0];
  8000da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000dd:	8b 00                	mov    (%eax),%eax
  8000df:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 3d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f6:	e8 02 00 00 00       	call   8000fd <exit>
}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800103:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80010a:	e8 b4 0d 00 00       	call   800ec3 <sys_env_destroy>
}
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011a:	8b 00                	mov    (%eax),%eax
  80011c:	8d 48 01             	lea    0x1(%eax),%ecx
  80011f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800122:	89 0a                	mov    %ecx,(%edx)
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	89 d1                	mov    %edx,%ecx
  800129:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800130:	8b 45 0c             	mov    0xc(%ebp),%eax
  800133:	8b 00                	mov    (%eax),%eax
  800135:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013a:	75 20                	jne    80015c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80013c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013f:	8b 00                	mov    (%eax),%eax
  800141:	8b 55 0c             	mov    0xc(%ebp),%edx
  800144:	83 c2 08             	add    $0x8,%edx
  800147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014b:	89 14 24             	mov    %edx,(%esp)
  80014e:	e8 ea 0c 00 00       	call   800e3d <sys_cputs>
		b->idx = 0;
  800153:	8b 45 0c             	mov    0xc(%ebp),%eax
  800156:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015f:	8b 40 04             	mov    0x4(%eax),%eax
  800162:	8d 50 01             	lea    0x1(%eax),%edx
  800165:	8b 45 0c             	mov    0xc(%ebp),%eax
  800168:	89 50 04             	mov    %edx,0x4(%eax)
}
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800176:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017d:	00 00 00 
	b.cnt = 0;
  800180:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800187:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	89 44 24 08          	mov    %eax,0x8(%esp)
  800198:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	c7 04 24 11 01 80 00 	movl   $0x800111,(%esp)
  8001a9:	e8 bd 01 00 00       	call   80036b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ae:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	83 c0 08             	add    $0x8,%eax
  8001c1:	89 04 24             	mov    %eax,(%esp)
  8001c4:	e8 74 0c 00 00       	call   800e3d <sys_cputs>

	return b.cnt;
  8001c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001da:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	e8 7e ff ff ff       	call   80016d <vcprintf>
  8001ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 34             	sub    $0x34,%esp
  8001fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800201:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800204:	8b 45 14             	mov    0x14(%ebp),%eax
  800207:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020a:	8b 45 18             	mov    0x18(%ebp),%eax
  80020d:	ba 00 00 00 00       	mov    $0x0,%edx
  800212:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800215:	77 72                	ja     800289 <printnum+0x92>
  800217:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80021a:	72 05                	jb     800221 <printnum+0x2a>
  80021c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80021f:	77 68                	ja     800289 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800221:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800224:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800227:	8b 45 18             	mov    0x18(%ebp),%eax
  80022a:	ba 00 00 00 00       	mov    $0x0,%edx
  80022f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800233:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80023a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80023d:	89 04 24             	mov    %eax,(%esp)
  800240:	89 54 24 04          	mov    %edx,0x4(%esp)
  800244:	e8 a7 14 00 00       	call   8016f0 <__udivdi3>
  800249:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80024c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800250:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800254:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800257:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80025b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
  800266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	e8 82 ff ff ff       	call   8001f7 <printnum>
  800275:	eb 1c                	jmp    800293 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027e:	8b 45 20             	mov    0x20(%ebp),%eax
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800289:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80028d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800291:	7f e4                	jg     800277 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800296:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80029e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002a1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b0:	e8 6b 15 00 00       	call   801820 <__umoddi3>
  8002b5:	05 08 1b 80 00       	add    $0x801b08,%eax
  8002ba:	0f b6 00             	movzbl (%eax),%eax
  8002bd:	0f be c0             	movsbl %al,%eax
  8002c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	ff d0                	call   *%eax
}
  8002cf:	83 c4 34             	add    $0x34,%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002dc:	7e 14                	jle    8002f2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	8d 48 08             	lea    0x8(%eax),%ecx
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	89 0a                	mov    %ecx,(%edx)
  8002eb:	8b 50 04             	mov    0x4(%eax),%edx
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	eb 30                	jmp    800322 <getuint+0x4d>
	else if (lflag)
  8002f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002f6:	74 16                	je     80030e <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	8b 00                	mov    (%eax),%eax
  8002fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800300:	8b 55 08             	mov    0x8(%ebp),%edx
  800303:	89 0a                	mov    %ecx,(%edx)
  800305:	8b 00                	mov    (%eax),%eax
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	eb 14                	jmp    800322 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 00                	mov    (%eax),%eax
  800313:	8d 48 04             	lea    0x4(%eax),%ecx
  800316:	8b 55 08             	mov    0x8(%ebp),%edx
  800319:	89 0a                	mov    %ecx,(%edx)
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800327:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80032b:	7e 14                	jle    800341 <getint+0x1d>
		return va_arg(*ap, long long);
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	8b 00                	mov    (%eax),%eax
  800332:	8d 48 08             	lea    0x8(%eax),%ecx
  800335:	8b 55 08             	mov    0x8(%ebp),%edx
  800338:	89 0a                	mov    %ecx,(%edx)
  80033a:	8b 50 04             	mov    0x4(%eax),%edx
  80033d:	8b 00                	mov    (%eax),%eax
  80033f:	eb 28                	jmp    800369 <getint+0x45>
	else if (lflag)
  800341:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800345:	74 12                	je     800359 <getint+0x35>
		return va_arg(*ap, long);
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	8b 00                	mov    (%eax),%eax
  80034c:	8d 48 04             	lea    0x4(%eax),%ecx
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 0a                	mov    %ecx,(%edx)
  800354:	8b 00                	mov    (%eax),%eax
  800356:	99                   	cltd   
  800357:	eb 10                	jmp    800369 <getint+0x45>
	else
		return va_arg(*ap, int);
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	8b 00                	mov    (%eax),%eax
  80035e:	8d 48 04             	lea    0x4(%eax),%ecx
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 0a                	mov    %ecx,(%edx)
  800366:	8b 00                	mov    (%eax),%eax
  800368:	99                   	cltd   
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800373:	eb 18                	jmp    80038d <vprintfmt+0x22>
			if (ch == '\0')
  800375:	85 db                	test   %ebx,%ebx
  800377:	75 05                	jne    80037e <vprintfmt+0x13>
				return;
  800379:	e9 cc 03 00 00       	jmp    80074a <vprintfmt+0x3df>
			putch(ch, putdat);
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	89 1c 24             	mov    %ebx,(%esp)
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038d:	8b 45 10             	mov    0x10(%ebp),%eax
  800390:	8d 50 01             	lea    0x1(%eax),%edx
  800393:	89 55 10             	mov    %edx,0x10(%ebp)
  800396:	0f b6 00             	movzbl (%eax),%eax
  800399:	0f b6 d8             	movzbl %al,%ebx
  80039c:	83 fb 25             	cmp    $0x25,%ebx
  80039f:	75 d4                	jne    800375 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003a1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003a5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c4:	8d 50 01             	lea    0x1(%eax),%edx
  8003c7:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ca:	0f b6 00             	movzbl (%eax),%eax
  8003cd:	0f b6 d8             	movzbl %al,%ebx
  8003d0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003d3:	83 f8 55             	cmp    $0x55,%eax
  8003d6:	0f 87 3d 03 00 00    	ja     800719 <vprintfmt+0x3ae>
  8003dc:	8b 04 85 2c 1b 80 00 	mov    0x801b2c(,%eax,4),%eax
  8003e3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003eb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003ef:	eb d0                	jmp    8003c1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003fb:	89 d0                	mov    %edx,%eax
  8003fd:	c1 e0 02             	shl    $0x2,%eax
  800400:	01 d0                	add    %edx,%eax
  800402:	01 c0                	add    %eax,%eax
  800404:	01 d8                	add    %ebx,%eax
  800406:	83 e8 30             	sub    $0x30,%eax
  800409:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	0f b6 00             	movzbl (%eax),%eax
  800412:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800415:	83 fb 2f             	cmp    $0x2f,%ebx
  800418:	7e 0b                	jle    800425 <vprintfmt+0xba>
  80041a:	83 fb 39             	cmp    $0x39,%ebx
  80041d:	7f 06                	jg     800425 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800423:	eb d3                	jmp    8003f8 <vprintfmt+0x8d>
			goto process_precision;
  800425:	eb 33                	jmp    80045a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 50 04             	lea    0x4(%eax),%edx
  80042d:	89 55 14             	mov    %edx,0x14(%ebp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800435:	eb 23                	jmp    80045a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800437:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043b:	79 0c                	jns    800449 <vprintfmt+0xde>
				width = 0;
  80043d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800444:	e9 78 ff ff ff       	jmp    8003c1 <vprintfmt+0x56>
  800449:	e9 73 ff ff ff       	jmp    8003c1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80044e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800455:	e9 67 ff ff ff       	jmp    8003c1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80045a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045e:	79 12                	jns    800472 <vprintfmt+0x107>
				width = precision, precision = -1;
  800460:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800463:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800466:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80046d:	e9 4f ff ff ff       	jmp    8003c1 <vprintfmt+0x56>
  800472:	e9 4a ff ff ff       	jmp    8003c1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800477:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80047b:	e9 41 ff ff ff       	jmp    8003c1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 00                	mov    (%eax),%eax
  80048b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800492:	89 04 24             	mov    %eax,(%esp)
  800495:	8b 45 08             	mov    0x8(%ebp),%eax
  800498:	ff d0                	call   *%eax
			break;
  80049a:	e9 a5 02 00 00       	jmp    800744 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	79 02                	jns    8004b0 <vprintfmt+0x145>
				err = -err;
  8004ae:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b0:	83 fb 09             	cmp    $0x9,%ebx
  8004b3:	7f 0b                	jg     8004c0 <vprintfmt+0x155>
  8004b5:	8b 34 9d e0 1a 80 00 	mov    0x801ae0(,%ebx,4),%esi
  8004bc:	85 f6                	test   %esi,%esi
  8004be:	75 23                	jne    8004e3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004c4:	c7 44 24 08 19 1b 80 	movl   $0x801b19,0x8(%esp)
  8004cb:	00 
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d6:	89 04 24             	mov    %eax,(%esp)
  8004d9:	e8 73 02 00 00       	call   800751 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004de:	e9 61 02 00 00       	jmp    800744 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004e7:	c7 44 24 08 22 1b 80 	movl   $0x801b22,0x8(%esp)
  8004ee:	00 
  8004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	89 04 24             	mov    %eax,(%esp)
  8004fc:	e8 50 02 00 00       	call   800751 <printfmt>
			break;
  800501:	e9 3e 02 00 00       	jmp    800744 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 30                	mov    (%eax),%esi
  800511:	85 f6                	test   %esi,%esi
  800513:	75 05                	jne    80051a <vprintfmt+0x1af>
				p = "(null)";
  800515:	be 25 1b 80 00       	mov    $0x801b25,%esi
			if (width > 0 && padc != '-')
  80051a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051e:	7e 37                	jle    800557 <vprintfmt+0x1ec>
  800520:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800524:	74 31                	je     800557 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052d:	89 34 24             	mov    %esi,(%esp)
  800530:	e8 39 03 00 00       	call   80086e <strnlen>
  800535:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800538:	eb 17                	jmp    800551 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80053a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80053e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800541:	89 54 24 04          	mov    %edx,0x4(%esp)
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	8b 45 08             	mov    0x8(%ebp),%eax
  80054b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800551:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800555:	7f e3                	jg     80053a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800557:	eb 38                	jmp    800591 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800559:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055d:	74 1f                	je     80057e <vprintfmt+0x213>
  80055f:	83 fb 1f             	cmp    $0x1f,%ebx
  800562:	7e 05                	jle    800569 <vprintfmt+0x1fe>
  800564:	83 fb 7e             	cmp    $0x7e,%ebx
  800567:	7e 15                	jle    80057e <vprintfmt+0x213>
					putch('?', putdat);
  800569:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800570:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800577:	8b 45 08             	mov    0x8(%ebp),%eax
  80057a:	ff d0                	call   *%eax
  80057c:	eb 0f                	jmp    80058d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	89 1c 24             	mov    %ebx,(%esp)
  800588:	8b 45 08             	mov    0x8(%ebp),%eax
  80058b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800591:	89 f0                	mov    %esi,%eax
  800593:	8d 70 01             	lea    0x1(%eax),%esi
  800596:	0f b6 00             	movzbl (%eax),%eax
  800599:	0f be d8             	movsbl %al,%ebx
  80059c:	85 db                	test   %ebx,%ebx
  80059e:	74 10                	je     8005b0 <vprintfmt+0x245>
  8005a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a4:	78 b3                	js     800559 <vprintfmt+0x1ee>
  8005a6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ae:	79 a9                	jns    800559 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b0:	eb 17                	jmp    8005c9 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cd:	7f e3                	jg     8005b2 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005cf:	e9 70 01 00 00       	jmp    800744 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	e8 3e fd ff ff       	call   800324 <getint>
  8005e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f2:	85 d2                	test   %edx,%edx
  8005f4:	79 26                	jns    80061c <vprintfmt+0x2b1>
				putch('-', putdat);
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	ff d0                	call   *%eax
				num = -(long long) num;
  800609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80060c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060f:	f7 d8                	neg    %eax
  800611:	83 d2 00             	adc    $0x0,%edx
  800614:	f7 da                	neg    %edx
  800616:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800619:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80061c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800623:	e9 a8 00 00 00       	jmp    8006d0 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800628:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80062b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	89 04 24             	mov    %eax,(%esp)
  800635:	e8 9b fc ff ff       	call   8002d5 <getuint>
  80063a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80063d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800640:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800647:	e9 84 00 00 00       	jmp    8006d0 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80064f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	e8 77 fc ff ff       	call   8002d5 <getuint>
  80065e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800661:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800664:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80066b:	eb 63                	jmp    8006d0 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80066d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	ff d0                	call   *%eax
			putch('x', putdat);
  800680:	8b 45 0c             	mov    0xc(%ebp),%eax
  800683:	89 44 24 04          	mov    %eax,0x4(%esp)
  800687:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 04             	lea    0x4(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006af:	eb 1f                	jmp    8006d0 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	e8 12 fc ff ff       	call   8002d5 <getuint>
  8006c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006c9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d7:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006de:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	89 04 24             	mov    %eax,(%esp)
  800701:	e8 f1 fa ff ff       	call   8001f7 <printnum>
			break;
  800706:	eb 3c                	jmp    800744 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800708:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070f:	89 1c 24             	mov    %ebx,(%esp)
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	ff d0                	call   *%eax
			break;
  800717:	eb 2b                	jmp    800744 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800730:	eb 04                	jmp    800736 <vprintfmt+0x3cb>
  800732:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800736:	8b 45 10             	mov    0x10(%ebp),%eax
  800739:	83 e8 01             	sub    $0x1,%eax
  80073c:	0f b6 00             	movzbl (%eax),%eax
  80073f:	3c 25                	cmp    $0x25,%al
  800741:	75 ef                	jne    800732 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800743:	90                   	nop
		}
	}
  800744:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800745:	e9 43 fc ff ff       	jmp    80038d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 40             	add    $0x40,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80075d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800760:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800764:	8b 45 10             	mov    0x10(%ebp),%eax
  800767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 ee fb ff ff       	call   80036b <vprintfmt>
	va_end(ap);
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800782:	8b 45 0c             	mov    0xc(%ebp),%eax
  800785:	8b 40 08             	mov    0x8(%eax),%eax
  800788:	8d 50 01             	lea    0x1(%eax),%edx
  80078b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
  800794:	8b 10                	mov    (%eax),%edx
  800796:	8b 45 0c             	mov    0xc(%ebp),%eax
  800799:	8b 40 04             	mov    0x4(%eax),%eax
  80079c:	39 c2                	cmp    %eax,%edx
  80079e:	73 12                	jae    8007b2 <sprintputch+0x33>
		*b->buf++ = ch;
  8007a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	8d 48 01             	lea    0x1(%eax),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ab:	89 0a                	mov    %ecx,(%edx)
  8007ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b0:	88 10                	mov    %dl,(%eax)
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	01 d0                	add    %edx,%eax
  8007cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007d9:	74 06                	je     8007e1 <vsnprintf+0x2d>
  8007db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007df:	7f 07                	jg     8007e8 <vsnprintf+0x34>
		return -E_INVAL;
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e6:	eb 2a                	jmp    800812 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fd:	c7 04 24 7f 07 80 00 	movl   $0x80077f,(%esp)
  800804:	e8 62 fb ff ff       	call   80036b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800809:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80081a:	8d 45 14             	lea    0x14(%ebp),%eax
  80081d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800827:	8b 45 10             	mov    0x10(%ebp),%eax
  80082a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800831:	89 44 24 04          	mov    %eax,0x4(%esp)
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	89 04 24             	mov    %eax,(%esp)
  80083b:	e8 74 ff ff ff       	call   8007b4 <vsnprintf>
  800840:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800843:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80084e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800855:	eb 08                	jmp    80085f <strlen+0x17>
		n++;
  800857:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80085b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	0f b6 00             	movzbl (%eax),%eax
  800865:	84 c0                	test   %al,%al
  800867:	75 ee                	jne    800857 <strlen+0xf>
		n++;
	return n;
  800869:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800874:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80087b:	eb 0c                	jmp    800889 <strnlen+0x1b>
		n++;
  80087d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800885:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800889:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80088d:	74 0a                	je     800899 <strnlen+0x2b>
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	0f b6 00             	movzbl (%eax),%eax
  800895:	84 c0                	test   %al,%al
  800897:	75 e4                	jne    80087d <strnlen+0xf>
		n++;
	return n;
  800899:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008aa:	90                   	nop
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8d 50 01             	lea    0x1(%eax),%edx
  8008b1:	89 55 08             	mov    %edx,0x8(%ebp)
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008ba:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	88 10                	mov    %dl,(%eax)
  8008c2:	0f b6 00             	movzbl (%eax),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	75 e2                	jne    8008ab <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	89 04 24             	mov    %eax,(%esp)
  8008da:	e8 69 ff ff ff       	call   800848 <strlen>
  8008df:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	01 c2                	add    %eax,%edx
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f1:	89 14 24             	mov    %edx,(%esp)
  8008f4:	e8 a5 ff ff ff       	call   80089e <strcpy>
	return dst;
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80090a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800911:	eb 23                	jmp    800936 <strncpy+0x38>
		*dst++ = *src;
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8d 50 01             	lea    0x1(%eax),%edx
  800919:	89 55 08             	mov    %edx,0x8(%ebp)
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	0f b6 12             	movzbl (%edx),%edx
  800922:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	0f b6 00             	movzbl (%eax),%eax
  80092a:	84 c0                	test   %al,%al
  80092c:	74 04                	je     800932 <strncpy+0x34>
			src++;
  80092e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800936:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800939:	3b 45 10             	cmp    0x10(%ebp),%eax
  80093c:	72 d5                	jb     800913 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80093e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800941:	c9                   	leave  
  800942:	c3                   	ret    

00800943 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80094f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800953:	74 33                	je     800988 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800955:	eb 17                	jmp    80096e <strlcpy+0x2b>
			*dst++ = *src++;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8d 50 01             	lea    0x1(%eax),%edx
  80095d:	89 55 08             	mov    %edx,0x8(%ebp)
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
  800963:	8d 4a 01             	lea    0x1(%edx),%ecx
  800966:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80096e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800972:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800976:	74 0a                	je     800982 <strlcpy+0x3f>
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	0f b6 00             	movzbl (%eax),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	75 d5                	jne    800957 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80098e:	29 c2                	sub    %eax,%edx
  800990:	89 d0                	mov    %edx,%eax
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800997:	eb 08                	jmp    8009a1 <strcmp+0xd>
		p++, q++;
  800999:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80099d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 00             	movzbl (%eax),%eax
  8009a7:	84 c0                	test   %al,%al
  8009a9:	74 10                	je     8009bb <strcmp+0x27>
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	0f b6 00             	movzbl (%eax),%eax
  8009b7:	38 c2                	cmp    %al,%dl
  8009b9:	74 de                	je     800999 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	0f b6 00             	movzbl (%eax),%eax
  8009c1:	0f b6 d0             	movzbl %al,%edx
  8009c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c7:	0f b6 00             	movzbl (%eax),%eax
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	29 c2                	sub    %eax,%edx
  8009cf:	89 d0                	mov    %edx,%eax
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009d6:	eb 0c                	jmp    8009e4 <strncmp+0x11>
		n--, p++, q++;
  8009d8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009e0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009e8:	74 1a                	je     800a04 <strncmp+0x31>
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 00             	movzbl (%eax),%eax
  8009f0:	84 c0                	test   %al,%al
  8009f2:	74 10                	je     800a04 <strncmp+0x31>
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	0f b6 10             	movzbl (%eax),%edx
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	0f b6 00             	movzbl (%eax),%eax
  800a00:	38 c2                	cmp    %al,%dl
  800a02:	74 d4                	je     8009d8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a08:	75 07                	jne    800a11 <strncmp+0x3e>
		return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0f:	eb 16                	jmp    800a27 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	0f b6 00             	movzbl (%eax),%eax
  800a17:	0f b6 d0             	movzbl %al,%edx
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	0f b6 00             	movzbl (%eax),%eax
  800a20:	0f b6 c0             	movzbl %al,%eax
  800a23:	29 c2                	sub    %eax,%edx
  800a25:	89 d0                	mov    %edx,%eax
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	83 ec 04             	sub    $0x4,%esp
  800a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a32:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a35:	eb 14                	jmp    800a4b <strchr+0x22>
		if (*s == c)
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	0f b6 00             	movzbl (%eax),%eax
  800a3d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a40:	75 05                	jne    800a47 <strchr+0x1e>
			return (char *) s;
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	eb 13                	jmp    800a5a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a47:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	0f b6 00             	movzbl (%eax),%eax
  800a51:	84 c0                	test   %al,%al
  800a53:	75 e2                	jne    800a37 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a68:	eb 11                	jmp    800a7b <strfind+0x1f>
		if (*s == c)
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 00             	movzbl (%eax),%eax
  800a70:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a73:	75 02                	jne    800a77 <strfind+0x1b>
			break;
  800a75:	eb 0e                	jmp    800a85 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	84 c0                	test   %al,%al
  800a83:	75 e5                	jne    800a6a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a92:	75 05                	jne    800a99 <memset+0xf>
		return v;
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	eb 5c                	jmp    800af5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	83 e0 03             	and    $0x3,%eax
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	75 41                	jne    800ae4 <memset+0x5a>
  800aa3:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa6:	83 e0 03             	and    $0x3,%eax
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	75 37                	jne    800ae4 <memset+0x5a>
		c &= 0xFF;
  800aad:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	c1 e0 18             	shl    $0x18,%eax
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abf:	c1 e0 10             	shl    $0x10,%eax
  800ac2:	09 c2                	or     %eax,%edx
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	c1 e0 08             	shl    $0x8,%eax
  800aca:	09 d0                	or     %edx,%eax
  800acc:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800acf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad2:	c1 e8 02             	shr    $0x2,%eax
  800ad5:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ad7:	8b 55 08             	mov    0x8(%ebp),%edx
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	89 d7                	mov    %edx,%edi
  800adf:	fc                   	cld    
  800ae0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae2:	eb 0e                	jmp    800af2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aed:	89 d7                	mov    %edx,%edi
  800aef:	fc                   	cld    
  800af0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b10:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b13:	73 6d                	jae    800b82 <memmove+0x8a>
  800b15:	8b 45 10             	mov    0x10(%ebp),%eax
  800b18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b1b:	01 d0                	add    %edx,%eax
  800b1d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b20:	76 60                	jbe    800b82 <memmove+0x8a>
		s += n;
  800b22:	8b 45 10             	mov    0x10(%ebp),%eax
  800b25:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b28:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b31:	83 e0 03             	and    $0x3,%eax
  800b34:	85 c0                	test   %eax,%eax
  800b36:	75 2f                	jne    800b67 <memmove+0x6f>
  800b38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3b:	83 e0 03             	and    $0x3,%eax
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	75 25                	jne    800b67 <memmove+0x6f>
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	83 e0 03             	and    $0x3,%eax
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	75 1b                	jne    800b67 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4f:	83 e8 04             	sub    $0x4,%eax
  800b52:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b55:	83 ea 04             	sub    $0x4,%edx
  800b58:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b5b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b5e:	89 c7                	mov    %eax,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	fd                   	std    
  800b63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b65:	eb 18                	jmp    800b7f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b70:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 de                	mov    %ebx,%esi
  800b7a:	89 c1                	mov    %eax,%ecx
  800b7c:	fd                   	std    
  800b7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7f:	fc                   	cld    
  800b80:	eb 45                	jmp    800bc7 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b85:	83 e0 03             	and    $0x3,%eax
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	75 2b                	jne    800bb7 <memmove+0xbf>
  800b8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8f:	83 e0 03             	and    $0x3,%eax
  800b92:	85 c0                	test   %eax,%eax
  800b94:	75 21                	jne    800bb7 <memmove+0xbf>
  800b96:	8b 45 10             	mov    0x10(%ebp),%eax
  800b99:	83 e0 03             	and    $0x3,%eax
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	75 17                	jne    800bb7 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba3:	c1 e8 02             	shr    $0x2,%eax
  800ba6:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ba8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	fc                   	cld    
  800bb3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb5:	eb 10                	jmp    800bc7 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bc0:	89 c7                	mov    %eax,%edi
  800bc2:	89 d6                	mov    %edx,%esi
  800bc4:	fc                   	cld    
  800bc5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	89 04 24             	mov    %eax,(%esp)
  800bec:	e8 07 ff ff ff       	call   800af8 <memmove>
}
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c02:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c05:	eb 30                	jmp    800c37 <memcmp+0x44>
		if (*s1 != *s2)
  800c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c0a:	0f b6 10             	movzbl (%eax),%edx
  800c0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c10:	0f b6 00             	movzbl (%eax),%eax
  800c13:	38 c2                	cmp    %al,%dl
  800c15:	74 18                	je     800c2f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c17:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c1a:	0f b6 00             	movzbl (%eax),%eax
  800c1d:	0f b6 d0             	movzbl %al,%edx
  800c20:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c23:	0f b6 00             	movzbl (%eax),%eax
  800c26:	0f b6 c0             	movzbl %al,%eax
  800c29:	29 c2                	sub    %eax,%edx
  800c2b:	89 d0                	mov    %edx,%eax
  800c2d:	eb 1a                	jmp    800c49 <memcmp+0x56>
		s1++, s2++;
  800c2f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c33:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c37:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c3d:	89 55 10             	mov    %edx,0x10(%ebp)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	75 c3                	jne    800c07 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c51:	8b 45 10             	mov    0x10(%ebp),%eax
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	01 d0                	add    %edx,%eax
  800c59:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c5c:	eb 13                	jmp    800c71 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	0f b6 10             	movzbl (%eax),%edx
  800c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c67:	38 c2                	cmp    %al,%dl
  800c69:	75 02                	jne    800c6d <memfind+0x22>
			break;
  800c6b:	eb 0c                	jmp    800c79 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c6d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c77:	72 e5                	jb     800c5e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c84:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c8b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c92:	eb 04                	jmp    800c98 <strtol+0x1a>
		s++;
  800c94:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	0f b6 00             	movzbl (%eax),%eax
  800c9e:	3c 20                	cmp    $0x20,%al
  800ca0:	74 f2                	je     800c94 <strtol+0x16>
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	0f b6 00             	movzbl (%eax),%eax
  800ca8:	3c 09                	cmp    $0x9,%al
  800caa:	74 e8                	je     800c94 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	0f b6 00             	movzbl (%eax),%eax
  800cb2:	3c 2b                	cmp    $0x2b,%al
  800cb4:	75 06                	jne    800cbc <strtol+0x3e>
		s++;
  800cb6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cba:	eb 15                	jmp    800cd1 <strtol+0x53>
	else if (*s == '-')
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	0f b6 00             	movzbl (%eax),%eax
  800cc2:	3c 2d                	cmp    $0x2d,%al
  800cc4:	75 0b                	jne    800cd1 <strtol+0x53>
		s++, neg = 1;
  800cc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cca:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd5:	74 06                	je     800cdd <strtol+0x5f>
  800cd7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800cdb:	75 24                	jne    800d01 <strtol+0x83>
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	0f b6 00             	movzbl (%eax),%eax
  800ce3:	3c 30                	cmp    $0x30,%al
  800ce5:	75 1a                	jne    800d01 <strtol+0x83>
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	83 c0 01             	add    $0x1,%eax
  800ced:	0f b6 00             	movzbl (%eax),%eax
  800cf0:	3c 78                	cmp    $0x78,%al
  800cf2:	75 0d                	jne    800d01 <strtol+0x83>
		s += 2, base = 16;
  800cf4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cf8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cff:	eb 2a                	jmp    800d2b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d05:	75 17                	jne    800d1e <strtol+0xa0>
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	0f b6 00             	movzbl (%eax),%eax
  800d0d:	3c 30                	cmp    $0x30,%al
  800d0f:	75 0d                	jne    800d1e <strtol+0xa0>
		s++, base = 8;
  800d11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d15:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d1c:	eb 0d                	jmp    800d2b <strtol+0xad>
	else if (base == 0)
  800d1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d22:	75 07                	jne    800d2b <strtol+0xad>
		base = 10;
  800d24:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	0f b6 00             	movzbl (%eax),%eax
  800d31:	3c 2f                	cmp    $0x2f,%al
  800d33:	7e 1b                	jle    800d50 <strtol+0xd2>
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	0f b6 00             	movzbl (%eax),%eax
  800d3b:	3c 39                	cmp    $0x39,%al
  800d3d:	7f 11                	jg     800d50 <strtol+0xd2>
			dig = *s - '0';
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	0f b6 00             	movzbl (%eax),%eax
  800d45:	0f be c0             	movsbl %al,%eax
  800d48:	83 e8 30             	sub    $0x30,%eax
  800d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d4e:	eb 48                	jmp    800d98 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	0f b6 00             	movzbl (%eax),%eax
  800d56:	3c 60                	cmp    $0x60,%al
  800d58:	7e 1b                	jle    800d75 <strtol+0xf7>
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	0f b6 00             	movzbl (%eax),%eax
  800d60:	3c 7a                	cmp    $0x7a,%al
  800d62:	7f 11                	jg     800d75 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	0f b6 00             	movzbl (%eax),%eax
  800d6a:	0f be c0             	movsbl %al,%eax
  800d6d:	83 e8 57             	sub    $0x57,%eax
  800d70:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d73:	eb 23                	jmp    800d98 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	0f b6 00             	movzbl (%eax),%eax
  800d7b:	3c 40                	cmp    $0x40,%al
  800d7d:	7e 3d                	jle    800dbc <strtol+0x13e>
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	0f b6 00             	movzbl (%eax),%eax
  800d85:	3c 5a                	cmp    $0x5a,%al
  800d87:	7f 33                	jg     800dbc <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	0f b6 00             	movzbl (%eax),%eax
  800d8f:	0f be c0             	movsbl %al,%eax
  800d92:	83 e8 37             	sub    $0x37,%eax
  800d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d9e:	7c 02                	jl     800da2 <strtol+0x124>
			break;
  800da0:	eb 1a                	jmp    800dbc <strtol+0x13e>
		s++, val = (val * base) + dig;
  800da2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800da9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db2:	01 d0                	add    %edx,%eax
  800db4:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800db7:	e9 6f ff ff ff       	jmp    800d2b <strtol+0xad>

	if (endptr)
  800dbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc0:	74 08                	je     800dca <strtol+0x14c>
		*endptr = (char *) s;
  800dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dca:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dce:	74 07                	je     800dd7 <strtol+0x159>
  800dd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dd3:	f7 d8                	neg    %eax
  800dd5:	eb 03                	jmp    800dda <strtol+0x15c>
  800dd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 55 10             	mov    0x10(%ebp),%edx
  800deb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dee:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800df1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800df4:	8b 75 20             	mov    0x20(%ebp),%esi
  800df7:	cd 30                	int    $0x30
  800df9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e00:	74 30                	je     800e32 <syscall+0x56>
  800e02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e06:	7e 2a                	jle    800e32 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e16:	c7 44 24 08 84 1c 80 	movl   $0x801c84,0x8(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 a1 1c 80 00 	movl   $0x801ca1,(%esp)
  800e2d:	e8 c1 07 00 00       	call   8015f3 <_panic>

	return ret;
  800e32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e35:	83 c4 3c             	add    $0x3c,%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e4d:	00 
  800e4e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e55:	00 
  800e56:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e5d:	00 
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e78:	e8 5f ff ff ff       	call   800ddc <syscall>
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e85:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e94:	00 
  800e95:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eac:	00 
  800ead:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb4:	00 
  800eb5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ebc:	e8 1b ff ff ff       	call   800ddc <syscall>
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800edb:	00 
  800edc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eeb:	00 
  800eec:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ef7:	00 
  800ef8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800eff:	e8 d8 fe ff ff       	call   800ddc <syscall>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f0c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f13:	00 
  800f14:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f23:	00 
  800f24:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f33:	00 
  800f34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f3b:	00 
  800f3c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f43:	e8 94 fe ff ff       	call   800ddc <syscall>
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <sys_yield>:

void
sys_yield(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f50:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f57:	00 
  800f58:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f5f:	00 
  800f60:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f67:	00 
  800f68:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f87:	e8 50 fe ff ff       	call   800ddc <syscall>
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f94:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fac:	00 
  800fad:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fc8:	e8 0f fe ff ff       	call   800ddc <syscall>
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800fda:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fea:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fee:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ff2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801001:	00 
  801002:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801009:	e8 ce fd ff ff       	call   800ddc <syscall>
}
  80100e:	83 c4 20             	add    $0x20,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801028:	00 
  801029:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801030:	00 
  801031:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801038:	00 
  801039:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80103d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801041:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801050:	e8 87 fd ff ff       	call   800ddc <syscall>
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80105d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801060:	8b 45 08             	mov    0x8(%ebp),%eax
  801063:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80106a:	00 
  80106b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801072:	00 
  801073:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80107a:	00 
  80107b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80107f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801083:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80108a:	00 
  80108b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801092:	e8 45 fd ff ff       	call   800ddc <syscall>
}
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80109f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010bc:	00 
  8010bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010cc:	00 
  8010cd:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010d4:	e8 03 fd ff ff       	call   800ddc <syscall>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010e1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010f1:	00 
  8010f2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010f6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801101:	89 44 24 08          	mov    %eax,0x8(%esp)
  801105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80110c:	00 
  80110d:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801114:	e8 c3 fc ff ff       	call   800ddc <syscall>
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80112b:	00 
  80112c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801133:	00 
  801134:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80113b:	00 
  80113c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801143:	00 
  801144:	89 44 24 08          	mov    %eax,0x8(%esp)
  801148:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80114f:	00 
  801150:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801157:	e8 80 fc ff ff       	call   800ddc <syscall>
}
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	8b 00                	mov    (%eax),%eax
  801169:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  80116c:	8b 45 08             	mov    0x8(%ebp),%eax
  80116f:	8b 40 04             	mov    0x4(%eax),%eax
  801172:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801178:	83 e0 02             	and    $0x2,%eax
  80117b:	85 c0                	test   %eax,%eax
  80117d:	75 23                	jne    8011a2 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  80117f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801182:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801186:	c7 44 24 08 b0 1c 80 	movl   $0x801cb0,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  80119d:	e8 51 04 00 00       	call   8015f3 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  8011a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a5:	c1 e8 0c             	shr    $0xc,%eax
  8011a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8011ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b5:	25 00 08 00 00       	and    $0x800,%eax
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	75 1c                	jne    8011da <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8011be:	c7 44 24 08 ec 1c 80 	movl   $0x801cec,0x8(%esp)
  8011c5:	00 
  8011c6:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011cd:	00 
  8011ce:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  8011d5:	e8 19 04 00 00       	call   8015f3 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8011da:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011e1:	00 
  8011e2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011e9:	00 
  8011ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f1:	e8 98 fd ff ff       	call   800f8e <sys_page_alloc>
  8011f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8011f9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8011fd:	79 23                	jns    801222 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8011ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801202:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801206:	c7 44 24 08 28 1d 80 	movl   $0x801d28,0x8(%esp)
  80120d:	00 
  80120e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801215:	00 
  801216:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  80121d:	e8 d1 03 00 00       	call   8015f3 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801228:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80122b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801230:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801237:	00 
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801243:	e8 8a f9 ff ff       	call   800bd2 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801248:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80124e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801251:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801256:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80125d:	00 
  80125e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801262:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801269:	00 
  80126a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801271:	00 
  801272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801279:	e8 51 fd ff ff       	call   800fcf <sys_page_map>
  80127e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801281:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801285:	79 23                	jns    8012aa <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801287:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80128a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128e:	c7 44 24 08 60 1d 80 	movl   $0x801d60,0x8(%esp)
  801295:	00 
  801296:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80129d:	00 
  80129e:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  8012a5:	e8 49 03 00 00       	call   8015f3 <_panic>
	}

	// panic("pgfault not implemented");
}
  8012aa:	c9                   	leave  
  8012ab:	c3                   	ret    

008012ac <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	56                   	push   %esi
  8012b0:	53                   	push   %ebx
  8012b1:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8012b4:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8012bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c5:	25 00 08 00 00       	and    $0x800,%eax
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	75 15                	jne    8012e3 <duppage+0x37>
  8012ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d8:	83 e0 02             	and    $0x2,%eax
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 84 e0 00 00 00    	je     8013c3 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8012e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ed:	83 e0 04             	and    $0x4,%eax
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	74 04                	je     8012f8 <duppage+0x4c>
  8012f4:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8012f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fe:	c1 e0 0c             	shl    $0xc,%eax
  801301:	89 c1                	mov    %eax,%ecx
  801303:	8b 45 0c             	mov    0xc(%ebp),%eax
  801306:	c1 e0 0c             	shl    $0xc,%eax
  801309:	89 c2                	mov    %eax,%edx
  80130b:	a1 04 20 80 00       	mov    0x802004,%eax
  801310:	8b 40 48             	mov    0x48(%eax),%eax
  801313:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801317:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80131b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801322:	89 54 24 04          	mov    %edx,0x4(%esp)
  801326:	89 04 24             	mov    %eax,(%esp)
  801329:	e8 a1 fc ff ff       	call   800fcf <sys_page_map>
  80132e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801331:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801335:	79 23                	jns    80135a <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801337:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133e:	c7 44 24 08 94 1d 80 	movl   $0x801d94,0x8(%esp)
  801345:	00 
  801346:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80134d:	00 
  80134e:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  801355:	e8 99 02 00 00       	call   8015f3 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80135a:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80135d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801360:	c1 e0 0c             	shl    $0xc,%eax
  801363:	89 c3                	mov    %eax,%ebx
  801365:	a1 04 20 80 00       	mov    0x802004,%eax
  80136a:	8b 48 48             	mov    0x48(%eax),%ecx
  80136d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801370:	c1 e0 0c             	shl    $0xc,%eax
  801373:	89 c2                	mov    %eax,%edx
  801375:	a1 04 20 80 00       	mov    0x802004,%eax
  80137a:	8b 40 48             	mov    0x48(%eax),%eax
  80137d:	89 74 24 10          	mov    %esi,0x10(%esp)
  801381:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801385:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801389:	89 54 24 04          	mov    %edx,0x4(%esp)
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 3a fc ff ff       	call   800fcf <sys_page_map>
  801395:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801398:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80139c:	79 23                	jns    8013c1 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a5:	c7 44 24 08 d0 1d 80 	movl   $0x801dd0,0x8(%esp)
  8013ac:	00 
  8013ad:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8013b4:	00 
  8013b5:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  8013bc:	e8 32 02 00 00       	call   8015f3 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8013c1:	eb 70                	jmp    801433 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cd:	25 ff 0f 00 00       	and    $0xfff,%eax
  8013d2:	89 c3                	mov    %eax,%ebx
  8013d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d7:	c1 e0 0c             	shl    $0xc,%eax
  8013da:	89 c1                	mov    %eax,%ecx
  8013dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013df:	c1 e0 0c             	shl    $0xc,%eax
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	a1 04 20 80 00       	mov    0x802004,%eax
  8013e9:	8b 40 48             	mov    0x48(%eax),%eax
  8013ec:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013f0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013ff:	89 04 24             	mov    %eax,(%esp)
  801402:	e8 c8 fb ff ff       	call   800fcf <sys_page_map>
  801407:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80140a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80140e:	79 23                	jns    801433 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  801410:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801413:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801417:	c7 44 24 08 00 1e 80 	movl   $0x801e00,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801426:	00 
  801427:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  80142e:	e8 c0 01 00 00       	call   8015f3 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801433:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801438:	83 c4 30             	add    $0x30,%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801445:	c7 04 24 5e 11 80 00 	movl   $0x80115e,(%esp)
  80144c:	e8 fd 01 00 00       	call   80164e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801451:	b8 07 00 00 00       	mov    $0x7,%eax
  801456:	cd 30                	int    $0x30
  801458:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80145b:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80145e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  801461:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801465:	79 23                	jns    80148a <fork+0x4b>
  801467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146e:	c7 44 24 08 38 1e 80 	movl   $0x801e38,0x8(%esp)
  801475:	00 
  801476:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80147d:	00 
  80147e:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  801485:	e8 69 01 00 00       	call   8015f3 <_panic>
	else if(childeid == 0){
  80148a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80148e:	75 29                	jne    8014b9 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801490:	e8 71 fa ff ff       	call   800f06 <sys_getenvid>
  801495:	25 ff 03 00 00       	and    $0x3ff,%eax
  80149a:	c1 e0 02             	shl    $0x2,%eax
  80149d:	89 c2                	mov    %eax,%edx
  80149f:	c1 e2 05             	shl    $0x5,%edx
  8014a2:	29 c2                	sub    %eax,%edx
  8014a4:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8014aa:	a3 04 20 80 00       	mov    %eax,0x802004
		// set_pgfault_handler(pgfault);
		return 0;
  8014af:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b4:	e9 16 01 00 00       	jmp    8015cf <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8014b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8014c0:	eb 3b                	jmp    8014fd <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  8014c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c5:	c1 f8 0a             	sar    $0xa,%eax
  8014c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014cf:	83 e0 01             	and    $0x1,%eax
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	74 23                	je     8014f9 <fork+0xba>
  8014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e0:	83 e0 01             	and    $0x1,%eax
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	74 12                	je     8014f9 <fork+0xba>
			duppage(childeid, i);
  8014e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 b3 fd ff ff       	call   8012ac <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8014f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801500:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801505:	76 bb                	jbe    8014c2 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801507:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80150e:	00 
  80150f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801516:	ee 
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	89 04 24             	mov    %eax,(%esp)
  80151d:	e8 6c fa ff ff       	call   800f8e <sys_page_alloc>
  801522:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801525:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801529:	79 23                	jns    80154e <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  80152b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80152e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801532:	c7 44 24 08 60 1e 80 	movl   $0x801e60,0x8(%esp)
  801539:	00 
  80153a:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801541:	00 
  801542:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  801549:	e8 a5 00 00 00       	call   8015f3 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80154e:	c7 44 24 04 c4 16 80 	movl   $0x8016c4,0x4(%esp)
  801555:	00 
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	89 04 24             	mov    %eax,(%esp)
  80155c:	e8 38 fb ff ff       	call   801099 <sys_env_set_pgfault_upcall>
  801561:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801564:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801568:	79 23                	jns    80158d <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  80156a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80156d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801571:	c7 44 24 08 88 1e 80 	movl   $0x801e88,0x8(%esp)
  801578:	00 
  801579:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801580:	00 
  801581:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  801588:	e8 66 00 00 00       	call   8015f3 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  80158d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801594:	00 
  801595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801598:	89 04 24             	mov    %eax,(%esp)
  80159b:	e8 b7 fa ff ff       	call   801057 <sys_env_set_status>
  8015a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015a7:	79 23                	jns    8015cc <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8015a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b0:	c7 44 24 08 bc 1e 80 	movl   $0x801ebc,0x8(%esp)
  8015b7:	00 
  8015b8:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8015bf:	00 
  8015c0:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  8015c7:	e8 27 00 00 00       	call   8015f3 <_panic>
	}
	return childeid;
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <sfork>:

// Challenge!
int
sfork(void)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015d7:	c7 44 24 08 e5 1e 80 	movl   $0x801ee5,0x8(%esp)
  8015de:	00 
  8015df:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8015e6:	00 
  8015e7:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  8015ee:	e8 00 00 00 00       	call   8015f3 <_panic>

008015f3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8015fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8015fd:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801600:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801606:	e8 fb f8 ff ff       	call   800f06 <sys_getenvid>
  80160b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160e:	89 54 24 10          	mov    %edx,0x10(%esp)
  801612:	8b 55 08             	mov    0x8(%ebp),%edx
  801615:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801619:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	c7 04 24 fc 1e 80 00 	movl   $0x801efc,(%esp)
  801628:	e8 a4 eb ff ff       	call   8001d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	8b 45 10             	mov    0x10(%ebp),%eax
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	e8 2e eb ff ff       	call   80016d <vcprintf>
	cprintf("\n");
  80163f:	c7 04 24 1f 1f 80 00 	movl   $0x801f1f,(%esp)
  801646:	e8 86 eb ff ff       	call   8001d1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80164b:	cc                   	int3   
  80164c:	eb fd                	jmp    80164b <_panic+0x58>

0080164e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801654:	a1 08 20 80 00       	mov    0x802008,%eax
  801659:	85 c0                	test   %eax,%eax
  80165b:	75 5d                	jne    8016ba <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80165d:	a1 04 20 80 00       	mov    0x802004,%eax
  801662:	8b 40 48             	mov    0x48(%eax),%eax
  801665:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80166c:	00 
  80166d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801674:	ee 
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 11 f9 ff ff       	call   800f8e <sys_page_alloc>
  80167d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801680:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801684:	79 1c                	jns    8016a2 <set_pgfault_handler+0x54>
  801686:	c7 44 24 08 24 1f 80 	movl   $0x801f24,0x8(%esp)
  80168d:	00 
  80168e:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801695:	00 
  801696:	c7 04 24 50 1f 80 00 	movl   $0x801f50,(%esp)
  80169d:	e8 51 ff ff ff       	call   8015f3 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8016a2:	a1 04 20 80 00       	mov    0x802004,%eax
  8016a7:	8b 40 48             	mov    0x48(%eax),%eax
  8016aa:	c7 44 24 04 c4 16 80 	movl   $0x8016c4,0x4(%esp)
  8016b1:	00 
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 df f9 ff ff       	call   801099 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8016c4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8016c5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8016ca:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8016cc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8016cf:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8016d3:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8016d5:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8016d9:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8016da:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8016dd:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8016df:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8016e0:	58                   	pop    %eax
	popal 						// pop all the registers
  8016e1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8016e2:	83 c4 04             	add    $0x4,%esp
	popfl
  8016e5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8016e6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8016e7:	c3                   	ret    
  8016e8:	66 90                	xchg   %ax,%ax
  8016ea:	66 90                	xchg   %ax,%ax
  8016ec:	66 90                	xchg   %ax,%ax
  8016ee:	66 90                	xchg   %ax,%ax

008016f0 <__udivdi3>:
  8016f0:	55                   	push   %ebp
  8016f1:	57                   	push   %edi
  8016f2:	56                   	push   %esi
  8016f3:	83 ec 0c             	sub    $0xc,%esp
  8016f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8016fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8016fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801702:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801706:	85 c0                	test   %eax,%eax
  801708:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80170c:	89 ea                	mov    %ebp,%edx
  80170e:	89 0c 24             	mov    %ecx,(%esp)
  801711:	75 2d                	jne    801740 <__udivdi3+0x50>
  801713:	39 e9                	cmp    %ebp,%ecx
  801715:	77 61                	ja     801778 <__udivdi3+0x88>
  801717:	85 c9                	test   %ecx,%ecx
  801719:	89 ce                	mov    %ecx,%esi
  80171b:	75 0b                	jne    801728 <__udivdi3+0x38>
  80171d:	b8 01 00 00 00       	mov    $0x1,%eax
  801722:	31 d2                	xor    %edx,%edx
  801724:	f7 f1                	div    %ecx
  801726:	89 c6                	mov    %eax,%esi
  801728:	31 d2                	xor    %edx,%edx
  80172a:	89 e8                	mov    %ebp,%eax
  80172c:	f7 f6                	div    %esi
  80172e:	89 c5                	mov    %eax,%ebp
  801730:	89 f8                	mov    %edi,%eax
  801732:	f7 f6                	div    %esi
  801734:	89 ea                	mov    %ebp,%edx
  801736:	83 c4 0c             	add    $0xc,%esp
  801739:	5e                   	pop    %esi
  80173a:	5f                   	pop    %edi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    
  80173d:	8d 76 00             	lea    0x0(%esi),%esi
  801740:	39 e8                	cmp    %ebp,%eax
  801742:	77 24                	ja     801768 <__udivdi3+0x78>
  801744:	0f bd e8             	bsr    %eax,%ebp
  801747:	83 f5 1f             	xor    $0x1f,%ebp
  80174a:	75 3c                	jne    801788 <__udivdi3+0x98>
  80174c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801750:	39 34 24             	cmp    %esi,(%esp)
  801753:	0f 86 9f 00 00 00    	jbe    8017f8 <__udivdi3+0x108>
  801759:	39 d0                	cmp    %edx,%eax
  80175b:	0f 82 97 00 00 00    	jb     8017f8 <__udivdi3+0x108>
  801761:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801768:	31 d2                	xor    %edx,%edx
  80176a:	31 c0                	xor    %eax,%eax
  80176c:	83 c4 0c             	add    $0xc,%esp
  80176f:	5e                   	pop    %esi
  801770:	5f                   	pop    %edi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    
  801773:	90                   	nop
  801774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801778:	89 f8                	mov    %edi,%eax
  80177a:	f7 f1                	div    %ecx
  80177c:	31 d2                	xor    %edx,%edx
  80177e:	83 c4 0c             	add    $0xc,%esp
  801781:	5e                   	pop    %esi
  801782:	5f                   	pop    %edi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    
  801785:	8d 76 00             	lea    0x0(%esi),%esi
  801788:	89 e9                	mov    %ebp,%ecx
  80178a:	8b 3c 24             	mov    (%esp),%edi
  80178d:	d3 e0                	shl    %cl,%eax
  80178f:	89 c6                	mov    %eax,%esi
  801791:	b8 20 00 00 00       	mov    $0x20,%eax
  801796:	29 e8                	sub    %ebp,%eax
  801798:	89 c1                	mov    %eax,%ecx
  80179a:	d3 ef                	shr    %cl,%edi
  80179c:	89 e9                	mov    %ebp,%ecx
  80179e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8017a2:	8b 3c 24             	mov    (%esp),%edi
  8017a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8017a9:	89 d6                	mov    %edx,%esi
  8017ab:	d3 e7                	shl    %cl,%edi
  8017ad:	89 c1                	mov    %eax,%ecx
  8017af:	89 3c 24             	mov    %edi,(%esp)
  8017b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017b6:	d3 ee                	shr    %cl,%esi
  8017b8:	89 e9                	mov    %ebp,%ecx
  8017ba:	d3 e2                	shl    %cl,%edx
  8017bc:	89 c1                	mov    %eax,%ecx
  8017be:	d3 ef                	shr    %cl,%edi
  8017c0:	09 d7                	or     %edx,%edi
  8017c2:	89 f2                	mov    %esi,%edx
  8017c4:	89 f8                	mov    %edi,%eax
  8017c6:	f7 74 24 08          	divl   0x8(%esp)
  8017ca:	89 d6                	mov    %edx,%esi
  8017cc:	89 c7                	mov    %eax,%edi
  8017ce:	f7 24 24             	mull   (%esp)
  8017d1:	39 d6                	cmp    %edx,%esi
  8017d3:	89 14 24             	mov    %edx,(%esp)
  8017d6:	72 30                	jb     801808 <__udivdi3+0x118>
  8017d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8017dc:	89 e9                	mov    %ebp,%ecx
  8017de:	d3 e2                	shl    %cl,%edx
  8017e0:	39 c2                	cmp    %eax,%edx
  8017e2:	73 05                	jae    8017e9 <__udivdi3+0xf9>
  8017e4:	3b 34 24             	cmp    (%esp),%esi
  8017e7:	74 1f                	je     801808 <__udivdi3+0x118>
  8017e9:	89 f8                	mov    %edi,%eax
  8017eb:	31 d2                	xor    %edx,%edx
  8017ed:	e9 7a ff ff ff       	jmp    80176c <__udivdi3+0x7c>
  8017f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8017f8:	31 d2                	xor    %edx,%edx
  8017fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ff:	e9 68 ff ff ff       	jmp    80176c <__udivdi3+0x7c>
  801804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801808:	8d 47 ff             	lea    -0x1(%edi),%eax
  80180b:	31 d2                	xor    %edx,%edx
  80180d:	83 c4 0c             	add    $0xc,%esp
  801810:	5e                   	pop    %esi
  801811:	5f                   	pop    %edi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    
  801814:	66 90                	xchg   %ax,%ax
  801816:	66 90                	xchg   %ax,%ax
  801818:	66 90                	xchg   %ax,%ax
  80181a:	66 90                	xchg   %ax,%ax
  80181c:	66 90                	xchg   %ax,%ax
  80181e:	66 90                	xchg   %ax,%ax

00801820 <__umoddi3>:
  801820:	55                   	push   %ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	83 ec 14             	sub    $0x14,%esp
  801826:	8b 44 24 28          	mov    0x28(%esp),%eax
  80182a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80182e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801832:	89 c7                	mov    %eax,%edi
  801834:	89 44 24 04          	mov    %eax,0x4(%esp)
  801838:	8b 44 24 30          	mov    0x30(%esp),%eax
  80183c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801840:	89 34 24             	mov    %esi,(%esp)
  801843:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801847:	85 c0                	test   %eax,%eax
  801849:	89 c2                	mov    %eax,%edx
  80184b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80184f:	75 17                	jne    801868 <__umoddi3+0x48>
  801851:	39 fe                	cmp    %edi,%esi
  801853:	76 4b                	jbe    8018a0 <__umoddi3+0x80>
  801855:	89 c8                	mov    %ecx,%eax
  801857:	89 fa                	mov    %edi,%edx
  801859:	f7 f6                	div    %esi
  80185b:	89 d0                	mov    %edx,%eax
  80185d:	31 d2                	xor    %edx,%edx
  80185f:	83 c4 14             	add    $0x14,%esp
  801862:	5e                   	pop    %esi
  801863:	5f                   	pop    %edi
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    
  801866:	66 90                	xchg   %ax,%ax
  801868:	39 f8                	cmp    %edi,%eax
  80186a:	77 54                	ja     8018c0 <__umoddi3+0xa0>
  80186c:	0f bd e8             	bsr    %eax,%ebp
  80186f:	83 f5 1f             	xor    $0x1f,%ebp
  801872:	75 5c                	jne    8018d0 <__umoddi3+0xb0>
  801874:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801878:	39 3c 24             	cmp    %edi,(%esp)
  80187b:	0f 87 e7 00 00 00    	ja     801968 <__umoddi3+0x148>
  801881:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801885:	29 f1                	sub    %esi,%ecx
  801887:	19 c7                	sbb    %eax,%edi
  801889:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80188d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801891:	8b 44 24 08          	mov    0x8(%esp),%eax
  801895:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801899:	83 c4 14             	add    $0x14,%esp
  80189c:	5e                   	pop    %esi
  80189d:	5f                   	pop    %edi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    
  8018a0:	85 f6                	test   %esi,%esi
  8018a2:	89 f5                	mov    %esi,%ebp
  8018a4:	75 0b                	jne    8018b1 <__umoddi3+0x91>
  8018a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ab:	31 d2                	xor    %edx,%edx
  8018ad:	f7 f6                	div    %esi
  8018af:	89 c5                	mov    %eax,%ebp
  8018b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8018b5:	31 d2                	xor    %edx,%edx
  8018b7:	f7 f5                	div    %ebp
  8018b9:	89 c8                	mov    %ecx,%eax
  8018bb:	f7 f5                	div    %ebp
  8018bd:	eb 9c                	jmp    80185b <__umoddi3+0x3b>
  8018bf:	90                   	nop
  8018c0:	89 c8                	mov    %ecx,%eax
  8018c2:	89 fa                	mov    %edi,%edx
  8018c4:	83 c4 14             	add    $0x14,%esp
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    
  8018cb:	90                   	nop
  8018cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018d0:	8b 04 24             	mov    (%esp),%eax
  8018d3:	be 20 00 00 00       	mov    $0x20,%esi
  8018d8:	89 e9                	mov    %ebp,%ecx
  8018da:	29 ee                	sub    %ebp,%esi
  8018dc:	d3 e2                	shl    %cl,%edx
  8018de:	89 f1                	mov    %esi,%ecx
  8018e0:	d3 e8                	shr    %cl,%eax
  8018e2:	89 e9                	mov    %ebp,%ecx
  8018e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e8:	8b 04 24             	mov    (%esp),%eax
  8018eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8018ef:	89 fa                	mov    %edi,%edx
  8018f1:	d3 e0                	shl    %cl,%eax
  8018f3:	89 f1                	mov    %esi,%ecx
  8018f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8018fd:	d3 ea                	shr    %cl,%edx
  8018ff:	89 e9                	mov    %ebp,%ecx
  801901:	d3 e7                	shl    %cl,%edi
  801903:	89 f1                	mov    %esi,%ecx
  801905:	d3 e8                	shr    %cl,%eax
  801907:	89 e9                	mov    %ebp,%ecx
  801909:	09 f8                	or     %edi,%eax
  80190b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80190f:	f7 74 24 04          	divl   0x4(%esp)
  801913:	d3 e7                	shl    %cl,%edi
  801915:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801919:	89 d7                	mov    %edx,%edi
  80191b:	f7 64 24 08          	mull   0x8(%esp)
  80191f:	39 d7                	cmp    %edx,%edi
  801921:	89 c1                	mov    %eax,%ecx
  801923:	89 14 24             	mov    %edx,(%esp)
  801926:	72 2c                	jb     801954 <__umoddi3+0x134>
  801928:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80192c:	72 22                	jb     801950 <__umoddi3+0x130>
  80192e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801932:	29 c8                	sub    %ecx,%eax
  801934:	19 d7                	sbb    %edx,%edi
  801936:	89 e9                	mov    %ebp,%ecx
  801938:	89 fa                	mov    %edi,%edx
  80193a:	d3 e8                	shr    %cl,%eax
  80193c:	89 f1                	mov    %esi,%ecx
  80193e:	d3 e2                	shl    %cl,%edx
  801940:	89 e9                	mov    %ebp,%ecx
  801942:	d3 ef                	shr    %cl,%edi
  801944:	09 d0                	or     %edx,%eax
  801946:	89 fa                	mov    %edi,%edx
  801948:	83 c4 14             	add    $0x14,%esp
  80194b:	5e                   	pop    %esi
  80194c:	5f                   	pop    %edi
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    
  80194f:	90                   	nop
  801950:	39 d7                	cmp    %edx,%edi
  801952:	75 da                	jne    80192e <__umoddi3+0x10e>
  801954:	8b 14 24             	mov    (%esp),%edx
  801957:	89 c1                	mov    %eax,%ecx
  801959:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80195d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801961:	eb cb                	jmp    80192e <__umoddi3+0x10e>
  801963:	90                   	nop
  801964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801968:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80196c:	0f 82 0f ff ff ff    	jb     801881 <__umoddi3+0x61>
  801972:	e9 1a ff ff ff       	jmp    801891 <__umoddi3+0x71>