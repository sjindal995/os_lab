
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
  800043:	e8 b4 16 00 00       	call   8016fc <sfork>
  800048:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80004b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80004e:	85 c0                	test   %eax,%eax
  800050:	74 5e                	je     8000b0 <umain+0x7d>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800052:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  800058:	e8 4d 0f 00 00       	call   800faa <sys_getenvid>
  80005d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800061:	89 44 24 04          	mov    %eax,0x4(%esp)
  800065:	c7 04 24 40 1c 80 00 	movl   $0x801c40,(%esp)
  80006c:	e8 04 02 00 00       	call   800275 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800071:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800074:	e8 31 0f 00 00       	call   800faa <sys_getenvid>
  800079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	c7 04 24 5a 1c 80 00 	movl   $0x801c5a,(%esp)
  800088:	e8 e8 01 00 00       	call   800275 <cprintf>
		ipc_send(who, 0, 0, 0);
  80008d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800090:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800097:	00 
  800098:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80009f:	00 
  8000a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000a7:	00 
  8000a8:	89 04 24             	mov    %eax,(%esp)
  8000ab:	e8 0c 17 00 00       	call   8017bc <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bf:	00 
  8000c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8000c3:	89 04 24             	mov    %eax,(%esp)
  8000c6:	e8 53 16 00 00       	call   80171e <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000cb:	a1 08 30 80 00       	mov    0x803008,%eax
  8000d0:	8b 40 48             	mov    0x48(%eax),%eax
  8000d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d6:	8b 3d 08 30 80 00    	mov    0x803008,%edi
  8000dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8000df:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8000e5:	e8 c0 0e 00 00       	call   800faa <sys_getenvid>
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000ed:	89 54 24 14          	mov    %edx,0x14(%esp)
  8000f1:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8000f5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 70 1c 80 00 	movl   $0x801c70,(%esp)
  800108:	e8 68 01 00 00       	call   800275 <cprintf>
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
  800144:	e8 73 16 00 00       	call   8017bc <ipc_send>
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
  800168:	e8 3d 0e 00 00       	call   800faa <sys_getenvid>
  80016d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800172:	c1 e0 02             	shl    $0x2,%eax
  800175:	89 c2                	mov    %eax,%edx
  800177:	c1 e2 05             	shl    $0x5,%edx
  80017a:	29 c2                	sub    %eax,%edx
  80017c:	89 d0                	mov    %edx,%eax
  80017e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800183:	a3 08 30 80 00       	mov    %eax,0x803008
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018f:	8b 45 08             	mov    0x8(%ebp),%eax
  800192:	89 04 24             	mov    %eax,(%esp)
  800195:	e8 99 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80019a:	e8 02 00 00 00       	call   8001a1 <exit>
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 b4 0d 00 00       	call   800f67 <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001be:	8b 00                	mov    (%eax),%eax
  8001c0:	8d 48 01             	lea    0x1(%eax),%ecx
  8001c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c6:	89 0a                	mov    %ecx,(%edx)
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	89 d1                	mov    %edx,%ecx
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	8b 00                	mov    (%eax),%eax
  8001d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001de:	75 20                	jne    800200 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	8b 00                	mov    (%eax),%eax
  8001e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e8:	83 c2 08             	add    $0x8,%edx
  8001eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ef:	89 14 24             	mov    %edx,(%esp)
  8001f2:	e8 ea 0c 00 00       	call   800ee1 <sys_cputs>
		b->idx = 0;
  8001f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	8b 40 04             	mov    0x4(%eax),%eax
  800206:	8d 50 01             	lea    0x1(%eax),%edx
  800209:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800221:	00 00 00 
	b.cnt = 0;
  800224:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800231:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	c7 04 24 b5 01 80 00 	movl   $0x8001b5,(%esp)
  80024d:	e8 bd 01 00 00       	call   80040f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800252:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800262:	83 c0 08             	add    $0x8,%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	e8 74 0c 00 00       	call   800ee1 <sys_cputs>

	return b.cnt;
  80026d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	89 04 24             	mov    %eax,(%esp)
  80028e:	e8 7e ff ff ff       	call   800211 <vcprintf>
  800293:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800296:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	53                   	push   %ebx
  80029f:	83 ec 34             	sub    $0x34,%esp
  8002a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ae:	8b 45 18             	mov    0x18(%ebp),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002b9:	77 72                	ja     80032d <printnum+0x92>
  8002bb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002be:	72 05                	jb     8002c5 <printnum+0x2a>
  8002c0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002c3:	77 68                	ja     80032d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c5:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002c8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002cb:	8b 45 18             	mov    0x18(%ebp),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002e1:	89 04 24             	mov    %eax,(%esp)
  8002e4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e8:	e8 b3 16 00 00       	call   8019a0 <__udivdi3>
  8002ed:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8002f0:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8002f4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002f8:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002fb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800307:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 04 24             	mov    %eax,(%esp)
  800314:	e8 82 ff ff ff       	call   80029b <printnum>
  800319:	eb 1c                	jmp    800337 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800322:	8b 45 20             	mov    0x20(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800331:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800335:	7f e4                	jg     80031b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800337:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800342:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800345:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800349:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80034d:	89 04 24             	mov    %eax,(%esp)
  800350:	89 54 24 04          	mov    %edx,0x4(%esp)
  800354:	e8 77 17 00 00       	call   801ad0 <__umoddi3>
  800359:	05 68 1d 80 00       	add    $0x801d68,%eax
  80035e:	0f b6 00             	movzbl (%eax),%eax
  800361:	0f be c0             	movsbl %al,%eax
  800364:	8b 55 0c             	mov    0xc(%ebp),%edx
  800367:	89 54 24 04          	mov    %edx,0x4(%esp)
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	ff d0                	call   *%eax
}
  800373:	83 c4 34             	add    $0x34,%esp
  800376:	5b                   	pop    %ebx
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800380:	7e 14                	jle    800396 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800382:	8b 45 08             	mov    0x8(%ebp),%eax
  800385:	8b 00                	mov    (%eax),%eax
  800387:	8d 48 08             	lea    0x8(%eax),%ecx
  80038a:	8b 55 08             	mov    0x8(%ebp),%edx
  80038d:	89 0a                	mov    %ecx,(%edx)
  80038f:	8b 50 04             	mov    0x4(%eax),%edx
  800392:	8b 00                	mov    (%eax),%eax
  800394:	eb 30                	jmp    8003c6 <getuint+0x4d>
	else if (lflag)
  800396:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80039a:	74 16                	je     8003b2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a7:	89 0a                	mov    %ecx,(%edx)
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 14                	jmp    8003c6 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 0a                	mov    %ecx,(%edx)
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003cf:	7e 14                	jle    8003e5 <getint+0x1d>
		return va_arg(*ap, long long);
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	8d 48 08             	lea    0x8(%eax),%ecx
  8003d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dc:	89 0a                	mov    %ecx,(%edx)
  8003de:	8b 50 04             	mov    0x4(%eax),%edx
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	eb 28                	jmp    80040d <getint+0x45>
	else if (lflag)
  8003e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003e9:	74 12                	je     8003fd <getint+0x35>
		return va_arg(*ap, long);
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f6:	89 0a                	mov    %ecx,(%edx)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	99                   	cltd   
  8003fb:	eb 10                	jmp    80040d <getint+0x45>
	else
		return va_arg(*ap, int);
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	8b 00                	mov    (%eax),%eax
  800402:	8d 48 04             	lea    0x4(%eax),%ecx
  800405:	8b 55 08             	mov    0x8(%ebp),%edx
  800408:	89 0a                	mov    %ecx,(%edx)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800417:	eb 18                	jmp    800431 <vprintfmt+0x22>
			if (ch == '\0')
  800419:	85 db                	test   %ebx,%ebx
  80041b:	75 05                	jne    800422 <vprintfmt+0x13>
				return;
  80041d:	e9 cc 03 00 00       	jmp    8007ee <vprintfmt+0x3df>
			putch(ch, putdat);
  800422:	8b 45 0c             	mov    0xc(%ebp),%eax
  800425:	89 44 24 04          	mov    %eax,0x4(%esp)
  800429:	89 1c 24             	mov    %ebx,(%esp)
  80042c:	8b 45 08             	mov    0x8(%ebp),%eax
  80042f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800431:	8b 45 10             	mov    0x10(%ebp),%eax
  800434:	8d 50 01             	lea    0x1(%eax),%edx
  800437:	89 55 10             	mov    %edx,0x10(%ebp)
  80043a:	0f b6 00             	movzbl (%eax),%eax
  80043d:	0f b6 d8             	movzbl %al,%ebx
  800440:	83 fb 25             	cmp    $0x25,%ebx
  800443:	75 d4                	jne    800419 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800445:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800449:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800450:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800457:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80045e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 45 10             	mov    0x10(%ebp),%eax
  800468:	8d 50 01             	lea    0x1(%eax),%edx
  80046b:	89 55 10             	mov    %edx,0x10(%ebp)
  80046e:	0f b6 00             	movzbl (%eax),%eax
  800471:	0f b6 d8             	movzbl %al,%ebx
  800474:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800477:	83 f8 55             	cmp    $0x55,%eax
  80047a:	0f 87 3d 03 00 00    	ja     8007bd <vprintfmt+0x3ae>
  800480:	8b 04 85 8c 1d 80 00 	mov    0x801d8c(,%eax,4),%eax
  800487:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800489:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80048d:	eb d6                	jmp    800465 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800493:	eb d0                	jmp    800465 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800495:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80049c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80049f:	89 d0                	mov    %edx,%eax
  8004a1:	c1 e0 02             	shl    $0x2,%eax
  8004a4:	01 d0                	add    %edx,%eax
  8004a6:	01 c0                	add    %eax,%eax
  8004a8:	01 d8                	add    %ebx,%eax
  8004aa:	83 e8 30             	sub    $0x30,%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b3:	0f b6 00             	movzbl (%eax),%eax
  8004b6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004b9:	83 fb 2f             	cmp    $0x2f,%ebx
  8004bc:	7e 0b                	jle    8004c9 <vprintfmt+0xba>
  8004be:	83 fb 39             	cmp    $0x39,%ebx
  8004c1:	7f 06                	jg     8004c9 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c7:	eb d3                	jmp    80049c <vprintfmt+0x8d>
			goto process_precision;
  8004c9:	eb 33                	jmp    8004fe <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 00                	mov    (%eax),%eax
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004d9:	eb 23                	jmp    8004fe <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004df:	79 0c                	jns    8004ed <vprintfmt+0xde>
				width = 0;
  8004e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8004e8:	e9 78 ff ff ff       	jmp    800465 <vprintfmt+0x56>
  8004ed:	e9 73 ff ff ff       	jmp    800465 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8004f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004f9:	e9 67 ff ff ff       	jmp    800465 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8004fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800502:	79 12                	jns    800516 <vprintfmt+0x107>
				width = precision, precision = -1;
  800504:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800507:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800511:	e9 4f ff ff ff       	jmp    800465 <vprintfmt+0x56>
  800516:	e9 4a ff ff ff       	jmp    800465 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80051f:	e9 41 ff ff ff       	jmp    800465 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 50 04             	lea    0x4(%eax),%edx
  80052a:	89 55 14             	mov    %edx,0x14(%ebp)
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800532:	89 54 24 04          	mov    %edx,0x4(%esp)
  800536:	89 04 24             	mov    %eax,(%esp)
  800539:	8b 45 08             	mov    0x8(%ebp),%eax
  80053c:	ff d0                	call   *%eax
			break;
  80053e:	e9 a5 02 00 00       	jmp    8007e8 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80054e:	85 db                	test   %ebx,%ebx
  800550:	79 02                	jns    800554 <vprintfmt+0x145>
				err = -err;
  800552:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800554:	83 fb 09             	cmp    $0x9,%ebx
  800557:	7f 0b                	jg     800564 <vprintfmt+0x155>
  800559:	8b 34 9d 40 1d 80 00 	mov    0x801d40(,%ebx,4),%esi
  800560:	85 f6                	test   %esi,%esi
  800562:	75 23                	jne    800587 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800564:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800568:	c7 44 24 08 79 1d 80 	movl   $0x801d79,0x8(%esp)
  80056f:	00 
  800570:	8b 45 0c             	mov    0xc(%ebp),%eax
  800573:	89 44 24 04          	mov    %eax,0x4(%esp)
  800577:	8b 45 08             	mov    0x8(%ebp),%eax
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	e8 73 02 00 00       	call   8007f5 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800582:	e9 61 02 00 00       	jmp    8007e8 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800587:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80058b:	c7 44 24 08 82 1d 80 	movl   $0x801d82,0x8(%esp)
  800592:	00 
  800593:	8b 45 0c             	mov    0xc(%ebp),%eax
  800596:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059a:	8b 45 08             	mov    0x8(%ebp),%eax
  80059d:	89 04 24             	mov    %eax,(%esp)
  8005a0:	e8 50 02 00 00       	call   8007f5 <printfmt>
			break;
  8005a5:	e9 3e 02 00 00       	jmp    8007e8 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 30                	mov    (%eax),%esi
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	75 05                	jne    8005be <vprintfmt+0x1af>
				p = "(null)";
  8005b9:	be 85 1d 80 00       	mov    $0x801d85,%esi
			if (width > 0 && padc != '-')
  8005be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c2:	7e 37                	jle    8005fb <vprintfmt+0x1ec>
  8005c4:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005c8:	74 31                	je     8005fb <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	89 34 24             	mov    %esi,(%esp)
  8005d4:	e8 39 03 00 00       	call   800912 <strnlen>
  8005d9:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005dc:	eb 17                	jmp    8005f5 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8005de:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8005e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ef:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f9:	7f e3                	jg     8005de <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fb:	eb 38                	jmp    800635 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8005fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800601:	74 1f                	je     800622 <vprintfmt+0x213>
  800603:	83 fb 1f             	cmp    $0x1f,%ebx
  800606:	7e 05                	jle    80060d <vprintfmt+0x1fe>
  800608:	83 fb 7e             	cmp    $0x7e,%ebx
  80060b:	7e 15                	jle    800622 <vprintfmt+0x213>
					putch('?', putdat);
  80060d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800610:	89 44 24 04          	mov    %eax,0x4(%esp)
  800614:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061b:	8b 45 08             	mov    0x8(%ebp),%eax
  80061e:	ff d0                	call   *%eax
  800620:	eb 0f                	jmp    800631 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800622:	8b 45 0c             	mov    0xc(%ebp),%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	89 1c 24             	mov    %ebx,(%esp)
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800631:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800635:	89 f0                	mov    %esi,%eax
  800637:	8d 70 01             	lea    0x1(%eax),%esi
  80063a:	0f b6 00             	movzbl (%eax),%eax
  80063d:	0f be d8             	movsbl %al,%ebx
  800640:	85 db                	test   %ebx,%ebx
  800642:	74 10                	je     800654 <vprintfmt+0x245>
  800644:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800648:	78 b3                	js     8005fd <vprintfmt+0x1ee>
  80064a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80064e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800652:	79 a9                	jns    8005fd <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800654:	eb 17                	jmp    80066d <vprintfmt+0x25e>
				putch(' ', putdat);
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800669:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80066d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800671:	7f e3                	jg     800656 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800673:	e9 70 01 00 00       	jmp    8007e8 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800678:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80067b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	89 04 24             	mov    %eax,(%esp)
  800685:	e8 3e fd ff ff       	call   8003c8 <getint>
  80068a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80068d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800693:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800696:	85 d2                	test   %edx,%edx
  800698:	79 26                	jns    8006c0 <vprintfmt+0x2b1>
				putch('-', putdat);
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	ff d0                	call   *%eax
				num = -(long long) num;
  8006ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006b3:	f7 d8                	neg    %eax
  8006b5:	83 d2 00             	adc    $0x0,%edx
  8006b8:	f7 da                	neg    %edx
  8006ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006c0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006c7:	e9 a8 00 00 00       	jmp    800774 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	e8 9b fc ff ff       	call   800379 <getuint>
  8006de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8006e4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006eb:	e9 84 00 00 00       	jmp    800774 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	e8 77 fc ff ff       	call   800379 <getuint>
  800702:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800705:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800708:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80070f:	eb 63                	jmp    800774 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	ff d0                	call   *%eax
			putch('x', putdat);
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8d 50 04             	lea    0x4(%eax),%edx
  80073d:	89 55 14             	mov    %edx,0x14(%ebp)
  800740:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800742:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800753:	eb 1f                	jmp    800774 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800755:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	e8 12 fc ff ff       	call   800379 <getuint>
  800767:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  80076d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800774:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	89 54 24 18          	mov    %edx,0x18(%esp)
  80077f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800782:	89 54 24 14          	mov    %edx,0x14(%esp)
  800786:	89 44 24 10          	mov    %eax,0x10(%esp)
  80078a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800790:	89 44 24 08          	mov    %eax,0x8(%esp)
  800794:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800798:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	89 04 24             	mov    %eax,(%esp)
  8007a5:	e8 f1 fa ff ff       	call   80029b <printnum>
			break;
  8007aa:	eb 3c                	jmp    8007e8 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b3:	89 1c 24             	mov    %ebx,(%esp)
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	ff d0                	call   *%eax
			break;
  8007bb:	eb 2b                	jmp    8007e8 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007d4:	eb 04                	jmp    8007da <vprintfmt+0x3cb>
  8007d6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	83 e8 01             	sub    $0x1,%eax
  8007e0:	0f b6 00             	movzbl (%eax),%eax
  8007e3:	3c 25                	cmp    $0x25,%al
  8007e5:	75 ef                	jne    8007d6 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8007e7:	90                   	nop
		}
	}
  8007e8:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e9:	e9 43 fc ff ff       	jmp    800431 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8007ee:	83 c4 40             	add    $0x40,%esp
  8007f1:	5b                   	pop    %ebx
  8007f2:	5e                   	pop    %esi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800804:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800808:	8b 45 10             	mov    0x10(%ebp),%eax
  80080b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800812:	89 44 24 04          	mov    %eax,0x4(%esp)
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	89 04 24             	mov    %eax,(%esp)
  80081c:	e8 ee fb ff ff       	call   80040f <vprintfmt>
	va_end(ap);
}
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	8b 40 08             	mov    0x8(%eax),%eax
  80082c:	8d 50 01             	lea    0x1(%eax),%edx
  80082f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800832:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083d:	8b 40 04             	mov    0x4(%eax),%eax
  800840:	39 c2                	cmp    %eax,%edx
  800842:	73 12                	jae    800856 <sprintputch+0x33>
		*b->buf++ = ch;
  800844:	8b 45 0c             	mov    0xc(%ebp),%eax
  800847:	8b 00                	mov    (%eax),%eax
  800849:	8d 48 01             	lea    0x1(%eax),%ecx
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 0a                	mov    %ecx,(%edx)
  800851:	8b 55 08             	mov    0x8(%ebp),%edx
  800854:	88 10                	mov    %dl,(%eax)
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800864:	8b 45 0c             	mov    0xc(%ebp),%eax
  800867:	8d 50 ff             	lea    -0x1(%eax),%edx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	01 d0                	add    %edx,%eax
  80086f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800872:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800879:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80087d:	74 06                	je     800885 <vsnprintf+0x2d>
  80087f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800883:	7f 07                	jg     80088c <vsnprintf+0x34>
		return -E_INVAL;
  800885:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088a:	eb 2a                	jmp    8008b6 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800893:	8b 45 10             	mov    0x10(%ebp),%eax
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	c7 04 24 23 08 80 00 	movl   $0x800823,(%esp)
  8008a8:	e8 62 fb ff ff       	call   80040f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008be:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	e8 74 ff ff ff       	call   800858 <vsnprintf>
  8008e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008f9:	eb 08                	jmp    800903 <strlen+0x17>
		n++;
  8008fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	0f b6 00             	movzbl (%eax),%eax
  800909:	84 c0                	test   %al,%al
  80090b:	75 ee                	jne    8008fb <strlen+0xf>
		n++;
	return n;
  80090d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800910:	c9                   	leave  
  800911:	c3                   	ret    

