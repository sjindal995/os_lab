
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
  8000ed:	c7 44 24 08 58 14 80 	movl   $0x801458,0x8(%esp)
  8000f4:	00 
  8000f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000fc:	00 
  8000fd:	c7 04 24 75 14 80 00 	movl   $0x801475,(%esp)
  800104:	e8 6f 03 00 00       	call   800478 <_panic>

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

00800435 <sys_exec>:

void sys_exec(char* buf){
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800445:	00 
  800446:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80044d:	00 
  80044e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800455:	00 
  800456:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80045d:	00 
  80045e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800462:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800469:	00 
  80046a:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800471:	e8 3d fc ff ff       	call   8000b3 <syscall>
}
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	53                   	push   %ebx
  80047c:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80047f:	8d 45 14             	lea    0x14(%ebp),%eax
  800482:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800485:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  80048b:	e8 4d fd ff ff       	call   8001dd <sys_getenvid>
  800490:	8b 55 0c             	mov    0xc(%ebp),%edx
  800493:	89 54 24 10          	mov    %edx,0x10(%esp)
  800497:	8b 55 08             	mov    0x8(%ebp),%edx
  80049a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a6:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  8004ad:	e8 e1 00 00 00       	call   800593 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	e8 6b 00 00 00       	call   80052f <vcprintf>
	cprintf("\n");
  8004c4:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  8004cb:	e8 c3 00 00 00       	call   800593 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004d0:	cc                   	int3   
  8004d1:	eb fd                	jmp    8004d0 <_panic+0x58>

008004d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	8d 48 01             	lea    0x1(%eax),%ecx
  8004e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e4:	89 0a                	mov    %ecx,(%edx)
  8004e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e9:	89 d1                	mov    %edx,%ecx
  8004eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ee:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004fc:	75 20                	jne    80051e <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800501:	8b 00                	mov    (%eax),%eax
  800503:	8b 55 0c             	mov    0xc(%ebp),%edx
  800506:	83 c2 08             	add    $0x8,%edx
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	89 14 24             	mov    %edx,(%esp)
  800510:	e8 ff fb ff ff       	call   800114 <sys_cputs>
		b->idx = 0;
  800515:	8b 45 0c             	mov    0xc(%ebp),%eax
  800518:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80051e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800521:	8b 40 04             	mov    0x4(%eax),%eax
  800524:	8d 50 01             	lea    0x1(%eax),%edx
  800527:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052a:	89 50 04             	mov    %edx,0x4(%eax)
}
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800538:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80053f:	00 00 00 
	b.cnt = 0;
  800542:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800549:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80054c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800553:	8b 45 08             	mov    0x8(%ebp),%eax
  800556:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800560:	89 44 24 04          	mov    %eax,0x4(%esp)
  800564:	c7 04 24 d3 04 80 00 	movl   $0x8004d3,(%esp)
  80056b:	e8 bd 01 00 00       	call   80072d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800570:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800576:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800580:	83 c0 08             	add    $0x8,%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	e8 89 fb ff ff       	call   800114 <sys_cputs>

	return b.cnt;
  80058b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800591:	c9                   	leave  
  800592:	c3                   	ret    

00800593 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800599:	8d 45 0c             	lea    0xc(%ebp),%eax
  80059c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80059f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	e8 7e ff ff ff       	call   80052f <vcprintf>
  8005b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005b7:	c9                   	leave  
  8005b8:	c3                   	ret    

008005b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 34             	sub    $0x34,%esp
  8005c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005cc:	8b 45 18             	mov    0x18(%ebp),%eax
  8005cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d4:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005d7:	77 72                	ja     80064b <printnum+0x92>
  8005d9:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005dc:	72 05                	jb     8005e3 <printnum+0x2a>
  8005de:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005e1:	77 68                	ja     80064b <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e3:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005e6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005e9:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	89 54 24 04          	mov    %edx,0x4(%esp)
  800606:	e8 95 0b 00 00       	call   8011a0 <__udivdi3>
  80060b:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80060e:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800612:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800616:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800619:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80061d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800621:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800625:	8b 45 0c             	mov    0xc(%ebp),%eax
  800628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	e8 82 ff ff ff       	call   8005b9 <printnum>
  800637:	eb 1c                	jmp    800655 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800639:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	8b 45 20             	mov    0x20(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	8b 45 08             	mov    0x8(%ebp),%eax
  800649:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80064b:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80064f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800653:	7f e4                	jg     800639 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800655:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800658:	bb 00 00 00 00       	mov    $0x0,%ebx
  80065d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800660:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800663:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800667:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800672:	e8 59 0c 00 00       	call   8012d0 <__umoddi3>
  800677:	05 88 15 80 00       	add    $0x801588,%eax
  80067c:	0f b6 00             	movzbl (%eax),%eax
  80067f:	0f be c0             	movsbl %al,%eax
  800682:	8b 55 0c             	mov    0xc(%ebp),%edx
  800685:	89 54 24 04          	mov    %edx,0x4(%esp)
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	ff d0                	call   *%eax
}
  800691:	83 c4 34             	add    $0x34,%esp
  800694:	5b                   	pop    %ebx
  800695:	5d                   	pop    %ebp
  800696:	c3                   	ret    

