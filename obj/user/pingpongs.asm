
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 31 01 00 00       	call   800162 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
  80003c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if ((who = sfork()) != 0) {
  800043:	e8 80 16 00 00       	call   8016c8 <sfork>
  800048:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80004b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80004e:	85 c0                	test   %eax,%eax
  800050:	74 5e                	je     8000b0 <umain+0x7d>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800052:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  800058:	e8 5d 0f 00 00       	call   800fba <sys_getenvid>
  80005d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800061:	89 44 24 04          	mov    %eax,0x4(%esp)
  800065:	c7 04 24 00 1c 80 00 	movl   $0x801c00,(%esp)
  80006c:	e8 14 02 00 00       	call   800285 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800071:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800074:	e8 41 0f 00 00       	call   800fba <sys_getenvid>
  800079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	c7 04 24 1a 1c 80 00 	movl   $0x801c1a,(%esp)
  800088:	e8 f8 01 00 00       	call   800285 <cprintf>
		ipc_send(who, 0, 0, 0);
  80008d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800090:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800097:	00 
  800098:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009f:	00 
  8000a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000a7:	00 
  8000a8:	89 04 24             	mov    %eax,(%esp)
  8000ab:	e8 d8 16 00 00       	call   801788 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bf:	00 
  8000c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8000c3:	89 04 24             	mov    %eax,(%esp)
  8000c6:	e8 1f 16 00 00       	call   8016ea <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000cb:	a1 08 30 80 00       	mov    0x803008,%eax
  8000d0:	8b 40 48             	mov    0x48(%eax),%eax
  8000d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d6:	8b 3d 08 30 80 00    	mov    0x803008,%edi
  8000dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8000df:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8000e5:	e8 d0 0e 00 00       	call   800fba <sys_getenvid>
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000ed:	89 54 24 14          	mov    %edx,0x14(%esp)
  8000f1:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8000f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 30 1c 80 00 	movl   $0x801c30,(%esp)
  800108:	e8 78 01 00 00       	call   800285 <cprintf>
		if (val == 10)
  80010d:	a1 04 30 80 00       	mov    0x803004,%eax
  800112:	83 f8 0a             	cmp    $0xa,%eax
  800115:	75 02                	jne    800119 <umain+0xe6>
			return;
  800117:	eb 41                	jmp    80015a <umain+0x127>
		++val;
  800119:	a1 04 30 80 00       	mov    0x803004,%eax
  80011e:	83 c0 01             	add    $0x1,%eax
  800121:	a3 04 30 80 00       	mov    %eax,0x803004
		ipc_send(who, 0, 0, 0);
  800126:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800129:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800130:	00 
  800131:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800138:	00 
  800139:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800140:	00 
  800141:	89 04 24             	mov    %eax,(%esp)
  800144:	e8 3f 16 00 00       	call   801788 <ipc_send>
		if (val == 10)
  800149:	a1 04 30 80 00       	mov    0x803004,%eax
  80014e:	83 f8 0a             	cmp    $0xa,%eax
  800151:	75 02                	jne    800155 <umain+0x122>
			return;
  800153:	eb 05                	jmp    80015a <umain+0x127>
	}
  800155:	e9 56 ff ff ff       	jmp    8000b0 <umain+0x7d>

}
  80015a:	83 c4 3c             	add    $0x3c,%esp
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800168:	e8 4d 0e 00 00       	call   800fba <sys_getenvid>
  80016d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800172:	c1 e0 02             	shl    $0x2,%eax
  800175:	89 c2                	mov    %eax,%edx
  800177:	c1 e2 05             	shl    $0x5,%edx
  80017a:	29 c2                	sub    %eax,%edx
  80017c:	89 d0                	mov    %edx,%eax
  80017e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800183:	a3 08 30 80 00       	mov    %eax,0x803008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800188:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80018c:	7e 0a                	jle    800198 <libmain+0x36>
		binaryname = argv[0];
  80018e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800191:	8b 00                	mov    (%eax),%eax
  800193:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 89 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001aa:	e8 02 00 00 00       	call   8001b1 <exit>
}
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 b4 0d 00 00       	call   800f77 <sys_env_destroy>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ce:	8b 00                	mov    (%eax),%eax
  8001d0:	8d 48 01             	lea    0x1(%eax),%ecx
  8001d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d6:	89 0a                	mov    %ecx,(%edx)
  8001d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001db:	89 d1                	mov    %edx,%ecx
  8001dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e0:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	8b 00                	mov    (%eax),%eax
  8001e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ee:	75 20                	jne    800210 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	8b 00                	mov    (%eax),%eax
  8001f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f8:	83 c2 08             	add    $0x8,%edx
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	89 14 24             	mov    %edx,(%esp)
  800202:	e8 ea 0c 00 00       	call   800ef1 <sys_cputs>
		b->idx = 0;
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800210:	8b 45 0c             	mov    0xc(%ebp),%eax
  800213:	8b 40 04             	mov    0x4(%eax),%eax
  800216:	8d 50 01             	lea    0x1(%eax),%edx
  800219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80022a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800231:	00 00 00 
	b.cnt = 0;
  800234:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800241:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800252:	89 44 24 04          	mov    %eax,0x4(%esp)
  800256:	c7 04 24 c5 01 80 00 	movl   $0x8001c5,(%esp)
  80025d:	e8 bd 01 00 00       	call   80041f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800262:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800272:	83 c0 08             	add    $0x8,%eax
  800275:	89 04 24             	mov    %eax,(%esp)
  800278:	e8 74 0c 00 00       	call   800ef1 <sys_cputs>

	return b.cnt;
  80027d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80028e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800294:	89 44 24 04          	mov    %eax,0x4(%esp)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	e8 7e ff ff ff       	call   800221 <vcprintf>
  8002a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 34             	sub    $0x34,%esp
  8002b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002be:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002c9:	77 72                	ja     80033d <printnum+0x92>
  8002cb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002ce:	72 05                	jb     8002d5 <printnum+0x2a>
  8002d0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002d3:	77 68                	ja     80033d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002d8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002db:	8b 45 18             	mov    0x18(%ebp),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002f1:	89 04 24             	mov    %eax,(%esp)
  8002f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f8:	e8 73 16 00 00       	call   801970 <__udivdi3>
  8002fd:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800300:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800304:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800308:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80030b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	e8 82 ff ff ff       	call   8002ab <printnum>
  800329:	eb 1c                	jmp    800347 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800332:	8b 45 20             	mov    0x20(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 45 08             	mov    0x8(%ebp),%eax
  80033b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800341:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800345:	7f e4                	jg     80032b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800347:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80034a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800352:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800355:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800359:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	89 54 24 04          	mov    %edx,0x4(%esp)
  800364:	e8 37 17 00 00       	call   801aa0 <__umoddi3>
  800369:	05 28 1d 80 00       	add    $0x801d28,%eax
  80036e:	0f b6 00             	movzbl (%eax),%eax
  800371:	0f be c0             	movsbl %al,%eax
  800374:	8b 55 0c             	mov    0xc(%ebp),%edx
  800377:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	ff d0                	call   *%eax
}
  800383:	83 c4 34             	add    $0x34,%esp
  800386:	5b                   	pop    %ebx
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800390:	7e 14                	jle    8003a6 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 00                	mov    (%eax),%eax
  800397:	8d 48 08             	lea    0x8(%eax),%ecx
  80039a:	8b 55 08             	mov    0x8(%ebp),%edx
  80039d:	89 0a                	mov    %ecx,(%edx)
  80039f:	8b 50 04             	mov    0x4(%eax),%edx
  8003a2:	8b 00                	mov    (%eax),%eax
  8003a4:	eb 30                	jmp    8003d6 <getuint+0x4d>
	else if (lflag)
  8003a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003aa:	74 16                	je     8003c2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	8b 00                	mov    (%eax),%eax
  8003b1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b7:	89 0a                	mov    %ecx,(%edx)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	eb 14                	jmp    8003d6 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cd:	89 0a                	mov    %ecx,(%edx)
  8003cf:	8b 00                	mov    (%eax),%eax
  8003d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003db:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003df:	7e 14                	jle    8003f5 <getint+0x1d>
		return va_arg(*ap, long long);
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	8b 00                	mov    (%eax),%eax
  8003e6:	8d 48 08             	lea    0x8(%eax),%ecx
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	89 0a                	mov    %ecx,(%edx)
  8003ee:	8b 50 04             	mov    0x4(%eax),%edx
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	eb 28                	jmp    80041d <getint+0x45>
	else if (lflag)
  8003f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003f9:	74 12                	je     80040d <getint+0x35>
		return va_arg(*ap, long);
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	8d 48 04             	lea    0x4(%eax),%ecx
  800403:	8b 55 08             	mov    0x8(%ebp),%edx
  800406:	89 0a                	mov    %ecx,(%edx)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	99                   	cltd   
  80040b:	eb 10                	jmp    80041d <getint+0x45>
	else
		return va_arg(*ap, int);
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	8b 00                	mov    (%eax),%eax
  800412:	8d 48 04             	lea    0x4(%eax),%ecx
  800415:	8b 55 08             	mov    0x8(%ebp),%edx
  800418:	89 0a                	mov    %ecx,(%edx)
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	99                   	cltd   
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800427:	eb 18                	jmp    800441 <vprintfmt+0x22>
			if (ch == '\0')
  800429:	85 db                	test   %ebx,%ebx
  80042b:	75 05                	jne    800432 <vprintfmt+0x13>
				return;
  80042d:	e9 cc 03 00 00       	jmp    8007fe <vprintfmt+0x3df>
			putch(ch, putdat);
  800432:	8b 45 0c             	mov    0xc(%ebp),%eax
  800435:	89 44 24 04          	mov    %eax,0x4(%esp)
  800439:	89 1c 24             	mov    %ebx,(%esp)
  80043c:	8b 45 08             	mov    0x8(%ebp),%eax
  80043f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800441:	8b 45 10             	mov    0x10(%ebp),%eax
  800444:	8d 50 01             	lea    0x1(%eax),%edx
  800447:	89 55 10             	mov    %edx,0x10(%ebp)
  80044a:	0f b6 00             	movzbl (%eax),%eax
  80044d:	0f b6 d8             	movzbl %al,%ebx
  800450:	83 fb 25             	cmp    $0x25,%ebx
  800453:	75 d4                	jne    800429 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800455:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800459:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800460:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800467:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80046e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 45 10             	mov    0x10(%ebp),%eax
  800478:	8d 50 01             	lea    0x1(%eax),%edx
  80047b:	89 55 10             	mov    %edx,0x10(%ebp)
  80047e:	0f b6 00             	movzbl (%eax),%eax
  800481:	0f b6 d8             	movzbl %al,%ebx
  800484:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800487:	83 f8 55             	cmp    $0x55,%eax
  80048a:	0f 87 3d 03 00 00    	ja     8007cd <vprintfmt+0x3ae>
  800490:	8b 04 85 4c 1d 80 00 	mov    0x801d4c(,%eax,4),%eax
  800497:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800499:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80049d:	eb d6                	jmp    800475 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004a3:	eb d0                	jmp    800475 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004af:	89 d0                	mov    %edx,%eax
  8004b1:	c1 e0 02             	shl    $0x2,%eax
  8004b4:	01 d0                	add    %edx,%eax
  8004b6:	01 c0                	add    %eax,%eax
  8004b8:	01 d8                	add    %ebx,%eax
  8004ba:	83 e8 30             	sub    $0x30,%eax
  8004bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c3:	0f b6 00             	movzbl (%eax),%eax
  8004c6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004c9:	83 fb 2f             	cmp    $0x2f,%ebx
  8004cc:	7e 0b                	jle    8004d9 <vprintfmt+0xba>
  8004ce:	83 fb 39             	cmp    $0x39,%ebx
  8004d1:	7f 06                	jg     8004d9 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d7:	eb d3                	jmp    8004ac <vprintfmt+0x8d>
			goto process_precision;
  8004d9:	eb 33                	jmp    80050e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004e9:	eb 23                	jmp    80050e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ef:	79 0c                	jns    8004fd <vprintfmt+0xde>
				width = 0;
  8004f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004f8:	e9 78 ff ff ff       	jmp    800475 <vprintfmt+0x56>
  8004fd:	e9 73 ff ff ff       	jmp    800475 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800502:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800509:	e9 67 ff ff ff       	jmp    800475 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	79 12                	jns    800526 <vprintfmt+0x107>
				width = precision, precision = -1;
  800514:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80051a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800521:	e9 4f ff ff ff       	jmp    800475 <vprintfmt+0x56>
  800526:	e9 4a ff ff ff       	jmp    800475 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80052f:	e9 41 ff ff ff       	jmp    800475 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 50 04             	lea    0x4(%eax),%edx
  80053a:	89 55 14             	mov    %edx,0x14(%ebp)
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800542:	89 54 24 04          	mov    %edx,0x4(%esp)
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	8b 45 08             	mov    0x8(%ebp),%eax
  80054c:	ff d0                	call   *%eax
			break;
  80054e:	e9 a5 02 00 00       	jmp    8007f8 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 50 04             	lea    0x4(%eax),%edx
  800559:	89 55 14             	mov    %edx,0x14(%ebp)
  80055c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80055e:	85 db                	test   %ebx,%ebx
  800560:	79 02                	jns    800564 <vprintfmt+0x145>
				err = -err;
  800562:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800564:	83 fb 09             	cmp    $0x9,%ebx
  800567:	7f 0b                	jg     800574 <vprintfmt+0x155>
  800569:	8b 34 9d 00 1d 80 00 	mov    0x801d00(,%ebx,4),%esi
  800570:	85 f6                	test   %esi,%esi
  800572:	75 23                	jne    800597 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800574:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800578:	c7 44 24 08 39 1d 80 	movl   $0x801d39,0x8(%esp)
  80057f:	00 
  800580:	8b 45 0c             	mov    0xc(%ebp),%eax
  800583:	89 44 24 04          	mov    %eax,0x4(%esp)
  800587:	8b 45 08             	mov    0x8(%ebp),%eax
  80058a:	89 04 24             	mov    %eax,(%esp)
  80058d:	e8 73 02 00 00       	call   800805 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800592:	e9 61 02 00 00       	jmp    8007f8 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800597:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80059b:	c7 44 24 08 42 1d 80 	movl   $0x801d42,0x8(%esp)
  8005a2:	00 
  8005a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ad:	89 04 24             	mov    %eax,(%esp)
  8005b0:	e8 50 02 00 00       	call   800805 <printfmt>
			break;
  8005b5:	e9 3e 02 00 00       	jmp    8007f8 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 50 04             	lea    0x4(%eax),%edx
  8005c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c3:	8b 30                	mov    (%eax),%esi
  8005c5:	85 f6                	test   %esi,%esi
  8005c7:	75 05                	jne    8005ce <vprintfmt+0x1af>
				p = "(null)";
  8005c9:	be 45 1d 80 00       	mov    $0x801d45,%esi
			if (width > 0 && padc != '-')
  8005ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d2:	7e 37                	jle    80060b <vprintfmt+0x1ec>
  8005d4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005d8:	74 31                	je     80060b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e1:	89 34 24             	mov    %esi,(%esp)
  8005e4:	e8 39 03 00 00       	call   800922 <strnlen>
  8005e9:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005ec:	eb 17                	jmp    800605 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005ee:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f9:	89 04 24             	mov    %eax,(%esp)
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800605:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800609:	7f e3                	jg     8005ee <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060b:	eb 38                	jmp    800645 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80060d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800611:	74 1f                	je     800632 <vprintfmt+0x213>
  800613:	83 fb 1f             	cmp    $0x1f,%ebx
  800616:	7e 05                	jle    80061d <vprintfmt+0x1fe>
  800618:	83 fb 7e             	cmp    $0x7e,%ebx
  80061b:	7e 15                	jle    800632 <vprintfmt+0x213>
					putch('?', putdat);
  80061d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800620:	89 44 24 04          	mov    %eax,0x4(%esp)
  800624:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062b:	8b 45 08             	mov    0x8(%ebp),%eax
  80062e:	ff d0                	call   *%eax
  800630:	eb 0f                	jmp    800641 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800632:	8b 45 0c             	mov    0xc(%ebp),%eax
  800635:	89 44 24 04          	mov    %eax,0x4(%esp)
  800639:	89 1c 24             	mov    %ebx,(%esp)
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800645:	89 f0                	mov    %esi,%eax
  800647:	8d 70 01             	lea    0x1(%eax),%esi
  80064a:	0f b6 00             	movzbl (%eax),%eax
  80064d:	0f be d8             	movsbl %al,%ebx
  800650:	85 db                	test   %ebx,%ebx
  800652:	74 10                	je     800664 <vprintfmt+0x245>
  800654:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800658:	78 b3                	js     80060d <vprintfmt+0x1ee>
  80065a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80065e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800662:	79 a9                	jns    80060d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800664:	eb 17                	jmp    80067d <vprintfmt+0x25e>
				putch(' ', putdat);
  800666:	8b 45 0c             	mov    0xc(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800679:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80067d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800681:	7f e3                	jg     800666 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800683:	e9 70 01 00 00       	jmp    8007f8 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800688:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80068b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	e8 3e fd ff ff       	call   8003d8 <getint>
  80069a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80069d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a6:	85 d2                	test   %edx,%edx
  8006a8:	79 26                	jns    8006d0 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	ff d0                	call   *%eax
				num = -(long long) num;
  8006bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c3:	f7 d8                	neg    %eax
  8006c5:	83 d2 00             	adc    $0x0,%edx
  8006c8:	f7 da                	neg    %edx
  8006ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006d0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006d7:	e9 a8 00 00 00       	jmp    800784 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	89 04 24             	mov    %eax,(%esp)
  8006e9:	e8 9b fc ff ff       	call   800389 <getuint>
  8006ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006f4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006fb:	e9 84 00 00 00       	jmp    800784 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800700:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800703:	89 44 24 04          	mov    %eax,0x4(%esp)
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	e8 77 fc ff ff       	call   800389 <getuint>
  800712:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800715:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800718:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80071f:	eb 63                	jmp    800784 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	ff d0                	call   *%eax
			putch('x', putdat);
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 50 04             	lea    0x4(%eax),%edx
  80074d:	89 55 14             	mov    %edx,0x14(%ebp)
  800750:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800752:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80075c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800763:	eb 1f                	jmp    800784 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800765:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
  80076f:	89 04 24             	mov    %eax,(%esp)
  800772:	e8 12 fc ff ff       	call   800389 <getuint>
  800777:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80077d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800784:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80078f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800792:	89 54 24 14          	mov    %edx,0x14(%esp)
  800796:	89 44 24 10          	mov    %eax,0x10(%esp)
  80079a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	e8 f1 fa ff ff       	call   8002ab <printnum>
			break;
  8007ba:	eb 3c                	jmp    8007f8 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	89 1c 24             	mov    %ebx,(%esp)
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	ff d0                	call   *%eax
			break;
  8007cb:	eb 2b                	jmp    8007f8 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007e4:	eb 04                	jmp    8007ea <vprintfmt+0x3cb>
  8007e6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ed:	83 e8 01             	sub    $0x1,%eax
  8007f0:	0f b6 00             	movzbl (%eax),%eax
  8007f3:	3c 25                	cmp    $0x25,%al
  8007f5:	75 ef                	jne    8007e6 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8007f7:	90                   	nop
		}
	}
  8007f8:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f9:	e9 43 fc ff ff       	jmp    800441 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007fe:	83 c4 40             	add    $0x40,%esp
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
  80080e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800811:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800814:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800818:	8b 45 10             	mov    0x10(%ebp),%eax
  80081b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800822:	89 44 24 04          	mov    %eax,0x4(%esp)
  800826:	8b 45 08             	mov    0x8(%ebp),%eax
  800829:	89 04 24             	mov    %eax,(%esp)
  80082c:	e8 ee fb ff ff       	call   80041f <vprintfmt>
	va_end(ap);
}
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	8b 40 08             	mov    0x8(%eax),%eax
  80083c:	8d 50 01             	lea    0x1(%eax),%edx
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800842:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	8b 40 04             	mov    0x4(%eax),%eax
  800850:	39 c2                	cmp    %eax,%edx
  800852:	73 12                	jae    800866 <sprintputch+0x33>
		*b->buf++ = ch;
  800854:	8b 45 0c             	mov    0xc(%ebp),%eax
  800857:	8b 00                	mov    (%eax),%eax
  800859:	8d 48 01             	lea    0x1(%eax),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085f:	89 0a                	mov    %ecx,(%edx)
  800861:	8b 55 08             	mov    0x8(%ebp),%edx
  800864:	88 10                	mov    %dl,(%eax)
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	8d 50 ff             	lea    -0x1(%eax),%edx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	01 d0                	add    %edx,%eax
  80087f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800882:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800889:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80088d:	74 06                	je     800895 <vsnprintf+0x2d>
  80088f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800893:	7f 07                	jg     80089c <vsnprintf+0x34>
		return -E_INVAL;
  800895:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089a:	eb 2a                	jmp    8008c6 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	c7 04 24 33 08 80 00 	movl   $0x800833,(%esp)
  8008b8:	e8 62 fb ff ff       	call   80041f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008db:	8b 45 10             	mov    0x10(%ebp),%eax
  8008de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	89 04 24             	mov    %eax,(%esp)
  8008ef:	e8 74 ff ff ff       	call   800868 <vsnprintf>
  8008f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800902:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800909:	eb 08                	jmp    800913 <strlen+0x17>
		n++;
  80090b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80090f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	0f b6 00             	movzbl (%eax),%eax
  800919:	84 c0                	test   %al,%al
  80091b:	75 ee                	jne    80090b <strlen+0xf>
		n++;
	return n;
  80091d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800928:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80092f:	eb 0c                	jmp    80093d <strnlen+0x1b>
		n++;
  800931:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800939:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80093d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800941:	74 0a                	je     80094d <strnlen+0x2b>
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 00             	movzbl (%eax),%eax
  800949:	84 c0                	test   %al,%al
  80094b:	75 e4                	jne    800931 <strnlen+0xf>
		n++;
	return n;
  80094d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80095e:	90                   	nop
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8d 50 01             	lea    0x1(%eax),%edx
  800965:	89 55 08             	mov    %edx,0x8(%ebp)
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800971:	0f b6 12             	movzbl (%edx),%edx
  800974:	88 10                	mov    %dl,(%eax)
  800976:	0f b6 00             	movzbl (%eax),%eax
  800979:	84 c0                	test   %al,%al
  80097b:	75 e2                	jne    80095f <strcpy+0xd>
		/* do nothing */;
	return ret;
  80097d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	e8 69 ff ff ff       	call   8008fc <strlen>
  800993:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800996:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	01 c2                	add    %eax,%edx
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a5:	89 14 24             	mov    %edx,(%esp)
  8009a8:	e8 a5 ff ff ff       	call   800952 <strcpy>
	return dst;
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009c5:	eb 23                	jmp    8009ea <strncpy+0x38>
		*dst++ = *src;
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8d 50 01             	lea    0x1(%eax),%edx
  8009cd:	89 55 08             	mov    %edx,0x8(%ebp)
  8009d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d3:	0f b6 12             	movzbl (%edx),%edx
  8009d6:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	0f b6 00             	movzbl (%eax),%eax
  8009de:	84 c0                	test   %al,%al
  8009e0:	74 04                	je     8009e6 <strncpy+0x34>
			src++;
  8009e2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009ed:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009f0:	72 d5                	jb     8009c7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a07:	74 33                	je     800a3c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a09:	eb 17                	jmp    800a22 <strlcpy+0x2b>
			*dst++ = *src++;
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8d 50 01             	lea    0x1(%eax),%edx
  800a11:	89 55 08             	mov    %edx,0x8(%ebp)
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a17:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a1a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a1d:	0f b6 12             	movzbl (%edx),%edx
  800a20:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a22:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a2a:	74 0a                	je     800a36 <strlcpy+0x3f>
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	0f b6 00             	movzbl (%eax),%eax
  800a32:	84 c0                	test   %al,%al
  800a34:	75 d5                	jne    800a0b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a42:	29 c2                	sub    %eax,%edx
  800a44:	89 d0                	mov    %edx,%eax
}
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a4b:	eb 08                	jmp    800a55 <strcmp+0xd>
		p++, q++;
  800a4d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a51:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	0f b6 00             	movzbl (%eax),%eax
  800a5b:	84 c0                	test   %al,%al
  800a5d:	74 10                	je     800a6f <strcmp+0x27>
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	0f b6 10             	movzbl (%eax),%edx
  800a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a68:	0f b6 00             	movzbl (%eax),%eax
  800a6b:	38 c2                	cmp    %al,%dl
  800a6d:	74 de                	je     800a4d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	0f b6 00             	movzbl (%eax),%eax
  800a75:	0f b6 d0             	movzbl %al,%edx
  800a78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7b:	0f b6 00             	movzbl (%eax),%eax
  800a7e:	0f b6 c0             	movzbl %al,%eax
  800a81:	29 c2                	sub    %eax,%edx
  800a83:	89 d0                	mov    %edx,%eax
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a8a:	eb 0c                	jmp    800a98 <strncmp+0x11>
		n--, p++, q++;
  800a8c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a90:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a94:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a98:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9c:	74 1a                	je     800ab8 <strncmp+0x31>
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 00             	movzbl (%eax),%eax
  800aa4:	84 c0                	test   %al,%al
  800aa6:	74 10                	je     800ab8 <strncmp+0x31>
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	0f b6 10             	movzbl (%eax),%edx
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	0f b6 00             	movzbl (%eax),%eax
  800ab4:	38 c2                	cmp    %al,%dl
  800ab6:	74 d4                	je     800a8c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ab8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800abc:	75 07                	jne    800ac5 <strncmp+0x3e>
		return 0;
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac3:	eb 16                	jmp    800adb <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	0f b6 00             	movzbl (%eax),%eax
  800acb:	0f b6 d0             	movzbl %al,%edx
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	0f b6 00             	movzbl (%eax),%eax
  800ad4:	0f b6 c0             	movzbl %al,%eax
  800ad7:	29 c2                	sub    %eax,%edx
  800ad9:	89 d0                	mov    %edx,%eax
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	83 ec 04             	sub    $0x4,%esp
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ae9:	eb 14                	jmp    800aff <strchr+0x22>
		if (*s == c)
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	0f b6 00             	movzbl (%eax),%eax
  800af1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800af4:	75 05                	jne    800afb <strchr+0x1e>
			return (char *) s;
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	eb 13                	jmp    800b0e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800afb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	0f b6 00             	movzbl (%eax),%eax
  800b05:	84 c0                	test   %al,%al
  800b07:	75 e2                	jne    800aeb <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	83 ec 04             	sub    $0x4,%esp
  800b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b19:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b1c:	eb 11                	jmp    800b2f <strfind+0x1f>
		if (*s == c)
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 00             	movzbl (%eax),%eax
  800b24:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b27:	75 02                	jne    800b2b <strfind+0x1b>
			break;
  800b29:	eb 0e                	jmp    800b39 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	0f b6 00             	movzbl (%eax),%eax
  800b35:	84 c0                	test   %al,%al
  800b37:	75 e5                	jne    800b1e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b46:	75 05                	jne    800b4d <memset+0xf>
		return v;
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	eb 5c                	jmp    800ba9 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	83 e0 03             	and    $0x3,%eax
  800b53:	85 c0                	test   %eax,%eax
  800b55:	75 41                	jne    800b98 <memset+0x5a>
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	83 e0 03             	and    $0x3,%eax
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	75 37                	jne    800b98 <memset+0x5a>
		c &= 0xFF;
  800b61:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	c1 e0 18             	shl    $0x18,%eax
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	c1 e0 10             	shl    $0x10,%eax
  800b76:	09 c2                	or     %eax,%edx
  800b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7b:	c1 e0 08             	shl    $0x8,%eax
  800b7e:	09 d0                	or     %edx,%eax
  800b80:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b83:	8b 45 10             	mov    0x10(%ebp),%eax
  800b86:	c1 e8 02             	shr    $0x2,%eax
  800b89:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	fc                   	cld    
  800b94:	f3 ab                	rep stos %eax,%es:(%edi)
  800b96:	eb 0e                	jmp    800ba6 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba1:	89 d7                	mov    %edx,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
  800bb2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bc7:	73 6d                	jae    800c36 <memmove+0x8a>
  800bc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bcf:	01 d0                	add    %edx,%eax
  800bd1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bd4:	76 60                	jbe    800c36 <memmove+0x8a>
		s += n;
  800bd6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd9:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdf:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be5:	83 e0 03             	and    $0x3,%eax
  800be8:	85 c0                	test   %eax,%eax
  800bea:	75 2f                	jne    800c1b <memmove+0x6f>
  800bec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bef:	83 e0 03             	and    $0x3,%eax
  800bf2:	85 c0                	test   %eax,%eax
  800bf4:	75 25                	jne    800c1b <memmove+0x6f>
  800bf6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf9:	83 e0 03             	and    $0x3,%eax
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	75 1b                	jne    800c1b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c03:	83 e8 04             	sub    $0x4,%eax
  800c06:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c09:	83 ea 04             	sub    $0x4,%edx
  800c0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c0f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	fd                   	std    
  800c17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c19:	eb 18                	jmp    800c33 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c1e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c24:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c27:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2a:	89 d7                	mov    %edx,%edi
  800c2c:	89 de                	mov    %ebx,%esi
  800c2e:	89 c1                	mov    %eax,%ecx
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
  800c34:	eb 45                	jmp    800c7b <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c39:	83 e0 03             	and    $0x3,%eax
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	75 2b                	jne    800c6b <memmove+0xbf>
  800c40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c43:	83 e0 03             	and    $0x3,%eax
  800c46:	85 c0                	test   %eax,%eax
  800c48:	75 21                	jne    800c6b <memmove+0xbf>
  800c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4d:	83 e0 03             	and    $0x3,%eax
  800c50:	85 c0                	test   %eax,%eax
  800c52:	75 17                	jne    800c6b <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c54:	8b 45 10             	mov    0x10(%ebp),%eax
  800c57:	c1 e8 02             	shr    $0x2,%eax
  800c5a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	fc                   	cld    
  800c67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c69:	eb 10                	jmp    800c7b <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c71:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c74:	89 c7                	mov    %eax,%edi
  800c76:	89 d6                	mov    %edx,%esi
  800c78:	fc                   	cld    
  800c79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	89 04 24             	mov    %eax,(%esp)
  800ca0:	e8 07 ff ff ff       	call   800bac <memmove>
}
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cb9:	eb 30                	jmp    800ceb <memcmp+0x44>
		if (*s1 != *s2)
  800cbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cbe:	0f b6 10             	movzbl (%eax),%edx
  800cc1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cc4:	0f b6 00             	movzbl (%eax),%eax
  800cc7:	38 c2                	cmp    %al,%dl
  800cc9:	74 18                	je     800ce3 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cce:	0f b6 00             	movzbl (%eax),%eax
  800cd1:	0f b6 d0             	movzbl %al,%edx
  800cd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cd7:	0f b6 00             	movzbl (%eax),%eax
  800cda:	0f b6 c0             	movzbl %al,%eax
  800cdd:	29 c2                	sub    %eax,%edx
  800cdf:	89 d0                	mov    %edx,%eax
  800ce1:	eb 1a                	jmp    800cfd <memcmp+0x56>
		s1++, s2++;
  800ce3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ceb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cee:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cf1:	89 55 10             	mov    %edx,0x10(%ebp)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	75 c3                	jne    800cbb <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d05:	8b 45 10             	mov    0x10(%ebp),%eax
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	01 d0                	add    %edx,%eax
  800d0d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d10:	eb 13                	jmp    800d25 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	0f b6 10             	movzbl (%eax),%edx
  800d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1b:	38 c2                	cmp    %al,%dl
  800d1d:	75 02                	jne    800d21 <memfind+0x22>
			break;
  800d1f:	eb 0c                	jmp    800d2d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d21:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
  800d28:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d2b:	72 e5                	jb     800d12 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d30:	c9                   	leave  
  800d31:	c3                   	ret    

