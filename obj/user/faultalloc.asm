
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
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
  800048:	c7 04 24 a0 15 80 00 	movl   $0x8015a0,(%esp)
  80004f:	e8 37 02 00 00       	call   80028b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80005a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800069:	00 
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800075:	e8 ce 0f 00 00       	call   801048 <sys_page_alloc>
  80007a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80007d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800081:	79 2a                	jns    8000ad <handler+0x7a>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800083:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800091:	c7 44 24 08 ac 15 80 	movl   $0x8015ac,0x8(%esp)
  800098:	00 
  800099:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000a0:	00 
  8000a1:	c7 04 24 d7 15 80 00 	movl   $0x8015d7,(%esp)
  8000a8:	e8 c3 00 00 00       	call   800170 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b4:	c7 44 24 08 ec 15 80 	movl   $0x8015ec,0x8(%esp)
  8000bb:	00 
  8000bc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000c3:	00 
  8000c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 ff 07 00 00       	call   8008ce <snprintf>
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
  8000de:	e8 78 11 00 00       	call   80125b <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000e3:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000ea:	de 
  8000eb:	c7 04 24 0d 16 80 00 	movl   $0x80160d,(%esp)
  8000f2:	e8 94 01 00 00       	call   80028b <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000f7:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000fe:	ca 
  8000ff:	c7 04 24 0d 16 80 00 	movl   $0x80160d,(%esp)
  800106:	e8 80 01 00 00       	call   80028b <cprintf>
}
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800113:	e8 a8 0e 00 00       	call   800fc0 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	c1 e0 02             	shl    $0x2,%eax
  800120:	89 c2                	mov    %eax,%edx
  800122:	c1 e2 05             	shl    $0x5,%edx
  800125:	29 c2                	sub    %eax,%edx
  800127:	89 d0                	mov    %edx,%eax
  800129:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800133:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800137:	7e 0a                	jle    800143 <libmain+0x36>
		binaryname = argv[0];
  800139:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013c:	8b 00                	mov    (%eax),%eax
  80013e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800143:	8b 45 0c             	mov    0xc(%ebp),%eax
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	8b 45 08             	mov    0x8(%ebp),%eax
  80014d:	89 04 24             	mov    %eax,(%esp)
  800150:	e8 7c ff ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800155:	e8 02 00 00 00       	call   80015c <exit>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800169:	e8 0f 0e 00 00       	call   800f7d <sys_env_destroy>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800177:	8d 45 14             	lea    0x14(%ebp),%eax
  80017a:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800183:	e8 38 0e 00 00       	call   800fc0 <sys_getenvid>
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800196:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	c7 04 24 1c 16 80 00 	movl   $0x80161c,(%esp)
  8001a5:	e8 e1 00 00 00       	call   80028b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b4:	89 04 24             	mov    %eax,(%esp)
  8001b7:	e8 6b 00 00 00       	call   800227 <vcprintf>
	cprintf("\n");
  8001bc:	c7 04 24 3f 16 80 00 	movl   $0x80163f,(%esp)
  8001c3:	e8 c3 00 00 00       	call   80028b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c8:	cc                   	int3   
  8001c9:	eb fd                	jmp    8001c8 <_panic+0x58>