00800912 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800918:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80091f:	eb 0c                	jmp    80092d <strnlen+0x1b>
		n++;
  800921:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800929:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80092d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800931:	74 0a                	je     80093d <strnlen+0x2b>
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	0f b6 00             	movzbl (%eax),%eax
  800939:	84 c0                	test   %al,%al
  80093b:	75 e4                	jne    800921 <strnlen+0xf>
		n++;
	return n;
  80093d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80094e:	90                   	nop
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8d 50 01             	lea    0x1(%eax),%edx
  800955:	89 55 08             	mov    %edx,0x8(%ebp)
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80095e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800961:	0f b6 12             	movzbl (%edx),%edx
  800964:	88 10                	mov    %dl,(%eax)
  800966:	0f b6 00             	movzbl (%eax),%eax
  800969:	84 c0                	test   %al,%al
  80096b:	75 e2                	jne    80094f <strcpy+0xd>
		/* do nothing */;
	return ret;
  80096d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	e8 69 ff ff ff       	call   8008ec <strlen>
  800983:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800986:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	01 c2                	add    %eax,%edx
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800991:	89 44 24 04          	mov    %eax,0x4(%esp)
  800995:	89 14 24             	mov    %edx,(%esp)
  800998:	e8 a5 ff ff ff       	call   800942 <strcpy>
	return dst;
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009b5:	eb 23                	jmp    8009da <strncpy+0x38>
		*dst++ = *src;
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8d 50 01             	lea    0x1(%eax),%edx
  8009bd:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c3:	0f b6 12             	movzbl (%edx),%edx
  8009c6:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	0f b6 00             	movzbl (%eax),%eax
  8009ce:	84 c0                	test   %al,%al
  8009d0:	74 04                	je     8009d6 <strncpy+0x34>
			src++;
  8009d2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009dd:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009e0:	72 d5                	jb     8009b7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f7:	74 33                	je     800a2c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8009f9:	eb 17                	jmp    800a12 <strlcpy+0x2b>
			*dst++ = *src++;
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8d 50 01             	lea    0x1(%eax),%edx
  800a01:	89 55 08             	mov    %edx,0x8(%ebp)
  800a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a07:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a0a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a16:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a1a:	74 0a                	je     800a26 <strlcpy+0x3f>
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	0f b6 00             	movzbl (%eax),%eax
  800a22:	84 c0                	test   %al,%al
  800a24:	75 d5                	jne    8009fb <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a32:	29 c2                	sub    %eax,%edx
  800a34:	89 d0                	mov    %edx,%eax
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a3b:	eb 08                	jmp    800a45 <strcmp+0xd>
		p++, q++;
  800a3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a41:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	0f b6 00             	movzbl (%eax),%eax
  800a4b:	84 c0                	test   %al,%al
  800a4d:	74 10                	je     800a5f <strcmp+0x27>
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	0f b6 10             	movzbl (%eax),%edx
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	0f b6 00             	movzbl (%eax),%eax
  800a5b:	38 c2                	cmp    %al,%dl
  800a5d:	74 de                	je     800a3d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	0f b6 00             	movzbl (%eax),%eax
  800a65:	0f b6 d0             	movzbl %al,%edx
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	0f b6 00             	movzbl (%eax),%eax
  800a6e:	0f b6 c0             	movzbl %al,%eax
  800a71:	29 c2                	sub    %eax,%edx
  800a73:	89 d0                	mov    %edx,%eax
}
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a7a:	eb 0c                	jmp    800a88 <strncmp+0x11>
		n--, p++, q++;
  800a7c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a80:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a84:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a8c:	74 1a                	je     800aa8 <strncmp+0x31>
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 00             	movzbl (%eax),%eax
  800a94:	84 c0                	test   %al,%al
  800a96:	74 10                	je     800aa8 <strncmp+0x31>
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	0f b6 10             	movzbl (%eax),%edx
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	0f b6 00             	movzbl (%eax),%eax
  800aa4:	38 c2                	cmp    %al,%dl
  800aa6:	74 d4                	je     800a7c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800aa8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aac:	75 07                	jne    800ab5 <strncmp+0x3e>
		return 0;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	eb 16                	jmp    800acb <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	0f b6 00             	movzbl (%eax),%eax
  800abb:	0f b6 d0             	movzbl %al,%edx
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	0f b6 00             	movzbl (%eax),%eax
  800ac4:	0f b6 c0             	movzbl %al,%eax
  800ac7:	29 c2                	sub    %eax,%edx
  800ac9:	89 d0                	mov    %edx,%eax
}
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	83 ec 04             	sub    $0x4,%esp
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ad9:	eb 14                	jmp    800aef <strchr+0x22>
		if (*s == c)
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	0f b6 00             	movzbl (%eax),%eax
  800ae1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ae4:	75 05                	jne    800aeb <strchr+0x1e>
			return (char *) s;
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	eb 13                	jmp    800afe <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aeb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	84 c0                	test   %al,%al
  800af7:	75 e2                	jne    800adb <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	83 ec 04             	sub    $0x4,%esp
  800b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b09:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b0c:	eb 11                	jmp    800b1f <strfind+0x1f>
		if (*s == c)
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 00             	movzbl (%eax),%eax
  800b14:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b17:	75 02                	jne    800b1b <strfind+0x1b>
			break;
  800b19:	eb 0e                	jmp    800b29 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	0f b6 00             	movzbl (%eax),%eax
  800b25:	84 c0                	test   %al,%al
  800b27:	75 e5                	jne    800b0e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b36:	75 05                	jne    800b3d <memset+0xf>
		return v;
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	eb 5c                	jmp    800b99 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	83 e0 03             	and    $0x3,%eax
  800b43:	85 c0                	test   %eax,%eax
  800b45:	75 41                	jne    800b88 <memset+0x5a>
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	83 e0 03             	and    $0x3,%eax
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	75 37                	jne    800b88 <memset+0x5a>
		c &= 0xFF;
  800b51:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5b:	c1 e0 18             	shl    $0x18,%eax
  800b5e:	89 c2                	mov    %eax,%edx
  800b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b63:	c1 e0 10             	shl    $0x10,%eax
  800b66:	09 c2                	or     %eax,%edx
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	c1 e0 08             	shl    $0x8,%eax
  800b6e:	09 d0                	or     %edx,%eax
  800b70:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	c1 e8 02             	shr    $0x2,%eax
  800b79:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	89 d7                	mov    %edx,%edi
  800b83:	fc                   	cld    
  800b84:	f3 ab                	rep stos %eax,%es:(%edi)
  800b86:	eb 0e                	jmp    800b96 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	fc                   	cld    
  800b94:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bb7:	73 6d                	jae    800c26 <memmove+0x8a>
  800bb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bbf:	01 d0                	add    %edx,%eax
  800bc1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bc4:	76 60                	jbe    800c26 <memmove+0x8a>
		s += n;
  800bc6:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc9:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd5:	83 e0 03             	and    $0x3,%eax
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	75 2f                	jne    800c0b <memmove+0x6f>
  800bdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bdf:	83 e0 03             	and    $0x3,%eax
  800be2:	85 c0                	test   %eax,%eax
  800be4:	75 25                	jne    800c0b <memmove+0x6f>
  800be6:	8b 45 10             	mov    0x10(%ebp),%eax
  800be9:	83 e0 03             	and    $0x3,%eax
  800bec:	85 c0                	test   %eax,%eax
  800bee:	75 1b                	jne    800c0b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf3:	83 e8 04             	sub    $0x4,%eax
  800bf6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf9:	83 ea 04             	sub    $0x4,%edx
  800bfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bff:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c02:	89 c7                	mov    %eax,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	fd                   	std    
  800c07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c09:	eb 18                	jmp    800c23 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c14:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c17:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1a:	89 d7                	mov    %edx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	89 c1                	mov    %eax,%ecx
  800c20:	fd                   	std    
  800c21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c23:	fc                   	cld    
  800c24:	eb 45                	jmp    800c6b <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c29:	83 e0 03             	and    $0x3,%eax
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	75 2b                	jne    800c5b <memmove+0xbf>
  800c30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c33:	83 e0 03             	and    $0x3,%eax
  800c36:	85 c0                	test   %eax,%eax
  800c38:	75 21                	jne    800c5b <memmove+0xbf>
  800c3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3d:	83 e0 03             	and    $0x3,%eax
  800c40:	85 c0                	test   %eax,%eax
  800c42:	75 17                	jne    800c5b <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c44:	8b 45 10             	mov    0x10(%ebp),%eax
  800c47:	c1 e8 02             	shr    $0x2,%eax
  800c4a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c52:	89 c7                	mov    %eax,%edi
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	fc                   	cld    
  800c57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c59:	eb 10                	jmp    800c6b <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c5e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c61:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c64:	89 c7                	mov    %eax,%edi
  800c66:	89 d6                	mov    %edx,%esi
  800c68:	fc                   	cld    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	89 04 24             	mov    %eax,(%esp)
  800c90:	e8 07 ff ff ff       	call   800b9c <memmove>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ca9:	eb 30                	jmp    800cdb <memcmp+0x44>
		if (*s1 != *s2)
  800cab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cae:	0f b6 10             	movzbl (%eax),%edx
  800cb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cb4:	0f b6 00             	movzbl (%eax),%eax
  800cb7:	38 c2                	cmp    %al,%dl
  800cb9:	74 18                	je     800cd3 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cbe:	0f b6 00             	movzbl (%eax),%eax
  800cc1:	0f b6 d0             	movzbl %al,%edx
  800cc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cc7:	0f b6 00             	movzbl (%eax),%eax
  800cca:	0f b6 c0             	movzbl %al,%eax
  800ccd:	29 c2                	sub    %eax,%edx
  800ccf:	89 d0                	mov    %edx,%eax
  800cd1:	eb 1a                	jmp    800ced <memcmp+0x56>
		s1++, s2++;
  800cd3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cd7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cde:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ce1:	89 55 10             	mov    %edx,0x10(%ebp)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	75 c3                	jne    800cab <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800cf5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	01 d0                	add    %edx,%eax
  800cfd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d00:	eb 13                	jmp    800d15 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	0f b6 10             	movzbl (%eax),%edx
  800d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0b:	38 c2                	cmp    %al,%dl
  800d0d:	75 02                	jne    800d11 <memfind+0x22>
			break;
  800d0f:	eb 0c                	jmp    800d1d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d11:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d1b:	72 e5                	jb     800d02 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d2f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d36:	eb 04                	jmp    800d3c <strtol+0x1a>
		s++;
  800d38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	0f b6 00             	movzbl (%eax),%eax
  800d42:	3c 20                	cmp    $0x20,%al
  800d44:	74 f2                	je     800d38 <strtol+0x16>
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	0f b6 00             	movzbl (%eax),%eax
  800d4c:	3c 09                	cmp    $0x9,%al
  800d4e:	74 e8                	je     800d38 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	0f b6 00             	movzbl (%eax),%eax
  800d56:	3c 2b                	cmp    $0x2b,%al
  800d58:	75 06                	jne    800d60 <strtol+0x3e>
		s++;
  800d5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5e:	eb 15                	jmp    800d75 <strtol+0x53>
	else if (*s == '-')
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	3c 2d                	cmp    $0x2d,%al
  800d68:	75 0b                	jne    800d75 <strtol+0x53>
		s++, neg = 1;
  800d6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d6e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d79:	74 06                	je     800d81 <strtol+0x5f>
  800d7b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d7f:	75 24                	jne    800da5 <strtol+0x83>
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	0f b6 00             	movzbl (%eax),%eax
  800d87:	3c 30                	cmp    $0x30,%al
  800d89:	75 1a                	jne    800da5 <strtol+0x83>
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	83 c0 01             	add    $0x1,%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	3c 78                	cmp    $0x78,%al
  800d96:	75 0d                	jne    800da5 <strtol+0x83>
		s += 2, base = 16;
  800d98:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d9c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800da3:	eb 2a                	jmp    800dcf <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800da5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da9:	75 17                	jne    800dc2 <strtol+0xa0>
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	3c 30                	cmp    $0x30,%al
  800db3:	75 0d                	jne    800dc2 <strtol+0xa0>
		s++, base = 8;
  800db5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800dc0:	eb 0d                	jmp    800dcf <strtol+0xad>
	else if (base == 0)
  800dc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc6:	75 07                	jne    800dcf <strtol+0xad>
		base = 10;
  800dc8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	0f b6 00             	movzbl (%eax),%eax
  800dd5:	3c 2f                	cmp    $0x2f,%al
  800dd7:	7e 1b                	jle    800df4 <strtol+0xd2>
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	3c 39                	cmp    $0x39,%al
  800de1:	7f 11                	jg     800df4 <strtol+0xd2>
			dig = *s - '0';
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	0f be c0             	movsbl %al,%eax
  800dec:	83 e8 30             	sub    $0x30,%eax
  800def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800df2:	eb 48                	jmp    800e3c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	0f b6 00             	movzbl (%eax),%eax
  800dfa:	3c 60                	cmp    $0x60,%al
  800dfc:	7e 1b                	jle    800e19 <strtol+0xf7>
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	0f b6 00             	movzbl (%eax),%eax
  800e04:	3c 7a                	cmp    $0x7a,%al
  800e06:	7f 11                	jg     800e19 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	0f b6 00             	movzbl (%eax),%eax
  800e0e:	0f be c0             	movsbl %al,%eax
  800e11:	83 e8 57             	sub    $0x57,%eax
  800e14:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e17:	eb 23                	jmp    800e3c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e19:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1c:	0f b6 00             	movzbl (%eax),%eax
  800e1f:	3c 40                	cmp    $0x40,%al
  800e21:	7e 3d                	jle    800e60 <strtol+0x13e>
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	0f b6 00             	movzbl (%eax),%eax
  800e29:	3c 5a                	cmp    $0x5a,%al
  800e2b:	7f 33                	jg     800e60 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 00             	movzbl (%eax),%eax
  800e33:	0f be c0             	movsbl %al,%eax
  800e36:	83 e8 37             	sub    $0x37,%eax
  800e39:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e42:	7c 02                	jl     800e46 <strtol+0x124>
			break;
  800e44:	eb 1a                	jmp    800e60 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e4d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e51:	89 c2                	mov    %eax,%edx
  800e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e56:	01 d0                	add    %edx,%eax
  800e58:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e5b:	e9 6f ff ff ff       	jmp    800dcf <strtol+0xad>

	if (endptr)
  800e60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e64:	74 08                	je     800e6e <strtol+0x14c>
		*endptr = (char *) s;
  800e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e69:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e6e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e72:	74 07                	je     800e7b <strtol+0x159>
  800e74:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e77:	f7 d8                	neg    %eax
  800e79:	eb 03                	jmp    800e7e <strtol+0x15c>
  800e7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e8f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800e92:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800e95:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800e98:	8b 75 20             	mov    0x20(%ebp),%esi
  800e9b:	cd 30                	int    $0x30
  800e9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ea4:	74 30                	je     800ed6 <syscall+0x56>
  800ea6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800eaa:	7e 2a                	jle    800ed6 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eaf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eba:	c7 44 24 08 e4 1e 80 	movl   $0x801ee4,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 01 1f 80 00 	movl   $0x801f01,(%esp)
  800ed1:	e8 d3 09 00 00       	call   8018a9 <_panic>

	return ret;
  800ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800ed9:	83 c4 3c             	add    $0x3c,%esp
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ef9:	00 
  800efa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f01:	00 
  800f02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f05:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1c:	e8 5f ff ff ff       	call   800e80 <syscall>
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f29:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f30:	00 
  800f31:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f38:	00 
  800f39:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f40:	00 
  800f41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f48:	00 
  800f49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f60:	e8 1b ff ff ff       	call   800e80 <syscall>
}
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f70:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f77:	00 
  800f78:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f7f:	00 
  800f80:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f87:	00 
  800f88:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f8f:	00 
  800f90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f94:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f9b:	00 
  800f9c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fa3:	e8 d8 fe ff ff       	call   800e80 <syscall>
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fb0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fcf:	00 
  800fd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fdf:	00 
  800fe0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800fe7:	e8 94 fe ff ff       	call   800e80 <syscall>
}
  800fec:	c9                   	leave  
  800fed:	c3                   	ret    

