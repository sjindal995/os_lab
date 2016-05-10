
obj/user/sh:     file format elf32-i386


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
	char* buf;
	uint32_t parent_id;
	while(1){
		// cprintf("inside parent environment: %08x\n", thisenv->env_id);
		buf = readline("U> ");
  800039:	c7 04 24 80 1b 80 00 	movl   $0x801b80,(%esp)
  800040:	e8 0c 08 00 00       	call   800851 <readline>
  800045:	89 45 f4             	mov    %eax,-0xc(%ebp)
		// cprintf("proceeding in env: ", thisenv->env_id);
		parent_id = thisenv->env_id;
  800048:	a1 20 34 80 00       	mov    0x803420,%eax
  80004d:	8b 40 48             	mov    0x48(%eax),%eax
  800050:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if(buf == NULL)
  800053:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800057:	75 02                	jne    80005b <umain+0x28>
			break;
  800059:	eb 6a                	jmp    8000c5 <umain+0x92>
		if(fork()==0){
  80005b:	e8 a0 15 00 00       	call   801600 <fork>
  800060:	85 c0                	test   %eax,%eax
  800062:	75 38                	jne    80009c <umain+0x69>
			cprintf("inside process with PID: %08x\n", thisenv->env_id);
  800064:	a1 20 34 80 00       	mov    0x803420,%eax
  800069:	8b 40 48             	mov    0x48(%eax),%eax
  80006c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800070:	c7 04 24 84 1b 80 00 	movl   $0x801b84,(%esp)
  800077:	e8 5e 01 00 00       	call   8001da <cprintf>
			cprintf("inside process with parent PID: %08x\n", parent_id);
  80007c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80007f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800083:	c7 04 24 a4 1b 80 00 	movl   $0x801ba4,(%esp)
  80008a:	e8 4b 01 00 00       	call   8001da <cprintf>
			sys_exec(buf);
  80008f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800092:	89 04 24             	mov    %eax,(%esp)
  800095:	e8 ba 11 00 00       	call   801254 <sys_exec>
  80009a:	eb 24                	jmp    8000c0 <umain+0x8d>
			// cprintf("\n\nbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n\n");
		}
		else{
			if(buf[strlen(buf)-1] != '&'){
  80009c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 97 08 00 00       	call   80093e <strlen>
  8000a7:	8d 50 ff             	lea    -0x1(%eax),%edx
  8000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000ad:	01 d0                	add    %edx,%eax
  8000af:	0f b6 00             	movzbl (%eax),%eax
  8000b2:	3c 26                	cmp    $0x26,%al
  8000b4:	74 0a                	je     8000c0 <umain+0x8d>
				sys_wait();
  8000b6:	e8 dc 11 00 00       	call   801297 <sys_wait>
			}
		}
	}
  8000bb:	e9 79 ff ff ff       	jmp    800039 <umain+0x6>
  8000c0:	e9 74 ff ff ff       	jmp    800039 <umain+0x6>
}
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

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
  8000cd:	e8 2a 0f 00 00       	call   800ffc <sys_getenvid>
  8000d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d7:	c1 e0 02             	shl    $0x2,%eax
  8000da:	89 c2                	mov    %eax,%edx
  8000dc:	c1 e2 05             	shl    $0x5,%edx
  8000df:	29 c2                	sub    %eax,%edx
  8000e1:	89 d0                	mov    %edx,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 20 34 80 00       	mov    %eax,0x803420
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
  800113:	e8 a1 0e 00 00       	call   800fb9 <sys_env_destroy>
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
  800157:	e8 d7 0d 00 00       	call   800f33 <sys_cputs>
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
  8001cd:	e8 61 0d 00 00       	call   800f33 <sys_cputs>

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
  80024d:	e8 9e 16 00 00       	call   8018f0 <__udivdi3>
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
  8002b9:	e8 62 17 00 00       	call   801a20 <__umoddi3>
  8002be:	05 a8 1c 80 00       	add    $0x801ca8,%eax
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
  8003e5:	8b 04 85 cc 1c 80 00 	mov    0x801ccc(,%eax,4),%eax
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
  8004be:	8b 34 9d 80 1c 80 00 	mov    0x801c80(,%ebx,4),%esi
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004cd:	c7 44 24 08 b9 1c 80 	movl   $0x801cb9,0x8(%esp)
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
  8004f0:	c7 44 24 08 c2 1c 80 	movl   $0x801cc2,0x8(%esp)
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
  80051e:	be c5 1c 80 00       	mov    $0x801cc5,%esi
			if (width > 0 && padc != '-')
  800523:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800527:	7e 37                	jle    800560 <vprintfmt+0x1ec>
  800529:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80052d:	74 31                	je     800560 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	89 34 24             	mov    %esi,(%esp)
  800539:	e8 26 04 00 00       	call   800964 <strnlen>
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

