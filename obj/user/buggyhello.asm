
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
  800048:	e8 b6 00 00 00       	call   800103 <sys_cputs>
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
  800055:	e8 72 01 00 00       	call   8001cc <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	c1 e0 02             	shl    $0x2,%eax
  800062:	89 c2                	mov    %eax,%edx
  800064:	c1 e2 05             	shl    $0x5,%edx
  800067:	29 c2                	sub    %eax,%edx
  800069:	89 d0                	mov    %edx,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800075:	8b 45 0c             	mov    0xc(%ebp),%eax
  800078:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007c:	8b 45 08             	mov    0x8(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 02 00 00 00       	call   80008e <exit>
}
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    

0080008e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009b:	e8 e9 00 00 00       	call   800189 <sys_env_destroy>
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
  8000a8:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8000b1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000b4:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b7:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000ba:	8b 75 20             	mov    0x20(%ebp),%esi
  8000bd:	cd 30                	int    $0x30
  8000bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c6:	74 30                	je     8000f8 <syscall+0x56>
  8000c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cc:	7e 2a                	jle    8000f8 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dc:	c7 44 24 08 8a 14 80 	movl   $0x80148a,0x8(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000eb:	00 
  8000ec:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  8000f3:	e8 b3 03 00 00       	call   8004ab <_panic>

	return ret;
  8000f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000fb:	83 c4 3c             	add    $0x3c,%esp
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800109:	8b 45 08             	mov    0x8(%ebp),%eax
  80010c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800113:	00 
  800114:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80011b:	00 
  80011c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800123:	00 
  800124:	8b 55 0c             	mov    0xc(%ebp),%edx
  800127:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80012b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013e:	e8 5f ff ff ff       	call   8000a2 <syscall>
}
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <sys_cgetc>:

int
sys_cgetc(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800152:	00 
  800153:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80015a:	00 
  80015b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800162:	00 
  800163:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80016a:	00 
  80016b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800182:	e8 1b ff ff ff       	call   8000a2 <syscall>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    

00800189 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80018f:	8b 45 08             	mov    0x8(%ebp),%eax
  800192:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800199:	00 
  80019a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b1:	00 
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001bd:	00 
  8001be:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c5:	e8 d8 fe ff ff       	call   8000a2 <syscall>
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001d2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d9:	00 
  8001da:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001e1:	00 
  8001e2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800201:	00 
  800202:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800209:	e8 94 fe ff ff       	call   8000a2 <syscall>
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <sys_yield>:

void
sys_yield(void)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800216:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80021d:	00 
  80021e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800225:	00 
  800226:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80022d:	00 
  80022e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800235:	00 
  800236:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80023d:	00 
  80023e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800245:	00 
  800246:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80024d:	e8 50 fe ff ff       	call   8000a2 <syscall>
}
  800252:	c9                   	leave  
  800253:	c3                   	ret    

00800254 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80025a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80026a:	00 
  80026b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800272:	00 
  800273:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800277:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800286:	00 
  800287:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80028e:	e8 0f fe ff ff       	call   8000a2 <syscall>
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
  8002a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002b0:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002b4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c7:	00 
  8002c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002cf:	e8 ce fd ff ff       	call   8000a2 <syscall>
}
  8002d4:	83 c4 20             	add    $0x20,%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f6:	00 
  8002f7:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002fe:	00 
  8002ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800303:	89 44 24 08          	mov    %eax,0x8(%esp)
  800307:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80030e:	00 
  80030f:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800316:	e8 87 fd ff ff       	call   8000a2 <syscall>
}
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800323:	8b 55 0c             	mov    0xc(%ebp),%edx
  800326:	8b 45 08             	mov    0x8(%ebp),%eax
  800329:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800330:	00 
  800331:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800338:	00 
  800339:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800340:	00 
  800341:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800345:	89 44 24 08          	mov    %eax,0x8(%esp)
  800349:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800350:	00 
  800351:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800358:	e8 45 fd ff ff       	call   8000a2 <syscall>
}
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    

0080035f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800365:	8b 55 0c             	mov    0xc(%ebp),%edx
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800372:	00 
  800373:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80037a:	00 
  80037b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800382:	00 
  800383:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800387:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800392:	00 
  800393:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80039a:	e8 03 fd ff ff       	call   8000a2 <syscall>
}
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    

008003a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003aa:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b7:	00 
  8003b8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003d2:	00 
  8003d3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003da:	e8 c3 fc ff ff       	call   8000a2 <syscall>
}
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    

008003e1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003f1:	00 
  8003f2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003f9:	00 
  8003fa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800401:	00 
  800402:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800409:	00 
  80040a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800415:	00 
  800416:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80041d:	e8 80 fc ff ff       	call   8000a2 <syscall>
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <sys_exec>:

void sys_exec(char* buf){
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80042a:	8b 45 08             	mov    0x8(%ebp),%eax
  80042d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800434:	00 
  800435:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80043c:	00 
  80043d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800444:	00 
  800445:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044c:	00 
  80044d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800451:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800458:	00 
  800459:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800460:	e8 3d fc ff ff       	call   8000a2 <syscall>
}
  800465:	c9                   	leave  
  800466:	c3                   	ret    

00800467 <sys_wait>:

void sys_wait(){
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80046d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800474:	00 
  800475:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80047c:	00 
  80047d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800484:	00 
  800485:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048c:	00 
  80048d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800494:	00 
  800495:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80049c:	00 
  80049d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8004a4:	e8 f9 fb ff ff       	call   8000a2 <syscall>
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	53                   	push   %ebx
  8004af:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8004b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004b8:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004be:	e8 09 fd ff ff       	call   8001cc <sys_getenvid>
  8004c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	c7 04 24 b8 14 80 00 	movl   $0x8014b8,(%esp)
  8004e0:	e8 e1 00 00 00       	call   8005c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	e8 6b 00 00 00       	call   800562 <vcprintf>
	cprintf("\n");
  8004f7:	c7 04 24 db 14 80 00 	movl   $0x8014db,(%esp)
  8004fe:	e8 c3 00 00 00       	call   8005c6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800503:	cc                   	int3   
  800504:	eb fd                	jmp    800503 <_panic+0x58>

00800506 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80050c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	8d 48 01             	lea    0x1(%eax),%ecx
  800514:	8b 55 0c             	mov    0xc(%ebp),%edx
  800517:	89 0a                	mov    %ecx,(%edx)
  800519:	8b 55 08             	mov    0x8(%ebp),%edx
  80051c:	89 d1                	mov    %edx,%ecx
  80051e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800521:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800525:	8b 45 0c             	mov    0xc(%ebp),%eax
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80052f:	75 20                	jne    800551 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800531:	8b 45 0c             	mov    0xc(%ebp),%eax
  800534:	8b 00                	mov    (%eax),%eax
  800536:	8b 55 0c             	mov    0xc(%ebp),%edx
  800539:	83 c2 08             	add    $0x8,%edx
  80053c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800540:	89 14 24             	mov    %edx,(%esp)
  800543:	e8 bb fb ff ff       	call   800103 <sys_cputs>
		b->idx = 0;
  800548:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800551:	8b 45 0c             	mov    0xc(%ebp),%eax
  800554:	8b 40 04             	mov    0x4(%eax),%eax
  800557:	8d 50 01             	lea    0x1(%eax),%edx
  80055a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80056b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800572:	00 00 00 
	b.cnt = 0;
  800575:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80057f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800586:	8b 45 08             	mov    0x8(%ebp),%eax
  800589:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800593:	89 44 24 04          	mov    %eax,0x4(%esp)
  800597:	c7 04 24 06 05 80 00 	movl   $0x800506,(%esp)
  80059e:	e8 bd 01 00 00       	call   800760 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005b3:	83 c0 08             	add    $0x8,%eax
  8005b6:	89 04 24             	mov    %eax,(%esp)
  8005b9:	e8 45 fb ff ff       	call   800103 <sys_cputs>

	return b.cnt;
  8005be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005c4:	c9                   	leave  
  8005c5:	c3                   	ret    

008005c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c6:	55                   	push   %ebp
  8005c7:	89 e5                	mov    %esp,%ebp
  8005c9:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005cc:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 7e ff ff ff       	call   800562 <vcprintf>
  8005e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005ea:	c9                   	leave  
  8005eb:	c3                   	ret    

008005ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005ec:	55                   	push   %ebp
  8005ed:	89 e5                	mov    %esp,%ebp
  8005ef:	53                   	push   %ebx
  8005f0:	83 ec 34             	sub    $0x34,%esp
  8005f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ff:	8b 45 18             	mov    0x18(%ebp),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
  800607:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80060a:	77 72                	ja     80067e <printnum+0x92>
  80060c:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80060f:	72 05                	jb     800616 <printnum+0x2a>
  800611:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800614:	77 68                	ja     80067e <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800616:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800619:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80061c:	8b 45 18             	mov    0x18(%ebp),%eax
  80061f:	ba 00 00 00 00       	mov    $0x0,%edx
  800624:	89 44 24 08          	mov    %eax,0x8(%esp)
  800628:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800632:	89 04 24             	mov    %eax,(%esp)
  800635:	89 54 24 04          	mov    %edx,0x4(%esp)
  800639:	e8 a2 0b 00 00       	call   8011e0 <__udivdi3>
  80063e:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800641:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800645:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800649:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80064c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800650:	89 44 24 08          	mov    %eax,0x8(%esp)
  800654:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	89 04 24             	mov    %eax,(%esp)
  800665:	e8 82 ff ff ff       	call   8005ec <printnum>
  80066a:	eb 1c                	jmp    800688 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80066c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800673:	8b 45 20             	mov    0x20(%ebp),%eax
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80067e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800682:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800686:	7f e4                	jg     80066c <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800688:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80068b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800693:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800696:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80069a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80069e:	89 04 24             	mov    %eax,(%esp)
  8006a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a5:	e8 66 0c 00 00       	call   801310 <__umoddi3>
  8006aa:	05 a8 15 80 00       	add    $0x8015a8,%eax
  8006af:	0f b6 00             	movzbl (%eax),%eax
  8006b2:	0f be c0             	movsbl %al,%eax
  8006b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	ff d0                	call   *%eax
}
  8006c4:	83 c4 34             	add    $0x34,%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006cd:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d1:	7e 14                	jle    8006e7 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	8d 48 08             	lea    0x8(%eax),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 0a                	mov    %ecx,(%edx)
  8006e0:	8b 50 04             	mov    0x4(%eax),%edx
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	eb 30                	jmp    800717 <getuint+0x4d>
	else if (lflag)
  8006e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006eb:	74 16                	je     800703 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f8:	89 0a                	mov    %ecx,(%edx)
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800701:	eb 14                	jmp    800717 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	8b 00                	mov    (%eax),%eax
  800708:	8d 48 04             	lea    0x4(%eax),%ecx
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
  80070e:	89 0a                	mov    %ecx,(%edx)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80071c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800720:	7e 14                	jle    800736 <getint+0x1d>
		return va_arg(*ap, long long);
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	8b 00                	mov    (%eax),%eax
  800727:	8d 48 08             	lea    0x8(%eax),%ecx
  80072a:	8b 55 08             	mov    0x8(%ebp),%edx
  80072d:	89 0a                	mov    %ecx,(%edx)
  80072f:	8b 50 04             	mov    0x4(%eax),%edx
  800732:	8b 00                	mov    (%eax),%eax
  800734:	eb 28                	jmp    80075e <getint+0x45>
	else if (lflag)
  800736:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80073a:	74 12                	je     80074e <getint+0x35>
		return va_arg(*ap, long);
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	8d 48 04             	lea    0x4(%eax),%ecx
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
  800747:	89 0a                	mov    %ecx,(%edx)
  800749:	8b 00                	mov    (%eax),%eax
  80074b:	99                   	cltd   
  80074c:	eb 10                	jmp    80075e <getint+0x45>
	else
		return va_arg(*ap, int);
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 00                	mov    (%eax),%eax
  800753:	8d 48 04             	lea    0x4(%eax),%ecx
  800756:	8b 55 08             	mov    0x8(%ebp),%edx
  800759:	89 0a                	mov    %ecx,(%edx)
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	99                   	cltd   
}
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	56                   	push   %esi
  800764:	53                   	push   %ebx
  800765:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800768:	eb 18                	jmp    800782 <vprintfmt+0x22>
			if (ch == '\0')
  80076a:	85 db                	test   %ebx,%ebx
  80076c:	75 05                	jne    800773 <vprintfmt+0x13>
				return;
  80076e:	e9 cc 03 00 00       	jmp    800b3f <vprintfmt+0x3df>
			putch(ch, putdat);
  800773:	8b 45 0c             	mov    0xc(%ebp),%eax
  800776:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077a:	89 1c 24             	mov    %ebx,(%esp)
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	8d 50 01             	lea    0x1(%eax),%edx
  800788:	89 55 10             	mov    %edx,0x10(%ebp)
  80078b:	0f b6 00             	movzbl (%eax),%eax
  80078e:	0f b6 d8             	movzbl %al,%ebx
  800791:	83 fb 25             	cmp    $0x25,%ebx
  800794:	75 d4                	jne    80076a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800796:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80079a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007a8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007af:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b9:	8d 50 01             	lea    0x1(%eax),%edx
  8007bc:	89 55 10             	mov    %edx,0x10(%ebp)
  8007bf:	0f b6 00             	movzbl (%eax),%eax
  8007c2:	0f b6 d8             	movzbl %al,%ebx
  8007c5:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007c8:	83 f8 55             	cmp    $0x55,%eax
  8007cb:	0f 87 3d 03 00 00    	ja     800b0e <vprintfmt+0x3ae>
  8007d1:	8b 04 85 cc 15 80 00 	mov    0x8015cc(,%eax,4),%eax
  8007d8:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007da:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007de:	eb d6                	jmp    8007b6 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007e0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007e4:	eb d0                	jmp    8007b6 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007ed:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007f0:	89 d0                	mov    %edx,%eax
  8007f2:	c1 e0 02             	shl    $0x2,%eax
  8007f5:	01 d0                	add    %edx,%eax
  8007f7:	01 c0                	add    %eax,%eax
  8007f9:	01 d8                	add    %ebx,%eax
  8007fb:	83 e8 30             	sub    $0x30,%eax
  8007fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800801:	8b 45 10             	mov    0x10(%ebp),%eax
  800804:	0f b6 00             	movzbl (%eax),%eax
  800807:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80080a:	83 fb 2f             	cmp    $0x2f,%ebx
  80080d:	7e 0b                	jle    80081a <vprintfmt+0xba>
  80080f:	83 fb 39             	cmp    $0x39,%ebx
  800812:	7f 06                	jg     80081a <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800814:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800818:	eb d3                	jmp    8007ed <vprintfmt+0x8d>
			goto process_precision;
  80081a:	eb 33                	jmp    80084f <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8d 50 04             	lea    0x4(%eax),%edx
  800822:	89 55 14             	mov    %edx,0x14(%ebp)
  800825:	8b 00                	mov    (%eax),%eax
  800827:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80082a:	eb 23                	jmp    80084f <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80082c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800830:	79 0c                	jns    80083e <vprintfmt+0xde>
				width = 0;
  800832:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800839:	e9 78 ff ff ff       	jmp    8007b6 <vprintfmt+0x56>
  80083e:	e9 73 ff ff ff       	jmp    8007b6 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800843:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80084a:	e9 67 ff ff ff       	jmp    8007b6 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80084f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800853:	79 12                	jns    800867 <vprintfmt+0x107>
				width = precision, precision = -1;
  800855:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800862:	e9 4f ff ff ff       	jmp    8007b6 <vprintfmt+0x56>
  800867:	e9 4a ff ff ff       	jmp    8007b6 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80086c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800870:	e9 41 ff ff ff       	jmp    8007b6 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8d 50 04             	lea    0x4(%eax),%edx
  80087b:	89 55 14             	mov    %edx,0x14(%ebp)
  80087e:	8b 00                	mov    (%eax),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 54 24 04          	mov    %edx,0x4(%esp)
  800887:	89 04 24             	mov    %eax,(%esp)
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	ff d0                	call   *%eax
			break;
  80088f:	e9 a5 02 00 00       	jmp    800b39 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8d 50 04             	lea    0x4(%eax),%edx
  80089a:	89 55 14             	mov    %edx,0x14(%ebp)
  80089d:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80089f:	85 db                	test   %ebx,%ebx
  8008a1:	79 02                	jns    8008a5 <vprintfmt+0x145>
				err = -err;
  8008a3:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008a5:	83 fb 09             	cmp    $0x9,%ebx
  8008a8:	7f 0b                	jg     8008b5 <vprintfmt+0x155>
  8008aa:	8b 34 9d 80 15 80 00 	mov    0x801580(,%ebx,4),%esi
  8008b1:	85 f6                	test   %esi,%esi
  8008b3:	75 23                	jne    8008d8 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008b5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008b9:	c7 44 24 08 b9 15 80 	movl   $0x8015b9,0x8(%esp)
  8008c0:	00 
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 73 02 00 00       	call   800b46 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008d3:	e9 61 02 00 00       	jmp    800b39 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008dc:	c7 44 24 08 c2 15 80 	movl   $0x8015c2,0x8(%esp)
  8008e3:	00 
  8008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	89 04 24             	mov    %eax,(%esp)
  8008f1:	e8 50 02 00 00       	call   800b46 <printfmt>
			break;
  8008f6:	e9 3e 02 00 00       	jmp    800b39 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8d 50 04             	lea    0x4(%eax),%edx
  800901:	89 55 14             	mov    %edx,0x14(%ebp)
  800904:	8b 30                	mov    (%eax),%esi
  800906:	85 f6                	test   %esi,%esi
  800908:	75 05                	jne    80090f <vprintfmt+0x1af>
				p = "(null)";
  80090a:	be c5 15 80 00       	mov    $0x8015c5,%esi
			if (width > 0 && padc != '-')
  80090f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800913:	7e 37                	jle    80094c <vprintfmt+0x1ec>
  800915:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800919:	74 31                	je     80094c <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80091b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800922:	89 34 24             	mov    %esi,(%esp)
  800925:	e8 39 03 00 00       	call   800c63 <strnlen>
  80092a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80092d:	eb 17                	jmp    800946 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80092f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
  800936:	89 54 24 04          	mov    %edx,0x4(%esp)
  80093a:	89 04 24             	mov    %eax,(%esp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800942:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800946:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094a:	7f e3                	jg     80092f <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094c:	eb 38                	jmp    800986 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80094e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800952:	74 1f                	je     800973 <vprintfmt+0x213>
  800954:	83 fb 1f             	cmp    $0x1f,%ebx
  800957:	7e 05                	jle    80095e <vprintfmt+0x1fe>
  800959:	83 fb 7e             	cmp    $0x7e,%ebx
  80095c:	7e 15                	jle    800973 <vprintfmt+0x213>
					putch('?', putdat);
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	89 44 24 04          	mov    %eax,0x4(%esp)
  800965:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	ff d0                	call   *%eax
  800971:	eb 0f                	jmp    800982 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800973:	8b 45 0c             	mov    0xc(%ebp),%eax
  800976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097a:	89 1c 24             	mov    %ebx,(%esp)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800982:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800986:	89 f0                	mov    %esi,%eax
  800988:	8d 70 01             	lea    0x1(%eax),%esi
  80098b:	0f b6 00             	movzbl (%eax),%eax
  80098e:	0f be d8             	movsbl %al,%ebx
  800991:	85 db                	test   %ebx,%ebx
  800993:	74 10                	je     8009a5 <vprintfmt+0x245>
  800995:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800999:	78 b3                	js     80094e <vprintfmt+0x1ee>
  80099b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80099f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009a3:	79 a9                	jns    80094e <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a5:	eb 17                	jmp    8009be <vprintfmt+0x25e>
				putch(' ', putdat);
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ba:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009c2:	7f e3                	jg     8009a7 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009c4:	e9 70 01 00 00       	jmp    800b39 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d3:	89 04 24             	mov    %eax,(%esp)
  8009d6:	e8 3e fd ff ff       	call   800719 <getint>
  8009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009de:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	79 26                	jns    800a11 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	ff d0                	call   *%eax
				num = -(long long) num;
  8009fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a04:	f7 d8                	neg    %eax
  800a06:	83 d2 00             	adc    $0x0,%edx
  800a09:	f7 da                	neg    %edx
  800a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a11:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a18:	e9 a8 00 00 00       	jmp    800ac5 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a24:	8d 45 14             	lea    0x14(%ebp),%eax
  800a27:	89 04 24             	mov    %eax,(%esp)
  800a2a:	e8 9b fc ff ff       	call   8006ca <getuint>
  800a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a32:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a35:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a3c:	e9 84 00 00 00       	jmp    800ac5 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a41:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a48:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4b:	89 04 24             	mov    %eax,(%esp)
  800a4e:	e8 77 fc ff ff       	call   8006ca <getuint>
  800a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a56:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a59:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a60:	eb 63                	jmp    800ac5 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a69:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	ff d0                	call   *%eax
			putch('x', putdat);
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 04             	lea    0x4(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a93:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a9d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800aa4:	eb 1f                	jmp    800ac5 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aad:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab0:	89 04 24             	mov    %eax,(%esp)
  800ab3:	e8 12 fc ff ff       	call   8006ca <getuint>
  800ab8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abb:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800abe:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac5:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ac9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800acc:	89 54 24 18          	mov    %edx,0x18(%esp)
  800ad0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ad3:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ad7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	89 04 24             	mov    %eax,(%esp)
  800af6:	e8 f1 fa ff ff       	call   8005ec <printnum>
			break;
  800afb:	eb 3c                	jmp    800b39 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b04:	89 1c 24             	mov    %ebx,(%esp)
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	ff d0                	call   *%eax
			break;
  800b0c:	eb 2b                	jmp    800b39 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b15:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b21:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b25:	eb 04                	jmp    800b2b <vprintfmt+0x3cb>
  800b27:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2e:	83 e8 01             	sub    $0x1,%eax
  800b31:	0f b6 00             	movzbl (%eax),%eax
  800b34:	3c 25                	cmp    $0x25,%al
  800b36:	75 ef                	jne    800b27 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b38:	90                   	nop
		}
	}
  800b39:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b3a:	e9 43 fc ff ff       	jmp    800782 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b3f:	83 c4 40             	add    $0x40,%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b4c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b59:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	89 04 24             	mov    %eax,(%esp)
  800b6d:	e8 ee fb ff ff       	call   800760 <vprintfmt>
	va_end(ap);
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	8b 40 08             	mov    0x8(%eax),%eax
  800b7d:	8d 50 01             	lea    0x1(%eax),%edx
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b89:	8b 10                	mov    (%eax),%edx
  800b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8e:	8b 40 04             	mov    0x4(%eax),%eax
  800b91:	39 c2                	cmp    %eax,%edx
  800b93:	73 12                	jae    800ba7 <sprintputch+0x33>
		*b->buf++ = ch;
  800b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b98:	8b 00                	mov    (%eax),%eax
  800b9a:	8d 48 01             	lea    0x1(%eax),%ecx
  800b9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba0:	89 0a                	mov    %ecx,(%edx)
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	88 10                	mov    %dl,(%eax)
}
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb8:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	01 d0                	add    %edx,%eax
  800bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bce:	74 06                	je     800bd6 <vsnprintf+0x2d>
  800bd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd4:	7f 07                	jg     800bdd <vsnprintf+0x34>
		return -E_INVAL;
  800bd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bdb:	eb 2a                	jmp    800c07 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bdd:	8b 45 14             	mov    0x14(%ebp),%eax
  800be0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be4:	8b 45 10             	mov    0x10(%ebp),%eax
  800be7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800beb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf2:	c7 04 24 74 0b 80 00 	movl   $0x800b74,(%esp)
  800bf9:	e8 62 fb ff ff       	call   800760 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c01:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800c12:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	89 04 24             	mov    %eax,(%esp)
  800c30:	e8 74 ff ff ff       	call   800ba9 <vsnprintf>
  800c35:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c43:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c4a:	eb 08                	jmp    800c54 <strlen+0x17>
		n++;
  800c4c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	0f b6 00             	movzbl (%eax),%eax
  800c5a:	84 c0                	test   %al,%al
  800c5c:	75 ee                	jne    800c4c <strlen+0xf>
		n++;
	return n;
  800c5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c69:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c70:	eb 0c                	jmp    800c7e <strnlen+0x1b>
		n++;
  800c72:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c76:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7a:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c82:	74 0a                	je     800c8e <strnlen+0x2b>
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	0f b6 00             	movzbl (%eax),%eax
  800c8a:	84 c0                	test   %al,%al
  800c8c:	75 e4                	jne    800c72 <strnlen+0xf>
		n++;
	return n;
  800c8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c9f:	90                   	nop
  800ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca3:	8d 50 01             	lea    0x1(%eax),%edx
  800ca6:	89 55 08             	mov    %edx,0x8(%ebp)
  800ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cac:	8d 4a 01             	lea    0x1(%edx),%ecx
  800caf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cb2:	0f b6 12             	movzbl (%edx),%edx
  800cb5:	88 10                	mov    %dl,(%eax)
  800cb7:	0f b6 00             	movzbl (%eax),%eax
  800cba:	84 c0                	test   %al,%al
  800cbc:	75 e2                	jne    800ca0 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cc1:	c9                   	leave  
  800cc2:	c3                   	ret    

