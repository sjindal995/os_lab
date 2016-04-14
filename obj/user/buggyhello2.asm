
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	a1 00 20 80 00       	mov    0x802000,%eax
  80003e:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800045:	00 
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 c6 00 00 00       	call   800114 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800056:	e8 82 01 00 00       	call   8001dd <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	c1 e0 02             	shl    $0x2,%eax
  800063:	89 c2                	mov    %eax,%edx
  800065:	c1 e2 05             	shl    $0x5,%edx
  800068:	29 c2                	sub    %eax,%edx
  80006a:	89 d0                	mov    %edx,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80007a:	7e 0a                	jle    800086 <libmain+0x36>
		binaryname = argv[0];
  80007c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007f:	8b 00                	mov    (%eax),%eax
  800081:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800086:	8b 45 0c             	mov    0xc(%ebp),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	8b 45 08             	mov    0x8(%ebp),%eax
  800090:	89 04 24             	mov    %eax,(%esp)
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 02 00 00 00       	call   80009f <exit>
}
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ac:	e8 e9 00 00 00       	call   80019a <sys_env_destroy>
}
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
  8000b9:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8000c2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000c5:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000c8:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000cb:	8b 75 20             	mov    0x20(%ebp),%esi
  8000ce:	cd 30                	int    $0x30
  8000d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000d7:	74 30                	je     800109 <syscall+0x56>
  8000d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000dd:	7e 2a                	jle    800109 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ed:	c7 44 24 08 18 14 80 	movl   $0x801418,0x8(%esp)
  8000f4:	00 
  8000f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000fc:	00 
  8000fd:	c7 04 24 35 14 80 00 	movl   $0x801435,(%esp)
  800104:	e8 2c 03 00 00       	call   800435 <_panic>

	return ret;
  800109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80010c:	83 c4 3c             	add    $0x3c,%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80011a:	8b 45 08             	mov    0x8(%ebp),%eax
  80011d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800124:	00 
  800125:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80012c:	00 
  80012d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800134:	00 
  800135:	8b 55 0c             	mov    0xc(%ebp),%edx
  800138:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80013c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800140:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014f:	e8 5f ff ff ff       	call   8000b3 <syscall>
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <sys_cgetc>:

int
sys_cgetc(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80015c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800163:	00 
  800164:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80016b:	00 
  80016c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800173:	00 
  800174:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80017b:	00 
  80017c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800183:	00 
  800184:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80018b:	00 
  80018c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800193:	e8 1b ff ff ff       	call   8000b3 <syscall>
}
  800198:	c9                   	leave  
  800199:	c3                   	ret    

0080019a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8001a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001b2:	00 
  8001b3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001ba:	00 
  8001bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c2:	00 
  8001c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001ce:	00 
  8001cf:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001d6:	e8 d8 fe ff ff       	call   8000b3 <syscall>
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    

008001dd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001e3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800202:	00 
  800203:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800212:	00 
  800213:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80021a:	e8 94 fe ff ff       	call   8000b3 <syscall>
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <sys_yield>:

void
sys_yield(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800227:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80022e:	00 
  80022f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800236:	00 
  800237:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80023e:	00 
  80023f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800246:	00 
  800247:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800256:	00 
  800257:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80025e:	e8 50 fe ff ff       	call   8000b3 <syscall>
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80026b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80027b:	00 
  80027c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800283:	00 
  800284:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800288:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80028c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800290:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800297:	00 
  800298:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80029f:	e8 0f fe ff ff       	call   8000b3 <syscall>
}
  8002a4:	c9                   	leave  
  8002a5:	c3                   	ret    

008002a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002ae:	8b 75 18             	mov    0x18(%ebp),%esi
  8002b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002c1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002c5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d8:	00 
  8002d9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002e0:	e8 ce fd ff ff       	call   8000b3 <syscall>
}
  8002e5:	83 c4 20             	add    $0x20,%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5e                   	pop    %esi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002ff:	00 
  800300:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800307:	00 
  800308:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80030f:	00 
  800310:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031f:	00 
  800320:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800327:	e8 87 fd ff ff       	call   8000b3 <syscall>
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800334:	8b 55 0c             	mov    0xc(%ebp),%edx
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800341:	00 
  800342:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800349:	00 
  80034a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800351:	00 
  800352:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800361:	00 
  800362:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800369:	e8 45 fd ff ff       	call   8000b3 <syscall>
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800376:	8b 55 0c             	mov    0xc(%ebp),%edx
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800383:	00 
  800384:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80038b:	00 
  80038c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800393:	00 
  800394:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800398:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003a3:	00 
  8003a4:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003ab:	e8 03 fd ff ff       	call   8000b3 <syscall>
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003b8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003c8:	00 
  8003c9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e3:	00 
  8003e4:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003eb:	e8 c3 fc ff ff       	call   8000b3 <syscall>
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800402:	00 
  800403:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80040a:	00 
  80040b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800412:	00 
  800413:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041a:	00 
  80041b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80042e:	e8 80 fc ff ff       	call   8000b3 <syscall>
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    

00800435 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	53                   	push   %ebx
  800439:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80043c:	8d 45 14             	lea    0x14(%ebp),%eax
  80043f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800442:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800448:	e8 90 fd ff ff       	call   8001dd <sys_getenvid>
  80044d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800450:	89 54 24 10          	mov    %edx,0x10(%esp)
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80045f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800463:	c7 04 24 44 14 80 00 	movl   $0x801444,(%esp)
  80046a:	e8 e1 00 00 00       	call   800550 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800472:	89 44 24 04          	mov    %eax,0x4(%esp)
  800476:	8b 45 10             	mov    0x10(%ebp),%eax
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	e8 6b 00 00 00       	call   8004ec <vcprintf>
	cprintf("\n");
  800481:	c7 04 24 67 14 80 00 	movl   $0x801467,(%esp)
  800488:	e8 c3 00 00 00       	call   800550 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048d:	cc                   	int3   
  80048e:	eb fd                	jmp    80048d <_panic+0x58>