00800d32 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d38:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d3f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d46:	eb 04                	jmp    800d4c <strtol+0x1a>
		s++;
  800d48:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	3c 20                	cmp    $0x20,%al
  800d54:	74 f2                	je     800d48 <strtol+0x16>
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	0f b6 00             	movzbl (%eax),%eax
  800d5c:	3c 09                	cmp    $0x9,%al
  800d5e:	74 e8                	je     800d48 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	3c 2b                	cmp    $0x2b,%al
  800d68:	75 06                	jne    800d70 <strtol+0x3e>
		s++;
  800d6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d6e:	eb 15                	jmp    800d85 <strtol+0x53>
	else if (*s == '-')
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	0f b6 00             	movzbl (%eax),%eax
  800d76:	3c 2d                	cmp    $0x2d,%al
  800d78:	75 0b                	jne    800d85 <strtol+0x53>
		s++, neg = 1;
  800d7a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d85:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d89:	74 06                	je     800d91 <strtol+0x5f>
  800d8b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d8f:	75 24                	jne    800db5 <strtol+0x83>
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	0f b6 00             	movzbl (%eax),%eax
  800d97:	3c 30                	cmp    $0x30,%al
  800d99:	75 1a                	jne    800db5 <strtol+0x83>
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	83 c0 01             	add    $0x1,%eax
  800da1:	0f b6 00             	movzbl (%eax),%eax
  800da4:	3c 78                	cmp    $0x78,%al
  800da6:	75 0d                	jne    800db5 <strtol+0x83>
		s += 2, base = 16;
  800da8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dac:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800db3:	eb 2a                	jmp    800ddf <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800db5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db9:	75 17                	jne    800dd2 <strtol+0xa0>
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	0f b6 00             	movzbl (%eax),%eax
  800dc1:	3c 30                	cmp    $0x30,%al
  800dc3:	75 0d                	jne    800dd2 <strtol+0xa0>
		s++, base = 8;
  800dc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dd0:	eb 0d                	jmp    800ddf <strtol+0xad>
	else if (base == 0)
  800dd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd6:	75 07                	jne    800ddf <strtol+0xad>
		base = 10;
  800dd8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	3c 2f                	cmp    $0x2f,%al
  800de7:	7e 1b                	jle    800e04 <strtol+0xd2>
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	0f b6 00             	movzbl (%eax),%eax
  800def:	3c 39                	cmp    $0x39,%al
  800df1:	7f 11                	jg     800e04 <strtol+0xd2>
			dig = *s - '0';
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	0f b6 00             	movzbl (%eax),%eax
  800df9:	0f be c0             	movsbl %al,%eax
  800dfc:	83 e8 30             	sub    $0x30,%eax
  800dff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e02:	eb 48                	jmp    800e4c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	0f b6 00             	movzbl (%eax),%eax
  800e0a:	3c 60                	cmp    $0x60,%al
  800e0c:	7e 1b                	jle    800e29 <strtol+0xf7>
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	0f b6 00             	movzbl (%eax),%eax
  800e14:	3c 7a                	cmp    $0x7a,%al
  800e16:	7f 11                	jg     800e29 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	0f b6 00             	movzbl (%eax),%eax
  800e1e:	0f be c0             	movsbl %al,%eax
  800e21:	83 e8 57             	sub    $0x57,%eax
  800e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e27:	eb 23                	jmp    800e4c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2c:	0f b6 00             	movzbl (%eax),%eax
  800e2f:	3c 40                	cmp    $0x40,%al
  800e31:	7e 3d                	jle    800e70 <strtol+0x13e>
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	0f b6 00             	movzbl (%eax),%eax
  800e39:	3c 5a                	cmp    $0x5a,%al
  800e3b:	7f 33                	jg     800e70 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 00             	movzbl (%eax),%eax
  800e43:	0f be c0             	movsbl %al,%eax
  800e46:	83 e8 37             	sub    $0x37,%eax
  800e49:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e52:	7c 02                	jl     800e56 <strtol+0x124>
			break;
  800e54:	eb 1a                	jmp    800e70 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e56:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e5d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e66:	01 d0                	add    %edx,%eax
  800e68:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e6b:	e9 6f ff ff ff       	jmp    800ddf <strtol+0xad>

	if (endptr)
  800e70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e74:	74 08                	je     800e7e <strtol+0x14c>
		*endptr = (char *) s;
  800e76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e7e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e82:	74 07                	je     800e8b <strtol+0x159>
  800e84:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e87:	f7 d8                	neg    %eax
  800e89:	eb 03                	jmp    800e8e <strtol+0x15c>
  800e8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e9f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ea2:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ea5:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ea8:	8b 75 20             	mov    0x20(%ebp),%esi
  800eab:	cd 30                	int    $0x30
  800ead:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb4:	74 30                	je     800ee6 <syscall+0x56>
  800eb6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eba:	7e 2a                	jle    800ee6 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ebf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eca:	c7 44 24 08 a4 1e 80 	movl   $0x801ea4,0x8(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed9:	00 
  800eda:	c7 04 24 c1 1e 80 00 	movl   $0x801ec1,(%esp)
  800ee1:	e8 8f 09 00 00       	call   801875 <_panic>

	return ret;
  800ee6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800ee9:	83 c4 3c             	add    $0x3c,%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f01:	00 
  800f02:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f09:	00 
  800f0a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f11:	00 
  800f12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f15:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2c:	e8 5f ff ff ff       	call   800e90 <syscall>
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f39:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f40:	00 
  800f41:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f48:	00 
  800f49:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f50:	00 
  800f51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f58:	00 
  800f59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f60:	00 
  800f61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f68:	00 
  800f69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f70:	e8 1b ff ff ff       	call   800e90 <syscall>
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f87:	00 
  800f88:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f8f:	00 
  800f90:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f97:	00 
  800f98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f9f:	00 
  800fa0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fab:	00 
  800fac:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fb3:	e8 d8 fe ff ff       	call   800e90 <syscall>
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fc0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fcf:	00 
  800fd0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fe7:	00 
  800fe8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fef:	00 
  800ff0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ff7:	e8 94 fe ff ff       	call   800e90 <syscall>
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <sys_yield>:

void
sys_yield(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801004:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80100b:	00 
  80100c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801013:	00 
  801014:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80101b:	00 
  80101c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801023:	00 
  801024:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801033:	00 
  801034:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80103b:	e8 50 fe ff ff       	call   800e90 <syscall>
}
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801048:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80104b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801058:	00 
  801059:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801060:	00 
  801061:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801065:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801069:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80107c:	e8 0f fe ff ff       	call   800e90 <syscall>
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80108b:	8b 75 18             	mov    0x18(%ebp),%esi
  80108e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801091:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801094:	8b 55 0c             	mov    0xc(%ebp),%edx
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	89 74 24 18          	mov    %esi,0x18(%esp)
  80109e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010a2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b5:	00 
  8010b6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010bd:	e8 ce fd ff ff       	call   800e90 <syscall>
}
  8010c2:	83 c4 20             	add    $0x20,%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5d                   	pop    %ebp
  8010c8:	c3                   	ret    

