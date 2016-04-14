
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
  800039:	e8 3f 15 00 00       	call   80157d <fork>
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
  800062:	e8 ca 16 00 00       	call   801731 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800067:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006a:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  800071:	00 
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  80007d:	e8 8d 02 00 00       	call   80030f <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800082:	a1 00 30 80 00       	mov    0x803000,%eax
  800087:	89 04 24             	mov    %eax,(%esp)
  80008a:	e8 f7 08 00 00       	call   800986 <strlen>
  80008f:	89 c2                	mov    %eax,%edx
  800091:	a1 00 30 80 00       	mov    0x803000,%eax
  800096:	89 54 24 08          	mov    %edx,0x8(%esp)
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a5:	e8 67 0a 00 00       	call   800b11 <strncmp>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 0c                	jne    8000ba <umain+0x87>
			cprintf("child received correct message\n");
  8000ae:	c7 04 24 c0 1c 80 00 	movl   $0x801cc0,(%esp)
  8000b5:	e8 55 02 00 00       	call   80030f <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000ba:	a1 04 30 80 00       	mov    0x803004,%eax
  8000bf:	89 04 24             	mov    %eax,(%esp)
  8000c2:	e8 bf 08 00 00       	call   800986 <strlen>
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	89 c2                	mov    %eax,%edx
  8000cc:	a1 04 30 80 00       	mov    0x803004,%eax
  8000d1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d9:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000e0:	e8 2b 0c 00 00       	call   800d10 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000e8:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000ef:	00 
  8000f0:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000f7:	00 
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 04 24             	mov    %eax,(%esp)
  800103:	e8 c7 16 00 00       	call   8017cf <ipc_send>
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
  800128:	e8 9f 0f 00 00       	call   8010cc <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  80012d:	a1 00 30 80 00       	mov    0x803000,%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 4c 08 00 00       	call   800986 <strlen>
  80013a:	83 c0 01             	add    $0x1,%eax
  80013d:	89 c2                	mov    %eax,%edx
  80013f:	a1 00 30 80 00       	mov    0x803000,%eax
  800144:	89 54 24 08          	mov    %edx,0x8(%esp)
  800148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014c:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800153:	e8 b8 0b 00 00       	call   800d10 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80015b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800162:	00 
  800163:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80016a:	00 
  80016b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800172:	00 
  800173:	89 04 24             	mov    %eax,(%esp)
  800176:	e8 54 16 00 00       	call   8017cf <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80017b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800182:	00 
  800183:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80018a:	00 
  80018b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 9b 15 00 00       	call   801731 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  8001a0:	00 
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	c7 04 24 ac 1c 80 00 	movl   $0x801cac,(%esp)
  8001ac:	e8 5e 01 00 00       	call   80030f <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001b1:	a1 04 30 80 00       	mov    0x803004,%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 c8 07 00 00       	call   800986 <strlen>
  8001be:	89 c2                	mov    %eax,%edx
  8001c0:	a1 04 30 80 00       	mov    0x803004,%eax
  8001c5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001d4:	e8 38 09 00 00       	call   800b11 <strncmp>
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	75 0c                	jne    8001e9 <umain+0x1b6>
		cprintf("parent received correct message\n");
  8001dd:	c7 04 24 e0 1c 80 00 	movl   $0x801ce0,(%esp)
  8001e4:	e8 26 01 00 00       	call   80030f <cprintf>
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
  8001f2:	e8 4d 0e 00 00       	call   801044 <sys_getenvid>
  8001f7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fc:	c1 e0 02             	shl    $0x2,%eax
  8001ff:	89 c2                	mov    %eax,%edx
  800201:	c1 e2 05             	shl    $0x5,%edx
  800204:	29 c2                	sub    %eax,%edx
  800206:	89 d0                	mov    %edx,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 0c 30 80 00       	mov    %eax,0x80300c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800212:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800216:	7e 0a                	jle    800222 <libmain+0x36>
		binaryname = argv[0];
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	8b 00                	mov    (%eax),%eax
  80021d:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  800222:	8b 45 0c             	mov    0xc(%ebp),%eax
  800225:	89 44 24 04          	mov    %eax,0x4(%esp)
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	89 04 24             	mov    %eax,(%esp)
  80022f:	e8 ff fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800234:	e8 02 00 00 00       	call   80023b <exit>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 b4 0d 00 00       	call   801001 <sys_env_destroy>
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800255:	8b 45 0c             	mov    0xc(%ebp),%eax
  800258:	8b 00                	mov    (%eax),%eax
  80025a:	8d 48 01             	lea    0x1(%eax),%ecx
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	89 0a                	mov    %ecx,(%edx)
  800262:	8b 55 08             	mov    0x8(%ebp),%edx
  800265:	89 d1                	mov    %edx,%ecx
  800267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026a:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800271:	8b 00                	mov    (%eax),%eax
  800273:	3d ff 00 00 00       	cmp    $0xff,%eax
  800278:	75 20                	jne    80029a <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80027a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027d:	8b 00                	mov    (%eax),%eax
  80027f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800282:	83 c2 08             	add    $0x8,%edx
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	89 14 24             	mov    %edx,(%esp)
  80028c:	e8 ea 0c 00 00       	call   800f7b <sys_cputs>
		b->idx = 0;
  800291:	8b 45 0c             	mov    0xc(%ebp),%eax
  800294:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029d:	8b 40 04             	mov    0x4(%eax),%eax
  8002a0:	8d 50 01             	lea    0x1(%eax),%edx
  8002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a6:	89 50 04             	mov    %edx,0x4(%eax)
}
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bb:	00 00 00 
	b.cnt = 0;
  8002be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e0:	c7 04 24 4f 02 80 00 	movl   $0x80024f,(%esp)
  8002e7:	e8 bd 01 00 00       	call   8004a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ec:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fc:	83 c0 08             	add    $0x8,%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	e8 74 0c 00 00       	call   800f7b <sys_cputs>

	return b.cnt;
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
  800318:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80031b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80031e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800322:	8b 45 08             	mov    0x8(%ebp),%eax
  800325:	89 04 24             	mov    %eax,(%esp)
  800328:	e8 7e ff ff ff       	call   8002ab <vcprintf>
  80032d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800330:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	53                   	push   %ebx
  800339:	83 ec 34             	sub    $0x34,%esp
  80033c:	8b 45 10             	mov    0x10(%ebp),%eax
  80033f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800342:	8b 45 14             	mov    0x14(%ebp),%eax
  800345:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800348:	8b 45 18             	mov    0x18(%ebp),%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800353:	77 72                	ja     8003c7 <printnum+0x92>
  800355:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800358:	72 05                	jb     80035f <printnum+0x2a>
  80035a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80035d:	77 68                	ja     8003c7 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800362:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800365:	8b 45 18             	mov    0x18(%ebp),%eax
  800368:	ba 00 00 00 00       	mov    $0x0,%edx
  80036d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800371:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800375:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800378:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80037b:	89 04 24             	mov    %eax,(%esp)
  80037e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800382:	e8 39 16 00 00       	call   8019c0 <__udivdi3>
  800387:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80038a:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80038e:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800392:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800395:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800399:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	89 04 24             	mov    %eax,(%esp)
  8003ae:	e8 82 ff ff ff       	call   800335 <printnum>
  8003b3:	eb 1c                	jmp    8003d1 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bc:	8b 45 20             	mov    0x20(%ebp),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c5:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8003cb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003cf:	7f e4                	jg     8003b5 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d1:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003ee:	e8 fd 16 00 00       	call   801af0 <__umoddi3>
  8003f3:	05 e8 1d 80 00       	add    $0x801de8,%eax
  8003f8:	0f b6 00             	movzbl (%eax),%eax
  8003fb:	0f be c0             	movsbl %al,%eax
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 54 24 04          	mov    %edx,0x4(%esp)
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
  80040b:	ff d0                	call   *%eax
}
  80040d:	83 c4 34             	add    $0x34,%esp
  800410:	5b                   	pop    %ebx
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800416:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80041a:	7e 14                	jle    800430 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80041c:	8b 45 08             	mov    0x8(%ebp),%eax
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	8d 48 08             	lea    0x8(%eax),%ecx
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	89 0a                	mov    %ecx,(%edx)
  800429:	8b 50 04             	mov    0x4(%eax),%edx
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	eb 30                	jmp    800460 <getuint+0x4d>
	else if (lflag)
  800430:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800434:	74 16                	je     80044c <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	8d 48 04             	lea    0x4(%eax),%ecx
  80043e:	8b 55 08             	mov    0x8(%ebp),%edx
  800441:	89 0a                	mov    %ecx,(%edx)
  800443:	8b 00                	mov    (%eax),%eax
  800445:	ba 00 00 00 00       	mov    $0x0,%edx
  80044a:	eb 14                	jmp    800460 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80044c:	8b 45 08             	mov    0x8(%ebp),%eax
  80044f:	8b 00                	mov    (%eax),%eax
  800451:	8d 48 04             	lea    0x4(%eax),%ecx
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	89 0a                	mov    %ecx,(%edx)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800465:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800469:	7e 14                	jle    80047f <getint+0x1d>
		return va_arg(*ap, long long);
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	8b 00                	mov    (%eax),%eax
  800470:	8d 48 08             	lea    0x8(%eax),%ecx
  800473:	8b 55 08             	mov    0x8(%ebp),%edx
  800476:	89 0a                	mov    %ecx,(%edx)
  800478:	8b 50 04             	mov    0x4(%eax),%edx
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	eb 28                	jmp    8004a7 <getint+0x45>
	else if (lflag)
  80047f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800483:	74 12                	je     800497 <getint+0x35>
		return va_arg(*ap, long);
  800485:	8b 45 08             	mov    0x8(%ebp),%eax
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	8d 48 04             	lea    0x4(%eax),%ecx
  80048d:	8b 55 08             	mov    0x8(%ebp),%edx
  800490:	89 0a                	mov    %ecx,(%edx)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	99                   	cltd   
  800495:	eb 10                	jmp    8004a7 <getint+0x45>
	else
		return va_arg(*ap, int);
  800497:	8b 45 08             	mov    0x8(%ebp),%eax
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	8d 48 04             	lea    0x4(%eax),%ecx
  80049f:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a2:	89 0a                	mov    %ecx,(%edx)
  8004a4:	8b 00                	mov    (%eax),%eax
  8004a6:	99                   	cltd   
}
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b1:	eb 18                	jmp    8004cb <vprintfmt+0x22>
			if (ch == '\0')
  8004b3:	85 db                	test   %ebx,%ebx
  8004b5:	75 05                	jne    8004bc <vprintfmt+0x13>
				return;
  8004b7:	e9 cc 03 00 00       	jmp    800888 <vprintfmt+0x3df>
			putch(ch, putdat);
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	89 1c 24             	mov    %ebx,(%esp)
  8004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c9:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ce:	8d 50 01             	lea    0x1(%eax),%edx
  8004d1:	89 55 10             	mov    %edx,0x10(%ebp)
  8004d4:	0f b6 00             	movzbl (%eax),%eax
  8004d7:	0f b6 d8             	movzbl %al,%ebx
  8004da:	83 fb 25             	cmp    $0x25,%ebx
  8004dd:	75 d4                	jne    8004b3 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004df:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004e3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004ea:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004f1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8004f8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800502:	8d 50 01             	lea    0x1(%eax),%edx
  800505:	89 55 10             	mov    %edx,0x10(%ebp)
  800508:	0f b6 00             	movzbl (%eax),%eax
  80050b:	0f b6 d8             	movzbl %al,%ebx
  80050e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800511:	83 f8 55             	cmp    $0x55,%eax
  800514:	0f 87 3d 03 00 00    	ja     800857 <vprintfmt+0x3ae>
  80051a:	8b 04 85 0c 1e 80 00 	mov    0x801e0c(,%eax,4),%eax
  800521:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800523:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800527:	eb d6                	jmp    8004ff <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800529:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80052d:	eb d0                	jmp    8004ff <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800536:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800539:	89 d0                	mov    %edx,%eax
  80053b:	c1 e0 02             	shl    $0x2,%eax
  80053e:	01 d0                	add    %edx,%eax
  800540:	01 c0                	add    %eax,%eax
  800542:	01 d8                	add    %ebx,%eax
  800544:	83 e8 30             	sub    $0x30,%eax
  800547:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80054a:	8b 45 10             	mov    0x10(%ebp),%eax
  80054d:	0f b6 00             	movzbl (%eax),%eax
  800550:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800553:	83 fb 2f             	cmp    $0x2f,%ebx
  800556:	7e 0b                	jle    800563 <vprintfmt+0xba>
  800558:	83 fb 39             	cmp    $0x39,%ebx
  80055b:	7f 06                	jg     800563 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80055d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800561:	eb d3                	jmp    800536 <vprintfmt+0x8d>
			goto process_precision;
  800563:	eb 33                	jmp    800598 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800573:	eb 23                	jmp    800598 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800575:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800579:	79 0c                	jns    800587 <vprintfmt+0xde>
				width = 0;
  80057b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800582:	e9 78 ff ff ff       	jmp    8004ff <vprintfmt+0x56>
  800587:	e9 73 ff ff ff       	jmp    8004ff <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80058c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800593:	e9 67 ff ff ff       	jmp    8004ff <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800598:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059c:	79 12                	jns    8005b0 <vprintfmt+0x107>
				width = precision, precision = -1;
  80059e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8005ab:	e9 4f ff ff ff       	jmp    8004ff <vprintfmt+0x56>
  8005b0:	e9 4a ff ff ff       	jmp    8004ff <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005b5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8005b9:	e9 41 ff ff ff       	jmp    8004ff <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 50 04             	lea    0x4(%eax),%edx
  8005c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d6:	ff d0                	call   *%eax
			break;
  8005d8:	e9 a5 02 00 00       	jmp    800882 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005e8:	85 db                	test   %ebx,%ebx
  8005ea:	79 02                	jns    8005ee <vprintfmt+0x145>
				err = -err;
  8005ec:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ee:	83 fb 09             	cmp    $0x9,%ebx
  8005f1:	7f 0b                	jg     8005fe <vprintfmt+0x155>
  8005f3:	8b 34 9d c0 1d 80 00 	mov    0x801dc0(,%ebx,4),%esi
  8005fa:	85 f6                	test   %esi,%esi
  8005fc:	75 23                	jne    800621 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800602:	c7 44 24 08 f9 1d 80 	movl   $0x801df9,0x8(%esp)
  800609:	00 
  80060a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	8b 45 08             	mov    0x8(%ebp),%eax
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	e8 73 02 00 00       	call   80088f <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80061c:	e9 61 02 00 00       	jmp    800882 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800621:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800625:	c7 44 24 08 02 1e 80 	movl   $0x801e02,0x8(%esp)
  80062c:	00 
  80062d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800630:	89 44 24 04          	mov    %eax,0x4(%esp)
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	e8 50 02 00 00       	call   80088f <printfmt>
			break;
  80063f:	e9 3e 02 00 00       	jmp    800882 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 30                	mov    (%eax),%esi
  80064f:	85 f6                	test   %esi,%esi
  800651:	75 05                	jne    800658 <vprintfmt+0x1af>
				p = "(null)";
  800653:	be 05 1e 80 00       	mov    $0x801e05,%esi
			if (width > 0 && padc != '-')
  800658:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065c:	7e 37                	jle    800695 <vprintfmt+0x1ec>
  80065e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800662:	74 31                	je     800695 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800664:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	89 34 24             	mov    %esi,(%esp)
  80066e:	e8 39 03 00 00       	call   8009ac <strnlen>
  800673:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800676:	eb 17                	jmp    80068f <vprintfmt+0x1e6>
					putch(padc, putdat);
  800678:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80067c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80068f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800693:	7f e3                	jg     800678 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800695:	eb 38                	jmp    8006cf <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800697:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069b:	74 1f                	je     8006bc <vprintfmt+0x213>
  80069d:	83 fb 1f             	cmp    $0x1f,%ebx
  8006a0:	7e 05                	jle    8006a7 <vprintfmt+0x1fe>
  8006a2:	83 fb 7e             	cmp    $0x7e,%ebx
  8006a5:	7e 15                	jle    8006bc <vprintfmt+0x213>
					putch('?', putdat);
  8006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	ff d0                	call   *%eax
  8006ba:	eb 0f                	jmp    8006cb <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c3:	89 1c 24             	mov    %ebx,(%esp)
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cb:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	8d 70 01             	lea    0x1(%eax),%esi
  8006d4:	0f b6 00             	movzbl (%eax),%eax
  8006d7:	0f be d8             	movsbl %al,%ebx
  8006da:	85 db                	test   %ebx,%ebx
  8006dc:	74 10                	je     8006ee <vprintfmt+0x245>
  8006de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e2:	78 b3                	js     800697 <vprintfmt+0x1ee>
  8006e4:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8006e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ec:	79 a9                	jns    800697 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ee:	eb 17                	jmp    800707 <vprintfmt+0x25e>
				putch(' ', putdat);
  8006f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800703:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800707:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80070b:	7f e3                	jg     8006f0 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80070d:	e9 70 01 00 00       	jmp    800882 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800712:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800715:	89 44 24 04          	mov    %eax,0x4(%esp)
  800719:	8d 45 14             	lea    0x14(%ebp),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	e8 3e fd ff ff       	call   800462 <getint>
  800724:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800727:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80072a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800730:	85 d2                	test   %edx,%edx
  800732:	79 26                	jns    80075a <vprintfmt+0x2b1>
				putch('-', putdat);
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	ff d0                	call   *%eax
				num = -(long long) num;
  800747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074d:	f7 d8                	neg    %eax
  80074f:	83 d2 00             	adc    $0x0,%edx
  800752:	f7 da                	neg    %edx
  800754:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800757:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80075a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800761:	e9 a8 00 00 00       	jmp    80080e <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800766:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076d:	8d 45 14             	lea    0x14(%ebp),%eax
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	e8 9b fc ff ff       	call   800413 <getuint>
  800778:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80077b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  80077e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800785:	e9 84 00 00 00       	jmp    80080e <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80078a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	e8 77 fc ff ff       	call   800413 <getuint>
  80079c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80079f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8007a2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8007a9:	eb 63                	jmp    80080e <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	ff d0                	call   *%eax
			putch('x', putdat);
  8007be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007ed:	eb 1f                	jmp    80080e <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8007f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f9:	89 04 24             	mov    %eax,(%esp)
  8007fc:	e8 12 fc ff ff       	call   800413 <getuint>
  800801:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800804:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800807:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80080e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800812:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800815:	89 54 24 18          	mov    %edx,0x18(%esp)
  800819:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80081c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800820:	89 44 24 10          	mov    %eax,0x10(%esp)
  800824:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800827:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80082a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800832:	8b 45 0c             	mov    0xc(%ebp),%eax
  800835:	89 44 24 04          	mov    %eax,0x4(%esp)
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	89 04 24             	mov    %eax,(%esp)
  80083f:	e8 f1 fa ff ff       	call   800335 <printnum>
			break;
  800844:	eb 3c                	jmp    800882 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800846:	8b 45 0c             	mov    0xc(%ebp),%eax
  800849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084d:	89 1c 24             	mov    %ebx,(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	ff d0                	call   *%eax
			break;
  800855:	eb 2b                	jmp    800882 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80086e:	eb 04                	jmp    800874 <vprintfmt+0x3cb>
  800870:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800874:	8b 45 10             	mov    0x10(%ebp),%eax
  800877:	83 e8 01             	sub    $0x1,%eax
  80087a:	0f b6 00             	movzbl (%eax),%eax
  80087d:	3c 25                	cmp    $0x25,%al
  80087f:	75 ef                	jne    800870 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800881:	90                   	nop
		}
	}
  800882:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800883:	e9 43 fc ff ff       	jmp    8004cb <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800888:	83 c4 40             	add    $0x40,%esp
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800895:	8d 45 14             	lea    0x14(%ebp),%eax
  800898:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	89 04 24             	mov    %eax,(%esp)
  8008b6:	e8 ee fb ff ff       	call   8004a9 <vprintfmt>
	va_end(ap);
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c3:	8b 40 08             	mov    0x8(%eax),%eax
  8008c6:	8d 50 01             	lea    0x1(%eax),%edx
  8008c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cc:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d2:	8b 10                	mov    (%eax),%edx
  8008d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d7:	8b 40 04             	mov    0x4(%eax),%eax
  8008da:	39 c2                	cmp    %eax,%edx
  8008dc:	73 12                	jae    8008f0 <sprintputch+0x33>
		*b->buf++ = ch;
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	8b 00                	mov    (%eax),%eax
  8008e3:	8d 48 01             	lea    0x1(%eax),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 0a                	mov    %ecx,(%edx)
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ee:	88 10                	mov    %dl,(%eax)
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	8d 50 ff             	lea    -0x1(%eax),%edx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	01 d0                	add    %edx,%eax
  800909:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80090c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800913:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800917:	74 06                	je     80091f <vsnprintf+0x2d>
  800919:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80091d:	7f 07                	jg     800926 <vsnprintf+0x34>
		return -E_INVAL;
  80091f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800924:	eb 2a                	jmp    800950 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092d:	8b 45 10             	mov    0x10(%ebp),%eax
  800930:	89 44 24 08          	mov    %eax,0x8(%esp)
  800934:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093b:	c7 04 24 bd 08 80 00 	movl   $0x8008bd,(%esp)
  800942:	e8 62 fb ff ff       	call   8004a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800947:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80095e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800961:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 74 ff ff ff       	call   8008f2 <vsnprintf>
  80097e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800981:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  80098c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800993:	eb 08                	jmp    80099d <strlen+0x17>
		n++;
  800995:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800999:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	0f b6 00             	movzbl (%eax),%eax
  8009a3:	84 c0                	test   %al,%al
  8009a5:	75 ee                	jne    800995 <strlen+0xf>
		n++;
	return n;
  8009a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009b9:	eb 0c                	jmp    8009c7 <strnlen+0x1b>
		n++;
  8009bb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009c3:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  8009c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009cb:	74 0a                	je     8009d7 <strnlen+0x2b>
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 00             	movzbl (%eax),%eax
  8009d3:	84 c0                	test   %al,%al
  8009d5:	75 e4                	jne    8009bb <strnlen+0xf>
		n++;
	return n;
  8009d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009e8:	90                   	nop
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8d 50 01             	lea    0x1(%eax),%edx
  8009ef:	89 55 08             	mov    %edx,0x8(%ebp)
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009f8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009fb:	0f b6 12             	movzbl (%edx),%edx
  8009fe:	88 10                	mov    %dl,(%eax)
  800a00:	0f b6 00             	movzbl (%eax),%eax
  800a03:	84 c0                	test   %al,%al
  800a05:	75 e2                	jne    8009e9 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 69 ff ff ff       	call   800986 <strlen>
  800a1d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800a20:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	01 c2                	add    %eax,%edx
  800a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2f:	89 14 24             	mov    %edx,(%esp)
  800a32:	e8 a5 ff ff ff       	call   8009dc <strcpy>
	return dst;
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a48:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a4f:	eb 23                	jmp    800a74 <strncpy+0x38>
		*dst++ = *src;
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8d 50 01             	lea    0x1(%eax),%edx
  800a57:	89 55 08             	mov    %edx,0x8(%ebp)
  800a5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5d:	0f b6 12             	movzbl (%edx),%edx
  800a60:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	0f b6 00             	movzbl (%eax),%eax
  800a68:	84 c0                	test   %al,%al
  800a6a:	74 04                	je     800a70 <strncpy+0x34>
			src++;
  800a6c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a70:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a77:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a7a:	72 d5                	jb     800a51 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a7c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a8d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a91:	74 33                	je     800ac6 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a93:	eb 17                	jmp    800aac <strlcpy+0x2b>
			*dst++ = *src++;
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8d 50 01             	lea    0x1(%eax),%edx
  800a9b:	89 55 08             	mov    %edx,0x8(%ebp)
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa1:	8d 4a 01             	lea    0x1(%edx),%ecx
  800aa4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800aa7:	0f b6 12             	movzbl (%edx),%edx
  800aaa:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aac:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ab0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab4:	74 0a                	je     800ac0 <strlcpy+0x3f>
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	0f b6 00             	movzbl (%eax),%eax
  800abc:	84 c0                	test   %al,%al
  800abe:	75 d5                	jne    800a95 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800acc:	29 c2                	sub    %eax,%edx
  800ace:	89 d0                	mov    %edx,%eax
}
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800ad5:	eb 08                	jmp    800adf <strcmp+0xd>
		p++, q++;
  800ad7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800adb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	0f b6 00             	movzbl (%eax),%eax
  800ae5:	84 c0                	test   %al,%al
  800ae7:	74 10                	je     800af9 <strcmp+0x27>
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af2:	0f b6 00             	movzbl (%eax),%eax
  800af5:	38 c2                	cmp    %al,%dl
  800af7:	74 de                	je     800ad7 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	0f b6 00             	movzbl (%eax),%eax
  800aff:	0f b6 d0             	movzbl %al,%edx
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	0f b6 00             	movzbl (%eax),%eax
  800b08:	0f b6 c0             	movzbl %al,%eax
  800b0b:	29 c2                	sub    %eax,%edx
  800b0d:	89 d0                	mov    %edx,%eax
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800b14:	eb 0c                	jmp    800b22 <strncmp+0x11>
		n--, p++, q++;
  800b16:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b1a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b1e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b26:	74 1a                	je     800b42 <strncmp+0x31>
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	0f b6 00             	movzbl (%eax),%eax
  800b2e:	84 c0                	test   %al,%al
  800b30:	74 10                	je     800b42 <strncmp+0x31>
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	0f b6 00             	movzbl (%eax),%eax
  800b3e:	38 c2                	cmp    %al,%dl
  800b40:	74 d4                	je     800b16 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800b42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b46:	75 07                	jne    800b4f <strncmp+0x3e>
		return 0;
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4d:	eb 16                	jmp    800b65 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	0f b6 00             	movzbl (%eax),%eax
  800b55:	0f b6 d0             	movzbl %al,%edx
  800b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5b:	0f b6 00             	movzbl (%eax),%eax
  800b5e:	0f b6 c0             	movzbl %al,%eax
  800b61:	29 c2                	sub    %eax,%edx
  800b63:	89 d0                	mov    %edx,%eax
}
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	83 ec 04             	sub    $0x4,%esp
  800b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b70:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b73:	eb 14                	jmp    800b89 <strchr+0x22>
		if (*s == c)
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	0f b6 00             	movzbl (%eax),%eax
  800b7b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b7e:	75 05                	jne    800b85 <strchr+0x1e>
			return (char *) s;
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	eb 13                	jmp    800b98 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b85:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 00             	movzbl (%eax),%eax
  800b8f:	84 c0                	test   %al,%al
  800b91:	75 e2                	jne    800b75 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	83 ec 04             	sub    $0x4,%esp
  800ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ba6:	eb 11                	jmp    800bb9 <strfind+0x1f>
		if (*s == c)
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	0f b6 00             	movzbl (%eax),%eax
  800bae:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800bb1:	75 02                	jne    800bb5 <strfind+0x1b>
			break;
  800bb3:	eb 0e                	jmp    800bc3 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bb5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	0f b6 00             	movzbl (%eax),%eax
  800bbf:	84 c0                	test   %al,%al
  800bc1:	75 e5                	jne    800ba8 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
	char *p;

	if (n == 0)
  800bcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bd0:	75 05                	jne    800bd7 <memset+0xf>
		return v;
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	eb 5c                	jmp    800c33 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	83 e0 03             	and    $0x3,%eax
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	75 41                	jne    800c22 <memset+0x5a>
  800be1:	8b 45 10             	mov    0x10(%ebp),%eax
  800be4:	83 e0 03             	and    $0x3,%eax
  800be7:	85 c0                	test   %eax,%eax
  800be9:	75 37                	jne    800c22 <memset+0x5a>
		c &= 0xFF;
  800beb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf5:	c1 e0 18             	shl    $0x18,%eax
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	c1 e0 10             	shl    $0x10,%eax
  800c00:	09 c2                	or     %eax,%edx
  800c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c05:	c1 e0 08             	shl    $0x8,%eax
  800c08:	09 d0                	or     %edx,%eax
  800c0a:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c10:	c1 e8 02             	shr    $0x2,%eax
  800c13:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	fc                   	cld    
  800c1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c20:	eb 0e                	jmp    800c30 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c28:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	fc                   	cld    
  800c2e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c42:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c51:	73 6d                	jae    800cc0 <memmove+0x8a>
  800c53:	8b 45 10             	mov    0x10(%ebp),%eax
  800c56:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c59:	01 d0                	add    %edx,%eax
  800c5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c5e:	76 60                	jbe    800cc0 <memmove+0x8a>
		s += n;
  800c60:	8b 45 10             	mov    0x10(%ebp),%eax
  800c63:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c66:	8b 45 10             	mov    0x10(%ebp),%eax
  800c69:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c6f:	83 e0 03             	and    $0x3,%eax
  800c72:	85 c0                	test   %eax,%eax
  800c74:	75 2f                	jne    800ca5 <memmove+0x6f>
  800c76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c79:	83 e0 03             	and    $0x3,%eax
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	75 25                	jne    800ca5 <memmove+0x6f>
  800c80:	8b 45 10             	mov    0x10(%ebp),%eax
  800c83:	83 e0 03             	and    $0x3,%eax
  800c86:	85 c0                	test   %eax,%eax
  800c88:	75 1b                	jne    800ca5 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c8d:	83 e8 04             	sub    $0x4,%eax
  800c90:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c93:	83 ea 04             	sub    $0x4,%edx
  800c96:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c99:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	89 d6                	mov    %edx,%esi
  800ca0:	fd                   	std    
  800ca1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca3:	eb 18                	jmp    800cbd <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca8:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cae:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb4:	89 d7                	mov    %edx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	89 c1                	mov    %eax,%ecx
  800cba:	fd                   	std    
  800cbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cbd:	fc                   	cld    
  800cbe:	eb 45                	jmp    800d05 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc3:	83 e0 03             	and    $0x3,%eax
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	75 2b                	jne    800cf5 <memmove+0xbf>
  800cca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ccd:	83 e0 03             	and    $0x3,%eax
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	75 21                	jne    800cf5 <memmove+0xbf>
  800cd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd7:	83 e0 03             	and    $0x3,%eax
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	75 17                	jne    800cf5 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cde:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce1:	c1 e8 02             	shr    $0x2,%eax
  800ce4:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ce6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ce9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	fc                   	cld    
  800cf1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf3:	eb 10                	jmp    800d05 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cfb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cfe:	89 c7                	mov    %eax,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	fc                   	cld    
  800d03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d16:	8b 45 10             	mov    0x10(%ebp),%eax
  800d19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	89 04 24             	mov    %eax,(%esp)
  800d2a:	e8 07 ff ff ff       	call   800c36 <memmove>
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d40:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800d43:	eb 30                	jmp    800d75 <memcmp+0x44>
		if (*s1 != *s2)
  800d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d48:	0f b6 10             	movzbl (%eax),%edx
  800d4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d4e:	0f b6 00             	movzbl (%eax),%eax
  800d51:	38 c2                	cmp    %al,%dl
  800d53:	74 18                	je     800d6d <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d58:	0f b6 00             	movzbl (%eax),%eax
  800d5b:	0f b6 d0             	movzbl %al,%edx
  800d5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d61:	0f b6 00             	movzbl (%eax),%eax
  800d64:	0f b6 c0             	movzbl %al,%eax
  800d67:	29 c2                	sub    %eax,%edx
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	eb 1a                	jmp    800d87 <memcmp+0x56>
		s1++, s2++;
  800d6d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d71:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d75:	8b 45 10             	mov    0x10(%ebp),%eax
  800d78:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d7b:	89 55 10             	mov    %edx,0x10(%ebp)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	75 c3                	jne    800d45 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	01 d0                	add    %edx,%eax
  800d97:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d9a:	eb 13                	jmp    800daf <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	0f b6 10             	movzbl (%eax),%edx
  800da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da5:	38 c2                	cmp    %al,%dl
  800da7:	75 02                	jne    800dab <memfind+0x22>
			break;
  800da9:	eb 0c                	jmp    800db7 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800db5:	72 e5                	jb     800d9c <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800dc2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800dc9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd0:	eb 04                	jmp    800dd6 <strtol+0x1a>
		s++;
  800dd2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	0f b6 00             	movzbl (%eax),%eax
  800ddc:	3c 20                	cmp    $0x20,%al
  800dde:	74 f2                	je     800dd2 <strtol+0x16>
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	3c 09                	cmp    $0x9,%al
  800de8:	74 e8                	je     800dd2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	0f b6 00             	movzbl (%eax),%eax
  800df0:	3c 2b                	cmp    $0x2b,%al
  800df2:	75 06                	jne    800dfa <strtol+0x3e>
		s++;
  800df4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df8:	eb 15                	jmp    800e0f <strtol+0x53>
	else if (*s == '-')
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	3c 2d                	cmp    $0x2d,%al
  800e02:	75 0b                	jne    800e0f <strtol+0x53>
		s++, neg = 1;
  800e04:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e08:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e13:	74 06                	je     800e1b <strtol+0x5f>
  800e15:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800e19:	75 24                	jne    800e3f <strtol+0x83>
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	0f b6 00             	movzbl (%eax),%eax
  800e21:	3c 30                	cmp    $0x30,%al
  800e23:	75 1a                	jne    800e3f <strtol+0x83>
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	83 c0 01             	add    $0x1,%eax
  800e2b:	0f b6 00             	movzbl (%eax),%eax
  800e2e:	3c 78                	cmp    $0x78,%al
  800e30:	75 0d                	jne    800e3f <strtol+0x83>
		s += 2, base = 16;
  800e32:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800e36:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800e3d:	eb 2a                	jmp    800e69 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800e3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e43:	75 17                	jne    800e5c <strtol+0xa0>
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	0f b6 00             	movzbl (%eax),%eax
  800e4b:	3c 30                	cmp    $0x30,%al
  800e4d:	75 0d                	jne    800e5c <strtol+0xa0>
		s++, base = 8;
  800e4f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e53:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e5a:	eb 0d                	jmp    800e69 <strtol+0xad>
	else if (base == 0)
  800e5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e60:	75 07                	jne    800e69 <strtol+0xad>
		base = 10;
  800e62:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	0f b6 00             	movzbl (%eax),%eax
  800e6f:	3c 2f                	cmp    $0x2f,%al
  800e71:	7e 1b                	jle    800e8e <strtol+0xd2>
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	0f b6 00             	movzbl (%eax),%eax
  800e79:	3c 39                	cmp    $0x39,%al
  800e7b:	7f 11                	jg     800e8e <strtol+0xd2>
			dig = *s - '0';
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	0f b6 00             	movzbl (%eax),%eax
  800e83:	0f be c0             	movsbl %al,%eax
  800e86:	83 e8 30             	sub    $0x30,%eax
  800e89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e8c:	eb 48                	jmp    800ed6 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	0f b6 00             	movzbl (%eax),%eax
  800e94:	3c 60                	cmp    $0x60,%al
  800e96:	7e 1b                	jle    800eb3 <strtol+0xf7>
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	0f b6 00             	movzbl (%eax),%eax
  800e9e:	3c 7a                	cmp    $0x7a,%al
  800ea0:	7f 11                	jg     800eb3 <strtol+0xf7>
			dig = *s - 'a' + 10;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	0f b6 00             	movzbl (%eax),%eax
  800ea8:	0f be c0             	movsbl %al,%eax
  800eab:	83 e8 57             	sub    $0x57,%eax
  800eae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800eb1:	eb 23                	jmp    800ed6 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	0f b6 00             	movzbl (%eax),%eax
  800eb9:	3c 40                	cmp    $0x40,%al
  800ebb:	7e 3d                	jle    800efa <strtol+0x13e>
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	0f b6 00             	movzbl (%eax),%eax
  800ec3:	3c 5a                	cmp    $0x5a,%al
  800ec5:	7f 33                	jg     800efa <strtol+0x13e>
			dig = *s - 'A' + 10;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	0f b6 00             	movzbl (%eax),%eax
  800ecd:	0f be c0             	movsbl %al,%eax
  800ed0:	83 e8 37             	sub    $0x37,%eax
  800ed3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800edc:	7c 02                	jl     800ee0 <strtol+0x124>
			break;
  800ede:	eb 1a                	jmp    800efa <strtol+0x13e>
		s++, val = (val * base) + dig;
  800ee0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ee4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ee7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef0:	01 d0                	add    %edx,%eax
  800ef2:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ef5:	e9 6f ff ff ff       	jmp    800e69 <strtol+0xad>

	if (endptr)
  800efa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800efe:	74 08                	je     800f08 <strtol+0x14c>
		*endptr = (char *) s;
  800f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800f08:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800f0c:	74 07                	je     800f15 <strtol+0x159>
  800f0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f11:	f7 d8                	neg    %eax
  800f13:	eb 03                	jmp    800f18 <strtol+0x15c>
  800f15:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	8b 55 10             	mov    0x10(%ebp),%edx
  800f29:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800f2c:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800f2f:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800f32:	8b 75 20             	mov    0x20(%ebp),%esi
  800f35:	cd 30                	int    $0x30
  800f37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f3e:	74 30                	je     800f70 <syscall+0x56>
  800f40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f44:	7e 2a                	jle    800f70 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f54:	c7 44 24 08 64 1f 80 	movl   $0x801f64,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 81 1f 80 00 	movl   $0x801f81,(%esp)
  800f6b:	e8 4c 09 00 00       	call   8018bc <_panic>

	return ret;
  800f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f73:	83 c4 3c             	add    $0x3c,%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f93:	00 
  800f94:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f9b:	00 
  800f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fa3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fae:	00 
  800faf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fb6:	e8 5f ff ff ff       	call   800f1a <syscall>
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <sys_cgetc>:

int
sys_cgetc(void)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fc3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fca:	00 
  800fcb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd2:	00 
  800fd3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fda:	00 
  800fdb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fea:	00 
  800feb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff2:	00 
  800ff3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ffa:	e8 1b ff ff ff       	call   800f1a <syscall>
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801007:	8b 45 08             	mov    0x8(%ebp),%eax
  80100a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801011:	00 
  801012:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801019:	00 
  80101a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801021:	00 
  801022:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801029:	00 
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  80103d:	e8 d8 fe ff ff       	call   800f1a <syscall>
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80104a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801051:	00 
  801052:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801059:	00 
  80105a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801061:	00 
  801062:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801069:	00 
  80106a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801071:	00 
  801072:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801079:	00 
  80107a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801081:	e8 94 fe ff ff       	call   800f1a <syscall>
}
  801086:	c9                   	leave  
  801087:	c3                   	ret    

00801088 <sys_yield>:

void
sys_yield(void)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80108e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801095:	00 
  801096:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80109d:	00 
  80109e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8010c5:	e8 50 fe ff ff       	call   800f1a <syscall>
}
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010ea:	00 
  8010eb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010fe:	00 
  8010ff:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801106:	e8 0f fe ff ff       	call   800f1a <syscall>
}
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	56                   	push   %esi
  801111:	53                   	push   %ebx
  801112:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801115:	8b 75 18             	mov    0x18(%ebp),%esi
  801118:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80111b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80111e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	89 74 24 18          	mov    %esi,0x18(%esp)
  801128:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80112c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801130:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801134:	89 44 24 08          	mov    %eax,0x8(%esp)
  801138:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801147:	e8 ce fd ff ff       	call   800f1a <syscall>
}
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  801187:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80118e:	e8 87 fd ff ff       	call   800f1a <syscall>
}
  801193:	c9                   	leave  
  801194:	c3                   	ret    