00800490 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800496:	8b 45 0c             	mov    0xc(%ebp),%eax
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	8d 48 01             	lea    0x1(%eax),%ecx
  80049e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a1:	89 0a                	mov    %ecx,(%edx)
  8004a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a6:	89 d1                	mov    %edx,%ecx
  8004a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ab:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b9:	75 20                	jne    8004db <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c3:	83 c2 08             	add    $0x8,%edx
  8004c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ca:	89 14 24             	mov    %edx,(%esp)
  8004cd:	e8 42 fc ff ff       	call   800114 <sys_cputs>
		b->idx = 0;
  8004d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004de:	8b 40 04             	mov    0x4(%eax),%eax
  8004e1:	8d 50 01             	lea    0x1(%eax),%edx
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e7:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fc:	00 00 00 
	b.cnt = 0;
  8004ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800506:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	89 44 24 08          	mov    %eax,0x8(%esp)
  800517:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	c7 04 24 90 04 80 00 	movl   $0x800490,(%esp)
  800528:	e8 bd 01 00 00       	call   8006ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800533:	89 44 24 04          	mov    %eax,0x4(%esp)
  800537:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80053d:	83 c0 08             	add    $0x8,%eax
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 cc fb ff ff       	call   800114 <sys_cputs>

	return b.cnt;
  800548:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800556:	8d 45 0c             	lea    0xc(%ebp),%eax
  800559:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80055c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	8b 45 08             	mov    0x8(%ebp),%eax
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	e8 7e ff ff ff       	call   8004ec <vcprintf>
  80056e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800571:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800574:	c9                   	leave  
  800575:	c3                   	ret    

00800576 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	53                   	push   %ebx
  80057a:	83 ec 34             	sub    $0x34,%esp
  80057d:	8b 45 10             	mov    0x10(%ebp),%eax
  800580:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800589:	8b 45 18             	mov    0x18(%ebp),%eax
  80058c:	ba 00 00 00 00       	mov    $0x0,%edx
  800591:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800594:	77 72                	ja     800608 <printnum+0x92>
  800596:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800599:	72 05                	jb     8005a0 <printnum+0x2a>
  80059b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80059e:	77 68                	ja     800608 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005a3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005a6:	8b 45 18             	mov    0x18(%ebp),%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c3:	e8 98 0b 00 00       	call   801160 <__udivdi3>
  8005c8:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005cb:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005cf:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005d3:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005d6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 82 ff ff ff       	call   800576 <printnum>
  8005f4:	eb 1c                	jmp    800612 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fd:	8b 45 20             	mov    0x20(%ebp),%eax
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	8b 45 08             	mov    0x8(%ebp),%eax
  800606:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800608:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80060c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800610:	7f e4                	jg     8005f6 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800612:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800615:	bb 00 00 00 00       	mov    $0x0,%ebx
  80061a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800620:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800624:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062f:	e8 5c 0c 00 00       	call   801290 <__umoddi3>
  800634:	05 48 15 80 00       	add    $0x801548,%eax
  800639:	0f b6 00             	movzbl (%eax),%eax
  80063c:	0f be c0             	movsbl %al,%eax
  80063f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800642:	89 54 24 04          	mov    %edx,0x4(%esp)
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	8b 45 08             	mov    0x8(%ebp),%eax
  80064c:	ff d0                	call   *%eax
}
  80064e:	83 c4 34             	add    $0x34,%esp
  800651:	5b                   	pop    %ebx
  800652:	5d                   	pop    %ebp
  800653:	c3                   	ret    

00800654 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800654:	55                   	push   %ebp
  800655:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800657:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80065b:	7e 14                	jle    800671 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	8d 48 08             	lea    0x8(%eax),%ecx
  800665:	8b 55 08             	mov    0x8(%ebp),%edx
  800668:	89 0a                	mov    %ecx,(%edx)
  80066a:	8b 50 04             	mov    0x4(%eax),%edx
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	eb 30                	jmp    8006a1 <getuint+0x4d>
	else if (lflag)
  800671:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800675:	74 16                	je     80068d <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	8d 48 04             	lea    0x4(%eax),%ecx
  80067f:	8b 55 08             	mov    0x8(%ebp),%edx
  800682:	89 0a                	mov    %ecx,(%edx)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
  80068b:	eb 14                	jmp    8006a1 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	8b 00                	mov    (%eax),%eax
  800692:	8d 48 04             	lea    0x4(%eax),%ecx
  800695:	8b 55 08             	mov    0x8(%ebp),%edx
  800698:	89 0a                	mov    %ecx,(%edx)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a1:	5d                   	pop    %ebp
  8006a2:	c3                   	ret    

