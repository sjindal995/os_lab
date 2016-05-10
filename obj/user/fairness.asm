
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 96 00 00 00       	call   8000c7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	envid_t who, id;

	id = sys_getenvid();
  800039:	e8 d1 0e 00 00       	call   800f0f <sys_getenvid>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if (thisenv == &envs[1]) {
  800041:	a1 04 20 80 00       	mov    0x802004,%eax
  800046:	3d 7c 00 c0 ee       	cmp    $0xeec0007c,%eax
  80004b:	75 37                	jne    800084 <umain+0x51>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800054:	00 
  800055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80005c:	00 
  80005d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800060:	89 04 24             	mov    %eax,(%esp)
  800063:	e8 ca 11 00 00       	call   801232 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  800068:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80006b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  80007d:	e8 58 01 00 00       	call   8001da <cprintf>
		}
  800082:	eb c9                	jmp    80004d <umain+0x1a>
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800084:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800089:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800090:	89 44 24 04          	mov    %eax,0x4(%esp)
  800094:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  80009b:	e8 3a 01 00 00       	call   8001da <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  8000a0:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000ac:	00 
  8000ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b4:	00 
  8000b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000bc:	00 
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 0b 12 00 00       	call   8012d0 <ipc_send>
  8000c5:	eb d9                	jmp    8000a0 <umain+0x6d>

