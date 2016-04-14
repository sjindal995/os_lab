
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
  800044:	e8 82 01 00 00       	call   8001cb <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	c1 e0 02             	shl    $0x2,%eax
  800051:	89 c2                	mov    %eax,%edx
  800053:	c1 e2 05             	shl    $0x5,%edx
  800056:	29 c2                	sub    %eax,%edx
  800058:	89 d0                	mov    %edx,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800068:	7e 0a                	jle    800074 <libmain+0x36>
		binaryname = argv[0];
  80006a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80006d:	8b 00                	mov    (%eax),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	8b 45 0c             	mov    0xc(%ebp),%eax
  800077:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007b:	8b 45 08             	mov    0x8(%ebp),%eax
  80007e:	89 04 24             	mov    %eax,(%esp)
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 02 00 00 00       	call   80008d <exit>
}
  80008b:	c9                   	leave  
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009a:	e8 e9 00 00 00       	call   800188 <sys_env_destroy>
}
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ad:	8b 55 10             	mov    0x10(%ebp),%edx
  8000b0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000b3:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b6:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000b9:	8b 75 20             	mov    0x20(%ebp),%esi
  8000bc:	cd 30                	int    $0x30
  8000be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c5:	74 30                	je     8000f7 <syscall+0x56>
  8000c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cb:	7e 2a                	jle    8000f7 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000db:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8000e2:	00 
  8000e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8000f2:	e8 2c 03 00 00       	call   800423 <_panic>

	return ret;
  8000f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000fa:	83 c4 3c             	add    $0x3c,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800108:	8b 45 08             	mov    0x8(%ebp),%eax
  80010b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800112:	00 
  800113:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80011a:	00 
  80011b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800122:	00 
  800123:	8b 55 0c             	mov    0xc(%ebp),%edx
  800126:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80012a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800135:	00 
  800136:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013d:	e8 5f ff ff ff       	call   8000a1 <syscall>
}
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <sys_cgetc>:

int
sys_cgetc(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800151:	00 
  800152:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800159:	00 
  80015a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800161:	00 
  800162:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800169:	00 
  80016a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800181:	e8 1b ff ff ff       	call   8000a1 <syscall>
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800198:	00 
  800199:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001a0:	00 
  8001a1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b0:	00 
  8001b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c4:	e8 d8 fe ff ff       	call   8000a1 <syscall>
}
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001d1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f0:	00 
  8001f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f8:	00 
  8001f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800200:	00 
  800201:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800208:	e8 94 fe ff ff       	call   8000a1 <syscall>
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <sys_yield>:

void
sys_yield(void)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800215:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80021c:	00 
  80021d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800224:	00 
  800225:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80022c:	00 
  80022d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800234:	00 
  800235:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80023c:	00 
  80023d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800244:	00 
  800245:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80024c:	e8 50 fe ff ff       	call   8000a1 <syscall>
}
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800259:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800269:	00 
  80026a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800271:	00 
  800272:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800276:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800285:	00 
  800286:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80028d:	e8 0f fe ff ff       	call   8000a1 <syscall>
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80029c:	8b 75 18             	mov    0x18(%ebp),%esi
  80029f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002af:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002b3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002ce:	e8 ce fd ff ff       	call   8000a1 <syscall>
}
  8002d3:	83 c4 20             	add    $0x20,%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002ed:	00 
  8002ee:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f5:	00 
  8002f6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002fd:	00 
  8002fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80030d:	00 
  80030e:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800315:	e8 87 fd ff ff       	call   8000a1 <syscall>
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800322:	8b 55 0c             	mov    0xc(%ebp),%edx
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80032f:	00 
  800330:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800337:	00 
  800338:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80033f:	00 
  800340:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034f:	00 
  800350:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800357:	e8 45 fd ff ff       	call   8000a1 <syscall>
}
  80035c:	c9                   	leave  
  80035d:	c3                   	ret    

0080035e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800364:	8b 55 0c             	mov    0xc(%ebp),%edx
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800371:	00 
  800372:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800379:	00 
  80037a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800381:	00 
  800382:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800386:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800399:	e8 03 fd ff ff       	call   8000a1 <syscall>
}
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8003af:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b6:	00 
  8003b7:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003d1:	00 
  8003d2:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003d9:	e8 c3 fc ff ff       	call   8000a1 <syscall>
}
  8003de:	c9                   	leave  
  8003df:	c3                   	ret    

008003e0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003f0:	00 
  8003f1:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003f8:	00 
  8003f9:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800400:	00 
  800401:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800408:	00 
  800409:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800414:	00 
  800415:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80041c:	e8 80 fc ff ff       	call   8000a1 <syscall>
}
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	53                   	push   %ebx
  800427:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80042a:	8d 45 14             	lea    0x14(%ebp),%eax
  80042d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800430:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800436:	e8 90 fd ff ff       	call   8001cb <sys_getenvid>
  80043b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800442:	8b 55 08             	mov    0x8(%ebp),%edx
  800445:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80044d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800451:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  800458:	e8 e1 00 00 00       	call   80053e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80045d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	8b 45 10             	mov    0x10(%ebp),%eax
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	e8 6b 00 00 00       	call   8004da <vcprintf>
	cprintf("\n");
  80046f:	c7 04 24 3b 14 80 00 	movl   $0x80143b,(%esp)
  800476:	e8 c3 00 00 00       	call   80053e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047b:	cc                   	int3   
  80047c:	eb fd                	jmp    80047b <_panic+0x58>