00800851 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 28             	sub    $0x28,%esp
	int i, c, echoing;

	if (prompt != NULL)
  800857:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80085b:	74 13                	je     800870 <readline+0x1f>
		cprintf("%s", prompt);
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	c7 04 24 24 1e 80 00 	movl   $0x801e24,(%esp)
  80086b:	e8 6a f9 ff ff       	call   8001da <cprintf>

	i = 0;
  800870:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// echoing = iscons(0);
	echoing = 1;
  800877:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	while (1) {
		c = getchar();
  80087e:	e8 52 0f 00 00       	call   8017d5 <getchar>
  800883:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
  800886:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80088a:	79 1d                	jns    8008a9 <readline+0x58>
			cprintf("read error: %e\n", c);
  80088c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	c7 04 24 27 1e 80 00 	movl   $0x801e27,(%esp)
  80089a:	e8 3b f9 ff ff       	call   8001da <cprintf>
			return NULL;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	e9 93 00 00 00       	jmp    80093c <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8008a9:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  8008ad:	74 06                	je     8008b5 <readline+0x64>
  8008af:	83 7d ec 7f          	cmpl   $0x7f,-0x14(%ebp)
  8008b3:	75 1e                	jne    8008d3 <readline+0x82>
  8008b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8008b9:	7e 18                	jle    8008d3 <readline+0x82>
			if (echoing)
  8008bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008bf:	74 0c                	je     8008cd <readline+0x7c>
				cputchar('\b');
  8008c1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  8008c8:	e8 e7 0e 00 00       	call   8017b4 <cputchar>
			i--;
  8008cd:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  8008d1:	eb 64                	jmp    800937 <readline+0xe6>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8008d3:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  8008d7:	7e 2e                	jle    800907 <readline+0xb6>
  8008d9:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  8008e0:	7f 25                	jg     800907 <readline+0xb6>
			if (echoing)
  8008e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008e6:	74 0b                	je     8008f3 <readline+0xa2>
				cputchar(c);
  8008e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	e8 c1 0e 00 00       	call   8017b4 <cputchar>
			buf[i++] = c;
  8008f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f6:	8d 50 01             	lea    0x1(%eax),%edx
  8008f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008ff:	88 90 20 30 80 00    	mov    %dl,0x803020(%eax)
  800905:	eb 30                	jmp    800937 <readline+0xe6>
		} else if (c == '\n' || c == '\r') {
  800907:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  80090b:	74 06                	je     800913 <readline+0xc2>
  80090d:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  800911:	75 24                	jne    800937 <readline+0xe6>
			if (echoing)
  800913:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800917:	74 0c                	je     800925 <readline+0xd4>
				cputchar('\n');
  800919:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800920:	e8 8f 0e 00 00       	call   8017b4 <cputchar>
			buf[i] = 0;
  800925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800928:	05 20 30 80 00       	add    $0x803020,%eax
  80092d:	c6 00 00             	movb   $0x0,(%eax)
			return buf;
  800930:	b8 20 30 80 00       	mov    $0x803020,%eax
  800935:	eb 05                	jmp    80093c <readline+0xeb>
		}
	}
  800937:	e9 42 ff ff ff       	jmp    80087e <readline+0x2d>
}
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800944:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80094b:	eb 08                	jmp    800955 <strlen+0x17>
		n++;
  80094d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800951:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	84 c0                	test   %al,%al
  80095d:	75 ee                	jne    80094d <strlen+0xf>
		n++;
	return n;
  80095f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800971:	eb 0c                	jmp    80097f <strnlen+0x1b>
		n++;
  800973:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800977:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80097b:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  80097f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800983:	74 0a                	je     80098f <strnlen+0x2b>
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 00             	movzbl (%eax),%eax
  80098b:	84 c0                	test   %al,%al
  80098d:	75 e4                	jne    800973 <strnlen+0xf>
		n++;
	return n;
  80098f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009a0:	90                   	nop
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8d 50 01             	lea    0x1(%eax),%edx
  8009a7:	89 55 08             	mov    %edx,0x8(%ebp)
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ad:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009b0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009b3:	0f b6 12             	movzbl (%edx),%edx
  8009b6:	88 10                	mov    %dl,(%eax)
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	84 c0                	test   %al,%al
  8009bd:	75 e2                	jne    8009a1 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	89 04 24             	mov    %eax,(%esp)
  8009d0:	e8 69 ff ff ff       	call   80093e <strlen>
  8009d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  8009d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	01 c2                	add    %eax,%edx
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e7:	89 14 24             	mov    %edx,(%esp)
  8009ea:	e8 a5 ff ff ff       	call   800994 <strcpy>
	return dst;
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009f2:	c9                   	leave  
  8009f3:	c3                   	ret    

008009f4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800a00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800a07:	eb 23                	jmp    800a2c <strncpy+0x38>
		*dst++ = *src;
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8d 50 01             	lea    0x1(%eax),%edx
  800a0f:	89 55 08             	mov    %edx,0x8(%ebp)
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a15:	0f b6 12             	movzbl (%edx),%edx
  800a18:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	0f b6 00             	movzbl (%eax),%eax
  800a20:	84 c0                	test   %al,%al
  800a22:	74 04                	je     800a28 <strncpy+0x34>
			src++;
  800a24:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a2f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a32:	72 d5                	jb     800a09 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a34:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a49:	74 33                	je     800a7e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800a4b:	eb 17                	jmp    800a64 <strlcpy+0x2b>
			*dst++ = *src++;
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8d 50 01             	lea    0x1(%eax),%edx
  800a53:	89 55 08             	mov    %edx,0x8(%ebp)
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a59:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a5c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a5f:	0f b6 12             	movzbl (%edx),%edx
  800a62:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a64:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a6c:	74 0a                	je     800a78 <strlcpy+0x3f>
  800a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a71:	0f b6 00             	movzbl (%eax),%eax
  800a74:	84 c0                	test   %al,%al
  800a76:	75 d5                	jne    800a4d <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a84:	29 c2                	sub    %eax,%edx
  800a86:	89 d0                	mov    %edx,%eax
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a8d:	eb 08                	jmp    800a97 <strcmp+0xd>
		p++, q++;
  800a8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800a93:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	0f b6 00             	movzbl (%eax),%eax
  800a9d:	84 c0                	test   %al,%al
  800a9f:	74 10                	je     800ab1 <strcmp+0x27>
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	0f b6 10             	movzbl (%eax),%edx
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	0f b6 00             	movzbl (%eax),%eax
  800aad:	38 c2                	cmp    %al,%dl
  800aaf:	74 de                	je     800a8f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	0f b6 00             	movzbl (%eax),%eax
  800ab7:	0f b6 d0             	movzbl %al,%edx
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	0f b6 00             	movzbl (%eax),%eax
  800ac0:	0f b6 c0             	movzbl %al,%eax
  800ac3:	29 c2                	sub    %eax,%edx
  800ac5:	89 d0                	mov    %edx,%eax
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800acc:	eb 0c                	jmp    800ada <strncmp+0x11>
		n--, p++, q++;
  800ace:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ad2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ad6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ada:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ade:	74 1a                	je     800afa <strncmp+0x31>
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	0f b6 00             	movzbl (%eax),%eax
  800ae6:	84 c0                	test   %al,%al
  800ae8:	74 10                	je     800afa <strncmp+0x31>
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	0f b6 00             	movzbl (%eax),%eax
  800af6:	38 c2                	cmp    %al,%dl
  800af8:	74 d4                	je     800ace <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800afa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800afe:	75 07                	jne    800b07 <strncmp+0x3e>
		return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	eb 16                	jmp    800b1d <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	0f b6 00             	movzbl (%eax),%eax
  800b0d:	0f b6 d0             	movzbl %al,%edx
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	0f b6 00             	movzbl (%eax),%eax
  800b16:	0f b6 c0             	movzbl %al,%eax
  800b19:	29 c2                	sub    %eax,%edx
  800b1b:	89 d0                	mov    %edx,%eax
}
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 04             	sub    $0x4,%esp
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b2b:	eb 14                	jmp    800b41 <strchr+0x22>
		if (*s == c)
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	0f b6 00             	movzbl (%eax),%eax
  800b33:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b36:	75 05                	jne    800b3d <strchr+0x1e>
			return (char *) s;
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	eb 13                	jmp    800b50 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	0f b6 00             	movzbl (%eax),%eax
  800b47:	84 c0                	test   %al,%al
  800b49:	75 e2                	jne    800b2d <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 04             	sub    $0x4,%esp
  800b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b5e:	eb 11                	jmp    800b71 <strfind+0x1f>
		if (*s == c)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	0f b6 00             	movzbl (%eax),%eax
  800b66:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b69:	75 02                	jne    800b6d <strfind+0x1b>
			break;
  800b6b:	eb 0e                	jmp    800b7b <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b6d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	0f b6 00             	movzbl (%eax),%eax
  800b77:	84 c0                	test   %al,%al
  800b79:	75 e5                	jne    800b60 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
	char *p;

	if (n == 0)
  800b84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b88:	75 05                	jne    800b8f <memset+0xf>
		return v;
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	eb 5c                	jmp    800beb <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	83 e0 03             	and    $0x3,%eax
  800b95:	85 c0                	test   %eax,%eax
  800b97:	75 41                	jne    800bda <memset+0x5a>
  800b99:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9c:	83 e0 03             	and    $0x3,%eax
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	75 37                	jne    800bda <memset+0x5a>
		c &= 0xFF;
  800ba3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	c1 e0 18             	shl    $0x18,%eax
  800bb0:	89 c2                	mov    %eax,%edx
  800bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb5:	c1 e0 10             	shl    $0x10,%eax
  800bb8:	09 c2                	or     %eax,%edx
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	c1 e0 08             	shl    $0x8,%eax
  800bc0:	09 d0                	or     %edx,%eax
  800bc2:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc8:	c1 e8 02             	shr    $0x2,%eax
  800bcb:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	fc                   	cld    
  800bd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd8:	eb 0e                	jmp    800be8 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	fc                   	cld    
  800be6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c09:	73 6d                	jae    800c78 <memmove+0x8a>
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c11:	01 d0                	add    %edx,%eax
  800c13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800c16:	76 60                	jbe    800c78 <memmove+0x8a>
		s += n;
  800c18:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1b:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800c1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c21:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c27:	83 e0 03             	and    $0x3,%eax
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	75 2f                	jne    800c5d <memmove+0x6f>
  800c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c31:	83 e0 03             	and    $0x3,%eax
  800c34:	85 c0                	test   %eax,%eax
  800c36:	75 25                	jne    800c5d <memmove+0x6f>
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3b:	83 e0 03             	and    $0x3,%eax
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	75 1b                	jne    800c5d <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c45:	83 e8 04             	sub    $0x4,%eax
  800c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c4b:	83 ea 04             	sub    $0x4,%edx
  800c4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c51:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c54:	89 c7                	mov    %eax,%edi
  800c56:	89 d6                	mov    %edx,%esi
  800c58:	fd                   	std    
  800c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5b:	eb 18                	jmp    800c75 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c60:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c66:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c69:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6c:	89 d7                	mov    %edx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	89 c1                	mov    %eax,%ecx
  800c72:	fd                   	std    
  800c73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c75:	fc                   	cld    
  800c76:	eb 45                	jmp    800cbd <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c7b:	83 e0 03             	and    $0x3,%eax
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	75 2b                	jne    800cad <memmove+0xbf>
  800c82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c85:	83 e0 03             	and    $0x3,%eax
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 21                	jne    800cad <memmove+0xbf>
  800c8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8f:	83 e0 03             	and    $0x3,%eax
  800c92:	85 c0                	test   %eax,%eax
  800c94:	75 17                	jne    800cad <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c96:	8b 45 10             	mov    0x10(%ebp),%eax
  800c99:	c1 e8 02             	shr    $0x2,%eax
  800c9c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ca1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ca4:	89 c7                	mov    %eax,%edi
  800ca6:	89 d6                	mov    %edx,%esi
  800ca8:	fc                   	cld    
  800ca9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cab:	eb 10                	jmp    800cbd <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800cb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cb6:	89 c7                	mov    %eax,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	fc                   	cld    
  800cbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cc0:	83 c4 10             	add    $0x10,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cce:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	89 04 24             	mov    %eax,(%esp)
  800ce2:	e8 07 ff ff ff       	call   800bee <memmove>
}
  800ce7:	c9                   	leave  
  800ce8:	c3                   	ret    

