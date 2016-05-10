
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
  8000c6:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  8000cd:	00 
  8000ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000d5:	00 
  8000d6:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  8000dd:	e8 f7 03 00 00       	call   8004d9 <_panic>

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
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <sys_guest>:

void sys_guest(){
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  80049b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004a2:	00 
  8004a3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004aa:	00 
  8004ab:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004b2:	00 
  8004b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ba:	00 
  8004bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004c2:	00 
  8004c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ca:	00 
  8004cb:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004d2:	e8 b5 fb ff ff       	call   80008c <syscall>
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	53                   	push   %ebx
  8004dd:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8004e3:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004e6:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004ec:	e8 c5 fc ff ff       	call   8001b6 <sys_getenvid>
  8004f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  80050e:	e8 e1 00 00 00       	call   8005f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800513:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051a:	8b 45 10             	mov    0x10(%ebp),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	e8 6b 00 00 00       	call   800590 <vcprintf>
	cprintf("\n");
  800525:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  80052c:	e8 c3 00 00 00       	call   8005f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800531:	cc                   	int3   
  800532:	eb fd                	jmp    800531 <_panic+0x58>

00800534 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80053a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	8d 48 01             	lea    0x1(%eax),%ecx
  800542:	8b 55 0c             	mov    0xc(%ebp),%edx
  800545:	89 0a                	mov    %ecx,(%edx)
  800547:	8b 55 08             	mov    0x8(%ebp),%edx
  80054a:	89 d1                	mov    %edx,%ecx
  80054c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054f:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
  800556:	8b 00                	mov    (%eax),%eax
  800558:	3d ff 00 00 00       	cmp    $0xff,%eax
  80055d:	75 20                	jne    80057f <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80055f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800562:	8b 00                	mov    (%eax),%eax
  800564:	8b 55 0c             	mov    0xc(%ebp),%edx
  800567:	83 c2 08             	add    $0x8,%edx
  80056a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056e:	89 14 24             	mov    %edx,(%esp)
  800571:	e8 77 fb ff ff       	call   8000ed <sys_cputs>
		b->idx = 0;
  800576:	8b 45 0c             	mov    0xc(%ebp),%eax
  800579:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80057f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800582:	8b 40 04             	mov    0x4(%eax),%eax
  800585:	8d 50 01             	lea    0x1(%eax),%edx
  800588:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058b:	89 50 04             	mov    %edx,0x4(%eax)
}
  80058e:	c9                   	leave  
  80058f:	c3                   	ret    

00800590 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800599:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005a0:	00 00 00 
	b.cnt = 0;
  8005a3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005aa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c5:	c7 04 24 34 05 80 00 	movl   $0x800534,(%esp)
  8005cc:	e8 bd 01 00 00       	call   80078e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005d1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005e1:	83 c0 08             	add    $0x8,%eax
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	e8 01 fb ff ff       	call   8000ed <sys_cputs>

	return b.cnt;
  8005ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005f2:	c9                   	leave  
  8005f3:	c3                   	ret    