00801195 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80119b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119e:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011b8:	00 
  8011b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8011d0:	e8 45 fd ff ff       	call   800f1a <syscall>
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011fa:	00 
  8011fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801203:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80120a:	00 
  80120b:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  801212:	e8 03 fd ff ff       	call   800f1a <syscall>
}
  801217:	c9                   	leave  
  801218:	c3                   	ret    

00801219 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80121f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801222:	8b 55 10             	mov    0x10(%ebp),%edx
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80122f:	00 
  801230:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801234:	89 54 24 10          	mov    %edx,0x10(%esp)
  801238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80123f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801243:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80124a:	00 
  80124b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  801252:	e8 c3 fc ff ff       	call   800f1a <syscall>
}
  801257:	c9                   	leave  
  801258:	c3                   	ret    

00801259 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80125f:	8b 45 08             	mov    0x8(%ebp),%eax
  801262:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801269:	00 
  80126a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801271:	00 
  801272:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801279:	00 
  80127a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801281:	00 
  801282:	89 44 24 08          	mov    %eax,0x8(%esp)
  801286:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80128d:	00 
  80128e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801295:	e8 80 fc ff ff       	call   800f1a <syscall>
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a5:	8b 00                	mov    (%eax),%eax
  8012a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  8012aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ad:	8b 40 04             	mov    0x4(%eax),%eax
  8012b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  8012b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b6:	83 e0 02             	and    $0x2,%eax
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	75 23                	jne    8012e0 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8012bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c4:	c7 44 24 08 90 1f 80 	movl   $0x801f90,0x8(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8012d3:	00 
  8012d4:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  8012db:	e8 dc 05 00 00       	call   8018bc <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  8012e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
  8012e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8012e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8012ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f3:	25 00 08 00 00       	and    $0x800,%eax
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	75 1c                	jne    801318 <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8012fc:	c7 44 24 08 cc 1f 80 	movl   $0x801fcc,0x8(%esp)
  801303:	00 
  801304:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80130b:	00 
  80130c:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  801313:	e8 a4 05 00 00       	call   8018bc <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  801318:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80131f:	00 
  801320:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801327:	00 
  801328:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80132f:	e8 98 fd ff ff       	call   8010cc <sys_page_alloc>
  801334:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801337:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80133b:	79 23                	jns    801360 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  80133d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801344:	c7 44 24 08 08 20 80 	movl   $0x802008,0x8(%esp)
  80134b:	00 
  80134c:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801353:	00 
  801354:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  80135b:	e8 5c 05 00 00       	call   8018bc <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801366:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801369:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80136e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801375:	00 
  801376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137a:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801381:	e8 8a f9 ff ff       	call   800d10 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801386:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801389:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801394:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80139b:	00 
  80139c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013a7:	00 
  8013a8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013af:	00 
  8013b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b7:	e8 51 fd ff ff       	call   80110d <sys_page_map>
  8013bc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8013bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013c3:	79 23                	jns    8013e8 <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8013c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013cc:	c7 44 24 08 40 20 80 	movl   $0x802040,0x8(%esp)
  8013d3:	00 
  8013d4:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  8013db:	00 
  8013dc:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  8013e3:	e8 d4 04 00 00       	call   8018bc <_panic>
	}

	// panic("pgfault not implemented");
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8013f2:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801403:	25 00 08 00 00       	and    $0x800,%eax
  801408:	85 c0                	test   %eax,%eax
  80140a:	75 15                	jne    801421 <duppage+0x37>
  80140c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801416:	83 e0 02             	and    $0x2,%eax
  801419:	85 c0                	test   %eax,%eax
  80141b:	0f 84 e0 00 00 00    	je     801501 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  801421:	8b 45 0c             	mov    0xc(%ebp),%eax
  801424:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142b:	83 e0 04             	and    $0x4,%eax
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 04                	je     801436 <duppage+0x4c>
  801432:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  801436:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801439:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143c:	c1 e0 0c             	shl    $0xc,%eax
  80143f:	89 c1                	mov    %eax,%ecx
  801441:	8b 45 0c             	mov    0xc(%ebp),%eax
  801444:	c1 e0 0c             	shl    $0xc,%eax
  801447:	89 c2                	mov    %eax,%edx
  801449:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80144e:	8b 40 48             	mov    0x48(%eax),%eax
  801451:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801455:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801460:	89 54 24 04          	mov    %edx,0x4(%esp)
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 a1 fc ff ff       	call   80110d <sys_page_map>
  80146c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80146f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801473:	79 23                	jns    801498 <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  801475:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801478:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147c:	c7 44 24 08 74 20 80 	movl   $0x802074,0x8(%esp)
  801483:	00 
  801484:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80148b:	00 
  80148c:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  801493:	e8 24 04 00 00       	call   8018bc <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801498:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80149b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149e:	c1 e0 0c             	shl    $0xc,%eax
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8014a8:	8b 48 48             	mov    0x48(%eax),%ecx
  8014ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ae:	c1 e0 0c             	shl    $0xc,%eax
  8014b1:	89 c2                	mov    %eax,%edx
  8014b3:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8014b8:	8b 40 48             	mov    0x48(%eax),%eax
  8014bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8014bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014cb:	89 04 24             	mov    %eax,(%esp)
  8014ce:	e8 3a fc ff ff       	call   80110d <sys_page_map>
  8014d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014da:	79 23                	jns    8014ff <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  8014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e3:	c7 44 24 08 b0 20 80 	movl   $0x8020b0,0x8(%esp)
  8014ea:	00 
  8014eb:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8014f2:	00 
  8014f3:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  8014fa:	e8 bd 03 00 00       	call   8018bc <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8014ff:	eb 70                	jmp    801571 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150b:	25 ff 0f 00 00       	and    $0xfff,%eax
  801510:	89 c3                	mov    %eax,%ebx
  801512:	8b 45 0c             	mov    0xc(%ebp),%eax
  801515:	c1 e0 0c             	shl    $0xc,%eax
  801518:	89 c1                	mov    %eax,%ecx
  80151a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151d:	c1 e0 0c             	shl    $0xc,%eax
  801520:	89 c2                	mov    %eax,%edx
  801522:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801527:	8b 40 48             	mov    0x48(%eax),%eax
  80152a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80152e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801532:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801535:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801539:	89 54 24 04          	mov    %edx,0x4(%esp)
  80153d:	89 04 24             	mov    %eax,(%esp)
  801540:	e8 c8 fb ff ff       	call   80110d <sys_page_map>
  801545:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801548:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80154c:	79 23                	jns    801571 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  80154e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801551:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801555:	c7 44 24 08 e0 20 80 	movl   $0x8020e0,0x8(%esp)
  80155c:	00 
  80155d:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  801564:	00 
  801565:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  80156c:	e8 4b 03 00 00       	call   8018bc <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801576:	83 c4 30             	add    $0x30,%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    