00800cc3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	89 04 24             	mov    %eax,(%esp)
  800ccf:	e8 69 ff ff ff       	call   800c3d <strlen>
  800cd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cd7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	01 c2                	add    %eax,%edx
  800cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce6:	89 14 24             	mov    %edx,(%esp)
  800ce9:	e8 a5 ff ff ff       	call   800c93 <strcpy>
	return dst;
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d06:	eb 23                	jmp    800d2b <strncpy+0x38>
		*dst++ = *src;
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8d 50 01             	lea    0x1(%eax),%edx
  800d0e:	89 55 08             	mov    %edx,0x8(%ebp)
  800d11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d14:	0f b6 12             	movzbl (%edx),%edx
  800d17:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1c:	0f b6 00             	movzbl (%eax),%eax
  800d1f:	84 c0                	test   %al,%al
  800d21:	74 04                	je     800d27 <strncpy+0x34>
			src++;
  800d23:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2e:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d31:	72 d5                	jb     800d08 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d33:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d48:	74 33                	je     800d7d <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d4a:	eb 17                	jmp    800d63 <strlcpy+0x2b>
			*dst++ = *src++;
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8d 50 01             	lea    0x1(%eax),%edx
  800d52:	89 55 08             	mov    %edx,0x8(%ebp)
  800d55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d58:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d5b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d5e:	0f b6 12             	movzbl (%edx),%edx
  800d61:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d63:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d6b:	74 0a                	je     800d77 <strlcpy+0x3f>
  800d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d70:	0f b6 00             	movzbl (%eax),%eax
  800d73:	84 c0                	test   %al,%al
  800d75:	75 d5                	jne    800d4c <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d80:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d83:	29 c2                	sub    %eax,%edx
  800d85:	89 d0                	mov    %edx,%eax
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d8c:	eb 08                	jmp    800d96 <strcmp+0xd>
		p++, q++;
  800d8e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d92:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	0f b6 00             	movzbl (%eax),%eax
  800d9c:	84 c0                	test   %al,%al
  800d9e:	74 10                	je     800db0 <strcmp+0x27>
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	0f b6 10             	movzbl (%eax),%edx
  800da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da9:	0f b6 00             	movzbl (%eax),%eax
  800dac:	38 c2                	cmp    %al,%dl
  800dae:	74 de                	je     800d8e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	0f b6 00             	movzbl (%eax),%eax
  800db6:	0f b6 d0             	movzbl %al,%edx
  800db9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbc:	0f b6 00             	movzbl (%eax),%eax
  800dbf:	0f b6 c0             	movzbl %al,%eax
  800dc2:	29 c2                	sub    %eax,%edx
  800dc4:	89 d0                	mov    %edx,%eax
}
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dcb:	eb 0c                	jmp    800dd9 <strncmp+0x11>
		n--, p++, q++;
  800dcd:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dd1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ddd:	74 1a                	je     800df9 <strncmp+0x31>
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	84 c0                	test   %al,%al
  800de7:	74 10                	je     800df9 <strncmp+0x31>
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	0f b6 10             	movzbl (%eax),%edx
  800def:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df2:	0f b6 00             	movzbl (%eax),%eax
  800df5:	38 c2                	cmp    %al,%dl
  800df7:	74 d4                	je     800dcd <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800df9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfd:	75 07                	jne    800e06 <strncmp+0x3e>
		return 0;
  800dff:	b8 00 00 00 00       	mov    $0x0,%eax
  800e04:	eb 16                	jmp    800e1c <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	0f b6 00             	movzbl (%eax),%eax
  800e0c:	0f b6 d0             	movzbl %al,%edx
  800e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e12:	0f b6 00             	movzbl (%eax),%eax
  800e15:	0f b6 c0             	movzbl %al,%eax
  800e18:	29 c2                	sub    %eax,%edx
  800e1a:	89 d0                	mov    %edx,%eax
}
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e27:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e2a:	eb 14                	jmp    800e40 <strchr+0x22>
		if (*s == c)
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e35:	75 05                	jne    800e3c <strchr+0x1e>
			return (char *) s;
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	eb 13                	jmp    800e4f <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	0f b6 00             	movzbl (%eax),%eax
  800e46:	84 c0                	test   %al,%al
  800e48:	75 e2                	jne    800e2c <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e5d:	eb 11                	jmp    800e70 <strfind+0x1f>
		if (*s == c)
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	0f b6 00             	movzbl (%eax),%eax
  800e65:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e68:	75 02                	jne    800e6c <strfind+0x1b>
			break;
  800e6a:	eb 0e                	jmp    800e7a <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e6c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	0f b6 00             	movzbl (%eax),%eax
  800e76:	84 c0                	test   %al,%al
  800e78:	75 e5                	jne    800e5f <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e87:	75 05                	jne    800e8e <memset+0xf>
		return v;
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	eb 5c                	jmp    800eea <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	83 e0 03             	and    $0x3,%eax
  800e94:	85 c0                	test   %eax,%eax
  800e96:	75 41                	jne    800ed9 <memset+0x5a>
  800e98:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9b:	83 e0 03             	and    $0x3,%eax
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	75 37                	jne    800ed9 <memset+0x5a>
		c &= 0xFF;
  800ea2:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eac:	c1 e0 18             	shl    $0x18,%eax
  800eaf:	89 c2                	mov    %eax,%edx
  800eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb4:	c1 e0 10             	shl    $0x10,%eax
  800eb7:	09 c2                	or     %eax,%edx
  800eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebc:	c1 e0 08             	shl    $0x8,%eax
  800ebf:	09 d0                	or     %edx,%eax
  800ec1:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ec4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec7:	c1 e8 02             	shr    $0x2,%eax
  800eca:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ecc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed2:	89 d7                	mov    %edx,%edi
  800ed4:	fc                   	cld    
  800ed5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ed7:	eb 0e                	jmp    800ee7 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ee2:	89 d7                	mov    %edx,%edi
  800ee4:	fc                   	cld    
  800ee5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f05:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f08:	73 6d                	jae    800f77 <memmove+0x8a>
  800f0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f10:	01 d0                	add    %edx,%eax
  800f12:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f15:	76 60                	jbe    800f77 <memmove+0x8a>
		s += n;
  800f17:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1a:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f20:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f26:	83 e0 03             	and    $0x3,%eax
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	75 2f                	jne    800f5c <memmove+0x6f>
  800f2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f30:	83 e0 03             	and    $0x3,%eax
  800f33:	85 c0                	test   %eax,%eax
  800f35:	75 25                	jne    800f5c <memmove+0x6f>
  800f37:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3a:	83 e0 03             	and    $0x3,%eax
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	75 1b                	jne    800f5c <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f44:	83 e8 04             	sub    $0x4,%eax
  800f47:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f4a:	83 ea 04             	sub    $0x4,%edx
  800f4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f50:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f53:	89 c7                	mov    %eax,%edi
  800f55:	89 d6                	mov    %edx,%esi
  800f57:	fd                   	std    
  800f58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5a:	eb 18                	jmp    800f74 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f65:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f68:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6b:	89 d7                	mov    %edx,%edi
  800f6d:	89 de                	mov    %ebx,%esi
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	fd                   	std    
  800f72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f74:	fc                   	cld    
  800f75:	eb 45                	jmp    800fbc <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7a:	83 e0 03             	and    $0x3,%eax
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	75 2b                	jne    800fac <memmove+0xbf>
  800f81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f84:	83 e0 03             	and    $0x3,%eax
  800f87:	85 c0                	test   %eax,%eax
  800f89:	75 21                	jne    800fac <memmove+0xbf>
  800f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8e:	83 e0 03             	and    $0x3,%eax
  800f91:	85 c0                	test   %eax,%eax
  800f93:	75 17                	jne    800fac <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f95:	8b 45 10             	mov    0x10(%ebp),%eax
  800f98:	c1 e8 02             	shr    $0x2,%eax
  800f9b:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa3:	89 c7                	mov    %eax,%edi
  800fa5:	89 d6                	mov    %edx,%esi
  800fa7:	fc                   	cld    
  800fa8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800faa:	eb 10                	jmp    800fbc <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800faf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fb2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb5:	89 c7                	mov    %eax,%edi
  800fb7:	89 d6                	mov    %edx,%esi
  800fb9:	fc                   	cld    
  800fba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fbc:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	5b                   	pop    %ebx
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    

