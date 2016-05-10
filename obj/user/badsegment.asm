
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
  8000cb:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000da:	00 
  8000db:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  8000e2:	e8 f7 03 00 00       	call   8004de <_panic>

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
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <sys_guest>:

void sys_guest(){
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004a0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004a7:	00 
  8004a8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004af:	00 
  8004b0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004b7:	00 
  8004b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004bf:	00 
  8004c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004c7:	00 
  8004c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004cf:	00 
  8004d0:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004d7:	e8 b5 fb ff ff       	call   800091 <syscall>
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8004e8:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004eb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004f1:	e8 c5 fc ff ff       	call   8001bb <sys_getenvid>
  8004f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800500:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800504:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800513:	e8 e1 00 00 00       	call   8005f9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	8b 45 10             	mov    0x10(%ebp),%eax
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	e8 6b 00 00 00       	call   800595 <vcprintf>
	cprintf("\n");
  80052a:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  800531:	e8 c3 00 00 00       	call   8005f9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800536:	cc                   	int3   
  800537:	eb fd                	jmp    800536 <_panic+0x58>

00800539 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800542:	8b 00                	mov    (%eax),%eax
  800544:	8d 48 01             	lea    0x1(%eax),%ecx
  800547:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054a:	89 0a                	mov    %ecx,(%edx)
  80054c:	8b 55 08             	mov    0x8(%ebp),%edx
  80054f:	89 d1                	mov    %edx,%ecx
  800551:	8b 55 0c             	mov    0xc(%ebp),%edx
  800554:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800562:	75 20                	jne    800584 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80056c:	83 c2 08             	add    $0x8,%edx
  80056f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800573:	89 14 24             	mov    %edx,(%esp)
  800576:	e8 77 fb ff ff       	call   8000f2 <sys_cputs>
		b->idx = 0;
  80057b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800584:	8b 45 0c             	mov    0xc(%ebp),%eax
  800587:	8b 40 04             	mov    0x4(%eax),%eax
  80058a:	8d 50 01             	lea    0x1(%eax),%edx
  80058d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800590:	89 50 04             	mov    %edx,0x4(%eax)
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80059e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005a5:	00 00 00 
	b.cnt = 0;
  8005a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ca:	c7 04 24 39 05 80 00 	movl   $0x800539,(%esp)
  8005d1:	e8 bd 01 00 00       	call   800793 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005d6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005e6:	83 c0 08             	add    $0x8,%eax
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	e8 01 fb ff ff       	call   8000f2 <sys_cputs>

	return b.cnt;
  8005f1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005f7:	c9                   	leave  
  8005f8:	c3                   	ret    

008005f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005ff:	8d 45 0c             	lea    0xc(%ebp),%eax
  800602:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800608:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060c:	8b 45 08             	mov    0x8(%ebp),%eax
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	e8 7e ff ff ff       	call   800595 <vcprintf>
  800617:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80061a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    

0080061f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	53                   	push   %ebx
  800623:	83 ec 34             	sub    $0x34,%esp
  800626:	8b 45 10             	mov    0x10(%ebp),%eax
  800629:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800632:	8b 45 18             	mov    0x18(%ebp),%eax
  800635:	ba 00 00 00 00       	mov    $0x0,%edx
  80063a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80063d:	77 72                	ja     8006b1 <printnum+0x92>
  80063f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800642:	72 05                	jb     800649 <printnum+0x2a>
  800644:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800647:	77 68                	ja     8006b1 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800649:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80064c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80064f:	8b 45 18             	mov    0x18(%ebp),%eax
  800652:	ba 00 00 00 00       	mov    $0x0,%edx
  800657:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800662:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066c:	e8 9f 0b 00 00       	call   801210 <__udivdi3>
  800671:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800674:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800678:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80067c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80067f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800683:	89 44 24 08          	mov    %eax,0x8(%esp)
  800687:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800692:	8b 45 08             	mov    0x8(%ebp),%eax
  800695:	89 04 24             	mov    %eax,(%esp)
  800698:	e8 82 ff ff ff       	call   80061f <printnum>
  80069d:	eb 1c                	jmp    8006bb <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80069f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	8b 45 20             	mov    0x20(%ebp),%eax
  8006a9:	89 04 24             	mov    %eax,(%esp)
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006b1:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006b5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006b9:	7f e4                	jg     80069f <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006bb:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d8:	e8 63 0c 00 00       	call   801340 <__umoddi3>
  8006dd:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8006e2:	0f b6 00             	movzbl (%eax),%eax
  8006e5:	0f be c0             	movsbl %al,%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	ff d0                	call   *%eax
}
  8006f7:	83 c4 34             	add    $0x34,%esp
  8006fa:	5b                   	pop    %ebx
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800700:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800704:	7e 14                	jle    80071a <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	8d 48 08             	lea    0x8(%eax),%ecx
  80070e:	8b 55 08             	mov    0x8(%ebp),%edx
  800711:	89 0a                	mov    %ecx,(%edx)
  800713:	8b 50 04             	mov    0x4(%eax),%edx
  800716:	8b 00                	mov    (%eax),%eax
  800718:	eb 30                	jmp    80074a <getuint+0x4d>
	else if (lflag)
  80071a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80071e:	74 16                	je     800736 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 00                	mov    (%eax),%eax
  800725:	8d 48 04             	lea    0x4(%eax),%ecx
  800728:	8b 55 08             	mov    0x8(%ebp),%edx
  80072b:	89 0a                	mov    %ecx,(%edx)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
  800734:	eb 14                	jmp    80074a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800736:	8b 45 08             	mov    0x8(%ebp),%eax
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	8d 48 04             	lea    0x4(%eax),%ecx
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
  800741:	89 0a                	mov    %ecx,(%edx)
  800743:	8b 00                	mov    (%eax),%eax
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80074f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800753:	7e 14                	jle    800769 <getint+0x1d>
		return va_arg(*ap, long long);
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	8d 48 08             	lea    0x8(%eax),%ecx
  80075d:	8b 55 08             	mov    0x8(%ebp),%edx
  800760:	89 0a                	mov    %ecx,(%edx)
  800762:	8b 50 04             	mov    0x4(%eax),%edx
  800765:	8b 00                	mov    (%eax),%eax
  800767:	eb 28                	jmp    800791 <getint+0x45>
	else if (lflag)
  800769:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80076d:	74 12                	je     800781 <getint+0x35>
		return va_arg(*ap, long);
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 00                	mov    (%eax),%eax
  800774:	8d 48 04             	lea    0x4(%eax),%ecx
  800777:	8b 55 08             	mov    0x8(%ebp),%edx
  80077a:	89 0a                	mov    %ecx,(%edx)
  80077c:	8b 00                	mov    (%eax),%eax
  80077e:	99                   	cltd   
  80077f:	eb 10                	jmp    800791 <getint+0x45>
	else
		return va_arg(*ap, int);
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 00                	mov    (%eax),%eax
  800786:	8d 48 04             	lea    0x4(%eax),%ecx
  800789:	8b 55 08             	mov    0x8(%ebp),%edx
  80078c:	89 0a                	mov    %ecx,(%edx)
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	99                   	cltd   
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079b:	eb 18                	jmp    8007b5 <vprintfmt+0x22>
			if (ch == '\0')
  80079d:	85 db                	test   %ebx,%ebx
  80079f:	75 05                	jne    8007a6 <vprintfmt+0x13>
				return;
  8007a1:	e9 cc 03 00 00       	jmp    800b72 <vprintfmt+0x3df>
			putch(ch, putdat);
  8007a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ad:	89 1c 24             	mov    %ebx,(%esp)
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b8:	8d 50 01             	lea    0x1(%eax),%edx
  8007bb:	89 55 10             	mov    %edx,0x10(%ebp)
  8007be:	0f b6 00             	movzbl (%eax),%eax
  8007c1:	0f b6 d8             	movzbl %al,%ebx
  8007c4:	83 fb 25             	cmp    $0x25,%ebx
  8007c7:	75 d4                	jne    80079d <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007c9:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007cd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007d4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007db:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ec:	8d 50 01             	lea    0x1(%eax),%edx
  8007ef:	89 55 10             	mov    %edx,0x10(%ebp)
  8007f2:	0f b6 00             	movzbl (%eax),%eax
  8007f5:	0f b6 d8             	movzbl %al,%ebx
  8007f8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007fb:	83 f8 55             	cmp    $0x55,%eax
  8007fe:	0f 87 3d 03 00 00    	ja     800b41 <vprintfmt+0x3ae>
  800804:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  80080b:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80080d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800811:	eb d6                	jmp    8007e9 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800813:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800817:	eb d0                	jmp    8007e9 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800819:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800820:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800823:	89 d0                	mov    %edx,%eax
  800825:	c1 e0 02             	shl    $0x2,%eax
  800828:	01 d0                	add    %edx,%eax
  80082a:	01 c0                	add    %eax,%eax
  80082c:	01 d8                	add    %ebx,%eax
  80082e:	83 e8 30             	sub    $0x30,%eax
  800831:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800834:	8b 45 10             	mov    0x10(%ebp),%eax
  800837:	0f b6 00             	movzbl (%eax),%eax
  80083a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80083d:	83 fb 2f             	cmp    $0x2f,%ebx
  800840:	7e 0b                	jle    80084d <vprintfmt+0xba>
  800842:	83 fb 39             	cmp    $0x39,%ebx
  800845:	7f 06                	jg     80084d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800847:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80084b:	eb d3                	jmp    800820 <vprintfmt+0x8d>
			goto process_precision;
  80084d:	eb 33                	jmp    800882 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8d 50 04             	lea    0x4(%eax),%edx
  800855:	89 55 14             	mov    %edx,0x14(%ebp)
  800858:	8b 00                	mov    (%eax),%eax
  80085a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80085d:	eb 23                	jmp    800882 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80085f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800863:	79 0c                	jns    800871 <vprintfmt+0xde>
				width = 0;
  800865:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80086c:	e9 78 ff ff ff       	jmp    8007e9 <vprintfmt+0x56>
  800871:	e9 73 ff ff ff       	jmp    8007e9 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800876:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80087d:	e9 67 ff ff ff       	jmp    8007e9 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800882:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800886:	79 12                	jns    80089a <vprintfmt+0x107>
				width = precision, precision = -1;
  800888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80088e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800895:	e9 4f ff ff ff       	jmp    8007e9 <vprintfmt+0x56>
  80089a:	e9 4a ff ff ff       	jmp    8007e9 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80089f:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008a3:	e9 41 ff ff ff       	jmp    8007e9 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8d 50 04             	lea    0x4(%eax),%edx
  8008ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b1:	8b 00                	mov    (%eax),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	ff d0                	call   *%eax
			break;
  8008c2:	e9 a5 02 00 00       	jmp    800b6c <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 04             	lea    0x4(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008d2:	85 db                	test   %ebx,%ebx
  8008d4:	79 02                	jns    8008d8 <vprintfmt+0x145>
				err = -err;
  8008d6:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008d8:	83 fb 09             	cmp    $0x9,%ebx
  8008db:	7f 0b                	jg     8008e8 <vprintfmt+0x155>
  8008dd:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8008e4:	85 f6                	test   %esi,%esi
  8008e6:	75 23                	jne    80090b <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008ec:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8008f3:	00 
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	89 04 24             	mov    %eax,(%esp)
  800901:	e8 73 02 00 00       	call   800b79 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800906:	e9 61 02 00 00       	jmp    800b6c <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80090b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80090f:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  800916:	00 
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	89 04 24             	mov    %eax,(%esp)
  800924:	e8 50 02 00 00       	call   800b79 <printfmt>
			break;
  800929:	e9 3e 02 00 00       	jmp    800b6c <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 30                	mov    (%eax),%esi
  800939:	85 f6                	test   %esi,%esi
  80093b:	75 05                	jne    800942 <vprintfmt+0x1af>
				p = "(null)";
  80093d:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  800942:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800946:	7e 37                	jle    80097f <vprintfmt+0x1ec>
  800948:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80094c:	74 31                	je     80097f <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80094e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800951:	89 44 24 04          	mov    %eax,0x4(%esp)
  800955:	89 34 24             	mov    %esi,(%esp)
  800958:	e8 39 03 00 00       	call   800c96 <strnlen>
  80095d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800960:	eb 17                	jmp    800979 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800962:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800966:	8b 55 0c             	mov    0xc(%ebp),%edx
  800969:	89 54 24 04          	mov    %edx,0x4(%esp)
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800975:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800979:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097d:	7f e3                	jg     800962 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80097f:	eb 38                	jmp    8009b9 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800981:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800985:	74 1f                	je     8009a6 <vprintfmt+0x213>
  800987:	83 fb 1f             	cmp    $0x1f,%ebx
  80098a:	7e 05                	jle    800991 <vprintfmt+0x1fe>
  80098c:	83 fb 7e             	cmp    $0x7e,%ebx
  80098f:	7e 15                	jle    8009a6 <vprintfmt+0x213>
					putch('?', putdat);
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	ff d0                	call   *%eax
  8009a4:	eb 0f                	jmp    8009b5 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ad:	89 1c 24             	mov    %ebx,(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b9:	89 f0                	mov    %esi,%eax
  8009bb:	8d 70 01             	lea    0x1(%eax),%esi
  8009be:	0f b6 00             	movzbl (%eax),%eax
  8009c1:	0f be d8             	movsbl %al,%ebx
  8009c4:	85 db                	test   %ebx,%ebx
  8009c6:	74 10                	je     8009d8 <vprintfmt+0x245>
  8009c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009cc:	78 b3                	js     800981 <vprintfmt+0x1ee>
  8009ce:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009d6:	79 a9                	jns    800981 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d8:	eb 17                	jmp    8009f1 <vprintfmt+0x25e>
				putch(' ', putdat);
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ed:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009f5:	7f e3                	jg     8009da <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009f7:	e9 70 01 00 00       	jmp    800b6c <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a03:	8d 45 14             	lea    0x14(%ebp),%eax
  800a06:	89 04 24             	mov    %eax,(%esp)
  800a09:	e8 3e fd ff ff       	call   80074c <getint>
  800a0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a11:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a1a:	85 d2                	test   %edx,%edx
  800a1c:	79 26                	jns    800a44 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	ff d0                	call   *%eax
				num = -(long long) num;
  800a31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a37:	f7 d8                	neg    %eax
  800a39:	83 d2 00             	adc    $0x0,%edx
  800a3c:	f7 da                	neg    %edx
  800a3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a41:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a44:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a4b:	e9 a8 00 00 00       	jmp    800af8 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a50:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a57:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5a:	89 04 24             	mov    %eax,(%esp)
  800a5d:	e8 9b fc ff ff       	call   8006fd <getuint>
  800a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a65:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a68:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a6f:	e9 84 00 00 00       	jmp    800af8 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a7e:	89 04 24             	mov    %eax,(%esp)
  800a81:	e8 77 fc ff ff       	call   8006fd <getuint>
  800a86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a89:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a8c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a93:	eb 63                	jmp    800af8 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	ff d0                	call   *%eax
			putch('x', putdat);
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800abb:	8b 45 14             	mov    0x14(%ebp),%eax
  800abe:	8d 50 04             	lea    0x4(%eax),%edx
  800ac1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac4:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ac9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ad0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ad7:	eb 1f                	jmp    800af8 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ad9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 12 fc ff ff       	call   8006fd <getuint>
  800aeb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aee:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800af1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800afc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aff:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b06:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b18:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	89 04 24             	mov    %eax,(%esp)
  800b29:	e8 f1 fa ff ff       	call   80061f <printnum>
			break;
  800b2e:	eb 3c                	jmp    800b6c <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b37:	89 1c 24             	mov    %ebx,(%esp)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	ff d0                	call   *%eax
			break;
  800b3f:	eb 2b                	jmp    800b6c <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b48:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b52:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b58:	eb 04                	jmp    800b5e <vprintfmt+0x3cb>
  800b5a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b61:	83 e8 01             	sub    $0x1,%eax
  800b64:	0f b6 00             	movzbl (%eax),%eax
  800b67:	3c 25                	cmp    $0x25,%al
  800b69:	75 ef                	jne    800b5a <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b6b:	90                   	nop
		}
	}
  800b6c:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b6d:	e9 43 fc ff ff       	jmp    8007b5 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b72:	83 c4 40             	add    $0x40,%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	89 04 24             	mov    %eax,(%esp)
  800ba0:	e8 ee fb ff ff       	call   800793 <vprintfmt>
	va_end(ap);
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800baa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bad:	8b 40 08             	mov    0x8(%eax),%eax
  800bb0:	8d 50 01             	lea    0x1(%eax),%edx
  800bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb6:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbc:	8b 10                	mov    (%eax),%edx
  800bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc1:	8b 40 04             	mov    0x4(%eax),%eax
  800bc4:	39 c2                	cmp    %eax,%edx
  800bc6:	73 12                	jae    800bda <sprintputch+0x33>
		*b->buf++ = ch;
  800bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcb:	8b 00                	mov    (%eax),%eax
  800bcd:	8d 48 01             	lea    0x1(%eax),%ecx
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd3:	89 0a                	mov    %ecx,(%edx)
  800bd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd8:	88 10                	mov    %dl,(%eax)
}
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800beb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	01 d0                	add    %edx,%eax
  800bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bf6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bfd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c01:	74 06                	je     800c09 <vsnprintf+0x2d>
  800c03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c07:	7f 07                	jg     800c10 <vsnprintf+0x34>
		return -E_INVAL;
  800c09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c0e:	eb 2a                	jmp    800c3a <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c10:	8b 45 14             	mov    0x14(%ebp),%eax
  800c13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c17:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c25:	c7 04 24 a7 0b 80 00 	movl   $0x800ba7,(%esp)
  800c2c:	e8 62 fb ff ff       	call   800793 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c34:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c42:	8d 45 14             	lea    0x14(%ebp),%eax
  800c45:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c52:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c60:	89 04 24             	mov    %eax,(%esp)
  800c63:	e8 74 ff ff ff       	call   800bdc <vsnprintf>
  800c68:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c76:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c7d:	eb 08                	jmp    800c87 <strlen+0x17>
		n++;
  800c7f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c83:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8a:	0f b6 00             	movzbl (%eax),%eax
  800c8d:	84 c0                	test   %al,%al
  800c8f:	75 ee                	jne    800c7f <strlen+0xf>
		n++;
	return n;
  800c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c9c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ca3:	eb 0c                	jmp    800cb1 <strnlen+0x1b>
		n++;
  800ca5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cad:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cb1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb5:	74 0a                	je     800cc1 <strnlen+0x2b>
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	0f b6 00             	movzbl (%eax),%eax
  800cbd:	84 c0                	test   %al,%al
  800cbf:	75 e4                	jne    800ca5 <strnlen+0xf>
		n++;
	return n;
  800cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800cd2:	90                   	nop
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	8d 50 01             	lea    0x1(%eax),%edx
  800cd9:	89 55 08             	mov    %edx,0x8(%ebp)
  800cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdf:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ce2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ce5:	0f b6 12             	movzbl (%edx),%edx
  800ce8:	88 10                	mov    %dl,(%eax)
  800cea:	0f b6 00             	movzbl (%eax),%eax
  800ced:	84 c0                	test   %al,%al
  800cef:	75 e2                	jne    800cd3 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	89 04 24             	mov    %eax,(%esp)
  800d02:	e8 69 ff ff ff       	call   800c70 <strlen>
  800d07:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d0a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	01 c2                	add    %eax,%edx
  800d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d19:	89 14 24             	mov    %edx,(%esp)
  800d1c:	e8 a5 ff ff ff       	call   800cc6 <strcpy>
	return dst;
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    

