
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
  800039:	c7 04 24 00 1a 80 00 	movl   $0x801a00,(%esp)
  800040:	e8 7c 01 00 00       	call   8001c1 <cprintf>
	if ((env = fork()) == 0) {
  800045:	e8 6c 14 00 00       	call   8014b6 <fork>
  80004a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80004d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800051:	75 0e                	jne    800061 <umain+0x2e>
		cprintf("I am the child.  Spinning...\n");
  800053:	c7 04 24 28 1a 80 00 	movl   $0x801a28,(%esp)
  80005a:	e8 62 01 00 00       	call   8001c1 <cprintf>
		while (1)
			/* do nothing */;
  80005f:	eb fe                	jmp    80005f <umain+0x2c>
	}

	cprintf("I am the parent.  Running the child...\n");
  800061:	c7 04 24 48 1a 80 00 	movl   $0x801a48,(%esp)
  800068:	e8 54 01 00 00       	call   8001c1 <cprintf>
	sys_yield();
  80006d:	e8 c8 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  800072:	e8 c3 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  800077:	e8 be 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  80007c:	e8 b9 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  800081:	e8 b4 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  800086:	e8 af 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  80008b:	e8 aa 0e 00 00       	call   800f3a <sys_yield>
	sys_yield();
  800090:	e8 a5 0e 00 00       	call   800f3a <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800095:	c7 04 24 70 1a 80 00 	movl   $0x801a70,(%esp)
  80009c:	e8 20 01 00 00       	call   8001c1 <cprintf>
	sys_env_destroy(env);
  8000a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a4:	89 04 24             	mov    %eax,(%esp)
  8000a7:	e8 07 0e 00 00       	call   800eb3 <sys_env_destroy>
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
  8000b4:	e8 3d 0e 00 00       	call   800ef6 <sys_getenvid>
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	c1 e0 02             	shl    $0x2,%eax
  8000c1:	89 c2                	mov    %eax,%edx
  8000c3:	c1 e2 05             	shl    $0x5,%edx
  8000c6:	29 c2                	sub    %eax,%edx
  8000c8:	89 d0                	mov    %edx,%eax
  8000ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000cf:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  8000d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000db:	8b 45 08             	mov    0x8(%ebp),%eax
  8000de:	89 04 24             	mov    %eax,(%esp)
  8000e1:	e8 4d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e6:	e8 02 00 00 00       	call   8000ed <exit>
}
  8000eb:	c9                   	leave  
  8000ec:	c3                   	ret    

