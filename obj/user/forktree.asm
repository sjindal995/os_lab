
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
  800045:	e8 32 08 00 00       	call   80087c <strlen>
  80004a:	83 f8 02             	cmp    $0x2,%eax
  80004d:	7f 43                	jg     800092 <forkchild+0x5f>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80004f:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800053:	89 44 24 10          	mov    %eax,0x10(%esp)
  800057:	8b 45 08             	mov    0x8(%ebp),%eax
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 80 1a 80 	movl   $0x801a80,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80006d:	00 
  80006e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800071:	89 04 24             	mov    %eax,(%esp)
  800074:	e8 cf 07 00 00       	call   800848 <snprintf>
	if (fork() == 0) {
  800079:	e8 c0 14 00 00       	call   80153e <fork>
  80007e:	85 c0                	test   %eax,%eax
  800080:	75 10                	jne    800092 <forkchild+0x5f>
		forktree(nxt);
  800082:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 07 00 00 00       	call   800094 <forktree>
		exit();
  80008d:	e8 9f 00 00 00       	call   800131 <exit>
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
  80009a:	e8 9b 0e 00 00       	call   800f3a <sys_getenvid>
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000aa:	c7 04 24 85 1a 80 00 	movl   $0x801a85,(%esp)
  8000b1:	e8 4f 01 00 00       	call   800205 <cprintf>

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
  8000e4:	c7 04 24 96 1a 80 00 	movl   $0x801a96,(%esp)
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
  8000f8:	e8 3d 0e 00 00       	call   800f3a <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	c1 e0 02             	shl    $0x2,%eax
  800105:	89 c2                	mov    %eax,%edx
  800107:	c1 e2 05             	shl    $0x5,%edx
  80010a:	29 c2                	sub    %eax,%edx
  80010c:	89 d0                	mov    %edx,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011f:	8b 45 08             	mov    0x8(%ebp),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 b4 ff ff ff       	call   8000de <umain>

	// exit gracefully
	exit();
  80012a:	e8 02 00 00 00       	call   800131 <exit>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    

00800131 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013e:	e8 b4 0d 00 00       	call   800ef7 <sys_env_destroy>
}
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80014b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014e:	8b 00                	mov    (%eax),%eax
  800150:	8d 48 01             	lea    0x1(%eax),%ecx
  800153:	8b 55 0c             	mov    0xc(%ebp),%edx
  800156:	89 0a                	mov    %ecx,(%edx)
  800158:	8b 55 08             	mov    0x8(%ebp),%edx
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800164:	8b 45 0c             	mov    0xc(%ebp),%eax
  800167:	8b 00                	mov    (%eax),%eax
  800169:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016e:	75 20                	jne    800190 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	8b 00                	mov    (%eax),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	83 c2 08             	add    $0x8,%edx
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	89 14 24             	mov    %edx,(%esp)
  800182:	e8 ea 0c 00 00       	call   800e71 <sys_cputs>
		b->idx = 0;
  800187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800190:	8b 45 0c             	mov    0xc(%ebp),%eax
  800193:	8b 40 04             	mov    0x4(%eax),%eax
  800196:	8d 50 01             	lea    0x1(%eax),%edx
  800199:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001aa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b1:	00 00 00 
	b.cnt = 0;
  8001b4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d6:	c7 04 24 45 01 80 00 	movl   $0x800145,(%esp)
  8001dd:	e8 bd 01 00 00       	call   80039f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f2:	83 c0 08             	add    $0x8,%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	e8 74 0c 00 00       	call   800e71 <sys_cputs>

	return b.cnt;
  8001fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80020e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	89 04 24             	mov    %eax,(%esp)
  80021e:	e8 7e ff ff ff       	call   8001a1 <vcprintf>
  800223:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800226:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 34             	sub    $0x34,%esp
  800232:	8b 45 10             	mov    0x10(%ebp),%eax
  800235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023e:	8b 45 18             	mov    0x18(%ebp),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
  800246:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800249:	77 72                	ja     8002bd <printnum+0x92>
  80024b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80024e:	72 05                	jb     800255 <printnum+0x2a>
  800250:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800253:	77 68                	ja     8002bd <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800255:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800258:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025b:	8b 45 18             	mov    0x18(%ebp),%eax
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
  800263:	89 44 24 08          	mov    %eax,0x8(%esp)
  800267:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80026e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	89 54 24 04          	mov    %edx,0x4(%esp)
  800278:	e8 73 15 00 00       	call   8017f0 <__udivdi3>
  80027d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800280:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800284:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800288:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80028b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 04 24             	mov    %eax,(%esp)
  8002a4:	e8 82 ff ff ff       	call   80022b <printnum>
  8002a9:	eb 1c                	jmp    8002c7 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b2:	8b 45 20             	mov    0x20(%ebp),%eax
  8002b5:	89 04 24             	mov    %eax,(%esp)
  8002b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bb:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8002c1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8002c5:	7f e4                	jg     8002ab <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c7:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002dd:	89 04 24             	mov    %eax,(%esp)
  8002e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e4:	e8 37 16 00 00       	call   801920 <__umoddi3>
  8002e9:	05 88 1b 80 00       	add    $0x801b88,%eax
  8002ee:	0f b6 00             	movzbl (%eax),%eax
  8002f1:	0f be c0             	movsbl %al,%eax
  8002f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fb:	89 04 24             	mov    %eax,(%esp)
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	ff d0                	call   *%eax
}
  800303:	83 c4 34             	add    $0x34,%esp
  800306:	5b                   	pop    %ebx
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800310:	7e 14                	jle    800326 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 00                	mov    (%eax),%eax
  800317:	8d 48 08             	lea    0x8(%eax),%ecx
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	89 0a                	mov    %ecx,(%edx)
  80031f:	8b 50 04             	mov    0x4(%eax),%edx
  800322:	8b 00                	mov    (%eax),%eax
  800324:	eb 30                	jmp    800356 <getuint+0x4d>
	else if (lflag)
  800326:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80032a:	74 16                	je     800342 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 00                	mov    (%eax),%eax
  800331:	8d 48 04             	lea    0x4(%eax),%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	89 0a                	mov    %ecx,(%edx)
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	eb 14                	jmp    800356 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800342:	8b 45 08             	mov    0x8(%ebp),%eax
  800345:	8b 00                	mov    (%eax),%eax
  800347:	8d 48 04             	lea    0x4(%eax),%ecx
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	89 0a                	mov    %ecx,(%edx)
  80034f:	8b 00                	mov    (%eax),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80035f:	7e 14                	jle    800375 <getint+0x1d>
		return va_arg(*ap, long long);
  800361:	8b 45 08             	mov    0x8(%ebp),%eax
  800364:	8b 00                	mov    (%eax),%eax
  800366:	8d 48 08             	lea    0x8(%eax),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	89 0a                	mov    %ecx,(%edx)
  80036e:	8b 50 04             	mov    0x4(%eax),%edx
  800371:	8b 00                	mov    (%eax),%eax
  800373:	eb 28                	jmp    80039d <getint+0x45>
	else if (lflag)
  800375:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800379:	74 12                	je     80038d <getint+0x35>
		return va_arg(*ap, long);
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	8d 48 04             	lea    0x4(%eax),%ecx
  800383:	8b 55 08             	mov    0x8(%ebp),%edx
  800386:	89 0a                	mov    %ecx,(%edx)
  800388:	8b 00                	mov    (%eax),%eax
  80038a:	99                   	cltd   
  80038b:	eb 10                	jmp    80039d <getint+0x45>
	else
		return va_arg(*ap, int);
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	8b 00                	mov    (%eax),%eax
  800392:	8d 48 04             	lea    0x4(%eax),%ecx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	89 0a                	mov    %ecx,(%edx)
  80039a:	8b 00                	mov    (%eax),%eax
  80039c:	99                   	cltd   
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	eb 18                	jmp    8003c1 <vprintfmt+0x22>
			if (ch == '\0')
  8003a9:	85 db                	test   %ebx,%ebx
  8003ab:	75 05                	jne    8003b2 <vprintfmt+0x13>
				return;
  8003ad:	e9 cc 03 00 00       	jmp    80077e <vprintfmt+0x3df>
			putch(ch, putdat);
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	89 1c 24             	mov    %ebx,(%esp)
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bf:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c4:	8d 50 01             	lea    0x1(%eax),%edx
  8003c7:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ca:	0f b6 00             	movzbl (%eax),%eax
  8003cd:	0f b6 d8             	movzbl %al,%ebx
  8003d0:	83 fb 25             	cmp    $0x25,%ebx
  8003d3:	75 d4                	jne    8003a9 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003d5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f8:	8d 50 01             	lea    0x1(%eax),%edx
  8003fb:	89 55 10             	mov    %edx,0x10(%ebp)
  8003fe:	0f b6 00             	movzbl (%eax),%eax
  800401:	0f b6 d8             	movzbl %al,%ebx
  800404:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800407:	83 f8 55             	cmp    $0x55,%eax
  80040a:	0f 87 3d 03 00 00    	ja     80074d <vprintfmt+0x3ae>
  800410:	8b 04 85 ac 1b 80 00 	mov    0x801bac(,%eax,4),%eax
  800417:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800419:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80041d:	eb d6                	jmp    8003f5 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80041f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800423:	eb d0                	jmp    8003f5 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800425:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80042c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80042f:	89 d0                	mov    %edx,%eax
  800431:	c1 e0 02             	shl    $0x2,%eax
  800434:	01 d0                	add    %edx,%eax
  800436:	01 c0                	add    %eax,%eax
  800438:	01 d8                	add    %ebx,%eax
  80043a:	83 e8 30             	sub    $0x30,%eax
  80043d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800440:	8b 45 10             	mov    0x10(%ebp),%eax
  800443:	0f b6 00             	movzbl (%eax),%eax
  800446:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800449:	83 fb 2f             	cmp    $0x2f,%ebx
  80044c:	7e 0b                	jle    800459 <vprintfmt+0xba>
  80044e:	83 fb 39             	cmp    $0x39,%ebx
  800451:	7f 06                	jg     800459 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800453:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800457:	eb d3                	jmp    80042c <vprintfmt+0x8d>
			goto process_precision;
  800459:	eb 33                	jmp    80048e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	8b 00                	mov    (%eax),%eax
  800466:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800469:	eb 23                	jmp    80048e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80046b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046f:	79 0c                	jns    80047d <vprintfmt+0xde>
				width = 0;
  800471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800478:	e9 78 ff ff ff       	jmp    8003f5 <vprintfmt+0x56>
  80047d:	e9 73 ff ff ff       	jmp    8003f5 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800482:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800489:	e9 67 ff ff ff       	jmp    8003f5 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80048e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800492:	79 12                	jns    8004a6 <vprintfmt+0x107>
				width = precision, precision = -1;
  800494:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800497:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8004a1:	e9 4f ff ff ff       	jmp    8003f5 <vprintfmt+0x56>
  8004a6:	e9 4a ff ff ff       	jmp    8003f5 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ab:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8004af:	e9 41 ff ff ff       	jmp    8003f5 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	ff d0                	call   *%eax
			break;
  8004ce:	e9 a5 02 00 00       	jmp    800778 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004de:	85 db                	test   %ebx,%ebx
  8004e0:	79 02                	jns    8004e4 <vprintfmt+0x145>
				err = -err;
  8004e2:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e4:	83 fb 09             	cmp    $0x9,%ebx
  8004e7:	7f 0b                	jg     8004f4 <vprintfmt+0x155>
  8004e9:	8b 34 9d 60 1b 80 00 	mov    0x801b60(,%ebx,4),%esi
  8004f0:	85 f6                	test   %esi,%esi
  8004f2:	75 23                	jne    800517 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004f8:	c7 44 24 08 99 1b 80 	movl   $0x801b99,0x8(%esp)
  8004ff:	00 
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	89 04 24             	mov    %eax,(%esp)
  80050d:	e8 73 02 00 00       	call   800785 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800512:	e9 61 02 00 00       	jmp    800778 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800517:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051b:	c7 44 24 08 a2 1b 80 	movl   $0x801ba2,0x8(%esp)
  800522:	00 
  800523:	8b 45 0c             	mov    0xc(%ebp),%eax
  800526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 50 02 00 00       	call   800785 <printfmt>
			break;
  800535:	e9 3e 02 00 00       	jmp    800778 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 30                	mov    (%eax),%esi
  800545:	85 f6                	test   %esi,%esi
  800547:	75 05                	jne    80054e <vprintfmt+0x1af>
				p = "(null)";
  800549:	be a5 1b 80 00       	mov    $0x801ba5,%esi
			if (width > 0 && padc != '-')
  80054e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800552:	7e 37                	jle    80058b <vprintfmt+0x1ec>
  800554:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800558:	74 31                	je     80058b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	e8 39 03 00 00       	call   8008a2 <strnlen>
  800569:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80056c:	eb 17                	jmp    800585 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80056e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800572:	8b 55 0c             	mov    0xc(%ebp),%edx
  800575:	89 54 24 04          	mov    %edx,0x4(%esp)
  800579:	89 04 24             	mov    %eax,(%esp)
  80057c:	8b 45 08             	mov    0x8(%ebp),%eax
  80057f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800585:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800589:	7f e3                	jg     80056e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058b:	eb 38                	jmp    8005c5 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80058d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800591:	74 1f                	je     8005b2 <vprintfmt+0x213>
  800593:	83 fb 1f             	cmp    $0x1f,%ebx
  800596:	7e 05                	jle    80059d <vprintfmt+0x1fe>
  800598:	83 fb 7e             	cmp    $0x7e,%ebx
  80059b:	7e 15                	jle    8005b2 <vprintfmt+0x213>
					putch('?', putdat);
  80059d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	ff d0                	call   *%eax
  8005b0:	eb 0f                	jmp    8005c1 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8005b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b9:	89 1c 24             	mov    %ebx,(%esp)
  8005bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bf:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c5:	89 f0                	mov    %esi,%eax
  8005c7:	8d 70 01             	lea    0x1(%eax),%esi
  8005ca:	0f b6 00             	movzbl (%eax),%eax
  8005cd:	0f be d8             	movsbl %al,%ebx
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	74 10                	je     8005e4 <vprintfmt+0x245>
  8005d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d8:	78 b3                	js     80058d <vprintfmt+0x1ee>
  8005da:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e2:	79 a9                	jns    80058d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e4:	eb 17                	jmp    8005fd <vprintfmt+0x25e>
				putch(' ', putdat);
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f7:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800601:	7f e3                	jg     8005e6 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800603:	e9 70 01 00 00       	jmp    800778 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800608:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	e8 3e fd ff ff       	call   800358 <getint>
  80061a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80061d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800623:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800626:	85 d2                	test   %edx,%edx
  800628:	79 26                	jns    800650 <vprintfmt+0x2b1>
				putch('-', putdat);
  80062a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800631:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800638:	8b 45 08             	mov    0x8(%ebp),%eax
  80063b:	ff d0                	call   *%eax
				num = -(long long) num;
  80063d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800640:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800643:	f7 d8                	neg    %eax
  800645:	83 d2 00             	adc    $0x0,%edx
  800648:	f7 da                	neg    %edx
  80064a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80064d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800650:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800657:	e9 a8 00 00 00       	jmp    800704 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80065f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	89 04 24             	mov    %eax,(%esp)
  800669:	e8 9b fc ff ff       	call   800309 <getuint>
  80066e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800671:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800674:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80067b:	e9 84 00 00 00       	jmp    800704 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800680:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800683:	89 44 24 04          	mov    %eax,0x4(%esp)
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	89 04 24             	mov    %eax,(%esp)
  80068d:	e8 77 fc ff ff       	call   800309 <getuint>
  800692:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800695:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800698:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80069f:	eb 63                	jmp    800704 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006af:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b2:	ff d0                	call   *%eax
			putch('x', putdat);
  8006b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 04             	lea    0x4(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006dc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006e3:	eb 1f                	jmp    800704 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 12 fc ff ff       	call   800309 <getuint>
  8006f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006fd:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800704:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800708:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80070f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800712:	89 54 24 14          	mov    %edx,0x14(%esp)
  800716:	89 44 24 10          	mov    %eax,0x10(%esp)
  80071a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800720:	89 44 24 08          	mov    %eax,0x8(%esp)
  800724:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	89 04 24             	mov    %eax,(%esp)
  800735:	e8 f1 fa ff ff       	call   80022b <printnum>
			break;
  80073a:	eb 3c                	jmp    800778 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800743:	89 1c 24             	mov    %ebx,(%esp)
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	ff d0                	call   *%eax
			break;
  80074b:	eb 2b                	jmp    800778 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800750:	89 44 24 04          	mov    %eax,0x4(%esp)
  800754:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800760:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800764:	eb 04                	jmp    80076a <vprintfmt+0x3cb>
  800766:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	83 e8 01             	sub    $0x1,%eax
  800770:	0f b6 00             	movzbl (%eax),%eax
  800773:	3c 25                	cmp    $0x25,%al
  800775:	75 ef                	jne    800766 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800777:	90                   	nop
		}
	}
  800778:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800779:	e9 43 fc ff ff       	jmp    8003c1 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80077e:	83 c4 40             	add    $0x40,%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800794:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800798:	8b 45 10             	mov    0x10(%ebp),%eax
  80079b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	89 04 24             	mov    %eax,(%esp)
  8007ac:	e8 ee fb ff ff       	call   80039f <vprintfmt>
	va_end(ap);
}
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8007b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b9:	8b 40 08             	mov    0x8(%eax),%eax
  8007bc:	8d 50 01             	lea    0x1(%eax),%edx
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c2:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cd:	8b 40 04             	mov    0x4(%eax),%eax
  8007d0:	39 c2                	cmp    %eax,%edx
  8007d2:	73 12                	jae    8007e6 <sprintputch+0x33>
		*b->buf++ = ch;
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	8d 48 01             	lea    0x1(%eax),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007df:	89 0a                	mov    %ecx,(%edx)
  8007e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007e4:	88 10                	mov    %dl,(%eax)
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	01 d0                	add    %edx,%eax
  8007ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800802:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800809:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80080d:	74 06                	je     800815 <vsnprintf+0x2d>
  80080f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800813:	7f 07                	jg     80081c <vsnprintf+0x34>
		return -E_INVAL;
  800815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081a:	eb 2a                	jmp    800846 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800823:	8b 45 10             	mov    0x10(%ebp),%eax
  800826:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	c7 04 24 b3 07 80 00 	movl   $0x8007b3,(%esp)
  800838:	e8 62 fb ff ff       	call   80039f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800840:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800843:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084e:	8d 45 14             	lea    0x14(%ebp),%eax
  800851:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800857:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085b:	8b 45 10             	mov    0x10(%ebp),%eax
  80085e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800862:	8b 45 0c             	mov    0xc(%ebp),%eax
  800865:	89 44 24 04          	mov    %eax,0x4(%esp)
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	e8 74 ff ff ff       	call   8007e8 <vsnprintf>
  800874:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800877:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800889:	eb 08                	jmp    800893 <strlen+0x17>
		n++;
  80088b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	0f b6 00             	movzbl (%eax),%eax
  800899:	84 c0                	test   %al,%al
  80089b:	75 ee                	jne    80088b <strlen+0xf>
		n++;
	return n;
  80089d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008af:	eb 0c                	jmp    8008bd <strnlen+0x1b>
		n++;
  8008b1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008b9:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8008bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008c1:	74 0a                	je     8008cd <strnlen+0x2b>
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 00             	movzbl (%eax),%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	75 e4                	jne    8008b1 <strnlen+0xf>
		n++;
	return n;
  8008cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008de:	90                   	nop
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8d 50 01             	lea    0x1(%eax),%edx
  8008e5:	89 55 08             	mov    %edx,0x8(%ebp)
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008ee:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	88 10                	mov    %dl,(%eax)
  8008f6:	0f b6 00             	movzbl (%eax),%eax
  8008f9:	84 c0                	test   %al,%al
  8008fb:	75 e2                	jne    8008df <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 69 ff ff ff       	call   80087c <strlen>
  800913:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800916:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	01 c2                	add    %eax,%edx
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	89 44 24 04          	mov    %eax,0x4(%esp)
  800925:	89 14 24             	mov    %edx,(%esp)
  800928:	e8 a5 ff ff ff       	call   8008d2 <strcpy>
	return dst;
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80093e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800945:	eb 23                	jmp    80096a <strncpy+0x38>
		*dst++ = *src;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8d 50 01             	lea    0x1(%eax),%edx
  80094d:	89 55 08             	mov    %edx,0x8(%ebp)
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	0f b6 00             	movzbl (%eax),%eax
  80095e:	84 c0                	test   %al,%al
  800960:	74 04                	je     800966 <strncpy+0x34>
			src++;
  800962:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800966:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80096a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80096d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800970:	72 d5                	jb     800947 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800972:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800983:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800987:	74 33                	je     8009bc <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800989:	eb 17                	jmp    8009a2 <strlcpy+0x2b>
			*dst++ = *src++;
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8d 50 01             	lea    0x1(%eax),%edx
  800991:	89 55 08             	mov    %edx,0x8(%ebp)
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	8d 4a 01             	lea    0x1(%edx),%ecx
  80099a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80099d:	0f b6 12             	movzbl (%edx),%edx
  8009a0:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009aa:	74 0a                	je     8009b6 <strlcpy+0x3f>
  8009ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009af:	0f b6 00             	movzbl (%eax),%eax
  8009b2:	84 c0                	test   %al,%al
  8009b4:	75 d5                	jne    80098b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009c2:	29 c2                	sub    %eax,%edx
  8009c4:	89 d0                	mov    %edx,%eax
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009cb:	eb 08                	jmp    8009d5 <strcmp+0xd>
		p++, q++;
  8009cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	0f b6 00             	movzbl (%eax),%eax
  8009db:	84 c0                	test   %al,%al
  8009dd:	74 10                	je     8009ef <strcmp+0x27>
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	0f b6 10             	movzbl (%eax),%edx
  8009e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e8:	0f b6 00             	movzbl (%eax),%eax
  8009eb:	38 c2                	cmp    %al,%dl
  8009ed:	74 de                	je     8009cd <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	0f b6 00             	movzbl (%eax),%eax
  8009f5:	0f b6 d0             	movzbl %al,%edx
  8009f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fb:	0f b6 00             	movzbl (%eax),%eax
  8009fe:	0f b6 c0             	movzbl %al,%eax
  800a01:	29 c2                	sub    %eax,%edx
  800a03:	89 d0                	mov    %edx,%eax
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a0a:	eb 0c                	jmp    800a18 <strncmp+0x11>
		n--, p++, q++;
  800a0c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a14:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a1c:	74 1a                	je     800a38 <strncmp+0x31>
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 00             	movzbl (%eax),%eax
  800a24:	84 c0                	test   %al,%al
  800a26:	74 10                	je     800a38 <strncmp+0x31>
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	0f b6 10             	movzbl (%eax),%edx
  800a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a31:	0f b6 00             	movzbl (%eax),%eax
  800a34:	38 c2                	cmp    %al,%dl
  800a36:	74 d4                	je     800a0c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a3c:	75 07                	jne    800a45 <strncmp+0x3e>
		return 0;
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	eb 16                	jmp    800a5b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	0f b6 00             	movzbl (%eax),%eax
  800a4b:	0f b6 d0             	movzbl %al,%edx
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	0f b6 00             	movzbl (%eax),%eax
  800a54:	0f b6 c0             	movzbl %al,%eax
  800a57:	29 c2                	sub    %eax,%edx
  800a59:	89 d0                	mov    %edx,%eax
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	83 ec 04             	sub    $0x4,%esp
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a69:	eb 14                	jmp    800a7f <strchr+0x22>
		if (*s == c)
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	0f b6 00             	movzbl (%eax),%eax
  800a71:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a74:	75 05                	jne    800a7b <strchr+0x1e>
			return (char *) s;
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	eb 13                	jmp    800a8e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	0f b6 00             	movzbl (%eax),%eax
  800a85:	84 c0                	test   %al,%al
  800a87:	75 e2                	jne    800a6b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 04             	sub    $0x4,%esp
  800a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a99:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a9c:	eb 11                	jmp    800aaf <strfind+0x1f>
		if (*s == c)
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 00             	movzbl (%eax),%eax
  800aa4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aa7:	75 02                	jne    800aab <strfind+0x1b>
			break;
  800aa9:	eb 0e                	jmp    800ab9 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	0f b6 00             	movzbl (%eax),%eax
  800ab5:	84 c0                	test   %al,%al
  800ab7:	75 e5                	jne    800a9e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800abc:	c9                   	leave  
  800abd:	c3                   	ret    

