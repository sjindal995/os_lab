
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
  80004e:	c7 44 24 04 00 1b 80 	movl   $0x801b00,0x4(%esp)
  800055:	00 
  800056:	c7 04 24 01 1b 80 00 	movl   $0x801b01,(%esp)
  80005d:	e8 58 07 00 00       	call   8007ba <cprintf>
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
  800074:	c7 44 24 04 11 1b 80 	movl   $0x801b11,0x4(%esp)
  80007b:	00 
  80007c:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  800083:	e8 32 07 00 00       	call   8007ba <cprintf>
  800088:	8b 45 08             	mov    0x8(%ebp),%eax
  80008b:	8b 10                	mov    (%eax),%edx
  80008d:	8b 45 10             	mov    0x10(%ebp),%eax
  800090:	8b 00                	mov    (%eax),%eax
  800092:	39 c2                	cmp    %eax,%edx
  800094:	75 0e                	jne    8000a4 <check_regs+0x71>
  800096:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80009d:	e8 18 07 00 00       	call   8007ba <cprintf>
  8000a2:	eb 13                	jmp    8000b7 <check_regs+0x84>
  8000a4:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  8000ab:	e8 0a 07 00 00       	call   8007ba <cprintf>
  8000b0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(esi, regs.reg_esi);
  8000b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8000ba:	8b 50 04             	mov    0x4(%eax),%edx
  8000bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c0:	8b 40 04             	mov    0x4(%eax),%eax
  8000c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8000c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000cb:	c7 44 24 04 33 1b 80 	movl   $0x801b33,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  8000da:	e8 db 06 00 00       	call   8007ba <cprintf>
  8000df:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e2:	8b 50 04             	mov    0x4(%eax),%edx
  8000e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8000e8:	8b 40 04             	mov    0x4(%eax),%eax
  8000eb:	39 c2                	cmp    %eax,%edx
  8000ed:	75 0e                	jne    8000fd <check_regs+0xca>
  8000ef:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8000f6:	e8 bf 06 00 00       	call   8007ba <cprintf>
  8000fb:	eb 13                	jmp    800110 <check_regs+0xdd>
  8000fd:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  800104:	e8 b1 06 00 00       	call   8007ba <cprintf>
  800109:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ebp, regs.reg_ebp);
  800110:	8b 45 10             	mov    0x10(%ebp),%eax
  800113:	8b 50 08             	mov    0x8(%eax),%edx
  800116:	8b 45 08             	mov    0x8(%ebp),%eax
  800119:	8b 40 08             	mov    0x8(%eax),%eax
  80011c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800120:	89 44 24 08          	mov    %eax,0x8(%esp)
  800124:	c7 44 24 04 37 1b 80 	movl   $0x801b37,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  800133:	e8 82 06 00 00       	call   8007ba <cprintf>
  800138:	8b 45 08             	mov    0x8(%ebp),%eax
  80013b:	8b 50 08             	mov    0x8(%eax),%edx
  80013e:	8b 45 10             	mov    0x10(%ebp),%eax
  800141:	8b 40 08             	mov    0x8(%eax),%eax
  800144:	39 c2                	cmp    %eax,%edx
  800146:	75 0e                	jne    800156 <check_regs+0x123>
  800148:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80014f:	e8 66 06 00 00       	call   8007ba <cprintf>
  800154:	eb 13                	jmp    800169 <check_regs+0x136>
  800156:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  80015d:	e8 58 06 00 00       	call   8007ba <cprintf>
  800162:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ebx, regs.reg_ebx);
  800169:	8b 45 10             	mov    0x10(%ebp),%eax
  80016c:	8b 50 10             	mov    0x10(%eax),%edx
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 40 10             	mov    0x10(%eax),%eax
  800175:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800179:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017d:	c7 44 24 04 3b 1b 80 	movl   $0x801b3b,0x4(%esp)
  800184:	00 
  800185:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  80018c:	e8 29 06 00 00       	call   8007ba <cprintf>
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	8b 50 10             	mov    0x10(%eax),%edx
  800197:	8b 45 10             	mov    0x10(%ebp),%eax
  80019a:	8b 40 10             	mov    0x10(%eax),%eax
  80019d:	39 c2                	cmp    %eax,%edx
  80019f:	75 0e                	jne    8001af <check_regs+0x17c>
  8001a1:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8001a8:	e8 0d 06 00 00       	call   8007ba <cprintf>
  8001ad:	eb 13                	jmp    8001c2 <check_regs+0x18f>
  8001af:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  8001b6:	e8 ff 05 00 00       	call   8007ba <cprintf>
  8001bb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(edx, regs.reg_edx);
  8001c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c5:	8b 50 14             	mov    0x14(%eax),%edx
  8001c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cb:	8b 40 14             	mov    0x14(%eax),%eax
  8001ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d6:	c7 44 24 04 3f 1b 80 	movl   $0x801b3f,0x4(%esp)
  8001dd:	00 
  8001de:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  8001e5:	e8 d0 05 00 00       	call   8007ba <cprintf>
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	8b 50 14             	mov    0x14(%eax),%edx
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	8b 40 14             	mov    0x14(%eax),%eax
  8001f6:	39 c2                	cmp    %eax,%edx
  8001f8:	75 0e                	jne    800208 <check_regs+0x1d5>
  8001fa:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  800201:	e8 b4 05 00 00       	call   8007ba <cprintf>
  800206:	eb 13                	jmp    80021b <check_regs+0x1e8>
  800208:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  80020f:	e8 a6 05 00 00       	call   8007ba <cprintf>
  800214:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(ecx, regs.reg_ecx);
  80021b:	8b 45 10             	mov    0x10(%ebp),%eax
  80021e:	8b 50 18             	mov    0x18(%eax),%edx
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 40 18             	mov    0x18(%eax),%eax
  800227:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80022b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022f:	c7 44 24 04 43 1b 80 	movl   $0x801b43,0x4(%esp)
  800236:	00 
  800237:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  80023e:	e8 77 05 00 00       	call   8007ba <cprintf>
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 50 18             	mov    0x18(%eax),%edx
  800249:	8b 45 10             	mov    0x10(%ebp),%eax
  80024c:	8b 40 18             	mov    0x18(%eax),%eax
  80024f:	39 c2                	cmp    %eax,%edx
  800251:	75 0e                	jne    800261 <check_regs+0x22e>
  800253:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80025a:	e8 5b 05 00 00       	call   8007ba <cprintf>
  80025f:	eb 13                	jmp    800274 <check_regs+0x241>
  800261:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  800268:	e8 4d 05 00 00       	call   8007ba <cprintf>
  80026d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eax, regs.reg_eax);
  800274:	8b 45 10             	mov    0x10(%ebp),%eax
  800277:	8b 50 1c             	mov    0x1c(%eax),%edx
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	8b 40 1c             	mov    0x1c(%eax),%eax
  800280:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	c7 44 24 04 47 1b 80 	movl   $0x801b47,0x4(%esp)
  80028f:	00 
  800290:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  800297:	e8 1e 05 00 00       	call   8007ba <cprintf>
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	8b 50 1c             	mov    0x1c(%eax),%edx
  8002a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a5:	8b 40 1c             	mov    0x1c(%eax),%eax
  8002a8:	39 c2                	cmp    %eax,%edx
  8002aa:	75 0e                	jne    8002ba <check_regs+0x287>
  8002ac:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8002b3:	e8 02 05 00 00       	call   8007ba <cprintf>
  8002b8:	eb 13                	jmp    8002cd <check_regs+0x29a>
  8002ba:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  8002c1:	e8 f4 04 00 00       	call   8007ba <cprintf>
  8002c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eip, eip);
  8002cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d0:	8b 50 20             	mov    0x20(%eax),%edx
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	8b 40 20             	mov    0x20(%eax),%eax
  8002d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e1:	c7 44 24 04 4b 1b 80 	movl   $0x801b4b,0x4(%esp)
  8002e8:	00 
  8002e9:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  8002f0:	e8 c5 04 00 00       	call   8007ba <cprintf>
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	8b 50 20             	mov    0x20(%eax),%edx
  8002fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fe:	8b 40 20             	mov    0x20(%eax),%eax
  800301:	39 c2                	cmp    %eax,%edx
  800303:	75 0e                	jne    800313 <check_regs+0x2e0>
  800305:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  80030c:	e8 a9 04 00 00       	call   8007ba <cprintf>
  800311:	eb 13                	jmp    800326 <check_regs+0x2f3>
  800313:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  80031a:	e8 9b 04 00 00       	call   8007ba <cprintf>
  80031f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(eflags, eflags);
  800326:	8b 45 10             	mov    0x10(%ebp),%eax
  800329:	8b 50 24             	mov    0x24(%eax),%edx
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	8b 40 24             	mov    0x24(%eax),%eax
  800332:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	c7 44 24 04 4f 1b 80 	movl   $0x801b4f,0x4(%esp)
  800341:	00 
  800342:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  800349:	e8 6c 04 00 00       	call   8007ba <cprintf>
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	8b 50 24             	mov    0x24(%eax),%edx
  800354:	8b 45 10             	mov    0x10(%ebp),%eax
  800357:	8b 40 24             	mov    0x24(%eax),%eax
  80035a:	39 c2                	cmp    %eax,%edx
  80035c:	75 0e                	jne    80036c <check_regs+0x339>
  80035e:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  800365:	e8 50 04 00 00       	call   8007ba <cprintf>
  80036a:	eb 13                	jmp    80037f <check_regs+0x34c>
  80036c:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  800373:	e8 42 04 00 00       	call   8007ba <cprintf>
  800378:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	CHECK(esp, esp);
  80037f:	8b 45 10             	mov    0x10(%ebp),%eax
  800382:	8b 50 28             	mov    0x28(%eax),%edx
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	8b 40 28             	mov    0x28(%eax),%eax
  80038b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 04 56 1b 80 	movl   $0x801b56,0x4(%esp)
  80039a:	00 
  80039b:	c7 04 24 15 1b 80 00 	movl   $0x801b15,(%esp)
  8003a2:	e8 13 04 00 00       	call   8007ba <cprintf>
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	8b 50 28             	mov    0x28(%eax),%edx
  8003ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b0:	8b 40 28             	mov    0x28(%eax),%eax
  8003b3:	39 c2                	cmp    %eax,%edx
  8003b5:	75 0e                	jne    8003c5 <check_regs+0x392>
  8003b7:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8003be:	e8 f7 03 00 00       	call   8007ba <cprintf>
  8003c3:	eb 13                	jmp    8003d8 <check_regs+0x3a5>
  8003c5:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  8003cc:	e8 e9 03 00 00       	call   8007ba <cprintf>
  8003d1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)

