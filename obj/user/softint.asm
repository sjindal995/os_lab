
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
  8000d7:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e6:	00 
  8000e7:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000ee:	e8 6f 03 00 00       	call   800462 <_panic>

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

00800462 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	53                   	push   %ebx
  800466:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800469:	8d 45 14             	lea    0x14(%ebp),%eax
  80046c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800475:	e8 4d fd ff ff       	call   8001c7 <sys_getenvid>
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800481:	8b 55 08             	mov    0x8(%ebp),%edx
  800484:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800488:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  800497:	e8 e1 00 00 00       	call   80057d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80049f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	e8 6b 00 00 00       	call   800519 <vcprintf>
	cprintf("\n");
  8004ae:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  8004b5:	e8 c3 00 00 00       	call   80057d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ba:	cc                   	int3   
  8004bb:	eb fd                	jmp    8004ba <_panic+0x58>

008004bd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	8d 48 01             	lea    0x1(%eax),%ecx
  8004cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ce:	89 0a                	mov    %ecx,(%edx)
  8004d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d3:	89 d1                	mov    %edx,%ecx
  8004d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d8:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e6:	75 20                	jne    800508 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004eb:	8b 00                	mov    (%eax),%eax
  8004ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f0:	83 c2 08             	add    $0x8,%edx
  8004f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f7:	89 14 24             	mov    %edx,(%esp)
  8004fa:	e8 ff fb ff ff       	call   8000fe <sys_cputs>
		b->idx = 0;
  8004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800502:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	8b 40 04             	mov    0x4(%eax),%eax
  80050e:	8d 50 01             	lea    0x1(%eax),%edx
  800511:	8b 45 0c             	mov    0xc(%ebp),%eax
  800514:	89 50 04             	mov    %edx,0x4(%eax)
}
  800517:	c9                   	leave  
  800518:	c3                   	ret    

00800519 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800522:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800529:	00 00 00 
	b.cnt = 0;
  80052c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800533:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800536:	8b 45 0c             	mov    0xc(%ebp),%eax
  800539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053d:	8b 45 08             	mov    0x8(%ebp),%eax
  800540:	89 44 24 08          	mov    %eax,0x8(%esp)
  800544:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80054a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054e:	c7 04 24 bd 04 80 00 	movl   $0x8004bd,(%esp)
  800555:	e8 bd 01 00 00       	call   800717 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80055a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800560:	89 44 24 04          	mov    %eax,0x4(%esp)
  800564:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80056a:	83 c0 08             	add    $0x8,%eax
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	e8 89 fb ff ff       	call   8000fe <sys_cputs>

	return b.cnt;
  800575:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80057b:	c9                   	leave  
  80057c:	c3                   	ret    

0080057d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800583:	8d 45 0c             	lea    0xc(%ebp),%eax
  800586:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	89 04 24             	mov    %eax,(%esp)
  800596:	e8 7e ff ff ff       	call   800519 <vcprintf>
  80059b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80059e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005a1:	c9                   	leave  
  8005a2:	c3                   	ret    

