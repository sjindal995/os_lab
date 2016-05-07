
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
  800050:	e8 26 02 00 00       	call   80027b <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800055:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005c:	f0 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 1d 03 00 00       	call   800386 <sys_env_set_pgfault_upcall>
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
  80007c:	e8 72 01 00 00       	call   8001f3 <sys_getenvid>
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	c1 e0 02             	shl    $0x2,%eax
  800089:	89 c2                	mov    %eax,%edx
  80008b:	c1 e2 05             	shl    $0x5,%edx
  80008e:	29 c2                	sub    %eax,%edx
  800090:	89 d0                	mov    %edx,%eax
  800092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  80009c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80009f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a6:	89 04 24             	mov    %eax,(%esp)
  8000a9:	e8 85 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ae:	e8 02 00 00 00       	call   8000b5 <exit>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 e9 00 00 00       	call   8001b0 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000d8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000db:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000de:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000e1:	8b 75 20             	mov    0x20(%ebp),%esi
  8000e4:	cd 30                	int    $0x30
  8000e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000ed:	74 30                	je     80011f <syscall+0x56>
  8000ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000f3:	7e 2a                	jle    80011f <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800103:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  80011a:	e8 b3 03 00 00       	call   8004d2 <_panic>

	return ret;
  80011f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800122:	83 c4 3c             	add    $0x3c,%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800130:	8b 45 08             	mov    0x8(%ebp),%eax
  800133:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80013a:	00 
  80013b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800142:	00 
  800143:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80014a:	00 
  80014b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80014e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 5f ff ff ff       	call   8000c9 <syscall>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <sys_cgetc>:

int
sys_cgetc(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800172:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800179:	00 
  80017a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800181:	00 
  800182:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800189:	00 
  80018a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800191:	00 
  800192:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a9:	e8 1b ff ff ff       	call   8000c9 <syscall>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d8:	00 
  8001d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001e4:	00 
  8001e5:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001ec:	e8 d8 fe ff ff       	call   8000c9 <syscall>
}
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001f9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800200:	00 
  800201:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800208:	00 
  800209:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800210:	00 
  800211:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800218:	00 
  800219:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800220:	00 
  800221:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800228:	00 
  800229:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800230:	e8 94 fe ff ff       	call   8000c9 <syscall>
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <sys_yield>:

void
sys_yield(void)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80023d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800244:	00 
  800245:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80024c:	00 
  80024d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800254:	00 
  800255:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025c:	00 
  80025d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800264:	00 
  800265:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80026c:	00 
  80026d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800274:	e8 50 fe ff ff       	call   8000c9 <syscall>
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800281:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800291:	00 
  800292:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800299:	00 
  80029a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80029e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8002b5:	e8 0f fe ff ff       	call   8000c9 <syscall>
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002c4:	8b 75 18             	mov    0x18(%ebp),%esi
  8002c7:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002d7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002db:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002ee:	00 
  8002ef:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002f6:	e8 ce fd ff ff       	call   8000c9 <syscall>
}
  8002fb:	83 c4 20             	add    $0x20,%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80030b:	8b 45 08             	mov    0x8(%ebp),%eax
  80030e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800315:	00 
  800316:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80031d:	00 
  80031e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800325:	00 
  800326:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80032a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800335:	00 
  800336:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80033d:	e8 87 fd ff ff       	call   8000c9 <syscall>
}
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80034a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80034d:	8b 45 08             	mov    0x8(%ebp),%eax
  800350:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800357:	00 
  800358:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80035f:	00 
  800360:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800367:	00 
  800368:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80037f:	e8 45 fd ff ff       	call   8000c9 <syscall>
}
  800384:	c9                   	leave  
  800385:	c3                   	ret    

00800386 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
  800392:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800399:	00 
  80039a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003a9:	00 
  8003aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003b9:	00 
  8003ba:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003c1:	e8 03 fd ff ff       	call   8000c9 <syscall>
}
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003ce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003de:	00 
  8003df:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003f9:	00 
  8003fa:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  800401:	e8 c3 fc ff ff       	call   8000c9 <syscall>
}
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800418:	00 
  800419:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800420:	00 
  800421:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800428:	00 
  800429:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800430:	00 
  800431:	89 44 24 08          	mov    %eax,0x8(%esp)
  800435:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80043c:	00 
  80043d:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800444:	e8 80 fc ff ff       	call   8000c9 <syscall>
}
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <sys_exec>:

void sys_exec(char* buf){
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80045b:	00 
  80045c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800463:	00 
  800464:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80046b:	00 
  80046c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800473:	00 
  800474:	89 44 24 08          	mov    %eax,0x8(%esp)
  800478:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80047f:	00 
  800480:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800487:	e8 3d fc ff ff       	call   8000c9 <syscall>
}
  80048c:	c9                   	leave  
  80048d:	c3                   	ret    

0080048e <sys_wait>:

void sys_wait(){
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  800494:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80049b:	00 
  80049c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004a3:	00 
  8004a4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004ab:	00 
  8004ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004bb:	00 
  8004bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004c3:	00 
  8004c4:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8004cb:	e8 f9 fb ff ff       	call   8000c9 <syscall>
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    

008004d2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	53                   	push   %ebx
  8004d6:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8004dc:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004df:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004e5:	e8 09 fd ff ff       	call   8001f3 <sys_getenvid>
  8004ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800500:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800507:	e8 e1 00 00 00       	call   8005ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800513:	8b 45 10             	mov    0x10(%ebp),%eax
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	e8 6b 00 00 00       	call   800589 <vcprintf>
	cprintf("\n");
  80051e:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  800525:	e8 c3 00 00 00       	call   8005ed <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80052a:	cc                   	int3   
  80052b:	eb fd                	jmp    80052a <_panic+0x58>

0080052d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
  800536:	8b 00                	mov    (%eax),%eax
  800538:	8d 48 01             	lea    0x1(%eax),%ecx
  80053b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053e:	89 0a                	mov    %ecx,(%edx)
  800540:	8b 55 08             	mov    0x8(%ebp),%edx
  800543:	89 d1                	mov    %edx,%ecx
  800545:	8b 55 0c             	mov    0xc(%ebp),%edx
  800548:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80054c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	3d ff 00 00 00       	cmp    $0xff,%eax
  800556:	75 20                	jne    800578 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800560:	83 c2 08             	add    $0x8,%edx
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
  800567:	89 14 24             	mov    %edx,(%esp)
  80056a:	e8 bb fb ff ff       	call   80012a <sys_cputs>
		b->idx = 0;
  80056f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800572:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057b:	8b 40 04             	mov    0x4(%eax),%eax
  80057e:	8d 50 01             	lea    0x1(%eax),%edx
  800581:	8b 45 0c             	mov    0xc(%ebp),%eax
  800584:	89 50 04             	mov    %edx,0x4(%eax)
}
  800587:	c9                   	leave  
  800588:	c3                   	ret    