008000ed <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fa:	e8 b4 0d 00 00       	call   800eb3 <sys_env_destroy>
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800107:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010a:	8b 00                	mov    (%eax),%eax
  80010c:	8d 48 01             	lea    0x1(%eax),%ecx
  80010f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800112:	89 0a                	mov    %ecx,(%edx)
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 d1                	mov    %edx,%ecx
  800119:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	8b 00                	mov    (%eax),%eax
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 20                	jne    80014c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80012c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012f:	8b 00                	mov    (%eax),%eax
  800131:	8b 55 0c             	mov    0xc(%ebp),%edx
  800134:	83 c2 08             	add    $0x8,%edx
  800137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013b:	89 14 24             	mov    %edx,(%esp)
  80013e:	e8 ea 0c 00 00       	call   800e2d <sys_cputs>
		b->idx = 0;
  800143:	8b 45 0c             	mov    0xc(%ebp),%eax
  800146:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80014c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014f:	8b 40 04             	mov    0x4(%eax),%eax
  800152:	8d 50 01             	lea    0x1(%eax),%edx
  800155:	8b 45 0c             	mov    0xc(%ebp),%eax
  800158:	89 50 04             	mov    %edx,0x4(%eax)
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800166:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016d:	00 00 00 
	b.cnt = 0;
  800170:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800177:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	89 44 24 08          	mov    %eax,0x8(%esp)
  800188:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 01 01 80 00 	movl   $0x800101,(%esp)
  800199:	e8 bd 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ae:	83 c0 08             	add    $0x8,%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 74 0c 00 00       	call   800e2d <sys_cputs>

	return b.cnt;
  8001b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 7e ff ff ff       	call   80015d <vcprintf>
  8001df:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 34             	sub    $0x34,%esp
  8001ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fa:	8b 45 18             	mov    0x18(%ebp),%eax
  8001fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800202:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800205:	77 72                	ja     800279 <printnum+0x92>
  800207:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80020a:	72 05                	jb     800211 <printnum+0x2a>
  80020c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80020f:	77 68                	ja     800279 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800211:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800214:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800217:	8b 45 18             	mov    0x18(%ebp),%eax
  80021a:	ba 00 00 00 00       	mov    $0x0,%edx
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80022a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80022d:	89 04 24             	mov    %eax,(%esp)
  800230:	89 54 24 04          	mov    %edx,0x4(%esp)
  800234:	e8 27 15 00 00       	call   801760 <__udivdi3>
  800239:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80023c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800240:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800244:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800247:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 82 ff ff ff       	call   8001e7 <printnum>
  800265:	eb 1c                	jmp    800283 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800267:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026e:	8b 45 20             	mov    0x20(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	8b 45 08             	mov    0x8(%ebp),%eax
  800277:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800279:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80027d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800281:	7f e4                	jg     800267 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800283:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800286:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80028e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800291:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800295:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800299:	89 04 24             	mov    %eax,(%esp)
  80029c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a0:	e8 eb 15 00 00       	call   801890 <__umoddi3>
  8002a5:	05 88 1b 80 00       	add    $0x801b88,%eax
  8002aa:	0f b6 00             	movzbl (%eax),%eax
  8002ad:	0f be c0             	movsbl %al,%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	ff d0                	call   *%eax
}
  8002bf:	83 c4 34             	add    $0x34,%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002cc:	7e 14                	jle    8002e2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	8b 00                	mov    (%eax),%eax
  8002d3:	8d 48 08             	lea    0x8(%eax),%ecx
  8002d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d9:	89 0a                	mov    %ecx,(%edx)
  8002db:	8b 50 04             	mov    0x4(%eax),%edx
  8002de:	8b 00                	mov    (%eax),%eax
  8002e0:	eb 30                	jmp    800312 <getuint+0x4d>
	else if (lflag)
  8002e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e6:	74 16                	je     8002fe <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	8b 00                	mov    (%eax),%eax
  8002ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	89 0a                	mov    %ecx,(%edx)
  8002f5:	8b 00                	mov    (%eax),%eax
  8002f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fc:	eb 14                	jmp    800312 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	8b 00                	mov    (%eax),%eax
  800303:	8d 48 04             	lea    0x4(%eax),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 0a                	mov    %ecx,(%edx)
  80030b:	8b 00                	mov    (%eax),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800317:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80031b:	7e 14                	jle    800331 <getint+0x1d>
		return va_arg(*ap, long long);
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	8b 00                	mov    (%eax),%eax
  800322:	8d 48 08             	lea    0x8(%eax),%ecx
  800325:	8b 55 08             	mov    0x8(%ebp),%edx
  800328:	89 0a                	mov    %ecx,(%edx)
  80032a:	8b 50 04             	mov    0x4(%eax),%edx
  80032d:	8b 00                	mov    (%eax),%eax
  80032f:	eb 28                	jmp    800359 <getint+0x45>
	else if (lflag)
  800331:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800335:	74 12                	je     800349 <getint+0x35>
		return va_arg(*ap, long);
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	8d 48 04             	lea    0x4(%eax),%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 0a                	mov    %ecx,(%edx)
  800344:	8b 00                	mov    (%eax),%eax
  800346:	99                   	cltd   
  800347:	eb 10                	jmp    800359 <getint+0x45>
	else
		return va_arg(*ap, int);
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	8b 00                	mov    (%eax),%eax
  80034e:	8d 48 04             	lea    0x4(%eax),%ecx
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	89 0a                	mov    %ecx,(%edx)
  800356:	8b 00                	mov    (%eax),%eax
  800358:	99                   	cltd   
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	56                   	push   %esi
  80035f:	53                   	push   %ebx
  800360:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800363:	eb 18                	jmp    80037d <vprintfmt+0x22>
			if (ch == '\0')
  800365:	85 db                	test   %ebx,%ebx
  800367:	75 05                	jne    80036e <vprintfmt+0x13>
				return;
  800369:	e9 cc 03 00 00       	jmp    80073a <vprintfmt+0x3df>
			putch(ch, putdat);
  80036e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800371:	89 44 24 04          	mov    %eax,0x4(%esp)
  800375:	89 1c 24             	mov    %ebx,(%esp)
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037d:	8b 45 10             	mov    0x10(%ebp),%eax
  800380:	8d 50 01             	lea    0x1(%eax),%edx
  800383:	89 55 10             	mov    %edx,0x10(%ebp)
  800386:	0f b6 00             	movzbl (%eax),%eax
  800389:	0f b6 d8             	movzbl %al,%ebx
  80038c:	83 fb 25             	cmp    $0x25,%ebx
  80038f:	75 d4                	jne    800365 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800391:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800395:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80039c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003a3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003aa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b4:	8d 50 01             	lea    0x1(%eax),%edx
  8003b7:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ba:	0f b6 00             	movzbl (%eax),%eax
  8003bd:	0f b6 d8             	movzbl %al,%ebx
  8003c0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003c3:	83 f8 55             	cmp    $0x55,%eax
  8003c6:	0f 87 3d 03 00 00    	ja     800709 <vprintfmt+0x3ae>
  8003cc:	8b 04 85 ac 1b 80 00 	mov    0x801bac(,%eax,4),%eax
  8003d3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003d9:	eb d6                	jmp    8003b1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003db:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003df:	eb d0                	jmp    8003b1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003eb:	89 d0                	mov    %edx,%eax
  8003ed:	c1 e0 02             	shl    $0x2,%eax
  8003f0:	01 d0                	add    %edx,%eax
  8003f2:	01 c0                	add    %eax,%eax
  8003f4:	01 d8                	add    %ebx,%eax
  8003f6:	83 e8 30             	sub    $0x30,%eax
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ff:	0f b6 00             	movzbl (%eax),%eax
  800402:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800405:	83 fb 2f             	cmp    $0x2f,%ebx
  800408:	7e 0b                	jle    800415 <vprintfmt+0xba>
  80040a:	83 fb 39             	cmp    $0x39,%ebx
  80040d:	7f 06                	jg     800415 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800413:	eb d3                	jmp    8003e8 <vprintfmt+0x8d>
			goto process_precision;
  800415:	eb 33                	jmp    80044a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800425:	eb 23                	jmp    80044a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800427:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042b:	79 0c                	jns    800439 <vprintfmt+0xde>
				width = 0;
  80042d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800434:	e9 78 ff ff ff       	jmp    8003b1 <vprintfmt+0x56>
  800439:	e9 73 ff ff ff       	jmp    8003b1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80043e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800445:	e9 67 ff ff ff       	jmp    8003b1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80044a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044e:	79 12                	jns    800462 <vprintfmt+0x107>
				width = precision, precision = -1;
  800450:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800453:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800456:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80045d:	e9 4f ff ff ff       	jmp    8003b1 <vprintfmt+0x56>
  800462:	e9 4a ff ff ff       	jmp    8003b1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800467:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80046b:	e9 41 ff ff ff       	jmp    8003b1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	8b 00                	mov    (%eax),%eax
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800482:	89 04 24             	mov    %eax,(%esp)
  800485:	8b 45 08             	mov    0x8(%ebp),%eax
  800488:	ff d0                	call   *%eax
			break;
  80048a:	e9 a5 02 00 00       	jmp    800734 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80049a:	85 db                	test   %ebx,%ebx
  80049c:	79 02                	jns    8004a0 <vprintfmt+0x145>
				err = -err;
  80049e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a0:	83 fb 09             	cmp    $0x9,%ebx
  8004a3:	7f 0b                	jg     8004b0 <vprintfmt+0x155>
  8004a5:	8b 34 9d 60 1b 80 00 	mov    0x801b60(,%ebx,4),%esi
  8004ac:	85 f6                	test   %esi,%esi
  8004ae:	75 23                	jne    8004d3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004b0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004b4:	c7 44 24 08 99 1b 80 	movl   $0x801b99,0x8(%esp)
  8004bb:	00 
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	e8 73 02 00 00       	call   800741 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004ce:	e9 61 02 00 00       	jmp    800734 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004d7:	c7 44 24 08 a2 1b 80 	movl   $0x801ba2,0x8(%esp)
  8004de:	00 
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 50 02 00 00       	call   800741 <printfmt>
			break;
  8004f1:	e9 3e 02 00 00       	jmp    800734 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 30                	mov    (%eax),%esi
  800501:	85 f6                	test   %esi,%esi
  800503:	75 05                	jne    80050a <vprintfmt+0x1af>
				p = "(null)";
  800505:	be a5 1b 80 00       	mov    $0x801ba5,%esi
			if (width > 0 && padc != '-')
  80050a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050e:	7e 37                	jle    800547 <vprintfmt+0x1ec>
  800510:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800514:	74 31                	je     800547 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800516:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051d:	89 34 24             	mov    %esi,(%esp)
  800520:	e8 39 03 00 00       	call   80085e <strnlen>
  800525:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800528:	eb 17                	jmp    800541 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80052a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80052e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800531:	89 54 24 04          	mov    %edx,0x4(%esp)
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	8b 45 08             	mov    0x8(%ebp),%eax
  80053b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800541:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800545:	7f e3                	jg     80052a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	eb 38                	jmp    800581 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800549:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054d:	74 1f                	je     80056e <vprintfmt+0x213>
  80054f:	83 fb 1f             	cmp    $0x1f,%ebx
  800552:	7e 05                	jle    800559 <vprintfmt+0x1fe>
  800554:	83 fb 7e             	cmp    $0x7e,%ebx
  800557:	7e 15                	jle    80056e <vprintfmt+0x213>
					putch('?', putdat);
  800559:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800560:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800567:	8b 45 08             	mov    0x8(%ebp),%eax
  80056a:	ff d0                	call   *%eax
  80056c:	eb 0f                	jmp    80057d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80056e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800571:	89 44 24 04          	mov    %eax,0x4(%esp)
  800575:	89 1c 24             	mov    %ebx,(%esp)
  800578:	8b 45 08             	mov    0x8(%ebp),%eax
  80057b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800581:	89 f0                	mov    %esi,%eax
  800583:	8d 70 01             	lea    0x1(%eax),%esi
  800586:	0f b6 00             	movzbl (%eax),%eax
  800589:	0f be d8             	movsbl %al,%ebx
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	74 10                	je     8005a0 <vprintfmt+0x245>
  800590:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800594:	78 b3                	js     800549 <vprintfmt+0x1ee>
  800596:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80059a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059e:	79 a9                	jns    800549 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a0:	eb 17                	jmp    8005b9 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005bd:	7f e3                	jg     8005a2 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005bf:	e9 70 01 00 00       	jmp    800734 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	e8 3e fd ff ff       	call   800314 <getint>
  8005d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	79 26                	jns    80060c <vprintfmt+0x2b1>
				putch('-', putdat);
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f7:	ff d0                	call   *%eax
				num = -(long long) num;
  8005f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ff:	f7 d8                	neg    %eax
  800601:	83 d2 00             	adc    $0x0,%edx
  800604:	f7 da                	neg    %edx
  800606:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800609:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80060c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800613:	e9 a8 00 00 00       	jmp    8006c0 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800618:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	e8 9b fc ff ff       	call   8002c5 <getuint>
  80062a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80062d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800630:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800637:	e9 84 00 00 00       	jmp    8006c0 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80063f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	e8 77 fc ff ff       	call   8002c5 <getuint>
  80064e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800651:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800654:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80065b:	eb 63                	jmp    8006c0 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80065d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800660:	89 44 24 04          	mov    %eax,0x4(%esp)
  800664:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066b:	8b 45 08             	mov    0x8(%ebp),%eax
  80066e:	ff d0                	call   *%eax
			putch('x', putdat);
  800670:	8b 45 0c             	mov    0xc(%ebp),%eax
  800673:	89 44 24 04          	mov    %eax,0x4(%esp)
  800677:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800698:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80069f:	eb 1f                	jmp    8006c0 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	e8 12 fc ff ff       	call   8002c5 <getuint>
  8006b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006b9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c7:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ce:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	89 04 24             	mov    %eax,(%esp)
  8006f1:	e8 f1 fa ff ff       	call   8001e7 <printnum>
			break;
  8006f6:	eb 3c                	jmp    800734 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ff:	89 1c 24             	mov    %ebx,(%esp)
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	ff d0                	call   *%eax
			break;
  800707:	eb 2b                	jmp    800734 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800709:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800710:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800720:	eb 04                	jmp    800726 <vprintfmt+0x3cb>
  800722:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800726:	8b 45 10             	mov    0x10(%ebp),%eax
  800729:	83 e8 01             	sub    $0x1,%eax
  80072c:	0f b6 00             	movzbl (%eax),%eax
  80072f:	3c 25                	cmp    $0x25,%al
  800731:	75 ef                	jne    800722 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800733:	90                   	nop
		}
	}
  800734:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800735:	e9 43 fc ff ff       	jmp    80037d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80073a:	83 c4 40             	add    $0x40,%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5d                   	pop    %ebp
  800740:	c3                   	ret    

