
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 38             	sub    $0x38,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800039:	8b 45 08             	mov    0x8(%ebp),%eax
  80003c:	8b 00                	mov    (%eax),%eax
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	cprintf("fault %x\n", addr);
  800041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800044:	89 44 24 04          	mov    %eax,0x4(%esp)
  800048:	c7 04 24 40 15 80 00 	movl   $0x801540,(%esp)
  80004f:	e8 23 02 00 00       	call   800277 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80005a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800069:	00 
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800075:	e8 ba 0f 00 00       	call   801034 <sys_page_alloc>
  80007a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80007d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800081:	79 2a                	jns    8000ad <handler+0x7a>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800083:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800091:	c7 44 24 08 4c 15 80 	movl   $0x80154c,0x8(%esp)
  800098:	00 
  800099:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000a0:	00 
  8000a1:	c7 04 24 77 15 80 00 	movl   $0x801577,(%esp)
  8000a8:	e8 af 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b4:	c7 44 24 08 8c 15 80 	movl   $0x80158c,0x8(%esp)
  8000bb:	00 
  8000bc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000c3:	00 
  8000c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 eb 07 00 00       	call   8008ba <snprintf>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000d7:	c7 04 24 33 00 80 00 	movl   $0x800033,(%esp)
  8000de:	e8 21 11 00 00       	call   801204 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000e3:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000f2:	e8 ec 0d 00 00       	call   800ee3 <sys_cputs>
}
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ff:	e8 a8 0e 00 00       	call   800fac <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	c1 e0 02             	shl    $0x2,%eax
  80010c:	89 c2                	mov    %eax,%edx
  80010e:	c1 e2 05             	shl    $0x5,%edx
  800111:	29 c2                	sub    %eax,%edx
  800113:	89 d0                	mov    %edx,%eax
  800115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800123:	7e 0a                	jle    80012f <libmain+0x36>
		binaryname = argv[0];
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	8b 00                	mov    (%eax),%eax
  80012a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800132:	89 44 24 04          	mov    %eax,0x4(%esp)
  800136:	8b 45 08             	mov    0x8(%ebp),%eax
  800139:	89 04 24             	mov    %eax,(%esp)
  80013c:	e8 90 ff ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800141:	e8 02 00 00 00       	call   800148 <exit>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 0f 0e 00 00       	call   800f69 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	53                   	push   %ebx
  800160:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800163:	8d 45 14             	lea    0x14(%ebp),%eax
  800166:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800169:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016f:	e8 38 0e 00 00       	call   800fac <sys_getenvid>
  800174:	8b 55 0c             	mov    0xc(%ebp),%edx
  800177:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800182:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018a:	c7 04 24 b8 15 80 00 	movl   $0x8015b8,(%esp)
  800191:	e8 e1 00 00 00       	call   800277 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 6b 00 00 00       	call   800213 <vcprintf>
	cprintf("\n");
  8001a8:	c7 04 24 db 15 80 00 	movl   $0x8015db,(%esp)
  8001af:	e8 c3 00 00 00       	call   800277 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b4:	cc                   	int3   
  8001b5:	eb fd                	jmp    8001b4 <_panic+0x58>