008005a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 34             	sub    $0x34,%esp
  8005aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b6:	8b 45 18             	mov    0x18(%ebp),%eax
  8005b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005be:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c1:	77 72                	ja     800635 <printnum+0x92>
  8005c3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c6:	72 05                	jb     8005cd <printnum+0x2a>
  8005c8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005cb:	77 68                	ja     800635 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005cd:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005d0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005d3:	8b 45 18             	mov    0x18(%ebp),%eax
  8005d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005e9:	89 04 24             	mov    %eax,(%esp)
  8005ec:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f0:	e8 9b 0b 00 00       	call   801190 <__udivdi3>
  8005f5:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005f8:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005fc:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800600:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800603:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800607:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80060f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800612:	89 44 24 04          	mov    %eax,0x4(%esp)
  800616:	8b 45 08             	mov    0x8(%ebp),%eax
  800619:	89 04 24             	mov    %eax,(%esp)
  80061c:	e8 82 ff ff ff       	call   8005a3 <printnum>
  800621:	eb 1c                	jmp    80063f <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800623:	8b 45 0c             	mov    0xc(%ebp),%eax
  800626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062a:	8b 45 20             	mov    0x20(%ebp),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	8b 45 08             	mov    0x8(%ebp),%eax
  800633:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800635:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800639:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80063d:	7f e4                	jg     800623 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80063f:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800642:	bb 00 00 00 00       	mov    $0x0,%ebx
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80064d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800651:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800655:	89 04 24             	mov    %eax,(%esp)
  800658:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065c:	e8 5f 0c 00 00       	call   8012c0 <__umoddi3>
  800661:	05 48 15 80 00       	add    $0x801548,%eax
  800666:	0f b6 00             	movzbl (%eax),%eax
  800669:	0f be c0             	movsbl %al,%eax
  80066c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80066f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	ff d0                	call   *%eax
}
  80067b:	83 c4 34             	add    $0x34,%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800684:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800688:	7e 14                	jle    80069e <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80068a:	8b 45 08             	mov    0x8(%ebp),%eax
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	8d 48 08             	lea    0x8(%eax),%ecx
  800692:	8b 55 08             	mov    0x8(%ebp),%edx
  800695:	89 0a                	mov    %ecx,(%edx)
  800697:	8b 50 04             	mov    0x4(%eax),%edx
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	eb 30                	jmp    8006ce <getuint+0x4d>
	else if (lflag)
  80069e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006a2:	74 16                	je     8006ba <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8006af:	89 0a                	mov    %ecx,(%edx)
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b8:	eb 14                	jmp    8006ce <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c5:	89 0a                	mov    %ecx,(%edx)
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d7:	7e 14                	jle    8006ed <getint+0x1d>
		return va_arg(*ap, long long);
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	8d 48 08             	lea    0x8(%eax),%ecx
  8006e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e4:	89 0a                	mov    %ecx,(%edx)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	eb 28                	jmp    800715 <getint+0x45>
	else if (lflag)
  8006ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006f1:	74 12                	je     800705 <getint+0x35>
		return va_arg(*ap, long);
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	8b 00                	mov    (%eax),%eax
  8006f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006fe:	89 0a                	mov    %ecx,(%edx)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	99                   	cltd   
  800703:	eb 10                	jmp    800715 <getint+0x45>
	else
		return va_arg(*ap, int);
  800705:	8b 45 08             	mov    0x8(%ebp),%eax
  800708:	8b 00                	mov    (%eax),%eax
  80070a:	8d 48 04             	lea    0x4(%eax),%ecx
  80070d:	8b 55 08             	mov    0x8(%ebp),%edx
  800710:	89 0a                	mov    %ecx,(%edx)
  800712:	8b 00                	mov    (%eax),%eax
  800714:	99                   	cltd   
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	56                   	push   %esi
  80071b:	53                   	push   %ebx
  80071c:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071f:	eb 18                	jmp    800739 <vprintfmt+0x22>
			if (ch == '\0')
  800721:	85 db                	test   %ebx,%ebx
  800723:	75 05                	jne    80072a <vprintfmt+0x13>
				return;
  800725:	e9 cc 03 00 00       	jmp    800af6 <vprintfmt+0x3df>
			putch(ch, putdat);
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	89 1c 24             	mov    %ebx,(%esp)
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800739:	8b 45 10             	mov    0x10(%ebp),%eax
  80073c:	8d 50 01             	lea    0x1(%eax),%edx
  80073f:	89 55 10             	mov    %edx,0x10(%ebp)
  800742:	0f b6 00             	movzbl (%eax),%eax
  800745:	0f b6 d8             	movzbl %al,%ebx
  800748:	83 fb 25             	cmp    $0x25,%ebx
  80074b:	75 d4                	jne    800721 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80074d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800751:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800758:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80075f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800766:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	8d 50 01             	lea    0x1(%eax),%edx
  800773:	89 55 10             	mov    %edx,0x10(%ebp)
  800776:	0f b6 00             	movzbl (%eax),%eax
  800779:	0f b6 d8             	movzbl %al,%ebx
  80077c:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80077f:	83 f8 55             	cmp    $0x55,%eax
  800782:	0f 87 3d 03 00 00    	ja     800ac5 <vprintfmt+0x3ae>
  800788:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  80078f:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800791:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800795:	eb d6                	jmp    80076d <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800797:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80079b:	eb d0                	jmp    80076d <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a7:	89 d0                	mov    %edx,%eax
  8007a9:	c1 e0 02             	shl    $0x2,%eax
  8007ac:	01 d0                	add    %edx,%eax
  8007ae:	01 c0                	add    %eax,%eax
  8007b0:	01 d8                	add    %ebx,%eax
  8007b2:	83 e8 30             	sub    $0x30,%eax
  8007b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bb:	0f b6 00             	movzbl (%eax),%eax
  8007be:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007c1:	83 fb 2f             	cmp    $0x2f,%ebx
  8007c4:	7e 0b                	jle    8007d1 <vprintfmt+0xba>
  8007c6:	83 fb 39             	cmp    $0x39,%ebx
  8007c9:	7f 06                	jg     8007d1 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007cb:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007cf:	eb d3                	jmp    8007a4 <vprintfmt+0x8d>
			goto process_precision;
  8007d1:	eb 33                	jmp    800806 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	8b 00                	mov    (%eax),%eax
  8007de:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007e1:	eb 23                	jmp    800806 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e7:	79 0c                	jns    8007f5 <vprintfmt+0xde>
				width = 0;
  8007e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007f0:	e9 78 ff ff ff       	jmp    80076d <vprintfmt+0x56>
  8007f5:	e9 73 ff ff ff       	jmp    80076d <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007fa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800801:	e9 67 ff ff ff       	jmp    80076d <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800806:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080a:	79 12                	jns    80081e <vprintfmt+0x107>
				width = precision, precision = -1;
  80080c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800812:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800819:	e9 4f ff ff ff       	jmp    80076d <vprintfmt+0x56>
  80081e:	e9 4a ff ff ff       	jmp    80076d <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800823:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800827:	e9 41 ff ff ff       	jmp    80076d <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8d 50 04             	lea    0x4(%eax),%edx
  800832:	89 55 14             	mov    %edx,0x14(%ebp)
  800835:	8b 00                	mov    (%eax),%eax
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	ff d0                	call   *%eax
			break;
  800846:	e9 a5 02 00 00       	jmp    800af0 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8d 50 04             	lea    0x4(%eax),%edx
  800851:	89 55 14             	mov    %edx,0x14(%ebp)
  800854:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800856:	85 db                	test   %ebx,%ebx
  800858:	79 02                	jns    80085c <vprintfmt+0x145>
				err = -err;
  80085a:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80085c:	83 fb 09             	cmp    $0x9,%ebx
  80085f:	7f 0b                	jg     80086c <vprintfmt+0x155>
  800861:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800868:	85 f6                	test   %esi,%esi
  80086a:	75 23                	jne    80088f <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80086c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800870:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  800877:	00 
  800878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 73 02 00 00       	call   800afd <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80088a:	e9 61 02 00 00       	jmp    800af0 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80088f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800893:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80089a:	00 
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	89 04 24             	mov    %eax,(%esp)
  8008a8:	e8 50 02 00 00       	call   800afd <printfmt>
			break;
  8008ad:	e9 3e 02 00 00       	jmp    800af0 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 30                	mov    (%eax),%esi
  8008bd:	85 f6                	test   %esi,%esi
  8008bf:	75 05                	jne    8008c6 <vprintfmt+0x1af>
				p = "(null)";
  8008c1:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  8008c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ca:	7e 37                	jle    800903 <vprintfmt+0x1ec>
  8008cc:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008d0:	74 31                	je     800903 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d9:	89 34 24             	mov    %esi,(%esp)
  8008dc:	e8 39 03 00 00       	call   800c1a <strnlen>
  8008e1:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008e4:	eb 17                	jmp    8008fd <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008e6:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f1:	89 04 24             	mov    %eax,(%esp)
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008f9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800901:	7f e3                	jg     8008e6 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800903:	eb 38                	jmp    80093d <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800905:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800909:	74 1f                	je     80092a <vprintfmt+0x213>
  80090b:	83 fb 1f             	cmp    $0x1f,%ebx
  80090e:	7e 05                	jle    800915 <vprintfmt+0x1fe>
  800910:	83 fb 7e             	cmp    $0x7e,%ebx
  800913:	7e 15                	jle    80092a <vprintfmt+0x213>
					putch('?', putdat);
  800915:	8b 45 0c             	mov    0xc(%ebp),%eax
  800918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	ff d0                	call   *%eax
  800928:	eb 0f                	jmp    800939 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800939:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093d:	89 f0                	mov    %esi,%eax
  80093f:	8d 70 01             	lea    0x1(%eax),%esi
  800942:	0f b6 00             	movzbl (%eax),%eax
  800945:	0f be d8             	movsbl %al,%ebx
  800948:	85 db                	test   %ebx,%ebx
  80094a:	74 10                	je     80095c <vprintfmt+0x245>
  80094c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800950:	78 b3                	js     800905 <vprintfmt+0x1ee>
  800952:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800956:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80095a:	79 a9                	jns    800905 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095c:	eb 17                	jmp    800975 <vprintfmt+0x25e>
				putch(' ', putdat);
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	89 44 24 04          	mov    %eax,0x4(%esp)
  800965:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800971:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800975:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800979:	7f e3                	jg     80095e <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80097b:	e9 70 01 00 00       	jmp    800af0 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800980:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800983:	89 44 24 04          	mov    %eax,0x4(%esp)
  800987:	8d 45 14             	lea    0x14(%ebp),%eax
  80098a:	89 04 24             	mov    %eax,(%esp)
  80098d:	e8 3e fd ff ff       	call   8006d0 <getint>
  800992:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800995:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800998:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80099b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80099e:	85 d2                	test   %edx,%edx
  8009a0:	79 26                	jns    8009c8 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	ff d0                	call   *%eax
				num = -(long long) num;
  8009b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009bb:	f7 d8                	neg    %eax
  8009bd:	83 d2 00             	adc    $0x0,%edx
  8009c0:	f7 da                	neg    %edx
  8009c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009c8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009cf:	e9 a8 00 00 00       	jmp    800a7c <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 9b fc ff ff       	call   800681 <getuint>
  8009e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009ec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009f3:	e9 84 00 00 00       	jmp    800a7c <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800a02:	89 04 24             	mov    %eax,(%esp)
  800a05:	e8 77 fc ff ff       	call   800681 <getuint>
  800a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a10:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a17:	eb 63                	jmp    800a7c <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	ff d0                	call   *%eax
			putch('x', putdat);
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a33:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a42:	8d 50 04             	lea    0x4(%eax),%edx
  800a45:	89 55 14             	mov    %edx,0x14(%ebp)
  800a48:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a54:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a5b:	eb 1f                	jmp    800a7c <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a64:	8d 45 14             	lea    0x14(%ebp),%eax
  800a67:	89 04 24             	mov    %eax,(%esp)
  800a6a:	e8 12 fc ff ff       	call   800681 <getuint>
  800a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a72:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a75:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a7c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a83:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a8a:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a95:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	89 04 24             	mov    %eax,(%esp)
  800aad:	e8 f1 fa ff ff       	call   8005a3 <printnum>
			break;
  800ab2:	eb 3c                	jmp    800af0 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abb:	89 1c 24             	mov    %ebx,(%esp)
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	ff d0                	call   *%eax
			break;
  800ac3:	eb 2b                	jmp    800af0 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800adc:	eb 04                	jmp    800ae2 <vprintfmt+0x3cb>
  800ade:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae5:	83 e8 01             	sub    $0x1,%eax
  800ae8:	0f b6 00             	movzbl (%eax),%eax
  800aeb:	3c 25                	cmp    $0x25,%al
  800aed:	75 ef                	jne    800ade <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800aef:	90                   	nop
		}
	}
  800af0:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800af1:	e9 43 fc ff ff       	jmp    800739 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800af6:	83 c4 40             	add    $0x40,%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b03:	8d 45 14             	lea    0x14(%ebp),%eax
  800b06:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b10:	8b 45 10             	mov    0x10(%ebp),%eax
  800b13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	89 04 24             	mov    %eax,(%esp)
  800b24:	e8 ee fb ff ff       	call   800717 <vprintfmt>
	va_end(ap);
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	8b 40 08             	mov    0x8(%eax),%eax
  800b34:	8d 50 01             	lea    0x1(%eax),%edx
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	8b 10                	mov    (%eax),%edx
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	8b 40 04             	mov    0x4(%eax),%eax
  800b48:	39 c2                	cmp    %eax,%edx
  800b4a:	73 12                	jae    800b5e <sprintputch+0x33>
		*b->buf++ = ch;
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	8b 00                	mov    (%eax),%eax
  800b51:	8d 48 01             	lea    0x1(%eax),%ecx
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b57:	89 0a                	mov    %ecx,(%edx)
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	88 10                	mov    %dl,(%eax)
}
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	01 d0                	add    %edx,%eax
  800b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b81:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b85:	74 06                	je     800b8d <vsnprintf+0x2d>
  800b87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8b:	7f 07                	jg     800b94 <vsnprintf+0x34>
		return -E_INVAL;
  800b8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b92:	eb 2a                	jmp    800bbe <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b94:	8b 45 14             	mov    0x14(%ebp),%eax
  800b97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba9:	c7 04 24 2b 0b 80 00 	movl   $0x800b2b,(%esp)
  800bb0:	e8 62 fb ff ff       	call   800717 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bb5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bc6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be1:	8b 45 08             	mov    0x8(%ebp),%eax
  800be4:	89 04 24             	mov    %eax,(%esp)
  800be7:	e8 74 ff ff ff       	call   800b60 <vsnprintf>
  800bec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bfa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c01:	eb 08                	jmp    800c0b <strlen+0x17>
		n++;
  800c03:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c07:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	0f b6 00             	movzbl (%eax),%eax
  800c11:	84 c0                	test   %al,%al
  800c13:	75 ee                	jne    800c03 <strlen+0xf>
		n++;
	return n;
  800c15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c20:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c27:	eb 0c                	jmp    800c35 <strnlen+0x1b>
		n++;
  800c29:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c31:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c39:	74 0a                	je     800c45 <strnlen+0x2b>
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	0f b6 00             	movzbl (%eax),%eax
  800c41:	84 c0                	test   %al,%al
  800c43:	75 e4                	jne    800c29 <strnlen+0xf>
		n++;
	return n;
  800c45:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c56:	90                   	nop
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	8d 50 01             	lea    0x1(%eax),%edx
  800c5d:	89 55 08             	mov    %edx,0x8(%ebp)
  800c60:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c63:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c66:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c69:	0f b6 12             	movzbl (%edx),%edx
  800c6c:	88 10                	mov    %dl,(%eax)
  800c6e:	0f b6 00             	movzbl (%eax),%eax
  800c71:	84 c0                	test   %al,%al
  800c73:	75 e2                	jne    800c57 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c75:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c78:	c9                   	leave  
  800c79:	c3                   	ret    

