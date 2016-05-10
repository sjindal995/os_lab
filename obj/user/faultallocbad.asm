
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
  800048:	c7 04 24 00 16 80 00 	movl   $0x801600,(%esp)
  80004f:	e8 13 02 00 00       	call   800267 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800057:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80005a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800069:	00 
  80006a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800075:	e8 aa 0f 00 00       	call   801024 <sys_page_alloc>
  80007a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80007d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800081:	79 2a                	jns    8000ad <handler+0x7a>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800083:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800086:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800091:	c7 44 24 08 0c 16 80 	movl   $0x80160c,0x8(%esp)
  800098:	00 
  800099:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000a0:	00 
  8000a1:	c7 04 24 37 16 80 00 	movl   $0x801637,(%esp)
  8000a8:	e8 9f 00 00 00       	call   80014c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b4:	c7 44 24 08 4c 16 80 	movl   $0x80164c,0x8(%esp)
  8000bb:	00 
  8000bc:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000c3:	00 
  8000c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c7:	89 04 24             	mov    %eax,(%esp)
  8000ca:	e8 db 07 00 00       	call   8008aa <snprintf>
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
  8000de:	e8 dc 11 00 00       	call   8012bf <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000e3:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000f2:	e8 dc 0d 00 00       	call   800ed3 <sys_cputs>
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
  8000ff:	e8 98 0e 00 00       	call   800f9c <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	c1 e0 02             	shl    $0x2,%eax
  80010c:	89 c2                	mov    %eax,%edx
  80010e:	c1 e2 05             	shl    $0x5,%edx
  800111:	29 c2                	sub    %eax,%edx
  800113:	89 d0                	mov    %edx,%eax
  800115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  80011f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800122:	89 44 24 04          	mov    %eax,0x4(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 a0 ff ff ff       	call   8000d1 <umain>

	// exit gracefully
	exit();
  800131:	e8 02 00 00 00       	call   800138 <exit>
}
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800145:	e8 0f 0e 00 00       	call   800f59 <sys_env_destroy>
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	53                   	push   %ebx
  800150:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800153:	8d 45 14             	lea    0x14(%ebp),%eax
  800156:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800159:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80015f:	e8 38 0e 00 00       	call   800f9c <sys_getenvid>
  800164:	8b 55 0c             	mov    0xc(%ebp),%edx
  800167:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800172:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017a:	c7 04 24 78 16 80 00 	movl   $0x801678,(%esp)
  800181:	e8 e1 00 00 00       	call   800267 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 10             	mov    0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 6b 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  800198:	c7 04 24 9b 16 80 00 	movl   $0x80169b,(%esp)
  80019f:	e8 c3 00 00 00       	call   800267 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a4:	cc                   	int3   
  8001a5:	eb fd                	jmp    8001a4 <_panic+0x58>

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b0:	8b 00                	mov    (%eax),%eax
  8001b2:	8d 48 01             	lea    0x1(%eax),%ecx
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b8:	89 0a                	mov    %ecx,(%edx)
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	89 d1                	mov    %edx,%ecx
  8001bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c2:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c9:	8b 00                	mov    (%eax),%eax
  8001cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d0:	75 20                	jne    8001f2 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d5:	8b 00                	mov    (%eax),%eax
  8001d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001da:	83 c2 08             	add    $0x8,%edx
  8001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e1:	89 14 24             	mov    %edx,(%esp)
  8001e4:	e8 ea 0c 00 00       	call   800ed3 <sys_cputs>
		b->idx = 0;
  8001e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8001f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f5:	8b 40 04             	mov    0x4(%eax),%eax
  8001f8:	8d 50 01             	lea    0x1(%eax),%edx
  8001fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fe:	89 50 04             	mov    %edx,0x4(%eax)
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800213:	00 00 00 
	b.cnt = 0;
  800216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	89 44 24 04          	mov    %eax,0x4(%esp)
  800238:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  80023f:	e8 bd 01 00 00       	call   800401 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800254:	83 c0 08             	add    $0x8,%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 74 0c 00 00       	call   800ed3 <sys_cputs>

	return b.cnt;
  80025f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026d:	8d 45 0c             	lea    0xc(%ebp),%eax
  800270:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800273:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800276:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 7e ff ff ff       	call   800203 <vcprintf>
  800285:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800288:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	53                   	push   %ebx
  800291:	83 ec 34             	sub    $0x34,%esp
  800294:	8b 45 10             	mov    0x10(%ebp),%eax
  800297:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80029a:	8b 45 14             	mov    0x14(%ebp),%eax
  80029d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ab:	77 72                	ja     80031f <printnum+0x92>
  8002ad:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002b0:	72 05                	jb     8002b7 <printnum+0x2a>
  8002b2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002b5:	77 68                	ja     80031f <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b7:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002da:	e8 81 10 00 00       	call   801360 <__udivdi3>
  8002df:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002e2:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002e6:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ea:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002ed:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800300:	8b 45 08             	mov    0x8(%ebp),%eax
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	e8 82 ff ff ff       	call   80028d <printnum>
  80030b:	eb 1c                	jmp    800329 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8b 45 20             	mov    0x20(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031f:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800323:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800327:	7f e4                	jg     80030d <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80032c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800334:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800337:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	89 54 24 04          	mov    %edx,0x4(%esp)
  800346:	e8 45 11 00 00       	call   801490 <__umoddi3>
  80034b:	05 68 17 80 00       	add    $0x801768,%eax
  800350:	0f b6 00             	movzbl (%eax),%eax
  800353:	0f be c0             	movsbl %al,%eax
  800356:	8b 55 0c             	mov    0xc(%ebp),%edx
  800359:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	ff d0                	call   *%eax
}
  800365:	83 c4 34             	add    $0x34,%esp
  800368:	5b                   	pop    %ebx
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800372:	7e 14                	jle    800388 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800374:	8b 45 08             	mov    0x8(%ebp),%eax
  800377:	8b 00                	mov    (%eax),%eax
  800379:	8d 48 08             	lea    0x8(%eax),%ecx
  80037c:	8b 55 08             	mov    0x8(%ebp),%edx
  80037f:	89 0a                	mov    %ecx,(%edx)
  800381:	8b 50 04             	mov    0x4(%eax),%edx
  800384:	8b 00                	mov    (%eax),%eax
  800386:	eb 30                	jmp    8003b8 <getuint+0x4d>
	else if (lflag)
  800388:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80038c:	74 16                	je     8003a4 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	8b 00                	mov    (%eax),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	8b 55 08             	mov    0x8(%ebp),%edx
  800399:	89 0a                	mov    %ecx,(%edx)
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	eb 14                	jmp    8003b8 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	8b 00                	mov    (%eax),%eax
  8003a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8003af:	89 0a                	mov    %ecx,(%edx)
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003bd:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003c1:	7e 14                	jle    8003d7 <getint+0x1d>
		return va_arg(*ap, long long);
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	8d 48 08             	lea    0x8(%eax),%ecx
  8003cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ce:	89 0a                	mov    %ecx,(%edx)
  8003d0:	8b 50 04             	mov    0x4(%eax),%edx
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	eb 28                	jmp    8003ff <getint+0x45>
	else if (lflag)
  8003d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003db:	74 12                	je     8003ef <getint+0x35>
		return va_arg(*ap, long);
  8003dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e8:	89 0a                	mov    %ecx,(%edx)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	99                   	cltd   
  8003ed:	eb 10                	jmp    8003ff <getint+0x45>
	else
		return va_arg(*ap, int);
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fa:	89 0a                	mov    %ecx,(%edx)
  8003fc:	8b 00                	mov    (%eax),%eax
  8003fe:	99                   	cltd   
}
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    

