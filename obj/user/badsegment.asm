
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
  8000db:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8000e2:	00 
  8000e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ea:	00 
  8000eb:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000f2:	e8 6f 03 00 00       	call   800466 <_panic>

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

00800423 <sys_exec>:

void sys_exec(char* buf){
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800433:	00 
  800434:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80043b:	00 
  80043c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800443:	00 
  800444:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044b:	00 
  80044c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800450:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800457:	00 
  800458:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80045f:	e8 3d fc ff ff       	call   8000a1 <syscall>
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	53                   	push   %ebx
  80046a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80046d:	8d 45 14             	lea    0x14(%ebp),%eax
  800470:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800473:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800479:	e8 4d fd ff ff       	call   8001cb <sys_getenvid>
  80047e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800481:	89 54 24 10          	mov    %edx,0x10(%esp)
  800485:	8b 55 08             	mov    0x8(%ebp),%edx
  800488:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800490:	89 44 24 04          	mov    %eax,0x4(%esp)
  800494:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  80049b:	e8 e1 00 00 00       	call   800581 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	e8 6b 00 00 00       	call   80051d <vcprintf>
	cprintf("\n");
  8004b2:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  8004b9:	e8 c3 00 00 00       	call   800581 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004be:	cc                   	int3   
  8004bf:	eb fd                	jmp    8004be <_panic+0x58>

008004c1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	8d 48 01             	lea    0x1(%eax),%ecx
  8004cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d2:	89 0a                	mov    %ecx,(%edx)
  8004d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d7:	89 d1                	mov    %edx,%ecx
  8004d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004dc:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ea:	75 20                	jne    80050c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f4:	83 c2 08             	add    $0x8,%edx
  8004f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fb:	89 14 24             	mov    %edx,(%esp)
  8004fe:	e8 ff fb ff ff       	call   800102 <sys_cputs>
		b->idx = 0;
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
  800506:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050f:	8b 40 04             	mov    0x4(%eax),%eax
  800512:	8d 50 01             	lea    0x1(%eax),%edx
  800515:	8b 45 0c             	mov    0xc(%ebp),%eax
  800518:	89 50 04             	mov    %edx,0x4(%eax)
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800526:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80052d:	00 00 00 
	b.cnt = 0;
  800530:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800537:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80053a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800541:	8b 45 08             	mov    0x8(%ebp),%eax
  800544:	89 44 24 08          	mov    %eax,0x8(%esp)
  800548:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80054e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800552:	c7 04 24 c1 04 80 00 	movl   $0x8004c1,(%esp)
  800559:	e8 bd 01 00 00       	call   80071b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80055e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800564:	89 44 24 04          	mov    %eax,0x4(%esp)
  800568:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80056e:	83 c0 08             	add    $0x8,%eax
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	e8 89 fb ff ff       	call   800102 <sys_cputs>

	return b.cnt;
  800579:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800587:	8d 45 0c             	lea    0xc(%ebp),%eax
  80058a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80058d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800590:	89 44 24 04          	mov    %eax,0x4(%esp)
  800594:	8b 45 08             	mov    0x8(%ebp),%eax
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	e8 7e ff ff ff       	call   80051d <vcprintf>
  80059f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	53                   	push   %ebx
  8005ab:	83 ec 34             	sub    $0x34,%esp
  8005ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ba:	8b 45 18             	mov    0x18(%ebp),%eax
  8005bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c5:	77 72                	ja     800639 <printnum+0x92>
  8005c7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005ca:	72 05                	jb     8005d1 <printnum+0x2a>
  8005cc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005cf:	77 68                	ja     800639 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005d1:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005d7:	8b 45 18             	mov    0x18(%ebp),%eax
  8005da:	ba 00 00 00 00       	mov    $0x0,%edx
  8005df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ed:	89 04 24             	mov    %eax,(%esp)
  8005f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f4:	e8 97 0b 00 00       	call   801190 <__udivdi3>
  8005f9:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005fc:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800600:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800604:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800607:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800613:	8b 45 0c             	mov    0xc(%ebp),%eax
  800616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061a:	8b 45 08             	mov    0x8(%ebp),%eax
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	e8 82 ff ff ff       	call   8005a7 <printnum>
  800625:	eb 1c                	jmp    800643 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800627:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062e:	8b 45 20             	mov    0x20(%ebp),%eax
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800639:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80063d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800641:	7f e4                	jg     800627 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800643:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800646:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800651:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800655:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800660:	e8 5b 0c 00 00       	call   8012c0 <__umoddi3>
  800665:	05 48 15 80 00       	add    $0x801548,%eax
  80066a:	0f b6 00             	movzbl (%eax),%eax
  80066d:	0f be c0             	movsbl %al,%eax
  800670:	8b 55 0c             	mov    0xc(%ebp),%edx
  800673:	89 54 24 04          	mov    %edx,0x4(%esp)
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	ff d0                	call   *%eax
}
  80067f:	83 c4 34             	add    $0x34,%esp
  800682:	5b                   	pop    %ebx
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800688:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80068c:	7e 14                	jle    8006a2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	8b 00                	mov    (%eax),%eax
  800693:	8d 48 08             	lea    0x8(%eax),%ecx
  800696:	8b 55 08             	mov    0x8(%ebp),%edx
  800699:	89 0a                	mov    %ecx,(%edx)
  80069b:	8b 50 04             	mov    0x4(%eax),%edx
  80069e:	8b 00                	mov    (%eax),%eax
  8006a0:	eb 30                	jmp    8006d2 <getuint+0x4d>
	else if (lflag)
  8006a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006a6:	74 16                	je     8006be <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b3:	89 0a                	mov    %ecx,(%edx)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bc:	eb 14                	jmp    8006d2 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c9:	89 0a                	mov    %ecx,(%edx)
  8006cb:	8b 00                	mov    (%eax),%eax
  8006cd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006db:	7e 14                	jle    8006f1 <getint+0x1d>
		return va_arg(*ap, long long);
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	8d 48 08             	lea    0x8(%eax),%ecx
  8006e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e8:	89 0a                	mov    %ecx,(%edx)
  8006ea:	8b 50 04             	mov    0x4(%eax),%edx
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	eb 28                	jmp    800719 <getint+0x45>
	else if (lflag)
  8006f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006f5:	74 12                	je     800709 <getint+0x35>
		return va_arg(*ap, long);
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800702:	89 0a                	mov    %ecx,(%edx)
  800704:	8b 00                	mov    (%eax),%eax
  800706:	99                   	cltd   
  800707:	eb 10                	jmp    800719 <getint+0x45>
	else
		return va_arg(*ap, int);
  800709:	8b 45 08             	mov    0x8(%ebp),%eax
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	8d 48 04             	lea    0x4(%eax),%ecx
  800711:	8b 55 08             	mov    0x8(%ebp),%edx
  800714:	89 0a                	mov    %ecx,(%edx)
  800716:	8b 00                	mov    (%eax),%eax
  800718:	99                   	cltd   
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	56                   	push   %esi
  80071f:	53                   	push   %ebx
  800720:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800723:	eb 18                	jmp    80073d <vprintfmt+0x22>
			if (ch == '\0')
  800725:	85 db                	test   %ebx,%ebx
  800727:	75 05                	jne    80072e <vprintfmt+0x13>
				return;
  800729:	e9 cc 03 00 00       	jmp    800afa <vprintfmt+0x3df>
			putch(ch, putdat);
  80072e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	89 1c 24             	mov    %ebx,(%esp)
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80073d:	8b 45 10             	mov    0x10(%ebp),%eax
  800740:	8d 50 01             	lea    0x1(%eax),%edx
  800743:	89 55 10             	mov    %edx,0x10(%ebp)
  800746:	0f b6 00             	movzbl (%eax),%eax
  800749:	0f b6 d8             	movzbl %al,%ebx
  80074c:	83 fb 25             	cmp    $0x25,%ebx
  80074f:	75 d4                	jne    800725 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800751:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800755:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80075c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800763:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80076a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800771:	8b 45 10             	mov    0x10(%ebp),%eax
  800774:	8d 50 01             	lea    0x1(%eax),%edx
  800777:	89 55 10             	mov    %edx,0x10(%ebp)
  80077a:	0f b6 00             	movzbl (%eax),%eax
  80077d:	0f b6 d8             	movzbl %al,%ebx
  800780:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800783:	83 f8 55             	cmp    $0x55,%eax
  800786:	0f 87 3d 03 00 00    	ja     800ac9 <vprintfmt+0x3ae>
  80078c:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800793:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800795:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800799:	eb d6                	jmp    800771 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80079b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80079f:	eb d0                	jmp    800771 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007a1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007ab:	89 d0                	mov    %edx,%eax
  8007ad:	c1 e0 02             	shl    $0x2,%eax
  8007b0:	01 d0                	add    %edx,%eax
  8007b2:	01 c0                	add    %eax,%eax
  8007b4:	01 d8                	add    %ebx,%eax
  8007b6:	83 e8 30             	sub    $0x30,%eax
  8007b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bf:	0f b6 00             	movzbl (%eax),%eax
  8007c2:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007c5:	83 fb 2f             	cmp    $0x2f,%ebx
  8007c8:	7e 0b                	jle    8007d5 <vprintfmt+0xba>
  8007ca:	83 fb 39             	cmp    $0x39,%ebx
  8007cd:	7f 06                	jg     8007d5 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007cf:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007d3:	eb d3                	jmp    8007a8 <vprintfmt+0x8d>
			goto process_precision;
  8007d5:	eb 33                	jmp    80080a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007e5:	eb 23                	jmp    80080a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007eb:	79 0c                	jns    8007f9 <vprintfmt+0xde>
				width = 0;
  8007ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007f4:	e9 78 ff ff ff       	jmp    800771 <vprintfmt+0x56>
  8007f9:	e9 73 ff ff ff       	jmp    800771 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007fe:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800805:	e9 67 ff ff ff       	jmp    800771 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80080a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080e:	79 12                	jns    800822 <vprintfmt+0x107>
				width = precision, precision = -1;
  800810:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800813:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800816:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80081d:	e9 4f ff ff ff       	jmp    800771 <vprintfmt+0x56>
  800822:	e9 4a ff ff ff       	jmp    800771 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800827:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80082b:	e9 41 ff ff ff       	jmp    800771 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8d 50 04             	lea    0x4(%eax),%edx
  800836:	89 55 14             	mov    %edx,0x14(%ebp)
  800839:	8b 00                	mov    (%eax),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800842:	89 04 24             	mov    %eax,(%esp)
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	ff d0                	call   *%eax
			break;
  80084a:	e9 a5 02 00 00       	jmp    800af4 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8d 50 04             	lea    0x4(%eax),%edx
  800855:	89 55 14             	mov    %edx,0x14(%ebp)
  800858:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80085a:	85 db                	test   %ebx,%ebx
  80085c:	79 02                	jns    800860 <vprintfmt+0x145>
				err = -err;
  80085e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800860:	83 fb 09             	cmp    $0x9,%ebx
  800863:	7f 0b                	jg     800870 <vprintfmt+0x155>
  800865:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  80086c:	85 f6                	test   %esi,%esi
  80086e:	75 23                	jne    800893 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800870:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800874:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80087b:	00 
  80087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 73 02 00 00       	call   800b01 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80088e:	e9 61 02 00 00       	jmp    800af4 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800893:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800897:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80089e:	00 
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	89 04 24             	mov    %eax,(%esp)
  8008ac:	e8 50 02 00 00       	call   800b01 <printfmt>
			break;
  8008b1:	e9 3e 02 00 00       	jmp    800af4 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b9:	8d 50 04             	lea    0x4(%eax),%edx
  8008bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bf:	8b 30                	mov    (%eax),%esi
  8008c1:	85 f6                	test   %esi,%esi
  8008c3:	75 05                	jne    8008ca <vprintfmt+0x1af>
				p = "(null)";
  8008c5:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8008ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ce:	7e 37                	jle    800907 <vprintfmt+0x1ec>
  8008d0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008d4:	74 31                	je     800907 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dd:	89 34 24             	mov    %esi,(%esp)
  8008e0:	e8 39 03 00 00       	call   800c1e <strnlen>
  8008e5:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008e8:	eb 17                	jmp    800901 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008ea:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f5:	89 04 24             	mov    %eax,(%esp)
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008fd:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800901:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800905:	7f e3                	jg     8008ea <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800907:	eb 38                	jmp    800941 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800909:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80090d:	74 1f                	je     80092e <vprintfmt+0x213>
  80090f:	83 fb 1f             	cmp    $0x1f,%ebx
  800912:	7e 05                	jle    800919 <vprintfmt+0x1fe>
  800914:	83 fb 7e             	cmp    $0x7e,%ebx
  800917:	7e 15                	jle    80092e <vprintfmt+0x213>
					putch('?', putdat);
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800920:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	ff d0                	call   *%eax
  80092c:	eb 0f                	jmp    80093d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80092e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	89 1c 24             	mov    %ebx,(%esp)
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800941:	89 f0                	mov    %esi,%eax
  800943:	8d 70 01             	lea    0x1(%eax),%esi
  800946:	0f b6 00             	movzbl (%eax),%eax
  800949:	0f be d8             	movsbl %al,%ebx
  80094c:	85 db                	test   %ebx,%ebx
  80094e:	74 10                	je     800960 <vprintfmt+0x245>
  800950:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800954:	78 b3                	js     800909 <vprintfmt+0x1ee>
  800956:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80095a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80095e:	79 a9                	jns    800909 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800960:	eb 17                	jmp    800979 <vprintfmt+0x25e>
				putch(' ', putdat);
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800975:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800979:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097d:	7f e3                	jg     800962 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80097f:	e9 70 01 00 00       	jmp    800af4 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800984:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098b:	8d 45 14             	lea    0x14(%ebp),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 3e fd ff ff       	call   8006d4 <getint>
  800996:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800999:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80099c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80099f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	79 26                	jns    8009cc <vprintfmt+0x2b1>
				putch('-', putdat);
  8009a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ad:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	ff d0                	call   *%eax
				num = -(long long) num;
  8009b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009bf:	f7 d8                	neg    %eax
  8009c1:	83 d2 00             	adc    $0x0,%edx
  8009c4:	f7 da                	neg    %edx
  8009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009cc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009d3:	e9 a8 00 00 00       	jmp    800a80 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009df:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e2:	89 04 24             	mov    %eax,(%esp)
  8009e5:	e8 9b fc ff ff       	call   800685 <getuint>
  8009ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ed:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009f0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009f7:	e9 84 00 00 00       	jmp    800a80 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a03:	8d 45 14             	lea    0x14(%ebp),%eax
  800a06:	89 04 24             	mov    %eax,(%esp)
  800a09:	e8 77 fc ff ff       	call   800685 <getuint>
  800a0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a11:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a14:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a1b:	eb 63                	jmp    800a80 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a24:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	ff d0                	call   *%eax
			putch('x', putdat);
  800a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a37:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a43:	8b 45 14             	mov    0x14(%ebp),%eax
  800a46:	8d 50 04             	lea    0x4(%eax),%edx
  800a49:	89 55 14             	mov    %edx,0x14(%ebp)
  800a4c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a58:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a5f:	eb 1f                	jmp    800a80 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a68:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 12 fc ff ff       	call   800685 <getuint>
  800a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a76:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a79:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a80:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a87:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a8e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	89 04 24             	mov    %eax,(%esp)
  800ab1:	e8 f1 fa ff ff       	call   8005a7 <printnum>
			break;
  800ab6:	eb 3c                	jmp    800af4 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abf:	89 1c 24             	mov    %ebx,(%esp)
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	ff d0                	call   *%eax
			break;
  800ac7:	eb 2b                	jmp    800af4 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800adc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae0:	eb 04                	jmp    800ae6 <vprintfmt+0x3cb>
  800ae2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae9:	83 e8 01             	sub    $0x1,%eax
  800aec:	0f b6 00             	movzbl (%eax),%eax
  800aef:	3c 25                	cmp    $0x25,%al
  800af1:	75 ef                	jne    800ae2 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800af3:	90                   	nop
		}
	}
  800af4:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800af5:	e9 43 fc ff ff       	jmp    80073d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800afa:	83 c4 40             	add    $0x40,%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b07:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b14:	8b 45 10             	mov    0x10(%ebp),%eax
  800b17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	89 04 24             	mov    %eax,(%esp)
  800b28:	e8 ee fb ff ff       	call   80071b <vprintfmt>
	va_end(ap);
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	8b 40 08             	mov    0x8(%eax),%eax
  800b38:	8d 50 01             	lea    0x1(%eax),%edx
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	8b 10                	mov    (%eax),%edx
  800b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b49:	8b 40 04             	mov    0x4(%eax),%eax
  800b4c:	39 c2                	cmp    %eax,%edx
  800b4e:	73 12                	jae    800b62 <sprintputch+0x33>
		*b->buf++ = ch;
  800b50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b53:	8b 00                	mov    (%eax),%eax
  800b55:	8d 48 01             	lea    0x1(%eax),%ecx
  800b58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5b:	89 0a                	mov    %ecx,(%edx)
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	88 10                	mov    %dl,(%eax)
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	01 d0                	add    %edx,%eax
  800b7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b85:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b89:	74 06                	je     800b91 <vsnprintf+0x2d>
  800b8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8f:	7f 07                	jg     800b98 <vsnprintf+0x34>
		return -E_INVAL;
  800b91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b96:	eb 2a                	jmp    800bc2 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b98:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bad:	c7 04 24 2f 0b 80 00 	movl   $0x800b2f,(%esp)
  800bb4:	e8 62 fb ff ff       	call   80071b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bca:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bda:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	89 04 24             	mov    %eax,(%esp)
  800beb:	e8 74 ff ff ff       	call   800b64 <vsnprintf>
  800bf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bfe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c05:	eb 08                	jmp    800c0f <strlen+0x17>
		n++;
  800c07:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c0b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	0f b6 00             	movzbl (%eax),%eax
  800c15:	84 c0                	test   %al,%al
  800c17:	75 ee                	jne    800c07 <strlen+0xf>
		n++;
	return n;
  800c19:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c2b:	eb 0c                	jmp    800c39 <strnlen+0x1b>
		n++;
  800c2d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c31:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c35:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3d:	74 0a                	je     800c49 <strnlen+0x2b>
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	0f b6 00             	movzbl (%eax),%eax
  800c45:	84 c0                	test   %al,%al
  800c47:	75 e4                	jne    800c2d <strnlen+0xf>
		n++;
	return n;
  800c49:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c5a:	90                   	nop
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	8d 50 01             	lea    0x1(%eax),%edx
  800c61:	89 55 08             	mov    %edx,0x8(%ebp)
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c67:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c6a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c6d:	0f b6 12             	movzbl (%edx),%edx
  800c70:	88 10                	mov    %dl,(%eax)
  800c72:	0f b6 00             	movzbl (%eax),%eax
  800c75:	84 c0                	test   %al,%al
  800c77:	75 e2                	jne    800c5b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	89 04 24             	mov    %eax,(%esp)
  800c8a:	e8 69 ff ff ff       	call   800bf8 <strlen>
  800c8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c92:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	01 c2                	add    %eax,%edx
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca1:	89 14 24             	mov    %edx,(%esp)
  800ca4:	e8 a5 ff ff ff       	call   800c4e <strcpy>
	return dst;
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cc1:	eb 23                	jmp    800ce6 <strncpy+0x38>
		*dst++ = *src;
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	8d 50 01             	lea    0x1(%eax),%edx
  800cc9:	89 55 08             	mov    %edx,0x8(%ebp)
  800ccc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccf:	0f b6 12             	movzbl (%edx),%edx
  800cd2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd7:	0f b6 00             	movzbl (%eax),%eax
  800cda:	84 c0                	test   %al,%al
  800cdc:	74 04                	je     800ce2 <strncpy+0x34>
			src++;
  800cde:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cec:	72 d5                	jb     800cc3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cee:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d03:	74 33                	je     800d38 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d05:	eb 17                	jmp    800d1e <strlcpy+0x2b>
			*dst++ = *src++;
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	8d 50 01             	lea    0x1(%eax),%edx
  800d0d:	89 55 08             	mov    %edx,0x8(%ebp)
  800d10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d13:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d16:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d19:	0f b6 12             	movzbl (%edx),%edx
  800d1c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d1e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d26:	74 0a                	je     800d32 <strlcpy+0x3f>
  800d28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2b:	0f b6 00             	movzbl (%eax),%eax
  800d2e:	84 c0                	test   %al,%al
  800d30:	75 d5                	jne    800d07 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3e:	29 c2                	sub    %eax,%edx
  800d40:	89 d0                	mov    %edx,%eax
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d47:	eb 08                	jmp    800d51 <strcmp+0xd>
		p++, q++;
  800d49:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	84 c0                	test   %al,%al
  800d59:	74 10                	je     800d6b <strcmp+0x27>
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	0f b6 10             	movzbl (%eax),%edx
  800d61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d64:	0f b6 00             	movzbl (%eax),%eax
  800d67:	38 c2                	cmp    %al,%dl
  800d69:	74 de                	je     800d49 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	0f b6 00             	movzbl (%eax),%eax
  800d71:	0f b6 d0             	movzbl %al,%edx
  800d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d77:	0f b6 00             	movzbl (%eax),%eax
  800d7a:	0f b6 c0             	movzbl %al,%eax
  800d7d:	29 c2                	sub    %eax,%edx
  800d7f:	89 d0                	mov    %edx,%eax
}
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d86:	eb 0c                	jmp    800d94 <strncmp+0x11>
		n--, p++, q++;
  800d88:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d8c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d90:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d98:	74 1a                	je     800db4 <strncmp+0x31>
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	0f b6 00             	movzbl (%eax),%eax
  800da0:	84 c0                	test   %al,%al
  800da2:	74 10                	je     800db4 <strncmp+0x31>
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	0f b6 10             	movzbl (%eax),%edx
  800daa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dad:	0f b6 00             	movzbl (%eax),%eax
  800db0:	38 c2                	cmp    %al,%dl
  800db2:	74 d4                	je     800d88 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800db4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db8:	75 07                	jne    800dc1 <strncmp+0x3e>
		return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbf:	eb 16                	jmp    800dd7 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	0f b6 00             	movzbl (%eax),%eax
  800dc7:	0f b6 d0             	movzbl %al,%edx
  800dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcd:	0f b6 00             	movzbl (%eax),%eax
  800dd0:	0f b6 c0             	movzbl %al,%eax
  800dd3:	29 c2                	sub    %eax,%edx
  800dd5:	89 d0                	mov    %edx,%eax
}
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de2:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de5:	eb 14                	jmp    800dfb <strchr+0x22>
		if (*s == c)
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	0f b6 00             	movzbl (%eax),%eax
  800ded:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df0:	75 05                	jne    800df7 <strchr+0x1e>
			return (char *) s;
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	eb 13                	jmp    800e0a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfe:	0f b6 00             	movzbl (%eax),%eax
  800e01:	84 c0                	test   %al,%al
  800e03:	75 e2                	jne    800de7 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0a:	c9                   	leave  
  800e0b:	c3                   	ret    

