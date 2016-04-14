
obj/user/buggyhello:     file format elf32-i386


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
	sys_cputs((char*)1, 1);
  800039:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
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
  8000ec:	c7 44 24 08 4a 14 80 	movl   $0x80144a,0x8(%esp)
  8000f3:	00 
  8000f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000fb:	00 
  8000fc:	c7 04 24 67 14 80 00 	movl   $0x801467,(%esp)
  800103:	e8 6f 03 00 00       	call   800477 <_panic>

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

00800434 <sys_exec>:

void sys_exec(char* buf){
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800444:	00 
  800445:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80044c:	00 
  80044d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800454:	00 
  800455:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80045c:	00 
  80045d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800461:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800468:	00 
  800469:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800470:	e8 3d fc ff ff       	call   8000b2 <syscall>
}
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	53                   	push   %ebx
  80047b:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80047e:	8d 45 14             	lea    0x14(%ebp),%eax
  800481:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800484:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80048a:	e8 4d fd ff ff       	call   8001dc <sys_getenvid>
  80048f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800492:	89 54 24 10          	mov    %edx,0x10(%esp)
  800496:	8b 55 08             	mov    0x8(%ebp),%edx
  800499:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	c7 04 24 78 14 80 00 	movl   $0x801478,(%esp)
  8004ac:	e8 e1 00 00 00       	call   800592 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	e8 6b 00 00 00       	call   80052e <vcprintf>
	cprintf("\n");
  8004c3:	c7 04 24 9b 14 80 00 	movl   $0x80149b,(%esp)
  8004ca:	e8 c3 00 00 00       	call   800592 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004cf:	cc                   	int3   
  8004d0:	eb fd                	jmp    8004cf <_panic+0x58>

008004d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	8d 48 01             	lea    0x1(%eax),%ecx
  8004e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e3:	89 0a                	mov    %ecx,(%edx)
  8004e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e8:	89 d1                	mov    %edx,%ecx
  8004ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ed:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004fb:	75 20                	jne    80051d <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800500:	8b 00                	mov    (%eax),%eax
  800502:	8b 55 0c             	mov    0xc(%ebp),%edx
  800505:	83 c2 08             	add    $0x8,%edx
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	89 14 24             	mov    %edx,(%esp)
  80050f:	e8 ff fb ff ff       	call   800113 <sys_cputs>
		b->idx = 0;
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
  800517:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80051d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800520:	8b 40 04             	mov    0x4(%eax),%eax
  800523:	8d 50 01             	lea    0x1(%eax),%edx
  800526:	8b 45 0c             	mov    0xc(%ebp),%eax
  800529:	89 50 04             	mov    %edx,0x4(%eax)
}
  80052c:	c9                   	leave  
  80052d:	c3                   	ret    

0080052e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800537:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80053e:	00 00 00 
	b.cnt = 0;
  800541:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800548:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800552:	8b 45 08             	mov    0x8(%ebp),%eax
  800555:	89 44 24 08          	mov    %eax,0x8(%esp)
  800559:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	c7 04 24 d2 04 80 00 	movl   $0x8004d2,(%esp)
  80056a:	e8 bd 01 00 00       	call   80072c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80056f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80057f:	83 c0 08             	add    $0x8,%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	e8 89 fb ff ff       	call   800113 <sys_cputs>

	return b.cnt;
  80058a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800590:	c9                   	leave  
  800591:	c3                   	ret    

00800592 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800592:	55                   	push   %ebp
  800593:	89 e5                	mov    %esp,%ebp
  800595:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800598:	8d 45 0c             	lea    0xc(%ebp),%eax
  80059b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80059e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	e8 7e ff ff ff       	call   80052e <vcprintf>
  8005b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005b6:	c9                   	leave  
  8005b7:	c3                   	ret    

