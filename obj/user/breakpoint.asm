
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
  8000d6:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8000dd:	00 
  8000de:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e5:	00 
  8000e6:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000ed:	e8 6f 03 00 00       	call   800461 <_panic>

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

0080041e <sys_exec>:

void sys_exec(char* buf){
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80042e:	00 
  80042f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800436:	00 
  800437:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80043e:	00 
  80043f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800446:	00 
  800447:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800452:	00 
  800453:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80045a:	e8 3d fc ff ff       	call   80009c <syscall>
}
  80045f:	c9                   	leave  
  800460:	c3                   	ret    

00800461 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	53                   	push   %ebx
  800465:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
  80046b:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046e:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800474:	e8 4d fd ff ff       	call   8001c6 <sys_getenvid>
  800479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800480:	8b 55 08             	mov    0x8(%ebp),%edx
  800483:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800487:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048f:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  800496:	e8 e1 00 00 00       	call   80057c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a5:	89 04 24             	mov    %eax,(%esp)
  8004a8:	e8 6b 00 00 00       	call   800518 <vcprintf>
	cprintf("\n");
  8004ad:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  8004b4:	e8 c3 00 00 00       	call   80057c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b9:	cc                   	int3   
  8004ba:	eb fd                	jmp    8004b9 <_panic+0x58>

008004bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	8d 48 01             	lea    0x1(%eax),%ecx
  8004ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004cd:	89 0a                	mov    %ecx,(%edx)
  8004cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d2:	89 d1                	mov    %edx,%ecx
  8004d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d7:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004de:	8b 00                	mov    (%eax),%eax
  8004e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e5:	75 20                	jne    800507 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ef:	83 c2 08             	add    $0x8,%edx
  8004f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f6:	89 14 24             	mov    %edx,(%esp)
  8004f9:	e8 ff fb ff ff       	call   8000fd <sys_cputs>
		b->idx = 0;
  8004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800501:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	8b 40 04             	mov    0x4(%eax),%eax
  80050d:	8d 50 01             	lea    0x1(%eax),%edx
  800510:	8b 45 0c             	mov    0xc(%ebp),%eax
  800513:	89 50 04             	mov    %edx,0x4(%eax)
}
  800516:	c9                   	leave  
  800517:	c3                   	ret    