00800d26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d32:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d39:	eb 23                	jmp    800d5e <strncpy+0x38>
		*dst++ = *src;
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	8d 50 01             	lea    0x1(%eax),%edx
  800d41:	89 55 08             	mov    %edx,0x8(%ebp)
  800d44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d47:	0f b6 12             	movzbl (%edx),%edx
  800d4a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4f:	0f b6 00             	movzbl (%eax),%eax
  800d52:	84 c0                	test   %al,%al
  800d54:	74 04                	je     800d5a <strncpy+0x34>
			src++;
  800d56:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d5a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d61:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d64:	72 d5                	jb     800d3b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d66:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d7b:	74 33                	je     800db0 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d7d:	eb 17                	jmp    800d96 <strlcpy+0x2b>
			*dst++ = *src++;
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8d 50 01             	lea    0x1(%eax),%edx
  800d85:	89 55 08             	mov    %edx,0x8(%ebp)
  800d88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d8e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d91:	0f b6 12             	movzbl (%edx),%edx
  800d94:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d96:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d9a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9e:	74 0a                	je     800daa <strlcpy+0x3f>
  800da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da3:	0f b6 00             	movzbl (%eax),%eax
  800da6:	84 c0                	test   %al,%al
  800da8:	75 d5                	jne    800d7f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800db6:	29 c2                	sub    %eax,%edx
  800db8:	89 d0                	mov    %edx,%eax
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dbf:	eb 08                	jmp    800dc9 <strcmp+0xd>
		p++, q++;
  800dc1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	0f b6 00             	movzbl (%eax),%eax
  800dcf:	84 c0                	test   %al,%al
  800dd1:	74 10                	je     800de3 <strcmp+0x27>
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	0f b6 10             	movzbl (%eax),%edx
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddc:	0f b6 00             	movzbl (%eax),%eax
  800ddf:	38 c2                	cmp    %al,%dl
  800de1:	74 de                	je     800dc1 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	0f b6 d0             	movzbl %al,%edx
  800dec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800def:	0f b6 00             	movzbl (%eax),%eax
  800df2:	0f b6 c0             	movzbl %al,%eax
  800df5:	29 c2                	sub    %eax,%edx
  800df7:	89 d0                	mov    %edx,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dfe:	eb 0c                	jmp    800e0c <strncmp+0x11>
		n--, p++, q++;
  800e00:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e04:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e08:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e10:	74 1a                	je     800e2c <strncmp+0x31>
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	0f b6 00             	movzbl (%eax),%eax
  800e18:	84 c0                	test   %al,%al
  800e1a:	74 10                	je     800e2c <strncmp+0x31>
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1f:	0f b6 10             	movzbl (%eax),%edx
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	0f b6 00             	movzbl (%eax),%eax
  800e28:	38 c2                	cmp    %al,%dl
  800e2a:	74 d4                	je     800e00 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e30:	75 07                	jne    800e39 <strncmp+0x3e>
		return 0;
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
  800e37:	eb 16                	jmp    800e4f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	0f b6 00             	movzbl (%eax),%eax
  800e3f:	0f b6 d0             	movzbl %al,%edx
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	0f b6 00             	movzbl (%eax),%eax
  800e48:	0f b6 c0             	movzbl %al,%eax
  800e4b:	29 c2                	sub    %eax,%edx
  800e4d:	89 d0                	mov    %edx,%eax
}
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e5d:	eb 14                	jmp    800e73 <strchr+0x22>
		if (*s == c)
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	0f b6 00             	movzbl (%eax),%eax
  800e65:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e68:	75 05                	jne    800e6f <strchr+0x1e>
			return (char *) s;
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	eb 13                	jmp    800e82 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e6f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	0f b6 00             	movzbl (%eax),%eax
  800e79:	84 c0                	test   %al,%al
  800e7b:	75 e2                	jne    800e5f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e90:	eb 11                	jmp    800ea3 <strfind+0x1f>
		if (*s == c)
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	0f b6 00             	movzbl (%eax),%eax
  800e98:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e9b:	75 02                	jne    800e9f <strfind+0x1b>
			break;
  800e9d:	eb 0e                	jmp    800ead <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e9f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	0f b6 00             	movzbl (%eax),%eax
  800ea9:	84 c0                	test   %al,%al
  800eab:	75 e5                	jne    800e92 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	57                   	push   %edi
	char *p;

	if (n == 0)
  800eb6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eba:	75 05                	jne    800ec1 <memset+0xf>
		return v;
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	eb 5c                	jmp    800f1d <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	83 e0 03             	and    $0x3,%eax
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	75 41                	jne    800f0c <memset+0x5a>
  800ecb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ece:	83 e0 03             	and    $0x3,%eax
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	75 37                	jne    800f0c <memset+0x5a>
		c &= 0xFF;
  800ed5:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edf:	c1 e0 18             	shl    $0x18,%eax
  800ee2:	89 c2                	mov    %eax,%edx
  800ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee7:	c1 e0 10             	shl    $0x10,%eax
  800eea:	09 c2                	or     %eax,%edx
  800eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eef:	c1 e0 08             	shl    $0x8,%eax
  800ef2:	09 d0                	or     %edx,%eax
  800ef4:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ef7:	8b 45 10             	mov    0x10(%ebp),%eax
  800efa:	c1 e8 02             	shr    $0x2,%eax
  800efd:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eff:	8b 55 08             	mov    0x8(%ebp),%edx
  800f02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f05:	89 d7                	mov    %edx,%edi
  800f07:	fc                   	cld    
  800f08:	f3 ab                	rep stos %eax,%es:(%edi)
  800f0a:	eb 0e                	jmp    800f1a <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f12:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f15:	89 d7                	mov    %edx,%edi
  800f17:	fc                   	cld    
  800f18:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f1a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f38:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f3b:	73 6d                	jae    800faa <memmove+0x8a>
  800f3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f40:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f43:	01 d0                	add    %edx,%eax
  800f45:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f48:	76 60                	jbe    800faa <memmove+0x8a>
		s += n;
  800f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f50:	8b 45 10             	mov    0x10(%ebp),%eax
  800f53:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f59:	83 e0 03             	and    $0x3,%eax
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	75 2f                	jne    800f8f <memmove+0x6f>
  800f60:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f63:	83 e0 03             	and    $0x3,%eax
  800f66:	85 c0                	test   %eax,%eax
  800f68:	75 25                	jne    800f8f <memmove+0x6f>
  800f6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6d:	83 e0 03             	and    $0x3,%eax
  800f70:	85 c0                	test   %eax,%eax
  800f72:	75 1b                	jne    800f8f <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f77:	83 e8 04             	sub    $0x4,%eax
  800f7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f7d:	83 ea 04             	sub    $0x4,%edx
  800f80:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f83:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f86:	89 c7                	mov    %eax,%edi
  800f88:	89 d6                	mov    %edx,%esi
  800f8a:	fd                   	std    
  800f8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f8d:	eb 18                	jmp    800fa7 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f92:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f98:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9e:	89 d7                	mov    %edx,%edi
  800fa0:	89 de                	mov    %ebx,%esi
  800fa2:	89 c1                	mov    %eax,%ecx
  800fa4:	fd                   	std    
  800fa5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa7:	fc                   	cld    
  800fa8:	eb 45                	jmp    800fef <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800faa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fad:	83 e0 03             	and    $0x3,%eax
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	75 2b                	jne    800fdf <memmove+0xbf>
  800fb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fb7:	83 e0 03             	and    $0x3,%eax
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	75 21                	jne    800fdf <memmove+0xbf>
  800fbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc1:	83 e0 03             	and    $0x3,%eax
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	75 17                	jne    800fdf <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcb:	c1 e8 02             	shr    $0x2,%eax
  800fce:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fd6:	89 c7                	mov    %eax,%edi
  800fd8:	89 d6                	mov    %edx,%esi
  800fda:	fc                   	cld    
  800fdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fdd:	eb 10                	jmp    800fef <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fdf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fe2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe8:	89 c7                	mov    %eax,%edi
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	fc                   	cld    
  800fed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801000:	8b 45 10             	mov    0x10(%ebp),%eax
  801003:	89 44 24 08          	mov    %eax,0x8(%esp)
  801007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	89 04 24             	mov    %eax,(%esp)
  801014:	e8 07 ff ff ff       	call   800f20 <memmove>
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801027:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  80102d:	eb 30                	jmp    80105f <memcmp+0x44>
		if (*s1 != *s2)
  80102f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801032:	0f b6 10             	movzbl (%eax),%edx
  801035:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801038:	0f b6 00             	movzbl (%eax),%eax
  80103b:	38 c2                	cmp    %al,%dl
  80103d:	74 18                	je     801057 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80103f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801042:	0f b6 00             	movzbl (%eax),%eax
  801045:	0f b6 d0             	movzbl %al,%edx
  801048:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80104b:	0f b6 00             	movzbl (%eax),%eax
  80104e:	0f b6 c0             	movzbl %al,%eax
  801051:	29 c2                	sub    %eax,%edx
  801053:	89 d0                	mov    %edx,%eax
  801055:	eb 1a                	jmp    801071 <memcmp+0x56>
		s1++, s2++;
  801057:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80105b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80105f:	8b 45 10             	mov    0x10(%ebp),%eax
  801062:	8d 50 ff             	lea    -0x1(%eax),%edx
  801065:	89 55 10             	mov    %edx,0x10(%ebp)
  801068:	85 c0                	test   %eax,%eax
  80106a:	75 c3                	jne    80102f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80106c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801079:	8b 45 10             	mov    0x10(%ebp),%eax
  80107c:	8b 55 08             	mov    0x8(%ebp),%edx
  80107f:	01 d0                	add    %edx,%eax
  801081:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801084:	eb 13                	jmp    801099 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	0f b6 10             	movzbl (%eax),%edx
  80108c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108f:	38 c2                	cmp    %al,%dl
  801091:	75 02                	jne    801095 <memfind+0x22>
			break;
  801093:	eb 0c                	jmp    8010a1 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801095:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
  80109c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80109f:	72 e5                	jb     801086 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010a1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010b3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ba:	eb 04                	jmp    8010c0 <strtol+0x1a>
		s++;
  8010bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c3:	0f b6 00             	movzbl (%eax),%eax
  8010c6:	3c 20                	cmp    $0x20,%al
  8010c8:	74 f2                	je     8010bc <strtol+0x16>
  8010ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cd:	0f b6 00             	movzbl (%eax),%eax
  8010d0:	3c 09                	cmp    $0x9,%al
  8010d2:	74 e8                	je     8010bc <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	0f b6 00             	movzbl (%eax),%eax
  8010da:	3c 2b                	cmp    $0x2b,%al
  8010dc:	75 06                	jne    8010e4 <strtol+0x3e>
		s++;
  8010de:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010e2:	eb 15                	jmp    8010f9 <strtol+0x53>
	else if (*s == '-')
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	0f b6 00             	movzbl (%eax),%eax
  8010ea:	3c 2d                	cmp    $0x2d,%al
  8010ec:	75 0b                	jne    8010f9 <strtol+0x53>
		s++, neg = 1;
  8010ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010fd:	74 06                	je     801105 <strtol+0x5f>
  8010ff:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801103:	75 24                	jne    801129 <strtol+0x83>
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	0f b6 00             	movzbl (%eax),%eax
  80110b:	3c 30                	cmp    $0x30,%al
  80110d:	75 1a                	jne    801129 <strtol+0x83>
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	83 c0 01             	add    $0x1,%eax
  801115:	0f b6 00             	movzbl (%eax),%eax
  801118:	3c 78                	cmp    $0x78,%al
  80111a:	75 0d                	jne    801129 <strtol+0x83>
		s += 2, base = 16;
  80111c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801120:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801127:	eb 2a                	jmp    801153 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801129:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80112d:	75 17                	jne    801146 <strtol+0xa0>
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	0f b6 00             	movzbl (%eax),%eax
  801135:	3c 30                	cmp    $0x30,%al
  801137:	75 0d                	jne    801146 <strtol+0xa0>
		s++, base = 8;
  801139:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80113d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801144:	eb 0d                	jmp    801153 <strtol+0xad>
	else if (base == 0)
  801146:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80114a:	75 07                	jne    801153 <strtol+0xad>
		base = 10;
  80114c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	0f b6 00             	movzbl (%eax),%eax
  801159:	3c 2f                	cmp    $0x2f,%al
  80115b:	7e 1b                	jle    801178 <strtol+0xd2>
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	0f b6 00             	movzbl (%eax),%eax
  801163:	3c 39                	cmp    $0x39,%al
  801165:	7f 11                	jg     801178 <strtol+0xd2>
			dig = *s - '0';
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
  80116a:	0f b6 00             	movzbl (%eax),%eax
  80116d:	0f be c0             	movsbl %al,%eax
  801170:	83 e8 30             	sub    $0x30,%eax
  801173:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801176:	eb 48                	jmp    8011c0 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	0f b6 00             	movzbl (%eax),%eax
  80117e:	3c 60                	cmp    $0x60,%al
  801180:	7e 1b                	jle    80119d <strtol+0xf7>
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	0f b6 00             	movzbl (%eax),%eax
  801188:	3c 7a                	cmp    $0x7a,%al
  80118a:	7f 11                	jg     80119d <strtol+0xf7>
			dig = *s - 'a' + 10;
  80118c:	8b 45 08             	mov    0x8(%ebp),%eax
  80118f:	0f b6 00             	movzbl (%eax),%eax
  801192:	0f be c0             	movsbl %al,%eax
  801195:	83 e8 57             	sub    $0x57,%eax
  801198:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80119b:	eb 23                	jmp    8011c0 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	0f b6 00             	movzbl (%eax),%eax
  8011a3:	3c 40                	cmp    $0x40,%al
  8011a5:	7e 3d                	jle    8011e4 <strtol+0x13e>
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	0f b6 00             	movzbl (%eax),%eax
  8011ad:	3c 5a                	cmp    $0x5a,%al
  8011af:	7f 33                	jg     8011e4 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	0f b6 00             	movzbl (%eax),%eax
  8011b7:	0f be c0             	movsbl %al,%eax
  8011ba:	83 e8 37             	sub    $0x37,%eax
  8011bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c3:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011c6:	7c 02                	jl     8011ca <strtol+0x124>
			break;
  8011c8:	eb 1a                	jmp    8011e4 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011ca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011d1:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011d5:	89 c2                	mov    %eax,%edx
  8011d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011da:	01 d0                	add    %edx,%eax
  8011dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011df:	e9 6f ff ff ff       	jmp    801153 <strtol+0xad>

	if (endptr)
  8011e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011e8:	74 08                	je     8011f2 <strtol+0x14c>
		*endptr = (char *) s;
  8011ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011f2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011f6:	74 07                	je     8011ff <strtol+0x159>
  8011f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011fb:	f7 d8                	neg    %eax
  8011fd:	eb 03                	jmp    801202 <strtol+0x15c>
  8011ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801202:	c9                   	leave  
  801203:	c3                   	ret    
  801204:	66 90                	xchg   %ax,%ax
  801206:	66 90                	xchg   %ax,%ax
  801208:	66 90                	xchg   %ax,%ax
  80120a:	66 90                	xchg   %ax,%ax
  80120c:	66 90                	xchg   %ax,%ax
  80120e:	66 90                	xchg   %ax,%ax