008000c7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000cd:	e8 3d 0e 00 00       	call   800f0f <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	c1 e0 02             	shl    $0x2,%eax
  8000da:	89 c2                	mov    %eax,%edx
  8000dc:	c1 e2 05             	shl    $0x5,%edx
  8000df:	29 c2                	sub    %eax,%edx
  8000e1:	89 d0                	mov    %edx,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  8000ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f7:	89 04 24             	mov    %eax,(%esp)
  8000fa:	e8 34 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 02 00 00 00       	call   800106 <exit>
}
  800104:	c9                   	leave  
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80010c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800113:	e8 b4 0d 00 00       	call   800ecc <sys_env_destroy>
}
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800120:	8b 45 0c             	mov    0xc(%ebp),%eax
  800123:	8b 00                	mov    (%eax),%eax
  800125:	8d 48 01             	lea    0x1(%eax),%ecx
  800128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012b:	89 0a                	mov    %ecx,(%edx)
  80012d:	8b 55 08             	mov    0x8(%ebp),%edx
  800130:	89 d1                	mov    %edx,%ecx
  800132:	8b 55 0c             	mov    0xc(%ebp),%edx
  800135:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800139:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013c:	8b 00                	mov    (%eax),%eax
  80013e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800143:	75 20                	jne    800165 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800145:	8b 45 0c             	mov    0xc(%ebp),%eax
  800148:	8b 00                	mov    (%eax),%eax
  80014a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80014d:	83 c2 08             	add    $0x8,%edx
  800150:	89 44 24 04          	mov    %eax,0x4(%esp)
  800154:	89 14 24             	mov    %edx,(%esp)
  800157:	e8 ea 0c 00 00       	call   800e46 <sys_cputs>
		b->idx = 0;
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800165:	8b 45 0c             	mov    0xc(%ebp),%eax
  800168:	8b 40 04             	mov    0x4(%eax),%eax
  80016b:	8d 50 01             	lea    0x1(%eax),%edx
  80016e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800171:	89 50 04             	mov    %edx,0x4(%eax)
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80017f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800186:	00 00 00 
	b.cnt = 0;
  800189:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800190:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800193:	8b 45 0c             	mov    0xc(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ab:	c7 04 24 1a 01 80 00 	movl   $0x80011a,(%esp)
  8001b2:	e8 bd 01 00 00       	call   800374 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c7:	83 c0 08             	add    $0x8,%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 74 0c 00 00       	call   800e46 <sys_cputs>

	return b.cnt;
  8001d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8001e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 7e ff ff ff       	call   800176 <vcprintf>
  8001f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8001fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	53                   	push   %ebx
  800204:	83 ec 34             	sub    $0x34,%esp
  800207:	8b 45 10             	mov    0x10(%ebp),%eax
  80020a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80020d:	8b 45 14             	mov    0x14(%ebp),%eax
  800210:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	8b 45 18             	mov    0x18(%ebp),%eax
  800216:	ba 00 00 00 00       	mov    $0x0,%edx
  80021b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80021e:	77 72                	ja     800292 <printnum+0x92>
  800220:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800223:	72 05                	jb     80022a <printnum+0x2a>
  800225:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800228:	77 68                	ja     800292 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80022d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800230:	8b 45 18             	mov    0x18(%ebp),%eax
  800233:	ba 00 00 00 00       	mov    $0x0,%edx
  800238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800243:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800246:	89 04 24             	mov    %eax,(%esp)
  800249:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024d:	e8 ce 11 00 00       	call   801420 <__udivdi3>
  800252:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800255:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800259:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80025d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800260:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	e8 82 ff ff ff       	call   800200 <printnum>
  80027e:	eb 1c                	jmp    80029c <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 44 24 04          	mov    %eax,0x4(%esp)
  800287:	8b 45 20             	mov    0x20(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800292:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800296:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80029a:	7f e4                	jg     800280 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80029f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8002a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002aa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ae:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b9:	e8 92 12 00 00       	call   801550 <__umoddi3>
  8002be:	05 c8 17 80 00       	add    $0x8017c8,%eax
  8002c3:	0f b6 00             	movzbl (%eax),%eax
  8002c6:	0f be c0             	movsbl %al,%eax
  8002c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	ff d0                	call   *%eax
}
  8002d8:	83 c4 34             	add    $0x34,%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002e5:	7e 14                	jle    8002fb <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	8b 00                	mov    (%eax),%eax
  8002ec:	8d 48 08             	lea    0x8(%eax),%ecx
  8002ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f2:	89 0a                	mov    %ecx,(%edx)
  8002f4:	8b 50 04             	mov    0x4(%eax),%edx
  8002f7:	8b 00                	mov    (%eax),%eax
  8002f9:	eb 30                	jmp    80032b <getuint+0x4d>
	else if (lflag)
  8002fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002ff:	74 16                	je     800317 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	8b 00                	mov    (%eax),%eax
  800306:	8d 48 04             	lea    0x4(%eax),%ecx
  800309:	8b 55 08             	mov    0x8(%ebp),%edx
  80030c:	89 0a                	mov    %ecx,(%edx)
  80030e:	8b 00                	mov    (%eax),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	eb 14                	jmp    80032b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	8b 00                	mov    (%eax),%eax
  80031c:	8d 48 04             	lea    0x4(%eax),%ecx
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
  800322:	89 0a                	mov    %ecx,(%edx)
  800324:	8b 00                	mov    (%eax),%eax
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800330:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800334:	7e 14                	jle    80034a <getint+0x1d>
		return va_arg(*ap, long long);
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	8d 48 08             	lea    0x8(%eax),%ecx
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	89 0a                	mov    %ecx,(%edx)
  800343:	8b 50 04             	mov    0x4(%eax),%edx
  800346:	8b 00                	mov    (%eax),%eax
  800348:	eb 28                	jmp    800372 <getint+0x45>
	else if (lflag)
  80034a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80034e:	74 12                	je     800362 <getint+0x35>
		return va_arg(*ap, long);
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	8b 00                	mov    (%eax),%eax
  800355:	8d 48 04             	lea    0x4(%eax),%ecx
  800358:	8b 55 08             	mov    0x8(%ebp),%edx
  80035b:	89 0a                	mov    %ecx,(%edx)
  80035d:	8b 00                	mov    (%eax),%eax
  80035f:	99                   	cltd   
  800360:	eb 10                	jmp    800372 <getint+0x45>
	else
		return va_arg(*ap, int);
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	8b 00                	mov    (%eax),%eax
  800367:	8d 48 04             	lea    0x4(%eax),%ecx
  80036a:	8b 55 08             	mov    0x8(%ebp),%edx
  80036d:	89 0a                	mov    %ecx,(%edx)
  80036f:	8b 00                	mov    (%eax),%eax
  800371:	99                   	cltd   
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037c:	eb 18                	jmp    800396 <vprintfmt+0x22>
			if (ch == '\0')
  80037e:	85 db                	test   %ebx,%ebx
  800380:	75 05                	jne    800387 <vprintfmt+0x13>
				return;
  800382:	e9 cc 03 00 00       	jmp    800753 <vprintfmt+0x3df>
			putch(ch, putdat);
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038e:	89 1c 24             	mov    %ebx,(%esp)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800396:	8b 45 10             	mov    0x10(%ebp),%eax
  800399:	8d 50 01             	lea    0x1(%eax),%edx
  80039c:	89 55 10             	mov    %edx,0x10(%ebp)
  80039f:	0f b6 00             	movzbl (%eax),%eax
  8003a2:	0f b6 d8             	movzbl %al,%ebx
  8003a5:	83 fb 25             	cmp    $0x25,%ebx
  8003a8:	75 d4                	jne    80037e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003aa:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003ae:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003c3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cd:	8d 50 01             	lea    0x1(%eax),%edx
  8003d0:	89 55 10             	mov    %edx,0x10(%ebp)
  8003d3:	0f b6 00             	movzbl (%eax),%eax
  8003d6:	0f b6 d8             	movzbl %al,%ebx
  8003d9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003dc:	83 f8 55             	cmp    $0x55,%eax
  8003df:	0f 87 3d 03 00 00    	ja     800722 <vprintfmt+0x3ae>
  8003e5:	8b 04 85 ec 17 80 00 	mov    0x8017ec(,%eax,4),%eax
  8003ec:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ee:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003f2:	eb d6                	jmp    8003ca <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f4:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003f8:	eb d0                	jmp    8003ca <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800401:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800404:	89 d0                	mov    %edx,%eax
  800406:	c1 e0 02             	shl    $0x2,%eax
  800409:	01 d0                	add    %edx,%eax
  80040b:	01 c0                	add    %eax,%eax
  80040d:	01 d8                	add    %ebx,%eax
  80040f:	83 e8 30             	sub    $0x30,%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800415:	8b 45 10             	mov    0x10(%ebp),%eax
  800418:	0f b6 00             	movzbl (%eax),%eax
  80041b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80041e:	83 fb 2f             	cmp    $0x2f,%ebx
  800421:	7e 0b                	jle    80042e <vprintfmt+0xba>
  800423:	83 fb 39             	cmp    $0x39,%ebx
  800426:	7f 06                	jg     80042e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800428:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042c:	eb d3                	jmp    800401 <vprintfmt+0x8d>
			goto process_precision;
  80042e:	eb 33                	jmp    800463 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80043e:	eb 23                	jmp    800463 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800440:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800444:	79 0c                	jns    800452 <vprintfmt+0xde>
				width = 0;
  800446:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80044d:	e9 78 ff ff ff       	jmp    8003ca <vprintfmt+0x56>
  800452:	e9 73 ff ff ff       	jmp    8003ca <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800457:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80045e:	e9 67 ff ff ff       	jmp    8003ca <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800463:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800467:	79 12                	jns    80047b <vprintfmt+0x107>
				width = precision, precision = -1;
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800476:	e9 4f ff ff ff       	jmp    8003ca <vprintfmt+0x56>
  80047b:	e9 4a ff ff ff       	jmp    8003ca <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800480:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800484:	e9 41 ff ff ff       	jmp    8003ca <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	8b 00                	mov    (%eax),%eax
  800494:	8b 55 0c             	mov    0xc(%ebp),%edx
  800497:	89 54 24 04          	mov    %edx,0x4(%esp)
  80049b:	89 04 24             	mov    %eax,(%esp)
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	ff d0                	call   *%eax
			break;
  8004a3:	e9 a5 02 00 00       	jmp    80074d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004b3:	85 db                	test   %ebx,%ebx
  8004b5:	79 02                	jns    8004b9 <vprintfmt+0x145>
				err = -err;
  8004b7:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 fb 09             	cmp    $0x9,%ebx
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x155>
  8004be:	8b 34 9d a0 17 80 00 	mov    0x8017a0(,%ebx,4),%esi
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004cd:	c7 44 24 08 d9 17 80 	movl   $0x8017d9,0x8(%esp)
  8004d4:	00 
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	e8 73 02 00 00       	call   80075a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004e7:	e9 61 02 00 00       	jmp    80074d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004ec:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004f0:	c7 44 24 08 e2 17 80 	movl   $0x8017e2,0x8(%esp)
  8004f7:	00 
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800502:	89 04 24             	mov    %eax,(%esp)
  800505:	e8 50 02 00 00       	call   80075a <printfmt>
			break;
  80050a:	e9 3e 02 00 00       	jmp    80074d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 50 04             	lea    0x4(%eax),%edx
  800515:	89 55 14             	mov    %edx,0x14(%ebp)
  800518:	8b 30                	mov    (%eax),%esi
  80051a:	85 f6                	test   %esi,%esi
  80051c:	75 05                	jne    800523 <vprintfmt+0x1af>
				p = "(null)";
  80051e:	be e5 17 80 00       	mov    $0x8017e5,%esi
			if (width > 0 && padc != '-')
  800523:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800527:	7e 37                	jle    800560 <vprintfmt+0x1ec>
  800529:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80052d:	74 31                	je     800560 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	89 34 24             	mov    %esi,(%esp)
  800539:	e8 39 03 00 00       	call   800877 <strnlen>
  80053e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800541:	eb 17                	jmp    80055a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800543:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800547:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 45 08             	mov    0x8(%ebp),%eax
  800554:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800556:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80055a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055e:	7f e3                	jg     800543 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800560:	eb 38                	jmp    80059a <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800562:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800566:	74 1f                	je     800587 <vprintfmt+0x213>
  800568:	83 fb 1f             	cmp    $0x1f,%ebx
  80056b:	7e 05                	jle    800572 <vprintfmt+0x1fe>
  80056d:	83 fb 7e             	cmp    $0x7e,%ebx
  800570:	7e 15                	jle    800587 <vprintfmt+0x213>
					putch('?', putdat);
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800580:	8b 45 08             	mov    0x8(%ebp),%eax
  800583:	ff d0                	call   *%eax
  800585:	eb 0f                	jmp    800596 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800587:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058e:	89 1c 24             	mov    %ebx,(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80059a:	89 f0                	mov    %esi,%eax
  80059c:	8d 70 01             	lea    0x1(%eax),%esi
  80059f:	0f b6 00             	movzbl (%eax),%eax
  8005a2:	0f be d8             	movsbl %al,%ebx
  8005a5:	85 db                	test   %ebx,%ebx
  8005a7:	74 10                	je     8005b9 <vprintfmt+0x245>
  8005a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ad:	78 b3                	js     800562 <vprintfmt+0x1ee>
  8005af:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b7:	79 a9                	jns    800562 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b9:	eb 17                	jmp    8005d2 <vprintfmt+0x25e>
				putch(' ', putdat);
  8005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cc:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ce:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d6:	7f e3                	jg     8005bb <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8005d8:	e9 70 01 00 00       	jmp    80074d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8005e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e7:	89 04 24             	mov    %eax,(%esp)
  8005ea:	e8 3e fd ff ff       	call   80032d <getint>
  8005ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	79 26                	jns    800625 <vprintfmt+0x2b1>
				putch('-', putdat);
  8005ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800602:	89 44 24 04          	mov    %eax,0x4(%esp)
  800606:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	ff d0                	call   *%eax
				num = -(long long) num;
  800612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800615:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800622:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800625:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80062c:	e9 a8 00 00 00       	jmp    8006d9 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800631:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800634:	89 44 24 04          	mov    %eax,0x4(%esp)
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	e8 9b fc ff ff       	call   8002de <getuint>
  800643:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800646:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800649:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800650:	e9 84 00 00 00       	jmp    8006d9 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800655:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	e8 77 fc ff ff       	call   8002de <getuint>
  800667:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80066a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  80066d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800674:	eb 63                	jmp    8006d9 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800676:	8b 45 0c             	mov    0xc(%ebp),%eax
  800679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	ff d0                	call   *%eax
			putch('x', putdat);
  800689:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006b8:	eb 1f                	jmp    8006d9 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c4:	89 04 24             	mov    %eax,(%esp)
  8006c7:	e8 12 fc ff ff       	call   8002de <getuint>
  8006cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006d2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	89 54 24 18          	mov    %edx,0x18(%esp)
  8006e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8006eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 f1 fa ff ff       	call   800200 <printnum>
			break;
  80070f:	eb 3c                	jmp    80074d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800711:	8b 45 0c             	mov    0xc(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	89 1c 24             	mov    %ebx,(%esp)
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	ff d0                	call   *%eax
			break;
  800720:	eb 2b                	jmp    80074d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800722:	8b 45 0c             	mov    0xc(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800735:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800739:	eb 04                	jmp    80073f <vprintfmt+0x3cb>
  80073b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80073f:	8b 45 10             	mov    0x10(%ebp),%eax
  800742:	83 e8 01             	sub    $0x1,%eax
  800745:	0f b6 00             	movzbl (%eax),%eax
  800748:	3c 25                	cmp    $0x25,%al
  80074a:	75 ef                	jne    80073b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  80074c:	90                   	nop
		}
	}
  80074d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074e:	e9 43 fc ff ff       	jmp    800396 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800753:	83 c4 40             	add    $0x40,%esp
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
  800763:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	89 04 24             	mov    %eax,(%esp)
  800781:	e8 ee fb ff ff       	call   800374 <vprintfmt>
	va_end(ap);
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80078b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078e:	8b 40 08             	mov    0x8(%eax),%eax
  800791:	8d 50 01             	lea    0x1(%eax),%edx
  800794:	8b 45 0c             	mov    0xc(%ebp),%eax
  800797:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079d:	8b 10                	mov    (%eax),%edx
  80079f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a2:	8b 40 04             	mov    0x4(%eax),%eax
  8007a5:	39 c2                	cmp    %eax,%edx
  8007a7:	73 12                	jae    8007bb <sprintputch+0x33>
		*b->buf++ = ch;
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	8d 48 01             	lea    0x1(%eax),%ecx
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b4:	89 0a                	mov    %ecx,(%edx)
  8007b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b9:	88 10                	mov    %dl,(%eax)
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cc:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d2:	01 d0                	add    %edx,%eax
  8007d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007e2:	74 06                	je     8007ea <vsnprintf+0x2d>
  8007e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007e8:	7f 07                	jg     8007f1 <vsnprintf+0x34>
		return -E_INVAL;
  8007ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ef:	eb 2a                	jmp    80081b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800802:	89 44 24 04          	mov    %eax,0x4(%esp)
  800806:	c7 04 24 88 07 80 00 	movl   $0x800788,(%esp)
  80080d:	e8 62 fb ff ff       	call   800374 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800812:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800815:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800818:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800823:	8d 45 14             	lea    0x14(%ebp),%eax
  800826:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800830:	8b 45 10             	mov    0x10(%ebp),%eax
  800833:	89 44 24 08          	mov    %eax,0x8(%esp)
  800837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	89 04 24             	mov    %eax,(%esp)
  800844:	e8 74 ff ff ff       	call   8007bd <vsnprintf>
  800849:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  80084c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800857:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80085e:	eb 08                	jmp    800868 <strlen+0x17>
		n++;
  800860:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800864:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 00             	movzbl (%eax),%eax
  80086e:	84 c0                	test   %al,%al
  800870:	75 ee                	jne    800860 <strlen+0xf>
		n++;
	return n;
  800872:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800884:	eb 0c                	jmp    800892 <strnlen+0x1b>
		n++;
  800886:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80088e:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800892:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800896:	74 0a                	je     8008a2 <strnlen+0x2b>
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	0f b6 00             	movzbl (%eax),%eax
  80089e:	84 c0                	test   %al,%al
  8008a0:	75 e4                	jne    800886 <strnlen+0xf>
		n++;
	return n;
  8008a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8008b3:	90                   	nop
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8d 50 01             	lea    0x1(%eax),%edx
  8008ba:	89 55 08             	mov    %edx,0x8(%ebp)
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008c3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	88 10                	mov    %dl,(%eax)
  8008cb:	0f b6 00             	movzbl (%eax),%eax
  8008ce:	84 c0                	test   %al,%al
  8008d0:	75 e2                	jne    8008b4 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8008d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	89 04 24             	mov    %eax,(%esp)
  8008e3:	e8 69 ff ff ff       	call   800851 <strlen>
  8008e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8008eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	01 c2                	add    %eax,%edx
  8008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	89 14 24             	mov    %edx,(%esp)
  8008fd:	e8 a5 ff ff ff       	call   8008a7 <strcpy>
	return dst;
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800913:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80091a:	eb 23                	jmp    80093f <strncpy+0x38>
		*dst++ = *src;
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8d 50 01             	lea    0x1(%eax),%edx
  800922:	89 55 08             	mov    %edx,0x8(%ebp)
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	0f b6 12             	movzbl (%edx),%edx
  80092b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80092d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800930:	0f b6 00             	movzbl (%eax),%eax
  800933:	84 c0                	test   %al,%al
  800935:	74 04                	je     80093b <strncpy+0x34>
			src++;
  800937:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80093f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800942:	3b 45 10             	cmp    0x10(%ebp),%eax
  800945:	72 d5                	jb     80091c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800947:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80094a:	c9                   	leave  
  80094b:	c3                   	ret    

0080094c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800958:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80095c:	74 33                	je     800991 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  80095e:	eb 17                	jmp    800977 <strlcpy+0x2b>
			*dst++ = *src++;
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8d 50 01             	lea    0x1(%eax),%edx
  800966:	89 55 08             	mov    %edx,0x8(%ebp)
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80096f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800972:	0f b6 12             	movzbl (%edx),%edx
  800975:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800977:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80097b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80097f:	74 0a                	je     80098b <strlcpy+0x3f>
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	0f b6 00             	movzbl (%eax),%eax
  800987:	84 c0                	test   %al,%al
  800989:	75 d5                	jne    800960 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800991:	8b 55 08             	mov    0x8(%ebp),%edx
  800994:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800997:	29 c2                	sub    %eax,%edx
  800999:	89 d0                	mov    %edx,%eax
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8009a0:	eb 08                	jmp    8009aa <strcmp+0xd>
		p++, q++;
  8009a2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009a6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	0f b6 00             	movzbl (%eax),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 10                	je     8009c4 <strcmp+0x27>
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	0f b6 10             	movzbl (%eax),%edx
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	0f b6 00             	movzbl (%eax),%eax
  8009c0:	38 c2                	cmp    %al,%dl
  8009c2:	74 de                	je     8009a2 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	0f b6 00             	movzbl (%eax),%eax
  8009ca:	0f b6 d0             	movzbl %al,%edx
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	0f b6 00             	movzbl (%eax),%eax
  8009d3:	0f b6 c0             	movzbl %al,%eax
  8009d6:	29 c2                	sub    %eax,%edx
  8009d8:	89 d0                	mov    %edx,%eax
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8009df:	eb 0c                	jmp    8009ed <strncmp+0x11>
		n--, p++, q++;
  8009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8009e5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8009e9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009f1:	74 1a                	je     800a0d <strncmp+0x31>
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	0f b6 00             	movzbl (%eax),%eax
  8009f9:	84 c0                	test   %al,%al
  8009fb:	74 10                	je     800a0d <strncmp+0x31>
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 10             	movzbl (%eax),%edx
  800a03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a06:	0f b6 00             	movzbl (%eax),%eax
  800a09:	38 c2                	cmp    %al,%dl
  800a0b:	74 d4                	je     8009e1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a11:	75 07                	jne    800a1a <strncmp+0x3e>
		return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	eb 16                	jmp    800a30 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	0f b6 00             	movzbl (%eax),%eax
  800a20:	0f b6 d0             	movzbl %al,%edx
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	0f b6 00             	movzbl (%eax),%eax
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	29 c2                	sub    %eax,%edx
  800a2e:	89 d0                	mov    %edx,%eax
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 04             	sub    $0x4,%esp
  800a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a3e:	eb 14                	jmp    800a54 <strchr+0x22>
		if (*s == c)
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	0f b6 00             	movzbl (%eax),%eax
  800a46:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a49:	75 05                	jne    800a50 <strchr+0x1e>
			return (char *) s;
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	eb 13                	jmp    800a63 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	0f b6 00             	movzbl (%eax),%eax
  800a5a:	84 c0                	test   %al,%al
  800a5c:	75 e2                	jne    800a40 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 04             	sub    $0x4,%esp
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800a71:	eb 11                	jmp    800a84 <strfind+0x1f>
		if (*s == c)
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	0f b6 00             	movzbl (%eax),%eax
  800a79:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800a7c:	75 02                	jne    800a80 <strfind+0x1b>
			break;
  800a7e:	eb 0e                	jmp    800a8e <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a80:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	0f b6 00             	movzbl (%eax),%eax
  800a8a:	84 c0                	test   %al,%al
  800a8c:	75 e5                	jne    800a73 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
	char *p;

	if (n == 0)
  800a97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9b:	75 05                	jne    800aa2 <memset+0xf>
		return v;
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	eb 5c                	jmp    800afe <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	83 e0 03             	and    $0x3,%eax
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	75 41                	jne    800aed <memset+0x5a>
  800aac:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaf:	83 e0 03             	and    $0x3,%eax
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	75 37                	jne    800aed <memset+0x5a>
		c &= 0xFF;
  800ab6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac0:	c1 e0 18             	shl    $0x18,%eax
  800ac3:	89 c2                	mov    %eax,%edx
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	c1 e0 10             	shl    $0x10,%eax
  800acb:	09 c2                	or     %eax,%edx
  800acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad0:	c1 e0 08             	shl    $0x8,%eax
  800ad3:	09 d0                	or     %edx,%eax
  800ad5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  800adb:	c1 e8 02             	shr    $0x2,%eax
  800ade:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae6:	89 d7                	mov    %edx,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 ab                	rep stos %eax,%es:(%edi)
  800aeb:	eb 0e                	jmp    800afb <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	fc                   	cld    
  800af9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b19:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b1c:	73 6d                	jae    800b8b <memmove+0x8a>
  800b1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b21:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b24:	01 d0                	add    %edx,%eax
  800b26:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800b29:	76 60                	jbe    800b8b <memmove+0x8a>
		s += n;
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800b31:	8b 45 10             	mov    0x10(%ebp),%eax
  800b34:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3a:	83 e0 03             	and    $0x3,%eax
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	75 2f                	jne    800b70 <memmove+0x6f>
  800b41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b44:	83 e0 03             	and    $0x3,%eax
  800b47:	85 c0                	test   %eax,%eax
  800b49:	75 25                	jne    800b70 <memmove+0x6f>
  800b4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4e:	83 e0 03             	and    $0x3,%eax
  800b51:	85 c0                	test   %eax,%eax
  800b53:	75 1b                	jne    800b70 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b58:	83 e8 04             	sub    $0x4,%eax
  800b5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800b5e:	83 ea 04             	sub    $0x4,%edx
  800b61:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b64:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b67:	89 c7                	mov    %eax,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	fd                   	std    
  800b6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6e:	eb 18                	jmp    800b88 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b73:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b79:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7f:	89 d7                	mov    %edx,%edi
  800b81:	89 de                	mov    %ebx,%esi
  800b83:	89 c1                	mov    %eax,%ecx
  800b85:	fd                   	std    
  800b86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b88:	fc                   	cld    
  800b89:	eb 45                	jmp    800bd0 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8e:	83 e0 03             	and    $0x3,%eax
  800b91:	85 c0                	test   %eax,%eax
  800b93:	75 2b                	jne    800bc0 <memmove+0xbf>
  800b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b98:	83 e0 03             	and    $0x3,%eax
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	75 21                	jne    800bc0 <memmove+0xbf>
  800b9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba2:	83 e0 03             	and    $0x3,%eax
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	75 17                	jne    800bc0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bac:	c1 e8 02             	shr    $0x2,%eax
  800baf:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bb7:	89 c7                	mov    %eax,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	fc                   	cld    
  800bbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbe:	eb 10                	jmp    800bd0 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	fc                   	cld    
  800bce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800bd0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be1:	8b 45 10             	mov    0x10(%ebp),%eax
  800be4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800beb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	89 04 24             	mov    %eax,(%esp)
  800bf5:	e8 07 ff ff ff       	call   800b01 <memmove>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c0e:	eb 30                	jmp    800c40 <memcmp+0x44>
		if (*s1 != *s2)
  800c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c13:	0f b6 10             	movzbl (%eax),%edx
  800c16:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c19:	0f b6 00             	movzbl (%eax),%eax
  800c1c:	38 c2                	cmp    %al,%dl
  800c1e:	74 18                	je     800c38 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800c20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c23:	0f b6 00             	movzbl (%eax),%eax
  800c26:	0f b6 d0             	movzbl %al,%edx
  800c29:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c2c:	0f b6 00             	movzbl (%eax),%eax
  800c2f:	0f b6 c0             	movzbl %al,%eax
  800c32:	29 c2                	sub    %eax,%edx
  800c34:	89 d0                	mov    %edx,%eax
  800c36:	eb 1a                	jmp    800c52 <memcmp+0x56>
		s1++, s2++;
  800c38:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c3c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c40:	8b 45 10             	mov    0x10(%ebp),%eax
  800c43:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c46:	89 55 10             	mov    %edx,0x10(%ebp)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	75 c3                	jne    800c10 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c60:	01 d0                	add    %edx,%eax
  800c62:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c65:	eb 13                	jmp    800c7a <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	0f b6 10             	movzbl (%eax),%edx
  800c6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c70:	38 c2                	cmp    %al,%dl
  800c72:	75 02                	jne    800c76 <memfind+0x22>
			break;
  800c74:	eb 0c                	jmp    800c82 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c76:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c80:	72 e5                	jb     800c67 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c8d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c94:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	eb 04                	jmp    800ca1 <strtol+0x1a>
		s++;
  800c9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	0f b6 00             	movzbl (%eax),%eax
  800ca7:	3c 20                	cmp    $0x20,%al
  800ca9:	74 f2                	je     800c9d <strtol+0x16>
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	0f b6 00             	movzbl (%eax),%eax
  800cb1:	3c 09                	cmp    $0x9,%al
  800cb3:	74 e8                	je     800c9d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	0f b6 00             	movzbl (%eax),%eax
  800cbb:	3c 2b                	cmp    $0x2b,%al
  800cbd:	75 06                	jne    800cc5 <strtol+0x3e>
		s++;
  800cbf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cc3:	eb 15                	jmp    800cda <strtol+0x53>
	else if (*s == '-')
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	0f b6 00             	movzbl (%eax),%eax
  800ccb:	3c 2d                	cmp    $0x2d,%al
  800ccd:	75 0b                	jne    800cda <strtol+0x53>
		s++, neg = 1;
  800ccf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cd3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cde:	74 06                	je     800ce6 <strtol+0x5f>
  800ce0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ce4:	75 24                	jne    800d0a <strtol+0x83>
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	0f b6 00             	movzbl (%eax),%eax
  800cec:	3c 30                	cmp    $0x30,%al
  800cee:	75 1a                	jne    800d0a <strtol+0x83>
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	83 c0 01             	add    $0x1,%eax
  800cf6:	0f b6 00             	movzbl (%eax),%eax
  800cf9:	3c 78                	cmp    $0x78,%al
  800cfb:	75 0d                	jne    800d0a <strtol+0x83>
		s += 2, base = 16;
  800cfd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d01:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d08:	eb 2a                	jmp    800d34 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800d0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0e:	75 17                	jne    800d27 <strtol+0xa0>
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	0f b6 00             	movzbl (%eax),%eax
  800d16:	3c 30                	cmp    $0x30,%al
  800d18:	75 0d                	jne    800d27 <strtol+0xa0>
		s++, base = 8;
  800d1a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d1e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d25:	eb 0d                	jmp    800d34 <strtol+0xad>
	else if (base == 0)
  800d27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d2b:	75 07                	jne    800d34 <strtol+0xad>
		base = 10;
  800d2d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	0f b6 00             	movzbl (%eax),%eax
  800d3a:	3c 2f                	cmp    $0x2f,%al
  800d3c:	7e 1b                	jle    800d59 <strtol+0xd2>
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	0f b6 00             	movzbl (%eax),%eax
  800d44:	3c 39                	cmp    $0x39,%al
  800d46:	7f 11                	jg     800d59 <strtol+0xd2>
			dig = *s - '0';
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	0f b6 00             	movzbl (%eax),%eax
  800d4e:	0f be c0             	movsbl %al,%eax
  800d51:	83 e8 30             	sub    $0x30,%eax
  800d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d57:	eb 48                	jmp    800da1 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	0f b6 00             	movzbl (%eax),%eax
  800d5f:	3c 60                	cmp    $0x60,%al
  800d61:	7e 1b                	jle    800d7e <strtol+0xf7>
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	3c 7a                	cmp    $0x7a,%al
  800d6b:	7f 11                	jg     800d7e <strtol+0xf7>
			dig = *s - 'a' + 10;
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	0f b6 00             	movzbl (%eax),%eax
  800d73:	0f be c0             	movsbl %al,%eax
  800d76:	83 e8 57             	sub    $0x57,%eax
  800d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d7c:	eb 23                	jmp    800da1 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	0f b6 00             	movzbl (%eax),%eax
  800d84:	3c 40                	cmp    $0x40,%al
  800d86:	7e 3d                	jle    800dc5 <strtol+0x13e>
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	0f b6 00             	movzbl (%eax),%eax
  800d8e:	3c 5a                	cmp    $0x5a,%al
  800d90:	7f 33                	jg     800dc5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	0f b6 00             	movzbl (%eax),%eax
  800d98:	0f be c0             	movsbl %al,%eax
  800d9b:	83 e8 37             	sub    $0x37,%eax
  800d9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800da7:	7c 02                	jl     800dab <strtol+0x124>
			break;
  800da9:	eb 1a                	jmp    800dc5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800dab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800daf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800db2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800db6:	89 c2                	mov    %eax,%edx
  800db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dbb:	01 d0                	add    %edx,%eax
  800dbd:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dc0:	e9 6f ff ff ff       	jmp    800d34 <strtol+0xad>

	if (endptr)
  800dc5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc9:	74 08                	je     800dd3 <strtol+0x14c>
		*endptr = (char *) s;
  800dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dd3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dd7:	74 07                	je     800de0 <strtol+0x159>
  800dd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ddc:	f7 d8                	neg    %eax
  800dde:	eb 03                	jmp    800de3 <strtol+0x15c>
  800de0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	8b 55 10             	mov    0x10(%ebp),%edx
  800df4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800df7:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800dfa:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800dfd:	8b 75 20             	mov    0x20(%ebp),%esi
  800e00:	cd 30                	int    $0x30
  800e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e09:	74 30                	je     800e3b <syscall+0x56>
  800e0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e0f:	7e 2a                	jle    800e3b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1f:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2e:	00 
  800e2f:	c7 04 24 61 19 80 00 	movl   $0x801961,(%esp)
  800e36:	e8 82 05 00 00       	call   8013bd <_panic>

	return ret;
  800e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800e3e:	83 c4 3c             	add    $0x3c,%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e56:	00 
  800e57:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800e66:	00 
  800e67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e6e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e79:	00 
  800e7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e81:	e8 5f ff ff ff       	call   800de5 <syscall>
}
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e8e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800e95:	00 
  800e96:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800ea5:	00 
  800ea6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ead:	00 
  800eae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ec5:	e8 1b ff ff ff       	call   800de5 <syscall>
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800edc:	00 
  800edd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800eec:	00 
  800eed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ef4:	00 
  800ef5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800f08:	e8 d8 fe ff ff       	call   800de5 <syscall>
}
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f15:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f24:	00 
  800f25:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f34:	00 
  800f35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f44:	00 
  800f45:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f4c:	e8 94 fe ff ff       	call   800de5 <syscall>
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <sys_yield>:

void
sys_yield(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f59:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f60:	00 
  800f61:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f68:	00 
  800f69:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f70:	00 
  800f71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800f90:	e8 50 fe ff ff       	call   800de5 <syscall>
}
  800f95:	c9                   	leave  
  800f96:	c3                   	ret    

00800f97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fad:	00 
  800fae:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fb5:	00 
  800fb6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fbe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fc9:	00 
  800fca:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800fd1:	e8 0f fe ff ff       	call   800de5 <syscall>
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800fe0:	8b 75 18             	mov    0x18(%ebp),%esi
  800fe3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fe6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fec:	8b 45 08             	mov    0x8(%ebp),%eax
  800fef:	89 74 24 18          	mov    %esi,0x18(%esp)
  800ff3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800ff7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ffb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801003:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80100a:	00 
  80100b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801012:	e8 ce fd ff ff       	call   800de5 <syscall>
}
  801017:	83 c4 20             	add    $0x20,%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801024:	8b 55 0c             	mov    0xc(%ebp),%edx
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
  80102a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801031:	00 
  801032:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801039:	00 
  80103a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801041:	00 
  801042:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801046:	89 44 24 08          	mov    %eax,0x8(%esp)
  80104a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801051:	00 
  801052:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801059:	e8 87 fd ff ff       	call   800de5 <syscall>
}
  80105e:	c9                   	leave  
  80105f:	c3                   	ret    

