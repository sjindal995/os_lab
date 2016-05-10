
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 fa 15 00 00       	call   801638 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800044:	85 c0                	test   %eax,%eax
  800046:	0f 85 c1 00 00 00    	jne    80010d <umain+0xda>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800053:	00 
  800054:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  80005b:	00 
  80005c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005f:	89 04 24             	mov    %eax,(%esp)
  800062:	e8 85 17 00 00       	call   8017ec <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800067:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006a:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  800071:	00 
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	c7 04 24 4c 1d 80 00 	movl   $0x801d4c,(%esp)
  80007d:	e8 7d 02 00 00       	call   8002ff <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800082:	a1 00 30 80 00       	mov    0x803000,%eax
  800087:	89 04 24             	mov    %eax,(%esp)
  80008a:	e8 e7 08 00 00       	call   800976 <strlen>
  80008f:	89 c2                	mov    %eax,%edx
  800091:	a1 00 30 80 00       	mov    0x803000,%eax
  800096:	89 54 24 08          	mov    %edx,0x8(%esp)
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a5:	e8 57 0a 00 00       	call   800b01 <strncmp>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 0c                	jne    8000ba <umain+0x87>
			cprintf("child received correct message\n");
  8000ae:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  8000b5:	e8 45 02 00 00       	call   8002ff <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000ba:	a1 04 30 80 00       	mov    0x803004,%eax
  8000bf:	89 04 24             	mov    %eax,(%esp)
  8000c2:	e8 af 08 00 00       	call   800976 <strlen>
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	89 c2                	mov    %eax,%edx
  8000cc:	a1 04 30 80 00       	mov    0x803004,%eax
  8000d1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d9:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000e0:	e8 1b 0c 00 00       	call   800d00 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000e8:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000ef:	00 
  8000f0:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000f7:	00 
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 04 24             	mov    %eax,(%esp)
  800103:	e8 82 17 00 00       	call   80188a <ipc_send>
		return;
  800108:	e9 dd 00 00 00       	jmp    8001ea <umain+0x1b7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80010d:	a1 0c 30 80 00       	mov    0x80300c,%eax
  800112:	8b 40 48             	mov    0x48(%eax),%eax
  800115:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80011c:	00 
  80011d:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800124:	00 
  800125:	89 04 24             	mov    %eax,(%esp)
  800128:	e8 8f 0f 00 00       	call   8010bc <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  80012d:	a1 00 30 80 00       	mov    0x803000,%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 3c 08 00 00       	call   800976 <strlen>
  80013a:	83 c0 01             	add    $0x1,%eax
  80013d:	89 c2                	mov    %eax,%edx
  80013f:	a1 00 30 80 00       	mov    0x803000,%eax
  800144:	89 54 24 08          	mov    %edx,0x8(%esp)
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800153:	e8 a8 0b 00 00       	call   800d00 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80015b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800162:	00 
  800163:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80016a:	00 
  80016b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800172:	00 
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 0f 17 00 00       	call   80188a <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80017b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800182:	00 
  800183:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80018a:	00 
  80018b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 56 16 00 00       	call   8017ec <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  8001a0:	00 
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 4c 1d 80 00 	movl   $0x801d4c,(%esp)
  8001ac:	e8 4e 01 00 00       	call   8002ff <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001b1:	a1 04 30 80 00       	mov    0x803004,%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 b8 07 00 00       	call   800976 <strlen>
  8001be:	89 c2                	mov    %eax,%edx
  8001c0:	a1 04 30 80 00       	mov    0x803004,%eax
  8001c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001d4:	e8 28 09 00 00       	call   800b01 <strncmp>
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	75 0c                	jne    8001e9 <umain+0x1b6>
		cprintf("parent received correct message\n");
  8001dd:	c7 04 24 80 1d 80 00 	movl   $0x801d80,(%esp)
  8001e4:	e8 16 01 00 00       	call   8002ff <cprintf>
	return;
  8001e9:	90                   	nop
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001f2:	e8 3d 0e 00 00       	call   801034 <sys_getenvid>
  8001f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fc:	c1 e0 02             	shl    $0x2,%eax
  8001ff:	89 c2                	mov    %eax,%edx
  800201:	c1 e2 05             	shl    $0x5,%edx
  800204:	29 c2                	sub    %eax,%edx
  800206:	89 d0                	mov    %edx,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 0c 30 80 00       	mov    %eax,0x80300c
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800212:	8b 45 0c             	mov    0xc(%ebp),%eax
  800215:	89 44 24 04          	mov    %eax,0x4(%esp)
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	89 04 24             	mov    %eax,(%esp)
  80021f:	e8 0f fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800224:	e8 02 00 00 00       	call   80022b <exit>
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800231:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800238:	e8 b4 0d 00 00       	call   800ff1 <sys_env_destroy>
}
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800245:	8b 45 0c             	mov    0xc(%ebp),%eax
  800248:	8b 00                	mov    (%eax),%eax
  80024a:	8d 48 01             	lea    0x1(%eax),%ecx
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 0a                	mov    %ecx,(%edx)
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	89 d1                	mov    %edx,%ecx
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80025e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800261:	8b 00                	mov    (%eax),%eax
  800263:	3d ff 00 00 00       	cmp    $0xff,%eax
  800268:	75 20                	jne    80028a <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026d:	8b 00                	mov    (%eax),%eax
  80026f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800272:	83 c2 08             	add    $0x8,%edx
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	89 14 24             	mov    %edx,(%esp)
  80027c:	e8 ea 0c 00 00       	call   800f6b <sys_cputs>
		b->idx = 0;
  800281:	8b 45 0c             	mov    0xc(%ebp),%eax
  800284:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80028a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028d:	8b 40 04             	mov    0x4(%eax),%eax
  800290:	8d 50 01             	lea    0x1(%eax),%edx
  800293:	8b 45 0c             	mov    0xc(%ebp),%eax
  800296:	89 50 04             	mov    %edx,0x4(%eax)
}
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ab:	00 00 00 
	b.cnt = 0;
  8002ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	c7 04 24 3f 02 80 00 	movl   $0x80023f,(%esp)
  8002d7:	e8 bd 01 00 00       	call   800499 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002dc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	83 c0 08             	add    $0x8,%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 74 0c 00 00       	call   800f6b <sys_cputs>

	return b.cnt;
  8002f7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800305:	8d 45 0c             	lea    0xc(%ebp),%eax
  800308:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80030b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	89 04 24             	mov    %eax,(%esp)
  800318:	e8 7e ff ff ff       	call   80029b <vcprintf>
  80031d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800320:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	53                   	push   %ebx
  800329:	83 ec 34             	sub    $0x34,%esp
  80032c:	8b 45 10             	mov    0x10(%ebp),%eax
  80032f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800338:	8b 45 18             	mov    0x18(%ebp),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
  800340:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800343:	77 72                	ja     8003b7 <printnum+0x92>
  800345:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800348:	72 05                	jb     80034f <printnum+0x2a>
  80034a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80034d:	77 68                	ja     8003b7 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800352:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800355:	8b 45 18             	mov    0x18(%ebp),%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
  80035d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800361:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800365:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800368:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800372:	e8 f9 16 00 00       	call   801a70 <__udivdi3>
  800377:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80037a:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80037e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800382:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800385:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800389:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800391:	8b 45 0c             	mov    0xc(%ebp),%eax
  800394:	89 44 24 04          	mov    %eax,0x4(%esp)
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	89 04 24             	mov    %eax,(%esp)
  80039e:	e8 82 ff ff ff       	call   800325 <printnum>
  8003a3:	eb 1c                	jmp    8003c1 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	8b 45 20             	mov    0x20(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8003bb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003bf:	7f e4                	jg     8003a5 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003c1:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003cf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003de:	e8 bd 17 00 00       	call   801ba0 <__umoddi3>
  8003e3:	05 88 1e 80 00       	add    $0x801e88,%eax
  8003e8:	0f b6 00             	movzbl (%eax),%eax
  8003eb:	0f be c0             	movsbl %al,%eax
  8003ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f5:	89 04 24             	mov    %eax,(%esp)
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	ff d0                	call   *%eax
}
  8003fd:	83 c4 34             	add    $0x34,%esp
  800400:	5b                   	pop    %ebx
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800406:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80040a:	7e 14                	jle    800420 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	8d 48 08             	lea    0x8(%eax),%ecx
  800414:	8b 55 08             	mov    0x8(%ebp),%edx
  800417:	89 0a                	mov    %ecx,(%edx)
  800419:	8b 50 04             	mov    0x4(%eax),%edx
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	eb 30                	jmp    800450 <getuint+0x4d>
	else if (lflag)
  800420:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800424:	74 16                	je     80043c <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	8d 48 04             	lea    0x4(%eax),%ecx
  80042e:	8b 55 08             	mov    0x8(%ebp),%edx
  800431:	89 0a                	mov    %ecx,(%edx)
  800433:	8b 00                	mov    (%eax),%eax
  800435:	ba 00 00 00 00       	mov    $0x0,%edx
  80043a:	eb 14                	jmp    800450 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80043c:	8b 45 08             	mov    0x8(%ebp),%eax
  80043f:	8b 00                	mov    (%eax),%eax
  800441:	8d 48 04             	lea    0x4(%eax),%ecx
  800444:	8b 55 08             	mov    0x8(%ebp),%edx
  800447:	89 0a                	mov    %ecx,(%edx)
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800455:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800459:	7e 14                	jle    80046f <getint+0x1d>
		return va_arg(*ap, long long);
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	8d 48 08             	lea    0x8(%eax),%ecx
  800463:	8b 55 08             	mov    0x8(%ebp),%edx
  800466:	89 0a                	mov    %ecx,(%edx)
  800468:	8b 50 04             	mov    0x4(%eax),%edx
  80046b:	8b 00                	mov    (%eax),%eax
  80046d:	eb 28                	jmp    800497 <getint+0x45>
	else if (lflag)
  80046f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800473:	74 12                	je     800487 <getint+0x35>
		return va_arg(*ap, long);
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	8d 48 04             	lea    0x4(%eax),%ecx
  80047d:	8b 55 08             	mov    0x8(%ebp),%edx
  800480:	89 0a                	mov    %ecx,(%edx)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	99                   	cltd   
  800485:	eb 10                	jmp    800497 <getint+0x45>
	else
		return va_arg(*ap, int);
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	8d 48 04             	lea    0x4(%eax),%ecx
  80048f:	8b 55 08             	mov    0x8(%ebp),%edx
  800492:	89 0a                	mov    %ecx,(%edx)
  800494:	8b 00                	mov    (%eax),%eax
  800496:	99                   	cltd   
}
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a1:	eb 18                	jmp    8004bb <vprintfmt+0x22>
			if (ch == '\0')
  8004a3:	85 db                	test   %ebx,%ebx
  8004a5:	75 05                	jne    8004ac <vprintfmt+0x13>
				return;
  8004a7:	e9 cc 03 00 00       	jmp    800878 <vprintfmt+0x3df>
			putch(ch, putdat);
  8004ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b3:	89 1c 24             	mov    %ebx,(%esp)
  8004b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b9:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004be:	8d 50 01             	lea    0x1(%eax),%edx
  8004c1:	89 55 10             	mov    %edx,0x10(%ebp)
  8004c4:	0f b6 00             	movzbl (%eax),%eax
  8004c7:	0f b6 d8             	movzbl %al,%ebx
  8004ca:	83 fb 25             	cmp    $0x25,%ebx
  8004cd:	75 d4                	jne    8004a3 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004cf:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004d3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004e1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004e8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f2:	8d 50 01             	lea    0x1(%eax),%edx
  8004f5:	89 55 10             	mov    %edx,0x10(%ebp)
  8004f8:	0f b6 00             	movzbl (%eax),%eax
  8004fb:	0f b6 d8             	movzbl %al,%ebx
  8004fe:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800501:	83 f8 55             	cmp    $0x55,%eax
  800504:	0f 87 3d 03 00 00    	ja     800847 <vprintfmt+0x3ae>
  80050a:	8b 04 85 ac 1e 80 00 	mov    0x801eac(,%eax,4),%eax
  800511:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800513:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800517:	eb d6                	jmp    8004ef <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800519:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80051d:	eb d0                	jmp    8004ef <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80051f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800526:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800529:	89 d0                	mov    %edx,%eax
  80052b:	c1 e0 02             	shl    $0x2,%eax
  80052e:	01 d0                	add    %edx,%eax
  800530:	01 c0                	add    %eax,%eax
  800532:	01 d8                	add    %ebx,%eax
  800534:	83 e8 30             	sub    $0x30,%eax
  800537:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80053a:	8b 45 10             	mov    0x10(%ebp),%eax
  80053d:	0f b6 00             	movzbl (%eax),%eax
  800540:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800543:	83 fb 2f             	cmp    $0x2f,%ebx
  800546:	7e 0b                	jle    800553 <vprintfmt+0xba>
  800548:	83 fb 39             	cmp    $0x39,%ebx
  80054b:	7f 06                	jg     800553 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80054d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800551:	eb d3                	jmp    800526 <vprintfmt+0x8d>
			goto process_precision;
  800553:	eb 33                	jmp    800588 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800563:	eb 23                	jmp    800588 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800565:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800569:	79 0c                	jns    800577 <vprintfmt+0xde>
				width = 0;
  80056b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800572:	e9 78 ff ff ff       	jmp    8004ef <vprintfmt+0x56>
  800577:	e9 73 ff ff ff       	jmp    8004ef <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80057c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800583:	e9 67 ff ff ff       	jmp    8004ef <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800588:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80058c:	79 12                	jns    8005a0 <vprintfmt+0x107>
				width = precision, precision = -1;
  80058e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800591:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800594:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80059b:	e9 4f ff ff ff       	jmp    8004ef <vprintfmt+0x56>
  8005a0:	e9 4a ff ff ff       	jmp    8004ef <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005a5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8005a9:	e9 41 ff ff ff       	jmp    8004ef <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c6:	ff d0                	call   *%eax
			break;
  8005c8:	e9 a5 02 00 00       	jmp    800872 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	79 02                	jns    8005de <vprintfmt+0x145>
				err = -err;
  8005dc:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005de:	83 fb 09             	cmp    $0x9,%ebx
  8005e1:	7f 0b                	jg     8005ee <vprintfmt+0x155>
  8005e3:	8b 34 9d 60 1e 80 00 	mov    0x801e60(,%ebx,4),%esi
  8005ea:	85 f6                	test   %esi,%esi
  8005ec:	75 23                	jne    800611 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f2:	c7 44 24 08 99 1e 80 	movl   $0x801e99,0x8(%esp)
  8005f9:	00 
  8005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	8b 45 08             	mov    0x8(%ebp),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	e8 73 02 00 00       	call   80087f <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80060c:	e9 61 02 00 00       	jmp    800872 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800611:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800615:	c7 44 24 08 a2 1e 80 	movl   $0x801ea2,0x8(%esp)
  80061c:	00 
  80061d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800620:	89 44 24 04          	mov    %eax,0x4(%esp)
  800624:	8b 45 08             	mov    0x8(%ebp),%eax
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	e8 50 02 00 00       	call   80087f <printfmt>
			break;
  80062f:	e9 3e 02 00 00       	jmp    800872 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	85 f6                	test   %esi,%esi
  800641:	75 05                	jne    800648 <vprintfmt+0x1af>
				p = "(null)";
  800643:	be a5 1e 80 00       	mov    $0x801ea5,%esi
			if (width > 0 && padc != '-')
  800648:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064c:	7e 37                	jle    800685 <vprintfmt+0x1ec>
  80064e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800652:	74 31                	je     800685 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800654:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800657:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065b:	89 34 24             	mov    %esi,(%esp)
  80065e:	e8 39 03 00 00       	call   80099c <strnlen>
  800663:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800666:	eb 17                	jmp    80067f <vprintfmt+0x1e6>
					putch(padc, putdat);
  800668:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80066c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80067f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800683:	7f e3                	jg     800668 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800685:	eb 38                	jmp    8006bf <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800687:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068b:	74 1f                	je     8006ac <vprintfmt+0x213>
  80068d:	83 fb 1f             	cmp    $0x1f,%ebx
  800690:	7e 05                	jle    800697 <vprintfmt+0x1fe>
  800692:	83 fb 7e             	cmp    $0x7e,%ebx
  800695:	7e 15                	jle    8006ac <vprintfmt+0x213>
					putch('?', putdat);
  800697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	ff d0                	call   *%eax
  8006aa:	eb 0f                	jmp    8006bb <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8006ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b3:	89 1c 24             	mov    %ebx,(%esp)
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006bb:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006bf:	89 f0                	mov    %esi,%eax
  8006c1:	8d 70 01             	lea    0x1(%eax),%esi
  8006c4:	0f b6 00             	movzbl (%eax),%eax
  8006c7:	0f be d8             	movsbl %al,%ebx
  8006ca:	85 db                	test   %ebx,%ebx
  8006cc:	74 10                	je     8006de <vprintfmt+0x245>
  8006ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d2:	78 b3                	js     800687 <vprintfmt+0x1ee>
  8006d4:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8006d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006dc:	79 a9                	jns    800687 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006de:	eb 17                	jmp    8006f7 <vprintfmt+0x25e>
				putch(' ', putdat);
  8006e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006f3:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006fb:	7f e3                	jg     8006e0 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8006fd:	e9 70 01 00 00       	jmp    800872 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800702:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	e8 3e fd ff ff       	call   800452 <getint>
  800714:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800717:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80071a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800720:	85 d2                	test   %edx,%edx
  800722:	79 26                	jns    80074a <vprintfmt+0x2b1>
				putch('-', putdat);
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	ff d0                	call   *%eax
				num = -(long long) num;
  800737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073d:	f7 d8                	neg    %eax
  80073f:	83 d2 00             	adc    $0x0,%edx
  800742:	f7 da                	neg    %edx
  800744:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800747:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80074a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800751:	e9 a8 00 00 00       	jmp    8007fe <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800756:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	8d 45 14             	lea    0x14(%ebp),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	e8 9b fc ff ff       	call   800403 <getuint>
  800768:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80076b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80076e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800775:	e9 84 00 00 00       	jmp    8007fe <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80077a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80077d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800781:	8d 45 14             	lea    0x14(%ebp),%eax
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	e8 77 fc ff ff       	call   800403 <getuint>
  80078c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80078f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800792:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800799:	eb 63                	jmp    8007fe <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	ff d0                	call   *%eax
			putch('x', putdat);
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 50 04             	lea    0x4(%eax),%edx
  8007c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ca:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007dd:	eb 1f                	jmp    8007fe <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007df:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	89 04 24             	mov    %eax,(%esp)
  8007ec:	e8 12 fc ff ff       	call   800403 <getuint>
  8007f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007f4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8007f7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fe:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800802:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800805:	89 54 24 18          	mov    %edx,0x18(%esp)
  800809:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80080c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800810:	89 44 24 10          	mov    %eax,0x10(%esp)
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800822:	8b 45 0c             	mov    0xc(%ebp),%eax
  800825:	89 44 24 04          	mov    %eax,0x4(%esp)
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	89 04 24             	mov    %eax,(%esp)
  80082f:	e8 f1 fa ff ff       	call   800325 <printnum>
			break;
  800834:	eb 3c                	jmp    800872 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800836:	8b 45 0c             	mov    0xc(%ebp),%eax
  800839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083d:	89 1c 24             	mov    %ebx,(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	ff d0                	call   *%eax
			break;
  800845:	eb 2b                	jmp    800872 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80085e:	eb 04                	jmp    800864 <vprintfmt+0x3cb>
  800860:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800864:	8b 45 10             	mov    0x10(%ebp),%eax
  800867:	83 e8 01             	sub    $0x1,%eax
  80086a:	0f b6 00             	movzbl (%eax),%eax
  80086d:	3c 25                	cmp    $0x25,%al
  80086f:	75 ef                	jne    800860 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800871:	90                   	nop
		}
	}
  800872:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800873:	e9 43 fc ff ff       	jmp    8004bb <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800878:	83 c4 40             	add    $0x40,%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800885:	8d 45 14             	lea    0x14(%ebp),%eax
  800888:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80088b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800892:	8b 45 10             	mov    0x10(%ebp),%eax
  800895:	89 44 24 08          	mov    %eax,0x8(%esp)
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	89 04 24             	mov    %eax,(%esp)
  8008a6:	e8 ee fb ff ff       	call   800499 <vprintfmt>
	va_end(ap);
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	8b 40 08             	mov    0x8(%eax),%eax
  8008b6:	8d 50 01             	lea    0x1(%eax),%edx
  8008b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bc:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c2:	8b 10                	mov    (%eax),%edx
  8008c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c7:	8b 40 04             	mov    0x4(%eax),%eax
  8008ca:	39 c2                	cmp    %eax,%edx
  8008cc:	73 12                	jae    8008e0 <sprintputch+0x33>
		*b->buf++ = ch;
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	8d 48 01             	lea    0x1(%eax),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d9:	89 0a                	mov    %ecx,(%edx)
  8008db:	8b 55 08             	mov    0x8(%ebp),%edx
  8008de:	88 10                	mov    %dl,(%eax)
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f1:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	01 d0                	add    %edx,%eax
  8008f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800903:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800907:	74 06                	je     80090f <vsnprintf+0x2d>
  800909:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80090d:	7f 07                	jg     800916 <vsnprintf+0x34>
		return -E_INVAL;
  80090f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800914:	eb 2a                	jmp    800940 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80091d:	8b 45 10             	mov    0x10(%ebp),%eax
  800920:	89 44 24 08          	mov    %eax,0x8(%esp)
  800924:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092b:	c7 04 24 ad 08 80 00 	movl   $0x8008ad,(%esp)
  800932:	e8 62 fb ff ff       	call   800499 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800937:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80093a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800948:	8d 45 14             	lea    0x14(%ebp),%eax
  80094b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80094e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800951:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800955:	8b 45 10             	mov    0x10(%ebp),%eax
  800958:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 74 ff ff ff       	call   8008e2 <vsnprintf>
  80096e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800971:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80097c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800983:	eb 08                	jmp    80098d <strlen+0x17>
		n++;
  800985:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800989:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	0f b6 00             	movzbl (%eax),%eax
  800993:	84 c0                	test   %al,%al
  800995:	75 ee                	jne    800985 <strlen+0xf>
		n++;
	return n;
  800997:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009a9:	eb 0c                	jmp    8009b7 <strnlen+0x1b>
		n++;
  8009ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009b3:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8009b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009bb:	74 0a                	je     8009c7 <strnlen+0x2b>
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 00             	movzbl (%eax),%eax
  8009c3:	84 c0                	test   %al,%al
  8009c5:	75 e4                	jne    8009ab <strnlen+0xf>
		n++;
	return n;
  8009c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009d8:	90                   	nop
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8d 50 01             	lea    0x1(%eax),%edx
  8009df:	89 55 08             	mov    %edx,0x8(%ebp)
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009e8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	88 10                	mov    %dl,(%eax)
  8009f0:	0f b6 00             	movzbl (%eax),%eax
  8009f3:	84 c0                	test   %al,%al
  8009f5:	75 e2                	jne    8009d9 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 69 ff ff ff       	call   800976 <strlen>
  800a0d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800a10:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	01 c2                	add    %eax,%edx
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1f:	89 14 24             	mov    %edx,(%esp)
  800a22:	e8 a5 ff ff ff       	call   8009cc <strcpy>
	return dst;
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a38:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a3f:	eb 23                	jmp    800a64 <strncpy+0x38>
		*dst++ = *src;
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8d 50 01             	lea    0x1(%eax),%edx
  800a47:	89 55 08             	mov    %edx,0x8(%ebp)
  800a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4d:	0f b6 12             	movzbl (%edx),%edx
  800a50:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	0f b6 00             	movzbl (%eax),%eax
  800a58:	84 c0                	test   %al,%al
  800a5a:	74 04                	je     800a60 <strncpy+0x34>
			src++;
  800a5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a60:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a67:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a6a:	72 d5                	jb     800a41 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a81:	74 33                	je     800ab6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a83:	eb 17                	jmp    800a9c <strlcpy+0x2b>
			*dst++ = *src++;
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8d 50 01             	lea    0x1(%eax),%edx
  800a8b:	89 55 08             	mov    %edx,0x8(%ebp)
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a91:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a94:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a97:	0f b6 12             	movzbl (%edx),%edx
  800a9a:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a9c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aa0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa4:	74 0a                	je     800ab0 <strlcpy+0x3f>
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	0f b6 00             	movzbl (%eax),%eax
  800aac:	84 c0                	test   %al,%al
  800aae:	75 d5                	jne    800a85 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800abc:	29 c2                	sub    %eax,%edx
  800abe:	89 d0                	mov    %edx,%eax
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800ac5:	eb 08                	jmp    800acf <strcmp+0xd>
		p++, q++;
  800ac7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800acb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	0f b6 00             	movzbl (%eax),%eax
  800ad5:	84 c0                	test   %al,%al
  800ad7:	74 10                	je     800ae9 <strcmp+0x27>
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 10             	movzbl (%eax),%edx
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	0f b6 00             	movzbl (%eax),%eax
  800ae5:	38 c2                	cmp    %al,%dl
  800ae7:	74 de                	je     800ac7 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 00             	movzbl (%eax),%eax
  800aef:	0f b6 d0             	movzbl %al,%edx
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	0f b6 00             	movzbl (%eax),%eax
  800af8:	0f b6 c0             	movzbl %al,%eax
  800afb:	29 c2                	sub    %eax,%edx
  800afd:	89 d0                	mov    %edx,%eax
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800b04:	eb 0c                	jmp    800b12 <strncmp+0x11>
		n--, p++, q++;
  800b06:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b0a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b0e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b16:	74 1a                	je     800b32 <strncmp+0x31>
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	0f b6 00             	movzbl (%eax),%eax
  800b1e:	84 c0                	test   %al,%al
  800b20:	74 10                	je     800b32 <strncmp+0x31>
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	0f b6 10             	movzbl (%eax),%edx
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	0f b6 00             	movzbl (%eax),%eax
  800b2e:	38 c2                	cmp    %al,%dl
  800b30:	74 d4                	je     800b06 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b36:	75 07                	jne    800b3f <strncmp+0x3e>
		return 0;
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3d:	eb 16                	jmp    800b55 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	0f b6 00             	movzbl (%eax),%eax
  800b45:	0f b6 d0             	movzbl %al,%edx
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	0f b6 00             	movzbl (%eax),%eax
  800b4e:	0f b6 c0             	movzbl %al,%eax
  800b51:	29 c2                	sub    %eax,%edx
  800b53:	89 d0                	mov    %edx,%eax
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 04             	sub    $0x4,%esp
  800b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b60:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b63:	eb 14                	jmp    800b79 <strchr+0x22>
		if (*s == c)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	0f b6 00             	movzbl (%eax),%eax
  800b6b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b6e:	75 05                	jne    800b75 <strchr+0x1e>
			return (char *) s;
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	eb 13                	jmp    800b88 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	0f b6 00             	movzbl (%eax),%eax
  800b7f:	84 c0                	test   %al,%al
  800b81:	75 e2                	jne    800b65 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    

