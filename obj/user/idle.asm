
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
  800039:	c7 05 00 20 80 00 60 	movl   $0x801460,0x802000
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
  8000d7:	c7 44 24 08 6f 14 80 	movl   $0x80146f,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e6:	00 
  8000e7:	c7 04 24 8c 14 80 00 	movl   $0x80148c,(%esp)
  8000ee:	e8 b3 03 00 00       	call   8004a6 <_panic>

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
  8004a4:	c9                   	leave  
  8004a5:	c3                   	ret    

008004a6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8004b0:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004b3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004b9:	e8 09 fd ff ff       	call   8001c7 <sys_getenvid>
  8004be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d4:	c7 04 24 9c 14 80 00 	movl   $0x80149c,(%esp)
  8004db:	e8 e1 00 00 00       	call   8005c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	e8 6b 00 00 00       	call   80055d <vcprintf>
	cprintf("\n");
  8004f2:	c7 04 24 bf 14 80 00 	movl   $0x8014bf,(%esp)
  8004f9:	e8 c3 00 00 00       	call   8005c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004fe:	cc                   	int3   
  8004ff:	eb fd                	jmp    8004fe <_panic+0x58>

00800501 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800507:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	8d 48 01             	lea    0x1(%eax),%ecx
  80050f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800512:	89 0a                	mov    %ecx,(%edx)
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 d1                	mov    %edx,%ecx
  800519:	8b 55 0c             	mov    0xc(%ebp),%edx
  80051c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800520:	8b 45 0c             	mov    0xc(%ebp),%eax
  800523:	8b 00                	mov    (%eax),%eax
  800525:	3d ff 00 00 00       	cmp    $0xff,%eax
  80052a:	75 20                	jne    80054c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80052c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	8b 55 0c             	mov    0xc(%ebp),%edx
  800534:	83 c2 08             	add    $0x8,%edx
  800537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053b:	89 14 24             	mov    %edx,(%esp)
  80053e:	e8 bb fb ff ff       	call   8000fe <sys_cputs>
		b->idx = 0;
  800543:	8b 45 0c             	mov    0xc(%ebp),%eax
  800546:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80054c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054f:	8b 40 04             	mov    0x4(%eax),%eax
  800552:	8d 50 01             	lea    0x1(%eax),%edx
  800555:	8b 45 0c             	mov    0xc(%ebp),%eax
  800558:	89 50 04             	mov    %edx,0x4(%eax)
}
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800566:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80056d:	00 00 00 
	b.cnt = 0;
  800570:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800577:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80057a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800581:	8b 45 08             	mov    0x8(%ebp),%eax
  800584:	89 44 24 08          	mov    %eax,0x8(%esp)
  800588:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80058e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800592:	c7 04 24 01 05 80 00 	movl   $0x800501,(%esp)
  800599:	e8 bd 01 00 00       	call   80075b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80059e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005ae:	83 c0 08             	add    $0x8,%eax
  8005b1:	89 04 24             	mov    %eax,(%esp)
  8005b4:	e8 45 fb ff ff       	call   8000fe <sys_cputs>

	return b.cnt;
  8005b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005bf:	c9                   	leave  
  8005c0:	c3                   	ret    

008005c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	e8 7e ff ff ff       	call   80055d <vcprintf>
  8005df:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005e5:	c9                   	leave  
  8005e6:	c3                   	ret    