00800401 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800409:	eb 18                	jmp    800423 <vprintfmt+0x22>
			if (ch == '\0')
  80040b:	85 db                	test   %ebx,%ebx
  80040d:	75 05                	jne    800414 <vprintfmt+0x13>
				return;
  80040f:	e9 cc 03 00 00       	jmp    8007e0 <vprintfmt+0x3df>
			putch(ch, putdat);
  800414:	8b 45 0c             	mov    0xc(%ebp),%eax
  800417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041b:	89 1c 24             	mov    %ebx,(%esp)
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800423:	8b 45 10             	mov    0x10(%ebp),%eax
  800426:	8d 50 01             	lea    0x1(%eax),%edx
  800429:	89 55 10             	mov    %edx,0x10(%ebp)
  80042c:	0f b6 00             	movzbl (%eax),%eax
  80042f:	0f b6 d8             	movzbl %al,%ebx
  800432:	83 fb 25             	cmp    $0x25,%ebx
  800435:	75 d4                	jne    80040b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800437:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80043b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800442:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800449:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800450:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 45 10             	mov    0x10(%ebp),%eax
  80045a:	8d 50 01             	lea    0x1(%eax),%edx
  80045d:	89 55 10             	mov    %edx,0x10(%ebp)
  800460:	0f b6 00             	movzbl (%eax),%eax
  800463:	0f b6 d8             	movzbl %al,%ebx
  800466:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800469:	83 f8 55             	cmp    $0x55,%eax
  80046c:	0f 87 3d 03 00 00    	ja     8007af <vprintfmt+0x3ae>
  800472:	8b 04 85 8c 17 80 00 	mov    0x80178c(,%eax,4),%eax
  800479:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80047b:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80047f:	eb d6                	jmp    800457 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800481:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800485:	eb d0                	jmp    800457 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800487:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80048e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800491:	89 d0                	mov    %edx,%eax
  800493:	c1 e0 02             	shl    $0x2,%eax
  800496:	01 d0                	add    %edx,%eax
  800498:	01 c0                	add    %eax,%eax
  80049a:	01 d8                	add    %ebx,%eax
  80049c:	83 e8 30             	sub    $0x30,%eax
  80049f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a5:	0f b6 00             	movzbl (%eax),%eax
  8004a8:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004ab:	83 fb 2f             	cmp    $0x2f,%ebx
  8004ae:	7e 0b                	jle    8004bb <vprintfmt+0xba>
  8004b0:	83 fb 39             	cmp    $0x39,%ebx
  8004b3:	7f 06                	jg     8004bb <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b9:	eb d3                	jmp    80048e <vprintfmt+0x8d>
			goto process_precision;
  8004bb:	eb 33                	jmp    8004f0 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004cb:	eb 23                	jmp    8004f0 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d1:	79 0c                	jns    8004df <vprintfmt+0xde>
				width = 0;
  8004d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004da:	e9 78 ff ff ff       	jmp    800457 <vprintfmt+0x56>
  8004df:	e9 73 ff ff ff       	jmp    800457 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004e4:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004eb:	e9 67 ff ff ff       	jmp    800457 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8004f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f4:	79 12                	jns    800508 <vprintfmt+0x107>
				width = precision, precision = -1;
  8004f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800503:	e9 4f ff ff ff       	jmp    800457 <vprintfmt+0x56>
  800508:	e9 4a ff ff ff       	jmp    800457 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800511:	e9 41 ff ff ff       	jmp    800457 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	8b 55 0c             	mov    0xc(%ebp),%edx
  800524:	89 54 24 04          	mov    %edx,0x4(%esp)
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	8b 45 08             	mov    0x8(%ebp),%eax
  80052e:	ff d0                	call   *%eax
			break;
  800530:	e9 a5 02 00 00       	jmp    8007da <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800540:	85 db                	test   %ebx,%ebx
  800542:	79 02                	jns    800546 <vprintfmt+0x145>
				err = -err;
  800544:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 fb 09             	cmp    $0x9,%ebx
  800549:	7f 0b                	jg     800556 <vprintfmt+0x155>
  80054b:	8b 34 9d 40 17 80 00 	mov    0x801740(,%ebx,4),%esi
  800552:	85 f6                	test   %esi,%esi
  800554:	75 23                	jne    800579 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800556:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80055a:	c7 44 24 08 79 17 80 	movl   $0x801779,0x8(%esp)
  800561:	00 
  800562:	8b 45 0c             	mov    0xc(%ebp),%eax
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	8b 45 08             	mov    0x8(%ebp),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	e8 73 02 00 00       	call   8007e7 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800574:	e9 61 02 00 00       	jmp    8007da <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800579:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80057d:	c7 44 24 08 82 17 80 	movl   $0x801782,0x8(%esp)
  800584:	00 
  800585:	8b 45 0c             	mov    0xc(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	e8 50 02 00 00       	call   8007e7 <printfmt>
			break;
  800597:	e9 3e 02 00 00       	jmp    8007da <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 30                	mov    (%eax),%esi
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	75 05                	jne    8005b0 <vprintfmt+0x1af>
				p = "(null)";
  8005ab:	be 85 17 80 00       	mov    $0x801785,%esi
			if (width > 0 && padc != '-')
  8005b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b4:	7e 37                	jle    8005ed <vprintfmt+0x1ec>
  8005b6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005ba:	74 31                	je     8005ed <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c3:	89 34 24             	mov    %esi,(%esp)
  8005c6:	e8 39 03 00 00       	call   800904 <strnlen>
  8005cb:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005ce:	eb 17                	jmp    8005e7 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005d0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e1:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005eb:	7f e3                	jg     8005d0 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ed:	eb 38                	jmp    800627 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f3:	74 1f                	je     800614 <vprintfmt+0x213>
  8005f5:	83 fb 1f             	cmp    $0x1f,%ebx
  8005f8:	7e 05                	jle    8005ff <vprintfmt+0x1fe>
  8005fa:	83 fb 7e             	cmp    $0x7e,%ebx
  8005fd:	7e 15                	jle    800614 <vprintfmt+0x213>
					putch('?', putdat);
  8005ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800602:	89 44 24 04          	mov    %eax,0x4(%esp)
  800606:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	ff d0                	call   *%eax
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800614:	8b 45 0c             	mov    0xc(%ebp),%eax
  800617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061b:	89 1c 24             	mov    %ebx,(%esp)
  80061e:	8b 45 08             	mov    0x8(%ebp),%eax
  800621:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800623:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800627:	89 f0                	mov    %esi,%eax
  800629:	8d 70 01             	lea    0x1(%eax),%esi
  80062c:	0f b6 00             	movzbl (%eax),%eax
  80062f:	0f be d8             	movsbl %al,%ebx
  800632:	85 db                	test   %ebx,%ebx
  800634:	74 10                	je     800646 <vprintfmt+0x245>
  800636:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80063a:	78 b3                	js     8005ef <vprintfmt+0x1ee>
  80063c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800640:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800644:	79 a9                	jns    8005ef <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800646:	eb 17                	jmp    80065f <vprintfmt+0x25e>
				putch(' ', putdat);
  800648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800656:	8b 45 08             	mov    0x8(%ebp),%eax
  800659:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80065f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800663:	7f e3                	jg     800648 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800665:	e9 70 01 00 00       	jmp    8007da <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80066d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	e8 3e fd ff ff       	call   8003ba <getint>
  80067c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80067f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800688:	85 d2                	test   %edx,%edx
  80068a:	79 26                	jns    8006b2 <vprintfmt+0x2b1>
				putch('-', putdat);
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800693:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	ff d0                	call   *%eax
				num = -(long long) num;
  80069f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a5:	f7 d8                	neg    %eax
  8006a7:	83 d2 00             	adc    $0x0,%edx
  8006aa:	f7 da                	neg    %edx
  8006ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006af:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006b2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006b9:	e9 a8 00 00 00       	jmp    800766 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006be:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	e8 9b fc ff ff       	call   80036b <getuint>
  8006d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006d6:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006dd:	e9 84 00 00 00       	jmp    800766 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	e8 77 fc ff ff       	call   80036b <getuint>
  8006f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8006fa:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800701:	eb 63                	jmp    800766 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800703:	8b 45 0c             	mov    0xc(%ebp),%eax
  800706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	ff d0                	call   *%eax
			putch('x', putdat);
  800716:	8b 45 0c             	mov    0xc(%ebp),%eax
  800719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8d 50 04             	lea    0x4(%eax),%edx
  80072f:	89 55 14             	mov    %edx,0x14(%ebp)
  800732:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800734:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800737:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800745:	eb 1f                	jmp    800766 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800747:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	8d 45 14             	lea    0x14(%ebp),%eax
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 12 fc ff ff       	call   80036b <getuint>
  800759:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80075c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80075f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800766:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80076a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076d:	89 54 24 18          	mov    %edx,0x18(%esp)
  800771:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800774:	89 54 24 14          	mov    %edx,0x14(%esp)
  800778:	89 44 24 10          	mov    %eax,0x10(%esp)
  80077c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800782:	89 44 24 08          	mov    %eax,0x8(%esp)
  800786:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	e8 f1 fa ff ff       	call   80028d <printnum>
			break;
  80079c:	eb 3c                	jmp    8007da <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	89 1c 24             	mov    %ebx,(%esp)
  8007a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ab:	ff d0                	call   *%eax
			break;
  8007ad:	eb 2b                	jmp    8007da <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007c6:	eb 04                	jmp    8007cc <vprintfmt+0x3cb>
  8007c8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cf:	83 e8 01             	sub    $0x1,%eax
  8007d2:	0f b6 00             	movzbl (%eax),%eax
  8007d5:	3c 25                	cmp    $0x25,%al
  8007d7:	75 ef                	jne    8007c8 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8007d9:	90                   	nop
		}
	}
  8007da:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007db:	e9 43 fc ff ff       	jmp    800423 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007e0:	83 c4 40             	add    $0x40,%esp
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800801:	8b 45 0c             	mov    0xc(%ebp),%eax
  800804:	89 44 24 04          	mov    %eax,0x4(%esp)
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	e8 ee fb ff ff       	call   800401 <vprintfmt>
	va_end(ap);
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081b:	8b 40 08             	mov    0x8(%eax),%eax
  80081e:	8d 50 01             	lea    0x1(%eax),%edx
  800821:	8b 45 0c             	mov    0xc(%ebp),%eax
  800824:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082f:	8b 40 04             	mov    0x4(%eax),%eax
  800832:	39 c2                	cmp    %eax,%edx
  800834:	73 12                	jae    800848 <sprintputch+0x33>
		*b->buf++ = ch;
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	8b 00                	mov    (%eax),%eax
  80083b:	8d 48 01             	lea    0x1(%eax),%ecx
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 0a                	mov    %ecx,(%edx)
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
  800846:	88 10                	mov    %dl,(%eax)
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	8d 50 ff             	lea    -0x1(%eax),%edx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	01 d0                	add    %edx,%eax
  800861:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80086f:	74 06                	je     800877 <vsnprintf+0x2d>
  800871:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800875:	7f 07                	jg     80087e <vsnprintf+0x34>
		return -E_INVAL;
  800877:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087c:	eb 2a                	jmp    8008a8 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800885:	8b 45 10             	mov    0x10(%ebp),%eax
  800888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	c7 04 24 15 08 80 00 	movl   $0x800815,(%esp)
  80089a:	e8 62 fb ff ff       	call   800401 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	89 04 24             	mov    %eax,(%esp)
  8008d1:	e8 74 ff ff ff       	call   80084a <vsnprintf>
  8008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008eb:	eb 08                	jmp    8008f5 <strlen+0x17>
		n++;
  8008ed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	84 c0                	test   %al,%al
  8008fd:	75 ee                	jne    8008ed <strlen+0xf>
		n++;
	return n;
  8008ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800911:	eb 0c                	jmp    80091f <strnlen+0x1b>
		n++;
  800913:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800917:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80091b:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80091f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800923:	74 0a                	je     80092f <strnlen+0x2b>
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	0f b6 00             	movzbl (%eax),%eax
  80092b:	84 c0                	test   %al,%al
  80092d:	75 e4                	jne    800913 <strnlen+0xf>
		n++;
	return n;
  80092f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800940:	90                   	nop
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8d 50 01             	lea    0x1(%eax),%edx
  800947:	89 55 08             	mov    %edx,0x8(%ebp)
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800950:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	88 10                	mov    %dl,(%eax)
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	84 c0                	test   %al,%al
  80095d:	75 e2                	jne    800941 <strcpy+0xd>
		/* do nothing */;
	return ret;
  80095f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	e8 69 ff ff ff       	call   8008de <strlen>
  800975:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800978:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	01 c2                	add    %eax,%edx
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
  800983:	89 44 24 04          	mov    %eax,0x4(%esp)
  800987:	89 14 24             	mov    %edx,(%esp)
  80098a:	e8 a5 ff ff ff       	call   800934 <strcpy>
	return dst;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009a7:	eb 23                	jmp    8009cc <strncpy+0x38>
		*dst++ = *src;
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8d 50 01             	lea    0x1(%eax),%edx
  8009af:	89 55 08             	mov    %edx,0x8(%ebp)
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b5:	0f b6 12             	movzbl (%edx),%edx
  8009b8:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	0f b6 00             	movzbl (%eax),%eax
  8009c0:	84 c0                	test   %al,%al
  8009c2:	74 04                	je     8009c8 <strncpy+0x34>
			src++;
  8009c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009cf:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009d2:	72 d5                	jb     8009a9 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009e9:	74 33                	je     800a1e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009eb:	eb 17                	jmp    800a04 <strlcpy+0x2b>
			*dst++ = *src++;
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8d 50 01             	lea    0x1(%eax),%edx
  8009f3:	89 55 08             	mov    %edx,0x8(%ebp)
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009fc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009ff:	0f b6 12             	movzbl (%edx),%edx
  800a02:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a04:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a0c:	74 0a                	je     800a18 <strlcpy+0x3f>
  800a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a11:	0f b6 00             	movzbl (%eax),%eax
  800a14:	84 c0                	test   %al,%al
  800a16:	75 d5                	jne    8009ed <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a24:	29 c2                	sub    %eax,%edx
  800a26:	89 d0                	mov    %edx,%eax
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a2d:	eb 08                	jmp    800a37 <strcmp+0xd>
		p++, q++;
  800a2f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a33:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	0f b6 00             	movzbl (%eax),%eax
  800a3d:	84 c0                	test   %al,%al
  800a3f:	74 10                	je     800a51 <strcmp+0x27>
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	0f b6 10             	movzbl (%eax),%edx
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	0f b6 00             	movzbl (%eax),%eax
  800a4d:	38 c2                	cmp    %al,%dl
  800a4f:	74 de                	je     800a2f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 00             	movzbl (%eax),%eax
  800a57:	0f b6 d0             	movzbl %al,%edx
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	0f b6 00             	movzbl (%eax),%eax
  800a60:	0f b6 c0             	movzbl %al,%eax
  800a63:	29 c2                	sub    %eax,%edx
  800a65:	89 d0                	mov    %edx,%eax
}
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a6c:	eb 0c                	jmp    800a7a <strncmp+0x11>
		n--, p++, q++;
  800a6e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a76:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a7e:	74 1a                	je     800a9a <strncmp+0x31>
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	0f b6 00             	movzbl (%eax),%eax
  800a86:	84 c0                	test   %al,%al
  800a88:	74 10                	je     800a9a <strncmp+0x31>
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a93:	0f b6 00             	movzbl (%eax),%eax
  800a96:	38 c2                	cmp    %al,%dl
  800a98:	74 d4                	je     800a6e <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9e:	75 07                	jne    800aa7 <strncmp+0x3e>
		return 0;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa5:	eb 16                	jmp    800abd <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	0f b6 00             	movzbl (%eax),%eax
  800aad:	0f b6 d0             	movzbl %al,%edx
  800ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab3:	0f b6 00             	movzbl (%eax),%eax
  800ab6:	0f b6 c0             	movzbl %al,%eax
  800ab9:	29 c2                	sub    %eax,%edx
  800abb:	89 d0                	mov    %edx,%eax
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	83 ec 04             	sub    $0x4,%esp
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800acb:	eb 14                	jmp    800ae1 <strchr+0x22>
		if (*s == c)
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	0f b6 00             	movzbl (%eax),%eax
  800ad3:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ad6:	75 05                	jne    800add <strchr+0x1e>
			return (char *) s;
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	eb 13                	jmp    800af0 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800add:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	0f b6 00             	movzbl (%eax),%eax
  800ae7:	84 c0                	test   %al,%al
  800ae9:	75 e2                	jne    800acd <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	83 ec 04             	sub    $0x4,%esp
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800afe:	eb 11                	jmp    800b11 <strfind+0x1f>
		if (*s == c)
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	0f b6 00             	movzbl (%eax),%eax
  800b06:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b09:	75 02                	jne    800b0d <strfind+0x1b>
			break;
  800b0b:	eb 0e                	jmp    800b1b <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b0d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	0f b6 00             	movzbl (%eax),%eax
  800b17:	84 c0                	test   %al,%al
  800b19:	75 e5                	jne    800b00 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b28:	75 05                	jne    800b2f <memset+0xf>
		return v;
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	eb 5c                	jmp    800b8b <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	83 e0 03             	and    $0x3,%eax
  800b35:	85 c0                	test   %eax,%eax
  800b37:	75 41                	jne    800b7a <memset+0x5a>
  800b39:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3c:	83 e0 03             	and    $0x3,%eax
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	75 37                	jne    800b7a <memset+0x5a>
		c &= 0xFF;
  800b43:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	c1 e0 18             	shl    $0x18,%eax
  800b50:	89 c2                	mov    %eax,%edx
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	c1 e0 10             	shl    $0x10,%eax
  800b58:	09 c2                	or     %eax,%edx
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	c1 e0 08             	shl    $0x8,%eax
  800b60:	09 d0                	or     %edx,%eax
  800b62:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b65:	8b 45 10             	mov    0x10(%ebp),%eax
  800b68:	c1 e8 02             	shr    $0x2,%eax
  800b6b:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	fc                   	cld    
  800b76:	f3 ab                	rep stos %eax,%es:(%edi)
  800b78:	eb 0e                	jmp    800b88 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b80:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b83:	89 d7                	mov    %edx,%edi
  800b85:	fc                   	cld    
  800b86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ba9:	73 6d                	jae    800c18 <memmove+0x8a>
  800bab:	8b 45 10             	mov    0x10(%ebp),%eax
  800bae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bb1:	01 d0                	add    %edx,%eax
  800bb3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bb6:	76 60                	jbe    800c18 <memmove+0x8a>
		s += n;
  800bb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbb:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc1:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc7:	83 e0 03             	and    $0x3,%eax
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	75 2f                	jne    800bfd <memmove+0x6f>
  800bce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bd1:	83 e0 03             	and    $0x3,%eax
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	75 25                	jne    800bfd <memmove+0x6f>
  800bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdb:	83 e0 03             	and    $0x3,%eax
  800bde:	85 c0                	test   %eax,%eax
  800be0:	75 1b                	jne    800bfd <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be5:	83 e8 04             	sub    $0x4,%eax
  800be8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800beb:	83 ea 04             	sub    $0x4,%edx
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bf1:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	fd                   	std    
  800bf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfb:	eb 18                	jmp    800c15 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c00:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c06:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c09:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0c:	89 d7                	mov    %edx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	89 c1                	mov    %eax,%ecx
  800c12:	fd                   	std    
  800c13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c15:	fc                   	cld    
  800c16:	eb 45                	jmp    800c5d <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1b:	83 e0 03             	and    $0x3,%eax
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	75 2b                	jne    800c4d <memmove+0xbf>
  800c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c25:	83 e0 03             	and    $0x3,%eax
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	75 21                	jne    800c4d <memmove+0xbf>
  800c2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2f:	83 e0 03             	and    $0x3,%eax
  800c32:	85 c0                	test   %eax,%eax
  800c34:	75 17                	jne    800c4d <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c36:	8b 45 10             	mov    0x10(%ebp),%eax
  800c39:	c1 e8 02             	shr    $0x2,%eax
  800c3c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c41:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c44:	89 c7                	mov    %eax,%edi
  800c46:	89 d6                	mov    %edx,%esi
  800c48:	fc                   	cld    
  800c49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4b:	eb 10                	jmp    800c5d <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c53:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	fc                   	cld    
  800c5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	89 04 24             	mov    %eax,(%esp)
  800c82:	e8 07 ff ff ff       	call   800b8e <memmove>
}
  800c87:	c9                   	leave  
  800c88:	c3                   	ret    