00801060 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801066:	8b 55 0c             	mov    0xc(%ebp),%edx
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801073:	00 
  801074:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80107b:	00 
  80107c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801083:	00 
  801084:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801093:	00 
  801094:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80109b:	e8 45 fd ff ff       	call   800de5 <syscall>
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010bd:	00 
  8010be:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8010c5:	00 
  8010c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010d5:	00 
  8010d6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8010dd:	e8 03 fd ff ff       	call   800de5 <syscall>
}
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010ea:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8010ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8010fa:	00 
  8010fb:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8010ff:	89 54 24 10          	mov    %edx,0x10(%esp)
  801103:	8b 55 0c             	mov    0xc(%ebp),%edx
  801106:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80110a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801115:	00 
  801116:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80111d:	e8 c3 fc ff ff       	call   800de5 <syscall>
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801134:	00 
  801135:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80113c:	00 
  80113d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801144:	00 
  801145:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80114c:	00 
  80114d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801151:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801160:	e8 80 fc ff ff       	call   800de5 <syscall>
}
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <sys_exec>:

void sys_exec(char* buf){
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80116d:	8b 45 08             	mov    0x8(%ebp),%eax
  801170:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801177:	00 
  801178:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80117f:	00 
  801180:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801187:	00 
  801188:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80118f:	00 
  801190:	89 44 24 08          	mov    %eax,0x8(%esp)
  801194:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80119b:	00 
  80119c:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  8011a3:	e8 3d fc ff ff       	call   800de5 <syscall>
}
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <sys_wait>:

void sys_wait(){
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  8011b0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d7:	00 
  8011d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011df:	00 
  8011e0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8011e7:	e8 f9 fb ff ff       	call   800de5 <syscall>
}
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <sys_guest>:

void sys_guest(){
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8011f4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801203:	00 
  801204:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80120b:	00 
  80120c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801213:	00 
  801214:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80121b:	00 
  80121c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801223:	00 
  801224:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  80122b:	e8 b5 fb ff ff       	call   800de5 <syscall>
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_dstva;
	if(!pg){
  801238:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80123c:	75 09                	jne    801247 <ipc_recv+0x15>
		i_dstva = UTOP;
  80123e:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
  801245:	eb 06                	jmp    80124d <ipc_recv+0x1b>
	}
	else{
		i_dstva = (uint32_t)pg;
  801247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	}
	int r = sys_ipc_recv((void *)i_dstva);
  80124d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801250:	89 04 24             	mov    %eax,(%esp)
  801253:	e8 cc fe ff ff       	call   801124 <sys_ipc_recv>
  801258:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(r == 0 && from_env_store) *from_env_store = thisenv->env_ipc_from;
  80125b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80125f:	75 15                	jne    801276 <ipc_recv+0x44>
  801261:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801265:	74 0f                	je     801276 <ipc_recv+0x44>
  801267:	a1 04 20 80 00       	mov    0x802004,%eax
  80126c:	8b 50 74             	mov    0x74(%eax),%edx
  80126f:	8b 45 08             	mov    0x8(%ebp),%eax
  801272:	89 10                	mov    %edx,(%eax)
  801274:	eb 15                	jmp    80128b <ipc_recv+0x59>
	else if(r < 0 && from_env_store) *from_env_store = 0;
  801276:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80127a:	79 0f                	jns    80128b <ipc_recv+0x59>
  80127c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801280:	74 09                	je     80128b <ipc_recv+0x59>
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
  801285:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0 && perm_store) *perm_store = thisenv->env_ipc_perm;
  80128b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80128f:	75 15                	jne    8012a6 <ipc_recv+0x74>
  801291:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801295:	74 0f                	je     8012a6 <ipc_recv+0x74>
  801297:	a1 04 20 80 00       	mov    0x802004,%eax
  80129c:	8b 50 78             	mov    0x78(%eax),%edx
  80129f:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a2:	89 10                	mov    %edx,(%eax)
  8012a4:	eb 15                	jmp    8012bb <ipc_recv+0x89>
	else if(r < 0 && perm_store) *perm_store = 0;
  8012a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8012aa:	79 0f                	jns    8012bb <ipc_recv+0x89>
  8012ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012b0:	74 09                	je     8012bb <ipc_recv+0x89>
  8012b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	if(r == 0) return thisenv->env_ipc_value;
  8012bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8012bf:	75 0a                	jne    8012cb <ipc_recv+0x99>
  8012c1:	a1 04 20 80 00       	mov    0x802004,%eax
  8012c6:	8b 40 70             	mov    0x70(%eax),%eax
  8012c9:	eb 03                	jmp    8012ce <ipc_recv+0x9c>
	else return r;
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("ipc_recv not implemented");
	// return 0;
}
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
  8012d6:	c7 45 f4 00 00 c0 ee 	movl   $0xeec00000,-0xc(%ebp)
	if(pg) i_srcva = (uint32_t)pg;
  8012dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012e1:	74 06                	je     8012e9 <ipc_send+0x19>
  8012e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  8012e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8012ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801301:	89 04 24             	mov    %eax,(%esp)
  801304:	e8 db fd ff ff       	call   8010e4 <sys_ipc_try_send>
  801309:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while(r == -E_IPC_NOT_RECV){
  80130c:	eb 28                	jmp    801336 <ipc_send+0x66>
		sys_yield();
  80130e:	e8 40 fc ff ff       	call   800f53 <sys_yield>
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
  801313:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801316:	8b 55 14             	mov    0x14(%ebp),%edx
  801319:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80131d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	89 44 24 04          	mov    %eax,0x4(%esp)
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 b1 fd ff ff       	call   8010e4 <sys_ipc_try_send>
  801333:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// LAB 4: Your code here.
	uint32_t i_srcva = UTOP;
	if(pg) i_srcva = (uint32_t)pg;
	int r;
	r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	while(r == -E_IPC_NOT_RECV){
  801336:	83 7d f0 f8          	cmpl   $0xfffffff8,-0x10(%ebp)
  80133a:	74 d2                	je     80130e <ipc_send+0x3e>
		sys_yield();
		r = sys_ipc_try_send(to_env, val, (void *)i_srcva, perm);
	}
	if(r == 0) return;
  80133c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801340:	75 02                	jne    801344 <ipc_send+0x74>
  801342:	eb 23                	jmp    801367 <ipc_send+0x97>
	else panic("ipc_send sys_ipc_try_send error: %e\n",r);
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134b:	c7 44 24 08 70 19 80 	movl   $0x801970,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 95 19 80 00 	movl   $0x801995,(%esp)
  801362:	e8 56 00 00 00       	call   8013bd <_panic>
	panic("ipc_send not implemented");
}
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 10             	sub    $0x10,%esp
	int i;
	for (i = 0; i < NENV; i++)
  80136f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801376:	eb 35                	jmp    8013ad <ipc_find_env+0x44>
		if (envs[i].env_type == type)
  801378:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80137b:	c1 e0 02             	shl    $0x2,%eax
  80137e:	89 c2                	mov    %eax,%edx
  801380:	c1 e2 05             	shl    $0x5,%edx
  801383:	29 c2                	sub    %eax,%edx
  801385:	8d 82 50 00 c0 ee    	lea    -0x113fffb0(%edx),%eax
  80138b:	8b 00                	mov    (%eax),%eax
  80138d:	3b 45 08             	cmp    0x8(%ebp),%eax
  801390:	75 17                	jne    8013a9 <ipc_find_env+0x40>
			return envs[i].env_id;
  801392:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801395:	c1 e0 02             	shl    $0x2,%eax
  801398:	89 c2                	mov    %eax,%edx
  80139a:	c1 e2 05             	shl    $0x5,%edx
  80139d:	29 c2                	sub    %eax,%edx
  80139f:	8d 82 48 00 c0 ee    	lea    -0x113fffb8(%edx),%eax
  8013a5:	8b 00                	mov    (%eax),%eax
  8013a7:	eb 12                	jmp    8013bb <ipc_find_env+0x52>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013a9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8013ad:	81 7d fc ff 03 00 00 	cmpl   $0x3ff,-0x4(%ebp)
  8013b4:	7e c2                	jle    801378 <ipc_find_env+0xf>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8013c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8013c7:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ca:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013d0:	e8 3a fb ff ff       	call   800f0f <sys_getenvid>
  8013d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	c7 04 24 a0 19 80 00 	movl   $0x8019a0,(%esp)
  8013f2:	e8 e3 ed ff ff       	call   8001da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801401:	89 04 24             	mov    %eax,(%esp)
  801404:	e8 6d ed ff ff       	call   800176 <vcprintf>
	cprintf("\n");
  801409:	c7 04 24 c3 19 80 00 	movl   $0x8019c3,(%esp)
  801410:	e8 c5 ed ff ff       	call   8001da <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801415:	cc                   	int3   
  801416:	eb fd                	jmp    801415 <_panic+0x58>
  801418:	66 90                	xchg   %ax,%ax
  80141a:	66 90                	xchg   %ax,%ax
  80141c:	66 90                	xchg   %ax,%ax
  80141e:	66 90                	xchg   %ax,%ax

