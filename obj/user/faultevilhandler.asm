
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 45 00 00 00       	call   800076 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 36 02 00 00       	call   80028b <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800055:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005c:	f0 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 2d 03 00 00       	call   800396 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
  80006e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    

00800076 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800076:	55                   	push   %ebp
  800077:	89 e5                	mov    %esp,%ebp
  800079:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80007c:	e8 82 01 00 00       	call   800203 <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	c1 e0 02             	shl    $0x2,%eax
  800089:	89 c2                	mov    %eax,%edx
  80008b:	c1 e2 05             	shl    $0x5,%edx
  80008e:	29 c2                	sub    %eax,%edx
  800090:	89 d0                	mov    %edx,%eax
  800092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000a0:	7e 0a                	jle    8000ac <libmain+0x36>
		binaryname = argv[0];
  8000a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a5:	8b 00                	mov    (%eax),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b6:	89 04 24             	mov    %eax,(%esp)
  8000b9:	e8 75 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000be:	e8 02 00 00 00       	call   8000c5 <exit>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d2:	e8 e9 00 00 00       	call   8001c0 <sys_env_destroy>
}
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
  8000df:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000e8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000eb:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000ee:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000f1:	8b 75 20             	mov    0x20(%ebp),%esi
  8000f4:	cd 30                	int    $0x30
  8000f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000fd:	74 30                	je     80012f <syscall+0x56>
  8000ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800103:	7e 2a                	jle    80012f <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800108:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010c:	8b 45 08             	mov    0x8(%ebp),%eax
  80010f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800113:	c7 44 24 08 6a 14 80 	movl   $0x80146a,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  80012a:	e8 6f 03 00 00       	call   80049e <_panic>

	return ret;
  80012f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800132:	83 c4 3c             	add    $0x3c,%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800140:	8b 45 08             	mov    0x8(%ebp),%eax
  800143:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80014a:	00 
  80014b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800152:	00 
  800153:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80015a:	00 
  80015b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80015e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800162:	89 44 24 08          	mov    %eax,0x8(%esp)
  800166:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80016d:	00 
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 5f ff ff ff       	call   8000d9 <syscall>
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <sys_cgetc>:

int
sys_cgetc(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800182:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800189:	00 
  80018a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800191:	00 
  800192:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800199:	00 
  80019a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001b1:	00 
  8001b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001b9:	e8 1b ff ff ff       	call   8000d9 <syscall>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e8:	00 
  8001e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001fc:	e8 d8 fe ff ff       	call   8000d9 <syscall>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800209:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800210:	00 
  800211:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800218:	00 
  800219:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800220:	00 
  800221:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800228:	00 
  800229:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800240:	e8 94 fe ff ff       	call   8000d9 <syscall>
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <sys_yield>:

void
sys_yield(void)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80024d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800254:	00 
  800255:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80025c:	00 
  80025d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800264:	00 
  800265:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026c:	00 
  80026d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800274:	00 
  800275:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80027c:	00 
  80027d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800284:	e8 50 fe ff ff       	call   8000d9 <syscall>
}
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800291:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002a9:	00 
  8002aa:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8002c5:	e8 0f fe ff ff       	call   8000d9 <syscall>
}
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002d4:	8b 75 18             	mov    0x18(%ebp),%esi
  8002d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002e7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002eb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002fe:	00 
  8002ff:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  800306:	e8 ce fd ff ff       	call   8000d9 <syscall>
}
  80030b:	83 c4 20             	add    $0x20,%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800318:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800325:	00 
  800326:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80032d:	00 
  80032e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800335:	00 
  800336:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80034d:	e8 87 fd ff ff       	call   8000d9 <syscall>
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80035a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800367:	00 
  800368:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80036f:	00 
  800370:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800377:	00 
  800378:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800387:	00 
  800388:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80038f:	e8 45 fd ff ff       	call   8000d9 <syscall>
}
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80039c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003a9:	00 
  8003aa:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003b1:	00 
  8003b2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003b9:	00 
  8003ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003c9:	00 
  8003ca:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003d1:	e8 03 fd ff ff       	call   8000d9 <syscall>
}
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8003e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ee:	00 
  8003ef:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003f3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800402:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800409:	00 
  80040a:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  800411:	e8 c3 fc ff ff       	call   8000d9 <syscall>
}
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800428:	00 
  800429:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800430:	00 
  800431:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800438:	00 
  800439:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800440:	00 
  800441:	89 44 24 08          	mov    %eax,0x8(%esp)
  800445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80044c:	00 
  80044d:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800454:	e8 80 fc ff ff       	call   8000d9 <syscall>
}
  800459:	c9                   	leave  
  80045a:	c3                   	ret    

0080045b <sys_exec>:

void sys_exec(char* buf){
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80046b:	00 
  80046c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800473:	00 
  800474:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80047b:	00 
  80047c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800483:	00 
  800484:	89 44 24 08          	mov    %eax,0x8(%esp)
  800488:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80048f:	00 
  800490:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800497:	e8 3d fc ff ff       	call   8000d9 <syscall>
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    

0080049e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	53                   	push   %ebx
  8004a2:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a8:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ab:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004b1:	e8 4d fd ff ff       	call   800203 <sys_getenvid>
  8004b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cc:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8004d3:	e8 e1 00 00 00       	call   8005b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004df:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	e8 6b 00 00 00       	call   800555 <vcprintf>
	cprintf("\n");
  8004ea:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8004f1:	e8 c3 00 00 00       	call   8005b9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004f6:	cc                   	int3   
  8004f7:	eb fd                	jmp    8004f6 <_panic+0x58>

008004f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800502:	8b 00                	mov    (%eax),%eax
  800504:	8d 48 01             	lea    0x1(%eax),%ecx
  800507:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050a:	89 0a                	mov    %ecx,(%edx)
  80050c:	8b 55 08             	mov    0x8(%ebp),%edx
  80050f:	89 d1                	mov    %edx,%ecx
  800511:	8b 55 0c             	mov    0xc(%ebp),%edx
  800514:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800522:	75 20                	jne    800544 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800524:	8b 45 0c             	mov    0xc(%ebp),%eax
  800527:	8b 00                	mov    (%eax),%eax
  800529:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052c:	83 c2 08             	add    $0x8,%edx
  80052f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800533:	89 14 24             	mov    %edx,(%esp)
  800536:	e8 ff fb ff ff       	call   80013a <sys_cputs>
		b->idx = 0;
  80053b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800544:	8b 45 0c             	mov    0xc(%ebp),%eax
  800547:	8b 40 04             	mov    0x4(%eax),%eax
  80054a:	8d 50 01             	lea    0x1(%eax),%edx
  80054d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800550:	89 50 04             	mov    %edx,0x4(%eax)
}
  800553:	c9                   	leave  
  800554:	c3                   	ret    