00800697 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80069a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80069e:	7e 14                	jle    8006b4 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ab:	89 0a                	mov    %ecx,(%edx)
  8006ad:	8b 50 04             	mov    0x4(%eax),%edx
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	eb 30                	jmp    8006e4 <getuint+0x4d>
	else if (lflag)
  8006b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b8:	74 16                	je     8006d0 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c5:	89 0a                	mov    %ecx,(%edx)
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ce:	eb 14                	jmp    8006e4 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006db:	89 0a                	mov    %ecx,(%edx)
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006e9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006ed:	7e 14                	jle    800703 <getint+0x1d>
		return va_arg(*ap, long long);
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	8d 48 08             	lea    0x8(%eax),%ecx
  8006f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006fa:	89 0a                	mov    %ecx,(%edx)
  8006fc:	8b 50 04             	mov    0x4(%eax),%edx
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	eb 28                	jmp    80072b <getint+0x45>
	else if (lflag)
  800703:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800707:	74 12                	je     80071b <getint+0x35>
		return va_arg(*ap, long);
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	8d 48 04             	lea    0x4(%eax),%ecx
  800711:	8b 55 08             	mov    0x8(%ebp),%edx
  800714:	89 0a                	mov    %ecx,(%edx)
  800716:	8b 00                	mov    (%eax),%eax
  800718:	99                   	cltd   
  800719:	eb 10                	jmp    80072b <getint+0x45>
	else
		return va_arg(*ap, int);
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 00                	mov    (%eax),%eax
  800720:	8d 48 04             	lea    0x4(%eax),%ecx
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
  800726:	89 0a                	mov    %ecx,(%edx)
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	99                   	cltd   
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	56                   	push   %esi
  800731:	53                   	push   %ebx
  800732:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800735:	eb 18                	jmp    80074f <vprintfmt+0x22>
			if (ch == '\0')
  800737:	85 db                	test   %ebx,%ebx
  800739:	75 05                	jne    800740 <vprintfmt+0x13>
				return;
  80073b:	e9 cc 03 00 00       	jmp    800b0c <vprintfmt+0x3df>
			putch(ch, putdat);
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	89 1c 24             	mov    %ebx,(%esp)
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074f:	8b 45 10             	mov    0x10(%ebp),%eax
  800752:	8d 50 01             	lea    0x1(%eax),%edx
  800755:	89 55 10             	mov    %edx,0x10(%ebp)
  800758:	0f b6 00             	movzbl (%eax),%eax
  80075b:	0f b6 d8             	movzbl %al,%ebx
  80075e:	83 fb 25             	cmp    $0x25,%ebx
  800761:	75 d4                	jne    800737 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800763:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800767:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80076e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800775:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80077c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800783:	8b 45 10             	mov    0x10(%ebp),%eax
  800786:	8d 50 01             	lea    0x1(%eax),%edx
  800789:	89 55 10             	mov    %edx,0x10(%ebp)
  80078c:	0f b6 00             	movzbl (%eax),%eax
  80078f:	0f b6 d8             	movzbl %al,%ebx
  800792:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800795:	83 f8 55             	cmp    $0x55,%eax
  800798:	0f 87 3d 03 00 00    	ja     800adb <vprintfmt+0x3ae>
  80079e:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  8007a5:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a7:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007ab:	eb d6                	jmp    800783 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007ad:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007b1:	eb d0                	jmp    800783 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007b3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007bd:	89 d0                	mov    %edx,%eax
  8007bf:	c1 e0 02             	shl    $0x2,%eax
  8007c2:	01 d0                	add    %edx,%eax
  8007c4:	01 c0                	add    %eax,%eax
  8007c6:	01 d8                	add    %ebx,%eax
  8007c8:	83 e8 30             	sub    $0x30,%eax
  8007cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d1:	0f b6 00             	movzbl (%eax),%eax
  8007d4:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007d7:	83 fb 2f             	cmp    $0x2f,%ebx
  8007da:	7e 0b                	jle    8007e7 <vprintfmt+0xba>
  8007dc:	83 fb 39             	cmp    $0x39,%ebx
  8007df:	7f 06                	jg     8007e7 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007e5:	eb d3                	jmp    8007ba <vprintfmt+0x8d>
			goto process_precision;
  8007e7:	eb 33                	jmp    80081c <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 00                	mov    (%eax),%eax
  8007f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007f7:	eb 23                	jmp    80081c <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007fd:	79 0c                	jns    80080b <vprintfmt+0xde>
				width = 0;
  8007ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800806:	e9 78 ff ff ff       	jmp    800783 <vprintfmt+0x56>
  80080b:	e9 73 ff ff ff       	jmp    800783 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800810:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800817:	e9 67 ff ff ff       	jmp    800783 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80081c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800820:	79 12                	jns    800834 <vprintfmt+0x107>
				width = precision, precision = -1;
  800822:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800825:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800828:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80082f:	e9 4f ff ff ff       	jmp    800783 <vprintfmt+0x56>
  800834:	e9 4a ff ff ff       	jmp    800783 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800839:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80083d:	e9 41 ff ff ff       	jmp    800783 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 50 04             	lea    0x4(%eax),%edx
  800848:	89 55 14             	mov    %edx,0x14(%ebp)
  80084b:	8b 00                	mov    (%eax),%eax
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 54 24 04          	mov    %edx,0x4(%esp)
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	ff d0                	call   *%eax
			break;
  80085c:	e9 a5 02 00 00       	jmp    800b06 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8d 50 04             	lea    0x4(%eax),%edx
  800867:	89 55 14             	mov    %edx,0x14(%ebp)
  80086a:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80086c:	85 db                	test   %ebx,%ebx
  80086e:	79 02                	jns    800872 <vprintfmt+0x145>
				err = -err;
  800870:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800872:	83 fb 09             	cmp    $0x9,%ebx
  800875:	7f 0b                	jg     800882 <vprintfmt+0x155>
  800877:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  80087e:	85 f6                	test   %esi,%esi
  800880:	75 23                	jne    8008a5 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800882:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800886:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  80088d:	00 
  80088e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800891:	89 44 24 04          	mov    %eax,0x4(%esp)
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	89 04 24             	mov    %eax,(%esp)
  80089b:	e8 73 02 00 00       	call   800b13 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008a0:	e9 61 02 00 00       	jmp    800b06 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008a9:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008b0:	00 
  8008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	89 04 24             	mov    %eax,(%esp)
  8008be:	e8 50 02 00 00       	call   800b13 <printfmt>
			break;
  8008c3:	e9 3e 02 00 00       	jmp    800b06 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d1:	8b 30                	mov    (%eax),%esi
  8008d3:	85 f6                	test   %esi,%esi
  8008d5:	75 05                	jne    8008dc <vprintfmt+0x1af>
				p = "(null)";
  8008d7:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8008dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008e0:	7e 37                	jle    800919 <vprintfmt+0x1ec>
  8008e2:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008e6:	74 31                	je     800919 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ef:	89 34 24             	mov    %esi,(%esp)
  8008f2:	e8 39 03 00 00       	call   800c30 <strnlen>
  8008f7:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008fa:	eb 17                	jmp    800913 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008fc:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
  800903:	89 54 24 04          	mov    %edx,0x4(%esp)
  800907:	89 04 24             	mov    %eax,(%esp)
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80090f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800913:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800917:	7f e3                	jg     8008fc <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800919:	eb 38                	jmp    800953 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80091b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80091f:	74 1f                	je     800940 <vprintfmt+0x213>
  800921:	83 fb 1f             	cmp    $0x1f,%ebx
  800924:	7e 05                	jle    80092b <vprintfmt+0x1fe>
  800926:	83 fb 7e             	cmp    $0x7e,%ebx
  800929:	7e 15                	jle    800940 <vprintfmt+0x213>
					putch('?', putdat);
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	ff d0                	call   *%eax
  80093e:	eb 0f                	jmp    80094f <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	89 44 24 04          	mov    %eax,0x4(%esp)
  800947:	89 1c 24             	mov    %ebx,(%esp)
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800953:	89 f0                	mov    %esi,%eax
  800955:	8d 70 01             	lea    0x1(%eax),%esi
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f be d8             	movsbl %al,%ebx
  80095e:	85 db                	test   %ebx,%ebx
  800960:	74 10                	je     800972 <vprintfmt+0x245>
  800962:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800966:	78 b3                	js     80091b <vprintfmt+0x1ee>
  800968:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80096c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800970:	79 a9                	jns    80091b <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800972:	eb 17                	jmp    80098b <vprintfmt+0x25e>
				putch(' ', putdat);
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800987:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80098b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80098f:	7f e3                	jg     800974 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800991:	e9 70 01 00 00       	jmp    800b06 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800996:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099d:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	e8 3e fd ff ff       	call   8006e6 <getint>
  8009a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009b4:	85 d2                	test   %edx,%edx
  8009b6:	79 26                	jns    8009de <vprintfmt+0x2b1>
				putch('-', putdat);
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	ff d0                	call   *%eax
				num = -(long long) num;
  8009cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d1:	f7 d8                	neg    %eax
  8009d3:	83 d2 00             	adc    $0x0,%edx
  8009d6:	f7 da                	neg    %edx
  8009d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009db:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009de:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009e5:	e9 a8 00 00 00       	jmp    800a92 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	e8 9b fc ff ff       	call   800697 <getuint>
  8009fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ff:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a02:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a09:	e9 84 00 00 00       	jmp    800a92 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a15:	8d 45 14             	lea    0x14(%ebp),%eax
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	e8 77 fc ff ff       	call   800697 <getuint>
  800a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a23:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a26:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a2d:	eb 63                	jmp    800a92 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a36:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	ff d0                	call   *%eax
			putch('x', putdat);
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a49:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a55:	8b 45 14             	mov    0x14(%ebp),%eax
  800a58:	8d 50 04             	lea    0x4(%eax),%edx
  800a5b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a5e:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a6a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a71:	eb 1f                	jmp    800a92 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a73:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a7d:	89 04 24             	mov    %eax,(%esp)
  800a80:	e8 12 fc ff ff       	call   800697 <getuint>
  800a85:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a88:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a8b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a92:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a96:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a99:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aa0:	89 54 24 14          	mov    %edx,0x14(%esp)
  800aa4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aae:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	89 04 24             	mov    %eax,(%esp)
  800ac3:	e8 f1 fa ff ff       	call   8005b9 <printnum>
			break;
  800ac8:	eb 3c                	jmp    800b06 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad1:	89 1c 24             	mov    %ebx,(%esp)
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	ff d0                	call   *%eax
			break;
  800ad9:	eb 2b                	jmp    800b06 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aee:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800af2:	eb 04                	jmp    800af8 <vprintfmt+0x3cb>
  800af4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800af8:	8b 45 10             	mov    0x10(%ebp),%eax
  800afb:	83 e8 01             	sub    $0x1,%eax
  800afe:	0f b6 00             	movzbl (%eax),%eax
  800b01:	3c 25                	cmp    $0x25,%al
  800b03:	75 ef                	jne    800af4 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b05:	90                   	nop
		}
	}
  800b06:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b07:	e9 43 fc ff ff       	jmp    80074f <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b0c:	83 c4 40             	add    $0x40,%esp
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b19:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b22:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	89 04 24             	mov    %eax,(%esp)
  800b3a:	e8 ee fb ff ff       	call   80072d <vprintfmt>
	va_end(ap);
}
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b47:	8b 40 08             	mov    0x8(%eax),%eax
  800b4a:	8d 50 01             	lea    0x1(%eax),%edx
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	8b 10                	mov    (%eax),%edx
  800b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5b:	8b 40 04             	mov    0x4(%eax),%eax
  800b5e:	39 c2                	cmp    %eax,%edx
  800b60:	73 12                	jae    800b74 <sprintputch+0x33>
		*b->buf++ = ch;
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	8b 00                	mov    (%eax),%eax
  800b67:	8d 48 01             	lea    0x1(%eax),%ecx
  800b6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6d:	89 0a                	mov    %ecx,(%edx)
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	88 10                	mov    %dl,(%eax)
}
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b85:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	01 d0                	add    %edx,%eax
  800b8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b97:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b9b:	74 06                	je     800ba3 <vsnprintf+0x2d>
  800b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba1:	7f 07                	jg     800baa <vsnprintf+0x34>
		return -E_INVAL;
  800ba3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ba8:	eb 2a                	jmp    800bd4 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800baa:	8b 45 14             	mov    0x14(%ebp),%eax
  800bad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbf:	c7 04 24 41 0b 80 00 	movl   $0x800b41,(%esp)
  800bc6:	e8 62 fb ff ff       	call   80072d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bdc:	8d 45 14             	lea    0x14(%ebp),%eax
  800bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be9:	8b 45 10             	mov    0x10(%ebp),%eax
  800bec:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfa:	89 04 24             	mov    %eax,(%esp)
  800bfd:	e8 74 ff ff ff       	call   800b76 <vsnprintf>
  800c02:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c10:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c17:	eb 08                	jmp    800c21 <strlen+0x17>
		n++;
  800c19:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	0f b6 00             	movzbl (%eax),%eax
  800c27:	84 c0                	test   %al,%al
  800c29:	75 ee                	jne    800c19 <strlen+0xf>
		n++;
	return n;
  800c2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c36:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c3d:	eb 0c                	jmp    800c4b <strnlen+0x1b>
		n++;
  800c3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c47:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4f:	74 0a                	je     800c5b <strnlen+0x2b>
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	0f b6 00             	movzbl (%eax),%eax
  800c57:	84 c0                	test   %al,%al
  800c59:	75 e4                	jne    800c3f <strnlen+0xf>
		n++;
	return n;
  800c5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c5e:	c9                   	leave  
  800c5f:	c3                   	ret    

