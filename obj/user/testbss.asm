
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 fa 00 00 00       	call   80012b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 40 15 80 00 	movl   $0x801540,(%esp)
  800040:	e8 54 02 00 00       	call   800299 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800045:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80004c:	eb 35                	jmp    800083 <umain+0x50>
		if (bigarray[i] != 0)
  80004e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800051:	8b 04 85 20 20 80 00 	mov    0x802020(,%eax,4),%eax
  800058:	85 c0                	test   %eax,%eax
  80005a:	74 23                	je     80007f <umain+0x4c>
			panic("bigarray[%d] isn't cleared!\n", i);
  80005c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80005f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800063:	c7 44 24 08 60 15 80 	movl   $0x801560,0x8(%esp)
  80006a:	00 
  80006b:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 7d 15 80 00 	movl   $0x80157d,(%esp)
  80007a:	e8 ff 00 00 00       	call   80017e <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80007f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800083:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  80008a:	7e c2                	jle    80004e <umain+0x1b>
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800093:	eb 11                	jmp    8000a6 <umain+0x73>
		bigarray[i] = i;
  800095:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80009b:	89 14 85 20 20 80 00 	mov    %edx,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  8000a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000a6:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  8000ad:	7e e6                	jle    800095 <umain+0x62>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8000b6:	eb 38                	jmp    8000f0 <umain+0xbd>
		if (bigarray[i] != i)
  8000b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000bb:	8b 14 85 20 20 80 00 	mov    0x802020(,%eax,4),%edx
  8000c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c5:	39 c2                	cmp    %eax,%edx
  8000c7:	74 23                	je     8000ec <umain+0xb9>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d0:	c7 44 24 08 8c 15 80 	movl   $0x80158c,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 7d 15 80 00 	movl   $0x80157d,(%esp)
  8000e7:	e8 92 00 00 00       	call   80017e <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8000f0:	81 7d f4 ff ff 0f 00 	cmpl   $0xfffff,-0xc(%ebp)
  8000f7:	7e bf                	jle    8000b8 <umain+0x85>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000f9:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  800100:	e8 94 01 00 00       	call   800299 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  800105:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  80010c:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  80010f:	c7 44 24 08 e7 15 80 	movl   $0x8015e7,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 7d 15 80 00 	movl   $0x80157d,(%esp)
  800126:	e8 53 00 00 00       	call   80017e <_panic>

0080012b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800131:	e8 98 0e 00 00       	call   800fce <sys_getenvid>
  800136:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013b:	c1 e0 02             	shl    $0x2,%eax
  80013e:	89 c2                	mov    %eax,%edx
  800140:	c1 e2 05             	shl    $0x5,%edx
  800143:	29 c2                	sub    %eax,%edx
  800145:	89 d0                	mov    %edx,%eax
  800147:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014c:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800151:	8b 45 0c             	mov    0xc(%ebp),%eax
  800154:	89 44 24 04          	mov    %eax,0x4(%esp)
  800158:	8b 45 08             	mov    0x8(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 d0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800163:	e8 02 00 00 00       	call   80016a <exit>
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800177:	e8 0f 0e 00 00       	call   800f8b <sys_env_destroy>
}
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	53                   	push   %ebx
  800182:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800185:	8d 45 14             	lea    0x14(%ebp),%eax
  800188:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800191:	e8 38 0e 00 00       	call   800fce <sys_getenvid>
  800196:	8b 55 0c             	mov    0xc(%ebp),%edx
  800199:	89 54 24 10          	mov    %edx,0x10(%esp)
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ac:	c7 04 24 08 16 80 00 	movl   $0x801608,(%esp)
  8001b3:	e8 e1 00 00 00       	call   800299 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 6b 00 00 00       	call   800235 <vcprintf>
	cprintf("\n");
  8001ca:	c7 04 24 2b 16 80 00 	movl   $0x80162b,(%esp)
  8001d1:	e8 c3 00 00 00       	call   800299 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x58>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8001df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e2:	8b 00                	mov    (%eax),%eax
  8001e4:	8d 48 01             	lea    0x1(%eax),%ecx
  8001e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ea:	89 0a                	mov    %ecx,(%edx)
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	89 d1                	mov    %edx,%ecx
  8001f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f4:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	8b 00                	mov    (%eax),%eax
  8001fd:	3d ff 00 00 00       	cmp    $0xff,%eax
  800202:	75 20                	jne    800224 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	8b 00                	mov    (%eax),%eax
  800209:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020c:	83 c2 08             	add    $0x8,%edx
  80020f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800213:	89 14 24             	mov    %edx,(%esp)
  800216:	e8 ea 0c 00 00       	call   800f05 <sys_cputs>
		b->idx = 0;
  80021b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	8b 40 04             	mov    0x4(%eax),%eax
  80022a:	8d 50 01             	lea    0x1(%eax),%edx
  80022d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800230:	89 50 04             	mov    %edx,0x4(%eax)
}
  800233:	c9                   	leave  
  800234:	c3                   	ret    

