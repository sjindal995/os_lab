
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80003f:	e8 72 01 00 00       	call   8001b6 <sys_getenvid>
  800044:	25 ff 03 00 00       	and    $0x3ff,%eax
  800049:	c1 e0 02             	shl    $0x2,%eax
  80004c:	89 c2                	mov    %eax,%edx
  80004e:	c1 e2 05             	shl    $0x5,%edx
  800051:	29 c2                	sub    %eax,%edx
  800053:	89 d0                	mov    %edx,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  80005f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800062:	89 44 24 04          	mov    %eax,0x4(%esp)
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	89 04 24             	mov    %eax,(%esp)
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 02 00 00 00       	call   800078 <exit>
}
  800076:	c9                   	leave  
  800077:	c3                   	ret    

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800085:	e8 e9 00 00 00       	call   800173 <sys_env_destroy>
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	57                   	push   %edi
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800095:	8b 45 08             	mov    0x8(%ebp),%eax
  800098:	8b 55 10             	mov    0x10(%ebp),%edx
  80009b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80009e:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000a1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000a4:	8b 75 20             	mov    0x20(%ebp),%esi
  8000a7:	cd 30                	int    $0x30
  8000a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000b0:	74 30                	je     8000e2 <syscall+0x56>
  8000b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000b6:	7e 2a                	jle    8000e2 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000bb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c6:	c7 44 24 08 6a 14 80 	movl   $0x80146a,0x8(%esp)
  8000cd:	00 
  8000ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000d5:	00 
  8000d6:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  8000dd:	e8 b3 03 00 00       	call   800495 <_panic>

	return ret;
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000e5:	83 c4 3c             	add    $0x3c,%esp
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800105:	00 
  800106:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80010d:	00 
  80010e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800111:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800115:	89 44 24 08          	mov    %eax,0x8(%esp)
  800119:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800120:	00 
  800121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800128:	e8 5f ff ff ff       	call   80008c <syscall>
}
  80012d:	c9                   	leave  
  80012e:	c3                   	ret    

0080012f <sys_cgetc>:

int
sys_cgetc(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800135:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80013c:	00 
  80013d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800144:	00 
  800145:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80014c:	00 
  80014d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800154:	00 
  800155:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80015c:	00 
  80015d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800164:	00 
  800165:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80016c:	e8 1b ff ff ff       	call   80008c <syscall>
}
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800183:	00 
  800184:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80018b:	00 
  80018c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800193:	00 
  800194:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80019b:	00 
  80019c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001a7:	00 
  8001a8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001af:	e8 d8 fe ff ff       	call   80008c <syscall>
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001bc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001c3:	00 
  8001c4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001cb:	00 
  8001cc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001d3:	00 
  8001d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001db:	00 
  8001dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8001f3:	e8 94 fe ff ff       	call   80008c <syscall>
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <sys_yield>:

void
sys_yield(void)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800200:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800207:	00 
  800208:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80020f:	00 
  800210:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800217:	00 
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800227:	00 
  800228:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80022f:	00 
  800230:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800237:	e8 50 fe ff ff       	call   80008c <syscall>
}
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800244:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800254:	00 
  800255:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80025c:	00 
  80025d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800261:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800265:	89 44 24 08          	mov    %eax,0x8(%esp)
  800269:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800270:	00 
  800271:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800278:	e8 0f fe ff ff       	call   80008c <syscall>
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	56                   	push   %esi
  800283:	53                   	push   %ebx
  800284:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800287:	8b 75 18             	mov    0x18(%ebp),%esi
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	89 74 24 18          	mov    %esi,0x18(%esp)
  80029a:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80029e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002b9:	e8 ce fd ff ff       	call   80008c <syscall>
}
  8002be:	83 c4 20             	add    $0x20,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002d8:	00 
  8002d9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002e0:	00 
  8002e1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002e8:	00 
  8002e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002f8:	00 
  8002f9:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800300:	e8 87 fd ff ff       	call   80008c <syscall>
}
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80030d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80031a:	00 
  80031b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800322:	00 
  800323:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80032a:	00 
  80032b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80033a:	00 
  80033b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800342:	e8 45 fd ff ff       	call   80008c <syscall>
}
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80035c:	00 
  80035d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800364:	00 
  800365:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80036c:	00 
  80036d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800371:	89 44 24 08          	mov    %eax,0x8(%esp)
  800375:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80037c:	00 
  80037d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800384:	e8 03 fd ff ff       	call   80008c <syscall>
}
  800389:	c9                   	leave  
  80038a:	c3                   	ret    

0080038b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800391:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800394:	8b 55 10             	mov    0x10(%ebp),%edx
  800397:	8b 45 08             	mov    0x8(%ebp),%eax
  80039a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003a1:	00 
  8003a2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003a6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003bc:	00 
  8003bd:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003c4:	e8 c3 fc ff ff       	call   80008c <syscall>
}
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003db:	00 
  8003dc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003e3:	00 
  8003e4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003eb:	00 
  8003ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f3:	00 
  8003f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003ff:	00 
  800400:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800407:	e8 80 fc ff ff       	call   80008c <syscall>
}
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <sys_exec>:

void sys_exec(char* buf){
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800414:	8b 45 08             	mov    0x8(%ebp),%eax
  800417:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80041e:	00 
  80041f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800426:	00 
  800427:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80042e:	00 
  80042f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800436:	00 
  800437:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800442:	00 
  800443:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80044a:	e8 3d fc ff ff       	call   80008c <syscall>
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    

00800451 <sys_wait>:

void sys_wait(){
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  800457:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80045e:	00 
  80045f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800466:	00 
  800467:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80046e:	00 
  80046f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800476:	00 
  800477:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80047e:	00 
  80047f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800486:	00 
  800487:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80048e:	e8 f9 fb ff ff       	call   80008c <syscall>
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	53                   	push   %ebx
  800499:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80049c:	8d 45 14             	lea    0x14(%ebp),%eax
  80049f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004a2:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004a8:	e8 09 fd ff ff       	call   8001b6 <sys_getenvid>
  8004ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8004ca:	e8 e1 00 00 00       	call   8005b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 6b 00 00 00       	call   80054c <vcprintf>
	cprintf("\n");
  8004e1:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8004e8:	e8 c3 00 00 00       	call   8005b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ed:	cc                   	int3   
  8004ee:	eb fd                	jmp    8004ed <_panic+0x58>

008004f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	8d 48 01             	lea    0x1(%eax),%ecx
  8004fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800501:	89 0a                	mov    %ecx,(%edx)
  800503:	8b 55 08             	mov    0x8(%ebp),%edx
  800506:	89 d1                	mov    %edx,%ecx
  800508:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050b:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800512:	8b 00                	mov    (%eax),%eax
  800514:	3d ff 00 00 00       	cmp    $0xff,%eax
  800519:	75 20                	jne    80053b <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	8b 55 0c             	mov    0xc(%ebp),%edx
  800523:	83 c2 08             	add    $0x8,%edx
  800526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052a:	89 14 24             	mov    %edx,(%esp)
  80052d:	e8 bb fb ff ff       	call   8000ed <sys_cputs>
		b->idx = 0;
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
  800535:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80053b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053e:	8b 40 04             	mov    0x4(%eax),%eax
  800541:	8d 50 01             	lea    0x1(%eax),%edx
  800544:	8b 45 0c             	mov    0xc(%ebp),%eax
  800547:	89 50 04             	mov    %edx,0x4(%eax)
}
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800555:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80055c:	00 00 00 
	b.cnt = 0;
  80055f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800566:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800569:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800570:	8b 45 08             	mov    0x8(%ebp),%eax
  800573:	89 44 24 08          	mov    %eax,0x8(%esp)
  800577:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80057d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800581:	c7 04 24 f0 04 80 00 	movl   $0x8004f0,(%esp)
  800588:	e8 bd 01 00 00       	call   80074a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80058d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800593:	89 44 24 04          	mov    %eax,0x4(%esp)
  800597:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059d:	83 c0 08             	add    $0x8,%eax
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	e8 45 fb ff ff       	call   8000ed <sys_cputs>

	return b.cnt;
  8005a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005ae:	c9                   	leave  
  8005af:	c3                   	ret    

008005b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005b6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	e8 7e ff ff ff       	call   80054c <vcprintf>
  8005ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005d4:	c9                   	leave  
  8005d5:	c3                   	ret    

008005d6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
  8005d9:	53                   	push   %ebx
  8005da:	83 ec 34             	sub    $0x34,%esp
  8005dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e9:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f1:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005f4:	77 72                	ja     800668 <printnum+0x92>
  8005f6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005f9:	72 05                	jb     800600 <printnum+0x2a>
  8005fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005fe:	77 68                	ja     800668 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800600:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800603:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800606:	8b 45 18             	mov    0x18(%ebp),%eax
  800609:	ba 00 00 00 00       	mov    $0x0,%edx
  80060e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800612:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800619:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800623:	e8 98 0b 00 00       	call   8011c0 <__udivdi3>
  800628:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80062b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80062f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800633:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800636:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80063a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800642:	8b 45 0c             	mov    0xc(%ebp),%eax
  800645:	89 44 24 04          	mov    %eax,0x4(%esp)
  800649:	8b 45 08             	mov    0x8(%ebp),%eax
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	e8 82 ff ff ff       	call   8005d6 <printnum>
  800654:	eb 1c                	jmp    800672 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800656:	8b 45 0c             	mov    0xc(%ebp),%eax
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	8b 45 20             	mov    0x20(%ebp),%eax
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	8b 45 08             	mov    0x8(%ebp),%eax
  800666:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800668:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80066c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800670:	7f e4                	jg     800656 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800672:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800675:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800680:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800684:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80068f:	e8 5c 0c 00 00       	call   8012f0 <__umoddi3>
  800694:	05 88 15 80 00       	add    $0x801588,%eax
  800699:	0f b6 00             	movzbl (%eax),%eax
  80069c:	0f be c0             	movsbl %al,%eax
  80069f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a6:	89 04 24             	mov    %eax,(%esp)
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	ff d0                	call   *%eax
}
  8006ae:	83 c4 34             	add    $0x34,%esp
  8006b1:	5b                   	pop    %ebx
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006b7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006bb:	7e 14                	jle    8006d1 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	8d 48 08             	lea    0x8(%eax),%ecx
  8006c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c8:	89 0a                	mov    %ecx,(%edx)
  8006ca:	8b 50 04             	mov    0x4(%eax),%edx
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	eb 30                	jmp    800701 <getuint+0x4d>
	else if (lflag)
  8006d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006d5:	74 16                	je     8006ed <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e2:	89 0a                	mov    %ecx,(%edx)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006eb:	eb 14                	jmp    800701 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f8:	89 0a                	mov    %ecx,(%edx)
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800706:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80070a:	7e 14                	jle    800720 <getint+0x1d>
		return va_arg(*ap, long long);
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	8d 48 08             	lea    0x8(%eax),%ecx
  800714:	8b 55 08             	mov    0x8(%ebp),%edx
  800717:	89 0a                	mov    %ecx,(%edx)
  800719:	8b 50 04             	mov    0x4(%eax),%edx
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	eb 28                	jmp    800748 <getint+0x45>
	else if (lflag)
  800720:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800724:	74 12                	je     800738 <getint+0x35>
		return va_arg(*ap, long);
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	8d 48 04             	lea    0x4(%eax),%ecx
  80072e:	8b 55 08             	mov    0x8(%ebp),%edx
  800731:	89 0a                	mov    %ecx,(%edx)
  800733:	8b 00                	mov    (%eax),%eax
  800735:	99                   	cltd   
  800736:	eb 10                	jmp    800748 <getint+0x45>
	else
		return va_arg(*ap, int);
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 00                	mov    (%eax),%eax
  80073d:	8d 48 04             	lea    0x4(%eax),%ecx
  800740:	8b 55 08             	mov    0x8(%ebp),%edx
  800743:	89 0a                	mov    %ecx,(%edx)
  800745:	8b 00                	mov    (%eax),%eax
  800747:	99                   	cltd   
}
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	56                   	push   %esi
  80074e:	53                   	push   %ebx
  80074f:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800752:	eb 18                	jmp    80076c <vprintfmt+0x22>
			if (ch == '\0')
  800754:	85 db                	test   %ebx,%ebx
  800756:	75 05                	jne    80075d <vprintfmt+0x13>
				return;
  800758:	e9 cc 03 00 00       	jmp    800b29 <vprintfmt+0x3df>
			putch(ch, putdat);
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	89 1c 24             	mov    %ebx,(%esp)
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80076c:	8b 45 10             	mov    0x10(%ebp),%eax
  80076f:	8d 50 01             	lea    0x1(%eax),%edx
  800772:	89 55 10             	mov    %edx,0x10(%ebp)
  800775:	0f b6 00             	movzbl (%eax),%eax
  800778:	0f b6 d8             	movzbl %al,%ebx
  80077b:	83 fb 25             	cmp    $0x25,%ebx
  80077e:	75 d4                	jne    800754 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800780:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800784:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80078b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800792:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800799:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a3:	8d 50 01             	lea    0x1(%eax),%edx
  8007a6:	89 55 10             	mov    %edx,0x10(%ebp)
  8007a9:	0f b6 00             	movzbl (%eax),%eax
  8007ac:	0f b6 d8             	movzbl %al,%ebx
  8007af:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007b2:	83 f8 55             	cmp    $0x55,%eax
  8007b5:	0f 87 3d 03 00 00    	ja     800af8 <vprintfmt+0x3ae>
  8007bb:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  8007c2:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007c4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007c8:	eb d6                	jmp    8007a0 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007ca:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007ce:	eb d0                	jmp    8007a0 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007d7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007da:	89 d0                	mov    %edx,%eax
  8007dc:	c1 e0 02             	shl    $0x2,%eax
  8007df:	01 d0                	add    %edx,%eax
  8007e1:	01 c0                	add    %eax,%eax
  8007e3:	01 d8                	add    %ebx,%eax
  8007e5:	83 e8 30             	sub    $0x30,%eax
  8007e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007f4:	83 fb 2f             	cmp    $0x2f,%ebx
  8007f7:	7e 0b                	jle    800804 <vprintfmt+0xba>
  8007f9:	83 fb 39             	cmp    $0x39,%ebx
  8007fc:	7f 06                	jg     800804 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007fe:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800802:	eb d3                	jmp    8007d7 <vprintfmt+0x8d>
			goto process_precision;
  800804:	eb 33                	jmp    800839 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 00                	mov    (%eax),%eax
  800811:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800814:	eb 23                	jmp    800839 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800816:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081a:	79 0c                	jns    800828 <vprintfmt+0xde>
				width = 0;
  80081c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800823:	e9 78 ff ff ff       	jmp    8007a0 <vprintfmt+0x56>
  800828:	e9 73 ff ff ff       	jmp    8007a0 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80082d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800834:	e9 67 ff ff ff       	jmp    8007a0 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800839:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80083d:	79 12                	jns    800851 <vprintfmt+0x107>
				width = precision, precision = -1;
  80083f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800842:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800845:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80084c:	e9 4f ff ff ff       	jmp    8007a0 <vprintfmt+0x56>
  800851:	e9 4a ff ff ff       	jmp    8007a0 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800856:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80085a:	e9 41 ff ff ff       	jmp    8007a0 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 50 04             	lea    0x4(%eax),%edx
  800865:	89 55 14             	mov    %edx,0x14(%ebp)
  800868:	8b 00                	mov    (%eax),%eax
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800871:	89 04 24             	mov    %eax,(%esp)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	ff d0                	call   *%eax
			break;
  800879:	e9 a5 02 00 00       	jmp    800b23 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 50 04             	lea    0x4(%eax),%edx
  800884:	89 55 14             	mov    %edx,0x14(%ebp)
  800887:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800889:	85 db                	test   %ebx,%ebx
  80088b:	79 02                	jns    80088f <vprintfmt+0x145>
				err = -err;
  80088d:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80088f:	83 fb 09             	cmp    $0x9,%ebx
  800892:	7f 0b                	jg     80089f <vprintfmt+0x155>
  800894:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  80089b:	85 f6                	test   %esi,%esi
  80089d:	75 23                	jne    8008c2 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80089f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008a3:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  8008aa:	00 
  8008ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 73 02 00 00       	call   800b30 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008bd:	e9 61 02 00 00       	jmp    800b23 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008c6:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008cd:	00 
  8008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	89 04 24             	mov    %eax,(%esp)
  8008db:	e8 50 02 00 00       	call   800b30 <printfmt>
			break;
  8008e0:	e9 3e 02 00 00       	jmp    800b23 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 04             	lea    0x4(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	8b 30                	mov    (%eax),%esi
  8008f0:	85 f6                	test   %esi,%esi
  8008f2:	75 05                	jne    8008f9 <vprintfmt+0x1af>
				p = "(null)";
  8008f4:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8008f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fd:	7e 37                	jle    800936 <vprintfmt+0x1ec>
  8008ff:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800903:	74 31                	je     800936 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800905:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090c:	89 34 24             	mov    %esi,(%esp)
  80090f:	e8 39 03 00 00       	call   800c4d <strnlen>
  800914:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800917:	eb 17                	jmp    800930 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800919:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800920:	89 54 24 04          	mov    %edx,0x4(%esp)
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80092c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800930:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800934:	7f e3                	jg     800919 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800936:	eb 38                	jmp    800970 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800938:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80093c:	74 1f                	je     80095d <vprintfmt+0x213>
  80093e:	83 fb 1f             	cmp    $0x1f,%ebx
  800941:	7e 05                	jle    800948 <vprintfmt+0x1fe>
  800943:	83 fb 7e             	cmp    $0x7e,%ebx
  800946:	7e 15                	jle    80095d <vprintfmt+0x213>
					putch('?', putdat);
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	ff d0                	call   *%eax
  80095b:	eb 0f                	jmp    80096c <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	89 44 24 04          	mov    %eax,0x4(%esp)
  800964:	89 1c 24             	mov    %ebx,(%esp)
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80096c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800970:	89 f0                	mov    %esi,%eax
  800972:	8d 70 01             	lea    0x1(%eax),%esi
  800975:	0f b6 00             	movzbl (%eax),%eax
  800978:	0f be d8             	movsbl %al,%ebx
  80097b:	85 db                	test   %ebx,%ebx
  80097d:	74 10                	je     80098f <vprintfmt+0x245>
  80097f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800983:	78 b3                	js     800938 <vprintfmt+0x1ee>
  800985:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800989:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098d:	79 a9                	jns    800938 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80098f:	eb 17                	jmp    8009a8 <vprintfmt+0x25e>
				putch(' ', putdat);
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ac:	7f e3                	jg     800991 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009ae:	e9 70 01 00 00       	jmp    800b23 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8009bd:	89 04 24             	mov    %eax,(%esp)
  8009c0:	e8 3e fd ff ff       	call   800703 <getint>
  8009c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d1:	85 d2                	test   %edx,%edx
  8009d3:	79 26                	jns    8009fb <vprintfmt+0x2b1>
				putch('-', putdat);
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	ff d0                	call   *%eax
				num = -(long long) num;
  8009e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ee:	f7 d8                	neg    %eax
  8009f0:	83 d2 00             	adc    $0x0,%edx
  8009f3:	f7 da                	neg    %edx
  8009f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009f8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009fb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a02:	e9 a8 00 00 00       	jmp    800aaf <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a07:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 9b fc ff ff       	call   8006b4 <getuint>
  800a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a1f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a26:	e9 84 00 00 00       	jmp    800aaf <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	8d 45 14             	lea    0x14(%ebp),%eax
  800a35:	89 04 24             	mov    %eax,(%esp)
  800a38:	e8 77 fc ff ff       	call   8006b4 <getuint>
  800a3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a40:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a43:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a4a:	eb 63                	jmp    800aaf <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	ff d0                	call   *%eax
			putch('x', putdat);
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a66:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a72:	8b 45 14             	mov    0x14(%ebp),%eax
  800a75:	8d 50 04             	lea    0x4(%eax),%edx
  800a78:	89 55 14             	mov    %edx,0x14(%ebp)
  800a7b:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a87:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a8e:	eb 1f                	jmp    800aaf <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a90:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a97:	8d 45 14             	lea    0x14(%ebp),%eax
  800a9a:	89 04 24             	mov    %eax,(%esp)
  800a9d:	e8 12 fc ff ff       	call   8006b4 <getuint>
  800aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aa5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aa8:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aaf:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab6:	89 54 24 18          	mov    %edx,0x18(%esp)
  800aba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800abd:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ac1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800acb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	89 04 24             	mov    %eax,(%esp)
  800ae0:	e8 f1 fa ff ff       	call   8005d6 <printnum>
			break;
  800ae5:	eb 3c                	jmp    800b23 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aee:	89 1c 24             	mov    %ebx,(%esp)
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	ff d0                	call   *%eax
			break;
  800af6:	eb 2b                	jmp    800b23 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b0b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b0f:	eb 04                	jmp    800b15 <vprintfmt+0x3cb>
  800b11:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b15:	8b 45 10             	mov    0x10(%ebp),%eax
  800b18:	83 e8 01             	sub    $0x1,%eax
  800b1b:	0f b6 00             	movzbl (%eax),%eax
  800b1e:	3c 25                	cmp    $0x25,%al
  800b20:	75 ef                	jne    800b11 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b22:	90                   	nop
		}
	}
  800b23:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b24:	e9 43 fc ff ff       	jmp    80076c <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b29:	83 c4 40             	add    $0x40,%esp
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b36:	8d 45 14             	lea    0x14(%ebp),%eax
  800b39:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b43:	8b 45 10             	mov    0x10(%ebp),%eax
  800b46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	89 04 24             	mov    %eax,(%esp)
  800b57:	e8 ee fb ff ff       	call   80074a <vprintfmt>
	va_end(ap);
}
  800b5c:	c9                   	leave  
  800b5d:	c3                   	ret    

