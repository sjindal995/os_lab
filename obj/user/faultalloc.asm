
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
  800048:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  80004f:	e8 27 02 00 00       	call   80027b <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80005a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800069:	00 
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800075:	e8 be 0f 00 00       	call   801038 <sys_page_alloc>
  80007a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80007d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800081:	79 2a                	jns    8000ad <handler+0x7a>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800083:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800091:	c7 44 24 08 cc 15 80 	movl   $0x8015cc,0x8(%esp)
  800098:	00 
  800099:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000a0:	00 
  8000a1:	c7 04 24 f7 15 80 00 	movl   $0x8015f7,(%esp)
  8000a8:	e8 b3 00 00 00       	call   800160 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b4:	c7 44 24 08 0c 16 80 	movl   $0x80160c,0x8(%esp)
  8000bb:	00 
  8000bc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000c3:	00 
  8000c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 ef 07 00 00       	call   8008be <snprintf>
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
  8000de:	e8 ac 11 00 00       	call   80128f <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000e3:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000ea:	de 
  8000eb:	c7 04 24 2d 16 80 00 	movl   $0x80162d,(%esp)
  8000f2:	e8 84 01 00 00       	call   80027b <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000f7:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000fe:	ca 
  8000ff:	c7 04 24 2d 16 80 00 	movl   $0x80162d,(%esp)
  800106:	e8 70 01 00 00       	call   80027b <cprintf>
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
  800113:	e8 98 0e 00 00       	call   800fb0 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	c1 e0 02             	shl    $0x2,%eax
  800120:	89 c2                	mov    %eax,%edx
  800122:	c1 e2 05             	shl    $0x5,%edx
  800125:	29 c2                	sub    %eax,%edx
  800127:	89 d0                	mov    %edx,%eax
  800129:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 8c ff ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800145:	e8 02 00 00 00       	call   80014c <exit>
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 0f 0e 00 00       	call   800f6d <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800167:	8d 45 14             	lea    0x14(%ebp),%eax
  80016a:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800173:	e8 38 0e 00 00       	call   800fb0 <sys_getenvid>
  800178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017f:	8b 55 08             	mov    0x8(%ebp),%edx
  800182:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800186:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018e:	c7 04 24 3c 16 80 00 	movl   $0x80163c,(%esp)
  800195:	e8 e1 00 00 00       	call   80027b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a4:	89 04 24             	mov    %eax,(%esp)
  8001a7:	e8 6b 00 00 00       	call   800217 <vcprintf>
	cprintf("\n");
  8001ac:	c7 04 24 5f 16 80 00 	movl   $0x80165f,(%esp)
  8001b3:	e8 c3 00 00 00       	call   80027b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b8:	cc                   	int3   
  8001b9:	eb fd                	jmp    8001b8 <_panic+0x58>