00800589 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800592:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800599:	00 00 00 
	b.cnt = 0;
  80059c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005be:	c7 04 24 2d 05 80 00 	movl   $0x80052d,(%esp)
  8005c5:	e8 bd 01 00 00       	call   800787 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ca:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005da:	83 c0 08             	add    $0x8,%eax
  8005dd:	89 04 24             	mov    %eax,(%esp)
  8005e0:	e8 45 fb ff ff       	call   80012a <sys_cputs>

	return b.cnt;
  8005e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005eb:	c9                   	leave  
  8005ec:	c3                   	ret    

008005ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005f3:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800600:	8b 45 08             	mov    0x8(%ebp),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	e8 7e ff ff ff       	call   800589 <vcprintf>
  80060b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80060e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800611:	c9                   	leave  
  800612:	c3                   	ret    

00800613 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800613:	55                   	push   %ebp
  800614:	89 e5                	mov    %esp,%ebp
  800616:	53                   	push   %ebx
  800617:	83 ec 34             	sub    $0x34,%esp
  80061a:	8b 45 10             	mov    0x10(%ebp),%eax
  80061d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800626:	8b 45 18             	mov    0x18(%ebp),%eax
  800629:	ba 00 00 00 00       	mov    $0x0,%edx
  80062e:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800631:	77 72                	ja     8006a5 <printnum+0x92>
  800633:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800636:	72 05                	jb     80063d <printnum+0x2a>
  800638:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80063b:	77 68                	ja     8006a5 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80063d:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800640:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800643:	8b 45 18             	mov    0x18(%ebp),%eax
  800646:	ba 00 00 00 00       	mov    $0x0,%edx
  80064b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800653:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800656:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800660:	e8 9b 0b 00 00       	call   801200 <__udivdi3>
  800665:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800668:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80066c:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800670:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800673:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800677:	89 44 24 08          	mov    %eax,0x8(%esp)
  80067b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80067f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800682:	89 44 24 04          	mov    %eax,0x4(%esp)
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	e8 82 ff ff ff       	call   800613 <printnum>
  800691:	eb 1c                	jmp    8006af <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800693:	8b 45 0c             	mov    0xc(%ebp),%eax
  800696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069a:	8b 45 20             	mov    0x20(%ebp),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006a5:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006a9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006ad:	7f e4                	jg     800693 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006af:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006c5:	89 04 24             	mov    %eax,(%esp)
  8006c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006cc:	e8 5f 0c 00 00       	call   801330 <__umoddi3>
  8006d1:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8006d6:	0f b6 00             	movzbl (%eax),%eax
  8006d9:	0f be c0             	movsbl %al,%eax
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006df:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	ff d0                	call   *%eax
}
  8006eb:	83 c4 34             	add    $0x34,%esp
  8006ee:	5b                   	pop    %ebx
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006f4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006f8:	7e 14                	jle    80070e <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	8d 48 08             	lea    0x8(%eax),%ecx
  800702:	8b 55 08             	mov    0x8(%ebp),%edx
  800705:	89 0a                	mov    %ecx,(%edx)
  800707:	8b 50 04             	mov    0x4(%eax),%edx
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	eb 30                	jmp    80073e <getuint+0x4d>
	else if (lflag)
  80070e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800712:	74 16                	je     80072a <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 00                	mov    (%eax),%eax
  800719:	8d 48 04             	lea    0x4(%eax),%ecx
  80071c:	8b 55 08             	mov    0x8(%ebp),%edx
  80071f:	89 0a                	mov    %ecx,(%edx)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	ba 00 00 00 00       	mov    $0x0,%edx
  800728:	eb 14                	jmp    80073e <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	8d 48 04             	lea    0x4(%eax),%ecx
  800732:	8b 55 08             	mov    0x8(%ebp),%edx
  800735:	89 0a                	mov    %ecx,(%edx)
  800737:	8b 00                	mov    (%eax),%eax
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800743:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800747:	7e 14                	jle    80075d <getint+0x1d>
		return va_arg(*ap, long long);
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	8d 48 08             	lea    0x8(%eax),%ecx
  800751:	8b 55 08             	mov    0x8(%ebp),%edx
  800754:	89 0a                	mov    %ecx,(%edx)
  800756:	8b 50 04             	mov    0x4(%eax),%edx
  800759:	8b 00                	mov    (%eax),%eax
  80075b:	eb 28                	jmp    800785 <getint+0x45>
	else if (lflag)
  80075d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800761:	74 12                	je     800775 <getint+0x35>
		return va_arg(*ap, long);
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 00                	mov    (%eax),%eax
  800768:	8d 48 04             	lea    0x4(%eax),%ecx
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
  80076e:	89 0a                	mov    %ecx,(%edx)
  800770:	8b 00                	mov    (%eax),%eax
  800772:	99                   	cltd   
  800773:	eb 10                	jmp    800785 <getint+0x45>
	else
		return va_arg(*ap, int);
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	8d 48 04             	lea    0x4(%eax),%ecx
  80077d:	8b 55 08             	mov    0x8(%ebp),%edx
  800780:	89 0a                	mov    %ecx,(%edx)
  800782:	8b 00                	mov    (%eax),%eax
  800784:	99                   	cltd   
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078f:	eb 18                	jmp    8007a9 <vprintfmt+0x22>
			if (ch == '\0')
  800791:	85 db                	test   %ebx,%ebx
  800793:	75 05                	jne    80079a <vprintfmt+0x13>
				return;
  800795:	e9 cc 03 00 00       	jmp    800b66 <vprintfmt+0x3df>
			putch(ch, putdat);
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	89 1c 24             	mov    %ebx,(%esp)
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ac:	8d 50 01             	lea    0x1(%eax),%edx
  8007af:	89 55 10             	mov    %edx,0x10(%ebp)
  8007b2:	0f b6 00             	movzbl (%eax),%eax
  8007b5:	0f b6 d8             	movzbl %al,%ebx
  8007b8:	83 fb 25             	cmp    $0x25,%ebx
  8007bb:	75 d4                	jne    800791 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007bd:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007c1:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007c8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007cf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e0:	8d 50 01             	lea    0x1(%eax),%edx
  8007e3:	89 55 10             	mov    %edx,0x10(%ebp)
  8007e6:	0f b6 00             	movzbl (%eax),%eax
  8007e9:	0f b6 d8             	movzbl %al,%ebx
  8007ec:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007ef:	83 f8 55             	cmp    $0x55,%eax
  8007f2:	0f 87 3d 03 00 00    	ja     800b35 <vprintfmt+0x3ae>
  8007f8:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  8007ff:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800801:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800805:	eb d6                	jmp    8007dd <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800807:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80080b:	eb d0                	jmp    8007dd <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80080d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800814:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800817:	89 d0                	mov    %edx,%eax
  800819:	c1 e0 02             	shl    $0x2,%eax
  80081c:	01 d0                	add    %edx,%eax
  80081e:	01 c0                	add    %eax,%eax
  800820:	01 d8                	add    %ebx,%eax
  800822:	83 e8 30             	sub    $0x30,%eax
  800825:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800828:	8b 45 10             	mov    0x10(%ebp),%eax
  80082b:	0f b6 00             	movzbl (%eax),%eax
  80082e:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800831:	83 fb 2f             	cmp    $0x2f,%ebx
  800834:	7e 0b                	jle    800841 <vprintfmt+0xba>
  800836:	83 fb 39             	cmp    $0x39,%ebx
  800839:	7f 06                	jg     800841 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80083b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80083f:	eb d3                	jmp    800814 <vprintfmt+0x8d>
			goto process_precision;
  800841:	eb 33                	jmp    800876 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	8d 50 04             	lea    0x4(%eax),%edx
  800849:	89 55 14             	mov    %edx,0x14(%ebp)
  80084c:	8b 00                	mov    (%eax),%eax
  80084e:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800851:	eb 23                	jmp    800876 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800853:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800857:	79 0c                	jns    800865 <vprintfmt+0xde>
				width = 0;
  800859:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800860:	e9 78 ff ff ff       	jmp    8007dd <vprintfmt+0x56>
  800865:	e9 73 ff ff ff       	jmp    8007dd <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80086a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800871:	e9 67 ff ff ff       	jmp    8007dd <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800876:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80087a:	79 12                	jns    80088e <vprintfmt+0x107>
				width = precision, precision = -1;
  80087c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80087f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800882:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800889:	e9 4f ff ff ff       	jmp    8007dd <vprintfmt+0x56>
  80088e:	e9 4a ff ff ff       	jmp    8007dd <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800893:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800897:	e9 41 ff ff ff       	jmp    8007dd <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 50 04             	lea    0x4(%eax),%edx
  8008a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	ff d0                	call   *%eax
			break;
  8008b6:	e9 a5 02 00 00       	jmp    800b60 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 50 04             	lea    0x4(%eax),%edx
  8008c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c4:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008c6:	85 db                	test   %ebx,%ebx
  8008c8:	79 02                	jns    8008cc <vprintfmt+0x145>
				err = -err;
  8008ca:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008cc:	83 fb 09             	cmp    $0x9,%ebx
  8008cf:	7f 0b                	jg     8008dc <vprintfmt+0x155>
  8008d1:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8008d8:	85 f6                	test   %esi,%esi
  8008da:	75 23                	jne    8008ff <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008e0:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8008e7:	00 
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 73 02 00 00       	call   800b6d <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008fa:	e9 61 02 00 00       	jmp    800b60 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800903:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  80090a:	00 
  80090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 50 02 00 00       	call   800b6d <printfmt>
			break;
  80091d:	e9 3e 02 00 00       	jmp    800b60 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 04             	lea    0x4(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	8b 30                	mov    (%eax),%esi
  80092d:	85 f6                	test   %esi,%esi
  80092f:	75 05                	jne    800936 <vprintfmt+0x1af>
				p = "(null)";
  800931:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  800936:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093a:	7e 37                	jle    800973 <vprintfmt+0x1ec>
  80093c:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800940:	74 31                	je     800973 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800942:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	89 34 24             	mov    %esi,(%esp)
  80094c:	e8 39 03 00 00       	call   800c8a <strnlen>
  800951:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800954:	eb 17                	jmp    80096d <vprintfmt+0x1e6>
					putch(padc, putdat);
  800956:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800961:	89 04 24             	mov    %eax,(%esp)
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800969:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80096d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800971:	7f e3                	jg     800956 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800973:	eb 38                	jmp    8009ad <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800975:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800979:	74 1f                	je     80099a <vprintfmt+0x213>
  80097b:	83 fb 1f             	cmp    $0x1f,%ebx
  80097e:	7e 05                	jle    800985 <vprintfmt+0x1fe>
  800980:	83 fb 7e             	cmp    $0x7e,%ebx
  800983:	7e 15                	jle    80099a <vprintfmt+0x213>
					putch('?', putdat);
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	ff d0                	call   *%eax
  800998:	eb 0f                	jmp    8009a9 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a1:	89 1c 24             	mov    %ebx,(%esp)
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009a9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009ad:	89 f0                	mov    %esi,%eax
  8009af:	8d 70 01             	lea    0x1(%eax),%esi
  8009b2:	0f b6 00             	movzbl (%eax),%eax
  8009b5:	0f be d8             	movsbl %al,%ebx
  8009b8:	85 db                	test   %ebx,%ebx
  8009ba:	74 10                	je     8009cc <vprintfmt+0x245>
  8009bc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009c0:	78 b3                	js     800975 <vprintfmt+0x1ee>
  8009c2:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009ca:	79 a9                	jns    800975 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009cc:	eb 17                	jmp    8009e5 <vprintfmt+0x25e>
				putch(' ', putdat);
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009e9:	7f e3                	jg     8009ce <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009eb:	e9 70 01 00 00       	jmp    800b60 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fa:	89 04 24             	mov    %eax,(%esp)
  8009fd:	e8 3e fd ff ff       	call   800740 <getint>
  800a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a05:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a0e:	85 d2                	test   %edx,%edx
  800a10:	79 26                	jns    800a38 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	ff d0                	call   *%eax
				num = -(long long) num;
  800a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a2b:	f7 d8                	neg    %eax
  800a2d:	83 d2 00             	adc    $0x0,%edx
  800a30:	f7 da                	neg    %edx
  800a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a35:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a3f:	e9 a8 00 00 00       	jmp    800aec <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a44:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4e:	89 04 24             	mov    %eax,(%esp)
  800a51:	e8 9b fc ff ff       	call   8006f1 <getuint>
  800a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a59:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a5c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a63:	e9 84 00 00 00       	jmp    800aec <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a72:	89 04 24             	mov    %eax,(%esp)
  800a75:	e8 77 fc ff ff       	call   8006f1 <getuint>
  800a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a7d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a80:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a87:	eb 63                	jmp    800aec <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	ff d0                	call   *%eax
			putch('x', putdat);
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab2:	8d 50 04             	lea    0x4(%eax),%edx
  800ab5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab8:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800aba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ac4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800acb:	eb 1f                	jmp    800aec <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800acd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad7:	89 04 24             	mov    %eax,(%esp)
  800ada:	e8 12 fc ff ff       	call   8006f1 <getuint>
  800adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ae2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800ae5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aec:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800af3:	89 54 24 18          	mov    %edx,0x18(%esp)
  800af7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800afa:	89 54 24 14          	mov    %edx,0x14(%esp)
  800afe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	89 04 24             	mov    %eax,(%esp)
  800b1d:	e8 f1 fa ff ff       	call   800613 <printnum>
			break;
  800b22:	eb 3c                	jmp    800b60 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2b:	89 1c 24             	mov    %ebx,(%esp)
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	ff d0                	call   *%eax
			break;
  800b33:	eb 2b                	jmp    800b60 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b4c:	eb 04                	jmp    800b52 <vprintfmt+0x3cb>
  800b4e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b52:	8b 45 10             	mov    0x10(%ebp),%eax
  800b55:	83 e8 01             	sub    $0x1,%eax
  800b58:	0f b6 00             	movzbl (%eax),%eax
  800b5b:	3c 25                	cmp    $0x25,%al
  800b5d:	75 ef                	jne    800b4e <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b5f:	90                   	nop
		}
	}
  800b60:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b61:	e9 43 fc ff ff       	jmp    8007a9 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b66:	83 c4 40             	add    $0x40,%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b73:	8d 45 14             	lea    0x14(%ebp),%eax
  800b76:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b80:	8b 45 10             	mov    0x10(%ebp),%eax
  800b83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	89 04 24             	mov    %eax,(%esp)
  800b94:	e8 ee fb ff ff       	call   800787 <vprintfmt>
	va_end(ap);
}
  800b99:	c9                   	leave  
  800b9a:	c3                   	ret    