00800fee <sys_yield>:

void
sys_yield(void)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ff4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801003:	00 
  801004:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80100b:	00 
  80100c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801013:	00 
  801014:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80101b:	00 
  80101c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801023:	00 
  801024:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80102b:	e8 50 fe ff ff       	call   800e80 <syscall>
}
  801030:	c9                   	leave  
  801031:	c3                   	ret    

00801032 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801038:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80103b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801048:	00 
  801049:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801050:	00 
  801051:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801055:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801059:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801064:	00 
  801065:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80106c:	e8 0f fe ff ff       	call   800e80 <syscall>
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80107b:	8b 75 18             	mov    0x18(%ebp),%esi
  80107e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801081:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801084:	8b 55 0c             	mov    0xc(%ebp),%edx
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	89 74 24 18          	mov    %esi,0x18(%esp)
  80108e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  801092:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801096:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80109a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80109e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a5:	00 
  8010a6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010ad:	e8 ce fd ff ff       	call   800e80 <syscall>
}
  8010b2:	83 c4 20             	add    $0x20,%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010cc:	00 
  8010cd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010dc:	00 
  8010dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ec:	00 
  8010ed:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  8010f4:	e8 87 fd ff ff       	call   800e80 <syscall>
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801101:	8b 55 0c             	mov    0xc(%ebp),%edx
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80110e:	00 
  80110f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801116:	00 
  801117:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80111e:	00 
  80111f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801123:	89 44 24 08          	mov    %eax,0x8(%esp)
  801127:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801136:	e8 45 fd ff ff       	call   800e80 <syscall>
}
  80113b:	c9                   	leave  
  80113c:	c3                   	ret    