0080157d <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801583:	c7 04 24 9c 12 80 00 	movl   $0x80129c,(%esp)
  80158a:	e8 88 03 00 00       	call   801917 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80158f:	b8 07 00 00 00       	mov    $0x7,%eax
  801594:	cd 30                	int    $0x30
  801596:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  801599:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80159c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  80159f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015a3:	79 23                	jns    8015c8 <fork+0x4b>
  8015a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015ac:	c7 44 24 08 18 21 80 	movl   $0x802118,0x8(%esp)
  8015b3:	00 
  8015b4:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8015bb:	00 
  8015bc:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  8015c3:	e8 f4 02 00 00       	call   8018bc <_panic>
	else if(childeid == 0){
  8015c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015cc:	75 29                	jne    8015f7 <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8015ce:	e8 71 fa ff ff       	call   801044 <sys_getenvid>
  8015d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015d8:	c1 e0 02             	shl    $0x2,%eax
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	c1 e2 05             	shl    $0x5,%edx
  8015e0:	29 c2                	sub    %eax,%edx
  8015e2:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8015e8:	a3 0c 30 80 00       	mov    %eax,0x80300c
		// set_pgfault_handler(pgfault);
		return 0;
  8015ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f2:	e9 16 01 00 00       	jmp    80170d <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8015f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8015fe:	eb 3b                	jmp    80163b <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801603:	c1 f8 0a             	sar    $0xa,%eax
  801606:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80160d:	83 e0 01             	and    $0x1,%eax
  801610:	85 c0                	test   %eax,%eax
  801612:	74 23                	je     801637 <fork+0xba>
  801614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801617:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80161e:	83 e0 01             	and    $0x1,%eax
  801621:	85 c0                	test   %eax,%eax
  801623:	74 12                	je     801637 <fork+0xba>
			duppage(childeid, i);
  801625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	89 04 24             	mov    %eax,(%esp)
  801632:	e8 b3 fd ff ff       	call   8013ea <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  801637:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80163b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163e:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  801643:	76 bb                	jbe    801600 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  801645:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80164c:	00 
  80164d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801654:	ee 
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	89 04 24             	mov    %eax,(%esp)
  80165b:	e8 6c fa ff ff       	call   8010cc <sys_page_alloc>
  801660:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801663:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801667:	79 23                	jns    80168c <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  801669:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80166c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801670:	c7 44 24 08 40 21 80 	movl   $0x802140,0x8(%esp)
  801677:	00 
  801678:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  80167f:	00 
  801680:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  801687:	e8 30 02 00 00       	call   8018bc <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80168c:	c7 44 24 04 8d 19 80 	movl   $0x80198d,0x4(%esp)
  801693:	00 
  801694:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 38 fb ff ff       	call   8011d7 <sys_env_set_pgfault_upcall>
  80169f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016a6:	79 23                	jns    8016cb <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  8016a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016af:	c7 44 24 08 68 21 80 	movl   $0x802168,0x8(%esp)
  8016b6:	00 
  8016b7:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8016be:	00 
  8016bf:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  8016c6:	e8 f1 01 00 00       	call   8018bc <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  8016cb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016d2:	00 
  8016d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 b7 fa ff ff       	call   801195 <sys_env_set_status>
  8016de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016e1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016e5:	79 23                	jns    80170a <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8016e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016ee:	c7 44 24 08 9c 21 80 	movl   $0x80219c,0x8(%esp)
  8016f5:	00 
  8016f6:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8016fd:	00 
  8016fe:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  801705:	e8 b2 01 00 00       	call   8018bc <_panic>
	}
	return childeid;
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <sfork>:

// Challenge!
int
sfork(void)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801715:	c7 44 24 08 c5 21 80 	movl   $0x8021c5,0x8(%esp)
  80171c:	00 
  80171d:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  801724:	00 
  801725:	c7 04 24 c0 1f 80 00 	movl   $0x801fc0,(%esp)
  80172c:	e8 8b 01 00 00       	call   8018bc <_panic>

00801731 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  801737:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80173b:	75 09                	jne    801746 <ipc_recv+0x15>
		i_dstva = UTOP;
  80173d:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  801744:	eb 06                	jmp    80174c <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  801746:	8b 45 0c             	mov    0xc(%ebp),%eax
  801749:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	89 04 24             	mov    %eax,(%esp)
  801752:	e8 02 fb ff ff       	call   801259 <sys_ipc_recv>
  801757:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  80175a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80175e:	75 15                	jne    801775 <ipc_recv+0x44>
  801760:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801764:	74 0f                	je     801775 <ipc_recv+0x44>
  801766:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80176b:	8b 50 74             	mov    0x74(%eax),%edx
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	89 10                	mov    %edx,(%eax)
  801773:	eb 15                	jmp    80178a <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  801775:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801779:	79 0f                	jns    80178a <ipc_recv+0x59>
  80177b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80177f:	74 09                	je     80178a <ipc_recv+0x59>
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  80178a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80178e:	75 15                	jne    8017a5 <ipc_recv+0x74>
  801790:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801794:	74 0f                	je     8017a5 <ipc_recv+0x74>
  801796:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80179b:	8b 50 78             	mov    0x78(%eax),%edx
  80179e:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a1:	89 10                	mov    %edx,(%eax)
  8017a3:	eb 15                	jmp    8017ba <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  8017a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017a9:	79 0f                	jns    8017ba <ipc_recv+0x89>
  8017ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017af:	74 09                	je     8017ba <ipc_recv+0x89>
  8017b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  8017ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8017be:	75 0a                	jne    8017ca <ipc_recv+0x99>
  8017c0:	a1 0c 30 80 00       	mov    0x80300c,%eax
  8017c5:	8b 40 70             	mov    0x70(%eax),%eax
  8017c8:	eb 03                	jmp    8017cd <ipc_recv+0x9c>
	else return r;
  8017ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  8017d5:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  8017dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017e0:	74 06                	je     8017e8 <ipc_send+0x19>
  8017e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8017e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017eb:	8b 55 14             	mov    0x14(%ebp),%edx
  8017ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	e8 11 fa ff ff       	call   801219 <sys_ipc_try_send>
  801808:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  80180b:	eb 28                	jmp    801835 <ipc_send+0x66>
		sys_yield();
  80180d:	e8 76 f8 ff ff       	call   801088 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801815:	8b 55 14             	mov    0x14(%ebp),%edx
  801818:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80181c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801820:	8b 45 0c             	mov    0xc(%ebp),%eax
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	89 04 24             	mov    %eax,(%esp)
  80182d:	e8 e7 f9 ff ff       	call   801219 <sys_ipc_try_send>
  801832:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  801835:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  801839:	74 d2                	je     80180d <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  80183b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80183f:	75 02                	jne    801843 <ipc_send+0x74>
  801841:	eb 23                	jmp    801866 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  801843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801846:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184a:	c7 44 24 08 dc 21 80 	movl   $0x8021dc,0x8(%esp)
  801851:	00 
  801852:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801859:	00 
  80185a:	c7 04 24 01 22 80 00 	movl   $0x802201,(%esp)
  801861:	e8 56 00 00 00       	call   8018bc <_panic>
	panic("ipc_send not implemented");
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  80186e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801875:	eb 35                	jmp    8018ac <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801877:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80187a:	c1 e0 02             	shl    $0x2,%eax
  80187d:	89 c2                	mov    %eax,%edx
  80187f:	c1 e2 05             	shl    $0x5,%edx
  801882:	29 c2                	sub    %eax,%edx
  801884:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  80188a:	8b 00                	mov    (%eax),%eax
  80188c:	3b 45 08             	cmp    0x8(%ebp),%eax
  80188f:	75 17                	jne    8018a8 <ipc_find_env+0x40>
			return envs[i].env_id;
  801891:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801894:	c1 e0 02             	shl    $0x2,%eax
  801897:	89 c2                	mov    %eax,%edx
  801899:	c1 e2 05             	shl    $0x5,%edx
  80189c:	29 c2                	sub    %eax,%edx
  80189e:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8018a4:	8b 00                	mov    (%eax),%eax
  8018a6:	eb 12                	jmp    8018ba <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8018a8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8018ac:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8018b3:	7e c2                	jle    801877 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8018b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8018c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c6:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018c9:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  8018cf:	e8 70 f7 ff ff       	call   801044 <sys_getenvid>
  8018d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018db:	8b 55 08             	mov    0x8(%ebp),%edx
  8018de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	c7 04 24 0c 22 80 00 	movl   $0x80220c,(%esp)
  8018f1:	e8 19 ea ff ff       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	e8 a3 e9 ff ff       	call   8002ab <vcprintf>
	cprintf("\n");
  801908:	c7 04 24 2f 22 80 00 	movl   $0x80222f,(%esp)
  80190f:	e8 fb e9 ff ff       	call   80030f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801914:	cc                   	int3   
  801915:	eb fd                	jmp    801914 <_panic+0x58>