00800b9b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba1:	8b 40 08             	mov    0x8(%eax),%eax
  800ba4:	8d 50 01             	lea    0x1(%eax),%edx
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb0:	8b 10                	mov    (%eax),%edx
  800bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb5:	8b 40 04             	mov    0x4(%eax),%eax
  800bb8:	39 c2                	cmp    %eax,%edx
  800bba:	73 12                	jae    800bce <sprintputch+0x33>
		*b->buf++ = ch;
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	8b 00                	mov    (%eax),%eax
  800bc1:	8d 48 01             	lea    0x1(%eax),%ecx
  800bc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc7:	89 0a                	mov    %ecx,(%edx)
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	88 10                	mov    %dl,(%eax)
}
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdf:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	01 d0                	add    %edx,%eax
  800be7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bf5:	74 06                	je     800bfd <vsnprintf+0x2d>
  800bf7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfb:	7f 07                	jg     800c04 <vsnprintf+0x34>
		return -E_INVAL;
  800bfd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c02:	eb 2a                	jmp    800c2e <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c04:	8b 45 14             	mov    0x14(%ebp),%eax
  800c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c12:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	c7 04 24 9b 0b 80 00 	movl   $0x800b9b,(%esp)
  800c20:	e8 62 fb ff ff       	call   800787 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c25:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c28:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c36:	8d 45 14             	lea    0x14(%ebp),%eax
  800c39:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c43:	8b 45 10             	mov    0x10(%ebp),%eax
  800c46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	89 04 24             	mov    %eax,(%esp)
  800c57:	e8 74 ff ff ff       	call   800bd0 <vsnprintf>
  800c5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c71:	eb 08                	jmp    800c7b <strlen+0x17>
		n++;
  800c73:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	0f b6 00             	movzbl (%eax),%eax
  800c81:	84 c0                	test   %al,%al
  800c83:	75 ee                	jne    800c73 <strlen+0xf>
		n++;
	return n;
  800c85:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c90:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c97:	eb 0c                	jmp    800ca5 <strnlen+0x1b>
		n++;
  800c99:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca1:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca9:	74 0a                	je     800cb5 <strnlen+0x2b>
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	0f b6 00             	movzbl (%eax),%eax
  800cb1:	84 c0                	test   %al,%al
  800cb3:	75 e4                	jne    800c99 <strnlen+0xf>
		n++;
	return n;
  800cb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800cc6:	90                   	nop
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	8d 50 01             	lea    0x1(%eax),%edx
  800ccd:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd3:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cd6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cd9:	0f b6 12             	movzbl (%edx),%edx
  800cdc:	88 10                	mov    %dl,(%eax)
  800cde:	0f b6 00             	movzbl (%eax),%eax
  800ce1:	84 c0                	test   %al,%al
  800ce3:	75 e2                	jne    800cc7 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ce5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    