008005b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	53                   	push   %ebx
  8005bc:	83 ec 34             	sub    $0x34,%esp
  8005bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005cb:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005d6:	77 72                	ja     80064a <printnum+0x92>
  8005d8:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005db:	72 05                	jb     8005e2 <printnum+0x2a>
  8005dd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005e0:	77 68                	ja     80064a <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005e5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005e8:	8b 45 18             	mov    0x18(%ebp),%eax
  8005eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	89 54 24 04          	mov    %edx,0x4(%esp)
  800605:	e8 96 0b 00 00       	call   8011a0 <__udivdi3>
  80060a:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80060d:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800611:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800615:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800618:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80061c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800620:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800624:	8b 45 0c             	mov    0xc(%ebp),%eax
  800627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062b:	8b 45 08             	mov    0x8(%ebp),%eax
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	e8 82 ff ff ff       	call   8005b8 <printnum>
  800636:	eb 1c                	jmp    800654 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800638:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063f:	8b 45 20             	mov    0x20(%ebp),%eax
  800642:	89 04 24             	mov    %eax,(%esp)
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80064a:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80064e:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800652:	7f e4                	jg     800638 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800654:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800657:	bb 00 00 00 00       	mov    $0x0,%ebx
  80065c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800662:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800666:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800671:	e8 5a 0c 00 00       	call   8012d0 <__umoddi3>
  800676:	05 68 15 80 00       	add    $0x801568,%eax
  80067b:	0f b6 00             	movzbl (%eax),%eax
  80067e:	0f be c0             	movsbl %al,%eax
  800681:	8b 55 0c             	mov    0xc(%ebp),%edx
  800684:	89 54 24 04          	mov    %edx,0x4(%esp)
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	ff d0                	call   *%eax
}
  800690:	83 c4 34             	add    $0x34,%esp
  800693:	5b                   	pop    %ebx
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800699:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80069d:	7e 14                	jle    8006b3 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	8b 00                	mov    (%eax),%eax
  8006a4:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006aa:	89 0a                	mov    %ecx,(%edx)
  8006ac:	8b 50 04             	mov    0x4(%eax),%edx
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	eb 30                	jmp    8006e3 <getuint+0x4d>
	else if (lflag)
  8006b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b7:	74 16                	je     8006cf <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c4:	89 0a                	mov    %ecx,(%edx)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006cd:	eb 14                	jmp    8006e3 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006da:	89 0a                	mov    %ecx,(%edx)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    