00800ce9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800cf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf8:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800cfb:	eb 30                	jmp    800d2d <memcmp+0x44>
		if (*s1 != *s2)
  800cfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d00:	0f b6 10             	movzbl (%eax),%edx
  800d03:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d06:	0f b6 00             	movzbl (%eax),%eax
  800d09:	38 c2                	cmp    %al,%dl
  800d0b:	74 18                	je     800d25 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d10:	0f b6 00             	movzbl (%eax),%eax
  800d13:	0f b6 d0             	movzbl %al,%edx
  800d16:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d19:	0f b6 00             	movzbl (%eax),%eax
  800d1c:	0f b6 c0             	movzbl %al,%eax
  800d1f:	29 c2                	sub    %eax,%edx
  800d21:	89 d0                	mov    %edx,%eax
  800d23:	eb 1a                	jmp    800d3f <memcmp+0x56>
		s1++, s2++;
  800d25:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d29:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d30:	8d 50 ff             	lea    -0x1(%eax),%edx
  800d33:	89 55 10             	mov    %edx,0x10(%ebp)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	75 c3                	jne    800cfd <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	01 d0                	add    %edx,%eax
  800d4f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800d52:	eb 13                	jmp    800d67 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	0f b6 10             	movzbl (%eax),%edx
  800d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5d:	38 c2                	cmp    %al,%dl
  800d5f:	75 02                	jne    800d63 <memfind+0x22>
			break;
  800d61:	eb 0c                	jmp    800d6f <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d63:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800d6d:	72 e5                	jb     800d54 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800d7a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800d81:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d88:	eb 04                	jmp    800d8e <strtol+0x1a>
		s++;
  800d8a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	0f b6 00             	movzbl (%eax),%eax
  800d94:	3c 20                	cmp    $0x20,%al
  800d96:	74 f2                	je     800d8a <strtol+0x16>
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	3c 09                	cmp    $0x9,%al
  800da0:	74 e8                	je     800d8a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	0f b6 00             	movzbl (%eax),%eax
  800da8:	3c 2b                	cmp    $0x2b,%al
  800daa:	75 06                	jne    800db2 <strtol+0x3e>
		s++;
  800dac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db0:	eb 15                	jmp    800dc7 <strtol+0x53>
	else if (*s == '-')
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	0f b6 00             	movzbl (%eax),%eax
  800db8:	3c 2d                	cmp    $0x2d,%al
  800dba:	75 0b                	jne    800dc7 <strtol+0x53>
		s++, neg = 1;
  800dbc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dcb:	74 06                	je     800dd3 <strtol+0x5f>
  800dcd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800dd1:	75 24                	jne    800df7 <strtol+0x83>
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	0f b6 00             	movzbl (%eax),%eax
  800dd9:	3c 30                	cmp    $0x30,%al
  800ddb:	75 1a                	jne    800df7 <strtol+0x83>
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	83 c0 01             	add    $0x1,%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	3c 78                	cmp    $0x78,%al
  800de8:	75 0d                	jne    800df7 <strtol+0x83>
		s += 2, base = 16;
  800dea:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800dee:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800df5:	eb 2a                	jmp    800e21 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  800df7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfb:	75 17                	jne    800e14 <strtol+0xa0>
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	0f b6 00             	movzbl (%eax),%eax
  800e03:	3c 30                	cmp    $0x30,%al
  800e05:	75 0d                	jne    800e14 <strtol+0xa0>
		s++, base = 8;
  800e07:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e0b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800e12:	eb 0d                	jmp    800e21 <strtol+0xad>
	else if (base == 0)
  800e14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e18:	75 07                	jne    800e21 <strtol+0xad>
		base = 10;
  800e1a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	0f b6 00             	movzbl (%eax),%eax
  800e27:	3c 2f                	cmp    $0x2f,%al
  800e29:	7e 1b                	jle    800e46 <strtol+0xd2>
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	0f b6 00             	movzbl (%eax),%eax
  800e31:	3c 39                	cmp    $0x39,%al
  800e33:	7f 11                	jg     800e46 <strtol+0xd2>
			dig = *s - '0';
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	0f b6 00             	movzbl (%eax),%eax
  800e3b:	0f be c0             	movsbl %al,%eax
  800e3e:	83 e8 30             	sub    $0x30,%eax
  800e41:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e44:	eb 48                	jmp    800e8e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	0f b6 00             	movzbl (%eax),%eax
  800e4c:	3c 60                	cmp    $0x60,%al
  800e4e:	7e 1b                	jle    800e6b <strtol+0xf7>
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	0f b6 00             	movzbl (%eax),%eax
  800e56:	3c 7a                	cmp    $0x7a,%al
  800e58:	7f 11                	jg     800e6b <strtol+0xf7>
			dig = *s - 'a' + 10;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	0f b6 00             	movzbl (%eax),%eax
  800e60:	0f be c0             	movsbl %al,%eax
  800e63:	83 e8 57             	sub    $0x57,%eax
  800e66:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800e69:	eb 23                	jmp    800e8e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	0f b6 00             	movzbl (%eax),%eax
  800e71:	3c 40                	cmp    $0x40,%al
  800e73:	7e 3d                	jle    800eb2 <strtol+0x13e>
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	0f b6 00             	movzbl (%eax),%eax
  800e7b:	3c 5a                	cmp    $0x5a,%al
  800e7d:	7f 33                	jg     800eb2 <strtol+0x13e>
			dig = *s - 'A' + 10;
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	0f b6 00             	movzbl (%eax),%eax
  800e85:	0f be c0             	movsbl %al,%eax
  800e88:	83 e8 37             	sub    $0x37,%eax
  800e8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e91:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e94:	7c 02                	jl     800e98 <strtol+0x124>
			break;
  800e96:	eb 1a                	jmp    800eb2 <strtol+0x13e>
		s++, val = (val * base) + dig;
  800e98:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ea3:	89 c2                	mov    %eax,%edx
  800ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea8:	01 d0                	add    %edx,%eax
  800eaa:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ead:	e9 6f ff ff ff       	jmp    800e21 <strtol+0xad>

	if (endptr)
  800eb2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb6:	74 08                	je     800ec0 <strtol+0x14c>
		*endptr = (char *) s;
  800eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ec0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800ec4:	74 07                	je     800ecd <strtol+0x159>
  800ec6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ec9:	f7 d8                	neg    %eax
  800ecb:	eb 03                	jmp    800ed0 <strtol+0x15c>
  800ecd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	8b 55 10             	mov    0x10(%ebp),%edx
  800ee1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800ee4:	8b 5d 18             	mov    0x18(%ebp),%ebx
  800ee7:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  800eea:	8b 75 20             	mov    0x20(%ebp),%esi
  800eed:	cd 30                	int    $0x30
  800eef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef6:	74 30                	je     800f28 <syscall+0x56>
  800ef8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800efc:	7e 2a                	jle    800f28 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f0c:	c7 44 24 08 37 1e 80 	movl   $0x801e37,0x8(%esp)
  800f13:	00 
  800f14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f1b:	00 
  800f1c:	c7 04 24 54 1e 80 00 	movl   $0x801e54,(%esp)
  800f23:	e8 cd 08 00 00       	call   8017f5 <_panic>

	return ret;
  800f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800f2b:	83 c4 3c             	add    $0x3c,%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f43:	00 
  800f44:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f4b:	00 
  800f4c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f53:	00 
  800f54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f57:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6e:	e8 5f ff ff ff       	call   800ed2 <syscall>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f7b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800f82:	00 
  800f83:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800f92:	00 
  800f93:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa2:	00 
  800fa3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800faa:	00 
  800fab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800fb2:	e8 1b ff ff ff       	call   800ed2 <syscall>
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800fc9:	00 
  800fca:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800fd9:	00 
  800fda:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe1:	00 
  800fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fe6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800fed:	00 
  800fee:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800ff5:	e8 d8 fe ff ff       	call   800ed2 <syscall>
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801002:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801009:	00 
  80100a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801011:	00 
  801012:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801019:	00 
  80101a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801021:	00 
  801022:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801029:	00 
  80102a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801031:	00 
  801032:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801039:	e8 94 fe ff ff       	call   800ed2 <syscall>
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <sys_yield>:

void
sys_yield(void)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801046:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80104d:	00 
  80104e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801055:	00 
  801056:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80105d:	00 
  80105e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801065:	00 
  801066:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106d:	00 
  80106e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801075:	00 
  801076:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80107d:	e8 50 fe ff ff       	call   800ed2 <syscall>
}
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80108a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80108d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80109a:	00 
  80109b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8010a2:	00 
  8010a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8010be:	e8 0f fe ff ff       	call   800ed2 <syscall>
}
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8010cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8010d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8010d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8010e0:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8010e4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8010e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010f7:	00 
  8010f8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8010ff:	e8 ce fd ff ff       	call   800ed2 <syscall>
}
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  80113f:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801146:	e8 87 fd ff ff       	call   800ed2 <syscall>
}
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  801181:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  801188:	e8 45 fd ff ff       	call   800ed2 <syscall>
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801195:	8b 55 0c             	mov    0xc(%ebp),%edx
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011a2:	00 
  8011a3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8011b2:	00 
  8011b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011c2:	00 
  8011c3:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8011ca:	e8 03 fd ff ff       	call   800ed2 <syscall>
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8011d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8011da:	8b 55 10             	mov    0x10(%ebp),%edx
  8011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8011e7:	00 
  8011e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8011ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80120a:	e8 c3 fc ff ff       	call   800ed2 <syscall>
}
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801221:	00 
  801222:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801229:	00 
  80122a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801231:	00 
  801232:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801239:	00 
  80123a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80123e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801245:	00 
  801246:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80124d:	e8 80 fc ff ff       	call   800ed2 <syscall>
}
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <sys_exec>:

void sys_exec(char* buf){
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801264:	00 
  801265:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80126c:	00 
  80126d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801274:	00 
  801275:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80127c:	00 
  80127d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801288:	00 
  801289:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801290:	e8 3d fc ff ff       	call   800ed2 <syscall>
}
  801295:	c9                   	leave  
  801296:	c3                   	ret    

00801297 <sys_wait>:

void sys_wait(){
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80129d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012b4:	00 
  8012b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012bc:	00 
  8012bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012c4:	00 
  8012c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012cc:	00 
  8012cd:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8012d4:	e8 f9 fb ff ff       	call   800ed2 <syscall>
}
  8012d9:	c9                   	leave  
  8012da:	c3                   	ret    

008012db <sys_guest>:

void sys_guest(){
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8012e1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8012e8:	00 
  8012e9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8012f0:	00 
  8012f1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8012f8:	00 
  8012f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801300:	00 
  801301:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801308:	00 
  801309:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801310:	00 
  801311:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  801318:	e8 b5 fb ff ff       	call   800ed2 <syscall>
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	8b 00                	mov    (%eax),%eax
  80132a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	8b 40 04             	mov    0x4(%eax),%eax
  801333:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  801336:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801339:	83 e0 02             	and    $0x2,%eax
  80133c:	85 c0                	test   %eax,%eax
  80133e:	75 23                	jne    801363 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  801340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801343:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801347:	c7 44 24 08 64 1e 80 	movl   $0x801e64,0x8(%esp)
  80134e:	00 
  80134f:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801356:	00 
  801357:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  80135e:	e8 92 04 00 00       	call   8017f5 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  801363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801366:	c1 e8 0c             	shr    $0xc,%eax
  801369:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  80136c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80136f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801376:	25 00 08 00 00       	and    $0x800,%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	75 1c                	jne    80139b <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  80137f:	c7 44 24 08 a0 1e 80 	movl   $0x801ea0,0x8(%esp)
  801386:	00 
  801387:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80138e:	00 
  80138f:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  801396:	e8 5a 04 00 00       	call   8017f5 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  80139b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013aa:	00 
  8013ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013b2:	e8 cd fc ff ff       	call   801084 <sys_page_alloc>
  8013b7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8013ba:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8013be:	79 23                	jns    8013e3 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  8013c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8013c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c7:	c7 44 24 08 dc 1e 80 	movl   $0x801edc,0x8(%esp)
  8013ce:	00 
  8013cf:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8013d6:	00 
  8013d7:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  8013de:	e8 12 04 00 00       	call   8017f5 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  8013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013f8:	00 
  8013f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801404:	e8 bf f8 ff ff       	call   800cc8 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  801409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801412:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801417:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80141e:	00 
  80141f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801423:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801432:	00 
  801433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143a:	e8 86 fc ff ff       	call   8010c5 <sys_page_map>
  80143f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801442:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801446:	79 23                	jns    80146b <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  801448:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80144b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144f:	c7 44 24 08 14 1f 80 	movl   $0x801f14,0x8(%esp)
  801456:	00 
  801457:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  80145e:	00 
  80145f:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  801466:	e8 8a 03 00 00       	call   8017f5 <_panic>
	}

	// panic("pgfault not implemented");
}
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  801475:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  80147c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801486:	25 00 08 00 00       	and    $0x800,%eax
  80148b:	85 c0                	test   %eax,%eax
  80148d:	75 15                	jne    8014a4 <duppage+0x37>
  80148f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801492:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801499:	83 e0 02             	and    $0x2,%eax
  80149c:	85 c0                	test   %eax,%eax
  80149e:	0f 84 e0 00 00 00    	je     801584 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  8014a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ae:	83 e0 04             	and    $0x4,%eax
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	74 04                	je     8014b9 <duppage+0x4c>
  8014b5:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  8014b9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bf:	c1 e0 0c             	shl    $0xc,%eax
  8014c2:	89 c1                	mov    %eax,%ecx
  8014c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c7:	c1 e0 0c             	shl    $0xc,%eax
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	a1 20 34 80 00       	mov    0x803420,%eax
  8014d1:	8b 40 48             	mov    0x48(%eax),%eax
  8014d4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014d8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014e7:	89 04 24             	mov    %eax,(%esp)
  8014ea:	e8 d6 fb ff ff       	call   8010c5 <sys_page_map>
  8014ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8014f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8014f6:	79 23                	jns    80151b <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  8014f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ff:	c7 44 24 08 48 1f 80 	movl   $0x801f48,0x8(%esp)
  801506:	00 
  801507:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80150e:	00 
  80150f:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  801516:	e8 da 02 00 00       	call   8017f5 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80151b:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80151e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801521:	c1 e0 0c             	shl    $0xc,%eax
  801524:	89 c3                	mov    %eax,%ebx
  801526:	a1 20 34 80 00       	mov    0x803420,%eax
  80152b:	8b 48 48             	mov    0x48(%eax),%ecx
  80152e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801531:	c1 e0 0c             	shl    $0xc,%eax
  801534:	89 c2                	mov    %eax,%edx
  801536:	a1 20 34 80 00       	mov    0x803420,%eax
  80153b:	8b 40 48             	mov    0x48(%eax),%eax
  80153e:	89 74 24 10          	mov    %esi,0x10(%esp)
  801542:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801546:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80154a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80154e:	89 04 24             	mov    %eax,(%esp)
  801551:	e8 6f fb ff ff       	call   8010c5 <sys_page_map>
  801556:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801559:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80155d:	79 23                	jns    801582 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  80155f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801562:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801566:	c7 44 24 08 84 1f 80 	movl   $0x801f84,0x8(%esp)
  80156d:	00 
  80156e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  801575:	00 
  801576:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  80157d:	e8 73 02 00 00       	call   8017f5 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  801582:	eb 70                	jmp    8015f4 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  801584:	8b 45 0c             	mov    0xc(%ebp),%eax
  801587:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801593:	89 c3                	mov    %eax,%ebx
  801595:	8b 45 0c             	mov    0xc(%ebp),%eax
  801598:	c1 e0 0c             	shl    $0xc,%eax
  80159b:	89 c1                	mov    %eax,%ecx
  80159d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a0:	c1 e0 0c             	shl    $0xc,%eax
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	a1 20 34 80 00       	mov    0x803420,%eax
  8015aa:	8b 40 48             	mov    0x48(%eax),%eax
  8015ad:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8015b1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8015b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c0:	89 04 24             	mov    %eax,(%esp)
  8015c3:	e8 fd fa ff ff       	call   8010c5 <sys_page_map>
  8015c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8015cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8015cf:	79 23                	jns    8015f4 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  8015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d8:	c7 44 24 08 b4 1f 80 	movl   $0x801fb4,0x8(%esp)
  8015df:	00 
  8015e0:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8015e7:	00 
  8015e8:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  8015ef:	e8 01 02 00 00       	call   8017f5 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  8015f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f9:	83 c4 30             	add    $0x30,%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    