008006a3 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006aa:	7e 14                	jle    8006c0 <getint+0x1d>
		return va_arg(*ap, long long);
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	8d 48 08             	lea    0x8(%eax),%ecx
  8006b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b7:	89 0a                	mov    %ecx,(%edx)
  8006b9:	8b 50 04             	mov    0x4(%eax),%edx
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	eb 28                	jmp    8006e8 <getint+0x45>
	else if (lflag)
  8006c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c4:	74 12                	je     8006d8 <getint+0x35>
		return va_arg(*ap, long);
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	8b 00                	mov    (%eax),%eax
  8006cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d1:	89 0a                	mov    %ecx,(%edx)
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	99                   	cltd   
  8006d6:	eb 10                	jmp    8006e8 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	8d 48 04             	lea    0x4(%eax),%ecx
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	89 0a                	mov    %ecx,(%edx)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	99                   	cltd   
}
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	56                   	push   %esi
  8006ee:	53                   	push   %ebx
  8006ef:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f2:	eb 18                	jmp    80070c <vprintfmt+0x22>
			if (ch == '\0')
  8006f4:	85 db                	test   %ebx,%ebx
  8006f6:	75 05                	jne    8006fd <vprintfmt+0x13>
				return;
  8006f8:	e9 cc 03 00 00       	jmp    800ac9 <vprintfmt+0x3df>
			putch(ch, putdat);
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	89 1c 24             	mov    %ebx,(%esp)
  800707:	8b 45 08             	mov    0x8(%ebp),%eax
  80070a:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070c:	8b 45 10             	mov    0x10(%ebp),%eax
  80070f:	8d 50 01             	lea    0x1(%eax),%edx
  800712:	89 55 10             	mov    %edx,0x10(%ebp)
  800715:	0f b6 00             	movzbl (%eax),%eax
  800718:	0f b6 d8             	movzbl %al,%ebx
  80071b:	83 fb 25             	cmp    $0x25,%ebx
  80071e:	75 d4                	jne    8006f4 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800720:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800724:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80072b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800732:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800739:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800740:	8b 45 10             	mov    0x10(%ebp),%eax
  800743:	8d 50 01             	lea    0x1(%eax),%edx
  800746:	89 55 10             	mov    %edx,0x10(%ebp)
  800749:	0f b6 00             	movzbl (%eax),%eax
  80074c:	0f b6 d8             	movzbl %al,%ebx
  80074f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800752:	83 f8 55             	cmp    $0x55,%eax
  800755:	0f 87 3d 03 00 00    	ja     800a98 <vprintfmt+0x3ae>
  80075b:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800762:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800764:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800768:	eb d6                	jmp    800740 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80076a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80076e:	eb d0                	jmp    800740 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800770:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800777:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80077a:	89 d0                	mov    %edx,%eax
  80077c:	c1 e0 02             	shl    $0x2,%eax
  80077f:	01 d0                	add    %edx,%eax
  800781:	01 c0                	add    %eax,%eax
  800783:	01 d8                	add    %ebx,%eax
  800785:	83 e8 30             	sub    $0x30,%eax
  800788:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80078b:	8b 45 10             	mov    0x10(%ebp),%eax
  80078e:	0f b6 00             	movzbl (%eax),%eax
  800791:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800794:	83 fb 2f             	cmp    $0x2f,%ebx
  800797:	7e 0b                	jle    8007a4 <vprintfmt+0xba>
  800799:	83 fb 39             	cmp    $0x39,%ebx
  80079c:	7f 06                	jg     8007a4 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079e:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007a2:	eb d3                	jmp    800777 <vprintfmt+0x8d>
			goto process_precision;
  8007a4:	eb 33                	jmp    8007d9 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007b4:	eb 23                	jmp    8007d9 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ba:	79 0c                	jns    8007c8 <vprintfmt+0xde>
				width = 0;
  8007bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007c3:	e9 78 ff ff ff       	jmp    800740 <vprintfmt+0x56>
  8007c8:	e9 73 ff ff ff       	jmp    800740 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007cd:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007d4:	e9 67 ff ff ff       	jmp    800740 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007dd:	79 12                	jns    8007f1 <vprintfmt+0x107>
				width = precision, precision = -1;
  8007df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007ec:	e9 4f ff ff ff       	jmp    800740 <vprintfmt+0x56>
  8007f1:	e9 4a ff ff ff       	jmp    800740 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007fa:	e9 41 ff ff ff       	jmp    800740 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 04             	lea    0x4(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800811:	89 04 24             	mov    %eax,(%esp)
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	ff d0                	call   *%eax
			break;
  800819:	e9 a5 02 00 00       	jmp    800ac3 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 50 04             	lea    0x4(%eax),%edx
  800824:	89 55 14             	mov    %edx,0x14(%ebp)
  800827:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800829:	85 db                	test   %ebx,%ebx
  80082b:	79 02                	jns    80082f <vprintfmt+0x145>
				err = -err;
  80082d:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082f:	83 fb 09             	cmp    $0x9,%ebx
  800832:	7f 0b                	jg     80083f <vprintfmt+0x155>
  800834:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  80083b:	85 f6                	test   %esi,%esi
  80083d:	75 23                	jne    800862 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80083f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800843:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80084a:	00 
  80084b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	89 04 24             	mov    %eax,(%esp)
  800858:	e8 73 02 00 00       	call   800ad0 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80085d:	e9 61 02 00 00       	jmp    800ac3 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800862:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800866:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80086d:	00 
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	89 44 24 04          	mov    %eax,0x4(%esp)
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 50 02 00 00       	call   800ad0 <printfmt>
			break;
  800880:	e9 3e 02 00 00       	jmp    800ac3 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8d 50 04             	lea    0x4(%eax),%edx
  80088b:	89 55 14             	mov    %edx,0x14(%ebp)
  80088e:	8b 30                	mov    (%eax),%esi
  800890:	85 f6                	test   %esi,%esi
  800892:	75 05                	jne    800899 <vprintfmt+0x1af>
				p = "(null)";
  800894:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  800899:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089d:	7e 37                	jle    8008d6 <vprintfmt+0x1ec>
  80089f:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008a3:	74 31                	je     8008d6 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	89 34 24             	mov    %esi,(%esp)
  8008af:	e8 39 03 00 00       	call   800bed <strnlen>
  8008b4:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008b7:	eb 17                	jmp    8008d0 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008b9:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d4:	7f e3                	jg     8008b9 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d6:	eb 38                	jmp    800910 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008dc:	74 1f                	je     8008fd <vprintfmt+0x213>
  8008de:	83 fb 1f             	cmp    $0x1f,%ebx
  8008e1:	7e 05                	jle    8008e8 <vprintfmt+0x1fe>
  8008e3:	83 fb 7e             	cmp    $0x7e,%ebx
  8008e6:	7e 15                	jle    8008fd <vprintfmt+0x213>
					putch('?', putdat);
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ef:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	ff d0                	call   *%eax
  8008fb:	eb 0f                	jmp    80090c <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800900:	89 44 24 04          	mov    %eax,0x4(%esp)
  800904:	89 1c 24             	mov    %ebx,(%esp)
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800910:	89 f0                	mov    %esi,%eax
  800912:	8d 70 01             	lea    0x1(%eax),%esi
  800915:	0f b6 00             	movzbl (%eax),%eax
  800918:	0f be d8             	movsbl %al,%ebx
  80091b:	85 db                	test   %ebx,%ebx
  80091d:	74 10                	je     80092f <vprintfmt+0x245>
  80091f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800923:	78 b3                	js     8008d8 <vprintfmt+0x1ee>
  800925:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800929:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80092d:	79 a9                	jns    8008d8 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092f:	eb 17                	jmp    800948 <vprintfmt+0x25e>
				putch(' ', putdat);
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800944:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800948:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094c:	7f e3                	jg     800931 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80094e:	e9 70 01 00 00       	jmp    800ac3 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800953:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8d 45 14             	lea    0x14(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 3e fd ff ff       	call   8006a3 <getint>
  800965:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800968:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80096b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800971:	85 d2                	test   %edx,%edx
  800973:	79 26                	jns    80099b <vprintfmt+0x2b1>
				putch('-', putdat);
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	ff d0                	call   *%eax
				num = -(long long) num;
  800988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80098b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80098e:	f7 d8                	neg    %eax
  800990:	83 d2 00             	adc    $0x0,%edx
  800993:	f7 da                	neg    %edx
  800995:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800998:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80099b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009a2:	e9 a8 00 00 00       	jmp    800a4f <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b1:	89 04 24             	mov    %eax,(%esp)
  8009b4:	e8 9b fc ff ff       	call   800654 <getuint>
  8009b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009bf:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c6:	e9 84 00 00 00       	jmp    800a4f <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	e8 77 fc ff ff       	call   800654 <getuint>
  8009dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009e3:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009ea:	eb 63                	jmp    800a4f <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	ff d0                	call   *%eax
			putch('x', putdat);
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a12:	8b 45 14             	mov    0x14(%ebp),%eax
  800a15:	8d 50 04             	lea    0x4(%eax),%edx
  800a18:	89 55 14             	mov    %edx,0x14(%ebp)
  800a1b:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a27:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a2e:	eb 1f                	jmp    800a4f <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a30:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a37:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3a:	89 04 24             	mov    %eax,(%esp)
  800a3d:	e8 12 fc ff ff       	call   800654 <getuint>
  800a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a45:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a48:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a56:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a5d:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a61:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	89 04 24             	mov    %eax,(%esp)
  800a80:	e8 f1 fa ff ff       	call   800576 <printnum>
			break;
  800a85:	eb 3c                	jmp    800ac3 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8e:	89 1c 24             	mov    %ebx,(%esp)
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	ff d0                	call   *%eax
			break;
  800a96:	eb 2b                	jmp    800ac3 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aaf:	eb 04                	jmp    800ab5 <vprintfmt+0x3cb>
  800ab1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ab5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab8:	83 e8 01             	sub    $0x1,%eax
  800abb:	0f b6 00             	movzbl (%eax),%eax
  800abe:	3c 25                	cmp    $0x25,%al
  800ac0:	75 ef                	jne    800ab1 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800ac2:	90                   	nop
		}
	}
  800ac3:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ac4:	e9 43 fc ff ff       	jmp    80070c <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ac9:	83 c4 40             	add    $0x40,%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ad6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	89 04 24             	mov    %eax,(%esp)
  800af7:	e8 ee fb ff ff       	call   8006ea <vprintfmt>
	va_end(ap);
}
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    

