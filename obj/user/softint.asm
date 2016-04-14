
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800040:	e8 82 01 00 00       	call   8001c7 <sys_getenvid>
  800045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004a:	c1 e0 02             	shl    $0x2,%eax
  80004d:	89 c2                	mov    %eax,%edx
  80004f:	c1 e2 05             	shl    $0x5,%edx
  800052:	29 c2                	sub    %eax,%edx
  800054:	89 d0                	mov    %edx,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800064:	7e 0a                	jle    800070 <libmain+0x36>
		binaryname = argv[0];
  800066:	8b 45 0c             	mov    0xc(%ebp),%eax
  800069:	8b 00                	mov    (%eax),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000d7:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e6:	00 
  8000e7:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8000ee:	e8 2c 03 00 00       	call   80041f <_panic>

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

0080041f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	53                   	push   %ebx
  800423:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800426:	8d 45 14             	lea    0x14(%ebp),%eax
  800429:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800432:	e8 90 fd ff ff       	call   8001c7 <sys_getenvid>
  800437:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80043e:	8b 55 08             	mov    0x8(%ebp),%edx
  800441:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800445:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800449:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044d:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  800454:	e8 e1 00 00 00       	call   80053a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800459:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80045c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800460:	8b 45 10             	mov    0x10(%ebp),%eax
  800463:	89 04 24             	mov    %eax,(%esp)
  800466:	e8 6b 00 00 00       	call   8004d6 <vcprintf>
	cprintf("\n");
  80046b:	c7 04 24 3b 14 80 00 	movl   $0x80143b,(%esp)
  800472:	e8 c3 00 00 00       	call   80053a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800477:	cc                   	int3   
  800478:	eb fd                	jmp    800477 <_panic+0x58>

0080047a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	8b 00                	mov    (%eax),%eax
  800485:	8d 48 01             	lea    0x1(%eax),%ecx
  800488:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048b:	89 0a                	mov    %ecx,(%edx)
  80048d:	8b 55 08             	mov    0x8(%ebp),%edx
  800490:	89 d1                	mov    %edx,%ecx
  800492:	8b 55 0c             	mov    0xc(%ebp),%edx
  800495:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800499:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049c:	8b 00                	mov    (%eax),%eax
  80049e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a3:	75 20                	jne    8004c5 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a8:	8b 00                	mov    (%eax),%eax
  8004aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ad:	83 c2 08             	add    $0x8,%edx
  8004b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b4:	89 14 24             	mov    %edx,(%esp)
  8004b7:	e8 42 fc ff ff       	call   8000fe <sys_cputs>
		b->idx = 0;
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c8:	8b 40 04             	mov    0x4(%eax),%eax
  8004cb:	8d 50 01             	lea    0x1(%eax),%edx
  8004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d1:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004d4:	c9                   	leave  
  8004d5:	c3                   	ret    

008004d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e6:	00 00 00 
	b.cnt = 0;
  8004e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800501:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050b:	c7 04 24 7a 04 80 00 	movl   $0x80047a,(%esp)
  800512:	e8 bd 01 00 00       	call   8006d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800517:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800527:	83 c0 08             	add    $0x8,%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	e8 cc fb ff ff       	call   8000fe <sys_cputs>

	return b.cnt;
  800532:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800538:	c9                   	leave  
  800539:	c3                   	ret    

0080053a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800540:	8d 45 0c             	lea    0xc(%ebp),%eax
  800543:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800549:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054d:	8b 45 08             	mov    0x8(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 7e ff ff ff       	call   8004d6 <vcprintf>
  800558:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80055b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80055e:	c9                   	leave  
  80055f:	c3                   	ret    

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	53                   	push   %ebx
  800564:	83 ec 34             	sub    $0x34,%esp
  800567:	8b 45 10             	mov    0x10(%ebp),%eax
  80056a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800573:	8b 45 18             	mov    0x18(%ebp),%eax
  800576:	ba 00 00 00 00       	mov    $0x0,%edx
  80057b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80057e:	77 72                	ja     8005f2 <printnum+0x92>
  800580:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800583:	72 05                	jb     80058a <printnum+0x2a>
  800585:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800588:	77 68                	ja     8005f2 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80058d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800590:	8b 45 18             	mov    0x18(%ebp),%eax
  800593:	ba 00 00 00 00       	mov    $0x0,%edx
  800598:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ad:	e8 9e 0b 00 00       	call   801150 <__udivdi3>
  8005b2:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005b5:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005b9:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005bd:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005c0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	e8 82 ff ff ff       	call   800560 <printnum>
  8005de:	eb 1c                	jmp    8005fc <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e7:	8b 45 20             	mov    0x20(%ebp),%eax
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f0:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005f6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8005fa:	7f e4                	jg     8005e0 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005fc:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800604:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800607:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	89 54 24 04          	mov    %edx,0x4(%esp)
  800619:	e8 62 0c 00 00       	call   801280 <__umoddi3>
  80061e:	05 08 15 80 00       	add    $0x801508,%eax
  800623:	0f b6 00             	movzbl (%eax),%eax
  800626:	0f be c0             	movsbl %al,%eax
  800629:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	ff d0                	call   *%eax
}
  800638:	83 c4 34             	add    $0x34,%esp
  80063b:	5b                   	pop    %ebx
  80063c:	5d                   	pop    %ebp
  80063d:	c3                   	ret    

