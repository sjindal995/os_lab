
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
  80003f:	e8 82 01 00 00       	call   8001c6 <sys_getenvid>
  800044:	25 ff 03 00 00       	and    $0x3ff,%eax
  800049:	c1 e0 02             	shl    $0x2,%eax
  80004c:	89 c2                	mov    %eax,%edx
  80004e:	c1 e2 05             	shl    $0x5,%edx
  800051:	29 c2                	sub    %eax,%edx
  800053:	89 d0                	mov    %edx,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800063:	7e 0a                	jle    80006f <libmain+0x36>
		binaryname = argv[0];
  800065:	8b 45 0c             	mov    0xc(%ebp),%eax
  800068:	8b 00                	mov    (%eax),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800072:	89 44 24 04          	mov    %eax,0x4(%esp)
  800076:	8b 45 08             	mov    0x8(%ebp),%eax
  800079:	89 04 24             	mov    %eax,(%esp)
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 02 00 00 00       	call   800088 <exit>
}
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 e9 00 00 00       	call   800183 <sys_env_destroy>
}
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a8:	8b 55 10             	mov    0x10(%ebp),%edx
  8000ab:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000ae:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000b4:	8b 75 20             	mov    0x20(%ebp),%esi
  8000b7:	cd 30                	int    $0x30
  8000b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c0:	74 30                	je     8000f2 <syscall+0x56>
  8000c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c6:	7e 2a                	jle    8000f2 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d6:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8000dd:	00 
  8000de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8000ed:	e8 2c 03 00 00       	call   80041e <_panic>

	return ret;
  8000f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000f5:	83 c4 3c             	add    $0x3c,%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800103:	8b 45 08             	mov    0x8(%ebp),%eax
  800106:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80010d:	00 
  80010e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800115:	00 
  800116:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80011d:	00 
  80011e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800121:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800125:	89 44 24 08          	mov    %eax,0x8(%esp)
  800129:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800130:	00 
  800131:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800138:	e8 5f ff ff ff       	call   80009c <syscall>
}
  80013d:	c9                   	leave  
  80013e:	c3                   	ret    

0080013f <sys_cgetc>:

int
sys_cgetc(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800145:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80014c:	00 
  80014d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800154:	00 
  800155:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80015c:	00 
  80015d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800164:	00 
  800165:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80016c:	00 
  80016d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800174:	00 
  800175:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80017c:	e8 1b ff ff ff       	call   80009c <syscall>
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800193:	00 
  800194:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80019b:	00 
  80019c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ab:	00 
  8001ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001b7:	00 
  8001b8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001bf:	e8 d8 fe ff ff       	call   80009c <syscall>
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    

008001c6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001cc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d3:	00 
  8001d4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001db:	00 
  8001dc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001eb:	00 
  8001ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f3:	00 
  8001f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001fb:	00 
  8001fc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800203:	e8 94 fe ff ff       	call   80009c <syscall>
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    

0080020a <sys_yield>:

void
sys_yield(void)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800210:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800217:	00 
  800218:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80021f:	00 
  800220:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800227:	00 
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800237:	00 
  800238:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80023f:	00 
  800240:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800247:	e8 50 fe ff ff       	call   80009c <syscall>
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800254:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800264:	00 
  800265:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80026c:	00 
  80026d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800271:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800275:	89 44 24 08          	mov    %eax,0x8(%esp)
  800279:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800288:	e8 0f fe ff ff       	call   80009c <syscall>
}
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	56                   	push   %esi
  800293:	53                   	push   %ebx
  800294:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800297:	8b 75 18             	mov    0x18(%ebp),%esi
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002aa:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ae:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002c9:	e8 ce fd ff ff       	call   80009c <syscall>
}
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002f8:	00 
  8002f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800301:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800310:	e8 87 fd ff ff       	call   80009c <syscall>
}
  800315:	c9                   	leave  
  800316:	c3                   	ret    

00800317 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80031d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80032a:	00 
  80032b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800332:	00 
  800333:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80033a:	00 
  80033b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034a:	00 
  80034b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800352:	e8 45 fd ff ff       	call   80009c <syscall>
}
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80035f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80036c:	00 
  80036d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800374:	00 
  800375:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80037c:	00 
  80037d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800381:	89 44 24 08          	mov    %eax,0x8(%esp)
  800385:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80038c:	00 
  80038d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800394:	e8 03 fd ff ff       	call   80009c <syscall>
}
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b1:	00 
  8003b2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003b6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003cc:	00 
  8003cd:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003d4:	e8 c3 fc ff ff       	call   80009c <syscall>
}
  8003d9:	c9                   	leave  
  8003da:	c3                   	ret    

008003db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003eb:	00 
  8003ec:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003f3:	00 
  8003f4:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003fb:	00 
  8003fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800403:	00 
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80040f:	00 
  800410:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800417:	e8 80 fc ff ff       	call   80009c <syscall>
}
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	53                   	push   %ebx
  800422:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800425:	8d 45 14             	lea    0x14(%ebp),%eax
  800428:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800431:	e8 90 fd ff ff       	call   8001c6 <sys_getenvid>
  800436:	8b 55 0c             	mov    0xc(%ebp),%edx
  800439:	89 54 24 10          	mov    %edx,0x10(%esp)
  80043d:	8b 55 08             	mov    0x8(%ebp),%edx
  800440:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  800453:	e8 e1 00 00 00       	call   800539 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80045b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045f:	8b 45 10             	mov    0x10(%ebp),%eax
  800462:	89 04 24             	mov    %eax,(%esp)
  800465:	e8 6b 00 00 00       	call   8004d5 <vcprintf>
	cprintf("\n");
  80046a:	c7 04 24 3b 14 80 00 	movl   $0x80143b,(%esp)
  800471:	e8 c3 00 00 00       	call   800539 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800476:	cc                   	int3   
  800477:	eb fd                	jmp    800476 <_panic+0x58>

00800479 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	8b 00                	mov    (%eax),%eax
  800484:	8d 48 01             	lea    0x1(%eax),%ecx
  800487:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048a:	89 0a                	mov    %ecx,(%edx)
  80048c:	8b 55 08             	mov    0x8(%ebp),%edx
  80048f:	89 d1                	mov    %edx,%ecx
  800491:	8b 55 0c             	mov    0xc(%ebp),%edx
  800494:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a2:	75 20                	jne    8004c4 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	8b 00                	mov    (%eax),%eax
  8004a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ac:	83 c2 08             	add    $0x8,%edx
  8004af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b3:	89 14 24             	mov    %edx,(%esp)
  8004b6:	e8 42 fc ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	8b 40 04             	mov    0x4(%eax),%eax
  8004ca:	8d 50 01             	lea    0x1(%eax),%edx
  8004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d0:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    

