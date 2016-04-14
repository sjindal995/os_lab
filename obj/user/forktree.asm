
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 c1 00 00 00       	call   8000f2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 38             	sub    $0x38,%esp
  800039:	8b 45 0c             	mov    0xc(%ebp),%eax
  80003c:	88 45 e4             	mov    %al,-0x1c(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80003f:	8b 45 08             	mov    0x8(%ebp),%eax
  800042:	89 04 24             	mov    %eax,(%esp)
  800045:	e8 42 08 00 00       	call   80088c <strlen>
  80004a:	83 f8 02             	cmp    $0x2,%eax
  80004d:	7f 43                	jg     800092 <forkchild+0x5f>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80004f:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800053:	89 44 24 10          	mov    %eax,0x10(%esp)
  800057:	8b 45 08             	mov    0x8(%ebp),%eax
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 c0 19 80 	movl   $0x8019c0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80006d:	00 
  80006e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800071:	89 04 24             	mov    %eax,(%esp)
  800074:	e8 df 07 00 00       	call   800858 <snprintf>
	if (fork() == 0) {
  800079:	e8 05 14 00 00       	call   801483 <fork>
  80007e:	85 c0                	test   %eax,%eax
  800080:	75 10                	jne    800092 <forkchild+0x5f>
		forktree(nxt);
  800082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 07 00 00 00       	call   800094 <forktree>
		exit();
  80008d:	e8 af 00 00 00       	call   800141 <exit>
	}
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <forktree>:

void
forktree(const char *cur)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80009a:	e8 ab 0e 00 00       	call   800f4a <sys_getenvid>
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	c7 04 24 c5 19 80 00 	movl   $0x8019c5,(%esp)
  8000b1:	e8 5f 01 00 00       	call   800215 <cprintf>

	forkchild(cur, '0');
  8000b6:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8000bd:	00 
  8000be:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c1:	89 04 24             	mov    %eax,(%esp)
  8000c4:	e8 6a ff ff ff       	call   800033 <forkchild>
	forkchild(cur, '1');
  8000c9:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8000d0:	00 
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d4:	89 04 24             	mov    %eax,(%esp)
  8000d7:	e8 57 ff ff ff       	call   800033 <forkchild>
}
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    

008000de <umain>:

void
umain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e4:	c7 04 24 d6 19 80 00 	movl   $0x8019d6,(%esp)
  8000eb:	e8 a4 ff ff ff       	call   800094 <forktree>
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000f8:	e8 4d 0e 00 00       	call   800f4a <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	c1 e0 02             	shl    $0x2,%eax
  800105:	89 c2                	mov    %eax,%edx
  800107:	c1 e2 05             	shl    $0x5,%edx
  80010a:	29 c2                	sub    %eax,%edx
  80010c:	89 d0                	mov    %edx,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80011c:	7e 0a                	jle    800128 <libmain+0x36>
		binaryname = argv[0];
  80011e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800121:	8b 00                	mov    (%eax),%eax
  800123:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	8b 45 08             	mov    0x8(%ebp),%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 a4 ff ff ff       	call   8000de <umain>

	// exit gracefully
	exit();
  80013a:	e8 02 00 00 00       	call   800141 <exit>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 b4 0d 00 00       	call   800f07 <sys_env_destroy>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80015b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015e:	8b 00                	mov    (%eax),%eax
  800160:	8d 48 01             	lea    0x1(%eax),%ecx
  800163:	8b 55 0c             	mov    0xc(%ebp),%edx
  800166:	89 0a                	mov    %ecx,(%edx)
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	8b 00                	mov    (%eax),%eax
  800179:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017e:	75 20                	jne    8001a0 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800180:	8b 45 0c             	mov    0xc(%ebp),%eax
  800183:	8b 00                	mov    (%eax),%eax
  800185:	8b 55 0c             	mov    0xc(%ebp),%edx
  800188:	83 c2 08             	add    $0x8,%edx
  80018b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018f:	89 14 24             	mov    %edx,(%esp)
  800192:	e8 ea 0c 00 00       	call   800e81 <sys_cputs>
		b->idx = 0;
  800197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a3:	8b 40 04             	mov    0x4(%eax),%eax
  8001a6:	8d 50 01             	lea    0x1(%eax),%edx
  8001a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ac:	89 50 04             	mov    %edx,0x4(%eax)
}
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c1:	00 00 00 
	b.cnt = 0;
  8001c4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	c7 04 24 55 01 80 00 	movl   $0x800155,(%esp)
  8001ed:	e8 bd 01 00 00       	call   8003af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800202:	83 c0 08             	add    $0x8,%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 74 0c 00 00       	call   800e81 <sys_cputs>

	return b.cnt;
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80021e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800221:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800224:	89 44 24 04          	mov    %eax,0x4(%esp)
  800228:	8b 45 08             	mov    0x8(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	e8 7e ff ff ff       	call   8001b1 <vcprintf>
  800233:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800236:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	53                   	push   %ebx
  80023f:	83 ec 34             	sub    $0x34,%esp
  800242:	8b 45 10             	mov    0x10(%ebp),%eax
  800245:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800248:	8b 45 14             	mov    0x14(%ebp),%eax
  80024b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024e:	8b 45 18             	mov    0x18(%ebp),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
  800256:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800259:	77 72                	ja     8002cd <printnum+0x92>
  80025b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80025e:	72 05                	jb     800265 <printnum+0x2a>
  800260:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800263:	77 68                	ja     8002cd <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800265:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800268:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026b:	8b 45 18             	mov    0x18(%ebp),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	89 44 24 08          	mov    %eax,0x8(%esp)
  800277:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80027e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	89 54 24 04          	mov    %edx,0x4(%esp)
  800288:	e8 a3 14 00 00       	call   801730 <__udivdi3>
  80028d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800290:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800294:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800298:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80029b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 82 ff ff ff       	call   80023b <printnum>
  8002b9:	eb 1c                	jmp    8002d7 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c2:	8b 45 20             	mov    0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cb:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cd:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002d1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002d5:	7f e4                	jg     8002bb <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d7:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002e5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f4:	e8 67 15 00 00       	call   801860 <__umoddi3>
  8002f9:	05 c8 1a 80 00       	add    $0x801ac8,%eax
  8002fe:	0f b6 00             	movzbl (%eax),%eax
  800301:	0f be c0             	movsbl %al,%eax
  800304:	8b 55 0c             	mov    0xc(%ebp),%edx
  800307:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	ff d0                	call   *%eax
}
  800313:	83 c4 34             	add    $0x34,%esp
  800316:	5b                   	pop    %ebx
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800320:	7e 14                	jle    800336 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	8b 00                	mov    (%eax),%eax
  800327:	8d 48 08             	lea    0x8(%eax),%ecx
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	89 0a                	mov    %ecx,(%edx)
  80032f:	8b 50 04             	mov    0x4(%eax),%edx
  800332:	8b 00                	mov    (%eax),%eax
  800334:	eb 30                	jmp    800366 <getuint+0x4d>
	else if (lflag)
  800336:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80033a:	74 16                	je     800352 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	8d 48 04             	lea    0x4(%eax),%ecx
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 0a                	mov    %ecx,(%edx)
  800349:	8b 00                	mov    (%eax),%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	eb 14                	jmp    800366 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	8d 48 04             	lea    0x4(%eax),%ecx
  80035a:	8b 55 08             	mov    0x8(%ebp),%edx
  80035d:	89 0a                	mov    %ecx,(%edx)
  80035f:	8b 00                	mov    (%eax),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80036f:	7e 14                	jle    800385 <getint+0x1d>
		return va_arg(*ap, long long);
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	8b 00                	mov    (%eax),%eax
  800376:	8d 48 08             	lea    0x8(%eax),%ecx
  800379:	8b 55 08             	mov    0x8(%ebp),%edx
  80037c:	89 0a                	mov    %ecx,(%edx)
  80037e:	8b 50 04             	mov    0x4(%eax),%edx
  800381:	8b 00                	mov    (%eax),%eax
  800383:	eb 28                	jmp    8003ad <getint+0x45>
	else if (lflag)
  800385:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800389:	74 12                	je     80039d <getint+0x35>
		return va_arg(*ap, long);
  80038b:	8b 45 08             	mov    0x8(%ebp),%eax
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	89 0a                	mov    %ecx,(%edx)
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	99                   	cltd   
  80039b:	eb 10                	jmp    8003ad <getint+0x45>
	else
		return va_arg(*ap, int);
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	8b 00                	mov    (%eax),%eax
  8003a2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 0a                	mov    %ecx,(%edx)
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	99                   	cltd   
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b7:	eb 18                	jmp    8003d1 <vprintfmt+0x22>
			if (ch == '\0')
  8003b9:	85 db                	test   %ebx,%ebx
  8003bb:	75 05                	jne    8003c2 <vprintfmt+0x13>
				return;
  8003bd:	e9 cc 03 00 00       	jmp    80078e <vprintfmt+0x3df>
			putch(ch, putdat);
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c9:	89 1c 24             	mov    %ebx,(%esp)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d4:	8d 50 01             	lea    0x1(%eax),%edx
  8003d7:	89 55 10             	mov    %edx,0x10(%ebp)
  8003da:	0f b6 00             	movzbl (%eax),%eax
  8003dd:	0f b6 d8             	movzbl %al,%ebx
  8003e0:	83 fb 25             	cmp    $0x25,%ebx
  8003e3:	75 d4                	jne    8003b9 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003e5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003e9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 45 10             	mov    0x10(%ebp),%eax
  800408:	8d 50 01             	lea    0x1(%eax),%edx
  80040b:	89 55 10             	mov    %edx,0x10(%ebp)
  80040e:	0f b6 00             	movzbl (%eax),%eax
  800411:	0f b6 d8             	movzbl %al,%ebx
  800414:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800417:	83 f8 55             	cmp    $0x55,%eax
  80041a:	0f 87 3d 03 00 00    	ja     80075d <vprintfmt+0x3ae>
  800420:	8b 04 85 ec 1a 80 00 	mov    0x801aec(,%eax,4),%eax
  800427:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800429:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80042d:	eb d6                	jmp    800405 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800433:	eb d0                	jmp    800405 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800435:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80043c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043f:	89 d0                	mov    %edx,%eax
  800441:	c1 e0 02             	shl    $0x2,%eax
  800444:	01 d0                	add    %edx,%eax
  800446:	01 c0                	add    %eax,%eax
  800448:	01 d8                	add    %ebx,%eax
  80044a:	83 e8 30             	sub    $0x30,%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800450:	8b 45 10             	mov    0x10(%ebp),%eax
  800453:	0f b6 00             	movzbl (%eax),%eax
  800456:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800459:	83 fb 2f             	cmp    $0x2f,%ebx
  80045c:	7e 0b                	jle    800469 <vprintfmt+0xba>
  80045e:	83 fb 39             	cmp    $0x39,%ebx
  800461:	7f 06                	jg     800469 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800467:	eb d3                	jmp    80043c <vprintfmt+0x8d>
			goto process_precision;
  800469:	eb 33                	jmp    80049e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	8b 00                	mov    (%eax),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800479:	eb 23                	jmp    80049e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80047b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047f:	79 0c                	jns    80048d <vprintfmt+0xde>
				width = 0;
  800481:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800488:	e9 78 ff ff ff       	jmp    800405 <vprintfmt+0x56>
  80048d:	e9 73 ff ff ff       	jmp    800405 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800499:	e9 67 ff ff ff       	jmp    800405 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80049e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004a2:	79 12                	jns    8004b6 <vprintfmt+0x107>
				width = precision, precision = -1;
  8004a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004aa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8004b1:	e9 4f ff ff ff       	jmp    800405 <vprintfmt+0x56>
  8004b6:	e9 4a ff ff ff       	jmp    800405 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bb:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8004bf:	e9 41 ff ff ff       	jmp    800405 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004d6:	89 04 24             	mov    %eax,(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	ff d0                	call   *%eax
			break;
  8004de:	e9 a5 02 00 00       	jmp    800788 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 50 04             	lea    0x4(%eax),%edx
  8004e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ec:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004ee:	85 db                	test   %ebx,%ebx
  8004f0:	79 02                	jns    8004f4 <vprintfmt+0x145>
				err = -err;
  8004f2:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f4:	83 fb 09             	cmp    $0x9,%ebx
  8004f7:	7f 0b                	jg     800504 <vprintfmt+0x155>
  8004f9:	8b 34 9d a0 1a 80 00 	mov    0x801aa0(,%ebx,4),%esi
  800500:	85 f6                	test   %esi,%esi
  800502:	75 23                	jne    800527 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800504:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800508:	c7 44 24 08 d9 1a 80 	movl   $0x801ad9,0x8(%esp)
  80050f:	00 
  800510:	8b 45 0c             	mov    0xc(%ebp),%eax
  800513:	89 44 24 04          	mov    %eax,0x4(%esp)
  800517:	8b 45 08             	mov    0x8(%ebp),%eax
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	e8 73 02 00 00       	call   800795 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800522:	e9 61 02 00 00       	jmp    800788 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800527:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80052b:	c7 44 24 08 e2 1a 80 	movl   $0x801ae2,0x8(%esp)
  800532:	00 
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
  800536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 50 02 00 00       	call   800795 <printfmt>
			break;
  800545:	e9 3e 02 00 00       	jmp    800788 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 30                	mov    (%eax),%esi
  800555:	85 f6                	test   %esi,%esi
  800557:	75 05                	jne    80055e <vprintfmt+0x1af>
				p = "(null)";
  800559:	be e5 1a 80 00       	mov    $0x801ae5,%esi
			if (width > 0 && padc != '-')
  80055e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800562:	7e 37                	jle    80059b <vprintfmt+0x1ec>
  800564:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800568:	74 31                	je     80059b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 39 03 00 00       	call   8008b2 <strnlen>
  800579:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80057c:	eb 17                	jmp    800595 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80057e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800582:	8b 55 0c             	mov    0xc(%ebp),%edx
  800585:	89 54 24 04          	mov    %edx,0x4(%esp)
  800589:	89 04 24             	mov    %eax,(%esp)
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800595:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800599:	7f e3                	jg     80057e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059b:	eb 38                	jmp    8005d5 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80059d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a1:	74 1f                	je     8005c2 <vprintfmt+0x213>
  8005a3:	83 fb 1f             	cmp    $0x1f,%ebx
  8005a6:	7e 05                	jle    8005ad <vprintfmt+0x1fe>
  8005a8:	83 fb 7e             	cmp    $0x7e,%ebx
  8005ab:	7e 15                	jle    8005c2 <vprintfmt+0x213>
					putch('?', putdat);
  8005ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005be:	ff d0                	call   *%eax
  8005c0:	eb 0f                	jmp    8005d1 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c9:	89 1c 24             	mov    %ebx,(%esp)
  8005cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cf:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d5:	89 f0                	mov    %esi,%eax
  8005d7:	8d 70 01             	lea    0x1(%eax),%esi
  8005da:	0f b6 00             	movzbl (%eax),%eax
  8005dd:	0f be d8             	movsbl %al,%ebx
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	74 10                	je     8005f4 <vprintfmt+0x245>
  8005e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e8:	78 b3                	js     80059d <vprintfmt+0x1ee>
  8005ea:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f2:	79 a9                	jns    80059d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f4:	eb 17                	jmp    80060d <vprintfmt+0x25e>
				putch(' ', putdat);
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800609:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80060d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800611:	7f e3                	jg     8005f6 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800613:	e9 70 01 00 00       	jmp    800788 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800618:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	e8 3e fd ff ff       	call   800368 <getint>
  80062a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80062d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800630:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800633:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800636:	85 d2                	test   %edx,%edx
  800638:	79 26                	jns    800660 <vprintfmt+0x2b1>
				putch('-', putdat);
  80063a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	ff d0                	call   *%eax
				num = -(long long) num;
  80064d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800650:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800653:	f7 d8                	neg    %eax
  800655:	83 d2 00             	adc    $0x0,%edx
  800658:	f7 da                	neg    %edx
  80065a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80065d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800660:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800667:	e9 a8 00 00 00       	jmp    800714 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80066f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	e8 9b fc ff ff       	call   800319 <getuint>
  80067e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800681:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800684:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80068b:	e9 84 00 00 00       	jmp    800714 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800690:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800693:	89 44 24 04          	mov    %eax,0x4(%esp)
  800697:	8d 45 14             	lea    0x14(%ebp),%eax
  80069a:	89 04 24             	mov    %eax,(%esp)
  80069d:	e8 77 fc ff ff       	call   800319 <getuint>
  8006a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8006a8:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8006af:	eb 63                	jmp    800714 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	ff d0                	call   *%eax
			putch('x', putdat);
  8006c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e0:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ec:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006f3:	eb 1f                	jmp    800714 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 12 fc ff ff       	call   800319 <getuint>
  800707:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80070d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800714:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80071f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800722:	89 54 24 14          	mov    %edx,0x14(%esp)
  800726:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800730:	89 44 24 08          	mov    %eax,0x8(%esp)
  800734:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073f:	8b 45 08             	mov    0x8(%ebp),%eax
  800742:	89 04 24             	mov    %eax,(%esp)
  800745:	e8 f1 fa ff ff       	call   80023b <printnum>
			break;
  80074a:	eb 3c                	jmp    800788 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800753:	89 1c 24             	mov    %ebx,(%esp)
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	ff d0                	call   *%eax
			break;
  80075b:	eb 2b                	jmp    800788 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800770:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800774:	eb 04                	jmp    80077a <vprintfmt+0x3cb>
  800776:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80077a:	8b 45 10             	mov    0x10(%ebp),%eax
  80077d:	83 e8 01             	sub    $0x1,%eax
  800780:	0f b6 00             	movzbl (%eax),%eax
  800783:	3c 25                	cmp    $0x25,%al
  800785:	75 ef                	jne    800776 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800787:	90                   	nop
		}
	}
  800788:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800789:	e9 43 fc ff ff       	jmp    8003d1 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80078e:	83 c4 40             	add    $0x40,%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	89 04 24             	mov    %eax,(%esp)
  8007bc:	e8 ee fb ff ff       	call   8003af <vprintfmt>
	va_end(ap);
}
  8007c1:	c9                   	leave  
  8007c2:	c3                   	ret    