00801917 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80191d:	a1 10 30 80 00       	mov    0x803010,%eax
  801922:	85 c0                	test   %eax,%eax
  801924:	75 5d                	jne    801983 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801926:	a1 0c 30 80 00       	mov    0x80300c,%eax
  80192b:	8b 40 48             	mov    0x48(%eax),%eax
  80192e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801935:	00 
  801936:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80193d:	ee 
  80193e:	89 04 24             	mov    %eax,(%esp)
  801941:	e8 86 f7 ff ff       	call   8010cc <sys_page_alloc>
  801946:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801949:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80194d:	79 1c                	jns    80196b <set_pgfault_handler+0x54>
  80194f:	c7 44 24 08 34 22 80 	movl   $0x802234,0x8(%esp)
  801956:	00 
  801957:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80195e:	00 
  80195f:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  801966:	e8 51 ff ff ff       	call   8018bc <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80196b:	a1 0c 30 80 00       	mov    0x80300c,%eax
  801970:	8b 40 48             	mov    0x48(%eax),%eax
  801973:	c7 44 24 04 8d 19 80 	movl   $0x80198d,0x4(%esp)
  80197a:	00 
  80197b:	89 04 24             	mov    %eax,(%esp)
  80197e:	e8 54 f8 ff ff       	call   8011d7 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	a3 10 30 80 00       	mov    %eax,0x803010
}
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80198d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80198e:	a1 10 30 80 00       	mov    0x803010,%eax
	call *%eax
  801993:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801995:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  801998:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  80199c:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80199e:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8019a2:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8019a3:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8019a6:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8019a8:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8019a9:	58                   	pop    %eax
	popal 						// pop all the registers
  8019aa:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8019ab:	83 c4 04             	add    $0x4,%esp
	popfl
  8019ae:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8019af:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8019b0:	c3                   	ret    
  8019b1:	66 90                	xchg   %ax,%ax
  8019b3:	66 90                	xchg   %ax,%ax
  8019b5:	66 90                	xchg   %ax,%ax
  8019b7:	66 90                	xchg   %ax,%ax
  8019b9:	66 90                	xchg   %ax,%ax
  8019bb:	66 90                	xchg   %ax,%ax
  8019bd:	66 90                	xchg   %ax,%ax
  8019bf:	90                   	nop