00800518 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800521:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800528:	00 00 00 
	b.cnt = 0;
  80052b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800532:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800535:	8b 45 0c             	mov    0xc(%ebp),%eax
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800543:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	c7 04 24 bc 04 80 00 	movl   $0x8004bc,(%esp)
  800554:	e8 bd 01 00 00       	call   800716 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800559:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800569:	83 c0 08             	add    $0x8,%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	e8 89 fb ff ff       	call   8000fd <sys_cputs>

	return b.cnt;
  800574:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800582:	8d 45 0c             	lea    0xc(%ebp),%eax
  800585:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800588:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058f:	8b 45 08             	mov    0x8(%ebp),%eax
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	e8 7e ff ff ff       	call   800518 <vcprintf>
  80059a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 34             	sub    $0x34,%esp
  8005a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bd:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c0:	77 72                	ja     800634 <printnum+0x92>
  8005c2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c5:	72 05                	jb     8005cc <printnum+0x2a>
  8005c7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005ca:	77 68                	ja     800634 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005cc:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005cf:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005d2:	8b 45 18             	mov    0x18(%ebp),%eax
  8005d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	e8 9c 0b 00 00       	call   801190 <__udivdi3>
  8005f4:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005f7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005fb:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005ff:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800602:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800606:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800611:	89 44 24 04          	mov    %eax,0x4(%esp)
  800615:	8b 45 08             	mov    0x8(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	e8 82 ff ff ff       	call   8005a2 <printnum>
  800620:	eb 1c                	jmp    80063e <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800622:	8b 45 0c             	mov    0xc(%ebp),%eax
  800625:	89 44 24 04          	mov    %eax,0x4(%esp)
  800629:	8b 45 20             	mov    0x20(%ebp),%eax
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	8b 45 08             	mov    0x8(%ebp),%eax
  800632:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800634:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800638:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80063c:	7f e4                	jg     800622 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80063e:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800641:	bb 00 00 00 00       	mov    $0x0,%ebx
  800646:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800649:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80064c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800650:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065b:	e8 60 0c 00 00       	call   8012c0 <__umoddi3>
  800660:	05 48 15 80 00       	add    $0x801548,%eax
  800665:	0f b6 00             	movzbl (%eax),%eax
  800668:	0f be c0             	movsbl %al,%eax
  80066b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800672:	89 04 24             	mov    %eax,(%esp)
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	ff d0                	call   *%eax
}
  80067a:	83 c4 34             	add    $0x34,%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800683:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800687:	7e 14                	jle    80069d <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	8d 48 08             	lea    0x8(%eax),%ecx
  800691:	8b 55 08             	mov    0x8(%ebp),%edx
  800694:	89 0a                	mov    %ecx,(%edx)
  800696:	8b 50 04             	mov    0x4(%eax),%edx
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	eb 30                	jmp    8006cd <getuint+0x4d>
	else if (lflag)
  80069d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006a1:	74 16                	je     8006b9 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ae:	89 0a                	mov    %ecx,(%edx)
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b7:	eb 14                	jmp    8006cd <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c4:	89 0a                	mov    %ecx,(%edx)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d2:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d6:	7e 14                	jle    8006ec <getint+0x1d>
		return va_arg(*ap, long long);
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	8d 48 08             	lea    0x8(%eax),%ecx
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	89 0a                	mov    %ecx,(%edx)
  8006e5:	8b 50 04             	mov    0x4(%eax),%edx
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	eb 28                	jmp    800714 <getint+0x45>
	else if (lflag)
  8006ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006f0:	74 12                	je     800704 <getint+0x35>
		return va_arg(*ap, long);
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8006fd:	89 0a                	mov    %ecx,(%edx)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	99                   	cltd   
  800702:	eb 10                	jmp    800714 <getint+0x45>
	else
		return va_arg(*ap, int);
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 00                	mov    (%eax),%eax
  800709:	8d 48 04             	lea    0x4(%eax),%ecx
  80070c:	8b 55 08             	mov    0x8(%ebp),%edx
  80070f:	89 0a                	mov    %ecx,(%edx)
  800711:	8b 00                	mov    (%eax),%eax
  800713:	99                   	cltd   
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	56                   	push   %esi
  80071a:	53                   	push   %ebx
  80071b:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071e:	eb 18                	jmp    800738 <vprintfmt+0x22>
			if (ch == '\0')
  800720:	85 db                	test   %ebx,%ebx
  800722:	75 05                	jne    800729 <vprintfmt+0x13>
				return;
  800724:	e9 cc 03 00 00       	jmp    800af5 <vprintfmt+0x3df>
			putch(ch, putdat);
  800729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	89 1c 24             	mov    %ebx,(%esp)
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800738:	8b 45 10             	mov    0x10(%ebp),%eax
  80073b:	8d 50 01             	lea    0x1(%eax),%edx
  80073e:	89 55 10             	mov    %edx,0x10(%ebp)
  800741:	0f b6 00             	movzbl (%eax),%eax
  800744:	0f b6 d8             	movzbl %al,%ebx
  800747:	83 fb 25             	cmp    $0x25,%ebx
  80074a:	75 d4                	jne    800720 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80074c:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800750:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800757:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80075e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800765:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076c:	8b 45 10             	mov    0x10(%ebp),%eax
  80076f:	8d 50 01             	lea    0x1(%eax),%edx
  800772:	89 55 10             	mov    %edx,0x10(%ebp)
  800775:	0f b6 00             	movzbl (%eax),%eax
  800778:	0f b6 d8             	movzbl %al,%ebx
  80077b:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80077e:	83 f8 55             	cmp    $0x55,%eax
  800781:	0f 87 3d 03 00 00    	ja     800ac4 <vprintfmt+0x3ae>
  800787:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  80078e:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800790:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800794:	eb d6                	jmp    80076c <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800796:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80079a:	eb d0                	jmp    80076c <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	c1 e0 02             	shl    $0x2,%eax
  8007ab:	01 d0                	add    %edx,%eax
  8007ad:	01 c0                	add    %eax,%eax
  8007af:	01 d8                	add    %ebx,%eax
  8007b1:	83 e8 30             	sub    $0x30,%eax
  8007b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ba:	0f b6 00             	movzbl (%eax),%eax
  8007bd:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007c0:	83 fb 2f             	cmp    $0x2f,%ebx
  8007c3:	7e 0b                	jle    8007d0 <vprintfmt+0xba>
  8007c5:	83 fb 39             	cmp    $0x39,%ebx
  8007c8:	7f 06                	jg     8007d0 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007ca:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007ce:	eb d3                	jmp    8007a3 <vprintfmt+0x8d>
			goto process_precision;
  8007d0:	eb 33                	jmp    800805 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007e0:	eb 23                	jmp    800805 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e6:	79 0c                	jns    8007f4 <vprintfmt+0xde>
				width = 0;
  8007e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007ef:	e9 78 ff ff ff       	jmp    80076c <vprintfmt+0x56>
  8007f4:	e9 73 ff ff ff       	jmp    80076c <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007f9:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800800:	e9 67 ff ff ff       	jmp    80076c <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800805:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800809:	79 12                	jns    80081d <vprintfmt+0x107>
				width = precision, precision = -1;
  80080b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800811:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800818:	e9 4f ff ff ff       	jmp    80076c <vprintfmt+0x56>
  80081d:	e9 4a ff ff ff       	jmp    80076c <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800822:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800826:	e9 41 ff ff ff       	jmp    80076c <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 50 04             	lea    0x4(%eax),%edx
  800831:	89 55 14             	mov    %edx,0x14(%ebp)
  800834:	8b 00                	mov    (%eax),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	ff d0                	call   *%eax
			break;
  800845:	e9 a5 02 00 00       	jmp    800aef <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8d 50 04             	lea    0x4(%eax),%edx
  800850:	89 55 14             	mov    %edx,0x14(%ebp)
  800853:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800855:	85 db                	test   %ebx,%ebx
  800857:	79 02                	jns    80085b <vprintfmt+0x145>
				err = -err;
  800859:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80085b:	83 fb 09             	cmp    $0x9,%ebx
  80085e:	7f 0b                	jg     80086b <vprintfmt+0x155>
  800860:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800867:	85 f6                	test   %esi,%esi
  800869:	75 23                	jne    80088e <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80086b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80086f:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  800876:	00 
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	89 04 24             	mov    %eax,(%esp)
  800884:	e8 73 02 00 00       	call   800afc <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800889:	e9 61 02 00 00       	jmp    800aef <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80088e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800892:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  800899:	00 
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	e8 50 02 00 00       	call   800afc <printfmt>
			break;
  8008ac:	e9 3e 02 00 00       	jmp    800aef <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8d 50 04             	lea    0x4(%eax),%edx
  8008b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ba:	8b 30                	mov    (%eax),%esi
  8008bc:	85 f6                	test   %esi,%esi
  8008be:	75 05                	jne    8008c5 <vprintfmt+0x1af>
				p = "(null)";
  8008c0:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8008c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c9:	7e 37                	jle    800902 <vprintfmt+0x1ec>
  8008cb:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008cf:	74 31                	je     800902 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	89 34 24             	mov    %esi,(%esp)
  8008db:	e8 39 03 00 00       	call   800c19 <strnlen>
  8008e0:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008e3:	eb 17                	jmp    8008fc <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008e5:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800900:	7f e3                	jg     8008e5 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800902:	eb 38                	jmp    80093c <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800904:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800908:	74 1f                	je     800929 <vprintfmt+0x213>
  80090a:	83 fb 1f             	cmp    $0x1f,%ebx
  80090d:	7e 05                	jle    800914 <vprintfmt+0x1fe>
  80090f:	83 fb 7e             	cmp    $0x7e,%ebx
  800912:	7e 15                	jle    800929 <vprintfmt+0x213>
					putch('?', putdat);
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	ff d0                	call   *%eax
  800927:	eb 0f                	jmp    800938 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800930:	89 1c 24             	mov    %ebx,(%esp)
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800938:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093c:	89 f0                	mov    %esi,%eax
  80093e:	8d 70 01             	lea    0x1(%eax),%esi
  800941:	0f b6 00             	movzbl (%eax),%eax
  800944:	0f be d8             	movsbl %al,%ebx
  800947:	85 db                	test   %ebx,%ebx
  800949:	74 10                	je     80095b <vprintfmt+0x245>
  80094b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80094f:	78 b3                	js     800904 <vprintfmt+0x1ee>
  800951:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800955:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800959:	79 a9                	jns    800904 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095b:	eb 17                	jmp    800974 <vprintfmt+0x25e>
				putch(' ', putdat);
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	89 44 24 04          	mov    %eax,0x4(%esp)
  800964:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800970:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800974:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800978:	7f e3                	jg     80095d <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80097a:	e9 70 01 00 00       	jmp    800aef <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80097f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800982:	89 44 24 04          	mov    %eax,0x4(%esp)
  800986:	8d 45 14             	lea    0x14(%ebp),%eax
  800989:	89 04 24             	mov    %eax,(%esp)
  80098c:	e8 3e fd ff ff       	call   8006cf <getint>
  800991:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800994:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800997:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80099a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80099d:	85 d2                	test   %edx,%edx
  80099f:	79 26                	jns    8009c7 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	ff d0                	call   *%eax
				num = -(long long) num;
  8009b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ba:	f7 d8                	neg    %eax
  8009bc:	83 d2 00             	adc    $0x0,%edx
  8009bf:	f7 da                	neg    %edx
  8009c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009c7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009ce:	e9 a8 00 00 00       	jmp    800a7b <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009da:	8d 45 14             	lea    0x14(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 9b fc ff ff       	call   800680 <getuint>
  8009e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009eb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009f2:	e9 84 00 00 00       	jmp    800a7b <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	e8 77 fc ff ff       	call   800680 <getuint>
  800a09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a0f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a16:	eb 63                	jmp    800a7b <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	ff d0                	call   *%eax
			putch('x', putdat);
  800a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a32:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a41:	8d 50 04             	lea    0x4(%eax),%edx
  800a44:	89 55 14             	mov    %edx,0x14(%ebp)
  800a47:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a53:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a5a:	eb 1f                	jmp    800a7b <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a63:	8d 45 14             	lea    0x14(%ebp),%eax
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 12 fc ff ff       	call   800680 <getuint>
  800a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a71:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a74:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a7b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a82:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a89:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	89 04 24             	mov    %eax,(%esp)
  800aac:	e8 f1 fa ff ff       	call   8005a2 <printnum>
			break;
  800ab1:	eb 3c                	jmp    800aef <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aba:	89 1c 24             	mov    %ebx,(%esp)
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	ff d0                	call   *%eax
			break;
  800ac2:	eb 2b                	jmp    800aef <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acb:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800adb:	eb 04                	jmp    800ae1 <vprintfmt+0x3cb>
  800add:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae4:	83 e8 01             	sub    $0x1,%eax
  800ae7:	0f b6 00             	movzbl (%eax),%eax
  800aea:	3c 25                	cmp    $0x25,%al
  800aec:	75 ef                	jne    800add <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800aee:	90                   	nop
		}
	}
  800aef:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800af0:	e9 43 fc ff ff       	jmp    800738 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800af5:	83 c4 40             	add    $0x40,%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b02:	8d 45 14             	lea    0x14(%ebp),%eax
  800b05:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b12:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	89 04 24             	mov    %eax,(%esp)
  800b23:	e8 ee fb ff ff       	call   800716 <vprintfmt>
	va_end(ap);
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	8b 40 08             	mov    0x8(%eax),%eax
  800b33:	8d 50 01             	lea    0x1(%eax),%edx
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	8b 10                	mov    (%eax),%edx
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	8b 40 04             	mov    0x4(%eax),%eax
  800b47:	39 c2                	cmp    %eax,%edx
  800b49:	73 12                	jae    800b5d <sprintputch+0x33>
		*b->buf++ = ch;
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	8b 00                	mov    (%eax),%eax
  800b50:	8d 48 01             	lea    0x1(%eax),%ecx
  800b53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b56:	89 0a                	mov    %ecx,(%edx)
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	88 10                	mov    %dl,(%eax)
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	01 d0                	add    %edx,%eax
  800b76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b80:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b84:	74 06                	je     800b8c <vsnprintf+0x2d>
  800b86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8a:	7f 07                	jg     800b93 <vsnprintf+0x34>
		return -E_INVAL;
  800b8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b91:	eb 2a                	jmp    800bbd <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b93:	8b 45 14             	mov    0x14(%ebp),%eax
  800b96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba8:	c7 04 24 2a 0b 80 00 	movl   $0x800b2a,(%esp)
  800baf:	e8 62 fb ff ff       	call   800716 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bc5:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	89 04 24             	mov    %eax,(%esp)
  800be6:	e8 74 ff ff ff       	call   800b5f <vsnprintf>
  800beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bf9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c00:	eb 08                	jmp    800c0a <strlen+0x17>
		n++;
  800c02:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	0f b6 00             	movzbl (%eax),%eax
  800c10:	84 c0                	test   %al,%al
  800c12:	75 ee                	jne    800c02 <strlen+0xf>
		n++;
	return n;
  800c14:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c1f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c26:	eb 0c                	jmp    800c34 <strnlen+0x1b>
		n++;
  800c28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c30:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c38:	74 0a                	je     800c44 <strnlen+0x2b>
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	0f b6 00             	movzbl (%eax),%eax
  800c40:	84 c0                	test   %al,%al
  800c42:	75 e4                	jne    800c28 <strnlen+0xf>
		n++;
	return n;
  800c44:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c55:	90                   	nop
  800c56:	8b 45 08             	mov    0x8(%ebp),%eax
  800c59:	8d 50 01             	lea    0x1(%eax),%edx
  800c5c:	89 55 08             	mov    %edx,0x8(%ebp)
  800c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c62:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c65:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c68:	0f b6 12             	movzbl (%edx),%edx
  800c6b:	88 10                	mov    %dl,(%eax)
  800c6d:	0f b6 00             	movzbl (%eax),%eax
  800c70:	84 c0                	test   %al,%al
  800c72:	75 e2                	jne    800c56 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c74:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	89 04 24             	mov    %eax,(%esp)
  800c85:	e8 69 ff ff ff       	call   800bf3 <strlen>
  800c8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c8d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	01 c2                	add    %eax,%edx
  800c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9c:	89 14 24             	mov    %edx,(%esp)
  800c9f:	e8 a5 ff ff ff       	call   800c49 <strcpy>
	return dst;
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca7:	c9                   	leave  
  800ca8:	c3                   	ret    