00800cea <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	89 04 24             	mov    %eax,(%esp)
  800cf6:	e8 69 ff ff ff       	call   800c64 <strlen>
  800cfb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cfe:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	01 c2                	add    %eax,%edx
  800d06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d0d:	89 14 24             	mov    %edx,(%esp)
  800d10:	e8 a5 ff ff ff       	call   800cba <strcpy>
	return dst;
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d26:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d2d:	eb 23                	jmp    800d52 <strncpy+0x38>
		*dst++ = *src;
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	8d 50 01             	lea    0x1(%eax),%edx
  800d35:	89 55 08             	mov    %edx,0x8(%ebp)
  800d38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3b:	0f b6 12             	movzbl (%edx),%edx
  800d3e:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d43:	0f b6 00             	movzbl (%eax),%eax
  800d46:	84 c0                	test   %al,%al
  800d48:	74 04                	je     800d4e <strncpy+0x34>
			src++;
  800d4a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d55:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d58:	72 d5                	jb     800d2f <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d6b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d6f:	74 33                	je     800da4 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d71:	eb 17                	jmp    800d8a <strlcpy+0x2b>
			*dst++ = *src++;
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	8d 50 01             	lea    0x1(%eax),%edx
  800d79:	89 55 08             	mov    %edx,0x8(%ebp)
  800d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d82:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d85:	0f b6 12             	movzbl (%edx),%edx
  800d88:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d8a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d92:	74 0a                	je     800d9e <strlcpy+0x3f>
  800d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	84 c0                	test   %al,%al
  800d9c:	75 d5                	jne    800d73 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800daa:	29 c2                	sub    %eax,%edx
  800dac:	89 d0                	mov    %edx,%eax
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800db3:	eb 08                	jmp    800dbd <strcmp+0xd>
		p++, q++;
  800db5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	0f b6 00             	movzbl (%eax),%eax
  800dc3:	84 c0                	test   %al,%al
  800dc5:	74 10                	je     800dd7 <strcmp+0x27>
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	0f b6 10             	movzbl (%eax),%edx
  800dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd0:	0f b6 00             	movzbl (%eax),%eax
  800dd3:	38 c2                	cmp    %al,%dl
  800dd5:	74 de                	je     800db5 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	0f b6 00             	movzbl (%eax),%eax
  800ddd:	0f b6 d0             	movzbl %al,%edx
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	0f b6 c0             	movzbl %al,%eax
  800de9:	29 c2                	sub    %eax,%edx
  800deb:	89 d0                	mov    %edx,%eax
}
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800df2:	eb 0c                	jmp    800e00 <strncmp+0x11>
		n--, p++, q++;
  800df4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800df8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dfc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e04:	74 1a                	je     800e20 <strncmp+0x31>
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	0f b6 00             	movzbl (%eax),%eax
  800e0c:	84 c0                	test   %al,%al
  800e0e:	74 10                	je     800e20 <strncmp+0x31>
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	0f b6 10             	movzbl (%eax),%edx
  800e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e19:	0f b6 00             	movzbl (%eax),%eax
  800e1c:	38 c2                	cmp    %al,%dl
  800e1e:	74 d4                	je     800df4 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e24:	75 07                	jne    800e2d <strncmp+0x3e>
		return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2b:	eb 16                	jmp    800e43 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 00             	movzbl (%eax),%eax
  800e33:	0f b6 d0             	movzbl %al,%edx
  800e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e39:	0f b6 00             	movzbl (%eax),%eax
  800e3c:	0f b6 c0             	movzbl %al,%eax
  800e3f:	29 c2                	sub    %eax,%edx
  800e41:	89 d0                	mov    %edx,%eax
}
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e51:	eb 14                	jmp    800e67 <strchr+0x22>
		if (*s == c)
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e5c:	75 05                	jne    800e63 <strchr+0x1e>
			return (char *) s;
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	eb 13                	jmp    800e76 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e63:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	0f b6 00             	movzbl (%eax),%eax
  800e6d:	84 c0                	test   %al,%al
  800e6f:	75 e2                	jne    800e53 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 04             	sub    $0x4,%esp
  800e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e81:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e84:	eb 11                	jmp    800e97 <strfind+0x1f>
		if (*s == c)
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	0f b6 00             	movzbl (%eax),%eax
  800e8c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e8f:	75 02                	jne    800e93 <strfind+0x1b>
			break;
  800e91:	eb 0e                	jmp    800ea1 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	0f b6 00             	movzbl (%eax),%eax
  800e9d:	84 c0                	test   %al,%al
  800e9f:	75 e5                	jne    800e86 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
	char *p;

	if (n == 0)
  800eaa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eae:	75 05                	jne    800eb5 <memset+0xf>
		return v;
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	eb 5c                	jmp    800f11 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	83 e0 03             	and    $0x3,%eax
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	75 41                	jne    800f00 <memset+0x5a>
  800ebf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec2:	83 e0 03             	and    $0x3,%eax
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	75 37                	jne    800f00 <memset+0x5a>
		c &= 0xFF;
  800ec9:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	c1 e0 18             	shl    $0x18,%eax
  800ed6:	89 c2                	mov    %eax,%edx
  800ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edb:	c1 e0 10             	shl    $0x10,%eax
  800ede:	09 c2                	or     %eax,%edx
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	c1 e0 08             	shl    $0x8,%eax
  800ee6:	09 d0                	or     %edx,%eax
  800ee8:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800eee:	c1 e8 02             	shr    $0x2,%eax
  800ef1:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ef3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	89 d7                	mov    %edx,%edi
  800efb:	fc                   	cld    
  800efc:	f3 ab                	rep stos %eax,%es:(%edi)
  800efe:	eb 0e                	jmp    800f0e <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f00:	8b 55 08             	mov    0x8(%ebp),%edx
  800f03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f06:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f09:	89 d7                	mov    %edx,%edi
  800f0b:	fc                   	cld    
  800f0c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f2f:	73 6d                	jae    800f9e <memmove+0x8a>
  800f31:	8b 45 10             	mov    0x10(%ebp),%eax
  800f34:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f37:	01 d0                	add    %edx,%eax
  800f39:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f3c:	76 60                	jbe    800f9e <memmove+0x8a>
		s += n;
  800f3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f41:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f44:	8b 45 10             	mov    0x10(%ebp),%eax
  800f47:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4d:	83 e0 03             	and    $0x3,%eax
  800f50:	85 c0                	test   %eax,%eax
  800f52:	75 2f                	jne    800f83 <memmove+0x6f>
  800f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f57:	83 e0 03             	and    $0x3,%eax
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	75 25                	jne    800f83 <memmove+0x6f>
  800f5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f61:	83 e0 03             	and    $0x3,%eax
  800f64:	85 c0                	test   %eax,%eax
  800f66:	75 1b                	jne    800f83 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6b:	83 e8 04             	sub    $0x4,%eax
  800f6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f71:	83 ea 04             	sub    $0x4,%edx
  800f74:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f7a:	89 c7                	mov    %eax,%edi
  800f7c:	89 d6                	mov    %edx,%esi
  800f7e:	fd                   	std    
  800f7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f81:	eb 18                	jmp    800f9b <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f86:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f8c:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f92:	89 d7                	mov    %edx,%edi
  800f94:	89 de                	mov    %ebx,%esi
  800f96:	89 c1                	mov    %eax,%ecx
  800f98:	fd                   	std    
  800f99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f9b:	fc                   	cld    
  800f9c:	eb 45                	jmp    800fe3 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa1:	83 e0 03             	and    $0x3,%eax
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	75 2b                	jne    800fd3 <memmove+0xbf>
  800fa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fab:	83 e0 03             	and    $0x3,%eax
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	75 21                	jne    800fd3 <memmove+0xbf>
  800fb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb5:	83 e0 03             	and    $0x3,%eax
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	75 17                	jne    800fd3 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbf:	c1 e8 02             	shr    $0x2,%eax
  800fc2:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fca:	89 c7                	mov    %eax,%edi
  800fcc:	89 d6                	mov    %edx,%esi
  800fce:	fc                   	cld    
  800fcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd1:	eb 10                	jmp    800fe3 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	89 d6                	mov    %edx,%esi
  800fe0:	fc                   	cld    
  800fe1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ff4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	89 04 24             	mov    %eax,(%esp)
  801008:	e8 07 ff ff ff       	call   800f14 <memmove>
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80100f:	55                   	push   %ebp
  801010:	89 e5                	mov    %esp,%ebp
  801012:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801021:	eb 30                	jmp    801053 <memcmp+0x44>
		if (*s1 != *s2)
  801023:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801026:	0f b6 10             	movzbl (%eax),%edx
  801029:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80102c:	0f b6 00             	movzbl (%eax),%eax
  80102f:	38 c2                	cmp    %al,%dl
  801031:	74 18                	je     80104b <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801033:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801036:	0f b6 00             	movzbl (%eax),%eax
  801039:	0f b6 d0             	movzbl %al,%edx
  80103c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80103f:	0f b6 00             	movzbl (%eax),%eax
  801042:	0f b6 c0             	movzbl %al,%eax
  801045:	29 c2                	sub    %eax,%edx
  801047:	89 d0                	mov    %edx,%eax
  801049:	eb 1a                	jmp    801065 <memcmp+0x56>
		s1++, s2++;
  80104b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80104f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801053:	8b 45 10             	mov    0x10(%ebp),%eax
  801056:	8d 50 ff             	lea    -0x1(%eax),%edx
  801059:	89 55 10             	mov    %edx,0x10(%ebp)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	75 c3                	jne    801023 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80106d:	8b 45 10             	mov    0x10(%ebp),%eax
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	01 d0                	add    %edx,%eax
  801075:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801078:	eb 13                	jmp    80108d <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	0f b6 10             	movzbl (%eax),%edx
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	38 c2                	cmp    %al,%dl
  801085:	75 02                	jne    801089 <memfind+0x22>
			break;
  801087:	eb 0c                	jmp    801095 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801089:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801093:	72 e5                	jb     80107a <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010a0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010a7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ae:	eb 04                	jmp    8010b4 <strtol+0x1a>
		s++;
  8010b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	0f b6 00             	movzbl (%eax),%eax
  8010ba:	3c 20                	cmp    $0x20,%al
  8010bc:	74 f2                	je     8010b0 <strtol+0x16>
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	0f b6 00             	movzbl (%eax),%eax
  8010c4:	3c 09                	cmp    $0x9,%al
  8010c6:	74 e8                	je     8010b0 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	0f b6 00             	movzbl (%eax),%eax
  8010ce:	3c 2b                	cmp    $0x2b,%al
  8010d0:	75 06                	jne    8010d8 <strtol+0x3e>
		s++;
  8010d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010d6:	eb 15                	jmp    8010ed <strtol+0x53>
	else if (*s == '-')
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	0f b6 00             	movzbl (%eax),%eax
  8010de:	3c 2d                	cmp    $0x2d,%al
  8010e0:	75 0b                	jne    8010ed <strtol+0x53>
		s++, neg = 1;
  8010e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010e6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010f1:	74 06                	je     8010f9 <strtol+0x5f>
  8010f3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010f7:	75 24                	jne    80111d <strtol+0x83>
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	0f b6 00             	movzbl (%eax),%eax
  8010ff:	3c 30                	cmp    $0x30,%al
  801101:	75 1a                	jne    80111d <strtol+0x83>
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	83 c0 01             	add    $0x1,%eax
  801109:	0f b6 00             	movzbl (%eax),%eax
  80110c:	3c 78                	cmp    $0x78,%al
  80110e:	75 0d                	jne    80111d <strtol+0x83>
		s += 2, base = 16;
  801110:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801114:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80111b:	eb 2a                	jmp    801147 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80111d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801121:	75 17                	jne    80113a <strtol+0xa0>
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
  801126:	0f b6 00             	movzbl (%eax),%eax
  801129:	3c 30                	cmp    $0x30,%al
  80112b:	75 0d                	jne    80113a <strtol+0xa0>
		s++, base = 8;
  80112d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801131:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801138:	eb 0d                	jmp    801147 <strtol+0xad>
	else if (base == 0)
  80113a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80113e:	75 07                	jne    801147 <strtol+0xad>
		base = 10;
  801140:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
  80114a:	0f b6 00             	movzbl (%eax),%eax
  80114d:	3c 2f                	cmp    $0x2f,%al
  80114f:	7e 1b                	jle    80116c <strtol+0xd2>
  801151:	8b 45 08             	mov    0x8(%ebp),%eax
  801154:	0f b6 00             	movzbl (%eax),%eax
  801157:	3c 39                	cmp    $0x39,%al
  801159:	7f 11                	jg     80116c <strtol+0xd2>
			dig = *s - '0';
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	0f b6 00             	movzbl (%eax),%eax
  801161:	0f be c0             	movsbl %al,%eax
  801164:	83 e8 30             	sub    $0x30,%eax
  801167:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80116a:	eb 48                	jmp    8011b4 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  80116c:	8b 45 08             	mov    0x8(%ebp),%eax
  80116f:	0f b6 00             	movzbl (%eax),%eax
  801172:	3c 60                	cmp    $0x60,%al
  801174:	7e 1b                	jle    801191 <strtol+0xf7>
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	0f b6 00             	movzbl (%eax),%eax
  80117c:	3c 7a                	cmp    $0x7a,%al
  80117e:	7f 11                	jg     801191 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	0f b6 00             	movzbl (%eax),%eax
  801186:	0f be c0             	movsbl %al,%eax
  801189:	83 e8 57             	sub    $0x57,%eax
  80118c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80118f:	eb 23                	jmp    8011b4 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	0f b6 00             	movzbl (%eax),%eax
  801197:	3c 40                	cmp    $0x40,%al
  801199:	7e 3d                	jle    8011d8 <strtol+0x13e>
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	0f b6 00             	movzbl (%eax),%eax
  8011a1:	3c 5a                	cmp    $0x5a,%al
  8011a3:	7f 33                	jg     8011d8 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a8:	0f b6 00             	movzbl (%eax),%eax
  8011ab:	0f be c0             	movsbl %al,%eax
  8011ae:	83 e8 37             	sub    $0x37,%eax
  8011b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b7:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011ba:	7c 02                	jl     8011be <strtol+0x124>
			break;
  8011bc:	eb 1a                	jmp    8011d8 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011c5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	01 d0                	add    %edx,%eax
  8011d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011d3:	e9 6f ff ff ff       	jmp    801147 <strtol+0xad>

	if (endptr)
  8011d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011dc:	74 08                	je     8011e6 <strtol+0x14c>
		*endptr = (char *) s;
  8011de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011e6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011ea:	74 07                	je     8011f3 <strtol+0x159>
  8011ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011ef:	f7 d8                	neg    %eax
  8011f1:	eb 03                	jmp    8011f6 <strtol+0x15c>
  8011f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    
  8011f8:	66 90                	xchg   %ax,%ax
  8011fa:	66 90                	xchg   %ax,%ax
  8011fc:	66 90                	xchg   %ax,%ax
  8011fe:	66 90                	xchg   %ax,%ax