00800c60 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
  800c69:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c6c:	90                   	nop
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	8d 50 01             	lea    0x1(%eax),%edx
  800c73:	89 55 08             	mov    %edx,0x8(%ebp)
  800c76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c79:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c7c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c7f:	0f b6 12             	movzbl (%edx),%edx
  800c82:	88 10                	mov    %dl,(%eax)
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	84 c0                	test   %al,%al
  800c89:	75 e2                	jne    800c6d <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c96:	8b 45 08             	mov    0x8(%ebp),%eax
  800c99:	89 04 24             	mov    %eax,(%esp)
  800c9c:	e8 69 ff ff ff       	call   800c0a <strlen>
  800ca1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800ca4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	01 c2                	add    %eax,%edx
  800cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb3:	89 14 24             	mov    %edx,(%esp)
  800cb6:	e8 a5 ff ff ff       	call   800c60 <strcpy>
	return dst;
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800ccc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cd3:	eb 23                	jmp    800cf8 <strncpy+0x38>
		*dst++ = *src;
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	8d 50 01             	lea    0x1(%eax),%edx
  800cdb:	89 55 08             	mov    %edx,0x8(%ebp)
  800cde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce1:	0f b6 12             	movzbl (%edx),%edx
  800ce4:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce9:	0f b6 00             	movzbl (%eax),%eax
  800cec:	84 c0                	test   %al,%al
  800cee:	74 04                	je     800cf4 <strncpy+0x34>
			src++;
  800cf0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cfb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cfe:	72 d5                	jb     800cd5 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d00:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d15:	74 33                	je     800d4a <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d17:	eb 17                	jmp    800d30 <strlcpy+0x2b>
			*dst++ = *src++;
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	8d 50 01             	lea    0x1(%eax),%edx
  800d1f:	89 55 08             	mov    %edx,0x8(%ebp)
  800d22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d25:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d28:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d2b:	0f b6 12             	movzbl (%edx),%edx
  800d2e:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d38:	74 0a                	je     800d44 <strlcpy+0x3f>
  800d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3d:	0f b6 00             	movzbl (%eax),%eax
  800d40:	84 c0                	test   %al,%al
  800d42:	75 d5                	jne    800d19 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d50:	29 c2                	sub    %eax,%edx
  800d52:	89 d0                	mov    %edx,%eax
}
  800d54:	c9                   	leave  
  800d55:	c3                   	ret    