008004d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e5:	00 00 00 
	b.cnt = 0;
  8004e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800500:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050a:	c7 04 24 79 04 80 00 	movl   $0x800479,(%esp)
  800511:	e8 bd 01 00 00       	call   8006d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800516:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800526:	83 c0 08             	add    $0x8,%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 cc fb ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
  800531:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800537:	c9                   	leave  
  800538:	c3                   	ret    

00800539 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800542:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800545:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	8b 45 08             	mov    0x8(%ebp),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 7e ff ff ff       	call   8004d5 <vcprintf>
  800557:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80055a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	53                   	push   %ebx
  800563:	83 ec 34             	sub    $0x34,%esp
  800566:	8b 45 10             	mov    0x10(%ebp),%eax
  800569:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800572:	8b 45 18             	mov    0x18(%ebp),%eax
  800575:	ba 00 00 00 00       	mov    $0x0,%edx
  80057a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80057d:	77 72                	ja     8005f1 <printnum+0x92>
  80057f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800582:	72 05                	jb     800589 <printnum+0x2a>
  800584:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800587:	77 68                	ja     8005f1 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800589:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80058c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80058f:	8b 45 18             	mov    0x18(%ebp),%eax
  800592:	ba 00 00 00 00       	mov    $0x0,%edx
  800597:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ac:	e8 9f 0b 00 00       	call   801150 <__udivdi3>
  8005b1:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005b4:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005b8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005bc:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005bf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d5:	89 04 24             	mov    %eax,(%esp)
  8005d8:	e8 82 ff ff ff       	call   80055f <printnum>
  8005dd:	eb 1c                	jmp    8005fb <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e6:	8b 45 20             	mov    0x20(%ebp),%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ef:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f1:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005f5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8005f9:	7f e4                	jg     8005df <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005fb:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800606:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800609:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800611:	89 04 24             	mov    %eax,(%esp)
  800614:	89 54 24 04          	mov    %edx,0x4(%esp)
  800618:	e8 63 0c 00 00       	call   801280 <__umoddi3>
  80061d:	05 08 15 80 00       	add    $0x801508,%eax
  800622:	0f b6 00             	movzbl (%eax),%eax
  800625:	0f be c0             	movsbl %al,%eax
  800628:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	8b 45 08             	mov    0x8(%ebp),%eax
  800635:	ff d0                	call   *%eax
}
  800637:	83 c4 34             	add    $0x34,%esp
  80063a:	5b                   	pop    %ebx
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800640:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800644:	7e 14                	jle    80065a <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800646:	8b 45 08             	mov    0x8(%ebp),%eax
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	8d 48 08             	lea    0x8(%eax),%ecx
  80064e:	8b 55 08             	mov    0x8(%ebp),%edx
  800651:	89 0a                	mov    %ecx,(%edx)
  800653:	8b 50 04             	mov    0x4(%eax),%edx
  800656:	8b 00                	mov    (%eax),%eax
  800658:	eb 30                	jmp    80068a <getuint+0x4d>
	else if (lflag)
  80065a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80065e:	74 16                	je     800676 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	8b 00                	mov    (%eax),%eax
  800665:	8d 48 04             	lea    0x4(%eax),%ecx
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	89 0a                	mov    %ecx,(%edx)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	ba 00 00 00 00       	mov    $0x0,%edx
  800674:	eb 14                	jmp    80068a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	8d 48 04             	lea    0x4(%eax),%ecx
  80067e:	8b 55 08             	mov    0x8(%ebp),%edx
  800681:	89 0a                	mov    %ecx,(%edx)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068a:	5d                   	pop    %ebp
  80068b:	c3                   	ret    