008005f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005fa:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	e8 7e ff ff ff       	call   800590 <vcprintf>
  800612:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800615:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	53                   	push   %ebx
  80061e:	83 ec 34             	sub    $0x34,%esp
  800621:	8b 45 10             	mov    0x10(%ebp),%eax
  800624:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80062d:	8b 45 18             	mov    0x18(%ebp),%eax
  800630:	ba 00 00 00 00       	mov    $0x0,%edx
  800635:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800638:	77 72                	ja     8006ac <printnum+0x92>
  80063a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80063d:	72 05                	jb     800644 <printnum+0x2a>
  80063f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800642:	77 68                	ja     8006ac <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800644:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800647:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80064a:	8b 45 18             	mov    0x18(%ebp),%eax
  80064d:	ba 00 00 00 00       	mov    $0x0,%edx
  800652:	89 44 24 08          	mov    %eax,0x8(%esp)
  800656:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800660:	89 04 24             	mov    %eax,(%esp)
  800663:	89 54 24 04          	mov    %edx,0x4(%esp)
  800667:	e8 94 0b 00 00       	call   801200 <__udivdi3>
  80066c:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80066f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800673:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800677:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80067a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80067e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800682:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800686:	8b 45 0c             	mov    0xc(%ebp),%eax
  800689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 82 ff ff ff       	call   80061a <printnum>
  800698:	eb 1c                	jmp    8006b6 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80069a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a1:	8b 45 20             	mov    0x20(%ebp),%eax
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006aa:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006ac:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006b0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006b4:	7f e4                	jg     80069a <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006b6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d3:	e8 58 0c 00 00       	call   801330 <__umoddi3>
  8006d8:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8006dd:	0f b6 00             	movzbl (%eax),%eax
  8006e0:	0f be c0             	movsbl %al,%eax
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	ff d0                	call   *%eax
}
  8006f2:	83 c4 34             	add    $0x34,%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006fb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006ff:	7e 14                	jle    800715 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	8b 00                	mov    (%eax),%eax
  800706:	8d 48 08             	lea    0x8(%eax),%ecx
  800709:	8b 55 08             	mov    0x8(%ebp),%edx
  80070c:	89 0a                	mov    %ecx,(%edx)
  80070e:	8b 50 04             	mov    0x4(%eax),%edx
  800711:	8b 00                	mov    (%eax),%eax
  800713:	eb 30                	jmp    800745 <getuint+0x4d>
	else if (lflag)
  800715:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800719:	74 16                	je     800731 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	8d 48 04             	lea    0x4(%eax),%ecx
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
  800726:	89 0a                	mov    %ecx,(%edx)
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	ba 00 00 00 00       	mov    $0x0,%edx
  80072f:	eb 14                	jmp    800745 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 00                	mov    (%eax),%eax
  800736:	8d 48 04             	lea    0x4(%eax),%ecx
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
  80073c:	89 0a                	mov    %ecx,(%edx)
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80074a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80074e:	7e 14                	jle    800764 <getint+0x1d>
		return va_arg(*ap, long long);
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	8b 00                	mov    (%eax),%eax
  800755:	8d 48 08             	lea    0x8(%eax),%ecx
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
  80075b:	89 0a                	mov    %ecx,(%edx)
  80075d:	8b 50 04             	mov    0x4(%eax),%edx
  800760:	8b 00                	mov    (%eax),%eax
  800762:	eb 28                	jmp    80078c <getint+0x45>
	else if (lflag)
  800764:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800768:	74 12                	je     80077c <getint+0x35>
		return va_arg(*ap, long);
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	8d 48 04             	lea    0x4(%eax),%ecx
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
  800775:	89 0a                	mov    %ecx,(%edx)
  800777:	8b 00                	mov    (%eax),%eax
  800779:	99                   	cltd   
  80077a:	eb 10                	jmp    80078c <getint+0x45>
	else
		return va_arg(*ap, int);
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	8d 48 04             	lea    0x4(%eax),%ecx
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
  800787:	89 0a                	mov    %ecx,(%edx)
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	99                   	cltd   
}
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	56                   	push   %esi
  800792:	53                   	push   %ebx
  800793:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800796:	eb 18                	jmp    8007b0 <vprintfmt+0x22>
			if (ch == '\0')
  800798:	85 db                	test   %ebx,%ebx
  80079a:	75 05                	jne    8007a1 <vprintfmt+0x13>
				return;
  80079c:	e9 cc 03 00 00       	jmp    800b6d <vprintfmt+0x3df>
			putch(ch, putdat);
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	89 1c 24             	mov    %ebx,(%esp)
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b3:	8d 50 01             	lea    0x1(%eax),%edx
  8007b6:	89 55 10             	mov    %edx,0x10(%ebp)
  8007b9:	0f b6 00             	movzbl (%eax),%eax
  8007bc:	0f b6 d8             	movzbl %al,%ebx
  8007bf:	83 fb 25             	cmp    $0x25,%ebx
  8007c2:	75 d4                	jne    800798 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007c4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007c8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007d6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007dd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e7:	8d 50 01             	lea    0x1(%eax),%edx
  8007ea:	89 55 10             	mov    %edx,0x10(%ebp)
  8007ed:	0f b6 00             	movzbl (%eax),%eax
  8007f0:	0f b6 d8             	movzbl %al,%ebx
  8007f3:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007f6:	83 f8 55             	cmp    $0x55,%eax
  8007f9:	0f 87 3d 03 00 00    	ja     800b3c <vprintfmt+0x3ae>
  8007ff:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  800806:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800808:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80080c:	eb d6                	jmp    8007e4 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80080e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800812:	eb d0                	jmp    8007e4 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800814:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80081b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80081e:	89 d0                	mov    %edx,%eax
  800820:	c1 e0 02             	shl    $0x2,%eax
  800823:	01 d0                	add    %edx,%eax
  800825:	01 c0                	add    %eax,%eax
  800827:	01 d8                	add    %ebx,%eax
  800829:	83 e8 30             	sub    $0x30,%eax
  80082c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80082f:	8b 45 10             	mov    0x10(%ebp),%eax
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800838:	83 fb 2f             	cmp    $0x2f,%ebx
  80083b:	7e 0b                	jle    800848 <vprintfmt+0xba>
  80083d:	83 fb 39             	cmp    $0x39,%ebx
  800840:	7f 06                	jg     800848 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800842:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800846:	eb d3                	jmp    80081b <vprintfmt+0x8d>
			goto process_precision;
  800848:	eb 33                	jmp    80087d <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8d 50 04             	lea    0x4(%eax),%edx
  800850:	89 55 14             	mov    %edx,0x14(%ebp)
  800853:	8b 00                	mov    (%eax),%eax
  800855:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800858:	eb 23                	jmp    80087d <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80085a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80085e:	79 0c                	jns    80086c <vprintfmt+0xde>
				width = 0;
  800860:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800867:	e9 78 ff ff ff       	jmp    8007e4 <vprintfmt+0x56>
  80086c:	e9 73 ff ff ff       	jmp    8007e4 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800871:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800878:	e9 67 ff ff ff       	jmp    8007e4 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80087d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800881:	79 12                	jns    800895 <vprintfmt+0x107>
				width = precision, precision = -1;
  800883:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800886:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800889:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800890:	e9 4f ff ff ff       	jmp    8007e4 <vprintfmt+0x56>
  800895:	e9 4a ff ff ff       	jmp    8007e4 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80089a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80089e:	e9 41 ff ff ff       	jmp    8007e4 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8d 50 04             	lea    0x4(%eax),%edx
  8008a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	ff d0                	call   *%eax
			break;
  8008bd:	e9 a5 02 00 00       	jmp    800b67 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8d 50 04             	lea    0x4(%eax),%edx
  8008c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cb:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008cd:	85 db                	test   %ebx,%ebx
  8008cf:	79 02                	jns    8008d3 <vprintfmt+0x145>
				err = -err;
  8008d1:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008d3:	83 fb 09             	cmp    $0x9,%ebx
  8008d6:	7f 0b                	jg     8008e3 <vprintfmt+0x155>
  8008d8:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8008df:	85 f6                	test   %esi,%esi
  8008e1:	75 23                	jne    800906 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008e3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008e7:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8008ee:	00 
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	89 04 24             	mov    %eax,(%esp)
  8008fc:	e8 73 02 00 00       	call   800b74 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800901:	e9 61 02 00 00       	jmp    800b67 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800906:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80090a:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  800911:	00 
  800912:	8b 45 0c             	mov    0xc(%ebp),%eax
  800915:	89 44 24 04          	mov    %eax,0x4(%esp)
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	89 04 24             	mov    %eax,(%esp)
  80091f:	e8 50 02 00 00       	call   800b74 <printfmt>
			break;
  800924:	e9 3e 02 00 00       	jmp    800b67 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8d 50 04             	lea    0x4(%eax),%edx
  80092f:	89 55 14             	mov    %edx,0x14(%ebp)
  800932:	8b 30                	mov    (%eax),%esi
  800934:	85 f6                	test   %esi,%esi
  800936:	75 05                	jne    80093d <vprintfmt+0x1af>
				p = "(null)";
  800938:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  80093d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800941:	7e 37                	jle    80097a <vprintfmt+0x1ec>
  800943:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800947:	74 31                	je     80097a <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800949:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	89 34 24             	mov    %esi,(%esp)
  800953:	e8 39 03 00 00       	call   800c91 <strnlen>
  800958:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80095b:	eb 17                	jmp    800974 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80095d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
  800964:	89 54 24 04          	mov    %edx,0x4(%esp)
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800970:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800974:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800978:	7f e3                	jg     80095d <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80097a:	eb 38                	jmp    8009b4 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80097c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800980:	74 1f                	je     8009a1 <vprintfmt+0x213>
  800982:	83 fb 1f             	cmp    $0x1f,%ebx
  800985:	7e 05                	jle    80098c <vprintfmt+0x1fe>
  800987:	83 fb 7e             	cmp    $0x7e,%ebx
  80098a:	7e 15                	jle    8009a1 <vprintfmt+0x213>
					putch('?', putdat);
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	ff d0                	call   *%eax
  80099f:	eb 0f                	jmp    8009b0 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	89 1c 24             	mov    %ebx,(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b0:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b4:	89 f0                	mov    %esi,%eax
  8009b6:	8d 70 01             	lea    0x1(%eax),%esi
  8009b9:	0f b6 00             	movzbl (%eax),%eax
  8009bc:	0f be d8             	movsbl %al,%ebx
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	74 10                	je     8009d3 <vprintfmt+0x245>
  8009c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009c7:	78 b3                	js     80097c <vprintfmt+0x1ee>
  8009c9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009d1:	79 a9                	jns    80097c <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d3:	eb 17                	jmp    8009ec <vprintfmt+0x25e>
				putch(' ', putdat);
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009f0:	7f e3                	jg     8009d5 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009f2:	e9 70 01 00 00       	jmp    800b67 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	e8 3e fd ff ff       	call   800747 <getint>
  800a09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a15:	85 d2                	test   %edx,%edx
  800a17:	79 26                	jns    800a3f <vprintfmt+0x2b1>
				putch('-', putdat);
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	ff d0                	call   *%eax
				num = -(long long) num;
  800a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a32:	f7 d8                	neg    %eax
  800a34:	83 d2 00             	adc    $0x0,%edx
  800a37:	f7 da                	neg    %edx
  800a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a3c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a3f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a46:	e9 a8 00 00 00       	jmp    800af3 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a52:	8d 45 14             	lea    0x14(%ebp),%eax
  800a55:	89 04 24             	mov    %eax,(%esp)
  800a58:	e8 9b fc ff ff       	call   8006f8 <getuint>
  800a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a60:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a63:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a6a:	e9 84 00 00 00       	jmp    800af3 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a76:	8d 45 14             	lea    0x14(%ebp),%eax
  800a79:	89 04 24             	mov    %eax,(%esp)
  800a7c:	e8 77 fc ff ff       	call   8006f8 <getuint>
  800a81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a84:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a87:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a8e:	eb 63                	jmp    800af3 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a97:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	ff d0                	call   *%eax
			putch('x', putdat);
  800aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaa:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	8d 50 04             	lea    0x4(%eax),%edx
  800abc:	89 55 14             	mov    %edx,0x14(%ebp)
  800abf:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ac1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800acb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ad2:	eb 1f                	jmp    800af3 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adb:	8d 45 14             	lea    0x14(%ebp),%eax
  800ade:	89 04 24             	mov    %eax,(%esp)
  800ae1:	e8 12 fc ff ff       	call   8006f8 <getuint>
  800ae6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ae9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aec:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af3:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afa:	89 54 24 18          	mov    %edx,0x18(%esp)
  800afe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b01:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b13:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	89 04 24             	mov    %eax,(%esp)
  800b24:	e8 f1 fa ff ff       	call   80061a <printnum>
			break;
  800b29:	eb 3c                	jmp    800b67 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b32:	89 1c 24             	mov    %ebx,(%esp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	ff d0                	call   *%eax
			break;
  800b3a:	eb 2b                	jmp    800b67 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b43:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b4f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b53:	eb 04                	jmp    800b59 <vprintfmt+0x3cb>
  800b55:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b59:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5c:	83 e8 01             	sub    $0x1,%eax
  800b5f:	0f b6 00             	movzbl (%eax),%eax
  800b62:	3c 25                	cmp    $0x25,%al
  800b64:	75 ef                	jne    800b55 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b66:	90                   	nop
		}
	}
  800b67:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b68:	e9 43 fc ff ff       	jmp    8007b0 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b6d:	83 c4 40             	add    $0x40,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b7a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b87:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	89 04 24             	mov    %eax,(%esp)
  800b9b:	e8 ee fb ff ff       	call   80078e <vprintfmt>
	va_end(ap);
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	8b 40 08             	mov    0x8(%eax),%eax
  800bab:	8d 50 01             	lea    0x1(%eax),%edx
  800bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb1:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb7:	8b 10                	mov    (%eax),%edx
  800bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbc:	8b 40 04             	mov    0x4(%eax),%eax
  800bbf:	39 c2                	cmp    %eax,%edx
  800bc1:	73 12                	jae    800bd5 <sprintputch+0x33>
		*b->buf++ = ch;
  800bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc6:	8b 00                	mov    (%eax),%eax
  800bc8:	8d 48 01             	lea    0x1(%eax),%ecx
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bce:	89 0a                	mov    %ecx,(%edx)
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	88 10                	mov    %dl,(%eax)
}
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800be9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bec:	01 d0                	add    %edx,%eax
  800bee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bf1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bfc:	74 06                	je     800c04 <vsnprintf+0x2d>
  800bfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c02:	7f 07                	jg     800c0b <vsnprintf+0x34>
		return -E_INVAL;
  800c04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c09:	eb 2a                	jmp    800c35 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c12:	8b 45 10             	mov    0x10(%ebp),%eax
  800c15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c19:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c20:	c7 04 24 a2 0b 80 00 	movl   $0x800ba2,(%esp)
  800c27:	e8 62 fb ff ff       	call   80078e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c2f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800c40:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	e8 74 ff ff ff       	call   800bd7 <vsnprintf>
  800c63:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c71:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c78:	eb 08                	jmp    800c82 <strlen+0x17>
		n++;
  800c7a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c7e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	0f b6 00             	movzbl (%eax),%eax
  800c88:	84 c0                	test   %al,%al
  800c8a:	75 ee                	jne    800c7a <strlen+0xf>
		n++;
	return n;
  800c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c97:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c9e:	eb 0c                	jmp    800cac <strnlen+0x1b>
		n++;
  800ca0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca8:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb0:	74 0a                	je     800cbc <strnlen+0x2b>
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	0f b6 00             	movzbl (%eax),%eax
  800cb8:	84 c0                	test   %al,%al
  800cba:	75 e4                	jne    800ca0 <strnlen+0xf>
		n++;
	return n;
  800cbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800ccd:	90                   	nop
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	8d 50 01             	lea    0x1(%eax),%edx
  800cd4:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cda:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cdd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ce0:	0f b6 12             	movzbl (%edx),%edx
  800ce3:	88 10                	mov    %dl,(%eax)
  800ce5:	0f b6 00             	movzbl (%eax),%eax
  800ce8:	84 c0                	test   %al,%al
  800cea:	75 e2                	jne    800cce <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cec:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	89 04 24             	mov    %eax,(%esp)
  800cfd:	e8 69 ff ff ff       	call   800c6b <strlen>
  800d02:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d05:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	01 c2                	add    %eax,%edx
  800d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d14:	89 14 24             	mov    %edx,(%esp)
  800d17:	e8 a5 ff ff ff       	call   800cc1 <strcpy>
	return dst;
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d2d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d34:	eb 23                	jmp    800d59 <strncpy+0x38>
		*dst++ = *src;
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	8d 50 01             	lea    0x1(%eax),%edx
  800d3c:	89 55 08             	mov    %edx,0x8(%ebp)
  800d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d42:	0f b6 12             	movzbl (%edx),%edx
  800d45:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4a:	0f b6 00             	movzbl (%eax),%eax
  800d4d:	84 c0                	test   %al,%al
  800d4f:	74 04                	je     800d55 <strncpy+0x34>
			src++;
  800d51:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d55:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d59:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d5c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d5f:	72 d5                	jb     800d36 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d61:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    