0080113d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801150:	00 
  801151:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801158:	00 
  801159:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801160:	00 
  801161:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801165:	89 44 24 08          	mov    %eax,0x8(%esp)
  801169:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801170:	00 
  801171:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801178:	e8 03 fd ff ff       	call   800e80 <syscall>
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801185:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801188:	8b 55 10             	mov    0x10(%ebp),%edx
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801195:	00 
  801196:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80119a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80119e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011b0:	00 
  8011b1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011b8:	e8 c3 fc ff ff       	call   800e80 <syscall>
}
  8011bd:	c9                   	leave  
  8011be:	c3                   	ret    

008011bf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011df:	00 
  8011e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011e7:	00 
  8011e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011f3:	00 
  8011f4:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  8011fb:	e8 80 fc ff ff       	call   800e80 <syscall>
}
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <sys_exec>:

void sys_exec(char* buf){
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801208:	8b 45 08             	mov    0x8(%ebp),%eax
  80120b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801212:	00 
  801213:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80121a:	00 
  80121b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801222:	00 
  801223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80122a:	00 
  80122b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801236:	00 
  801237:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80123e:	e8 3d fc ff ff       	call   800e80 <syscall>
}
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <sys_wait>:

void sys_wait(){
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80124b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801252:	00 
  801253:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80125a:	00 
  80125b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801262:	00 
  801263:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80126a:	00 
  80126b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80127a:	00 
  80127b:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  801282:	e8 f9 fb ff ff       	call   800e80 <syscall>
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	8b 00                	mov    (%eax),%eax
  801294:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801297:	8b 45 08             	mov    0x8(%ebp),%eax
  80129a:	8b 40 04             	mov    0x4(%eax),%eax
  80129d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  8012a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a3:	83 e0 02             	and    $0x2,%eax
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	75 23                	jne    8012cd <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8012aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b1:	c7 44 24 08 10 1f 80 	movl   $0x801f10,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8012c8:	e8 dc 05 00 00       	call   8018a9 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  8012cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d0:	c1 e8 0c             	shr    $0xc,%eax
  8012d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8012d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e0:	25 00 08 00 00       	and    $0x800,%eax
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	75 1c                	jne    801305 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8012e9:	c7 44 24 08 4c 1f 80 	movl   $0x801f4c,0x8(%esp)
  8012f0:	00 
  8012f1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8012f8:	00 
  8012f9:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801300:	e8 a4 05 00 00       	call   8018a9 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  801305:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131c:	e8 11 fd ff ff       	call   801032 <sys_page_alloc>
  801321:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801324:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801328:	79 23                	jns    80134d <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  80132a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80132d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801331:	c7 44 24 08 88 1f 80 	movl   $0x801f88,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801348:	e8 5c 05 00 00       	call   8018a9 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801353:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801356:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80135b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801362:	00 
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80136e:	e8 03 f9 ff ff       	call   800c76 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801379:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801381:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801388:	00 
  801389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a4:	e8 ca fc ff ff       	call   801073 <sys_page_map>
  8013a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8013ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013b0:	79 23                	jns    8013d5 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8013b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b9:	c7 44 24 08 c0 1f 80 	movl   $0x801fc0,0x8(%esp)
  8013c0:	00 
  8013c1:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  8013c8:	00 
  8013c9:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8013d0:	e8 d4 04 00 00       	call   8018a9 <_panic>
	}

	// panic("pgfault not implemented");
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8013df:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8013e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f0:	25 00 08 00 00       	and    $0x800,%eax
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	75 15                	jne    80140e <duppage+0x37>
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801403:	83 e0 02             	and    $0x2,%eax
  801406:	85 c0                	test   %eax,%eax
  801408:	0f 84 e0 00 00 00    	je     8014ee <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  80140e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801411:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801418:	83 e0 04             	and    $0x4,%eax
  80141b:	85 c0                	test   %eax,%eax
  80141d:	74 04                	je     801423 <duppage+0x4c>
  80141f:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  801423:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801426:	8b 45 0c             	mov    0xc(%ebp),%eax
  801429:	c1 e0 0c             	shl    $0xc,%eax
  80142c:	89 c1                	mov    %eax,%ecx
  80142e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801431:	c1 e0 0c             	shl    $0xc,%eax
  801434:	89 c2                	mov    %eax,%edx
  801436:	a1 08 30 80 00       	mov    0x803008,%eax
  80143b:	8b 40 48             	mov    0x48(%eax),%eax
  80143e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801442:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801449:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80144d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801451:	89 04 24             	mov    %eax,(%esp)
  801454:	e8 1a fc ff ff       	call   801073 <sys_page_map>
  801459:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80145c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801460:	79 23                	jns    801485 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801469:	c7 44 24 08 f4 1f 80 	movl   $0x801ff4,0x8(%esp)
  801470:	00 
  801471:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801478:	00 
  801479:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801480:	e8 24 04 00 00       	call   8018a9 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801485:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148b:	c1 e0 0c             	shl    $0xc,%eax
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	a1 08 30 80 00       	mov    0x803008,%eax
  801495:	8b 48 48             	mov    0x48(%eax),%ecx
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	c1 e0 0c             	shl    $0xc,%eax
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	a1 08 30 80 00       	mov    0x803008,%eax
  8014a5:	8b 40 48             	mov    0x48(%eax),%eax
  8014a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014b8:	89 04 24             	mov    %eax,(%esp)
  8014bb:	e8 b3 fb ff ff       	call   801073 <sys_page_map>
  8014c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014c7:	79 23                	jns    8014ec <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  8014c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d0:	c7 44 24 08 30 20 80 	movl   $0x802030,0x8(%esp)
  8014d7:	00 
  8014d8:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8014df:	00 
  8014e0:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8014e7:	e8 bd 03 00 00       	call   8018a9 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014ec:	eb 70                	jmp    80155e <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  8014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f8:	25 ff 0f 00 00       	and    $0xfff,%eax
  8014fd:	89 c3                	mov    %eax,%ebx
  8014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801502:	c1 e0 0c             	shl    $0xc,%eax
  801505:	89 c1                	mov    %eax,%ecx
  801507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150a:	c1 e0 0c             	shl    $0xc,%eax
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	a1 08 30 80 00       	mov    0x803008,%eax
  801514:	8b 40 48             	mov    0x48(%eax),%eax
  801517:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80151b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80151f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801522:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801526:	89 54 24 04          	mov    %edx,0x4(%esp)
  80152a:	89 04 24             	mov    %eax,(%esp)
  80152d:	e8 41 fb ff ff       	call   801073 <sys_page_map>
  801532:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801535:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801539:	79 23                	jns    80155e <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  80153b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801542:	c7 44 24 08 60 20 80 	movl   $0x802060,0x8(%esp)
  801549:	00 
  80154a:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801551:	00 
  801552:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801559:	e8 4b 03 00 00       	call   8018a9 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  80155e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801563:	83 c4 30             	add    $0x30,%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801570:	c7 04 24 89 12 80 00 	movl   $0x801289,(%esp)
  801577:	e8 88 03 00 00       	call   801904 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80157c:	b8 07 00 00 00       	mov    $0x7,%eax
  801581:	cd 30                	int    $0x30
  801583:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801586:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  801589:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  80158c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801590:	79 23                	jns    8015b5 <fork+0x4b>
  801592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801595:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801599:	c7 44 24 08 98 20 80 	movl   $0x802098,0x8(%esp)
  8015a0:	00 
  8015a1:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015a8:	00 
  8015a9:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8015b0:	e8 f4 02 00 00       	call   8018a9 <_panic>
	else if(childeid == 0){
  8015b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015b9:	75 29                	jne    8015e4 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8015bb:	e8 ea f9 ff ff       	call   800faa <sys_getenvid>
  8015c0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015c5:	c1 e0 02             	shl    $0x2,%eax
  8015c8:	89 c2                	mov    %eax,%edx
  8015ca:	c1 e2 05             	shl    $0x5,%edx
  8015cd:	29 c2                	sub    %eax,%edx
  8015cf:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8015d5:	a3 08 30 80 00       	mov    %eax,0x803008
		// set_pgfault_handler(pgfault);
		return 0;
  8015da:	b8 00 00 00 00       	mov    $0x0,%eax
  8015df:	e9 16 01 00 00       	jmp    8016fa <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8015eb:	eb 3b                	jmp    801628 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  8015ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f0:	c1 f8 0a             	sar    $0xa,%eax
  8015f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015fa:	83 e0 01             	and    $0x1,%eax
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 23                	je     801624 <fork+0xba>
  801601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160b:	83 e0 01             	and    $0x1,%eax
  80160e:	85 c0                	test   %eax,%eax
  801610:	74 12                	je     801624 <fork+0xba>
			duppage(childeid, i);
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	89 44 24 04          	mov    %eax,0x4(%esp)
  801619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 b3 fd ff ff       	call   8013d7 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801624:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801630:	76 bb                	jbe    8015ed <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801632:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801639:	00 
  80163a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801641:	ee 
  801642:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801645:	89 04 24             	mov    %eax,(%esp)
  801648:	e8 e5 f9 ff ff       	call   801032 <sys_page_alloc>
  80164d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801650:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801654:	79 23                	jns    801679 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  801656:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80165d:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  801664:	00 
  801665:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  80166c:	00 
  80166d:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801674:	e8 30 02 00 00       	call   8018a9 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  801679:	c7 44 24 04 7a 19 80 	movl   $0x80197a,0x4(%esp)
  801680:	00 
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	89 04 24             	mov    %eax,(%esp)
  801687:	e8 b1 fa ff ff       	call   80113d <sys_env_set_pgfault_upcall>
  80168c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80168f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801693:	79 23                	jns    8016b8 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  801695:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801698:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80169c:	c7 44 24 08 e8 20 80 	movl   $0x8020e8,0x8(%esp)
  8016a3:	00 
  8016a4:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8016ab:	00 
  8016ac:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8016b3:	e8 f1 01 00 00       	call   8018a9 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  8016b8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016bf:	00 
  8016c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c3:	89 04 24             	mov    %eax,(%esp)
  8016c6:	e8 30 fa ff ff       	call   8010fb <sys_env_set_status>
  8016cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016ce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016d2:	79 23                	jns    8016f7 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8016d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016db:	c7 44 24 08 1c 21 80 	movl   $0x80211c,0x8(%esp)
  8016e2:	00 
  8016e3:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8016ea:	00 
  8016eb:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8016f2:	e8 b2 01 00 00       	call   8018a9 <_panic>
	}
	return childeid;
  8016f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <sfork>:

// Challenge!
int
sfork(void)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801702:	c7 44 24 08 45 21 80 	movl   $0x802145,0x8(%esp)
  801709:	00 
  80170a:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801711:	00 
  801712:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  801719:	e8 8b 01 00 00       	call   8018a9 <_panic>

0080171e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  801724:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801728:	75 09                	jne    801733 <ipc_recv+0x15>
		i_dstva = UTOP;
  80172a:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  801731:	eb 06                	jmp    801739 <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  801733:	8b 45 0c             	mov    0xc(%ebp),%eax
  801736:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  801739:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173c:	89 04 24             	mov    %eax,(%esp)
  80173f:	e8 7b fa ff ff       	call   8011bf <sys_ipc_recv>
  801744:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  801747:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80174b:	75 15                	jne    801762 <ipc_recv+0x44>
  80174d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801751:	74 0f                	je     801762 <ipc_recv+0x44>
  801753:	a1 08 30 80 00       	mov    0x803008,%eax
  801758:	8b 50 74             	mov    0x74(%eax),%edx
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	89 10                	mov    %edx,(%eax)
  801760:	eb 15                	jmp    801777 <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  801762:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801766:	79 0f                	jns    801777 <ipc_recv+0x59>
  801768:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80176c:	74 09                	je     801777 <ipc_recv+0x59>
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  801777:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80177b:	75 15                	jne    801792 <ipc_recv+0x74>
  80177d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801781:	74 0f                	je     801792 <ipc_recv+0x74>
  801783:	a1 08 30 80 00       	mov    0x803008,%eax
  801788:	8b 50 78             	mov    0x78(%eax),%edx
  80178b:	8b 45 10             	mov    0x10(%ebp),%eax
  80178e:	89 10                	mov    %edx,(%eax)
  801790:	eb 15                	jmp    8017a7 <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  801792:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801796:	79 0f                	jns    8017a7 <ipc_recv+0x89>
  801798:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80179c:	74 09                	je     8017a7 <ipc_recv+0x89>
  80179e:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  8017a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017ab:	75 0a                	jne    8017b7 <ipc_recv+0x99>
  8017ad:	a1 08 30 80 00       	mov    0x803008,%eax
  8017b2:	8b 40 70             	mov    0x70(%eax),%eax
  8017b5:	eb 03                	jmp    8017ba <ipc_recv+0x9c>
	else return r;
  8017b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  8017ba:	c9                   	leave  
  8017bb:	c3                   	ret    