008001cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d4:	8b 00                	mov    (%eax),%eax
  8001d6:	8d 48 01             	lea    0x1(%eax),%ecx
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 0a                	mov    %ecx,(%edx)
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e6:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ed:	8b 00                	mov    (%eax),%eax
  8001ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f4:	75 20                	jne    800216 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f9:	8b 00                	mov    (%eax),%eax
  8001fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fe:	83 c2 08             	add    $0x8,%edx
  800201:	89 44 24 04          	mov    %eax,0x4(%esp)
  800205:	89 14 24             	mov    %edx,(%esp)
  800208:	e8 ea 0c 00 00       	call   800ef7 <sys_cputs>
		b->idx = 0;
  80020d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800210:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800216:	8b 45 0c             	mov    0xc(%ebp),%eax
  800219:	8b 40 04             	mov    0x4(%eax),%eax
  80021c:	8d 50 01             	lea    0x1(%eax),%edx
  80021f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800222:	89 50 04             	mov    %edx,0x4(%eax)
}
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800230:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800237:	00 00 00 
	b.cnt = 0;
  80023a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800241:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800244:	8b 45 0c             	mov    0xc(%ebp),%eax
  800247:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 cb 01 80 00 	movl   $0x8001cb,(%esp)
  800263:	e8 bd 01 00 00       	call   800425 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800268:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80026e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800272:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800278:	83 c0 08             	add    $0x8,%eax
  80027b:	89 04 24             	mov    %eax,(%esp)
  80027e:	e8 74 0c 00 00       	call   800ef7 <sys_cputs>

	return b.cnt;
  800283:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800291:	8d 45 0c             	lea    0xc(%ebp),%eax
  800294:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80029a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 04 24             	mov    %eax,(%esp)
  8002a4:	e8 7e ff ff ff       	call   800227 <vcprintf>
  8002a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 34             	sub    $0x34,%esp
  8002b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002be:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c4:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002cf:	77 72                	ja     800343 <printnum+0x92>
  8002d1:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002d4:	72 05                	jb     8002db <printnum+0x2a>
  8002d6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002d9:	77 68                	ja     800343 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002db:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002de:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fe:	e8 fd 0f 00 00       	call   801300 <__udivdi3>
  800303:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800306:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80030a:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80030e:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800311:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800315:	89 44 24 08          	mov    %eax,0x8(%esp)
  800319:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80031d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	e8 82 ff ff ff       	call   8002b1 <printnum>
  80032f:	eb 1c                	jmp    80034d <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
  800334:	89 44 24 04          	mov    %eax,0x4(%esp)
  800338:	8b 45 20             	mov    0x20(%ebp),%eax
  80033b:	89 04 24             	mov    %eax,(%esp)
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800343:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800347:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80034b:	7f e4                	jg     800331 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800350:	bb 00 00 00 00       	mov    $0x0,%ebx
  800355:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800358:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80035b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036a:	e8 c1 10 00 00       	call   801430 <__umoddi3>
  80036f:	05 28 17 80 00       	add    $0x801728,%eax
  800374:	0f b6 00             	movzbl (%eax),%eax
  800377:	0f be c0             	movsbl %al,%eax
  80037a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80037d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	8b 45 08             	mov    0x8(%ebp),%eax
  800387:	ff d0                	call   *%eax
}
  800389:	83 c4 34             	add    $0x34,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800392:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800396:	7e 14                	jle    8003ac <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	8d 48 08             	lea    0x8(%eax),%ecx
  8003a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a3:	89 0a                	mov    %ecx,(%edx)
  8003a5:	8b 50 04             	mov    0x4(%eax),%edx
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	eb 30                	jmp    8003dc <getuint+0x4d>
	else if (lflag)
  8003ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003b0:	74 16                	je     8003c8 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 0a                	mov    %ecx,(%edx)
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 14                	jmp    8003dc <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d3:	89 0a                	mov    %ecx,(%edx)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003e5:	7e 14                	jle    8003fb <getint+0x1d>
		return va_arg(*ap, long long);
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	8d 48 08             	lea    0x8(%eax),%ecx
  8003ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f2:	89 0a                	mov    %ecx,(%edx)
  8003f4:	8b 50 04             	mov    0x4(%eax),%edx
  8003f7:	8b 00                	mov    (%eax),%eax
  8003f9:	eb 28                	jmp    800423 <getint+0x45>
	else if (lflag)
  8003fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003ff:	74 12                	je     800413 <getint+0x35>
		return va_arg(*ap, long);
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	8b 00                	mov    (%eax),%eax
  800406:	8d 48 04             	lea    0x4(%eax),%ecx
  800409:	8b 55 08             	mov    0x8(%ebp),%edx
  80040c:	89 0a                	mov    %ecx,(%edx)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	99                   	cltd   
  800411:	eb 10                	jmp    800423 <getint+0x45>
	else
		return va_arg(*ap, int);
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	8d 48 04             	lea    0x4(%eax),%ecx
  80041b:	8b 55 08             	mov    0x8(%ebp),%edx
  80041e:	89 0a                	mov    %ecx,(%edx)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	99                   	cltd   
}
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042d:	eb 18                	jmp    800447 <vprintfmt+0x22>
			if (ch == '\0')
  80042f:	85 db                	test   %ebx,%ebx
  800431:	75 05                	jne    800438 <vprintfmt+0x13>
				return;
  800433:	e9 cc 03 00 00       	jmp    800804 <vprintfmt+0x3df>
			putch(ch, putdat);
  800438:	8b 45 0c             	mov    0xc(%ebp),%eax
  80043b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043f:	89 1c 24             	mov    %ebx,(%esp)
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800447:	8b 45 10             	mov    0x10(%ebp),%eax
  80044a:	8d 50 01             	lea    0x1(%eax),%edx
  80044d:	89 55 10             	mov    %edx,0x10(%ebp)
  800450:	0f b6 00             	movzbl (%eax),%eax
  800453:	0f b6 d8             	movzbl %al,%ebx
  800456:	83 fb 25             	cmp    $0x25,%ebx
  800459:	75 d4                	jne    80042f <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80045b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80045f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800466:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80046d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800474:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 45 10             	mov    0x10(%ebp),%eax
  80047e:	8d 50 01             	lea    0x1(%eax),%edx
  800481:	89 55 10             	mov    %edx,0x10(%ebp)
  800484:	0f b6 00             	movzbl (%eax),%eax
  800487:	0f b6 d8             	movzbl %al,%ebx
  80048a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80048d:	83 f8 55             	cmp    $0x55,%eax
  800490:	0f 87 3d 03 00 00    	ja     8007d3 <vprintfmt+0x3ae>
  800496:	8b 04 85 4c 17 80 00 	mov    0x80174c(,%eax,4),%eax
  80049d:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80049f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004a3:	eb d6                	jmp    80047b <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004a9:	eb d0                	jmp    80047b <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ab:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b5:	89 d0                	mov    %edx,%eax
  8004b7:	c1 e0 02             	shl    $0x2,%eax
  8004ba:	01 d0                	add    %edx,%eax
  8004bc:	01 c0                	add    %eax,%eax
  8004be:	01 d8                	add    %ebx,%eax
  8004c0:	83 e8 30             	sub    $0x30,%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c9:	0f b6 00             	movzbl (%eax),%eax
  8004cc:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004cf:	83 fb 2f             	cmp    $0x2f,%ebx
  8004d2:	7e 0b                	jle    8004df <vprintfmt+0xba>
  8004d4:	83 fb 39             	cmp    $0x39,%ebx
  8004d7:	7f 06                	jg     8004df <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004dd:	eb d3                	jmp    8004b2 <vprintfmt+0x8d>
			goto process_precision;
  8004df:	eb 33                	jmp    800514 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004ef:	eb 23                	jmp    800514 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f5:	79 0c                	jns    800503 <vprintfmt+0xde>
				width = 0;
  8004f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004fe:	e9 78 ff ff ff       	jmp    80047b <vprintfmt+0x56>
  800503:	e9 73 ff ff ff       	jmp    80047b <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800508:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80050f:	e9 67 ff ff ff       	jmp    80047b <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800514:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800518:	79 12                	jns    80052c <vprintfmt+0x107>
				width = precision, precision = -1;
  80051a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800527:	e9 4f ff ff ff       	jmp    80047b <vprintfmt+0x56>
  80052c:	e9 4a ff ff ff       	jmp    80047b <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800531:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800535:	e9 41 ff ff ff       	jmp    80047b <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 50 04             	lea    0x4(%eax),%edx
  800540:	89 55 14             	mov    %edx,0x14(%ebp)
  800543:	8b 00                	mov    (%eax),%eax
  800545:	8b 55 0c             	mov    0xc(%ebp),%edx
  800548:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	8b 45 08             	mov    0x8(%ebp),%eax
  800552:	ff d0                	call   *%eax
			break;
  800554:	e9 a5 02 00 00       	jmp    8007fe <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800564:	85 db                	test   %ebx,%ebx
  800566:	79 02                	jns    80056a <vprintfmt+0x145>
				err = -err;
  800568:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056a:	83 fb 09             	cmp    $0x9,%ebx
  80056d:	7f 0b                	jg     80057a <vprintfmt+0x155>
  80056f:	8b 34 9d 00 17 80 00 	mov    0x801700(,%ebx,4),%esi
  800576:	85 f6                	test   %esi,%esi
  800578:	75 23                	jne    80059d <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80057a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80057e:	c7 44 24 08 39 17 80 	movl   $0x801739,0x8(%esp)
  800585:	00 
  800586:	8b 45 0c             	mov    0xc(%ebp),%eax
  800589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058d:	8b 45 08             	mov    0x8(%ebp),%eax
  800590:	89 04 24             	mov    %eax,(%esp)
  800593:	e8 73 02 00 00       	call   80080b <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800598:	e9 61 02 00 00       	jmp    8007fe <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80059d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005a1:	c7 44 24 08 42 17 80 	movl   $0x801742,0x8(%esp)
  8005a8:	00 
  8005a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b3:	89 04 24             	mov    %eax,(%esp)
  8005b6:	e8 50 02 00 00       	call   80080b <printfmt>
			break;
  8005bb:	e9 3e 02 00 00       	jmp    8007fe <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	85 f6                	test   %esi,%esi
  8005cd:	75 05                	jne    8005d4 <vprintfmt+0x1af>
				p = "(null)";
  8005cf:	be 45 17 80 00       	mov    $0x801745,%esi
			if (width > 0 && padc != '-')
  8005d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d8:	7e 37                	jle    800611 <vprintfmt+0x1ec>
  8005da:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005de:	74 31                	je     800611 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	89 34 24             	mov    %esi,(%esp)
  8005ea:	e8 39 03 00 00       	call   800928 <strnlen>
  8005ef:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005f2:	eb 17                	jmp    80060b <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005f4:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800607:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80060b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060f:	7f e3                	jg     8005f4 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800611:	eb 38                	jmp    80064b <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800613:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800617:	74 1f                	je     800638 <vprintfmt+0x213>
  800619:	83 fb 1f             	cmp    $0x1f,%ebx
  80061c:	7e 05                	jle    800623 <vprintfmt+0x1fe>
  80061e:	83 fb 7e             	cmp    $0x7e,%ebx
  800621:	7e 15                	jle    800638 <vprintfmt+0x213>
					putch('?', putdat);
  800623:	8b 45 0c             	mov    0xc(%ebp),%eax
  800626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  800634:	ff d0                	call   *%eax
  800636:	eb 0f                	jmp    800647 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	89 1c 24             	mov    %ebx,(%esp)
  800642:	8b 45 08             	mov    0x8(%ebp),%eax
  800645:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800647:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80064b:	89 f0                	mov    %esi,%eax
  80064d:	8d 70 01             	lea    0x1(%eax),%esi
  800650:	0f b6 00             	movzbl (%eax),%eax
  800653:	0f be d8             	movsbl %al,%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	74 10                	je     80066a <vprintfmt+0x245>
  80065a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065e:	78 b3                	js     800613 <vprintfmt+0x1ee>
  800660:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800664:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800668:	79 a9                	jns    800613 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066a:	eb 17                	jmp    800683 <vprintfmt+0x25e>
				putch(' ', putdat);
  80066c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800673:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800683:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800687:	7f e3                	jg     80066c <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800689:	e9 70 01 00 00       	jmp    8007fe <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800691:	89 44 24 04          	mov    %eax,0x4(%esp)
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	89 04 24             	mov    %eax,(%esp)
  80069b:	e8 3e fd ff ff       	call   8003de <getint>
  8006a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006a3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	79 26                	jns    8006d6 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	ff d0                	call   *%eax
				num = -(long long) num;
  8006c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c9:	f7 d8                	neg    %eax
  8006cb:	83 d2 00             	adc    $0x0,%edx
  8006ce:	f7 da                	neg    %edx
  8006d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006d6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006dd:	e9 a8 00 00 00       	jmp    80078a <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	e8 9b fc ff ff       	call   80038f <getuint>
  8006f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006fa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800701:	e9 84 00 00 00       	jmp    80078a <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800706:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 77 fc ff ff       	call   80038f <getuint>
  800718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80071e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800725:	eb 63                	jmp    80078a <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800727:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	ff d0                	call   *%eax
			putch('x', putdat);
  80073a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800741:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8d 50 04             	lea    0x4(%eax),%edx
  800753:	89 55 14             	mov    %edx,0x14(%ebp)
  800756:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800758:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80075b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800762:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800769:	eb 1f                	jmp    80078a <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80076e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800772:	8d 45 14             	lea    0x14(%ebp),%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 12 fc ff ff       	call   80038f <getuint>
  80077d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800780:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800783:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80078e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800791:	89 54 24 18          	mov    %edx,0x18(%esp)
  800795:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800798:	89 54 24 14          	mov    %edx,0x14(%esp)
  80079c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	e8 f1 fa ff ff       	call   8002b1 <printnum>
			break;
  8007c0:	eb 3c                	jmp    8007fe <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c9:	89 1c 24             	mov    %ebx,(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	ff d0                	call   *%eax
			break;
  8007d1:	eb 2b                	jmp    8007fe <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007da:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007ea:	eb 04                	jmp    8007f0 <vprintfmt+0x3cb>
  8007ec:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f3:	83 e8 01             	sub    $0x1,%eax
  8007f6:	0f b6 00             	movzbl (%eax),%eax
  8007f9:	3c 25                	cmp    $0x25,%al
  8007fb:	75 ef                	jne    8007ec <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8007fd:	90                   	nop
		}
	}
  8007fe:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ff:	e9 43 fc ff ff       	jmp    800447 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800804:	83 c4 40             	add    $0x40,%esp
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800811:	8d 45 14             	lea    0x14(%ebp),%eax
  800814:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800817:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081e:	8b 45 10             	mov    0x10(%ebp),%eax
  800821:	89 44 24 08          	mov    %eax,0x8(%esp)
  800825:	8b 45 0c             	mov    0xc(%ebp),%eax
  800828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 ee fb ff ff       	call   800425 <vprintfmt>
	va_end(ap);
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083f:	8b 40 08             	mov    0x8(%eax),%eax
  800842:	8d 50 01             	lea    0x1(%eax),%edx
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8b 45 0c             	mov    0xc(%ebp),%eax
  800853:	8b 40 04             	mov    0x4(%eax),%eax
  800856:	39 c2                	cmp    %eax,%edx
  800858:	73 12                	jae    80086c <sprintputch+0x33>
		*b->buf++ = ch;
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	8d 48 01             	lea    0x1(%eax),%ecx
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	89 0a                	mov    %ecx,(%edx)
  800867:	8b 55 08             	mov    0x8(%ebp),%edx
  80086a:	88 10                	mov    %dl,(%eax)
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	01 d0                	add    %edx,%eax
  800885:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800893:	74 06                	je     80089b <vsnprintf+0x2d>
  800895:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800899:	7f 07                	jg     8008a2 <vsnprintf+0x34>
		return -E_INVAL;
  80089b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a0:	eb 2a                	jmp    8008cc <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	c7 04 24 39 08 80 00 	movl   $0x800839,(%esp)
  8008be:	e8 62 fb ff ff       	call   800425 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    