00801200 <__udivdi3>:
  801200:	55                   	push   %ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	8b 44 24 28          	mov    0x28(%esp),%eax
  80120a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80120e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801212:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801216:	85 c0                	test   %eax,%eax
  801218:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80121c:	89 ea                	mov    %ebp,%edx
  80121e:	89 0c 24             	mov    %ecx,(%esp)
  801221:	75 2d                	jne    801250 <__udivdi3+0x50>
  801223:	39 e9                	cmp    %ebp,%ecx
  801225:	77 61                	ja     801288 <__udivdi3+0x88>
  801227:	85 c9                	test   %ecx,%ecx
  801229:	89 ce                	mov    %ecx,%esi
  80122b:	75 0b                	jne    801238 <__udivdi3+0x38>
  80122d:	b8 01 00 00 00       	mov    $0x1,%eax
  801232:	31 d2                	xor    %edx,%edx
  801234:	f7 f1                	div    %ecx
  801236:	89 c6                	mov    %eax,%esi
  801238:	31 d2                	xor    %edx,%edx
  80123a:	89 e8                	mov    %ebp,%eax
  80123c:	f7 f6                	div    %esi
  80123e:	89 c5                	mov    %eax,%ebp
  801240:	89 f8                	mov    %edi,%eax
  801242:	f7 f6                	div    %esi
  801244:	89 ea                	mov    %ebp,%edx
  801246:	83 c4 0c             	add    $0xc,%esp
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    
  80124d:	8d 76 00             	lea    0x0(%esi),%esi
  801250:	39 e8                	cmp    %ebp,%eax
  801252:	77 24                	ja     801278 <__udivdi3+0x78>
  801254:	0f bd e8             	bsr    %eax,%ebp
  801257:	83 f5 1f             	xor    $0x1f,%ebp
  80125a:	75 3c                	jne    801298 <__udivdi3+0x98>
  80125c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801260:	39 34 24             	cmp    %esi,(%esp)
  801263:	0f 86 9f 00 00 00    	jbe    801308 <__udivdi3+0x108>
  801269:	39 d0                	cmp    %edx,%eax
  80126b:	0f 82 97 00 00 00    	jb     801308 <__udivdi3+0x108>
  801271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801278:	31 d2                	xor    %edx,%edx
  80127a:	31 c0                	xor    %eax,%eax
  80127c:	83 c4 0c             	add    $0xc,%esp
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    
  801283:	90                   	nop
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	89 f8                	mov    %edi,%eax
  80128a:	f7 f1                	div    %ecx
  80128c:	31 d2                	xor    %edx,%edx
  80128e:	83 c4 0c             	add    $0xc,%esp
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	89 e9                	mov    %ebp,%ecx
  80129a:	8b 3c 24             	mov    (%esp),%edi
  80129d:	d3 e0                	shl    %cl,%eax
  80129f:	89 c6                	mov    %eax,%esi
  8012a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012a6:	29 e8                	sub    %ebp,%eax
  8012a8:	89 c1                	mov    %eax,%ecx
  8012aa:	d3 ef                	shr    %cl,%edi
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012b2:	8b 3c 24             	mov    (%esp),%edi
  8012b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012b9:	89 d6                	mov    %edx,%esi
  8012bb:	d3 e7                	shl    %cl,%edi
  8012bd:	89 c1                	mov    %eax,%ecx
  8012bf:	89 3c 24             	mov    %edi,(%esp)
  8012c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012c6:	d3 ee                	shr    %cl,%esi
  8012c8:	89 e9                	mov    %ebp,%ecx
  8012ca:	d3 e2                	shl    %cl,%edx
  8012cc:	89 c1                	mov    %eax,%ecx
  8012ce:	d3 ef                	shr    %cl,%edi
  8012d0:	09 d7                	or     %edx,%edi
  8012d2:	89 f2                	mov    %esi,%edx
  8012d4:	89 f8                	mov    %edi,%eax
  8012d6:	f7 74 24 08          	divl   0x8(%esp)
  8012da:	89 d6                	mov    %edx,%esi
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	f7 24 24             	mull   (%esp)
  8012e1:	39 d6                	cmp    %edx,%esi
  8012e3:	89 14 24             	mov    %edx,(%esp)
  8012e6:	72 30                	jb     801318 <__udivdi3+0x118>
  8012e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012ec:	89 e9                	mov    %ebp,%ecx
  8012ee:	d3 e2                	shl    %cl,%edx
  8012f0:	39 c2                	cmp    %eax,%edx
  8012f2:	73 05                	jae    8012f9 <__udivdi3+0xf9>
  8012f4:	3b 34 24             	cmp    (%esp),%esi
  8012f7:	74 1f                	je     801318 <__udivdi3+0x118>
  8012f9:	89 f8                	mov    %edi,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	e9 7a ff ff ff       	jmp    80127c <__udivdi3+0x7c>
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	31 d2                	xor    %edx,%edx
  80130a:	b8 01 00 00 00       	mov    $0x1,%eax
  80130f:	e9 68 ff ff ff       	jmp    80127c <__udivdi3+0x7c>
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	8d 47 ff             	lea    -0x1(%edi),%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	83 c4 0c             	add    $0xc,%esp
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    
  801324:	66 90                	xchg   %ax,%ax
  801326:	66 90                	xchg   %ax,%ax
  801328:	66 90                	xchg   %ax,%ax
  80132a:	66 90                	xchg   %ax,%ax
  80132c:	66 90                	xchg   %ax,%ax
  80132e:	66 90                	xchg   %ax,%ax