008017bc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  8017c2:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  8017c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017cd:	74 06                	je     8017d5 <ipc_send+0x19>
  8017cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8017db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 8a f9 ff ff       	call   80117f <sys_ipc_try_send>
  8017f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  8017f8:	eb 28                	jmp    801822 <ipc_send+0x66>
		sys_yield();
  8017fa:	e8 ef f7 ff ff       	call   800fee <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8017ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801802:	8b 55 14             	mov    0x14(%ebp),%edx
  801805:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801809:	89 44 24 08          	mov    %eax,0x8(%esp)
  80180d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801810:	89 44 24 04          	mov    %eax,0x4(%esp)
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	89 04 24             	mov    %eax,(%esp)
  80181a:	e8 60 f9 ff ff       	call   80117f <sys_ipc_try_send>
  80181f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  801822:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  801826:	74 d2                	je     8017fa <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  801828:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80182c:	75 02                	jne    801830 <ipc_send+0x74>
  80182e:	eb 23                	jmp    801853 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  801830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801833:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801837:	c7 44 24 08 5c 21 80 	movl   $0x80215c,0x8(%esp)
  80183e:	00 
  80183f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801846:	00 
  801847:	c7 04 24 81 21 80 00 	movl   $0x802181,(%esp)
  80184e:	e8 56 00 00 00       	call   8018a9 <_panic>
	panic("ipc_send not implemented");
}
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  80185b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801862:	eb 35                	jmp    801899 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801864:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801867:	c1 e0 02             	shl    $0x2,%eax
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	c1 e2 05             	shl    $0x5,%edx
  80186f:	29 c2                	sub    %eax,%edx
  801871:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  801877:	8b 00                	mov    (%eax),%eax
  801879:	3b 45 08             	cmp    0x8(%ebp),%eax
  80187c:	75 17                	jne    801895 <ipc_find_env+0x40>
			return envs[i].env_id;
  80187e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801881:	c1 e0 02             	shl    $0x2,%eax
  801884:	89 c2                	mov    %eax,%edx
  801886:	c1 e2 05             	shl    $0x5,%edx
  801889:	29 c2                	sub    %eax,%edx
  80188b:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  801891:	8b 00                	mov    (%eax),%eax
  801893:	eb 12                	jmp    8018a7 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801895:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801899:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8018a0:	7e c2                	jle    801864 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8018b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b3:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018b6:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8018bc:	e8 e9 f6 ff ff       	call   800faa <sys_getenvid>
  8018c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d7:	c7 04 24 8c 21 80 00 	movl   $0x80218c,(%esp)
  8018de:	e8 92 e9 ff ff       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8018ed:	89 04 24             	mov    %eax,(%esp)
  8018f0:	e8 1c e9 ff ff       	call   800211 <vcprintf>
	cprintf("\n");
  8018f5:	c7 04 24 af 21 80 00 	movl   $0x8021af,(%esp)
  8018fc:	e8 74 e9 ff ff       	call   800275 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801901:	cc                   	int3   
  801902:	eb fd                	jmp    801901 <_panic+0x58>

