
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
  800113:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  80012a:	e8 2c 03 00 00       	call   80045b <_panic>

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

0080045b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	53                   	push   %ebx
  80045f:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800462:	8d 45 14             	lea    0x14(%ebp),%eax
  800465:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800468:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80046e:	e8 90 fd ff ff       	call   800203 <sys_getenvid>
  800473:	8b 55 0c             	mov    0xc(%ebp),%edx
  800476:	89 54 24 10          	mov    %edx,0x10(%esp)
  80047a:	8b 55 08             	mov    0x8(%ebp),%edx
  80047d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800481:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800485:	89 44 24 04          	mov    %eax,0x4(%esp)
  800489:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  800490:	e8 e1 00 00 00       	call   800576 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049c:	8b 45 10             	mov    0x10(%ebp),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	e8 6b 00 00 00       	call   800512 <vcprintf>
	cprintf("\n");
  8004a7:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  8004ae:	e8 c3 00 00 00       	call   800576 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b3:	cc                   	int3   
  8004b4:	eb fd                	jmp    8004b3 <_panic+0x58>

008004b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	8d 48 01             	lea    0x1(%eax),%ecx
  8004c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c7:	89 0a                	mov    %ecx,(%edx)
  8004c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cc:	89 d1                	mov    %edx,%ecx
  8004ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d1:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004df:	75 20                	jne    800501 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e9:	83 c2 08             	add    $0x8,%edx
  8004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f0:	89 14 24             	mov    %edx,(%esp)
  8004f3:	e8 42 fc ff ff       	call   80013a <sys_cputs>
		b->idx = 0;
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
  800504:	8b 40 04             	mov    0x4(%eax),%eax
  800507:	8d 50 01             	lea    0x1(%eax),%edx
  80050a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80051b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800522:	00 00 00 
	b.cnt = 0;
  800525:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80052c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80052f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800532:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800536:	8b 45 08             	mov    0x8(%ebp),%eax
  800539:	89 44 24 08          	mov    %eax,0x8(%esp)
  80053d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800543:	89 44 24 04          	mov    %eax,0x4(%esp)
  800547:	c7 04 24 b6 04 80 00 	movl   $0x8004b6,(%esp)
  80054e:	e8 bd 01 00 00       	call   800710 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800553:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800563:	83 c0 08             	add    $0x8,%eax
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	e8 cc fb ff ff       	call   80013a <sys_cputs>

	return b.cnt;
  80056e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800574:	c9                   	leave  
  800575:	c3                   	ret    

00800576 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80057c:	8d 45 0c             	lea    0xc(%ebp),%eax
  80057f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800585:	89 44 24 04          	mov    %eax,0x4(%esp)
  800589:	8b 45 08             	mov    0x8(%ebp),%eax
  80058c:	89 04 24             	mov    %eax,(%esp)
  80058f:	e8 7e ff ff ff       	call   800512 <vcprintf>
  800594:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800597:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80059a:	c9                   	leave  
  80059b:	c3                   	ret    

0080059c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	53                   	push   %ebx
  8005a0:	83 ec 34             	sub    $0x34,%esp
  8005a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005af:	8b 45 18             	mov    0x18(%ebp),%eax
  8005b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005ba:	77 72                	ja     80062e <printnum+0x92>
  8005bc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005bf:	72 05                	jb     8005c6 <printnum+0x2a>
  8005c1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005c4:	77 68                	ja     80062e <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005c6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005c9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005cc:	8b 45 18             	mov    0x18(%ebp),%eax
  8005cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e2:	89 04 24             	mov    %eax,(%esp)
  8005e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005e9:	e8 a2 0b 00 00       	call   801190 <__udivdi3>
  8005ee:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005f1:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005f5:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005f9:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800600:	89 44 24 08          	mov    %eax,0x8(%esp)
  800604:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	8b 45 08             	mov    0x8(%ebp),%eax
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	e8 82 ff ff ff       	call   80059c <printnum>
  80061a:	eb 1c                	jmp    800638 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80061c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800623:	8b 45 20             	mov    0x20(%ebp),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	8b 45 08             	mov    0x8(%ebp),%eax
  80062c:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80062e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800632:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800636:	7f e4                	jg     80061c <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800638:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80063b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800640:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800643:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800646:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80064a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	89 54 24 04          	mov    %edx,0x4(%esp)
  800655:	e8 66 0c 00 00       	call   8012c0 <__umoddi3>
  80065a:	05 48 15 80 00       	add    $0x801548,%eax
  80065f:	0f b6 00             	movzbl (%eax),%eax
  800662:	0f be c0             	movsbl %al,%eax
  800665:	8b 55 0c             	mov    0xc(%ebp),%edx
  800668:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066c:	89 04 24             	mov    %eax,(%esp)
  80066f:	8b 45 08             	mov    0x8(%ebp),%eax
  800672:	ff d0                	call   *%eax
}
  800674:	83 c4 34             	add    $0x34,%esp
  800677:	5b                   	pop    %ebx
  800678:	5d                   	pop    %ebp
  800679:	c3                   	ret    