00800555 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80055e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800565:	00 00 00 
	b.cnt = 0;
  800568:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80056f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800579:	8b 45 08             	mov    0x8(%ebp),%eax
  80057c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800580:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800586:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058a:	c7 04 24 f9 04 80 00 	movl   $0x8004f9,(%esp)
  800591:	e8 bd 01 00 00       	call   800753 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800596:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005a6:	83 c0 08             	add    $0x8,%eax
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	e8 89 fb ff ff       	call   80013a <sys_cputs>

	return b.cnt;
  8005b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005b7:	c9                   	leave  
  8005b8:	c3                   	ret    

008005b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bf:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 7e ff ff ff       	call   800555 <vcprintf>
  8005d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005da:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	53                   	push   %ebx
  8005e3:	83 ec 34             	sub    $0x34,%esp
  8005e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f2:	8b 45 18             	mov    0x18(%ebp),%eax
  8005f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fa:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005fd:	77 72                	ja     800671 <printnum+0x92>
  8005ff:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800602:	72 05                	jb     800609 <printnum+0x2a>
  800604:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800607:	77 68                	ja     800671 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800609:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80060c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060f:	8b 45 18             	mov    0x18(%ebp),%eax
  800612:	ba 00 00 00 00       	mov    $0x0,%edx
  800617:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800622:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800625:	89 04 24             	mov    %eax,(%esp)
  800628:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062c:	e8 9f 0b 00 00       	call   8011d0 <__udivdi3>
  800631:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800634:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800638:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80063c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80063f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800643:	89 44 24 08          	mov    %eax,0x8(%esp)
  800647:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	89 04 24             	mov    %eax,(%esp)
  800658:	e8 82 ff ff ff       	call   8005df <printnum>
  80065d:	eb 1c                	jmp    80067b <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80065f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800662:	89 44 24 04          	mov    %eax,0x4(%esp)
  800666:	8b 45 20             	mov    0x20(%ebp),%eax
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800671:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800675:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800679:	7f e4                	jg     80065f <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80067b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80067e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800686:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800689:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80068d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	89 54 24 04          	mov    %edx,0x4(%esp)
  800698:	e8 63 0c 00 00       	call   801300 <__umoddi3>
  80069d:	05 88 15 80 00       	add    $0x801588,%eax
  8006a2:	0f b6 00             	movzbl (%eax),%eax
  8006a5:	0f be c0             	movsbl %al,%eax
  8006a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	ff d0                	call   *%eax
}
  8006b7:	83 c4 34             	add    $0x34,%esp
  8006ba:	5b                   	pop    %ebx
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006c0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006c4:	7e 14                	jle    8006da <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	8b 00                	mov    (%eax),%eax
  8006cb:	8d 48 08             	lea    0x8(%eax),%ecx
  8006ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d1:	89 0a                	mov    %ecx,(%edx)
  8006d3:	8b 50 04             	mov    0x4(%eax),%edx
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	eb 30                	jmp    80070a <getuint+0x4d>
	else if (lflag)
  8006da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006de:	74 16                	je     8006f6 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006eb:	89 0a                	mov    %ecx,(%edx)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f4:	eb 14                	jmp    80070a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800701:	89 0a                	mov    %ecx,(%edx)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80070f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800713:	7e 14                	jle    800729 <getint+0x1d>
		return va_arg(*ap, long long);
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	8d 48 08             	lea    0x8(%eax),%ecx
  80071d:	8b 55 08             	mov    0x8(%ebp),%edx
  800720:	89 0a                	mov    %ecx,(%edx)
  800722:	8b 50 04             	mov    0x4(%eax),%edx
  800725:	8b 00                	mov    (%eax),%eax
  800727:	eb 28                	jmp    800751 <getint+0x45>
	else if (lflag)
  800729:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80072d:	74 12                	je     800741 <getint+0x35>
		return va_arg(*ap, long);
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 00                	mov    (%eax),%eax
  800734:	8d 48 04             	lea    0x4(%eax),%ecx
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
  80073a:	89 0a                	mov    %ecx,(%edx)
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	99                   	cltd   
  80073f:	eb 10                	jmp    800751 <getint+0x45>
	else
		return va_arg(*ap, int);
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 00                	mov    (%eax),%eax
  800746:	8d 48 04             	lea    0x4(%eax),%ecx
  800749:	8b 55 08             	mov    0x8(%ebp),%edx
  80074c:	89 0a                	mov    %ecx,(%edx)
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	99                   	cltd   
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075b:	eb 18                	jmp    800775 <vprintfmt+0x22>
			if (ch == '\0')
  80075d:	85 db                	test   %ebx,%ebx
  80075f:	75 05                	jne    800766 <vprintfmt+0x13>
				return;
  800761:	e9 cc 03 00 00       	jmp    800b32 <vprintfmt+0x3df>
			putch(ch, putdat);
  800766:	8b 45 0c             	mov    0xc(%ebp),%eax
  800769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076d:	89 1c 24             	mov    %ebx,(%esp)
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800775:	8b 45 10             	mov    0x10(%ebp),%eax
  800778:	8d 50 01             	lea    0x1(%eax),%edx
  80077b:	89 55 10             	mov    %edx,0x10(%ebp)
  80077e:	0f b6 00             	movzbl (%eax),%eax
  800781:	0f b6 d8             	movzbl %al,%ebx
  800784:	83 fb 25             	cmp    $0x25,%ebx
  800787:	75 d4                	jne    80075d <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800789:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80078d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800794:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80079b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007a2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ac:	8d 50 01             	lea    0x1(%eax),%edx
  8007af:	89 55 10             	mov    %edx,0x10(%ebp)
  8007b2:	0f b6 00             	movzbl (%eax),%eax
  8007b5:	0f b6 d8             	movzbl %al,%ebx
  8007b8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007bb:	83 f8 55             	cmp    $0x55,%eax
  8007be:	0f 87 3d 03 00 00    	ja     800b01 <vprintfmt+0x3ae>
  8007c4:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  8007cb:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007cd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007d1:	eb d6                	jmp    8007a9 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007d3:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007d7:	eb d0                	jmp    8007a9 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007e3:	89 d0                	mov    %edx,%eax
  8007e5:	c1 e0 02             	shl    $0x2,%eax
  8007e8:	01 d0                	add    %edx,%eax
  8007ea:	01 c0                	add    %eax,%eax
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	83 e8 30             	sub    $0x30,%eax
  8007f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f7:	0f b6 00             	movzbl (%eax),%eax
  8007fa:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007fd:	83 fb 2f             	cmp    $0x2f,%ebx
  800800:	7e 0b                	jle    80080d <vprintfmt+0xba>
  800802:	83 fb 39             	cmp    $0x39,%ebx
  800805:	7f 06                	jg     80080d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800807:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80080b:	eb d3                	jmp    8007e0 <vprintfmt+0x8d>
			goto process_precision;
  80080d:	eb 33                	jmp    800842 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80081d:	eb 23                	jmp    800842 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80081f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800823:	79 0c                	jns    800831 <vprintfmt+0xde>
				width = 0;
  800825:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80082c:	e9 78 ff ff ff       	jmp    8007a9 <vprintfmt+0x56>
  800831:	e9 73 ff ff ff       	jmp    8007a9 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800836:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80083d:	e9 67 ff ff ff       	jmp    8007a9 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800842:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800846:	79 12                	jns    80085a <vprintfmt+0x107>
				width = precision, precision = -1;
  800848:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80084b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80084e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800855:	e9 4f ff ff ff       	jmp    8007a9 <vprintfmt+0x56>
  80085a:	e9 4a ff ff ff       	jmp    8007a9 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80085f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800863:	e9 41 ff ff ff       	jmp    8007a9 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 00                	mov    (%eax),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	ff d0                	call   *%eax
			break;
  800882:	e9 a5 02 00 00       	jmp    800b2c <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8d 50 04             	lea    0x4(%eax),%edx
  80088d:	89 55 14             	mov    %edx,0x14(%ebp)
  800890:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800892:	85 db                	test   %ebx,%ebx
  800894:	79 02                	jns    800898 <vprintfmt+0x145>
				err = -err;
  800896:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800898:	83 fb 09             	cmp    $0x9,%ebx
  80089b:	7f 0b                	jg     8008a8 <vprintfmt+0x155>
  80089d:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  8008a4:	85 f6                	test   %esi,%esi
  8008a6:	75 23                	jne    8008cb <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008ac:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  8008b3:	00 
  8008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	89 04 24             	mov    %eax,(%esp)
  8008c1:	e8 73 02 00 00       	call   800b39 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008c6:	e9 61 02 00 00       	jmp    800b2c <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008cb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008cf:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008d6:	00 
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	89 04 24             	mov    %eax,(%esp)
  8008e4:	e8 50 02 00 00       	call   800b39 <printfmt>
			break;
  8008e9:	e9 3e 02 00 00       	jmp    800b2c <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8d 50 04             	lea    0x4(%eax),%edx
  8008f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f7:	8b 30                	mov    (%eax),%esi
  8008f9:	85 f6                	test   %esi,%esi
  8008fb:	75 05                	jne    800902 <vprintfmt+0x1af>
				p = "(null)";
  8008fd:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  800902:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800906:	7e 37                	jle    80093f <vprintfmt+0x1ec>
  800908:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80090c:	74 31                	je     80093f <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80090e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	89 34 24             	mov    %esi,(%esp)
  800918:	e8 39 03 00 00       	call   800c56 <strnlen>
  80091d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800920:	eb 17                	jmp    800939 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800922:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 54 24 04          	mov    %edx,0x4(%esp)
  80092d:	89 04 24             	mov    %eax,(%esp)
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800935:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800939:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093d:	7f e3                	jg     800922 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093f:	eb 38                	jmp    800979 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800941:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800945:	74 1f                	je     800966 <vprintfmt+0x213>
  800947:	83 fb 1f             	cmp    $0x1f,%ebx
  80094a:	7e 05                	jle    800951 <vprintfmt+0x1fe>
  80094c:	83 fb 7e             	cmp    $0x7e,%ebx
  80094f:	7e 15                	jle    800966 <vprintfmt+0x213>
					putch('?', putdat);
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	ff d0                	call   *%eax
  800964:	eb 0f                	jmp    800975 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096d:	89 1c 24             	mov    %ebx,(%esp)
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800975:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800979:	89 f0                	mov    %esi,%eax
  80097b:	8d 70 01             	lea    0x1(%eax),%esi
  80097e:	0f b6 00             	movzbl (%eax),%eax
  800981:	0f be d8             	movsbl %al,%ebx
  800984:	85 db                	test   %ebx,%ebx
  800986:	74 10                	je     800998 <vprintfmt+0x245>
  800988:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098c:	78 b3                	js     800941 <vprintfmt+0x1ee>
  80098e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800992:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800996:	79 a9                	jns    800941 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800998:	eb 17                	jmp    8009b1 <vprintfmt+0x25e>
				putch(' ', putdat);
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ad:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b5:	7f e3                	jg     80099a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009b7:	e9 70 01 00 00       	jmp    800b2c <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 3e fd ff ff       	call   80070c <getint>
  8009ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	79 26                	jns    800a04 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e5:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	ff d0                	call   *%eax
				num = -(long long) num;
  8009f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009f7:	f7 d8                	neg    %eax
  8009f9:	83 d2 00             	adc    $0x0,%edx
  8009fc:	f7 da                	neg    %edx
  8009fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a01:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a04:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a0b:	e9 a8 00 00 00       	jmp    800ab8 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a17:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1a:	89 04 24             	mov    %eax,(%esp)
  800a1d:	e8 9b fc ff ff       	call   8006bd <getuint>
  800a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a25:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a28:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a2f:	e9 84 00 00 00       	jmp    800ab8 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a34:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 77 fc ff ff       	call   8006bd <getuint>
  800a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a49:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a4c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a53:	eb 63                	jmp    800ab8 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	ff d0                	call   *%eax
			putch('x', putdat);
  800a68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7e:	8d 50 04             	lea    0x4(%eax),%edx
  800a81:	89 55 14             	mov    %edx,0x14(%ebp)
  800a84:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a90:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a97:	eb 1f                	jmp    800ab8 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 12 fc ff ff       	call   8006bd <getuint>
  800aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aae:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800ab1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abf:	89 54 24 18          	mov    %edx,0x18(%esp)
  800ac3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ac6:	89 54 24 14          	mov    %edx,0x14(%esp)
  800aca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	89 04 24             	mov    %eax,(%esp)
  800ae9:	e8 f1 fa ff ff       	call   8005df <printnum>
			break;
  800aee:	eb 3c                	jmp    800b2c <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af7:	89 1c 24             	mov    %ebx,(%esp)
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	ff d0                	call   *%eax
			break;
  800aff:	eb 2b                	jmp    800b2c <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b08:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b14:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b18:	eb 04                	jmp    800b1e <vprintfmt+0x3cb>
  800b1a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b21:	83 e8 01             	sub    $0x1,%eax
  800b24:	0f b6 00             	movzbl (%eax),%eax
  800b27:	3c 25                	cmp    $0x25,%al
  800b29:	75 ef                	jne    800b1a <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b2b:	90                   	nop
		}
	}
  800b2c:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b2d:	e9 43 fc ff ff       	jmp    800775 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b32:	83 c4 40             	add    $0x40,%esp
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b3f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b48:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	89 04 24             	mov    %eax,(%esp)
  800b60:	e8 ee fb ff ff       	call   800753 <vprintfmt>
	va_end(ap);
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	8b 40 08             	mov    0x8(%eax),%eax
  800b70:	8d 50 01             	lea    0x1(%eax),%edx
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	8b 10                	mov    (%eax),%edx
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	8b 40 04             	mov    0x4(%eax),%eax
  800b84:	39 c2                	cmp    %eax,%edx
  800b86:	73 12                	jae    800b9a <sprintputch+0x33>
		*b->buf++ = ch;
  800b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8b:	8b 00                	mov    (%eax),%eax
  800b8d:	8d 48 01             	lea    0x1(%eax),%ecx
  800b90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b93:	89 0a                	mov    %ecx,(%edx)
  800b95:	8b 55 08             	mov    0x8(%ebp),%edx
  800b98:	88 10                	mov    %dl,(%eax)
}
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	01 d0                	add    %edx,%eax
  800bb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bbd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bc1:	74 06                	je     800bc9 <vsnprintf+0x2d>
  800bc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc7:	7f 07                	jg     800bd0 <vsnprintf+0x34>
		return -E_INVAL;
  800bc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bce:	eb 2a                	jmp    800bfa <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bde:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be5:	c7 04 24 67 0b 80 00 	movl   $0x800b67,(%esp)
  800bec:	e8 62 fb ff ff       	call   800753 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c02:	8d 45 14             	lea    0x14(%ebp),%eax
  800c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c12:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	89 04 24             	mov    %eax,(%esp)
  800c23:	e8 74 ff ff ff       	call   800b9c <vsnprintf>
  800c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c36:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c3d:	eb 08                	jmp    800c47 <strlen+0x17>
		n++;
  800c3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	0f b6 00             	movzbl (%eax),%eax
  800c4d:	84 c0                	test   %al,%al
  800c4f:	75 ee                	jne    800c3f <strlen+0xf>
		n++;
	return n;
  800c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c63:	eb 0c                	jmp    800c71 <strnlen+0x1b>
		n++;
  800c65:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6d:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c75:	74 0a                	je     800c81 <strnlen+0x2b>
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	0f b6 00             	movzbl (%eax),%eax
  800c7d:	84 c0                	test   %al,%al
  800c7f:	75 e4                	jne    800c65 <strnlen+0xf>
		n++;
	return n;
  800c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c92:	90                   	nop
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	8d 50 01             	lea    0x1(%eax),%edx
  800c99:	89 55 08             	mov    %edx,0x8(%ebp)
  800c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ca2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ca5:	0f b6 12             	movzbl (%edx),%edx
  800ca8:	88 10                	mov    %dl,(%eax)
  800caa:	0f b6 00             	movzbl (%eax),%eax
  800cad:	84 c0                	test   %al,%al
  800caf:	75 e2                	jne    800c93 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cb4:	c9                   	leave  
  800cb5:	c3                   	ret    