#undef CHECK

	cprintf("Registers %s ", testname);
  8003d8:	8b 45 18             	mov    0x18(%ebp),%eax
  8003db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003df:	c7 04 24 5a 1b 80 00 	movl   $0x801b5a,(%esp)
  8003e6:	e8 cf 03 00 00       	call   8007ba <cprintf>
	if (!mismatch)
  8003eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8003ef:	75 0e                	jne    8003ff <check_regs+0x3cc>
		cprintf("OK\n");
  8003f1:	c7 04 24 25 1b 80 00 	movl   $0x801b25,(%esp)
  8003f8:	e8 bd 03 00 00       	call   8007ba <cprintf>
  8003fd:	eb 0c                	jmp    80040b <check_regs+0x3d8>
	else
		cprintf("MISMATCH\n");
  8003ff:	c7 04 24 29 1b 80 00 	movl   $0x801b29,(%esp)
  800406:	e8 af 03 00 00       	call   8007ba <cprintf>
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
  800432:	c7 44 24 08 68 1b 80 	movl   $0x801b68,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 99 1b 80 00 	movl   $0x801b99,(%esp)
  800449:	e8 51 02 00 00       	call   80069f <_panic>
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
  8004b9:	c7 44 24 10 aa 1b 80 	movl   $0x801baa,0x10(%esp)
  8004c0:	00 
  8004c1:	c7 44 24 0c b8 1b 80 	movl   $0x801bb8,0xc(%esp)
  8004c8:	00 
  8004c9:	c7 44 24 08 60 20 80 	movl   $0x802060,0x8(%esp)
  8004d0:	00 
  8004d1:	c7 44 24 04 bf 1b 80 	movl   $0x801bbf,0x4(%esp)
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
  8004fc:	e8 76 10 00 00       	call   801577 <sys_page_alloc>
  800501:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800504:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800508:	79 23                	jns    80052d <pgfault+0x120>
		panic("sys_page_alloc: %e", r);
  80050a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800511:	c7 44 24 08 c6 1b 80 	movl   $0x801bc6,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 99 1b 80 00 	movl   $0x801b99,(%esp)
  800528:	e8 72 01 00 00       	call   80069f <_panic>
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
  80053c:	e8 8d 12 00 00       	call   8017ce <set_pgfault_handler>

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
  800608:	c7 04 24 dc 1b 80 00 	movl   $0x801bdc,(%esp)
  80060f:	e8 a6 01 00 00       	call   8007ba <cprintf>
	after.eip = before.eip;
  800614:	a1 40 20 80 00       	mov    0x802040,%eax
  800619:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80061e:	c7 44 24 10 fb 1b 80 	movl   $0x801bfb,0x10(%esp)
  800625:	00 
  800626:	c7 44 24 0c 0c 1c 80 	movl   $0x801c0c,0xc(%esp)
  80062d:	00 
  80062e:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  800635:	00 
  800636:	c7 44 24 04 bf 1b 80 	movl   $0x801bbf,0x4(%esp)
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
  800652:	e8 98 0e 00 00       	call   8014ef <sys_getenvid>
  800657:	25 ff 03 00 00       	and    $0x3ff,%eax
  80065c:	c1 e0 02             	shl    $0x2,%eax
  80065f:	89 c2                	mov    %eax,%edx
  800661:	c1 e2 05             	shl    $0x5,%edx
  800664:	29 c2                	sub    %eax,%edx
  800666:	89 d0                	mov    %edx,%eax
  800668:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80066d:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800672:	8b 45 0c             	mov    0xc(%ebp),%eax
  800675:	89 44 24 04          	mov    %eax,0x4(%esp)
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	e8 ab fe ff ff       	call   80052f <umain>

	// exit gracefully
	exit();
  800684:	e8 02 00 00 00       	call   80068b <exit>
}
  800689:	c9                   	leave  
  80068a:	c3                   	ret    

0080068b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800691:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800698:	e8 0f 0e 00 00       	call   8014ac <sys_env_destroy>
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	53                   	push   %ebx
  8006a3:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006ac:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8006b2:	e8 38 0e 00 00       	call   8014ef <sys_getenvid>
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ba:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006be:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cd:	c7 04 24 1c 1c 80 00 	movl   $0x801c1c,(%esp)
  8006d4:	e8 e1 00 00 00       	call   8007ba <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	e8 6b 00 00 00       	call   800756 <vcprintf>
	cprintf("\n");
  8006eb:	c7 04 24 3f 1c 80 00 	movl   $0x801c3f,(%esp)
  8006f2:	e8 c3 00 00 00       	call   8007ba <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006f7:	cc                   	int3   
  8006f8:	eb fd                	jmp    8006f7 <_panic+0x58>