00800c89 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c98:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c9b:	eb 30                	jmp    800ccd <memcmp+0x44>
		if (*s1 != *s2)
  800c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ca0:	0f b6 10             	movzbl (%eax),%edx
  800ca3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ca6:	0f b6 00             	movzbl (%eax),%eax
  800ca9:	38 c2                	cmp    %al,%dl
  800cab:	74 18                	je     800cc5 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cb0:	0f b6 00             	movzbl (%eax),%eax
  800cb3:	0f b6 d0             	movzbl %al,%edx
  800cb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cb9:	0f b6 00             	movzbl (%eax),%eax
  800cbc:	0f b6 c0             	movzbl %al,%eax
  800cbf:	29 c2                	sub    %eax,%edx
  800cc1:	89 d0                	mov    %edx,%eax
  800cc3:	eb 1a                	jmp    800cdf <memcmp+0x56>
		s1++, s2++;
  800cc5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cc9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cd3:	89 55 10             	mov    %edx,0x10(%ebp)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	75 c3                	jne    800c9d <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdf:	c9                   	leave  
  800ce0:	c3                   	ret    

00800ce1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ce7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	01 d0                	add    %edx,%eax
  800cef:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800cf2:	eb 13                	jmp    800d07 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	0f b6 10             	movzbl (%eax),%edx
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	38 c2                	cmp    %al,%dl
  800cff:	75 02                	jne    800d03 <memfind+0x22>
			break;
  800d01:	eb 0c                	jmp    800d0f <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d03:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d0d:	72 e5                	jb     800cf4 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d1a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d21:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d28:	eb 04                	jmp    800d2e <strtol+0x1a>
		s++;
  800d2a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	0f b6 00             	movzbl (%eax),%eax
  800d34:	3c 20                	cmp    $0x20,%al
  800d36:	74 f2                	je     800d2a <strtol+0x16>
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	0f b6 00             	movzbl (%eax),%eax
  800d3e:	3c 09                	cmp    $0x9,%al
  800d40:	74 e8                	je     800d2a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	0f b6 00             	movzbl (%eax),%eax
  800d48:	3c 2b                	cmp    $0x2b,%al
  800d4a:	75 06                	jne    800d52 <strtol+0x3e>
		s++;
  800d4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d50:	eb 15                	jmp    800d67 <strtol+0x53>
	else if (*s == '-')
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	0f b6 00             	movzbl (%eax),%eax
  800d58:	3c 2d                	cmp    $0x2d,%al
  800d5a:	75 0b                	jne    800d67 <strtol+0x53>
		s++, neg = 1;
  800d5c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d60:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d6b:	74 06                	je     800d73 <strtol+0x5f>
  800d6d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d71:	75 24                	jne    800d97 <strtol+0x83>
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	0f b6 00             	movzbl (%eax),%eax
  800d79:	3c 30                	cmp    $0x30,%al
  800d7b:	75 1a                	jne    800d97 <strtol+0x83>
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	83 c0 01             	add    $0x1,%eax
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	3c 78                	cmp    $0x78,%al
  800d88:	75 0d                	jne    800d97 <strtol+0x83>
		s += 2, base = 16;
  800d8a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d8e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d95:	eb 2a                	jmp    800dc1 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9b:	75 17                	jne    800db4 <strtol+0xa0>
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	0f b6 00             	movzbl (%eax),%eax
  800da3:	3c 30                	cmp    $0x30,%al
  800da5:	75 0d                	jne    800db4 <strtol+0xa0>
		s++, base = 8;
  800da7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dab:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800db2:	eb 0d                	jmp    800dc1 <strtol+0xad>
	else if (base == 0)
  800db4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db8:	75 07                	jne    800dc1 <strtol+0xad>
		base = 10;
  800dba:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	0f b6 00             	movzbl (%eax),%eax
  800dc7:	3c 2f                	cmp    $0x2f,%al
  800dc9:	7e 1b                	jle    800de6 <strtol+0xd2>
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	0f b6 00             	movzbl (%eax),%eax
  800dd1:	3c 39                	cmp    $0x39,%al
  800dd3:	7f 11                	jg     800de6 <strtol+0xd2>
			dig = *s - '0';
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	0f b6 00             	movzbl (%eax),%eax
  800ddb:	0f be c0             	movsbl %al,%eax
  800dde:	83 e8 30             	sub    $0x30,%eax
  800de1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800de4:	eb 48                	jmp    800e2e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	0f b6 00             	movzbl (%eax),%eax
  800dec:	3c 60                	cmp    $0x60,%al
  800dee:	7e 1b                	jle    800e0b <strtol+0xf7>
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	3c 7a                	cmp    $0x7a,%al
  800df8:	7f 11                	jg     800e0b <strtol+0xf7>
			dig = *s - 'a' + 10;
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	0f be c0             	movsbl %al,%eax
  800e03:	83 e8 57             	sub    $0x57,%eax
  800e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e09:	eb 23                	jmp    800e2e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	0f b6 00             	movzbl (%eax),%eax
  800e11:	3c 40                	cmp    $0x40,%al
  800e13:	7e 3d                	jle    800e52 <strtol+0x13e>
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	3c 5a                	cmp    $0x5a,%al
  800e1d:	7f 33                	jg     800e52 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	0f b6 00             	movzbl (%eax),%eax
  800e25:	0f be c0             	movsbl %al,%eax
  800e28:	83 e8 37             	sub    $0x37,%eax
  800e2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e31:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e34:	7c 02                	jl     800e38 <strtol+0x124>
			break;
  800e36:	eb 1a                	jmp    800e52 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e48:	01 d0                	add    %edx,%eax
  800e4a:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e4d:	e9 6f ff ff ff       	jmp    800dc1 <strtol+0xad>

	if (endptr)
  800e52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e56:	74 08                	je     800e60 <strtol+0x14c>
		*endptr = (char *) s;
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e60:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e64:	74 07                	je     800e6d <strtol+0x159>
  800e66:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e69:	f7 d8                	neg    %eax
  800e6b:	eb 03                	jmp    800e70 <strtol+0x15c>
  800e6d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    

