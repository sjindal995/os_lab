
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
  800103:	c7 44 24 08 ea 14 80 	movl   $0x8014ea,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 07 15 80 00 	movl   $0x801507,(%esp)
  80011a:	e8 f7 03 00 00       	call   800516 <_panic>

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
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    

008004d2 <sys_guest>:

void sys_guest(){
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004d8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004df:	00 
  8004e0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004e7:	00 
  8004e8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004ff:	00 
  800500:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800507:	00 
  800508:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  80050f:	e8 b5 fb ff ff       	call   8000c9 <syscall>
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
  800520:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800523:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800529:	e8 c5 fc ff ff       	call   8001f3 <sys_getenvid>
  80052e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800531:	89 54 24 10          	mov    %edx,0x10(%esp)
  800535:	8b 55 08             	mov    0x8(%ebp),%edx
  800538:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800540:	89 44 24 04          	mov    %eax,0x4(%esp)
  800544:	c7 04 24 18 15 80 00 	movl   $0x801518,(%esp)
  80054b:	e8 e1 00 00 00       	call   800631 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800550:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800553:	89 44 24 04          	mov    %eax,0x4(%esp)
  800557:	8b 45 10             	mov    0x10(%ebp),%eax
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	e8 6b 00 00 00       	call   8005cd <vcprintf>
	cprintf("\n");
  800562:	c7 04 24 3b 15 80 00 	movl   $0x80153b,(%esp)
  800569:	e8 c3 00 00 00       	call   800631 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80056e:	cc                   	int3   
  80056f:	eb fd                	jmp    80056e <_panic+0x58>

00800571 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800571:	55                   	push   %ebp
  800572:	89 e5                	mov    %esp,%ebp
  800574:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800577:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	8d 48 01             	lea    0x1(%eax),%ecx
  80057f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800582:	89 0a                	mov    %ecx,(%edx)
  800584:	8b 55 08             	mov    0x8(%ebp),%edx
  800587:	89 d1                	mov    %edx,%ecx
  800589:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800590:	8b 45 0c             	mov    0xc(%ebp),%eax
  800593:	8b 00                	mov    (%eax),%eax
  800595:	3d ff 00 00 00       	cmp    $0xff,%eax
  80059a:	75 20                	jne    8005bc <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80059c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a4:	83 c2 08             	add    $0x8,%edx
  8005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ab:	89 14 24             	mov    %edx,(%esp)
  8005ae:	e8 77 fb ff ff       	call   80012a <sys_cputs>
		b->idx = 0;
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8005bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005bf:	8b 40 04             	mov    0x4(%eax),%eax
  8005c2:	8d 50 01             	lea    0x1(%eax),%edx
  8005c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c8:	89 50 04             	mov    %edx,0x4(%eax)
}
  8005cb:	c9                   	leave  
  8005cc:	c3                   	ret    

008005cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005cd:	55                   	push   %ebp
  8005ce:	89 e5                	mov    %esp,%ebp
  8005d0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005dd:	00 00 00 
	b.cnt = 0;
  8005e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800602:	c7 04 24 71 05 80 00 	movl   $0x800571,(%esp)
  800609:	e8 bd 01 00 00       	call   8007cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80060e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80061e:	83 c0 08             	add    $0x8,%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 01 fb ff ff       	call   80012a <sys_cputs>

	return b.cnt;
  800629:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    