00800741 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800750:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800754:	8b 45 10             	mov    0x10(%ebp),%eax
  800757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	e8 ee fb ff ff       	call   80035b <vprintfmt>
	va_end(ap);
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800772:	8b 45 0c             	mov    0xc(%ebp),%eax
  800775:	8b 40 08             	mov    0x8(%eax),%eax
  800778:	8d 50 01             	lea    0x1(%eax),%edx
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800781:	8b 45 0c             	mov    0xc(%ebp),%eax
  800784:	8b 10                	mov    (%eax),%edx
  800786:	8b 45 0c             	mov    0xc(%ebp),%eax
  800789:	8b 40 04             	mov    0x4(%eax),%eax
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	73 12                	jae    8007a2 <sprintputch+0x33>
		*b->buf++ = ch;
  800790:	8b 45 0c             	mov    0xc(%ebp),%eax
  800793:	8b 00                	mov    (%eax),%eax
  800795:	8d 48 01             	lea    0x1(%eax),%ecx
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079b:	89 0a                	mov    %ecx,(%edx)
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a0:	88 10                	mov    %dl,(%eax)
}
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	01 d0                	add    %edx,%eax
  8007bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007c9:	74 06                	je     8007d1 <vsnprintf+0x2d>
  8007cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007cf:	7f 07                	jg     8007d8 <vsnprintf+0x34>
		return -E_INVAL;
  8007d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d6:	eb 2a                	jmp    800802 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007df:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ed:	c7 04 24 6f 07 80 00 	movl   $0x80076f,(%esp)
  8007f4:	e8 62 fb ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080a:	8d 45 14             	lea    0x14(%ebp),%eax
  80080d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 74 ff ff ff       	call   8007a4 <vsnprintf>
  800830:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800833:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800845:	eb 08                	jmp    80084f <strlen+0x17>
		n++;
  800847:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	0f b6 00             	movzbl (%eax),%eax
  800855:	84 c0                	test   %al,%al
  800857:	75 ee                	jne    800847 <strlen+0xf>
		n++;
	return n;
  800859:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800864:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80086b:	eb 0c                	jmp    800879 <strnlen+0x1b>
		n++;
  80086d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800871:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800875:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800879:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80087d:	74 0a                	je     800889 <strnlen+0x2b>
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	0f b6 00             	movzbl (%eax),%eax
  800885:	84 c0                	test   %al,%al
  800887:	75 e4                	jne    80086d <strnlen+0xf>
		n++;
	return n;
  800889:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80089a:	90                   	nop
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8d 50 01             	lea    0x1(%eax),%edx
  8008a1:	89 55 08             	mov    %edx,0x8(%ebp)
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008aa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	88 10                	mov    %dl,(%eax)
  8008b2:	0f b6 00             	movzbl (%eax),%eax
  8008b5:	84 c0                	test   %al,%al
  8008b7:	75 e2                	jne    80089b <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 69 ff ff ff       	call   800838 <strlen>
  8008cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	01 c2                	add    %eax,%edx
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	89 14 24             	mov    %edx,(%esp)
  8008e4:	e8 a5 ff ff ff       	call   80088e <strcpy>
	return dst;
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8008fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800901:	eb 23                	jmp    800926 <strncpy+0x38>
		*dst++ = *src;
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	8d 50 01             	lea    0x1(%eax),%edx
  800909:	89 55 08             	mov    %edx,0x8(%ebp)
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	0f b6 12             	movzbl (%edx),%edx
  800912:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	0f b6 00             	movzbl (%eax),%eax
  80091a:	84 c0                	test   %al,%al
  80091c:	74 04                	je     800922 <strncpy+0x34>
			src++;
  80091e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800926:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800929:	3b 45 10             	cmp    0x10(%ebp),%eax
  80092c:	72 d5                	jb     800903 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80092e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80093f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800943:	74 33                	je     800978 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800945:	eb 17                	jmp    80095e <strlcpy+0x2b>
			*dst++ = *src++;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8d 50 01             	lea    0x1(%eax),%edx
  80094d:	89 55 08             	mov    %edx,0x8(%ebp)
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
  800953:	8d 4a 01             	lea    0x1(%edx),%ecx
  800956:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80095e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800962:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800966:	74 0a                	je     800972 <strlcpy+0x3f>
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	0f b6 00             	movzbl (%eax),%eax
  80096e:	84 c0                	test   %al,%al
  800970:	75 d5                	jne    800947 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800978:	8b 55 08             	mov    0x8(%ebp),%edx
  80097b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80097e:	29 c2                	sub    %eax,%edx
  800980:	89 d0                	mov    %edx,%eax
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800987:	eb 08                	jmp    800991 <strcmp+0xd>
		p++, q++;
  800989:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80098d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	0f b6 00             	movzbl (%eax),%eax
  800997:	84 c0                	test   %al,%al
  800999:	74 10                	je     8009ab <strcmp+0x27>
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	0f b6 10             	movzbl (%eax),%edx
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	0f b6 00             	movzbl (%eax),%eax
  8009a7:	38 c2                	cmp    %al,%dl
  8009a9:	74 de                	je     800989 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	0f b6 00             	movzbl (%eax),%eax
  8009b1:	0f b6 d0             	movzbl %al,%edx
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f b6 c0             	movzbl %al,%eax
  8009bd:	29 c2                	sub    %eax,%edx
  8009bf:	89 d0                	mov    %edx,%eax
}
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009c6:	eb 0c                	jmp    8009d4 <strncmp+0x11>
		n--, p++, q++;
  8009c8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009cc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009d0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009d8:	74 1a                	je     8009f4 <strncmp+0x31>
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	0f b6 00             	movzbl (%eax),%eax
  8009e0:	84 c0                	test   %al,%al
  8009e2:	74 10                	je     8009f4 <strncmp+0x31>
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	0f b6 10             	movzbl (%eax),%edx
  8009ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ed:	0f b6 00             	movzbl (%eax),%eax
  8009f0:	38 c2                	cmp    %al,%dl
  8009f2:	74 d4                	je     8009c8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8009f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f8:	75 07                	jne    800a01 <strncmp+0x3e>
		return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 16                	jmp    800a17 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	0f b6 00             	movzbl (%eax),%eax
  800a07:	0f b6 d0             	movzbl %al,%edx
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	0f b6 00             	movzbl (%eax),%eax
  800a10:	0f b6 c0             	movzbl %al,%eax
  800a13:	29 c2                	sub    %eax,%edx
  800a15:	89 d0                	mov    %edx,%eax
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 04             	sub    $0x4,%esp
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a25:	eb 14                	jmp    800a3b <strchr+0x22>
		if (*s == c)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	0f b6 00             	movzbl (%eax),%eax
  800a2d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a30:	75 05                	jne    800a37 <strchr+0x1e>
			return (char *) s;
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	eb 13                	jmp    800a4a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	0f b6 00             	movzbl (%eax),%eax
  800a41:	84 c0                	test   %al,%al
  800a43:	75 e2                	jne    800a27 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	c9                   	leave  
  800a4b:	c3                   	ret    