00801210 <__udivdi3>:
  801210:	55                   	push   %ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8b 44 24 28          	mov    0x28(%esp),%eax
  80121a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80121e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801222:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801226:	85 c0                	test   %eax,%eax
  801228:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80122c:	89 ea                	mov    %ebp,%edx
  80122e:	89 0c 24             	mov    %ecx,(%esp)
  801231:	75 2d                	jne    801260 <__udivdi3+0x50>
  801233:	39 e9                	cmp    %ebp,%ecx
  801235:	77 61                	ja     801298 <__udivdi3+0x88>
  801237:	85 c9                	test   %ecx,%ecx
  801239:	89 ce                	mov    %ecx,%esi
  80123b:	75 0b                	jne    801248 <__udivdi3+0x38>
  80123d:	b8 01 00 00 00       	mov    $0x1,%eax
  801242:	31 d2                	xor    %edx,%edx
  801244:	f7 f1                	div    %ecx
  801246:	89 c6                	mov    %eax,%esi
  801248:	31 d2                	xor    %edx,%edx
  80124a:	89 e8                	mov    %ebp,%eax
  80124c:	f7 f6                	div    %esi
  80124e:	89 c5                	mov    %eax,%ebp
  801250:	89 f8                	mov    %edi,%eax
  801252:	f7 f6                	div    %esi
  801254:	89 ea                	mov    %ebp,%edx
  801256:	83 c4 0c             	add    $0xc,%esp
  801259:	5e                   	pop    %esi
  80125a:	5f                   	pop    %edi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    
  80125d:	8d 76 00             	lea    0x0(%esi),%esi
  801260:	39 e8                	cmp    %ebp,%eax
  801262:	77 24                	ja     801288 <__udivdi3+0x78>
  801264:	0f bd e8             	bsr    %eax,%ebp
  801267:	83 f5 1f             	xor    $0x1f,%ebp
  80126a:	75 3c                	jne    8012a8 <__udivdi3+0x98>
  80126c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801270:	39 34 24             	cmp    %esi,(%esp)
  801273:	0f 86 9f 00 00 00    	jbe    801318 <__udivdi3+0x108>
  801279:	39 d0                	cmp    %edx,%eax
  80127b:	0f 82 97 00 00 00    	jb     801318 <__udivdi3+0x108>
  801281:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801288:	31 d2                	xor    %edx,%edx
  80128a:	31 c0                	xor    %eax,%eax
  80128c:	83 c4 0c             	add    $0xc,%esp
  80128f:	5e                   	pop    %esi
  801290:	5f                   	pop    %edi
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    
  801293:	90                   	nop
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	89 f8                	mov    %edi,%eax
  80129a:	f7 f1                	div    %ecx
  80129c:	31 d2                	xor    %edx,%edx
  80129e:	83 c4 0c             	add    $0xc,%esp
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	8b 3c 24             	mov    (%esp),%edi
  8012ad:	d3 e0                	shl    %cl,%eax
  8012af:	89 c6                	mov    %eax,%esi
  8012b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012b6:	29 e8                	sub    %ebp,%eax
  8012b8:	89 c1                	mov    %eax,%ecx
  8012ba:	d3 ef                	shr    %cl,%edi
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012c2:	8b 3c 24             	mov    (%esp),%edi
  8012c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012c9:	89 d6                	mov    %edx,%esi
  8012cb:	d3 e7                	shl    %cl,%edi
  8012cd:	89 c1                	mov    %eax,%ecx
  8012cf:	89 3c 24             	mov    %edi,(%esp)
  8012d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012d6:	d3 ee                	shr    %cl,%esi
  8012d8:	89 e9                	mov    %ebp,%ecx
  8012da:	d3 e2                	shl    %cl,%edx
  8012dc:	89 c1                	mov    %eax,%ecx
  8012de:	d3 ef                	shr    %cl,%edi
  8012e0:	09 d7                	or     %edx,%edi
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	89 f8                	mov    %edi,%eax
  8012e6:	f7 74 24 08          	divl   0x8(%esp)
  8012ea:	89 d6                	mov    %edx,%esi
  8012ec:	89 c7                	mov    %eax,%edi
  8012ee:	f7 24 24             	mull   (%esp)
  8012f1:	39 d6                	cmp    %edx,%esi
  8012f3:	89 14 24             	mov    %edx,(%esp)
  8012f6:	72 30                	jb     801328 <__udivdi3+0x118>
  8012f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012fc:	89 e9                	mov    %ebp,%ecx
  8012fe:	d3 e2                	shl    %cl,%edx
  801300:	39 c2                	cmp    %eax,%edx
  801302:	73 05                	jae    801309 <__udivdi3+0xf9>
  801304:	3b 34 24             	cmp    (%esp),%esi
  801307:	74 1f                	je     801328 <__udivdi3+0x118>
  801309:	89 f8                	mov    %edi,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	e9 7a ff ff ff       	jmp    80128c <__udivdi3+0x7c>
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	31 d2                	xor    %edx,%edx
  80131a:	b8 01 00 00 00       	mov    $0x1,%eax
  80131f:	e9 68 ff ff ff       	jmp    80128c <__udivdi3+0x7c>
  801324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801328:	8d 47 ff             	lea    -0x1(%edi),%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	83 c4 0c             	add    $0xc,%esp
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
  801334:	66 90                	xchg   %ax,%ax
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <__umoddi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	83 ec 14             	sub    $0x14,%esp
  801346:	8b 44 24 28          	mov    0x28(%esp),%eax
  80134a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80134e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801352:	89 c7                	mov    %eax,%edi
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	8b 44 24 30          	mov    0x30(%esp),%eax
  80135c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801360:	89 34 24             	mov    %esi,(%esp)
  801363:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801367:	85 c0                	test   %eax,%eax
  801369:	89 c2                	mov    %eax,%edx
  80136b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136f:	75 17                	jne    801388 <__umoddi3+0x48>
  801371:	39 fe                	cmp    %edi,%esi
  801373:	76 4b                	jbe    8013c0 <__umoddi3+0x80>
  801375:	89 c8                	mov    %ecx,%eax
  801377:	89 fa                	mov    %edi,%edx
  801379:	f7 f6                	div    %esi
  80137b:	89 d0                	mov    %edx,%eax
  80137d:	31 d2                	xor    %edx,%edx
  80137f:	83 c4 14             	add    $0x14,%esp
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    
  801386:	66 90                	xchg   %ax,%ax
  801388:	39 f8                	cmp    %edi,%eax
  80138a:	77 54                	ja     8013e0 <__umoddi3+0xa0>
  80138c:	0f bd e8             	bsr    %eax,%ebp
  80138f:	83 f5 1f             	xor    $0x1f,%ebp
  801392:	75 5c                	jne    8013f0 <__umoddi3+0xb0>
  801394:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801398:	39 3c 24             	cmp    %edi,(%esp)
  80139b:	0f 87 e7 00 00 00    	ja     801488 <__umoddi3+0x148>
  8013a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013a5:	29 f1                	sub    %esi,%ecx
  8013a7:	19 c7                	sbb    %eax,%edi
  8013a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013b9:	83 c4 14             	add    $0x14,%esp
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    
  8013c0:	85 f6                	test   %esi,%esi
  8013c2:	89 f5                	mov    %esi,%ebp
  8013c4:	75 0b                	jne    8013d1 <__umoddi3+0x91>
  8013c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	f7 f6                	div    %esi
  8013cf:	89 c5                	mov    %eax,%ebp
  8013d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013d5:	31 d2                	xor    %edx,%edx
  8013d7:	f7 f5                	div    %ebp
  8013d9:	89 c8                	mov    %ecx,%eax
  8013db:	f7 f5                	div    %ebp
  8013dd:	eb 9c                	jmp    80137b <__umoddi3+0x3b>
  8013df:	90                   	nop
  8013e0:	89 c8                	mov    %ecx,%eax
  8013e2:	89 fa                	mov    %edi,%edx
  8013e4:	83 c4 14             	add    $0x14,%esp
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
  8013eb:	90                   	nop
  8013ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	8b 04 24             	mov    (%esp),%eax
  8013f3:	be 20 00 00 00       	mov    $0x20,%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	29 ee                	sub    %ebp,%esi
  8013fc:	d3 e2                	shl    %cl,%edx
  8013fe:	89 f1                	mov    %esi,%ecx
  801400:	d3 e8                	shr    %cl,%eax
  801402:	89 e9                	mov    %ebp,%ecx
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 04 24             	mov    (%esp),%eax
  80140b:	09 54 24 04          	or     %edx,0x4(%esp)
  80140f:	89 fa                	mov    %edi,%edx
  801411:	d3 e0                	shl    %cl,%eax
  801413:	89 f1                	mov    %esi,%ecx
  801415:	89 44 24 08          	mov    %eax,0x8(%esp)
  801419:	8b 44 24 10          	mov    0x10(%esp),%eax
  80141d:	d3 ea                	shr    %cl,%edx
  80141f:	89 e9                	mov    %ebp,%ecx
  801421:	d3 e7                	shl    %cl,%edi
  801423:	89 f1                	mov    %esi,%ecx
  801425:	d3 e8                	shr    %cl,%eax
  801427:	89 e9                	mov    %ebp,%ecx
  801429:	09 f8                	or     %edi,%eax
  80142b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80142f:	f7 74 24 04          	divl   0x4(%esp)
  801433:	d3 e7                	shl    %cl,%edi
  801435:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801439:	89 d7                	mov    %edx,%edi
  80143b:	f7 64 24 08          	mull   0x8(%esp)
  80143f:	39 d7                	cmp    %edx,%edi
  801441:	89 c1                	mov    %eax,%ecx
  801443:	89 14 24             	mov    %edx,(%esp)
  801446:	72 2c                	jb     801474 <__umoddi3+0x134>
  801448:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80144c:	72 22                	jb     801470 <__umoddi3+0x130>
  80144e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801452:	29 c8                	sub    %ecx,%eax
  801454:	19 d7                	sbb    %edx,%edi
  801456:	89 e9                	mov    %ebp,%ecx
  801458:	89 fa                	mov    %edi,%edx
  80145a:	d3 e8                	shr    %cl,%eax
  80145c:	89 f1                	mov    %esi,%ecx
  80145e:	d3 e2                	shl    %cl,%edx
  801460:	89 e9                	mov    %ebp,%ecx
  801462:	d3 ef                	shr    %cl,%edi
  801464:	09 d0                	or     %edx,%eax
  801466:	89 fa                	mov    %edi,%edx
  801468:	83 c4 14             	add    $0x14,%esp
  80146b:	5e                   	pop    %esi
  80146c:	5f                   	pop    %edi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    
  80146f:	90                   	nop
  801470:	39 d7                	cmp    %edx,%edi
  801472:	75 da                	jne    80144e <__umoddi3+0x10e>
  801474:	8b 14 24             	mov    (%esp),%edx
  801477:	89 c1                	mov    %eax,%ecx
  801479:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80147d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801481:	eb cb                	jmp    80144e <__umoddi3+0x10e>
  801483:	90                   	nop
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80148c:	0f 82 0f ff ff ff    	jb     8013a1 <__umoddi3+0x61>
  801492:	e9 1a ff ff ff       	jmp    8013b1 <__umoddi3+0x71>