008006e5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006e8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006ec:	7e 14                	jle    800702 <getint+0x1d>
		return va_arg(*ap, long long);
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	8d 48 08             	lea    0x8(%eax),%ecx
  8006f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f9:	89 0a                	mov    %ecx,(%edx)
  8006fb:	8b 50 04             	mov    0x4(%eax),%edx
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	eb 28                	jmp    80072a <getint+0x45>
	else if (lflag)
  800702:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800706:	74 12                	je     80071a <getint+0x35>
		return va_arg(*ap, long);
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	8b 00                	mov    (%eax),%eax
  80070d:	8d 48 04             	lea    0x4(%eax),%ecx
  800710:	8b 55 08             	mov    0x8(%ebp),%edx
  800713:	89 0a                	mov    %ecx,(%edx)
  800715:	8b 00                	mov    (%eax),%eax
  800717:	99                   	cltd   
  800718:	eb 10                	jmp    80072a <getint+0x45>
	else
		return va_arg(*ap, int);
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	8d 48 04             	lea    0x4(%eax),%ecx
  800722:	8b 55 08             	mov    0x8(%ebp),%edx
  800725:	89 0a                	mov    %ecx,(%edx)
  800727:	8b 00                	mov    (%eax),%eax
  800729:	99                   	cltd   
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800734:	eb 18                	jmp    80074e <vprintfmt+0x22>
			if (ch == '\0')
  800736:	85 db                	test   %ebx,%ebx
  800738:	75 05                	jne    80073f <vprintfmt+0x13>
				return;
  80073a:	e9 cc 03 00 00       	jmp    800b0b <vprintfmt+0x3df>
			putch(ch, putdat);
  80073f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	89 1c 24             	mov    %ebx,(%esp)
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	8d 50 01             	lea    0x1(%eax),%edx
  800754:	89 55 10             	mov    %edx,0x10(%ebp)
  800757:	0f b6 00             	movzbl (%eax),%eax
  80075a:	0f b6 d8             	movzbl %al,%ebx
  80075d:	83 fb 25             	cmp    $0x25,%ebx
  800760:	75 d4                	jne    800736 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800762:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800766:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80076d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800774:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80077b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	8d 50 01             	lea    0x1(%eax),%edx
  800788:	89 55 10             	mov    %edx,0x10(%ebp)
  80078b:	0f b6 00             	movzbl (%eax),%eax
  80078e:	0f b6 d8             	movzbl %al,%ebx
  800791:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800794:	83 f8 55             	cmp    $0x55,%eax
  800797:	0f 87 3d 03 00 00    	ja     800ada <vprintfmt+0x3ae>
  80079d:	8b 04 85 8c 15 80 00 	mov    0x80158c(,%eax,4),%eax
  8007a4:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a6:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007aa:	eb d6                	jmp    800782 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007ac:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007b0:	eb d0                	jmp    800782 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007bc:	89 d0                	mov    %edx,%eax
  8007be:	c1 e0 02             	shl    $0x2,%eax
  8007c1:	01 d0                	add    %edx,%eax
  8007c3:	01 c0                	add    %eax,%eax
  8007c5:	01 d8                	add    %ebx,%eax
  8007c7:	83 e8 30             	sub    $0x30,%eax
  8007ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	0f b6 00             	movzbl (%eax),%eax
  8007d3:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007d6:	83 fb 2f             	cmp    $0x2f,%ebx
  8007d9:	7e 0b                	jle    8007e6 <vprintfmt+0xba>
  8007db:	83 fb 39             	cmp    $0x39,%ebx
  8007de:	7f 06                	jg     8007e6 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007e4:	eb d3                	jmp    8007b9 <vprintfmt+0x8d>
			goto process_precision;
  8007e6:	eb 33                	jmp    80081b <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007f6:	eb 23                	jmp    80081b <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007fc:	79 0c                	jns    80080a <vprintfmt+0xde>
				width = 0;
  8007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800805:	e9 78 ff ff ff       	jmp    800782 <vprintfmt+0x56>
  80080a:	e9 73 ff ff ff       	jmp    800782 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80080f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800816:	e9 67 ff ff ff       	jmp    800782 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80081b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081f:	79 12                	jns    800833 <vprintfmt+0x107>
				width = precision, precision = -1;
  800821:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800824:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800827:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80082e:	e9 4f ff ff ff       	jmp    800782 <vprintfmt+0x56>
  800833:	e9 4a ff ff ff       	jmp    800782 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800838:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80083c:	e9 41 ff ff ff       	jmp    800782 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8d 50 04             	lea    0x4(%eax),%edx
  800847:	89 55 14             	mov    %edx,0x14(%ebp)
  80084a:	8b 00                	mov    (%eax),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	ff d0                	call   *%eax
			break;
  80085b:	e9 a5 02 00 00       	jmp    800b05 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80086b:	85 db                	test   %ebx,%ebx
  80086d:	79 02                	jns    800871 <vprintfmt+0x145>
				err = -err;
  80086f:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800871:	83 fb 09             	cmp    $0x9,%ebx
  800874:	7f 0b                	jg     800881 <vprintfmt+0x155>
  800876:	8b 34 9d 40 15 80 00 	mov    0x801540(,%ebx,4),%esi
  80087d:	85 f6                	test   %esi,%esi
  80087f:	75 23                	jne    8008a4 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800881:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800885:	c7 44 24 08 79 15 80 	movl   $0x801579,0x8(%esp)
  80088c:	00 
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	e8 73 02 00 00       	call   800b12 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80089f:	e9 61 02 00 00       	jmp    800b05 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008a8:	c7 44 24 08 82 15 80 	movl   $0x801582,0x8(%esp)
  8008af:	00 
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	e8 50 02 00 00       	call   800b12 <printfmt>
			break;
  8008c2:	e9 3e 02 00 00       	jmp    800b05 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 50 04             	lea    0x4(%eax),%edx
  8008cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d0:	8b 30                	mov    (%eax),%esi
  8008d2:	85 f6                	test   %esi,%esi
  8008d4:	75 05                	jne    8008db <vprintfmt+0x1af>
				p = "(null)";
  8008d6:	be 85 15 80 00       	mov    $0x801585,%esi
			if (width > 0 && padc != '-')
  8008db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008df:	7e 37                	jle    800918 <vprintfmt+0x1ec>
  8008e1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008e5:	74 31                	je     800918 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	89 34 24             	mov    %esi,(%esp)
  8008f1:	e8 39 03 00 00       	call   800c2f <strnlen>
  8008f6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008f9:	eb 17                	jmp    800912 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008fb:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800902:	89 54 24 04          	mov    %edx,0x4(%esp)
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80090e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800912:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800916:	7f e3                	jg     8008fb <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800918:	eb 38                	jmp    800952 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80091a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80091e:	74 1f                	je     80093f <vprintfmt+0x213>
  800920:	83 fb 1f             	cmp    $0x1f,%ebx
  800923:	7e 05                	jle    80092a <vprintfmt+0x1fe>
  800925:	83 fb 7e             	cmp    $0x7e,%ebx
  800928:	7e 15                	jle    80093f <vprintfmt+0x213>
					putch('?', putdat);
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800931:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	ff d0                	call   *%eax
  80093d:	eb 0f                	jmp    80094e <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	89 44 24 04          	mov    %eax,0x4(%esp)
  800946:	89 1c 24             	mov    %ebx,(%esp)
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800952:	89 f0                	mov    %esi,%eax
  800954:	8d 70 01             	lea    0x1(%eax),%esi
  800957:	0f b6 00             	movzbl (%eax),%eax
  80095a:	0f be d8             	movsbl %al,%ebx
  80095d:	85 db                	test   %ebx,%ebx
  80095f:	74 10                	je     800971 <vprintfmt+0x245>
  800961:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800965:	78 b3                	js     80091a <vprintfmt+0x1ee>
  800967:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80096b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80096f:	79 a9                	jns    80091a <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800971:	eb 17                	jmp    80098a <vprintfmt+0x25e>
				putch(' ', putdat);
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800986:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80098a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80098e:	7f e3                	jg     800973 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800990:	e9 70 01 00 00       	jmp    800b05 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800995:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800998:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099c:	8d 45 14             	lea    0x14(%ebp),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	e8 3e fd ff ff       	call   8006e5 <getint>
  8009a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009b3:	85 d2                	test   %edx,%edx
  8009b5:	79 26                	jns    8009dd <vprintfmt+0x2b1>
				putch('-', putdat);
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009be:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	ff d0                	call   *%eax
				num = -(long long) num;
  8009ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d0:	f7 d8                	neg    %eax
  8009d2:	83 d2 00             	adc    $0x0,%edx
  8009d5:	f7 da                	neg    %edx
  8009d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009da:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009dd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009e4:	e9 a8 00 00 00       	jmp    800a91 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f3:	89 04 24             	mov    %eax,(%esp)
  8009f6:	e8 9b fc ff ff       	call   800696 <getuint>
  8009fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a01:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a08:	e9 84 00 00 00       	jmp    800a91 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8d 45 14             	lea    0x14(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 77 fc ff ff       	call   800696 <getuint>
  800a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a22:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a25:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a2c:	eb 63                	jmp    800a91 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a35:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	ff d0                	call   *%eax
			putch('x', putdat);
  800a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a54:	8b 45 14             	mov    0x14(%ebp),%eax
  800a57:	8d 50 04             	lea    0x4(%eax),%edx
  800a5a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a5d:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a69:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a70:	eb 1f                	jmp    800a91 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a79:	8d 45 14             	lea    0x14(%ebp),%eax
  800a7c:	89 04 24             	mov    %eax,(%esp)
  800a7f:	e8 12 fc ff ff       	call   800696 <getuint>
  800a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a87:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a8a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a91:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a98:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a9f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800aa3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	89 04 24             	mov    %eax,(%esp)
  800ac2:	e8 f1 fa ff ff       	call   8005b8 <printnum>
			break;
  800ac7:	eb 3c                	jmp    800b05 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	89 1c 24             	mov    %ebx,(%esp)
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	ff d0                	call   *%eax
			break;
  800ad8:	eb 2b                	jmp    800b05 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aed:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800af1:	eb 04                	jmp    800af7 <vprintfmt+0x3cb>
  800af3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800af7:	8b 45 10             	mov    0x10(%ebp),%eax
  800afa:	83 e8 01             	sub    $0x1,%eax
  800afd:	0f b6 00             	movzbl (%eax),%eax
  800b00:	3c 25                	cmp    $0x25,%al
  800b02:	75 ef                	jne    800af3 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b04:	90                   	nop
		}
	}
  800b05:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b06:	e9 43 fc ff ff       	jmp    80074e <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b0b:	83 c4 40             	add    $0x40,%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b18:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b25:	8b 45 10             	mov    0x10(%ebp),%eax
  800b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 ee fb ff ff       	call   80072c <vprintfmt>
	va_end(ap);
}
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	8b 40 08             	mov    0x8(%eax),%eax
  800b49:	8d 50 01             	lea    0x1(%eax),%edx
  800b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4f:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	8b 10                	mov    (%eax),%edx
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	8b 40 04             	mov    0x4(%eax),%eax
  800b5d:	39 c2                	cmp    %eax,%edx
  800b5f:	73 12                	jae    800b73 <sprintputch+0x33>
		*b->buf++ = ch;
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	8b 00                	mov    (%eax),%eax
  800b66:	8d 48 01             	lea    0x1(%eax),%ecx
  800b69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6c:	89 0a                	mov    %ecx,(%edx)
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	88 10                	mov    %dl,(%eax)
}
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	01 d0                	add    %edx,%eax
  800b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b96:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b9a:	74 06                	je     800ba2 <vsnprintf+0x2d>
  800b9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba0:	7f 07                	jg     800ba9 <vsnprintf+0x34>
		return -E_INVAL;
  800ba2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ba7:	eb 2a                	jmp    800bd3 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ba9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbe:	c7 04 24 40 0b 80 00 	movl   $0x800b40,(%esp)
  800bc5:	e8 62 fb ff ff       	call   80072c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bcd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bdb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be8:	8b 45 10             	mov    0x10(%ebp),%eax
  800beb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	89 04 24             	mov    %eax,(%esp)
  800bfc:	e8 74 ff ff ff       	call   800b75 <vsnprintf>
  800c01:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c0f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c16:	eb 08                	jmp    800c20 <strlen+0x17>
		n++;
  800c18:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	0f b6 00             	movzbl (%eax),%eax
  800c26:	84 c0                	test   %al,%al
  800c28:	75 ee                	jne    800c18 <strlen+0xf>
		n++;
	return n;
  800c2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c35:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c3c:	eb 0c                	jmp    800c4a <strnlen+0x1b>
		n++;
  800c3e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c42:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c46:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4e:	74 0a                	je     800c5a <strnlen+0x2b>
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	0f b6 00             	movzbl (%eax),%eax
  800c56:	84 c0                	test   %al,%al
  800c58:	75 e4                	jne    800c3e <strnlen+0xf>
		n++;
	return n;
  800c5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c65:	8b 45 08             	mov    0x8(%ebp),%eax
  800c68:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c6b:	90                   	nop
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8d 50 01             	lea    0x1(%eax),%edx
  800c72:	89 55 08             	mov    %edx,0x8(%ebp)
  800c75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c78:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c7b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c7e:	0f b6 12             	movzbl (%edx),%edx
  800c81:	88 10                	mov    %dl,(%eax)
  800c83:	0f b6 00             	movzbl (%eax),%eax
  800c86:	84 c0                	test   %al,%al
  800c88:	75 e2                	jne    800c6c <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 69 ff ff ff       	call   800c09 <strlen>
  800ca0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800ca3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	01 c2                	add    %eax,%edx
  800cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb2:	89 14 24             	mov    %edx,(%esp)
  800cb5:	e8 a5 ff ff ff       	call   800c5f <strcpy>
	return dst;
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cbd:	c9                   	leave  
  800cbe:	c3                   	ret    