008001b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c0:	8b 00                	mov    (%eax),%eax
  8001c2:	8d 48 01             	lea    0x1(%eax),%ecx
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c8:	89 0a                	mov    %ecx,(%edx)
  8001ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cd:	89 d1                	mov    %edx,%ecx
  8001cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d2:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d9:	8b 00                	mov    (%eax),%eax
  8001db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e0:	75 20                	jne    800202 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e5:	8b 00                	mov    (%eax),%eax
  8001e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ea:	83 c2 08             	add    $0x8,%edx
  8001ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f1:	89 14 24             	mov    %edx,(%esp)
  8001f4:	e8 ea 0c 00 00       	call   800ee3 <sys_cputs>
		b->idx = 0;
  8001f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800202:	8b 45 0c             	mov    0xc(%ebp),%eax
  800205:	8b 40 04             	mov    0x4(%eax),%eax
  800208:	8d 50 01             	lea    0x1(%eax),%edx
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	89 50 04             	mov    %edx,0x4(%eax)
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	8b 45 0c             	mov    0xc(%ebp),%eax
  800233:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	89 44 24 04          	mov    %eax,0x4(%esp)
  800248:	c7 04 24 b7 01 80 00 	movl   $0x8001b7,(%esp)
  80024f:	e8 bd 01 00 00       	call   800411 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800254:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	83 c0 08             	add    $0x8,%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	e8 74 0c 00 00       	call   800ee3 <sys_cputs>

	return b.cnt;
  80026f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027d:	8d 45 0c             	lea    0xc(%ebp),%eax
  800280:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	e8 7e ff ff ff       	call   800213 <vcprintf>
  800295:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800298:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 34             	sub    $0x34,%esp
  8002a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002bb:	77 72                	ja     80032f <printnum+0x92>
  8002bd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002c0:	72 05                	jb     8002c7 <printnum+0x2a>
  8002c2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002c5:	77 68                	ja     80032f <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c7:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002cd:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ea:	e8 b1 0f 00 00       	call   8012a0 <__udivdi3>
  8002ef:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002f2:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002f6:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002fa:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002fd:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800301:	89 44 24 08          	mov    %eax,0x8(%esp)
  800305:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800309:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	e8 82 ff ff ff       	call   80029d <printnum>
  80031b:	eb 1c                	jmp    800339 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	8b 45 20             	mov    0x20(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032f:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800333:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800337:	7f e4                	jg     80031d <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800339:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80033c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800341:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800344:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800347:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	89 54 24 04          	mov    %edx,0x4(%esp)
  800356:	e8 75 10 00 00       	call   8013d0 <__umoddi3>
  80035b:	05 a8 16 80 00       	add    $0x8016a8,%eax
  800360:	0f b6 00             	movzbl (%eax),%eax
  800363:	0f be c0             	movsbl %al,%eax
  800366:	8b 55 0c             	mov    0xc(%ebp),%edx
  800369:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	ff d0                	call   *%eax
}
  800375:	83 c4 34             	add    $0x34,%esp
  800378:	5b                   	pop    %ebx
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800382:	7e 14                	jle    800398 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800384:	8b 45 08             	mov    0x8(%ebp),%eax
  800387:	8b 00                	mov    (%eax),%eax
  800389:	8d 48 08             	lea    0x8(%eax),%ecx
  80038c:	8b 55 08             	mov    0x8(%ebp),%edx
  80038f:	89 0a                	mov    %ecx,(%edx)
  800391:	8b 50 04             	mov    0x4(%eax),%edx
  800394:	8b 00                	mov    (%eax),%eax
  800396:	eb 30                	jmp    8003c8 <getuint+0x4d>
	else if (lflag)
  800398:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80039c:	74 16                	je     8003b4 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80039e:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a1:	8b 00                	mov    (%eax),%eax
  8003a3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 0a                	mov    %ecx,(%edx)
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	eb 14                	jmp    8003c8 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	8b 00                	mov    (%eax),%eax
  8003b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bf:	89 0a                	mov    %ecx,(%edx)
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cd:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003d1:	7e 14                	jle    8003e7 <getint+0x1d>
		return va_arg(*ap, long long);
  8003d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	8d 48 08             	lea    0x8(%eax),%ecx
  8003db:	8b 55 08             	mov    0x8(%ebp),%edx
  8003de:	89 0a                	mov    %ecx,(%edx)
  8003e0:	8b 50 04             	mov    0x4(%eax),%edx
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	eb 28                	jmp    80040f <getint+0x45>
	else if (lflag)
  8003e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003eb:	74 12                	je     8003ff <getint+0x35>
		return va_arg(*ap, long);
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f8:	89 0a                	mov    %ecx,(%edx)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	99                   	cltd   
  8003fd:	eb 10                	jmp    80040f <getint+0x45>
	else
		return va_arg(*ap, int);
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	8b 00                	mov    (%eax),%eax
  800404:	8d 48 04             	lea    0x4(%eax),%ecx
  800407:	8b 55 08             	mov    0x8(%ebp),%edx
  80040a:	89 0a                	mov    %ecx,(%edx)
  80040c:	8b 00                	mov    (%eax),%eax
  80040e:	99                   	cltd   
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	56                   	push   %esi
  800415:	53                   	push   %ebx
  800416:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	eb 18                	jmp    800433 <vprintfmt+0x22>
			if (ch == '\0')
  80041b:	85 db                	test   %ebx,%ebx
  80041d:	75 05                	jne    800424 <vprintfmt+0x13>
				return;
  80041f:	e9 cc 03 00 00       	jmp    8007f0 <vprintfmt+0x3df>
			putch(ch, putdat);
  800424:	8b 45 0c             	mov    0xc(%ebp),%eax
  800427:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042b:	89 1c 24             	mov    %ebx,(%esp)
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800433:	8b 45 10             	mov    0x10(%ebp),%eax
  800436:	8d 50 01             	lea    0x1(%eax),%edx
  800439:	89 55 10             	mov    %edx,0x10(%ebp)
  80043c:	0f b6 00             	movzbl (%eax),%eax
  80043f:	0f b6 d8             	movzbl %al,%ebx
  800442:	83 fb 25             	cmp    $0x25,%ebx
  800445:	75 d4                	jne    80041b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800447:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80044b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800452:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800459:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800460:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 45 10             	mov    0x10(%ebp),%eax
  80046a:	8d 50 01             	lea    0x1(%eax),%edx
  80046d:	89 55 10             	mov    %edx,0x10(%ebp)
  800470:	0f b6 00             	movzbl (%eax),%eax
  800473:	0f b6 d8             	movzbl %al,%ebx
  800476:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800479:	83 f8 55             	cmp    $0x55,%eax
  80047c:	0f 87 3d 03 00 00    	ja     8007bf <vprintfmt+0x3ae>
  800482:	8b 04 85 cc 16 80 00 	mov    0x8016cc(,%eax,4),%eax
  800489:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80048b:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80048f:	eb d6                	jmp    800467 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800491:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800495:	eb d0                	jmp    800467 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800497:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80049e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a1:	89 d0                	mov    %edx,%eax
  8004a3:	c1 e0 02             	shl    $0x2,%eax
  8004a6:	01 d0                	add    %edx,%eax
  8004a8:	01 c0                	add    %eax,%eax
  8004aa:	01 d8                	add    %ebx,%eax
  8004ac:	83 e8 30             	sub    $0x30,%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b5:	0f b6 00             	movzbl (%eax),%eax
  8004b8:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004bb:	83 fb 2f             	cmp    $0x2f,%ebx
  8004be:	7e 0b                	jle    8004cb <vprintfmt+0xba>
  8004c0:	83 fb 39             	cmp    $0x39,%ebx
  8004c3:	7f 06                	jg     8004cb <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c9:	eb d3                	jmp    80049e <vprintfmt+0x8d>
			goto process_precision;
  8004cb:	eb 33                	jmp    800500 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 50 04             	lea    0x4(%eax),%edx
  8004d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004db:	eb 23                	jmp    800500 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e1:	79 0c                	jns    8004ef <vprintfmt+0xde>
				width = 0;
  8004e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004ea:	e9 78 ff ff ff       	jmp    800467 <vprintfmt+0x56>
  8004ef:	e9 73 ff ff ff       	jmp    800467 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004f4:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004fb:	e9 67 ff ff ff       	jmp    800467 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800500:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800504:	79 12                	jns    800518 <vprintfmt+0x107>
				width = precision, precision = -1;
  800506:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800513:	e9 4f ff ff ff       	jmp    800467 <vprintfmt+0x56>
  800518:	e9 4a ff ff ff       	jmp    800467 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800521:	e9 41 ff ff ff       	jmp    800467 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	8b 55 0c             	mov    0xc(%ebp),%edx
  800534:	89 54 24 04          	mov    %edx,0x4(%esp)
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	8b 45 08             	mov    0x8(%ebp),%eax
  80053e:	ff d0                	call   *%eax
			break;
  800540:	e9 a5 02 00 00       	jmp    8007ea <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800550:	85 db                	test   %ebx,%ebx
  800552:	79 02                	jns    800556 <vprintfmt+0x145>
				err = -err;
  800554:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800556:	83 fb 09             	cmp    $0x9,%ebx
  800559:	7f 0b                	jg     800566 <vprintfmt+0x155>
  80055b:	8b 34 9d 80 16 80 00 	mov    0x801680(,%ebx,4),%esi
  800562:	85 f6                	test   %esi,%esi
  800564:	75 23                	jne    800589 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800566:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80056a:	c7 44 24 08 b9 16 80 	movl   $0x8016b9,0x8(%esp)
  800571:	00 
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	8b 45 08             	mov    0x8(%ebp),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	e8 73 02 00 00       	call   8007f7 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800584:	e9 61 02 00 00       	jmp    8007ea <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800589:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80058d:	c7 44 24 08 c2 16 80 	movl   $0x8016c2,0x8(%esp)
  800594:	00 
  800595:	8b 45 0c             	mov    0xc(%ebp),%eax
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	8b 45 08             	mov    0x8(%ebp),%eax
  80059f:	89 04 24             	mov    %eax,(%esp)
  8005a2:	e8 50 02 00 00       	call   8007f7 <printfmt>
			break;
  8005a7:	e9 3e 02 00 00       	jmp    8007ea <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 30                	mov    (%eax),%esi
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	75 05                	jne    8005c0 <vprintfmt+0x1af>
				p = "(null)";
  8005bb:	be c5 16 80 00       	mov    $0x8016c5,%esi
			if (width > 0 && padc != '-')
  8005c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c4:	7e 37                	jle    8005fd <vprintfmt+0x1ec>
  8005c6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005ca:	74 31                	je     8005fd <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	89 34 24             	mov    %esi,(%esp)
  8005d6:	e8 39 03 00 00       	call   800914 <strnlen>
  8005db:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005de:	eb 17                	jmp    8005f7 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005e0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f1:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fb:	7f e3                	jg     8005e0 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fd:	eb 38                	jmp    800637 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800603:	74 1f                	je     800624 <vprintfmt+0x213>
  800605:	83 fb 1f             	cmp    $0x1f,%ebx
  800608:	7e 05                	jle    80060f <vprintfmt+0x1fe>
  80060a:	83 fb 7e             	cmp    $0x7e,%ebx
  80060d:	7e 15                	jle    800624 <vprintfmt+0x213>
					putch('?', putdat);
  80060f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800612:	89 44 24 04          	mov    %eax,0x4(%esp)
  800616:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	ff d0                	call   *%eax
  800622:	eb 0f                	jmp    800633 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800624:	8b 45 0c             	mov    0xc(%ebp),%eax
  800627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062b:	89 1c 24             	mov    %ebx,(%esp)
  80062e:	8b 45 08             	mov    0x8(%ebp),%eax
  800631:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800633:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800637:	89 f0                	mov    %esi,%eax
  800639:	8d 70 01             	lea    0x1(%eax),%esi
  80063c:	0f b6 00             	movzbl (%eax),%eax
  80063f:	0f be d8             	movsbl %al,%ebx
  800642:	85 db                	test   %ebx,%ebx
  800644:	74 10                	je     800656 <vprintfmt+0x245>
  800646:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064a:	78 b3                	js     8005ff <vprintfmt+0x1ee>
  80064c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800650:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800654:	79 a9                	jns    8005ff <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800656:	eb 17                	jmp    80066f <vprintfmt+0x25e>
				putch(' ', putdat);
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800666:	8b 45 08             	mov    0x8(%ebp),%eax
  800669:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80066f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800673:	7f e3                	jg     800658 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800675:	e9 70 01 00 00       	jmp    8007ea <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80067d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
  800684:	89 04 24             	mov    %eax,(%esp)
  800687:	e8 3e fd ff ff       	call   8003ca <getint>
  80068c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80068f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800692:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800695:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800698:	85 d2                	test   %edx,%edx
  80069a:	79 26                	jns    8006c2 <vprintfmt+0x2b1>
				putch('-', putdat);
  80069c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	ff d0                	call   *%eax
				num = -(long long) num;
  8006af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b5:	f7 d8                	neg    %eax
  8006b7:	83 d2 00             	adc    $0x0,%edx
  8006ba:	f7 da                	neg    %edx
  8006bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006bf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006c2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006c9:	e9 a8 00 00 00       	jmp    800776 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	e8 9b fc ff ff       	call   80037b <getuint>
  8006e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006e6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006ed:	e9 84 00 00 00       	jmp    800776 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	e8 77 fc ff ff       	call   80037b <getuint>
  800704:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800707:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80070a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800711:	eb 63                	jmp    800776 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800713:	8b 45 0c             	mov    0xc(%ebp),%eax
  800716:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	ff d0                	call   *%eax
			putch('x', putdat);
  800726:	8b 45 0c             	mov    0xc(%ebp),%eax
  800729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8d 50 04             	lea    0x4(%eax),%edx
  80073f:	89 55 14             	mov    %edx,0x14(%ebp)
  800742:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800747:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800755:	eb 1f                	jmp    800776 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800757:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	89 04 24             	mov    %eax,(%esp)
  800764:	e8 12 fc ff ff       	call   80037b <getuint>
  800769:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80076f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800776:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80077a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077d:	89 54 24 18          	mov    %edx,0x18(%esp)
  800781:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800784:	89 54 24 14          	mov    %edx,0x14(%esp)
  800788:	89 44 24 10          	mov    %eax,0x10(%esp)
  80078c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800792:	89 44 24 08          	mov    %eax,0x8(%esp)
  800796:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	e8 f1 fa ff ff       	call   80029d <printnum>
			break;
  8007ac:	eb 3c                	jmp    8007ea <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b5:	89 1c 24             	mov    %ebx,(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	ff d0                	call   *%eax
			break;
  8007bd:	eb 2b                	jmp    8007ea <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007d6:	eb 04                	jmp    8007dc <vprintfmt+0x3cb>
  8007d8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007df:	83 e8 01             	sub    $0x1,%eax
  8007e2:	0f b6 00             	movzbl (%eax),%eax
  8007e5:	3c 25                	cmp    $0x25,%al
  8007e7:	75 ef                	jne    8007d8 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8007e9:	90                   	nop
		}
	}
  8007ea:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007eb:	e9 43 fc ff ff       	jmp    800433 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007f0:	83 c4 40             	add    $0x40,%esp
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800800:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800803:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 ee fb ff ff       	call   800411 <vprintfmt>
	va_end(ap);
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082b:	8b 40 08             	mov    0x8(%eax),%eax
  80082e:	8d 50 01             	lea    0x1(%eax),%edx
  800831:	8b 45 0c             	mov    0xc(%ebp),%eax
  800834:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083f:	8b 40 04             	mov    0x4(%eax),%eax
  800842:	39 c2                	cmp    %eax,%edx
  800844:	73 12                	jae    800858 <sprintputch+0x33>
		*b->buf++ = ch;
  800846:	8b 45 0c             	mov    0xc(%ebp),%eax
  800849:	8b 00                	mov    (%eax),%eax
  80084b:	8d 48 01             	lea    0x1(%eax),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 0a                	mov    %ecx,(%edx)
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
  800856:	88 10                	mov    %dl,(%eax)
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800866:	8b 45 0c             	mov    0xc(%ebp),%eax
  800869:	8d 50 ff             	lea    -0x1(%eax),%edx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	01 d0                	add    %edx,%eax
  800871:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800874:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80087f:	74 06                	je     800887 <vsnprintf+0x2d>
  800881:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800885:	7f 07                	jg     80088e <vsnprintf+0x34>
		return -E_INVAL;
  800887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088c:	eb 2a                	jmp    8008b8 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088e:	8b 45 14             	mov    0x14(%ebp),%eax
  800891:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800895:	8b 45 10             	mov    0x10(%ebp),%eax
  800898:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	c7 04 24 25 08 80 00 	movl   $0x800825,(%esp)
  8008aa:	e8 62 fb ff ff       	call   800411 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	89 04 24             	mov    %eax,(%esp)
  8008e1:	e8 74 ff ff ff       	call   80085a <vsnprintf>
  8008e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008fb:	eb 08                	jmp    800905 <strlen+0x17>
		n++;
  8008fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800901:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	84 c0                	test   %al,%al
  80090d:	75 ee                	jne    8008fd <strlen+0xf>
		n++;
	return n;
  80090f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800921:	eb 0c                	jmp    80092f <strnlen+0x1b>
		n++;
  800923:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800927:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80092b:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80092f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800933:	74 0a                	je     80093f <strnlen+0x2b>
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 00             	movzbl (%eax),%eax
  80093b:	84 c0                	test   %al,%al
  80093d:	75 e4                	jne    800923 <strnlen+0xf>
		n++;
	return n;
  80093f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800950:	90                   	nop
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8d 50 01             	lea    0x1(%eax),%edx
  800957:	89 55 08             	mov    %edx,0x8(%ebp)
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800960:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800963:	0f b6 12             	movzbl (%edx),%edx
  800966:	88 10                	mov    %dl,(%eax)
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	84 c0                	test   %al,%al
  80096d:	75 e2                	jne    800951 <strcpy+0xd>
		/* do nothing */;
	return ret;
  80096f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	89 04 24             	mov    %eax,(%esp)
  800980:	e8 69 ff ff ff       	call   8008ee <strlen>
  800985:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800988:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	01 c2                	add    %eax,%edx
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	89 44 24 04          	mov    %eax,0x4(%esp)
  800997:	89 14 24             	mov    %edx,(%esp)
  80099a:	e8 a5 ff ff ff       	call   800944 <strcpy>
	return dst;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009b0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009b7:	eb 23                	jmp    8009dc <strncpy+0x38>
		*dst++ = *src;
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8d 50 01             	lea    0x1(%eax),%edx
  8009bf:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cd:	0f b6 00             	movzbl (%eax),%eax
  8009d0:	84 c0                	test   %al,%al
  8009d2:	74 04                	je     8009d8 <strncpy+0x34>
			src++;
  8009d4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009df:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009e2:	72 d5                	jb     8009b9 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009e4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f9:	74 33                	je     800a2e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009fb:	eb 17                	jmp    800a14 <strlcpy+0x2b>
			*dst++ = *src++;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8d 50 01             	lea    0x1(%eax),%edx
  800a03:	89 55 08             	mov    %edx,0x8(%ebp)
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a0c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a14:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a1c:	74 0a                	je     800a28 <strlcpy+0x3f>
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	0f b6 00             	movzbl (%eax),%eax
  800a24:	84 c0                	test   %al,%al
  800a26:	75 d5                	jne    8009fd <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a34:	29 c2                	sub    %eax,%edx
  800a36:	89 d0                	mov    %edx,%eax
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a3d:	eb 08                	jmp    800a47 <strcmp+0xd>
		p++, q++;
  800a3f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a43:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	0f b6 00             	movzbl (%eax),%eax
  800a4d:	84 c0                	test   %al,%al
  800a4f:	74 10                	je     800a61 <strcmp+0x27>
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 10             	movzbl (%eax),%edx
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	0f b6 00             	movzbl (%eax),%eax
  800a5d:	38 c2                	cmp    %al,%dl
  800a5f:	74 de                	je     800a3f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	0f b6 00             	movzbl (%eax),%eax
  800a67:	0f b6 d0             	movzbl %al,%edx
  800a6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6d:	0f b6 00             	movzbl (%eax),%eax
  800a70:	0f b6 c0             	movzbl %al,%eax
  800a73:	29 c2                	sub    %eax,%edx
  800a75:	89 d0                	mov    %edx,%eax
}
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a7c:	eb 0c                	jmp    800a8a <strncmp+0x11>
		n--, p++, q++;
  800a7e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a8e:	74 1a                	je     800aaa <strncmp+0x31>
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	0f b6 00             	movzbl (%eax),%eax
  800a96:	84 c0                	test   %al,%al
  800a98:	74 10                	je     800aaa <strncmp+0x31>
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa3:	0f b6 00             	movzbl (%eax),%eax
  800aa6:	38 c2                	cmp    %al,%dl
  800aa8:	74 d4                	je     800a7e <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800aaa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aae:	75 07                	jne    800ab7 <strncmp+0x3e>
		return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	eb 16                	jmp    800acd <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	0f b6 00             	movzbl (%eax),%eax
  800abd:	0f b6 d0             	movzbl %al,%edx
  800ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac3:	0f b6 00             	movzbl (%eax),%eax
  800ac6:	0f b6 c0             	movzbl %al,%eax
  800ac9:	29 c2                	sub    %eax,%edx
  800acb:	89 d0                	mov    %edx,%eax
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 04             	sub    $0x4,%esp
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800adb:	eb 14                	jmp    800af1 <strchr+0x22>
		if (*s == c)
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	0f b6 00             	movzbl (%eax),%eax
  800ae3:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ae6:	75 05                	jne    800aed <strchr+0x1e>
			return (char *) s;
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	eb 13                	jmp    800b00 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	0f b6 00             	movzbl (%eax),%eax
  800af7:	84 c0                	test   %al,%al
  800af9:	75 e2                	jne    800add <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	83 ec 04             	sub    $0x4,%esp
  800b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b0e:	eb 11                	jmp    800b21 <strfind+0x1f>
		if (*s == c)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	0f b6 00             	movzbl (%eax),%eax
  800b16:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b19:	75 02                	jne    800b1d <strfind+0x1b>
			break;
  800b1b:	eb 0e                	jmp    800b2b <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	0f b6 00             	movzbl (%eax),%eax
  800b27:	84 c0                	test   %al,%al
  800b29:	75 e5                	jne    800b10 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b38:	75 05                	jne    800b3f <memset+0xf>
		return v;
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	eb 5c                	jmp    800b9b <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	83 e0 03             	and    $0x3,%eax
  800b45:	85 c0                	test   %eax,%eax
  800b47:	75 41                	jne    800b8a <memset+0x5a>
  800b49:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4c:	83 e0 03             	and    $0x3,%eax
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	75 37                	jne    800b8a <memset+0x5a>
		c &= 0xFF;
  800b53:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	c1 e0 18             	shl    $0x18,%eax
  800b60:	89 c2                	mov    %eax,%edx
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	c1 e0 10             	shl    $0x10,%eax
  800b68:	09 c2                	or     %eax,%edx
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	c1 e0 08             	shl    $0x8,%eax
  800b70:	09 d0                	or     %edx,%eax
  800b72:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b75:	8b 45 10             	mov    0x10(%ebp),%eax
  800b78:	c1 e8 02             	shr    $0x2,%eax
  800b7b:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	89 d7                	mov    %edx,%edi
  800b85:	fc                   	cld    
  800b86:	f3 ab                	rep stos %eax,%es:(%edi)
  800b88:	eb 0e                	jmp    800b98 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b90:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	fc                   	cld    
  800b96:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bb9:	73 6d                	jae    800c28 <memmove+0x8a>
  800bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bc1:	01 d0                	add    %edx,%eax
  800bc3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bc6:	76 60                	jbe    800c28 <memmove+0x8a>
		s += n;
  800bc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcb:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bce:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd1:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd7:	83 e0 03             	and    $0x3,%eax
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	75 2f                	jne    800c0d <memmove+0x6f>
  800bde:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be1:	83 e0 03             	and    $0x3,%eax
  800be4:	85 c0                	test   %eax,%eax
  800be6:	75 25                	jne    800c0d <memmove+0x6f>
  800be8:	8b 45 10             	mov    0x10(%ebp),%eax
  800beb:	83 e0 03             	and    $0x3,%eax
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	75 1b                	jne    800c0d <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf5:	83 e8 04             	sub    $0x4,%eax
  800bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bfb:	83 ea 04             	sub    $0x4,%edx
  800bfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c01:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	fd                   	std    
  800c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0b:	eb 18                	jmp    800c25 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c10:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c16:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c19:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	89 c1                	mov    %eax,%ecx
  800c22:	fd                   	std    
  800c23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c25:	fc                   	cld    
  800c26:	eb 45                	jmp    800c6d <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2b:	83 e0 03             	and    $0x3,%eax
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	75 2b                	jne    800c5d <memmove+0xbf>
  800c32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c35:	83 e0 03             	and    $0x3,%eax
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	75 21                	jne    800c5d <memmove+0xbf>
  800c3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3f:	83 e0 03             	and    $0x3,%eax
  800c42:	85 c0                	test   %eax,%eax
  800c44:	75 17                	jne    800c5d <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c46:	8b 45 10             	mov    0x10(%ebp),%eax
  800c49:	c1 e8 02             	shr    $0x2,%eax
  800c4c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c51:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c54:	89 c7                	mov    %eax,%edi
  800c56:	89 d6                	mov    %edx,%esi
  800c58:	fc                   	cld    
  800c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5b:	eb 10                	jmp    800c6d <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c63:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	89 d6                	mov    %edx,%esi
  800c6a:	fc                   	cld    
  800c6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 07 ff ff ff       	call   800b9e <memmove>
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca8:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cab:	eb 30                	jmp    800cdd <memcmp+0x44>
		if (*s1 != *s2)
  800cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cb0:	0f b6 10             	movzbl (%eax),%edx
  800cb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cb6:	0f b6 00             	movzbl (%eax),%eax
  800cb9:	38 c2                	cmp    %al,%dl
  800cbb:	74 18                	je     800cd5 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cc0:	0f b6 00             	movzbl (%eax),%eax
  800cc3:	0f b6 d0             	movzbl %al,%edx
  800cc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cc9:	0f b6 00             	movzbl (%eax),%eax
  800ccc:	0f b6 c0             	movzbl %al,%eax
  800ccf:	29 c2                	sub    %eax,%edx
  800cd1:	89 d0                	mov    %edx,%eax
  800cd3:	eb 1a                	jmp    800cef <memcmp+0x56>
		s1++, s2++;
  800cd5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cd9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ce3:	89 55 10             	mov    %edx,0x10(%ebp)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	75 c3                	jne    800cad <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	01 d0                	add    %edx,%eax
  800cff:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d02:	eb 13                	jmp    800d17 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	0f b6 10             	movzbl (%eax),%edx
  800d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0d:	38 c2                	cmp    %al,%dl
  800d0f:	75 02                	jne    800d13 <memfind+0x22>
			break;
  800d11:	eb 0c                	jmp    800d1f <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d13:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d1d:	72 e5                	jb     800d04 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d2a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d31:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d38:	eb 04                	jmp    800d3e <strtol+0x1a>
		s++;
  800d3a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	0f b6 00             	movzbl (%eax),%eax
  800d44:	3c 20                	cmp    $0x20,%al
  800d46:	74 f2                	je     800d3a <strtol+0x16>
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	0f b6 00             	movzbl (%eax),%eax
  800d4e:	3c 09                	cmp    $0x9,%al
  800d50:	74 e8                	je     800d3a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	0f b6 00             	movzbl (%eax),%eax
  800d58:	3c 2b                	cmp    $0x2b,%al
  800d5a:	75 06                	jne    800d62 <strtol+0x3e>
		s++;
  800d5c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d60:	eb 15                	jmp    800d77 <strtol+0x53>
	else if (*s == '-')
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	3c 2d                	cmp    $0x2d,%al
  800d6a:	75 0b                	jne    800d77 <strtol+0x53>
		s++, neg = 1;
  800d6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d70:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d7b:	74 06                	je     800d83 <strtol+0x5f>
  800d7d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d81:	75 24                	jne    800da7 <strtol+0x83>
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	3c 30                	cmp    $0x30,%al
  800d8b:	75 1a                	jne    800da7 <strtol+0x83>
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	83 c0 01             	add    $0x1,%eax
  800d93:	0f b6 00             	movzbl (%eax),%eax
  800d96:	3c 78                	cmp    $0x78,%al
  800d98:	75 0d                	jne    800da7 <strtol+0x83>
		s += 2, base = 16;
  800d9a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d9e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800da5:	eb 2a                	jmp    800dd1 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800da7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dab:	75 17                	jne    800dc4 <strtol+0xa0>
  800dad:	8b 45 08             	mov    0x8(%ebp),%eax
  800db0:	0f b6 00             	movzbl (%eax),%eax
  800db3:	3c 30                	cmp    $0x30,%al
  800db5:	75 0d                	jne    800dc4 <strtol+0xa0>
		s++, base = 8;
  800db7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dc2:	eb 0d                	jmp    800dd1 <strtol+0xad>
	else if (base == 0)
  800dc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc8:	75 07                	jne    800dd1 <strtol+0xad>
		base = 10;
  800dca:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd4:	0f b6 00             	movzbl (%eax),%eax
  800dd7:	3c 2f                	cmp    $0x2f,%al
  800dd9:	7e 1b                	jle    800df6 <strtol+0xd2>
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	0f b6 00             	movzbl (%eax),%eax
  800de1:	3c 39                	cmp    $0x39,%al
  800de3:	7f 11                	jg     800df6 <strtol+0xd2>
			dig = *s - '0';
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	0f b6 00             	movzbl (%eax),%eax
  800deb:	0f be c0             	movsbl %al,%eax
  800dee:	83 e8 30             	sub    $0x30,%eax
  800df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800df4:	eb 48                	jmp    800e3e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	0f b6 00             	movzbl (%eax),%eax
  800dfc:	3c 60                	cmp    $0x60,%al
  800dfe:	7e 1b                	jle    800e1b <strtol+0xf7>
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	0f b6 00             	movzbl (%eax),%eax
  800e06:	3c 7a                	cmp    $0x7a,%al
  800e08:	7f 11                	jg     800e1b <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	0f b6 00             	movzbl (%eax),%eax
  800e10:	0f be c0             	movsbl %al,%eax
  800e13:	83 e8 57             	sub    $0x57,%eax
  800e16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e19:	eb 23                	jmp    800e3e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	0f b6 00             	movzbl (%eax),%eax
  800e21:	3c 40                	cmp    $0x40,%al
  800e23:	7e 3d                	jle    800e62 <strtol+0x13e>
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	0f b6 00             	movzbl (%eax),%eax
  800e2b:	3c 5a                	cmp    $0x5a,%al
  800e2d:	7f 33                	jg     800e62 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	0f b6 00             	movzbl (%eax),%eax
  800e35:	0f be c0             	movsbl %al,%eax
  800e38:	83 e8 37             	sub    $0x37,%eax
  800e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e44:	7c 02                	jl     800e48 <strtol+0x124>
			break;
  800e46:	eb 1a                	jmp    800e62 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e48:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e58:	01 d0                	add    %edx,%eax
  800e5a:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e5d:	e9 6f ff ff ff       	jmp    800dd1 <strtol+0xad>

	if (endptr)
  800e62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e66:	74 08                	je     800e70 <strtol+0x14c>
		*endptr = (char *) s;
  800e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e70:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e74:	74 07                	je     800e7d <strtol+0x159>
  800e76:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e79:	f7 d8                	neg    %eax
  800e7b:	eb 03                	jmp    800e80 <strtol+0x15c>
  800e7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	8b 55 10             	mov    0x10(%ebp),%edx
  800e91:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e94:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e97:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e9a:	8b 75 20             	mov    0x20(%ebp),%esi
  800e9d:	cd 30                	int    $0x30
  800e9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ea6:	74 30                	je     800ed8 <syscall+0x56>
  800ea8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eac:	7e 2a                	jle    800ed8 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebc:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecb:	00 
  800ecc:	c7 04 24 41 18 80 00 	movl   $0x801841,(%esp)
  800ed3:	e8 84 f2 ff ff       	call   80015c <_panic>

	return ret;
  800ed8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800edb:	83 c4 3c             	add    $0x3c,%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eec:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800efb:	00 
  800efc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f03:	00 
  800f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f07:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1e:	e8 5f ff ff ff       	call   800e82 <syscall>
}
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    