00800b5e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	8b 40 08             	mov    0x8(%eax),%eax
  800b67:	8d 50 01             	lea    0x1(%eax),%edx
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	8b 10                	mov    (%eax),%edx
  800b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b78:	8b 40 04             	mov    0x4(%eax),%eax
  800b7b:	39 c2                	cmp    %eax,%edx
  800b7d:	73 12                	jae    800b91 <sprintputch+0x33>
		*b->buf++ = ch;
  800b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b82:	8b 00                	mov    (%eax),%eax
  800b84:	8d 48 01             	lea    0x1(%eax),%ecx
  800b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8a:	89 0a                	mov    %ecx,(%edx)
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	88 10                	mov    %dl,(%eax)
}
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	01 d0                	add    %edx,%eax
  800baa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bb4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bb8:	74 06                	je     800bc0 <vsnprintf+0x2d>
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	7f 07                	jg     800bc7 <vsnprintf+0x34>
		return -E_INVAL;
  800bc0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bc5:	eb 2a                	jmp    800bf1 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bce:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdc:	c7 04 24 5e 0b 80 00 	movl   $0x800b5e,(%esp)
  800be3:	e8 62 fb ff ff       	call   80074a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800beb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bf9:	8d 45 14             	lea    0x14(%ebp),%eax
  800bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c06:	8b 45 10             	mov    0x10(%ebp),%eax
  800c09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	89 04 24             	mov    %eax,(%esp)
  800c1a:	e8 74 ff ff ff       	call   800b93 <vsnprintf>
  800c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c34:	eb 08                	jmp    800c3e <strlen+0x17>
		n++;
  800c36:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 00             	movzbl (%eax),%eax
  800c44:	84 c0                	test   %al,%al
  800c46:	75 ee                	jne    800c36 <strlen+0xf>
		n++;
	return n;
  800c48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c53:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c5a:	eb 0c                	jmp    800c68 <strnlen+0x1b>
		n++;
  800c5c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c64:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6c:	74 0a                	je     800c78 <strnlen+0x2b>
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 00             	movzbl (%eax),%eax
  800c74:	84 c0                	test   %al,%al
  800c76:	75 e4                	jne    800c5c <strnlen+0xf>
		n++;
	return n;
  800c78:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c89:	90                   	nop
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	8d 50 01             	lea    0x1(%eax),%edx
  800c90:	89 55 08             	mov    %edx,0x8(%ebp)
  800c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c96:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c99:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c9c:	0f b6 12             	movzbl (%edx),%edx
  800c9f:	88 10                	mov    %dl,(%eax)
  800ca1:	0f b6 00             	movzbl (%eax),%eax
  800ca4:	84 c0                	test   %al,%al
  800ca6:	75 e2                	jne    800c8a <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	89 04 24             	mov    %eax,(%esp)
  800cb9:	e8 69 ff ff ff       	call   800c27 <strlen>
  800cbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cc1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	01 c2                	add    %eax,%edx
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd0:	89 14 24             	mov    %edx,(%esp)
  800cd3:	e8 a5 ff ff ff       	call   800c7d <strcpy>
	return dst;
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce6:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800ce9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cf0:	eb 23                	jmp    800d15 <strncpy+0x38>
		*dst++ = *src;
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8d 50 01             	lea    0x1(%eax),%edx
  800cf8:	89 55 08             	mov    %edx,0x8(%ebp)
  800cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfe:	0f b6 12             	movzbl (%edx),%edx
  800d01:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d06:	0f b6 00             	movzbl (%eax),%eax
  800d09:	84 c0                	test   %al,%al
  800d0b:	74 04                	je     800d11 <strncpy+0x34>
			src++;
  800d0d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d11:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d18:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d1b:	72 d5                	jb     800cf2 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d32:	74 33                	je     800d67 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d34:	eb 17                	jmp    800d4d <strlcpy+0x2b>
			*dst++ = *src++;
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	8d 50 01             	lea    0x1(%eax),%edx
  800d3c:	89 55 08             	mov    %edx,0x8(%ebp)
  800d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d42:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d45:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d48:	0f b6 12             	movzbl (%edx),%edx
  800d4b:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d4d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d55:	74 0a                	je     800d61 <strlcpy+0x3f>
  800d57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5a:	0f b6 00             	movzbl (%eax),%eax
  800d5d:	84 c0                	test   %al,%al
  800d5f:	75 d5                	jne    800d36 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d6d:	29 c2                	sub    %eax,%edx
  800d6f:	89 d0                	mov    %edx,%eax
}
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d76:	eb 08                	jmp    800d80 <strcmp+0xd>
		p++, q++;
  800d78:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	84 c0                	test   %al,%al
  800d88:	74 10                	je     800d9a <strcmp+0x27>
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 10             	movzbl (%eax),%edx
  800d90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d93:	0f b6 00             	movzbl (%eax),%eax
  800d96:	38 c2                	cmp    %al,%dl
  800d98:	74 de                	je     800d78 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	0f b6 00             	movzbl (%eax),%eax
  800da0:	0f b6 d0             	movzbl %al,%edx
  800da3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da6:	0f b6 00             	movzbl (%eax),%eax
  800da9:	0f b6 c0             	movzbl %al,%eax
  800dac:	29 c2                	sub    %eax,%edx
  800dae:	89 d0                	mov    %edx,%eax
}
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800db5:	eb 0c                	jmp    800dc3 <strncmp+0x11>
		n--, p++, q++;
  800db7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dc3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc7:	74 1a                	je     800de3 <strncmp+0x31>
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	0f b6 00             	movzbl (%eax),%eax
  800dcf:	84 c0                	test   %al,%al
  800dd1:	74 10                	je     800de3 <strncmp+0x31>
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	0f b6 10             	movzbl (%eax),%edx
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	38 c2                	cmp    %al,%dl
  800de1:	74 d4                	je     800db7 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800de3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de7:	75 07                	jne    800df0 <strncmp+0x3e>
		return 0;
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	eb 16                	jmp    800e06 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	0f b6 d0             	movzbl %al,%edx
  800df9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	0f b6 c0             	movzbl %al,%eax
  800e02:	29 c2                	sub    %eax,%edx
  800e04:	89 d0                	mov    %edx,%eax
}
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e14:	eb 14                	jmp    800e2a <strchr+0x22>
		if (*s == c)
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	0f b6 00             	movzbl (%eax),%eax
  800e1c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e1f:	75 05                	jne    800e26 <strchr+0x1e>
			return (char *) s;
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	eb 13                	jmp    800e39 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e26:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	0f b6 00             	movzbl (%eax),%eax
  800e30:	84 c0                	test   %al,%al
  800e32:	75 e2                	jne    800e16 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e44:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e47:	eb 11                	jmp    800e5a <strfind+0x1f>
		if (*s == c)
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	0f b6 00             	movzbl (%eax),%eax
  800e4f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e52:	75 02                	jne    800e56 <strfind+0x1b>
			break;
  800e54:	eb 0e                	jmp    800e64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e56:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	0f b6 00             	movzbl (%eax),%eax
  800e60:	84 c0                	test   %al,%al
  800e62:	75 e5                	jne    800e49 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e71:	75 05                	jne    800e78 <memset+0xf>
		return v;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	eb 5c                	jmp    800ed4 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	83 e0 03             	and    $0x3,%eax
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	75 41                	jne    800ec3 <memset+0x5a>
  800e82:	8b 45 10             	mov    0x10(%ebp),%eax
  800e85:	83 e0 03             	and    $0x3,%eax
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	75 37                	jne    800ec3 <memset+0x5a>
		c &= 0xFF;
  800e8c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	c1 e0 18             	shl    $0x18,%eax
  800e99:	89 c2                	mov    %eax,%edx
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	c1 e0 10             	shl    $0x10,%eax
  800ea1:	09 c2                	or     %eax,%edx
  800ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea6:	c1 e0 08             	shl    $0x8,%eax
  800ea9:	09 d0                	or     %edx,%eax
  800eab:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eae:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb1:	c1 e8 02             	shr    $0x2,%eax
  800eb4:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	89 d7                	mov    %edx,%edi
  800ebe:	fc                   	cld    
  800ebf:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec1:	eb 0e                	jmp    800ed1 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ecc:	89 d7                	mov    %edx,%edi
  800ece:	fc                   	cld    
  800ecf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ed1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eef:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ef2:	73 6d                	jae    800f61 <memmove+0x8a>
  800ef4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800efa:	01 d0                	add    %edx,%eax
  800efc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eff:	76 60                	jbe    800f61 <memmove+0x8a>
		s += n;
  800f01:	8b 45 10             	mov    0x10(%ebp),%eax
  800f04:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f07:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0a:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f10:	83 e0 03             	and    $0x3,%eax
  800f13:	85 c0                	test   %eax,%eax
  800f15:	75 2f                	jne    800f46 <memmove+0x6f>
  800f17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1a:	83 e0 03             	and    $0x3,%eax
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	75 25                	jne    800f46 <memmove+0x6f>
  800f21:	8b 45 10             	mov    0x10(%ebp),%eax
  800f24:	83 e0 03             	and    $0x3,%eax
  800f27:	85 c0                	test   %eax,%eax
  800f29:	75 1b                	jne    800f46 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2e:	83 e8 04             	sub    $0x4,%eax
  800f31:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f34:	83 ea 04             	sub    $0x4,%edx
  800f37:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f3d:	89 c7                	mov    %eax,%edi
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	fd                   	std    
  800f42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f44:	eb 18                	jmp    800f5e <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f49:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4f:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f52:	8b 45 10             	mov    0x10(%ebp),%eax
  800f55:	89 d7                	mov    %edx,%edi
  800f57:	89 de                	mov    %ebx,%esi
  800f59:	89 c1                	mov    %eax,%ecx
  800f5b:	fd                   	std    
  800f5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f5e:	fc                   	cld    
  800f5f:	eb 45                	jmp    800fa6 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	83 e0 03             	and    $0x3,%eax
  800f67:	85 c0                	test   %eax,%eax
  800f69:	75 2b                	jne    800f96 <memmove+0xbf>
  800f6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6e:	83 e0 03             	and    $0x3,%eax
  800f71:	85 c0                	test   %eax,%eax
  800f73:	75 21                	jne    800f96 <memmove+0xbf>
  800f75:	8b 45 10             	mov    0x10(%ebp),%eax
  800f78:	83 e0 03             	and    $0x3,%eax
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	75 17                	jne    800f96 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f82:	c1 e8 02             	shr    $0x2,%eax
  800f85:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f8d:	89 c7                	mov    %eax,%edi
  800f8f:	89 d6                	mov    %edx,%esi
  800f91:	fc                   	cld    
  800f92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f94:	eb 10                	jmp    800fa6 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f96:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f99:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f9f:	89 c7                	mov    %eax,%edi
  800fa1:	89 d6                	mov    %edx,%esi
  800fa3:	fc                   	cld    
  800fa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	89 04 24             	mov    %eax,(%esp)
  800fcb:	e8 07 ff ff ff       	call   800ed7 <memmove>
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe1:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fe4:	eb 30                	jmp    801016 <memcmp+0x44>
		if (*s1 != *s2)
  800fe6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fe9:	0f b6 10             	movzbl (%eax),%edx
  800fec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fef:	0f b6 00             	movzbl (%eax),%eax
  800ff2:	38 c2                	cmp    %al,%dl
  800ff4:	74 18                	je     80100e <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff9:	0f b6 00             	movzbl (%eax),%eax
  800ffc:	0f b6 d0             	movzbl %al,%edx
  800fff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801002:	0f b6 00             	movzbl (%eax),%eax
  801005:	0f b6 c0             	movzbl %al,%eax
  801008:	29 c2                	sub    %eax,%edx
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	eb 1a                	jmp    801028 <memcmp+0x56>
		s1++, s2++;
  80100e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801012:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801016:	8b 45 10             	mov    0x10(%ebp),%eax
  801019:	8d 50 ff             	lea    -0x1(%eax),%edx
  80101c:	89 55 10             	mov    %edx,0x10(%ebp)
  80101f:	85 c0                	test   %eax,%eax
  801021:	75 c3                	jne    800fe6 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801023:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801030:	8b 45 10             	mov    0x10(%ebp),%eax
  801033:	8b 55 08             	mov    0x8(%ebp),%edx
  801036:	01 d0                	add    %edx,%eax
  801038:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80103b:	eb 13                	jmp    801050 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	0f b6 10             	movzbl (%eax),%edx
  801043:	8b 45 0c             	mov    0xc(%ebp),%eax
  801046:	38 c2                	cmp    %al,%dl
  801048:	75 02                	jne    80104c <memfind+0x22>
			break;
  80104a:	eb 0c                	jmp    801058 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801056:	72 e5                	jb     80103d <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801063:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80106a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801071:	eb 04                	jmp    801077 <strtol+0x1a>
		s++;
  801073:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	0f b6 00             	movzbl (%eax),%eax
  80107d:	3c 20                	cmp    $0x20,%al
  80107f:	74 f2                	je     801073 <strtol+0x16>
  801081:	8b 45 08             	mov    0x8(%ebp),%eax
  801084:	0f b6 00             	movzbl (%eax),%eax
  801087:	3c 09                	cmp    $0x9,%al
  801089:	74 e8                	je     801073 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	0f b6 00             	movzbl (%eax),%eax
  801091:	3c 2b                	cmp    $0x2b,%al
  801093:	75 06                	jne    80109b <strtol+0x3e>
		s++;
  801095:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801099:	eb 15                	jmp    8010b0 <strtol+0x53>
	else if (*s == '-')
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	0f b6 00             	movzbl (%eax),%eax
  8010a1:	3c 2d                	cmp    $0x2d,%al
  8010a3:	75 0b                	jne    8010b0 <strtol+0x53>
		s++, neg = 1;
  8010a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010a9:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b4:	74 06                	je     8010bc <strtol+0x5f>
  8010b6:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010ba:	75 24                	jne    8010e0 <strtol+0x83>
  8010bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bf:	0f b6 00             	movzbl (%eax),%eax
  8010c2:	3c 30                	cmp    $0x30,%al
  8010c4:	75 1a                	jne    8010e0 <strtol+0x83>
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	83 c0 01             	add    $0x1,%eax
  8010cc:	0f b6 00             	movzbl (%eax),%eax
  8010cf:	3c 78                	cmp    $0x78,%al
  8010d1:	75 0d                	jne    8010e0 <strtol+0x83>
		s += 2, base = 16;
  8010d3:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010d7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010de:	eb 2a                	jmp    80110a <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e4:	75 17                	jne    8010fd <strtol+0xa0>
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	0f b6 00             	movzbl (%eax),%eax
  8010ec:	3c 30                	cmp    $0x30,%al
  8010ee:	75 0d                	jne    8010fd <strtol+0xa0>
		s++, base = 8;
  8010f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010fb:	eb 0d                	jmp    80110a <strtol+0xad>
	else if (base == 0)
  8010fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801101:	75 07                	jne    80110a <strtol+0xad>
		base = 10;
  801103:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	0f b6 00             	movzbl (%eax),%eax
  801110:	3c 2f                	cmp    $0x2f,%al
  801112:	7e 1b                	jle    80112f <strtol+0xd2>
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	0f b6 00             	movzbl (%eax),%eax
  80111a:	3c 39                	cmp    $0x39,%al
  80111c:	7f 11                	jg     80112f <strtol+0xd2>
			dig = *s - '0';
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	0f b6 00             	movzbl (%eax),%eax
  801124:	0f be c0             	movsbl %al,%eax
  801127:	83 e8 30             	sub    $0x30,%eax
  80112a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112d:	eb 48                	jmp    801177 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	0f b6 00             	movzbl (%eax),%eax
  801135:	3c 60                	cmp    $0x60,%al
  801137:	7e 1b                	jle    801154 <strtol+0xf7>
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	0f b6 00             	movzbl (%eax),%eax
  80113f:	3c 7a                	cmp    $0x7a,%al
  801141:	7f 11                	jg     801154 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801143:	8b 45 08             	mov    0x8(%ebp),%eax
  801146:	0f b6 00             	movzbl (%eax),%eax
  801149:	0f be c0             	movsbl %al,%eax
  80114c:	83 e8 57             	sub    $0x57,%eax
  80114f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801152:	eb 23                	jmp    801177 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	0f b6 00             	movzbl (%eax),%eax
  80115a:	3c 40                	cmp    $0x40,%al
  80115c:	7e 3d                	jle    80119b <strtol+0x13e>
  80115e:	8b 45 08             	mov    0x8(%ebp),%eax
  801161:	0f b6 00             	movzbl (%eax),%eax
  801164:	3c 5a                	cmp    $0x5a,%al
  801166:	7f 33                	jg     80119b <strtol+0x13e>
			dig = *s - 'A' + 10;
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	0f b6 00             	movzbl (%eax),%eax
  80116e:	0f be c0             	movsbl %al,%eax
  801171:	83 e8 37             	sub    $0x37,%eax
  801174:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801177:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80117d:	7c 02                	jl     801181 <strtol+0x124>
			break;
  80117f:	eb 1a                	jmp    80119b <strtol+0x13e>
		s++, val = (val * base) + dig;
  801181:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801185:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801188:	0f af 45 10          	imul   0x10(%ebp),%eax
  80118c:	89 c2                	mov    %eax,%edx
  80118e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801191:	01 d0                	add    %edx,%eax
  801193:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801196:	e9 6f ff ff ff       	jmp    80110a <strtol+0xad>

	if (endptr)
  80119b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80119f:	74 08                	je     8011a9 <strtol+0x14c>
		*endptr = (char *) s;
  8011a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011a9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011ad:	74 07                	je     8011b6 <strtol+0x159>
  8011af:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011b2:	f7 d8                	neg    %eax
  8011b4:	eb 03                	jmp    8011b9 <strtol+0x15c>
  8011b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    
  8011bb:	66 90                	xchg   %ax,%ax
  8011bd:	66 90                	xchg   %ax,%ax
  8011bf:	90                   	nop

