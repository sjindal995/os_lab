
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800048:	e8 c6 00 00 00       	call   800113 <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800055:	e8 82 01 00 00       	call   8001dc <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	c1 e0 02             	shl    $0x2,%eax
  800062:	89 c2                	mov    %eax,%edx
  800064:	c1 e2 05             	shl    $0x5,%edx
  800067:	29 c2                	sub    %eax,%edx
  800069:	89 d0                	mov    %edx,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800079:	7e 0a                	jle    800085 <libmain+0x36>
		binaryname = argv[0];
  80007b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007e:	8b 00                	mov    (%eax),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800085:	8b 45 0c             	mov    0xc(%ebp),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	8b 45 08             	mov    0x8(%ebp),%eax
  80008f:	89 04 24             	mov    %eax,(%esp)
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 02 00 00 00       	call   80009e <exit>
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ab:	e8 e9 00 00 00       	call   800199 <sys_env_destroy>
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000be:	8b 55 10             	mov    0x10(%ebp),%edx
  8000c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000c4:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000c7:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000ca:	8b 75 20             	mov    0x20(%ebp),%esi
  8000cd:	cd 30                	int    $0x30
  8000cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000d6:	74 30                	je     800108 <syscall+0x56>
  8000d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000dc:	7e 2a                	jle    800108 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ec:	c7 44 24 08 0a 14 80 	movl   $0x80140a,0x8(%esp)
  8000f3:	00 
  8000f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000fb:	00 
  8000fc:	c7 04 24 27 14 80 00 	movl   $0x801427,(%esp)
  800103:	e8 2c 03 00 00       	call   800434 <_panic>

	return ret;
  800108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800123:	00 
  800124:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80012b:	00 
  80012c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800133:	00 
  800134:	8b 55 0c             	mov    0xc(%ebp),%edx
  800137:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80013b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 5f ff ff ff       	call   8000b2 <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_cgetc>:

int
sys_cgetc(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80015b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800162:	00 
  800163:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80016a:	00 
  80016b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800172:	00 
  800173:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80017a:	00 
  80017b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800182:	00 
  800183:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80018a:	00 
  80018b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800192:	e8 1b ff ff ff       	call   8000b2 <syscall>
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001b1:	00 
  8001b2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c1:	00 
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001cd:	00 
  8001ce:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001d5:	e8 d8 fe ff ff       	call   8000b2 <syscall>
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001e2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800219:	e8 94 fe ff ff       	call   8000b2 <syscall>
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_yield>:

void
sys_yield(void)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800226:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80022d:	00 
  80022e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800235:	00 
  800236:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80023d:	00 
  80023e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800245:	00 
  800246:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024d:	00 
  80024e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800255:	00 
  800256:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80025d:	e8 50 fe ff ff       	call   8000b2 <syscall>
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80026a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80027a:	00 
  80027b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800282:	00 
  800283:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800287:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80028b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800296:	00 
  800297:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80029e:	e8 0f fe ff ff       	call   8000b2 <syscall>
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002ad:	8b 75 18             	mov    0x18(%ebp),%esi
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002c0:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002c4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d7:	00 
  8002d8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002df:	e8 ce fd ff ff       	call   8000b2 <syscall>
}
  8002e4:	83 c4 20             	add    $0x20,%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002fe:	00 
  8002ff:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800306:	00 
  800307:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80030e:	00 
  80030f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031e:	00 
  80031f:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800326:	e8 87 fd ff ff       	call   8000b2 <syscall>
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800340:	00 
  800341:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800348:	00 
  800349:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800350:	00 
  800351:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800355:	89 44 24 08          	mov    %eax,0x8(%esp)
  800359:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800360:	00 
  800361:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800368:	e8 45 fd ff ff       	call   8000b2 <syscall>
}
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800375:	8b 55 0c             	mov    0xc(%ebp),%edx
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800382:	00 
  800383:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80038a:	00 
  80038b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800392:	00 
  800393:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003a2:	00 
  8003a3:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003aa:	e8 03 fd ff ff       	call   8000b2 <syscall>
}
  8003af:	c9                   	leave  
  8003b0:	c3                   	ret    