00800cbf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800ccb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cd2:	eb 23                	jmp    800cf7 <strncpy+0x38>
		*dst++ = *src;
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	8d 50 01             	lea    0x1(%eax),%edx
  800cda:	89 55 08             	mov    %edx,0x8(%ebp)
  800cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce0:	0f b6 12             	movzbl (%edx),%edx
  800ce3:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	0f b6 00             	movzbl (%eax),%eax
  800ceb:	84 c0                	test   %al,%al
  800ced:	74 04                	je     800cf3 <strncpy+0x34>
			src++;
  800cef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cfa:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cfd:	72 d5                	jb     800cd4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cff:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d14:	74 33                	je     800d49 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d16:	eb 17                	jmp    800d2f <strlcpy+0x2b>
			*dst++ = *src++;
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	8d 50 01             	lea    0x1(%eax),%edx
  800d1e:	89 55 08             	mov    %edx,0x8(%ebp)
  800d21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d24:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d27:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d2a:	0f b6 12             	movzbl (%edx),%edx
  800d2d:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d2f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d37:	74 0a                	je     800d43 <strlcpy+0x3f>
  800d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3c:	0f b6 00             	movzbl (%eax),%eax
  800d3f:	84 c0                	test   %al,%al
  800d41:	75 d5                	jne    800d18 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d4f:	29 c2                	sub    %eax,%edx
  800d51:	89 d0                	mov    %edx,%eax
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    