00800631 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800637:	8d 45 0c             	lea    0xc(%ebp),%eax
  80063a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80063d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800640:	89 44 24 04          	mov    %eax,0x4(%esp)
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	e8 7e ff ff ff       	call   8005cd <vcprintf>
  80064f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800652:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	53                   	push   %ebx
  80065b:	83 ec 34             	sub    $0x34,%esp
  80065e:	8b 45 10             	mov    0x10(%ebp),%eax
  800661:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80066a:	8b 45 18             	mov    0x18(%ebp),%eax
  80066d:	ba 00 00 00 00       	mov    $0x0,%edx
  800672:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800675:	77 72                	ja     8006e9 <printnum+0x92>
  800677:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80067a:	72 05                	jb     800681 <printnum+0x2a>
  80067c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80067f:	77 68                	ja     8006e9 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800681:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800684:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800687:	8b 45 18             	mov    0x18(%ebp),%eax
  80068a:	ba 00 00 00 00       	mov    $0x0,%edx
  80068f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a4:	e8 97 0b 00 00       	call   801240 <__udivdi3>
  8006a9:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8006ac:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8006b0:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8006b4:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006b7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 82 ff ff ff       	call   800657 <printnum>
  8006d5:	eb 1c                	jmp    8006f3 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006de:	8b 45 20             	mov    0x20(%ebp),%eax
  8006e1:	89 04 24             	mov    %eax,(%esp)
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006e9:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006ed:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006f1:	7f e4                	jg     8006d7 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006f3:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800701:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800705:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800709:	89 04 24             	mov    %eax,(%esp)
  80070c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800710:	e8 5b 0c 00 00       	call   801370 <__umoddi3>
  800715:	05 08 16 80 00       	add    $0x801608,%eax
  80071a:	0f b6 00             	movzbl (%eax),%eax
  80071d:	0f be c0             	movsbl %al,%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
  800723:	89 54 24 04          	mov    %edx,0x4(%esp)
  800727:	89 04 24             	mov    %eax,(%esp)
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
  80072d:	ff d0                	call   *%eax
}
  80072f:	83 c4 34             	add    $0x34,%esp
  800732:	5b                   	pop    %ebx
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800738:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80073c:	7e 14                	jle    800752 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	8b 00                	mov    (%eax),%eax
  800743:	8d 48 08             	lea    0x8(%eax),%ecx
  800746:	8b 55 08             	mov    0x8(%ebp),%edx
  800749:	89 0a                	mov    %ecx,(%edx)
  80074b:	8b 50 04             	mov    0x4(%eax),%edx
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	eb 30                	jmp    800782 <getuint+0x4d>
	else if (lflag)
  800752:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800756:	74 16                	je     80076e <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	8d 48 04             	lea    0x4(%eax),%ecx
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
  800763:	89 0a                	mov    %ecx,(%edx)
  800765:	8b 00                	mov    (%eax),%eax
  800767:	ba 00 00 00 00       	mov    $0x0,%edx
  80076c:	eb 14                	jmp    800782 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 00                	mov    (%eax),%eax
  800773:	8d 48 04             	lea    0x4(%eax),%ecx
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
  800779:	89 0a                	mov    %ecx,(%edx)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800787:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80078b:	7e 14                	jle    8007a1 <getint+0x1d>
		return va_arg(*ap, long long);
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	8b 00                	mov    (%eax),%eax
  800792:	8d 48 08             	lea    0x8(%eax),%ecx
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
  800798:	89 0a                	mov    %ecx,(%edx)
  80079a:	8b 50 04             	mov    0x4(%eax),%edx
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	eb 28                	jmp    8007c9 <getint+0x45>
	else if (lflag)
  8007a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007a5:	74 12                	je     8007b9 <getint+0x35>
		return va_arg(*ap, long);
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b2:	89 0a                	mov    %ecx,(%edx)
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	99                   	cltd   
  8007b7:	eb 10                	jmp    8007c9 <getint+0x45>
	else
		return va_arg(*ap, int);
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	8d 48 04             	lea    0x4(%eax),%ecx
  8007c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c4:	89 0a                	mov    %ecx,(%edx)
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	99                   	cltd   
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d3:	eb 18                	jmp    8007ed <vprintfmt+0x22>
			if (ch == '\0')
  8007d5:	85 db                	test   %ebx,%ebx
  8007d7:	75 05                	jne    8007de <vprintfmt+0x13>
				return;
  8007d9:	e9 cc 03 00 00       	jmp    800baa <vprintfmt+0x3df>
			putch(ch, putdat);
  8007de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e5:	89 1c 24             	mov    %ebx,(%esp)
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f0:	8d 50 01             	lea    0x1(%eax),%edx
  8007f3:	89 55 10             	mov    %edx,0x10(%ebp)
  8007f6:	0f b6 00             	movzbl (%eax),%eax
  8007f9:	0f b6 d8             	movzbl %al,%ebx
  8007fc:	83 fb 25             	cmp    $0x25,%ebx
  8007ff:	75 d4                	jne    8007d5 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800801:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800805:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80080c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800813:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80081a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800821:	8b 45 10             	mov    0x10(%ebp),%eax
  800824:	8d 50 01             	lea    0x1(%eax),%edx
  800827:	89 55 10             	mov    %edx,0x10(%ebp)
  80082a:	0f b6 00             	movzbl (%eax),%eax
  80082d:	0f b6 d8             	movzbl %al,%ebx
  800830:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800833:	83 f8 55             	cmp    $0x55,%eax
  800836:	0f 87 3d 03 00 00    	ja     800b79 <vprintfmt+0x3ae>
  80083c:	8b 04 85 2c 16 80 00 	mov    0x80162c(,%eax,4),%eax
  800843:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800845:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800849:	eb d6                	jmp    800821 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80084b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80084f:	eb d0                	jmp    800821 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800851:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800858:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	c1 e0 02             	shl    $0x2,%eax
  800860:	01 d0                	add    %edx,%eax
  800862:	01 c0                	add    %eax,%eax
  800864:	01 d8                	add    %ebx,%eax
  800866:	83 e8 30             	sub    $0x30,%eax
  800869:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80086c:	8b 45 10             	mov    0x10(%ebp),%eax
  80086f:	0f b6 00             	movzbl (%eax),%eax
  800872:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800875:	83 fb 2f             	cmp    $0x2f,%ebx
  800878:	7e 0b                	jle    800885 <vprintfmt+0xba>
  80087a:	83 fb 39             	cmp    $0x39,%ebx
  80087d:	7f 06                	jg     800885 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80087f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800883:	eb d3                	jmp    800858 <vprintfmt+0x8d>
			goto process_precision;
  800885:	eb 33                	jmp    8008ba <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8d 50 04             	lea    0x4(%eax),%edx
  80088d:	89 55 14             	mov    %edx,0x14(%ebp)
  800890:	8b 00                	mov    (%eax),%eax
  800892:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800895:	eb 23                	jmp    8008ba <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800897:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089b:	79 0c                	jns    8008a9 <vprintfmt+0xde>
				width = 0;
  80089d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8008a4:	e9 78 ff ff ff       	jmp    800821 <vprintfmt+0x56>
  8008a9:	e9 73 ff ff ff       	jmp    800821 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8008ae:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008b5:	e9 67 ff ff ff       	jmp    800821 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8008ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008be:	79 12                	jns    8008d2 <vprintfmt+0x107>
				width = precision, precision = -1;
  8008c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8008cd:	e9 4f ff ff ff       	jmp    800821 <vprintfmt+0x56>
  8008d2:	e9 4a ff ff ff       	jmp    800821 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008d7:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008db:	e9 41 ff ff ff       	jmp    800821 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 00                	mov    (%eax),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	ff d0                	call   *%eax
			break;
  8008fa:	e9 a5 02 00 00       	jmp    800ba4 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800902:	8d 50 04             	lea    0x4(%eax),%edx
  800905:	89 55 14             	mov    %edx,0x14(%ebp)
  800908:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80090a:	85 db                	test   %ebx,%ebx
  80090c:	79 02                	jns    800910 <vprintfmt+0x145>
				err = -err;
  80090e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800910:	83 fb 09             	cmp    $0x9,%ebx
  800913:	7f 0b                	jg     800920 <vprintfmt+0x155>
  800915:	8b 34 9d e0 15 80 00 	mov    0x8015e0(,%ebx,4),%esi
  80091c:	85 f6                	test   %esi,%esi
  80091e:	75 23                	jne    800943 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800920:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800924:	c7 44 24 08 19 16 80 	movl   $0x801619,0x8(%esp)
  80092b:	00 
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 73 02 00 00       	call   800bb1 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80093e:	e9 61 02 00 00       	jmp    800ba4 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800943:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800947:	c7 44 24 08 22 16 80 	movl   $0x801622,0x8(%esp)
  80094e:	00 
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	89 44 24 04          	mov    %eax,0x4(%esp)
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	89 04 24             	mov    %eax,(%esp)
  80095c:	e8 50 02 00 00       	call   800bb1 <printfmt>
			break;
  800961:	e9 3e 02 00 00       	jmp    800ba4 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8d 50 04             	lea    0x4(%eax),%edx
  80096c:	89 55 14             	mov    %edx,0x14(%ebp)
  80096f:	8b 30                	mov    (%eax),%esi
  800971:	85 f6                	test   %esi,%esi
  800973:	75 05                	jne    80097a <vprintfmt+0x1af>
				p = "(null)";
  800975:	be 25 16 80 00       	mov    $0x801625,%esi
			if (width > 0 && padc != '-')
  80097a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097e:	7e 37                	jle    8009b7 <vprintfmt+0x1ec>
  800980:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800984:	74 31                	je     8009b7 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800986:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800989:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098d:	89 34 24             	mov    %esi,(%esp)
  800990:	e8 39 03 00 00       	call   800cce <strnlen>
  800995:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800998:	eb 17                	jmp    8009b1 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80099a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a5:	89 04 24             	mov    %eax,(%esp)
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ad:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b5:	7f e3                	jg     80099a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b7:	eb 38                	jmp    8009f1 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8009b9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009bd:	74 1f                	je     8009de <vprintfmt+0x213>
  8009bf:	83 fb 1f             	cmp    $0x1f,%ebx
  8009c2:	7e 05                	jle    8009c9 <vprintfmt+0x1fe>
  8009c4:	83 fb 7e             	cmp    $0x7e,%ebx
  8009c7:	7e 15                	jle    8009de <vprintfmt+0x213>
					putch('?', putdat);
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	ff d0                	call   *%eax
  8009dc:	eb 0f                	jmp    8009ed <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e5:	89 1c 24             	mov    %ebx,(%esp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ed:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009f1:	89 f0                	mov    %esi,%eax
  8009f3:	8d 70 01             	lea    0x1(%eax),%esi
  8009f6:	0f b6 00             	movzbl (%eax),%eax
  8009f9:	0f be d8             	movsbl %al,%ebx
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	74 10                	je     800a10 <vprintfmt+0x245>
  800a00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a04:	78 b3                	js     8009b9 <vprintfmt+0x1ee>
  800a06:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800a0a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a0e:	79 a9                	jns    8009b9 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a10:	eb 17                	jmp    800a29 <vprintfmt+0x25e>
				putch(' ', putdat);
  800a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a25:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a29:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a2d:	7f e3                	jg     800a12 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800a2f:	e9 70 01 00 00       	jmp    800ba4 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a34:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3e:	89 04 24             	mov    %eax,(%esp)
  800a41:	e8 3e fd ff ff       	call   800784 <getint>
  800a46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a49:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a52:	85 d2                	test   %edx,%edx
  800a54:	79 26                	jns    800a7c <vprintfmt+0x2b1>
				putch('-', putdat);
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5d:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	ff d0                	call   *%eax
				num = -(long long) num;
  800a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a6f:	f7 d8                	neg    %eax
  800a71:	83 d2 00             	adc    $0x0,%edx
  800a74:	f7 da                	neg    %edx
  800a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a79:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a7c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a83:	e9 a8 00 00 00       	jmp    800b30 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a92:	89 04 24             	mov    %eax,(%esp)
  800a95:	e8 9b fc ff ff       	call   800735 <getuint>
  800a9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a9d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800aa0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800aa7:	e9 84 00 00 00       	jmp    800b30 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800aac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab3:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab6:	89 04 24             	mov    %eax,(%esp)
  800ab9:	e8 77 fc ff ff       	call   800735 <getuint>
  800abe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ac1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800ac4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800acb:	eb 63                	jmp    800b30 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800acd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	ff d0                	call   *%eax
			putch('x', putdat);
  800ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae7:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800af3:	8b 45 14             	mov    0x14(%ebp),%eax
  800af6:	8d 50 04             	lea    0x4(%eax),%edx
  800af9:	89 55 14             	mov    %edx,0x14(%ebp)
  800afc:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800afe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b08:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800b0f:	eb 1f                	jmp    800b30 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b11:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b18:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1b:	89 04 24             	mov    %eax,(%esp)
  800b1e:	e8 12 fc ff ff       	call   800735 <getuint>
  800b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b26:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800b29:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b30:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b34:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b37:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b3e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b50:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	89 04 24             	mov    %eax,(%esp)
  800b61:	e8 f1 fa ff ff       	call   800657 <printnum>
			break;
  800b66:	eb 3c                	jmp    800ba4 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6f:	89 1c 24             	mov    %ebx,(%esp)
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	ff d0                	call   *%eax
			break;
  800b77:	eb 2b                	jmp    800ba4 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b80:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b8c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b90:	eb 04                	jmp    800b96 <vprintfmt+0x3cb>
  800b92:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b96:	8b 45 10             	mov    0x10(%ebp),%eax
  800b99:	83 e8 01             	sub    $0x1,%eax
  800b9c:	0f b6 00             	movzbl (%eax),%eax
  800b9f:	3c 25                	cmp    $0x25,%al
  800ba1:	75 ef                	jne    800b92 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800ba3:	90                   	nop
		}
	}
  800ba4:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ba5:	e9 43 fc ff ff       	jmp    8007ed <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800baa:	83 c4 40             	add    $0x40,%esp
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800bb7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bba:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	89 04 24             	mov    %eax,(%esp)
  800bd8:	e8 ee fb ff ff       	call   8007cb <vprintfmt>
	va_end(ap);
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	8b 40 08             	mov    0x8(%eax),%eax
  800be8:	8d 50 01             	lea    0x1(%eax),%edx
  800beb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bee:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf4:	8b 10                	mov    (%eax),%edx
  800bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf9:	8b 40 04             	mov    0x4(%eax),%eax
  800bfc:	39 c2                	cmp    %eax,%edx
  800bfe:	73 12                	jae    800c12 <sprintputch+0x33>
		*b->buf++ = ch;
  800c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c03:	8b 00                	mov    (%eax),%eax
  800c05:	8d 48 01             	lea    0x1(%eax),%ecx
  800c08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0b:	89 0a                	mov    %ecx,(%edx)
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	88 10                	mov    %dl,(%eax)
}
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c23:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	01 d0                	add    %edx,%eax
  800c2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c39:	74 06                	je     800c41 <vsnprintf+0x2d>
  800c3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3f:	7f 07                	jg     800c48 <vsnprintf+0x34>
		return -E_INVAL;
  800c41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c46:	eb 2a                	jmp    800c72 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c48:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c56:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5d:	c7 04 24 df 0b 80 00 	movl   $0x800bdf,(%esp)
  800c64:	e8 62 fb ff ff       	call   8007cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c72:	c9                   	leave  
  800c73:	c3                   	ret    