00800c7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	89 04 24             	mov    %eax,(%esp)
  800c86:	e8 69 ff ff ff       	call   800bf4 <strlen>
  800c8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c8e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	01 c2                	add    %eax,%edx
  800c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9d:	89 14 24             	mov    %edx,(%esp)
  800ca0:	e8 a5 ff ff ff       	call   800c4a <strcpy>
	return dst;
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca8:	c9                   	leave  
  800ca9:	c3                   	ret    

00800caa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cb6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cbd:	eb 23                	jmp    800ce2 <strncpy+0x38>
		*dst++ = *src;
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	8d 50 01             	lea    0x1(%eax),%edx
  800cc5:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccb:	0f b6 12             	movzbl (%edx),%edx
  800cce:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd3:	0f b6 00             	movzbl (%eax),%eax
  800cd6:	84 c0                	test   %al,%al
  800cd8:	74 04                	je     800cde <strncpy+0x34>
			src++;
  800cda:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cde:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce5:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ce8:	72 d5                	jb     800cbf <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cea:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ced:	c9                   	leave  
  800cee:	c3                   	ret    

00800cef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cfb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cff:	74 33                	je     800d34 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d01:	eb 17                	jmp    800d1a <strlcpy+0x2b>
			*dst++ = *src++;
  800d03:	8b 45 08             	mov    0x8(%ebp),%eax
  800d06:	8d 50 01             	lea    0x1(%eax),%edx
  800d09:	89 55 08             	mov    %edx,0x8(%ebp)
  800d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d12:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d15:	0f b6 12             	movzbl (%edx),%edx
  800d18:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d1a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d22:	74 0a                	je     800d2e <strlcpy+0x3f>
  800d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d27:	0f b6 00             	movzbl (%eax),%eax
  800d2a:	84 c0                	test   %al,%al
  800d2c:	75 d5                	jne    800d03 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3a:	29 c2                	sub    %eax,%edx
  800d3c:	89 d0                	mov    %edx,%eax
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d43:	eb 08                	jmp    800d4d <strcmp+0xd>
		p++, q++;
  800d45:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d49:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	0f b6 00             	movzbl (%eax),%eax
  800d53:	84 c0                	test   %al,%al
  800d55:	74 10                	je     800d67 <strcmp+0x27>
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	0f b6 10             	movzbl (%eax),%edx
  800d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d60:	0f b6 00             	movzbl (%eax),%eax
  800d63:	38 c2                	cmp    %al,%dl
  800d65:	74 de                	je     800d45 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	0f b6 00             	movzbl (%eax),%eax
  800d6d:	0f b6 d0             	movzbl %al,%edx
  800d70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d73:	0f b6 00             	movzbl (%eax),%eax
  800d76:	0f b6 c0             	movzbl %al,%eax
  800d79:	29 c2                	sub    %eax,%edx
  800d7b:	89 d0                	mov    %edx,%eax
}
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d82:	eb 0c                	jmp    800d90 <strncmp+0x11>
		n--, p++, q++;
  800d84:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d88:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d94:	74 1a                	je     800db0 <strncmp+0x31>
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	0f b6 00             	movzbl (%eax),%eax
  800d9c:	84 c0                	test   %al,%al
  800d9e:	74 10                	je     800db0 <strncmp+0x31>
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	0f b6 10             	movzbl (%eax),%edx
  800da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da9:	0f b6 00             	movzbl (%eax),%eax
  800dac:	38 c2                	cmp    %al,%dl
  800dae:	74 d4                	je     800d84 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800db0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db4:	75 07                	jne    800dbd <strncmp+0x3e>
		return 0;
  800db6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbb:	eb 16                	jmp    800dd3 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	0f b6 00             	movzbl (%eax),%eax
  800dc3:	0f b6 d0             	movzbl %al,%edx
  800dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc9:	0f b6 00             	movzbl (%eax),%eax
  800dcc:	0f b6 c0             	movzbl %al,%eax
  800dcf:	29 c2                	sub    %eax,%edx
  800dd1:	89 d0                	mov    %edx,%eax
}
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dde:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de1:	eb 14                	jmp    800df7 <strchr+0x22>
		if (*s == c)
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dec:	75 05                	jne    800df3 <strchr+0x1e>
			return (char *) s;
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	eb 13                	jmp    800e06 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	0f b6 00             	movzbl (%eax),%eax
  800dfd:	84 c0                	test   %al,%al
  800dff:	75 e2                	jne    800de3 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e14:	eb 11                	jmp    800e27 <strfind+0x1f>
		if (*s == c)
  800e16:	8b 45 08             	mov    0x8(%ebp),%eax
  800e19:	0f b6 00             	movzbl (%eax),%eax
  800e1c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e1f:	75 02                	jne    800e23 <strfind+0x1b>
			break;
  800e21:	eb 0e                	jmp    800e31 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e23:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	0f b6 00             	movzbl (%eax),%eax
  800e2d:	84 c0                	test   %al,%al
  800e2f:	75 e5                	jne    800e16 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e3e:	75 05                	jne    800e45 <memset+0xf>
		return v;
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	eb 5c                	jmp    800ea1 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	83 e0 03             	and    $0x3,%eax
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	75 41                	jne    800e90 <memset+0x5a>
  800e4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e52:	83 e0 03             	and    $0x3,%eax
  800e55:	85 c0                	test   %eax,%eax
  800e57:	75 37                	jne    800e90 <memset+0x5a>
		c &= 0xFF;
  800e59:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e63:	c1 e0 18             	shl    $0x18,%eax
  800e66:	89 c2                	mov    %eax,%edx
  800e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6b:	c1 e0 10             	shl    $0x10,%eax
  800e6e:	09 c2                	or     %eax,%edx
  800e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e73:	c1 e0 08             	shl    $0x8,%eax
  800e76:	09 d0                	or     %edx,%eax
  800e78:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7e:	c1 e8 02             	shr    $0x2,%eax
  800e81:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e89:	89 d7                	mov    %edx,%edi
  800e8b:	fc                   	cld    
  800e8c:	f3 ab                	rep stos %eax,%es:(%edi)
  800e8e:	eb 0e                	jmp    800e9e <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	fc                   	cld    
  800e9c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ebf:	73 6d                	jae    800f2e <memmove+0x8a>
  800ec1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec7:	01 d0                	add    %edx,%eax
  800ec9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ecc:	76 60                	jbe    800f2e <memmove+0x8a>
		s += n;
  800ece:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed1:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ed4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed7:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edd:	83 e0 03             	and    $0x3,%eax
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	75 2f                	jne    800f13 <memmove+0x6f>
  800ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee7:	83 e0 03             	and    $0x3,%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	75 25                	jne    800f13 <memmove+0x6f>
  800eee:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef1:	83 e0 03             	and    $0x3,%eax
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	75 1b                	jne    800f13 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efb:	83 e8 04             	sub    $0x4,%eax
  800efe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f01:	83 ea 04             	sub    $0x4,%edx
  800f04:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f07:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f0a:	89 c7                	mov    %eax,%edi
  800f0c:	89 d6                	mov    %edx,%esi
  800f0e:	fd                   	std    
  800f0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f11:	eb 18                	jmp    800f2b <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f16:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1c:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f22:	89 d7                	mov    %edx,%edi
  800f24:	89 de                	mov    %ebx,%esi
  800f26:	89 c1                	mov    %eax,%ecx
  800f28:	fd                   	std    
  800f29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f2b:	fc                   	cld    
  800f2c:	eb 45                	jmp    800f73 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f31:	83 e0 03             	and    $0x3,%eax
  800f34:	85 c0                	test   %eax,%eax
  800f36:	75 2b                	jne    800f63 <memmove+0xbf>
  800f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3b:	83 e0 03             	and    $0x3,%eax
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	75 21                	jne    800f63 <memmove+0xbf>
  800f42:	8b 45 10             	mov    0x10(%ebp),%eax
  800f45:	83 e0 03             	and    $0x3,%eax
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	75 17                	jne    800f63 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	c1 e8 02             	shr    $0x2,%eax
  800f52:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f57:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f5a:	89 c7                	mov    %eax,%edi
  800f5c:	89 d6                	mov    %edx,%esi
  800f5e:	fc                   	cld    
  800f5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f61:	eb 10                	jmp    800f73 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f66:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f69:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f6c:	89 c7                	mov    %eax,%edi
  800f6e:	89 d6                	mov    %edx,%esi
  800f70:	fc                   	cld    
  800f71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f73:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f84:	8b 45 10             	mov    0x10(%ebp),%eax
  800f87:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f92:	8b 45 08             	mov    0x8(%ebp),%eax
  800f95:	89 04 24             	mov    %eax,(%esp)
  800f98:	e8 07 ff ff ff       	call   800ea4 <memmove>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fae:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fb1:	eb 30                	jmp    800fe3 <memcmp+0x44>
		if (*s1 != *s2)
  800fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fb6:	0f b6 10             	movzbl (%eax),%edx
  800fb9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fbc:	0f b6 00             	movzbl (%eax),%eax
  800fbf:	38 c2                	cmp    %al,%dl
  800fc1:	74 18                	je     800fdb <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc6:	0f b6 00             	movzbl (%eax),%eax
  800fc9:	0f b6 d0             	movzbl %al,%edx
  800fcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fcf:	0f b6 00             	movzbl (%eax),%eax
  800fd2:	0f b6 c0             	movzbl %al,%eax
  800fd5:	29 c2                	sub    %eax,%edx
  800fd7:	89 d0                	mov    %edx,%eax
  800fd9:	eb 1a                	jmp    800ff5 <memcmp+0x56>
		s1++, s2++;
  800fdb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fdf:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe9:	89 55 10             	mov    %edx,0x10(%ebp)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	75 c3                	jne    800fb3 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ffd:	8b 45 10             	mov    0x10(%ebp),%eax
  801000:	8b 55 08             	mov    0x8(%ebp),%edx
  801003:	01 d0                	add    %edx,%eax
  801005:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801008:	eb 13                	jmp    80101d <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	0f b6 10             	movzbl (%eax),%edx
  801010:	8b 45 0c             	mov    0xc(%ebp),%eax
  801013:	38 c2                	cmp    %al,%dl
  801015:	75 02                	jne    801019 <memfind+0x22>
			break;
  801017:	eb 0c                	jmp    801025 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801019:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
  801020:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801023:	72 e5                	jb     80100a <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801028:	c9                   	leave  
  801029:	c3                   	ret    