008001bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c4:	8b 00                	mov    (%eax),%eax
  8001c6:	8d 48 01             	lea    0x1(%eax),%ecx
  8001c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cc:	89 0a                	mov    %ecx,(%edx)
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	89 d1                	mov    %edx,%ecx
  8001d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d6:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dd:	8b 00                	mov    (%eax),%eax
  8001df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e4:	75 20                	jne    800206 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e9:	8b 00                	mov    (%eax),%eax
  8001eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ee:	83 c2 08             	add    $0x8,%edx
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	89 14 24             	mov    %edx,(%esp)
  8001f8:	e8 ea 0c 00 00       	call   800ee7 <sys_cputs>
		b->idx = 0;
  8001fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800200:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	8b 40 04             	mov    0x4(%eax),%eax
  80020c:	8d 50 01             	lea    0x1(%eax),%edx
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800212:	89 50 04             	mov    %edx,0x4(%eax)
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800220:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800227:	00 00 00 
	b.cnt = 0;
  80022a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800231:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800242:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024c:	c7 04 24 bb 01 80 00 	movl   $0x8001bb,(%esp)
  800253:	e8 bd 01 00 00       	call   800415 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800258:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800268:	83 c0 08             	add    $0x8,%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 74 0c 00 00       	call   800ee7 <sys_cputs>

	return b.cnt;
  800273:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800281:	8d 45 0c             	lea    0xc(%ebp),%eax
  800284:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80028a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 7e ff ff ff       	call   800217 <vcprintf>
  800299:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 34             	sub    $0x34,%esp
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b4:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002bf:	77 72                	ja     800333 <printnum+0x92>
  8002c1:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002c4:	72 05                	jb     8002cb <printnum+0x2a>
  8002c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002c9:	77 68                	ja     800333 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cb:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002ce:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002d1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ee:	e8 3d 10 00 00       	call   801330 <__udivdi3>
  8002f3:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002f6:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002fa:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002fe:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800301:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800305:	89 44 24 08          	mov    %eax,0x8(%esp)
  800309:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	e8 82 ff ff ff       	call   8002a1 <printnum>
  80031f:	eb 1c                	jmp    80033d <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800321:	8b 45 0c             	mov    0xc(%ebp),%eax
  800324:	89 44 24 04          	mov    %eax,0x4(%esp)
  800328:	8b 45 20             	mov    0x20(%ebp),%eax
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800333:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800337:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80033b:	7f e4                	jg     800321 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800340:	bb 00 00 00 00       	mov    $0x0,%ebx
  800345:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800348:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80034b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035a:	e8 01 11 00 00       	call   801460 <__umoddi3>
  80035f:	05 48 17 80 00       	add    $0x801748,%eax
  800364:	0f b6 00             	movzbl (%eax),%eax
  800367:	0f be c0             	movsbl %al,%eax
  80036a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	8b 45 08             	mov    0x8(%ebp),%eax
  800377:	ff d0                	call   *%eax
}
  800379:	83 c4 34             	add    $0x34,%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800382:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800386:	7e 14                	jle    80039c <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	8d 48 08             	lea    0x8(%eax),%ecx
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 0a                	mov    %ecx,(%edx)
  800395:	8b 50 04             	mov    0x4(%eax),%edx
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	eb 30                	jmp    8003cc <getuint+0x4d>
	else if (lflag)
  80039c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003a0:	74 16                	je     8003b8 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 0a                	mov    %ecx,(%edx)
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	eb 14                	jmp    8003cc <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	8b 00                	mov    (%eax),%eax
  8003bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c3:	89 0a                	mov    %ecx,(%edx)
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003d5:	7e 14                	jle    8003eb <getint+0x1d>
		return va_arg(*ap, long long);
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	8d 48 08             	lea    0x8(%eax),%ecx
  8003df:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e2:	89 0a                	mov    %ecx,(%edx)
  8003e4:	8b 50 04             	mov    0x4(%eax),%edx
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	eb 28                	jmp    800413 <getint+0x45>
	else if (lflag)
  8003eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003ef:	74 12                	je     800403 <getint+0x35>
		return va_arg(*ap, long);
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	8b 00                	mov    (%eax),%eax
  8003f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fc:	89 0a                	mov    %ecx,(%edx)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	99                   	cltd   
  800401:	eb 10                	jmp    800413 <getint+0x45>
	else
		return va_arg(*ap, int);
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	8b 00                	mov    (%eax),%eax
  800408:	8d 48 04             	lea    0x4(%eax),%ecx
  80040b:	8b 55 08             	mov    0x8(%ebp),%edx
  80040e:	89 0a                	mov    %ecx,(%edx)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	99                   	cltd   
}
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041d:	eb 18                	jmp    800437 <vprintfmt+0x22>
			if (ch == '\0')
  80041f:	85 db                	test   %ebx,%ebx
  800421:	75 05                	jne    800428 <vprintfmt+0x13>
				return;
  800423:	e9 cc 03 00 00       	jmp    8007f4 <vprintfmt+0x3df>
			putch(ch, putdat);
  800428:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80042f:	89 1c 24             	mov    %ebx,(%esp)
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	8b 45 10             	mov    0x10(%ebp),%eax
  80043a:	8d 50 01             	lea    0x1(%eax),%edx
  80043d:	89 55 10             	mov    %edx,0x10(%ebp)
  800440:	0f b6 00             	movzbl (%eax),%eax
  800443:	0f b6 d8             	movzbl %al,%ebx
  800446:	83 fb 25             	cmp    $0x25,%ebx
  800449:	75 d4                	jne    80041f <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80044b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80044f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800456:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80045d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800464:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 45 10             	mov    0x10(%ebp),%eax
  80046e:	8d 50 01             	lea    0x1(%eax),%edx
  800471:	89 55 10             	mov    %edx,0x10(%ebp)
  800474:	0f b6 00             	movzbl (%eax),%eax
  800477:	0f b6 d8             	movzbl %al,%ebx
  80047a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80047d:	83 f8 55             	cmp    $0x55,%eax
  800480:	0f 87 3d 03 00 00    	ja     8007c3 <vprintfmt+0x3ae>
  800486:	8b 04 85 6c 17 80 00 	mov    0x80176c(,%eax,4),%eax
  80048d:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80048f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800493:	eb d6                	jmp    80046b <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800495:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800499:	eb d0                	jmp    80046b <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a5:	89 d0                	mov    %edx,%eax
  8004a7:	c1 e0 02             	shl    $0x2,%eax
  8004aa:	01 d0                	add    %edx,%eax
  8004ac:	01 c0                	add    %eax,%eax
  8004ae:	01 d8                	add    %ebx,%eax
  8004b0:	83 e8 30             	sub    $0x30,%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b9:	0f b6 00             	movzbl (%eax),%eax
  8004bc:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004bf:	83 fb 2f             	cmp    $0x2f,%ebx
  8004c2:	7e 0b                	jle    8004cf <vprintfmt+0xba>
  8004c4:	83 fb 39             	cmp    $0x39,%ebx
  8004c7:	7f 06                	jg     8004cf <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cd:	eb d3                	jmp    8004a2 <vprintfmt+0x8d>
			goto process_precision;
  8004cf:	eb 33                	jmp    800504 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 50 04             	lea    0x4(%eax),%edx
  8004d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004df:	eb 23                	jmp    800504 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e5:	79 0c                	jns    8004f3 <vprintfmt+0xde>
				width = 0;
  8004e7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004ee:	e9 78 ff ff ff       	jmp    80046b <vprintfmt+0x56>
  8004f3:	e9 73 ff ff ff       	jmp    80046b <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004f8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004ff:	e9 67 ff ff ff       	jmp    80046b <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800504:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800508:	79 12                	jns    80051c <vprintfmt+0x107>
				width = precision, precision = -1;
  80050a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800510:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800517:	e9 4f ff ff ff       	jmp    80046b <vprintfmt+0x56>
  80051c:	e9 4a ff ff ff       	jmp    80046b <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800521:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800525:	e9 41 ff ff ff       	jmp    80046b <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 50 04             	lea    0x4(%eax),%edx
  800530:	89 55 14             	mov    %edx,0x14(%ebp)
  800533:	8b 00                	mov    (%eax),%eax
  800535:	8b 55 0c             	mov    0xc(%ebp),%edx
  800538:	89 54 24 04          	mov    %edx,0x4(%esp)
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	8b 45 08             	mov    0x8(%ebp),%eax
  800542:	ff d0                	call   *%eax
			break;
  800544:	e9 a5 02 00 00       	jmp    8007ee <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 50 04             	lea    0x4(%eax),%edx
  80054f:	89 55 14             	mov    %edx,0x14(%ebp)
  800552:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800554:	85 db                	test   %ebx,%ebx
  800556:	79 02                	jns    80055a <vprintfmt+0x145>
				err = -err;
  800558:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 fb 09             	cmp    $0x9,%ebx
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x155>
  80055f:	8b 34 9d 20 17 80 00 	mov    0x801720(,%ebx,4),%esi
  800566:	85 f6                	test   %esi,%esi
  800568:	75 23                	jne    80058d <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80056a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80056e:	c7 44 24 08 59 17 80 	movl   $0x801759,0x8(%esp)
  800575:	00 
  800576:	8b 45 0c             	mov    0xc(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 73 02 00 00       	call   8007fb <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800588:	e9 61 02 00 00       	jmp    8007ee <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80058d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800591:	c7 44 24 08 62 17 80 	movl   $0x801762,0x8(%esp)
  800598:	00 
  800599:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	e8 50 02 00 00       	call   8007fb <printfmt>
			break;
  8005ab:	e9 3e 02 00 00       	jmp    8007ee <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 30                	mov    (%eax),%esi
  8005bb:	85 f6                	test   %esi,%esi
  8005bd:	75 05                	jne    8005c4 <vprintfmt+0x1af>
				p = "(null)";
  8005bf:	be 65 17 80 00       	mov    $0x801765,%esi
			if (width > 0 && padc != '-')
  8005c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c8:	7e 37                	jle    800601 <vprintfmt+0x1ec>
  8005ca:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005ce:	74 31                	je     800601 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	89 34 24             	mov    %esi,(%esp)
  8005da:	e8 39 03 00 00       	call   800918 <strnlen>
  8005df:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005e2:	eb 17                	jmp    8005fb <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005e4:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f5:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f7:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ff:	7f e3                	jg     8005e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800601:	eb 38                	jmp    80063b <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800603:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800607:	74 1f                	je     800628 <vprintfmt+0x213>
  800609:	83 fb 1f             	cmp    $0x1f,%ebx
  80060c:	7e 05                	jle    800613 <vprintfmt+0x1fe>
  80060e:	83 fb 7e             	cmp    $0x7e,%ebx
  800611:	7e 15                	jle    800628 <vprintfmt+0x213>
					putch('?', putdat);
  800613:	8b 45 0c             	mov    0xc(%ebp),%eax
  800616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800621:	8b 45 08             	mov    0x8(%ebp),%eax
  800624:	ff d0                	call   *%eax
  800626:	eb 0f                	jmp    800637 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062f:	89 1c 24             	mov    %ebx,(%esp)
  800632:	8b 45 08             	mov    0x8(%ebp),%eax
  800635:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800637:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80063b:	89 f0                	mov    %esi,%eax
  80063d:	8d 70 01             	lea    0x1(%eax),%esi
  800640:	0f b6 00             	movzbl (%eax),%eax
  800643:	0f be d8             	movsbl %al,%ebx
  800646:	85 db                	test   %ebx,%ebx
  800648:	74 10                	je     80065a <vprintfmt+0x245>
  80064a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80064e:	78 b3                	js     800603 <vprintfmt+0x1ee>
  800650:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800654:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800658:	79 a9                	jns    800603 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065a:	eb 17                	jmp    800673 <vprintfmt+0x25e>
				putch(' ', putdat);
  80065c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800663:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80066a:	8b 45 08             	mov    0x8(%ebp),%eax
  80066d:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800673:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800677:	7f e3                	jg     80065c <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800679:	e9 70 01 00 00       	jmp    8007ee <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800681:	89 44 24 04          	mov    %eax,0x4(%esp)
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	e8 3e fd ff ff       	call   8003ce <getint>
  800690:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800693:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800699:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80069c:	85 d2                	test   %edx,%edx
  80069e:	79 26                	jns    8006c6 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a7:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	ff d0                	call   *%eax
				num = -(long long) num;
  8006b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b9:	f7 d8                	neg    %eax
  8006bb:	83 d2 00             	adc    $0x0,%edx
  8006be:	f7 da                	neg    %edx
  8006c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006c6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006cd:	e9 a8 00 00 00       	jmp    80077a <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	e8 9b fc ff ff       	call   80037f <getuint>
  8006e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006ea:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006f1:	e9 84 00 00 00       	jmp    80077a <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	e8 77 fc ff ff       	call   80037f <getuint>
  800708:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80070e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800715:	eb 63                	jmp    80077a <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800717:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	ff d0                	call   *%eax
			putch('x', putdat);
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 50 04             	lea    0x4(%eax),%edx
  800743:	89 55 14             	mov    %edx,0x14(%ebp)
  800746:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800752:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800759:	eb 1f                	jmp    80077a <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80075e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	89 04 24             	mov    %eax,(%esp)
  800768:	e8 12 fc ff ff       	call   80037f <getuint>
  80076d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800770:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800773:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80077a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80077e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800781:	89 54 24 18          	mov    %edx,0x18(%esp)
  800785:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800788:	89 54 24 14          	mov    %edx,0x14(%esp)
  80078c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800793:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	e8 f1 fa ff ff       	call   8002a1 <printnum>
			break;
  8007b0:	eb 3c                	jmp    8007ee <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	89 1c 24             	mov    %ebx,(%esp)
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	ff d0                	call   *%eax
			break;
  8007c1:	eb 2b                	jmp    8007ee <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007da:	eb 04                	jmp    8007e0 <vprintfmt+0x3cb>
  8007dc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e3:	83 e8 01             	sub    $0x1,%eax
  8007e6:	0f b6 00             	movzbl (%eax),%eax
  8007e9:	3c 25                	cmp    $0x25,%al
  8007eb:	75 ef                	jne    8007dc <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8007ed:	90                   	nop
		}
	}
  8007ee:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ef:	e9 43 fc ff ff       	jmp    800437 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007f4:	83 c4 40             	add    $0x40,%esp
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
  800804:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8b 45 0c             	mov    0xc(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	e8 ee fb ff ff       	call   800415 <vprintfmt>
	va_end(ap);
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    

00800829 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80082c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082f:	8b 40 08             	mov    0x8(%eax),%eax
  800832:	8d 50 01             	lea    0x1(%eax),%edx
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	8b 45 0c             	mov    0xc(%ebp),%eax
  800843:	8b 40 04             	mov    0x4(%eax),%eax
  800846:	39 c2                	cmp    %eax,%edx
  800848:	73 12                	jae    80085c <sprintputch+0x33>
		*b->buf++ = ch;
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	8d 48 01             	lea    0x1(%eax),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 0a                	mov    %ecx,(%edx)
  800857:	8b 55 08             	mov    0x8(%ebp),%edx
  80085a:	88 10                	mov    %dl,(%eax)
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	01 d0                	add    %edx,%eax
  800875:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800878:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800883:	74 06                	je     80088b <vsnprintf+0x2d>
  800885:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800889:	7f 07                	jg     800892 <vsnprintf+0x34>
		return -E_INVAL;
  80088b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800890:	eb 2a                	jmp    8008bc <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800892:	8b 45 14             	mov    0x14(%ebp),%eax
  800895:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800899:	8b 45 10             	mov    0x10(%ebp),%eax
  80089c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a7:	c7 04 24 29 08 80 00 	movl   $0x800829,(%esp)
  8008ae:	e8 62 fb ff ff       	call   800415 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 74 ff ff ff       	call   80085e <vsnprintf>
  8008ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008ff:	eb 08                	jmp    800909 <strlen+0x17>
		n++;
  800901:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800905:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	0f b6 00             	movzbl (%eax),%eax
  80090f:	84 c0                	test   %al,%al
  800911:	75 ee                	jne    800901 <strlen+0xf>
		n++;
	return n;
  800913:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800925:	eb 0c                	jmp    800933 <strnlen+0x1b>
		n++;
  800927:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80092f:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800933:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800937:	74 0a                	je     800943 <strnlen+0x2b>
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	0f b6 00             	movzbl (%eax),%eax
  80093f:	84 c0                	test   %al,%al
  800941:	75 e4                	jne    800927 <strnlen+0xf>
		n++;
	return n;
  800943:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800954:	90                   	nop
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8d 50 01             	lea    0x1(%eax),%edx
  80095b:	89 55 08             	mov    %edx,0x8(%ebp)
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800961:	8d 4a 01             	lea    0x1(%edx),%ecx
  800964:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800967:	0f b6 12             	movzbl (%edx),%edx
  80096a:	88 10                	mov    %dl,(%eax)
  80096c:	0f b6 00             	movzbl (%eax),%eax
  80096f:	84 c0                	test   %al,%al
  800971:	75 e2                	jne    800955 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	89 04 24             	mov    %eax,(%esp)
  800984:	e8 69 ff ff ff       	call   8008f2 <strlen>
  800989:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  80098c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	01 c2                	add    %eax,%edx
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	89 14 24             	mov    %edx,(%esp)
  80099e:	e8 a5 ff ff ff       	call   800948 <strcpy>
	return dst;
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    

008009a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009bb:	eb 23                	jmp    8009e0 <strncpy+0x38>
		*dst++ = *src;
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8d 50 01             	lea    0x1(%eax),%edx
  8009c3:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	0f b6 00             	movzbl (%eax),%eax
  8009d4:	84 c0                	test   %al,%al
  8009d6:	74 04                	je     8009dc <strncpy+0x34>
			src++;
  8009d8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009e3:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009e6:	72 d5                	jb     8009bd <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009fd:	74 33                	je     800a32 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009ff:	eb 17                	jmp    800a18 <strlcpy+0x2b>
			*dst++ = *src++;
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8d 50 01             	lea    0x1(%eax),%edx
  800a07:	89 55 08             	mov    %edx,0x8(%ebp)
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a10:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a13:	0f b6 12             	movzbl (%edx),%edx
  800a16:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a18:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a20:	74 0a                	je     800a2c <strlcpy+0x3f>
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	0f b6 00             	movzbl (%eax),%eax
  800a28:	84 c0                	test   %al,%al
  800a2a:	75 d5                	jne    800a01 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a32:	8b 55 08             	mov    0x8(%ebp),%edx
  800a35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a38:	29 c2                	sub    %eax,%edx
  800a3a:	89 d0                	mov    %edx,%eax
}
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a41:	eb 08                	jmp    800a4b <strcmp+0xd>
		p++, q++;
  800a43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a47:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	0f b6 00             	movzbl (%eax),%eax
  800a51:	84 c0                	test   %al,%al
  800a53:	74 10                	je     800a65 <strcmp+0x27>
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	0f b6 00             	movzbl (%eax),%eax
  800a61:	38 c2                	cmp    %al,%dl
  800a63:	74 de                	je     800a43 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	0f b6 d0             	movzbl %al,%edx
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	0f b6 00             	movzbl (%eax),%eax
  800a74:	0f b6 c0             	movzbl %al,%eax
  800a77:	29 c2                	sub    %eax,%edx
  800a79:	89 d0                	mov    %edx,%eax
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a80:	eb 0c                	jmp    800a8e <strncmp+0x11>
		n--, p++, q++;
  800a82:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a8a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a92:	74 1a                	je     800aae <strncmp+0x31>
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	0f b6 00             	movzbl (%eax),%eax
  800a9a:	84 c0                	test   %al,%al
  800a9c:	74 10                	je     800aae <strncmp+0x31>
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 10             	movzbl (%eax),%edx
  800aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa7:	0f b6 00             	movzbl (%eax),%eax
  800aaa:	38 c2                	cmp    %al,%dl
  800aac:	74 d4                	je     800a82 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800aae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab2:	75 07                	jne    800abb <strncmp+0x3e>
		return 0;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab9:	eb 16                	jmp    800ad1 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	0f b6 00             	movzbl (%eax),%eax
  800ac1:	0f b6 d0             	movzbl %al,%edx
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	0f b6 00             	movzbl (%eax),%eax
  800aca:	0f b6 c0             	movzbl %al,%eax
  800acd:	29 c2                	sub    %eax,%edx
  800acf:	89 d0                	mov    %edx,%eax
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	83 ec 04             	sub    $0x4,%esp
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800adf:	eb 14                	jmp    800af5 <strchr+0x22>
		if (*s == c)
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	0f b6 00             	movzbl (%eax),%eax
  800ae7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800aea:	75 05                	jne    800af1 <strchr+0x1e>
			return (char *) s;
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	eb 13                	jmp    800b04 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800af1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	0f b6 00             	movzbl (%eax),%eax
  800afb:	84 c0                	test   %al,%al
  800afd:	75 e2                	jne    800ae1 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b04:	c9                   	leave  
  800b05:	c3                   	ret    