0080067a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80067d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800681:	7e 14                	jle    800697 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	8b 00                	mov    (%eax),%eax
  800688:	8d 48 08             	lea    0x8(%eax),%ecx
  80068b:	8b 55 08             	mov    0x8(%ebp),%edx
  80068e:	89 0a                	mov    %ecx,(%edx)
  800690:	8b 50 04             	mov    0x4(%eax),%edx
  800693:	8b 00                	mov    (%eax),%eax
  800695:	eb 30                	jmp    8006c7 <getuint+0x4d>
	else if (lflag)
  800697:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80069b:	74 16                	je     8006b3 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80069d:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	8d 48 04             	lea    0x4(%eax),%ecx
  8006a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a8:	89 0a                	mov    %ecx,(%edx)
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b1:	eb 14                	jmp    8006c7 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8006bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006be:	89 0a                	mov    %ecx,(%edx)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006cc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d0:	7e 14                	jle    8006e6 <getint+0x1d>
		return va_arg(*ap, long long);
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	8d 48 08             	lea    0x8(%eax),%ecx
  8006da:	8b 55 08             	mov    0x8(%ebp),%edx
  8006dd:	89 0a                	mov    %ecx,(%edx)
  8006df:	8b 50 04             	mov    0x4(%eax),%edx
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	eb 28                	jmp    80070e <getint+0x45>
	else if (lflag)
  8006e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006ea:	74 12                	je     8006fe <getint+0x35>
		return va_arg(*ap, long);
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f7:	89 0a                	mov    %ecx,(%edx)
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	99                   	cltd   
  8006fc:	eb 10                	jmp    80070e <getint+0x45>
	else
		return va_arg(*ap, int);
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 00                	mov    (%eax),%eax
  800703:	8d 48 04             	lea    0x4(%eax),%ecx
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
  800709:	89 0a                	mov    %ecx,(%edx)
  80070b:	8b 00                	mov    (%eax),%eax
  80070d:	99                   	cltd   
}
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	56                   	push   %esi
  800714:	53                   	push   %ebx
  800715:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800718:	eb 18                	jmp    800732 <vprintfmt+0x22>
			if (ch == '\0')
  80071a:	85 db                	test   %ebx,%ebx
  80071c:	75 05                	jne    800723 <vprintfmt+0x13>
				return;
  80071e:	e9 cc 03 00 00       	jmp    800aef <vprintfmt+0x3df>
			putch(ch, putdat);
  800723:	8b 45 0c             	mov    0xc(%ebp),%eax
  800726:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072a:	89 1c 24             	mov    %ebx,(%esp)
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800732:	8b 45 10             	mov    0x10(%ebp),%eax
  800735:	8d 50 01             	lea    0x1(%eax),%edx
  800738:	89 55 10             	mov    %edx,0x10(%ebp)
  80073b:	0f b6 00             	movzbl (%eax),%eax
  80073e:	0f b6 d8             	movzbl %al,%ebx
  800741:	83 fb 25             	cmp    $0x25,%ebx
  800744:	75 d4                	jne    80071a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800746:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80074a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800751:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800758:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80075f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	8d 50 01             	lea    0x1(%eax),%edx
  80076c:	89 55 10             	mov    %edx,0x10(%ebp)
  80076f:	0f b6 00             	movzbl (%eax),%eax
  800772:	0f b6 d8             	movzbl %al,%ebx
  800775:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800778:	83 f8 55             	cmp    $0x55,%eax
  80077b:	0f 87 3d 03 00 00    	ja     800abe <vprintfmt+0x3ae>
  800781:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800788:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80078a:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80078e:	eb d6                	jmp    800766 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800790:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800794:	eb d0                	jmp    800766 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800796:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80079d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	c1 e0 02             	shl    $0x2,%eax
  8007a5:	01 d0                	add    %edx,%eax
  8007a7:	01 c0                	add    %eax,%eax
  8007a9:	01 d8                	add    %ebx,%eax
  8007ab:	83 e8 30             	sub    $0x30,%eax
  8007ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b4:	0f b6 00             	movzbl (%eax),%eax
  8007b7:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007ba:	83 fb 2f             	cmp    $0x2f,%ebx
  8007bd:	7e 0b                	jle    8007ca <vprintfmt+0xba>
  8007bf:	83 fb 39             	cmp    $0x39,%ebx
  8007c2:	7f 06                	jg     8007ca <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007c4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007c8:	eb d3                	jmp    80079d <vprintfmt+0x8d>
			goto process_precision;
  8007ca:	eb 33                	jmp    8007ff <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 50 04             	lea    0x4(%eax),%edx
  8007d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007da:	eb 23                	jmp    8007ff <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e0:	79 0c                	jns    8007ee <vprintfmt+0xde>
				width = 0;
  8007e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007e9:	e9 78 ff ff ff       	jmp    800766 <vprintfmt+0x56>
  8007ee:	e9 73 ff ff ff       	jmp    800766 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007f3:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007fa:	e9 67 ff ff ff       	jmp    800766 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800803:	79 12                	jns    800817 <vprintfmt+0x107>
				width = precision, precision = -1;
  800805:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800808:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800812:	e9 4f ff ff ff       	jmp    800766 <vprintfmt+0x56>
  800817:	e9 4a ff ff ff       	jmp    800766 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80081c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800820:	e9 41 ff ff ff       	jmp    800766 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8d 50 04             	lea    0x4(%eax),%edx
  80082b:	89 55 14             	mov    %edx,0x14(%ebp)
  80082e:	8b 00                	mov    (%eax),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 54 24 04          	mov    %edx,0x4(%esp)
  800837:	89 04 24             	mov    %eax,(%esp)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	ff d0                	call   *%eax
			break;
  80083f:	e9 a5 02 00 00       	jmp    800ae9 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 04             	lea    0x4(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)
  80084d:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80084f:	85 db                	test   %ebx,%ebx
  800851:	79 02                	jns    800855 <vprintfmt+0x145>
				err = -err;
  800853:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800855:	83 fb 09             	cmp    $0x9,%ebx
  800858:	7f 0b                	jg     800865 <vprintfmt+0x155>
  80085a:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800861:	85 f6                	test   %esi,%esi
  800863:	75 23                	jne    800888 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800865:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800869:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  800870:	00 
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
  800874:	89 44 24 04          	mov    %eax,0x4(%esp)
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 73 02 00 00       	call   800af6 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800883:	e9 61 02 00 00       	jmp    800ae9 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800888:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80088c:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  800893:	00 
  800894:	8b 45 0c             	mov    0xc(%ebp),%eax
  800897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	89 04 24             	mov    %eax,(%esp)
  8008a1:	e8 50 02 00 00       	call   800af6 <printfmt>
			break;
  8008a6:	e9 3e 02 00 00       	jmp    800ae9 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8d 50 04             	lea    0x4(%eax),%edx
  8008b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b4:	8b 30                	mov    (%eax),%esi
  8008b6:	85 f6                	test   %esi,%esi
  8008b8:	75 05                	jne    8008bf <vprintfmt+0x1af>
				p = "(null)";
  8008ba:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8008bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c3:	7e 37                	jle    8008fc <vprintfmt+0x1ec>
  8008c5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008c9:	74 31                	je     8008fc <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d2:	89 34 24             	mov    %esi,(%esp)
  8008d5:	e8 39 03 00 00       	call   800c13 <strnlen>
  8008da:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008dd:	eb 17                	jmp    8008f6 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008df:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ea:	89 04 24             	mov    %eax,(%esp)
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fa:	7f e3                	jg     8008df <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fc:	eb 38                	jmp    800936 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800902:	74 1f                	je     800923 <vprintfmt+0x213>
  800904:	83 fb 1f             	cmp    $0x1f,%ebx
  800907:	7e 05                	jle    80090e <vprintfmt+0x1fe>
  800909:	83 fb 7e             	cmp    $0x7e,%ebx
  80090c:	7e 15                	jle    800923 <vprintfmt+0x213>
					putch('?', putdat);
  80090e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	ff d0                	call   *%eax
  800921:	eb 0f                	jmp    800932 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	89 1c 24             	mov    %ebx,(%esp)
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800932:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800936:	89 f0                	mov    %esi,%eax
  800938:	8d 70 01             	lea    0x1(%eax),%esi
  80093b:	0f b6 00             	movzbl (%eax),%eax
  80093e:	0f be d8             	movsbl %al,%ebx
  800941:	85 db                	test   %ebx,%ebx
  800943:	74 10                	je     800955 <vprintfmt+0x245>
  800945:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800949:	78 b3                	js     8008fe <vprintfmt+0x1ee>
  80094b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80094f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800953:	79 a9                	jns    8008fe <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800955:	eb 17                	jmp    80096e <vprintfmt+0x25e>
				putch(' ', putdat);
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80096a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80096e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800972:	7f e3                	jg     800957 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800974:	e9 70 01 00 00       	jmp    800ae9 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800979:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80097c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800980:	8d 45 14             	lea    0x14(%ebp),%eax
  800983:	89 04 24             	mov    %eax,(%esp)
  800986:	e8 3e fd ff ff       	call   8006c9 <getint>
  80098b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800991:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800994:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800997:	85 d2                	test   %edx,%edx
  800999:	79 26                	jns    8009c1 <vprintfmt+0x2b1>
				putch('-', putdat);
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	ff d0                	call   *%eax
				num = -(long long) num;
  8009ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009b4:	f7 d8                	neg    %eax
  8009b6:	83 d2 00             	adc    $0x0,%edx
  8009b9:	f7 da                	neg    %edx
  8009bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009be:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009c1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c8:	e9 a8 00 00 00       	jmp    800a75 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 9b fc ff ff       	call   80067a <getuint>
  8009df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009e5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009ec:	e9 84 00 00 00       	jmp    800a75 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fb:	89 04 24             	mov    %eax,(%esp)
  8009fe:	e8 77 fc ff ff       	call   80067a <getuint>
  800a03:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a06:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a09:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a10:	eb 63                	jmp    800a75 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	ff d0                	call   *%eax
			putch('x', putdat);
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a38:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3b:	8d 50 04             	lea    0x4(%eax),%edx
  800a3e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a41:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a54:	eb 1f                	jmp    800a75 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a56:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a60:	89 04 24             	mov    %eax,(%esp)
  800a63:	e8 12 fc ff ff       	call   80067a <getuint>
  800a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a6b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a6e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a75:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7c:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a83:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a95:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 f1 fa ff ff       	call   80059c <printnum>
			break;
  800aab:	eb 3c                	jmp    800ae9 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	89 1c 24             	mov    %ebx,(%esp)
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	ff d0                	call   *%eax
			break;
  800abc:	eb 2b                	jmp    800ae9 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ad5:	eb 04                	jmp    800adb <vprintfmt+0x3cb>
  800ad7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800adb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ade:	83 e8 01             	sub    $0x1,%eax
  800ae1:	0f b6 00             	movzbl (%eax),%eax
  800ae4:	3c 25                	cmp    $0x25,%al
  800ae6:	75 ef                	jne    800ad7 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800ae8:	90                   	nop
		}
	}
  800ae9:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aea:	e9 43 fc ff ff       	jmp    800732 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aef:	83 c4 40             	add    $0x40,%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800afc:	8d 45 14             	lea    0x14(%ebp),%eax
  800aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b09:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	89 04 24             	mov    %eax,(%esp)
  800b1d:	e8 ee fb ff ff       	call   800710 <vprintfmt>
	va_end(ap);
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	8b 40 08             	mov    0x8(%eax),%eax
  800b2d:	8d 50 01             	lea    0x1(%eax),%edx
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	8b 10                	mov    (%eax),%edx
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	8b 40 04             	mov    0x4(%eax),%eax
  800b41:	39 c2                	cmp    %eax,%edx
  800b43:	73 12                	jae    800b57 <sprintputch+0x33>
		*b->buf++ = ch;
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	8b 00                	mov    (%eax),%eax
  800b4a:	8d 48 01             	lea    0x1(%eax),%ecx
  800b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b50:	89 0a                	mov    %ecx,(%edx)
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	88 10                	mov    %dl,(%eax)
}
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b68:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	01 d0                	add    %edx,%eax
  800b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b7a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b7e:	74 06                	je     800b86 <vsnprintf+0x2d>
  800b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b84:	7f 07                	jg     800b8d <vsnprintf+0x34>
		return -E_INVAL;
  800b86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b8b:	eb 2a                	jmp    800bb7 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b94:	8b 45 10             	mov    0x10(%ebp),%eax
  800b97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba2:	c7 04 24 24 0b 80 00 	movl   $0x800b24,(%esp)
  800ba9:	e8 62 fb ff ff       	call   800710 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bbf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	89 04 24             	mov    %eax,(%esp)
  800be0:	e8 74 ff ff ff       	call   800b59 <vsnprintf>
  800be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bf3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bfa:	eb 08                	jmp    800c04 <strlen+0x17>
		n++;
  800bfc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c00:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	0f b6 00             	movzbl (%eax),%eax
  800c0a:	84 c0                	test   %al,%al
  800c0c:	75 ee                	jne    800bfc <strlen+0xf>
		n++;
	return n;
  800c0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c20:	eb 0c                	jmp    800c2e <strnlen+0x1b>
		n++;
  800c22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c26:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c2a:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c32:	74 0a                	je     800c3e <strnlen+0x2b>
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	0f b6 00             	movzbl (%eax),%eax
  800c3a:	84 c0                	test   %al,%al
  800c3c:	75 e4                	jne    800c22 <strnlen+0xf>
		n++;
	return n;
  800c3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c4f:	90                   	nop
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	8d 50 01             	lea    0x1(%eax),%edx
  800c56:	89 55 08             	mov    %edx,0x8(%ebp)
  800c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c5f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c62:	0f b6 12             	movzbl (%edx),%edx
  800c65:	88 10                	mov    %dl,(%eax)
  800c67:	0f b6 00             	movzbl (%eax),%eax
  800c6a:	84 c0                	test   %al,%al
  800c6c:	75 e2                	jne    800c50 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	89 04 24             	mov    %eax,(%esp)
  800c7f:	e8 69 ff ff ff       	call   800bed <strlen>
  800c84:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c87:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	01 c2                	add    %eax,%edx
  800c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c96:	89 14 24             	mov    %edx,(%esp)
  800c99:	e8 a5 ff ff ff       	call   800c43 <strcpy>
	return dst;
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800caf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cb6:	eb 23                	jmp    800cdb <strncpy+0x38>
		*dst++ = *src;
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8d 50 01             	lea    0x1(%eax),%edx
  800cbe:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc4:	0f b6 12             	movzbl (%edx),%edx
  800cc7:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	0f b6 00             	movzbl (%eax),%eax
  800ccf:	84 c0                	test   %al,%al
  800cd1:	74 04                	je     800cd7 <strncpy+0x34>
			src++;
  800cd3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cde:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ce1:	72 d5                	jb     800cb8 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ce3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    