00801420 <__udivdi3>:
  801420:	55                   	push   %ebp
  801421:	57                   	push   %edi
  801422:	56                   	push   %esi
  801423:	83 ec 0c             	sub    $0xc,%esp
  801426:	8b 44 24 28          	mov    0x28(%esp),%eax
  80142a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80142e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801432:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801436:	85 c0                	test   %eax,%eax
  801438:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80143c:	89 ea                	mov    %ebp,%edx
  80143e:	89 0c 24             	mov    %ecx,(%esp)
  801441:	75 2d                	jne    801470 <__udivdi3+0x50>
  801443:	39 e9                	cmp    %ebp,%ecx
  801445:	77 61                	ja     8014a8 <__udivdi3+0x88>
  801447:	85 c9                	test   %ecx,%ecx
  801449:	89 ce                	mov    %ecx,%esi
  80144b:	75 0b                	jne    801458 <__udivdi3+0x38>
  80144d:	b8 01 00 00 00       	mov    $0x1,%eax
  801452:	31 d2                	xor    %edx,%edx
  801454:	f7 f1                	div    %ecx
  801456:	89 c6                	mov    %eax,%esi
  801458:	31 d2                	xor    %edx,%edx
  80145a:	89 e8                	mov    %ebp,%eax
  80145c:	f7 f6                	div    %esi
  80145e:	89 c5                	mov    %eax,%ebp
  801460:	89 f8                	mov    %edi,%eax
  801462:	f7 f6                	div    %esi
  801464:	89 ea                	mov    %ebp,%edx
  801466:	83 c4 0c             	add    $0xc,%esp
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    
  80146d:	8d 76 00             	lea    0x0(%esi),%esi
  801470:	39 e8                	cmp    %ebp,%eax
  801472:	77 24                	ja     801498 <__udivdi3+0x78>
  801474:	0f bd e8             	bsr    %eax,%ebp
  801477:	83 f5 1f             	xor    $0x1f,%ebp
  80147a:	75 3c                	jne    8014b8 <__udivdi3+0x98>
  80147c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801480:	39 34 24             	cmp    %esi,(%esp)
  801483:	0f 86 9f 00 00 00    	jbe    801528 <__udivdi3+0x108>
  801489:	39 d0                	cmp    %edx,%eax
  80148b:	0f 82 97 00 00 00    	jb     801528 <__udivdi3+0x108>
  801491:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	31 c0                	xor    %eax,%eax
  80149c:	83 c4 0c             	add    $0xc,%esp
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
  8014a3:	90                   	nop
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	89 f8                	mov    %edi,%eax
  8014aa:	f7 f1                	div    %ecx
  8014ac:	31 d2                	xor    %edx,%edx
  8014ae:	83 c4 0c             	add    $0xc,%esp
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    
  8014b5:	8d 76 00             	lea    0x0(%esi),%esi
  8014b8:	89 e9                	mov    %ebp,%ecx
  8014ba:	8b 3c 24             	mov    (%esp),%edi
  8014bd:	d3 e0                	shl    %cl,%eax
  8014bf:	89 c6                	mov    %eax,%esi
  8014c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c6:	29 e8                	sub    %ebp,%eax
  8014c8:	89 c1                	mov    %eax,%ecx
  8014ca:	d3 ef                	shr    %cl,%edi
  8014cc:	89 e9                	mov    %ebp,%ecx
  8014ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8014d2:	8b 3c 24             	mov    (%esp),%edi
  8014d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8014d9:	89 d6                	mov    %edx,%esi
  8014db:	d3 e7                	shl    %cl,%edi
  8014dd:	89 c1                	mov    %eax,%ecx
  8014df:	89 3c 24             	mov    %edi,(%esp)
  8014e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014e6:	d3 ee                	shr    %cl,%esi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	d3 e2                	shl    %cl,%edx
  8014ec:	89 c1                	mov    %eax,%ecx
  8014ee:	d3 ef                	shr    %cl,%edi
  8014f0:	09 d7                	or     %edx,%edi
  8014f2:	89 f2                	mov    %esi,%edx
  8014f4:	89 f8                	mov    %edi,%eax
  8014f6:	f7 74 24 08          	divl   0x8(%esp)
  8014fa:	89 d6                	mov    %edx,%esi
  8014fc:	89 c7                	mov    %eax,%edi
  8014fe:	f7 24 24             	mull   (%esp)
  801501:	39 d6                	cmp    %edx,%esi
  801503:	89 14 24             	mov    %edx,(%esp)
  801506:	72 30                	jb     801538 <__udivdi3+0x118>
  801508:	8b 54 24 04          	mov    0x4(%esp),%edx
  80150c:	89 e9                	mov    %ebp,%ecx
  80150e:	d3 e2                	shl    %cl,%edx
  801510:	39 c2                	cmp    %eax,%edx
  801512:	73 05                	jae    801519 <__udivdi3+0xf9>
  801514:	3b 34 24             	cmp    (%esp),%esi
  801517:	74 1f                	je     801538 <__udivdi3+0x118>
  801519:	89 f8                	mov    %edi,%eax
  80151b:	31 d2                	xor    %edx,%edx
  80151d:	e9 7a ff ff ff       	jmp    80149c <__udivdi3+0x7c>
  801522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801528:	31 d2                	xor    %edx,%edx
  80152a:	b8 01 00 00 00       	mov    $0x1,%eax
  80152f:	e9 68 ff ff ff       	jmp    80149c <__udivdi3+0x7c>
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	8d 47 ff             	lea    -0x1(%edi),%eax
  80153b:	31 d2                	xor    %edx,%edx
  80153d:	83 c4 0c             	add    $0xc,%esp
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
  801544:	66 90                	xchg   %ax,%ax
  801546:	66 90                	xchg   %ax,%ax
  801548:	66 90                	xchg   %ax,%ax
  80154a:	66 90                	xchg   %ax,%ax
  80154c:	66 90                	xchg   %ax,%ax
  80154e:	66 90                	xchg   %ax,%ax

