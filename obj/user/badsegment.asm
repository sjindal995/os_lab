
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800044:	e8 72 01 00 00       	call   8001bb <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	c1 e0 02             	shl    $0x2,%eax
  800051:	89 c2                	mov    %eax,%edx
  800053:	c1 e2 05             	shl    $0x5,%edx
  800056:	29 c2                	sub    %eax,%edx
  800058:	89 d0                	mov    %edx,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800064:	8b 45 0c             	mov    0xc(%ebp),%eax
  800067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006b:	8b 45 08             	mov    0x8(%ebp),%eax
  80006e:	89 04 24             	mov    %eax,(%esp)
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 02 00 00 00       	call   80007d <exit>
}
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800083:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008a:	e8 e9 00 00 00       	call   800178 <sys_env_destroy>
}
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009a:	8b 45 08             	mov    0x8(%ebp),%eax
  80009d:	8b 55 10             	mov    0x10(%ebp),%edx
  8000a0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000a3:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000a6:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000a9:	8b 75 20             	mov    0x20(%ebp),%esi
  8000ac:	cd 30                	int    $0x30
  8000ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000b5:	74 30                	je     8000e7 <syscall+0x56>
  8000b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000bb:	7e 2a                	jle    8000e7 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cb:	c7 44 24 08 6a 14 80 	movl   $0x80146a,0x8(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000da:	00 
  8000db:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  8000e2:	e8 b3 03 00 00       	call   80049a <_panic>

	return ret;
  8000e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000ea:	83 c4 3c             	add    $0x3c,%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5f                   	pop    %edi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800102:	00 
  800103:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80010a:	00 
  80010b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800112:	00 
  800113:	8b 55 0c             	mov    0xc(%ebp),%edx
  800116:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80011a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012d:	e8 5f ff ff ff       	call   800091 <syscall>
}
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <sys_cgetc>:

int
sys_cgetc(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80013a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800141:	00 
  800142:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800149:	00 
  80014a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800151:	00 
  800152:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800159:	00 
  80015a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800161:	00 
  800162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800169:	00 
  80016a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800171:	e8 1b ff ff ff       	call   800091 <syscall>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800188:	00 
  800189:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800190:	00 
  800191:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800198:	00 
  800199:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a0:	00 
  8001a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001ac:	00 
  8001ad:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001b4:	e8 d8 fe ff ff       	call   800091 <syscall>
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001c1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8001f8:	e8 94 fe ff ff       	call   800091 <syscall>
}
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <sys_yield>:

void
sys_yield(void)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800205:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80020c:	00 
  80020d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800214:	00 
  800215:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80021c:	00 
  80021d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800224:	00 
  800225:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80023c:	e8 50 fe ff ff       	call   800091 <syscall>
}
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800249:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800259:	00 
  80025a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800261:	00 
  800262:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800266:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80027d:	e8 0f fe ff ff       	call   800091 <syscall>
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80028c:	8b 75 18             	mov    0x18(%ebp),%esi
  80028f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800292:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800295:	8b 55 0c             	mov    0xc(%ebp),%edx
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	89 74 24 18          	mov    %esi,0x18(%esp)
  80029f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002a3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002be:	e8 ce fd ff ff       	call   800091 <syscall>
}
  8002c3:	83 c4 20             	add    $0x20,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002dd:	00 
  8002de:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002ed:	00 
  8002ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002fd:	00 
  8002fe:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800305:	e8 87 fd ff ff       	call   800091 <syscall>
}
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800312:	8b 55 0c             	mov    0xc(%ebp),%edx
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80031f:	00 
  800320:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800327:	00 
  800328:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80032f:	00 
  800330:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80033f:	00 
  800340:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800347:	e8 45 fd ff ff       	call   800091 <syscall>
}
  80034c:	c9                   	leave  
  80034d:	c3                   	ret    

0080034e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800354:	8b 55 0c             	mov    0xc(%ebp),%edx
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800361:	00 
  800362:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800369:	00 
  80036a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800371:	00 
  800372:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800376:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800389:	e8 03 fd ff ff       	call   800091 <syscall>
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800396:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800399:	8b 55 10             	mov    0x10(%ebp),%edx
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003a6:	00 
  8003a7:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003c1:	00 
  8003c2:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003c9:	e8 c3 fc ff ff       	call   800091 <syscall>
}
  8003ce:	c9                   	leave  
  8003cf:	c3                   	ret    

008003d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003e0:	00 
  8003e1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003e8:	00 
  8003e9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003f0:	00 
  8003f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f8:	00 
  8003f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800404:	00 
  800405:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80040c:	e8 80 fc ff ff       	call   800091 <syscall>
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <sys_exec>:

void sys_exec(char* buf){
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800423:	00 
  800424:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80042b:	00 
  80042c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800433:	00 
  800434:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043b:	00 
  80043c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800440:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800447:	00 
  800448:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80044f:	e8 3d fc ff ff       	call   800091 <syscall>
}
  800454:	c9                   	leave  
  800455:	c3                   	ret    