00800cb6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	89 04 24             	mov    %eax,(%esp)
  800cc2:	e8 69 ff ff ff       	call   800c30 <strlen>
  800cc7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cca:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	01 c2                	add    %eax,%edx
  800cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd9:	89 14 24             	mov    %edx,(%esp)
  800cdc:	e8 a5 ff ff ff       	call   800c86 <strcpy>
	return dst;
  800ce1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ce4:	c9                   	leave  
  800ce5:	c3                   	ret    

00800ce6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cf2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cf9:	eb 23                	jmp    800d1e <strncpy+0x38>
		*dst++ = *src;
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	8d 50 01             	lea    0x1(%eax),%edx
  800d01:	89 55 08             	mov    %edx,0x8(%ebp)
  800d04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d07:	0f b6 12             	movzbl (%edx),%edx
  800d0a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0f:	0f b6 00             	movzbl (%eax),%eax
  800d12:	84 c0                	test   %al,%al
  800d14:	74 04                	je     800d1a <strncpy+0x34>
			src++;
  800d16:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d1a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d21:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d24:	72 d5                	jb     800cfb <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d26:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d3b:	74 33                	je     800d70 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d3d:	eb 17                	jmp    800d56 <strlcpy+0x2b>
			*dst++ = *src++;
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	8d 50 01             	lea    0x1(%eax),%edx
  800d45:	89 55 08             	mov    %edx,0x8(%ebp)
  800d48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d4e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d51:	0f b6 12             	movzbl (%edx),%edx
  800d54:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d56:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5e:	74 0a                	je     800d6a <strlcpy+0x3f>
  800d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	84 c0                	test   %al,%al
  800d68:	75 d5                	jne    800d3f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d76:	29 c2                	sub    %eax,%edx
  800d78:	89 d0                	mov    %edx,%eax
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d7f:	eb 08                	jmp    800d89 <strcmp+0xd>
		p++, q++;
  800d81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d85:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	0f b6 00             	movzbl (%eax),%eax
  800d8f:	84 c0                	test   %al,%al
  800d91:	74 10                	je     800da3 <strcmp+0x27>
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	0f b6 10             	movzbl (%eax),%edx
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	0f b6 00             	movzbl (%eax),%eax
  800d9f:	38 c2                	cmp    %al,%dl
  800da1:	74 de                	je     800d81 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	0f b6 00             	movzbl (%eax),%eax
  800da9:	0f b6 d0             	movzbl %al,%edx
  800dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daf:	0f b6 00             	movzbl (%eax),%eax
  800db2:	0f b6 c0             	movzbl %al,%eax
  800db5:	29 c2                	sub    %eax,%edx
  800db7:	89 d0                	mov    %edx,%eax
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dbe:	eb 0c                	jmp    800dcc <strncmp+0x11>
		n--, p++, q++;
  800dc0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dc4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd0:	74 1a                	je     800dec <strncmp+0x31>
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	0f b6 00             	movzbl (%eax),%eax
  800dd8:	84 c0                	test   %al,%al
  800dda:	74 10                	je     800dec <strncmp+0x31>
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	0f b6 10             	movzbl (%eax),%edx
  800de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de5:	0f b6 00             	movzbl (%eax),%eax
  800de8:	38 c2                	cmp    %al,%dl
  800dea:	74 d4                	je     800dc0 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df0:	75 07                	jne    800df9 <strncmp+0x3e>
		return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
  800df7:	eb 16                	jmp    800e0f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	0f b6 d0             	movzbl %al,%edx
  800e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e05:	0f b6 00             	movzbl (%eax),%eax
  800e08:	0f b6 c0             	movzbl %al,%eax
  800e0b:	29 c2                	sub    %eax,%edx
  800e0d:	89 d0                	mov    %edx,%eax
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e1d:	eb 14                	jmp    800e33 <strchr+0x22>
		if (*s == c)
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	0f b6 00             	movzbl (%eax),%eax
  800e25:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e28:	75 05                	jne    800e2f <strchr+0x1e>
			return (char *) s;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	eb 13                	jmp    800e42 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e2f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	0f b6 00             	movzbl (%eax),%eax
  800e39:	84 c0                	test   %al,%al
  800e3b:	75 e2                	jne    800e1f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e50:	eb 11                	jmp    800e63 <strfind+0x1f>
		if (*s == c)
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	0f b6 00             	movzbl (%eax),%eax
  800e58:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e5b:	75 02                	jne    800e5f <strfind+0x1b>
			break;
  800e5d:	eb 0e                	jmp    800e6d <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e5f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	0f b6 00             	movzbl (%eax),%eax
  800e69:	84 c0                	test   %al,%al
  800e6b:	75 e5                	jne    800e52 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    