00801550 <__umoddi3>:
  801550:	55                   	push   %ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	83 ec 14             	sub    $0x14,%esp
  801556:	8b 44 24 28          	mov    0x28(%esp),%eax
  80155a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80155e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801562:	89 c7                	mov    %eax,%edi
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	8b 44 24 30          	mov    0x30(%esp),%eax
  80156c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801570:	89 34 24             	mov    %esi,(%esp)
  801573:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801577:	85 c0                	test   %eax,%eax
  801579:	89 c2                	mov    %eax,%edx
  80157b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80157f:	75 17                	jne    801598 <__umoddi3+0x48>
  801581:	39 fe                	cmp    %edi,%esi
  801583:	76 4b                	jbe    8015d0 <__umoddi3+0x80>
  801585:	89 c8                	mov    %ecx,%eax
  801587:	89 fa                	mov    %edi,%edx
  801589:	f7 f6                	div    %esi
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	31 d2                	xor    %edx,%edx
  80158f:	83 c4 14             	add    $0x14,%esp
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    
  801596:	66 90                	xchg   %ax,%ax
  801598:	39 f8                	cmp    %edi,%eax
  80159a:	77 54                	ja     8015f0 <__umoddi3+0xa0>
  80159c:	0f bd e8             	bsr    %eax,%ebp
  80159f:	83 f5 1f             	xor    $0x1f,%ebp
  8015a2:	75 5c                	jne    801600 <__umoddi3+0xb0>
  8015a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8015a8:	39 3c 24             	cmp    %edi,(%esp)
  8015ab:	0f 87 e7 00 00 00    	ja     801698 <__umoddi3+0x148>
  8015b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015b5:	29 f1                	sub    %esi,%ecx
  8015b7:	19 c7                	sbb    %eax,%edi
  8015b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8015c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8015c9:	83 c4 14             	add    $0x14,%esp
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    
  8015d0:	85 f6                	test   %esi,%esi
  8015d2:	89 f5                	mov    %esi,%ebp
  8015d4:	75 0b                	jne    8015e1 <__umoddi3+0x91>
  8015d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8015db:	31 d2                	xor    %edx,%edx
  8015dd:	f7 f6                	div    %esi
  8015df:	89 c5                	mov    %eax,%ebp
  8015e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8015e5:	31 d2                	xor    %edx,%edx
  8015e7:	f7 f5                	div    %ebp
  8015e9:	89 c8                	mov    %ecx,%eax
  8015eb:	f7 f5                	div    %ebp
  8015ed:	eb 9c                	jmp    80158b <__umoddi3+0x3b>
  8015ef:	90                   	nop
  8015f0:	89 c8                	mov    %ecx,%eax
  8015f2:	89 fa                	mov    %edi,%edx
  8015f4:	83 c4 14             	add    $0x14,%esp
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    
  8015fb:	90                   	nop
  8015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801600:	8b 04 24             	mov    (%esp),%eax
  801603:	be 20 00 00 00       	mov    $0x20,%esi
  801608:	89 e9                	mov    %ebp,%ecx
  80160a:	29 ee                	sub    %ebp,%esi
  80160c:	d3 e2                	shl    %cl,%edx
  80160e:	89 f1                	mov    %esi,%ecx
  801610:	d3 e8                	shr    %cl,%eax
  801612:	89 e9                	mov    %ebp,%ecx
  801614:	89 44 24 04          	mov    %eax,0x4(%esp)
  801618:	8b 04 24             	mov    (%esp),%eax
  80161b:	09 54 24 04          	or     %edx,0x4(%esp)
  80161f:	89 fa                	mov    %edi,%edx
  801621:	d3 e0                	shl    %cl,%eax
  801623:	89 f1                	mov    %esi,%ecx
  801625:	89 44 24 08          	mov    %eax,0x8(%esp)
  801629:	8b 44 24 10          	mov    0x10(%esp),%eax
  80162d:	d3 ea                	shr    %cl,%edx
  80162f:	89 e9                	mov    %ebp,%ecx
  801631:	d3 e7                	shl    %cl,%edi
  801633:	89 f1                	mov    %esi,%ecx
  801635:	d3 e8                	shr    %cl,%eax
  801637:	89 e9                	mov    %ebp,%ecx
  801639:	09 f8                	or     %edi,%eax
  80163b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80163f:	f7 74 24 04          	divl   0x4(%esp)
  801643:	d3 e7                	shl    %cl,%edi
  801645:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801649:	89 d7                	mov    %edx,%edi
  80164b:	f7 64 24 08          	mull   0x8(%esp)
  80164f:	39 d7                	cmp    %edx,%edi
  801651:	89 c1                	mov    %eax,%ecx
  801653:	89 14 24             	mov    %edx,(%esp)
  801656:	72 2c                	jb     801684 <__umoddi3+0x134>
  801658:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80165c:	72 22                	jb     801680 <__umoddi3+0x130>
  80165e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801662:	29 c8                	sub    %ecx,%eax
  801664:	19 d7                	sbb    %edx,%edi
  801666:	89 e9                	mov    %ebp,%ecx
  801668:	89 fa                	mov    %edi,%edx
  80166a:	d3 e8                	shr    %cl,%eax
  80166c:	89 f1                	mov    %esi,%ecx
  80166e:	d3 e2                	shl    %cl,%edx
  801670:	89 e9                	mov    %ebp,%ecx
  801672:	d3 ef                	shr    %cl,%edi
  801674:	09 d0                	or     %edx,%eax
  801676:	89 fa                	mov    %edi,%edx
  801678:	83 c4 14             	add    $0x14,%esp
  80167b:	5e                   	pop    %esi
  80167c:	5f                   	pop    %edi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    
  80167f:	90                   	nop
  801680:	39 d7                	cmp    %edx,%edi
  801682:	75 da                	jne    80165e <__umoddi3+0x10e>
  801684:	8b 14 24             	mov    (%esp),%edx
  801687:	89 c1                	mov    %eax,%ecx
  801689:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80168d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801691:	eb cb                	jmp    80165e <__umoddi3+0x10e>
  801693:	90                   	nop
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80169c:	0f 82 0f ff ff ff    	jb     8015b1 <__umoddi3+0x61>
  8016a2:	e9 1a ff ff ff       	jmp    8015c1 <__umoddi3+0x71>