008005e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e7:	55                   	push   %ebp
  8005e8:	89 e5                	mov    %esp,%ebp
  8005ea:	53                   	push   %ebx
  8005eb:	83 ec 34             	sub    $0x34,%esp
  8005ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005fa:	8b 45 18             	mov    0x18(%ebp),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800602:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800605:	77 72                	ja     800679 <printnum+0x92>
  800607:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80060a:	72 05                	jb     800611 <printnum+0x2a>
  80060c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80060f:	77 68                	ja     800679 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800611:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800614:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800617:	8b 45 18             	mov    0x18(%ebp),%eax
  80061a:	ba 00 00 00 00       	mov    $0x0,%edx
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	89 54 24 04          	mov    %edx,0x4(%esp)
  800634:	e8 97 0b 00 00       	call   8011d0 <__udivdi3>
  800639:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80063c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800640:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800644:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800647:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80064b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800653:	8b 45 0c             	mov    0xc(%ebp),%eax
  800656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065a:	8b 45 08             	mov    0x8(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	e8 82 ff ff ff       	call   8005e7 <printnum>
  800665:	eb 1c                	jmp    800683 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800667:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066e:	8b 45 20             	mov    0x20(%ebp),%eax
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800679:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80067d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800681:	7f e4                	jg     800667 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800683:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800686:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80068e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800691:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800695:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800699:	89 04 24             	mov    %eax,(%esp)
  80069c:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a0:	e8 5b 0c 00 00       	call   801300 <__umoddi3>
  8006a5:	05 a8 15 80 00       	add    $0x8015a8,%eax
  8006aa:	0f b6 00             	movzbl (%eax),%eax
  8006ad:	0f be c0             	movsbl %al,%eax
  8006b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	ff d0                	call   *%eax
}
  8006bf:	83 c4 34             	add    $0x34,%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006c8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006cc:	7e 14                	jle    8006e2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	8d 48 08             	lea    0x8(%eax),%ecx
  8006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d9:	89 0a                	mov    %ecx,(%edx)
  8006db:	8b 50 04             	mov    0x4(%eax),%edx
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	eb 30                	jmp    800712 <getuint+0x4d>
	else if (lflag)
  8006e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006e6:	74 16                	je     8006fe <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f3:	89 0a                	mov    %ecx,(%edx)
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fc:	eb 14                	jmp    800712 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800701:	8b 00                	mov    (%eax),%eax
  800703:	8d 48 04             	lea    0x4(%eax),%ecx
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
  800709:	89 0a                	mov    %ecx,(%edx)
  80070b:	8b 00                	mov    (%eax),%eax
  80070d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800717:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80071b:	7e 14                	jle    800731 <getint+0x1d>
		return va_arg(*ap, long long);
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 00                	mov    (%eax),%eax
  800722:	8d 48 08             	lea    0x8(%eax),%ecx
  800725:	8b 55 08             	mov    0x8(%ebp),%edx
  800728:	89 0a                	mov    %ecx,(%edx)
  80072a:	8b 50 04             	mov    0x4(%eax),%edx
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	eb 28                	jmp    800759 <getint+0x45>
	else if (lflag)
  800731:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800735:	74 12                	je     800749 <getint+0x35>
		return va_arg(*ap, long);
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	8d 48 04             	lea    0x4(%eax),%ecx
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
  800742:	89 0a                	mov    %ecx,(%edx)
  800744:	8b 00                	mov    (%eax),%eax
  800746:	99                   	cltd   
  800747:	eb 10                	jmp    800759 <getint+0x45>
	else
		return va_arg(*ap, int);
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	8d 48 04             	lea    0x4(%eax),%ecx
  800751:	8b 55 08             	mov    0x8(%ebp),%edx
  800754:	89 0a                	mov    %ecx,(%edx)
  800756:	8b 00                	mov    (%eax),%eax
  800758:	99                   	cltd   
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	56                   	push   %esi
  80075f:	53                   	push   %ebx
  800760:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800763:	eb 18                	jmp    80077d <vprintfmt+0x22>
			if (ch == '\0')
  800765:	85 db                	test   %ebx,%ebx
  800767:	75 05                	jne    80076e <vprintfmt+0x13>
				return;
  800769:	e9 cc 03 00 00       	jmp    800b3a <vprintfmt+0x3df>
			putch(ch, putdat);
  80076e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800771:	89 44 24 04          	mov    %eax,0x4(%esp)
  800775:	89 1c 24             	mov    %ebx,(%esp)
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077d:	8b 45 10             	mov    0x10(%ebp),%eax
  800780:	8d 50 01             	lea    0x1(%eax),%edx
  800783:	89 55 10             	mov    %edx,0x10(%ebp)
  800786:	0f b6 00             	movzbl (%eax),%eax
  800789:	0f b6 d8             	movzbl %al,%ebx
  80078c:	83 fb 25             	cmp    $0x25,%ebx
  80078f:	75 d4                	jne    800765 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800791:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800795:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80079c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007a3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007aa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b4:	8d 50 01             	lea    0x1(%eax),%edx
  8007b7:	89 55 10             	mov    %edx,0x10(%ebp)
  8007ba:	0f b6 00             	movzbl (%eax),%eax
  8007bd:	0f b6 d8             	movzbl %al,%ebx
  8007c0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007c3:	83 f8 55             	cmp    $0x55,%eax
  8007c6:	0f 87 3d 03 00 00    	ja     800b09 <vprintfmt+0x3ae>
  8007cc:	8b 04 85 cc 15 80 00 	mov    0x8015cc(,%eax,4),%eax
  8007d3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007d5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007d9:	eb d6                	jmp    8007b1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007db:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007df:	eb d0                	jmp    8007b1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007eb:	89 d0                	mov    %edx,%eax
  8007ed:	c1 e0 02             	shl    $0x2,%eax
  8007f0:	01 d0                	add    %edx,%eax
  8007f2:	01 c0                	add    %eax,%eax
  8007f4:	01 d8                	add    %ebx,%eax
  8007f6:	83 e8 30             	sub    $0x30,%eax
  8007f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ff:	0f b6 00             	movzbl (%eax),%eax
  800802:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800805:	83 fb 2f             	cmp    $0x2f,%ebx
  800808:	7e 0b                	jle    800815 <vprintfmt+0xba>
  80080a:	83 fb 39             	cmp    $0x39,%ebx
  80080d:	7f 06                	jg     800815 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80080f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800813:	eb d3                	jmp    8007e8 <vprintfmt+0x8d>
			goto process_precision;
  800815:	eb 33                	jmp    80084a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 00                	mov    (%eax),%eax
  800822:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800825:	eb 23                	jmp    80084a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800827:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80082b:	79 0c                	jns    800839 <vprintfmt+0xde>
				width = 0;
  80082d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800834:	e9 78 ff ff ff       	jmp    8007b1 <vprintfmt+0x56>
  800839:	e9 73 ff ff ff       	jmp    8007b1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80083e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800845:	e9 67 ff ff ff       	jmp    8007b1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80084a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80084e:	79 12                	jns    800862 <vprintfmt+0x107>
				width = precision, precision = -1;
  800850:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800853:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800856:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80085d:	e9 4f ff ff ff       	jmp    8007b1 <vprintfmt+0x56>
  800862:	e9 4a ff ff ff       	jmp    8007b1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800867:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80086b:	e9 41 ff ff ff       	jmp    8007b1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	89 55 14             	mov    %edx,0x14(%ebp)
  800879:	8b 00                	mov    (%eax),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	ff d0                	call   *%eax
			break;
  80088a:	e9 a5 02 00 00       	jmp    800b34 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8d 50 04             	lea    0x4(%eax),%edx
  800895:	89 55 14             	mov    %edx,0x14(%ebp)
  800898:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80089a:	85 db                	test   %ebx,%ebx
  80089c:	79 02                	jns    8008a0 <vprintfmt+0x145>
				err = -err;
  80089e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008a0:	83 fb 09             	cmp    $0x9,%ebx
  8008a3:	7f 0b                	jg     8008b0 <vprintfmt+0x155>
  8008a5:	8b 34 9d 80 15 80 00 	mov    0x801580(,%ebx,4),%esi
  8008ac:	85 f6                	test   %esi,%esi
  8008ae:	75 23                	jne    8008d3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008b0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008b4:	c7 44 24 08 b9 15 80 	movl   $0x8015b9,0x8(%esp)
  8008bb:	00 
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 73 02 00 00       	call   800b41 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008ce:	e9 61 02 00 00       	jmp    800b34 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008d7:	c7 44 24 08 c2 15 80 	movl   $0x8015c2,0x8(%esp)
  8008de:	00 
  8008df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	89 04 24             	mov    %eax,(%esp)
  8008ec:	e8 50 02 00 00       	call   800b41 <printfmt>
			break;
  8008f1:	e9 3e 02 00 00       	jmp    800b34 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8d 50 04             	lea    0x4(%eax),%edx
  8008fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ff:	8b 30                	mov    (%eax),%esi
  800901:	85 f6                	test   %esi,%esi
  800903:	75 05                	jne    80090a <vprintfmt+0x1af>
				p = "(null)";
  800905:	be c5 15 80 00       	mov    $0x8015c5,%esi
			if (width > 0 && padc != '-')
  80090a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090e:	7e 37                	jle    800947 <vprintfmt+0x1ec>
  800910:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800914:	74 31                	je     800947 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800916:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	89 34 24             	mov    %esi,(%esp)
  800920:	e8 39 03 00 00       	call   800c5e <strnlen>
  800925:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800928:	eb 17                	jmp    800941 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80092a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 54 24 04          	mov    %edx,0x4(%esp)
  800935:	89 04 24             	mov    %eax,(%esp)
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80093d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800941:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800945:	7f e3                	jg     80092a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800947:	eb 38                	jmp    800981 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800949:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80094d:	74 1f                	je     80096e <vprintfmt+0x213>
  80094f:	83 fb 1f             	cmp    $0x1f,%ebx
  800952:	7e 05                	jle    800959 <vprintfmt+0x1fe>
  800954:	83 fb 7e             	cmp    $0x7e,%ebx
  800957:	7e 15                	jle    80096e <vprintfmt+0x213>
					putch('?', putdat);
  800959:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800960:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	ff d0                	call   *%eax
  80096c:	eb 0f                	jmp    80097d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	89 1c 24             	mov    %ebx,(%esp)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80097d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800981:	89 f0                	mov    %esi,%eax
  800983:	8d 70 01             	lea    0x1(%eax),%esi
  800986:	0f b6 00             	movzbl (%eax),%eax
  800989:	0f be d8             	movsbl %al,%ebx
  80098c:	85 db                	test   %ebx,%ebx
  80098e:	74 10                	je     8009a0 <vprintfmt+0x245>
  800990:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800994:	78 b3                	js     800949 <vprintfmt+0x1ee>
  800996:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80099a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80099e:	79 a9                	jns    800949 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a0:	eb 17                	jmp    8009b9 <vprintfmt+0x25e>
				putch(' ', putdat);
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009b5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009bd:	7f e3                	jg     8009a2 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009bf:	e9 70 01 00 00       	jmp    800b34 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 3e fd ff ff       	call   800714 <getint>
  8009d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009e2:	85 d2                	test   %edx,%edx
  8009e4:	79 26                	jns    800a0c <vprintfmt+0x2b1>
				putch('-', putdat);
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ed:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	ff d0                	call   *%eax
				num = -(long long) num;
  8009f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ff:	f7 d8                	neg    %eax
  800a01:	83 d2 00             	adc    $0x0,%edx
  800a04:	f7 da                	neg    %edx
  800a06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a09:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a0c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a13:	e9 a8 00 00 00       	jmp    800ac0 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a18:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a22:	89 04 24             	mov    %eax,(%esp)
  800a25:	e8 9b fc ff ff       	call   8006c5 <getuint>
  800a2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a2d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a30:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a37:	e9 84 00 00 00       	jmp    800ac0 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	8d 45 14             	lea    0x14(%ebp),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 77 fc ff ff       	call   8006c5 <getuint>
  800a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a51:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a54:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a5b:	eb 63                	jmp    800ac0 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a64:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	ff d0                	call   *%eax
			putch('x', putdat);
  800a70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a77:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a83:	8b 45 14             	mov    0x14(%ebp),%eax
  800a86:	8d 50 04             	lea    0x4(%eax),%edx
  800a89:	89 55 14             	mov    %edx,0x14(%ebp)
  800a8c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a98:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a9f:	eb 1f                	jmp    800ac0 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	8d 45 14             	lea    0x14(%ebp),%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 12 fc ff ff       	call   8006c5 <getuint>
  800ab3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ab6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800ab9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ac4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac7:	89 54 24 18          	mov    %edx,0x18(%esp)
  800acb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ace:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ad2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	89 04 24             	mov    %eax,(%esp)
  800af1:	e8 f1 fa ff ff       	call   8005e7 <printnum>
			break;
  800af6:	eb 3c                	jmp    800b34 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aff:	89 1c 24             	mov    %ebx,(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	ff d0                	call   *%eax
			break;
  800b07:	eb 2b                	jmp    800b34 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b1c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b20:	eb 04                	jmp    800b26 <vprintfmt+0x3cb>
  800b22:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	83 e8 01             	sub    $0x1,%eax
  800b2c:	0f b6 00             	movzbl (%eax),%eax
  800b2f:	3c 25                	cmp    $0x25,%al
  800b31:	75 ef                	jne    800b22 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b33:	90                   	nop
		}
	}
  800b34:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b35:	e9 43 fc ff ff       	jmp    80077d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b3a:	83 c4 40             	add    $0x40,%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b47:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b54:	8b 45 10             	mov    0x10(%ebp),%eax
  800b57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	89 04 24             	mov    %eax,(%esp)
  800b68:	e8 ee fb ff ff       	call   80075b <vprintfmt>
	va_end(ap);
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b75:	8b 40 08             	mov    0x8(%eax),%eax
  800b78:	8d 50 01             	lea    0x1(%eax),%edx
  800b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	8b 10                	mov    (%eax),%edx
  800b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b89:	8b 40 04             	mov    0x4(%eax),%eax
  800b8c:	39 c2                	cmp    %eax,%edx
  800b8e:	73 12                	jae    800ba2 <sprintputch+0x33>
		*b->buf++ = ch;
  800b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b93:	8b 00                	mov    (%eax),%eax
  800b95:	8d 48 01             	lea    0x1(%eax),%ecx
  800b98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9b:	89 0a                	mov    %ecx,(%edx)
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	88 10                	mov    %dl,(%eax)
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	01 d0                	add    %edx,%eax
  800bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bc5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bc9:	74 06                	je     800bd1 <vsnprintf+0x2d>
  800bcb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcf:	7f 07                	jg     800bd8 <vsnprintf+0x34>
		return -E_INVAL;
  800bd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bd6:	eb 2a                	jmp    800c02 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800be2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bed:	c7 04 24 6f 0b 80 00 	movl   $0x800b6f,(%esp)
  800bf4:	e8 62 fb ff ff       	call   80075b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bfc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c0a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c17:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	89 04 24             	mov    %eax,(%esp)
  800c2b:	e8 74 ff ff ff       	call   800ba4 <vsnprintf>
  800c30:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c45:	eb 08                	jmp    800c4f <strlen+0x17>
		n++;
  800c47:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c4b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	0f b6 00             	movzbl (%eax),%eax
  800c55:	84 c0                	test   %al,%al
  800c57:	75 ee                	jne    800c47 <strlen+0xf>
		n++;
	return n;
  800c59:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c64:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c6b:	eb 0c                	jmp    800c79 <strnlen+0x1b>
		n++;
  800c6d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c71:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c75:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7d:	74 0a                	je     800c89 <strnlen+0x2b>
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	0f b6 00             	movzbl (%eax),%eax
  800c85:	84 c0                	test   %al,%al
  800c87:	75 e4                	jne    800c6d <strnlen+0xf>
		n++;
	return n;
  800c89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c9a:	90                   	nop
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	8d 50 01             	lea    0x1(%eax),%edx
  800ca1:	89 55 08             	mov    %edx,0x8(%ebp)
  800ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca7:	8d 4a 01             	lea    0x1(%edx),%ecx
  800caa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cad:	0f b6 12             	movzbl (%edx),%edx
  800cb0:	88 10                	mov    %dl,(%eax)
  800cb2:	0f b6 00             	movzbl (%eax),%eax
  800cb5:	84 c0                	test   %al,%al
  800cb7:	75 e2                	jne    800c9b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	89 04 24             	mov    %eax,(%esp)
  800cca:	e8 69 ff ff ff       	call   800c38 <strlen>
  800ccf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cd2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	01 c2                	add    %eax,%edx
  800cda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce1:	89 14 24             	mov    %edx,(%esp)
  800ce4:	e8 a5 ff ff ff       	call   800c8e <strcpy>
	return dst;
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cfa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d01:	eb 23                	jmp    800d26 <strncpy+0x38>
		*dst++ = *src;
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	8d 50 01             	lea    0x1(%eax),%edx
  800d09:	89 55 08             	mov    %edx,0x8(%ebp)
  800d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0f:	0f b6 12             	movzbl (%edx),%edx
  800d12:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d17:	0f b6 00             	movzbl (%eax),%eax
  800d1a:	84 c0                	test   %al,%al
  800d1c:	74 04                	je     800d22 <strncpy+0x34>
			src++;
  800d1e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d26:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d29:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d2c:	72 d5                	jb     800d03 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d2e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d43:	74 33                	je     800d78 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d45:	eb 17                	jmp    800d5e <strlcpy+0x2b>
			*dst++ = *src++;
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8d 50 01             	lea    0x1(%eax),%edx
  800d4d:	89 55 08             	mov    %edx,0x8(%ebp)
  800d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d53:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d56:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d59:	0f b6 12             	movzbl (%edx),%edx
  800d5c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d5e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d66:	74 0a                	je     800d72 <strlcpy+0x3f>
  800d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6b:	0f b6 00             	movzbl (%eax),%eax
  800d6e:	84 c0                	test   %al,%al
  800d70:	75 d5                	jne    800d47 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d7e:	29 c2                	sub    %eax,%edx
  800d80:	89 d0                	mov    %edx,%eax
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d87:	eb 08                	jmp    800d91 <strcmp+0xd>
		p++, q++;
  800d89:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	0f b6 00             	movzbl (%eax),%eax
  800d97:	84 c0                	test   %al,%al
  800d99:	74 10                	je     800dab <strcmp+0x27>
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	0f b6 10             	movzbl (%eax),%edx
  800da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	38 c2                	cmp    %al,%dl
  800da9:	74 de                	je     800d89 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	0f b6 d0             	movzbl %al,%edx
  800db4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db7:	0f b6 00             	movzbl (%eax),%eax
  800dba:	0f b6 c0             	movzbl %al,%eax
  800dbd:	29 c2                	sub    %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
}
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    