0080063e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800641:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800645:	7e 14                	jle    80065b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800647:	8b 45 08             	mov    0x8(%ebp),%eax
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	8d 48 08             	lea    0x8(%eax),%ecx
  80064f:	8b 55 08             	mov    0x8(%ebp),%edx
  800652:	89 0a                	mov    %ecx,(%edx)
  800654:	8b 50 04             	mov    0x4(%eax),%edx
  800657:	8b 00                	mov    (%eax),%eax
  800659:	eb 30                	jmp    80068b <getuint+0x4d>
	else if (lflag)
  80065b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80065f:	74 16                	je     800677 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	8b 00                	mov    (%eax),%eax
  800666:	8d 48 04             	lea    0x4(%eax),%ecx
  800669:	8b 55 08             	mov    0x8(%ebp),%edx
  80066c:	89 0a                	mov    %ecx,(%edx)
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	ba 00 00 00 00       	mov    $0x0,%edx
  800675:	eb 14                	jmp    80068b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	8d 48 04             	lea    0x4(%eax),%ecx
  80067f:	8b 55 08             	mov    0x8(%ebp),%edx
  800682:	89 0a                	mov    %ecx,(%edx)
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800690:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800694:	7e 14                	jle    8006aa <getint+0x1d>
		return va_arg(*ap, long long);
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	8d 48 08             	lea    0x8(%eax),%ecx
  80069e:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a1:	89 0a                	mov    %ecx,(%edx)
  8006a3:	8b 50 04             	mov    0x4(%eax),%edx
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	eb 28                	jmp    8006d2 <getint+0x45>
	else if (lflag)
  8006aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006ae:	74 12                	je     8006c2 <getint+0x35>
		return va_arg(*ap, long);
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	8b 00                	mov    (%eax),%eax
  8006b5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bb:	89 0a                	mov    %ecx,(%edx)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	99                   	cltd   
  8006c0:	eb 10                	jmp    8006d2 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cd:	89 0a                	mov    %ecx,(%edx)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	99                   	cltd   
}
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006dc:	eb 18                	jmp    8006f6 <vprintfmt+0x22>
			if (ch == '\0')
  8006de:	85 db                	test   %ebx,%ebx
  8006e0:	75 05                	jne    8006e7 <vprintfmt+0x13>
				return;
  8006e2:	e9 cc 03 00 00       	jmp    800ab3 <vprintfmt+0x3df>
			putch(ch, putdat);
  8006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ee:	89 1c 24             	mov    %ebx,(%esp)
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f9:	8d 50 01             	lea    0x1(%eax),%edx
  8006fc:	89 55 10             	mov    %edx,0x10(%ebp)
  8006ff:	0f b6 00             	movzbl (%eax),%eax
  800702:	0f b6 d8             	movzbl %al,%ebx
  800705:	83 fb 25             	cmp    $0x25,%ebx
  800708:	75 d4                	jne    8006de <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80070a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80070e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800715:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80071c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800723:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	8d 50 01             	lea    0x1(%eax),%edx
  800730:	89 55 10             	mov    %edx,0x10(%ebp)
  800733:	0f b6 00             	movzbl (%eax),%eax
  800736:	0f b6 d8             	movzbl %al,%ebx
  800739:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80073c:	83 f8 55             	cmp    $0x55,%eax
  80073f:	0f 87 3d 03 00 00    	ja     800a82 <vprintfmt+0x3ae>
  800745:	8b 04 85 2c 15 80 00 	mov    0x80152c(,%eax,4),%eax
  80074c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80074e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800752:	eb d6                	jmp    80072a <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800754:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800758:	eb d0                	jmp    80072a <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800761:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800764:	89 d0                	mov    %edx,%eax
  800766:	c1 e0 02             	shl    $0x2,%eax
  800769:	01 d0                	add    %edx,%eax
  80076b:	01 c0                	add    %eax,%eax
  80076d:	01 d8                	add    %ebx,%eax
  80076f:	83 e8 30             	sub    $0x30,%eax
  800772:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800775:	8b 45 10             	mov    0x10(%ebp),%eax
  800778:	0f b6 00             	movzbl (%eax),%eax
  80077b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80077e:	83 fb 2f             	cmp    $0x2f,%ebx
  800781:	7e 0b                	jle    80078e <vprintfmt+0xba>
  800783:	83 fb 39             	cmp    $0x39,%ebx
  800786:	7f 06                	jg     80078e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800788:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078c:	eb d3                	jmp    800761 <vprintfmt+0x8d>
			goto process_precision;
  80078e:	eb 33                	jmp    8007c3 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8d 50 04             	lea    0x4(%eax),%edx
  800796:	89 55 14             	mov    %edx,0x14(%ebp)
  800799:	8b 00                	mov    (%eax),%eax
  80079b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80079e:	eb 23                	jmp    8007c3 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a4:	79 0c                	jns    8007b2 <vprintfmt+0xde>
				width = 0;
  8007a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007ad:	e9 78 ff ff ff       	jmp    80072a <vprintfmt+0x56>
  8007b2:	e9 73 ff ff ff       	jmp    80072a <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007b7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007be:	e9 67 ff ff ff       	jmp    80072a <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c7:	79 12                	jns    8007db <vprintfmt+0x107>
				width = precision, precision = -1;
  8007c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007d6:	e9 4f ff ff ff       	jmp    80072a <vprintfmt+0x56>
  8007db:	e9 4a ff ff ff       	jmp    80072a <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e0:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007e4:	e9 41 ff ff ff       	jmp    80072a <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8d 50 04             	lea    0x4(%eax),%edx
  8007ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f2:	8b 00                	mov    (%eax),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	ff d0                	call   *%eax
			break;
  800803:	e9 a5 02 00 00       	jmp    800aad <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8d 50 04             	lea    0x4(%eax),%edx
  80080e:	89 55 14             	mov    %edx,0x14(%ebp)
  800811:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800813:	85 db                	test   %ebx,%ebx
  800815:	79 02                	jns    800819 <vprintfmt+0x145>
				err = -err;
  800817:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800819:	83 fb 09             	cmp    $0x9,%ebx
  80081c:	7f 0b                	jg     800829 <vprintfmt+0x155>
  80081e:	8b 34 9d e0 14 80 00 	mov    0x8014e0(,%ebx,4),%esi
  800825:	85 f6                	test   %esi,%esi
  800827:	75 23                	jne    80084c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800829:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80082d:	c7 44 24 08 19 15 80 	movl   $0x801519,0x8(%esp)
  800834:	00 
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 73 02 00 00       	call   800aba <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800847:	e9 61 02 00 00       	jmp    800aad <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80084c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800850:	c7 44 24 08 22 15 80 	movl   $0x801522,0x8(%esp)
  800857:	00 
  800858:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	e8 50 02 00 00       	call   800aba <printfmt>
			break;
  80086a:	e9 3e 02 00 00       	jmp    800aad <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 50 04             	lea    0x4(%eax),%edx
  800875:	89 55 14             	mov    %edx,0x14(%ebp)
  800878:	8b 30                	mov    (%eax),%esi
  80087a:	85 f6                	test   %esi,%esi
  80087c:	75 05                	jne    800883 <vprintfmt+0x1af>
				p = "(null)";
  80087e:	be 25 15 80 00       	mov    $0x801525,%esi
			if (width > 0 && padc != '-')
  800883:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800887:	7e 37                	jle    8008c0 <vprintfmt+0x1ec>
  800889:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80088d:	74 31                	je     8008c0 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800892:	89 44 24 04          	mov    %eax,0x4(%esp)
  800896:	89 34 24             	mov    %esi,(%esp)
  800899:	e8 39 03 00 00       	call   800bd7 <strnlen>
  80089e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008a1:	eb 17                	jmp    8008ba <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008a3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008be:	7f e3                	jg     8008a3 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c0:	eb 38                	jmp    8008fa <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c6:	74 1f                	je     8008e7 <vprintfmt+0x213>
  8008c8:	83 fb 1f             	cmp    $0x1f,%ebx
  8008cb:	7e 05                	jle    8008d2 <vprintfmt+0x1fe>
  8008cd:	83 fb 7e             	cmp    $0x7e,%ebx
  8008d0:	7e 15                	jle    8008e7 <vprintfmt+0x213>
					putch('?', putdat);
  8008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	ff d0                	call   *%eax
  8008e5:	eb 0f                	jmp    8008f6 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	89 1c 24             	mov    %ebx,(%esp)
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fa:	89 f0                	mov    %esi,%eax
  8008fc:	8d 70 01             	lea    0x1(%eax),%esi
  8008ff:	0f b6 00             	movzbl (%eax),%eax
  800902:	0f be d8             	movsbl %al,%ebx
  800905:	85 db                	test   %ebx,%ebx
  800907:	74 10                	je     800919 <vprintfmt+0x245>
  800909:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80090d:	78 b3                	js     8008c2 <vprintfmt+0x1ee>
  80090f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800913:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800917:	79 a9                	jns    8008c2 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800919:	eb 17                	jmp    800932 <vprintfmt+0x25e>
				putch(' ', putdat);
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800932:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800936:	7f e3                	jg     80091b <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800938:	e9 70 01 00 00       	jmp    800aad <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80093d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800940:	89 44 24 04          	mov    %eax,0x4(%esp)
  800944:	8d 45 14             	lea    0x14(%ebp),%eax
  800947:	89 04 24             	mov    %eax,(%esp)
  80094a:	e8 3e fd ff ff       	call   80068d <getint>
  80094f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800952:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800958:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095b:	85 d2                	test   %edx,%edx
  80095d:	79 26                	jns    800985 <vprintfmt+0x2b1>
				putch('-', putdat);
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	ff d0                	call   *%eax
				num = -(long long) num;
  800972:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800975:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800978:	f7 d8                	neg    %eax
  80097a:	83 d2 00             	adc    $0x0,%edx
  80097d:	f7 da                	neg    %edx
  80097f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800982:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800985:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80098c:	e9 a8 00 00 00       	jmp    800a39 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800991:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800994:	89 44 24 04          	mov    %eax,0x4(%esp)
  800998:	8d 45 14             	lea    0x14(%ebp),%eax
  80099b:	89 04 24             	mov    %eax,(%esp)
  80099e:	e8 9b fc ff ff       	call   80063e <getuint>
  8009a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009a9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009b0:	e9 84 00 00 00       	jmp    800a39 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009bf:	89 04 24             	mov    %eax,(%esp)
  8009c2:	e8 77 fc ff ff       	call   80063e <getuint>
  8009c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009cd:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009d4:	eb 63                	jmp    800a39 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dd:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	ff d0                	call   *%eax
			putch('x', putdat);
  8009e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8009fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ff:	8d 50 04             	lea    0x4(%eax),%edx
  800a02:	89 55 14             	mov    %edx,0x14(%ebp)
  800a05:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a11:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a18:	eb 1f                	jmp    800a39 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	8d 45 14             	lea    0x14(%ebp),%eax
  800a24:	89 04 24             	mov    %eax,(%esp)
  800a27:	e8 12 fc ff ff       	call   80063e <getuint>
  800a2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a2f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a32:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a39:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a40:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a47:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a59:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	89 04 24             	mov    %eax,(%esp)
  800a6a:	e8 f1 fa ff ff       	call   800560 <printnum>
			break;
  800a6f:	eb 3c                	jmp    800aad <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a78:	89 1c 24             	mov    %ebx,(%esp)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	ff d0                	call   *%eax
			break;
  800a80:	eb 2b                	jmp    800aad <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a89:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a95:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a99:	eb 04                	jmp    800a9f <vprintfmt+0x3cb>
  800a9b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800a9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa2:	83 e8 01             	sub    $0x1,%eax
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	3c 25                	cmp    $0x25,%al
  800aaa:	75 ef                	jne    800a9b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800aac:	90                   	nop
		}
	}
  800aad:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aae:	e9 43 fc ff ff       	jmp    8006f6 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ab3:	83 c4 40             	add    $0x40,%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ac0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800acd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	89 04 24             	mov    %eax,(%esp)
  800ae1:	e8 ee fb ff ff       	call   8006d4 <vprintfmt>
	va_end(ap);
}
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aee:	8b 40 08             	mov    0x8(%eax),%eax
  800af1:	8d 50 01             	lea    0x1(%eax),%edx
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	8b 10                	mov    (%eax),%edx
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	8b 40 04             	mov    0x4(%eax),%eax
  800b05:	39 c2                	cmp    %eax,%edx
  800b07:	73 12                	jae    800b1b <sprintputch+0x33>
		*b->buf++ = ch;
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	8b 00                	mov    (%eax),%eax
  800b0e:	8d 48 01             	lea    0x1(%eax),%ecx
  800b11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b14:	89 0a                	mov    %ecx,(%edx)
  800b16:	8b 55 08             	mov    0x8(%ebp),%edx
  800b19:	88 10                	mov    %dl,(%eax)
}
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	01 d0                	add    %edx,%eax
  800b34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b42:	74 06                	je     800b4a <vsnprintf+0x2d>
  800b44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b48:	7f 07                	jg     800b51 <vsnprintf+0x34>
		return -E_INVAL;
  800b4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b4f:	eb 2a                	jmp    800b7b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b51:	8b 45 14             	mov    0x14(%ebp),%eax
  800b54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b58:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b66:	c7 04 24 e8 0a 80 00 	movl   $0x800ae8,(%esp)
  800b6d:	e8 62 fb ff ff       	call   8006d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b75:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b83:	8d 45 14             	lea    0x14(%ebp),%eax
  800b86:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b90:	8b 45 10             	mov    0x10(%ebp),%eax
  800b93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	89 04 24             	mov    %eax,(%esp)
  800ba4:	e8 74 ff ff ff       	call   800b1d <vsnprintf>
  800ba9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    