008003b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003c7:	00 
  8003c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e2:	00 
  8003e3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003ea:	e8 c3 fc ff ff       	call   8000b2 <syscall>
}
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800401:	00 
  800402:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800409:	00 
  80040a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800411:	00 
  800412:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800419:	00 
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800425:	00 
  800426:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80042d:	e8 80 fc ff ff       	call   8000b2 <syscall>
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	53                   	push   %ebx
  800438:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80043b:	8d 45 14             	lea    0x14(%ebp),%eax
  80043e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800441:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800447:	e8 90 fd ff ff       	call   8001dc <sys_getenvid>
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800453:	8b 55 08             	mov    0x8(%ebp),%edx
  800456:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80045e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800462:	c7 04 24 38 14 80 00 	movl   $0x801438,(%esp)
  800469:	e8 e1 00 00 00       	call   80054f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800471:	89 44 24 04          	mov    %eax,0x4(%esp)
  800475:	8b 45 10             	mov    0x10(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 6b 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  800480:	c7 04 24 5b 14 80 00 	movl   $0x80145b,(%esp)
  800487:	e8 c3 00 00 00       	call   80054f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048c:	cc                   	int3   
  80048d:	eb fd                	jmp    80048c <_panic+0x58>

0080048f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800495:	8b 45 0c             	mov    0xc(%ebp),%eax
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	8d 48 01             	lea    0x1(%eax),%ecx
  80049d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a0:	89 0a                	mov    %ecx,(%edx)
  8004a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a5:	89 d1                	mov    %edx,%ecx
  8004a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004aa:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b8:	75 20                	jne    8004da <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c2:	83 c2 08             	add    $0x8,%edx
  8004c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c9:	89 14 24             	mov    %edx,(%esp)
  8004cc:	e8 42 fc ff ff       	call   800113 <sys_cputs>
		b->idx = 0;
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dd:	8b 40 04             	mov    0x4(%eax),%eax
  8004e0:	8d 50 01             	lea    0x1(%eax),%edx
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e6:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 8f 04 80 00 	movl   $0x80048f,(%esp)
  800527:	e8 bd 01 00 00       	call   8006e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80053c:	83 c0 08             	add    $0x8,%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	e8 cc fb ff ff       	call   800113 <sys_cputs>

	return b.cnt;
  800547:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80054d:	c9                   	leave  
  80054e:	c3                   	ret    

0080054f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800555:	8d 45 0c             	lea    0xc(%ebp),%eax
  800558:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80055b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800562:	8b 45 08             	mov    0x8(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	e8 7e ff ff ff       	call   8004eb <vcprintf>
  80056d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800570:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	53                   	push   %ebx
  800579:	83 ec 34             	sub    $0x34,%esp
  80057c:	8b 45 10             	mov    0x10(%ebp),%eax
  80057f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	8b 45 18             	mov    0x18(%ebp),%eax
  80058b:	ba 00 00 00 00       	mov    $0x0,%edx
  800590:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800593:	77 72                	ja     800607 <printnum+0x92>
  800595:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800598:	72 05                	jb     80059f <printnum+0x2a>
  80059a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80059d:	77 68                	ja     800607 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c2:	e8 99 0b 00 00       	call   801160 <__udivdi3>
  8005c7:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005ca:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005ce:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005d2:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005d5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 82 ff ff ff       	call   800575 <printnum>
  8005f3:	eb 1c                	jmp    800611 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	8b 45 20             	mov    0x20(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800607:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80060b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80060f:	7f e4                	jg     8005f5 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800611:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800614:	bb 00 00 00 00       	mov    $0x0,%ebx
  800619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80061f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800623:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062e:	e8 5d 0c 00 00       	call   801290 <__umoddi3>
  800633:	05 28 15 80 00       	add    $0x801528,%eax
  800638:	0f b6 00             	movzbl (%eax),%eax
  80063b:	0f be c0             	movsbl %al,%eax
  80063e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800641:	89 54 24 04          	mov    %edx,0x4(%esp)
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	ff d0                	call   *%eax
}
  80064d:	83 c4 34             	add    $0x34,%esp
  800650:	5b                   	pop    %ebx
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800656:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80065a:	7e 14                	jle    800670 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	8d 48 08             	lea    0x8(%eax),%ecx
  800664:	8b 55 08             	mov    0x8(%ebp),%edx
  800667:	89 0a                	mov    %ecx,(%edx)
  800669:	8b 50 04             	mov    0x4(%eax),%edx
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	eb 30                	jmp    8006a0 <getuint+0x4d>
	else if (lflag)
  800670:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800674:	74 16                	je     80068c <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	8d 48 04             	lea    0x4(%eax),%ecx
  80067e:	8b 55 08             	mov    0x8(%ebp),%edx
  800681:	89 0a                	mov    %ecx,(%edx)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
  80068a:	eb 14                	jmp    8006a0 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	8d 48 04             	lea    0x4(%eax),%ecx
  800694:	8b 55 08             	mov    0x8(%ebp),%edx
  800697:	89 0a                	mov    %ecx,(%edx)
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006a9:	7e 14                	jle    8006bf <getint+0x1d>
		return va_arg(*ap, long long);
  8006ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	8d 48 08             	lea    0x8(%eax),%ecx
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b6:	89 0a                	mov    %ecx,(%edx)
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	eb 28                	jmp    8006e7 <getint+0x45>
	else if (lflag)
  8006bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c3:	74 12                	je     8006d7 <getint+0x35>
		return va_arg(*ap, long);
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d0:	89 0a                	mov    %ecx,(%edx)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	99                   	cltd   
  8006d5:	eb 10                	jmp    8006e7 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e2:	89 0a                	mov    %ecx,(%edx)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	99                   	cltd   
}
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	56                   	push   %esi
  8006ed:	53                   	push   %ebx
  8006ee:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f1:	eb 18                	jmp    80070b <vprintfmt+0x22>
			if (ch == '\0')
  8006f3:	85 db                	test   %ebx,%ebx
  8006f5:	75 05                	jne    8006fc <vprintfmt+0x13>
				return;
  8006f7:	e9 cc 03 00 00       	jmp    800ac8 <vprintfmt+0x3df>
			putch(ch, putdat);
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	89 1c 24             	mov    %ebx,(%esp)
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070b:	8b 45 10             	mov    0x10(%ebp),%eax
  80070e:	8d 50 01             	lea    0x1(%eax),%edx
  800711:	89 55 10             	mov    %edx,0x10(%ebp)
  800714:	0f b6 00             	movzbl (%eax),%eax
  800717:	0f b6 d8             	movzbl %al,%ebx
  80071a:	83 fb 25             	cmp    $0x25,%ebx
  80071d:	75 d4                	jne    8006f3 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80071f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800723:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80072a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800731:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800738:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 45 10             	mov    0x10(%ebp),%eax
  800742:	8d 50 01             	lea    0x1(%eax),%edx
  800745:	89 55 10             	mov    %edx,0x10(%ebp)
  800748:	0f b6 00             	movzbl (%eax),%eax
  80074b:	0f b6 d8             	movzbl %al,%ebx
  80074e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800751:	83 f8 55             	cmp    $0x55,%eax
  800754:	0f 87 3d 03 00 00    	ja     800a97 <vprintfmt+0x3ae>
  80075a:	8b 04 85 4c 15 80 00 	mov    0x80154c(,%eax,4),%eax
  800761:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800763:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800767:	eb d6                	jmp    80073f <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80076d:	eb d0                	jmp    80073f <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800776:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800779:	89 d0                	mov    %edx,%eax
  80077b:	c1 e0 02             	shl    $0x2,%eax
  80077e:	01 d0                	add    %edx,%eax
  800780:	01 c0                	add    %eax,%eax
  800782:	01 d8                	add    %ebx,%eax
  800784:	83 e8 30             	sub    $0x30,%eax
  800787:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	0f b6 00             	movzbl (%eax),%eax
  800790:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800793:	83 fb 2f             	cmp    $0x2f,%ebx
  800796:	7e 0b                	jle    8007a3 <vprintfmt+0xba>
  800798:	83 fb 39             	cmp    $0x39,%ebx
  80079b:	7f 06                	jg     8007a3 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007a1:	eb d3                	jmp    800776 <vprintfmt+0x8d>
			goto process_precision;
  8007a3:	eb 33                	jmp    8007d8 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 04             	lea    0x4(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	8b 00                	mov    (%eax),%eax
  8007b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007b3:	eb 23                	jmp    8007d8 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b9:	79 0c                	jns    8007c7 <vprintfmt+0xde>
				width = 0;
  8007bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007c2:	e9 78 ff ff ff       	jmp    80073f <vprintfmt+0x56>
  8007c7:	e9 73 ff ff ff       	jmp    80073f <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007cc:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007d3:	e9 67 ff ff ff       	jmp    80073f <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007dc:	79 12                	jns    8007f0 <vprintfmt+0x107>
				width = precision, precision = -1;
  8007de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007eb:	e9 4f ff ff ff       	jmp    80073f <vprintfmt+0x56>
  8007f0:	e9 4a ff ff ff       	jmp    80073f <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007f9:	e9 41 ff ff ff       	jmp    80073f <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 50 04             	lea    0x4(%eax),%edx
  800804:	89 55 14             	mov    %edx,0x14(%ebp)
  800807:	8b 00                	mov    (%eax),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	ff d0                	call   *%eax
			break;
  800818:	e9 a5 02 00 00       	jmp    800ac2 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 04             	lea    0x4(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800828:	85 db                	test   %ebx,%ebx
  80082a:	79 02                	jns    80082e <vprintfmt+0x145>
				err = -err;
  80082c:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082e:	83 fb 09             	cmp    $0x9,%ebx
  800831:	7f 0b                	jg     80083e <vprintfmt+0x155>
  800833:	8b 34 9d 00 15 80 00 	mov    0x801500(,%ebx,4),%esi
  80083a:	85 f6                	test   %esi,%esi
  80083c:	75 23                	jne    800861 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80083e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800842:	c7 44 24 08 39 15 80 	movl   $0x801539,0x8(%esp)
  800849:	00 
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	e8 73 02 00 00       	call   800acf <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80085c:	e9 61 02 00 00       	jmp    800ac2 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800861:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800865:	c7 44 24 08 42 15 80 	movl   $0x801542,0x8(%esp)
  80086c:	00 
  80086d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800870:	89 44 24 04          	mov    %eax,0x4(%esp)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	e8 50 02 00 00       	call   800acf <printfmt>
			break;
  80087f:	e9 3e 02 00 00       	jmp    800ac2 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 50 04             	lea    0x4(%eax),%edx
  80088a:	89 55 14             	mov    %edx,0x14(%ebp)
  80088d:	8b 30                	mov    (%eax),%esi
  80088f:	85 f6                	test   %esi,%esi
  800891:	75 05                	jne    800898 <vprintfmt+0x1af>
				p = "(null)";
  800893:	be 45 15 80 00       	mov    $0x801545,%esi
			if (width > 0 && padc != '-')
  800898:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089c:	7e 37                	jle    8008d5 <vprintfmt+0x1ec>
  80089e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008a2:	74 31                	je     8008d5 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	89 34 24             	mov    %esi,(%esp)
  8008ae:	e8 39 03 00 00       	call   800bec <strnlen>
  8008b3:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008b6:	eb 17                	jmp    8008cf <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008b8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cb:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d3:	7f e3                	jg     8008b8 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d5:	eb 38                	jmp    80090f <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008db:	74 1f                	je     8008fc <vprintfmt+0x213>
  8008dd:	83 fb 1f             	cmp    $0x1f,%ebx
  8008e0:	7e 05                	jle    8008e7 <vprintfmt+0x1fe>
  8008e2:	83 fb 7e             	cmp    $0x7e,%ebx
  8008e5:	7e 15                	jle    8008fc <vprintfmt+0x213>
					putch('?', putdat);
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	ff d0                	call   *%eax
  8008fa:	eb 0f                	jmp    80090b <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80090f:	89 f0                	mov    %esi,%eax
  800911:	8d 70 01             	lea    0x1(%eax),%esi
  800914:	0f b6 00             	movzbl (%eax),%eax
  800917:	0f be d8             	movsbl %al,%ebx
  80091a:	85 db                	test   %ebx,%ebx
  80091c:	74 10                	je     80092e <vprintfmt+0x245>
  80091e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800922:	78 b3                	js     8008d7 <vprintfmt+0x1ee>
  800924:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800928:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80092c:	79 a9                	jns    8008d7 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	eb 17                	jmp    800947 <vprintfmt+0x25e>
				putch(' ', putdat);
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	89 44 24 04          	mov    %eax,0x4(%esp)
  800937:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800943:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800947:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094b:	7f e3                	jg     800930 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80094d:	e9 70 01 00 00       	jmp    800ac2 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800952:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800955:	89 44 24 04          	mov    %eax,0x4(%esp)
  800959:	8d 45 14             	lea    0x14(%ebp),%eax
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	e8 3e fd ff ff       	call   8006a2 <getint>
  800964:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800967:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80096a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800970:	85 d2                	test   %edx,%edx
  800972:	79 26                	jns    80099a <vprintfmt+0x2b1>
				putch('-', putdat);
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	ff d0                	call   *%eax
				num = -(long long) num;
  800987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80098a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80098d:	f7 d8                	neg    %eax
  80098f:	83 d2 00             	adc    $0x0,%edx
  800992:	f7 da                	neg    %edx
  800994:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800997:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80099a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009a1:	e9 a8 00 00 00       	jmp    800a4e <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b0:	89 04 24             	mov    %eax,(%esp)
  8009b3:	e8 9b fc ff ff       	call   800653 <getuint>
  8009b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009be:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c5:	e9 84 00 00 00       	jmp    800a4e <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d4:	89 04 24             	mov    %eax,(%esp)
  8009d7:	e8 77 fc ff ff       	call   800653 <getuint>
  8009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009df:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009e2:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009e9:	eb 63                	jmp    800a4e <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	ff d0                	call   *%eax
			putch('x', putdat);
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a05:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a11:	8b 45 14             	mov    0x14(%ebp),%eax
  800a14:	8d 50 04             	lea    0x4(%eax),%edx
  800a17:	89 55 14             	mov    %edx,0x14(%ebp)
  800a1a:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a26:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a2d:	eb 1f                	jmp    800a4e <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a36:	8d 45 14             	lea    0x14(%ebp),%eax
  800a39:	89 04 24             	mov    %eax,(%esp)
  800a3c:	e8 12 fc ff ff       	call   800653 <getuint>
  800a41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a44:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a47:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a4e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a55:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a5c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a60:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a79:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7c:	89 04 24             	mov    %eax,(%esp)
  800a7f:	e8 f1 fa ff ff       	call   800575 <printnum>
			break;
  800a84:	eb 3c                	jmp    800ac2 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8d:	89 1c 24             	mov    %ebx,(%esp)
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	ff d0                	call   *%eax
			break;
  800a95:	eb 2b                	jmp    800ac2 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aaa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aae:	eb 04                	jmp    800ab4 <vprintfmt+0x3cb>
  800ab0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ab4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab7:	83 e8 01             	sub    $0x1,%eax
  800aba:	0f b6 00             	movzbl (%eax),%eax
  800abd:	3c 25                	cmp    $0x25,%al
  800abf:	75 ef                	jne    800ab0 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800ac1:	90                   	nop
		}
	}
  800ac2:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ac3:	e9 43 fc ff ff       	jmp    80070b <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ac8:	83 c4 40             	add    $0x40,%esp
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ad5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ade:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ae2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 ee fb ff ff       	call   8006e9 <vprintfmt>
	va_end(ap);
}
  800afb:	c9                   	leave  
  800afc:	c3                   	ret    