008006fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
  800703:	8b 00                	mov    (%eax),%eax
  800705:	8d 48 01             	lea    0x1(%eax),%ecx
  800708:	8b 55 0c             	mov    0xc(%ebp),%edx
  80070b:	89 0a                	mov    %ecx,(%edx)
  80070d:	8b 55 08             	mov    0x8(%ebp),%edx
  800710:	89 d1                	mov    %edx,%ecx
  800712:	8b 55 0c             	mov    0xc(%ebp),%edx
  800715:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800723:	75 20                	jne    800745 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800725:	8b 45 0c             	mov    0xc(%ebp),%eax
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072d:	83 c2 08             	add    $0x8,%edx
  800730:	89 44 24 04          	mov    %eax,0x4(%esp)
  800734:	89 14 24             	mov    %edx,(%esp)
  800737:	e8 ea 0c 00 00       	call   801426 <sys_cputs>
		b->idx = 0;
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800745:	8b 45 0c             	mov    0xc(%ebp),%eax
  800748:	8b 40 04             	mov    0x4(%eax),%eax
  80074b:	8d 50 01             	lea    0x1(%eax),%edx
  80074e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800751:	89 50 04             	mov    %edx,0x4(%eax)
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80075f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800766:	00 00 00 
	b.cnt = 0;
  800769:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800770:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800773:	8b 45 0c             	mov    0xc(%ebp),%eax
  800776:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800781:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	c7 04 24 fa 06 80 00 	movl   $0x8006fa,(%esp)
  800792:	e8 bd 01 00 00       	call   800954 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800797:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007a7:	83 c0 08             	add    $0x8,%eax
  8007aa:	89 04 24             	mov    %eax,(%esp)
  8007ad:	e8 74 0c 00 00       	call   801426 <sys_cputs>

	return b.cnt;
  8007b2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007c0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8007c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	e8 7e ff ff ff       	call   800756 <vcprintf>
  8007d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8007db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	83 ec 34             	sub    $0x34,%esp
  8007e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007f3:	8b 45 18             	mov    0x18(%ebp),%eax
  8007f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8007fe:	77 72                	ja     800872 <printnum+0x92>
  800800:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800803:	72 05                	jb     80080a <printnum+0x2a>
  800805:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800808:	77 68                	ja     800872 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80080a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80080d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800810:	8b 45 18             	mov    0x18(%ebp),%eax
  800813:	ba 00 00 00 00       	mov    $0x0,%edx
  800818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	e8 3e 10 00 00       	call   801870 <__udivdi3>
  800832:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800835:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800839:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80083d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800840:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800844:	89 44 24 08          	mov    %eax,0x8(%esp)
  800848:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 82 ff ff ff       	call   8007e0 <printnum>
  80085e:	eb 1c                	jmp    80087c <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800860:	8b 45 0c             	mov    0xc(%ebp),%eax
  800863:	89 44 24 04          	mov    %eax,0x4(%esp)
  800867:	8b 45 20             	mov    0x20(%ebp),%eax
  80086a:	89 04 24             	mov    %eax,(%esp)
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800872:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800876:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80087a:	7f e4                	jg     800860 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80087c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80087f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80088a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80088e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	89 54 24 04          	mov    %edx,0x4(%esp)
  800899:	e8 02 11 00 00       	call   8019a0 <__umoddi3>
  80089e:	05 28 1d 80 00       	add    $0x801d28,%eax
  8008a3:	0f b6 00             	movzbl (%eax),%eax
  8008a6:	0f be c0             	movsbl %al,%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b0:	89 04 24             	mov    %eax,(%esp)
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	ff d0                	call   *%eax
}
  8008b8:	83 c4 34             	add    $0x34,%esp
  8008bb:	5b                   	pop    %ebx
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8008c1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8008c5:	7e 14                	jle    8008db <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 00                	mov    (%eax),%eax
  8008cc:	8d 48 08             	lea    0x8(%eax),%ecx
  8008cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d2:	89 0a                	mov    %ecx,(%edx)
  8008d4:	8b 50 04             	mov    0x4(%eax),%edx
  8008d7:	8b 00                	mov    (%eax),%eax
  8008d9:	eb 30                	jmp    80090b <getuint+0x4d>
	else if (lflag)
  8008db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008df:	74 16                	je     8008f7 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 00                	mov    (%eax),%eax
  8008e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8008e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ec:	89 0a                	mov    %ecx,(%edx)
  8008ee:	8b 00                	mov    (%eax),%eax
  8008f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f5:	eb 14                	jmp    80090b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	8b 00                	mov    (%eax),%eax
  8008fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8008ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800902:	89 0a                	mov    %ecx,(%edx)
  800904:	8b 00                	mov    (%eax),%eax
  800906:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800910:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800914:	7e 14                	jle    80092a <getint+0x1d>
		return va_arg(*ap, long long);
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 00                	mov    (%eax),%eax
  80091b:	8d 48 08             	lea    0x8(%eax),%ecx
  80091e:	8b 55 08             	mov    0x8(%ebp),%edx
  800921:	89 0a                	mov    %ecx,(%edx)
  800923:	8b 50 04             	mov    0x4(%eax),%edx
  800926:	8b 00                	mov    (%eax),%eax
  800928:	eb 28                	jmp    800952 <getint+0x45>
	else if (lflag)
  80092a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80092e:	74 12                	je     800942 <getint+0x35>
		return va_arg(*ap, long);
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 00                	mov    (%eax),%eax
  800935:	8d 48 04             	lea    0x4(%eax),%ecx
  800938:	8b 55 08             	mov    0x8(%ebp),%edx
  80093b:	89 0a                	mov    %ecx,(%edx)
  80093d:	8b 00                	mov    (%eax),%eax
  80093f:	99                   	cltd   
  800940:	eb 10                	jmp    800952 <getint+0x45>
	else
		return va_arg(*ap, int);
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 00                	mov    (%eax),%eax
  800947:	8d 48 04             	lea    0x4(%eax),%ecx
  80094a:	8b 55 08             	mov    0x8(%ebp),%edx
  80094d:	89 0a                	mov    %ecx,(%edx)
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	99                   	cltd   
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80095c:	eb 18                	jmp    800976 <vprintfmt+0x22>
			if (ch == '\0')
  80095e:	85 db                	test   %ebx,%ebx
  800960:	75 05                	jne    800967 <vprintfmt+0x13>
				return;
  800962:	e9 cc 03 00 00       	jmp    800d33 <vprintfmt+0x3df>
			putch(ch, putdat);
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	89 1c 24             	mov    %ebx,(%esp)
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800976:	8b 45 10             	mov    0x10(%ebp),%eax
  800979:	8d 50 01             	lea    0x1(%eax),%edx
  80097c:	89 55 10             	mov    %edx,0x10(%ebp)
  80097f:	0f b6 00             	movzbl (%eax),%eax
  800982:	0f b6 d8             	movzbl %al,%ebx
  800985:	83 fb 25             	cmp    $0x25,%ebx
  800988:	75 d4                	jne    80095e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80098a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80098e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800995:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80099c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8009a3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ad:	8d 50 01             	lea    0x1(%eax),%edx
  8009b0:	89 55 10             	mov    %edx,0x10(%ebp)
  8009b3:	0f b6 00             	movzbl (%eax),%eax
  8009b6:	0f b6 d8             	movzbl %al,%ebx
  8009b9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8009bc:	83 f8 55             	cmp    $0x55,%eax
  8009bf:	0f 87 3d 03 00 00    	ja     800d02 <vprintfmt+0x3ae>
  8009c5:	8b 04 85 4c 1d 80 00 	mov    0x801d4c(,%eax,4),%eax
  8009cc:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8009ce:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8009d2:	eb d6                	jmp    8009aa <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8009d4:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8009d8:	eb d0                	jmp    8009aa <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8009da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8009e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009e4:	89 d0                	mov    %edx,%eax
  8009e6:	c1 e0 02             	shl    $0x2,%eax
  8009e9:	01 d0                	add    %edx,%eax
  8009eb:	01 c0                	add    %eax,%eax
  8009ed:	01 d8                	add    %ebx,%eax
  8009ef:	83 e8 30             	sub    $0x30,%eax
  8009f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8009f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f8:	0f b6 00             	movzbl (%eax),%eax
  8009fb:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8009fe:	83 fb 2f             	cmp    $0x2f,%ebx
  800a01:	7e 0b                	jle    800a0e <vprintfmt+0xba>
  800a03:	83 fb 39             	cmp    $0x39,%ebx
  800a06:	7f 06                	jg     800a0e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a08:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a0c:	eb d3                	jmp    8009e1 <vprintfmt+0x8d>
			goto process_precision;
  800a0e:	eb 33                	jmp    800a43 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800a10:	8b 45 14             	mov    0x14(%ebp),%eax
  800a13:	8d 50 04             	lea    0x4(%eax),%edx
  800a16:	89 55 14             	mov    %edx,0x14(%ebp)
  800a19:	8b 00                	mov    (%eax),%eax
  800a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800a1e:	eb 23                	jmp    800a43 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800a20:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a24:	79 0c                	jns    800a32 <vprintfmt+0xde>
				width = 0;
  800a26:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800a2d:	e9 78 ff ff ff       	jmp    8009aa <vprintfmt+0x56>
  800a32:	e9 73 ff ff ff       	jmp    8009aa <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800a37:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800a3e:	e9 67 ff ff ff       	jmp    8009aa <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800a43:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a47:	79 12                	jns    800a5b <vprintfmt+0x107>
				width = precision, precision = -1;
  800a49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a4f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800a56:	e9 4f ff ff ff       	jmp    8009aa <vprintfmt+0x56>
  800a5b:	e9 4a ff ff ff       	jmp    8009aa <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a60:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800a64:	e9 41 ff ff ff       	jmp    8009aa <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800a69:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6c:	8d 50 04             	lea    0x4(%eax),%edx
  800a6f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a72:	8b 00                	mov    (%eax),%eax
  800a74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a77:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	ff d0                	call   *%eax
			break;
  800a83:	e9 a5 02 00 00       	jmp    800d2d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 04             	lea    0x4(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800a93:	85 db                	test   %ebx,%ebx
  800a95:	79 02                	jns    800a99 <vprintfmt+0x145>
				err = -err;
  800a97:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a99:	83 fb 09             	cmp    $0x9,%ebx
  800a9c:	7f 0b                	jg     800aa9 <vprintfmt+0x155>
  800a9e:	8b 34 9d 00 1d 80 00 	mov    0x801d00(,%ebx,4),%esi
  800aa5:	85 f6                	test   %esi,%esi
  800aa7:	75 23                	jne    800acc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800aa9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800aad:	c7 44 24 08 39 1d 80 	movl   $0x801d39,0x8(%esp)
  800ab4:	00 
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	89 04 24             	mov    %eax,(%esp)
  800ac2:	e8 73 02 00 00       	call   800d3a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800ac7:	e9 61 02 00 00       	jmp    800d2d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800acc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ad0:	c7 44 24 08 42 1d 80 	movl   $0x801d42,0x8(%esp)
  800ad7:	00 
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 50 02 00 00       	call   800d3a <printfmt>
			break;
  800aea:	e9 3e 02 00 00       	jmp    800d2d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800aef:	8b 45 14             	mov    0x14(%ebp),%eax
  800af2:	8d 50 04             	lea    0x4(%eax),%edx
  800af5:	89 55 14             	mov    %edx,0x14(%ebp)
  800af8:	8b 30                	mov    (%eax),%esi
  800afa:	85 f6                	test   %esi,%esi
  800afc:	75 05                	jne    800b03 <vprintfmt+0x1af>
				p = "(null)";
  800afe:	be 45 1d 80 00       	mov    $0x801d45,%esi
			if (width > 0 && padc != '-')
  800b03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b07:	7e 37                	jle    800b40 <vprintfmt+0x1ec>
  800b09:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800b0d:	74 31                	je     800b40 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b16:	89 34 24             	mov    %esi,(%esp)
  800b19:	e8 39 03 00 00       	call   800e57 <strnlen>
  800b1e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800b21:	eb 17                	jmp    800b3a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800b23:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b2e:	89 04 24             	mov    %eax,(%esp)
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b36:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b3a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b3e:	7f e3                	jg     800b23 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b40:	eb 38                	jmp    800b7a <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800b42:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b46:	74 1f                	je     800b67 <vprintfmt+0x213>
  800b48:	83 fb 1f             	cmp    $0x1f,%ebx
  800b4b:	7e 05                	jle    800b52 <vprintfmt+0x1fe>
  800b4d:	83 fb 7e             	cmp    $0x7e,%ebx
  800b50:	7e 15                	jle    800b67 <vprintfmt+0x213>
					putch('?', putdat);
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b59:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	ff d0                	call   *%eax
  800b65:	eb 0f                	jmp    800b76 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6e:	89 1c 24             	mov    %ebx,(%esp)
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b76:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800b7a:	89 f0                	mov    %esi,%eax
  800b7c:	8d 70 01             	lea    0x1(%eax),%esi
  800b7f:	0f b6 00             	movzbl (%eax),%eax
  800b82:	0f be d8             	movsbl %al,%ebx
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	74 10                	je     800b99 <vprintfmt+0x245>
  800b89:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b8d:	78 b3                	js     800b42 <vprintfmt+0x1ee>
  800b8f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800b93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b97:	79 a9                	jns    800b42 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b99:	eb 17                	jmp    800bb2 <vprintfmt+0x25e>
				putch(' ', putdat);
  800b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800bae:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800bb2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bb6:	7f e3                	jg     800b9b <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800bb8:	e9 70 01 00 00       	jmp    800d2d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc4:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc7:	89 04 24             	mov    %eax,(%esp)
  800bca:	e8 3e fd ff ff       	call   80090d <getint>
  800bcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bd2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bdb:	85 d2                	test   %edx,%edx
  800bdd:	79 26                	jns    800c05 <vprintfmt+0x2b1>
				putch('-', putdat);
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	ff d0                	call   *%eax
				num = -(long long) num;
  800bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bf8:	f7 d8                	neg    %eax
  800bfa:	83 d2 00             	adc    $0x0,%edx
  800bfd:	f7 da                	neg    %edx
  800bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c02:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800c05:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800c0c:	e9 a8 00 00 00       	jmp    800cb9 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c11:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c18:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1b:	89 04 24             	mov    %eax,(%esp)
  800c1e:	e8 9b fc ff ff       	call   8008be <getuint>
  800c23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c26:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800c29:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800c30:	e9 84 00 00 00       	jmp    800cb9 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800c35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c3c:	8d 45 14             	lea    0x14(%ebp),%eax
  800c3f:	89 04 24             	mov    %eax,(%esp)
  800c42:	e8 77 fc ff ff       	call   8008be <getuint>
  800c47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800c4d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800c54:	eb 63                	jmp    800cb9 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	ff d0                	call   *%eax
			putch('x', putdat);
  800c69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c70:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c7f:	8d 50 04             	lea    0x4(%eax),%edx
  800c82:	89 55 14             	mov    %edx,0x14(%ebp)
  800c85:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800c91:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800c98:	eb 1f                	jmp    800cb9 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca1:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca4:	89 04 24             	mov    %eax,(%esp)
  800ca7:	e8 12 fc ff ff       	call   8008be <getuint>
  800cac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800caf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800cb2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cb9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cc0:	89 54 24 18          	mov    %edx,0x18(%esp)
  800cc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cc7:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	89 04 24             	mov    %eax,(%esp)
  800cea:	e8 f1 fa ff ff       	call   8007e0 <printnum>
			break;
  800cef:	eb 3c                	jmp    800d2d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf8:	89 1c 24             	mov    %ebx,(%esp)
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	ff d0                	call   *%eax
			break;
  800d00:	eb 2b                	jmp    800d2d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d09:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d15:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d19:	eb 04                	jmp    800d1f <vprintfmt+0x3cb>
  800d1b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d22:	83 e8 01             	sub    $0x1,%eax
  800d25:	0f b6 00             	movzbl (%eax),%eax
  800d28:	3c 25                	cmp    $0x25,%al
  800d2a:	75 ef                	jne    800d1b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800d2c:	90                   	nop
		}
	}
  800d2d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d2e:	e9 43 fc ff ff       	jmp    800976 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800d33:	83 c4 40             	add    $0x40,%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800d40:	8d 45 14             	lea    0x14(%ebp),%eax
  800d43:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	89 04 24             	mov    %eax,(%esp)
  800d61:	e8 ee fb ff ff       	call   800954 <vprintfmt>
	va_end(ap);
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6e:	8b 40 08             	mov    0x8(%eax),%eax
  800d71:	8d 50 01             	lea    0x1(%eax),%edx
  800d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d77:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7d:	8b 10                	mov    (%eax),%edx
  800d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d82:	8b 40 04             	mov    0x4(%eax),%eax
  800d85:	39 c2                	cmp    %eax,%edx
  800d87:	73 12                	jae    800d9b <sprintputch+0x33>
		*b->buf++ = ch;
  800d89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8c:	8b 00                	mov    (%eax),%eax
  800d8e:	8d 48 01             	lea    0x1(%eax),%ecx
  800d91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d94:	89 0a                	mov    %ecx,(%edx)
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	88 10                	mov    %dl,(%eax)
}
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800da9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dac:	8d 50 ff             	lea    -0x1(%eax),%edx
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	01 d0                	add    %edx,%eax
  800db4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800db7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800dbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800dc2:	74 06                	je     800dca <vsnprintf+0x2d>
  800dc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc8:	7f 07                	jg     800dd1 <vsnprintf+0x34>
		return -E_INVAL;
  800dca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dcf:	eb 2a                	jmp    800dfb <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800dd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de6:	c7 04 24 68 0d 80 00 	movl   $0x800d68,(%esp)
  800ded:	e8 62 fb ff ff       	call   800954 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800df2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800df5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e03:	8d 45 14             	lea    0x14(%ebp),%eax
  800e06:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e10:	8b 45 10             	mov    0x10(%ebp),%eax
  800e13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	89 04 24             	mov    %eax,(%esp)
  800e24:	e8 74 ff ff ff       	call   800d9d <vsnprintf>
  800e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800e37:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e3e:	eb 08                	jmp    800e48 <strlen+0x17>
		n++;
  800e40:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4b:	0f b6 00             	movzbl (%eax),%eax
  800e4e:	84 c0                	test   %al,%al
  800e50:	75 ee                	jne    800e40 <strlen+0xf>
		n++;
	return n;
  800e52:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e5d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800e64:	eb 0c                	jmp    800e72 <strnlen+0x1b>
		n++;
  800e66:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e6e:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800e72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e76:	74 0a                	je     800e82 <strnlen+0x2b>
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	0f b6 00             	movzbl (%eax),%eax
  800e7e:	84 c0                	test   %al,%al
  800e80:	75 e4                	jne    800e66 <strnlen+0xf>
		n++;
	return n;
  800e82:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800e93:	90                   	nop
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	8d 50 01             	lea    0x1(%eax),%edx
  800e9a:	89 55 08             	mov    %edx,0x8(%ebp)
  800e9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea0:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ea3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ea6:	0f b6 12             	movzbl (%edx),%edx
  800ea9:	88 10                	mov    %dl,(%eax)
  800eab:	0f b6 00             	movzbl (%eax),%eax
  800eae:	84 c0                	test   %al,%al
  800eb0:	75 e2                	jne    800e94 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	89 04 24             	mov    %eax,(%esp)
  800ec3:	e8 69 ff ff ff       	call   800e31 <strlen>
  800ec8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800ecb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	01 c2                	add    %eax,%edx
  800ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eda:	89 14 24             	mov    %edx,(%esp)
  800edd:	e8 a5 ff ff ff       	call   800e87 <strcpy>
	return dst;
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800ef3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800efa:	eb 23                	jmp    800f1f <strncpy+0x38>
		*dst++ = *src;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	8d 50 01             	lea    0x1(%eax),%edx
  800f02:	89 55 08             	mov    %edx,0x8(%ebp)
  800f05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f08:	0f b6 12             	movzbl (%edx),%edx
  800f0b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f10:	0f b6 00             	movzbl (%eax),%eax
  800f13:	84 c0                	test   %al,%al
  800f15:	74 04                	je     800f1b <strncpy+0x34>
			src++;
  800f17:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800f1b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800f1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f22:	3b 45 10             	cmp    0x10(%ebp),%eax
  800f25:	72 d5                	jb     800efc <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800f27:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800f32:	8b 45 08             	mov    0x8(%ebp),%eax
  800f35:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3c:	74 33                	je     800f71 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800f3e:	eb 17                	jmp    800f57 <strlcpy+0x2b>
			*dst++ = *src++;
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	8d 50 01             	lea    0x1(%eax),%edx
  800f46:	89 55 08             	mov    %edx,0x8(%ebp)
  800f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800f4f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800f52:	0f b6 12             	movzbl (%edx),%edx
  800f55:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800f57:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800f5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5f:	74 0a                	je     800f6b <strlcpy+0x3f>
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	0f b6 00             	movzbl (%eax),%eax
  800f67:	84 c0                	test   %al,%al
  800f69:	75 d5                	jne    800f40 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f77:	29 c2                	sub    %eax,%edx
  800f79:	89 d0                	mov    %edx,%eax
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800f80:	eb 08                	jmp    800f8a <strcmp+0xd>
		p++, q++;
  800f82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800f86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	0f b6 00             	movzbl (%eax),%eax
  800f90:	84 c0                	test   %al,%al
  800f92:	74 10                	je     800fa4 <strcmp+0x27>
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	0f b6 10             	movzbl (%eax),%edx
  800f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9d:	0f b6 00             	movzbl (%eax),%eax
  800fa0:	38 c2                	cmp    %al,%dl
  800fa2:	74 de                	je     800f82 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	0f b6 00             	movzbl (%eax),%eax
  800faa:	0f b6 d0             	movzbl %al,%edx
  800fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb0:	0f b6 00             	movzbl (%eax),%eax
  800fb3:	0f b6 c0             	movzbl %al,%eax
  800fb6:	29 c2                	sub    %eax,%edx
  800fb8:	89 d0                	mov    %edx,%eax
}
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800fbf:	eb 0c                	jmp    800fcd <strncmp+0x11>
		n--, p++, q++;
  800fc1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800fc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fc9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800fcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fd1:	74 1a                	je     800fed <strncmp+0x31>
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	0f b6 00             	movzbl (%eax),%eax
  800fd9:	84 c0                	test   %al,%al
  800fdb:	74 10                	je     800fed <strncmp+0x31>
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	0f b6 10             	movzbl (%eax),%edx
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	0f b6 00             	movzbl (%eax),%eax
  800fe9:	38 c2                	cmp    %al,%dl
  800feb:	74 d4                	je     800fc1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800fed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ff1:	75 07                	jne    800ffa <strncmp+0x3e>
		return 0;
  800ff3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff8:	eb 16                	jmp    801010 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffd:	0f b6 00             	movzbl (%eax),%eax
  801000:	0f b6 d0             	movzbl %al,%edx
  801003:	8b 45 0c             	mov    0xc(%ebp),%eax
  801006:	0f b6 00             	movzbl (%eax),%eax
  801009:	0f b6 c0             	movzbl %al,%eax
  80100c:	29 c2                	sub    %eax,%edx
  80100e:	89 d0                	mov    %edx,%eax
}
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  80101e:	eb 14                	jmp    801034 <strchr+0x22>
		if (*s == c)
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	0f b6 00             	movzbl (%eax),%eax
  801026:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801029:	75 05                	jne    801030 <strchr+0x1e>
			return (char *) s;
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	eb 13                	jmp    801043 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801030:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801034:	8b 45 08             	mov    0x8(%ebp),%eax
  801037:	0f b6 00             	movzbl (%eax),%eax
  80103a:	84 c0                	test   %al,%al
  80103c:	75 e2                	jne    801020 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80103e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801051:	eb 11                	jmp    801064 <strfind+0x1f>
		if (*s == c)
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	0f b6 00             	movzbl (%eax),%eax
  801059:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80105c:	75 02                	jne    801060 <strfind+0x1b>
			break;
  80105e:	eb 0e                	jmp    80106e <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801060:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801064:	8b 45 08             	mov    0x8(%ebp),%eax
  801067:	0f b6 00             	movzbl (%eax),%eax
  80106a:	84 c0                	test   %al,%al
  80106c:	75 e5                	jne    801053 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
	char *p;

	if (n == 0)
  801077:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80107b:	75 05                	jne    801082 <memset+0xf>
		return v;
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	eb 5c                	jmp    8010de <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	83 e0 03             	and    $0x3,%eax
  801088:	85 c0                	test   %eax,%eax
  80108a:	75 41                	jne    8010cd <memset+0x5a>
  80108c:	8b 45 10             	mov    0x10(%ebp),%eax
  80108f:	83 e0 03             	and    $0x3,%eax
  801092:	85 c0                	test   %eax,%eax
  801094:	75 37                	jne    8010cd <memset+0x5a>
		c &= 0xFF;
  801096:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80109d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a0:	c1 e0 18             	shl    $0x18,%eax
  8010a3:	89 c2                	mov    %eax,%edx
  8010a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a8:	c1 e0 10             	shl    $0x10,%eax
  8010ab:	09 c2                	or     %eax,%edx
  8010ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b0:	c1 e0 08             	shl    $0x8,%eax
  8010b3:	09 d0                	or     %edx,%eax
  8010b5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8010b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bb:	c1 e8 02             	shr    $0x2,%eax
  8010be:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8010c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c6:	89 d7                	mov    %edx,%edi
  8010c8:	fc                   	cld    
  8010c9:	f3 ab                	rep stos %eax,%es:(%edi)
  8010cb:	eb 0e                	jmp    8010db <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010d6:	89 d7                	mov    %edx,%edi
  8010d8:	fc                   	cld    
  8010d9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  8010f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8010fc:	73 6d                	jae    80116b <memmove+0x8a>
  8010fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801101:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801104:	01 d0                	add    %edx,%eax
  801106:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  801109:	76 60                	jbe    80116b <memmove+0x8a>
		s += n;
  80110b:	8b 45 10             	mov    0x10(%ebp),%eax
  80110e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  801111:	8b 45 10             	mov    0x10(%ebp),%eax
  801114:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801117:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80111a:	83 e0 03             	and    $0x3,%eax
  80111d:	85 c0                	test   %eax,%eax
  80111f:	75 2f                	jne    801150 <memmove+0x6f>
  801121:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801124:	83 e0 03             	and    $0x3,%eax
  801127:	85 c0                	test   %eax,%eax
  801129:	75 25                	jne    801150 <memmove+0x6f>
  80112b:	8b 45 10             	mov    0x10(%ebp),%eax
  80112e:	83 e0 03             	and    $0x3,%eax
  801131:	85 c0                	test   %eax,%eax
  801133:	75 1b                	jne    801150 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801135:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801138:	83 e8 04             	sub    $0x4,%eax
  80113b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80113e:	83 ea 04             	sub    $0x4,%edx
  801141:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801144:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801147:	89 c7                	mov    %eax,%edi
  801149:	89 d6                	mov    %edx,%esi
  80114b:	fd                   	std    
  80114c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80114e:	eb 18                	jmp    801168 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801150:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801153:	8d 50 ff             	lea    -0x1(%eax),%edx
  801156:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801159:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80115c:	8b 45 10             	mov    0x10(%ebp),%eax
  80115f:	89 d7                	mov    %edx,%edi
  801161:	89 de                	mov    %ebx,%esi
  801163:	89 c1                	mov    %eax,%ecx
  801165:	fd                   	std    
  801166:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801168:	fc                   	cld    
  801169:	eb 45                	jmp    8011b0 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	83 e0 03             	and    $0x3,%eax
  801171:	85 c0                	test   %eax,%eax
  801173:	75 2b                	jne    8011a0 <memmove+0xbf>
  801175:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801178:	83 e0 03             	and    $0x3,%eax
  80117b:	85 c0                	test   %eax,%eax
  80117d:	75 21                	jne    8011a0 <memmove+0xbf>
  80117f:	8b 45 10             	mov    0x10(%ebp),%eax
  801182:	83 e0 03             	and    $0x3,%eax
  801185:	85 c0                	test   %eax,%eax
  801187:	75 17                	jne    8011a0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801189:	8b 45 10             	mov    0x10(%ebp),%eax
  80118c:	c1 e8 02             	shr    $0x2,%eax
  80118f:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801191:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801194:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801197:	89 c7                	mov    %eax,%edi
  801199:	89 d6                	mov    %edx,%esi
  80119b:	fc                   	cld    
  80119c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80119e:	eb 10                	jmp    8011b0 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011a9:	89 c7                	mov    %eax,%edi
  8011ab:	89 d6                	mov    %edx,%esi
  8011ad:	fc                   	cld    
  8011ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8011c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	89 04 24             	mov    %eax,(%esp)
  8011d5:	e8 07 ff ff ff       	call   8010e1 <memmove>
}
  8011da:	c9                   	leave  
  8011db:	c3                   	ret    