008007c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c9:	8b 40 08             	mov    0x8(%eax),%eax
  8007cc:	8d 50 01             	lea    0x1(%eax),%edx
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d2:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d8:	8b 10                	mov    (%eax),%edx
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dd:	8b 40 04             	mov    0x4(%eax),%eax
  8007e0:	39 c2                	cmp    %eax,%edx
  8007e2:	73 12                	jae    8007f6 <sprintputch+0x33>
		*b->buf++ = ch;
  8007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e7:	8b 00                	mov    (%eax),%eax
  8007e9:	8d 48 01             	lea    0x1(%eax),%ecx
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	89 0a                	mov    %ecx,(%edx)
  8007f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f4:	88 10                	mov    %dl,(%eax)
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800804:	8b 45 0c             	mov    0xc(%ebp),%eax
  800807:	8d 50 ff             	lea    -0x1(%eax),%edx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	01 d0                	add    %edx,%eax
  80080f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800812:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800819:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80081d:	74 06                	je     800825 <vsnprintf+0x2d>
  80081f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800823:	7f 07                	jg     80082c <vsnprintf+0x34>
		return -E_INVAL;
  800825:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082a:	eb 2a                	jmp    800856 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800833:	8b 45 10             	mov    0x10(%ebp),%eax
  800836:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800841:	c7 04 24 c3 07 80 00 	movl   $0x8007c3,(%esp)
  800848:	e8 62 fb ff ff       	call   8003af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
  800861:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800864:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800867:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086b:	8b 45 10             	mov    0x10(%ebp),%eax
  80086e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800872:	8b 45 0c             	mov    0xc(%ebp),%eax
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	e8 74 ff ff ff       	call   8007f8 <vsnprintf>
  800884:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800887:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800892:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800899:	eb 08                	jmp    8008a3 <strlen+0x17>
		n++;
  80089b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80089f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 00             	movzbl (%eax),%eax
  8008a9:	84 c0                	test   %al,%al
  8008ab:	75 ee                	jne    80089b <strlen+0xf>
		n++;
	return n;
  8008ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008bf:	eb 0c                	jmp    8008cd <strnlen+0x1b>
		n++;
  8008c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008c9:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008d1:	74 0a                	je     8008dd <strnlen+0x2b>
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	0f b6 00             	movzbl (%eax),%eax
  8008d9:	84 c0                	test   %al,%al
  8008db:	75 e4                	jne    8008c1 <strnlen+0xf>
		n++;
	return n;
  8008dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008ee:	90                   	nop
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8d 50 01             	lea    0x1(%eax),%edx
  8008f5:	89 55 08             	mov    %edx,0x8(%ebp)
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008fe:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	88 10                	mov    %dl,(%eax)
  800906:	0f b6 00             	movzbl (%eax),%eax
  800909:	84 c0                	test   %al,%al
  80090b:	75 e2                	jne    8008ef <strcpy+0xd>
		/* do nothing */;
	return ret;
  80090d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800910:	c9                   	leave  
  800911:	c3                   	ret    