00800abe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ac2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac6:	75 05                	jne    800acd <memset+0xf>
		return v;
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	eb 5c                	jmp    800b29 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	83 e0 03             	and    $0x3,%eax
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	75 41                	jne    800b18 <memset+0x5a>
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	83 e0 03             	and    $0x3,%eax
  800add:	85 c0                	test   %eax,%eax
  800adf:	75 37                	jne    800b18 <memset+0x5a>
		c &= 0xFF;
  800ae1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	c1 e0 18             	shl    $0x18,%eax
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	c1 e0 10             	shl    $0x10,%eax
  800af6:	09 c2                	or     %eax,%edx
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	c1 e0 08             	shl    $0x8,%eax
  800afe:	09 d0                	or     %edx,%eax
  800b00:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b03:	8b 45 10             	mov    0x10(%ebp),%eax
  800b06:	c1 e8 02             	shr    $0x2,%eax
  800b09:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	fc                   	cld    
  800b14:	f3 ab                	rep stos %eax,%es:(%edi)
  800b16:	eb 0e                	jmp    800b26 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b18:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b21:	89 d7                	mov    %edx,%edi
  800b23:	fc                   	cld    
  800b24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b44:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b47:	73 6d                	jae    800bb6 <memmove+0x8a>
  800b49:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b4f:	01 d0                	add    %edx,%eax
  800b51:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b54:	76 60                	jbe    800bb6 <memmove+0x8a>
		s += n;
  800b56:	8b 45 10             	mov    0x10(%ebp),%eax
  800b59:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b65:	83 e0 03             	and    $0x3,%eax
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	75 2f                	jne    800b9b <memmove+0x6f>
  800b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6f:	83 e0 03             	and    $0x3,%eax
  800b72:	85 c0                	test   %eax,%eax
  800b74:	75 25                	jne    800b9b <memmove+0x6f>
  800b76:	8b 45 10             	mov    0x10(%ebp),%eax
  800b79:	83 e0 03             	and    $0x3,%eax
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	75 1b                	jne    800b9b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b83:	83 e8 04             	sub    $0x4,%eax
  800b86:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b89:	83 ea 04             	sub    $0x4,%edx
  800b8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b8f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 d6                	mov    %edx,%esi
  800b96:	fd                   	std    
  800b97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b99:	eb 18                	jmp    800bb3 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b9e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba4:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
  800baa:	89 d7                	mov    %edx,%edi
  800bac:	89 de                	mov    %ebx,%esi
  800bae:	89 c1                	mov    %eax,%ecx
  800bb0:	fd                   	std    
  800bb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb3:	fc                   	cld    
  800bb4:	eb 45                	jmp    800bfb <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb9:	83 e0 03             	and    $0x3,%eax
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	75 2b                	jne    800beb <memmove+0xbf>
  800bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc3:	83 e0 03             	and    $0x3,%eax
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	75 21                	jne    800beb <memmove+0xbf>
  800bca:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcd:	83 e0 03             	and    $0x3,%eax
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	75 17                	jne    800beb <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd7:	c1 e8 02             	shr    $0x2,%eax
  800bda:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bdf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be2:	89 c7                	mov    %eax,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	fc                   	cld    
  800be7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800be9:	eb 10                	jmp    800bfb <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800beb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	fc                   	cld    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	89 04 24             	mov    %eax,(%esp)
  800c20:	e8 07 ff ff ff       	call   800b2c <memmove>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c39:	eb 30                	jmp    800c6b <memcmp+0x44>
		if (*s1 != *s2)
  800c3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c3e:	0f b6 10             	movzbl (%eax),%edx
  800c41:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c44:	0f b6 00             	movzbl (%eax),%eax
  800c47:	38 c2                	cmp    %al,%dl
  800c49:	74 18                	je     800c63 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c4e:	0f b6 00             	movzbl (%eax),%eax
  800c51:	0f b6 d0             	movzbl %al,%edx
  800c54:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c57:	0f b6 00             	movzbl (%eax),%eax
  800c5a:	0f b6 c0             	movzbl %al,%eax
  800c5d:	29 c2                	sub    %eax,%edx
  800c5f:	89 d0                	mov    %edx,%eax
  800c61:	eb 1a                	jmp    800c7d <memcmp+0x56>
		s1++, s2++;
  800c63:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c67:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c71:	89 55 10             	mov    %edx,0x10(%ebp)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	75 c3                	jne    800c3b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c85:	8b 45 10             	mov    0x10(%ebp),%eax
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	01 d0                	add    %edx,%eax
  800c8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c90:	eb 13                	jmp    800ca5 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	0f b6 10             	movzbl (%eax),%edx
  800c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9b:	38 c2                	cmp    %al,%dl
  800c9d:	75 02                	jne    800ca1 <memfind+0x22>
			break;
  800c9f:	eb 0c                	jmp    800cad <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cab:	72 e5                	jb     800c92 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cb8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cbf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc6:	eb 04                	jmp    800ccc <strtol+0x1a>
		s++;
  800cc8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	0f b6 00             	movzbl (%eax),%eax
  800cd2:	3c 20                	cmp    $0x20,%al
  800cd4:	74 f2                	je     800cc8 <strtol+0x16>
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	0f b6 00             	movzbl (%eax),%eax
  800cdc:	3c 09                	cmp    $0x9,%al
  800cde:	74 e8                	je     800cc8 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	0f b6 00             	movzbl (%eax),%eax
  800ce6:	3c 2b                	cmp    $0x2b,%al
  800ce8:	75 06                	jne    800cf0 <strtol+0x3e>
		s++;
  800cea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cee:	eb 15                	jmp    800d05 <strtol+0x53>
	else if (*s == '-')
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	0f b6 00             	movzbl (%eax),%eax
  800cf6:	3c 2d                	cmp    $0x2d,%al
  800cf8:	75 0b                	jne    800d05 <strtol+0x53>
		s++, neg = 1;
  800cfa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cfe:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d09:	74 06                	je     800d11 <strtol+0x5f>
  800d0b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d0f:	75 24                	jne    800d35 <strtol+0x83>
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	0f b6 00             	movzbl (%eax),%eax
  800d17:	3c 30                	cmp    $0x30,%al
  800d19:	75 1a                	jne    800d35 <strtol+0x83>
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	83 c0 01             	add    $0x1,%eax
  800d21:	0f b6 00             	movzbl (%eax),%eax
  800d24:	3c 78                	cmp    $0x78,%al
  800d26:	75 0d                	jne    800d35 <strtol+0x83>
		s += 2, base = 16;
  800d28:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d2c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d33:	eb 2a                	jmp    800d5f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d39:	75 17                	jne    800d52 <strtol+0xa0>
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	0f b6 00             	movzbl (%eax),%eax
  800d41:	3c 30                	cmp    $0x30,%al
  800d43:	75 0d                	jne    800d52 <strtol+0xa0>
		s++, base = 8;
  800d45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d49:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d50:	eb 0d                	jmp    800d5f <strtol+0xad>
	else if (base == 0)
  800d52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d56:	75 07                	jne    800d5f <strtol+0xad>
		base = 10;
  800d58:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	0f b6 00             	movzbl (%eax),%eax
  800d65:	3c 2f                	cmp    $0x2f,%al
  800d67:	7e 1b                	jle    800d84 <strtol+0xd2>
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	0f b6 00             	movzbl (%eax),%eax
  800d6f:	3c 39                	cmp    $0x39,%al
  800d71:	7f 11                	jg     800d84 <strtol+0xd2>
			dig = *s - '0';
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	0f b6 00             	movzbl (%eax),%eax
  800d79:	0f be c0             	movsbl %al,%eax
  800d7c:	83 e8 30             	sub    $0x30,%eax
  800d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d82:	eb 48                	jmp    800dcc <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	0f b6 00             	movzbl (%eax),%eax
  800d8a:	3c 60                	cmp    $0x60,%al
  800d8c:	7e 1b                	jle    800da9 <strtol+0xf7>
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	3c 7a                	cmp    $0x7a,%al
  800d96:	7f 11                	jg     800da9 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	0f be c0             	movsbl %al,%eax
  800da1:	83 e8 57             	sub    $0x57,%eax
  800da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800da7:	eb 23                	jmp    800dcc <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	0f b6 00             	movzbl (%eax),%eax
  800daf:	3c 40                	cmp    $0x40,%al
  800db1:	7e 3d                	jle    800df0 <strtol+0x13e>
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	0f b6 00             	movzbl (%eax),%eax
  800db9:	3c 5a                	cmp    $0x5a,%al
  800dbb:	7f 33                	jg     800df0 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	0f b6 00             	movzbl (%eax),%eax
  800dc3:	0f be c0             	movsbl %al,%eax
  800dc6:	83 e8 37             	sub    $0x37,%eax
  800dc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dd2:	7c 02                	jl     800dd6 <strtol+0x124>
			break;
  800dd4:	eb 1a                	jmp    800df0 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dd6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dda:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ddd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de6:	01 d0                	add    %edx,%eax
  800de8:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800deb:	e9 6f ff ff ff       	jmp    800d5f <strtol+0xad>

	if (endptr)
  800df0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df4:	74 08                	je     800dfe <strtol+0x14c>
		*endptr = (char *) s;
  800df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dfe:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e02:	74 07                	je     800e0b <strtol+0x159>
  800e04:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e07:	f7 d8                	neg    %eax
  800e09:	eb 03                	jmp    800e0e <strtol+0x15c>
  800e0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    