00800ce8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf8:	74 33                	je     800d2d <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cfa:	eb 17                	jmp    800d13 <strlcpy+0x2b>
			*dst++ = *src++;
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	8d 50 01             	lea    0x1(%eax),%edx
  800d02:	89 55 08             	mov    %edx,0x8(%ebp)
  800d05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d08:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d0b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d0e:	0f b6 12             	movzbl (%edx),%edx
  800d11:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d13:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1b:	74 0a                	je     800d27 <strlcpy+0x3f>
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	0f b6 00             	movzbl (%eax),%eax
  800d23:	84 c0                	test   %al,%al
  800d25:	75 d5                	jne    800cfc <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d33:	29 c2                	sub    %eax,%edx
  800d35:	89 d0                	mov    %edx,%eax
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d3c:	eb 08                	jmp    800d46 <strcmp+0xd>
		p++, q++;
  800d3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d42:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	0f b6 00             	movzbl (%eax),%eax
  800d4c:	84 c0                	test   %al,%al
  800d4e:	74 10                	je     800d60 <strcmp+0x27>
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	0f b6 10             	movzbl (%eax),%edx
  800d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d59:	0f b6 00             	movzbl (%eax),%eax
  800d5c:	38 c2                	cmp    %al,%dl
  800d5e:	74 de                	je     800d3e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	0f b6 d0             	movzbl %al,%edx
  800d69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6c:	0f b6 00             	movzbl (%eax),%eax
  800d6f:	0f b6 c0             	movzbl %al,%eax
  800d72:	29 c2                	sub    %eax,%edx
  800d74:	89 d0                	mov    %edx,%eax
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d7b:	eb 0c                	jmp    800d89 <strncmp+0x11>
		n--, p++, q++;
  800d7d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d85:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d8d:	74 1a                	je     800da9 <strncmp+0x31>
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	0f b6 00             	movzbl (%eax),%eax
  800d95:	84 c0                	test   %al,%al
  800d97:	74 10                	je     800da9 <strncmp+0x31>
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	0f b6 10             	movzbl (%eax),%edx
  800d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da2:	0f b6 00             	movzbl (%eax),%eax
  800da5:	38 c2                	cmp    %al,%dl
  800da7:	74 d4                	je     800d7d <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dad:	75 07                	jne    800db6 <strncmp+0x3e>
		return 0;
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	eb 16                	jmp    800dcc <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	0f b6 00             	movzbl (%eax),%eax
  800dbc:	0f b6 d0             	movzbl %al,%edx
  800dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc2:	0f b6 00             	movzbl (%eax),%eax
  800dc5:	0f b6 c0             	movzbl %al,%eax
  800dc8:	29 c2                	sub    %eax,%edx
  800dca:	89 d0                	mov    %edx,%eax
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dda:	eb 14                	jmp    800df0 <strchr+0x22>
		if (*s == c)
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	0f b6 00             	movzbl (%eax),%eax
  800de2:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800de5:	75 05                	jne    800dec <strchr+0x1e>
			return (char *) s;
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	eb 13                	jmp    800dff <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	84 c0                	test   %al,%al
  800df8:	75 e2                	jne    800ddc <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e0d:	eb 11                	jmp    800e20 <strfind+0x1f>
		if (*s == c)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	0f b6 00             	movzbl (%eax),%eax
  800e15:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e18:	75 02                	jne    800e1c <strfind+0x1b>
			break;
  800e1a:	eb 0e                	jmp    800e2a <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	0f b6 00             	movzbl (%eax),%eax
  800e26:	84 c0                	test   %al,%al
  800e28:	75 e5                	jne    800e0f <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e37:	75 05                	jne    800e3e <memset+0xf>
		return v;
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	eb 5c                	jmp    800e9a <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	83 e0 03             	and    $0x3,%eax
  800e44:	85 c0                	test   %eax,%eax
  800e46:	75 41                	jne    800e89 <memset+0x5a>
  800e48:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4b:	83 e0 03             	and    $0x3,%eax
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	75 37                	jne    800e89 <memset+0x5a>
		c &= 0xFF;
  800e52:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	c1 e0 18             	shl    $0x18,%eax
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e64:	c1 e0 10             	shl    $0x10,%eax
  800e67:	09 c2                	or     %eax,%edx
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	c1 e0 08             	shl    $0x8,%eax
  800e6f:	09 d0                	or     %edx,%eax
  800e71:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e74:	8b 45 10             	mov    0x10(%ebp),%eax
  800e77:	c1 e8 02             	shr    $0x2,%eax
  800e7a:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	89 d7                	mov    %edx,%edi
  800e84:	fc                   	cld    
  800e85:	f3 ab                	rep stos %eax,%es:(%edi)
  800e87:	eb 0e                	jmp    800e97 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e92:	89 d7                	mov    %edx,%edi
  800e94:	fc                   	cld    
  800e95:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eb8:	73 6d                	jae    800f27 <memmove+0x8a>
  800eba:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec0:	01 d0                	add    %edx,%eax
  800ec2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec5:	76 60                	jbe    800f27 <memmove+0x8a>
		s += n;
  800ec7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eca:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ecd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed0:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed6:	83 e0 03             	and    $0x3,%eax
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	75 2f                	jne    800f0c <memmove+0x6f>
  800edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee0:	83 e0 03             	and    $0x3,%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	75 25                	jne    800f0c <memmove+0x6f>
  800ee7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eea:	83 e0 03             	and    $0x3,%eax
  800eed:	85 c0                	test   %eax,%eax
  800eef:	75 1b                	jne    800f0c <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef4:	83 e8 04             	sub    $0x4,%eax
  800ef7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800efa:	83 ea 04             	sub    $0x4,%edx
  800efd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f03:	89 c7                	mov    %eax,%edi
  800f05:	89 d6                	mov    %edx,%esi
  800f07:	fd                   	std    
  800f08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0a:	eb 18                	jmp    800f24 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f0f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f15:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f18:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 de                	mov    %ebx,%esi
  800f1f:	89 c1                	mov    %eax,%ecx
  800f21:	fd                   	std    
  800f22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f24:	fc                   	cld    
  800f25:	eb 45                	jmp    800f6c <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2a:	83 e0 03             	and    $0x3,%eax
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	75 2b                	jne    800f5c <memmove+0xbf>
  800f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f34:	83 e0 03             	and    $0x3,%eax
  800f37:	85 c0                	test   %eax,%eax
  800f39:	75 21                	jne    800f5c <memmove+0xbf>
  800f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3e:	83 e0 03             	and    $0x3,%eax
  800f41:	85 c0                	test   %eax,%eax
  800f43:	75 17                	jne    800f5c <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f45:	8b 45 10             	mov    0x10(%ebp),%eax
  800f48:	c1 e8 02             	shr    $0x2,%eax
  800f4b:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f53:	89 c7                	mov    %eax,%edi
  800f55:	89 d6                	mov    %edx,%esi
  800f57:	fc                   	cld    
  800f58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5a:	eb 10                	jmp    800f6c <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f62:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f65:	89 c7                	mov    %eax,%edi
  800f67:	89 d6                	mov    %edx,%esi
  800f69:	fc                   	cld    
  800f6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	89 04 24             	mov    %eax,(%esp)
  800f91:	e8 07 ff ff ff       	call   800e9d <memmove>
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    