00800afd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b03:	8b 40 08             	mov    0x8(%eax),%eax
  800b06:	8d 50 01             	lea    0x1(%eax),%edx
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b12:	8b 10                	mov    (%eax),%edx
  800b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b17:	8b 40 04             	mov    0x4(%eax),%eax
  800b1a:	39 c2                	cmp    %eax,%edx
  800b1c:	73 12                	jae    800b30 <sprintputch+0x33>
		*b->buf++ = ch;
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	8b 00                	mov    (%eax),%eax
  800b23:	8d 48 01             	lea    0x1(%eax),%ecx
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 0a                	mov    %ecx,(%edx)
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	88 10                	mov    %dl,(%eax)
}
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	01 d0                	add    %edx,%eax
  800b49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b57:	74 06                	je     800b5f <vsnprintf+0x2d>
  800b59:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5d:	7f 07                	jg     800b66 <vsnprintf+0x34>
		return -E_INVAL;
  800b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b64:	eb 2a                	jmp    800b90 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b66:	8b 45 14             	mov    0x14(%ebp),%eax
  800b69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b74:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7b:	c7 04 24 fd 0a 80 00 	movl   $0x800afd,(%esp)
  800b82:	e8 62 fb ff ff       	call   8006e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b98:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb6:	89 04 24             	mov    %eax,(%esp)
  800bb9:	e8 74 ff ff ff       	call   800b32 <vsnprintf>
  800bbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bcc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bd3:	eb 08                	jmp    800bdd <strlen+0x17>
		n++;
  800bd5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	0f b6 00             	movzbl (%eax),%eax
  800be3:	84 c0                	test   %al,%al
  800be5:	75 ee                	jne    800bd5 <strlen+0xf>
		n++;
	return n;
  800be7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bf9:	eb 0c                	jmp    800c07 <strnlen+0x1b>
		n++;
  800bfb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c03:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0b:	74 0a                	je     800c17 <strnlen+0x2b>
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	0f b6 00             	movzbl (%eax),%eax
  800c13:	84 c0                	test   %al,%al
  800c15:	75 e4                	jne    800bfb <strnlen+0xf>
		n++;
	return n;
  800c17:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    