00800dc3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dc6:	eb 0c                	jmp    800dd4 <strncmp+0x11>
		n--, p++, q++;
  800dc8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dcc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd8:	74 1a                	je     800df4 <strncmp+0x31>
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 10                	je     800df4 <strncmp+0x31>
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	0f b6 10             	movzbl (%eax),%edx
  800dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ded:	0f b6 00             	movzbl (%eax),%eax
  800df0:	38 c2                	cmp    %al,%dl
  800df2:	74 d4                	je     800dc8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800df4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df8:	75 07                	jne    800e01 <strncmp+0x3e>
		return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	eb 16                	jmp    800e17 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	0f b6 00             	movzbl (%eax),%eax
  800e07:	0f b6 d0             	movzbl %al,%edx
  800e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0d:	0f b6 00             	movzbl (%eax),%eax
  800e10:	0f b6 c0             	movzbl %al,%eax
  800e13:	29 c2                	sub    %eax,%edx
  800e15:	89 d0                	mov    %edx,%eax
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 04             	sub    $0x4,%esp
  800e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e22:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e25:	eb 14                	jmp    800e3b <strchr+0x22>
		if (*s == c)
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	0f b6 00             	movzbl (%eax),%eax
  800e2d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e30:	75 05                	jne    800e37 <strchr+0x1e>
			return (char *) s;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	eb 13                	jmp    800e4a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3e:	0f b6 00             	movzbl (%eax),%eax
  800e41:	84 c0                	test   %al,%al
  800e43:	75 e2                	jne    800e27 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e55:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e58:	eb 11                	jmp    800e6b <strfind+0x1f>
		if (*s == c)
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	0f b6 00             	movzbl (%eax),%eax
  800e60:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e63:	75 02                	jne    800e67 <strfind+0x1b>
			break;
  800e65:	eb 0e                	jmp    800e75 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	0f b6 00             	movzbl (%eax),%eax
  800e71:	84 c0                	test   %al,%al
  800e73:	75 e5                	jne    800e5a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    