00800f98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800faa:	eb 30                	jmp    800fdc <memcmp+0x44>
		if (*s1 != *s2)
  800fac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800faf:	0f b6 10             	movzbl (%eax),%edx
  800fb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fb5:	0f b6 00             	movzbl (%eax),%eax
  800fb8:	38 c2                	cmp    %al,%dl
  800fba:	74 18                	je     800fd4 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fbf:	0f b6 00             	movzbl (%eax),%eax
  800fc2:	0f b6 d0             	movzbl %al,%edx
  800fc5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc8:	0f b6 00             	movzbl (%eax),%eax
  800fcb:	0f b6 c0             	movzbl %al,%eax
  800fce:	29 c2                	sub    %eax,%edx
  800fd0:	89 d0                	mov    %edx,%eax
  800fd2:	eb 1a                	jmp    800fee <memcmp+0x56>
		s1++, s2++;
  800fd4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fd8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdf:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe2:	89 55 10             	mov    %edx,0x10(%ebp)
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	75 c3                	jne    800fac <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ff6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	01 d0                	add    %edx,%eax
  800ffe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801001:	eb 13                	jmp    801016 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801003:	8b 45 08             	mov    0x8(%ebp),%eax
  801006:	0f b6 10             	movzbl (%eax),%edx
  801009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100c:	38 c2                	cmp    %al,%dl
  80100e:	75 02                	jne    801012 <memfind+0x22>
			break;
  801010:	eb 0c                	jmp    80101e <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801012:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80101c:	72 e5                	jb     801003 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801029:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801030:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801037:	eb 04                	jmp    80103d <strtol+0x1a>
		s++;
  801039:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	0f b6 00             	movzbl (%eax),%eax
  801043:	3c 20                	cmp    $0x20,%al
  801045:	74 f2                	je     801039 <strtol+0x16>
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	0f b6 00             	movzbl (%eax),%eax
  80104d:	3c 09                	cmp    $0x9,%al
  80104f:	74 e8                	je     801039 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801051:	8b 45 08             	mov    0x8(%ebp),%eax
  801054:	0f b6 00             	movzbl (%eax),%eax
  801057:	3c 2b                	cmp    $0x2b,%al
  801059:	75 06                	jne    801061 <strtol+0x3e>
		s++;
  80105b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80105f:	eb 15                	jmp    801076 <strtol+0x53>
	else if (*s == '-')
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	0f b6 00             	movzbl (%eax),%eax
  801067:	3c 2d                	cmp    $0x2d,%al
  801069:	75 0b                	jne    801076 <strtol+0x53>
		s++, neg = 1;
  80106b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80106f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801076:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80107a:	74 06                	je     801082 <strtol+0x5f>
  80107c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801080:	75 24                	jne    8010a6 <strtol+0x83>
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	0f b6 00             	movzbl (%eax),%eax
  801088:	3c 30                	cmp    $0x30,%al
  80108a:	75 1a                	jne    8010a6 <strtol+0x83>
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	83 c0 01             	add    $0x1,%eax
  801092:	0f b6 00             	movzbl (%eax),%eax
  801095:	3c 78                	cmp    $0x78,%al
  801097:	75 0d                	jne    8010a6 <strtol+0x83>
		s += 2, base = 16;
  801099:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80109d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010a4:	eb 2a                	jmp    8010d0 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010aa:	75 17                	jne    8010c3 <strtol+0xa0>
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	3c 30                	cmp    $0x30,%al
  8010b4:	75 0d                	jne    8010c3 <strtol+0xa0>
		s++, base = 8;
  8010b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ba:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010c1:	eb 0d                	jmp    8010d0 <strtol+0xad>
	else if (base == 0)
  8010c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c7:	75 07                	jne    8010d0 <strtol+0xad>
		base = 10;
  8010c9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	0f b6 00             	movzbl (%eax),%eax
  8010d6:	3c 2f                	cmp    $0x2f,%al
  8010d8:	7e 1b                	jle    8010f5 <strtol+0xd2>
  8010da:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dd:	0f b6 00             	movzbl (%eax),%eax
  8010e0:	3c 39                	cmp    $0x39,%al
  8010e2:	7f 11                	jg     8010f5 <strtol+0xd2>
			dig = *s - '0';
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	0f b6 00             	movzbl (%eax),%eax
  8010ea:	0f be c0             	movsbl %al,%eax
  8010ed:	83 e8 30             	sub    $0x30,%eax
  8010f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f3:	eb 48                	jmp    80113d <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	0f b6 00             	movzbl (%eax),%eax
  8010fb:	3c 60                	cmp    $0x60,%al
  8010fd:	7e 1b                	jle    80111a <strtol+0xf7>
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	0f b6 00             	movzbl (%eax),%eax
  801105:	3c 7a                	cmp    $0x7a,%al
  801107:	7f 11                	jg     80111a <strtol+0xf7>
			dig = *s - 'a' + 10;
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
  80110c:	0f b6 00             	movzbl (%eax),%eax
  80110f:	0f be c0             	movsbl %al,%eax
  801112:	83 e8 57             	sub    $0x57,%eax
  801115:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801118:	eb 23                	jmp    80113d <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	0f b6 00             	movzbl (%eax),%eax
  801120:	3c 40                	cmp    $0x40,%al
  801122:	7e 3d                	jle    801161 <strtol+0x13e>
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
  801127:	0f b6 00             	movzbl (%eax),%eax
  80112a:	3c 5a                	cmp    $0x5a,%al
  80112c:	7f 33                	jg     801161 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	0f b6 00             	movzbl (%eax),%eax
  801134:	0f be c0             	movsbl %al,%eax
  801137:	83 e8 37             	sub    $0x37,%eax
  80113a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801140:	3b 45 10             	cmp    0x10(%ebp),%eax
  801143:	7c 02                	jl     801147 <strtol+0x124>
			break;
  801145:	eb 1a                	jmp    801161 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801147:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80114b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80114e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801152:	89 c2                	mov    %eax,%edx
  801154:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801157:	01 d0                	add    %edx,%eax
  801159:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80115c:	e9 6f ff ff ff       	jmp    8010d0 <strtol+0xad>

	if (endptr)
  801161:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801165:	74 08                	je     80116f <strtol+0x14c>
		*endptr = (char *) s;
  801167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116a:	8b 55 08             	mov    0x8(%ebp),%edx
  80116d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80116f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801173:	74 07                	je     80117c <strtol+0x159>
  801175:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801178:	f7 d8                	neg    %eax
  80117a:	eb 03                	jmp    80117f <strtol+0x15c>
  80117c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    
  801181:	66 90                	xchg   %ax,%ax
  801183:	66 90                	xchg   %ax,%ax
  801185:	66 90                	xchg   %ax,%ax
  801187:	66 90                	xchg   %ax,%ax
  801189:	66 90                	xchg   %ax,%ax
  80118b:	66 90                	xchg   %ax,%ax
  80118d:	66 90                	xchg   %ax,%ax
  80118f:	90                   	nop

