
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
  800043:	e8 f8 16 00 00       	call   801740 <sfork>
  800048:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80004b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80004e:	85 c0                	test   %eax,%eax
  800050:	74 5e                	je     8000b0 <umain+0x7d>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800052:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  800058:	e8 4d 0f 00 00       	call   800faa <sys_getenvid>
  80005d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800061:	89 44 24 04          	mov    %eax,0x4(%esp)
  800065:	c7 04 24 80 1c 80 00 	movl   $0x801c80,(%esp)
  80006c:	e8 04 02 00 00       	call   800275 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800071:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800074:	e8 31 0f 00 00       	call   800faa <sys_getenvid>
  800079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	c7 04 24 9a 1c 80 00 	movl   $0x801c9a,(%esp)
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
  8000ab:	e8 50 17 00 00       	call   801800 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bf:	00 
  8000c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8000c3:	89 04 24             	mov    %eax,(%esp)
  8000c6:	e8 97 16 00 00       	call   801762 <ipc_recv>
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
  800101:	c7 04 24 b0 1c 80 00 	movl   $0x801cb0,(%esp)
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
  800144:	e8 b7 16 00 00       	call   801800 <ipc_send>
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
  8002e8:	e8 03 17 00 00       	call   8019f0 <__udivdi3>
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
  800354:	e8 c7 17 00 00       	call   801b20 <__umoddi3>
  800359:	05 a8 1d 80 00       	add    $0x801da8,%eax
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
  800480:	8b 04 85 cc 1d 80 00 	mov    0x801dcc(,%eax,4),%eax
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
  800559:	8b 34 9d 80 1d 80 00 	mov    0x801d80(,%ebx,4),%esi
  800560:	85 f6                	test   %esi,%esi
  800562:	75 23                	jne    800587 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800564:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800568:	c7 44 24 08 b9 1d 80 	movl   $0x801db9,0x8(%esp)
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
  80058b:	c7 44 24 08 c2 1d 80 	movl   $0x801dc2,0x8(%esp)
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
  8005b9:	be c5 1d 80 00       	mov    $0x801dc5,%esi
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
  800eba:	c7 44 24 08 24 1f 80 	movl   $0x801f24,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec9:	00 
  800eca:	c7 04 24 41 1f 80 00 	movl   $0x801f41,(%esp)
  800ed1:	e8 17 0a 00 00       	call   8018ed <_panic>

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
}
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <sys_guest>:

void sys_guest(){
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  80128f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801296:	00 
  801297:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80129e:	00 
  80129f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012ae:	00 
  8012af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b6:	00 
  8012b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012be:	00 
  8012bf:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8012c6:	e8 b5 fb ff ff       	call   800e80 <syscall>
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d6:	8b 00                	mov    (%eax),%eax
  8012d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	8b 40 04             	mov    0x4(%eax),%eax
  8012e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  8012e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e7:	83 e0 02             	and    $0x2,%eax
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	75 23                	jne    801311 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f5:	c7 44 24 08 50 1f 80 	movl   $0x801f50,0x8(%esp)
  8012fc:	00 
  8012fd:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801304:	00 
  801305:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  80130c:	e8 dc 05 00 00       	call   8018ed <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801314:	c1 e8 0c             	shr    $0xc,%eax
  801317:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  80131a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80131d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801324:	25 00 08 00 00       	and    $0x800,%eax
  801329:	85 c0                	test   %eax,%eax
  80132b:	75 1c                	jne    801349 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  80132d:	c7 44 24 08 8c 1f 80 	movl   $0x801f8c,0x8(%esp)
  801334:	00 
  801335:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80133c:	00 
  80133d:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  801344:	e8 a4 05 00 00       	call   8018ed <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  801349:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801350:	00 
  801351:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801358:	00 
  801359:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801360:	e8 cd fc ff ff       	call   801032 <sys_page_alloc>
  801365:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801368:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80136c:	79 23                	jns    801391 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  80136e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801375:	c7 44 24 08 c8 1f 80 	movl   $0x801fc8,0x8(%esp)
  80137c:	00 
  80137d:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801384:	00 
  801385:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  80138c:	e8 5c 05 00 00       	call   8018ed <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80139a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80139f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013a6:	00 
  8013a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ab:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013b2:	e8 bf f8 ff ff       	call   800c76 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013c5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013cc:	00 
  8013cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e8:	e8 86 fc ff ff       	call   801073 <sys_page_map>
  8013ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8013f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013f4:	79 23                	jns    801419 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8013f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013fd:	c7 44 24 08 00 20 80 	movl   $0x802000,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  801414:	e8 d4 04 00 00       	call   8018ed <_panic>
	}

	// panic("pgfault not implemented");
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	56                   	push   %esi
  80141f:	53                   	push   %ebx
  801420:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801423:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  80142a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801434:	25 00 08 00 00       	and    $0x800,%eax
  801439:	85 c0                	test   %eax,%eax
  80143b:	75 15                	jne    801452 <duppage+0x37>
  80143d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801440:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801447:	83 e0 02             	and    $0x2,%eax
  80144a:	85 c0                	test   %eax,%eax
  80144c:	0f 84 e0 00 00 00    	je     801532 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  801452:	8b 45 0c             	mov    0xc(%ebp),%eax
  801455:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145c:	83 e0 04             	and    $0x4,%eax
  80145f:	85 c0                	test   %eax,%eax
  801461:	74 04                	je     801467 <duppage+0x4c>
  801463:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  801467:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80146a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146d:	c1 e0 0c             	shl    $0xc,%eax
  801470:	89 c1                	mov    %eax,%ecx
  801472:	8b 45 0c             	mov    0xc(%ebp),%eax
  801475:	c1 e0 0c             	shl    $0xc,%eax
  801478:	89 c2                	mov    %eax,%edx
  80147a:	a1 08 30 80 00       	mov    0x803008,%eax
  80147f:	8b 40 48             	mov    0x48(%eax),%eax
  801482:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801486:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80148a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80148d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801491:	89 54 24 04          	mov    %edx,0x4(%esp)
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 d6 fb ff ff       	call   801073 <sys_page_map>
  80149d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014a4:	79 23                	jns    8014c9 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  8014a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ad:	c7 44 24 08 34 20 80 	movl   $0x802034,0x8(%esp)
  8014b4:	00 
  8014b5:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8014bc:	00 
  8014bd:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  8014c4:	e8 24 04 00 00       	call   8018ed <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014c9:	8b 75 f4             	mov    -0xc(%ebp),%esi
  8014cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cf:	c1 e0 0c             	shl    $0xc,%eax
  8014d2:	89 c3                	mov    %eax,%ebx
  8014d4:	a1 08 30 80 00       	mov    0x803008,%eax
  8014d9:	8b 48 48             	mov    0x48(%eax),%ecx
  8014dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014df:	c1 e0 0c             	shl    $0xc,%eax
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	a1 08 30 80 00       	mov    0x803008,%eax
  8014e9:	8b 40 48             	mov    0x48(%eax),%eax
  8014ec:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014f4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014fc:	89 04 24             	mov    %eax,(%esp)
  8014ff:	e8 6f fb ff ff       	call   801073 <sys_page_map>
  801504:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801507:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80150b:	79 23                	jns    801530 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801510:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801514:	c7 44 24 08 70 20 80 	movl   $0x802070,0x8(%esp)
  80151b:	00 
  80151c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801523:	00 
  801524:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  80152b:	e8 bd 03 00 00       	call   8018ed <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801530:	eb 70                	jmp    8015a2 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801532:	8b 45 0c             	mov    0xc(%ebp),%eax
  801535:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801541:	89 c3                	mov    %eax,%ebx
  801543:	8b 45 0c             	mov    0xc(%ebp),%eax
  801546:	c1 e0 0c             	shl    $0xc,%eax
  801549:	89 c1                	mov    %eax,%ecx
  80154b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154e:	c1 e0 0c             	shl    $0xc,%eax
  801551:	89 c2                	mov    %eax,%edx
  801553:	a1 08 30 80 00       	mov    0x803008,%eax
  801558:	8b 40 48             	mov    0x48(%eax),%eax
  80155b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80155f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801563:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801566:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80156a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80156e:	89 04 24             	mov    %eax,(%esp)
  801571:	e8 fd fa ff ff       	call   801073 <sys_page_map>
  801576:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801579:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80157d:	79 23                	jns    8015a2 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  80157f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801586:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  80158d:	00 
  80158e:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801595:	00 
  801596:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  80159d:	e8 4b 03 00 00       	call   8018ed <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  8015a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a7:	83 c4 30             	add    $0x30,%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8015b4:	c7 04 24 cd 12 80 00 	movl   $0x8012cd,(%esp)
  8015bb:	e8 88 03 00 00       	call   801948 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015c0:	b8 07 00 00 00       	mov    $0x7,%eax
  8015c5:	cd 30                	int    $0x30
  8015c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  8015ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  8015cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  8015d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015d4:	79 23                	jns    8015f9 <fork+0x4b>
  8015d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015dd:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  8015e4:	00 
  8015e5:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015ec:	00 
  8015ed:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  8015f4:	e8 f4 02 00 00       	call   8018ed <_panic>
	else if(childeid == 0){
  8015f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015fd:	75 29                	jne    801628 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8015ff:	e8 a6 f9 ff ff       	call   800faa <sys_getenvid>
  801604:	25 ff 03 00 00       	and    $0x3ff,%eax
  801609:	c1 e0 02             	shl    $0x2,%eax
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	c1 e2 05             	shl    $0x5,%edx
  801611:	29 c2                	sub    %eax,%edx
  801613:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  801619:	a3 08 30 80 00       	mov    %eax,0x803008
		// set_pgfault_handler(pgfault);
		return 0;
  80161e:	b8 00 00 00 00       	mov    $0x0,%eax
  801623:	e9 16 01 00 00       	jmp    80173e <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801628:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80162f:	eb 3b                	jmp    80166c <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801634:	c1 f8 0a             	sar    $0xa,%eax
  801637:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80163e:	83 e0 01             	and    $0x1,%eax
  801641:	85 c0                	test   %eax,%eax
  801643:	74 23                	je     801668 <fork+0xba>
  801645:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801648:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80164f:	83 e0 01             	and    $0x1,%eax
  801652:	85 c0                	test   %eax,%eax
  801654:	74 12                	je     801668 <fork+0xba>
			duppage(childeid, i);
  801656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801660:	89 04 24             	mov    %eax,(%esp)
  801663:	e8 b3 fd ff ff       	call   80141b <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801668:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166f:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801674:	76 bb                	jbe    801631 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801676:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80167d:	00 
  80167e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801685:	ee 
  801686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 a1 f9 ff ff       	call   801032 <sys_page_alloc>
  801691:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801694:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801698:	79 23                	jns    8016bd <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  80169a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80169d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016a1:	c7 44 24 08 00 21 80 	movl   $0x802100,0x8(%esp)
  8016a8:	00 
  8016a9:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  8016b0:	00 
  8016b1:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  8016b8:	e8 30 02 00 00       	call   8018ed <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  8016bd:	c7 44 24 04 be 19 80 	movl   $0x8019be,0x4(%esp)
  8016c4:	00 
  8016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c8:	89 04 24             	mov    %eax,(%esp)
  8016cb:	e8 6d fa ff ff       	call   80113d <sys_env_set_pgfault_upcall>
  8016d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016d7:	79 23                	jns    8016fc <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8016d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016e0:	c7 44 24 08 28 21 80 	movl   $0x802128,0x8(%esp)
  8016e7:	00 
  8016e8:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8016ef:	00 
  8016f0:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  8016f7:	e8 f1 01 00 00       	call   8018ed <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  8016fc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801703:	00 
  801704:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	e8 ec f9 ff ff       	call   8010fb <sys_env_set_status>
  80170f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801712:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801716:	79 23                	jns    80173b <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  801718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80171b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80171f:	c7 44 24 08 5c 21 80 	movl   $0x80215c,0x8(%esp)
  801726:	00 
  801727:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  80172e:	00 
  80172f:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  801736:	e8 b2 01 00 00       	call   8018ed <_panic>
	}
	return childeid;
  80173b:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <sfork>:

// Challenge!
int
sfork(void)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801746:	c7 44 24 08 85 21 80 	movl   $0x802185,0x8(%esp)
  80174d:	00 
  80174e:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801755:	00 
  801756:	c7 04 24 80 1f 80 00 	movl   $0x801f80,(%esp)
  80175d:	e8 8b 01 00 00       	call   8018ed <_panic>

00801762 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  801768:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80176c:	75 09                	jne    801777 <ipc_recv+0x15>
		i_dstva = UTOP;
  80176e:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  801775:	eb 06                	jmp    80177d <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  801777:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  80177d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	e8 37 fa ff ff       	call   8011bf <sys_ipc_recv>
  801788:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  80178b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80178f:	75 15                	jne    8017a6 <ipc_recv+0x44>
  801791:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801795:	74 0f                	je     8017a6 <ipc_recv+0x44>
  801797:	a1 08 30 80 00       	mov    0x803008,%eax
  80179c:	8b 50 74             	mov    0x74(%eax),%edx
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	89 10                	mov    %edx,(%eax)
  8017a4:	eb 15                	jmp    8017bb <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  8017a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017aa:	79 0f                	jns    8017bb <ipc_recv+0x59>
  8017ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8017b0:	74 09                	je     8017bb <ipc_recv+0x59>
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  8017bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017bf:	75 15                	jne    8017d6 <ipc_recv+0x74>
  8017c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017c5:	74 0f                	je     8017d6 <ipc_recv+0x74>
  8017c7:	a1 08 30 80 00       	mov    0x803008,%eax
  8017cc:	8b 50 78             	mov    0x78(%eax),%edx
  8017cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d2:	89 10                	mov    %edx,(%eax)
  8017d4:	eb 15                	jmp    8017eb <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  8017d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017da:	79 0f                	jns    8017eb <ipc_recv+0x89>
  8017dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017e0:	74 09                	je     8017eb <ipc_recv+0x89>
  8017e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  8017eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017ef:	75 0a                	jne    8017fb <ipc_recv+0x99>
  8017f1:	a1 08 30 80 00       	mov    0x803008,%eax
  8017f6:	8b 40 70             	mov    0x70(%eax),%eax
  8017f9:	eb 03                	jmp    8017fe <ipc_recv+0x9c>
	else return r;
  8017fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  801806:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  80180d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801811:	74 06                	je     801819 <ipc_send+0x19>
  801813:	8b 45 10             	mov    0x10(%ebp),%eax
  801816:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181c:	8b 55 14             	mov    0x14(%ebp),%edx
  80181f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801823:	89 44 24 08          	mov    %eax,0x8(%esp)
  801827:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	89 04 24             	mov    %eax,(%esp)
  801834:	e8 46 f9 ff ff       	call   80117f <sys_ipc_try_send>
  801839:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  80183c:	eb 28                	jmp    801866 <ipc_send+0x66>
		sys_yield();
  80183e:	e8 ab f7 ff ff       	call   800fee <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801843:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801846:	8b 55 14             	mov    0x14(%ebp),%edx
  801849:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80184d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	89 44 24 04          	mov    %eax,0x4(%esp)
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 1c f9 ff ff       	call   80117f <sys_ipc_try_send>
  801863:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  801866:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  80186a:	74 d2                	je     80183e <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  80186c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801870:	75 02                	jne    801874 <ipc_send+0x74>
  801872:	eb 23                	jmp    801897 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  801874:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801877:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80187b:	c7 44 24 08 9c 21 80 	movl   $0x80219c,0x8(%esp)
  801882:	00 
  801883:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80188a:	00 
  80188b:	c7 04 24 c1 21 80 00 	movl   $0x8021c1,(%esp)
  801892:	e8 56 00 00 00       	call   8018ed <_panic>
	panic("ipc_send not implemented");
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  80189f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8018a6:	eb 35                	jmp    8018dd <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  8018a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ab:	c1 e0 02             	shl    $0x2,%eax
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	c1 e2 05             	shl    $0x5,%edx
  8018b3:	29 c2                	sub    %eax,%edx
  8018b5:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  8018bb:	8b 00                	mov    (%eax),%eax
  8018bd:	3b 45 08             	cmp    0x8(%ebp),%eax
  8018c0:	75 17                	jne    8018d9 <ipc_find_env+0x40>
			return envs[i].env_id;
  8018c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018c5:	c1 e0 02             	shl    $0x2,%eax
  8018c8:	89 c2                	mov    %eax,%edx
  8018ca:	c1 e2 05             	shl    $0x5,%edx
  8018cd:	29 c2                	sub    %eax,%edx
  8018cf:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8018d5:	8b 00                	mov    (%eax),%eax
  8018d7:	eb 12                	jmp    8018eb <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018d9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8018dd:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8018e4:	7e c2                	jle    8018a8 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8018f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f7:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018fa:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801900:	e8 a5 f6 ff ff       	call   800faa <sys_getenvid>
  801905:	8b 55 0c             	mov    0xc(%ebp),%edx
  801908:	89 54 24 10          	mov    %edx,0x10(%esp)
  80190c:	8b 55 08             	mov    0x8(%ebp),%edx
  80190f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801913:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191b:	c7 04 24 cc 21 80 00 	movl   $0x8021cc,(%esp)
  801922:	e8 4e e9 ff ff       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192e:	8b 45 10             	mov    0x10(%ebp),%eax
  801931:	89 04 24             	mov    %eax,(%esp)
  801934:	e8 d8 e8 ff ff       	call   800211 <vcprintf>
	cprintf("\n");
  801939:	c7 04 24 ef 21 80 00 	movl   $0x8021ef,(%esp)
  801940:	e8 30 e9 ff ff       	call   800275 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801945:	cc                   	int3   
  801946:	eb fd                	jmp    801945 <_panic+0x58>