00800e10 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e1f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e22:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e25:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e28:	8b 75 20             	mov    0x20(%ebp),%esi
  800e2b:	cd 30                	int    $0x30
  800e2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e34:	74 30                	je     800e66 <syscall+0x56>
  800e36:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e3a:	7e 2a                	jle    800e66 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4a:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800e61:	e8 8c 08 00 00       	call   8016f2 <_panic>

	return ret;
  800e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e69:	83 c4 3c             	add    $0x3c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e81:	00 
  800e82:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e89:	00 
  800e8a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e91:	00 
  800e92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e95:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e99:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eac:	e8 5f ff ff ff       	call   800e10 <syscall>
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800eb9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee8:	00 
  800ee9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ef0:	e8 1b ff ff ff       	call   800e10 <syscall>
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f07:	00 
  800f08:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f0f:	00 
  800f10:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f17:	00 
  800f18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1f:	00 
  800f20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f24:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f33:	e8 d8 fe ff ff       	call   800e10 <syscall>
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f40:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f47:	00 
  800f48:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f4f:	00 
  800f50:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f57:	00 
  800f58:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5f:	00 
  800f60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f67:	00 
  800f68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6f:	00 
  800f70:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f77:	e8 94 fe ff ff       	call   800e10 <syscall>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <sys_yield>:

void
sys_yield(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f84:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f93:	00 
  800f94:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800fbb:	e8 50 fe ff ff       	call   800e10 <syscall>
}
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fc8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe0:	00 
  800fe1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ff4:	00 
  800ff5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800ffc:	e8 0f fe ff ff       	call   800e10 <syscall>
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80100b:	8b 75 18             	mov    0x18(%ebp),%esi
  80100e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801011:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801014:	8b 55 0c             	mov    0xc(%ebp),%edx
  801017:	8b 45 08             	mov    0x8(%ebp),%eax
  80101a:	89 74 24 18          	mov    %esi,0x18(%esp)
  80101e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801022:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801026:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80103d:	e8 ce fd ff ff       	call   800e10 <syscall>
}
  801042:	83 c4 20             	add    $0x20,%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80104f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801052:	8b 45 08             	mov    0x8(%ebp),%eax
  801055:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80105c:	00 
  80105d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801064:	00 
  801065:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80106c:	00 
  80106d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801071:	89 44 24 08          	mov    %eax,0x8(%esp)
  801075:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801084:	e8 87 fd ff ff       	call   800e10 <syscall>
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801091:	8b 55 0c             	mov    0xc(%ebp),%edx
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80109e:	00 
  80109f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010a6:	00 
  8010a7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010ae:	00 
  8010af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010be:	00 
  8010bf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8010c6:	e8 45 fd ff ff       	call   800e10 <syscall>
}
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    