00800afe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b04:	8b 40 08             	mov    0x8(%eax),%eax
  800b07:	8d 50 01             	lea    0x1(%eax),%edx
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	8b 10                	mov    (%eax),%edx
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	8b 40 04             	mov    0x4(%eax),%eax
  800b1b:	39 c2                	cmp    %eax,%edx
  800b1d:	73 12                	jae    800b31 <sprintputch+0x33>
		*b->buf++ = ch;
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	8b 00                	mov    (%eax),%eax
  800b24:	8d 48 01             	lea    0x1(%eax),%ecx
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	89 0a                	mov    %ecx,(%edx)
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	88 10                	mov    %dl,(%eax)
}
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	01 d0                	add    %edx,%eax
  800b4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b54:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b58:	74 06                	je     800b60 <vsnprintf+0x2d>
  800b5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5e:	7f 07                	jg     800b67 <vsnprintf+0x34>
		return -E_INVAL;
  800b60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b65:	eb 2a                	jmp    800b91 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b67:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b75:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7c:	c7 04 24 fe 0a 80 00 	movl   $0x800afe,(%esp)
  800b83:	e8 62 fb ff ff       	call   8006ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b99:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	89 04 24             	mov    %eax,(%esp)
  800bba:	e8 74 ff ff ff       	call   800b33 <vsnprintf>
  800bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bcd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bd4:	eb 08                	jmp    800bde <strlen+0x17>
		n++;
  800bd6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bda:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	0f b6 00             	movzbl (%eax),%eax
  800be4:	84 c0                	test   %al,%al
  800be6:	75 ee                	jne    800bd6 <strlen+0xf>
		n++;
	return n;
  800be8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bfa:	eb 0c                	jmp    800c08 <strnlen+0x1b>
		n++;
  800bfc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c00:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c04:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0c:	74 0a                	je     800c18 <strnlen+0x2b>
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	0f b6 00             	movzbl (%eax),%eax
  800c14:	84 c0                	test   %al,%al
  800c16:	75 e4                	jne    800bfc <strnlen+0xf>
		n++;
	return n;
  800c18:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c23:	8b 45 08             	mov    0x8(%ebp),%eax
  800c26:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c29:	90                   	nop
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8d 50 01             	lea    0x1(%eax),%edx
  800c30:	89 55 08             	mov    %edx,0x8(%ebp)
  800c33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c36:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c39:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c3c:	0f b6 12             	movzbl (%edx),%edx
  800c3f:	88 10                	mov    %dl,(%eax)
  800c41:	0f b6 00             	movzbl (%eax),%eax
  800c44:	84 c0                	test   %al,%al
  800c46:	75 e2                	jne    800c2a <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c48:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	89 04 24             	mov    %eax,(%esp)
  800c59:	e8 69 ff ff ff       	call   800bc7 <strlen>
  800c5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c61:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	01 c2                	add    %eax,%edx
  800c69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c70:	89 14 24             	mov    %edx,(%esp)
  800c73:	e8 a5 ff ff ff       	call   800c1d <strcpy>
	return dst;
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c89:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c90:	eb 23                	jmp    800cb5 <strncpy+0x38>
		*dst++ = *src;
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	8d 50 01             	lea    0x1(%eax),%edx
  800c98:	89 55 08             	mov    %edx,0x8(%ebp)
  800c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9e:	0f b6 12             	movzbl (%edx),%edx
  800ca1:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ca3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca6:	0f b6 00             	movzbl (%eax),%eax
  800ca9:	84 c0                	test   %al,%al
  800cab:	74 04                	je     800cb1 <strncpy+0x34>
			src++;
  800cad:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cb8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cbb:	72 d5                	jb     800c92 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd2:	74 33                	je     800d07 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cd4:	eb 17                	jmp    800ced <strlcpy+0x2b>
			*dst++ = *src++;
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	8d 50 01             	lea    0x1(%eax),%edx
  800cdc:	89 55 08             	mov    %edx,0x8(%ebp)
  800cdf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce2:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ce5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ce8:	0f b6 12             	movzbl (%edx),%edx
  800ceb:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ced:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800cf1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf5:	74 0a                	je     800d01 <strlcpy+0x3f>
  800cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfa:	0f b6 00             	movzbl (%eax),%eax
  800cfd:	84 c0                	test   %al,%al
  800cff:	75 d5                	jne    800cd6 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d0d:	29 c2                	sub    %eax,%edx
  800d0f:	89 d0                	mov    %edx,%eax
}
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d16:	eb 08                	jmp    800d20 <strcmp+0xd>
		p++, q++;
  800d18:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d1c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	0f b6 00             	movzbl (%eax),%eax
  800d26:	84 c0                	test   %al,%al
  800d28:	74 10                	je     800d3a <strcmp+0x27>
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	0f b6 10             	movzbl (%eax),%edx
  800d30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d33:	0f b6 00             	movzbl (%eax),%eax
  800d36:	38 c2                	cmp    %al,%dl
  800d38:	74 de                	je     800d18 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	0f b6 00             	movzbl (%eax),%eax
  800d40:	0f b6 d0             	movzbl %al,%edx
  800d43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d46:	0f b6 00             	movzbl (%eax),%eax
  800d49:	0f b6 c0             	movzbl %al,%eax
  800d4c:	29 c2                	sub    %eax,%edx
  800d4e:	89 d0                	mov    %edx,%eax
}
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    