00800e72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e7a:	75 05                	jne    800e81 <memset+0xf>
		return v;
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7f:	eb 5c                	jmp    800edd <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	83 e0 03             	and    $0x3,%eax
  800e87:	85 c0                	test   %eax,%eax
  800e89:	75 41                	jne    800ecc <memset+0x5a>
  800e8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8e:	83 e0 03             	and    $0x3,%eax
  800e91:	85 c0                	test   %eax,%eax
  800e93:	75 37                	jne    800ecc <memset+0x5a>
		c &= 0xFF;
  800e95:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	c1 e0 18             	shl    $0x18,%eax
  800ea2:	89 c2                	mov    %eax,%edx
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	c1 e0 10             	shl    $0x10,%eax
  800eaa:	09 c2                	or     %eax,%edx
  800eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaf:	c1 e0 08             	shl    $0x8,%eax
  800eb2:	09 d0                	or     %edx,%eax
  800eb4:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eba:	c1 e8 02             	shr    $0x2,%eax
  800ebd:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	89 d7                	mov    %edx,%edi
  800ec7:	fc                   	cld    
  800ec8:	f3 ab                	rep stos %eax,%es:(%edi)
  800eca:	eb 0e                	jmp    800eda <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed5:	89 d7                	mov    %edx,%edi
  800ed7:	fc                   	cld    
  800ed8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800efb:	73 6d                	jae    800f6a <memmove+0x8a>
  800efd:	8b 45 10             	mov    0x10(%ebp),%eax
  800f00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f03:	01 d0                	add    %edx,%eax
  800f05:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f08:	76 60                	jbe    800f6a <memmove+0x8a>
		s += n;
  800f0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f10:	8b 45 10             	mov    0x10(%ebp),%eax
  800f13:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f19:	83 e0 03             	and    $0x3,%eax
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	75 2f                	jne    800f4f <memmove+0x6f>
  800f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f23:	83 e0 03             	and    $0x3,%eax
  800f26:	85 c0                	test   %eax,%eax
  800f28:	75 25                	jne    800f4f <memmove+0x6f>
  800f2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2d:	83 e0 03             	and    $0x3,%eax
  800f30:	85 c0                	test   %eax,%eax
  800f32:	75 1b                	jne    800f4f <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f37:	83 e8 04             	sub    $0x4,%eax
  800f3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3d:	83 ea 04             	sub    $0x4,%edx
  800f40:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f43:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f46:	89 c7                	mov    %eax,%edi
  800f48:	89 d6                	mov    %edx,%esi
  800f4a:	fd                   	std    
  800f4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4d:	eb 18                	jmp    800f67 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f52:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f58:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5e:	89 d7                	mov    %edx,%edi
  800f60:	89 de                	mov    %ebx,%esi
  800f62:	89 c1                	mov    %eax,%ecx
  800f64:	fd                   	std    
  800f65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f67:	fc                   	cld    
  800f68:	eb 45                	jmp    800faf <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6d:	83 e0 03             	and    $0x3,%eax
  800f70:	85 c0                	test   %eax,%eax
  800f72:	75 2b                	jne    800f9f <memmove+0xbf>
  800f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f77:	83 e0 03             	and    $0x3,%eax
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	75 21                	jne    800f9f <memmove+0xbf>
  800f7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f81:	83 e0 03             	and    $0x3,%eax
  800f84:	85 c0                	test   %eax,%eax
  800f86:	75 17                	jne    800f9f <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f88:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8b:	c1 e8 02             	shr    $0x2,%eax
  800f8e:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f93:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	fc                   	cld    
  800f9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9d:	eb 10                	jmp    800faf <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fa8:	89 c7                	mov    %eax,%edi
  800faa:	89 d6                	mov    %edx,%esi
  800fac:	fc                   	cld    
  800fad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	e8 07 ff ff ff       	call   800ee0 <memmove>
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fea:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fed:	eb 30                	jmp    80101f <memcmp+0x44>
		if (*s1 != *s2)
  800fef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff2:	0f b6 10             	movzbl (%eax),%edx
  800ff5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ff8:	0f b6 00             	movzbl (%eax),%eax
  800ffb:	38 c2                	cmp    %al,%dl
  800ffd:	74 18                	je     801017 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801002:	0f b6 00             	movzbl (%eax),%eax
  801005:	0f b6 d0             	movzbl %al,%edx
  801008:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80100b:	0f b6 00             	movzbl (%eax),%eax
  80100e:	0f b6 c0             	movzbl %al,%eax
  801011:	29 c2                	sub    %eax,%edx
  801013:	89 d0                	mov    %edx,%eax
  801015:	eb 1a                	jmp    801031 <memcmp+0x56>
		s1++, s2++;
  801017:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80101b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80101f:	8b 45 10             	mov    0x10(%ebp),%eax
  801022:	8d 50 ff             	lea    -0x1(%eax),%edx
  801025:	89 55 10             	mov    %edx,0x10(%ebp)
  801028:	85 c0                	test   %eax,%eax
  80102a:	75 c3                	jne    800fef <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80102c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801039:	8b 45 10             	mov    0x10(%ebp),%eax
  80103c:	8b 55 08             	mov    0x8(%ebp),%edx
  80103f:	01 d0                	add    %edx,%eax
  801041:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801044:	eb 13                	jmp    801059 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	0f b6 10             	movzbl (%eax),%edx
  80104c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104f:	38 c2                	cmp    %al,%dl
  801051:	75 02                	jne    801055 <memfind+0x22>
			break;
  801053:	eb 0c                	jmp    801061 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801055:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80105f:	72 e5                	jb     801046 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80106c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801073:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107a:	eb 04                	jmp    801080 <strtol+0x1a>
		s++;
  80107c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801080:	8b 45 08             	mov    0x8(%ebp),%eax
  801083:	0f b6 00             	movzbl (%eax),%eax
  801086:	3c 20                	cmp    $0x20,%al
  801088:	74 f2                	je     80107c <strtol+0x16>
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	0f b6 00             	movzbl (%eax),%eax
  801090:	3c 09                	cmp    $0x9,%al
  801092:	74 e8                	je     80107c <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	0f b6 00             	movzbl (%eax),%eax
  80109a:	3c 2b                	cmp    $0x2b,%al
  80109c:	75 06                	jne    8010a4 <strtol+0x3e>
		s++;
  80109e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010a2:	eb 15                	jmp    8010b9 <strtol+0x53>
	else if (*s == '-')
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	0f b6 00             	movzbl (%eax),%eax
  8010aa:	3c 2d                	cmp    $0x2d,%al
  8010ac:	75 0b                	jne    8010b9 <strtol+0x53>
		s++, neg = 1;
  8010ae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010b2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010bd:	74 06                	je     8010c5 <strtol+0x5f>
  8010bf:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010c3:	75 24                	jne    8010e9 <strtol+0x83>
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	0f b6 00             	movzbl (%eax),%eax
  8010cb:	3c 30                	cmp    $0x30,%al
  8010cd:	75 1a                	jne    8010e9 <strtol+0x83>
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	83 c0 01             	add    $0x1,%eax
  8010d5:	0f b6 00             	movzbl (%eax),%eax
  8010d8:	3c 78                	cmp    $0x78,%al
  8010da:	75 0d                	jne    8010e9 <strtol+0x83>
		s += 2, base = 16;
  8010dc:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010e0:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010e7:	eb 2a                	jmp    801113 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ed:	75 17                	jne    801106 <strtol+0xa0>
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	0f b6 00             	movzbl (%eax),%eax
  8010f5:	3c 30                	cmp    $0x30,%al
  8010f7:	75 0d                	jne    801106 <strtol+0xa0>
		s++, base = 8;
  8010f9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010fd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801104:	eb 0d                	jmp    801113 <strtol+0xad>
	else if (base == 0)
  801106:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80110a:	75 07                	jne    801113 <strtol+0xad>
		base = 10;
  80110c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	0f b6 00             	movzbl (%eax),%eax
  801119:	3c 2f                	cmp    $0x2f,%al
  80111b:	7e 1b                	jle    801138 <strtol+0xd2>
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
  801120:	0f b6 00             	movzbl (%eax),%eax
  801123:	3c 39                	cmp    $0x39,%al
  801125:	7f 11                	jg     801138 <strtol+0xd2>
			dig = *s - '0';
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	0f b6 00             	movzbl (%eax),%eax
  80112d:	0f be c0             	movsbl %al,%eax
  801130:	83 e8 30             	sub    $0x30,%eax
  801133:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801136:	eb 48                	jmp    801180 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	0f b6 00             	movzbl (%eax),%eax
  80113e:	3c 60                	cmp    $0x60,%al
  801140:	7e 1b                	jle    80115d <strtol+0xf7>
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	0f b6 00             	movzbl (%eax),%eax
  801148:	3c 7a                	cmp    $0x7a,%al
  80114a:	7f 11                	jg     80115d <strtol+0xf7>
			dig = *s - 'a' + 10;
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	0f b6 00             	movzbl (%eax),%eax
  801152:	0f be c0             	movsbl %al,%eax
  801155:	83 e8 57             	sub    $0x57,%eax
  801158:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80115b:	eb 23                	jmp    801180 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	0f b6 00             	movzbl (%eax),%eax
  801163:	3c 40                	cmp    $0x40,%al
  801165:	7e 3d                	jle    8011a4 <strtol+0x13e>
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	0f b6 00             	movzbl (%eax),%eax
  80116d:	3c 5a                	cmp    $0x5a,%al
  80116f:	7f 33                	jg     8011a4 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
  801174:	0f b6 00             	movzbl (%eax),%eax
  801177:	0f be c0             	movsbl %al,%eax
  80117a:	83 e8 37             	sub    $0x37,%eax
  80117d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801180:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801183:	3b 45 10             	cmp    0x10(%ebp),%eax
  801186:	7c 02                	jl     80118a <strtol+0x124>
			break;
  801188:	eb 1a                	jmp    8011a4 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80118a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80118e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801191:	0f af 45 10          	imul   0x10(%ebp),%eax
  801195:	89 c2                	mov    %eax,%edx
  801197:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119a:	01 d0                	add    %edx,%eax
  80119c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80119f:	e9 6f ff ff ff       	jmp    801113 <strtol+0xad>

	if (endptr)
  8011a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011a8:	74 08                	je     8011b2 <strtol+0x14c>
		*endptr = (char *) s;
  8011aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011b2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011b6:	74 07                	je     8011bf <strtol+0x159>
  8011b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011bb:	f7 d8                	neg    %eax
  8011bd:	eb 03                	jmp    8011c2 <strtol+0x15c>
  8011bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    
  8011c4:	66 90                	xchg   %ax,%ax
  8011c6:	66 90                	xchg   %ax,%ax
  8011c8:	66 90                	xchg   %ax,%ax
  8011ca:	66 90                	xchg   %ax,%ax
  8011cc:	66 90                	xchg   %ax,%ax
  8011ce:	66 90                	xchg   %ax,%ax