00800c1c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c28:	90                   	nop
  800c29:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2c:	8d 50 01             	lea    0x1(%eax),%edx
  800c2f:	89 55 08             	mov    %edx,0x8(%ebp)
  800c32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c35:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c38:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c3b:	0f b6 12             	movzbl (%edx),%edx
  800c3e:	88 10                	mov    %dl,(%eax)
  800c40:	0f b6 00             	movzbl (%eax),%eax
  800c43:	84 c0                	test   %al,%al
  800c45:	75 e2                	jne    800c29 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c47:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    

00800c4c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 69 ff ff ff       	call   800bc6 <strlen>
  800c5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c60:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c63:	8b 45 08             	mov    0x8(%ebp),%eax
  800c66:	01 c2                	add    %eax,%edx
  800c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6f:	89 14 24             	mov    %edx,(%esp)
  800c72:	e8 a5 ff ff ff       	call   800c1c <strcpy>
	return dst;
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c82:	8b 45 08             	mov    0x8(%ebp),%eax
  800c85:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c88:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c8f:	eb 23                	jmp    800cb4 <strncpy+0x38>
		*dst++ = *src;
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8d 50 01             	lea    0x1(%eax),%edx
  800c97:	89 55 08             	mov    %edx,0x8(%ebp)
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9d:	0f b6 12             	movzbl (%edx),%edx
  800ca0:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca5:	0f b6 00             	movzbl (%eax),%eax
  800ca8:	84 c0                	test   %al,%al
  800caa:	74 04                	je     800cb0 <strncpy+0x34>
			src++;
  800cac:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cb7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cba:	72 d5                	jb     800c91 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800ccd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cd1:	74 33                	je     800d06 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cd3:	eb 17                	jmp    800cec <strlcpy+0x2b>
			*dst++ = *src++;
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	8d 50 01             	lea    0x1(%eax),%edx
  800cdb:	89 55 08             	mov    %edx,0x8(%ebp)
  800cde:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce1:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ce4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ce7:	0f b6 12             	movzbl (%edx),%edx
  800cea:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cec:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800cf0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf4:	74 0a                	je     800d00 <strlcpy+0x3f>
  800cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf9:	0f b6 00             	movzbl (%eax),%eax
  800cfc:	84 c0                	test   %al,%al
  800cfe:	75 d5                	jne    800cd5 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d0c:	29 c2                	sub    %eax,%edx
  800d0e:	89 d0                	mov    %edx,%eax
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d15:	eb 08                	jmp    800d1f <strcmp+0xd>
		p++, q++;
  800d17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d1b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	0f b6 00             	movzbl (%eax),%eax
  800d25:	84 c0                	test   %al,%al
  800d27:	74 10                	je     800d39 <strcmp+0x27>
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	0f b6 10             	movzbl (%eax),%edx
  800d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d32:	0f b6 00             	movzbl (%eax),%eax
  800d35:	38 c2                	cmp    %al,%dl
  800d37:	74 de                	je     800d17 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	0f b6 00             	movzbl (%eax),%eax
  800d3f:	0f b6 d0             	movzbl %al,%edx
  800d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d45:	0f b6 00             	movzbl (%eax),%eax
  800d48:	0f b6 c0             	movzbl %al,%eax
  800d4b:	29 c2                	sub    %eax,%edx
  800d4d:	89 d0                	mov    %edx,%eax
}
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d54:	eb 0c                	jmp    800d62 <strncmp+0x11>
		n--, p++, q++;
  800d56:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d66:	74 1a                	je     800d82 <strncmp+0x31>
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	0f b6 00             	movzbl (%eax),%eax
  800d6e:	84 c0                	test   %al,%al
  800d70:	74 10                	je     800d82 <strncmp+0x31>
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	0f b6 10             	movzbl (%eax),%edx
  800d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7b:	0f b6 00             	movzbl (%eax),%eax
  800d7e:	38 c2                	cmp    %al,%dl
  800d80:	74 d4                	je     800d56 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d86:	75 07                	jne    800d8f <strncmp+0x3e>
		return 0;
  800d88:	b8 00 00 00 00       	mov    $0x0,%eax
  800d8d:	eb 16                	jmp    800da5 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	0f b6 00             	movzbl (%eax),%eax
  800d95:	0f b6 d0             	movzbl %al,%edx
  800d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9b:	0f b6 00             	movzbl (%eax),%eax
  800d9e:	0f b6 c0             	movzbl %al,%eax
  800da1:	29 c2                	sub    %eax,%edx
  800da3:	89 d0                	mov    %edx,%eax
}
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db0:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800db3:	eb 14                	jmp    800dc9 <strchr+0x22>
		if (*s == c)
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	0f b6 00             	movzbl (%eax),%eax
  800dbb:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dbe:	75 05                	jne    800dc5 <strchr+0x1e>
			return (char *) s;
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	eb 13                	jmp    800dd8 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	0f b6 00             	movzbl (%eax),%eax
  800dcf:	84 c0                	test   %al,%al
  800dd1:	75 e2                	jne    800db5 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd8:	c9                   	leave  
  800dd9:	c3                   	ret    