00800b06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	83 ec 04             	sub    $0x4,%esp
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b12:	eb 11                	jmp    800b25 <strfind+0x1f>
		if (*s == c)
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	0f b6 00             	movzbl (%eax),%eax
  800b1a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b1d:	75 02                	jne    800b21 <strfind+0x1b>
			break;
  800b1f:	eb 0e                	jmp    800b2f <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b21:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	0f b6 00             	movzbl (%eax),%eax
  800b2b:	84 c0                	test   %al,%al
  800b2d:	75 e5                	jne    800b14 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b3c:	75 05                	jne    800b43 <memset+0xf>
		return v;
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	eb 5c                	jmp    800b9f <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	83 e0 03             	and    $0x3,%eax
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	75 41                	jne    800b8e <memset+0x5a>
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b50:	83 e0 03             	and    $0x3,%eax
  800b53:	85 c0                	test   %eax,%eax
  800b55:	75 37                	jne    800b8e <memset+0x5a>
		c &= 0xFF;
  800b57:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	c1 e0 18             	shl    $0x18,%eax
  800b64:	89 c2                	mov    %eax,%edx
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	c1 e0 10             	shl    $0x10,%eax
  800b6c:	09 c2                	or     %eax,%edx
  800b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b71:	c1 e0 08             	shl    $0x8,%eax
  800b74:	09 d0                	or     %edx,%eax
  800b76:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b79:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7c:	c1 e8 02             	shr    $0x2,%eax
  800b7f:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b81:	8b 55 08             	mov    0x8(%ebp),%edx
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	fc                   	cld    
  800b8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b8c:	eb 0e                	jmp    800b9c <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b94:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b97:	89 d7                	mov    %edx,%edi
  800b99:	fc                   	cld    
  800b9a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b9c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bbd:	73 6d                	jae    800c2c <memmove+0x8a>
  800bbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bc5:	01 d0                	add    %edx,%eax
  800bc7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bca:	76 60                	jbe    800c2c <memmove+0x8a>
		s += n;
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd5:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bdb:	83 e0 03             	and    $0x3,%eax
  800bde:	85 c0                	test   %eax,%eax
  800be0:	75 2f                	jne    800c11 <memmove+0x6f>
  800be2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be5:	83 e0 03             	and    $0x3,%eax
  800be8:	85 c0                	test   %eax,%eax
  800bea:	75 25                	jne    800c11 <memmove+0x6f>
  800bec:	8b 45 10             	mov    0x10(%ebp),%eax
  800bef:	83 e0 03             	and    $0x3,%eax
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	75 1b                	jne    800c11 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf9:	83 e8 04             	sub    $0x4,%eax
  800bfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bff:	83 ea 04             	sub    $0x4,%edx
  800c02:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c05:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c08:	89 c7                	mov    %eax,%edi
  800c0a:	89 d6                	mov    %edx,%esi
  800c0c:	fd                   	std    
  800c0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0f:	eb 18                	jmp    800c29 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c14:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1a:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c20:	89 d7                	mov    %edx,%edi
  800c22:	89 de                	mov    %ebx,%esi
  800c24:	89 c1                	mov    %eax,%ecx
  800c26:	fd                   	std    
  800c27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c29:	fc                   	cld    
  800c2a:	eb 45                	jmp    800c71 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2f:	83 e0 03             	and    $0x3,%eax
  800c32:	85 c0                	test   %eax,%eax
  800c34:	75 2b                	jne    800c61 <memmove+0xbf>
  800c36:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c39:	83 e0 03             	and    $0x3,%eax
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	75 21                	jne    800c61 <memmove+0xbf>
  800c40:	8b 45 10             	mov    0x10(%ebp),%eax
  800c43:	83 e0 03             	and    $0x3,%eax
  800c46:	85 c0                	test   %eax,%eax
  800c48:	75 17                	jne    800c61 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4d:	c1 e8 02             	shr    $0x2,%eax
  800c50:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c55:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c58:	89 c7                	mov    %eax,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	fc                   	cld    
  800c5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5f:	eb 10                	jmp    800c71 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c61:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c64:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c67:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	89 d6                	mov    %edx,%esi
  800c6e:	fc                   	cld    
  800c6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c82:	8b 45 10             	mov    0x10(%ebp),%eax
  800c85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	89 04 24             	mov    %eax,(%esp)
  800c96:	e8 07 ff ff ff       	call   800ba2 <memmove>
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    