00800d52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d55:	eb 0c                	jmp    800d63 <strncmp+0x11>
		n--, p++, q++;
  800d57:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d63:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d67:	74 1a                	je     800d83 <strncmp+0x31>
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	0f b6 00             	movzbl (%eax),%eax
  800d6f:	84 c0                	test   %al,%al
  800d71:	74 10                	je     800d83 <strncmp+0x31>
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	0f b6 10             	movzbl (%eax),%edx
  800d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	38 c2                	cmp    %al,%dl
  800d81:	74 d4                	je     800d57 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d87:	75 07                	jne    800d90 <strncmp+0x3e>
		return 0;
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8e:	eb 16                	jmp    800da6 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	0f b6 00             	movzbl (%eax),%eax
  800d96:	0f b6 d0             	movzbl %al,%edx
  800d99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9c:	0f b6 00             	movzbl (%eax),%eax
  800d9f:	0f b6 c0             	movzbl %al,%eax
  800da2:	29 c2                	sub    %eax,%edx
  800da4:	89 d0                	mov    %edx,%eax
}
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	83 ec 04             	sub    $0x4,%esp
  800dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db1:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800db4:	eb 14                	jmp    800dca <strchr+0x22>
		if (*s == c)
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	0f b6 00             	movzbl (%eax),%eax
  800dbc:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dbf:	75 05                	jne    800dc6 <strchr+0x1e>
			return (char *) s;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	eb 13                	jmp    800dd9 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	0f b6 00             	movzbl (%eax),%eax
  800dd0:	84 c0                	test   %al,%al
  800dd2:	75 e2                	jne    800db6 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de4:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de7:	eb 11                	jmp    800dfa <strfind+0x1f>
		if (*s == c)
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	0f b6 00             	movzbl (%eax),%eax
  800def:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df2:	75 02                	jne    800df6 <strfind+0x1b>
			break;
  800df4:	eb 0e                	jmp    800e04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800df6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	84 c0                	test   %al,%al
  800e02:	75 e5                	jne    800de9 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e11:	75 05                	jne    800e18 <memset+0xf>
		return v;
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	eb 5c                	jmp    800e74 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	83 e0 03             	and    $0x3,%eax
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	75 41                	jne    800e63 <memset+0x5a>
  800e22:	8b 45 10             	mov    0x10(%ebp),%eax
  800e25:	83 e0 03             	and    $0x3,%eax
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	75 37                	jne    800e63 <memset+0x5a>
		c &= 0xFF;
  800e2c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e36:	c1 e0 18             	shl    $0x18,%eax
  800e39:	89 c2                	mov    %eax,%edx
  800e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3e:	c1 e0 10             	shl    $0x10,%eax
  800e41:	09 c2                	or     %eax,%edx
  800e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e46:	c1 e0 08             	shl    $0x8,%eax
  800e49:	09 d0                	or     %edx,%eax
  800e4b:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e51:	c1 e8 02             	shr    $0x2,%eax
  800e54:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	89 d7                	mov    %edx,%edi
  800e5e:	fc                   	cld    
  800e5f:	f3 ab                	rep stos %eax,%es:(%edi)
  800e61:	eb 0e                	jmp    800e71 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e69:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	fc                   	cld    
  800e6f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e92:	73 6d                	jae    800f01 <memmove+0x8a>
  800e94:	8b 45 10             	mov    0x10(%ebp),%eax
  800e97:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e9a:	01 d0                	add    %edx,%eax
  800e9c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e9f:	76 60                	jbe    800f01 <memmove+0x8a>
		s += n;
  800ea1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea4:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ea7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eaa:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb0:	83 e0 03             	and    $0x3,%eax
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	75 2f                	jne    800ee6 <memmove+0x6f>
  800eb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eba:	83 e0 03             	and    $0x3,%eax
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	75 25                	jne    800ee6 <memmove+0x6f>
  800ec1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec4:	83 e0 03             	and    $0x3,%eax
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	75 1b                	jne    800ee6 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ecb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ece:	83 e8 04             	sub    $0x4,%eax
  800ed1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed4:	83 ea 04             	sub    $0x4,%edx
  800ed7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800eda:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800edd:	89 c7                	mov    %eax,%edi
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	fd                   	std    
  800ee2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee4:	eb 18                	jmp    800efe <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ee6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee9:	8d 50 ff             	lea    -0x1(%eax),%edx
  800eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eef:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef5:	89 d7                	mov    %edx,%edi
  800ef7:	89 de                	mov    %ebx,%esi
  800ef9:	89 c1                	mov    %eax,%ecx
  800efb:	fd                   	std    
  800efc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800efe:	fc                   	cld    
  800eff:	eb 45                	jmp    800f46 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f04:	83 e0 03             	and    $0x3,%eax
  800f07:	85 c0                	test   %eax,%eax
  800f09:	75 2b                	jne    800f36 <memmove+0xbf>
  800f0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f0e:	83 e0 03             	and    $0x3,%eax
  800f11:	85 c0                	test   %eax,%eax
  800f13:	75 21                	jne    800f36 <memmove+0xbf>
  800f15:	8b 45 10             	mov    0x10(%ebp),%eax
  800f18:	83 e0 03             	and    $0x3,%eax
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 17                	jne    800f36 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f22:	c1 e8 02             	shr    $0x2,%eax
  800f25:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f2d:	89 c7                	mov    %eax,%edi
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	fc                   	cld    
  800f32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f34:	eb 10                	jmp    800f46 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3f:	89 c7                	mov    %eax,%edi
  800f41:	89 d6                	mov    %edx,%esi
  800f43:	fc                   	cld    
  800f44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f57:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f65:	8b 45 08             	mov    0x8(%ebp),%eax
  800f68:	89 04 24             	mov    %eax,(%esp)
  800f6b:	e8 07 ff ff ff       	call   800e77 <memmove>
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f81:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f84:	eb 30                	jmp    800fb6 <memcmp+0x44>
		if (*s1 != *s2)
  800f86:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f89:	0f b6 10             	movzbl (%eax),%edx
  800f8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f8f:	0f b6 00             	movzbl (%eax),%eax
  800f92:	38 c2                	cmp    %al,%dl
  800f94:	74 18                	je     800fae <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f96:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f99:	0f b6 00             	movzbl (%eax),%eax
  800f9c:	0f b6 d0             	movzbl %al,%edx
  800f9f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fa2:	0f b6 00             	movzbl (%eax),%eax
  800fa5:	0f b6 c0             	movzbl %al,%eax
  800fa8:	29 c2                	sub    %eax,%edx
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	eb 1a                	jmp    800fc8 <memcmp+0x56>
		s1++, s2++;
  800fae:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fb2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb9:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fbc:	89 55 10             	mov    %edx,0x10(%ebp)
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	75 c3                	jne    800f86 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	01 d0                	add    %edx,%eax
  800fd8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fdb:	eb 13                	jmp    800ff0 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	0f b6 10             	movzbl (%eax),%edx
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	38 c2                	cmp    %al,%dl
  800fe8:	75 02                	jne    800fec <memfind+0x22>
			break;
  800fea:	eb 0c                	jmp    800ff8 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ff6:	72 e5                	jb     800fdd <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800ff8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801003:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80100a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801011:	eb 04                	jmp    801017 <strtol+0x1a>
		s++;
  801013:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801017:	8b 45 08             	mov    0x8(%ebp),%eax
  80101a:	0f b6 00             	movzbl (%eax),%eax
  80101d:	3c 20                	cmp    $0x20,%al
  80101f:	74 f2                	je     801013 <strtol+0x16>
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	0f b6 00             	movzbl (%eax),%eax
  801027:	3c 09                	cmp    $0x9,%al
  801029:	74 e8                	je     801013 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	0f b6 00             	movzbl (%eax),%eax
  801031:	3c 2b                	cmp    $0x2b,%al
  801033:	75 06                	jne    80103b <strtol+0x3e>
		s++;
  801035:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801039:	eb 15                	jmp    801050 <strtol+0x53>
	else if (*s == '-')
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	0f b6 00             	movzbl (%eax),%eax
  801041:	3c 2d                	cmp    $0x2d,%al
  801043:	75 0b                	jne    801050 <strtol+0x53>
		s++, neg = 1;
  801045:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801049:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801050:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801054:	74 06                	je     80105c <strtol+0x5f>
  801056:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80105a:	75 24                	jne    801080 <strtol+0x83>
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	0f b6 00             	movzbl (%eax),%eax
  801062:	3c 30                	cmp    $0x30,%al
  801064:	75 1a                	jne    801080 <strtol+0x83>
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	83 c0 01             	add    $0x1,%eax
  80106c:	0f b6 00             	movzbl (%eax),%eax
  80106f:	3c 78                	cmp    $0x78,%al
  801071:	75 0d                	jne    801080 <strtol+0x83>
		s += 2, base = 16;
  801073:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801077:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80107e:	eb 2a                	jmp    8010aa <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801080:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801084:	75 17                	jne    80109d <strtol+0xa0>
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	0f b6 00             	movzbl (%eax),%eax
  80108c:	3c 30                	cmp    $0x30,%al
  80108e:	75 0d                	jne    80109d <strtol+0xa0>
		s++, base = 8;
  801090:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801094:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80109b:	eb 0d                	jmp    8010aa <strtol+0xad>
	else if (base == 0)
  80109d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010a1:	75 07                	jne    8010aa <strtol+0xad>
		base = 10;
  8010a3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ad:	0f b6 00             	movzbl (%eax),%eax
  8010b0:	3c 2f                	cmp    $0x2f,%al
  8010b2:	7e 1b                	jle    8010cf <strtol+0xd2>
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	0f b6 00             	movzbl (%eax),%eax
  8010ba:	3c 39                	cmp    $0x39,%al
  8010bc:	7f 11                	jg     8010cf <strtol+0xd2>
			dig = *s - '0';
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	0f b6 00             	movzbl (%eax),%eax
  8010c4:	0f be c0             	movsbl %al,%eax
  8010c7:	83 e8 30             	sub    $0x30,%eax
  8010ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010cd:	eb 48                	jmp    801117 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	0f b6 00             	movzbl (%eax),%eax
  8010d5:	3c 60                	cmp    $0x60,%al
  8010d7:	7e 1b                	jle    8010f4 <strtol+0xf7>
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	0f b6 00             	movzbl (%eax),%eax
  8010df:	3c 7a                	cmp    $0x7a,%al
  8010e1:	7f 11                	jg     8010f4 <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e6:	0f b6 00             	movzbl (%eax),%eax
  8010e9:	0f be c0             	movsbl %al,%eax
  8010ec:	83 e8 57             	sub    $0x57,%eax
  8010ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f2:	eb 23                	jmp    801117 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	0f b6 00             	movzbl (%eax),%eax
  8010fa:	3c 40                	cmp    $0x40,%al
  8010fc:	7e 3d                	jle    80113b <strtol+0x13e>
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	0f b6 00             	movzbl (%eax),%eax
  801104:	3c 5a                	cmp    $0x5a,%al
  801106:	7f 33                	jg     80113b <strtol+0x13e>
			dig = *s - 'A' + 10;
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
  80110b:	0f b6 00             	movzbl (%eax),%eax
  80110e:	0f be c0             	movsbl %al,%eax
  801111:	83 e8 37             	sub    $0x37,%eax
  801114:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801117:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80111d:	7c 02                	jl     801121 <strtol+0x124>
			break;
  80111f:	eb 1a                	jmp    80113b <strtol+0x13e>
		s++, val = (val * base) + dig;
  801121:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801125:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801128:	0f af 45 10          	imul   0x10(%ebp),%eax
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801131:	01 d0                	add    %edx,%eax
  801133:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801136:	e9 6f ff ff ff       	jmp    8010aa <strtol+0xad>

	if (endptr)
  80113b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80113f:	74 08                	je     801149 <strtol+0x14c>
		*endptr = (char *) s;
  801141:	8b 45 0c             	mov    0xc(%ebp),%eax
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801149:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80114d:	74 07                	je     801156 <strtol+0x159>
  80114f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801152:	f7 d8                	neg    %eax
  801154:	eb 03                	jmp    801159 <strtol+0x15c>
  801156:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    
  80115b:	66 90                	xchg   %ax,%ax
  80115d:	66 90                	xchg   %ax,%ax
  80115f:	90                   	nop