00801904 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80190a:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80190f:	85 c0                	test   %eax,%eax
  801911:	75 5d                	jne    801970 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801913:	a1 08 30 80 00       	mov    0x803008,%eax
  801918:	8b 40 48             	mov    0x48(%eax),%eax
  80191b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801922:	00 
  801923:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80192a:	ee 
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	e8 ff f6 ff ff       	call   801032 <sys_page_alloc>
  801933:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801936:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80193a:	79 1c                	jns    801958 <set_pgfault_handler+0x54>
  80193c:	c7 44 24 08 b4 21 80 	movl   $0x8021b4,0x8(%esp)
  801943:	00 
  801944:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80194b:	00 
  80194c:	c7 04 24 e0 21 80 00 	movl   $0x8021e0,(%esp)
  801953:	e8 51 ff ff ff       	call   8018a9 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801958:	a1 08 30 80 00       	mov    0x803008,%eax
  80195d:	8b 40 48             	mov    0x48(%eax),%eax
  801960:	c7 44 24 04 7a 19 80 	movl   $0x80197a,0x4(%esp)
  801967:	00 
  801968:	89 04 24             	mov    %eax,(%esp)
  80196b:	e8 cd f7 ff ff       	call   80113d <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80197a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80197b:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  801980:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801982:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801985:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801989:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80198b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80198f:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801990:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801993:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801995:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801996:	58                   	pop    %eax
	popal 						// pop all the registers
  801997:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801998:	83 c4 04             	add    $0x4,%esp
	popfl
  80199b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80199c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80199d:	c3                   	ret    
  80199e:	66 90                	xchg   %ax,%ax

008019a0 <__udivdi3>:
  8019a0:	55                   	push   %ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8019ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8019b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019bc:	89 ea                	mov    %ebp,%edx
  8019be:	89 0c 24             	mov    %ecx,(%esp)
  8019c1:	75 2d                	jne    8019f0 <__udivdi3+0x50>
  8019c3:	39 e9                	cmp    %ebp,%ecx
  8019c5:	77 61                	ja     801a28 <__udivdi3+0x88>
  8019c7:	85 c9                	test   %ecx,%ecx
  8019c9:	89 ce                	mov    %ecx,%esi
  8019cb:	75 0b                	jne    8019d8 <__udivdi3+0x38>
  8019cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d2:	31 d2                	xor    %edx,%edx
  8019d4:	f7 f1                	div    %ecx
  8019d6:	89 c6                	mov    %eax,%esi
  8019d8:	31 d2                	xor    %edx,%edx
  8019da:	89 e8                	mov    %ebp,%eax
  8019dc:	f7 f6                	div    %esi
  8019de:	89 c5                	mov    %eax,%ebp
  8019e0:	89 f8                	mov    %edi,%eax
  8019e2:	f7 f6                	div    %esi
  8019e4:	89 ea                	mov    %ebp,%edx
  8019e6:	83 c4 0c             	add    $0xc,%esp
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    
  8019ed:	8d 76 00             	lea    0x0(%esi),%esi
  8019f0:	39 e8                	cmp    %ebp,%eax
  8019f2:	77 24                	ja     801a18 <__udivdi3+0x78>
  8019f4:	0f bd e8             	bsr    %eax,%ebp
  8019f7:	83 f5 1f             	xor    $0x1f,%ebp
  8019fa:	75 3c                	jne    801a38 <__udivdi3+0x98>
  8019fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a00:	39 34 24             	cmp    %esi,(%esp)
  801a03:	0f 86 9f 00 00 00    	jbe    801aa8 <__udivdi3+0x108>
  801a09:	39 d0                	cmp    %edx,%eax
  801a0b:	0f 82 97 00 00 00    	jb     801aa8 <__udivdi3+0x108>
  801a11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a18:	31 d2                	xor    %edx,%edx
  801a1a:	31 c0                	xor    %eax,%eax
  801a1c:	83 c4 0c             	add    $0xc,%esp
  801a1f:	5e                   	pop    %esi
  801a20:	5f                   	pop    %edi
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    
  801a23:	90                   	nop
  801a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a28:	89 f8                	mov    %edi,%eax
  801a2a:	f7 f1                	div    %ecx
  801a2c:	31 d2                	xor    %edx,%edx
  801a2e:	83 c4 0c             	add    $0xc,%esp
  801a31:	5e                   	pop    %esi
  801a32:	5f                   	pop    %edi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    
  801a35:	8d 76 00             	lea    0x0(%esi),%esi
  801a38:	89 e9                	mov    %ebp,%ecx
  801a3a:	8b 3c 24             	mov    (%esp),%edi
  801a3d:	d3 e0                	shl    %cl,%eax
  801a3f:	89 c6                	mov    %eax,%esi
  801a41:	b8 20 00 00 00       	mov    $0x20,%eax
  801a46:	29 e8                	sub    %ebp,%eax
  801a48:	89 c1                	mov    %eax,%ecx
  801a4a:	d3 ef                	shr    %cl,%edi
  801a4c:	89 e9                	mov    %ebp,%ecx
  801a4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a52:	8b 3c 24             	mov    (%esp),%edi
  801a55:	09 74 24 08          	or     %esi,0x8(%esp)
  801a59:	89 d6                	mov    %edx,%esi
  801a5b:	d3 e7                	shl    %cl,%edi
  801a5d:	89 c1                	mov    %eax,%ecx
  801a5f:	89 3c 24             	mov    %edi,(%esp)
  801a62:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a66:	d3 ee                	shr    %cl,%esi
  801a68:	89 e9                	mov    %ebp,%ecx
  801a6a:	d3 e2                	shl    %cl,%edx
  801a6c:	89 c1                	mov    %eax,%ecx
  801a6e:	d3 ef                	shr    %cl,%edi
  801a70:	09 d7                	or     %edx,%edi
  801a72:	89 f2                	mov    %esi,%edx
  801a74:	89 f8                	mov    %edi,%eax
  801a76:	f7 74 24 08          	divl   0x8(%esp)
  801a7a:	89 d6                	mov    %edx,%esi
  801a7c:	89 c7                	mov    %eax,%edi
  801a7e:	f7 24 24             	mull   (%esp)
  801a81:	39 d6                	cmp    %edx,%esi
  801a83:	89 14 24             	mov    %edx,(%esp)
  801a86:	72 30                	jb     801ab8 <__udivdi3+0x118>
  801a88:	8b 54 24 04          	mov    0x4(%esp),%edx
  801a8c:	89 e9                	mov    %ebp,%ecx
  801a8e:	d3 e2                	shl    %cl,%edx
  801a90:	39 c2                	cmp    %eax,%edx
  801a92:	73 05                	jae    801a99 <__udivdi3+0xf9>
  801a94:	3b 34 24             	cmp    (%esp),%esi
  801a97:	74 1f                	je     801ab8 <__udivdi3+0x118>
  801a99:	89 f8                	mov    %edi,%eax
  801a9b:	31 d2                	xor    %edx,%edx
  801a9d:	e9 7a ff ff ff       	jmp    801a1c <__udivdi3+0x7c>
  801aa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801aa8:	31 d2                	xor    %edx,%edx
  801aaa:	b8 01 00 00 00       	mov    $0x1,%eax
  801aaf:	e9 68 ff ff ff       	jmp    801a1c <__udivdi3+0x7c>
  801ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ab8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801abb:	31 d2                	xor    %edx,%edx
  801abd:	83 c4 0c             	add    $0xc,%esp
  801ac0:	5e                   	pop    %esi
  801ac1:	5f                   	pop    %edi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    
  801ac4:	66 90                	xchg   %ax,%ax
  801ac6:	66 90                	xchg   %ax,%ax
  801ac8:	66 90                	xchg   %ax,%ax
  801aca:	66 90                	xchg   %ax,%ax
  801acc:	66 90                	xchg   %ax,%ax
  801ace:	66 90                	xchg   %ax,%ax