00800e7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e82:	75 05                	jne    800e89 <memset+0xf>
		return v;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	eb 5c                	jmp    800ee5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	83 e0 03             	and    $0x3,%eax
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	75 41                	jne    800ed4 <memset+0x5a>
  800e93:	8b 45 10             	mov    0x10(%ebp),%eax
  800e96:	83 e0 03             	and    $0x3,%eax
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	75 37                	jne    800ed4 <memset+0x5a>
		c &= 0xFF;
  800e9d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	c1 e0 18             	shl    $0x18,%eax
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaf:	c1 e0 10             	shl    $0x10,%eax
  800eb2:	09 c2                	or     %eax,%edx
  800eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb7:	c1 e0 08             	shl    $0x8,%eax
  800eba:	09 d0                	or     %edx,%eax
  800ebc:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ebf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec2:	c1 e8 02             	shr    $0x2,%eax
  800ec5:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ec7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecd:	89 d7                	mov    %edx,%edi
  800ecf:	fc                   	cld    
  800ed0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ed2:	eb 0e                	jmp    800ee2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eda:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800edd:	89 d7                	mov    %edx,%edi
  800edf:	fc                   	cld    
  800ee0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f00:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f03:	73 6d                	jae    800f72 <memmove+0x8a>
  800f05:	8b 45 10             	mov    0x10(%ebp),%eax
  800f08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0b:	01 d0                	add    %edx,%eax
  800f0d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f10:	76 60                	jbe    800f72 <memmove+0x8a>
		s += n;
  800f12:	8b 45 10             	mov    0x10(%ebp),%eax
  800f15:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f18:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f21:	83 e0 03             	and    $0x3,%eax
  800f24:	85 c0                	test   %eax,%eax
  800f26:	75 2f                	jne    800f57 <memmove+0x6f>
  800f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2b:	83 e0 03             	and    $0x3,%eax
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	75 25                	jne    800f57 <memmove+0x6f>
  800f32:	8b 45 10             	mov    0x10(%ebp),%eax
  800f35:	83 e0 03             	and    $0x3,%eax
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	75 1b                	jne    800f57 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3f:	83 e8 04             	sub    $0x4,%eax
  800f42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f45:	83 ea 04             	sub    $0x4,%edx
  800f48:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f4b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f4e:	89 c7                	mov    %eax,%edi
  800f50:	89 d6                	mov    %edx,%esi
  800f52:	fd                   	std    
  800f53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f55:	eb 18                	jmp    800f6f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f60:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f63:	8b 45 10             	mov    0x10(%ebp),%eax
  800f66:	89 d7                	mov    %edx,%edi
  800f68:	89 de                	mov    %ebx,%esi
  800f6a:	89 c1                	mov    %eax,%ecx
  800f6c:	fd                   	std    
  800f6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f6f:	fc                   	cld    
  800f70:	eb 45                	jmp    800fb7 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f75:	83 e0 03             	and    $0x3,%eax
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	75 2b                	jne    800fa7 <memmove+0xbf>
  800f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f7f:	83 e0 03             	and    $0x3,%eax
  800f82:	85 c0                	test   %eax,%eax
  800f84:	75 21                	jne    800fa7 <memmove+0xbf>
  800f86:	8b 45 10             	mov    0x10(%ebp),%eax
  800f89:	83 e0 03             	and    $0x3,%eax
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	75 17                	jne    800fa7 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f90:	8b 45 10             	mov    0x10(%ebp),%eax
  800f93:	c1 e8 02             	shr    $0x2,%eax
  800f96:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f9e:	89 c7                	mov    %eax,%edi
  800fa0:	89 d6                	mov    %edx,%esi
  800fa2:	fc                   	cld    
  800fa3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fa5:	eb 10                	jmp    800fb7 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800faa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb0:	89 c7                	mov    %eax,%edi
  800fb2:	89 d6                	mov    %edx,%esi
  800fb4:	fc                   	cld    
  800fb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    