008011c0 <__udivdi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011dc:	89 ea                	mov    %ebp,%edx
  8011de:	89 0c 24             	mov    %ecx,(%esp)
  8011e1:	75 2d                	jne    801210 <__udivdi3+0x50>
  8011e3:	39 e9                	cmp    %ebp,%ecx
  8011e5:	77 61                	ja     801248 <__udivdi3+0x88>
  8011e7:	85 c9                	test   %ecx,%ecx
  8011e9:	89 ce                	mov    %ecx,%esi
  8011eb:	75 0b                	jne    8011f8 <__udivdi3+0x38>
  8011ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f2:	31 d2                	xor    %edx,%edx
  8011f4:	f7 f1                	div    %ecx
  8011f6:	89 c6                	mov    %eax,%esi
  8011f8:	31 d2                	xor    %edx,%edx
  8011fa:	89 e8                	mov    %ebp,%eax
  8011fc:	f7 f6                	div    %esi
  8011fe:	89 c5                	mov    %eax,%ebp
  801200:	89 f8                	mov    %edi,%eax
  801202:	f7 f6                	div    %esi
  801204:	89 ea                	mov    %ebp,%edx
  801206:	83 c4 0c             	add    $0xc,%esp
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    
  80120d:	8d 76 00             	lea    0x0(%esi),%esi
  801210:	39 e8                	cmp    %ebp,%eax
  801212:	77 24                	ja     801238 <__udivdi3+0x78>
  801214:	0f bd e8             	bsr    %eax,%ebp
  801217:	83 f5 1f             	xor    $0x1f,%ebp
  80121a:	75 3c                	jne    801258 <__udivdi3+0x98>
  80121c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801220:	39 34 24             	cmp    %esi,(%esp)
  801223:	0f 86 9f 00 00 00    	jbe    8012c8 <__udivdi3+0x108>
  801229:	39 d0                	cmp    %edx,%eax
  80122b:	0f 82 97 00 00 00    	jb     8012c8 <__udivdi3+0x108>
  801231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801238:	31 d2                	xor    %edx,%edx
  80123a:	31 c0                	xor    %eax,%eax
  80123c:	83 c4 0c             	add    $0xc,%esp
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    
  801243:	90                   	nop
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	89 f8                	mov    %edi,%eax
  80124a:	f7 f1                	div    %ecx
  80124c:	31 d2                	xor    %edx,%edx
  80124e:	83 c4 0c             	add    $0xc,%esp
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    
  801255:	8d 76 00             	lea    0x0(%esi),%esi
  801258:	89 e9                	mov    %ebp,%ecx
  80125a:	8b 3c 24             	mov    (%esp),%edi
  80125d:	d3 e0                	shl    %cl,%eax
  80125f:	89 c6                	mov    %eax,%esi
  801261:	b8 20 00 00 00       	mov    $0x20,%eax
  801266:	29 e8                	sub    %ebp,%eax
  801268:	89 c1                	mov    %eax,%ecx
  80126a:	d3 ef                	shr    %cl,%edi
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801272:	8b 3c 24             	mov    (%esp),%edi
  801275:	09 74 24 08          	or     %esi,0x8(%esp)
  801279:	89 d6                	mov    %edx,%esi
  80127b:	d3 e7                	shl    %cl,%edi
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	89 3c 24             	mov    %edi,(%esp)
  801282:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801286:	d3 ee                	shr    %cl,%esi
  801288:	89 e9                	mov    %ebp,%ecx
  80128a:	d3 e2                	shl    %cl,%edx
  80128c:	89 c1                	mov    %eax,%ecx
  80128e:	d3 ef                	shr    %cl,%edi
  801290:	09 d7                	or     %edx,%edi
  801292:	89 f2                	mov    %esi,%edx
  801294:	89 f8                	mov    %edi,%eax
  801296:	f7 74 24 08          	divl   0x8(%esp)
  80129a:	89 d6                	mov    %edx,%esi
  80129c:	89 c7                	mov    %eax,%edi
  80129e:	f7 24 24             	mull   (%esp)
  8012a1:	39 d6                	cmp    %edx,%esi
  8012a3:	89 14 24             	mov    %edx,(%esp)
  8012a6:	72 30                	jb     8012d8 <__udivdi3+0x118>
  8012a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 e2                	shl    %cl,%edx
  8012b0:	39 c2                	cmp    %eax,%edx
  8012b2:	73 05                	jae    8012b9 <__udivdi3+0xf9>
  8012b4:	3b 34 24             	cmp    (%esp),%esi
  8012b7:	74 1f                	je     8012d8 <__udivdi3+0x118>
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	e9 7a ff ff ff       	jmp    80123c <__udivdi3+0x7c>
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cf:	e9 68 ff ff ff       	jmp    80123c <__udivdi3+0x7c>
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	83 c4 0c             	add    $0xc,%esp
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    
  8012e4:	66 90                	xchg   %ax,%ax
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__umoddi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 14             	sub    $0x14,%esp
  8012f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801302:	89 c7                	mov    %eax,%edi
  801304:	89 44 24 04          	mov    %eax,0x4(%esp)
  801308:	8b 44 24 30          	mov    0x30(%esp),%eax
  80130c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801310:	89 34 24             	mov    %esi,(%esp)
  801313:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801317:	85 c0                	test   %eax,%eax
  801319:	89 c2                	mov    %eax,%edx
  80131b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80131f:	75 17                	jne    801338 <__umoddi3+0x48>
  801321:	39 fe                	cmp    %edi,%esi
  801323:	76 4b                	jbe    801370 <__umoddi3+0x80>
  801325:	89 c8                	mov    %ecx,%eax
  801327:	89 fa                	mov    %edi,%edx
  801329:	f7 f6                	div    %esi
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	31 d2                	xor    %edx,%edx
  80132f:	83 c4 14             	add    $0x14,%esp
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
  801336:	66 90                	xchg   %ax,%ax
  801338:	39 f8                	cmp    %edi,%eax
  80133a:	77 54                	ja     801390 <__umoddi3+0xa0>
  80133c:	0f bd e8             	bsr    %eax,%ebp
  80133f:	83 f5 1f             	xor    $0x1f,%ebp
  801342:	75 5c                	jne    8013a0 <__umoddi3+0xb0>
  801344:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801348:	39 3c 24             	cmp    %edi,(%esp)
  80134b:	0f 87 e7 00 00 00    	ja     801438 <__umoddi3+0x148>
  801351:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801355:	29 f1                	sub    %esi,%ecx
  801357:	19 c7                	sbb    %eax,%edi
  801359:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801361:	8b 44 24 08          	mov    0x8(%esp),%eax
  801365:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801369:	83 c4 14             	add    $0x14,%esp
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
  801370:	85 f6                	test   %esi,%esi
  801372:	89 f5                	mov    %esi,%ebp
  801374:	75 0b                	jne    801381 <__umoddi3+0x91>
  801376:	b8 01 00 00 00       	mov    $0x1,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f6                	div    %esi
  80137f:	89 c5                	mov    %eax,%ebp
  801381:	8b 44 24 04          	mov    0x4(%esp),%eax
  801385:	31 d2                	xor    %edx,%edx
  801387:	f7 f5                	div    %ebp
  801389:	89 c8                	mov    %ecx,%eax
  80138b:	f7 f5                	div    %ebp
  80138d:	eb 9c                	jmp    80132b <__umoddi3+0x3b>
  80138f:	90                   	nop
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 fa                	mov    %edi,%edx
  801394:	83 c4 14             	add    $0x14,%esp
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
  80139b:	90                   	nop
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	8b 04 24             	mov    (%esp),%eax
  8013a3:	be 20 00 00 00       	mov    $0x20,%esi
  8013a8:	89 e9                	mov    %ebp,%ecx
  8013aa:	29 ee                	sub    %ebp,%esi
  8013ac:	d3 e2                	shl    %cl,%edx
  8013ae:	89 f1                	mov    %esi,%ecx
  8013b0:	d3 e8                	shr    %cl,%eax
  8013b2:	89 e9                	mov    %ebp,%ecx
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 04 24             	mov    (%esp),%eax
  8013bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013bf:	89 fa                	mov    %edi,%edx
  8013c1:	d3 e0                	shl    %cl,%eax
  8013c3:	89 f1                	mov    %esi,%ecx
  8013c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013cd:	d3 ea                	shr    %cl,%edx
  8013cf:	89 e9                	mov    %ebp,%ecx
  8013d1:	d3 e7                	shl    %cl,%edi
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	d3 e8                	shr    %cl,%eax
  8013d7:	89 e9                	mov    %ebp,%ecx
  8013d9:	09 f8                	or     %edi,%eax
  8013db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013df:	f7 74 24 04          	divl   0x4(%esp)
  8013e3:	d3 e7                	shl    %cl,%edi
  8013e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013e9:	89 d7                	mov    %edx,%edi
  8013eb:	f7 64 24 08          	mull   0x8(%esp)
  8013ef:	39 d7                	cmp    %edx,%edi
  8013f1:	89 c1                	mov    %eax,%ecx
  8013f3:	89 14 24             	mov    %edx,(%esp)
  8013f6:	72 2c                	jb     801424 <__umoddi3+0x134>
  8013f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013fc:	72 22                	jb     801420 <__umoddi3+0x130>
  8013fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801402:	29 c8                	sub    %ecx,%eax
  801404:	19 d7                	sbb    %edx,%edi
  801406:	89 e9                	mov    %ebp,%ecx
  801408:	89 fa                	mov    %edi,%edx
  80140a:	d3 e8                	shr    %cl,%eax
  80140c:	89 f1                	mov    %esi,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	89 e9                	mov    %ebp,%ecx
  801412:	d3 ef                	shr    %cl,%edi
  801414:	09 d0                	or     %edx,%eax
  801416:	89 fa                	mov    %edi,%edx
  801418:	83 c4 14             	add    $0x14,%esp
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    
  80141f:	90                   	nop
  801420:	39 d7                	cmp    %edx,%edi
  801422:	75 da                	jne    8013fe <__umoddi3+0x10e>
  801424:	8b 14 24             	mov    (%esp),%edx
  801427:	89 c1                	mov    %eax,%ecx
  801429:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80142d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801431:	eb cb                	jmp    8013fe <__umoddi3+0x10e>
  801433:	90                   	nop
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80143c:	0f 82 0f ff ff ff    	jb     801351 <__umoddi3+0x61>
  801442:	e9 1a ff ff ff       	jmp    801361 <__umoddi3+0x71>