00800d56 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d59:	eb 08                	jmp    800d63 <strcmp+0xd>
		p++, q++;
  800d5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	84 c0                	test   %al,%al
  800d6b:	74 10                	je     800d7d <strcmp+0x27>
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	0f b6 10             	movzbl (%eax),%edx
  800d73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d76:	0f b6 00             	movzbl (%eax),%eax
  800d79:	38 c2                	cmp    %al,%dl
  800d7b:	74 de                	je     800d5b <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	0f b6 00             	movzbl (%eax),%eax
  800d83:	0f b6 d0             	movzbl %al,%edx
  800d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d89:	0f b6 00             	movzbl (%eax),%eax
  800d8c:	0f b6 c0             	movzbl %al,%eax
  800d8f:	29 c2                	sub    %eax,%edx
  800d91:	89 d0                	mov    %edx,%eax
}
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d98:	eb 0c                	jmp    800da6 <strncmp+0x11>
		n--, p++, q++;
  800d9a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d9e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800da6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800daa:	74 1a                	je     800dc6 <strncmp+0x31>
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	0f b6 00             	movzbl (%eax),%eax
  800db2:	84 c0                	test   %al,%al
  800db4:	74 10                	je     800dc6 <strncmp+0x31>
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	0f b6 10             	movzbl (%eax),%edx
  800dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbf:	0f b6 00             	movzbl (%eax),%eax
  800dc2:	38 c2                	cmp    %al,%dl
  800dc4:	74 d4                	je     800d9a <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dc6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dca:	75 07                	jne    800dd3 <strncmp+0x3e>
		return 0;
  800dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd1:	eb 16                	jmp    800de9 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	0f b6 00             	movzbl (%eax),%eax
  800dd9:	0f b6 d0             	movzbl %al,%edx
  800ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddf:	0f b6 00             	movzbl (%eax),%eax
  800de2:	0f b6 c0             	movzbl %al,%eax
  800de5:	29 c2                	sub    %eax,%edx
  800de7:	89 d0                	mov    %edx,%eax
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df4:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800df7:	eb 14                	jmp    800e0d <strchr+0x22>
		if (*s == c)
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e02:	75 05                	jne    800e09 <strchr+0x1e>
			return (char *) s;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	eb 13                	jmp    800e1c <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	0f b6 00             	movzbl (%eax),%eax
  800e13:	84 c0                	test   %al,%al
  800e15:	75 e2                	jne    800df9 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e27:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e2a:	eb 11                	jmp    800e3d <strfind+0x1f>
		if (*s == c)
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e35:	75 02                	jne    800e39 <strfind+0x1b>
			break;
  800e37:	eb 0e                	jmp    800e47 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e39:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 00             	movzbl (%eax),%eax
  800e43:	84 c0                	test   %al,%al
  800e45:	75 e5                	jne    800e2c <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e54:	75 05                	jne    800e5b <memset+0xf>
		return v;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	eb 5c                	jmp    800eb7 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	83 e0 03             	and    $0x3,%eax
  800e61:	85 c0                	test   %eax,%eax
  800e63:	75 41                	jne    800ea6 <memset+0x5a>
  800e65:	8b 45 10             	mov    0x10(%ebp),%eax
  800e68:	83 e0 03             	and    $0x3,%eax
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	75 37                	jne    800ea6 <memset+0x5a>
		c &= 0xFF;
  800e6f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e79:	c1 e0 18             	shl    $0x18,%eax
  800e7c:	89 c2                	mov    %eax,%edx
  800e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e81:	c1 e0 10             	shl    $0x10,%eax
  800e84:	09 c2                	or     %eax,%edx
  800e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e89:	c1 e0 08             	shl    $0x8,%eax
  800e8c:	09 d0                	or     %edx,%eax
  800e8e:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e91:	8b 45 10             	mov    0x10(%ebp),%eax
  800e94:	c1 e8 02             	shr    $0x2,%eax
  800e97:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	89 d7                	mov    %edx,%edi
  800ea1:	fc                   	cld    
  800ea2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea4:	eb 0e                	jmp    800eb4 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800eaf:	89 d7                	mov    %edx,%edi
  800eb1:	fc                   	cld    
  800eb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed5:	73 6d                	jae    800f44 <memmove+0x8a>
  800ed7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eda:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800edd:	01 d0                	add    %edx,%eax
  800edf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ee2:	76 60                	jbe    800f44 <memmove+0x8a>
		s += n;
  800ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee7:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800eea:	8b 45 10             	mov    0x10(%ebp),%eax
  800eed:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef3:	83 e0 03             	and    $0x3,%eax
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	75 2f                	jne    800f29 <memmove+0x6f>
  800efa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efd:	83 e0 03             	and    $0x3,%eax
  800f00:	85 c0                	test   %eax,%eax
  800f02:	75 25                	jne    800f29 <memmove+0x6f>
  800f04:	8b 45 10             	mov    0x10(%ebp),%eax
  800f07:	83 e0 03             	and    $0x3,%eax
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	75 1b                	jne    800f29 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f11:	83 e8 04             	sub    $0x4,%eax
  800f14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f17:	83 ea 04             	sub    $0x4,%edx
  800f1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f1d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f20:	89 c7                	mov    %eax,%edi
  800f22:	89 d6                	mov    %edx,%esi
  800f24:	fd                   	std    
  800f25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f27:	eb 18                	jmp    800f41 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f32:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f35:	8b 45 10             	mov    0x10(%ebp),%eax
  800f38:	89 d7                	mov    %edx,%edi
  800f3a:	89 de                	mov    %ebx,%esi
  800f3c:	89 c1                	mov    %eax,%ecx
  800f3e:	fd                   	std    
  800f3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f41:	fc                   	cld    
  800f42:	eb 45                	jmp    800f89 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f47:	83 e0 03             	and    $0x3,%eax
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	75 2b                	jne    800f79 <memmove+0xbf>
  800f4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f51:	83 e0 03             	and    $0x3,%eax
  800f54:	85 c0                	test   %eax,%eax
  800f56:	75 21                	jne    800f79 <memmove+0xbf>
  800f58:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5b:	83 e0 03             	and    $0x3,%eax
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	75 17                	jne    800f79 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f62:	8b 45 10             	mov    0x10(%ebp),%eax
  800f65:	c1 e8 02             	shr    $0x2,%eax
  800f68:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f70:	89 c7                	mov    %eax,%edi
  800f72:	89 d6                	mov    %edx,%esi
  800f74:	fc                   	cld    
  800f75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f77:	eb 10                	jmp    800f89 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	fc                   	cld    
  800f87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f9a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	89 04 24             	mov    %eax,(%esp)
  800fae:	e8 07 ff ff ff       	call   800eba <memmove>
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc4:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fc7:	eb 30                	jmp    800ff9 <memcmp+0x44>
		if (*s1 != *s2)
  800fc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fcc:	0f b6 10             	movzbl (%eax),%edx
  800fcf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd2:	0f b6 00             	movzbl (%eax),%eax
  800fd5:	38 c2                	cmp    %al,%dl
  800fd7:	74 18                	je     800ff1 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fdc:	0f b6 00             	movzbl (%eax),%eax
  800fdf:	0f b6 d0             	movzbl %al,%edx
  800fe2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fe5:	0f b6 00             	movzbl (%eax),%eax
  800fe8:	0f b6 c0             	movzbl %al,%eax
  800feb:	29 c2                	sub    %eax,%edx
  800fed:	89 d0                	mov    %edx,%eax
  800fef:	eb 1a                	jmp    80100b <memcmp+0x56>
		s1++, s2++;
  800ff1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ff5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fff:	89 55 10             	mov    %edx,0x10(%ebp)
  801002:	85 c0                	test   %eax,%eax
  801004:	75 c3                	jne    800fc9 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801006:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    