008010c9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010ec:	00 
  8010ed:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010fc:	00 
  8010fd:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801104:	e8 87 fd ff ff       	call   800e90 <syscall>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801111:	8b 55 0c             	mov    0xc(%ebp),%edx
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80111e:	00 
  80111f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801126:	00 
  801127:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80112e:	00 
  80112f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801133:	89 44 24 08          	mov    %eax,0x8(%esp)
  801137:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80113e:	00 
  80113f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801146:	e8 45 fd ff ff       	call   800e90 <syscall>
}
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801153:	8b 55 0c             	mov    0xc(%ebp),%edx
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801160:	00 
  801161:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801168:	00 
  801169:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801170:	00 
  801171:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801175:	89 44 24 08          	mov    %eax,0x8(%esp)
  801179:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801188:	e8 03 fd ff ff       	call   800e90 <syscall>
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801195:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801198:	8b 55 10             	mov    0x10(%ebp),%edx
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011a5:	00 
  8011a6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011aa:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011c0:	00 
  8011c1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011c8:	e8 c3 fc ff ff       	call   800e90 <syscall>
}
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011df:	00 
  8011e0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011ef:	00 
  8011f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011f7:	00 
  8011f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801203:	00 
  801204:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80120b:	e8 80 fc ff ff       	call   800e90 <syscall>
}
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <sys_exec>:

void sys_exec(char* buf){
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801218:	8b 45 08             	mov    0x8(%ebp),%eax
  80121b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801222:	00 
  801223:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80122a:	00 
  80122b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801232:	00 
  801233:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80123a:	00 
  80123b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801246:	00 
  801247:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80124e:	e8 3d fc ff ff       	call   800e90 <syscall>
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	8b 00                	mov    (%eax),%eax
  801260:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	8b 40 04             	mov    0x4(%eax),%eax
  801269:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	83 e0 02             	and    $0x2,%eax
  801272:	85 c0                	test   %eax,%eax
  801274:	75 23                	jne    801299 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127d:	c7 44 24 08 d0 1e 80 	movl   $0x801ed0,0x8(%esp)
  801284:	00 
  801285:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80128c:	00 
  80128d:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  801294:	e8 dc 05 00 00       	call   801875 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801299:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129c:	c1 e8 0c             	shr    $0xc,%eax
  80129f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8012a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ac:	25 00 08 00 00       	and    $0x800,%eax
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	75 1c                	jne    8012d1 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8012b5:	c7 44 24 08 0c 1f 80 	movl   $0x801f0c,0x8(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8012c4:	00 
  8012c5:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  8012cc:	e8 a4 05 00 00       	call   801875 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8012d1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012d8:	00 
  8012d9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012e0:	00 
  8012e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e8:	e8 55 fd ff ff       	call   801042 <sys_page_alloc>
  8012ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8012f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012f4:	79 23                	jns    801319 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8012f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8012f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fd:	c7 44 24 08 48 1f 80 	movl   $0x801f48,0x8(%esp)
  801304:	00 
  801305:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80130c:	00 
  80130d:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  801314:	e8 5c 05 00 00       	call   801875 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801319:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80131f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801322:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801327:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80132e:	00 
  80132f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801333:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80133a:	e8 47 f9 ff ff       	call   800c86 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  80133f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801342:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801348:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80134d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801354:	00 
  801355:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801359:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801360:	00 
  801361:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801368:	00 
  801369:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801370:	e8 0e fd ff ff       	call   801083 <sys_page_map>
  801375:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801378:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80137c:	79 23                	jns    8013a1 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  80137e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801381:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801385:	c7 44 24 08 80 1f 80 	movl   $0x801f80,0x8(%esp)
  80138c:	00 
  80138d:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  801394:	00 
  801395:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  80139c:	e8 d4 04 00 00       	call   801875 <_panic>
	}

	// panic("pgfault not implemented");
}
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8013ab:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8013b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bc:	25 00 08 00 00       	and    $0x800,%eax
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	75 15                	jne    8013da <duppage+0x37>
  8013c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013cf:	83 e0 02             	and    $0x2,%eax
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	0f 84 e0 00 00 00    	je     8014ba <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8013da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e4:	83 e0 04             	and    $0x4,%eax
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	74 04                	je     8013ef <duppage+0x4c>
  8013eb:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8013ef:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f5:	c1 e0 0c             	shl    $0xc,%eax
  8013f8:	89 c1                	mov    %eax,%ecx
  8013fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fd:	c1 e0 0c             	shl    $0xc,%eax
  801400:	89 c2                	mov    %eax,%edx
  801402:	a1 08 30 80 00       	mov    0x803008,%eax
  801407:	8b 40 48             	mov    0x48(%eax),%eax
  80140a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80140e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801412:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801415:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801419:	89 54 24 04          	mov    %edx,0x4(%esp)
  80141d:	89 04 24             	mov    %eax,(%esp)
  801420:	e8 5e fc ff ff       	call   801083 <sys_page_map>
  801425:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801428:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80142c:	79 23                	jns    801451 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  80142e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801431:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801435:	c7 44 24 08 b4 1f 80 	movl   $0x801fb4,0x8(%esp)
  80143c:	00 
  80143d:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801444:	00 
  801445:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  80144c:	e8 24 04 00 00       	call   801875 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801451:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801454:	8b 45 0c             	mov    0xc(%ebp),%eax
  801457:	c1 e0 0c             	shl    $0xc,%eax
  80145a:	89 c3                	mov    %eax,%ebx
  80145c:	a1 08 30 80 00       	mov    0x803008,%eax
  801461:	8b 48 48             	mov    0x48(%eax),%ecx
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
  801467:	c1 e0 0c             	shl    $0xc,%eax
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	a1 08 30 80 00       	mov    0x803008,%eax
  801471:	8b 40 48             	mov    0x48(%eax),%eax
  801474:	89 74 24 10          	mov    %esi,0x10(%esp)
  801478:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80147c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801480:	89 54 24 04          	mov    %edx,0x4(%esp)
  801484:	89 04 24             	mov    %eax,(%esp)
  801487:	e8 f7 fb ff ff       	call   801083 <sys_page_map>
  80148c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80148f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801493:	79 23                	jns    8014b8 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  801495:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801498:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80149c:	c7 44 24 08 f0 1f 80 	movl   $0x801ff0,0x8(%esp)
  8014a3:	00 
  8014a4:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8014ab:	00 
  8014ac:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  8014b3:	e8 bd 03 00 00       	call   801875 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014b8:	eb 70                	jmp    80152a <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  8014ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c4:	25 ff 0f 00 00       	and    $0xfff,%eax
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ce:	c1 e0 0c             	shl    $0xc,%eax
  8014d1:	89 c1                	mov    %eax,%ecx
  8014d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d6:	c1 e0 0c             	shl    $0xc,%eax
  8014d9:	89 c2                	mov    %eax,%edx
  8014db:	a1 08 30 80 00       	mov    0x803008,%eax
  8014e0:	8b 40 48             	mov    0x48(%eax),%eax
  8014e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014e7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014f6:	89 04 24             	mov    %eax,(%esp)
  8014f9:	e8 85 fb ff ff       	call   801083 <sys_page_map>
  8014fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801501:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801505:	79 23                	jns    80152a <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80150e:	c7 44 24 08 20 20 80 	movl   $0x802020,0x8(%esp)
  801515:	00 
  801516:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  80151d:	00 
  80151e:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  801525:	e8 4b 03 00 00       	call   801875 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80152f:	83 c4 30             	add    $0x30,%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5d                   	pop    %ebp
  801535:	c3                   	ret    