008010cd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010f0:	00 
  8010f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801100:	00 
  801101:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801108:	e8 03 fd ff ff       	call   800e10 <syscall>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801115:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801118:	8b 55 10             	mov    0x10(%ebp),%edx
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801125:	00 
  801126:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80112a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80112e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801131:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801135:	89 44 24 08          	mov    %eax,0x8(%esp)
  801139:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801140:	00 
  801141:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801148:	e8 c3 fc ff ff       	call   800e10 <syscall>
}
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80115f:	00 
  801160:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801167:	00 
  801168:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80116f:	00 
  801170:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801177:	00 
  801178:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801183:	00 
  801184:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80118b:	e8 80 fc ff ff       	call   800e10 <syscall>
}
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <sys_exec>:

void sys_exec(char* buf){
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011ba:	00 
  8011bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011c6:	00 
  8011c7:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8011ce:	e8 3d fc ff ff       	call   800e10 <syscall>
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <sys_wait>:

void sys_wait(){
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  8011db:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801202:	00 
  801203:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801212:	e8 f9 fb ff ff       	call   800e10 <syscall>
}
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <sys_guest>:

void sys_guest(){
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  80121f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801226:	00 
  801227:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80122e:	00 
  80122f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801236:	00 
  801237:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80123e:	00 
  80123f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801246:	00 
  801247:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80124e:	00 
  80124f:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  801256:	e8 b5 fb ff ff       	call   800e10 <syscall>
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	8b 00                	mov    (%eax),%eax
  801268:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	8b 40 04             	mov    0x4(%eax),%eax
  801271:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	83 e0 02             	and    $0x2,%eax
  80127a:	85 c0                	test   %eax,%eax
  80127c:	75 23                	jne    8012a1 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801285:	c7 44 24 08 30 1d 80 	movl   $0x801d30,0x8(%esp)
  80128c:	00 
  80128d:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801294:	00 
  801295:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80129c:	e8 51 04 00 00       	call   8016f2 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  8012a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a4:	c1 e8 0c             	shr    $0xc,%eax
  8012a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8012aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b4:	25 00 08 00 00       	and    $0x800,%eax
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	75 1c                	jne    8012d9 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8012bd:	c7 44 24 08 6c 1d 80 	movl   $0x801d6c,0x8(%esp)
  8012c4:	00 
  8012c5:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8012cc:	00 
  8012cd:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8012d4:	e8 19 04 00 00       	call   8016f2 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8012d9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f0:	e8 cd fc ff ff       	call   800fc2 <sys_page_alloc>
  8012f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012fc:	79 23                	jns    801321 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8012fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801305:	c7 44 24 08 a8 1d 80 	movl   $0x801da8,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80131c:	e8 d1 03 00 00       	call   8016f2 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80132a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801336:	00 
  801337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801342:	e8 bf f8 ff ff       	call   800c06 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801347:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801350:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801355:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80135c:	00 
  80135d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801361:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801368:	00 
  801369:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801370:	00 
  801371:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801378:	e8 86 fc ff ff       	call   801003 <sys_page_map>
  80137d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801380:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801384:	79 23                	jns    8013a9 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801386:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138d:	c7 44 24 08 e0 1d 80 	movl   $0x801de0,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8013a4:	e8 49 03 00 00       	call   8016f2 <_panic>
	}

	// panic("pgfault not implemented");
}
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8013b3:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8013ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c4:	25 00 08 00 00       	and    $0x800,%eax
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	75 15                	jne    8013e2 <duppage+0x37>
  8013cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d7:	83 e0 02             	and    $0x2,%eax
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	0f 84 e0 00 00 00    	je     8014c2 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8013e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ec:	83 e0 04             	and    $0x4,%eax
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	74 04                	je     8013f7 <duppage+0x4c>
  8013f3:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8013f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fd:	c1 e0 0c             	shl    $0xc,%eax
  801400:	89 c1                	mov    %eax,%ecx
  801402:	8b 45 0c             	mov    0xc(%ebp),%eax
  801405:	c1 e0 0c             	shl    $0xc,%eax
  801408:	89 c2                	mov    %eax,%edx
  80140a:	a1 04 20 80 00       	mov    0x802004,%eax
  80140f:	8b 40 48             	mov    0x48(%eax),%eax
  801412:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801416:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80141a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801421:	89 54 24 04          	mov    %edx,0x4(%esp)
  801425:	89 04 24             	mov    %eax,(%esp)
  801428:	e8 d6 fb ff ff       	call   801003 <sys_page_map>
  80142d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801430:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801434:	79 23                	jns    801459 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143d:	c7 44 24 08 14 1e 80 	movl   $0x801e14,0x8(%esp)
  801444:	00 
  801445:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80144c:	00 
  80144d:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801454:	e8 99 02 00 00       	call   8016f2 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801459:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	c1 e0 0c             	shl    $0xc,%eax
  801462:	89 c3                	mov    %eax,%ebx
  801464:	a1 04 20 80 00       	mov    0x802004,%eax
  801469:	8b 48 48             	mov    0x48(%eax),%ecx
  80146c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146f:	c1 e0 0c             	shl    $0xc,%eax
  801472:	89 c2                	mov    %eax,%edx
  801474:	a1 04 20 80 00       	mov    0x802004,%eax
  801479:	8b 40 48             	mov    0x48(%eax),%eax
  80147c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801480:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801484:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801488:	89 54 24 04          	mov    %edx,0x4(%esp)
  80148c:	89 04 24             	mov    %eax,(%esp)
  80148f:	e8 6f fb ff ff       	call   801003 <sys_page_map>
  801494:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801497:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80149b:	79 23                	jns    8014c0 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80149d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a4:	c7 44 24 08 50 1e 80 	movl   $0x801e50,0x8(%esp)
  8014ab:	00 
  8014ac:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8014b3:	00 
  8014b4:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8014bb:	e8 32 02 00 00       	call   8016f2 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014c0:	eb 70                	jmp    801532 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  8014c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cc:	25 ff 0f 00 00       	and    $0xfff,%eax
  8014d1:	89 c3                	mov    %eax,%ebx
  8014d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d6:	c1 e0 0c             	shl    $0xc,%eax
  8014d9:	89 c1                	mov    %eax,%ecx
  8014db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014de:	c1 e0 0c             	shl    $0xc,%eax
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	a1 04 20 80 00       	mov    0x802004,%eax
  8014e8:	8b 40 48             	mov    0x48(%eax),%eax
  8014eb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014ef:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014fe:	89 04 24             	mov    %eax,(%esp)
  801501:	e8 fd fa ff ff       	call   801003 <sys_page_map>
  801506:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801509:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80150d:	79 23                	jns    801532 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801516:	c7 44 24 08 80 1e 80 	movl   $0x801e80,0x8(%esp)
  80151d:	00 
  80151e:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801525:	00 
  801526:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80152d:	e8 c0 01 00 00       	call   8016f2 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801537:	83 c4 30             	add    $0x30,%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    