00801160 <__udivdi3>:
  801160:	55                   	push   %ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	8b 44 24 28          	mov    0x28(%esp),%eax
  80116a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80116e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801172:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801176:	85 c0                	test   %eax,%eax
  801178:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80117c:	89 ea                	mov    %ebp,%edx
  80117e:	89 0c 24             	mov    %ecx,(%esp)
  801181:	75 2d                	jne    8011b0 <__udivdi3+0x50>
  801183:	39 e9                	cmp    %ebp,%ecx
  801185:	77 61                	ja     8011e8 <__udivdi3+0x88>
  801187:	85 c9                	test   %ecx,%ecx
  801189:	89 ce                	mov    %ecx,%esi
  80118b:	75 0b                	jne    801198 <__udivdi3+0x38>
  80118d:	b8 01 00 00 00       	mov    $0x1,%eax
  801192:	31 d2                	xor    %edx,%edx
  801194:	f7 f1                	div    %ecx
  801196:	89 c6                	mov    %eax,%esi
  801198:	31 d2                	xor    %edx,%edx
  80119a:	89 e8                	mov    %ebp,%eax
  80119c:	f7 f6                	div    %esi
  80119e:	89 c5                	mov    %eax,%ebp
  8011a0:	89 f8                	mov    %edi,%eax
  8011a2:	f7 f6                	div    %esi
  8011a4:	89 ea                	mov    %ebp,%edx
  8011a6:	83 c4 0c             	add    $0xc,%esp
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    
  8011ad:	8d 76 00             	lea    0x0(%esi),%esi
  8011b0:	39 e8                	cmp    %ebp,%eax
  8011b2:	77 24                	ja     8011d8 <__udivdi3+0x78>
  8011b4:	0f bd e8             	bsr    %eax,%ebp
  8011b7:	83 f5 1f             	xor    $0x1f,%ebp
  8011ba:	75 3c                	jne    8011f8 <__udivdi3+0x98>
  8011bc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011c0:	39 34 24             	cmp    %esi,(%esp)
  8011c3:	0f 86 9f 00 00 00    	jbe    801268 <__udivdi3+0x108>
  8011c9:	39 d0                	cmp    %edx,%eax
  8011cb:	0f 82 97 00 00 00    	jb     801268 <__udivdi3+0x108>
  8011d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	31 c0                	xor    %eax,%eax
  8011dc:	83 c4 0c             	add    $0xc,%esp
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    
  8011e3:	90                   	nop
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	89 f8                	mov    %edi,%eax
  8011ea:	f7 f1                	div    %ecx
  8011ec:	31 d2                	xor    %edx,%edx
  8011ee:	83 c4 0c             	add    $0xc,%esp
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    
  8011f5:	8d 76 00             	lea    0x0(%esi),%esi
  8011f8:	89 e9                	mov    %ebp,%ecx
  8011fa:	8b 3c 24             	mov    (%esp),%edi
  8011fd:	d3 e0                	shl    %cl,%eax
  8011ff:	89 c6                	mov    %eax,%esi
  801201:	b8 20 00 00 00       	mov    $0x20,%eax
  801206:	29 e8                	sub    %ebp,%eax
  801208:	89 c1                	mov    %eax,%ecx
  80120a:	d3 ef                	shr    %cl,%edi
  80120c:	89 e9                	mov    %ebp,%ecx
  80120e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801212:	8b 3c 24             	mov    (%esp),%edi
  801215:	09 74 24 08          	or     %esi,0x8(%esp)
  801219:	89 d6                	mov    %edx,%esi
  80121b:	d3 e7                	shl    %cl,%edi
  80121d:	89 c1                	mov    %eax,%ecx
  80121f:	89 3c 24             	mov    %edi,(%esp)
  801222:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801226:	d3 ee                	shr    %cl,%esi
  801228:	89 e9                	mov    %ebp,%ecx
  80122a:	d3 e2                	shl    %cl,%edx
  80122c:	89 c1                	mov    %eax,%ecx
  80122e:	d3 ef                	shr    %cl,%edi
  801230:	09 d7                	or     %edx,%edi
  801232:	89 f2                	mov    %esi,%edx
  801234:	89 f8                	mov    %edi,%eax
  801236:	f7 74 24 08          	divl   0x8(%esp)
  80123a:	89 d6                	mov    %edx,%esi
  80123c:	89 c7                	mov    %eax,%edi
  80123e:	f7 24 24             	mull   (%esp)
  801241:	39 d6                	cmp    %edx,%esi
  801243:	89 14 24             	mov    %edx,(%esp)
  801246:	72 30                	jb     801278 <__udivdi3+0x118>
  801248:	8b 54 24 04          	mov    0x4(%esp),%edx
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	d3 e2                	shl    %cl,%edx
  801250:	39 c2                	cmp    %eax,%edx
  801252:	73 05                	jae    801259 <__udivdi3+0xf9>
  801254:	3b 34 24             	cmp    (%esp),%esi
  801257:	74 1f                	je     801278 <__udivdi3+0x118>
  801259:	89 f8                	mov    %edi,%eax
  80125b:	31 d2                	xor    %edx,%edx
  80125d:	e9 7a ff ff ff       	jmp    8011dc <__udivdi3+0x7c>
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	31 d2                	xor    %edx,%edx
  80126a:	b8 01 00 00 00       	mov    $0x1,%eax
  80126f:	e9 68 ff ff ff       	jmp    8011dc <__udivdi3+0x7c>
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	8d 47 ff             	lea    -0x1(%edi),%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	83 c4 0c             	add    $0xc,%esp
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    
  801284:	66 90                	xchg   %ax,%ax
  801286:	66 90                	xchg   %ax,%ax
  801288:	66 90                	xchg   %ax,%ax
  80128a:	66 90                	xchg   %ax,%ax
  80128c:	66 90                	xchg   %ax,%ax
  80128e:	66 90                	xchg   %ax,%ax