00800d55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d58:	eb 08                	jmp    800d62 <strcmp+0xd>
		p++, q++;
  800d5a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d5e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	84 c0                	test   %al,%al
  800d6a:	74 10                	je     800d7c <strcmp+0x27>
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	0f b6 10             	movzbl (%eax),%edx
  800d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d75:	0f b6 00             	movzbl (%eax),%eax
  800d78:	38 c2                	cmp    %al,%dl
  800d7a:	74 de                	je     800d5a <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	0f b6 00             	movzbl (%eax),%eax
  800d82:	0f b6 d0             	movzbl %al,%edx
  800d85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d88:	0f b6 00             	movzbl (%eax),%eax
  800d8b:	0f b6 c0             	movzbl %al,%eax
  800d8e:	29 c2                	sub    %eax,%edx
  800d90:	89 d0                	mov    %edx,%eax
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d97:	eb 0c                	jmp    800da5 <strncmp+0x11>
		n--, p++, q++;
  800d99:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d9d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800da1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800da5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da9:	74 1a                	je     800dc5 <strncmp+0x31>
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	84 c0                	test   %al,%al
  800db3:	74 10                	je     800dc5 <strncmp+0x31>
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	0f b6 10             	movzbl (%eax),%edx
  800dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbe:	0f b6 00             	movzbl (%eax),%eax
  800dc1:	38 c2                	cmp    %al,%dl
  800dc3:	74 d4                	je     800d99 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dc5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc9:	75 07                	jne    800dd2 <strncmp+0x3e>
		return 0;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd0:	eb 16                	jmp    800de8 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	0f b6 00             	movzbl (%eax),%eax
  800dd8:	0f b6 d0             	movzbl %al,%edx
  800ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dde:	0f b6 00             	movzbl (%eax),%eax
  800de1:	0f b6 c0             	movzbl %al,%eax
  800de4:	29 c2                	sub    %eax,%edx
  800de6:	89 d0                	mov    %edx,%eax
}
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800df6:	eb 14                	jmp    800e0c <strchr+0x22>
		if (*s == c)
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	0f b6 00             	movzbl (%eax),%eax
  800dfe:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e01:	75 05                	jne    800e08 <strchr+0x1e>
			return (char *) s;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	eb 13                	jmp    800e1b <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e08:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	0f b6 00             	movzbl (%eax),%eax
  800e12:	84 c0                	test   %al,%al
  800e14:	75 e2                	jne    800df8 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1b:	c9                   	leave  
  800e1c:	c3                   	ret    