00800ca9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cb5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cbc:	eb 23                	jmp    800ce1 <strncpy+0x38>
		*dst++ = *src;
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	8d 50 01             	lea    0x1(%eax),%edx
  800cc4:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cca:	0f b6 12             	movzbl (%edx),%edx
  800ccd:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd2:	0f b6 00             	movzbl (%eax),%eax
  800cd5:	84 c0                	test   %al,%al
  800cd7:	74 04                	je     800cdd <strncpy+0x34>
			src++;
  800cd9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cdd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ce7:	72 d5                	jb     800cbe <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ce9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cfa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cfe:	74 33                	je     800d33 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d00:	eb 17                	jmp    800d19 <strlcpy+0x2b>
			*dst++ = *src++;
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8d 50 01             	lea    0x1(%eax),%edx
  800d08:	89 55 08             	mov    %edx,0x8(%ebp)
  800d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d11:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d14:	0f b6 12             	movzbl (%edx),%edx
  800d17:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d19:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d21:	74 0a                	je     800d2d <strlcpy+0x3f>
  800d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d26:	0f b6 00             	movzbl (%eax),%eax
  800d29:	84 c0                	test   %al,%al
  800d2b:	75 d5                	jne    800d02 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d39:	29 c2                	sub    %eax,%edx
  800d3b:	89 d0                	mov    %edx,%eax
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d42:	eb 08                	jmp    800d4c <strcmp+0xd>
		p++, q++;
  800d44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d48:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	84 c0                	test   %al,%al
  800d54:	74 10                	je     800d66 <strcmp+0x27>
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	0f b6 10             	movzbl (%eax),%edx
  800d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5f:	0f b6 00             	movzbl (%eax),%eax
  800d62:	38 c2                	cmp    %al,%dl
  800d64:	74 de                	je     800d44 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	0f b6 d0             	movzbl %al,%edx
  800d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d72:	0f b6 00             	movzbl (%eax),%eax
  800d75:	0f b6 c0             	movzbl %al,%eax
  800d78:	29 c2                	sub    %eax,%edx
  800d7a:	89 d0                	mov    %edx,%eax
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d81:	eb 0c                	jmp    800d8f <strncmp+0x11>
		n--, p++, q++;
  800d83:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d87:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d93:	74 1a                	je     800daf <strncmp+0x31>
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	0f b6 00             	movzbl (%eax),%eax
  800d9b:	84 c0                	test   %al,%al
  800d9d:	74 10                	je     800daf <strncmp+0x31>
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	0f b6 10             	movzbl (%eax),%edx
  800da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da8:	0f b6 00             	movzbl (%eax),%eax
  800dab:	38 c2                	cmp    %al,%dl
  800dad:	74 d4                	je     800d83 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800daf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db3:	75 07                	jne    800dbc <strncmp+0x3e>
		return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dba:	eb 16                	jmp    800dd2 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	0f b6 00             	movzbl (%eax),%eax
  800dc2:	0f b6 d0             	movzbl %al,%edx
  800dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc8:	0f b6 00             	movzbl (%eax),%eax
  800dcb:	0f b6 c0             	movzbl %al,%eax
  800dce:	29 c2                	sub    %eax,%edx
  800dd0:	89 d0                	mov    %edx,%eax
}
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de0:	eb 14                	jmp    800df6 <strchr+0x22>
		if (*s == c)
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	0f b6 00             	movzbl (%eax),%eax
  800de8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800deb:	75 05                	jne    800df2 <strchr+0x1e>
			return (char *) s;
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	eb 13                	jmp    800e05 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	0f b6 00             	movzbl (%eax),%eax
  800dfc:	84 c0                	test   %al,%al
  800dfe:	75 e2                	jne    800de2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e10:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e13:	eb 11                	jmp    800e26 <strfind+0x1f>
		if (*s == c)
  800e15:	8b 45 08             	mov    0x8(%ebp),%eax
  800e18:	0f b6 00             	movzbl (%eax),%eax
  800e1b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e1e:	75 02                	jne    800e22 <strfind+0x1b>
			break;
  800e20:	eb 0e                	jmp    800e30 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e22:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	0f b6 00             	movzbl (%eax),%eax
  800e2c:	84 c0                	test   %al,%al
  800e2e:	75 e5                	jne    800e15 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e3d:	75 05                	jne    800e44 <memset+0xf>
		return v;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	eb 5c                	jmp    800ea0 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
  800e47:	83 e0 03             	and    $0x3,%eax
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	75 41                	jne    800e8f <memset+0x5a>
  800e4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e51:	83 e0 03             	and    $0x3,%eax
  800e54:	85 c0                	test   %eax,%eax
  800e56:	75 37                	jne    800e8f <memset+0x5a>
		c &= 0xFF;
  800e58:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e62:	c1 e0 18             	shl    $0x18,%eax
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6a:	c1 e0 10             	shl    $0x10,%eax
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e72:	c1 e0 08             	shl    $0x8,%eax
  800e75:	09 d0                	or     %edx,%eax
  800e77:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7d:	c1 e8 02             	shr    $0x2,%eax
  800e80:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e88:	89 d7                	mov    %edx,%edi
  800e8a:	fc                   	cld    
  800e8b:	f3 ab                	rep stos %eax,%es:(%edi)
  800e8d:	eb 0e                	jmp    800e9d <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e95:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e98:	89 d7                	mov    %edx,%edi
  800e9a:	fc                   	cld    
  800e9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ebe:	73 6d                	jae    800f2d <memmove+0x8a>
  800ec0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec6:	01 d0                	add    %edx,%eax
  800ec8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ecb:	76 60                	jbe    800f2d <memmove+0x8a>
		s += n;
  800ecd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed0:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ed3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed6:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edc:	83 e0 03             	and    $0x3,%eax
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	75 2f                	jne    800f12 <memmove+0x6f>
  800ee3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee6:	83 e0 03             	and    $0x3,%eax
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	75 25                	jne    800f12 <memmove+0x6f>
  800eed:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef0:	83 e0 03             	and    $0x3,%eax
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	75 1b                	jne    800f12 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efa:	83 e8 04             	sub    $0x4,%eax
  800efd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f00:	83 ea 04             	sub    $0x4,%edx
  800f03:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f06:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f09:	89 c7                	mov    %eax,%edi
  800f0b:	89 d6                	mov    %edx,%esi
  800f0d:	fd                   	std    
  800f0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f10:	eb 18                	jmp    800f2a <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f12:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f15:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1b:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f21:	89 d7                	mov    %edx,%edi
  800f23:	89 de                	mov    %ebx,%esi
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	fd                   	std    
  800f28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f2a:	fc                   	cld    
  800f2b:	eb 45                	jmp    800f72 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f30:	83 e0 03             	and    $0x3,%eax
  800f33:	85 c0                	test   %eax,%eax
  800f35:	75 2b                	jne    800f62 <memmove+0xbf>
  800f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3a:	83 e0 03             	and    $0x3,%eax
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	75 21                	jne    800f62 <memmove+0xbf>
  800f41:	8b 45 10             	mov    0x10(%ebp),%eax
  800f44:	83 e0 03             	and    $0x3,%eax
  800f47:	85 c0                	test   %eax,%eax
  800f49:	75 17                	jne    800f62 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4e:	c1 e8 02             	shr    $0x2,%eax
  800f51:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f56:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f59:	89 c7                	mov    %eax,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	fc                   	cld    
  800f5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f60:	eb 10                	jmp    800f72 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f65:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f68:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f6b:	89 c7                	mov    %eax,%edi
  800f6d:	89 d6                	mov    %edx,%esi
  800f6f:	fc                   	cld    
  800f70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f83:	8b 45 10             	mov    0x10(%ebp),%eax
  800f86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	89 04 24             	mov    %eax,(%esp)
  800f97:	e8 07 ff ff ff       	call   800ea3 <memmove>
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fb0:	eb 30                	jmp    800fe2 <memcmp+0x44>
		if (*s1 != *s2)
  800fb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fb5:	0f b6 10             	movzbl (%eax),%edx
  800fb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fbb:	0f b6 00             	movzbl (%eax),%eax
  800fbe:	38 c2                	cmp    %al,%dl
  800fc0:	74 18                	je     800fda <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc5:	0f b6 00             	movzbl (%eax),%eax
  800fc8:	0f b6 d0             	movzbl %al,%edx
  800fcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fce:	0f b6 00             	movzbl (%eax),%eax
  800fd1:	0f b6 c0             	movzbl %al,%eax
  800fd4:	29 c2                	sub    %eax,%edx
  800fd6:	89 d0                	mov    %edx,%eax
  800fd8:	eb 1a                	jmp    800ff4 <memcmp+0x56>
		s1++, s2++;
  800fda:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fde:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe5:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe8:	89 55 10             	mov    %edx,0x10(%ebp)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	75 c3                	jne    800fb2 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ffc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	01 d0                	add    %edx,%eax
  801004:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801007:	eb 13                	jmp    80101c <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801009:	8b 45 08             	mov    0x8(%ebp),%eax
  80100c:	0f b6 10             	movzbl (%eax),%edx
  80100f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801012:	38 c2                	cmp    %al,%dl
  801014:	75 02                	jne    801018 <memfind+0x22>
			break;
  801016:	eb 0c                	jmp    801024 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801018:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80101c:	8b 45 08             	mov    0x8(%ebp),%eax
  80101f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801022:	72 e5                	jb     801009 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80102f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801036:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103d:	eb 04                	jmp    801043 <strtol+0x1a>
		s++;
  80103f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	0f b6 00             	movzbl (%eax),%eax
  801049:	3c 20                	cmp    $0x20,%al
  80104b:	74 f2                	je     80103f <strtol+0x16>
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax
  801050:	0f b6 00             	movzbl (%eax),%eax
  801053:	3c 09                	cmp    $0x9,%al
  801055:	74 e8                	je     80103f <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	0f b6 00             	movzbl (%eax),%eax
  80105d:	3c 2b                	cmp    $0x2b,%al
  80105f:	75 06                	jne    801067 <strtol+0x3e>
		s++;
  801061:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801065:	eb 15                	jmp    80107c <strtol+0x53>
	else if (*s == '-')
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	0f b6 00             	movzbl (%eax),%eax
  80106d:	3c 2d                	cmp    $0x2d,%al
  80106f:	75 0b                	jne    80107c <strtol+0x53>
		s++, neg = 1;
  801071:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801075:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80107c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801080:	74 06                	je     801088 <strtol+0x5f>
  801082:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801086:	75 24                	jne    8010ac <strtol+0x83>
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
  80108b:	0f b6 00             	movzbl (%eax),%eax
  80108e:	3c 30                	cmp    $0x30,%al
  801090:	75 1a                	jne    8010ac <strtol+0x83>
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	83 c0 01             	add    $0x1,%eax
  801098:	0f b6 00             	movzbl (%eax),%eax
  80109b:	3c 78                	cmp    $0x78,%al
  80109d:	75 0d                	jne    8010ac <strtol+0x83>
		s += 2, base = 16;
  80109f:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010a3:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010aa:	eb 2a                	jmp    8010d6 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b0:	75 17                	jne    8010c9 <strtol+0xa0>
  8010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b5:	0f b6 00             	movzbl (%eax),%eax
  8010b8:	3c 30                	cmp    $0x30,%al
  8010ba:	75 0d                	jne    8010c9 <strtol+0xa0>
		s++, base = 8;
  8010bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010c0:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010c7:	eb 0d                	jmp    8010d6 <strtol+0xad>
	else if (base == 0)
  8010c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010cd:	75 07                	jne    8010d6 <strtol+0xad>
		base = 10;
  8010cf:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	0f b6 00             	movzbl (%eax),%eax
  8010dc:	3c 2f                	cmp    $0x2f,%al
  8010de:	7e 1b                	jle    8010fb <strtol+0xd2>
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	0f b6 00             	movzbl (%eax),%eax
  8010e6:	3c 39                	cmp    $0x39,%al
  8010e8:	7f 11                	jg     8010fb <strtol+0xd2>
			dig = *s - '0';
  8010ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ed:	0f b6 00             	movzbl (%eax),%eax
  8010f0:	0f be c0             	movsbl %al,%eax
  8010f3:	83 e8 30             	sub    $0x30,%eax
  8010f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f9:	eb 48                	jmp    801143 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	0f b6 00             	movzbl (%eax),%eax
  801101:	3c 60                	cmp    $0x60,%al
  801103:	7e 1b                	jle    801120 <strtol+0xf7>
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	0f b6 00             	movzbl (%eax),%eax
  80110b:	3c 7a                	cmp    $0x7a,%al
  80110d:	7f 11                	jg     801120 <strtol+0xf7>
			dig = *s - 'a' + 10;
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	0f b6 00             	movzbl (%eax),%eax
  801115:	0f be c0             	movsbl %al,%eax
  801118:	83 e8 57             	sub    $0x57,%eax
  80111b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80111e:	eb 23                	jmp    801143 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	0f b6 00             	movzbl (%eax),%eax
  801126:	3c 40                	cmp    $0x40,%al
  801128:	7e 3d                	jle    801167 <strtol+0x13e>
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	0f b6 00             	movzbl (%eax),%eax
  801130:	3c 5a                	cmp    $0x5a,%al
  801132:	7f 33                	jg     801167 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	0f b6 00             	movzbl (%eax),%eax
  80113a:	0f be c0             	movsbl %al,%eax
  80113d:	83 e8 37             	sub    $0x37,%eax
  801140:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801143:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801146:	3b 45 10             	cmp    0x10(%ebp),%eax
  801149:	7c 02                	jl     80114d <strtol+0x124>
			break;
  80114b:	eb 1a                	jmp    801167 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80114d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801151:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801154:	0f af 45 10          	imul   0x10(%ebp),%eax
  801158:	89 c2                	mov    %eax,%edx
  80115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115d:	01 d0                	add    %edx,%eax
  80115f:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801162:	e9 6f ff ff ff       	jmp    8010d6 <strtol+0xad>

	if (endptr)
  801167:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80116b:	74 08                	je     801175 <strtol+0x14c>
		*endptr = (char *) s;
  80116d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801170:	8b 55 08             	mov    0x8(%ebp),%edx
  801173:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801175:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801179:	74 07                	je     801182 <strtol+0x159>
  80117b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80117e:	f7 d8                	neg    %eax
  801180:	eb 03                	jmp    801185 <strtol+0x15c>
  801182:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801185:	c9                   	leave  
  801186:	c3                   	ret    
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