00800b8a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	83 ec 04             	sub    $0x4,%esp
  800b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b93:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b96:	eb 11                	jmp    800ba9 <strfind+0x1f>
		if (*s == c)
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	0f b6 00             	movzbl (%eax),%eax
  800b9e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ba1:	75 02                	jne    800ba5 <strfind+0x1b>
			break;
  800ba3:	eb 0e                	jmp    800bb3 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ba5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 00             	movzbl (%eax),%eax
  800baf:	84 c0                	test   %al,%al
  800bb1:	75 e5                	jne    800b98 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800bb3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
	char *p;

	if (n == 0)
  800bbc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bc0:	75 05                	jne    800bc7 <memset+0xf>
		return v;
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	eb 5c                	jmp    800c23 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	83 e0 03             	and    $0x3,%eax
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	75 41                	jne    800c12 <memset+0x5a>
  800bd1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd4:	83 e0 03             	and    $0x3,%eax
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	75 37                	jne    800c12 <memset+0x5a>
		c &= 0xFF;
  800bdb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	c1 e0 18             	shl    $0x18,%eax
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	c1 e0 10             	shl    $0x10,%eax
  800bf0:	09 c2                	or     %eax,%edx
  800bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf5:	c1 e0 08             	shl    $0x8,%eax
  800bf8:	09 d0                	or     %edx,%eax
  800bfa:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bfd:	8b 45 10             	mov    0x10(%ebp),%eax
  800c00:	c1 e8 02             	shr    $0x2,%eax
  800c03:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0b:	89 d7                	mov    %edx,%edi
  800c0d:	fc                   	cld    
  800c0e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c10:	eb 0e                	jmp    800c20 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c18:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	fc                   	cld    
  800c1e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c41:	73 6d                	jae    800cb0 <memmove+0x8a>
  800c43:	8b 45 10             	mov    0x10(%ebp),%eax
  800c46:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c49:	01 d0                	add    %edx,%eax
  800c4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c4e:	76 60                	jbe    800cb0 <memmove+0x8a>
		s += n;
  800c50:	8b 45 10             	mov    0x10(%ebp),%eax
  800c53:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c56:	8b 45 10             	mov    0x10(%ebp),%eax
  800c59:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5f:	83 e0 03             	and    $0x3,%eax
  800c62:	85 c0                	test   %eax,%eax
  800c64:	75 2f                	jne    800c95 <memmove+0x6f>
  800c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c69:	83 e0 03             	and    $0x3,%eax
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	75 25                	jne    800c95 <memmove+0x6f>
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	83 e0 03             	and    $0x3,%eax
  800c76:	85 c0                	test   %eax,%eax
  800c78:	75 1b                	jne    800c95 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c7d:	83 e8 04             	sub    $0x4,%eax
  800c80:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c83:	83 ea 04             	sub    $0x4,%edx
  800c86:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c89:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	fd                   	std    
  800c91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c93:	eb 18                	jmp    800cad <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c98:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c9e:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ca1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca4:	89 d7                	mov    %edx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	89 c1                	mov    %eax,%ecx
  800caa:	fd                   	std    
  800cab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cad:	fc                   	cld    
  800cae:	eb 45                	jmp    800cf5 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb3:	83 e0 03             	and    $0x3,%eax
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	75 2b                	jne    800ce5 <memmove+0xbf>
  800cba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cbd:	83 e0 03             	and    $0x3,%eax
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	75 21                	jne    800ce5 <memmove+0xbf>
  800cc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc7:	83 e0 03             	and    $0x3,%eax
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	75 17                	jne    800ce5 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cce:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd1:	c1 e8 02             	shr    $0x2,%eax
  800cd4:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 d6                	mov    %edx,%esi
  800ce0:	fc                   	cld    
  800ce1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ce3:	eb 10                	jmp    800cf5 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ce5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ceb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	fc                   	cld    
  800cf3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cf8:	83 c4 10             	add    $0x10,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d06:	8b 45 10             	mov    0x10(%ebp),%eax
  800d09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	89 04 24             	mov    %eax,(%esp)
  800d1a:	e8 07 ff ff ff       	call   800c26 <memmove>
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d33:	eb 30                	jmp    800d65 <memcmp+0x44>
		if (*s1 != *s2)
  800d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d38:	0f b6 10             	movzbl (%eax),%edx
  800d3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d3e:	0f b6 00             	movzbl (%eax),%eax
  800d41:	38 c2                	cmp    %al,%dl
  800d43:	74 18                	je     800d5d <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d48:	0f b6 00             	movzbl (%eax),%eax
  800d4b:	0f b6 d0             	movzbl %al,%edx
  800d4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d51:	0f b6 00             	movzbl (%eax),%eax
  800d54:	0f b6 c0             	movzbl %al,%eax
  800d57:	29 c2                	sub    %eax,%edx
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	eb 1a                	jmp    800d77 <memcmp+0x56>
		s1++, s2++;
  800d5d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d61:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d65:	8b 45 10             	mov    0x10(%ebp),%eax
  800d68:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d6b:	89 55 10             	mov    %edx,0x10(%ebp)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	75 c3                	jne    800d35 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	01 d0                	add    %edx,%eax
  800d87:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d8a:	eb 13                	jmp    800d9f <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8f:	0f b6 10             	movzbl (%eax),%edx
  800d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d95:	38 c2                	cmp    %al,%dl
  800d97:	75 02                	jne    800d9b <memfind+0x22>
			break;
  800d99:	eb 0c                	jmp    800da7 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d9b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800da5:	72 e5                	jb     800d8c <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800daa:	c9                   	leave  
  800dab:	c3                   	ret    

