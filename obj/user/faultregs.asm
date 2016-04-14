
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 1b 06 00 00       	call   80064c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	int mismatch = 0;
  800039:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 14             	mov    0x14(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80004e:	c7 44 24 04 a0 1a 80 	movl   $0x801aa0,0x4(%esp)
  800055:	00 
  800056:	c7 04 24 a1 1a 80 00 	movl   $0x801aa1,(%esp)
  80005d:	e8 68 07 00 00       	call   8007ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800062:	8b 45 10             	mov    0x10(%ebp),%eax
  800065:	8b 10                	mov    (%eax),%edx
  800067:	8b 45 08             	mov    0x8(%ebp),%eax
  80006a:	8b 00                	mov    (%eax),%eax
  80006c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800070:	89 44 24 08          	mov    %eax,0x8(%esp)
  800074:	c7 44 24 04 b1 1a 80 	movl   $0x801ab1,0x4(%esp)
  80007b:	00 
  80007c:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800083:	e8 42 07 00 00       	call   8007ca <cprintf>
  800088:	8b 45 08             	mov    0x8(%ebp),%eax
  80008b:	8b 10                	mov    (%eax),%edx
  80008d:	8b 45 10             	mov    0x10(%ebp),%eax
  800090:	8b 00                	mov    (%eax),%eax
  800092:	39 c2                	cmp    %eax,%edx
  800094:	75 0e                	jne    8000a4 <check_regs+0x71>
  800096:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  80009d:	e8 28 07 00 00       	call   8007ca <cprintf>
  8000a2:	eb 13                	jmp    8000b7 <check_regs+0x84>
  8000a4:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  8000ab:	e8 1a 07 00 00       	call   8007ca <cprintf>
  8000b0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(esi, regs.reg_esi);
  8000b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8000ba:	8b 50 04             	mov    0x4(%eax),%edx
  8000bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c0:	8b 40 04             	mov    0x4(%eax),%eax
  8000c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8000c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000cb:	c7 44 24 04 d3 1a 80 	movl   $0x801ad3,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  8000da:	e8 eb 06 00 00       	call   8007ca <cprintf>
  8000df:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e2:	8b 50 04             	mov    0x4(%eax),%edx
  8000e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8000e8:	8b 40 04             	mov    0x4(%eax),%eax
  8000eb:	39 c2                	cmp    %eax,%edx
  8000ed:	75 0e                	jne    8000fd <check_regs+0xca>
  8000ef:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  8000f6:	e8 cf 06 00 00       	call   8007ca <cprintf>
  8000fb:	eb 13                	jmp    800110 <check_regs+0xdd>
  8000fd:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  800104:	e8 c1 06 00 00       	call   8007ca <cprintf>
  800109:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ebp, regs.reg_ebp);
  800110:	8b 45 10             	mov    0x10(%ebp),%eax
  800113:	8b 50 08             	mov    0x8(%eax),%edx
  800116:	8b 45 08             	mov    0x8(%ebp),%eax
  800119:	8b 40 08             	mov    0x8(%eax),%eax
  80011c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800120:	89 44 24 08          	mov    %eax,0x8(%esp)
  800124:	c7 44 24 04 d7 1a 80 	movl   $0x801ad7,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800133:	e8 92 06 00 00       	call   8007ca <cprintf>
  800138:	8b 45 08             	mov    0x8(%ebp),%eax
  80013b:	8b 50 08             	mov    0x8(%eax),%edx
  80013e:	8b 45 10             	mov    0x10(%ebp),%eax
  800141:	8b 40 08             	mov    0x8(%eax),%eax
  800144:	39 c2                	cmp    %eax,%edx
  800146:	75 0e                	jne    800156 <check_regs+0x123>
  800148:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  80014f:	e8 76 06 00 00       	call   8007ca <cprintf>
  800154:	eb 13                	jmp    800169 <check_regs+0x136>
  800156:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  80015d:	e8 68 06 00 00       	call   8007ca <cprintf>
  800162:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ebx, regs.reg_ebx);
  800169:	8b 45 10             	mov    0x10(%ebp),%eax
  80016c:	8b 50 10             	mov    0x10(%eax),%edx
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 40 10             	mov    0x10(%eax),%eax
  800175:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800179:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017d:	c7 44 24 04 db 1a 80 	movl   $0x801adb,0x4(%esp)
  800184:	00 
  800185:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  80018c:	e8 39 06 00 00       	call   8007ca <cprintf>
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	8b 50 10             	mov    0x10(%eax),%edx
  800197:	8b 45 10             	mov    0x10(%ebp),%eax
  80019a:	8b 40 10             	mov    0x10(%eax),%eax
  80019d:	39 c2                	cmp    %eax,%edx
  80019f:	75 0e                	jne    8001af <check_regs+0x17c>
  8001a1:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  8001a8:	e8 1d 06 00 00       	call   8007ca <cprintf>
  8001ad:	eb 13                	jmp    8001c2 <check_regs+0x18f>
  8001af:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  8001b6:	e8 0f 06 00 00       	call   8007ca <cprintf>
  8001bb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(edx, regs.reg_edx);
  8001c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c5:	8b 50 14             	mov    0x14(%eax),%edx
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	8b 40 14             	mov    0x14(%eax),%eax
  8001ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d6:	c7 44 24 04 df 1a 80 	movl   $0x801adf,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  8001e5:	e8 e0 05 00 00       	call   8007ca <cprintf>
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	8b 50 14             	mov    0x14(%eax),%edx
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	8b 40 14             	mov    0x14(%eax),%eax
  8001f6:	39 c2                	cmp    %eax,%edx
  8001f8:	75 0e                	jne    800208 <check_regs+0x1d5>
  8001fa:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  800201:	e8 c4 05 00 00       	call   8007ca <cprintf>
  800206:	eb 13                	jmp    80021b <check_regs+0x1e8>
  800208:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  80020f:	e8 b6 05 00 00       	call   8007ca <cprintf>
  800214:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ecx, regs.reg_ecx);
  80021b:	8b 45 10             	mov    0x10(%ebp),%eax
  80021e:	8b 50 18             	mov    0x18(%eax),%edx
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 40 18             	mov    0x18(%eax),%eax
  800227:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80022b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022f:	c7 44 24 04 e3 1a 80 	movl   $0x801ae3,0x4(%esp)
  800236:	00 
  800237:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  80023e:	e8 87 05 00 00       	call   8007ca <cprintf>
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 50 18             	mov    0x18(%eax),%edx
  800249:	8b 45 10             	mov    0x10(%ebp),%eax
  80024c:	8b 40 18             	mov    0x18(%eax),%eax
  80024f:	39 c2                	cmp    %eax,%edx
  800251:	75 0e                	jne    800261 <check_regs+0x22e>
  800253:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  80025a:	e8 6b 05 00 00       	call   8007ca <cprintf>
  80025f:	eb 13                	jmp    800274 <check_regs+0x241>
  800261:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  800268:	e8 5d 05 00 00       	call   8007ca <cprintf>
  80026d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eax, regs.reg_eax);
  800274:	8b 45 10             	mov    0x10(%ebp),%eax
  800277:	8b 50 1c             	mov    0x1c(%eax),%edx
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	8b 40 1c             	mov    0x1c(%eax),%eax
  800280:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	c7 44 24 04 e7 1a 80 	movl   $0x801ae7,0x4(%esp)
  80028f:	00 
  800290:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800297:	e8 2e 05 00 00       	call   8007ca <cprintf>
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	8b 50 1c             	mov    0x1c(%eax),%edx
  8002a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a5:	8b 40 1c             	mov    0x1c(%eax),%eax
  8002a8:	39 c2                	cmp    %eax,%edx
  8002aa:	75 0e                	jne    8002ba <check_regs+0x287>
  8002ac:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  8002b3:	e8 12 05 00 00       	call   8007ca <cprintf>
  8002b8:	eb 13                	jmp    8002cd <check_regs+0x29a>
  8002ba:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  8002c1:	e8 04 05 00 00       	call   8007ca <cprintf>
  8002c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eip, eip);
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	8b 50 20             	mov    0x20(%eax),%edx
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	8b 40 20             	mov    0x20(%eax),%eax
  8002d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e1:	c7 44 24 04 eb 1a 80 	movl   $0x801aeb,0x4(%esp)
  8002e8:	00 
  8002e9:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  8002f0:	e8 d5 04 00 00       	call   8007ca <cprintf>
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 50 20             	mov    0x20(%eax),%edx
  8002fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fe:	8b 40 20             	mov    0x20(%eax),%eax
  800301:	39 c2                	cmp    %eax,%edx
  800303:	75 0e                	jne    800313 <check_regs+0x2e0>
  800305:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  80030c:	e8 b9 04 00 00       	call   8007ca <cprintf>
  800311:	eb 13                	jmp    800326 <check_regs+0x2f3>
  800313:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  80031a:	e8 ab 04 00 00       	call   8007ca <cprintf>
  80031f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eflags, eflags);
  800326:	8b 45 10             	mov    0x10(%ebp),%eax
  800329:	8b 50 24             	mov    0x24(%eax),%edx
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 40 24             	mov    0x24(%eax),%eax
  800332:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	c7 44 24 04 ef 1a 80 	movl   $0x801aef,0x4(%esp)
  800341:	00 
  800342:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800349:	e8 7c 04 00 00       	call   8007ca <cprintf>
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	8b 50 24             	mov    0x24(%eax),%edx
  800354:	8b 45 10             	mov    0x10(%ebp),%eax
  800357:	8b 40 24             	mov    0x24(%eax),%eax
  80035a:	39 c2                	cmp    %eax,%edx
  80035c:	75 0e                	jne    80036c <check_regs+0x339>
  80035e:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  800365:	e8 60 04 00 00       	call   8007ca <cprintf>
  80036a:	eb 13                	jmp    80037f <check_regs+0x34c>
  80036c:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  800373:	e8 52 04 00 00       	call   8007ca <cprintf>
  800378:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(esp, esp);
  80037f:	8b 45 10             	mov    0x10(%ebp),%eax
  800382:	8b 50 28             	mov    0x28(%eax),%edx
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	8b 40 28             	mov    0x28(%eax),%eax
  80038b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 04 f6 1a 80 	movl   $0x801af6,0x4(%esp)
  80039a:	00 
  80039b:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  8003a2:	e8 23 04 00 00       	call   8007ca <cprintf>
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	8b 50 28             	mov    0x28(%eax),%edx
  8003ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b0:	8b 40 28             	mov    0x28(%eax),%eax
  8003b3:	39 c2                	cmp    %eax,%edx
  8003b5:	75 0e                	jne    8003c5 <check_regs+0x392>
  8003b7:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  8003be:	e8 07 04 00 00       	call   8007ca <cprintf>
  8003c3:	eb 13                	jmp    8003d8 <check_regs+0x3a5>
  8003c5:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  8003cc:	e8 f9 03 00 00       	call   8007ca <cprintf>
  8003d1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