00800456 <sys_wait>:

void sys_wait(){
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
  800459:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80045c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800463:	00 
  800464:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80046b:	00 
  80046c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800473:	00 
  800474:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80047b:	00 
  80047c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800483:	00 
  800484:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80048b:	00 
  80048c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  800493:	e8 f9 fb ff ff       	call   800091 <syscall>
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	53                   	push   %ebx
  80049e:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a4:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004a7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004ad:	e8 09 fd ff ff       	call   8001bb <sys_getenvid>
  8004b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c8:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8004cf:	e8 e1 00 00 00       	call   8005b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004db:	8b 45 10             	mov    0x10(%ebp),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	e8 6b 00 00 00       	call   800551 <vcprintf>
	cprintf("\n");
  8004e6:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8004ed:	e8 c3 00 00 00       	call   8005b5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004f2:	cc                   	int3   
  8004f3:	eb fd                	jmp    8004f2 <_panic+0x58>

008004f5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	8d 48 01             	lea    0x1(%eax),%ecx
  800503:	8b 55 0c             	mov    0xc(%ebp),%edx
  800506:	89 0a                	mov    %ecx,(%edx)
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 d1                	mov    %edx,%ecx
  80050d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800510:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
  800517:	8b 00                	mov    (%eax),%eax
  800519:	3d ff 00 00 00       	cmp    $0xff,%eax
  80051e:	75 20                	jne    800540 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
  800523:	8b 00                	mov    (%eax),%eax
  800525:	8b 55 0c             	mov    0xc(%ebp),%edx
  800528:	83 c2 08             	add    $0x8,%edx
  80052b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052f:	89 14 24             	mov    %edx,(%esp)
  800532:	e8 bb fb ff ff       	call   8000f2 <sys_cputs>
		b->idx = 0;
  800537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800540:	8b 45 0c             	mov    0xc(%ebp),%eax
  800543:	8b 40 04             	mov    0x4(%eax),%eax
  800546:	8d 50 01             	lea    0x1(%eax),%edx
  800549:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80055a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800561:	00 00 00 
	b.cnt = 0;
  800564:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80056b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80056e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800571:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800575:	8b 45 08             	mov    0x8(%ebp),%eax
  800578:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800582:	89 44 24 04          	mov    %eax,0x4(%esp)
  800586:	c7 04 24 f5 04 80 00 	movl   $0x8004f5,(%esp)
  80058d:	e8 bd 01 00 00       	call   80074f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800592:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005a2:	83 c0 08             	add    $0x8,%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	e8 45 fb ff ff       	call   8000f2 <sys_cputs>

	return b.cnt;
  8005ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005be:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	e8 7e ff ff ff       	call   800551 <vcprintf>
  8005d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005d9:	c9                   	leave  
  8005da:	c3                   	ret    

008005db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	53                   	push   %ebx
  8005df:	83 ec 34             	sub    $0x34,%esp
  8005e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ee:	8b 45 18             	mov    0x18(%ebp),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005f9:	77 72                	ja     80066d <printnum+0x92>
  8005fb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005fe:	72 05                	jb     800605 <printnum+0x2a>
  800600:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800603:	77 68                	ja     80066d <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800605:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800608:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80060b:	8b 45 18             	mov    0x18(%ebp),%eax
  80060e:	ba 00 00 00 00       	mov    $0x0,%edx
  800613:	89 44 24 08          	mov    %eax,0x8(%esp)
  800617:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	89 54 24 04          	mov    %edx,0x4(%esp)
  800628:	e8 93 0b 00 00       	call   8011c0 <__udivdi3>
  80062d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800630:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800634:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800638:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80063b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80063f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800643:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800647:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064e:	8b 45 08             	mov    0x8(%ebp),%eax
  800651:	89 04 24             	mov    %eax,(%esp)
  800654:	e8 82 ff ff ff       	call   8005db <printnum>
  800659:	eb 1c                	jmp    800677 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80065b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800662:	8b 45 20             	mov    0x20(%ebp),%eax
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80066d:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800671:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800675:	7f e4                	jg     80065b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800677:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80067a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800682:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800685:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800689:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	89 54 24 04          	mov    %edx,0x4(%esp)
  800694:	e8 57 0c 00 00       	call   8012f0 <__umoddi3>
  800699:	05 88 15 80 00       	add    $0x801588,%eax
  80069e:	0f b6 00             	movzbl (%eax),%eax
  8006a1:	0f be c0             	movsbl %al,%eax
  8006a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	ff d0                	call   *%eax
}
  8006b3:	83 c4 34             	add    $0x34,%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    