00800c74 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c7a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c87:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 74 ff ff ff       	call   800c14 <vsnprintf>
  800ca0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800cae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cb5:	eb 08                	jmp    800cbf <strlen+0x17>
		n++;
  800cb7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	0f b6 00             	movzbl (%eax),%eax
  800cc5:	84 c0                	test   %al,%al
  800cc7:	75 ee                	jne    800cb7 <strlen+0xf>
		n++;
	return n;
  800cc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ccc:	c9                   	leave  
  800ccd:	c3                   	ret    

00800cce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cdb:	eb 0c                	jmp    800ce9 <strnlen+0x1b>
		n++;
  800cdd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ce5:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800ce9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ced:	74 0a                	je     800cf9 <strnlen+0x2b>
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	0f b6 00             	movzbl (%eax),%eax
  800cf5:	84 c0                	test   %al,%al
  800cf7:	75 e4                	jne    800cdd <strnlen+0xf>
		n++;
	return n;
  800cf9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    

00800cfe <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800d0a:	90                   	nop
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	8d 50 01             	lea    0x1(%eax),%edx
  800d11:	89 55 08             	mov    %edx,0x8(%ebp)
  800d14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d17:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d1a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d1d:	0f b6 12             	movzbl (%edx),%edx
  800d20:	88 10                	mov    %dl,(%eax)
  800d22:	0f b6 00             	movzbl (%eax),%eax
  800d25:	84 c0                	test   %al,%al
  800d27:	75 e2                	jne    800d0b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800d29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	89 04 24             	mov    %eax,(%esp)
  800d3a:	e8 69 ff ff ff       	call   800ca8 <strlen>
  800d3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d42:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	01 c2                	add    %eax,%edx
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d51:	89 14 24             	mov    %edx,(%esp)
  800d54:	e8 a5 ff ff ff       	call   800cfe <strcpy>
	return dst;
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    