#undef CHECK

	cprintf("Registers %s ", testname);
  8003d8:	8b 45 18             	mov    0x18(%ebp),%eax
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	c7 04 24 fa 1a 80 00 	movl   $0x801afa,(%esp)
  8003e6:	e8 df 03 00 00       	call   8007ca <cprintf>
	if (!mismatch)
  8003eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8003ef:	75 0e                	jne    8003ff <check_regs+0x3cc>
		cprintf("OK\n");
  8003f1:	c7 04 24 c5 1a 80 00 	movl   $0x801ac5,(%esp)
  8003f8:	e8 cd 03 00 00       	call   8007ca <cprintf>
  8003fd:	eb 0c                	jmp    80040b <check_regs+0x3d8>
	else
		cprintf("MISMATCH\n");
  8003ff:	c7 04 24 c9 1a 80 00 	movl   $0x801ac9,(%esp)
  800406:	e8 bf 03 00 00       	call   8007ca <cprintf>
}
  80040b:	c9                   	leave  
  80040c:	c3                   	ret    

0080040d <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	83 ec 38             	sub    $0x38,%esp
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	3d 00 00 40 00       	cmp    $0x400000,%eax
  80041d:	74 2f                	je     80044e <pgfault+0x41>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	8b 50 28             	mov    0x28(%eax),%edx
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	8b 00                	mov    (%eax),%eax
  80042a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 08 1b 80 	movl   $0x801b08,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 39 1b 80 00 	movl   $0x801b39,(%esp)
  800449:	e8 61 02 00 00       	call   8006af <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 50 08             	mov    0x8(%eax),%edx
  800454:	89 15 60 20 80 00    	mov    %edx,0x802060
  80045a:	8b 50 0c             	mov    0xc(%eax),%edx
  80045d:	89 15 64 20 80 00    	mov    %edx,0x802064
  800463:	8b 50 10             	mov    0x10(%eax),%edx
  800466:	89 15 68 20 80 00    	mov    %edx,0x802068
  80046c:	8b 50 14             	mov    0x14(%eax),%edx
  80046f:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  800475:	8b 50 18             	mov    0x18(%eax),%edx
  800478:	89 15 70 20 80 00    	mov    %edx,0x802070
  80047e:	8b 50 1c             	mov    0x1c(%eax),%edx
  800481:	89 15 74 20 80 00    	mov    %edx,0x802074
  800487:	8b 50 20             	mov    0x20(%eax),%edx
  80048a:	89 15 78 20 80 00    	mov    %edx,0x802078
  800490:	8b 40 24             	mov    0x24(%eax),%eax
  800493:	a3 7c 20 80 00       	mov    %eax,0x80207c
	during.eip = utf->utf_eip;
  800498:	8b 45 08             	mov    0x8(%ebp),%eax
  80049b:	8b 40 28             	mov    0x28(%eax),%eax
  80049e:	a3 80 20 80 00       	mov    %eax,0x802080
	during.eflags = utf->utf_eflags;
  8004a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a6:	8b 40 2c             	mov    0x2c(%eax),%eax
  8004a9:	a3 84 20 80 00       	mov    %eax,0x802084
	during.esp = utf->utf_esp;
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	8b 40 30             	mov    0x30(%eax),%eax
  8004b4:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8004b9:	c7 44 24 10 4a 1b 80 	movl   $0x801b4a,0x10(%esp)
  8004c0:	00 
  8004c1:	c7 44 24 0c 58 1b 80 	movl   $0x801b58,0xc(%esp)
  8004c8:	00 
  8004c9:	c7 44 24 08 60 20 80 	movl   $0x802060,0x8(%esp)
  8004d0:	00 
  8004d1:	c7 44 24 04 5f 1b 80 	movl   $0x801b5f,0x4(%esp)
  8004d8:	00 
  8004d9:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  8004e0:	e8 4e fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8004e5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8004ec:	00 
  8004ed:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8004f4:	00 
  8004f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004fc:	e8 86 10 00 00       	call   801587 <sys_page_alloc>
  800501:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800504:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800508:	79 23                	jns    80052d <pgfault+0x120>
		panic("sys_page_alloc: %e", r);
  80050a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800511:	c7 44 24 08 66 1b 80 	movl   $0x801b66,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 39 1b 80 00 	movl   $0x801b39,(%esp)
  800528:	e8 82 01 00 00       	call   8006af <_panic>
}
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <umain>:

void
umain(int argc, char **argv)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800535:	c7 04 24 0d 04 80 00 	movl   $0x80040d,(%esp)
  80053c:	e8 16 12 00 00       	call   801757 <set_pgfault_handler>

	__asm __volatile(
  800541:	50                   	push   %eax
  800542:	9c                   	pushf  
  800543:	58                   	pop    %eax
  800544:	0d d5 08 00 00       	or     $0x8d5,%eax
  800549:	50                   	push   %eax
  80054a:	9d                   	popf   
  80054b:	a3 44 20 80 00       	mov    %eax,0x802044
  800550:	8d 05 8b 05 80 00    	lea    0x80058b,%eax
  800556:	a3 40 20 80 00       	mov    %eax,0x802040
  80055b:	58                   	pop    %eax
  80055c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800562:	89 35 24 20 80 00    	mov    %esi,0x802024
  800568:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80056e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800574:	89 15 34 20 80 00    	mov    %edx,0x802034
  80057a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800580:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800585:	89 25 48 20 80 00    	mov    %esp,0x802048
  80058b:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800592:	00 00 00 
  800595:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  80059b:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8005a1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8005a7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8005ad:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8005b3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8005b9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8005be:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8005c4:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  8005ca:	8b 35 24 20 80 00    	mov    0x802024,%esi
  8005d0:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  8005d6:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  8005dc:	8b 15 34 20 80 00    	mov    0x802034,%edx
  8005e2:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  8005e8:	a1 3c 20 80 00       	mov    0x80203c,%eax
  8005ed:	8b 25 48 20 80 00    	mov    0x802048,%esp
  8005f3:	50                   	push   %eax
  8005f4:	9c                   	pushf  
  8005f5:	58                   	pop    %eax
  8005f6:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8005fb:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  8005fc:	b8 00 00 40 00       	mov    $0x400000,%eax
  800601:	8b 00                	mov    (%eax),%eax
  800603:	83 f8 2a             	cmp    $0x2a,%eax
  800606:	74 0c                	je     800614 <umain+0xe5>
		cprintf("EIP after page-fault MISMATCH\n");
  800608:	c7 04 24 7c 1b 80 00 	movl   $0x801b7c,(%esp)
  80060f:	e8 b6 01 00 00       	call   8007ca <cprintf>
	after.eip = before.eip;
  800614:	a1 40 20 80 00       	mov    0x802040,%eax
  800619:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80061e:	c7 44 24 10 9b 1b 80 	movl   $0x801b9b,0x10(%esp)
  800625:	00 
  800626:	c7 44 24 0c ac 1b 80 	movl   $0x801bac,0xc(%esp)
  80062d:	00 
  80062e:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  800635:	00 
  800636:	c7 44 24 04 5f 1b 80 	movl   $0x801b5f,0x4(%esp)
  80063d:	00 
  80063e:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  800645:	e8 e9 f9 ff ff       	call   800033 <check_regs>
}
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800652:	e8 a8 0e 00 00       	call   8014ff <sys_getenvid>
  800657:	25 ff 03 00 00       	and    $0x3ff,%eax
  80065c:	c1 e0 02             	shl    $0x2,%eax
  80065f:	89 c2                	mov    %eax,%edx
  800661:	c1 e2 05             	shl    $0x5,%edx
  800664:	29 c2                	sub    %eax,%edx
  800666:	89 d0                	mov    %edx,%eax
  800668:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80066d:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800672:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800676:	7e 0a                	jle    800682 <libmain+0x36>
		binaryname = argv[0];
  800678:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800682:	8b 45 0c             	mov    0xc(%ebp),%eax
  800685:	89 44 24 04          	mov    %eax,0x4(%esp)
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	89 04 24             	mov    %eax,(%esp)
  80068f:	e8 9b fe ff ff       	call   80052f <umain>

	// exit gracefully
	exit();
  800694:	e8 02 00 00 00       	call   80069b <exit>
}
  800699:	c9                   	leave  
  80069a:	c3                   	ret    