0080102a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801030:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801037:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103e:	eb 04                	jmp    801044 <strtol+0x1a>
		s++;
  801040:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	0f b6 00             	movzbl (%eax),%eax
  80104a:	3c 20                	cmp    $0x20,%al
  80104c:	74 f2                	je     801040 <strtol+0x16>
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	0f b6 00             	movzbl (%eax),%eax
  801054:	3c 09                	cmp    $0x9,%al
  801056:	74 e8                	je     801040 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801058:	8b 45 08             	mov    0x8(%ebp),%eax
  80105b:	0f b6 00             	movzbl (%eax),%eax
  80105e:	3c 2b                	cmp    $0x2b,%al
  801060:	75 06                	jne    801068 <strtol+0x3e>
		s++;
  801062:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801066:	eb 15                	jmp    80107d <strtol+0x53>
	else if (*s == '-')
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	0f b6 00             	movzbl (%eax),%eax
  80106e:	3c 2d                	cmp    $0x2d,%al
  801070:	75 0b                	jne    80107d <strtol+0x53>
		s++, neg = 1;
  801072:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801076:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80107d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801081:	74 06                	je     801089 <strtol+0x5f>
  801083:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801087:	75 24                	jne    8010ad <strtol+0x83>
  801089:	8b 45 08             	mov    0x8(%ebp),%eax
  80108c:	0f b6 00             	movzbl (%eax),%eax
  80108f:	3c 30                	cmp    $0x30,%al
  801091:	75 1a                	jne    8010ad <strtol+0x83>
  801093:	8b 45 08             	mov    0x8(%ebp),%eax
  801096:	83 c0 01             	add    $0x1,%eax
  801099:	0f b6 00             	movzbl (%eax),%eax
  80109c:	3c 78                	cmp    $0x78,%al
  80109e:	75 0d                	jne    8010ad <strtol+0x83>
		s += 2, base = 16;
  8010a0:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010a4:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010ab:	eb 2a                	jmp    8010d7 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b1:	75 17                	jne    8010ca <strtol+0xa0>
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	0f b6 00             	movzbl (%eax),%eax
  8010b9:	3c 30                	cmp    $0x30,%al
  8010bb:	75 0d                	jne    8010ca <strtol+0xa0>
		s++, base = 8;
  8010bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010c1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010c8:	eb 0d                	jmp    8010d7 <strtol+0xad>
	else if (base == 0)
  8010ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ce:	75 07                	jne    8010d7 <strtol+0xad>
		base = 10;
  8010d0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010da:	0f b6 00             	movzbl (%eax),%eax
  8010dd:	3c 2f                	cmp    $0x2f,%al
  8010df:	7e 1b                	jle    8010fc <strtol+0xd2>
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e4:	0f b6 00             	movzbl (%eax),%eax
  8010e7:	3c 39                	cmp    $0x39,%al
  8010e9:	7f 11                	jg     8010fc <strtol+0xd2>
			dig = *s - '0';
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	0f b6 00             	movzbl (%eax),%eax
  8010f1:	0f be c0             	movsbl %al,%eax
  8010f4:	83 e8 30             	sub    $0x30,%eax
  8010f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010fa:	eb 48                	jmp    801144 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ff:	0f b6 00             	movzbl (%eax),%eax
  801102:	3c 60                	cmp    $0x60,%al
  801104:	7e 1b                	jle    801121 <strtol+0xf7>
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	0f b6 00             	movzbl (%eax),%eax
  80110c:	3c 7a                	cmp    $0x7a,%al
  80110e:	7f 11                	jg     801121 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	0f b6 00             	movzbl (%eax),%eax
  801116:	0f be c0             	movsbl %al,%eax
  801119:	83 e8 57             	sub    $0x57,%eax
  80111c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80111f:	eb 23                	jmp    801144 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	0f b6 00             	movzbl (%eax),%eax
  801127:	3c 40                	cmp    $0x40,%al
  801129:	7e 3d                	jle    801168 <strtol+0x13e>
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	0f b6 00             	movzbl (%eax),%eax
  801131:	3c 5a                	cmp    $0x5a,%al
  801133:	7f 33                	jg     801168 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	0f b6 00             	movzbl (%eax),%eax
  80113b:	0f be c0             	movsbl %al,%eax
  80113e:	83 e8 37             	sub    $0x37,%eax
  801141:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801144:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801147:	3b 45 10             	cmp    0x10(%ebp),%eax
  80114a:	7c 02                	jl     80114e <strtol+0x124>
			break;
  80114c:	eb 1a                	jmp    801168 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80114e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801152:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801155:	0f af 45 10          	imul   0x10(%ebp),%eax
  801159:	89 c2                	mov    %eax,%edx
  80115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115e:	01 d0                	add    %edx,%eax
  801160:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801163:	e9 6f ff ff ff       	jmp    8010d7 <strtol+0xad>

	if (endptr)
  801168:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80116c:	74 08                	je     801176 <strtol+0x14c>
		*endptr = (char *) s;
  80116e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
  801174:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801176:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80117a:	74 07                	je     801183 <strtol+0x159>
  80117c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80117f:	f7 d8                	neg    %eax
  801181:	eb 03                	jmp    801186 <strtol+0x15c>
  801183:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801186:	c9                   	leave  
  801187:	c3                   	ret    
  801188:	66 90                	xchg   %ax,%ax
  80118a:	66 90                	xchg   %ax,%ax
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