008006b9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006bc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006c0:	7e 14                	jle    8006d6 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	8d 48 08             	lea    0x8(%eax),%ecx
  8006ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cd:	89 0a                	mov    %ecx,(%edx)
  8006cf:	8b 50 04             	mov    0x4(%eax),%edx
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	eb 30                	jmp    800706 <getuint+0x4d>
	else if (lflag)
  8006d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006da:	74 16                	je     8006f2 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	8d 48 04             	lea    0x4(%eax),%ecx
  8006e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e7:	89 0a                	mov    %ecx,(%edx)
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f0:	eb 14                	jmp    800706 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8006fd:	89 0a                	mov    %ecx,(%edx)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80070b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80070f:	7e 14                	jle    800725 <getint+0x1d>
		return va_arg(*ap, long long);
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 00                	mov    (%eax),%eax
  800716:	8d 48 08             	lea    0x8(%eax),%ecx
  800719:	8b 55 08             	mov    0x8(%ebp),%edx
  80071c:	89 0a                	mov    %ecx,(%edx)
  80071e:	8b 50 04             	mov    0x4(%eax),%edx
  800721:	8b 00                	mov    (%eax),%eax
  800723:	eb 28                	jmp    80074d <getint+0x45>
	else if (lflag)
  800725:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800729:	74 12                	je     80073d <getint+0x35>
		return va_arg(*ap, long);
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 00                	mov    (%eax),%eax
  800730:	8d 48 04             	lea    0x4(%eax),%ecx
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
  800736:	89 0a                	mov    %ecx,(%edx)
  800738:	8b 00                	mov    (%eax),%eax
  80073a:	99                   	cltd   
  80073b:	eb 10                	jmp    80074d <getint+0x45>
	else
		return va_arg(*ap, int);
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 00                	mov    (%eax),%eax
  800742:	8d 48 04             	lea    0x4(%eax),%ecx
  800745:	8b 55 08             	mov    0x8(%ebp),%edx
  800748:	89 0a                	mov    %ecx,(%edx)
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	99                   	cltd   
}
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	56                   	push   %esi
  800753:	53                   	push   %ebx
  800754:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800757:	eb 18                	jmp    800771 <vprintfmt+0x22>
			if (ch == '\0')
  800759:	85 db                	test   %ebx,%ebx
  80075b:	75 05                	jne    800762 <vprintfmt+0x13>
				return;
  80075d:	e9 cc 03 00 00       	jmp    800b2e <vprintfmt+0x3df>
			putch(ch, putdat);
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
  800765:	89 44 24 04          	mov    %eax,0x4(%esp)
  800769:	89 1c 24             	mov    %ebx,(%esp)
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800771:	8b 45 10             	mov    0x10(%ebp),%eax
  800774:	8d 50 01             	lea    0x1(%eax),%edx
  800777:	89 55 10             	mov    %edx,0x10(%ebp)
  80077a:	0f b6 00             	movzbl (%eax),%eax
  80077d:	0f b6 d8             	movzbl %al,%ebx
  800780:	83 fb 25             	cmp    $0x25,%ebx
  800783:	75 d4                	jne    800759 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800785:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800789:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800790:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800797:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80079e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a8:	8d 50 01             	lea    0x1(%eax),%edx
  8007ab:	89 55 10             	mov    %edx,0x10(%ebp)
  8007ae:	0f b6 00             	movzbl (%eax),%eax
  8007b1:	0f b6 d8             	movzbl %al,%ebx
  8007b4:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007b7:	83 f8 55             	cmp    $0x55,%eax
  8007ba:	0f 87 3d 03 00 00    	ja     800afd <vprintfmt+0x3ae>
  8007c0:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  8007c7:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007c9:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007cd:	eb d6                	jmp    8007a5 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007cf:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007d3:	eb d0                	jmp    8007a5 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007df:	89 d0                	mov    %edx,%eax
  8007e1:	c1 e0 02             	shl    $0x2,%eax
  8007e4:	01 d0                	add    %edx,%eax
  8007e6:	01 c0                	add    %eax,%eax
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	83 e8 30             	sub    $0x30,%eax
  8007ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f3:	0f b6 00             	movzbl (%eax),%eax
  8007f6:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007f9:	83 fb 2f             	cmp    $0x2f,%ebx
  8007fc:	7e 0b                	jle    800809 <vprintfmt+0xba>
  8007fe:	83 fb 39             	cmp    $0x39,%ebx
  800801:	7f 06                	jg     800809 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800803:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800807:	eb d3                	jmp    8007dc <vprintfmt+0x8d>
			goto process_precision;
  800809:	eb 33                	jmp    80083e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)
  800814:	8b 00                	mov    (%eax),%eax
  800816:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800819:	eb 23                	jmp    80083e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80081b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081f:	79 0c                	jns    80082d <vprintfmt+0xde>
				width = 0;
  800821:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800828:	e9 78 ff ff ff       	jmp    8007a5 <vprintfmt+0x56>
  80082d:	e9 73 ff ff ff       	jmp    8007a5 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800832:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800839:	e9 67 ff ff ff       	jmp    8007a5 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80083e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800842:	79 12                	jns    800856 <vprintfmt+0x107>
				width = precision, precision = -1;
  800844:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800847:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80084a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800851:	e9 4f ff ff ff       	jmp    8007a5 <vprintfmt+0x56>
  800856:	e9 4a ff ff ff       	jmp    8007a5 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80085b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80085f:	e9 41 ff ff ff       	jmp    8007a5 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8d 50 04             	lea    0x4(%eax),%edx
  80086a:	89 55 14             	mov    %edx,0x14(%ebp)
  80086d:	8b 00                	mov    (%eax),%eax
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	89 54 24 04          	mov    %edx,0x4(%esp)
  800876:	89 04 24             	mov    %eax,(%esp)
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	ff d0                	call   *%eax
			break;
  80087e:	e9 a5 02 00 00       	jmp    800b28 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8d 50 04             	lea    0x4(%eax),%edx
  800889:	89 55 14             	mov    %edx,0x14(%ebp)
  80088c:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80088e:	85 db                	test   %ebx,%ebx
  800890:	79 02                	jns    800894 <vprintfmt+0x145>
				err = -err;
  800892:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800894:	83 fb 09             	cmp    $0x9,%ebx
  800897:	7f 0b                	jg     8008a4 <vprintfmt+0x155>
  800899:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  8008a0:	85 f6                	test   %esi,%esi
  8008a2:	75 23                	jne    8008c7 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008a8:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  8008af:	00 
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	e8 73 02 00 00       	call   800b35 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008c2:	e9 61 02 00 00       	jmp    800b28 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008c7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008cb:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008d2:	00 
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	89 04 24             	mov    %eax,(%esp)
  8008e0:	e8 50 02 00 00       	call   800b35 <printfmt>
			break;
  8008e5:	e9 3e 02 00 00       	jmp    800b28 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8d 50 04             	lea    0x4(%eax),%edx
  8008f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f3:	8b 30                	mov    (%eax),%esi
  8008f5:	85 f6                	test   %esi,%esi
  8008f7:	75 05                	jne    8008fe <vprintfmt+0x1af>
				p = "(null)";
  8008f9:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8008fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800902:	7e 37                	jle    80093b <vprintfmt+0x1ec>
  800904:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800908:	74 31                	je     80093b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80090a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80090d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800911:	89 34 24             	mov    %esi,(%esp)
  800914:	e8 39 03 00 00       	call   800c52 <strnlen>
  800919:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80091c:	eb 17                	jmp    800935 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80091e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 54 24 04          	mov    %edx,0x4(%esp)
  800929:	89 04 24             	mov    %eax,(%esp)
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800931:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800935:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800939:	7f e3                	jg     80091e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093b:	eb 38                	jmp    800975 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80093d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800941:	74 1f                	je     800962 <vprintfmt+0x213>
  800943:	83 fb 1f             	cmp    $0x1f,%ebx
  800946:	7e 05                	jle    80094d <vprintfmt+0x1fe>
  800948:	83 fb 7e             	cmp    $0x7e,%ebx
  80094b:	7e 15                	jle    800962 <vprintfmt+0x213>
					putch('?', putdat);
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800950:	89 44 24 04          	mov    %eax,0x4(%esp)
  800954:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	ff d0                	call   *%eax
  800960:	eb 0f                	jmp    800971 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	89 1c 24             	mov    %ebx,(%esp)
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800971:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800975:	89 f0                	mov    %esi,%eax
  800977:	8d 70 01             	lea    0x1(%eax),%esi
  80097a:	0f b6 00             	movzbl (%eax),%eax
  80097d:	0f be d8             	movsbl %al,%ebx
  800980:	85 db                	test   %ebx,%ebx
  800982:	74 10                	je     800994 <vprintfmt+0x245>
  800984:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800988:	78 b3                	js     80093d <vprintfmt+0x1ee>
  80098a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80098e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800992:	79 a9                	jns    80093d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800994:	eb 17                	jmp    8009ad <vprintfmt+0x25e>
				putch(' ', putdat);
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b1:	7f e3                	jg     800996 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009b3:	e9 70 01 00 00       	jmp    800b28 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 3e fd ff ff       	call   800708 <getint>
  8009ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d6:	85 d2                	test   %edx,%edx
  8009d8:	79 26                	jns    800a00 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	ff d0                	call   *%eax
				num = -(long long) num;
  8009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009f3:	f7 d8                	neg    %eax
  8009f5:	83 d2 00             	adc    $0x0,%edx
  8009f8:	f7 da                	neg    %edx
  8009fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009fd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a00:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a07:	e9 a8 00 00 00       	jmp    800ab4 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a13:	8d 45 14             	lea    0x14(%ebp),%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 9b fc ff ff       	call   8006b9 <getuint>
  800a1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a21:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a24:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a2b:	e9 84 00 00 00       	jmp    800ab4 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a30:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a37:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3a:	89 04 24             	mov    %eax,(%esp)
  800a3d:	e8 77 fc ff ff       	call   8006b9 <getuint>
  800a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a45:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a48:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a4f:	eb 63                	jmp    800ab4 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	ff d0                	call   *%eax
			putch('x', putdat);
  800a64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6b:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a77:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7a:	8d 50 04             	lea    0x4(%eax),%edx
  800a7d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a80:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a8c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a93:	eb 1f                	jmp    800ab4 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a95:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a9f:	89 04 24             	mov    %eax,(%esp)
  800aa2:	e8 12 fc ff ff       	call   8006b9 <getuint>
  800aa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aaa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aad:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ab8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abb:	89 54 24 18          	mov    %edx,0x18(%esp)
  800abf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ac2:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ac6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 f1 fa ff ff       	call   8005db <printnum>
			break;
  800aea:	eb 3c                	jmp    800b28 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af3:	89 1c 24             	mov    %ebx,(%esp)
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	ff d0                	call   *%eax
			break;
  800afb:	eb 2b                	jmp    800b28 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b04:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b10:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b14:	eb 04                	jmp    800b1a <vprintfmt+0x3cb>
  800b16:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1d:	83 e8 01             	sub    $0x1,%eax
  800b20:	0f b6 00             	movzbl (%eax),%eax
  800b23:	3c 25                	cmp    $0x25,%al
  800b25:	75 ef                	jne    800b16 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b27:	90                   	nop
		}
	}
  800b28:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b29:	e9 43 fc ff ff       	jmp    800771 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b2e:	83 c4 40             	add    $0x40,%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b48:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	89 04 24             	mov    %eax,(%esp)
  800b5c:	e8 ee fb ff ff       	call   80074f <vprintfmt>
	va_end(ap);
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	8b 40 08             	mov    0x8(%eax),%eax
  800b6c:	8d 50 01             	lea    0x1(%eax),%edx
  800b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b72:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b78:	8b 10                	mov    (%eax),%edx
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	8b 40 04             	mov    0x4(%eax),%eax
  800b80:	39 c2                	cmp    %eax,%edx
  800b82:	73 12                	jae    800b96 <sprintputch+0x33>
		*b->buf++ = ch;
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	8b 00                	mov    (%eax),%eax
  800b89:	8d 48 01             	lea    0x1(%eax),%ecx
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	89 0a                	mov    %ecx,(%edx)
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	88 10                	mov    %dl,(%eax)
}
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	01 d0                	add    %edx,%eax
  800baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bb2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bb9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bbd:	74 06                	je     800bc5 <vsnprintf+0x2d>
  800bbf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc3:	7f 07                	jg     800bcc <vsnprintf+0x34>
		return -E_INVAL;
  800bc5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bca:	eb 2a                	jmp    800bf6 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bda:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be1:	c7 04 24 63 0b 80 00 	movl   $0x800b63,(%esp)
  800be8:	e8 62 fb ff ff       	call   80074f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bfe:	8d 45 14             	lea    0x14(%ebp),%eax
  800c01:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	89 04 24             	mov    %eax,(%esp)
  800c1f:	e8 74 ff ff ff       	call   800b98 <vsnprintf>
  800c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c32:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c39:	eb 08                	jmp    800c43 <strlen+0x17>
		n++;
  800c3b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	0f b6 00             	movzbl (%eax),%eax
  800c49:	84 c0                	test   %al,%al
  800c4b:	75 ee                	jne    800c3b <strlen+0xf>
		n++;
	return n;
  800c4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c58:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c5f:	eb 0c                	jmp    800c6d <strnlen+0x1b>
		n++;
  800c61:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c65:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c69:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c6d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c71:	74 0a                	je     800c7d <strnlen+0x2b>
  800c73:	8b 45 08             	mov    0x8(%ebp),%eax
  800c76:	0f b6 00             	movzbl (%eax),%eax
  800c79:	84 c0                	test   %al,%al
  800c7b:	75 e4                	jne    800c61 <strnlen+0xf>
		n++;
	return n;
  800c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c8e:	90                   	nop
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	8d 50 01             	lea    0x1(%eax),%edx
  800c95:	89 55 08             	mov    %edx,0x8(%ebp)
  800c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c9e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ca1:	0f b6 12             	movzbl (%edx),%edx
  800ca4:	88 10                	mov    %dl,(%eax)
  800ca6:	0f b6 00             	movzbl (%eax),%eax
  800ca9:	84 c0                	test   %al,%al
  800cab:	75 e2                	jne    800c8f <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	89 04 24             	mov    %eax,(%esp)
  800cbe:	e8 69 ff ff ff       	call   800c2c <strlen>
  800cc3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cc6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	01 c2                	add    %eax,%edx
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	89 14 24             	mov    %edx,(%esp)
  800cd8:	e8 a5 ff ff ff       	call   800c82 <strcpy>
	return dst;
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cf5:	eb 23                	jmp    800d1a <strncpy+0x38>
		*dst++ = *src;
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	8d 50 01             	lea    0x1(%eax),%edx
  800cfd:	89 55 08             	mov    %edx,0x8(%ebp)
  800d00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d03:	0f b6 12             	movzbl (%edx),%edx
  800d06:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0b:	0f b6 00             	movzbl (%eax),%eax
  800d0e:	84 c0                	test   %al,%al
  800d10:	74 04                	je     800d16 <strncpy+0x34>
			src++;
  800d12:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d1d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d20:	72 d5                	jb     800cf7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d37:	74 33                	je     800d6c <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d39:	eb 17                	jmp    800d52 <strlcpy+0x2b>
			*dst++ = *src++;
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	8d 50 01             	lea    0x1(%eax),%edx
  800d41:	89 55 08             	mov    %edx,0x8(%ebp)
  800d44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d47:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d4a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d4d:	0f b6 12             	movzbl (%edx),%edx
  800d50:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d52:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5a:	74 0a                	je     800d66 <strlcpy+0x3f>
  800d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5f:	0f b6 00             	movzbl (%eax),%eax
  800d62:	84 c0                	test   %al,%al
  800d64:	75 d5                	jne    800d3b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d72:	29 c2                	sub    %eax,%edx
  800d74:	89 d0                	mov    %edx,%eax
}
  800d76:	c9                   	leave  
  800d77:	c3                   	ret    