00800bb1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bbe:	eb 08                	jmp    800bc8 <strlen+0x17>
		n++;
  800bc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	0f b6 00             	movzbl (%eax),%eax
  800bce:	84 c0                	test   %al,%al
  800bd0:	75 ee                	jne    800bc0 <strlen+0xf>
		n++;
	return n;
  800bd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bdd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800be4:	eb 0c                	jmp    800bf2 <strnlen+0x1b>
		n++;
  800be6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bee:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800bf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf6:	74 0a                	je     800c02 <strnlen+0x2b>
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	0f b6 00             	movzbl (%eax),%eax
  800bfe:	84 c0                	test   %al,%al
  800c00:	75 e4                	jne    800be6 <strnlen+0xf>
		n++;
	return n;
  800c02:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c13:	90                   	nop
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	8d 50 01             	lea    0x1(%eax),%edx
  800c1a:	89 55 08             	mov    %edx,0x8(%ebp)
  800c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c20:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c23:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c26:	0f b6 12             	movzbl (%edx),%edx
  800c29:	88 10                	mov    %dl,(%eax)
  800c2b:	0f b6 00             	movzbl (%eax),%eax
  800c2e:	84 c0                	test   %al,%al
  800c30:	75 e2                	jne    800c14 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c32:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	89 04 24             	mov    %eax,(%esp)
  800c43:	e8 69 ff ff ff       	call   800bb1 <strlen>
  800c48:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c4b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	01 c2                	add    %eax,%edx
  800c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5a:	89 14 24             	mov    %edx,(%esp)
  800c5d:	e8 a5 ff ff ff       	call   800c07 <strcpy>
	return dst;
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c70:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c73:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c7a:	eb 23                	jmp    800c9f <strncpy+0x38>
		*dst++ = *src;
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8d 50 01             	lea    0x1(%eax),%edx
  800c82:	89 55 08             	mov    %edx,0x8(%ebp)
  800c85:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c88:	0f b6 12             	movzbl (%edx),%edx
  800c8b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c90:	0f b6 00             	movzbl (%eax),%eax
  800c93:	84 c0                	test   %al,%al
  800c95:	74 04                	je     800c9b <strncpy+0x34>
			src++;
  800c97:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800c9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ca2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ca5:	72 d5                	jb     800c7c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ca7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800caa:	c9                   	leave  
  800cab:	c3                   	ret    