00800912 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	e8 69 ff ff ff       	call   80088c <strlen>
  800923:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800926:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	01 c2                	add    %eax,%edx
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	89 14 24             	mov    %edx,(%esp)
  800938:	e8 a5 ff ff ff       	call   8008e2 <strcpy>
	return dst;
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80094e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800955:	eb 23                	jmp    80097a <strncpy+0x38>
		*dst++ = *src;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8d 50 01             	lea    0x1(%eax),%edx
  80095d:	89 55 08             	mov    %edx,0x8(%ebp)
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
  800963:	0f b6 12             	movzbl (%edx),%edx
  800966:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	0f b6 00             	movzbl (%eax),%eax
  80096e:	84 c0                	test   %al,%al
  800970:	74 04                	je     800976 <strncpy+0x34>
			src++;
  800972:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800976:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80097a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80097d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800980:	72 d5                	jb     800957 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800982:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800993:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800997:	74 33                	je     8009cc <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800999:	eb 17                	jmp    8009b2 <strlcpy+0x2b>
			*dst++ = *src++;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8d 50 01             	lea    0x1(%eax),%edx
  8009a1:	89 55 08             	mov    %edx,0x8(%ebp)
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009aa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009ad:	0f b6 12             	movzbl (%edx),%edx
  8009b0:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009ba:	74 0a                	je     8009c6 <strlcpy+0x3f>
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	0f b6 00             	movzbl (%eax),%eax
  8009c2:	84 c0                	test   %al,%al
  8009c4:	75 d5                	jne    80099b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009d2:	29 c2                	sub    %eax,%edx
  8009d4:	89 d0                	mov    %edx,%eax
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009db:	eb 08                	jmp    8009e5 <strcmp+0xd>
		p++, q++;
  8009dd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009e1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	84 c0                	test   %al,%al
  8009ed:	74 10                	je     8009ff <strcmp+0x27>
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	0f b6 10             	movzbl (%eax),%edx
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	0f b6 00             	movzbl (%eax),%eax
  8009fb:	38 c2                	cmp    %al,%dl
  8009fd:	74 de                	je     8009dd <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	0f b6 00             	movzbl (%eax),%eax
  800a05:	0f b6 d0             	movzbl %al,%edx
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	0f b6 00             	movzbl (%eax),%eax
  800a0e:	0f b6 c0             	movzbl %al,%eax
  800a11:	29 c2                	sub    %eax,%edx
  800a13:	89 d0                	mov    %edx,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a1a:	eb 0c                	jmp    800a28 <strncmp+0x11>
		n--, p++, q++;
  800a1c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a20:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a24:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a2c:	74 1a                	je     800a48 <strncmp+0x31>
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 00             	movzbl (%eax),%eax
  800a34:	84 c0                	test   %al,%al
  800a36:	74 10                	je     800a48 <strncmp+0x31>
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	0f b6 10             	movzbl (%eax),%edx
  800a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a41:	0f b6 00             	movzbl (%eax),%eax
  800a44:	38 c2                	cmp    %al,%dl
  800a46:	74 d4                	je     800a1c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a4c:	75 07                	jne    800a55 <strncmp+0x3e>
		return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	eb 16                	jmp    800a6b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	0f b6 00             	movzbl (%eax),%eax
  800a5b:	0f b6 d0             	movzbl %al,%edx
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	0f b6 00             	movzbl (%eax),%eax
  800a64:	0f b6 c0             	movzbl %al,%eax
  800a67:	29 c2                	sub    %eax,%edx
  800a69:	89 d0                	mov    %edx,%eax
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	83 ec 04             	sub    $0x4,%esp
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a79:	eb 14                	jmp    800a8f <strchr+0x22>
		if (*s == c)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a84:	75 05                	jne    800a8b <strchr+0x1e>
			return (char *) s;
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	eb 13                	jmp    800a9e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	0f b6 00             	movzbl (%eax),%eax
  800a95:	84 c0                	test   %al,%al
  800a97:	75 e2                	jne    800a7b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	83 ec 04             	sub    $0x4,%esp
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aac:	eb 11                	jmp    800abf <strfind+0x1f>
		if (*s == c)
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 00             	movzbl (%eax),%eax
  800ab4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ab7:	75 02                	jne    800abb <strfind+0x1b>
			break;
  800ab9:	eb 0e                	jmp    800ac9 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800abb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	84 c0                	test   %al,%al
  800ac7:	75 e5                	jne    800aae <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ad2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ad6:	75 05                	jne    800add <memset+0xf>
		return v;
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	eb 5c                	jmp    800b39 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	83 e0 03             	and    $0x3,%eax
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	75 41                	jne    800b28 <memset+0x5a>
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	83 e0 03             	and    $0x3,%eax
  800aed:	85 c0                	test   %eax,%eax
  800aef:	75 37                	jne    800b28 <memset+0x5a>
		c &= 0xFF;
  800af1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	c1 e0 18             	shl    $0x18,%eax
  800afe:	89 c2                	mov    %eax,%edx
  800b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b03:	c1 e0 10             	shl    $0x10,%eax
  800b06:	09 c2                	or     %eax,%edx
  800b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0b:	c1 e0 08             	shl    $0x8,%eax
  800b0e:	09 d0                	or     %edx,%eax
  800b10:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b13:	8b 45 10             	mov    0x10(%ebp),%eax
  800b16:	c1 e8 02             	shr    $0x2,%eax
  800b19:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	89 d7                	mov    %edx,%edi
  800b23:	fc                   	cld    
  800b24:	f3 ab                	rep stos %eax,%es:(%edi)
  800b26:	eb 0e                	jmp    800b36 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b28:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	fc                   	cld    
  800b34:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b54:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b57:	73 6d                	jae    800bc6 <memmove+0x8a>
  800b59:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b5f:	01 d0                	add    %edx,%eax
  800b61:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b64:	76 60                	jbe    800bc6 <memmove+0x8a>
		s += n;
  800b66:	8b 45 10             	mov    0x10(%ebp),%eax
  800b69:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b75:	83 e0 03             	and    $0x3,%eax
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	75 2f                	jne    800bab <memmove+0x6f>
  800b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b7f:	83 e0 03             	and    $0x3,%eax
  800b82:	85 c0                	test   %eax,%eax
  800b84:	75 25                	jne    800bab <memmove+0x6f>
  800b86:	8b 45 10             	mov    0x10(%ebp),%eax
  800b89:	83 e0 03             	and    $0x3,%eax
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	75 1b                	jne    800bab <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b93:	83 e8 04             	sub    $0x4,%eax
  800b96:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b99:	83 ea 04             	sub    $0x4,%edx
  800b9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	fd                   	std    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 18                	jmp    800bc3 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bae:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb4:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 de                	mov    %ebx,%esi
  800bbe:	89 c1                	mov    %eax,%ecx
  800bc0:	fd                   	std    
  800bc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc3:	fc                   	cld    
  800bc4:	eb 45                	jmp    800c0b <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc9:	83 e0 03             	and    $0x3,%eax
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	75 2b                	jne    800bfb <memmove+0xbf>
  800bd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd3:	83 e0 03             	and    $0x3,%eax
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	75 21                	jne    800bfb <memmove+0xbf>
  800bda:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdd:	83 e0 03             	and    $0x3,%eax
  800be0:	85 c0                	test   %eax,%eax
  800be2:	75 17                	jne    800bfb <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be4:	8b 45 10             	mov    0x10(%ebp),%eax
  800be7:	c1 e8 02             	shr    $0x2,%eax
  800bea:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	fc                   	cld    
  800bf7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf9:	eb 10                	jmp    800c0b <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bfe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c01:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	fc                   	cld    
  800c09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 07 ff ff ff       	call   800b3c <memmove>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c46:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c49:	eb 30                	jmp    800c7b <memcmp+0x44>
		if (*s1 != *s2)
  800c4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c4e:	0f b6 10             	movzbl (%eax),%edx
  800c51:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c54:	0f b6 00             	movzbl (%eax),%eax
  800c57:	38 c2                	cmp    %al,%dl
  800c59:	74 18                	je     800c73 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c5e:	0f b6 00             	movzbl (%eax),%eax
  800c61:	0f b6 d0             	movzbl %al,%edx
  800c64:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c67:	0f b6 00             	movzbl (%eax),%eax
  800c6a:	0f b6 c0             	movzbl %al,%eax
  800c6d:	29 c2                	sub    %eax,%edx
  800c6f:	89 d0                	mov    %edx,%eax
  800c71:	eb 1a                	jmp    800c8d <memcmp+0x56>
		s1++, s2++;
  800c73:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c77:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c81:	89 55 10             	mov    %edx,0x10(%ebp)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	75 c3                	jne    800c4b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c95:	8b 45 10             	mov    0x10(%ebp),%eax
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	01 d0                	add    %edx,%eax
  800c9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800ca0:	eb 13                	jmp    800cb5 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	0f b6 10             	movzbl (%eax),%edx
  800ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cab:	38 c2                	cmp    %al,%dl
  800cad:	75 02                	jne    800cb1 <memfind+0x22>
			break;
  800caf:	eb 0c                	jmp    800cbd <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cbb:	72 e5                	jb     800ca2 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cc8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ccf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd6:	eb 04                	jmp    800cdc <strtol+0x1a>
		s++;
  800cd8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	0f b6 00             	movzbl (%eax),%eax
  800ce2:	3c 20                	cmp    $0x20,%al
  800ce4:	74 f2                	je     800cd8 <strtol+0x16>
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	0f b6 00             	movzbl (%eax),%eax
  800cec:	3c 09                	cmp    $0x9,%al
  800cee:	74 e8                	je     800cd8 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	0f b6 00             	movzbl (%eax),%eax
  800cf6:	3c 2b                	cmp    $0x2b,%al
  800cf8:	75 06                	jne    800d00 <strtol+0x3e>
		s++;
  800cfa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cfe:	eb 15                	jmp    800d15 <strtol+0x53>
	else if (*s == '-')
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	0f b6 00             	movzbl (%eax),%eax
  800d06:	3c 2d                	cmp    $0x2d,%al
  800d08:	75 0b                	jne    800d15 <strtol+0x53>
		s++, neg = 1;
  800d0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d0e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d15:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d19:	74 06                	je     800d21 <strtol+0x5f>
  800d1b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d1f:	75 24                	jne    800d45 <strtol+0x83>
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
  800d24:	0f b6 00             	movzbl (%eax),%eax
  800d27:	3c 30                	cmp    $0x30,%al
  800d29:	75 1a                	jne    800d45 <strtol+0x83>
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	83 c0 01             	add    $0x1,%eax
  800d31:	0f b6 00             	movzbl (%eax),%eax
  800d34:	3c 78                	cmp    $0x78,%al
  800d36:	75 0d                	jne    800d45 <strtol+0x83>
		s += 2, base = 16;
  800d38:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d3c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d43:	eb 2a                	jmp    800d6f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d49:	75 17                	jne    800d62 <strtol+0xa0>
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	0f b6 00             	movzbl (%eax),%eax
  800d51:	3c 30                	cmp    $0x30,%al
  800d53:	75 0d                	jne    800d62 <strtol+0xa0>
		s++, base = 8;
  800d55:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d59:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d60:	eb 0d                	jmp    800d6f <strtol+0xad>
	else if (base == 0)
  800d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d66:	75 07                	jne    800d6f <strtol+0xad>
		base = 10;
  800d68:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	0f b6 00             	movzbl (%eax),%eax
  800d75:	3c 2f                	cmp    $0x2f,%al
  800d77:	7e 1b                	jle    800d94 <strtol+0xd2>
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	3c 39                	cmp    $0x39,%al
  800d81:	7f 11                	jg     800d94 <strtol+0xd2>
			dig = *s - '0';
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	0f be c0             	movsbl %al,%eax
  800d8c:	83 e8 30             	sub    $0x30,%eax
  800d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d92:	eb 48                	jmp    800ddc <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	3c 60                	cmp    $0x60,%al
  800d9c:	7e 1b                	jle    800db9 <strtol+0xf7>
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	0f b6 00             	movzbl (%eax),%eax
  800da4:	3c 7a                	cmp    $0x7a,%al
  800da6:	7f 11                	jg     800db9 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	0f be c0             	movsbl %al,%eax
  800db1:	83 e8 57             	sub    $0x57,%eax
  800db4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800db7:	eb 23                	jmp    800ddc <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	0f b6 00             	movzbl (%eax),%eax
  800dbf:	3c 40                	cmp    $0x40,%al
  800dc1:	7e 3d                	jle    800e00 <strtol+0x13e>
  800dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc6:	0f b6 00             	movzbl (%eax),%eax
  800dc9:	3c 5a                	cmp    $0x5a,%al
  800dcb:	7f 33                	jg     800e00 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	0f b6 00             	movzbl (%eax),%eax
  800dd3:	0f be c0             	movsbl %al,%eax
  800dd6:	83 e8 37             	sub    $0x37,%eax
  800dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800de2:	7c 02                	jl     800de6 <strtol+0x124>
			break;
  800de4:	eb 1a                	jmp    800e00 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800de6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dea:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ded:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df6:	01 d0                	add    %edx,%eax
  800df8:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dfb:	e9 6f ff ff ff       	jmp    800d6f <strtol+0xad>

	if (endptr)
  800e00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e04:	74 08                	je     800e0e <strtol+0x14c>
		*endptr = (char *) s;
  800e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e12:	74 07                	je     800e1b <strtol+0x159>
  800e14:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e17:	f7 d8                	neg    %eax
  800e19:	eb 03                	jmp    800e1e <strtol+0x15c>
  800e1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e2f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e32:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e35:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e38:	8b 75 20             	mov    0x20(%ebp),%esi
  800e3b:	cd 30                	int    $0x30
  800e3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e44:	74 30                	je     800e76 <syscall+0x56>
  800e46:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e4a:	7e 2a                	jle    800e76 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5a:	c7 44 24 08 44 1c 80 	movl   $0x801c44,0x8(%esp)
  800e61:	00 
  800e62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e69:	00 
  800e6a:	c7 04 24 61 1c 80 00 	movl   $0x801c61,(%esp)
  800e71:	e8 c1 07 00 00       	call   801637 <_panic>

	return ret;
  800e76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e79:	83 c4 3c             	add    $0x3c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e91:	00 
  800e92:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e99:	00 
  800e9a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ea1:	00 
  800ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ea9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ead:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb4:	00 
  800eb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ebc:	e8 5f ff ff ff       	call   800e20 <syscall>
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ec9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef8:	00 
  800ef9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f00:	e8 1b ff ff ff       	call   800e20 <syscall>
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f10:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f17:	00 
  800f18:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f1f:	00 
  800f20:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f27:	00 
  800f28:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f2f:	00 
  800f30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f34:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f3b:	00 
  800f3c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f43:	e8 d8 fe ff ff       	call   800e20 <syscall>
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
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
  800f80:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f87:	e8 94 fe ff ff       	call   800e20 <syscall>
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <sys_yield>:

void
sys_yield(void)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f94:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fab:	00 
  800fac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb3:	00 
  800fb4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbb:	00 
  800fbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc3:	00 
  800fc4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fcb:	e8 50 fe ff ff       	call   800e20 <syscall>
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff0:	00 
  800ff1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ff5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80100c:	e8 0f fe ff ff       	call   800e20 <syscall>
}
  801011:	c9                   	leave  
  801012:	c3                   	ret    

00801013 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80101b:	8b 75 18             	mov    0x18(%ebp),%esi
  80101e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801021:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801024:	8b 55 0c             	mov    0xc(%ebp),%edx
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	89 74 24 18          	mov    %esi,0x18(%esp)
  80102e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801032:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801036:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80103a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801045:	00 
  801046:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80104d:	e8 ce fd ff ff       	call   800e20 <syscall>
}
  801052:	83 c4 20             	add    $0x20,%esp
  801055:	5b                   	pop    %ebx
  801056:	5e                   	pop    %esi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80105f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80106c:	00 
  80106d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801074:	00 
  801075:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80107c:	00 
  80107d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80108c:	00 
  80108d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801094:	e8 87 fd ff ff       	call   800e20 <syscall>
}
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010ae:	00 
  8010af:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010b6:	00 
  8010b7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010be:	00 
  8010bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010d6:	e8 45 fd ff ff       	call   800e20 <syscall>
}
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801100:	00 
  801101:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801105:	89 44 24 08          	mov    %eax,0x8(%esp)
  801109:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801110:	00 
  801111:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801118:	e8 03 fd ff ff       	call   800e20 <syscall>
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801125:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801128:	8b 55 10             	mov    0x10(%ebp),%edx
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801135:	00 
  801136:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80113a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80113e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801141:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801145:	89 44 24 08          	mov    %eax,0x8(%esp)
  801149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801158:	e8 c3 fc ff ff       	call   800e20 <syscall>
}
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80116f:	00 
  801170:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801177:	00 
  801178:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80117f:	00 
  801180:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801187:	00 
  801188:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80119b:	e8 80 fc ff ff       	call   800e20 <syscall>
}
  8011a0:	c9                   	leave  
  8011a1:	c3                   	ret    