00801290 <__umoddi3>:
  801290:	55                   	push   %ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	83 ec 14             	sub    $0x14,%esp
  801296:	8b 44 24 28          	mov    0x28(%esp),%eax
  80129a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80129e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012a2:	89 c7                	mov    %eax,%edi
  8012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012b0:	89 34 24             	mov    %esi,(%esp)
  8012b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	75 17                	jne    8012d8 <__umoddi3+0x48>
  8012c1:	39 fe                	cmp    %edi,%esi
  8012c3:	76 4b                	jbe    801310 <__umoddi3+0x80>
  8012c5:	89 c8                	mov    %ecx,%eax
  8012c7:	89 fa                	mov    %edi,%edx
  8012c9:	f7 f6                	div    %esi
  8012cb:	89 d0                	mov    %edx,%eax
  8012cd:	31 d2                	xor    %edx,%edx
  8012cf:	83 c4 14             	add    $0x14,%esp
  8012d2:	5e                   	pop    %esi
  8012d3:	5f                   	pop    %edi
  8012d4:	5d                   	pop    %ebp
  8012d5:	c3                   	ret    
  8012d6:	66 90                	xchg   %ax,%ax
  8012d8:	39 f8                	cmp    %edi,%eax
  8012da:	77 54                	ja     801330 <__umoddi3+0xa0>
  8012dc:	0f bd e8             	bsr    %eax,%ebp
  8012df:	83 f5 1f             	xor    $0x1f,%ebp
  8012e2:	75 5c                	jne    801340 <__umoddi3+0xb0>
  8012e4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012e8:	39 3c 24             	cmp    %edi,(%esp)
  8012eb:	0f 87 e7 00 00 00    	ja     8013d8 <__umoddi3+0x148>
  8012f1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012f5:	29 f1                	sub    %esi,%ecx
  8012f7:	19 c7                	sbb    %eax,%edi
  8012f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801301:	8b 44 24 08          	mov    0x8(%esp),%eax
  801305:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801309:	83 c4 14             	add    $0x14,%esp
  80130c:	5e                   	pop    %esi
  80130d:	5f                   	pop    %edi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    
  801310:	85 f6                	test   %esi,%esi
  801312:	89 f5                	mov    %esi,%ebp
  801314:	75 0b                	jne    801321 <__umoddi3+0x91>
  801316:	b8 01 00 00 00       	mov    $0x1,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	f7 f6                	div    %esi
  80131f:	89 c5                	mov    %eax,%ebp
  801321:	8b 44 24 04          	mov    0x4(%esp),%eax
  801325:	31 d2                	xor    %edx,%edx
  801327:	f7 f5                	div    %ebp
  801329:	89 c8                	mov    %ecx,%eax
  80132b:	f7 f5                	div    %ebp
  80132d:	eb 9c                	jmp    8012cb <__umoddi3+0x3b>
  80132f:	90                   	nop
  801330:	89 c8                	mov    %ecx,%eax
  801332:	89 fa                	mov    %edi,%edx
  801334:	83 c4 14             	add    $0x14,%esp
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    
  80133b:	90                   	nop
  80133c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801340:	8b 04 24             	mov    (%esp),%eax
  801343:	be 20 00 00 00       	mov    $0x20,%esi
  801348:	89 e9                	mov    %ebp,%ecx
  80134a:	29 ee                	sub    %ebp,%esi
  80134c:	d3 e2                	shl    %cl,%edx
  80134e:	89 f1                	mov    %esi,%ecx
  801350:	d3 e8                	shr    %cl,%eax
  801352:	89 e9                	mov    %ebp,%ecx
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	8b 04 24             	mov    (%esp),%eax
  80135b:	09 54 24 04          	or     %edx,0x4(%esp)
  80135f:	89 fa                	mov    %edi,%edx
  801361:	d3 e0                	shl    %cl,%eax
  801363:	89 f1                	mov    %esi,%ecx
  801365:	89 44 24 08          	mov    %eax,0x8(%esp)
  801369:	8b 44 24 10          	mov    0x10(%esp),%eax
  80136d:	d3 ea                	shr    %cl,%edx
  80136f:	89 e9                	mov    %ebp,%ecx
  801371:	d3 e7                	shl    %cl,%edi
  801373:	89 f1                	mov    %esi,%ecx
  801375:	d3 e8                	shr    %cl,%eax
  801377:	89 e9                	mov    %ebp,%ecx
  801379:	09 f8                	or     %edi,%eax
  80137b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80137f:	f7 74 24 04          	divl   0x4(%esp)
  801383:	d3 e7                	shl    %cl,%edi
  801385:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801389:	89 d7                	mov    %edx,%edi
  80138b:	f7 64 24 08          	mull   0x8(%esp)
  80138f:	39 d7                	cmp    %edx,%edi
  801391:	89 c1                	mov    %eax,%ecx
  801393:	89 14 24             	mov    %edx,(%esp)
  801396:	72 2c                	jb     8013c4 <__umoddi3+0x134>
  801398:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80139c:	72 22                	jb     8013c0 <__umoddi3+0x130>
  80139e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013a2:	29 c8                	sub    %ecx,%eax
  8013a4:	19 d7                	sbb    %edx,%edi
  8013a6:	89 e9                	mov    %ebp,%ecx
  8013a8:	89 fa                	mov    %edi,%edx
  8013aa:	d3 e8                	shr    %cl,%eax
  8013ac:	89 f1                	mov    %esi,%ecx
  8013ae:	d3 e2                	shl    %cl,%edx
  8013b0:	89 e9                	mov    %ebp,%ecx
  8013b2:	d3 ef                	shr    %cl,%edi
  8013b4:	09 d0                	or     %edx,%eax
  8013b6:	89 fa                	mov    %edi,%edx
  8013b8:	83 c4 14             	add    $0x14,%esp
  8013bb:	5e                   	pop    %esi
  8013bc:	5f                   	pop    %edi
  8013bd:	5d                   	pop    %ebp
  8013be:	c3                   	ret    
  8013bf:	90                   	nop
  8013c0:	39 d7                	cmp    %edx,%edi
  8013c2:	75 da                	jne    80139e <__umoddi3+0x10e>
  8013c4:	8b 14 24             	mov    (%esp),%edx
  8013c7:	89 c1                	mov    %eax,%ecx
  8013c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8013cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8013d1:	eb cb                	jmp    80139e <__umoddi3+0x10e>
  8013d3:	90                   	nop
  8013d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8013dc:	0f 82 0f ff ff ff    	jb     8012f1 <__umoddi3+0x61>
  8013e2:	e9 1a ff ff ff       	jmp    801301 <__umoddi3+0x71>