00800cac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cbc:	74 33                	je     800cf1 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cbe:	eb 17                	jmp    800cd7 <strlcpy+0x2b>
			*dst++ = *src++;
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	8d 50 01             	lea    0x1(%eax),%edx
  800cc6:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ccf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cd2:	0f b6 12             	movzbl (%edx),%edx
  800cd5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cd7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800cdb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cdf:	74 0a                	je     800ceb <strlcpy+0x3f>
  800ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce4:	0f b6 00             	movzbl (%eax),%eax
  800ce7:	84 c0                	test   %al,%al
  800ce9:	75 d5                	jne    800cc0 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf7:	29 c2                	sub    %eax,%edx
  800cf9:	89 d0                	mov    %edx,%eax
}
  800cfb:	c9                   	leave  
  800cfc:	c3                   	ret    

00800cfd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d00:	eb 08                	jmp    800d0a <strcmp+0xd>
		p++, q++;
  800d02:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d06:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	0f b6 00             	movzbl (%eax),%eax
  800d10:	84 c0                	test   %al,%al
  800d12:	74 10                	je     800d24 <strcmp+0x27>
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	0f b6 10             	movzbl (%eax),%edx
  800d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1d:	0f b6 00             	movzbl (%eax),%eax
  800d20:	38 c2                	cmp    %al,%dl
  800d22:	74 de                	je     800d02 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	0f b6 00             	movzbl (%eax),%eax
  800d2a:	0f b6 d0             	movzbl %al,%edx
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	0f b6 00             	movzbl (%eax),%eax
  800d33:	0f b6 c0             	movzbl %al,%eax
  800d36:	29 c2                	sub    %eax,%edx
  800d38:	89 d0                	mov    %edx,%eax
}
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d3f:	eb 0c                	jmp    800d4d <strncmp+0x11>
		n--, p++, q++;
  800d41:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d49:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d51:	74 1a                	je     800d6d <strncmp+0x31>
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	0f b6 00             	movzbl (%eax),%eax
  800d59:	84 c0                	test   %al,%al
  800d5b:	74 10                	je     800d6d <strncmp+0x31>
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	0f b6 10             	movzbl (%eax),%edx
  800d63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	38 c2                	cmp    %al,%dl
  800d6b:	74 d4                	je     800d41 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d71:	75 07                	jne    800d7a <strncmp+0x3e>
		return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	eb 16                	jmp    800d90 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	0f b6 00             	movzbl (%eax),%eax
  800d80:	0f b6 d0             	movzbl %al,%edx
  800d83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	0f b6 c0             	movzbl %al,%eax
  800d8c:	29 c2                	sub    %eax,%edx
  800d8e:	89 d0                	mov    %edx,%eax
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800d9e:	eb 14                	jmp    800db4 <strchr+0x22>
		if (*s == c)
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	0f b6 00             	movzbl (%eax),%eax
  800da6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800da9:	75 05                	jne    800db0 <strchr+0x1e>
			return (char *) s;
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	eb 13                	jmp    800dc3 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800db0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	0f b6 00             	movzbl (%eax),%eax
  800dba:	84 c0                	test   %al,%al
  800dbc:	75 e2                	jne    800da0 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    