00801948 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80194e:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801953:	85 c0                	test   %eax,%eax
  801955:	75 5d                	jne    8019b4 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801957:	a1 08 30 80 00       	mov    0x803008,%eax
  80195c:	8b 40 48             	mov    0x48(%eax),%eax
  80195f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801966:	00 
  801967:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80196e:	ee 
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	e8 bb f6 ff ff       	call   801032 <sys_page_alloc>
  801977:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80197a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80197e:	79 1c                	jns    80199c <set_pgfault_handler+0x54>
  801980:	c7 44 24 08 f4 21 80 	movl   $0x8021f4,0x8(%esp)
  801987:	00 
  801988:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80198f:	00 
  801990:	c7 04 24 20 22 80 00 	movl   $0x802220,(%esp)
  801997:	e8 51 ff ff ff       	call   8018ed <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80199c:	a1 08 30 80 00       	mov    0x803008,%eax
  8019a1:	8b 40 48             	mov    0x48(%eax),%eax
  8019a4:	c7 44 24 04 be 19 80 	movl   $0x8019be,0x4(%esp)
  8019ab:	00 
  8019ac:	89 04 24             	mov    %eax,(%esp)
  8019af:	e8 89 f7 ff ff       	call   80113d <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8019b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b7:	a3 0c 30 80 00       	mov    %eax,0x80300c
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8019be:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8019bf:	a1 0c 30 80 00       	mov    0x80300c,%eax
	call *%eax
  8019c4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8019c6:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8019c9:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8019cd:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8019cf:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8019d3:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8019d4:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8019d7:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8019d9:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8019da:	58                   	pop    %eax
	popal 						// pop all the registers
  8019db:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8019dc:	83 c4 04             	add    $0x4,%esp
	popfl
  8019df:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8019e0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8019e1:	c3                   	ret    
  8019e2:	66 90                	xchg   %ax,%ax
  8019e4:	66 90                	xchg   %ax,%ax
  8019e6:	66 90                	xchg   %ax,%ax
  8019e8:	66 90                	xchg   %ax,%ax
  8019ea:	66 90                	xchg   %ax,%ax
  8019ec:	66 90                	xchg   %ax,%ax
  8019ee:	66 90                	xchg   %ax,%ax