00800235 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800245:	00 00 00 
	b.cnt = 0;
  800248:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800252:	8b 45 0c             	mov    0xc(%ebp),%eax
  800255:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800266:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026a:	c7 04 24 d9 01 80 00 	movl   $0x8001d9,(%esp)
  800271:	e8 bd 01 00 00       	call   800433 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800276:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800286:	83 c0 08             	add    $0x8,%eax
  800289:	89 04 24             	mov    %eax,(%esp)
  80028c:	e8 74 0c 00 00       	call   800f05 <sys_cputs>

	return b.cnt;
  800291:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029f:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8002a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	e8 7e ff ff ff       	call   800235 <vcprintf>
  8002b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8002ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 34             	sub    $0x34,%esp
  8002c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8002cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d2:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002dd:	77 72                	ja     800351 <printnum+0x92>
  8002df:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8002e2:	72 05                	jb     8002e9 <printnum+0x2a>
  8002e4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8002e7:	77 68                	ja     800351 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e9:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8002ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ef:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800302:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030c:	e8 9f 0f 00 00       	call   8012b0 <__udivdi3>
  800311:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800314:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800318:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80031c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80031f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800323:	89 44 24 08          	mov    %eax,0x8(%esp)
  800327:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80032b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	e8 82 ff ff ff       	call   8002bf <printnum>
  80033d:	eb 1c                	jmp    80035b <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800342:	89 44 24 04          	mov    %eax,0x4(%esp)
  800346:	8b 45 20             	mov    0x20(%ebp),%eax
  800349:	89 04 24             	mov    %eax,(%esp)
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800351:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800355:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800359:	7f e4                	jg     80033f <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80035e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800363:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800366:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800369:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80036d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	89 54 24 04          	mov    %edx,0x4(%esp)
  800378:	e8 63 10 00 00       	call   8013e0 <__umoddi3>
  80037d:	05 08 17 80 00       	add    $0x801708,%eax
  800382:	0f b6 00             	movzbl (%eax),%eax
  800385:	0f be c0             	movsbl %al,%eax
  800388:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	ff d0                	call   *%eax
}
  800397:	83 c4 34             	add    $0x34,%esp
  80039a:	5b                   	pop    %ebx
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003a4:	7e 14                	jle    8003ba <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	8d 48 08             	lea    0x8(%eax),%ecx
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 0a                	mov    %ecx,(%edx)
  8003b3:	8b 50 04             	mov    0x4(%eax),%edx
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	eb 30                	jmp    8003ea <getuint+0x4d>
	else if (lflag)
  8003ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8003be:	74 16                	je     8003d6 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 00                	mov    (%eax),%eax
  8003c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cb:	89 0a                	mov    %ecx,(%edx)
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d4:	eb 14                	jmp    8003ea <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8003d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	8d 48 04             	lea    0x4(%eax),%ecx
  8003de:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e1:	89 0a                	mov    %ecx,(%edx)
  8003e3:	8b 00                	mov    (%eax),%eax
  8003e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ef:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003f3:	7e 14                	jle    800409 <getint+0x1d>
		return va_arg(*ap, long long);
  8003f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	8d 48 08             	lea    0x8(%eax),%ecx
  8003fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800400:	89 0a                	mov    %ecx,(%edx)
  800402:	8b 50 04             	mov    0x4(%eax),%edx
  800405:	8b 00                	mov    (%eax),%eax
  800407:	eb 28                	jmp    800431 <getint+0x45>
	else if (lflag)
  800409:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80040d:	74 12                	je     800421 <getint+0x35>
		return va_arg(*ap, long);
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
  800412:	8b 00                	mov    (%eax),%eax
  800414:	8d 48 04             	lea    0x4(%eax),%ecx
  800417:	8b 55 08             	mov    0x8(%ebp),%edx
  80041a:	89 0a                	mov    %ecx,(%edx)
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	99                   	cltd   
  80041f:	eb 10                	jmp    800431 <getint+0x45>
	else
		return va_arg(*ap, int);
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	8b 00                	mov    (%eax),%eax
  800426:	8d 48 04             	lea    0x4(%eax),%ecx
  800429:	8b 55 08             	mov    0x8(%ebp),%edx
  80042c:	89 0a                	mov    %ecx,(%edx)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
}
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043b:	eb 18                	jmp    800455 <vprintfmt+0x22>
			if (ch == '\0')
  80043d:	85 db                	test   %ebx,%ebx
  80043f:	75 05                	jne    800446 <vprintfmt+0x13>
				return;
  800441:	e9 cc 03 00 00       	jmp    800812 <vprintfmt+0x3df>
			putch(ch, putdat);
  800446:	8b 45 0c             	mov    0xc(%ebp),%eax
  800449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044d:	89 1c 24             	mov    %ebx,(%esp)
  800450:	8b 45 08             	mov    0x8(%ebp),%eax
  800453:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800455:	8b 45 10             	mov    0x10(%ebp),%eax
  800458:	8d 50 01             	lea    0x1(%eax),%edx
  80045b:	89 55 10             	mov    %edx,0x10(%ebp)
  80045e:	0f b6 00             	movzbl (%eax),%eax
  800461:	0f b6 d8             	movzbl %al,%ebx
  800464:	83 fb 25             	cmp    $0x25,%ebx
  800467:	75 d4                	jne    80043d <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800469:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80046d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800474:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80047b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800482:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 45 10             	mov    0x10(%ebp),%eax
  80048c:	8d 50 01             	lea    0x1(%eax),%edx
  80048f:	89 55 10             	mov    %edx,0x10(%ebp)
  800492:	0f b6 00             	movzbl (%eax),%eax
  800495:	0f b6 d8             	movzbl %al,%ebx
  800498:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80049b:	83 f8 55             	cmp    $0x55,%eax
  80049e:	0f 87 3d 03 00 00    	ja     8007e1 <vprintfmt+0x3ae>
  8004a4:	8b 04 85 2c 17 80 00 	mov    0x80172c(,%eax,4),%eax
  8004ab:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8004ad:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8004b1:	eb d6                	jmp    800489 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8004b7:	eb d0                	jmp    800489 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8004c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c3:	89 d0                	mov    %edx,%eax
  8004c5:	c1 e0 02             	shl    $0x2,%eax
  8004c8:	01 d0                	add    %edx,%eax
  8004ca:	01 c0                	add    %eax,%eax
  8004cc:	01 d8                	add    %ebx,%eax
  8004ce:	83 e8 30             	sub    $0x30,%eax
  8004d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8004d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d7:	0f b6 00             	movzbl (%eax),%eax
  8004da:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8004dd:	83 fb 2f             	cmp    $0x2f,%ebx
  8004e0:	7e 0b                	jle    8004ed <vprintfmt+0xba>
  8004e2:	83 fb 39             	cmp    $0x39,%ebx
  8004e5:	7f 06                	jg     8004ed <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e7:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004eb:	eb d3                	jmp    8004c0 <vprintfmt+0x8d>
			goto process_precision;
  8004ed:	eb 33                	jmp    800522 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	8b 00                	mov    (%eax),%eax
  8004fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8004fd:	eb 23                	jmp    800522 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8004ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800503:	79 0c                	jns    800511 <vprintfmt+0xde>
				width = 0;
  800505:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80050c:	e9 78 ff ff ff       	jmp    800489 <vprintfmt+0x56>
  800511:	e9 73 ff ff ff       	jmp    800489 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800516:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80051d:	e9 67 ff ff ff       	jmp    800489 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800522:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800526:	79 12                	jns    80053a <vprintfmt+0x107>
				width = precision, precision = -1;
  800528:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800535:	e9 4f ff ff ff       	jmp    800489 <vprintfmt+0x56>
  80053a:	e9 4a ff ff ff       	jmp    800489 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800543:	e9 41 ff ff ff       	jmp    800489 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	8b 55 0c             	mov    0xc(%ebp),%edx
  800556:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	ff d0                	call   *%eax
			break;
  800562:	e9 a5 02 00 00       	jmp    80080c <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800572:	85 db                	test   %ebx,%ebx
  800574:	79 02                	jns    800578 <vprintfmt+0x145>
				err = -err;
  800576:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 fb 09             	cmp    $0x9,%ebx
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x155>
  80057d:	8b 34 9d e0 16 80 00 	mov    0x8016e0(,%ebx,4),%esi
  800584:	85 f6                	test   %esi,%esi
  800586:	75 23                	jne    8005ab <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800588:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80058c:	c7 44 24 08 19 17 80 	movl   $0x801719,0x8(%esp)
  800593:	00 
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059b:	8b 45 08             	mov    0x8(%ebp),%eax
  80059e:	89 04 24             	mov    %eax,(%esp)
  8005a1:	e8 73 02 00 00       	call   800819 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8005a6:	e9 61 02 00 00       	jmp    80080c <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8005af:	c7 44 24 08 22 17 80 	movl   $0x801722,0x8(%esp)
  8005b6:	00 
  8005b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	89 04 24             	mov    %eax,(%esp)
  8005c4:	e8 50 02 00 00       	call   800819 <printfmt>
			break;
  8005c9:	e9 3e 02 00 00       	jmp    80080c <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 04             	lea    0x4(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 30                	mov    (%eax),%esi
  8005d9:	85 f6                	test   %esi,%esi
  8005db:	75 05                	jne    8005e2 <vprintfmt+0x1af>
				p = "(null)";
  8005dd:	be 25 17 80 00       	mov    $0x801725,%esi
			if (width > 0 && padc != '-')
  8005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e6:	7e 37                	jle    80061f <vprintfmt+0x1ec>
  8005e8:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8005ec:	74 31                	je     80061f <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f5:	89 34 24             	mov    %esi,(%esp)
  8005f8:	e8 39 03 00 00       	call   800936 <strnlen>
  8005fd:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800600:	eb 17                	jmp    800619 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800602:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800606:	8b 55 0c             	mov    0xc(%ebp),%edx
  800609:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060d:	89 04 24             	mov    %eax,(%esp)
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800619:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061d:	7f e3                	jg     800602 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061f:	eb 38                	jmp    800659 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800621:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800625:	74 1f                	je     800646 <vprintfmt+0x213>
  800627:	83 fb 1f             	cmp    $0x1f,%ebx
  80062a:	7e 05                	jle    800631 <vprintfmt+0x1fe>
  80062c:	83 fb 7e             	cmp    $0x7e,%ebx
  80062f:	7e 15                	jle    800646 <vprintfmt+0x213>
					putch('?', putdat);
  800631:	8b 45 0c             	mov    0xc(%ebp),%eax
  800634:	89 44 24 04          	mov    %eax,0x4(%esp)
  800638:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80063f:	8b 45 08             	mov    0x8(%ebp),%eax
  800642:	ff d0                	call   *%eax
  800644:	eb 0f                	jmp    800655 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800646:	8b 45 0c             	mov    0xc(%ebp),%eax
  800649:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064d:	89 1c 24             	mov    %ebx,(%esp)
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800655:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800659:	89 f0                	mov    %esi,%eax
  80065b:	8d 70 01             	lea    0x1(%eax),%esi
  80065e:	0f b6 00             	movzbl (%eax),%eax
  800661:	0f be d8             	movsbl %al,%ebx
  800664:	85 db                	test   %ebx,%ebx
  800666:	74 10                	je     800678 <vprintfmt+0x245>
  800668:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066c:	78 b3                	js     800621 <vprintfmt+0x1ee>
  80066e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800672:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800676:	79 a9                	jns    800621 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800678:	eb 17                	jmp    800691 <vprintfmt+0x25e>
				putch(' ', putdat);
  80067a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800681:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800691:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800695:	7f e3                	jg     80067a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800697:	e9 70 01 00 00       	jmp    80080c <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80069f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	89 04 24             	mov    %eax,(%esp)
  8006a9:	e8 3e fd ff ff       	call   8003ec <getint>
  8006ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8006b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	79 26                	jns    8006e4 <vprintfmt+0x2b1>
				putch('-', putdat);
  8006be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	ff d0                	call   *%eax
				num = -(long long) num;
  8006d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d7:	f7 d8                	neg    %eax
  8006d9:	83 d2 00             	adc    $0x0,%edx
  8006dc:	f7 da                	neg    %edx
  8006de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8006e4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8006eb:	e9 a8 00 00 00       	jmp    800798 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	89 04 24             	mov    %eax,(%esp)
  8006fd:	e8 9b fc ff ff       	call   80039d <getuint>
  800702:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800705:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800708:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80070f:	e9 84 00 00 00       	jmp    800798 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800714:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	89 04 24             	mov    %eax,(%esp)
  800721:	e8 77 fc ff ff       	call   80039d <getuint>
  800726:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800729:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80072c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800733:	eb 63                	jmp    800798 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800735:	8b 45 0c             	mov    0xc(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	ff d0                	call   *%eax
			putch('x', putdat);
  800748:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800756:	8b 45 08             	mov    0x8(%ebp),%eax
  800759:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800766:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800769:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800770:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800777:	eb 1f                	jmp    800798 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800779:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80077c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  800783:	89 04 24             	mov    %eax,(%esp)
  800786:	e8 12 fc ff ff       	call   80039d <getuint>
  80078b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80078e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800791:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800798:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80079c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079f:	89 54 24 18          	mov    %edx,0x18(%esp)
  8007a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a6:	89 54 24 14          	mov    %edx,0x14(%esp)
  8007aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	89 04 24             	mov    %eax,(%esp)
  8007c9:	e8 f1 fa ff ff       	call   8002bf <printnum>
			break;
  8007ce:	eb 3c                	jmp    80080c <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d7:	89 1c 24             	mov    %ebx,(%esp)
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	ff d0                	call   *%eax
			break;
  8007df:	eb 2b                	jmp    80080c <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007f8:	eb 04                	jmp    8007fe <vprintfmt+0x3cb>
  8007fa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8007fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800801:	83 e8 01             	sub    $0x1,%eax
  800804:	0f b6 00             	movzbl (%eax),%eax
  800807:	3c 25                	cmp    $0x25,%al
  800809:	75 ef                	jne    8007fa <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80080b:	90                   	nop
		}
	}
  80080c:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80080d:	e9 43 fc ff ff       	jmp    800455 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800812:	83 c4 40             	add    $0x40,%esp
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
  800822:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800828:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082c:	8b 45 10             	mov    0x10(%ebp),%eax
  80082f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800833:	8b 45 0c             	mov    0xc(%ebp),%eax
  800836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	e8 ee fb ff ff       	call   800433 <vprintfmt>
	va_end(ap);
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	8b 40 08             	mov    0x8(%eax),%eax
  800850:	8d 50 01             	lea    0x1(%eax),%edx
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800861:	8b 40 04             	mov    0x4(%eax),%eax
  800864:	39 c2                	cmp    %eax,%edx
  800866:	73 12                	jae    80087a <sprintputch+0x33>
		*b->buf++ = ch;
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	8d 48 01             	lea    0x1(%eax),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
  800873:	89 0a                	mov    %ecx,(%edx)
  800875:	8b 55 08             	mov    0x8(%ebp),%edx
  800878:	88 10                	mov    %dl,(%eax)
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088b:	8d 50 ff             	lea    -0x1(%eax),%edx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	01 d0                	add    %edx,%eax
  800893:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800896:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008a1:	74 06                	je     8008a9 <vsnprintf+0x2d>
  8008a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008a7:	7f 07                	jg     8008b0 <vsnprintf+0x34>
		return -E_INVAL;
  8008a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ae:	eb 2a                	jmp    8008da <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c5:	c7 04 24 47 08 80 00 	movl   $0x800847,(%esp)
  8008cc:	e8 62 fb ff ff       	call   800433 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8008e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	89 04 24             	mov    %eax,(%esp)
  800903:	e8 74 ff ff ff       	call   80087c <vsnprintf>
  800908:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80091d:	eb 08                	jmp    800927 <strlen+0x17>
		n++;
  80091f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800923:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	0f b6 00             	movzbl (%eax),%eax
  80092d:	84 c0                	test   %al,%al
  80092f:	75 ee                	jne    80091f <strlen+0xf>
		n++;
	return n;
  800931:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800943:	eb 0c                	jmp    800951 <strnlen+0x1b>
		n++;
  800945:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800949:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80094d:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800951:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800955:	74 0a                	je     800961 <strnlen+0x2b>
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	0f b6 00             	movzbl (%eax),%eax
  80095d:	84 c0                	test   %al,%al
  80095f:	75 e4                	jne    800945 <strnlen+0xf>
		n++;
	return n;
  800961:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800972:	90                   	nop
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8d 50 01             	lea    0x1(%eax),%edx
  800979:	89 55 08             	mov    %edx,0x8(%ebp)
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800982:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800985:	0f b6 12             	movzbl (%edx),%edx
  800988:	88 10                	mov    %dl,(%eax)
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	84 c0                	test   %al,%al
  80098f:	75 e2                	jne    800973 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800991:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	e8 69 ff ff ff       	call   800910 <strlen>
  8009a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	01 c2                	add    %eax,%edx
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b9:	89 14 24             	mov    %edx,(%esp)
  8009bc:	e8 a5 ff ff ff       	call   800966 <strcpy>
	return dst;
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009d9:	eb 23                	jmp    8009fe <strncpy+0x38>
		*dst++ = *src;
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8d 50 01             	lea    0x1(%eax),%edx
  8009e1:	89 55 08             	mov    %edx,0x8(%ebp)
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e7:	0f b6 12             	movzbl (%edx),%edx
  8009ea:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	0f b6 00             	movzbl (%eax),%eax
  8009f2:	84 c0                	test   %al,%al
  8009f4:	74 04                	je     8009fa <strncpy+0x34>
			src++;
  8009f6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8009fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a01:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a04:	72 d5                	jb     8009db <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a06:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a1b:	74 33                	je     800a50 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a1d:	eb 17                	jmp    800a36 <strlcpy+0x2b>
			*dst++ = *src++;
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8d 50 01             	lea    0x1(%eax),%edx
  800a25:	89 55 08             	mov    %edx,0x8(%ebp)
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a2e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a31:	0f b6 12             	movzbl (%edx),%edx
  800a34:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a36:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a3e:	74 0a                	je     800a4a <strlcpy+0x3f>
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	0f b6 00             	movzbl (%eax),%eax
  800a46:	84 c0                	test   %al,%al
  800a48:	75 d5                	jne    800a1f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a50:	8b 55 08             	mov    0x8(%ebp),%edx
  800a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a56:	29 c2                	sub    %eax,%edx
  800a58:	89 d0                	mov    %edx,%eax
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a5f:	eb 08                	jmp    800a69 <strcmp+0xd>
		p++, q++;
  800a61:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a65:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a69:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6c:	0f b6 00             	movzbl (%eax),%eax
  800a6f:	84 c0                	test   %al,%al
  800a71:	74 10                	je     800a83 <strcmp+0x27>
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	0f b6 10             	movzbl (%eax),%edx
  800a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7c:	0f b6 00             	movzbl (%eax),%eax
  800a7f:	38 c2                	cmp    %al,%dl
  800a81:	74 de                	je     800a61 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	0f b6 00             	movzbl (%eax),%eax
  800a89:	0f b6 d0             	movzbl %al,%edx
  800a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8f:	0f b6 00             	movzbl (%eax),%eax
  800a92:	0f b6 c0             	movzbl %al,%eax
  800a95:	29 c2                	sub    %eax,%edx
  800a97:	89 d0                	mov    %edx,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a9e:	eb 0c                	jmp    800aac <strncmp+0x11>
		n--, p++, q++;
  800aa0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aa4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800aa8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab0:	74 1a                	je     800acc <strncmp+0x31>
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	0f b6 00             	movzbl (%eax),%eax
  800ab8:	84 c0                	test   %al,%al
  800aba:	74 10                	je     800acc <strncmp+0x31>
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	0f b6 10             	movzbl (%eax),%edx
  800ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac5:	0f b6 00             	movzbl (%eax),%eax
  800ac8:	38 c2                	cmp    %al,%dl
  800aca:	74 d4                	je     800aa0 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800acc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ad0:	75 07                	jne    800ad9 <strncmp+0x3e>
		return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	eb 16                	jmp    800aef <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	0f b6 00             	movzbl (%eax),%eax
  800adf:	0f b6 d0             	movzbl %al,%edx
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	0f b6 00             	movzbl (%eax),%eax
  800ae8:	0f b6 c0             	movzbl %al,%eax
  800aeb:	29 c2                	sub    %eax,%edx
  800aed:	89 d0                	mov    %edx,%eax
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 04             	sub    $0x4,%esp
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800afd:	eb 14                	jmp    800b13 <strchr+0x22>
		if (*s == c)
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	0f b6 00             	movzbl (%eax),%eax
  800b05:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b08:	75 05                	jne    800b0f <strchr+0x1e>
			return (char *) s;
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	eb 13                	jmp    800b22 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	0f b6 00             	movzbl (%eax),%eax
  800b19:	84 c0                	test   %al,%al
  800b1b:	75 e2                	jne    800aff <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	83 ec 04             	sub    $0x4,%esp
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b30:	eb 11                	jmp    800b43 <strfind+0x1f>
		if (*s == c)
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	0f b6 00             	movzbl (%eax),%eax
  800b38:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b3b:	75 02                	jne    800b3f <strfind+0x1b>
			break;
  800b3d:	eb 0e                	jmp    800b4d <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b3f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	0f b6 00             	movzbl (%eax),%eax
  800b49:	84 c0                	test   %al,%al
  800b4b:	75 e5                	jne    800b32 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b5a:	75 05                	jne    800b61 <memset+0xf>
		return v;
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	eb 5c                	jmp    800bbd <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	83 e0 03             	and    $0x3,%eax
  800b67:	85 c0                	test   %eax,%eax
  800b69:	75 41                	jne    800bac <memset+0x5a>
  800b6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6e:	83 e0 03             	and    $0x3,%eax
  800b71:	85 c0                	test   %eax,%eax
  800b73:	75 37                	jne    800bac <memset+0x5a>
		c &= 0xFF;
  800b75:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7f:	c1 e0 18             	shl    $0x18,%eax
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	c1 e0 10             	shl    $0x10,%eax
  800b8a:	09 c2                	or     %eax,%edx
  800b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8f:	c1 e0 08             	shl    $0x8,%eax
  800b92:	09 d0                	or     %edx,%eax
  800b94:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b97:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9a:	c1 e8 02             	shr    $0x2,%eax
  800b9d:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	fc                   	cld    
  800ba8:	f3 ab                	rep stos %eax,%es:(%edi)
  800baa:	eb 0e                	jmp    800bba <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	fc                   	cld    
  800bb8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800bdb:	73 6d                	jae    800c4a <memmove+0x8a>
  800bdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be3:	01 d0                	add    %edx,%eax
  800be5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800be8:	76 60                	jbe    800c4a <memmove+0x8a>
		s += n;
  800bea:	8b 45 10             	mov    0x10(%ebp),%eax
  800bed:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800bf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf3:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf9:	83 e0 03             	and    $0x3,%eax
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	75 2f                	jne    800c2f <memmove+0x6f>
  800c00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c03:	83 e0 03             	and    $0x3,%eax
  800c06:	85 c0                	test   %eax,%eax
  800c08:	75 25                	jne    800c2f <memmove+0x6f>
  800c0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0d:	83 e0 03             	and    $0x3,%eax
  800c10:	85 c0                	test   %eax,%eax
  800c12:	75 1b                	jne    800c2f <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c17:	83 e8 04             	sub    $0x4,%eax
  800c1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c1d:	83 ea 04             	sub    $0x4,%edx
  800c20:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c23:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	89 d6                	mov    %edx,%esi
  800c2a:	fd                   	std    
  800c2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2d:	eb 18                	jmp    800c47 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c32:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c38:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3e:	89 d7                	mov    %edx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	89 c1                	mov    %eax,%ecx
  800c44:	fd                   	std    
  800c45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c47:	fc                   	cld    
  800c48:	eb 45                	jmp    800c8f <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4d:	83 e0 03             	and    $0x3,%eax
  800c50:	85 c0                	test   %eax,%eax
  800c52:	75 2b                	jne    800c7f <memmove+0xbf>
  800c54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c57:	83 e0 03             	and    $0x3,%eax
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	75 21                	jne    800c7f <memmove+0xbf>
  800c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c61:	83 e0 03             	and    $0x3,%eax
  800c64:	85 c0                	test   %eax,%eax
  800c66:	75 17                	jne    800c7f <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c68:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6b:	c1 e8 02             	shr    $0x2,%eax
  800c6e:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c73:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	89 d6                	mov    %edx,%esi
  800c7a:	fc                   	cld    
  800c7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7d:	eb 10                	jmp    800c8f <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c82:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c85:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c88:	89 c7                	mov    %eax,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	fc                   	cld    
  800c8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	89 04 24             	mov    %eax,(%esp)
  800cb4:	e8 07 ff ff ff       	call   800bc0 <memmove>
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cca:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ccd:	eb 30                	jmp    800cff <memcmp+0x44>
		if (*s1 != *s2)
  800ccf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cd2:	0f b6 10             	movzbl (%eax),%edx
  800cd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cd8:	0f b6 00             	movzbl (%eax),%eax
  800cdb:	38 c2                	cmp    %al,%dl
  800cdd:	74 18                	je     800cf7 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800cdf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce2:	0f b6 00             	movzbl (%eax),%eax
  800ce5:	0f b6 d0             	movzbl %al,%edx
  800ce8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ceb:	0f b6 00             	movzbl (%eax),%eax
  800cee:	0f b6 c0             	movzbl %al,%eax
  800cf1:	29 c2                	sub    %eax,%edx
  800cf3:	89 d0                	mov    %edx,%eax
  800cf5:	eb 1a                	jmp    800d11 <memcmp+0x56>
		s1++, s2++;
  800cf7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cfb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cff:	8b 45 10             	mov    0x10(%ebp),%eax
  800d02:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d05:	89 55 10             	mov    %edx,0x10(%ebp)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	75 c3                	jne    800ccf <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d19:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	01 d0                	add    %edx,%eax
  800d21:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d24:	eb 13                	jmp    800d39 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
  800d29:	0f b6 10             	movzbl (%eax),%edx
  800d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2f:	38 c2                	cmp    %al,%dl
  800d31:	75 02                	jne    800d35 <memfind+0x22>
			break;
  800d33:	eb 0c                	jmp    800d41 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d35:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d3f:	72 e5                	jb     800d26 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d44:	c9                   	leave  
  800d45:	c3                   	ret    