00800dac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800db2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800db9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dc0:	eb 04                	jmp    800dc6 <strtol+0x1a>
		s++;
  800dc2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	0f b6 00             	movzbl (%eax),%eax
  800dcc:	3c 20                	cmp    $0x20,%al
  800dce:	74 f2                	je     800dc2 <strtol+0x16>
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	0f b6 00             	movzbl (%eax),%eax
  800dd6:	3c 09                	cmp    $0x9,%al
  800dd8:	74 e8                	je     800dc2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	3c 2b                	cmp    $0x2b,%al
  800de2:	75 06                	jne    800dea <strtol+0x3e>
		s++;
  800de4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de8:	eb 15                	jmp    800dff <strtol+0x53>
	else if (*s == '-')
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	0f b6 00             	movzbl (%eax),%eax
  800df0:	3c 2d                	cmp    $0x2d,%al
  800df2:	75 0b                	jne    800dff <strtol+0x53>
		s++, neg = 1;
  800df4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e03:	74 06                	je     800e0b <strtol+0x5f>
  800e05:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800e09:	75 24                	jne    800e2f <strtol+0x83>
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	0f b6 00             	movzbl (%eax),%eax
  800e11:	3c 30                	cmp    $0x30,%al
  800e13:	75 1a                	jne    800e2f <strtol+0x83>
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	83 c0 01             	add    $0x1,%eax
  800e1b:	0f b6 00             	movzbl (%eax),%eax
  800e1e:	3c 78                	cmp    $0x78,%al
  800e20:	75 0d                	jne    800e2f <strtol+0x83>
		s += 2, base = 16;
  800e22:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e26:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e2d:	eb 2a                	jmp    800e59 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e33:	75 17                	jne    800e4c <strtol+0xa0>
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	0f b6 00             	movzbl (%eax),%eax
  800e3b:	3c 30                	cmp    $0x30,%al
  800e3d:	75 0d                	jne    800e4c <strtol+0xa0>
		s++, base = 8;
  800e3f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e43:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e4a:	eb 0d                	jmp    800e59 <strtol+0xad>
	else if (base == 0)
  800e4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e50:	75 07                	jne    800e59 <strtol+0xad>
		base = 10;
  800e52:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	0f b6 00             	movzbl (%eax),%eax
  800e5f:	3c 2f                	cmp    $0x2f,%al
  800e61:	7e 1b                	jle    800e7e <strtol+0xd2>
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	0f b6 00             	movzbl (%eax),%eax
  800e69:	3c 39                	cmp    $0x39,%al
  800e6b:	7f 11                	jg     800e7e <strtol+0xd2>
			dig = *s - '0';
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	0f b6 00             	movzbl (%eax),%eax
  800e73:	0f be c0             	movsbl %al,%eax
  800e76:	83 e8 30             	sub    $0x30,%eax
  800e79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e7c:	eb 48                	jmp    800ec6 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e81:	0f b6 00             	movzbl (%eax),%eax
  800e84:	3c 60                	cmp    $0x60,%al
  800e86:	7e 1b                	jle    800ea3 <strtol+0xf7>
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	0f b6 00             	movzbl (%eax),%eax
  800e8e:	3c 7a                	cmp    $0x7a,%al
  800e90:	7f 11                	jg     800ea3 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	0f b6 00             	movzbl (%eax),%eax
  800e98:	0f be c0             	movsbl %al,%eax
  800e9b:	83 e8 57             	sub    $0x57,%eax
  800e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ea1:	eb 23                	jmp    800ec6 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	0f b6 00             	movzbl (%eax),%eax
  800ea9:	3c 40                	cmp    $0x40,%al
  800eab:	7e 3d                	jle    800eea <strtol+0x13e>
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	0f b6 00             	movzbl (%eax),%eax
  800eb3:	3c 5a                	cmp    $0x5a,%al
  800eb5:	7f 33                	jg     800eea <strtol+0x13e>
			dig = *s - 'A' + 10;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	0f b6 00             	movzbl (%eax),%eax
  800ebd:	0f be c0             	movsbl %al,%eax
  800ec0:	83 e8 37             	sub    $0x37,%eax
  800ec3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ecc:	7c 02                	jl     800ed0 <strtol+0x124>
			break;
  800ece:	eb 1a                	jmp    800eea <strtol+0x13e>
		s++, val = (val * base) + dig;
  800ed0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ed4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ed7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee0:	01 d0                	add    %edx,%eax
  800ee2:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ee5:	e9 6f ff ff ff       	jmp    800e59 <strtol+0xad>

	if (endptr)
  800eea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eee:	74 08                	je     800ef8 <strtol+0x14c>
		*endptr = (char *) s;
  800ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ef8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800efc:	74 07                	je     800f05 <strtol+0x159>
  800efe:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f01:	f7 d8                	neg    %eax
  800f03:	eb 03                	jmp    800f08 <strtol+0x15c>
  800f05:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	8b 55 10             	mov    0x10(%ebp),%edx
  800f19:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f1c:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800f1f:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f22:	8b 75 20             	mov    0x20(%ebp),%esi
  800f25:	cd 30                	int    $0x30
  800f27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f2e:	74 30                	je     800f60 <syscall+0x56>
  800f30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f34:	7e 2a                	jle    800f60 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f44:	c7 44 24 08 04 20 80 	movl   $0x802004,0x8(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f53:	00 
  800f54:	c7 04 24 21 20 80 00 	movl   $0x802021,(%esp)
  800f5b:	e8 17 0a 00 00       	call   801977 <_panic>

	return ret;
  800f60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f63:	83 c4 3c             	add    $0x3c,%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
  800f74:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f83:	00 
  800f84:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f8b:	00 
  800f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9e:	00 
  800f9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa6:	e8 5f ff ff ff       	call   800f0a <syscall>
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <sys_cgetc>:

int
sys_cgetc(void)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fb3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fba:	00 
  800fbb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fca:	00 
  800fcb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe2:	00 
  800fe3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fea:	e8 1b ff ff ff       	call   800f0a <syscall>
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801001:	00 
  801002:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801009:	00 
  80100a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801011:	00 
  801012:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801019:	00 
  80101a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801025:	00 
  801026:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80102d:	e8 d8 fe ff ff       	call   800f0a <syscall>
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80103a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801041:	00 
  801042:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801049:	00 
  80104a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801051:	00 
  801052:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801059:	00 
  80105a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801061:	00 
  801062:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801069:	00 
  80106a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801071:	e8 94 fe ff ff       	call   800f0a <syscall>
}
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <sys_yield>:

void
sys_yield(void)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80107e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801085:	00 
  801086:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80108d:	00 
  80108e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801095:	00 
  801096:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80109d:	00 
  80109e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ad:	00 
  8010ae:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8010b5:	e8 50 fe ff ff       	call   800f0a <syscall>
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010d2:	00 
  8010d3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010da:	00 
  8010db:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010ee:	00 
  8010ef:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010f6:	e8 0f fe ff ff       	call   800f0a <syscall>
}
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    

008010fd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801105:	8b 75 18             	mov    0x18(%ebp),%esi
  801108:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80110b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	89 74 24 18          	mov    %esi,0x18(%esp)
  801118:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80111c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801120:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801124:	89 44 24 08          	mov    %eax,0x8(%esp)
  801128:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80112f:	00 
  801130:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801137:	e8 ce fd ff ff       	call   800f0a <syscall>
}
  80113c:	83 c4 20             	add    $0x20,%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  801177:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80117e:	e8 87 fd ff ff       	call   800f0a <syscall>
}
  801183:	c9                   	leave  
  801184:	c3                   	ret    

00801185 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80118b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801198:	00 
  801199:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011a8:	00 
  8011a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011c0:	e8 45 fd ff ff       	call   800f0a <syscall>
}
  8011c5:	c9                   	leave  
  8011c6:	c3                   	ret    