00800fc2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd9:	89 04 24             	mov    %eax,(%esp)
  800fdc:	e8 07 ff ff ff       	call   800ee8 <memmove>
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fec:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ff5:	eb 30                	jmp    801027 <memcmp+0x44>
		if (*s1 != *s2)
  800ff7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ffa:	0f b6 10             	movzbl (%eax),%edx
  800ffd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801000:	0f b6 00             	movzbl (%eax),%eax
  801003:	38 c2                	cmp    %al,%dl
  801005:	74 18                	je     80101f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801007:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80100a:	0f b6 00             	movzbl (%eax),%eax
  80100d:	0f b6 d0             	movzbl %al,%edx
  801010:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801013:	0f b6 00             	movzbl (%eax),%eax
  801016:	0f b6 c0             	movzbl %al,%eax
  801019:	29 c2                	sub    %eax,%edx
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	eb 1a                	jmp    801039 <memcmp+0x56>
		s1++, s2++;
  80101f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801023:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801027:	8b 45 10             	mov    0x10(%ebp),%eax
  80102a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80102d:	89 55 10             	mov    %edx,0x10(%ebp)
  801030:	85 c0                	test   %eax,%eax
  801032:	75 c3                	jne    800ff7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801041:	8b 45 10             	mov    0x10(%ebp),%eax
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	01 d0                	add    %edx,%eax
  801049:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80104c:	eb 13                	jmp    801061 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	0f b6 10             	movzbl (%eax),%edx
  801054:	8b 45 0c             	mov    0xc(%ebp),%eax
  801057:	38 c2                	cmp    %al,%dl
  801059:	75 02                	jne    80105d <memfind+0x22>
			break;
  80105b:	eb 0c                	jmp    801069 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80105d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801067:	72 e5                	jb     80104e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801074:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80107b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801082:	eb 04                	jmp    801088 <strtol+0x1a>
		s++;
  801084:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
  80108b:	0f b6 00             	movzbl (%eax),%eax
  80108e:	3c 20                	cmp    $0x20,%al
  801090:	74 f2                	je     801084 <strtol+0x16>
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	0f b6 00             	movzbl (%eax),%eax
  801098:	3c 09                	cmp    $0x9,%al
  80109a:	74 e8                	je     801084 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	0f b6 00             	movzbl (%eax),%eax
  8010a2:	3c 2b                	cmp    $0x2b,%al
  8010a4:	75 06                	jne    8010ac <strtol+0x3e>
		s++;
  8010a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010aa:	eb 15                	jmp    8010c1 <strtol+0x53>
	else if (*s == '-')
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	3c 2d                	cmp    $0x2d,%al
  8010b4:	75 0b                	jne    8010c1 <strtol+0x53>
		s++, neg = 1;
  8010b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ba:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c5:	74 06                	je     8010cd <strtol+0x5f>
  8010c7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010cb:	75 24                	jne    8010f1 <strtol+0x83>
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	0f b6 00             	movzbl (%eax),%eax
  8010d3:	3c 30                	cmp    $0x30,%al
  8010d5:	75 1a                	jne    8010f1 <strtol+0x83>
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	83 c0 01             	add    $0x1,%eax
  8010dd:	0f b6 00             	movzbl (%eax),%eax
  8010e0:	3c 78                	cmp    $0x78,%al
  8010e2:	75 0d                	jne    8010f1 <strtol+0x83>
		s += 2, base = 16;
  8010e4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010e8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010ef:	eb 2a                	jmp    80111b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010f5:	75 17                	jne    80110e <strtol+0xa0>
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	0f b6 00             	movzbl (%eax),%eax
  8010fd:	3c 30                	cmp    $0x30,%al
  8010ff:	75 0d                	jne    80110e <strtol+0xa0>
		s++, base = 8;
  801101:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801105:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80110c:	eb 0d                	jmp    80111b <strtol+0xad>
	else if (base == 0)
  80110e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801112:	75 07                	jne    80111b <strtol+0xad>
		base = 10;
  801114:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	0f b6 00             	movzbl (%eax),%eax
  801121:	3c 2f                	cmp    $0x2f,%al
  801123:	7e 1b                	jle    801140 <strtol+0xd2>
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
  801128:	0f b6 00             	movzbl (%eax),%eax
  80112b:	3c 39                	cmp    $0x39,%al
  80112d:	7f 11                	jg     801140 <strtol+0xd2>
			dig = *s - '0';
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	0f b6 00             	movzbl (%eax),%eax
  801135:	0f be c0             	movsbl %al,%eax
  801138:	83 e8 30             	sub    $0x30,%eax
  80113b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80113e:	eb 48                	jmp    801188 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	0f b6 00             	movzbl (%eax),%eax
  801146:	3c 60                	cmp    $0x60,%al
  801148:	7e 1b                	jle    801165 <strtol+0xf7>
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	0f b6 00             	movzbl (%eax),%eax
  801150:	3c 7a                	cmp    $0x7a,%al
  801152:	7f 11                	jg     801165 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	0f b6 00             	movzbl (%eax),%eax
  80115a:	0f be c0             	movsbl %al,%eax
  80115d:	83 e8 57             	sub    $0x57,%eax
  801160:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801163:	eb 23                	jmp    801188 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	0f b6 00             	movzbl (%eax),%eax
  80116b:	3c 40                	cmp    $0x40,%al
  80116d:	7e 3d                	jle    8011ac <strtol+0x13e>
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	0f b6 00             	movzbl (%eax),%eax
  801175:	3c 5a                	cmp    $0x5a,%al
  801177:	7f 33                	jg     8011ac <strtol+0x13e>
			dig = *s - 'A' + 10;
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	0f b6 00             	movzbl (%eax),%eax
  80117f:	0f be c0             	movsbl %al,%eax
  801182:	83 e8 37             	sub    $0x37,%eax
  801185:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80118e:	7c 02                	jl     801192 <strtol+0x124>
			break;
  801190:	eb 1a                	jmp    8011ac <strtol+0x13e>
		s++, val = (val * base) + dig;
  801192:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801196:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801199:	0f af 45 10          	imul   0x10(%ebp),%eax
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a2:	01 d0                	add    %edx,%eax
  8011a4:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011a7:	e9 6f ff ff ff       	jmp    80111b <strtol+0xad>

	if (endptr)
  8011ac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011b0:	74 08                	je     8011ba <strtol+0x14c>
		*endptr = (char *) s;
  8011b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011ba:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011be:	74 07                	je     8011c7 <strtol+0x159>
  8011c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011c3:	f7 d8                	neg    %eax
  8011c5:	eb 03                	jmp    8011ca <strtol+0x15c>
  8011c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    
  8011cc:	66 90                	xchg   %ax,%ax
  8011ce:	66 90                	xchg   %ax,%ax