00800d46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d4c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d53:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d5a:	eb 04                	jmp    800d60 <strtol+0x1a>
		s++;
  800d5c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	3c 20                	cmp    $0x20,%al
  800d68:	74 f2                	je     800d5c <strtol+0x16>
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	0f b6 00             	movzbl (%eax),%eax
  800d70:	3c 09                	cmp    $0x9,%al
  800d72:	74 e8                	je     800d5c <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	0f b6 00             	movzbl (%eax),%eax
  800d7a:	3c 2b                	cmp    $0x2b,%al
  800d7c:	75 06                	jne    800d84 <strtol+0x3e>
		s++;
  800d7e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d82:	eb 15                	jmp    800d99 <strtol+0x53>
	else if (*s == '-')
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	0f b6 00             	movzbl (%eax),%eax
  800d8a:	3c 2d                	cmp    $0x2d,%al
  800d8c:	75 0b                	jne    800d99 <strtol+0x53>
		s++, neg = 1;
  800d8e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d92:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9d:	74 06                	je     800da5 <strtol+0x5f>
  800d9f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800da3:	75 24                	jne    800dc9 <strtol+0x83>
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	0f b6 00             	movzbl (%eax),%eax
  800dab:	3c 30                	cmp    $0x30,%al
  800dad:	75 1a                	jne    800dc9 <strtol+0x83>
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	83 c0 01             	add    $0x1,%eax
  800db5:	0f b6 00             	movzbl (%eax),%eax
  800db8:	3c 78                	cmp    $0x78,%al
  800dba:	75 0d                	jne    800dc9 <strtol+0x83>
		s += 2, base = 16;
  800dbc:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dc0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800dc7:	eb 2a                	jmp    800df3 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800dc9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dcd:	75 17                	jne    800de6 <strtol+0xa0>
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	0f b6 00             	movzbl (%eax),%eax
  800dd5:	3c 30                	cmp    $0x30,%al
  800dd7:	75 0d                	jne    800de6 <strtol+0xa0>
		s++, base = 8;
  800dd9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ddd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800de4:	eb 0d                	jmp    800df3 <strtol+0xad>
	else if (base == 0)
  800de6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dea:	75 07                	jne    800df3 <strtol+0xad>
		base = 10;
  800dec:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	0f b6 00             	movzbl (%eax),%eax
  800df9:	3c 2f                	cmp    $0x2f,%al
  800dfb:	7e 1b                	jle    800e18 <strtol+0xd2>
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	0f b6 00             	movzbl (%eax),%eax
  800e03:	3c 39                	cmp    $0x39,%al
  800e05:	7f 11                	jg     800e18 <strtol+0xd2>
			dig = *s - '0';
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	0f b6 00             	movzbl (%eax),%eax
  800e0d:	0f be c0             	movsbl %al,%eax
  800e10:	83 e8 30             	sub    $0x30,%eax
  800e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e16:	eb 48                	jmp    800e60 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	0f b6 00             	movzbl (%eax),%eax
  800e1e:	3c 60                	cmp    $0x60,%al
  800e20:	7e 1b                	jle    800e3d <strtol+0xf7>
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	0f b6 00             	movzbl (%eax),%eax
  800e28:	3c 7a                	cmp    $0x7a,%al
  800e2a:	7f 11                	jg     800e3d <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	0f be c0             	movsbl %al,%eax
  800e35:	83 e8 57             	sub    $0x57,%eax
  800e38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e3b:	eb 23                	jmp    800e60 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 00             	movzbl (%eax),%eax
  800e43:	3c 40                	cmp    $0x40,%al
  800e45:	7e 3d                	jle    800e84 <strtol+0x13e>
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	0f b6 00             	movzbl (%eax),%eax
  800e4d:	3c 5a                	cmp    $0x5a,%al
  800e4f:	7f 33                	jg     800e84 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e51:	8b 45 08             	mov    0x8(%ebp),%eax
  800e54:	0f b6 00             	movzbl (%eax),%eax
  800e57:	0f be c0             	movsbl %al,%eax
  800e5a:	83 e8 37             	sub    $0x37,%eax
  800e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e63:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e66:	7c 02                	jl     800e6a <strtol+0x124>
			break;
  800e68:	eb 1a                	jmp    800e84 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e6e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e71:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e75:	89 c2                	mov    %eax,%edx
  800e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7a:	01 d0                	add    %edx,%eax
  800e7c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800e7f:	e9 6f ff ff ff       	jmp    800df3 <strtol+0xad>

	if (endptr)
  800e84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e88:	74 08                	je     800e92 <strtol+0x14c>
		*endptr = (char *) s;
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800e92:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800e96:	74 07                	je     800e9f <strtol+0x159>
  800e98:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e9b:	f7 d8                	neg    %eax
  800e9d:	eb 03                	jmp    800ea2 <strtol+0x15c>
  800e9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	8b 55 10             	mov    0x10(%ebp),%edx
  800eb3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800eb6:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800eb9:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800ebc:	8b 75 20             	mov    0x20(%ebp),%esi
  800ebf:	cd 30                	int    $0x30
  800ec1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec8:	74 30                	je     800efa <syscall+0x56>
  800eca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ece:	7e 2a                	jle    800efa <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ed3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ede:	c7 44 24 08 84 18 80 	movl   $0x801884,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 a1 18 80 00 	movl   $0x8018a1,(%esp)
  800ef5:	e8 84 f2 ff ff       	call   80017e <_panic>

	return ret;
  800efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800efd:	83 c4 3c             	add    $0x3c,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f15:	00 
  800f16:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f1d:	00 
  800f1e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f25:	00 
  800f26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f29:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f38:	00 
  800f39:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f40:	e8 5f ff ff ff       	call   800ea4 <syscall>
}
  800f45:	c9                   	leave  
  800f46:	c3                   	ret    