00801536 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80153c:	c7 04 24 55 12 80 00 	movl   $0x801255,(%esp)
  801543:	e8 88 03 00 00       	call   8018d0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801548:	b8 07 00 00 00       	mov    $0x7,%eax
  80154d:	cd 30                	int    $0x30
  80154f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801552:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  801555:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  801558:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80155c:	79 23                	jns    801581 <fork+0x4b>
  80155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801561:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801565:	c7 44 24 08 58 20 80 	movl   $0x802058,0x8(%esp)
  80156c:	00 
  80156d:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  801574:	00 
  801575:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  80157c:	e8 f4 02 00 00       	call   801875 <_panic>
	else if(childeid == 0){
  801581:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801585:	75 29                	jne    8015b0 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801587:	e8 2e fa ff ff       	call   800fba <sys_getenvid>
  80158c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801591:	c1 e0 02             	shl    $0x2,%eax
  801594:	89 c2                	mov    %eax,%edx
  801596:	c1 e2 05             	shl    $0x5,%edx
  801599:	29 c2                	sub    %eax,%edx
  80159b:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8015a1:	a3 08 30 80 00       	mov    %eax,0x803008
		// set_pgfault_handler(pgfault);
		return 0;
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ab:	e9 16 01 00 00       	jmp    8016c6 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8015b7:	eb 3b                	jmp    8015f4 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  8015b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bc:	c1 f8 0a             	sar    $0xa,%eax
  8015bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c6:	83 e0 01             	and    $0x1,%eax
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	74 23                	je     8015f0 <fork+0xba>
  8015cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d7:	83 e0 01             	and    $0x1,%eax
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 12                	je     8015f0 <fork+0xba>
			duppage(childeid, i);
  8015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	89 04 24             	mov    %eax,(%esp)
  8015eb:	e8 b3 fd ff ff       	call   8013a3 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8015f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f7:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  8015fc:	76 bb                	jbe    8015b9 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  8015fe:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801605:	00 
  801606:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80160d:	ee 
  80160e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801611:	89 04 24             	mov    %eax,(%esp)
  801614:	e8 29 fa ff ff       	call   801042 <sys_page_alloc>
  801619:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801620:	79 23                	jns    801645 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  801622:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801625:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801629:	c7 44 24 08 80 20 80 	movl   $0x802080,0x8(%esp)
  801630:	00 
  801631:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801638:	00 
  801639:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  801640:	e8 30 02 00 00       	call   801875 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  801645:	c7 44 24 04 46 19 80 	movl   $0x801946,0x4(%esp)
  80164c:	00 
  80164d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801650:	89 04 24             	mov    %eax,(%esp)
  801653:	e8 f5 fa ff ff       	call   80114d <sys_env_set_pgfault_upcall>
  801658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80165b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80165f:	79 23                	jns    801684 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  801661:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801664:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801668:	c7 44 24 08 a8 20 80 	movl   $0x8020a8,0x8(%esp)
  80166f:	00 
  801670:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801677:	00 
  801678:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  80167f:	e8 f1 01 00 00       	call   801875 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  801684:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80168b:	00 
  80168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 74 fa ff ff       	call   80110b <sys_env_set_status>
  801697:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80169a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80169e:	79 23                	jns    8016c3 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8016a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016a7:	c7 44 24 08 dc 20 80 	movl   $0x8020dc,0x8(%esp)
  8016ae:	00 
  8016af:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8016b6:	00 
  8016b7:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  8016be:	e8 b2 01 00 00       	call   801875 <_panic>
	}
	return childeid;
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <sfork>:

// Challenge!
int
sfork(void)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016ce:	c7 44 24 08 05 21 80 	movl   $0x802105,0x8(%esp)
  8016d5:	00 
  8016d6:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8016dd:	00 
  8016de:	c7 04 24 00 1f 80 00 	movl   $0x801f00,(%esp)
  8016e5:	e8 8b 01 00 00       	call   801875 <_panic>

008016ea <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  8016f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8016f4:	75 09                	jne    8016ff <ipc_recv+0x15>
		i_dstva = UTOP;
  8016f6:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  8016fd:	eb 06                	jmp    801705 <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  8016ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801702:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	89 04 24             	mov    %eax,(%esp)
  80170b:	e8 bf fa ff ff       	call   8011cf <sys_ipc_recv>
  801710:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  801713:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801717:	75 15                	jne    80172e <ipc_recv+0x44>
  801719:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80171d:	74 0f                	je     80172e <ipc_recv+0x44>
  80171f:	a1 08 30 80 00       	mov    0x803008,%eax
  801724:	8b 50 74             	mov    0x74(%eax),%edx
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	89 10                	mov    %edx,(%eax)
  80172c:	eb 15                	jmp    801743 <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  80172e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801732:	79 0f                	jns    801743 <ipc_recv+0x59>
  801734:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801738:	74 09                	je     801743 <ipc_recv+0x59>
  80173a:	8b 45 08             	mov    0x8(%ebp),%eax
  80173d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  801743:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801747:	75 15                	jne    80175e <ipc_recv+0x74>
  801749:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80174d:	74 0f                	je     80175e <ipc_recv+0x74>
  80174f:	a1 08 30 80 00       	mov    0x803008,%eax
  801754:	8b 50 78             	mov    0x78(%eax),%edx
  801757:	8b 45 10             	mov    0x10(%ebp),%eax
  80175a:	89 10                	mov    %edx,(%eax)
  80175c:	eb 15                	jmp    801773 <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  80175e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801762:	79 0f                	jns    801773 <ipc_recv+0x89>
  801764:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801768:	74 09                	je     801773 <ipc_recv+0x89>
  80176a:	8b 45 10             	mov    0x10(%ebp),%eax
  80176d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  801773:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801777:	75 0a                	jne    801783 <ipc_recv+0x99>
  801779:	a1 08 30 80 00       	mov    0x803008,%eax
  80177e:	8b 40 70             	mov    0x70(%eax),%eax
  801781:	eb 03                	jmp    801786 <ipc_recv+0x9c>
	else return r;
  801783:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  80178e:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  801795:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801799:	74 06                	je     8017a1 <ipc_send+0x19>
  80179b:	8b 45 10             	mov    0x10(%ebp),%eax
  80179e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8017a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a4:	8b 55 14             	mov    0x14(%ebp),%edx
  8017a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	89 04 24             	mov    %eax,(%esp)
  8017bc:	e8 ce f9 ff ff       	call   80118f <sys_ipc_try_send>
  8017c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  8017c4:	eb 28                	jmp    8017ee <ipc_send+0x66>
		sys_yield();
  8017c6:	e8 33 f8 ff ff       	call   800ffe <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8017cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ce:	8b 55 14             	mov    0x14(%ebp),%edx
  8017d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 a4 f9 ff ff       	call   80118f <sys_ipc_try_send>
  8017eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  8017ee:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  8017f2:	74 d2                	je     8017c6 <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  8017f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017f8:	75 02                	jne    8017fc <ipc_send+0x74>
  8017fa:	eb 23                	jmp    80181f <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  8017fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801803:	c7 44 24 08 1c 21 80 	movl   $0x80211c,0x8(%esp)
  80180a:	00 
  80180b:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801812:	00 
  801813:	c7 04 24 41 21 80 00 	movl   $0x802141,(%esp)
  80181a:	e8 56 00 00 00       	call   801875 <_panic>
	panic("ipc_send not implemented");
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  801827:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80182e:	eb 35                	jmp    801865 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801830:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801833:	c1 e0 02             	shl    $0x2,%eax
  801836:	89 c2                	mov    %eax,%edx
  801838:	c1 e2 05             	shl    $0x5,%edx
  80183b:	29 c2                	sub    %eax,%edx
  80183d:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  801843:	8b 00                	mov    (%eax),%eax
  801845:	3b 45 08             	cmp    0x8(%ebp),%eax
  801848:	75 17                	jne    801861 <ipc_find_env+0x40>
			return envs[i].env_id;
  80184a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184d:	c1 e0 02             	shl    $0x2,%eax
  801850:	89 c2                	mov    %eax,%edx
  801852:	c1 e2 05             	shl    $0x5,%edx
  801855:	29 c2                	sub    %eax,%edx
  801857:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  80185d:	8b 00                	mov    (%eax),%eax
  80185f:	eb 12                	jmp    801873 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801861:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801865:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  80186c:	7e c2                	jle    801830 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80187c:	8d 45 14             	lea    0x14(%ebp),%eax
  80187f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801882:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801888:	e8 2d f7 ff ff       	call   800fba <sys_getenvid>
  80188d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801890:	89 54 24 10          	mov    %edx,0x10(%esp)
  801894:	8b 55 08             	mov    0x8(%ebp),%edx
  801897:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80189b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  8018aa:	e8 d6 e9 ff ff       	call   800285 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b9:	89 04 24             	mov    %eax,(%esp)
  8018bc:	e8 60 e9 ff ff       	call   800221 <vcprintf>
	cprintf("\n");
  8018c1:	c7 04 24 6f 21 80 00 	movl   $0x80216f,(%esp)
  8018c8:	e8 b8 e9 ff ff       	call   800285 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8018cd:	cc                   	int3   
  8018ce:	eb fd                	jmp    8018cd <_panic+0x58>