0080069b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8006a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a8:	e8 0f 0e 00 00       	call   8014bc <sys_env_destroy>
}
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    

008006af <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006bc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8006c2:	e8 38 0e 00 00       	call   8014ff <sys_getenvid>
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ca:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	c7 04 24 bc 1b 80 00 	movl   $0x801bbc,(%esp)
  8006e4:	e8 e1 00 00 00       	call   8007ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f3:	89 04 24             	mov    %eax,(%esp)
  8006f6:	e8 6b 00 00 00       	call   800766 <vcprintf>
	cprintf("\n");
  8006fb:	c7 04 24 df 1b 80 00 	movl   $0x801bdf,(%esp)
  800702:	e8 c3 00 00 00       	call   8007ca <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800707:	cc                   	int3   
  800708:	eb fd                	jmp    800707 <_panic+0x58>

0080070a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800710:	8b 45 0c             	mov    0xc(%ebp),%eax
  800713:	8b 00                	mov    (%eax),%eax
  800715:	8d 48 01             	lea    0x1(%eax),%ecx
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071b:	89 0a                	mov    %ecx,(%edx)
  80071d:	8b 55 08             	mov    0x8(%ebp),%edx
  800720:	89 d1                	mov    %edx,%ecx
  800722:	8b 55 0c             	mov    0xc(%ebp),%edx
  800725:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072c:	8b 00                	mov    (%eax),%eax
  80072e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800733:	75 20                	jne    800755 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800735:	8b 45 0c             	mov    0xc(%ebp),%eax
  800738:	8b 00                	mov    (%eax),%eax
  80073a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073d:	83 c2 08             	add    $0x8,%edx
  800740:	89 44 24 04          	mov    %eax,0x4(%esp)
  800744:	89 14 24             	mov    %edx,(%esp)
  800747:	e8 ea 0c 00 00       	call   801436 <sys_cputs>
		b->idx = 0;
  80074c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800755:	8b 45 0c             	mov    0xc(%ebp),%eax
  800758:	8b 40 04             	mov    0x4(%eax),%eax
  80075b:	8d 50 01             	lea    0x1(%eax),%edx
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800761:	89 50 04             	mov    %edx,0x4(%eax)
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80076f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800776:	00 00 00 
	b.cnt = 0;
  800779:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800780:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800783:	8b 45 0c             	mov    0xc(%ebp),%eax
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 08             	mov    0x8(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079b:	c7 04 24 0a 07 80 00 	movl   $0x80070a,(%esp)
  8007a2:	e8 bd 01 00 00       	call   800964 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8007ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007b7:	83 c0 08             	add    $0x8,%eax
  8007ba:	89 04 24             	mov    %eax,(%esp)
  8007bd:	e8 74 0c 00 00       	call   801436 <sys_cputs>

	return b.cnt;
  8007c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007d0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8007d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 7e ff ff ff       	call   800766 <vcprintf>
  8007e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 34             	sub    $0x34,%esp
  8007f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800803:	8b 45 18             	mov    0x18(%ebp),%eax
  800806:	ba 00 00 00 00       	mov    $0x0,%edx
  80080b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80080e:	77 72                	ja     800882 <printnum+0x92>
  800810:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800813:	72 05                	jb     80081a <printnum+0x2a>
  800815:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800818:	77 68                	ja     800882 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80081a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80081d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800820:	8b 45 18             	mov    0x18(%ebp),%eax
  800823:	ba 00 00 00 00       	mov    $0x0,%edx
  800828:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800833:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800836:	89 04 24             	mov    %eax,(%esp)
  800839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083d:	e8 be 0f 00 00       	call   801800 <__udivdi3>
  800842:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800845:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800849:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80084d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800850:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800854:	89 44 24 08          	mov    %eax,0x8(%esp)
  800858:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80085c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 82 ff ff ff       	call   8007f0 <printnum>
  80086e:	eb 1c                	jmp    80088c <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800870:	8b 45 0c             	mov    0xc(%ebp),%eax
  800873:	89 44 24 04          	mov    %eax,0x4(%esp)
  800877:	8b 45 20             	mov    0x20(%ebp),%eax
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800882:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800886:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80088a:	7f e4                	jg     800870 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80088c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80088f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800897:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80089a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80089e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008a2:	89 04 24             	mov    %eax,(%esp)
  8008a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a9:	e8 82 10 00 00       	call   801930 <__umoddi3>
  8008ae:	05 c8 1c 80 00       	add    $0x801cc8,%eax
  8008b3:	0f b6 00             	movzbl (%eax),%eax
  8008b6:	0f be c0             	movsbl %al,%eax
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	ff d0                	call   *%eax
}
  8008c8:	83 c4 34             	add    $0x34,%esp
  8008cb:	5b                   	pop    %ebx
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8008d1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8008d5:	7e 14                	jle    8008eb <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 00                	mov    (%eax),%eax
  8008dc:	8d 48 08             	lea    0x8(%eax),%ecx
  8008df:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e2:	89 0a                	mov    %ecx,(%edx)
  8008e4:	8b 50 04             	mov    0x4(%eax),%edx
  8008e7:	8b 00                	mov    (%eax),%eax
  8008e9:	eb 30                	jmp    80091b <getuint+0x4d>
	else if (lflag)
  8008eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008ef:	74 16                	je     800907 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	8b 00                	mov    (%eax),%eax
  8008f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8008f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fc:	89 0a                	mov    %ecx,(%edx)
  8008fe:	8b 00                	mov    (%eax),%eax
  800900:	ba 00 00 00 00       	mov    $0x0,%edx
  800905:	eb 14                	jmp    80091b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 00                	mov    (%eax),%eax
  80090c:	8d 48 04             	lea    0x4(%eax),%ecx
  80090f:	8b 55 08             	mov    0x8(%ebp),%edx
  800912:	89 0a                	mov    %ecx,(%edx)
  800914:	8b 00                	mov    (%eax),%eax
  800916:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800920:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800924:	7e 14                	jle    80093a <getint+0x1d>
		return va_arg(*ap, long long);
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 00                	mov    (%eax),%eax
  80092b:	8d 48 08             	lea    0x8(%eax),%ecx
  80092e:	8b 55 08             	mov    0x8(%ebp),%edx
  800931:	89 0a                	mov    %ecx,(%edx)
  800933:	8b 50 04             	mov    0x4(%eax),%edx
  800936:	8b 00                	mov    (%eax),%eax
  800938:	eb 28                	jmp    800962 <getint+0x45>
	else if (lflag)
  80093a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80093e:	74 12                	je     800952 <getint+0x35>
		return va_arg(*ap, long);
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 00                	mov    (%eax),%eax
  800945:	8d 48 04             	lea    0x4(%eax),%ecx
  800948:	8b 55 08             	mov    0x8(%ebp),%edx
  80094b:	89 0a                	mov    %ecx,(%edx)
  80094d:	8b 00                	mov    (%eax),%eax
  80094f:	99                   	cltd   
  800950:	eb 10                	jmp    800962 <getint+0x45>
	else
		return va_arg(*ap, int);
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	8b 00                	mov    (%eax),%eax
  800957:	8d 48 04             	lea    0x4(%eax),%ecx
  80095a:	8b 55 08             	mov    0x8(%ebp),%edx
  80095d:	89 0a                	mov    %ecx,(%edx)
  80095f:	8b 00                	mov    (%eax),%eax
  800961:	99                   	cltd   
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80096c:	eb 18                	jmp    800986 <vprintfmt+0x22>
			if (ch == '\0')
  80096e:	85 db                	test   %ebx,%ebx
  800970:	75 05                	jne    800977 <vprintfmt+0x13>
				return;
  800972:	e9 cc 03 00 00       	jmp    800d43 <vprintfmt+0x3df>
			putch(ch, putdat);
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097e:	89 1c 24             	mov    %ebx,(%esp)
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800986:	8b 45 10             	mov    0x10(%ebp),%eax
  800989:	8d 50 01             	lea    0x1(%eax),%edx
  80098c:	89 55 10             	mov    %edx,0x10(%ebp)
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 d8             	movzbl %al,%ebx
  800995:	83 fb 25             	cmp    $0x25,%ebx
  800998:	75 d4                	jne    80096e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80099a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80099e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8009a5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8009ac:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8009b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8009bd:	8d 50 01             	lea    0x1(%eax),%edx
  8009c0:	89 55 10             	mov    %edx,0x10(%ebp)
  8009c3:	0f b6 00             	movzbl (%eax),%eax
  8009c6:	0f b6 d8             	movzbl %al,%ebx
  8009c9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8009cc:	83 f8 55             	cmp    $0x55,%eax
  8009cf:	0f 87 3d 03 00 00    	ja     800d12 <vprintfmt+0x3ae>
  8009d5:	8b 04 85 ec 1c 80 00 	mov    0x801cec(,%eax,4),%eax
  8009dc:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8009de:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8009e2:	eb d6                	jmp    8009ba <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009e4:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8009e8:	eb d0                	jmp    8009ba <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009ea:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8009f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009f4:	89 d0                	mov    %edx,%eax
  8009f6:	c1 e0 02             	shl    $0x2,%eax
  8009f9:	01 d0                	add    %edx,%eax
  8009fb:	01 c0                	add    %eax,%eax
  8009fd:	01 d8                	add    %ebx,%eax
  8009ff:	83 e8 30             	sub    $0x30,%eax
  800a02:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800a05:	8b 45 10             	mov    0x10(%ebp),%eax
  800a08:	0f b6 00             	movzbl (%eax),%eax
  800a0b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800a0e:	83 fb 2f             	cmp    $0x2f,%ebx
  800a11:	7e 0b                	jle    800a1e <vprintfmt+0xba>
  800a13:	83 fb 39             	cmp    $0x39,%ebx
  800a16:	7f 06                	jg     800a1e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a18:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a1c:	eb d3                	jmp    8009f1 <vprintfmt+0x8d>
			goto process_precision;
  800a1e:	eb 33                	jmp    800a53 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800a20:	8b 45 14             	mov    0x14(%ebp),%eax
  800a23:	8d 50 04             	lea    0x4(%eax),%edx
  800a26:	89 55 14             	mov    %edx,0x14(%ebp)
  800a29:	8b 00                	mov    (%eax),%eax
  800a2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800a2e:	eb 23                	jmp    800a53 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800a30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a34:	79 0c                	jns    800a42 <vprintfmt+0xde>
				width = 0;
  800a36:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800a3d:	e9 78 ff ff ff       	jmp    8009ba <vprintfmt+0x56>
  800a42:	e9 73 ff ff ff       	jmp    8009ba <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800a47:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800a4e:	e9 67 ff ff ff       	jmp    8009ba <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800a53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a57:	79 12                	jns    800a6b <vprintfmt+0x107>
				width = precision, precision = -1;
  800a59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a5f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800a66:	e9 4f ff ff ff       	jmp    8009ba <vprintfmt+0x56>
  800a6b:	e9 4a ff ff ff       	jmp    8009ba <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a70:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800a74:	e9 41 ff ff ff       	jmp    8009ba <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a79:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7c:	8d 50 04             	lea    0x4(%eax),%edx
  800a7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a82:	8b 00                	mov    (%eax),%eax
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a87:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a8b:	89 04 24             	mov    %eax,(%esp)
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	ff d0                	call   *%eax
			break;
  800a93:	e9 a5 02 00 00       	jmp    800d3d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8d 50 04             	lea    0x4(%eax),%edx
  800a9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa1:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	79 02                	jns    800aa9 <vprintfmt+0x145>
				err = -err;
  800aa7:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800aa9:	83 fb 09             	cmp    $0x9,%ebx
  800aac:	7f 0b                	jg     800ab9 <vprintfmt+0x155>
  800aae:	8b 34 9d a0 1c 80 00 	mov    0x801ca0(,%ebx,4),%esi
  800ab5:	85 f6                	test   %esi,%esi
  800ab7:	75 23                	jne    800adc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800ab9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800abd:	c7 44 24 08 d9 1c 80 	movl   $0x801cd9,0x8(%esp)
  800ac4:	00 
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	89 04 24             	mov    %eax,(%esp)
  800ad2:	e8 73 02 00 00       	call   800d4a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800ad7:	e9 61 02 00 00       	jmp    800d3d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800adc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ae0:	c7 44 24 08 e2 1c 80 	movl   $0x801ce2,0x8(%esp)
  800ae7:	00 
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	89 04 24             	mov    %eax,(%esp)
  800af5:	e8 50 02 00 00       	call   800d4a <printfmt>
			break;
  800afa:	e9 3e 02 00 00       	jmp    800d3d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800aff:	8b 45 14             	mov    0x14(%ebp),%eax
  800b02:	8d 50 04             	lea    0x4(%eax),%edx
  800b05:	89 55 14             	mov    %edx,0x14(%ebp)
  800b08:	8b 30                	mov    (%eax),%esi
  800b0a:	85 f6                	test   %esi,%esi
  800b0c:	75 05                	jne    800b13 <vprintfmt+0x1af>
				p = "(null)";
  800b0e:	be e5 1c 80 00       	mov    $0x801ce5,%esi
			if (width > 0 && padc != '-')
  800b13:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b17:	7e 37                	jle    800b50 <vprintfmt+0x1ec>
  800b19:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800b1d:	74 31                	je     800b50 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b26:	89 34 24             	mov    %esi,(%esp)
  800b29:	e8 39 03 00 00       	call   800e67 <strnlen>
  800b2e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800b31:	eb 17                	jmp    800b4a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800b33:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b3e:	89 04 24             	mov    %eax,(%esp)
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b46:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b4a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b4e:	7f e3                	jg     800b33 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b50:	eb 38                	jmp    800b8a <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800b52:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b56:	74 1f                	je     800b77 <vprintfmt+0x213>
  800b58:	83 fb 1f             	cmp    $0x1f,%ebx
  800b5b:	7e 05                	jle    800b62 <vprintfmt+0x1fe>
  800b5d:	83 fb 7e             	cmp    $0x7e,%ebx
  800b60:	7e 15                	jle    800b77 <vprintfmt+0x213>
					putch('?', putdat);
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b69:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	ff d0                	call   *%eax
  800b75:	eb 0f                	jmp    800b86 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7e:	89 1c 24             	mov    %ebx,(%esp)
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b86:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b8a:	89 f0                	mov    %esi,%eax
  800b8c:	8d 70 01             	lea    0x1(%eax),%esi
  800b8f:	0f b6 00             	movzbl (%eax),%eax
  800b92:	0f be d8             	movsbl %al,%ebx
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	74 10                	je     800ba9 <vprintfmt+0x245>
  800b99:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b9d:	78 b3                	js     800b52 <vprintfmt+0x1ee>
  800b9f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800ba3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ba7:	79 a9                	jns    800b52 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ba9:	eb 17                	jmp    800bc2 <vprintfmt+0x25e>
				putch(' ', putdat);
  800bab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bbe:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800bc2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bc6:	7f e3                	jg     800bab <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800bc8:	e9 70 01 00 00       	jmp    800d3d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd4:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd7:	89 04 24             	mov    %eax,(%esp)
  800bda:	e8 3e fd ff ff       	call   80091d <getint>
  800bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800be2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800beb:	85 d2                	test   %edx,%edx
  800bed:	79 26                	jns    800c15 <vprintfmt+0x2b1>
				putch('-', putdat);
  800bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	ff d0                	call   *%eax
				num = -(long long) num;
  800c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c08:	f7 d8                	neg    %eax
  800c0a:	83 d2 00             	adc    $0x0,%edx
  800c0d:	f7 da                	neg    %edx
  800c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c12:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800c15:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800c1c:	e9 a8 00 00 00       	jmp    800cc9 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c21:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c28:	8d 45 14             	lea    0x14(%ebp),%eax
  800c2b:	89 04 24             	mov    %eax,(%esp)
  800c2e:	e8 9b fc ff ff       	call   8008ce <getuint>
  800c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c36:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800c39:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800c40:	e9 84 00 00 00       	jmp    800cc9 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800c45:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4c:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4f:	89 04 24             	mov    %eax,(%esp)
  800c52:	e8 77 fc ff ff       	call   8008ce <getuint>
  800c57:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800c5d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800c64:	eb 63                	jmp    800cc9 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800c66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	ff d0                	call   *%eax
			putch('x', putdat);
  800c79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c80:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8a:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8f:	8d 50 04             	lea    0x4(%eax),%edx
  800c92:	89 55 14             	mov    %edx,0x14(%ebp)
  800c95:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ca1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ca8:	eb 1f                	jmp    800cc9 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800caa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800cad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb1:	8d 45 14             	lea    0x14(%ebp),%eax
  800cb4:	89 04 24             	mov    %eax,(%esp)
  800cb7:	e8 12 fc ff ff       	call   8008ce <getuint>
  800cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800cc2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cc9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ccd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd0:	89 54 24 18          	mov    %edx,0x18(%esp)
  800cd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cd7:	89 54 24 14          	mov    %edx,0x14(%esp)
  800cdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ce9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	89 04 24             	mov    %eax,(%esp)
  800cfa:	e8 f1 fa ff ff       	call   8007f0 <printnum>
			break;
  800cff:	eb 3c                	jmp    800d3d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d08:	89 1c 24             	mov    %ebx,(%esp)
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	ff d0                	call   *%eax
			break;
  800d10:	eb 2b                	jmp    800d3d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d19:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d25:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d29:	eb 04                	jmp    800d2f <vprintfmt+0x3cb>
  800d2b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d32:	83 e8 01             	sub    $0x1,%eax
  800d35:	0f b6 00             	movzbl (%eax),%eax
  800d38:	3c 25                	cmp    $0x25,%al
  800d3a:	75 ef                	jne    800d2b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800d3c:	90                   	nop
		}
	}
  800d3d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d3e:	e9 43 fc ff ff       	jmp    800986 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800d43:	83 c4 40             	add    $0x40,%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800d50:	8d 45 14             	lea    0x14(%ebp),%eax
  800d53:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	89 04 24             	mov    %eax,(%esp)
  800d71:	e8 ee fb ff ff       	call   800964 <vprintfmt>
	va_end(ap);
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7e:	8b 40 08             	mov    0x8(%eax),%eax
  800d81:	8d 50 01             	lea    0x1(%eax),%edx
  800d84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d87:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8d:	8b 10                	mov    (%eax),%edx
  800d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d92:	8b 40 04             	mov    0x4(%eax),%eax
  800d95:	39 c2                	cmp    %eax,%edx
  800d97:	73 12                	jae    800dab <sprintputch+0x33>
		*b->buf++ = ch;
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	8b 00                	mov    (%eax),%eax
  800d9e:	8d 48 01             	lea    0x1(%eax),%ecx
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da4:	89 0a                	mov    %ecx,(%edx)
  800da6:	8b 55 08             	mov    0x8(%ebp),%edx
  800da9:	88 10                	mov    %dl,(%eax)
}
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800db9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbc:	8d 50 ff             	lea    -0x1(%eax),%edx
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	01 d0                	add    %edx,%eax
  800dc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800dc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800dce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800dd2:	74 06                	je     800dda <vsnprintf+0x2d>
  800dd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd8:	7f 07                	jg     800de1 <vsnprintf+0x34>
		return -E_INVAL;
  800dda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ddf:	eb 2a                	jmp    800e0b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800de1:	8b 45 14             	mov    0x14(%ebp),%eax
  800de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de8:	8b 45 10             	mov    0x10(%ebp),%eax
  800deb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800def:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df6:	c7 04 24 78 0d 80 00 	movl   $0x800d78,(%esp)
  800dfd:	e8 62 fb ff ff       	call   800964 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e02:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e05:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    