0080068c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80068c:	55                   	push   %ebp
  80068d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800693:	7e 14                	jle    8006a9 <getint+0x1d>
		return va_arg(*ap, long long);
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	8d 48 08             	lea    0x8(%eax),%ecx
  80069d:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a0:	89 0a                	mov    %ecx,(%edx)
  8006a2:	8b 50 04             	mov    0x4(%eax),%edx
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	eb 28                	jmp    8006d1 <getint+0x45>
	else if (lflag)
  8006a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006ad:	74 12                	je     8006c1 <getint+0x35>
		return va_arg(*ap, long);
  8006af:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ba:	89 0a                	mov    %ecx,(%edx)
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	99                   	cltd   
  8006bf:	eb 10                	jmp    8006d1 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cc:	89 0a                	mov    %ecx,(%edx)
  8006ce:	8b 00                	mov    (%eax),%eax
  8006d0:	99                   	cltd   
}
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006db:	eb 18                	jmp    8006f5 <vprintfmt+0x22>
			if (ch == '\0')
  8006dd:	85 db                	test   %ebx,%ebx
  8006df:	75 05                	jne    8006e6 <vprintfmt+0x13>
				return;
  8006e1:	e9 cc 03 00 00       	jmp    800ab2 <vprintfmt+0x3df>
			putch(ch, putdat);
  8006e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ed:	89 1c 24             	mov    %ebx,(%esp)
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f8:	8d 50 01             	lea    0x1(%eax),%edx
  8006fb:	89 55 10             	mov    %edx,0x10(%ebp)
  8006fe:	0f b6 00             	movzbl (%eax),%eax
  800701:	0f b6 d8             	movzbl %al,%ebx
  800704:	83 fb 25             	cmp    $0x25,%ebx
  800707:	75 d4                	jne    8006dd <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800709:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80070d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800714:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80071b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800722:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 45 10             	mov    0x10(%ebp),%eax
  80072c:	8d 50 01             	lea    0x1(%eax),%edx
  80072f:	89 55 10             	mov    %edx,0x10(%ebp)
  800732:	0f b6 00             	movzbl (%eax),%eax
  800735:	0f b6 d8             	movzbl %al,%ebx
  800738:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80073b:	83 f8 55             	cmp    $0x55,%eax
  80073e:	0f 87 3d 03 00 00    	ja     800a81 <vprintfmt+0x3ae>
  800744:	8b 04 85 2c 15 80 00 	mov    0x80152c(,%eax,4),%eax
  80074b:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80074d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800751:	eb d6                	jmp    800729 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800753:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800757:	eb d0                	jmp    800729 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800759:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800760:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800763:	89 d0                	mov    %edx,%eax
  800765:	c1 e0 02             	shl    $0x2,%eax
  800768:	01 d0                	add    %edx,%eax
  80076a:	01 c0                	add    %eax,%eax
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	83 e8 30             	sub    $0x30,%eax
  800771:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800774:	8b 45 10             	mov    0x10(%ebp),%eax
  800777:	0f b6 00             	movzbl (%eax),%eax
  80077a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80077d:	83 fb 2f             	cmp    $0x2f,%ebx
  800780:	7e 0b                	jle    80078d <vprintfmt+0xba>
  800782:	83 fb 39             	cmp    $0x39,%ebx
  800785:	7f 06                	jg     80078d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800787:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078b:	eb d3                	jmp    800760 <vprintfmt+0x8d>
			goto process_precision;
  80078d:	eb 33                	jmp    8007c2 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80079d:	eb 23                	jmp    8007c2 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80079f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a3:	79 0c                	jns    8007b1 <vprintfmt+0xde>
				width = 0;
  8007a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007ac:	e9 78 ff ff ff       	jmp    800729 <vprintfmt+0x56>
  8007b1:	e9 73 ff ff ff       	jmp    800729 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007bd:	e9 67 ff ff ff       	jmp    800729 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c6:	79 12                	jns    8007da <vprintfmt+0x107>
				width = precision, precision = -1;
  8007c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007d5:	e9 4f ff ff ff       	jmp    800729 <vprintfmt+0x56>
  8007da:	e9 4a ff ff ff       	jmp    800729 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007df:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007e3:	e9 41 ff ff ff       	jmp    800729 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fa:	89 04 24             	mov    %eax,(%esp)
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	ff d0                	call   *%eax
			break;
  800802:	e9 a5 02 00 00       	jmp    800aac <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800812:	85 db                	test   %ebx,%ebx
  800814:	79 02                	jns    800818 <vprintfmt+0x145>
				err = -err;
  800816:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800818:	83 fb 09             	cmp    $0x9,%ebx
  80081b:	7f 0b                	jg     800828 <vprintfmt+0x155>
  80081d:	8b 34 9d e0 14 80 00 	mov    0x8014e0(,%ebx,4),%esi
  800824:	85 f6                	test   %esi,%esi
  800826:	75 23                	jne    80084b <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800828:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80082c:	c7 44 24 08 19 15 80 	movl   $0x801519,0x8(%esp)
  800833:	00 
  800834:	8b 45 0c             	mov    0xc(%ebp),%eax
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	e8 73 02 00 00       	call   800ab9 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800846:	e9 61 02 00 00       	jmp    800aac <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80084b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80084f:	c7 44 24 08 22 15 80 	movl   $0x801522,0x8(%esp)
  800856:	00 
  800857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	89 04 24             	mov    %eax,(%esp)
  800864:	e8 50 02 00 00       	call   800ab9 <printfmt>
			break;
  800869:	e9 3e 02 00 00       	jmp    800aac <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8d 50 04             	lea    0x4(%eax),%edx
  800874:	89 55 14             	mov    %edx,0x14(%ebp)
  800877:	8b 30                	mov    (%eax),%esi
  800879:	85 f6                	test   %esi,%esi
  80087b:	75 05                	jne    800882 <vprintfmt+0x1af>
				p = "(null)";
  80087d:	be 25 15 80 00       	mov    $0x801525,%esi
			if (width > 0 && padc != '-')
  800882:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800886:	7e 37                	jle    8008bf <vprintfmt+0x1ec>
  800888:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80088c:	74 31                	je     8008bf <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800891:	89 44 24 04          	mov    %eax,0x4(%esp)
  800895:	89 34 24             	mov    %esi,(%esp)
  800898:	e8 39 03 00 00       	call   800bd6 <strnlen>
  80089d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008a0:	eb 17                	jmp    8008b9 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008a2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ad:	89 04 24             	mov    %eax,(%esp)
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008bd:	7f e3                	jg     8008a2 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bf:	eb 38                	jmp    8008f9 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c5:	74 1f                	je     8008e6 <vprintfmt+0x213>
  8008c7:	83 fb 1f             	cmp    $0x1f,%ebx
  8008ca:	7e 05                	jle    8008d1 <vprintfmt+0x1fe>
  8008cc:	83 fb 7e             	cmp    $0x7e,%ebx
  8008cf:	7e 15                	jle    8008e6 <vprintfmt+0x213>
					putch('?', putdat);
  8008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	ff d0                	call   *%eax
  8008e4:	eb 0f                	jmp    8008f5 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ed:	89 1c 24             	mov    %ebx,(%esp)
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	8d 70 01             	lea    0x1(%eax),%esi
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	0f be d8             	movsbl %al,%ebx
  800904:	85 db                	test   %ebx,%ebx
  800906:	74 10                	je     800918 <vprintfmt+0x245>
  800908:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80090c:	78 b3                	js     8008c1 <vprintfmt+0x1ee>
  80090e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800912:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800916:	79 a9                	jns    8008c1 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800918:	eb 17                	jmp    800931 <vprintfmt+0x25e>
				putch(' ', putdat);
  80091a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800921:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800931:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800935:	7f e3                	jg     80091a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800937:	e9 70 01 00 00       	jmp    800aac <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80093c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800943:	8d 45 14             	lea    0x14(%ebp),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 3e fd ff ff       	call   80068c <getint>
  80094e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800951:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800954:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800957:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095a:	85 d2                	test   %edx,%edx
  80095c:	79 26                	jns    800984 <vprintfmt+0x2b1>
				putch('-', putdat);
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	89 44 24 04          	mov    %eax,0x4(%esp)
  800965:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	ff d0                	call   *%eax
				num = -(long long) num;
  800971:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800974:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800977:	f7 d8                	neg    %eax
  800979:	83 d2 00             	adc    $0x0,%edx
  80097c:	f7 da                	neg    %edx
  80097e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800981:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800984:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80098b:	e9 a8 00 00 00       	jmp    800a38 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800990:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800993:	89 44 24 04          	mov    %eax,0x4(%esp)
  800997:	8d 45 14             	lea    0x14(%ebp),%eax
  80099a:	89 04 24             	mov    %eax,(%esp)
  80099d:	e8 9b fc ff ff       	call   80063d <getuint>
  8009a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009a8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009af:	e9 84 00 00 00       	jmp    800a38 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 77 fc ff ff       	call   80063d <getuint>
  8009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009cc:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009d3:	eb 63                	jmp    800a38 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	ff d0                	call   *%eax
			putch('x', putdat);
  8009e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fe:	8d 50 04             	lea    0x4(%eax),%edx
  800a01:	89 55 14             	mov    %edx,0x14(%ebp)
  800a04:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a10:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a17:	eb 1f                	jmp    800a38 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	8d 45 14             	lea    0x14(%ebp),%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 12 fc ff ff       	call   80063d <getuint>
  800a2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a2e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a31:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a38:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a3f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a46:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 f1 fa ff ff       	call   80055f <printnum>
			break;
  800a6e:	eb 3c                	jmp    800aac <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a77:	89 1c 24             	mov    %ebx,(%esp)
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	ff d0                	call   *%eax
			break;
  800a7f:	eb 2b                	jmp    800aac <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a88:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a94:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a98:	eb 04                	jmp    800a9e <vprintfmt+0x3cb>
  800a9a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa1:	83 e8 01             	sub    $0x1,%eax
  800aa4:	0f b6 00             	movzbl (%eax),%eax
  800aa7:	3c 25                	cmp    $0x25,%al
  800aa9:	75 ef                	jne    800a9a <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800aab:	90                   	nop
		}
	}
  800aac:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aad:	e9 43 fc ff ff       	jmp    8006f5 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ab2:	83 c4 40             	add    $0x40,%esp
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800abf:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800acc:	8b 45 10             	mov    0x10(%ebp),%eax
  800acf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	89 04 24             	mov    %eax,(%esp)
  800ae0:	e8 ee fb ff ff       	call   8006d3 <vprintfmt>
	va_end(ap);
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	8b 40 08             	mov    0x8(%eax),%eax
  800af0:	8d 50 01             	lea    0x1(%eax),%edx
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	8b 10                	mov    (%eax),%edx
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	8b 40 04             	mov    0x4(%eax),%eax
  800b04:	39 c2                	cmp    %eax,%edx
  800b06:	73 12                	jae    800b1a <sprintputch+0x33>
		*b->buf++ = ch;
  800b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0b:	8b 00                	mov    (%eax),%eax
  800b0d:	8d 48 01             	lea    0x1(%eax),%ecx
  800b10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b13:	89 0a                	mov    %ecx,(%edx)
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	88 10                	mov    %dl,(%eax)
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	01 d0                	add    %edx,%eax
  800b33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b41:	74 06                	je     800b49 <vsnprintf+0x2d>
  800b43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b47:	7f 07                	jg     800b50 <vsnprintf+0x34>
		return -E_INVAL;
  800b49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b4e:	eb 2a                	jmp    800b7a <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b50:	8b 45 14             	mov    0x14(%ebp),%eax
  800b53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	c7 04 24 e7 0a 80 00 	movl   $0x800ae7,(%esp)
  800b6c:	e8 62 fb ff ff       	call   8006d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b74:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b82:	8d 45 14             	lea    0x14(%ebp),%eax
  800b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	89 04 24             	mov    %eax,(%esp)
  800ba3:	e8 74 ff ff ff       	call   800b1c <vsnprintf>
  800ba8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bbd:	eb 08                	jmp    800bc7 <strlen+0x17>
		n++;
  800bbf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	0f b6 00             	movzbl (%eax),%eax
  800bcd:	84 c0                	test   %al,%al
  800bcf:	75 ee                	jne    800bbf <strlen+0xf>
		n++;
	return n;
  800bd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bdc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800be3:	eb 0c                	jmp    800bf1 <strnlen+0x1b>
		n++;
  800be5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bed:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800bf1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf5:	74 0a                	je     800c01 <strnlen+0x2b>
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfa:	0f b6 00             	movzbl (%eax),%eax
  800bfd:	84 c0                	test   %al,%al
  800bff:	75 e4                	jne    800be5 <strnlen+0xf>
		n++;
	return n;
  800c01:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c12:	90                   	nop
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8d 50 01             	lea    0x1(%eax),%edx
  800c19:	89 55 08             	mov    %edx,0x8(%ebp)
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c22:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c25:	0f b6 12             	movzbl (%edx),%edx
  800c28:	88 10                	mov    %dl,(%eax)
  800c2a:	0f b6 00             	movzbl (%eax),%eax
  800c2d:	84 c0                	test   %al,%al
  800c2f:	75 e2                	jne    800c13 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	89 04 24             	mov    %eax,(%esp)
  800c42:	e8 69 ff ff ff       	call   800bb0 <strlen>
  800c47:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c4a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	01 c2                	add    %eax,%edx
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	89 14 24             	mov    %edx,(%esp)
  800c5c:	e8 a5 ff ff ff       	call   800c06 <strcpy>
	return dst;
  800c61:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c79:	eb 23                	jmp    800c9e <strncpy+0x38>
		*dst++ = *src;
  800c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7e:	8d 50 01             	lea    0x1(%eax),%edx
  800c81:	89 55 08             	mov    %edx,0x8(%ebp)
  800c84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c87:	0f b6 12             	movzbl (%edx),%edx
  800c8a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8f:	0f b6 00             	movzbl (%eax),%eax
  800c92:	84 c0                	test   %al,%al
  800c94:	74 04                	je     800c9a <strncpy+0x34>
			src++;
  800c96:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ca1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ca4:	72 d5                	jb     800c7b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ca6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cbb:	74 33                	je     800cf0 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cbd:	eb 17                	jmp    800cd6 <strlcpy+0x2b>
			*dst++ = *src++;
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	8d 50 01             	lea    0x1(%eax),%edx
  800cc5:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cce:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cd1:	0f b6 12             	movzbl (%edx),%edx
  800cd4:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cd6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800cda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cde:	74 0a                	je     800cea <strlcpy+0x3f>
  800ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce3:	0f b6 00             	movzbl (%eax),%eax
  800ce6:	84 c0                	test   %al,%al
  800ce8:	75 d5                	jne    800cbf <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf6:	29 c2                	sub    %eax,%edx
  800cf8:	89 d0                	mov    %edx,%eax
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800cff:	eb 08                	jmp    800d09 <strcmp+0xd>
		p++, q++;
  800d01:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d05:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	0f b6 00             	movzbl (%eax),%eax
  800d0f:	84 c0                	test   %al,%al
  800d11:	74 10                	je     800d23 <strcmp+0x27>
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	0f b6 10             	movzbl (%eax),%edx
  800d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1c:	0f b6 00             	movzbl (%eax),%eax
  800d1f:	38 c2                	cmp    %al,%dl
  800d21:	74 de                	je     800d01 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	0f b6 00             	movzbl (%eax),%eax
  800d29:	0f b6 d0             	movzbl %al,%edx
  800d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2f:	0f b6 00             	movzbl (%eax),%eax
  800d32:	0f b6 c0             	movzbl %al,%eax
  800d35:	29 c2                	sub    %eax,%edx
  800d37:	89 d0                	mov    %edx,%eax
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d3e:	eb 0c                	jmp    800d4c <strncmp+0x11>
		n--, p++, q++;
  800d40:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d48:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d50:	74 1a                	je     800d6c <strncmp+0x31>
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	0f b6 00             	movzbl (%eax),%eax
  800d58:	84 c0                	test   %al,%al
  800d5a:	74 10                	je     800d6c <strncmp+0x31>
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	0f b6 10             	movzbl (%eax),%edx
  800d62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	38 c2                	cmp    %al,%dl
  800d6a:	74 d4                	je     800d40 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d70:	75 07                	jne    800d79 <strncmp+0x3e>
		return 0;
  800d72:	b8 00 00 00 00       	mov    $0x0,%eax
  800d77:	eb 16                	jmp    800d8f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	0f b6 d0             	movzbl %al,%edx
  800d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d85:	0f b6 00             	movzbl (%eax),%eax
  800d88:	0f b6 c0             	movzbl %al,%eax
  800d8b:	29 c2                	sub    %eax,%edx
  800d8d:	89 d0                	mov    %edx,%eax
}
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800d9d:	eb 14                	jmp    800db3 <strchr+0x22>
		if (*s == c)
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	0f b6 00             	movzbl (%eax),%eax
  800da5:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800da8:	75 05                	jne    800daf <strchr+0x1e>
			return (char *) s;
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	eb 13                	jmp    800dc2 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800daf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	0f b6 00             	movzbl (%eax),%eax
  800db9:	84 c0                	test   %al,%al
  800dbb:	75 e2                	jne    800d9f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 04             	sub    $0x4,%esp
  800dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dd0:	eb 11                	jmp    800de3 <strfind+0x1f>
		if (*s == c)
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	0f b6 00             	movzbl (%eax),%eax
  800dd8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ddb:	75 02                	jne    800ddf <strfind+0x1b>
			break;
  800ddd:	eb 0e                	jmp    800ded <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ddf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	84 c0                	test   %al,%al
  800deb:	75 e5                	jne    800dd2 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800df0:	c9                   	leave  
  800df1:	c3                   	ret    