0080153e <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801544:	c7 04 24 5d 12 80 00 	movl   $0x80125d,(%esp)
  80154b:	e8 fd 01 00 00       	call   80174d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801550:	b8 07 00 00 00       	mov    $0x7,%eax
  801555:	cd 30                	int    $0x30
  801557:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80155a:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80155d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  801560:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801564:	79 23                	jns    801589 <fork+0x4b>
  801566:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801569:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80156d:	c7 44 24 08 b8 1e 80 	movl   $0x801eb8,0x8(%esp)
  801574:	00 
  801575:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80157c:	00 
  80157d:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801584:	e8 69 01 00 00       	call   8016f2 <_panic>
	else if(childeid == 0){
  801589:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80158d:	75 29                	jne    8015b8 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  80158f:	e8 a6 f9 ff ff       	call   800f3a <sys_getenvid>
  801594:	25 ff 03 00 00       	and    $0x3ff,%eax
  801599:	c1 e0 02             	shl    $0x2,%eax
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	c1 e2 05             	shl    $0x5,%edx
  8015a1:	29 c2                	sub    %eax,%edx
  8015a3:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8015a9:	a3 04 20 80 00       	mov    %eax,0x802004
		// set_pgfault_handler(pgfault);
		return 0;
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b3:	e9 16 01 00 00       	jmp    8016ce <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8015bf:	eb 3b                	jmp    8015fc <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  8015c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c4:	c1 f8 0a             	sar    $0xa,%eax
  8015c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ce:	83 e0 01             	and    $0x1,%eax
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	74 23                	je     8015f8 <fork+0xba>
  8015d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015df:	83 e0 01             	and    $0x1,%eax
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	74 12                	je     8015f8 <fork+0xba>
			duppage(childeid, i);
  8015e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	89 04 24             	mov    %eax,(%esp)
  8015f3:	e8 b3 fd ff ff       	call   8013ab <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8015fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ff:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801604:	76 bb                	jbe    8015c1 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801606:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80160d:	00 
  80160e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801615:	ee 
  801616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801619:	89 04 24             	mov    %eax,(%esp)
  80161c:	e8 a1 f9 ff ff       	call   800fc2 <sys_page_alloc>
  801621:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801624:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801628:	79 23                	jns    80164d <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  80162a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80162d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801631:	c7 44 24 08 e0 1e 80 	movl   $0x801ee0,0x8(%esp)
  801638:	00 
  801639:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801640:	00 
  801641:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801648:	e8 a5 00 00 00       	call   8016f2 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80164d:	c7 44 24 04 c3 17 80 	movl   $0x8017c3,0x4(%esp)
  801654:	00 
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	89 04 24             	mov    %eax,(%esp)
  80165b:	e8 6d fa ff ff       	call   8010cd <sys_env_set_pgfault_upcall>
  801660:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801663:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801667:	79 23                	jns    80168c <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  801669:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80166c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801670:	c7 44 24 08 08 1f 80 	movl   $0x801f08,0x8(%esp)
  801677:	00 
  801678:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  80167f:	00 
  801680:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801687:	e8 66 00 00 00       	call   8016f2 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  80168c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801693:	00 
  801694:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 ec f9 ff ff       	call   80108b <sys_env_set_status>
  80169f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016a6:	79 23                	jns    8016cb <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8016a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016af:	c7 44 24 08 3c 1f 80 	movl   $0x801f3c,0x8(%esp)
  8016b6:	00 
  8016b7:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8016be:	00 
  8016bf:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8016c6:	e8 27 00 00 00       	call   8016f2 <_panic>
	}
	return childeid;
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <sfork>:

// Challenge!
int
sfork(void)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016d6:	c7 44 24 08 65 1f 80 	movl   $0x801f65,0x8(%esp)
  8016dd:	00 
  8016de:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8016e5:	00 
  8016e6:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8016ed:	e8 00 00 00 00       	call   8016f2 <_panic>

008016f2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8016fc:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016ff:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801705:	e8 30 f8 ff ff       	call   800f3a <sys_getenvid>
  80170a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80170d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801711:	8b 55 08             	mov    0x8(%ebp),%edx
  801714:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801718:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80171c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801720:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  801727:	e8 d9 ea ff ff       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80172c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801733:	8b 45 10             	mov    0x10(%ebp),%eax
  801736:	89 04 24             	mov    %eax,(%esp)
  801739:	e8 63 ea ff ff       	call   8001a1 <vcprintf>
	cprintf("\n");
  80173e:	c7 04 24 9f 1f 80 00 	movl   $0x801f9f,(%esp)
  801745:	e8 bb ea ff ff       	call   800205 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80174a:	cc                   	int3   
  80174b:	eb fd                	jmp    80174a <_panic+0x58>

0080174d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801753:	a1 08 20 80 00       	mov    0x802008,%eax
  801758:	85 c0                	test   %eax,%eax
  80175a:	75 5d                	jne    8017b9 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80175c:	a1 04 20 80 00       	mov    0x802004,%eax
  801761:	8b 40 48             	mov    0x48(%eax),%eax
  801764:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80176b:	00 
  80176c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801773:	ee 
  801774:	89 04 24             	mov    %eax,(%esp)
  801777:	e8 46 f8 ff ff       	call   800fc2 <sys_page_alloc>
  80177c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80177f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801783:	79 1c                	jns    8017a1 <set_pgfault_handler+0x54>
  801785:	c7 44 24 08 a4 1f 80 	movl   $0x801fa4,0x8(%esp)
  80178c:	00 
  80178d:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801794:	00 
  801795:	c7 04 24 d0 1f 80 00 	movl   $0x801fd0,(%esp)
  80179c:	e8 51 ff ff ff       	call   8016f2 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8017a1:	a1 04 20 80 00       	mov    0x802004,%eax
  8017a6:	8b 40 48             	mov    0x48(%eax),%eax
  8017a9:	c7 44 24 04 c3 17 80 	movl   $0x8017c3,0x4(%esp)
  8017b0:	00 
  8017b1:	89 04 24             	mov    %eax,(%esp)
  8017b4:	e8 14 f9 ff ff       	call   8010cd <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bc:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017c3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017c4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8017c9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8017cb:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8017ce:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8017d2:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8017d4:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8017d8:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8017d9:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8017dc:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8017de:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8017df:	58                   	pop    %eax
	popal 						// pop all the registers
  8017e0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8017e1:	83 c4 04             	add    $0x4,%esp
	popfl
  8017e4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8017e5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8017e6:	c3                   	ret    
  8017e7:	66 90                	xchg   %ax,%ax
  8017e9:	66 90                	xchg   %ax,%ax
  8017eb:	66 90                	xchg   %ax,%ax
  8017ed:	66 90                	xchg   %ax,%ax
  8017ef:	90                   	nop

008017f0 <__udivdi3>:
  8017f0:	55                   	push   %ebp
  8017f1:	57                   	push   %edi
  8017f2:	56                   	push   %esi
  8017f3:	83 ec 0c             	sub    $0xc,%esp
  8017f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8017fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8017fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801802:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801806:	85 c0                	test   %eax,%eax
  801808:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80180c:	89 ea                	mov    %ebp,%edx
  80180e:	89 0c 24             	mov    %ecx,(%esp)
  801811:	75 2d                	jne    801840 <__udivdi3+0x50>
  801813:	39 e9                	cmp    %ebp,%ecx
  801815:	77 61                	ja     801878 <__udivdi3+0x88>
  801817:	85 c9                	test   %ecx,%ecx
  801819:	89 ce                	mov    %ecx,%esi
  80181b:	75 0b                	jne    801828 <__udivdi3+0x38>
  80181d:	b8 01 00 00 00       	mov    $0x1,%eax
  801822:	31 d2                	xor    %edx,%edx
  801824:	f7 f1                	div    %ecx
  801826:	89 c6                	mov    %eax,%esi
  801828:	31 d2                	xor    %edx,%edx
  80182a:	89 e8                	mov    %ebp,%eax
  80182c:	f7 f6                	div    %esi
  80182e:	89 c5                	mov    %eax,%ebp
  801830:	89 f8                	mov    %edi,%eax
  801832:	f7 f6                	div    %esi
  801834:	89 ea                	mov    %ebp,%edx
  801836:	83 c4 0c             	add    $0xc,%esp
  801839:	5e                   	pop    %esi
  80183a:	5f                   	pop    %edi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    
  80183d:	8d 76 00             	lea    0x0(%esi),%esi
  801840:	39 e8                	cmp    %ebp,%eax
  801842:	77 24                	ja     801868 <__udivdi3+0x78>
  801844:	0f bd e8             	bsr    %eax,%ebp
  801847:	83 f5 1f             	xor    $0x1f,%ebp
  80184a:	75 3c                	jne    801888 <__udivdi3+0x98>
  80184c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801850:	39 34 24             	cmp    %esi,(%esp)
  801853:	0f 86 9f 00 00 00    	jbe    8018f8 <__udivdi3+0x108>
  801859:	39 d0                	cmp    %edx,%eax
  80185b:	0f 82 97 00 00 00    	jb     8018f8 <__udivdi3+0x108>
  801861:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801868:	31 d2                	xor    %edx,%edx
  80186a:	31 c0                	xor    %eax,%eax
  80186c:	83 c4 0c             	add    $0xc,%esp
  80186f:	5e                   	pop    %esi
  801870:	5f                   	pop    %edi
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    
  801873:	90                   	nop
  801874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801878:	89 f8                	mov    %edi,%eax
  80187a:	f7 f1                	div    %ecx
  80187c:	31 d2                	xor    %edx,%edx
  80187e:	83 c4 0c             	add    $0xc,%esp
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    
  801885:	8d 76 00             	lea    0x0(%esi),%esi
  801888:	89 e9                	mov    %ebp,%ecx
  80188a:	8b 3c 24             	mov    (%esp),%edi
  80188d:	d3 e0                	shl    %cl,%eax
  80188f:	89 c6                	mov    %eax,%esi
  801891:	b8 20 00 00 00       	mov    $0x20,%eax
  801896:	29 e8                	sub    %ebp,%eax
  801898:	89 c1                	mov    %eax,%ecx
  80189a:	d3 ef                	shr    %cl,%edi
  80189c:	89 e9                	mov    %ebp,%ecx
  80189e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018a2:	8b 3c 24             	mov    (%esp),%edi
  8018a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018a9:	89 d6                	mov    %edx,%esi
  8018ab:	d3 e7                	shl    %cl,%edi
  8018ad:	89 c1                	mov    %eax,%ecx
  8018af:	89 3c 24             	mov    %edi,(%esp)
  8018b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018b6:	d3 ee                	shr    %cl,%esi
  8018b8:	89 e9                	mov    %ebp,%ecx
  8018ba:	d3 e2                	shl    %cl,%edx
  8018bc:	89 c1                	mov    %eax,%ecx
  8018be:	d3 ef                	shr    %cl,%edi
  8018c0:	09 d7                	or     %edx,%edi
  8018c2:	89 f2                	mov    %esi,%edx
  8018c4:	89 f8                	mov    %edi,%eax
  8018c6:	f7 74 24 08          	divl   0x8(%esp)
  8018ca:	89 d6                	mov    %edx,%esi
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	f7 24 24             	mull   (%esp)
  8018d1:	39 d6                	cmp    %edx,%esi
  8018d3:	89 14 24             	mov    %edx,(%esp)
  8018d6:	72 30                	jb     801908 <__udivdi3+0x118>
  8018d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8018dc:	89 e9                	mov    %ebp,%ecx
  8018de:	d3 e2                	shl    %cl,%edx
  8018e0:	39 c2                	cmp    %eax,%edx
  8018e2:	73 05                	jae    8018e9 <__udivdi3+0xf9>
  8018e4:	3b 34 24             	cmp    (%esp),%esi
  8018e7:	74 1f                	je     801908 <__udivdi3+0x118>
  8018e9:	89 f8                	mov    %edi,%eax
  8018eb:	31 d2                	xor    %edx,%edx
  8018ed:	e9 7a ff ff ff       	jmp    80186c <__udivdi3+0x7c>
  8018f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8018f8:	31 d2                	xor    %edx,%edx
  8018fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ff:	e9 68 ff ff ff       	jmp    80186c <__udivdi3+0x7c>
  801904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801908:	8d 47 ff             	lea    -0x1(%edi),%eax
  80190b:	31 d2                	xor    %edx,%edx
  80190d:	83 c4 0c             	add    $0xc,%esp
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    
  801914:	66 90                	xchg   %ax,%ax
  801916:	66 90                	xchg   %ax,%ax
  801918:	66 90                	xchg   %ax,%ax
  80191a:	66 90                	xchg   %ax,%ax
  80191c:	66 90                	xchg   %ax,%ax
  80191e:	66 90                	xchg   %ax,%ax