00800e0c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 04             	sub    $0x4,%esp
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e18:	eb 11                	jmp    800e2b <strfind+0x1f>
		if (*s == c)
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	0f b6 00             	movzbl (%eax),%eax
  800e20:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e23:	75 02                	jne    800e27 <strfind+0x1b>
			break;
  800e25:	eb 0e                	jmp    800e35 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	0f b6 00             	movzbl (%eax),%eax
  800e31:	84 c0                	test   %al,%al
  800e33:	75 e5                	jne    800e1a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e42:	75 05                	jne    800e49 <memset+0xf>
		return v;
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
  800e47:	eb 5c                	jmp    800ea5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	83 e0 03             	and    $0x3,%eax
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	75 41                	jne    800e94 <memset+0x5a>
  800e53:	8b 45 10             	mov    0x10(%ebp),%eax
  800e56:	83 e0 03             	and    $0x3,%eax
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	75 37                	jne    800e94 <memset+0x5a>
		c &= 0xFF;
  800e5d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e67:	c1 e0 18             	shl    $0x18,%eax
  800e6a:	89 c2                	mov    %eax,%edx
  800e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6f:	c1 e0 10             	shl    $0x10,%eax
  800e72:	09 c2                	or     %eax,%edx
  800e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e77:	c1 e0 08             	shl    $0x8,%eax
  800e7a:	09 d0                	or     %edx,%eax
  800e7c:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e82:	c1 e8 02             	shr    $0x2,%eax
  800e85:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	89 d7                	mov    %edx,%edi
  800e8f:	fc                   	cld    
  800e90:	f3 ab                	rep stos %eax,%es:(%edi)
  800e92:	eb 0e                	jmp    800ea2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e94:	8b 55 08             	mov    0x8(%ebp),%edx
  800e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e9d:	89 d7                	mov    %edx,%edi
  800e9f:	fc                   	cld    
  800ea0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec3:	73 6d                	jae    800f32 <memmove+0x8a>
  800ec5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ecb:	01 d0                	add    %edx,%eax
  800ecd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed0:	76 60                	jbe    800f32 <memmove+0x8a>
		s += n;
  800ed2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed5:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ed8:	8b 45 10             	mov    0x10(%ebp),%eax
  800edb:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ede:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee1:	83 e0 03             	and    $0x3,%eax
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	75 2f                	jne    800f17 <memmove+0x6f>
  800ee8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eeb:	83 e0 03             	and    $0x3,%eax
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	75 25                	jne    800f17 <memmove+0x6f>
  800ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef5:	83 e0 03             	and    $0x3,%eax
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	75 1b                	jne    800f17 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eff:	83 e8 04             	sub    $0x4,%eax
  800f02:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f05:	83 ea 04             	sub    $0x4,%edx
  800f08:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f0b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f0e:	89 c7                	mov    %eax,%edi
  800f10:	89 d6                	mov    %edx,%esi
  800f12:	fd                   	std    
  800f13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f15:	eb 18                	jmp    800f2f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f20:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f23:	8b 45 10             	mov    0x10(%ebp),%eax
  800f26:	89 d7                	mov    %edx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	89 c1                	mov    %eax,%ecx
  800f2c:	fd                   	std    
  800f2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f2f:	fc                   	cld    
  800f30:	eb 45                	jmp    800f77 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f35:	83 e0 03             	and    $0x3,%eax
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	75 2b                	jne    800f67 <memmove+0xbf>
  800f3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3f:	83 e0 03             	and    $0x3,%eax
  800f42:	85 c0                	test   %eax,%eax
  800f44:	75 21                	jne    800f67 <memmove+0xbf>
  800f46:	8b 45 10             	mov    0x10(%ebp),%eax
  800f49:	83 e0 03             	and    $0x3,%eax
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	75 17                	jne    800f67 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f50:	8b 45 10             	mov    0x10(%ebp),%eax
  800f53:	c1 e8 02             	shr    $0x2,%eax
  800f56:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f58:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f5e:	89 c7                	mov    %eax,%edi
  800f60:	89 d6                	mov    %edx,%esi
  800f62:	fc                   	cld    
  800f63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f65:	eb 10                	jmp    800f77 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f67:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f70:	89 c7                	mov    %eax,%edi
  800f72:	89 d6                	mov    %edx,%esi
  800f74:	fc                   	cld    
  800f75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f88:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
  800f99:	89 04 24             	mov    %eax,(%esp)
  800f9c:	e8 07 ff ff ff       	call   800ea8 <memmove>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fac:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800faf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fb5:	eb 30                	jmp    800fe7 <memcmp+0x44>
		if (*s1 != *s2)
  800fb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fba:	0f b6 10             	movzbl (%eax),%edx
  800fbd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc0:	0f b6 00             	movzbl (%eax),%eax
  800fc3:	38 c2                	cmp    %al,%dl
  800fc5:	74 18                	je     800fdf <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fca:	0f b6 00             	movzbl (%eax),%eax
  800fcd:	0f b6 d0             	movzbl %al,%edx
  800fd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd3:	0f b6 00             	movzbl (%eax),%eax
  800fd6:	0f b6 c0             	movzbl %al,%eax
  800fd9:	29 c2                	sub    %eax,%edx
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	eb 1a                	jmp    800ff9 <memcmp+0x56>
		s1++, s2++;
  800fdf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fe3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fea:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fed:	89 55 10             	mov    %edx,0x10(%ebp)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	75 c3                	jne    800fb7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801001:	8b 45 10             	mov    0x10(%ebp),%eax
  801004:	8b 55 08             	mov    0x8(%ebp),%edx
  801007:	01 d0                	add    %edx,%eax
  801009:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80100c:	eb 13                	jmp    801021 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80100e:	8b 45 08             	mov    0x8(%ebp),%eax
  801011:	0f b6 10             	movzbl (%eax),%edx
  801014:	8b 45 0c             	mov    0xc(%ebp),%eax
  801017:	38 c2                	cmp    %al,%dl
  801019:	75 02                	jne    80101d <memfind+0x22>
			break;
  80101b:	eb 0c                	jmp    801029 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80101d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801027:	72 e5                	jb     80100e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801034:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80103b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801042:	eb 04                	jmp    801048 <strtol+0x1a>
		s++;
  801044:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801048:	8b 45 08             	mov    0x8(%ebp),%eax
  80104b:	0f b6 00             	movzbl (%eax),%eax
  80104e:	3c 20                	cmp    $0x20,%al
  801050:	74 f2                	je     801044 <strtol+0x16>
  801052:	8b 45 08             	mov    0x8(%ebp),%eax
  801055:	0f b6 00             	movzbl (%eax),%eax
  801058:	3c 09                	cmp    $0x9,%al
  80105a:	74 e8                	je     801044 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	0f b6 00             	movzbl (%eax),%eax
  801062:	3c 2b                	cmp    $0x2b,%al
  801064:	75 06                	jne    80106c <strtol+0x3e>
		s++;
  801066:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80106a:	eb 15                	jmp    801081 <strtol+0x53>
	else if (*s == '-')
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	0f b6 00             	movzbl (%eax),%eax
  801072:	3c 2d                	cmp    $0x2d,%al
  801074:	75 0b                	jne    801081 <strtol+0x53>
		s++, neg = 1;
  801076:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801081:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801085:	74 06                	je     80108d <strtol+0x5f>
  801087:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80108b:	75 24                	jne    8010b1 <strtol+0x83>
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	0f b6 00             	movzbl (%eax),%eax
  801093:	3c 30                	cmp    $0x30,%al
  801095:	75 1a                	jne    8010b1 <strtol+0x83>
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	83 c0 01             	add    $0x1,%eax
  80109d:	0f b6 00             	movzbl (%eax),%eax
  8010a0:	3c 78                	cmp    $0x78,%al
  8010a2:	75 0d                	jne    8010b1 <strtol+0x83>
		s += 2, base = 16;
  8010a4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010a8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010af:	eb 2a                	jmp    8010db <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b5:	75 17                	jne    8010ce <strtol+0xa0>
  8010b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ba:	0f b6 00             	movzbl (%eax),%eax
  8010bd:	3c 30                	cmp    $0x30,%al
  8010bf:	75 0d                	jne    8010ce <strtol+0xa0>
		s++, base = 8;
  8010c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010c5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010cc:	eb 0d                	jmp    8010db <strtol+0xad>
	else if (base == 0)
  8010ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010d2:	75 07                	jne    8010db <strtol+0xad>
		base = 10;
  8010d4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	0f b6 00             	movzbl (%eax),%eax
  8010e1:	3c 2f                	cmp    $0x2f,%al
  8010e3:	7e 1b                	jle    801100 <strtol+0xd2>
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	0f b6 00             	movzbl (%eax),%eax
  8010eb:	3c 39                	cmp    $0x39,%al
  8010ed:	7f 11                	jg     801100 <strtol+0xd2>
			dig = *s - '0';
  8010ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f2:	0f b6 00             	movzbl (%eax),%eax
  8010f5:	0f be c0             	movsbl %al,%eax
  8010f8:	83 e8 30             	sub    $0x30,%eax
  8010fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010fe:	eb 48                	jmp    801148 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	0f b6 00             	movzbl (%eax),%eax
  801106:	3c 60                	cmp    $0x60,%al
  801108:	7e 1b                	jle    801125 <strtol+0xf7>
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	0f b6 00             	movzbl (%eax),%eax
  801110:	3c 7a                	cmp    $0x7a,%al
  801112:	7f 11                	jg     801125 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	0f b6 00             	movzbl (%eax),%eax
  80111a:	0f be c0             	movsbl %al,%eax
  80111d:	83 e8 57             	sub    $0x57,%eax
  801120:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801123:	eb 23                	jmp    801148 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
  801128:	0f b6 00             	movzbl (%eax),%eax
  80112b:	3c 40                	cmp    $0x40,%al
  80112d:	7e 3d                	jle    80116c <strtol+0x13e>
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	0f b6 00             	movzbl (%eax),%eax
  801135:	3c 5a                	cmp    $0x5a,%al
  801137:	7f 33                	jg     80116c <strtol+0x13e>
			dig = *s - 'A' + 10;
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	0f b6 00             	movzbl (%eax),%eax
  80113f:	0f be c0             	movsbl %al,%eax
  801142:	83 e8 37             	sub    $0x37,%eax
  801145:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80114e:	7c 02                	jl     801152 <strtol+0x124>
			break;
  801150:	eb 1a                	jmp    80116c <strtol+0x13e>
		s++, val = (val * base) + dig;
  801152:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801156:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801159:	0f af 45 10          	imul   0x10(%ebp),%eax
  80115d:	89 c2                	mov    %eax,%edx
  80115f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801162:	01 d0                	add    %edx,%eax
  801164:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801167:	e9 6f ff ff ff       	jmp    8010db <strtol+0xad>

	if (endptr)
  80116c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801170:	74 08                	je     80117a <strtol+0x14c>
		*endptr = (char *) s;
  801172:	8b 45 0c             	mov    0xc(%ebp),%eax
  801175:	8b 55 08             	mov    0x8(%ebp),%edx
  801178:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80117a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80117e:	74 07                	je     801187 <strtol+0x159>
  801180:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801183:	f7 d8                	neg    %eax
  801185:	eb 03                	jmp    80118a <strtol+0x15c>
  801187:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80118a:	c9                   	leave  
  80118b:	c3                   	ret    
  80118c:	66 90                	xchg   %ax,%ax
  80118e:	66 90                	xchg   %ax,%ax

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