00800fc7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fcd:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	89 04 24             	mov    %eax,(%esp)
  800fe1:	e8 07 ff ff ff       	call   800eed <memmove>
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ffa:	eb 30                	jmp    80102c <memcmp+0x44>
		if (*s1 != *s2)
  800ffc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fff:	0f b6 10             	movzbl (%eax),%edx
  801002:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801005:	0f b6 00             	movzbl (%eax),%eax
  801008:	38 c2                	cmp    %al,%dl
  80100a:	74 18                	je     801024 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80100c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80100f:	0f b6 00             	movzbl (%eax),%eax
  801012:	0f b6 d0             	movzbl %al,%edx
  801015:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801018:	0f b6 00             	movzbl (%eax),%eax
  80101b:	0f b6 c0             	movzbl %al,%eax
  80101e:	29 c2                	sub    %eax,%edx
  801020:	89 d0                	mov    %edx,%eax
  801022:	eb 1a                	jmp    80103e <memcmp+0x56>
		s1++, s2++;
  801024:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801028:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102c:	8b 45 10             	mov    0x10(%ebp),%eax
  80102f:	8d 50 ff             	lea    -0x1(%eax),%edx
  801032:	89 55 10             	mov    %edx,0x10(%ebp)
  801035:	85 c0                	test   %eax,%eax
  801037:	75 c3                	jne    800ffc <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801039:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801046:	8b 45 10             	mov    0x10(%ebp),%eax
  801049:	8b 55 08             	mov    0x8(%ebp),%edx
  80104c:	01 d0                	add    %edx,%eax
  80104e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801051:	eb 13                	jmp    801066 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	0f b6 10             	movzbl (%eax),%edx
  801059:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105c:	38 c2                	cmp    %al,%dl
  80105e:	75 02                	jne    801062 <memfind+0x22>
			break;
  801060:	eb 0c                	jmp    80106e <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801062:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80106c:	72 e5                	jb     801053 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801079:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801080:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801087:	eb 04                	jmp    80108d <strtol+0x1a>
		s++;
  801089:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	0f b6 00             	movzbl (%eax),%eax
  801093:	3c 20                	cmp    $0x20,%al
  801095:	74 f2                	je     801089 <strtol+0x16>
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	0f b6 00             	movzbl (%eax),%eax
  80109d:	3c 09                	cmp    $0x9,%al
  80109f:	74 e8                	je     801089 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a4:	0f b6 00             	movzbl (%eax),%eax
  8010a7:	3c 2b                	cmp    $0x2b,%al
  8010a9:	75 06                	jne    8010b1 <strtol+0x3e>
		s++;
  8010ab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010af:	eb 15                	jmp    8010c6 <strtol+0x53>
	else if (*s == '-')
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b4:	0f b6 00             	movzbl (%eax),%eax
  8010b7:	3c 2d                	cmp    $0x2d,%al
  8010b9:	75 0b                	jne    8010c6 <strtol+0x53>
		s++, neg = 1;
  8010bb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010bf:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ca:	74 06                	je     8010d2 <strtol+0x5f>
  8010cc:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010d0:	75 24                	jne    8010f6 <strtol+0x83>
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	0f b6 00             	movzbl (%eax),%eax
  8010d8:	3c 30                	cmp    $0x30,%al
  8010da:	75 1a                	jne    8010f6 <strtol+0x83>
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	83 c0 01             	add    $0x1,%eax
  8010e2:	0f b6 00             	movzbl (%eax),%eax
  8010e5:	3c 78                	cmp    $0x78,%al
  8010e7:	75 0d                	jne    8010f6 <strtol+0x83>
		s += 2, base = 16;
  8010e9:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010ed:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010f4:	eb 2a                	jmp    801120 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010fa:	75 17                	jne    801113 <strtol+0xa0>
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ff:	0f b6 00             	movzbl (%eax),%eax
  801102:	3c 30                	cmp    $0x30,%al
  801104:	75 0d                	jne    801113 <strtol+0xa0>
		s++, base = 8;
  801106:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80110a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801111:	eb 0d                	jmp    801120 <strtol+0xad>
	else if (base == 0)
  801113:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801117:	75 07                	jne    801120 <strtol+0xad>
		base = 10;
  801119:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	0f b6 00             	movzbl (%eax),%eax
  801126:	3c 2f                	cmp    $0x2f,%al
  801128:	7e 1b                	jle    801145 <strtol+0xd2>
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	0f b6 00             	movzbl (%eax),%eax
  801130:	3c 39                	cmp    $0x39,%al
  801132:	7f 11                	jg     801145 <strtol+0xd2>
			dig = *s - '0';
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	0f b6 00             	movzbl (%eax),%eax
  80113a:	0f be c0             	movsbl %al,%eax
  80113d:	83 e8 30             	sub    $0x30,%eax
  801140:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801143:	eb 48                	jmp    80118d <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	0f b6 00             	movzbl (%eax),%eax
  80114b:	3c 60                	cmp    $0x60,%al
  80114d:	7e 1b                	jle    80116a <strtol+0xf7>
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	0f b6 00             	movzbl (%eax),%eax
  801155:	3c 7a                	cmp    $0x7a,%al
  801157:	7f 11                	jg     80116a <strtol+0xf7>
			dig = *s - 'a' + 10;
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	0f b6 00             	movzbl (%eax),%eax
  80115f:	0f be c0             	movsbl %al,%eax
  801162:	83 e8 57             	sub    $0x57,%eax
  801165:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801168:	eb 23                	jmp    80118d <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80116a:	8b 45 08             	mov    0x8(%ebp),%eax
  80116d:	0f b6 00             	movzbl (%eax),%eax
  801170:	3c 40                	cmp    $0x40,%al
  801172:	7e 3d                	jle    8011b1 <strtol+0x13e>
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	0f b6 00             	movzbl (%eax),%eax
  80117a:	3c 5a                	cmp    $0x5a,%al
  80117c:	7f 33                	jg     8011b1 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	0f b6 00             	movzbl (%eax),%eax
  801184:	0f be c0             	movsbl %al,%eax
  801187:	83 e8 37             	sub    $0x37,%eax
  80118a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80118d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801190:	3b 45 10             	cmp    0x10(%ebp),%eax
  801193:	7c 02                	jl     801197 <strtol+0x124>
			break;
  801195:	eb 1a                	jmp    8011b1 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801197:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80119b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80119e:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a7:	01 d0                	add    %edx,%eax
  8011a9:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011ac:	e9 6f ff ff ff       	jmp    801120 <strtol+0xad>

	if (endptr)
  8011b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011b5:	74 08                	je     8011bf <strtol+0x14c>
		*endptr = (char *) s;
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bd:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011bf:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011c3:	74 07                	je     8011cc <strtol+0x159>
  8011c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011c8:	f7 d8                	neg    %eax
  8011ca:	eb 03                	jmp    8011cf <strtol+0x15c>
  8011cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    
  8011d1:	66 90                	xchg   %ax,%ax
  8011d3:	66 90                	xchg   %ax,%ax
  8011d5:	66 90                	xchg   %ax,%ax
  8011d7:	66 90                	xchg   %ax,%ax
  8011d9:	66 90                	xchg   %ax,%ax
  8011db:	66 90                	xchg   %ax,%ax
  8011dd:	66 90                	xchg   %ax,%ax
  8011df:	90                   	nop