00800c9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cac:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800caf:	eb 30                	jmp    800ce1 <memcmp+0x44>
		if (*s1 != *s2)
  800cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cb4:	0f b6 10             	movzbl (%eax),%edx
  800cb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cba:	0f b6 00             	movzbl (%eax),%eax
  800cbd:	38 c2                	cmp    %al,%dl
  800cbf:	74 18                	je     800cd9 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cc4:	0f b6 00             	movzbl (%eax),%eax
  800cc7:	0f b6 d0             	movzbl %al,%edx
  800cca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ccd:	0f b6 00             	movzbl (%eax),%eax
  800cd0:	0f b6 c0             	movzbl %al,%eax
  800cd3:	29 c2                	sub    %eax,%edx
  800cd5:	89 d0                	mov    %edx,%eax
  800cd7:	eb 1a                	jmp    800cf3 <memcmp+0x56>
		s1++, s2++;
  800cd9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cdd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ce7:	89 55 10             	mov    %edx,0x10(%ebp)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	75 c3                	jne    800cb1 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf3:	c9                   	leave  
  800cf4:	c3                   	ret    

00800cf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800cfb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	01 d0                	add    %edx,%eax
  800d03:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d06:	eb 13                	jmp    800d1b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	0f b6 10             	movzbl (%eax),%edx
  800d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d11:	38 c2                	cmp    %al,%dl
  800d13:	75 02                	jne    800d17 <memfind+0x22>
			break;
  800d15:	eb 0c                	jmp    800d23 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d21:	72 e5                	jb     800d08 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d35:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3c:	eb 04                	jmp    800d42 <strtol+0x1a>
		s++;
  800d3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	0f b6 00             	movzbl (%eax),%eax
  800d48:	3c 20                	cmp    $0x20,%al
  800d4a:	74 f2                	je     800d3e <strtol+0x16>
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	3c 09                	cmp    $0x9,%al
  800d54:	74 e8                	je     800d3e <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	0f b6 00             	movzbl (%eax),%eax
  800d5c:	3c 2b                	cmp    $0x2b,%al
  800d5e:	75 06                	jne    800d66 <strtol+0x3e>
		s++;
  800d60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d64:	eb 15                	jmp    800d7b <strtol+0x53>
	else if (*s == '-')
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	3c 2d                	cmp    $0x2d,%al
  800d6e:	75 0b                	jne    800d7b <strtol+0x53>
		s++, neg = 1;
  800d70:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d74:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d7f:	74 06                	je     800d87 <strtol+0x5f>
  800d81:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d85:	75 24                	jne    800dab <strtol+0x83>
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	0f b6 00             	movzbl (%eax),%eax
  800d8d:	3c 30                	cmp    $0x30,%al
  800d8f:	75 1a                	jne    800dab <strtol+0x83>
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	83 c0 01             	add    $0x1,%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	3c 78                	cmp    $0x78,%al
  800d9c:	75 0d                	jne    800dab <strtol+0x83>
		s += 2, base = 16;
  800d9e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800da2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800da9:	eb 2a                	jmp    800dd5 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800dab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800daf:	75 17                	jne    800dc8 <strtol+0xa0>
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	0f b6 00             	movzbl (%eax),%eax
  800db7:	3c 30                	cmp    $0x30,%al
  800db9:	75 0d                	jne    800dc8 <strtol+0xa0>
		s++, base = 8;
  800dbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dc6:	eb 0d                	jmp    800dd5 <strtol+0xad>
	else if (base == 0)
  800dc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dcc:	75 07                	jne    800dd5 <strtol+0xad>
		base = 10;
  800dce:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	0f b6 00             	movzbl (%eax),%eax
  800ddb:	3c 2f                	cmp    $0x2f,%al
  800ddd:	7e 1b                	jle    800dfa <strtol+0xd2>
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	3c 39                	cmp    $0x39,%al
  800de7:	7f 11                	jg     800dfa <strtol+0xd2>
			dig = *s - '0';
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	0f b6 00             	movzbl (%eax),%eax
  800def:	0f be c0             	movsbl %al,%eax
  800df2:	83 e8 30             	sub    $0x30,%eax
  800df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800df8:	eb 48                	jmp    800e42 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	3c 60                	cmp    $0x60,%al
  800e02:	7e 1b                	jle    800e1f <strtol+0xf7>
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	0f b6 00             	movzbl (%eax),%eax
  800e0a:	3c 7a                	cmp    $0x7a,%al
  800e0c:	7f 11                	jg     800e1f <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	0f b6 00             	movzbl (%eax),%eax
  800e14:	0f be c0             	movsbl %al,%eax
  800e17:	83 e8 57             	sub    $0x57,%eax
  800e1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e1d:	eb 23                	jmp    800e42 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	0f b6 00             	movzbl (%eax),%eax
  800e25:	3c 40                	cmp    $0x40,%al
  800e27:	7e 3d                	jle    800e66 <strtol+0x13e>
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	0f b6 00             	movzbl (%eax),%eax
  800e2f:	3c 5a                	cmp    $0x5a,%al
  800e31:	7f 33                	jg     800e66 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	0f b6 00             	movzbl (%eax),%eax
  800e39:	0f be c0             	movsbl %al,%eax
  800e3c:	83 e8 37             	sub    $0x37,%eax
  800e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e45:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e48:	7c 02                	jl     800e4c <strtol+0x124>
			break;
  800e4a:	eb 1a                	jmp    800e66 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e50:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e57:	89 c2                	mov    %eax,%edx
  800e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e5c:	01 d0                	add    %edx,%eax
  800e5e:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e61:	e9 6f ff ff ff       	jmp    800dd5 <strtol+0xad>

	if (endptr)
  800e66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6a:	74 08                	je     800e74 <strtol+0x14c>
		*endptr = (char *) s;
  800e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e74:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e78:	74 07                	je     800e81 <strtol+0x159>
  800e7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e7d:	f7 d8                	neg    %eax
  800e7f:	eb 03                	jmp    800e84 <strtol+0x15c>
  800e81:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	8b 55 10             	mov    0x10(%ebp),%edx
  800e95:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e98:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e9b:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e9e:	8b 75 20             	mov    0x20(%ebp),%esi
  800ea1:	cd 30                	int    $0x30
  800ea3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eaa:	74 30                	je     800edc <syscall+0x56>
  800eac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eb0:	7e 2a                	jle    800edc <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ec0:	c7 44 24 08 c4 18 80 	movl   $0x8018c4,0x8(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecf:	00 
  800ed0:	c7 04 24 e1 18 80 00 	movl   $0x8018e1,(%esp)
  800ed7:	e8 84 f2 ff ff       	call   800160 <_panic>

	return ret;
  800edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800edf:	83 c4 3c             	add    $0x3c,%esp
  800ee2:	5b                   	pop    %ebx
  800ee3:	5e                   	pop    %esi
  800ee4:	5f                   	pop    %edi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ef7:	00 
  800ef8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eff:	00 
  800f00:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f07:	00 
  800f08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f1a:	00 
  800f1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f22:	e8 5f ff ff ff       	call   800e86 <syscall>
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f2f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f36:	00 
  800f37:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f46:	00 
  800f47:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f56:	00 
  800f57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5e:	00 
  800f5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f66:	e8 1b ff ff ff       	call   800e86 <syscall>
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
  800f76:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f85:	00 
  800f86:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f95:	00 
  800f96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fa1:	00 
  800fa2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fa9:	e8 d8 fe ff ff       	call   800e86 <syscall>
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fb6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fcd:	00 
  800fce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd5:	00 
  800fd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fdd:	00 
  800fde:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe5:	00 
  800fe6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fed:	e8 94 fe ff ff       	call   800e86 <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <sys_yield>:

void
sys_yield(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ffa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801001:	00 
  801002:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801009:	00 
  80100a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801011:	00 
  801012:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801019:	00 
  80101a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801021:	00 
  801022:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801029:	00 
  80102a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801031:	e8 50 fe ff ff       	call   800e86 <syscall>
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80103e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801041:	8b 55 0c             	mov    0xc(%ebp),%edx
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80104e:	00 
  80104f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801056:	00 
  801057:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80105b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80105f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801063:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801072:	e8 0f fe ff ff       	call   800e86 <syscall>
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801081:	8b 75 18             	mov    0x18(%ebp),%esi
  801084:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801087:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80108a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	89 74 24 18          	mov    %esi,0x18(%esp)
  801094:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801098:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80109c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ab:	00 
  8010ac:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010b3:	e8 ce fd ff ff       	call   800e86 <syscall>
}
  8010b8:	83 c4 20             	add    $0x20,%esp
  8010bb:	5b                   	pop    %ebx
  8010bc:	5e                   	pop    %esi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010da:	00 
  8010db:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010e2:	00 
  8010e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f2:	00 
  8010f3:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010fa:	e8 87 fd ff ff       	call   800e86 <syscall>
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801107:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801114:	00 
  801115:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80111c:	00 
  80111d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801124:	00 
  801125:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80113c:	e8 45 fd ff ff       	call   800e86 <syscall>
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801149:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801156:	00 
  801157:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80115e:	00 
  80115f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801166:	00 
  801167:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80116b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80116f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801176:	00 
  801177:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80117e:	e8 03 fd ff ff       	call   800e86 <syscall>
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80118b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80118e:	8b 55 10             	mov    0x10(%ebp),%edx
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80119b:	00 
  80119c:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011b6:	00 
  8011b7:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011be:	e8 c3 fc ff ff       	call   800e86 <syscall>
}
  8011c3:	c9                   	leave  
  8011c4:	c3                   	ret    