00800e0d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e13:	8d 45 14             	lea    0x14(%ebp),%eax
  800e16:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e20:	8b 45 10             	mov    0x10(%ebp),%eax
  800e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	89 04 24             	mov    %eax,(%esp)
  800e34:	e8 74 ff ff ff       	call   800dad <vsnprintf>
  800e39:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    

00800e41 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800e47:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e4e:	eb 08                	jmp    800e58 <strlen+0x17>
		n++;
  800e50:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e54:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	0f b6 00             	movzbl (%eax),%eax
  800e5e:	84 c0                	test   %al,%al
  800e60:	75 ee                	jne    800e50 <strlen+0xf>
		n++;
	return n;
  800e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e6d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e74:	eb 0c                	jmp    800e82 <strnlen+0x1b>
		n++;
  800e76:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e7a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e7e:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800e82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e86:	74 0a                	je     800e92 <strnlen+0x2b>
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	0f b6 00             	movzbl (%eax),%eax
  800e8e:	84 c0                	test   %al,%al
  800e90:	75 e4                	jne    800e76 <strnlen+0xf>
		n++;
	return n;
  800e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800ea3:	90                   	nop
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea7:	8d 50 01             	lea    0x1(%eax),%edx
  800eaa:	89 55 08             	mov    %edx,0x8(%ebp)
  800ead:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb0:	8d 4a 01             	lea    0x1(%edx),%ecx
  800eb3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800eb6:	0f b6 12             	movzbl (%edx),%edx
  800eb9:	88 10                	mov    %dl,(%eax)
  800ebb:	0f b6 00             	movzbl (%eax),%eax
  800ebe:	84 c0                	test   %al,%al
  800ec0:	75 e2                	jne    800ea4 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ec2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	89 04 24             	mov    %eax,(%esp)
  800ed3:	e8 69 ff ff ff       	call   800e41 <strlen>
  800ed8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800edb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	01 c2                	add    %eax,%edx
  800ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eea:	89 14 24             	mov    %edx,(%esp)
  800eed:	e8 a5 ff ff ff       	call   800e97 <strcpy>
	return dst;
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800f03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800f0a:	eb 23                	jmp    800f2f <strncpy+0x38>
		*dst++ = *src;
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	8d 50 01             	lea    0x1(%eax),%edx
  800f12:	89 55 08             	mov    %edx,0x8(%ebp)
  800f15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f18:	0f b6 12             	movzbl (%edx),%edx
  800f1b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	0f b6 00             	movzbl (%eax),%eax
  800f23:	84 c0                	test   %al,%al
  800f25:	74 04                	je     800f2b <strncpy+0x34>
			src++;
  800f27:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f2b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800f2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f32:	3b 45 10             	cmp    0x10(%ebp),%eax
  800f35:	72 d5                	jb     800f0c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800f37:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800f42:	8b 45 08             	mov    0x8(%ebp),%eax
  800f45:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800f48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4c:	74 33                	je     800f81 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800f4e:	eb 17                	jmp    800f67 <strlcpy+0x2b>
			*dst++ = *src++;
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
  800f53:	8d 50 01             	lea    0x1(%eax),%edx
  800f56:	89 55 08             	mov    %edx,0x8(%ebp)
  800f59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800f5f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800f62:	0f b6 12             	movzbl (%edx),%edx
  800f65:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f67:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800f6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6f:	74 0a                	je     800f7b <strlcpy+0x3f>
  800f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f74:	0f b6 00             	movzbl (%eax),%eax
  800f77:	84 c0                	test   %al,%al
  800f79:	75 d5                	jne    800f50 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f87:	29 c2                	sub    %eax,%edx
  800f89:	89 d0                	mov    %edx,%eax
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800f90:	eb 08                	jmp    800f9a <strcmp+0xd>
		p++, q++;
  800f92:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f96:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9d:	0f b6 00             	movzbl (%eax),%eax
  800fa0:	84 c0                	test   %al,%al
  800fa2:	74 10                	je     800fb4 <strcmp+0x27>
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	0f b6 10             	movzbl (%eax),%edx
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	0f b6 00             	movzbl (%eax),%eax
  800fb0:	38 c2                	cmp    %al,%dl
  800fb2:	74 de                	je     800f92 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb7:	0f b6 00             	movzbl (%eax),%eax
  800fba:	0f b6 d0             	movzbl %al,%edx
  800fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc0:	0f b6 00             	movzbl (%eax),%eax
  800fc3:	0f b6 c0             	movzbl %al,%eax
  800fc6:	29 c2                	sub    %eax,%edx
  800fc8:	89 d0                	mov    %edx,%eax
}
  800fca:	5d                   	pop    %ebp
  800fcb:	c3                   	ret    