00800d66 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d76:	74 33                	je     800dab <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d78:	eb 17                	jmp    800d91 <strlcpy+0x2b>
			*dst++ = *src++;
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	8d 50 01             	lea    0x1(%eax),%edx
  800d80:	89 55 08             	mov    %edx,0x8(%ebp)
  800d83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d86:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d89:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d8c:	0f b6 12             	movzbl (%edx),%edx
  800d8f:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d91:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d99:	74 0a                	je     800da5 <strlcpy+0x3f>
  800d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9e:	0f b6 00             	movzbl (%eax),%eax
  800da1:	84 c0                	test   %al,%al
  800da3:	75 d5                	jne    800d7a <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800db1:	29 c2                	sub    %eax,%edx
  800db3:	89 d0                	mov    %edx,%eax
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dba:	eb 08                	jmp    800dc4 <strcmp+0xd>
		p++, q++;
  800dbc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	0f b6 00             	movzbl (%eax),%eax
  800dca:	84 c0                	test   %al,%al
  800dcc:	74 10                	je     800dde <strcmp+0x27>
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	0f b6 10             	movzbl (%eax),%edx
  800dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd7:	0f b6 00             	movzbl (%eax),%eax
  800dda:	38 c2                	cmp    %al,%dl
  800ddc:	74 de                	je     800dbc <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	0f b6 00             	movzbl (%eax),%eax
  800de4:	0f b6 d0             	movzbl %al,%edx
  800de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dea:	0f b6 00             	movzbl (%eax),%eax
  800ded:	0f b6 c0             	movzbl %al,%eax
  800df0:	29 c2                	sub    %eax,%edx
  800df2:	89 d0                	mov    %edx,%eax
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800df9:	eb 0c                	jmp    800e07 <strncmp+0x11>
		n--, p++, q++;
  800dfb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e03:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e0b:	74 1a                	je     800e27 <strncmp+0x31>
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	0f b6 00             	movzbl (%eax),%eax
  800e13:	84 c0                	test   %al,%al
  800e15:	74 10                	je     800e27 <strncmp+0x31>
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 10             	movzbl (%eax),%edx
  800e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e20:	0f b6 00             	movzbl (%eax),%eax
  800e23:	38 c2                	cmp    %al,%dl
  800e25:	74 d4                	je     800dfb <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e2b:	75 07                	jne    800e34 <strncmp+0x3e>
		return 0;
  800e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e32:	eb 16                	jmp    800e4a <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	0f b6 00             	movzbl (%eax),%eax
  800e3a:	0f b6 d0             	movzbl %al,%edx
  800e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e40:	0f b6 00             	movzbl (%eax),%eax
  800e43:	0f b6 c0             	movzbl %al,%eax
  800e46:	29 c2                	sub    %eax,%edx
  800e48:	89 d0                	mov    %edx,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e55:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e58:	eb 14                	jmp    800e6e <strchr+0x22>
		if (*s == c)
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	0f b6 00             	movzbl (%eax),%eax
  800e60:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e63:	75 05                	jne    800e6a <strchr+0x1e>
			return (char *) s;
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	eb 13                	jmp    800e7d <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	0f b6 00             	movzbl (%eax),%eax
  800e74:	84 c0                	test   %al,%al
  800e76:	75 e2                	jne    800e5a <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 04             	sub    $0x4,%esp
  800e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e88:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e8b:	eb 11                	jmp    800e9e <strfind+0x1f>
		if (*s == c)
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	0f b6 00             	movzbl (%eax),%eax
  800e93:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e96:	75 02                	jne    800e9a <strfind+0x1b>
			break;
  800e98:	eb 0e                	jmp    800ea8 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e9a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	0f b6 00             	movzbl (%eax),%eax
  800ea4:	84 c0                	test   %al,%al
  800ea6:	75 e5                	jne    800e8d <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
	char *p;

	if (n == 0)
  800eb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb5:	75 05                	jne    800ebc <memset+0xf>
		return v;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	eb 5c                	jmp    800f18 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	83 e0 03             	and    $0x3,%eax
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	75 41                	jne    800f07 <memset+0x5a>
  800ec6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec9:	83 e0 03             	and    $0x3,%eax
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	75 37                	jne    800f07 <memset+0x5a>
		c &= 0xFF;
  800ed0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eda:	c1 e0 18             	shl    $0x18,%eax
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee2:	c1 e0 10             	shl    $0x10,%eax
  800ee5:	09 c2                	or     %eax,%edx
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	c1 e0 08             	shl    $0x8,%eax
  800eed:	09 d0                	or     %edx,%eax
  800eef:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef5:	c1 e8 02             	shr    $0x2,%eax
  800ef8:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f00:	89 d7                	mov    %edx,%edi
  800f02:	fc                   	cld    
  800f03:	f3 ab                	rep stos %eax,%es:(%edi)
  800f05:	eb 0e                	jmp    800f15 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f10:	89 d7                	mov    %edx,%edi
  800f12:	fc                   	cld    
  800f13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f33:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f36:	73 6d                	jae    800fa5 <memmove+0x8a>
  800f38:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3e:	01 d0                	add    %edx,%eax
  800f40:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f43:	76 60                	jbe    800fa5 <memmove+0x8a>
		s += n;
  800f45:	8b 45 10             	mov    0x10(%ebp),%eax
  800f48:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4e:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f54:	83 e0 03             	and    $0x3,%eax
  800f57:	85 c0                	test   %eax,%eax
  800f59:	75 2f                	jne    800f8a <memmove+0x6f>
  800f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5e:	83 e0 03             	and    $0x3,%eax
  800f61:	85 c0                	test   %eax,%eax
  800f63:	75 25                	jne    800f8a <memmove+0x6f>
  800f65:	8b 45 10             	mov    0x10(%ebp),%eax
  800f68:	83 e0 03             	and    $0x3,%eax
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	75 1b                	jne    800f8a <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f72:	83 e8 04             	sub    $0x4,%eax
  800f75:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f78:	83 ea 04             	sub    $0x4,%edx
  800f7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f7e:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f81:	89 c7                	mov    %eax,%edi
  800f83:	89 d6                	mov    %edx,%esi
  800f85:	fd                   	std    
  800f86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f88:	eb 18                	jmp    800fa2 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f8d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f93:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f96:	8b 45 10             	mov    0x10(%ebp),%eax
  800f99:	89 d7                	mov    %edx,%edi
  800f9b:	89 de                	mov    %ebx,%esi
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	fd                   	std    
  800fa0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa2:	fc                   	cld    
  800fa3:	eb 45                	jmp    800fea <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa8:	83 e0 03             	and    $0x3,%eax
  800fab:	85 c0                	test   %eax,%eax
  800fad:	75 2b                	jne    800fda <memmove+0xbf>
  800faf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fb2:	83 e0 03             	and    $0x3,%eax
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	75 21                	jne    800fda <memmove+0xbf>
  800fb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbc:	83 e0 03             	and    $0x3,%eax
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	75 17                	jne    800fda <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc6:	c1 e8 02             	shr    $0x2,%eax
  800fc9:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fd1:	89 c7                	mov    %eax,%edi
  800fd3:	89 d6                	mov    %edx,%esi
  800fd5:	fc                   	cld    
  800fd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd8:	eb 10                	jmp    800fea <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fda:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fdd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe3:	89 c7                	mov    %eax,%edi
  800fe5:	89 d6                	mov    %edx,%esi
  800fe7:	fc                   	cld    
  800fe8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fed:	83 c4 10             	add    $0x10,%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801002:	8b 45 0c             	mov    0xc(%ebp),%eax
  801005:	89 44 24 04          	mov    %eax,0x4(%esp)
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	89 04 24             	mov    %eax,(%esp)
  80100f:	e8 07 ff ff ff       	call   800f1b <memmove>
}
  801014:	c9                   	leave  
  801015:	c3                   	ret    