0080047e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800484:	8b 45 0c             	mov    0xc(%ebp),%eax
  800487:	8b 00                	mov    (%eax),%eax
  800489:	8d 48 01             	lea    0x1(%eax),%ecx
  80048c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048f:	89 0a                	mov    %ecx,(%edx)
  800491:	8b 55 08             	mov    0x8(%ebp),%edx
  800494:	89 d1                	mov    %edx,%ecx
  800496:	8b 55 0c             	mov    0xc(%ebp),%edx
  800499:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a7:	75 20                	jne    8004c9 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b1:	83 c2 08             	add    $0x8,%edx
  8004b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b8:	89 14 24             	mov    %edx,(%esp)
  8004bb:	e8 42 fc ff ff       	call   800102 <sys_cputs>
		b->idx = 0;
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cc:	8b 40 04             	mov    0x4(%eax),%eax
  8004cf:	8d 50 01             	lea    0x1(%eax),%edx
  8004d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d5:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004d8:	c9                   	leave  
  8004d9:	c3                   	ret    

008004da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
  8004dd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ea:	00 00 00 
	b.cnt = 0;
  8004ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	89 44 24 08          	mov    %eax,0x8(%esp)
  800505:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	c7 04 24 7e 04 80 00 	movl   $0x80047e,(%esp)
  800516:	e8 bd 01 00 00       	call   8006d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800521:	89 44 24 04          	mov    %eax,0x4(%esp)
  800525:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052b:	83 c0 08             	add    $0x8,%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 cc fb ff ff       	call   800102 <sys_cputs>

	return b.cnt;
  800536:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800544:	8d 45 0c             	lea    0xc(%ebp),%eax
  800547:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80054a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80054d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800551:	8b 45 08             	mov    0x8(%ebp),%eax
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	e8 7e ff ff ff       	call   8004da <vcprintf>
  80055c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80055f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	53                   	push   %ebx
  800568:	83 ec 34             	sub    $0x34,%esp
  80056b:	8b 45 10             	mov    0x10(%ebp),%eax
  80056e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800577:	8b 45 18             	mov    0x18(%ebp),%eax
  80057a:	ba 00 00 00 00       	mov    $0x0,%edx
  80057f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800582:	77 72                	ja     8005f6 <printnum+0x92>
  800584:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800587:	72 05                	jb     80058e <printnum+0x2a>
  800589:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80058c:	77 68                	ja     8005f6 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800591:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800594:	8b 45 18             	mov    0x18(%ebp),%eax
  800597:	ba 00 00 00 00       	mov    $0x0,%edx
  80059c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b1:	e8 9a 0b 00 00       	call   801150 <__udivdi3>
  8005b6:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005b9:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005bd:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005c1:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005c4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	e8 82 ff ff ff       	call   800564 <printnum>
  8005e2:	eb 1c                	jmp    800600 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005eb:	8b 45 20             	mov    0x20(%ebp),%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f4:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f6:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005fa:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8005fe:	7f e4                	jg     8005e4 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800600:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800603:	bb 00 00 00 00       	mov    $0x0,%ebx
  800608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80060b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800612:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061d:	e8 5e 0c 00 00       	call   801280 <__umoddi3>
  800622:	05 08 15 80 00       	add    $0x801508,%eax
  800627:	0f b6 00             	movzbl (%eax),%eax
  80062a:	0f be c0             	movsbl %al,%eax
  80062d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800630:	89 54 24 04          	mov    %edx,0x4(%esp)
  800634:	89 04 24             	mov    %eax,(%esp)
  800637:	8b 45 08             	mov    0x8(%ebp),%eax
  80063a:	ff d0                	call   *%eax
}
  80063c:	83 c4 34             	add    $0x34,%esp
  80063f:	5b                   	pop    %ebx
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800645:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800649:	7e 14                	jle    80065f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	8b 00                	mov    (%eax),%eax
  800650:	8d 48 08             	lea    0x8(%eax),%ecx
  800653:	8b 55 08             	mov    0x8(%ebp),%edx
  800656:	89 0a                	mov    %ecx,(%edx)
  800658:	8b 50 04             	mov    0x4(%eax),%edx
  80065b:	8b 00                	mov    (%eax),%eax
  80065d:	eb 30                	jmp    80068f <getuint+0x4d>
	else if (lflag)
  80065f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800663:	74 16                	je     80067b <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	8d 48 04             	lea    0x4(%eax),%ecx
  80066d:	8b 55 08             	mov    0x8(%ebp),%edx
  800670:	89 0a                	mov    %ecx,(%edx)
  800672:	8b 00                	mov    (%eax),%eax
  800674:	ba 00 00 00 00       	mov    $0x0,%edx
  800679:	eb 14                	jmp    80068f <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	8d 48 04             	lea    0x4(%eax),%ecx
  800683:	8b 55 08             	mov    0x8(%ebp),%edx
  800686:	89 0a                	mov    %ecx,(%edx)
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800694:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800698:	7e 14                	jle    8006ae <getint+0x1d>
		return va_arg(*ap, long long);
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a5:	89 0a                	mov    %ecx,(%edx)
  8006a7:	8b 50 04             	mov    0x4(%eax),%edx
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	eb 28                	jmp    8006d6 <getint+0x45>
	else if (lflag)
  8006ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b2:	74 12                	je     8006c6 <getint+0x35>
		return va_arg(*ap, long);
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 00                	mov    (%eax),%eax
  8006b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bf:	89 0a                	mov    %ecx,(%edx)
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	99                   	cltd   
  8006c4:	eb 10                	jmp    8006d6 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	8b 00                	mov    (%eax),%eax
  8006cb:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d1:	89 0a                	mov    %ecx,(%edx)
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	99                   	cltd   
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	56                   	push   %esi
  8006dc:	53                   	push   %ebx
  8006dd:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e0:	eb 18                	jmp    8006fa <vprintfmt+0x22>
			if (ch == '\0')
  8006e2:	85 db                	test   %ebx,%ebx
  8006e4:	75 05                	jne    8006eb <vprintfmt+0x13>
				return;
  8006e6:	e9 cc 03 00 00       	jmp    800ab7 <vprintfmt+0x3df>
			putch(ch, putdat);
  8006eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f2:	89 1c 24             	mov    %ebx,(%esp)
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fd:	8d 50 01             	lea    0x1(%eax),%edx
  800700:	89 55 10             	mov    %edx,0x10(%ebp)
  800703:	0f b6 00             	movzbl (%eax),%eax
  800706:	0f b6 d8             	movzbl %al,%ebx
  800709:	83 fb 25             	cmp    $0x25,%ebx
  80070c:	75 d4                	jne    8006e2 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80070e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800712:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800719:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800720:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800727:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 45 10             	mov    0x10(%ebp),%eax
  800731:	8d 50 01             	lea    0x1(%eax),%edx
  800734:	89 55 10             	mov    %edx,0x10(%ebp)
  800737:	0f b6 00             	movzbl (%eax),%eax
  80073a:	0f b6 d8             	movzbl %al,%ebx
  80073d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800740:	83 f8 55             	cmp    $0x55,%eax
  800743:	0f 87 3d 03 00 00    	ja     800a86 <vprintfmt+0x3ae>
  800749:	8b 04 85 2c 15 80 00 	mov    0x80152c(,%eax,4),%eax
  800750:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800752:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800756:	eb d6                	jmp    80072e <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800758:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80075c:	eb d0                	jmp    80072e <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800765:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800768:	89 d0                	mov    %edx,%eax
  80076a:	c1 e0 02             	shl    $0x2,%eax
  80076d:	01 d0                	add    %edx,%eax
  80076f:	01 c0                	add    %eax,%eax
  800771:	01 d8                	add    %ebx,%eax
  800773:	83 e8 30             	sub    $0x30,%eax
  800776:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800779:	8b 45 10             	mov    0x10(%ebp),%eax
  80077c:	0f b6 00             	movzbl (%eax),%eax
  80077f:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800782:	83 fb 2f             	cmp    $0x2f,%ebx
  800785:	7e 0b                	jle    800792 <vprintfmt+0xba>
  800787:	83 fb 39             	cmp    $0x39,%ebx
  80078a:	7f 06                	jg     800792 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800790:	eb d3                	jmp    800765 <vprintfmt+0x8d>
			goto process_precision;
  800792:	eb 33                	jmp    8007c7 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 50 04             	lea    0x4(%eax),%edx
  80079a:	89 55 14             	mov    %edx,0x14(%ebp)
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007a2:	eb 23                	jmp    8007c7 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a8:	79 0c                	jns    8007b6 <vprintfmt+0xde>
				width = 0;
  8007aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007b1:	e9 78 ff ff ff       	jmp    80072e <vprintfmt+0x56>
  8007b6:	e9 73 ff ff ff       	jmp    80072e <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007bb:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007c2:	e9 67 ff ff ff       	jmp    80072e <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007cb:	79 12                	jns    8007df <vprintfmt+0x107>
				width = precision, precision = -1;
  8007cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007da:	e9 4f ff ff ff       	jmp    80072e <vprintfmt+0x56>
  8007df:	e9 4a ff ff ff       	jmp    80072e <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007e8:	e9 41 ff ff ff       	jmp    80072e <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	8b 00                	mov    (%eax),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ff:	89 04 24             	mov    %eax,(%esp)
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	ff d0                	call   *%eax
			break;
  800807:	e9 a5 02 00 00       	jmp    800ab1 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 50 04             	lea    0x4(%eax),%edx
  800812:	89 55 14             	mov    %edx,0x14(%ebp)
  800815:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800817:	85 db                	test   %ebx,%ebx
  800819:	79 02                	jns    80081d <vprintfmt+0x145>
				err = -err;
  80081b:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081d:	83 fb 09             	cmp    $0x9,%ebx
  800820:	7f 0b                	jg     80082d <vprintfmt+0x155>
  800822:	8b 34 9d e0 14 80 00 	mov    0x8014e0(,%ebx,4),%esi
  800829:	85 f6                	test   %esi,%esi
  80082b:	75 23                	jne    800850 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80082d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800831:	c7 44 24 08 19 15 80 	movl   $0x801519,0x8(%esp)
  800838:	00 
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 73 02 00 00       	call   800abe <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80084b:	e9 61 02 00 00       	jmp    800ab1 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800850:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800854:	c7 44 24 08 22 15 80 	movl   $0x801522,0x8(%esp)
  80085b:	00 
  80085c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	89 04 24             	mov    %eax,(%esp)
  800869:	e8 50 02 00 00       	call   800abe <printfmt>
			break;
  80086e:	e9 3e 02 00 00       	jmp    800ab1 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 50 04             	lea    0x4(%eax),%edx
  800879:	89 55 14             	mov    %edx,0x14(%ebp)
  80087c:	8b 30                	mov    (%eax),%esi
  80087e:	85 f6                	test   %esi,%esi
  800880:	75 05                	jne    800887 <vprintfmt+0x1af>
				p = "(null)";
  800882:	be 25 15 80 00       	mov    $0x801525,%esi
			if (width > 0 && padc != '-')
  800887:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088b:	7e 37                	jle    8008c4 <vprintfmt+0x1ec>
  80088d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800891:	74 31                	je     8008c4 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800893:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089a:	89 34 24             	mov    %esi,(%esp)
  80089d:	e8 39 03 00 00       	call   800bdb <strnlen>
  8008a2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008a5:	eb 17                	jmp    8008be <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008a7:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ba:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c2:	7f e3                	jg     8008a7 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c4:	eb 38                	jmp    8008fe <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ca:	74 1f                	je     8008eb <vprintfmt+0x213>
  8008cc:	83 fb 1f             	cmp    $0x1f,%ebx
  8008cf:	7e 05                	jle    8008d6 <vprintfmt+0x1fe>
  8008d1:	83 fb 7e             	cmp    $0x7e,%ebx
  8008d4:	7e 15                	jle    8008eb <vprintfmt+0x213>
					putch('?', putdat);
  8008d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	ff d0                	call   *%eax
  8008e9:	eb 0f                	jmp    8008fa <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fa:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fe:	89 f0                	mov    %esi,%eax
  800900:	8d 70 01             	lea    0x1(%eax),%esi
  800903:	0f b6 00             	movzbl (%eax),%eax
  800906:	0f be d8             	movsbl %al,%ebx
  800909:	85 db                	test   %ebx,%ebx
  80090b:	74 10                	je     80091d <vprintfmt+0x245>
  80090d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800911:	78 b3                	js     8008c6 <vprintfmt+0x1ee>
  800913:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800917:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80091b:	79 a9                	jns    8008c6 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80091d:	eb 17                	jmp    800936 <vprintfmt+0x25e>
				putch(' ', putdat);
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800932:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800936:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093a:	7f e3                	jg     80091f <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80093c:	e9 70 01 00 00       	jmp    800ab1 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800941:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800944:	89 44 24 04          	mov    %eax,0x4(%esp)
  800948:	8d 45 14             	lea    0x14(%ebp),%eax
  80094b:	89 04 24             	mov    %eax,(%esp)
  80094e:	e8 3e fd ff ff       	call   800691 <getint>
  800953:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800956:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095f:	85 d2                	test   %edx,%edx
  800961:	79 26                	jns    800989 <vprintfmt+0x2b1>
				putch('-', putdat);
  800963:	8b 45 0c             	mov    0xc(%ebp),%eax
  800966:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	ff d0                	call   *%eax
				num = -(long long) num;
  800976:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800979:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80097c:	f7 d8                	neg    %eax
  80097e:	83 d2 00             	adc    $0x0,%edx
  800981:	f7 da                	neg    %edx
  800983:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800986:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800989:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800990:	e9 a8 00 00 00       	jmp    800a3d <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800995:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	8d 45 14             	lea    0x14(%ebp),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	e8 9b fc ff ff       	call   800642 <getuint>
  8009a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009ad:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009b4:	e9 84 00 00 00       	jmp    800a3d <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	e8 77 fc ff ff       	call   800642 <getuint>
  8009cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009d1:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009d8:	eb 63                	jmp    800a3d <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	ff d0                	call   *%eax
			putch('x', putdat);
  8009ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a00:	8b 45 14             	mov    0x14(%ebp),%eax
  800a03:	8d 50 04             	lea    0x4(%eax),%edx
  800a06:	89 55 14             	mov    %edx,0x14(%ebp)
  800a09:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a15:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a1c:	eb 1f                	jmp    800a3d <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	8d 45 14             	lea    0x14(%ebp),%eax
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	e8 12 fc ff ff       	call   800642 <getuint>
  800a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a33:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a36:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a3d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a44:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a4b:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a59:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 f1 fa ff ff       	call   800564 <printnum>
			break;
  800a73:	eb 3c                	jmp    800ab1 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7c:	89 1c 24             	mov    %ebx,(%esp)
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	ff d0                	call   *%eax
			break;
  800a84:	eb 2b                	jmp    800ab1 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a99:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a9d:	eb 04                	jmp    800aa3 <vprintfmt+0x3cb>
  800a9f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aa3:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa6:	83 e8 01             	sub    $0x1,%eax
  800aa9:	0f b6 00             	movzbl (%eax),%eax
  800aac:	3c 25                	cmp    $0x25,%al
  800aae:	75 ef                	jne    800a9f <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800ab0:	90                   	nop
		}
	}
  800ab1:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ab2:	e9 43 fc ff ff       	jmp    8006fa <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ab7:	83 c4 40             	add    $0x40,%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ac4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 ee fb ff ff       	call   8006d8 <vprintfmt>
	va_end(ap);
}
  800aea:	c9                   	leave  
  800aeb:	c3                   	ret    