00800fcc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800fcf:	eb 0c                	jmp    800fdd <strncmp+0x11>
		n--, p++, q++;
  800fd1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800fd5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fd9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fe1:	74 1a                	je     800ffd <strncmp+0x31>
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	0f b6 00             	movzbl (%eax),%eax
  800fe9:	84 c0                	test   %al,%al
  800feb:	74 10                	je     800ffd <strncmp+0x31>
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	0f b6 10             	movzbl (%eax),%edx
  800ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff6:	0f b6 00             	movzbl (%eax),%eax
  800ff9:	38 c2                	cmp    %al,%dl
  800ffb:	74 d4                	je     800fd1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ffd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801001:	75 07                	jne    80100a <strncmp+0x3e>
		return 0;
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
  801008:	eb 16                	jmp    801020 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	0f b6 00             	movzbl (%eax),%eax
  801010:	0f b6 d0             	movzbl %al,%edx
  801013:	8b 45 0c             	mov    0xc(%ebp),%eax
  801016:	0f b6 00             	movzbl (%eax),%eax
  801019:	0f b6 c0             	movzbl %al,%eax
  80101c:	29 c2                	sub    %eax,%edx
  80101e:	89 d0                	mov    %edx,%eax
}
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 04             	sub    $0x4,%esp
  801028:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  80102e:	eb 14                	jmp    801044 <strchr+0x22>
		if (*s == c)
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	0f b6 00             	movzbl (%eax),%eax
  801036:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801039:	75 05                	jne    801040 <strchr+0x1e>
			return (char *) s;
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	eb 13                	jmp    801053 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801040:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	0f b6 00             	movzbl (%eax),%eax
  80104a:	84 c0                	test   %al,%al
  80104c:	75 e2                	jne    801030 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801061:	eb 11                	jmp    801074 <strfind+0x1f>
		if (*s == c)
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	0f b6 00             	movzbl (%eax),%eax
  801069:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80106c:	75 02                	jne    801070 <strfind+0x1b>
			break;
  80106e:	eb 0e                	jmp    80107e <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801070:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801074:	8b 45 08             	mov    0x8(%ebp),%eax
  801077:	0f b6 00             	movzbl (%eax),%eax
  80107a:	84 c0                	test   %al,%al
  80107c:	75 e5                	jne    801063 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
	char *p;

	if (n == 0)
  801087:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108b:	75 05                	jne    801092 <memset+0xf>
		return v;
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	eb 5c                	jmp    8010ee <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	83 e0 03             	and    $0x3,%eax
  801098:	85 c0                	test   %eax,%eax
  80109a:	75 41                	jne    8010dd <memset+0x5a>
  80109c:	8b 45 10             	mov    0x10(%ebp),%eax
  80109f:	83 e0 03             	and    $0x3,%eax
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	75 37                	jne    8010dd <memset+0x5a>
		c &= 0xFF;
  8010a6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8010ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b0:	c1 e0 18             	shl    $0x18,%eax
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b8:	c1 e0 10             	shl    $0x10,%eax
  8010bb:	09 c2                	or     %eax,%edx
  8010bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c0:	c1 e0 08             	shl    $0x8,%eax
  8010c3:	09 d0                	or     %edx,%eax
  8010c5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8010c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010cb:	c1 e8 02             	shr    $0x2,%eax
  8010ce:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8010d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d6:	89 d7                	mov    %edx,%edi
  8010d8:	fc                   	cld    
  8010d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8010db:	eb 0e                	jmp    8010eb <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010e6:	89 d7                	mov    %edx,%edi
  8010e8:	fc                   	cld    
  8010e9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8010fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  801106:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801109:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  80110c:	73 6d                	jae    80117b <memmove+0x8a>
  80110e:	8b 45 10             	mov    0x10(%ebp),%eax
  801111:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801114:	01 d0                	add    %edx,%eax
  801116:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  801119:	76 60                	jbe    80117b <memmove+0x8a>
		s += n;
  80111b:	8b 45 10             	mov    0x10(%ebp),%eax
  80111e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  801121:	8b 45 10             	mov    0x10(%ebp),%eax
  801124:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801127:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112a:	83 e0 03             	and    $0x3,%eax
  80112d:	85 c0                	test   %eax,%eax
  80112f:	75 2f                	jne    801160 <memmove+0x6f>
  801131:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801134:	83 e0 03             	and    $0x3,%eax
  801137:	85 c0                	test   %eax,%eax
  801139:	75 25                	jne    801160 <memmove+0x6f>
  80113b:	8b 45 10             	mov    0x10(%ebp),%eax
  80113e:	83 e0 03             	and    $0x3,%eax
  801141:	85 c0                	test   %eax,%eax
  801143:	75 1b                	jne    801160 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801145:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801148:	83 e8 04             	sub    $0x4,%eax
  80114b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114e:	83 ea 04             	sub    $0x4,%edx
  801151:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801154:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801157:	89 c7                	mov    %eax,%edi
  801159:	89 d6                	mov    %edx,%esi
  80115b:	fd                   	std    
  80115c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80115e:	eb 18                	jmp    801178 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801160:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801163:	8d 50 ff             	lea    -0x1(%eax),%edx
  801166:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801169:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80116c:	8b 45 10             	mov    0x10(%ebp),%eax
  80116f:	89 d7                	mov    %edx,%edi
  801171:	89 de                	mov    %ebx,%esi
  801173:	89 c1                	mov    %eax,%ecx
  801175:	fd                   	std    
  801176:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801178:	fc                   	cld    
  801179:	eb 45                	jmp    8011c0 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80117b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117e:	83 e0 03             	and    $0x3,%eax
  801181:	85 c0                	test   %eax,%eax
  801183:	75 2b                	jne    8011b0 <memmove+0xbf>
  801185:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801188:	83 e0 03             	and    $0x3,%eax
  80118b:	85 c0                	test   %eax,%eax
  80118d:	75 21                	jne    8011b0 <memmove+0xbf>
  80118f:	8b 45 10             	mov    0x10(%ebp),%eax
  801192:	83 e0 03             	and    $0x3,%eax
  801195:	85 c0                	test   %eax,%eax
  801197:	75 17                	jne    8011b0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801199:	8b 45 10             	mov    0x10(%ebp),%eax
  80119c:	c1 e8 02             	shr    $0x2,%eax
  80119f:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8011a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a7:	89 c7                	mov    %eax,%edi
  8011a9:	89 d6                	mov    %edx,%esi
  8011ab:	fc                   	cld    
  8011ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8011ae:	eb 10                	jmp    8011c0 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011b9:	89 c7                	mov    %eax,%edi
  8011bb:	89 d6                	mov    %edx,%esi
  8011bd:	fc                   	cld    
  8011be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	5b                   	pop    %ebx
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	89 04 24             	mov    %eax,(%esp)
  8011e5:	e8 07 ff ff ff       	call   8010f1 <memmove>
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  8011f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fb:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  8011fe:	eb 30                	jmp    801230 <memcmp+0x44>
		if (*s1 != *s2)
  801200:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801203:	0f b6 10             	movzbl (%eax),%edx
  801206:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801209:	0f b6 00             	movzbl (%eax),%eax
  80120c:	38 c2                	cmp    %al,%dl
  80120e:	74 18                	je     801228 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801210:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801213:	0f b6 00             	movzbl (%eax),%eax
  801216:	0f b6 d0             	movzbl %al,%edx
  801219:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80121c:	0f b6 00             	movzbl (%eax),%eax
  80121f:	0f b6 c0             	movzbl %al,%eax
  801222:	29 c2                	sub    %eax,%edx
  801224:	89 d0                	mov    %edx,%eax
  801226:	eb 1a                	jmp    801242 <memcmp+0x56>
		s1++, s2++;
  801228:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80122c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801230:	8b 45 10             	mov    0x10(%ebp),%eax
  801233:	8d 50 ff             	lea    -0x1(%eax),%edx
  801236:	89 55 10             	mov    %edx,0x10(%ebp)
  801239:	85 c0                	test   %eax,%eax
  80123b:	75 c3                	jne    801200 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80124a:	8b 45 10             	mov    0x10(%ebp),%eax
  80124d:	8b 55 08             	mov    0x8(%ebp),%edx
  801250:	01 d0                	add    %edx,%eax
  801252:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801255:	eb 13                	jmp    80126a <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801257:	8b 45 08             	mov    0x8(%ebp),%eax
  80125a:	0f b6 10             	movzbl (%eax),%edx
  80125d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801260:	38 c2                	cmp    %al,%dl
  801262:	75 02                	jne    801266 <memfind+0x22>
			break;
  801264:	eb 0c                	jmp    801272 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801266:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
  80126d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801270:	72 e5                	jb     801257 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80127d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801284:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80128b:	eb 04                	jmp    801291 <strtol+0x1a>
		s++;
  80128d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
  801294:	0f b6 00             	movzbl (%eax),%eax
  801297:	3c 20                	cmp    $0x20,%al
  801299:	74 f2                	je     80128d <strtol+0x16>
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	0f b6 00             	movzbl (%eax),%eax
  8012a1:	3c 09                	cmp    $0x9,%al
  8012a3:	74 e8                	je     80128d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	0f b6 00             	movzbl (%eax),%eax
  8012ab:	3c 2b                	cmp    $0x2b,%al
  8012ad:	75 06                	jne    8012b5 <strtol+0x3e>
		s++;
  8012af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012b3:	eb 15                	jmp    8012ca <strtol+0x53>
	else if (*s == '-')
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b8:	0f b6 00             	movzbl (%eax),%eax
  8012bb:	3c 2d                	cmp    $0x2d,%al
  8012bd:	75 0b                	jne    8012ca <strtol+0x53>
		s++, neg = 1;
  8012bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012c3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012ce:	74 06                	je     8012d6 <strtol+0x5f>
  8012d0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8012d4:	75 24                	jne    8012fa <strtol+0x83>
  8012d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d9:	0f b6 00             	movzbl (%eax),%eax
  8012dc:	3c 30                	cmp    $0x30,%al
  8012de:	75 1a                	jne    8012fa <strtol+0x83>
  8012e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e3:	83 c0 01             	add    $0x1,%eax
  8012e6:	0f b6 00             	movzbl (%eax),%eax
  8012e9:	3c 78                	cmp    $0x78,%al
  8012eb:	75 0d                	jne    8012fa <strtol+0x83>
		s += 2, base = 16;
  8012ed:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8012f1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8012f8:	eb 2a                	jmp    801324 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8012fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012fe:	75 17                	jne    801317 <strtol+0xa0>
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	0f b6 00             	movzbl (%eax),%eax
  801306:	3c 30                	cmp    $0x30,%al
  801308:	75 0d                	jne    801317 <strtol+0xa0>
		s++, base = 8;
  80130a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80130e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801315:	eb 0d                	jmp    801324 <strtol+0xad>
	else if (base == 0)
  801317:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80131b:	75 07                	jne    801324 <strtol+0xad>
		base = 10;
  80131d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	0f b6 00             	movzbl (%eax),%eax
  80132a:	3c 2f                	cmp    $0x2f,%al
  80132c:	7e 1b                	jle    801349 <strtol+0xd2>
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	0f b6 00             	movzbl (%eax),%eax
  801334:	3c 39                	cmp    $0x39,%al
  801336:	7f 11                	jg     801349 <strtol+0xd2>
			dig = *s - '0';
  801338:	8b 45 08             	mov    0x8(%ebp),%eax
  80133b:	0f b6 00             	movzbl (%eax),%eax
  80133e:	0f be c0             	movsbl %al,%eax
  801341:	83 e8 30             	sub    $0x30,%eax
  801344:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801347:	eb 48                	jmp    801391 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
  80134c:	0f b6 00             	movzbl (%eax),%eax
  80134f:	3c 60                	cmp    $0x60,%al
  801351:	7e 1b                	jle    80136e <strtol+0xf7>
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	0f b6 00             	movzbl (%eax),%eax
  801359:	3c 7a                	cmp    $0x7a,%al
  80135b:	7f 11                	jg     80136e <strtol+0xf7>
			dig = *s - 'a' + 10;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	0f b6 00             	movzbl (%eax),%eax
  801363:	0f be c0             	movsbl %al,%eax
  801366:	83 e8 57             	sub    $0x57,%eax
  801369:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80136c:	eb 23                	jmp    801391 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	0f b6 00             	movzbl (%eax),%eax
  801374:	3c 40                	cmp    $0x40,%al
  801376:	7e 3d                	jle    8013b5 <strtol+0x13e>
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	0f b6 00             	movzbl (%eax),%eax
  80137e:	3c 5a                	cmp    $0x5a,%al
  801380:	7f 33                	jg     8013b5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	0f b6 00             	movzbl (%eax),%eax
  801388:	0f be c0             	movsbl %al,%eax
  80138b:	83 e8 37             	sub    $0x37,%eax
  80138e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	3b 45 10             	cmp    0x10(%ebp),%eax
  801397:	7c 02                	jl     80139b <strtol+0x124>
			break;
  801399:	eb 1a                	jmp    8013b5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80139b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80139f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013a2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ab:	01 d0                	add    %edx,%eax
  8013ad:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8013b0:	e9 6f ff ff ff       	jmp    801324 <strtol+0xad>

	if (endptr)
  8013b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013b9:	74 08                	je     8013c3 <strtol+0x14c>
		*endptr = (char *) s;
  8013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013be:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8013c3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8013c7:	74 07                	je     8013d0 <strtol+0x159>
  8013c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013cc:	f7 d8                	neg    %eax
  8013ce:	eb 03                	jmp    8013d3 <strtol+0x15c>
  8013d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	57                   	push   %edi
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
  8013db:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8013e4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8013e7:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8013ea:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8013ed:	8b 75 20             	mov    0x20(%ebp),%esi
  8013f0:	cd 30                	int    $0x30
  8013f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013f9:	74 30                	je     80142b <syscall+0x56>
  8013fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8013ff:	7e 2a                	jle    80142b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  801401:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801404:	89 44 24 10          	mov    %eax,0x10(%esp)
  801408:	8b 45 08             	mov    0x8(%ebp),%eax
  80140b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140f:	c7 44 24 08 44 1e 80 	movl   $0x801e44,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80141e:	00 
  80141f:	c7 04 24 61 1e 80 00 	movl   $0x801e61,(%esp)
  801426:	e8 84 f2 ff ff       	call   8006af <_panic>

	return ret;
  80142b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80142e:	83 c4 3c             	add    $0x3c,%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801446:	00 
  801447:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80144e:	00 
  80144f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801456:	00 
  801457:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80145e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801462:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801469:	00 
  80146a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801471:	e8 5f ff ff ff       	call   8013d5 <syscall>
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <sys_cgetc>:

int
sys_cgetc(void)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80147e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801485:	00 
  801486:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80148d:	00 
  80148e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801495:	00 
  801496:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80149d:	00 
  80149e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014a5:	00 
  8014a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ad:	00 
  8014ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014b5:	e8 1b ff ff ff       	call   8013d5 <syscall>
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8014c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8014cc:	00 
  8014cd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8014d4:	00 
  8014d5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8014dc:	00 
  8014dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014e4:	00 
  8014e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014f0:	00 
  8014f1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8014f8:	e8 d8 fe ff ff       	call   8013d5 <syscall>
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    

008014ff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801505:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80150c:	00 
  80150d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801514:	00 
  801515:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80151c:	00 
  80151d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801524:	00 
  801525:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152c:	00 
  80152d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801534:	00 
  801535:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80153c:	e8 94 fe ff ff       	call   8013d5 <syscall>
}
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <sys_yield>:

void
sys_yield(void)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801549:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801550:	00 
  801551:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801558:	00 
  801559:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801560:	00 
  801561:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801568:	00 
  801569:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801570:	00 
  801571:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801578:	00 
  801579:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801580:	e8 50 fe ff ff       	call   8013d5 <syscall>
}
  801585:	c9                   	leave  
  801586:	c3                   	ret    

00801587 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80158d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801590:	8b 55 0c             	mov    0xc(%ebp),%edx
  801593:	8b 45 08             	mov    0x8(%ebp),%eax
  801596:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80159d:	00 
  80159e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8015a5:	00 
  8015a6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8015aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015b9:	00 
  8015ba:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8015c1:	e8 0f fe ff ff       	call   8013d5 <syscall>
}
  8015c6:	c9                   	leave  
  8015c7:	c3                   	ret    