00800df2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
	char *p;

	if (n == 0)
  800df6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfa:	75 05                	jne    800e01 <memset+0xf>
		return v;
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	eb 5c                	jmp    800e5d <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	83 e0 03             	and    $0x3,%eax
  800e07:	85 c0                	test   %eax,%eax
  800e09:	75 41                	jne    800e4c <memset+0x5a>
  800e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0e:	83 e0 03             	and    $0x3,%eax
  800e11:	85 c0                	test   %eax,%eax
  800e13:	75 37                	jne    800e4c <memset+0x5a>
		c &= 0xFF;
  800e15:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1f:	c1 e0 18             	shl    $0x18,%eax
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e27:	c1 e0 10             	shl    $0x10,%eax
  800e2a:	09 c2                	or     %eax,%edx
  800e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2f:	c1 e0 08             	shl    $0x8,%eax
  800e32:	09 d0                	or     %edx,%eax
  800e34:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e37:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3a:	c1 e8 02             	shr    $0x2,%eax
  800e3d:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	89 d7                	mov    %edx,%edi
  800e47:	fc                   	cld    
  800e48:	f3 ab                	rep stos %eax,%es:(%edi)
  800e4a:	eb 0e                	jmp    800e5a <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e55:	89 d7                	mov    %edx,%edi
  800e57:	fc                   	cld    
  800e58:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e78:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e7b:	73 6d                	jae    800eea <memmove+0x8a>
  800e7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e80:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e83:	01 d0                	add    %edx,%eax
  800e85:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e88:	76 60                	jbe    800eea <memmove+0x8a>
		s += n;
  800e8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800e90:	8b 45 10             	mov    0x10(%ebp),%eax
  800e93:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e99:	83 e0 03             	and    $0x3,%eax
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	75 2f                	jne    800ecf <memmove+0x6f>
  800ea0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ea3:	83 e0 03             	and    $0x3,%eax
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	75 25                	jne    800ecf <memmove+0x6f>
  800eaa:	8b 45 10             	mov    0x10(%ebp),%eax
  800ead:	83 e0 03             	and    $0x3,%eax
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	75 1b                	jne    800ecf <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb7:	83 e8 04             	sub    $0x4,%eax
  800eba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ebd:	83 ea 04             	sub    $0x4,%edx
  800ec0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ec3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ec6:	89 c7                	mov    %eax,%edi
  800ec8:	89 d6                	mov    %edx,%esi
  800eca:	fd                   	std    
  800ecb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ecd:	eb 18                	jmp    800ee7 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ed2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ed5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed8:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800edb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ede:	89 d7                	mov    %edx,%edi
  800ee0:	89 de                	mov    %ebx,%esi
  800ee2:	89 c1                	mov    %eax,%ecx
  800ee4:	fd                   	std    
  800ee5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ee7:	fc                   	cld    
  800ee8:	eb 45                	jmp    800f2f <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eed:	83 e0 03             	and    $0x3,%eax
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	75 2b                	jne    800f1f <memmove+0xbf>
  800ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef7:	83 e0 03             	and    $0x3,%eax
  800efa:	85 c0                	test   %eax,%eax
  800efc:	75 21                	jne    800f1f <memmove+0xbf>
  800efe:	8b 45 10             	mov    0x10(%ebp),%eax
  800f01:	83 e0 03             	and    $0x3,%eax
  800f04:	85 c0                	test   %eax,%eax
  800f06:	75 17                	jne    800f1f <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	c1 e8 02             	shr    $0x2,%eax
  800f0e:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f13:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f16:	89 c7                	mov    %eax,%edi
  800f18:	89 d6                	mov    %edx,%esi
  800f1a:	fc                   	cld    
  800f1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1d:	eb 10                	jmp    800f2f <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f22:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f25:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f28:	89 c7                	mov    %eax,%edi
  800f2a:	89 d6                	mov    %edx,%esi
  800f2c:	fc                   	cld    
  800f2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f40:	8b 45 10             	mov    0x10(%ebp),%eax
  800f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	89 04 24             	mov    %eax,(%esp)
  800f54:	e8 07 ff ff ff       	call   800e60 <memmove>
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f6d:	eb 30                	jmp    800f9f <memcmp+0x44>
		if (*s1 != *s2)
  800f6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f72:	0f b6 10             	movzbl (%eax),%edx
  800f75:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f78:	0f b6 00             	movzbl (%eax),%eax
  800f7b:	38 c2                	cmp    %al,%dl
  800f7d:	74 18                	je     800f97 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f82:	0f b6 00             	movzbl (%eax),%eax
  800f85:	0f b6 d0             	movzbl %al,%edx
  800f88:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f8b:	0f b6 00             	movzbl (%eax),%eax
  800f8e:	0f b6 c0             	movzbl %al,%eax
  800f91:	29 c2                	sub    %eax,%edx
  800f93:	89 d0                	mov    %edx,%eax
  800f95:	eb 1a                	jmp    800fb1 <memcmp+0x56>
		s1++, s2++;
  800f97:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800f9b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fa5:	89 55 10             	mov    %edx,0x10(%ebp)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	75 c3                	jne    800f6f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	01 d0                	add    %edx,%eax
  800fc1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fc4:	eb 13                	jmp    800fd9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	0f b6 10             	movzbl (%eax),%edx
  800fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcf:	38 c2                	cmp    %al,%dl
  800fd1:	75 02                	jne    800fd5 <memfind+0x22>
			break;
  800fd3:	eb 0c                	jmp    800fe1 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fd5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800fdf:	72 e5                	jb     800fc6 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    