00800d5e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d6a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d71:	eb 23                	jmp    800d96 <strncpy+0x38>
		*dst++ = *src;
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	8d 50 01             	lea    0x1(%eax),%edx
  800d79:	89 55 08             	mov    %edx,0x8(%ebp)
  800d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7f:	0f b6 12             	movzbl (%edx),%edx
  800d82:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d87:	0f b6 00             	movzbl (%eax),%eax
  800d8a:	84 c0                	test   %al,%al
  800d8c:	74 04                	je     800d92 <strncpy+0x34>
			src++;
  800d8e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d92:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d96:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d99:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d9c:	72 d5                	jb     800d73 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    

00800da3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800daf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db3:	74 33                	je     800de8 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800db5:	eb 17                	jmp    800dce <strlcpy+0x2b>
			*dst++ = *src++;
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dba:	8d 50 01             	lea    0x1(%eax),%edx
  800dbd:	89 55 08             	mov    %edx,0x8(%ebp)
  800dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc3:	8d 4a 01             	lea    0x1(%edx),%ecx
  800dc6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800dc9:	0f b6 12             	movzbl (%edx),%edx
  800dcc:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dce:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd6:	74 0a                	je     800de2 <strlcpy+0x3f>
  800dd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddb:	0f b6 00             	movzbl (%eax),%eax
  800dde:	84 c0                	test   %al,%al
  800de0:	75 d5                	jne    800db7 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dee:	29 c2                	sub    %eax,%edx
  800df0:	89 d0                	mov    %edx,%eax
}
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800df7:	eb 08                	jmp    800e01 <strcmp+0xd>
		p++, q++;
  800df9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dfd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	0f b6 00             	movzbl (%eax),%eax
  800e07:	84 c0                	test   %al,%al
  800e09:	74 10                	je     800e1b <strcmp+0x27>
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	0f b6 10             	movzbl (%eax),%edx
  800e11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e14:	0f b6 00             	movzbl (%eax),%eax
  800e17:	38 c2                	cmp    %al,%dl
  800e19:	74 de                	je     800df9 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	0f b6 00             	movzbl (%eax),%eax
  800e21:	0f b6 d0             	movzbl %al,%edx
  800e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e27:	0f b6 00             	movzbl (%eax),%eax
  800e2a:	0f b6 c0             	movzbl %al,%eax
  800e2d:	29 c2                	sub    %eax,%edx
  800e2f:	89 d0                	mov    %edx,%eax
}
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e36:	eb 0c                	jmp    800e44 <strncmp+0x11>
		n--, p++, q++;
  800e38:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e3c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e40:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e48:	74 1a                	je     800e64 <strncmp+0x31>
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	0f b6 00             	movzbl (%eax),%eax
  800e50:	84 c0                	test   %al,%al
  800e52:	74 10                	je     800e64 <strncmp+0x31>
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	0f b6 10             	movzbl (%eax),%edx
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	0f b6 00             	movzbl (%eax),%eax
  800e60:	38 c2                	cmp    %al,%dl
  800e62:	74 d4                	je     800e38 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e64:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e68:	75 07                	jne    800e71 <strncmp+0x3e>
		return 0;
  800e6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6f:	eb 16                	jmp    800e87 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	0f b6 00             	movzbl (%eax),%eax
  800e77:	0f b6 d0             	movzbl %al,%edx
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	0f b6 00             	movzbl (%eax),%eax
  800e80:	0f b6 c0             	movzbl %al,%eax
  800e83:	29 c2                	sub    %eax,%edx
  800e85:	89 d0                	mov    %edx,%eax
}
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e95:	eb 14                	jmp    800eab <strchr+0x22>
		if (*s == c)
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	0f b6 00             	movzbl (%eax),%eax
  800e9d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ea0:	75 05                	jne    800ea7 <strchr+0x1e>
			return (char *) s;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	eb 13                	jmp    800eba <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ea7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	0f b6 00             	movzbl (%eax),%eax
  800eb1:	84 c0                	test   %al,%al
  800eb3:	75 e2                	jne    800e97 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ec8:	eb 11                	jmp    800edb <strfind+0x1f>
		if (*s == c)
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecd:	0f b6 00             	movzbl (%eax),%eax
  800ed0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ed3:	75 02                	jne    800ed7 <strfind+0x1b>
			break;
  800ed5:	eb 0e                	jmp    800ee5 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ed7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	0f b6 00             	movzbl (%eax),%eax
  800ee1:	84 c0                	test   %al,%al
  800ee3:	75 e5                	jne    800eca <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ee5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
	char *p;

	if (n == 0)
  800eee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef2:	75 05                	jne    800ef9 <memset+0xf>
		return v;
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	eb 5c                	jmp    800f55 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	83 e0 03             	and    $0x3,%eax
  800eff:	85 c0                	test   %eax,%eax
  800f01:	75 41                	jne    800f44 <memset+0x5a>
  800f03:	8b 45 10             	mov    0x10(%ebp),%eax
  800f06:	83 e0 03             	and    $0x3,%eax
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	75 37                	jne    800f44 <memset+0x5a>
		c &= 0xFF;
  800f0d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f17:	c1 e0 18             	shl    $0x18,%eax
  800f1a:	89 c2                	mov    %eax,%edx
  800f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1f:	c1 e0 10             	shl    $0x10,%eax
  800f22:	09 c2                	or     %eax,%edx
  800f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f27:	c1 e0 08             	shl    $0x8,%eax
  800f2a:	09 d0                	or     %edx,%eax
  800f2c:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f32:	c1 e8 02             	shr    $0x2,%eax
  800f35:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f37:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3d:	89 d7                	mov    %edx,%edi
  800f3f:	fc                   	cld    
  800f40:	f3 ab                	rep stos %eax,%es:(%edi)
  800f42:	eb 0e                	jmp    800f52 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f44:	8b 55 08             	mov    0x8(%ebp),%edx
  800f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f4d:	89 d7                	mov    %edx,%edi
  800f4f:	fc                   	cld    
  800f50:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f70:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f73:	73 6d                	jae    800fe2 <memmove+0x8a>
  800f75:	8b 45 10             	mov    0x10(%ebp),%eax
  800f78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f7b:	01 d0                	add    %edx,%eax
  800f7d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f80:	76 60                	jbe    800fe2 <memmove+0x8a>
		s += n;
  800f82:	8b 45 10             	mov    0x10(%ebp),%eax
  800f85:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f88:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f91:	83 e0 03             	and    $0x3,%eax
  800f94:	85 c0                	test   %eax,%eax
  800f96:	75 2f                	jne    800fc7 <memmove+0x6f>
  800f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f9b:	83 e0 03             	and    $0x3,%eax
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	75 25                	jne    800fc7 <memmove+0x6f>
  800fa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa5:	83 e0 03             	and    $0x3,%eax
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	75 1b                	jne    800fc7 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800faf:	83 e8 04             	sub    $0x4,%eax
  800fb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fb5:	83 ea 04             	sub    $0x4,%edx
  800fb8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fbb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800fbe:	89 c7                	mov    %eax,%edi
  800fc0:	89 d6                	mov    %edx,%esi
  800fc2:	fd                   	std    
  800fc3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fc5:	eb 18                	jmp    800fdf <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fca:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd0:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd6:	89 d7                	mov    %edx,%edi
  800fd8:	89 de                	mov    %ebx,%esi
  800fda:	89 c1                	mov    %eax,%ecx
  800fdc:	fd                   	std    
  800fdd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fdf:	fc                   	cld    
  800fe0:	eb 45                	jmp    801027 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe5:	83 e0 03             	and    $0x3,%eax
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	75 2b                	jne    801017 <memmove+0xbf>
  800fec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fef:	83 e0 03             	and    $0x3,%eax
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	75 21                	jne    801017 <memmove+0xbf>
  800ff6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff9:	83 e0 03             	and    $0x3,%eax
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	75 17                	jne    801017 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801000:	8b 45 10             	mov    0x10(%ebp),%eax
  801003:	c1 e8 02             	shr    $0x2,%eax
  801006:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801008:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80100b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80100e:	89 c7                	mov    %eax,%edi
  801010:	89 d6                	mov    %edx,%esi
  801012:	fc                   	cld    
  801013:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801015:	eb 10                	jmp    801027 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801017:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80101a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801020:	89 c7                	mov    %eax,%edi
  801022:	89 d6                	mov    %edx,%esi
  801024:	fc                   	cld    
  801025:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  801027:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5f                   	pop    %edi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801038:	8b 45 10             	mov    0x10(%ebp),%eax
  80103b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801042:	89 44 24 04          	mov    %eax,0x4(%esp)
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	89 04 24             	mov    %eax,(%esp)
  80104c:	e8 07 ff ff ff       	call   800f58 <memmove>
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  80105f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801062:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801065:	eb 30                	jmp    801097 <memcmp+0x44>
		if (*s1 != *s2)
  801067:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80106a:	0f b6 10             	movzbl (%eax),%edx
  80106d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801070:	0f b6 00             	movzbl (%eax),%eax
  801073:	38 c2                	cmp    %al,%dl
  801075:	74 18                	je     80108f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801077:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80107a:	0f b6 00             	movzbl (%eax),%eax
  80107d:	0f b6 d0             	movzbl %al,%edx
  801080:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801083:	0f b6 00             	movzbl (%eax),%eax
  801086:	0f b6 c0             	movzbl %al,%eax
  801089:	29 c2                	sub    %eax,%edx
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	eb 1a                	jmp    8010a9 <memcmp+0x56>
		s1++, s2++;
  80108f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801093:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801097:	8b 45 10             	mov    0x10(%ebp),%eax
  80109a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80109d:	89 55 10             	mov    %edx,0x10(%ebp)
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	75 c3                	jne    801067 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  8010b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b7:	01 d0                	add    %edx,%eax
  8010b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  8010bc:	eb 13                	jmp    8010d1 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	0f b6 10             	movzbl (%eax),%edx
  8010c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c7:	38 c2                	cmp    %al,%dl
  8010c9:	75 02                	jne    8010cd <memfind+0x22>
			break;
  8010cb:	eb 0c                	jmp    8010d9 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8010d7:	72 e5                	jb     8010be <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010eb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010f2:	eb 04                	jmp    8010f8 <strtol+0x1a>
		s++;
  8010f4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	0f b6 00             	movzbl (%eax),%eax
  8010fe:	3c 20                	cmp    $0x20,%al
  801100:	74 f2                	je     8010f4 <strtol+0x16>
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	0f b6 00             	movzbl (%eax),%eax
  801108:	3c 09                	cmp    $0x9,%al
  80110a:	74 e8                	je     8010f4 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	0f b6 00             	movzbl (%eax),%eax
  801112:	3c 2b                	cmp    $0x2b,%al
  801114:	75 06                	jne    80111c <strtol+0x3e>
		s++;
  801116:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80111a:	eb 15                	jmp    801131 <strtol+0x53>
	else if (*s == '-')
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	0f b6 00             	movzbl (%eax),%eax
  801122:	3c 2d                	cmp    $0x2d,%al
  801124:	75 0b                	jne    801131 <strtol+0x53>
		s++, neg = 1;
  801126:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80112a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801131:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801135:	74 06                	je     80113d <strtol+0x5f>
  801137:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80113b:	75 24                	jne    801161 <strtol+0x83>
  80113d:	8b 45 08             	mov    0x8(%ebp),%eax
  801140:	0f b6 00             	movzbl (%eax),%eax
  801143:	3c 30                	cmp    $0x30,%al
  801145:	75 1a                	jne    801161 <strtol+0x83>
  801147:	8b 45 08             	mov    0x8(%ebp),%eax
  80114a:	83 c0 01             	add    $0x1,%eax
  80114d:	0f b6 00             	movzbl (%eax),%eax
  801150:	3c 78                	cmp    $0x78,%al
  801152:	75 0d                	jne    801161 <strtol+0x83>
		s += 2, base = 16;
  801154:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801158:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80115f:	eb 2a                	jmp    80118b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801161:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801165:	75 17                	jne    80117e <strtol+0xa0>
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	0f b6 00             	movzbl (%eax),%eax
  80116d:	3c 30                	cmp    $0x30,%al
  80116f:	75 0d                	jne    80117e <strtol+0xa0>
		s++, base = 8;
  801171:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801175:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80117c:	eb 0d                	jmp    80118b <strtol+0xad>
	else if (base == 0)
  80117e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801182:	75 07                	jne    80118b <strtol+0xad>
		base = 10;
  801184:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	0f b6 00             	movzbl (%eax),%eax
  801191:	3c 2f                	cmp    $0x2f,%al
  801193:	7e 1b                	jle    8011b0 <strtol+0xd2>
  801195:	8b 45 08             	mov    0x8(%ebp),%eax
  801198:	0f b6 00             	movzbl (%eax),%eax
  80119b:	3c 39                	cmp    $0x39,%al
  80119d:	7f 11                	jg     8011b0 <strtol+0xd2>
			dig = *s - '0';
  80119f:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a2:	0f b6 00             	movzbl (%eax),%eax
  8011a5:	0f be c0             	movsbl %al,%eax
  8011a8:	83 e8 30             	sub    $0x30,%eax
  8011ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011ae:	eb 48                	jmp    8011f8 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b3:	0f b6 00             	movzbl (%eax),%eax
  8011b6:	3c 60                	cmp    $0x60,%al
  8011b8:	7e 1b                	jle    8011d5 <strtol+0xf7>
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bd:	0f b6 00             	movzbl (%eax),%eax
  8011c0:	3c 7a                	cmp    $0x7a,%al
  8011c2:	7f 11                	jg     8011d5 <strtol+0xf7>
			dig = *s - 'a' + 10;
  8011c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c7:	0f b6 00             	movzbl (%eax),%eax
  8011ca:	0f be c0             	movsbl %al,%eax
  8011cd:	83 e8 57             	sub    $0x57,%eax
  8011d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011d3:	eb 23                	jmp    8011f8 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	0f b6 00             	movzbl (%eax),%eax
  8011db:	3c 40                	cmp    $0x40,%al
  8011dd:	7e 3d                	jle    80121c <strtol+0x13e>
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	0f b6 00             	movzbl (%eax),%eax
  8011e5:	3c 5a                	cmp    $0x5a,%al
  8011e7:	7f 33                	jg     80121c <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	0f b6 00             	movzbl (%eax),%eax
  8011ef:	0f be c0             	movsbl %al,%eax
  8011f2:	83 e8 37             	sub    $0x37,%eax
  8011f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fb:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011fe:	7c 02                	jl     801202 <strtol+0x124>
			break;
  801200:	eb 1a                	jmp    80121c <strtol+0x13e>
		s++, val = (val * base) + dig;
  801202:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801206:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801209:	0f af 45 10          	imul   0x10(%ebp),%eax
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801212:	01 d0                	add    %edx,%eax
  801214:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801217:	e9 6f ff ff ff       	jmp    80118b <strtol+0xad>

	if (endptr)
  80121c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801220:	74 08                	je     80122a <strtol+0x14c>
		*endptr = (char *) s;
  801222:	8b 45 0c             	mov    0xc(%ebp),%eax
  801225:	8b 55 08             	mov    0x8(%ebp),%edx
  801228:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80122a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80122e:	74 07                	je     801237 <strtol+0x159>
  801230:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801233:	f7 d8                	neg    %eax
  801235:	eb 03                	jmp    80123a <strtol+0x15c>
  801237:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <__udivdi3>:
  801240:	55                   	push   %ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	8b 44 24 28          	mov    0x28(%esp),%eax
  80124a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80124e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801252:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801256:	85 c0                	test   %eax,%eax
  801258:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80125c:	89 ea                	mov    %ebp,%edx
  80125e:	89 0c 24             	mov    %ecx,(%esp)
  801261:	75 2d                	jne    801290 <__udivdi3+0x50>
  801263:	39 e9                	cmp    %ebp,%ecx
  801265:	77 61                	ja     8012c8 <__udivdi3+0x88>
  801267:	85 c9                	test   %ecx,%ecx
  801269:	89 ce                	mov    %ecx,%esi
  80126b:	75 0b                	jne    801278 <__udivdi3+0x38>
  80126d:	b8 01 00 00 00       	mov    $0x1,%eax
  801272:	31 d2                	xor    %edx,%edx
  801274:	f7 f1                	div    %ecx
  801276:	89 c6                	mov    %eax,%esi
  801278:	31 d2                	xor    %edx,%edx
  80127a:	89 e8                	mov    %ebp,%eax
  80127c:	f7 f6                	div    %esi
  80127e:	89 c5                	mov    %eax,%ebp
  801280:	89 f8                	mov    %edi,%eax
  801282:	f7 f6                	div    %esi
  801284:	89 ea                	mov    %ebp,%edx
  801286:	83 c4 0c             	add    $0xc,%esp
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	39 e8                	cmp    %ebp,%eax
  801292:	77 24                	ja     8012b8 <__udivdi3+0x78>
  801294:	0f bd e8             	bsr    %eax,%ebp
  801297:	83 f5 1f             	xor    $0x1f,%ebp
  80129a:	75 3c                	jne    8012d8 <__udivdi3+0x98>
  80129c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012a0:	39 34 24             	cmp    %esi,(%esp)
  8012a3:	0f 86 9f 00 00 00    	jbe    801348 <__udivdi3+0x108>
  8012a9:	39 d0                	cmp    %edx,%eax
  8012ab:	0f 82 97 00 00 00    	jb     801348 <__udivdi3+0x108>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	31 c0                	xor    %eax,%eax
  8012bc:	83 c4 0c             	add    $0xc,%esp
  8012bf:	5e                   	pop    %esi
  8012c0:	5f                   	pop    %edi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    
  8012c3:	90                   	nop
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	f7 f1                	div    %ecx
  8012cc:	31 d2                	xor    %edx,%edx
  8012ce:	83 c4 0c             	add    $0xc,%esp
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	89 e9                	mov    %ebp,%ecx
  8012da:	8b 3c 24             	mov    (%esp),%edi
  8012dd:	d3 e0                	shl    %cl,%eax
  8012df:	89 c6                	mov    %eax,%esi
  8012e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e6:	29 e8                	sub    %ebp,%eax
  8012e8:	89 c1                	mov    %eax,%ecx
  8012ea:	d3 ef                	shr    %cl,%edi
  8012ec:	89 e9                	mov    %ebp,%ecx
  8012ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012f2:	8b 3c 24             	mov    (%esp),%edi
  8012f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012f9:	89 d6                	mov    %edx,%esi
  8012fb:	d3 e7                	shl    %cl,%edi
  8012fd:	89 c1                	mov    %eax,%ecx
  8012ff:	89 3c 24             	mov    %edi,(%esp)
  801302:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801306:	d3 ee                	shr    %cl,%esi
  801308:	89 e9                	mov    %ebp,%ecx
  80130a:	d3 e2                	shl    %cl,%edx
  80130c:	89 c1                	mov    %eax,%ecx
  80130e:	d3 ef                	shr    %cl,%edi
  801310:	09 d7                	or     %edx,%edi
  801312:	89 f2                	mov    %esi,%edx
  801314:	89 f8                	mov    %edi,%eax
  801316:	f7 74 24 08          	divl   0x8(%esp)
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	f7 24 24             	mull   (%esp)
  801321:	39 d6                	cmp    %edx,%esi
  801323:	89 14 24             	mov    %edx,(%esp)
  801326:	72 30                	jb     801358 <__udivdi3+0x118>
  801328:	8b 54 24 04          	mov    0x4(%esp),%edx
  80132c:	89 e9                	mov    %ebp,%ecx
  80132e:	d3 e2                	shl    %cl,%edx
  801330:	39 c2                	cmp    %eax,%edx
  801332:	73 05                	jae    801339 <__udivdi3+0xf9>
  801334:	3b 34 24             	cmp    (%esp),%esi
  801337:	74 1f                	je     801358 <__udivdi3+0x118>
  801339:	89 f8                	mov    %edi,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	e9 7a ff ff ff       	jmp    8012bc <__udivdi3+0x7c>
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	b8 01 00 00 00       	mov    $0x1,%eax
  80134f:	e9 68 ff ff ff       	jmp    8012bc <__udivdi3+0x7c>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	8d 47 ff             	lea    -0x1(%edi),%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	83 c4 0c             	add    $0xc,%esp
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
  801364:	66 90                	xchg   %ax,%ax
  801366:	66 90                	xchg   %ax,%ax
  801368:	66 90                	xchg   %ax,%ax
  80136a:	66 90                	xchg   %ax,%ax
  80136c:	66 90                	xchg   %ax,%ax
  80136e:	66 90                	xchg   %ax,%ax