008008ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 74 ff ff ff       	call   80086e <vsnprintf>
  8008fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800908:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80090f:	eb 08                	jmp    800919 <strlen+0x17>
		n++;
  800911:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800915:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	0f b6 00             	movzbl (%eax),%eax
  80091f:	84 c0                	test   %al,%al
  800921:	75 ee                	jne    800911 <strlen+0xf>
		n++;
	return n;
  800923:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800935:	eb 0c                	jmp    800943 <strnlen+0x1b>
		n++;
  800937:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80093f:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800943:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800947:	74 0a                	je     800953 <strnlen+0x2b>
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	0f b6 00             	movzbl (%eax),%eax
  80094f:	84 c0                	test   %al,%al
  800951:	75 e4                	jne    800937 <strnlen+0xf>
		n++;
	return n;
  800953:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800964:	90                   	nop
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8d 50 01             	lea    0x1(%eax),%edx
  80096b:	89 55 08             	mov    %edx,0x8(%ebp)
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	8d 4a 01             	lea    0x1(%edx),%ecx
  800974:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800977:	0f b6 12             	movzbl (%edx),%edx
  80097a:	88 10                	mov    %dl,(%eax)
  80097c:	0f b6 00             	movzbl (%eax),%eax
  80097f:	84 c0                	test   %al,%al
  800981:	75 e2                	jne    800965 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800983:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	89 04 24             	mov    %eax,(%esp)
  800994:	e8 69 ff ff ff       	call   800902 <strlen>
  800999:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80099c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	01 c2                	add    %eax,%edx
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ab:	89 14 24             	mov    %edx,(%esp)
  8009ae:	e8 a5 ff ff ff       	call   800958 <strcpy>
	return dst;
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009cb:	eb 23                	jmp    8009f0 <strncpy+0x38>
		*dst++ = *src;
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8d 50 01             	lea    0x1(%eax),%edx
  8009d3:	89 55 08             	mov    %edx,0x8(%ebp)
  8009d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d9:	0f b6 12             	movzbl (%edx),%edx
  8009dc:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	0f b6 00             	movzbl (%eax),%eax
  8009e4:	84 c0                	test   %al,%al
  8009e6:	74 04                	je     8009ec <strncpy+0x34>
			src++;
  8009e8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ec:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009f3:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009f6:	72 d5                	jb     8009cd <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a0d:	74 33                	je     800a42 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a0f:	eb 17                	jmp    800a28 <strlcpy+0x2b>
			*dst++ = *src++;
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8d 50 01             	lea    0x1(%eax),%edx
  800a17:	89 55 08             	mov    %edx,0x8(%ebp)
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a20:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a23:	0f b6 12             	movzbl (%edx),%edx
  800a26:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a28:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a30:	74 0a                	je     800a3c <strlcpy+0x3f>
  800a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	84 c0                	test   %al,%al
  800a3a:	75 d5                	jne    800a11 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a48:	29 c2                	sub    %eax,%edx
  800a4a:	89 d0                	mov    %edx,%eax
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a51:	eb 08                	jmp    800a5b <strcmp+0xd>
		p++, q++;
  800a53:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a57:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	0f b6 00             	movzbl (%eax),%eax
  800a61:	84 c0                	test   %al,%al
  800a63:	74 10                	je     800a75 <strcmp+0x27>
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	0f b6 10             	movzbl (%eax),%edx
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	0f b6 00             	movzbl (%eax),%eax
  800a71:	38 c2                	cmp    %al,%dl
  800a73:	74 de                	je     800a53 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 d0             	movzbl %al,%edx
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	0f b6 00             	movzbl (%eax),%eax
  800a84:	0f b6 c0             	movzbl %al,%eax
  800a87:	29 c2                	sub    %eax,%edx
  800a89:	89 d0                	mov    %edx,%eax
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a90:	eb 0c                	jmp    800a9e <strncmp+0x11>
		n--, p++, q++;
  800a92:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a96:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a9a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa2:	74 1a                	je     800abe <strncmp+0x31>
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	0f b6 00             	movzbl (%eax),%eax
  800aaa:	84 c0                	test   %al,%al
  800aac:	74 10                	je     800abe <strncmp+0x31>
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 10             	movzbl (%eax),%edx
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	0f b6 00             	movzbl (%eax),%eax
  800aba:	38 c2                	cmp    %al,%dl
  800abc:	74 d4                	je     800a92 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800abe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ac2:	75 07                	jne    800acb <strncmp+0x3e>
		return 0;
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	eb 16                	jmp    800ae1 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	0f b6 00             	movzbl (%eax),%eax
  800ad1:	0f b6 d0             	movzbl %al,%edx
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	0f b6 00             	movzbl (%eax),%eax
  800ada:	0f b6 c0             	movzbl %al,%eax
  800add:	29 c2                	sub    %eax,%edx
  800adf:	89 d0                	mov    %edx,%eax
}
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 04             	sub    $0x4,%esp
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aef:	eb 14                	jmp    800b05 <strchr+0x22>
		if (*s == c)
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	0f b6 00             	movzbl (%eax),%eax
  800af7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800afa:	75 05                	jne    800b01 <strchr+0x1e>
			return (char *) s;
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	eb 13                	jmp    800b14 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b01:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	0f b6 00             	movzbl (%eax),%eax
  800b0b:	84 c0                	test   %al,%al
  800b0d:	75 e2                	jne    800af1 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	83 ec 04             	sub    $0x4,%esp
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b22:	eb 11                	jmp    800b35 <strfind+0x1f>
		if (*s == c)
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	0f b6 00             	movzbl (%eax),%eax
  800b2a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b2d:	75 02                	jne    800b31 <strfind+0x1b>
			break;
  800b2f:	eb 0e                	jmp    800b3f <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b31:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	0f b6 00             	movzbl (%eax),%eax
  800b3b:	84 c0                	test   %al,%al
  800b3d:	75 e5                	jne    800b24 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b4c:	75 05                	jne    800b53 <memset+0xf>
		return v;
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	eb 5c                	jmp    800baf <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	83 e0 03             	and    $0x3,%eax
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	75 41                	jne    800b9e <memset+0x5a>
  800b5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b60:	83 e0 03             	and    $0x3,%eax
  800b63:	85 c0                	test   %eax,%eax
  800b65:	75 37                	jne    800b9e <memset+0x5a>
		c &= 0xFF;
  800b67:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b71:	c1 e0 18             	shl    $0x18,%eax
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b79:	c1 e0 10             	shl    $0x10,%eax
  800b7c:	09 c2                	or     %eax,%edx
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	c1 e0 08             	shl    $0x8,%eax
  800b84:	09 d0                	or     %edx,%eax
  800b86:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8c:	c1 e8 02             	shr    $0x2,%eax
  800b8f:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	fc                   	cld    
  800b9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b9c:	eb 0e                	jmp    800bac <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba7:	89 d7                	mov    %edx,%edi
  800ba9:	fc                   	cld    
  800baa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bca:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bcd:	73 6d                	jae    800c3c <memmove+0x8a>
  800bcf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bd5:	01 d0                	add    %edx,%eax
  800bd7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bda:	76 60                	jbe    800c3c <memmove+0x8a>
		s += n;
  800bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdf:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800be2:	8b 45 10             	mov    0x10(%ebp),%eax
  800be5:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800beb:	83 e0 03             	and    $0x3,%eax
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	75 2f                	jne    800c21 <memmove+0x6f>
  800bf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf5:	83 e0 03             	and    $0x3,%eax
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	75 25                	jne    800c21 <memmove+0x6f>
  800bfc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bff:	83 e0 03             	and    $0x3,%eax
  800c02:	85 c0                	test   %eax,%eax
  800c04:	75 1b                	jne    800c21 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c09:	83 e8 04             	sub    $0x4,%eax
  800c0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c0f:	83 ea 04             	sub    $0x4,%edx
  800c12:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c15:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c18:	89 c7                	mov    %eax,%edi
  800c1a:	89 d6                	mov    %edx,%esi
  800c1c:	fd                   	std    
  800c1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1f:	eb 18                	jmp    800c39 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c24:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2a:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 de                	mov    %ebx,%esi
  800c34:	89 c1                	mov    %eax,%ecx
  800c36:	fd                   	std    
  800c37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c39:	fc                   	cld    
  800c3a:	eb 45                	jmp    800c81 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3f:	83 e0 03             	and    $0x3,%eax
  800c42:	85 c0                	test   %eax,%eax
  800c44:	75 2b                	jne    800c71 <memmove+0xbf>
  800c46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c49:	83 e0 03             	and    $0x3,%eax
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	75 21                	jne    800c71 <memmove+0xbf>
  800c50:	8b 45 10             	mov    0x10(%ebp),%eax
  800c53:	83 e0 03             	and    $0x3,%eax
  800c56:	85 c0                	test   %eax,%eax
  800c58:	75 17                	jne    800c71 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5d:	c1 e8 02             	shr    $0x2,%eax
  800c60:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c65:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c68:	89 c7                	mov    %eax,%edi
  800c6a:	89 d6                	mov    %edx,%esi
  800c6c:	fc                   	cld    
  800c6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6f:	eb 10                	jmp    800c81 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c77:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c7a:	89 c7                	mov    %eax,%edi
  800c7c:	89 d6                	mov    %edx,%esi
  800c7e:	fc                   	cld    
  800c7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c92:	8b 45 10             	mov    0x10(%ebp),%eax
  800c95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	89 04 24             	mov    %eax,(%esp)
  800ca6:	e8 07 ff ff ff       	call   800bb2 <memmove>
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbc:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cbf:	eb 30                	jmp    800cf1 <memcmp+0x44>
		if (*s1 != *s2)
  800cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cc4:	0f b6 10             	movzbl (%eax),%edx
  800cc7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cca:	0f b6 00             	movzbl (%eax),%eax
  800ccd:	38 c2                	cmp    %al,%dl
  800ccf:	74 18                	je     800ce9 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cd4:	0f b6 00             	movzbl (%eax),%eax
  800cd7:	0f b6 d0             	movzbl %al,%edx
  800cda:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cdd:	0f b6 00             	movzbl (%eax),%eax
  800ce0:	0f b6 c0             	movzbl %al,%eax
  800ce3:	29 c2                	sub    %eax,%edx
  800ce5:	89 d0                	mov    %edx,%eax
  800ce7:	eb 1a                	jmp    800d03 <memcmp+0x56>
		s1++, s2++;
  800ce9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ced:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cf7:	89 55 10             	mov    %edx,0x10(%ebp)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	75 c3                	jne    800cc1 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	01 d0                	add    %edx,%eax
  800d13:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d16:	eb 13                	jmp    800d2b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	0f b6 10             	movzbl (%eax),%edx
  800d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d21:	38 c2                	cmp    %al,%dl
  800d23:	75 02                	jne    800d27 <memfind+0x22>
			break;
  800d25:	eb 0c                	jmp    800d33 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d31:	72 e5                	jb     800d18 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d45:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4c:	eb 04                	jmp    800d52 <strtol+0x1a>
		s++;
  800d4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	0f b6 00             	movzbl (%eax),%eax
  800d58:	3c 20                	cmp    $0x20,%al
  800d5a:	74 f2                	je     800d4e <strtol+0x16>
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	0f b6 00             	movzbl (%eax),%eax
  800d62:	3c 09                	cmp    $0x9,%al
  800d64:	74 e8                	je     800d4e <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	3c 2b                	cmp    $0x2b,%al
  800d6e:	75 06                	jne    800d76 <strtol+0x3e>
		s++;
  800d70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d74:	eb 15                	jmp    800d8b <strtol+0x53>
	else if (*s == '-')
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	0f b6 00             	movzbl (%eax),%eax
  800d7c:	3c 2d                	cmp    $0x2d,%al
  800d7e:	75 0b                	jne    800d8b <strtol+0x53>
		s++, neg = 1;
  800d80:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d84:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d8f:	74 06                	je     800d97 <strtol+0x5f>
  800d91:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d95:	75 24                	jne    800dbb <strtol+0x83>
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	0f b6 00             	movzbl (%eax),%eax
  800d9d:	3c 30                	cmp    $0x30,%al
  800d9f:	75 1a                	jne    800dbb <strtol+0x83>
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	83 c0 01             	add    $0x1,%eax
  800da7:	0f b6 00             	movzbl (%eax),%eax
  800daa:	3c 78                	cmp    $0x78,%al
  800dac:	75 0d                	jne    800dbb <strtol+0x83>
		s += 2, base = 16;
  800dae:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800db2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800db9:	eb 2a                	jmp    800de5 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800dbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dbf:	75 17                	jne    800dd8 <strtol+0xa0>
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	0f b6 00             	movzbl (%eax),%eax
  800dc7:	3c 30                	cmp    $0x30,%al
  800dc9:	75 0d                	jne    800dd8 <strtol+0xa0>
		s++, base = 8;
  800dcb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dcf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dd6:	eb 0d                	jmp    800de5 <strtol+0xad>
	else if (base == 0)
  800dd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ddc:	75 07                	jne    800de5 <strtol+0xad>
		base = 10;
  800dde:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	0f b6 00             	movzbl (%eax),%eax
  800deb:	3c 2f                	cmp    $0x2f,%al
  800ded:	7e 1b                	jle    800e0a <strtol+0xd2>
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	0f b6 00             	movzbl (%eax),%eax
  800df5:	3c 39                	cmp    $0x39,%al
  800df7:	7f 11                	jg     800e0a <strtol+0xd2>
			dig = *s - '0';
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	0f be c0             	movsbl %al,%eax
  800e02:	83 e8 30             	sub    $0x30,%eax
  800e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e08:	eb 48                	jmp    800e52 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	0f b6 00             	movzbl (%eax),%eax
  800e10:	3c 60                	cmp    $0x60,%al
  800e12:	7e 1b                	jle    800e2f <strtol+0xf7>
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	0f b6 00             	movzbl (%eax),%eax
  800e1a:	3c 7a                	cmp    $0x7a,%al
  800e1c:	7f 11                	jg     800e2f <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	0f b6 00             	movzbl (%eax),%eax
  800e24:	0f be c0             	movsbl %al,%eax
  800e27:	83 e8 57             	sub    $0x57,%eax
  800e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e2d:	eb 23                	jmp    800e52 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	0f b6 00             	movzbl (%eax),%eax
  800e35:	3c 40                	cmp    $0x40,%al
  800e37:	7e 3d                	jle    800e76 <strtol+0x13e>
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	0f b6 00             	movzbl (%eax),%eax
  800e3f:	3c 5a                	cmp    $0x5a,%al
  800e41:	7f 33                	jg     800e76 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	0f b6 00             	movzbl (%eax),%eax
  800e49:	0f be c0             	movsbl %al,%eax
  800e4c:	83 e8 37             	sub    $0x37,%eax
  800e4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e55:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e58:	7c 02                	jl     800e5c <strtol+0x124>
			break;
  800e5a:	eb 1a                	jmp    800e76 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e5c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e60:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6c:	01 d0                	add    %edx,%eax
  800e6e:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e71:	e9 6f ff ff ff       	jmp    800de5 <strtol+0xad>

	if (endptr)
  800e76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e7a:	74 08                	je     800e84 <strtol+0x14c>
		*endptr = (char *) s;
  800e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e82:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e84:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e88:	74 07                	je     800e91 <strtol+0x159>
  800e8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e8d:	f7 d8                	neg    %eax
  800e8f:	eb 03                	jmp    800e94 <strtol+0x15c>
  800e91:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ea5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ea8:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800eab:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800eae:	8b 75 20             	mov    0x20(%ebp),%esi
  800eb1:	cd 30                	int    $0x30
  800eb3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eba:	74 30                	je     800eec <syscall+0x56>
  800ebc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ec0:	7e 2a                	jle    800eec <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ed0:	c7 44 24 08 a4 18 80 	movl   $0x8018a4,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edf:	00 
  800ee0:	c7 04 24 c1 18 80 00 	movl   $0x8018c1,(%esp)
  800ee7:	e8 84 f2 ff ff       	call   800170 <_panic>

	return ret;
  800eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800eef:	83 c4 3c             	add    $0x3c,%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f07:	00 
  800f08:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f0f:	00 
  800f10:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f17:	00 
  800f18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f23:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f2a:	00 
  800f2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f32:	e8 5f ff ff ff       	call   800e96 <syscall>
}
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f3f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f46:	00 
  800f47:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f56:	00 
  800f57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f66:	00 
  800f67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6e:	00 
  800f6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f76:	e8 1b ff ff ff       	call   800e96 <syscall>
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f95:	00 
  800f96:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fa5:	00 
  800fa6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800faa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fb1:	00 
  800fb2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fb9:	e8 d8 fe ff ff       	call   800e96 <syscall>
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fc6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fcd:	00 
  800fce:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fdd:	00 
  800fde:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe5:	00 
  800fe6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fed:	00 
  800fee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff5:	00 
  800ff6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ffd:	e8 94 fe ff ff       	call   800e96 <syscall>
}
  801002:	c9                   	leave  
  801003:	c3                   	ret    