00800fe6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800fec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ff3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ffa:	eb 04                	jmp    801000 <strtol+0x1a>
		s++;
  800ffc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801000:	8b 45 08             	mov    0x8(%ebp),%eax
  801003:	0f b6 00             	movzbl (%eax),%eax
  801006:	3c 20                	cmp    $0x20,%al
  801008:	74 f2                	je     800ffc <strtol+0x16>
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	0f b6 00             	movzbl (%eax),%eax
  801010:	3c 09                	cmp    $0x9,%al
  801012:	74 e8                	je     800ffc <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	0f b6 00             	movzbl (%eax),%eax
  80101a:	3c 2b                	cmp    $0x2b,%al
  80101c:	75 06                	jne    801024 <strtol+0x3e>
		s++;
  80101e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801022:	eb 15                	jmp    801039 <strtol+0x53>
	else if (*s == '-')
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	0f b6 00             	movzbl (%eax),%eax
  80102a:	3c 2d                	cmp    $0x2d,%al
  80102c:	75 0b                	jne    801039 <strtol+0x53>
		s++, neg = 1;
  80102e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801032:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801039:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80103d:	74 06                	je     801045 <strtol+0x5f>
  80103f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801043:	75 24                	jne    801069 <strtol+0x83>
  801045:	8b 45 08             	mov    0x8(%ebp),%eax
  801048:	0f b6 00             	movzbl (%eax),%eax
  80104b:	3c 30                	cmp    $0x30,%al
  80104d:	75 1a                	jne    801069 <strtol+0x83>
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	83 c0 01             	add    $0x1,%eax
  801055:	0f b6 00             	movzbl (%eax),%eax
  801058:	3c 78                	cmp    $0x78,%al
  80105a:	75 0d                	jne    801069 <strtol+0x83>
		s += 2, base = 16;
  80105c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801060:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801067:	eb 2a                	jmp    801093 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801069:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80106d:	75 17                	jne    801086 <strtol+0xa0>
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
  801072:	0f b6 00             	movzbl (%eax),%eax
  801075:	3c 30                	cmp    $0x30,%al
  801077:	75 0d                	jne    801086 <strtol+0xa0>
		s++, base = 8;
  801079:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801084:	eb 0d                	jmp    801093 <strtol+0xad>
	else if (base == 0)
  801086:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108a:	75 07                	jne    801093 <strtol+0xad>
		base = 10;
  80108c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	0f b6 00             	movzbl (%eax),%eax
  801099:	3c 2f                	cmp    $0x2f,%al
  80109b:	7e 1b                	jle    8010b8 <strtol+0xd2>
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a0:	0f b6 00             	movzbl (%eax),%eax
  8010a3:	3c 39                	cmp    $0x39,%al
  8010a5:	7f 11                	jg     8010b8 <strtol+0xd2>
			dig = *s - '0';
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010aa:	0f b6 00             	movzbl (%eax),%eax
  8010ad:	0f be c0             	movsbl %al,%eax
  8010b0:	83 e8 30             	sub    $0x30,%eax
  8010b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010b6:	eb 48                	jmp    801100 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	0f b6 00             	movzbl (%eax),%eax
  8010be:	3c 60                	cmp    $0x60,%al
  8010c0:	7e 1b                	jle    8010dd <strtol+0xf7>
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	0f b6 00             	movzbl (%eax),%eax
  8010c8:	3c 7a                	cmp    $0x7a,%al
  8010ca:	7f 11                	jg     8010dd <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	0f b6 00             	movzbl (%eax),%eax
  8010d2:	0f be c0             	movsbl %al,%eax
  8010d5:	83 e8 57             	sub    $0x57,%eax
  8010d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010db:	eb 23                	jmp    801100 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e0:	0f b6 00             	movzbl (%eax),%eax
  8010e3:	3c 40                	cmp    $0x40,%al
  8010e5:	7e 3d                	jle    801124 <strtol+0x13e>
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	0f b6 00             	movzbl (%eax),%eax
  8010ed:	3c 5a                	cmp    $0x5a,%al
  8010ef:	7f 33                	jg     801124 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	0f b6 00             	movzbl (%eax),%eax
  8010f7:	0f be c0             	movsbl %al,%eax
  8010fa:	83 e8 37             	sub    $0x37,%eax
  8010fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801100:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801103:	3b 45 10             	cmp    0x10(%ebp),%eax
  801106:	7c 02                	jl     80110a <strtol+0x124>
			break;
  801108:	eb 1a                	jmp    801124 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80110a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80110e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801111:	0f af 45 10          	imul   0x10(%ebp),%eax
  801115:	89 c2                	mov    %eax,%edx
  801117:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111a:	01 d0                	add    %edx,%eax
  80111c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80111f:	e9 6f ff ff ff       	jmp    801093 <strtol+0xad>

	if (endptr)
  801124:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801128:	74 08                	je     801132 <strtol+0x14c>
		*endptr = (char *) s;
  80112a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
  801130:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801132:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801136:	74 07                	je     80113f <strtol+0x159>
  801138:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80113b:	f7 d8                	neg    %eax
  80113d:	eb 03                	jmp    801142 <strtol+0x15c>
  80113f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    
  801144:	66 90                	xchg   %ax,%ax
  801146:	66 90                	xchg   %ax,%ax
  801148:	66 90                	xchg   %ax,%ax
  80114a:	66 90                	xchg   %ax,%ax
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <__udivdi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	8b 44 24 28          	mov    0x28(%esp),%eax
  80115a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80115e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801162:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801166:	85 c0                	test   %eax,%eax
  801168:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80116c:	89 ea                	mov    %ebp,%edx
  80116e:	89 0c 24             	mov    %ecx,(%esp)
  801171:	75 2d                	jne    8011a0 <__udivdi3+0x50>
  801173:	39 e9                	cmp    %ebp,%ecx
  801175:	77 61                	ja     8011d8 <__udivdi3+0x88>
  801177:	85 c9                	test   %ecx,%ecx
  801179:	89 ce                	mov    %ecx,%esi
  80117b:	75 0b                	jne    801188 <__udivdi3+0x38>
  80117d:	b8 01 00 00 00       	mov    $0x1,%eax
  801182:	31 d2                	xor    %edx,%edx
  801184:	f7 f1                	div    %ecx
  801186:	89 c6                	mov    %eax,%esi
  801188:	31 d2                	xor    %edx,%edx
  80118a:	89 e8                	mov    %ebp,%eax
  80118c:	f7 f6                	div    %esi
  80118e:	89 c5                	mov    %eax,%ebp
  801190:	89 f8                	mov    %edi,%eax
  801192:	f7 f6                	div    %esi
  801194:	89 ea                	mov    %ebp,%edx
  801196:	83 c4 0c             	add    $0xc,%esp
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    
  80119d:	8d 76 00             	lea    0x0(%esi),%esi
  8011a0:	39 e8                	cmp    %ebp,%eax
  8011a2:	77 24                	ja     8011c8 <__udivdi3+0x78>
  8011a4:	0f bd e8             	bsr    %eax,%ebp
  8011a7:	83 f5 1f             	xor    $0x1f,%ebp
  8011aa:	75 3c                	jne    8011e8 <__udivdi3+0x98>
  8011ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011b0:	39 34 24             	cmp    %esi,(%esp)
  8011b3:	0f 86 9f 00 00 00    	jbe    801258 <__udivdi3+0x108>
  8011b9:	39 d0                	cmp    %edx,%eax
  8011bb:	0f 82 97 00 00 00    	jb     801258 <__udivdi3+0x108>
  8011c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	31 d2                	xor    %edx,%edx
  8011ca:	31 c0                	xor    %eax,%eax
  8011cc:	83 c4 0c             	add    $0xc,%esp
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    
  8011d3:	90                   	nop
  8011d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	89 f8                	mov    %edi,%eax
  8011da:	f7 f1                	div    %ecx
  8011dc:	31 d2                	xor    %edx,%edx
  8011de:	83 c4 0c             	add    $0xc,%esp
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    
  8011e5:	8d 76 00             	lea    0x0(%esi),%esi
  8011e8:	89 e9                	mov    %ebp,%ecx
  8011ea:	8b 3c 24             	mov    (%esp),%edi
  8011ed:	d3 e0                	shl    %cl,%eax
  8011ef:	89 c6                	mov    %eax,%esi
  8011f1:	b8 20 00 00 00       	mov    $0x20,%eax
  8011f6:	29 e8                	sub    %ebp,%eax
  8011f8:	89 c1                	mov    %eax,%ecx
  8011fa:	d3 ef                	shr    %cl,%edi
  8011fc:	89 e9                	mov    %ebp,%ecx
  8011fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801202:	8b 3c 24             	mov    (%esp),%edi
  801205:	09 74 24 08          	or     %esi,0x8(%esp)
  801209:	89 d6                	mov    %edx,%esi
  80120b:	d3 e7                	shl    %cl,%edi
  80120d:	89 c1                	mov    %eax,%ecx
  80120f:	89 3c 24             	mov    %edi,(%esp)
  801212:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801216:	d3 ee                	shr    %cl,%esi
  801218:	89 e9                	mov    %ebp,%ecx
  80121a:	d3 e2                	shl    %cl,%edx
  80121c:	89 c1                	mov    %eax,%ecx
  80121e:	d3 ef                	shr    %cl,%edi
  801220:	09 d7                	or     %edx,%edi
  801222:	89 f2                	mov    %esi,%edx
  801224:	89 f8                	mov    %edi,%eax
  801226:	f7 74 24 08          	divl   0x8(%esp)
  80122a:	89 d6                	mov    %edx,%esi
  80122c:	89 c7                	mov    %eax,%edi
  80122e:	f7 24 24             	mull   (%esp)
  801231:	39 d6                	cmp    %edx,%esi
  801233:	89 14 24             	mov    %edx,(%esp)
  801236:	72 30                	jb     801268 <__udivdi3+0x118>
  801238:	8b 54 24 04          	mov    0x4(%esp),%edx
  80123c:	89 e9                	mov    %ebp,%ecx
  80123e:	d3 e2                	shl    %cl,%edx
  801240:	39 c2                	cmp    %eax,%edx
  801242:	73 05                	jae    801249 <__udivdi3+0xf9>
  801244:	3b 34 24             	cmp    (%esp),%esi
  801247:	74 1f                	je     801268 <__udivdi3+0x118>
  801249:	89 f8                	mov    %edi,%eax
  80124b:	31 d2                	xor    %edx,%edx
  80124d:	e9 7a ff ff ff       	jmp    8011cc <__udivdi3+0x7c>
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	b8 01 00 00 00       	mov    $0x1,%eax
  80125f:	e9 68 ff ff ff       	jmp    8011cc <__udivdi3+0x7c>
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	8d 47 ff             	lea    -0x1(%edi),%eax
  80126b:	31 d2                	xor    %edx,%edx
  80126d:	83 c4 0c             	add    $0xc,%esp
  801270:	5e                   	pop    %esi
  801271:	5f                   	pop    %edi
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    
  801274:	66 90                	xchg   %ax,%ax
  801276:	66 90                	xchg   %ax,%ax
  801278:	66 90                	xchg   %ax,%ax
  80127a:	66 90                	xchg   %ax,%ax
  80127c:	66 90                	xchg   %ax,%ax
  80127e:	66 90                	xchg   %ax,%ax