008018d0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8018d6:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	75 5d                	jne    80193c <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8018df:	a1 08 30 80 00       	mov    0x803008,%eax
  8018e4:	8b 40 48             	mov    0x48(%eax),%eax
  8018e7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018ee:	00 
  8018ef:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8018f6:	ee 
  8018f7:	89 04 24             	mov    %eax,(%esp)
  8018fa:	e8 43 f7 ff ff       	call   801042 <sys_page_alloc>
  8018ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801902:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801906:	79 1c                	jns    801924 <set_pgfault_handler+0x54>
  801908:	c7 44 24 08 74 21 80 	movl   $0x802174,0x8(%esp)
  80190f:	00 
  801910:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801917:	00 
  801918:	c7 04 24 a0 21 80 00 	movl   $0x8021a0,(%esp)
  80191f:	e8 51 ff ff ff       	call   801875 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801924:	a1 08 30 80 00       	mov    0x803008,%eax
  801929:	8b 40 48             	mov    0x48(%eax),%eax
  80192c:	c7 44 24 04 46 19 80 	movl   $0x801946,0x4(%esp)
  801933:	00 
  801934:	89 04 24             	mov    %eax,(%esp)
  801937:	e8 11 f8 ff ff       	call   80114d <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801946:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801947:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  80194c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80194e:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801951:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801955:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801957:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80195b:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80195c:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80195f:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801961:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801962:	58                   	pop    %eax
	popal 						// pop all the registers
  801963:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801964:	83 c4 04             	add    $0x4,%esp
	popfl
  801967:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801968:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801969:	c3                   	ret    
  80196a:	66 90                	xchg   %ax,%ax
  80196c:	66 90                	xchg   %ax,%ax
  80196e:	66 90                	xchg   %ax,%ax

00801970 <__udivdi3>:
  801970:	55                   	push   %ebp
  801971:	57                   	push   %edi
  801972:	56                   	push   %esi
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	8b 44 24 28          	mov    0x28(%esp),%eax
  80197a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80197e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801982:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801986:	85 c0                	test   %eax,%eax
  801988:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80198c:	89 ea                	mov    %ebp,%edx
  80198e:	89 0c 24             	mov    %ecx,(%esp)
  801991:	75 2d                	jne    8019c0 <__udivdi3+0x50>
  801993:	39 e9                	cmp    %ebp,%ecx
  801995:	77 61                	ja     8019f8 <__udivdi3+0x88>
  801997:	85 c9                	test   %ecx,%ecx
  801999:	89 ce                	mov    %ecx,%esi
  80199b:	75 0b                	jne    8019a8 <__udivdi3+0x38>
  80199d:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a2:	31 d2                	xor    %edx,%edx
  8019a4:	f7 f1                	div    %ecx
  8019a6:	89 c6                	mov    %eax,%esi
  8019a8:	31 d2                	xor    %edx,%edx
  8019aa:	89 e8                	mov    %ebp,%eax
  8019ac:	f7 f6                	div    %esi
  8019ae:	89 c5                	mov    %eax,%ebp
  8019b0:	89 f8                	mov    %edi,%eax
  8019b2:	f7 f6                	div    %esi
  8019b4:	89 ea                	mov    %ebp,%edx
  8019b6:	83 c4 0c             	add    $0xc,%esp
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    
  8019bd:	8d 76 00             	lea    0x0(%esi),%esi
  8019c0:	39 e8                	cmp    %ebp,%eax
  8019c2:	77 24                	ja     8019e8 <__udivdi3+0x78>
  8019c4:	0f bd e8             	bsr    %eax,%ebp
  8019c7:	83 f5 1f             	xor    $0x1f,%ebp
  8019ca:	75 3c                	jne    801a08 <__udivdi3+0x98>
  8019cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8019d0:	39 34 24             	cmp    %esi,(%esp)
  8019d3:	0f 86 9f 00 00 00    	jbe    801a78 <__udivdi3+0x108>
  8019d9:	39 d0                	cmp    %edx,%eax
  8019db:	0f 82 97 00 00 00    	jb     801a78 <__udivdi3+0x108>
  8019e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8019e8:	31 d2                	xor    %edx,%edx
  8019ea:	31 c0                	xor    %eax,%eax
  8019ec:	83 c4 0c             	add    $0xc,%esp
  8019ef:	5e                   	pop    %esi
  8019f0:	5f                   	pop    %edi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    
  8019f3:	90                   	nop
  8019f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019f8:	89 f8                	mov    %edi,%eax
  8019fa:	f7 f1                	div    %ecx
  8019fc:	31 d2                	xor    %edx,%edx
  8019fe:	83 c4 0c             	add    $0xc,%esp
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    
  801a05:	8d 76 00             	lea    0x0(%esi),%esi
  801a08:	89 e9                	mov    %ebp,%ecx
  801a0a:	8b 3c 24             	mov    (%esp),%edi
  801a0d:	d3 e0                	shl    %cl,%eax
  801a0f:	89 c6                	mov    %eax,%esi
  801a11:	b8 20 00 00 00       	mov    $0x20,%eax
  801a16:	29 e8                	sub    %ebp,%eax
  801a18:	89 c1                	mov    %eax,%ecx
  801a1a:	d3 ef                	shr    %cl,%edi
  801a1c:	89 e9                	mov    %ebp,%ecx
  801a1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a22:	8b 3c 24             	mov    (%esp),%edi
  801a25:	09 74 24 08          	or     %esi,0x8(%esp)
  801a29:	89 d6                	mov    %edx,%esi
  801a2b:	d3 e7                	shl    %cl,%edi
  801a2d:	89 c1                	mov    %eax,%ecx
  801a2f:	89 3c 24             	mov    %edi,(%esp)
  801a32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a36:	d3 ee                	shr    %cl,%esi
  801a38:	89 e9                	mov    %ebp,%ecx
  801a3a:	d3 e2                	shl    %cl,%edx
  801a3c:	89 c1                	mov    %eax,%ecx
  801a3e:	d3 ef                	shr    %cl,%edi
  801a40:	09 d7                	or     %edx,%edi
  801a42:	89 f2                	mov    %esi,%edx
  801a44:	89 f8                	mov    %edi,%eax
  801a46:	f7 74 24 08          	divl   0x8(%esp)
  801a4a:	89 d6                	mov    %edx,%esi
  801a4c:	89 c7                	mov    %eax,%edi
  801a4e:	f7 24 24             	mull   (%esp)
  801a51:	39 d6                	cmp    %edx,%esi
  801a53:	89 14 24             	mov    %edx,(%esp)
  801a56:	72 30                	jb     801a88 <__udivdi3+0x118>
  801a58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a5c:	89 e9                	mov    %ebp,%ecx
  801a5e:	d3 e2                	shl    %cl,%edx
  801a60:	39 c2                	cmp    %eax,%edx
  801a62:	73 05                	jae    801a69 <__udivdi3+0xf9>
  801a64:	3b 34 24             	cmp    (%esp),%esi
  801a67:	74 1f                	je     801a88 <__udivdi3+0x118>
  801a69:	89 f8                	mov    %edi,%eax
  801a6b:	31 d2                	xor    %edx,%edx
  801a6d:	e9 7a ff ff ff       	jmp    8019ec <__udivdi3+0x7c>
  801a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801a78:	31 d2                	xor    %edx,%edx
  801a7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7f:	e9 68 ff ff ff       	jmp    8019ec <__udivdi3+0x7c>
  801a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a8b:	31 d2                	xor    %edx,%edx
  801a8d:	83 c4 0c             	add    $0xc,%esp
  801a90:	5e                   	pop    %esi
  801a91:	5f                   	pop    %edi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    
  801a94:	66 90                	xchg   %ax,%ax
  801a96:	66 90                	xchg   %ax,%ax
  801a98:	66 90                	xchg   %ax,%ax
  801a9a:	66 90                	xchg   %ax,%ax
  801a9c:	66 90                	xchg   %ax,%ax
  801a9e:	66 90                	xchg   %ax,%ax