008019f0 <__udivdi3>:
  8019f0:	55                   	push   %ebp
  8019f1:	57                   	push   %edi
  8019f2:	56                   	push   %esi
  8019f3:	83 ec 0c             	sub    $0xc,%esp
  8019f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8019fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801a02:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a0c:	89 ea                	mov    %ebp,%edx
  801a0e:	89 0c 24             	mov    %ecx,(%esp)
  801a11:	75 2d                	jne    801a40 <__udivdi3+0x50>
  801a13:	39 e9                	cmp    %ebp,%ecx
  801a15:	77 61                	ja     801a78 <__udivdi3+0x88>
  801a17:	85 c9                	test   %ecx,%ecx
  801a19:	89 ce                	mov    %ecx,%esi
  801a1b:	75 0b                	jne    801a28 <__udivdi3+0x38>
  801a1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a22:	31 d2                	xor    %edx,%edx
  801a24:	f7 f1                	div    %ecx
  801a26:	89 c6                	mov    %eax,%esi
  801a28:	31 d2                	xor    %edx,%edx
  801a2a:	89 e8                	mov    %ebp,%eax
  801a2c:	f7 f6                	div    %esi
  801a2e:	89 c5                	mov    %eax,%ebp
  801a30:	89 f8                	mov    %edi,%eax
  801a32:	f7 f6                	div    %esi
  801a34:	89 ea                	mov    %ebp,%edx
  801a36:	83 c4 0c             	add    $0xc,%esp
  801a39:	5e                   	pop    %esi
  801a3a:	5f                   	pop    %edi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    
  801a3d:	8d 76 00             	lea    0x0(%esi),%esi
  801a40:	39 e8                	cmp    %ebp,%eax
  801a42:	77 24                	ja     801a68 <__udivdi3+0x78>
  801a44:	0f bd e8             	bsr    %eax,%ebp
  801a47:	83 f5 1f             	xor    $0x1f,%ebp
  801a4a:	75 3c                	jne    801a88 <__udivdi3+0x98>
  801a4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a50:	39 34 24             	cmp    %esi,(%esp)
  801a53:	0f 86 9f 00 00 00    	jbe    801af8 <__udivdi3+0x108>
  801a59:	39 d0                	cmp    %edx,%eax
  801a5b:	0f 82 97 00 00 00    	jb     801af8 <__udivdi3+0x108>
  801a61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a68:	31 d2                	xor    %edx,%edx
  801a6a:	31 c0                	xor    %eax,%eax
  801a6c:	83 c4 0c             	add    $0xc,%esp
  801a6f:	5e                   	pop    %esi
  801a70:	5f                   	pop    %edi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    
  801a73:	90                   	nop
  801a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a78:	89 f8                	mov    %edi,%eax
  801a7a:	f7 f1                	div    %ecx
  801a7c:	31 d2                	xor    %edx,%edx
  801a7e:	83 c4 0c             	add    $0xc,%esp
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    
  801a85:	8d 76 00             	lea    0x0(%esi),%esi
  801a88:	89 e9                	mov    %ebp,%ecx
  801a8a:	8b 3c 24             	mov    (%esp),%edi
  801a8d:	d3 e0                	shl    %cl,%eax
  801a8f:	89 c6                	mov    %eax,%esi
  801a91:	b8 20 00 00 00       	mov    $0x20,%eax
  801a96:	29 e8                	sub    %ebp,%eax
  801a98:	89 c1                	mov    %eax,%ecx
  801a9a:	d3 ef                	shr    %cl,%edi
  801a9c:	89 e9                	mov    %ebp,%ecx
  801a9e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801aa2:	8b 3c 24             	mov    (%esp),%edi
  801aa5:	09 74 24 08          	or     %esi,0x8(%esp)
  801aa9:	89 d6                	mov    %edx,%esi
  801aab:	d3 e7                	shl    %cl,%edi
  801aad:	89 c1                	mov    %eax,%ecx
  801aaf:	89 3c 24             	mov    %edi,(%esp)
  801ab2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ab6:	d3 ee                	shr    %cl,%esi
  801ab8:	89 e9                	mov    %ebp,%ecx
  801aba:	d3 e2                	shl    %cl,%edx
  801abc:	89 c1                	mov    %eax,%ecx
  801abe:	d3 ef                	shr    %cl,%edi
  801ac0:	09 d7                	or     %edx,%edi
  801ac2:	89 f2                	mov    %esi,%edx
  801ac4:	89 f8                	mov    %edi,%eax
  801ac6:	f7 74 24 08          	divl   0x8(%esp)
  801aca:	89 d6                	mov    %edx,%esi
  801acc:	89 c7                	mov    %eax,%edi
  801ace:	f7 24 24             	mull   (%esp)
  801ad1:	39 d6                	cmp    %edx,%esi
  801ad3:	89 14 24             	mov    %edx,(%esp)
  801ad6:	72 30                	jb     801b08 <__udivdi3+0x118>
  801ad8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801adc:	89 e9                	mov    %ebp,%ecx
  801ade:	d3 e2                	shl    %cl,%edx
  801ae0:	39 c2                	cmp    %eax,%edx
  801ae2:	73 05                	jae    801ae9 <__udivdi3+0xf9>
  801ae4:	3b 34 24             	cmp    (%esp),%esi
  801ae7:	74 1f                	je     801b08 <__udivdi3+0x118>
  801ae9:	89 f8                	mov    %edi,%eax
  801aeb:	31 d2                	xor    %edx,%edx
  801aed:	e9 7a ff ff ff       	jmp    801a6c <__udivdi3+0x7c>
  801af2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801af8:	31 d2                	xor    %edx,%edx
  801afa:	b8 01 00 00 00       	mov    $0x1,%eax
  801aff:	e9 68 ff ff ff       	jmp    801a6c <__udivdi3+0x7c>
  801b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b0b:	31 d2                	xor    %edx,%edx
  801b0d:	83 c4 0c             	add    $0xc,%esp
  801b10:	5e                   	pop    %esi
  801b11:	5f                   	pop    %edi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    
  801b14:	66 90                	xchg   %ax,%ax
  801b16:	66 90                	xchg   %ax,%ax
  801b18:	66 90                	xchg   %ax,%ax
  801b1a:	66 90                	xchg   %ax,%ax
  801b1c:	66 90                	xchg   %ax,%ax
  801b1e:	66 90                	xchg   %ax,%ax