00800f25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f2b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f32:	00 
  800f33:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f42:	00 
  800f43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f52:	00 
  800f53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5a:	00 
  800f5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f62:	e8 1b ff ff ff       	call   800e82 <syscall>
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f79:	00 
  800f7a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f81:	00 
  800f82:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f89:	00 
  800f8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f91:	00 
  800f92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f96:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f9d:	00 
  800f9e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fa5:	e8 d8 fe ff ff       	call   800e82 <syscall>
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fb2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fb9:	00 
  800fba:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fc9:	00 
  800fca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe1:	00 
  800fe2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fe9:	e8 94 fe ff ff       	call   800e82 <syscall>
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <sys_yield>:

void
sys_yield(void)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ff6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801005:	00 
  801006:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80100d:	00 
  80100e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801015:	00 
  801016:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80101d:	00 
  80101e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801025:	00 
  801026:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80102d:	e8 50 fe ff ff       	call   800e82 <syscall>
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80103a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80103d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801040:	8b 45 08             	mov    0x8(%ebp),%eax
  801043:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80104a:	00 
  80104b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801052:	00 
  801053:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801057:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80105b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801066:	00 
  801067:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80106e:	e8 0f fe ff ff       	call   800e82 <syscall>
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80107d:	8b 75 18             	mov    0x18(%ebp),%esi
  801080:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801083:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801086:	8b 55 0c             	mov    0xc(%ebp),%edx
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801090:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801094:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801098:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80109c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a7:	00 
  8010a8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010af:	e8 ce fd ff ff       	call   800e82 <syscall>
}
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010ce:	00 
  8010cf:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d6:	00 
  8010d7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010de:	00 
  8010df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ee:	00 
  8010ef:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010f6:	e8 87 fd ff ff       	call   800e82 <syscall>
}
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801103:	8b 55 0c             	mov    0xc(%ebp),%edx
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801110:	00 
  801111:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801118:	00 
  801119:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801120:	00 
  801121:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801125:	89 44 24 08          	mov    %eax,0x8(%esp)
  801129:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801130:	00 
  801131:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801138:	e8 45 fd ff ff       	call   800e82 <syscall>
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801145:	8b 55 0c             	mov    0xc(%ebp),%edx
  801148:	8b 45 08             	mov    0x8(%ebp),%eax
  80114b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801152:	00 
  801153:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115a:	00 
  80115b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801162:	00 
  801163:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801172:	00 
  801173:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80117a:	e8 03 fd ff ff       	call   800e82 <syscall>
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801187:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80118a:	8b 55 10             	mov    0x10(%ebp),%edx
  80118d:	8b 45 08             	mov    0x8(%ebp),%eax
  801190:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801197:	00 
  801198:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80119c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011ba:	e8 c3 fc ff ff       	call   800e82 <syscall>
}
  8011bf:	c9                   	leave  
  8011c0:	c3                   	ret    