00800dda <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 04             	sub    $0x4,%esp
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de6:	eb 11                	jmp    800df9 <strfind+0x1f>
		if (*s == c)
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	0f b6 00             	movzbl (%eax),%eax
  800dee:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df1:	75 02                	jne    800df5 <strfind+0x1b>
			break;
  800df3:	eb 0e                	jmp    800e03 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800df5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 00             	movzbl (%eax),%eax
  800dff:	84 c0                	test   %al,%al
  800e01:	75 e5                	jne    800de8 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e10:	75 05                	jne    800e17 <memset+0xf>
		return v;
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	eb 5c                	jmp    800e73 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	83 e0 03             	and    $0x3,%eax
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	75 41                	jne    800e62 <memset+0x5a>
  800e21:	8b 45 10             	mov    0x10(%ebp),%eax
  800e24:	83 e0 03             	and    $0x3,%eax
  800e27:	85 c0                	test   %eax,%eax
  800e29:	75 37                	jne    800e62 <memset+0x5a>
		c &= 0xFF;
  800e2b:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e35:	c1 e0 18             	shl    $0x18,%eax
  800e38:	89 c2                	mov    %eax,%edx
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	c1 e0 10             	shl    $0x10,%eax
  800e40:	09 c2                	or     %eax,%edx
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	c1 e0 08             	shl    $0x8,%eax
  800e48:	09 d0                	or     %edx,%eax
  800e4a:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e50:	c1 e8 02             	shr    $0x2,%eax
  800e53:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	89 d7                	mov    %edx,%edi
  800e5d:	fc                   	cld    
  800e5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800e60:	eb 0e                	jmp    800e70 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e6b:	89 d7                	mov    %edx,%edi
  800e6d:	fc                   	cld    
  800e6e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e91:	73 6d                	jae    800f00 <memmove+0x8a>
  800e93:	8b 45 10             	mov    0x10(%ebp),%eax
  800e96:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e99:	01 d0                	add    %edx,%eax
  800e9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e9e:	76 60                	jbe    800f00 <memmove+0x8a>
		s += n;
  800ea0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea3:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ea6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea9:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eaf:	83 e0 03             	and    $0x3,%eax
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	75 2f                	jne    800ee5 <memmove+0x6f>
  800eb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb9:	83 e0 03             	and    $0x3,%eax
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	75 25                	jne    800ee5 <memmove+0x6f>
  800ec0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec3:	83 e0 03             	and    $0x3,%eax
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	75 1b                	jne    800ee5 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ecd:	83 e8 04             	sub    $0x4,%eax
  800ed0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed3:	83 ea 04             	sub    $0x4,%edx
  800ed6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800edc:	89 c7                	mov    %eax,%edi
  800ede:	89 d6                	mov    %edx,%esi
  800ee0:	fd                   	std    
  800ee1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee3:	eb 18                	jmp    800efd <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee8:	8d 50 ff             	lea    -0x1(%eax),%edx
  800eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eee:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ef1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef4:	89 d7                	mov    %edx,%edi
  800ef6:	89 de                	mov    %ebx,%esi
  800ef8:	89 c1                	mov    %eax,%ecx
  800efa:	fd                   	std    
  800efb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800efd:	fc                   	cld    
  800efe:	eb 45                	jmp    800f45 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f03:	83 e0 03             	and    $0x3,%eax
  800f06:	85 c0                	test   %eax,%eax
  800f08:	75 2b                	jne    800f35 <memmove+0xbf>
  800f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f0d:	83 e0 03             	and    $0x3,%eax
  800f10:	85 c0                	test   %eax,%eax
  800f12:	75 21                	jne    800f35 <memmove+0xbf>
  800f14:	8b 45 10             	mov    0x10(%ebp),%eax
  800f17:	83 e0 03             	and    $0x3,%eax
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	75 17                	jne    800f35 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f21:	c1 e8 02             	shr    $0x2,%eax
  800f24:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f29:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f2c:	89 c7                	mov    %eax,%edi
  800f2e:	89 d6                	mov    %edx,%esi
  800f30:	fc                   	cld    
  800f31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f33:	eb 10                	jmp    800f45 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3e:	89 c7                	mov    %eax,%edi
  800f40:	89 d6                	mov    %edx,%esi
  800f42:	fc                   	cld    
  800f43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f56:	8b 45 10             	mov    0x10(%ebp),%eax
  800f59:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f64:	8b 45 08             	mov    0x8(%ebp),%eax
  800f67:	89 04 24             	mov    %eax,(%esp)
  800f6a:	e8 07 ff ff ff       	call   800e76 <memmove>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f80:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f83:	eb 30                	jmp    800fb5 <memcmp+0x44>
		if (*s1 != *s2)
  800f85:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f88:	0f b6 10             	movzbl (%eax),%edx
  800f8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f8e:	0f b6 00             	movzbl (%eax),%eax
  800f91:	38 c2                	cmp    %al,%dl
  800f93:	74 18                	je     800fad <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f98:	0f b6 00             	movzbl (%eax),%eax
  800f9b:	0f b6 d0             	movzbl %al,%edx
  800f9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fa1:	0f b6 00             	movzbl (%eax),%eax
  800fa4:	0f b6 c0             	movzbl %al,%eax
  800fa7:	29 c2                	sub    %eax,%edx
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	eb 1a                	jmp    800fc7 <memcmp+0x56>
		s1++, s2++;
  800fad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fb1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb8:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fbb:	89 55 10             	mov    %edx,0x10(%ebp)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	75 c3                	jne    800f85 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fcf:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	01 d0                	add    %edx,%eax
  800fd7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fda:	eb 13                	jmp    800fef <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	0f b6 10             	movzbl (%eax),%edx
  800fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe5:	38 c2                	cmp    %al,%dl
  800fe7:	75 02                	jne    800feb <memfind+0x22>
			break;
  800fe9:	eb 0c                	jmp    800ff7 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800feb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ff5:	72 e5                	jb     800fdc <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800ff7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801002:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801009:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801010:	eb 04                	jmp    801016 <strtol+0x1a>
		s++;
  801012:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	0f b6 00             	movzbl (%eax),%eax
  80101c:	3c 20                	cmp    $0x20,%al
  80101e:	74 f2                	je     801012 <strtol+0x16>
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	0f b6 00             	movzbl (%eax),%eax
  801026:	3c 09                	cmp    $0x9,%al
  801028:	74 e8                	je     801012 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	0f b6 00             	movzbl (%eax),%eax
  801030:	3c 2b                	cmp    $0x2b,%al
  801032:	75 06                	jne    80103a <strtol+0x3e>
		s++;
  801034:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801038:	eb 15                	jmp    80104f <strtol+0x53>
	else if (*s == '-')
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
  80103d:	0f b6 00             	movzbl (%eax),%eax
  801040:	3c 2d                	cmp    $0x2d,%al
  801042:	75 0b                	jne    80104f <strtol+0x53>
		s++, neg = 1;
  801044:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801048:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80104f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801053:	74 06                	je     80105b <strtol+0x5f>
  801055:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801059:	75 24                	jne    80107f <strtol+0x83>
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	0f b6 00             	movzbl (%eax),%eax
  801061:	3c 30                	cmp    $0x30,%al
  801063:	75 1a                	jne    80107f <strtol+0x83>
  801065:	8b 45 08             	mov    0x8(%ebp),%eax
  801068:	83 c0 01             	add    $0x1,%eax
  80106b:	0f b6 00             	movzbl (%eax),%eax
  80106e:	3c 78                	cmp    $0x78,%al
  801070:	75 0d                	jne    80107f <strtol+0x83>
		s += 2, base = 16;
  801072:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801076:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80107d:	eb 2a                	jmp    8010a9 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80107f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801083:	75 17                	jne    80109c <strtol+0xa0>
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
  801088:	0f b6 00             	movzbl (%eax),%eax
  80108b:	3c 30                	cmp    $0x30,%al
  80108d:	75 0d                	jne    80109c <strtol+0xa0>
		s++, base = 8;
  80108f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801093:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80109a:	eb 0d                	jmp    8010a9 <strtol+0xad>
	else if (base == 0)
  80109c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010a0:	75 07                	jne    8010a9 <strtol+0xad>
		base = 10;
  8010a2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ac:	0f b6 00             	movzbl (%eax),%eax
  8010af:	3c 2f                	cmp    $0x2f,%al
  8010b1:	7e 1b                	jle    8010ce <strtol+0xd2>
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b6:	0f b6 00             	movzbl (%eax),%eax
  8010b9:	3c 39                	cmp    $0x39,%al
  8010bb:	7f 11                	jg     8010ce <strtol+0xd2>
			dig = *s - '0';
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	0f b6 00             	movzbl (%eax),%eax
  8010c3:	0f be c0             	movsbl %al,%eax
  8010c6:	83 e8 30             	sub    $0x30,%eax
  8010c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010cc:	eb 48                	jmp    801116 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	0f b6 00             	movzbl (%eax),%eax
  8010d4:	3c 60                	cmp    $0x60,%al
  8010d6:	7e 1b                	jle    8010f3 <strtol+0xf7>
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	0f b6 00             	movzbl (%eax),%eax
  8010de:	3c 7a                	cmp    $0x7a,%al
  8010e0:	7f 11                	jg     8010f3 <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	0f b6 00             	movzbl (%eax),%eax
  8010e8:	0f be c0             	movsbl %al,%eax
  8010eb:	83 e8 57             	sub    $0x57,%eax
  8010ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f1:	eb 23                	jmp    801116 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	0f b6 00             	movzbl (%eax),%eax
  8010f9:	3c 40                	cmp    $0x40,%al
  8010fb:	7e 3d                	jle    80113a <strtol+0x13e>
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	0f b6 00             	movzbl (%eax),%eax
  801103:	3c 5a                	cmp    $0x5a,%al
  801105:	7f 33                	jg     80113a <strtol+0x13e>
			dig = *s - 'A' + 10;
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	0f b6 00             	movzbl (%eax),%eax
  80110d:	0f be c0             	movsbl %al,%eax
  801110:	83 e8 37             	sub    $0x37,%eax
  801113:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801119:	3b 45 10             	cmp    0x10(%ebp),%eax
  80111c:	7c 02                	jl     801120 <strtol+0x124>
			break;
  80111e:	eb 1a                	jmp    80113a <strtol+0x13e>
		s++, val = (val * base) + dig;
  801120:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801124:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801127:	0f af 45 10          	imul   0x10(%ebp),%eax
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801130:	01 d0                	add    %edx,%eax
  801132:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801135:	e9 6f ff ff ff       	jmp    8010a9 <strtol+0xad>

	if (endptr)
  80113a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80113e:	74 08                	je     801148 <strtol+0x14c>
		*endptr = (char *) s;
  801140:	8b 45 0c             	mov    0xc(%ebp),%eax
  801143:	8b 55 08             	mov    0x8(%ebp),%edx
  801146:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801148:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80114c:	74 07                	je     801155 <strtol+0x159>
  80114e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801151:	f7 d8                	neg    %eax
  801153:	eb 03                	jmp    801158 <strtol+0x15c>
  801155:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801158:	c9                   	leave  
  801159:	c3                   	ret    
  80115a:	66 90                	xchg   %ax,%ax
  80115c:	66 90                	xchg   %ax,%ax
  80115e:	66 90                	xchg   %ax,%ax

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