00800f47 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f4d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f54:	00 
  800f55:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f64:	00 
  800f65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f74:	00 
  800f75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f7c:	00 
  800f7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800f84:	e8 1b ff ff ff       	call   800ea4 <syscall>
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fab:	00 
  800fac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb3:	00 
  800fb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800fc7:	e8 d8 fe ff ff       	call   800ea4 <syscall>
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fd4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800feb:	00 
  800fec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801003:	00 
  801004:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80100b:	e8 94 fe ff ff       	call   800ea4 <syscall>
}
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <sys_yield>:

void
sys_yield(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801018:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80101f:	00 
  801020:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801027:	00 
  801028:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80102f:	00 
  801030:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801037:	00 
  801038:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103f:	00 
  801040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801047:	00 
  801048:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80104f:	e8 50 fe ff ff       	call   800ea4 <syscall>
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80105c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80105f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
  801065:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80106c:	00 
  80106d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801074:	00 
  801075:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801079:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80107d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801081:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  801090:	e8 0f fe ff ff       	call   800ea4 <syscall>
}
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80109f:	8b 75 18             	mov    0x18(%ebp),%esi
  8010a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010b2:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010b6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010c9:	00 
  8010ca:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010d1:	e8 ce fd ff ff       	call   800ea4 <syscall>
}
  8010d6:	83 c4 20             	add    $0x20,%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010f8:	00 
  8010f9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801100:	00 
  801101:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801105:	89 44 24 08          	mov    %eax,0x8(%esp)
  801109:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801110:	00 
  801111:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801118:	e8 87 fd ff ff       	call   800ea4 <syscall>
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801125:	8b 55 0c             	mov    0xc(%ebp),%edx
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801132:	00 
  801133:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80113a:	00 
  80113b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801142:	00 
  801143:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801147:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80115a:	e8 45 fd ff ff       	call   800ea4 <syscall>
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801174:	00 
  801175:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80117c:	00 
  80117d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801184:	00 
  801185:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801189:	89 44 24 08          	mov    %eax,0x8(%esp)
  80118d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801194:	00 
  801195:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80119c:	e8 03 fd ff ff       	call   800ea4 <syscall>
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011ac:	8b 55 10             	mov    0x10(%ebp),%edx
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011b9:	00 
  8011ba:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011be:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8011dc:	e8 c3 fc ff ff       	call   800ea4 <syscall>
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011f3:	00 
  8011f4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801203:	00 
  801204:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80120b:	00 
  80120c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801210:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80121f:	e8 80 fc ff ff       	call   800ea4 <syscall>
}
  801224:	c9                   	leave  
  801225:	c3                   	ret    