00800d78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d7b:	eb 08                	jmp    800d85 <strcmp+0xd>
		p++, q++;
  800d7d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d81:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d85:	8b 45 08             	mov    0x8(%ebp),%eax
  800d88:	0f b6 00             	movzbl (%eax),%eax
  800d8b:	84 c0                	test   %al,%al
  800d8d:	74 10                	je     800d9f <strcmp+0x27>
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	0f b6 10             	movzbl (%eax),%edx
  800d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d98:	0f b6 00             	movzbl (%eax),%eax
  800d9b:	38 c2                	cmp    %al,%dl
  800d9d:	74 de                	je     800d7d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	0f b6 00             	movzbl (%eax),%eax
  800da5:	0f b6 d0             	movzbl %al,%edx
  800da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	0f b6 c0             	movzbl %al,%eax
  800db1:	29 c2                	sub    %eax,%edx
  800db3:	89 d0                	mov    %edx,%eax
}
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dba:	eb 0c                	jmp    800dc8 <strncmp+0x11>
		n--, p++, q++;
  800dbc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dc0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dcc:	74 1a                	je     800de8 <strncmp+0x31>
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	0f b6 00             	movzbl (%eax),%eax
  800dd4:	84 c0                	test   %al,%al
  800dd6:	74 10                	je     800de8 <strncmp+0x31>
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	0f b6 10             	movzbl (%eax),%edx
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	0f b6 00             	movzbl (%eax),%eax
  800de4:	38 c2                	cmp    %al,%dl
  800de6:	74 d4                	je     800dbc <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800de8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dec:	75 07                	jne    800df5 <strncmp+0x3e>
		return 0;
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
  800df3:	eb 16                	jmp    800e0b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	0f b6 00             	movzbl (%eax),%eax
  800dfb:	0f b6 d0             	movzbl %al,%edx
  800dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e01:	0f b6 00             	movzbl (%eax),%eax
  800e04:	0f b6 c0             	movzbl %al,%eax
  800e07:	29 c2                	sub    %eax,%edx
  800e09:	89 d0                	mov    %edx,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e16:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e19:	eb 14                	jmp    800e2f <strchr+0x22>
		if (*s == c)
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	0f b6 00             	movzbl (%eax),%eax
  800e21:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e24:	75 05                	jne    800e2b <strchr+0x1e>
			return (char *) s;
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	eb 13                	jmp    800e3e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	0f b6 00             	movzbl (%eax),%eax
  800e35:	84 c0                	test   %al,%al
  800e37:	75 e2                	jne    800e1b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	83 ec 04             	sub    $0x4,%esp
  800e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e49:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e4c:	eb 11                	jmp    800e5f <strfind+0x1f>
		if (*s == c)
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	0f b6 00             	movzbl (%eax),%eax
  800e54:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e57:	75 02                	jne    800e5b <strfind+0x1b>
			break;
  800e59:	eb 0e                	jmp    800e69 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e5b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	0f b6 00             	movzbl (%eax),%eax
  800e65:	84 c0                	test   %al,%al
  800e67:	75 e5                	jne    800e4e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e76:	75 05                	jne    800e7d <memset+0xf>
		return v;
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	eb 5c                	jmp    800ed9 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	83 e0 03             	and    $0x3,%eax
  800e83:	85 c0                	test   %eax,%eax
  800e85:	75 41                	jne    800ec8 <memset+0x5a>
  800e87:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8a:	83 e0 03             	and    $0x3,%eax
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	75 37                	jne    800ec8 <memset+0x5a>
		c &= 0xFF;
  800e91:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9b:	c1 e0 18             	shl    $0x18,%eax
  800e9e:	89 c2                	mov    %eax,%edx
  800ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea3:	c1 e0 10             	shl    $0x10,%eax
  800ea6:	09 c2                	or     %eax,%edx
  800ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eab:	c1 e0 08             	shl    $0x8,%eax
  800eae:	09 d0                	or     %edx,%eax
  800eb0:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb6:	c1 e8 02             	shr    $0x2,%eax
  800eb9:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec1:	89 d7                	mov    %edx,%edi
  800ec3:	fc                   	cld    
  800ec4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec6:	eb 0e                	jmp    800ed6 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ece:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed1:	89 d7                	mov    %edx,%edi
  800ed3:	fc                   	cld    
  800ed4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ee5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee8:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800eee:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ef7:	73 6d                	jae    800f66 <memmove+0x8a>
  800ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  800efc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eff:	01 d0                	add    %edx,%eax
  800f01:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f04:	76 60                	jbe    800f66 <memmove+0x8a>
		s += n;
  800f06:	8b 45 10             	mov    0x10(%ebp),%eax
  800f09:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f15:	83 e0 03             	and    $0x3,%eax
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	75 2f                	jne    800f4b <memmove+0x6f>
  800f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1f:	83 e0 03             	and    $0x3,%eax
  800f22:	85 c0                	test   %eax,%eax
  800f24:	75 25                	jne    800f4b <memmove+0x6f>
  800f26:	8b 45 10             	mov    0x10(%ebp),%eax
  800f29:	83 e0 03             	and    $0x3,%eax
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	75 1b                	jne    800f4b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f33:	83 e8 04             	sub    $0x4,%eax
  800f36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f39:	83 ea 04             	sub    $0x4,%edx
  800f3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f42:	89 c7                	mov    %eax,%edi
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	fd                   	std    
  800f47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f49:	eb 18                	jmp    800f63 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f4e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f54:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f57:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5a:	89 d7                	mov    %edx,%edi
  800f5c:	89 de                	mov    %ebx,%esi
  800f5e:	89 c1                	mov    %eax,%ecx
  800f60:	fd                   	std    
  800f61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f63:	fc                   	cld    
  800f64:	eb 45                	jmp    800fab <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f69:	83 e0 03             	and    $0x3,%eax
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	75 2b                	jne    800f9b <memmove+0xbf>
  800f70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f73:	83 e0 03             	and    $0x3,%eax
  800f76:	85 c0                	test   %eax,%eax
  800f78:	75 21                	jne    800f9b <memmove+0xbf>
  800f7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7d:	83 e0 03             	and    $0x3,%eax
  800f80:	85 c0                	test   %eax,%eax
  800f82:	75 17                	jne    800f9b <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f84:	8b 45 10             	mov    0x10(%ebp),%eax
  800f87:	c1 e8 02             	shr    $0x2,%eax
  800f8a:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f8f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	89 d6                	mov    %edx,%esi
  800f96:	fc                   	cld    
  800f97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f99:	eb 10                	jmp    800fab <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f9e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fa4:	89 c7                	mov    %eax,%edi
  800fa6:	89 d6                	mov    %edx,%esi
  800fa8:	fc                   	cld    
  800fa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	5b                   	pop    %ebx
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fca:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	e8 07 ff ff ff       	call   800edc <memmove>
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fe9:	eb 30                	jmp    80101b <memcmp+0x44>
		if (*s1 != *s2)
  800feb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fee:	0f b6 10             	movzbl (%eax),%edx
  800ff1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ff4:	0f b6 00             	movzbl (%eax),%eax
  800ff7:	38 c2                	cmp    %al,%dl
  800ff9:	74 18                	je     801013 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ffb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ffe:	0f b6 00             	movzbl (%eax),%eax
  801001:	0f b6 d0             	movzbl %al,%edx
  801004:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801007:	0f b6 00             	movzbl (%eax),%eax
  80100a:	0f b6 c0             	movzbl %al,%eax
  80100d:	29 c2                	sub    %eax,%edx
  80100f:	89 d0                	mov    %edx,%eax
  801011:	eb 1a                	jmp    80102d <memcmp+0x56>
		s1++, s2++;
  801013:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801017:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80101b:	8b 45 10             	mov    0x10(%ebp),%eax
  80101e:	8d 50 ff             	lea    -0x1(%eax),%edx
  801021:	89 55 10             	mov    %edx,0x10(%ebp)
  801024:	85 c0                	test   %eax,%eax
  801026:	75 c3                	jne    800feb <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801035:	8b 45 10             	mov    0x10(%ebp),%eax
  801038:	8b 55 08             	mov    0x8(%ebp),%edx
  80103b:	01 d0                	add    %edx,%eax
  80103d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801040:	eb 13                	jmp    801055 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	0f b6 10             	movzbl (%eax),%edx
  801048:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104b:	38 c2                	cmp    %al,%dl
  80104d:	75 02                	jne    801051 <memfind+0x22>
			break;
  80104f:	eb 0c                	jmp    80105d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801051:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801055:	8b 45 08             	mov    0x8(%ebp),%eax
  801058:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80105b:	72 e5                	jb     801042 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80105d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801068:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80106f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801076:	eb 04                	jmp    80107c <strtol+0x1a>
		s++;
  801078:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107c:	8b 45 08             	mov    0x8(%ebp),%eax
  80107f:	0f b6 00             	movzbl (%eax),%eax
  801082:	3c 20                	cmp    $0x20,%al
  801084:	74 f2                	je     801078 <strtol+0x16>
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	0f b6 00             	movzbl (%eax),%eax
  80108c:	3c 09                	cmp    $0x9,%al
  80108e:	74 e8                	je     801078 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	0f b6 00             	movzbl (%eax),%eax
  801096:	3c 2b                	cmp    $0x2b,%al
  801098:	75 06                	jne    8010a0 <strtol+0x3e>
		s++;
  80109a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80109e:	eb 15                	jmp    8010b5 <strtol+0x53>
	else if (*s == '-')
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a3:	0f b6 00             	movzbl (%eax),%eax
  8010a6:	3c 2d                	cmp    $0x2d,%al
  8010a8:	75 0b                	jne    8010b5 <strtol+0x53>
		s++, neg = 1;
  8010aa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ae:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b9:	74 06                	je     8010c1 <strtol+0x5f>
  8010bb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010bf:	75 24                	jne    8010e5 <strtol+0x83>
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	0f b6 00             	movzbl (%eax),%eax
  8010c7:	3c 30                	cmp    $0x30,%al
  8010c9:	75 1a                	jne    8010e5 <strtol+0x83>
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	83 c0 01             	add    $0x1,%eax
  8010d1:	0f b6 00             	movzbl (%eax),%eax
  8010d4:	3c 78                	cmp    $0x78,%al
  8010d6:	75 0d                	jne    8010e5 <strtol+0x83>
		s += 2, base = 16;
  8010d8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010dc:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010e3:	eb 2a                	jmp    80110f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e9:	75 17                	jne    801102 <strtol+0xa0>
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	0f b6 00             	movzbl (%eax),%eax
  8010f1:	3c 30                	cmp    $0x30,%al
  8010f3:	75 0d                	jne    801102 <strtol+0xa0>
		s++, base = 8;
  8010f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801100:	eb 0d                	jmp    80110f <strtol+0xad>
	else if (base == 0)
  801102:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801106:	75 07                	jne    80110f <strtol+0xad>
		base = 10;
  801108:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	0f b6 00             	movzbl (%eax),%eax
  801115:	3c 2f                	cmp    $0x2f,%al
  801117:	7e 1b                	jle    801134 <strtol+0xd2>
  801119:	8b 45 08             	mov    0x8(%ebp),%eax
  80111c:	0f b6 00             	movzbl (%eax),%eax
  80111f:	3c 39                	cmp    $0x39,%al
  801121:	7f 11                	jg     801134 <strtol+0xd2>
			dig = *s - '0';
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
  801126:	0f b6 00             	movzbl (%eax),%eax
  801129:	0f be c0             	movsbl %al,%eax
  80112c:	83 e8 30             	sub    $0x30,%eax
  80112f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801132:	eb 48                	jmp    80117c <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	0f b6 00             	movzbl (%eax),%eax
  80113a:	3c 60                	cmp    $0x60,%al
  80113c:	7e 1b                	jle    801159 <strtol+0xf7>
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	0f b6 00             	movzbl (%eax),%eax
  801144:	3c 7a                	cmp    $0x7a,%al
  801146:	7f 11                	jg     801159 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801148:	8b 45 08             	mov    0x8(%ebp),%eax
  80114b:	0f b6 00             	movzbl (%eax),%eax
  80114e:	0f be c0             	movsbl %al,%eax
  801151:	83 e8 57             	sub    $0x57,%eax
  801154:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801157:	eb 23                	jmp    80117c <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	0f b6 00             	movzbl (%eax),%eax
  80115f:	3c 40                	cmp    $0x40,%al
  801161:	7e 3d                	jle    8011a0 <strtol+0x13e>
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	0f b6 00             	movzbl (%eax),%eax
  801169:	3c 5a                	cmp    $0x5a,%al
  80116b:	7f 33                	jg     8011a0 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80116d:	8b 45 08             	mov    0x8(%ebp),%eax
  801170:	0f b6 00             	movzbl (%eax),%eax
  801173:	0f be c0             	movsbl %al,%eax
  801176:	83 e8 37             	sub    $0x37,%eax
  801179:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80117c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117f:	3b 45 10             	cmp    0x10(%ebp),%eax
  801182:	7c 02                	jl     801186 <strtol+0x124>
			break;
  801184:	eb 1a                	jmp    8011a0 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801186:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80118a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80118d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801191:	89 c2                	mov    %eax,%edx
  801193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801196:	01 d0                	add    %edx,%eax
  801198:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80119b:	e9 6f ff ff ff       	jmp    80110f <strtol+0xad>

	if (endptr)
  8011a0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011a4:	74 08                	je     8011ae <strtol+0x14c>
		*endptr = (char *) s;
  8011a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ac:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011ae:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011b2:	74 07                	je     8011bb <strtol+0x159>
  8011b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011b7:	f7 d8                	neg    %eax
  8011b9:	eb 03                	jmp    8011be <strtol+0x15c>
  8011bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

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