008015c8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8015d0:	8b 75 18             	mov    0x18(%ebp),%esi
  8015d3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8015d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015df:	89 74 24 18          	mov    %esi,0x18(%esp)
  8015e3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8015e7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8015eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015fa:	00 
  8015fb:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  801602:	e8 ce fd ff ff       	call   8013d5 <syscall>
}
  801607:	83 c4 20             	add    $0x20,%esp
  80160a:	5b                   	pop    %ebx
  80160b:	5e                   	pop    %esi
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801621:	00 
  801622:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801629:	00 
  80162a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801631:	00 
  801632:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801636:	89 44 24 08          	mov    %eax,0x8(%esp)
  80163a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801641:	00 
  801642:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801649:	e8 87 fd ff ff       	call   8013d5 <syscall>
}
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801656:	8b 55 0c             	mov    0xc(%ebp),%edx
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801663:	00 
  801664:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80166b:	00 
  80166c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801673:	00 
  801674:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801678:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801683:	00 
  801684:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80168b:	e8 45 fd ff ff       	call   8013d5 <syscall>
}
  801690:	c9                   	leave  
  801691:	c3                   	ret    

00801692 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801698:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8016a5:	00 
  8016a6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8016ad:	00 
  8016ae:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8016b5:	00 
  8016b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016c5:	00 
  8016c6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8016cd:	e8 03 fd ff ff       	call   8013d5 <syscall>
}
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8016da:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8016dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8016ea:	00 
  8016eb:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8016ef:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801705:	00 
  801706:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  80170d:	e8 c3 fc ff ff       	call   8013d5 <syscall>
}
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801714:	55                   	push   %ebp
  801715:	89 e5                	mov    %esp,%ebp
  801717:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801724:	00 
  801725:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80172c:	00 
  80172d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801734:	00 
  801735:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80173c:	00 
  80173d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801741:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801748:	00 
  801749:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801750:	e8 80 fc ff ff       	call   8013d5 <syscall>
}
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80175d:	a1 d0 20 80 00       	mov    0x8020d0,%eax
  801762:	85 c0                	test   %eax,%eax
  801764:	75 5d                	jne    8017c3 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801766:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  80176b:	8b 40 48             	mov    0x48(%eax),%eax
  80176e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801775:	00 
  801776:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80177d:	ee 
  80177e:	89 04 24             	mov    %eax,(%esp)
  801781:	e8 01 fe ff ff       	call   801587 <sys_page_alloc>
  801786:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801789:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80178d:	79 1c                	jns    8017ab <set_pgfault_handler+0x54>
  80178f:	c7 44 24 08 70 1e 80 	movl   $0x801e70,0x8(%esp)
  801796:	00 
  801797:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80179e:	00 
  80179f:	c7 04 24 9c 1e 80 00 	movl   $0x801e9c,(%esp)
  8017a6:	e8 04 ef ff ff       	call   8006af <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8017ab:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8017b0:	8b 40 48             	mov    0x48(%eax),%eax
  8017b3:	c7 44 24 04 cd 17 80 	movl   $0x8017cd,0x4(%esp)
  8017ba:	00 
  8017bb:	89 04 24             	mov    %eax,(%esp)
  8017be:	e8 cf fe ff ff       	call   801692 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    

008017cd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017cd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017ce:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  8017d3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8017d5:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8017d8:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  8017dc:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  8017de:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  8017e2:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  8017e3:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  8017e6:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  8017e8:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  8017e9:	58                   	pop    %eax
	popal 						// pop all the registers
  8017ea:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  8017eb:	83 c4 04             	add    $0x4,%esp
	popfl
  8017ee:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  8017ef:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8017f0:	c3                   	ret    
  8017f1:	66 90                	xchg   %ax,%ax
  8017f3:	66 90                	xchg   %ax,%ax
  8017f5:	66 90                	xchg   %ax,%ax
  8017f7:	66 90                	xchg   %ax,%ax
  8017f9:	66 90                	xchg   %ax,%ax
  8017fb:	66 90                	xchg   %ax,%ax
  8017fd:	66 90                	xchg   %ax,%ax
  8017ff:	90                   	nop