00800aec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af2:	8b 40 08             	mov    0x8(%eax),%eax
  800af5:	8d 50 01             	lea    0x1(%eax),%edx
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	8b 10                	mov    (%eax),%edx
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b06:	8b 40 04             	mov    0x4(%eax),%eax
  800b09:	39 c2                	cmp    %eax,%edx
  800b0b:	73 12                	jae    800b1f <sprintputch+0x33>
		*b->buf++ = ch;
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	8b 00                	mov    (%eax),%eax
  800b12:	8d 48 01             	lea    0x1(%eax),%ecx
  800b15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b18:	89 0a                	mov    %ecx,(%edx)
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	88 10                	mov    %dl,(%eax)
}
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	01 d0                	add    %edx,%eax
  800b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b42:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b46:	74 06                	je     800b4e <vsnprintf+0x2d>
  800b48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4c:	7f 07                	jg     800b55 <vsnprintf+0x34>
		return -E_INVAL;
  800b4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b53:	eb 2a                	jmp    800b7f <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b55:	8b 45 14             	mov    0x14(%ebp),%eax
  800b58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b63:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6a:	c7 04 24 ec 0a 80 00 	movl   $0x800aec,(%esp)
  800b71:	e8 62 fb ff ff       	call   8006d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b79:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b87:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b94:	8b 45 10             	mov    0x10(%ebp),%eax
  800b97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	89 04 24             	mov    %eax,(%esp)
  800ba8:	e8 74 ff ff ff       	call   800b21 <vsnprintf>
  800bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bb3:	c9                   	leave  
  800bb4:	c3                   	ret    