008011e0 <__udivdi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011fc:	89 ea                	mov    %ebp,%edx
  8011fe:	89 0c 24             	mov    %ecx,(%esp)
  801201:	75 2d                	jne    801230 <__udivdi3+0x50>
  801203:	39 e9                	cmp    %ebp,%ecx
  801205:	77 61                	ja     801268 <__udivdi3+0x88>
  801207:	85 c9                	test   %ecx,%ecx
  801209:	89 ce                	mov    %ecx,%esi
  80120b:	75 0b                	jne    801218 <__udivdi3+0x38>
  80120d:	b8 01 00 00 00       	mov    $0x1,%eax
  801212:	31 d2                	xor    %edx,%edx
  801214:	f7 f1                	div    %ecx
  801216:	89 c6                	mov    %eax,%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	89 e8                	mov    %ebp,%eax
  80121c:	f7 f6                	div    %esi
  80121e:	89 c5                	mov    %eax,%ebp
  801220:	89 f8                	mov    %edi,%eax
  801222:	f7 f6                	div    %esi
  801224:	89 ea                	mov    %ebp,%edx
  801226:	83 c4 0c             	add    $0xc,%esp
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    
  80122d:	8d 76 00             	lea    0x0(%esi),%esi
  801230:	39 e8                	cmp    %ebp,%eax
  801232:	77 24                	ja     801258 <__udivdi3+0x78>
  801234:	0f bd e8             	bsr    %eax,%ebp
  801237:	83 f5 1f             	xor    $0x1f,%ebp
  80123a:	75 3c                	jne    801278 <__udivdi3+0x98>
  80123c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801240:	39 34 24             	cmp    %esi,(%esp)
  801243:	0f 86 9f 00 00 00    	jbe    8012e8 <__udivdi3+0x108>
  801249:	39 d0                	cmp    %edx,%eax
  80124b:	0f 82 97 00 00 00    	jb     8012e8 <__udivdi3+0x108>
  801251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	31 c0                	xor    %eax,%eax
  80125c:	83 c4 0c             	add    $0xc,%esp
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
  801263:	90                   	nop
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	89 f8                	mov    %edi,%eax
  80126a:	f7 f1                	div    %ecx
  80126c:	31 d2                	xor    %edx,%edx
  80126e:	83 c4 0c             	add    $0xc,%esp
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
  801275:	8d 76 00             	lea    0x0(%esi),%esi
  801278:	89 e9                	mov    %ebp,%ecx
  80127a:	8b 3c 24             	mov    (%esp),%edi
  80127d:	d3 e0                	shl    %cl,%eax
  80127f:	89 c6                	mov    %eax,%esi
  801281:	b8 20 00 00 00       	mov    $0x20,%eax
  801286:	29 e8                	sub    %ebp,%eax
  801288:	89 c1                	mov    %eax,%ecx
  80128a:	d3 ef                	shr    %cl,%edi
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801292:	8b 3c 24             	mov    (%esp),%edi
  801295:	09 74 24 08          	or     %esi,0x8(%esp)
  801299:	89 d6                	mov    %edx,%esi
  80129b:	d3 e7                	shl    %cl,%edi
  80129d:	89 c1                	mov    %eax,%ecx
  80129f:	89 3c 24             	mov    %edi,(%esp)
  8012a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012a6:	d3 ee                	shr    %cl,%esi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	d3 e2                	shl    %cl,%edx
  8012ac:	89 c1                	mov    %eax,%ecx
  8012ae:	d3 ef                	shr    %cl,%edi
  8012b0:	09 d7                	or     %edx,%edi
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	f7 74 24 08          	divl   0x8(%esp)
  8012ba:	89 d6                	mov    %edx,%esi
  8012bc:	89 c7                	mov    %eax,%edi
  8012be:	f7 24 24             	mull   (%esp)
  8012c1:	39 d6                	cmp    %edx,%esi
  8012c3:	89 14 24             	mov    %edx,(%esp)
  8012c6:	72 30                	jb     8012f8 <__udivdi3+0x118>
  8012c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	39 c2                	cmp    %eax,%edx
  8012d2:	73 05                	jae    8012d9 <__udivdi3+0xf9>
  8012d4:	3b 34 24             	cmp    (%esp),%esi
  8012d7:	74 1f                	je     8012f8 <__udivdi3+0x118>
  8012d9:	89 f8                	mov    %edi,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	e9 7a ff ff ff       	jmp    80125c <__udivdi3+0x7c>
  8012e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ef:	e9 68 ff ff ff       	jmp    80125c <__udivdi3+0x7c>
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	83 c4 0c             	add    $0xc,%esp
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
  801304:	66 90                	xchg   %ax,%ax
  801306:	66 90                	xchg   %ax,%ax
  801308:	66 90                	xchg   %ax,%ax
  80130a:	66 90                	xchg   %ax,%ax
  80130c:	66 90                	xchg   %ax,%ax
  80130e:	66 90                	xchg   %ax,%ax