00801016 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801022:	8b 45 0c             	mov    0xc(%ebp),%eax
  801025:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801028:	eb 30                	jmp    80105a <memcmp+0x44>
		if (*s1 != *s2)
  80102a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80102d:	0f b6 10             	movzbl (%eax),%edx
  801030:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801033:	0f b6 00             	movzbl (%eax),%eax
  801036:	38 c2                	cmp    %al,%dl
  801038:	74 18                	je     801052 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80103a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80103d:	0f b6 00             	movzbl (%eax),%eax
  801040:	0f b6 d0             	movzbl %al,%edx
  801043:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801046:	0f b6 00             	movzbl (%eax),%eax
  801049:	0f b6 c0             	movzbl %al,%eax
  80104c:	29 c2                	sub    %eax,%edx
  80104e:	89 d0                	mov    %edx,%eax
  801050:	eb 1a                	jmp    80106c <memcmp+0x56>
		s1++, s2++;
  801052:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801056:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80105a:	8b 45 10             	mov    0x10(%ebp),%eax
  80105d:	8d 50 ff             	lea    -0x1(%eax),%edx
  801060:	89 55 10             	mov    %edx,0x10(%ebp)
  801063:	85 c0                	test   %eax,%eax
  801065:	75 c3                	jne    80102a <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801067:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801074:	8b 45 10             	mov    0x10(%ebp),%eax
  801077:	8b 55 08             	mov    0x8(%ebp),%edx
  80107a:	01 d0                	add    %edx,%eax
  80107c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80107f:	eb 13                	jmp    801094 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801081:	8b 45 08             	mov    0x8(%ebp),%eax
  801084:	0f b6 10             	movzbl (%eax),%edx
  801087:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108a:	38 c2                	cmp    %al,%dl
  80108c:	75 02                	jne    801090 <memfind+0x22>
			break;
  80108e:	eb 0c                	jmp    80109c <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801090:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80109a:	72 e5                	jb     801081 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80109f:	c9                   	leave  
  8010a0:	c3                   	ret    

