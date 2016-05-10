
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 a0 	movl   $0x8014a0,0x802000
  800040:	14 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 c3 01 00 00       	call   80020b <sys_yield>
	}
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800050:	e8 72 01 00 00       	call   8001c7 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	c1 e0 02             	shl    $0x2,%eax
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	c1 e2 05             	shl    $0x5,%edx
  800062:	29 c2                	sub    %eax,%edx
  800064:	89 d0                	mov    %edx,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800070:	8b 45 0c             	mov    0xc(%ebp),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	8b 45 08             	mov    0x8(%ebp),%eax
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 02 00 00 00       	call   800089 <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 e9 00 00 00       	call   800184 <sys_env_destroy>
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8000ac:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000af:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b2:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000b5:	8b 75 20             	mov    0x20(%ebp),%esi
  8000b8:	cd 30                	int    $0x30
  8000ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c1:	74 30                	je     8000f3 <syscall+0x56>
  8000c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c7:	7e 2a                	jle    8000f3 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d7:	c7 44 24 08 af 14 80 	movl   $0x8014af,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e6:	00 
  8000e7:	c7 04 24 cc 14 80 00 	movl   $0x8014cc,(%esp)
  8000ee:	e8 f7 03 00 00       	call   8004ea <_panic>

	return ret;
  8000f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000f6:	83 c4 3c             	add    $0x3c,%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80010e:	00 
  80010f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800116:	00 
  800117:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80011e:	00 
  80011f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800122:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800126:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800131:	00 
  800132:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800139:	e8 5f ff ff ff       	call   80009d <syscall>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <sys_cgetc>:

int
sys_cgetc(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800146:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80014d:	00 
  80014e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800155:	00 
  800156:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80015d:	00 
  80015e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800165:	00 
  800166:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80016d:	00 
  80016e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800175:	00 
  800176:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80017d:	e8 1b ff ff ff       	call   80009d <syscall>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80018a:	8b 45 08             	mov    0x8(%ebp),%eax
  80018d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800194:	00 
  800195:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80019c:	00 
  80019d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ac:	00 
  8001ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c0:	e8 d8 fe ff ff       	call   80009d <syscall>
}
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001cd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d4:	00 
  8001d5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001dc:	00 
  8001dd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f4:	00 
  8001f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001fc:	00 
  8001fd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800204:	e8 94 fe ff ff       	call   80009d <syscall>
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <sys_yield>:

void
sys_yield(void)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800211:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800218:	00 
  800219:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800220:	00 
  800221:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800228:	00 
  800229:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800230:	00 
  800231:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800238:	00 
  800239:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800240:	00 
  800241:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800248:	e8 50 fe ff ff       	call   80009d <syscall>
}
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800255:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025b:	8b 45 08             	mov    0x8(%ebp),%eax
  80025e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800265:	00 
  800266:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80026d:	00 
  80026e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800272:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800289:	e8 0f fe ff ff       	call   80009d <syscall>
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800298:	8b 75 18             	mov    0x18(%ebp),%esi
  80029b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002ab:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002af:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c2:	00 
  8002c3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002ca:	e8 ce fd ff ff       	call   80009d <syscall>
}
  8002cf:	83 c4 20             	add    $0x20,%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002e9:	00 
  8002ea:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002f9:	00 
  8002fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800302:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800309:	00 
  80030a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800311:	e8 87 fd ff ff       	call   80009d <syscall>
}
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80031e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80032b:	00 
  80032c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800333:	00 
  800334:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80033b:	00 
  80033c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800340:	89 44 24 08          	mov    %eax,0x8(%esp)
  800344:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034b:	00 
  80034c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800353:	e8 45 fd ff ff       	call   80009d <syscall>
}
  800358:	c9                   	leave  
  800359:	c3                   	ret    

0080035a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800360:	8b 55 0c             	mov    0xc(%ebp),%edx
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80036d:	00 
  80036e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800375:	00 
  800376:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80037d:	00 
  80037e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800382:	89 44 24 08          	mov    %eax,0x8(%esp)
  800386:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800395:	e8 03 fd ff ff       	call   80009d <syscall>
}
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003a5:	8b 55 10             	mov    0x10(%ebp),%edx
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b2:	00 
  8003b3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003cd:	00 
  8003ce:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003d5:	e8 c3 fc ff ff       	call   80009d <syscall>
}
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ec:	00 
  8003ed:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003f4:	00 
  8003f5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003fc:	00 
  8003fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800404:	00 
  800405:	89 44 24 08          	mov    %eax,0x8(%esp)
  800409:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800410:	00 
  800411:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800418:	e8 80 fc ff ff       	call   80009d <syscall>
}
  80041d:	c9                   	leave  
  80041e:	c3                   	ret    

0080041f <sys_exec>:

void sys_exec(char* buf){
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80042f:	00 
  800430:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800437:	00 
  800438:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80043f:	00 
  800440:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800447:	00 
  800448:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800453:	00 
  800454:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80045b:	e8 3d fc ff ff       	call   80009d <syscall>
}
  800460:	c9                   	leave  
  800461:	c3                   	ret    

00800462 <sys_wait>:

void sys_wait(){
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  800468:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80046f:	00 
  800470:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800477:	00 
  800478:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80047f:	00 
  800480:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800487:	00 
  800488:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80048f:	00 
  800490:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800497:	00 
  800498:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80049f:	e8 f9 fb ff ff       	call   80009d <syscall>
}
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <sys_guest>:

void sys_guest(){
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004ac:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004bb:	00 
  8004bc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004c3:	00 
  8004c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004cb:	00 
  8004cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004d3:	00 
  8004d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004db:	00 
  8004dc:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004e3:	e8 b5 fb ff ff       	call   80009d <syscall>
  8004e8:	c9                   	leave  
  8004e9:	c3                   	ret    

008004ea <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	53                   	push   %ebx
  8004ee:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f4:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004fd:	e8 c5 fc ff ff       	call   8001c7 <sys_getenvid>
  800502:	8b 55 0c             	mov    0xc(%ebp),%edx
  800505:	89 54 24 10          	mov    %edx,0x10(%esp)
  800509:	8b 55 08             	mov    0x8(%ebp),%edx
  80050c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800510:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800514:	89 44 24 04          	mov    %eax,0x4(%esp)
  800518:	c7 04 24 dc 14 80 00 	movl   $0x8014dc,(%esp)
  80051f:	e8 e1 00 00 00       	call   800605 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800524:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052b:	8b 45 10             	mov    0x10(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 6b 00 00 00       	call   8005a1 <vcprintf>
	cprintf("\n");
  800536:	c7 04 24 ff 14 80 00 	movl   $0x8014ff,(%esp)
  80053d:	e8 c3 00 00 00       	call   800605 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800542:	cc                   	int3   
  800543:	eb fd                	jmp    800542 <_panic+0x58>

00800545 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	8d 48 01             	lea    0x1(%eax),%ecx
  800553:	8b 55 0c             	mov    0xc(%ebp),%edx
  800556:	89 0a                	mov    %ecx,(%edx)
  800558:	8b 55 08             	mov    0x8(%ebp),%edx
  80055b:	89 d1                	mov    %edx,%ecx
  80055d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800560:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800564:	8b 45 0c             	mov    0xc(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	3d ff 00 00 00       	cmp    $0xff,%eax
  80056e:	75 20                	jne    800590 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800570:	8b 45 0c             	mov    0xc(%ebp),%eax
  800573:	8b 00                	mov    (%eax),%eax
  800575:	8b 55 0c             	mov    0xc(%ebp),%edx
  800578:	83 c2 08             	add    $0x8,%edx
  80057b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057f:	89 14 24             	mov    %edx,(%esp)
  800582:	e8 77 fb ff ff       	call   8000fe <sys_cputs>
		b->idx = 0;
  800587:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800590:	8b 45 0c             	mov    0xc(%ebp),%eax
  800593:	8b 40 04             	mov    0x4(%eax),%eax
  800596:	8d 50 01             	lea    0x1(%eax),%edx
  800599:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    

008005a1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005aa:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005b1:	00 00 00 
	b.cnt = 0;
  8005b4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005bb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005cc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d6:	c7 04 24 45 05 80 00 	movl   $0x800545,(%esp)
  8005dd:	e8 bd 01 00 00       	call   80079f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005e2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005f2:	83 c0 08             	add    $0x8,%eax
  8005f5:	89 04 24             	mov    %eax,(%esp)
  8005f8:	e8 01 fb ff ff       	call   8000fe <sys_cputs>

	return b.cnt;
  8005fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800603:	c9                   	leave  
  800604:	c3                   	ret    

00800605 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80060b:	8d 45 0c             	lea    0xc(%ebp),%eax
  80060e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	e8 7e ff ff ff       	call   8005a1 <vcprintf>
  800623:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800626:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800629:	c9                   	leave  
  80062a:	c3                   	ret    

0080062b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 34             	sub    $0x34,%esp
  800632:	8b 45 10             	mov    0x10(%ebp),%eax
  800635:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80063e:	8b 45 18             	mov    0x18(%ebp),%eax
  800641:	ba 00 00 00 00       	mov    $0x0,%edx
  800646:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800649:	77 72                	ja     8006bd <printnum+0x92>
  80064b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80064e:	72 05                	jb     800655 <printnum+0x2a>
  800650:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800653:	77 68                	ja     8006bd <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800655:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800658:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80065b:	8b 45 18             	mov    0x18(%ebp),%eax
  80065e:	ba 00 00 00 00       	mov    $0x0,%edx
  800663:	89 44 24 08          	mov    %eax,0x8(%esp)
  800667:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80066b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	89 54 24 04          	mov    %edx,0x4(%esp)
  800678:	e8 93 0b 00 00       	call   801210 <__udivdi3>
  80067d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800680:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800684:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800688:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80068b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80068f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 82 ff ff ff       	call   80062b <printnum>
  8006a9:	eb 1c                	jmp    8006c7 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b2:	8b 45 20             	mov    0x20(%ebp),%eax
  8006b5:	89 04 24             	mov    %eax,(%esp)
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006bd:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006c1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006c5:	7f e4                	jg     8006ab <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006c7:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e4:	e8 57 0c 00 00       	call   801340 <__umoddi3>
  8006e9:	05 e8 15 80 00       	add    $0x8015e8,%eax
  8006ee:	0f b6 00             	movzbl (%eax),%eax
  8006f1:	0f be c0             	movsbl %al,%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006fb:	89 04 24             	mov    %eax,(%esp)
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	ff d0                	call   *%eax
}
  800703:	83 c4 34             	add    $0x34,%esp
  800706:	5b                   	pop    %ebx
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80070c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800710:	7e 14                	jle    800726 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	8b 00                	mov    (%eax),%eax
  800717:	8d 48 08             	lea    0x8(%eax),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	89 0a                	mov    %ecx,(%edx)
  80071f:	8b 50 04             	mov    0x4(%eax),%edx
  800722:	8b 00                	mov    (%eax),%eax
  800724:	eb 30                	jmp    800756 <getuint+0x4d>
	else if (lflag)
  800726:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80072a:	74 16                	je     800742 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	8d 48 04             	lea    0x4(%eax),%ecx
  800734:	8b 55 08             	mov    0x8(%ebp),%edx
  800737:	89 0a                	mov    %ecx,(%edx)
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	ba 00 00 00 00       	mov    $0x0,%edx
  800740:	eb 14                	jmp    800756 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 00                	mov    (%eax),%eax
  800747:	8d 48 04             	lea    0x4(%eax),%ecx
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
  80074d:	89 0a                	mov    %ecx,(%edx)
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80075b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80075f:	7e 14                	jle    800775 <getint+0x1d>
		return va_arg(*ap, long long);
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 00                	mov    (%eax),%eax
  800766:	8d 48 08             	lea    0x8(%eax),%ecx
  800769:	8b 55 08             	mov    0x8(%ebp),%edx
  80076c:	89 0a                	mov    %ecx,(%edx)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	eb 28                	jmp    80079d <getint+0x45>
	else if (lflag)
  800775:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800779:	74 12                	je     80078d <getint+0x35>
		return va_arg(*ap, long);
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	8d 48 04             	lea    0x4(%eax),%ecx
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
  800786:	89 0a                	mov    %ecx,(%edx)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	99                   	cltd   
  80078b:	eb 10                	jmp    80079d <getint+0x45>
	else
		return va_arg(*ap, int);
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	8b 00                	mov    (%eax),%eax
  800792:	8d 48 04             	lea    0x4(%eax),%ecx
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
  800798:	89 0a                	mov    %ecx,(%edx)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	99                   	cltd   
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a7:	eb 18                	jmp    8007c1 <vprintfmt+0x22>
			if (ch == '\0')
  8007a9:	85 db                	test   %ebx,%ebx
  8007ab:	75 05                	jne    8007b2 <vprintfmt+0x13>
				return;
  8007ad:	e9 cc 03 00 00       	jmp    800b7e <vprintfmt+0x3df>
			putch(ch, putdat);
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	89 1c 24             	mov    %ebx,(%esp)
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c4:	8d 50 01             	lea    0x1(%eax),%edx
  8007c7:	89 55 10             	mov    %edx,0x10(%ebp)
  8007ca:	0f b6 00             	movzbl (%eax),%eax
  8007cd:	0f b6 d8             	movzbl %al,%ebx
  8007d0:	83 fb 25             	cmp    $0x25,%ebx
  8007d3:	75 d4                	jne    8007a9 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007d5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007d9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007e7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	8d 50 01             	lea    0x1(%eax),%edx
  8007fb:	89 55 10             	mov    %edx,0x10(%ebp)
  8007fe:	0f b6 00             	movzbl (%eax),%eax
  800801:	0f b6 d8             	movzbl %al,%ebx
  800804:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800807:	83 f8 55             	cmp    $0x55,%eax
  80080a:	0f 87 3d 03 00 00    	ja     800b4d <vprintfmt+0x3ae>
  800810:	8b 04 85 0c 16 80 00 	mov    0x80160c(,%eax,4),%eax
  800817:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800819:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80081d:	eb d6                	jmp    8007f5 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80081f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800823:	eb d0                	jmp    8007f5 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800825:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80082c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80082f:	89 d0                	mov    %edx,%eax
  800831:	c1 e0 02             	shl    $0x2,%eax
  800834:	01 d0                	add    %edx,%eax
  800836:	01 c0                	add    %eax,%eax
  800838:	01 d8                	add    %ebx,%eax
  80083a:	83 e8 30             	sub    $0x30,%eax
  80083d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800840:	8b 45 10             	mov    0x10(%ebp),%eax
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800849:	83 fb 2f             	cmp    $0x2f,%ebx
  80084c:	7e 0b                	jle    800859 <vprintfmt+0xba>
  80084e:	83 fb 39             	cmp    $0x39,%ebx
  800851:	7f 06                	jg     800859 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800853:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800857:	eb d3                	jmp    80082c <vprintfmt+0x8d>
			goto process_precision;
  800859:	eb 33                	jmp    80088e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 50 04             	lea    0x4(%eax),%edx
  800861:	89 55 14             	mov    %edx,0x14(%ebp)
  800864:	8b 00                	mov    (%eax),%eax
  800866:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800869:	eb 23                	jmp    80088e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80086b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80086f:	79 0c                	jns    80087d <vprintfmt+0xde>
				width = 0;
  800871:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800878:	e9 78 ff ff ff       	jmp    8007f5 <vprintfmt+0x56>
  80087d:	e9 73 ff ff ff       	jmp    8007f5 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800882:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800889:	e9 67 ff ff ff       	jmp    8007f5 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80088e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800892:	79 12                	jns    8008a6 <vprintfmt+0x107>
				width = precision, precision = -1;
  800894:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800897:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80089a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8008a1:	e9 4f ff ff ff       	jmp    8007f5 <vprintfmt+0x56>
  8008a6:	e9 4a ff ff ff       	jmp    8007f5 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ab:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008af:	e9 41 ff ff ff       	jmp    8007f5 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 50 04             	lea    0x4(%eax),%edx
  8008ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bd:	8b 00                	mov    (%eax),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	ff d0                	call   *%eax
			break;
  8008ce:	e9 a5 02 00 00       	jmp    800b78 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d6:	8d 50 04             	lea    0x4(%eax),%edx
  8008d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008dc:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008de:	85 db                	test   %ebx,%ebx
  8008e0:	79 02                	jns    8008e4 <vprintfmt+0x145>
				err = -err;
  8008e2:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008e4:	83 fb 09             	cmp    $0x9,%ebx
  8008e7:	7f 0b                	jg     8008f4 <vprintfmt+0x155>
  8008e9:	8b 34 9d c0 15 80 00 	mov    0x8015c0(,%ebx,4),%esi
  8008f0:	85 f6                	test   %esi,%esi
  8008f2:	75 23                	jne    800917 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008f8:	c7 44 24 08 f9 15 80 	movl   $0x8015f9,0x8(%esp)
  8008ff:	00 
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	89 44 24 04          	mov    %eax,0x4(%esp)
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	89 04 24             	mov    %eax,(%esp)
  80090d:	e8 73 02 00 00       	call   800b85 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800912:	e9 61 02 00 00       	jmp    800b78 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800917:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80091b:	c7 44 24 08 02 16 80 	movl   $0x801602,0x8(%esp)
  800922:	00 
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	89 04 24             	mov    %eax,(%esp)
  800930:	e8 50 02 00 00       	call   800b85 <printfmt>
			break;
  800935:	e9 3e 02 00 00       	jmp    800b78 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8d 50 04             	lea    0x4(%eax),%edx
  800940:	89 55 14             	mov    %edx,0x14(%ebp)
  800943:	8b 30                	mov    (%eax),%esi
  800945:	85 f6                	test   %esi,%esi
  800947:	75 05                	jne    80094e <vprintfmt+0x1af>
				p = "(null)";
  800949:	be 05 16 80 00       	mov    $0x801605,%esi
			if (width > 0 && padc != '-')
  80094e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800952:	7e 37                	jle    80098b <vprintfmt+0x1ec>
  800954:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800958:	74 31                	je     80098b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80095a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	89 34 24             	mov    %esi,(%esp)
  800964:	e8 39 03 00 00       	call   800ca2 <strnlen>
  800969:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80096c:	eb 17                	jmp    800985 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80096e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 54 24 04          	mov    %edx,0x4(%esp)
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800981:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800985:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800989:	7f e3                	jg     80096e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80098b:	eb 38                	jmp    8009c5 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80098d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800991:	74 1f                	je     8009b2 <vprintfmt+0x213>
  800993:	83 fb 1f             	cmp    $0x1f,%ebx
  800996:	7e 05                	jle    80099d <vprintfmt+0x1fe>
  800998:	83 fb 7e             	cmp    $0x7e,%ebx
  80099b:	7e 15                	jle    8009b2 <vprintfmt+0x213>
					putch('?', putdat);
  80099d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	ff d0                	call   *%eax
  8009b0:	eb 0f                	jmp    8009c1 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b9:	89 1c 24             	mov    %ebx,(%esp)
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009c5:	89 f0                	mov    %esi,%eax
  8009c7:	8d 70 01             	lea    0x1(%eax),%esi
  8009ca:	0f b6 00             	movzbl (%eax),%eax
  8009cd:	0f be d8             	movsbl %al,%ebx
  8009d0:	85 db                	test   %ebx,%ebx
  8009d2:	74 10                	je     8009e4 <vprintfmt+0x245>
  8009d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009d8:	78 b3                	js     80098d <vprintfmt+0x1ee>
  8009da:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009e2:	79 a9                	jns    80098d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e4:	eb 17                	jmp    8009fd <vprintfmt+0x25e>
				putch(' ', putdat);
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ed:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009f9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a01:	7f e3                	jg     8009e6 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800a03:	e9 70 01 00 00       	jmp    800b78 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 3e fd ff ff       	call   800758 <getint>
  800a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a26:	85 d2                	test   %edx,%edx
  800a28:	79 26                	jns    800a50 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a31:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	ff d0                	call   *%eax
				num = -(long long) num;
  800a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a43:	f7 d8                	neg    %eax
  800a45:	83 d2 00             	adc    $0x0,%edx
  800a48:	f7 da                	neg    %edx
  800a4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a4d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a50:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a57:	e9 a8 00 00 00       	jmp    800b04 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a63:	8d 45 14             	lea    0x14(%ebp),%eax
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 9b fc ff ff       	call   800709 <getuint>
  800a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a71:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a74:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a7b:	e9 84 00 00 00       	jmp    800b04 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a80:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a87:	8d 45 14             	lea    0x14(%ebp),%eax
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	e8 77 fc ff ff       	call   800709 <getuint>
  800a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a95:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a98:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a9f:	eb 63                	jmp    800b04 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	ff d0                	call   *%eax
			putch('x', putdat);
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abb:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aca:	8d 50 04             	lea    0x4(%eax),%edx
  800acd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad0:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ad5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800adc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ae3:	eb 1f                	jmp    800b04 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ae5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aec:	8d 45 14             	lea    0x14(%ebp),%eax
  800aef:	89 04 24             	mov    %eax,(%esp)
  800af2:	e8 12 fc ff ff       	call   800709 <getuint>
  800af7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800afa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800afd:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b04:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0b:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b12:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b16:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b24:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	89 04 24             	mov    %eax,(%esp)
  800b35:	e8 f1 fa ff ff       	call   80062b <printnum>
			break;
  800b3a:	eb 3c                	jmp    800b78 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b43:	89 1c 24             	mov    %ebx,(%esp)
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	ff d0                	call   *%eax
			break;
  800b4b:	eb 2b                	jmp    800b78 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b54:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b64:	eb 04                	jmp    800b6a <vprintfmt+0x3cb>
  800b66:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6d:	83 e8 01             	sub    $0x1,%eax
  800b70:	0f b6 00             	movzbl (%eax),%eax
  800b73:	3c 25                	cmp    $0x25,%al
  800b75:	75 ef                	jne    800b66 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b77:	90                   	nop
		}
	}
  800b78:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b79:	e9 43 fc ff ff       	jmp    8007c1 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b7e:	83 c4 40             	add    $0x40,%esp
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b8b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b94:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b98:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	89 04 24             	mov    %eax,(%esp)
  800bac:	e8 ee fb ff ff       	call   80079f <vprintfmt>
	va_end(ap);
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	8b 40 08             	mov    0x8(%eax),%eax
  800bbc:	8d 50 01             	lea    0x1(%eax),%edx
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc2:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc8:	8b 10                	mov    (%eax),%edx
  800bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcd:	8b 40 04             	mov    0x4(%eax),%eax
  800bd0:	39 c2                	cmp    %eax,%edx
  800bd2:	73 12                	jae    800be6 <sprintputch+0x33>
		*b->buf++ = ch;
  800bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd7:	8b 00                	mov    (%eax),%eax
  800bd9:	8d 48 01             	lea    0x1(%eax),%ecx
  800bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdf:	89 0a                	mov    %ecx,(%edx)
  800be1:	8b 55 08             	mov    0x8(%ebp),%edx
  800be4:	88 10                	mov    %dl,(%eax)
}
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	01 d0                	add    %edx,%eax
  800bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c0d:	74 06                	je     800c15 <vsnprintf+0x2d>
  800c0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c13:	7f 07                	jg     800c1c <vsnprintf+0x34>
		return -E_INVAL;
  800c15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c1a:	eb 2a                	jmp    800c46 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c23:	8b 45 10             	mov    0x10(%ebp),%eax
  800c26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c31:	c7 04 24 b3 0b 80 00 	movl   $0x800bb3,(%esp)
  800c38:	e8 62 fb ff ff       	call   80079f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c40:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c4e:	8d 45 14             	lea    0x14(%ebp),%eax
  800c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	89 04 24             	mov    %eax,(%esp)
  800c6f:	e8 74 ff ff ff       	call   800be8 <vsnprintf>
  800c74:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c82:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c89:	eb 08                	jmp    800c93 <strlen+0x17>
		n++;
  800c8b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	0f b6 00             	movzbl (%eax),%eax
  800c99:	84 c0                	test   %al,%al
  800c9b:	75 ee                	jne    800c8b <strlen+0xf>
		n++;
	return n;
  800c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800caf:	eb 0c                	jmp    800cbd <strnlen+0x1b>
		n++;
  800cb1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cb5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb9:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc1:	74 0a                	je     800ccd <strnlen+0x2b>
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	0f b6 00             	movzbl (%eax),%eax
  800cc9:	84 c0                	test   %al,%al
  800ccb:	75 e4                	jne    800cb1 <strnlen+0xf>
		n++;
	return n;
  800ccd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    