008011d0 <__udivdi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ec:	89 ea                	mov    %ebp,%edx
  8011ee:	89 0c 24             	mov    %ecx,(%esp)
  8011f1:	75 2d                	jne    801220 <__udivdi3+0x50>
  8011f3:	39 e9                	cmp    %ebp,%ecx
  8011f5:	77 61                	ja     801258 <__udivdi3+0x88>
  8011f7:	85 c9                	test   %ecx,%ecx
  8011f9:	89 ce                	mov    %ecx,%esi
  8011fb:	75 0b                	jne    801208 <__udivdi3+0x38>
  8011fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801202:	31 d2                	xor    %edx,%edx
  801204:	f7 f1                	div    %ecx
  801206:	89 c6                	mov    %eax,%esi
  801208:	31 d2                	xor    %edx,%edx
  80120a:	89 e8                	mov    %ebp,%eax
  80120c:	f7 f6                	div    %esi
  80120e:	89 c5                	mov    %eax,%ebp
  801210:	89 f8                	mov    %edi,%eax
  801212:	f7 f6                	div    %esi
  801214:	89 ea                	mov    %ebp,%edx
  801216:	83 c4 0c             	add    $0xc,%esp
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    
  80121d:	8d 76 00             	lea    0x0(%esi),%esi
  801220:	39 e8                	cmp    %ebp,%eax
  801222:	77 24                	ja     801248 <__udivdi3+0x78>
  801224:	0f bd e8             	bsr    %eax,%ebp
  801227:	83 f5 1f             	xor    $0x1f,%ebp
  80122a:	75 3c                	jne    801268 <__udivdi3+0x98>
  80122c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801230:	39 34 24             	cmp    %esi,(%esp)
  801233:	0f 86 9f 00 00 00    	jbe    8012d8 <__udivdi3+0x108>
  801239:	39 d0                	cmp    %edx,%eax
  80123b:	0f 82 97 00 00 00    	jb     8012d8 <__udivdi3+0x108>
  801241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801248:	31 d2                	xor    %edx,%edx
  80124a:	31 c0                	xor    %eax,%eax
  80124c:	83 c4 0c             	add    $0xc,%esp
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    
  801253:	90                   	nop
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	89 f8                	mov    %edi,%eax
  80125a:	f7 f1                	div    %ecx
  80125c:	31 d2                	xor    %edx,%edx
  80125e:	83 c4 0c             	add    $0xc,%esp
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    
  801265:	8d 76 00             	lea    0x0(%esi),%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	8b 3c 24             	mov    (%esp),%edi
  80126d:	d3 e0                	shl    %cl,%eax
  80126f:	89 c6                	mov    %eax,%esi
  801271:	b8 20 00 00 00       	mov    $0x20,%eax
  801276:	29 e8                	sub    %ebp,%eax
  801278:	89 c1                	mov    %eax,%ecx
  80127a:	d3 ef                	shr    %cl,%edi
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801282:	8b 3c 24             	mov    (%esp),%edi
  801285:	09 74 24 08          	or     %esi,0x8(%esp)
  801289:	89 d6                	mov    %edx,%esi
  80128b:	d3 e7                	shl    %cl,%edi
  80128d:	89 c1                	mov    %eax,%ecx
  80128f:	89 3c 24             	mov    %edi,(%esp)
  801292:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801296:	d3 ee                	shr    %cl,%esi
  801298:	89 e9                	mov    %ebp,%ecx
  80129a:	d3 e2                	shl    %cl,%edx
  80129c:	89 c1                	mov    %eax,%ecx
  80129e:	d3 ef                	shr    %cl,%edi
  8012a0:	09 d7                	or     %edx,%edi
  8012a2:	89 f2                	mov    %esi,%edx
  8012a4:	89 f8                	mov    %edi,%eax
  8012a6:	f7 74 24 08          	divl   0x8(%esp)
  8012aa:	89 d6                	mov    %edx,%esi
  8012ac:	89 c7                	mov    %eax,%edi
  8012ae:	f7 24 24             	mull   (%esp)
  8012b1:	39 d6                	cmp    %edx,%esi
  8012b3:	89 14 24             	mov    %edx,(%esp)
  8012b6:	72 30                	jb     8012e8 <__udivdi3+0x118>
  8012b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	d3 e2                	shl    %cl,%edx
  8012c0:	39 c2                	cmp    %eax,%edx
  8012c2:	73 05                	jae    8012c9 <__udivdi3+0xf9>
  8012c4:	3b 34 24             	cmp    (%esp),%esi
  8012c7:	74 1f                	je     8012e8 <__udivdi3+0x118>
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	e9 7a ff ff ff       	jmp    80124c <__udivdi3+0x7c>
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	31 d2                	xor    %edx,%edx
  8012da:	b8 01 00 00 00       	mov    $0x1,%eax
  8012df:	e9 68 ff ff ff       	jmp    80124c <__udivdi3+0x7c>
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	83 c4 0c             	add    $0xc,%esp
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    
  8012f4:	66 90                	xchg   %ax,%ax
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__umoddi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 44 24 28          	mov    0x28(%esp),%eax
  80130a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80130e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801312:	89 c7                	mov    %eax,%edi
  801314:	89 44 24 04          	mov    %eax,0x4(%esp)
  801318:	8b 44 24 30          	mov    0x30(%esp),%eax
  80131c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801320:	89 34 24             	mov    %esi,(%esp)
  801323:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801327:	85 c0                	test   %eax,%eax
  801329:	89 c2                	mov    %eax,%edx
  80132b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80132f:	75 17                	jne    801348 <__umoddi3+0x48>
  801331:	39 fe                	cmp    %edi,%esi
  801333:	76 4b                	jbe    801380 <__umoddi3+0x80>
  801335:	89 c8                	mov    %ecx,%eax
  801337:	89 fa                	mov    %edi,%edx
  801339:	f7 f6                	div    %esi
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	31 d2                	xor    %edx,%edx
  80133f:	83 c4 14             	add    $0x14,%esp
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    
  801346:	66 90                	xchg   %ax,%ax
  801348:	39 f8                	cmp    %edi,%eax
  80134a:	77 54                	ja     8013a0 <__umoddi3+0xa0>
  80134c:	0f bd e8             	bsr    %eax,%ebp
  80134f:	83 f5 1f             	xor    $0x1f,%ebp
  801352:	75 5c                	jne    8013b0 <__umoddi3+0xb0>
  801354:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801358:	39 3c 24             	cmp    %edi,(%esp)
  80135b:	0f 87 e7 00 00 00    	ja     801448 <__umoddi3+0x148>
  801361:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801365:	29 f1                	sub    %esi,%ecx
  801367:	19 c7                	sbb    %eax,%edi
  801369:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801371:	8b 44 24 08          	mov    0x8(%esp),%eax
  801375:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801379:	83 c4 14             	add    $0x14,%esp
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    
  801380:	85 f6                	test   %esi,%esi
  801382:	89 f5                	mov    %esi,%ebp
  801384:	75 0b                	jne    801391 <__umoddi3+0x91>
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	f7 f6                	div    %esi
  80138f:	89 c5                	mov    %eax,%ebp
  801391:	8b 44 24 04          	mov    0x4(%esp),%eax
  801395:	31 d2                	xor    %edx,%edx
  801397:	f7 f5                	div    %ebp
  801399:	89 c8                	mov    %ecx,%eax
  80139b:	f7 f5                	div    %ebp
  80139d:	eb 9c                	jmp    80133b <__umoddi3+0x3b>
  80139f:	90                   	nop
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 fa                	mov    %edi,%edx
  8013a4:	83 c4 14             	add    $0x14,%esp
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
  8013ab:	90                   	nop
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	8b 04 24             	mov    (%esp),%eax
  8013b3:	be 20 00 00 00       	mov    $0x20,%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	29 ee                	sub    %ebp,%esi
  8013bc:	d3 e2                	shl    %cl,%edx
  8013be:	89 f1                	mov    %esi,%ecx
  8013c0:	d3 e8                	shr    %cl,%eax
  8013c2:	89 e9                	mov    %ebp,%ecx
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 04 24             	mov    (%esp),%eax
  8013cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	d3 e0                	shl    %cl,%eax
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013dd:	d3 ea                	shr    %cl,%edx
  8013df:	89 e9                	mov    %ebp,%ecx
  8013e1:	d3 e7                	shl    %cl,%edi
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	d3 e8                	shr    %cl,%eax
  8013e7:	89 e9                	mov    %ebp,%ecx
  8013e9:	09 f8                	or     %edi,%eax
  8013eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013ef:	f7 74 24 04          	divl   0x4(%esp)
  8013f3:	d3 e7                	shl    %cl,%edi
  8013f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013f9:	89 d7                	mov    %edx,%edi
  8013fb:	f7 64 24 08          	mull   0x8(%esp)
  8013ff:	39 d7                	cmp    %edx,%edi
  801401:	89 c1                	mov    %eax,%ecx
  801403:	89 14 24             	mov    %edx,(%esp)
  801406:	72 2c                	jb     801434 <__umoddi3+0x134>
  801408:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80140c:	72 22                	jb     801430 <__umoddi3+0x130>
  80140e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801412:	29 c8                	sub    %ecx,%eax
  801414:	19 d7                	sbb    %edx,%edi
  801416:	89 e9                	mov    %ebp,%ecx
  801418:	89 fa                	mov    %edi,%edx
  80141a:	d3 e8                	shr    %cl,%eax
  80141c:	89 f1                	mov    %esi,%ecx
  80141e:	d3 e2                	shl    %cl,%edx
  801420:	89 e9                	mov    %ebp,%ecx
  801422:	d3 ef                	shr    %cl,%edi
  801424:	09 d0                	or     %edx,%eax
  801426:	89 fa                	mov    %edi,%edx
  801428:	83 c4 14             	add    $0x14,%esp
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    
  80142f:	90                   	nop
  801430:	39 d7                	cmp    %edx,%edi
  801432:	75 da                	jne    80140e <__umoddi3+0x10e>
  801434:	8b 14 24             	mov    (%esp),%edx
  801437:	89 c1                	mov    %eax,%ecx
  801439:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80143d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801441:	eb cb                	jmp    80140e <__umoddi3+0x10e>
  801443:	90                   	nop
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80144c:	0f 82 0f ff ff ff    	jb     801361 <__umoddi3+0x61>
  801452:	e9 1a ff ff ff       	jmp    801371 <__umoddi3+0x71>