008011c5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ce:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011d5:	00 
  8011d6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011dd:	00 
  8011de:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011e5:	00 
  8011e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011ed:	00 
  8011ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801201:	e8 80 fc ff ff       	call   800e86 <syscall>
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <sys_exec>:

void sys_exec(char* buf){
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
  801211:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801218:	00 
  801219:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801220:	00 
  801221:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801228:	00 
  801229:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801230:	00 
  801231:	89 44 24 08          	mov    %eax,0x8(%esp)
  801235:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80123c:	00 
  80123d:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801244:	e8 3d fc ff ff       	call   800e86 <syscall>
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <sys_wait>:

void sys_wait(){
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  801251:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801258:	00 
  801259:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801260:	00 
  801261:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801268:	00 
  801269:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801270:	00 
  801271:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801278:	00 
  801279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801280:	00 
  801281:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801288:	e8 f9 fb ff ff       	call   800e86 <syscall>
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801295:	a1 08 20 80 00       	mov    0x802008,%eax
  80129a:	85 c0                	test   %eax,%eax
  80129c:	75 5d                	jne    8012fb <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80129e:	a1 04 20 80 00       	mov    0x802004,%eax
  8012a3:	8b 40 48             	mov    0x48(%eax),%eax
  8012a6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ad:	00 
  8012ae:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012b5:	ee 
  8012b6:	89 04 24             	mov    %eax,(%esp)
  8012b9:	e8 7a fd ff ff       	call   801038 <sys_page_alloc>
  8012be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8012c5:	79 1c                	jns    8012e3 <set_pgfault_handler+0x54>
  8012c7:	c7 44 24 08 f0 18 80 	movl   $0x8018f0,0x8(%esp)
  8012ce:	00 
  8012cf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8012d6:	00 
  8012d7:	c7 04 24 1c 19 80 00 	movl   $0x80191c,(%esp)
  8012de:	e8 7d ee ff ff       	call   800160 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8012e3:	a1 04 20 80 00       	mov    0x802004,%eax
  8012e8:	8b 40 48             	mov    0x48(%eax),%eax
  8012eb:	c7 44 24 04 05 13 80 	movl   $0x801305,0x4(%esp)
  8012f2:	00 
  8012f3:	89 04 24             	mov    %eax,(%esp)
  8012f6:	e8 48 fe ff ff       	call   801143 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fe:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801305:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801306:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80130b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80130d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801310:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801314:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801316:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80131a:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80131b:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80131e:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801320:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801321:	58                   	pop    %eax
	popal 						// pop all the registers
  801322:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801323:	83 c4 04             	add    $0x4,%esp
	popfl
  801326:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801327:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801328:	c3                   	ret    
  801329:	66 90                	xchg   %ax,%ax
  80132b:	66 90                	xchg   %ax,%ax
  80132d:	66 90                	xchg   %ax,%ax
  80132f:	90                   	nop

00801330 <__udivdi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80133a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80133e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801342:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801346:	85 c0                	test   %eax,%eax
  801348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80134c:	89 ea                	mov    %ebp,%edx
  80134e:	89 0c 24             	mov    %ecx,(%esp)
  801351:	75 2d                	jne    801380 <__udivdi3+0x50>
  801353:	39 e9                	cmp    %ebp,%ecx
  801355:	77 61                	ja     8013b8 <__udivdi3+0x88>
  801357:	85 c9                	test   %ecx,%ecx
  801359:	89 ce                	mov    %ecx,%esi
  80135b:	75 0b                	jne    801368 <__udivdi3+0x38>
  80135d:	b8 01 00 00 00       	mov    $0x1,%eax
  801362:	31 d2                	xor    %edx,%edx
  801364:	f7 f1                	div    %ecx
  801366:	89 c6                	mov    %eax,%esi
  801368:	31 d2                	xor    %edx,%edx
  80136a:	89 e8                	mov    %ebp,%eax
  80136c:	f7 f6                	div    %esi
  80136e:	89 c5                	mov    %eax,%ebp
  801370:	89 f8                	mov    %edi,%eax
  801372:	f7 f6                	div    %esi
  801374:	89 ea                	mov    %ebp,%edx
  801376:	83 c4 0c             	add    $0xc,%esp
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    
  80137d:	8d 76 00             	lea    0x0(%esi),%esi
  801380:	39 e8                	cmp    %ebp,%eax
  801382:	77 24                	ja     8013a8 <__udivdi3+0x78>
  801384:	0f bd e8             	bsr    %eax,%ebp
  801387:	83 f5 1f             	xor    $0x1f,%ebp
  80138a:	75 3c                	jne    8013c8 <__udivdi3+0x98>
  80138c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801390:	39 34 24             	cmp    %esi,(%esp)
  801393:	0f 86 9f 00 00 00    	jbe    801438 <__udivdi3+0x108>
  801399:	39 d0                	cmp    %edx,%eax
  80139b:	0f 82 97 00 00 00    	jb     801438 <__udivdi3+0x108>
  8013a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	31 d2                	xor    %edx,%edx
  8013aa:	31 c0                	xor    %eax,%eax
  8013ac:	83 c4 0c             	add    $0xc,%esp
  8013af:	5e                   	pop    %esi
  8013b0:	5f                   	pop    %edi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    
  8013b3:	90                   	nop
  8013b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b8:	89 f8                	mov    %edi,%eax
  8013ba:	f7 f1                	div    %ecx
  8013bc:	31 d2                	xor    %edx,%edx
  8013be:	83 c4 0c             	add    $0xc,%esp
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
  8013c5:	8d 76 00             	lea    0x0(%esi),%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	8b 3c 24             	mov    (%esp),%edi
  8013cd:	d3 e0                	shl    %cl,%eax
  8013cf:	89 c6                	mov    %eax,%esi
  8013d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013d6:	29 e8                	sub    %ebp,%eax
  8013d8:	89 c1                	mov    %eax,%ecx
  8013da:	d3 ef                	shr    %cl,%edi
  8013dc:	89 e9                	mov    %ebp,%ecx
  8013de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013e2:	8b 3c 24             	mov    (%esp),%edi
  8013e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013e9:	89 d6                	mov    %edx,%esi
  8013eb:	d3 e7                	shl    %cl,%edi
  8013ed:	89 c1                	mov    %eax,%ecx
  8013ef:	89 3c 24             	mov    %edi,(%esp)
  8013f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013f6:	d3 ee                	shr    %cl,%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	d3 e2                	shl    %cl,%edx
  8013fc:	89 c1                	mov    %eax,%ecx
  8013fe:	d3 ef                	shr    %cl,%edi
  801400:	09 d7                	or     %edx,%edi
  801402:	89 f2                	mov    %esi,%edx
  801404:	89 f8                	mov    %edi,%eax
  801406:	f7 74 24 08          	divl   0x8(%esp)
  80140a:	89 d6                	mov    %edx,%esi
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	f7 24 24             	mull   (%esp)
  801411:	39 d6                	cmp    %edx,%esi
  801413:	89 14 24             	mov    %edx,(%esp)
  801416:	72 30                	jb     801448 <__udivdi3+0x118>
  801418:	8b 54 24 04          	mov    0x4(%esp),%edx
  80141c:	89 e9                	mov    %ebp,%ecx
  80141e:	d3 e2                	shl    %cl,%edx
  801420:	39 c2                	cmp    %eax,%edx
  801422:	73 05                	jae    801429 <__udivdi3+0xf9>
  801424:	3b 34 24             	cmp    (%esp),%esi
  801427:	74 1f                	je     801448 <__udivdi3+0x118>
  801429:	89 f8                	mov    %edi,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	e9 7a ff ff ff       	jmp    8013ac <__udivdi3+0x7c>
  801432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801438:	31 d2                	xor    %edx,%edx
  80143a:	b8 01 00 00 00       	mov    $0x1,%eax
  80143f:	e9 68 ff ff ff       	jmp    8013ac <__udivdi3+0x7c>
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	8d 47 ff             	lea    -0x1(%edi),%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	83 c4 0c             	add    $0xc,%esp
  801450:	5e                   	pop    %esi
  801451:	5f                   	pop    %edi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    
  801454:	66 90                	xchg   %ax,%ax
  801456:	66 90                	xchg   %ax,%ax
  801458:	66 90                	xchg   %ax,%ax
  80145a:	66 90                	xchg   %ax,%ax
  80145c:	66 90                	xchg   %ax,%ax
  80145e:	66 90                	xchg   %ax,%ax

00801460 <__umoddi3>:
  801460:	55                   	push   %ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	83 ec 14             	sub    $0x14,%esp
  801466:	8b 44 24 28          	mov    0x28(%esp),%eax
  80146a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80146e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801472:	89 c7                	mov    %eax,%edi
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	8b 44 24 30          	mov    0x30(%esp),%eax
  80147c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801480:	89 34 24             	mov    %esi,(%esp)
  801483:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801487:	85 c0                	test   %eax,%eax
  801489:	89 c2                	mov    %eax,%edx
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	75 17                	jne    8014a8 <__umoddi3+0x48>
  801491:	39 fe                	cmp    %edi,%esi
  801493:	76 4b                	jbe    8014e0 <__umoddi3+0x80>
  801495:	89 c8                	mov    %ecx,%eax
  801497:	89 fa                	mov    %edi,%edx
  801499:	f7 f6                	div    %esi
  80149b:	89 d0                	mov    %edx,%eax
  80149d:	31 d2                	xor    %edx,%edx
  80149f:	83 c4 14             	add    $0x14,%esp
  8014a2:	5e                   	pop    %esi
  8014a3:	5f                   	pop    %edi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    
  8014a6:	66 90                	xchg   %ax,%ax
  8014a8:	39 f8                	cmp    %edi,%eax
  8014aa:	77 54                	ja     801500 <__umoddi3+0xa0>
  8014ac:	0f bd e8             	bsr    %eax,%ebp
  8014af:	83 f5 1f             	xor    $0x1f,%ebp
  8014b2:	75 5c                	jne    801510 <__umoddi3+0xb0>
  8014b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014b8:	39 3c 24             	cmp    %edi,(%esp)
  8014bb:	0f 87 e7 00 00 00    	ja     8015a8 <__umoddi3+0x148>
  8014c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014c5:	29 f1                	sub    %esi,%ecx
  8014c7:	19 c7                	sbb    %eax,%edi
  8014c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014d9:	83 c4 14             	add    $0x14,%esp
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    
  8014e0:	85 f6                	test   %esi,%esi
  8014e2:	89 f5                	mov    %esi,%ebp
  8014e4:	75 0b                	jne    8014f1 <__umoddi3+0x91>
  8014e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014eb:	31 d2                	xor    %edx,%edx
  8014ed:	f7 f6                	div    %esi
  8014ef:	89 c5                	mov    %eax,%ebp
  8014f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014f5:	31 d2                	xor    %edx,%edx
  8014f7:	f7 f5                	div    %ebp
  8014f9:	89 c8                	mov    %ecx,%eax
  8014fb:	f7 f5                	div    %ebp
  8014fd:	eb 9c                	jmp    80149b <__umoddi3+0x3b>
  8014ff:	90                   	nop
  801500:	89 c8                	mov    %ecx,%eax
  801502:	89 fa                	mov    %edi,%edx
  801504:	83 c4 14             	add    $0x14,%esp
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    
  80150b:	90                   	nop
  80150c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801510:	8b 04 24             	mov    (%esp),%eax
  801513:	be 20 00 00 00       	mov    $0x20,%esi
  801518:	89 e9                	mov    %ebp,%ecx
  80151a:	29 ee                	sub    %ebp,%esi
  80151c:	d3 e2                	shl    %cl,%edx
  80151e:	89 f1                	mov    %esi,%ecx
  801520:	d3 e8                	shr    %cl,%eax
  801522:	89 e9                	mov    %ebp,%ecx
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	8b 04 24             	mov    (%esp),%eax
  80152b:	09 54 24 04          	or     %edx,0x4(%esp)
  80152f:	89 fa                	mov    %edi,%edx
  801531:	d3 e0                	shl    %cl,%eax
  801533:	89 f1                	mov    %esi,%ecx
  801535:	89 44 24 08          	mov    %eax,0x8(%esp)
  801539:	8b 44 24 10          	mov    0x10(%esp),%eax
  80153d:	d3 ea                	shr    %cl,%edx
  80153f:	89 e9                	mov    %ebp,%ecx
  801541:	d3 e7                	shl    %cl,%edi
  801543:	89 f1                	mov    %esi,%ecx
  801545:	d3 e8                	shr    %cl,%eax
  801547:	89 e9                	mov    %ebp,%ecx
  801549:	09 f8                	or     %edi,%eax
  80154b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80154f:	f7 74 24 04          	divl   0x4(%esp)
  801553:	d3 e7                	shl    %cl,%edi
  801555:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801559:	89 d7                	mov    %edx,%edi
  80155b:	f7 64 24 08          	mull   0x8(%esp)
  80155f:	39 d7                	cmp    %edx,%edi
  801561:	89 c1                	mov    %eax,%ecx
  801563:	89 14 24             	mov    %edx,(%esp)
  801566:	72 2c                	jb     801594 <__umoddi3+0x134>
  801568:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80156c:	72 22                	jb     801590 <__umoddi3+0x130>
  80156e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801572:	29 c8                	sub    %ecx,%eax
  801574:	19 d7                	sbb    %edx,%edi
  801576:	89 e9                	mov    %ebp,%ecx
  801578:	89 fa                	mov    %edi,%edx
  80157a:	d3 e8                	shr    %cl,%eax
  80157c:	89 f1                	mov    %esi,%ecx
  80157e:	d3 e2                	shl    %cl,%edx
  801580:	89 e9                	mov    %ebp,%ecx
  801582:	d3 ef                	shr    %cl,%edi
  801584:	09 d0                	or     %edx,%eax
  801586:	89 fa                	mov    %edi,%edx
  801588:	83 c4 14             	add    $0x14,%esp
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
  80158f:	90                   	nop
  801590:	39 d7                	cmp    %edx,%edi
  801592:	75 da                	jne    80156e <__umoddi3+0x10e>
  801594:	8b 14 24             	mov    (%esp),%edx
  801597:	89 c1                	mov    %eax,%ecx
  801599:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80159d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8015a1:	eb cb                	jmp    80156e <__umoddi3+0x10e>
  8015a3:	90                   	nop
  8015a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015ac:	0f 82 0f ff ff ff    	jb     8014c1 <__umoddi3+0x61>
  8015b2:	e9 1a ff ff ff       	jmp    8014d1 <__umoddi3+0x71>