00800cd2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800cde:	90                   	nop
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	8d 50 01             	lea    0x1(%eax),%edx
  800ce5:	89 55 08             	mov    %edx,0x8(%ebp)
  800ce8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ceb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cee:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cf1:	0f b6 12             	movzbl (%edx),%edx
  800cf4:	88 10                	mov    %dl,(%eax)
  800cf6:	0f b6 00             	movzbl (%eax),%eax
  800cf9:	84 c0                	test   %al,%al
  800cfb:	75 e2                	jne    800cdf <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	89 04 24             	mov    %eax,(%esp)
  800d0e:	e8 69 ff ff ff       	call   800c7c <strlen>
  800d13:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d16:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	01 c2                	add    %eax,%edx
  800d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d25:	89 14 24             	mov    %edx,(%esp)
  800d28:	e8 a5 ff ff ff       	call   800cd2 <strcpy>
	return dst;
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d30:	c9                   	leave  
  800d31:	c3                   	ret    

00800d32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d45:	eb 23                	jmp    800d6a <strncpy+0x38>
		*dst++ = *src;
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8d 50 01             	lea    0x1(%eax),%edx
  800d4d:	89 55 08             	mov    %edx,0x8(%ebp)
  800d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d53:	0f b6 12             	movzbl (%edx),%edx
  800d56:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	84 c0                	test   %al,%al
  800d60:	74 04                	je     800d66 <strncpy+0x34>
			src++;
  800d62:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d66:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d6d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d70:	72 d5                	jb     800d47 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d72:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    