00800a4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 04             	sub    $0x4,%esp
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a58:	eb 11                	jmp    800a6b <strfind+0x1f>
		if (*s == c)
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	0f b6 00             	movzbl (%eax),%eax
  800a60:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a63:	75 02                	jne    800a67 <strfind+0x1b>
			break;
  800a65:	eb 0e                	jmp    800a75 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	0f b6 00             	movzbl (%eax),%eax
  800a71:	84 c0                	test   %al,%al
  800a73:	75 e5                	jne    800a5a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a82:	75 05                	jne    800a89 <memset+0xf>
		return v;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	eb 5c                	jmp    800ae5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	83 e0 03             	and    $0x3,%eax
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	75 41                	jne    800ad4 <memset+0x5a>
  800a93:	8b 45 10             	mov    0x10(%ebp),%eax
  800a96:	83 e0 03             	and    $0x3,%eax
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	75 37                	jne    800ad4 <memset+0x5a>
		c &= 0xFF;
  800a9d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa7:	c1 e0 18             	shl    $0x18,%eax
  800aaa:	89 c2                	mov    %eax,%edx
  800aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaf:	c1 e0 10             	shl    $0x10,%eax
  800ab2:	09 c2                	or     %eax,%edx
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	c1 e0 08             	shl    $0x8,%eax
  800aba:	09 d0                	or     %edx,%eax
  800abc:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac2:	c1 e8 02             	shr    $0x2,%eax
  800ac5:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	89 d7                	mov    %edx,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad2:	eb 0e                	jmp    800ae2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800add:	89 d7                	mov    %edx,%edi
  800adf:	fc                   	cld    
  800ae0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800af1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b00:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b03:	73 6d                	jae    800b72 <memmove+0x8a>
  800b05:	8b 45 10             	mov    0x10(%ebp),%eax
  800b08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b0b:	01 d0                	add    %edx,%eax
  800b0d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b10:	76 60                	jbe    800b72 <memmove+0x8a>
		s += n;
  800b12:	8b 45 10             	mov    0x10(%ebp),%eax
  800b15:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b18:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b21:	83 e0 03             	and    $0x3,%eax
  800b24:	85 c0                	test   %eax,%eax
  800b26:	75 2f                	jne    800b57 <memmove+0x6f>
  800b28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b2b:	83 e0 03             	and    $0x3,%eax
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	75 25                	jne    800b57 <memmove+0x6f>
  800b32:	8b 45 10             	mov    0x10(%ebp),%eax
  800b35:	83 e0 03             	and    $0x3,%eax
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	75 1b                	jne    800b57 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3f:	83 e8 04             	sub    $0x4,%eax
  800b42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b45:	83 ea 04             	sub    $0x4,%edx
  800b48:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	fd                   	std    
  800b53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b55:	eb 18                	jmp    800b6f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b60:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 de                	mov    %ebx,%esi
  800b6a:	89 c1                	mov    %eax,%ecx
  800b6c:	fd                   	std    
  800b6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b6f:	fc                   	cld    
  800b70:	eb 45                	jmp    800bb7 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b75:	83 e0 03             	and    $0x3,%eax
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	75 2b                	jne    800ba7 <memmove+0xbf>
  800b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b7f:	83 e0 03             	and    $0x3,%eax
  800b82:	85 c0                	test   %eax,%eax
  800b84:	75 21                	jne    800ba7 <memmove+0xbf>
  800b86:	8b 45 10             	mov    0x10(%ebp),%eax
  800b89:	83 e0 03             	and    $0x3,%eax
  800b8c:	85 c0                	test   %eax,%eax
  800b8e:	75 17                	jne    800ba7 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b90:	8b 45 10             	mov    0x10(%ebp),%eax
  800b93:	c1 e8 02             	shr    $0x2,%eax
  800b96:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	fc                   	cld    
  800ba3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba5:	eb 10                	jmp    800bb7 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800baa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bb0:	89 c7                	mov    %eax,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	fc                   	cld    
  800bb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	89 04 24             	mov    %eax,(%esp)
  800bdc:	e8 07 ff ff ff       	call   800ae8 <memmove>
}
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800bf5:	eb 30                	jmp    800c27 <memcmp+0x44>
		if (*s1 != *s2)
  800bf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bfa:	0f b6 10             	movzbl (%eax),%edx
  800bfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c00:	0f b6 00             	movzbl (%eax),%eax
  800c03:	38 c2                	cmp    %al,%dl
  800c05:	74 18                	je     800c1f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c0a:	0f b6 00             	movzbl (%eax),%eax
  800c0d:	0f b6 d0             	movzbl %al,%edx
  800c10:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c13:	0f b6 00             	movzbl (%eax),%eax
  800c16:	0f b6 c0             	movzbl %al,%eax
  800c19:	29 c2                	sub    %eax,%edx
  800c1b:	89 d0                	mov    %edx,%eax
  800c1d:	eb 1a                	jmp    800c39 <memcmp+0x56>
		s1++, s2++;
  800c1f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c23:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c27:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c2d:	89 55 10             	mov    %edx,0x10(%ebp)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	75 c3                	jne    800bf7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c41:	8b 45 10             	mov    0x10(%ebp),%eax
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	01 d0                	add    %edx,%eax
  800c49:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c4c:	eb 13                	jmp    800c61 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	0f b6 10             	movzbl (%eax),%edx
  800c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c57:	38 c2                	cmp    %al,%dl
  800c59:	75 02                	jne    800c5d <memfind+0x22>
			break;
  800c5b:	eb 0c                	jmp    800c69 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c5d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
  800c64:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c67:	72 e5                	jb     800c4e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c74:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c7b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c82:	eb 04                	jmp    800c88 <strtol+0x1a>
		s++;
  800c84:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	0f b6 00             	movzbl (%eax),%eax
  800c8e:	3c 20                	cmp    $0x20,%al
  800c90:	74 f2                	je     800c84 <strtol+0x16>
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	0f b6 00             	movzbl (%eax),%eax
  800c98:	3c 09                	cmp    $0x9,%al
  800c9a:	74 e8                	je     800c84 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	0f b6 00             	movzbl (%eax),%eax
  800ca2:	3c 2b                	cmp    $0x2b,%al
  800ca4:	75 06                	jne    800cac <strtol+0x3e>
		s++;
  800ca6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800caa:	eb 15                	jmp    800cc1 <strtol+0x53>
	else if (*s == '-')
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	0f b6 00             	movzbl (%eax),%eax
  800cb2:	3c 2d                	cmp    $0x2d,%al
  800cb4:	75 0b                	jne    800cc1 <strtol+0x53>
		s++, neg = 1;
  800cb6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cba:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc5:	74 06                	je     800ccd <strtol+0x5f>
  800cc7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ccb:	75 24                	jne    800cf1 <strtol+0x83>
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	0f b6 00             	movzbl (%eax),%eax
  800cd3:	3c 30                	cmp    $0x30,%al
  800cd5:	75 1a                	jne    800cf1 <strtol+0x83>
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	83 c0 01             	add    $0x1,%eax
  800cdd:	0f b6 00             	movzbl (%eax),%eax
  800ce0:	3c 78                	cmp    $0x78,%al
  800ce2:	75 0d                	jne    800cf1 <strtol+0x83>
		s += 2, base = 16;
  800ce4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800ce8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800cef:	eb 2a                	jmp    800d1b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800cf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf5:	75 17                	jne    800d0e <strtol+0xa0>
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	0f b6 00             	movzbl (%eax),%eax
  800cfd:	3c 30                	cmp    $0x30,%al
  800cff:	75 0d                	jne    800d0e <strtol+0xa0>
		s++, base = 8;
  800d01:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d05:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d0c:	eb 0d                	jmp    800d1b <strtol+0xad>
	else if (base == 0)
  800d0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d12:	75 07                	jne    800d1b <strtol+0xad>
		base = 10;
  800d14:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	0f b6 00             	movzbl (%eax),%eax
  800d21:	3c 2f                	cmp    $0x2f,%al
  800d23:	7e 1b                	jle    800d40 <strtol+0xd2>
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
  800d28:	0f b6 00             	movzbl (%eax),%eax
  800d2b:	3c 39                	cmp    $0x39,%al
  800d2d:	7f 11                	jg     800d40 <strtol+0xd2>
			dig = *s - '0';
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	0f b6 00             	movzbl (%eax),%eax
  800d35:	0f be c0             	movsbl %al,%eax
  800d38:	83 e8 30             	sub    $0x30,%eax
  800d3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d3e:	eb 48                	jmp    800d88 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	0f b6 00             	movzbl (%eax),%eax
  800d46:	3c 60                	cmp    $0x60,%al
  800d48:	7e 1b                	jle    800d65 <strtol+0xf7>
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	0f b6 00             	movzbl (%eax),%eax
  800d50:	3c 7a                	cmp    $0x7a,%al
  800d52:	7f 11                	jg     800d65 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	0f b6 00             	movzbl (%eax),%eax
  800d5a:	0f be c0             	movsbl %al,%eax
  800d5d:	83 e8 57             	sub    $0x57,%eax
  800d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d63:	eb 23                	jmp    800d88 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	0f b6 00             	movzbl (%eax),%eax
  800d6b:	3c 40                	cmp    $0x40,%al
  800d6d:	7e 3d                	jle    800dac <strtol+0x13e>
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	0f b6 00             	movzbl (%eax),%eax
  800d75:	3c 5a                	cmp    $0x5a,%al
  800d77:	7f 33                	jg     800dac <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	0f be c0             	movsbl %al,%eax
  800d82:	83 e8 37             	sub    $0x37,%eax
  800d85:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d8e:	7c 02                	jl     800d92 <strtol+0x124>
			break;
  800d90:	eb 1a                	jmp    800dac <strtol+0x13e>
		s++, val = (val * base) + dig;
  800d92:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d96:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d99:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da2:	01 d0                	add    %edx,%eax
  800da4:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800da7:	e9 6f ff ff ff       	jmp    800d1b <strtol+0xad>

	if (endptr)
  800dac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db0:	74 08                	je     800dba <strtol+0x14c>
		*endptr = (char *) s;
  800db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dbe:	74 07                	je     800dc7 <strtol+0x159>
  800dc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dc3:	f7 d8                	neg    %eax
  800dc5:	eb 03                	jmp    800dca <strtol+0x15c>
  800dc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	8b 55 10             	mov    0x10(%ebp),%edx
  800ddb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800dde:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800de1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800de4:	8b 75 20             	mov    0x20(%ebp),%esi
  800de7:	cd 30                	int    $0x30
  800de9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df0:	74 30                	je     800e22 <syscall+0x56>
  800df2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800df6:	7e 2a                	jle    800e22 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e06:	c7 44 24 08 04 1d 80 	movl   $0x801d04,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 21 1d 80 00 	movl   $0x801d21,(%esp)
  800e1d:	e8 48 08 00 00       	call   80166a <_panic>

	return ret;
  800e22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e25:	83 c4 3c             	add    $0x3c,%esp
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e45:	00 
  800e46:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e4d:	00 
  800e4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e51:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e60:	00 
  800e61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e68:	e8 5f ff ff ff       	call   800dcc <syscall>
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e75:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e84:	00 
  800e85:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800eac:	e8 1b ff ff ff       	call   800dcc <syscall>
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800edb:	00 
  800edc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ee7:	00 
  800ee8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800eef:	e8 d8 fe ff ff       	call   800dcc <syscall>
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800efc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f03:	00 
  800f04:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f0b:	00 
  800f0c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f13:	00 
  800f14:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f33:	e8 94 fe ff ff       	call   800dcc <syscall>
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <sys_yield>:

void
sys_yield(void)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
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
  800f70:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f77:	e8 50 fe ff ff       	call   800dcc <syscall>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f84:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f94:	00 
  800f95:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f9c:	00 
  800f9d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fb8:	e8 0f fe ff ff       	call   800dcc <syscall>
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fc7:	8b 75 18             	mov    0x18(%ebp),%esi
  800fca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fcd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	89 74 24 18          	mov    %esi,0x18(%esp)
  800fda:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800fde:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fe2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ff1:	00 
  800ff2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800ff9:	e8 ce fd ff ff       	call   800dcc <syscall>
}
  800ffe:	83 c4 20             	add    $0x20,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    

00801005 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80100b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801018:	00 
  801019:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801020:	00 
  801021:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801028:	00 
  801029:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80102d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801031:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801040:	e8 87 fd ff ff       	call   800dcc <syscall>
}
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80104d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80105a:	00 
  80105b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801062:	00 
  801063:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80106a:	00 
  80106b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80106f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801073:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801082:	e8 45 fd ff ff       	call   800dcc <syscall>
}
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80108f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80109c:	00 
  80109d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010ac:	00 
  8010ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010bc:	00 
  8010bd:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010c4:	e8 03 fd ff ff       	call   800dcc <syscall>
}
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010d1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e1:	00 
  8010e2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010e6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010fc:	00 
  8010fd:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801104:	e8 c3 fc ff ff       	call   800dcc <syscall>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80111b:	00 
  80111c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801123:	00 
  801124:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80112b:	00 
  80112c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801133:	00 
  801134:	89 44 24 08          	mov    %eax,0x8(%esp)
  801138:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801147:	e8 80 fc ff ff       	call   800dcc <syscall>
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <sys_exec>:

void sys_exec(char* buf){
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80115e:	00 
  80115f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801166:	00 
  801167:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80116e:	00 
  80116f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801176:	00 
  801177:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80118a:	e8 3d fc ff ff       	call   800dcc <syscall>
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <sys_wait>:

void sys_wait(){
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  801197:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80119e:	00 
  80119f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011ae:	00 
  8011af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011b6:	00 
  8011b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011be:	00 
  8011bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011c6:	00 
  8011c7:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8011ce:	e8 f9 fb ff ff       	call   800dcc <syscall>
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	8b 00                	mov    (%eax),%eax
  8011e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	8b 40 04             	mov    0x4(%eax),%eax
  8011e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  8011ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ef:	83 e0 02             	and    $0x2,%eax
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	75 23                	jne    801219 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8011f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fd:	c7 44 24 08 30 1d 80 	movl   $0x801d30,0x8(%esp)
  801204:	00 
  801205:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80120c:	00 
  80120d:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801214:	e8 51 04 00 00       	call   80166a <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	c1 e8 0c             	shr    $0xc,%eax
  80121f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  801222:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801225:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80122c:	25 00 08 00 00       	and    $0x800,%eax
  801231:	85 c0                	test   %eax,%eax
  801233:	75 1c                	jne    801251 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  801235:	c7 44 24 08 6c 1d 80 	movl   $0x801d6c,0x8(%esp)
  80123c:	00 
  80123d:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801244:	00 
  801245:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80124c:	e8 19 04 00 00       	call   80166a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  801251:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801258:	00 
  801259:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801260:	00 
  801261:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801268:	e8 11 fd ff ff       	call   800f7e <sys_page_alloc>
  80126d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801270:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801274:	79 23                	jns    801299 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  801276:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127d:	c7 44 24 08 a8 1d 80 	movl   $0x801da8,0x8(%esp)
  801284:	00 
  801285:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80128c:	00 
  80128d:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801294:	e8 d1 03 00 00       	call   80166a <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801299:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012ae:	00 
  8012af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b3:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8012ba:	e8 03 f9 ff ff       	call   800bc2 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  8012bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012cd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012d4:	00 
  8012d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f0:	e8 ca fc ff ff       	call   800fbf <sys_page_map>
  8012f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012fc:	79 23                	jns    801321 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8012fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801305:	c7 44 24 08 e0 1d 80 	movl   $0x801de0,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80131c:	e8 49 03 00 00       	call   80166a <_panic>
	}

	// panic("pgfault not implemented");
}
  801321:	c9                   	leave  
  801322:	c3                   	ret    