00800bb5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bbb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bc2:	eb 08                	jmp    800bcc <strlen+0x17>
		n++;
  800bc4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcf:	0f b6 00             	movzbl (%eax),%eax
  800bd2:	84 c0                	test   %al,%al
  800bd4:	75 ee                	jne    800bc4 <strlen+0xf>
		n++;
	return n;
  800bd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bd9:	c9                   	leave  
  800bda:	c3                   	ret    

00800bdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800be8:	eb 0c                	jmp    800bf6 <strnlen+0x1b>
		n++;
  800bea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bf2:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800bf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfa:	74 0a                	je     800c06 <strnlen+0x2b>
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	0f b6 00             	movzbl (%eax),%eax
  800c02:	84 c0                	test   %al,%al
  800c04:	75 e4                	jne    800bea <strnlen+0xf>
		n++;
	return n;
  800c06:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c17:	90                   	nop
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	8d 50 01             	lea    0x1(%eax),%edx
  800c1e:	89 55 08             	mov    %edx,0x8(%ebp)
  800c21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c24:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c27:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c2a:	0f b6 12             	movzbl (%edx),%edx
  800c2d:	88 10                	mov    %dl,(%eax)
  800c2f:	0f b6 00             	movzbl (%eax),%eax
  800c32:	84 c0                	test   %al,%al
  800c34:	75 e2                	jne    800c18 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c36:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	89 04 24             	mov    %eax,(%esp)
  800c47:	e8 69 ff ff ff       	call   800bb5 <strlen>
  800c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c4f:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	01 c2                	add    %eax,%edx
  800c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5e:	89 14 24             	mov    %edx,(%esp)
  800c61:	e8 a5 ff ff ff       	call   800c0b <strcpy>
	return dst;
  800c66:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c71:	8b 45 08             	mov    0x8(%ebp),%eax
  800c74:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c77:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c7e:	eb 23                	jmp    800ca3 <strncpy+0x38>
		*dst++ = *src;
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8d 50 01             	lea    0x1(%eax),%edx
  800c86:	89 55 08             	mov    %edx,0x8(%ebp)
  800c89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8c:	0f b6 12             	movzbl (%edx),%edx
  800c8f:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800c91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c94:	0f b6 00             	movzbl (%eax),%eax
  800c97:	84 c0                	test   %al,%al
  800c99:	74 04                	je     800c9f <strncpy+0x34>
			src++;
  800c9b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ca6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ca9:	72 d5                	jb     800c80 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cab:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cbc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc0:	74 33                	je     800cf5 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cc2:	eb 17                	jmp    800cdb <strlcpy+0x2b>
			*dst++ = *src++;
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8d 50 01             	lea    0x1(%eax),%edx
  800cca:	89 55 08             	mov    %edx,0x8(%ebp)
  800ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd0:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cd3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cd6:	0f b6 12             	movzbl (%edx),%edx
  800cd9:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cdb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800cdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce3:	74 0a                	je     800cef <strlcpy+0x3f>
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	0f b6 00             	movzbl (%eax),%eax
  800ceb:	84 c0                	test   %al,%al
  800ced:	75 d5                	jne    800cc4 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cfb:	29 c2                	sub    %eax,%edx
  800cfd:	89 d0                	mov    %edx,%eax
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d04:	eb 08                	jmp    800d0e <strcmp+0xd>
		p++, q++;
  800d06:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d0a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	0f b6 00             	movzbl (%eax),%eax
  800d14:	84 c0                	test   %al,%al
  800d16:	74 10                	je     800d28 <strcmp+0x27>
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	0f b6 10             	movzbl (%eax),%edx
  800d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d21:	0f b6 00             	movzbl (%eax),%eax
  800d24:	38 c2                	cmp    %al,%dl
  800d26:	74 de                	je     800d06 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	0f b6 00             	movzbl (%eax),%eax
  800d2e:	0f b6 d0             	movzbl %al,%edx
  800d31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d34:	0f b6 00             	movzbl (%eax),%eax
  800d37:	0f b6 c0             	movzbl %al,%eax
  800d3a:	29 c2                	sub    %eax,%edx
  800d3c:	89 d0                	mov    %edx,%eax
}
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d43:	eb 0c                	jmp    800d51 <strncmp+0x11>
		n--, p++, q++;
  800d45:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d49:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d55:	74 1a                	je     800d71 <strncmp+0x31>
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	0f b6 00             	movzbl (%eax),%eax
  800d5d:	84 c0                	test   %al,%al
  800d5f:	74 10                	je     800d71 <strncmp+0x31>
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	0f b6 10             	movzbl (%eax),%edx
  800d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6a:	0f b6 00             	movzbl (%eax),%eax
  800d6d:	38 c2                	cmp    %al,%dl
  800d6f:	74 d4                	je     800d45 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d71:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d75:	75 07                	jne    800d7e <strncmp+0x3e>
		return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7c:	eb 16                	jmp    800d94 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	0f b6 00             	movzbl (%eax),%eax
  800d84:	0f b6 d0             	movzbl %al,%edx
  800d87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8a:	0f b6 00             	movzbl (%eax),%eax
  800d8d:	0f b6 c0             	movzbl %al,%eax
  800d90:	29 c2                	sub    %eax,%edx
  800d92:	89 d0                	mov    %edx,%eax
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800da2:	eb 14                	jmp    800db8 <strchr+0x22>
		if (*s == c)
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	0f b6 00             	movzbl (%eax),%eax
  800daa:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dad:	75 05                	jne    800db4 <strchr+0x1e>
			return (char *) s;
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	eb 13                	jmp    800dc7 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800db4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbb:	0f b6 00             	movzbl (%eax),%eax
  800dbe:	84 c0                	test   %al,%al
  800dc0:	75 e2                	jne    800da4 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    