00801004 <sys_yield>:

void
sys_yield(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80100a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801011:	00 
  801012:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801019:	00 
  80101a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801021:	00 
  801022:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801029:	00 
  80102a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801031:	00 
  801032:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801039:	00 
  80103a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801041:	e8 50 fe ff ff       	call   800e96 <syscall>
}
  801046:	c9                   	leave  
  801047:	c3                   	ret    

00801048 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80104e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801051:	8b 55 0c             	mov    0xc(%ebp),%edx
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80105e:	00 
  80105f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801066:	00 
  801067:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80106b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80106f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801073:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801082:	e8 0f fe ff ff       	call   800e96 <syscall>
}
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801091:	8b 75 18             	mov    0x18(%ebp),%esi
  801094:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801097:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80109a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a0:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010a4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010a8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010bb:	00 
  8010bc:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010c3:	e8 ce fd ff ff       	call   800e96 <syscall>
}
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ea:	00 
  8010eb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010f2:	00 
  8010f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801102:	00 
  801103:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80110a:	e8 87 fd ff ff       	call   800e96 <syscall>
}
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801117:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801124:	00 
  801125:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80112c:	00 
  80112d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801134:	00 
  801135:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801139:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80114c:	e8 45 fd ff ff       	call   800e96 <syscall>
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801159:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801166:	00 
  801167:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80116e:	00 
  80116f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801176:	00 
  801177:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80117b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801186:	00 
  801187:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80118e:	e8 03 fd ff ff       	call   800e96 <syscall>
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80119b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80119e:	8b 55 10             	mov    0x10(%ebp),%edx
  8011a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011ab:	00 
  8011ac:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011c6:	00 
  8011c7:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011ce:	e8 c3 fc ff ff       	call   800e96 <syscall>
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011e5:	00 
  8011e6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011ed:	00 
  8011ee:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011fd:	00 
  8011fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801202:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801209:	00 
  80120a:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801211:	e8 80 fc ff ff       	call   800e96 <syscall>
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <sys_exec>:

void sys_exec(char* buf){
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801228:	00 
  801229:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801230:	00 
  801231:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801238:	00 
  801239:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801240:	00 
  801241:	89 44 24 08          	mov    %eax,0x8(%esp)
  801245:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80124c:	00 
  80124d:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801254:	e8 3d fc ff ff       	call   800e96 <syscall>
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801261:	a1 08 20 80 00       	mov    0x802008,%eax
  801266:	85 c0                	test   %eax,%eax
  801268:	75 5d                	jne    8012c7 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80126a:	a1 04 20 80 00       	mov    0x802004,%eax
  80126f:	8b 40 48             	mov    0x48(%eax),%eax
  801272:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801279:	00 
  80127a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801281:	ee 
  801282:	89 04 24             	mov    %eax,(%esp)
  801285:	e8 be fd ff ff       	call   801048 <sys_page_alloc>
  80128a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80128d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801291:	79 1c                	jns    8012af <set_pgfault_handler+0x54>
  801293:	c7 44 24 08 d0 18 80 	movl   $0x8018d0,0x8(%esp)
  80129a:	00 
  80129b:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8012a2:	00 
  8012a3:	c7 04 24 fc 18 80 00 	movl   $0x8018fc,(%esp)
  8012aa:	e8 c1 ee ff ff       	call   800170 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8012af:	a1 04 20 80 00       	mov    0x802004,%eax
  8012b4:	8b 40 48             	mov    0x48(%eax),%eax
  8012b7:	c7 44 24 04 d1 12 80 	movl   $0x8012d1,0x4(%esp)
  8012be:	00 
  8012bf:	89 04 24             	mov    %eax,(%esp)
  8012c2:	e8 8c fe ff ff       	call   801153 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ca:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012d1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012d2:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8012d7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012d9:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8012dc:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8012e0:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8012e2:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8012e6:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8012e7:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8012ea:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8012ec:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8012ed:	58                   	pop    %eax
	popal 						// pop all the registers
  8012ee:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8012ef:	83 c4 04             	add    $0x4,%esp
	popfl
  8012f2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8012f3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8012f4:	c3                   	ret    
  8012f5:	66 90                	xchg   %ax,%ax
  8012f7:	66 90                	xchg   %ax,%ax
  8012f9:	66 90                	xchg   %ax,%ax
  8012fb:	66 90                	xchg   %ax,%ax
  8012fd:	66 90                	xchg   %ax,%ax
  8012ff:	90                   	nop

00801300 <__udivdi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	8b 44 24 28          	mov    0x28(%esp),%eax
  80130a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80130e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801312:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801316:	85 c0                	test   %eax,%eax
  801318:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80131c:	89 ea                	mov    %ebp,%edx
  80131e:	89 0c 24             	mov    %ecx,(%esp)
  801321:	75 2d                	jne    801350 <__udivdi3+0x50>
  801323:	39 e9                	cmp    %ebp,%ecx
  801325:	77 61                	ja     801388 <__udivdi3+0x88>
  801327:	85 c9                	test   %ecx,%ecx
  801329:	89 ce                	mov    %ecx,%esi
  80132b:	75 0b                	jne    801338 <__udivdi3+0x38>
  80132d:	b8 01 00 00 00       	mov    $0x1,%eax
  801332:	31 d2                	xor    %edx,%edx
  801334:	f7 f1                	div    %ecx
  801336:	89 c6                	mov    %eax,%esi
  801338:	31 d2                	xor    %edx,%edx
  80133a:	89 e8                	mov    %ebp,%eax
  80133c:	f7 f6                	div    %esi
  80133e:	89 c5                	mov    %eax,%ebp
  801340:	89 f8                	mov    %edi,%eax
  801342:	f7 f6                	div    %esi
  801344:	89 ea                	mov    %ebp,%edx
  801346:	83 c4 0c             	add    $0xc,%esp
  801349:	5e                   	pop    %esi
  80134a:	5f                   	pop    %edi
  80134b:	5d                   	pop    %ebp
  80134c:	c3                   	ret    
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	39 e8                	cmp    %ebp,%eax
  801352:	77 24                	ja     801378 <__udivdi3+0x78>
  801354:	0f bd e8             	bsr    %eax,%ebp
  801357:	83 f5 1f             	xor    $0x1f,%ebp
  80135a:	75 3c                	jne    801398 <__udivdi3+0x98>
  80135c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801360:	39 34 24             	cmp    %esi,(%esp)
  801363:	0f 86 9f 00 00 00    	jbe    801408 <__udivdi3+0x108>
  801369:	39 d0                	cmp    %edx,%eax
  80136b:	0f 82 97 00 00 00    	jb     801408 <__udivdi3+0x108>
  801371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801378:	31 d2                	xor    %edx,%edx
  80137a:	31 c0                	xor    %eax,%eax
  80137c:	83 c4 0c             	add    $0xc,%esp
  80137f:	5e                   	pop    %esi
  801380:	5f                   	pop    %edi
  801381:	5d                   	pop    %ebp
  801382:	c3                   	ret    
  801383:	90                   	nop
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	89 f8                	mov    %edi,%eax
  80138a:	f7 f1                	div    %ecx
  80138c:	31 d2                	xor    %edx,%edx
  80138e:	83 c4 0c             	add    $0xc,%esp
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	89 e9                	mov    %ebp,%ecx
  80139a:	8b 3c 24             	mov    (%esp),%edi
  80139d:	d3 e0                	shl    %cl,%eax
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013a6:	29 e8                	sub    %ebp,%eax
  8013a8:	89 c1                	mov    %eax,%ecx
  8013aa:	d3 ef                	shr    %cl,%edi
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013b2:	8b 3c 24             	mov    (%esp),%edi
  8013b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013b9:	89 d6                	mov    %edx,%esi
  8013bb:	d3 e7                	shl    %cl,%edi
  8013bd:	89 c1                	mov    %eax,%ecx
  8013bf:	89 3c 24             	mov    %edi,(%esp)
  8013c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c6:	d3 ee                	shr    %cl,%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	d3 e2                	shl    %cl,%edx
  8013cc:	89 c1                	mov    %eax,%ecx
  8013ce:	d3 ef                	shr    %cl,%edi
  8013d0:	09 d7                	or     %edx,%edi
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	89 f8                	mov    %edi,%eax
  8013d6:	f7 74 24 08          	divl   0x8(%esp)
  8013da:	89 d6                	mov    %edx,%esi
  8013dc:	89 c7                	mov    %eax,%edi
  8013de:	f7 24 24             	mull   (%esp)
  8013e1:	39 d6                	cmp    %edx,%esi
  8013e3:	89 14 24             	mov    %edx,(%esp)
  8013e6:	72 30                	jb     801418 <__udivdi3+0x118>
  8013e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ec:	89 e9                	mov    %ebp,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	39 c2                	cmp    %eax,%edx
  8013f2:	73 05                	jae    8013f9 <__udivdi3+0xf9>
  8013f4:	3b 34 24             	cmp    (%esp),%esi
  8013f7:	74 1f                	je     801418 <__udivdi3+0x118>
  8013f9:	89 f8                	mov    %edi,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	e9 7a ff ff ff       	jmp    80137c <__udivdi3+0x7c>
  801402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	b8 01 00 00 00       	mov    $0x1,%eax
  80140f:	e9 68 ff ff ff       	jmp    80137c <__udivdi3+0x7c>
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	8d 47 ff             	lea    -0x1(%edi),%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	83 c4 0c             	add    $0xc,%esp
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    
  801424:	66 90                	xchg   %ax,%ax
  801426:	66 90                	xchg   %ax,%ax
  801428:	66 90                	xchg   %ax,%ax
  80142a:	66 90                	xchg   %ax,%ax
  80142c:	66 90                	xchg   %ax,%ax
  80142e:	66 90                	xchg   %ax,%ax

00801430 <__umoddi3>:
  801430:	55                   	push   %ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	83 ec 14             	sub    $0x14,%esp
  801436:	8b 44 24 28          	mov    0x28(%esp),%eax
  80143a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80143e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801442:	89 c7                	mov    %eax,%edi
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	8b 44 24 30          	mov    0x30(%esp),%eax
  80144c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801450:	89 34 24             	mov    %esi,(%esp)
  801453:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801457:	85 c0                	test   %eax,%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80145f:	75 17                	jne    801478 <__umoddi3+0x48>
  801461:	39 fe                	cmp    %edi,%esi
  801463:	76 4b                	jbe    8014b0 <__umoddi3+0x80>
  801465:	89 c8                	mov    %ecx,%eax
  801467:	89 fa                	mov    %edi,%edx
  801469:	f7 f6                	div    %esi
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	31 d2                	xor    %edx,%edx
  80146f:	83 c4 14             	add    $0x14,%esp
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    
  801476:	66 90                	xchg   %ax,%ax
  801478:	39 f8                	cmp    %edi,%eax
  80147a:	77 54                	ja     8014d0 <__umoddi3+0xa0>
  80147c:	0f bd e8             	bsr    %eax,%ebp
  80147f:	83 f5 1f             	xor    $0x1f,%ebp
  801482:	75 5c                	jne    8014e0 <__umoddi3+0xb0>
  801484:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801488:	39 3c 24             	cmp    %edi,(%esp)
  80148b:	0f 87 e7 00 00 00    	ja     801578 <__umoddi3+0x148>
  801491:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801495:	29 f1                	sub    %esi,%ecx
  801497:	19 c7                	sbb    %eax,%edi
  801499:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014a9:	83 c4 14             	add    $0x14,%esp
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    
  8014b0:	85 f6                	test   %esi,%esi
  8014b2:	89 f5                	mov    %esi,%ebp
  8014b4:	75 0b                	jne    8014c1 <__umoddi3+0x91>
  8014b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	f7 f6                	div    %esi
  8014bf:	89 c5                	mov    %eax,%ebp
  8014c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014c5:	31 d2                	xor    %edx,%edx
  8014c7:	f7 f5                	div    %ebp
  8014c9:	89 c8                	mov    %ecx,%eax
  8014cb:	f7 f5                	div    %ebp
  8014cd:	eb 9c                	jmp    80146b <__umoddi3+0x3b>
  8014cf:	90                   	nop
  8014d0:	89 c8                	mov    %ecx,%eax
  8014d2:	89 fa                	mov    %edi,%edx
  8014d4:	83 c4 14             	add    $0x14,%esp
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    
  8014db:	90                   	nop
  8014dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	8b 04 24             	mov    (%esp),%eax
  8014e3:	be 20 00 00 00       	mov    $0x20,%esi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	29 ee                	sub    %ebp,%esi
  8014ec:	d3 e2                	shl    %cl,%edx
  8014ee:	89 f1                	mov    %esi,%ecx
  8014f0:	d3 e8                	shr    %cl,%eax
  8014f2:	89 e9                	mov    %ebp,%ecx
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	8b 04 24             	mov    (%esp),%eax
  8014fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014ff:	89 fa                	mov    %edi,%edx
  801501:	d3 e0                	shl    %cl,%eax
  801503:	89 f1                	mov    %esi,%ecx
  801505:	89 44 24 08          	mov    %eax,0x8(%esp)
  801509:	8b 44 24 10          	mov    0x10(%esp),%eax
  80150d:	d3 ea                	shr    %cl,%edx
  80150f:	89 e9                	mov    %ebp,%ecx
  801511:	d3 e7                	shl    %cl,%edi
  801513:	89 f1                	mov    %esi,%ecx
  801515:	d3 e8                	shr    %cl,%eax
  801517:	89 e9                	mov    %ebp,%ecx
  801519:	09 f8                	or     %edi,%eax
  80151b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80151f:	f7 74 24 04          	divl   0x4(%esp)
  801523:	d3 e7                	shl    %cl,%edi
  801525:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801529:	89 d7                	mov    %edx,%edi
  80152b:	f7 64 24 08          	mull   0x8(%esp)
  80152f:	39 d7                	cmp    %edx,%edi
  801531:	89 c1                	mov    %eax,%ecx
  801533:	89 14 24             	mov    %edx,(%esp)
  801536:	72 2c                	jb     801564 <__umoddi3+0x134>
  801538:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80153c:	72 22                	jb     801560 <__umoddi3+0x130>
  80153e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801542:	29 c8                	sub    %ecx,%eax
  801544:	19 d7                	sbb    %edx,%edi
  801546:	89 e9                	mov    %ebp,%ecx
  801548:	89 fa                	mov    %edi,%edx
  80154a:	d3 e8                	shr    %cl,%eax
  80154c:	89 f1                	mov    %esi,%ecx
  80154e:	d3 e2                	shl    %cl,%edx
  801550:	89 e9                	mov    %ebp,%ecx
  801552:	d3 ef                	shr    %cl,%edi
  801554:	09 d0                	or     %edx,%eax
  801556:	89 fa                	mov    %edi,%edx
  801558:	83 c4 14             	add    $0x14,%esp
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    
  80155f:	90                   	nop
  801560:	39 d7                	cmp    %edx,%edi
  801562:	75 da                	jne    80153e <__umoddi3+0x10e>
  801564:	8b 14 24             	mov    (%esp),%edx
  801567:	89 c1                	mov    %eax,%ecx
  801569:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80156d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801571:	eb cb                	jmp    80153e <__umoddi3+0x10e>
  801573:	90                   	nop
  801574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801578:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80157c:	0f 82 0f ff ff ff    	jb     801491 <__umoddi3+0x61>
  801582:	e9 1a ff ff ff       	jmp    8014a1 <__umoddi3+0x71>