00801323 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  80132b:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  801332:	8b 45 0c             	mov    0xc(%ebp),%eax
  801335:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80133c:	25 00 08 00 00       	and    $0x800,%eax
  801341:	85 c0                	test   %eax,%eax
  801343:	75 15                	jne    80135a <duppage+0x37>
  801345:	8b 45 0c             	mov    0xc(%ebp),%eax
  801348:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134f:	83 e0 02             	and    $0x2,%eax
  801352:	85 c0                	test   %eax,%eax
  801354:	0f 84 e0 00 00 00    	je     80143a <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  80135a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801364:	83 e0 04             	and    $0x4,%eax
  801367:	85 c0                	test   %eax,%eax
  801369:	74 04                	je     80136f <duppage+0x4c>
  80136b:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  80136f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801372:	8b 45 0c             	mov    0xc(%ebp),%eax
  801375:	c1 e0 0c             	shl    $0xc,%eax
  801378:	89 c1                	mov    %eax,%ecx
  80137a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137d:	c1 e0 0c             	shl    $0xc,%eax
  801380:	89 c2                	mov    %eax,%edx
  801382:	a1 04 20 80 00       	mov    0x802004,%eax
  801387:	8b 40 48             	mov    0x48(%eax),%eax
  80138a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80138e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801395:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801399:	89 54 24 04          	mov    %edx,0x4(%esp)
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 1a fc ff ff       	call   800fbf <sys_page_map>
  8013a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8013a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013ac:	79 23                	jns    8013d1 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b5:	c7 44 24 08 14 1e 80 	movl   $0x801e14,0x8(%esp)
  8013bc:	00 
  8013bd:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8013c4:	00 
  8013c5:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8013cc:	e8 99 02 00 00       	call   80166a <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8013d1:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8013d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d7:	c1 e0 0c             	shl    $0xc,%eax
  8013da:	89 c3                	mov    %eax,%ebx
  8013dc:	a1 04 20 80 00       	mov    0x802004,%eax
  8013e1:	8b 48 48             	mov    0x48(%eax),%ecx
  8013e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e7:	c1 e0 0c             	shl    $0xc,%eax
  8013ea:	89 c2                	mov    %eax,%edx
  8013ec:	a1 04 20 80 00       	mov    0x802004,%eax
  8013f1:	8b 40 48             	mov    0x48(%eax),%eax
  8013f4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013f8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013fc:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801400:	89 54 24 04          	mov    %edx,0x4(%esp)
  801404:	89 04 24             	mov    %eax,(%esp)
  801407:	e8 b3 fb ff ff       	call   800fbf <sys_page_map>
  80140c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80140f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801413:	79 23                	jns    801438 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  801415:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801418:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80141c:	c7 44 24 08 50 1e 80 	movl   $0x801e50,0x8(%esp)
  801423:	00 
  801424:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  80142b:	00 
  80142c:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801433:	e8 32 02 00 00       	call   80166a <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801438:	eb 70                	jmp    8014aa <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  80143a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801444:	25 ff 0f 00 00       	and    $0xfff,%eax
  801449:	89 c3                	mov    %eax,%ebx
  80144b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144e:	c1 e0 0c             	shl    $0xc,%eax
  801451:	89 c1                	mov    %eax,%ecx
  801453:	8b 45 0c             	mov    0xc(%ebp),%eax
  801456:	c1 e0 0c             	shl    $0xc,%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	a1 04 20 80 00       	mov    0x802004,%eax
  801460:	8b 40 48             	mov    0x48(%eax),%eax
  801463:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801467:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80146b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801472:	89 54 24 04          	mov    %edx,0x4(%esp)
  801476:	89 04 24             	mov    %eax,(%esp)
  801479:	e8 41 fb ff ff       	call   800fbf <sys_page_map>
  80147e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801481:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801485:	79 23                	jns    8014aa <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  801487:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80148e:	c7 44 24 08 80 1e 80 	movl   $0x801e80,0x8(%esp)
  801495:	00 
  801496:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  80149d:	00 
  80149e:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8014a5:	e8 c0 01 00 00       	call   80166a <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014af:	83 c4 30             	add    $0x30,%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014bc:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  8014c3:	e8 fd 01 00 00       	call   8016c5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8014c8:	b8 07 00 00 00       	mov    $0x7,%eax
  8014cd:	cd 30                	int    $0x30
  8014cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8014d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8014d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8014d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014dc:	79 23                	jns    801501 <fork+0x4b>
  8014de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e5:	c7 44 24 08 b8 1e 80 	movl   $0x801eb8,0x8(%esp)
  8014ec:	00 
  8014ed:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8014f4:	00 
  8014f5:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8014fc:	e8 69 01 00 00       	call   80166a <_panic>
	else if(childeid == 0){
  801501:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801505:	75 29                	jne    801530 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801507:	e8 ea f9 ff ff       	call   800ef6 <sys_getenvid>
  80150c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801511:	c1 e0 02             	shl    $0x2,%eax
  801514:	89 c2                	mov    %eax,%edx
  801516:	c1 e2 05             	shl    $0x5,%edx
  801519:	29 c2                	sub    %eax,%edx
  80151b:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  801521:	a3 04 20 80 00       	mov    %eax,0x802004
		// set_pgfault_handler(pgfault);
		return 0;
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	e9 16 01 00 00       	jmp    801646 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801530:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801537:	eb 3b                	jmp    801574 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153c:	c1 f8 0a             	sar    $0xa,%eax
  80153f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801546:	83 e0 01             	and    $0x1,%eax
  801549:	85 c0                	test   %eax,%eax
  80154b:	74 23                	je     801570 <fork+0xba>
  80154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801550:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801557:	83 e0 01             	and    $0x1,%eax
  80155a:	85 c0                	test   %eax,%eax
  80155c:	74 12                	je     801570 <fork+0xba>
			duppage(childeid, i);
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	89 44 24 04          	mov    %eax,0x4(%esp)
  801565:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801568:	89 04 24             	mov    %eax,(%esp)
  80156b:	e8 b3 fd ff ff       	call   801323 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801570:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801574:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801577:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  80157c:	76 bb                	jbe    801539 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  80157e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801585:	00 
  801586:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80158d:	ee 
  80158e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801591:	89 04 24             	mov    %eax,(%esp)
  801594:	e8 e5 f9 ff ff       	call   800f7e <sys_page_alloc>
  801599:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80159c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015a0:	79 23                	jns    8015c5 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8015a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a9:	c7 44 24 08 e0 1e 80 	movl   $0x801ee0,0x8(%esp)
  8015b0:	00 
  8015b1:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8015b8:	00 
  8015b9:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8015c0:	e8 a5 00 00 00       	call   80166a <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  8015c5:	c7 44 24 04 3b 17 80 	movl   $0x80173b,0x4(%esp)
  8015cc:	00 
  8015cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d0:	89 04 24             	mov    %eax,(%esp)
  8015d3:	e8 b1 fa ff ff       	call   801089 <sys_env_set_pgfault_upcall>
  8015d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015df:	79 23                	jns    801604 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8015e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8015e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e8:	c7 44 24 08 08 1f 80 	movl   $0x801f08,0x8(%esp)
  8015ef:	00 
  8015f0:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8015f7:	00 
  8015f8:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8015ff:	e8 66 00 00 00       	call   80166a <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  801604:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80160b:	00 
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	e8 30 fa ff ff       	call   801047 <sys_env_set_status>
  801617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80161e:	79 23                	jns    801643 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  801620:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801623:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801627:	c7 44 24 08 3c 1f 80 	movl   $0x801f3c,0x8(%esp)
  80162e:	00 
  80162f:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801636:	00 
  801637:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  80163e:	e8 27 00 00 00       	call   80166a <_panic>
	}
	return childeid;
  801643:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  801646:	c9                   	leave  
  801647:	c3                   	ret    

00801648 <sfork>:

// Challenge!
int
sfork(void)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80164e:	c7 44 24 08 65 1f 80 	movl   $0x801f65,0x8(%esp)
  801655:	00 
  801656:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  80165d:	00 
  80165e:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  801665:	e8 00 00 00 00       	call   80166a <_panic>

0080166a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  801671:	8d 45 14             	lea    0x14(%ebp),%eax
  801674:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801677:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80167d:	e8 74 f8 ff ff       	call   800ef6 <sys_getenvid>
  801682:	8b 55 0c             	mov    0xc(%ebp),%edx
  801685:	89 54 24 10          	mov    %edx,0x10(%esp)
  801689:	8b 55 08             	mov    0x8(%ebp),%edx
  80168c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801690:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801694:	89 44 24 04          	mov    %eax,0x4(%esp)
  801698:	c7 04 24 7c 1f 80 00 	movl   $0x801f7c,(%esp)
  80169f:	e8 1d eb ff ff       	call   8001c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8016a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ae:	89 04 24             	mov    %eax,(%esp)
  8016b1:	e8 a7 ea ff ff       	call   80015d <vcprintf>
	cprintf("\n");
  8016b6:	c7 04 24 9f 1f 80 00 	movl   $0x801f9f,(%esp)
  8016bd:	e8 ff ea ff ff       	call   8001c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016c2:	cc                   	int3   
  8016c3:	eb fd                	jmp    8016c2 <_panic+0x58>

008016c5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8016cb:	a1 08 20 80 00       	mov    0x802008,%eax
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	75 5d                	jne    801731 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8016d4:	a1 04 20 80 00       	mov    0x802004,%eax
  8016d9:	8b 40 48             	mov    0x48(%eax),%eax
  8016dc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016e3:	00 
  8016e4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016eb:	ee 
  8016ec:	89 04 24             	mov    %eax,(%esp)
  8016ef:	e8 8a f8 ff ff       	call   800f7e <sys_page_alloc>
  8016f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8016fb:	79 1c                	jns    801719 <set_pgfault_handler+0x54>
  8016fd:	c7 44 24 08 a4 1f 80 	movl   $0x801fa4,0x8(%esp)
  801704:	00 
  801705:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80170c:	00 
  80170d:	c7 04 24 d0 1f 80 00 	movl   $0x801fd0,(%esp)
  801714:	e8 51 ff ff ff       	call   80166a <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801719:	a1 04 20 80 00       	mov    0x802004,%eax
  80171e:	8b 40 48             	mov    0x48(%eax),%eax
  801721:	c7 44 24 04 3b 17 80 	movl   $0x80173b,0x4(%esp)
  801728:	00 
  801729:	89 04 24             	mov    %eax,(%esp)
  80172c:	e8 58 f9 ff ff       	call   801089 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801731:	8b 45 08             	mov    0x8(%ebp),%eax
  801734:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80173b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80173c:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801741:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801743:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801746:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  80174a:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80174c:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801750:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801751:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801754:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801756:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801757:	58                   	pop    %eax
	popal 						// pop all the registers
  801758:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801759:	83 c4 04             	add    $0x4,%esp
	popfl
  80175c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80175d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80175e:	c3                   	ret    
  80175f:	90                   	nop

00801760 <__udivdi3>:
  801760:	55                   	push   %ebp
  801761:	57                   	push   %edi
  801762:	56                   	push   %esi
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	8b 44 24 28          	mov    0x28(%esp),%eax
  80176a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80176e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801772:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801776:	85 c0                	test   %eax,%eax
  801778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80177c:	89 ea                	mov    %ebp,%edx
  80177e:	89 0c 24             	mov    %ecx,(%esp)
  801781:	75 2d                	jne    8017b0 <__udivdi3+0x50>
  801783:	39 e9                	cmp    %ebp,%ecx
  801785:	77 61                	ja     8017e8 <__udivdi3+0x88>
  801787:	85 c9                	test   %ecx,%ecx
  801789:	89 ce                	mov    %ecx,%esi
  80178b:	75 0b                	jne    801798 <__udivdi3+0x38>
  80178d:	b8 01 00 00 00       	mov    $0x1,%eax
  801792:	31 d2                	xor    %edx,%edx
  801794:	f7 f1                	div    %ecx
  801796:	89 c6                	mov    %eax,%esi
  801798:	31 d2                	xor    %edx,%edx
  80179a:	89 e8                	mov    %ebp,%eax
  80179c:	f7 f6                	div    %esi
  80179e:	89 c5                	mov    %eax,%ebp
  8017a0:	89 f8                	mov    %edi,%eax
  8017a2:	f7 f6                	div    %esi
  8017a4:	89 ea                	mov    %ebp,%edx
  8017a6:	83 c4 0c             	add    $0xc,%esp
  8017a9:	5e                   	pop    %esi
  8017aa:	5f                   	pop    %edi
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    
  8017ad:	8d 76 00             	lea    0x0(%esi),%esi
  8017b0:	39 e8                	cmp    %ebp,%eax
  8017b2:	77 24                	ja     8017d8 <__udivdi3+0x78>
  8017b4:	0f bd e8             	bsr    %eax,%ebp
  8017b7:	83 f5 1f             	xor    $0x1f,%ebp
  8017ba:	75 3c                	jne    8017f8 <__udivdi3+0x98>
  8017bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017c0:	39 34 24             	cmp    %esi,(%esp)
  8017c3:	0f 86 9f 00 00 00    	jbe    801868 <__udivdi3+0x108>
  8017c9:	39 d0                	cmp    %edx,%eax
  8017cb:	0f 82 97 00 00 00    	jb     801868 <__udivdi3+0x108>
  8017d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8017d8:	31 d2                	xor    %edx,%edx
  8017da:	31 c0                	xor    %eax,%eax
  8017dc:	83 c4 0c             	add    $0xc,%esp
  8017df:	5e                   	pop    %esi
  8017e0:	5f                   	pop    %edi
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    
  8017e3:	90                   	nop
  8017e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017e8:	89 f8                	mov    %edi,%eax
  8017ea:	f7 f1                	div    %ecx
  8017ec:	31 d2                	xor    %edx,%edx
  8017ee:	83 c4 0c             	add    $0xc,%esp
  8017f1:	5e                   	pop    %esi
  8017f2:	5f                   	pop    %edi
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    
  8017f5:	8d 76 00             	lea    0x0(%esi),%esi
  8017f8:	89 e9                	mov    %ebp,%ecx
  8017fa:	8b 3c 24             	mov    (%esp),%edi
  8017fd:	d3 e0                	shl    %cl,%eax
  8017ff:	89 c6                	mov    %eax,%esi
  801801:	b8 20 00 00 00       	mov    $0x20,%eax
  801806:	29 e8                	sub    %ebp,%eax
  801808:	89 c1                	mov    %eax,%ecx
  80180a:	d3 ef                	shr    %cl,%edi
  80180c:	89 e9                	mov    %ebp,%ecx
  80180e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801812:	8b 3c 24             	mov    (%esp),%edi
  801815:	09 74 24 08          	or     %esi,0x8(%esp)
  801819:	89 d6                	mov    %edx,%esi
  80181b:	d3 e7                	shl    %cl,%edi
  80181d:	89 c1                	mov    %eax,%ecx
  80181f:	89 3c 24             	mov    %edi,(%esp)
  801822:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801826:	d3 ee                	shr    %cl,%esi
  801828:	89 e9                	mov    %ebp,%ecx
  80182a:	d3 e2                	shl    %cl,%edx
  80182c:	89 c1                	mov    %eax,%ecx
  80182e:	d3 ef                	shr    %cl,%edi
  801830:	09 d7                	or     %edx,%edi
  801832:	89 f2                	mov    %esi,%edx
  801834:	89 f8                	mov    %edi,%eax
  801836:	f7 74 24 08          	divl   0x8(%esp)
  80183a:	89 d6                	mov    %edx,%esi
  80183c:	89 c7                	mov    %eax,%edi
  80183e:	f7 24 24             	mull   (%esp)
  801841:	39 d6                	cmp    %edx,%esi
  801843:	89 14 24             	mov    %edx,(%esp)
  801846:	72 30                	jb     801878 <__udivdi3+0x118>
  801848:	8b 54 24 04          	mov    0x4(%esp),%edx
  80184c:	89 e9                	mov    %ebp,%ecx
  80184e:	d3 e2                	shl    %cl,%edx
  801850:	39 c2                	cmp    %eax,%edx
  801852:	73 05                	jae    801859 <__udivdi3+0xf9>
  801854:	3b 34 24             	cmp    (%esp),%esi
  801857:	74 1f                	je     801878 <__udivdi3+0x118>
  801859:	89 f8                	mov    %edi,%eax
  80185b:	31 d2                	xor    %edx,%edx
  80185d:	e9 7a ff ff ff       	jmp    8017dc <__udivdi3+0x7c>
  801862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801868:	31 d2                	xor    %edx,%edx
  80186a:	b8 01 00 00 00       	mov    $0x1,%eax
  80186f:	e9 68 ff ff ff       	jmp    8017dc <__udivdi3+0x7c>
  801874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801878:	8d 47 ff             	lea    -0x1(%edi),%eax
  80187b:	31 d2                	xor    %edx,%edx
  80187d:	83 c4 0c             	add    $0xc,%esp
  801880:	5e                   	pop    %esi
  801881:	5f                   	pop    %edi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    
  801884:	66 90                	xchg   %ax,%ax
  801886:	66 90                	xchg   %ax,%ax
  801888:	66 90                	xchg   %ax,%ax
  80188a:	66 90                	xchg   %ax,%ax
  80188c:	66 90                	xchg   %ax,%ax
  80188e:	66 90                	xchg   %ax,%ax