00800e72 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	8b 55 10             	mov    0x10(%ebp),%edx
  800e81:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e84:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e87:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e8a:	8b 75 20             	mov    0x20(%ebp),%esi
  800e8d:	cd 30                	int    $0x30
  800e8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e96:	74 30                	je     800ec8 <syscall+0x56>
  800e98:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e9c:	7e 2a                	jle    800ec8 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eac:	c7 44 24 08 e4 18 80 	movl   $0x8018e4,0x8(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebb:	00 
  800ebc:	c7 04 24 01 19 80 00 	movl   $0x801901,(%esp)
  800ec3:	e8 84 f2 ff ff       	call   80014c <_panic>

	return ret;
  800ec8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800ecb:	83 c4 3c             	add    $0x3c,%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  800edc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800eeb:	00 
  800eec:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ef3:	00 
  800ef4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800efb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f06:	00 
  800f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f0e:	e8 5f ff ff ff       	call   800e72 <syscall>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f1b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f22:	00 
  800f23:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f32:	00 
  800f33:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f42:	00 
  800f43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f4a:	00 
  800f4b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f52:	e8 1b ff ff ff       	call   800e72 <syscall>
}
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f69:	00 
  800f6a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f71:	00 
  800f72:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f79:	00 
  800f7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f81:	00 
  800f82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f86:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f8d:	00 
  800f8e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f95:	e8 d8 fe ff ff       	call   800e72 <syscall>
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fa2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fa9:	00 
  800faa:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fb9:	00 
  800fba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd1:	00 
  800fd2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fd9:	e8 94 fe ff ff       	call   800e72 <syscall>
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <sys_yield>:

void
sys_yield(void)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fe6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fed:	00 
  800fee:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ff5:	00 
  800ff6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ffd:	00 
  800ffe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801005:	00 
  801006:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80100d:	00 
  80100e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801015:	00 
  801016:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80101d:	e8 50 fe ff ff       	call   800e72 <syscall>
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80102a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80102d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80103a:	00 
  80103b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801042:	00 
  801043:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801047:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80104b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801056:	00 
  801057:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80105e:	e8 0f fe ff ff       	call   800e72 <syscall>
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	56                   	push   %esi
  801069:	53                   	push   %ebx
  80106a:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80106d:	8b 75 18             	mov    0x18(%ebp),%esi
  801070:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801073:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801076:	8b 55 0c             	mov    0xc(%ebp),%edx
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801080:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801084:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801088:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80108c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801090:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801097:	00 
  801098:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  80109f:	e8 ce fd ff ff       	call   800e72 <syscall>
}
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010be:	00 
  8010bf:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010ce:	00 
  8010cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010de:	00 
  8010df:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010e6:	e8 87 fd ff ff       	call   800e72 <syscall>
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    

008010ed <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801100:	00 
  801101:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801108:	00 
  801109:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801110:	00 
  801111:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801115:	89 44 24 08          	mov    %eax,0x8(%esp)
  801119:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801120:	00 
  801121:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801128:	e8 45 fd ff ff       	call   800e72 <syscall>
}
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801135:	8b 55 0c             	mov    0xc(%ebp),%edx
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801142:	00 
  801143:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80114a:	00 
  80114b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801152:	00 
  801153:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801162:	00 
  801163:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80116a:	e8 03 fd ff ff       	call   800e72 <syscall>
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801177:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80117a:	8b 55 10             	mov    0x10(%ebp),%edx
  80117d:	8b 45 08             	mov    0x8(%ebp),%eax
  801180:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801187:	00 
  801188:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80118c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801190:	8b 55 0c             	mov    0xc(%ebp),%edx
  801193:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801197:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011a2:	00 
  8011a3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011aa:	e8 c3 fc ff ff       	call   800e72 <syscall>
}
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011c9:	00 
  8011ca:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011d1:	00 
  8011d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011d9:	00 
  8011da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011de:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011e5:	00 
  8011e6:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011ed:	e8 80 fc ff ff       	call   800e72 <syscall>
}
  8011f2:	c9                   	leave  
  8011f3:	c3                   	ret    