008011dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  8011e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011eb:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  8011ee:	eb 30                	jmp    801220 <memcmp+0x44>
		if (*s1 != *s2)
  8011f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011f3:	0f b6 10             	movzbl (%eax),%edx
  8011f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011f9:	0f b6 00             	movzbl (%eax),%eax
  8011fc:	38 c2                	cmp    %al,%dl
  8011fe:	74 18                	je     801218 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801200:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801203:	0f b6 00             	movzbl (%eax),%eax
  801206:	0f b6 d0             	movzbl %al,%edx
  801209:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80120c:	0f b6 00             	movzbl (%eax),%eax
  80120f:	0f b6 c0             	movzbl %al,%eax
  801212:	29 c2                	sub    %eax,%edx
  801214:	89 d0                	mov    %edx,%eax
  801216:	eb 1a                	jmp    801232 <memcmp+0x56>
		s1++, s2++;
  801218:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80121c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801220:	8b 45 10             	mov    0x10(%ebp),%eax
  801223:	8d 50 ff             	lea    -0x1(%eax),%edx
  801226:	89 55 10             	mov    %edx,0x10(%ebp)
  801229:	85 c0                	test   %eax,%eax
  80122b:	75 c3                	jne    8011f0 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80123a:	8b 45 10             	mov    0x10(%ebp),%eax
  80123d:	8b 55 08             	mov    0x8(%ebp),%edx
  801240:	01 d0                	add    %edx,%eax
  801242:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801245:	eb 13                	jmp    80125a <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801247:	8b 45 08             	mov    0x8(%ebp),%eax
  80124a:	0f b6 10             	movzbl (%eax),%edx
  80124d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801250:	38 c2                	cmp    %al,%dl
  801252:	75 02                	jne    801256 <memfind+0x22>
			break;
  801254:	eb 0c                	jmp    801262 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801256:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801260:	72 e5                	jb     801247 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80126d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801274:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80127b:	eb 04                	jmp    801281 <strtol+0x1a>
		s++;
  80127d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801281:	8b 45 08             	mov    0x8(%ebp),%eax
  801284:	0f b6 00             	movzbl (%eax),%eax
  801287:	3c 20                	cmp    $0x20,%al
  801289:	74 f2                	je     80127d <strtol+0x16>
  80128b:	8b 45 08             	mov    0x8(%ebp),%eax
  80128e:	0f b6 00             	movzbl (%eax),%eax
  801291:	3c 09                	cmp    $0x9,%al
  801293:	74 e8                	je     80127d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	0f b6 00             	movzbl (%eax),%eax
  80129b:	3c 2b                	cmp    $0x2b,%al
  80129d:	75 06                	jne    8012a5 <strtol+0x3e>
		s++;
  80129f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012a3:	eb 15                	jmp    8012ba <strtol+0x53>
	else if (*s == '-')
  8012a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a8:	0f b6 00             	movzbl (%eax),%eax
  8012ab:	3c 2d                	cmp    $0x2d,%al
  8012ad:	75 0b                	jne    8012ba <strtol+0x53>
		s++, neg = 1;
  8012af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012b3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8012ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012be:	74 06                	je     8012c6 <strtol+0x5f>
  8012c0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8012c4:	75 24                	jne    8012ea <strtol+0x83>
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	0f b6 00             	movzbl (%eax),%eax
  8012cc:	3c 30                	cmp    $0x30,%al
  8012ce:	75 1a                	jne    8012ea <strtol+0x83>
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	83 c0 01             	add    $0x1,%eax
  8012d6:	0f b6 00             	movzbl (%eax),%eax
  8012d9:	3c 78                	cmp    $0x78,%al
  8012db:	75 0d                	jne    8012ea <strtol+0x83>
		s += 2, base = 16;
  8012dd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8012e1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8012e8:	eb 2a                	jmp    801314 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8012ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012ee:	75 17                	jne    801307 <strtol+0xa0>
  8012f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f3:	0f b6 00             	movzbl (%eax),%eax
  8012f6:	3c 30                	cmp    $0x30,%al
  8012f8:	75 0d                	jne    801307 <strtol+0xa0>
		s++, base = 8;
  8012fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8012fe:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801305:	eb 0d                	jmp    801314 <strtol+0xad>
	else if (base == 0)
  801307:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80130b:	75 07                	jne    801314 <strtol+0xad>
		base = 10;
  80130d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	0f b6 00             	movzbl (%eax),%eax
  80131a:	3c 2f                	cmp    $0x2f,%al
  80131c:	7e 1b                	jle    801339 <strtol+0xd2>
  80131e:	8b 45 08             	mov    0x8(%ebp),%eax
  801321:	0f b6 00             	movzbl (%eax),%eax
  801324:	3c 39                	cmp    $0x39,%al
  801326:	7f 11                	jg     801339 <strtol+0xd2>
			dig = *s - '0';
  801328:	8b 45 08             	mov    0x8(%ebp),%eax
  80132b:	0f b6 00             	movzbl (%eax),%eax
  80132e:	0f be c0             	movsbl %al,%eax
  801331:	83 e8 30             	sub    $0x30,%eax
  801334:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801337:	eb 48                	jmp    801381 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801339:	8b 45 08             	mov    0x8(%ebp),%eax
  80133c:	0f b6 00             	movzbl (%eax),%eax
  80133f:	3c 60                	cmp    $0x60,%al
  801341:	7e 1b                	jle    80135e <strtol+0xf7>
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
  801346:	0f b6 00             	movzbl (%eax),%eax
  801349:	3c 7a                	cmp    $0x7a,%al
  80134b:	7f 11                	jg     80135e <strtol+0xf7>
			dig = *s - 'a' + 10;
  80134d:	8b 45 08             	mov    0x8(%ebp),%eax
  801350:	0f b6 00             	movzbl (%eax),%eax
  801353:	0f be c0             	movsbl %al,%eax
  801356:	83 e8 57             	sub    $0x57,%eax
  801359:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80135c:	eb 23                	jmp    801381 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80135e:	8b 45 08             	mov    0x8(%ebp),%eax
  801361:	0f b6 00             	movzbl (%eax),%eax
  801364:	3c 40                	cmp    $0x40,%al
  801366:	7e 3d                	jle    8013a5 <strtol+0x13e>
  801368:	8b 45 08             	mov    0x8(%ebp),%eax
  80136b:	0f b6 00             	movzbl (%eax),%eax
  80136e:	3c 5a                	cmp    $0x5a,%al
  801370:	7f 33                	jg     8013a5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801372:	8b 45 08             	mov    0x8(%ebp),%eax
  801375:	0f b6 00             	movzbl (%eax),%eax
  801378:	0f be c0             	movsbl %al,%eax
  80137b:	83 e8 37             	sub    $0x37,%eax
  80137e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801381:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801384:	3b 45 10             	cmp    0x10(%ebp),%eax
  801387:	7c 02                	jl     80138b <strtol+0x124>
			break;
  801389:	eb 1a                	jmp    8013a5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80138b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80138f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801392:	0f af 45 10          	imul   0x10(%ebp),%eax
  801396:	89 c2                	mov    %eax,%edx
  801398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139b:	01 d0                	add    %edx,%eax
  80139d:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8013a0:	e9 6f ff ff ff       	jmp    801314 <strtol+0xad>

	if (endptr)
  8013a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013a9:	74 08                	je     8013b3 <strtol+0x14c>
		*endptr = (char *) s;
  8013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8013b3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8013b7:	74 07                	je     8013c0 <strtol+0x159>
  8013b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8013bc:	f7 d8                	neg    %eax
  8013be:	eb 03                	jmp    8013c3 <strtol+0x15c>
  8013c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	57                   	push   %edi
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8013d4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8013d7:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8013da:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8013dd:	8b 75 20             	mov    0x20(%ebp),%esi
  8013e0:	cd 30                	int    $0x30
  8013e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013e9:	74 30                	je     80141b <syscall+0x56>
  8013eb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8013ef:	7e 2a                	jle    80141b <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ff:	c7 44 24 08 a4 1e 80 	movl   $0x801ea4,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80140e:	00 
  80140f:	c7 04 24 c1 1e 80 00 	movl   $0x801ec1,(%esp)
  801416:	e8 84 f2 ff ff       	call   80069f <_panic>

	return ret;
  80141b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80141e:	83 c4 3c             	add    $0x3c,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80142c:	8b 45 08             	mov    0x8(%ebp),%eax
  80142f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801436:	00 
  801437:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80143e:	00 
  80143f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801446:	00 
  801447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80144e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801452:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801459:	00 
  80145a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801461:	e8 5f ff ff ff       	call   8013c5 <syscall>
}
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <sys_cgetc>:

int
sys_cgetc(void)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80146e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801475:	00 
  801476:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80147d:	00 
  80147e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801485:	00 
  801486:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80148d:	00 
  80148e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801495:	00 
  801496:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80149d:	00 
  80149e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014a5:	e8 1b ff ff ff       	call   8013c5 <syscall>
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8014b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8014bc:	00 
  8014bd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8014c4:	00 
  8014c5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8014cc:	00 
  8014cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014d4:	00 
  8014d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014e0:	00 
  8014e1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8014e8:	e8 d8 fe ff ff       	call   8013c5 <syscall>
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8014f5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8014fc:	00 
  8014fd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801504:	00 
  801505:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80150c:	00 
  80150d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801514:	00 
  801515:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80151c:	00 
  80151d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801524:	00 
  801525:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80152c:	e8 94 fe ff ff       	call   8013c5 <syscall>
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <sys_yield>:

void
sys_yield(void)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801539:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801540:	00 
  801541:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801548:	00 
  801549:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801550:	00 
  801551:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801558:	00 
  801559:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801560:	00 
  801561:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801568:	00 
  801569:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  801570:	e8 50 fe ff ff       	call   8013c5 <syscall>
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80157d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801580:	8b 55 0c             	mov    0xc(%ebp),%edx
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80158d:	00 
  80158e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801595:	00 
  801596:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80159a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80159e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015a9:	00 
  8015aa:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8015b1:	e8 0f fe ff ff       	call   8013c5 <syscall>
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8015c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8015c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8015c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cf:	89 74 24 18          	mov    %esi,0x18(%esp)
  8015d3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8015d7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8015db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015ea:	00 
  8015eb:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8015f2:	e8 ce fd ff ff       	call   8013c5 <syscall>
}
  8015f7:	83 c4 20             	add    $0x20,%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801604:	8b 55 0c             	mov    0xc(%ebp),%edx
  801607:	8b 45 08             	mov    0x8(%ebp),%eax
  80160a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801611:	00 
  801612:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  801619:	00 
  80161a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801621:	00 
  801622:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801626:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801631:	00 
  801632:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  801639:	e8 87 fd ff ff       	call   8013c5 <syscall>
}
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801646:	8b 55 0c             	mov    0xc(%ebp),%edx
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801653:	00 
  801654:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80165b:	00 
  80165c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801663:	00 
  801664:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801668:	89 44 24 08          	mov    %eax,0x8(%esp)
  80166c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801673:	00 
  801674:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80167b:	e8 45 fd ff ff       	call   8013c5 <syscall>
}
  801680:	c9                   	leave  
  801681:	c3                   	ret    