008011c1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011d9:	00 
  8011da:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011e1:	00 
  8011e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011e9:	00 
  8011ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011f5:	00 
  8011f6:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011fd:	e8 80 fc ff ff       	call   800e82 <syscall>
}
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80120a:	a1 08 20 80 00       	mov    0x802008,%eax
  80120f:	85 c0                	test   %eax,%eax
  801211:	75 5d                	jne    801270 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801213:	a1 04 20 80 00       	mov    0x802004,%eax
  801218:	8b 40 48             	mov    0x48(%eax),%eax
  80121b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801222:	00 
  801223:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80122a:	ee 
  80122b:	89 04 24             	mov    %eax,(%esp)
  80122e:	e8 01 fe ff ff       	call   801034 <sys_page_alloc>
  801233:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801236:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80123a:	79 1c                	jns    801258 <set_pgfault_handler+0x54>
  80123c:	c7 44 24 08 50 18 80 	movl   $0x801850,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80124b:	00 
  80124c:	c7 04 24 7c 18 80 00 	movl   $0x80187c,(%esp)
  801253:	e8 04 ef ff ff       	call   80015c <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801258:	a1 04 20 80 00       	mov    0x802004,%eax
  80125d:	8b 40 48             	mov    0x48(%eax),%eax
  801260:	c7 44 24 04 7a 12 80 	movl   $0x80127a,0x4(%esp)
  801267:	00 
  801268:	89 04 24             	mov    %eax,(%esp)
  80126b:	e8 cf fe ff ff       	call   80113f <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80127a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80127b:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801280:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801282:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801285:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801289:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80128b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80128f:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801290:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801293:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801295:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801296:	58                   	pop    %eax
	popal 						// pop all the registers
  801297:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801298:	83 c4 04             	add    $0x4,%esp
	popfl
  80129b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80129c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80129d:	c3                   	ret    
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__udivdi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012bc:	89 ea                	mov    %ebp,%edx
  8012be:	89 0c 24             	mov    %ecx,(%esp)
  8012c1:	75 2d                	jne    8012f0 <__udivdi3+0x50>
  8012c3:	39 e9                	cmp    %ebp,%ecx
  8012c5:	77 61                	ja     801328 <__udivdi3+0x88>
  8012c7:	85 c9                	test   %ecx,%ecx
  8012c9:	89 ce                	mov    %ecx,%esi
  8012cb:	75 0b                	jne    8012d8 <__udivdi3+0x38>
  8012cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d2:	31 d2                	xor    %edx,%edx
  8012d4:	f7 f1                	div    %ecx
  8012d6:	89 c6                	mov    %eax,%esi
  8012d8:	31 d2                	xor    %edx,%edx
  8012da:	89 e8                	mov    %ebp,%eax
  8012dc:	f7 f6                	div    %esi
  8012de:	89 c5                	mov    %eax,%ebp
  8012e0:	89 f8                	mov    %edi,%eax
  8012e2:	f7 f6                	div    %esi
  8012e4:	89 ea                	mov    %ebp,%edx
  8012e6:	83 c4 0c             	add    $0xc,%esp
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    
  8012ed:	8d 76 00             	lea    0x0(%esi),%esi
  8012f0:	39 e8                	cmp    %ebp,%eax
  8012f2:	77 24                	ja     801318 <__udivdi3+0x78>
  8012f4:	0f bd e8             	bsr    %eax,%ebp
  8012f7:	83 f5 1f             	xor    $0x1f,%ebp
  8012fa:	75 3c                	jne    801338 <__udivdi3+0x98>
  8012fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801300:	39 34 24             	cmp    %esi,(%esp)
  801303:	0f 86 9f 00 00 00    	jbe    8013a8 <__udivdi3+0x108>
  801309:	39 d0                	cmp    %edx,%eax
  80130b:	0f 82 97 00 00 00    	jb     8013a8 <__udivdi3+0x108>
  801311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801318:	31 d2                	xor    %edx,%edx
  80131a:	31 c0                	xor    %eax,%eax
  80131c:	83 c4 0c             	add    $0xc,%esp
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    
  801323:	90                   	nop
  801324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801328:	89 f8                	mov    %edi,%eax
  80132a:	f7 f1                	div    %ecx
  80132c:	31 d2                	xor    %edx,%edx
  80132e:	83 c4 0c             	add    $0xc,%esp
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    
  801335:	8d 76 00             	lea    0x0(%esi),%esi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	8b 3c 24             	mov    (%esp),%edi
  80133d:	d3 e0                	shl    %cl,%eax
  80133f:	89 c6                	mov    %eax,%esi
  801341:	b8 20 00 00 00       	mov    $0x20,%eax
  801346:	29 e8                	sub    %ebp,%eax
  801348:	89 c1                	mov    %eax,%ecx
  80134a:	d3 ef                	shr    %cl,%edi
  80134c:	89 e9                	mov    %ebp,%ecx
  80134e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801352:	8b 3c 24             	mov    (%esp),%edi
  801355:	09 74 24 08          	or     %esi,0x8(%esp)
  801359:	89 d6                	mov    %edx,%esi
  80135b:	d3 e7                	shl    %cl,%edi
  80135d:	89 c1                	mov    %eax,%ecx
  80135f:	89 3c 24             	mov    %edi,(%esp)
  801362:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801366:	d3 ee                	shr    %cl,%esi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	d3 e2                	shl    %cl,%edx
  80136c:	89 c1                	mov    %eax,%ecx
  80136e:	d3 ef                	shr    %cl,%edi
  801370:	09 d7                	or     %edx,%edi
  801372:	89 f2                	mov    %esi,%edx
  801374:	89 f8                	mov    %edi,%eax
  801376:	f7 74 24 08          	divl   0x8(%esp)
  80137a:	89 d6                	mov    %edx,%esi
  80137c:	89 c7                	mov    %eax,%edi
  80137e:	f7 24 24             	mull   (%esp)
  801381:	39 d6                	cmp    %edx,%esi
  801383:	89 14 24             	mov    %edx,(%esp)
  801386:	72 30                	jb     8013b8 <__udivdi3+0x118>
  801388:	8b 54 24 04          	mov    0x4(%esp),%edx
  80138c:	89 e9                	mov    %ebp,%ecx
  80138e:	d3 e2                	shl    %cl,%edx
  801390:	39 c2                	cmp    %eax,%edx
  801392:	73 05                	jae    801399 <__udivdi3+0xf9>
  801394:	3b 34 24             	cmp    (%esp),%esi
  801397:	74 1f                	je     8013b8 <__udivdi3+0x118>
  801399:	89 f8                	mov    %edi,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	e9 7a ff ff ff       	jmp    80131c <__udivdi3+0x7c>
  8013a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013a8:	31 d2                	xor    %edx,%edx
  8013aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8013af:	e9 68 ff ff ff       	jmp    80131c <__udivdi3+0x7c>
  8013b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	83 c4 0c             	add    $0xc,%esp
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    
  8013c4:	66 90                	xchg   %ax,%ax
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	83 ec 14             	sub    $0x14,%esp
  8013d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013e2:	89 c7                	mov    %eax,%edi
  8013e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013f0:	89 34 24             	mov    %esi,(%esp)
  8013f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	89 c2                	mov    %eax,%edx
  8013fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013ff:	75 17                	jne    801418 <__umoddi3+0x48>
  801401:	39 fe                	cmp    %edi,%esi
  801403:	76 4b                	jbe    801450 <__umoddi3+0x80>
  801405:	89 c8                	mov    %ecx,%eax
  801407:	89 fa                	mov    %edi,%edx
  801409:	f7 f6                	div    %esi
  80140b:	89 d0                	mov    %edx,%eax
  80140d:	31 d2                	xor    %edx,%edx
  80140f:	83 c4 14             	add    $0x14,%esp
  801412:	5e                   	pop    %esi
  801413:	5f                   	pop    %edi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    
  801416:	66 90                	xchg   %ax,%ax
  801418:	39 f8                	cmp    %edi,%eax
  80141a:	77 54                	ja     801470 <__umoddi3+0xa0>
  80141c:	0f bd e8             	bsr    %eax,%ebp
  80141f:	83 f5 1f             	xor    $0x1f,%ebp
  801422:	75 5c                	jne    801480 <__umoddi3+0xb0>
  801424:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801428:	39 3c 24             	cmp    %edi,(%esp)
  80142b:	0f 87 e7 00 00 00    	ja     801518 <__umoddi3+0x148>
  801431:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801435:	29 f1                	sub    %esi,%ecx
  801437:	19 c7                	sbb    %eax,%edi
  801439:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80143d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801441:	8b 44 24 08          	mov    0x8(%esp),%eax
  801445:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801449:	83 c4 14             	add    $0x14,%esp
  80144c:	5e                   	pop    %esi
  80144d:	5f                   	pop    %edi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    
  801450:	85 f6                	test   %esi,%esi
  801452:	89 f5                	mov    %esi,%ebp
  801454:	75 0b                	jne    801461 <__umoddi3+0x91>
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	f7 f6                	div    %esi
  80145f:	89 c5                	mov    %eax,%ebp
  801461:	8b 44 24 04          	mov    0x4(%esp),%eax
  801465:	31 d2                	xor    %edx,%edx
  801467:	f7 f5                	div    %ebp
  801469:	89 c8                	mov    %ecx,%eax
  80146b:	f7 f5                	div    %ebp
  80146d:	eb 9c                	jmp    80140b <__umoddi3+0x3b>
  80146f:	90                   	nop
  801470:	89 c8                	mov    %ecx,%eax
  801472:	89 fa                	mov    %edi,%edx
  801474:	83 c4 14             	add    $0x14,%esp
  801477:	5e                   	pop    %esi
  801478:	5f                   	pop    %edi
  801479:	5d                   	pop    %ebp
  80147a:	c3                   	ret    
  80147b:	90                   	nop
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	8b 04 24             	mov    (%esp),%eax
  801483:	be 20 00 00 00       	mov    $0x20,%esi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	29 ee                	sub    %ebp,%esi
  80148c:	d3 e2                	shl    %cl,%edx
  80148e:	89 f1                	mov    %esi,%ecx
  801490:	d3 e8                	shr    %cl,%eax
  801492:	89 e9                	mov    %ebp,%ecx
  801494:	89 44 24 04          	mov    %eax,0x4(%esp)
  801498:	8b 04 24             	mov    (%esp),%eax
  80149b:	09 54 24 04          	or     %edx,0x4(%esp)
  80149f:	89 fa                	mov    %edi,%edx
  8014a1:	d3 e0                	shl    %cl,%eax
  8014a3:	89 f1                	mov    %esi,%ecx
  8014a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014ad:	d3 ea                	shr    %cl,%edx
  8014af:	89 e9                	mov    %ebp,%ecx
  8014b1:	d3 e7                	shl    %cl,%edi
  8014b3:	89 f1                	mov    %esi,%ecx
  8014b5:	d3 e8                	shr    %cl,%eax
  8014b7:	89 e9                	mov    %ebp,%ecx
  8014b9:	09 f8                	or     %edi,%eax
  8014bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8014bf:	f7 74 24 04          	divl   0x4(%esp)
  8014c3:	d3 e7                	shl    %cl,%edi
  8014c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014c9:	89 d7                	mov    %edx,%edi
  8014cb:	f7 64 24 08          	mull   0x8(%esp)
  8014cf:	39 d7                	cmp    %edx,%edi
  8014d1:	89 c1                	mov    %eax,%ecx
  8014d3:	89 14 24             	mov    %edx,(%esp)
  8014d6:	72 2c                	jb     801504 <__umoddi3+0x134>
  8014d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014dc:	72 22                	jb     801500 <__umoddi3+0x130>
  8014de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014e2:	29 c8                	sub    %ecx,%eax
  8014e4:	19 d7                	sbb    %edx,%edi
  8014e6:	89 e9                	mov    %ebp,%ecx
  8014e8:	89 fa                	mov    %edi,%edx
  8014ea:	d3 e8                	shr    %cl,%eax
  8014ec:	89 f1                	mov    %esi,%ecx
  8014ee:	d3 e2                	shl    %cl,%edx
  8014f0:	89 e9                	mov    %ebp,%ecx
  8014f2:	d3 ef                	shr    %cl,%edi
  8014f4:	09 d0                	or     %edx,%eax
  8014f6:	89 fa                	mov    %edi,%edx
  8014f8:	83 c4 14             	add    $0x14,%esp
  8014fb:	5e                   	pop    %esi
  8014fc:	5f                   	pop    %edi
  8014fd:	5d                   	pop    %ebp
  8014fe:	c3                   	ret    
  8014ff:	90                   	nop
  801500:	39 d7                	cmp    %edx,%edi
  801502:	75 da                	jne    8014de <__umoddi3+0x10e>
  801504:	8b 14 24             	mov    (%esp),%edx
  801507:	89 c1                	mov    %eax,%ecx
  801509:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80150d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801511:	eb cb                	jmp    8014de <__umoddi3+0x10e>
  801513:	90                   	nop
  801514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801518:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80151c:	0f 82 0f ff ff ff    	jb     801431 <__umoddi3+0x61>
  801522:	e9 1a ff ff ff       	jmp    801441 <__umoddi3+0x71>