00800dc5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	83 ec 04             	sub    $0x4,%esp
  800dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dce:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dd1:	eb 11                	jmp    800de4 <strfind+0x1f>
		if (*s == c)
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	0f b6 00             	movzbl (%eax),%eax
  800dd9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ddc:	75 02                	jne    800de0 <strfind+0x1b>
			break;
  800dde:	eb 0e                	jmp    800dee <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800de0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	0f b6 00             	movzbl (%eax),%eax
  800dea:	84 c0                	test   %al,%al
  800dec:	75 e5                	jne    800dd3 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
	char *p;

	if (n == 0)
  800df7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfb:	75 05                	jne    800e02 <memset+0xf>
		return v;
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	eb 5c                	jmp    800e5e <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	83 e0 03             	and    $0x3,%eax
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	75 41                	jne    800e4d <memset+0x5a>
  800e0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0f:	83 e0 03             	and    $0x3,%eax
  800e12:	85 c0                	test   %eax,%eax
  800e14:	75 37                	jne    800e4d <memset+0x5a>
		c &= 0xFF;
  800e16:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e20:	c1 e0 18             	shl    $0x18,%eax
  800e23:	89 c2                	mov    %eax,%edx
  800e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e28:	c1 e0 10             	shl    $0x10,%eax
  800e2b:	09 c2                	or     %eax,%edx
  800e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e30:	c1 e0 08             	shl    $0x8,%eax
  800e33:	09 d0                	or     %edx,%eax
  800e35:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e38:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3b:	c1 e8 02             	shr    $0x2,%eax
  800e3e:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e46:	89 d7                	mov    %edx,%edi
  800e48:	fc                   	cld    
  800e49:	f3 ab                	rep stos %eax,%es:(%edi)
  800e4b:	eb 0e                	jmp    800e5b <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e56:	89 d7                	mov    %edx,%edi
  800e58:	fc                   	cld    
  800e59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e79:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e7c:	73 6d                	jae    800eeb <memmove+0x8a>
  800e7e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e81:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e84:	01 d0                	add    %edx,%eax
  800e86:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e89:	76 60                	jbe    800eeb <memmove+0x8a>
		s += n;
  800e8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800e91:	8b 45 10             	mov    0x10(%ebp),%eax
  800e94:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9a:	83 e0 03             	and    $0x3,%eax
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	75 2f                	jne    800ed0 <memmove+0x6f>
  800ea1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ea4:	83 e0 03             	and    $0x3,%eax
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	75 25                	jne    800ed0 <memmove+0x6f>
  800eab:	8b 45 10             	mov    0x10(%ebp),%eax
  800eae:	83 e0 03             	and    $0x3,%eax
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	75 1b                	jne    800ed0 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb8:	83 e8 04             	sub    $0x4,%eax
  800ebb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ebe:	83 ea 04             	sub    $0x4,%edx
  800ec1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ec4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ec7:	89 c7                	mov    %eax,%edi
  800ec9:	89 d6                	mov    %edx,%esi
  800ecb:	fd                   	std    
  800ecc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ece:	eb 18                	jmp    800ee8 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ed3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed9:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800edc:	8b 45 10             	mov    0x10(%ebp),%eax
  800edf:	89 d7                	mov    %edx,%edi
  800ee1:	89 de                	mov    %ebx,%esi
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	fd                   	std    
  800ee6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ee8:	fc                   	cld    
  800ee9:	eb 45                	jmp    800f30 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eee:	83 e0 03             	and    $0x3,%eax
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	75 2b                	jne    800f20 <memmove+0xbf>
  800ef5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef8:	83 e0 03             	and    $0x3,%eax
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 21                	jne    800f20 <memmove+0xbf>
  800eff:	8b 45 10             	mov    0x10(%ebp),%eax
  800f02:	83 e0 03             	and    $0x3,%eax
  800f05:	85 c0                	test   %eax,%eax
  800f07:	75 17                	jne    800f20 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f09:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0c:	c1 e8 02             	shr    $0x2,%eax
  800f0f:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f17:	89 c7                	mov    %eax,%edi
  800f19:	89 d6                	mov    %edx,%esi
  800f1b:	fc                   	cld    
  800f1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1e:	eb 10                	jmp    800f30 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f23:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f26:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f29:	89 c7                	mov    %eax,%edi
  800f2b:	89 d6                	mov    %edx,%esi
  800f2d:	fc                   	cld    
  800f2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f41:	8b 45 10             	mov    0x10(%ebp),%eax
  800f44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	89 04 24             	mov    %eax,(%esp)
  800f55:	e8 07 ff ff ff       	call   800e61 <memmove>
}
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f62:	8b 45 08             	mov    0x8(%ebp),%eax
  800f65:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f6e:	eb 30                	jmp    800fa0 <memcmp+0x44>
		if (*s1 != *s2)
  800f70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f73:	0f b6 10             	movzbl (%eax),%edx
  800f76:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f79:	0f b6 00             	movzbl (%eax),%eax
  800f7c:	38 c2                	cmp    %al,%dl
  800f7e:	74 18                	je     800f98 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f83:	0f b6 00             	movzbl (%eax),%eax
  800f86:	0f b6 d0             	movzbl %al,%edx
  800f89:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f8c:	0f b6 00             	movzbl (%eax),%eax
  800f8f:	0f b6 c0             	movzbl %al,%eax
  800f92:	29 c2                	sub    %eax,%edx
  800f94:	89 d0                	mov    %edx,%eax
  800f96:	eb 1a                	jmp    800fb2 <memcmp+0x56>
		s1++, s2++;
  800f98:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800f9c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fa6:	89 55 10             	mov    %edx,0x10(%ebp)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	75 c3                	jne    800f70 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fba:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc0:	01 d0                	add    %edx,%eax
  800fc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fc5:	eb 13                	jmp    800fda <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fca:	0f b6 10             	movzbl (%eax),%edx
  800fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd0:	38 c2                	cmp    %al,%dl
  800fd2:	75 02                	jne    800fd6 <memfind+0x22>
			break;
  800fd4:	eb 0c                	jmp    800fe2 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fd6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fda:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800fe0:	72 e5                	jb     800fc7 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800fed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ff4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ffb:	eb 04                	jmp    801001 <strtol+0x1a>
		s++;
  800ffd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801001:	8b 45 08             	mov    0x8(%ebp),%eax
  801004:	0f b6 00             	movzbl (%eax),%eax
  801007:	3c 20                	cmp    $0x20,%al
  801009:	74 f2                	je     800ffd <strtol+0x16>
  80100b:	8b 45 08             	mov    0x8(%ebp),%eax
  80100e:	0f b6 00             	movzbl (%eax),%eax
  801011:	3c 09                	cmp    $0x9,%al
  801013:	74 e8                	je     800ffd <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	0f b6 00             	movzbl (%eax),%eax
  80101b:	3c 2b                	cmp    $0x2b,%al
  80101d:	75 06                	jne    801025 <strtol+0x3e>
		s++;
  80101f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801023:	eb 15                	jmp    80103a <strtol+0x53>
	else if (*s == '-')
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	0f b6 00             	movzbl (%eax),%eax
  80102b:	3c 2d                	cmp    $0x2d,%al
  80102d:	75 0b                	jne    80103a <strtol+0x53>
		s++, neg = 1;
  80102f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801033:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80103a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80103e:	74 06                	je     801046 <strtol+0x5f>
  801040:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801044:	75 24                	jne    80106a <strtol+0x83>
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	0f b6 00             	movzbl (%eax),%eax
  80104c:	3c 30                	cmp    $0x30,%al
  80104e:	75 1a                	jne    80106a <strtol+0x83>
  801050:	8b 45 08             	mov    0x8(%ebp),%eax
  801053:	83 c0 01             	add    $0x1,%eax
  801056:	0f b6 00             	movzbl (%eax),%eax
  801059:	3c 78                	cmp    $0x78,%al
  80105b:	75 0d                	jne    80106a <strtol+0x83>
		s += 2, base = 16;
  80105d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801061:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801068:	eb 2a                	jmp    801094 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80106a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80106e:	75 17                	jne    801087 <strtol+0xa0>
  801070:	8b 45 08             	mov    0x8(%ebp),%eax
  801073:	0f b6 00             	movzbl (%eax),%eax
  801076:	3c 30                	cmp    $0x30,%al
  801078:	75 0d                	jne    801087 <strtol+0xa0>
		s++, base = 8;
  80107a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801085:	eb 0d                	jmp    801094 <strtol+0xad>
	else if (base == 0)
  801087:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108b:	75 07                	jne    801094 <strtol+0xad>
		base = 10;
  80108d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	0f b6 00             	movzbl (%eax),%eax
  80109a:	3c 2f                	cmp    $0x2f,%al
  80109c:	7e 1b                	jle    8010b9 <strtol+0xd2>
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	0f b6 00             	movzbl (%eax),%eax
  8010a4:	3c 39                	cmp    $0x39,%al
  8010a6:	7f 11                	jg     8010b9 <strtol+0xd2>
			dig = *s - '0';
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	0f b6 00             	movzbl (%eax),%eax
  8010ae:	0f be c0             	movsbl %al,%eax
  8010b1:	83 e8 30             	sub    $0x30,%eax
  8010b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010b7:	eb 48                	jmp    801101 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bc:	0f b6 00             	movzbl (%eax),%eax
  8010bf:	3c 60                	cmp    $0x60,%al
  8010c1:	7e 1b                	jle    8010de <strtol+0xf7>
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	0f b6 00             	movzbl (%eax),%eax
  8010c9:	3c 7a                	cmp    $0x7a,%al
  8010cb:	7f 11                	jg     8010de <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	0f b6 00             	movzbl (%eax),%eax
  8010d3:	0f be c0             	movsbl %al,%eax
  8010d6:	83 e8 57             	sub    $0x57,%eax
  8010d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010dc:	eb 23                	jmp    801101 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010de:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e1:	0f b6 00             	movzbl (%eax),%eax
  8010e4:	3c 40                	cmp    $0x40,%al
  8010e6:	7e 3d                	jle    801125 <strtol+0x13e>
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	0f b6 00             	movzbl (%eax),%eax
  8010ee:	3c 5a                	cmp    $0x5a,%al
  8010f0:	7f 33                	jg     801125 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f5:	0f b6 00             	movzbl (%eax),%eax
  8010f8:	0f be c0             	movsbl %al,%eax
  8010fb:	83 e8 37             	sub    $0x37,%eax
  8010fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801104:	3b 45 10             	cmp    0x10(%ebp),%eax
  801107:	7c 02                	jl     80110b <strtol+0x124>
			break;
  801109:	eb 1a                	jmp    801125 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80110b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80110f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801112:	0f af 45 10          	imul   0x10(%ebp),%eax
  801116:	89 c2                	mov    %eax,%edx
  801118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111b:	01 d0                	add    %edx,%eax
  80111d:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801120:	e9 6f ff ff ff       	jmp    801094 <strtol+0xad>

	if (endptr)
  801125:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801129:	74 08                	je     801133 <strtol+0x14c>
		*endptr = (char *) s;
  80112b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112e:	8b 55 08             	mov    0x8(%ebp),%edx
  801131:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801133:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801137:	74 07                	je     801140 <strtol+0x159>
  801139:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80113c:	f7 d8                	neg    %eax
  80113e:	eb 03                	jmp    801143 <strtol+0x15c>
  801140:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    
  801145:	66 90                	xchg   %ax,%ax
  801147:	66 90                	xchg   %ax,%ax
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