00801226 <sys_exec>:

void sys_exec(char* buf){
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80122c:	8b 45 08             	mov    0x8(%ebp),%eax
  80122f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801236:	00 
  801237:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80123e:	00 
  80123f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801246:	00 
  801247:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80124e:	00 
  80124f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801253:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80125a:	00 
  80125b:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801262:	e8 3d fc ff ff       	call   800ea4 <syscall>
}
  801267:	c9                   	leave  
  801268:	c3                   	ret    

00801269 <sys_wait>:

void sys_wait(){
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80126f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801276:	00 
  801277:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80127e:	00 
  80127f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801286:	00 
  801287:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80128e:	00 
  80128f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801296:	00 
  801297:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80129e:	00 
  80129f:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8012a6:	e8 f9 fb ff ff       	call   800ea4 <syscall>
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    
  8012ad:	66 90                	xchg   %ax,%ax
  8012af:	90                   	nop

008012b0 <__udivdi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	83 ec 0c             	sub    $0xc,%esp
  8012b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012cc:	89 ea                	mov    %ebp,%edx
  8012ce:	89 0c 24             	mov    %ecx,(%esp)
  8012d1:	75 2d                	jne    801300 <__udivdi3+0x50>
  8012d3:	39 e9                	cmp    %ebp,%ecx
  8012d5:	77 61                	ja     801338 <__udivdi3+0x88>
  8012d7:	85 c9                	test   %ecx,%ecx
  8012d9:	89 ce                	mov    %ecx,%esi
  8012db:	75 0b                	jne    8012e8 <__udivdi3+0x38>
  8012dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8012e2:	31 d2                	xor    %edx,%edx
  8012e4:	f7 f1                	div    %ecx
  8012e6:	89 c6                	mov    %eax,%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	89 e8                	mov    %ebp,%eax
  8012ec:	f7 f6                	div    %esi
  8012ee:	89 c5                	mov    %eax,%ebp
  8012f0:	89 f8                	mov    %edi,%eax
  8012f2:	f7 f6                	div    %esi
  8012f4:	89 ea                	mov    %ebp,%edx
  8012f6:	83 c4 0c             	add    $0xc,%esp
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    
  8012fd:	8d 76 00             	lea    0x0(%esi),%esi
  801300:	39 e8                	cmp    %ebp,%eax
  801302:	77 24                	ja     801328 <__udivdi3+0x78>
  801304:	0f bd e8             	bsr    %eax,%ebp
  801307:	83 f5 1f             	xor    $0x1f,%ebp
  80130a:	75 3c                	jne    801348 <__udivdi3+0x98>
  80130c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801310:	39 34 24             	cmp    %esi,(%esp)
  801313:	0f 86 9f 00 00 00    	jbe    8013b8 <__udivdi3+0x108>
  801319:	39 d0                	cmp    %edx,%eax
  80131b:	0f 82 97 00 00 00    	jb     8013b8 <__udivdi3+0x108>
  801321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801328:	31 d2                	xor    %edx,%edx
  80132a:	31 c0                	xor    %eax,%eax
  80132c:	83 c4 0c             	add    $0xc,%esp
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	90                   	nop
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	89 f8                	mov    %edi,%eax
  80133a:	f7 f1                	div    %ecx
  80133c:	31 d2                	xor    %edx,%edx
  80133e:	83 c4 0c             	add    $0xc,%esp
  801341:	5e                   	pop    %esi
  801342:	5f                   	pop    %edi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    
  801345:	8d 76 00             	lea    0x0(%esi),%esi
  801348:	89 e9                	mov    %ebp,%ecx
  80134a:	8b 3c 24             	mov    (%esp),%edi
  80134d:	d3 e0                	shl    %cl,%eax
  80134f:	89 c6                	mov    %eax,%esi
  801351:	b8 20 00 00 00       	mov    $0x20,%eax
  801356:	29 e8                	sub    %ebp,%eax
  801358:	89 c1                	mov    %eax,%ecx
  80135a:	d3 ef                	shr    %cl,%edi
  80135c:	89 e9                	mov    %ebp,%ecx
  80135e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801362:	8b 3c 24             	mov    (%esp),%edi
  801365:	09 74 24 08          	or     %esi,0x8(%esp)
  801369:	89 d6                	mov    %edx,%esi
  80136b:	d3 e7                	shl    %cl,%edi
  80136d:	89 c1                	mov    %eax,%ecx
  80136f:	89 3c 24             	mov    %edi,(%esp)
  801372:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801376:	d3 ee                	shr    %cl,%esi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	d3 e2                	shl    %cl,%edx
  80137c:	89 c1                	mov    %eax,%ecx
  80137e:	d3 ef                	shr    %cl,%edi
  801380:	09 d7                	or     %edx,%edi
  801382:	89 f2                	mov    %esi,%edx
  801384:	89 f8                	mov    %edi,%eax
  801386:	f7 74 24 08          	divl   0x8(%esp)
  80138a:	89 d6                	mov    %edx,%esi
  80138c:	89 c7                	mov    %eax,%edi
  80138e:	f7 24 24             	mull   (%esp)
  801391:	39 d6                	cmp    %edx,%esi
  801393:	89 14 24             	mov    %edx,(%esp)
  801396:	72 30                	jb     8013c8 <__udivdi3+0x118>
  801398:	8b 54 24 04          	mov    0x4(%esp),%edx
  80139c:	89 e9                	mov    %ebp,%ecx
  80139e:	d3 e2                	shl    %cl,%edx
  8013a0:	39 c2                	cmp    %eax,%edx
  8013a2:	73 05                	jae    8013a9 <__udivdi3+0xf9>
  8013a4:	3b 34 24             	cmp    (%esp),%esi
  8013a7:	74 1f                	je     8013c8 <__udivdi3+0x118>
  8013a9:	89 f8                	mov    %edi,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	e9 7a ff ff ff       	jmp    80132c <__udivdi3+0x7c>
  8013b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b8:	31 d2                	xor    %edx,%edx
  8013ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bf:	e9 68 ff ff ff       	jmp    80132c <__udivdi3+0x7c>
  8013c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	83 c4 0c             	add    $0xc,%esp
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    
  8013d4:	66 90                	xchg   %ax,%ax
  8013d6:	66 90                	xchg   %ax,%ax
  8013d8:	66 90                	xchg   %ax,%ax
  8013da:	66 90                	xchg   %ax,%ax
  8013dc:	66 90                	xchg   %ax,%ax
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <__umoddi3>:
  8013e0:	55                   	push   %ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	83 ec 14             	sub    $0x14,%esp
  8013e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8013f2:	89 c7                	mov    %eax,%edi
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801400:	89 34 24             	mov    %esi,(%esp)
  801403:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801407:	85 c0                	test   %eax,%eax
  801409:	89 c2                	mov    %eax,%edx
  80140b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80140f:	75 17                	jne    801428 <__umoddi3+0x48>
  801411:	39 fe                	cmp    %edi,%esi
  801413:	76 4b                	jbe    801460 <__umoddi3+0x80>
  801415:	89 c8                	mov    %ecx,%eax
  801417:	89 fa                	mov    %edi,%edx
  801419:	f7 f6                	div    %esi
  80141b:	89 d0                	mov    %edx,%eax
  80141d:	31 d2                	xor    %edx,%edx
  80141f:	83 c4 14             	add    $0x14,%esp
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    
  801426:	66 90                	xchg   %ax,%ax
  801428:	39 f8                	cmp    %edi,%eax
  80142a:	77 54                	ja     801480 <__umoddi3+0xa0>
  80142c:	0f bd e8             	bsr    %eax,%ebp
  80142f:	83 f5 1f             	xor    $0x1f,%ebp
  801432:	75 5c                	jne    801490 <__umoddi3+0xb0>
  801434:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801438:	39 3c 24             	cmp    %edi,(%esp)
  80143b:	0f 87 e7 00 00 00    	ja     801528 <__umoddi3+0x148>
  801441:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801445:	29 f1                	sub    %esi,%ecx
  801447:	19 c7                	sbb    %eax,%edi
  801449:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80144d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801451:	8b 44 24 08          	mov    0x8(%esp),%eax
  801455:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801459:	83 c4 14             	add    $0x14,%esp
  80145c:	5e                   	pop    %esi
  80145d:	5f                   	pop    %edi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    
  801460:	85 f6                	test   %esi,%esi
  801462:	89 f5                	mov    %esi,%ebp
  801464:	75 0b                	jne    801471 <__umoddi3+0x91>
  801466:	b8 01 00 00 00       	mov    $0x1,%eax
  80146b:	31 d2                	xor    %edx,%edx
  80146d:	f7 f6                	div    %esi
  80146f:	89 c5                	mov    %eax,%ebp
  801471:	8b 44 24 04          	mov    0x4(%esp),%eax
  801475:	31 d2                	xor    %edx,%edx
  801477:	f7 f5                	div    %ebp
  801479:	89 c8                	mov    %ecx,%eax
  80147b:	f7 f5                	div    %ebp
  80147d:	eb 9c                	jmp    80141b <__umoddi3+0x3b>
  80147f:	90                   	nop
  801480:	89 c8                	mov    %ecx,%eax
  801482:	89 fa                	mov    %edi,%edx
  801484:	83 c4 14             	add    $0x14,%esp
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    
  80148b:	90                   	nop
  80148c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801490:	8b 04 24             	mov    (%esp),%eax
  801493:	be 20 00 00 00       	mov    $0x20,%esi
  801498:	89 e9                	mov    %ebp,%ecx
  80149a:	29 ee                	sub    %ebp,%esi
  80149c:	d3 e2                	shl    %cl,%edx
  80149e:	89 f1                	mov    %esi,%ecx
  8014a0:	d3 e8                	shr    %cl,%eax
  8014a2:	89 e9                	mov    %ebp,%ecx
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	8b 04 24             	mov    (%esp),%eax
  8014ab:	09 54 24 04          	or     %edx,0x4(%esp)
  8014af:	89 fa                	mov    %edi,%edx
  8014b1:	d3 e0                	shl    %cl,%eax
  8014b3:	89 f1                	mov    %esi,%ecx
  8014b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014bd:	d3 ea                	shr    %cl,%edx
  8014bf:	89 e9                	mov    %ebp,%ecx
  8014c1:	d3 e7                	shl    %cl,%edi
  8014c3:	89 f1                	mov    %esi,%ecx
  8014c5:	d3 e8                	shr    %cl,%eax
  8014c7:	89 e9                	mov    %ebp,%ecx
  8014c9:	09 f8                	or     %edi,%eax
  8014cb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8014cf:	f7 74 24 04          	divl   0x4(%esp)
  8014d3:	d3 e7                	shl    %cl,%edi
  8014d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014d9:	89 d7                	mov    %edx,%edi
  8014db:	f7 64 24 08          	mull   0x8(%esp)
  8014df:	39 d7                	cmp    %edx,%edi
  8014e1:	89 c1                	mov    %eax,%ecx
  8014e3:	89 14 24             	mov    %edx,(%esp)
  8014e6:	72 2c                	jb     801514 <__umoddi3+0x134>
  8014e8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014ec:	72 22                	jb     801510 <__umoddi3+0x130>
  8014ee:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014f2:	29 c8                	sub    %ecx,%eax
  8014f4:	19 d7                	sbb    %edx,%edi
  8014f6:	89 e9                	mov    %ebp,%ecx
  8014f8:	89 fa                	mov    %edi,%edx
  8014fa:	d3 e8                	shr    %cl,%eax
  8014fc:	89 f1                	mov    %esi,%ecx
  8014fe:	d3 e2                	shl    %cl,%edx
  801500:	89 e9                	mov    %ebp,%ecx
  801502:	d3 ef                	shr    %cl,%edi
  801504:	09 d0                	or     %edx,%eax
  801506:	89 fa                	mov    %edi,%edx
  801508:	83 c4 14             	add    $0x14,%esp
  80150b:	5e                   	pop    %esi
  80150c:	5f                   	pop    %edi
  80150d:	5d                   	pop    %ebp
  80150e:	c3                   	ret    
  80150f:	90                   	nop
  801510:	39 d7                	cmp    %edx,%edi
  801512:	75 da                	jne    8014ee <__umoddi3+0x10e>
  801514:	8b 14 24             	mov    (%esp),%edx
  801517:	89 c1                	mov    %eax,%ecx
  801519:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80151d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801521:	eb cb                	jmp    8014ee <__umoddi3+0x10e>
  801523:	90                   	nop
  801524:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801528:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80152c:	0f 82 0f ff ff ff    	jb     801441 <__umoddi3+0x61>
  801532:	e9 1a ff ff ff       	jmp    801451 <__umoddi3+0x71>