008011d0 <__udivdi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ec:	89 ea                	mov    %ebp,%edx
  8011ee:	89 0c 24             	mov    %ecx,(%esp)
  8011f1:	75 2d                	jne    801220 <__udivdi3+0x50>
  8011f3:	39 e9                	cmp    %ebp,%ecx
  8011f5:	77 61                	ja     801258 <__udivdi3+0x88>
  8011f7:	85 c9                	test   %ecx,%ecx
  8011f9:	89 ce                	mov    %ecx,%esi
  8011fb:	75 0b                	jne    801208 <__udivdi3+0x38>
  8011fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801202:	31 d2                	xor    %edx,%edx
  801204:	f7 f1                	div    %ecx
  801206:	89 c6                	mov    %eax,%esi
  801208:	31 d2                	xor    %edx,%edx
  80120a:	89 e8                	mov    %ebp,%eax
  80120c:	f7 f6                	div    %esi
  80120e:	89 c5                	mov    %eax,%ebp
  801210:	89 f8                	mov    %edi,%eax
  801212:	f7 f6                	div    %esi
  801214:	89 ea                	mov    %ebp,%edx
  801216:	83 c4 0c             	add    $0xc,%esp
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    
  80121d:	8d 76 00             	lea    0x0(%esi),%esi
  801220:	39 e8                	cmp    %ebp,%eax
  801222:	77 24                	ja     801248 <__udivdi3+0x78>
  801224:	0f bd e8             	bsr    %eax,%ebp
  801227:	83 f5 1f             	xor    $0x1f,%ebp
  80122a:	75 3c                	jne    801268 <__udivdi3+0x98>
  80122c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801230:	39 34 24             	cmp    %esi,(%esp)
  801233:	0f 86 9f 00 00 00    	jbe    8012d8 <__udivdi3+0x108>
  801239:	39 d0                	cmp    %edx,%eax
  80123b:	0f 82 97 00 00 00    	jb     8012d8 <__udivdi3+0x108>
  801241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801248:	31 d2                	xor    %edx,%edx
  80124a:	31 c0                	xor    %eax,%eax
  80124c:	83 c4 0c             	add    $0xc,%esp
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    
  801253:	90                   	nop
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	89 f8                	mov    %edi,%eax
  80125a:	f7 f1                	div    %ecx
  80125c:	31 d2                	xor    %edx,%edx
  80125e:	83 c4 0c             	add    $0xc,%esp
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    
  801265:	8d 76 00             	lea    0x0(%esi),%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	8b 3c 24             	mov    (%esp),%edi
  80126d:	d3 e0                	shl    %cl,%eax
  80126f:	89 c6                	mov    %eax,%esi
  801271:	b8 20 00 00 00       	mov    $0x20,%eax
  801276:	29 e8                	sub    %ebp,%eax
  801278:	89 c1                	mov    %eax,%ecx
  80127a:	d3 ef                	shr    %cl,%edi
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801282:	8b 3c 24             	mov    (%esp),%edi
  801285:	09 74 24 08          	or     %esi,0x8(%esp)
  801289:	89 d6                	mov    %edx,%esi
  80128b:	d3 e7                	shl    %cl,%edi
  80128d:	89 c1                	mov    %eax,%ecx
  80128f:	89 3c 24             	mov    %edi,(%esp)
  801292:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801296:	d3 ee                	shr    %cl,%esi
  801298:	89 e9                	mov    %ebp,%ecx
  80129a:	d3 e2                	shl    %cl,%edx
  80129c:	89 c1                	mov    %eax,%ecx
  80129e:	d3 ef                	shr    %cl,%edi
  8012a0:	09 d7                	or     %edx,%edi
  8012a2:	89 f2                	mov    %esi,%edx
  8012a4:	89 f8                	mov    %edi,%eax
  8012a6:	f7 74 24 08          	divl   0x8(%esp)
  8012aa:	89 d6                	mov    %edx,%esi
  8012ac:	89 c7                	mov    %eax,%edi
  8012ae:	f7 24 24             	mull   (%esp)
  8012b1:	39 d6                	cmp    %edx,%esi
  8012b3:	89 14 24             	mov    %edx,(%esp)
  8012b6:	72 30                	jb     8012e8 <__udivdi3+0x118>
  8012b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	d3 e2                	shl    %cl,%edx
  8012c0:	39 c2                	cmp    %eax,%edx
  8012c2:	73 05                	jae    8012c9 <__udivdi3+0xf9>
  8012c4:	3b 34 24             	cmp    (%esp),%esi
  8012c7:	74 1f                	je     8012e8 <__udivdi3+0x118>
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	e9 7a ff ff ff       	jmp    80124c <__udivdi3+0x7c>
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	31 d2                	xor    %edx,%edx
  8012da:	b8 01 00 00 00       	mov    $0x1,%eax
  8012df:	e9 68 ff ff ff       	jmp    80124c <__udivdi3+0x7c>
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	83 c4 0c             	add    $0xc,%esp
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    
  8012f4:	66 90                	xchg   %ax,%ax
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__umoddi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 44 24 28          	mov    0x28(%esp),%eax
  80130a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80130e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801312:	89 c7                	mov    %eax,%edi
  801314:	89 44 24 04          	mov    %eax,0x4(%esp)
  801318:	8b 44 24 30          	mov    0x30(%esp),%eax
  80131c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801320:	89 34 24             	mov    %esi,(%esp)
  801323:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801327:	85 c0                	test   %eax,%eax
  801329:	89 c2                	mov    %eax,%edx
  80132b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80132f:	75 17                	jne    801348 <__umoddi3+0x48>
  801331:	39 fe                	cmp    %edi,%esi
  801333:	76 4b                	jbe    801380 <__umoddi3+0x80>
  801335:	89 c8                	mov    %ecx,%eax
  801337:	89 fa                	mov    %edi,%edx
  801339:	f7 f6                	div    %esi
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	31 d2                	xor    %edx,%edx
  80133f:	83 c4 14             	add    $0x14,%esp
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    
  801346:	66 90                	xchg   %ax,%ax
  801348:	39 f8                	cmp    %edi,%eax
  80134a:	77 54                	ja     8013a0 <__umoddi3+0xa0>
  80134c:	0f bd e8             	bsr    %eax,%ebp
  80134f:	83 f5 1f             	xor    $0x1f,%ebp
  801352:	75 5c                	jne    8013b0 <__umoddi3+0xb0>
  801354:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801358:	39 3c 24             	cmp    %edi,(%esp)
  80135b:	0f 87 e7 00 00 00    	ja     801448 <__umoddi3+0x148>
  801361:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801365:	29 f1                	sub    %esi,%ecx
  801367:	19 c7                	sbb    %eax,%edi
  801369:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801371:	8b 44 24 08          	mov    0x8(%esp),%eax
  801375:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801379:	83 c4 14             	add    $0x14,%esp
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    
  801380:	85 f6                	test   %esi,%esi
  801382:	89 f5                	mov    %esi,%ebp
  801384:	75 0b                	jne    801391 <__umoddi3+0x91>
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	f7 f6                	div    %esi
  80138f:	89 c5                	mov    %eax,%ebp
  801391:	8b 44 24 04          	mov    0x4(%esp),%eax
  801395:	31 d2                	xor    %edx,%edx
  801397:	f7 f5                	div    %ebp
  801399:	89 c8                	mov    %ecx,%eax
  80139b:	f7 f5                	div    %ebp
  80139d:	eb 9c                	jmp    80133b <__umoddi3+0x3b>
  80139f:	90                   	nop
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 fa                	mov    %edi,%edx
  8013a4:	83 c4 14             	add    $0x14,%esp
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
  8013ab:	90                   	nop
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	8b 04 24             	mov    (%esp),%eax
  8013b3:	be 20 00 00 00       	mov    $0x20,%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	29 ee                	sub    %ebp,%esi
  8013bc:	d3 e2                	shl    %cl,%edx
  8013be:	89 f1                	mov    %esi,%ecx
  8013c0:	d3 e8                	shr    %cl,%eax
  8013c2:	89 e9                	mov    %ebp,%ecx
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 04 24             	mov    (%esp),%eax
  8013cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	d3 e0                	shl    %cl,%eax
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013dd:	d3 ea                	shr    %cl,%edx
  8013df:	89 e9                	mov    %ebp,%ecx
  8013e1:	d3 e7                	shl    %cl,%edi
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	d3 e8                	shr    %cl,%eax
  8013e7:	89 e9                	mov    %ebp,%ecx
  8013e9:	09 f8                	or     %edi,%eax
  8013eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013ef:	f7 74 24 04          	divl   0x4(%esp)
  8013f3:	d3 e7                	shl    %cl,%edi
  8013f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013f9:	89 d7                	mov    %edx,%edi
  8013fb:	f7 64 24 08          	mull   0x8(%esp)
  8013ff:	39 d7                	cmp    %edx,%edi
  801401:	89 c1                	mov    %eax,%ecx
  801403:	89 14 24             	mov    %edx,(%esp)
  801406:	72 2c                	jb     801434 <__umoddi3+0x134>
  801408:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80140c:	72 22                	jb     801430 <__umoddi3+0x130>
  80140e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801412:	29 c8                	sub    %ecx,%eax
  801414:	19 d7                	sbb    %edx,%edi
  801416:	89 e9                	mov    %ebp,%ecx
  801418:	89 fa                	mov    %edi,%edx
  80141a:	d3 e8                	shr    %cl,%eax
  80141c:	89 f1                	mov    %esi,%ecx
  80141e:	d3 e2                	shl    %cl,%edx
  801420:	89 e9                	mov    %ebp,%ecx
  801422:	d3 ef                	shr    %cl,%edi
  801424:	09 d0                	or     %edx,%eax
  801426:	89 fa                	mov    %edi,%edx
  801428:	83 c4 14             	add    $0x14,%esp
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    
  80142f:	90                   	nop
  801430:	39 d7                	cmp    %edx,%edi
  801432:	75 da                	jne    80140e <__umoddi3+0x10e>
  801434:	8b 14 24             	mov    (%esp),%edx
  801437:	89 c1                	mov    %eax,%ecx
  801439:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80143d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801441:	eb cb                	jmp    80140e <__umoddi3+0x10e>
  801443:	90                   	nop
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80144c:	0f 82 0f ff ff ff    	jb     801361 <__umoddi3+0x61>
  801452:	e9 1a ff ff ff       	jmp    801371 <__umoddi3+0x71>