008011a2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8011a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ab:	8b 00                	mov    (%eax),%eax
  8011ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b3:	8b 40 04             	mov    0x4(%eax),%eax
  8011b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  8011b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bc:	83 e0 02             	and    $0x2,%eax
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	75 23                	jne    8011e6 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ca:	c7 44 24 08 70 1c 80 	movl   $0x801c70,0x8(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8011d9:	00 
  8011da:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  8011e1:	e8 51 04 00 00       	call   801637 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  8011e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e9:	c1 e8 0c             	shr    $0xc,%eax
  8011ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8011ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f9:	25 00 08 00 00       	and    $0x800,%eax
  8011fe:	85 c0                	test   %eax,%eax
  801200:	75 1c                	jne    80121e <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  801202:	c7 44 24 08 ac 1c 80 	movl   $0x801cac,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  801219:	e8 19 04 00 00       	call   801637 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  80121e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801225:	00 
  801226:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80122d:	00 
  80122e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801235:	e8 98 fd ff ff       	call   800fd2 <sys_page_alloc>
  80123a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80123d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801241:	79 23                	jns    801266 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  801243:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801246:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124a:	c7 44 24 08 e8 1c 80 	movl   $0x801ce8,0x8(%esp)
  801251:	00 
  801252:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801259:	00 
  80125a:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  801261:	e8 d1 03 00 00       	call   801637 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801274:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80127b:	00 
  80127c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801280:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801287:	e8 8a f9 ff ff       	call   800c16 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801292:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801295:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012a1:	00 
  8012a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b5:	00 
  8012b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bd:	e8 51 fd ff ff       	call   801013 <sys_page_map>
  8012c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012c9:	79 23                	jns    8012ee <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8012cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d2:	c7 44 24 08 20 1d 80 	movl   $0x801d20,0x8(%esp)
  8012d9:	00 
  8012da:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  8012e1:	00 
  8012e2:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  8012e9:	e8 49 03 00 00       	call   801637 <_panic>
	}

	// panic("pgfault not implemented");
}
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	56                   	push   %esi
  8012f4:	53                   	push   %ebx
  8012f5:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8012f8:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8012ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801302:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801309:	25 00 08 00 00       	and    $0x800,%eax
  80130e:	85 c0                	test   %eax,%eax
  801310:	75 15                	jne    801327 <duppage+0x37>
  801312:	8b 45 0c             	mov    0xc(%ebp),%eax
  801315:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80131c:	83 e0 02             	and    $0x2,%eax
  80131f:	85 c0                	test   %eax,%eax
  801321:	0f 84 e0 00 00 00    	je     801407 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  801327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801331:	83 e0 04             	and    $0x4,%eax
  801334:	85 c0                	test   %eax,%eax
  801336:	74 04                	je     80133c <duppage+0x4c>
  801338:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  80133c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80133f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801342:	c1 e0 0c             	shl    $0xc,%eax
  801345:	89 c1                	mov    %eax,%ecx
  801347:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134a:	c1 e0 0c             	shl    $0xc,%eax
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	a1 04 20 80 00       	mov    0x802004,%eax
  801354:	8b 40 48             	mov    0x48(%eax),%eax
  801357:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80135b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80135f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801362:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801366:	89 54 24 04          	mov    %edx,0x4(%esp)
  80136a:	89 04 24             	mov    %eax,(%esp)
  80136d:	e8 a1 fc ff ff       	call   801013 <sys_page_map>
  801372:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801375:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801379:	79 23                	jns    80139e <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  80137b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801382:	c7 44 24 08 54 1d 80 	movl   $0x801d54,0x8(%esp)
  801389:	00 
  80138a:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801391:	00 
  801392:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  801399:	e8 99 02 00 00       	call   801637 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80139e:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	c1 e0 0c             	shl    $0xc,%eax
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	a1 04 20 80 00       	mov    0x802004,%eax
  8013ae:	8b 48 48             	mov    0x48(%eax),%ecx
  8013b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b4:	c1 e0 0c             	shl    $0xc,%eax
  8013b7:	89 c2                	mov    %eax,%edx
  8013b9:	a1 04 20 80 00       	mov    0x802004,%eax
  8013be:	8b 40 48             	mov    0x48(%eax),%eax
  8013c1:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 3a fc ff ff       	call   801013 <sys_page_map>
  8013d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8013dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013e0:	79 23                	jns    801405 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e9:	c7 44 24 08 90 1d 80 	movl   $0x801d90,0x8(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8013f8:	00 
  8013f9:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  801400:	e8 32 02 00 00       	call   801637 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801405:	eb 70                	jmp    801477 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801407:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801411:	25 ff 0f 00 00       	and    $0xfff,%eax
  801416:	89 c3                	mov    %eax,%ebx
  801418:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141b:	c1 e0 0c             	shl    $0xc,%eax
  80141e:	89 c1                	mov    %eax,%ecx
  801420:	8b 45 0c             	mov    0xc(%ebp),%eax
  801423:	c1 e0 0c             	shl    $0xc,%eax
  801426:	89 c2                	mov    %eax,%edx
  801428:	a1 04 20 80 00       	mov    0x802004,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801434:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80143f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801443:	89 04 24             	mov    %eax,(%esp)
  801446:	e8 c8 fb ff ff       	call   801013 <sys_page_map>
  80144b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80144e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801452:	79 23                	jns    801477 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  801454:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145b:	c7 44 24 08 c0 1d 80 	movl   $0x801dc0,0x8(%esp)
  801462:	00 
  801463:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  80146a:	00 
  80146b:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  801472:	e8 c0 01 00 00       	call   801637 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801477:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80147c:	83 c4 30             	add    $0x30,%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801489:	c7 04 24 a2 11 80 00 	movl   $0x8011a2,(%esp)
  801490:	e8 fd 01 00 00       	call   801692 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801495:	b8 07 00 00 00       	mov    $0x7,%eax
  80149a:	cd 30                	int    $0x30
  80149c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80149f:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8014a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8014a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014a9:	79 23                	jns    8014ce <fork+0x4b>
  8014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b2:	c7 44 24 08 f8 1d 80 	movl   $0x801df8,0x8(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8014c1:	00 
  8014c2:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  8014c9:	e8 69 01 00 00       	call   801637 <_panic>
	else if(childeid == 0){
  8014ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014d2:	75 29                	jne    8014fd <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8014d4:	e8 71 fa ff ff       	call   800f4a <sys_getenvid>
  8014d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014de:	c1 e0 02             	shl    $0x2,%eax
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	c1 e2 05             	shl    $0x5,%edx
  8014e6:	29 c2                	sub    %eax,%edx
  8014e8:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8014ee:	a3 04 20 80 00       	mov    %eax,0x802004
		// set_pgfault_handler(pgfault);
		return 0;
  8014f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f8:	e9 16 01 00 00       	jmp    801613 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8014fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801504:	eb 3b                	jmp    801541 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801506:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801509:	c1 f8 0a             	sar    $0xa,%eax
  80150c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801513:	83 e0 01             	and    $0x1,%eax
  801516:	85 c0                	test   %eax,%eax
  801518:	74 23                	je     80153d <fork+0xba>
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801524:	83 e0 01             	and    $0x1,%eax
  801527:	85 c0                	test   %eax,%eax
  801529:	74 12                	je     80153d <fork+0xba>
			duppage(childeid, i);
  80152b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801535:	89 04 24             	mov    %eax,(%esp)
  801538:	e8 b3 fd ff ff       	call   8012f0 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80153d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801541:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801544:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801549:	76 bb                	jbe    801506 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  80154b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801552:	00 
  801553:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80155a:	ee 
  80155b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155e:	89 04 24             	mov    %eax,(%esp)
  801561:	e8 6c fa ff ff       	call   800fd2 <sys_page_alloc>
  801566:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801569:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80156d:	79 23                	jns    801592 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  80156f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801572:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801576:	c7 44 24 08 20 1e 80 	movl   $0x801e20,0x8(%esp)
  80157d:	00 
  80157e:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801585:	00 
  801586:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  80158d:	e8 a5 00 00 00       	call   801637 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  801592:	c7 44 24 04 08 17 80 	movl   $0x801708,0x4(%esp)
  801599:	00 
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 38 fb ff ff       	call   8010dd <sys_env_set_pgfault_upcall>
  8015a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015ac:	79 23                	jns    8015d1 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8015ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b5:	c7 44 24 08 48 1e 80 	movl   $0x801e48,0x8(%esp)
  8015bc:	00 
  8015bd:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8015c4:	00 
  8015c5:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  8015cc:	e8 66 00 00 00       	call   801637 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  8015d1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8015d8:	00 
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	89 04 24             	mov    %eax,(%esp)
  8015df:	e8 b7 fa ff ff       	call   80109b <sys_env_set_status>
  8015e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015eb:	79 23                	jns    801610 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8015ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f4:	c7 44 24 08 7c 1e 80 	movl   $0x801e7c,0x8(%esp)
  8015fb:	00 
  8015fc:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801603:	00 
  801604:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  80160b:	e8 27 00 00 00       	call   801637 <_panic>
	}
	return childeid;
  801610:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <sfork>:

// Challenge!
int
sfork(void)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80161b:	c7 44 24 08 a5 1e 80 	movl   $0x801ea5,0x8(%esp)
  801622:	00 
  801623:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  80162a:	00 
  80162b:	c7 04 24 a0 1c 80 00 	movl   $0x801ca0,(%esp)
  801632:	e8 00 00 00 00       	call   801637 <_panic>

00801637 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80163e:	8d 45 14             	lea    0x14(%ebp),%eax
  801641:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801644:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80164a:	e8 fb f8 ff ff       	call   800f4a <sys_getenvid>
  80164f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801652:	89 54 24 10          	mov    %edx,0x10(%esp)
  801656:	8b 55 08             	mov    0x8(%ebp),%edx
  801659:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80165d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801661:	89 44 24 04          	mov    %eax,0x4(%esp)
  801665:	c7 04 24 bc 1e 80 00 	movl   $0x801ebc,(%esp)
  80166c:	e8 a4 eb ff ff       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	89 44 24 04          	mov    %eax,0x4(%esp)
  801678:	8b 45 10             	mov    0x10(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 2e eb ff ff       	call   8001b1 <vcprintf>
	cprintf("\n");
  801683:	c7 04 24 df 1e 80 00 	movl   $0x801edf,(%esp)
  80168a:	e8 86 eb ff ff       	call   800215 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80168f:	cc                   	int3   
  801690:	eb fd                	jmp    80168f <_panic+0x58>

00801692 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801698:	a1 08 20 80 00       	mov    0x802008,%eax
  80169d:	85 c0                	test   %eax,%eax
  80169f:	75 5d                	jne    8016fe <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8016a1:	a1 04 20 80 00       	mov    0x802004,%eax
  8016a6:	8b 40 48             	mov    0x48(%eax),%eax
  8016a9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016b0:	00 
  8016b1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016b8:	ee 
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 11 f9 ff ff       	call   800fd2 <sys_page_alloc>
  8016c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016c8:	79 1c                	jns    8016e6 <set_pgfault_handler+0x54>
  8016ca:	c7 44 24 08 e4 1e 80 	movl   $0x801ee4,0x8(%esp)
  8016d1:	00 
  8016d2:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8016d9:	00 
  8016da:	c7 04 24 10 1f 80 00 	movl   $0x801f10,(%esp)
  8016e1:	e8 51 ff ff ff       	call   801637 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8016e6:	a1 04 20 80 00       	mov    0x802004,%eax
  8016eb:	8b 40 48             	mov    0x48(%eax),%eax
  8016ee:	c7 44 24 04 08 17 80 	movl   $0x801708,0x4(%esp)
  8016f5:	00 
  8016f6:	89 04 24             	mov    %eax,(%esp)
  8016f9:	e8 df f9 ff ff       	call   8010dd <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801708:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801709:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80170e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801710:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801713:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801717:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801719:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80171d:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80171e:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801721:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801723:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801724:	58                   	pop    %eax
	popal 						// pop all the registers
  801725:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801726:	83 c4 04             	add    $0x4,%esp
	popfl
  801729:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80172a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80172b:	c3                   	ret    
  80172c:	66 90                	xchg   %ax,%ax
  80172e:	66 90                	xchg   %ax,%ax

00801730 <__udivdi3>:
  801730:	55                   	push   %ebp
  801731:	57                   	push   %edi
  801732:	56                   	push   %esi
  801733:	83 ec 0c             	sub    $0xc,%esp
  801736:	8b 44 24 28          	mov    0x28(%esp),%eax
  80173a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80173e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801742:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801746:	85 c0                	test   %eax,%eax
  801748:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80174c:	89 ea                	mov    %ebp,%edx
  80174e:	89 0c 24             	mov    %ecx,(%esp)
  801751:	75 2d                	jne    801780 <__udivdi3+0x50>
  801753:	39 e9                	cmp    %ebp,%ecx
  801755:	77 61                	ja     8017b8 <__udivdi3+0x88>
  801757:	85 c9                	test   %ecx,%ecx
  801759:	89 ce                	mov    %ecx,%esi
  80175b:	75 0b                	jne    801768 <__udivdi3+0x38>
  80175d:	b8 01 00 00 00       	mov    $0x1,%eax
  801762:	31 d2                	xor    %edx,%edx
  801764:	f7 f1                	div    %ecx
  801766:	89 c6                	mov    %eax,%esi
  801768:	31 d2                	xor    %edx,%edx
  80176a:	89 e8                	mov    %ebp,%eax
  80176c:	f7 f6                	div    %esi
  80176e:	89 c5                	mov    %eax,%ebp
  801770:	89 f8                	mov    %edi,%eax
  801772:	f7 f6                	div    %esi
  801774:	89 ea                	mov    %ebp,%edx
  801776:	83 c4 0c             	add    $0xc,%esp
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    
  80177d:	8d 76 00             	lea    0x0(%esi),%esi
  801780:	39 e8                	cmp    %ebp,%eax
  801782:	77 24                	ja     8017a8 <__udivdi3+0x78>
  801784:	0f bd e8             	bsr    %eax,%ebp
  801787:	83 f5 1f             	xor    $0x1f,%ebp
  80178a:	75 3c                	jne    8017c8 <__udivdi3+0x98>
  80178c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801790:	39 34 24             	cmp    %esi,(%esp)
  801793:	0f 86 9f 00 00 00    	jbe    801838 <__udivdi3+0x108>
  801799:	39 d0                	cmp    %edx,%eax
  80179b:	0f 82 97 00 00 00    	jb     801838 <__udivdi3+0x108>
  8017a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017a8:	31 d2                	xor    %edx,%edx
  8017aa:	31 c0                	xor    %eax,%eax
  8017ac:	83 c4 0c             	add    $0xc,%esp
  8017af:	5e                   	pop    %esi
  8017b0:	5f                   	pop    %edi
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    
  8017b3:	90                   	nop
  8017b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017b8:	89 f8                	mov    %edi,%eax
  8017ba:	f7 f1                	div    %ecx
  8017bc:	31 d2                	xor    %edx,%edx
  8017be:	83 c4 0c             	add    $0xc,%esp
  8017c1:	5e                   	pop    %esi
  8017c2:	5f                   	pop    %edi
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    
  8017c5:	8d 76 00             	lea    0x0(%esi),%esi
  8017c8:	89 e9                	mov    %ebp,%ecx
  8017ca:	8b 3c 24             	mov    (%esp),%edi
  8017cd:	d3 e0                	shl    %cl,%eax
  8017cf:	89 c6                	mov    %eax,%esi
  8017d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8017d6:	29 e8                	sub    %ebp,%eax
  8017d8:	89 c1                	mov    %eax,%ecx
  8017da:	d3 ef                	shr    %cl,%edi
  8017dc:	89 e9                	mov    %ebp,%ecx
  8017de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8017e2:	8b 3c 24             	mov    (%esp),%edi
  8017e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8017e9:	89 d6                	mov    %edx,%esi
  8017eb:	d3 e7                	shl    %cl,%edi
  8017ed:	89 c1                	mov    %eax,%ecx
  8017ef:	89 3c 24             	mov    %edi,(%esp)
  8017f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017f6:	d3 ee                	shr    %cl,%esi
  8017f8:	89 e9                	mov    %ebp,%ecx
  8017fa:	d3 e2                	shl    %cl,%edx
  8017fc:	89 c1                	mov    %eax,%ecx
  8017fe:	d3 ef                	shr    %cl,%edi
  801800:	09 d7                	or     %edx,%edi
  801802:	89 f2                	mov    %esi,%edx
  801804:	89 f8                	mov    %edi,%eax
  801806:	f7 74 24 08          	divl   0x8(%esp)
  80180a:	89 d6                	mov    %edx,%esi
  80180c:	89 c7                	mov    %eax,%edi
  80180e:	f7 24 24             	mull   (%esp)
  801811:	39 d6                	cmp    %edx,%esi
  801813:	89 14 24             	mov    %edx,(%esp)
  801816:	72 30                	jb     801848 <__udivdi3+0x118>
  801818:	8b 54 24 04          	mov    0x4(%esp),%edx
  80181c:	89 e9                	mov    %ebp,%ecx
  80181e:	d3 e2                	shl    %cl,%edx
  801820:	39 c2                	cmp    %eax,%edx
  801822:	73 05                	jae    801829 <__udivdi3+0xf9>
  801824:	3b 34 24             	cmp    (%esp),%esi
  801827:	74 1f                	je     801848 <__udivdi3+0x118>
  801829:	89 f8                	mov    %edi,%eax
  80182b:	31 d2                	xor    %edx,%edx
  80182d:	e9 7a ff ff ff       	jmp    8017ac <__udivdi3+0x7c>
  801832:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801838:	31 d2                	xor    %edx,%edx
  80183a:	b8 01 00 00 00       	mov    $0x1,%eax
  80183f:	e9 68 ff ff ff       	jmp    8017ac <__udivdi3+0x7c>
  801844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801848:	8d 47 ff             	lea    -0x1(%edi),%eax
  80184b:	31 d2                	xor    %edx,%edx
  80184d:	83 c4 0c             	add    $0xc,%esp
  801850:	5e                   	pop    %esi
  801851:	5f                   	pop    %edi
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    
  801854:	66 90                	xchg   %ax,%ax
  801856:	66 90                	xchg   %ax,%ax
  801858:	66 90                	xchg   %ax,%ax
  80185a:	66 90                	xchg   %ax,%ax
  80185c:	66 90                	xchg   %ax,%ax
  80185e:	66 90                	xchg   %ax,%ax

00801860 <__umoddi3>:
  801860:	55                   	push   %ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	83 ec 14             	sub    $0x14,%esp
  801866:	8b 44 24 28          	mov    0x28(%esp),%eax
  80186a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80186e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801872:	89 c7                	mov    %eax,%edi
  801874:	89 44 24 04          	mov    %eax,0x4(%esp)
  801878:	8b 44 24 30          	mov    0x30(%esp),%eax
  80187c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801880:	89 34 24             	mov    %esi,(%esp)
  801883:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801887:	85 c0                	test   %eax,%eax
  801889:	89 c2                	mov    %eax,%edx
  80188b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80188f:	75 17                	jne    8018a8 <__umoddi3+0x48>
  801891:	39 fe                	cmp    %edi,%esi
  801893:	76 4b                	jbe    8018e0 <__umoddi3+0x80>
  801895:	89 c8                	mov    %ecx,%eax
  801897:	89 fa                	mov    %edi,%edx
  801899:	f7 f6                	div    %esi
  80189b:	89 d0                	mov    %edx,%eax
  80189d:	31 d2                	xor    %edx,%edx
  80189f:	83 c4 14             	add    $0x14,%esp
  8018a2:	5e                   	pop    %esi
  8018a3:	5f                   	pop    %edi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    
  8018a6:	66 90                	xchg   %ax,%ax
  8018a8:	39 f8                	cmp    %edi,%eax
  8018aa:	77 54                	ja     801900 <__umoddi3+0xa0>
  8018ac:	0f bd e8             	bsr    %eax,%ebp
  8018af:	83 f5 1f             	xor    $0x1f,%ebp
  8018b2:	75 5c                	jne    801910 <__umoddi3+0xb0>
  8018b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8018b8:	39 3c 24             	cmp    %edi,(%esp)
  8018bb:	0f 87 e7 00 00 00    	ja     8019a8 <__umoddi3+0x148>
  8018c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018c5:	29 f1                	sub    %esi,%ecx
  8018c7:	19 c7                	sbb    %eax,%edi
  8018c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8018d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8018d9:	83 c4 14             	add    $0x14,%esp
  8018dc:	5e                   	pop    %esi
  8018dd:	5f                   	pop    %edi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    
  8018e0:	85 f6                	test   %esi,%esi
  8018e2:	89 f5                	mov    %esi,%ebp
  8018e4:	75 0b                	jne    8018f1 <__umoddi3+0x91>
  8018e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8018eb:	31 d2                	xor    %edx,%edx
  8018ed:	f7 f6                	div    %esi
  8018ef:	89 c5                	mov    %eax,%ebp
  8018f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8018f5:	31 d2                	xor    %edx,%edx
  8018f7:	f7 f5                	div    %ebp
  8018f9:	89 c8                	mov    %ecx,%eax
  8018fb:	f7 f5                	div    %ebp
  8018fd:	eb 9c                	jmp    80189b <__umoddi3+0x3b>
  8018ff:	90                   	nop
  801900:	89 c8                	mov    %ecx,%eax
  801902:	89 fa                	mov    %edi,%edx
  801904:	83 c4 14             	add    $0x14,%esp
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    
  80190b:	90                   	nop
  80190c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801910:	8b 04 24             	mov    (%esp),%eax
  801913:	be 20 00 00 00       	mov    $0x20,%esi
  801918:	89 e9                	mov    %ebp,%ecx
  80191a:	29 ee                	sub    %ebp,%esi
  80191c:	d3 e2                	shl    %cl,%edx
  80191e:	89 f1                	mov    %esi,%ecx
  801920:	d3 e8                	shr    %cl,%eax
  801922:	89 e9                	mov    %ebp,%ecx
  801924:	89 44 24 04          	mov    %eax,0x4(%esp)
  801928:	8b 04 24             	mov    (%esp),%eax
  80192b:	09 54 24 04          	or     %edx,0x4(%esp)
  80192f:	89 fa                	mov    %edi,%edx
  801931:	d3 e0                	shl    %cl,%eax
  801933:	89 f1                	mov    %esi,%ecx
  801935:	89 44 24 08          	mov    %eax,0x8(%esp)
  801939:	8b 44 24 10          	mov    0x10(%esp),%eax
  80193d:	d3 ea                	shr    %cl,%edx
  80193f:	89 e9                	mov    %ebp,%ecx
  801941:	d3 e7                	shl    %cl,%edi
  801943:	89 f1                	mov    %esi,%ecx
  801945:	d3 e8                	shr    %cl,%eax
  801947:	89 e9                	mov    %ebp,%ecx
  801949:	09 f8                	or     %edi,%eax
  80194b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80194f:	f7 74 24 04          	divl   0x4(%esp)
  801953:	d3 e7                	shl    %cl,%edi
  801955:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801959:	89 d7                	mov    %edx,%edi
  80195b:	f7 64 24 08          	mull   0x8(%esp)
  80195f:	39 d7                	cmp    %edx,%edi
  801961:	89 c1                	mov    %eax,%ecx
  801963:	89 14 24             	mov    %edx,(%esp)
  801966:	72 2c                	jb     801994 <__umoddi3+0x134>
  801968:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80196c:	72 22                	jb     801990 <__umoddi3+0x130>
  80196e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801972:	29 c8                	sub    %ecx,%eax
  801974:	19 d7                	sbb    %edx,%edi
  801976:	89 e9                	mov    %ebp,%ecx
  801978:	89 fa                	mov    %edi,%edx
  80197a:	d3 e8                	shr    %cl,%eax
  80197c:	89 f1                	mov    %esi,%ecx
  80197e:	d3 e2                	shl    %cl,%edx
  801980:	89 e9                	mov    %ebp,%ecx
  801982:	d3 ef                	shr    %cl,%edi
  801984:	09 d0                	or     %edx,%eax
  801986:	89 fa                	mov    %edi,%edx
  801988:	83 c4 14             	add    $0x14,%esp
  80198b:	5e                   	pop    %esi
  80198c:	5f                   	pop    %edi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    
  80198f:	90                   	nop
  801990:	39 d7                	cmp    %edx,%edi
  801992:	75 da                	jne    80196e <__umoddi3+0x10e>
  801994:	8b 14 24             	mov    (%esp),%edx
  801997:	89 c1                	mov    %eax,%ecx
  801999:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80199d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8019a1:	eb cb                	jmp    80196e <__umoddi3+0x10e>
  8019a3:	90                   	nop
  8019a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8019ac:	0f 82 0f ff ff ff    	jb     8018c1 <__umoddi3+0x61>
  8019b2:	e9 1a ff ff ff       	jmp    8018d1 <__umoddi3+0x71>