00801310 <__umoddi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80131a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80131e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801322:	89 c7                	mov    %eax,%edi
  801324:	89 44 24 04          	mov    %eax,0x4(%esp)
  801328:	8b 44 24 30          	mov    0x30(%esp),%eax
  80132c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801330:	89 34 24             	mov    %esi,(%esp)
  801333:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801337:	85 c0                	test   %eax,%eax
  801339:	89 c2                	mov    %eax,%edx
  80133b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80133f:	75 17                	jne    801358 <__umoddi3+0x48>
  801341:	39 fe                	cmp    %edi,%esi
  801343:	76 4b                	jbe    801390 <__umoddi3+0x80>
  801345:	89 c8                	mov    %ecx,%eax
  801347:	89 fa                	mov    %edi,%edx
  801349:	f7 f6                	div    %esi
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	31 d2                	xor    %edx,%edx
  80134f:	83 c4 14             	add    $0x14,%esp
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    
  801356:	66 90                	xchg   %ax,%ax
  801358:	39 f8                	cmp    %edi,%eax
  80135a:	77 54                	ja     8013b0 <__umoddi3+0xa0>
  80135c:	0f bd e8             	bsr    %eax,%ebp
  80135f:	83 f5 1f             	xor    $0x1f,%ebp
  801362:	75 5c                	jne    8013c0 <__umoddi3+0xb0>
  801364:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801368:	39 3c 24             	cmp    %edi,(%esp)
  80136b:	0f 87 e7 00 00 00    	ja     801458 <__umoddi3+0x148>
  801371:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801375:	29 f1                	sub    %esi,%ecx
  801377:	19 c7                	sbb    %eax,%edi
  801379:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801381:	8b 44 24 08          	mov    0x8(%esp),%eax
  801385:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801389:	83 c4 14             	add    $0x14,%esp
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    
  801390:	85 f6                	test   %esi,%esi
  801392:	89 f5                	mov    %esi,%ebp
  801394:	75 0b                	jne    8013a1 <__umoddi3+0x91>
  801396:	b8 01 00 00 00       	mov    $0x1,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	f7 f6                	div    %esi
  80139f:	89 c5                	mov    %eax,%ebp
  8013a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013a5:	31 d2                	xor    %edx,%edx
  8013a7:	f7 f5                	div    %ebp
  8013a9:	89 c8                	mov    %ecx,%eax
  8013ab:	f7 f5                	div    %ebp
  8013ad:	eb 9c                	jmp    80134b <__umoddi3+0x3b>
  8013af:	90                   	nop
  8013b0:	89 c8                	mov    %ecx,%eax
  8013b2:	89 fa                	mov    %edi,%edx
  8013b4:	83 c4 14             	add    $0x14,%esp
  8013b7:	5e                   	pop    %esi
  8013b8:	5f                   	pop    %edi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    
  8013bb:	90                   	nop
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	8b 04 24             	mov    (%esp),%eax
  8013c3:	be 20 00 00 00       	mov    $0x20,%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	29 ee                	sub    %ebp,%esi
  8013cc:	d3 e2                	shl    %cl,%edx
  8013ce:	89 f1                	mov    %esi,%ecx
  8013d0:	d3 e8                	shr    %cl,%eax
  8013d2:	89 e9                	mov    %ebp,%ecx
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 04 24             	mov    (%esp),%eax
  8013db:	09 54 24 04          	or     %edx,0x4(%esp)
  8013df:	89 fa                	mov    %edi,%edx
  8013e1:	d3 e0                	shl    %cl,%eax
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ed:	d3 ea                	shr    %cl,%edx
  8013ef:	89 e9                	mov    %ebp,%ecx
  8013f1:	d3 e7                	shl    %cl,%edi
  8013f3:	89 f1                	mov    %esi,%ecx
  8013f5:	d3 e8                	shr    %cl,%eax
  8013f7:	89 e9                	mov    %ebp,%ecx
  8013f9:	09 f8                	or     %edi,%eax
  8013fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013ff:	f7 74 24 04          	divl   0x4(%esp)
  801403:	d3 e7                	shl    %cl,%edi
  801405:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801409:	89 d7                	mov    %edx,%edi
  80140b:	f7 64 24 08          	mull   0x8(%esp)
  80140f:	39 d7                	cmp    %edx,%edi
  801411:	89 c1                	mov    %eax,%ecx
  801413:	89 14 24             	mov    %edx,(%esp)
  801416:	72 2c                	jb     801444 <__umoddi3+0x134>
  801418:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80141c:	72 22                	jb     801440 <__umoddi3+0x130>
  80141e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801422:	29 c8                	sub    %ecx,%eax
  801424:	19 d7                	sbb    %edx,%edi
  801426:	89 e9                	mov    %ebp,%ecx
  801428:	89 fa                	mov    %edi,%edx
  80142a:	d3 e8                	shr    %cl,%eax
  80142c:	89 f1                	mov    %esi,%ecx
  80142e:	d3 e2                	shl    %cl,%edx
  801430:	89 e9                	mov    %ebp,%ecx
  801432:	d3 ef                	shr    %cl,%edi
  801434:	09 d0                	or     %edx,%eax
  801436:	89 fa                	mov    %edi,%edx
  801438:	83 c4 14             	add    $0x14,%esp
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    
  80143f:	90                   	nop
  801440:	39 d7                	cmp    %edx,%edi
  801442:	75 da                	jne    80141e <__umoddi3+0x10e>
  801444:	8b 14 24             	mov    (%esp),%edx
  801447:	89 c1                	mov    %eax,%ecx
  801449:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80144d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801451:	eb cb                	jmp    80141e <__umoddi3+0x10e>
  801453:	90                   	nop
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80145c:	0f 82 0f ff ff ff    	jb     801371 <__umoddi3+0x61>
  801462:	e9 1a ff ff ff       	jmp    801381 <__umoddi3+0x71>