00800e1d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e26:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e29:	eb 11                	jmp    800e3c <strfind+0x1f>
		if (*s == c)
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	0f b6 00             	movzbl (%eax),%eax
  800e31:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e34:	75 02                	jne    800e38 <strfind+0x1b>
			break;
  800e36:	eb 0e                	jmp    800e46 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	0f b6 00             	movzbl (%eax),%eax
  800e42:	84 c0                	test   %al,%al
  800e44:	75 e5                	jne    800e2b <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e53:	75 05                	jne    800e5a <memset+0xf>
		return v;
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	eb 5c                	jmp    800eb6 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	83 e0 03             	and    $0x3,%eax
  800e60:	85 c0                	test   %eax,%eax
  800e62:	75 41                	jne    800ea5 <memset+0x5a>
  800e64:	8b 45 10             	mov    0x10(%ebp),%eax
  800e67:	83 e0 03             	and    $0x3,%eax
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	75 37                	jne    800ea5 <memset+0x5a>
		c &= 0xFF;
  800e6e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e78:	c1 e0 18             	shl    $0x18,%eax
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e80:	c1 e0 10             	shl    $0x10,%eax
  800e83:	09 c2                	or     %eax,%edx
  800e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e88:	c1 e0 08             	shl    $0x8,%eax
  800e8b:	09 d0                	or     %edx,%eax
  800e8d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e90:	8b 45 10             	mov    0x10(%ebp),%eax
  800e93:	c1 e8 02             	shr    $0x2,%eax
  800e96:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	89 d7                	mov    %edx,%edi
  800ea0:	fc                   	cld    
  800ea1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ea3:	eb 0e                	jmp    800eb3 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ea5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800eae:	89 d7                	mov    %edx,%edi
  800eb0:	fc                   	cld    
  800eb1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed4:	73 6d                	jae    800f43 <memmove+0x8a>
  800ed6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800edc:	01 d0                	add    %edx,%eax
  800ede:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ee1:	76 60                	jbe    800f43 <memmove+0x8a>
		s += n;
  800ee3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee6:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ee9:	8b 45 10             	mov    0x10(%ebp),%eax
  800eec:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef2:	83 e0 03             	and    $0x3,%eax
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 2f                	jne    800f28 <memmove+0x6f>
  800ef9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efc:	83 e0 03             	and    $0x3,%eax
  800eff:	85 c0                	test   %eax,%eax
  800f01:	75 25                	jne    800f28 <memmove+0x6f>
  800f03:	8b 45 10             	mov    0x10(%ebp),%eax
  800f06:	83 e0 03             	and    $0x3,%eax
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	75 1b                	jne    800f28 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f10:	83 e8 04             	sub    $0x4,%eax
  800f13:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f16:	83 ea 04             	sub    $0x4,%edx
  800f19:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f1c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f1f:	89 c7                	mov    %eax,%edi
  800f21:	89 d6                	mov    %edx,%esi
  800f23:	fd                   	std    
  800f24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f26:	eb 18                	jmp    800f40 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f31:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f34:	8b 45 10             	mov    0x10(%ebp),%eax
  800f37:	89 d7                	mov    %edx,%edi
  800f39:	89 de                	mov    %ebx,%esi
  800f3b:	89 c1                	mov    %eax,%ecx
  800f3d:	fd                   	std    
  800f3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f40:	fc                   	cld    
  800f41:	eb 45                	jmp    800f88 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f46:	83 e0 03             	and    $0x3,%eax
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	75 2b                	jne    800f78 <memmove+0xbf>
  800f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f50:	83 e0 03             	and    $0x3,%eax
  800f53:	85 c0                	test   %eax,%eax
  800f55:	75 21                	jne    800f78 <memmove+0xbf>
  800f57:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5a:	83 e0 03             	and    $0x3,%eax
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	75 17                	jne    800f78 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f61:	8b 45 10             	mov    0x10(%ebp),%eax
  800f64:	c1 e8 02             	shr    $0x2,%eax
  800f67:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f69:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f6f:	89 c7                	mov    %eax,%edi
  800f71:	89 d6                	mov    %edx,%esi
  800f73:	fc                   	cld    
  800f74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f76:	eb 10                	jmp    800f88 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f81:	89 c7                	mov    %eax,%edi
  800f83:	89 d6                	mov    %edx,%esi
  800f85:	fc                   	cld    
  800f86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f99:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	89 04 24             	mov    %eax,(%esp)
  800fad:	e8 07 ff ff ff       	call   800eb9 <memmove>
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc3:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fc6:	eb 30                	jmp    800ff8 <memcmp+0x44>
		if (*s1 != *s2)
  800fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fcb:	0f b6 10             	movzbl (%eax),%edx
  800fce:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd1:	0f b6 00             	movzbl (%eax),%eax
  800fd4:	38 c2                	cmp    %al,%dl
  800fd6:	74 18                	je     800ff0 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fdb:	0f b6 00             	movzbl (%eax),%eax
  800fde:	0f b6 d0             	movzbl %al,%edx
  800fe1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fe4:	0f b6 00             	movzbl (%eax),%eax
  800fe7:	0f b6 c0             	movzbl %al,%eax
  800fea:	29 c2                	sub    %eax,%edx
  800fec:	89 d0                	mov    %edx,%eax
  800fee:	eb 1a                	jmp    80100a <memcmp+0x56>
		s1++, s2++;
  800ff0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ff4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ffe:	89 55 10             	mov    %edx,0x10(%ebp)
  801001:	85 c0                	test   %eax,%eax
  801003:	75 c3                	jne    800fc8 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801012:	8b 45 10             	mov    0x10(%ebp),%eax
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	01 d0                	add    %edx,%eax
  80101a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80101d:	eb 13                	jmp    801032 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
  801022:	0f b6 10             	movzbl (%eax),%edx
  801025:	8b 45 0c             	mov    0xc(%ebp),%eax
  801028:	38 c2                	cmp    %al,%dl
  80102a:	75 02                	jne    80102e <memfind+0x22>
			break;
  80102c:	eb 0c                	jmp    80103a <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80102e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801038:	72 e5                	jb     80101f <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80103d:	c9                   	leave  
  80103e:	c3                   	ret    