0080100d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801013:	8b 45 10             	mov    0x10(%ebp),%eax
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	01 d0                	add    %edx,%eax
  80101b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80101e:	eb 13                	jmp    801033 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	0f b6 10             	movzbl (%eax),%edx
  801026:	8b 45 0c             	mov    0xc(%ebp),%eax
  801029:	38 c2                	cmp    %al,%dl
  80102b:	75 02                	jne    80102f <memfind+0x22>
			break;
  80102d:	eb 0c                	jmp    80103b <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80102f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801039:	72 e5                	jb     801020 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801046:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80104d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801054:	eb 04                	jmp    80105a <strtol+0x1a>
		s++;
  801056:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105a:	8b 45 08             	mov    0x8(%ebp),%eax
  80105d:	0f b6 00             	movzbl (%eax),%eax
  801060:	3c 20                	cmp    $0x20,%al
  801062:	74 f2                	je     801056 <strtol+0x16>
  801064:	8b 45 08             	mov    0x8(%ebp),%eax
  801067:	0f b6 00             	movzbl (%eax),%eax
  80106a:	3c 09                	cmp    $0x9,%al
  80106c:	74 e8                	je     801056 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	0f b6 00             	movzbl (%eax),%eax
  801074:	3c 2b                	cmp    $0x2b,%al
  801076:	75 06                	jne    80107e <strtol+0x3e>
		s++;
  801078:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107c:	eb 15                	jmp    801093 <strtol+0x53>
	else if (*s == '-')
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	0f b6 00             	movzbl (%eax),%eax
  801084:	3c 2d                	cmp    $0x2d,%al
  801086:	75 0b                	jne    801093 <strtol+0x53>
		s++, neg = 1;
  801088:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80108c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801093:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801097:	74 06                	je     80109f <strtol+0x5f>
  801099:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80109d:	75 24                	jne    8010c3 <strtol+0x83>
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	0f b6 00             	movzbl (%eax),%eax
  8010a5:	3c 30                	cmp    $0x30,%al
  8010a7:	75 1a                	jne    8010c3 <strtol+0x83>
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	83 c0 01             	add    $0x1,%eax
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	3c 78                	cmp    $0x78,%al
  8010b4:	75 0d                	jne    8010c3 <strtol+0x83>
		s += 2, base = 16;
  8010b6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010ba:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010c1:	eb 2a                	jmp    8010ed <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c7:	75 17                	jne    8010e0 <strtol+0xa0>
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	0f b6 00             	movzbl (%eax),%eax
  8010cf:	3c 30                	cmp    $0x30,%al
  8010d1:	75 0d                	jne    8010e0 <strtol+0xa0>
		s++, base = 8;
  8010d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010d7:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010de:	eb 0d                	jmp    8010ed <strtol+0xad>
	else if (base == 0)
  8010e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e4:	75 07                	jne    8010ed <strtol+0xad>
		base = 10;
  8010e6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	0f b6 00             	movzbl (%eax),%eax
  8010f3:	3c 2f                	cmp    $0x2f,%al
  8010f5:	7e 1b                	jle    801112 <strtol+0xd2>
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	0f b6 00             	movzbl (%eax),%eax
  8010fd:	3c 39                	cmp    $0x39,%al
  8010ff:	7f 11                	jg     801112 <strtol+0xd2>
			dig = *s - '0';
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	0f b6 00             	movzbl (%eax),%eax
  801107:	0f be c0             	movsbl %al,%eax
  80110a:	83 e8 30             	sub    $0x30,%eax
  80110d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801110:	eb 48                	jmp    80115a <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	0f b6 00             	movzbl (%eax),%eax
  801118:	3c 60                	cmp    $0x60,%al
  80111a:	7e 1b                	jle    801137 <strtol+0xf7>
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	0f b6 00             	movzbl (%eax),%eax
  801122:	3c 7a                	cmp    $0x7a,%al
  801124:	7f 11                	jg     801137 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	0f b6 00             	movzbl (%eax),%eax
  80112c:	0f be c0             	movsbl %al,%eax
  80112f:	83 e8 57             	sub    $0x57,%eax
  801132:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801135:	eb 23                	jmp    80115a <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801137:	8b 45 08             	mov    0x8(%ebp),%eax
  80113a:	0f b6 00             	movzbl (%eax),%eax
  80113d:	3c 40                	cmp    $0x40,%al
  80113f:	7e 3d                	jle    80117e <strtol+0x13e>
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	0f b6 00             	movzbl (%eax),%eax
  801147:	3c 5a                	cmp    $0x5a,%al
  801149:	7f 33                	jg     80117e <strtol+0x13e>
			dig = *s - 'A' + 10;
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	0f b6 00             	movzbl (%eax),%eax
  801151:	0f be c0             	movsbl %al,%eax
  801154:	83 e8 37             	sub    $0x37,%eax
  801157:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115d:	3b 45 10             	cmp    0x10(%ebp),%eax
  801160:	7c 02                	jl     801164 <strtol+0x124>
			break;
  801162:	eb 1a                	jmp    80117e <strtol+0x13e>
		s++, val = (val * base) + dig;
  801164:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801168:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80116b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80116f:	89 c2                	mov    %eax,%edx
  801171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801174:	01 d0                	add    %edx,%eax
  801176:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801179:	e9 6f ff ff ff       	jmp    8010ed <strtol+0xad>

	if (endptr)
  80117e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801182:	74 08                	je     80118c <strtol+0x14c>
		*endptr = (char *) s;
  801184:	8b 45 0c             	mov    0xc(%ebp),%eax
  801187:	8b 55 08             	mov    0x8(%ebp),%edx
  80118a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80118c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801190:	74 07                	je     801199 <strtol+0x159>
  801192:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801195:	f7 d8                	neg    %eax
  801197:	eb 03                	jmp    80119c <strtol+0x15c>
  801199:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    
  80119e:	66 90                	xchg   %ax,%ax

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011bc:	89 ea                	mov    %ebp,%edx
  8011be:	89 0c 24             	mov    %ecx,(%esp)
  8011c1:	75 2d                	jne    8011f0 <__udivdi3+0x50>
  8011c3:	39 e9                	cmp    %ebp,%ecx
  8011c5:	77 61                	ja     801228 <__udivdi3+0x88>
  8011c7:	85 c9                	test   %ecx,%ecx
  8011c9:	89 ce                	mov    %ecx,%esi
  8011cb:	75 0b                	jne    8011d8 <__udivdi3+0x38>
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	f7 f1                	div    %ecx
  8011d6:	89 c6                	mov    %eax,%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	89 e8                	mov    %ebp,%eax
  8011dc:	f7 f6                	div    %esi
  8011de:	89 c5                	mov    %eax,%ebp
  8011e0:	89 f8                	mov    %edi,%eax
  8011e2:	f7 f6                	div    %esi
  8011e4:	89 ea                	mov    %ebp,%edx
  8011e6:	83 c4 0c             	add    $0xc,%esp
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
  8011ed:	8d 76 00             	lea    0x0(%esi),%esi
  8011f0:	39 e8                	cmp    %ebp,%eax
  8011f2:	77 24                	ja     801218 <__udivdi3+0x78>
  8011f4:	0f bd e8             	bsr    %eax,%ebp
  8011f7:	83 f5 1f             	xor    $0x1f,%ebp
  8011fa:	75 3c                	jne    801238 <__udivdi3+0x98>
  8011fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801200:	39 34 24             	cmp    %esi,(%esp)
  801203:	0f 86 9f 00 00 00    	jbe    8012a8 <__udivdi3+0x108>
  801209:	39 d0                	cmp    %edx,%eax
  80120b:	0f 82 97 00 00 00    	jb     8012a8 <__udivdi3+0x108>
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	31 c0                	xor    %eax,%eax
  80121c:	83 c4 0c             	add    $0xc,%esp
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	89 f8                	mov    %edi,%eax
  80122a:	f7 f1                	div    %ecx
  80122c:	31 d2                	xor    %edx,%edx
  80122e:	83 c4 0c             	add    $0xc,%esp
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    
  801235:	8d 76 00             	lea    0x0(%esi),%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	8b 3c 24             	mov    (%esp),%edi
  80123d:	d3 e0                	shl    %cl,%eax
  80123f:	89 c6                	mov    %eax,%esi
  801241:	b8 20 00 00 00       	mov    $0x20,%eax
  801246:	29 e8                	sub    %ebp,%eax
  801248:	89 c1                	mov    %eax,%ecx
  80124a:	d3 ef                	shr    %cl,%edi
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801252:	8b 3c 24             	mov    (%esp),%edi
  801255:	09 74 24 08          	or     %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	d3 e7                	shl    %cl,%edi
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 3c 24             	mov    %edi,(%esp)
  801262:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801266:	d3 ee                	shr    %cl,%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	d3 e2                	shl    %cl,%edx
  80126c:	89 c1                	mov    %eax,%ecx
  80126e:	d3 ef                	shr    %cl,%edi
  801270:	09 d7                	or     %edx,%edi
  801272:	89 f2                	mov    %esi,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	f7 74 24 08          	divl   0x8(%esp)
  80127a:	89 d6                	mov    %edx,%esi
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	f7 24 24             	mull   (%esp)
  801281:	39 d6                	cmp    %edx,%esi
  801283:	89 14 24             	mov    %edx,(%esp)
  801286:	72 30                	jb     8012b8 <__udivdi3+0x118>
  801288:	8b 54 24 04          	mov    0x4(%esp),%edx
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	39 c2                	cmp    %eax,%edx
  801292:	73 05                	jae    801299 <__udivdi3+0xf9>
  801294:	3b 34 24             	cmp    (%esp),%esi
  801297:	74 1f                	je     8012b8 <__udivdi3+0x118>
  801299:	89 f8                	mov    %edi,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	e9 7a ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012af:	e9 68 ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 0c             	add    $0xc,%esp
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012e2:	89 c7                	mov    %eax,%edi
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012f0:	89 34 24             	mov    %esi,(%esp)
  8012f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	75 17                	jne    801318 <__umoddi3+0x48>
  801301:	39 fe                	cmp    %edi,%esi
  801303:	76 4b                	jbe    801350 <__umoddi3+0x80>
  801305:	89 c8                	mov    %ecx,%eax
  801307:	89 fa                	mov    %edi,%edx
  801309:	f7 f6                	div    %esi
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	31 d2                	xor    %edx,%edx
  80130f:	83 c4 14             	add    $0x14,%esp
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
  801316:	66 90                	xchg   %ax,%ax
  801318:	39 f8                	cmp    %edi,%eax
  80131a:	77 54                	ja     801370 <__umoddi3+0xa0>
  80131c:	0f bd e8             	bsr    %eax,%ebp
  80131f:	83 f5 1f             	xor    $0x1f,%ebp
  801322:	75 5c                	jne    801380 <__umoddi3+0xb0>
  801324:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801328:	39 3c 24             	cmp    %edi,(%esp)
  80132b:	0f 87 e7 00 00 00    	ja     801418 <__umoddi3+0x148>
  801331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801335:	29 f1                	sub    %esi,%ecx
  801337:	19 c7                	sbb    %eax,%edi
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801341:	8b 44 24 08          	mov    0x8(%esp),%eax
  801345:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801349:	83 c4 14             	add    $0x14,%esp
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    
  801350:	85 f6                	test   %esi,%esi
  801352:	89 f5                	mov    %esi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f6                	div    %esi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	8b 44 24 04          	mov    0x4(%esp),%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	f7 f5                	div    %ebp
  801369:	89 c8                	mov    %ecx,%eax
  80136b:	f7 f5                	div    %ebp
  80136d:	eb 9c                	jmp    80130b <__umoddi3+0x3b>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 fa                	mov    %edi,%edx
  801374:	83 c4 14             	add    $0x14,%esp
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
  80137b:	90                   	nop
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 04 24             	mov    (%esp),%eax
  801383:	be 20 00 00 00       	mov    $0x20,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ee                	sub    %ebp,%esi
  80138c:	d3 e2                	shl    %cl,%edx
  80138e:	89 f1                	mov    %esi,%ecx
  801390:	d3 e8                	shr    %cl,%eax
  801392:	89 e9                	mov    %ebp,%ecx
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	8b 04 24             	mov    (%esp),%eax
  80139b:	09 54 24 04          	or     %edx,0x4(%esp)
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e0                	shl    %cl,%eax
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ad:	d3 ea                	shr    %cl,%edx
  8013af:	89 e9                	mov    %ebp,%ecx
  8013b1:	d3 e7                	shl    %cl,%edi
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	d3 e8                	shr    %cl,%eax
  8013b7:	89 e9                	mov    %ebp,%ecx
  8013b9:	09 f8                	or     %edi,%eax
  8013bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013bf:	f7 74 24 04          	divl   0x4(%esp)
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c9:	89 d7                	mov    %edx,%edi
  8013cb:	f7 64 24 08          	mull   0x8(%esp)
  8013cf:	39 d7                	cmp    %edx,%edi
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 2c                	jb     801404 <__umoddi3+0x134>
  8013d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013dc:	72 22                	jb     801400 <__umoddi3+0x130>
  8013de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013e2:	29 c8                	sub    %ecx,%eax
  8013e4:	19 d7                	sbb    %edx,%edi
  8013e6:	89 e9                	mov    %ebp,%ecx
  8013e8:	89 fa                	mov    %edi,%edx
  8013ea:	d3 e8                	shr    %cl,%eax
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	89 e9                	mov    %ebp,%ecx
  8013f2:	d3 ef                	shr    %cl,%edi
  8013f4:	09 d0                	or     %edx,%eax
  8013f6:	89 fa                	mov    %edi,%edx
  8013f8:	83 c4 14             	add    $0x14,%esp
  8013fb:	5e                   	pop    %esi
  8013fc:	5f                   	pop    %edi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
  8013ff:	90                   	nop
  801400:	39 d7                	cmp    %edx,%edi
  801402:	75 da                	jne    8013de <__umoddi3+0x10e>
  801404:	8b 14 24             	mov    (%esp),%edx
  801407:	89 c1                	mov    %eax,%ecx
  801409:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80140d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801411:	eb cb                	jmp    8013de <__umoddi3+0x10e>
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80141c:	0f 82 0f ff ff ff    	jb     801331 <__umoddi3+0x61>
  801422:	e9 1a ff ff ff       	jmp    801341 <__umoddi3+0x71>