00801280 <__umoddi3>:
  801280:	55                   	push   %ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	83 ec 14             	sub    $0x14,%esp
  801286:	8b 44 24 28          	mov    0x28(%esp),%eax
  80128a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80128e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801292:	89 c7                	mov    %eax,%edi
  801294:	89 44 24 04          	mov    %eax,0x4(%esp)
  801298:	8b 44 24 30          	mov    0x30(%esp),%eax
  80129c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012a0:	89 34 24             	mov    %esi,(%esp)
  8012a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012af:	75 17                	jne    8012c8 <__umoddi3+0x48>
  8012b1:	39 fe                	cmp    %edi,%esi
  8012b3:	76 4b                	jbe    801300 <__umoddi3+0x80>
  8012b5:	89 c8                	mov    %ecx,%eax
  8012b7:	89 fa                	mov    %edi,%edx
  8012b9:	f7 f6                	div    %esi
  8012bb:	89 d0                	mov    %edx,%eax
  8012bd:	31 d2                	xor    %edx,%edx
  8012bf:	83 c4 14             	add    $0x14,%esp
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	39 f8                	cmp    %edi,%eax
  8012ca:	77 54                	ja     801320 <__umoddi3+0xa0>
  8012cc:	0f bd e8             	bsr    %eax,%ebp
  8012cf:	83 f5 1f             	xor    $0x1f,%ebp
  8012d2:	75 5c                	jne    801330 <__umoddi3+0xb0>
  8012d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012d8:	39 3c 24             	cmp    %edi,(%esp)
  8012db:	0f 87 e7 00 00 00    	ja     8013c8 <__umoddi3+0x148>
  8012e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012e5:	29 f1                	sub    %esi,%ecx
  8012e7:	19 c7                	sbb    %eax,%edi
  8012e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012f1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012f9:	83 c4 14             	add    $0x14,%esp
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    
  801300:	85 f6                	test   %esi,%esi
  801302:	89 f5                	mov    %esi,%ebp
  801304:	75 0b                	jne    801311 <__umoddi3+0x91>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f6                	div    %esi
  80130f:	89 c5                	mov    %eax,%ebp
  801311:	8b 44 24 04          	mov    0x4(%esp),%eax
  801315:	31 d2                	xor    %edx,%edx
  801317:	f7 f5                	div    %ebp
  801319:	89 c8                	mov    %ecx,%eax
  80131b:	f7 f5                	div    %ebp
  80131d:	eb 9c                	jmp    8012bb <__umoddi3+0x3b>
  80131f:	90                   	nop
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 fa                	mov    %edi,%edx
  801324:	83 c4 14             	add    $0x14,%esp
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
  80132b:	90                   	nop
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	8b 04 24             	mov    (%esp),%eax
  801333:	be 20 00 00 00       	mov    $0x20,%esi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	29 ee                	sub    %ebp,%esi
  80133c:	d3 e2                	shl    %cl,%edx
  80133e:	89 f1                	mov    %esi,%ecx
  801340:	d3 e8                	shr    %cl,%eax
  801342:	89 e9                	mov    %ebp,%ecx
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	8b 04 24             	mov    (%esp),%eax
  80134b:	09 54 24 04          	or     %edx,0x4(%esp)
  80134f:	89 fa                	mov    %edi,%edx
  801351:	d3 e0                	shl    %cl,%eax
  801353:	89 f1                	mov    %esi,%ecx
  801355:	89 44 24 08          	mov    %eax,0x8(%esp)
  801359:	8b 44 24 10          	mov    0x10(%esp),%eax
  80135d:	d3 ea                	shr    %cl,%edx
  80135f:	89 e9                	mov    %ebp,%ecx
  801361:	d3 e7                	shl    %cl,%edi
  801363:	89 f1                	mov    %esi,%ecx
  801365:	d3 e8                	shr    %cl,%eax
  801367:	89 e9                	mov    %ebp,%ecx
  801369:	09 f8                	or     %edi,%eax
  80136b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80136f:	f7 74 24 04          	divl   0x4(%esp)
  801373:	d3 e7                	shl    %cl,%edi
  801375:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801379:	89 d7                	mov    %edx,%edi
  80137b:	f7 64 24 08          	mull   0x8(%esp)
  80137f:	39 d7                	cmp    %edx,%edi
  801381:	89 c1                	mov    %eax,%ecx
  801383:	89 14 24             	mov    %edx,(%esp)
  801386:	72 2c                	jb     8013b4 <__umoddi3+0x134>
  801388:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80138c:	72 22                	jb     8013b0 <__umoddi3+0x130>
  80138e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801392:	29 c8                	sub    %ecx,%eax
  801394:	19 d7                	sbb    %edx,%edi
  801396:	89 e9                	mov    %ebp,%ecx
  801398:	89 fa                	mov    %edi,%edx
  80139a:	d3 e8                	shr    %cl,%eax
  80139c:	89 f1                	mov    %esi,%ecx
  80139e:	d3 e2                	shl    %cl,%edx
  8013a0:	89 e9                	mov    %ebp,%ecx
  8013a2:	d3 ef                	shr    %cl,%edi
  8013a4:	09 d0                	or     %edx,%eax
  8013a6:	89 fa                	mov    %edi,%edx
  8013a8:	83 c4 14             	add    $0x14,%esp
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    
  8013af:	90                   	nop
  8013b0:	39 d7                	cmp    %edx,%edi
  8013b2:	75 da                	jne    80138e <__umoddi3+0x10e>
  8013b4:	8b 14 24             	mov    (%esp),%edx
  8013b7:	89 c1                	mov    %eax,%ecx
  8013b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8013bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8013c1:	eb cb                	jmp    80138e <__umoddi3+0x10e>
  8013c3:	90                   	nop
  8013c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8013cc:	0f 82 0f ff ff ff    	jb     8012e1 <__umoddi3+0x61>
  8013d2:	e9 1a ff ff ff       	jmp    8012f1 <__umoddi3+0x71>