0080103f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801045:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80104c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801053:	eb 04                	jmp    801059 <strtol+0x1a>
		s++;
  801055:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	0f b6 00             	movzbl (%eax),%eax
  80105f:	3c 20                	cmp    $0x20,%al
  801061:	74 f2                	je     801055 <strtol+0x16>
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	0f b6 00             	movzbl (%eax),%eax
  801069:	3c 09                	cmp    $0x9,%al
  80106b:	74 e8                	je     801055 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80106d:	8b 45 08             	mov    0x8(%ebp),%eax
  801070:	0f b6 00             	movzbl (%eax),%eax
  801073:	3c 2b                	cmp    $0x2b,%al
  801075:	75 06                	jne    80107d <strtol+0x3e>
		s++;
  801077:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107b:	eb 15                	jmp    801092 <strtol+0x53>
	else if (*s == '-')
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	0f b6 00             	movzbl (%eax),%eax
  801083:	3c 2d                	cmp    $0x2d,%al
  801085:	75 0b                	jne    801092 <strtol+0x53>
		s++, neg = 1;
  801087:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80108b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801092:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801096:	74 06                	je     80109e <strtol+0x5f>
  801098:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80109c:	75 24                	jne    8010c2 <strtol+0x83>
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	0f b6 00             	movzbl (%eax),%eax
  8010a4:	3c 30                	cmp    $0x30,%al
  8010a6:	75 1a                	jne    8010c2 <strtol+0x83>
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	83 c0 01             	add    $0x1,%eax
  8010ae:	0f b6 00             	movzbl (%eax),%eax
  8010b1:	3c 78                	cmp    $0x78,%al
  8010b3:	75 0d                	jne    8010c2 <strtol+0x83>
		s += 2, base = 16;
  8010b5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010b9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010c0:	eb 2a                	jmp    8010ec <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c6:	75 17                	jne    8010df <strtol+0xa0>
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	0f b6 00             	movzbl (%eax),%eax
  8010ce:	3c 30                	cmp    $0x30,%al
  8010d0:	75 0d                	jne    8010df <strtol+0xa0>
		s++, base = 8;
  8010d2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010d6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010dd:	eb 0d                	jmp    8010ec <strtol+0xad>
	else if (base == 0)
  8010df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e3:	75 07                	jne    8010ec <strtol+0xad>
		base = 10;
  8010e5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	0f b6 00             	movzbl (%eax),%eax
  8010f2:	3c 2f                	cmp    $0x2f,%al
  8010f4:	7e 1b                	jle    801111 <strtol+0xd2>
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	0f b6 00             	movzbl (%eax),%eax
  8010fc:	3c 39                	cmp    $0x39,%al
  8010fe:	7f 11                	jg     801111 <strtol+0xd2>
			dig = *s - '0';
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	0f b6 00             	movzbl (%eax),%eax
  801106:	0f be c0             	movsbl %al,%eax
  801109:	83 e8 30             	sub    $0x30,%eax
  80110c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80110f:	eb 48                	jmp    801159 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	0f b6 00             	movzbl (%eax),%eax
  801117:	3c 60                	cmp    $0x60,%al
  801119:	7e 1b                	jle    801136 <strtol+0xf7>
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	0f b6 00             	movzbl (%eax),%eax
  801121:	3c 7a                	cmp    $0x7a,%al
  801123:	7f 11                	jg     801136 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
  801128:	0f b6 00             	movzbl (%eax),%eax
  80112b:	0f be c0             	movsbl %al,%eax
  80112e:	83 e8 57             	sub    $0x57,%eax
  801131:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801134:	eb 23                	jmp    801159 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	0f b6 00             	movzbl (%eax),%eax
  80113c:	3c 40                	cmp    $0x40,%al
  80113e:	7e 3d                	jle    80117d <strtol+0x13e>
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	0f b6 00             	movzbl (%eax),%eax
  801146:	3c 5a                	cmp    $0x5a,%al
  801148:	7f 33                	jg     80117d <strtol+0x13e>
			dig = *s - 'A' + 10;
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	0f b6 00             	movzbl (%eax),%eax
  801150:	0f be c0             	movsbl %al,%eax
  801153:	83 e8 37             	sub    $0x37,%eax
  801156:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115c:	3b 45 10             	cmp    0x10(%ebp),%eax
  80115f:	7c 02                	jl     801163 <strtol+0x124>
			break;
  801161:	eb 1a                	jmp    80117d <strtol+0x13e>
		s++, val = (val * base) + dig;
  801163:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801167:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80116a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80116e:	89 c2                	mov    %eax,%edx
  801170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801173:	01 d0                	add    %edx,%eax
  801175:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801178:	e9 6f ff ff ff       	jmp    8010ec <strtol+0xad>

	if (endptr)
  80117d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801181:	74 08                	je     80118b <strtol+0x14c>
		*endptr = (char *) s;
  801183:	8b 45 0c             	mov    0xc(%ebp),%eax
  801186:	8b 55 08             	mov    0x8(%ebp),%edx
  801189:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80118b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80118f:	74 07                	je     801198 <strtol+0x159>
  801191:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801194:	f7 d8                	neg    %eax
  801196:	eb 03                	jmp    80119b <strtol+0x15c>
  801198:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    
  80119d:	66 90                	xchg   %ax,%ax
  80119f:	90                   	nop

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