00801890 <__umoddi3>:
  801890:	55                   	push   %ebp
  801891:	57                   	push   %edi
  801892:	56                   	push   %esi
  801893:	83 ec 14             	sub    $0x14,%esp
  801896:	8b 44 24 28          	mov    0x28(%esp),%eax
  80189a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80189e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8018a2:	89 c7                	mov    %eax,%edi
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8018ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018b0:	89 34 24             	mov    %esi,(%esp)
  8018b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8018bf:	75 17                	jne    8018d8 <__umoddi3+0x48>
  8018c1:	39 fe                	cmp    %edi,%esi
  8018c3:	76 4b                	jbe    801910 <__umoddi3+0x80>
  8018c5:	89 c8                	mov    %ecx,%eax
  8018c7:	89 fa                	mov    %edi,%edx
  8018c9:	f7 f6                	div    %esi
  8018cb:	89 d0                	mov    %edx,%eax
  8018cd:	31 d2                	xor    %edx,%edx
  8018cf:	83 c4 14             	add    $0x14,%esp
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    
  8018d6:	66 90                	xchg   %ax,%ax
  8018d8:	39 f8                	cmp    %edi,%eax
  8018da:	77 54                	ja     801930 <__umoddi3+0xa0>
  8018dc:	0f bd e8             	bsr    %eax,%ebp
  8018df:	83 f5 1f             	xor    $0x1f,%ebp
  8018e2:	75 5c                	jne    801940 <__umoddi3+0xb0>
  8018e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8018e8:	39 3c 24             	cmp    %edi,(%esp)
  8018eb:	0f 87 e7 00 00 00    	ja     8019d8 <__umoddi3+0x148>
  8018f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018f5:	29 f1                	sub    %esi,%ecx
  8018f7:	19 c7                	sbb    %eax,%edi
  8018f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801901:	8b 44 24 08          	mov    0x8(%esp),%eax
  801905:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801909:	83 c4 14             	add    $0x14,%esp
  80190c:	5e                   	pop    %esi
  80190d:	5f                   	pop    %edi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    
  801910:	85 f6                	test   %esi,%esi
  801912:	89 f5                	mov    %esi,%ebp
  801914:	75 0b                	jne    801921 <__umoddi3+0x91>
  801916:	b8 01 00 00 00       	mov    $0x1,%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	f7 f6                	div    %esi
  80191f:	89 c5                	mov    %eax,%ebp
  801921:	8b 44 24 04          	mov    0x4(%esp),%eax
  801925:	31 d2                	xor    %edx,%edx
  801927:	f7 f5                	div    %ebp
  801929:	89 c8                	mov    %ecx,%eax
  80192b:	f7 f5                	div    %ebp
  80192d:	eb 9c                	jmp    8018cb <__umoddi3+0x3b>
  80192f:	90                   	nop
  801930:	89 c8                	mov    %ecx,%eax
  801932:	89 fa                	mov    %edi,%edx
  801934:	83 c4 14             	add    $0x14,%esp
  801937:	5e                   	pop    %esi
  801938:	5f                   	pop    %edi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    
  80193b:	90                   	nop
  80193c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801940:	8b 04 24             	mov    (%esp),%eax
  801943:	be 20 00 00 00       	mov    $0x20,%esi
  801948:	89 e9                	mov    %ebp,%ecx
  80194a:	29 ee                	sub    %ebp,%esi
  80194c:	d3 e2                	shl    %cl,%edx
  80194e:	89 f1                	mov    %esi,%ecx
  801950:	d3 e8                	shr    %cl,%eax
  801952:	89 e9                	mov    %ebp,%ecx
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	8b 04 24             	mov    (%esp),%eax
  80195b:	09 54 24 04          	or     %edx,0x4(%esp)
  80195f:	89 fa                	mov    %edi,%edx
  801961:	d3 e0                	shl    %cl,%eax
  801963:	89 f1                	mov    %esi,%ecx
  801965:	89 44 24 08          	mov    %eax,0x8(%esp)
  801969:	8b 44 24 10          	mov    0x10(%esp),%eax
  80196d:	d3 ea                	shr    %cl,%edx
  80196f:	89 e9                	mov    %ebp,%ecx
  801971:	d3 e7                	shl    %cl,%edi
  801973:	89 f1                	mov    %esi,%ecx
  801975:	d3 e8                	shr    %cl,%eax
  801977:	89 e9                	mov    %ebp,%ecx
  801979:	09 f8                	or     %edi,%eax
  80197b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80197f:	f7 74 24 04          	divl   0x4(%esp)
  801983:	d3 e7                	shl    %cl,%edi
  801985:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801989:	89 d7                	mov    %edx,%edi
  80198b:	f7 64 24 08          	mull   0x8(%esp)
  80198f:	39 d7                	cmp    %edx,%edi
  801991:	89 c1                	mov    %eax,%ecx
  801993:	89 14 24             	mov    %edx,(%esp)
  801996:	72 2c                	jb     8019c4 <__umoddi3+0x134>
  801998:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80199c:	72 22                	jb     8019c0 <__umoddi3+0x130>
  80199e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8019a2:	29 c8                	sub    %ecx,%eax
  8019a4:	19 d7                	sbb    %edx,%edi
  8019a6:	89 e9                	mov    %ebp,%ecx
  8019a8:	89 fa                	mov    %edi,%edx
  8019aa:	d3 e8                	shr    %cl,%eax
  8019ac:	89 f1                	mov    %esi,%ecx
  8019ae:	d3 e2                	shl    %cl,%edx
  8019b0:	89 e9                	mov    %ebp,%ecx
  8019b2:	d3 ef                	shr    %cl,%edi
  8019b4:	09 d0                	or     %edx,%eax
  8019b6:	89 fa                	mov    %edi,%edx
  8019b8:	83 c4 14             	add    $0x14,%esp
  8019bb:	5e                   	pop    %esi
  8019bc:	5f                   	pop    %edi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    
  8019bf:	90                   	nop
  8019c0:	39 d7                	cmp    %edx,%edi
  8019c2:	75 da                	jne    80199e <__umoddi3+0x10e>
  8019c4:	8b 14 24             	mov    (%esp),%edx
  8019c7:	89 c1                	mov    %eax,%ecx
  8019c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8019cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8019d1:	eb cb                	jmp    80199e <__umoddi3+0x10e>
  8019d3:	90                   	nop
  8019d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8019dc:	0f 82 0f ff ff ff    	jb     8018f1 <__umoddi3+0x61>
  8019e2:	e9 1a ff ff ff       	jmp    801901 <__umoddi3+0x71>