00801b20 <__umoddi3>:
  801b20:	55                   	push   %ebp
  801b21:	57                   	push   %edi
  801b22:	56                   	push   %esi
  801b23:	83 ec 14             	sub    $0x14,%esp
  801b26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801b2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801b2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801b32:	89 c7                	mov    %eax,%edi
  801b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b38:	8b 44 24 30          	mov    0x30(%esp),%eax
  801b3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801b40:	89 34 24             	mov    %esi,(%esp)
  801b43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b47:	85 c0                	test   %eax,%eax
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b4f:	75 17                	jne    801b68 <__umoddi3+0x48>
  801b51:	39 fe                	cmp    %edi,%esi
  801b53:	76 4b                	jbe    801ba0 <__umoddi3+0x80>
  801b55:	89 c8                	mov    %ecx,%eax
  801b57:	89 fa                	mov    %edi,%edx
  801b59:	f7 f6                	div    %esi
  801b5b:	89 d0                	mov    %edx,%eax
  801b5d:	31 d2                	xor    %edx,%edx
  801b5f:	83 c4 14             	add    $0x14,%esp
  801b62:	5e                   	pop    %esi
  801b63:	5f                   	pop    %edi
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	39 f8                	cmp    %edi,%eax
  801b6a:	77 54                	ja     801bc0 <__umoddi3+0xa0>
  801b6c:	0f bd e8             	bsr    %eax,%ebp
  801b6f:	83 f5 1f             	xor    $0x1f,%ebp
  801b72:	75 5c                	jne    801bd0 <__umoddi3+0xb0>
  801b74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b78:	39 3c 24             	cmp    %edi,(%esp)
  801b7b:	0f 87 e7 00 00 00    	ja     801c68 <__umoddi3+0x148>
  801b81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b85:	29 f1                	sub    %esi,%ecx
  801b87:	19 c7                	sbb    %eax,%edi
  801b89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b91:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b99:	83 c4 14             	add    $0x14,%esp
  801b9c:	5e                   	pop    %esi
  801b9d:	5f                   	pop    %edi
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    
  801ba0:	85 f6                	test   %esi,%esi
  801ba2:	89 f5                	mov    %esi,%ebp
  801ba4:	75 0b                	jne    801bb1 <__umoddi3+0x91>
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f6                	div    %esi
  801baf:	89 c5                	mov    %eax,%ebp
  801bb1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bb5:	31 d2                	xor    %edx,%edx
  801bb7:	f7 f5                	div    %ebp
  801bb9:	89 c8                	mov    %ecx,%eax
  801bbb:	f7 f5                	div    %ebp
  801bbd:	eb 9c                	jmp    801b5b <__umoddi3+0x3b>
  801bbf:	90                   	nop
  801bc0:	89 c8                	mov    %ecx,%eax
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	83 c4 14             	add    $0x14,%esp
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    
  801bcb:	90                   	nop
  801bcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	8b 04 24             	mov    (%esp),%eax
  801bd3:	be 20 00 00 00       	mov    $0x20,%esi
  801bd8:	89 e9                	mov    %ebp,%ecx
  801bda:	29 ee                	sub    %ebp,%esi
  801bdc:	d3 e2                	shl    %cl,%edx
  801bde:	89 f1                	mov    %esi,%ecx
  801be0:	d3 e8                	shr    %cl,%eax
  801be2:	89 e9                	mov    %ebp,%ecx
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	8b 04 24             	mov    (%esp),%eax
  801beb:	09 54 24 04          	or     %edx,0x4(%esp)
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	d3 e0                	shl    %cl,%eax
  801bf3:	89 f1                	mov    %esi,%ecx
  801bf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bfd:	d3 ea                	shr    %cl,%edx
  801bff:	89 e9                	mov    %ebp,%ecx
  801c01:	d3 e7                	shl    %cl,%edi
  801c03:	89 f1                	mov    %esi,%ecx
  801c05:	d3 e8                	shr    %cl,%eax
  801c07:	89 e9                	mov    %ebp,%ecx
  801c09:	09 f8                	or     %edi,%eax
  801c0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801c0f:	f7 74 24 04          	divl   0x4(%esp)
  801c13:	d3 e7                	shl    %cl,%edi
  801c15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c19:	89 d7                	mov    %edx,%edi
  801c1b:	f7 64 24 08          	mull   0x8(%esp)
  801c1f:	39 d7                	cmp    %edx,%edi
  801c21:	89 c1                	mov    %eax,%ecx
  801c23:	89 14 24             	mov    %edx,(%esp)
  801c26:	72 2c                	jb     801c54 <__umoddi3+0x134>
  801c28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801c2c:	72 22                	jb     801c50 <__umoddi3+0x130>
  801c2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c32:	29 c8                	sub    %ecx,%eax
  801c34:	19 d7                	sbb    %edx,%edi
  801c36:	89 e9                	mov    %ebp,%ecx
  801c38:	89 fa                	mov    %edi,%edx
  801c3a:	d3 e8                	shr    %cl,%eax
  801c3c:	89 f1                	mov    %esi,%ecx
  801c3e:	d3 e2                	shl    %cl,%edx
  801c40:	89 e9                	mov    %ebp,%ecx
  801c42:	d3 ef                	shr    %cl,%edi
  801c44:	09 d0                	or     %edx,%eax
  801c46:	89 fa                	mov    %edi,%edx
  801c48:	83 c4 14             	add    $0x14,%esp
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    
  801c4f:	90                   	nop
  801c50:	39 d7                	cmp    %edx,%edi
  801c52:	75 da                	jne    801c2e <__umoddi3+0x10e>
  801c54:	8b 14 24             	mov    (%esp),%edx
  801c57:	89 c1                	mov    %eax,%ecx
  801c59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c61:	eb cb                	jmp    801c2e <__umoddi3+0x10e>
  801c63:	90                   	nop
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c6c:	0f 82 0f ff ff ff    	jb     801b81 <__umoddi3+0x61>
  801c72:	e9 1a ff ff ff       	jmp    801b91 <__umoddi3+0x71>