00800d77 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d87:	74 33                	je     800dbc <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d89:	eb 17                	jmp    800da2 <strlcpy+0x2b>
			*dst++ = *src++;
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	8d 50 01             	lea    0x1(%eax),%edx
  800d91:	89 55 08             	mov    %edx,0x8(%ebp)
  800d94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d97:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d9a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d9d:	0f b6 12             	movzbl (%edx),%edx
  800da0:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800da2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800da6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800daa:	74 0a                	je     800db6 <strlcpy+0x3f>
  800dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daf:	0f b6 00             	movzbl (%eax),%eax
  800db2:	84 c0                	test   %al,%al
  800db4:	75 d5                	jne    800d8b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dc2:	29 c2                	sub    %eax,%edx
  800dc4:	89 d0                	mov    %edx,%eax
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dcb:	eb 08                	jmp    800dd5 <strcmp+0xd>
		p++, q++;
  800dcd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	0f b6 00             	movzbl (%eax),%eax
  800ddb:	84 c0                	test   %al,%al
  800ddd:	74 10                	je     800def <strcmp+0x27>
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 10             	movzbl (%eax),%edx
  800de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de8:	0f b6 00             	movzbl (%eax),%eax
  800deb:	38 c2                	cmp    %al,%dl
  800ded:	74 de                	je     800dcd <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	0f b6 00             	movzbl (%eax),%eax
  800df5:	0f b6 d0             	movzbl %al,%edx
  800df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfb:	0f b6 00             	movzbl (%eax),%eax
  800dfe:	0f b6 c0             	movzbl %al,%eax
  800e01:	29 c2                	sub    %eax,%edx
  800e03:	89 d0                	mov    %edx,%eax
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e0a:	eb 0c                	jmp    800e18 <strncmp+0x11>
		n--, p++, q++;
  800e0c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e14:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e1c:	74 1a                	je     800e38 <strncmp+0x31>
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	0f b6 00             	movzbl (%eax),%eax
  800e24:	84 c0                	test   %al,%al
  800e26:	74 10                	je     800e38 <strncmp+0x31>
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	0f b6 10             	movzbl (%eax),%edx
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	0f b6 00             	movzbl (%eax),%eax
  800e34:	38 c2                	cmp    %al,%dl
  800e36:	74 d4                	je     800e0c <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e3c:	75 07                	jne    800e45 <strncmp+0x3e>
		return 0;
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e43:	eb 16                	jmp    800e5b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	0f b6 00             	movzbl (%eax),%eax
  800e4b:	0f b6 d0             	movzbl %al,%edx
  800e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e51:	0f b6 00             	movzbl (%eax),%eax
  800e54:	0f b6 c0             	movzbl %al,%eax
  800e57:	29 c2                	sub    %eax,%edx
  800e59:	89 d0                	mov    %edx,%eax
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 04             	sub    $0x4,%esp
  800e63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e66:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e69:	eb 14                	jmp    800e7f <strchr+0x22>
		if (*s == c)
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	0f b6 00             	movzbl (%eax),%eax
  800e71:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e74:	75 05                	jne    800e7b <strchr+0x1e>
			return (char *) s;
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	eb 13                	jmp    800e8e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e7b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	0f b6 00             	movzbl (%eax),%eax
  800e85:	84 c0                	test   %al,%al
  800e87:	75 e2                	jne    800e6b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e99:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e9c:	eb 11                	jmp    800eaf <strfind+0x1f>
		if (*s == c)
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	0f b6 00             	movzbl (%eax),%eax
  800ea4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ea7:	75 02                	jne    800eab <strfind+0x1b>
			break;
  800ea9:	eb 0e                	jmp    800eb9 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	0f b6 00             	movzbl (%eax),%eax
  800eb5:	84 c0                	test   %al,%al
  800eb7:	75 e5                	jne    800e9e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ec2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ec6:	75 05                	jne    800ecd <memset+0xf>
		return v;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	eb 5c                	jmp    800f29 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	83 e0 03             	and    $0x3,%eax
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	75 41                	jne    800f18 <memset+0x5a>
  800ed7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eda:	83 e0 03             	and    $0x3,%eax
  800edd:	85 c0                	test   %eax,%eax
  800edf:	75 37                	jne    800f18 <memset+0x5a>
		c &= 0xFF;
  800ee1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eeb:	c1 e0 18             	shl    $0x18,%eax
  800eee:	89 c2                	mov    %eax,%edx
  800ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef3:	c1 e0 10             	shl    $0x10,%eax
  800ef6:	09 c2                	or     %eax,%edx
  800ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efb:	c1 e0 08             	shl    $0x8,%eax
  800efe:	09 d0                	or     %edx,%eax
  800f00:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f03:	8b 45 10             	mov    0x10(%ebp),%eax
  800f06:	c1 e8 02             	shr    $0x2,%eax
  800f09:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f11:	89 d7                	mov    %edx,%edi
  800f13:	fc                   	cld    
  800f14:	f3 ab                	rep stos %eax,%es:(%edi)
  800f16:	eb 0e                	jmp    800f26 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f21:	89 d7                	mov    %edx,%edi
  800f23:	fc                   	cld    
  800f24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f26:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f38:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f44:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f47:	73 6d                	jae    800fb6 <memmove+0x8a>
  800f49:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f4f:	01 d0                	add    %edx,%eax
  800f51:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f54:	76 60                	jbe    800fb6 <memmove+0x8a>
		s += n;
  800f56:	8b 45 10             	mov    0x10(%ebp),%eax
  800f59:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f65:	83 e0 03             	and    $0x3,%eax
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	75 2f                	jne    800f9b <memmove+0x6f>
  800f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6f:	83 e0 03             	and    $0x3,%eax
  800f72:	85 c0                	test   %eax,%eax
  800f74:	75 25                	jne    800f9b <memmove+0x6f>
  800f76:	8b 45 10             	mov    0x10(%ebp),%eax
  800f79:	83 e0 03             	and    $0x3,%eax
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	75 1b                	jne    800f9b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f83:	83 e8 04             	sub    $0x4,%eax
  800f86:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f89:	83 ea 04             	sub    $0x4,%edx
  800f8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f8f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	89 d6                	mov    %edx,%esi
  800f96:	fd                   	std    
  800f97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f99:	eb 18                	jmp    800fb3 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f9e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa4:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fa7:	8b 45 10             	mov    0x10(%ebp),%eax
  800faa:	89 d7                	mov    %edx,%edi
  800fac:	89 de                	mov    %ebx,%esi
  800fae:	89 c1                	mov    %eax,%ecx
  800fb0:	fd                   	std    
  800fb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb3:	fc                   	cld    
  800fb4:	eb 45                	jmp    800ffb <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb9:	83 e0 03             	and    $0x3,%eax
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	75 2b                	jne    800feb <memmove+0xbf>
  800fc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fc3:	83 e0 03             	and    $0x3,%eax
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	75 21                	jne    800feb <memmove+0xbf>
  800fca:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcd:	83 e0 03             	and    $0x3,%eax
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	75 17                	jne    800feb <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd7:	c1 e8 02             	shr    $0x2,%eax
  800fda:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fdf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe2:	89 c7                	mov    %eax,%edi
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	fc                   	cld    
  800fe7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fe9:	eb 10                	jmp    800ffb <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800feb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fee:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ff4:	89 c7                	mov    %eax,%edi
  800ff6:	89 d6                	mov    %edx,%esi
  800ff8:	fc                   	cld    
  800ff9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80100c:	8b 45 10             	mov    0x10(%ebp),%eax
  80100f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801013:	8b 45 0c             	mov    0xc(%ebp),%eax
  801016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	e8 07 ff ff ff       	call   800f2c <memmove>
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  80102d:	8b 45 08             	mov    0x8(%ebp),%eax
  801030:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801033:	8b 45 0c             	mov    0xc(%ebp),%eax
  801036:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801039:	eb 30                	jmp    80106b <memcmp+0x44>
		if (*s1 != *s2)
  80103b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80103e:	0f b6 10             	movzbl (%eax),%edx
  801041:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801044:	0f b6 00             	movzbl (%eax),%eax
  801047:	38 c2                	cmp    %al,%dl
  801049:	74 18                	je     801063 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80104b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80104e:	0f b6 00             	movzbl (%eax),%eax
  801051:	0f b6 d0             	movzbl %al,%edx
  801054:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801057:	0f b6 00             	movzbl (%eax),%eax
  80105a:	0f b6 c0             	movzbl %al,%eax
  80105d:	29 c2                	sub    %eax,%edx
  80105f:	89 d0                	mov    %edx,%eax
  801061:	eb 1a                	jmp    80107d <memcmp+0x56>
		s1++, s2++;
  801063:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801067:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80106b:	8b 45 10             	mov    0x10(%ebp),%eax
  80106e:	8d 50 ff             	lea    -0x1(%eax),%edx
  801071:	89 55 10             	mov    %edx,0x10(%ebp)
  801074:	85 c0                	test   %eax,%eax
  801076:	75 c3                	jne    80103b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801085:	8b 45 10             	mov    0x10(%ebp),%eax
  801088:	8b 55 08             	mov    0x8(%ebp),%edx
  80108b:	01 d0                	add    %edx,%eax
  80108d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801090:	eb 13                	jmp    8010a5 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	0f b6 10             	movzbl (%eax),%edx
  801098:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109b:	38 c2                	cmp    %al,%dl
  80109d:	75 02                	jne    8010a1 <memfind+0x22>
			break;
  80109f:	eb 0c                	jmp    8010ad <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010a1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8010ab:	72 e5                	jb     801092 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010ad:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010bf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010c6:	eb 04                	jmp    8010cc <strtol+0x1a>
		s++;
  8010c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	0f b6 00             	movzbl (%eax),%eax
  8010d2:	3c 20                	cmp    $0x20,%al
  8010d4:	74 f2                	je     8010c8 <strtol+0x16>
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	0f b6 00             	movzbl (%eax),%eax
  8010dc:	3c 09                	cmp    $0x9,%al
  8010de:	74 e8                	je     8010c8 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	0f b6 00             	movzbl (%eax),%eax
  8010e6:	3c 2b                	cmp    $0x2b,%al
  8010e8:	75 06                	jne    8010f0 <strtol+0x3e>
		s++;
  8010ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ee:	eb 15                	jmp    801105 <strtol+0x53>
	else if (*s == '-')
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	0f b6 00             	movzbl (%eax),%eax
  8010f6:	3c 2d                	cmp    $0x2d,%al
  8010f8:	75 0b                	jne    801105 <strtol+0x53>
		s++, neg = 1;
  8010fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010fe:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801105:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801109:	74 06                	je     801111 <strtol+0x5f>
  80110b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80110f:	75 24                	jne    801135 <strtol+0x83>
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	0f b6 00             	movzbl (%eax),%eax
  801117:	3c 30                	cmp    $0x30,%al
  801119:	75 1a                	jne    801135 <strtol+0x83>
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	83 c0 01             	add    $0x1,%eax
  801121:	0f b6 00             	movzbl (%eax),%eax
  801124:	3c 78                	cmp    $0x78,%al
  801126:	75 0d                	jne    801135 <strtol+0x83>
		s += 2, base = 16;
  801128:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80112c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801133:	eb 2a                	jmp    80115f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801135:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801139:	75 17                	jne    801152 <strtol+0xa0>
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	0f b6 00             	movzbl (%eax),%eax
  801141:	3c 30                	cmp    $0x30,%al
  801143:	75 0d                	jne    801152 <strtol+0xa0>
		s++, base = 8;
  801145:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801149:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801150:	eb 0d                	jmp    80115f <strtol+0xad>
	else if (base == 0)
  801152:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801156:	75 07                	jne    80115f <strtol+0xad>
		base = 10;
  801158:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	0f b6 00             	movzbl (%eax),%eax
  801165:	3c 2f                	cmp    $0x2f,%al
  801167:	7e 1b                	jle    801184 <strtol+0xd2>
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	0f b6 00             	movzbl (%eax),%eax
  80116f:	3c 39                	cmp    $0x39,%al
  801171:	7f 11                	jg     801184 <strtol+0xd2>
			dig = *s - '0';
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	0f b6 00             	movzbl (%eax),%eax
  801179:	0f be c0             	movsbl %al,%eax
  80117c:	83 e8 30             	sub    $0x30,%eax
  80117f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801182:	eb 48                	jmp    8011cc <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	0f b6 00             	movzbl (%eax),%eax
  80118a:	3c 60                	cmp    $0x60,%al
  80118c:	7e 1b                	jle    8011a9 <strtol+0xf7>
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	0f b6 00             	movzbl (%eax),%eax
  801194:	3c 7a                	cmp    $0x7a,%al
  801196:	7f 11                	jg     8011a9 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	0f b6 00             	movzbl (%eax),%eax
  80119e:	0f be c0             	movsbl %al,%eax
  8011a1:	83 e8 57             	sub    $0x57,%eax
  8011a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011a7:	eb 23                	jmp    8011cc <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8011a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ac:	0f b6 00             	movzbl (%eax),%eax
  8011af:	3c 40                	cmp    $0x40,%al
  8011b1:	7e 3d                	jle    8011f0 <strtol+0x13e>
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	0f b6 00             	movzbl (%eax),%eax
  8011b9:	3c 5a                	cmp    $0x5a,%al
  8011bb:	7f 33                	jg     8011f0 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	0f b6 00             	movzbl (%eax),%eax
  8011c3:	0f be c0             	movsbl %al,%eax
  8011c6:	83 e8 37             	sub    $0x37,%eax
  8011c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cf:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011d2:	7c 02                	jl     8011d6 <strtol+0x124>
			break;
  8011d4:	eb 1a                	jmp    8011f0 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011d6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011da:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011dd:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e6:	01 d0                	add    %edx,%eax
  8011e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011eb:	e9 6f ff ff ff       	jmp    80115f <strtol+0xad>

	if (endptr)
  8011f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011f4:	74 08                	je     8011fe <strtol+0x14c>
		*endptr = (char *) s;
  8011f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011fe:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801202:	74 07                	je     80120b <strtol+0x159>
  801204:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801207:	f7 d8                	neg    %eax
  801209:	eb 03                	jmp    80120e <strtol+0x15c>
  80120b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

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