00801330 <__umoddi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	83 ec 14             	sub    $0x14,%esp
  801336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80133a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80133e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801342:	89 c7                	mov    %eax,%edi
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	8b 44 24 30          	mov    0x30(%esp),%eax
  80134c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801350:	89 34 24             	mov    %esi,(%esp)
  801353:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801357:	85 c0                	test   %eax,%eax
  801359:	89 c2                	mov    %eax,%edx
  80135b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135f:	75 17                	jne    801378 <__umoddi3+0x48>
  801361:	39 fe                	cmp    %edi,%esi
  801363:	76 4b                	jbe    8013b0 <__umoddi3+0x80>
  801365:	89 c8                	mov    %ecx,%eax
  801367:	89 fa                	mov    %edi,%edx
  801369:	f7 f6                	div    %esi
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	31 d2                	xor    %edx,%edx
  80136f:	83 c4 14             	add    $0x14,%esp
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    
  801376:	66 90                	xchg   %ax,%ax
  801378:	39 f8                	cmp    %edi,%eax
  80137a:	77 54                	ja     8013d0 <__umoddi3+0xa0>
  80137c:	0f bd e8             	bsr    %eax,%ebp
  80137f:	83 f5 1f             	xor    $0x1f,%ebp
  801382:	75 5c                	jne    8013e0 <__umoddi3+0xb0>
  801384:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801388:	39 3c 24             	cmp    %edi,(%esp)
  80138b:	0f 87 e7 00 00 00    	ja     801478 <__umoddi3+0x148>
  801391:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801395:	29 f1                	sub    %esi,%ecx
  801397:	19 c7                	sbb    %eax,%edi
  801399:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013a9:	83 c4 14             	add    $0x14,%esp
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    
  8013b0:	85 f6                	test   %esi,%esi
  8013b2:	89 f5                	mov    %esi,%ebp
  8013b4:	75 0b                	jne    8013c1 <__umoddi3+0x91>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f6                	div    %esi
  8013bf:	89 c5                	mov    %eax,%ebp
  8013c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013c5:	31 d2                	xor    %edx,%edx
  8013c7:	f7 f5                	div    %ebp
  8013c9:	89 c8                	mov    %ecx,%eax
  8013cb:	f7 f5                	div    %ebp
  8013cd:	eb 9c                	jmp    80136b <__umoddi3+0x3b>
  8013cf:	90                   	nop
  8013d0:	89 c8                	mov    %ecx,%eax
  8013d2:	89 fa                	mov    %edi,%edx
  8013d4:	83 c4 14             	add    $0x14,%esp
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    
  8013db:	90                   	nop
  8013dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	8b 04 24             	mov    (%esp),%eax
  8013e3:	be 20 00 00 00       	mov    $0x20,%esi
  8013e8:	89 e9                	mov    %ebp,%ecx
  8013ea:	29 ee                	sub    %ebp,%esi
  8013ec:	d3 e2                	shl    %cl,%edx
  8013ee:	89 f1                	mov    %esi,%ecx
  8013f0:	d3 e8                	shr    %cl,%eax
  8013f2:	89 e9                	mov    %ebp,%ecx
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	8b 04 24             	mov    (%esp),%eax
  8013fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013ff:	89 fa                	mov    %edi,%edx
  801401:	d3 e0                	shl    %cl,%eax
  801403:	89 f1                	mov    %esi,%ecx
  801405:	89 44 24 08          	mov    %eax,0x8(%esp)
  801409:	8b 44 24 10          	mov    0x10(%esp),%eax
  80140d:	d3 ea                	shr    %cl,%edx
  80140f:	89 e9                	mov    %ebp,%ecx
  801411:	d3 e7                	shl    %cl,%edi
  801413:	89 f1                	mov    %esi,%ecx
  801415:	d3 e8                	shr    %cl,%eax
  801417:	89 e9                	mov    %ebp,%ecx
  801419:	09 f8                	or     %edi,%eax
  80141b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80141f:	f7 74 24 04          	divl   0x4(%esp)
  801423:	d3 e7                	shl    %cl,%edi
  801425:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801429:	89 d7                	mov    %edx,%edi
  80142b:	f7 64 24 08          	mull   0x8(%esp)
  80142f:	39 d7                	cmp    %edx,%edi
  801431:	89 c1                	mov    %eax,%ecx
  801433:	89 14 24             	mov    %edx,(%esp)
  801436:	72 2c                	jb     801464 <__umoddi3+0x134>
  801438:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80143c:	72 22                	jb     801460 <__umoddi3+0x130>
  80143e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801442:	29 c8                	sub    %ecx,%eax
  801444:	19 d7                	sbb    %edx,%edi
  801446:	89 e9                	mov    %ebp,%ecx
  801448:	89 fa                	mov    %edi,%edx
  80144a:	d3 e8                	shr    %cl,%eax
  80144c:	89 f1                	mov    %esi,%ecx
  80144e:	d3 e2                	shl    %cl,%edx
  801450:	89 e9                	mov    %ebp,%ecx
  801452:	d3 ef                	shr    %cl,%edi
  801454:	09 d0                	or     %edx,%eax
  801456:	89 fa                	mov    %edi,%edx
  801458:	83 c4 14             	add    $0x14,%esp
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
  80145f:	90                   	nop
  801460:	39 d7                	cmp    %edx,%edi
  801462:	75 da                	jne    80143e <__umoddi3+0x10e>
  801464:	8b 14 24             	mov    (%esp),%edx
  801467:	89 c1                	mov    %eax,%ecx
  801469:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80146d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801471:	eb cb                	jmp    80143e <__umoddi3+0x10e>
  801473:	90                   	nop
  801474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801478:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80147c:	0f 82 0f ff ff ff    	jb     801391 <__umoddi3+0x61>
  801482:	e9 1a ff ff ff       	jmp    8013a1 <__umoddi3+0x71>