008010a1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010ae:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b5:	eb 04                	jmp    8010bb <strtol+0x1a>
		s++;
  8010b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	0f b6 00             	movzbl (%eax),%eax
  8010c1:	3c 20                	cmp    $0x20,%al
  8010c3:	74 f2                	je     8010b7 <strtol+0x16>
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	0f b6 00             	movzbl (%eax),%eax
  8010cb:	3c 09                	cmp    $0x9,%al
  8010cd:	74 e8                	je     8010b7 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	0f b6 00             	movzbl (%eax),%eax
  8010d5:	3c 2b                	cmp    $0x2b,%al
  8010d7:	75 06                	jne    8010df <strtol+0x3e>
		s++;
  8010d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010dd:	eb 15                	jmp    8010f4 <strtol+0x53>
	else if (*s == '-')
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	0f b6 00             	movzbl (%eax),%eax
  8010e5:	3c 2d                	cmp    $0x2d,%al
  8010e7:	75 0b                	jne    8010f4 <strtol+0x53>
		s++, neg = 1;
  8010e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ed:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010f8:	74 06                	je     801100 <strtol+0x5f>
  8010fa:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010fe:	75 24                	jne    801124 <strtol+0x83>
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	0f b6 00             	movzbl (%eax),%eax
  801106:	3c 30                	cmp    $0x30,%al
  801108:	75 1a                	jne    801124 <strtol+0x83>
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	83 c0 01             	add    $0x1,%eax
  801110:	0f b6 00             	movzbl (%eax),%eax
  801113:	3c 78                	cmp    $0x78,%al
  801115:	75 0d                	jne    801124 <strtol+0x83>
		s += 2, base = 16;
  801117:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80111b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801122:	eb 2a                	jmp    80114e <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801124:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801128:	75 17                	jne    801141 <strtol+0xa0>
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	0f b6 00             	movzbl (%eax),%eax
  801130:	3c 30                	cmp    $0x30,%al
  801132:	75 0d                	jne    801141 <strtol+0xa0>
		s++, base = 8;
  801134:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801138:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80113f:	eb 0d                	jmp    80114e <strtol+0xad>
	else if (base == 0)
  801141:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801145:	75 07                	jne    80114e <strtol+0xad>
		base = 10;
  801147:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	0f b6 00             	movzbl (%eax),%eax
  801154:	3c 2f                	cmp    $0x2f,%al
  801156:	7e 1b                	jle    801173 <strtol+0xd2>
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	0f b6 00             	movzbl (%eax),%eax
  80115e:	3c 39                	cmp    $0x39,%al
  801160:	7f 11                	jg     801173 <strtol+0xd2>
			dig = *s - '0';
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	0f b6 00             	movzbl (%eax),%eax
  801168:	0f be c0             	movsbl %al,%eax
  80116b:	83 e8 30             	sub    $0x30,%eax
  80116e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801171:	eb 48                	jmp    8011bb <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	0f b6 00             	movzbl (%eax),%eax
  801179:	3c 60                	cmp    $0x60,%al
  80117b:	7e 1b                	jle    801198 <strtol+0xf7>
  80117d:	8b 45 08             	mov    0x8(%ebp),%eax
  801180:	0f b6 00             	movzbl (%eax),%eax
  801183:	3c 7a                	cmp    $0x7a,%al
  801185:	7f 11                	jg     801198 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	0f b6 00             	movzbl (%eax),%eax
  80118d:	0f be c0             	movsbl %al,%eax
  801190:	83 e8 57             	sub    $0x57,%eax
  801193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801196:	eb 23                	jmp    8011bb <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	0f b6 00             	movzbl (%eax),%eax
  80119e:	3c 40                	cmp    $0x40,%al
  8011a0:	7e 3d                	jle    8011df <strtol+0x13e>
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	0f b6 00             	movzbl (%eax),%eax
  8011a8:	3c 5a                	cmp    $0x5a,%al
  8011aa:	7f 33                	jg     8011df <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8011af:	0f b6 00             	movzbl (%eax),%eax
  8011b2:	0f be c0             	movsbl %al,%eax
  8011b5:	83 e8 37             	sub    $0x37,%eax
  8011b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011be:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011c1:	7c 02                	jl     8011c5 <strtol+0x124>
			break;
  8011c3:	eb 1a                	jmp    8011df <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011c9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011cc:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011d0:	89 c2                	mov    %eax,%edx
  8011d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d5:	01 d0                	add    %edx,%eax
  8011d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011da:	e9 6f ff ff ff       	jmp    80114e <strtol+0xad>

	if (endptr)
  8011df:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011e3:	74 08                	je     8011ed <strtol+0x14c>
		*endptr = (char *) s;
  8011e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011eb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011ed:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011f1:	74 07                	je     8011fa <strtol+0x159>
  8011f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011f6:	f7 d8                	neg    %eax
  8011f8:	eb 03                	jmp    8011fd <strtol+0x15c>
  8011fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    
  8011ff:	90                   	nop

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