008019c0 <__udivdi3>:
  8019c0:	55                   	push   %ebp
  8019c1:	57                   	push   %edi
  8019c2:	56                   	push   %esi
  8019c3:	83 ec 0c             	sub    $0xc,%esp
  8019c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8019ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8019d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019dc:	89 ea                	mov    %ebp,%edx
  8019de:	89 0c 24             	mov    %ecx,(%esp)
  8019e1:	75 2d                	jne    801a10 <__udivdi3+0x50>
  8019e3:	39 e9                	cmp    %ebp,%ecx
  8019e5:	77 61                	ja     801a48 <__udivdi3+0x88>
  8019e7:	85 c9                	test   %ecx,%ecx
  8019e9:	89 ce                	mov    %ecx,%esi
  8019eb:	75 0b                	jne    8019f8 <__udivdi3+0x38>
  8019ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f2:	31 d2                	xor    %edx,%edx
  8019f4:	f7 f1                	div    %ecx
  8019f6:	89 c6                	mov    %eax,%esi
  8019f8:	31 d2                	xor    %edx,%edx
  8019fa:	89 e8                	mov    %ebp,%eax
  8019fc:	f7 f6                	div    %esi
  8019fe:	89 c5                	mov    %eax,%ebp
  801a00:	89 f8                	mov    %edi,%eax
  801a02:	f7 f6                	div    %esi
  801a04:	89 ea                	mov    %ebp,%edx
  801a06:	83 c4 0c             	add    $0xc,%esp
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    
  801a0d:	8d 76 00             	lea    0x0(%esi),%esi
  801a10:	39 e8                	cmp    %ebp,%eax
  801a12:	77 24                	ja     801a38 <__udivdi3+0x78>
  801a14:	0f bd e8             	bsr    %eax,%ebp
  801a17:	83 f5 1f             	xor    $0x1f,%ebp
  801a1a:	75 3c                	jne    801a58 <__udivdi3+0x98>
  801a1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801a20:	39 34 24             	cmp    %esi,(%esp)
  801a23:	0f 86 9f 00 00 00    	jbe    801ac8 <__udivdi3+0x108>
  801a29:	39 d0                	cmp    %edx,%eax
  801a2b:	0f 82 97 00 00 00    	jb     801ac8 <__udivdi3+0x108>
  801a31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801a38:	31 d2                	xor    %edx,%edx
  801a3a:	31 c0                	xor    %eax,%eax
  801a3c:	83 c4 0c             	add    $0xc,%esp
  801a3f:	5e                   	pop    %esi
  801a40:	5f                   	pop    %edi
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    
  801a43:	90                   	nop
  801a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a48:	89 f8                	mov    %edi,%eax
  801a4a:	f7 f1                	div    %ecx
  801a4c:	31 d2                	xor    %edx,%edx
  801a4e:	83 c4 0c             	add    $0xc,%esp
  801a51:	5e                   	pop    %esi
  801a52:	5f                   	pop    %edi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    
  801a55:	8d 76 00             	lea    0x0(%esi),%esi
  801a58:	89 e9                	mov    %ebp,%ecx
  801a5a:	8b 3c 24             	mov    (%esp),%edi
  801a5d:	d3 e0                	shl    %cl,%eax
  801a5f:	89 c6                	mov    %eax,%esi
  801a61:	b8 20 00 00 00       	mov    $0x20,%eax
  801a66:	29 e8                	sub    %ebp,%eax
  801a68:	89 c1                	mov    %eax,%ecx
  801a6a:	d3 ef                	shr    %cl,%edi
  801a6c:	89 e9                	mov    %ebp,%ecx
  801a6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a72:	8b 3c 24             	mov    (%esp),%edi
  801a75:	09 74 24 08          	or     %esi,0x8(%esp)
  801a79:	89 d6                	mov    %edx,%esi
  801a7b:	d3 e7                	shl    %cl,%edi
  801a7d:	89 c1                	mov    %eax,%ecx
  801a7f:	89 3c 24             	mov    %edi,(%esp)
  801a82:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a86:	d3 ee                	shr    %cl,%esi
  801a88:	89 e9                	mov    %ebp,%ecx
  801a8a:	d3 e2                	shl    %cl,%edx
  801a8c:	89 c1                	mov    %eax,%ecx
  801a8e:	d3 ef                	shr    %cl,%edi
  801a90:	09 d7                	or     %edx,%edi
  801a92:	89 f2                	mov    %esi,%edx
  801a94:	89 f8                	mov    %edi,%eax
  801a96:	f7 74 24 08          	divl   0x8(%esp)
  801a9a:	89 d6                	mov    %edx,%esi
  801a9c:	89 c7                	mov    %eax,%edi
  801a9e:	f7 24 24             	mull   (%esp)
  801aa1:	39 d6                	cmp    %edx,%esi
  801aa3:	89 14 24             	mov    %edx,(%esp)
  801aa6:	72 30                	jb     801ad8 <__udivdi3+0x118>
  801aa8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801aac:	89 e9                	mov    %ebp,%ecx
  801aae:	d3 e2                	shl    %cl,%edx
  801ab0:	39 c2                	cmp    %eax,%edx
  801ab2:	73 05                	jae    801ab9 <__udivdi3+0xf9>
  801ab4:	3b 34 24             	cmp    (%esp),%esi
  801ab7:	74 1f                	je     801ad8 <__udivdi3+0x118>
  801ab9:	89 f8                	mov    %edi,%eax
  801abb:	31 d2                	xor    %edx,%edx
  801abd:	e9 7a ff ff ff       	jmp    801a3c <__udivdi3+0x7c>
  801ac2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ac8:	31 d2                	xor    %edx,%edx
  801aca:	b8 01 00 00 00       	mov    $0x1,%eax
  801acf:	e9 68 ff ff ff       	jmp    801a3c <__udivdi3+0x7c>
  801ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad8:	8d 47 ff             	lea    -0x1(%edi),%eax
  801adb:	31 d2                	xor    %edx,%edx
  801add:	83 c4 0c             	add    $0xc,%esp
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    
  801ae4:	66 90                	xchg   %ax,%ax
  801ae6:	66 90                	xchg   %ax,%ax
  801ae8:	66 90                	xchg   %ax,%ax
  801aea:	66 90                	xchg   %ax,%ax
  801aec:	66 90                	xchg   %ax,%ax
  801aee:	66 90                	xchg   %ax,%ax