00801600 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801606:	c7 04 24 1f 13 80 00 	movl   $0x80131f,(%esp)
  80160d:	e8 3e 02 00 00       	call   801850 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801612:	b8 07 00 00 00       	mov    $0x7,%eax
  801617:	cd 30                	int    $0x30
  801619:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80161c:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80161f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  801622:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801626:	79 23                	jns    80164b <fork+0x4b>
  801628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80162f:	c7 44 24 08 ec 1f 80 	movl   $0x801fec,0x8(%esp)
  801636:	00 
  801637:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80163e:	00 
  80163f:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  801646:	e8 aa 01 00 00       	call   8017f5 <_panic>
	else if(childeid == 0){
  80164b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80164f:	75 29                	jne    80167a <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  801651:	e8 a6 f9 ff ff       	call   800ffc <sys_getenvid>
  801656:	25 ff 03 00 00       	and    $0x3ff,%eax
  80165b:	c1 e0 02             	shl    $0x2,%eax
  80165e:	89 c2                	mov    %eax,%edx
  801660:	c1 e2 05             	shl    $0x5,%edx
  801663:	29 c2                	sub    %eax,%edx
  801665:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80166b:	a3 20 34 80 00       	mov    %eax,0x803420
		// set_pgfault_handler(pgfault);
		return 0;
  801670:	b8 00 00 00 00       	mov    $0x0,%eax
  801675:	e9 16 01 00 00       	jmp    801790 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80167a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801681:	eb 3b                	jmp    8016be <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  801683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801686:	c1 f8 0a             	sar    $0xa,%eax
  801689:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801690:	83 e0 01             	and    $0x1,%eax
  801693:	85 c0                	test   %eax,%eax
  801695:	74 23                	je     8016ba <fork+0xba>
  801697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a1:	83 e0 01             	and    $0x1,%eax
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	74 12                	je     8016ba <fork+0xba>
			duppage(childeid, i);
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 b3 fd ff ff       	call   80146d <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8016ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  8016be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c1:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  8016c6:	76 bb                	jbe    801683 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  8016c8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016cf:	00 
  8016d0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8016d7:	ee 
  8016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016db:	89 04 24             	mov    %eax,(%esp)
  8016de:	e8 a1 f9 ff ff       	call   801084 <sys_page_alloc>
  8016e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016e6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016ea:	79 23                	jns    80170f <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  8016ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016f3:	c7 44 24 08 14 20 80 	movl   $0x802014,0x8(%esp)
  8016fa:	00 
  8016fb:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801702:	00 
  801703:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  80170a:	e8 e6 00 00 00       	call   8017f5 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80170f:	c7 44 24 04 c6 18 80 	movl   $0x8018c6,0x4(%esp)
  801716:	00 
  801717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	e8 6d fa ff ff       	call   80118f <sys_env_set_pgfault_upcall>
  801722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801725:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801729:	79 23                	jns    80174e <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  80172b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80172e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801732:	c7 44 24 08 3c 20 80 	movl   $0x80203c,0x8(%esp)
  801739:	00 
  80173a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801741:	00 
  801742:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  801749:	e8 a7 00 00 00       	call   8017f5 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  80174e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801755:	00 
  801756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801759:	89 04 24             	mov    %eax,(%esp)
  80175c:	e8 ec f9 ff ff       	call   80114d <sys_env_set_status>
  801761:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801764:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801768:	79 23                	jns    80178d <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  80176a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80176d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801771:	c7 44 24 08 70 20 80 	movl   $0x802070,0x8(%esp)
  801778:	00 
  801779:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801780:	00 
  801781:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  801788:	e8 68 00 00 00       	call   8017f5 <_panic>
	}
	return childeid;
  80178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  801790:	c9                   	leave  
  801791:	c3                   	ret    

00801792 <sfork>:

// Challenge!
int
sfork(void)
{
  801792:	55                   	push   %ebp
  801793:	89 e5                	mov    %esp,%ebp
  801795:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801798:	c7 44 24 08 99 20 80 	movl   $0x802099,0x8(%esp)
  80179f:	00 
  8017a0:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  8017a7:	00 
  8017a8:	c7 04 24 94 1e 80 00 	movl   $0x801e94,(%esp)
  8017af:	e8 41 00 00 00       	call   8017f5 <_panic>

008017b4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8017c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017c7:	00 
  8017c8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8017cb:	89 04 24             	mov    %eax,(%esp)
  8017ce:	e8 60 f7 ff ff       	call   800f33 <sys_cputs>
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <getchar>:

int
getchar(void)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	// sys_cgetc does not block, but getchar should.
	while ((r = sys_cgetc()) == 0)
  8017db:	eb 05                	jmp    8017e2 <getchar+0xd>
		sys_yield();
  8017dd:	e8 5e f8 ff ff       	call   801040 <sys_yield>
int
getchar(void)
{
	int r;
	// sys_cgetc does not block, but getchar should.
	while ((r = sys_cgetc()) == 0)
  8017e2:	e8 8e f7 ff ff       	call   800f75 <sys_cgetc>
  8017e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8017ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017ee:	74 ed                	je     8017dd <getchar+0x8>
		sys_yield();
	return r;
  8017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8017fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8017ff:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801802:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801808:	e8 ef f7 ff ff       	call   800ffc <sys_getenvid>
  80180d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801810:	89 54 24 10          	mov    %edx,0x10(%esp)
  801814:	8b 55 08             	mov    0x8(%ebp),%edx
  801817:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80181b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	c7 04 24 b0 20 80 00 	movl   $0x8020b0,(%esp)
  80182a:	e8 ab e9 ff ff       	call   8001da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	8b 45 10             	mov    0x10(%ebp),%eax
  801839:	89 04 24             	mov    %eax,(%esp)
  80183c:	e8 35 e9 ff ff       	call   800176 <vcprintf>
	cprintf("\n");
  801841:	c7 04 24 d3 20 80 00 	movl   $0x8020d3,(%esp)
  801848:	e8 8d e9 ff ff       	call   8001da <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80184d:	cc                   	int3   
  80184e:	eb fd                	jmp    80184d <_panic+0x58>

00801850 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801856:	a1 24 34 80 00       	mov    0x803424,%eax
  80185b:	85 c0                	test   %eax,%eax
  80185d:	75 5d                	jne    8018bc <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80185f:	a1 20 34 80 00       	mov    0x803420,%eax
  801864:	8b 40 48             	mov    0x48(%eax),%eax
  801867:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80186e:	00 
  80186f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801876:	ee 
  801877:	89 04 24             	mov    %eax,(%esp)
  80187a:	e8 05 f8 ff ff       	call   801084 <sys_page_alloc>
  80187f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801882:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801886:	79 1c                	jns    8018a4 <set_pgfault_handler+0x54>
  801888:	c7 44 24 08 d8 20 80 	movl   $0x8020d8,0x8(%esp)
  80188f:	00 
  801890:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801897:	00 
  801898:	c7 04 24 04 21 80 00 	movl   $0x802104,(%esp)
  80189f:	e8 51 ff ff ff       	call   8017f5 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8018a4:	a1 20 34 80 00       	mov    0x803420,%eax
  8018a9:	8b 40 48             	mov    0x48(%eax),%eax
  8018ac:	c7 44 24 04 c6 18 80 	movl   $0x8018c6,0x4(%esp)
  8018b3:	00 
  8018b4:	89 04 24             	mov    %eax,(%esp)
  8018b7:	e8 d3 f8 ff ff       	call   80118f <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	a3 24 34 80 00       	mov    %eax,0x803424
}
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8018c6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8018c7:	a1 24 34 80 00       	mov    0x803424,%eax
	call *%eax
  8018cc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8018ce:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8018d1:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8018d5:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8018d7:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8018db:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8018dc:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8018df:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8018e1:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8018e2:	58                   	pop    %eax
	popal 						// pop all the registers
  8018e3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8018e4:	83 c4 04             	add    $0x4,%esp
	popfl
  8018e7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8018e8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8018e9:	c3                   	ret    
  8018ea:	66 90                	xchg   %ax,%ax
  8018ec:	66 90                	xchg   %ax,%ax
  8018ee:	66 90                	xchg   %ax,%ax

008018f0 <__udivdi3>:
  8018f0:	55                   	push   %ebp
  8018f1:	57                   	push   %edi
  8018f2:	56                   	push   %esi
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8018fa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8018fe:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801902:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801906:	85 c0                	test   %eax,%eax
  801908:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80190c:	89 ea                	mov    %ebp,%edx
  80190e:	89 0c 24             	mov    %ecx,(%esp)
  801911:	75 2d                	jne    801940 <__udivdi3+0x50>
  801913:	39 e9                	cmp    %ebp,%ecx
  801915:	77 61                	ja     801978 <__udivdi3+0x88>
  801917:	85 c9                	test   %ecx,%ecx
  801919:	89 ce                	mov    %ecx,%esi
  80191b:	75 0b                	jne    801928 <__udivdi3+0x38>
  80191d:	b8 01 00 00 00       	mov    $0x1,%eax
  801922:	31 d2                	xor    %edx,%edx
  801924:	f7 f1                	div    %ecx
  801926:	89 c6                	mov    %eax,%esi
  801928:	31 d2                	xor    %edx,%edx
  80192a:	89 e8                	mov    %ebp,%eax
  80192c:	f7 f6                	div    %esi
  80192e:	89 c5                	mov    %eax,%ebp
  801930:	89 f8                	mov    %edi,%eax
  801932:	f7 f6                	div    %esi
  801934:	89 ea                	mov    %ebp,%edx
  801936:	83 c4 0c             	add    $0xc,%esp
  801939:	5e                   	pop    %esi
  80193a:	5f                   	pop    %edi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    
  80193d:	8d 76 00             	lea    0x0(%esi),%esi
  801940:	39 e8                	cmp    %ebp,%eax
  801942:	77 24                	ja     801968 <__udivdi3+0x78>
  801944:	0f bd e8             	bsr    %eax,%ebp
  801947:	83 f5 1f             	xor    $0x1f,%ebp
  80194a:	75 3c                	jne    801988 <__udivdi3+0x98>
  80194c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801950:	39 34 24             	cmp    %esi,(%esp)
  801953:	0f 86 9f 00 00 00    	jbe    8019f8 <__udivdi3+0x108>
  801959:	39 d0                	cmp    %edx,%eax
  80195b:	0f 82 97 00 00 00    	jb     8019f8 <__udivdi3+0x108>
  801961:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801968:	31 d2                	xor    %edx,%edx
  80196a:	31 c0                	xor    %eax,%eax
  80196c:	83 c4 0c             	add    $0xc,%esp
  80196f:	5e                   	pop    %esi
  801970:	5f                   	pop    %edi
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    
  801973:	90                   	nop
  801974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801978:	89 f8                	mov    %edi,%eax
  80197a:	f7 f1                	div    %ecx
  80197c:	31 d2                	xor    %edx,%edx
  80197e:	83 c4 0c             	add    $0xc,%esp
  801981:	5e                   	pop    %esi
  801982:	5f                   	pop    %edi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    
  801985:	8d 76 00             	lea    0x0(%esi),%esi
  801988:	89 e9                	mov    %ebp,%ecx
  80198a:	8b 3c 24             	mov    (%esp),%edi
  80198d:	d3 e0                	shl    %cl,%eax
  80198f:	89 c6                	mov    %eax,%esi
  801991:	b8 20 00 00 00       	mov    $0x20,%eax
  801996:	29 e8                	sub    %ebp,%eax
  801998:	89 c1                	mov    %eax,%ecx
  80199a:	d3 ef                	shr    %cl,%edi
  80199c:	89 e9                	mov    %ebp,%ecx
  80199e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019a2:	8b 3c 24             	mov    (%esp),%edi
  8019a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8019a9:	89 d6                	mov    %edx,%esi
  8019ab:	d3 e7                	shl    %cl,%edi
  8019ad:	89 c1                	mov    %eax,%ecx
  8019af:	89 3c 24             	mov    %edi,(%esp)
  8019b2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019b6:	d3 ee                	shr    %cl,%esi
  8019b8:	89 e9                	mov    %ebp,%ecx
  8019ba:	d3 e2                	shl    %cl,%edx
  8019bc:	89 c1                	mov    %eax,%ecx
  8019be:	d3 ef                	shr    %cl,%edi
  8019c0:	09 d7                	or     %edx,%edi
  8019c2:	89 f2                	mov    %esi,%edx
  8019c4:	89 f8                	mov    %edi,%eax
  8019c6:	f7 74 24 08          	divl   0x8(%esp)
  8019ca:	89 d6                	mov    %edx,%esi
  8019cc:	89 c7                	mov    %eax,%edi
  8019ce:	f7 24 24             	mull   (%esp)
  8019d1:	39 d6                	cmp    %edx,%esi
  8019d3:	89 14 24             	mov    %edx,(%esp)
  8019d6:	72 30                	jb     801a08 <__udivdi3+0x118>
  8019d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8019dc:	89 e9                	mov    %ebp,%ecx
  8019de:	d3 e2                	shl    %cl,%edx
  8019e0:	39 c2                	cmp    %eax,%edx
  8019e2:	73 05                	jae    8019e9 <__udivdi3+0xf9>
  8019e4:	3b 34 24             	cmp    (%esp),%esi
  8019e7:	74 1f                	je     801a08 <__udivdi3+0x118>
  8019e9:	89 f8                	mov    %edi,%eax
  8019eb:	31 d2                	xor    %edx,%edx
  8019ed:	e9 7a ff ff ff       	jmp    80196c <__udivdi3+0x7c>
  8019f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8019f8:	31 d2                	xor    %edx,%edx
  8019fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ff:	e9 68 ff ff ff       	jmp    80196c <__udivdi3+0x7c>
  801a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a08:	8d 47 ff             	lea    -0x1(%edi),%eax
  801a0b:	31 d2                	xor    %edx,%edx
  801a0d:	83 c4 0c             	add    $0xc,%esp
  801a10:	5e                   	pop    %esi
  801a11:	5f                   	pop    %edi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    
  801a14:	66 90                	xchg   %ax,%ax
  801a16:	66 90                	xchg   %ax,%ax
  801a18:	66 90                	xchg   %ax,%ax
  801a1a:	66 90                	xchg   %ax,%ax
  801a1c:	66 90                	xchg   %ax,%ax
  801a1e:	66 90                	xchg   %ax,%ax

00801a20 <__umoddi3>:
  801a20:	55                   	push   %ebp
  801a21:	57                   	push   %edi
  801a22:	56                   	push   %esi
  801a23:	83 ec 14             	sub    $0x14,%esp
  801a26:	8b 44 24 28          	mov    0x28(%esp),%eax
  801a2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801a2e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801a32:	89 c7                	mov    %eax,%edi
  801a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a38:	8b 44 24 30          	mov    0x30(%esp),%eax
  801a3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801a40:	89 34 24             	mov    %esi,(%esp)
  801a43:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a47:	85 c0                	test   %eax,%eax
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a4f:	75 17                	jne    801a68 <__umoddi3+0x48>
  801a51:	39 fe                	cmp    %edi,%esi
  801a53:	76 4b                	jbe    801aa0 <__umoddi3+0x80>
  801a55:	89 c8                	mov    %ecx,%eax
  801a57:	89 fa                	mov    %edi,%edx
  801a59:	f7 f6                	div    %esi
  801a5b:	89 d0                	mov    %edx,%eax
  801a5d:	31 d2                	xor    %edx,%edx
  801a5f:	83 c4 14             	add    $0x14,%esp
  801a62:	5e                   	pop    %esi
  801a63:	5f                   	pop    %edi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    
  801a66:	66 90                	xchg   %ax,%ax
  801a68:	39 f8                	cmp    %edi,%eax
  801a6a:	77 54                	ja     801ac0 <__umoddi3+0xa0>
  801a6c:	0f bd e8             	bsr    %eax,%ebp
  801a6f:	83 f5 1f             	xor    $0x1f,%ebp
  801a72:	75 5c                	jne    801ad0 <__umoddi3+0xb0>
  801a74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801a78:	39 3c 24             	cmp    %edi,(%esp)
  801a7b:	0f 87 e7 00 00 00    	ja     801b68 <__umoddi3+0x148>
  801a81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a85:	29 f1                	sub    %esi,%ecx
  801a87:	19 c7                	sbb    %eax,%edi
  801a89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a91:	8b 44 24 08          	mov    0x8(%esp),%eax
  801a95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801a99:	83 c4 14             	add    $0x14,%esp
  801a9c:	5e                   	pop    %esi
  801a9d:	5f                   	pop    %edi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    
  801aa0:	85 f6                	test   %esi,%esi
  801aa2:	89 f5                	mov    %esi,%ebp
  801aa4:	75 0b                	jne    801ab1 <__umoddi3+0x91>
  801aa6:	b8 01 00 00 00       	mov    $0x1,%eax
  801aab:	31 d2                	xor    %edx,%edx
  801aad:	f7 f6                	div    %esi
  801aaf:	89 c5                	mov    %eax,%ebp
  801ab1:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ab5:	31 d2                	xor    %edx,%edx
  801ab7:	f7 f5                	div    %ebp
  801ab9:	89 c8                	mov    %ecx,%eax
  801abb:	f7 f5                	div    %ebp
  801abd:	eb 9c                	jmp    801a5b <__umoddi3+0x3b>
  801abf:	90                   	nop
  801ac0:	89 c8                	mov    %ecx,%eax
  801ac2:	89 fa                	mov    %edi,%edx
  801ac4:	83 c4 14             	add    $0x14,%esp
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    
  801acb:	90                   	nop
  801acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ad0:	8b 04 24             	mov    (%esp),%eax
  801ad3:	be 20 00 00 00       	mov    $0x20,%esi
  801ad8:	89 e9                	mov    %ebp,%ecx
  801ada:	29 ee                	sub    %ebp,%esi
  801adc:	d3 e2                	shl    %cl,%edx
  801ade:	89 f1                	mov    %esi,%ecx
  801ae0:	d3 e8                	shr    %cl,%eax
  801ae2:	89 e9                	mov    %ebp,%ecx
  801ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae8:	8b 04 24             	mov    (%esp),%eax
  801aeb:	09 54 24 04          	or     %edx,0x4(%esp)
  801aef:	89 fa                	mov    %edi,%edx
  801af1:	d3 e0                	shl    %cl,%eax
  801af3:	89 f1                	mov    %esi,%ecx
  801af5:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801afd:	d3 ea                	shr    %cl,%edx
  801aff:	89 e9                	mov    %ebp,%ecx
  801b01:	d3 e7                	shl    %cl,%edi
  801b03:	89 f1                	mov    %esi,%ecx
  801b05:	d3 e8                	shr    %cl,%eax
  801b07:	89 e9                	mov    %ebp,%ecx
  801b09:	09 f8                	or     %edi,%eax
  801b0b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801b0f:	f7 74 24 04          	divl   0x4(%esp)
  801b13:	d3 e7                	shl    %cl,%edi
  801b15:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b19:	89 d7                	mov    %edx,%edi
  801b1b:	f7 64 24 08          	mull   0x8(%esp)
  801b1f:	39 d7                	cmp    %edx,%edi
  801b21:	89 c1                	mov    %eax,%ecx
  801b23:	89 14 24             	mov    %edx,(%esp)
  801b26:	72 2c                	jb     801b54 <__umoddi3+0x134>
  801b28:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801b2c:	72 22                	jb     801b50 <__umoddi3+0x130>
  801b2e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801b32:	29 c8                	sub    %ecx,%eax
  801b34:	19 d7                	sbb    %edx,%edi
  801b36:	89 e9                	mov    %ebp,%ecx
  801b38:	89 fa                	mov    %edi,%edx
  801b3a:	d3 e8                	shr    %cl,%eax
  801b3c:	89 f1                	mov    %esi,%ecx
  801b3e:	d3 e2                	shl    %cl,%edx
  801b40:	89 e9                	mov    %ebp,%ecx
  801b42:	d3 ef                	shr    %cl,%edi
  801b44:	09 d0                	or     %edx,%eax
  801b46:	89 fa                	mov    %edi,%edx
  801b48:	83 c4 14             	add    $0x14,%esp
  801b4b:	5e                   	pop    %esi
  801b4c:	5f                   	pop    %edi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    
  801b4f:	90                   	nop
  801b50:	39 d7                	cmp    %edx,%edi
  801b52:	75 da                	jne    801b2e <__umoddi3+0x10e>
  801b54:	8b 14 24             	mov    (%esp),%edx
  801b57:	89 c1                	mov    %eax,%ecx
  801b59:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801b5d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801b61:	eb cb                	jmp    801b2e <__umoddi3+0x10e>
  801b63:	90                   	nop
  801b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b68:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801b6c:	0f 82 0f ff ff ff    	jb     801a81 <__umoddi3+0x61>
  801b72:	e9 1a ff ff ff       	jmp    801a91 <__umoddi3+0x71>