00801920 <__umoddi3>:
  801920:	55                   	push   %ebp
  801921:	57                   	push   %edi
  801922:	56                   	push   %esi
  801923:	83 ec 14             	sub    $0x14,%esp
  801926:	8b 44 24 28          	mov    0x28(%esp),%eax
  80192a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80192e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801932:	89 c7                	mov    %eax,%edi
  801934:	89 44 24 04          	mov    %eax,0x4(%esp)
  801938:	8b 44 24 30          	mov    0x30(%esp),%eax
  80193c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801940:	89 34 24             	mov    %esi,(%esp)
  801943:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801947:	85 c0                	test   %eax,%eax
  801949:	89 c2                	mov    %eax,%edx
  80194b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80194f:	75 17                	jne    801968 <__umoddi3+0x48>
  801951:	39 fe                	cmp    %edi,%esi
  801953:	76 4b                	jbe    8019a0 <__umoddi3+0x80>
  801955:	89 c8                	mov    %ecx,%eax
  801957:	89 fa                	mov    %edi,%edx
  801959:	f7 f6                	div    %esi
  80195b:	89 d0                	mov    %edx,%eax
  80195d:	31 d2                	xor    %edx,%edx
  80195f:	83 c4 14             	add    $0x14,%esp
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    
  801966:	66 90                	xchg   %ax,%ax
  801968:	39 f8                	cmp    %edi,%eax
  80196a:	77 54                	ja     8019c0 <__umoddi3+0xa0>
  80196c:	0f bd e8             	bsr    %eax,%ebp
  80196f:	83 f5 1f             	xor    $0x1f,%ebp
  801972:	75 5c                	jne    8019d0 <__umoddi3+0xb0>
  801974:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801978:	39 3c 24             	cmp    %edi,(%esp)
  80197b:	0f 87 e7 00 00 00    	ja     801a68 <__umoddi3+0x148>
  801981:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801985:	29 f1                	sub    %esi,%ecx
  801987:	19 c7                	sbb    %eax,%edi
  801989:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80198d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801991:	8b 44 24 08          	mov    0x8(%esp),%eax
  801995:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801999:	83 c4 14             	add    $0x14,%esp
  80199c:	5e                   	pop    %esi
  80199d:	5f                   	pop    %edi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    
  8019a0:	85 f6                	test   %esi,%esi
  8019a2:	89 f5                	mov    %esi,%ebp
  8019a4:	75 0b                	jne    8019b1 <__umoddi3+0x91>
  8019a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ab:	31 d2                	xor    %edx,%edx
  8019ad:	f7 f6                	div    %esi
  8019af:	89 c5                	mov    %eax,%ebp
  8019b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019b5:	31 d2                	xor    %edx,%edx
  8019b7:	f7 f5                	div    %ebp
  8019b9:	89 c8                	mov    %ecx,%eax
  8019bb:	f7 f5                	div    %ebp
  8019bd:	eb 9c                	jmp    80195b <__umoddi3+0x3b>
  8019bf:	90                   	nop
  8019c0:	89 c8                	mov    %ecx,%eax
  8019c2:	89 fa                	mov    %edi,%edx
  8019c4:	83 c4 14             	add    $0x14,%esp
  8019c7:	5e                   	pop    %esi
  8019c8:	5f                   	pop    %edi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    
  8019cb:	90                   	nop
  8019cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d0:	8b 04 24             	mov    (%esp),%eax
  8019d3:	be 20 00 00 00       	mov    $0x20,%esi
  8019d8:	89 e9                	mov    %ebp,%ecx
  8019da:	29 ee                	sub    %ebp,%esi
  8019dc:	d3 e2                	shl    %cl,%edx
  8019de:	89 f1                	mov    %esi,%ecx
  8019e0:	d3 e8                	shr    %cl,%eax
  8019e2:	89 e9                	mov    %ebp,%ecx
  8019e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e8:	8b 04 24             	mov    (%esp),%eax
  8019eb:	09 54 24 04          	or     %edx,0x4(%esp)
  8019ef:	89 fa                	mov    %edi,%edx
  8019f1:	d3 e0                	shl    %cl,%eax
  8019f3:	89 f1                	mov    %esi,%ecx
  8019f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8019fd:	d3 ea                	shr    %cl,%edx
  8019ff:	89 e9                	mov    %ebp,%ecx
  801a01:	d3 e7                	shl    %cl,%edi
  801a03:	89 f1                	mov    %esi,%ecx
  801a05:	d3 e8                	shr    %cl,%eax
  801a07:	89 e9                	mov    %ebp,%ecx
  801a09:	09 f8                	or     %edi,%eax
  801a0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a0f:	f7 74 24 04          	divl   0x4(%esp)
  801a13:	d3 e7                	shl    %cl,%edi
  801a15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a19:	89 d7                	mov    %edx,%edi
  801a1b:	f7 64 24 08          	mull   0x8(%esp)
  801a1f:	39 d7                	cmp    %edx,%edi
  801a21:	89 c1                	mov    %eax,%ecx
  801a23:	89 14 24             	mov    %edx,(%esp)
  801a26:	72 2c                	jb     801a54 <__umoddi3+0x134>
  801a28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a2c:	72 22                	jb     801a50 <__umoddi3+0x130>
  801a2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a32:	29 c8                	sub    %ecx,%eax
  801a34:	19 d7                	sbb    %edx,%edi
  801a36:	89 e9                	mov    %ebp,%ecx
  801a38:	89 fa                	mov    %edi,%edx
  801a3a:	d3 e8                	shr    %cl,%eax
  801a3c:	89 f1                	mov    %esi,%ecx
  801a3e:	d3 e2                	shl    %cl,%edx
  801a40:	89 e9                	mov    %ebp,%ecx
  801a42:	d3 ef                	shr    %cl,%edi
  801a44:	09 d0                	or     %edx,%eax
  801a46:	89 fa                	mov    %edi,%edx
  801a48:	83 c4 14             	add    $0x14,%esp
  801a4b:	5e                   	pop    %esi
  801a4c:	5f                   	pop    %edi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    
  801a4f:	90                   	nop
  801a50:	39 d7                	cmp    %edx,%edi
  801a52:	75 da                	jne    801a2e <__umoddi3+0x10e>
  801a54:	8b 14 24             	mov    (%esp),%edx
  801a57:	89 c1                	mov    %eax,%ecx
  801a59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801a61:	eb cb                	jmp    801a2e <__umoddi3+0x10e>
  801a63:	90                   	nop
  801a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801a6c:	0f 82 0f ff ff ff    	jb     801981 <__umoddi3+0x61>
  801a72:	e9 1a ff ff ff       	jmp    801991 <__umoddi3+0x71>