00801190 <__udivdi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	8b 44 24 28          	mov    0x28(%esp),%eax
  80119a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80119e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ac:	89 ea                	mov    %ebp,%edx
  8011ae:	89 0c 24             	mov    %ecx,(%esp)
  8011b1:	75 2d                	jne    8011e0 <__udivdi3+0x50>
  8011b3:	39 e9                	cmp    %ebp,%ecx
  8011b5:	77 61                	ja     801218 <__udivdi3+0x88>
  8011b7:	85 c9                	test   %ecx,%ecx
  8011b9:	89 ce                	mov    %ecx,%esi
  8011bb:	75 0b                	jne    8011c8 <__udivdi3+0x38>
  8011bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c2:	31 d2                	xor    %edx,%edx
  8011c4:	f7 f1                	div    %ecx
  8011c6:	89 c6                	mov    %eax,%esi
  8011c8:	31 d2                	xor    %edx,%edx
  8011ca:	89 e8                	mov    %ebp,%eax
  8011cc:	f7 f6                	div    %esi
  8011ce:	89 c5                	mov    %eax,%ebp
  8011d0:	89 f8                	mov    %edi,%eax
  8011d2:	f7 f6                	div    %esi
  8011d4:	89 ea                	mov    %ebp,%edx
  8011d6:	83 c4 0c             	add    $0xc,%esp
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    
  8011dd:	8d 76 00             	lea    0x0(%esi),%esi
  8011e0:	39 e8                	cmp    %ebp,%eax
  8011e2:	77 24                	ja     801208 <__udivdi3+0x78>
  8011e4:	0f bd e8             	bsr    %eax,%ebp
  8011e7:	83 f5 1f             	xor    $0x1f,%ebp
  8011ea:	75 3c                	jne    801228 <__udivdi3+0x98>
  8011ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011f0:	39 34 24             	cmp    %esi,(%esp)
  8011f3:	0f 86 9f 00 00 00    	jbe    801298 <__udivdi3+0x108>
  8011f9:	39 d0                	cmp    %edx,%eax
  8011fb:	0f 82 97 00 00 00    	jb     801298 <__udivdi3+0x108>
  801201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801208:	31 d2                	xor    %edx,%edx
  80120a:	31 c0                	xor    %eax,%eax
  80120c:	83 c4 0c             	add    $0xc,%esp
  80120f:	5e                   	pop    %esi
  801210:	5f                   	pop    %edi
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    
  801213:	90                   	nop
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	89 f8                	mov    %edi,%eax
  80121a:	f7 f1                	div    %ecx
  80121c:	31 d2                	xor    %edx,%edx
  80121e:	83 c4 0c             	add    $0xc,%esp
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    
  801225:	8d 76 00             	lea    0x0(%esi),%esi
  801228:	89 e9                	mov    %ebp,%ecx
  80122a:	8b 3c 24             	mov    (%esp),%edi
  80122d:	d3 e0                	shl    %cl,%eax
  80122f:	89 c6                	mov    %eax,%esi
  801231:	b8 20 00 00 00       	mov    $0x20,%eax
  801236:	29 e8                	sub    %ebp,%eax
  801238:	89 c1                	mov    %eax,%ecx
  80123a:	d3 ef                	shr    %cl,%edi
  80123c:	89 e9                	mov    %ebp,%ecx
  80123e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801242:	8b 3c 24             	mov    (%esp),%edi
  801245:	09 74 24 08          	or     %esi,0x8(%esp)
  801249:	89 d6                	mov    %edx,%esi
  80124b:	d3 e7                	shl    %cl,%edi
  80124d:	89 c1                	mov    %eax,%ecx
  80124f:	89 3c 24             	mov    %edi,(%esp)
  801252:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801256:	d3 ee                	shr    %cl,%esi
  801258:	89 e9                	mov    %ebp,%ecx
  80125a:	d3 e2                	shl    %cl,%edx
  80125c:	89 c1                	mov    %eax,%ecx
  80125e:	d3 ef                	shr    %cl,%edi
  801260:	09 d7                	or     %edx,%edi
  801262:	89 f2                	mov    %esi,%edx
  801264:	89 f8                	mov    %edi,%eax
  801266:	f7 74 24 08          	divl   0x8(%esp)
  80126a:	89 d6                	mov    %edx,%esi
  80126c:	89 c7                	mov    %eax,%edi
  80126e:	f7 24 24             	mull   (%esp)
  801271:	39 d6                	cmp    %edx,%esi
  801273:	89 14 24             	mov    %edx,(%esp)
  801276:	72 30                	jb     8012a8 <__udivdi3+0x118>
  801278:	8b 54 24 04          	mov    0x4(%esp),%edx
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 e2                	shl    %cl,%edx
  801280:	39 c2                	cmp    %eax,%edx
  801282:	73 05                	jae    801289 <__udivdi3+0xf9>
  801284:	3b 34 24             	cmp    (%esp),%esi
  801287:	74 1f                	je     8012a8 <__udivdi3+0x118>
  801289:	89 f8                	mov    %edi,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	e9 7a ff ff ff       	jmp    80120c <__udivdi3+0x7c>
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	31 d2                	xor    %edx,%edx
  80129a:	b8 01 00 00 00       	mov    $0x1,%eax
  80129f:	e9 68 ff ff ff       	jmp    80120c <__udivdi3+0x7c>
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012ab:	31 d2                	xor    %edx,%edx
  8012ad:	83 c4 0c             	add    $0xc,%esp
  8012b0:	5e                   	pop    %esi
  8012b1:	5f                   	pop    %edi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    
  8012b4:	66 90                	xchg   %ax,%ax
  8012b6:	66 90                	xchg   %ax,%ax
  8012b8:	66 90                	xchg   %ax,%ax
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	83 ec 14             	sub    $0x14,%esp
  8012c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012d2:	89 c7                	mov    %eax,%edi
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012e0:	89 34 24             	mov    %esi,(%esp)
  8012e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ef:	75 17                	jne    801308 <__umoddi3+0x48>
  8012f1:	39 fe                	cmp    %edi,%esi
  8012f3:	76 4b                	jbe    801340 <__umoddi3+0x80>
  8012f5:	89 c8                	mov    %ecx,%eax
  8012f7:	89 fa                	mov    %edi,%edx
  8012f9:	f7 f6                	div    %esi
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	31 d2                	xor    %edx,%edx
  8012ff:	83 c4 14             	add    $0x14,%esp
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    
  801306:	66 90                	xchg   %ax,%ax
  801308:	39 f8                	cmp    %edi,%eax
  80130a:	77 54                	ja     801360 <__umoddi3+0xa0>
  80130c:	0f bd e8             	bsr    %eax,%ebp
  80130f:	83 f5 1f             	xor    $0x1f,%ebp
  801312:	75 5c                	jne    801370 <__umoddi3+0xb0>
  801314:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801318:	39 3c 24             	cmp    %edi,(%esp)
  80131b:	0f 87 e7 00 00 00    	ja     801408 <__umoddi3+0x148>
  801321:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801325:	29 f1                	sub    %esi,%ecx
  801327:	19 c7                	sbb    %eax,%edi
  801329:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801331:	8b 44 24 08          	mov    0x8(%esp),%eax
  801335:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801339:	83 c4 14             	add    $0x14,%esp
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
  801340:	85 f6                	test   %esi,%esi
  801342:	89 f5                	mov    %esi,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x91>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f6                	div    %esi
  80134f:	89 c5                	mov    %eax,%ebp
  801351:	8b 44 24 04          	mov    0x4(%esp),%eax
  801355:	31 d2                	xor    %edx,%edx
  801357:	f7 f5                	div    %ebp
  801359:	89 c8                	mov    %ecx,%eax
  80135b:	f7 f5                	div    %ebp
  80135d:	eb 9c                	jmp    8012fb <__umoddi3+0x3b>
  80135f:	90                   	nop
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 fa                	mov    %edi,%edx
  801364:	83 c4 14             	add    $0x14,%esp
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    
  80136b:	90                   	nop
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	8b 04 24             	mov    (%esp),%eax
  801373:	be 20 00 00 00       	mov    $0x20,%esi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	29 ee                	sub    %ebp,%esi
  80137c:	d3 e2                	shl    %cl,%edx
  80137e:	89 f1                	mov    %esi,%ecx
  801380:	d3 e8                	shr    %cl,%eax
  801382:	89 e9                	mov    %ebp,%ecx
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 04 24             	mov    (%esp),%eax
  80138b:	09 54 24 04          	or     %edx,0x4(%esp)
  80138f:	89 fa                	mov    %edi,%edx
  801391:	d3 e0                	shl    %cl,%eax
  801393:	89 f1                	mov    %esi,%ecx
  801395:	89 44 24 08          	mov    %eax,0x8(%esp)
  801399:	8b 44 24 10          	mov    0x10(%esp),%eax
  80139d:	d3 ea                	shr    %cl,%edx
  80139f:	89 e9                	mov    %ebp,%ecx
  8013a1:	d3 e7                	shl    %cl,%edi
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	d3 e8                	shr    %cl,%eax
  8013a7:	89 e9                	mov    %ebp,%ecx
  8013a9:	09 f8                	or     %edi,%eax
  8013ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013af:	f7 74 24 04          	divl   0x4(%esp)
  8013b3:	d3 e7                	shl    %cl,%edi
  8013b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013b9:	89 d7                	mov    %edx,%edi
  8013bb:	f7 64 24 08          	mull   0x8(%esp)
  8013bf:	39 d7                	cmp    %edx,%edi
  8013c1:	89 c1                	mov    %eax,%ecx
  8013c3:	89 14 24             	mov    %edx,(%esp)
  8013c6:	72 2c                	jb     8013f4 <__umoddi3+0x134>
  8013c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013cc:	72 22                	jb     8013f0 <__umoddi3+0x130>
  8013ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013d2:	29 c8                	sub    %ecx,%eax
  8013d4:	19 d7                	sbb    %edx,%edi
  8013d6:	89 e9                	mov    %ebp,%ecx
  8013d8:	89 fa                	mov    %edi,%edx
  8013da:	d3 e8                	shr    %cl,%eax
  8013dc:	89 f1                	mov    %esi,%ecx
  8013de:	d3 e2                	shl    %cl,%edx
  8013e0:	89 e9                	mov    %ebp,%ecx
  8013e2:	d3 ef                	shr    %cl,%edi
  8013e4:	09 d0                	or     %edx,%eax
  8013e6:	89 fa                	mov    %edi,%edx
  8013e8:	83 c4 14             	add    $0x14,%esp
  8013eb:	5e                   	pop    %esi
  8013ec:	5f                   	pop    %edi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    
  8013ef:	90                   	nop
  8013f0:	39 d7                	cmp    %edx,%edi
  8013f2:	75 da                	jne    8013ce <__umoddi3+0x10e>
  8013f4:	8b 14 24             	mov    (%esp),%edx
  8013f7:	89 c1                	mov    %eax,%ecx
  8013f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8013fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801401:	eb cb                	jmp    8013ce <__umoddi3+0x10e>
  801403:	90                   	nop
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80140c:	0f 82 0f ff ff ff    	jb     801321 <__umoddi3+0x61>
  801412:	e9 1a ff ff ff       	jmp    801331 <__umoddi3+0x71>