00801682 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801682:	55                   	push   %ebp
  801683:	89 e5                	mov    %esp,%ebp
  801685:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801688:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801695:	00 
  801696:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80169d:	00 
  80169e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8016a5:	00 
  8016a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ae:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016b5:	00 
  8016b6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8016bd:	e8 03 fd ff ff       	call   8013c5 <syscall>
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8016ca:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8016cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8016da:	00 
  8016db:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8016df:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016f5:	00 
  8016f6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8016fd:	e8 c3 fc ff ff       	call   8013c5 <syscall>
}
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801714:	00 
  801715:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80171c:	00 
  80171d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801724:	00 
  801725:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80172c:	00 
  80172d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801731:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801738:	00 
  801739:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  801740:	e8 80 fc ff ff       	call   8013c5 <syscall>
}
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <sys_exec>:

void sys_exec(char* buf){
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801757:	00 
  801758:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80175f:	00 
  801760:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  801767:	00 
  801768:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80176f:	00 
  801770:	89 44 24 08          	mov    %eax,0x8(%esp)
  801774:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80177b:	00 
  80177c:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  801783:	e8 3d fc ff ff       	call   8013c5 <syscall>
}
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <sys_wait>:

void sys_wait(){
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  801790:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  801797:	00 
  801798:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80179f:	00 
  8017a0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8017a7:	00 
  8017a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017af:	00 
  8017b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b7:	00 
  8017b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017bf:	00 
  8017c0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8017c7:	e8 f9 fb ff ff       	call   8013c5 <syscall>
  8017cc:	c9                   	leave  
  8017cd:	c3                   	ret    

008017ce <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8017d4:	a1 d0 20 80 00       	mov    0x8020d0,%eax
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	75 5d                	jne    80183a <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  8017dd:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8017e2:	8b 40 48             	mov    0x48(%eax),%eax
  8017e5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017ec:	00 
  8017ed:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017f4:	ee 
  8017f5:	89 04 24             	mov    %eax,(%esp)
  8017f8:	e8 7a fd ff ff       	call   801577 <sys_page_alloc>
  8017fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801800:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801804:	79 1c                	jns    801822 <set_pgfault_handler+0x54>
  801806:	c7 44 24 08 d0 1e 80 	movl   $0x801ed0,0x8(%esp)
  80180d:	00 
  80180e:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801815:	00 
  801816:	c7 04 24 fc 1e 80 00 	movl   $0x801efc,(%esp)
  80181d:	e8 7d ee ff ff       	call   80069f <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801822:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801827:	8b 40 48             	mov    0x48(%eax),%eax
  80182a:	c7 44 24 04 44 18 80 	movl   $0x801844,0x4(%esp)
  801831:	00 
  801832:	89 04 24             	mov    %eax,(%esp)
  801835:	e8 48 fe ff ff       	call   801682 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801842:	c9                   	leave  
  801843:	c3                   	ret    

00801844 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801844:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801845:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80184a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80184c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  80184f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801853:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801855:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801859:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  80185a:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80185d:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  80185f:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  801860:	58                   	pop    %eax
	popal 						// pop all the registers
  801861:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  801862:	83 c4 04             	add    $0x4,%esp
	popfl
  801865:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801866:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801867:	c3                   	ret    
  801868:	66 90                	xchg   %ax,%ax
  80186a:	66 90                	xchg   %ax,%ax
  80186c:	66 90                	xchg   %ax,%ax
  80186e:	66 90                	xchg   %ax,%ax

00801870 <__udivdi3>:
  801870:	55                   	push   %ebp
  801871:	57                   	push   %edi
  801872:	56                   	push   %esi
  801873:	83 ec 0c             	sub    $0xc,%esp
  801876:	8b 44 24 28          	mov    0x28(%esp),%eax
  80187a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80187e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801882:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801886:	85 c0                	test   %eax,%eax
  801888:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80188c:	89 ea                	mov    %ebp,%edx
  80188e:	89 0c 24             	mov    %ecx,(%esp)
  801891:	75 2d                	jne    8018c0 <__udivdi3+0x50>
  801893:	39 e9                	cmp    %ebp,%ecx
  801895:	77 61                	ja     8018f8 <__udivdi3+0x88>
  801897:	85 c9                	test   %ecx,%ecx
  801899:	89 ce                	mov    %ecx,%esi
  80189b:	75 0b                	jne    8018a8 <__udivdi3+0x38>
  80189d:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a2:	31 d2                	xor    %edx,%edx
  8018a4:	f7 f1                	div    %ecx
  8018a6:	89 c6                	mov    %eax,%esi
  8018a8:	31 d2                	xor    %edx,%edx
  8018aa:	89 e8                	mov    %ebp,%eax
  8018ac:	f7 f6                	div    %esi
  8018ae:	89 c5                	mov    %eax,%ebp
  8018b0:	89 f8                	mov    %edi,%eax
  8018b2:	f7 f6                	div    %esi
  8018b4:	89 ea                	mov    %ebp,%edx
  8018b6:	83 c4 0c             	add    $0xc,%esp
  8018b9:	5e                   	pop    %esi
  8018ba:	5f                   	pop    %edi
  8018bb:	5d                   	pop    %ebp
  8018bc:	c3                   	ret    
  8018bd:	8d 76 00             	lea    0x0(%esi),%esi
  8018c0:	39 e8                	cmp    %ebp,%eax
  8018c2:	77 24                	ja     8018e8 <__udivdi3+0x78>
  8018c4:	0f bd e8             	bsr    %eax,%ebp
  8018c7:	83 f5 1f             	xor    $0x1f,%ebp
  8018ca:	75 3c                	jne    801908 <__udivdi3+0x98>
  8018cc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8018d0:	39 34 24             	cmp    %esi,(%esp)
  8018d3:	0f 86 9f 00 00 00    	jbe    801978 <__udivdi3+0x108>
  8018d9:	39 d0                	cmp    %edx,%eax
  8018db:	0f 82 97 00 00 00    	jb     801978 <__udivdi3+0x108>
  8018e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8018e8:	31 d2                	xor    %edx,%edx
  8018ea:	31 c0                	xor    %eax,%eax
  8018ec:	83 c4 0c             	add    $0xc,%esp
  8018ef:	5e                   	pop    %esi
  8018f0:	5f                   	pop    %edi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    
  8018f3:	90                   	nop
  8018f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018f8:	89 f8                	mov    %edi,%eax
  8018fa:	f7 f1                	div    %ecx
  8018fc:	31 d2                	xor    %edx,%edx
  8018fe:	83 c4 0c             	add    $0xc,%esp
  801901:	5e                   	pop    %esi
  801902:	5f                   	pop    %edi
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    
  801905:	8d 76 00             	lea    0x0(%esi),%esi
  801908:	89 e9                	mov    %ebp,%ecx
  80190a:	8b 3c 24             	mov    (%esp),%edi
  80190d:	d3 e0                	shl    %cl,%eax
  80190f:	89 c6                	mov    %eax,%esi
  801911:	b8 20 00 00 00       	mov    $0x20,%eax
  801916:	29 e8                	sub    %ebp,%eax
  801918:	89 c1                	mov    %eax,%ecx
  80191a:	d3 ef                	shr    %cl,%edi
  80191c:	89 e9                	mov    %ebp,%ecx
  80191e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801922:	8b 3c 24             	mov    (%esp),%edi
  801925:	09 74 24 08          	or     %esi,0x8(%esp)
  801929:	89 d6                	mov    %edx,%esi
  80192b:	d3 e7                	shl    %cl,%edi
  80192d:	89 c1                	mov    %eax,%ecx
  80192f:	89 3c 24             	mov    %edi,(%esp)
  801932:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801936:	d3 ee                	shr    %cl,%esi
  801938:	89 e9                	mov    %ebp,%ecx
  80193a:	d3 e2                	shl    %cl,%edx
  80193c:	89 c1                	mov    %eax,%ecx
  80193e:	d3 ef                	shr    %cl,%edi
  801940:	09 d7                	or     %edx,%edi
  801942:	89 f2                	mov    %esi,%edx
  801944:	89 f8                	mov    %edi,%eax
  801946:	f7 74 24 08          	divl   0x8(%esp)
  80194a:	89 d6                	mov    %edx,%esi
  80194c:	89 c7                	mov    %eax,%edi
  80194e:	f7 24 24             	mull   (%esp)
  801951:	39 d6                	cmp    %edx,%esi
  801953:	89 14 24             	mov    %edx,(%esp)
  801956:	72 30                	jb     801988 <__udivdi3+0x118>
  801958:	8b 54 24 04          	mov    0x4(%esp),%edx
  80195c:	89 e9                	mov    %ebp,%ecx
  80195e:	d3 e2                	shl    %cl,%edx
  801960:	39 c2                	cmp    %eax,%edx
  801962:	73 05                	jae    801969 <__udivdi3+0xf9>
  801964:	3b 34 24             	cmp    (%esp),%esi
  801967:	74 1f                	je     801988 <__udivdi3+0x118>
  801969:	89 f8                	mov    %edi,%eax
  80196b:	31 d2                	xor    %edx,%edx
  80196d:	e9 7a ff ff ff       	jmp    8018ec <__udivdi3+0x7c>
  801972:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801978:	31 d2                	xor    %edx,%edx
  80197a:	b8 01 00 00 00       	mov    $0x1,%eax
  80197f:	e9 68 ff ff ff       	jmp    8018ec <__udivdi3+0x7c>
  801984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801988:	8d 47 ff             	lea    -0x1(%edi),%eax
  80198b:	31 d2                	xor    %edx,%edx
  80198d:	83 c4 0c             	add    $0xc,%esp
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    
  801994:	66 90                	xchg   %ax,%ax
  801996:	66 90                	xchg   %ax,%ax
  801998:	66 90                	xchg   %ax,%ax
  80199a:	66 90                	xchg   %ax,%ax
  80199c:	66 90                	xchg   %ax,%ax
  80199e:	66 90                	xchg   %ax,%ax

008019a0 <__umoddi3>:
  8019a0:	55                   	push   %ebp
  8019a1:	57                   	push   %edi
  8019a2:	56                   	push   %esi
  8019a3:	83 ec 14             	sub    $0x14,%esp
  8019a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8019aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8019ae:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8019b2:	89 c7                	mov    %eax,%edi
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8019bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8019c0:	89 34 24             	mov    %esi,(%esp)
  8019c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019cf:	75 17                	jne    8019e8 <__umoddi3+0x48>
  8019d1:	39 fe                	cmp    %edi,%esi
  8019d3:	76 4b                	jbe    801a20 <__umoddi3+0x80>
  8019d5:	89 c8                	mov    %ecx,%eax
  8019d7:	89 fa                	mov    %edi,%edx
  8019d9:	f7 f6                	div    %esi
  8019db:	89 d0                	mov    %edx,%eax
  8019dd:	31 d2                	xor    %edx,%edx
  8019df:	83 c4 14             	add    $0x14,%esp
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    
  8019e6:	66 90                	xchg   %ax,%ax
  8019e8:	39 f8                	cmp    %edi,%eax
  8019ea:	77 54                	ja     801a40 <__umoddi3+0xa0>
  8019ec:	0f bd e8             	bsr    %eax,%ebp
  8019ef:	83 f5 1f             	xor    $0x1f,%ebp
  8019f2:	75 5c                	jne    801a50 <__umoddi3+0xb0>
  8019f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8019f8:	39 3c 24             	cmp    %edi,(%esp)
  8019fb:	0f 87 e7 00 00 00    	ja     801ae8 <__umoddi3+0x148>
  801a01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801a05:	29 f1                	sub    %esi,%ecx
  801a07:	19 c7                	sbb    %eax,%edi
  801a09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a11:	8b 44 24 08          	mov    0x8(%esp),%eax
  801a15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801a19:	83 c4 14             	add    $0x14,%esp
  801a1c:	5e                   	pop    %esi
  801a1d:	5f                   	pop    %edi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    
  801a20:	85 f6                	test   %esi,%esi
  801a22:	89 f5                	mov    %esi,%ebp
  801a24:	75 0b                	jne    801a31 <__umoddi3+0x91>
  801a26:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2b:	31 d2                	xor    %edx,%edx
  801a2d:	f7 f6                	div    %esi
  801a2f:	89 c5                	mov    %eax,%ebp
  801a31:	8b 44 24 04          	mov    0x4(%esp),%eax
  801a35:	31 d2                	xor    %edx,%edx
  801a37:	f7 f5                	div    %ebp
  801a39:	89 c8                	mov    %ecx,%eax
  801a3b:	f7 f5                	div    %ebp
  801a3d:	eb 9c                	jmp    8019db <__umoddi3+0x3b>
  801a3f:	90                   	nop
  801a40:	89 c8                	mov    %ecx,%eax
  801a42:	89 fa                	mov    %edi,%edx
  801a44:	83 c4 14             	add    $0x14,%esp
  801a47:	5e                   	pop    %esi
  801a48:	5f                   	pop    %edi
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    
  801a4b:	90                   	nop
  801a4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a50:	8b 04 24             	mov    (%esp),%eax
  801a53:	be 20 00 00 00       	mov    $0x20,%esi
  801a58:	89 e9                	mov    %ebp,%ecx
  801a5a:	29 ee                	sub    %ebp,%esi
  801a5c:	d3 e2                	shl    %cl,%edx
  801a5e:	89 f1                	mov    %esi,%ecx
  801a60:	d3 e8                	shr    %cl,%eax
  801a62:	89 e9                	mov    %ebp,%ecx
  801a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a68:	8b 04 24             	mov    (%esp),%eax
  801a6b:	09 54 24 04          	or     %edx,0x4(%esp)
  801a6f:	89 fa                	mov    %edi,%edx
  801a71:	d3 e0                	shl    %cl,%eax
  801a73:	89 f1                	mov    %esi,%ecx
  801a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a79:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a7d:	d3 ea                	shr    %cl,%edx
  801a7f:	89 e9                	mov    %ebp,%ecx
  801a81:	d3 e7                	shl    %cl,%edi
  801a83:	89 f1                	mov    %esi,%ecx
  801a85:	d3 e8                	shr    %cl,%eax
  801a87:	89 e9                	mov    %ebp,%ecx
  801a89:	09 f8                	or     %edi,%eax
  801a8b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a8f:	f7 74 24 04          	divl   0x4(%esp)
  801a93:	d3 e7                	shl    %cl,%edi
  801a95:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a99:	89 d7                	mov    %edx,%edi
  801a9b:	f7 64 24 08          	mull   0x8(%esp)
  801a9f:	39 d7                	cmp    %edx,%edi
  801aa1:	89 c1                	mov    %eax,%ecx
  801aa3:	89 14 24             	mov    %edx,(%esp)
  801aa6:	72 2c                	jb     801ad4 <__umoddi3+0x134>
  801aa8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801aac:	72 22                	jb     801ad0 <__umoddi3+0x130>
  801aae:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ab2:	29 c8                	sub    %ecx,%eax
  801ab4:	19 d7                	sbb    %edx,%edi
  801ab6:	89 e9                	mov    %ebp,%ecx
  801ab8:	89 fa                	mov    %edi,%edx
  801aba:	d3 e8                	shr    %cl,%eax
  801abc:	89 f1                	mov    %esi,%ecx
  801abe:	d3 e2                	shl    %cl,%edx
  801ac0:	89 e9                	mov    %ebp,%ecx
  801ac2:	d3 ef                	shr    %cl,%edi
  801ac4:	09 d0                	or     %edx,%eax
  801ac6:	89 fa                	mov    %edi,%edx
  801ac8:	83 c4 14             	add    $0x14,%esp
  801acb:	5e                   	pop    %esi
  801acc:	5f                   	pop    %edi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    
  801acf:	90                   	nop
  801ad0:	39 d7                	cmp    %edx,%edi
  801ad2:	75 da                	jne    801aae <__umoddi3+0x10e>
  801ad4:	8b 14 24             	mov    (%esp),%edx
  801ad7:	89 c1                	mov    %eax,%ecx
  801ad9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801add:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801ae1:	eb cb                	jmp    801aae <__umoddi3+0x10e>
  801ae3:	90                   	nop
  801ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ae8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801aec:	0f 82 0f ff ff ff    	jb     801a01 <__umoddi3+0x61>
  801af2:	e9 1a ff ff ff       	jmp    801a11 <__umoddi3+0x71>