008011c7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011da:	00 
  8011db:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011ea:	00 
  8011eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801202:	e8 03 fd ff ff       	call   800f0a <syscall>
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    

00801209 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80120f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801212:	8b 55 10             	mov    0x10(%ebp),%edx
  801215:	8b 45 08             	mov    0x8(%ebp),%eax
  801218:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80121f:	00 
  801220:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801224:	89 54 24 10          	mov    %edx,0x10(%esp)
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80122f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801233:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80123a:	00 
  80123b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801242:	e8 c3 fc ff ff       	call   800f0a <syscall>
}
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801259:	00 
  80125a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801261:	00 
  801262:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801269:	00 
  80126a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801271:	00 
  801272:	89 44 24 08          	mov    %eax,0x8(%esp)
  801276:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80127d:	00 
  80127e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801285:	e8 80 fc ff ff       	call   800f0a <syscall>
}
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <sys_exec>:

void sys_exec(char* buf){
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  801292:	8b 45 08             	mov    0x8(%ebp),%eax
  801295:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80129c:	00 
  80129d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012b4:	00 
  8012b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8012c8:	e8 3d fc ff ff       	call   800f0a <syscall>
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <sys_wait>:

void sys_wait(){
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  8012d5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012dc:	00 
  8012dd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012e4:	00 
  8012e5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012f4:	00 
  8012f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012fc:	00 
  8012fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801304:	00 
  801305:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80130c:	e8 f9 fb ff ff       	call   800f0a <syscall>
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <sys_guest>:

void sys_guest(){
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  801319:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801320:	00 
  801321:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801328:	00 
  801329:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801330:	00 
  801331:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801338:	00 
  801339:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801340:	00 
  801341:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801348:	00 
  801349:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  801350:	e8 b5 fb ff ff       	call   800f0a <syscall>
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	8b 00                	mov    (%eax),%eax
  801362:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  801365:	8b 45 08             	mov    0x8(%ebp),%eax
  801368:	8b 40 04             	mov    0x4(%eax),%eax
  80136b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  80136e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801371:	83 e0 02             	and    $0x2,%eax
  801374:	85 c0                	test   %eax,%eax
  801376:	75 23                	jne    80139b <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  801378:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137f:	c7 44 24 08 30 20 80 	movl   $0x802030,0x8(%esp)
  801386:	00 
  801387:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80138e:	00 
  80138f:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  801396:	e8 dc 05 00 00       	call   801977 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	c1 e8 0c             	shr    $0xc,%eax
  8013a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8013a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ae:	25 00 08 00 00       	and    $0x800,%eax
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	75 1c                	jne    8013d3 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8013b7:	c7 44 24 08 6c 20 80 	movl   $0x80206c,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8013c6:	00 
  8013c7:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  8013ce:	e8 a4 05 00 00       	call   801977 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8013d3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013da:	00 
  8013db:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013e2:	00 
  8013e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ea:	e8 cd fc ff ff       	call   8010bc <sys_page_alloc>
  8013ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8013f2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013f6:	79 23                	jns    80141b <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8013f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ff:	c7 44 24 08 a8 20 80 	movl   $0x8020a8,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  801416:	e8 5c 05 00 00       	call   801977 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  80141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801421:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801424:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801429:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801430:	00 
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80143c:	e8 bf f8 ff ff       	call   800d00 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801441:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801447:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80144a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80144f:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801456:	00 
  801457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801462:	00 
  801463:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80146a:	00 
  80146b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801472:	e8 86 fc ff ff       	call   8010fd <sys_page_map>
  801477:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80147a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80147e:	79 23                	jns    8014a3 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801480:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801487:	c7 44 24 08 e0 20 80 	movl   $0x8020e0,0x8(%esp)
  80148e:	00 
  80148f:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  801496:	00 
  801497:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  80149e:	e8 d4 04 00 00       	call   801977 <_panic>
	}

	// panic("pgfault not implemented");
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	56                   	push   %esi
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8014ad:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8014b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014be:	25 00 08 00 00       	and    $0x800,%eax
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	75 15                	jne    8014dc <duppage+0x37>
  8014c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d1:	83 e0 02             	and    $0x2,%eax
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	0f 84 e0 00 00 00    	je     8015bc <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8014dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e6:	83 e0 04             	and    $0x4,%eax
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	74 04                	je     8014f1 <duppage+0x4c>
  8014ed:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8014f1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f7:	c1 e0 0c             	shl    $0xc,%eax
  8014fa:	89 c1                	mov    %eax,%ecx
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	c1 e0 0c             	shl    $0xc,%eax
  801502:	89 c2                	mov    %eax,%edx
  801504:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801509:	8b 40 48             	mov    0x48(%eax),%eax
  80150c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801510:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801514:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801517:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 d6 fb ff ff       	call   8010fd <sys_page_map>
  801527:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80152a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80152e:	79 23                	jns    801553 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801533:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801537:	c7 44 24 08 14 21 80 	movl   $0x802114,0x8(%esp)
  80153e:	00 
  80153f:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  801546:	00 
  801547:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  80154e:	e8 24 04 00 00       	call   801977 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801553:	8b 75 f4             	mov    -0xc(%ebp),%esi
  801556:	8b 45 0c             	mov    0xc(%ebp),%eax
  801559:	c1 e0 0c             	shl    $0xc,%eax
  80155c:	89 c3                	mov    %eax,%ebx
  80155e:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801563:	8b 48 48             	mov    0x48(%eax),%ecx
  801566:	8b 45 0c             	mov    0xc(%ebp),%eax
  801569:	c1 e0 0c             	shl    $0xc,%eax
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801573:	8b 40 48             	mov    0x48(%eax),%eax
  801576:	89 74 24 10          	mov    %esi,0x10(%esp)
  80157a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80157e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801582:	89 54 24 04          	mov    %edx,0x4(%esp)
  801586:	89 04 24             	mov    %eax,(%esp)
  801589:	e8 6f fb ff ff       	call   8010fd <sys_page_map>
  80158e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801591:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801595:	79 23                	jns    8015ba <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  801597:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159e:	c7 44 24 08 50 21 80 	movl   $0x802150,0x8(%esp)
  8015a5:	00 
  8015a6:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8015ad:	00 
  8015ae:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  8015b5:	e8 bd 03 00 00       	call   801977 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8015ba:	eb 70                	jmp    80162c <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  8015bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c6:	25 ff 0f 00 00       	and    $0xfff,%eax
  8015cb:	89 c3                	mov    %eax,%ebx
  8015cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d0:	c1 e0 0c             	shl    $0xc,%eax
  8015d3:	89 c1                	mov    %eax,%ecx
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	c1 e0 0c             	shl    $0xc,%eax
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8015e2:	8b 40 48             	mov    0x48(%eax),%eax
  8015e5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8015e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8015ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015f4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f8:	89 04 24             	mov    %eax,(%esp)
  8015fb:	e8 fd fa ff ff       	call   8010fd <sys_page_map>
  801600:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801603:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801607:	79 23                	jns    80162c <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  801609:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801610:	c7 44 24 08 80 21 80 	movl   $0x802180,0x8(%esp)
  801617:	00 
  801618:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  80161f:	00 
  801620:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  801627:	e8 4b 03 00 00       	call   801977 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  80162c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801631:	83 c4 30             	add    $0x30,%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80163e:	c7 04 24 57 13 80 00 	movl   $0x801357,(%esp)
  801645:	e8 88 03 00 00       	call   8019d2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80164a:	b8 07 00 00 00       	mov    $0x7,%eax
  80164f:	cd 30                	int    $0x30
  801651:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801654:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  801657:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  80165a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80165e:	79 23                	jns    801683 <fork+0x4b>
  801660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801663:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801667:	c7 44 24 08 b8 21 80 	movl   $0x8021b8,0x8(%esp)
  80166e:	00 
  80166f:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  801676:	00 
  801677:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  80167e:	e8 f4 02 00 00       	call   801977 <_panic>
	else if(childeid == 0){
  801683:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801687:	75 29                	jne    8016b2 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801689:	e8 a6 f9 ff ff       	call   801034 <sys_getenvid>
  80168e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801693:	c1 e0 02             	shl    $0x2,%eax
  801696:	89 c2                	mov    %eax,%edx
  801698:	c1 e2 05             	shl    $0x5,%edx
  80169b:	29 c2                	sub    %eax,%edx
  80169d:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8016a3:	a3 0c 30 80 00       	mov    %eax,0x80300c
		// set_pgfault_handler(pgfault);
		return 0;
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ad:	e9 16 01 00 00       	jmp    8017c8 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8016b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8016b9:	eb 3b                	jmp    8016f6 <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  8016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016be:	c1 f8 0a             	sar    $0xa,%eax
  8016c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016c8:	83 e0 01             	and    $0x1,%eax
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	74 23                	je     8016f2 <fork+0xba>
  8016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d9:	83 e0 01             	and    $0x1,%eax
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	74 12                	je     8016f2 <fork+0xba>
			duppage(childeid, i);
  8016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	89 04 24             	mov    %eax,(%esp)
  8016ed:	e8 b3 fd ff ff       	call   8014a5 <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8016f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8016f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f9:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  8016fe:	76 bb                	jbe    8016bb <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801700:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801707:	00 
  801708:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80170f:	ee 
  801710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801713:	89 04 24             	mov    %eax,(%esp)
  801716:	e8 a1 f9 ff ff       	call   8010bc <sys_page_alloc>
  80171b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80171e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801722:	79 23                	jns    801747 <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  801724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801727:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80172b:	c7 44 24 08 e0 21 80 	movl   $0x8021e0,0x8(%esp)
  801732:	00 
  801733:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  80173a:	00 
  80173b:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  801742:	e8 30 02 00 00       	call   801977 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  801747:	c7 44 24 04 48 1a 80 	movl   $0x801a48,0x4(%esp)
  80174e:	00 
  80174f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801752:	89 04 24             	mov    %eax,(%esp)
  801755:	e8 6d fa ff ff       	call   8011c7 <sys_env_set_pgfault_upcall>
  80175a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80175d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801761:	79 23                	jns    801786 <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  801763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80176a:	c7 44 24 08 08 22 80 	movl   $0x802208,0x8(%esp)
  801771:	00 
  801772:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801779:	00 
  80177a:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  801781:	e8 f1 01 00 00       	call   801977 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  801786:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80178d:	00 
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 ec f9 ff ff       	call   801185 <sys_env_set_status>
  801799:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80179c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8017a0:	79 23                	jns    8017c5 <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8017a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a9:	c7 44 24 08 3c 22 80 	movl   $0x80223c,0x8(%esp)
  8017b0:	00 
  8017b1:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8017b8:	00 
  8017b9:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  8017c0:	e8 b2 01 00 00       	call   801977 <_panic>
	}
	return childeid;
  8017c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    

008017ca <sfork>:

// Challenge!
int
sfork(void)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8017d0:	c7 44 24 08 65 22 80 	movl   $0x802265,0x8(%esp)
  8017d7:	00 
  8017d8:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8017df:	00 
  8017e0:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  8017e7:	e8 8b 01 00 00       	call   801977 <_panic>

008017ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  8017f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8017f6:	75 09                	jne    801801 <ipc_recv+0x15>
		i_dstva = UTOP;
  8017f8:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  8017ff:	eb 06                	jmp    801807 <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  801807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180a:	89 04 24             	mov    %eax,(%esp)
  80180d:	e8 37 fa ff ff       	call   801249 <sys_ipc_recv>
  801812:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  801815:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801819:	75 15                	jne    801830 <ipc_recv+0x44>
  80181b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80181f:	74 0f                	je     801830 <ipc_recv+0x44>
  801821:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801826:	8b 50 74             	mov    0x74(%eax),%edx
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	89 10                	mov    %edx,(%eax)
  80182e:	eb 15                	jmp    801845 <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  801830:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801834:	79 0f                	jns    801845 <ipc_recv+0x59>
  801836:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80183a:	74 09                	je     801845 <ipc_recv+0x59>
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  801845:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801849:	75 15                	jne    801860 <ipc_recv+0x74>
  80184b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80184f:	74 0f                	je     801860 <ipc_recv+0x74>
  801851:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801856:	8b 50 78             	mov    0x78(%eax),%edx
  801859:	8b 45 10             	mov    0x10(%ebp),%eax
  80185c:	89 10                	mov    %edx,(%eax)
  80185e:	eb 15                	jmp    801875 <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  801860:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801864:	79 0f                	jns    801875 <ipc_recv+0x89>
  801866:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80186a:	74 09                	je     801875 <ipc_recv+0x89>
  80186c:	8b 45 10             	mov    0x10(%ebp),%eax
  80186f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  801875:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801879:	75 0a                	jne    801885 <ipc_recv+0x99>
  80187b:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801880:	8b 40 70             	mov    0x70(%eax),%eax
  801883:	eb 03                	jmp    801888 <ipc_recv+0x9c>
	else return r;
  801885:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  801890:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  801897:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80189b:	74 06                	je     8018a3 <ipc_send+0x19>
  80189d:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	8b 55 14             	mov    0x14(%ebp),%edx
  8018a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	89 04 24             	mov    %eax,(%esp)
  8018be:	e8 46 f9 ff ff       	call   801209 <sys_ipc_try_send>
  8018c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  8018c6:	eb 28                	jmp    8018f0 <ipc_send+0x66>
		sys_yield();
  8018c8:	e8 ab f7 ff ff       	call   801078 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8018cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d0:	8b 55 14             	mov    0x14(%ebp),%edx
  8018d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	89 04 24             	mov    %eax,(%esp)
  8018e8:	e8 1c f9 ff ff       	call   801209 <sys_ipc_try_send>
  8018ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  8018f0:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  8018f4:	74 d2                	je     8018c8 <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  8018f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8018fa:	75 02                	jne    8018fe <ipc_send+0x74>
  8018fc:	eb 23                	jmp    801921 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  8018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801905:	c7 44 24 08 7c 22 80 	movl   $0x80227c,0x8(%esp)
  80190c:	00 
  80190d:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801914:	00 
  801915:	c7 04 24 a1 22 80 00 	movl   $0x8022a1,(%esp)
  80191c:	e8 56 00 00 00       	call   801977 <_panic>
	panic("ipc_send not implemented");
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  801929:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801930:	eb 35                	jmp    801967 <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801932:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801935:	c1 e0 02             	shl    $0x2,%eax
  801938:	89 c2                	mov    %eax,%edx
  80193a:	c1 e2 05             	shl    $0x5,%edx
  80193d:	29 c2                	sub    %eax,%edx
  80193f:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  801945:	8b 00                	mov    (%eax),%eax
  801947:	3b 45 08             	cmp    0x8(%ebp),%eax
  80194a:	75 17                	jne    801963 <ipc_find_env+0x40>
			return envs[i].env_id;
  80194c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80194f:	c1 e0 02             	shl    $0x2,%eax
  801952:	89 c2                	mov    %eax,%edx
  801954:	c1 e2 05             	shl    $0x5,%edx
  801957:	29 c2                	sub    %eax,%edx
  801959:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  80195f:	8b 00                	mov    (%eax),%eax
  801961:	eb 12                	jmp    801975 <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801963:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801967:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  80196e:	7e c2                	jle    801932 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80197e:	8d 45 14             	lea    0x14(%ebp),%eax
  801981:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801984:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  80198a:	e8 a5 f6 ff ff       	call   801034 <sys_getenvid>
  80198f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801992:	89 54 24 10          	mov    %edx,0x10(%esp)
  801996:	8b 55 08             	mov    0x8(%ebp),%edx
  801999:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80199d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a5:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  8019ac:	e8 4e e9 ff ff       	call   8002ff <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 d8 e8 ff ff       	call   80029b <vcprintf>
	cprintf("\n");
  8019c3:	c7 04 24 cf 22 80 00 	movl   $0x8022cf,(%esp)
  8019ca:	e8 30 e9 ff ff       	call   8002ff <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019cf:	cc                   	int3   
  8019d0:	eb fd                	jmp    8019cf <_panic+0x58>

008019d2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8019d8:	a1 10 30 80 00       	mov    0x803010,%eax
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	75 5d                	jne    801a3e <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8019e1:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8019e6:	8b 40 48             	mov    0x48(%eax),%eax
  8019e9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019f0:	00 
  8019f1:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8019f8:	ee 
  8019f9:	89 04 24             	mov    %eax,(%esp)
  8019fc:	e8 bb f6 ff ff       	call   8010bc <sys_page_alloc>
  801a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801a04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801a08:	79 1c                	jns    801a26 <set_pgfault_handler+0x54>
  801a0a:	c7 44 24 08 d4 22 80 	movl   $0x8022d4,0x8(%esp)
  801a11:	00 
  801a12:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801a19:	00 
  801a1a:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  801a21:	e8 51 ff ff ff       	call   801977 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801a26:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801a2b:	8b 40 48             	mov    0x48(%eax),%eax
  801a2e:	c7 44 24 04 48 1a 80 	movl   $0x801a48,0x4(%esp)
  801a35:	00 
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 89 f7 ff ff       	call   8011c7 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	a3 10 30 80 00       	mov    %eax,0x803010
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801a48:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801a49:	a1 10 30 80 00       	mov    0x803010,%eax
	call *%eax
  801a4e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801a50:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801a53:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801a57:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801a59:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801a5d:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801a5e:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  801a61:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  801a63:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801a64:	58                   	pop    %eax
	popal 						// pop all the registers
  801a65:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801a66:	83 c4 04             	add    $0x4,%esp
	popfl
  801a69:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801a6a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801a6b:	c3                   	ret    
  801a6c:	66 90                	xchg   %ax,%ax
  801a6e:	66 90                	xchg   %ax,%ax

00801a70 <__udivdi3>:
  801a70:	55                   	push   %ebp
  801a71:	57                   	push   %edi
  801a72:	56                   	push   %esi
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a7a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801a7e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801a82:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a86:	85 c0                	test   %eax,%eax
  801a88:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a8c:	89 ea                	mov    %ebp,%edx
  801a8e:	89 0c 24             	mov    %ecx,(%esp)
  801a91:	75 2d                	jne    801ac0 <__udivdi3+0x50>
  801a93:	39 e9                	cmp    %ebp,%ecx
  801a95:	77 61                	ja     801af8 <__udivdi3+0x88>
  801a97:	85 c9                	test   %ecx,%ecx
  801a99:	89 ce                	mov    %ecx,%esi
  801a9b:	75 0b                	jne    801aa8 <__udivdi3+0x38>
  801a9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa2:	31 d2                	xor    %edx,%edx
  801aa4:	f7 f1                	div    %ecx
  801aa6:	89 c6                	mov    %eax,%esi
  801aa8:	31 d2                	xor    %edx,%edx
  801aaa:	89 e8                	mov    %ebp,%eax
  801aac:	f7 f6                	div    %esi
  801aae:	89 c5                	mov    %eax,%ebp
  801ab0:	89 f8                	mov    %edi,%eax
  801ab2:	f7 f6                	div    %esi
  801ab4:	89 ea                	mov    %ebp,%edx
  801ab6:	83 c4 0c             	add    $0xc,%esp
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    
  801abd:	8d 76 00             	lea    0x0(%esi),%esi
  801ac0:	39 e8                	cmp    %ebp,%eax
  801ac2:	77 24                	ja     801ae8 <__udivdi3+0x78>
  801ac4:	0f bd e8             	bsr    %eax,%ebp
  801ac7:	83 f5 1f             	xor    $0x1f,%ebp
  801aca:	75 3c                	jne    801b08 <__udivdi3+0x98>
  801acc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ad0:	39 34 24             	cmp    %esi,(%esp)
  801ad3:	0f 86 9f 00 00 00    	jbe    801b78 <__udivdi3+0x108>
  801ad9:	39 d0                	cmp    %edx,%eax
  801adb:	0f 82 97 00 00 00    	jb     801b78 <__udivdi3+0x108>
  801ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	31 d2                	xor    %edx,%edx
  801aea:	31 c0                	xor    %eax,%eax
  801aec:	83 c4 0c             	add    $0xc,%esp
  801aef:	5e                   	pop    %esi
  801af0:	5f                   	pop    %edi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    
  801af3:	90                   	nop
  801af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af8:	89 f8                	mov    %edi,%eax
  801afa:	f7 f1                	div    %ecx
  801afc:	31 d2                	xor    %edx,%edx
  801afe:	83 c4 0c             	add    $0xc,%esp
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    
  801b05:	8d 76 00             	lea    0x0(%esi),%esi
  801b08:	89 e9                	mov    %ebp,%ecx
  801b0a:	8b 3c 24             	mov    (%esp),%edi
  801b0d:	d3 e0                	shl    %cl,%eax
  801b0f:	89 c6                	mov    %eax,%esi
  801b11:	b8 20 00 00 00       	mov    $0x20,%eax
  801b16:	29 e8                	sub    %ebp,%eax
  801b18:	89 c1                	mov    %eax,%ecx
  801b1a:	d3 ef                	shr    %cl,%edi
  801b1c:	89 e9                	mov    %ebp,%ecx
  801b1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801b22:	8b 3c 24             	mov    (%esp),%edi
  801b25:	09 74 24 08          	or     %esi,0x8(%esp)
  801b29:	89 d6                	mov    %edx,%esi
  801b2b:	d3 e7                	shl    %cl,%edi
  801b2d:	89 c1                	mov    %eax,%ecx
  801b2f:	89 3c 24             	mov    %edi,(%esp)
  801b32:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b36:	d3 ee                	shr    %cl,%esi
  801b38:	89 e9                	mov    %ebp,%ecx
  801b3a:	d3 e2                	shl    %cl,%edx
  801b3c:	89 c1                	mov    %eax,%ecx
  801b3e:	d3 ef                	shr    %cl,%edi
  801b40:	09 d7                	or     %edx,%edi
  801b42:	89 f2                	mov    %esi,%edx
  801b44:	89 f8                	mov    %edi,%eax
  801b46:	f7 74 24 08          	divl   0x8(%esp)
  801b4a:	89 d6                	mov    %edx,%esi
  801b4c:	89 c7                	mov    %eax,%edi
  801b4e:	f7 24 24             	mull   (%esp)
  801b51:	39 d6                	cmp    %edx,%esi
  801b53:	89 14 24             	mov    %edx,(%esp)
  801b56:	72 30                	jb     801b88 <__udivdi3+0x118>
  801b58:	8b 54 24 04          	mov    0x4(%esp),%edx
  801b5c:	89 e9                	mov    %ebp,%ecx
  801b5e:	d3 e2                	shl    %cl,%edx
  801b60:	39 c2                	cmp    %eax,%edx
  801b62:	73 05                	jae    801b69 <__udivdi3+0xf9>
  801b64:	3b 34 24             	cmp    (%esp),%esi
  801b67:	74 1f                	je     801b88 <__udivdi3+0x118>
  801b69:	89 f8                	mov    %edi,%eax
  801b6b:	31 d2                	xor    %edx,%edx
  801b6d:	e9 7a ff ff ff       	jmp    801aec <__udivdi3+0x7c>
  801b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b78:	31 d2                	xor    %edx,%edx
  801b7a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7f:	e9 68 ff ff ff       	jmp    801aec <__udivdi3+0x7c>
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	8d 47 ff             	lea    -0x1(%edi),%eax
  801b8b:	31 d2                	xor    %edx,%edx
  801b8d:	83 c4 0c             	add    $0xc,%esp
  801b90:	5e                   	pop    %esi
  801b91:	5f                   	pop    %edi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    
  801b94:	66 90                	xchg   %ax,%ax
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__umoddi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	83 ec 14             	sub    $0x14,%esp
  801ba6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801baa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801bae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801bb2:	89 c7                	mov    %eax,%edi
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801bbc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801bc0:	89 34 24             	mov    %esi,(%esp)
  801bc3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	89 c2                	mov    %eax,%edx
  801bcb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bcf:	75 17                	jne    801be8 <__umoddi3+0x48>
  801bd1:	39 fe                	cmp    %edi,%esi
  801bd3:	76 4b                	jbe    801c20 <__umoddi3+0x80>
  801bd5:	89 c8                	mov    %ecx,%eax
  801bd7:	89 fa                	mov    %edi,%edx
  801bd9:	f7 f6                	div    %esi
  801bdb:	89 d0                	mov    %edx,%eax
  801bdd:	31 d2                	xor    %edx,%edx
  801bdf:	83 c4 14             	add    $0x14,%esp
  801be2:	5e                   	pop    %esi
  801be3:	5f                   	pop    %edi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    
  801be6:	66 90                	xchg   %ax,%ax
  801be8:	39 f8                	cmp    %edi,%eax
  801bea:	77 54                	ja     801c40 <__umoddi3+0xa0>
  801bec:	0f bd e8             	bsr    %eax,%ebp
  801bef:	83 f5 1f             	xor    $0x1f,%ebp
  801bf2:	75 5c                	jne    801c50 <__umoddi3+0xb0>
  801bf4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801bf8:	39 3c 24             	cmp    %edi,(%esp)
  801bfb:	0f 87 e7 00 00 00    	ja     801ce8 <__umoddi3+0x148>
  801c01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801c05:	29 f1                	sub    %esi,%ecx
  801c07:	19 c7                	sbb    %eax,%edi
  801c09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c11:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801c19:	83 c4 14             	add    $0x14,%esp
  801c1c:	5e                   	pop    %esi
  801c1d:	5f                   	pop    %edi
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    
  801c20:	85 f6                	test   %esi,%esi
  801c22:	89 f5                	mov    %esi,%ebp
  801c24:	75 0b                	jne    801c31 <__umoddi3+0x91>
  801c26:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2b:	31 d2                	xor    %edx,%edx
  801c2d:	f7 f6                	div    %esi
  801c2f:	89 c5                	mov    %eax,%ebp
  801c31:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c35:	31 d2                	xor    %edx,%edx
  801c37:	f7 f5                	div    %ebp
  801c39:	89 c8                	mov    %ecx,%eax
  801c3b:	f7 f5                	div    %ebp
  801c3d:	eb 9c                	jmp    801bdb <__umoddi3+0x3b>
  801c3f:	90                   	nop
  801c40:	89 c8                	mov    %ecx,%eax
  801c42:	89 fa                	mov    %edi,%edx
  801c44:	83 c4 14             	add    $0x14,%esp
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    
  801c4b:	90                   	nop
  801c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c50:	8b 04 24             	mov    (%esp),%eax
  801c53:	be 20 00 00 00       	mov    $0x20,%esi
  801c58:	89 e9                	mov    %ebp,%ecx
  801c5a:	29 ee                	sub    %ebp,%esi
  801c5c:	d3 e2                	shl    %cl,%edx
  801c5e:	89 f1                	mov    %esi,%ecx
  801c60:	d3 e8                	shr    %cl,%eax
  801c62:	89 e9                	mov    %ebp,%ecx
  801c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c68:	8b 04 24             	mov    (%esp),%eax
  801c6b:	09 54 24 04          	or     %edx,0x4(%esp)
  801c6f:	89 fa                	mov    %edi,%edx
  801c71:	d3 e0                	shl    %cl,%eax
  801c73:	89 f1                	mov    %esi,%ecx
  801c75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c79:	8b 44 24 10          	mov    0x10(%esp),%eax
  801c7d:	d3 ea                	shr    %cl,%edx
  801c7f:	89 e9                	mov    %ebp,%ecx
  801c81:	d3 e7                	shl    %cl,%edi
  801c83:	89 f1                	mov    %esi,%ecx
  801c85:	d3 e8                	shr    %cl,%eax
  801c87:	89 e9                	mov    %ebp,%ecx
  801c89:	09 f8                	or     %edi,%eax
  801c8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801c8f:	f7 74 24 04          	divl   0x4(%esp)
  801c93:	d3 e7                	shl    %cl,%edi
  801c95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c99:	89 d7                	mov    %edx,%edi
  801c9b:	f7 64 24 08          	mull   0x8(%esp)
  801c9f:	39 d7                	cmp    %edx,%edi
  801ca1:	89 c1                	mov    %eax,%ecx
  801ca3:	89 14 24             	mov    %edx,(%esp)
  801ca6:	72 2c                	jb     801cd4 <__umoddi3+0x134>
  801ca8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801cac:	72 22                	jb     801cd0 <__umoddi3+0x130>
  801cae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801cb2:	29 c8                	sub    %ecx,%eax
  801cb4:	19 d7                	sbb    %edx,%edi
  801cb6:	89 e9                	mov    %ebp,%ecx
  801cb8:	89 fa                	mov    %edi,%edx
  801cba:	d3 e8                	shr    %cl,%eax
  801cbc:	89 f1                	mov    %esi,%ecx
  801cbe:	d3 e2                	shl    %cl,%edx
  801cc0:	89 e9                	mov    %ebp,%ecx
  801cc2:	d3 ef                	shr    %cl,%edi
  801cc4:	09 d0                	or     %edx,%eax
  801cc6:	89 fa                	mov    %edi,%edx
  801cc8:	83 c4 14             	add    $0x14,%esp
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    
  801ccf:	90                   	nop
  801cd0:	39 d7                	cmp    %edx,%edi
  801cd2:	75 da                	jne    801cae <__umoddi3+0x10e>
  801cd4:	8b 14 24             	mov    (%esp),%edx
  801cd7:	89 c1                	mov    %eax,%ecx
  801cd9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801cdd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801ce1:	eb cb                	jmp    801cae <__umoddi3+0x10e>
  801ce3:	90                   	nop
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801cec:	0f 82 0f ff ff ff    	jb     801c01 <__umoddi3+0x61>
  801cf2:	e9 1a ff ff ff       	jmp    801c11 <__umoddi3+0x71>