00801aa0 <__umoddi3>:
  801aa0:	55                   	push   %ebp
  801aa1:	57                   	push   %edi
  801aa2:	56                   	push   %esi
  801aa3:	83 ec 14             	sub    $0x14,%esp
  801aa6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801aaa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801aae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ab2:	89 c7                	mov    %eax,%edi
  801ab4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801abc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ac0:	89 34 24             	mov    %esi,(%esp)
  801ac3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	89 c2                	mov    %eax,%edx
  801acb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801acf:	75 17                	jne    801ae8 <__umoddi3+0x48>
  801ad1:	39 fe                	cmp    %edi,%esi
  801ad3:	76 4b                	jbe    801b20 <__umoddi3+0x80>
  801ad5:	89 c8                	mov    %ecx,%eax
  801ad7:	89 fa                	mov    %edi,%edx
  801ad9:	f7 f6                	div    %esi
  801adb:	89 d0                	mov    %edx,%eax
  801add:	31 d2                	xor    %edx,%edx
  801adf:	83 c4 14             	add    $0x14,%esp
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
  801ae6:	66 90                	xchg   %ax,%ax
  801ae8:	39 f8                	cmp    %edi,%eax
  801aea:	77 54                	ja     801b40 <__umoddi3+0xa0>
  801aec:	0f bd e8             	bsr    %eax,%ebp
  801aef:	83 f5 1f             	xor    $0x1f,%ebp
  801af2:	75 5c                	jne    801b50 <__umoddi3+0xb0>
  801af4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801af8:	39 3c 24             	cmp    %edi,(%esp)
  801afb:	0f 87 e7 00 00 00    	ja     801be8 <__umoddi3+0x148>
  801b01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b05:	29 f1                	sub    %esi,%ecx
  801b07:	19 c7                	sbb    %eax,%edi
  801b09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b11:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b19:	83 c4 14             	add    $0x14,%esp
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    
  801b20:	85 f6                	test   %esi,%esi
  801b22:	89 f5                	mov    %esi,%ebp
  801b24:	75 0b                	jne    801b31 <__umoddi3+0x91>
  801b26:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2b:	31 d2                	xor    %edx,%edx
  801b2d:	f7 f6                	div    %esi
  801b2f:	89 c5                	mov    %eax,%ebp
  801b31:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b35:	31 d2                	xor    %edx,%edx
  801b37:	f7 f5                	div    %ebp
  801b39:	89 c8                	mov    %ecx,%eax
  801b3b:	f7 f5                	div    %ebp
  801b3d:	eb 9c                	jmp    801adb <__umoddi3+0x3b>
  801b3f:	90                   	nop
  801b40:	89 c8                	mov    %ecx,%eax
  801b42:	89 fa                	mov    %edi,%edx
  801b44:	83 c4 14             	add    $0x14,%esp
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    
  801b4b:	90                   	nop
  801b4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b50:	8b 04 24             	mov    (%esp),%eax
  801b53:	be 20 00 00 00       	mov    $0x20,%esi
  801b58:	89 e9                	mov    %ebp,%ecx
  801b5a:	29 ee                	sub    %ebp,%esi
  801b5c:	d3 e2                	shl    %cl,%edx
  801b5e:	89 f1                	mov    %esi,%ecx
  801b60:	d3 e8                	shr    %cl,%eax
  801b62:	89 e9                	mov    %ebp,%ecx
  801b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b68:	8b 04 24             	mov    (%esp),%eax
  801b6b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b6f:	89 fa                	mov    %edi,%edx
  801b71:	d3 e0                	shl    %cl,%eax
  801b73:	89 f1                	mov    %esi,%ecx
  801b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b79:	8b 44 24 10          	mov    0x10(%esp),%eax
  801b7d:	d3 ea                	shr    %cl,%edx
  801b7f:	89 e9                	mov    %ebp,%ecx
  801b81:	d3 e7                	shl    %cl,%edi
  801b83:	89 f1                	mov    %esi,%ecx
  801b85:	d3 e8                	shr    %cl,%eax
  801b87:	89 e9                	mov    %ebp,%ecx
  801b89:	09 f8                	or     %edi,%eax
  801b8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b8f:	f7 74 24 04          	divl   0x4(%esp)
  801b93:	d3 e7                	shl    %cl,%edi
  801b95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b99:	89 d7                	mov    %edx,%edi
  801b9b:	f7 64 24 08          	mull   0x8(%esp)
  801b9f:	39 d7                	cmp    %edx,%edi
  801ba1:	89 c1                	mov    %eax,%ecx
  801ba3:	89 14 24             	mov    %edx,(%esp)
  801ba6:	72 2c                	jb     801bd4 <__umoddi3+0x134>
  801ba8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bac:	72 22                	jb     801bd0 <__umoddi3+0x130>
  801bae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801bb2:	29 c8                	sub    %ecx,%eax
  801bb4:	19 d7                	sbb    %edx,%edi
  801bb6:	89 e9                	mov    %ebp,%ecx
  801bb8:	89 fa                	mov    %edi,%edx
  801bba:	d3 e8                	shr    %cl,%eax
  801bbc:	89 f1                	mov    %esi,%ecx
  801bbe:	d3 e2                	shl    %cl,%edx
  801bc0:	89 e9                	mov    %ebp,%ecx
  801bc2:	d3 ef                	shr    %cl,%edi
  801bc4:	09 d0                	or     %edx,%eax
  801bc6:	89 fa                	mov    %edi,%edx
  801bc8:	83 c4 14             	add    $0x14,%esp
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    
  801bcf:	90                   	nop
  801bd0:	39 d7                	cmp    %edx,%edi
  801bd2:	75 da                	jne    801bae <__umoddi3+0x10e>
  801bd4:	8b 14 24             	mov    (%esp),%edx
  801bd7:	89 c1                	mov    %eax,%ecx
  801bd9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801bdd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801be1:	eb cb                	jmp    801bae <__umoddi3+0x10e>
  801be3:	90                   	nop
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801bec:	0f 82 0f ff ff ff    	jb     801b01 <__umoddi3+0x61>
  801bf2:	e9 1a ff ff ff       	jmp    801b11 <__umoddi3+0x71>