00800dc9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dd5:	eb 11                	jmp    800de8 <strfind+0x1f>
		if (*s == c)
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	0f b6 00             	movzbl (%eax),%eax
  800ddd:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800de0:	75 02                	jne    800de4 <strfind+0x1b>
			break;
  800de2:	eb 0e                	jmp    800df2 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800de4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	0f b6 00             	movzbl (%eax),%eax
  800dee:	84 c0                	test   %al,%al
  800df0:	75 e5                	jne    800dd7 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
	char *p;

	if (n == 0)
  800dfb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dff:	75 05                	jne    800e06 <memset+0xf>
		return v;
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	eb 5c                	jmp    800e62 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	83 e0 03             	and    $0x3,%eax
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	75 41                	jne    800e51 <memset+0x5a>
  800e10:	8b 45 10             	mov    0x10(%ebp),%eax
  800e13:	83 e0 03             	and    $0x3,%eax
  800e16:	85 c0                	test   %eax,%eax
  800e18:	75 37                	jne    800e51 <memset+0x5a>
		c &= 0xFF;
  800e1a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e24:	c1 e0 18             	shl    $0x18,%eax
  800e27:	89 c2                	mov    %eax,%edx
  800e29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2c:	c1 e0 10             	shl    $0x10,%eax
  800e2f:	09 c2                	or     %eax,%edx
  800e31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e34:	c1 e0 08             	shl    $0x8,%eax
  800e37:	09 d0                	or     %edx,%eax
  800e39:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3f:	c1 e8 02             	shr    $0x2,%eax
  800e42:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	89 d7                	mov    %edx,%edi
  800e4c:	fc                   	cld    
  800e4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800e4f:	eb 0e                	jmp    800e5f <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e57:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e5a:	89 d7                	mov    %edx,%edi
  800e5c:	fc                   	cld    
  800e5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e80:	73 6d                	jae    800eef <memmove+0x8a>
  800e82:	8b 45 10             	mov    0x10(%ebp),%eax
  800e85:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e88:	01 d0                	add    %edx,%eax
  800e8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e8d:	76 60                	jbe    800eef <memmove+0x8a>
		s += n;
  800e8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e92:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800e95:	8b 45 10             	mov    0x10(%ebp),%eax
  800e98:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9e:	83 e0 03             	and    $0x3,%eax
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	75 2f                	jne    800ed4 <memmove+0x6f>
  800ea5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ea8:	83 e0 03             	and    $0x3,%eax
  800eab:	85 c0                	test   %eax,%eax
  800ead:	75 25                	jne    800ed4 <memmove+0x6f>
  800eaf:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb2:	83 e0 03             	and    $0x3,%eax
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	75 1b                	jne    800ed4 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ebc:	83 e8 04             	sub    $0x4,%eax
  800ebf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec2:	83 ea 04             	sub    $0x4,%edx
  800ec5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ec8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ecb:	89 c7                	mov    %eax,%edi
  800ecd:	89 d6                	mov    %edx,%esi
  800ecf:	fd                   	std    
  800ed0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed2:	eb 18                	jmp    800eec <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ed4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ed7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edd:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ee0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee3:	89 d7                	mov    %edx,%edi
  800ee5:	89 de                	mov    %ebx,%esi
  800ee7:	89 c1                	mov    %eax,%ecx
  800ee9:	fd                   	std    
  800eea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eec:	fc                   	cld    
  800eed:	eb 45                	jmp    800f34 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef2:	83 e0 03             	and    $0x3,%eax
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 2b                	jne    800f24 <memmove+0xbf>
  800ef9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efc:	83 e0 03             	and    $0x3,%eax
  800eff:	85 c0                	test   %eax,%eax
  800f01:	75 21                	jne    800f24 <memmove+0xbf>
  800f03:	8b 45 10             	mov    0x10(%ebp),%eax
  800f06:	83 e0 03             	and    $0x3,%eax
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	75 17                	jne    800f24 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f10:	c1 e8 02             	shr    $0x2,%eax
  800f13:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f1b:	89 c7                	mov    %eax,%edi
  800f1d:	89 d6                	mov    %edx,%esi
  800f1f:	fc                   	cld    
  800f20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f22:	eb 10                	jmp    800f34 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f27:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f2d:	89 c7                	mov    %eax,%edi
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	fc                   	cld    
  800f32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f45:	8b 45 10             	mov    0x10(%ebp),%eax
  800f48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f53:	8b 45 08             	mov    0x8(%ebp),%eax
  800f56:	89 04 24             	mov    %eax,(%esp)
  800f59:	e8 07 ff ff ff       	call   800e65 <memmove>
}
  800f5e:	c9                   	leave  
  800f5f:	c3                   	ret    