00801ad0 <__umoddi3>:
  801ad0:	55                   	push   %ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	83 ec 14             	sub    $0x14,%esp
  801ad6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801ada:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801ade:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801ae2:	89 c7                	mov    %eax,%edi
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801aec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801af0:	89 34 24             	mov    %esi,(%esp)
  801af3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801af7:	85 c0                	test   %eax,%eax
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801aff:	75 17                	jne    801b18 <__umoddi3+0x48>
  801b01:	39 fe                	cmp    %edi,%esi
  801b03:	76 4b                	jbe    801b50 <__umoddi3+0x80>
  801b05:	89 c8                	mov    %ecx,%eax
  801b07:	89 fa                	mov    %edi,%edx
  801b09:	f7 f6                	div    %esi
  801b0b:	89 d0                	mov    %edx,%eax
  801b0d:	31 d2                	xor    %edx,%edx
  801b0f:	83 c4 14             	add    $0x14,%esp
  801b12:	5e                   	pop    %esi
  801b13:	5f                   	pop    %edi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    
  801b16:	66 90                	xchg   %ax,%ax
  801b18:	39 f8                	cmp    %edi,%eax
  801b1a:	77 54                	ja     801b70 <__umoddi3+0xa0>
  801b1c:	0f bd e8             	bsr    %eax,%ebp
  801b1f:	83 f5 1f             	xor    $0x1f,%ebp
  801b22:	75 5c                	jne    801b80 <__umoddi3+0xb0>
  801b24:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b28:	39 3c 24             	cmp    %edi,(%esp)
  801b2b:	0f 87 e7 00 00 00    	ja     801c18 <__umoddi3+0x148>
  801b31:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b35:	29 f1                	sub    %esi,%ecx
  801b37:	19 c7                	sbb    %eax,%edi
  801b39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b3d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b41:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b45:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b49:	83 c4 14             	add    $0x14,%esp
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    
  801b50:	85 f6                	test   %esi,%esi
  801b52:	89 f5                	mov    %esi,%ebp
  801b54:	75 0b                	jne    801b61 <__umoddi3+0x91>
  801b56:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5b:	31 d2                	xor    %edx,%edx
  801b5d:	f7 f6                	div    %esi
  801b5f:	89 c5                	mov    %eax,%ebp
  801b61:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b65:	31 d2                	xor    %edx,%edx
  801b67:	f7 f5                	div    %ebp
  801b69:	89 c8                	mov    %ecx,%eax
  801b6b:	f7 f5                	div    %ebp
  801b6d:	eb 9c                	jmp    801b0b <__umoddi3+0x3b>
  801b6f:	90                   	nop
  801b70:	89 c8                	mov    %ecx,%eax
  801b72:	89 fa                	mov    %edi,%edx
  801b74:	83 c4 14             	add    $0x14,%esp
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    
  801b7b:	90                   	nop
  801b7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b80:	8b 04 24             	mov    (%esp),%eax
  801b83:	be 20 00 00 00       	mov    $0x20,%esi
  801b88:	89 e9                	mov    %ebp,%ecx
  801b8a:	29 ee                	sub    %ebp,%esi
  801b8c:	d3 e2                	shl    %cl,%edx
  801b8e:	89 f1                	mov    %esi,%ecx
  801b90:	d3 e8                	shr    %cl,%eax
  801b92:	89 e9                	mov    %ebp,%ecx
  801b94:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b98:	8b 04 24             	mov    (%esp),%eax
  801b9b:	09 54 24 04          	or     %edx,0x4(%esp)
  801b9f:	89 fa                	mov    %edi,%edx
  801ba1:	d3 e0                	shl    %cl,%eax
  801ba3:	89 f1                	mov    %esi,%ecx
  801ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bad:	d3 ea                	shr    %cl,%edx
  801baf:	89 e9                	mov    %ebp,%ecx
  801bb1:	d3 e7                	shl    %cl,%edi
  801bb3:	89 f1                	mov    %esi,%ecx
  801bb5:	d3 e8                	shr    %cl,%eax
  801bb7:	89 e9                	mov    %ebp,%ecx
  801bb9:	09 f8                	or     %edi,%eax
  801bbb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801bbf:	f7 74 24 04          	divl   0x4(%esp)
  801bc3:	d3 e7                	shl    %cl,%edi
  801bc5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bc9:	89 d7                	mov    %edx,%edi
  801bcb:	f7 64 24 08          	mull   0x8(%esp)
  801bcf:	39 d7                	cmp    %edx,%edi
  801bd1:	89 c1                	mov    %eax,%ecx
  801bd3:	89 14 24             	mov    %edx,(%esp)
  801bd6:	72 2c                	jb     801c04 <__umoddi3+0x134>
  801bd8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bdc:	72 22                	jb     801c00 <__umoddi3+0x130>
  801bde:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801be2:	29 c8                	sub    %ecx,%eax
  801be4:	19 d7                	sbb    %edx,%edi
  801be6:	89 e9                	mov    %ebp,%ecx
  801be8:	89 fa                	mov    %edi,%edx
  801bea:	d3 e8                	shr    %cl,%eax
  801bec:	89 f1                	mov    %esi,%ecx
  801bee:	d3 e2                	shl    %cl,%edx
  801bf0:	89 e9                	mov    %ebp,%ecx
  801bf2:	d3 ef                	shr    %cl,%edi
  801bf4:	09 d0                	or     %edx,%eax
  801bf6:	89 fa                	mov    %edi,%edx
  801bf8:	83 c4 14             	add    $0x14,%esp
  801bfb:	5e                   	pop    %esi
  801bfc:	5f                   	pop    %edi
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    
  801bff:	90                   	nop
  801c00:	39 d7                	cmp    %edx,%edi
  801c02:	75 da                	jne    801bde <__umoddi3+0x10e>
  801c04:	8b 14 24             	mov    (%esp),%edx
  801c07:	89 c1                	mov    %eax,%ecx
  801c09:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c0d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c11:	eb cb                	jmp    801bde <__umoddi3+0x10e>
  801c13:	90                   	nop
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c1c:	0f 82 0f ff ff ff    	jb     801b31 <__umoddi3+0x61>
  801c22:	e9 1a ff ff ff       	jmp    801b41 <__umoddi3+0x71>