00801af0 <__umoddi3>:
  801af0:	55                   	push   %ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	83 ec 14             	sub    $0x14,%esp
  801af6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801afa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801afe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801b02:	89 c7                	mov    %eax,%edi
  801b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b08:	8b 44 24 30          	mov    0x30(%esp),%eax
  801b0c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801b10:	89 34 24             	mov    %esi,(%esp)
  801b13:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b17:	85 c0                	test   %eax,%eax
  801b19:	89 c2                	mov    %eax,%edx
  801b1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b1f:	75 17                	jne    801b38 <__umoddi3+0x48>
  801b21:	39 fe                	cmp    %edi,%esi
  801b23:	76 4b                	jbe    801b70 <__umoddi3+0x80>
  801b25:	89 c8                	mov    %ecx,%eax
  801b27:	89 fa                	mov    %edi,%edx
  801b29:	f7 f6                	div    %esi
  801b2b:	89 d0                	mov    %edx,%eax
  801b2d:	31 d2                	xor    %edx,%edx
  801b2f:	83 c4 14             	add    $0x14,%esp
  801b32:	5e                   	pop    %esi
  801b33:	5f                   	pop    %edi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	39 f8                	cmp    %edi,%eax
  801b3a:	77 54                	ja     801b90 <__umoddi3+0xa0>
  801b3c:	0f bd e8             	bsr    %eax,%ebp
  801b3f:	83 f5 1f             	xor    $0x1f,%ebp
  801b42:	75 5c                	jne    801ba0 <__umoddi3+0xb0>
  801b44:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801b48:	39 3c 24             	cmp    %edi,(%esp)
  801b4b:	0f 87 e7 00 00 00    	ja     801c38 <__umoddi3+0x148>
  801b51:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801b55:	29 f1                	sub    %esi,%ecx
  801b57:	19 c7                	sbb    %eax,%edi
  801b59:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b5d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b61:	8b 44 24 08          	mov    0x8(%esp),%eax
  801b65:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801b69:	83 c4 14             	add    $0x14,%esp
  801b6c:	5e                   	pop    %esi
  801b6d:	5f                   	pop    %edi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    
  801b70:	85 f6                	test   %esi,%esi
  801b72:	89 f5                	mov    %esi,%ebp
  801b74:	75 0b                	jne    801b81 <__umoddi3+0x91>
  801b76:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7b:	31 d2                	xor    %edx,%edx
  801b7d:	f7 f6                	div    %esi
  801b7f:	89 c5                	mov    %eax,%ebp
  801b81:	8b 44 24 04          	mov    0x4(%esp),%eax
  801b85:	31 d2                	xor    %edx,%edx
  801b87:	f7 f5                	div    %ebp
  801b89:	89 c8                	mov    %ecx,%eax
  801b8b:	f7 f5                	div    %ebp
  801b8d:	eb 9c                	jmp    801b2b <__umoddi3+0x3b>
  801b8f:	90                   	nop
  801b90:	89 c8                	mov    %ecx,%eax
  801b92:	89 fa                	mov    %edi,%edx
  801b94:	83 c4 14             	add    $0x14,%esp
  801b97:	5e                   	pop    %esi
  801b98:	5f                   	pop    %edi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    
  801b9b:	90                   	nop
  801b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	8b 04 24             	mov    (%esp),%eax
  801ba3:	be 20 00 00 00       	mov    $0x20,%esi
  801ba8:	89 e9                	mov    %ebp,%ecx
  801baa:	29 ee                	sub    %ebp,%esi
  801bac:	d3 e2                	shl    %cl,%edx
  801bae:	89 f1                	mov    %esi,%ecx
  801bb0:	d3 e8                	shr    %cl,%eax
  801bb2:	89 e9                	mov    %ebp,%ecx
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	8b 04 24             	mov    (%esp),%eax
  801bbb:	09 54 24 04          	or     %edx,0x4(%esp)
  801bbf:	89 fa                	mov    %edi,%edx
  801bc1:	d3 e0                	shl    %cl,%eax
  801bc3:	89 f1                	mov    %esi,%ecx
  801bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801bcd:	d3 ea                	shr    %cl,%edx
  801bcf:	89 e9                	mov    %ebp,%ecx
  801bd1:	d3 e7                	shl    %cl,%edi
  801bd3:	89 f1                	mov    %esi,%ecx
  801bd5:	d3 e8                	shr    %cl,%eax
  801bd7:	89 e9                	mov    %ebp,%ecx
  801bd9:	09 f8                	or     %edi,%eax
  801bdb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801bdf:	f7 74 24 04          	divl   0x4(%esp)
  801be3:	d3 e7                	shl    %cl,%edi
  801be5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801be9:	89 d7                	mov    %edx,%edi
  801beb:	f7 64 24 08          	mull   0x8(%esp)
  801bef:	39 d7                	cmp    %edx,%edi
  801bf1:	89 c1                	mov    %eax,%ecx
  801bf3:	89 14 24             	mov    %edx,(%esp)
  801bf6:	72 2c                	jb     801c24 <__umoddi3+0x134>
  801bf8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801bfc:	72 22                	jb     801c20 <__umoddi3+0x130>
  801bfe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801c02:	29 c8                	sub    %ecx,%eax
  801c04:	19 d7                	sbb    %edx,%edi
  801c06:	89 e9                	mov    %ebp,%ecx
  801c08:	89 fa                	mov    %edi,%edx
  801c0a:	d3 e8                	shr    %cl,%eax
  801c0c:	89 f1                	mov    %esi,%ecx
  801c0e:	d3 e2                	shl    %cl,%edx
  801c10:	89 e9                	mov    %ebp,%ecx
  801c12:	d3 ef                	shr    %cl,%edi
  801c14:	09 d0                	or     %edx,%eax
  801c16:	89 fa                	mov    %edi,%edx
  801c18:	83 c4 14             	add    $0x14,%esp
  801c1b:	5e                   	pop    %esi
  801c1c:	5f                   	pop    %edi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    
  801c1f:	90                   	nop
  801c20:	39 d7                	cmp    %edx,%edi
  801c22:	75 da                	jne    801bfe <__umoddi3+0x10e>
  801c24:	8b 14 24             	mov    (%esp),%edx
  801c27:	89 c1                	mov    %eax,%ecx
  801c29:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801c2d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801c31:	eb cb                	jmp    801bfe <__umoddi3+0x10e>
  801c33:	90                   	nop
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801c3c:	0f 82 0f ff ff ff    	jb     801b51 <__umoddi3+0x61>
  801c42:	e9 1a ff ff ff       	jmp    801b61 <__umoddi3+0x71>