00800f60 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f66:	8b 45 08             	mov    0x8(%ebp),%eax
  800f69:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6f:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f72:	eb 30                	jmp    800fa4 <memcmp+0x44>
		if (*s1 != *s2)
  800f74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f77:	0f b6 10             	movzbl (%eax),%edx
  800f7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f7d:	0f b6 00             	movzbl (%eax),%eax
  800f80:	38 c2                	cmp    %al,%dl
  800f82:	74 18                	je     800f9c <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f84:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f87:	0f b6 00             	movzbl (%eax),%eax
  800f8a:	0f b6 d0             	movzbl %al,%edx
  800f8d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f90:	0f b6 00             	movzbl (%eax),%eax
  800f93:	0f b6 c0             	movzbl %al,%eax
  800f96:	29 c2                	sub    %eax,%edx
  800f98:	89 d0                	mov    %edx,%eax
  800f9a:	eb 1a                	jmp    800fb6 <memcmp+0x56>
		s1++, s2++;
  800f9c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fa0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800faa:	89 55 10             	mov    %edx,0x10(%ebp)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	75 c3                	jne    800f74 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	01 d0                	add    %edx,%eax
  800fc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fc9:	eb 13                	jmp    800fde <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fce:	0f b6 10             	movzbl (%eax),%edx
  800fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd4:	38 c2                	cmp    %al,%dl
  800fd6:	75 02                	jne    800fda <memfind+0x22>
			break;
  800fd8:	eb 0c                	jmp    800fe6 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fda:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800fe4:	72 e5                	jb     800fcb <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ff1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ff8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fff:	eb 04                	jmp    801005 <strtol+0x1a>
		s++;
  801001:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801005:	8b 45 08             	mov    0x8(%ebp),%eax
  801008:	0f b6 00             	movzbl (%eax),%eax
  80100b:	3c 20                	cmp    $0x20,%al
  80100d:	74 f2                	je     801001 <strtol+0x16>
  80100f:	8b 45 08             	mov    0x8(%ebp),%eax
  801012:	0f b6 00             	movzbl (%eax),%eax
  801015:	3c 09                	cmp    $0x9,%al
  801017:	74 e8                	je     801001 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
  80101c:	0f b6 00             	movzbl (%eax),%eax
  80101f:	3c 2b                	cmp    $0x2b,%al
  801021:	75 06                	jne    801029 <strtol+0x3e>
		s++;
  801023:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801027:	eb 15                	jmp    80103e <strtol+0x53>
	else if (*s == '-')
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
  80102c:	0f b6 00             	movzbl (%eax),%eax
  80102f:	3c 2d                	cmp    $0x2d,%al
  801031:	75 0b                	jne    80103e <strtol+0x53>
		s++, neg = 1;
  801033:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801037:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80103e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801042:	74 06                	je     80104a <strtol+0x5f>
  801044:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801048:	75 24                	jne    80106e <strtol+0x83>
  80104a:	8b 45 08             	mov    0x8(%ebp),%eax
  80104d:	0f b6 00             	movzbl (%eax),%eax
  801050:	3c 30                	cmp    $0x30,%al
  801052:	75 1a                	jne    80106e <strtol+0x83>
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	83 c0 01             	add    $0x1,%eax
  80105a:	0f b6 00             	movzbl (%eax),%eax
  80105d:	3c 78                	cmp    $0x78,%al
  80105f:	75 0d                	jne    80106e <strtol+0x83>
		s += 2, base = 16;
  801061:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801065:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80106c:	eb 2a                	jmp    801098 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80106e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801072:	75 17                	jne    80108b <strtol+0xa0>
  801074:	8b 45 08             	mov    0x8(%ebp),%eax
  801077:	0f b6 00             	movzbl (%eax),%eax
  80107a:	3c 30                	cmp    $0x30,%al
  80107c:	75 0d                	jne    80108b <strtol+0xa0>
		s++, base = 8;
  80107e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801082:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801089:	eb 0d                	jmp    801098 <strtol+0xad>
	else if (base == 0)
  80108b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108f:	75 07                	jne    801098 <strtol+0xad>
		base = 10;
  801091:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	0f b6 00             	movzbl (%eax),%eax
  80109e:	3c 2f                	cmp    $0x2f,%al
  8010a0:	7e 1b                	jle    8010bd <strtol+0xd2>
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	0f b6 00             	movzbl (%eax),%eax
  8010a8:	3c 39                	cmp    $0x39,%al
  8010aa:	7f 11                	jg     8010bd <strtol+0xd2>
			dig = *s - '0';
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	0f be c0             	movsbl %al,%eax
  8010b5:	83 e8 30             	sub    $0x30,%eax
  8010b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010bb:	eb 48                	jmp    801105 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	0f b6 00             	movzbl (%eax),%eax
  8010c3:	3c 60                	cmp    $0x60,%al
  8010c5:	7e 1b                	jle    8010e2 <strtol+0xf7>
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	0f b6 00             	movzbl (%eax),%eax
  8010cd:	3c 7a                	cmp    $0x7a,%al
  8010cf:	7f 11                	jg     8010e2 <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d4:	0f b6 00             	movzbl (%eax),%eax
  8010d7:	0f be c0             	movsbl %al,%eax
  8010da:	83 e8 57             	sub    $0x57,%eax
  8010dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010e0:	eb 23                	jmp    801105 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	0f b6 00             	movzbl (%eax),%eax
  8010e8:	3c 40                	cmp    $0x40,%al
  8010ea:	7e 3d                	jle    801129 <strtol+0x13e>
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	0f b6 00             	movzbl (%eax),%eax
  8010f2:	3c 5a                	cmp    $0x5a,%al
  8010f4:	7f 33                	jg     801129 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	0f b6 00             	movzbl (%eax),%eax
  8010fc:	0f be c0             	movsbl %al,%eax
  8010ff:	83 e8 37             	sub    $0x37,%eax
  801102:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801108:	3b 45 10             	cmp    0x10(%ebp),%eax
  80110b:	7c 02                	jl     80110f <strtol+0x124>
			break;
  80110d:	eb 1a                	jmp    801129 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80110f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801113:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801116:	0f af 45 10          	imul   0x10(%ebp),%eax
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111f:	01 d0                	add    %edx,%eax
  801121:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801124:	e9 6f ff ff ff       	jmp    801098 <strtol+0xad>

	if (endptr)
  801129:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80112d:	74 08                	je     801137 <strtol+0x14c>
		*endptr = (char *) s;
  80112f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801132:	8b 55 08             	mov    0x8(%ebp),%edx
  801135:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801137:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80113b:	74 07                	je     801144 <strtol+0x159>
  80113d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801140:	f7 d8                	neg    %eax
  801142:	eb 03                	jmp    801147 <strtol+0x15c>
  801144:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    
  801149:	66 90                	xchg   %ax,%ax
  80114b:	66 90                	xchg   %ax,%ax
  80114d:	66 90                	xchg   %ax,%ax
  80114f:	90                   	nop

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