008011f4 <sys_exec>:

void sys_exec(char* buf){
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  8011fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801204:	00 
  801205:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80120c:	00 
  80120d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801214:	00 
  801215:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80121c:	00 
  80121d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801221:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801230:	e8 3d fc ff ff       	call   800e72 <syscall>
}
  801235:	c9                   	leave  
  801236:	c3                   	ret    

00801237 <sys_wait>:

void sys_wait(){
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80123d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801244:	00 
  801245:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80124c:	00 
  80124d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801254:	00 
  801255:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80125c:	00 
  80125d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801264:	00 
  801265:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80126c:	00 
  80126d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801274:	e8 f9 fb ff ff       	call   800e72 <syscall>
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <sys_guest>:

void sys_guest(){
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  801281:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801288:	00 
  801289:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801290:	00 
  801291:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801298:	00 
  801299:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012a0:	00 
  8012a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8012b8:	e8 b5 fb ff ff       	call   800e72 <syscall>
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012c5:	a1 08 20 80 00       	mov    0x802008,%eax
  8012ca:	85 c0                	test   %eax,%eax
  8012cc:	75 5d                	jne    80132b <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8012ce:	a1 04 20 80 00       	mov    0x802004,%eax
  8012d3:	8b 40 48             	mov    0x48(%eax),%eax
  8012d6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012e5:	ee 
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 36 fd ff ff       	call   801024 <sys_page_alloc>
  8012ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8012f5:	79 1c                	jns    801313 <set_pgfault_handler+0x54>
  8012f7:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801306:	00 
  801307:	c7 04 24 3c 19 80 00 	movl   $0x80193c,(%esp)
  80130e:	e8 39 ee ff ff       	call   80014c <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801313:	a1 04 20 80 00       	mov    0x802004,%eax
  801318:	8b 40 48             	mov    0x48(%eax),%eax
  80131b:	c7 44 24 04 35 13 80 	movl   $0x801335,0x4(%esp)
  801322:	00 
  801323:	89 04 24             	mov    %eax,(%esp)
  801326:	e8 04 fe ff ff       	call   80112f <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80132b:	8b 45 08             	mov    0x8(%ebp),%eax
  80132e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801335:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801336:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80133b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133d:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801340:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801344:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801346:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80134a:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80134b:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80134e:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801350:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801351:	58                   	pop    %eax
	popal 						// pop all the registers
  801352:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801353:	83 c4 04             	add    $0x4,%esp
	popfl
  801356:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801357:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801358:	c3                   	ret    
  801359:	66 90                	xchg   %ax,%ax
  80135b:	66 90                	xchg   %ax,%ax
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