00801370 <__umoddi3>:
  801370:	55                   	push   %ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	83 ec 14             	sub    $0x14,%esp
  801376:	8b 44 24 28          	mov    0x28(%esp),%eax
  80137a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80137e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801382:	89 c7                	mov    %eax,%edi
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 44 24 30          	mov    0x30(%esp),%eax
  80138c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801390:	89 34 24             	mov    %esi,(%esp)
  801393:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801397:	85 c0                	test   %eax,%eax
  801399:	89 c2                	mov    %eax,%edx
  80139b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80139f:	75 17                	jne    8013b8 <__umoddi3+0x48>
  8013a1:	39 fe                	cmp    %edi,%esi
  8013a3:	76 4b                	jbe    8013f0 <__umoddi3+0x80>
  8013a5:	89 c8                	mov    %ecx,%eax
  8013a7:	89 fa                	mov    %edi,%edx
  8013a9:	f7 f6                	div    %esi
  8013ab:	89 d0                	mov    %edx,%eax
  8013ad:	31 d2                	xor    %edx,%edx
  8013af:	83 c4 14             	add    $0x14,%esp
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    
  8013b6:	66 90                	xchg   %ax,%ax
  8013b8:	39 f8                	cmp    %edi,%eax
  8013ba:	77 54                	ja     801410 <__umoddi3+0xa0>
  8013bc:	0f bd e8             	bsr    %eax,%ebp
  8013bf:	83 f5 1f             	xor    $0x1f,%ebp
  8013c2:	75 5c                	jne    801420 <__umoddi3+0xb0>
  8013c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013c8:	39 3c 24             	cmp    %edi,(%esp)
  8013cb:	0f 87 e7 00 00 00    	ja     8014b8 <__umoddi3+0x148>
  8013d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d5:	29 f1                	sub    %esi,%ecx
  8013d7:	19 c7                	sbb    %eax,%edi
  8013d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013e9:	83 c4 14             	add    $0x14,%esp
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    
  8013f0:	85 f6                	test   %esi,%esi
  8013f2:	89 f5                	mov    %esi,%ebp
  8013f4:	75 0b                	jne    801401 <__umoddi3+0x91>
  8013f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	f7 f6                	div    %esi
  8013ff:	89 c5                	mov    %eax,%ebp
  801401:	8b 44 24 04          	mov    0x4(%esp),%eax
  801405:	31 d2                	xor    %edx,%edx
  801407:	f7 f5                	div    %ebp
  801409:	89 c8                	mov    %ecx,%eax
  80140b:	f7 f5                	div    %ebp
  80140d:	eb 9c                	jmp    8013ab <__umoddi3+0x3b>
  80140f:	90                   	nop
  801410:	89 c8                	mov    %ecx,%eax
  801412:	89 fa                	mov    %edi,%edx
  801414:	83 c4 14             	add    $0x14,%esp
  801417:	5e                   	pop    %esi
  801418:	5f                   	pop    %edi
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    
  80141b:	90                   	nop
  80141c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801420:	8b 04 24             	mov    (%esp),%eax
  801423:	be 20 00 00 00       	mov    $0x20,%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	29 ee                	sub    %ebp,%esi
  80142c:	d3 e2                	shl    %cl,%edx
  80142e:	89 f1                	mov    %esi,%ecx
  801430:	d3 e8                	shr    %cl,%eax
  801432:	89 e9                	mov    %ebp,%ecx
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	8b 04 24             	mov    (%esp),%eax
  80143b:	09 54 24 04          	or     %edx,0x4(%esp)
  80143f:	89 fa                	mov    %edi,%edx
  801441:	d3 e0                	shl    %cl,%eax
  801443:	89 f1                	mov    %esi,%ecx
  801445:	89 44 24 08          	mov    %eax,0x8(%esp)
  801449:	8b 44 24 10          	mov    0x10(%esp),%eax
  80144d:	d3 ea                	shr    %cl,%edx
  80144f:	89 e9                	mov    %ebp,%ecx
  801451:	d3 e7                	shl    %cl,%edi
  801453:	89 f1                	mov    %esi,%ecx
  801455:	d3 e8                	shr    %cl,%eax
  801457:	89 e9                	mov    %ebp,%ecx
  801459:	09 f8                	or     %edi,%eax
  80145b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80145f:	f7 74 24 04          	divl   0x4(%esp)
  801463:	d3 e7                	shl    %cl,%edi
  801465:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801469:	89 d7                	mov    %edx,%edi
  80146b:	f7 64 24 08          	mull   0x8(%esp)
  80146f:	39 d7                	cmp    %edx,%edi
  801471:	89 c1                	mov    %eax,%ecx
  801473:	89 14 24             	mov    %edx,(%esp)
  801476:	72 2c                	jb     8014a4 <__umoddi3+0x134>
  801478:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80147c:	72 22                	jb     8014a0 <__umoddi3+0x130>
  80147e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801482:	29 c8                	sub    %ecx,%eax
  801484:	19 d7                	sbb    %edx,%edi
  801486:	89 e9                	mov    %ebp,%ecx
  801488:	89 fa                	mov    %edi,%edx
  80148a:	d3 e8                	shr    %cl,%eax
  80148c:	89 f1                	mov    %esi,%ecx
  80148e:	d3 e2                	shl    %cl,%edx
  801490:	89 e9                	mov    %ebp,%ecx
  801492:	d3 ef                	shr    %cl,%edi
  801494:	09 d0                	or     %edx,%eax
  801496:	89 fa                	mov    %edi,%edx
  801498:	83 c4 14             	add    $0x14,%esp
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    
  80149f:	90                   	nop
  8014a0:	39 d7                	cmp    %edx,%edi
  8014a2:	75 da                	jne    80147e <__umoddi3+0x10e>
  8014a4:	8b 14 24             	mov    (%esp),%edx
  8014a7:	89 c1                	mov    %eax,%ecx
  8014a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8014ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014b1:	eb cb                	jmp    80147e <__umoddi3+0x10e>
  8014b3:	90                   	nop
  8014b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014bc:	0f 82 0f ff ff ff    	jb     8013d1 <__umoddi3+0x61>
  8014c2:	e9 1a ff ff ff       	jmp    8013e1 <__umoddi3+0x71>