00801800 <__udivdi3>:
  801800:	55                   	push   %ebp
  801801:	57                   	push   %edi
  801802:	56                   	push   %esi
  801803:	83 ec 0c             	sub    $0xc,%esp
  801806:	8b 44 24 28          	mov    0x28(%esp),%eax
  80180a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80180e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801812:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801816:	85 c0                	test   %eax,%eax
  801818:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80181c:	89 ea                	mov    %ebp,%edx
  80181e:	89 0c 24             	mov    %ecx,(%esp)
  801821:	75 2d                	jne    801850 <__udivdi3+0x50>
  801823:	39 e9                	cmp    %ebp,%ecx
  801825:	77 61                	ja     801888 <__udivdi3+0x88>
  801827:	85 c9                	test   %ecx,%ecx
  801829:	89 ce                	mov    %ecx,%esi
  80182b:	75 0b                	jne    801838 <__udivdi3+0x38>
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	31 d2                	xor    %edx,%edx
  801834:	f7 f1                	div    %ecx
  801836:	89 c6                	mov    %eax,%esi
  801838:	31 d2                	xor    %edx,%edx
  80183a:	89 e8                	mov    %ebp,%eax
  80183c:	f7 f6                	div    %esi
  80183e:	89 c5                	mov    %eax,%ebp
  801840:	89 f8                	mov    %edi,%eax
  801842:	f7 f6                	div    %esi
  801844:	89 ea                	mov    %ebp,%edx
  801846:	83 c4 0c             	add    $0xc,%esp
  801849:	5e                   	pop    %esi
  80184a:	5f                   	pop    %edi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    
  80184d:	8d 76 00             	lea    0x0(%esi),%esi
  801850:	39 e8                	cmp    %ebp,%eax
  801852:	77 24                	ja     801878 <__udivdi3+0x78>
  801854:	0f bd e8             	bsr    %eax,%ebp
  801857:	83 f5 1f             	xor    $0x1f,%ebp
  80185a:	75 3c                	jne    801898 <__udivdi3+0x98>
  80185c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801860:	39 34 24             	cmp    %esi,(%esp)
  801863:	0f 86 9f 00 00 00    	jbe    801908 <__udivdi3+0x108>
  801869:	39 d0                	cmp    %edx,%eax
  80186b:	0f 82 97 00 00 00    	jb     801908 <__udivdi3+0x108>
  801871:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801878:	31 d2                	xor    %edx,%edx
  80187a:	31 c0                	xor    %eax,%eax
  80187c:	83 c4 0c             	add    $0xc,%esp
  80187f:	5e                   	pop    %esi
  801880:	5f                   	pop    %edi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    
  801883:	90                   	nop
  801884:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801888:	89 f8                	mov    %edi,%eax
  80188a:	f7 f1                	div    %ecx
  80188c:	31 d2                	xor    %edx,%edx
  80188e:	83 c4 0c             	add    $0xc,%esp
  801891:	5e                   	pop    %esi
  801892:	5f                   	pop    %edi
  801893:	5d                   	pop    %ebp
  801894:	c3                   	ret    
  801895:	8d 76 00             	lea    0x0(%esi),%esi
  801898:	89 e9                	mov    %ebp,%ecx
  80189a:	8b 3c 24             	mov    (%esp),%edi
  80189d:	d3 e0                	shl    %cl,%eax
  80189f:	89 c6                	mov    %eax,%esi
  8018a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8018a6:	29 e8                	sub    %ebp,%eax
  8018a8:	89 c1                	mov    %eax,%ecx
  8018aa:	d3 ef                	shr    %cl,%edi
  8018ac:	89 e9                	mov    %ebp,%ecx
  8018ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018b2:	8b 3c 24             	mov    (%esp),%edi
  8018b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018b9:	89 d6                	mov    %edx,%esi
  8018bb:	d3 e7                	shl    %cl,%edi
  8018bd:	89 c1                	mov    %eax,%ecx
  8018bf:	89 3c 24             	mov    %edi,(%esp)
  8018c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018c6:	d3 ee                	shr    %cl,%esi
  8018c8:	89 e9                	mov    %ebp,%ecx
  8018ca:	d3 e2                	shl    %cl,%edx
  8018cc:	89 c1                	mov    %eax,%ecx
  8018ce:	d3 ef                	shr    %cl,%edi
  8018d0:	09 d7                	or     %edx,%edi
  8018d2:	89 f2                	mov    %esi,%edx
  8018d4:	89 f8                	mov    %edi,%eax
  8018d6:	f7 74 24 08          	divl   0x8(%esp)
  8018da:	89 d6                	mov    %edx,%esi
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	f7 24 24             	mull   (%esp)
  8018e1:	39 d6                	cmp    %edx,%esi
  8018e3:	89 14 24             	mov    %edx,(%esp)
  8018e6:	72 30                	jb     801918 <__udivdi3+0x118>
  8018e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8018ec:	89 e9                	mov    %ebp,%ecx
  8018ee:	d3 e2                	shl    %cl,%edx
  8018f0:	39 c2                	cmp    %eax,%edx
  8018f2:	73 05                	jae    8018f9 <__udivdi3+0xf9>
  8018f4:	3b 34 24             	cmp    (%esp),%esi
  8018f7:	74 1f                	je     801918 <__udivdi3+0x118>
  8018f9:	89 f8                	mov    %edi,%eax
  8018fb:	31 d2                	xor    %edx,%edx
  8018fd:	e9 7a ff ff ff       	jmp    80187c <__udivdi3+0x7c>
  801902:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801908:	31 d2                	xor    %edx,%edx
  80190a:	b8 01 00 00 00       	mov    $0x1,%eax
  80190f:	e9 68 ff ff ff       	jmp    80187c <__udivdi3+0x7c>
  801914:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801918:	8d 47 ff             	lea    -0x1(%edi),%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	83 c4 0c             	add    $0xc,%esp
  801920:	5e                   	pop    %esi
  801921:	5f                   	pop    %edi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    
  801924:	66 90                	xchg   %ax,%ax
  801926:	66 90                	xchg   %ax,%ax
  801928:	66 90                	xchg   %ax,%ax
  80192a:	66 90                	xchg   %ax,%ax
  80192c:	66 90                	xchg   %ax,%ax
  80192e:	66 90                	xchg   %ax,%ax

00801930 <__umoddi3>:
  801930:	55                   	push   %ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	83 ec 14             	sub    $0x14,%esp
  801936:	8b 44 24 28          	mov    0x28(%esp),%eax
  80193a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80193e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801942:	89 c7                	mov    %eax,%edi
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	8b 44 24 30          	mov    0x30(%esp),%eax
  80194c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801950:	89 34 24             	mov    %esi,(%esp)
  801953:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801957:	85 c0                	test   %eax,%eax
  801959:	89 c2                	mov    %eax,%edx
  80195b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80195f:	75 17                	jne    801978 <__umoddi3+0x48>
  801961:	39 fe                	cmp    %edi,%esi
  801963:	76 4b                	jbe    8019b0 <__umoddi3+0x80>
  801965:	89 c8                	mov    %ecx,%eax
  801967:	89 fa                	mov    %edi,%edx
  801969:	f7 f6                	div    %esi
  80196b:	89 d0                	mov    %edx,%eax
  80196d:	31 d2                	xor    %edx,%edx
  80196f:	83 c4 14             	add    $0x14,%esp
  801972:	5e                   	pop    %esi
  801973:	5f                   	pop    %edi
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    
  801976:	66 90                	xchg   %ax,%ax
  801978:	39 f8                	cmp    %edi,%eax
  80197a:	77 54                	ja     8019d0 <__umoddi3+0xa0>
  80197c:	0f bd e8             	bsr    %eax,%ebp
  80197f:	83 f5 1f             	xor    $0x1f,%ebp
  801982:	75 5c                	jne    8019e0 <__umoddi3+0xb0>
  801984:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801988:	39 3c 24             	cmp    %edi,(%esp)
  80198b:	0f 87 e7 00 00 00    	ja     801a78 <__umoddi3+0x148>
  801991:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801995:	29 f1                	sub    %esi,%ecx
  801997:	19 c7                	sbb    %eax,%edi
  801999:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80199d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8019a9:	83 c4 14             	add    $0x14,%esp
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    
  8019b0:	85 f6                	test   %esi,%esi
  8019b2:	89 f5                	mov    %esi,%ebp
  8019b4:	75 0b                	jne    8019c1 <__umoddi3+0x91>
  8019b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bb:	31 d2                	xor    %edx,%edx
  8019bd:	f7 f6                	div    %esi
  8019bf:	89 c5                	mov    %eax,%ebp
  8019c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019c5:	31 d2                	xor    %edx,%edx
  8019c7:	f7 f5                	div    %ebp
  8019c9:	89 c8                	mov    %ecx,%eax
  8019cb:	f7 f5                	div    %ebp
  8019cd:	eb 9c                	jmp    80196b <__umoddi3+0x3b>
  8019cf:	90                   	nop
  8019d0:	89 c8                	mov    %ecx,%eax
  8019d2:	89 fa                	mov    %edi,%edx
  8019d4:	83 c4 14             	add    $0x14,%esp
  8019d7:	5e                   	pop    %esi
  8019d8:	5f                   	pop    %edi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    
  8019db:	90                   	nop
  8019dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8019e0:	8b 04 24             	mov    (%esp),%eax
  8019e3:	be 20 00 00 00       	mov    $0x20,%esi
  8019e8:	89 e9                	mov    %ebp,%ecx
  8019ea:	29 ee                	sub    %ebp,%esi
  8019ec:	d3 e2                	shl    %cl,%edx
  8019ee:	89 f1                	mov    %esi,%ecx
  8019f0:	d3 e8                	shr    %cl,%eax
  8019f2:	89 e9                	mov    %ebp,%ecx
  8019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f8:	8b 04 24             	mov    (%esp),%eax
  8019fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8019ff:	89 fa                	mov    %edi,%edx
  801a01:	d3 e0                	shl    %cl,%eax
  801a03:	89 f1                	mov    %esi,%ecx
  801a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a0d:	d3 ea                	shr    %cl,%edx
  801a0f:	89 e9                	mov    %ebp,%ecx
  801a11:	d3 e7                	shl    %cl,%edi
  801a13:	89 f1                	mov    %esi,%ecx
  801a15:	d3 e8                	shr    %cl,%eax
  801a17:	89 e9                	mov    %ebp,%ecx
  801a19:	09 f8                	or     %edi,%eax
  801a1b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a1f:	f7 74 24 04          	divl   0x4(%esp)
  801a23:	d3 e7                	shl    %cl,%edi
  801a25:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a29:	89 d7                	mov    %edx,%edi
  801a2b:	f7 64 24 08          	mull   0x8(%esp)
  801a2f:	39 d7                	cmp    %edx,%edi
  801a31:	89 c1                	mov    %eax,%ecx
  801a33:	89 14 24             	mov    %edx,(%esp)
  801a36:	72 2c                	jb     801a64 <__umoddi3+0x134>
  801a38:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a3c:	72 22                	jb     801a60 <__umoddi3+0x130>
  801a3e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a42:	29 c8                	sub    %ecx,%eax
  801a44:	19 d7                	sbb    %edx,%edi
  801a46:	89 e9                	mov    %ebp,%ecx
  801a48:	89 fa                	mov    %edi,%edx
  801a4a:	d3 e8                	shr    %cl,%eax
  801a4c:	89 f1                	mov    %esi,%ecx
  801a4e:	d3 e2                	shl    %cl,%edx
  801a50:	89 e9                	mov    %ebp,%ecx
  801a52:	d3 ef                	shr    %cl,%edi
  801a54:	09 d0                	or     %edx,%eax
  801a56:	89 fa                	mov    %edi,%edx
  801a58:	83 c4 14             	add    $0x14,%esp
  801a5b:	5e                   	pop    %esi
  801a5c:	5f                   	pop    %edi
  801a5d:	5d                   	pop    %ebp
  801a5e:	c3                   	ret    
  801a5f:	90                   	nop
  801a60:	39 d7                	cmp    %edx,%edi
  801a62:	75 da                	jne    801a3e <__umoddi3+0x10e>
  801a64:	8b 14 24             	mov    (%esp),%edx
  801a67:	89 c1                	mov    %eax,%ecx
  801a69:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a6d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801a71:	eb cb                	jmp    801a3e <__umoddi3+0x10e>
  801a73:	90                   	nop
  801a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a78:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801a7c:	0f 82 0f ff ff ff    	jb     801991 <__umoddi3+0x61>
  801a82:	e9 1a ff ff ff       	jmp    8019a1 <__umoddi3+0x71>
